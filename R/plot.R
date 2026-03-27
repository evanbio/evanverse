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
#' @param alpha Numeric. Fill transparency (0-1). Default: 0.7.
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
