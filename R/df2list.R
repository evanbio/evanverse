#' Convert Data Frame to Named List by Grouping
#'
#' Group a data frame by one column and convert to named list.
#' Each key becomes a list name; each value column becomes vector.
#'
#' @param data A data.frame or tibble to be grouped.
#' @param key_col Character. Column name for list names.
#' @param value_col Character. Column name for list values.
#' @param verbose Logical. Whether to show message. Default = TRUE.
#'
#' @return A named list, where each element is a character vector of values.
#' @export
#'
#' @examples
#' df <- data.frame(
#'   cell_type = c("T_cells", "T_cells", "B_cells", "B_cells"),
#'   marker = c("CD3D", "CD3E", "CD79A", "MS4A1")
#' )
#' df2list(df, "cell_type", "marker")
df2list <- function(data, key_col, value_col, verbose = TRUE) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data.frame or tibble.")
  }
  if (!key_col %in% colnames(data)) {
    cli::cli_abort("Column {key_col} not found in {.arg data}.")
  }
  if (!value_col %in% colnames(data)) {
    cli::cli_abort("Column {value_col} not found in {.arg data}.")
  }

  # ===========================================================================
  # Conversion Phase
  # ===========================================================================

  result <- split(data[[value_col]], data[[key_col]])

  # ===========================================================================
  # Output Phase
  # ===========================================================================

  if (verbose) {
    cli::cli_alert_success("Converted {length(result)} groups into a named list.")
  }

  return(result)
}
