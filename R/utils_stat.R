# =============================================================================
# utils_stat.R — Internal statistical helpers shared across stat_* functions
# =============================================================================


#' Central dispatch for pwr:: calls
#'
#' Pass \code{power = NULL} to solve for power, or \code{n = NULL} to solve
#' for sample size. Used by \code{stat_power()}, \code{stat_n()}, and
#' internal recommendation / curve helpers.
#'
#' @keywords internal
#' @noRd
.pwr_compute <- function(n, power, effect_size, test, alternative, alpha, k, df) {
  pwr_type <- switch(test,
    "t_two"    = "two.sample",
    "t_one"    = "one.sample",
    "t_paired" = "paired",
    NULL
  )

  switch(test,
    "t_two" = ,
    "t_one" = ,
    "t_paired" = {
      pwr::pwr.t.test(
        n = n, d = effect_size, sig.level = alpha,
        power = power, type = pwr_type, alternative = alternative
      )
    },
    "anova" = {
      pwr::pwr.anova.test(
        k = k, n = n, f = effect_size, sig.level = alpha, power = power
      )
    },
    "proportion" = {
      pwr::pwr.p.test(
        h = effect_size, n = n, sig.level = alpha,
        power = power, alternative = alternative
      )
    },
    "correlation" = {
      pwr::pwr.r.test(
        r = effect_size, n = n, sig.level = alpha,
        power = power, alternative = alternative
      )
    },
    "chisq" = {
      pwr::pwr.chisq.test(
        w = effect_size, N = n, df = df, sig.level = alpha, power = power
      )
    }
  )
}


# =============================================================================
# Shared n helpers
# =============================================================================

#' Number of groups for a given test (used to derive total n)
#' @keywords internal
#' @noRd
.n_groups <- function(test, k = NULL) {
  switch(test,
    "t_two" = 2L,
    "anova" = as.integer(k),
    1L
  )
}


#' Display unit for n (per group / pairs / total)
#' @keywords internal
#' @noRd
.n_unit <- function(test) {
  switch(test,
    "t_two"    = "per group",
    "anova"    = "per group",
    "t_paired" = "pairs",
    "total"
  )
}


# =============================================================================
# stat_power() helpers
# =============================================================================

#' Plain-text interpretation of a power value
#' @keywords internal
#' @noRd
.power_interp <- function(power, effect_size) {
  if (power < 0.5) {
    sprintf(
      "With only %.1f%% power, the study is unlikely to detect a true effect of size %.2f.",
      power * 100, effect_size
    )
  } else if (power < 0.8) {
    sprintf(
      "Power of %.1f%% falls below the conventional 80%% threshold for an effect size of %.2f.",
      power * 100, effect_size
    )
  } else if (power < 0.95) {
    sprintf(
      "Power of %.1f%% is good \u2014 %.1f%% probability of detecting a true effect of size %.2f.",
      power * 100, power * 100, effect_size
    )
  } else {
    sprintf(
      "Power of %.1f%% is very high. Verify the sample size isn't larger than necessary.",
      power * 100
    )
  }
}


#' Actionable recommendation based on power level
#'
#' Returns \code{NULL} when power is between 0.8 and 0.95 (adequate range).
#'
#' @keywords internal
#' @noRd
.power_recommend <- function(power, n, effect_size, test, alternative, alpha, k, df) {
  if (power >= 0.8 && power <= 0.95) return(NULL)

  if (power < 0.8) {
    req <- tryCatch(
      .pwr_compute(
        n = NULL, power = 0.8, effect_size = effect_size, test = test,
        alternative = alternative, alpha = alpha, k = k, df = df
      ),
      error = function(e) NULL
    )
    if (is.null(req))
      return("Consider increasing sample size to reach 80% power.")

    # Reason: chisq uses capital N; all other pwr functions use lowercase n
    req_n <- ceiling(if (test == "chisq") req$N else req$n)
    sprintf(
      "To reach 80%% power, increase n from %d to %d %s.",
      n, req_n, .n_unit(test)
    )
  } else {
    "Power > 95%: consider whether such a large sample is necessary \u2014 trivially small effects may reach significance."
  }
}


#' Build a power curve (power ~ n) ggplot2 object
#' @keywords internal
#' @noRd
.power_curve <- function(n, power, effect_size, alpha, test, alternative,
                         k, df, plot_range = NULL) {

  n_min <- if (is.null(plot_range)) max(5L, floor(n * 0.3)) else plot_range[1]
  n_max <- if (is.null(plot_range)) ceiling(n * 2)           else plot_range[2]
  n_seq <- unique(round(seq(n_min, n_max, length.out = 100)))

  power_seq <- vapply(n_seq, function(ni) {
    tryCatch(
      .pwr_compute(
        n = ni, power = NULL, effect_size = effect_size, test = test,
        alternative = alternative, alpha = alpha, k = k, df = df
      )$power,
      error = function(e) NA_real_
    )
  }, numeric(1L))

  col_line   <- "#3B82C4"
  col_accent <- "#E05C4B"

  ggplot2::ggplot(
    data.frame(n = n_seq, power = power_seq),
    ggplot2::aes(x = n, y = power)
  ) +
    ggplot2::geom_line(color = col_line, linewidth = 1.2) +
    ggplot2::geom_hline(
      yintercept = 0.8, linetype = "dashed",
      color = col_accent, linewidth = 0.8
    ) +
    ggplot2::geom_point(
      data = data.frame(n = n, power = power),
      ggplot2::aes(x = n, y = power),
      color = col_accent, size = 3.5
    ) +
    ggplot2::labs(
      title    = "Statistical Power Curve",
      subtitle = sprintf("Effect size = %.3f,  alpha = %.3f", effect_size, alpha),
      x        = sprintf("Sample size (%s)", .n_unit(test)),
      y        = "Power (1 \u2212 \u03b2)"
    ) +
    ggplot2::scale_y_continuous(limits = c(0, 1), breaks = seq(0, 1, 0.1)) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(size = 11)
    )
}


# =============================================================================
# stat_n() helpers
# =============================================================================

#' Plain-text interpretation of a sample size result
#' @keywords internal
#' @noRd
.n_interp <- function(n, power, effect_size, test, k = NULL) {
  groups <- .n_groups(test, k)
  if (groups > 1L) {
    sprintf(
      "To detect an effect of size %.2f with %.0f%% power, recruit %d subjects %s (%d total).",
      effect_size, power * 100, n, .n_unit(test), n * groups
    )
  } else {
    unit <- if (test == "t_paired") "pairs" else "subjects in total"
    sprintf(
      "To detect an effect of size %.2f with %.0f%% power, recruit %d %s.",
      effect_size, power * 100, n, unit
    )
  }
}


