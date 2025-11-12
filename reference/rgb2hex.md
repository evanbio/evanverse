# Convert RGB values to HEX color codes

Convert an RGB triplet (or a list of triplets) to HEX color codes.

## Usage

``` r
rgb2hex(rgb)
```

## Arguments

- rgb:

  A numeric vector of length 3 (e.g., `c(255, 128, 0)`), or a list of
  such vectors (e.g., `list(c(255,128,0), c(0,255,0))`).

## Value

A HEX color string if a single RGB vector is provided, or a character
vector of HEX codes if a list is provided.

## Examples

``` r
rgb2hex(c(255, 128, 0))                           # "#FF8000"
#> ✔ RGB: c(255, 128, 0) -> HEX: #FF8000
#> [1] "#FF8000"
rgb2hex(list(c(255,128,0), c(0,255,0)))           # c("#FF8000", "#00FF00")
#> ✔ Converted 2 RGB values to HEX.
#> ℹ RGB: c(255, 128, 0) -> HEX: #FF8000
#> ℹ RGB: c(0, 255, 0) -> HEX: #00FF00
#> [1] "#FF8000" "#00FF00"
```
