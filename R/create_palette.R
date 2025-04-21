#' 🎨 create_palette(): Save Custom Color Palettes as JSON
#'
#' Save a named color palette (sequential, diverging, or qualitative) to a JSON file.
#' Used for palette sharing, reuse, and future compilation.
#'
#' @param name Character. Palette name (e.g., "Blues").
#' @param type Character. One of "sequential", "diverging", or "qualitative".
#' @param colors Character vector of HEX color values (e.g., "#E64B35" or "#E64B35B2").
#' @param color_dir Root folder to store palettes (default: "inst/extdata/palettes").
#' @param log Logical. Whether to log palette creation in "logs/palettes/create_palette.log".
#'
#' @return (Invisibly) A list with `path` and `info`.
#' @export
#'
#' @examples
#' create_palette("blues", "sequential", c("#deebf7", "#9ecae1", "#3182bd"))
#' create_palette("vividset", "qualitative", c("#E64B35", "#4DBBD5", "#00A087"))
create_palette <- function(name,
                           type = c("sequential", "diverging", "qualitative"),
                           colors,
                           color_dir = "inst/extdata/palettes",
                           log = TRUE) {
  #-- Dependency check
  if (!requireNamespace("jsonlite", quietly = TRUE)) {
    stop("Please install the 'jsonlite' package.", call. = FALSE)
  }
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Please install the 'cli' package.", call. = FALSE)
  }

  type <- match.arg(type)

  #-- Validate HEX
  valid_hex <- grepl("^#[0-9A-Fa-f]{6}([0-9A-Fa-f]{2})?$", colors)
  if (!all(valid_hex)) {
    stop("❌ Some color values are not valid HEX codes (e.g., '#FF5733' or '#FF5733B2').")
  }

  #-- Validate name
  if (!is.character(name) || length(name) != 1) {
    stop("❌ Palette name must be a single string.")
  }

  #-- Directory
  palette_dir <- file.path(color_dir, type)
  if (!dir.exists(palette_dir)) {
    dir.create(palette_dir, recursive = TRUE)
    cli::cli_alert_info("📂 Directory created: {.path {palette_dir}}")
  }

  json_file <- file.path(palette_dir, paste0(name, ".json"))
  palette_info <- list(name = name, type = type, colors = colors)

  #-- If exists
  if (file.exists(json_file)) {
    cli::cli_alert_warning("⚠️ Palette already exists: {.path {json_file}}")
    return(invisible(list(path = json_file, info = palette_info)))
  }

  #-- Save
  tryCatch({
    jsonlite::write_json(palette_info, path = json_file, pretty = TRUE, auto_unbox = TRUE)
    cli::cli_alert_success("✅ Palette saved: {.path {json_file}}")
  }, error = function(e) {
    cli::cli_alert_danger("❌ Failed to write JSON: {e$message}")
    stop(e)
  })

  #-- Log
  if (log) {
    log_path <- "logs/palettes/create_palette.log"
    dir.create(dirname(log_path), recursive = TRUE, showWarnings = FALSE)

    entry <- paste(
      Sys.time(), "|", name, "|", type,
      "|", length(colors), "colors",
      "|", json_file
    )

    tryCatch({
      cat(entry, "\n", file = log_path, append = TRUE)
    }, error = function(e) {
      cli::cli_alert_danger("❌ Failed to write log: {e$message}")
    })
  }

  invisible(list(path = json_file, info = palette_info))
}
