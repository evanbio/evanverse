# evanverse

> A utility toolkit for R — data science & bioinformatics workflows

[![CRAN](https://www.r-pkg.org/badges/version/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse?branch=main)
[![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

---

## Overview

**evanverse** provides 50+ functions across visualization, statistical analysis, bioinformatics, and more.

## Installation

```r
install.packages("evanverse")
```

## Quick Start

```r
library(evanverse)

"Hello" %p% " " %p% "World"           # string concatenation
set_mirror("cran", "tuna")            # configure CRAN mirror
plot_venn(list(A = 1:5, B = 3:8))    # Venn diagram
quick_ttest(df, "group", "value")     # t-test with auto method selection
gene2ensembl(c("TP53", "BRCA1"))      # gene ID conversion
stat_power(n = 30, effect_size = 0.5) # power analysis
```

## Function Areas

| Area | Functions |
|---|---|
| Package management | `set_mirror()`, `pkg_functions()` — see [pak](https://pak.r-lib.org/) for install/update/check |
| Visualization | `plot_bar()`, `plot_venn()`, `plot_forest()`, `plot_pie()`, `plot_density()` |
| Statistical analysis | `quick_ttest()`, `quick_anova()`, `quick_chisq()`, `quick_cor()`, `stat_power()`, `stat_n()` |
| Color palettes | Moved to [biopalette](https://github.com/evanbio/biopalette) |
| File & download | `file_ls()`, `file_tree()`, `download_url()`, `download_geo()`, ... |
| Bioinformatics | `gene2ensembl()`, `gene2entrez()`, `gmt2df()`, `gmt2list()`, ... |
| Operators | `%p%`, `%nin%`, `%is%`, `%map%`, `%match%` |

## Documentation

- [Get Started](articles/get-started.html)
- [Function Reference](reference/index.html)
- [Vignettes](articles/index.html)

## License

MIT License © 2025–2026 Evan Zhou
