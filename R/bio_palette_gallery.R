#' 🌈 bio_palette_gallery(): Visualize All Palettes in a Gallery View
#'
#' Display palettes from a compiled RDS in a paged gallery format.
#'
#' @param palette_rds Path to compiled RDS.
#'        Default: internal palettes.rds from `inst/extdata/`.
#' @param type Palette types to include: "sequential", "diverging", "qualitative"
#' @param max_palettes Number of palettes per page (default: 30)
#' @param max_row Max colors per row (default: 12)
#' @param verbose Whether to print summary/logs (default: TRUE)
#'
#' @return A named list of ggplot objects (one per page)
#' @export
bio_palette_gallery <- function(palette_rds = NULL,
                                type = c("sequential", "diverging", "qualitative"),
                                max_palettes = 30,
                                max_row = 12,
                                verbose = TRUE) {
  if (!requireNamespace("cli", quietly = TRUE)) stop("Please install 'cli'.")
  if (!requireNamespace("ggplot2", quietly = TRUE)) stop("Please install 'ggplot2'.")

  library(ggplot2)
  type <- match.arg(type, several.ok = TRUE)

  # --- Set default path from inst/extdata
  if (is.null(palette_rds)) {
    palette_rds <- system.file("extdata", "palettes.rds", package = "evanverse")
  }

  # --- Check file
  if (!file.exists(palette_rds)) {
    cli::cli_alert_danger("RDS file not found: {.path {palette_rds}}")
    return(invisible(NULL))
  }

  # --- Load RDS
  palettes <- tryCatch(readRDS(palette_rds), error = function(e) {
    cli::cli_alert_danger("Failed to read palette RDS: {e$message}")
    return(NULL)
  })

  available_types <- names(palettes)
  selected_types <- intersect(type, available_types)
  if (length(selected_types) == 0) {
    cli::cli_alert_warning("No matching types in RDS. Available: {paste(available_types, collapse=', ')}")
    return(invisible(NULL))
  }

  plots <- list()

  for (type_val in selected_types) {
    pal_data <- palettes[[type_val]]
    pal_info <- data.frame(name = names(pal_data), n = lengths(pal_data))
    pal_info <- pal_info[order(-pal_info$n, pal_info$name), ]

    total <- nrow(pal_info)
    pages <- ceiling(total / max_palettes)
    if (verbose) cli::cli_alert_info("🎨 Type {.strong {type_val}}: {total} palettes → {pages} page(s)")

    for (pg in seq_len(pages)) {
      idx <- ((pg - 1) * max_palettes + 1):min(pg * max_palettes, total)
      rows <- pal_info[idx, ]
      y_offset <- 0
      plot_data <- label_data <- data.frame()

      for (i in seq_len(nrow(rows))) {
        colors <- pal_data[[rows$name[i]]]
        n_colors <- length(colors)
        n_rows <- ceiling(n_colors / max_row)

        for (r in seq_len(n_rows)) {
          i_start <- (r - 1) * max_row + 1
          i_end <- min(r * max_row, n_colors)
          row_colors <- colors[i_start:i_end]

          plot_data <- rbind(plot_data, data.frame(
            type = type_val,
            name = rows$name[i],
            x = seq_along(row_colors) * 2,
            y = y_offset,
            color = row_colors
          ))

          label_data <- rbind(label_data, data.frame(
            name = rows$name[i],
            x = 0.8,
            y = y_offset
          ))
          y_offset <- y_offset - 1.5
        }
        y_offset <- y_offset - 0.5
      }

      max_x <- max(plot_data$x)
      p <- ggplot(plot_data, aes(x = x, y = y, fill = color)) +
        geom_tile(width = 1.8, height = 0.7) +
        geom_text(data = label_data, aes(x = x, y = y, label = name),
                  hjust = 1, size = 3.6, inherit.aes = FALSE) +
        scale_fill_identity() +
        scale_x_continuous(expand = c(0, 0)) +
        coord_fixed(xlim = c(-2, max_x + 2), clip = "off") +
        theme_void() +
        theme(plot.margin = margin(20, 20, 20, 20))

      key <- paste0(type_val, "_page", pg)
      plots[[key]] <- p
      if (pg == 1 && verbose) {
        print(p)
        cli::cli_alert_success("✅ Rendered '{type_val}' page 1 of {pages}")
      }
    }
  }

  invisible(plots)
}
