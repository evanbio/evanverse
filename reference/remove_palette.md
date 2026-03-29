# Remove a Saved Palette JSON

Remove a palette JSON file by name, searching across types if needed.

## Usage

``` r
remove_palette(name, type = NULL, color_dir)
```

## Arguments

- name:

  Character. Palette name (without '.json' suffix).

- type:

  Character. One of "sequential", "diverging", "qualitative". If NULL,
  searches all types.

- color_dir:

  Character. Root folder where palettes are stored.

## Value

Invisibly TRUE if removed successfully, FALSE otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
remove_palette("seq_blues", color_dir = "path/to/palettes")
remove_palette("qual_vivid", type = "qualitative", color_dir = "path/to/palettes")
} # }
```
