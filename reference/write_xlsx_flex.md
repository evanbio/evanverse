# Flexible Excel writer

Write a data frame or a **named** list of data frames to an Excel file
with optional styling.

## Usage

``` r
write_xlsx_flex(
  data,
  file_path,
  overwrite = TRUE,
  timestamp = FALSE,
  with_style = TRUE,
  auto_col_width = TRUE,
  open_after = FALSE,
  verbose = TRUE
)
```

## Arguments

- data:

  A data.frame, or a **named** list of data.frames.

- file_path:

  Output path to a `.xlsx` file.

- overwrite:

  Whether to overwrite if the file exists. Default: TRUE.

- timestamp:

  Whether to append a date suffix (`YYYY-MM-DD`) to the filename.
  Default: FALSE.

- with_style:

  Whether to apply a simple header style (bold, fill, centered).
  Default: TRUE.

- auto_col_width:

  Whether to auto-adjust column widths. Default: TRUE.

- open_after:

  Whether to open the file after writing (platform-dependent). Default:
  FALSE.

- verbose:

  Whether to print CLI messages (info/warn/success). Errors are always
  shown. Default: TRUE.

## Value

No return value; writes a file to disk.
