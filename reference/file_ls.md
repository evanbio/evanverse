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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-04-09 02:41:18
#> 2                                 downlit   0.004 2026-04-09 02:41:26
#> 3                        file1ccf11fea9ff   0.000 2026-04-09 02:41:24
#> 4                        file1ccf242cf9b3   0.004 2026-04-09 02:41:19
#> 5                        file1ccf37f698d5   0.004 2026-04-09 02:41:19
#> 6                        file1ccf519742d8   0.004 2026-04-09 02:41:18
#> 7                        file1ccf527e6f7d   0.004 2026-04-09 02:41:19
#> 8                        file1ccf5b8f013a   0.004 2026-04-09 02:41:18
#> 9                        file1ccf66268a4a   0.000 2026-04-09 02:41:21
#> 10                   file1ccf665a29ef.txt   0.000 2026-04-09 02:41:27
#> 11                       file1ccf686bed96   0.000 2026-04-09 02:41:25
#> 12                   file1ccf7138a41f.csv   0.000 2026-04-09 02:41:27
#> 13                       file1ccf7a5c58c4   0.000 2026-04-09 02:41:21
#> 14                        file1ccff41a5b5   0.004 2026-04-09 02:41:18
#>                                                      path
#> 1  /tmp/RtmpqMRrJC/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpqMRrJC/downlit
#> 3                        /tmp/RtmpqMRrJC/file1ccf11fea9ff
#> 4                        /tmp/RtmpqMRrJC/file1ccf242cf9b3
#> 5                        /tmp/RtmpqMRrJC/file1ccf37f698d5
#> 6                        /tmp/RtmpqMRrJC/file1ccf519742d8
#> 7                        /tmp/RtmpqMRrJC/file1ccf527e6f7d
#> 8                        /tmp/RtmpqMRrJC/file1ccf5b8f013a
#> 9                        /tmp/RtmpqMRrJC/file1ccf66268a4a
#> 10                   /tmp/RtmpqMRrJC/file1ccf665a29ef.txt
#> 11                       /tmp/RtmpqMRrJC/file1ccf686bed96
#> 12                   /tmp/RtmpqMRrJC/file1ccf7138a41f.csv
#> 13                       /tmp/RtmpqMRrJC/file1ccf7a5c58c4
#> 14                        /tmp/RtmpqMRrJC/file1ccff41a5b5
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
