# `%nin%`: Not-in operator (negation of `%in%`)

A binary operator to test whether elements of the left-hand vector are
**not** present in the right-hand vector. This is equivalent to
`!(x %in% table)`.

## Usage

``` r
x %nin% table
```

## Arguments

- x:

  vector or NULL: the values to be matched.

- table:

  vector or NULL: the values to be matched against.

## Value

A logical vector where `TRUE` indicates the corresponding element of `x`
is not present in `table`. Results involving `NA` follow base R
semantics: e.g., if `x` contains `NA` and `table` does not, the result
at that position is `NA` (since `!NA` is `NA`).

## Examples

``` r
c("A", "B", "C") %nin% c("B", "D")   # TRUE FALSE TRUE
#> [1]  TRUE FALSE  TRUE
1:5 %nin% c(2, 4)                    # TRUE FALSE TRUE FALSE TRUE
#> [1]  TRUE FALSE  TRUE FALSE  TRUE
NA %nin% c(1, 2)                     # NA (since NA %in% c(1,2) is NA)
#> [1] TRUE
NA %nin% c(NA, 1)                    # FALSE (since NA is in table)
#> [1] FALSE

# Works with mixed types as `%in%` does:
c(1, "a") %nin% c("a", "b", 2)
#> [1]  TRUE FALSE
```
