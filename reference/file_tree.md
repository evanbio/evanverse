# file_tree: Print and Log Directory Tree Structure

Print the directory structure of a given path in a tree-like format
using ASCII characters for maximum compatibility across different
systems. Optionally, save the result to a log file for record keeping or
debugging.

## Usage

``` r
file_tree(
  path = ".",
  max_depth = 2,
  verbose = TRUE,
  log = FALSE,
  log_path = NULL,
  file_name = NULL,
  append = FALSE
)
```

## Arguments

- path:

  Character. The target root directory path to print. Default is ".".

- max_depth:

  Integer. Maximum depth of recursion into subdirectories. Default is 2.

- verbose:

  Logical. Whether to print the tree to console. Default is TRUE.

- log:

  Logical. Whether to save the tree output as a log file. Default is
  FALSE.

- log_path:

  Character. Directory path to save the log file if log = TRUE. Default
  is tempdir().

- file_name:

  Character. Custom file name for the log file. If NULL, a name like
  "file_tree_YYYYMMDD_HHMMSS.log" will be used.

- append:

  Logical. If TRUE, appends to an existing file (if present). If FALSE,
  overwrites the file. Default is FALSE.

## Value

Invisibly returns a character vector containing each line of the file
tree.

## Examples

``` r
# Basic usage with current directory:
file_tree()
#> 
#> ── Directory Tree: /home/runner/work/evanverse/evanverse/docs/reference ────────
#> +-- bio_palette_gallery.html
#> +-- check_pkg.html
#> +-- clear_palette_cache.html
#> +-- comb.html
#> +-- combine_logic.html
#> +-- compile_palettes.html
#> +-- convert_gene_id.html
#> +-- create_palette.html
#> +-- df2list.html
#> +-- df_forest_test.html
#> +-- download_batch.html
#> +-- download_gene_ref.html
#> +-- download_geo_data.html
#> +-- download_url.html
#> +-- figures
#> |   +-- logo-input.png
#> |   +-- logo.png
#> +-- file_info.html
#> +-- index.html
file_tree(".", max_depth = 3)
#> 
#> ── Directory Tree: /home/runner/work/evanverse/evanverse/docs/reference ────────
#> +-- bio_palette_gallery.html
#> +-- check_pkg.html
#> +-- clear_palette_cache.html
#> +-- comb.html
#> +-- combine_logic.html
#> +-- compile_palettes.html
#> +-- convert_gene_id.html
#> +-- create_palette.html
#> +-- df2list.html
#> +-- df_forest_test.html
#> +-- download_batch.html
#> +-- download_gene_ref.html
#> +-- download_geo_data.html
#> +-- download_url.html
#> +-- figures
#> |   +-- logo-input.png
#> |   +-- logo.png
#> +-- file_info.html
#> +-- index.html

# \donttest{
# Example with temporary directory and logging:
temp_dir <- tempdir()
file_tree(temp_dir, max_depth = 2, log = TRUE, log_path = tempdir())
#> 
#> ── Directory Tree: /tmp/Rtmp9jgg6U ─────────────────────────────────────────────
#> +-- bslib-4e96cd1a4fdf985a397403cff03664c0
#> |   +-- bootstrap.bundle.min.js
#> |   +-- bootstrap.bundle.min.js.map
#> |   +-- bootstrap.min.css
#> +-- downlit
#> |   +-- Biobase
#> |   +-- base
#> |   +-- cli
#> |   +-- curl
#> |   +-- devtools
#> |   +-- pkgdown
#> |   +-- remotes
#> |   +-- stats
#> |   +-- utils
#> +-- file18d318b97b4b
#> +-- file18d31e5fc1af
#> +-- file18d32806214d
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZ9hiA.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZBhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZFhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZJhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZNhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZthiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZxhiI2B.woff2
#> |   +-- font.css
#> +-- file18d3486c860f
#> +-- file18d351a1be7d
#> |   +-- font.css
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTN1OVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTNFOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTNVOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTOVOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTOlOV.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTPlOVgaY.woff2
#> +-- file18d3565a772b
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZ9hiA.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZBhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZFhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZJhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZNhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZthiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZxhiI2B.woff2
#> |   +-- font.css
#> +-- file18d35a7c7788
#> +-- file18d35b308303
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZ9hiA.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZBhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZFhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZJhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZNhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZthiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZxhiI2B.woff2
#> |   +-- font.css
#> +-- file18d36a8cae2b
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZ9hiA.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZBhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZFhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZJhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZNhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZthiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZxhiI2B.woff2
#> |   +-- font.css
#> +-- file18d37cad2478
#> +-- file18d38d1c3bf
#> |   +-- font.css
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTN1OVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTNFOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTNVOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTOVOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTOlOV.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTPlOVgaY.woff2
#> +-- logs
#> |   +-- palettes
#> +-- palettes.rds
#> +-- robots.txt
#> ✔ File tree log saved to: /tmp/Rtmp9jgg6U/file_tree_20251117_134412.log
# }
```
