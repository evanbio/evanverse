#===============================================================================
# 🧪 Test: rows_with_void()
# 📁 File: test-rows_with_void.R
# 🔍 Description: Unit tests for rows_with_void() to detect void-containing rows
#===============================================================================

#------------------------------------------------------------------------------
# 🧪 Basic functionality
#------------------------------------------------------------------------------

test_that("rows_with_void() detects rows with void values", {
  df <- data.frame(
    id = 1:3,
    name = c("Alice", "", "Charlie"),
    score = c(10, 15, NA),
    stringsAsFactors = FALSE
  )

  result <- rows_with_void(df)
  expect_equal(result, c(FALSE, TRUE, TRUE))
})

test_that("rows_with_void() returns logical vector", {
  df <- data.frame(a = c(1, 2), b = c("", "x"), stringsAsFactors = FALSE)
  result <- rows_with_void(df)

  # Ensure result is a logical vector and its values match the expected order
  expect_type(result, "logical")
  expect_equal(result, c(TRUE, FALSE))  # Adjusted expected order (based on NA check)
})


#------------------------------------------------------------------------------
# ⚙️ Parameter variations
#------------------------------------------------------------------------------

test_that("rows_with_void() respects include_na = FALSE", {
  df <- data.frame(a = c("A", NA), b = c(1, 2), stringsAsFactors = FALSE)
  result <- rows_with_void(df, include_na = FALSE)
  expect_equal(result, c(FALSE, FALSE))
})

test_that("rows_with_void() respects include_empty_str = FALSE", {
  df <- data.frame(a = c("A", ""), b = c(1, 2), stringsAsFactors = FALSE)
  result <- rows_with_void(df, include_empty_str = FALSE)
  expect_equal(result, c(FALSE, FALSE))
})

test_that("rows_with_void() handles all include_* = FALSE correctly", {
  df <- data.frame(a = c("", NA, "text"), b = c(1, 2, 3), stringsAsFactors = FALSE)
  result <- rows_with_void(df, include_na = FALSE, include_empty_str = FALSE)
  expect_equal(result, c(FALSE, FALSE, FALSE))
})

#------------------------------------------------------------------------------
# 🧪 Edge cases
#------------------------------------------------------------------------------

test_that("rows_with_void() on empty data.frame returns empty", {
  df <- data.frame()
  expect_equal(rows_with_void(df), logical(0))
})

test_that("rows_with_void() on fully valid data returns FALSE", {
  df <- data.frame(a = c("A", "B"), b = c(1, 2), stringsAsFactors = FALSE)
  expect_equal(rows_with_void(df), c(FALSE, FALSE))
})

test_that("rows_with_void() handles NULL input gracefully", {
  expect_error(rows_with_void(NULL))
})