#' Practical recruitment recommendation based on required n
#' @keywords internal
#' @noRd
.n_recommend <- function(n) {
  if (n < 10) {
    "Very small sample \u2014 ensure measurement instruments have high reliability."
  } else if (n < 30) {
    "Recruit 10\u201315% extra to account for potential dropout or exclusions."
  } else if (n < 100) {
    "Recruit 10\u201320% extra to account for dropout, missing data, or protocol violations."
  } else {
    "For large studies, budget 15\u201320% extra for dropout and consider interim analyses."
  }
}


#' Build a sample size curve (n ~ effect size) ggplot2 object
#' @keywords internal
#' @noRd
.n_curve <- function(n, power, effect_size, alpha, test, alternative,
                     k, df, plot_range = NULL) {

  # Auto range: bracket the target effect size, respect test-specific ceilings
  if (is.null(plot_range)) {
    es_ceil <- switch(test, "correlation" = 0.95, "anova" = 1.0, "chisq" = 1.0, 2.0)
    plot_range <- c(
      max(0.05, effect_size * 0.3),
      min(effect_size * 2.5, es_ceil)
    )
  }

  es_seq <- seq(plot_range[1], plot_range[2], length.out = 100)

  n_seq <- vapply(es_seq, function(es) {
    tryCatch({
      res <- .pwr_compute(
        n = NULL, power = power, effect_size = es, test = test,
        alternative = alternative, alpha = alpha, k = k, df = df
      )
      ceiling(if (test == "chisq") res$N else res$n)
    }, error = function(e) NA_real_)
  }, numeric(1L))

  # Reference lines for Cohen conventions within the plot range
  refs <- .effect_size_refs(test)
  refs <- refs[refs >= plot_range[1] & refs <= plot_range[2]]

  col_line   <- "#3B82C4"
  col_accent <- "#E05C4B"
  col_ref    <- "gray50"

  p <- ggplot2::ggplot(
    data.frame(effect_size = es_seq, n = n_seq),
    ggplot2::aes(x = effect_size, y = n)
  ) +
    ggplot2::geom_line(color = col_line, linewidth = 1.2) +
    ggplot2::geom_point(
      data = data.frame(effect_size = effect_size, n = n),
      ggplot2::aes(x = effect_size, y = n),
      color = col_accent, size = 3.5
    ) +
    ggplot2::labs(
      title    = "Required Sample Size Curve",
      subtitle = sprintf("Target power = %.0f%%,  alpha = %.3f", power * 100, alpha),
      x        = "Effect size",
      y        = sprintf("Required n (%s)", .n_unit(test))
    ) +
    ggplot2::theme_minimal(base_size = 12) +
    ggplot2::theme(
      plot.title    = ggplot2::element_text(face = "bold", size = 14),
      plot.subtitle = ggplot2::element_text(size = 11)
    )

  if (length(refs) > 0) {
    p <- p + ggplot2::geom_vline(
      xintercept = refs, linetype = "dashed",
      linewidth = 0.6, alpha = 0.6, color = col_ref
    )
  }

  p
}


# =============================================================================
# Shared display helpers
# =============================================================================

#' Cohen effect size reference values by test type
#' @keywords internal
#' @noRd
.effect_size_refs <- function(test) {
  switch(test,
    "t_two"      = ,
    "t_one"      = ,
    "t_paired"   = c(small = 0.2,  medium = 0.5,  large = 0.8),
    "anova"      = c(small = 0.1,  medium = 0.25, large = 0.4),
    "proportion" = c(small = 0.2,  medium = 0.5,  large = 0.8),
    "correlation"= c(small = 0.1,  medium = 0.3,  large = 0.5),
    "chisq"      = c(small = 0.1,  medium = 0.3,  large = 0.5)
  )
}


#' Human-readable label for a test type
#' @keywords internal
#' @noRd
.test_label <- function(test, k = NULL, df = NULL) {
  switch(test,
    "t_two"      = "Two-sample t-test",
    "t_one"      = "One-sample t-test",
    "t_paired"   = "Paired t-test",
    "anova"      = sprintf("ANOVA (%d groups)", k),
    "proportion" = "Proportion test (one-sample)",
    "correlation"= "Correlation test",
    "chisq"      = sprintf("Chi-square test (df = %d)", df)
  )
}


#' Human-readable sample size label (value + unit)
#' @keywords internal
#' @noRd
.n_label <- function(n, test) {
  sprintf("%d %s", n, .n_unit(test))
}


# =============================================================================
# Biostat helpers (quick_ttest / quick_anova / quick_chisq / quick_cor)
# =============================================================================


# -----------------------------------------------------------------------------
# Data preparation
# -----------------------------------------------------------------------------

