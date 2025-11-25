#===============================================================================
# Test: plot_forest()
# File: test-plot_forest.R
# Description: Unit tests for the plot_forest() function
#===============================================================================

#------------------------------------------------------------------------------
# Setup: Create test data
#------------------------------------------------------------------------------

# Set seed for reproducibility
set.seed(123)

# Basic forest plot data (single-model)
test_data_single <- data.frame(
  Variable = c("Age", "BMI", "Sex", "Male", "Female"),
  ` ` = rep(strrep(" ", 20), 5),
  `OR (95% CI)` = c("1.28 (1.15-1.43)", "1.05 (1.02-1.09)",
                     "", "1.42 (1.10-1.83)", "0.88 (0.65-1.18)"),
  `P` = c("0.001", "0.003", "", "0.007", "0.380"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

test_est_single <- c(1.28, 1.05, NA, 1.42, 0.88)
test_lower_single <- c(1.15, 1.02, NA, 1.10, 0.65)
test_upper_single <- c(1.43, 1.09, NA, 1.83, 1.18)

# Multi-model data (three models)
test_data_multi <- data.frame(
  Variable = c("Hypertension", "Diabetes", "Inactivity"),
  ` ` = rep(strrep(" ", 15), 3),
  `Model 1` = c("1.85 (1.42-2.41)", "2.12 (1.58-2.84)", "1.42 (1.08-1.87)"),
  `Model 2` = c("1.72 (1.32-2.24)", "1.95 (1.45-2.62)", "1.35 (1.03-1.77)"),
  `Model 3` = c("1.58 (1.20-2.08)", "1.78 (1.31-2.42)", "1.28 (0.97-1.69)"),
  stringsAsFactors = FALSE,
  check.names = FALSE
)

test_est_multi <- list(
  c(1.85, 2.12, 1.42),
  c(1.72, 1.95, 1.35),
  c(1.58, 1.78, 1.28)
)
test_lower_multi <- list(
  c(1.42, 1.58, 1.08),
  c(1.32, 1.45, 1.03),
  c(1.20, 1.31, 0.97)
)
test_upper_multi <- list(
  c(2.41, 2.84, 1.87),
  c(2.24, 2.62, 1.77),
  c(2.08, 2.42, 1.69)
)

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("plot_forest() creates a gtable object", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() works with single-model data", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    ref_line = 1,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
  expect_true(length(result$heights) > 0)
  expect_true(length(result$widths) > 0)
})

test_that("plot_forest() works with multi-model data", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_multi,
    est = test_est_multi,
    lower = test_lower_multi,
    upper = test_upper_multi,
    ci_column = 2,
    ref_line = 1,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() handles NA values in estimates", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  # test_data_single already contains NA in row 3
  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("plot_forest() requires data parameter", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  expect_error(
    plot_forest(
      est = list(test_est_single),
      lower = list(test_lower_single),
      upper = list(test_upper_single),
      ci_column = 2
    ),
    "argument \"data\" is missing"
  )
})

test_that("plot_forest() requires est parameter", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  expect_error(
    plot_forest(
      data = test_data_single,
      lower = list(test_lower_single),
      upper = list(test_upper_single),
      ci_column = 2
    ),
    "argument \"est\" is missing"
  )
})

test_that("plot_forest() requires ci_column parameter", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  expect_error(
    plot_forest(
      data = test_data_single,
      est = list(test_est_single),
      lower = list(test_lower_single),
      upper = list(test_upper_single)
    ),
    "argument \"ci_column\" is missing"
  )
})

#------------------------------------------------------------------------------
# Theme and Styling Tests
#------------------------------------------------------------------------------

test_that("plot_forest() applies default theme", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    theme_preset = "default",
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() accepts custom theme parameters", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    theme_custom = list(base_size = 14, ci_pch = 16),
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() applies text alignment", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    align_left = 1,
    align_center = c(2, 3, 4),
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() applies bold formatting to groups", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    bold_group = c("Sex"),
    bold_group_col = 1,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() applies bold formatting to p-values", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    bold_pvalue_cols = 4,
    p_threshold = 0.05,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

#------------------------------------------------------------------------------
# Background and Color Tests
#------------------------------------------------------------------------------

test_that("plot_forest() applies zebra background", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    background_style = "zebra",
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() applies group background", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    background_style = "group",
    background_group_rows = c(3),
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() applies CI colors - single color", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    ci_colors = "#E64B35",
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() applies CI colors - vector", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  colors <- c("#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    ci_colors = colors,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

#------------------------------------------------------------------------------
# Border Tests
#------------------------------------------------------------------------------

test_that("plot_forest() adds simple borders", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    add_borders = TRUE,
    border_width = 3,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() works without borders", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    add_borders = FALSE,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

#------------------------------------------------------------------------------
# Layout Adjustment Tests
#------------------------------------------------------------------------------

test_that("plot_forest() applies default layout adjustments", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    height_top = 8,
    height_header = 12,
    height_main = 10,
    height_bottom = 8,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
  expect_true(length(result$heights) > 0)
})

test_that("plot_forest() applies custom height adjustments", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    height_custom = list('1' = 10, '2' = 15),
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() applies custom width adjustments", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    width_custom = list('2' = 50, '3' = 60),
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() respects layout_verbose parameter", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  # verbose = FALSE should not print layout info
  result_quiet <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    layout_verbose = FALSE
  )
  expect_s3_class(result_quiet, "gtable")

  # verbose = TRUE should print layout info
  result_verbose <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    layout_verbose = TRUE
  )
  expect_s3_class(result_verbose, "gtable")
})

