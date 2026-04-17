# =============================================================================
# stat.R — Combinatorics and statistical utilities
# =============================================================================

#' Calculate Statistical Power
#'
#' Computes statistical power for a planned study given sample size, effect size,
#' and design parameters. Supports t-tests (two-sample, one-sample, paired),
#' ANOVA, proportion tests, correlation tests, and chi-square tests.
#'
#' @param n Integer. Sample size. Interpretation depends on test:
#'   \itemize{
#'     \item \code{"t_two"}, \code{"anova"}: per group
#'     \item \code{"t_paired"}: number of pairs
#'     \item all others: total
#'   }
#' @param effect_size Numeric. Effect size appropriate for the chosen test
#'   (must be positive). Conventions:
#'   \itemize{
#'     \item Cohen's d for t-tests (small 0.2, medium 0.5, large 0.8)
#'     \item Cohen's f for ANOVA (small 0.1, medium 0.25, large 0.4)
#'     \item Cohen's h for proportion tests (small 0.2, medium 0.5, large 0.8)
#'     \item Pearson r for correlation (small 0.1, medium 0.3, large 0.5)
#'     \item Cohen's w for chi-square (small 0.1, medium 0.3, large 0.5)
#'   }
#' @param test Character. Test type:
#'   \code{"t_two"} (two-sample t-test, default), \code{"t_one"}
#'   (one-sample t-test), \code{"t_paired"} (paired t-test),
#'   \code{"anova"}, \code{"proportion"}, \code{"correlation"},
#'   or \code{"chisq"}.
#' @param alternative Character. Direction of the alternative hypothesis:
#'   \code{"two.sided"} (default), \code{"less"}, or \code{"greater"}.
#'   Ignored for \code{"anova"} and \code{"chisq"}.
#' @param alpha Numeric. Significance level (Type I error rate). Default: 0.05.
#' @param k Integer \eqn{\ge 2}. Number of groups. Required when
#'   \code{test = "anova"}.
#' @param df Integer \eqn{\ge 1}. Degrees of freedom. Required when
#'   \code{test = "chisq"}.
#'
#' @return An object of class \code{"power_result"} (invisibly) containing:
#'   \describe{
#'     \item{\code{params}}{Named list of all input parameters}
#'     \item{\code{power}}{Computed statistical power (numeric in \code{[0, 1]})}
#'     \item{\code{computed}}{\code{"power"} — distinguishes from
#'       \code{stat_n()} results where \code{computed = "n"}}
#'     \item{\code{interpretation}}{Plain-text interpretation of the power value}
#'     \item{\code{recommendation}}{Actionable recommendation, or \code{NULL}
#'       when power is between 0.8 and 0.95}
#'   }
#'   Use \code{print(result)} for a brief summary, \code{summary(result)} for
#'   full details, and \code{plot(result)} to display the power curve.
#'
#' @examples
#' \dontrun{
#' result <- stat_power(n = 30, effect_size = 0.5)
#' print(result)
#' summary(result)
#' plot(result)
#'
#' stat_power(n = 25, effect_size = 0.25, test = "anova", k = 3)
#' stat_power(n = 50, effect_size = 0.3,  test = "correlation",
#'            alternative = "greater")
#' }
#'
#' @export
stat_power <- function(n,
                       effect_size,
                       test        = c("t_two", "t_one", "t_paired",
                                       "anova", "proportion", "correlation", "chisq"),
                       alternative = c("two.sided", "less", "greater"),
                       alpha       = 0.05,
                       k           = NULL,
                       df          = NULL) {

  test        <- match.arg(test)
  alternative <- match.arg(alternative)

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  n <- .assert_count(n)
  .assert_positive_numeric(effect_size)
  .assert_proportion(alpha)

  if (test == "correlation" && effect_size > 1) {
    cli::cli_abort("{.arg effect_size} for correlation must be in (0, 1].", call = NULL)
  }

  if (test == "anova") {
    if (is.null(k))
      cli::cli_abort("{.arg k} (number of groups) is required for ANOVA.", call = NULL)
    k <- .assert_count_min(k, min = 2L)
  }

  if (test == "chisq") {
    if (is.null(df))
      cli::cli_abort("{.arg df} (degrees of freedom) is required for chi-square.", call = NULL)
    df <- .assert_count(df)
  }

  if (test %in% c("anova", "chisq") && alternative != "two.sided") {
    cli::cli_warn(
      c("{.arg alternative} is ignored for {.val {test}} tests.",
        "i" = "ANOVA and chi-square are inherently non-directional.")
    )
  }

  # ---------------------------------------------------------------------------
  # Power calculation
  # ---------------------------------------------------------------------------
  pwr_result <- tryCatch(
    .pwr_compute(
      n = n, power = NULL, effect_size = effect_size, test = test,
      alternative = alternative, alpha = alpha, k = k, df = df
    ),
    error = function(e)
      cli::cli_abort(
        c("Power calculation failed.", "x" = conditionMessage(e)), call = NULL
      )
  )

  invisible(structure(
    list(
      params = list(
        n           = n,
        effect_size = effect_size,
        test        = test,
        alternative = alternative,
        alpha       = alpha,
        k           = k,
        df          = df
      ),
      power          = pwr_result$power,
      computed       = "power",
      interpretation = .power_interp(pwr_result$power, effect_size),
      recommendation = .power_recommend(pwr_result$power, n, effect_size,
                                        test, alternative, alpha, k, df)
    ),
    class = "power_result"
  ))
}


# =============================================================================
# S3 Methods  (shared by stat_power() and stat_n())
# =============================================================================

#' @export
print.power_result <- function(x, ...) {
  label <- .test_label(x$params$test, x$params$k, x$params$df)

  if (x$computed == "power") {
    power_pct <- sprintf("%.1f%%", x$power * 100)
    if (x$power < 0.5) {
      cli::cli_alert_danger( "Power: {power_pct}  (very low) | {label}")
    } else if (x$power < 0.8) {
      cli::cli_alert_warning("Power: {power_pct}  (below 80%) | {label}")
    } else if (x$power < 0.95) {
      cli::cli_alert_success("Power: {power_pct}  (good) | {label}")
    } else {
      cli::cli_alert_success("Power: {power_pct}  (very high) | {label}")
    }
    n_label_str <- .n_label(x$params$n, x$params$test)
    cli::cli_text(
      "n = {n_label_str},  ",
      "effect size = {sprintf('%.3f', x$params$effect_size)},  ",
      "alpha = {sprintf('%.3f', x$params$alpha)}"
    )

  } else {
    # computed == "n"
    groups <- .n_groups(x$params$test, x$params$k)
    n_str  <- if (groups > 1L) {
      sprintf("n = %d %s  (%d total)", x$n, .n_unit(x$params$test), x$n * groups)
    } else {
      sprintf("n = %d %s", x$n, .n_unit(x$params$test))
    }
    cli::cli_alert_success("{n_str} | {label}")
    cli::cli_text(
      "Target power = {sprintf('%.0f%%', x$params$power * 100)},  ",
      "effect size = {sprintf('%.3f', x$params$effect_size)},  ",
      "alpha = {sprintf('%.3f', x$params$alpha)}"
    )
  }

  cli::cli_text("")
  cli::cli_text(x$interpretation)

  invisible(x)
}


