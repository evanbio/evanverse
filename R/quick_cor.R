#' Quick Correlation Analysis with Heatmap Visualization
#'
#' Perform correlation analysis with automatic p-value calculation and
#' publication-ready heatmap visualization. Supports multiple correlation
#' methods and significance testing with optional multiple testing correction.
#'
#' @param data A data frame containing numeric variables.
#' @param vars Optional character vector specifying which variables to include.
#'   If \code{NULL} (default), all numeric columns will be used.
#' @param method Character. Correlation method: "pearson" (default), "spearman",
#'   or "kendall".
#' @param use Character. Method for handling missing values, passed to \code{cor()}.
#'   Default is "pairwise.complete.obs". Other options: "everything",
#'   "all.obs", "complete.obs", "na.or.complete".
#' @param p_adjust_method Character. Method for p-value adjustment for multiple
#'   testing. Default is "none". Options: "holm", "hochberg", "hommel",
#'   "bonferroni", "BH", "BY", "fdr", "none". See \code{\link[stats]{p.adjust}}.
#' @param sig_level Numeric vector. Significance levels for star annotations.
#'   Default is \code{c(0.001, 0.01, 0.05)} corresponding to ***, **, *.
#' @param type Character. Type of heatmap: "full" (default), "upper", or "lower".
#' @param show_coef Logical. Display correlation coefficients on the heatmap?
#'   Default is \code{FALSE}.
#' @param show_sig Logical. Display significance stars on the heatmap?
#'   Default is \code{TRUE}.
#' @param hc_order Logical. Reorder variables using hierarchical clustering?
#'   Default is \code{TRUE}.
#' @param hc_method Character. Hierarchical clustering method if \code{hc_order = TRUE}.
#'   Default is "complete". See \code{\link[stats]{hclust}}.
#' @param palette Character. Color palette name from evanverse palettes.
#'   Default is "gradient_rd_bu" (diverging Red-Blue palette, recommended for
#'   correlation matrices). Set to \code{NULL} to use ggplot2 defaults.
#'   Other diverging options: "piyg", "earthy_diverge", "fire_ice_duo".
#' @param lab_size Numeric. Size of coefficient labels if \code{show_coef = TRUE}.
#'   Default is 3.
#' @param title Character. Plot title. Default is \code{NULL} (no title).
#' @param show_axis_x Logical. Display x-axis labels? Default is \code{TRUE}.
#' @param show_axis_y Logical. Display y-axis labels? Default is \code{TRUE}.
#' @param axis_x_angle Numeric. Rotation angle for x-axis labels in degrees.
#'   Default is 45. Common values: 0 (horizontal), 45 (diagonal), 90 (vertical).
#' @param axis_y_angle Numeric. Rotation angle for y-axis labels in degrees.
#'   Default is 0 (horizontal).
#' @param axis_text_size Numeric. Font size for axis labels. Default is 10.
#' @param verbose Logical. Print diagnostic messages? Default is \code{TRUE}.
#' @param ... Additional arguments (currently unused, reserved for future extensions).
#'
#' @return An object of class \code{quick_cor_result} containing:
#'   \describe{
#'     \item{plot}{A ggplot object with the correlation heatmap}
#'     \item{cor_matrix}{Correlation coefficient matrix}
#'     \item{p_matrix}{P-value matrix (unadjusted)}
#'     \item{p_adjusted}{Adjusted p-value matrix (if p_adjust_method != "none")}
#'     \item{method_used}{Correlation method used}
#'     \item{significant_pairs}{Data frame of significant correlation pairs}
#'     \item{descriptive_stats}{Descriptive statistics for each variable}
#'     \item{parameters}{List of analysis parameters}
#'     \item{timestamp}{POSIXct timestamp of analysis}
#'   }
#'
#' @details
#' \strong{"Quick" means easy to use, not simplified or inaccurate.}
#'
#' This function performs complete correlation analysis with proper statistical testing:
#'
#' \subsection{Correlation Methods}{
#'   \itemize{
#'     \item \strong{Pearson}: Measures linear relationships, assumes normality
#'     \item \strong{Spearman}: Rank-based, robust to outliers and non-normality
#'     \item \strong{Kendall}: Rank-based, better for small samples or many ties
#'   }
#' }
#'
#' \subsection{P-value Calculation}{
#'   P-values are calculated for each pairwise correlation. The function
#'   automatically uses \code{psych::corr.test()} if the \code{psych} package
#'   is installed, which provides significantly faster computation (10-100x speedup
#'   for large matrices) compared to the base R \code{stats::cor.test()} loop.
#'   If \code{psych} is not available, the function gracefully falls back to the
#'   base R implementation.
#'
#'   For large correlation matrices with many tests, consider using
#'   \code{p_adjust_method} to control for multiple testing (e.g., "bonferroni"
#'   or "fdr").
#'
#'   \strong{Performance tip}: Install the \code{psych} package for faster
#'   p-value computation:
#'   \code{install.packages("psych")}
#' }
#'
#' \subsection{Visualization}{
#'   The heatmap includes:
#'   \itemize{
#'     \item Color-coded correlation coefficients (red = positive, blue = negative)
#'     \item Optional significance stars (***, **, *)
#'     \item Optional coefficient values
#'     \item Hierarchical clustering to group similar variables
#'     \item Publication-ready styling
#'   }
#' }
#'
#' @section Important Notes:
#'
#' \itemize{
#'   \item \strong{Numeric variables only}: The function automatically selects
#'     numeric columns or uses the variables specified in \code{vars}.
#'   \item \strong{Constant variables}: Variables with zero variance are
#'     automatically removed with a warning.
#'   \item \strong{Sample size}: The function will warn if sample sizes are
#'     very small (n < 5) after removing missing values.
#'   \item \strong{Missing values}: Handled according to the \code{use} parameter.
#'     "pairwise.complete.obs" is recommended for optimal sample size usage.
#'   \item \strong{Optional dependencies}: For optimal performance, install
#'     \code{psych} (fast p-value computation) and \code{ggcorrplot} (heatmap
#'     visualization). The function will work without them but may be slower
#'     or use fallback plotting.
#' }
#'
#' @examples
#' # Example 1: Basic correlation analysis
#' result <- quick_cor(mtcars)
#' print(result)
#'
#' # Example 2: Spearman correlation with specific variables
#' result <- quick_cor(
#'   mtcars,
#'   vars = c("mpg", "hp", "wt", "qsec"),
#'   method = "spearman"
#' )
#'
#' # Example 3: Upper triangular with Bonferroni correction
#' result <- quick_cor(
#'   iris,
#'   type = "upper",
#'   p_adjust_method = "bonferroni",
#'   show_coef = TRUE
#' )
#'
#' # Example 4: Custom palette and title
#' result <- quick_cor(
#'   mtcars,
#'   palette = "gradient_rd_bu",
#'   title = "Correlation Matrix of mtcars Dataset",
#'   hc_order = TRUE
#' )
#'
#' # Example 5: Customize axis labels
#' result <- quick_cor(
#'   mtcars,
#'   axis_x_angle = 90,      # Vertical x-axis labels
#'   axis_text_size = 12,    # Larger text
#'   show_axis_y = FALSE     # Hide y-axis labels
#' )
#'
#' # Access components
#' result$plot                 # ggplot object
#' result$cor_matrix           # Correlation matrix
#' result$significant_pairs    # Significant pairs
#' summary(result)             # Detailed summary
#'
#' @importFrom magrittr %>%
#' @importFrom rlang .data
#' @importFrom stats cor cor.test p.adjust hclust dist var
#' @importFrom utils head
#' @export
#' @seealso
#' \code{\link[stats]{cor}}, \code{\link[stats]{cor.test}}
quick_cor <- function(data,
                      vars = NULL,
                      method = c("pearson", "spearman", "kendall"),
                      use = "pairwise.complete.obs",
                      p_adjust_method = c("none", "holm", "hochberg", "hommel",
                                          "bonferroni", "BH", "BY", "fdr"),
                      sig_level = c(0.001, 0.01, 0.05),
                      type = c("full", "upper", "lower"),
                      show_coef = FALSE,
                      show_sig = TRUE,
                      hc_order = TRUE,
                      hc_method = "complete",
                      palette = "gradient_rd_bu",
                      lab_size = 3,
                      title = NULL,
                      show_axis_x = TRUE,
                      show_axis_y = TRUE,
                      axis_x_angle = 45,
                      axis_y_angle = 0,
                      axis_text_size = 10,
                      verbose = TRUE,
                      ...) {

  # ===========================================================================
  # 1. Parameter Validation & Setup
  # ===========================================================================

  # Match arguments
  method <- match.arg(method)
  type <- match.arg(type)
  p_adjust_method <- match.arg(p_adjust_method)

  # Validate basic inputs
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame.")
  }

  if (!is.logical(verbose) || length(verbose) != 1) {
    cli::cli_abort("{.arg verbose} must be TRUE or FALSE.")
  }

  if (!is.logical(show_coef) || length(show_coef) != 1) {
    cli::cli_abort("{.arg show_coef} must be TRUE or FALSE.")
  }

  if (!is.logical(show_sig) || length(show_sig) != 1) {
    cli::cli_abort("{.arg show_sig} must be TRUE or FALSE.")
  }

  if (!is.logical(hc_order) || length(hc_order) != 1) {
    cli::cli_abort("{.arg hc_order} must be TRUE or FALSE.")
  }

  if (!is.numeric(sig_level) || any(sig_level <= 0) || any(sig_level >= 1)) {
    cli::cli_abort("{.arg sig_level} must be numeric values between 0 and 1.")
  }

  # Sort sig_level in ascending order
  sig_level <- sort(sig_level)

  # Check show_coef and show_sig mutual exclusivity
  if (show_coef && show_sig) {
    if (verbose) {
      cli::cli_alert_warning(
        "Both {.arg show_coef} and {.arg show_sig} are TRUE. Setting {.arg show_sig} to FALSE to avoid overlapping labels."
      )
    }
    show_sig <- FALSE
  }

  # ===========================================================================
  # 2. Data Preparation
  # ===========================================================================

  if (verbose) {
    cli::cli_h2("Data Preparation")
  }

  # Select variables
  if (is.null(vars)) {
    # Automatically select numeric columns
    numeric_cols <- sapply(data, is.numeric)
    if (sum(numeric_cols) == 0) {
      cli::cli_abort("No numeric columns found in {.arg data}.")
    }
    df <- data[, numeric_cols, drop = FALSE]
    if (verbose) {
      cli::cli_alert_info(
        "Automatically selected {sum(numeric_cols)} numeric column{?s}."
      )
    }
  } else {
    # Use specified variables
    if (!is.character(vars)) {
      cli::cli_abort("{.arg vars} must be a character vector.")
    }

    missing_vars <- setdiff(vars, names(data))
    if (length(missing_vars) > 0) {
      n_missing <- length(missing_vars)
      cli::cli_abort(
        c(
          "{n_missing} variable{?s} not found in {.arg data}:",
          "x" = "{.val {missing_vars}}"
        )
      )
    }

    df <- data[, vars, drop = FALSE]

    # Check if all selected variables are numeric
    non_numeric <- !sapply(df, is.numeric)
    if (any(non_numeric)) {
      cli::cli_abort(
        c(
          "All variables must be numeric.",
          "x" = "Non-numeric: {.val {names(df)[non_numeric]}}"
        )
      )
    }

    if (verbose) {
      cli::cli_alert_info("Using {length(vars)} specified variable{?s}.")
    }
  }

  # Check minimum number of variables
  if (ncol(df) < 2) {
    cli::cli_abort(
      "At least 2 numeric variables are required for correlation analysis."
    )
  }

  # Remove constant variables (zero variance)
  var_check <- sapply(df, function(x) {
    var(x, na.rm = TRUE)
  })

  constant_vars <- names(var_check)[var_check == 0 | is.na(var_check)]

  if (length(constant_vars) > 0) {
    if (verbose) {
      cli::cli_alert_warning(
        "Removed {length(constant_vars)} constant variable{?s}: {.val {constant_vars}}"
      )
    }
    df <- df[, !names(df) %in% constant_vars, drop = FALSE]
  }

  # Final check
  if (ncol(df) < 2) {
    cli::cli_abort(
      "At least 2 non-constant variables remain after removing constant columns."
    )
  }

  # Check sample size
  n_obs <- nrow(df)
  if (n_obs < 5) {
    cli::cli_alert_warning(
      "Very small sample size (n = {n_obs}). Results may be unreliable."
    )
  }

  # ===========================================================================
  # 3. Compute Correlation Matrix and P-values
  # ===========================================================================

  if (verbose) {
    cli::cli_h2("Computing Correlations")
  }

  cor_results <- .compute_correlation_matrix(
    df = df,
    method = method,
    use = use,
    verbose = verbose
  )

  cor_matrix <- cor_results$cor_matrix
  p_matrix <- cor_results$p_matrix

  # Apply multiple testing correction if requested
  if (p_adjust_method != "none") {
    if (verbose) {
      cli::cli_alert_info(
        "Applying {p_adjust_method} correction for multiple testing..."
      )
    }

    # Extract upper triangle p-values (excluding diagonal)
    p_vec <- p_matrix[upper.tri(p_matrix)]
    p_adj_vec <- stats::p.adjust(p_vec, method = p_adjust_method)

    # Create adjusted p-value matrix
    p_adjusted <- matrix(NA, nrow = nrow(p_matrix), ncol = ncol(p_matrix))
    rownames(p_adjusted) <- rownames(p_matrix)
    colnames(p_adjusted) <- colnames(p_matrix)

    # Fill upper triangle
    p_adjusted[upper.tri(p_adjusted)] <- p_adj_vec
    # Mirror to lower triangle
    p_adjusted[lower.tri(p_adjusted)] <- t(p_adjusted)[lower.tri(p_adjusted)]
    # Diagonal is NA (self-correlation p-value is meaningless)
    diag(p_adjusted) <- NA

  } else {
    p_adjusted <- NULL
  }

  # ===========================================================================
  # 4. Identify Significant Pairs
  # ===========================================================================

  # Use adjusted p-values if available, otherwise use original
  p_for_sig <- if (!is.null(p_adjusted)) p_adjusted else p_matrix

  # Extract significant pairs
  sig_pairs_list <- list()
  for (i in 1:(nrow(cor_matrix) - 1)) {
    for (j in (i + 1):ncol(cor_matrix)) {
      var1 <- rownames(cor_matrix)[i]
      var2 <- colnames(cor_matrix)[j]
      r <- cor_matrix[i, j]
      p <- p_for_sig[i, j]

      if (!is.na(p) && p < max(sig_level)) {
        sig_pairs_list[[length(sig_pairs_list) + 1]] <- data.frame(
          var1 = var1,
          var2 = var2,
          correlation = r,
          p_value = p,
          stringsAsFactors = FALSE
        )
      }
    }
  }

  if (length(sig_pairs_list) > 0) {
    significant_pairs <- do.call(rbind, sig_pairs_list)
    significant_pairs <- significant_pairs[order(significant_pairs$p_value), ]
    rownames(significant_pairs) <- NULL
  } else {
    significant_pairs <- data.frame(
      var1 = character(0),
      var2 = character(0),
      correlation = numeric(0),
      p_value = numeric(0)
    )
  }

  if (verbose) {
    n_tests <- choose(ncol(df), 2)
    n_sig <- nrow(significant_pairs)
    cli::cli_alert_info(
      "Found {n_sig} significant correlation{?s} out of {n_tests} test{?s}"
    )

    # Warn about highly correlated pairs
    if (n_sig > 0) {
      high_cor <- significant_pairs[abs(significant_pairs$correlation) > 0.9, ]
      if (nrow(high_cor) > 0) {
        cli::cli_alert_warning(
          "Found {nrow(high_cor)} pair{?s} with |r| > 0.9 (potential multicollinearity)"
        )
      }
    }
  }

  # ===========================================================================
  # 5. Descriptive Statistics
  # ===========================================================================

  desc_stats <- data.frame(
    variable = names(df),
    n = sapply(df, function(x) sum(!is.na(x))),
    mean = sapply(df, mean, na.rm = TRUE),
    sd = sapply(df, sd, na.rm = TRUE),
    median = sapply(df, median, na.rm = TRUE),
    min = sapply(df, min, na.rm = TRUE),
    max = sapply(df, max, na.rm = TRUE),
    stringsAsFactors = FALSE
  )
  rownames(desc_stats) <- NULL

  # ===========================================================================
  # 6. Create Heatmap Visualization
  # ===========================================================================

  if (verbose) {
    cli::cli_h2("Creating Heatmap")
  }

  plot_obj <- .create_cor_heatmap(
    cor_matrix = cor_matrix,
    p_matrix = p_for_sig,
    type = type,
    show_coef = show_coef,
    show_sig = show_sig,
    sig_level = sig_level,
    hc_order = hc_order,
    hc_method = hc_method,
    palette = palette,
    lab_size = lab_size,
    title = title,
    show_axis_x = show_axis_x,
    show_axis_y = show_axis_y,
    axis_x_angle = axis_x_angle,
    axis_y_angle = axis_y_angle,
    axis_text_size = axis_text_size,
    verbose = verbose
  )

  # ===========================================================================
  # 7. Construct Return Object
  # ===========================================================================

  result <- structure(
    list(
      plot = plot_obj,
      cor_matrix = cor_matrix,
      p_matrix = p_matrix,
      p_adjusted = p_adjusted,
      method_used = method,
      significant_pairs = significant_pairs,
      descriptive_stats = desc_stats,
      parameters = list(
        use = use,
        p_adjust_method = p_adjust_method,
        sig_level = sig_level,
        type = type,
        hc_order = hc_order
      ),
      timestamp = Sys.time()
    ),
    class = "quick_cor_result"
  )

  if (verbose) {
    cli::cli_alert_success("Analysis complete!")
  }

  return(result)
}


