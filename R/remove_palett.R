#' 🗑️ remove_palette(): Smart Remove a Saved Palette JSON
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
#' remove_palette("blues")
#' remove_palette("vividset", type = "qualitative")
remove_palette <- function(name,
                            type = NULL,
                            color_dir = "inst/extdata/palettes",
                            log = TRUE) {
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Please install the 'cli' package.", call. = FALSE)
  }

  valid_types <- c("sequential", "diverging", "qualitative")

  # Determine types to try
  if (is.null(type)) {
    types_to_try <- valid_types
  } else {
    type <- match.arg(type, choices = valid_types)
    types_to_try <- c(type, setdiff(valid_types, type))
  }

  found <- FALSE

  for (current_type in types_to_try) {
    palette_dir <- file.path(color_dir, current_type)
    json_file <- file.path(palette_dir, paste0(name, ".json"))

    if (file.exists(json_file)) {
      tryCatch({
        file.remove(json_file)
        cli::cli_alert_success("✅ Palette found in {.strong {current_type}} and removed: {.path {json_file}}")

        # Log
        if (log) {
          log_path <- "logs/palettes/remove_palette.log"
          dir.create(dirname(log_path), recursive = TRUE, showWarnings = FALSE)

          entry <- paste(
            Sys.time(), "|", name, "|", current_type,
            "| Removed", "|", json_file
          )

          cat(entry, "\n", file = log_path, append = TRUE)
        }

        found <- TRUE
        break  # Only remove once
      }, error = function(e) {
        cli::cli_alert_danger("❌ Failed to remove palette: {e$message}")
      })
    }
  }

  if (!found) {
    cli::cli_alert_warning("⚠️ Palette not found in any type: {.strong {name}}")
  }

  invisible(found)
}
