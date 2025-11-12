# Reload Palette Cache

Force reload of palette data from disk. This is useful if you've updated
the palette RDS file and want to refresh the cached data without
restarting R.

## Usage

``` r
reload_palette_cache()
```

## Value

Invisible NULL

## Examples

``` r
if (FALSE) { # \dontrun{
# After updating palettes.rds, reload the cache
reload_palette_cache()
} # }
```
