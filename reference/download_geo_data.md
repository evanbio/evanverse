# Download GEO Data Resources

Downloads GEO (Gene Expression Omnibus) datasets including expression
data, supplemental files, and platform annotations with error handling
and logging.

## Usage

``` r
download_geo_data(
  gse_id,
  dest_dir,
  overwrite = FALSE,
  log = TRUE,
  log_file = NULL,
  retries = 2,
  timeout = 300
)
```

## Arguments

- gse_id:

  Character. GEO Series accession ID (e.g., "GSE12345").

- dest_dir:

  Character. Destination directory for downloaded files.

- overwrite:

  Logical. Whether to overwrite existing files (default: FALSE).

- log:

  Logical. Whether to create log file (default: TRUE).

- log_file:

  Character or NULL. Log file path (auto-generated if NULL).

- retries:

  Numeric. Number of retry attempts (default: 2).

- timeout:

  Numeric. Timeout in seconds (default: 300).

## Value

A list with components:

- gse_object:

  ExpressionSet object with expression data and annotations

- supplemental_files:

  Paths to downloaded supplemental files

- platform_info:

  Platform information (platform_id, gpl_files)

- meta:

  Download metadata (timing, file counts, etc.)

## Details

Downloads GSEMatrix files, supplemental files, and GPL annotations.
Includes retry mechanism, timeout control, and logging. Requires:
GEOquery, Biobase, withr, cli.

## References

<https://www.ncbi.nlm.nih.gov/geo/>

Barrett T, Wilhite SE, Ledoux P, Evangelista C, Kim IF, Tomashevsky M,
Marshall KA, Phillippy KH, Sherman PM, Holko M, Yefanov A, Lee H, Zhang
N, Robertson CL, Serova N, Davis S, Soboleva A. NCBI GEO: archive for
functional genomics data sets–update. Nucleic Acids Res. 2013 Jan;
41(Database issue):D991-5.

## Examples

``` r
if (FALSE) { # \dontrun{
# Download GEO data (requires network connection):
result <- download_geo_data("GSE12345", dest_dir = tempdir())

# Advanced usage with custom settings:
result <- download_geo_data(
  gse_id = "GSE7305",
  dest_dir = tempdir(),
  log = TRUE,
  retries = 3,
  timeout = 600
)

# Access downloaded data:
expr_data <- Biobase::exprs(result$gse_object)
sample_info <- Biobase::pData(result$gse_object)
feature_info <- Biobase::fData(result$gse_object)
} # }
```
