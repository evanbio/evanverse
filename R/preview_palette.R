#' 🖼 preview_palette(): Visualize a Palette from RDS
#'
#' Preview the appearance of a palette from `data/palettes.rds` using various plot types.
#'
#' @param name Name of the palette.
#' @param type Palette type: "sequential", "diverging", "qualitative".
#' @param n Number of colors to use (default: all).
#' @param plot_type Plot style: "bar", "pie", "point", "rect", "circle".
#' @param title Plot title (default: same as palette name).
#' @param palette_rds Path to RDS file. Default: system.file("extdata", "palettes.rds", package = "evanverse").
#' @param preview Whether to show the plot immediately. Default: TRUE.
#'
#' @return NULL (invisible), for plotting side effect.
#' @export
preview_palette <- function(name,
                            type = c("sequential", "diverging", "qualitative"),
                            n = NULL,
                            plot_type = c("bar", "pie", "point", "rect", "circle"),
                            title = name,
                            palette_rds = system.file("extdata", "palettes.rds", package = "evanverse"),
                            preview = TRUE) {

  if (!requireNamespace("cli", quietly = TRUE)) stop("Please install the 'cli' package.")
  type <- match.arg(type)
  plot_type <- match.arg(plot_type)

  colors <- get_palette(name = name, type = type, n = n, palette_rds = palette_rds)
  num_colors <- length(colors)

  if (!preview) return(invisible(NULL))

  cli::cli_h2("Previewing palette: {name}")
  cli::cli_alert_info("Plot type: {.val {plot_type}}, colors: {num_colors}")

  switch(plot_type,
         "bar" = barplot(rep(1, num_colors), col = colors, border = NA, space = 0,
                         axes = FALSE, main = title, names.arg = colors, las = 2, cex.names = 0.8),
         "pie" = pie(rep(1, num_colors), col = colors, labels = colors, border = "white",
                     main = title, cex = 0.8),
         "point" = {
           plot(seq_len(num_colors), rep(1, num_colors), pch = 19, cex = 5, col = colors,
                axes = FALSE, xlab = "", ylab = "", main = title)
           text(seq_len(num_colors), rep(1.2, num_colors), labels = colors, pos = 3, cex = 0.8)
         },
         "rect" = {
           plot(0, 0, type = "n", xlim = c(0, num_colors), ylim = c(0, 1),
                axes = FALSE, xlab = "", ylab = "", main = title)
           rect(0:(num_colors-1), 0, 1:num_colors, 1, col = colors, border = NA)
           text((0:(num_colors-1) + 1:num_colors) / 2, 0.5, labels = colors, col = "white", cex = 0.8)
         },
         "circle" = {
           plot(0, 0, type = "n", xlim = c(0, num_colors), ylim = c(0, 1),
                axes = FALSE, xlab = "", ylab = "", main = title)
           symbols(seq_len(num_colors) - 0.5, rep(0.5, num_colors), circles = rep(0.4, num_colors),
                   inches = FALSE, bg = colors, add = TRUE)
           text(seq_len(num_colors) - 0.5, 0.5, labels = colors, col = "white", cex = 0.8)
         }
  )

  invisible(NULL)
}
