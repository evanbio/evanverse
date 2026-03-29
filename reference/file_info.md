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
#> 1 file1c5d3c17763a.txt       0 2026-03-29 14:12:13
#> 2 file1c5d6035e12f.csv       0 2026-03-29 14:12:13
#>                                   path
#> 1 /tmp/RtmpqQsuau/file1c5d3c17763a.txt
#> 2 /tmp/RtmpqQsuau/file1c5d6035e12f.csv
```
