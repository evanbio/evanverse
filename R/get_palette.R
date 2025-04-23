#' 🎨 get_palette(): Load Color Palette from RDS
#'
#' Load a named palette from `data/palettes.rds`, returning a vector of HEX colors.
#' Automatically checks for type mismatch and gives smart suggestions.
#'
#' @param name Name of the palette (e.g. "vividset").
#' @param type One of: `"sequential"`, `"diverging"`, `"qualitative"`.
#' @param n Number of colors to return. Default `NULL` returns all.
#' @param palette_rds Path to RDS file. Default: `here::here("data/palettes.rds")`.
#'
#' @return A character vector of HEX color codes.
#' @export
#'
#' @examples
#' get_palette("vividset", type = "qualitative")
#' get_palette("softtrio", type = "qualitative", n = 2)
get_palette <- function(name,
                        type = c("sequential", "diverging", "qualitative"),
                        n = NULL,
                        palette_rds = system.file("extdata", "palettes.rds", package = "evanverse")) {

  # --- Check dependencies
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Package 'cli' required. Please install it.")
  }

  type <- match.arg(type)

  # --- Check file
  if (!file.exists(palette_rds)) {
    cli::cli_alert_danger("Palette file not found at: {.path {palette_rds}}")
    stop("Please compile palettes first via `compile_palettes()`.")
  }

  palettes <- readRDS(palette_rds)
  valid_types <- names(palettes)

  # --- Check name
  if (!is.character(name) || length(name) != 1) {
    stop("Palette name must be a single string.")
  }

  if (!type %in% valid_types) {
    cli::cli_alert_danger("Invalid type '{type}'. Must be one of: {.val {valid_types}}.")
    stop("Invalid palette type.")
  }

  if (!name %in% names(palettes[[type]])) {
    found_type <- purrr::detect(valid_types, ~ name %in% names(palettes[[.x]]))

    if (!is.null(found_type)) {
      cli::cli_alert_warning("'{name}' not found under '{type}', but exists under '{found_type}'.")
      cli::cli_alert_info("Try: get_palette('{name}', type = '{found_type}')")
      stop(sprintf("'%s' not found under '%s', but exists under '%s'.", name, type, found_type))
    } else {
      cli::cli_alert_danger("Palette '{name}' not found in any type.")
      stop(sprintf("Palette '%s' not found in any type.", name))
    }
  }

  # --- Extract colors
  colors <- palettes[[type]][[name]]
  cli::cli_alert_success("Loaded palette '{name}' ({type}), {length(colors)} colors.")

  # --- Return all if n is NULL
  if (is.null(n)) return(colors)

  # --- Check and return subset
  if (!is.numeric(n) || length(n) != 1 || n <= 0 || n != round(n)) {
    cli::cli_alert_danger("Invalid `n`: must be a single positive integer.")
    stop("Invalid `n`: must be a single positive integer.")
  }

  if (n > length(colors)) {
    stop(sprintf("Palette '%s' only has %d colors, but requested %d.", name, length(colors), n))
  }

  return(colors[seq_len(n)])
}
