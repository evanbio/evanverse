# =============================================================================
# Test: df2list()
# File: test-df2list.R
# Description: Tests for converting data.frame to named list
# =============================================================================

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
test_that("df2list converts to named list grouped by key_col", {
  df <- data.frame(
    cell_type = c(rep("B", 3), rep("T", 2)),
    marker = c("CD19", "CD20", "CD22", "CD3D", "CD8A")
  )

  result <- df2list(df, key_col = "cell_type", value_col = "marker", verbose = FALSE)

  expect_type(result, "list")
  expect_named(result, c("B", "T"))
  expect_equal(length(result), 2)
  expect_equal(result$B, c("CD19", "CD20", "CD22"))
  expect_equal(result$T, c("CD3D", "CD8A"))
})

# ------------------------------------------------------------------------------
# Error handling tests
# ------------------------------------------------------------------------------
test_that("throws error for non-data.frame input", {
  expect_error(df2list("not_a_df", "a", "b"), "data")
})

test_that("throws error if key_col is invalid", {
  df <- data.frame(a = 1:3, b = letters[1:3])
  expect_error(
    df2list(df, key_col = "nonexistent", value_col = "b"),
    "not found"
  )
})

test_that("throws error if value_col is invalid", {
  df <- data.frame(a = 1:3, b = letters[1:3])
  expect_error(
    df2list(df, key_col = "a", value_col = "missing"),
    "not found"
  )
})

# ------------------------------------------------------------------------------
# Silent operation tests
# ------------------------------------------------------------------------------
test_that("runs silently when verbose = FALSE", {
  df <- data.frame(group = c("X", "X", "Y"), val = c(1, 2, 3))
  expect_silent(df2list(df, "group", "val", verbose = FALSE))
})

