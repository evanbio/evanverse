# =============================================================================
# test-stat.R — Tests for all exported functions in R/stat.R
# =============================================================================

# Shared fixtures --------------------------------------------------------------

.ttest_df <- function(seed = 1L, n = 30L, diff = 1) {
  set.seed(seed)
  data.frame(
    group = rep(c("A", "B"), each = n),
    value = c(rnorm(n, mean = 0), rnorm(n, mean = diff))
  )
}

.paired_df <- function(seed = 2L, n = 20L) {
  set.seed(seed)
  data.frame(
    id    = rep(seq_len(n), 2L),
    group = rep(c("pre", "post"), each = n),
    value = c(rnorm(n, 0), rnorm(n, 1))
  )
}

.anova_df <- function(seed = 3L, n = 25L) {
  set.seed(seed)
  data.frame(
    group = rep(LETTERS[1:3], each = n),
    value = c(rnorm(n, 0), rnorm(n, 0.5), rnorm(n, 1.2))
  )
}

.chisq_df <- function(seed = 4L, n = 100L) {
  set.seed(seed)
  data.frame(
    treatment = sample(c("A", "B", "C"), n, replace = TRUE),
    response  = sample(c("Yes", "No"), n, replace = TRUE,
                       prob = c(0.6, 0.4))
  )
}

.cor_df <- function(seed = 5L, n = 50L) {
  set.seed(seed)
  data.frame(
    x1 = rnorm(n),
    x2 = rnorm(n),
    x3 = rnorm(n),
    x4 = rnorm(n)
  )
}


# =============================================================================
# stat_power
# =============================================================================

test_that("stat_power returns power_result with computed = 'power'", {
  res <- stat_power(n = 30, effect_size = 0.5)
  expect_s3_class(res, "power_result")
  expect_equal(res$computed, "power")
  expect_true(res$power >= 0 && res$power <= 1)
})

test_that("stat_power power increases with larger n", {
  p_small <- stat_power(n = 10,  effect_size = 0.5)$power
  p_large <- stat_power(n = 100, effect_size = 0.5)$power
  expect_gt(p_large, p_small)
})

test_that("stat_power power increases with larger effect_size", {
  p_small <- stat_power(n = 30, effect_size = 0.2)$power
  p_large <- stat_power(n = 30, effect_size = 0.8)$power
  expect_gt(p_large, p_small)
})

test_that("stat_power works for all test types", {
  expect_no_error(stat_power(n = 30, effect_size = 0.5, test = "t_two"))
  expect_no_error(stat_power(n = 30, effect_size = 0.5, test = "t_one"))
  expect_no_error(stat_power(n = 30, effect_size = 0.5, test = "t_paired"))
  expect_no_error(stat_power(n = 30, effect_size = 0.5, test = "proportion"))
  expect_no_error(stat_power(n = 30, effect_size = 0.3, test = "correlation"))
  expect_no_error(stat_power(n = 30, effect_size = 0.25, test = "anova", k = 3))
  expect_no_error(stat_power(n = 30, effect_size = 0.3, test = "chisq", df = 2))
})

test_that("stat_power works with one-sided alternative", {
  res <- stat_power(n = 30, effect_size = 0.5, alternative = "greater")
  expect_s3_class(res, "power_result")
})

test_that("stat_power result has expected list structure", {
  res <- stat_power(n = 30, effect_size = 0.5)
  expect_true(all(c("params", "power", "computed", "interpretation") %in% names(res)))
  expect_equal(res$params$n, 30L)
  expect_equal(res$params$effect_size, 0.5)
})

test_that("stat_power errors when k missing for anova", {
  expect_error(stat_power(n = 30, effect_size = 0.25, test = "anova"),
               class = "rlang_error")
})

test_that("stat_power errors when df missing for chisq", {
  expect_error(stat_power(n = 30, effect_size = 0.3, test = "chisq"),
               class = "rlang_error")
})

test_that("stat_power errors when effect_size > 1 for correlation", {
  expect_error(stat_power(n = 30, effect_size = 1.2, test = "correlation"),
               class = "rlang_error")
})

test_that("stat_power errors on non-positive effect_size", {
  expect_error(stat_power(n = 30, effect_size = 0),  class = "rlang_error")
  expect_error(stat_power(n = 30, effect_size = -1), class = "rlang_error")
})

test_that("stat_power errors on invalid n", {
  expect_error(stat_power(n = 0,  effect_size = 0.5), class = "rlang_error")
  expect_error(stat_power(n = -5, effect_size = 0.5), class = "rlang_error")
})

