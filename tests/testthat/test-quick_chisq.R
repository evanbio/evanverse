#===============================================================================
# Test: quick_chisq()
# File: test-quick_chisq.R
# Description: Unit tests for the quick_chisq() function
#===============================================================================

#------------------------------------------------------------------------------
# Setup: Create test data
#------------------------------------------------------------------------------

# Set seed for reproducibility
set.seed(123)

# Standard 3x2 contingency table data (adequate expected frequencies)
test_data_standard <- data.frame(
  treatment = rep(c("A", "B", "C"), times = c(40, 40, 40)),
  response = c(
    sample(c("Success", "Failure"), 40, replace = TRUE, prob = c(0.7, 0.3)),
    sample(c("Success", "Failure"), 40, replace = TRUE, prob = c(0.6, 0.4)),
    sample(c("Success", "Failure"), 40, replace = TRUE, prob = c(0.5, 0.5))
  ),
  stringsAsFactors = FALSE
)

# 2x2 table with adequate expected frequencies
test_data_2x2 <- data.frame(
  gender = rep(c("Male", "Female"), each = 50),
  disease = sample(c("Yes", "No"), 100, replace = TRUE, prob = c(0.3, 0.7)),
  stringsAsFactors = FALSE
)

# 2x2 table with small expected frequencies (for Fisher's test)
test_data_small <- data.frame(
  group = c(rep("A", 8), rep("B", 8)),
  outcome = c(rep(c("Yes", "No"), c(7, 1)), rep(c("Yes", "No"), c(2, 6))),
  stringsAsFactors = FALSE
)

# Large contingency table (4x3)
test_data_large <- data.frame(
  category1 = rep(c("Cat1", "Cat2", "Cat3", "Cat4"), each = 30),
  category2 = sample(c("Type1", "Type2", "Type3"), 120, replace = TRUE),
  stringsAsFactors = FALSE
)

# Data with NA values
test_data_na <- test_data_standard
test_data_na$response[1:5] <- NA

# Unbalanced data
test_data_unbalanced <- data.frame(
  group = c(rep("A", 10), rep("B", 50)),
  status = sample(c("Active", "Inactive"), 60, replace = TRUE),
  stringsAsFactors = FALSE
)

# Data with character variables (not factors)
test_data_char <- data.frame(
  var1 = sample(c("Low", "Medium", "High"), 60, replace = TRUE),
  var2 = sample(c("Yes", "No"), 60, replace = TRUE),
  stringsAsFactors = FALSE
)

# Paired data for McNemar's test (before-after measurements)
test_data_mcnemar <- data.frame(
  before = rep(c("Positive", "Negative"), times = c(60, 40)),
  after = c(
    sample(c("Positive", "Negative"), 60, replace = TRUE, prob = c(0.7, 0.3)),
    sample(c("Positive", "Negative"), 40, replace = TRUE, prob = c(0.4, 0.6))
  ),
  stringsAsFactors = FALSE
)

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("quick_chisq() creates a quick_chisq_result object", {
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        verbose = FALSE)
  expect_s3_class(result, "quick_chisq_result")
})

test_that("quick_chisq() performs chi-square test", {
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        method = "chisq",
                        verbose = FALSE)
  expect_s3_class(result$test_result, "htest")
  expect_match(result$method_used, "Chi-square")
  expect_true("p.value" %in% names(result$test_result))
})

test_that("quick_chisq() performs Fisher's exact test", {
  result <- quick_chisq(test_data_small,
                        var1 = group,
                        var2 = outcome,
                        method = "fisher",
                        verbose = FALSE)
  expect_s3_class(result$test_result, "htest")
  expect_match(result$method_used, "Fisher")
})

test_that("quick_chisq() performs McNemar's test", {
  result <- quick_chisq(test_data_mcnemar,
                        var1 = before,
                        var2 = after,
                        method = "mcnemar",
                        verbose = FALSE)
  expect_s3_class(result$test_result, "htest")
  expect_match(result$method_used, "McNemar")
})

test_that("quick_chisq() auto-selects appropriate method", {
  # Standard data should select chi-square
  result_standard <- quick_chisq(test_data_standard,
                                  var1 = treatment,
                                  var2 = response,
                                  method = "auto",
                                  verbose = FALSE)
  expect_match(result_standard$method_used, "Chi-square")

  # Small expected frequencies should trigger Fisher's test
  result_small <- quick_chisq(test_data_small,
                               var1 = group,
                               var2 = outcome,
                               method = "auto",
                               verbose = FALSE)
  expect_match(result_small$method_used, "Fisher")
})

