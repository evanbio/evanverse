#===============================================================================
# Test: pkg.R public functions
# File: test-pkg.R
# Description: Unit tests for set_mirror(), inst_pkg(), check_pkg(),
#              update_pkg(), pkg_version(), pkg_functions()
#===============================================================================

#==============================================================================
# set_mirror()
#==============================================================================

test_that("set_mirror() sets CRAN mirror correctly", {
  old <- options(repos = c(CRAN = "https://cloud.r-project.org"))
  on.exit(options(old), add = TRUE)

  set_mirror("cran", "tuna")
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.tuna.tsinghua.edu.cn/CRAN")

  set_mirror("cran", "ustc")
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.ustc.edu.cn/CRAN")

  set_mirror("cran", "westlake")
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.westlake.edu.cn/CRAN")
})

test_that("set_mirror() sets Bioconductor mirror correctly", {
  old <- options(BioC_mirror = "https://bioconductor.org")
  on.exit(options(old), add = TRUE)

  set_mirror("bioc", "tuna")
  expect_equal(getOption("BioC_mirror"),
               "https://mirrors.tuna.tsinghua.edu.cn/bioconductor")

  set_mirror("bioc", "ustc")
  expect_equal(getOption("BioC_mirror"),
               "https://mirrors.ustc.edu.cn/bioconductor")
})

test_that("set_mirror() sets both mirrors with repo = 'all'", {
  old <- options(repos = c(CRAN = "https://cloud.r-project.org"),
                 BioC_mirror = "https://bioconductor.org")
  on.exit(options(old), add = TRUE)

  set_mirror("all", "tuna")
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.tuna.tsinghua.edu.cn/CRAN")
  expect_equal(getOption("BioC_mirror"),
               "https://mirrors.tuna.tsinghua.edu.cn/bioconductor")
})

test_that("set_mirror() defaults to repo = 'all' and mirror = 'tuna'", {
  old <- options(repos = c(CRAN = "https://cloud.r-project.org"),
                 BioC_mirror = "https://bioconductor.org")
  on.exit(options(old), add = TRUE)

  set_mirror()
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.tuna.tsinghua.edu.cn/CRAN")
  expect_equal(getOption("BioC_mirror"),
               "https://mirrors.tuna.tsinghua.edu.cn/bioconductor")
})

test_that("set_mirror() returns previous settings invisibly", {
  old <- options(repos = c(CRAN = "https://cloud.r-project.org"),
                 BioC_mirror = "https://bioconductor.org")
  on.exit(options(old), add = TRUE)

  prev <- set_mirror("all", "tuna")
  expect_type(prev, "list")
  expect_named(prev, c("repos", "BioC_mirror"))
  expect_equal(prev$repos[["CRAN"]], "https://cloud.r-project.org")
  expect_equal(prev$BioC_mirror, "https://bioconductor.org")
})

test_that("set_mirror() official mirrors set correct URLs", {
  old <- options(repos = c(CRAN = "https://cloud.r-project.org"),
                 BioC_mirror = "https://bioconductor.org")
  on.exit(options(old), add = TRUE)

  set_mirror("cran", "official")
  expect_equal(getOption("repos")[["CRAN"]], "https://cloud.r-project.org")

  set_mirror("bioc", "official")
  expect_equal(getOption("BioC_mirror"), "https://bioconductor.org")
})

test_that("set_mirror() emits CLI messages", {
  old <- options(repos = c(CRAN = "https://cloud.r-project.org"),
                 BioC_mirror = "https://bioconductor.org")
  on.exit(options(old), add = TRUE)

  expect_message(set_mirror("cran", "tuna"), "CRAN mirror set to")
  expect_message(set_mirror("bioc", "ustc"), "Bioconductor mirror set to")
})

test_that("set_mirror() errors on invalid repo", {
  expect_error(set_mirror("invalid", "tuna"), "should be one of")
})

test_that("set_mirror() errors on unknown CRAN mirror", {
  expect_error(set_mirror("cran", "nonexistent"), "Unknown CRAN mirror")
})

test_that("set_mirror() errors on unknown Bioconductor mirror", {
  expect_error(set_mirror("bioc", "nonexistent"), "Unknown Bioconductor mirror")
})

test_that("set_mirror() errors when CRAN-only mirror used for bioc", {
  expect_error(set_mirror("bioc", "rstudio"), "Unknown Bioconductor mirror")
})

test_that("set_mirror() errors when CRAN-only mirror used for all", {
  expect_error(set_mirror("all", "rstudio"), "CRAN-only")
  expect_error(set_mirror("all", "aliyun"), "CRAN-only")
})

