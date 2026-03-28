# =============================================================================
# utils_palette.R — Internal helpers for the palette module
# =============================================================================


#' Build plot and label data for one gallery page
#'
#' @param rows data.frame. Palette info (name, n) for this page.
#' @param pal_data List. All palettes for the current type.
#' @param type_val Character. Palette type name.
#' @param max_row Integer. Max colors per row.
#' @return List with `plot_data` and `label_data`.
#'
#' @keywords internal
#' @noRd
.build_palette_gallery_page_data <- function(rows, pal_data, type_val, max_row) {
  y_offset <- 0
  plot_data_list  <- list()
  label_data_list <- list()

  for (i in seq_len(nrow(rows))) {
    colors   <- pal_data[[rows$name[i]]]
    n_colors <- length(colors)
    n_rows   <- ceiling(n_colors / max_row)

    for (r in seq_len(n_rows)) {
      i_start    <- (r - 1) * max_row + 1
      i_end      <- min(r * max_row, n_colors)
      row_colors <- colors[i_start:i_end]

      plot_data_list[[length(plot_data_list) + 1]] <- data.frame(
        type  = type_val,
        name  = rows$name[i],
        x     = seq_along(row_colors) * 2,
        y     = y_offset,
        color = row_colors,
        stringsAsFactors = FALSE
      )

      label_data_list[[length(label_data_list) + 1]] <- data.frame(
        name = rows$name[i],
        x    = 0.8,
        y    = y_offset,
        stringsAsFactors = FALSE
      )

      y_offset <- y_offset - 1.5
    }
    y_offset <- y_offset - 0.5
  }

  list(
    plot_data  = do.call(rbind, plot_data_list),
    label_data = do.call(rbind, label_data_list)
  )
}


#' Build a ggplot object for one gallery page
#'
#' @param plot_data data.frame. Color tile data.
#' @param label_data data.frame. Palette label data.
#' @return A ggplot object.
#'
#' @keywords internal
#' @noRd
.plot_palette_gallery_page <- function(plot_data, label_data) {
  max_x <- max(plot_data$x)

  ggplot2::ggplot(plot_data, ggplot2::aes(x = x, y = y, fill = color)) +
    ggplot2::geom_tile(width = 1.8, height = 0.7) +
    ggplot2::geom_text(
      data = label_data,
      ggplot2::aes(x = x, y = y, label = name),
      hjust = 1, size = 3.6, inherit.aes = FALSE
    ) +
    ggplot2::scale_fill_identity() +
    ggplot2::scale_x_continuous(expand = c(0, 0)) +
    ggplot2::coord_fixed(xlim = c(-2, max_x + 2), clip = "off") +
    ggplot2::theme_void() +
    ggplot2::theme(plot.margin = ggplot2::margin(20, 20, 20, 20))
}


#' Render a palette preview plot
#'
#' @param colors Character vector of HEX color codes.
#' @param plot_type Character. One of "bar", "pie", "point", "rect", "circle".
#' @param title Character. Plot title.
#'
#' @keywords internal
#' @noRd
.plot_palette_preview <- function(colors, plot_type, title) {
  num_colors <- length(colors)

  switch(plot_type,
    "bar" = {
      graphics::barplot(rep(1, num_colors), col = colors, border = NA, space = 0,
        axes = FALSE, main = title, names.arg = colors, las = 2, cex.names = 0.8)
    },
    "pie" = {
      graphics::pie(rep(1, num_colors), col = colors, labels = colors, border = "white",
        main = title, cex = 0.8)
    },
    "point" = {
      graphics::plot(seq_len(num_colors), rep(1, num_colors), pch = 19, cex = 5, col = colors,
        axes = FALSE, xlab = "", ylab = "", main = title)
      graphics::text(seq_len(num_colors), rep(1.2, num_colors), labels = colors, pos = 3, cex = 0.8)
    },
    "rect" = {
      graphics::plot(0, 0, type = "n", xlim = c(0, num_colors), ylim = c(0, 1),
        axes = FALSE, xlab = "", ylab = "", main = title)
      graphics::rect(0:(num_colors - 1), 0, 1:num_colors, 1, col = colors, border = NA)
      graphics::text((0:(num_colors - 1) + 1:num_colors) / 2, 0.5, labels = colors, col = "white", cex = 0.8)
    },
    "circle" = {
      graphics::plot(0, 0, type = "n", xlim = c(0, num_colors), ylim = c(0, 1),
        axes = FALSE, xlab = "", ylab = "", main = title)
      graphics::symbols(seq_len(num_colors) - 0.5, rep(0.5, num_colors), circles = rep(0.4, num_colors),
        inches = FALSE, bg = colors, add = TRUE)
      graphics::text(seq_len(num_colors) - 0.5, 0.5, labels = colors, col = "white", cex = 0.8)
    }
  )

  invisible(NULL)
}


