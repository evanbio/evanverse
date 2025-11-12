# Update R Packages

Update R packages from CRAN, GitHub, or Bioconductor. Supports full
updates, source-specific updates, or targeted package updates.
Automatically handles version compatibility checks and respects mirror
settings.

## Usage

``` r
update_pkg(pkg = NULL, source = NULL, ...)
```

## Arguments

- pkg:

  Character vector. Package name(s) to update. For GitHub, use
  `"user/repo"` format. Only required when `source` is specified.

- source:

  Character. Package source: "CRAN", "GitHub", or "Bioconductor".
  Optional if updating all installed CRAN and Bioconductor packages.

- ...:

  Additional arguments passed to
  [`install.packages`](https://rdrr.io/r/utils/install.packages.html),
  [`install_github`](https://remotes.r-lib.org/reference/install_github.html),
  or
  [`install`](https://bioconductor.github.io/BiocManager/reference/install.html).

## Value

NULL (invisibly). Side effect: updates packages.

## Examples

``` r
if (FALSE) { # \dontrun{
# Update all CRAN + Bioconductor packages:
update_pkg()

# Update all CRAN packages only:
update_pkg(source = "CRAN")

# Update specific package:
update_pkg("ggplot2", source = "CRAN")

# Update GitHub package:
update_pkg("hadley/ggplot2", source = "GitHub")
} # }
```