# =============================================================================
# Internal Helper Functions
# =============================================================================

#' Compute Correlation Matrix and P-values
#'
#' @param df Data frame with numeric columns
#' @param method Correlation method
#' @param use Missing value handling method
#' @param verbose Print messages?
#' @return List with cor_matrix and p_matrix
#' @keywords internal
#' @noRd
.compute_correlation_matrix <- function(df, method, use, verbose = TRUE) {

  # Compute correlation matrix
  cor_matrix <- stats::cor(df, use = use, method = method)

  # Try to use psych::corr.test() for efficient p-value computation
  if (requireNamespace("psych", quietly = TRUE)) {
    # psych::corr.test is much faster than loop-based cor.test
    tryCatch({
      corr_result <- psych::corr.test(df, use = use, method = method, adjust = "none")
      p_matrix <- corr_result$p

      # Diagonal should be NA (self-correlation p-value is meaningless)
      diag(p_matrix) <- NA

      return(list(
        cor_matrix = cor_matrix,
        p_matrix = p_matrix
      ))
    }, error = function(e) {
      if (verbose) {
        cli::cli_alert_warning(
          "psych::corr.test() failed. Falling back to stats::cor.test()."
        )
      }
      # Fall through to manual calculation below
    })
  }

  # Fallback: Manual p-value calculation using cor.test (slower but robust)
  n_vars <- ncol(df)
  p_matrix <- matrix(NA, nrow = n_vars, ncol = n_vars)
  rownames(p_matrix) <- colnames(df)
  colnames(p_matrix) <- colnames(df)

  # Calculate p-values for each pair
  for (i in 1:(n_vars - 1)) {
    for (j in (i + 1):n_vars) {
      # Get complete cases for this pair
      pair_data <- df[, c(i, j)]
      complete_idx <- stats::complete.cases(pair_data)
      x <- pair_data[complete_idx, 1]
      y <- pair_data[complete_idx, 2]

      if (length(x) >= 3) {
        # Need at least 3 observations for cor.test
        test_result <- tryCatch(
          stats::cor.test(x, y, method = method),
          error = function(e) NULL
        )

        if (!is.null(test_result)) {
          p_matrix[i, j] <- test_result$p.value
          p_matrix[j, i] <- test_result$p.value
        }
      }
    }
  }

  # Diagonal is 1 (self-correlation), p-value is NA
  diag(p_matrix) <- NA

  return(list(
    cor_matrix = cor_matrix,
    p_matrix = p_matrix
  ))
}


