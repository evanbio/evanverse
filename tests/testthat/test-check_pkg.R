#==============================================================================
# Test: check_pkg()
# File: test-check_pkg.R
# Description: Unit tests for check_pkg() function
#==============================================================================

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
test_that("check_pkg() detects installed packages", {
  res <- check_pkg("stats", source = "CRAN", auto_install = FALSE)
  expect_true(res$installed)
})

test_that("check_pkg() handles GitHub input format", {
  res <- check_pkg("r-lib/cli", source = "GitHub", auto_install = FALSE)
  expect_true(res$name == "cli")
})

# ------------------------------------------------------------------------------
# Error handling tests
# ------------------------------------------------------------------------------
test_that("check_pkg() errors on invalid source", {
  expect_error(check_pkg("dplyr", source = "unknown"))
})

# ------------------------------------------------------------------------------
# Output structure tests
# ------------------------------------------------------------------------------
test_that("check_pkg() returns a tibble", {
  res <- check_pkg("ggplot2", source = "CRAN", auto_install = FALSE)
  expect_s3_class(res, "tbl_df")
})

# ------------------------------------------------------------------------------
# Multiple packages test
# ------------------------------------------------------------------------------
test_that("check_pkg() handles multiple packages", {
  res <- check_pkg(c("stats", "utils"), source = "CRAN", auto_install = FALSE)
  expect_equal(nrow(res), 2)
  expect_true(all(res$installed))
})

# ------------------------------------------------------------------------------
# Bioconductor source test (if available)
# ------------------------------------------------------------------------------
test_that("check_pkg() handles Bioconductor source", {
  skip_on_cran()  # Skip on CRAN to avoid Bioconductor dependencies
  # This test assumes Bioconductor is set up; adjust as needed
  res <- check_pkg("Biobase", source = "Bioconductor", auto_install = FALSE)
  expect_s3_class(res, "tbl_df")
})

