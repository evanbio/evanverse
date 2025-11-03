#' Quick t-test with Automatic Visualization
#'
#' Perform t-test or Wilcoxon test (automatically selected based on data
#' characteristics and sample size) with publication-ready visualization.
#' Designed for comparing **two groups only**. For multiple group comparisons,
#' use \code{quick_anova()} instead.
#'
#' @param data A data frame containing the variables.
#' @param group Column name for the grouping variable (must have exactly 2 levels).
#'   Supports both quoted and unquoted names via NSE.
#' @param value Column name for the numeric values to compare.
#'   Supports both quoted and unquoted names via NSE.
#' @param method Character. Test method: "auto" (default), "t.test", or "wilcox.test".
#'   When "auto", the function intelligently selects based on normality and sample size.
#' @param paired Logical. Whether to perform a paired test. Default is \code{FALSE}.
#'   If \code{TRUE}, the \code{id} parameter must be specified to match pairs.
#' @param id Column name for the pairing ID variable (required when \code{paired = TRUE}).
#'   Each unique ID should appear exactly once in each group. Supports both quoted
#'   and unquoted names via NSE.
#' @param alternative Character. Alternative hypothesis: "two.sided" (default),
#'   "less", or "greater".
#' @param var.equal Logical or \code{NULL}. Assume equal variances?
#'   If \code{NULL} (default), automatically tested using Levene's test (ignored for paired tests).
#' @param conf.level Numeric. Confidence level for the interval. Default is 0.95.
#' @param plot_type Character. Type of plot: "boxplot" (default), "violin", or "both".
#' @param add_jitter Logical. Add jittered points to the plot? Default is \code{TRUE}.
#' @param point_size Numeric. Size of the points. Default is 2.
#' @param point_alpha Numeric. Transparency of points (0-1). Default is 0.6.
#' @param show_p_value Logical. Display p-value on the plot? Default is \code{TRUE}.
#' @param p_label Character. P-value label format: "p.signif" (stars, default) or
#'   "p.format" (numeric p-value).
#' @param palette Character. Color palette name from evanverse palettes.
#'   Default is "qual_vivid". Set to \code{NULL} to use ggplot2 defaults.
#' @param verbose Logical. Print diagnostic messages? Default is \code{TRUE}.
#' @param ... Additional arguments (currently unused, reserved for future extensions).
#'
#' @return An object of class \code{quick_ttest_result} containing:
#'   \describe{
#'     \item{plot}{A ggplot object with the comparison visualization}
#'     \item{test_result}{The htest object from \code{t.test()} or \code{wilcox.test()}}
#'     \item{method_used}{Character string of the test method used}
#'     \item{normality_tests}{List of Shapiro-Wilk test results for each group}
#'     \item{variance_test}{Levene's test result (if applicable)}
#'     \item{descriptive_stats}{Data frame with descriptive statistics by group}
#'     \item{auto_decision}{Details about automatic method selection}
#'     \item{timestamp}{POSIXct timestamp of analysis}
#'   }
#'
#' @details
#' \strong{"Quick" means easy to use, not simplified or inaccurate.}
#'
#' This function performs full statistical testing with proper assumption checking:
#'
#' \subsection{Automatic Method Selection (method = "auto")}{
#'   The function uses an intelligent algorithm that considers both normality
#'   and sample size:
#'
#'   \itemize{
#'     \item \strong{Large samples (n ≥ 100 per group)}: Prefers t-test due to
#'       Central Limit Theorem, even if Shapiro-Wilk rejects normality (which
#'       becomes overly sensitive in large samples).
#'     \item \strong{Medium samples (30 ≤ n < 100)}: Uses Shapiro-Wilk test with
#'       a stricter threshold (p < 0.01) to avoid false positives.
#'     \item \strong{Small samples (n < 30)}: Strictly checks normality with
#'       standard threshold (p < 0.05).
#'   }
#'
#'   This approach avoids the common pitfall of automatically switching to
#'   non-parametric tests for large samples where t-test is actually more appropriate.
#' }
#'
#' \subsection{Variance Equality Check}{
#'   When \code{var.equal = NULL} and t-test is selected, Levene's test is
#'   performed. If variances are unequal (p < 0.05), Welch's t-test is used
#'   automatically.
#' }
#'
#' \subsection{Visualization}{
#'   The plot includes:
#'   \itemize{
#'     \item Boxplot, violin plot, or both (based on \code{plot_type})
#'     \item Individual data points (if \code{add_jitter = TRUE})
#'     \item Statistical comparison with p-value
#'     \item Publication-ready styling
#'   }
#' }
#'
#' @section Important Notes:
#'
#' \itemize{
#'   \item \strong{Two groups only}: This function requires exactly 2 levels in
#'     the grouping variable. For multiple group comparisons, use
#'     \code{quick_anova()} instead.
#'   \item \strong{Sample size warnings}: The function will warn if sample sizes
#'     are very small (< 5) or highly unbalanced (ratio > 3:1).
#'   \item \strong{Missing values}: Automatically removed with a warning.
#' }
#'
#' @examples
#' # Example 1: Basic usage with automatic method selection
#' set.seed(123)
#' data <- data.frame(
#'   group = rep(c("Control", "Treatment"), each = 30),
#'   expression = c(rnorm(30, mean = 5), rnorm(30, mean = 6))
#' )
#'
#' result <- quick_ttest(data, group = group, value = expression)
#' print(result)
#'
#' # Example 2: Paired samples (e.g., before/after)
#' paired_data <- data.frame(
#'   patient = rep(1:20, 2),
#'   timepoint = rep(c("Before", "After"), each = 20),
#'   score = c(rnorm(20, 50, 10), rnorm(20, 55, 10))
#' )
#'
#' result <- quick_ttest(paired_data,
#'                       group = timepoint,
#'                       value = score,
#'                       paired = TRUE,
#'                       id = patient)
#'
#' # Example 3: Non-normal data with manual method selection
#' skewed_data <- data.frame(
#'   group = rep(c("A", "B"), each = 25),
#'   value = c(rexp(25, rate = 0.5), rexp(25, rate = 1))
#' )
#'
#' result <- quick_ttest(skewed_data,
#'                       group = group,
#'                       value = value,
#'                       method = "wilcox.test",
#'                       verbose = TRUE)
#'
#' # Example 4: Customize visualization
#' result <- quick_ttest(data,
#'                       group = group,
#'                       value = expression,
#'                       plot_type = "both",
#'                       palette = "qual_balanced",
#'                       p_label = "p.format")
#'
#' # Access components
#' result$plot              # ggplot object
#' result$test_result       # htest object
#' summary(result)          # Detailed summary
#'
#' @export
#' @seealso
#' \code{\link[stats]{t.test}}, \code{\link[stats]{wilcox.test}},
#' \code{\link{quick_anova}} for multiple group comparisons
quick_ttest <- function(data,
                        group,
                        value,
                        method = c("auto", "t.test", "wilcox.test"),
                        paired = FALSE,
                        id,
                        alternative = c("two.sided", "less", "greater"),
                        var.equal = NULL,
                        conf.level = 0.95,
                        plot_type = c("boxplot", "violin", "both"),
                        add_jitter = TRUE,
                        point_size = 2,
                        point_alpha = 0.6,
                        show_p_value = TRUE,
                        p_label = c("p.signif", "p.format"),
                        palette = "qual_vivid",
                        verbose = TRUE,
                        ...) {

  # ===========================================================================
  # 1. Parameter Validation & Setup
  # ===========================================================================

  # Match arguments
  method <- match.arg(method)
  alternative <- match.arg(alternative)
  plot_type <- match.arg(plot_type)
  p_label <- match.arg(p_label)

  # Validate basic inputs
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }

  if (!is.logical(paired) || length(paired) != 1) {
    cli::cli_abort("{.arg paired} must be TRUE or FALSE.")
  }

  # Check id parameter when paired = TRUE
  if (paired && missing(id)) {
    cli::cli_abort("{.arg id} must be specified when {.arg paired} is TRUE.")
  }

  if (!is.logical(verbose) || length(verbose) != 1) {
    cli::cli_abort("{.arg verbose} must be TRUE or FALSE.")
  }

  if (!is.numeric(conf.level) || conf.level <= 0 || conf.level >= 1) {
    cli::cli_abort("{.arg conf.level} must be between 0 and 1.")
  }

  # Capture column names using NSE
  group_col <- rlang::ensym(group)
  value_col <- rlang::ensym(value)
  group_name <- rlang::as_string(group_col)
  value_name <- rlang::as_string(value_col)

  # Capture id column if provided
  if (paired && !missing(id)) {
    id_col <- rlang::ensym(id)
    id_name <- rlang::as_string(id_col)
  } else {
    id_name <- NULL
  }

  # Check columns exist
  if (!group_name %in% names(data)) {
    cli::cli_abort("Column {.field {group_name}} not found in {.arg data}.")
  }
  if (!value_name %in% names(data)) {
    cli::cli_abort("Column {.field {value_name}} not found in {.arg data}.")
  }
  if (paired && !id_name %in% names(data)) {
    cli::cli_abort("Column {.field {id_name}} not found in {.arg data}.")
  }

  # ===========================================================================
  # 2. Data Preparation
  # ===========================================================================

  # Extract relevant columns
  if (paired) {
    df <- data[, c(group_name, value_name, id_name), drop = FALSE]
    colnames(df) <- c("group", "value", "id")
  } else {
    df <- data[, c(group_name, value_name), drop = FALSE]
    colnames(df) <- c("group", "value")
  }

  # Check for missing values
  n_missing <- sum(is.na(df$group) | is.na(df$value))
  if (n_missing > 0) {
    if (verbose) {
      cli::cli_alert_warning(
        "Removed {n_missing} row{?s} with missing values."
      )
    }
    df <- df[complete.cases(df), ]
  }

  if (nrow(df) == 0) {
    cli::cli_abort("No valid data remaining after removing missing values.")
  }

  # Check value is numeric
  if (!is.numeric(df$value)) {
    cli::cli_abort("{.field {value_name}} must be numeric.")
  }

  # Ensure group is factor
  if (!is.factor(df$group)) {
    df$group <- as.factor(df$group)
  }

  # Check for exactly 2 groups
  group_levels <- levels(df$group)
  n_groups <- length(group_levels)

  if (n_groups != 2) {
    cli::cli_abort(
      c(
        "{.fn quick_ttest} requires exactly 2 groups.",
        "i" = "Found {n_groups} group{?s}: {.val {group_levels}}",
        "i" = "For multiple group comparisons, use {.fn quick_anova} instead."
      )
    )
  }

  # Validate and prepare paired data
  if (paired) {
    # Check each ID appears exactly once in each group
    id_counts <- df %>%
      dplyr::group_by(id, group) %>%
      dplyr::summarise(n = dplyr::n(), .groups = "drop")

    # Check for IDs appearing more than once per group
    duplicated_ids <- id_counts %>%
      dplyr::filter(n > 1)

    if (nrow(duplicated_ids) > 0) {
      cli::cli_abort(
        c(
          "Each ID must appear exactly once per group for paired tests.",
          "i" = "Found {nrow(duplicated_ids)} ID(s) with duplicates."
        )
      )
    }

    # Check for IDs not appearing in both groups
    id_group_counts <- df %>%
      dplyr::group_by(id) %>%
      dplyr::summarise(n_groups = dplyr::n_distinct(group), .groups = "drop")

    unpaired_ids <- id_group_counts %>%
      dplyr::filter(n_groups != 2)

    if (nrow(unpaired_ids) > 0) {
      cli::cli_abort(
        c(
          "Each ID must appear in both groups for paired tests.",
          "i" = "Found {nrow(unpaired_ids)} ID(s) missing from one group."
        )
      )
    }

    # Sort data by id and group to ensure proper pairing
    df <- df %>%
      dplyr::arrange(id, group)

    if (verbose) {
      cli::cli_alert_success(
        "Validated {dplyr::n_distinct(df$id)} paired observations."
      )
    }
  }

  # ===========================================================================
  # 3. Descriptive Statistics & Sample Size Checks
  # ===========================================================================

  desc_stats <- df %>%
    dplyr::group_by(group) %>%
    dplyr::summarise(
      n = dplyr::n(),
      mean = mean(value, na.rm = TRUE),
      sd = sd(value, na.rm = TRUE),
      median = median(value, na.rm = TRUE),
      min = min(value, na.rm = TRUE),
      max = max(value, na.rm = TRUE),
      .groups = "drop"
    )

  sample_sizes <- desc_stats$n
  names(sample_sizes) <- group_levels

  # Sample size warnings
  if (any(sample_sizes < 5)) {
    cli::cli_alert_warning(
      "Very small sample size detected (n < 5). Results may be unreliable."
    )
  }

  # Check balance
  size_ratio <- max(sample_sizes) / min(sample_sizes)
  if (size_ratio > 3) {
    cli::cli_alert_warning(
      "Highly unbalanced sample sizes (ratio {round(size_ratio, 1)}:1). Consider caution in interpretation."
    )
  }

  # ===========================================================================
  # 4. Automatic Method Selection
  # ===========================================================================

  auto_decision <- list(
    normality_results = NULL,
    variance_result = NULL,
    method_rationale = NULL
  )

  if (method == "auto") {

    if (verbose) {
      cli::cli_h2("Automatic Method Selection")
    }

    # Check normality (for paired tests, checks differences; for independent, checks each group)
    normality_tests <- .check_normality_smart(df, paired = paired, verbose = verbose)
    auto_decision$normality_results <- normality_tests

    # Decide on method based on normality and sample size
    use_parametric <- normality_tests$recommendation == "parametric"

    if (use_parametric) {
      method_selected <- "t.test"
      auto_decision$method_rationale <- normality_tests$rationale

      # Check variance equality (only for independent samples t-test, not for paired)
      if (!paired && is.null(var.equal)) {
        variance_test <- .check_variance_equality(df, verbose = verbose)
        auto_decision$variance_result <- variance_test
        var.equal <- variance_test$equal_variance
      }

      if (verbose) {
        if (paired) {
          cli::cli_alert_success(
            "Using paired t-test"
          )
        } else if (var.equal) {
          cli::cli_alert_success(
            "Using Student's t-test (equal variances assumed)"
          )
        } else {
          cli::cli_alert_success(
            "Using Welch's t-test (unequal variances)"
          )
        }
      }
    } else {
      method_selected <- "wilcox.test"
      auto_decision$method_rationale <- normality_tests$rationale

      if (verbose) {
        cli::cli_alert_success("Using Wilcoxon rank-sum test (non-parametric)")
      }
    }

  } else {
    # Manual method selection
    method_selected <- method

    if (verbose) {
      cli::cli_alert_info("Using manually specified method: {method_selected}")
    }

    # Still check variance for t-test if var.equal is NULL
    if (method_selected == "t.test" && is.null(var.equal)) {
      variance_test <- .check_variance_equality(df, verbose = verbose)
      auto_decision$variance_result <- variance_test
      var.equal <- variance_test$equal_variance
    }
  }

  # Default var.equal if still NULL
  if (is.null(var.equal)) {
    var.equal <- TRUE
  }

  # ===========================================================================
  # 5. Perform Statistical Test
  # ===========================================================================

  if (verbose) {
    cli::cli_h2("Statistical Test")
  }

  if (method_selected == "t.test") {
    if (paired) {
      # For paired tests, use vector interface with ID matching
      group_levels <- levels(df$group)

      # Match pairs using ID (data is already sorted by id and group)
      df_wide <- df %>%
        dplyr::select(id, group, value) %>%
        tidyr::pivot_wider(names_from = group, values_from = value)

      x <- df_wide[[as.character(group_levels[1])]]
      y <- df_wide[[as.character(group_levels[2])]]

      test_result <- stats::t.test(
        x = x,
        y = y,
        paired = TRUE,
        alternative = alternative,
        conf.level = conf.level
      )
    } else {
      # For independent samples, use formula interface (no paired parameter)
      test_result <- stats::t.test(
        value ~ group,
        data = df,
        alternative = alternative,
        var.equal = var.equal,
        conf.level = conf.level
      )
    }
  } else {
    if (paired) {
      # For paired tests, use vector interface with ID matching
      group_levels <- levels(df$group)

      # Match pairs using ID (data is already sorted by id and group)
      df_wide <- df %>%
        dplyr::select(id, group, value) %>%
        tidyr::pivot_wider(names_from = group, values_from = value)

      x <- df_wide[[as.character(group_levels[1])]]
      y <- df_wide[[as.character(group_levels[2])]]

      test_result <- stats::wilcox.test(
        x = x,
        y = y,
        paired = TRUE,
        alternative = alternative,
        conf.int = TRUE,
        conf.level = conf.level
      )
    } else {
      # For independent samples, use formula interface (no paired parameter)
      test_result <- stats::wilcox.test(
        value ~ group,
        data = df,
        alternative = alternative,
        conf.int = TRUE,
        conf.level = conf.level
      )
    }
  }

  if (verbose) {
    if (test_result$p.value < 0.001) {
      p_display <- "p < 0.001"
    } else {
      p_display <- sprintf("p = %.4f", test_result$p.value)
    }

    if (test_result$p.value < 0.05) {
      cli::cli_alert_success(
        "Significant difference detected ({p_display})"
      )
    } else {
      cli::cli_alert_info(
        "No significant difference ({p_display})"
      )
    }
  }

  # ===========================================================================
  # 6. Create Visualization
  # ===========================================================================

  if (verbose) {
    cli::cli_h2("Creating Visualization")
  }

  plot_obj <- .create_comparison_plot(
    data = df,
    group_levels = group_levels,
    test_result = test_result,
    method_used = method_selected,
    plot_type = plot_type,
    add_jitter = add_jitter,
    point_size = point_size,
    point_alpha = point_alpha,
    show_p_value = show_p_value,
    p_label = p_label,
    palette = palette,
    group_name = group_name,
    value_name = value_name
  )

  # ===========================================================================
  # 7. Construct Return Object
  # ===========================================================================

  result <- structure(
    list(
      plot = plot_obj,
      test_result = test_result,
      method_used = method_selected,
      normality_tests = auto_decision$normality_results,
      variance_test = auto_decision$variance_result,
      descriptive_stats = desc_stats,
      auto_decision = auto_decision,
      parameters = list(
        paired = paired,
        alternative = alternative,
        var.equal = var.equal,
        conf.level = conf.level
      ),
      timestamp = Sys.time()
    ),
    class = "quick_ttest_result"
  )

  if (verbose) {
    cli::cli_alert_success("Analysis complete!")
  }

  return(result)
}