test_that("stat_power warns when alternative ignored for anova/chisq", {
  expect_warning(
    stat_power(n = 30, effect_size = 0.25, test = "anova",
               k = 3, alternative = "greater")
  )
  expect_warning(
    stat_power(n = 50, effect_size = 0.3, test = "chisq",
               df = 1, alternative = "less")
  )
})

test_that("stat_power print method runs without error", {
  res <- stat_power(n = 30, effect_size = 0.5)
  expect_no_error(print(res))
  expect_invisible(print(res))
})

test_that("stat_power summary method runs without error", {
  res <- stat_power(n = 30, effect_size = 0.5)
  expect_no_error(summary(res))
  expect_invisible(summary(res))
})

test_that("plot.power_result runs without error", {
  res <- stat_power(n = 30, effect_size = 0.5)
  expect_no_error(plot(res))
  expect_invisible(plot(res))
})


# =============================================================================
# stat_n
# =============================================================================

test_that("stat_n returns power_result with computed = 'n'", {
  res <- stat_n(power = 0.8, effect_size = 0.5)
  expect_s3_class(res, "power_result")
  expect_equal(res$computed, "n")
  expect_true(is.integer(res$n))
  expect_true(res$n > 0L)
})

test_that("stat_n n increases as effect_size decreases", {
  n_large <- stat_n(power = 0.8, effect_size = 0.2)$n
  n_small <- stat_n(power = 0.8, effect_size = 0.8)$n
  expect_gt(n_large, n_small)
})

test_that("stat_n n increases as power target increases", {
  n_low  <- stat_n(power = 0.6, effect_size = 0.5)$n
  n_high <- stat_n(power = 0.95, effect_size = 0.5)$n
  expect_gt(n_high, n_low)
})

test_that("stat_n works for all test types", {
  expect_no_error(stat_n(power = 0.8, effect_size = 0.5, test = "t_two"))
  expect_no_error(stat_n(power = 0.8, effect_size = 0.5, test = "t_one"))
  expect_no_error(stat_n(power = 0.8, effect_size = 0.5, test = "t_paired"))
  expect_no_error(stat_n(power = 0.8, effect_size = 0.5, test = "proportion"))
  expect_no_error(stat_n(power = 0.8, effect_size = 0.3, test = "correlation"))
  expect_no_error(stat_n(power = 0.8, effect_size = 0.25, test = "anova", k = 3))
  expect_no_error(stat_n(power = 0.8, effect_size = 0.3, test = "chisq", df = 1))
})

test_that("stat_n result is a positive integer", {
  res <- stat_n(power = 0.8, effect_size = 0.5)
  expect_true(res$n >= 1L)
  expect_equal(res$n, as.integer(res$n))
})

test_that("stat_n errors when k missing for anova", {
  expect_error(stat_n(power = 0.8, effect_size = 0.25, test = "anova"),
               class = "rlang_error")
})

test_that("stat_n errors when df missing for chisq", {
  expect_error(stat_n(power = 0.8, effect_size = 0.3, test = "chisq"),
               class = "rlang_error")
})

test_that("stat_n errors on invalid power (outside 0–1)", {
  expect_error(stat_n(power = 0,    effect_size = 0.5), class = "rlang_error")
  expect_error(stat_n(power = 1.1,  effect_size = 0.5), class = "rlang_error")
  expect_error(stat_n(power = -0.1, effect_size = 0.5), class = "rlang_error")
})

test_that("stat_n print method runs without error", {
  res <- stat_n(power = 0.8, effect_size = 0.5)
  expect_no_error(print(res))
  expect_invisible(print(res))
})

test_that("stat_n summary method runs without error", {
  res <- stat_n(power = 0.8, effect_size = 0.5)
  expect_no_error(summary(res))
  expect_invisible(summary(res))
})

test_that("plot.power_result runs for sample-size results", {
  res <- stat_n(power = 0.8, effect_size = 0.5)
  expect_no_error(plot(res))
  expect_invisible(plot(res))
})

test_that("stat_power and stat_n are inverse-consistent", {
  # stat_n gives n; plugging that n back into stat_power should recover ~80%
  n_req <- stat_n(power = 0.8, effect_size = 0.5)$n
  pwr   <- stat_power(n = n_req, effect_size = 0.5)$power
  expect_gte(pwr, 0.78)  # allow small numeric tolerance
})


