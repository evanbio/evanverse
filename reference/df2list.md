# Convert Data Frame to Named List by Grouping

Group a data frame by one column and convert to named list. Each key
becomes a list name; each value column becomes vector.

## Usage

``` r
df2list(data, key_col, value_col, verbose = TRUE)
```

## Arguments

- data:

  A data.frame or tibble to be grouped.

- key_col:

  Character. Column name for list names.

- value_col:

  Character. Column name for list values.

- verbose:

  Logical. Whether to show message. Default = TRUE.

## Value

A named list, where each element is a character vector of values.

## Examples

``` r
df <- data.frame(
  cell_type = c("T_cells", "T_cells", "B_cells", "B_cells"),
  marker = c("CD3D", "CD3E", "CD79A", "MS4A1")
)
df2list(df, "cell_type", "marker")
#> ✔ Converted 2 groups into a named list.
#> $B_cells
#> [1] "CD79A" "MS4A1"
#> 
#> $T_cells
#> [1] "CD3D" "CD3E"
#> 
```
