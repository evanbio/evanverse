# =============================================================================
# palette.R — Color palette management functions
# =============================================================================

#' Get a Color Palette
#'
#' Retrieve a named palette by name and type, returning a vector of HEX colors.
#' Automatically checks for type mismatch and provides smart suggestions.
#'
#' @param name Character. Name of the palette (e.g. "qual_vivid").
#' @param type Character. One of "sequential", "diverging", "qualitative". If NULL, type is auto-detected.
#' @param n Integer. Number of colors to return. If NULL, returns all colors. Default is NULL.
#'
#' @return Character vector of HEX color codes.
#'
#' @examples
#' get_palette("qual_vivid", type = "qualitative")
#' get_palette("qual_softtrio", type = "qualitative", n = 2)
#' get_palette("seq_blues", type = "sequential", n = 3)
#' get_palette("div_contrast", type = "diverging")
#'
#' @export
get_palette <- function(name,
                        type = NULL,
                        n = NULL) {

  # Validate inputs
  .assert_scalar_string(name)
  if (!is.null(type)) type <- match.arg(type, c("sequential", "diverging", "qualitative"))
  if (!is.null(n)) .assert_count(n)

  palettes <- .load_palettes()

  # Auto-detect type if not provided
  if (is.null(type)) {
    found <- .find_palette_type(name, palettes)
    if (is.null(found)) cli::cli_abort("Palette {.val {name}} not found in any type.", call = NULL)
    if (length(found) > 1) {
      cli::cli_alert_warning("Found in multiple types: {.val {found}}. Using {.val {found[1]}}. Specify {.arg type} to override.")
    }
    type <- found[1]
  } else {
    # type specified — verify name exists under it
    if (!name %in% names(palettes[[type]])) {
      found <- .find_palette_type(name, palettes)
      if (!is.null(found)) {
        cli::cli_abort("Palette {.val {name}} not found under {.val {type}}, but exists under {.val {found}}. Try: {.code get_palette(\"{name}\", type = \"{found[1]}\")}",  call = NULL)
      } else {
        cli::cli_abort("Palette {.val {name}} not found in any type.", call = NULL)
      }
    }
  }

  colors <- palettes[[type]][[name]]

  if (is.null(n)) return(colors)

  # Return requested subset
  if (n > length(colors)) {
    cli::cli_abort("Palette {.val {name}} only has {.val {length(colors)}} colors, but requested {.val {n}}.", call = NULL)
  }

  colors[seq_len(n)]
}


#' List Available Color Palettes
#'
#' Return a data.frame of all available palette metadata, optionally filtered by type.
#'
#' @param type Palette type(s) to filter: `"sequential"`, `"diverging"`, `"qualitative"`. Default NULL returns all.
#' @param sort Whether to sort by type, n_color, name. Default: TRUE.
#'
#' @return A `data.frame` with columns: `name`, `type`, `n_color`, `colors`.
#' @export
#'
#' @examples
#' list_palettes()
#' list_palettes(type = "qualitative")
#' list_palettes(type = c("sequential", "diverging"))
list_palettes <- function(type = NULL,
                          sort = TRUE) {

  # Validate inputs
  .assert_flag(sort)

  palettes <- .load_palettes()

  # Resolve type: NULL means all available types
  if (!is.null(type)) {
    type <- match.arg(type, c("sequential", "diverging", "qualitative"), several.ok = TRUE)
  } else {
    type <- names(palettes)
  }

  matched_types <- intersect(type, names(palettes))

  if (length(matched_types) == 0) {
    cli::cli_alert_warning("No matching types. Available: {.val {names(palettes)}}")
    return(.empty_palette_df())
  }

  # Build palette metadata data.frame
  palette_df <- do.call(rbind, lapply(matched_types, function(t) {
    pset <- palettes[[t]]
    if (length(pset) == 0) return(NULL)
    data.frame(
      name    = names(pset),
      type    = t,
      n_color = lengths(pset),
      colors  = I(unname(pset)),
      stringsAsFactors = FALSE
    )
  }))

  if (sort) {
    palette_df <- palette_df[order(palette_df$type, palette_df$n_color, palette_df$name), ]
  }

  palette_df
}


