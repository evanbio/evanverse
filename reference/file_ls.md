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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-31 07:24:41
#> 2                                 downlit   0.004 2026-03-31 07:24:49
#> 3                        file1c3513c95b8d   0.000 2026-03-31 07:24:43
#> 4                    file1c352bcd4f62.csv   0.000 2026-03-31 07:24:49
#> 5                        file1c3537fc54f4   0.000 2026-03-31 07:24:47
#> 6                        file1c353fe0abe6   0.004 2026-03-31 07:24:41
#> 7                        file1c3540cb74a4   0.004 2026-03-31 07:24:41
#> 8                        file1c354c3d6216   0.000 2026-03-31 07:24:48
#> 9                         file1c3559c372c   0.004 2026-03-31 07:24:41
#> 10                       file1c355ef17f18   0.004 2026-03-31 07:24:42
#> 11                   file1c356d6a2b51.txt   0.000 2026-03-31 07:24:49
#> 12                       file1c3574bacf4e   0.004 2026-03-31 07:24:42
#> 13                         file1c35e5c20e   0.004 2026-03-31 07:24:42
#>                                                      path
#> 1  /tmp/RtmpDjYdGl/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpDjYdGl/downlit
#> 3                        /tmp/RtmpDjYdGl/file1c3513c95b8d
#> 4                    /tmp/RtmpDjYdGl/file1c352bcd4f62.csv
#> 5                        /tmp/RtmpDjYdGl/file1c3537fc54f4
#> 6                        /tmp/RtmpDjYdGl/file1c353fe0abe6
#> 7                        /tmp/RtmpDjYdGl/file1c3540cb74a4
#> 8                        /tmp/RtmpDjYdGl/file1c354c3d6216
#> 9                         /tmp/RtmpDjYdGl/file1c3559c372c
#> 10                       /tmp/RtmpDjYdGl/file1c355ef17f18
#> 11                   /tmp/RtmpDjYdGl/file1c356d6a2b51.txt
#> 12                       /tmp/RtmpDjYdGl/file1c3574bacf4e
#> 13                         /tmp/RtmpDjYdGl/file1c35e5c20e
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
