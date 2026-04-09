# Get metadata for one or more files

Returns a data.frame with file metadata for the given file path(s).

## Usage

``` r
file_info(file)
```

## Arguments

- file:

  Character vector of file paths.

## Value

A data.frame with columns: `file`, `size_MB`, `modified_time`, `path`.

## Examples

``` r
f1 <- tempfile(fileext = ".txt")
f2 <- tempfile(fileext = ".csv")
writeLines("hello", f1)
writeLines("a,b\\n1,2", f2)
file_info(c(f1, f2))
#>                   file size_MB       modified_time
#> 1 file1ccf665a29ef.txt       0 2026-04-09 02:41:27
#> 2 file1ccf7138a41f.csv       0 2026-04-09 02:41:27
#>                                   path
#> 1 /tmp/RtmpqMRrJC/file1ccf665a29ef.txt
#> 2 /tmp/RtmpqMRrJC/file1ccf7138a41f.csv
```
