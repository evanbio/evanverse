# Package Management

A unified interface for R package management across CRAN, GitHub,
Bioconductor, and local sources. Provides consistent installation,
checking, updating, and querying capabilities.

## Details

The package management functions automatically:

- Respect mirror settings configured via
  [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md)

- Handle dependencies for BiocManager and devtools

- Validate package names and sources

- Provide informative error messages and progress updates

Recommended workflow:

1.  (Optional) Configure mirrors:
    [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md)

2.  Install packages:
    [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md)

3.  Check status:
    [`check_pkg()`](https://evanbio.github.io/evanverse/reference/check_pkg.md)

4.  Update packages:
    [`update_pkg()`](https://evanbio.github.io/evanverse/reference/update_pkg.md)

5.  Query information:
    [`pkg_version()`](https://evanbio.github.io/evanverse/reference/pkg_version.md),
    [`pkg_functions()`](https://evanbio.github.io/evanverse/reference/pkg_functions.md)

## See also

[`install.packages`](https://rdrr.io/r/utils/install.packages.html) for
base installation,
[`install_github`](https://remotes.r-lib.org/reference/install_github.html)
for GitHub packages,
[`install`](https://bioconductor.github.io/BiocManager/reference/install.html)
for Bioconductor packages.
