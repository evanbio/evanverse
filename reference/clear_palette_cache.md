# Clear Palette Cache

Clear the internal palette cache and force reload on next access. This
is useful if you've updated the palette RDS file and want to reload the
data.

## Usage

``` r
clear_palette_cache()
```

## Value

Invisible NULL

## Examples

``` r
if (FALSE) { # \dontrun{
# Clear cache (rarely needed)
clear_palette_cache()

# Cache will be automatically reloaded on next get_palette() call
get_palette("qual_vivid", type = "qualitative")
} # }
```
