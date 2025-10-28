#===============================================================================
# Test: Void Value Utilities
# File: test-void.R
# Description: Unit tests for all void-related functions (is_void, any_void,
#              drop_void, replace_void, cols_with_void, rows_with_void)
#===============================================================================

#===============================================================================
# is_void() Tests
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
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
# Parameter behavior
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

#------------------------------------------------------------------------------
# List input
#------------------------------------------------------------------------------

test_that("is_void() works with list input", {
  x <- list("", NA, NULL, "non-empty")
  result <- is_void(x)
  expect_equal(result, c(TRUE, TRUE, TRUE, FALSE))
})

test_that("is_void() handles nested lists", {
  x <- list("a", list(NULL, "b", list(NA)))
  result <- is_void(x)
  expect_equal(result, c(FALSE, TRUE, FALSE, TRUE))
})

#------------------------------------------------------------------------------
# Edge cases
#------------------------------------------------------------------------------

test_that("is_void() works with non-character types", {
  x <- c(NA, 1, 2)
  result <- is_void(x)
  expect_equal(result, c(TRUE, FALSE, FALSE))
})

test_that("is_void() handles all NA input", {
  x <- c(NA, NA)
  expect_equal(is_void(x), c(TRUE, TRUE))
  expect_equal(is_void(x, include_na = FALSE), c(FALSE, FALSE))
})

test_that("is_void() handles empty input", {
  expect_equal(is_void(character(0)), logical(0))
})

test_that("is_void() handles logical vectors", {
  x <- c(TRUE, FALSE, NA)
  result <- is_void(x)
  expect_equal(result, c(FALSE, FALSE, TRUE))
})

#===============================================================================
# any_void() Tests
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------

test_that("any_void() detects NA and empty strings", {
  x <- c("A", "", NA)
  expect_true(any_void(x))
})

test_that("any_void() returns FALSE for all valid values", {
  x <- c("apple", "banana", "cherry")
  expect_false(any_void(x))
})

#------------------------------------------------------------------------------
# Parameter variations
#------------------------------------------------------------------------------

test_that("any_void() respects include_na = FALSE", {
  x <- c("A", "", NA)
  expect_true(any_void(x, include_na = FALSE))     # only "" triggers TRUE
  expect_false(any_void(x, include_na = FALSE, include_empty_str = FALSE))  # nothing void
})

test_that("any_void() respects include_empty_str = FALSE", {
  x <- c("", "X")
  expect_false(any_void(x, include_empty_str = FALSE))
})

test_that("any_void() handles NULL correctly", {
  expect_true(any_void(NULL))                        # default = TRUE
  expect_false(any_void(NULL, include_null = FALSE)) # turn off
})

#------------------------------------------------------------------------------
# List input support
#------------------------------------------------------------------------------

test_that("any_void() works on list input", {
  x <- list("X", "", NULL, NA)
  expect_true(any_void(x))
  expect_false(any_void(x, include_na = FALSE, include_empty_str = FALSE, include_null = FALSE))
})

test_that("any_void() handles nested lists", {
  x <- list("a", list(NULL, "b"))
  expect_true(any_void(x))
})

#------------------------------------------------------------------------------
# Edge cases
#------------------------------------------------------------------------------

test_that("any_void() on empty vector returns FALSE", {
  expect_false(any_void(character(0)))
})

test_that("any_void() handles numeric input with NA", {
  x <- c(1, 2, NA)
  expect_true(any_void(x))
  expect_false(any_void(x, include_na = FALSE))
})

test_that("any_void() handles all NA input", {
  x <- c(NA, NA)
  expect_true(any_void(x))
  expect_false(any_void(x, include_na = FALSE))
})

#===============================================================================
# drop_void() Tests
#===============================================================================

# -------------------------------------------------------------------------------
# Basic removal
# -------------------------------------------------------------------------------
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

# -------------------------------------------------------------------------------
# Parameter variations
# -------------------------------------------------------------------------------
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

# -------------------------------------------------------------------------------
# Edge cases
# -------------------------------------------------------------------------------
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

#===============================================================================
# replace_void() Tests
#===============================================================================

#------------------------------------------------------------------------------
# Basic replacements
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
# Parameter variations
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
  expect_equal(
    replace_void(x, value = "Z", include_na = FALSE, include_empty_str = FALSE),
    c("", NA, "X")
  )
})

#------------------------------------------------------------------------------
# Edge cases
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

#------------------------------------------------------------------------------
# Additional coverage (non-intrusive)
#------------------------------------------------------------------------------
test_that("include_null = FALSE leaves NULLs in list unchanged", {
  x <- list("A", NULL, "B", NA, "")
  res <- replace_void(x, value = "X", include_null = FALSE)
  expect_equal(res, list("A", NULL, "B", "X", "X"))
})

