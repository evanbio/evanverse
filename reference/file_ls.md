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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-31 09:12:31
#> 2                                 downlit   0.004 2026-03-31 09:12:41
#> 3                        file1bd818be6e1c   0.000 2026-03-31 09:12:35
#> 4                        file1bd81fd43836   0.000 2026-03-31 09:12:39
#> 5                        file1bd8255322ea   0.004 2026-03-31 09:12:34
#> 6                        file1bd82c74cd67   0.004 2026-03-31 09:12:34
#> 7                    file1bd83b2b5bd5.txt   0.000 2026-03-31 09:12:41
#> 8                        file1bd844055b8f   0.004 2026-03-31 09:12:32
#> 9                        file1bd84e9e22c3   0.004 2026-03-31 09:12:32
#> 10                       file1bd853ded8d4   0.000 2026-03-31 09:12:40
#> 11                   file1bd85a979a41.csv   0.000 2026-03-31 09:12:41
#> 12                       file1bd873ad7310   0.004 2026-03-31 09:12:32
#> 13                       file1bd877b355c3   0.004 2026-03-31 09:12:34
#>                                                      path
#> 1  /tmp/RtmpnWbzLe/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpnWbzLe/downlit
#> 3                        /tmp/RtmpnWbzLe/file1bd818be6e1c
#> 4                        /tmp/RtmpnWbzLe/file1bd81fd43836
#> 5                        /tmp/RtmpnWbzLe/file1bd8255322ea
#> 6                        /tmp/RtmpnWbzLe/file1bd82c74cd67
#> 7                    /tmp/RtmpnWbzLe/file1bd83b2b5bd5.txt
#> 8                        /tmp/RtmpnWbzLe/file1bd844055b8f
#> 9                        /tmp/RtmpnWbzLe/file1bd84e9e22c3
#> 10                       /tmp/RtmpnWbzLe/file1bd853ded8d4
#> 11                   /tmp/RtmpnWbzLe/file1bd85a979a41.csv
#> 12                       /tmp/RtmpnWbzLe/file1bd873ad7310
#> 13                       /tmp/RtmpnWbzLe/file1bd877b355c3
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
