#===============================================================================
# Test: stat_samplesize()
# File: test-stat_samplesize.R
# Description: Unit tests for the stat_samplesize() function
#===============================================================================

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("stat_samplesize() creates a stat_samplesize_result object", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )
  expect_s3_class(result, "stat_samplesize_result")
})

test_that("stat_samplesize() works for two-sample t-test", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    type = "two.sample",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_type, "t.test")
  expect_equal(result$test_subtype, "two.sample")
  expect_true(is.numeric(result$n))
  expect_true(result$n > 0)
  expect_equal(result$n_total, result$n * 2)
})

test_that("stat_samplesize() works for one-sample t-test", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.6,
    test = "t.test",
    type = "one.sample",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_subtype, "one.sample")
  expect_equal(result$n_total, result$n)
})

test_that("stat_samplesize() works for paired t-test", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.7,
    test = "t.test",
    type = "paired",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_subtype, "paired")
  expect_equal(result$n_total, result$n)
})

test_that("stat_samplesize() works for ANOVA", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.25,
    test = "anova",
    k = 3,
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_type, "anova")
  expect_equal(result$k, 3)
  expect_null(result$test_subtype)
  expect_equal(result$n_total, result$n * 3)
})

test_that("stat_samplesize() works for proportion test", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "proportion",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_type, "proportion")
  expect_true(result$n > 0)
  expect_equal(result$n_total, result$n)
})

test_that("stat_samplesize() works for correlation test", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.3,
    test = "correlation",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_type, "correlation")
  expect_true(result$n > 0)
  expect_equal(result$n_total, result$n)
})

test_that("stat_samplesize() works for chi-square test", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.3,
    test = "chisq",
    df = 3,
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$test_type, "chisq")
  expect_equal(result$df, 3)
  expect_true(result$n > 0)
  expect_equal(result$n_total, result$n)
})


#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("stat_samplesize() validates power parameter", {
  # power must be between 0 and 1
  expect_error(
    stat_samplesize(power = -0.1, effect_size = 0.5),
    "power.*between 0 and 1"
  )
  expect_error(
    stat_samplesize(power = 1.5, effect_size = 0.5),
    "power.*between 0 and 1"
  )
  expect_error(
    stat_samplesize(power = 0, effect_size = 0.5),
    "power.*between 0 and 1"
  )
  expect_error(
    stat_samplesize(power = 1, effect_size = 0.5),
    "power.*between 0 and 1"
  )

  # power must be numeric
  expect_error(
    stat_samplesize(power = "0.8", effect_size = 0.5),
    "power.*numeric"
  )

  # power must be single value
  expect_error(
    stat_samplesize(power = c(0.8, 0.9), effect_size = 0.5),
    "power.*single"
  )

  # power cannot be NA
  expect_error(
    stat_samplesize(power = NA, effect_size = 0.5),
    "power.*between 0 and 1"
  )
})

test_that("stat_samplesize() validates effect_size parameter", {
  # effect_size must be positive
  expect_error(
    stat_samplesize(power = 0.8, effect_size = -0.5),
    "effect_size.*positive"
  )
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0),
    "effect_size.*positive"
  )

  # effect_size must be numeric
  expect_error(
    stat_samplesize(power = 0.8, effect_size = "0.5"),
    "effect_size.*numeric"
  )

  # effect_size must be single value
  expect_error(
    stat_samplesize(power = 0.8, effect_size = c(0.5, 0.6)),
    "effect_size.*single"
  )

  # effect_size cannot be NA
  expect_error(
    stat_samplesize(power = 0.8, effect_size = NA),
    "effect_size.*positive"
  )

  # effect_size is required
  expect_error(
    stat_samplesize(power = 0.8),
    "missing.*effect_size"
  )
})

test_that("stat_samplesize() validates alpha parameter", {
  # alpha must be between 0 and 1
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, alpha = -0.05),
    "alpha.*between 0 and 1"
  )
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, alpha = 1.5),
    "alpha.*between 0 and 1"
  )

  # alpha must be numeric
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, alpha = "0.05"),
    "alpha.*numeric"
  )

  # alpha must be single value
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, alpha = c(0.05, 0.01)),
    "alpha.*single"
  )
})

