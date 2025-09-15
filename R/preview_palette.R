#' Preview Palette: Visualize a Palette from RDS
#'
#' Preview the appearance of a palette from `data/palettes.rds` using various plot types.
#' This function provides multiple visualization options to help users evaluate color palettes.
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
#'
#' @examples
#' \dontrun{
#' preview_palette("viridis", type = "sequential", plot_type = "bar")
#' preview_palette("RdYlBu", type = "diverging", plot_type = "pie")
#' }
preview_palette <- function(name,
                            type = c("sequential", "diverging", "qualitative"),
                            n = NULL,
                            plot_type = c("bar", "pie", "point", "rect", "circle"),
                            title = name,
                            palette_rds = system.file("extdata", "palettes.rds", package = "evanverse"),
                            preview = TRUE) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================

  # Check for required packages
  if (!requireNamespace("cli", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg cli} is required but not installed.")
  }

  # Validate name parameter
  if (missing(name) || !is.character(name) || length(name) != 1 || is.na(name)) {
    cli::cli_abort("'name' must be a single non-empty character string.")
  }

  # Validate type parameter
  type <- match.arg(type)

  # Validate n parameter
  if (!is.null(n) && (!is.numeric(n) || length(n) != 1 || is.na(n) || n <= 0)) {
    cli::cli_abort("'n' must be a positive integer or NULL.")
  }

  # Validate plot_type parameter
  plot_type <- match.arg(plot_type)

  # Validate title parameter
  if (!is.character(title) || length(title) != 1 || is.na(title)) {
    cli::cli_abort("'title' must be a single character string.")
  }

  # Validate palette_rds parameter
  if (!is.character(palette_rds) || length(palette_rds) != 1 || is.na(palette_rds)) {
    cli::cli_abort("'palette_rds' must be a single character string.")
  }

  # Check if palette file exists
  if (!file.exists(palette_rds)) {
    cli::cli_abort("Palette file not found: {.file {palette_rds}}")
  }

  # Validate preview parameter
  if (!is.logical(preview) || length(preview) != 1 || is.na(preview)) {
    cli::cli_abort("'preview' must be a single logical value.")
  }

  # ===========================================================================
  # Main logic
  # ===========================================================================

  # Get the palette colors
  colors <- get_palette(name = name, type = type, n = n, palette_rds = palette_rds)
  num_colors <- length(colors)

  # If preview is FALSE, return early
  if (!preview) {
    return(invisible(NULL))
  }

  # Display information
  cli::cli_h2("Previewing palette: {.val {name}}")
  cli::cli_alert_info("Plot type: {.val {plot_type}}, colors: {.val {num_colors}}")

  # ===========================================================================
  # Plot generation
  # ===========================================================================

  # Generate the appropriate plot based on plot_type
  switch(plot_type,
         "bar" = {
           barplot(rep(1, num_colors), col = colors, border = NA, space = 0,
                   axes = FALSE, main = title, names.arg = colors, las = 2, cex.names = 0.8)
         },
         "pie" = {
           pie(rep(1, num_colors), col = colors, labels = colors, border = "white",
               main = title, cex = 0.8)
         },
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
