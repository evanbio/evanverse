# evanverse

<!-- badges: start -->
[![GitHub version](https://img.shields.io/github/v/tag/evanbio/evanverse?label=version&color=success)](https://github.com/evanbio/evanverse/releases)

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
<!-- badges: end -->

**evanverse** is a modular and lightweight R package by Evan Zhou.  
It provides a flexible and expressive toolkit for daily R development, including data processing, scripting, and reproducible analysis workflows.


## Features

- 📦 Modular structure with a focus on clarity and reusability  
- 🛠️ Practical utilities for package handling, logic, and workflow automation  
- ✨ Minimal, expressive, and extensible design

## Installation

You can install the development version of `evanverse` from GitHub with:

```r
# install.packages("devtools")
# devtools::install_github("evanbio/evanverse")
```

## Usage

```r
library(evanverse)

# Example:
"Hello" %p% "world"
```

## Functions Overview

evanverse currently provides the following utility functions:

- **Package management**
  - `check_pkg()` — check if packages are installed
  - `inst_pkg()` — install packages from CRAN, GitHub, Bioconductor
  - `update_pkg()` — update packages by source

- **Logical operations**
  - `%p%` — paste two strings with space
  - `%is%` — strict identity comparison
  - `combine_logic()` — combine multiple logical vectors

- **Color conversion**
  - `hex2rgb()` — convert HEX to RGB
  - `rgb2hex()` — convert RGB to HEX

- **Visualization**
  - `plot_venn()` — draw 2–4 set Venn diagrams

- **Workflow tools**
  - `with_timer()` — wrap and time a function
  - `remind()` — show helpful R usage tips

## Documentation

Full documentation and vignettes available at:
👉 https://evanbio.github.io/evanverse/

## Contributing

This project is in active development and currently designed for personal use.  
Feedback and pull requests are welcome in future versions.

## License

MIT License © 2025 Evan Zhou

---