test_that("set_mirror() errors on completely unknown mirror with all", {
  expect_error(set_mirror("all", "nonexistent"), "Unknown mirror")
})

test_that("set_mirror() preserves non-CRAN repo entries when setting CRAN mirror", {
  old <- options(repos = c(CRAN = "https://cloud.r-project.org",
                           RSPM = "https://packagemanager.posit.co/cran/latest"))
  on.exit(options(old), add = TRUE)

  set_mirror("cran", "tuna")
  repos <- getOption("repos")
  expect_equal(repos[["CRAN"]], "https://mirrors.tuna.tsinghua.edu.cn/CRAN")
  expect_equal(repos[["RSPM"]], "https://packagemanager.posit.co/cran/latest")
})

#==============================================================================
# inst_pkg()
#==============================================================================

test_that("inst_pkg() errors on invalid source", {
  expect_error(inst_pkg(pkg = "dplyr", source = "invalid"), "should be one of")
  expect_error(inst_pkg(pkg = "dplyr", source = "cran"),    "should be one of")
})

test_that("inst_pkg() errors when pkg is invalid for CRAN/Bioc", {
  expect_error(inst_pkg(pkg = NULL,         source = "CRAN"), "non-empty character vector")
  expect_error(inst_pkg(pkg = 123,          source = "CRAN"), "non-empty character vector")
  expect_error(inst_pkg(pkg = character(0), source = "CRAN"), "non-empty character vector")
  expect_error(inst_pkg(pkg = c("a", NA),   source = "CRAN"), "non-empty character vector")
})

test_that("inst_pkg() errors when path is missing for Local source", {
  expect_error(inst_pkg(source = "Local"), "path")
})

test_that("inst_pkg() errors on invalid GitHub user/repo format", {
  expect_error(inst_pkg(pkg = "invalidformat",            source = "GitHub"), "user/repo")
  expect_error(inst_pkg(pkg = c("user/repo", "invalid"), source = "GitHub"), "user/repo")
  # Full URLs are rejected (multiple slashes)
  expect_error(inst_pkg(pkg = "https://github.com/user/repo", source = "GitHub"), "user/repo")
})

test_that("inst_pkg() and update_pkg() accept extended GitHub ref formats", {
  local_mocked_bindings(
    .install_from_github    = function(pkg, ...) invisible(NULL),
    .filter_installed_packages = function(pkg, source) pkg,
    .package = "evanverse"
  )
  # user/repo@ref and user/repo#pr are valid devtools formats
  expect_no_error(suppressMessages(inst_pkg("user/repo@main",   source = "GitHub")))
  expect_no_error(suppressMessages(inst_pkg("user/repo#123",    source = "GitHub")))
  expect_no_error(suppressMessages(update_pkg("user/repo@v1.0", source = "GitHub")))
})

#==============================================================================
# check_pkg()
#==============================================================================

test_that("check_pkg() returns a tibble with correct columns", {
  res <- check_pkg("stats", source = "CRAN")
  expect_s3_class(res, "tbl_df")
  expect_named(res, c("package", "name", "installed", "source"))
})

test_that("check_pkg() detects installed base packages", {
  res <- check_pkg("stats", source = "CRAN")
  expect_true(res$installed[[1]])
})

test_that("check_pkg() handles multiple packages", {
  res <- check_pkg(c("stats", "utils"), source = "CRAN")
  expect_equal(nrow(res), 2L)
  expect_true(all(res$installed))
})

test_that("check_pkg() extracts package name from GitHub user/repo format", {
  res <- check_pkg("r-lib/cli", source = "GitHub")
  expect_equal(res$name[[1]],    "cli")
  expect_equal(res$package[[1]], "r-lib/cli")
})

test_that("check_pkg() errors on invalid source", {
  expect_error(check_pkg("dplyr", source = "unknown"), "should be one of")
})

test_that("check_pkg() errors when pkg is missing", {
  expect_error(check_pkg(source = "CRAN"), "argument.*missing|pkg")
})

test_that("check_pkg() validates pkg argument", {
  expect_error(check_pkg(NULL,         source = "CRAN"), "non-empty character vector")
  expect_error(check_pkg(123,          source = "CRAN"), "non-empty character vector")
  expect_error(check_pkg(character(0), source = "CRAN"), "non-empty character vector")
})

