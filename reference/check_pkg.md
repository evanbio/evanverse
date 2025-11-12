# Check Package Installation Status

Check whether packages are installed and optionally install missing
ones. Internally calls
[`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md)
for auto-installation.

## Usage

``` r
check_pkg(
  pkg = NULL,
  source = c("CRAN", "GitHub", "Bioconductor"),
  auto_install = TRUE,
  ...
)
```

## Arguments

- pkg:

  Character vector. Package names or GitHub repos (e.g., "user/repo").

- source:

  Character. Package source: "CRAN", "GitHub", or "Bioconductor".

- auto_install:

  Logical. If TRUE (default), install missing packages automatically.

- ...:

  Additional arguments passed to
  [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md).

## Value

A tibble with columns: `package`, `name`, `installed`, `source`.

## Examples

``` r
# Check if ggplot2 is installed (will install if missing):
check_pkg("ggplot2", source = "CRAN")
#> ✔ Installed: ggplot2
#> # A tibble: 1 × 4
#>   package name    installed source
#>   <chr>   <chr>   <lgl>     <chr> 
#> 1 ggplot2 ggplot2 TRUE      CRAN  

# Check without auto-install:
check_pkg("r-lib/devtools", source = "GitHub", auto_install = FALSE)
#> ✔ Installed: devtools
#> # A tibble: 1 × 4
#>   package        name     installed source
#>   <chr>          <chr>    <lgl>     <chr> 
#> 1 r-lib/devtools devtools TRUE      GitHub
```
