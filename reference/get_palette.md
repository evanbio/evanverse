# Get a Color Palette

Retrieve a named palette by name and type, returning a vector of HEX
colors. Automatically checks for type mismatch and provides smart
suggestions.

## Usage

``` r
get_palette(name, type = NULL, n = NULL, palettes_path = NULL)
```

## Arguments

- name:

  Character. Name of the palette (e.g. "qual_vivid").

- type:

  Character. One of "sequential", "diverging", "qualitative". If NULL,
  type is auto-detected.

- n:

  Integer. Number of colors to return. If NULL, returns all colors.
  Default is NULL.

- palettes_path:

  Character. Path to a `palettes.rda` file. If NULL, uses the installed
  package dataset.

## Value

Character vector of HEX color codes.

## Examples

``` r
get_palette("qual_vivid", type = "qualitative")
#> [1] "#E64B35" "#4DBBD5" "#00A087" "#3C5488" "#F39B7F" "#8491B4" "#91D1C2"
#> [8] "#DC0000" "#7E6148"
get_palette("qual_softtrio", type = "qualitative", n = 2)
#> [1] "#E64B35B2" "#00A087B2"
get_palette("seq_blues", type = "sequential", n = 3)
#> [1] "#deebf7" "#9ecae1" "#3182bd"
get_palette("div_contrast", type = "diverging")
#> [1] "#C64328" "#56BBA5"
```