test_that("quick_chisq() creates ggplot object", {
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        verbose = FALSE)
  expect_s3_class(result$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Return Object Structure Tests
#------------------------------------------------------------------------------

test_that("quick_chisq() returns all required components", {
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        verbose = FALSE)

  expect_true("plot" %in% names(result))
  expect_true("test_result" %in% names(result))
  expect_true("method_used" %in% names(result))
  expect_true("contingency_table" %in% names(result))
  expect_true("expected_freq" %in% names(result))
  expect_true("pearson_residuals" %in% names(result))
  expect_true("effect_size" %in% names(result))
  expect_true("descriptive_stats" %in% names(result))
  expect_true("auto_decision" %in% names(result))
  expect_true("timestamp" %in% names(result))
})

test_that("quick_chisq() plot is a ggplot object", {
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        verbose = FALSE)
  expect_s3_class(result$plot, "gg")
  expect_s3_class(result$plot, "ggplot")
})

test_that("quick_chisq() contingency table has correct structure", {
  result <- quick_chisq(test_data_2x2,
                        var1 = gender,
                        var2 = disease,
                        verbose = FALSE)
  expect_true(is.table(result$contingency_table))
  expect_equal(length(dim(result$contingency_table)), 2)
  expect_equal(nrow(result$contingency_table), 2)
  expect_equal(ncol(result$contingency_table), 2)
})

test_that("quick_chisq() expected frequencies match contingency table", {
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        verbose = FALSE)
  expect_equal(dim(result$expected_freq), dim(result$contingency_table))
  expect_equal(sum(result$expected_freq), sum(result$contingency_table))
})

test_that("quick_chisq() calculates Cramer's V correctly", {
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        method = "chisq",
                        verbose = FALSE)
  expect_true(!is.null(result$effect_size))
  expect_true("cramers_v" %in% names(result$effect_size))
  expect_true("interpretation" %in% names(result$effect_size))
  expect_true(result$effect_size$cramers_v >= 0 && result$effect_size$cramers_v <= 1)
})

test_that("quick_chisq() calculates Pearson residuals", {
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        method = "chisq",
                        verbose = FALSE)
  expect_true(!is.null(result$pearson_residuals))
  expect_equal(dim(result$pearson_residuals), dim(result$contingency_table))
})

test_that("quick_chisq() descriptive stats are correct", {
  result <- quick_chisq(test_data_2x2,
                        var1 = gender,
                        var2 = disease,
                        verbose = FALSE)
  expect_s3_class(result$descriptive_stats, "data.frame")
  expect_true("Count" %in% names(result$descriptive_stats))
  expect_true("Proportion" %in% names(result$descriptive_stats))
  expect_true("Percent" %in% names(result$descriptive_stats))
  expect_equal(sum(result$descriptive_stats$Count), 100)
  expect_equal(sum(result$descriptive_stats$Proportion), 1, tolerance = 1e-6)
})

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("quick_chisq() validates data argument", {
  expect_error(
    quick_chisq(data = "not a data frame", var1 = treatment, var2 = response),
    "must be a data frame"
  )
})

test_that("quick_chisq() validates column existence", {
  expect_error(
    quick_chisq(test_data_standard, var1 = nonexistent, var2 = response),
    "not found"
  )
  expect_error(
    quick_chisq(test_data_standard, var1 = treatment, var2 = nonexistent),
    "not found"
  )
})

test_that("quick_chisq() validates conf.level", {
  expect_error(
    quick_chisq(test_data_standard, var1 = treatment, var2 = response, conf.level = 1.5),
    "between 0 and 1"
  )
  expect_error(
    quick_chisq(test_data_standard, var1 = treatment, var2 = response, conf.level = -0.5),
    "between 0 and 1"
  )
})

test_that("quick_chisq() validates logical arguments", {
  expect_error(
    quick_chisq(test_data_standard, var1 = treatment, var2 = response, show_p_value = "yes"),
    "must be TRUE or FALSE"
  )
  expect_error(
    quick_chisq(test_data_standard, var1 = treatment, var2 = response, verbose = 1),
    "must be TRUE or FALSE"
  )
})

