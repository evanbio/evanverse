# tests/testthat/test-percent_is_operator.R
# 📌 Tests for `%is%` — Strict identity comparison with diagnostics

# ------------------------------------------------------------------------------
# ✅ Basic functionality
# ------------------------------------------------------------------------------

test_that("basic comparison works for vectors", {
  expect_true(1:3 %is% 1:3)
  expect_false(1:3 %is% c(1, 2, 4))
  expect_false(c("a", "b") %is% c("a", "c"))
})

test_that("basic comparison works for matrices", {
  m1 <- matrix(1:4, nrow = 2)
  m2 <- matrix(1:4, nrow = 2)
  m3 <- matrix(c(1, 2, 3, 5), nrow = 2)
  expect_true(m1 %is% m2)
  expect_false(m1 %is% m3)
})

test_that("basic comparison works for data.frames", {
  df1 <- data.frame(x = 1:2, y = c("a", "b"))
  df2 <- data.frame(x = 1:2, y = c("a", "b"))
  df3 <- data.frame(x = 1:2, y = c("a", "c"))
  expect_true(df1 %is% df2)
  expect_false(df1 %is% df3)
})

# ------------------------------------------------------------------------------
# ✅ Handles edge cases correctly
# ------------------------------------------------------------------------------

test_that("handles empty vectors", {
  expect_true(numeric(0) %is% numeric(0))
  expect_true(character(0) %is% character(0))
  expect_false(numeric(0) %is% c(1))
})

test_that("handles empty matrices and data.frames", {
  m1 <- matrix(numeric(0), nrow = 0, ncol = 0)
  m2 <- matrix(numeric(0), nrow = 0, ncol = 0)
  df1 <- data.frame(x = numeric(0))
  df2 <- data.frame(x = numeric(0))
  expect_true(m1 %is% m2)
  expect_true(df1 %is% df2)
  expect_false(m1 %is% matrix(numeric(0), nrow = 1, ncol = 0))
})

test_that("handles NA and NaN correctly", {
  expect_true(c(1, NA) %is% c(1, NA))
  expect_false(c(1, NA) %is% c(1, NaN))
  expect_false(c(1, NaN) %is% c(1, NA))
})

# ------------------------------------------------------------------------------
# ✅ Skips unsupported output-based tests — Recommend manual check if needed
# ------------------------------------------------------------------------------

test_that("errors for unsupported input types", {
  expect_false(list(1) %is% 1:3)
  expect_false(1:3 %is% function() {})
})

test_that("detects type and value mismatches (without output check)", {
  expect_false(c(1, 2) %is% c(1, 2, 3))
  expect_false(matrix(1:4, 2) %is% matrix(1:4, 1))
  expect_false(data.frame(x = 1) %is% data.frame(y = 1))
  expect_false(c(1, 2, 3) %is% c(1, 2, 4))
})

test_that("detects matrix and data.frame value differences", {
  m1 <- matrix(1:4, nrow = 2)
  m2 <- matrix(c(1, 2, 3, 5), nrow = 2)
  expect_false(m1 %is% m2)

  df1 <- data.frame(x = 1:2, y = c("a", "b"))
  df2 <- data.frame(x = 1:2, y = c("a", "c"))
  expect_false(df1 %is% df2)
})

