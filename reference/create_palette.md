# create_palette(): Save Custom Color Palettes as JSON

Save a named color palette (sequential, diverging, or qualitative) to a
JSON file. Used for palette sharing, reuse, and future compilation.

## Usage

``` r
create_palette(
  name,
  type = c("sequential", "diverging", "qualitative"),
  colors,
  color_dir,
  log = TRUE
)
```

## Arguments

- name:

  Character. Palette name (e.g., "Blues").

- type:

  Character. One of "sequential", "diverging", or "qualitative".

- colors:

  Character vector of HEX color values (e.g., "#E64B35" or "#E64B35B2").

- color_dir:

  Character. Root folder to store palettes (required). Use tempdir() for
  examples/tests.

- log:

  Logical. Whether to log palette creation to a temporary log file.

## Value

(Invisibly) A list with `path` and `info`.

## Examples

``` r
# Create palette in temporary directory:
temp_dir <- file.path(tempdir(), "palettes")
create_palette(
  "blues",
  "sequential",
  c("#deebf7", "#9ecae1", "#3182bd"),
  color_dir = temp_dir
)
#> ℹ Directory created: /tmp/Rtmp259fZZ/palettes/sequential
#> ✔ Palette saved: /tmp/Rtmp259fZZ/palettes/sequential/blues.json

create_palette(
  "qual_vivid",
  "qualitative",
  c("#E64B35", "#4DBBD5", "#00A087"),
  color_dir = temp_dir
)
#> ℹ Directory created: /tmp/Rtmp259fZZ/palettes/qualitative
#> ✔ Palette saved: /tmp/Rtmp259fZZ/palettes/qualitative/qual_vivid.json

# Clean up
unlink(temp_dir, recursive = TRUE)
```
