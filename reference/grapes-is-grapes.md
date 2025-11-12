# Strict identity comparison with diagnostics

A semantic operator that checks whether two objects are strictly
identical, and prints where they differ if not.

## Usage

``` r
a %is% b
```

## Arguments

- a:

  First object (vector, matrix, or data.frame)

- b:

  Second object (vector, matrix, or data.frame)

## Value

TRUE if identical, FALSE otherwise (with diagnostics)

## Examples

``` r
1:3 %is% 1:3                  # TRUE
#> [1] TRUE
1:3 %is% c(1, 2, 3)           # FALSE, type mismatch (integer vs double)
#> ── Objects are NOT identical ───────────────────────────────────────────────────
#> ✖ Type mismatch: integer vs double
#> ✖ Class mismatch: integer vs numeric
#> [1] FALSE
data.frame(x=1) %is% data.frame(y=1)  # FALSE, column name mismatch
#> ── Objects are NOT identical ───────────────────────────────────────────────────
#> ✖ Column names differ: x vs y
#> [1] FALSE
m1 <- matrix(1:4, nrow=2)
m2 <- matrix(c(1,99,3,4), nrow=2)
m1 %is% m2                  # FALSE, value differs at [1,2]
#> ── Objects are NOT identical ───────────────────────────────────────────────────
#> ✖ Type mismatch: integer vs double
#> ✖ Values differ at 1 cell(s), e.g., [2,1]: 2 vs 99
#> [1] FALSE
c(a=1, b=2) %is% c(b=2, a=1) # FALSE, names differ
#> ── Objects are NOT identical ───────────────────────────────────────────────────
#> ✖ Names differ: a, b vs b, a
#> ✖ Values differ at 2 position(s), e.g., index 1: 1 vs 2
#> [1] FALSE
```