#' @export
summary.power_result <- function(object, ...) {
  x <- object

  if (x$computed == "power") {
    cli::cli_h1("Statistical Power Analysis")

    cli::cli_h2("Parameters")
    cli::cli_dl(c(
      "Test"        = .test_label(x$params$test, x$params$k, x$params$df),
      "n"           = .n_label(x$params$n, x$params$test),
      "Effect size" = sprintf("%.4f", x$params$effect_size),
      "alpha"       = sprintf("%.4f", x$params$alpha),
      "Alternative" = x$params$alternative
    ))

    cli::cli_h2("Result")
    power_pct <- sprintf("%.2f%%", x$power * 100)
    if (x$power < 0.5) {
      cli::cli_alert_danger( "Power (1-beta): {power_pct}  (very low)")
    } else if (x$power < 0.8) {
      cli::cli_alert_warning("Power (1-beta): {power_pct}  (below 80% threshold)")
    } else if (x$power < 0.95) {
      cli::cli_alert_success("Power (1-beta): {power_pct}  (good)")
    } else {
      cli::cli_alert_success("Power (1-beta): {power_pct}  (very high)")
    }

  } else {
    # computed == "n"
    cli::cli_h1("Sample Size Estimation")

    cli::cli_h2("Parameters")
    cli::cli_dl(c(
      "Test"         = .test_label(x$params$test, x$params$k, x$params$df),
      "Target power" = sprintf("%.0f%%  (%.4f)", x$params$power * 100, x$params$power),
      "Effect size"  = sprintf("%.4f", x$params$effect_size),
      "alpha"        = sprintf("%.4f", x$params$alpha),
      "Alternative"  = x$params$alternative
    ))

    cli::cli_h2("Result")
    groups      <- .n_groups(x$params$test, x$params$k)
    n_unit_str  <- .n_unit(x$params$test)
    if (groups > 1L) {
      cli::cli_alert_success("n {n_unit_str}: {x$n}")
      cli::cli_alert_success("n total:              {x$n * groups}")
    } else {
      cli::cli_alert_success("n {n_unit_str}: {x$n}")
    }
  }

  cli::cli_h2("Interpretation")
  cli::cli_text(x$interpretation)

  if (!is.null(x$recommendation)) {
    cli::cli_h2("Recommendation")
    cli::cli_alert_info(x$recommendation)
  }

  cli::cli_text("")
  invisible(x)
}


#' @rdname stat_power
#' @export
#' @param x A \code{power_result} object returned by \code{stat_power()} or
#'   \code{stat_n()}.
#' @param y Ignored.
#' @param ... Additional arguments (currently unused).
#' @param plot_range Numeric vector of length 2. Custom axis range for the curve.
#'   For \code{stat_power()} results: range over sample sizes.
#'   For \code{stat_n()} results: range over effect sizes.
#'   \code{NULL} uses an automatic range.
plot.power_result <- function(x, y = NULL, plot_range = NULL, ...) {
  if (!is.null(plot_range)) {
    plot_range <- sort(plot_range)
    if (length(plot_range) != 2L || any(!is.finite(plot_range)) || plot_range[1] <= 0) {
      cli::cli_abort(
        "{.arg plot_range} must be a numeric vector of two positive values.", call = NULL
      )
    }
  }

  if (x$computed == "power") {
    print(.power_curve(
      n           = x$params$n,
      power       = x$power,
      effect_size = x$params$effect_size,
      alpha       = x$params$alpha,
      test        = x$params$test,
      alternative = x$params$alternative,
      k           = x$params$k,
      df          = x$params$df,
      plot_range  = plot_range
    ))
  } else {
    print(.n_curve(
      n           = x$n,
      power       = x$params$power,
      effect_size = x$params$effect_size,
      alpha       = x$params$alpha,
      test        = x$params$test,
      alternative = x$params$alternative,
      k           = x$params$k,
      df          = x$params$df,
      plot_range  = plot_range
    ))
  }

  invisible(x)
}


#' Calculate Required Sample Size
#'
#' Computes the minimum sample size needed to achieve a target statistical power
#' for detecting a given effect size. Supports t-tests (two-sample, one-sample,
#' paired), ANOVA, proportion tests, correlation tests, and chi-square tests.
#'
#' @param power Numeric. Target statistical power. Default: 0.8.
#' @param effect_size Numeric. Effect size appropriate for the chosen test
#'   (must be positive). Conventions:
#'   \itemize{
#'     \item Cohen's d for t-tests (small 0.2, medium 0.5, large 0.8)
#'     \item Cohen's f for ANOVA (small 0.1, medium 0.25, large 0.4)
#'     \item Cohen's h for proportion tests (small 0.2, medium 0.5, large 0.8)
#'     \item Pearson r for correlation (small 0.1, medium 0.3, large 0.5)
#'     \item Cohen's w for chi-square (small 0.1, medium 0.3, large 0.5)
#'   }
#' @param test Character. Test type:
#'   \code{"t_two"} (two-sample t-test, default), \code{"t_one"}
#'   (one-sample t-test), \code{"t_paired"} (paired t-test),
#'   \code{"anova"}, \code{"proportion"}, \code{"correlation"},
#'   or \code{"chisq"}.
#' @param alternative Character. Direction of the alternative hypothesis:
#'   \code{"two.sided"} (default), \code{"less"}, or \code{"greater"}.
#'   Ignored for \code{"anova"} and \code{"chisq"}.
#' @param alpha Numeric. Significance level (Type I error rate). Default: 0.05.
#' @param k Integer \eqn{\ge 2}. Number of groups. Required when
#'   \code{test = "anova"}.
#' @param df Integer \eqn{\ge 1}. Degrees of freedom. Required when
#'   \code{test = "chisq"}.
#'
#' @return An object of class \code{"power_result"} (invisibly) containing:
#'   \describe{
#'     \item{\code{params}}{Named list of all input parameters}
#'     \item{\code{n}}{Required sample size, rounded up. Per group for
#'       \code{"t_two"} and \code{"anova"}; number of pairs for
#'       \code{"t_paired"}; total for all others.}
#'     \item{\code{computed}}{\code{"n"} — distinguishes from \code{stat_power()}
#'       results where \code{computed = "power"}}
#'     \item{\code{interpretation}}{Plain-text interpretation}
#'     \item{\code{recommendation}}{Practical recruitment advice}
#'   }
#'   Use \code{print(result)} for a brief summary, \code{summary(result)} for
#'   full details, and \code{plot(result)} to display the sample size curve.
#'
#' @examples
#' \dontrun{
#' # Two-sample t-test (default)
#' result <- stat_n(power = 0.8, effect_size = 0.5)
#' print(result)
#' summary(result)
#' plot(result)
#'
#' # ANOVA with 4 groups, higher power target
#' stat_n(power = 0.9, effect_size = 0.25, test = "anova", k = 4)
#'
#' # Correlation, one-sided
#' stat_n(power = 0.8, effect_size = 0.3, test = "correlation",
#'        alternative = "greater")
#' }
#'
#' @seealso \code{\link{stat_power}} for computing power given sample size.
#'
#' @export
stat_n <- function(power       = 0.8,
                   effect_size,
                   test        = c("t_two", "t_one", "t_paired",
                                   "anova", "proportion", "correlation", "chisq"),
                   alternative = c("two.sided", "less", "greater"),
                   alpha       = 0.05,
                   k           = NULL,
                   df          = NULL) {

  test        <- match.arg(test)
  alternative <- match.arg(alternative)

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  .assert_proportion(power)
  .assert_positive_numeric(effect_size)
  .assert_proportion(alpha)

  if (test == "correlation" && effect_size > 1) {
    cli::cli_abort(
      "{.arg effect_size} for correlation must be in (0, 1].",
      call = NULL
    )
  }

  if (test == "anova") {
    if (is.null(k))
      cli::cli_abort("{.arg k} (number of groups) is required for ANOVA.", call = NULL)
    k <- .assert_count_min(k, min = 2L)
  }

  if (test == "chisq") {
    if (is.null(df))
      cli::cli_abort(
        "{.arg df} (degrees of freedom) is required for chi-square.",
        call = NULL
      )
    df <- .assert_count(df)
  }

  if (test %in% c("anova", "chisq") && alternative != "two.sided") {
    cli::cli_warn(
      c(
        "{.arg alternative} is ignored for {.val {test}} tests.",
        "i" = "ANOVA and chi-square are inherently non-directional."
      )
    )
  }

  # ---------------------------------------------------------------------------
  # Sample size calculation
  # ---------------------------------------------------------------------------
  pwr_result <- tryCatch(
    .pwr_compute(
      n = NULL, power = power,
      effect_size = effect_size, test = test,
      alternative = alternative, alpha = alpha,
      k = k, df = df
    ),
    error = function(e)
      cli::cli_abort(
        c("Sample size calculation failed.", "x" = conditionMessage(e)),
        call = NULL
      )
  )

  # Reason: chisq uses capital N; all other pwr functions use lowercase n
  n <- as.integer(ceiling(if (test == "chisq") pwr_result$N else pwr_result$n))

  if (n > 1000L) {
    cli::cli_warn(
      c(
        "Required sample size is very large (n = {n} {.n_unit(test)}).",
        "i" = "Consider a larger minimum detectable effect size or accepting lower power."
      )
    )
  }

  invisible(structure(
    list(
      params = list(
        power       = power,
        effect_size = effect_size,
        test        = test,
        alternative = alternative,
        alpha       = alpha,
        k           = k,
        df          = df
      ),
      n              = n,
      computed       = "n",
      interpretation = .n_interp(n, power, effect_size, test, k),
      recommendation = .n_recommend(n)
    ),
    class = "power_result"
  ))
}


