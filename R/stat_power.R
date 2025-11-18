#' Calculate Statistical Power
#'
#' Compute the statistical power (probability of correctly rejecting the null
#' hypothesis) for a given sample size, effect size, and significance level.
#' Supports multiple test types including t-tests, ANOVA, proportion tests,
#' correlation tests, and chi-square tests.
#'
#' @param n Integer. Sample size. Interpretation depends on test type:
#'   \itemize{
#'     \item t-tests and ANOVA: Sample size per group
#'     \item Proportion test: Total sample size (one-sample test)
#'     \item Correlation: Total number of paired observations
#'     \item Chi-square: Total sample size
#'   }
#' @param effect_size Numeric. Effect size appropriate for the test (must be positive):
#'   \itemize{
#'     \item Cohen's d for t-tests (small: 0.2, medium: 0.5, large: 0.8)
#'     \item Cohen's f for ANOVA (small: 0.1, medium: 0.25, large: 0.4)
#'     \item Cohen's h for proportion tests (small: 0.2, medium: 0.5, large: 0.8)
#'     \item Correlation coefficient r for correlation tests (small: 0.1, medium: 0.3, large: 0.5).
#'       Use absolute value; power is the same for positive and negative correlations.
#'     \item Cohen's w for chi-square tests (small: 0.1, medium: 0.3, large: 0.5)
#'   }
#' @param test Character. Type of statistical test: "t.test" (default), "anova",
#'   "proportion", "correlation", or "chisq".
#' @param type Character. For t-tests only: "two.sample" (default), "one.sample", or "paired".
#' @param alternative Character. Direction of alternative hypothesis: "two.sided" (default),
#'   "less", or "greater". Note: Only applicable to t-tests, proportion tests, and
#'   correlation tests. Ignored for ANOVA and chi-square tests (which are inherently non-directional).
#' @param alpha Numeric. Significance level (Type I error rate). Default: 0.05.
#' @param k Integer. Number of groups (required for ANOVA).
#' @param df Integer. Degrees of freedom (required for chi-square tests).
#' @param plot Logical. Generate a power curve plot? Default: TRUE.
#' @param plot_range Numeric vector of length 2. Range of sample sizes for the power
#'   curve. If NULL (default), automatically determined.
#' @param palette Character. evanverse palette name for the plot. Default: "qual_vivid".
#' @param verbose Logical. Print detailed diagnostic information? Default: TRUE.
#'
#' @return An object of class \code{stat_power_result} containing:
#'   \describe{
#'     \item{power}{The calculated statistical power (probability of detecting the effect)}
#'     \item{n}{Sample size used in the calculation}
#'     \item{effect_size}{Effect size used in the calculation}
#'     \item{alpha}{Significance level}
#'     \item{test_type}{Type of statistical test}
#'     \item{test_subtype}{Subtype for t-tests (e.g., "two.sample", "one.sample", "paired"); NULL for other tests}
#'     \item{alternative}{Direction of alternative hypothesis used in the test}
#'     \item{k}{Number of groups (for ANOVA); NULL for other tests}
#'     \item{df}{Degrees of freedom (for chi-square tests); NULL for other tests}
#'     \item{plot}{ggplot2 object showing the power curve (if plot = TRUE); NULL otherwise}
#'     \item{pwr_object}{Raw result object from the \pkg{pwr} package function}
#'     \item{details}{List with interpretation and recommendation text}
#'     \item{timestamp}{POSIXct timestamp of when the calculation was performed}
#'   }
#'
#' @details
#' Statistical power is the probability of correctly rejecting the null hypothesis
#' when it is false (i.e., detecting a true effect). Conventionally, a power of
#' 0.8 (80%) is considered adequate, though higher power (0.9 or 0.95) may be
#' desirable in some contexts.
#'
#' The function uses the \pkg{pwr} package for all power calculations, ensuring
#' accurate results based on well-established statistical theory.
#'
#' @section Test-Specific Notes:
#' \strong{Proportion Test:} Uses \code{pwr.p.test}, which is for one-sample
#' proportion tests (testing a single proportion against a hypothesized value).
#' For two-sample proportion tests, consider using specialized tools or packages.
#' The \code{effect_size} parameter uses Cohen's h, which quantifies the difference
#' between two proportions. In one-sample settings, Cohen's h is computed from the
#' observed proportion \emph{p} and the null hypothesis proportion \emph{p0}.
#'
#' @section Power Curve:
#' When \code{plot = TRUE}, a power curve is generated showing how statistical
#' power changes with sample size. The curve helps visualize:
#' \itemize{
#'   \item The current power level (marked with a red point)
#'   \item The conventional 0.8 power threshold (red dashed line)
#'   \item How increasing sample size affects power
#' }
#'
#' @examples
#' \dontrun{
#' # Example 1: Power for a two-sample t-test
#' result <- stat_power(
#'   n = 30,
#'   effect_size = 0.5,
#'   test = "t.test",
#'   type = "two.sample"
#' )
#' print(result)
#' plot(result)
#'
#' # Example 2: Power for ANOVA with 3 groups
#' stat_power(
#'   n = 25,
#'   effect_size = 0.25,
#'   test = "anova",
#'   k = 3
#' )
#'
#' # Example 3: Power for correlation test
#' stat_power(
#'   n = 50,
#'   effect_size = 0.3,
#'   test = "correlation"
#' )
#' }
#'
#'
#' @export
stat_power <- function(n,
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
  # Parameter validation and matching
  # ===========================================================================
  test <- match.arg(test)
  type <- match.arg(type)
  alternative <- match.arg(alternative)

  # Validate n
  if (missing(n) || !is.numeric(n) || length(n) != 1 || is.na(n) ||
      n <= 0 || n != round(n)) {
    cli::cli_abort("{.arg n} must be a single positive integer.")
  }

  # Validate effect_size
  if (missing(effect_size) || !is.numeric(effect_size) || length(effect_size) != 1 ||
      is.na(effect_size) || effect_size <= 0) {
    cli::cli_abort("{.arg effect_size} must be a single positive numeric value.")
  }

  # Test-specific effect_size range validation
  if (test == "correlation" && effect_size > 1) {
    cli::cli_abort("{.arg effect_size} for correlation must be between 0 and 1.")
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

  # Warn if alternative is specified for non-directional tests
  if (test %in% c("anova", "chisq") && alternative != "two.sided") {
    cli::cli_warn(
      c(
        "{.arg alternative} is ignored for {.val {test}} tests.",
        "i" = "ANOVA and chi-square tests are inherently non-directional."
      )
    )
  }

  # Validate plot parameters
  if (!is.logical(plot) || length(plot) != 1 || is.na(plot)) {
    cli::cli_abort("{.arg plot} must be a single logical value.")
  }

  if (!is.logical(verbose) || length(verbose) != 1 || is.na(verbose)) {
    cli::cli_abort("{.arg verbose} must be a single logical value.")
  }

  if (!is.null(plot_range)) {
    if (!is.numeric(plot_range) || length(plot_range) != 2 || any(is.na(plot_range))) {
      cli::cli_abort("{.arg plot_range} must be a numeric vector of length 2.")
    }
    plot_range <- sort(plot_range)
    if (plot_range[1] <= 0) {
      cli::cli_abort("{.arg plot_range} values must be positive.")
    }
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
            n = n,
            d = effect_size,
            sig.level = alpha,
            type = type,
            alternative = alternative
          )
        },
        "anova" = {
          pwr::pwr.anova.test(
            k = k,
            n = n,
            f = effect_size,
            sig.level = alpha
          )
        },
        "proportion" = {
          pwr::pwr.p.test(
            h = effect_size,
            n = n,
            sig.level = alpha,
            alternative = alternative
          )
        },
        "correlation" = {
          pwr::pwr.r.test(
            r = effect_size,
            n = n,
            sig.level = alpha,
            alternative = alternative
          )
        },
        "chisq" = {
          pwr::pwr.chisq.test(
            w = effect_size,
            N = n,
            df = df,
            sig.level = alpha
          )
        }
      )
    },
    error = function(e) {
      cli::cli_abort(
        c(
          "Power calculation failed.",
          "x" = "Error: {e$message}"
        )
      )
    }
  )

  power <- pwr_result$power

  # ===========================================================================
  # Generate interpretation and recommendations
  # ===========================================================================
  interpretation <- .generate_power_interpretation(power, test, effect_size, n)
  recommendation <- .generate_power_recommendation(power, n, effect_size, test, type, alpha, k, df, alternative)

  # ===========================================================================
  # Generate plot (if requested)
  # ===========================================================================
  plot_obj <- NULL
  if (plot) {
    plot_obj <- .create_power_curve(
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
      power = power,
      n = n,
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
    class = c("stat_power_result", "list")
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
print.stat_power_result <- function(x, ...) {
  cli::cli_h1("Statistical Power Analysis")
  cli::cli_text("")

  # Test information
  if (x$test_type == "t.test") {
    cli::cli_alert_info("Test: {x$test_type} ({x$test_subtype})")
  } else if (x$test_type == "anova") {
    cli::cli_alert_info("Test: {x$test_type} (k = {x$k} groups)")
  } else {
    cli::cli_alert_info("Test: {x$test_type}")
  }

  cli::cli_alert_info("Effect size: {sprintf('%.3f', x$effect_size)}")
  # Sample size with clarification
  n_label <- if (x$test_type %in% c("t.test", "anova")) {
    sprintf("Sample size: %d (per group)", x$n)
  } else {
    sprintf("Sample size: %d (total)", x$n)
  }
  cli::cli_alert_info(n_label)
  cli::cli_alert_info("Significance level (alpha): {sprintf('%.3f', x$alpha)}")
  cli::cli_alert_info("Alternative: {x$alternative}")

  cli::cli_text("")
  cli::cli_h2("Result")

  # Power result with color coding
  power_pct <- sprintf("%.2f%%", x$power * 100)
  if (x$power < 0.5) {
    cli::cli_alert_danger("Statistical Power: {.val {power_pct}} (Very Low)")
  } else if (x$power < 0.8) {
    cli::cli_alert_warning("Statistical Power: {.val {power_pct}} (Below Recommended)")
  } else if (x$power < 0.95) {
    cli::cli_alert_success("Statistical Power: {.val {power_pct}} (Good)")
  } else {
    cli::cli_alert_success("Statistical Power: {.val {power_pct}} (Very High)")
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
summary.stat_power_result <- function(object, ...) {
  cat("\n")
  cat("Statistical Power Analysis Summary\n")
  cat("==================================\n\n")

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
  cat(sprintf("  Effect size:       %.4f\n", object$effect_size))
  # Sample size with clarification
  n_unit <- if (object$test_type %in% c("t.test", "anova")) "(per group)" else "(total)"
  cat(sprintf("  Sample size:       %d %s\n", object$n, n_unit))
  cat(sprintf("  Significance (alpha):  %.4f\n", object$alpha))
  cat("\n")

  cat("Result:\n")
  cat(sprintf("  Power (1-beta):       %.4f (%.2f%%)\n", object$power, object$power * 100))
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
plot.stat_power_result <- function(x, y = NULL, ...) {
  if (!is.null(x$plot)) {
    print(x$plot)
  } else {
    cli::cli_warn("No plot available. Set {.arg plot = TRUE} when calling stat_power().")
  }
  invisible(x)
}


# =============================================================================
# Internal Helper Functions
# =============================================================================

#' Generate Power Interpretation Text
#' @keywords internal
#' @noRd
.generate_power_interpretation <- function(power, test, effect_size, n) {
  if (power < 0.5) {
    sprintf(
      "This study has only %.1f%% power, meaning there is a %.1f%% chance of detecting a true effect of size %.2f. This is considered very low power.",
      power * 100, power * 100, effect_size
    )
  } else if (power < 0.8) {
    sprintf(
      "This study has %.1f%% power to detect an effect size of %.2f. While this provides some ability to detect the effect, it falls below the conventional 80%% threshold.",
      power * 100, effect_size
    )
  } else if (power < 0.95) {
    sprintf(
      "This study has %.1f%% power, which is considered good. There is a %.1f%% probability of correctly detecting a true effect of size %.2f.",
      power * 100, power * 100, effect_size
    )
  } else {
    sprintf(
      "This study has very high power (%.1f%%). While this is good for detecting effects, consider whether this sample size is larger than necessary.",
      power * 100
    )
  }
}


#' Generate Power Recommendation Text
#' @keywords internal
#' @noRd
.generate_power_recommendation <- function(power, n, effect_size, test, type, alpha, k, df, alternative) {
  if (power < 0.8) {
    # Calculate required sample size for 80% power
    required_result <- tryCatch(
      {
        switch(
          test,
          "t.test" = pwr::pwr.t.test(d = effect_size, sig.level = alpha, power = 0.8, type = type, alternative = alternative),
          "anova" = pwr::pwr.anova.test(k = k, f = effect_size, sig.level = alpha, power = 0.8),
          "proportion" = pwr::pwr.p.test(h = effect_size, sig.level = alpha, power = 0.8, alternative = alternative),
          "correlation" = pwr::pwr.r.test(r = effect_size, sig.level = alpha, power = 0.8, alternative = alternative),
          "chisq" = pwr::pwr.chisq.test(w = effect_size, df = df, sig.level = alpha, power = 0.8)
        )
      },
      error = function(e) NULL
    )

    if (!is.null(required_result)) {
      # Extract sample size (field name differs: 'n' for most tests, 'N' for chisq)
      required_n <- if (test == "chisq") {
        ceiling(required_result$N)
      } else {
        ceiling(required_result$n)
      }
      # Determine appropriate unit based on test type
      unit <- if (test %in% c("t.test", "anova")) "per group" else "in total"
      sprintf(
        "To achieve 80%% power, increase sample size from %d to %d %s.",
        n, required_n, unit
      )
    } else {
      "Consider increasing sample size to achieve at least 80% power."
    }
  } else if (power > 0.95) {
    "Consider whether such high power is necessary, as it may lead to detecting trivially small effects."
  } else {
    NULL
  }
}


#' Create Power Curve Plot
#' @keywords internal
#' @noRd
.create_power_curve <- function(n, power, effect_size, alpha, test, type,
                                 alternative, k, df, plot_range, palette) {

  # Determine sample size range for curve
  if (is.null(plot_range)) {
    n_min <- max(5, floor(n * 0.3))
    n_max <- ceiling(n * 2)
    plot_range <- c(n_min, n_max)
  }

  # Generate integer sample sizes (remove duplicates for small ranges)
  n_seq <- unique(round(seq(plot_range[1], plot_range[2], length.out = 100)))

  # Calculate power for each sample size
  power_seq <- sapply(n_seq, function(ni) {
    tryCatch(
      {
        result <- switch(
          test,
          "t.test" = pwr::pwr.t.test(n = ni, d = effect_size, sig.level = alpha,
                                     type = type, alternative = alternative),
          "anova" = pwr::pwr.anova.test(k = k, n = ni, f = effect_size, sig.level = alpha),
          "proportion" = pwr::pwr.p.test(h = effect_size, n = ni, sig.level = alpha,
                                         alternative = alternative),
          "correlation" = pwr::pwr.r.test(r = effect_size, n = ni, sig.level = alpha,
                                          alternative = alternative),
          "chisq" = pwr::pwr.chisq.test(w = effect_size, N = ni, df = df, sig.level = alpha)
        )
        result$power
      },
      error = function(e) NA_real_
    )
  })

  # Get palette colors
  colors <- tryCatch(
    suppressMessages(get_palette(palette, type = "qualitative", n = 2)),
    error = function(e) c("#4DBBD5", "#E64B35")
  )

  # Create plot data
  plot_data <- data.frame(
    n = n_seq,
    power = power_seq
  )

  # Build plot
  p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = n, y = power)) +
    ggplot2::geom_line(color = colors[1], linewidth = 1.2) +
    ggplot2::geom_hline(yintercept = 0.8, linetype = "dashed",
                        color = colors[2], linewidth = 0.8) +
    ggplot2::geom_point(data = data.frame(n = n, power = power),
                        ggplot2::aes(x = n, y = power),
                        color = colors[2], size = 3) +
    ggplot2::labs(
      title = "Statistical Power Curve",
      subtitle = sprintf("Effect size = %.3f, alpha = %.3f", effect_size, alpha),
      x = if (test %in% c("t.test", "anova")) "Sample Size (per group)" else "Sample Size",
      y = "Statistical Power (1 - beta)"
    ) +
    ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.1)) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(size = 11)
    )

  p
}
