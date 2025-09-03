#' any_void(): Check if Any Value is Void (NA / NULL / "")
#'
#' Test whether any element in a vector or list is considered "void".
#' Void values include `NA`, `NULL`, and empty strings (`""`), and
#' you can customize which ones to consider.
#'
#' @param x A vector or list to evaluate.
#' @param include_na Logical. Consider `NA` as void. Default: TRUE.
#' @param include_null Logical. Consider `NULL` as void. Default: TRUE.
#' @param include_empty_str Logical. Consider `""` as void. Default: TRUE.
#'
#' @return A single logical value:
#'   - `TRUE` if any void values are present.
#'   - `FALSE` otherwise.
#'   - For `NULL` input, returns `TRUE` if `include_null = TRUE`, else `FALSE`.
#'
#' @export
#'
#' @examples
#' any_void(c("a", "", NA))                # TRUE
#' any_void(list("x", NULL, "y"))          # TRUE
#' any_void(c("a", "b", "c"))              # FALSE
#' any_void(NULL)                          # TRUE
#' any_void("", include_empty_str = FALSE) # FALSE
any_void <- function(x,
                     include_na = TRUE,
                     include_null = TRUE,
                     include_empty_str = TRUE) {
  # -------------------------------------------------------------------
  # Delegate to is_void() for element-wise detection.
  # The result is a logical vector (same length as input).
  # -------------------------------------------------------------------
  result <- is_void(
    x,
    include_na = include_na,
    include_null = include_null,
    include_empty_str = include_empty_str
  )

  # Return TRUE if any element is void, otherwise FALSE.
  any(result)
}
