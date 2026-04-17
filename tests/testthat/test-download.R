# =============================================================================
# test-download.R — Tests for all exported functions in R/download.R
# =============================================================================

# Shared mock data ------------------------------------------------------------

.fake_gene_ref <- function(species = "human") {
  data.frame(
    ensembl_id       = paste0("ENSG0000", seq_len(5)),
    symbol           = c("TP53", "BRCA1", "MYC", "EGFR", "PTEN"),
    entrez_id        = c("7157", "672", "4609", "1956", "5728"),
    gene_type        = rep("protein_coding", 5),
    chromosome       = c("17", "17", "8", "7", "10"),
    start            = c(7661779L, 43044295L, 127735434L, 55019017L, 89692905L),
    end              = c(7687550L, 43125483L, 127742951L, 55211628L, 89728532L),
    strand           = c(-1L, 1L, 1L, 1L, -1L),
    description      = rep("protein coding gene", 5),
    stringsAsFactors = FALSE
  )
}


# =============================================================================
# download_gene_ref()
# =============================================================================

test_that("download_gene_ref errors on invalid species", {
  expect_error(download_gene_ref(species = "fly"),   class = "error")
  expect_error(download_gene_ref(species = "Human"), class = "error")
  expect_error(download_gene_ref(species = ""),      class = "error")
})

test_that("download_gene_ref errors when dest is not a scalar string", {
  expect_error(download_gene_ref(dest = 123),               class = "rlang_error")
  expect_error(download_gene_ref(dest = c("a.rds", "b")),  class = "rlang_error")
  expect_error(download_gene_ref(dest = ""),                class = "rlang_error")
})

test_that("download_gene_ref errors with informative message when biomaRt is absent", {
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) FALSE,
    .package = "base"
  )
  expect_error(download_gene_ref(species = "human"), regexp = "biomaRt", class = "rlang_error")
})

test_that("download_gene_ref appends .rds when dest has no extension", {
  tmp <- withr::local_tempfile()   # no .rds extension

  local_mocked_bindings(
    useMart             = function(...) list(),
    listEnsemblArchives = function(...) data.frame(version = "110",
                                                   current_release = "*",
                                                   stringsAsFactors = FALSE),
    getBM               = function(...) .fake_gene_ref(),
    .package = "biomaRt"
  )

  download_gene_ref(species = "human", dest = tmp)
  expect_true(file.exists(paste0(tmp, ".rds")))
  expect_false(file.exists(tmp))
})

test_that("download_gene_ref does not double .rds extension", {
  tmp <- withr::local_tempfile(fileext = ".rds")

  local_mocked_bindings(
    useMart             = function(...) list(),
    listEnsemblArchives = function(...) data.frame(version = "110",
                                                   current_release = "*",
                                                   stringsAsFactors = FALSE),
    getBM               = function(...) .fake_gene_ref(),
    .package = "biomaRt"
  )

  download_gene_ref(species = "human", dest = tmp)
  expect_true(file.exists(tmp))
  expect_false(file.exists(paste0(tmp, ".rds")))
})

test_that("download_gene_ref returns data.frame with expected columns", {
  local_mocked_bindings(
    useMart             = function(...) list(),
    listEnsemblArchives = function(...) data.frame(version = "110",
                                                   current_release = "*",
                                                   stringsAsFactors = FALSE),
    getBM               = function(...) .fake_gene_ref(),
    .package = "biomaRt"
  )

  out <- download_gene_ref(species = "human")
  expect_s3_class(out, "data.frame")
  expect_true(all(c("ensembl_id", "symbol", "entrez_id", "gene_type",
                    "chromosome", "start", "end", "strand", "description",
                    "species", "ensembl_version", "download_date") %in% names(out)))
  expect_equal(unique(out$species), "human")
  expect_s3_class(out$download_date, "Date")
  expect_gt(nrow(out), 0L)
})

test_that("download_gene_ref network: returns valid data.frame for human", {
  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("biomaRt")

  out <- download_gene_ref(species = "human")
  expect_s3_class(out, "data.frame")
  expect_gt(nrow(out), 0L)
  expect_equal(unique(out$species), "human")
})


# =============================================================================
# download_url()
# =============================================================================

