# Flexible Excel reader

Read an Excel sheet via
[`readxl::read_excel()`](https://readxl.tidyverse.org/reference/read_excel.html)
with optional column-name cleaning
([`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)),
basic type control, and CLI messages.

## Usage

``` r
read_excel_flex(
  file_path,
  sheet = 1,
  skip = 0,
  header = TRUE,
  range = NULL,
  col_types = NULL,
  clean_names = TRUE,
  guess_max = 1000,
  trim_ws = TRUE,
  na = "",
  verbose = TRUE
)
```

## Arguments

- file_path:

  Path to the Excel file (.xlsx or .xls).

- sheet:

  Sheet name or index to read (default: 1).

- skip:

  Number of lines to skip before reading data (default: 0).

- header:

  Logical. Whether the first row contains column names (default: TRUE).

- range:

  Optional cell range (e.g., `"B2:D100"`). Default: `NULL`.

- col_types:

  Optional vector specifying column types; passed to `readxl`.

- clean_names:

  Logical. Clean column names with
  [`janitor::clean_names()`](https://sfirke.github.io/janitor/reference/clean_names.html)
  (default: TRUE).

- guess_max:

  Max rows to guess column types (default: 1000).

- trim_ws:

  Logical. Trim surrounding whitespace in text fields (default: TRUE).

- na:

  Values to interpret as NA (default: `""`).

- verbose:

  Logical. Show CLI output (default: TRUE).

## Value

A tibble (or data.frame) read from the Excel sheet.
