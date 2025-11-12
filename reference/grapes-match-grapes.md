# %match%: Case-insensitive match returning indices

Performs case-insensitive matching, like
[`base::match()`](https://rdrr.io/r/base/match.html), but ignores letter
case.

## Usage

``` r
x %match% table
```

## Arguments

- x:

  Character vector to match.

- table:

  Character vector of values to match against.

## Value

An integer vector of the positions of matches of `x` in `table`, like
[`base::match()`](https://rdrr.io/r/base/match.html). Returns `NA` for
non-matches. Returns an integer(0) if `x` is length 0.

## Examples

``` r
# Basic matching
c("tp53", "BRCA1", "egfr") %match% c("TP53", "EGFR", "MYC")
#> [1]  1 NA  2
# returns: 1 NA 2

# No matches returns: all NA
c("aaa", "bbb") %match% c("xxx", "yyy")
#> [1] NA NA

# Empty input
character(0) %match% c("a", "b")
#> integer(0)

# Order sensitivity (like match): first match is returned
c("x") %match% c("X", "x", "x")
#> [1] 1
# returns: 1
```
