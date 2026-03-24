# =============================================================================
# utils_biostat.R — Internal helpers for biostat functions
# =============================================================================


# -----------------------------------------------------------------------------
# Layer 1: Data preparation
# -----------------------------------------------------------------------------

#' Prepare two-group data for t-test / Wilcoxon test
#'
#' Extracts and renames the relevant columns, removes missing values,
#' coerces group to factor, and checks that exactly 2 groups are present.
#'
#' @param data A data frame.
#' @param group_name Column name for grouping variable.
#' @param value_name Column name for numeric values.
#' @param id_name Column name for pairing ID, or NULL.
#' @param paired Logical.
#' @param verbose Logical. Print messages?
#' @return A data frame with columns 'group', 'value' (and 'id' if paired).
#' @keywords internal
#' @noRd
.prepare_ttest_data <- function(data, group_name, value_name, id_name = NULL,
                                 paired = FALSE, verbose = TRUE) {
  # Extract columns and standardise names
  cols <- if (paired) c(group_name, value_name, id_name) else c(group_name, value_name)
  df <- data[, cols, drop = FALSE]
  colnames(df) <- if (paired) c("group", "value", "id") else c("group", "value")

  # Remove missing values
  n_missing <- sum(is.na(df$group) | is.na(df$value))
  if (n_missing > 0) {
    if (verbose) cli::cli_alert_warning("Removed {n_missing} row{?s} with missing values.")
    df <- df[stats::complete.cases(df), ]
  }
  if (nrow(df) == 0) cli::cli_abort("No valid data remaining after removing missing values.")

  # Value must be numeric
  if (!is.numeric(df$value))
    cli::cli_abort("{.field {value_name}} must be numeric.")

  # Coerce group to factor
  if (!is.factor(df$group)) df$group <- as.factor(df$group)

  # Exactly 2 groups required
  group_levels <- levels(df$group)
  if (length(group_levels) != 2)
    cli::cli_abort(c(
      "{.fn quick_ttest} requires exactly 2 groups.",
      "i" = "Found {length(group_levels)} group{?s}: {.val {group_levels}}"
    ))

  df
}


#' Validate paired data structure
#'
#' Checks that each ID appears exactly once per group and in both groups.
#' Sorts data by id and group to ensure proper pairing order.
#'
#' @param df Data frame with columns 'id', 'group', 'value'.
#' @param verbose Logical. Print messages?
#' @return Sorted data frame.
#' @keywords internal
#' @noRd
.validate_paired_ttest_data <- function(df, verbose = TRUE) {
  # Each ID must appear exactly once per group
  id_counts <- df |>
    dplyr::group_by(.data$id, .data$group) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop")

  duplicated_ids <- dplyr::filter(id_counts, .data$n > 1)
  if (nrow(duplicated_ids) > 0)
    cli::cli_abort(c(
      "Each ID must appear exactly once per group for paired tests.",
      "i" = "Found {nrow(duplicated_ids)} ID(s) with duplicates."
    ))

  # Each ID must appear in both groups
  id_group_counts <- df |>
    dplyr::group_by(.data$id) |>
    dplyr::summarise(n_groups = dplyr::n_distinct(.data$group), .groups = "drop")

  unpaired_ids <- dplyr::filter(id_group_counts, .data$n_groups != 2)
  if (nrow(unpaired_ids) > 0)
    cli::cli_abort(c(
      "Each ID must appear in both groups for paired tests.",
      "i" = "Found {nrow(unpaired_ids)} ID(s) missing from one group."
    ))

  dplyr::arrange(df, .data$id, .data$group)
}


# -----------------------------------------------------------------------------
# Layer 2: Descriptive statistics
# -----------------------------------------------------------------------------

#' Compute descriptive statistics for two-group data
#'
#' Returns per-group summary and warns on small or highly unbalanced samples.
#'
#' @param df Data frame with columns 'group' and 'value'.
#' @param group_levels Character vector of the two group levels.
#' @return A data frame with columns: group, n, mean, sd, median, min, max.
#' @keywords internal
#' @noRd
.describe_two_group_data <- function(df, group_levels) {
  desc_stats <- df |>
    dplyr::group_by(.data$group) |>
    dplyr::summarise(
      n      = dplyr::n(),
      mean   = mean(.data$value,   na.rm = TRUE),
      sd     = sd(.data$value,     na.rm = TRUE),
      median = stats::median(.data$value, na.rm = TRUE),
      min    = min(.data$value,    na.rm = TRUE),
      max    = max(.data$value,    na.rm = TRUE),
      .groups = "drop"
    )

  sample_sizes <- stats::setNames(desc_stats$n, group_levels)

  if (any(sample_sizes < 5))
    cli::cli_alert_warning("Very small sample size (n < 5). Results may be unreliable.")

  size_ratio <- max(sample_sizes) / min(sample_sizes)
  if (size_ratio > 3)
    cli::cli_alert_warning(
      "Highly unbalanced samples (ratio {round(size_ratio, 1)}:1). Interpret with caution."
    )

  desc_stats
}


