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


#' Assert that an argument is a non-empty character vector without NA values
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_character_vector <- function(x, arg = deparse(substitute(x))) {
  if (!is.character(x) || length(x) == 0L || any(is.na(x))) {
    cli::cli_abort("{.arg {arg}} must be a non-empty character vector without NA values.", call = NULL)
  }
  invisible(x)
}


#' Assert that a file path exists on disk
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_file_exists <- function(x, arg = deparse(substitute(x))) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    cli::cli_abort("{.arg {arg}} must be a single non-empty string.", call = NULL)
  }
  if (!file.exists(x)) {
    cli::cli_abort("File not found: {.path {x}}", call = NULL)
  }
  invisible(x)
}


#' Assert that a directory exists on disk
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_dir_exists <- function(x, arg = deparse(substitute(x))) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x)) {
    cli::cli_abort("{.arg {arg}} must be a single non-empty string.", call = NULL)
  }
  if (!dir.exists(x)) {
    cli::cli_abort("Directory not found: {.path {x}}", call = NULL)
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


#' Assert that an argument is a single integer >= min
#'
#' @param x The argument to check.
#' @param min Minimum allowed value. Default 1L (same as .assert_count). Use 0L for non-negative integers.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{as.integer(x)}.
#'
#' @keywords internal
#' @noRd
.assert_count_min <- function(x, min = 1L, arg = deparse(substitute(x))) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      !is.finite(x) || x < min || x != floor(x)) {
    cli::cli_abort("{.arg {arg}} must be a single integer >= {min}.", call = NULL)
  }
  invisible(as.integer(x))
}


#' Assert that an argument is a data.frame
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_data_frame <- function(x, arg = deparse(substitute(x))) {
  if (!is.data.frame(x)) {
    cli::cli_abort("{.arg {arg}} must be a data.frame.", call = NULL)
  }
  invisible(x)
}


#' Assert that the parent directory of a destination path exists or can be created
#'
#' @param x A file path string.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_dest_path <- function(x, arg = deparse(substitute(x))) {
  if (!is.character(x) || length(x) != 1L || is.na(x) || !nzchar(x))
    cli::cli_abort("{.arg {arg}} must be a single non-empty string.", call = NULL)
  parent <- dirname(x)
  if (!dir.exists(parent)) {
    ok <- dir.create(parent, recursive = TRUE, showWarnings = FALSE)
    if (!ok) {
      cli::cli_abort(
        "Cannot create directory for {.arg {arg}}: {.path {parent}}",
        call = NULL
      )
    }
    cli::cli_alert_info("Created directory: {.path {parent}}")
  }
  invisible(x)
}


.assert_data_frame <- function(x, arg = deparse(substitute(x))) {
  if (!is.data.frame(x)) {
    cli::cli_abort("{.arg {arg}} must be a data.frame.", call = NULL)
  }
  invisible(x)
}


#' Assert that required columns are present in a data.frame
#'
#' Reports all missing columns in a single error rather than stopping at the
#' first, so the user can fix everything in one pass.
#'
#' @param data The data.frame to check.
#' @param cols Character vector of required column names.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{data}.
#'
#' @keywords internal
#' @noRd
.assert_has_cols <- function(data, cols, arg = deparse(substitute(data))) {
  missing <- setdiff(cols, names(data))
  if (length(missing) > 0L) {
    cli::cli_abort(
      "{.arg {arg}} is missing column{?s}: {.val {missing}}.",
      call = NULL
    )
  }
  invisible(data)
}


#' Assert that a vector has no duplicate values
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_no_dupes <- function(x, arg = deparse(substitute(x))) {
  dupes <- unique(x[duplicated(x)])
  if (length(dupes) > 0L) {
    cli::cli_abort(
      "{.arg {arg}} must not contain duplicate value{?s}: {.val {dupes}}.",
      call = NULL
    )
  }
  invisible(x)
}


#' Assert that a character vector contains no NA or empty string values
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_no_blank <- function(x, arg = deparse(substitute(x))) {
  if (anyNA(x) || any(!nzchar(x))) {
    cli::cli_abort(
      "{.arg {arg}} must not contain NA or empty string values.",
      call = NULL
    )
  }
  invisible(x)
}


#' Assert that an argument is a named vector with no NA or empty names
#'
#' @param x The argument to check.
#' @param arg Name of the argument (for error messages).
#' @return Invisibly returns \code{x}.
#'
#' @keywords internal
#' @noRd
.assert_named_vector <- function(x, arg = deparse(substitute(x))) {
  if (!is.vector(x) || is.list(x)) {
    cli::cli_abort("{.arg {arg}} must be a vector.", call = NULL)
  }
  nms <- names(x)
  if (is.null(nms) || anyNA(nms) || any(!nzchar(nms))) {
    cli::cli_abort("{.arg {arg}} must be a named vector with non-empty names.", call = NULL)
  }
  .assert_no_dupes(nms)
  invisible(x)
}


#' Assert that an argument is a numeric scalar strictly between 0 and 1
#'
#' @keywords internal
#' @noRd
.assert_proportion <- function(x, arg = deparse(substitute(x))) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      !is.finite(x) || x <= 0 || x >= 1) {
    cli::cli_abort("{.arg {arg}} must be a single number strictly between 0 and 1.", call = NULL)
  }
  invisible(x)
}


#' Assert that an argument is a non-empty numeric vector without NA values
#'
#' @keywords internal
#' @noRd
.assert_numeric_vector <- function(x, arg = deparse(substitute(x))) {
  if (!is.numeric(x) || length(x) == 0L || any(is.na(x))) {
    cli::cli_abort("{.arg {arg}} must be a non-empty numeric vector without NA values.", call = NULL)
  }
  invisible(x)
}


#' Assert that an argument is a single finite numeric value >= min
#'
#' @param min Numeric. Minimum allowed value (inclusive). Default: 0.
#' @keywords internal
#' @noRd
.assert_numeric_min <- function(x, min = 0, arg = deparse(substitute(x))) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      !is.finite(x) || x < min) {
    cli::cli_abort("{.arg {arg}} must be a single finite numeric value >= {min}.", call = NULL)
  }
  invisible(x)
}


#' Assert that an argument is a single finite numeric value strictly > 0
#'
#' @keywords internal
#' @noRd
.assert_positive_numeric <- function(x, arg = deparse(substitute(x))) {
  if (!is.numeric(x) || length(x) != 1L || is.na(x) ||
      !is.finite(x) || x <= 0) {
    cli::cli_abort("{.arg {arg}} must be a single positive numeric value.", call = NULL)
  }
  invisible(x)
}


#' Assert that an argument has exactly n elements
#'
#' @keywords internal
#' @noRd
.assert_length_n <- function(x, n, arg = deparse(substitute(x))) {
  if (length(x) != n) {
    cli::cli_abort("{.arg {arg}} must have length {n}, not {length(x)}.", call = NULL)
  }
  invisible(x)
}


#' Assert that an argument is a logical vector (scalar or vector)
#'
#' @keywords internal
#' @noRd
.assert_logical <- function(x, arg = deparse(substitute(x))) {
  if (!is.logical(x)) {
    cli::cli_abort("{.arg {arg}} must be a logical vector.", call = NULL)
  }
  invisible(x)
}
