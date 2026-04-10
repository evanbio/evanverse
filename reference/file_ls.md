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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-04-10 14:20:03
#> 2                                 downlit   0.004 2026-04-10 14:20:11
#> 3                        file1a3c17955cc5   0.004 2026-04-10 14:20:04
#> 4                        file1a3c18ada779   0.000 2026-04-10 14:20:06
#> 5                        file1a3c1bb0147f   0.000 2026-04-10 14:20:10
#> 6                        file1a3c345ae92c   0.004 2026-04-10 14:20:04
#> 7                        file1a3c38e16556   0.004 2026-04-10 14:20:05
#> 8                    file1a3c3ba5081b.txt   0.000 2026-04-10 14:20:11
#> 9                    file1a3c5a8d68ee.csv   0.000 2026-04-10 14:20:11
#> 10                       file1a3c5f07a82c   0.004 2026-04-10 14:20:05
#> 11                       file1a3c71d1aa34   0.004 2026-04-10 14:20:05
#> 12                       file1a3c7ddd80ad   0.000 2026-04-10 14:20:07
#> 13                        file1a3ccdb8eee   0.004 2026-04-10 14:20:04
#>                                                      path
#> 1  /tmp/RtmpcskXh6/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpcskXh6/downlit
#> 3                        /tmp/RtmpcskXh6/file1a3c17955cc5
#> 4                        /tmp/RtmpcskXh6/file1a3c18ada779
#> 5                        /tmp/RtmpcskXh6/file1a3c1bb0147f
#> 6                        /tmp/RtmpcskXh6/file1a3c345ae92c
#> 7                        /tmp/RtmpcskXh6/file1a3c38e16556
#> 8                    /tmp/RtmpcskXh6/file1a3c3ba5081b.txt
#> 9                    /tmp/RtmpcskXh6/file1a3c5a8d68ee.csv
#> 10                       /tmp/RtmpcskXh6/file1a3c5f07a82c
#> 11                       /tmp/RtmpcskXh6/file1a3c71d1aa34
#> 12                       /tmp/RtmpcskXh6/file1a3c7ddd80ad
#> 13                        /tmp/RtmpcskXh6/file1a3ccdb8eee
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
