#===============================================================================
# Test: pkg_version()
# File: test-pkg_version.R
# Description: Unit tests for the pkg_version() function
# Notes:
#   - Only input/structure validation runs on CRAN.
#   - Any tests that require network or GitHub access are skipped with skip_on_cran().
#===============================================================================

test_that("pkg_version() returns correct structure", {
  skip_on_cran()
  pkgs <- c("cli", "ggplot2", "nonexistentpackage123456")
  res <- suppressMessages(pkg_version(pkgs, preview = FALSE))

  expect_s3_class(res, "data.frame")
  expect_named(res, c("package", "version", "latest", "source"))
  expect_equal(nrow(res), length(pkgs))
})

test_that("pkg_version() detects installed version", {
  skip_on_cran()
  res <- suppressMessages(pkg_version("cli", preview = FALSE))
  expect_true(!is.na(res$version[1]))
})

test_that("pkg_version() detects CRAN source", {
  skip_on_cran()
  res <- suppressMessages(pkg_version("ggplot2", preview = FALSE))
  expect_equal(res$source[1], "CRAN")
  expect_true(!is.na(res$latest[1]))
})

test_that("pkg_version() handles nonexistent packages gracefully", {
  skip_on_cran()
  res <- suppressMessages(pkg_version("nonexistentpackage123456", preview = FALSE))
  expect_true(is.na(res$version[1]))
  expect_true(is.na(res$latest[1]))
  expect_equal(res$source[1], "Not Found")
})

# -------------------------------------------------------------------
# Optional GitHub-related test: skipped on CRAN
# -------------------------------------------------------------------
test_that("pkg_version() detects GitHub package (if installed locally)", {
  skip_on_cran()
  # This test only works if MRPRESSO (or another GitHub package) is installed.
  # It will pass silently if not installed.
  if ("MRPRESSO" %in% rownames(installed.packages())) {
    res <- suppressMessages(pkg_version("MRPRESSO", preview = FALSE))
    expect_true(grepl("^GitHub", res$source[1]))
  } else {
    succeed("GitHub package not installed locally; skipping test.")
  }
})
