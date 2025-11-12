# Set CRAN/Bioconductor Mirrors

Configure CRAN and/or Bioconductor mirrors for faster package
installation. Once set, all package management functions (`inst_pkg`,
`update_pkg`, etc.) will respect these mirror settings.

## Usage

``` r
set_mirror(repo = c("all", "cran", "bioc"), mirror = "tuna")
```

## Arguments

- repo:

  Character. Repository type: "cran", "bioc", or "all" (default: "all").

- mirror:

  Character. Predefined mirror name (default: "tuna").

## Value

Previous mirror settings (invisibly).

## Details

Available CRAN mirrors:

- **official**: R Project cloud server

- **rstudio**: RStudio CRAN mirror

- **tuna**: Tsinghua University (China)

- **ustc**: USTC (China)

- **aliyun**: Alibaba Cloud (China)

- **sjtu**: Shanghai Jiao Tong University (China)

- **pku**: Peking University (China)

- **hku**: Hong Kong University

- **westlake**: Westlake University (China)

- **nju**: Nanjing University (China)

- **sustech**: SUSTech (China)

Available Bioconductor mirrors:

- **official**: Bioconductor official server

- **tuna**: Tsinghua University (China)

- **ustc**: USTC (China)

- **westlake**: Westlake University (China)

- **nju**: Nanjing University (China)

## Examples

``` r
if (FALSE) { # \dontrun{
# Set all mirrors to tuna (default):
set_mirror()

# Set only CRAN mirror:
set_mirror("cran", "westlake")

# Set only Bioconductor mirror:
set_mirror("bioc", "ustc")

# Check current settings:
getOption("repos")
getOption("BioC_mirror")
} # }
```