# =============================================================================
# quick_ttest — Two-group comparison with automatic method selection
# =============================================================================

#' Two-group comparison with automatic method selection
#'
#' Performs a t-test or Wilcoxon test for exactly two groups, with automatic
#' method selection based on normality when \code{method = "auto"}.
#' Always uses Welch's t-test for unpaired comparisons (no equal-variance
#' assumption).
#'
#' \strong{Auto method selection logic:}
#' \itemize{
#'   \item \eqn{n \ge 100}: t-test (CLT applies; Shapiro-Wilk unreliable at large n)
#'   \item \eqn{30 \le n < 100}: Shapiro-Wilk at \eqn{p < 0.01} threshold
#'   \item \eqn{n < 30}: Shapiro-Wilk at \eqn{p < 0.05} threshold
#' }
#'
#' @param data A data frame.
#' @param group_col Character. Column name for the grouping variable (exactly 2 levels).
#' @param value_col Character. Column name for the numeric response variable.
#' @param method One of \code{"auto"} (default), \code{"t.test"},
#'   \code{"wilcox.test"}.
#' @param paired Logical. Paired test? Default \code{FALSE}.
#'   Requires \code{id_col} when \code{TRUE}.
#' @param id_col Character. Column name for the pairing identifier. Required when
#'   \code{paired = TRUE}.
#' @param alternative One of \code{"two.sided"} (default), \code{"less"},
#'   \code{"greater"}.
#' @param alpha Numeric. Significance level. Default \code{0.05}.
#'
#' @return An object of class \code{"quick_ttest_result"} (invisibly)
#'   containing:
#'   \describe{
#'     \item{\code{test_result}}{An \code{htest} object from the test}
#'     \item{\code{method_used}}{Character: \code{"t.test"} or
#'       \code{"wilcox.test"}}
#'     \item{\code{descriptive_stats}}{Per-group summary data frame}
#'     \item{\code{normality_tests}}{Shapiro-Wilk results (auto mode only);
#'       \code{NULL} when method is forced}
#'     \item{\code{params}}{List of input parameters}
#'     \item{\code{data}}{Cleaned data frame used for the test (for
#'       \code{plot()} method)}
#'   }
#'   Use \code{print(result)} for a one-line summary, \code{summary(result)}
#'   for full details, and \code{plot(result)} for a comparison plot.
#'
#' @examples
#' set.seed(42)
#' df <- data.frame(
#'   group = rep(c("A", "B"), each = 30),
#'   value = c(rnorm(30, 5), rnorm(30, 6))
#' )
#' result <- quick_ttest(df, group_col = "group", value_col = "value")
#' print(result)
#' summary(result)
#' plot(result)
#'
#' @seealso \code{\link[stats]{t.test}}, \code{\link[stats]{wilcox.test}}
#' @export
quick_ttest <- function(data,
                        group_col,
                        value_col,
                        method      = c("auto", "t.test", "wilcox.test"),
                        paired      = FALSE,
                        id_col      = NULL,
                        alternative = c("two.sided", "less", "greater"),
                        alpha       = 0.05) {

  method      <- match.arg(method)
  alternative <- match.arg(alternative)

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  .assert_data_frame(data)
  .assert_flag(paired)
  .assert_proportion(alpha)

  .assert_scalar_string(group_col, "group_col")
  .assert_scalar_string(value_col, "value_col")
  .assert_has_cols(data, c(group_col, value_col))

  if (paired) {
    if (is.null(id_col))
      cli::cli_abort("{.arg id_col} is required when {.arg paired} is TRUE.")
    .assert_scalar_string(id_col, "id_col")
    .assert_has_cols(data, id_col)
  }

  group_name <- group_col
  value_name <- value_col
  id_name    <- id_col

  # ---------------------------------------------------------------------------
  # Prepare data
  # ---------------------------------------------------------------------------
  df           <- .prepare_ttest_data(data, group_name, value_name, id_name, paired)
  group_levels <- levels(df$group)
  if (paired) df <- .validate_paired_ttest_data(df)

  # ---------------------------------------------------------------------------
  # Descriptive statistics
  # ---------------------------------------------------------------------------
  desc_stats <- .describe_two_group_data(df, group_levels)

  # ---------------------------------------------------------------------------
  # Method selection
  # ---------------------------------------------------------------------------
  normality_tests <- NULL

  if (method == "auto") {
    normality_tests <- .check_group_normality(df, paired = paired)
    method_selected <- if (normality_tests$recommendation == "parametric") "t.test" else "wilcox.test"
  } else {
    method_selected <- method
  }

  # ---------------------------------------------------------------------------
  # Run test
  # ---------------------------------------------------------------------------
  conf_level  <- 1 - alpha
  test_result <- if (method_selected == "t.test") {
    .run_quick_ttest(df, group_levels, paired, alternative, conf_level)
  } else {
    .run_quick_wilcox(df, group_levels, paired, alternative, conf_level)
  }

  invisible(structure(
    list(
      test_result       = test_result,
      method_used       = method_selected,
      descriptive_stats = desc_stats,
      normality_tests   = normality_tests,
      params            = list(
        group_name  = group_name,
        value_name  = value_name,
        paired      = paired,
        alternative = alternative,
        alpha       = alpha,
        direction   = paste(group_levels[1], "-", group_levels[2])
      ),
      data = df   # retained for plot() method
    ),
    class = "quick_ttest_result"
  ))
}


# =============================================================================
# S3 Methods
# =============================================================================

#' @export
print.quick_ttest_result <- function(x, ...) {
  p     <- x$test_result$p.value
  p_fmt <- if (p < 0.001) "p < 0.001" else sprintf("p = %.4f", p)
  sig   <- if (p < x$params$alpha) "*" else ""

  n_str <- paste(
    paste0(x$descriptive_stats$group, " n=", x$descriptive_stats$n),
    collapse = ", "
  )

  dir_str <- if (x$params$alternative != "two.sided")
    paste0(" | ", x$params$direction) else ""
  cli::cli_text("{x$method_used} | {p_fmt}{sig}{dir_str} | {n_str}")
  invisible(x)
}