#------------------------------------------------------------------------------
# Auto-generation Features Tests
#------------------------------------------------------------------------------

test_that("plot_forest() auto-generates ticks when only xlim provided", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    xlim = c(0.5, 2.5),
    ticks_at = NULL,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() respects provided ticks_at", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    xlim = c(0.5, 2.5),
    ticks_at = c(0.5, 1, 1.5, 2, 2.5),
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

#------------------------------------------------------------------------------
# Multi-group Positioning Tests
#------------------------------------------------------------------------------

test_that("plot_forest() applies nudge_y for multi-group spacing", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_multi,
    est = test_est_multi,
    lower = test_lower_multi,
    upper = test_upper_multi,
    ci_column = 2,
    nudge_y = 0.2,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() works with custom nudge_y", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_multi,
    est = test_est_multi,
    lower = test_lower_multi,
    upper = test_upper_multi,
    ci_column = 2,
    nudge_y = 0.3,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

#------------------------------------------------------------------------------
# Sizes Parameter Tests
#------------------------------------------------------------------------------

test_that("plot_forest() accepts single size value", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    sizes = 0.8,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() accepts size vector matching row count", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  # Must match the number of rows in data
  sizes_vec <- rep(0.6, nrow(test_data_single))

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    sizes = sizes_vec,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

#------------------------------------------------------------------------------
# Arrow Labels Tests
#------------------------------------------------------------------------------

test_that("plot_forest() accepts arrow labels", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    arrow_lab = c("Lower Risk", "Higher Risk"),
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() works without arrow labels", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    arrow_lab = NULL,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

#------------------------------------------------------------------------------
# File Saving Tests
#------------------------------------------------------------------------------

test_that("plot_forest() saves plot when save_plot = TRUE", {
  skip_on_cran()
  skip_if_not_installed("forestploter")
  skip_if_not_installed("ggplot2")

  temp_dir <- tempdir()

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    save_plot = TRUE,
    filename = "test_forest",
    save_path = temp_dir,
    save_formats = "png",
    save_width = 20,
    save_height = 15,
    save_verbose = FALSE,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
  expect_true(file.exists(file.path(temp_dir, "test_forest.png")))

  # Clean up
  unlink(file.path(temp_dir, "test_forest.png"))
})

test_that("plot_forest() saves multiple formats", {
  skip_on_cran()
  skip_if_not_installed("forestploter")
  skip_if_not_installed("ggplot2")

  temp_dir <- tempdir()

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    save_plot = TRUE,
    filename = "test_forest_multi",
    save_path = temp_dir,
    save_formats = c("png", "pdf"),
    save_verbose = FALSE,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
  expect_true(file.exists(file.path(temp_dir, "test_forest_multi.png")))
  expect_true(file.exists(file.path(temp_dir, "test_forest_multi.pdf")))

  # Clean up
  unlink(file.path(temp_dir, "test_forest_multi.png"))
  unlink(file.path(temp_dir, "test_forest_multi.pdf"))
})

#------------------------------------------------------------------------------
# Integration Tests
#------------------------------------------------------------------------------

test_that("plot_forest() end-to-end workflow with full customization", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    ref_line = 1,
    xlim = c(0.5, 2.5),
    arrow_lab = c("Protective", "Risk"),
    sizes = 0.6,
    nudge_y = 0.2,
    theme_preset = "default",
    align_left = 1,
    align_center = c(2, 3, 4),
    bold_pvalue_cols = 4,
    p_threshold = 0.05,
    background_style = "zebra",
    ci_colors = "#E64B35",
    add_borders = TRUE,
    border_width = 3,
    height_main = 10,
    height_bottom = 8,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
  expect_true(length(result$heights) > 0)
  expect_true(length(result$widths) > 0)
})

test_that("plot_forest() end-to-end workflow with multi-model data", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_multi,
    est = test_est_multi,
    lower = test_lower_multi,
    upper = test_upper_multi,
    ci_column = 2,
    ref_line = 1,
    xlim = c(0.5, 3),
    sizes = 0.6,
    nudge_y = 0.2,
    add_borders = TRUE,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
  expect_true(length(result$heights) >= nrow(test_data_multi))
})

#------------------------------------------------------------------------------
# Edge Cases and Special Scenarios
#------------------------------------------------------------------------------

test_that("plot_forest() handles minimal parameters", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() handles all NA row", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  # Row 3 in test_data_single has all NAs
  result <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    layout_verbose = FALSE
  )

  expect_s3_class(result, "gtable")
})

test_that("plot_forest() handles different ref_line values", {
  skip_on_cran()
  skip_if_not_installed("forestploter")

  # OR scale (ref = 1)
  result_or <- plot_forest(
    data = test_data_single,
    est = list(test_est_single),
    lower = list(test_lower_single),
    upper = list(test_upper_single),
    ci_column = 2,
    ref_line = 1,
    layout_verbose = FALSE
  )
  expect_s3_class(result_or, "gtable")

  # Mean difference scale (ref = 0)
  result_md <- plot_forest(
    data = test_data_single,
    est = list(test_est_single - 1),  # Shift to center at 0
    lower = list(test_lower_single - 1),
    upper = list(test_upper_single - 1),
    ci_column = 2,
    ref_line = 0,
    layout_verbose = FALSE
  )
  expect_s3_class(result_md, "gtable")
})

#===============================================================================
# End: test-plot_forest.R
#===============================================================================

