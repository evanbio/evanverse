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
