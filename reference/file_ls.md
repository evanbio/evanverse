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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-29 14:12:04
#> 2                                 downlit   0.004 2026-03-29 14:12:13
#> 3                        file1c5d1a1bd72c   0.004 2026-03-29 14:12:06
#> 4                        file1c5d35e45313   0.004 2026-03-29 14:12:06
#> 5                    file1c5d3c17763a.txt   0.000 2026-03-29 14:12:13
#> 6                        file1c5d420f102b   0.000 2026-03-29 14:12:07
#> 7                        file1c5d4d1b7f7f   0.004 2026-03-29 14:12:05
#> 8                        file1c5d55c0cd72   0.004 2026-03-29 14:12:06
#> 9                    file1c5d6035e12f.csv   0.000 2026-03-29 14:12:13
#> 10                       file1c5d6712545f   0.000 2026-03-29 14:12:11
#> 11                       file1c5d792ab4ae   0.004 2026-03-29 14:12:05
#> 12                       file1c5d7a3f8685   0.000 2026-03-29 14:12:12
#> 13                       file1c5d7c6e4eed   0.004 2026-03-29 14:12:05
#>                                                      path
#> 1  /tmp/RtmpqQsuau/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpqQsuau/downlit
#> 3                        /tmp/RtmpqQsuau/file1c5d1a1bd72c
#> 4                        /tmp/RtmpqQsuau/file1c5d35e45313
#> 5                    /tmp/RtmpqQsuau/file1c5d3c17763a.txt
#> 6                        /tmp/RtmpqQsuau/file1c5d420f102b
#> 7                        /tmp/RtmpqQsuau/file1c5d4d1b7f7f
#> 8                        /tmp/RtmpqQsuau/file1c5d55c0cd72
#> 9                    /tmp/RtmpqQsuau/file1c5d6035e12f.csv
#> 10                       /tmp/RtmpqQsuau/file1c5d6712545f
#> 11                       /tmp/RtmpqQsuau/file1c5d792ab4ae
#> 12                       /tmp/RtmpqQsuau/file1c5d7a3f8685
#> 13                       /tmp/RtmpqQsuau/file1c5d7c6e4eed
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
