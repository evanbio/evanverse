# Managing R Packages with evanverse

``` r
library(evanverse)
```

## 📦 Manage Your R Packages with Style

`evanverse` provides streamlined utility functions for installing,
checking, and updating R packages — including support for CRAN,
Bioconductor, and GitHub.

This vignette walks through:

- [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md)
  — install packages from any source

- [`check_pkg()`](https://evanbio.github.io/evanverse/reference/check_pkg.md)
  — check if a package is installed

- [`update_pkg()`](https://evanbio.github.io/evanverse/reference/update_pkg.md)
  — update packages smartly

## 🔧 Install Packages — `inst_pkg()`

``` r
# Install a single CRAN package
inst_pkg("dplyr", source = "CRAN")

# Install from GitHub
inst_pkg("evanbio/evanverse", source = "GitHub")

# Install Bioconductor packages
inst_pkg("edgeR", source = "Bioconductor")
```

## 🔍 Check Package Availability — `check_pkg()`

``` r
check_pkg("ggplot2")    # TRUE
check_pkg("notapkg")    # FALSE
```

## 🔁 Update Packages — `update_pkg()`

``` r
# Update CRAN and Bioconductor packages
update_pkg()

# Update GitHub packages only
update_pkg(pkg = c("evanbio/evanverse", "rstudio/gt"), source = "GitHub")

# Update specific Bioconductor package
update_pkg(pkg = "limma", source = "Bioconductor")
```

## 📘 Summary

Managing packages across CRAN, Bioconductor, and GitHub doesn’t need to
be a pain.

With `evanverse`, you can keep your environment tidy and up-to-date —
with just a few consistent commands.
