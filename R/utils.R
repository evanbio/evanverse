# =============================================================================
# utils.R — Package-wide internal helpers
# =============================================================================


#' Assert that an argument is a single non-empty string
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_scalar_string <- function(x, arg = deparse(substitute(x))) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    cli::cli_abort("{.arg {arg}} must be a single non-empty string.", call = NULL)
  }
  invisible(x)
}


#' Assert that an argument is a valid path string
#'
#' Checks that the value is a single non-empty string suitable for use as a
#' file or directory path. Does not require the path to already exist.
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_dir_path <- function(x, arg = deparse(substitute(x))) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    cli::cli_abort("{.arg {arg}} must be a single non-empty string.", call = NULL)
  }
  invisible(x)
}


#' Assert that an argument is a single logical flag (TRUE or FALSE)
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_flag <- function(x, arg = deparse(substitute(x))) {
  if (!is.logical(x) || length(x) != 1L || is.na(x)) {
    cli::cli_abort("{.arg {arg}} must be TRUE or FALSE.", call = NULL)
  }
  invisible(x)
}


#' Assert that an argument is a single positive integer (count parameter)
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{as.integer(x)}.
#'
#' @keywords internal
#' @noRd
.assert_count <- function(x, arg = deparse(substitute(x))) {
  # Reason: is.finite() required because floor(Inf) == Inf, so without it
  # Inf would silently pass the floor check
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      !is.finite(x) || x < 1L || x != floor(x)) {
    cli::cli_abort("{.arg {arg}} must be a single positive integer.", call = NULL)
  }
  invisible(as.integer(x))
}
