#' `%p%`: paste two strings with a single space
#'
#' An infix operator for string concatenation with one space between `lhs` and `rhs`.
#' Inspired by the readability of `%>%`, intended for expressive text building.
#'
#' @param lhs A character vector on the left-hand side.
#' @param rhs A character vector on the right-hand side.
#'
#' @return A character vector, concatenating `lhs` and `rhs` with a single space.
#' @export
#'
#' @examples
#' "Hello" %p% "world"
#' "Good" %p% "job"
#' c("hello", "good") %p% c("world", "morning")   # vectorized
`%p%` <- function(lhs, rhs) {

  # ===========================================================================
  # Input validation
  # ===========================================================================
  if (!is.character(lhs)) {
    cli::cli_abort("'lhs' must be a character vector.")
  }
  if (!is.character(rhs)) {
    cli::cli_abort("'rhs' must be a character vector.")
  }

  # ===========================================================================
  # Concatenate
  # ===========================================================================
  out <- paste(lhs, rhs, sep = " ")

  # ===========================================================================
  # Return
  # ===========================================================================
  out
}
