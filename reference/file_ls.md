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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-29 15:21:25
#> 2                                 downlit   0.004 2026-03-29 15:21:34
#> 3                    file1c4910164596.csv   0.000 2026-03-29 15:21:34
#> 4                        file1c492a4c8516   0.000 2026-03-29 15:21:32
#> 5                        file1c49303625e4   0.000 2026-03-29 15:21:28
#> 6                        file1c4930a5f987   0.004 2026-03-29 15:21:27
#> 7                    file1c4934549a56.txt   0.000 2026-03-29 15:21:34
#> 8                        file1c4939a1b96a   0.004 2026-03-29 15:21:25
#> 9                        file1c4946f182c5   0.004 2026-03-29 15:21:25
#> 10                        file1c4947f074a   0.004 2026-03-29 15:21:27
#> 11                       file1c4952392b97   0.000 2026-03-29 15:21:33
#> 12                       file1c495f80176a   0.004 2026-03-29 15:21:25
#> 13                       file1c4977984ac2   0.004 2026-03-29 15:21:27
#>                                                      path
#> 1  /tmp/RtmpDTkdcL/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpDTkdcL/downlit
#> 3                    /tmp/RtmpDTkdcL/file1c4910164596.csv
#> 4                        /tmp/RtmpDTkdcL/file1c492a4c8516
#> 5                        /tmp/RtmpDTkdcL/file1c49303625e4
#> 6                        /tmp/RtmpDTkdcL/file1c4930a5f987
#> 7                    /tmp/RtmpDTkdcL/file1c4934549a56.txt
#> 8                        /tmp/RtmpDTkdcL/file1c4939a1b96a
#> 9                        /tmp/RtmpDTkdcL/file1c4946f182c5
#> 10                        /tmp/RtmpDTkdcL/file1c4947f074a
#> 11                       /tmp/RtmpDTkdcL/file1c4952392b97
#> 12                       /tmp/RtmpDTkdcL/file1c495f80176a
#> 13                       /tmp/RtmpDTkdcL/file1c4977984ac2
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