test_that("check_pkg() validates auto_install argument", {
  expect_error(check_pkg("stats", source = "CRAN", auto_install = "yes"), "TRUE or FALSE")
  expect_error(check_pkg("stats", source = "CRAN", auto_install = NA),    "TRUE or FALSE")
})

test_that("check_pkg() auto_install=TRUE continues after partial install failure", {
  call_n <- 0L
  local_mocked_bindings(
    inst_pkg = function(pkg, ...) {
      call_n <<- call_n + 1L
      if (call_n == 1L) stop("Simulated install failure")
      invisible(NULL)
    },
    .package = "evanverse"
  )

  res <- suppressMessages(
    check_pkg(c("_fake_a_", "_fake_b_"), source = "CRAN", auto_install = TRUE)
  )

  expect_equal(nrow(res), 2L)
  expect_false(res$installed[[1]])  # first install failed — stays FALSE
  expect_true(res$installed[[2]])   # second install succeeded — set to TRUE
})

#==============================================================================
# update_pkg()
#==============================================================================

test_that("update_pkg() errors on invalid source", {
  expect_error(update_pkg(pkg = "dplyr", source = "unknown"),      "should be one of")
  expect_error(update_pkg(pkg = "dplyr", source = "cran"),         "should be one of")
  expect_error(update_pkg(pkg = "dplyr", source = "bioconductor"), "should be one of")
})

test_that("update_pkg() errors when pkg provided without explicit source", {
  expect_error(update_pkg(pkg = "dplyr"), "Must specify.*source")
})

test_that("update_pkg() errors when GitHub source has no pkg", {
  expect_error(update_pkg(source = "GitHub"), "Must provide.*pkg")
})

test_that("update_pkg() errors on invalid GitHub user/repo format", {
  expect_error(update_pkg(pkg = "invalid-format",            source = "GitHub"), "user/repo")
  expect_error(update_pkg(pkg = c("user/repo", "invalid"),  source = "GitHub"), "user/repo")
})

test_that("update_pkg() validates pkg argument type", {
  expect_error(update_pkg(pkg = 123,          source = "CRAN"), "non-empty character vector")
  expect_error(update_pkg(pkg = character(0), source = "CRAN"), "non-empty character vector")
  expect_error(update_pkg(pkg = c("a", NA),   source = "CRAN"), "non-empty character vector")
})

test_that("update_pkg() targeted Bioc update does not trigger full upgrade", {
  bioc_calls <- list()
  local_mocked_bindings(
    .install_from_bioc = function(pkg, ...) {
      bioc_calls[[length(bioc_calls) + 1L]] <<- pkg
      invisible(NULL)
    },
    .package = "evanverse"
  )

  suppressMessages(update_pkg("DESeq2", source = "Bioconductor"))

  # .install_from_bioc called exactly once with the specific package
  expect_length(bioc_calls, 1L)
  expect_equal(bioc_calls[[1L]], "DESeq2")
})

#==============================================================================
# pkg_version()
#==============================================================================

test_that("pkg_version() validates pkg argument", {
  expect_error(pkg_version(NULL),         "non-empty character vector")
  expect_error(pkg_version(character(0)), "non-empty character vector")
  expect_error(pkg_version(123),          "non-empty character vector")
  expect_error(pkg_version(c("a", NA)),   "non-empty character vector")
})

test_that("pkg_version() deduplicates pkg input", {
  local_mocked_bindings(
    .cran_latest_versions = function() stats::setNames(character(0), character(0)),
    .bioc_latest_versions = function() stats::setNames(character(0), character(0)),
    .package = "evanverse"
  )
  res <- pkg_version(c("cli", "cli"))
  expect_equal(nrow(res), 1L)
})

test_that("pkg_version() returns correct structure and source classification (offline)", {
  local_mocked_bindings(
    .cran_latest_versions = function() c(cli = "3.6.0"),
    .bioc_latest_versions = function() c(deseq2 = "1.40.0"),
    .package = "evanverse"
  )

  res <- pkg_version(c("cli", "DESeq2", "nonexistentpackage123456"))
  expect_s3_class(res, "data.frame")
  expect_named(res, c("package", "version", "latest", "source"))
  expect_equal(nrow(res), 3L)
  expect_equal(res$source[res$package == "cli"],    "CRAN")
  expect_equal(res$latest[res$package == "cli"],    "3.6.0")
  expect_equal(res$source[res$package == "DESeq2"], "Bioconductor")
  expect_equal(res$source[res$package == "nonexistentpackage123456"], "Not Found")
})

