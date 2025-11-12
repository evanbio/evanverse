# Check Package Versions

Check installed and latest available versions of R packages across CRAN,
Bioconductor, and GitHub. Supports case-insensitive matching.

## Usage

``` r
pkg_version(pkg, preview = TRUE)
```

## Arguments

- pkg:

  Character vector. Package names to check.

- preview:

  Logical. If TRUE (default), print result to console.

## Value

A data.frame with columns: `package`, `version` (installed), `latest`
(available), and `source`.

## Examples

``` r
if (FALSE) { # \dontrun{
# Check versions of multiple packages:
pkg_version(c("ggplot2", "dplyr"))

# Check without console preview:
result <- pkg_version(c("ggplot2", "limma"), preview = FALSE)
} # }
```
