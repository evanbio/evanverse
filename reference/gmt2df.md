# gmt2df: Convert GMT File to Long-format Data Frame

Reads a .gmt gene set file and returns a long-format data frame with one
row per gene, including the gene set name and optional description.

## Usage

``` r
gmt2df(file, verbose = TRUE)
```

## Arguments

- file:

  Character. Path to a .gmt file (supports .gmt or .gmt.gz).

- verbose:

  Logical. Whether to show progress message. Default is TRUE.

## Value

A tibble with columns: term, description, and gene.

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires a GMT file to run:
gmt_file <- "path/to/geneset.gmt"
result <- gmt2df(gmt_file)
head(result, 10)
} # }
```
