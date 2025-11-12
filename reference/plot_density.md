# plot_density: Univariate Density Plot (Fill Group, Black Outline)

Create a density plot with group color as fill, and fixed black border
for all curves.

## Usage

``` r
plot_density(
  data,
  x,
  group = NULL,
  facet = NULL,
  palette = c("#1b9e77", "#d95f02", "#7570b3"),
  alpha = 0.7,
  base_size = 14,
  xlab = NULL,
  ylab = "Density",
  title = NULL,
  legend_pos = "right",
  adjust = 1,
  show_mean = FALSE,
  mean_line_color = "red",
  add_hist = FALSE,
  hist_bins = NULL,
  add_rug = FALSE,
  theme = "minimal"
)
```

## Arguments

- data:

  data.frame. Input dataset.

- x:

  Character. Name of numeric variable to plot.

- group:

  Character. Grouping variable for fill color. (Optional)

- facet:

  Character. Faceting variable. (Optional)

- palette:

  Character vector. Fill color palette, e.g.
  c("#FF0000","#00FF00","#0000FF"). Will be recycled as needed. Cannot
  be a palette name. Default: c("#1b9e77", "#d95f02", "#7570b3")

- alpha:

  Numeric. Fill transparency. Default: 0.7.

- base_size:

  Numeric. Theme base font size. Default: 14.

- xlab:

  Character. X-axis label. Default: NULL (uses variable name).

- ylab:

  Character. Y-axis label. Default: "Density".

- title:

  Character. Plot title. Default: NULL.

- legend_pos:

  Character. Legend position. One of "right", "left", "top", "bottom",
  "none". Default: "right".

- adjust:

  Numeric. Density bandwidth adjust. Default: 1.

- show_mean:

  Logical. Whether to add mean line. Default: FALSE.

- mean_line_color:

  Character. Mean line color. Default: "red".

- add_hist:

  Logical. Whether to add histogram layer. Default: FALSE.

- hist_bins:

  Integer. Number of histogram bins. Default: NULL (auto).

- add_rug:

  Logical. Whether to add rug marks at bottom. Default: FALSE.

- theme:

  Character. ggplot2 theme style. One of "minimal", "classic", "bw",
  "light", "dark". Default: "minimal".

## Value

ggplot object.