# -----------------------------------------------------------------------------
# Layer 4: Plotting
# -----------------------------------------------------------------------------

#' Create two-group comparison plot
#'
#' @param data Data frame with 'group' and 'value' columns.
#' @param group_levels Character vector of the two group levels.
#' @param test_result htest object from t.test or wilcox.test.
#' @param plot_type One of "boxplot", "violin", "both".
#' @param add_jitter Logical.
#' @param point_size Numeric.
#' @param point_alpha Numeric.
#' @param show_p_value Logical.
#' @param p_label One of "p.signif", "p.format".
#' @param palette Palette name or NULL.
#' @param group_name Original group column name (for axis label).
#' @param value_name Original value column name (for axis label).
#' @return A ggplot object.
#' @keywords internal
#' @noRd
.create_comparison_plot <- function(data, group_levels, test_result,
                                     plot_type, add_jitter, point_size, point_alpha,
                                     show_p_value, p_label, palette,
                                     group_name, value_name) {
  # Resolve palette colors
  colors <- NULL
  if (!is.null(palette)) {
    tryCatch({
      colors <- get_palette(palette, type = "qualitative")
      if (length(colors) < length(group_levels))
        colors <- rep(colors, length.out = length(group_levels))
    }, error = function(e) {
      cli::cli_alert_warning("Could not load palette {.val {palette}}. Using defaults.")
    })
  }

  # Base plot
  p <- ggplot2::ggplot(data, ggplot2::aes(x = .data$group, y = .data$value, fill = .data$group))

  # Geometry layers
  if (plot_type == "boxplot") {
    p <- p + ggplot2::geom_boxplot(alpha = 0.7, outlier.shape = NA)
  } else if (plot_type == "violin") {
    p <- p + ggplot2::geom_violin(alpha = 0.7, trim = FALSE)
  } else {
    p <- p +
      ggplot2::geom_violin(alpha = 0.3, trim = FALSE) +
      ggplot2::geom_boxplot(width = 0.2, alpha = 0.7, outlier.shape = NA)
  }

  if (add_jitter)
    p <- p + ggplot2::geom_jitter(width = 0.1, size = point_size,
                                   alpha = point_alpha, show.legend = FALSE)

  # P-value annotation (requires ggpubr)
  if (show_p_value) {
    if (!requireNamespace("ggpubr", quietly = TRUE)) {
      cli::cli_alert_warning("{.pkg ggpubr} not installed. Skipping p-value annotation.")
    } else {
      y_max      <- max(data[["value"]], na.rm = TRUE)
      y_range    <- y_max - min(data[["value"]], na.rm = TRUE)
      y_position <- y_max + y_range * 0.15
      p_value    <- test_result$p.value

      p_label_text <- if (p_label == "p.signif") {
        dplyr::case_when(
          p_value < 0.001 ~ "***",
          p_value < 0.01  ~ "**",
          p_value < 0.05  ~ "*",
          TRUE            ~ "ns"
        )
      } else {
        if (p_value < 0.001) "p < 0.001" else sprintf("p = %.3f", p_value)
      }

      stat_df <- data.frame(
        group1       = as.character(group_levels[1]),
        group2       = as.character(group_levels[2]),
        p.adj        = p_value,
        p.adj.signif = p_label_text,
        y.position   = y_position,
        stringsAsFactors = FALSE
      )

      p <- p + ggpubr::stat_pvalue_manual(stat_df, label = "p.adj.signif",
                                           size = 4, bracket.size = 0.5, tip.length = 0.02)
    }
  }

  # Colors and theme
  if (!is.null(colors)) p <- p + ggplot2::scale_fill_manual(values = colors)

  # Theme: use ggpubr if available, fallback to theme_bw
  theme_fn <- if (requireNamespace("ggpubr", quietly = TRUE)) {
    ggpubr::theme_pubr(base_size = 12)
  } else {
    ggplot2::theme_bw(base_size = 12)
  }

  p + theme_fn +
    ggplot2::theme(legend.position = "none") +
    ggplot2::labs(x = group_name, y = value_name)
}


# -----------------------------------------------------------------------------
# Layer 3: Test execution helpers
# -----------------------------------------------------------------------------