#' Read and validate a single palette JSON file
#'
#' Parses the file, checks required fields, type validity, and HEX codes.
#' Returns NULL (with a warning) on any failure so the caller can skip.
#'
#' @param json_file Character. Path to the JSON file.
#' @return Named list with `name`, `type`, `colors`, or NULL on failure.
#'
#' @keywords internal
#' @noRd
.read_palette_json <- function(json_file) {
  palette_info <- tryCatch(jsonlite::fromJSON(json_file), error = function(e) NULL)

  if (is.null(palette_info)) {
    cli::cli_alert_warning("Failed to parse JSON: {.file {json_file}}")
    return(NULL)
  }

  missing_fields <- setdiff(c("name", "type", "colors"), names(palette_info))
  if (length(missing_fields) > 0) {
    cli::cli_alert_warning("Missing fields ({.val {missing_fields}}) in: {.file {json_file}}")
    return(NULL)
  }

  valid_types <- c("sequential", "diverging", "qualitative")
  if (!palette_info$type %in% valid_types) {
    cli::cli_alert_warning("Unknown type {.val {palette_info$type}}, skipping: {.file {json_file}}")
    return(NULL)
  }

  ok <- tryCatch(
    { .assert_hex_colors(palette_info$colors); TRUE },
    error = function(e) {
      cli::cli_alert_warning("Invalid HEX codes in: {.file {json_file}}")
      FALSE
    }
  )
  if (!ok) return(NULL)

  palette_info[c("name", "type", "colors")]
}


#' Load compiled palette data
#'
#' Returns the `palettes` package dataset, with fallbacks for devtools/testthat
#' workflows where lazy-data binding may not be in namespace yet.
#'
#' @return Named list of palettes keyed by type.
#'
#' @keywords internal
#' @noRd
.load_palettes <- function() {
  ns <- asNamespace("evanverse")
  if (exists("palettes", envir = ns, inherits = FALSE)) {
    return(get("palettes", envir = ns, inherits = FALSE))
  }

  pkg_env_name <- "package:evanverse"
  if (pkg_env_name %in% search()) {
    pkg_env <- as.environment(pkg_env_name)
    if (exists("palettes", envir = pkg_env, inherits = FALSE)) {
      return(get("palettes", envir = pkg_env, inherits = FALSE))
    }
  }

  local_rda <- file.path("data", "palettes.rda")
  if (file.exists(local_rda)) {
    e <- new.env(parent = emptyenv())
    load(local_rda, envir = e)
    if (exists("palettes", envir = e, inherits = FALSE)) {
      return(get("palettes", envir = e, inherits = FALSE))
    }
  }

  e <- new.env(parent = emptyenv())
  suppressWarnings(utils::data("palettes", package = "evanverse", envir = e))
  if (exists("palettes", envir = e, inherits = FALSE)) {
    return(get("palettes", envir = e, inherits = FALSE))
  }

  cli::cli_abort(
    "Palette dataset {.val palettes} is unavailable. Rebuild it via {.file data-raw/palettes.R}.",
    call = NULL
  )
}


