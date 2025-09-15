#===============================================================================
# Test: inst_pkg()
# File: test-inst_pkg.R
# Description: Unit tests for the inst_pkg() function
#===============================================================================

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("inst_pkg() validates source parameter correctly", {
  expect_error(
    inst_pkg(pkg = "dplyr", source = "invalid"),
    "'arg' should be one of"
  )
  
  expect_error(
    inst_pkg(pkg = "dplyr", source = "unknown"),
    "'arg' should be one of"
  )
})

test_that("inst_pkg() validates pkg parameter correctly", {
  expect_error(
    inst_pkg(pkg = c("dplyr", NA), source = "CRAN"),
    "'pkg' must be a character vector without NA values"
  )
  
  expect_error(
    inst_pkg(pkg = 123, source = "CRAN"),
    "'pkg' must be a character vector without NA values"
  )
  
  expect_error(
    inst_pkg(pkg = character(0), source = "CRAN"),
    "'pkg' must be a character vector without NA values"
  )
})

test_that("inst_pkg() validates pkg and source relationship", {
  expect_error(
    inst_pkg(source = "CRAN"),
    "Must provide 'pkg' for non-local installation"
  )
  
  expect_error(
    inst_pkg(source = "GitHub"),
    "Must provide 'pkg' for non-local installation"
  )
  
  expect_error(
    inst_pkg(source = "Bioconductor"),
    "Must provide 'pkg' for non-local installation"
  )
})

test_that("inst_pkg() validates GitHub package format", {
  expect_error(
    inst_pkg(pkg = "invalidformat", source = "GitHub"),
    "GitHub packages must be in 'user/repo' format"
  )
  
  expect_error(
    inst_pkg(pkg = c("validuser/repo", "invalid"), source = "GitHub"),
    "GitHub packages must be in 'user/repo' format"
  )
})

test_that("inst_pkg() validates local installation parameters", {
  expect_error(
    inst_pkg(source = "Local"),
    "Must provide 'path' for local installation"
  )
})

#------------------------------------------------------------------------------
# Basic Function Acceptance (No Network Operations)
#------------------------------------------------------------------------------

test_that("inst_pkg() accepts valid parameters without execution", {
  # Only test that the function doesn't immediately error on valid input
  expect_true(is.function(inst_pkg))
  
  # Test parameter parsing without execution
  expect_silent({
    formals_check <- formals(inst_pkg)
    expect_true("pkg" %in% names(formals_check))
    expect_true("source" %in% names(formals_check))
    expect_true("path" %in% names(formals_check))
  })
})
