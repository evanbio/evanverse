# Convert RGB Values to HEX Color Codes

Convert RGB values to HEX color codes. Accepts either a numeric vector
of length 3 or a data.frame with columns `r`, `g`, `b` (symmetric with
[`hex2rgb()`](https://evanbio.github.io/evanverse/reference/hex2rgb.md)).

## Usage

``` r
rgb2hex(rgb)
```

## Arguments

- rgb:

  A numeric vector of length 3 (e.g., `c(255, 128, 0)`), or a data.frame
  with columns `r`, `g`, `b`. Values must be in \[0, 255\]. Non-integer
  values are rounded to the nearest integer before conversion.

## Value

A character vector of HEX color codes.

## Examples

``` r
rgb2hex(c(255, 128, 0))
#> [1] "#FF8000"
rgb2hex(hex2rgb(c("#FF8000", "#00FF00")))
#> [1] "#FF8000" "#00FF00"
```