# =============================================================================
# quick_ttest
# =============================================================================

test_that("quick_ttest returns quick_ttest_result class", {
  res <- quick_ttest(.ttest_df(), "group", "value")
  expect_s3_class(res, "quick_ttest_result")
})

test_that("quick_ttest returns invisibly", {
  expect_invisible(quick_ttest(.ttest_df(), "group", "value"))
})

test_that("quick_ttest result has expected structure", {
  res <- quick_ttest(.ttest_df(), "group", "value")
  expect_true(all(c("test_result", "method_used", "descriptive_stats",
                    "normality_tests", "params", "data") %in% names(res)))
})

test_that("quick_ttest auto method populates normality_tests", {
  res <- quick_ttest(.ttest_df(), "group", "value", method = "auto")
  expect_false(is.null(res$normality_tests))
  expect_true("recommendation" %in% names(res$normality_tests))
})

test_that("quick_ttest forced method leaves normality_tests NULL", {
  res <- quick_ttest(.ttest_df(), "group", "value", method = "t.test")
  expect_null(res$normality_tests)
})

test_that("quick_ttest forced wilcox.test uses Wilcoxon", {
  res <- quick_ttest(.ttest_df(), "group", "value", method = "wilcox.test")
  expect_equal(res$method_used, "wilcox.test")
})

test_that("quick_ttest handles constant groups in normality diagnostics", {
  df <- data.frame(
    group = rep(c("A", "B"), each = 10L),
    value = c(rep(1, 10), rnorm(10))
  )
  expect_message(
    res <- quick_ttest(df, "group", "value", method = "auto"),
    regexp = "constant group"
  )
  expect_s3_class(res, "quick_ttest_result")
})

test_that("quick_ttest wilcox.test is quiet with ties", {
  df <- data.frame(
    group = rep(c("A", "B"), each = 3L),
    value = c(1, 1, 2, 3, 4, 5)
  )
  expect_no_warning(quick_ttest(df, "group", "value", method = "wilcox.test"))
})

test_that("quick_ttest descriptive_stats has two rows (one per group)", {
  res <- quick_ttest(.ttest_df(), "group", "value")
  expect_equal(nrow(res$descriptive_stats), 2L)
})

test_that("quick_ttest p.value is in (0, 1)", {
  res <- quick_ttest(.ttest_df(), "group", "value")
  p   <- res$test_result$p.value
  expect_true(is.numeric(p) && p >= 0 && p <= 1)
})

test_that("quick_ttest detects significant difference (large effect)", {
  set.seed(99)
  df  <- data.frame(
    group = rep(c("A", "B"), each = 50L),
    value = c(rnorm(50, 0), rnorm(50, 3))
  )
  res <- quick_ttest(df, "group", "value", method = "t.test")
  expect_lt(res$test_result$p.value, 0.05)
})

test_that("quick_ttest one-sided alternative is stored in params", {
  res <- quick_ttest(.ttest_df(), "group", "value", alternative = "greater")
  expect_equal(res$params$alternative, "greater")
})

test_that("quick_ttest paired test with id_col works", {
  res <- quick_ttest(.paired_df(), "group", "value",
                     paired = TRUE, id_col = "id", method = "t.test")
  expect_s3_class(res, "quick_ttest_result")
  expect_true(res$params$paired)
})

test_that("quick_ttest errors when group_col is not character", {
  expect_error(
    quick_ttest(.ttest_df(), group_col = 1L, value_col = "value"),
    class = "rlang_error"
  )
})

test_that("quick_ttest errors when column not found in data", {
  expect_error(
    quick_ttest(.ttest_df(), "missing_col", "value"),
    class = "rlang_error"
  )
})

test_that("quick_ttest errors when paired = TRUE and id_col is NULL", {
  expect_error(
    quick_ttest(.ttest_df(), "group", "value", paired = TRUE),
    class = "rlang_error"
  )
})

test_that("quick_ttest errors on non-data.frame input", {
  expect_error(
    quick_ttest(list(group = "A", value = 1), "group", "value"),
    class = "rlang_error"
  )
})

test_that("quick_ttest print method runs without error", {
  res <- quick_ttest(.ttest_df(), "group", "value")
  expect_no_error(print(res))
  expect_invisible(print(res))
})

test_that("quick_ttest summary method runs without error", {
  res <- quick_ttest(.ttest_df(), "group", "value")
  expect_no_error(summary(res))
  expect_invisible(summary(res))
})

