#' bio_palette_gallery(): Visualize All Palettes in a Gallery View
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

  # Validate and set default type parameters
  type <- match.arg(type, several.ok = TRUE)

  # ===========================================================================
  # Data Preparation Phase
  # ===========================================================================
  
  # --- Set default RDS file path
  if (is.null(palette_rds)) {
    palette_rds <- system.file("extdata", "palettes.rds", package = "evanverse")
  }

  # --- Check if file exists
  if (!file.exists(palette_rds)) {
    cli::cli_alert_danger("RDS file not found: {.path {palette_rds}}")
    return(invisible(list()))
  }

  # --- Safely read RDS file
  palettes <- tryCatch(readRDS(palette_rds), error = function(e) {
    cli::cli_alert_danger("Failed to read palette RDS: {e$message}")
    return(NULL)
  })
  if (is.null(palettes)) return(invisible(list()))

  # --- Filter user-specified palette types
  available_types <- names(palettes)
  selected_types <- intersect(type, available_types)
  if (length(selected_types) == 0) {
    cli::cli_alert_warning("No matching types in RDS. Available: {paste(available_types, collapse=', ')}")
    return(invisible(list()))
  }

  # ===========================================================================
  # Main Loop: Generate Paged Graphics for Each Type
  # ===========================================================================
  
  plots <- list()  # Store all generated plots

  # Iterate through each palette type (sequential, diverging, qualitative)
  for (type_val in selected_types) {
    pal_data <- palettes[[type_val]]  # Get all palettes for current type
    
    # --- Prepare palette info and sort (by length desc, name asc)
    pal_info <- data.frame(name = names(pal_data), n = lengths(pal_data))
    pal_info <- pal_info[order(-pal_info$n, pal_info$name), ]

    # --- Calculate pagination info
    total <- nrow(pal_info)
    pages <- ceiling(total / max_palettes)
    if (verbose) {
      cli::cli_alert_info("Type {.strong {type_val}}: {total} palettes → {pages} page(s)")
    }

    # =========================================================================
    # Inner Loop: Generate Each Page
    # =========================================================================
    
    for (pg in seq_len(pages)) {
      # --- Determine palette index range for current page
      idx <- ((pg - 1) * max_palettes + 1):min(pg * max_palettes, total)
      rows <- pal_info[idx, ]  # Palette info for current page
      y_offset <- 0           # Y-axis offset for vertical arrangement

      # --- Initialize data collection lists (avoid frequent data merging in loops)
      plot_data_list <- list()   # Color tile data
      label_data_list <- list()  # Label data

      # =======================================================================
      # Build Page Data: Iterate Through Each Palette on Current Page
      # =======================================================================
      
      for (i in seq_len(nrow(rows))) {
        colors <- pal_data[[rows$name[i]]]  # Get color vector for palette
        n_colors <- length(colors)          # Total number of colors
        n_rows <- ceiling(n_colors / max_row)  # Required number of rows

        # Handle multi-row display for long palettes
        for (r in seq_len(n_rows)) {
          # --- Calculate color range for current row
          i_start <- (r - 1) * max_row + 1
          i_end <- min(r * max_row, n_colors)
          row_colors <- colors[i_start:i_end]

          # --- Build color tile data (one rectangle per color)
          plot_data_list[[length(plot_data_list) + 1]] <- data.frame(
            type = type_val,                      # Palette type
            name = rows$name[i],                  # Palette name
            x = seq_along(row_colors) * 2,        # X coordinate (horizontal spacing = 2)
            y = y_offset,                         # Y coordinate (current row position)
            color = row_colors,                   # Color values
            stringsAsFactors = FALSE
          )

          # --- Build label data (one palette name per row)
          label_data_list[[length(label_data_list) + 1]] <- data.frame(
            name = rows$name[i],  # Palette name
            x = 0.8,              # Label X position (left side)
            y = y_offset,         # Label Y position (same row as tiles)
            stringsAsFactors = FALSE
          )
          
          y_offset <- y_offset - 1.5  # Row spacing
        }
        y_offset <- y_offset - 0.5  # Palette spacing (extra gap)
      }

      # =======================================================================
      # Data Merging and Plot Creation
      # =======================================================================
      
      # --- Combine all data at once (performance optimization)
      plot_data <- dplyr::bind_rows(plot_data_list)
      label_data <- dplyr::bind_rows(label_data_list)

      # --- Create ggplot graphic
      max_x <- max(plot_data$x)  # Determine X-axis range
      p <- ggplot2::ggplot(plot_data, ggplot2::aes(x = x, y = y, fill = color)) +
        # Draw color tiles
        ggplot2::geom_tile(width = 1.8, height = 0.7) +
        # Add palette name labels
        ggplot2::geom_text(
          data = label_data, 
          ggplot2::aes(x = x, y = y, label = name),
          hjust = 1, size = 3.6, inherit.aes = FALSE
        ) +
        # Use actual color values for fill
        ggplot2::scale_fill_identity() +
        # Set X-axis range and margins
        ggplot2::scale_x_continuous(expand = c(0, 0)) +
        # Fixed aspect ratio, set display range
        ggplot2::coord_fixed(xlim = c(-2, max_x + 2), clip = "off") +
        # Clean theme
        ggplot2::theme_void() +
        ggplot2::theme(plot.margin = ggplot2::margin(20, 20, 20, 20))

      # --- Store plot and display first page
      key <- paste0(type_val, "_page", pg)  # Generate unique key name
      plots[[key]] <- p
      
      # Display first page of each type (optional)
      if (pg == 1 && verbose) {
        print(p)
        cli::cli_alert_success("Rendered '{type_val}' page 1 of {pages}")
      }
    }
  }

  # Return invisible list of all plots
  invisible(plots)
}
