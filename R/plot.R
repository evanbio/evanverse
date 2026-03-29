# =============================================================================
# plot.R — Plotting functions
# =============================================================================

#' Bar plot with optional grouping and sorting
#'
#' Create a bar chart from a data frame with optional dodge grouping,
#' vertical/horizontal orientation, and sorting by y values.
#'
#' @param data A data.frame.
#' @param x_col Character. Column name for the x-axis. Values must be unique
#'   when `group_col` is `NULL`.
#' @param y_col Character. Column name for the y-axis.
#' @param horizontal Logical. If `TRUE`, flip to horizontal layout. Default: `FALSE`.
#' @param sort Logical. Whether to sort bars by y values. Default: `FALSE`.
#' @param decreasing Logical. If `sort = TRUE`, sort in decreasing order.
#'   Default: `TRUE`.
#' @param group_col Character or `NULL`. Column name for dodge grouping. Default: `NULL`.
#' @param sort_by Character or `NULL`. Required when `sort = TRUE` and `group_col`
#'   is set. Must be a valid level of the `group_col` column; used to order x
#'   positions by that group's y values.
#'
#' @importFrom rlang .data
#' @return A `ggplot` object.
#' @export
#'
#' @examples
#' df <- data.frame(
#'   category = c("A", "B", "C", "D"),
#'   value    = c(10, 25, 15, 30)
#' )
#' plot_bar(df, x_col = "category", y_col = "value",
#'          sort = TRUE, horizontal = TRUE)
plot_bar <- function(data,
                     x_col,
                     y_col,
                     horizontal = FALSE,
                     sort       = FALSE,
                     decreasing = TRUE,
                     group_col  = NULL,
                     sort_by    = NULL) {
  # validation
  .assert_data_frame(data)
  .assert_scalar_string(x_col)
  .assert_scalar_string(y_col)
  .assert_has_cols(data, c(x_col, y_col))
  .assert_flag(horizontal)
  .assert_flag(sort)
  .assert_flag(decreasing)

  # group
  group_levels <- NULL

  if (!is.null(group_col)) {
    .assert_scalar_string(group_col)
    .assert_has_cols(data, group_col)

    # (x_col, group_col) pairs must be unique
    .assert_no_dupes(paste(data[[x_col]], data[[group_col]], sep = "\t"))

    if (!is.factor(data[[group_col]])) {
      data[[group_col]] <- as.factor(data[[group_col]])
    }
    group_levels <- levels(data[[group_col]])

  } else {
    .assert_no_dupes(data[[x_col]])
  }

  # sorting
  if (isTRUE(sort)) {
    if (is.null(group_col)) {
      ordering      <- order(data[[y_col]], decreasing = decreasing)
      levels_sorted <- as.character(data[[x_col]][ordering])
      data[[x_col]] <- factor(data[[x_col]], levels = levels_sorted)

    } else {
      if (is.null(sort_by)) {
        cli::cli_abort(
          "`sort = TRUE` requires `sort_by`. Available levels of `{group_col}`: {.val {group_levels}}"
        )
      }
      .assert_scalar_string(sort_by)
      if (!sort_by %in% group_levels) {
        cli::cli_abort(
          "`sort_by = \"{sort_by}\"` is not a valid level of `{group_col}`. Available: {.val {group_levels}}"
        )
      }

      df_sub        <- data[data[[group_col]] == sort_by, , drop = FALSE]
      ordering      <- order(df_sub[[y_col]], decreasing = decreasing)
      levels_sorted <- as.character(df_sub[[x_col]][ordering])
      # Append any x_col values not covered by sort_by group at the end,
      # so no categories are silently dropped as NA by ggplot.
      levels_sorted <- union(levels_sorted, unique(as.character(data[[x_col]])))
      data[[x_col]] <- factor(data[[x_col]], levels = levels_sorted)
    }
  }

  # plot
  aes_mapping <- if (!is.null(group_col)) {
    ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]], fill = .data[[group_col]])
  } else {
    ggplot2::aes(x = .data[[x_col]], y = .data[[y_col]])
  }

  p <- ggplot2::ggplot(data, aes_mapping) +
    ggplot2::geom_col(position = if (!is.null(group_col)) "dodge" else "identity") +
    ggpubr::theme_pubr()

  if (isTRUE(horizontal)) {
    p <- p + ggplot2::coord_flip()
  }

  p
}


