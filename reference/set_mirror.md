# Set CRAN/Bioconductor Mirrors

Configure CRAN and/or Bioconductor mirrors for faster package
installation. R's native installation functions, BiocManager, and pak
can respect these settings once set.

## Usage

``` r
set_mirror(repo = c("all", "cran", "bioc"), mirror = "tuna")
```

## Arguments

- repo:

  Character. One of `"all"`, `"cran"`, `"bioc"`. Default: `"all"`.

- mirror:

  Character. Mirror name. Default: `"tuna"`. CRAN: `official`,
  `rstudio`, `tuna`, `ustc`, `aliyun`, `sjtu`, `pku`, `hku`, `westlake`,
  `nju`, `sustech`. Bioc: `official`, `tuna`, `ustc`, `westlake`, `nju`.

## Value

Previous mirror settings (invisibly).

## Examples

``` r
if (FALSE) { # \dontrun{
set_mirror()                    # all mirrors → tuna
set_mirror("cran", "westlake")  # CRAN only
set_mirror("bioc", "ustc")      # Bioc only
} # }
```
