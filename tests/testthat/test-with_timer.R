# tests/testthat/test-with_timer.R
# Tests for with_timer — function execution timer wrapper

# ------------------------------------------------------------------------------
# Basic functionality
# ------------------------------------------------------------------------------
test_that("with_timer wraps function correctly and returns expected result", {
  skip_if_not_installed("tictoc")
  square_fn <- function(x) x^2
  wrapped_fn <- with_timer(square_fn, name = "Square test")

  result <- wrapped_fn(5)
  expect_equal(result, 25)
})

test_that("with_timer returns invisibly", {
  skip_if_not_installed("tictoc")
  quiet_fn <- function(x) x
  wrapped <- with_timer(quiet_fn, name = "Silent task")

  expect_invisible(wrapped(1))
})

# ------------------------------------------------------------------------------
# Error handling
# ------------------------------------------------------------------------------
test_that("with_timer throws error if fn is not a function", {
  skip_if_not_installed("tictoc")
  expect_error(with_timer("not_a_function"), "must be a function")
})
