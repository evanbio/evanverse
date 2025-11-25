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
#> ── Directory Tree: /tmp/RtmpjLapgI ─────────────────────────────────────────────
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
#> +-- file19b8109e0a99
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZ9hiA.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZBhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZFhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZJhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZNhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZthiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZxhiI2B.woff2
#> |   +-- font.css
#> +-- file19b815f4429c
#> +-- file19b825ba5cf5
#> +-- file19b8384326cb
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZ9hiA.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZBhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZFhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZJhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZNhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZthiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZxhiI2B.woff2
#> |   +-- font.css
#> +-- file19b8398e8a32
#> +-- file19b84acfa0f7
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZ9hiA.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZBhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZFhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZJhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZNhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZthiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZxhiI2B.woff2
#> |   +-- font.css
#> +-- file19b84eb88b02
#> +-- file19b84edf1c07
#> |   +-- font.css
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTN1OVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTNFOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTNVOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTOVOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTOlOV.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTPlOVgaY.woff2
#> +-- file19b868683e7d
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZ9hiA.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZBhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZFhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZJhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZNhiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZthiI2B.woff2
#> |   +-- UcCO3FwrK3iLTeHuS_nVMrMxCp50SjIw2boKoduKmMEVuLyfAZxhiI2B.woff2
#> |   +-- font.css
#> +-- file19b869dc0484
#> |   +-- font.css
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTN1OVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTNFOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTNVOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTOVOVgaY.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTOlOV.woff2
#> |   +-- tDbY2o-flEEny0FZhsfKu5WU4zr3E_BX0PnT8RD8yKxTPlOVgaY.woff2
#> +-- file19b879db2c4
#> +-- logs
#> |   +-- palettes
#> +-- palettes.rds
#> +-- robots.txt
#> ✔ File tree log saved to: /tmp/RtmpjLapgI/file_tree_20251125_060726.log
# }
```
