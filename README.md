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

## ✨ Overview

**evanverse** is a comprehensive utility package designed to streamline your R workflows. Built by [Evan Zhou](mailto:evanzhou.bio@gmail.com), it combines 55+ carefully crafted functions for data analysis, visualization, and bioinformatics into a single, coherent toolkit.

### Why evanverse?

```r
# 🎯 Intuitive operators
"Hello" %p% "World"                    # → "Hello World"

# 🎨 Beautiful visualizations
plot_venn(list(A = 1:5, B = 3:8))     # Instant Venn diagrams

# 📦 Smart package management
inst_pkg("dplyr", source = "CRAN")     # Multi-source installation

# 🧬 Bioinformatics made easy
convert_gene_id(genes, from = "SYMBOL", to = "ENSEMBL")
```

---

## 🚀 Installation

### Stable Release (CRAN)

```r
install.packages("evanverse")
```

### Development Version

```r
# install.packages("devtools")
devtools::install_github("evanbio/evanverse")
```

**Requirements:** R ≥ 4.1.0

---

## 🎯 Core Features

<table>
<tr>
<td width="50%">

### 📦 Package Management
- Multi-source installation (CRAN, GitHub, Bioconductor)
- Version checking & updates
- Package function exploration
- Mirror configuration

</td>
<td width="50%">

### 🎨 Visualization
- Ready-to-use plotting functions
- Bioinformatics color palettes
- Venn diagrams, forest plots
- Bar, pie, density plots

</td>
</tr>
<tr>
<td width="50%">

### 🧬 Bioinformatics
- Gene ID conversion
- GMT file handling
- GEO data downloading
- Reference data management

</td>
<td width="50%">

### 🔧 Data Processing
- Flexible file I/O
- Column mapping utilities
- Void value handling
- Data transformations

</td>
</tr>
<tr>
<td width="50%">

### 🧮 Custom Operators
- `%p%` - String concatenation
- `%is%` - Identity comparison
- `%nin%` - Not in
- `%map%`, `%match%` - Mapping tools

</td>
<td width="50%">

### ⚙️ Workflow Tools
- Timer wrappers
- Safe execution
- Reminder system
- Interactive viewing

</td>
</tr>
</table>

---

## 💡 Quick Examples

### String Operations
```r
library(evanverse)

# Concatenate with %p%
first_name %p% " " %p% last_name

# Check if NOT in set
5 %nin% c(1, 2, 3, 4)  # TRUE
```

### Color Palettes
```r
# List available palettes
list_palettes()

# Get a palette
colors <- get_palette("celltype", n = 5)

# Preview palette
preview_palette("celltype")
```

### File Operations
```r
# Flexible table reading
data <- read_table_flex("data.csv")

# Directory tree visualization
file_tree(".", max_depth = 2)
```

### Bioinformatics Workflows
```r
# Convert gene IDs
genes <- c("TP53", "BRCA1", "EGFR")
ensembl_ids <- convert_gene_id(genes, from = "SYMBOL", to = "ENSEMBL")

# Parse GMT files
pathways <- gmt2list("pathway.gmt")
```

### Package Management
```r
# Install from multiple sources
inst_pkg(c("dplyr", "ggplot2"), source = "CRAN")
inst_pkg("limma", source = "Bioconductor")
inst_pkg("user/repo", source = "GitHub")

# Check versions
pkg_version("evanverse")
```

---

## 📖 Function Categories

<details>
<summary><b>📦 Package Management</b> (6 functions)</summary>

- `check_pkg()` - Check if packages are installed
- `inst_pkg()` - Install packages from multiple sources
- `update_pkg()` - Update installed packages
- `pkg_version()` - Get package version
- `pkg_functions()` - List package functions
- `set_mirror()` - Configure CRAN mirror

</details>

<details>
<summary><b>🎨 Visualization & Plotting</b> (5 functions)</summary>

- `plot_venn()` - Venn diagrams
- `plot_forest()` - Forest plots
- `plot_bar()` - Bar charts
- `plot_pie()` - Pie charts
- `plot_density()` - Density plots

</details>

<details>
<summary><b>🌈 Color Palettes</b> (9 functions)</summary>

- `get_palette()` - Retrieve color palette
- `list_palettes()` - List available palettes
- `create_palette()` - Create custom palette
- `preview_palette()` - Preview palette colors
- `bio_palette_gallery()` - Browse bio palettes
- `compile_palettes()` - Compile palette data
- `remove_palette()` - Remove palette
- `hex2rgb()` - Convert hex to RGB
- `rgb2hex()` - Convert RGB to hex

</details>

<details>
<summary><b>📁 File & Data I/O</b> (10 functions)</summary>

- `read_table_flex()` - Flexible table reading
- `read_excel_flex()` - Flexible Excel reading
- `write_xlsx_flex()` - Flexible Excel writing
- `download_url()` - Download from URL
- `download_batch()` - Batch downloads
- `download_geo_data()` - Download GEO datasets
- `file_info()` - File information
- `file_tree()` - Directory tree
- `get_ext()` - Get file extension
- `view()` - Interactive data viewer

</details>

<details>
<summary><b>🧬 Bioinformatics</b> (4 functions)</summary>

- `convert_gene_id()` - Gene ID conversion
- `download_gene_ref()` - Download gene references
- `gmt2df()` - GMT to data frame
- `gmt2list()` - GMT to list

</details>

<details>
<summary><b>🔧 Data Processing</b> (10 functions)</summary>

- `df2list()` - Data frame to list
- `map_column()` - Map column values
- `is_void()` - Check for void values
- `any_void()` - Any void values
- `drop_void()` - Remove void values
- `replace_void()` - Replace void values
- `cols_with_void()` - Columns with voids
- `rows_with_void()` - Rows with voids

</details>

<details>
<summary><b>🧮 Operators & Logic</b> (8 functions)</summary>

- `%p%` - String concatenation operator
- `%is%` - Identity comparison
- `%nin%` - Not in operator
- `%map%` - Mapping operator
- `%match%` - Match operator
- `combine_logic()` - Combine logical vectors
- `comb()` - Combinations
- `perm()` - Permutations

</details>

<details>
<summary><b>⚙️ Workflow Tools</b> (3 functions)</summary>

- `with_timer()` - Execute with timing
- `remind()` - Set reminders
- `safe_execute()` - Safe function execution

</details>

---

## 📚 Documentation

Complete documentation with examples and vignettes:

👉 **[https://evanbio.github.io/evanverse/](https://evanbio.github.io/evanverse/)**

---

## 🤝 Contributing

We welcome contributions! Please see our [Contributing Guide](CONTRIBUTING.md) for details.

- 🐛 [Report bugs](https://github.com/evanbio/evanverse/issues/new?template=bug_report.yml)
- 💡 [Request features](https://github.com/evanbio/evanverse/issues/new?template=feature_request.yml)
- 📖 [Improve docs](https://github.com/evanbio/evanverse/issues/new?template=documentation.yml)
- ❓ [Ask questions](https://github.com/evanbio/evanverse/issues/new?template=question.yml)

---

## 📜 License

MIT License © 2025 [Evan Zhou](mailto:evanzhou.bio@gmail.com)

See [LICENSE.md](LICENSE.md) for details.

---

## 📊 Project Status

- ✅ **CRAN Published** - Version 0.3.7
- ✅ **Stable Lifecycle** - Production ready
- ✅ **Full Test Coverage** - Comprehensive test suite
- ✅ **Active Maintenance** - Regular updates

---

<div align="center">

**Made with ❤️ by [Evan Zhou](https://github.com/evanbio)**

[⬆ Back to Top](#evanverse)

</div>
