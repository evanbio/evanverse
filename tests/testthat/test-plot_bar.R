#===============================================================================
# Test: plot_bar()
# File: test-plot_bar.R
# Description: Unit tests for the plot_bar() function
#===============================================================================

#------------------------------------------------------------------------------
# Setup: Create test data
#------------------------------------------------------------------------------

# Create sample data for testing
test_data <- data.frame(
  category = c("A", "B", "C", "D"),
  value = c(10, 25, 15, 30),
  group = c("X", "X", "Y", "Y"),
  stringsAsFactors = FALSE
)

test_data_factor <- data.frame(
  category = factor(c("A", "B", "C", "D")),
  value = c(10, 25, 15, 30),
  group = factor(c("X", "X", "Y", "Y"))
)

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("plot_bar() creates a ggplot object", {
  p <- plot_bar(test_data, x = category, y = value)
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar() works with quoted column names", {
  p <- plot_bar(test_data, x = "category", y = "value")
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar() works with unquoted column names", {
  p <- plot_bar(test_data, x = category, y = value)
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar() works with fill parameter", {
  p <- plot_bar(test_data, x = category, y = value, fill = "group")
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar() works in horizontal direction", {
  p <- plot_bar(test_data, x = category, y = value, direction = "horizontal")
  expect_s3_class(p, "ggplot")
})

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("plot_bar() validates data parameter", {
  expect_error(plot_bar(NULL, x = category, y = value), "`data` must be a data.frame")
  expect_error(plot_bar(list(a = 1, b = 2), x = category, y = value), "`data` must be a data.frame")
  expect_error(plot_bar("not_a_df", x = category, y = value), "`data` must be a data.frame")
})

test_that("plot_bar() validates column existence", {
  expect_error(plot_bar(test_data, x = nonexistent, y = value), "Column `nonexistent` not found")
  expect_error(plot_bar(test_data, x = category, y = nonexistent), "Column `nonexistent` not found")
})

test_that("plot_bar() validates width parameter", {
  expect_error(plot_bar(test_data, x = category, y = value, width = "invalid"), "`width` must be a single positive numeric value")
  expect_error(plot_bar(test_data, x = category, y = value, width = -1), "`width` must be a single positive numeric value")
  expect_error(plot_bar(test_data, x = category, y = value, width = 0), "`width` must be a single positive numeric value")
  expect_error(plot_bar(test_data, x = category, y = value, width = c(0.5, 0.7)), "`width` must be a single positive numeric value")
  expect_error(plot_bar(test_data, x = category, y = value, width = NA), "`width` must be a single positive numeric value")
})

test_that("plot_bar() validates fill parameter", {
  expect_error(plot_bar(test_data, x = category, y = value, fill = 123), "`fill` must be a single non-NA character string")
  expect_error(plot_bar(test_data, x = category, y = value, fill = c("group1", "group2")), "`fill` must be a single non-NA character string")
  expect_error(plot_bar(test_data, x = category, y = value, fill = NA), "`fill` must be a single non-NA character string")
  expect_error(plot_bar(test_data, x = category, y = value, fill = ""), "`fill` must be a single non-NA character string")
})

test_that("plot_bar() validates direction parameter", {
  expect_error(plot_bar(test_data, x = category, y = value, direction = "invalid"), "'arg' should be one of")
})

test_that("plot_bar() validates sort_dir parameter", {
  expect_error(plot_bar(test_data, x = category, y = value, sort = TRUE, sort_dir = "invalid"), "'arg' should be one of")
})

#------------------------------------------------------------------------------
# Sorting Tests
#------------------------------------------------------------------------------

test_that("plot_bar() handles sorting without fill", {
  p <- plot_bar(test_data, x = category, y = value, sort = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar() handles sorting with sort_by", {
  p <- plot_bar(test_data, x = category, y = value, fill = "group", sort = TRUE, sort_by = "X")
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar() validates sort_by parameter", {
  expect_error(
    plot_bar(test_data, x = category, y = value, fill = "group", sort = TRUE, sort_by = "invalid"),
    "is not a valid level of"
  )
})

test_that("plot_bar() handles descending sort", {
  p <- plot_bar(test_data, x = category, y = value, sort = TRUE, sort_dir = "desc")
  expect_s3_class(p, "ggplot")
})

#------------------------------------------------------------------------------
# Warning Tests
#------------------------------------------------------------------------------

test_that("plot_bar() warns about duplicated x without fill", {
  test_data_dup <- data.frame(
    category = c("A", "A", "B", "B"),
    value = c(10, 15, 20, 25)
  )
  expect_warning(
    plot_bar(test_data_dup, x = category, y = value),
    "Multiple rows share the same x value"
  )
})

test_that("plot_bar() warns when sort_by is not set with fill", {
  expect_warning(
    plot_bar(test_data, x = category, y = value, fill = "group", sort = TRUE),
    "`sort = TRUE` but `sort_by` is not set"
  )
})

#------------------------------------------------------------------------------
# Edge Cases and Special Scenarios
#------------------------------------------------------------------------------

test_that("plot_bar() handles factor columns", {
  p <- plot_bar(test_data_factor, x = category, y = value)
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar() handles empty data frame", {
  empty_data <- data.frame(category = character(0), value = numeric(0))
  p <- plot_bar(empty_data, x = category, y = value)
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar() handles single row data", {
  single_data <- data.frame(category = "A", value = 10)
  p <- plot_bar(single_data, x = category, y = value)
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar() passes additional arguments to geom_bar", {
  p <- plot_bar(test_data, x = category, y = value, alpha = 0.5, color = "black")
  expect_s3_class(p, "ggplot")
})

#------------------------------------------------------------------------------
# Dependency Tests
#------------------------------------------------------------------------------

test_that("plot_bar() requires ggplot2", {
  # This test would normally skip if ggplot2 is not available
  # But since we're in a package context, we'll assume it's available
  skip_if_not(requireNamespace("ggplot2", quietly = TRUE), "ggplot2 not available")
  p <- plot_bar(test_data, x = category, y = value)
  expect_s3_class(p, "ggplot")
})

#===============================================================================
# End: test-plot_bar.R
#===============================================================================

