# =============================================================================
# biostat.R — quick_ttest: two-group comparison with auto method selection
# =============================================================================

#' Two-group comparison with automatic method selection
#'
#' Performs a t-test or Wilcoxon test (auto-selected by normality and sample size)
#' with a publication-ready plot. Requires exactly 2 groups.
#'
#' Method selection when `method = "auto"`:
#' - n >= 100: t-test (CLT applies; Shapiro-Wilk is unreliable at large n)
#' - 30 <= n < 100: Shapiro-Wilk at p < 0.01 threshold
#' - n < 30: Shapiro-Wilk at p < 0.05 threshold
#'
#' When `var.equal = NULL`, Levene's test determines Student's vs Welch's t-test.
#'
#' @param data A data frame.
#' @param group Column name for the grouping variable (exactly 2 levels). Supports NSE.
#' @param value Column name for the numeric values. Supports NSE.
#' @param method One of `"auto"` (default), `"t.test"`, `"wilcox.test"`.
#' @param paired Logical. Paired test? Default `FALSE`. Requires `id` when `TRUE`.
#' @param id Column name for pairing ID (required when `paired = TRUE`). Supports NSE.
#' @param alternative One of `"two.sided"` (default), `"less"`, `"greater"`.
#' @param var.equal Logical or `NULL`. If `NULL`, auto-tested via Levene's test.
#' @param conf.level Numeric. Confidence level. Default `0.95`.
#' @param plot_type One of `"boxplot"` (default), `"violin"`, `"both"`.
#' @param add_jitter Logical. Add jittered points? Default `TRUE`.
#' @param point_size Numeric. Point size. Default `2`.
#' @param point_alpha Numeric. Point transparency (0–1). Default `0.6`.
#' @param show_p_value Logical. Show p-value on plot? Default `TRUE`.
#' @param p_label One of `"p.signif"` (stars, default) or `"p.format"` (numeric).
#' @param palette Palette name from evanverse. Default `"qual_vivid"`. `NULL` for ggplot2 defaults.
#' @param verbose Logical. Print progress messages? Default `TRUE`.
#' @param ... Reserved for future use.
#'
#' @return A `quick_ttest_result` object with:
#' - `plot`: ggplot object
#' - `test_result`: htest object
#' - `method_used`, `descriptive_stats`, `normality_tests`, `variance_test`, `parameters`, `timestamp`
#'
#' @seealso [stats::t.test()], [stats::wilcox.test()]
#' @importFrom rlang .data
#' @importFrom stats complete.cases median sd
#' @export
#'
#' @examples
#' set.seed(42)
#' df <- data.frame(
#'   group = rep(c("A", "B"), each = 30),
#'   value = c(rnorm(30, 5), rnorm(30, 6))
#' )
#' result <- quick_ttest(df, group = group, value = value)
#' summary(result)
quick_ttest <- function(data,
                        group,
                        value,
                        method      = c("auto", "t.test", "wilcox.test"),
                        paired      = FALSE,
                        id          = NULL,
                        alternative = c("two.sided", "less", "greater"),
                        var.equal   = NULL,
                        conf.level  = 0.95,
                        plot_type   = c("boxplot", "violin", "both"),
                        add_jitter  = TRUE,
                        point_size  = 2,
                        point_alpha = 0.6,
                        show_p_value = TRUE,
                        p_label     = c("p.signif", "p.format"),
                        palette     = "qual_vivid",
                        verbose     = TRUE,
                        ...) {

  # Resolve arguments
  method      <- match.arg(method)
  alternative <- match.arg(alternative)
  plot_type   <- match.arg(plot_type)
  p_label     <- match.arg(p_label)

  # Validate scalar inputs
  if (!is.data.frame(data))                          cli::cli_abort("{.arg data} must be a data frame.")
  .assert_flag(paired)
  .assert_flag(verbose)
  if (paired && is.null(id))                         cli::cli_abort("{.arg id} required when {.arg paired} is TRUE.")
  if (!is.numeric(conf.level) || conf.level <= 0 || conf.level >= 1)
    cli::cli_abort("{.arg conf.level} must be between 0 and 1.")

  # Resolve column names via NSE
  group_name <- rlang::as_string(rlang::ensym(group))
  value_name <- rlang::as_string(rlang::ensym(value))
  id_name    <- if (!is.null(id)) rlang::as_string(rlang::ensym(id)) else NULL

  if (!group_name %in% names(data)) cli::cli_abort("Column {.field {group_name}} not found in {.arg data}.")
  if (!value_name %in% names(data)) cli::cli_abort("Column {.field {value_name}} not found in {.arg data}.")
  if (paired && !id_name %in% names(data)) cli::cli_abort("Column {.field {id_name}} not found in {.arg data}.")

  # Prepare data
  df <- .prepare_ttest_data(data, group_name, value_name, id_name,
                             paired = paired, verbose = verbose)
  group_levels <- levels(df$group)
  if (paired) df <- .validate_paired_ttest_data(df, verbose = verbose)

  # Descriptive statistics
  desc_stats <- .describe_two_group_data(df, group_levels)

  # Method selection
  auto_decision <- list(normality_results = NULL, variance_result = NULL, method_rationale = NULL)

  if (method == "auto") {
    normality_tests <- .check_group_normality(df, paired = paired, verbose = verbose)
    auto_decision$normality_results <- normality_tests

    if (normality_tests$recommendation == "parametric") {
      method_selected <- "t.test"
      auto_decision$method_rationale <- normality_tests$rationale
      if (!paired && is.null(var.equal)) {
        vt <- .check_variance_equality(df, verbose = verbose)
        auto_decision$variance_result <- vt
        var.equal <- vt$equal_variance
      }
    } else {
      method_selected <- "wilcox.test"
      auto_decision$method_rationale <- normality_tests$rationale
    }
  } else {
    method_selected <- method
    if (method_selected == "t.test" && is.null(var.equal)) {
      vt <- .check_variance_equality(df, verbose = verbose)
      auto_decision$variance_result <- vt
      var.equal <- vt$equal_variance
    }
  }

  if (is.null(var.equal)) var.equal <- TRUE

  # Run test
  if (method_selected == "t.test") {
    test_result <- .run_quick_ttest(df, group_levels, paired, alternative, var.equal, conf.level)
  } else {
    test_result <- .run_quick_wilcox(df, group_levels, paired, alternative, conf.level)
  }

  if (verbose) {
    p_fmt <- if (test_result$p.value < 0.001) "p < 0.001" else sprintf("p = %.4f", test_result$p.value)
    cli::cli_alert_info("{method_selected}: {p_fmt}")
  }

  # Plot
  plot_obj <- .create_comparison_plot(
    data = df, group_levels = group_levels, test_result = test_result,
    plot_type = plot_type, add_jitter = add_jitter,
    point_size = point_size, point_alpha = point_alpha,
    show_p_value = show_p_value, p_label = p_label,
    palette = palette, group_name = group_name, value_name = value_name
  )

  # Return
  structure(
    list(
      plot             = plot_obj,
      test_result      = test_result,
      method_used      = method_selected,
      normality_tests  = auto_decision$normality_results,
      variance_test    = auto_decision$variance_result,
      descriptive_stats = desc_stats,
      auto_decision    = auto_decision,
      parameters       = list(paired = paired, alternative = alternative,
                              var.equal = var.equal, conf.level = conf.level,
                              group_name = group_name, value_name = value_name,
                              plot_type = plot_type, palette = palette),
      timestamp        = Sys.time()
    ),
    class = "quick_ttest_result"
  )
}


