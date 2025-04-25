#' Approximate numeric comparison with tolerance and diagnostics
#'
#' A semantic binary operator to check whether two numeric objects are
#' approximately equal, allowing for small floating-point errors.
#' Provides detailed diagnostics if the comparison fails.
#'
#' @param a First object (numeric vector, matrix, or data.frame)
#' @param b Second object to compare against
#' @param tol Tolerance level for numeric differences (default: sqrt(.Machine$double.eps))
#'
#' @return TRUE if all values are approximately equal, FALSE otherwise (with diagnostics)
#' @export
#'
#' @examples
#' x <- c(1 / 49 * 49, sqrt(2)^2)
#' x %near% c(1, 2)  # TRUE
#' data.frame(a = c(1, 2.00000001)) %near% data.frame(a = c(1, 2))  # TRUE
`%near%` <- function(a, b, tol = sqrt(.Machine$double.eps)) {
  if (missing(a) || missing(b)) {
    stop("Both arguments must be provided to %near%")
  }

  # Helper: Check supported types
  is_supported <- function(x) {
    (is.atomic(x) && is.numeric(x) && !is.list(x)) || 
        (is.matrix(x) && is.numeric(x)) ||
        (is.data.frame(x) && all(sapply(x, is.numeric)))
  }

  if (!is_supported(a)) {
    cli::cli_alert_danger("Unsupported type for a: {.val {class(a)}}")
    return(FALSE)
  }

  if (!is_supported(b)) {
    cli::cli_alert_danger("Unsupported type for b: {.val {class(b)}}")
    return(FALSE)
  }

  # Dimension or length check
  if (is.vector(a) && !is.matrix(a) && length(a) != length(b)) {
    cli::cli_alert_danger("Length mismatch: {.val {length(a)}} vs {.val {length(b)}}")
    return(FALSE)
  }

  if ((is.matrix(a) || is.data.frame(a)) && !identical(dim(a), dim(b))) {
    cli::cli_alert_danger("Dimension mismatch: {.val {paste(dim(a), collapse = 'x')}} vs {.val {paste(dim(b), collapse = 'x')}}")
    return(FALSE)
  }

  # Name check (optional warning)
  if (is.data.frame(a) && !identical(names(a), names(b))) {
    cli::cli_alert_warning("Column names differ: {.val {paste0(names(a), collapse = ', ')}} vs {.val {paste0(names(b), collapse = ', ')}}")
  }

  # Core comparison function
  is_near <- function(x, y) abs(x - y) <= tol

  # Data frame comparison
  if (is.data.frame(a)) {
    for (col in intersect(names(a), names(b))) {
      if (!all(is_near(a[[col]], b[[col]]))) {
        i <- which(!is_near(a[[col]], b[[col]]))[1]
        cli::cli_alert_danger("Values differ in column '{col}' at row {i}: {.val {a[[col]][i]}} vs {.val {b[[col]][i]}}")
        return(FALSE)
      }
    }
  } else if (is.matrix(a)) {
    # Matrix element-wise comparison
    diff_idx <- which(!is_near(a, b), arr.ind = TRUE)
    if (nrow(diff_idx) > 0) {
      cli::cli_alert_danger("Values differ at {nrow(diff_idx)} position(s), e.g., [{diff_idx[1,1]}, {diff_idx[1,2]}]: {.val {a[diff_idx[1,1], diff_idx[1,2]]}} vs {.val {b[diff_idx[1,1], diff_idx[1,2]]}}")
      return(FALSE)
    }
  } else if (is.vector(a)) {
    # Vector element-wise comparison
    diff_idx <- which(!is_near(a, b))
    if (length(diff_idx) > 0) {
      cli::cli_alert_danger("Values differ at {length(diff_idx)} position(s), e.g., index {diff_idx[1]}: {.val {a[diff_idx[1]]}} vs {.val {b[diff_idx[1]]}}")
      return(FALSE)
    }
  }

  return(TRUE)
}
