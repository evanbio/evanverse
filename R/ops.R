# =============================================================================
# ops.R — Custom infix operators
# =============================================================================

#' Paste two strings with a single space
#'
#' An infix operator for string concatenation with one space between `lhs` and `rhs`.
#'
#' @param lhs A character vector.
#' @param rhs A character vector.
#'
#' @return A character vector of concatenated strings.
#'
#' @note Both `lhs` and `rhs` must be non-`NA` character vectors; `NA` values and
#'   non-character inputs (including `NULL`) raise an error. Lengths must be
#'   equal, or one side must have length 1.
#' @export
#'
#' @examples
#' "Hello" %p% "world"
#' c("hello", "good") %p% c("world", "morning")
`%p%` <- function(lhs, rhs) {
  # Validate inputs
  .assert_character_vector(lhs)
  .assert_character_vector(rhs)

  lhs_len <- length(lhs)
  rhs_len <- length(rhs)
  if (lhs_len != rhs_len && lhs_len != 1L && rhs_len != 1L) {
    cli::cli_abort(
      "{.arg lhs} and {.arg rhs} must have equal lengths, or one side must have length 1.",
      call = NULL
    )
  }

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
#'
#' @note Both `x` and `table` must be **non-empty** character vectors; `character(0)` or
#'   non-character inputs raise an error. Empty strings are also rejected.
#'   This differs from [base::match()] and `%nin%`,
#'   which accept empty vectors. The stricter contract is intentional for gene-ID workflows
#'   where an empty query almost always signals an upstream mistake.
#' @export
#'
#' @examples
#' c("tp53", "BRCA1", "egfr") %match% c("TP53", "EGFR", "MYC")
#' # returns: 1 NA 2
`%match%` <- function(x, table) {
  # Validate inputs
  .assert_character_vector(x)
  .assert_character_vector(table)
  .assert_no_blank(x)
  .assert_no_blank(table)

  # Case-insensitive match via tolower
  x_norm     <- tolower(x)
  table_norm <- .normalize_ops_table(table)

  match(x_norm, table_norm)
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
#' @return A named character vector. Names are canonical entries from `table`; values are the
#'   original elements from `x`. Order follows `x` (not `table`). Unmatched entries are dropped.
#'
#' @note Both `x` and `table` must be non-empty character vectors without `NA`
#'   or empty string values. If `table` contains duplicated values after case
#'   normalization, the first match is used with a warning.
#' @export
#'
#' @examples
#' c("tp53", "brca1", "egfr") %map% c("TP53", "EGFR", "MYC")
#' # returns: TP53 = "tp53", EGFR = "egfr"
`%map%` <- function(x, table) {
  # Validate inputs
  .assert_character_vector(x)
  .assert_character_vector(table)
  .assert_no_blank(x)
  .assert_no_blank(table)

  # Case-insensitive match
  match_idx <- match(tolower(x), .normalize_ops_table(table))

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


#' Normalize an operator lookup table and warn on ambiguous matches
#'
#' @param table Character vector to normalize.
#' @return Lower-case version of \code{table}.
#' @keywords internal
#' @noRd
.normalize_ops_table <- function(table) {
  table_norm <- tolower(table)
  duplicated_value <- unique(table_norm[duplicated(table_norm)])

  if (length(duplicated_value) > 0L) {
    cli::cli_warn(
      "{.arg table} contains duplicated value{?s} after case normalization: {.val {duplicated_value}}. Using the first match.",
      call = NULL
    )
  }

  table_norm
}
