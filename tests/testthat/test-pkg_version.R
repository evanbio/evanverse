#===============================================================================
# Test: pkg_version()
# File: test-pkg_version.R
# Description: Unit tests for the pkg_version() function
# Notes:
#   - Only input/structure validation runs on CRAN.
#   - Any tests that require network or GitHub access are skipped with skip_on_cran().
#===============================================================================

test_that("pkg_version() validates input parameters", {
  expect_error(pkg_version(NULL), "`pkg` must be a non-empty character vector")
  expect_error(pkg_version(character(0)), "`pkg` must be a non-empty character vector")
  expect_error(pkg_version(123), "`pkg` must be a non-empty character vector")
  expect_error(pkg_version("cli", preview = "yes"), "`preview` must be a single logical value")
  expect_error(pkg_version("cli", preview = c(TRUE, FALSE)), "`preview` must be a single logical value")
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
