# Download gene annotation reference table from Ensembl

Downloads a standardized gene annotation table for human or mouse using
`biomaRt`. Includes Ensembl ID, gene symbol, Entrez ID, gene type,
chromosome location, and other metadata.

## Usage

``` r
download_gene_ref(
  species = c("human", "mouse"),
  remove_empty_symbol = FALSE,
  remove_na_entrez = FALSE,
  save = FALSE,
  save_path = NULL
)
```

## Arguments

- species:

  Organism, either `"human"` or `"mouse"`. Default is `"human"`.

- remove_empty_symbol:

  Logical. Remove entries with missing gene symbol. Default: `FALSE`.

- remove_na_entrez:

  Logical. Remove entries with missing Entrez ID. Default: `FALSE`.

- save:

  Logical. Whether to save the result as `.rds`. Default: `FALSE`.

- save_path:

  File path to save (optional). If `NULL`, will use default
  `gene_ref_<species>_<date>.rds`.

## Value

A `data.frame` containing gene annotation.
