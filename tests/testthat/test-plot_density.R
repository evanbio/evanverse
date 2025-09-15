#===============================================================================
# Test: plot_density()
# File: test-plot_density.R
# Description: Unit tests for the plot_density() function
#===============================================================================

#------------------------------------------------------------------------------
# Setup: Create test data
#------------------------------------------------------------------------------

# Create sample data for testing
test_data <- data.frame(
  value = c(rnorm(50, 10, 2), rnorm(50, 15, 3), rnorm(50, 20, 2)),
  group = rep(c("A", "B", "C"), each = 50),
  facet_var = rep(c("X", "Y"), each = 75),
  stringsAsFactors = FALSE
)

test_data_numeric <- data.frame(
  numeric_var = rnorm(100),
  category = sample(c("Type1", "Type2"), 100, replace = TRUE)
)

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("plot_density() creates a ggplot object", {
  p <- plot_density(test_data, x = "value")
  expect_s3_class(p, "ggplot")
})

test_that("plot_density() works with group parameter", {
  p <- plot_density(test_data, x = "value", group = "group")
  expect_s3_class(p, "ggplot")
})

test_that("plot_density() works with facet parameter", {
  p <- plot_density(test_data, x = "value", facet = "facet_var")
  expect_s3_class(p, "ggplot")
})

test_that("plot_density() works with both group and facet", {
  p <- plot_density(test_data, x = "value", group = "group", facet = "facet_var")
  expect_s3_class(p, "ggplot")
})

