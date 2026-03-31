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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-31 06:36:51
#> 2                                 downlit   0.004 2026-03-31 06:37:01
#> 3                        file1c33207b50f7   0.000 2026-03-31 06:37:00
#> 4                        file1c33233fd64a   0.004 2026-03-31 06:36:52
#> 5                        file1c33237a743e   0.000 2026-03-31 06:36:59
#> 6                    file1c332dc421ca.csv   0.000 2026-03-31 06:37:01
#> 7                        file1c33359e8dc7   0.004 2026-03-31 06:36:52
#> 8                        file1c333783204c   0.004 2026-03-31 06:36:54
#> 9                        file1c3343b6144c   0.004 2026-03-31 06:36:52
#> 10                    file1c33548f10a.txt   0.000 2026-03-31 06:37:01
#> 11                       file1c33770dd948   0.004 2026-03-31 06:36:54
#> 12                        file1c3380fe114   0.004 2026-03-31 06:36:54
#> 13                        file1c33a2b3dfa   0.000 2026-03-31 06:36:55
#>                                                      path
#> 1  /tmp/RtmpMuo6sr/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpMuo6sr/downlit
#> 3                        /tmp/RtmpMuo6sr/file1c33207b50f7
#> 4                        /tmp/RtmpMuo6sr/file1c33233fd64a
#> 5                        /tmp/RtmpMuo6sr/file1c33237a743e
#> 6                    /tmp/RtmpMuo6sr/file1c332dc421ca.csv
#> 7                        /tmp/RtmpMuo6sr/file1c33359e8dc7
#> 8                        /tmp/RtmpMuo6sr/file1c333783204c
#> 9                        /tmp/RtmpMuo6sr/file1c3343b6144c
#> 10                    /tmp/RtmpMuo6sr/file1c33548f10a.txt
#> 11                       /tmp/RtmpMuo6sr/file1c33770dd948
#> 12                        /tmp/RtmpMuo6sr/file1c3380fe114
#> 13                        /tmp/RtmpMuo6sr/file1c33a2b3dfa
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
