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
  # ---- Input checks ----
  stopifnot(is.data.frame(data))
  stopifnot(x %in% names(data))
  if (!is.null(group)) stopifnot(group %in% names(data))
  if (!is.null(facet)) stopifnot(facet %in% names(data))
  if (!is.character(palette) || length(palette) < 1 || any(is.na(palette))) {
    stop("palette must be a non-empty character vector of color codes, e.g. c('#FF0000', '#00FF00').")
  }
  if (length(palette) == 1 && palette %in% rownames(RColorBrewer::brewer.pal.info)) {
    stop('palette must be a color vector, not a palette name like "Set1".')
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
  aes_main <- ggplot2::aes(x = .data[[x]])
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
        ggplot2::aes(y = after_stat(density), fill = .data[[group]]),
        alpha = alpha * 0.6,
        bins = hist_bins,
        position = "identity",
        color = "black"
      )
    } else {
      p <- p + ggplot2::geom_histogram(
        ggplot2::aes(y = after_stat(density)),
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
