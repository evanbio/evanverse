# Plot a Clean Pie Chart with Optional Inner Labels

Generate a polished pie chart from a vector or a grouped data frame.
Labels (optional) are placed inside the pie slices.

## Usage

``` r
plot_pie(
  data,
  group_col = "group",
  count_col = "count",
  label = c("none", "count", "percent", "both"),
  label_size = 4,
  label_color = "black",
  fill = c("#009076", "#C71E1D", "#15607A", "#FA8C00", "#18A1CD"),
  title = "Pie Chart",
  title_size = 14,
  title_color = "black",
  legend.position = "right",
  preview = TRUE,
  save = NULL,
  return_data = FALSE
)
```

## Arguments

- data:

  A character/factor vector or data.frame.

- group_col:

  Group column name (for data.frame). Default: "group".

- count_col:

  Count column name (for data.frame). Default: "count".

- label:

  Type of label to display: "none", "count", "percent", or "both".
  Default: "none".

- label_size:

  Label font size. Default: 4.

- label_color:

  Label font color. Default: "black".

- fill:

  Fill color vector. Default: 5-color palette.

- title:

  Plot title. Default: "Pie Chart".

- title_size:

  Title font size. Default: 14.

- title_color:

  Title color. Default: "black".

- legend.position:

  Legend position. Default: "right".

- preview:

  Whether to print the plot. Default: TRUE.

- save:

  Optional path to save the plot (e.g., "plot.png").

- return_data:

  If TRUE, return list(plot = ..., data = ...). Default: FALSE.

## Value

A ggplot object or list(plot, data)
