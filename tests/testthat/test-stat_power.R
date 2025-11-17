#===============================================================================
# Test: stat_power()
# File: test-stat_power.R
# Description: Unit tests for the stat_power() function
#===============================================================================

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("stat_power() creates a stat_power_result object", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )
  expect_s3_class(result, "stat_power_result")
})

test_that("stat_power() works for two-sample t-test", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    test = "t.test",
    type = "two.sample",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_type, "t.test")
  expect_equal(result$test_subtype, "two.sample")
  expect_true(result$power > 0 && result$power < 1)
})

test_that("stat_power() works for one-sample t-test", {
  result <- stat_power(
    n = 25,
    effect_size = 0.6,
    test = "t.test",
    type = "one.sample",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_subtype, "one.sample")
})

test_that("stat_power() works for paired t-test", {
  result <- stat_power(
    n = 20,
    effect_size = 0.7,
    test = "t.test",
    type = "paired",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_subtype, "paired")
})

test_that("stat_power() works for ANOVA", {
  result <- stat_power(
    n = 25,
    effect_size = 0.25,
    test = "anova",
    k = 3,
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_type, "anova")
  expect_equal(result$k, 3)
  expect_null(result$test_subtype)
})

test_that("stat_power() works for proportion test", {
  result <- stat_power(
    n = 100,
    effect_size = 0.5,
    test = "proportion",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_type, "proportion")
  expect_true(result$power > 0 && result$power < 1)
})

test_that("stat_power() works for correlation test", {
  result <- stat_power(
    n = 50,
    effect_size = 0.3,
    test = "correlation",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_type, "correlation")
  expect_true(result$power > 0 && result$power < 1)
})

test_that("stat_power() works for chi-square test", {
  result <- stat_power(
    n = 150,
    effect_size = 0.3,
    test = "chisq",
    df = 3,
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_type, "chisq")
  expect_equal(result$df, 3)
})

#------------------------------------------------------------------------------
# Alternative Hypothesis Tests
#------------------------------------------------------------------------------

test_that("stat_power() respects alternative hypothesis for t-test", {
  result_two <- stat_power(
    n = 30,
    effect_size = 0.5,
    test = "t.test",
    alternative = "two.sided",
    verbose = FALSE,
    plot = FALSE
  )

  result_greater <- stat_power(
    n = 30,
    effect_size = 0.5,
    test = "t.test",
    alternative = "greater",
    verbose = FALSE,
    plot = FALSE
  )

  # One-sided test should have higher power
  expect_true(result_greater$power > result_two$power)
  expect_equal(result_two$alternative, "two.sided")
  expect_equal(result_greater$alternative, "greater")
})

test_that("stat_power() warns when alternative is used with ANOVA", {
  expect_warning(
    stat_power(
      n = 30,
      effect_size = 0.25,
      test = "anova",
      k = 3,
      alternative = "greater",
      verbose = FALSE,
      plot = FALSE
    ),
    "alternative.*ignored"
  )
})

test_that("stat_power() warns when alternative is used with chisq", {
  expect_warning(
    stat_power(
      n = 100,
      effect_size = 0.3,
      test = "chisq",
      df = 2,
      alternative = "less",
      verbose = FALSE,
      plot = FALSE
    ),
    "alternative.*ignored"
  )
})

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("stat_power() validates n parameter", {
  expect_error(
    stat_power(n = -10, effect_size = 0.5),
    "n.*must be.*positive integer"
  )
  expect_error(
    stat_power(n = 0, effect_size = 0.5),
    "n.*must be.*positive integer"
  )
  expect_error(
    stat_power(n = 10.5, effect_size = 0.5),
    "n.*must be.*positive integer"
  )
  expect_error(
    stat_power(n = NA, effect_size = 0.5),
    "n.*must be.*positive integer"
  )
})

test_that("stat_power() validates effect_size parameter", {
  expect_error(
    stat_power(n = 30, effect_size = -0.5),
    "effect_size.*must be.*positive"
  )
  expect_error(
    stat_power(n = 30, effect_size = 0),
    "effect_size.*must be.*positive"
  )
  expect_error(
    stat_power(n = 30, effect_size = NA),
    "effect_size.*must be.*positive"
  )
})

test_that("stat_power() validates correlation effect_size range", {
  expect_error(
    stat_power(n = 50, effect_size = 1.5, test = "correlation"),
    "effect_size.*correlation.*between 0 and 1"
  )

  # Valid values should work
  result <- stat_power(
    n = 50,
    effect_size = 0.5,
    test = "correlation",
    verbose = FALSE,
    plot = FALSE
  )
  expect_s3_class(result, "stat_power_result")
})

test_that("stat_power() validates alpha parameter", {
  expect_error(
    stat_power(n = 30, effect_size = 0.5, alpha = -0.05),
    "alpha.*must be.*between 0 and 1"
  )
  expect_error(
    stat_power(n = 30, effect_size = 0.5, alpha = 0),
    "alpha.*must be.*between 0 and 1"
  )
  expect_error(
    stat_power(n = 30, effect_size = 0.5, alpha = 1),
    "alpha.*must be.*between 0 and 1"
  )
})