#' Pivot paired data to wide format for vector-based tests
#'
#' @param df Data frame with columns 'id', 'group', 'value'.
#' @param group_levels Character vector of the two group levels.
#' @return A list with elements `x` and `y` (numeric vectors, matched by id).
#' @keywords internal
#' @noRd
.pivot_paired_wide <- function(df, group_levels) {
  df_wide <- df |>
    dplyr::select("id", "group", "value") |>
    tidyr::pivot_wider(names_from = "group", values_from = "value")

  list(
    x = df_wide[[as.character(group_levels[1])]],
    y = df_wide[[as.character(group_levels[2])]]
  )
}


#' Run t-test (paired or independent)
#'
#' @param df Data frame with columns 'group', 'value' (and 'id' if paired).
#' @param group_levels Character vector of the two group levels.
#' @param paired Logical. Paired test?
#' @param alternative Character. Alternative hypothesis.
#' @param var.equal Logical. Assume equal variances (ignored when paired).
#' @param conf.level Numeric. Confidence level.
#' @return An htest object.
#' @keywords internal
#' @noRd
.run_quick_ttest <- function(df, group_levels, paired, alternative, var.equal, conf.level) {
  if (paired) {
    vecs <- .pivot_paired_wide(df, group_levels)
    stats::t.test(
      x = vecs$x, y = vecs$y,
      paired      = TRUE,
      alternative = alternative,
      conf.level  = conf.level
    )
  } else {
    stats::t.test(
      value ~ group,
      data        = df,
      alternative = alternative,
      var.equal   = var.equal,
      conf.level  = conf.level
    )
  }
}


#' Run Wilcoxon test (paired or independent)
#'
#' @param df Data frame with columns 'group', 'value' (and 'id' if paired).
#' @param group_levels Character vector of the two group levels.
#' @param paired Logical. Paired test?
#' @param alternative Character. Alternative hypothesis.
#' @param conf.level Numeric. Confidence level.
#' @return An htest object.
#' @keywords internal
#' @noRd
.run_quick_wilcox <- function(df, group_levels, paired, alternative, conf.level) {
  if (paired) {
    vecs <- .pivot_paired_wide(df, group_levels)
    stats::wilcox.test(
      x = vecs$x, y = vecs$y,
      paired      = TRUE,
      alternative = alternative,
      conf.int    = TRUE,
      conf.level  = conf.level
    )
  } else {
    stats::wilcox.test(
      value ~ group,
      data        = df,
      alternative = alternative,
      conf.int    = TRUE,
      conf.level  = conf.level
    )
  }
}


# -----------------------------------------------------------------------------
# Layer 2: Pre-test checks
# -----------------------------------------------------------------------------

