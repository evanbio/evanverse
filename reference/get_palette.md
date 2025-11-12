# Get Palette: Load Color Palette from RDS

Load a named palette from data/palettes.rds, returning a vector of HEX
colors. Automatically checks for type mismatch and provides smart
suggestions.

## Usage

``` r
get_palette(
  name,
  type = c("sequential", "diverging", "qualitative"),
  n = NULL,
  palette_rds = system.file("extdata", "palettes.rds", package = "evanverse")
)
```

## Arguments

- name:

  Character. Name of the palette (e.g. "qual_vivid").

- type:

  Character. One of "sequential", "diverging", "qualitative".

- n:

  Integer. Number of colors to return. If NULL, returns all colors.
  Default is NULL.

- palette_rds:

  Character. Path to RDS file. Default uses system file in package.

## Value

Character vector of HEX color codes.

## Examples

``` r
get_palette("qual_vivid", type = "qualitative")
#> ✔ Loaded palette "qual_vivid" ("qualitative"), 9 colors
#> [1] "#E64B35" "#4DBBD5" "#00A087" "#3C5488" "#F39B7F" "#8491B4" "#91D1C2"
#> [8] "#DC0000" "#7E6148"
get_palette("qual_softtrio", type = "qualitative", n = 2)
#> ✔ Loaded palette "qual_softtrio" ("qualitative"), 3 colors
#> [1] "#E64B35B2" "#00A087B2"
get_palette("seq_blues", type = "sequential", n = 3)
#> ✔ Loaded palette "seq_blues" ("sequential"), 3 colors
#> [1] "#deebf7" "#9ecae1" "#3182bd"
get_palette("div_contrast", type = "diverging")
#> ✔ Loaded palette "div_contrast" ("diverging"), 2 colors
#> [1] "#C64328" "#56BBA5"
```
