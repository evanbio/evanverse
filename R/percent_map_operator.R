#' 🔁 %map%: Case-insensitive mapping returning named vector
#'
#' Performs case-insensitive matching between elements in `x` and entries in `table`,
#' returning a named character vector: matched `table` entries as names, and `x` as values.
#' Unmatched values are assigned a default name ("unknown") but removed before returning.
#'
#' @param x Character vector of input strings.
#' @param table Character vector to match against.
#'
#' @return A named character vector. Names come from matched `table` values, values from `x`.
#' @export
#'
#' @examples
#' c("tp53", "brca1", "egfr") %map% c("TP53", "EGFR", "MYC")
#' # → Named vector with matches: TP53 = "tp53", EGFR = "egfr"
`%map%` <- function(x, table) {
  stopifnot(is.character(x), is.character(table))

  default <- "unknown"
  lower_x <- tolower(x)
  lower_table <- tolower(table)
  match_idx <- match(lower_x, lower_table)

  matched_names <- table[match_idx]
  matched_names[is.na(matched_names)] <- default

  result <- setNames(x, matched_names)
  result <- result[names(result) != default]
  return(result)
}
