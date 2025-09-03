#' is_void(): Check for Null / NA / Blank ("") Values
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
#'   - If `x` is `NULL`, returns a single `TRUE` (if include_null=TRUE) or `FALSE`.
#'   - If `x` is an empty vector, returns `logical(0)`.
#'   - If `x` is a list, evaluates each element recursively and returns a flattened logical vector.
#'   - For atomic vectors, returns a logical vector of the same length.
#'
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
  # -------------------------------------------------------------------
  # Case 1: Entire input is NULL
  # -------------------------------------------------------------------
  if (is.null(x)) return(include_null)

  # -------------------------------------------------------------------
  # Case 2: Input is a list (possibly nested)
  # -------------------------------------------------------------------
  if (is.list(x)) {
    return(unlist(lapply(
      x,
      is_void,
      include_na = include_na,
      include_null = include_null,
      include_empty_str = include_empty_str
    ), use.names = FALSE))
  }

  # -------------------------------------------------------------------
  # Case 3: Input is an atomic vector
  # -------------------------------------------------------------------
  void <- rep(FALSE, length(x))

  if (include_na) {
    void <- void | is.na(x)
  }

  if (include_empty_str && is.character(x)) {
    void <- void | x == ""
  }

  void[is.na(void)] <- FALSE
  return(void)
}
