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
#> 1  bslib-03915c98e1bba073af2cc4dfd18baa4a   0.004 2026-04-17 09:29:23
#> 2                                 downlit   0.004 2026-04-17 09:29:31
#> 3                        file1a301959e4cc   0.004 2026-04-17 09:29:23
#> 4                    file1a3025de9616.csv   0.000 2026-04-17 09:29:31
#> 5                        file1a302da616d6   0.000 2026-04-17 09:29:26
#> 6                        file1a303018d939   0.000 2026-04-17 09:29:30
#> 7                         file1a30418c94d   0.000 2026-04-17 09:29:26
#> 8                        file1a30437677da   0.004 2026-04-17 09:29:23
#> 9                        file1a3062b6c01a   0.004 2026-04-17 09:29:24
#> 10                       file1a306433614b   0.004 2026-04-17 09:29:23
#> 11                       file1a306b405841   0.004 2026-04-17 09:29:24
#> 12                       file1a306e11d200   0.004 2026-04-17 09:29:24
#> 13                    file1a30ce88f4e.txt   0.000 2026-04-17 09:29:31
#>                                                      path
#> 1  /tmp/Rtmpc177kE/bslib-03915c98e1bba073af2cc4dfd18baa4a
#> 2                                 /tmp/Rtmpc177kE/downlit
#> 3                        /tmp/Rtmpc177kE/file1a301959e4cc
#> 4                    /tmp/Rtmpc177kE/file1a3025de9616.csv
#> 5                        /tmp/Rtmpc177kE/file1a302da616d6
#> 6                        /tmp/Rtmpc177kE/file1a303018d939
#> 7                         /tmp/Rtmpc177kE/file1a30418c94d
#> 8                        /tmp/Rtmpc177kE/file1a30437677da
#> 9                        /tmp/Rtmpc177kE/file1a3062b6c01a
#> 10                       /tmp/Rtmpc177kE/file1a306433614b
#> 11                       /tmp/Rtmpc177kE/file1a306b405841
#> 12                       /tmp/Rtmpc177kE/file1a306e11d200
#> 13                    /tmp/Rtmpc177kE/file1a30ce88f4e.txt
file_ls(tempdir(), pattern = "\\.R$", recursive = TRUE)
#> [1] file          size_MB       modified_time path         
#> <0 rows> (or 0-length row.names)
```
