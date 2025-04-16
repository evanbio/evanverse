# tests/testthat/test-check_pkg.R

test_that("check_pkg() detects installed packages", {
  res <- check_pkg("stats", source = "CRAN", auto_install = FALSE)
  expect_true(res$installed)
})

test_that("check_pkg() handles GitHub input format", {
  res <- check_pkg("r-lib/cli", source = "GitHub", auto_install = FALSE)
  expect_true(res$name == "cli")
})

test_that("check_pkg() errors on invalid source", {
  expect_error(check_pkg("dplyr", source = "unknown"), "Invalid source")
})

test_that("check_pkg() returns a tibble", {
  res <- check_pkg("ggplot2", source = "CRAN", auto_install = FALSE)
  expect_s3_class(res, "tbl_df")
})
