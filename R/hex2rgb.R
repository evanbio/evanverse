#' 🎨 Convert HEX color(s) to RGB format
#'
#' Converts a single HEX string or a character vector of HEX strings to RGB numeric values.
#'
#' @param hex A HEX color string (e.g., `"#FF8000"`) or a character vector of HEX codes.
#'
#' @return A numeric vector of length 3 for a single HEX input, or a named list of RGB vectors for multiple inputs.
#' @export
#'
#' @examples
#' hex2rgb("#FF8000")
#' hex2rgb(c("#FF8000", "#00FF00"))
hex2rgb <- function(hex) {
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Package 'cli' is required. Please install it with install.packages('cli')", call. = FALSE)
  }

  # Validate input
  if (!is.character(hex)) stop("HEX input must be a character string or vector.")

  hex_clean <- gsub("#", "", hex)
  if (any(nchar(hex_clean) != 6)) stop("Each HEX value must be 6 characters (excluding '#').")
  if (!all(grepl("^[0-9A-Fa-f]{6}$", hex_clean))) stop("HEX values must be valid 6-digit hex codes.")

  # Convert to RGB
  to_rgb <- function(h) {
    unname(c(
      strtoi(substr(h, 1, 2), 16),
      strtoi(substr(h, 3, 4), 16),
      strtoi(substr(h, 5, 6), 16)
    ))
  }

  if (length(hex) == 1) {
    rgb <- to_rgb(hex_clean)
    cli::cli_alert_success("{hex} -> RGB: c({paste(rgb, collapse = ', ')})")
    return(rgb)
  }

  rgb_list <- setNames(lapply(hex_clean, to_rgb), hex)
  cli::cli_alert_success("Converted {length(hex)} HEX values to RGB:")
  for (i in seq_along(hex)) {
    cli::cli_alert_info("{hex[i]} -> RGB: c({paste(rgb_list[[i]], collapse = ', ')})")
  }

  return(rgb_list)
}
