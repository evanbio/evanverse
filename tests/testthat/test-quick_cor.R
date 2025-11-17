#===============================================================================
# Test: quick_cor()
# File: test-quick_cor.R
# Description: Unit tests for the quick_cor() function
#===============================================================================

#------------------------------------------------------------------------------
# Setup: Create test data
#------------------------------------------------------------------------------

# Set seed for reproducibility
set.seed(123)

# Standard test data with multiple numeric columns
test_data_normal <- data.frame(
  var1 = rnorm(50, mean = 10, sd = 2),
  var2 = rnorm(50, mean = 15, sd = 3),
  var3 = rnorm(50, mean = 20, sd = 4),
  var4 = rnorm(50, mean = 25, sd = 5),
  stringsAsFactors = FALSE
)

# Add correlated variables
test_data_normal$var5 <- test_data_normal$var1 * 0.8 + rnorm(50, 0, 1)

# Data with some missing values
test_data_na <- test_data_normal
test_data_na$var1[1:5] <- NA
test_data_na$var2[6:10] <- NA

# Data with a constant variable
test_data_constant <- test_data_normal
test_data_constant$constant_var <- 5

# Small sample data
test_data_small <- data.frame(
  x = rnorm(4, 10, 2),
  y = rnorm(4, 15, 3),
  z = rnorm(4, 20, 4)
)

# Mixed data types
test_data_mixed <- test_data_normal
test_data_mixed$category <- sample(c("A", "B", "C"), 50, replace = TRUE)

# mtcars subset for real-world example
mtcars_subset <- mtcars[, c("mpg", "hp", "wt", "qsec")]

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("quick_cor() creates a quick_cor_result object", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, verbose = FALSE)
  expect_s3_class(result, "quick_cor_result")
})

test_that("quick_cor() returns all expected components", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, verbose = FALSE)

  expect_true("plot" %in% names(result))
  expect_true("cor_matrix" %in% names(result))
  expect_true("p_matrix" %in% names(result))
  expect_true("method_used" %in% names(result))
  expect_true("significant_pairs" %in% names(result))
  expect_true("descriptive_stats" %in% names(result))
  expect_true("parameters" %in% names(result))
  expect_true("timestamp" %in% names(result))
})

test_that("quick_cor() plot is a ggplot object", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, verbose = FALSE)
  expect_s3_class(result$plot, "gg")
  expect_s3_class(result$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Correlation Method Tests
#------------------------------------------------------------------------------

test_that("quick_cor() computes Pearson correlation correctly", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, method = "pearson", verbose = FALSE)

  expect_equal(result$method_used, "pearson")
  expect_true(is.matrix(result$cor_matrix))

  # Check diagonal is 1 (self-correlation)
  expect_true(all(abs(diag(result$cor_matrix) - 1) < 1e-10))

  # Check symmetry
  expect_true(all(abs(result$cor_matrix - t(result$cor_matrix)) < 1e-10))

  # Check correlation range [-1, 1]
  expect_true(all(result$cor_matrix >= -1 & result$cor_matrix <= 1))
})

test_that("quick_cor() computes Spearman correlation correctly", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, method = "spearman", verbose = FALSE)

  expect_equal(result$method_used, "spearman")
  expect_true(is.matrix(result$cor_matrix))
  expect_true(all(abs(diag(result$cor_matrix) - 1) < 1e-10))
})

test_that("quick_cor() computes Kendall correlation correctly", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, method = "kendall", verbose = FALSE)

  expect_equal(result$method_used, "kendall")
  expect_true(is.matrix(result$cor_matrix))
  expect_true(all(abs(diag(result$cor_matrix) - 1) < 1e-10))
})

#------------------------------------------------------------------------------
# P-value and Significance Tests
#------------------------------------------------------------------------------

test_that("quick_cor() computes p-values correctly", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, verbose = FALSE)

  expect_true(is.matrix(result$p_matrix))
  expect_equal(dim(result$p_matrix), dim(result$cor_matrix))

  # Diagonal should be NA (self-correlation p-value is meaningless)
  expect_true(all(is.na(diag(result$p_matrix))))

  # P-values should be between 0 and 1 (excluding NA)
  p_vals <- result$p_matrix[!is.na(result$p_matrix)]
  expect_true(all(p_vals >= 0 & p_vals <= 1))
})

test_that("quick_cor() identifies significant pairs correctly", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, verbose = FALSE)

  expect_true(is.data.frame(result$significant_pairs))
  expect_true(all(c("var1", "var2", "correlation", "p_value") %in%
                    names(result$significant_pairs)))

  # All significant pairs should have p < max(sig_level)
  if (nrow(result$significant_pairs) > 0) {
    expect_true(all(result$significant_pairs$p_value < 0.05))
  }
})

