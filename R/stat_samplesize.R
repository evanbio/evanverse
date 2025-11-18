#' Calculate Required Sample Size
#'
#' Compute the minimum sample size required to achieve a specified statistical
#' power for detecting a given effect size. Supports multiple test types including
#' t-tests, ANOVA, proportion tests, correlation tests, and chi-square tests.
#'
#' @param power Numeric. Target statistical power (probability of correctly rejecting
#'   the null hypothesis). Default: 0.8 (80%).
#' @param effect_size Numeric. Effect size appropriate for the test:
#'   \itemize{
#'     \item Cohen's d for t-tests (small: 0.2, medium: 0.5, large: 0.8)
#'     \item Cohen's f for ANOVA (small: 0.1, medium: 0.25, large: 0.4)
#'     \item Cohen's h for proportion tests (small: 0.2, medium: 0.5, large: 0.8)
#'     \item Correlation coefficient r for correlation tests (small: 0.1, medium: 0.3, large: 0.5)
#'     \item Cohen's w for chi-square tests (small: 0.1, medium: 0.3, large: 0.5)
#'   }
#' @param test Character. Type of statistical test: "t.test" (default), "anova",
#'   "proportion", "correlation", or "chisq".
#' @param type Character. For t-tests only: "two.sample" (default), "one.sample", or "paired".
#' @param alternative Character. Direction of alternative hypothesis: "two.sided" (default),
#'   "less", or "greater".
#' @param alpha Numeric. Significance level (Type I error rate). Default: 0.05.
#' @param k Integer. Number of groups (required for ANOVA).
#' @param df Integer. Degrees of freedom (required for chi-square tests).
#' @param plot Logical. Generate a sample size curve plot? Default: TRUE.
#' @param plot_range Numeric vector of length 2. Range of effect sizes for the curve.
#'   If NULL (default), automatically determined.
#' @param palette Character. evanverse palette name for the plot. Default: "qual_vivid".
#' @param verbose Logical. Print detailed diagnostic information? Default: TRUE.
#'
#' @return An object of class \code{stat_samplesize_result} containing:
#'   \describe{
#'     \item{n}{Required sample size (per group for t-tests and ANOVA)}
#'     \item{n_total}{Total sample size across all groups}
#'     \item{power}{Target statistical power}
#'     \item{effect_size}{Effect size used in the calculation}
#'     \item{alpha}{Significance level}
#'     \item{test_type}{Type of statistical test}
#'     \item{plot}{ggplot2 object showing the sample size curve (if plot = TRUE)}
#'     \item{details}{List with interpretation and recommendations}
#'   }
#'
#' @details
#' Sample size estimation is a critical step in research planning. This function
#' calculates the minimum number of participants needed to achieve a specified
#' statistical power (typically 0.8 or 80%) for detecting an effect of a given size.
#'
#' The function uses the \pkg{pwr} package for all calculations, ensuring accurate
#' results based on well-established statistical theory. Sample sizes are always
#' rounded up to the nearest integer.
#'
#' @section Sample Size Curve:
#' When \code{plot = TRUE}, a sample size curve is generated showing how required
#' sample size changes with effect size. The curve helps visualize:
#' \itemize{
#'   \item The current required sample size (marked with a red point)
#'   \item Reference lines for small, medium, and large effects
#'   \item How detecting smaller effects requires larger samples
#' }
#'
#' @section Important Notes:
#' \itemize{
#'   \item Sample sizes are calculated per group for t-tests and ANOVA
#'   \item Consider adding 10-15% to account for potential dropout
#'   \item Very small effect sizes may require impractically large samples
#' }
#'
#' @examples
#' \dontrun{
#' # Example 1: Sample size for a two-sample t-test
#' result <- stat_samplesize(
#'   power = 0.8,
#'   effect_size = 0.5,
#'   test = "t.test",
#'   type = "two.sample"
#' )
#' print(result)
#' plot(result)
#'
#' # Example 2: Sample size for ANOVA with 3 groups
#' stat_samplesize(
#'   power = 0.8,
#'   effect_size = 0.25,
#'   test = "anova",
#'   k = 3
#' )
#'
#' # Example 3: Sample size for correlation test
#' stat_samplesize(
#'   power = 0.9,
#'   effect_size = 0.3,
#'   test = "correlation"
#' )
#' }
#'
#' @seealso
#' \code{\link{stat_power}} for calculating statistical power.
#'
#' @export
stat_samplesize <- function(power = 0.8,
                            effect_size,
                            test = c("t.test", "anova", "proportion", "correlation", "chisq"),
                            type = c("two.sample", "one.sample", "paired"),
                            alternative = c("two.sided", "less", "greater"),
                            alpha = 0.05,
                            k = NULL,
                            df = NULL,
                            plot = TRUE,
                            plot_range = NULL,
                            palette = "qual_vivid",
                            verbose = TRUE) {

  # ===========================================================================
  # Dependency checks
  # ===========================================================================
  if (!requireNamespace("pwr", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg pwr} is required for stat_samplesize().")
  }

  # ===========================================================================
  # Parameter validation and matching
  # ===========================================================================
  test <- match.arg(test)
  type <- match.arg(type)
  alternative <- match.arg(alternative)

  # Validate power
  if (!is.numeric(power) || length(power) != 1 || is.na(power) ||
      power <= 0 || power >= 1) {
    cli::cli_abort("{.arg power} must be a single numeric value between 0 and 1.")
  }

  # Validate effect_size
  if (missing(effect_size)) {
    cli::cli_abort("missing required argument {.arg effect_size}.")
  }

  if (!is.numeric(effect_size) || length(effect_size) != 1 ||
      is.na(effect_size) || effect_size <= 0) {
    cli::cli_abort("{.arg effect_size} must be a single positive numeric value.")
  }

  # Validate alpha
  if (!is.numeric(alpha) || length(alpha) != 1 || is.na(alpha) ||
      alpha <= 0 || alpha >= 1) {
    cli::cli_abort("{.arg alpha} must be a single numeric value between 0 and 1.")
  }

  # Test-specific validations
  if (test == "anova" && is.null(k)) {
    cli::cli_abort("{.arg k} (number of groups) is required for ANOVA.")
  }

  if (test == "anova" && (!is.numeric(k) || length(k) != 1 || is.na(k) ||
                          k < 2 || k != round(k))) {
    cli::cli_abort("{.arg k} must be an integer >= 2.")
  }

  if (test == "chisq" && is.null(df)) {
    cli::cli_abort("{.arg df} (degrees of freedom) is required for chi-square test.")
  }

  if (test == "chisq" && (!is.numeric(df) || length(df) != 1 || is.na(df) ||
                          df < 1 || df != round(df))) {
    cli::cli_abort("{.arg df} must be a positive integer.")
  }

  # Validate plot parameters
  if (!is.logical(plot) || length(plot) != 1 || is.na(plot)) {
    cli::cli_abort("{.arg plot} must be a single logical value.")
  }

  if (!is.null(plot_range)) {
    if (!is.numeric(plot_range) || length(plot_range) != 2 || any(is.na(plot_range)) ||
        plot_range[1] >= plot_range[2] || plot_range[1] <= 0) {
      cli::cli_abort(
        "{.arg plot_range} must be a numeric vector of length 2 with positive values and plot_range[1] < plot_range[2]."
      )
    }

    # Test-specific validation for plot_range
    if (test == "correlation" && plot_range[2] > 1) {
      cli::cli_abort("{.arg plot_range[2]} for correlation must be <= 1.")
    }
  }

  if (!is.logical(verbose) || length(verbose) != 1 || is.na(verbose)) {
    cli::cli_abort("{.arg verbose} must be a single logical value.")
  }

  # ===========================================================================
  # Call appropriate pwr function
  # ===========================================================================
  pwr_result <- tryCatch(
    {
      switch(
        test,
        "t.test" = {
          pwr::pwr.t.test(
            d = effect_size,
            sig.level = alpha,
            power = power,
            type = type,
            alternative = alternative
          )
        },
        "anova" = {
          pwr::pwr.anova.test(
            k = k,
            f = effect_size,
            sig.level = alpha,
            power = power
          )
        },
        "proportion" = {
          pwr::pwr.p.test(
            h = effect_size,
            sig.level = alpha,
            power = power,
            alternative = alternative
          )
        },
        "correlation" = {
          pwr::pwr.r.test(
            r = effect_size,
            sig.level = alpha,
            power = power,
            alternative = alternative
          )
        },
        "chisq" = {
          pwr::pwr.chisq.test(
            w = effect_size,
            df = df,
            sig.level = alpha,
            power = power
          )
        }
      )
    },
    error = function(e) {
      cli::cli_abort(
        c(
          "Sample size calculation failed.",
          "x" = "Error: {e$message}"
        )
      )
    }
  )

  # Extract and round up sample size
  n_raw <- if (test == "chisq") pwr_result$N else pwr_result$n
  n <- as.integer(ceiling(n_raw))

  # Calculate total sample size
  n_total <- as.integer(if (test == "t.test" && type == "two.sample") {
    n * 2
  } else if (test == "anova") {
    n * k
  } else {
    n
  })

  # Warn if sample size is very large
  if (n > 1000) {
    cli::cli_warn(
      c(
        "The calculated sample size is very large (n = {n}).",
        "i" = "This may be impractical. Consider:",
        "*" = "Increasing the minimum detectable effect size",
        "*" = "Accepting lower statistical power",
        "*" = "Using a larger alpha level (if appropriate)"
      )
    )
  }

  # ===========================================================================
  # Generate interpretation and recommendations
  # ===========================================================================
  interpretation <- .generate_samplesize_interpretation(n, n_total, power, effect_size, test, k)
  recommendation <- .generate_samplesize_recommendation(n, test)

  # ===========================================================================
  # Generate plot (if requested)
  # ===========================================================================
  plot_obj <- NULL
  if (plot) {
    plot_obj <- .create_samplesize_curve(
      n = n,
      power = power,
      effect_size = effect_size,
      alpha = alpha,
      test = test,
      type = type,
      alternative = alternative,
      k = k,
      df = df,
      plot_range = plot_range,
      palette = palette
    )
  }

  # ===========================================================================
  # Construct result object
  # ===========================================================================
  result <- structure(
    list(
      n = n,
      n_total = n_total,
      power = power,
      effect_size = effect_size,
      alpha = alpha,
      test_type = test,
      test_subtype = if (test == "t.test") type else NULL,
      alternative = alternative,
      k = k,
      df = df,
      plot = plot_obj,
      pwr_object = pwr_result,
      details = list(
        interpretation = interpretation,
        recommendation = recommendation
      ),
      timestamp = Sys.time()
    ),
    class = c("stat_samplesize_result", "list")
  )

  # ===========================================================================
  # Print result (if verbose)
  # ===========================================================================
  if (verbose) {
    print(result)
  }

  invisible(result)
}