test_that("plot.quick_ttest_result runs without error", {
  res <- quick_ttest(.ttest_df(), "group", "value")
  expect_no_error(plot(res, show_p_value = FALSE))
  expect_invisible(plot(res, show_p_value = FALSE))
})


# =============================================================================
# quick_anova
# =============================================================================

test_that("quick_anova returns quick_anova_result class", {
  res <- quick_anova(.anova_df(), "group", "value")
  expect_s3_class(res, "quick_anova_result")
})

test_that("quick_anova returns invisibly", {
  expect_invisible(quick_anova(.anova_df(), "group", "value"))
})

test_that("quick_anova result has expected structure", {
  res <- quick_anova(.anova_df(), "group", "value")
  expect_true(all(c("omnibus_result", "post_hoc", "method_used",
                    "descriptive_stats", "assumption_checks",
                    "params", "data") %in% names(res)))
})

test_that("quick_anova auto selects one of three methods", {
  res <- quick_anova(.anova_df(), "group", "value", method = "auto")
  expect_true(res$method_used %in% c("anova", "welch", "kruskal"))
})

test_that("quick_anova forced anova method is respected", {
  res <- quick_anova(.anova_df(), "group", "value", method = "anova")
  expect_equal(res$method_used, "anova")
})

test_that("quick_anova forced kruskal method is respected", {
  res <- quick_anova(.anova_df(), "group", "value", method = "kruskal")
  expect_equal(res$method_used, "kruskal")
})

test_that("quick_anova handles constant groups in normality diagnostics", {
  df <- data.frame(
    group = rep(LETTERS[1:3], each = 10L),
    value = c(rep(1, 10), rep(2, 10), rnorm(10))
  )
  expect_message(
    res <- quick_anova(df, "group", "value", method = "kruskal", post_hoc = "none"),
    regexp = "constant group"
  )
  expect_s3_class(res, "quick_anova_result")
  expect_equal(res$method_used, "kruskal")
})

test_that("quick_anova kruskal epsilon-squared uses H-based group formula", {
  df <- data.frame(
    group = rep(LETTERS[1:3], each = 10L),
    value = c(seq_len(10), 101:110, 201:210)
  )
  res <- quick_anova(df, "group", "value", method = "kruskal", post_hoc = "none")
  expect_gt(res$omnibus_result$effect_size$epsilon_squared, 0.8)
})

test_that("quick_anova p_value is in (0, 1)", {
  res <- quick_anova(.anova_df(), "group", "value")
  p   <- res$omnibus_result$p_value
  expect_true(is.numeric(p) && p >= 0 && p <= 1)
})

test_that("quick_anova descriptive_stats has one row per group", {
  res <- quick_anova(.anova_df(), "group", "value")
  expect_equal(nrow(res$descriptive_stats), 3L)
})

test_that("quick_anova post_hoc = 'none' returns NULL post_hoc", {
  res <- quick_anova(.anova_df(), "group", "value", post_hoc = "none")
  expect_null(res$post_hoc)
})

test_that("quick_anova post_hoc tukey runs for classical anova", {
  res <- quick_anova(.anova_df(), "group", "value",
                     method = "anova", post_hoc = "tukey")
  expect_false(is.null(res$post_hoc))
})

test_that("quick_anova assumption_checks includes normality results", {
  res <- quick_anova(.anova_df(), "group", "value")
  expect_false(is.null(res$assumption_checks$normality))
})

test_that("quick_anova errors when group_col not character", {
  expect_error(
    quick_anova(.anova_df(), group_col = 1L, value_col = "value"),
    class = "rlang_error"
  )
})

test_that("quick_anova errors when column not found in data", {
  expect_error(
    quick_anova(.anova_df(), "no_such_col", "value"),
    class = "rlang_error"
  )
})

test_that("quick_anova errors on non-data.frame input", {
  expect_error(
    quick_anova(list(group = "A", value = 1), "group", "value"),
    class = "rlang_error"
  )
})

test_that("quick_anova print method runs without error", {
  res <- quick_anova(.anova_df(), "group", "value")
  expect_no_error(print(res))
  expect_invisible(print(res))
})

test_that("quick_anova summary method runs without error", {
  res <- quick_anova(.anova_df(), "group", "value")
  expect_no_error(summary(res))
  expect_invisible(summary(res))
})

