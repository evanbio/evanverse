# Strict identity comparison

An infix operator for strict equality. Equivalent to
[`base::identical()`](https://rdrr.io/r/base/identical.html).

## Usage

``` r
a %is% b
```

## Arguments

- a:

  First object.

- b:

  Second object.

## Value

`TRUE` if identical, `FALSE` otherwise.

## Examples

``` r
1:3 %is% 1:3          # TRUE
#> [1] TRUE
1:3 %is% c(1, 2, 3)   # FALSE (integer vs double)
#> [1] FALSE
```
