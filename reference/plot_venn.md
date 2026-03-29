# Venn diagram for 2-4 sets

Draws a Venn diagram using either `ggvenn` (classic) or `ggVennDiagram`
(gradient). Both packages must be installed (they are in `Suggests`).

## Usage

``` r
plot_venn(
  set1,
  set2,
  set3 = NULL,
  set4 = NULL,
  set_names = NULL,
  method = c("classic", "gradient"),
  label = c("count", "percent", "both", "none"),
  palette = NULL,
  return_sets = FALSE
)
```

## Arguments

- set1, set2:

  Required input vectors (at least two sets).

- set3, set4:

  Optional additional sets. Default: `NULL`.

- set_names:

  Character vector of set labels. If `NULL`, uses the variable names of
  the inputs. Default: `NULL`.

- method:

  Drawing method: `"classic"` (ggvenn) or `"gradient"` (ggVennDiagram).
  Default: `"classic"`.

- label:

  Label type: `"count"`, `"percent"`, `"both"`, or `"none"`. Default:
  `"count"`.

- palette:

  For `"classic"`: character vector of fill colors, recycled to match
  the number of sets. For `"gradient"`: a single `RColorBrewer` palette
  name passed to `scale_fill_distiller()`. If `NULL`, defaults are used.
  Default: `NULL`.

- return_sets:

  Logical. If `TRUE`, returns `list(plot, sets)` instead of just the
  plot. Default: `FALSE`.

## Value

A `ggplot` object, or a named list with elements `plot` and `sets` if
`return_sets = TRUE`.

## Examples

``` r
if (requireNamespace("ggvenn", quietly = TRUE)) {
  set.seed(42)
  plot_venn(sample(letters, 15), sample(letters, 12), sample(letters, 10))
}
```
