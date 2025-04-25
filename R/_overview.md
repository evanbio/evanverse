# 📦 evanverse Function Overview

This document provides a categorized overview of all functions in the `R/` directory of the **evanverse** package.  
It helps developers and users quickly understand the available tools and their respective files.

---

## 🧩 Data Handling

| Function         | Description                                                | File               |
|------------------|------------------------------------------------------------|--------------------|
| `df2list()`       | Group a data frame by a key column and aggregate values as lists | df2list.R          |
| `map_column()`    | Map values in a column using a named vector                | map_column.R       |
| `read_table_flex()` | Flexibly read tabular data from various formats          | read_table_flex.R  |
| `replace_void()`  | Replace NA, NULL, or empty strings with a specified value  | replace_void.R     |
| `drop_void()`     | Drop rows or columns with void values                      | drop_void.R        |
| `cols_with_void()`| Identify columns with any void values                      | cols_with_void.R   |
| `rows_with_void()`| Identify rows with any void values                         | rows_with_void.R   |
| `any_void()`      | Check if any element in a vector is void                   | any_void.R         |
| `is_void()`       | Check if a value is void                                   | is_void.R          |
| `%is%`, `%nin%`, `%p%`, `%match%`, `%map%` | Custom infix operators for flexible filtering | percent_*_operator.R |

---

## 🎨 Visualization & Palettes

| Function              | Description                                      | File                   |
|------------------------|--------------------------------------------------|------------------------|
| `plot_venn()`           | Draw a 2–4-set Venn diagram (classic/gradient)  | plot_venn.R            |
| `plot_pie()`            | Simple labeled pie chart                        | plot_pie.R             |
| `bio_palette_gallery()` | Display all available palettes in the system    | bio_palette_gallery.R  |
| `get_palette()`         | Retrieve a palette by name and type             | get_palette.R          |
| `compile_palettes()`    | Compile JSON palettes into RDS format           | compile_palettes.R     |
| `create_palette()`      | Generate a custom named palette                 | create_palette.R       |
| `preview_palette()`     | Preview colors in a palette                     | preview_palette.R      |
| `list_palettes()`       | List all palettes stored in the package         | list_palettes.R        |

---

## 🧬 Gene & Pathway Utilities

| Function        | Description                                | File           |
|------------------|--------------------------------------------|----------------|
| `gmt2df()`        | Convert a .gmt file to a data frame        | gmt2df.R       |
| `gmt2list()`      | Convert a .gmt file to a named list        | gmt2list.R     |
| `convert_gene_id()` | Convert gene identifiers between types   | convert_gene_id.R |
| `download_gene_ref()`| Download reference gene annotation      | download_gene_ref.R |

---

## 📦 Package Management

| Function        | Description                                  | File           |
|------------------|----------------------------------------------|----------------|
| `update_pkg()`    | Update packages from CRAN, GitHub, Bioc      | update_pkg.R   |
| `check_pkg()`     | Check if required packages are installed     | check_pkg.R    |
| `inst_pkg()`      | Install packages with automatic source logic | inst_pkg.R     |
| `pkg_version()`   | Get the installed version of a package       | pkg_version.R  |

---

## 🧰 Utility Tools

| Function        | Description                                  | File             |
|------------------|----------------------------------------------|------------------|
| `file_tree()`     | Display a directory tree                    | file_tree.R      |
| `file_info()`     | Get file metadata like size and date        | file_info.R      |
| `get_ext()`       | Extract file extension                      | get_ext.R        |
| `download_url()`  | Download file from a URL                    | download_url.R   |
| `remind()`        | Print styled messages to the console        | remind.R         |
| `with_timer()`    | Time execution of an expression             | with_timer.R     |

---

## 📦 Package Internal Files

| File                  | Purpose                        |
|------------------------|--------------------------------|
| `evanverse-package.R` | Package-level documentation    |
| `zzz.R`               | Initialization hooks (e.g. .onLoad) |

---

🗂 *This overview was auto-curated on 2025-04-24.*
