# gmt2list: Convert GMT File to Named List

Reads a .gmt gene set file and returns a named list, where each list
element is a gene set.

## Usage

``` r
gmt2list(file, verbose = TRUE)
```

## Arguments

- file:

  Character. Path to a .gmt file.

- verbose:

  Logical. Whether to print message. Default is TRUE.

## Value

A named list where each element is a character vector of gene symbols.

## Examples

``` r
if (FALSE) { # \dontrun{
# Requires a GMT file to run:
gmt_file <- "path/to/geneset.gmt"
gene_sets <- gmt2list(gmt_file)
length(gene_sets)
names(gene_sets)[1:3]
} # }
```