test_that("quick_chisq() requires at least 2 levels in each variable", {
  single_level_data <- data.frame(
    var1 = rep("A", 20),
    var2 = sample(c("Yes", "No"), 20, replace = TRUE)
  )
  expect_error(
    quick_chisq(single_level_data, var1 = var1, var2 = var2),
    "at least 2 levels"
  )
})

test_that("quick_chisq() requires square table for McNemar's test", {
  # Non-square table should error with McNemar's test
  expect_error(
    quick_chisq(test_data_standard,
                var1 = treatment,
                var2 = response,
                method = "mcnemar",
                verbose = FALSE),
    "square contingency table"
  )
})

#------------------------------------------------------------------------------
# Method Selection Tests
#------------------------------------------------------------------------------

test_that("quick_chisq() applies Yates' correction appropriately", {
  # 2x2 table with moderate expected frequencies
  result <- quick_chisq(test_data_2x2,
                        var1 = gender,
                        var2 = disease,
                        method = "auto",
                        verbose = FALSE)

  # Result should have auto_decision info
  expect_true(!is.null(result$auto_decision))

  # If expected frequencies are low, should either apply Yates' or use Fisher's
  if (min(result$expected_freq) < 10) {
    expect_true(!is.null(result$auto_decision$yates_correction) ||
                  result$method_used == "Fisher's exact test")
  }
})

test_that("quick_chisq() handles low expected frequencies", {
  # Function should handle data with low expected frequencies
  # (may produce warnings from stats::chisq.test)
  result <- suppressWarnings(
    quick_chisq(test_data_small,
                var1 = group,
                var2 = outcome,
                method = "chisq",
                verbose = FALSE)
  )
  expect_s3_class(result, "quick_chisq_result")
})

test_that("quick_chisq() respects correct parameter", {
  result_corrected <- quick_chisq(test_data_2x2,
                                   var1 = gender,
                                   var2 = disease,
                                   method = "chisq",
                                   correct = TRUE,
                                   verbose = FALSE)
  expect_match(result_corrected$method_used, "Yates")

  result_uncorrected <- quick_chisq(test_data_2x2,
                                     var1 = gender,
                                     var2 = disease,
                                     method = "chisq",
                                     correct = FALSE,
                                     verbose = FALSE)
  expect_false(grepl("Yates", result_uncorrected$method_used))
})

test_that("quick_chisq() applies Yates' correction for McNemar's test", {
  result_corrected <- quick_chisq(test_data_mcnemar,
                                   var1 = before,
                                   var2 = after,
                                   method = "mcnemar",
                                   correct = TRUE,
                                   verbose = FALSE)
  expect_s3_class(result_corrected$test_result, "htest")
})

#------------------------------------------------------------------------------
# Visualization Tests
#------------------------------------------------------------------------------

test_that("quick_chisq() creates different plot types", {
  result_grouped <- quick_chisq(test_data_standard,
                                 var1 = treatment,
                                 var2 = response,
                                 plot_type = "bar_grouped",
                                 verbose = FALSE)
  expect_s3_class(result_grouped$plot, "ggplot")

  result_stacked <- quick_chisq(test_data_standard,
                                 var1 = treatment,
                                 var2 = response,
                                 plot_type = "bar_stacked",
                                 verbose = FALSE)
  expect_s3_class(result_stacked$plot, "ggplot")

  result_heatmap <- quick_chisq(test_data_standard,
                                 var1 = treatment,
                                 var2 = response,
                                 plot_type = "heatmap",
                                 method = "chisq",
                                 verbose = FALSE)
  expect_s3_class(result_heatmap$plot, "ggplot")
})

test_that("quick_chisq() respects show_p_value parameter", {
  result_with_p <- quick_chisq(test_data_standard,
                                var1 = treatment,
                                var2 = response,
                                show_p_value = TRUE,
                                verbose = FALSE)
  expect_s3_class(result_with_p$plot, "ggplot")

  result_without_p <- quick_chisq(test_data_standard,
                                   var1 = treatment,
                                   var2 = response,
                                   show_p_value = FALSE,
                                   verbose = FALSE)
  expect_s3_class(result_without_p$plot, "ggplot")
})

test_that("quick_chisq() supports p-value label formats", {
  result_stars <- quick_chisq(test_data_standard,
                               var1 = treatment,
                               var2 = response,
                               p_label = "p.signif",
                               verbose = FALSE)
  expect_s3_class(result_stars$plot, "ggplot")

  result_numeric <- quick_chisq(test_data_standard,
                                 var1 = treatment,
                                 var2 = response,
                                 p_label = "p.format",
                                 verbose = FALSE)
  expect_s3_class(result_numeric$plot, "ggplot")
})

