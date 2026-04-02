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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-04-02 03:02:08
#> 2                                 downlit   0.004 2026-04-02 03:02:17
#> 3                        file1c43258f9c3a   0.004 2026-04-02 03:02:09
#> 4                        file1c4326b4e384   0.004 2026-04-02 03:02:09
#> 5                        file1c4328d03908   0.000 2026-04-02 03:02:10
#> 6                        file1c432ddf891c   0.000 2026-04-02 03:02:16
#> 7                    file1c433783d0bb.csv   0.000 2026-04-02 03:02:17
#> 8                        file1c433fc6b351   0.004 2026-04-02 03:02:08
#> 9                        file1c4356ca59e7   0.004 2026-04-02 03:02:08
#> 10                       file1c4356d1151f   0.000 2026-04-02 03:02:15
#> 11                       file1c43687820ed   0.004 2026-04-02 03:02:08
#> 12                       file1c437ccc3027   0.004 2026-04-02 03:02:09
#> 13                   file1c437ec22071.txt   0.000 2026-04-02 03:02:17
#>                                                      path
#> 1  /tmp/Rtmp97J7zu/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/Rtmp97J7zu/downlit
#> 3                        /tmp/Rtmp97J7zu/file1c43258f9c3a
#> 4                        /tmp/Rtmp97J7zu/file1c4326b4e384
#> 5                        /tmp/Rtmp97J7zu/file1c4328d03908
#> 6                        /tmp/Rtmp97J7zu/file1c432ddf891c
#> 7                    /tmp/Rtmp97J7zu/file1c433783d0bb.csv
#> 8                        /tmp/Rtmp97J7zu/file1c433fc6b351
#> 9                        /tmp/Rtmp97J7zu/file1c4356ca59e7
#> 10                       /tmp/Rtmp97J7zu/file1c4356d1151f
#> 11                       /tmp/Rtmp97J7zu/file1c43687820ed
#> 12                       /tmp/Rtmp97J7zu/file1c437ccc3027
#> 13                   /tmp/Rtmp97J7zu/file1c437ec22071.txt
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
