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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-03-31 05:49:31
#> 2                                 downlit   0.004 2026-03-31 05:49:40
#> 3                        file1c2e16b78824   0.004 2026-03-31 05:49:32
#> 4                    file1c2e1e95ea65.csv   0.000 2026-03-31 05:49:41
#> 5                    file1c2e2aa929be.txt   0.000 2026-03-31 05:49:41
#> 6                        file1c2e2ffcc513   0.000 2026-03-31 05:49:40
#> 7                        file1c2e32311f6f   0.004 2026-03-31 05:49:32
#> 8                         file1c2e32a022d   0.004 2026-03-31 05:49:33
#> 9                        file1c2e332517e3   0.004 2026-03-31 05:49:32
#> 10                       file1c2e36d83513   0.000 2026-03-31 05:49:34
#> 11                       file1c2e64ac4d94   0.000 2026-03-31 05:49:39
#> 12                        file1c2e78ff502   0.004 2026-03-31 05:49:33
#> 13                       file1c2e7c3388bb   0.004 2026-03-31 05:49:33
#>                                                      path
#> 1  /tmp/RtmpoaTqJK/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmpoaTqJK/downlit
#> 3                        /tmp/RtmpoaTqJK/file1c2e16b78824
#> 4                    /tmp/RtmpoaTqJK/file1c2e1e95ea65.csv
#> 5                    /tmp/RtmpoaTqJK/file1c2e2aa929be.txt
#> 6                        /tmp/RtmpoaTqJK/file1c2e2ffcc513
#> 7                        /tmp/RtmpoaTqJK/file1c2e32311f6f
#> 8                         /tmp/RtmpoaTqJK/file1c2e32a022d
#> 9                        /tmp/RtmpoaTqJK/file1c2e332517e3
#> 10                       /tmp/RtmpoaTqJK/file1c2e36d83513
#> 11                       /tmp/RtmpoaTqJK/file1c2e64ac4d94
#> 12                        /tmp/RtmpoaTqJK/file1c2e78ff502
#> 13                       /tmp/RtmpoaTqJK/file1c2e7c3388bb
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
