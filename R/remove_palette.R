#' Remove a Saved Palette JSON
#'
#' Remove a palette file by name, trying across types if necessary.
#'
#' @param name Character. Palette name (without '.json' suffix).
#' @param type Character. Optional. Preferred type ("sequential", "diverging", or "qualitative").
#' @param color_dir Root folder where palettes are stored (default: "inst/extdata/palettes").
#' @param log Logical. Whether to log palette removal in "logs/palettes/remove_palette.log".
#'
#' @return Invisibly TRUE if removed successfully, FALSE otherwise.
#' @export
#'
#' @examples
#' \dontrun{
#' remove_palette("blues")
#' remove_palette("vividset", type = "qualitative")
#' }
remove_palette <- function(name,
                            type = NULL,
                            color_dir = "inst/extdata/palettes",
                            log = TRUE) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================

  # Validate name parameter
  if (missing(name) || !is.character(name) || length(name) != 1 || is.na(name) || nchar(name) == 0) {
    cli::cli_abort("'name' must be a non-empty character string.")
  }

  # Validate color_dir parameter
  if (!is.character(color_dir) || length(color_dir) != 1 || is.na(color_dir)) {
    cli::cli_abort("'color_dir' must be a character string.")
  }

  # Validate log parameter
  if (!is.logical(log) || length(log) != 1 || is.na(log)) {
    cli::cli_abort("'log' must be TRUE or FALSE.")
  }

  # Validate and normalize type parameter
  valid_types <- c("sequential", "diverging", "qualitative")
  if (!is.null(type)) {
    type <- match.arg(type, choices = valid_types)
  }

  # ===========================================================================
  # Determine types to try
  # ===========================================================================
  types_to_try <- if (is.null(type)) {
    valid_types
  } else {
    c(type, setdiff(valid_types, type))
  }

  # ===========================================================================
  # Search and remove palette
  # ===========================================================================
  found <- FALSE

  for (current_type in types_to_try) {
    palette_dir <- file.path(color_dir, current_type)
    json_file <- file.path(palette_dir, paste0(name, ".json"))

    if (file.exists(json_file)) {
      # Attempt to remove the file
      success <- tryCatch({
        file.remove(json_file)
        TRUE
      }, error = function(e) {
        cli::cli_alert_danger("Failed to remove palette: {.file {json_file}} - {e$message}")
        FALSE
      })

      if (success) {
        cli::cli_alert_success("Palette removed from {.strong {current_type}}: {.file {json_file}}")

        # Log the removal if requested
        if (log) {
          log_path <- "logs/palettes/remove_palette.log"
          
          # Ensure log directory exists
          log_dir <- dirname(log_path)
          if (!dir.exists(log_dir)) {
            dir.create(log_dir, recursive = TRUE, showWarnings = FALSE)
          }
          
          # Create log entry with timestamp
          timestamp <- format(Sys.time(), "%Y-%m-%d %H:%M:%S")
          entry <- sprintf("%s | %s | %s | REMOVED | %s",
                           timestamp, name, current_type, json_file)
          
          # Write to log file
          tryCatch({
            cat(entry, "\n", file = log_path, append = TRUE)
          }, error = function(e) {
            cli::cli_alert_warning("Failed to write to log file: {e$message}")
          })
        }

        found <- TRUE
        break  # Only remove from first found location
      }
    }
  }

  # ===========================================================================
  # Report result
  # ===========================================================================
  if (!found) {
    cli::cli_alert_warning("Palette not found in any type: {.strong {name}}")
  }

  invisible(found)
}