#' Create and Save a Custom Color Palette
#'
#' Save a named color palette to a JSON file for future compilation and reuse.
#'
#' @param name Character. Palette name (e.g., "blues").
#' @param type Character. One of "sequential", "diverging", or "qualitative".
#' @param colors Character vector of HEX color values (e.g., "#E64B35" or "#E64B35B2").
#' @param color_dir Character. Root folder to store palettes. Use tempdir() for examples/tests.
#' @param overwrite Logical. If TRUE, overwrite existing palette file. Default: FALSE.
#'
#' @return Invisibly returns a list with `path` and `info`.
#' @export
#'
#' @examples
#' temp_dir <- file.path(tempdir(), "palettes")
#' create_palette("blues", "sequential", c("#deebf7", "#9ecae1", "#3182bd"), color_dir = temp_dir)
#' create_palette("qual_vivid", "qualitative", c("#E64B35", "#4DBBD5", "#00A087"), color_dir = temp_dir)
#'
#' # Overwrite an existing palette explicitly
#' create_palette("blues", "sequential", c("#c6dbef", "#6baed6", "#2171b5"), color_dir = temp_dir, overwrite = TRUE)
#'
#' unlink(temp_dir, recursive = TRUE)
create_palette <- function(name,
                           type = c("sequential", "diverging", "qualitative"),
                           colors,
                           color_dir,
                           overwrite = FALSE) {

  # Validate inputs
  .assert_scalar_string(name)
  type <- match.arg(type)
  .assert_hex_colors(colors)
  .assert_dir_path(color_dir)
  .assert_flag(overwrite)

  # Create type subdirectory if needed
  palette_dir <- file.path(color_dir, type)
  if (!dir.exists(palette_dir)) {
    ok <- dir.create(palette_dir, recursive = TRUE, showWarnings = FALSE)
    if (!ok) cli::cli_abort("Failed to create directory: {.path {palette_dir}}", call = NULL)
  }

  json_file <- file.path(palette_dir, paste0(name, ".json"))
  palette_info <- list(name = name, type = type, colors = colors)

  # Guard against accidental overwrite
  if (file.exists(json_file)) {
    if (!overwrite) {
      cli::cli_abort("Palette {.val {name}} already exists. Use {.code overwrite = TRUE} to replace.", call = NULL)
    }
    cli::cli_alert_info("Overwriting existing palette: {.val {name}}")
  }

  # Write JSON
  tryCatch({
    jsonlite::write_json(palette_info, path = json_file, pretty = TRUE, auto_unbox = TRUE)
    cli::cli_alert_success("Palette saved: {.file {json_file}}")
  }, error = function(e) {
    cli::cli_abort("Failed to write JSON: {e$message}", call = NULL)
  })

  invisible(list(path = json_file, info = palette_info))
}


#' Preview a Color Palette
#'
#' Visualize a palette using various plot styles.
#'
#' @param name Character. Name of the palette.
#' @param type Character. One of "sequential", "diverging", "qualitative". If NULL, auto-detected.
#' @param n Integer. Number of colors to use. If NULL, uses all. Default: NULL.
#' @param plot_type Character. One of "bar", "pie", "point", "rect", "circle". Default: "bar".
#' @param title Character. Plot title. If NULL, defaults to palette name.
#'
#' @return Invisibly returns NULL. Called for plotting side effect.
#' @export
#'
#' @examples
#' \donttest{
#' preview_palette("seq_blues", plot_type = "bar")
#' preview_palette("div_fireice", plot_type = "pie")
#' preview_palette("qual_vivid", n = 4, plot_type = "circle")
#' }
preview_palette <- function(name,
                            type = NULL,
                            n = NULL,
                            plot_type = c("bar", "pie", "point", "rect", "circle"),
                            title = NULL) {

  # Validate inputs
  .assert_scalar_string(name)
  if (!is.null(type)) type <- match.arg(type, c("sequential", "diverging", "qualitative"))
  if (!is.null(n)) .assert_count(n)
  plot_type <- match.arg(plot_type)
  if (is.null(title)) title <- name else .assert_scalar_string(title)

  colors <- get_palette(name = name, type = type, n = n)
  .plot_palette_preview(colors, plot_type, title)

  invisible(NULL)
}