#' Assert that a numeric vector is a valid RGB triplet
#'
#' @param x Numeric vector of length 3 with values in [0, 255].
#' @param arg Name of the argument (for error messages).
#'
#' @keywords internal
#' @noRd
.assert_rgb_triplet <- function(x, arg = deparse(substitute(x))) {
  if (!is.numeric(x) || length(x) != 3L) {
    cli::cli_abort("{.arg {arg}} must be a numeric vector of length 3.", call = NULL)
  }
  if (anyNA(x) || any(!is.finite(x))) {
    cli::cli_abort("{.arg {arg}} must not contain NA, Inf, or NaN.", call = NULL)
  }
  if (any(x < 0 | x > 255)) {
    cli::cli_abort("{.arg {arg}} values must be in [0, 255].", call = NULL)
  }
  invisible(x)
}


#' Assert that a data.frame has valid r, g, b columns
#'
#' @param x data.frame with columns r, g, b.
#' @param arg Name of the argument (for error messages).
#'
#' @keywords internal
#' @noRd
.assert_rgb_df <- function(x, arg = deparse(substitute(x))) {
  if (!is.data.frame(x)) {
    cli::cli_abort("{.arg {arg}} must be a data.frame.", call = NULL)
  }
  missing_cols <- setdiff(c("r", "g", "b"), names(x))
  if (length(missing_cols) > 0) {
    cli::cli_abort("{.arg {arg}} must have columns {.val {c('r', 'g', 'b')}}. Missing: {.val {missing_cols}}.", call = NULL)
  }
  for (col in c("r", "g", "b")) {
    vals <- x[[col]]
    if (!is.numeric(vals) || anyNA(vals) || any(!is.finite(vals)) || any(vals < 0 | vals > 255)) {
      cli::cli_abort("Column {.val {col}} in {.arg {arg}} must be numeric with values in [0, 255].", call = NULL)
    }
  }
  invisible(x)
}


#' Assert that all values are valid HEX color codes
#'
#' @param x Character vector of HEX color codes.
#' @param arg Name of the argument (for error messages).
#'
#' @keywords internal
#' @noRd
.assert_hex_colors <- function(x, arg = deparse(substitute(x))) {
  if (!is.character(x) || length(x) == 0) {
    cli::cli_abort("{.arg {arg}} must be a non-empty character vector of HEX codes.", call = NULL)
  }
  invalid <- !grepl("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", x)
  if (any(invalid)) {
    cli::cli_abort("{.arg {arg}} contains invalid HEX codes: {.val {x[invalid]}}.", call = NULL)
  }
  invisible(x)
}


#' Return an empty palette metadata data.frame
#'
#' @return Empty data.frame with columns: name, type, n_color, colors.
#'
#' @keywords internal
#' @noRd
.empty_palette_df <- function() {
  data.frame(
    name    = character(),
    type    = character(),
    n_color = integer(),
    colors  = I(list()),
    stringsAsFactors = FALSE
  )
}


#' Print a palette metadata data.frame to console
#'
#' @param palette_df data.frame. Output of list_palettes().
#'
#' @keywords internal
#' @noRd
.print_palette_list <- function(palette_df) {
  cli::cli_h1("Available Color Palettes")
  cli::cli_alert_info("Total: {nrow(palette_df)} palettes")

  type_counts <- table(palette_df$type)
  for (t in names(type_counts)) {
    cli::cli_alert_info("{.strong {t}}: {type_counts[t]} palettes")
  }

  cli::cli_text("")
  cli::cli_ul()
  for (i in seq_len(nrow(palette_df))) {
    cli::cli_li("{.strong {palette_df$name[i]}} ({palette_df$type[i]}) - {palette_df$n_color[i]} colors")
  }
  cli::cli_end()
}


#' Find which type(s) a palette name belongs to
#'
#' @param name Character. Palette name to search for.
#' @param palettes List. Compiled palette data (keyed by type).
#' @return Character vector of matching type names, or NULL if not found.
#'
#' @keywords internal
#' @noRd
.find_palette_type <- function(name, palettes) {
  found <- names(palettes)[sapply(names(palettes), function(t) name %in% names(palettes[[t]]))]
  if (length(found) == 0) return(NULL)
  found
}
