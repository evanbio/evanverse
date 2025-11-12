#' Quick ANOVA with Automatic Method Selection
#'
#' Conduct one-way ANOVA, Welch ANOVA, or Kruskal-Wallis test with automatic
#' assumption checks, publication-ready visualization, and optional post-hoc
#' comparisons. Designed for comparing two or more independent groups.
#'
#' @param data A data frame containing the variables.
#' @param group Column name for the grouping factor. Supports quoted or
#'   unquoted names via tidy evaluation.
#' @param value Column name for the numeric response variable.
#' @param method Character. One of "auto" (default), "anova", "welch",
#'   or "kruskal". When "auto", the function inspects normality and
#'   homogeneity of variances to pick an appropriate test.
#' @param post_hoc Character. Post-hoc procedure: "auto" (default), "none",
#'   "tukey", "welch", or "wilcox". "auto" selects Tukey for ANOVA,
#'   Welch-style pairwise t-tests for Welch ANOVA, and pairwise Wilcoxon
#'   tests for Kruskal-Wallis.
#' @param conf.level Numeric. Confidence level for the test/intervals.
#'   Default is 0.95.
#' @param plot_type Character. One of "boxplot", "violin", or "both".
#' @param add_jitter Logical. Add jittered points? Default TRUE.
#' @param point_size Numeric. Size of jitter points. Default 2.
#' @param point_alpha Numeric. Transparency for jitter points (0-1). Default 0.6.
#' @param show_p_value Logical. Show omnibus p-value on the plot? Default TRUE.
#' @param p_label Character. P-value display: "p.format" (default) or
#'   "p.signif" (stars).
#' @param palette Character. Palette name from evanverse, or NULL for defaults.
#' @param verbose Logical. Print informative messages? Default TRUE.
#' @param ... Reserved for future extensions.
#'
#' @return An object of class \code{quick_anova_result} with elements:
#'   \describe{
#'     \item{plot}{ggplot object of the comparison}
#'     \item{omnibus_result}{List describing the main test}
#'     \item{post_hoc}{Post-hoc comparison table (if requested)}
#'     \item{method_used}{Character. "anova", "welch", or "kruskal"}
#'     \item{descriptive_stats}{Summary statistics by group}
#'     \item{assumption_checks}{Results of normality/variance checks}
#'     \item{auto_decision}{Details explaining automatic selections}
#'     \item{timestamp}{POSIXct timestamp of the analysis}
#'   }
#'
#' @examples
#' set.seed(123)
#' df <- data.frame(
#'   group = rep(LETTERS[1:3], each = 40),
#'   value = rnorm(120, mean = rep(c(0, 0.5, 1.2), each = 40), sd = 1)
#' )
#' res <- quick_anova(df, group, value)
#' res$plot
#' summary(res)
#'
#' @seealso \code{\link[stats]{aov}}, \code{\link[stats]{oneway.test}},
#'   \code{\link[stats]{kruskal.test}}
#' @export
quick_anova <- function(data,
                        group,
                        value,
                        method = c("auto", "anova", "welch", "kruskal"),
                        post_hoc = c("auto", "none", "tukey", "welch", "wilcox"),
                        conf.level = 0.95,
                        plot_type = c("boxplot", "violin", "both"),
                        add_jitter = TRUE,
                        point_size = 2,
                        point_alpha = 0.6,
                        show_p_value = TRUE,
                        p_label = c("p.format", "p.signif"),
                        palette = "qual_vivid",
                        verbose = TRUE,
                        ...) {

  method <- match.arg(method)
  post_hoc <- match.arg(post_hoc)
  plot_type <- match.arg(plot_type)
  p_label <- match.arg(p_label)

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }
  if (!is.numeric(conf.level) || conf.level <= 0 || conf.level >= 1) {
    cli::cli_abort("{.arg conf.level} must be between 0 and 1.")
  }
  if (!is.logical(add_jitter) || length(add_jitter) != 1) {
    cli::cli_abort("{.arg add_jitter} must be TRUE or FALSE.")
  }
  if (!is.logical(show_p_value) || length(show_p_value) != 1) {
    cli::cli_abort("{.arg show_p_value} must be TRUE or FALSE.")
  }
  if (!is.logical(verbose) || length(verbose) != 1) {
    cli::cli_abort("{.arg verbose} must be TRUE or FALSE.")
  }

  group_col <- rlang::ensym(group)
  value_col <- rlang::ensym(value)
  group_name <- rlang::as_string(group_col)
  value_name <- rlang::as_string(value_col)

  if (!group_name %in% names(data)) {
    cli::cli_abort("Column {.field {group_name}} not found in {.arg data}.")
  }
  if (!value_name %in% names(data)) {
    cli::cli_abort("Column {.field {value_name}} not found in {.arg data}.")
  }

  df <- data[, c(group_name, value_name), drop = FALSE]
  colnames(df) <- c("group", "value")

  n_missing <- sum(is.na(df$group) | is.na(df$value))
  if (n_missing > 0) {
    if (verbose) {
      cli::cli_alert_warning("Removed {n_missing} row{?s} with missing values.")
    }
    df <- df[stats::complete.cases(df), , drop = FALSE]
  }
  if (nrow(df) == 0) {
    cli::cli_abort("No valid data remaining after removing missing values.")
  }
  if (!is.numeric(df$value)) {
    cli::cli_abort("{.field {value_name}} must be numeric.")
  }
  if (!is.factor(df$group)) {
    df$group <- as.factor(df$group)
  }

  group_levels <- levels(df$group)
  n_groups <- length(group_levels)
  if (n_groups < 2) {
    cli::cli_abort("{.fn quick_anova} requires at least 2 groups.")
  }
  if (n_groups == 2 && verbose) {
    cli::cli_alert_info("Detected exactly 2 groups. Consider using {.fn quick_ttest} for pairwise comparisons.")
  }

  desc_stats <- df %>%
    dplyr::group_by(.data$group) %>%
    dplyr::summarise(
      n = dplyr::n(),
      mean = mean(.data$value, na.rm = TRUE),
      sd = sd(.data$value, na.rm = TRUE),
      median = median(.data$value, na.rm = TRUE),
      min = min(.data$value, na.rm = TRUE),
      max = max(.data$value, na.rm = TRUE),
      .groups = "drop"
    )

  sample_sizes <- desc_stats$n
  if (any(sample_sizes < 5)) {
    cli::cli_alert_warning("Very small sample size detected (n < 5). Use caution.")
  }
  if ((max(sample_sizes) / min(sample_sizes)) > 4) {
    cli::cli_alert_warning("Severely unbalanced sample sizes detected.")
  }

  auto_decision <- list(
    normality = NULL,
    variance = NULL,
    method_rationale = NULL
  )

  normality_tests <- NULL
  variance_test <- NULL

  if (method == "auto") {
    if (verbose) {
      cli::cli_h2("Automatic Method Selection")
    }

    normality_tests <- .check_normality_smart(df, paired = FALSE, verbose = verbose)
    auto_decision$normality <- normality_tests

    use_parametric <- normality_tests$recommendation == "parametric"

    if (use_parametric) {
      variance_test <- .check_variance_equality(df, verbose = verbose)
      auto_decision$variance <- variance_test

      if (variance_test$equal_variance) {
        method_selected <- "anova"
        auto_decision$method_rationale <- "Normality satisfied and variances approximately equal."
      } else {
        method_selected <- "welch"
        auto_decision$method_rationale <- "Normality satisfied but variances unequal. Using Welch ANOVA."
      }
    } else {
      method_selected <- "kruskal"
      auto_decision$method_rationale <- "Normality assumption violated. Using Kruskal-Wallis."
    }
  } else {
    method_selected <- method
    if (verbose) {
      cli::cli_alert_info("Using manually specified method: {method_selected}")
    }
  }

  # Perform assumption checks based on selected method
  # Always run normality tests for diagnostic purposes
  if (is.null(normality_tests)) {
    normality_tests <- .check_normality_smart(df, paired = FALSE, verbose = verbose)
  }

  # Only check variance equality for classical ANOVA (not Welch, which handles unequal variances)
  if (is.null(variance_test) && method_selected == "anova") {
    variance_test <- .check_variance_equality(df, verbose = verbose)
  }

  # Resolve and validate post-hoc method early (before running omnibus test)
  chosen_post_hoc <- .resolve_post_hoc_method(post_hoc, method_selected)

  # Early validation of post-hoc compatibility
  if (chosen_post_hoc != "none") {
    .validate_post_hoc_compatibility(chosen_post_hoc, method_selected, verbose)
  }

  if (verbose) {
    cli::cli_h2("Omnibus Test")
  }

  omnibus_result <- .run_anova_test(df, method_selected, conf.level, verbose)
  p_value <- omnibus_result$p_value

  post_hoc_result <- NULL

  if (chosen_post_hoc != "none") {
    post_hoc_result <- .run_post_hoc_tests(
      df = df,
      method_used = method_selected,
      post_hoc_method = chosen_post_hoc,
      omnibus_result = omnibus_result,
      conf.level = conf.level,
      verbose = verbose
    )
  }

  # Extract statistic value safely
  if (method_selected == "anova") {
    stat_value <- omnibus_result$summary[[1]][1, "F value"]
  } else if (method_selected == "welch") {
    stat_value <- omnibus_result$statistic
  } else {
    stat_value <- omnibus_result$statistic
  }

  plot <- .create_anova_plot(
    data = df,
    group_levels = group_levels,
    plot_type = plot_type,
    add_jitter = add_jitter,
    point_size = point_size,
    point_alpha = point_alpha,
    palette = palette,
    show_p_value = show_p_value,
    p_value = p_value,
    p_label = p_label,
    method_used = method_selected,
    statistic_value = stat_value,
    descriptive_stats = desc_stats,
    group_name = group_name,
    value_name = value_name
  )

  res <- list(
    plot = plot,
    omnibus_result = omnibus_result,
    post_hoc = post_hoc_result,
    method_used = method_selected,
    descriptive_stats = desc_stats,
    assumption_checks = list(
      normality = normality_tests,
      variance = variance_test
    ),
    auto_decision = auto_decision,
    timestamp = Sys.time(),
    parameters = list(
      method = method,
      post_hoc = post_hoc,
      conf.level = conf.level,
      plot_type = plot_type,
      add_jitter = add_jitter,
      show_p_value = show_p_value
    )
  )

  class(res) <- "quick_anova_result"
  res
}

