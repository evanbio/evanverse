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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-04-02 02:46:55
#> 2                                 downlit   0.004 2026-04-02 02:47:03
#> 3                        file1d6318b8d218   0.004 2026-04-02 02:46:56
#> 4                    file1d6329176069.csv   0.000 2026-04-02 02:47:03
#> 5                        file1d632fef5720   0.000 2026-04-02 02:47:02
#> 6                        file1d6331d96a09   0.004 2026-04-02 02:46:55
#> 7                         file1d6343e9088   0.004 2026-04-02 02:46:56
#> 8                        file1d63547a69d4   0.004 2026-04-02 02:46:56
#> 9                        file1d63574a331d   0.000 2026-04-02 02:46:57
#> 10                       file1d636529e01e   0.000 2026-04-02 02:47:01
#> 11                   file1d6365a85b35.txt   0.000 2026-04-02 02:47:03
#> 12                       file1d636d445ce0   0.004 2026-04-02 02:46:55
#> 13                        file1d63f097f15   0.004 2026-04-02 02:46:55
#>                                                      path
#> 1  /tmp/RtmppAT0uQ/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/RtmppAT0uQ/downlit
#> 3                        /tmp/RtmppAT0uQ/file1d6318b8d218
#> 4                    /tmp/RtmppAT0uQ/file1d6329176069.csv
#> 5                        /tmp/RtmppAT0uQ/file1d632fef5720
#> 6                        /tmp/RtmppAT0uQ/file1d6331d96a09
#> 7                         /tmp/RtmppAT0uQ/file1d6343e9088
#> 8                        /tmp/RtmppAT0uQ/file1d63547a69d4
#> 9                        /tmp/RtmppAT0uQ/file1d63574a331d
#> 10                       /tmp/RtmppAT0uQ/file1d636529e01e
#> 11                   /tmp/RtmppAT0uQ/file1d6365a85b35.txt
#> 12                       /tmp/RtmppAT0uQ/file1d636d445ce0
#> 13                        /tmp/RtmppAT0uQ/file1d63f097f15
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
