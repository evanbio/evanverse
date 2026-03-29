# Number of permutations P(n, k)

Calculates the number of ordered arrangements of `k` items from `n`
distinct items. P(n, k) = n! / (n - k)!

## Usage

``` r
perm(n, k)
```

## Arguments

- n:

  Non-negative integer. Total number of items.

- k:

  Non-negative integer. Number of items to arrange. Must be \<= `n`.

## Value

A numeric value. Returns `0` when `k > n`, `1` when `k = 0`.

## Examples

``` r
perm(8, 4)   # 1680
#> [1] 1680
perm(5, 2)   # 20
#> [1] 20
perm(10, 0)  # 1
#> [1] 1
perm(5, 6)   # 0
#> [1] 0
```
