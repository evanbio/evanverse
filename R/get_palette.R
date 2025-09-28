#' Get Palette: Load Color Palette from RDS
#'
#' Load a named palette from data/palettes.rds, returning a vector of HEX colors.
#' Automatically checks for type mismatch and provides smart suggestions.
#'
#' @param name Character. Name of the palette (e.g. "vividset").
#' @param type Character. One of "sequential", "diverging", "qualitative".
#' @param n Integer. Number of colors to return. If NULL, returns all colors. Default is NULL.
#' @param palette_rds Character. Path to RDS file. Default uses system file in package.
#'
#' @return Character vector of HEX color codes.
#'
#' @examples
#' get_palette("vividset", type = "qualitative")
#' get_palette("softtrio", type = "qualitative", n = 2)
#' get_palette("blues", type = "sequential", n = 3)
#' get_palette("contrast_duo", type = "diverging")
#'
#' @export
get_palette <- function(name,
                        type = c("sequential", "diverging", "qualitative"),
                        n = NULL,
                        palette_rds = system.file("extdata", "palettes.rds", package = "evanverse")) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================

  # Check for required packages
  if (!requireNamespace("cli", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg cli} is required but not installed.")
  }
  if (!requireNamespace("purrr", quietly = TRUE)) {
    cli::cli_abort("Package {.pkg purrr} is required but not installed.")
  }

  # Validate name parameter
  if (missing(name) || !is.character(name) || length(name) != 1 || is.na(name) || name == "") {
    cli::cli_abort("'name' must be a single non-empty character string.")
  }

  # Validate and normalize type parameter
  type <- match.arg(type)

  # Validate n parameter
  if (!is.null(n)) {
    if (!is.numeric(n) || length(n) != 1 || is.na(n) || n <= 0 || n != round(n)) {
      cli::cli_abort("'n' must be a single positive integer.")
    }
  }

  # Validate palette file path
  if (!is.character(palette_rds) || length(palette_rds) != 1 || is.na(palette_rds)) {
    cli::cli_abort("'palette_rds' must be a single character string.")
  }

  # ===========================================================================
  # File loading
  # ===========================================================================

  # Check if file exists
  if (!file.exists(palette_rds)) {
    cli::cli_abort("Palette file not found: {.file {palette_rds}}. Please compile palettes first via {.fn compile_palettes}.")
  }

  # Load palette data
  palettes <- readRDS(palette_rds)
  valid_types <- names(palettes)

  # ===========================================================================
  # Palette lookup
  # ===========================================================================

  # Check if type exists
  if (!type %in% valid_types) {
    cli::cli_abort("Invalid type {.val {type}}. Must be one of: {.val {valid_types}}")
  }

  # Check if palette name exists in specified type
  if (!name %in% names(palettes[[type]])) {
    # Search for palette in other types
    found_type <- purrr::detect(valid_types, ~ name %in% names(palettes[[.x]]))

    if (!is.null(found_type)) {
      cli::cli_abort("Palette {.val {name}} not found under {.val {type}}, but exists under {.val {found_type}}. Try: {.code get_palette(\"{name}\", type = \"{found_type}\")}")
    } else {
      cli::cli_abort("Palette {.val {name}} not found in any type.")
    }
  }

  # ===========================================================================
  # Color extraction
  # ===========================================================================

  # Extract color vector
  colors <- palettes[[type]][[name]]
  cli::cli_alert_success("Loaded palette {.val {name}} ({.val {type}}), {.val {length(colors)}} colors")

  # Return all colors if n is NULL
  if (is.null(n)) {
    return(colors)
  }

  # ===========================================================================
  # Subset processing
  # ===========================================================================

  # Check if requested number is available
  if (n > length(colors)) {
    cli::cli_abort("Palette {.val {name}} only has {.val {length(colors)}} colors, but requested {.val {n}}.")
  }

  # Return subset of colors
  return(colors[seq_len(n)])
}