test_that("download_url errors on invalid url", {
  dest <- withr::local_tempfile()
  expect_error(download_url(123,           dest = dest), class = "rlang_error")
  expect_error(download_url(c("a", "b"),   dest = dest), class = "rlang_error")
  expect_error(download_url("",            dest = dest), class = "rlang_error")
  expect_error(download_url(NA_character_, dest = dest), class = "rlang_error")
})

test_that("download_url errors on invalid dest", {
  expect_error(download_url("https://x.com", dest = 1),             class = "rlang_error")
  expect_error(download_url("https://x.com", dest = ""),            class = "rlang_error")
  expect_error(download_url("https://x.com", dest = NA_character_), class = "rlang_error")
})

test_that("download_url errors on invalid logical flags", {
  dest <- withr::local_tempfile()
  url  <- "https://x.com"
  expect_error(download_url(url, dest, overwrite = "yes"), class = "rlang_error")
  expect_error(download_url(url, dest, resume    = "yes"), class = "rlang_error")
})

test_that("download_url errors on invalid timeout / retries", {
  dest <- withr::local_tempfile()
  url  <- "https://x.com"
  expect_error(download_url(url, dest, timeout = 0),   class = "rlang_error")
  expect_error(download_url(url, dest, timeout = -1),  class = "rlang_error")
  expect_error(download_url(url, dest, retries = -1),  class = "rlang_error")
  expect_error(download_url(url, dest, retries = 1.5), class = "rlang_error")
})

test_that("download_url skips and returns path invisibly when file exists and overwrite = FALSE", {
  dest <- withr::local_tempfile()
  writeLines("original", dest)

  out <- withVisible(
    suppressMessages(download_url("https://x.com", dest = dest, overwrite = FALSE))
  )
  expect_false(out$visible)
  expect_equal(out$value, dest)
  expect_equal(readLines(dest), "original")
})

test_that("download_url does not skip when overwrite = TRUE", {
  dest <- withr::local_tempfile()
  writeLines("old", dest)

  local_mocked_bindings(
    curl_download = function(url, destfile, ...) {
      writeLines("new", destfile); invisible(destfile)
    },
    new_handle   = function(...) list(),
    handle_setopt = function(h, ...) invisible(h),
    .package = "curl"
  )

  download_url("https://x.com/f.txt", dest = dest, overwrite = TRUE, resume = FALSE)
  expect_equal(readLines(dest), "new")
})

test_that("download_url does not leave dest file when non-resume download fails", {
  dest <- withr::local_tempfile()

  local_mocked_bindings(
    curl_download = function(url, destfile, ...) {
      writeLines("partial", destfile)
      stop("simulated download failure")
    },
    new_handle    = function(...) list(),
    handle_setopt = function(h, ...) invisible(h),
    .package = "curl"
  )

  expect_error(
    download_url("https://x.com/f.txt", dest = dest, retries = 0),
    class = "rlang_error"
  )
  expect_false(file.exists(dest))
})

test_that("download_url sets resume_from when overwrite = TRUE and resume = TRUE", {
  dest <- withr::local_tempfile()
  writeLines("partial", dest)

  resume_from_called <- FALSE
  local_mocked_bindings(
    new_handle    = function(...) list(),
    handle_setopt = function(h, ...) {
      if ("resume_from" %in% ...names()) resume_from_called <<- TRUE
      invisible(h)
    },
    curl_download = function(url, destfile, ...) {
      writeLines("done", destfile); invisible(destfile)
    },
    .package = "curl"
  )

  download_url("https://x.com/f.txt", dest = dest, overwrite = TRUE, resume = TRUE)
  expect_true(resume_from_called)
})

test_that("download_url network: downloads a small file successfully", {
  skip_on_cran()
  skip_on_ci()

  dest <- withr::local_tempfile(fileext = ".txt")
  out  <- download_url("https://httpbin.org/robots.txt", dest = dest,
                       timeout = 30, retries = 1)
  expect_equal(out, dest)
  expect_gt(file.info(dest)$size, 0L)
})

test_that("download_url network: errors after exhausting retries on bad URL", {
  skip_on_cran()
  skip_on_ci()

  dest <- withr::local_tempfile()
  expect_error(
    download_url("https://httpbin.org/status/404", dest = dest,
                 retries = 0, timeout = 10),
    class = "rlang_error"
  )
})


# =============================================================================
# download_batch()
# =============================================================================

