#' comb: Calculate Number of Combinations C(n, k)
#'
#' Calculates the total number of ways to choose k items from n distinct items (without regard to order),
#' i.e., the number of combinations C(n, k) = n! / (k! * (n - k)!).
#' This function is intended for moderate n and k. For very large values, consider the 'gmp' package.
#'
#' @param n Integer. Total number of items (non-negative integer).
#' @param k Integer. Number of items to choose (non-negative integer, must be \\u2264 n).
#'
#' @return Numeric. The combination count C(n, k) (returns Inf for very large n).
#' @export
#'
#' @examples
#' comb(8, 4)      # 70
#' comb(5, 2)      # 10
#' comb(10, 0)     # 1
#' comb(5, 6)      # 0
comb <- function(n, k) {

  # ===========================================================================
  # Parameter Validation Phase
  # ===========================================================================

  # Check if n and k are single numeric values
  if (!is.numeric(n) || !is.numeric(k) || length(n) != 1 || length(k) != 1) {
    cli::cli_abort("Arguments 'n' and 'k' must be single numeric values.")
  }

  # Check for non-negative values
  if (n < 0 || k < 0) {
    cli::cli_abort("'n' and 'k' must be non-negative integers.")
  }

  # Check for integer values
  if (abs(n - round(n)) > .Machine$double.eps^0.5 ||
      abs(k - round(k)) > .Machine$double.eps^0.5) {
    cli::cli_abort("'n' and 'k' must be integers.")
  }

  # Convert to integers
  n <- as.integer(n)
  k <- as.integer(k)

  # ===========================================================================
  # Special Cases Handling
  # ===========================================================================

  if (k > n) return(0L)
  if (k == 0 || k == n) return(1L)

  # ===========================================================================
  # Main Calculation Phase
  # ===========================================================================

  # Optimize calculation to avoid large factorials: C(n,k) = prod((n-k+1):n) / k!
  # This prevents overflow for moderate n
  if (k > n - k) k <- n - k  # Use symmetry: C(n,k) = C(n,n-k)

  result <- prod((n - k + 1):n) / factorial(k)

  # ===========================================================================
  # Return Result
  # ===========================================================================

  return(result)
}
