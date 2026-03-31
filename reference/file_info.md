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
#> 1 file1c2e2d30ffb0.txt       0 2026-03-31 05:31:35
#> 2 file1c2e2bc999e7.csv       0 2026-03-31 05:31:35
#>                                   path
#> 1 /tmp/RtmpPRw1mp/file1c2e2d30ffb0.txt
#> 2 /tmp/RtmpPRw1mp/file1c2e2bc999e7.csv
```
