#==============================================================================
# Test: combine_logic()
# File: test-combine_logic.R
# Description: Unit tests for combine_logic() function
#==============================================================================

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
test_that("combine_logic works for simple logical vectors", {
  x <- c(TRUE, FALSE, TRUE)
  y <- c(TRUE, TRUE, FALSE)

  expect_equal(combine_logic(x, y), c(TRUE, FALSE, FALSE))
  expect_equal(combine_logic(x, y, op = "|"), c(TRUE, TRUE, TRUE))
})

test_that("combine_logic works with more than two conditions", {
  a <- c(TRUE, FALSE, TRUE)
  b <- c(TRUE, TRUE, FALSE)
  c <- c(TRUE, FALSE, FALSE)

  expect_equal(combine_logic(a, b, c), c(TRUE, FALSE, FALSE))
  expect_equal(combine_logic(a, b, c, op = "|"), c(TRUE, TRUE, TRUE))
})

# ------------------------------------------------------------------------------
# NA handling tests
# ------------------------------------------------------------------------------
test_that("combine_logic returns NA if any NA present (na.rm = FALSE)", {
  x <- c(TRUE, NA, FALSE)
  y <- c(TRUE, TRUE, FALSE)

  expect_equal(combine_logic(x, y), c(TRUE, NA, FALSE))
})

test_that("combine_logic removes NA if na.rm = TRUE", {
  x <- c(TRUE, NA, FALSE)
  y <- c(TRUE, TRUE, FALSE)

  expect_equal(combine_logic(x, y, na.rm = TRUE), c(TRUE, TRUE, FALSE))
})

# ------------------------------------------------------------------------------
# Error handling tests
# ------------------------------------------------------------------------------
test_that("combine_logic fails for length mismatch", {
  expect_error(combine_logic(c(TRUE, FALSE), c(TRUE, TRUE, FALSE)),
               "All logical vectors must be the same length.")
})

test_that("combine_logic fails for invalid operator", {
  expect_error(combine_logic(c(TRUE, FALSE), op = "&&&"),
               "'arg' should be one of")
})

test_that("combine_logic fails for non-logical input", {
  expect_error(combine_logic(c(1, 2), c(3, 4)),
               "All inputs must be logical vectors.")
})

