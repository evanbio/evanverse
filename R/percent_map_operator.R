#' %map%: Case-insensitive mapping returning named vector
#'
#' Performs case-insensitive matching between elements in `x` and entries in `table`,
#' returning a named character vector: names are the matched entries from `table`,
#' values are the original elements from `x`.  
#' Unmatched values are ignored (not included in the result).
#'
#' @param x Character vector of input strings.
#' @param table Character vector to match against.
#'
#' @return A named character vector. Names are from matched `table` values, values are from `x`.
#'   If no matches are found, returns a zero-length named character vector.
#' @export
#'
#' @examples
#' # Basic matching (case-insensitive)
#' c("tp53", "brca1", "egfr") %map% c("TP53", "EGFR", "MYC")
#' # → Named vector: TP53 = "tp53", EGFR = "egfr"
#'
#' # Values not in table are dropped
#' c("akt1", "tp53") %map% c("TP53", "EGFR")
#' # → TP53 = "tp53"
#'
#' # All unmatched values → empty result
#' c("none1", "none2") %map% c("TP53", "EGFR")
#' # → character(0)
`%map%` <- function(x, table) {

  # ===========================================================================
  # Input validation
  # ===========================================================================
  if (!is.character(x)) {
    cli::cli_abort("Input 'x' must be a character vector.")
  }
  if (!is.character(table)) {
    cli::cli_abort("Input 'table' must be a character vector.")
  }

  # ===========================================================================
  # Case-insensitive matching
  # ===========================================================================
  lower_x <- tolower(x)
  lower_table <- tolower(table)
  match_idx <- match(lower_x, lower_table)

  # ===========================================================================
  # Construct result: keep only matched entries
  # ===========================================================================
  matched_names <- table[match_idx]
  result <- setNames(x, matched_names)
  result <- result[!is.na(names(result))]

  return(result)
}
