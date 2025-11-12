# get_ext: Extract File Extension(s)

Extract file extension(s) from a file name or path. Supports vector
input and optionally preserves compound extensions (e.g., .tar.gz) when
keep_all = TRUE.

## Usage

``` r
get_ext(paths, keep_all = FALSE, include_dot = FALSE, to_lower = FALSE)
```

## Arguments

- paths:

  Character vector of file names or paths.

- keep_all:

  Logical. If TRUE, returns full suffix after first dot in basename. If
  FALSE, returns only the last extension. Default is FALSE.

- include_dot:

  Logical. If TRUE, includes the leading dot in result. Default is
  FALSE.

- to_lower:

  Logical. If TRUE, converts extensions to lowercase. Default is FALSE.

## Value

Character vector of extensions.

## Examples

``` r
get_ext("data.csv")               # "csv"
#> [1] "csv"
get_ext("archive.tar.gz")         # "gz"
#> [1] "gz"
get_ext("archive.tar.gz", TRUE)   # "tar.gz"
#> [1] "tar.gz"
get_ext(c("a.R", "b.txt", "c"))   # "R" "txt" ""
#> [1] "R"   "txt" ""   
get_ext("data.CSV", to_lower = TRUE)  # "csv"
#> [1] "csv"
```
