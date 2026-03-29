# Download a GEO series

Downloads a GEO series including expression data, supplemental files,
and platform annotations.

## Usage

``` r
download_geo(gse_id, dest_dir, retries = 2, timeout = 300)
```

## Arguments

- gse_id:

  Character. GEO Series accession ID (e.g., "GSE12345").

- dest_dir:

  Character. Destination directory for downloaded files.

- retries:

  Integer. Number of retry attempts after the first failure. Default: 2.

- timeout:

  Integer. Timeout in seconds per request. Default: 300.

## Value

A list with:

- gse_object:

  ExpressionSet with expression data and annotations

- supplemental_files:

  Character vector of supplemental file paths

- platform_info:

  List with `platform_id` and `gpl_files`

## Examples

``` r
if (FALSE) { # \dontrun{
result <- download_geo("GSE12345", dest_dir = tempdir())
expr_data   <- Biobase::exprs(result$gse_object)
sample_info <- Biobase::pData(result$gse_object)
} # }
```
