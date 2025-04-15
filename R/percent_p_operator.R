#' Paste two strings with a space
#'
#' `%p%` is a custom infix operator for string concatenation with a single space.
#' It’s inspired by the readability of `%>%`, but meant for expressive text building.
#'
#' @param lhs A character vector on the left-hand side.
#' @param rhs A character vector on the right-hand side.
#'
#' @return A character vector, with elements from `lhs` and `rhs` pasted together using a space.
#'
#' @examples
#' "Hello" %p% "world"
#' "Good" %p% "job"
#'
#' @export
`%p%` <- function(lhs, rhs) {
  stopifnot(is.character(lhs), is.character(rhs))
  paste(lhs, rhs, sep = " ")
}
