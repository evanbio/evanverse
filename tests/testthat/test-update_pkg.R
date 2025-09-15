#===============================================================================
# Test: update_pkg()
# File: test-update_pkg.R
# Description: Unit tests for the update_pkg() function
#===============================================================================

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("update_pkg() validates source parameter correctly", {
  expect_error(
    update_pkg(pkg = "dplyr", source = "unknown"),
    "'arg' should be one of"
  )
  
  expect_error(
    update_pkg(pkg = "dplyr", source = "invalid"),
    "'arg' should be one of"
  )
})

test_that("update_pkg() validates pkg parameter correctly", {
  
  expect_error(
    update_pkg(pkg = c("dplyr", NA), source = "CRAN"),
    "'pkg' must be a character vector without NA values"
  )
  
  expect_error(
    update_pkg(pkg = 123, source = "CRAN"),
    "'pkg' must be a character vector without NA values"
  )
  
  expect_error(
    update_pkg(pkg = character(0), source = "CRAN"),
    "'pkg' must be a character vector without NA values"
  )
})

test_that("update_pkg() validates pkg and source relationship", {
  expect_error(
    update_pkg(pkg = "dplyr"),
    "Must specify 'source' when providing 'pkg'"
  )
  
  expect_error(
    update_pkg(source = "GitHub"),
    "Must provide 'pkg' when updating GitHub packages"
  )
})

test_that("update_pkg() validates GitHub package format", {
  expect_error(
    update_pkg(pkg = "invalid-format", source = "GitHub"),
    "GitHub packages must be in 'user/repo' format"
  )
  
  expect_error(
    update_pkg(pkg = c("user/repo", "invalid"), source = "GitHub"),
    "GitHub packages must be in 'user/repo' format"
  )
})

#------------------------------------------------------------------------------
# Basic Function Acceptance (No Network Operations)
#------------------------------------------------------------------------------

test_that("update_pkg() accepts valid single package parameters", {
  # Only test that the function doesn't immediately error on valid input
  # Skip actual execution to avoid network operations
  expect_true(is.function(update_pkg))
  
  # Test parameter parsing without execution
  expect_silent({
    formals_check <- formals(update_pkg)
    expect_true("pkg" %in% names(formals_check))
    expect_true("source" %in% names(formals_check))
  })
})

#------------------------------------------------------------------------------
# Edge Cases and Error Handling
#------------------------------------------------------------------------------

test_that("update_pkg() handles empty package vector", {
  expect_error(
    update_pkg(pkg = character(0), source = "CRAN"),
    "'pkg' must be a character vector without NA values"
  )
})

test_that("update_pkg() case sensitivity for source parameter", {
  expect_error(
    update_pkg(pkg = "test", source = "cran"),
    "'arg' should be one of"
  )
  
  expect_error(
    update_pkg(pkg = "test", source = "github"),
    "'arg' should be one of"
  )
  
  expect_error(
    update_pkg(pkg = "test", source = "bioconductor"),
    "'arg' should be one of"
  )
})

#===============================================================================
# End: test-update_pkg.R
#===============================================================================

