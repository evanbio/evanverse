#' Quick Chi-Square Test with Automatic Visualization
#'
#' Perform chi-square test of independence or Fisher's exact test (automatically
#' selected based on expected frequencies) with publication-ready visualization.
#' Designed for analyzing the association between two categorical variables.
#'
#' @param data A data frame containing the variables.
#' @param var1 Column name for the first categorical variable (row variable).
#'   Supports both quoted and unquoted names via NSE.
#' @param var2 Column name for the second categorical variable (column variable).
#'   Supports both quoted and unquoted names via NSE.
#' @param method Character. Test method: "auto" (default), "chisq", "fisher", or "mcnemar".
#'   When "auto", the function intelligently selects based on expected frequencies and table size.
#'   \strong{WARNING}: "mcnemar" is ONLY for paired/matched data (e.g., before-after measurements
#'   on the same subjects). It tests marginal homogeneity, NOT independence. Do NOT use McNemar's
#'   test for independent samples - use "chisq" or "fisher" instead.
#' @param correct Logical or \code{NULL}. Apply Yates' continuity correction?
#'   If \code{NULL} (default), automatically applied for 2x2 tables with expected frequencies < 10.
#' @param conf.level Numeric. Confidence level for the interval. Default is 0.95.
#' @param plot_type Character. Type of plot: "bar_grouped" (default),
#'   "bar_stacked", or "heatmap".
#' @param show_p_value Logical. Display p-value on the plot? Default is \code{TRUE}.
#' @param p_label Character. P-value label format: "p.format" (numeric p-value, default) or
#'   "p.signif" (stars).
#' @param palette Character. Color palette name from evanverse palettes.
#'   Default is "qual_vivid". Set to \code{NULL} to use ggplot2 defaults.
#' @param verbose Logical. Print diagnostic messages? Default is \code{TRUE}.
#' @param ... Additional arguments (currently unused, reserved for future extensions).
#'
#' @return An object of class \code{quick_chisq_result} containing:
#'   \describe{
#'     \item{plot}{A ggplot object with the association visualization}
#'     \item{test_result}{The htest object from \code{chisq.test()} or \code{fisher.test()}}
#'     \item{method_used}{Character string of the test method used}
#'     \item{contingency_table}{The contingency table (counts)}
#'     \item{expected_freq}{Matrix of expected frequencies}
#'     \item{pearson_residuals}{Pearson residuals for each cell}
#'     \item{effect_size}{Cramer's V effect size measure}
#'     \item{descriptive_stats}{Data frame with frequencies and proportions}
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
#'   The function uses an intelligent algorithm based on expected frequencies:
#'
#'   \itemize{
#'     \item \strong{All expected frequencies >= 5}: Standard chi-square test
#'     \item \strong{2x2 table with any expected frequency < 5}: Fisher's exact test
#'     \item \strong{Larger table with expected frequency < 5}: Chi-square with warning
#'     \item \strong{2x2 table with 5 <= expected frequency < 10}: Chi-square with Yates' correction
#'   }
#' }
#'
#' \subsection{Effect Size}{
#'   Cramer's V is calculated as a measure of effect size:
#'   \itemize{
#'     \item Small effect: V = 0.1
#'     \item Medium effect: V = 0.3
#'     \item Large effect: V = 0.5
#'   }
#' }
#'
#' \subsection{Pearson Residuals}{
#'   Pearson residuals are calculated for each cell as (observed - expected) / sqrt(expected):
#'   \itemize{
#'     \item Values > |2| indicate significant deviation from independence
#'     \item Values > |3| indicate very significant deviation
#'   }
#' }
#'
#' \subsection{Visualization Options}{
#'   \itemize{
#'     \item \strong{bar_grouped}: Grouped bar chart (default)
#'     \item \strong{bar_stacked}: Stacked bar chart (100\% stacked)
#'     \item \strong{heatmap}: Heatmap of Pearson residuals
#'   }
#' }
#'
#' @section Important Notes:
#'
#' \itemize{
#'   \item \strong{Categorical variables}: Both variables must be categorical or will be coerced to factors.
#'   \item \strong{Sample size}: Fisher's exact test may be computationally intensive for large tables.
#'   \item \strong{Missing values}: Automatically removed with a warning.
#'   \item \strong{Low frequencies}: Cells with expected frequency < 5 may lead to unreliable results.
#' }
#'
#' @examples
#' # Example 1: Basic usage with automatic method selection
#' set.seed(123)
#' data <- data.frame(
#'   treatment = sample(c("A", "B", "C"), 100, replace = TRUE),
#'   response = sample(c("Success", "Failure"), 100, replace = TRUE,
#'                     prob = c(0.6, 0.4))
#' )
#'
#' result <- quick_chisq(data, var1 = treatment, var2 = response)
#' print(result)
#'
#' # Example 2: 2x2 table
#' data_2x2 <- data.frame(
#'   gender = rep(c("Male", "Female"), each = 50),
#'   disease = sample(c("Yes", "No"), 100, replace = TRUE)
#' )
#'
#' result <- quick_chisq(data_2x2, var1 = gender, var2 = disease)
#'
#' # Example 3: Customize visualization
#' result <- quick_chisq(data,
#'                       var1 = treatment,
#'                       var2 = response,
#'                       plot_type = "bar_grouped",
#'                       palette = "qual_balanced")
#'
#' # Example 4: Manual method selection
#' result <- quick_chisq(data,
#'                       var1 = treatment,
#'                       var2 = response,
#'                       method = "chisq",
#'                       correct = FALSE)
#'
#' # Access components
#' result$plot                      # ggplot object
#' result$test_result               # htest object
#' result$contingency_table         # Contingency table
#' result$pearson_residuals         # Pearson residuals
#' summary(result)                  # Detailed summary
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @export
#' @seealso \code{\link[stats]{chisq.test}}, \code{\link[stats]{fisher.test}},
#'   \code{\link{quick_ttest}}, \code{\link{quick_anova}}
quick_chisq <- function(data,
                        var1,
                        var2,
                        method = c("auto", "chisq", "fisher", "mcnemar"),
                        correct = NULL,
                        conf.level = 0.95,
                        plot_type = c("bar_grouped", "bar_stacked", "heatmap"),
                        show_p_value = TRUE,
                        p_label = c("p.format", "p.signif"),
                        palette = "qual_vivid",
                        verbose = TRUE,
                        ...) {

  # Argument validation
  method <- match.arg(method)
  plot_type <- match.arg(plot_type)
  p_label <- match.arg(p_label)

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }
  if (!is.numeric(conf.level) || conf.level <= 0 || conf.level >= 1) {
    cli::cli_abort("{.arg conf.level} must be between 0 and 1.")
  }
  if (!is.logical(show_p_value) || length(show_p_value) != 1) {
    cli::cli_abort("{.arg show_p_value} must be TRUE or FALSE.")
  }
  if (!is.logical(verbose) || length(verbose) != 1) {
    cli::cli_abort("{.arg verbose} must be TRUE or FALSE.")
  }

  # Extract variable names
  var1_col <- rlang::ensym(var1)
  var2_col <- rlang::ensym(var2)
  var1_name <- rlang::as_string(var1_col)
  var2_name <- rlang::as_string(var2_col)

  if (!var1_name %in% names(data)) {
    cli::cli_abort("Column {.field {var1_name}} not found in {.arg data}.")
  }
  if (!var2_name %in% names(data)) {
    cli::cli_abort("Column {.field {var2_name}} not found in {.arg data}.")
  }

  # Prepare data
  df <- data[, c(var1_name, var2_name), drop = FALSE]
  colnames(df) <- c("var1", "var2")

  # Handle missing values
  n_missing <- sum(is.na(df$var1) | is.na(df$var2))
  if (n_missing > 0) {
    if (verbose) {
      cli::cli_alert_warning("Removed {n_missing} row{?s} with missing values.")
    }
    df <- df[stats::complete.cases(df), , drop = FALSE]
  }

  if (nrow(df) == 0) {
    cli::cli_abort("No valid data remaining after removing missing values.")
  }

  # Convert to factors if not already
  if (!is.factor(df$var1)) {
    df$var1 <- as.factor(as.character(df$var1))
    if (verbose) {
      cli::cli_alert_info("{.field {var1_name}} converted to factor with {nlevels(df$var1)} level{?s}.")
    }
  }
  if (!is.factor(df$var2)) {
    df$var2 <- as.factor(as.character(df$var2))
    if (verbose) {
      cli::cli_alert_info("{.field {var2_name}} converted to factor with {nlevels(df$var2)} level{?s}.")
    }
  }

  # Create contingency table
  cont_table <- table(df$var1, df$var2)
  n_total <- sum(cont_table)

  # Check table dimensions
  n_rows <- nrow(cont_table)
  n_cols <- ncol(cont_table)

  if (n_rows < 2 || n_cols < 2) {
    cli::cli_abort("Need at least 2 levels in each variable for chi-square test.")
  }

  # Calculate expected frequencies
  row_sums <- rowSums(cont_table)
  col_sums <- colSums(cont_table)
  expected_freq <- outer(row_sums, col_sums) / n_total

  # Check expected frequencies
  min_expected <- min(expected_freq)
  n_cells_below_5 <- sum(expected_freq < 5)
  prop_cells_below_5 <- n_cells_below_5 / length(expected_freq)

  # Automatic method selection
  auto_decision <- list(
    contingency_table_size = paste0(n_rows, "x", n_cols),
    total_n = n_total,
    min_expected_frequency = round(min_expected, 2),
    n_cells_below_5 = n_cells_below_5,
    prop_cells_below_5 = round(prop_cells_below_5, 3)
  )

  if (method == "auto") {
    if (n_rows == 2 && n_cols == 2 && min_expected < 5) {
      # 2x2 table with small expected frequencies -> Fisher's exact test
      method <- "fisher"
      auto_decision$reason <- "2x2 table with expected frequency < 5: using Fisher's exact test"
      if (verbose) {
        cli::cli_alert_info("2x2 table with expected freq < 5. Using Fisher's exact test.")
      }
    } else if (min_expected < 5 && prop_cells_below_5 > 0.2) {
      # More than 20% of cells have expected frequency < 5
      method <- "chisq"
      auto_decision$reason <- "More than 20% of cells have expected freq < 5: using chi-square with warning"
      if (verbose) {
        cli::cli_alert_warning("More than 20% of cells have expected freq < 5. Results may be unreliable.")
        cli::cli_alert_warning("Consider combining categories or using Fisher's exact test (may be slow for large tables).")
      }
    } else {
      # Standard chi-square test
      method <- "chisq"
      if (n_rows == 2 && n_cols == 2 && min_expected < 10) {
        # Apply Yates' correction for 2x2 tables with small expected frequencies
        if (is.null(correct)) {
          correct <- TRUE
          auto_decision$yates_correction <- TRUE
          auto_decision$reason <- "2x2 table with 5 <= expected freq < 10: applying Yates' correction"
          if (verbose) {
            cli::cli_alert_info("Applying Yates' continuity correction for 2x2 table.")
          }
        }
      } else {
        if (is.null(correct)) {
          correct <- FALSE
        }
        auto_decision$reason <- "All expected frequencies adequate: using standard chi-square test"
      }
    }
  } else {
    auto_decision$reason <- paste("User-specified method:", method)
    if (is.null(correct)) {
      correct <- FALSE
    }
  }

  # Perform the test
  timestamp <- Sys.time()

  if (method == "fisher") {
    test_result <- tryCatch({
      stats::fisher.test(cont_table, conf.level = conf.level)
    }, error = function(e) {
      cli::cli_alert_danger("Fisher's exact test failed: {e$message}")
      cli::cli_alert_info("Falling back to chi-square test.")
      stats::chisq.test(cont_table, correct = FALSE)
    })
    method_used <- "Fisher's exact test"
  } else if (method == "chisq") {
    test_result <- stats::chisq.test(cont_table, correct = correct)
    method_used <- if (correct) {
      "Chi-square test with Yates' correction"
    } else {
      "Chi-square test"
    }
  } else if (method == "mcnemar") {
    if (n_rows != n_cols) {
      cli::cli_abort("McNemar's test requires a square contingency table.")
    }
    test_result <- stats::mcnemar.test(cont_table, correct = correct)
    method_used <- "McNemar's test"
  }

  # Calculate Pearson residuals
  if (method == "chisq") {
    observed <- as.vector(cont_table)
    expected <- as.vector(expected_freq)
    pearson_resid <- (observed - expected) / sqrt(expected)
    pearson_resid_matrix <- matrix(pearson_resid, nrow = n_rows, ncol = n_cols)
    dimnames(pearson_resid_matrix) <- dimnames(cont_table)
  } else {
    pearson_resid_matrix <- NULL
  }

  # Calculate Cramer's V (effect size)
  if (!is.null(test_result$statistic)) {
    chi_sq <- as.numeric(test_result$statistic)
    min_dim <- min(n_rows - 1, n_cols - 1)
    cramers_v <- sqrt(chi_sq / (n_total * min_dim))

    # Interpret effect size
    if (cramers_v < 0.1) {
      effect_interpretation <- "negligible"
    } else if (cramers_v < 0.3) {
      effect_interpretation <- "small"
    } else if (cramers_v < 0.5) {
      effect_interpretation <- "medium"
    } else {
      effect_interpretation <- "large"
    }

    effect_size <- list(
      cramers_v = round(cramers_v, 3),
      interpretation = effect_interpretation
    )
  } else {
    effect_size <- NULL
  }

  # Descriptive statistics
  desc_stats <- as.data.frame.table(cont_table)
  colnames(desc_stats) <- c(var1_name, var2_name, "Count")
  desc_stats$Proportion <- desc_stats$Count / n_total
  desc_stats$Percent <- round(desc_stats$Proportion * 100, 2)

  # Create visualization
  plot <- .create_chisq_plot(
    df = df,
    cont_table = cont_table,
    pearson_residuals = pearson_resid_matrix,
    test_result = test_result,
    method_used = method_used,
    plot_type = plot_type,
    show_p_value = show_p_value,
    p_label = p_label,
    palette = palette,
    var1_name = var1_name,
    var2_name = var2_name,
    verbose = verbose
  )

  # Construct result object
  result <- list(
    plot = plot,
    test_result = test_result,
    method_used = method_used,
    contingency_table = cont_table,
    expected_freq = expected_freq,
    pearson_residuals = pearson_resid_matrix,
    effect_size = effect_size,
    descriptive_stats = desc_stats,
    auto_decision = auto_decision,
    timestamp = timestamp
  )

  class(result) <- "quick_chisq_result"
  return(result)
}


