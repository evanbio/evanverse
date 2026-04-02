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
#> 1 file1d6365a85b35.txt       0 2026-04-02 02:47:03
#> 2 file1d6329176069.csv       0 2026-04-02 02:47:03
#>                                   path
#> 1 /tmp/RtmppAT0uQ/file1d6365a85b35.txt
#> 2 /tmp/RtmppAT0uQ/file1d6329176069.csv
```