test_that("quick_cor() applies p-value adjustment correctly", {
  skip_if_not_installed("ggcorrplot")
  result_bonf <- quick_cor(test_data_normal,
                           p_adjust_method = "bonferroni",
                           verbose = FALSE)

  expect_false(is.null(result_bonf$p_adjusted))
  expect_true(is.matrix(result_bonf$p_adjusted))

  # Adjusted p-values should be >= original p-values
  orig <- result_bonf$p_matrix[upper.tri(result_bonf$p_matrix)]
  adj <- result_bonf$p_adjusted[upper.tri(result_bonf$p_adjusted)]
  non_na <- !is.na(orig) & !is.na(adj)
  expect_true(all(adj[non_na] >= orig[non_na] - 1e-10))
})

test_that("quick_cor() p_adjusted has NA diagonal", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal,
                      p_adjust_method = "bonferroni",
                      verbose = FALSE)

  expect_true(all(is.na(diag(result$p_adjusted))))
})

#------------------------------------------------------------------------------
# Variable Selection Tests
#------------------------------------------------------------------------------

test_that("quick_cor() auto-selects numeric columns", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_mixed, verbose = FALSE)

  # Should have excluded the categorical variable
  expect_equal(ncol(result$cor_matrix), 5)
  expect_false("category" %in% colnames(result$cor_matrix))
})

test_that("quick_cor() accepts vars parameter", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal,
                      vars = c("var1", "var2", "var3"),
                      verbose = FALSE)

  expect_equal(ncol(result$cor_matrix), 3)
  expect_true(all(c("var1", "var2", "var3") %in% colnames(result$cor_matrix)))
})

test_that("quick_cor() removes constant variables with warning", {
  skip_if_not_installed("ggcorrplot")
  expect_message(
    result <- quick_cor(test_data_constant, verbose = TRUE),
    "constant"
  )

  # constant_var should be removed
  expect_false("constant_var" %in% colnames(result$cor_matrix))
})

#------------------------------------------------------------------------------
# Heatmap Type Tests
#------------------------------------------------------------------------------

test_that("quick_cor() creates full heatmap", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, type = "full", verbose = FALSE)
  expect_equal(result$parameters$type, "full")
})

test_that("quick_cor() creates upper triangular heatmap", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, type = "upper", verbose = FALSE)
  expect_equal(result$parameters$type, "upper")
})

test_that("quick_cor() creates lower triangular heatmap", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, type = "lower", verbose = FALSE)
  expect_equal(result$parameters$type, "lower")
})

#------------------------------------------------------------------------------
# Show Coefficient and Significance Tests
#------------------------------------------------------------------------------

test_that("quick_cor() show_coef and show_sig are mutually exclusive", {
  skip_if_not_installed("ggcorrplot")

  # When both are TRUE, show_sig should be set to FALSE with warning
  expect_message(
    result <- quick_cor(test_data_normal,
                       show_coef = TRUE,
                       show_sig = TRUE,
                       verbose = TRUE),
    "show_sig"
  )

  # Result should still be valid
  expect_s3_class(result, "quick_cor_result")
})

test_that("quick_cor() respects show_coef parameter", {
  skip_if_not_installed("ggcorrplot")
  result_no_coef <- quick_cor(test_data_normal, show_coef = FALSE, verbose = FALSE)
  result_with_coef <- quick_cor(test_data_normal, show_coef = TRUE, verbose = FALSE)

  expect_s3_class(result_no_coef$plot, "ggplot")
  expect_s3_class(result_with_coef$plot, "ggplot")
})

test_that("quick_cor() respects show_sig parameter", {
  skip_if_not_installed("ggcorrplot")
  result_no_sig <- quick_cor(test_data_normal, show_sig = FALSE, verbose = FALSE)
  result_with_sig <- quick_cor(test_data_normal, show_sig = TRUE, verbose = FALSE)

  expect_s3_class(result_no_sig$plot, "ggplot")
  expect_s3_class(result_with_sig$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Axis Label Tests
#------------------------------------------------------------------------------

test_that("quick_cor() respects axis label parameters", {
  skip_if_not_installed("ggcorrplot")

  result <- quick_cor(test_data_normal,
                      show_axis_x = FALSE,
                      show_axis_y = TRUE,
                      axis_x_angle = 90,
                      axis_y_angle = 0,
                      axis_text_size = 12,
                      verbose = FALSE)

  expect_s3_class(result$plot, "ggplot")
})

test_that("quick_cor() handles different axis angles", {
  skip_if_not_installed("ggcorrplot")

  # Test various angles
  for (angle in c(0, 45, 90)) {
    result <- quick_cor(test_data_normal,
                       axis_x_angle = angle,
                       verbose = FALSE)
    expect_s3_class(result$plot, "ggplot")
  }
})

#------------------------------------------------------------------------------
# Edge Cases and Error Handling
#------------------------------------------------------------------------------

test_that("quick_cor() handles missing values correctly", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_na, verbose = FALSE)

  expect_s3_class(result, "quick_cor_result")
  expect_true(is.matrix(result$cor_matrix))

  # With pairwise.complete.obs, should still have correlations
  expect_true(all(abs(diag(result$cor_matrix) - 1) < 1e-10))
})

test_that("quick_cor() fails with non-data.frame input", {
  expect_error(
    quick_cor(as.matrix(test_data_normal)),
    "must be a data frame"
  )
})

test_that("quick_cor() fails with no numeric columns", {
  df_no_numeric <- data.frame(
    a = letters[1:10],
    b = LETTERS[1:10],
    stringsAsFactors = FALSE
  )
  expect_error(
    quick_cor(df_no_numeric),
    "No numeric columns"
  )
})

test_that("quick_cor() fails with only one numeric column", {
  df_one_col <- data.frame(x = rnorm(10))
  expect_error(
    quick_cor(df_one_col),
    "At least 2"
  )
})

test_that("quick_cor() fails with non-existent vars", {
  expect_error(
    quick_cor(test_data_normal, vars = c("var1", "nonexistent")),
    "not found"
  )
})

test_that("quick_cor() fails with non-numeric vars", {
  expect_error(
    quick_cor(test_data_mixed, vars = c("var1", "category")),
    "must be numeric"
  )
})

test_that("quick_cor() warns with small sample size", {
  skip_if_not_installed("ggcorrplot")
  expect_message(
    quick_cor(test_data_small, verbose = TRUE),
    "small sample size"
  )
})

#------------------------------------------------------------------------------
# S3 Method Tests
#------------------------------------------------------------------------------

test_that("print.quick_cor_result works", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, verbose = FALSE)

  # Should not error
  expect_output(print(result))
})

