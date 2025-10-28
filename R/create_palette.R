#' create_palette(): Save Custom Color Palettes as JSON
#'
#' Save a named color palette (sequential, diverging, or qualitative) to a JSON file.
#' Used for palette sharing, reuse, and future compilation.
#'
#' @param name Character. Palette name (e.g., "Blues").
#' @param type Character. One of "sequential", "diverging", or "qualitative".
#' @param colors Character vector of HEX color values (e.g., "#E64B35" or "#E64B35B2").
#' @param color_dir Character. Root folder to store palettes (required). Use tempdir() for examples/tests.
#' @param log Logical. Whether to log palette creation to a temporary log file.
#'
#' @return (Invisibly) A list with `path` and `info`.
#' @export
#'
#' @examples
#' # Create palette in temporary directory:
#' temp_dir <- file.path(tempdir(), "palettes")
#' create_palette(
#'   "blues",
#'   "sequential",
#'   c("#deebf7", "#9ecae1", "#3182bd"),
#'   color_dir = temp_dir
#' )
#'
#' create_palette(
#'   "qual_vivid",
#'   "qualitative",
#'   c("#E64B35", "#4DBBD5", "#00A087"),
#'   color_dir = temp_dir
#' )
#'
#' # Clean up
#' unlink(temp_dir, recursive = TRUE)
create_palette <- function(name,
                           type = c("sequential", "diverging", "qualitative"),
                           colors,
                           color_dir,
                           log = TRUE) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  # Validate dependencies
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    cli::cli_abort("Please install the 'jsonlite' package.")
  }
  if (!requireNamespace("cli", quietly = TRUE)) {
    cli::cli_abort("Please install the 'cli' package.")
  }

  # Validate type
  type <- match.arg(type)

  # Validate colors (HEX format)
  valid_hex <- grepl("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", colors)
  if (!all(valid_hex)) {
    cli::cli_abort("Some color values are not valid HEX codes (e.g., '#FF5733' or '#FF5733B2').")
  }

  # Validate name
  if (!is.character(name) || length(name) != 1) {
    cli::cli_abort("Palette name must be a single string.")
  }

  # Validate color_dir (required parameter)
  if (missing(color_dir) || is.null(color_dir) || !is.character(color_dir) || length(color_dir) != 1) {
    cli::cli_abort("'color_dir' must be specified. Use tempdir() for examples/tests.")
  }

  # ===========================================================================
  # Directory Setup Phase
  # ===========================================================================

  palette_dir <- file.path(color_dir, type)
  if (!dir.exists(palette_dir)) {
    dir.create(palette_dir, recursive = TRUE)
    cli::cli_alert_info("Directory created: {palette_dir}")
  }

  json_file <- file.path(palette_dir, paste0(name, ".json"))
  palette_info <- list(name = name, type = type, colors = colors)

  # ===========================================================================
  # File Existence Check Phase
  # ===========================================================================

  if (file.exists(json_file)) {
    cli::cli_alert_warning("Palette already exists: {json_file}")
    return(invisible(list(path = json_file, info = palette_info)))
  }

  # ===========================================================================
  # JSON Saving Phase
  # ===========================================================================

  tryCatch({
    jsonlite::write_json(palette_info, path = json_file, pretty = TRUE, auto_unbox = TRUE)
    cli::cli_alert_success("Palette saved: {json_file}")
  }, error = function(e) {
    cli::cli_abort("Failed to write JSON: {e$message}")
  })

  # ===========================================================================
  # Logging Phase
  # ===========================================================================

  if (log) {
    log_path <- file.path(tempdir(), "logs", "palettes", "create_palette.log")
    dir.create(dirname(log_path), recursive = TRUE, showWarnings = FALSE)

    entry <- paste(
      Sys.time(), "|", name, "|", type,
      "|", length(colors), "colors",
      "|", json_file
    )

    tryCatch({
      con <- file(log_path, open = "a")
      on.exit(close(con), add = TRUE)
      writeLines(entry, con = con)
    }, error = function(e) {
      cli::cli_alert_danger("Failed to write log: {e$message}")
    })
  }

  invisible(list(path = json_file, info = palette_info))
}