test_that("pkg_version() handles mixed-case package names consistently", {
  local_mocked_bindings(
    .cran_latest_versions = function() c(cli = "3.6.0"),
    .bioc_latest_versions = function() stats::setNames(character(0), character(0)),
    .package = "evanverse"
  )

  lower <- pkg_version("cli")
  upper <- pkg_version("CLI")
  expect_equal(lower$source[[1]], upper$source[[1]])
  expect_equal(lower$latest[[1]], upper$latest[[1]])
})

test_that("pkg_version() handles incomplete GitHub DESCRIPTION fields gracefully", {
  tmp_lib <- tempfile("fakelib")
  dir.create(file.path(tmp_lib, "mypkg"), recursive = TRUE)
  writeLines(
    c("Package: mypkg", "Version: 1.0.0", "RemoteType: github"),
    file.path(tmp_lib, "mypkg", "DESCRIPTION")
  )
  on.exit(unlink(tmp_lib, recursive = TRUE), add = TRUE)

  local_mocked_bindings(
    .cran_latest_versions  = function() stats::setNames(character(0), character(0)),
    .bioc_latest_versions  = function() stats::setNames(character(0), character(0)),
    .installed_pkg_info    = function(pkg) {
      list(mypkg = list(Version = "1.0.0", LibPath = tmp_lib, Package = "mypkg"))
    },
    .package = "evanverse"
  )

  # Should not error even though RemoteSha/RemoteUsername/RemoteRepo/RemoteRef are absent
  res <- expect_no_error(pkg_version("mypkg"))
  expect_equal(res$version[[1]], "1.0.0")
  expect_equal(res$source[[1]],  "Not Found")
})

test_that("pkg_version() returns data.frame with correct columns (online)", {
  skip_on_cran()
  skip_if_offline()
  old <- options(BioC_mirror = "https://bioconductor.org")
  on.exit(options(old), add = TRUE)

  res <- pkg_version("cli")
  expect_s3_class(res, "data.frame")
  expect_named(res, c("package", "version", "latest", "source"))
})

test_that("pkg_version() detects installed version and CRAN source (online)", {
  skip_on_cran()
  skip_if_offline()
  old <- options(BioC_mirror = "https://bioconductor.org")
  on.exit(options(old), add = TRUE)

  res <- pkg_version("cli")
  expect_false(is.na(res$version[[1]]))
  expect_equal(res$source[[1]], "CRAN")
  expect_false(is.na(res$latest[[1]]))
})

test_that("pkg_version() returns 'Not Found' for unknown package (online)", {
  skip_on_cran()
  skip_if_offline()
  old <- options(BioC_mirror = "https://bioconductor.org")
  on.exit(options(old), add = TRUE)

  res <- pkg_version("nonexistentpackage123456")
  expect_true(is.na(res$version[[1]]))
  expect_equal(res$source[[1]], "Not Found")
})

#==============================================================================
# pkg_functions()
#==============================================================================

test_that("pkg_functions() returns sorted character vector of exports", {
  funcs <- pkg_functions("stats")
  expect_type(funcs, "character")
  expect_true(length(funcs) > 0L)
  expect_equal(funcs, sort(funcs))
  expect_true("lm" %in% funcs)
  expect_visible(funcs)
})

test_that("pkg_functions() filters by keyword case-insensitively", {
  lower <- pkg_functions("stats", key = "lm")
  upper <- pkg_functions("stats", key = "LM")

  expect_true(all(grepl("lm", lower, ignore.case = TRUE)))
  expect_true(length(lower) > 0L)
  expect_equal(lower, upper)
})

test_that("pkg_functions() returns empty vector when keyword has no match", {
  funcs <- pkg_functions("stats", key = "zzzzzz")
  expect_type(funcs, "character")
  expect_length(funcs, 0L)
})

test_that("pkg_functions() errors for uninstalled package", {
  expect_error(pkg_functions("somefakepkg_notinstalled"), "not installed")
})

test_that("pkg_functions() validates pkg argument", {
  expect_error(pkg_functions(123),           "single non-empty string")
  expect_error(pkg_functions(""),            "single non-empty string")
  expect_error(pkg_functions(NA_character_), "single non-empty string")
  expect_error(pkg_functions(c("a", "b")),   "single non-empty string")
})

test_that("pkg_functions() validates key argument", {
  expect_error(pkg_functions("stats", key = c("a", "b")),    "single non-empty string")
  expect_error(pkg_functions("stats", key = NA_character_),  "single non-empty string")
  expect_error(pkg_functions("stats", key = ""),             "single non-empty string")
})