.run_anova_test <- function(df, method_used, conf.level, verbose) {
  if (method_used == "anova") {
    fit <- stats::aov(value ~ group, data = df)
    summary_tbl <- summary(fit)
    p_value <- summary_tbl[[1]][["Pr(>F)"]][1]
    effect <- .compute_anova_effect_size(fit)

    if (verbose) {
      cli::cli_alert_success("Completed classical one-way ANOVA (p = {sprintf('%.4f', p_value)})")
    }

    return(list(
      type = "anova",
      fit = fit,
      summary = summary_tbl,
      p_value = p_value,
      effect_size = effect
    ))
  }

  if (method_used == "welch") {
    test <- stats::oneway.test(value ~ group, data = df, var.equal = FALSE)
    if (verbose) {
      cli::cli_alert_success("Completed Welch ANOVA (p = {sprintf('%.4f', test$p.value)})")
    }
    return(list(
      type = "welch",
      test = test,
      p_value = test$p.value,
      statistic = unname(test$statistic),
      parameter = test$parameter
    ))
  }

  test <- stats::kruskal.test(value ~ group, data = df)
  effect <- .compute_kruskal_effect_size(test, n = nrow(df), k = length(unique(df$group)))

  if (verbose) {
    cli::cli_alert_success("Completed Kruskal-Wallis test (p = {sprintf('%.4f', test$p.value)})")
  }

  list(
    type = "kruskal",
    test = test,
    p_value = test$p.value,
    statistic = unname(test$statistic),
    parameter = test$parameter,
    effect_size = effect
  )
}

