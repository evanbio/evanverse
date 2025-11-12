# Install R Packages from Multiple Sources

Install R packages from CRAN, GitHub, Bioconductor, or local source.
Automatically respects mirror settings from
[`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md).

## Usage

``` r
inst_pkg(
  pkg = NULL,
  source = c("CRAN", "GitHub", "Bioconductor", "Local"),
  path = NULL,
  ...
)
```

## Arguments

- pkg:

  Character vector. Package name(s) or GitHub repo (e.g., "user/repo").
  Not required for `source = "local"`.

- source:

  Character. Package source: "CRAN", "GitHub", "Bioconductor", "Local".
  Case-insensitive, first match used.

- path:

  Character. Path to local package file (required when
  `source = "local"`).

- ...:

  Additional arguments passed to
  [`install.packages`](https://rdrr.io/r/utils/install.packages.html),
  [`install_github`](https://remotes.r-lib.org/reference/install_github.html),
  or
  [`install`](https://bioconductor.github.io/BiocManager/reference/install.html).

## Value

NULL (invisibly). Side effect: installs packages.

## Examples

``` r
if (FALSE) { # \dontrun{
# Install from CRAN:
inst_pkg("dplyr", source = "CRAN")

# Install from GitHub:
inst_pkg("hadley/emo", source = "GitHub")

# Install from Bioconductor:
inst_pkg("scRNAseq", source = "Bioconductor")

# Install from local file:
inst_pkg(source = "Local", path = "mypackage.tar.gz")
} # }
```