test_that("stat_samplesize() validates k parameter for ANOVA", {
  # k is required for ANOVA
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.25, test = "anova"),
    "k.*required"
  )

  # k must be >= 2
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.25, test = "anova", k = 1),
    "k.*>= 2"
  )

  # k must be integer
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.25, test = "anova", k = 3.5),
    "k.*integer"
  )

  # k must be numeric
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.25, test = "anova", k = "3"),
    "k.*integer"
  )
})

test_that("stat_samplesize() validates df parameter for chi-square", {
  # df is required for chisq
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.3, test = "chisq"),
    "df.*required"
  )

  # df must be >= 1
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.3, test = "chisq", df = 0),
    "df.*positive integer"
  )

  # df must be integer
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.3, test = "chisq", df = 2.5),
    "df.*integer"
  )

  # df must be numeric
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.3, test = "chisq", df = "3"),
    "df.*integer"
  )
})

test_that("stat_samplesize() validates plot parameter", {
  # plot must be logical
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, plot = "TRUE"),
    "plot.*logical"
  )

  # plot must be single value
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, plot = c(TRUE, FALSE)),
    "plot.*single"
  )

  # plot cannot be NA
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, plot = NA),
    "plot.*logical"
  )
})

test_that("stat_samplesize() validates verbose parameter", {
  # verbose must be logical
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, verbose = "TRUE"),
    "verbose.*logical"
  )

  # verbose must be single value
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, verbose = c(TRUE, FALSE)),
    "verbose.*single"
  )

  # verbose cannot be NA
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, verbose = NA),
    "verbose.*logical"
  )
})

test_that("stat_samplesize() validates plot_range parameter", {
  # plot_range must be numeric vector of length 2
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, plot_range = c(0.1)),
    "plot_range.*length 2"
  )

  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, plot_range = c(0.1, 0.5, 1.0)),
    "plot_range.*length 2"
  )

  # plot_range[1] must be < plot_range[2]
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, plot_range = c(0.5, 0.3)),
    "plot_range\\[1\\] < plot_range\\[2\\]"
  )

  # plot_range must be positive
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, plot_range = c(-0.1, 0.5)),
    "positive"
  )

  # plot_range cannot contain NA
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.5, plot_range = c(NA, 0.5)),
    "plot_range"
  )

  # correlation plot_range[2] must be <= 1
  expect_error(
    stat_samplesize(power = 0.8, effect_size = 0.3, test = "correlation", plot_range = c(0.1, 1.5)),
    "plot_range\\[2\\].*<= 1"
  )
})


#------------------------------------------------------------------------------
# Return Object Structure Tests
#------------------------------------------------------------------------------

test_that("stat_samplesize() returns object with correct fields", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    type = "two.sample",
    verbose = FALSE,
    plot = TRUE
  )

  # Check all required fields exist
  expect_true("n" %in% names(result))
  expect_true("n_total" %in% names(result))
  expect_true("power" %in% names(result))
  expect_true("effect_size" %in% names(result))
  expect_true("alpha" %in% names(result))
  expect_true("test_type" %in% names(result))
  expect_true("test_subtype" %in% names(result))
  expect_true("alternative" %in% names(result))
  expect_true("plot" %in% names(result))
  expect_true("pwr_object" %in% names(result))
  expect_true("details" %in% names(result))
  expect_true("timestamp" %in% names(result))

  # Check field types
  expect_type(result$n, "integer")
  expect_type(result$n_total, "integer")
  expect_type(result$power, "double")
  expect_type(result$effect_size, "double")
  expect_type(result$alpha, "double")
  expect_type(result$test_type, "character")
  expect_type(result$alternative, "character")
  expect_type(result$details, "list")
  expect_s3_class(result$timestamp, "POSIXct")

  # Check plot is ggplot object when plot = TRUE
  expect_s3_class(result$plot, "gg")
})