.resolve_post_hoc_method <- function(post_hoc, method_used) {
  if (post_hoc == "auto") {
    return(switch(
      method_used,
      anova = "tukey",
      welch = "welch",
      kruskal = "wilcox",
      "none"
    ))
  }
  post_hoc
}

.validate_post_hoc_compatibility <- function(post_hoc_method, method_used, verbose) {
  # Early validation to catch incompatible post-hoc/method combinations
  # This prevents wasting time on omnibus test when post-hoc will be skipped

  incompatible <- FALSE
  reason <- NULL

  if (post_hoc_method == "tukey" && method_used != "anova") {
    incompatible <- TRUE
    reason <- "Tukey HSD is only appropriate after classical ANOVA."
  } else if (post_hoc_method == "welch" && method_used == "kruskal") {
    incompatible <- TRUE
    reason <- "Welch-style pairwise t-tests are not suitable after Kruskal-Wallis."
  } else if (post_hoc_method == "wilcox" && method_used %in% c("anova", "welch")) {
    incompatible <- TRUE
    reason <- "Wilcoxon post-hoc is typically paired with Kruskal-Wallis."
  }

  if (incompatible) {
    if (verbose) {
      cli::cli_alert_warning(
        "{reason} Post-hoc comparisons will be skipped. Consider using {.arg post_hoc = 'auto'}."
      )
    }
  }

  invisible(NULL)
}

