#' plot_density: Univariate Density Plot (Fill Group, Black Outline)
#'
#' Create a density plot with group color as fill, and fixed black border for all curves.
#'
#' @param data data.frame. Input dataset.
#' @param x Character. Name of numeric variable to plot.
#' @param group Character. Grouping variable for fill color. (Optional)
#' @param facet Character. Faceting variable. (Optional)
#' @param palette Character vector. Fill color palette, e.g. c("#FF0000","#00FF00","#0000FF").
#'        Will be recycled as needed. Cannot be a palette name.
#'        Default: c("#1b9e77", "#d95f02", "#7570b3")
#' @param alpha Numeric. Fill transparency. Default: 0.7.
#' @param base_size Numeric. Theme base font size. Default: 14.
#' @param xlab,ylab,title,legend_pos See above. (Omitted for brevity)
#' @param adjust Numeric. Density bandwidth adjust. Default: 1.
#' @param show_mean Logical. Whether to add mean line. Default: FALSE.
#' @param mean_line_color Character. Mean line color. Default: "red".
#' @param add_hist, hist_bins, add_rug, theme See above. (Omitted for brevity)
#'
#' @return ggplot object.
#' @export
plot_density <- function(
  data,
  x,
  group = NULL,
  facet = NULL,
  palette = c("#1b9e77", "#d95f02", "#7570b3"),
  alpha = 0.7,
  base_size = 14,
  xlab = NULL,
  ylab = "Density",
  title = NULL,
  legend_pos = "right",
  adjust = 1,
  show_mean = FALSE,
  mean_line_color = "red",
  add_hist = FALSE,
  hist_bins = NULL,
  add_rug = FALSE,
  theme = "minimal"
) {
  # ===========================================================================
  # Dependency checks
  # ===========================================================================
  if (!requireNamespace("rlang", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg rlang} is required for plot_density().")
  }
  if (!requireNamespace("RColorBrewer", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg RColorBrewer} is required for plot_density().")
  }

  # ===========================================================================
  # Parameter validation
  # ===========================================================================

  # Validate data
  if (!is.data.frame(data)) {
    cli::cli_abort("`data` must be a data.frame.")
  }
  if (nrow(data) == 0) {
    cli::cli_abort("`data` must contain at least one row.")
  }

  # Validate x parameter
  if (missing(x) || !is.character(x) || length(x) != 1 || is.na(x) || x == "") {
    cli::cli_abort("`x` must be a single non-empty character string (column name).")
  }
  if (!x %in% names(data)) {
    cli::cli_abort("Column `{x}` not found in `data`.")
  }
  if (!is.numeric(data[[x]])) {
    cli::cli_abort("Column `{x}` must contain numeric values for density plotting.")
  }

  # Validate group parameter
  if (!is.null(group)) {
    if (!is.character(group) || length(group) != 1 || is.na(group) || group == "") {
      cli::cli_abort("`group` must be a single non-empty character string (column name).")
    }
    if (!group %in% names(data)) {
      cli::cli_abort("Column `{group}` not found in `data`.")
    }
  }

  # Validate facet parameter
  if (!is.null(facet)) {
    if (!is.character(facet) || length(facet) != 1 || is.na(facet) || facet == "") {
      cli::cli_abort("`facet` must be a single non-empty character string (column name).")
    }
    if (!facet %in% names(data)) {
      cli::cli_abort("Column `{facet}` not found in `data`.")
    }
  }

  # Validate palette parameter
  if (!is.character(palette) || length(palette) < 1 || any(is.na(palette))) {
    cli::cli_abort("`palette` must be a non-empty character vector of color codes, e.g. c('#FF0000', '#00FF00').")
  }
  if (length(palette) == 1 && palette %in% rownames(RColorBrewer::brewer.pal.info)) {
    cli::cli_abort("`palette` must be a color vector, not a palette name like 'Set1'.")
  }

  # Validate numeric parameters
  if (!is.numeric(alpha) || length(alpha) != 1 || is.na(alpha) || alpha < 0 || alpha > 1) {
    cli::cli_abort("`alpha` must be a single numeric value between 0 and 1.")
  }
  if (!is.numeric(base_size) || length(base_size) != 1 || is.na(base_size) || base_size <= 0) {
    cli::cli_abort("`base_size` must be a single positive numeric value.")
  }
  if (!is.numeric(adjust) || length(adjust) != 1 || is.na(adjust) || adjust <= 0) {
    cli::cli_abort("`adjust` must be a single positive numeric value.")
  }

  # Validate logical parameters
  if (!is.logical(show_mean) || length(show_mean) != 1 || is.na(show_mean)) {
    cli::cli_abort("`show_mean` must be a single logical value.")
  }
  if (!is.logical(add_hist) || length(add_hist) != 1 || is.na(add_hist)) {
    cli::cli_abort("`add_hist` must be a single logical value.")
  }
  if (!is.logical(add_rug) || length(add_rug) != 1 || is.na(add_rug)) {
    cli::cli_abort("`add_rug` must be a single logical value.")
  }

  # Validate hist_bins if provided
  if (!is.null(hist_bins)) {
    if (!is.numeric(hist_bins) || length(hist_bins) != 1 || is.na(hist_bins) || hist_bins <= 0 || hist_bins != round(hist_bins)) {
      cli::cli_abort("`hist_bins` must be a single positive integer.")
    }
  }

  # Validate theme parameter
  valid_themes <- c("minimal", "classic", "bw", "light", "dark")
  if (!is.character(theme) || length(theme) != 1 || is.na(theme) || !theme %in% valid_themes) {
    cli::cli_abort("`theme` must be one of: {.val {valid_themes}}")
  }

  # Validate legend_pos
  valid_positions <- c("right", "left", "top", "bottom", "none")
  if (!is.character(legend_pos) || length(legend_pos) != 1 || is.na(legend_pos) || !legend_pos %in% valid_positions) {
    cli::cli_abort("`legend_pos` must be one of: {.val {valid_positions}}")
  }

  df <- data

  # ---- Theme setup ----
  theme_dict <- list(
    minimal = ggplot2::theme_minimal,
    classic = ggplot2::theme_classic,
    bw      = ggplot2::theme_bw,
    light   = ggplot2::theme_light,
    dark    = ggplot2::theme_dark
  )
  if (!theme %in% names(theme_dict)) theme <- "minimal"
  theme_fn <- theme_dict[[theme]]

  # ---- Main aesthetics: only map fill (not color) ----
  aes_main <- ggplot2::aes(x = !!rlang::sym(x))
  if (!is.null(group)) {
    aes_main$fill <- rlang::sym(group)  # only fill
  }

  # ---- Initialize plot ----
  p <- ggplot2::ggplot(df, mapping = aes_main) +
    theme_fn(base_size = base_size) +
    ggplot2::labs(
      x = ifelse(is.null(xlab), x, xlab),
      y = ylab,
      title = title,
      fill = group
    ) +
    ggplot2::theme(legend.position = legend_pos)

  # ---- Add histogram (black outline) ----
  if (add_hist) {
    if (!is.null(group)) {
      p <- p + ggplot2::geom_histogram(
        ggplot2::aes(y = ggplot2::after_stat(density), fill = !!rlang::sym(group)),
        alpha = alpha * 0.6,
        bins = hist_bins,
        position = "identity",
        color = "black"
      )
    } else {
      p <- p + ggplot2::geom_histogram(
        ggplot2::aes(y = ggplot2::after_stat(density)),
        fill = "grey80",
        alpha = alpha * 0.6,
        bins = hist_bins,
        color = "black"
      )
    }
  }

  # ---- Density curve: fill by group, border always black ----
  p <- p + ggplot2::geom_density(
    alpha = alpha,
    adjust = adjust,
    linewidth = 0.6,
    color = "black"    # fixed border color
  )

  # ---- Manual fill palette ----
  if (!is.null(group)) {
    group_levels <- unique(df[[group]])
    n_group <- length(group_levels)
    palette_use <- rep(palette, length.out = n_group)
    names(palette_use) <- as.character(group_levels)
    p <- p + ggplot2::scale_fill_manual(values = palette_use)
  }

  # ---- Faceting ----
  if (!is.null(facet)) {
    p <- p + ggplot2::facet_wrap(as.formula(paste("~", facet)))
  }

  # ---- Mean lines ----
  if (show_mean) {
    if (!is.null(group)) {
      group_means <- stats::aggregate(df[[x]], by = list(df[[group]]), FUN = mean, na.rm = TRUE)
      names(group_means) <- c("group", "mean")
      for (i in seq_len(nrow(group_means))) {
        p <- p + ggplot2::geom_vline(
          xintercept = group_means$mean[i],
          color = mean_line_color,
          linetype = "dashed",
          linewidth = 0.8,
          show.legend = FALSE
        )
      }
    } else {
      mu <- mean(df[[x]], na.rm = TRUE)
      p <- p + ggplot2::geom_vline(
        xintercept = mu,
        color = mean_line_color,
        linetype = "dashed",
        linewidth = 0.8,
        show.legend = FALSE
      )
    }
  }

  # ---- Rug marks ----
  if (add_rug) {
    p <- p + ggplot2::geom_rug(
      alpha = 0.7,
      sides = "b"
    )
  }

  return(p)
}
