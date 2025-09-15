# tests/testthat/test-percent_p_operator.R
# Tests for `%p%` — String concatenation operator (with a space)

# ------------------------------------------------------------------------------
# Basic functionality
# ------------------------------------------------------------------------------
test_that("basic concatenation works", {
  expect_equal("Hello" %p% "world", "Hello world")
  expect_equal("Good" %p% "job", "Good job")
  expect_equal("a" %p% "b", "a b")
})

# ------------------------------------------------------------------------------
# Handles empty string inputs
# ------------------------------------------------------------------------------
test_that("handles empty string inputs", {
  expect_equal("A" %p% "", "A ")
  expect_equal("" %p% "B", " B")
  expect_equal("" %p% "", " ")
})

# ------------------------------------------------------------------------------
# Vectorized input (element-wise paste)
# ------------------------------------------------------------------------------
test_that("works with vectorized input", {
  expect_equal(c("a", "b") %p% c("1", "2"), c("a 1", "b 2"))
  expect_equal("X" %p% c("Y", "Z"), c("X Y", "X Z"))
})

# ------------------------------------------------------------------------------
# Error handling
# ------------------------------------------------------------------------------
test_that("throws error for non-character input", {
  expect_error(1 %p% "a", "must be a character vector")
  expect_error("a" %p% TRUE, "must be a character vector")
  expect_error(list("a") %p% "b", "must be a character vector")
})

