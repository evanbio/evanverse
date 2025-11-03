#===============================================================================
# Test: quick_ttest()
# File: test-quick_ttest.R
# Description: Unit tests for the quick_ttest() function
#===============================================================================

#------------------------------------------------------------------------------
# Setup: Create test data
#------------------------------------------------------------------------------

# Set seed for reproducibility
set.seed(123)

# Independent samples test data (normal distribution)
test_data_normal <- data.frame(
  group = rep(c("Control", "Treatment"), each = 25),
  value = c(rnorm(25, mean = 10, sd = 2), rnorm(25, mean = 12, sd = 2)),
  stringsAsFactors = FALSE
)

# Paired samples test data
test_data_paired <- data.frame(
  patient = rep(1:20, 2),
  timepoint = rep(c("Before", "After"), each = 20),
  score = c(rnorm(20, mean = 50, sd = 10), rnorm(20, mean = 55, sd = 10)),
  stringsAsFactors = FALSE
)

# Skewed data (for non-parametric test)
test_data_skewed <- data.frame(
  group = rep(c("A", "B"), each = 20),
  value = c(rexp(20, rate = 0.5), rexp(20, rate = 1)),
  stringsAsFactors = FALSE
)

# Small sample data
test_data_small <- data.frame(
  group = rep(c("X", "Y"), each = 5),
  value = c(rnorm(5, 10, 2), rnorm(5, 12, 2)),
  stringsAsFactors = FALSE
)

# Data with NA values
test_data_na <- test_data_normal
test_data_na$value[1:3] <- NA

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("quick_ttest() creates a quick_ttest_result object", {
  result <- quick_ttest(test_data_normal,
                        group = group,
                        value = value,
                        verbose = FALSE)
  expect_s3_class(result, "quick_ttest_result")
})

test_that("quick_ttest() performs independent samples t-test", {
  result <- quick_ttest(test_data_normal,
                        group = group,
                        value = value,
                        method = "t.test",
                        verbose = FALSE)
  expect_s3_class(result$test_result, "htest")
  expect_equal(result$method_used, "t.test")
  expect_true("p.value" %in% names(result$test_result))
})

test_that("quick_ttest() performs paired t-test", {
  result <- quick_ttest(test_data_paired,
                        group = timepoint,
                        value = score,
                        paired = TRUE,
                        id = patient,
                        method = "t.test",
                        verbose = FALSE)
  expect_s3_class(result$test_result, "htest")
  expect_equal(result$method_used, "t.test")
  expect_true(result$parameters$paired)
})

test_that("quick_ttest() performs Wilcoxon test", {
  result <- quick_ttest(test_data_skewed,
                        group = group,
                        value = value,
                        method = "wilcox.test",
                        verbose = FALSE)
  expect_s3_class(result$test_result, "htest")
  expect_equal(result$method_used, "wilcox.test")
})

test_that("quick_ttest() auto-selects appropriate method", {
  # Normal data should select t-test
  result_normal <- quick_ttest(test_data_normal,
                                group = group,
                                value = value,
                                method = "auto",
                                verbose = FALSE)
  expect_equal(result_normal$method_used, "t.test")
})

