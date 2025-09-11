#' Convert HEX color(s) to RGB numeric components
#'
#' Convert a single HEX color string or a character vector of HEX strings to RGB
#' numeric components. The function accepts values with or without a leading
#' `#`. Messaging uses `cli` if available and falls back to `message()`.
#'
#' @param hex Character. A HEX color string (e.g. `"#FF8000"`) or a character
#'   vector of HEX codes. No NA values allowed.
#'
#' @return If `hex` has length 1, a named numeric vector with elements
#'   `c(r, g, b)`. If `hex` has length > 1, a named list where each element is
#'   a named numeric vector for the corresponding input.
#'
#' @examples
#' hex2rgb("#FF8000")
#' hex2rgb(c("#FF8000", "#00FF00"))
#'
#' @export
hex2rgb <- function(hex) {
  
  # ==========================================================================
  # Parameter validation
  # ==========================================================================
  if (!is.character(hex)) {
    stop("'hex' must be a character vector of HEX color codes.", call. = FALSE)
  }
  if (length(hex) == 0) return(list())
  if (any(is.na(hex))) stop("NA values are not allowed in 'hex'.", call. = FALSE)
  
  # Remove leading '#' if present and validate length/content
  hex_clean <- gsub("^#", "", hex)
  bad_len <- nchar(hex_clean) != 6
  if (any(bad_len)) {
    stop("Each HEX value must be 6 hex digits (optionally prefixed with '#').", call. = FALSE)
  }
  if (!all(grepl("^[0-9A-Fa-f]{6}$", hex_clean))) {
    stop("HEX values must be valid 6-digit hexadecimal codes.", call. = FALSE)
  }
  
  # ==========================================================================
  # Conversion and messaging
  # ==========================================================================
  
  # Single HEX color - return named numeric vector
  if (length(hex) == 1) {
    # Convert to RGB
    rgb <- c(
      r = strtoi(substr(hex_clean, 1, 2), 16L),
      g = strtoi(substr(hex_clean, 3, 4), 16L),
      b = strtoi(substr(hex_clean, 5, 6), 16L)
    )
    # Convert to double while preserving names
    storage.mode(rgb) <- "double"
    
    # Messaging
    if (requireNamespace("cli", quietly = TRUE)) {
      cli::cli_alert_success(paste0(hex, " -> RGB: c(", paste(rgb, collapse = ", "), ")"))
    } else {
      message(paste0(hex, " -> RGB: c(", paste(rgb, collapse = ", "), ")"))
    }
    
    return(rgb)
  }
  
  # Multiple HEX colors - return named list
  rgb_list <- vector("list", length(hex))
  names(rgb_list) <- hex
  
  for (i in seq_along(hex)) {
    rgb <- c(
      r = strtoi(substr(hex_clean[i], 1, 2), 16L),
      g = strtoi(substr(hex_clean[i], 3, 4), 16L),
      b = strtoi(substr(hex_clean[i], 5, 6), 16L)
    )
    # Convert to double while preserving names
    storage.mode(rgb) <- "double"
    rgb_list[[i]] <- rgb
  }
  
  # Messaging for multiple colors
  if (requireNamespace("cli", quietly = TRUE)) {
    cli::cli_alert_success(paste0("Converted ", length(hex), " HEX values to RGB."))
    for (i in seq_along(hex)) {
      cli::cli_alert_info(paste0(hex[i], " -> RGB: c(", paste(rgb_list[[i]], collapse = ", "), ")"))
    }
  } else {
    message(paste0("Converted ", length(hex), " HEX values to RGB."))
    for (i in seq_along(hex)) {
      message(paste0(hex[i], " -> RGB: c(", paste(rgb_list[[i]], collapse = ", "), ")"))
    }
  }
  
  return(rgb_list)
}