#' Visualize All Palettes in a Gallery View
#'
#' Display palettes in a paged gallery format, returning a named list of ggplot objects.
#'
#' @param type Palette types to include: "sequential", "diverging", "qualitative". Default NULL returns all.
#' @param max_palettes Number of palettes per page. Default: 30.
#' @param max_row Max colors per row. Default: 12.
#' @param verbose Whether to print progress info. Default: TRUE.
#'
#' @return A named list of ggplot objects (one per page).
#' @export
palette_gallery <- function(type = NULL,
                                max_palettes = 30,
                                max_row = 12,
                                verbose = TRUE) {

  # Validate inputs
  .assert_count(max_palettes)
  .assert_count(max_row)
  .assert_flag(verbose)

  palettes <- .load_palettes()

  # Resolve type: NULL means all available types
  if (!is.null(type)) {
    type <- match.arg(type, c("sequential", "diverging", "qualitative"), several.ok = TRUE)
  } else {
    type <- names(palettes)
  }

  selected_types <- intersect(type, names(palettes))
  if (length(selected_types) == 0) return(list())

  plots <- list()

  for (type_val in selected_types) {
    pal_data <- palettes[[type_val]]

    pal_info <- data.frame(name = names(pal_data), n = lengths(pal_data))
    pal_info <- pal_info[order(-pal_info$n, pal_info$name), ]

    total <- nrow(pal_info)
    pages <- ceiling(total / max_palettes)

    if (verbose) cli::cli_alert_info("Type {.strong {type_val}}: {total} palettes -> {pages} page(s)")

    for (pg in seq_len(pages)) {
      idx  <- ((pg - 1) * max_palettes + 1):min(pg * max_palettes, total)
      rows <- pal_info[idx, ]

      page  <- .build_palette_gallery_page_data(rows, pal_data, type_val, max_row)
      p     <- .plot_palette_gallery_page(page$plot_data, page$label_data)
      key   <- paste0(type_val, "_page", pg)
      plots[[key]] <- p

      if (verbose) cli::cli_alert_success("Built {.val {key}}")
    }
  }

  plots
}


#' Compile JSON Palettes into RDS
#'
#' Read JSON files under `palettes_dir/`, validate content, and compile into a structured RDS file.
#'
#' @param palettes_dir Character. Folder containing subdirs: sequential/, diverging/, qualitative/.
#' @param output_rds Character. Path to save compiled RDS file. Use tempdir() for examples/tests.
#'
#' @return Invisibly returns RDS file path (character).
#'
#' @examples
#' \donttest{
#' compile_palettes(
#'   palettes_dir = system.file("extdata", "palettes", package = "evanverse"),
#'   output_rds = file.path(tempdir(), "palettes.rds")
#' )
#' }
#'
#' @export
compile_palettes <- function(palettes_dir, output_rds) {

  # Validate inputs
  .assert_dir_path(palettes_dir)
  .assert_dir_path(output_rds)

  if (!dir.exists(palettes_dir)) {
    cli::cli_abort("Palettes directory does not exist: {.path {palettes_dir}}", call = NULL)
  }

  # Locate JSON files across all type subdirectories
  json_files <- sort(unlist(lapply(
    c("sequential", "diverging", "qualitative"),
    function(type) list.files(file.path(palettes_dir, type), pattern = "\\.json$", full.names = TRUE)
  )))

  if (length(json_files) == 0) {
    cli::cli_abort("No JSON files found under {.path {palettes_dir}}", call = NULL)
  }

  palettes <- list(sequential = list(), diverging = list(), qualitative = list())

  for (json_file in json_files) {
    p <- .read_palette_json(json_file)
    if (is.null(p)) next

    if (p$name %in% names(palettes[[p$type]])) {
      cli::cli_alert_warning("Duplicate palette {.val {p$name}} in {.val {p$type}}, overwriting.")
    }

    palettes[[p$type]][[p$name]] <- p$colors
  }

  # Ensure output directory exists
  out_dir <- dirname(output_rds)
  if (!dir.exists(out_dir)) {
    ok <- dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
    if (!ok) cli::cli_abort("Failed to create output directory: {.path {out_dir}}", call = NULL)
  }

  tryCatch({
    saveRDS(palettes, file = output_rds)
    cli::cli_alert_success("Saved: {.file {output_rds}}")
  }, error = function(e) {
    cli::cli_abort("Failed to save RDS: {e$message}", call = NULL)
  })

  total <- sum(lengths(palettes))
  cli::cli_alert_success("Compiled {total} palette{?s}: Sequential={length(palettes$sequential)}, Diverging={length(palettes$diverging)}, Qualitative={length(palettes$qualitative)}")

  invisible(output_rds)
}


