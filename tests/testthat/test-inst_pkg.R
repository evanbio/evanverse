#===============================================================================
# Test: inst_pkg()
# File: test-inst_pkg.R
# Description: Unit tests for inst_pkg() unified installer
#===============================================================================

# ------------------------------------------------------------------------------
# Basic functionality: Skip if already installed
# ------------------------------------------------------------------------------

test_that("skips already installed CRAN package", {
  skip_on_cran()  # conservative on CRAN
  expect_invisible(inst_pkg("utils", source = "CRAN"))
})

# ------------------------------------------------------------------------------
# Source handling: case-insensitive and shorthand accepted
# ------------------------------------------------------------------------------

test_that("accepts valid sources and abbreviations", {
  skip_on_cran()
  # Should succeed because 'utils' is base R
  expect_invisible(inst_pkg("utils", source = "CRAN"))

  skip_if_not_installed("cli")
  expect_invisible(inst_pkg("r-lib/cli", source = "GitHub"))

  skip_if_not_installed("BiocGenerics")
  expect_invisible(inst_pkg("BiocGenerics", source = "Bioconductor"))
})

# ------------------------------------------------------------------------------
# Invalid source input
# ------------------------------------------------------------------------------

test_that("errors on invalid source input", {
  expect_error(inst_pkg("dplyr", source = "invalid"))
})

# ------------------------------------------------------------------------------
# Missing arguments
# ------------------------------------------------------------------------------

test_that("throws error when pkg is missing for non-local source", {
  expect_error(inst_pkg(source = "CRAN"), "provide a package name")
})

test_that("throws error when path is missing for local source", {
  expect_error(inst_pkg(source = "Local"))
})