# Helper function to create plots
.create_chisq_plot <- function(df, cont_table, pearson_residuals, test_result, method_used,
                                plot_type, show_p_value, p_label, palette,
                                var1_name, var2_name, verbose = TRUE) {

  # Prepare data for plotting
  plot_data <- as.data.frame.table(cont_table)
  colnames(plot_data) <- c("var1", "var2", "Count")
  plot_data$var1 <- as.factor(plot_data$var1)
  plot_data$var2 <- as.factor(plot_data$var2)

  # Get colors
  colors <- NULL
  if (!is.null(palette)) {
    n_colors_needed <- nlevels(plot_data$var2)
    tryCatch({
      colors <- get_palette(palette, n = n_colors_needed)
      # Validate: check if we got enough colors
      if (is.null(colors) || length(colors) < n_colors_needed) {
        if (verbose) {
          cli::cli_alert_warning(
            "Palette '{palette}' provided insufficient colors ({length(colors)} of {n_colors_needed} needed). Using default colors."
          )
        }
        colors <- NULL
      }
    }, error = function(e) {
      if (verbose) {
        cli::cli_alert_warning(
          "Failed to load palette '{palette}': {e$message}. Using default colors."
        )
      }
      colors <- NULL
    })
  }

  # Create base plot based on plot_type
  if (plot_type == "bar_grouped") {
    p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$var1, y = .data$Count, fill = .data$var2)) +
      ggplot2::geom_bar(stat = "identity", position = "dodge", width = 0.7) +
      ggplot2::labs(
        x = var1_name,
        y = "Count",
        fill = var2_name
      ) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(
        legend.position = "right",
        panel.grid.major.x = ggplot2::element_blank()
      )
  } else if (plot_type == "bar_stacked") {
    # Calculate proportions for stacked bars
    plot_data <- plot_data %>%
      dplyr::group_by(.data$var1) %>%
      dplyr::mutate(Proportion = .data$Count / sum(.data$Count)) %>%
      dplyr::ungroup()

    p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = .data$var1, y = .data$Proportion, fill = .data$var2)) +
      ggplot2::geom_bar(stat = "identity", width = 0.7) +
      ggplot2::labs(
        x = var1_name,
        y = "Proportion",
        fill = var2_name
      ) +
      ggplot2::scale_y_continuous(labels = scales::percent) +
      ggplot2::theme_minimal(base_size = 12) +
      ggplot2::theme(
        legend.position = "right",
        panel.grid.major.x = ggplot2::element_blank()
      )
  } else if (plot_type == "heatmap") {
    # Heatmap of Pearson residuals
    if (!is.null(pearson_residuals)) {
      residual_data <- as.data.frame.table(pearson_residuals)
      colnames(residual_data) <- c("var1", "var2", "Residual")

      p <- ggplot2::ggplot(residual_data, ggplot2::aes(x = .data$var2, y = .data$var1, fill = .data$Residual)) +
        ggplot2::geom_tile(color = "white", linewidth = 0.5) +
        ggplot2::geom_text(ggplot2::aes(label = round(.data$Residual, 2)), size = 4) +
        ggplot2::scale_fill_gradient2(
          low = "#2166AC",
          mid = "white",
          high = "#B2182B",
          midpoint = 0,
          limits = c(-max(abs(residual_data$Residual)), max(abs(residual_data$Residual))),
          name = "Pearson Residual"
        ) +
        ggplot2::labs(
          x = var2_name,
          y = var1_name,
          title = "Pearson Residuals"
        ) +
        ggplot2::theme_minimal(base_size = 12) +
        ggplot2::theme(
          panel.grid = ggplot2::element_blank()
        )
    } else {
      cli::cli_alert_warning("Pearson residuals not available. Using grouped bar chart.")
      plot_type <- "bar_grouped"
      p <- .create_chisq_plot(df, cont_table, NULL, test_result, method_used,
                              "bar_grouped", show_p_value, p_label, palette,
                              var1_name, var2_name, verbose)
      return(p)
    }
  }

  # Apply color palette
  if (!is.null(colors) && plot_type != "heatmap") {
    p <- p + ggplot2::scale_fill_manual(values = colors)
  }

  # Add p-value annotation
  if (show_p_value && plot_type != "heatmap") {
    p_value <- test_result$p.value

    if (p_label == "p.format") {
      if (p_value < 0.001) {
        p_text <- "p < 0.001"
      } else {
        p_text <- paste0("p = ", format.pval(p_value, digits = 3))
      }
    } else {
      # p.signif
      if (p_value < 0.001) {
        p_text <- "***"
      } else if (p_value < 0.01) {
        p_text <- "**"
      } else if (p_value < 0.05) {
        p_text <- "*"
      } else {
        p_text <- "ns"
      }
    }

    p <- p + ggplot2::labs(
      title = method_used,
      subtitle = p_text
    )
  } else {
    p <- p + ggplot2::labs(
      title = method_used
    )
  }

  return(p)
}