test_that("stat_samplesize() returns NULL plot when plot = FALSE", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    verbose = FALSE,
    plot = FALSE
  )

  expect_null(result$plot)
})

test_that("stat_samplesize() details list contains interpretation and recommendation", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    verbose = FALSE,
    plot = FALSE
  )

  expect_true("interpretation" %in% names(result$details))
  expect_true("recommendation" %in% names(result$details))
  expect_type(result$details$interpretation, "character")
  expect_type(result$details$recommendation, "character")
})


#------------------------------------------------------------------------------
# Alternative Hypothesis Tests
#------------------------------------------------------------------------------

test_that("stat_samplesize() works with two-sided alternative", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    alternative = "two.sided",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result$alternative, "two.sided")
})

test_that("stat_samplesize() works with one-sided alternatives", {
  # Test one-sided alternative (greater) with positive effect size
  # Note: alternative="less" requires negative effect size, so we only test "greater"
  result_greater <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    type = "one.sample",
    alternative = "greater",
    verbose = FALSE,
    plot = FALSE
  )

  expect_equal(result_greater$alternative, "greater")

  # One-sided test should require smaller sample than two-sided
  result_two <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    type = "one.sample",
    alternative = "two.sided",
    verbose = FALSE,
    plot = FALSE
  )

  expect_true(result_greater$n < result_two$n)
})


#------------------------------------------------------------------------------
# S3 Methods Tests
#------------------------------------------------------------------------------

test_that("print.stat_samplesize_result() works", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    type = "two.sample",
    verbose = FALSE,
    plot = FALSE
  )

  # Test that print method runs without error and returns invisibly
  expect_invisible(print(result))

  # Check that result object contains expected information
  expect_equal(result$n, 64L)
  expect_equal(result$n_total, 128L)
  expect_equal(result$test_type, "t.test")
})

test_that("summary.stat_samplesize_result() works", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )

  # Test that summary method runs without error and returns invisibly
  # Note: summary() uses cat() which should be captured by capture.output
  output <- capture.output(summary(result))

  # Verify some output was produced
  expect_true(length(output) > 0)
  expect_match(paste(output, collapse = "\n"), "Sample Size Estimation Summary")
})

test_that("plot.stat_samplesize_result() works", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    plot = TRUE,
    verbose = FALSE
  )

  # Should not throw error
  expect_silent(plot(result))
})

test_that("plot.stat_samplesize_result() warns when plot = FALSE", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    plot = FALSE,
    verbose = FALSE
  )

  expect_warning(plot(result), "No plot available")
})


#------------------------------------------------------------------------------
# Edge Cases and Special Scenarios
#------------------------------------------------------------------------------

test_that("stat_samplesize() warns for very large sample sizes", {
  expect_warning(
    stat_samplesize(
      power = 0.8,
      effect_size = 0.05,
      test = "correlation",
      verbose = FALSE,
      plot = FALSE
    ),
    "very large"
  )
})

test_that("stat_samplesize() rounds up sample size to integer", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = FALSE
  )

  expect_true(result$n == round(result$n))
  expect_type(result$n, "integer")
})

test_that("stat_samplesize() works with custom alpha levels", {
  result_005 <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    alpha = 0.05,
    verbose = FALSE,
    plot = FALSE
  )

  result_001 <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    alpha = 0.01,
    verbose = FALSE,
    plot = FALSE
  )

  # More stringent alpha requires larger sample
  expect_true(result_001$n > result_005$n)
})

test_that("stat_samplesize() works with high power requirements", {
  result_80 <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    verbose = FALSE,
    plot = FALSE
  )

  result_95 <- stat_samplesize(
    power = 0.95,
    effect_size = 0.5,
    verbose = FALSE,
    plot = FALSE
  )

  # Higher power requires larger sample
  expect_true(result_95$n > result_80$n)
})

