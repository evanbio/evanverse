# download_batch(): Batch download files using multi_download (parallel with curl)

A robust batch downloader that supports concurrent downloads with
flexible options. Built on top of
[`curl::multi_download()`](https://jeroen.r-universe.dev/curl/reference/multi_download.html)
for parallelism.

## Usage

``` r
download_batch(
  urls,
  dest_dir,
  overwrite = FALSE,
  unzip = FALSE,
  workers = 4,
  verbose = TRUE,
  timeout = 600,
  resume = FALSE,
  speed_limit = NULL,
  retries = 3
)
```

## Arguments

- urls:

  Character vector. List of URLs to download.

- dest_dir:

  Character. Destination directory (required). Use tempdir() for
  examples/tests.

- overwrite:

  Logical. Whether to overwrite existing files. Default: FALSE.

- unzip:

  Logical. Whether to unzip after download (for supported formats).
  Default: FALSE.

- workers:

  Integer. Number of parallel workers. Default: 4.

- verbose:

  Logical. Show download progress messages. Default: TRUE.

- timeout:

  Integer. Timeout in seconds for each download. Default: 600.

- resume:

  Logical. Whether to resume interrupted downloads. Default: FALSE.

- speed_limit:

  Numeric. Bandwidth limit in bytes/sec (e.g., 500000 = 500KB/s).
  Default: NULL.

- retries:

  Integer. Retry attempts if download fails. Default: 3.

## Value

Invisibly returns a list of downloaded (and optionally unzipped) file
paths.