.run_post_hoc_tests <- function(df, method_used, post_hoc_method, omnibus_result, conf.level, verbose) {

  # These checks are now redundant (performed in .validate_post_hoc_compatibility)
  # but kept for defensive programming in case function is called directly
  if (post_hoc_method == "tukey" && method_used != "anova") {
    return(NULL)
  }
  if (post_hoc_method == "welch" && method_used == "kruskal") {
    return(NULL)
  }
  if (post_hoc_method == "wilcox" && method_used %in% c("anova", "welch")) {
    return(NULL)
  }

  if (post_hoc_method == "tukey") {
    # Reuse the ANOVA fit object from omnibus_result to avoid recomputation
    fit <- omnibus_result$fit
    tukey <- stats::TukeyHSD(fit, conf.level = conf.level)
    tbl <- tibble::as_tibble(
      as.data.frame(tukey[[1]]),
      rownames = "comparison"
    )
    # Use regex to split on the LAST hyphen, handling group names that contain hyphens
    # Pattern: "-(?=[^-]*$)" matches the last hyphen (negative lookahead for any hyphen after it)
    tbl <- tidyr::separate(tbl, .data$comparison, into = c("group2", "group1"), sep = "-(?=[^-]*$)", remove = TRUE)

    if (verbose) {
      cli::cli_alert_info("Applied Tukey HSD post-hoc comparisons.")
    }

    return(list(
      method = "tukey",
      table = tbl,
      raw = tukey
    ))
  }

  if (post_hoc_method == "welch") {
    test <- stats::pairwise.t.test(df$value, df$group, p.adjust.method = "BH", pool.sd = FALSE)
    tbl <- .tidy_pairwise_matrix(test$p.value)

    if (verbose) {
      cli::cli_alert_info("Applied Welch-style pairwise t-tests with BH adjustment.")
    }

    return(list(
      method = "welch",
      table = tbl,
      raw = test
    ))
  }

  if (post_hoc_method == "wilcox") {
    test <- stats::pairwise.wilcox.test(df$value, df$group, p.adjust.method = "BH", exact = FALSE)
    tbl <- .tidy_pairwise_matrix(test$p.value)

    if (verbose) {
      cli::cli_alert_info("Applied pairwise Wilcoxon tests with BH adjustment.")
    }

    return(list(
      method = "wilcox",
      table = tbl,
      raw = test
    ))
  }

  cli::cli_alert_warning("Unsupported post-hoc method {.val {post_hoc_method}}. Skipping.")
  NULL
}

