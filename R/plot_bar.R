#' Bar plot with optional fill grouping, sorting, and directional layout
#'
#' @param data A data frame containing the input data.
#' @param x Column name for the x-axis (quoted or unquoted).
#' @param y Column name for the y-axis (quoted or unquoted).
#' @param fill Optional. A character string specifying the column name to be mapped to fill (grouping).
#' @param direction Plot direction. Either "vertical" or "horizontal". Default is "vertical".
#' @param sort Logical. Whether to sort the bars based on y values. Default is FALSE.
#' @param sort_by Optional. If `fill` is specified and `sort = TRUE`, this selects which level of `fill` is used for sorting.
#' @param sort_dir Sorting direction. Either "asc" (increasing) or "desc" (decreasing). Default is "asc".
#' @param width Numeric. Width of bars. Default is 0.7.
#' @param ... Additional arguments passed to `geom_bar()`, such as `alpha`, `color`, etc.
#'
#' @return A ggplot object showing a bar chart.
#' @export
plot_bar <- function(data, x, y, fill = NULL,
                     direction = c("vertical", "horizontal"),
                     sort = FALSE,
                     sort_by = NULL,
                     sort_dir = c("asc", "desc"),
                     width = 0.7,
                     ...) {
  library(ggplot2)
  library(ggpubr)
  library(rlang)

  direction <- match.arg(direction)
  sort_dir <- match.arg(sort_dir)

  x_sym <- ensym(x)
  y_sym <- ensym(y)
  x_str <- as_string(x_sym)
  y_str <- as_string(y_sym)

  df <- data

  # Warn if x has duplicates but no fill is provided
  if (anyDuplicated(df[[x_str]]) > 0 && is.null(fill)) {
    warning("⚠️ Multiple rows share the same x value, but `fill` is not set.\nDid you forget to specify `fill = \"...\"`?")
  }

  # Handle fill variable
  fill_sym <- NULL
  fill_levels <- NULL
  if (!is.null(fill)) {
    if (!is.character(fill) || length(fill) != 1) {
      stop("`fill` must be a single character string, e.g., fill = \"group_var\"")
    }
    if (!fill %in% colnames(df)) {
      stop(paste0("Column `", fill, "` not found in data."))
    }
    if (!is.factor(df[[fill]])) {
      df[[fill]] <- as.factor(df[[fill]])
    }
    fill_levels <- levels(df[[fill]])

    if ("fill" %in% names(list(...))) {
      stop("You cannot specify both `fill` as a mapped variable and also pass `fill = ...` in `...`.")
    }
  }

  # Sorting
  if (sort) {
    if (!is.null(fill)) {
      selected_level <- sort_by
      if (is.null(selected_level)) {
        selected_level <- fill_levels[1]
        warning(paste0("sort = TRUE but `sort_by` is not set. Using first level: ", selected_level))
      } else if (!selected_level %in% fill_levels) {
        stop(paste0("`sort_by = \"", sort_by, "\"` is not a valid level of `fill = \"", fill, "\"`.\nAvailable levels: ",
                    paste(fill_levels, collapse = ", ")))
      }

      df_subset <- df[df[[fill]] == selected_level, ]
      df_summary <- df_subset |>
        dplyr::group_by(.data[[x_str]]) |>
        dplyr::summarise(sort_value = mean(.data[[y_str]], na.rm = TRUE), .groups = "drop")

    } else {
      df_summary <- df[!duplicated(df[[x_str]]), , drop = FALSE]
      df_summary$sort_value <- df_summary[[y_str]]
    }

    ordering <- order(df_summary$sort_value, decreasing = (sort_dir == "desc"))
    levels_sorted <- df_summary[[x_str]][ordering]
    df[[x_str]] <- factor(df[[x_str]], levels = levels_sorted)
  }

  # aes mapping
  aes_mapping <- if (!is.null(fill)) {
    aes(x = !!x_sym, y = !!y_sym, fill = !!sym(fill))
  } else {
    aes(x = !!x_sym, y = !!y_sym)
  }
  position <- if (!is.null(fill)) "dodge" else "identity"

  # Plot construction
  p <- ggplot(df, aes_mapping) +
    geom_bar(stat = "identity", position = position, width = width, ...) +
    theme_pubr()

  if (direction == "horizontal") {
    p <- p + coord_flip()
  }

  return(p)
}