test_that("summary.quick_cor_result works", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, verbose = FALSE)

  # Should not error
  expect_error(summary(result), NA)

  # Verify the object has necessary components for summary
  expect_true(!is.null(result$method_used))
  expect_true(!is.null(result$cor_matrix))
  expect_true(!is.null(result$parameters))
})

test_that("summary.quick_cor_result shows adjustment info", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal,
                      p_adjust_method = "bonferroni",
                      verbose = FALSE)

  # Check that p_adjust_method is stored correctly
  expect_equal(result$parameters$p_adjust_method, "bonferroni")

  # Summary should work without error
  expect_error(summary(result), NA)
})

#------------------------------------------------------------------------------
# Descriptive Statistics Tests
#------------------------------------------------------------------------------

test_that("quick_cor() computes descriptive statistics", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, verbose = FALSE)

  expect_true(is.data.frame(result$descriptive_stats))
  expect_true(all(c("variable", "n", "mean", "sd", "median", "min", "max") %in%
                    names(result$descriptive_stats)))
  expect_equal(nrow(result$descriptive_stats), ncol(result$cor_matrix))
})

#------------------------------------------------------------------------------
# Real-world Example Tests
#------------------------------------------------------------------------------

test_that("quick_cor() works with mtcars data", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(mtcars_subset, verbose = FALSE)

  expect_s3_class(result, "quick_cor_result")
  expect_equal(ncol(result$cor_matrix), 4)

  # mpg and wt should be negatively correlated
  mpg_wt_cor <- result$cor_matrix["mpg", "wt"]
  expect_true(mpg_wt_cor < 0)
})

test_that("quick_cor() works with iris data", {
  skip_if_not_installed("ggcorrplot")
  iris_numeric <- iris[, 1:4]
  result <- quick_cor(iris_numeric, verbose = FALSE)

  expect_s3_class(result, "quick_cor_result")
  expect_equal(ncol(result$cor_matrix), 4)
})

#------------------------------------------------------------------------------
# Clustering Tests
#------------------------------------------------------------------------------

test_that("quick_cor() respects hc_order parameter", {
  skip_if_not_installed("ggcorrplot")
  result_no_hc <- quick_cor(test_data_normal, hc_order = FALSE, verbose = FALSE)
  result_with_hc <- quick_cor(test_data_normal, hc_order = TRUE, verbose = FALSE)

  expect_equal(result_no_hc$parameters$hc_order, FALSE)
  expect_equal(result_with_hc$parameters$hc_order, TRUE)
})

#------------------------------------------------------------------------------
# Palette Tests
#------------------------------------------------------------------------------

test_that("quick_cor() accepts custom palette", {
  skip_if_not_installed("ggcorrplot")
  custom_title <- "My Custom Correlation Plot"
  result <- quick_cor(test_data_normal,
                      palette = "piyg",
                      title = custom_title,
                      verbose = FALSE)

  expect_s3_class(result$plot, "ggplot")
  # Title should be in the plot
  expect_true(!is.null(result$plot$labels$title))
  expect_equal(result$plot$labels$title, custom_title)
})

test_that("quick_cor() works with NULL palette", {
  skip_if_not_installed("ggcorrplot")
  result <- quick_cor(test_data_normal, palette = NULL, verbose = FALSE)
  expect_s3_class(result$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("quick_cor() validates sig_level parameter", {
  expect_error(
    quick_cor(test_data_normal, sig_level = c(-0.1, 0.05)),
    "sig_level"
  )

  expect_error(
    quick_cor(test_data_normal, sig_level = c(0.05, 1.5)),
    "sig_level"
  )
})

test_that("quick_cor() validates verbose parameter", {
  expect_error(
    quick_cor(test_data_normal, verbose = "yes"),
    "verbose"
  )
})

test_that("quick_cor() validates show_coef parameter", {
  expect_error(
    quick_cor(test_data_normal, show_coef = "yes"),
    "show_coef"
  )
})
