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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-04-17 09:45:18
#> 2                                 downlit   0.004 2026-04-17 09:45:26
#> 3                        file19dc18ec669d   0.000 2026-04-17 09:45:21
#> 4                        file19dc1d10ffa7   0.004 2026-04-17 09:45:18
#> 5                        file19dc23709a68   0.004 2026-04-17 09:45:18
#> 6                        file19dc2dc4450f   0.000 2026-04-17 09:45:21
#> 7                        file19dc43a69cde   0.004 2026-04-17 09:45:19
#> 8                        file19dc471ca52b   0.004 2026-04-17 09:45:18
#> 9                    file19dc516a16fa.txt   0.000 2026-04-17 09:45:26
#> 10                       file19dc640f6b9f   0.000 2026-04-17 09:45:25
#> 11                   file19dc6880b045.csv   0.000 2026-04-17 09:45:26
#> 12                       file19dc75eb07ee   0.004 2026-04-17 09:45:19
#> 13                       file19dc77d72e49   0.004 2026-04-17 09:45:19
#>                                                      path
#> 1  /tmp/Rtmp9QYLfi/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/Rtmp9QYLfi/downlit
#> 3                        /tmp/Rtmp9QYLfi/file19dc18ec669d
#> 4                        /tmp/Rtmp9QYLfi/file19dc1d10ffa7
#> 5                        /tmp/Rtmp9QYLfi/file19dc23709a68
#> 6                        /tmp/Rtmp9QYLfi/file19dc2dc4450f
#> 7                        /tmp/Rtmp9QYLfi/file19dc43a69cde
#> 8                        /tmp/Rtmp9QYLfi/file19dc471ca52b
#> 9                    /tmp/Rtmp9QYLfi/file19dc516a16fa.txt
#> 10                       /tmp/Rtmp9QYLfi/file19dc640f6b9f
#> 11                   /tmp/Rtmp9QYLfi/file19dc6880b045.csv
#> 12                       /tmp/Rtmp9QYLfi/file19dc75eb07ee
#> 13                       /tmp/Rtmp9QYLfi/file19dc77d72e49
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
