# combine_logic: Combine multiple logical vectors with a logical operator

A utility function to combine two or more logical vectors using logical
AND (`&`) or OR (`|`) operations. Supports NA handling and checks for
consistent vector lengths.

## Usage

``` r
combine_logic(..., op = "&", na.rm = FALSE)
```

## Arguments

- ...:

  Logical vectors to combine.

- op:

  Operator to apply: `"&"` (default) or `"|"`.

- na.rm:

  Logical. If TRUE, treats NA values as TRUE (default is FALSE).

## Value

A single logical vector of the same length as inputs.

## Examples

``` r
x <- 1:5
combine_logic(x > 2, x %% 2 == 1)            # AND by default
#> [1] FALSE FALSE  TRUE FALSE  TRUE
combine_logic(x > 2, x %% 2 == 1, op = "|")  # OR logic
#> [1]  TRUE FALSE  TRUE  TRUE  TRUE
combine_logic(c(TRUE, NA), c(TRUE, TRUE), na.rm = TRUE)
#> [1] TRUE TRUE
```
