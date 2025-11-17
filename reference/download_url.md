# download_url(): Download File from URL

Downloads files from URLs (HTTP/HTTPS/FTP/SFTP) with robust error
handling, retry mechanisms, and advanced features like resume, bandwidth
limiting, and auto-extraction.

## Usage

``` r
download_url(
  url,
  dest,
  overwrite = FALSE,
  unzip = FALSE,
  verbose = TRUE,
  timeout = 600,
  headers = NULL,
  resume = FALSE,
  speed_limit = NULL,
  retries = 3
)
```

## Arguments

- url:

  Character string. Full URL to the file to download. Supports HTTP,
  HTTPS, FTP, and SFTP protocols.

- dest:

  Character string. Destination file path (required). Use
  file.path(tempdir(), basename(url)) for examples/tests.

- overwrite:

  Logical. Whether to overwrite existing files. Default: FALSE.

- unzip:

  Logical. Whether to automatically extract compressed files after
  download. Supports .zip, .gz, .tar.gz formats. Default: FALSE.

- verbose:

  Logical. Whether to show download progress and status messages.
  Default: TRUE.

- timeout:

  Numeric. Download timeout in seconds. Default: 600 (10 minutes).

- headers:

  Named list. Custom HTTP headers for the request (e.g.,
  list(Authorization = "Bearer token")). Default: NULL.

- resume:

  Logical. Whether to attempt resuming interrupted downloads if a
  partial file exists. Default: FALSE.

- speed_limit:

  Numeric. Bandwidth limit in bytes per second (e.g., 500000 = 500KB/s).
  Default: NULL (no limit).

- retries:

  Integer. Number of retry attempts on download failure. Default: 3.

## Value

Invisible character string or vector of file paths:

- If unzip = FALSE:

  Path to the downloaded file

- If unzip = TRUE:

  Vector of paths to extracted files

## Details

This function provides a comprehensive solution for downloading files
with:

### Supported Protocols

Supports HTTP/HTTPS, FTP, and SFTP protocols.

### Features

Includes retry mechanism, resume support, bandwidth control,
auto-extraction, progress tracking, and custom headers.

### Compression Support

Supports .zip, .gz, and .tar.gz formats.

## Dependencies

Required packages: curl, cli, R.utils (automatically checked at
runtime).

## Examples

``` r
if (FALSE) { # \dontrun{
# Download a CSV file from GitHub:
download_url(
  url = "https://raw.githubusercontent.com/tidyverse/ggplot2/main/README.md",
  dest = file.path(tempdir(), "ggplot2_readme.md"),
  timeout = 30
)

# Download and extract a zip file:
download_url(
  url = "https://cran.r-project.org/src/contrib/Archive/dplyr/dplyr_0.8.0.tar.gz",
  dest = file.path(tempdir(), "dplyr.tar.gz"),
  unzip = TRUE,
  timeout = 60
)
} # }

# \donttest{
# Quick demo with a tiny file:
download_url(
  url = "https://httpbin.org/robots.txt",
  dest = file.path(tempdir(), "robots.txt"),
  timeout = 10,
  verbose = FALSE
)
#> 
#> ── Starting File Download ──────────────────────────────────────────────────────
#> ℹ URL: <https://httpbin.org/robots.txt>
#> ℹ Destination: /tmp/Rtmp259fZZ/robots.txt
#> 
#> ── Download Attempt 1/3 ──
#> 
#> ✔ Download completed successfully
#> ℹ File size: 0 MB
#> ℹ Download time: 0.68 seconds
#> 
#> ── Download Process Completed ──────────────────────────────────────────────────
#> ✔ Final file: /tmp/Rtmp259fZZ/robots.txt
# }
```
