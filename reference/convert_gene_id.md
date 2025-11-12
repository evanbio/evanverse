# convert_gene_id(): Convert gene identifiers using a reference table

Converts between Ensembl, Symbol, and Entrez gene IDs using a reference
table. Supports both character vectors and data.frame columns.
Automatically loads species-specific reference data from `data/`, or
downloads if unavailable.

## Usage

``` r
convert_gene_id(
  query,
  from = "symbol",
  to = c("ensembl_id", "entrez_id"),
  species = c("human", "mouse"),
  query_col = NULL,
  ref_table = NULL,
  keep_na = FALSE,
  preview = TRUE
)
```

## Arguments

- query:

  Character vector or data.frame to convert.

- from:

  Source ID type (e.g., "symbol", "ensembl_id", "entrez_id").

- to:

  Target ID type(s). Supports multiple.

- species:

  Either `"human"` or `"mouse"`. Default `"human"`.

- query_col:

  If `query` is a data.frame, the column name to convert.

- ref_table:

  Optional reference table.

- keep_na:

  Logical. Whether to keep unmatched rows. Default: `FALSE`.

- preview:

  Logical. Whether to preview output. Default: `TRUE`.

## Value

A `data.frame` containing original and converted columns.
