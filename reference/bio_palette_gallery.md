# bio_palette_gallery(): Visualize All Palettes in a Gallery View

Display palettes from a compiled RDS in a paged gallery format.

## Usage

``` r
bio_palette_gallery(
  palette_rds = NULL,
  type = c("sequential", "diverging", "qualitative"),
  max_palettes = 30,
  max_row = 12,
  verbose = TRUE
)
```

## Arguments

- palette_rds:

  Path to compiled RDS. Default: internal palettes.rds from
  `inst/extdata/`.

- type:

  Palette types to include: "sequential", "diverging", "qualitative"

- max_palettes:

  Number of palettes per page (default: 30)

- max_row:

  Max colors per row (default: 12)

- verbose:

  Whether to print summary/logs (default: TRUE)

## Value

A named list of ggplot objects (one per page)
