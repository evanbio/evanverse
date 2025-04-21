#===============================================================================
# 🧪 Test: is_void()
# 📁 File: test-is_void.R
# 🔍 Description: Unit tests for is_void() handling NA, NULL, and ""
#===============================================================================

#------------------------------------------------------------------------------
# 🧪 Basic functionality
#------------------------------------------------------------------------------

test_that("is_void() detects NA and empty string by default", {
  x <- c("a", "", NA)
  result <- is_void(x)
  expect_equal(result, c(FALSE, TRUE, TRUE))
})

test_that("is_void() returns TRUE for NULL if include_null = TRUE", {
  expect_true(is_void(NULL))
})

test_that("is_void() returns FALSE for NULL if include_null = FALSE", {
  expect_false(is_void(NULL, include_null = FALSE))
})

#------------------------------------------------------------------------------
# ⚙️ Parameter behavior
#------------------------------------------------------------------------------

test_that("is_void() respects include_na = FALSE", {
  x <- c("", NA)
  result <- is_void(x, include_na = FALSE)
  expect_equal(result, c(TRUE, FALSE))
})

test_that("is_void() respects include_empty_str = FALSE", {
  x <- c("", NA)
  result <- is_void(x, include_empty_str = FALSE)
  expect_equal(result, c(FALSE, TRUE))
})

test_that("is_void() works with list input", {
  x <- list("", NA, NULL, "non-empty")
  result <- is_void(x)
  expect_equal(result, c(TRUE, TRUE, TRUE, FALSE))
})

test_that("is_void() works with non-character types", {
  x <- c(NA, 1, 2)
  result <- is_void(x)
  expect_equal(result, c(TRUE, FALSE, FALSE))
})
