#' cols_with_void(): Detect Columns Containing Void Values
#'
#' Scan a data.frame or tibble and identify columns that contain any "void" values.
#' Void values include `NA`, `NULL`, and `""`, which can be toggled via parameters.
#'
#' @param data A data.frame or tibble.
#' @param include_na Logical. Detect `NA` if TRUE. Default: TRUE.
#' @param include_null Logical. Detect `NULL` if TRUE. Default: TRUE.
#' @param include_empty_str Logical. Detect `""` if TRUE. Default: TRUE.
#' @param return_names Logical. If TRUE (default), return column names; else logical vector.
#'
#' @return A character vector (column names) or logical vector indicating void presence per column.
#' @export
#'
#' @examples
#' df <- data.frame(name = c("A", "", "C"), score = c(1, NA, 3), id = 1:3)
#' cols_with_void(df)
#' cols_with_void(df, return_names = FALSE)
#' cols_with_void(df, include_na = FALSE)
cols_with_void <- function(data,
                           include_na = TRUE,
                           include_null = TRUE,
                           include_empty_str = TRUE,
                           return_names = TRUE) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  # Check if data is a data.frame or tibble
  if (!is.data.frame(data)) {
    cli::cli_abort("Input must be a data.frame or tibble.")
  }

  # Validate logical parameters
  if (!is.logical(include_na) || length(include_na) != 1) {
    cli::cli_abort("`include_na` must be a single logical value.")
  }
  if (!is.logical(include_null) || length(include_null) != 1) {
    cli::cli_abort("`include_null` must be a single logical value.")
  }
  if (!is.logical(include_empty_str) || length(include_empty_str) != 1) {
    cli::cli_abort("`include_empty_str` must be a single logical value.")
  }
  if (!is.logical(return_names) || length(return_names) != 1) {
    cli::cli_abort("`return_names` must be a single logical value.")
  }

  # ===========================================================================
  # Void Detection Phase
  # ===========================================================================

  # Vectorized detection of void values per column (performance optimized)
  result <- vapply(data, function(col) {
    void <- is_void(col,
                    include_na = include_na,
                    include_null = include_null,
                    include_empty_str = include_empty_str)
    any(void, na.rm = TRUE)
  }, logical(1))

  # ===========================================================================
  # Return Result
  # ===========================================================================

  # Return column names or logical vector based on return_names
  if (return_names) {
    names(result)[result]
  } else {
    result
  }
}