test_that("plot.quick_anova_result runs without error", {
  res <- quick_anova(.anova_df(), "group", "value")
  expect_no_error(plot(res, show_p_value = FALSE))
  expect_invisible(plot(res, show_p_value = FALSE))
})


# =============================================================================
# quick_chisq
# =============================================================================

test_that("quick_chisq returns quick_chisq_result class", {
  res <- quick_chisq(.chisq_df(), "treatment", "response")
  expect_s3_class(res, "quick_chisq_result")
})

test_that("quick_chisq returns invisibly", {
  expect_invisible(quick_chisq(.chisq_df(), "treatment", "response"))
})

test_that("quick_chisq result has expected structure", {
  res <- quick_chisq(.chisq_df(), "treatment", "response")
  expect_true(all(c("test_result", "method_used", "contingency_table",
                    "expected_freq", "params", "data") %in% names(res)))
})

test_that("quick_chisq auto method selects a recognised test", {
  res <- quick_chisq(.chisq_df(), "treatment", "response", method = "auto")
  expect_true(grepl("chi-square|Fisher|McNemar", res$method_used, ignore.case = TRUE))
})

test_that("quick_chisq forced chisq method is respected", {
  res <- quick_chisq(.chisq_df(), "treatment", "response", method = "chisq")
  expect_true(grepl("chi|chisq", res$method_used, ignore.case = TRUE))
})

test_that("quick_chisq p.value is in [0, 1]", {
  res <- quick_chisq(.chisq_df(), "treatment", "response")
  p   <- res$test_result$p.value
  expect_true(is.numeric(p) && p >= 0 && p <= 1)
})

test_that("quick_chisq contingency_table is a table of correct dimensions", {
  res <- quick_chisq(.chisq_df(), "treatment", "response")
  expect_true(inherits(res$contingency_table, "table"))
  expect_equal(length(dim(res$contingency_table)), 2L)
})

test_that("quick_chisq fisher method works on 2x2 table", {
  df  <- data.frame(
    x = c("A", "A", "B", "B"),
    y = c("Y", "N", "Y", "N")
  )
  # Fisher on small table
  expect_no_error(quick_chisq(df, "x", "y", method = "fisher"))
})

test_that("quick_chisq stores params correctly", {
  res <- quick_chisq(.chisq_df(), "treatment", "response", alpha = 0.01)
  expect_equal(res$params$alpha, 0.01)
  expect_equal(res$params$x_col, "treatment")
  expect_equal(res$params$y_col, "response")
})

test_that("quick_chisq errors when x_col is not character", {
  expect_error(
    quick_chisq(.chisq_df(), x_col = 1L, y_col = "response"),
    class = "rlang_error"
  )
})

test_that("quick_chisq errors when column not found in data", {
  expect_error(
    quick_chisq(.chisq_df(), "no_such_col", "response"),
    class = "rlang_error"
  )
})

test_that("quick_chisq errors on non-data.frame input", {
  expect_error(
    quick_chisq(list(x = "A", y = "Y"), "x", "y"),
    class = "rlang_error"
  )
})

test_that("quick_chisq print method runs without error", {
  res <- quick_chisq(.chisq_df(), "treatment", "response")
  expect_no_error(print(res))
  expect_invisible(print(res))
})

test_that("quick_chisq summary method runs without error", {
  res <- quick_chisq(.chisq_df(), "treatment", "response")
  expect_no_error(summary(res))
  expect_invisible(summary(res))
})

test_that("plot.quick_chisq_result runs without error", {
  res <- quick_chisq(.chisq_df(), "treatment", "response")
  expect_no_error(plot(res, show_p_value = FALSE))
  expect_invisible(plot(res, show_p_value = FALSE))
})


# =============================================================================
# quick_cor
# =============================================================================

test_that("quick_cor returns quick_cor_result class", {
  res <- quick_cor(.cor_df())
  expect_s3_class(res, "quick_cor_result")
})

test_that("quick_cor returns invisibly", {
  expect_invisible(quick_cor(.cor_df()))
})

test_that("quick_cor result has expected structure", {
  res <- quick_cor(.cor_df())
  expect_true(all(c("cor_matrix", "p_matrix", "p_adjusted",
                    "method_used", "significant_pairs",
                    "descriptive_stats", "params", "data") %in% names(res)))
})

test_that("quick_cor cor_matrix is symmetric with 1 on diagonal", {
  res <- quick_cor(.cor_df())
  m   <- res$cor_matrix
  expect_equal(m, t(m))
  expect_equal(unname(diag(m)), rep(1, ncol(m)))
})

