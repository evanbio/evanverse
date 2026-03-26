#===============================================================================
# Test: package.R public functions
# File: test-package.R
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

test_that("set_mirror() errors when CRAN-only mirror used for bioc or all", {
  expect_error(set_mirror("bioc", "rstudio"), "Unknown Bioconductor mirror")
  expect_error(set_mirror("all",  "rstudio"), "Unknown Bioconductor mirror")
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
  expect_error(inst_pkg(pkg = "invalidformat",             source = "GitHub"), "user/repo")
  expect_error(inst_pkg(pkg = c("user/repo", "invalid"),  source = "GitHub"), "user/repo")
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

test_that("check_pkg() validates pkg argument", {
  expect_error(check_pkg(NULL,         source = "CRAN"), "non-empty character vector")
  expect_error(check_pkg(123,          source = "CRAN"), "non-empty character vector")
  expect_error(check_pkg(character(0), source = "CRAN"), "non-empty character vector")
})

test_that("check_pkg() validates auto_install argument", {
  expect_error(check_pkg("stats", source = "CRAN", auto_install = "yes"), "TRUE or FALSE")
  expect_error(check_pkg("stats", source = "CRAN", auto_install = NA),    "TRUE or FALSE")
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

#==============================================================================
# pkg_version()
#==============================================================================

test_that("pkg_version() validates pkg argument", {
  expect_error(pkg_version(NULL),         "non-empty character vector")
  expect_error(pkg_version(character(0)), "non-empty character vector")
  expect_error(pkg_version(123),          "non-empty character vector")
  expect_error(pkg_version(c("a", NA)),   "non-empty character vector")
})

test_that("pkg_version() returns data.frame with correct columns", {
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy CRAN package database fetch skipped.")

  res <- pkg_version("cli")
  expect_s3_class(res, "data.frame")
  expect_named(res, c("package", "version", "latest", "source"))
})

test_that("pkg_version() detects installed version and CRAN source", {
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy CRAN package database fetch skipped.")

  res <- pkg_version("cli")
  expect_false(is.na(res$version[[1]]))
  expect_equal(res$source[[1]], "CRAN")
  expect_false(is.na(res$latest[[1]]))
})

test_that("pkg_version() returns 'Not Found' for unknown package", {
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy CRAN package database fetch skipped.")

  res <- pkg_version("nonexistentpackage123456")
  expect_true(is.na(res$version[[1]]))
  expect_equal(res$source[[1]], "Not Found")
})

test_that("pkg_version() deduplicates pkg input", {
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy CRAN package database fetch skipped.")

  res <- pkg_version(c("cli", "cli"))
  expect_equal(nrow(res), 1L)
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

#===============================================================================
# End: test-package.R
#===============================================================================
