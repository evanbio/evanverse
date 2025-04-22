#===============================================================================
# 🧪 Test: pkg_version()
# 📁 File: test-pkg_version.R
# 🔍 Description: Unit tests for the pkg_version() function
#===============================================================================

test_that("pkg_version() returns correct structure", {
  pkgs <- c("cli", "ggplot2", "nonexistentpackage123456")
  res <- suppressMessages(pkg_version(pkgs, preview = FALSE))

  expect_s3_class(res, "data.frame")
  expect_named(res, c("package", "version", "latest", "source"))
  expect_equal(nrow(res), length(pkgs))
})

test_that("pkg_version() detects installed version", {
  res <- suppressMessages(pkg_version("cli", preview = FALSE))
  expect_true(!is.na(res$version[1]))
})

test_that("pkg_version() detects CRAN source", {
  res <- suppressMessages(pkg_version("ggplot2", preview = FALSE))
  expect_equal(res$source[1], "CRAN")
  expect_true(!is.na(res$latest[1]))
})

test_that("pkg_version() handles nonexistent packages", {
  res <- suppressMessages(pkg_version("nonexistentpackage123456", preview = FALSE))
  expect_true(is.na(res$version[1]))
  expect_true(is.na(res$latest[1]))
  expect_equal(res$source[1], "Not Found")
})

# Optional: add a GitHub test if a GitHub-installed package exists locally
test_that("pkg_version() detects GitHub package", {
  res <- suppressMessages(pkg_version("MRPRESSO", preview = FALSE))
  expect_true(grepl("^GitHub", res$source[1]))
})
