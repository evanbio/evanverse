# Safely Execute an Expression

Evaluate code with unified error handling (and consistent warning
reporting). On error, prints a CLI message (unless `quiet = TRUE`) and
returns `NULL`.

## Usage

``` r
safe_execute(expr, fail_message = "An error occurred", quiet = FALSE)
```

## Arguments

- expr:

  Code to evaluate.

- fail_message:

  Message to display if an error occurs. Default: "An error occurred".

- quiet:

  Logical. If `TRUE`, suppress messages. Default: `FALSE`.

## Value

The result of the expression if successful; otherwise `NULL`.

## Examples

``` r
safe_execute(log(1))
#> [1] 0
safe_execute(log("a"), fail_message = "Failed to compute log")
#> ✖ Failed to compute log: non-numeric argument to mathematical function
#> NULL
```
