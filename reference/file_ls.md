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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-29 15:25:34
#> 2                                 downlit   0.004 2026-03-29 15:25:43
#> 3                    file1c4d158cf86f.csv   0.000 2026-03-29 15:25:44
#> 4                        file1c4d174201ae   0.004 2026-03-29 15:25:34
#> 5                        file1c4d1cf72bb3   0.004 2026-03-29 15:25:36
#> 6                        file1c4d4c451d55   0.000 2026-03-29 15:25:43
#> 7                        file1c4d4f0bc237   0.000 2026-03-29 15:25:42
#> 8                        file1c4d6553d411   0.004 2026-03-29 15:25:36
#> 9                        file1c4d66848fda   0.004 2026-03-29 15:25:34
#> 10                       file1c4d7ec01a09   0.000 2026-03-29 15:25:37
#> 11                    file1c4d9a99eaf.txt   0.000 2026-03-29 15:25:44
#> 12                         file1c4dd0c9f9   0.004 2026-03-29 15:25:34
#> 13                        file1c4df20481e   0.004 2026-03-29 15:25:36
#>                                                      path
#> 1  /tmp/RtmpqUNPwK/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpqUNPwK/downlit
#> 3                    /tmp/RtmpqUNPwK/file1c4d158cf86f.csv
#> 4                        /tmp/RtmpqUNPwK/file1c4d174201ae
#> 5                        /tmp/RtmpqUNPwK/file1c4d1cf72bb3
#> 6                        /tmp/RtmpqUNPwK/file1c4d4c451d55
#> 7                        /tmp/RtmpqUNPwK/file1c4d4f0bc237
#> 8                        /tmp/RtmpqUNPwK/file1c4d6553d411
#> 9                        /tmp/RtmpqUNPwK/file1c4d66848fda
#> 10                       /tmp/RtmpqUNPwK/file1c4d7ec01a09
#> 11                    /tmp/RtmpqUNPwK/file1c4d9a99eaf.txt
#> 12                         /tmp/RtmpqUNPwK/file1c4dd0c9f9
#> 13                        /tmp/RtmpqUNPwK/file1c4df20481e
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
