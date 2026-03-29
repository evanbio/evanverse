# Convert a data frame to a named list by grouping

Groups a data frame by one column and collects values from another
column into a named list.

## Usage

``` r
df2list(data, group_col, value_col)
```

## Arguments

- data:

  A data.frame or tibble.

- group_col:

  Character. Column name to use as list names.

- value_col:

  Character. Column name to collect as list values.

## Value

A named list where each element is a vector of values for that group.

## Examples

``` r
df <- data.frame(
  cell_type = c("T_cells", "T_cells", "B_cells", "B_cells"),
  marker    = c("CD3D", "CD3E", "CD79A", "MS4A1")
)
df2list(df, "cell_type", "marker")
#> $B_cells
#> [1] "CD79A" "MS4A1"
#> 
#> $T_cells
#> [1] "CD3D" "CD3E"
#> 
```
