# Print directory tree structure

Prints the directory structure of a given dir in a tree-like format.
Invisibly returns the lines so the result can be captured if needed.

## Usage

``` r
file_tree(dir = ".", max_depth = 2)
```

## Arguments

- dir:

  Character. Root directory path. Default: `"."`.

- max_depth:

  Integer. Maximum recursion depth. Default: 2.

## Value

Invisibly returns a character vector of tree lines.

## Examples

``` r
file_tree()
#> /home/runner/work/evanverse/evanverse/docs/reference
#> +-- comb.html
#> +-- df2list.html
#> +-- df2vect.html
#> +-- download_batch.html
#> +-- download_gene_ref.html
#> +-- download_geo.html
#> +-- download_url.html
#> +-- figures
#> |   +-- logo.png
#> +-- file_info.html
#> +-- file_ls.html
#> +-- index.html
file_tree(".", max_depth = 3)
#> /home/runner/work/evanverse/evanverse/docs/reference
#> +-- comb.html
#> +-- df2list.html
#> +-- df2vect.html
#> +-- download_batch.html
#> +-- download_gene_ref.html
#> +-- download_geo.html
#> +-- download_url.html
#> +-- figures
#> |   +-- logo.png
#> +-- file_info.html
#> +-- file_ls.html
#> +-- index.html
```