#' Density plot with optional grouping and faceting
#'
#' Create a univariate density plot with optional fill grouping and faceting.
#' Density curves have a fixed black border; fill is controlled by `group_col`.
#'
#' @param data A data.frame.
#' @param x_col Character. Column name of the numeric variable to plot.
#' @param group_col Character or `NULL`. Column name for fill grouping. Default: `NULL`.
#' @param facet_col Character or `NULL`. Column name for faceting. Default: `NULL`.
#' @param alpha Numeric. Fill transparency \[0, 1\] (0 = fully transparent,
#'   1 = fully opaque). Default: 0.7.
#' @param adjust Numeric. Bandwidth adjustment multiplier. Default: 1.
#' @param palette Character vector or `NULL`. Fill colors recycled to match the
#'   number of groups. If `NULL`, uses ggplot2 default colors. Default: `NULL`.
#'
#' @return A `ggplot` object.
#' @importFrom stats as.formula
#' @export
#'
#' @examples
#' plot_density(iris, x_col = "Sepal.Length", group_col = "Species")
plot_density <- function(data,
                         x_col,
                         group_col = NULL,
                         facet_col = NULL,
                         alpha     = 0.7,
                         adjust    = 1,
                         palette   = NULL) {
  # validation
  .assert_data_frame(data)
  .assert_scalar_string(x_col)
  .assert_has_cols(data, x_col)

  .assert_numeric_vector(data[[x_col]])
  .assert_proportion(alpha)
  .assert_positive_numeric(adjust)

  # group_col
  if (!is.null(group_col)) {
    .assert_scalar_string(group_col)
    .assert_has_cols(data, group_col)
  }

  # facet_col
  if (!is.null(facet_col)) {
    .assert_scalar_string(facet_col)
    .assert_has_cols(data, facet_col)
  }

  # palette
  if (!is.null(palette)) {
    .assert_character_vector(palette)
    if (is.null(group_col)) {
      cli::cli_warn("`palette` is ignored when `group_col` is NULL.")
    }
  }

  # plot
  aes_main <- if (!is.null(group_col)) {
    ggplot2::aes(x = .data[[x_col]], fill = .data[[group_col]])
  } else {
    ggplot2::aes(x = .data[[x_col]])
  }

  p <- ggplot2::ggplot(data, aes_main) +
    ggplot2::geom_density(alpha = alpha, adjust = adjust,
                          linewidth = 0.6, color = "black") +
    ggpubr::theme_pubr()

  # manual palette
  if (!is.null(group_col) && !is.null(palette)) {
    group_levels <- if (is.factor(data[[group_col]])) {
      levels(data[[group_col]])
    } else {
      unique(as.character(data[[group_col]]))
    }
    palette_use  <- rep(palette, length.out = length(group_levels))
    names(palette_use) <- group_levels
    p <- p + ggplot2::scale_fill_manual(values = palette_use)
  }

  # faceting
  if (!is.null(facet_col)) {
    p <- p + ggplot2::facet_wrap(stats::as.formula(paste("~", facet_col)))
  }

  p
}


