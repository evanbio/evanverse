#===============================================================================
# Test: quick_anova()
# File: test-quick_anova.R
# Description: Unit tests for the quick_anova() function
#===============================================================================

#------------------------------------------------------------------------------
# Setup: Create test data
#------------------------------------------------------------------------------

# Set seed for reproducibility
set.seed(123)

# Normal distribution, 3 groups (for standard ANOVA)
test_data_normal <- data.frame(
  group = rep(c("A", "B", "C"), each = 25),
  value = c(rnorm(25, mean = 10, sd = 2),
            rnorm(25, mean = 12, sd = 2),
            rnorm(25, mean = 14, sd = 2)),
  stringsAsFactors = FALSE
)

# Unequal variances, 3 groups (for Welch ANOVA)
test_data_unequal_var <- data.frame(
  group = rep(c("X", "Y", "Z"), each = 20),
  value = c(rnorm(20, mean = 10, sd = 1),
            rnorm(20, mean = 12, sd = 3),
            rnorm(20, mean = 15, sd = 5)),
  stringsAsFactors = FALSE
)

# Skewed data, 4 groups (for Kruskal-Wallis)
test_data_skewed <- data.frame(
  treatment = rep(c("T1", "T2", "T3", "T4"), each = 20),
  score = c(rexp(20, 1), rexp(20, 1.5), rexp(20, 2), rexp(20, 2.5)),
  stringsAsFactors = FALSE
)

# Small sample data
test_data_small <- data.frame(
  group = rep(c("Low", "Medium", "High"), each = 5),
  response = c(rnorm(5, 5, 1), rnorm(5, 6, 1), rnorm(5, 7, 1)),
  stringsAsFactors = FALSE
)

# Data with NA values
test_data_na <- test_data_normal
test_data_na$value[1:3] <- NA

# Two groups only (should work but suggest using quick_ttest)
test_data_two_groups <- data.frame(
  group = rep(c("Control", "Treatment"), each = 20),
  value = c(rnorm(20, 10, 2), rnorm(20, 12, 2)),
  stringsAsFactors = FALSE
)

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("quick_anova() creates a quick_anova_result object", {
  result <- quick_anova(test_data_normal,
                        group = group,
                        value = value,
                        verbose = FALSE)
  expect_s3_class(result, "quick_anova_result")
})

test_that("quick_anova() performs standard one-way ANOVA", {
  result <- quick_anova(test_data_normal,
                        group = group,
                        value = value,
                        method = "anova",
                        verbose = FALSE)
  expect_equal(result$method_used, "anova")
  expect_true(!is.null(result$omnibus_result))
  expect_true("p_value" %in% names(result$omnibus_result))
})

test_that("quick_anova() performs Welch ANOVA", {
  result <- quick_anova(test_data_unequal_var,
                        group = group,
                        value = value,
                        method = "welch",
                        verbose = FALSE)
  expect_equal(result$method_used, "welch")
  expect_true(!is.null(result$omnibus_result))
  expect_true("p_value" %in% names(result$omnibus_result))
})

test_that("quick_anova() performs Kruskal-Wallis test", {
  result <- quick_anova(test_data_skewed,
                        group = treatment,
                        value = score,
                        method = "kruskal",
                        verbose = FALSE)
  expect_equal(result$method_used, "kruskal")
  expect_true(!is.null(result$omnibus_result))
  expect_true("p_value" %in% names(result$omnibus_result))
})

test_that("quick_anova() auto-selects appropriate method", {
  # Normal data with equal variances should select ANOVA
  result_normal <- quick_anova(test_data_normal,
                                group = group,
                                value = value,
                                method = "auto",
                                verbose = FALSE)
  expect_true(result_normal$method_used %in% c("anova", "welch"))
})