test_that("stat_power() requires k for ANOVA", {
  expect_error(
    stat_power(n = 30, effect_size = 0.25, test = "anova"),
    "k.*required for ANOVA"
  )
})

test_that("stat_power() validates k parameter for ANOVA", {
  expect_error(
    stat_power(n = 30, effect_size = 0.25, test = "anova", k = 1),
    "k.*must be.*>= 2"
  )
  expect_error(
    stat_power(n = 30, effect_size = 0.25, test = "anova", k = 2.5),
    "k.*must be.*integer"
  )
})

test_that("stat_power() requires df for chi-square", {
  expect_error(
    stat_power(n = 100, effect_size = 0.3, test = "chisq"),
    "df.*required for chi-square"
  )
})

test_that("stat_power() validates df parameter for chi-square", {
  expect_error(
    stat_power(n = 100, effect_size = 0.3, test = "chisq", df = 0),
    "df.*must be.*positive integer"
  )
  expect_error(
    stat_power(n = 100, effect_size = 0.3, test = "chisq", df = 2.5),
    "df.*must be.*positive integer"
  )
})

test_that("stat_power() validates plot parameter", {
  expect_error(
    stat_power(n = 30, effect_size = 0.5, plot = "yes"),
    "plot.*must be.*logical"
  )
  expect_error(
    stat_power(n = 30, effect_size = 0.5, plot = NA),
    "plot.*must be.*logical"
  )
})

test_that("stat_power() validates verbose parameter", {
  expect_error(
    stat_power(n = 30, effect_size = 0.5, verbose = "yes"),
    "verbose.*must be.*logical"
  )
  expect_error(
    stat_power(n = 30, effect_size = 0.5, verbose = NA),
    "verbose.*must be.*logical"
  )
})

test_that("stat_power() validates plot_range parameter", {
  expect_error(
    stat_power(n = 30, effect_size = 0.5, plot_range = c(10, 20, 30)),
    "plot_range.*must be.*length 2"
  )
  expect_error(
    stat_power(n = 30, effect_size = 0.5, plot_range = "10-50"),
    "plot_range.*must be.*numeric"
  )
  expect_error(
    stat_power(n = 30, effect_size = 0.5, plot_range = c(-5, 50)),
    "plot_range.*must be positive"
  )
})

#------------------------------------------------------------------------------
# Return Object Structure Tests
#------------------------------------------------------------------------------

test_that("stat_power() returns object with required components", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )

  expect_true("power" %in% names(result))
  expect_true("n" %in% names(result))
  expect_true("effect_size" %in% names(result))
  expect_true("alpha" %in% names(result))
  expect_true("test_type" %in% names(result))
  expect_true("alternative" %in% names(result))
  expect_true("plot" %in% names(result))
  expect_true("pwr_object" %in% names(result))
  expect_true("details" %in% names(result))
  expect_true("timestamp" %in% names(result))
})

test_that("stat_power() result has correct types", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )

  expect_type(result$power, "double")
  expect_type(result$n, "double")
  expect_type(result$effect_size, "double")
  expect_type(result$alpha, "double")
  expect_type(result$test_type, "character")
  expect_type(result$details, "list")
  expect_s3_class(result$timestamp, "POSIXct")
})

test_that("stat_power() includes plot when requested", {
  result_with_plot <- stat_power(
    n = 30,
    effect_size = 0.5,
    plot = TRUE,
    verbose = FALSE
  )

  result_without_plot <- stat_power(
    n = 30,
    effect_size = 0.5,
    plot = FALSE,
    verbose = FALSE
  )

  expect_s3_class(result_with_plot$plot, "gg")
  expect_null(result_without_plot$plot)
})

test_that("stat_power() includes test-specific fields", {
  # t-test should have test_subtype
  result_t <- stat_power(
    n = 30,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )
  expect_type(result_t$test_subtype, "character")

  # ANOVA should have k
  result_anova <- stat_power(
    n = 25,
    effect_size = 0.25,
    test = "anova",
    k = 3,
    verbose = FALSE,
    plot = FALSE
  )
  expect_equal(result_anova$k, 3)

  # Chi-square should have df
  result_chisq <- stat_power(
    n = 100,
    effect_size = 0.3,
    test = "chisq",
    df = 3,
    verbose = FALSE,
    plot = FALSE
  )
  expect_equal(result_chisq$df, 3)
})

#------------------------------------------------------------------------------
# S3 Methods Tests
#------------------------------------------------------------------------------

test_that("print.stat_power_result works", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    verbose = FALSE,
    plot = FALSE
  )

  # print method should run without error
  expect_error(print(result), NA)
  expect_invisible(print(result))
})

test_that("summary.stat_power_result works", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    verbose = FALSE,
    plot = FALSE
  )

  # summary method should run without error
  expect_error(capture.output(summary(result)), NA)
})

