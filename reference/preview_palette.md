# Preview Palette: Visualize a Palette from RDS

Preview the appearance of a palette from `data/palettes.rds` using
various plot types. This function provides multiple visualization
options to help users evaluate color palettes.

## Usage

``` r
preview_palette(
  name,
  type = c("sequential", "diverging", "qualitative"),
  n = NULL,
  plot_type = c("bar", "pie", "point", "rect", "circle"),
  title = name,
  palette_rds = system.file("extdata", "palettes.rds", package = "evanverse"),
  preview = TRUE
)
```

## Arguments

- name:

  Name of the palette.

- type:

  Palette type: "sequential", "diverging", "qualitative".

- n:

  Number of colors to use (default: all).

- plot_type:

  Plot style: "bar", "pie", "point", "rect", "circle".

- title:

  Plot title (default: same as palette name).

- palette_rds:

  Path to RDS file. Default: system.file("extdata", "palettes.rds",
  package = "evanverse").

- preview:

  Whether to show the plot immediately. Default: TRUE.

## Value

NULL (invisible), for plotting side effect.

## Examples

``` r
# \donttest{
# Preview sequential palette:
preview_palette("seq_blues", type = "sequential", plot_type = "bar")
#> ✔ Loaded palette "seq_blues" ("sequential"), 3 colors
#> 
#> ── Previewing palette: "seq_blues" ──
#> 
#> ℹ Plot type: "bar", colors: 3


# Preview diverging palette:
preview_palette("div_fireice", type = "diverging", plot_type = "pie")
#> ✔ Loaded palette "div_fireice" ("diverging"), 2 colors
#> 
#> ── Previewing palette: "div_fireice" ──
#> 
#> ℹ Plot type: "pie", colors: 2


# Preview qualitative palette with custom colors:
preview_palette("qual_vivid", type = "qualitative", n = 4, plot_type = "circle")
#> ✔ Loaded palette "qual_vivid" ("qualitative"), 9 colors
#> 
#> ── Previewing palette: "qual_vivid" ──
#> 
#> ℹ Plot type: "circle", colors: 4

# }
```
