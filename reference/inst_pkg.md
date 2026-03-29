# Install R Packages from Multiple Sources

Install R packages from CRAN, GitHub, Bioconductor, or local source.
Respects mirror settings from
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

  Character vector. Package name(s) or GitHub `"user/repo"`. Not
  required for `source = "Local"`.

- source:

  Character. One of `"CRAN"`, `"GitHub"`, `"Bioconductor"`, `"Local"`.

- path:

  Character. Path to local package file (required for
  `source = "Local"`).

- ...:

  Passed to the underlying install function.

## Value

NULL invisibly.

## Examples

``` r
if (FALSE) { # \dontrun{
inst_pkg("dplyr", source = "CRAN")
inst_pkg("hadley/emo", source = "GitHub")
inst_pkg("scRNAseq", source = "Bioconductor")
inst_pkg(source = "Local", path = "mypackage.tar.gz")
} # }
```