.tidy_pairwise_matrix <- function(mat) {
  if (is.null(mat)) {
    return(NULL)
  }

  df <- as.data.frame(as.table(mat), stringsAsFactors = FALSE)
  colnames(df) <- c("group1", "group2", "p.adjusted")
  df <- df[!is.na(df$p.adjusted), , drop = FALSE]
  tibble::as_tibble(df)
}

.compute_anova_effect_size <- function(fit) {
  summary_tbl <- summary(fit)[[1]]
  ss_between <- summary_tbl[1, "Sum Sq"]
  ss_within <- summary_tbl[2, "Sum Sq"]
  df_between <- summary_tbl[1, "Df"]
  df_within <- summary_tbl[2, "Df"]
  ms_within <- ss_within / df_within

  ss_total <- ss_between + ss_within
  eta_sq <- ss_between / ss_total
  omega_sq <- (ss_between - df_between * ms_within) / (ss_total + ms_within)

  list(
    eta_squared = max(0, eta_sq),
    omega_squared = max(0, omega_sq)
  )
}

.compute_kruskal_effect_size <- function(test, n, k) {
  # Use epsilon squared (ε²) as the standard effect size for Kruskal-Wallis
  # Formula: ε² = H / (n² - 1)
  # Where H is the Kruskal-Wallis statistic and n is the total sample size
  # Reference: Tomczak & Tomczak (2014). The need to report effect size estimates revisited.
  H <- unname(test$statistic)
  epsilon_sq <- H / ((n * n) - 1)

  list(
    epsilon_squared = max(0, min(1, epsilon_sq))  # Bound between 0 and 1
  )
}

