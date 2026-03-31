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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-31 07:22:04
#> 2                                 downlit   0.004 2026-03-31 07:22:12
#> 3                        file1c4b25680ffa   0.004 2026-03-31 07:22:05
#> 4                    file1c4b2889a0f1.txt   0.000 2026-03-31 07:22:12
#> 5                    file1c4b2c14a344.csv   0.000 2026-03-31 07:22:12
#> 6                        file1c4b2cf8f94d   0.004 2026-03-31 07:22:04
#> 7                        file1c4b3ac15ac6   0.004 2026-03-31 07:22:05
#> 8                        file1c4b44168d00   0.004 2026-03-31 07:22:04
#> 9                        file1c4b45b61526   0.004 2026-03-31 07:22:05
#> 10                       file1c4b5d7f844e   0.004 2026-03-31 07:22:04
#> 11                       file1c4b5fae0302   0.000 2026-03-31 07:22:10
#> 12                       file1c4b72b3b26a   0.000 2026-03-31 07:22:06
#> 13                       file1c4b7ffae598   0.000 2026-03-31 07:22:11
#>                                                      path
#> 1  /tmp/RtmpzzPmUM/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpzzPmUM/downlit
#> 3                        /tmp/RtmpzzPmUM/file1c4b25680ffa
#> 4                    /tmp/RtmpzzPmUM/file1c4b2889a0f1.txt
#> 5                    /tmp/RtmpzzPmUM/file1c4b2c14a344.csv
#> 6                        /tmp/RtmpzzPmUM/file1c4b2cf8f94d
#> 7                        /tmp/RtmpzzPmUM/file1c4b3ac15ac6
#> 8                        /tmp/RtmpzzPmUM/file1c4b44168d00
#> 9                        /tmp/RtmpzzPmUM/file1c4b45b61526
#> 10                       /tmp/RtmpzzPmUM/file1c4b5d7f844e
#> 11                       /tmp/RtmpzzPmUM/file1c4b5fae0302
#> 12                       /tmp/RtmpzzPmUM/file1c4b72b3b26a
#> 13                       /tmp/RtmpzzPmUM/file1c4b7ffae598
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
