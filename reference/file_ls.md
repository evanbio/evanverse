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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-04-10 14:02:14
#> 2                                 downlit   0.004 2026-04-10 14:02:21
#> 3                        file1afb10883b67   0.004 2026-04-10 14:02:16
#> 4                        file1afb24083157   0.004 2026-04-10 14:02:16
#> 5                        file1afb2e98cbf4   0.004 2026-04-10 14:02:14
#> 6                        file1afb35e11622   0.000 2026-04-10 14:02:20
#> 7                        file1afb44dce5ff   0.004 2026-04-10 14:02:16
#> 8                        file1afb452b43b9   0.000 2026-04-10 14:02:17
#> 9                        file1afb4b89f7fe   0.000 2026-04-10 14:02:17
#> 10                       file1afb4caa8df2   0.004 2026-04-10 14:02:14
#> 11                       file1afb4cc6fe3d   0.004 2026-04-10 14:02:14
#> 12                   file1afb772f8ee8.txt   0.000 2026-04-10 14:02:22
#> 13                   file1afb7d0328c4.csv   0.000 2026-04-10 14:02:22
#>                                                      path
#> 1  /tmp/Rtmppg5iuq/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/Rtmppg5iuq/downlit
#> 3                        /tmp/Rtmppg5iuq/file1afb10883b67
#> 4                        /tmp/Rtmppg5iuq/file1afb24083157
#> 5                        /tmp/Rtmppg5iuq/file1afb2e98cbf4
#> 6                        /tmp/Rtmppg5iuq/file1afb35e11622
#> 7                        /tmp/Rtmppg5iuq/file1afb44dce5ff
#> 8                        /tmp/Rtmppg5iuq/file1afb452b43b9
#> 9                        /tmp/Rtmppg5iuq/file1afb4b89f7fe
#> 10                       /tmp/Rtmppg5iuq/file1afb4caa8df2
#> 11                       /tmp/Rtmppg5iuq/file1afb4cc6fe3d
#> 12                   /tmp/Rtmppg5iuq/file1afb772f8ee8.txt
#> 13                   /tmp/Rtmppg5iuq/file1afb7d0328c4.csv
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
