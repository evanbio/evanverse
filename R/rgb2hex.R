#' Convert RGB values to HEX color codes
#'
#' Convert an RGB triplet (or a list of triplets) to HEX color codes.
#'
#' @param rgb A numeric vector of length 3 (e.g., \code{c(255, 128, 0)}),
#'   or a list of such vectors (e.g., \code{list(c(255,128,0), c(0,255,0))}).
#'
#' @return A HEX color string if a single RGB vector is provided, or a character
#'   vector of HEX codes if a list is provided.
#' @export
#'
#' @examples
#' rgb2hex(c(255, 128, 0))                           # "#FF8000"
#' rgb2hex(list(c(255,128,0), c(0,255,0)))           # c("#FF8000", "#00FF00")
rgb2hex <- function(rgb) {

  # ===========================================================================
  # Input validation
  # ===========================================================================
  is_rgb_triplet <- function(x) is.numeric(x) && length(x) == 3 && all(is.finite(x))

  if (is.list(rgb)) {
    ok_len_num <- vapply(rgb, function(x) is.numeric(x) && length(x) == 3, logical(1))
    if (!all(ok_len_num)) {
      cli::cli_abort("Each RGB entry must be a numeric vector of length 3.")
    }
    ok_finite <- vapply(rgb, function(x) all(is.finite(x)), logical(1))
    if (!all(ok_finite)) {
      cli::cli_abort("RGB values must be finite numbers.")
    }
    rng_ok <- vapply(rgb, function(x) all(x >= 0 & x <= 255), logical(1))
    if (!all(rng_ok)) {
      cli::cli_abort("All RGB values must be in [0, 255].")
    }

  } else {
    if (!is_rgb_triplet(rgb)) {
      cli::cli_abort("RGB must be a numeric vector of length 3 (finite values).")
    }
    if (any(rgb < 0 | rgb > 255)) {
      cli::cli_abort("All RGB values must be in [0, 255].")
    }
  }

  # ===========================================================================
  # Conversion
  # ===========================================================================
  if (is.list(rgb)) {
    rgb <- lapply(rgb, function(x) round(x))
    hex <- vapply(
      rgb,
      function(x) grDevices::rgb(x[1], x[2], x[3], maxColorValue = 255),
      character(1)
    )

    cli::cli_alert_success("Converted {length(hex)} RGB value{?s} to HEX.")
    for (i in seq_along(hex)) {
      cli::cli_alert_info("RGB: c({paste(rgb[[i]], collapse = ', ')}) \u2192 HEX: {hex[i]}")
    }
    return(hex)

  } else {
    rgb <- round(rgb)
    hex <- grDevices::rgb(rgb[1], rgb[2], rgb[3], maxColorValue = 255)
    cli::cli_alert_success("RGB: c({paste(rgb, collapse = ', ')}) \u2192 HEX: {hex}")
    return(hex)
  }
}