.create_anova_plot <- function(data,
                               group_levels,
                               plot_type,
                               add_jitter,
                               point_size,
                               point_alpha,
                               palette,
                               show_p_value,
                               p_value,
                               p_label,
                               method_used,
                               statistic_value,
                               descriptive_stats,
                               group_name,
                               value_name) {

  colors <- NULL
  if (!is.null(palette)) {
    colors <- tryCatch(
      {
        cols <- get_palette(palette, type = "qualitative")
        if (length(cols) < length(group_levels)) {
          cols <- rep(cols, length.out = length(group_levels))
        }
        cols
      },
      error = function(e) {
        cli::cli_alert_warning("Could not load palette {.val {palette}}. Using defaults.")
        NULL
      }
    )
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

  if (add_jitter) {
    p <- p + ggplot2::geom_jitter(
      width = 0.15,
      size = point_size,
      alpha = point_alpha,
      show.legend = FALSE
    )
  }

  if (!is.null(colors)) {
    p <- p + ggplot2::scale_fill_manual(values = colors)
  }

  # Add simple text in top-right corner
  if (show_p_value) {
    # Method name
    method_name <- switch(
      method_used,
      anova = "One-way ANOVA",
      welch = "Welch ANOVA",
      kruskal = "Kruskal-Wallis",
      method_used
    )

    # P-value formatting
    if (p_label == "p.signif") {
      # Only show stars, no p-value
      if (p_value < 0.001) {
        p_text <- "***"
      } else if (p_value < 0.01) {
        p_text <- "**"
      } else if (p_value < 0.05) {
        p_text <- "*"
      } else {
        p_text <- "ns"
      }
    } else {
      # Show p-value, no stars
      if (p_value < 0.0001) {
        p_text <- sprintf("p = %.2e", p_value)
      } else {
        p_text <- sprintf("p = %.4f", p_value)
      }
    }

    # Two lines: method and p-value
    label_text <- paste0(method_name, "\n", p_text)

    # Add text annotation in top-right corner
    p <- p + ggplot2::annotate(
      "text",
      x = Inf,
      y = Inf,
      label = label_text,
      hjust = 1.05,
      vjust = 1.2,
      size = 4,
      fontface = "bold",
      lineheight = 1.1,
      color = "black"
    )
  }

  p <- p +
    ggpubr::theme_pubr(base_size = 14) +
    ggplot2::theme(
      legend.position = "none",
      plot.subtitle = ggplot2::element_text(
        size = 14,
        hjust = 0,
        color = "black",
        face = "bold",
        margin = ggplot2::margin(b = 12)
      ),
      plot.title = ggplot2::element_text(size = 16, hjust = 0, face = "bold"),
      axis.title = ggplot2::element_text(size = 13, face = "bold", color = "black"),
      axis.text = ggplot2::element_text(size = 12, color = "gray20"),
      panel.grid.major.y = ggplot2::element_line(color = "gray90", linewidth = 0.3),
      panel.grid.minor.y = ggplot2::element_blank()
    ) +
    ggplot2::labs(
      x = group_name,
      y = value_name
    ) +
    ggplot2::coord_cartesian(clip = "off")

  p
}

#' @export
print.quick_anova_result <- function(x, ...) {
  # Print the plot safely
  if (!is.null(x$plot)) {
    tryCatch({
      print(x$plot)
    }, error = function(e) {
      warning("Could not print plot: ", e$message)
    })
  }

  cat("\n")
  cli::cli_h2("Quick ANOVA Results")
  cli::cli_text("")
  cli::cli_alert_info("Method: {x$method_used}")

  p_val <- x$omnibus_result$p_value
  p_display <- if (p_val < 0.001) "p < 0.001" else sprintf("p = %.4f", p_val)

  if (p_val < 0.05) {
    cli::cli_alert_success("Significant group differences ({p_display})")
  } else {
    cli::cli_alert_info("No significant group differences ({p_display})")
  }

  cli::cli_text("")
  cli::cli_h3("Descriptive Statistics")
  print(x$descriptive_stats)

  if (!is.null(x$post_hoc)) {
    cli::cli_text("")
    cli::cli_h3("Post-hoc Summary ({x$post_hoc$method})")
    print(x$post_hoc$table)
  }

  invisible(x)
}

#' @export
summary.quick_anova_result <- function(object, ...) {
  cat("\n")
  cli::cli_h2("Detailed Quick ANOVA Summary")
  cat("\n")

  cli::cli_h3("Omnibus Test")
  omni <- object$omnibus_result
  if (identical(omni$type, "anova")) {
    print(omni$summary)
  } else if (identical(omni$type, "welch")) {
    print(omni$test)
  } else {
    print(omni$test)
  }
  if (!is.null(omni$effect_size)) {
    cli::cli_text("")
    cli::cli_alert_info("Effect sizes: {paste(names(omni$effect_size), sprintf('%.3f', unlist(omni$effect_size)), collapse = ', ')}")
  }
  cat("\n")

  cli::cli_h3("Descriptive Statistics")
  print(object$descriptive_stats)
  cat("\n")

  if (!is.null(object$assumption_checks$normality)) {
    cli::cli_h3("Normality Checks (Shapiro-Wilk)")
    norm <- object$assumption_checks$normality
    for (grp in names(norm$tests)) {
      res <- norm$tests[[grp]]
      if (!is.null(res$p.value) && !is.na(res$p.value)) {
        p_fmt <- if (res$p.value < 0.001) "p < 0.001" else sprintf("p = %.4f", res$p.value)
        cli::cli_text("  {grp}: n = {res$n}, {p_fmt}")
      }
    }
    cli::cli_text("")
    cli::cli_alert_info("Decision: {norm$rationale}")
    cat("\n")
  }

  if (!is.null(object$assumption_checks$variance) && object$assumption_checks$variance$test_performed) {
    cli::cli_h3("Variance Equality (Levene)")
    vt <- object$assumption_checks$variance
    p_fmt <- if (vt$p_value < 0.001) "p < 0.001" else sprintf("p = %.4f", vt$p_value)
    cli::cli_text("Levene's test: {p_fmt}")
    cli::cli_text("Equal variance: {vt$equal_variance}")
    cat("\n")
  }

  if (!is.null(object$post_hoc)) {
    cli::cli_h3("Post-hoc Comparisons ({object$post_hoc$method})")
    print(object$post_hoc$table)
    cat("\n")
  }

  cli::cli_text("Analysis performed: {format(object$timestamp, '%Y-%m-%d %H:%M:%S')}")

  invisible(object)
}