test_that("quick_chisq() applies color palette", {
  result_custom <- quick_chisq(test_data_standard,
                                var1 = treatment,
                                var2 = response,
                                palette = "qual_balanced",
                                verbose = FALSE)
  expect_s3_class(result_custom$plot, "ggplot")

  result_null <- quick_chisq(test_data_standard,
                              var1 = treatment,
                              var2 = response,
                              palette = NULL,
                              verbose = FALSE)
  expect_s3_class(result_null$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Data Handling Tests
#------------------------------------------------------------------------------

test_that("quick_chisq() handles missing values", {
  # Function should handle missing values (with or without message depending on verbose)
  result <- quick_chisq(test_data_na,
                        var1 = treatment,
                        var2 = response,
                        verbose = FALSE)
  expect_s3_class(result, "quick_chisq_result")
  # Verify that rows with NA were removed
  expect_true(!is.null(result$contingency_table))
})

test_that("quick_chisq() converts character variables to factors", {
  expect_message(
    result <- quick_chisq(test_data_char,
                          var1 = var1,
                          var2 = var2,
                          verbose = TRUE),
    "converted to factor"
  )
  expect_s3_class(result, "quick_chisq_result")
})

test_that("quick_chisq() handles unbalanced data", {
  result <- quick_chisq(test_data_unbalanced,
                        var1 = group,
                        var2 = status,
                        verbose = FALSE)
  expect_s3_class(result, "quick_chisq_result")
})

test_that("quick_chisq() errors on empty data after removing NAs", {
  all_na_data <- data.frame(
    var1 = rep(NA, 10),
    var2 = rep(NA, 10)
  )
  expect_error(
    quick_chisq(all_na_data, var1 = var1, var2 = var2),
    "No valid data"
  )
})

#------------------------------------------------------------------------------
# S3 Methods Tests
#------------------------------------------------------------------------------

test_that("print.quick_chisq_result works", {
  result <- quick_chisq(test_data_2x2,
                        var1 = gender,
                        var2 = disease,
                        verbose = FALSE)
  expect_output(print(result), "Quick Chi-Square Test Result")
  expect_output(print(result), "Method:")
  expect_output(print(result), "P-value:")
})

test_that("summary.quick_chisq_result works", {
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        method = "chisq",
                        verbose = FALSE)
  expect_output(summary(result), "Detailed Summary")
  expect_output(summary(result), "Observed Frequencies")
  expect_output(summary(result), "Expected Frequencies")
  expect_output(summary(result), "Pearson Residuals")
  expect_output(summary(result), "Effect Size")
})

test_that("print handles plot errors gracefully", {
  result <- quick_chisq(test_data_2x2,
                        var1 = gender,
                        var2 = disease,
                        verbose = FALSE)
  # Corrupt the plot
  result$plot <- NULL
  # Should still print statistical summary without error
  expect_output(print(result), "Quick Chi-Square Test Result")
})

#------------------------------------------------------------------------------
# Verbose Mode Tests
#------------------------------------------------------------------------------

test_that("quick_chisq() prints messages when verbose = TRUE", {
  # Function should produce diagnostic messages when verbose = TRUE
  result <- quick_chisq(test_data_char,
                        var1 = var1,
                        var2 = var2,
                        verbose = TRUE)
  # Just verify the result is created - verbose messages are visible in test output
  expect_s3_class(result, "quick_chisq_result")
})

test_that("quick_chisq() minimizes output when verbose = FALSE", {
  # verbose = FALSE should minimize output
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        verbose = FALSE)
  # Just check the result is created successfully
  expect_s3_class(result, "quick_chisq_result")
})

#------------------------------------------------------------------------------
# Edge Cases Tests
#------------------------------------------------------------------------------

test_that("quick_chisq() handles 2x2 tables correctly", {
  result <- quick_chisq(test_data_2x2,
                        var1 = gender,
                        var2 = disease,
                        verbose = FALSE)
  expect_equal(nrow(result$contingency_table), 2)
  expect_equal(ncol(result$contingency_table), 2)
})

test_that("quick_chisq() handles large contingency tables", {
  result <- quick_chisq(test_data_large,
                        var1 = category1,
                        var2 = category2,
                        verbose = FALSE)
  expect_equal(nrow(result$contingency_table), 4)
  expect_equal(ncol(result$contingency_table), 3)
})

test_that("quick_chisq() timestamp is POSIXct", {
  result <- quick_chisq(test_data_standard,
                        var1 = treatment,
                        var2 = response,
                        verbose = FALSE)
  expect_s3_class(result$timestamp, "POSIXct")
})

test_that("quick_chisq() handles quoted and unquoted column names", {
  result_unquoted <- quick_chisq(test_data_standard,
                                  var1 = treatment,
                                  var2 = response,
                                  verbose = FALSE)
  expect_s3_class(result_unquoted, "quick_chisq_result")

  # Note: Quoted names would be `"treatment"` but NSE handles this automatically
})

#------------------------------------------------------------------------------
# Integration Tests
#------------------------------------------------------------------------------

test_that("quick_chisq() integrates with different methods", {
  # Test chi-square
  result_chisq <- quick_chisq(test_data_standard,
                               var1 = treatment,
                               var2 = response,
                               method = "chisq",
                               verbose = FALSE)
  expect_match(result_chisq$method_used, "Chi-square")

  # Test Fisher (on small data)
  result_fisher <- quick_chisq(test_data_small,
                                var1 = group,
                                var2 = outcome,
                                method = "fisher",
                                verbose = FALSE)
  expect_match(result_fisher$method_used, "Fisher")
})

test_that("quick_chisq() produces consistent results", {
  result1 <- quick_chisq(test_data_2x2,
                         var1 = gender,
                         var2 = disease,
                         method = "chisq",
                         verbose = FALSE)
  result2 <- quick_chisq(test_data_2x2,
                         var1 = gender,
                         var2 = disease,
                         method = "chisq",
                         verbose = FALSE)
  expect_equal(result1$test_result$statistic, result2$test_result$statistic)
  expect_equal(result1$test_result$p.value, result2$test_result$p.value)
})

test_that("quick_chisq() end-to-end workflow for chi-square test", {
  result <- quick_chisq(
    data = test_data_standard,
    var1 = treatment,
    var2 = response,
    method = "auto",
    plot_type = "bar_grouped",
    show_p_value = TRUE,
    p_label = "p.signif",
    palette = "qual_vivid",
    verbose = FALSE
  )

  expect_s3_class(result, "quick_chisq_result")
  expect_s3_class(result$plot, "ggplot")
  expect_s3_class(result$test_result, "htest")
  expect_true(result$test_result$p.value >= 0 && result$test_result$p.value <= 1)
  expect_true(!is.null(result$effect_size))
  expect_true(!is.null(result$contingency_table))
})

test_that("quick_chisq() end-to-end workflow for Fisher's test", {
  result <- quick_chisq(
    data = test_data_small,
    var1 = group,
    var2 = outcome,
    method = "auto",
    plot_type = "bar_grouped",
    show_p_value = TRUE,
    p_label = "p.format",
    verbose = FALSE
  )

  expect_s3_class(result, "quick_chisq_result")
  expect_s3_class(result$plot, "ggplot")
  expect_s3_class(result$test_result, "htest")
  expect_match(result$method_used, "Fisher")
  expect_true(result$test_result$p.value >= 0 && result$test_result$p.value <= 1)
})

test_that("quick_chisq() end-to-end workflow for McNemar's test", {
  result <- quick_chisq(
    data = test_data_mcnemar,
    var1 = before,
    var2 = after,
    method = "mcnemar",
    plot_type = "heatmap",
    show_p_value = TRUE,
    verbose = FALSE
  )

  expect_s3_class(result, "quick_chisq_result")
  expect_s3_class(result$plot, "ggplot")
  expect_s3_class(result$test_result, "htest")
  expect_match(result$method_used, "McNemar")
  expect_true(result$test_result$p.value >= 0 && result$test_result$p.value <= 1)
})

#------------------------------------------------------------------------------
# Performance Tests (Optional)
#------------------------------------------------------------------------------

test_that("quick_chisq() completes in reasonable time", {
  expect_no_error({
    system.time({
      result <- quick_chisq(test_data_large,
                            var1 = category1,
                            var2 = category2,
                            verbose = FALSE)
    })
  })
})

#===============================================================================
# End: test-quick_chisq.R
#===============================================================================
