# %map%: Case-insensitive mapping returning named vector

Performs case-insensitive matching between elements in `x` and entries
in `table`, returning a named character vector: names are the matched
entries from `table`, values are the original elements from `x`.
Unmatched values are ignored (not included in the result).

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

A named character vector. Names are from matched `table` values, values
are from `x`. If no matches are found, returns a zero-length named
character vector.

## Examples

``` r
# Basic matching (case-insensitive)
c("tp53", "brca1", "egfr") %map% c("TP53", "EGFR", "MYC")
#>   TP53   EGFR 
#> "tp53" "egfr" 
# returns: Named vector: TP53 = "tp53", EGFR = "egfr"

# Values not in table are dropped
c("akt1", "tp53") %map% c("TP53", "EGFR")
#>   TP53 
#> "tp53" 
# returns: TP53 = "tp53"

# All unmatched values returns: empty result
c("none1", "none2") %map% c("TP53", "EGFR")
#> named character(0)
# returns: character(0)
```
