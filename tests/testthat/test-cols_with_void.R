#===============================================================================
# 🧪 Test: cols_with_void()
# 📁 File: test-cols_with_void.R
# 🔍 Description: Unit tests for cols_with_void() to detect void-containing columns
#===============================================================================

#------------------------------------------------------------------------------
# 🧪 Basic functionality
#------------------------------------------------------------------------------

test_that("cols_with_void() returns column names with voids", {
  df <- data.frame(
    id = 1:3,
    name = c("A", "", "C"),
    score = c(10, NA, 20),
    stringsAsFactors = FALSE
  )

  result <- cols_with_void(df)
  expect_equal(result, c("name", "score"))
})

test_that("cols_with_void() returns logical vector if return_names = FALSE", {
  df <- data.frame(a = c(1, 2), b = c("", "x"), stringsAsFactors = FALSE)
  result <- cols_with_void(df, return_names = FALSE)
  expect_type(result, "logical")
  expect_named(result, c("a", "b"))
  expect_equal(result, setNames(c(FALSE, TRUE), c("a", "b")))
})

#------------------------------------------------------------------------------
# ⚙️ Parameter variations
#------------------------------------------------------------------------------

test_that("cols_with_void() respects include_empty_str = FALSE", {
  df <- data.frame(a = c("a", ""), b = c(1, 2), stringsAsFactors = FALSE)
  result <- cols_with_void(df, include_empty_str = FALSE)
  expect_equal(result, character(0))
})

test_that("cols_with_void() respects include_na = FALSE", {
  df <- data.frame(a = c("A", NA), b = c(1, 2), stringsAsFactors = FALSE)
  result <- cols_with_void(df, include_na = FALSE)
  expect_equal(result, character(0))
})

#------------------------------------------------------------------------------
# 🧪 Edge cases
#------------------------------------------------------------------------------

test_that("cols_with_void() on fully valid data returns empty vector", {
  df <- data.frame(a = c("A", "B"), b = 1:2, stringsAsFactors = FALSE)
  expect_equal(cols_with_void(df), character(0))
})

test_that("cols_with_void() on empty data.frame returns empty", {
  df <- data.frame()
  expect_equal(cols_with_void(df), character(0))
})

test_that("cols_with_void() errors on non-data input", {
  expect_error(cols_with_void(c("A", NA)))
})

