#===============================================================================
# 🧪 Test: drop_void()
# 📁 File: test-drop_void.R
# 🔍 Description: Unit tests for drop_void() to remove NA, NULL, and "" values
#===============================================================================

#------------------------------------------------------------------------------
# 🧪 Basic removal
#------------------------------------------------------------------------------

test_that("drop_void() removes NA and empty strings by default", {
  x <- c("A", "", NA, "B")
  expect_equal(drop_void(x), c("A", "B"))
})

test_that("drop_void() removes NULL from list", {
  x <- list("X", "", NULL, NA)
  result <- drop_void(x)
  expect_equal(result, list("X"))
})

test_that("drop_void() returns NULL if input is NULL", {
  expect_null(drop_void(NULL))
})

#------------------------------------------------------------------------------
# ⚙️ Parameter variations
#------------------------------------------------------------------------------

test_that("drop_void() respects include_na = FALSE", {
  x <- c("A", "", NA)
  expect_equal(drop_void(x, include_na = FALSE), c("A", NA))
})

test_that("drop_void() respects include_empty_str = FALSE", {
  x <- c("A", "", NA)
  expect_equal(drop_void(x, include_empty_str = FALSE), c("A",""))
})

test_that("drop_void() retains all when all excluded", {
  x <- c("", NA, "text")
  expect_equal(drop_void(x, include_na = FALSE, include_empty_str = FALSE), c("", NA, "text"))
})

#------------------------------------------------------------------------------
# 🧪 Edge cases
#------------------------------------------------------------------------------

test_that("drop_void() on vector with no void returns identical input", {
  x <- c("A", "B")
  expect_equal(drop_void(x), x)
})

test_that("drop_void() on empty vector returns empty vector", {
  expect_equal(drop_void(character(0)), character(0))
})

test_that("drop_void() handles list with mixed content", {
  x <- list("A", NA, NULL, "", "B")
  expect_equal(drop_void(x), list("A", "B"))
})