# =============================================================================
# S3 Methods
# =============================================================================

#' @export
print.stat_samplesize_result <- function(x, ...) {
  cli::cli_h1("Sample Size Estimation")
  cli::cli_text("")

  # Test information
  if (x$test_type == "t.test") {
    cli::cli_alert_info("Test: {x$test_type} ({x$test_subtype})")
  } else if (x$test_type == "anova") {
    cli::cli_alert_info("Test: {x$test_type} (k = {x$k} groups)")
  } else {
    cli::cli_alert_info("Test: {x$test_type}")
  }

  cli::cli_alert_info("Target power: {sprintf('%.2f', x$power)}")
  cli::cli_alert_info("Effect size: {sprintf('%.3f', x$effect_size)}")
  cli::cli_alert_info("Significance level (alpha): {sprintf('%.3f', x$alpha)}")
  cli::cli_alert_info("Alternative: {x$alternative}")

  cli::cli_text("")
  cli::cli_h2("Result")

  # Sample size result
  if (x$test_type %in% c("t.test", "anova") && x$n_total > x$n) {
    cli::cli_alert_success(
      "Sample size per group: {.val {x$n}}"
    )
    cli::cli_alert_success(
      "Total sample size: {.val {x$n_total}}"
    )
  } else {
    cli::cli_alert_success(
      "Required sample size (total): {.val {x$n}}"
    )
  }

  cli::cli_text("")
  cli::cli_text(x$details$interpretation)

  if (!is.null(x$details$recommendation)) {
    cli::cli_text("")
    cli::cli_alert_info("Recommendation: {x$details$recommendation}")
  }

  cli::cli_text("")
  invisible(x)
}


