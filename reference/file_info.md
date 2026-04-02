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
#> 1 file1c437ec22071.txt       0 2026-04-02 03:02:17
#> 2 file1c433783d0bb.csv       0 2026-04-02 03:02:17
#>                                   path
#> 1 /tmp/Rtmp97J7zu/file1c437ec22071.txt
#> 2 /tmp/Rtmp97J7zu/file1c433783d0bb.csv
```