#' Prepare two-group data for t-test / Wilcoxon test
#'
#' Extracts and renames relevant columns, removes missing values, coerces
#' group to factor, and checks that exactly 2 groups are present.
#'
#' @param data A data frame.
#' @param group_name Column name for grouping variable.
#' @param value_name Column name for numeric values.
#' @param id_name Column name for pairing ID, or NULL.
#' @param paired Logical.
#' @return A data frame with columns \code{group}, \code{value}
#'   (and \code{id} if paired).
#' @keywords internal
#' @noRd
.prepare_ttest_data <- function(data, group_name, value_name,
                                 id_name = NULL, paired = FALSE) {
  cols <- if (paired) c(group_name, value_name, id_name) else c(group_name, value_name)
  df   <- data[, cols, drop = FALSE]
  colnames(df) <- if (paired) c("group", "value", "id") else c("group", "value")

  n_missing <- sum(!stats::complete.cases(df))
  if (n_missing > 0) {
    cli::cli_alert_warning("Removed {n_missing} row{?s} with missing values.")
    df <- df[stats::complete.cases(df), ]
  }
  if (nrow(df) == 0)
    cli::cli_abort("No valid data remaining after removing missing values.")

  if (!is.numeric(df$value))
    cli::cli_abort("{.field {value_name}} must be numeric.")

  if (!is.factor(df$group)) df$group <- as.factor(df$group)

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
#' @param df Data frame with columns \code{id}, \code{group}, \code{value}.
#' @return Sorted data frame.
#' @keywords internal
#' @noRd
.validate_paired_ttest_data <- function(df) {
  id_counts <- df |>
    dplyr::group_by(.data$id, .data$group) |>
    dplyr::summarise(n = dplyr::n(), .groups = "drop")

  duplicated_ids <- dplyr::filter(id_counts, .data$n > 1)
  if (nrow(duplicated_ids) > 0)
    cli::cli_abort(c(
      "Each ID must appear exactly once per group for paired tests.",
      "i" = "Found {nrow(duplicated_ids)} ID(s) with duplicate entries."
    ))

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
# Descriptive statistics
# -----------------------------------------------------------------------------

#' Compute per-group descriptive statistics
#'
#' Returns a summary data frame and warns on small or highly unbalanced samples.
#'
#' @param df Data frame with columns \code{group} and \code{value}.
#' @param group_levels Character vector of the two group levels.
#' @return A data frame with columns: group, n, mean, sd, median, min, max.
#' @keywords internal
#' @noRd
.describe_two_group_data <- function(df, group_levels) {
  desc <- df |>
    dplyr::group_by(.data$group) |>
    dplyr::summarise(
      n      = dplyr::n(),
      mean   = mean(.data$value,        na.rm = TRUE),
      sd     = stats::sd(.data$value,   na.rm = TRUE),
      median = stats::median(.data$value, na.rm = TRUE),
      min    = min(.data$value,         na.rm = TRUE),
      max    = max(.data$value,         na.rm = TRUE),
      .groups = "drop"
    )

  ns <- stats::setNames(desc$n, group_levels)

  if (any(ns < 5))
    cli::cli_alert_warning("Very small sample size (n < 5) in at least one group. Results may be unreliable.")

  if (max(ns) / min(ns) > 3)
    cli::cli_alert_warning(
      "Highly unbalanced samples (ratio {round(max(ns) / min(ns), 1)}:1). Interpret with caution."
    )

  desc
}


# -----------------------------------------------------------------------------
# Pre-test: normality check
# -----------------------------------------------------------------------------

#' Check normality for two-group comparison via Shapiro-Wilk
#'
#' For paired tests, checks normality of the paired differences.
#' For independent tests, checks each group separately.
#' Uses sample-size-adaptive thresholds.
#'
#' @param df Data frame with columns \code{group}, \code{value}
#'   (and \code{id} if paired).
#' @param paired Logical.
#' @return List with \code{tests}, \code{sample_sizes},
#'   \code{recommendation} ("parametric" or "non-parametric"),
#'   and \code{rationale}.
#' @keywords internal
#' @noRd
.check_group_normality <- function(df, paired = FALSE) {

  if (paired) {
    groups  <- unique(df$group)
    df_wide <- df |>
      dplyr::select("id", "group", "value") |>
      tidyr::pivot_wider(names_from = "group", values_from = "value")

    diffs <- df_wide[[as.character(groups[1])]] - df_wide[[as.character(groups[2])]]
    n     <- length(diffs)

    if (n < 3) {
      tests <- list(differences = list(p.value = NA, n = n))
      return(list(tests = tests, sample_sizes = c(differences = n),
                  recommendation = "parametric",
                  rationale = "Too few observations for Shapiro-Wilk. Defaulting to paired t-test (use with caution).",
                  paired = TRUE))
    }

    sw    <- stats::shapiro.test(diffs)
    tests <- list(differences = list(p.value = sw$p.value, n = n, statistic = sw$statistic))
    p     <- sw$p.value

    if (n >= 100) {
      rec <- "parametric"
      rat <- "Large sample (n \u2265 100). CLT applies; Shapiro-Wilk is unreliable at this size."
    } else if (n >= 30) {
      if (p >= 0.01) {
        rec <- "parametric"
        rat <- sprintf("Medium sample (n = %d). Differences reasonably normal (Shapiro p = %.3f \u2265 0.01).", n, p)
      } else {
        rec <- "non-parametric"
        rat <- sprintf("Medium sample (n = %d). Differences depart from normality (Shapiro p = %.3f < 0.01).", n, p)
        cli::cli_alert_warning("Normality violated (Shapiro p < 0.01). Switching to Wilcoxon signed-rank test.")
      }
    } else {
      if (p >= 0.05) {
        rec <- "parametric"
        rat <- sprintf("Small sample (n = %d). Differences appear normal (Shapiro p = %.3f \u2265 0.05).", n, p)
      } else {
        rec <- "non-parametric"
        rat <- sprintf("Small sample (n = %d). Differences deviate from normality (Shapiro p = %.3f < 0.05).", n, p)
        cli::cli_alert_warning("Normality violated (Shapiro p < 0.05). Switching to Wilcoxon signed-rank test.")
      }
    }

    return(list(tests = tests, sample_sizes = c(differences = n),
                recommendation = rec, rationale = rat, paired = TRUE))
  }

  # Independent samples
  groups       <- levels(df$group)
  tests        <- list()
  sample_sizes <- numeric(length(groups))
  names(sample_sizes) <- groups

  for (i in seq_along(groups)) {
    grp  <- groups[i]
    vals <- df$value[df$group == grp]
    n    <- length(vals)
    sample_sizes[i] <- n

    if (n < 3) {
      tests[[grp]] <- list(p.value = NA, n = n)
    } else {
      sw           <- stats::shapiro.test(vals)
      tests[[grp]] <- list(p.value = sw$p.value, n = n, statistic = sw$statistic)
    }
  }

  min_n    <- min(sample_sizes)
  p_values <- vapply(tests, function(x) x$p.value, numeric(1L))
  p_values <- p_values[!is.na(p_values)]

  if (length(p_values) == 0) {
    return(list(tests = tests, sample_sizes = sample_sizes,
                recommendation = "parametric",
                rationale = "Too few observations for Shapiro-Wilk. Defaulting to t-test (use with caution).",
                paired = FALSE))
  }

  if (min_n >= 100) {
    rec <- "parametric"
    rat <- "Large samples (n \u2265 100). CLT applies; Shapiro-Wilk is unreliable at this size."
  } else if (min_n >= 30) {
    if (all(p_values >= 0.01)) {
      rec <- "parametric"
      rat <- sprintf("Medium samples (min n = %d). Data reasonably normal (all Shapiro p \u2265 0.01).", min_n)
    } else {
      rec <- "non-parametric"
      rat <- sprintf("Medium samples (min n = %d). Data departs from normality (Shapiro p < 0.01).", min_n)
      cli::cli_alert_warning("Normality violated (Shapiro p < 0.01). Switching to Wilcoxon rank-sum test.")
    }
  } else {
    if (all(p_values >= 0.05)) {
      rec <- "parametric"
      rat <- sprintf("Small samples (min n = %d). Data appears normal (all Shapiro p \u2265 0.05).", min_n)
    } else {
      rec <- "non-parametric"
      rat <- sprintf("Small samples (min n = %d). Data deviates from normality (Shapiro p < 0.05).", min_n)
      cli::cli_alert_warning("Normality violated (Shapiro p < 0.05). Switching to Wilcoxon rank-sum test.")
    }
  }

  list(tests = tests, sample_sizes = sample_sizes,
       recommendation = rec, rationale = rat, paired = FALSE)
}


# -----------------------------------------------------------------------------
# Test execution
# -----------------------------------------------------------------------------

#' Pivot paired data to wide format for vector-based tests
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


#' Run t-test (Welch for unpaired, standard for paired)
#'
#' Always uses Welch's t-test for independent samples (\code{var.equal = FALSE}).
#'
#' @param df Data frame with columns \code{group}, \code{value}
#'   (and \code{id} if paired).
#' @param group_levels Character vector of the two group levels.
#' @param paired Logical.
#' @param alternative Character.
#' @param conf_level Numeric.
#' @return An \code{htest} object.
#' @keywords internal
#' @noRd
.run_quick_ttest <- function(df, group_levels, paired, alternative, conf_level) {
  if (paired) {
    vecs <- .pivot_paired_wide(df, group_levels)
    stats::t.test(
      x = vecs$x, y = vecs$y,
      paired      = TRUE,
      alternative = alternative,
      conf.level  = conf_level
    )
  } else {
    # Reason: always Welch's — more robust; minimal cost when variances are equal
    stats::t.test(
      value ~ group,
      data        = df,
      alternative = alternative,
      var.equal   = FALSE,
      conf.level  = conf_level
    )
  }
}


#' Run Wilcoxon test (signed-rank for paired, rank-sum for independent)
#'
#' @param df Data frame with columns \code{group}, \code{value}
#'   (and \code{id} if paired).
#' @param group_levels Character vector of the two group levels.
#' @param paired Logical.
#' @param alternative Character.
#' @param conf_level Numeric.
#' @return An \code{htest} object.
#' @keywords internal
#' @noRd
.run_quick_wilcox <- function(df, group_levels, paired, alternative, conf_level) {
  if (paired) {
    vecs <- .pivot_paired_wide(df, group_levels)
    stats::wilcox.test(
      x = vecs$x, y = vecs$y,
      paired      = TRUE,
      alternative = alternative,
      conf.int    = TRUE,
      conf.level  = conf_level
    )
  } else {
    stats::wilcox.test(
      value ~ group,
      data        = df,
      alternative = alternative,
      conf.int    = TRUE,
      conf.level  = conf_level
    )
  }
}


# -----------------------------------------------------------------------------
# Variance equality check (ANOVA only)
# -----------------------------------------------------------------------------

#' Check variance equality using Levene's test
#'
#' Used by \code{quick_anova()} to decide between classical ANOVA and Welch
#' ANOVA. Not used by \code{quick_ttest()}, which always applies Welch's
#' correction for independent samples.
#'
#' @param df Data frame with columns \code{group} and \code{value}.
#' @return List with \code{test_performed}, \code{equal_variance}, and
#'   optionally \code{p_value} and \code{test_object}.
#' @keywords internal
#' @noRd
.check_variance_equality <- function(df) {
  if (!requireNamespace("car", quietly = TRUE)) {
    cli::cli_alert_warning("{.pkg car} not available. Defaulting to Welch ANOVA as safer choice.")
    return(list(test_performed = FALSE, equal_variance = FALSE))
  }

  levene <- car::leveneTest(value ~ group, data = df)
  p      <- levene$`Pr(>F)`[1]

  if (!p >= 0.05) {
    p_fmt <- if (p < 0.001) "p < 0.001" else sprintf("p = %.3f", p)
    cli::cli_alert_warning("Unequal variances detected (Levene {p_fmt}). Using Welch ANOVA.")
  }

  list(
    test_performed = TRUE,
    p_value        = p,
    equal_variance = p >= 0.05,
    test_object    = levene
  )
}


# -----------------------------------------------------------------------------
# Plotting
# -----------------------------------------------------------------------------

#' Create two-group comparison plot
#'
#' @param data Data frame with \code{group} and \code{value} columns.
#' @param group_levels Character vector of the two group levels.
#' @param test_result \code{htest} object.
#' @param plot_type One of \code{"boxplot"}, \code{"violin"}, \code{"both"}.
#' @param add_jitter Logical.
#' @param point_size Numeric.
#' @param point_alpha Numeric.
#' @param show_p_value Logical.
#' @param p_label One of \code{"p.signif"}, \code{"p.format"}.
#' @param palette Palette name or \code{NULL}.
#' @param group_name Original group column name (axis label).
#' @param value_name Original value column name (axis label).
#' @return A ggplot object.
#' @keywords internal
#' @noRd
.create_comparison_plot <- function(data, group_levels, test_result,
                                     plot_type, add_jitter, point_size, point_alpha,
                                     show_p_value, p_label, palette,
                                     group_name, value_name) {
  colors <- NULL
  if (!is.null(palette)) {
    tryCatch({
      colors <- get_palette(palette, type = "qualitative")
      if (length(colors) < length(group_levels))
        colors <- rep(colors, length.out = length(group_levels))
    }, error = function(e) {
      cli::cli_alert_warning("Could not load palette {.val {palette}}. Using ggplot2 defaults.")
    })
  }

  p <- ggplot2::ggplot(data, ggplot2::aes(
    x    = .data$group,
    y    = .data$value,
    fill = .data$group
  ))

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
    p <- p + ggplot2::geom_jitter(
      width = 0.1, size = point_size, alpha = point_alpha, show.legend = FALSE
    )

  if (show_p_value) {
    if (!requireNamespace("ggpubr", quietly = TRUE)) {
      cli::cli_alert_warning("{.pkg ggpubr} not installed. Skipping p-value annotation.")
    } else {
      p_value  <- test_result$p.value
      y_vals   <- data[["value"]]
      y_max    <- max(y_vals, na.rm = TRUE)
      y_offset <- max(diff(range(y_vals, na.rm = TRUE)) * 0.15, 0.5)
      y_pos    <- y_max + y_offset

      label_text <- if (p_label == "p.signif") {
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
        p.adj.signif = label_text,
        y.position   = y_pos
      )

      p <- p + ggpubr::stat_pvalue_manual(
        stat_df, label = "p.adj.signif", size = 4,
        bracket.size = 0.5, tip.length = 0.02
      )
    }
  }

  if (!is.null(colors))
    p <- p + ggplot2::scale_fill_manual(values = colors)

  theme_fn <- if (requireNamespace("ggpubr", quietly = TRUE)) {
    ggpubr::theme_pubr(base_size = 12)
  } else {
    ggplot2::theme_bw(base_size = 12)
  }

  p + theme_fn +
    ggplot2::theme(legend.position = "none") +
    ggplot2::labs(x = group_name, y = value_name)
}


# =============================================================================
# Internal helpers
# =============================================================================

#' Run the omnibus test
#' @keywords internal
#' @noRd
.run_anova_omnibus <- function(df, method_used) {
  if (method_used == "anova") {
    fit        <- stats::aov(value ~ group, data = df)
    summary_tbl <- summary(fit)
    p_value    <- summary_tbl[[1]][["Pr(>F)"]][1]
    return(list(
      type       = "anova",
      fit        = fit,
      summary    = summary_tbl,
      p_value    = p_value,
      effect_size = .compute_anova_effect(fit)
    ))
  }

  if (method_used == "welch") {
    test <- stats::oneway.test(value ~ group, data = df, var.equal = FALSE)
    return(list(
      type      = "welch",
      test      = test,
      p_value   = test$p.value,
      statistic = unname(test$statistic),
      parameter = test$parameter
    ))
  }

  # kruskal
  test <- stats::kruskal.test(value ~ group, data = df)
  list(
    type        = "kruskal",
    test        = test,
    p_value     = test$p.value,
    statistic   = unname(test$statistic),
    parameter   = test$parameter,
    effect_size = .compute_kruskal_effect(test, nrow(df))
  )
}


#' Resolve post-hoc method name
#' @keywords internal
#' @noRd
.resolve_post_hoc <- function(post_hoc, method_used) {
  if (post_hoc != "auto") return(post_hoc)
  switch(method_used,
    anova   = "tukey",
    welch   = "welch",
    kruskal = "wilcox",
    "none"
  )
}


#' Warn on incompatible post-hoc / omnibus combinations
#' @keywords internal
#' @noRd
.check_post_hoc_compat <- function(post_hoc_method, method_used) {
  if (post_hoc_method == "none") return(invisible(NULL))

  msg <- NULL
  if (post_hoc_method == "tukey"  && method_used != "anova")
    msg <- "Tukey HSD is only appropriate after classical ANOVA."
  if (post_hoc_method == "welch"  && method_used == "kruskal")
    msg <- "Welch pairwise t-tests are not suitable after Kruskal-Wallis."
  if (post_hoc_method == "wilcox" && method_used %in% c("anova", "welch"))
    msg <- "Wilcoxon post-hoc is typically paired with Kruskal-Wallis."

  if (!is.null(msg))
    cli::cli_alert_warning(
      "{msg} Post-hoc will be skipped. Consider {.code post_hoc = 'auto'}."
    )

  invisible(NULL)
}


#' Run post-hoc tests
#' @keywords internal
#' @noRd
.run_anova_post_hoc <- function(df, method_used, post_hoc_method,
                                 omnibus_result, conf_level) {
  # Guard: incompatible combinations return NULL silently
  if (post_hoc_method == "tukey"  && method_used != "anova")   return(NULL)
  if (post_hoc_method == "welch"  && method_used == "kruskal") return(NULL)
  if (post_hoc_method == "wilcox" && method_used %in% c("anova", "welch")) return(NULL)

  if (post_hoc_method == "tukey") {
    tukey <- stats::TukeyHSD(omnibus_result$fit, conf.level = conf_level)
    # Reason: split on LAST hyphen to handle group names that contain hyphens
    tbl <- tibble::as_tibble(as.data.frame(tukey[[1]]), rownames = "comparison")
    tbl <- tidyr::separate(tbl, "comparison",
                           into = c("group2", "group1"),
                           sep = "-(?=[^-]*$)", remove = TRUE)
    return(list(method = "tukey", table = tbl, raw = tukey))
  }

  if (post_hoc_method == "welch") {
    test <- stats::pairwise.t.test(df$value, df$group,
                                   p.adjust.method = "BH", pool.sd = FALSE)
    return(list(method = "welch", table = .tidy_pairwise(test$p.value), raw = test))
  }

  if (post_hoc_method == "wilcox") {
    test <- stats::pairwise.wilcox.test(df$value, df$group,
                                        p.adjust.method = "BH", exact = FALSE)
    return(list(method = "wilcox", table = .tidy_pairwise(test$p.value), raw = test))
  }

  cli::cli_alert_warning("Unknown post-hoc method {.val {post_hoc_method}}. Skipping.")
  NULL
}


#' Convert a pairwise p-value matrix to a tidy data frame
#' @keywords internal
#' @noRd
.tidy_pairwise <- function(mat) {
  if (is.null(mat)) return(NULL)
  df <- as.data.frame(as.table(mat))
  colnames(df) <- c("group1", "group2", "p.adjusted")
  tibble::as_tibble(df[!is.na(df$p.adjusted), , drop = FALSE])
}


#' Compute eta-squared and omega-squared for classical ANOVA
#' @keywords internal
#' @noRd
.compute_anova_effect <- function(fit) {
  tbl        <- summary(fit)[[1]]
  ss_between <- tbl[1, "Sum Sq"]
  ss_within  <- tbl[2, "Sum Sq"]
  df_between <- tbl[1, "Df"]
  df_within  <- tbl[2, "Df"]
  ms_within  <- ss_within / df_within
  ss_total   <- ss_between + ss_within

  list(
    eta_squared   = max(0, ss_between / ss_total),
    omega_squared = max(0, (ss_between - df_between * ms_within) /
                            (ss_total + ms_within))
  )
}


#' Compute epsilon-squared for Kruskal-Wallis
#' @keywords internal
#' @noRd
.compute_kruskal_effect <- function(test, n) {
  # Reference: Tomczak & Tomczak (2014)
  H <- unname(test$statistic)
  list(epsilon_squared = max(0, min(1, H / (n^2 - 1))))
}


#' Create ANOVA comparison plot
#' @keywords internal
#' @noRd
.create_anova_plot <- function(data, group_levels, plot_type, add_jitter,
                                point_size, point_alpha, palette,
                                show_p_value, p_value, p_label,
                                method_used, group_name, value_name) {

  colors <- NULL
  if (!is.null(palette)) {
    tryCatch({
      colors <- get_palette(palette, type = "qualitative")
      if (length(colors) < length(group_levels))
        colors <- rep(colors, length.out = length(group_levels))
    }, error = function(e) {
      cli::cli_alert_warning("Could not load palette {.val {palette}}. Using ggplot2 defaults.")
    })
  }

  p <- ggplot2::ggplot(
    data,
    ggplot2::aes(x = .data$group, y = .data$value, fill = .data$group)
  )

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
    p <- p + ggplot2::geom_jitter(
      width = 0.15, size = point_size, alpha = point_alpha, show.legend = FALSE
    )

  if (!is.null(colors))
    p <- p + ggplot2::scale_fill_manual(values = colors)

  if (show_p_value) {
    method_label <- switch(method_used,
      anova   = "One-way ANOVA",
      welch   = "Welch ANOVA",
      kruskal = "Kruskal-Wallis"
    )
    p_text <- if (p_label == "p.signif") {
      dplyr::case_when(
        p_value < 0.001 ~ "***",
        p_value < 0.01  ~ "**",
        p_value < 0.05  ~ "*",
        TRUE            ~ "ns"
      )
    } else {
      if (p_value < 0.0001) sprintf("p = %.2e", p_value)
      else                  sprintf("p = %.4f", p_value)
    }

    p <- p + ggplot2::annotate(
      "text",
      x = Inf, y = Inf,
      label      = paste0(method_label, "\n", p_text),
      hjust      = 1.05, vjust = 1.2,
      size       = 4, fontface = "bold",
      lineheight = 1.1, color = "black"
    )
  }

  theme_fn <- if (requireNamespace("ggpubr", quietly = TRUE)) {
    ggpubr::theme_pubr(base_size = 12)
  } else {
    ggplot2::theme_bw(base_size = 12)
  }

  p + theme_fn +
    ggplot2::theme(
      legend.position  = "none",
      axis.title       = ggplot2::element_text(size = 12, face = "bold"),
      panel.grid.major.y = ggplot2::element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor.y = ggplot2::element_blank()
    ) +
    ggplot2::labs(x = group_name, y = value_name) +
    ggplot2::coord_cartesian(clip = "off")
}


# =============================================================================
# quick_chisq() helpers
# =============================================================================

#' Prepare data for chi-square test
#' @keywords internal
#' @noRd
.prepare_chisq_data <- function(data, x_col, y_col) {
  df           <- data[, c(x_col, y_col), drop = FALSE]
  colnames(df) <- c("var1", "var2")

  n_missing <- sum(is.na(df$var1) | is.na(df$var2))
  if (n_missing > 0) {
    cli::cli_alert_warning("Removed {n_missing} row{?s} with missing values.")
    df <- df[stats::complete.cases(df), , drop = FALSE]
  }
  if (nrow(df) == 0)
    cli::cli_abort("No valid data remaining after removing missing values.")

  if (!is.factor(df$var1)) df$var1 <- as.factor(as.character(df$var1))
  if (!is.factor(df$var2)) df$var2 <- as.factor(as.character(df$var2))

  df
}


#' Select chi-square test method based on expected frequencies
#' @keywords internal
#' @noRd
.select_chisq_method <- function(method, correct, n_rows, n_cols,
                                  n_total, expected_freq) {
  min_expected       <- min(expected_freq)
  n_cells_below_5    <- sum(expected_freq < 5)
  prop_cells_below_5 <- n_cells_below_5 / length(expected_freq)

  base <- list(
    table_size         = paste0(n_rows, "x", n_cols),
    total_n            = n_total,
    min_expected_freq  = round(min_expected, 2),
    n_cells_below_5    = n_cells_below_5,
    prop_cells_below_5 = round(prop_cells_below_5, 3)
  )

  if (method != "auto") {
    correct_used <- if (is.null(correct)) FALSE else correct
    label <- switch(method,
      chisq   = if (correct_used) "Chi-square test with Yates' correction"
                else "Chi-square test",
      fisher  = "Fisher's exact test",
      mcnemar = "McNemar's test"
    )
    return(c(base, list(method = method, correct = correct_used, label = label,
                        reason = paste("User-specified method:", method))))
  }

  # 2x2 with small expected frequencies -> Fisher's exact test
  if (n_rows == 2 && n_cols == 2 && min_expected < 5) {
    cli::cli_alert_info("2x2 table with expected freq < 5. Using Fisher's exact test.")
    return(c(base, list(
      method = "fisher", correct = FALSE,
      label  = "Fisher's exact test",
      reason = "2x2 table with expected frequency < 5: using Fisher's exact test"
    )))
  }

  # > 20% cells with expected freq < 5 -> chi-square with warning
  if (min_expected < 5 && prop_cells_below_5 > 0.2) {
    cli::cli_alert_warning("More than 20% of cells have expected freq < 5. Results may be unreliable.")
    cli::cli_alert_warning("Consider combining categories or using Fisher's exact test.")
    correct_used <- if (is.null(correct)) FALSE else correct
    return(c(base, list(
      method  = "chisq", correct = correct_used,
      label   = "Chi-square test",
      reason  = "More than 20% of cells have expected freq < 5: using chi-square with warning"
    )))
  }

  # 2x2 with moderate expected frequencies -> Yates' correction
  if (n_rows == 2 && n_cols == 2 && min_expected < 10 && is.null(correct)) {
    cli::cli_alert_info("Applying Yates' continuity correction for 2x2 table.")
    return(c(base, list(
      method = "chisq", correct = TRUE,
      label  = "Chi-square test with Yates' correction",
      reason = "2x2 table with 5 \u2264 expected freq < 10: applying Yates' correction"
    )))
  }

  # Standard chi-square
  correct_used <- if (is.null(correct)) FALSE else correct
  c(base, list(
    method  = "chisq",
    correct = correct_used,
    label   = if (correct_used) "Chi-square test with Yates' correction"
              else "Chi-square test",
    reason  = "All expected frequencies adequate: using standard chi-square test"
  ))
}


#' Run the selected chi-square family test
#' @keywords internal
#' @noRd
.run_chisq_test <- function(cont_table, method, correct, conf_level,
                             n_rows, n_cols) {
  if (method == "fisher") {
    return(tryCatch(
      stats::fisher.test(cont_table, conf.level = conf_level),
      error = function(e) {
        cli::cli_alert_danger(
          "Fisher's exact test failed: {e$message}. Falling back to chi-square."
        )
        stats::chisq.test(cont_table, correct = FALSE)
      }
    ))
  }

  if (method == "chisq")
    return(stats::chisq.test(cont_table, correct = correct))

  # mcnemar
  if (n_rows != n_cols)
    cli::cli_abort("McNemar's test requires a square contingency table.")
  stats::mcnemar.test(cont_table, correct = correct)
}


#' Compute Cramer's V effect size
#' @keywords internal
#' @noRd
.compute_cramers_v <- function(test_result, n_total, n_rows, n_cols) {
  if (is.null(test_result$statistic)) return(NULL)

  chi_sq  <- as.numeric(test_result$statistic)
  min_dim <- min(n_rows - 1, n_cols - 1)
  v       <- sqrt(chi_sq / (n_total * min_dim))

  interp <- if (v < 0.1) "negligible" else if (v < 0.3) "small" else
            if (v < 0.5) "medium" else "large"

  list(cramers_v = round(v, 3), interpretation = interp)
}


#' Create chi-square association plot
#' @keywords internal
#' @noRd
.create_chisq_plot <- function(df, cont_table, pearson_residuals, test_result,
                                method_used, plot_type, show_p_value, p_label,
                                palette, x_name, y_name) {
  plot_data           <- as.data.frame.table(cont_table)
  colnames(plot_data) <- c("var1", "var2", "Count")
  plot_data$var1      <- as.factor(plot_data$var1)
  plot_data$var2      <- as.factor(plot_data$var2)

  # Resolve palette colors
  colors <- NULL
  if (!is.null(palette)) {
    n_needed <- nlevels(plot_data$var2)
    tryCatch({
      colors <- get_palette(palette, n = n_needed)
      if (is.null(colors) || length(colors) < n_needed) {
        cli::cli_alert_warning(
          "Palette '{palette}' has insufficient colors ({length(colors)} of {n_needed} needed). Using defaults."
        )
        colors <- NULL
      }
    }, error = function(e) {
      cli::cli_alert_warning("Failed to load palette '{palette}': {e$message}. Using defaults.")
    })
  }

  # Build plot
  if (plot_type == "bar_grouped") {
    p <- ggplot2::ggplot(
      plot_data,
      ggplot2::aes(x = .data$var1, y = .data$Count, fill = .data$var2)
    ) +
      ggplot2::geom_bar(stat = "identity", position = "dodge", width = 0.7) +
      ggplot2::labs(x = x_name, y = "Count", fill = y_name) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(
        legend.position    = "right",
        panel.grid.major.x = ggplot2::element_blank()
      )

  } else if (plot_type == "bar_stacked") {
    plot_data <- plot_data |>
      dplyr::group_by(.data$var1) |>
      dplyr::mutate(Proportion = .data$Count / sum(.data$Count)) |>
      dplyr::ungroup()

    p <- ggplot2::ggplot(
      plot_data,
      ggplot2::aes(x = .data$var1, y = .data$Proportion, fill = .data$var2)
    ) +
      ggplot2::geom_bar(stat = "identity", width = 0.7) +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::labs(x = x_name, y = "Proportion", fill = y_name) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(
        legend.position    = "right",
        panel.grid.major.x = ggplot2::element_blank()
      )

  } else {
    # heatmap of Pearson residuals
    if (is.null(pearson_residuals)) {
      cli::cli_alert_warning("Pearson residuals unavailable. Falling back to bar_grouped.")
      return(.create_chisq_plot(df, cont_table, NULL, test_result, method_used,
                                "bar_grouped", show_p_value, p_label, palette,
                                x_name, y_name))
    }
    residual_data           <- as.data.frame.table(pearson_residuals)
    colnames(residual_data) <- c("var1", "var2", "Residual")
    abs_max                 <- max(abs(residual_data$Residual))

    p <- ggplot2::ggplot(
      residual_data,
      ggplot2::aes(x = .data$var2, y = .data$var1, fill = .data$Residual)
    ) +
      ggplot2::geom_tile(color = "white", linewidth = 0.5) +
      ggplot2::geom_text(
        ggplot2::aes(label = round(.data$Residual, 2)), size = 4
      ) +
      ggplot2::scale_fill_gradient2(
        low = "#2166AC", mid = "white", high = "#B2182B",
        midpoint = 0, limits = c(-abs_max, abs_max),
        name = "Pearson\nResidual"
      ) +
      ggplot2::labs(x = y_name, y = x_name, title = "Pearson Residuals") +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(panel.grid = ggplot2::element_blank())
  }

  # Apply palette (not for heatmap which has its own scale)
  if (!is.null(colors) && plot_type != "heatmap")
    p <- p + ggplot2::scale_fill_manual(values = colors)

  # P-value annotation
  if (show_p_value && plot_type != "heatmap") {
    p_value <- test_result$p.value
    p_text  <- if (p_label == "p.signif") {
      dplyr::case_when(
        p_value < 0.001 ~ "***",
        p_value < 0.01  ~ "**",
        p_value < 0.05  ~ "*",
        TRUE            ~ "ns"
      )
    } else {
      if (p_value < 0.001) "p < 0.001"
      else paste0("p = ", format.pval(p_value, digits = 3))
    }
    p <- p + ggplot2::labs(title = method_used, subtitle = p_text)
  } else {
    p <- p + ggplot2::labs(title = method_used)
  }

  p
}


# =============================================================================
# quick_cor() helpers
# =============================================================================

#' Prepare and validate data for correlation analysis
#' @keywords internal
#' @noRd
.prepare_cor_data <- function(data, vars) {
  if (is.null(vars)) {
    numeric_cols <- vapply(data, is.numeric, logical(1L))
    if (!any(numeric_cols))
      cli::cli_abort("No numeric columns found in {.arg data}.")
    df <- data[, numeric_cols, drop = FALSE]
  } else {
    .assert_character_vector(vars)
    .assert_has_cols(data, vars)
    df <- data[, vars, drop = FALSE]
    non_numeric <- !vapply(df, is.numeric, logical(1L))
    if (any(non_numeric))
      cli::cli_abort(c(
        "All variables must be numeric.",
        "x" = "Non-numeric: {.val {names(df)[non_numeric]}}"
      ))
  }

  if (ncol(df) < 2)
    cli::cli_abort("At least 2 numeric variables are required.")

  # Remove constant variables
  variances      <- vapply(df, function(x) stats::var(x, na.rm = TRUE), numeric(1L))
  constant_vars  <- names(variances)[variances == 0 | is.na(variances)]
  if (length(constant_vars) > 0) {
    cli::cli_alert_warning(
      "Removed {length(constant_vars)} constant variable{?s}: {.val {constant_vars}}"
    )
    df <- df[, !names(df) %in% constant_vars, drop = FALSE]
  }

  if (ncol(df) < 2)
    cli::cli_abort("At least 2 non-constant variables required after removing constant columns.")

  df
}


#' Compute correlation matrix and p-values
#' @keywords internal
#' @noRd
.compute_correlation_matrix <- function(df, method, use) {
  cor_matrix <- stats::cor(df, use = use, method = method)

  # Fast path: psych::corr.test
  if (requireNamespace("psych", quietly = TRUE)) {
    result <- tryCatch({
      ct        <- psych::corr.test(df, use = use, method = method, adjust = "none")
      p_matrix  <- ct$p
      diag(p_matrix) <- NA
      list(cor_matrix = cor_matrix, p_matrix = p_matrix)
    }, error = function(e) {
      cli::cli_alert_warning("psych::corr.test() failed. Falling back to stats::cor.test().")
      NULL
    })
    if (!is.null(result)) return(result)
  }

  # Fallback: loop over pairs
  n_vars   <- ncol(df)
  p_matrix <- matrix(NA_real_, nrow = n_vars, ncol = n_vars,
                     dimnames = list(colnames(df), colnames(df)))

  for (i in seq_len(n_vars - 1)) {
    for (j in seq(i + 1, n_vars)) {
      pair     <- df[, c(i, j)]
      complete <- stats::complete.cases(pair)
      x <- pair[complete, 1]
      y <- pair[complete, 2]

      if (length(x) >= 3) {
        res <- tryCatch(stats::cor.test(x, y, method = method), error = function(e) NULL)
        if (!is.null(res)) {
          p_matrix[i, j] <- res$p.value
          p_matrix[j, i] <- res$p.value
        }
      }
    }
  }

  list(cor_matrix = cor_matrix, p_matrix = p_matrix)
}


#' Extract significant correlation pairs
#' @keywords internal
#' @noRd
.extract_sig_pairs <- function(cor_matrix, p_matrix, alpha) {
  rows <- list()
  n    <- nrow(cor_matrix)

  for (i in seq_len(n - 1)) {
    for (j in seq(i + 1, n)) {
      p <- p_matrix[i, j]
      if (!is.na(p) && p < alpha) {
        rows[[length(rows) + 1L]] <- data.frame(
          var1        = rownames(cor_matrix)[i],
          var2        = colnames(cor_matrix)[j],
          correlation = cor_matrix[i, j],
          p_value     = p
        )
      }
    }
  }

  if (length(rows) == 0L)
    return(data.frame(var1 = character(), var2 = character(),
                      correlation = numeric(), p_value = numeric()))

  out <- do.call(rbind, rows)
  out[order(out$p_value), ]
}


#' Create correlation heatmap
#' @keywords internal
#' @noRd
.create_cor_heatmap <- function(cor_matrix, p_matrix, type, show_coef, show_sig,
                                 sig_level, hc_order, hc_method, palette,
                                 lab_size, title, show_axis_x, show_axis_y,
                                 axis_x_angle, axis_y_angle, axis_text_size) {

  if (!requireNamespace("ggcorrplot", quietly = TRUE))
    cli::cli_abort(c(
      "Package {.pkg ggcorrplot} is required for correlation heatmaps.",
      "i" = "Install with: {.code install.packages('ggcorrplot')}"
    ))

  # Resolve palette colors
  color_vec <- NULL
  if (!is.null(palette)) {
    tryCatch({
      for (type_try in c("diverging", "sequential", "qualitative")) {
        color_vec <- tryCatch(
          get_palette(palette, type = type_try),
          error = function(e) NULL
        )
        if (!is.null(color_vec) && length(color_vec) >= 3) break
      }
      if (!is.null(color_vec) && length(color_vec) < 3) color_vec <- NULL
    }, error = function(e) {
      cli::cli_alert_warning("Could not load palette {.val {palette}}. Using defaults.")
    })
  }
  if (is.null(color_vec))
    color_vec <- c("#67a9cf", "#f7f7f7", "#ef8a62")  # Blue-White-Red

  # Build heatmap
  p <- suppressWarnings(
    ggcorrplot::ggcorrplot(
      corr          = cor_matrix,
      method        = "square",
      type          = type,
      colors        = color_vec,
      ggtheme       = ggplot2::theme_minimal,
      show.legend   = TRUE,
      legend.title  = "Correlation",
      lab           = show_coef,
      lab_col       = "black",
      lab_size      = lab_size,
      hc.order      = hc_order,
      hc.method     = hc_method,
      outline.color = "grey85",
      digits        = 2
    )
  )

  if (!is.null(title))
    p <- p + ggplot2::labs(title = title)

  # Axis styling
  x_hjust <- if (axis_x_angle == 0) 0.5 else 1
  x_vjust <- if (axis_x_angle == 90) 0.5 else 1
  y_hjust <- if (axis_y_angle == 0) 1 else 0.5
  y_vjust <- if (axis_y_angle == 90) 1 else 0.5

  p <- p + ggplot2::theme(
    plot.title   = ggplot2::element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.text.x  = if (show_axis_x)
      ggplot2::element_text(angle = axis_x_angle, hjust = x_hjust,
                            vjust = x_vjust, size = axis_text_size)
      else ggplot2::element_blank(),
    axis.text.y  = if (show_axis_y)
      ggplot2::element_text(angle = axis_y_angle, hjust = y_hjust,
                            vjust = y_vjust, size = axis_text_size)
      else ggplot2::element_blank(),
    panel.grid        = ggplot2::element_blank(),
    panel.background  = ggplot2::element_rect(fill = "white", colour = NA),
    plot.background   = ggplot2::element_rect(fill = "white", colour = NA)
  )

  # Significance stars
  if (show_sig) {
    var_levels <- levels(p$data$Var1)
    star_mat   <- matrix("", nrow = nrow(p_matrix), ncol = ncol(p_matrix),
                         dimnames = dimnames(p_matrix))

    for (i in seq_len(nrow(p_matrix))) {
      for (j in seq_len(ncol(p_matrix))) {
        pv <- p_matrix[i, j]
        if (!is.na(pv)) {
          star_mat[i, j] <- if (pv <= sig_level[1]) "***" else
                            if (pv <= sig_level[2]) "**"  else
                            if (pv <= sig_level[3]) "*"   else ""
        }
      }
    }

    star_df        <- as.data.frame(as.table(star_mat))
    names(star_df) <- c("Var1", "Var2", "stars")
    star_df        <- star_df[nzchar(star_df$stars), ]
    star_df$Var1   <- factor(star_df$Var1, levels = var_levels)
    star_df$Var2   <- factor(star_df$Var2, levels = var_levels)

    if (type == "upper")
      star_df <- star_df[as.numeric(star_df$Var1) < as.numeric(star_df$Var2), ]
    else if (type == "lower")
      star_df <- star_df[as.numeric(star_df$Var1) > as.numeric(star_df$Var2), ]

    if (nrow(star_df) > 0)
      p <- p + ggplot2::geom_text(
        data    = star_df,
        mapping = ggplot2::aes(x = .data$Var2, y = .data$Var1, label = .data$stars),
        inherit.aes = FALSE, size = 3.8, color = "black"
      )
  }

  p
}