#' @export
summary.stat_samplesize_result <- function(object, ...) {
  cat("\n")
  cat("Sample Size Estimation Summary\n")
  cat("==============================\n\n")

  cat("Test Information:\n")
  if (object$test_type == "t.test") {
    cat(sprintf("  Test type:         %s (%s)\n", object$test_type, object$test_subtype))
  } else if (object$test_type == "anova") {
    cat(sprintf("  Test type:         %s (k = %d groups)\n", object$test_type, object$k))
  } else {
    cat(sprintf("  Test type:         %s\n", object$test_type))
  }
  cat(sprintf("  Alternative:       %s\n", object$alternative))
  cat("\n")

  cat("Parameters:\n")
  cat(sprintf("  Target power:      %.4f (%.2f%%)\n", object$power, object$power * 100))
  cat(sprintf("  Effect size:       %.4f\n", object$effect_size))
  cat(sprintf("  Significance (alpha):  %.4f\n", object$alpha))
  cat("\n")

  cat("Result:\n")
  if (object$test_type %in% c("t.test", "anova") && object$n_total > object$n) {
    cat(sprintf("  Sample size (per group):   %d\n", object$n))
    cat(sprintf("  Total sample size:         %d\n", object$n_total))
  } else {
    cat(sprintf("  Required sample size:      %d (total)\n", object$n))
  }
  cat("\n")

  cat("Interpretation:\n")
  cat(sprintf("  %s\n", object$details$interpretation))
  cat("\n")

  if (!is.null(object$details$recommendation)) {
    cat("Recommendation:\n")
    cat(sprintf("  %s\n", object$details$recommendation))
    cat("\n")
  }

  invisible(object)
}


