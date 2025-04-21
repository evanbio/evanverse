#===============================================================================
# 🧪 Test: replace_void()
# 📁 File: test-replace_void.R
# 🔍 Description: Unit tests for replace_void() to substitute NA, NULL, and "" values
#===============================================================================

#------------------------------------------------------------------------------
# 🧪 Basic replacements
#------------------------------------------------------------------------------

test_that("replace_void() replaces NA and empty string by default", {
  x <- c("A", "", NA, "B")
  expect_equal(replace_void(x, value = "X"), c("A", "X", "X", "B"))
})

test_that("replace_void() replaces NULL in list", {
  x <- list("A", "", NULL, NA, "B")
  result <- replace_void(x, value = "Z")
  expect_equal(result, list("A", "Z", "Z", "Z", "B"))
})

test_that("replace_void() returns replacement if input is NULL", {
  expect_equal(replace_void(NULL, value = "X"), "X")
  expect_null(replace_void(NULL, value = "X", include_null = FALSE))
})

#------------------------------------------------------------------------------
# ⚙️ Parameter variations
#------------------------------------------------------------------------------

test_that("replace_void() respects include_na = FALSE", {
  x <- c("A", "", NA)
  result <- replace_void(x, value = "Z", include_na = FALSE)
  expect_equal(result, c("A", "Z", NA))
})

test_that("replace_void() respects include_empty_str = FALSE", {
  x <- c("A", "", NA)
  result <- replace_void(x, value = "Z", include_empty_str = FALSE)
  expect_equal(result, c("A", "", "Z"))
})

test_that("replace_void() handles all include_* = FALSE correctly", {
  x <- c("", NA, "X")
  expect_equal(replace_void(x, value = "Z",
                            include_na = FALSE,
                            include_empty_str = FALSE), c("", NA, "X"))
})

#------------------------------------------------------------------------------
# 🧪 Edge cases
#------------------------------------------------------------------------------

test_that("replace_void() on fully valid input returns unchanged", {
  x <- c("A", "B")
  expect_equal(replace_void(x, value = "Z"), x)
})

test_that("replace_void() on empty input returns empty input", {
  expect_equal(replace_void(character(0), value = "Z"), character(0))
})

test_that("replace_void() on list with no void returns original list", {
  x <- list("A", "B")
  expect_equal(replace_void(x, value = "Z"), x)
})