#' Pie chart from a vector or grouped data frame
#'
#' Accepts either a character/factor vector (frequency counted automatically)
#' or a data frame with pre-computed counts. Slices with zero count are dropped.
#' At least two groups are required.
#'
#' @param data A character/factor vector, or a data.frame.
#' @param group_col Character. Column name for group labels (data.frame only).
#' @param count_col Character. Column name for counts (data.frame only).
#'   Values must be non-negative.
#' @param label Label type: `"none"`, `"count"`, `"percent"`, or `"both"`.
#'   Default: `"none"`.
#' @param palette Character vector or `NULL`. Slice fill colors recycled to
#'   match the number of groups. If `NULL`, uses ggplot2 default colors.
#'   Default: `NULL`.
#'
#' @return A `ggplot` object.
#' @export
#'
#' @examples
#' # From a vector
#' plot_pie(c("A", "A", "B", "C", "C", "C"))
#'
#' # From a data frame
#' df <- data.frame(group = c("X", "Y", "Z"), count = c(10, 25, 15))
#' plot_pie(df, group_col = "group", count_col = "count", label = "percent")
plot_pie <- function(data,
                     group_col = NULL,
                     count_col = NULL,
                     label     = c("none", "count", "percent", "both"),
                     palette   = NULL) {
  # validation
  label <- match.arg(label)

  if (!is.null(palette)) .assert_character_vector(palette)

  # prepare data
  if (is.data.frame(data)) {
    .assert_scalar_string(group_col)
    .assert_scalar_string(count_col)
    .assert_has_cols(data, c(group_col, count_col))

    df <- data.frame(
      group = as.character(data[[group_col]]),
      count = as.numeric(data[[count_col]]),
      stringsAsFactors = FALSE
    )

    .assert_no_blank(df$group)
    if (anyNA(df$count)) {
      cli::cli_abort("`{count_col}` must not contain NA values.")
    }
    if (any(df$count < 0)) {
      cli::cli_abort("`{count_col}` must contain non-negative values.")
    }

  } else if (is.character(data) || is.factor(data)) {
    if (anyNA(data)) {
      cli::cli_abort("`data` must not contain NA values.")
    }
    tab <- table(data)
    df  <- data.frame(
      group = names(tab),
      count = as.numeric(tab),
      stringsAsFactors = FALSE
    )

  } else {
    cli::cli_abort("`data` must be a vector or a data.frame.")
  }

  # drop zero-count slices
  df <- df[df$count > 0, , drop = FALSE]

  if (nrow(df) < 2) {
    cli::cli_abort("At least two groups with non-zero count are required.")
  }

  # compute labels
  total <- sum(df$count)
  df$percent    <- round(df$count / total * 100, 1)
  df$label_text <- switch(
    label,
    "count"   = as.character(df$count),
    "percent" = paste0(df$percent, "%"),
    "both"    = paste0(df$count, " (", df$percent, "%)"),
    ""
  )

  # plot
  p <- ggplot2::ggplot(df, ggplot2::aes(x = "", y = count, fill = group)) +
    ggplot2::geom_col(width = 1, color = "white") +
    ggplot2::coord_polar(theta = "y") +
    ggplot2::theme_void()

  if (label != "none") {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = label_text),
      position = ggplot2::position_stack(vjust = 0.5)
    )
  }

  if (!is.null(palette)) {
    palette_use        <- rep(palette, length.out = nrow(df))
    names(palette_use) <- df$group
    p <- p + ggplot2::scale_fill_manual(values = palette_use)
  }

  p
}


