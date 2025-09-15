#' map_column(): Map values in a column using named vector or list
#'
#' @description
#' Maps values in a column of a data.frame (query) to new values using a named
#' vector or list (`map`), optionally creating a new column or replacing the original.
#'
#' @param query A data.frame containing the column to be mapped.
#' @param by A string. Column name in `query` to be mapped.
#' @param map A named vector or list. Names are original values, values are mapped values.
#' @param to A string. Name of the column to store mapped results (if `overwrite = FALSE`).
#' @param overwrite Logical. Whether to replace the `by` column with mapped values. Default: FALSE.
#' @param default Default value to assign if no match is found. Default: "unknown".
#' @param preview Logical. Whether to print preview of result (default TRUE).
#'
#' @return A data.frame with a new or modified column based on the mapping (returned invisibly).
#' @export
#'
#' @examples
#' df <- data.frame(gene = c("TP53", "BRCA1", "EGFR", "XYZ"))
#' gene_map <- c("TP53" = "Tumor suppressor", "EGFR" = "Oncogene")
#' map_column(df, by = "gene", map = gene_map, to = "label")
map_column <- function(query,
                       by,
                       map,
                       to = "mapped",
                       overwrite = FALSE,
                       default = "unknown",
                       preview = TRUE) {

  # ===========================================================================
  # Input validation
  # ===========================================================================
  if (!is.data.frame(query)) {
    cli::cli_abort("'query' must be a data.frame.")
  }
  if (!is.character(by) || length(by) != 1L || is.na(by) || !nzchar(by)) {
    cli::cli_abort("'by' must be a non-empty single string.")
  }
  if (!(by %in% colnames(query))) {
    cli::cli_abort("Column '{by}' not found in 'query'.")
  }
  if (!(is.list(map) || is.vector(map))) {
    cli::cli_abort("'map' must be a named vector or list.")
  }
  if (is.null(names(map))) {
    cli::cli_abort("'map' must have names (original values) and values (mapped results).")
  }

  # ===========================================================================
  # Prepare mapping vector
  # ===========================================================================
  vec_map <- unlist(map, recursive = TRUE, use.names = TRUE)

  # ===========================================================================
  # Mapping logic
  # - Numeric column: skip mapping, keep original values
  # - Non-numeric: do name-based lookup, fill unmatched with 'default'
  # ===========================================================================
  col_val <- query[[by]]

  if (is.numeric(col_val)) {
    mapped_vals <- col_val
    unmatched_n <- 0L
    cli::cli_alert_info("Numeric column detected in '{by}'; mapping skipped and values preserved.")
  } else {
    keys <- as.character(col_val)
    looked_up <- vec_map[keys]
    unmatched_n <- sum(is.na(looked_up))
    looked_up[is.na(looked_up)] <- default
    mapped_vals <- looked_up
    cli::cli_alert_info("Mapping completed for '{by}': {unmatched_n} unmatched value(s) assigned to default.")
  }

  # ===========================================================================
  # Write back (overwrite vs. create 'to')
  # ===========================================================================
  if (isTRUE(overwrite)) {
    query[[by]] <- mapped_vals
    if (isTRUE(preview)) {
      cli::cli_alert_success("Column '{by}' overwritten with mapped values.")
      print(utils::head(query, 6))
    }
  } else {
    query[[to]] <- mapped_vals
    if (isTRUE(preview)) {
      cli::cli_alert_success("New column '{to}' created using mapping.")
      print(utils::head(query, 6))
    }
  }

  # ===========================================================================
  # Return
  # ===========================================================================
  invisible(query)
}
