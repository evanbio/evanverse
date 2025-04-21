#' 🧼 drop_void(): Remove Void Values from a Vector or List
#'
#' Remove elements from a vector or list that are considered "void":
#' `NA`, `NULL`, and empty strings (`""`). Each can be toggled via parameters.
#'
#' @param x A vector or list.
#' @param include_na Logical. Remove `NA` if TRUE. Default: TRUE.
#' @param include_null Logical. Remove `NULL` if TRUE. Default: TRUE.
#' @param include_empty_str Logical. Remove `""` if TRUE. Default: TRUE.
#'
#' @return A cleaned vector or list of the same type as input, with void values removed.
#' @export
#'
#' @examples
#' drop_void(c("apple", "", NA, "banana"))
#' drop_void(list("A", NA, "", NULL, "B"))
#' drop_void(c("", NA), include_na = FALSE)
drop_void <- function(x,
                      include_na = TRUE,
                      include_null = TRUE,
                      include_empty_str = TRUE) {
  if (is.null(x)) return(x)

  void <- is_void(x,
                  include_na = include_na,
                  include_null = include_null,
                  include_empty_str = include_empty_str)

  # Replace NA in void logic with FALSE to ensure clean indexing
  void[is.na(void)] <- FALSE

  x[!void]
}