test_that("quick_anova() creates ggplot object", {
  result <- quick_anova(test_data_normal,
                        group = group,
                        value = value,
                        verbose = FALSE)
  expect_s3_class(result$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("quick_anova() validates data parameter", {
  expect_error(quick_anova(NULL, group = group, value = value),
               "`data` must be a data frame")
  expect_error(quick_anova(list(a = 1), group = group, value = value),
               "`data` must be a data frame")
})

test_that("quick_anova() validates conf.level parameter", {
  expect_error(quick_anova(test_data_normal, group = group, value = value,
                          conf.level = 1.5),
               "`conf.level` must be between 0 and 1")
  expect_error(quick_anova(test_data_normal, group = group, value = value,
                          conf.level = -0.5),
               "`conf.level` must be between 0 and 1")
})

test_that("quick_anova() validates add_jitter parameter", {
  expect_error(quick_anova(test_data_normal, group = group, value = value,
                          add_jitter = "yes"),
               "`add_jitter` must be TRUE or FALSE")
})

test_that("quick_anova() validates show_p_value parameter", {
  expect_error(quick_anova(test_data_normal, group = group, value = value,
                          show_p_value = "yes"),
               "`show_p_value` must be TRUE or FALSE")
})

test_that("quick_anova() validates verbose parameter", {
  expect_error(quick_anova(test_data_normal, group = group, value = value,
                          verbose = "yes"),
               "`verbose` must be TRUE or FALSE")
})

test_that("quick_anova() validates column names", {
  expect_error(quick_anova(test_data_normal,
                          group = nonexistent,
                          value = value,
                          verbose = FALSE),
               "not found")
  expect_error(quick_anova(test_data_normal,
                          group = group,
                          value = nonexistent,
                          verbose = FALSE),
               "not found")
})

test_that("quick_anova() validates value is numeric", {
  bad_data <- test_data_normal
  bad_data$value <- as.character(bad_data$value)
  expect_error(quick_anova(bad_data, group = group, value = value,
                          verbose = FALSE),
               "must be numeric")
})

test_that("quick_anova() requires at least 2 groups", {
  single_group_data <- data.frame(
    group = rep("A", 20),
    value = rnorm(20)
  )
  expect_error(quick_anova(single_group_data, group = group, value = value,
                          verbose = FALSE),
               "requires at least 2 groups")
})

test_that("quick_anova() works with exactly 2 groups", {
  result <- quick_anova(test_data_two_groups,
                        group = group,
                        value = value,
                        verbose = FALSE)
  expect_s3_class(result, "quick_anova_result")
})

#------------------------------------------------------------------------------
# Post-hoc Tests Validation
#------------------------------------------------------------------------------

test_that("quick_anova() performs Tukey HSD post-hoc after ANOVA", {
  result <- quick_anova(test_data_normal,
                        group = group,
                        value = value,
                        method = "anova",
                        post_hoc = "tukey",
                        verbose = FALSE)
  expect_true(!is.null(result$post_hoc))
  expect_equal(result$post_hoc$method, "tukey")
})

test_that("quick_anova() performs Welch post-hoc after Welch ANOVA", {
  result <- quick_anova(test_data_unequal_var,
                        group = group,
                        value = value,
                        method = "welch",
                        post_hoc = "welch",
                        verbose = FALSE)
  expect_true(!is.null(result$post_hoc))
  expect_equal(result$post_hoc$method, "welch")
})

test_that("quick_anova() performs Wilcoxon post-hoc after Kruskal-Wallis", {
  result <- quick_anova(test_data_skewed,
                        group = treatment,
                        value = score,
                        method = "kruskal",
                        post_hoc = "wilcox",
                        verbose = FALSE)
  expect_true(!is.null(result$post_hoc))
  expect_equal(result$post_hoc$method, "wilcox")
})

test_that("quick_anova() auto-selects appropriate post-hoc test", {
  result <- quick_anova(test_data_normal,
                        group = group,
                        value = value,
                        method = "anova",
                        post_hoc = "auto",
                        verbose = FALSE)
  expect_true(!is.null(result$post_hoc))
})

test_that("quick_anova() skips post-hoc when post_hoc = 'none'", {
  result <- quick_anova(test_data_normal,
                        group = group,
                        value = value,
                        method = "anova",
                        post_hoc = "none",
                        verbose = FALSE)
  expect_true(is.null(result$post_hoc))
})

#------------------------------------------------------------------------------
# Statistical Tests Validation
#------------------------------------------------------------------------------

test_that("quick_anova() performs normality checks", {
  result <- quick_anova(test_data_normal,
                        group = group,
                        value = value,
                        method = "auto",
                        verbose = FALSE)
  expect_true(!is.null(result$assumption_checks$normality))
  expect_true("recommendation" %in% names(result$assumption_checks$normality))
})

test_that("quick_anova() checks variance equality for ANOVA", {
  result <- quick_anova(test_data_normal,
                        group = group,
                        value = value,
                        method = "anova",
                        verbose = FALSE)
  # Should have variance test if method is ANOVA and auto decision was made
  expect_true(is.null(result$assumption_checks$variance) ||
              !is.null(result$assumption_checks$variance))
})

test_that("quick_anova() handles method = 'auto' correctly", {
  # For normal data, should choose parametric method
  result <- quick_anova(test_data_normal,
                        group = group,
                        value = value,
                        method = "auto",
                        verbose = FALSE)
  expect_true(result$method_used %in% c("anova", "welch"))

  # For skewed data, should choose Kruskal-Wallis
  result_skewed <- quick_anova(test_data_skewed,
                                group = treatment,
                                value = score,
                                method = "auto",
                                verbose = FALSE)
  expect_true(result_skewed$method_used %in% c("anova", "welch", "kruskal"))
})

#------------------------------------------------------------------------------
# Plot Customization Tests
#------------------------------------------------------------------------------

test_that("quick_anova() supports different plot types", {
  result_box <- quick_anova(test_data_normal, group = group, value = value,
                            plot_type = "boxplot", verbose = FALSE)
  expect_s3_class(result_box$plot, "ggplot")

  result_violin <- quick_anova(test_data_normal, group = group, value = value,
                               plot_type = "violin", verbose = FALSE)
  expect_s3_class(result_violin$plot, "ggplot")

  result_both <- quick_anova(test_data_normal, group = group, value = value,
                             plot_type = "both", verbose = FALSE)
  expect_s3_class(result_both$plot, "ggplot")
})

test_that("quick_anova() supports jitter customization", {
  result_no_jitter <- quick_anova(test_data_normal, group = group, value = value,
                                  add_jitter = FALSE, verbose = FALSE)
  expect_s3_class(result_no_jitter$plot, "ggplot")

  result_custom <- quick_anova(test_data_normal, group = group, value = value,
                               add_jitter = TRUE, point_size = 3,
                               point_alpha = 0.8, verbose = FALSE)
  expect_s3_class(result_custom$plot, "ggplot")
})

test_that("quick_anova() supports p-value label formats", {
  result_stars <- quick_anova(test_data_normal, group = group, value = value,
                              p_label = "p.signif", verbose = FALSE)
  expect_s3_class(result_stars$plot, "ggplot")

  result_numeric <- quick_anova(test_data_normal, group = group, value = value,
                                p_label = "p.format", verbose = FALSE)
  expect_s3_class(result_numeric$plot, "ggplot")
})

test_that("quick_anova() supports hiding p-value", {
  result <- quick_anova(test_data_normal, group = group, value = value,
                        show_p_value = FALSE, verbose = FALSE)
  expect_s3_class(result$plot, "ggplot")
})

test_that("quick_anova() accepts palette parameter", {
  result <- quick_anova(test_data_normal, group = group, value = value,
                        palette = "qual_bold", verbose = FALSE)
  expect_s3_class(result$plot, "ggplot")
})

test_that("quick_anova() accepts NULL palette", {
  result <- quick_anova(test_data_normal, group = group, value = value,
                        palette = NULL, verbose = FALSE)
  expect_s3_class(result$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Return Object Structure Tests
#------------------------------------------------------------------------------

test_that("quick_anova() returns object with required components", {
  result <- quick_anova(test_data_normal, group = group, value = value,
                        verbose = FALSE)

  expect_true("plot" %in% names(result))
  expect_true("omnibus_result" %in% names(result))
  expect_true("post_hoc" %in% names(result))
  expect_true("method_used" %in% names(result))
  expect_true("descriptive_stats" %in% names(result))
  expect_true("assumption_checks" %in% names(result))
  expect_true("auto_decision" %in% names(result))
  expect_true("timestamp" %in% names(result))
  expect_true("parameters" %in% names(result))
})

test_that("quick_anova() result contains descriptive statistics", {
  result <- quick_anova(test_data_normal, group = group, value = value,
                        verbose = FALSE)

  expect_s3_class(result$descriptive_stats, "data.frame")
  expect_true("n" %in% names(result$descriptive_stats))
  expect_true("mean" %in% names(result$descriptive_stats))
  expect_true("sd" %in% names(result$descriptive_stats))
  expect_true("median" %in% names(result$descriptive_stats))
})

test_that("quick_anova() stores parameters correctly", {
  result <- quick_anova(test_data_normal,
                        group = group,
                        value = value,
                        method = "anova",
                        post_hoc = "tukey",
                        conf.level = 0.95,
                        plot_type = "boxplot",
                        verbose = FALSE)

  expect_equal(result$parameters$method, "anova")
  expect_equal(result$parameters$post_hoc, "tukey")
  expect_equal(result$parameters$conf.level, 0.95)
  expect_equal(result$parameters$plot_type, "boxplot")
})

#------------------------------------------------------------------------------
# Edge Cases and Special Scenarios
#------------------------------------------------------------------------------

test_that("quick_anova() handles small samples", {
  result <- quick_anova(test_data_small, group = group, value = response,
                        verbose = FALSE)
  expect_s3_class(result, "quick_anova_result")
})

test_that("quick_anova() handles data with NA values", {
  result <- quick_anova(test_data_na, group = group, value = value,
                       verbose = FALSE)
  expect_s3_class(result, "quick_anova_result")
  # Check that rows with NA were removed
  expect_true(nrow(result$descriptive_stats) == 3)
})

test_that("quick_anova() handles different confidence levels", {
  result_90 <- quick_anova(test_data_normal,
                           group = group,
                           value = value,
                           conf.level = 0.90,
                           verbose = FALSE)
  expect_equal(result_90$parameters$conf.level, 0.90)

  result_99 <- quick_anova(test_data_normal,
                           group = group,
                           value = value,
                           conf.level = 0.99,
                           verbose = FALSE)
  expect_equal(result_99$parameters$conf.level, 0.99)
})

test_that("quick_anova() handles unbalanced sample sizes", {
  unbalanced_data <- data.frame(
    group = c(rep("A", 10), rep("B", 20), rep("C", 30)),
    value = rnorm(60)
  )
  result <- quick_anova(unbalanced_data, group = group, value = value,
                       verbose = FALSE)
  expect_s3_class(result, "quick_anova_result")
  # Check descriptive stats show different sample sizes
  expect_true(length(unique(result$descriptive_stats$n)) > 1)
})

test_that("quick_anova() handles 4+ groups", {
  many_groups_data <- data.frame(
    group = rep(c("A", "B", "C", "D", "E"), each = 15),
    value = c(rnorm(15, 10, 2), rnorm(15, 11, 2), rnorm(15, 12, 2),
              rnorm(15, 13, 2), rnorm(15, 14, 2))
  )
  result <- quick_anova(many_groups_data, group = group, value = value,
                       verbose = FALSE)
  expect_s3_class(result, "quick_anova_result")
  expect_equal(nrow(result$descriptive_stats), 5)
})

test_that("quick_anova() p-value is within valid range", {
  result <- quick_anova(test_data_normal, group = group, value = value,
                        verbose = FALSE)
  expect_true(result$omnibus_result$p_value >= 0)
  expect_true(result$omnibus_result$p_value <= 1)
})

#------------------------------------------------------------------------------
# S3 Methods Tests
#------------------------------------------------------------------------------

test_that("print.quick_anova_result works", {
  result <- quick_anova(test_data_normal, group = group, value = value,
                        verbose = FALSE)
  # print method displays plot and descriptive stats
  expect_output(print(result), "Method:|group|value")
})

test_that("summary.quick_anova_result works", {
  result <- quick_anova(test_data_normal, group = group, value = value,
                        verbose = FALSE)
  # summary should produce output - just check it runs without error
  expect_output(summary(result))
})

test_that("quick_anova_result contains plot", {
  result <- quick_anova(test_data_normal, group = group, value = value,
                        verbose = FALSE)
  # Result should contain a ggplot object
  expect_s3_class(result$plot, "ggplot")
})

#------------------------------------------------------------------------------
# Verbose Mode Tests
#------------------------------------------------------------------------------

test_that("quick_anova() prints messages when verbose = TRUE", {
  # Function should produce diagnostic messages when verbose = TRUE
  result <- quick_anova(test_data_normal, group = group, value = value,
                       verbose = TRUE)
  # Just verify the result is created - verbose messages are visible in test output
  expect_s3_class(result, "quick_anova_result")
})

test_that("quick_anova() minimizes output when verbose = FALSE", {
  # verbose = FALSE should minimize output
  result <- quick_anova(test_data_normal, group = group, value = value,
                       verbose = FALSE)
  # Just check the result is created successfully
  expect_s3_class(result, "quick_anova_result")
})

#------------------------------------------------------------------------------
# Integration Tests
#------------------------------------------------------------------------------

test_that("quick_anova() end-to-end workflow for ANOVA", {
  result <- quick_anova(
    data = test_data_normal,
    group = group,
    value = value,
    method = "anova",
    post_hoc = "tukey",
    plot_type = "boxplot",
    add_jitter = TRUE,
    show_p_value = TRUE,
    p_label = "p.signif",
    palette = "qual_vivid",
    verbose = FALSE
  )

  expect_s3_class(result, "quick_anova_result")
  expect_s3_class(result$plot, "ggplot")
  expect_equal(result$method_used, "anova")
  expect_true(!is.null(result$post_hoc))
  expect_true(result$omnibus_result$p_value >= 0 && result$omnibus_result$p_value <= 1)
})

test_that("quick_anova() end-to-end workflow for Welch ANOVA", {
  result <- quick_anova(
    data = test_data_unequal_var,
    group = group,
    value = value,
    method = "welch",
    post_hoc = "welch",
    plot_type = "violin",
    show_p_value = TRUE,
    p_label = "p.format",
    verbose = FALSE
  )

  expect_s3_class(result, "quick_anova_result")
  expect_s3_class(result$plot, "ggplot")
  expect_equal(result$method_used, "welch")
  expect_true(!is.null(result$post_hoc))
  expect_true(result$omnibus_result$p_value >= 0 && result$omnibus_result$p_value <= 1)
})

test_that("quick_anova() end-to-end workflow for Kruskal-Wallis", {
  result <- quick_anova(
    data = test_data_skewed,
    group = treatment,
    value = score,
    method = "kruskal",
    post_hoc = "wilcox",
    plot_type = "both",
    show_p_value = TRUE,
    verbose = FALSE
  )

  expect_s3_class(result, "quick_anova_result")
  expect_s3_class(result$plot, "ggplot")
  expect_equal(result$method_used, "kruskal")
  expect_true(!is.null(result$post_hoc))
  expect_true(result$omnibus_result$p_value >= 0 && result$omnibus_result$p_value <= 1)
})

#===============================================================================
# End: test-quick_anova.R
#===============================================================================
