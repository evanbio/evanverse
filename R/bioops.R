# =============================================================================
# bioops.R — Custom infix operators
# =============================================================================

#' Paste two strings with a single space
#'
#' An infix operator for string concatenation with one space between `lhs` and `rhs`.
#'
#' @param lhs A character vector.
#' @param rhs A character vector.
#'
#' @return A character vector of concatenated strings.
#' @export
#'
#' @examples
#' "Hello" %p% "world"
#' c("hello", "good") %p% c("world", "morning")
`%p%` <- function(lhs, rhs) {
  # Validate inputs
  .assert_character_vector(lhs)
  .assert_character_vector(rhs)

  # Concatenate with space
  paste(lhs, rhs, sep = " ")
}


#' Not-in operator
#'
#' Tests whether elements of `x` are **not** present in `table`. Equivalent to `!(x %in% table)`.
#' NA behaviour follows base R semantics.
#'
#' @param x A vector of values to test.
#' @param table A vector of values to test against.
#'
#' @return A logical vector.
#' @export
#'
#' @examples
#' c("A", "B", "C") %nin% c("B", "D")   # TRUE FALSE TRUE
#' 1:5 %nin% c(2, 4)                    # TRUE FALSE TRUE FALSE TRUE
`%nin%` <- function(x, table) {
  !(x %in% table)
}


#' Case-insensitive match returning indices
#'
#' Like [base::match()], but ignores letter case. Useful for gene ID matching.
#'
#' @param x Character vector to match.
#' @param table Character vector of values to match against.
#'
#' @return An integer vector of match positions. Returns `NA` for non-matches.
#' @export
#'
#' @examples
#' c("tp53", "BRCA1", "egfr") %match% c("TP53", "EGFR", "MYC")
#' # returns: 1 NA 2
`%match%` <- function(x, table) {
  # Validate inputs
  .assert_character_vector(x)
  .assert_character_vector(table)

  # Case-insensitive match via tolower
  match(tolower(x), tolower(table))
}


#' Case-insensitive mapping returning a named vector
#'
#' Like `%match%`, but returns a named character vector instead of indices.
#' Names are canonical entries from `table`; values are the original elements from `x`.
#' Unmatched values are dropped.
#'
#' @param x Character vector of input strings.
#' @param table Character vector to match against.
#'
#' @return A named character vector. Names from `table`, values from `x`. Unmatched entries dropped.
#' @export
#'
#' @examples
#' c("tp53", "brca1", "egfr") %map% c("TP53", "EGFR", "MYC")
#' # returns: TP53 = "tp53", EGFR = "egfr"
`%map%` <- function(x, table) {
  # Validate inputs
  .assert_character_vector(x)
  .assert_character_vector(table)

  # Case-insensitive match
  match_idx <- match(tolower(x), tolower(table))

  # Build named vector, drop unmatched
  result <- stats::setNames(x, table[match_idx])
  result[!is.na(names(result))]
}


#' Strict identity comparison
#'
#' An infix operator for strict equality. Equivalent to [base::identical()].
#'
#' @param a First object.
#' @param b Second object.
#'
#' @return `TRUE` if identical, `FALSE` otherwise.
#' @export
#'
#' @examples
#' 1:3 %is% 1:3          # TRUE
#' 1:3 %is% c(1, 2, 3)   # FALSE (integer vs double)
`%is%` <- function(a, b) {
  identical(a, b)
}
