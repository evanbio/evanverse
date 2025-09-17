# 📦 evanverse Function Overview

This document provides a categorized overview of all functions in the `R/` directory of the **evanverse** package.
It helps developers and users quickly understand the available tools and their respective files.

**Total Functions: 55+** | **Last Updated: 2025-09-17**

---

## 📦 Package Management
*Multi-source package installation and management tools*

| Function        | Description                                  | File           |
|------------------|----------------------------------------------|----------------|
| `inst_pkg()`      | Install packages with automatic source detection (CRAN, GitHub, Bioconductor) | inst_pkg.R     |
| `check_pkg()`     | Check if required packages are installed     | check_pkg.R    |
| `update_pkg()`    | Update packages from CRAN, GitHub, Bioc      | update_pkg.R   |
| `pkg_version()`   | Get the installed version of a package       | pkg_version.R  |
| `pkg_functions()` | List all functions exported by a package     | pkg_functions.R |
| `set_mirror()`    | Set CRAN mirror for package installation     | set_mirror.R   |

---

## 📊 Visualization & Plotting
*High-level plotting functions with sensible defaults*

| Function              | Description                                      | File                   |
|------------------------|--------------------------------------------------|------------------------|
| `plot_venn()`           | Draw 2–4-set Venn diagrams with customizable styles | plot_venn.R            |
| `plot_bar()`            | Create bar plots with flexible styling options  | plot_bar.R             |
| `plot_pie()`            | Generate labeled pie charts                     | plot_pie.R             |
| `plot_density()`        | Create density plots for distribution comparison | plot_density.R         |
| `plot_forest()`         | Generate forest plots for meta-analysis         | plot_forest.R          |

---

## 🎨 Color Palettes & Management
*Bioinformatics-focused color palette system*

| Function              | Description                                      | File                   |
|------------------------|--------------------------------------------------|------------------------|
| `get_palette()`         | Retrieve a palette by name and type             | get_palette.R          |
| `list_palettes()`       | List all available palettes with details        | list_palettes.R        |
| `create_palette()`      | Generate and save custom named palettes         | create_palette.R       |
| `preview_palette()`     | Preview colors in a palette visually            | preview_palette.R      |
| `remove_palette()`      | Remove a custom palette from storage            | remove_palette.R       |
| `bio_palette_gallery()` | Display comprehensive palette gallery           | bio_palette_gallery.R  |
| `compile_palettes()`    | Compile JSON palettes into RDS format           | compile_palettes.R     |
| `hex2rgb()`             | Convert hex colors to RGB format                | hex2rgb.R              |
| `rgb2hex()`             | Convert RGB colors to hex format                | rgb2hex.R              |

---

## 💾 File & Data I/O
*Flexible file operations with enhanced error handling*

| Function              | Description                                      | File                   |
|------------------------|--------------------------------------------------|------------------------|
| `read_table_flex()`     | Flexibly read tabular data from various formats | read_table_flex.R      |
| `read_excel_flex()`     | Enhanced Excel file reading with error recovery | read_excel_flex.R      |
| `write_xlsx_flex()`     | Write data to Excel with flexible options       | write_xlsx_flex.R      |
| `download_url()`        | Download files from URLs with progress tracking | download_url.R         |
| `download_batch()`      | Batch download multiple files efficiently       | download_batch.R       |
| `download_geo_data()`   | Download GEO datasets with metadata             | download_geo_data.R    |
| `file_info()`           | Get detailed file metadata (size, dates, etc.)  | file_info.R            |
| `file_tree()`           | Display directory structure as a tree           | file_tree.R            |
| `get_ext()`             | Extract file extension from file paths          | get_ext.R              |
| `view()`                | Enhanced data viewing with automatic formatting | view.R                 |

---

## 🧬 Bioinformatics Utilities
*Specialized tools for genomic data processing*

| Function        | Description                                | File           |
|------------------|--------------------------------------------|----------------|
| `convert_gene_id()` | Convert gene identifiers between different annotation systems | convert_gene_id.R |
| `download_gene_ref()`| Download reference gene annotation databases | download_gene_ref.R |
| `gmt2df()`        | Convert GMT gene set files to data frames   | gmt2df.R       |
| `gmt2list()`      | Convert GMT gene set files to named lists   | gmt2list.R     |

---

## 🔄 Data Processing & Transformation
*Tools for data manipulation and void value handling*

| Function         | Description                                                | File               |
|------------------|------------------------------------------------------------|--------------------|
| `df2list()`       | Group data frame by key column and aggregate as lists     | df2list.R          |
| `map_column()`    | Map values in columns using named vectors                 | map_column.R       |
| `is_void()`       | Check if values are void (NA, NULL, empty strings)        | is_void.R          |
| `any_void()`      | Check if any element in a vector is void                  | any_void.R         |
| `replace_void()`  | Replace void values with specified replacements           | replace_void.R     |
| `drop_void()`     | Remove rows/columns containing void values                 | drop_void.R        |
| `cols_with_void()`| Identify columns containing any void values               | cols_with_void.R   |
| `rows_with_void()`| Identify rows containing any void values                  | rows_with_void.R   |

---

## ⚡ Operators & Logic
*Custom infix operators and logical utilities*

| Function         | Description                                                | File               |
|------------------|------------------------------------------------------------|--------------------|
| `%is%`           | Enhanced identity checking operator                        | percent_is_operator.R |
| `%nin%`          | "Not in" operator (opposite of %in%)                      | percent_nin_operator.R |
| `%p%`            | Paste operator for string concatenation                   | percent_p_operator.R |
| `%match%`        | Pattern matching operator                                  | percent_match_operator.R |
| `%map%`          | Mapping operator for transformations                      | percent_map_operator.R |
| `combine_logic()` | Combine multiple logical conditions                       | combine_logic.R    |
| `comb()`         | Generate combinations (n choose k)                        | comb.R             |
| `perm()`         | Generate permutations                                      | perm.R             |

---

## 🛠️ Workflow & Development Tools
*Productivity enhancing utilities for development*

| Function        | Description                                  | File             |
|------------------|----------------------------------------------|------------------|
| `with_timer()`    | Time execution of expressions with reporting | with_timer.R     |
| `remind()`        | Print styled console messages with formatting | remind.R         |
| `safe_execute()`  | Execute code with comprehensive error handling | safe_execute.R   |

---

## 📋 Data Documentation
*Internal data documentation and metadata*

| File                  | Purpose                        |
|------------------------|--------------------------------|
| `data_documentation.R` | Documentation for package datasets |
| `evanverse-package.R` | Package-level documentation and imports |
| `zzz.R`               | Package initialization hooks (.onLoad, .onAttach) |
| `_overview.md`        | This comprehensive function overview |

---

## 📈 Function Categories Summary

- **📦 Package Management**: 6 functions - Multi-source installation and management
- **📊 Visualization & Plotting**: 5 functions - Publication-ready charts and plots
- **🎨 Color Palettes**: 9 functions - Comprehensive color management system
- **💾 File & Data I/O**: 10 functions - Robust file operations with error handling
- **🧬 Bioinformatics**: 4 functions - Genomic data processing utilities
- **🔄 Data Processing**: 8 functions - Data transformation and void handling
- **⚡ Operators & Logic**: 8 functions - Custom operators and logical utilities
- **🛠️ Development Tools**: 3 functions - Workflow enhancement utilities

**Total: 53 exported functions across 56 R files**

---

*📅 Last updated: September 17, 2025*
*🔄 Auto-generated from R/ directory analysis*