#' @export
plot.stat_samplesize_result <- function(x, y = NULL, ...) {
  if (!is.null(x$plot)) {
    print(x$plot)
  } else {
    cli::cli_warn("No plot available. Set {.arg plot = TRUE} when calling stat_samplesize().")
  }
  invisible(x)
}


# =============================================================================
# Internal Helper Functions
# =============================================================================

#' Generate Sample Size Interpretation Text
#' @keywords internal
#' @noRd
.generate_samplesize_interpretation <- function(n, n_total, power, effect_size, test, k) {
  if (test %in% c("t.test", "anova") && n_total > n) {
    sprintf(
      "To achieve %.0f%% power for detecting an effect size of %.2f, you need %d subjects per group (%d total).",
      power * 100, effect_size, n, n_total
    )
  } else {
    test_name <- switch(
      test,
      "proportion" = "proportion test",
      "correlation" = "correlation test",
      "chisq" = "chi-square test",
      test
    )
    sprintf(
      "To achieve %.0f%% power for detecting an effect size of %.2f in a %s, you need a total of %d subjects.",
      power * 100, effect_size, test_name, n
    )
  }
}


#' Generate Sample Size Recommendation Text
#' @keywords internal
#' @noRd
.generate_samplesize_recommendation <- function(n, test) {
  if (n < 10) {
    "This is a very small sample size. Ensure your measurement instruments are highly reliable."
  } else if (n < 30) {
    "Consider recruiting 10-15% more subjects to account for potential dropout or exclusions."
  } else if (n < 100) {
    "Consider recruiting 10-20% more subjects to account for potential dropout, missing data, or protocol violations."
  } else {
    "For large studies, consider interim analyses and adaptive designs. Budget 15-20% extra for dropout."
  }
}


