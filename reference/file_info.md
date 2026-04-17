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
#> 1 file19dc516a16fa.txt       0 2026-04-17 09:45:26
#> 2 file19dc6880b045.csv       0 2026-04-17 09:45:26
#>                                   path
#> 1 /tmp/Rtmp9QYLfi/file19dc516a16fa.txt
#> 2 /tmp/Rtmp9QYLfi/file19dc6880b045.csv
```