# =============================================================================
# Internal Helper Functions
# =============================================================================

#' Smart Normality Checking with Sample Size Consideration
#'
#' For paired tests, checks normality of DIFFERENCES (not individual groups).
#' For independent samples, checks normality of each group separately.
#'
#' @param df Data frame with columns 'group' and 'value' (and 'id' if paired = TRUE)
#' @param paired Logical. If TRUE, checks normality of paired differences
#' @param verbose Print messages?
#' @return List with normality test results and recommendation
#' @keywords internal
#' @noRd
.check_normality_smart <- function(df, paired = FALSE, verbose = TRUE) {

  # For paired tests, check normality of DIFFERENCES, not individual groups
  if (paired) {
    if (verbose) {
      cli::cli_alert_info("Checking normality of paired differences...")
    }

    groups <- unique(df$group)
    if (length(groups) != 2) {
      cli::cli_abort("Paired test requires exactly 2 groups.")
    }

    # Calculate differences using ID matching (safe approach)
    # Data is already sorted by id and group from validation step
    df_wide <- df %>%
      dplyr::select(id, group, value) %>%
      tidyr::pivot_wider(names_from = group, values_from = value)

    group1_col <- as.character(groups[1])
    group2_col <- as.character(groups[2])

    differences <- df_wide[[group1_col]] - df_wide[[group2_col]]
    n <- length(differences)

    # Shapiro-Wilk test on differences
    if (n < 3) {
      shapiro_results <- list(
        differences = list(
          p.value = NA,
          n = n,
          warning = "Sample size too small for Shapiro-Wilk test"
        )
      )
    } else {
      shapiro_test <- stats::shapiro.test(differences)
      shapiro_results <- list(
        differences = list(
          p.value = shapiro_test$p.value,
          n = n,
          statistic = shapiro_test$statistic
        )
      )
    }

    # Decision logic for paired data
    if (is.na(shapiro_results$differences$p.value)) {
      recommendation <- "parametric"
      rationale <- "Sample size too small for normality testing. Defaulting to paired t-test (use with caution)."

    } else if (n >= 100) {
      recommendation <- "parametric"
      rationale <- paste0(
        "Large sample size (n >= 100). Central Limit Theorem ensures paired t-test robustness. ",
        "Shapiro-Wilk test is overly sensitive in large samples."
      )

      if (verbose) {
        cli::cli_alert_info(
          "Large sample detected (n = {n}). Using paired t-test (CLT applies)."
        )
      }

    } else if (n >= 30) {
      p_val <- shapiro_results$differences$p.value
      if (p_val >= 0.01) {
        recommendation <- "parametric"
        rationale <- paste0(
          "Medium sample size (30 <= n < 100). Differences appear reasonably normal ",
          "(Shapiro p >= 0.01). Using paired t-test."
        )

        if (verbose) {
          cli::cli_alert_success(
            "Differences appear reasonably normal (using p < 0.01 threshold for medium samples)."
          )
        }
      } else {
        recommendation <- "non-parametric"
        rationale <- paste0(
          "Medium sample size (30 <= n < 100). Differences show significant departure from normality ",
          "(Shapiro p < 0.01). Using Wilcoxon signed-rank test."
        )

        if (verbose) {
          cli::cli_alert_warning(
            "Differences deviate from normality (p < 0.01). Switching to non-parametric test."
          )
        }
      }

    } else {
      p_val <- shapiro_results$differences$p.value
      if (p_val >= 0.05) {
        recommendation <- "parametric"
        rationale <- paste0(
          "Small sample size (n < 30). Differences appear normal (Shapiro p >= 0.05). ",
          "Using paired t-test."
        )

        if (verbose) {
          cli::cli_alert_success(
            "Differences appear normal (Shapiro-Wilk p >= 0.05)."
          )
        }
      } else {
        recommendation <- "non-parametric"
        rationale <- paste0(
          "Small sample size (n < 30). Differences deviate from normality (Shapiro p < 0.05). ",
          "Using Wilcoxon signed-rank test."
        )

        if (verbose) {
          cli::cli_alert_warning(
            "Differences not normally distributed (Shapiro p < 0.05). Using non-parametric test."
          )
        }
      }
    }

    # Print detailed results if verbose
    if (verbose && !is.na(shapiro_results$differences$p.value)) {
      p_val <- shapiro_results$differences$p.value
      p_fmt <- if (p_val < 0.001) "p < 0.001" else sprintf("p = %.3f", p_val)
      cli::cli_text("  Differences: n = {n}, {p_fmt}")
    }

    return(list(
      tests = shapiro_results,
      sample_sizes = c(differences = n),
      recommendation = recommendation,
      rationale = rationale,
      paired = TRUE
    ))
  }

  # For independent samples, check normality of each group separately
  if (verbose) {
    cli::cli_alert_info("Checking normality for each group...")
  }

  groups <- unique(df$group)
  shapiro_results <- list()
  sample_sizes <- numeric(length(groups))
  names(sample_sizes) <- groups

  for (i in seq_along(groups)) {
    grp <- groups[i]
    subset_data <- df$value[df$group == grp]
    n <- length(subset_data)
    sample_sizes[i] <- n

    # Shapiro-Wilk test (requires n >= 3)
    if (n < 3) {
      shapiro_results[[as.character(grp)]] <- list(
        p.value = NA,
        n = n,
        warning = "Sample size too small for Shapiro-Wilk test"
      )
    } else {
      shapiro_test <- stats::shapiro.test(subset_data)
      shapiro_results[[as.character(grp)]] <- list(
        p.value = shapiro_test$p.value,
        n = n,
        statistic = shapiro_test$statistic
      )
    }
  }

  # Decision logic based on sample size
  min_n <- min(sample_sizes)
  max_n <- max(sample_sizes)

  # Extract p-values
  p_values <- sapply(shapiro_results, function(x) x$p.value)
  p_values <- p_values[!is.na(p_values)]

  if (length(p_values) == 0) {
    # Can't perform Shapiro test
    recommendation <- "parametric"  # Default to t-test for tiny samples
    rationale <- "Sample size too small for normality testing. Defaulting to t-test (use with caution)."

  } else if (min_n >= 100) {
    # Large sample: CLT applies, prefer t-test
    recommendation <- "parametric"
    rationale <- paste0(
      "Large sample size (n >= 100). Central Limit Theorem ensures t-test robustness. ",
      "Shapiro-Wilk test is overly sensitive in large samples."
    )

    if (verbose) {
      cli::cli_alert_info(
        "Large samples detected (n = {min_n}-{max_n}). Using t-test (CLT applies)."
      )
    }

  } else if (min_n >= 30) {
    # Medium sample: use stricter threshold (p < 0.01)
    if (all(p_values >= 0.01)) {
      recommendation <- "parametric"
      rationale <- paste0(
        "Medium sample size (30 <= n < 100). Data appears reasonably normal ",
        "(Shapiro p >= 0.01). Using t-test."
      )

      if (verbose) {
        cli::cli_alert_success(
          "Data appears reasonably normal (using p < 0.01 threshold for medium samples)."
        )
      }
    } else {
      recommendation <- "non-parametric"
      rationale <- paste0(
        "Medium sample size (30 <= n < 100). Data shows significant departure from normality ",
        "(Shapiro p < 0.01). Using Wilcoxon test."
      )

      if (verbose) {
        cli::cli_alert_warning(
          "Data deviates from normality (p < 0.01). Switching to non-parametric test."
        )
      }
    }

  } else {
    # Small sample: use standard threshold (p < 0.05)
    if (all(p_values >= 0.05)) {
      recommendation <- "parametric"
      rationale <- paste0(
        "Small sample size (n < 30). Data appears normal (Shapiro p >= 0.05). ",
        "Using t-test."
      )

      if (verbose) {
        cli::cli_alert_success(
          "Data appears normal (Shapiro-Wilk p >= 0.05)."
        )
      }
    } else {
      recommendation <- "non-parametric"
      rationale <- paste0(
        "Small sample size (n < 30). Data deviates from normality (Shapiro p < 0.05). ",
        "Using Wilcoxon test."
      )

      if (verbose) {
        cli::cli_alert_warning(
          "Data not normally distributed (Shapiro p < 0.05). Using non-parametric test."
        )
      }
    }
  }

  # Print detailed results if verbose
  if (verbose && length(p_values) > 0) {
    for (grp in names(shapiro_results)) {
      res <- shapiro_results[[grp]]
      if (!is.na(res$p.value)) {
        p_fmt <- if (res$p.value < 0.001) "p < 0.001" else sprintf("p = %.3f", res$p.value)
        cli::cli_text("  {grp}: n = {res$n}, {p_fmt}")
      }
    }
  }

  return(list(
    tests = shapiro_results,
    sample_sizes = sample_sizes,
    recommendation = recommendation,
    rationale = rationale,
    paired = FALSE
  ))
}