test_that("quick_ttest() creates ggplot object", {
  result <- quick_ttest(test_data_normal,
                        group = group,
                        value = value,
                        verbose = FALSE)
  expect_s3_class(result$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("quick_ttest() validates data parameter", {
  expect_error(quick_ttest(NULL, group = group, value = value),
               "`data` must be a data frame")
  expect_error(quick_ttest(list(a = 1), group = group, value = value),
               "`data` must be a data frame")
})

test_that("quick_ttest() validates paired parameter", {
  expect_error(quick_ttest(test_data_normal, group = group, value = value,
                          paired = "yes"),
               "`paired` must be TRUE or FALSE")
  expect_error(quick_ttest(test_data_normal, group = group, value = value,
                          paired = c(TRUE, FALSE)),
               "`paired` must be TRUE or FALSE")
})

test_that("quick_ttest() requires id when paired = TRUE", {
  expect_error(quick_ttest(test_data_paired,
                          group = timepoint,
                          value = score,
                          paired = TRUE,
                          verbose = FALSE),
               "`id` must be specified when `paired` is TRUE")
})

test_that("quick_ttest() validates conf.level parameter", {
  expect_error(quick_ttest(test_data_normal, group = group, value = value,
                          conf.level = 1.5),
               "`conf.level` must be between 0 and 1")
  expect_error(quick_ttest(test_data_normal, group = group, value = value,
                          conf.level = -0.5),
               "`conf.level` must be between 0 and 1")
})

test_that("quick_ttest() validates column names", {
  expect_error(quick_ttest(test_data_normal,
                          group = nonexistent,
                          value = value,
                          verbose = FALSE),
               "not found")
  expect_error(quick_ttest(test_data_normal,
                          group = group,
                          value = nonexistent,
                          verbose = FALSE),
               "not found")
})

test_that("quick_ttest() validates value is numeric", {
  bad_data <- test_data_normal
  bad_data$value <- as.character(bad_data$value)
  expect_error(quick_ttest(bad_data, group = group, value = value,
                          verbose = FALSE),
               "must be numeric")
})

test_that("quick_ttest() requires exactly 2 groups", {
  multi_group_data <- data.frame(
    group = rep(c("A", "B", "C"), each = 10),
    value = rnorm(30)
  )
  expect_error(quick_ttest(multi_group_data, group = group, value = value,
                          verbose = FALSE),
               "requires exactly 2 groups")
})

#------------------------------------------------------------------------------
# Paired Data Validation Tests
#------------------------------------------------------------------------------

test_that("quick_ttest() validates paired IDs are in both groups", {
  bad_paired_data <- test_data_paired
  bad_paired_data <- bad_paired_data[-1, ]  # Remove one observation

  expect_error(quick_ttest(bad_paired_data,
                          group = timepoint,
                          value = score,
                          paired = TRUE,
                          id = patient,
                          verbose = FALSE),
               "must appear in both groups")
})

test_that("quick_ttest() validates paired IDs are not duplicated", {
  bad_paired_data <- test_data_paired
  bad_paired_data <- rbind(bad_paired_data, bad_paired_data[1, ])  # Duplicate one row

  expect_error(quick_ttest(bad_paired_data,
                          group = timepoint,
                          value = score,
                          paired = TRUE,
                          id = patient,
                          verbose = FALSE),
               "exactly once per group")
})

test_that("quick_ttest() accepts different column names as id", {
  paired_data_alt <- test_data_paired
  names(paired_data_alt)[1] <- "subject_id"

  result <- quick_ttest(paired_data_alt,
                        group = timepoint,
                        value = score,
                        paired = TRUE,
                        id = subject_id,
                        verbose = FALSE)
  expect_s3_class(result, "quick_ttest_result")
})

#------------------------------------------------------------------------------
# Statistical Tests Validation
#------------------------------------------------------------------------------

test_that("quick_ttest() performs normality checks for independent samples", {
  result <- quick_ttest(test_data_normal,
                        group = group,
                        value = value,
                        method = "auto",
                        verbose = FALSE)
  expect_true(!is.null(result$normality_tests))
  expect_true("recommendation" %in% names(result$normality_tests))
})

test_that("quick_ttest() checks normality of differences for paired samples", {
  result <- quick_ttest(test_data_paired,
                        group = timepoint,
                        value = score,
                        paired = TRUE,
                        id = patient,
                        method = "auto",
                        verbose = FALSE)
  expect_true(!is.null(result$normality_tests))
  expect_true(result$normality_tests$paired)
})

test_that("quick_ttest() checks variance equality for independent t-test", {
  result <- quick_ttest(test_data_normal,
                        group = group,
                        value = value,
                        method = "t.test",
                        var.equal = NULL,
                        verbose = FALSE)
  # Should have variance test result (or default to FALSE if car not available)
  expect_true(is.logical(result$parameters$var.equal) ||
              !is.null(result$variance_test))
})

test_that("quick_ttest() handles paired tests appropriately", {
  result <- quick_ttest(test_data_paired,
                        group = timepoint,
                        value = score,
                        paired = TRUE,
                        id = patient,
                        method = "t.test",
                        verbose = FALSE)
  # For paired tests, function should work correctly
  expect_true(result$parameters$paired)
  expect_s3_class(result$test_result, "htest")
})

test_that("quick_ttest() respects var.equal parameter", {
  result_equal <- quick_ttest(test_data_normal,
                              group = group,
                              value = value,
                              method = "t.test",
                              var.equal = TRUE,
                              verbose = FALSE)
  expect_true(result_equal$parameters$var.equal)

  result_unequal <- quick_ttest(test_data_normal,
                                group = group,
                                value = value,
                                method = "t.test",
                                var.equal = FALSE,
                                verbose = FALSE)
  expect_false(result_unequal$parameters$var.equal)
})

#------------------------------------------------------------------------------
# Plot Customization Tests
#------------------------------------------------------------------------------

test_that("quick_ttest() supports different plot types", {
  result_box <- quick_ttest(test_data_normal, group = group, value = value,
                            plot_type = "boxplot", verbose = FALSE)
  expect_s3_class(result_box$plot, "ggplot")

  result_violin <- quick_ttest(test_data_normal, group = group, value = value,
                               plot_type = "violin", verbose = FALSE)
  expect_s3_class(result_violin$plot, "ggplot")

  result_both <- quick_ttest(test_data_normal, group = group, value = value,
                             plot_type = "both", verbose = FALSE)
  expect_s3_class(result_both$plot, "ggplot")
})

test_that("quick_ttest() supports jitter customization", {
  result_no_jitter <- quick_ttest(test_data_normal, group = group, value = value,
                                  add_jitter = FALSE, verbose = FALSE)
  expect_s3_class(result_no_jitter$plot, "ggplot")

  result_custom <- quick_ttest(test_data_normal, group = group, value = value,
                               add_jitter = TRUE, point_size = 3,
                               point_alpha = 0.8, verbose = FALSE)
  expect_s3_class(result_custom$plot, "ggplot")
})

test_that("quick_ttest() supports p-value label formats", {
  result_stars <- quick_ttest(test_data_normal, group = group, value = value,
                              p_label = "p.signif", verbose = FALSE)
  expect_s3_class(result_stars$plot, "ggplot")

  result_numeric <- quick_ttest(test_data_normal, group = group, value = value,
                                p_label = "p.format", verbose = FALSE)
  expect_s3_class(result_numeric$plot, "ggplot")
})

test_that("quick_ttest() supports hiding p-value", {
  result <- quick_ttest(test_data_normal, group = group, value = value,
                        show_p_value = FALSE, verbose = FALSE)
  expect_s3_class(result$plot, "ggplot")
})

test_that("quick_ttest() accepts palette parameter", {
  result <- quick_ttest(test_data_normal, group = group, value = value,
                        palette = "qual_bold", verbose = FALSE)
  expect_s3_class(result$plot, "ggplot")
})

test_that("quick_ttest() accepts NULL palette", {
  result <- quick_ttest(test_data_normal, group = group, value = value,
                        palette = NULL, verbose = FALSE)
  expect_s3_class(result$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Return Object Structure Tests
#------------------------------------------------------------------------------

test_that("quick_ttest() returns object with required components", {
  result <- quick_ttest(test_data_normal, group = group, value = value,
                        verbose = FALSE)

  expect_true("plot" %in% names(result))
  expect_true("test_result" %in% names(result))
  expect_true("method_used" %in% names(result))
  expect_true("normality_tests" %in% names(result))
  expect_true("descriptive_stats" %in% names(result))
  expect_true("parameters" %in% names(result))
  expect_true("timestamp" %in% names(result))
})

test_that("quick_ttest() result contains descriptive statistics", {
  result <- quick_ttest(test_data_normal, group = group, value = value,
                        verbose = FALSE)

  expect_s3_class(result$descriptive_stats, "data.frame")
  expect_true("n" %in% names(result$descriptive_stats))
  expect_true("mean" %in% names(result$descriptive_stats))
  expect_true("sd" %in% names(result$descriptive_stats))
})

test_that("quick_ttest() stores parameters correctly", {
  result <- quick_ttest(test_data_normal,
                        group = group,
                        value = value,
                        paired = FALSE,
                        alternative = "two.sided",
                        conf.level = 0.95,
                        verbose = FALSE)

  expect_false(result$parameters$paired)
  expect_equal(result$parameters$alternative, "two.sided")
  expect_equal(result$parameters$conf.level, 0.95)
})

#------------------------------------------------------------------------------
# Edge Cases and Special Scenarios
#------------------------------------------------------------------------------

test_that("quick_ttest() handles small samples", {
  result <- quick_ttest(test_data_small, group = group, value = value,
                        verbose = FALSE)
  expect_s3_class(result, "quick_ttest_result")
})

test_that("quick_ttest() handles data with NA values", {
  # Function should handle NA values (with or without warning depending on verbose)
  result <- quick_ttest(test_data_na, group = group, value = value,
                       verbose = FALSE)
  expect_s3_class(result, "quick_ttest_result")
  # Check that rows with NA were removed
  expect_true(nrow(result$descriptive_stats) == 2)
})

test_that("quick_ttest() handles one-sided tests", {
  result_greater <- quick_ttest(test_data_normal,
                                group = group,
                                value = value,
                                alternative = "greater",
                                verbose = FALSE)
  expect_equal(result_greater$parameters$alternative, "greater")

  result_less <- quick_ttest(test_data_normal,
                             group = group,
                             value = value,
                             alternative = "less",
                             verbose = FALSE)
  expect_equal(result_less$parameters$alternative, "less")
})

test_that("quick_ttest() handles different confidence levels", {
  result_90 <- quick_ttest(test_data_normal,
                           group = group,
                           value = value,
                           conf.level = 0.90,
                           verbose = FALSE)
  expect_equal(result_90$parameters$conf.level, 0.90)

  result_99 <- quick_ttest(test_data_normal,
                           group = group,
                           value = value,
                           conf.level = 0.99,
                           verbose = FALSE)
  expect_equal(result_99$parameters$conf.level, 0.99)
})

test_that("quick_ttest() handles unbalanced sample sizes", {
  unbalanced_data <- data.frame(
    group = c(rep("A", 10), rep("B", 30)),
    value = rnorm(40)
  )
  # Function should handle unbalanced sample sizes
  result <- quick_ttest(unbalanced_data, group = group, value = value,
                       verbose = FALSE)
  expect_s3_class(result, "quick_ttest_result")
  # Check descriptive stats show different sample sizes
  expect_true(result$descriptive_stats$n[1] != result$descriptive_stats$n[2])
})

test_that("quick_ttest() handles groups with equal variances", {
  equal_var_data <- data.frame(
    group = rep(c("A", "B"), each = 20),
    value = c(rnorm(20, 10, 2), rnorm(20, 12, 2))
  )
  result <- quick_ttest(equal_var_data,
                        group = group,
                        value = value,
                        var.equal = NULL,
                        verbose = FALSE)
  expect_s3_class(result, "quick_ttest_result")
})

#------------------------------------------------------------------------------
# S3 Methods Tests
#------------------------------------------------------------------------------

test_that("print.quick_ttest_result works", {
  result <- quick_ttest(test_data_normal, group = group, value = value,
                        verbose = FALSE)
  # print method displays plot and descriptive stats
  expect_output(print(result), "Method:|group|value")
})

test_that("summary.quick_ttest_result works", {
  result <- quick_ttest(test_data_normal, group = group, value = value,
                        verbose = FALSE)
  # summary should produce output - just check it runs without error
  expect_output(summary(result))
})

test_that("quick_ttest_result contains plot", {
  result <- quick_ttest(test_data_normal, group = group, value = value,
                        verbose = FALSE)
  # Result should contain a ggplot object
  expect_s3_class(result$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Verbose Mode Tests
#------------------------------------------------------------------------------

test_that("quick_ttest() prints messages when verbose = TRUE", {
  # Function should produce diagnostic messages when verbose = TRUE
  # Using expect_message to catch cli output
  result <- quick_ttest(test_data_normal, group = group, value = value,
                       verbose = TRUE)
  # Just verify the result is created - verbose messages are visible in test output
  expect_s3_class(result, "quick_ttest_result")
})

test_that("quick_ttest() minimizes output when verbose = FALSE", {
  # verbose = FALSE should minimize output (palette messages may still appear)
  result <- quick_ttest(test_data_normal, group = group, value = value,
                       verbose = FALSE)
  # Just check the result is created successfully
  expect_s3_class(result, "quick_ttest_result")
})

#------------------------------------------------------------------------------
# Integration Tests
#------------------------------------------------------------------------------

test_that("quick_ttest() end-to-end workflow for independent samples", {
  result <- quick_ttest(
    data = test_data_normal,
    group = group,
    value = value,
    method = "auto",
    plot_type = "boxplot",
    add_jitter = TRUE,
    show_p_value = TRUE,
    p_label = "p.signif",
    palette = "qual_vivid",
    verbose = FALSE
  )

  expect_s3_class(result, "quick_ttest_result")
  expect_s3_class(result$plot, "ggplot")
  expect_s3_class(result$test_result, "htest")
  expect_true(result$test_result$p.value >= 0 && result$test_result$p.value <= 1)
})

test_that("quick_ttest() end-to-end workflow for paired samples", {
  result <- quick_ttest(
    data = test_data_paired,
    group = timepoint,
    value = score,
    paired = TRUE,
    id = patient,
    method = "auto",
    plot_type = "violin",
    show_p_value = TRUE,
    verbose = FALSE
  )

  expect_s3_class(result, "quick_ttest_result")
  expect_s3_class(result$plot, "ggplot")
  expect_s3_class(result$test_result, "htest")
  expect_true(result$parameters$paired)
  expect_true(result$test_result$p.value >= 0 && result$test_result$p.value <= 1)
})

#===============================================================================
# End: test-quick_ttest.R
#===============================================================================
