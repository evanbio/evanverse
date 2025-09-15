#' rows_with_void: Detect rows containing void values (NA / NULL / "")
#'
#' Scan a data.frame or tibble and identify rows that contain any "void" values.
#' Void values include `NA`, `NULL`, and empty strings `""` (toggle via flags).
#'
#' @param data A data.frame or tibble.
#' @param include_na Logical. Detect `NA` if TRUE. Default: TRUE.
#' @param include_null Logical. Detect `NULL` if TRUE. Default: TRUE.
#' @param include_empty_str Logical. Detect empty strings `""` if TRUE. Default: TRUE.
#'
#' @return A logical vector of length `nrow(data)` indicating whether each row
#'   contains at least one void value.
#' @export
#'
#' @examples
#' df <- data.frame(id = 1:3, name = c("A", "", "C"), score = c(10, NA, 20))
#' rows_with_void(df)
#' df[rows_with_void(df), ]
rows_with_void <- function(data,
                           include_na = TRUE,
                           include_null = TRUE,
                           include_empty_str = TRUE) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================
  if (!is.data.frame(data)) {
    cli::cli_abort("Input must be a data.frame or tibble.")
  }

  # ===========================================================================
  # Row-wise scan using `is_void`
  # ===========================================================================
  result <- apply(
    data, 1,
    function(row) {
      any(is_void(
        row,
        include_na = include_na,
        include_null = include_null,
        include_empty_str = include_empty_str
      ))
    }
  )

  # ===========================================================================
  # Return
  # ===========================================================================
  result
}