#' Check Variance Equality using Levene's Test
#'
#' @param df Data frame with columns 'group' and 'value'
#' @param verbose Print messages?
#' @return List with test result and recommendation
#' @keywords internal
#' @noRd
.check_variance_equality <- function(df, verbose = TRUE) {

  # Check if car package is available for Levene's test
  if (!requireNamespace("car", quietly = TRUE)) {
    if (verbose) {
      cli::cli_alert_info(
        "Package {.pkg car} not available. Defaulting to Welch's t-test (safer and more robust)."
      )
    }
    return(list(
      test_performed = FALSE,
      equal_variance = FALSE,
      reason = "car package not available; using Welch's t-test as safer default"
    ))
  }

  levene_test <- car::leveneTest(value ~ group, data = df)
  p_value <- levene_test$`Pr(>F)`[1]

  equal_variance <- p_value >= 0.05

  if (verbose) {
    p_fmt <- if (p_value < 0.001) "p < 0.001" else sprintf("p = %.3f", p_value)

    if (equal_variance) {
      cli::cli_alert_success(
        "Variances appear equal (Levene's test, {p_fmt})"
      )
    } else {
      cli::cli_alert_warning(
        "Variances are unequal (Levene's test, {p_fmt}). Will use Welch's t-test."
      )
    }
  }

  return(list(
    test_performed = TRUE,
    p_value = p_value,
    equal_variance = equal_variance,
    test_object = levene_test
  ))
}


