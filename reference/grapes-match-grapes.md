# Case-insensitive match returning indices

Like [`base::match()`](https://rdrr.io/r/base/match.html), but ignores
letter case. Useful for gene ID matching.

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

An integer vector of match positions. Returns `NA` for non-matches.

## Note

Both `x` and `table` must be **non-empty** character vectors;
`character(0)` or non-character inputs raise an error. This differs from
[`base::match()`](https://rdrr.io/r/base/match.html) and `%nin%`, which
accept empty vectors. The stricter contract is intentional for gene-ID
workflows where an empty query almost always signals a upstream mistake.

## Examples

``` r
c("tp53", "BRCA1", "egfr") %match% c("TP53", "EGFR", "MYC")
#> [1]  1 NA  2
# returns: 1 NA 2
```
