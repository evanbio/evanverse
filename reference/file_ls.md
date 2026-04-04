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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-04-04 12:04:05
#> 2                                 downlit   0.004 2026-04-04 12:04:14
#> 3                        file1be3111ebf2c   0.004 2026-04-04 12:04:05
#> 4                        file1be31fb30194   0.004 2026-04-04 12:04:05
#> 5                        file1be33a8d66df   0.004 2026-04-04 12:04:07
#> 6                        file1be342e5dc0f   0.000 2026-04-04 12:04:12
#> 7                    file1be3479e5d73.txt   0.000 2026-04-04 12:04:14
#> 8                    file1be34d149574.csv   0.000 2026-04-04 12:04:14
#> 9                        file1be358c071b7   0.004 2026-04-04 12:04:05
#> 10                       file1be367df39d2   0.000 2026-04-04 12:04:13
#> 11                       file1be36eaf44b7   0.004 2026-04-04 12:04:07
#> 12                        file1be390dba21   0.004 2026-04-04 12:04:07
#> 13                        file1be3b719b0d   0.000 2026-04-04 12:04:08
#>                                                      path
#> 1  /tmp/RtmpMbHjBv/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpMbHjBv/downlit
#> 3                        /tmp/RtmpMbHjBv/file1be3111ebf2c
#> 4                        /tmp/RtmpMbHjBv/file1be31fb30194
#> 5                        /tmp/RtmpMbHjBv/file1be33a8d66df
#> 6                        /tmp/RtmpMbHjBv/file1be342e5dc0f
#> 7                    /tmp/RtmpMbHjBv/file1be3479e5d73.txt
#> 8                    /tmp/RtmpMbHjBv/file1be34d149574.csv
#> 9                        /tmp/RtmpMbHjBv/file1be358c071b7
#> 10                       /tmp/RtmpMbHjBv/file1be367df39d2
#> 11                       /tmp/RtmpMbHjBv/file1be36eaf44b7
#> 12                        /tmp/RtmpMbHjBv/file1be390dba21
#> 13                        /tmp/RtmpMbHjBv/file1be3b719b0d
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
