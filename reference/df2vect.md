# Convert a data frame to a named vector

Extracts two columns from a data frame and returns a named vector, using
one column as names and the other as values. The value column type is
preserved as-is.

## Usage

``` r
df2vect(data, name_col, value_col)
```

## Arguments

- data:

  A data.frame or tibble.

- name_col:

  Character. Column to use as vector names. Must not contain `NA`, empty
  strings, or duplicate entries; all trigger an error.

- value_col:

  Character. Column name whose values become the vector elements. The
  original column type is preserved.

## Value

A named vector with the same type as `data[[value_col]]`.

## Examples

``` r
df <- data.frame(
  gene  = c("TP53", "BRCA1", "MYC"),
  score = c(0.9, 0.7, 0.5)
)
df2vect(df, "gene", "score")
#>  TP53 BRCA1   MYC 
#>   0.9   0.7   0.5 
```