#' Create Comparison Plot
#'
#' @param data Data frame with 'group' and 'value' columns
#' @param group_levels Character vector of group levels
#' @param test_result htest object from t.test or wilcox.test
#' @param method_used Character string of method used
#' @param plot_type Type of plot
#' @param add_jitter Add jittered points?
#' @param point_size Size of points
#' @param point_alpha Transparency of points
#' @param show_p_value Show p-value on plot?
#' @param p_label P-value label format
#' @param palette Palette name or NULL
#' @param group_name Original group column name
#' @param value_name Original value column name
#' @return ggplot object
#' @keywords internal
#' @noRd
.create_comparison_plot <- function(data, group_levels, test_result, method_used,
                                     plot_type, add_jitter, point_size, point_alpha,
                                     show_p_value, p_label, palette,
                                     group_name, value_name) {

  # Get colors
  if (!is.null(palette)) {
    tryCatch({
      colors <- get_palette(palette, type = "qualitative")
      if (length(colors) < length(group_levels)) {
        colors <- rep(colors, length.out = length(group_levels))
      }
    }, error = function(e) {
      cli::cli_alert_warning("Could not load palette {.val {palette}}. Using defaults.")
      colors <- NULL
    })
  } else {
    colors <- NULL
  }

  # Base plot
  p <- ggplot2::ggplot(data, ggplot2::aes(x = group, y = value, fill = group))

  # Add plot layers based on type
  if (plot_type == "boxplot") {
    p <- p + ggplot2::geom_boxplot(alpha = 0.7, outlier.shape = NA)
  } else if (plot_type == "violin") {
    p <- p + ggplot2::geom_violin(alpha = 0.7, trim = FALSE)
  } else if (plot_type == "both") {
    p <- p +
      ggplot2::geom_violin(alpha = 0.3, trim = FALSE) +
      ggplot2::geom_boxplot(width = 0.2, alpha = 0.7, outlier.shape = NA)
  }

  # Add jittered points
  if (add_jitter) {
    p <- p + ggplot2::geom_jitter(
      width = 0.1,
      size = point_size,
      alpha = point_alpha,
      show.legend = FALSE
    )
  }

  # Add statistical comparison using the already-computed p-value
  if (show_p_value) {
    # Calculate y position for p-value label (slightly above the highest data point)
    y_max <- max(data$value, na.rm = TRUE)
    y_min <- min(data$value, na.rm = TRUE)
    y_range <- y_max - y_min
    y_position <- y_max + y_range * 0.15

    # Format p-value based on p_label
    p_value <- test_result$p.value

    if (p_label == "p.signif") {
      # Convert p-value to significance stars
      p_label_text <- dplyr::case_when(
        p_value < 0.001 ~ "***",
        p_value < 0.01 ~ "**",
        p_value < 0.05 ~ "*",
        TRUE ~ "ns"
      )
    } else {
      # Format as numeric p-value
      if (p_value < 0.001) {
        p_label_text <- "p < 0.001"
      } else {
        p_label_text <- sprintf("p = %.3f", p_value)
      }
    }

    # Prepare data frame for stat_pvalue_manual
    stat_df <- data.frame(
      group1 = as.character(group_levels[1]),
      group2 = as.character(group_levels[2]),
      p.adj = p_value,
      p.adj.signif = p_label_text,
      y.position = y_position,
      stringsAsFactors = FALSE
    )

    # Add p-value annotation using the already-computed result
    p <- p + ggpubr::stat_pvalue_manual(
      stat_df,
      label = "p.adj.signif",  # Always use the pre-formatted label
      size = 4,
      bracket.size = 0.5,
      tip.length = 0.02
    )
  }

  # Apply colors
  if (!is.null(colors)) {
    p <- p + ggplot2::scale_fill_manual(values = colors)
  }

  # Theme
  p <- p +
    ggpubr::theme_pubr(base_size = 12) +
    ggplot2::theme(
      legend.position = "none"
    ) +
    ggplot2::labs(
      x = group_name,
      y = value_name
    )

  return(p)
}


