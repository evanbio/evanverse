#===============================================================================
# Test: plot_pie()
# File: test-plot_pie.R
# Description: Unit tests for the plot_pie() function
#===============================================================================

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("plot_pie() validates data parameter", {
  expect_error(plot_pie(NULL), "`data` cannot be NULL")
  expect_error(plot_pie(list(a = 1, b = 2)), "Input must be a vector or data frame")
})

test_that("plot_pie() validates numeric parameters", {
  df <- data.frame(group = c("A", "B"), count = c(10, 20))

  expect_error(plot_pie(df, label_size = "invalid"), "`label_size` must be a single positive numeric value")
  expect_error(plot_pie(df, label_size = -1), "`label_size` must be a single positive numeric value")
  expect_error(plot_pie(df, label_size = 0), "`label_size` must be a single positive numeric value")
  expect_error(plot_pie(df, label_size = c(4, 5)), "`label_size` must be a single positive numeric value")

  expect_error(plot_pie(df, title_size = "invalid"), "`title_size` must be a single positive numeric value")
  expect_error(plot_pie(df, title_size = -1), "`title_size` must be a single positive numeric value")
  expect_error(plot_pie(df, title_size = 0), "`title_size` must be a single positive numeric value")
})

test_that("plot_pie() validates character parameters", {
  df <- data.frame(group = c("A", "B"), count = c(10, 20))

  expect_error(plot_pie(df, label_color = 123), "`label_color` must be a single non-NA character string")
  expect_error(plot_pie(df, label_color = c("red", "blue")), "`label_color` must be a single non-NA character string")
  expect_error(plot_pie(df, label_color = NA), "`label_color` must be a single non-NA character string")

  expect_error(plot_pie(df, title_color = 123), "`title_color` must be a single non-NA character string")
  expect_error(plot_pie(df, title = 123), "`title` must be a single non-NA character string")
})

test_that("plot_pie() validates logical parameters", {
  df <- data.frame(group = c("A", "B"), count = c(10, 20))

  expect_error(plot_pie(df, preview = "yes"), "`preview` must be a single logical value")
  expect_error(plot_pie(df, preview = c(TRUE, FALSE)), "`preview` must be a single logical value")

  expect_error(plot_pie(df, return_data = "yes"), "`return_data` must be a single logical value")
  expect_error(plot_pie(df, return_data = c(TRUE, FALSE)), "`return_data` must be a single logical value")
})

test_that("plot_pie() validates column names for data.frame input", {
  df <- data.frame(group = c("A", "B"), count = c(10, 20))

  expect_error(plot_pie(df, group_col = 123), "`group_col` must be a single non-empty character string")
  expect_error(plot_pie(df, group_col = ""), "`group_col` must be a single non-empty character string")
  expect_error(plot_pie(df, group_col = c("group", "other")), "`group_col` must be a single non-empty character string")

  expect_error(plot_pie(df, count_col = 123), "`count_col` must be a single non-empty character string")
  expect_error(plot_pie(df, count_col = ""), "`count_col` must be a single non-empty character string")
})

test_that("plot_pie() validates save parameter", {
  df <- data.frame(group = c("A", "B"), count = c(10, 20))

  expect_error(plot_pie(df, save = 123), "`save` must be a single non-empty character string")
  expect_error(plot_pie(df, save = ""), "`save` must be a single non-empty character string")
  expect_error(plot_pie(df, save = c("file1.png", "file2.png")), "`save` must be a single non-empty character string")
})

#------------------------------------------------------------------------------
# Input Validation
#------------------------------------------------------------------------------

test_that("plot_pie() works with character vector input", {
  vec <- c("A", "A", "B", "C", "C", "C")
  expect_silent(p <- plot_pie(vec, preview = FALSE))
  expect_s3_class(p, "gg")
})

test_that("plot_pie() works with data.frame input", {
  df <- data.frame(group = c("A", "B", "C"), count = c(10, 20, 30))
  expect_silent(p <- plot_pie(df, group_col = "group", count_col = "count", preview = FALSE))
  expect_s3_class(p, "gg")
})

test_that("plot_pie() handles single group in vector input", {
  vec <- c("A", "A", "A")
  expect_error(plot_pie(vec, preview = FALSE), "Vector input must contain at least two unique groups")
})

