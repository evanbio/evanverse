# file_info: Summarise file information

Given a file or folder path (or vector), returns a data.frame containing
file name, size (MB), last modified time, optional line count, and path.

## Usage

``` r
file_info(
  paths,
  recursive = FALSE,
  count_line = TRUE,
  preview = TRUE,
  filter_pattern = NULL,
  full_name = TRUE
)
```

## Arguments

- paths:

  Character vector of file paths or a folder path.

- recursive:

  Logical. If a folder is given, whether to search recursively. Default:
  FALSE.

- count_line:

  Logical. Whether to count lines in each file. Default: TRUE.

- preview:

  Logical. Whether to show skipped/missing messages. Default: TRUE.

- filter_pattern:

  Optional regex to filter file names (e.g., "\\R\$"). Default: NULL.

- full_name:

  Logical. Whether to return full file paths. Default: TRUE.

## Value

A data.frame with columns: file, size_MB, modified_time, line_count,
path.

## Examples

``` r
file_info("R")
#> ! No valid files found.
#> data frame with 0 columns and 0 rows
file_info(c("README.md", "DESCRIPTION"))
#> ! No valid files found.
#> data frame with 0 columns and 0 rows
file_info("R", filter_pattern = "\\.R$", recursive = TRUE)
#> ! No valid files found.
#> data frame with 0 columns and 0 rows
```
