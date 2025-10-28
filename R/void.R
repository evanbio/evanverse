#' @title Void Value Utilities
#' @name void
#'
#' @description
#' A comprehensive suite of functions for detecting, removing, and managing
#' "void" values (NA, NULL, and empty strings) in R objects.
#'
#' @details
#' The void utilities family consists of:
#' \itemize{
#'   \item \code{\link{is_void}}: Core detection function returning logical vector
#'   \item \code{\link{any_void}}: Check if any void value exists
#'   \item \code{\link{drop_void}}: Remove void values from vectors/lists
#'   \item \code{\link{replace_void}}: Replace void values with custom values
#'   \item \code{\link{cols_with_void}}: Detect columns containing void values
#'   \item \code{\link{rows_with_void}}: Detect rows containing void values
#' }
#'
#' All functions support customizable void detection through three parameters:
#' \itemize{
#'   \item \code{include_na}: Consider \code{NA} as void (default: TRUE)
#'   \item \code{include_null}: Consider \code{NULL} as void (default: TRUE)
#'   \item \code{include_empty_str}: Consider \code{""} as void (default: TRUE)
#' }
NULL

# =============================================================================
# Core Detection Function
# =============================================================================

#' is_void(): Check for Null / NA / Blank ("") Values
#' @rdname void
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

# =============================================================================
# Vector/List Operations
# =============================================================================

#' any_void(): Check if Any Value is Void (NA / NULL / "")
#' @rdname void
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

#' drop_void: Remove Void Values from a Vector or List
#' @rdname void
#'
#' Removes elements from a vector or list that are considered "void":
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

#' Replace void values (NA / NULL / "")
#' @rdname void
#'
#' Replace elements in a vector or list considered "void" with a specified value.
#' Void values include `NA`, `NULL`, and empty strings `""` (toggle via flags).
#'
#' @param x A vector or list.
#' @param value The replacement value to use for voids. Default: `NA`.
#' @param include_na Logical. Replace `NA` if TRUE. Default: TRUE.
#' @param include_null Logical. Replace `NULL` if TRUE. Default: TRUE.
#' @param include_empty_str Logical. Replace empty strings `""` if TRUE. Default: TRUE.
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

  # ===========================================================================
  # Short-circuit for NULL input
  # ===========================================================================
  if (is.null(x)) {
    return(if (include_null) value else NULL)
  }

  # ===========================================================================
  # Compute void mask using `is_void`
  # ===========================================================================
  void <- is_void(
    x,
    include_na = include_na,
    include_null = include_null,
    include_empty_str = include_empty_str
  )
  void[is.na(void)] <- FALSE

  # ===========================================================================
  # Replace values
  # ===========================================================================
  if (is.list(x)) {
    x[void] <- rep(list(value), sum(void))
    return(x)
  }

  x[void] <- value
  x
}

# =============================================================================
# Data Frame Operations
# =============================================================================

#' cols_with_void(): Detect Columns Containing Void Values
#' @rdname void
#'
#' Scan a data.frame or tibble and identify columns that contain any "void" values.
#' Void values include `NA`, `NULL`, and `""`, which can be toggled via parameters.
#'
#' @param data A data.frame or tibble.
#' @param include_na Logical. Detect `NA` if TRUE. Default: TRUE.
#' @param include_null Logical. Detect `NULL` if TRUE. Default: TRUE.
#' @param include_empty_str Logical. Detect `""` if TRUE. Default: TRUE.
#' @param return_names Logical. If TRUE (default), return column names; else logical vector.
#'
#' @return A character vector (column names) or logical vector indicating void presence per column.
#' @export
#'
#' @examples
#' df <- data.frame(name = c("A", "", "C"), score = c(1, NA, 3), id = 1:3)
#' cols_with_void(df)
#' cols_with_void(df, return_names = FALSE)
#' cols_with_void(df, include_na = FALSE)
cols_with_void <- function(data,
                           include_na = TRUE,
                           include_null = TRUE,
                           include_empty_str = TRUE,
                           return_names = TRUE) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  # Check if data is a data.frame or tibble
  if (!is.data.frame(data)) {
    cli::cli_abort("Input must be a data.frame or tibble.")
  }

  # Validate logical parameters
  if (!is.logical(include_na) || length(include_na) != 1) {
    cli::cli_abort("`include_na` must be a single logical value.")
  }
  if (!is.logical(include_null) || length(include_null) != 1) {
    cli::cli_abort("`include_null` must be a single logical value.")
  }
  if (!is.logical(include_empty_str) || length(include_empty_str) != 1) {
    cli::cli_abort("`include_empty_str` must be a single logical value.")
  }
  if (!is.logical(return_names) || length(return_names) != 1) {
    cli::cli_abort("`return_names` must be a single logical value.")
  }

  # ===========================================================================
  # Void Detection Phase
  # ===========================================================================

  # Vectorized detection of void values per column (performance optimized)
  result <- vapply(data, function(col) {
    void <- is_void(col,
                    include_na = include_na,
                    include_null = include_null,
                    include_empty_str = include_empty_str)
    any(void, na.rm = TRUE)
  }, logical(1))

  # ===========================================================================
  # Return Result
  # ===========================================================================

  # Return column names or logical vector based on return_names
  if (return_names) {
    names(result)[result]
  } else {
    result
  }
}

#' rows_with_void: Detect rows containing void values (NA / NULL / "")
#' @rdname void
#'
#' Scan a data.frame or tibble and identify rows that contain any "void" values.
#' Void values include `NA`, `NULL`, and empty strings `""` (toggle via flags).
#'
#' @param data A data.frame or tibble.
#' @param include_na Logical. Detect `NA` if TRUE. Default: TRUE.
#' @param include_null Logical. Detect `NULL` if TRUE. Default: TRUE.
#' @param include_empty_str Logical. Detect empty strings `""` if TRUE. Default: TRUE.
#'
#' @return A logical vector of length `nrow(data)` indicating whether each row
#'   contains at least one void value.
#' @export
#'
#' @examples
#' df <- data.frame(id = 1:3, name = c("A", "", "C"), score = c(10, NA, 20))
#' rows_with_void(df)
#' df[rows_with_void(df), ]
rows_with_void <- function(data,
                           include_na = TRUE,
                           include_null = TRUE,
                           include_empty_str = TRUE) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================
  if (!is.data.frame(data)) {
    cli::cli_abort("Input must be a data.frame or tibble.")
  }

  # ===========================================================================
  # Row-wise scan using `is_void`
  # ===========================================================================
  result <- apply(
    data, 1,
    function(row) {
      any(is_void(
        row,
        include_na = include_na,
        include_null = include_null,
        include_empty_str = include_empty_str
      ))
    }
  )

  # ===========================================================================
  # Return
  # ===========================================================================
  result
}
