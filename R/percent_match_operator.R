#' 🔍 %match%: Case-insensitive match returning indices
#'
#' Performs case-insensitive matching, like `match()`, but ignores letter case.
#'
#' @param x Character vector to match.
#' @param table Character vector of values to match against.
#'
#' @return An integer vector of the positions of matches of `x` in `table`,
#' like `match()`. Returns `NA` for non-matches.
#' @export
#'
#' @examples
#' c("tp53", "BRCA1", "egfr") %match% c("TP53", "EGFR", "MYC")
#' # Returns: 1 NA 2
`%match%` <- function(x, table) {
  stopifnot(is.character(x), is.character(table))
  lower_x <- tolower(x)
  lower_table <- tolower(table)
  match(lower_x, lower_table)
}
