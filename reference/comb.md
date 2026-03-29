# Number of combinations C(n, k)

Calculates the number of ways to choose `k` items from `n` distinct
items (unordered). C(n, k) = n! / (k! \* (n - k)!)

## Usage

``` r
comb(n, k)
```

## Arguments

- n:

  Non-negative integer. Total number of items.

- k:

  Non-negative integer. Number of items to choose. Must be \<= `n`.

## Value

A numeric value. Returns `0` when `k > n`, `1` when `k = 0` or `k = n`.

## Examples

``` r
comb(8, 4)   # 70
#> [1] 70
comb(5, 2)   # 10
#> [1] 10
comb(10, 0)  # 1
#> [1] 1
comb(5, 6)   # 0
#> [1] 0
```
