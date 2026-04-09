# Package Management

## Overview

The pkg module provides two functions:

| Function                                                                            | Purpose                                            |
|-------------------------------------------------------------------------------------|----------------------------------------------------|
| [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md)       | Configure CRAN / Bioconductor download mirrors     |
| [`pkg_functions()`](https://evanbio.github.io/evanverse/reference/pkg_functions.md) | List exported functions from any installed package |

For installation, updates, and status checks, we recommend
[pak](https://pak.r-lib.org/) — it provides a more elegant and
performant workflow with parallel downloads and a unified interface for
CRAN, GitHub, and Bioconductor.

``` r
library(evanverse)
```

> **Note:** All code examples in this vignette are static
> (`eval = FALSE`).

------------------------------------------------------------------------

## 1 Mirror Configuration

### `set_mirror()` — Set CRAN and Bioconductor mirrors

Configures the CRAN and/or Bioconductor download mirrors. Settings are
respected by R’s native install functions and by pak. The previous
settings are returned invisibly, making it easy to restore them.

``` r
# Set both mirrors to Tsinghua (default)
set_mirror()
#> v CRAN mirror set to: https://mirrors.tuna.tsinghua.edu.cn/CRAN
#> v Bioconductor mirror set to: https://mirrors.tuna.tsinghua.edu.cn/bioconductor

# CRAN only
set_mirror("cran", "ustc")
#> v CRAN mirror set to: https://mirrors.ustc.edu.cn/CRAN

# Bioconductor only
set_mirror("bioc", "nju")
#> v Bioconductor mirror set to: https://mirrors.nju.edu.cn/bioconductor
```

Available mirrors:

| Mirror     | CRAN | Bioconductor |
|------------|:----:|:------------:|
| `official` |  v   |      v       |
| `tuna`     |  v   |      v       |
| `ustc`     |  v   |      v       |
| `westlake` |  v   |      v       |
| `nju`      |  v   |      v       |
| `rstudio`  |  v   |      \-      |
| `aliyun`   |  v   |      \-      |
| `sjtu`     |  v   |      \-      |
| `pku`      |  v   |      \-      |
| `hku`      |  v   |      \-      |
| `sustech`  |  v   |      \-      |

CRAN-only mirrors cannot be used with `repo = "all"`:

``` r
set_mirror("all", "aliyun")
#> Error in `set_mirror()`:
#> ! Mirror "aliyun" is CRAN-only and cannot be used with `repo = "all"`.
#> i Use `set_mirror("cran", "aliyun")` instead.
#> i Shared mirrors: "official", "tuna", "ustc", "westlake", "nju"
```

The previous settings are returned invisibly for easy restoration:

``` r
prev <- set_mirror("cran", "tuna")
# ... do work ...
options(prev)  # restore original mirror
```

------------------------------------------------------------------------

## 2 Package Exploration

### `pkg_functions()` — List exported functions

Returns an alphabetically sorted character vector of exported symbols
from any installed package. Use `key` to filter by a case-insensitive
keyword.

``` r
pkg_functions("evanverse")
#>  [1] "compile_palettes" "create_palette"  "df2list"
#>  [4] "df2vect"          "file_info"        "file_ls"
#>  ...
```

``` r
# Filter by keyword (case-insensitive)
pkg_functions("evanverse", key = "palette")
#> [1] "compile_palettes" "create_palette"   "get_palette"
#> [4] "list_palettes"    "palette_gallery"  "preview_palette"
#> [7] "remove_palette"

pkg_functions("stats", key = "test")
#> [1] "ansari.test"   "bartlett.test" "binom.test"
#> [4] "chisq.test"    "cor.test"      "fisher.test"
#> ...
```

An unmatched keyword returns an empty vector rather than an error:

``` r
pkg_functions("stats", key = "zzzzzz")
#> character(0)
```

Querying an uninstalled package raises an informative error:

``` r
pkg_functions("somefakepkg")
#> Error in `pkg_functions()`:
#> ! Package `somefakepkg` is not installed.
```

------------------------------------------------------------------------

## 3 Recommended: pak for Installation & Updates

We found that [pak](https://pak.r-lib.org/) provides a more elegant and
performant package management workflow. It supports parallel
installation, automatic dependency resolution, and a unified interface
for all package sources — which is why `inst_pkg()`, `check_pkg()`,
`update_pkg()`, and `pkg_version()` were removed from evanverse.

``` r
# Install pak
install.packages("pak")

# Set a fast mirror first (evanverse)
set_mirror("all", "tuna")

# Install from any source with a unified interface
pak::pkg_install("ggplot2")                              # CRAN
pak::pkg_install("tidyverse/ggplot2")                    # GitHub
pak::pkg_install("bioc::DESeq2")                         # Bioconductor
pak::pkg_install(c("dplyr", "bioc::limma", "r-lib/pak")) # mixed

# Check status
pak::pkg_status(c("ggplot2", "DESeq2"))

# Update all or specific packages
pak::pkg_update()
pak::pkg_update("ggplot2")
```

------------------------------------------------------------------------

## Getting Help

- [`?set_mirror`](https://evanbio.github.io/evanverse/reference/set_mirror.md)
- [`?pkg_functions`](https://evanbio.github.io/evanverse/reference/pkg_functions.md)
- [pak documentation](https://pak.r-lib.org/)
- [GitHub Issues](https://github.com/evanbio/evanverse/issues)
