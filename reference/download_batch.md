# Batch download files in parallel

Downloads multiple files concurrently using
[`curl::multi_download()`](https://jeroen.r-universe.dev/curl/reference/multi_download.html).

## Usage

``` r
download_batch(
  urls,
  dest_dir,
  overwrite = FALSE,
  resume = TRUE,
  timeout = 600,
  retries = 3
)
```

## Arguments

- urls:

  Character vector. URLs to download.

- dest_dir:

  Character. Destination directory.

- overwrite:

  Logical. Whether to overwrite existing files. Default: FALSE.

- resume:

  Logical. Whether to resume from an existing non-empty destination file
  when `overwrite = TRUE`. Default: TRUE.

- timeout:

  Integer. Timeout in seconds for each download. Default: 600.

- retries:

  Integer. Number of retry attempts after the first failure. Default: 3.

## Value

Invisibly returns a character vector of destination file paths.
