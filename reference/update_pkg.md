# Update R Packages

Update R packages from CRAN, GitHub, or Bioconductor. Supports full
updates, source-specific updates, or targeted package updates.

## Usage

``` r
update_pkg(
  pkg = NULL,
  source = c("all", "CRAN", "GitHub", "Bioconductor"),
  ...
)
```

## Arguments

- pkg:

  Character vector. Package name(s) or GitHub `"user/repo"`. If NULL,
  updates all installed packages for the given source.

- source:

  Character. One of `"all"`, `"CRAN"`, `"GitHub"`, `"Bioconductor"`.
  Default `"all"` updates all CRAN + Bioconductor packages.

- ...:

  Passed to the underlying update function.

## Value

NULL invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
update_pkg()                                    # all CRAN + Bioc
update_pkg(source = "CRAN")                     # all CRAN only
update_pkg("ggplot2", source = "CRAN")          # specific package
update_pkg("hadley/ggplot2", source = "GitHub")
} # }
```