test_that("download_batch errors on invalid urls", {
  tmp <- withr::local_tempdir()
  expect_error(download_batch(123,       dest_dir = tmp), class = "rlang_error")
  expect_error(download_batch(list("a"), dest_dir = tmp), class = "rlang_error")
  expect_error(download_batch(c("https://x.com/a.txt", ""), dest_dir = tmp), class = "rlang_error")
})

test_that("download_batch errors on invalid dest_dir", {
  expect_error(download_batch(c("https://x.com"), dest_dir = 1),  class = "rlang_error")
  expect_error(download_batch(c("https://x.com"), dest_dir = ""), class = "rlang_error")
})

test_that("download_batch errors on invalid logical flags", {
  tmp <- withr::local_tempdir()
  expect_error(download_batch("https://x.com", tmp, overwrite = "yes"), class = "rlang_error")
  expect_error(download_batch("https://x.com", tmp, resume    = 1L),    class = "rlang_error")
})

test_that("download_batch errors on duplicate destination filenames", {
  tmp  <- withr::local_tempdir()
  urls <- c("https://host.com/data.csv?v=1", "https://other.com/data.csv?v=2")
  expect_error(
    download_batch(urls, dest_dir = tmp),
    regexp   = "duplicate",
    ignore.case = TRUE,
    class = "rlang_error"
  )
})

test_that("download_batch creates dest_dir when it does not exist", {
  tmp    <- withr::local_tempdir()
  newdir <- file.path(tmp, "new_subdir")
  urls   <- "https://host.com/file.txt"

  local_mocked_bindings(
    multi_download = function(urls, destfile, ...) {
      data.frame(success = TRUE, status_code = 200L, error = NA_character_,
                 url = urls, destfile = destfile, stringsAsFactors = FALSE)
    },
    .package = "curl"
  )

  download_batch(urls, dest_dir = newdir)
  expect_true(dir.exists(newdir))
})

test_that("download_batch skips all existing files when overwrite = FALSE", {
  tmp   <- withr::local_tempdir()
  fname <- "existing.txt"
  writeLines("keep", file.path(tmp, fname))

  # No mock needed — function returns early before any curl call
  suppressMessages(download_batch(paste0("https://host.com/", fname),
                                  dest_dir = tmp, overwrite = FALSE))
  expect_equal(readLines(file.path(tmp, fname)), "keep")
})

test_that("download_batch detects partial HTTP 4xx failures", {
  tmp  <- withr::local_tempdir()
  urls <- c("https://host.com/good.txt", "https://host.com/bad.txt")

  local_mocked_bindings(
    multi_download = function(urls, destfile, ...) {
      data.frame(success = c(TRUE, TRUE), status_code = c(200L, 404L),
                 error = c(NA, NA), url = urls, destfile = destfile,
                 stringsAsFactors = FALSE)
    },
    .package = "curl"
  )

  expect_error(
    download_batch(urls, dest_dir = tmp, retries = 0),
    regexp = "failed",
    class  = "rlang_error"
  )
})

test_that("download_batch detects curl-level errors", {
  tmp  <- withr::local_tempdir()
  urls <- "https://host.com/file.txt"

  local_mocked_bindings(
    multi_download = function(urls, destfile, ...) {
      data.frame(success = FALSE, status_code = NA_integer_,
                 error = "Could not resolve host",
                 url = urls, destfile = destfile, stringsAsFactors = FALSE)
    },
    .package = "curl"
  )

  expect_error(
    download_batch(urls, dest_dir = tmp, retries = 0),
    regexp = "failed",
    class  = "rlang_error"
  )
})

test_that("download_batch retries only failed files and succeeds on second attempt", {
  tmp   <- withr::local_tempdir()
  urls  <- c("https://host.com/good.txt", "https://host.com/bad.txt")
  dests <- file.path(tmp, c("good.txt", "bad.txt"))
  calls <- 0L

  local_mocked_bindings(
    multi_download = function(urls, destfile, ...) {
      calls <<- calls + 1L
      if (calls == 1L) {
        # First attempt: good.txt OK, bad.txt 404
        data.frame(success = c(TRUE, TRUE), status_code = c(200L, 404L),
                   error = c(NA, NA), url = urls, destfile = destfile,
                   stringsAsFactors = FALSE)
      } else {
        # Second attempt: only bad.txt retried, now succeeds
        data.frame(success = TRUE, status_code = 200L, error = NA,
                   url = urls, destfile = destfile,
                   stringsAsFactors = FALSE)
      }
    },
    .package = "curl"
  )

  out <- download_batch(urls, dest_dir = tmp, retries = 1)
  expect_equal(calls, 2L)          # exactly two rounds
  expect_length(out, 2L)
})

