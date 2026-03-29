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
#> 1 file1c0a237735f0.txt       0 2026-03-29 12:50:41
#> 2 file1c0a20f89945.csv       0 2026-03-29 12:50:41
#>                                   path
#> 1 /tmp/RtmpLX8B30/file1c0a237735f0.txt
#> 2 /tmp/RtmpLX8B30/file1c0a20f89945.csv
```
