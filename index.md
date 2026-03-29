# evanverse

> A utility toolkit for R — data science & bioinformatics workflows

[![CRAN](https://www.r-pkg.org/badges/version/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse?branch=main)
[![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

------------------------------------------------------------------------

## Overview

**evanverse** provides ~50 functions across package management,
visualization, statistical analysis, bioinformatics, and more.

## Installation

``` r
install.packages("evanverse")
```

## Quick Start

``` r
library(evanverse)

"Hello" %p% " " %p% "World"           # string concatenation
inst_pkg("limma", source = "Bioc")    # multi-source install
plot_venn(list(A = 1:5, B = 3:8))    # Venn diagram
quick_ttest(df, "group", "value")     # t-test with auto method selection
gene2ensembl(c("TP53", "BRCA1"))      # gene ID conversion
stat_power(n = 30, effect_size = 0.5) # power analysis
```

## Function Areas

| Area                 | Functions                                                                                                                                                                                                                                                                                                                                                                                                                                                                            |
|----------------------|--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Package management   | [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md), [`check_pkg()`](https://evanbio.github.io/evanverse/reference/check_pkg.md), [`update_pkg()`](https://evanbio.github.io/evanverse/reference/update_pkg.md), [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md), …                                                                                                                                                              |
| Visualization        | [`plot_bar()`](https://evanbio.github.io/evanverse/reference/plot_bar.md), [`plot_venn()`](https://evanbio.github.io/evanverse/reference/plot_venn.md), [`plot_forest()`](https://evanbio.github.io/evanverse/reference/plot_forest.md), [`plot_pie()`](https://evanbio.github.io/evanverse/reference/plot_pie.md), [`plot_density()`](https://evanbio.github.io/evanverse/reference/plot_density.md)                                                                                |
| Statistical analysis | [`quick_ttest()`](https://evanbio.github.io/evanverse/reference/quick_ttest.md), [`quick_anova()`](https://evanbio.github.io/evanverse/reference/quick_anova.md), [`quick_chisq()`](https://evanbio.github.io/evanverse/reference/quick_chisq.md), [`quick_cor()`](https://evanbio.github.io/evanverse/reference/quick_cor.md), [`stat_power()`](https://evanbio.github.io/evanverse/reference/stat_power.md), [`stat_n()`](https://evanbio.github.io/evanverse/reference/stat_n.md) |
| Color palettes       | [`get_palette()`](https://evanbio.github.io/evanverse/reference/get_palette.md), [`create_palette()`](https://evanbio.github.io/evanverse/reference/create_palette.md), [`preview_palette()`](https://evanbio.github.io/evanverse/reference/preview_palette.md), [`palette_gallery()`](https://evanbio.github.io/evanverse/reference/palette_gallery.md), …                                                                                                                          |
| File & download      | [`file_ls()`](https://evanbio.github.io/evanverse/reference/file_ls.md), [`file_tree()`](https://evanbio.github.io/evanverse/reference/file_tree.md), [`download_url()`](https://evanbio.github.io/evanverse/reference/download_url.md), [`download_geo()`](https://evanbio.github.io/evanverse/reference/download_geo.md), …                                                                                                                                                        |
| Bioinformatics       | [`gene2ensembl()`](https://evanbio.github.io/evanverse/reference/gene2ensembl.md), [`gene2entrez()`](https://evanbio.github.io/evanverse/reference/gene2entrez.md), [`gmt2df()`](https://evanbio.github.io/evanverse/reference/gmt2df.md), [`gmt2list()`](https://evanbio.github.io/evanverse/reference/gmt2list.md), …                                                                                                                                                              |
| Operators            | `%p%`, `%nin%`, `%is%`, `%map%`, `%match%`                                                                                                                                                                                                                                                                                                                                                                                                                                           |

## Documentation

- [Get
  Started](https://evanbio.github.io/evanverse/articles/get-started.md)
- [Function
  Reference](https://evanbio.github.io/evanverse/reference/index.md)
- [Vignettes](https://evanbio.github.io/evanverse/articles/index.md)

## License

MIT License © 2025–2026 Evan Zhou
