# df2list.R
# ==============================================================================
# 📦 Function: df2list
# Group a data frame by key_col and aggregate value_col as a list-column
# Used for converting long-form data into grouped list format (e.g. marker sets)
# ==============================================================================

#' 📦 Convert Data Frame to List by Grouping
#'
#' Group a data frame by one column and aggregate values from another column into lists.
#' Useful for creating marker gene sets: e.g., `cell_type -> marker_genes`.
#'
#' @param data A data.frame or tibble to be grouped.
#' @param key_col Character. Name of the column to group by (e.g., `"cell_type"`).
#' @param value_col Character. Name of the column to aggregate into lists (e.g., `"marker_genes"`).
#' @param verbose Logical. Whether to show progress messages. Default is `TRUE`.
#'
#' @return A tibble with one row per key and a list-column of aggregated values.
#' @export
#'
#' @importFrom dplyr group_by summarise
#' @importFrom tibble as_tibble
#' @importFrom cli cli_alert_success cli_abort
#'
#' @examples
#' df <- data.frame(
#'   cell_type = c(rep("B_CELLS_MEMORY", 5), rep("T_CELLS_CD8", 4), rep("MONOCYTES", 3)),
#'   marker_genes = c("AIM2", "BANK1", "CD19", "CD27", "CD37",
#'                    "CD8A", "CD8B", "GZMB", "PRF1",
#'                    "LYZ", "S100A9", "CD14")
#' )
#' df2list(df, key_col = "cell_type", value_col = "marker_genes")
df2list <- function(data, key_col, value_col, verbose = TRUE) {
  # --- Argument validation ---
  if (!is.data.frame(data)) {
    cli::cli_abort("❌ {.arg data} must be a data.frame or tibble.")
  }
  if (!is.character(key_col) || length(key_col) != 1 || !key_col %in% names(data)) {
    cli::cli_abort("❌ {.arg key_col} must be a single character string and a valid column in {.arg data}.")
  }
  if (!is.character(value_col) || length(value_col) != 1 || !value_col %in% names(data)) {
    cli::cli_abort("❌ {.arg value_col} must be a single character string and a valid column in {.arg data}.")
  }

  # --- Main transformation ---
  result <- dplyr::group_by(data, .data[[key_col]]) |>
    dplyr::summarise(
      !!value_col := list(.data[[value_col]]),
      .groups = "drop"
    ) |>
    tibble::as_tibble()

  # --- Final message ---
  if (verbose) {
    cli::cli_alert_success(
      "🎉 Successfully grouped {.val {nrow(result)}} rows by {.arg {key_col}} and aggregated {.arg {value_col}} as lists."
    )
  }

  return(result)
}
