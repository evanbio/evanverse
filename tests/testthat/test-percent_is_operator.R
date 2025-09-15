#===============================================================================
# Test: percent_is_operator()
# tests/testthat/test-percent_is_operator.R
# Tests for `%is%` — Strict identity comparison with diagnostics
#===============================================================================

# ------------------------------------------------------------------------------
# Basic functionality
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
# Names and attributes
# ------------------------------------------------------------------------------
test_that("detects vector name differences", {
  v1 <- c(a = 1, b = 2)
  v2 <- c(b = 2, a = 1)
  expect_false(v1 %is% v2)
})

test_that("detects data.frame column name differences", {
  df1 <- data.frame(x = 1, y = 2)
  df2 <- data.frame(y = 2, x = 1)
  expect_false(df1 %is% df2)
})

test_that("detects matrix dimnames differences", {
  m1 <- matrix(1:4, nrow = 2, dimnames = list(c("r1","r2"), c("c1","c2")))
  m2 <- matrix(1:4, nrow = 2, dimnames = list(c("r1","r2"), c("cX","c2")))
  expect_false(m1 %is% m2)
})

# ------------------------------------------------------------------------------
# NA/NaN handling
# ------------------------------------------------------------------------------
test_that("handles NA and NaN consistently", {
  expect_true(c(1, NA) %is% c(1, NA))
  expect_false(c(1, NA) %is% c(1, NaN))
  expect_false(c(1, NaN) %is% c(1, NA))
})

# ------------------------------------------------------------------------------
# Edge cases and unsupported inputs
# ------------------------------------------------------------------------------
test_that("handles empty vectors, matrices, and data.frames", {
  expect_true(numeric(0) %is% numeric(0))
  expect_true(character(0) %is% character(0))

  m0a <- matrix(numeric(0), nrow = 0, ncol = 0)
  m0b <- matrix(numeric(0), nrow = 0, ncol = 0)
  expect_true(m0a %is% m0b)
  expect_false(m0a %is% matrix(numeric(0), nrow = 1, ncol = 0))

  d0a <- data.frame(x = numeric(0))
  d0b <- data.frame(x = numeric(0))
  expect_true(d0a %is% d0b)
})

test_that("detects type/shape mismatches without relying on output text", {
  expect_false(c(1, 2) %is% c(1, 2, 3))                         # length mismatch
  expect_false(matrix(1:4, 2) %is% matrix(1:4, 1))              # dim mismatch
  expect_false(data.frame(x = 1) %is% data.frame(y = 1))        # names mismatch
})

test_that("returns FALSE for unsupported types", {
  expect_false(list(1) %is% 1:3)
  expect_false(1:3 %is% (function() {}))
})
