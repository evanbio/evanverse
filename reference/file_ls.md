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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-31 05:31:26
#> 2                                 downlit   0.004 2026-03-31 05:31:35
#> 3                        file1c2e10820e08   0.000 2026-03-31 05:31:29
#> 4                        file1c2e152a3178   0.004 2026-03-31 05:31:28
#> 5                        file1c2e15c054d6   0.004 2026-03-31 05:31:26
#> 6                        file1c2e232b3f82   0.004 2026-03-31 05:31:28
#> 7                    file1c2e2bc999e7.csv   0.000 2026-03-31 05:31:35
#> 8                    file1c2e2d30ffb0.txt   0.000 2026-03-31 05:31:35
#> 9                        file1c2e5035d8ec   0.004 2026-03-31 05:31:28
#> 10                       file1c2e54d042c5   0.000 2026-03-31 05:31:34
#> 11                       file1c2e553b524b   0.000 2026-03-31 05:31:33
#> 12                        file1c2e55f2506   0.004 2026-03-31 05:31:26
#> 13                       file1c2e7d87887f   0.004 2026-03-31 05:31:26
#>                                                      path
#> 1  /tmp/RtmpPRw1mp/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpPRw1mp/downlit
#> 3                        /tmp/RtmpPRw1mp/file1c2e10820e08
#> 4                        /tmp/RtmpPRw1mp/file1c2e152a3178
#> 5                        /tmp/RtmpPRw1mp/file1c2e15c054d6
#> 6                        /tmp/RtmpPRw1mp/file1c2e232b3f82
#> 7                    /tmp/RtmpPRw1mp/file1c2e2bc999e7.csv
#> 8                    /tmp/RtmpPRw1mp/file1c2e2d30ffb0.txt
#> 9                        /tmp/RtmpPRw1mp/file1c2e5035d8ec
#> 10                       /tmp/RtmpPRw1mp/file1c2e54d042c5
#> 11                       /tmp/RtmpPRw1mp/file1c2e553b524b
#> 12                        /tmp/RtmpPRw1mp/file1c2e55f2506
#> 13                       /tmp/RtmpPRw1mp/file1c2e7d87887f
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