test_that("numeric vectors replace NA with numeric value (type-stable)", {
  x <- c(1, NA_real_, 3)
  res <- replace_void(x, value = 0)
  expect_equal(res, c(1, 0, 3))
  expect_type(res, "double")
})

#===============================================================================
# cols_with_void() Tests
#===============================================================================

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Parameter variations tests
# ------------------------------------------------------------------------------
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

test_that("cols_with_void() respects include_null = FALSE", {
  df <- data.frame(a = c("A", NULL), b = c(1, 2), stringsAsFactors = FALSE)
  result <- cols_with_void(df, include_null = FALSE)
  expect_equal(result, character(0))
})

# ------------------------------------------------------------------------------
# Edge cases tests
# ------------------------------------------------------------------------------
test_that("cols_with_void() on fully valid data returns empty vector", {
  df <- data.frame(a = c("A", "B"), b = 1:2, stringsAsFactors = FALSE)
  expect_equal(cols_with_void(df), character(0))
})

test_that("cols_with_void() on empty data.frame returns empty", {
  df <- data.frame()
  expect_equal(cols_with_void(df), character(0))
})

# ------------------------------------------------------------------------------
# Error handling tests
# ------------------------------------------------------------------------------
test_that("cols_with_void() errors on non-data input", {
  expect_error(cols_with_void(c("A", NA)))
})

test_that("cols_with_void() errors on invalid include_na parameter", {
  df <- data.frame(a = 1:2, stringsAsFactors = FALSE)
  expect_error(cols_with_void(df, include_na = "yes"))
})

test_that("cols_with_void() errors on invalid return_names parameter", {
  df <- data.frame(a = 1:2, stringsAsFactors = FALSE)
  expect_error(cols_with_void(df, return_names = "yes"))
})

test_that("cols_with_void() errors on invalid include_null parameter", {
  df <- data.frame(a = 1:2, stringsAsFactors = FALSE)
  expect_error(cols_with_void(df, include_null = "yes"))
})

test_that("cols_with_void() errors on invalid include_empty_str parameter", {
  df <- data.frame(a = 1:2, stringsAsFactors = FALSE)
  expect_error(cols_with_void(df, include_empty_str = "yes"))
})

#===============================================================================
# rows_with_void() Tests
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------
test_that("rows_with_void() detects rows with void values", {
  df <- data.frame(
    id    = 1:3,
    name  = c("Alice", "", "Charlie"),
    score = c(10, 15, NA),
    stringsAsFactors = FALSE
  )

  result <- rows_with_void(df)
  expect_type(result, "logical")
  expect_equal(result, c(FALSE, TRUE, TRUE))
})

test_that("rows_with_void() returns logical vector with correct order", {
  df <- data.frame(a = c(1, 2), b = c("", "x"), stringsAsFactors = FALSE)
  result <- rows_with_void(df)
  expect_type(result, "logical")
  expect_equal(result, c(TRUE, FALSE))
})

#------------------------------------------------------------------------------
# Parameter variants
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

test_that("rows_with_void() with all flags FALSE returns all FALSE", {
  df <- data.frame(a = c("", NA, "text"), b = c(1, 2, 3), stringsAsFactors = FALSE)
  result <- rows_with_void(
    df,
    include_na = FALSE,
    include_empty_str = FALSE,
    include_null = FALSE
  )
  expect_equal(result, c(FALSE, FALSE, FALSE))
})

#------------------------------------------------------------------------------
# Edge cases
#------------------------------------------------------------------------------
test_that("rows_with_void() on empty data.frame returns empty logical", {
  df <- data.frame()
  expect_equal(rows_with_void(df), logical(0))
})

test_that("rows_with_void() on fully valid data returns all FALSE", {
  df <- data.frame(a = c("A", "B"), b = c(1, 2), stringsAsFactors = FALSE)
  expect_equal(rows_with_void(df), c(FALSE, FALSE))
})

test_that("rows_with_void() errors on non-data.frame input", {
  expect_error(rows_with_void(NULL), regexp = "data\\.frame|tibble")
})

#------------------------------------------------------------------------------
# Additional coverage
#------------------------------------------------------------------------------
test_that("rows_with_void() treats empty string in factor columns as void", {
  df <- data.frame(a = factor(c("", "x")), b = c(1, 2))
  expect_equal(rows_with_void(df), c(TRUE, FALSE))
})

test_that("rows_with_void() works with tibble input", {
  skip_if_not_installed("tibble")
  df <- tibble::tibble(id = 1:3, name = c("A", "", "C"))
  expect_equal(rows_with_void(df), c(FALSE, TRUE, FALSE))
})