test_that("stat_samplesize() prints messages when verbose = TRUE", {
  # verbose = TRUE should print output (via cli)
  # Just test that the function runs and returns expected result
  result <- stat_samplesize(power = 0.8, effect_size = 0.5, verbose = TRUE, plot = FALSE)
  expect_s3_class(result, "stat_samplesize_result")
  expect_equal(result$n, 64L)
})

test_that("stat_samplesize() minimizes output when verbose = FALSE", {
  expect_silent(
    stat_samplesize(power = 0.8, effect_size = 0.5, verbose = FALSE, plot = FALSE)
  )
})


#------------------------------------------------------------------------------
# Integration Tests
#------------------------------------------------------------------------------

test_that("stat_samplesize() end-to-end workflow for t-test", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    type = "two.sample",
    alternative = "two.sided",
    alpha = 0.05,
    plot = TRUE,
    plot_range = c(0.2, 1.0),
    verbose = FALSE
  )

  expect_s3_class(result, "stat_samplesize_result")
  expect_equal(result$power, 0.8)
  expect_equal(result$effect_size, 0.5)
  expect_equal(result$alpha, 0.05)
  expect_s3_class(result$plot, "gg")

  # Test print and summary methods run without error
  expect_invisible(print(result))

  summary_output <- capture.output(summary(result))
  expect_true(length(summary_output) > 0)
  expect_match(paste(summary_output, collapse = "\n"), "Sample Size Estimation Summary")
})

test_that("stat_samplesize() end-to-end workflow for ANOVA", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.25,
    test = "anova",
    k = 4,
    alpha = 0.05,
    plot = TRUE,
    verbose = FALSE
  )

  expect_s3_class(result, "stat_samplesize_result")
  expect_equal(result$test_type, "anova")
  expect_equal(result$k, 4)
  expect_equal(result$n_total, result$n * 4)
  expect_s3_class(result$plot, "gg")
})

test_that("stat_samplesize() end-to-end workflow for correlation", {
  result <- stat_samplesize(
    power = 0.9,
    effect_size = 0.3,
    test = "correlation",
    alternative = "two.sided",
    alpha = 0.05,
    plot = TRUE,
    verbose = FALSE
  )

  expect_s3_class(result, "stat_samplesize_result")
  expect_equal(result$test_type, "correlation")
  expect_equal(result$power, 0.9)
  expect_s3_class(result$plot, "gg")
})


#------------------------------------------------------------------------------
# Sample Size Interpretation Tests
#------------------------------------------------------------------------------

test_that("stat_samplesize() interpretation distinguishes per group vs total", {
  # t-test should say "per group"
  result_ttest <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    type = "two.sample",
    verbose = FALSE,
    plot = FALSE
  )

  expect_match(result_ttest$details$interpretation, "per group")
  expect_match(result_ttest$details$interpretation, "total")

  # Correlation should say "total"
  result_corr <- stat_samplesize(
    power = 0.8,
    effect_size = 0.3,
    test = "correlation",
    verbose = FALSE,
    plot = FALSE
  )

  expect_match(result_corr$details$interpretation, "total")
  expect_match(result_corr$details$interpretation, "correlation test")
})


#------------------------------------------------------------------------------
# Plot Range Tests
#------------------------------------------------------------------------------

test_that("stat_samplesize() uses custom plot_range when provided", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    plot_range = c(0.2, 1.0),
    verbose = FALSE,
    plot = TRUE
  )

  expect_s3_class(result$plot, "gg")
  # Plot should exist and be created without error
})

test_that("stat_samplesize() generates appropriate default plot_range", {
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.5,
    test = "t.test",
    verbose = FALSE,
    plot = TRUE
  )

  expect_s3_class(result$plot, "gg")
})

test_that("stat_samplesize() respects correlation plot_range limits", {
  # Should work with valid range
  result <- stat_samplesize(
    power = 0.8,
    effect_size = 0.3,
    test = "correlation",
    plot_range = c(0.1, 0.8),
    verbose = FALSE,
    plot = TRUE
  )

  expect_s3_class(result$plot, "gg")
})