#' @export
summary.quick_ttest_result <- function(object, ...) {
  x     <- object
  p     <- x$test_result$p.value
  p_fmt <- if (p < 0.001) "p < 0.001" else sprintf("p = %.4f", p)

  cli::cli_h1("Two-group Comparison")

  # --- Parameters ---
  cli::cli_h2("Parameters")
  test_label <- if (x$method_used == "t.test") {
    if (x$params$paired) "Paired t-test" else "Welch two-sample t-test"
  } else {
    if (x$params$paired) "Wilcoxon signed-rank test" else "Wilcoxon rank-sum test"
  }
  cli::cli_dl(c(
    "Test"        = test_label,
    "Direction"   = x$params$direction,
    "Alternative" = x$params$alternative,
    "alpha"       = sprintf("%.3f", x$params$alpha),
    "Paired"      = as.character(x$params$paired)
  ))

  # --- Result ---
  cli::cli_h2("Result")
  if (p < x$params$alpha) {
    cli::cli_alert_success("{p_fmt}  (significant at alpha = {x$params$alpha})")
  } else {
    cli::cli_alert_info("{p_fmt}  (not significant at alpha = {x$params$alpha})")
  }
  cli::cli_text("")
  print(x$test_result)

  # --- Descriptive statistics ---
  cli::cli_h2("Descriptive statistics")
  print(x$descriptive_stats)

  # --- Normality (auto mode only) ---
  if (!is.null(x$normality_tests)) {
    cli::cli_h2("Normality (Shapiro-Wilk)")
    for (grp in names(x$normality_tests$tests)) {
      res <- x$normality_tests$tests[[grp]]
      if (!is.na(res$p.value)) {
        pf <- if (res$p.value < 0.001) "p < 0.001" else sprintf("p = %.3f", res$p.value)
        cli::cli_text("  {grp}: n = {res$n},  {pf}")
      }
    }
    cli::cli_text("  \u2192 {x$normality_tests$rationale}")
  }

  cli::cli_text("")
  invisible(x)
}


#' @rdname quick_ttest
#' @export
#' @param x A \code{quick_ttest_result} object from \code{quick_ttest()}.
#' @param y Ignored.
#' @param ... Additional arguments passed to the internal plotting backend.
#' @param plot_type One of \code{"boxplot"} (default), \code{"violin"},
#'   \code{"both"}.
#' @param add_jitter Logical. Add jittered points? Default \code{TRUE}.
#' @param point_size Numeric. Jitter point size. Default \code{2}.
#' @param point_alpha Numeric. Jitter point transparency (0-1). Default \code{0.6}.
#' @param show_p_value Logical. Annotate plot with p-value? Default \code{TRUE}.
#' @param p_label One of \code{"p.signif"} (stars, default) or
#'   \code{"p.format"} (numeric).
#' @param palette evanverse palette name. Default \code{"qual_vivid"}.
#'   \code{NULL} uses ggplot2 defaults.
plot.quick_ttest_result <- function(x, y = NULL,
                                     plot_type    = c("boxplot", "violin", "both"),
                                     add_jitter   = TRUE,
                                     point_size   = 2,
                                     point_alpha  = 0.6,
                                     show_p_value = TRUE,
                                     p_label      = c("p.signif", "p.format"),
                                     palette      = "qual_vivid",
                                     ...) {
  plot_type <- match.arg(plot_type)
  p_label   <- match.arg(p_label)

  print(.create_comparison_plot(
    data         = x$data,
    group_levels = levels(x$data$group),
    test_result  = x$test_result,
    plot_type    = plot_type,
    add_jitter   = add_jitter,
    point_size   = point_size,
    point_alpha  = point_alpha,
    show_p_value = show_p_value,
    p_label      = p_label,
    palette      = palette,
    group_name   = x$params$group_name,
    value_name   = x$params$value_name
  ))

  invisible(x)
}


# =============================================================================
# quick_anova — One-way comparison with automatic method selection
# =============================================================================

#' One-way comparison with automatic method selection
#'
#' Performs a one-way ANOVA, Welch ANOVA, or Kruskal-Wallis test with
#' automatic assumption checking and optional post-hoc comparisons.
#'
#' \strong{Auto method selection logic:}
#' \enumerate{
#'   \item Normality checked per group via Shapiro-Wilk (sample-size-adaptive
#'     thresholds — see \code{\link{quick_ttest}} for details).
#'   \item If normality passes: Levene's test decides between classical ANOVA
#'     (equal variances) and Welch ANOVA (unequal variances).
#'   \item If normality fails: Kruskal-Wallis is used.
#' }
#'
#' \strong{Post-hoc defaults when \code{post_hoc = "auto"}:}
#' \itemize{
#'   \item \code{"anova"} → Tukey HSD
#'   \item \code{"welch"} → Pairwise Welch t-tests (BH-adjusted)
#'   \item \code{"kruskal"} → Pairwise Wilcoxon (BH-adjusted)
#' }
#'
#' @param data A data frame.
#' @param group_col Character. Column name for the grouping factor (2 or more levels).
#' @param value_col Character. Column name for the numeric response variable.
#' @param method One of \code{"auto"} (default), \code{"anova"},
#'   \code{"welch"}, or \code{"kruskal"}.
#' @param post_hoc One of \code{"auto"} (default), \code{"none"},
#'   \code{"tukey"}, \code{"welch"}, or \code{"wilcox"}.
#' @param alpha Numeric. Significance level. Default \code{0.05}.
#'
#' @return An object of class \code{"quick_anova_result"} (invisibly)
#'   containing:
#'   \describe{
#'     \item{\code{omnibus_result}}{List with test object, p-value, and
#'       effect size}
#'     \item{\code{post_hoc}}{Post-hoc table (or \code{NULL} if none)}
#'     \item{\code{method_used}}{Character: \code{"anova"}, \code{"welch"},
#'       or \code{"kruskal"}}
#'     \item{\code{descriptive_stats}}{Per-group summary data frame}
#'     \item{\code{assumption_checks}}{List with normality and variance
#'       test results (diagnostics even when method is forced)}
#'     \item{\code{params}}{List of input parameters}
#'     \item{\code{data}}{Cleaned data frame (for \code{plot()} method)}
#'   }
#'   Use \code{print(result)} for a brief summary, \code{summary(result)}
#'   for full details, and \code{plot(result)} for a comparison plot.
#'
#' @examples
#' set.seed(123)
#' df <- data.frame(
#'   group = rep(LETTERS[1:3], each = 40),
#'   value = rnorm(120, mean = rep(c(0, 0.5, 1.2), each = 40), sd = 1)
#' )
#' result <- quick_anova(df, group_col = "group", value_col = "value")
#' print(result)
#' summary(result)
#' plot(result)
#'
#' @seealso \code{\link[stats]{aov}}, \code{\link[stats]{oneway.test}},
#'   \code{\link[stats]{kruskal.test}}
#' @export
quick_anova <- function(data,
                        group_col,
                        value_col,
                        method   = c("auto", "anova", "welch", "kruskal"),
                        post_hoc = c("auto", "none", "tukey", "welch", "wilcox"),
                        alpha    = 0.05) {

  method   <- match.arg(method)
  post_hoc <- match.arg(post_hoc)

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  .assert_data_frame(data)
  .assert_proportion(alpha)

  .assert_scalar_string(group_col, "group_col")
  .assert_scalar_string(value_col, "value_col")
  .assert_has_cols(data, c(group_col, value_col))
  group_name <- group_col
  value_name <- value_col

  # ---------------------------------------------------------------------------
  # Prepare data
  # ---------------------------------------------------------------------------
  df <- data[, c(group_name, value_name), drop = FALSE]
  colnames(df) <- c("group", "value")

  n_missing <- sum(!stats::complete.cases(df))
  if (n_missing > 0) {
    cli::cli_alert_warning("Removed {n_missing} row{?s} with missing values.")
    df <- df[stats::complete.cases(df), , drop = FALSE]
  }
  if (nrow(df) == 0)
    cli::cli_abort("No valid data remaining after removing missing values.")
  if (!is.numeric(df$value))
    cli::cli_abort("{.field {value_name}} must be numeric.")
  if (!is.factor(df$group))
    df$group <- as.factor(df$group)

  group_levels <- levels(df$group)
  n_groups     <- length(group_levels)

  if (n_groups < 2)
    cli::cli_abort("{.fn quick_anova} requires at least 2 groups.")
  if (n_groups == 2)
    cli::cli_alert_info("Only 2 groups detected. Consider {.fn quick_ttest} for pairwise comparisons.")

  # ---------------------------------------------------------------------------
  # Descriptive statistics
  # ---------------------------------------------------------------------------
  desc_stats <- df |>
    dplyr::group_by(.data$group) |>
    dplyr::summarise(
      n      = dplyr::n(),
      mean   = mean(.data$value,          na.rm = TRUE),
      sd     = stats::sd(.data$value,     na.rm = TRUE),
      median = stats::median(.data$value, na.rm = TRUE),
      min    = min(.data$value,           na.rm = TRUE),
      max    = max(.data$value,           na.rm = TRUE),
      .groups = "drop"
    )

  ns <- desc_stats$n
  if (any(ns < 5))
    cli::cli_alert_warning("Very small sample size (n < 5) in at least one group. Results may be unreliable.")
  if (max(ns) / min(ns) > 4)
    cli::cli_alert_warning(
      "Severely unbalanced samples (ratio {round(max(ns) / min(ns), 1)}:1). Interpret with caution."
    )

  # ---------------------------------------------------------------------------
  # Assumption checks (always run for diagnostics)
  # ---------------------------------------------------------------------------
  normality_tests <- .check_group_normality(df, paired = FALSE)
  variance_test   <- NULL

  # ---------------------------------------------------------------------------
  # Method selection
  # ---------------------------------------------------------------------------
  if (method == "auto") {
    if (normality_tests$recommendation == "parametric") {
      variance_test   <- .check_variance_equality(df)
      method_selected <- if (variance_test$equal_variance) "anova" else "welch"
    } else {
      method_selected <- "kruskal"
    }
  } else {
    method_selected <- method
    # Run Levene diagnostics when classical ANOVA is used (even if forced)
    if (method_selected == "anova")
      variance_test <- .check_variance_equality(df)
  }

  # ---------------------------------------------------------------------------
  # Post-hoc method resolution and compatibility check
  # ---------------------------------------------------------------------------
  post_hoc_method <- .resolve_post_hoc(post_hoc, method_selected)
  .check_post_hoc_compat(post_hoc_method, method_selected)

  # ---------------------------------------------------------------------------
  # Run omnibus test
  # ---------------------------------------------------------------------------
  conf_level     <- 1 - alpha
  omnibus_result <- .run_anova_omnibus(df, method_selected)

  # ---------------------------------------------------------------------------
  # Run post-hoc tests
  # ---------------------------------------------------------------------------
  post_hoc_result <- if (post_hoc_method != "none") {
    .run_anova_post_hoc(df, method_selected, post_hoc_method, omnibus_result, conf_level)
  } else {
    NULL
  }

  invisible(structure(
    list(
      omnibus_result    = omnibus_result,
      post_hoc          = post_hoc_result,
      method_used       = method_selected,
      descriptive_stats = desc_stats,
      assumption_checks = list(
        normality = normality_tests,
        variance  = variance_test
      ),
      params = list(
        group_name = group_name,
        value_name = value_name,
        method     = method,
        post_hoc   = post_hoc,
        alpha      = alpha
      ),
      data = df
    ),
    class = "quick_anova_result"
  ))
}