#' Remove a Saved Palette JSON
#'
#' Remove a palette JSON file by name, searching across types if needed.
#'
#' @param name Character. Palette name (without '.json' suffix).
#' @param type Character. One of "sequential", "diverging", "qualitative". If NULL, searches all types.
#' @param color_dir Character. Root folder where palettes are stored.
#'
#' @return Invisibly TRUE if removed successfully, FALSE otherwise.
#' @export
#'
#' @examples
#' \dontrun{
#' remove_palette("seq_blues", color_dir = "path/to/palettes")
#' remove_palette("qual_vivid", type = "qualitative", color_dir = "path/to/palettes")
#' }
remove_palette <- function(name,
                            type = NULL,
                            color_dir) {

  # Validate inputs
  .assert_scalar_string(name)
  .assert_dir_path(color_dir)
  if (!is.null(type)) type <- match.arg(type, c("sequential", "diverging", "qualitative"))

  # Search specified type first, then others
  valid_types <- c("sequential", "diverging", "qualitative")
  types_to_try <- if (is.null(type)) valid_types else c(type, setdiff(valid_types, type))

  for (current_type in types_to_try) {
    json_file <- file.path(color_dir, current_type, paste0(name, ".json"))

    if (file.exists(json_file)) {
      ok <- tryCatch({
        isTRUE(file.remove(json_file))
      }, error = function(e) {
        cli::cli_alert_warning("Failed to remove: {.file {json_file}} - {e$message}")
        FALSE
      })

      if (ok) {
        cli::cli_alert_success("Removed {.val {name}} from {.strong {current_type}}")
        return(invisible(TRUE))
      }
    }
  }

  cli::cli_alert_warning("Palette {.val {name}} not found in any type.")
  invisible(FALSE)
}


#' Convert HEX Colors to RGB
#'
#' Convert a character vector of HEX color codes to a data.frame with columns
#' `r`, `g`, `b`. Row names are set to the input HEX values.
#'
#' @param hex Character vector of HEX color codes (e.g. `"#FF8000"` or `"#FF8000B2"`).
#'   Both 6-digit and 8-digit (with alpha) codes are accepted. Alpha is silently ignored.
#'   The `#` prefix is required. No NA values allowed.
#'
#' @return A data.frame with columns `hex`, `r`, `g`, `b`.
#'
#' @examples
#' hex2rgb("#FF8000")
#' hex2rgb(c("#FF8000", "#00FF00"))
#'
#' @export
hex2rgb <- function(hex) {

  # Validate inputs
  .assert_hex_colors(hex)

  hex_clean <- gsub("^#", "", hex)

  result <- data.frame(
    hex = hex,
    r   = as.double(strtoi(substr(hex_clean, 1, 2), 16L)),
    g   = as.double(strtoi(substr(hex_clean, 3, 4), 16L)),
    b   = as.double(strtoi(substr(hex_clean, 5, 6), 16L)),
    stringsAsFactors = FALSE
  )

  result
}


#' Convert RGB Values to HEX Color Codes
#'
#' Convert RGB values to HEX color codes. Accepts either a numeric vector of
#' length 3 or a data.frame with columns `r`, `g`, `b` (symmetric with `hex2rgb()`).
#'
#' @param rgb A numeric vector of length 3 (e.g., `c(255, 128, 0)`), or a
#'   data.frame with columns `r`, `g`, `b`. Values must be in \[0, 255\].
#'   Non-integer values are rounded to the nearest integer before conversion.
#'
#' @return A character vector of HEX color codes.
#'
#' @examples
#' rgb2hex(c(255, 128, 0))
#' rgb2hex(hex2rgb(c("#FF8000", "#00FF00")))
#'
#' @export
rgb2hex <- function(rgb) {

  if (is.data.frame(rgb)) {
    .assert_rgb_df(rgb)
    mapply(
      function(r, g, b) grDevices::rgb(round(r), round(g), round(b), maxColorValue = 255),
      rgb$r, rgb$g, rgb$b,
      USE.NAMES = FALSE
    )
  } else {
    .assert_rgb_triplet(rgb)
    grDevices::rgb(round(rgb[1]), round(rgb[2]), round(rgb[3]), maxColorValue = 255)
  }
}
