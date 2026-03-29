# Check Package Versions

Check installed and latest available versions of R packages across CRAN,
Bioconductor, and GitHub.

## Usage

``` r
pkg_version(pkg)
```

## Arguments

- pkg:

  Character vector. Package names to check.

## Value

A data.frame with columns: `package`, `version` (installed version),
`latest` (latest available on CRAN/Bioc; for GitHub packages this
reflects the installed remote SHA, not the actual latest remote commit),
`source`. GitHub info is only available for installed packages with
`RemoteType == "github"` in their DESCRIPTION.

## Examples

``` r
if (FALSE) { # \dontrun{
pkg_version(c("ggplot2", "dplyr"))
} # }
```
