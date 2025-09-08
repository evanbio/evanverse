#' combine_logic: Combine multiple logical vectors with a logical operator
#'
#' A utility function to combine two or more logical vectors using
#' logical AND (`&`) or OR (`|`) operations. Supports NA handling and
#' checks for consistent vector lengths.
#'
#' @param ... Logical vectors to combine.
#' @param op Operator to apply: `"&"` (default) or `"|"`.
#' @param na.rm Logical. If TRUE, treats NA values as TRUE (default is FALSE).
#'
#' @return A single logical vector of the same length as inputs.
#' @export
#'
#' @examples
#' x <- 1:5
#' combine_logic(x > 2, x %% 2 == 1)            # AND by default
#' combine_logic(x > 2, x %% 2 == 1, op = "|")  # OR logic
#' combine_logic(c(TRUE, NA), c(TRUE, TRUE), na.rm = TRUE)
combine_logic <- function(..., op = "&", na.rm = FALSE) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  # Collect all input arguments
  args <- list(...)

  # Ensure all inputs are logical vectors
  if (!all(vapply(args, is.logical, logical(1)))) {
    cli::cli_abort("All inputs must be logical vectors.")
  }

  # Check if all vectors have the same length
  if (!all(lengths(args) == length(args[[1]]))) {
    cli::cli_abort("All logical vectors must be the same length.")
  }

  # Validate operator parameter
  op <- match.arg(op, c("&", "|"))

  # ===========================================================================
  # NA Handling Phase
  # ===========================================================================

  # Handle NA values if requested
  if (na.rm) {
    args <- lapply(args, function(x) {
      x[is.na(x)] <- TRUE
      x
    })
  }

  # ===========================================================================
  # Operator Selection and Combination Phase
  # ===========================================================================

  # Determine the combining operator
  op_fn <- switch(op,
                  "&" = `&`,
                  "|" = `|`)

  # Combine all logical vectors using Reduce (efficient for multiple vectors)
  Reduce(op_fn, args)
}