# =============================================================================
# S3 Methods
# =============================================================================

#' @export
print.quick_anova_result <- function(x, ...) {
  p     <- x$omnibus_result$p_value
  p_fmt <- if (p < 0.001) "p < 0.001" else sprintf("p = %.4f", p)
  sig   <- if (p < x$params$alpha) "*" else ""

  method_label <- switch(x$method_used,
    anova   = "One-way ANOVA",
    welch   = "Welch ANOVA",
    kruskal = "Kruskal-Wallis"
  )

  n_str <- paste(
    paste0(x$descriptive_stats$group, " n=", x$descriptive_stats$n),
    collapse = ", "
  )

  cli::cli_text("{method_label} | {p_fmt}{sig} | {n_str}")
  invisible(x)
}


#' @export
summary.quick_anova_result <- function(object, ...) {
  x     <- object
  p     <- x$omnibus_result$p_value
  p_fmt <- if (p < 0.001) "p < 0.001" else sprintf("p = %.4f", p)

  method_label <- switch(x$method_used,
    anova   = "One-way ANOVA",
    welch   = "Welch ANOVA",
    kruskal = "Kruskal-Wallis"
  )

  cli::cli_h1("One-way Comparison")

  # --- Parameters ---
  cli::cli_h2("Parameters")
  cli::cli_dl(c(
    "Test"  = method_label,
    "alpha" = sprintf("%.3f", x$params$alpha)
  ))

  # --- Omnibus result ---
  cli::cli_h2("Omnibus Test")
  if (p < x$params$alpha) {
    cli::cli_alert_success("{p_fmt}  (significant at alpha = {x$params$alpha})")
  } else {
    cli::cli_alert_info("{p_fmt}  (not significant at alpha = {x$params$alpha})")
  }
  if (!is.null(x$omnibus_result$effect_size)) {
    es <- x$omnibus_result$effect_size
    cli::cli_text(paste(names(es), sprintf("%.3f", unlist(es)), sep = " = ", collapse = ",  "))
  }
  cli::cli_text("")
  if (x$method_used == "anova") {
    print(x$omnibus_result$summary)
  } else {
    print(x$omnibus_result$test)
  }

  # --- Descriptive statistics ---
  cli::cli_h2("Descriptive statistics")
  print(x$descriptive_stats)

  # --- Normality ---
  if (!is.null(x$assumption_checks$normality)) {
    cli::cli_h2("Normality (Shapiro-Wilk)")
    norm <- x$assumption_checks$normality
    for (grp in names(norm$tests)) {
      res <- norm$tests[[grp]]
      if (!is.na(res$p.value)) {
        pf <- if (res$p.value < 0.001) "p < 0.001" else sprintf("p = %.3f", res$p.value)
        cli::cli_text("  {grp}: n = {res$n},  {pf}")
      }
    }
    cli::cli_text("  -> {norm$rationale}")
  }

  # --- Variance ---
  if (!is.null(x$assumption_checks$variance) &&
      isTRUE(x$assumption_checks$variance$test_performed)) {
    cli::cli_h2("Variance (Levene's test)")
    vt  <- x$assumption_checks$variance
    pf  <- if (vt$p_value < 0.001) "p < 0.001" else sprintf("p = %.3f", vt$p_value)
    cli::cli_text("  {pf}  |  equal variances: {vt$equal_variance}")
  }

  # --- Post-hoc ---
  if (!is.null(x$post_hoc)) {
    cli::cli_h2("Post-hoc ({x$post_hoc$method})")
    print(x$post_hoc$table)
  }

  cli::cli_text("")
  invisible(x)
}


#' @rdname quick_anova
#' @export
#' @param x A \code{quick_anova_result} object from \code{quick_anova()}.
#' @param y Ignored.
#' @param ... Additional arguments passed to the internal plotting backend.
#' @param plot_type One of \code{"boxplot"} (default), \code{"violin"},
#'   \code{"both"}.
#' @param add_jitter Logical. Add jittered points? Default \code{TRUE}.
#' @param point_size Numeric. Jitter point size. Default \code{2}.
#' @param point_alpha Numeric. Jitter point transparency (0-1). Default \code{0.6}.
#' @param show_p_value Logical. Annotate plot with omnibus p-value? Default \code{TRUE}.
#' @param p_label One of \code{"p.format"} (default) or \code{"p.signif"} (stars).
#' @param palette evanverse palette name. Default \code{"qual_vivid"}.
#'   \code{NULL} uses ggplot2 defaults.
plot.quick_anova_result <- function(x, y = NULL,
                                     plot_type    = c("boxplot", "violin", "both"),
                                     add_jitter   = TRUE,
                                     point_size   = 2,
                                     point_alpha  = 0.6,
                                     show_p_value = TRUE,
                                     p_label      = c("p.format", "p.signif"),
                                     palette      = "qual_vivid",
                                     ...) {
  plot_type <- match.arg(plot_type)
  p_label   <- match.arg(p_label)

  print(.create_anova_plot(
    data              = x$data,
    group_levels      = levels(x$data$group),
    plot_type         = plot_type,
    add_jitter        = add_jitter,
    point_size        = point_size,
    point_alpha       = point_alpha,
    palette           = palette,
    show_p_value      = show_p_value,
    p_value           = x$omnibus_result$p_value,
    p_label           = p_label,
    method_used       = x$method_used,
    group_name        = x$params$group_name,
    value_name        = x$params$value_name
  ))

  invisible(x)
}


