#' 🔁 map_column(): Map values in a column using named vector or list
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
#' @return A data.frame with a new or modified column based on the mapping.
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
  # --- Checks
  stopifnot(is.data.frame(query))
  stopifnot(is.character(by) && length(by) == 1)
  stopifnot(by %in% colnames(query))
  stopifnot(is.list(map) || is.vector(map))
  if (is.null(names(map))) stop("`map` must be a named vector or list.")

  vec_map <- unlist(map)
  key_vals <- as.character(query[[by]])
  mapped_vals <- vec_map[key_vals]
  mapped_vals[is.na(mapped_vals)] <- default

  if (overwrite) {
    query[[by]] <- mapped_vals
    if (preview) {
      cli::cli_h2("🔁 Column '{by}' overwritten with mapped values")
      print(utils::head(query, 6))
    }
  } else {
    query[[to]] <- mapped_vals
    if (preview) {
      cli::cli_h2("🔁 New column '{to}' created using map")
      print(utils::head(query, 6))
    }
  }

  invisible(query)
} 