#' Create Correlation Heatmap
#'
#' @param cor_matrix Correlation matrix
#' @param p_matrix P-value matrix
#' @param type Heatmap type (full, upper, lower)
#' @param show_coef Show coefficient values?
#' @param show_sig Show significance stars?
#' @param sig_level Significance levels
#' @param hc_order Use hierarchical clustering?
#' @param hc_method Clustering method
#' @param palette Palette name
#' @param lab_size Label size
#' @param title Plot title
#' @param show_axis_x Show x-axis labels?
#' @param show_axis_y Show y-axis labels?
#' @param axis_x_angle X-axis label angle
#' @param axis_y_angle Y-axis label angle
#' @param axis_text_size Axis label size
#' @param verbose Print messages?
#' @return ggplot object
#' @keywords internal
#' @noRd
.create_cor_heatmap <- function(cor_matrix, p_matrix, type, show_coef, show_sig,
                                 sig_level, hc_order, hc_method, palette,
                                 lab_size, title, show_axis_x, show_axis_y,
                                 axis_x_angle, axis_y_angle, axis_text_size,
                                 verbose = TRUE) {

  # Check if ggcorrplot is available
  if (!requireNamespace("ggcorrplot", quietly = TRUE)) {
    cli::cli_abort(
      c(
        "Package {.pkg ggcorrplot} is required for correlation heatmaps.",
        "i" = "Install it with: install.packages('ggcorrplot')"
      )
    )
  }

  # Get colors
  color_vec <- NULL
  if (!is.null(palette)) {
    tryCatch({
      # For correlation heatmap, try to get diverging palette
      # First try as diverging type
      color_vec <- tryCatch(
        get_palette(palette, type = "diverging"),
        error = function(e) NULL
      )

      # If that fails, try other types
      if (is.null(color_vec) || length(color_vec) < 3) {
        color_vec <- tryCatch(
          get_palette(palette, type = "sequential"),
          error = function(e) NULL
        )
      }

      if (is.null(color_vec) || length(color_vec) < 3) {
        color_vec <- tryCatch(
          get_palette(palette, type = "qualitative"),
          error = function(e) NULL
        )
      }

      # Need at least 3 colors for diverging scale
      if (!is.null(color_vec) && length(color_vec) < 3) {
        color_vec <- NULL
      }
    }, error = function(e) {
      if (verbose) {
        cli::cli_alert_warning("Could not load palette {.val {palette}}. Using defaults.")
      }
      color_vec <- NULL
    })
  }

  # Default diverging colors if palette not provided or failed
  if (is.null(color_vec)) {
    color_vec <- c("#67a9cf", "#f7f7f7", "#ef8a62")  # Blue-White-Red
  }

  # Create base heatmap using ggcorrplot
  # Suppress aes_string() deprecation warning from ggcorrplot package
  p <- suppressWarnings(
    ggcorrplot::ggcorrplot(
      corr = cor_matrix,
      method = "square",
      type = type,
      colors = color_vec,
      ggtheme = ggplot2::theme_minimal,
      show.legend = TRUE,
      legend.title = "Correlation",
      lab = show_coef,
      lab_col = "black",
      lab_size = lab_size,
      hc.order = hc_order,
      hc.method = hc_method,
      outline.color = "grey85",
      digits = 2
    )
  )

  # Add title if provided
  if (!is.null(title)) {
    p <- p + ggplot2::labs(title = title)
  }

  # Customize theme
  # Calculate hjust and vjust based on angle
  x_hjust <- if (axis_x_angle == 0) 0.5 else if (axis_x_angle == 90) 1 else 1
  x_vjust <- if (axis_x_angle == 0) 0.5 else if (axis_x_angle == 90) 0.5 else 1
  y_hjust <- if (axis_y_angle == 0) 1 else if (axis_y_angle == 90) 0.5 else 1
  y_vjust <- if (axis_y_angle == 0) 0.5 else if (axis_y_angle == 90) 1 else 0.5

  p <- p + ggplot2::theme(
    plot.title = ggplot2::element_text(hjust = 0.5, size = 16, face = "bold"),
    axis.text.x = if (show_axis_x) {
      ggplot2::element_text(
        angle = axis_x_angle,
        hjust = x_hjust,
        vjust = x_vjust,
        size = axis_text_size
      )
    } else {
      ggplot2::element_blank()
    },
    axis.text.y = if (show_axis_y) {
      ggplot2::element_text(
        angle = axis_y_angle,
        hjust = y_hjust,
        vjust = y_vjust,
        size = axis_text_size
      )
    } else {
      ggplot2::element_blank()
    },
    panel.grid = ggplot2::element_blank(),
    panel.background = ggplot2::element_rect(fill = "white", colour = NA),
    plot.background = ggplot2::element_rect(fill = "white", colour = NA)
  )

  # Add significance stars if requested
  if (show_sig) {
    # Get the variable order from the plot (after potential hc.order)
    plot_data <- p$data
    var_levels <- levels(plot_data$Var1)

    # Create significance star matrix
    star_labels <- c("***", "**", "*")
    star_mat <- matrix("", nrow = nrow(p_matrix), ncol = ncol(p_matrix))
    rownames(star_mat) <- rownames(p_matrix)
    colnames(star_mat) <- colnames(p_matrix)

    for (i in 1:nrow(p_matrix)) {
      for (j in 1:ncol(p_matrix)) {
        p_val <- p_matrix[i, j]
        if (!is.na(p_val)) {
          if (p_val <= sig_level[1]) {
            star_mat[i, j] <- star_labels[1]
          } else if (p_val <= sig_level[2]) {
            star_mat[i, j] <- star_labels[2]
          } else if (p_val <= sig_level[3]) {
            star_mat[i, j] <- star_labels[3]
          }
        }
      }
    }

    # Convert to data frame
    star_df <- as.data.frame(as.table(star_mat), stringsAsFactors = FALSE)
    names(star_df) <- c("Var1", "Var2", "stars")
    star_df <- subset(star_df, nzchar(stars))

    # Align factor levels with plot
    star_df$Var1 <- factor(star_df$Var1, levels = var_levels)
    star_df$Var2 <- factor(star_df$Var2, levels = var_levels)

    # Filter based on type
    if (type == "upper") {
      star_df <- subset(star_df, as.numeric(Var1) < as.numeric(Var2))
    } else if (type == "lower") {
      star_df <- subset(star_df, as.numeric(Var1) > as.numeric(Var2))
    }

    # Add stars to plot
    if (nrow(star_df) > 0) {
      p <- p + ggplot2::geom_text(
        data = star_df,
        mapping = ggplot2::aes(x = .data$Var2, y = .data$Var1, label = .data$stars),
        inherit.aes = FALSE,
        size = 3.8,
        color = "black"
      )
    }
  }

  return(p)
}


