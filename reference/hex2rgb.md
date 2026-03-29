# Convert HEX Colors to RGB

Convert a character vector of HEX color codes to a data.frame with
columns `hex`, `r`, `g`, `b`.

## Usage

``` r
hex2rgb(hex)
```

## Arguments

- hex:

  Character vector of HEX color codes (e.g. `"#FF8000"` or
  `"#FF8000B2"`). Both 6-digit and 8-digit (with alpha) codes are
  accepted. Alpha is silently ignored. The `#` prefix is required. No NA
  values allowed.

## Value

A data.frame with columns `hex`, `r`, `g`, `b`.

## Examples

``` r
hex2rgb("#FF8000")
#>       hex   r   g b
#> 1 #FF8000 255 128 0
hex2rgb(c("#FF8000", "#00FF00"))
#>       hex   r   g b
#> 1 #FF8000 255 128 0
#> 2 #00FF00   0 255 0
```