test_that("plot_pie() handles missing columns in data.frame", {
  df <- data.frame(a = c("A", "B"), b = c(10, 20))
  expect_error(plot_pie(df, group_col = "missing", count_col = "b"), "Data frame must contain columns")
  expect_error(plot_pie(df, group_col = "a", count_col = "missing"), "Data frame must contain columns")
})

#------------------------------------------------------------------------------
# Label Parameter
#------------------------------------------------------------------------------

test_that("plot_pie() handles different label types", {
  df <- data.frame(group = c("X", "Y", "Z"), count = c(10, 20, 30))
  for (lbl in c("none", "count", "percent", "both")) {
    expect_silent(p <- plot_pie(df, label = lbl, preview = FALSE))
    expect_s3_class(p, "gg")
  }
})

test_that("plot_pie() validates label parameter", {
  df <- data.frame(group = c("A", "B"), count = c(10, 20))
  expect_error(plot_pie(df, label = "invalid"), "'arg' should be one of")
})

#------------------------------------------------------------------------------
# Return Values
#------------------------------------------------------------------------------

test_that("plot_pie() returns both plot and data when return_data = TRUE", {
  df <- data.frame(group = c("A", "B"), count = c(1, 2))
  out <- plot_pie(df, return_data = TRUE, preview = FALSE)

  expect_type(out, "list")
  expect_named(out, c("plot", "data"))
  expect_s3_class(out$plot, "gg")
  expect_s3_class(out$data, "data.frame")
  expect_true(all(c("group", "count", "percent", "label_text") %in% colnames(out$data)))
})

test_that("plot_pie() returns only plot when return_data = FALSE", {
  df <- data.frame(group = c("A", "B"), count = c(10, 20))
  p <- plot_pie(df, return_data = FALSE, preview = FALSE)
  expect_s3_class(p, "gg")
})

#------------------------------------------------------------------------------
# Customization Tests
#------------------------------------------------------------------------------

test_that("plot_pie() handles custom colors", {
  df <- data.frame(group = c("A", "B", "C"), count = c(10, 20, 30))
  custom_colors <- c("red", "blue", "green")
  expect_silent(p <- plot_pie(df, fill = custom_colors, preview = FALSE))
  expect_s3_class(p, "gg")
})

test_that("plot_pie() handles custom title and colors", {
  df <- data.frame(group = c("A", "B"), count = c(10, 20))
  expect_silent(p <- plot_pie(df,
                              title = "Custom Title",
                              title_size = 16,
                              title_color = "blue",
                              label_color = "red",
                              preview = FALSE))
  expect_s3_class(p, "gg")
})

#------------------------------------------------------------------------------
# Data Processing Tests
#------------------------------------------------------------------------------

test_that("plot_pie() filters out zero counts", {
  df <- data.frame(group = c("A", "B", "C"), count = c(10, 0, 30))
  out <- plot_pie(df, return_data = TRUE, preview = FALSE)
  expect_equal(nrow(out$data), 2)  # Should exclude zero count
  expect_false("B" %in% out$data$group)  # Group B should be excluded
})

test_that("plot_pie() handles negative counts", {
  df <- data.frame(group = c("A", "B", "C"), count = c(10, -5, 30))
  out <- plot_pie(df, return_data = TRUE, preview = FALSE)
  expect_equal(nrow(out$data), 2)  # Should exclude negative count
  expect_false("B" %in% out$data$group)  # Group B should be excluded
})

test_that("plot_pie() calculates percentages correctly", {
  df <- data.frame(group = c("A", "B"), count = c(25, 75))
  out <- plot_pie(df, return_data = TRUE, preview = FALSE)
  # Data is sorted by count in descending order, so B (75) comes first, then A (25)
  expect_equal(out$data$percent, c(75.0, 25.0))
  expect_equal(out$data$group, c("B", "A"))
})

#------------------------------------------------------------------------------
# Error Handling
#------------------------------------------------------------------------------

test_that("plot_pie() throws error for invalid input", {
  expect_error(plot_pie(1234), "at least two unique groups")

  bad_df <- data.frame(a = 1:3)
  expect_error(plot_pie(bad_df, group_col = "a", count_col = "b"))
})

#===============================================================================
# End: test-plot_pie.R
#===============================================================================