# =============================================================================
# S3 Methods for quick_ttest_result
# =============================================================================

#' Print method for quick_ttest_result
#' @param x A quick_ttest_result object
#' @param ... Additional arguments (unused)
#' @export
print.quick_ttest_result <- function(x, ...) {
  # Display the plot
  print(x$plot)

  # Print statistical summary
  cat("\n")
  cli::cli_h2("Quick t-test Results")

  cli::cli_text("")
  cli::cli_alert_info("Method: {x$method_used}")

  # Format p-value
  if (x$test_result$p.value < 0.001) {
    p_display <- "p < 0.001"
  } else {
    p_display <- sprintf("p = %.4f", x$test_result$p.value)
  }

  # Statistical result
  if (x$test_result$p.value < 0.05) {
    cli::cli_alert_success("Significant difference ({p_display})")
  } else {
    cli::cli_alert_info("No significant difference ({p_display})")
  }

  # Descriptive stats
  cli::cli_text("")
  cli::cli_h3("Descriptive Statistics")
  print(x$descriptive_stats)

  # Additional info
  cli::cli_text("")
  cli::cli_text("Use {.fn summary} for detailed results.")

  invisible(x)
}


#' Summary method for quick_ttest_result
#' @param object A quick_ttest_result object
#' @param ... Additional arguments (unused)
#' @export
summary.quick_ttest_result <- function(object, ...) {
  cat("\n")
  cli::cli_h2("Detailed Quick t-test Summary")
  cat("\n")

  # Test information
  cli::cli_h3("Test Method")
  cli::cli_text("Method used: {object$method_used}")
  cli::cli_text("Paired: {object$parameters$paired}")
  cli::cli_text("Alternative: {object$parameters$alternative}")

  if (object$method_used == "t.test") {
    cli::cli_text("Equal variance: {object$parameters$var.equal}")
  }

  cat("\n")

  # Statistical result
  cli::cli_h3("Test Result")
  print(object$test_result)
  cat("\n")

  # Descriptive stats
  cli::cli_h3("Descriptive Statistics")
  print(object$descriptive_stats)
  cat("\n")

  # Normality tests (if performed)
  if (!is.null(object$normality_tests)) {
    cli::cli_h3("Normality Tests (Shapiro-Wilk)")
    for (grp in names(object$normality_tests$tests)) {
      res <- object$normality_tests$tests[[grp]]
      if (!is.na(res$p.value)) {
        p_fmt <- if (res$p.value < 0.001) "p < 0.001" else sprintf("p = %.4f", res$p.value)
        cli::cli_text("  {grp}: n = {res$n}, {p_fmt}")
      }
    }
    cli::cli_text("")
    cli::cli_alert_info("Decision: {object$normality_tests$rationale}")
    cat("\n")
  }

  # Variance test (if performed)
  if (!is.null(object$variance_test) && object$variance_test$test_performed) {
    cli::cli_h3("Variance Equality Test (Levene)")
    p_fmt <- if (object$variance_test$p_value < 0.001) {
      "p < 0.001"
    } else {
      sprintf("p = %.4f", object$variance_test$p_value)
    }
    cli::cli_text("Levene's test: {p_fmt}")
    cli::cli_text("Equal variances: {object$variance_test$equal_variance}")
    cat("\n")
  }

  # Timestamp
  cli::cli_text("Analysis performed: {format(object$timestamp, '%Y-%m-%d %H:%M:%S')}")

  invisible(object)
}