# =============================================================================
# quick_chisq — Categorical association test with automatic method selection
# =============================================================================

#' Categorical association test with automatic method selection
#'
#' Tests the association between two categorical variables using chi-square,
#' Fisher's exact, or McNemar's test, with automatic method selection based
#' on expected cell frequencies when \code{method = "auto"}.
#'
#' \strong{Auto method selection logic:}
#' \itemize{
#'   \item 2×2 table with any expected frequency < 5: Fisher's exact test
#'   \item >20\% of cells with expected frequency < 5: chi-square with warning
#'   \item 2x2 table with 5 <= expected frequency < 10: Yates' correction applied
#'   \item Otherwise: standard chi-square test
#' }
#'
#' \strong{WARNING}: \code{"mcnemar"} is ONLY for paired/matched data (e.g.,
#' before-after measurements on the same subjects). Do NOT use for independent
#' samples — use \code{"chisq"} or \code{"fisher"} instead.
#'
#' @param data A data frame.
#' @param x_col Character. Column name for the first categorical variable (row variable).
#' @param y_col Character. Column name for the second categorical variable (column variable).
#' @param method One of \code{"auto"} (default), \code{"chisq"},
#'   \code{"fisher"}, \code{"mcnemar"}.
#' @param correct Logical or \code{NULL}. Apply Yates' continuity correction?
#'   \code{NULL} (default) applies it automatically for 2×2 tables with
#'   expected frequencies between 5 and 10.
#' @param conf_level Numeric. Confidence level for Fisher's exact test interval.
#'   Default \code{0.95}.
#' @param alpha Numeric. Significance level for \code{print()} and
#'   \code{summary()}. Default \code{0.05}.
#'
#' @return An object of class \code{"quick_chisq_result"} (invisibly) containing:
#'   \describe{
#'     \item{\code{test_result}}{An \code{htest} object from the test}
#'     \item{\code{method_used}}{Character: human-readable test method label}
#'     \item{\code{contingency_table}}{Observed frequency table}
#'     \item{\code{expected_freq}}{Matrix of expected frequencies}
#'     \item{\code{pearson_residuals}}{Pearson residuals matrix; \code{NULL}
#'       for Fisher/McNemar}
#'     \item{\code{effect_size}}{Cramer's V and interpretation; \code{NULL}
#'       when statistic is unavailable}
#'     \item{\code{descriptive_stats}}{Data frame with counts, proportions,
#'       and percents}
#'     \item{\code{auto_decision}}{List with method selection details}
#'     \item{\code{params}}{List of input parameters}
#'     \item{\code{data}}{Cleaned data frame used for the test (for
#'       \code{plot()} method)}
#'   }
#'   Use \code{print(result)} for a one-line summary, \code{summary(result)}
#'   for full details, and \code{plot(result)} for a visualization.
#'
#' @examples
#' set.seed(123)
#' df <- data.frame(
#'   treatment = sample(c("A", "B", "C"), 100, replace = TRUE),
#'   response  = sample(c("Success", "Failure"), 100, replace = TRUE,
#'                      prob = c(0.6, 0.4))
#' )
#' result <- quick_chisq(df, x_col = "treatment", y_col = "response")
#' print(result)
#' summary(result)
#' plot(result)
#'
#' @seealso \code{\link[stats]{chisq.test}}, \code{\link[stats]{fisher.test}},
#'   \code{\link{quick_ttest}}, \code{\link{quick_anova}}
#' @export
quick_chisq <- function(data,
                        x_col,
                        y_col,
                        method     = c("auto", "chisq", "fisher", "mcnemar"),
                        correct    = NULL,
                        conf_level = 0.95,
                        alpha      = 0.05) {

  method <- match.arg(method)

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  .assert_data_frame(data)
  .assert_scalar_string(x_col)
  .assert_scalar_string(y_col)
  .assert_has_cols(data, c(x_col, y_col))
  .assert_proportion(conf_level)
  .assert_proportion(alpha)
  if (!is.null(correct)) .assert_flag(correct)

  # ---------------------------------------------------------------------------
  # Prepare data
  # ---------------------------------------------------------------------------
  df <- .prepare_chisq_data(data, x_col, y_col)

  # ---------------------------------------------------------------------------
  # Contingency table
  # ---------------------------------------------------------------------------
  cont_table    <- table(df$var1, df$var2)
  n_total       <- sum(cont_table)
  n_rows        <- nrow(cont_table)
  n_cols        <- ncol(cont_table)
  row_sums      <- rowSums(cont_table)
  col_sums      <- colSums(cont_table)
  expected_freq <- outer(row_sums, col_sums) / n_total

  if (n_rows < 2 || n_cols < 2)
    cli::cli_abort("Need at least 2 levels in each variable for chi-square test.")

  # ---------------------------------------------------------------------------
  # Method selection
  # ---------------------------------------------------------------------------
  auto_decision   <- .select_chisq_method(method, correct, n_rows, n_cols,
                                          n_total, expected_freq)
  method_selected <- auto_decision$method
  correct_used    <- auto_decision$correct

  # ---------------------------------------------------------------------------
  # Run test
  # ---------------------------------------------------------------------------
  test_result <- .run_chisq_test(cont_table, method_selected, correct_used,
                                 conf_level, n_rows, n_cols)
  method_used <- auto_decision$label

  # ---------------------------------------------------------------------------
  # Post-test calculations
  # ---------------------------------------------------------------------------
  pearson_residuals <- if (method_selected == "chisq") {
    resid <- (as.vector(cont_table) - as.vector(expected_freq)) /
               sqrt(as.vector(expected_freq))
    mat   <- matrix(resid, nrow = n_rows, ncol = n_cols)
    dimnames(mat) <- dimnames(cont_table)
    mat
  } else {
    NULL
  }

  effect_size <- .compute_cramers_v(test_result, n_total, n_rows, n_cols)

  desc_stats              <- as.data.frame.table(cont_table)
  colnames(desc_stats)    <- c(x_col, y_col, "Count")
  desc_stats$Proportion   <- desc_stats$Count / n_total
  desc_stats$Percent      <- round(desc_stats$Proportion * 100, 2)

  invisible(structure(
    list(
      test_result       = test_result,
      method_used       = method_used,
      contingency_table = cont_table,
      expected_freq     = expected_freq,
      pearson_residuals = pearson_residuals,
      effect_size       = effect_size,
      descriptive_stats = desc_stats,
      auto_decision     = auto_decision,
      params            = list(
        x_col      = x_col,
        y_col      = y_col,
        conf_level = conf_level,
        alpha      = alpha,
        table_size = paste0(n_rows, "x", n_cols)
      ),
      data = df
    ),
    class = "quick_chisq_result"
  ))
}


# =============================================================================
# S3 Methods
# =============================================================================

#' @export
print.quick_chisq_result <- function(x, ...) {
  p     <- x$test_result$p.value
  p_fmt <- if (p < 0.001) "p < 0.001" else sprintf("p = %.4f", p)
  sig   <- if (p < x$params$alpha) "*" else ""

  es_str <- if (!is.null(x$effect_size))
    paste0(" | V = ", x$effect_size$cramers_v,
           " (", x$effect_size$interpretation, ")")
  else ""

  cli::cli_text(
    "{x$method_used} | {p_fmt}{sig} | {x$params$table_size}{es_str}"
  )
  invisible(x)
}


