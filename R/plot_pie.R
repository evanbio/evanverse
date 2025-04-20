#' 🥧 Plot a Clean Pie Chart with Optional Inner Labels
#'
#' Generate a polished pie chart from a vector or a grouped data frame.
#' Labels (optional) are placed inside the pie slices.
#'
#' @param data A character/factor vector or data.frame.
#' @param group_col Group column name (for data.frame). Default: "group".
#' @param count_col Count column name (for data.frame). Default: "count".
#' @param label Type of label to display: "none", "count", "percent", or "both". Default: "none".
#' @param label_size Label font size. Default: 4.
#' @param label_color Label font color. Default: "black".
#' @param fill Fill color vector. Default: 5-color palette.
#' @param title Plot title. Default: "Pie Chart".
#' @param title_size Title font size. Default: 14.
#' @param title_color Title color. Default: "black".
#' @param legend.position Legend position. Default: "right".
#' @param preview Whether to print the plot. Default: TRUE.
#' @param save Optional path to save the plot (e.g., "plot.png").
#' @param return_data If TRUE, return list(plot = ..., data = ...). Default: FALSE.
#'
#' @return A ggplot object or list(plot, data)
#' @export
plot_pie <- function(data,
                     group_col = "group",
                     count_col = "count",
                     label = c("none", "count", "percent", "both"),
                     label_size = 4,
                     label_color = "black",
                     fill = c("#009076", "#C71E1D", "#15607A", "#FA8C00", "#18A1CD"),
                     title = "Pie Chart",
                     title_size = 14,
                     title_color = "black",
                     legend.position = "right",
                     preview = TRUE,
                     save = NULL,
                     return_data = FALSE) {

  # -- Dependency check
  required_pkgs <- c("ggplot2", "dplyr")
  missing <- required_pkgs[!sapply(required_pkgs, requireNamespace, quietly = TRUE)]
  if (length(missing) > 0) {
    cli::cli_abort("Missing packages: {paste(missing, collapse = ', ')}")
  }

  label <- match.arg(label)

  # -- Prepare input data
  if (is.atomic(data) && is.vector(data)) {
    tab <- table(data)
    if (length(tab) < 2) {
      cli::cli_abort("Vector input must contain at least two unique groups.")
    }
    df <- as.data.frame(tab, stringsAsFactors = FALSE)
    colnames(df) <- c("group", "count")
  } else if (is.data.frame(data)) {
    if (!all(c(group_col, count_col) %in% colnames(data))) {
      cli::cli_abort("Data frame must contain columns '{group_col}' and '{count_col}'.")
    }
    df <- data.frame(
      group = as.character(data[[group_col]]),
      count = as.numeric(data[[count_col]]),
      stringsAsFactors = FALSE
    )
  } else {
    cli::cli_abort("Input must be a vector or data frame.")
  }

  df <- df[df$count > 0, , drop = FALSE]
  total <- sum(df$count)

  df <- df %>%
    dplyr::arrange(dplyr::desc(count)) %>%
    dplyr::mutate(
      percent = round(count / total * 100, 1),
      label_text = dplyr::case_when(
        label == "count"   ~ as.character(count),
        label == "percent" ~ paste0(percent, "%"),
        label == "both"    ~ paste0(count, " (", percent, "%)"),
        TRUE               ~ ""
      )
    )

  # -- Base pie plot
  p <- ggplot2::ggplot(df, ggplot2::aes(x = "", y = count, fill = group)) +
    ggplot2::geom_col(width = 1, color = "white") +
    ggplot2::coord_polar(theta = "y") +
    ggplot2::theme_void() +
    ggplot2::ggtitle(title) +
    ggplot2::theme(
      plot.title = ggplot2::element_text(hjust = 0.5, size = title_size, color = title_color),
      legend.position = legend.position
    )

  # -- Add inner labels
  if (label != "none") {
    p <- p + ggplot2::geom_text(
      ggplot2::aes(label = label_text),
      position = ggplot2::position_stack(vjust = 0.5),
      color = label_color,
      size = label_size,
      check_overlap = TRUE
    )
  }

  # -- Optional fill color
  if (!is.null(fill)) {
    p <- p + ggplot2::scale_fill_manual(values = fill)
  }

  # -- Save to file
  if (!is.null(save)) {
    ggplot2::ggsave(filename = save, plot = p, width = 6, height = 6)
    cli::cli_alert_success("✅ Pie chart saved to {save}")
  }

  # -- Output
  if (preview) print(p)
  if (return_data) return(list(plot = p, data = df))
  return(p)
}
