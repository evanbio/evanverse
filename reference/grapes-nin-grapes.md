# Not-in operator

Tests whether elements of `x` are **not** present in `table`. Equivalent
to `!(x %in% table)`. NA behaviour follows base R semantics.

## Usage

``` r
x %nin% table
```

## Arguments

- x:

  A vector of values to test.

- table:

  A vector of values to test against.

## Value

A logical vector.

## Examples

``` r
c("A", "B", "C") %nin% c("B", "D")   # TRUE FALSE TRUE
#> [1]  TRUE FALSE  TRUE
1:5 %nin% c(2, 4)                    # TRUE FALSE TRUE FALSE TRUE
#> [1]  TRUE FALSE  TRUE FALSE  TRUE
```
