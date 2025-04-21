#' 🕳️ is_void(): Check for Null / NA / Blank ("") Values
#'
#' Determine whether input values are considered "void": `NULL`, `NA`, or `""`.
#' Each condition is controlled by a dedicated argument.
#'
#' @param x A vector or list to evaluate.
#' @param include_na Logical. Consider `NA` as void. Default: TRUE.
#' @param include_null Logical. Consider `NULL` as void. Default: TRUE.
#' @param include_empty_str Logical. Consider `""` as void. Default: TRUE.
#'
#' @return A logical vector indicating which elements are void.
#' @export
#'
#' @examples
#' is_void(c(NA, "", "text"))                  # TRUE TRUE FALSE
#' is_void(list(NA, "", NULL, "a"))            # TRUE TRUE TRUE FALSE
#' is_void("NA", include_na = FALSE)           # FALSE
#' is_void(NULL)                               # TRUE
is_void <- function(x,
                    include_na = TRUE,
                    include_null = TRUE,
                    include_empty_str = TRUE) {

  # Special case: if input is NULL, return TRUE (or FALSE based on setting)
  if (is.null(x)) return(include_null)

  # If list: recursively evaluate each element
  if (is.list(x)) {
    return(vapply(x, is_void,
                  logical(1),
                  include_na = include_na,
                  include_null = include_null,
                  include_empty_str = include_empty_str))
  }

  # Base logical vector
  void <- rep(FALSE, length(x))

  # NA
  if (include_na) {
    void <- void | is.na(x)
  }

  # Empty string
  if (include_empty_str && is.character(x)) {
    void <- void | x == ""
  }

  # Ensure NA is explicitly FALSE if not matched
  void[is.na(void)] <- FALSE

  return(void)
}
