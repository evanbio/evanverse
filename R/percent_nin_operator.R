#' ❌ `%nin%`: Not In Operator
#'
#' A binary operator to test if elements of the left-hand vector are **not**
#' present in the right-hand vector. This is the negation of `%in%`, and is
#' equivalent to `!(x %in% y)`.
#'
#' @param x A vector of values to test.
#' @param table A vector to match against.
#'
#' @return A logical vector indicating if elements of `x` are **not in** `table`.
#' @export
#'
#' @examples
#' c("A", "B", "C") %nin% c("B", "D")  # TRUE FALSE TRUE
#' 1:5 %nin% c(2, 4)                   # TRUE FALSE TRUE FALSE TRUE

# --- Option 1: Using base::Negate (recommended, concise)
`%nin%` <- Negate(`%in%`)

# --- Option 2: Using manual negation (equivalent)
# `%nin%` <- function(x, table) {
#   !(x %in% table)
# }
