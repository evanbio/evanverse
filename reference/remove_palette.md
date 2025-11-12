# Remove a Saved Palette JSON

Remove a palette file by name, trying across types if necessary.

## Usage

``` r
remove_palette(name, type = NULL, color_dir, log = TRUE)
```

## Arguments

- name:

  Character. Palette name (without '.json' suffix).

- type:

  Character. Optional. Preferred type ("sequential", "diverging", or
  "qualitative").

- color_dir:

  Character. Root folder where palettes are stored (required). Use
  tempdir() for examples/tests.

- log:

  Logical. Whether to log palette removal to a temporary log file.

## Value

Invisibly TRUE if removed successfully, FALSE otherwise.

## Examples

``` r
if (FALSE) { # \dontrun{
# Remove a palette (requires write permissions):
remove_palette("seq_blues")

# Remove with specific type:
remove_palette("qual_vivid", type = "qualitative")
} # }
```
