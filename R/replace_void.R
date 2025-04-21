#' 🔁 replace_void(): Replace Void Values (NA / NULL / "") with a Specified Value
#'
#' Replace elements in a vector or list that are considered "void" with a user-defined `value`.
#' Void values include `NA`, `NULL`, and empty strings (`""`), each toggleable.
#'
#' @param x A vector or list.
#' @param value The replacement value to use for voids. Default: `NA`.
#' @param include_na Logical. Replace `NA` if TRUE. Default: TRUE.
#' @param include_null Logical. Replace `NULL` if TRUE. Default: TRUE.
#' @param include_empty_str Logical. Replace `""` if TRUE. Default: TRUE.
#'
#' @return A cleaned vector or list with void values replaced.
#' @export
#'
#' @examples
#' replace_void(c(NA, "", "a"), value = "N/A")
#' replace_void(list("A", "", NULL, NA), value = "missing")
#' replace_void(c("", "b"), value = 0, include_empty_str = TRUE)
replace_void <- function(x,
                         value = NA,
                         include_na = TRUE,
                         include_null = TRUE,
                         include_empty_str = TRUE) {
  if (is.null(x)) {
    return(if (include_null) value else NULL)
  }

  void <- is_void(x,
                  include_na = include_na,
                  include_null = include_null,
                  include_empty_str = include_empty_str)

  void[is.na(void)] <- FALSE

  # Replace for list
  if (is.list(x)) {
    x[void] <- rep(list(value), sum(void))
    return(x)
  }

  # Replace for atomic vectors
  x[void] <- value
  return(x)
}