#' Check normality for two-group comparison
#'
#' For paired tests, checks normality of paired differences.
#' For independent samples, checks normality of each group separately.
#' Uses sample-size-adaptive Shapiro-Wilk thresholds.
#'
#' @param df Data frame with columns 'group', 'value' (and 'id' if paired).
#' @param paired Logical. If TRUE, checks normality of paired differences.
#' @param verbose Logical. Print messages?
#' @return List with `tests`, `sample_sizes`, `recommendation`, `rationale`, `paired`.
#' @keywords internal
#' @noRd
.check_group_normality <- function(df, paired = FALSE, verbose = TRUE) {

  if (paired) {
    groups <- unique(df$group)
    if (length(groups) != 2) cli::cli_abort("Paired test requires exactly 2 groups.")

    df_wide <- df |>
      dplyr::select("id", "group", "value") |>
      tidyr::pivot_wider(names_from = "group", values_from = "value")

    differences <- df_wide[[as.character(groups[1])]] - df_wide[[as.character(groups[2])]]
    n <- length(differences)

    if (n < 3) {
      shapiro_results <- list(differences = list(p.value = NA, n = n,
                              warning = "Sample size too small for Shapiro-Wilk test"))
    } else {
      sw <- stats::shapiro.test(differences)
      shapiro_results <- list(differences = list(p.value = sw$p.value, n = n, statistic = sw$statistic))
    }

    p_val <- shapiro_results$differences$p.value
    if (is.na(p_val)) {
      recommendation <- "parametric"
      rationale <- "Sample size too small for normality testing. Defaulting to paired t-test (use with caution)."
    } else if (n >= 100) {
      recommendation <- "parametric"
      rationale <- "Large sample (n >= 100). CLT ensures paired t-test robustness; Shapiro-Wilk overly sensitive."
    } else if (n >= 30) {
      if (p_val >= 0.01) {
        recommendation <- "parametric"
        rationale <- "Medium sample (30 <= n < 100). Differences reasonably normal (Shapiro p >= 0.01)."
      } else {
        recommendation <- "non-parametric"
        rationale <- "Medium sample (30 <= n < 100). Differences depart from normality (Shapiro p < 0.01)."
        if (verbose) cli::cli_alert_warning("Normality assumption violated (Shapiro p < 0.01). Switching to Wilcoxon.")
      }
    } else {
      if (p_val >= 0.05) {
        recommendation <- "parametric"
        rationale <- "Small sample (n < 30). Differences appear normal (Shapiro p >= 0.05)."
      } else {
        recommendation <- "non-parametric"
        rationale <- "Small sample (n < 30). Differences deviate from normality (Shapiro p < 0.05)."
        if (verbose) cli::cli_alert_warning("Normality assumption violated (Shapiro p < 0.05). Switching to Wilcoxon.")
      }
    }

    return(list(tests = shapiro_results, sample_sizes = c(differences = n),
                recommendation = recommendation, rationale = rationale, paired = TRUE))
  }

  # Independent samples
  groups <- unique(df$group)
  shapiro_results <- list()
  sample_sizes <- numeric(length(groups))
  names(sample_sizes) <- groups

  for (i in seq_along(groups)) {
    grp <- groups[i]
    vals <- df$value[df$group == grp]
    n <- length(vals)
    sample_sizes[i] <- n

    if (n < 3) {
      shapiro_results[[as.character(grp)]] <- list(p.value = NA, n = n,
                                                    warning = "Sample size too small for Shapiro-Wilk test")
    } else {
      sw <- stats::shapiro.test(vals)
      shapiro_results[[as.character(grp)]] <- list(p.value = sw$p.value, n = n, statistic = sw$statistic)
    }
  }

  min_n <- min(sample_sizes)
  p_values <- sapply(shapiro_results, function(x) x$p.value)
  p_values <- p_values[!is.na(p_values)]

  if (length(p_values) == 0) {
    recommendation <- "parametric"
    rationale <- "Sample size too small for normality testing. Defaulting to t-test (use with caution)."
  } else if (min_n >= 100) {
    recommendation <- "parametric"
    rationale <- "Large samples (n >= 100). CLT ensures t-test robustness; Shapiro-Wilk overly sensitive."
  } else if (min_n >= 30) {
    if (all(p_values >= 0.01)) {
      recommendation <- "parametric"
      rationale <- "Medium samples (30 <= n < 100). Data reasonably normal (Shapiro p >= 0.01)."
    } else {
      recommendation <- "non-parametric"
      rationale <- "Medium samples (30 <= n < 100). Data departs from normality (Shapiro p < 0.01)."
      if (verbose) cli::cli_alert_warning("Normality assumption violated (Shapiro p < 0.01). Switching to Wilcoxon.")
    }
  } else {
    if (all(p_values >= 0.05)) {
      recommendation <- "parametric"
      rationale <- "Small samples (n < 30). Data appears normal (Shapiro p >= 0.05)."
    } else {
      recommendation <- "non-parametric"
      rationale <- "Small samples (n < 30). Data deviates from normality (Shapiro p < 0.05)."
      if (verbose) cli::cli_alert_warning("Normality assumption violated (Shapiro p < 0.05). Switching to Wilcoxon.")
    }
  }

  list(tests = shapiro_results, sample_sizes = sample_sizes,
       recommendation = recommendation, rationale = rationale, paired = FALSE)
}


#' Check variance equality using Levene's test
#'
#' @param df Data frame with columns 'group' and 'value'.
#' @param verbose Logical. Print messages?
#' @return List with `test_performed`, `equal_variance`, and optionally `p_value`, `test_object`.
#' @keywords internal
#' @noRd
.check_variance_equality <- function(df, verbose = TRUE) {

  if (!requireNamespace("car", quietly = TRUE)) {
    return(list(test_performed = FALSE, equal_variance = FALSE,
                reason = "car package not available; using Welch's t-test as safer default"))
  }

  levene_test <- car::leveneTest(value ~ group, data = df)
  p_value <- levene_test$`Pr(>F)`[1]
  equal_variance <- p_value >= 0.05

  if (verbose && !equal_variance) {
    p_fmt <- if (p_value < 0.001) "p < 0.001" else sprintf("p = %.3f", p_value)
    cli::cli_alert_warning("Unequal variances (Levene {p_fmt}). Using Welch's t-test.")
  }

  list(test_performed = TRUE, p_value = p_value,
       equal_variance = equal_variance, test_object = levene_test)
}
