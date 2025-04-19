# 📦 Tests for `df2list()` — Group & aggregate value_col into list-column
# File: tests/testthat/test-df2list.R

# ------------------------------------------------------------------------------
# ✅ Basic functionality: groups correctly
# ------------------------------------------------------------------------------

test_that("df2list groups by key and aggregates value column", {
  df <- data.frame(
    cell_type = c(rep("B", 3), rep("T", 2)),
    marker = c("CD19", "CD20", "CD22", "CD3D", "CD8A")
  )

  result <- df2list(df, key_col = "cell_type", value_col = "marker", verbose = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_equal(nrow(result), 2)
  expect_named(result, c("cell_type", "marker"))
  expect_true(all(vapply(result$marker, is.character, logical(1))))
  expect_equal(result$marker[[1]], c("CD19", "CD20", "CD22"))
})

# ------------------------------------------------------------------------------
# ❌ Invalid inputs: wrong types or missing columns
# ------------------------------------------------------------------------------

test_that("throws error for non-data.frame input", {
  expect_error(df2list("not_a_df", "a", "b"), "data")
})

test_that("throws error if key_col is invalid", {
  df <- data.frame(a = 1:3, b = letters[1:3])
  expect_error(df2list(df, key_col = "nonexistent", value_col = "b"), "key_col")
})

test_that("throws error if value_col is invalid", {
  df <- data.frame(a = 1:3, b = letters[1:3])
  expect_error(df2list(df, key_col = "a", value_col = "missing"), "value_col")
})

# ------------------------------------------------------------------------------
# ✅ Silent when verbose = FALSE
# ------------------------------------------------------------------------------

test_that("runs silently when verbose = FALSE", {
  df <- data.frame(group = c("X", "X", "Y"), val = c(1, 2, 3))
  expect_silent(df2list(df, "group", "val", verbose = FALSE))
})