#' @export
summary.quick_chisq_result <- function(object, ...) {
  x     <- object
  p     <- x$test_result$p.value
  p_fmt <- if (p < 0.001) "p < 0.001" else sprintf("p = %.4f", p)

  cli::cli_h1("Categorical Association Test")

  # --- Parameters ---
  cli::cli_h2("Parameters")
  cli::cli_dl(c(
    "Test"       = x$method_used,
    "Variables"  = paste(x$params$x_col, "\u00d7", x$params$y_col),
    "Table size" = x$params$table_size,
    "alpha"      = sprintf("%.3f", x$params$alpha)
  ))

  # --- Result ---
  cli::cli_h2("Result")
  if (p < x$params$alpha) {
    cli::cli_alert_success("{p_fmt}  (significant at alpha = {x$params$alpha})")
  } else {
    cli::cli_alert_info("{p_fmt}  (not significant at alpha = {x$params$alpha})")
  }
  cli::cli_text("")
  print(x$test_result)

  # --- Effect size ---
  if (!is.null(x$effect_size)) {
    cli::cli_h2("Effect Size (Cramer's V)")
    cli::cli_dl(c(
      "V"              = as.character(x$effect_size$cramers_v),
      "Interpretation" = x$effect_size$interpretation
    ))
  }

  # --- Contingency tables ---
  cli::cli_h2("Observed Frequencies")
  print(x$contingency_table)

  cli::cli_h2("Expected Frequencies")
  print(round(x$expected_freq, 2))

  if (!is.null(x$pearson_residuals)) {
    cli::cli_h2("Pearson Residuals")
    print(round(x$pearson_residuals, 2))
    cli::cli_text(
      "  \u2192 |residual| > 2 indicates significant deviation from independence"
    )
  }

  # --- Method selection ---
  cli::cli_h2("Method Selection")
  cli::cli_dl(c(
    "Table size"          = x$auto_decision$table_size,
    "Total N"             = as.character(x$auto_decision$total_n),
    "Min expected freq"   = as.character(x$auto_decision$min_expected_freq),
    "Cells with freq < 5" = as.character(x$auto_decision$n_cells_below_5),
    "Decision"            = x$auto_decision$reason
  ))

  cli::cli_text("")
  invisible(x)
}


#' @rdname quick_chisq
#' @export
#' @param x A \code{quick_chisq_result} object from \code{quick_chisq()}.
#' @param y Ignored.
#' @param ... Additional arguments passed to the internal plotting backend.
#' @param plot_type One of \code{"bar_grouped"} (default), \code{"bar_stacked"},
#'   or \code{"heatmap"}.
#' @param show_p_value Logical. Annotate plot with p-value? Default \code{TRUE}.
#' @param p_label One of \code{"p.format"} (numeric, default) or
#'   \code{"p.signif"} (stars).
#' @param palette evanverse palette name. Default \code{"qual_vivid"}.
#'   \code{NULL} uses ggplot2 defaults.
plot.quick_chisq_result <- function(x, y = NULL,
                                     plot_type    = c("bar_grouped", "bar_stacked", "heatmap"),
                                     show_p_value = TRUE,
                                     p_label      = c("p.format", "p.signif"),
                                     palette      = "qual_vivid",
                                     ...) {
  plot_type <- match.arg(plot_type)
  p_label   <- match.arg(p_label)

  print(.create_chisq_plot(
    df                = x$data,
    cont_table        = x$contingency_table,
    pearson_residuals = x$pearson_residuals,
    test_result       = x$test_result,
    method_used       = x$method_used,
    plot_type         = plot_type,
    show_p_value      = show_p_value,
    p_label           = p_label,
    palette           = palette,
    x_name            = x$params$x_col,
    y_name            = x$params$y_col
  ))

  invisible(x)
}


# =============================================================================
# quick_cor — Correlation analysis with heatmap visualization
# =============================================================================

#' Correlation analysis with heatmap visualization
#'
#' Computes pairwise correlations with p-values, optional multiple-testing
#' correction, and a publication-ready heatmap. Supports Pearson, Spearman,
#' and Kendall methods.
#'
#' \strong{P-value computation:} Uses \code{psych::corr.test()} when available
#' (10-100× faster for large matrices); otherwise falls back to a
#' \code{stats::cor.test()} loop.
#'
#' @param data A data frame.
#' @param vars Character vector of column names to include. \code{NULL}
#'   (default) uses all numeric columns.
#' @param method One of \code{"pearson"} (default), \code{"spearman"},
#'   \code{"kendall"}.
#' @param use Character. Missing-value handling passed to \code{cor()}.
#'   Default \code{"pairwise.complete.obs"}.
#' @param p_adjust_method P-value adjustment method passed to
#'   \code{\link[stats]{p.adjust}}. Default \code{"none"}.
#' @param alpha Numeric. Significance threshold for identifying significant
#'   pairs. Default \code{0.05}.
#'
#' @return An object of class \code{"quick_cor_result"} (invisibly) containing:
#'   \describe{
#'     \item{\code{cor_matrix}}{Correlation coefficient matrix}
#'     \item{\code{p_matrix}}{Unadjusted p-value matrix}
#'     \item{\code{p_adjusted}}{Adjusted p-value matrix; \code{NULL} when
#'       \code{p_adjust_method = "none"}}
#'     \item{\code{method_used}}{Correlation method used}
#'     \item{\code{significant_pairs}}{Data frame of significant pairs}
#'     \item{\code{descriptive_stats}}{Per-variable summary data frame}
#'     \item{\code{params}}{List of input parameters}
#'     \item{\code{data}}{Cleaned data frame (for \code{plot()} method)}
#'   }
#'   Use \code{print(result)} for a one-line summary, \code{summary(result)}
#'   for full details, and \code{plot(result)} for the correlation heatmap.
#'
#' @examples
#' result <- quick_cor(mtcars)
#' print(result)
#' summary(result)
#' if (requireNamespace("ggcorrplot", quietly = TRUE)) {
#'   plot(result)
#' }
#'
#' result <- quick_cor(
#'   mtcars,
#'   vars   = c("mpg", "hp", "wt", "qsec"),
#'   method = "spearman",
#'   p_adjust_method = "BH"
#' )
#'
#' @seealso \code{\link[stats]{cor}}, \code{\link[stats]{cor.test}},
#'   \code{\link{quick_ttest}}, \code{\link{quick_chisq}}
#' @export
quick_cor <- function(data,
                      vars            = NULL,
                      method          = c("pearson", "spearman", "kendall"),
                      use             = "pairwise.complete.obs",
                      p_adjust_method = c("none", "holm", "hochberg", "hommel",
                                          "bonferroni", "BH", "BY", "fdr"),
                      alpha           = 0.05) {

  method          <- match.arg(method)
  p_adjust_method <- match.arg(p_adjust_method)

  # ---------------------------------------------------------------------------
  # Validation
  # ---------------------------------------------------------------------------
  .assert_data_frame(data)
  .assert_scalar_string(use)
  use_choices <- c("everything", "all.obs", "complete.obs", "na.or.complete",
                   "pairwise.complete.obs")
  if (!use %in% use_choices) {
    cli::cli_abort(
      "{.arg use} must be one of {.val {use_choices}}.",
      call = NULL
    )
  }
  .assert_proportion(alpha)

  # ---------------------------------------------------------------------------
  # Prepare data
  # ---------------------------------------------------------------------------
  df <- .prepare_cor_data(data, vars)

  n_obs <- nrow(df)
  if (n_obs < 5)
    cli::cli_alert_warning("Very small sample size (n = {n_obs}). Results may be unreliable.")

  # ---------------------------------------------------------------------------
  # Compute correlations and p-values
  # ---------------------------------------------------------------------------
  cor_results <- .compute_correlation_matrix(df, method, use)
  cor_matrix  <- cor_results$cor_matrix
  p_matrix    <- cor_results$p_matrix

  # ---------------------------------------------------------------------------
  # Multiple testing correction
  # ---------------------------------------------------------------------------
  if (p_adjust_method != "none") {
    p_vec     <- p_matrix[upper.tri(p_matrix)]
    p_adj_vec <- stats::p.adjust(p_vec, method = p_adjust_method)

    p_adjusted <- matrix(NA, nrow = nrow(p_matrix), ncol = ncol(p_matrix),
                         dimnames = dimnames(p_matrix))
    p_adjusted[upper.tri(p_adjusted)] <- p_adj_vec
    p_adjusted[lower.tri(p_adjusted)] <- t(p_adjusted)[lower.tri(p_adjusted)]
    diag(p_adjusted) <- NA
  } else {
    p_adjusted <- NULL
  }

  # ---------------------------------------------------------------------------
  # Significant pairs
  # ---------------------------------------------------------------------------
  p_for_sig        <- if (!is.null(p_adjusted)) p_adjusted else p_matrix
  significant_pairs <- .extract_sig_pairs(cor_matrix, p_for_sig, alpha)

  n_sig <- nrow(significant_pairs)
  n_tests <- choose(ncol(df), 2)
  cli::cli_alert_info("Found {n_sig} significant pair{?s} out of {n_tests} test{?s}.")

  if (n_sig > 0) {
    high_cor <- significant_pairs[abs(significant_pairs$correlation) > 0.9, ]
    if (nrow(high_cor) > 0)
      cli::cli_alert_warning("{nrow(high_cor)} pair{?s} with |r| > 0.9 (potential multicollinearity).")
  }

  # ---------------------------------------------------------------------------
  # Descriptive statistics
  # ---------------------------------------------------------------------------
  desc_stats <- data.frame(
    variable = names(df),
    n        = sapply(df, function(x) sum(!is.na(x))),
    mean     = sapply(df, mean,           na.rm = TRUE),
    sd       = sapply(df, stats::sd,      na.rm = TRUE),
    median   = sapply(df, stats::median,  na.rm = TRUE),
    min      = sapply(df, min,            na.rm = TRUE),
    max      = sapply(df, max,            na.rm = TRUE),
    row.names = NULL
  )

  invisible(structure(
    list(
      cor_matrix        = cor_matrix,
      p_matrix          = p_matrix,
      p_adjusted        = p_adjusted,
      method_used       = method,
      significant_pairs = significant_pairs,
      descriptive_stats = desc_stats,
      params            = list(
        use             = use,
        p_adjust_method = p_adjust_method,
        alpha           = alpha,
        n_vars          = ncol(df)
      ),
      data = df
    ),
    class = "quick_cor_result"
  ))
}


