# tests/testthat/test-remind.R
# 📌 Tests for `remind()` — keyword-based usage reminder

# ------------------------------------------------------------------------------
# ✅ Basic functionality
# ------------------------------------------------------------------------------

test_that("returns invisible output for valid keywords", {
  expect_invisible(remind("glimpse"))
  expect_invisible(remind("read_excel"))
})

test_that("supports partial matching for keywords", {
  expect_invisible(remind("glim"))
  expect_invisible(remind("excel"))
})

# ------------------------------------------------------------------------------
# ✅ NULL input prints full keyword list
# ------------------------------------------------------------------------------

test_that("returns NULL and prints full list when keyword is NULL", {
  result <- expect_invisible(remind())
  expect_null(result)
})

# ------------------------------------------------------------------------------
# ✅ Handles unmatched keyword
# ------------------------------------------------------------------------------

test_that("returns FALSE with no match and prints warning", {
  result <- expect_invisible(remind("notakeyword"))
  expect_false(result)
})

# ------------------------------------------------------------------------------
# ✅ Handles  case insensitive
# ------------------------------------------------------------------------------

test_that("supports partial matches (case-insensitive)", {
  result <- expect_invisible(remind("Glim"))
  expect_true(result)
})

# ------------------------------------------------------------------------------
# ✅ Handles  multiple matches
# ------------------------------------------------------------------------------

test_that("prints multiple matches if available", {
  # You can add another mock entry like "glimpse_data" if needed later
  expect_invisible(remind("read"))
})
