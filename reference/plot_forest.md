# Draw a forest plot using forestploter with publication-quality styling

Draw a forest plot using forestploter with publication-quality styling

## Usage

``` r
plot_forest(
  data,
  estimate_col = "estimate",
  lower_col = "conf.low",
  upper_col = "conf.high",
  label_col = "variable",
  p_col = "p.value",
  ref_line = 1,
  sig_level = 0.05,
  bold_sig = TRUE,
  arrow_lab = c("Unfavorable", "Favorable"),
  ticks_at = c(0.5, 1, 1.5, 2),
  xlim = c(0, 3),
  footnote = "P-value < 0.05 was considered statistically significant",
  boxcolor = c("#E64B35", "#4DBBD5", "#00A087", "#3C5488", "#F39B7F", "#8491B4",
    "#91D1C2", "#DC0000", "#7E6148"),
  align_left = 1,
  align_right = NULL,
  align_center = NULL,
  gap_width = 30
)
```

## Arguments

- data:

  Data frame with required columns: estimate, lower, upper, label, and
  p-value.

- estimate_col:

  Name of column containing point estimates.

- lower_col:

  Name of column containing lower CI.

- upper_col:

  Name of column containing upper CI.

- label_col:

  Name of column for variable labels.

- p_col:

  Name of column for p-values.

- ref_line:

  Reference line value, typically 1 for OR/HR.

- sig_level:

  Threshold to bold significant rows (default 0.05).

- bold_sig:

  Whether to bold significant rows.

- arrow_lab:

  Labels at both ends of the forest axis.

- ticks_at:

  Vector of x-axis tick marks.

- xlim:

  Range of x-axis (e.g., c(0, 3)). If NULL, auto-calculated. Default:
  c(0, 3).

- footnote:

  Caption text below the plot.

- boxcolor:

  Fill colors for CI boxes, will repeat if too short.

- align_left:

  Integer column indices to left-align.

- align_right:

  Integer column indices to right-align.

- align_center:

  Integer column indices to center-align.

- gap_width:

  Number of spaces in the gap column (default = 30).

## Value

A forestplot object