#' Create Sample Size Curve Plot
#' @keywords internal
#' @noRd
.create_samplesize_curve <- function(n, power, effect_size, alpha, test, type,
                                      alternative, k, df, plot_range, palette) {

  # Determine effect size range for curve
  if (is.null(plot_range)) {
    es_min <- max(0.05, effect_size * 0.3)

    # Set upper limit based on test type
    es_max_default <- switch(
      test,
      "correlation" = 0.95,     # r must be < 1
      "anova" = 1.0,            # f rarely > 1
      "chisq" = 1.0,            # w rarely > 1
      "t.test" = 2.0,           # d can be larger
      "proportion" = 2.0,       # h can be larger
      1.5                        # fallback
    )

    es_max <- min(effect_size * 2, es_max_default)
    plot_range <- c(es_min, es_max)
  }

  es_seq <- seq(plot_range[1], plot_range[2], length.out = 100)

  # Calculate sample size for each effect size
  n_seq <- sapply(es_seq, function(es) {
    tryCatch(
      {
        result <- switch(
          test,
          "t.test" = pwr::pwr.t.test(d = es, sig.level = alpha, power = power,
                                     type = type, alternative = alternative),
          "anova" = pwr::pwr.anova.test(k = k, f = es, sig.level = alpha, power = power),
          "proportion" = pwr::pwr.p.test(h = es, sig.level = alpha, power = power,
                                         alternative = alternative),
          "correlation" = pwr::pwr.r.test(r = es, sig.level = alpha, power = power,
                                          alternative = alternative),
          "chisq" = pwr::pwr.chisq.test(w = es, df = df, sig.level = alpha, power = power)
        )
        ceiling(if (test == "chisq") result$N else result$n)
      },
      error = function(e) NA_real_
    )
  })

  # Get palette colors
  colors <- tryCatch(
    suppressMessages(get_palette(palette, type = "qualitative", n = 2)),
    error = function(e) c("#E64B35", "#4DBBD5")
  )

  # Create plot data
  plot_data <- data.frame(
    effect_size = es_seq,
    n = n_seq
  )

  # Build plot
  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = effect_size, y = n)) +
    ggplot2::geom_line(color = colors[1], linewidth = 1.2) +
    ggplot2::geom_point(data = data.frame(effect_size = effect_size, n = n),
                        ggplot2::aes(x = effect_size, y = n),
                        color = colors[2], size = 3) +
    ggplot2::labs(
      title = "Required Sample Size Curve",
      subtitle = sprintf("Target power = %.2f, alpha = %.3f", power, alpha),
      x = "Effect Size",
      y = if (test %in% c("t.test", "anova")) "Required Sample Size (per group)" else "Required Sample Size"
    ) +
    ggplot2::scale_x_continuous(
      limits = plot_range,
      breaks = scales::pretty_breaks(n = 8),
      expand = ggplot2::expansion(mult = c(0.02, 0.02))
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(size = 11)
    )

  # Add reference lines for common effect sizes (within plot range)
  if (test == "t.test") {
    ref_lines <- c(small = 0.2, medium = 0.5, large = 0.8)
    ref_lines <- ref_lines[ref_lines >= plot_range[1] & ref_lines <= plot_range[2]]
    if (length(ref_lines) > 0) {
      p <- p +
        ggplot2::geom_vline(xintercept = ref_lines, linetype = "dashed",
                            linewidth = 0.6, alpha = 0.5, color = "gray40")
    }
  } else if (test == "anova") {
    ref_lines <- c(small = 0.1, medium = 0.25, large = 0.4)
    ref_lines <- ref_lines[ref_lines >= plot_range[1] & ref_lines <= plot_range[2]]
    if (length(ref_lines) > 0) {
      p <- p +
        ggplot2::geom_vline(xintercept = ref_lines, linetype = "dashed",
                            linewidth = 0.6, alpha = 0.5, color = "gray40")
    }
  } else if (test == "correlation") {
    ref_lines <- c(small = 0.1, medium = 0.3, large = 0.5)
    ref_lines <- ref_lines[ref_lines >= plot_range[1] & ref_lines <= plot_range[2]]
    if (length(ref_lines) > 0) {
      p <- p +
        ggplot2::geom_vline(xintercept = ref_lines, linetype = "dashed",
                            linewidth = 0.6, alpha = 0.5, color = "gray40")
    }
  }

  p
}
