# Case-insensitive mapping returning a named vector

Like `%match%`, but returns a named character vector instead of indices.
Names are canonical entries from `table`; values are the original
elements from `x`. Unmatched values are dropped.

## Usage

``` r
x %map% table
```

## Arguments

- x:

  Character vector of input strings.

- table:

  Character vector to match against.

## Value

A named character vector. Names are canonical entries from `table`;
values are the original elements from `x`. Order follows `x` (not
`table`). Unmatched entries are dropped.

## Note

Both `x` and `table` must be non-empty character vectors without `NA` or
empty string values. If `table` contains duplicated values after case
normalization, the first match is used with a warning.

## Examples

``` r
c("tp53", "brca1", "egfr") %map% c("TP53", "EGFR", "MYC")
#>   TP53   EGFR 
#> "tp53" "egfr" 
# returns: TP53 = "tp53", EGFR = "egfr"
```
