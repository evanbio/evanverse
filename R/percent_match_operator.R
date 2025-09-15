#' %match%: Case-insensitive match returning indices
#'
#' Performs case-insensitive matching, like [base::match()], but ignores letter case.
#'
#' @param x Character vector to match.
#' @param table Character vector of values to match against.
#'
#' @return An integer vector of the positions of matches of `x` in `table`,
#'   like [base::match()]. Returns `NA` for non-matches. Returns an integer(0)
#'   if `x` is length 0.
#' @export
#'
#' @examples
#' # Basic matching
#' c("tp53", "BRCA1", "egfr") %match% c("TP53", "EGFR", "MYC")
#' # → 1 NA 2
#'
#' # No matches → all NA
#' c("aaa", "bbb") %match% c("xxx", "yyy")
#'
#' # Empty input
#' character(0) %match% c("a", "b")
#'
#' # Order sensitivity (like match): first match is returned
#' c("x") %match% c("X", "x", "x")
#' # → 1
`%match%` <- function(x, table) {

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
  # Case-insensitive match
  # ===========================================================================
  lower_x <- tolower(x)
  lower_table <- tolower(table)
  result <- match(lower_x, lower_table)

  return(result)
}
