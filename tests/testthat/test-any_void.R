#===============================================================================
# Test: any_void()
# File: test-any_void.R
# Description: Unit tests for any_void() utility function
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------

test_that("any_void() detects NA and empty strings", {
  x <- c("A", "", NA)
  expect_true(any_void(x))
})

test_that("any_void() returns FALSE for all valid values", {
  x <- c("apple", "banana", "cherry")
  expect_false(any_void(x))
})

#------------------------------------------------------------------------------
# Parameter variations
#------------------------------------------------------------------------------

test_that("any_void() respects include_na = FALSE", {
  x <- c("A", "", NA)
  expect_true(any_void(x, include_na = FALSE))     # only "" triggers TRUE
  expect_false(any_void(x, include_na = FALSE, include_empty_str = FALSE))  # nothing void
})

test_that("any_void() respects include_empty_str = FALSE", {
  x <- c("", "X")
  expect_false(any_void(x, include_empty_str = FALSE))
})

test_that("any_void() handles NULL correctly", {
  expect_true(any_void(NULL))                        # default = TRUE
  expect_false(any_void(NULL, include_null = FALSE)) # turn off
})

#------------------------------------------------------------------------------
# List input support
#------------------------------------------------------------------------------

test_that("any_void() works on list input", {
  x <- list("X", "", NULL, NA)
  expect_true(any_void(x))
  expect_false(any_void(x, include_na = FALSE, include_empty_str = FALSE, include_null = FALSE))
})

test_that("any_void() handles nested lists", {
  x <- list("a", list(NULL, "b"))
  expect_true(any_void(x))
})

#------------------------------------------------------------------------------
# Edge cases
#------------------------------------------------------------------------------

test_that("any_void() on empty vector returns FALSE", {
  expect_false(any_void(character(0)))
})

test_that("any_void() handles numeric input with NA", {
  x <- c(1, 2, NA)
  expect_true(any_void(x))
  expect_false(any_void(x, include_na = FALSE))
})

test_that("any_void() handles all NA input", {
  x <- c(NA, NA)
  expect_true(any_void(x))
  expect_false(any_void(x, include_na = FALSE))
})