# =============================================================================
# S3 Methods for quick_cor_result
# =============================================================================

#' Print method for quick_cor_result
#' @param x A quick_cor_result object
#' @param ... Additional arguments (unused)
#' @export
print.quick_cor_result <- function(x, ...) {
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
  cli::cli_h2("Quick Correlation Analysis Results")

  cli::cli_text("")
  cli::cli_alert_info("Method: {x$method_used}")
  cli::cli_alert_info("Variables: {nrow(x$cor_matrix)}")
  cli::cli_alert_info("Significant pairs: {nrow(x$significant_pairs)}")

  # Show top significant correlations
  if (nrow(x$significant_pairs) > 0) {
    cli::cli_text("")
    cli::cli_h3("Top 5 Significant Correlations")
    top_pairs <- head(x$significant_pairs, 5)
    print(top_pairs, row.names = FALSE)
  }

  # Additional info
  cli::cli_text("")
  cli::cli_text("Use {.fn summary} for detailed results.")

  invisible(x)
}


#' Summary method for quick_cor_result
#' @param object A quick_cor_result object
#' @param ... Additional arguments (unused)
#' @export
summary.quick_cor_result <- function(object, ...) {
  cat("\n")
  cli::cli_h2("Detailed Correlation Analysis Summary")
  cat("\n")

  # Method information
  cli::cli_h3("Analysis Parameters")
  cli::cli_text("Correlation method: {object$method_used}")
  cli::cli_text("Missing value handling: {object$parameters$use}")
  cli::cli_text("P-value adjustment: {object$parameters$p_adjust_method}")
  cli::cli_text("Number of variables: {nrow(object$cor_matrix)}")
  cat("\n")

  # Descriptive statistics
  cli::cli_h3("Descriptive Statistics")
  print(object$descriptive_stats, row.names = FALSE)
  cat("\n")

  # Correlation summary
  cli::cli_h3("Correlation Summary")
  cor_vec <- object$cor_matrix[upper.tri(object$cor_matrix)]
  cli::cli_text("Min correlation: {round(min(cor_vec, na.rm = TRUE), 3)}")
  cli::cli_text("Max correlation: {round(max(cor_vec, na.rm = TRUE), 3)}")
  cli::cli_text("Mean |correlation|: {round(mean(abs(cor_vec), na.rm = TRUE), 3)}")
  cat("\n")

  # Significant pairs
  cli::cli_h3("Significant Correlations")
  n_tests <- choose(nrow(object$cor_matrix), 2)
  n_sig <- nrow(object$significant_pairs)

  # Explain which p-values were used for significance determination
  if (object$parameters$p_adjust_method != "none") {
    cli::cli_alert_info(
      "Significant pairs are based on {.strong adjusted} p-values (method: {object$parameters$p_adjust_method})"
    )
  } else {
    cli::cli_alert_info(
      "Significant pairs are based on {.strong unadjusted} p-values"
    )
  }

  cli::cli_text("Significant pairs: {n_sig} out of {n_tests} tests")

  if (n_sig > 0) {
    cat("\nAll significant pairs:\n")
    print(object$significant_pairs, row.names = FALSE)
  } else {
    cli::cli_text("No significant correlations found at the specified thresholds.")
  }
  cat("\n")

  # Timestamp
  cli::cli_text("Analysis performed: {format(object$timestamp, '%Y-%m-%d %H:%M:%S')}")

  invisible(object)
}
