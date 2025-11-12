# Bar plot with optional fill grouping, sorting, and directional layout

Create a bar chart from a data frame with optional grouping (`fill`),
vertical/horizontal orientation, and sorting by values.

## Usage

``` r
plot_bar(
  data,
  x,
  y,
  fill = NULL,
  direction = c("vertical", "horizontal"),
  sort = FALSE,
  sort_by = NULL,
  sort_dir = c("asc", "desc"),
  width = 0.7,
  ...
)
```

## Arguments

- data:

  A data frame.

- x:

  Column name for the x-axis (quoted or unquoted).

- y:

  Column name for the y-axis (quoted or unquoted).

- fill:

  Optional character scalar. Column name to map to fill (grouping).

- direction:

  Plot direction: "vertical" or "horizontal". Default: "vertical".

- sort:

  Logical. Whether to sort bars based on y values. Default: FALSE.

- sort_by:

  Optional. If `fill` is set and `sort = TRUE`, choose which level of
  `fill` is used for sorting.

- sort_dir:

  Sorting direction: "asc" or "desc". Default: "asc".

- width:

  Numeric. Bar width. Default: 0.7.

- ...:

  Additional args passed to
  [`ggplot2::geom_bar()`](https://ggplot2.tidyverse.org/reference/geom_bar.html),
  e.g. `alpha`, `color`.

## Value

A `ggplot` object.
