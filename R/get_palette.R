#' get_palette: Load Color Palette from RDS
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
#' get_palette("plasma", type = "sequential", n = 5)
#' get_palette("RdYlBu", type = "diverging")
#'
#' @export
get_palette <- function(name,
                        type = c("sequential", "diverging", "qualitative"),
                        n = NULL,
                        palette_rds = system.file("extdata", "palettes.rds", package = "evanverse")) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  # Validate name parameter
  if (!is.character(name) || length(name) != 1 || is.na(name) || name == "") {
    stop("'name' must be a single non-empty character string.", call. = FALSE)
  }

  # Validate and normalize type parameter
  type <- match.arg(type)

  # Validate n parameter
  if (!is.null(n)) {
    if (!is.numeric(n) || length(n) != 1 || is.na(n) || n <= 0 || n != round(n)) {
      stop("'n' must be a single positive integer.", call. = FALSE)
    }
  }

  # Validate palette file path
  if (!is.character(palette_rds) || length(palette_rds) != 1) {
    stop("'palette_rds' must be a single character string.", call. = FALSE)
  }

  # ===========================================================================
  # File Loading Phase
  # ===========================================================================

  # Check if file exists
  if (!file.exists(palette_rds)) {
    cli::cli_alert_danger("Palette file not found at: {.path {palette_rds}}")
    stop("Please compile palettes first via compile_palettes().", call. = FALSE)
  }

  # Load palette data
  palettes <- readRDS(palette_rds)
  valid_types <- names(palettes)

  # ===========================================================================
  # Palette Lookup Phase
  # ===========================================================================

  # Check if type exists
  if (!type %in% valid_types) {
    cli::cli_alert_danger("Invalid type '{type}'. Must be one of: {.val {valid_types}}")
    stop("Invalid palette type.", call. = FALSE)
  }

  # Check if palette name exists in specified type
  if (!name %in% names(palettes[[type]])) {
    # Search for palette in other types using purrr
    found_type <- purrr::detect(valid_types, ~ name %in% names(palettes[[.x]]))

    if (!is.null(found_type)) {
      cli::cli_alert_warning("'{name}' not found under '{type}', but exists under '{found_type}'")
      cli::cli_alert_info("Try: get_palette('{name}', type = '{found_type}')")
      stop("Palette '", name, "' not found under '", type, "', but exists under '", found_type, "'.", call. = FALSE)
    } else {
      cli::cli_alert_danger("Palette '{name}' not found in any type")
      stop("Palette '", name, "' not found in any type.", call. = FALSE)
    }
  }

  # ===========================================================================
  # Color Extraction Phase
  # ===========================================================================

  # Extract color vector
  colors <- palettes[[type]][[name]]
  cli::cli_alert_success("Loaded palette '{name}' ({type}), {length(colors)} colors")

  # Return all colors if n is NULL
  if (is.null(n)) {
    return(colors)
  }

  # ===========================================================================
  # Subset Processing Phase
  # ===========================================================================

  # Check if requested number is available
  if (n > length(colors)) {
    stop("Palette '", name, "' only has ", length(colors), " colors, but requested ", n, ".", call. = FALSE)
  }

  # Return subset of colors
  return(colors[seq_len(n)])
}
