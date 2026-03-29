# List files in a directory with metadata

Returns a data.frame with file metadata for all files in a directory.

## Usage

``` r
file_ls(dir, recursive = FALSE, pattern = NULL)
```

## Arguments

- dir:

  Character. Directory path.

- recursive:

  Logical. Whether to search recursively. Default: FALSE.

- pattern:

  Optional regex to filter file names (e.g., `"\.R$"`). Default: NULL.

## Value

A data.frame with columns: `file`, `size_MB`, `modified_time`, `path`.

## Examples

``` r
file_ls(tempdir())
#>                                      file size_MB       modified_time
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-29 11:22:32
#> 2                                 downlit   0.004 2026-03-29 11:22:42
#> 3                        file1be21027f681   0.004 2026-03-29 11:22:33
#> 4                        file1be221955299   0.004 2026-03-29 11:22:33
#> 5                        file1be222408edc   0.004 2026-03-29 11:22:34
#> 6                    file1be23d5d4a54.csv   0.000 2026-03-29 11:22:42
#> 7                        file1be23ea91385   0.004 2026-03-29 11:22:34
#> 8                        file1be2457f3d7b   0.001 2026-03-29 11:22:36
#> 9                    file1be246411fcc.txt   0.000 2026-03-29 11:22:42
#> 10                        file1be24b9ed68   0.000 2026-03-29 11:22:36
#> 11                        file1be2529ce04   0.004 2026-03-29 11:22:33
#> 12                       file1be2563b0ac3   0.000 2026-03-29 11:22:41
#> 13                       file1be25f79da27   0.004 2026-03-29 11:22:34
#> 14                        file1be26d629f6   0.000 2026-03-29 11:22:35
#> 15                       file1be26fb1b195   0.001 2026-03-29 11:22:35
#> 16                       file1be27428d41c   0.000 2026-03-29 11:22:40
#>                                                      path
#> 1  /tmp/RtmpsD08Ck/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpsD08Ck/downlit
#> 3                        /tmp/RtmpsD08Ck/file1be21027f681
#> 4                        /tmp/RtmpsD08Ck/file1be221955299
#> 5                        /tmp/RtmpsD08Ck/file1be222408edc
#> 6                    /tmp/RtmpsD08Ck/file1be23d5d4a54.csv
#> 7                        /tmp/RtmpsD08Ck/file1be23ea91385
#> 8                        /tmp/RtmpsD08Ck/file1be2457f3d7b
#> 9                    /tmp/RtmpsD08Ck/file1be246411fcc.txt
#> 10                        /tmp/RtmpsD08Ck/file1be24b9ed68
#> 11                        /tmp/RtmpsD08Ck/file1be2529ce04
#> 12                       /tmp/RtmpsD08Ck/file1be2563b0ac3
#> 13                       /tmp/RtmpsD08Ck/file1be25f79da27
#> 14                        /tmp/RtmpsD08Ck/file1be26d629f6
#> 15                       /tmp/RtmpsD08Ck/file1be26fb1b195
#> 16                       /tmp/RtmpsD08Ck/file1be27428d41c
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