test_that("quick_cor cor_matrix values are in [-1, 1]", {
  res <- quick_cor(.cor_df())
  expect_true(all(abs(res$cor_matrix) <= 1 + 1e-10))
})

test_that("quick_cor works with explicit vars", {
  res <- quick_cor(.cor_df(), vars = c("x1", "x2", "x3"))
  expect_equal(ncol(res$cor_matrix), 3L)
  expect_equal(res$params$n_vars, 3L)
})

test_that("quick_cor spearman method is respected", {
  res <- quick_cor(.cor_df(), method = "spearman")
  expect_equal(res$method_used, "spearman")
})

test_that("quick_cor kendall method is respected", {
  res <- quick_cor(.cor_df(), method = "kendall")
  expect_equal(res$method_used, "kendall")
})

test_that("quick_cor p_adjust_method BH produces adjusted p-values", {
  res <- quick_cor(.cor_df(), p_adjust_method = "BH")
  expect_false(is.null(res$p_adjusted))
})

test_that("quick_cor p_adjust_method none leaves p_adjusted NULL", {
  res <- quick_cor(.cor_df(), p_adjust_method = "none")
  expect_null(res$p_adjusted)
})

test_that("quick_cor errors on invalid missing-value handling", {
  expect_error(
    quick_cor(.cor_df(), use = "bad.use"),
    class = "rlang_error"
  )
})

test_that("quick_cor significant_pairs is a data.frame with expected columns", {
  res <- quick_cor(.cor_df())
  expect_s3_class(res$significant_pairs, "data.frame")
  expect_true(all(c("var1", "var2", "correlation", "p_value") %in%
                    names(res$significant_pairs)))
})

test_that("quick_cor significant_pairs sorted ascending by p_value", {
  set.seed(10)
  df  <- data.frame(
    a = rnorm(80), b = rnorm(80), c = rnorm(80),
    d = rnorm(80), e = rnorm(80)
  )
  res <- quick_cor(df)
  sp  <- res$significant_pairs
  # always assert: either no pairs, or pairs are sorted by ascending p_value
  expect_true(nrow(sp) == 0L || all(diff(sp$p_value) >= 0))
})

test_that("quick_cor uses all numeric columns when vars = NULL", {
  res <- quick_cor(.cor_df())
  expect_equal(res$params$n_vars, 4L)
})

test_that("quick_cor descriptive_stats has one row per variable", {
  res <- quick_cor(.cor_df())
  expect_equal(nrow(res$descriptive_stats), 4L)
  expect_true("variable" %in% names(res$descriptive_stats))
})

test_that("quick_cor errors when data has no numeric columns", {
  df <- data.frame(a = letters[1:5], b = letters[6:10])
  expect_error(quick_cor(df), class = "rlang_error")
})

test_that("quick_cor errors when fewer than 2 vars remain", {
  df <- data.frame(a = rnorm(10), b = letters[1:10])
  expect_error(quick_cor(df, vars = c("a", "b")), class = "rlang_error")
})

test_that("quick_cor errors when specified vars are not in data", {
  expect_error(
    quick_cor(.cor_df(), vars = c("x1", "x_missing")),
    class = "rlang_error"
  )
})

test_that("quick_cor errors on non-data.frame input", {
  expect_error(quick_cor(list(a = 1:5, b = 1:5)), class = "rlang_error")
})

test_that("quick_cor print method runs without error", {
  res <- quick_cor(.cor_df())
  expect_no_error(print(res))
  expect_invisible(print(res))
})

test_that("quick_cor summary method runs without error", {
  res <- quick_cor(.cor_df())
  expect_no_error(summary(res))
  expect_invisible(summary(res))
})

test_that("plot.quick_cor_result runs without error", {
  skip_if_not_installed("ggcorrplot")
  res <- quick_cor(.cor_df())
  expect_no_error(plot(res, show_sig = FALSE))
  expect_invisible(plot(res, show_sig = FALSE))
})

test_that("plot.quick_cor_result errors when sig_level length != 3", {
  res <- quick_cor(.cor_df())
  expect_error(
    plot(res, sig_level = c(0.01, 0.05)),
    class = "rlang_error"
  )
})

test_that("plot.quick_cor_result errors when show_coef and show_sig both TRUE", {
  res <- quick_cor(.cor_df())
  expect_error(
    plot(res, show_coef = TRUE, show_sig = TRUE),
    class = "rlang_error"
  )
})
