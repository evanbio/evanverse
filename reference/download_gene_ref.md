# Download gene annotation reference table from Ensembl

Downloads a standardized gene annotation table for human or mouse using
`biomaRt`. Includes Ensembl ID, gene symbol, Entrez ID, gene type,
chromosome location, and other metadata.

## Usage

``` r
download_gene_ref(species = c("human", "mouse"), dest = NULL)
```

## Arguments

- species:

  One of `"human"` or `"mouse"`. Default: `"human"`.

- dest:

  Character or `NULL`. File path to save the result as `.rds`. If `NULL`
  (default), the result is not saved.

## Value

A `data.frame` containing gene annotation.
