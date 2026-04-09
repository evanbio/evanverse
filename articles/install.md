# Installation Guide

## Overview

This guide covers installation and mirror setup for `evanverse`. For
package installation and updates beyond evanverse itself, we recommend
[pak](https://pak.r-lib.org/).

| Area                    | Tools                                                                                                                                            |
|-------------------------|--------------------------------------------------------------------------------------------------------------------------------------------------|
| Base installation       | [`install.packages()`](https://rdrr.io/r/utils/install.packages.html), [`pak::pkg_install()`](https://pak.r-lib.org/reference/pkg_install.html)  |
| Mirror configuration    | [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md)                                                                    |
| Installation and checks | [`pak::pkg_install()`](https://pak.r-lib.org/reference/pkg_install.html), [`pak::pkg_status()`](https://pak.r-lib.org/reference/pkg_status.html) |
| Updates                 | `pak::pkg_update()`                                                                                                                              |

``` r
library(evanverse)
```

> **Note:** All examples are static (`eval = FALSE`). Network-dependent
> commands require internet access.

------------------------------------------------------------------------

## 1 Install evanverse

### CRAN release (recommended)

``` r
install.packages("evanverse")
```

### GitHub development version

``` r
install.packages("devtools")
devtools::install_github("evanbio/evanverse")
```

### Minimal vs full dependency install

``` r
# Minimal: Depends + Imports only
install.packages("evanverse", dependencies = c("Depends", "Imports"))

# Full: include Suggests
install.packages("evanverse", dependencies = TRUE)
```

------------------------------------------------------------------------

## 2 Configure Mirrors

### `set_mirror()` - Configure CRAN/Bioconductor mirrors

[`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md)
configures the mirrors used by R’s package system (and respected by
pak).

``` r
# Set both CRAN + Bioconductor mirrors (default mirror: tuna)
set_mirror()
#> v CRAN mirror set to: https://mirrors.tuna.tsinghua.edu.cn/CRAN
#> v Bioconductor mirror set to: https://mirrors.tuna.tsinghua.edu.cn/bioconductor

# CRAN only
set_mirror("cran", "westlake")

# Bioconductor only
set_mirror("bioc", "official")
```

Supported mirror names:

| Scope        | Mirrors                                                                                             |
|--------------|-----------------------------------------------------------------------------------------------------|
| CRAN         | `official`, `rstudio`, `tuna`, `ustc`, `aliyun`, `sjtu`, `pku`, `hku`, `westlake`, `nju`, `sustech` |
| Bioconductor | `official`, `tuna`, `ustc`, `westlake`, `nju`                                                       |

CRAN-only mirrors cannot be used with `repo = "all"`:

``` r
set_mirror("all", "aliyun")
#> Error in `set_mirror()`:
#> ! Mirror "aliyun" is CRAN-only and cannot be used with repo = "all".
```

------------------------------------------------------------------------

## 3 Installing Other Packages

We recommend [pak](https://pak.r-lib.org/) for all package installation
needs. It provides parallel installs, a unified interface for CRAN /
GitHub / Bioconductor, and automatic dependency resolution.

``` r
# Install pak first (if needed)
install.packages("pak")

# CRAN
pak::pkg_install("dplyr")

# GitHub
pak::pkg_install("hadley/emo")

# Bioconductor
pak::pkg_install("DESeq2")

# Multiple sources at once
pak::pkg_install(c("dplyr", "tidyverse/ggplot2", "bioc::DESeq2"))
```

Check status and update:

``` r
pak::pkg_status(c("ggplot2", "dplyr"))
pak::pkg_update()
```

------------------------------------------------------------------------

## 4 Troubleshooting

### Package not available

``` r
R.version.string
```

If your R version is too old, upgrade R and retry.

### Bioconductor install problems

``` r
if (!requireNamespace("BiocManager", quietly = TRUE)) {
  install.packages("BiocManager")
}
BiocManager::install(c("Biobase", "GSEABase", "biomaRt", "GEOquery"))
```

### Corporate network / proxy issues

``` r
Sys.setenv(http_proxy = "http://your-proxy:port")
Sys.setenv(https_proxy = "https://your-proxy:port")
```

### Local library permission issues

``` r
install.packages("evanverse", lib = Sys.getenv("R_LIBS_USER"))
```

------------------------------------------------------------------------

## 5 A Combined Workflow

The following sequence is practical for a fresh environment:

``` r
# 1) Install evanverse
install.packages("evanverse")
library(evanverse)

# 2) Set mirrors (especially useful in China)
set_mirror("all", "tuna")

# 3) Install packages via pak
pak::pkg_install(c("dplyr", "ggplot2"))
pak::pkg_install("bioc::DESeq2")

# 4) Verify status
pak::pkg_status(c("dplyr", "ggplot2", "DESeq2"))

# 5) Keep packages updated
pak::pkg_update()
```

------------------------------------------------------------------------

## Getting Help

- [`?set_mirror`](https://evanbio.github.io/evanverse/reference/set_mirror.md)
- [pak documentation](https://pak.r-lib.org/)
- [CRAN Package Page](https://cran.r-project.org/package=evanverse)
- [GitHub Issues](https://github.com/evanbio/evanverse/issues)
