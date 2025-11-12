# Flexible and fast table reader using data.table::fread

Robust table reader with auto delimiter detection for `.csv`, `.tsv`,
`.txt`, and their `.gz` variants. Uses
[`data.table::fread()`](https://rdatatable.gitlab.io/data.table/reference/fread.html)
and prints CLI messages.

## Usage

``` r
read_table_flex(
  file_path,
  sep = NULL,
  encoding = "UTF-8",
  header = TRUE,
  df = TRUE,
  verbose = FALSE
)
```

## Arguments

- file_path:

  Character. Path to the file to be read.

- sep:

  Optional. Field delimiter. If `NULL`, auto-detected by file extension.

- encoding:

  Character. File encoding accepted by fread: "unknown", "UTF-8", or
  "Latin-1".

- header:

  Logical. Whether the file contains a header row. Default: `TRUE`.

- df:

  Logical. Return data.frame instead of data.table. Default: `TRUE`.

- verbose:

  Logical. Show progress and details. Default: `FALSE`.

## Value

A `data.frame` (default) or `data.table` depending on `df` parameter.
