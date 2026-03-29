# Check Package Installation Status

Check whether packages are installed and optionally install missing
ones. Calls
[`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md)
for auto-installation.

## Usage

``` r
check_pkg(
  pkg,
  source = c("CRAN", "GitHub", "Bioconductor"),
  auto_install = FALSE,
  ...
)
```

## Arguments

- pkg:

  Character vector. Package names or GitHub `"user/repo"`.

- source:

  Character. One of `"CRAN"`, `"GitHub"`, `"Bioconductor"`.

- auto_install:

  Logical. If `TRUE`, install missing packages automatically. Default:
  `FALSE`.

- ...:

  Passed to
  [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md).

## Value

A tibble with columns: `package`, `name`, `installed`, `source`.

## Examples

``` r
check_pkg("ggplot2", source = "CRAN")
#> ✔ Installed: ggplot2
#> # A tibble: 1 × 4
#>   package name    installed source
#>   <chr>   <chr>   <lgl>     <chr> 
#> 1 ggplot2 ggplot2 TRUE      CRAN  
check_pkg("r-lib/devtools", source = "GitHub", auto_install = FALSE)
#> ✔ Installed: devtools
#> # A tibble: 1 × 4
#>   package        name     installed source
#>   <chr>          <chr>    <lgl>     <chr> 
#> 1 r-lib/devtools devtools TRUE      GitHub
```
