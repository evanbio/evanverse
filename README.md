<div align="center">

<img src="man/figures/logo.png" width="180" alt="evanverse logo" />

# evanverse

### *A Modern R Toolkit for Data Science & Bioinformatics*

[![CRAN](https://www.r-pkg.org/badges/version/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse?branch=main)
[![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/evanverse)](https://CRAN.R-project.org/package=evanverse)

[📚 Documentation](https://evanbio.github.io/evanverse/) •
[🚀 Getting Started](https://evanbio.github.io/evanverse/articles/get-started.html) •
[💬 Issues](https://github.com/evanbio/evanverse/issues) •
[🤝 Contributing](CONTRIBUTING.md)

---

**Languages:** English | [简体中文](README_zh.md)

</div>

---

## Overview

**evanverse** is a utility toolkit for R providing ~50 functions across package management, data visualization, statistical testing, bioinformatics, and more. Built by [Evan Zhou](mailto:evanzhou.bio@gmail.com).

```r
library(evanverse)

"Hello" %p% " " %p% "World"           # string concatenation
inst_pkg("limma", source = "Bioc")    # multi-source package install
plot_venn(list(A = 1:5, B = 3:8))    # instant Venn diagram
quick_ttest(df, "group", "value")     # t-test with auto assumption check
gene2ensembl(c("TP53", "BRCA1"))      # gene ID conversion
```

---

## Installation

```r
# Stable release (CRAN)
install.packages("evanverse")

# Development version
devtools::install_github("evanbio/evanverse")
```

**Requires:** R ≥ 4.1.0

---

## Function Reference

<details>
<summary><b>📦 Package Management</b> (6)</summary>

- `check_pkg()` — check if packages are installed
- `inst_pkg()` — install from CRAN / GitHub / Bioconductor
- `update_pkg()` — update installed packages
- `pkg_version()` — get package version
- `pkg_functions()` — list functions in a package
- `set_mirror()` — configure CRAN mirror

</details>

<details>
<summary><b>🎨 Visualization</b> (5)</summary>

- `plot_venn()` — Venn diagrams
- `plot_forest()` — forest plots
- `plot_bar()` — bar charts
- `plot_pie()` — pie charts
- `plot_density()` — density plots

</details>

<details>
<summary><b>📊 Statistical Analysis</b> (6)</summary>

- `quick_ttest()` — t-test with automatic method selection
- `quick_anova()` — one-way ANOVA with post-hoc tests
- `quick_chisq()` — chi-square / Fisher exact test
- `quick_cor()` — correlation analysis with heatmap
- `stat_power()` — statistical power analysis
- `stat_n()` — sample size calculation

</details>

<details>
<summary><b>🌈 Color Palettes</b> (9)</summary>

- `get_palette()` — retrieve a palette
- `list_palettes()` — list available palettes
- `create_palette()` — create a custom palette
- `preview_palette()` — preview palette colors
- `palette_gallery()` — browse all palettes
- `compile_palettes()` — compile palette data
- `remove_palette()` — remove a palette
- `hex2rgb()` / `rgb2hex()` — color conversion

</details>

<details>
<summary><b>📁 File & Download</b> (7)</summary>

- `download_url()` — download a single URL
- `download_batch()` — batch downloads
- `download_geo()` — download GEO datasets
- `file_info()` — file metadata
- `file_ls()` — list files with metadata
- `file_tree()` — directory tree visualization
- `view()` — interactive data viewer

</details>

<details>
<summary><b>🧬 Bioinformatics</b> (5)</summary>

- `gene2ensembl()` — convert gene symbols to Ensembl IDs
- `gene2entrez()` — convert gene symbols to Entrez IDs
- `download_gene_ref()` — download gene reference table
- `gmt2df()` — parse GMT to data frame
- `gmt2list()` — parse GMT to list

</details>

<details>
<summary><b>🔧 Data Processing</b> (3)</summary>

- `df2list()` — data frame to named list
- `df2vect()` — data frame column to named vector
- `recode_column()` — recode column values by mapping

</details>

<details>
<summary><b>🧮 Operators & Combinatorics</b> (7)</summary>

- `%p%` — string concatenation
- `%is%` — identity check
- `%nin%` — not-in operator
- `%map%` — mapping operator
- `%match%` — match operator
- `comb()` — combinations
- `perm()` — permutations

</details>

<details>
<summary><b>🧪 Toy Data</b> (2)</summary>

- `toy_gene_ref()` — small gene reference table for testing
- `toy_gmt()` — small GMT file for testing

</details>

---

## Documentation

Full documentation, vignettes, and function reference:

👉 **[https://evanbio.github.io/evanverse/](https://evanbio.github.io/evanverse/)**

---

## License

MIT License © 2025–2026 [Evan Zhou](mailto:evanzhou.bio@gmail.com)

<div align="center">

**Made with ❤️ by [Evan Zhou](https://github.com/evanbio)**

</div>
