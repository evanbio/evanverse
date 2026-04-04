# Visualize All Palettes in a Gallery View

Display palettes in a paged gallery format, returning a named list of
ggplot objects.

## Usage

``` r
palette_gallery(
  type = NULL,
  max_palettes = 30,
  max_row = 12,
  verbose = TRUE,
  palettes_path = NULL
)
```

## Arguments

- type:

  Palette types to include: "sequential", "diverging", "qualitative".
  Default NULL returns all.

- max_palettes:

  Number of palettes per page. Default: 30.

- max_row:

  Max colors per row. Default: 12.

- verbose:

  Whether to print progress info. Default: TRUE.

- palettes_path:

  Character. Path to a `palettes.rda` file. If NULL, uses the installed
  package dataset.

## Value

A named list of ggplot objects (one per page).

## Examples

``` r
# \donttest{
palette_gallery()
#> ℹ Type sequential: 11 palettes -> 1 page(s)
#> ✔ Built "sequential_page1"
#> ℹ Type diverging: 7 palettes -> 1 page(s)
#> ✔ Built "diverging_page1"
#> ℹ Type qualitative: 75 palettes -> 3 page(s)
#> ✔ Built "qualitative_page1"
#> ✔ Built "qualitative_page2"
#> ✔ Built "qualitative_page3"
#> $sequential_page1

#> 
#> $diverging_page1

#> 
#> $qualitative_page1

#> 
#> $qualitative_page2

#> 
#> $qualitative_page3

#> 
palette_gallery(type = "qualitative")
#> ℹ Type qualitative: 75 palettes -> 3 page(s)
#> ✔ Built "qualitative_page1"
#> ✔ Built "qualitative_page2"
#> ✔ Built "qualitative_page3"
#> $qualitative_page1

#> 
#> $qualitative_page2

#> 
#> $qualitative_page3

#> 
palette_gallery(type = c("sequential", "diverging"), max_palettes = 10)
#> ℹ Type sequential: 11 palettes -> 2 page(s)
#> ✔ Built "sequential_page1"
#> ✔ Built "sequential_page2"
#> ℹ Type diverging: 7 palettes -> 1 page(s)
#> ✔ Built "diverging_page1"
#> $sequential_page1

#> 
#> $sequential_page2

#> 
#> $diverging_page1

#> 
# }
```
