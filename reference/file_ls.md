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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-29 12:50:32
#> 2                                 downlit   0.004 2026-03-29 12:50:41
#> 3                        file1c0a1f9ab12e   0.000 2026-03-29 12:50:39
#> 4                    file1c0a20f89945.csv   0.000 2026-03-29 12:50:41
#> 5                        file1c0a22caee16   0.004 2026-03-29 12:50:32
#> 6                    file1c0a237735f0.txt   0.000 2026-03-29 12:50:41
#> 7                        file1c0a2cdfb70b   0.000 2026-03-29 12:50:35
#> 8                        file1c0a52a57eaf   0.004 2026-03-29 12:50:34
#> 9                        file1c0a5ce64096   0.004 2026-03-29 12:50:34
#> 10                       file1c0a640ba0ae   0.000 2026-03-29 12:50:40
#> 11                       file1c0a67cc92b7   0.004 2026-03-29 12:50:34
#> 12                       file1c0a6f08248d   0.004 2026-03-29 12:50:32
#> 13                        file1c0ac8f40b7   0.004 2026-03-29 12:50:32
#>                                                      path
#> 1  /tmp/RtmpLX8B30/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpLX8B30/downlit
#> 3                        /tmp/RtmpLX8B30/file1c0a1f9ab12e
#> 4                    /tmp/RtmpLX8B30/file1c0a20f89945.csv
#> 5                        /tmp/RtmpLX8B30/file1c0a22caee16
#> 6                    /tmp/RtmpLX8B30/file1c0a237735f0.txt
#> 7                        /tmp/RtmpLX8B30/file1c0a2cdfb70b
#> 8                        /tmp/RtmpLX8B30/file1c0a52a57eaf
#> 9                        /tmp/RtmpLX8B30/file1c0a5ce64096
#> 10                       /tmp/RtmpLX8B30/file1c0a640ba0ae
#> 11                       /tmp/RtmpLX8B30/file1c0a67cc92b7
#> 12                       /tmp/RtmpLX8B30/file1c0a6f08248d
#> 13                        /tmp/RtmpLX8B30/file1c0ac8f40b7
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