# =============================================================================
# S3 Methods
# =============================================================================

#' @export
print.quick_cor_result <- function(x, ...) {
  n_sig   <- nrow(x$significant_pairs)
  n_tests <- choose(x$params$n_vars, 2)
  cli::cli_text(
    "{x$method_used} | {x$params$n_vars} vars | {n_sig}/{n_tests} significant pairs (alpha = {x$params$alpha})"
  )
  invisible(x)
}


#' @export
summary.quick_cor_result <- function(object, ...) {
  x <- object

  cli::cli_h1("Correlation Analysis")

  # --- Parameters ---
  cli::cli_h2("Parameters")
  cli::cli_dl(c(
    "Method"      = x$method_used,
    "Missing obs" = x$params$use,
    "P-adjust"    = x$params$p_adjust_method,
    "Variables"   = as.character(x$params$n_vars),
    "alpha"       = sprintf("%.3f", x$params$alpha)
  ))

  # --- Descriptive statistics ---
  cli::cli_h2("Descriptive Statistics")
  print(x$descriptive_stats, row.names = FALSE)

  # --- Correlation summary ---
  cli::cli_h2("Correlation Summary")
  cor_vec <- x$cor_matrix[upper.tri(x$cor_matrix)]
  cli::cli_dl(c(
    "Min"      = sprintf("%.3f", min(cor_vec,       na.rm = TRUE)),
    "Max"      = sprintf("%.3f", max(cor_vec,       na.rm = TRUE)),
    "Mean |r|" = sprintf("%.3f", mean(abs(cor_vec), na.rm = TRUE))
  ))

  # --- Significant pairs ---
  cli::cli_h2("Significant Pairs")
  n_sig   <- nrow(x$significant_pairs)
  n_tests <- choose(x$params$n_vars, 2)

  if (x$params$p_adjust_method != "none") {
    cli::cli_alert_info(
      "Based on {.strong adjusted} p-values ({x$params$p_adjust_method})."
    )
  } else {
    cli::cli_alert_info("Based on {.strong unadjusted} p-values.")
  }

  cli::cli_text("{n_sig} out of {n_tests} pairs significant at alpha = {x$params$alpha}")

  if (n_sig > 0) {
    cli::cli_text("")
    print(x$significant_pairs, row.names = FALSE)
  }

  cli::cli_text("")
  invisible(x)
}


#' @rdname quick_cor
#' @export
#' @param x A \code{quick_cor_result} object from \code{quick_cor()}.
#' @param y Ignored.
#' @param ... Additional arguments passed to the internal plotting backend.
#' @param type One of \code{"full"} (default), \code{"upper"}, \code{"lower"}.
#' @param show_coef Logical. Show correlation coefficients? Default \code{FALSE}.
#' @param show_sig Logical. Show significance stars? Default \code{TRUE}.
#'   Silently disabled when \code{show_coef = TRUE}.
#' @param hc_order Logical. Reorder by hierarchical clustering? Default \code{TRUE}.
#' @param hc_method Clustering method. Default \code{"complete"}.
#' @param palette evanverse palette name. Default \code{"gradient_rd_bu"}.
#'   \code{NULL} uses a built-in Blue-White-Red scale.
#' @param lab_size Numeric. Label size when \code{show_coef = TRUE}. Default \code{3}.
#' @param title Character. Plot title. Default \code{NULL}.
#' @param show_axis_x Logical. Show x-axis labels? Default \code{TRUE}.
#' @param show_axis_y Logical. Show y-axis labels? Default \code{TRUE}.
#' @param axis_x_angle Numeric. X-axis label angle. Default \code{45}.
#' @param axis_y_angle Numeric. Y-axis label angle. Default \code{0}.
#' @param axis_text_size Numeric. Axis text size. Default \code{10}.
#' @param sig_level Numeric vector. P-value thresholds for ***, **, *.
#'   Default \code{c(0.001, 0.01, 0.05)}.
plot.quick_cor_result <- function(x, y = NULL,
                                   type           = c("full", "upper", "lower"),
                                   show_coef      = FALSE,
                                   show_sig       = TRUE,
                                   hc_order       = TRUE,
                                   hc_method      = "complete",
                                   palette        = "gradient_rd_bu",
                                   lab_size       = 3,
                                   title          = NULL,
                                   show_axis_x    = TRUE,
                                   show_axis_y    = TRUE,
                                   axis_x_angle   = 45,
                                   axis_y_angle   = 0,
                                   axis_text_size = 10,
                                   sig_level      = c(0.001, 0.01, 0.05),
                                   ...) {
  type      <- match.arg(type)
  sig_level <- sort(sig_level)

  if (length(sig_level) != 3L)
    cli::cli_abort("{.arg sig_level} must be a length-3 numeric vector.")

  if (show_coef && show_sig)
    cli::cli_abort("{.arg show_coef} and {.arg show_sig} are mutually exclusive.")

  p_for_plot <- if (!is.null(x$p_adjusted)) x$p_adjusted else x$p_matrix

  print(.create_cor_heatmap(
    cor_matrix     = x$cor_matrix,
    p_matrix       = p_for_plot,
    type           = type,
    show_coef      = show_coef,
    show_sig       = show_sig,
    sig_level      = sig_level,
    hc_order       = hc_order,
    hc_method      = hc_method,
    palette        = palette,
    lab_size       = lab_size,
    title          = title,
    show_axis_x    = show_axis_x,
    show_axis_y    = show_axis_y,
    axis_x_angle   = axis_x_angle,
    axis_y_angle   = axis_y_angle,
    axis_text_size = axis_text_size
  ))

  invisible(x)
}
