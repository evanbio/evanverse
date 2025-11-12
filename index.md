# evanverse

> A comprehensive R utility package for data science and bioinformatics
> workflows

[![CRAN](https://www.r-pkg.org/badges/version/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse?branch=main)
[![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

------------------------------------------------------------------------

## Overview

**evanverse** provides 55+ utility functions designed to streamline R
workflows across data analysis, visualization, and bioinformatics. Built
with a focus on simplicity and reproducibility.

## Installation

``` r
# Stable release from CRAN
install.packages("evanverse")

# Development version from GitHub
devtools::install_github("evanbio/evanverse")
```

**Requirements:** R ≥ 4.1.0

## Key Features

**Package Management** — Multi-source installation (CRAN, GitHub,
Bioconductor), version checking, and automated updates

**Data Visualization** — Publication-ready plots with
bioinformatics-focused color palettes and professional themes

**Bioinformatics Tools** — Gene ID conversion, GMT file parsing, GEO
data access, and reference management

**Data Processing** — Flexible I/O, void value handling, column mapping,
and data transformations

**Custom Operators** — Intuitive infix operators for string
manipulation, set operations, and data mapping

**Workflow Utilities** — Timer wrappers, safe execution, and
productivity-enhancing development tools

## Quick Start

``` r
library(evanverse)

# String concatenation with %p%
"Hello" %p% " " %p% "World"  # → "Hello World"

# Install packages from multiple sources
inst_pkg("dplyr", source = "CRAN")
inst_pkg("limma", source = "Bioconductor")

# Create professional visualizations
plot_venn(list(A = 1:5, B = 3:8))

# Convert gene identifiers
convert_gene_id(c("TP53", "BRCA1"), from = "SYMBOL", to = "ENSEMBL")
```

## Documentation

- **[Getting Started
  Guide](https://evanbio.github.io/evanverse/articles/get-started.md)**
  — Installation and basic usage
- **[Comprehensive
  Guide](https://evanbio.github.io/evanverse/articles/comprehensive-guide.md)**
  — Complete feature overview
- **[Function
  Reference](https://evanbio.github.io/evanverse/reference/index.md)** —
  Detailed API documentation
- **[Vignettes](https://evanbio.github.io/evanverse/articles/index.md)**
  — Topic-specific tutorials

## Getting Help

- Browse the [function
  reference](https://evanbio.github.io/evanverse/reference/index.md) for
  detailed documentation
- Read
  [vignettes](https://evanbio.github.io/evanverse/articles/index.md) for
  comprehensive examples
- Report issues on [GitHub](https://github.com/evanbio/evanverse/issues)

## License

MIT License © 2025 Evan Zhou
