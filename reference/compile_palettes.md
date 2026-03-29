# Compile JSON Palettes into a Palette List

Read JSON files under `palettes_dir/`, validate content, and return a
structured list of palettes. Used by `data-raw/palettes.R` to build the
package dataset via
[`usethis::use_data()`](https://usethis.r-lib.org/reference/use_data.html).

## Usage

``` r
compile_palettes(palettes_dir)
```

## Arguments

- palettes_dir:

  Character. Folder containing subdirs: sequential/, diverging/,
  qualitative/.

## Value

Invisibly returns a named list with elements `sequential`, `diverging`,
`qualitative`.

## Examples

``` r
# \donttest{
compile_palettes(
  palettes_dir = system.file("extdata", "palettes", package = "evanverse")
)
#> ✔ Compiled 93 palettes: Sequential=11, Diverging=7, Qualitative=75
# }
```
