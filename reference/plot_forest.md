# Forest Plot with Advanced Customization

Create publication-ready forest plots with extensive customization for
confidence intervals, themes, colors, borders, and layout. Designed for
meta-analysis and comparative study visualizations.

## Usage

``` r
plot_forest(
  data,
  est,
  lower,
  upper,
  ci_column,
  ref_line = 1,
  xlim = NULL,
  ticks_at = NULL,
  arrow_lab = NULL,
  sizes = 0.6,
  nudge_y = 0.2,
  theme_preset = "default",
  theme_custom = NULL,
  align_left = NULL,
  align_center = NULL,
  align_right = NULL,
  bold_group = NULL,
  bold_group_col = 1,
  bold_pvalue_cols = NULL,
  p_threshold = 0.05,
  bold_custom = NULL,
  background_style = "none",
  background_group_rows = NULL,
  background_colors = NULL,
  ci_colors = NULL,
  ci_group_ids = NULL,
  add_borders = TRUE,
  border_width = 3,
  group_headers = NULL,
  group_border_width = 6,
  custom_borders = NULL,
  height_top = 8,
  height_header = 12,
  height_main = 10,
  height_bottom = 8,
  width_left = 10,
  width_right = 10,
  width_adjust = 5,
  height_custom = NULL,
  width_custom = NULL,
  layout_verbose = TRUE,
  save_plot = FALSE,
  filename = "forest_plot",
  save_path = ".",
  save_formats = c("png", "pdf"),
  save_width = 35,
  save_height = 42,
  save_units = "cm",
  save_dpi = 300,
  save_bg = "white",
  save_overwrite = TRUE,
  save_verbose = TRUE
)
```

## Arguments

- data:

  Data frame containing the plot data (both text and numeric columns).

