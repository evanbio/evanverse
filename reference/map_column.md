# map_column(): Map values in a column using named vector or list

Maps values in a column of a data.frame (query) to new values using a
named vector or list (`map`), optionally creating a new column or
replacing the original.

## Usage

``` r
map_column(
  query,
  by,
  map,
  to = "mapped",
  overwrite = FALSE,
  default = "unknown",
  preview = TRUE
)
```

## Arguments

- query:

  A data.frame containing the column to be mapped.

- by:

  A string. Column name in `query` to be mapped.

- map:

  A named vector or list. Names are original values, values are mapped
  values.

- to:

  A string. Name of the column to store mapped results (if
  `overwrite = FALSE`).

- overwrite:

  Logical. Whether to replace the `by` column with mapped values.
  Default: FALSE.

- default:

  Default value to assign if no match is found. Default: "unknown".

- preview:

  Logical. Whether to print preview of result (default TRUE).

## Value

A data.frame with a new or modified column based on the mapping
(returned invisibly).

## Examples

``` r
df <- data.frame(gene = c("TP53", "BRCA1", "EGFR", "XYZ"))
gene_map <- c("TP53" = "Tumor suppressor", "EGFR" = "Oncogene")
map_column(df, by = "gene", map = gene_map, to = "label")
#> ℹ Mapping completed for 'gene': 2 unmatched value(s) assigned to default.
#> ✔ New column 'label' created using mapping.
#>    gene            label
#> 1  TP53 Tumor suppressor
#> 2 BRCA1          unknown
#> 3  EGFR         Oncogene
#> 4   XYZ          unknown
```
