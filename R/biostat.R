# =============================================================================
# biostat.R — Combinatorics and statistical utilities
# =============================================================================

#' Number of permutations P(n, k)
#'
#' Calculates the number of ordered arrangements of `k` items from `n` distinct items.
#' P(n, k) = n! / (n - k)!
#'
#' @param n Non-negative integer. Total number of items.
#' @param k Non-negative integer. Number of items to arrange. Must be <= `n`.
#'
#' @return A numeric value. Returns `0` when `k > n`, `1` when `k = 0`.
#' @export
#'
#' @examples
#' perm(8, 4)   # 1680
#' perm(5, 2)   # 20
#' perm(10, 0)  # 1
#' perm(5, 6)   # 0
perm <- function(n, k) {
  # Validate inputs
  n <- .assert_count_min(n, min = 0L)
  k <- .assert_count_min(k, min = 0L)

  # Special cases
  if (k > n) return(0)
  if (k == 0) return(1)

  # Warn if result likely overflows double (log scale check via lgamma)
  if (lgamma(n + 1) - lgamma(n - k + 1) > log(.Machine$double.xmax))
    cli::cli_alert_warning("P({n}, {k}) exceeds double range and will return Inf.")

  # Iterative multiplication: avoids computing full factorials
  result <- 1
  for (i in 0:(k - 1)) result <- result * (n - i)
  result
}


#' Number of combinations C(n, k)
#'
#' Calculates the number of ways to choose `k` items from `n` distinct items (unordered).
#' C(n, k) = n! / (k! * (n - k)!)
#'
#' @param n Non-negative integer. Total number of items.
#' @param k Non-negative integer. Number of items to choose. Must be <= `n`.
#'
#' @return A numeric value. Returns `0` when `k > n`, `1` when `k = 0` or `k = n`.
#' @export
#'
#' @examples
#' comb(8, 4)   # 70
#' comb(5, 2)   # 10
#' comb(10, 0)  # 1
#' comb(5, 6)   # 0
comb <- function(n, k) {
  # Validate inputs
  n <- .assert_count_min(n, min = 0L)
  k <- .assert_count_min(k, min = 0L)

  # Special cases
  if (k > n) return(0)
  if (k == 0 || k == n) return(1)

  # Warn if result likely overflows double (log scale check via lgamma)
  if (lgamma(n + 1) - lgamma(k + 1) - lgamma(n - k + 1) > log(.Machine$double.xmax))
    cli::cli_alert_warning("C({n}, {k}) exceeds double range and will return Inf.")

  # Use symmetry C(n,k) = C(n,n-k) to minimise multiplications
  if (k > n - k) k <- n - k
  prod((n - k + 1):n) / factorial(k)
}


