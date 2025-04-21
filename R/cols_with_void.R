#' 🧭 cols_with_void(): Detect Columns Containing Void Values
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
cols_with_void <- function(data,
                           include_na = TRUE,
                           include_null = TRUE,
                           include_empty_str = TRUE,
                           return_names = TRUE) {
  if (!is.data.frame(data)) {
    cli::cli_abort("Input must be a data.frame or tibble.")
  }

  result <- vapply(data, function(col) {
    void <- is_void(col,
                    include_na = include_na,
                    include_null = include_null,
                    include_empty_str = include_empty_str)
    any(void, na.rm = TRUE)
  }, logical(1))

  if (return_names) {
    names(result)[result]
  } else {
    result
  }
}
