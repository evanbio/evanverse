#' 🎨 Convert RGB values to HEX color codes
#'
#' A utility function to convert RGB color values (either a numeric vector or list of vectors)
#' into HEX color codes, with informative feedback.
#'
#' @param rgb A numeric vector of length 3 (e.g. \code{c(255, 128, 0)}),
#'   or a list of such vectors (e.g. \code{list(c(255, 128, 0), c(0, 255, 0))}).
#'
#' @return A HEX color string if a single RGB vector is provided,
#'   or a character vector of HEX codes if a list of RGB values is provided.
#' @export
#'
#' @examples
#' # Convert single RGB value
#' rgb2hex(c(255, 128, 0))  # "#FF8000"
#'
#' # Convert multiple RGB values
#' rgb2hex(list(c(255, 128, 0), c(0, 255, 0)))  # c("#FF8000", "#00FF00")
rgb2hex <- function(rgb) {
  if (!requireNamespace("cli", quietly = TRUE)) {
    stop("Package 'cli' is required. Please install it via install.packages('cli')", call. = FALSE)
  }

  # Handle list of RGB values
  if (is.list(rgb)) {
    if (!all(sapply(rgb, function(x) is.numeric(x) && length(x) == 3))) {
      stop("Each RGB entry must be a numeric vector of length 3.")
    }
    if (any(unlist(rgb) < 0 | unlist(rgb) > 255)) {
      stop("All RGB values must be between 0 and 255.")
    }

    rgb <- lapply(rgb, round)
    hex <- sapply(rgb, function(x) grDevices::rgb(x[1], x[2], x[3], maxColorValue = 255))

    cli::cli_alert_success("Converted {length(hex)} RGB value(s) to HEX:")
    for (i in seq_along(hex)) {
      cli::cli_alert_info("RGB: c({paste(rgb[[i]], collapse = ', ')}) → HEX: {hex[i]}")
    }

    return(hex)

  } else {
    # Single RGB vector
    if (!is.numeric(rgb) || length(rgb) != 3) {
      stop("RGB must be a numeric vector of length 3.")
    }
    if (any(rgb < 0 | rgb > 255)) {
      stop("All RGB values must be between 0 and 255.")
    }

    rgb <- round(rgb)
    hex <- grDevices::rgb(rgb[1], rgb[2], rgb[3], maxColorValue = 255)
    cli::cli_alert_success("RGB: c({paste(rgb, collapse = ', ')}) → HEX: {hex}")
    return(hex)
  }
}
