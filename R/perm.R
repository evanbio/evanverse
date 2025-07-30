#' 🧮 perm: Calculate Number of Permutations A(n, k)
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
  # --- Parameter checks ---
  # Ensure n and k are single numeric values
  if (!is.numeric(n) || !is.numeric(k) || length(n) != 1 || length(k) != 1) {
    stop("Arguments 'n' and 'k' must be single numeric values.")
  }
  # Ensure non-negative
  if (n < 0 || k < 0) {
    stop("'n' and 'k' must be non-negative integers.")
  }
  # Ensure integers
  if (abs(n - round(n)) > .Machine$double.eps^0.5 ||
      abs(k - round(k)) > .Machine$double.eps^0.5) {
    stop("'n' and 'k' must be integers.")
  }
  n <- as.integer(n)
  k <- as.integer(k)

  # --- Special cases ---
  # If k > n or k < 0, return 0
  if (k > n) return(0L)
  # If k == 0, return 1 (the empty permutation)
  if (k == 0) return(1L)

  # --- Main calculation ---
  # Calculate the permutation count
  result <- factorial(n) / factorial(n - k)

  # --- Return result ---
  return(result)
}
