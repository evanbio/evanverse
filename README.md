# evanverse: Utility Functions for Data Analysis and Visualization

<!-- badges: start -->
[![CRAN status](https://www.r-pkg.org/badges/version/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![CRAN downloads (monthly)](https://cranlogs.r-pkg.org/badges/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![CRAN checks](https://badges.cranchecks.info/worst/evanverse.svg)](https://cran.r-project.org/web/checks/check_results_evanverse.html)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
[![Codecov test coverage](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse?branch=main)
[![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![GitHub last commit](https://img.shields.io/github/last-commit/evanbio/evanverse)](https://github.com/evanbio/evanverse/commits/main)
[![GitHub issues](https://img.shields.io/github/issues/evanbio/evanverse)](https://github.com/evanbio/evanverse/issues)
[![Dependencies](https://img.shields.io/badge/dependencies-10%20imports%20|%2015%20suggests-blue)](https://CRAN.R-project.org/package=evanverse)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
[![R version](https://img.shields.io/badge/R-%E2%89%A5%204.1.0-blue)](https://www.r-project.org/)
<img src="man/figures/logo.png" align="right" width="120" />
<!-- badges: end -->

<br>

**evanverse** is a comprehensive R utility package by Evan Zhou that provides a unified toolkit for data analysis, visualization, and bioinformatics workflows. It combines practical functions for package management, data processing, color palettes, plotting, and workflow automation.

## Features

- 📦 **Package Management**: Multi-source installation (CRAN, GitHub, Bioconductor), version checking, and updates
- 🎨 **Color & Visualization**: Bioinformatics color palettes, plotting functions (Venn, forest, bar, pie, density)
- 🔧 **Data Processing**: Flexible file I/O, gene ID conversion, void value handling, column mapping
- 🧮 **Operators & Logic**: Custom infix operators (%p%, %is%, %nin%, %map%, %match%), logical utilities
- 🌐 **Download & Network**: URL downloading with retry, GEO data fetching, batch operations
- ⚙️ **Workflow Tools**: Timing, reminders, safe execution, interactive viewing

## Installation

### 🚀 CRAN (Recommended)

`evanverse` is now available on CRAN! Install the stable release with:

```r
install.packages("evanverse")
```

### 📦 Development Version

You can install the latest development version from GitHub:

```r
# install.packages("devtools")
devtools::install_github("evanbio/evanverse")
```

> **CRAN Release**: Version 0.3.7 is now published on CRAN (Windows support confirmed). This release ensures full CRAN compliance with file operation policies and maintains perfect check results (0 errors, 0 warnings, 0 notes).

## Usage

```r
library(evanverse)

# Quick examples
"Hello" %p% "world"              # String concatenation
c(1, 2, NA) %is% c(1, 2, NA)     # Identity comparison
file_tree(".")                   # View project structure
```

## Functions Overview

evanverse v0.3.7 provides 55+ utility functions organized by category:

### 📦 Package Management
- `check_pkg()`, `inst_pkg()`, `update_pkg()`, `pkg_version()`, `pkg_functions()`, `set_mirror()`

### 🎨 Visualization & Plotting
- `plot_venn()`, `plot_forest()`, `plot_bar()`, `plot_pie()`, `plot_density()`

### 🌈 Color Palettes
- `get_palette()`, `list_palettes()`, `create_palette()`, `preview_palette()`, `bio_palette_gallery()`, `compile_palettes()`, `remove_palette()`
- `hex2rgb()`, `rgb2hex()`

### 📁 File & Data I/O
- `read_table_flex()`, `read_excel_flex()`, `write_xlsx_flex()`, `download_url()`, `download_batch()`, `download_geo_data()`
- `file_info()`, `file_tree()`, `get_ext()`, `view()`

### 🧬 Bioinformatics
- `convert_gene_id()`, `download_gene_ref()`, `gmt2df()`, `gmt2list()`

### 🔧 Data Processing
- `df2list()`, `map_column()`, `is_void()`, `any_void()`, `drop_void()`, `replace_void()`, `cols_with_void()`, `rows_with_void()`

### 🧮 Operators & Logic
- `%p%`, `%is%`, `%nin%`, `%map%`, `%match%`
- `combine_logic()`, `comb()`, `perm()`

### ⚙️ Workflow Tools
- `with_timer()`, `remind()`, `safe_execute()`

## Documentation

Full documentation and vignettes available at:
👉 https://evanbio.github.io/evanverse/

## Contributing

This project is in active development and currently designed for personal use.  
Feedback and pull requests are welcome in future versions.

## License

MIT License © 2025 Evan Zhou

---



