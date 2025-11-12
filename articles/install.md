# Installation Guide

## Overview

This guide covers all installation methods for **evanverse**, including
system requirements, dependencies, and troubleshooting.

------------------------------------------------------------------------

## Quick Install

### From CRAN (Recommended)

The stable release is available on CRAN:

``` r
install.packages("evanverse")
```

### From GitHub (Development Version)

For the latest features and bug fixes:

``` r
# Install devtools if needed
install.packages("devtools")

# Install evanverse
devtools::install_github("evanbio/evanverse")
```

------------------------------------------------------------------------

## System Requirements

- **R Version**: ≥ 4.1.0
- **Operating Systems**: Windows, macOS, Linux
- **Internet Connection**: Required for initial installation and some
  functions

------------------------------------------------------------------------

## Dependencies

evanverse depends on several packages that will be automatically
installed:

### Core Dependencies

- **tidyverse** — Data manipulation and visualization
- **data.table** — Fast data processing
- **jsonlite** — JSON handling for color palettes

### Bioinformatics Dependencies

- **Biobase** — Bioconductor infrastructure
- **GSEABase** — Gene set analysis
- **biomaRt** — Gene ID conversion

### Visualization Dependencies

- **ggplot2** — Plotting framework
- **VennDiagram** — Venn diagram generation
- **ggVennDiagram** — Modern Venn diagrams

### Utility Dependencies

- **cli** — Command-line interface
- **fs** — File system operations
- **curl** — URL downloads
- **openxlsx** — Excel file handling

------------------------------------------------------------------------

## Installation Options

### Minimal Installation

Install without suggested packages:

``` r
install.packages("evanverse", dependencies = c("Depends", "Imports"))
```

### Full Installation

Install with all suggested packages for complete functionality:

``` r
install.packages("evanverse", dependencies = TRUE)
```

### Install Specific Version

``` r
# Install a specific version from CRAN
devtools::install_version("evanverse", version = "0.3.7")

# Install from a specific GitHub release
devtools::install_github("evanbio/evanverse@v0.3.7")
```

------------------------------------------------------------------------

## Bioconductor Dependencies

Some bioinformatics functions require Bioconductor packages. Install
them separately:

``` r
# Install BiocManager if needed
if (!requireNamespace("BiocManager", quietly = TRUE))
    install.packages("BiocManager")

# Install Bioconductor dependencies
BiocManager::install(c("Biobase", "GSEABase", "biomaRt", "GEOquery"))
```

------------------------------------------------------------------------

## Verify Installation

After installation, verify that evanverse is working correctly:

``` r
# Load the package
library(evanverse)

# Check version
packageVersion("evanverse")
#> [1] '0.3.7'

# List available functions
pkg_functions("evanverse")
#> 
#> ── Package: evanverse ──
#> 
#> ℹ Matched exported names: 62
#> %is%
#> %map%
#> %match%
#> %nin%
#> %p%
#> any_void
#> bio_palette_gallery
#> check_pkg
#> clear_palette_cache
#> cols_with_void
#> comb
#> combine_logic
#> compile_palettes
#> convert_gene_id
#> create_palette
#> df2list
#> download_batch
#> download_gene_ref
#> download_geo_data
#> download_url
#> drop_void
#> file_info
#> file_tree
#> get_ext
#> get_palette
#> gmt2df
#> gmt2list
#> hex2rgb
#> inst_pkg
#> is_void
#> list_palettes
#> map_column
#> palette_cache_info
#> perm
#> pkg_functions
#> pkg_version
#> plot_bar
#> plot_density
#> plot_forest
#> plot_pie
#> plot_venn
#> preview_palette
#> quick_anova
#> quick_chisq
#> quick_ttest
#> read_excel_flex
#> read_table_flex
#> reload_palette_cache
#> remind
#> remove_palette
#> replace_void
#> rgb2hex
#> rows_with_void
#> safe_execute
#> scale_color_evanverse
#> scale_colour_evanverse
#> scale_fill_evanverse
#> set_mirror
#> update_pkg
#> view
#> with_timer
#> write_xlsx_flex

# Test basic functionality
"Hello" %p% " " %p% "World"
#> [1] "Hello   World"
```

------------------------------------------------------------------------

## Update evanverse

### Update from CRAN

``` r
update.packages("evanverse")
```

### Update from GitHub

``` r
devtools::install_github("evanbio/evanverse", force = TRUE)
```

### Using evanverse’s Built-in Updater

``` r
library(evanverse)
update_pkg("evanverse")
```

------------------------------------------------------------------------

## Troubleshooting

### Installation Fails with “package not available”

**Solution**: Ensure you’re using R ≥ 4.1.0

``` r
R.version.string
```

### Bioconductor Packages Not Installing

**Solution**: Install BiocManager first, then retry:

``` r
install.packages("BiocManager")
BiocManager::install(c("Biobase", "GSEABase"))
```

### Permission Errors on Linux/macOS

**Solution**: Install to user library:

``` r
install.packages("evanverse", lib = Sys.getenv("R_LIBS_USER"))
```

### Network/Firewall Issues

**Solution**: Configure proxy if behind a firewall:

``` r
Sys.setenv(http_proxy = "http://your-proxy:port")
Sys.setenv(https_proxy = "https://your-proxy:port")
```

### Compilation Issues on Windows

**Solution**: Install Rtools from
[CRAN](https://cran.r-project.org/bin/windows/Rtools/)

------------------------------------------------------------------------

## Uninstall

To remove evanverse:

``` r
remove.packages("evanverse")
```

------------------------------------------------------------------------

## Getting Help

- **Documentation**: <https://evanbio.github.io/evanverse/>
- **Issues**: [GitHub
  Issues](https://github.com/evanbio/evanverse/issues)
- **CRAN**: [CRAN Package
  Page](https://cran.r-project.org/package=evanverse)

------------------------------------------------------------------------

## Next Steps

After installation:

1.  Read the [Getting Started
    Guide](https://evanbio.github.io/evanverse/articles/get-started.md)
2.  Explore the [Comprehensive
    Guide](https://evanbio.github.io/evanverse/articles/comprehensive-guide.md)
3.  Browse the [Function
    Reference](https://evanbio.github.io/evanverse/reference/index.md)
4.  Try domain-specific vignettes:
    - [Package
      Management](https://evanbio.github.io/evanverse/articles/package-management.md)
    - [Data
      Processing](https://evanbio.github.io/evanverse/articles/data-processing.md)
    - [Color
      Palettes](https://evanbio.github.io/evanverse/articles/color-palettes.md)
    - [Bioinformatics
      Workflows](https://evanbio.github.io/evanverse/articles/bioinformatics-workflows.md)