#' Print Method for quick_chisq_result
#'
#' @param x An object of class \code{quick_chisq_result}
#' @param ... Additional arguments (unused)
#' @export
print.quick_chisq_result <- function(x, ...) {
  # Print the plot safely
  if (!is.null(x$plot)) {
    tryCatch({
      print(x$plot)
    }, error = function(e) {
      warning("Could not print plot: ", e$message)
    })
  }

  # Print statistical summary
  cat("\n")
  cat("===========================================================\n")
  cat("  Quick Chi-Square Test Result\n")
  cat("===========================================================\n\n")

  cat("Method:", x$method_used, "\n")
  cat("Test statistic:", round(x$test_result$statistic, 3), "\n")

  if (!is.null(x$test_result$parameter)) {
    cat("Degrees of freedom:", x$test_result$parameter, "\n")
  }

  cat("P-value:", format.pval(x$test_result$p.value, digits = 4), "\n\n")

  # Effect size
  if (!is.null(x$effect_size)) {
    cat("Effect Size (Cramer's V):", x$effect_size$cramers_v,
        "(", x$effect_size$interpretation, ")\n\n")
  }

  # Contingency table
  cat("Contingency Table:\n")
  print(x$contingency_table)
  cat("\n")

  # Auto decision
  if (!is.null(x$auto_decision$reason)) {
    cat("Decision:", x$auto_decision$reason, "\n")
  }

  cat("\nTimestamp:", format(x$timestamp, "%Y-%m-%d %H:%M:%S"), "\n")
  cat("===========================================================\n")

  invisible(x)
}