# =============================================================================
# S3 methods
# =============================================================================

#' @export
print.quick_ttest_result <- function(x, ...) {
  p_fmt <- if (x$test_result$p.value < 0.001) "p < 0.001" else
    sprintf("p = %.4f", x$test_result$p.value)
  n_per_group <- paste(
    paste(x$descriptive_stats$group, x$descriptive_stats$n, sep = " n="),
    collapse = ", "
  )
  cli::cli_text("{x$method_used} | {p_fmt} | {n_per_group}")
  invisible(x)
}


#' @export
summary.quick_ttest_result <- function(object, ...) {
  p_fmt <- if (object$test_result$p.value < 0.001) "p < 0.001" else
    sprintf("p = %.4f", object$test_result$p.value)

  cli::cli_h2("{object$method_used} ({p_fmt})")
  cli::cli_text("paired: {object$parameters$paired} | alternative: {object$parameters$alternative} | conf.level: {object$parameters$conf.level}")
  if (object$method_used == "t.test")
    cli::cli_text("var.equal: {object$parameters$var.equal}")

  cat("\n")
  print(object$test_result)

  cat("\n")
  cli::cli_h3("Descriptive statistics")
  print(object$descriptive_stats)

  if (!is.null(object$normality_tests)) {
    cat("\n")
    cli::cli_h3("Normality (Shapiro-Wilk)")
    for (grp in names(object$normality_tests$tests)) {
      res <- object$normality_tests$tests[[grp]]
      if (!is.na(res$p.value)) {
        pf <- if (res$p.value < 0.001) "p < 0.001" else sprintf("p = %.3f", res$p.value)
        cli::cli_text("  {grp}: n = {res$n}, {pf}")
      }
    }
    cli::cli_text("  → {object$normality_tests$rationale}")
  }

  if (!is.null(object$variance_test) && object$variance_test$test_performed) {
    cat("\n")
    cli::cli_h3("Variance (Levene)")
    pf <- if (object$variance_test$p_value < 0.001) "p < 0.001" else
      sprintf("p = %.3f", object$variance_test$p_value)
    cli::cli_text("  {pf} | equal: {object$variance_test$equal_variance}")
  }

  cat("\n")
  cli::cli_text("{format(object$timestamp, '%Y-%m-%d %H:%M:%S')}")
  invisible(object)
}
