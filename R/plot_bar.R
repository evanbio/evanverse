#' Bar plot with optional fill grouping, sorting, and directional layout
#'
#' Create a bar chart from a data frame with optional grouping (`fill`),
#' vertical/horizontal orientation, and sorting by values.
#'
#' @param data A data frame.
#' @param x Column name for the x-axis (quoted or unquoted).
#' @param y Column name for the y-axis (quoted or unquoted).
#' @param fill Optional character scalar. Column name to map to fill (grouping).
#' @param direction Plot direction: "vertical" or "horizontal". Default: "vertical".
#' @param sort Logical. Whether to sort bars based on y values. Default: FALSE.
#' @param sort_by Optional. If `fill` is set and `sort = TRUE`, choose which level
#'   of `fill` is used for sorting.
#' @param sort_dir Sorting direction: "asc" or "desc". Default: "asc".
#' @param width Numeric. Bar width. Default: 0.7.
#' @param ... Additional args passed to `ggplot2::geom_bar()`, e.g. `alpha`, `color`.
#'
#' @return A `ggplot` object.
#' @export
plot_bar <- function(data, x, y, fill = NULL,
                     direction = c("vertical", "horizontal"),
                     sort = FALSE,
                     sort_by = NULL,
                     sort_dir = c("asc", "desc"),
                     width = 0.7,
                     ...) {
  # ===========================================================================
  # Dependency checks (no library() calls)
  # ===========================================================================
  if (!requireNamespace("ggplot2", quietly = TRUE)) {
    cli::cli_abort("Package 'ggplot2' is required for plot_bar().")
  }
  if (!requireNamespace("ggpubr", quietly = TRUE)) {
    cli::cli_abort("Package 'ggpubr' is required for plot_bar().")
  }
  if (!requireNamespace("rlang", quietly = TRUE)) {
    cli::cli_abort("Package 'rlang' is required for plot_bar().")
  }

  # ===========================================================================
  # Argument matching & validation
  # ===========================================================================
  direction <- match.arg(direction)
  sort_dir  <- match.arg(sort_dir)

  if (!is.data.frame(data)) {
    cli::cli_abort("`data` must be a data.frame.")
  }
  if (!is.numeric(width) || length(width) != 1L || is.na(width) || width <= 0) {
    cli::cli_abort("`width` must be a single positive numeric value.")
  }

  x_sym <- rlang::ensym(x)
  y_sym <- rlang::ensym(y)
  x_str <- rlang::as_string(x_sym)
  y_str <- rlang::as_string(y_sym)

  if (!x_str %in% names(data)) cli::cli_abort("Column `{x_str}` not found in `data`.")
  if (!y_str %in% names(data)) cli::cli_abort("Column `{y_str}` not found in `data`.")

  df <- data

  # Warn if duplicated x without grouping
  if (anyDuplicated(df[[x_str]]) > 0 && is.null(fill)) {
    cli::cli_warn("Multiple rows share the same x value, but `fill` is not set. Did you mean `fill = \"...\"`?")
  }

  # Handle fill (optional grouping)
  fill_levels <- NULL
  if (!is.null(fill)) {
    if (!is.character(fill) || length(fill) != 1L || is.na(fill) || fill == "") {
      cli::cli_abort("`fill` must be a single non-NA character string (column name).")
    }
    if (!fill %in% names(df)) {
      cli::cli_abort("Column `{fill}` not found in `data`.")
    }
    if (!is.factor(df[[fill]])) {
      df[[fill]] <- as.factor(df[[fill]])
    }
    fill_levels <- levels(df[[fill]])

    # prevent conflict if user also passes a constant fill aesthetic via ...
    if ("fill" %in% names(list(...))) {
      cli::cli_abort("Cannot map `fill` to a column and also pass a constant `fill` in `...`.")
    }
  }

  # ===========================================================================
  # Sorting logic (base R, no dplyr dependency)
  # ===========================================================================
  if (isTRUE(sort)) {
    if (!is.null(fill)) {
      # choose sorting level
      chosen_level <- sort_by
      if (is.null(chosen_level)) {
        chosen_level <- fill_levels[1L]
        cli::cli_warn("`sort = TRUE` but `sort_by` is not set. Using first level: {chosen_level}")
      } else if (!chosen_level %in% fill_levels) {
        cli::cli_abort("`sort_by = \"{sort_by}\"` is not a valid level of `fill = \"{fill}\"`. Available: {paste(fill_levels, collapse = ', ')}")
      }

      # subset at chosen level and aggregate mean(y) by x
      df_sub <- df[df[[fill]] == chosen_level, , drop = FALSE]
      if (nrow(df_sub) > 0) {
        agg <- stats::aggregate(df_sub[[y_str]],
                                by = list(df_sub[[x_str]]),
                                FUN = function(z) mean(z, na.rm = TRUE))
        # agg has columns: Group.1, x
        ordering <- order(agg[[2L]], decreasing = (sort_dir == "desc"))
        levels_sorted <- agg[[1L]][ordering]
      } else {
        # no rows in selected level; keep original order
        levels_sorted <- unique(df[[x_str]])
      }
      df[[x_str]] <- factor(df[[x_str]], levels = levels_sorted)

    } else {
      # No fill: use the first occurrence of each x (or direct y) to sort
      # If duplicates exist, sorting will reflect the first encountered y.
      idx_first <- !duplicated(df[[x_str]])
      df_summary <- df[idx_first, , drop = FALSE]
      ordering <- order(df_summary[[y_str]], decreasing = (sort_dir == "desc"))
      levels_sorted <- df_summary[[x_str]][ordering]
      df[[x_str]] <- factor(df[[x_str]], levels = levels_sorted)
    }
  }

  # ===========================================================================
  # Aesthetics & geometry
  # ===========================================================================
  aes_mapping <- if (!is.null(fill)) {
    ggplot2::aes(x = !!x_sym, y = !!y_sym, fill = !!rlang::sym(fill))
  } else {
    ggplot2::aes(x = !!x_sym, y = !!y_sym)
  }

  position_mode <- if (!is.null(fill)) "dodge" else "identity"

  p <- ggplot2::ggplot(df, aes_mapping) +
    ggplot2::geom_bar(stat = "identity", position = position_mode, width = width, ...) +
    ggpubr::theme_pubr()

  if (identical(direction, "horizontal")) {
    p <- p + ggplot2::coord_flip()
  }

  p
}