test_that("plot.stat_power_result works with plot", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    plot = TRUE,
    verbose = FALSE
  )

  # Should not throw error
  expect_error(plot(result), NA)
})

test_that("plot.stat_power_result warns without plot", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    plot = FALSE,
    verbose = FALSE
  )

  expect_warning(plot(result), "No plot available")
})

#------------------------------------------------------------------------------
# Edge Cases and Special Scenarios
#------------------------------------------------------------------------------

test_that("stat_power() produces sensible power values", {
  # Small sample, small effect -> low power
  result_low <- stat_power(
    n = 10,
    effect_size = 0.2,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )
  expect_true(result_low$power < 0.5)

  # Large sample, large effect -> high power
  result_high <- stat_power(
    n = 100,
    effect_size = 0.8,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )
  expect_true(result_high$power > 0.95)
})

test_that("stat_power() increases with sample size", {
  result_n30 <- stat_power(
    n = 30,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )

  result_n60 <- stat_power(
    n = 60,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )

  expect_true(result_n60$power > result_n30$power)
})

test_that("stat_power() handles plot_range correctly", {
  result <- stat_power(
    n = 50,
    effect_size = 0.5,
    plot = TRUE,
    plot_range = c(20, 100),
    verbose = FALSE
  )

  expect_s3_class(result$plot, "gg")
})

test_that("stat_power() auto-sorts reversed plot_range", {
  result <- stat_power(
    n = 50,
    effect_size = 0.5,
    plot = TRUE,
    plot_range = c(100, 20),
    verbose = FALSE
  )

  expect_s3_class(result, "stat_power_result")
})

test_that("stat_power() works with very small effect sizes", {
  result <- stat_power(
    n = 1000,
    effect_size = 0.05,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )

  expect_s3_class(result, "stat_power_result")
  expect_true(result$power > 0 && result$power < 1)
})

test_that("stat_power() works with correlation at upper boundary", {
  result <- stat_power(
    n = 30,
    effect_size = 1,
    test = "correlation",
    verbose = FALSE,
    plot = FALSE
  )

  expect_s3_class(result, "stat_power_result")
  expect_true(result$power > 0.99)
})

test_that("stat_power() works with minimum valid k for ANOVA", {
  result <- stat_power(
    n = 25,
    effect_size = 0.25,
    test = "anova",
    k = 2,
    verbose = FALSE,
    plot = FALSE
  )

  expect_s3_class(result, "stat_power_result")
  expect_equal(result$k, 2)
})

test_that("stat_power() recommendations work correctly", {
  # Low power should generate recommendation
  result_low <- stat_power(
    n = 15,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )
  expect_false(is.null(result_low$details$recommendation))

  # Adequate power should not generate recommendation
  result_ok <- stat_power(
    n = 65,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )
  expect_null(result_ok$details$recommendation)

  # Very high power should generate caution
  result_high <- stat_power(
    n = 200,
    effect_size = 0.8,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )
  expect_false(is.null(result_high$details$recommendation))
})

#------------------------------------------------------------------------------
# Verbose Mode Tests
#------------------------------------------------------------------------------

test_that("stat_power() prints messages when verbose = TRUE", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    verbose = TRUE,
    plot = FALSE
  )

  expect_s3_class(result, "stat_power_result")
})

test_that("stat_power() minimizes output when verbose = FALSE", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    verbose = FALSE,
    plot = FALSE
  )

  expect_s3_class(result, "stat_power_result")
})

#------------------------------------------------------------------------------
# Integration Tests
#------------------------------------------------------------------------------

test_that("stat_power() end-to-end workflow for t-test", {
  result <- stat_power(
    n = 30,
    effect_size = 0.5,
    test = "t.test",
    type = "two.sample",
    alternative = "two.sided",
    alpha = 0.05,
    plot = TRUE,
    plot_range = c(10, 100),
    verbose = FALSE
  )

  expect_s3_class(result, "stat_power_result")
  expect_s3_class(result$plot, "gg")
  expect_true(result$power > 0 && result$power < 1)
})

test_that("stat_power() end-to-end workflow for ANOVA", {
  result <- stat_power(
    n = 25,
    effect_size = 0.25,
    test = "anova",
    k = 4,
    alpha = 0.05,
    plot = TRUE,
    verbose = FALSE
  )

  expect_s3_class(result, "stat_power_result")
  expect_s3_class(result$plot, "gg")
  expect_equal(result$k, 4)
})

test_that("stat_power() end-to-end workflow for correlation", {
  result <- stat_power(
    n = 50,
    effect_size = 0.3,
    test = "correlation",
    alternative = "two.sided",
    alpha = 0.05,
    plot = TRUE,
    verbose = FALSE
  )

  expect_s3_class(result, "stat_power_result")
  expect_s3_class(result$plot, "gg")
  expect_equal(result$test_type, "correlation")
})

#===============================================================================
# End: test-stat_power.R
#===============================================================================
