# Download a file from a URL

Downloads a file from a URL with retry and resume support.

## Usage

``` r
download_url(
  url,
  dest,
  overwrite = FALSE,
  resume = TRUE,
  timeout = 600,
  retries = 3
)
```

## Arguments

- url:

  Character string. Full URL to the file to download.

- dest:

  Character string. Destination file path.

- overwrite:

  Logical. Whether to overwrite an existing file. Default: FALSE. If
  FALSE and the file exists, download is skipped. If TRUE and
  `resume = TRUE`, will attempt to resume from an existing non-empty
  destination file. If TRUE and `resume = FALSE`, the file is downloaded
  from scratch.

- resume:

  Logical. Whether to resume from an existing non-empty destination file
  when `overwrite = TRUE`. Default: TRUE.

- timeout:

  Integer. Download timeout in seconds. Default: 600.

- retries:

  Integer. Number of retry attempts after the first failure. Default: 3.

## Value

Invisibly returns the path to the downloaded file.

## Examples

``` r
if (FALSE) { # \dontrun{
download_url(
  url  = "https://raw.githubusercontent.com/tidyverse/ggplot2/main/README.md",
  dest = file.path(tempdir(), "ggplot2_readme.md")
)
} # }
```