#' Summary Method for quick_chisq_result
#'
#' @param object An object of class \code{quick_chisq_result}
#' @param ... Additional arguments (unused)
#' @export
summary.quick_chisq_result <- function(object, ...) {
  cat("===========================================================\n")
  cat("  Quick Chi-Square Test - Detailed Summary\n")
  cat("===========================================================\n\n")

  # Test information
  cat("Method:", object$method_used, "\n")
  cat("Timestamp:", format(object$timestamp, "%Y-%m-%d %H:%M:%S"), "\n\n")

  # Test results
  cat("-----------------------------------------------------------\n")
  cat("Test Results:\n")
  cat("-----------------------------------------------------------\n")
  print(object$test_result)
  cat("\n")

  # Effect size
  if (!is.null(object$effect_size)) {
    cat("-----------------------------------------------------------\n")
    cat("Effect Size:\n")
    cat("-----------------------------------------------------------\n")
    cat("Cramer's V:", object$effect_size$cramers_v, "\n")
    cat("Interpretation:", object$effect_size$interpretation, "\n\n")
  }

  # Contingency table
  cat("-----------------------------------------------------------\n")
  cat("Observed Frequencies:\n")
  cat("-----------------------------------------------------------\n")
  print(object$contingency_table)
  cat("\n")

  # Expected frequencies
  cat("-----------------------------------------------------------\n")
  cat("Expected Frequencies:\n")
  cat("-----------------------------------------------------------\n")
  print(round(object$expected_freq, 2))
  cat("\n")

  # Pearson residuals
  if (!is.null(object$pearson_residuals)) {
    cat("-----------------------------------------------------------\n")
    cat("Pearson Residuals:\n")
    cat("-----------------------------------------------------------\n")
    print(round(object$pearson_residuals, 2))
    cat("\nNote: Values > |2| indicate significant deviation from independence\n\n")
  }

  # Descriptive statistics
  cat("-----------------------------------------------------------\n")
  cat("Descriptive Statistics:\n")
  cat("-----------------------------------------------------------\n")
  print(object$descriptive_stats)
  cat("\n")

  # Auto decision details
  if (!is.null(object$auto_decision)) {
    cat("-----------------------------------------------------------\n")
    cat("Method Selection Details:\n")
    cat("-----------------------------------------------------------\n")
    cat("Table size:", object$auto_decision$contingency_table_size, "\n")
    cat("Total N:", object$auto_decision$total_n, "\n")
    cat("Minimum expected frequency:", object$auto_decision$min_expected_frequency, "\n")
    cat("Cells with expected freq < 5:", object$auto_decision$n_cells_below_5, "\n")
    cat("Proportion of cells < 5:", object$auto_decision$prop_cells_below_5, "\n")
    cat("Reason:", object$auto_decision$reason, "\n")
  }

  cat("\n===========================================================\n")

  invisible(object)
}
