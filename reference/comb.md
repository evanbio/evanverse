# comb: Calculate Number of Combinations C(n, k)

Calculates the total number of ways to choose k items from n distinct
items (without regard to order), i.e., the number of combinations C(n,
k) = n! / (k! \* (n - k)!). This function is intended for moderate n and
k. For very large values, consider the 'gmp' package.

## Usage

``` r
comb(n, k)
```

## Arguments

- n:

  Integer. Total number of items (non-negative integer).

- k:

  Integer. Number of items to choose (non-negative integer, must be \<=
  n).

## Value

Numeric. The combination count C(n, k) (returns Inf for very large n).

## Examples

``` r
comb(8, 4)      # 70
#> [1] 70
comb(5, 2)      # 10
#> [1] 10
comb(10, 0)     # 1
#> [1] 1
comb(5, 6)      # 0
#> [1] 0
```
