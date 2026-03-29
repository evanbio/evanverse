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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-29 15:18:40
#> 2                                 downlit   0.004 2026-03-29 15:18:49
#> 3                        file1c521349384f   0.004 2026-03-29 15:18:42
#> 4                        file1c521c50d1e1   0.004 2026-03-29 15:18:40
#> 5                        file1c5222080800   0.000 2026-03-29 15:18:47
#> 6                        file1c52321659fa   0.000 2026-03-29 15:18:48
#> 7                    file1c523684fd78.csv   0.000 2026-03-29 15:18:49
#> 8                        file1c5243d75ebe   0.004 2026-03-29 15:18:40
#> 9                        file1c5245d18199   0.004 2026-03-29 15:18:42
#> 10                   file1c524d90d887.txt   0.000 2026-03-29 15:18:49
#> 11                       file1c524f3815f3   0.004 2026-03-29 15:18:42
#> 12                       file1c52722e3340   0.004 2026-03-29 15:18:40
#> 13                       file1c527fa54fb8   0.000 2026-03-29 15:18:43
#>                                                      path
#> 1  /tmp/Rtmp7t0SD5/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/Rtmp7t0SD5/downlit
#> 3                        /tmp/Rtmp7t0SD5/file1c521349384f
#> 4                        /tmp/Rtmp7t0SD5/file1c521c50d1e1
#> 5                        /tmp/Rtmp7t0SD5/file1c5222080800
#> 6                        /tmp/Rtmp7t0SD5/file1c52321659fa
#> 7                    /tmp/Rtmp7t0SD5/file1c523684fd78.csv
#> 8                        /tmp/Rtmp7t0SD5/file1c5243d75ebe
#> 9                        /tmp/Rtmp7t0SD5/file1c5245d18199
#> 10                   /tmp/Rtmp7t0SD5/file1c524d90d887.txt
#> 11                       /tmp/Rtmp7t0SD5/file1c524f3815f3
#> 12                       /tmp/Rtmp7t0SD5/file1c52722e3340
#> 13                       /tmp/Rtmp7t0SD5/file1c527fa54fb8
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