test_that("download_batch network: downloads multiple files successfully", {
  skip_on_cran()
  skip_on_ci()

  tmp  <- withr::local_tempdir()
  urls <- c("https://httpbin.org/robots.txt", "https://httpbin.org/encoding/utf8")
  out  <- download_batch(urls, dest_dir = tmp, retries = 1, timeout = 30)
  expect_length(out, 2L)
  expect_true(all(file.exists(out)))
})


# =============================================================================
# download_geo()
# =============================================================================

test_that("download_geo errors on invalid gse_id format", {
  tmp <- withr::local_tempdir()
  expect_error(download_geo("GSE",      dest_dir = tmp),
               regexp = "GEO accession", class = "rlang_error")
  expect_error(download_geo("gse12345", dest_dir = tmp),
               regexp = "GEO accession", class = "rlang_error")
  expect_error(download_geo("GSEXYZ",   dest_dir = tmp),
               regexp = "GEO accession", class = "rlang_error")
  expect_error(download_geo(123,        dest_dir = tmp), class = "rlang_error")
})

test_that("download_geo errors on invalid dest_dir", {
  expect_error(download_geo("GSE12345", dest_dir = 1),  class = "rlang_error")
  expect_error(download_geo("GSE12345", dest_dir = ""), class = "rlang_error")
})

test_that("download_geo errors on invalid retries / timeout", {
  tmp <- withr::local_tempdir()
  expect_error(download_geo("GSE12345", tmp, retries = -1), class = "rlang_error")
  expect_error(download_geo("GSE12345", tmp, timeout = 0),  class = "rlang_error")
})

test_that("download_geo errors with informative message when GEOquery is absent", {
  tmp <- withr::local_tempdir()
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) FALSE,
    .package = "base"
  )
  expect_error(download_geo("GSE12345", dest_dir = tmp),
               regexp = "GEOquery", class = "rlang_error")
})

test_that("download_geo orchestrates helpers and returns correct list structure", {
  skip_if_not_installed("GEOquery")
  tmp      <- withr::local_tempdir()
  fake_eset <- structure(list(annotation = "GPL1234"), class = "ExpressionSet")

  local_mocked_bindings(
    .download_geo_gsematrix  = function(...) fake_eset,
    .download_geo_supp_files = function(...) character(0),
    .download_geo_platform   = function(...) list(platform_id = "GPL1234",
                                                  gpl_files   = character(0)),
    .package = "evanverse"
  )

  out <- suppressWarnings(download_geo("GSE99999", dest_dir = tmp))
  expect_named(out, c("gse_object", "supplemental_files", "platform_info"))
  expect_identical(out$gse_object, fake_eset)
  expect_type(out$supplemental_files, "character")
  expect_named(out$platform_info, c("platform_id", "gpl_files"))
})

test_that(".geo_retry warning contains last error message on all-fail", {
  tmp <- withr::local_tempdir()
  skip_if_not_installed("GEOquery")

  local_mocked_bindings(
    getGEO = function(...) stop("simulated_network_error"),
    .package = "GEOquery"
  )

  expect_warning(
    tryCatch(
      download_geo("GSE99999", dest_dir = tmp, retries = 0, timeout = 1),
      error = function(e) NULL
    ),
    regexp = "simulated_network_error"
  )
})

test_that("download_geo network: returns list with expected structure", {
  skip_on_cran()
  skip_on_ci()
  skip_if_not_installed("GEOquery")

  # retries = 0 / timeout = 30: fail fast; supplemental files may be absent or
  # large — structure assertions hold regardless because supp failures return character(0)
  tmp <- withr::local_tempdir()
  out <- suppressWarnings(download_geo("GSE121212", dest_dir = tmp, retries = 0, timeout = 30))
  expect_named(out, c("gse_object", "supplemental_files", "platform_info"))
  expect_type(out$supplemental_files, "character")
  expect_named(out$platform_info, c("platform_id", "gpl_files"))
})
