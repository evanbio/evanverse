#===============================================================================
# Test: pkg_functions()
# File: tests/testthat/test-pkg_functions.R
# Description: Unit tests for listing exported names from a package
# Dependencies: testthat
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------
test_that("pkg_functions() returns exported names from a package", {
  funcs <- pkg_functions("stats")
  expect_true(is.character(funcs))
  expect_true(length(funcs) > 0)
  expect_true("lm" %in% funcs)  # stats::lm is exported
})

#------------------------------------------------------------------------------
# Sorting
#------------------------------------------------------------------------------
test_that("returned names are sorted alphabetically", {
  funcs <- pkg_functions("stats")
  expect_equal(funcs, sort(funcs))
})

#------------------------------------------------------------------------------
# Keyword filtering (case-insensitive, partial)
#------------------------------------------------------------------------------
test_that("pkg_functions() filters by keyword", {
  funcs <- pkg_functions("stats", key = "lm")
  expect_true(all(grepl("lm", funcs, ignore.case = TRUE)))
})

test_that("pkg_functions() filtering is case-insensitive", {
  funcs <- pkg_functions("stats", key = "LM")
  expect_true(all(grepl("lm", funcs, ignore.case = TRUE)))
})

#------------------------------------------------------------------------------
# No matches
#------------------------------------------------------------------------------
test_that("pkg_functions() returns empty vector when no match", {
  funcs <- pkg_functions("stats", key = "zzzzzz")
  expect_type(funcs, "character")
  expect_equal(length(funcs), 0L)
})

#------------------------------------------------------------------------------
# Error handling
#------------------------------------------------------------------------------
test_that("pkg_functions() errors for non-installed package", {
  expect_error(pkg_functions("somefakepkgnotinstalled"), regexp = "not installed")
})

test_that("pkg_functions() errors for non-character `pkg`", {
  expect_error(pkg_functions(123))
  expect_error(pkg_functions(TRUE))
  expect_error(pkg_functions(NA_character_), regexp = "non-empty")
})

test_that("pkg_functions() errors for invalid `key` input", {
  expect_error(pkg_functions("stats", key = c("a", "b")))
  expect_error(pkg_functions("stats", key = NA_character_))
})
