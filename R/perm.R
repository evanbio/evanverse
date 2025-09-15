#' Calculate Number of Permutations A(n, k)
#'
#' Calculates the total number of ways to arrange k items selected from n distinct items, i.e.,
#' the number of permutations A(n, k) = n! / (n - k)!.
#' This function is intended for moderate n and k. For very large numbers, consider supporting the 'gmp' package.
#'
#' @param n Integer. Total number of items (non-negative integer).
#' @param k Integer. Number of items selected for permutation (non-negative integer, must be ≤ n).
#'
#' @return Numeric. The permutation count A(n, k) (returns Inf for very large n).
#' @export
#'
#' @examples
#' perm(8, 4)      # 1680
#' perm(5, 2)      # 20
#' perm(10, 0)     # 1
#' perm(5, 6)      # 0
perm <- function(n, k) {

  # ===========================================================================
  # Parameter validation
  # ===========================================================================

  # Validate n parameter
  if (missing(n) || !is.numeric(n) || length(n) != 1 || is.na(n)) {
    cli::cli_abort("'n' must be a single numeric value.")
  }

  # Validate k parameter
  if (missing(k) || !is.numeric(k) || length(k) != 1 || is.na(k)) {
    cli::cli_abort("'k' must be a single numeric value.")
  }

  # Check for non-negative values
  if (n < 0 || k < 0) {
    cli::cli_abort("'n' and 'k' must be non-negative.")
  }

  # Check for integer values
  if (n != round(n) || k != round(k)) {
    cli::cli_abort("'n' and 'k' must be integers.")
  }

  # Convert to integers
  n <- as.integer(n)
  k <- as.integer(k)

  # ===========================================================================
  # Special cases
  # ===========================================================================

  # If k > n, return 0
  if (k > n) {
    return(0L)
  }

  # If k == 0, return 1 (empty permutation)
  if (k == 0) {
    return(1L)
  }

  # ===========================================================================
  # Main calculation
  # ===========================================================================

  # For large n, warn about potential overflow
  if (n > 20) {
    cli::cli_alert_warning("Large n ({n}) may cause numeric overflow. Consider using the 'gmp' package for arbitrary precision.")
  }

  # Calculate permutation: P(n,k) = n! / (n-k)!
  # Use iterative multiplication to avoid computing large factorials
  result <- 1
  for (i in 0:(k-1)) {
    result <- result * (n - i)
  }

  return(result)
}
