# Recode a column in a data frame using a named vector

Maps values in a column to new values using a named vector (`dict`).
Unmatched values are replaced with `default`.

## Usage

``` r
recode_column(data, column, dict, name = NULL, default = NA)
```

## Arguments

- data:

  A data.frame.

- column:

  Character. Column name to recode.

- dict:

  Named vector. Names are original values, values are replacements.

- name:

  Character or `NULL`. Name of the output column. If `NULL` (default),
  the original column is overwritten. Otherwise a new column is created.

- default:

  Default value for unmatched entries. Default: `NA`.

## Value

A data.frame with the recoded column.

## Examples

``` r
df <- data.frame(gene = c("TP53", "BRCA1", "EGFR", "XYZ"))
dict <- c("TP53" = "Tumor suppressor", "EGFR" = "Oncogene")
recode_column(df, "gene", dict, name = "label")
#>    gene            label
#> 1  TP53 Tumor suppressor
#> 2 BRCA1             <NA>
#> 3  EGFR         Oncogene
#> 4   XYZ             <NA>
recode_column(df, "gene", dict)
#>               gene
#> 1 Tumor suppressor
#> 2             <NA>
#> 3         Oncogene
#> 4             <NA>
```
