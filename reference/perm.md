# Calculate Number of Permutations A(n, k)

Calculates the total number of ways to arrange k items selected from n
distinct items, i.e., the number of permutations A(n, k) = n! / (n -
k)!. This function is intended for moderate n and k. For very large
numbers, consider supporting the 'gmp' package.

## Usage

``` r
perm(n, k)
```

## Arguments

- n:

  Integer. Total number of items (non-negative integer).

- k:

  Integer. Number of items selected for permutation (non-negative
  integer, must be \<= n).

## Value

Numeric. The permutation count A(n, k) (returns Inf for very large n).

## Examples

``` r
perm(8, 4)      # 1680
#> [1] 1680
perm(5, 2)      # 20
#> [1] 20
perm(10, 0)     # 1
#> [1] 1
perm(5, 6)      # 0
#> [1] 0
```
