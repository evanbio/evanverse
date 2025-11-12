# Convert HEX color(s) to RGB numeric components

Convert a single HEX color string or a character vector of HEX strings
to RGB numeric components. The function accepts values with or without a
leading `#`. Messaging uses `cli` if available and falls back to
[`message()`](https://rdrr.io/r/base/message.html).

## Usage

``` r
hex2rgb(hex)
```

## Arguments

- hex:

  Character. A HEX color string (e.g. `"#FF8000"`) or a character vector
  of HEX codes. No NA values allowed.

## Value

If `hex` has length 1, a named numeric vector with elements
`c(r, g, b)`. If `hex` has length \> 1, a named list where each element
is a named numeric vector for the corresponding input.

## Examples

``` r
hex2rgb("#FF8000")
#> ✔ #FF8000 -> RGB: c(255, 128, 0)
#>   r   g   b 
#> 255 128   0 
hex2rgb(c("#FF8000", "#00FF00"))
#> ✔ Converted 2 HEX values to RGB.
#> ℹ #FF8000 -> RGB: c(255, 128, 0)
#> ℹ #00FF00 -> RGB: c(0, 255, 0)
#> $`#FF8000`
#>   r   g   b 
#> 255 128   0 
#> 
#> $`#00FF00`
#>   r   g   b 
#>   0 255   0 
#> 
```