#' Venn diagram for 2-4 sets
#'
#' Draws a Venn diagram using either `ggvenn` (classic) or `ggVennDiagram`
#' (gradient). Both packages must be installed (they are in `Suggests`).
#'
#' @param set1,set2 Required input vectors (at least two sets).
#' @param set3,set4 Optional additional sets. Default: `NULL`.
#' @param set_names Character vector of set labels. If `NULL`, uses the
#'   variable names of the inputs. Default: `NULL`.
#' @param method Drawing method: `"classic"` (ggvenn) or `"gradient"`
#'   (ggVennDiagram). Default: `"classic"`.
#' @param label Label type: `"count"`, `"percent"`, `"both"`, or `"none"`.
#'   Default: `"count"`.
#' @param palette For `"classic"`: character vector of fill colors, recycled
#'   to match the number of sets. For `"gradient"`: a single
#'   `RColorBrewer` palette name passed to `scale_fill_distiller()`.
#'   If `NULL`, defaults are used. Default: `NULL`.
#' @param return_sets Logical. If `TRUE`, returns `list(plot, sets)` instead
#'   of just the plot. Default: `FALSE`.
#'
#' @return A `ggplot` object, or a named list with elements `plot` and `sets`
#'   if `return_sets = TRUE`.
#' @export
#'
#' @examples
#' if (requireNamespace("ggvenn", quietly = TRUE)) {
#'   set.seed(42)
#'   plot_venn(sample(letters, 15), sample(letters, 12), sample(letters, 10))
#' }
plot_venn <- function(set1, set2,
                      set3        = NULL,
                      set4        = NULL,
                      set_names   = NULL,
                      method      = c("classic", "gradient"),
                      label       = c("count", "percent", "both", "none"),
                      palette     = NULL,
                      return_sets = FALSE) {
  # validation
  method <- match.arg(method)
  label  <- match.arg(label)
  .assert_flag(return_sets)

  if (!is.null(palette))   .assert_character_vector(palette)
  if (!is.null(set_names)) .assert_character_vector(set_names)

  # build set list
  venn_sets <- list(set1, set2)
  var_names <- c(deparse(substitute(set1)), deparse(substitute(set2)))

  if (!is.null(set3)) { venn_sets[[3]] <- set3; var_names[3] <- deparse(substitute(set3)) }
  if (!is.null(set4)) { venn_sets[[4]] <- set4; var_names[4] <- deparse(substitute(set4)) }

  # validate each set
  for (i in seq_along(venn_sets)) {
    if (length(venn_sets[[i]]) == 0)
      cli::cli_abort("{var_names[[i]]} must not be empty.")
  }

  # set names
  if (!is.null(set_names)) {
    if (length(set_names) != length(venn_sets)) {
      cli::cli_abort(
        "`set_names` length ({length(set_names)}) must match number of sets ({length(venn_sets)})."
      )
    }
  } else {
    set_names <- var_names
  }

  # dependency check (Suggests)
  if (method == "classic" && !requireNamespace("ggvenn", quietly = TRUE)) {
    cli::cli_abort('Package {.pkg ggvenn} is required for {.val "classic"} method.')
  }
  if (method == "gradient" && !requireNamespace("ggVennDiagram", quietly = TRUE)) {
    cli::cli_abort('Package {.pkg ggVennDiagram} is required for {.val "gradient"} method.')
  }

  # deduplicate silently
  venn_sets <- lapply(venn_sets, unique)
  names(venn_sets) <- set_names

  # plot
  if (method == "classic") {
    fill_colors <- if (!is.null(palette)) {
      rep(palette, length.out = length(venn_sets))
    } else {
      c("skyblue", "pink", "lightgreen", "lightyellow")[seq_along(venn_sets)]
    }

    p <- ggvenn::ggvenn(
      data            = venn_sets,
      columns         = names(venn_sets),
      show_elements   = (label == "both"),
      show_percentage = (label %in% c("percent", "both")),
      fill_color      = fill_colors
    ) + ggplot2::theme_void()

  } else {
    p <- ggVennDiagram::ggVennDiagram(
      x              = venn_sets,
      category.names = names(venn_sets),
      label          = label,
      show_intersect = FALSE
    )

    if (!is.null(palette)) {
      if (length(palette) != 1L) {
        cli::cli_abort(
          'The {.val "gradient"} method requires a single RColorBrewer palette name (length 1). Got length {length(palette)}.'
        )
      }
      .assert_scalar_string(palette)
      p <- p + ggplot2::scale_fill_distiller(palette = palette)
    }
  }

  if (isTRUE(return_sets)) return(list(plot = p, sets = venn_sets))
  p
}
#' Publication-ready forest plot
#'
#' Produces a publication-ready forest plot with UKB-standard styling.
#' The user supplies a data frame whose first column is the row label
#' (\code{item}), plus any additional display columns (e.g. \code{Cases/N}).
#' The gap column and the auto-formatted \code{OR (95\% CI)} text column are
#' inserted automatically at \code{ci_column}. Numeric p-value columns
#' declared via \code{p_cols} are formatted in-place.
#'
#' @param data data.frame. First column must be the label column (\code{item}).
#'   Additional columns are displayed as-is (character) or formatted if named
#'   in \code{p_cols} (must be numeric). Column order is preserved.
#' @param est Numeric vector. Point estimates (\code{NA} = no CI drawn).
#' @param lower Numeric vector. Lower CI bounds (same length as \code{est}).
#' @param upper Numeric vector. Upper CI bounds (same length as \code{est}).
#' @param ci_column Integer. Column position in the final rendered table where
#'   the gap/CI graphic is placed. Must be between \code{2} and
#'   \code{ncol(data) + 1} (inclusive). Default: \code{2L}.
#' @param ref_line Numeric. Reference line. Default: \code{1} (HR/OR).
#'   Use \code{0} for beta coefficients.
#' @param xlim Numeric vector of length 2. X-axis limits. \code{NULL} (default)
#'   uses \code{c(0, 2)}.
#' @param ticks_at Numeric vector. Tick positions. \code{NULL} (default) = 5
#'   evenly spaced ticks across \code{xlim}.
#' @param arrow_lab Character vector of length 2. Directional labels.
#'   Default: \code{c("Lower risk", "Higher risk")}. \code{NULL} = none.
#' @param header Character vector of length \code{ncol(data) + 2}. Column
#'   header labels for the final rendered table (original columns + gap_ci +
#'   OR label). \code{NULL} (default) = use column names from \code{data} plus
#'   \code{"gap_ci"} and \code{"OR (95\% CI)"}. Pass \code{""} for the gap
#'   column position.
#' @param indent Integer vector (length = \code{nrow(data)}). Indentation
#'   level of the label column: each unit adds two leading spaces.
#'   Default: all zeros.
#' @param bold_label Logical vector (length = \code{nrow(data)}). Which rows
#'   to bold in the label column. \code{NULL} (default) = auto-derive from
#'   \code{indent}: rows where \code{indent == 0} are bolded (parent rows),
#'   indented sub-rows are plain.
#' @param ci_col Character scalar or vector (length = \code{nrow(data)}).
#'   CI colour(s). \code{NA} rows are skipped automatically.
#'   Default: \code{"black"}.
#' @param ci_sizes Numeric. Point size. Default: \code{0.6}.
#' @param ci_Theight Numeric. CI cap height. Default: \code{0.2}.
#' @param ci_digits Integer. Decimal places for the auto-generated
#'   \code{OR (95\% CI)} column. Default: \code{2L}.
#' @param ci_sep Character. Separator between lower and upper CI in the label,
#'   e.g. \code{", "} or \code{" - "}. Default: \code{", "}.
#' @param p_cols Character vector. Names of numeric p-value columns in
#'   \code{data}. These are formatted to \code{p_digits} decimal places with
#'   \code{"<0.001"}-style clipping. \code{NULL} = none.
#' @param p_digits Integer. Decimal places for p-value formatting.
#'   Default: \code{3L}.
#' @param bold_p \code{TRUE} (bold all non-NA p below \code{p_threshold}),
#'   \code{FALSE} (no bolding), or a logical vector (per-row control).
#'   Default: \code{TRUE}.
#' @param p_threshold Numeric. P-value threshold for bolding when
#'   \code{bold_p = TRUE}. Default: \code{0.05}.
#' @param align Integer vector of length \code{ncol(data) + 2}. Alignment per
#'   column: \code{-1} left, \code{0} centre, \code{1} right. Must cover all
#'   final columns (original + gap_ci + OR label).
#'   \code{NULL} = auto (column 1 left, all others centre).
#' @param background Character. Row background style: \code{"zebra"},
#'   \code{"bold_label"} (shade rows where \code{bold_label = TRUE}),
#'   or \code{"none"}. Default: \code{"zebra"}.
#' @param bg_col Character. Shading colour for backgrounds (scalar), or a
#'   per-row vector of length \code{nrow(data)} (overrides style).
#'   Default: \code{"#F0F0F0"}.
#' @param border Character. Border style: \code{"three_line"} or \code{"none"}.
#'   Default: \code{"three_line"}.
#' @param border_width Numeric. Border line width(s). Scalar = all three lines
#'   same width; length-3 vector = top-of-header, bottom-of-header,
#'   bottom-of-body. Default: \code{3}.
#' @param row_height \code{NULL} (auto), numeric scalar, or numeric vector
#'   (length = total gtable rows including margins). Auto sets 8 / 12 / 10 / 15
#'   mm for top / header / data / bottom respectively.
#' @param col_width \code{NULL} (auto), numeric scalar, or numeric vector
#'   (length = total gtable columns). Auto rounds each default width up so the
#'   adjustment is in \eqn{[5, 10)} mm.
#' @param save Logical. Save output to files? Default: \code{FALSE}.
#' @param dest Character. Destination file path (extension ignored; all four
#'   formats are saved). Required when \code{save = TRUE}.
#' @param save_width Numeric. Output width in cm. Default: \code{20}.
#' @param save_height Numeric or \code{NULL}. Output height in cm.
#'   \code{NULL} = \code{nrow(data) * 0.9 + 3}.
#' @param theme Character preset (\code{"default"}) or a
#'   \code{forestploter::forest_theme} object. Default: \code{"default"}.
#'
#' @return A \pkg{forestploter} plot object (gtable), returned invisibly.
#'   Display with \code{plot()} or \code{grid::grid.draw()}.
#'
#' @importFrom forestploter forest forest_theme edit_plot add_border
#' @importFrom grid gpar unit
#' @export
#'
#' @examples
#' df <- data.frame(
#'   item      = c("Exposure vs. control", "Unadjusted", "Fully adjusted"),
#'   `Cases/N` = c("", "89/4521", "89/4521"),
#'   p_value   = c(NA_real_, 0.001, 0.006),
#'   check.names = FALSE
#' )
#'
#' p <- plot_forest(
#'   data       = df,
#'   est        = c(NA, 1.52, 1.43),
#'   lower      = c(NA, 1.18, 1.11),
#'   upper      = c(NA, 1.96, 1.85),
#'   ci_column  = 2L,
#'   indent     = c(0L, 1L, 1L),
#'   bold_label = c(TRUE, FALSE, FALSE),
#'   p_cols     = "p_value",
#'   xlim       = c(0.5, 3.0)
#' )
#' plot(p)
plot_forest <- function(data,
                        est,
                        lower,
                        upper,
                        ci_column   = 2L,
                        ref_line    = 1,
                        xlim        = NULL,
                        ticks_at    = NULL,
                        arrow_lab   = c("Lower risk", "Higher risk"),
                        header      = NULL,
                        indent      = NULL,
                        bold_label  = NULL,
                        ci_col      = "black",
                        ci_sizes    = 0.6,
                        ci_Theight  = 0.2,
                        ci_digits   = 2L,
                        ci_sep      = ", ",
                        p_cols      = NULL,
                        p_digits    = 3L,
                        bold_p      = TRUE,
                        p_threshold = 0.05,
                        align       = NULL,
                        background  = "zebra",
                        bg_col      = "#F0F0F0",
                        border      = "three_line",
                        border_width = 3,
                        row_height  = NULL,
                        col_width   = NULL,
                        save        = FALSE,
                        dest        = NULL,
                        save_width  = 20,
                        save_height = NULL,
                        theme       = "default") {

  # Validate inputs
  .assert_data_frame(data)
  n        <- nrow(data)
  nc_orig  <- ncol(data)
  nc_final <- nc_orig + 2L   # gap_ci + OR label always inserted

  .assert_length_n(est,   n)
  .assert_length_n(lower, n)
  .assert_length_n(upper, n)
  if (!is.null(indent))     .assert_length_n(indent,     n)
  if (!is.null(bold_label)) .assert_length_n(bold_label, n)
  if (length(ci_col) > 1L)  .assert_length_n(ci_col,     n)
  .assert_has_cols(data, p_cols)
  .assert_logical(bold_p)
  if (length(bold_p) == 1L) bold_p <- rep(bold_p, n)
  .assert_length_n(bold_p, n)

  if (ci_column < 2L || ci_column > nc_orig + 1L)
    cli::cli_abort(
      "{.arg ci_column} must be between 2 and {nc_orig + 1L} (ncol(data) + 1).",
      call = NULL
    )
  if (!is.null(header)) .assert_length_n(header, nc_final)
  if (!is.null(align))  .assert_length_n(align,  nc_final)

  # Defaults
  if (is.null(indent)) indent <- rep(0L, n)
  # bold_label default: bold parent rows (indent == 0), leave sub-rows plain
  if (is.null(bold_label)) bold_label <- indent == 0L

  # Pre-process data
  out        <- .fp_build_data(data, est, lower, upper, indent,
                               p_cols, p_digits, ci_digits, ci_sep, ci_column)
  data_r     <- out$data
  p_col_idxs <- out$p_col_idxs
  p_numeric  <- out$p_numeric

  nr <- nrow(data_r)

  if (!is.null(header)) names(data_r) <- header

  # Build base plot
  if (is.null(xlim)) xlim <- c(0, 2)
  if (is.null(ticks_at))
    ticks_at <- seq(xlim[1L], xlim[2L], length.out = 5L)

  p <- forestploter::forest(
    data      = data_r,
    est       = list(est),
    lower     = list(lower),
    upper     = list(upper),
    ci_column = ci_column,
    ref_line  = ref_line,
    xlim      = xlim,
    ticks_at  = ticks_at,
    arrow_lab = arrow_lab,
    sizes     = ci_sizes,
    theme     = .fp_theme(theme, ci_Theight = ci_Theight)
  )

  # Post-processing
  p <- .fp_align(p, nc_final, align)
  p <- .fp_bold_label(p, bold_label)

  if (!is.null(p_cols))
    p <- .fp_bold_p(p, p_cols, p_col_idxs, p_numeric, bold_p, p_threshold, nr)

  p <- .fp_ci_colors(p, ci_col, ci_column, est, nr)
  p <- .fp_background(p, nr, nc_final, background, bold_label, bg_col)
  p <- .fp_borders(p, nr, border, border_width)
  p <- .fp_layout(p, row_height, col_width)

  # Save
  if (isTRUE(save)) {
    if (is.null(dest))
      cli::cli_abort("{.arg dest} must be provided when {.arg save = TRUE}.", call = NULL)
    h <- if (is.null(save_height)) nr * 0.9 + 3 else save_height
    .fp_save(p, dest, save_width, h)
  }

  invisible(p)
}