test_that("plot_density() works with histogram", {
  p <- plot_density(test_data, x = "value", add_hist = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("plot_density() works with rug marks", {
  p <- plot_density(test_data, x = "value", add_rug = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("plot_density() works with mean lines", {
  p <- plot_density(test_data, x = "value", show_mean = TRUE)
  expect_s3_class(p, "ggplot")
})

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("plot_density() validates data parameter", {
  expect_error(plot_density(NULL, x = "value"), "`data` must be a data.frame")
  expect_error(plot_density(list(a = 1, b = 2), x = "value"), "`data` must be a data.frame")
  expect_error(plot_density(data.frame(), x = "value"), "`data` must contain at least one row")
})

test_that("plot_density() validates x parameter", {
  expect_error(plot_density(test_data, x = NULL), "`x` must be a single non-empty character string")
  expect_error(plot_density(test_data, x = 123), "`x` must be a single non-empty character string")
  expect_error(plot_density(test_data, x = c("value", "group")), "`x` must be a single non-empty character string")
  expect_error(plot_density(test_data, x = ""), "`x` must be a single non-empty character string")
  expect_error(plot_density(test_data, x = "nonexistent"), "Column `nonexistent` not found")
  expect_error(plot_density(test_data, x = "group"), "Column `group` must contain numeric values")
})

test_that("plot_density() validates group parameter", {
  expect_error(plot_density(test_data, x = "value", group = 123), "`group` must be a single non-empty character string")
  expect_error(plot_density(test_data, x = "value", group = c("group1", "group2")), "`group` must be a single non-empty character string")
  expect_error(plot_density(test_data, x = "value", group = ""), "`group` must be a single non-empty character string")
  expect_error(plot_density(test_data, x = "value", group = "nonexistent"), "Column `nonexistent` not found")
})

test_that("plot_density() validates facet parameter", {
  expect_error(plot_density(test_data, x = "value", facet = 123), "`facet` must be a single non-empty character string")
  expect_error(plot_density(test_data, x = "value", facet = c("facet1", "facet2")), "`facet` must be a single non-empty character string")
  expect_error(plot_density(test_data, x = "value", facet = ""), "`facet` must be a single non-empty character string")
  expect_error(plot_density(test_data, x = "value", facet = "nonexistent"), "Column `nonexistent` not found")
})

test_that("plot_density() validates palette parameter", {
  expect_error(plot_density(test_data, x = "value", palette = "Set1"), "`palette` must be a color vector, not a palette name")
  expect_error(plot_density(test_data, x = "value", palette = character(0)), "`palette` must be a non-empty character vector")
  expect_error(plot_density(test_data, x = "value", palette = c("#FF0000", NA)), "`palette` must be a non-empty character vector")
})

test_that("plot_density() validates numeric parameters", {
  expect_error(plot_density(test_data, x = "value", alpha = "invalid"), "`alpha` must be a single numeric value between 0 and 1")
  expect_error(plot_density(test_data, x = "value", alpha = -0.5), "`alpha` must be a single numeric value between 0 and 1")
  expect_error(plot_density(test_data, x = "value", alpha = 1.5), "`alpha` must be a single numeric value between 0 and 1")
  expect_error(plot_density(test_data, x = "value", base_size = "invalid"), "`base_size` must be a single positive numeric value")
  expect_error(plot_density(test_data, x = "value", base_size = -1), "`base_size` must be a single positive numeric value")
  expect_error(plot_density(test_data, x = "value", adjust = "invalid"), "`adjust` must be a single positive numeric value")
  expect_error(plot_density(test_data, x = "value", adjust = 0), "`adjust` must be a single positive numeric value")
})

test_that("plot_density() validates logical parameters", {
  expect_error(plot_density(test_data, x = "value", show_mean = "yes"), "`show_mean` must be a single logical value")
  expect_error(plot_density(test_data, x = "value", add_hist = "yes"), "`add_hist` must be a single logical value")
  expect_error(plot_density(test_data, x = "value", add_rug = "yes"), "`add_rug` must be a single logical value")
})

test_that("plot_density() validates hist_bins parameter", {
  expect_error(plot_density(test_data, x = "value", add_hist = TRUE, hist_bins = "invalid"), "`hist_bins` must be a single positive integer")
  expect_error(plot_density(test_data, x = "value", add_hist = TRUE, hist_bins = -1), "`hist_bins` must be a single positive integer")
  expect_error(plot_density(test_data, x = "value", add_hist = TRUE, hist_bins = 1.5), "`hist_bins` must be a single positive integer")
})

test_that("plot_density() validates theme parameter", {
  expect_error(plot_density(test_data, x = "value", theme = "invalid"), "`theme` must be one of")
  expect_error(plot_density(test_data, x = "value", theme = 123), "`theme` must be one of")
})

test_that("plot_density() validates legend_pos parameter", {
  expect_error(plot_density(test_data, x = "value", legend_pos = "invalid"), "`legend_pos` must be one of")
  expect_error(plot_density(test_data, x = "value", legend_pos = 123), "`legend_pos` must be one of")
})

#------------------------------------------------------------------------------
# Advanced Functionality Tests
#------------------------------------------------------------------------------

test_that("plot_density() handles different themes", {
  themes <- c("minimal", "classic", "bw", "light", "dark")
  for (theme_name in themes) {
    p <- plot_density(test_data, x = "value", theme = theme_name)
    expect_s3_class(p, "ggplot")
  }
})

test_that("plot_density() handles palette recycling", {
  # Fewer colors than groups
  p <- plot_density(test_data, x = "value", group = "group", palette = c("#FF0000", "#00FF00"))
  expect_s3_class(p, "ggplot")

  # More colors than groups
  p <- plot_density(test_data, x = "value", group = "group", palette = c("#FF0000", "#00FF00", "#0000FF", "#FFFF00"))
  expect_s3_class(p, "ggplot")
})

test_that("plot_density() handles mean lines with groups", {
  p <- plot_density(test_data, x = "value", group = "group", show_mean = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("plot_density() handles histogram with groups", {
  p <- plot_density(test_data, x = "value", group = "group", add_hist = TRUE, hist_bins = 20)
  expect_s3_class(p, "ggplot")
})

#------------------------------------------------------------------------------
# Edge Cases and Special Scenarios
#------------------------------------------------------------------------------

test_that("plot_density() handles single group", {
  single_group_data <- data.frame(value = rnorm(50), group = rep("A", 50))
  p <- plot_density(single_group_data, x = "value", group = "group")
  expect_s3_class(p, "ggplot")
})

test_that("plot_density() handles data with NA values", {
  data_with_na <- test_data
  data_with_na$value[1:10] <- NA
  p <- plot_density(data_with_na, x = "value")
  expect_s3_class(p, "ggplot")
})

test_that("plot_density() handles custom mean line color", {
  p <- plot_density(test_data, x = "value", show_mean = TRUE, mean_line_color = "blue")
  expect_s3_class(p, "ggplot")
})

#===============================================================================
# End: test-plot_density.R
#===============================================================================