- est:

  List of numeric vectors containing effect estimates. Use
  [`list()`](https://rdrr.io/r/base/list.html) even for single group.
  Example: `list(data$estimate)` or
  `list(data$estimate_1, data$estimate_2)`.

- lower:

  List of numeric vectors containing lower CI bounds.

- upper:

  List of numeric vectors containing upper CI bounds.

- ci_column:

  Integer vector specifying which column(s) to draw CI graphics.
  Example: `c(3)` for single group, `c(3, 7)` for two groups.

- ref_line:

  Numeric. Reference line position (e.g., 1 for OR, 0 for mean
  difference). Default: 1.

- xlim:

  Numeric vector of length 2. X-axis limits. Default: `NULL`
  (auto-calculate).

- ticks_at:

  Numeric vector. X-axis tick positions. Default: `NULL`
  (auto-calculate).

- arrow_lab:

  Character vector of length 2. Labels for left and right arrows.
  Example: `c("Favors A", "Favors B")`. Default: `NULL`.

- sizes:

  Numeric. Size of CI center points. Can be:

  - Single value: Automatically applied to all rows (e.g., `0.6`)

  - Vector: Must match the number of data rows. If length is
    insufficient, later rows will have no CI displayed. To repeat a
    pattern, use `rep(c(0.5, 0.4, 0.3), length.out = nrow(data))`.

  Default: 0.6.

- nudge_y:

  Numeric. Vertical nudge for multi-group CI positioning. Default: 0.2.

- theme_preset:

  Character. Theme preset name. Default: `"default"`. See
  `.get_forest_theme()` for available presets.

- theme_custom:

  List. Custom theme parameters to override preset. Default: `NULL`.

- align_left:

  Integer vector. Columns to left-align. Default: `NULL`.

- align_center:

  Integer vector. Columns to center-align. Default: `NULL`.

- align_right:

  Integer vector. Columns to right-align. Default: `NULL`.

- bold_group:

  Character vector. Group names to bold. Default: `NULL`.

- bold_group_col:

  Integer. Column containing group names. Default: 1.

- bold_pvalue_cols:

  Integer vector. P-value columns to bold if significant. Default:
  `NULL`.

- p_threshold:

  Numeric. P-value threshold for bolding. Default: 0.05.

- bold_custom:

  List of custom bold specifications. Default: `NULL`.

- background_style:

  Character. Background style: `"none"`, `"zebra"`, `"group"`,
  `"block"`. Default: `"none"`.

- background_group_rows:

  Integer vector. Row indices of group headers (for `"group"` and
  `"block"` styles). Default: `NULL`.

- background_colors:

  Named list of colors (primary, secondary, alternate). Default: `NULL`.

- ci_colors:

  Color specification for CI boxes. Can be single color, vector, or
  named list with mapping. Default: `NULL`.

- ci_group_ids:

  Optional vector of group IDs for color mapping. Default: `NULL`.

- add_borders:

  Logical. Add simple borders. Default: `TRUE`.

- border_width:

  Numeric. Border line width (mm). Default: 3.

- group_headers:

  List of group header specifications for multi-group plots. Default:
  `NULL`.

- group_border_width:

  Numeric. Border width for group mode (mm). Default: 6.

- custom_borders:

  List of custom border specifications. Default: `NULL`.

- height_top:

  Numeric. Top margin height (mm). Default: 8.

- height_header:

  Numeric. Header row height (mm). Default: 12.

- height_main:

  Numeric. Data row height (mm). Default: 10.

- height_bottom:

  Numeric. Bottom margin height (mm). Default: 8.

- width_left:

  Numeric. Left margin width (mm). Default: 10.

- width_right:

  Numeric. Right margin width (mm). Default: 10.

- width_adjust:

  Numeric. Width adjustment for data columns (mm). Default: 5.

- height_custom:

  Named list for manual height override. Default: `NULL`.

- width_custom:

  Named list for manual width override. Default: `NULL`.

- layout_verbose:

  Logical. Print layout adjustment info. Default: `TRUE`.

- save_plot:

  Logical. Save plot to file(s). Default: `FALSE`.

- filename:

  Character. Base filename (without extension). Default:
  `"forest_plot"`.

- save_path:

  Character. Directory path for saving. Default: `"."`.

- save_formats:

  Character vector. File formats to save. Default: `c("png", "pdf")`.

- save_width:

  Numeric. Plot width. Default: 35.

- save_height:

  Numeric. Plot height. Default: 42.

- save_units:

  Character. Units for width/height. Default: `"cm"`.

- save_dpi:

  Numeric. Resolution for raster formats. Default: 300.

- save_bg:

  Character. Background color. Default: `"white"`.

- save_overwrite:

  Logical. Overwrite existing files. Default: `TRUE`.

- save_verbose:

  Logical. Print save messages. Default: `TRUE`.

## Value

A forest plot object (gtable). Can be displayed with
[`print()`](https://rdrr.io/r/base/print.html) or `grid.draw()`. The
object contains the complete plot structure and can be saved using the
built-in save functionality or standard ggplot2 methods.

## Details

**Core Workflow:**

The function creates a base forest plot using the forestploter package,
then applies a series of customizations:

1.  Theme application (presets or custom)

2.  Text alignment adjustments

3.  Bold formatting for groups and significant p-values

4.  Background colors (zebra, group, or block patterns)

5.  CI box colors (single, vector, or mapped)

6.  Border additions (simple, group, or custom)

7.  Layout adjustments (widths and heights)

8.  Optional file saving

**CI Color Mapping:**

The `ci_colors` parameter accepts three formats:

- **Single color**: Applied to all rows (e.g., `"#E64B35"`)

- **Color vector**: Must match the number of rows

- **Named list with mapping**: Maps group IDs to colors

Example of named mapping:

    ci_colors = list(
      mapping = c("Q1" = "#DC0000", "Q2" = "#8491B4", "Q3" = "#F39B7F"),
      default = "#999999"
    )

## Important Notes

- **Data preparation**: The `data` parameter should contain all display
  columns including pre-formatted text

- **CI graphics**: Use `strrep(" ", n)` to create space columns where CI
  graphics will be drawn

- **Layout tuning**: Use `height_custom` and `width_custom` after
  inspecting verbose output for fine-grained control

## See also

[`forest`](https://rdrr.io/pkg/forestploter/man/forest.html) for the
underlying plotting function,
[`forest_theme`](https://rdrr.io/pkg/forestploter/man/forest_theme.html)
for theme customization.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example 1: Using built-in forest_data
library(dplyr)
library(evanverse)

# Load example data
data("forest_data")

# Filter to single-model data (rows without est_2)
df <- forest_data %>%
  filter(is.na(est_2)) %>%
  filter(!is.na(est))  # Remove header rows

# Prepare display data
plot_data <- df %>%
  mutate(
    ` ` = strrep(" ", 20),
    `OR (95% CI)` = sprintf("%.2f (%.2f-%.2f)", est, lower, upper),
    `P` = ifelse(pval < 0.001, "<0.001", sprintf("%.3f", pval))
  ) %>%
  select(Variable = variable, ` `, `OR (95% CI)`, `P`)

# Create plot
p <- plot_forest(
  data = plot_data,
  est = list(df$est),
  lower = list(df$lower),
  upper = list(df$upper),
  ci_column = 2,
  ref_line = 1
)
print(p)

# Example 2: Multi-model comparison
df_multi <- forest_data %>%
  filter(!is.na(est_2))  # Multi-model rows

plot_data_multi <- df_multi %>%
  mutate(
    ` ` = strrep(" ", 20),
    `Model 1` = sprintf("%.2f (%.2f-%.2f)", est, lower, upper),
    `Model 2` = sprintf("%.2f (%.2f-%.2f)", est_2, lower_2, upper_2),
    `Model 3` = sprintf("%.2f (%.2f-%.2f)", est_3, lower_3, upper_3)
  ) %>%
  select(Variable = variable, ` `, `Model 1`, `Model 2`, `Model 3`)

p <- plot_forest(
  data = plot_data_multi,
  est = list(df_multi$est, df_multi$est_2, df_multi$est_3),
  lower = list(df_multi$lower, df_multi$lower_2, df_multi$lower_3),
  upper = list(df_multi$upper, df_multi$upper_2, df_multi$upper_3),
  ci_column = 2,
  ref_line = 1
)

# Example 3: Customized styling
p <- plot_forest(
  data = plot_data,
  est = list(df$est),
  lower = list(df$lower),
  upper = list(df$upper),
  ci_column = 2,
  xlim = c(0.5, 3),
  arrow_lab = c("Lower Risk", "Higher Risk"),
  align_left = 1,
  align_center = c(2, 3, 4),
  bold_pvalue_cols = 4,
  background_style = "zebra"
)

# Example 4: Save to files
plot_forest(
  data = plot_data,
  est = list(df$est),
  lower = list(df$lower),
  upper = list(df$upper),
  ci_column = 2,
  save_plot = TRUE,
  filename = "forest_plot",
  save_formats = c("png", "pdf")
)
} # }
```
