# Changelog

## evanverse 0.3.7

CRAN release: 2025-10-21

*Released: October 16, 2025* **Published on CRAN: October 21, 2025** 🎉

**CRAN Compliance Release** - Fixed file system operation policy
violations.

#### CRAN Publication

- **Status**: Successfully published on CRAN (October 21, 2025)
- **Platform**: Windows support confirmed
- **Installation**: `install.packages("evanverse")`
- **CRAN Page**: <https://CRAN.R-project.org/package=evanverse>

------------------------------------------------------------------------

#### CRAN Compliance Fixes

- **File operation policy compliance**: Removed all default file paths
  that write to user’s home directory or working directory
  - Fixed 9 functions to require explicit path parameters instead of
    defaults
  - Functions updated:
    [`create_palette()`](https://evanbio.github.io/evanverse/reference/create_palette.md),
    [`remove_palette()`](https://evanbio.github.io/evanverse/reference/remove_palette.md),
    [`compile_palettes()`](https://evanbio.github.io/evanverse/reference/compile_palettes.md),
    [`download_batch()`](https://evanbio.github.io/evanverse/reference/download_batch.md),
    [`download_url()`](https://evanbio.github.io/evanverse/reference/download_url.md),
    [`download_geo_data()`](https://evanbio.github.io/evanverse/reference/download_geo_data.md)
  - All examples and tests now use
    [`tempdir()`](https://rdrr.io/r/base/tempfile.html) for file
    operations
- **Updated function signatures** (Breaking Changes - Path Parameters
  Now Required):
  - [`create_palette()`](https://evanbio.github.io/evanverse/reference/create_palette.md):
    `color_dir` parameter now required (no default)
  - [`remove_palette()`](https://evanbio.github.io/evanverse/reference/remove_palette.md):
    `color_dir` parameter now required (no default)
  - [`compile_palettes()`](https://evanbio.github.io/evanverse/reference/compile_palettes.md):
    Both `palettes_dir` and `output_rds` parameters now required
  - [`download_batch()`](https://evanbio.github.io/evanverse/reference/download_batch.md):
    `dest_dir` parameter now required (no default)
  - [`download_url()`](https://evanbio.github.io/evanverse/reference/download_url.md):
    `dest` parameter now required (no default)
- **Enhanced parameter validation**: All affected functions now provide
  clear error messages when required paths are missing
  - Error messages guide users to use
    [`tempdir()`](https://rdrr.io/r/base/tempfile.html) for examples and
    tests
  - Documentation updated to reflect required parameters

#### Migration Guide

For users upgrading from 0.3.6:

``` r
# OLD (0.3.6) - No longer works in 0.3.7
create_palette("my_palette", "sequential", colors)

# NEW (0.3.7) - Explicit path required
temp_dir <- file.path(tempdir(), "palettes")
create_palette("my_palette", "sequential", colors, color_dir = temp_dir)

# For production use, specify your desired directory
create_palette("my_palette", "sequential", colors,
               color_dir = "path/to/your/palette/directory")
```

#### Technical Details

- **Reviewer**: Addressed feedback from Benjamin Altmann (CRAN)
- **Policy Reference**: [CRAN File Writing
  Policy](https://contributor.r-project.org/cran-cookbook/code_issues.html#writing-files-and-directories-to-the-home-filespace)
- **Functions modified**: 9 functions updated for CRAN compliance
- **Documentation**: All man pages regenerated with updated parameter
  descriptions
- **Backward compatibility**: This is a breaking change for functions
  that previously had default file paths

------------------------------------------------------------------------

## evanverse 0.3.6

*Released: October 8, 2025*

**Maintenance Release** - Minor improvements and bug fixes.

------------------------------------------------------------------------

#### Bug Fixes

- Fixed plot_venn function to properly handle void values in list inputs
- Improved namespace consistency across package functions
- Minor documentation updates for clarity

#### Technical Details

- Updated package version to 0.3.6
- All R CMD check tests passing (0 errors, 0 warnings, 0 notes)
- Maintained CRAN compliance standards

------------------------------------------------------------------------

## evanverse 0.3.5

*Released: October 7, 2025*

**CRAN Resubmission** - Addressed all reviewer feedback with improved
examples and file operation handling.

------------------------------------------------------------------------

#### CRAN Compliance Fixes

- **Fixed function examples**: Updated 10 functions with properly
  working examples per CRAN reviewer feedback
  - Replaced `\donttest{}` with `\dontrun{}` for network-dependent
    operations
  - Added `\donttest{}` with quick demos for appropriate functions
  - Fixed all commented examples in `@examples` sections
- **File operation improvements**: All examples now use
  [`tempdir()`](https://rdrr.io/r/base/tempfile.html) for temporary file
  creation
  - Enhanced
    [`create_palette()`](https://evanbio.github.io/evanverse/reference/create_palette.md)
    examples with proper cleanup code
  - Updated
    [`file_tree()`](https://evanbio.github.io/evanverse/reference/file_tree.md)
    examples to use appropriate paths
  - Fixed
    [`preview_palette()`](https://evanbio.github.io/evanverse/reference/preview_palette.md)
    to use existing palette names
- **Network operation handling**: Properly wrapped all network-dependent
  examples
  - Functions updated:
    [`download_geo_data()`](https://evanbio.github.io/evanverse/reference/download_geo_data.md),
    [`download_url()`](https://evanbio.github.io/evanverse/reference/download_url.md),
    [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md),
    [`pkg_version()`](https://evanbio.github.io/evanverse/reference/pkg_version.md),
    [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md)
- **GMT file examples**: Enhanced examples for
  [`gmt2df()`](https://evanbio.github.io/evanverse/reference/gmt2df.md)
  and
  [`gmt2list()`](https://evanbio.github.io/evanverse/reference/gmt2list.md)
  functions
- **Palette management**: Fixed examples for
  [`compile_palettes()`](https://evanbio.github.io/evanverse/reference/compile_palettes.md)
  and
  [`remove_palette()`](https://evanbio.github.io/evanverse/reference/remove_palette.md)

#### Technical Details

- **Reviewer**: Addressed feedback from Benjamin Altmann (CRAN)
- **Functions updated**: 10 functions with improved examples and
  documentation
- **Files modified**: 24 R and man files for consistency
- **Compliance**: All examples now follow CRAN policies for file
  operations and network access

------------------------------------------------------------------------

## evanverse 0.3.4

*Released: September 28, 2025*

**CRAN Submission Ready** - Enhanced version with dependency
optimization and improved documentation quality.

------------------------------------------------------------------------

#### Major Improvements

- **Dependency optimization**: Moved bioinformatics packages (GSEABase,
  Biobase, GEOquery, biomaRt) from Imports to Suggests for lighter base
  installation
- **Enhanced documentation**: Streamlined function documentation for
  improved readability and consistency across all 55+ functions
- **Test suite improvements**: Enhanced test reliability with better
  isolation and parameter validation (1358 tests passing)
- **Vignette optimizations**: Improved graphics parameter handling and
  execution speed with proper cleanup
- **Code style improvements**: Consistent formatting and improved
  maintainability across all functions

#### CRAN Compliance Enhancements

- **Perfect clean check**: 0 errors ✔ \| 0 warnings ✔ \| 0 notes ✔
- **Package size optimization**: Reduced from 6.5MB to 1.5MB through
  dependency restructuring
- **Cross-platform validation**: Confirmed compatibility across Windows,
  macOS, and Linux
- **Installation time improvement**: Optimized to 5 seconds with reduced
  mandatory dependencies
- **Check time optimization**: Streamlined to 133 seconds through better
  test organization

#### Documentation & Quality

- **Streamlined roxygen2 documentation**: Updated across 17 core R
  functions for clarity
- **Enhanced function examples**: All examples verified and optimized
  for CRAN compliance
- **Improved cross-references**: Validated all internal links and
  references
- **Better error handling**: Enhanced user-friendly error messages and
  validation

#### Technical Details

- **R CMD check status**: All checks passing with perfect results across
  multiple platforms
- **Test coverage**: 1358 tests with 25 network-dependent tests properly
  skipped on CRAN
- **Documentation completeness**: All exported functions have
  comprehensive documentation
- **Dependency management**: Strategic use of Imports vs Suggests for
  optimal installation experience

------------------------------------------------------------------------

## evanverse 0.3.3

*Released: September 19, 2025*

**CRAN Submission Ready** - Passed CRAN automatic checks; under manual
review.

------------------------------------------------------------------------

#### CRAN Compliance Fixes

- **Resolved all R CMD check issues**: Eliminated remaining warnings and
  notes for full CRAN compliance
- **Enhanced documentation consistency**: Fixed all argument mismatches
  and improved parameter descriptions
- **Optimized package dependencies**: Streamlined imports and resolved
  namespace conflicts
- **Cross-platform validation**: Confirmed compatibility across Windows,
  macOS, and Linux environments
- **Test suite refinement**: Updated test conditions and skip logic for
  CRAN environment compatibility

#### CRAN Check Results

- **Windows (R-release)**: ✅ PASS - 0 errors, 0 warnings, 0 notes
- **Debian (R-devel)**: ✅ PASS - 0 errors, 0 warnings, 0 notes
- **All test environments**: Successfully validated across multiple R
  versions and platforms

#### What’s New

- Final CRAN submission preparations completed
- Enhanced package robustness and reliability
- Improved documentation quality and consistency
- Streamlined codebase for production readiness

#### Technical Details

- **R CMD check status**: All checks passing with clean results
- **Test coverage**: 1336+ tests with appropriate CRAN skip conditions
- **Documentation**: All man pages updated with proper formatting and
  examples
- **Vignettes**: Network-dependent code properly handled with
  `eval=FALSE`

#### Next Steps

- **CRAN manual review**: Package submitted and awaiting final approval
- **Expected timeline**: Approval anticipated within 10 working days
- **Installation**: Will be available via
  `install.packages("evanverse")` upon approval

------------------------------------------------------------------------

## evanverse 0.3.2

A maintenance release focusing on CRAN check compliance and package
quality improvements.

------------------------------------------------------------------------

#### CRAN Compliance Fixes

- **Fixed namespace imports**: Added proper `package::function` prefixes
  for all base R functions
  - Added [`stats::setNames`](https://rdrr.io/r/stats/setNames.html),
    [`utils::install.packages`](https://rdrr.io/r/utils/install.packages.html),
    [`utils::available.packages`](https://rdrr.io/r/utils/available.packages.html),
    etc.
  - Resolved “no visible global function definition” warnings
- **Removed Unicode characters**: Cleaned up emoji characters from R
  code files for better compatibility
- **Updated documentation**: Fixed argument mismatches in function
  documentation (e.g., `%nin%` operator)
- **Network dependency handling**: Ensured all network-dependent code in
  vignettes uses `eval=FALSE`
- **Enhanced examples**: Wrapped network-dependent examples in
  `\dontrun{}` blocks

#### Code Quality Improvements

- Improved function documentation with accurate parameter descriptions
- Standardized error messages and validation patterns
- Enhanced CRAN submission readiness with better compliance checks
- Updated package structure for optimal build and check processes

------------------------------------------------------------------------

## evanverse 0.3.1

A patch release focusing on CRAN submission preparation and
cross-platform compatibility validation.

------------------------------------------------------------------------

#### Documentation & Release Preparation

- **CRAN Submission Checklist**: Added comprehensive checklist covering
  all policy requirements and compliance checks
- **Test Environment Documentation**: Created detailed
  `cran-comments.md` with test environments and submission documentation
- **Cross-Platform Compatibility**: Generated validation report
  confirming Windows/macOS/Linux support
- **Documentation Updates**: Updated package documentation with improved
  man pages and examples
- **Test Suite Validation**: Verified all 1336 tests pass with proper
  skip conditions for CRAN/CI environments

#### Internal Improvements

- **File Path Handling**: Enhanced validation across all platforms with
  robust error handling
- **Platform-Specific Code**: Confirmed minimal platform dependencies
  with proper error handling
- **Dependency Validation**: Verified all dependencies are
  cross-platform compatible
- **Package Structure**: Cleaned up package structure by removing
  unnecessary `.here` file

------------------------------------------------------------------------

## evanverse 0.3.0

A focused refactor release: unified CLI messaging, CRAN-safe startup,
tighter parameter validation, stronger tests, and several new utilities.

------------------------------------------------------------------------

#### New Functions

- **[`plot_forest()`](https://evanbio.github.io/evanverse/reference/plot_forest.md)**
  — Forest plots with publication-style defaults (forestploter),
  significance bolding, color recycling, and alignment options.

- **[`plot_bar()`](https://evanbio.github.io/evanverse/reference/plot_bar.md)**
  — Bar charts with optional fill grouping, sorting, vertical/horizontal
  layout, and clean defaults.

- **[`read_excel_flex()`](https://evanbio.github.io/evanverse/reference/read_excel_flex.md)**
  — Enhanced Excel reader (readxl) with optional name cleaning
  (janitor), range/col_types controls, and CLI feedback.

- **[`write_xlsx_flex()`](https://evanbio.github.io/evanverse/reference/write_xlsx_flex.md)**
  — Flexible Excel writer (openxlsx) with header styling, auto column
  width, overwrite/timestamp options.

- **[`view()`](https://evanbio.github.io/evanverse/reference/view.md)**
  — Quick interactive data viewer (reactable) for exploration/QC.

- **[`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md)**
  — Switch CRAN/Bioconductor mirrors with predefined, named endpoints.

- **[`pkg_functions()`](https://evanbio.github.io/evanverse/reference/pkg_functions.md)**
  — List exported functions from any installed package, with optional
  keyword filtering.

------------------------------------------------------------------------

#### Enhancements & Refactors

- **[`read_table_flex()`](https://evanbio.github.io/evanverse/reference/read_table_flex.md)**
  - Inlined, robust delimiter detection for .csv/.tsv/.txt and .gz files
  - Stricter parameter checks and clearer CLI error messages
  - Enhanced encoding guardrails for better file handling
- **[`update_pkg()`](https://evanbio.github.io/evanverse/reference/update_pkg.md)**
  - Source normalization via strict
    [`match()`](https://rdrr.io/r/base/match.html) function
  - Supports only “CRAN”, “GitHub”, “Bioconductor” sources
  - Clearer messages and mirror handling aligned with
    [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md)
- **[`pkg_version()`](https://evanbio.github.io/evanverse/reference/pkg_version.md)**
  - More robust CRAN/Bioconductor database retrieval
  - Helpful suggestions for GitHub package installations
  - Optional preview printing with clearer CLI output
- **Diagnostic Operators**
  - `%is%` and `%near%` messages standardized (no emoji)
  - Tighter type/shape checks with cleaner examples
  - `%nin%` implemented as `Negate(%in%)` with simple, predictable NA
    semantics
- **Data Utilities**
  - [`map_column()`](https://evanbio.github.io/evanverse/reference/map_column.md)
    uses unified `cli` output and counts unmatched keys
  - Skips numeric columns by design, removes emoji, adds modular
    separators
  - [`with_timer()`](https://evanbio.github.io/evanverse/reference/with_timer.md)
    simplified using `tictoc` timing and `cli` output
  - [`remind()`](https://evanbio.github.io/evanverse/reference/remind.md)
    rendering fixed for `cli` braces with partial/case-insensitive
    matches
  - [`rgb2hex()`](https://evanbio.github.io/evanverse/reference/rgb2hex.md)
    input validation tightened with concise CLI feedback
  - [`rows_with_void()`](https://evanbio.github.io/evanverse/reference/void.md)
    header streamlined, delegates detection to
    [`is_void()`](https://evanbio.github.io/evanverse/reference/void.md)
- **Startup and Documentation**
  - `.onAttach` switched to plain
    [`cli::cli_text()`](https://cli.r-lib.org/reference/cli_text.html)
    messages (no emoji), CRAN-safe
  - Roxygen examples trimmed for non-interactive/CRAN environments
  - Consistent headers and separators throughout documentation

------------------------------------------------------------------------

#### Testing & QA

- **Test Structure Improvements**
  - Tests modularized and expanded with per-test `skip_on_cran()` /
    `skip_if_not_installed()`
  - Removed nested `test_that()` blocks for better organization
  - Strengthened assertions with more tolerant regex messages to avoid
    brittle failures
- **Enhanced Test Coverage**
  - Added/updated coverage for plotting functions:
    [`plot_forest()`](https://evanbio.github.io/evanverse/reference/plot_forest.md),
    [`plot_bar()`](https://evanbio.github.io/evanverse/reference/plot_bar.md)
  - File I/O functions:
    [`read_table_flex()`](https://evanbio.github.io/evanverse/reference/read_table_flex.md),
    [`read_excel_flex()`](https://evanbio.github.io/evanverse/reference/read_excel_flex.md),
    [`write_xlsx_flex()`](https://evanbio.github.io/evanverse/reference/write_xlsx_flex.md)
  - Package management:
    [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md),
    [`pkg_functions()`](https://evanbio.github.io/evanverse/reference/pkg_functions.md)
  - Utilities:
    [`remind()`](https://evanbio.github.io/evanverse/reference/remind.md),
    [`map_column()`](https://evanbio.github.io/evanverse/reference/map_column.md),
    [`replace_void()`](https://evanbio.github.io/evanverse/reference/void.md),
    [`rows_with_void()`](https://evanbio.github.io/evanverse/reference/void.md),
    [`rgb2hex()`](https://evanbio.github.io/evanverse/reference/rgb2hex.md)
  - Operators: `%is%`, `%near%`, `%nin%`, `%p%`
- **Environment Compatibility**
  - Marked environment-dependent tests (e.g.,
    [`file_info()`](https://evanbio.github.io/evanverse/reference/file_info.md))
    with `skip_on_cran()`
  - Ensured tests work reliably across different platforms and CI
    environments

------------------------------------------------------------------------

#### Internal Changes

- **Namespace and Data Access**
  - Fixed internal data access during package load to avoid namespace
    lookup errors
  - Removed direct `pkg::object` dependency for bundled data
- **Code Style and Standards**
  - Consistent CLI style implementation across all functions
  - Removed all emoji from code, comments, and roxygen documentation
  - Enhanced code readability and maintainability

------------------------------------------------------------------------

## evanverse 0.2.0

A comprehensive upgrade with expanded tools for R developers and
bioinformaticians.

------------------------------------------------------------------------

#### New Functions (by Category)

##### File & Data Management

- [`file_info()`](https://evanbio.github.io/evanverse/reference/file_info.md),
  [`file_tree()`](https://evanbio.github.io/evanverse/reference/file_tree.md),
  [`get_ext()`](https://evanbio.github.io/evanverse/reference/get_ext.md),
  [`read_table_flex()`](https://evanbio.github.io/evanverse/reference/read_table_flex.md),
  [`download_url()`](https://evanbio.github.io/evanverse/reference/download_url.md)

##### Package Management Tools

- [`check_pkg()`](https://evanbio.github.io/evanverse/reference/check_pkg.md),
  [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md),
  [`update_pkg()`](https://evanbio.github.io/evanverse/reference/update_pkg.md),
  [`pkg_version()`](https://evanbio.github.io/evanverse/reference/pkg_version.md)

##### Bioinformatics Color Palettes

- [`compile_palettes()`](https://evanbio.github.io/evanverse/reference/compile_palettes.md),
  [`get_palette()`](https://evanbio.github.io/evanverse/reference/get_palette.md),
  [`list_palettes()`](https://evanbio.github.io/evanverse/reference/list_palettes.md),
  [`create_palette()`](https://evanbio.github.io/evanverse/reference/create_palette.md)
- [`preview_palette()`](https://evanbio.github.io/evanverse/reference/preview_palette.md),
  [`bio_palette_gallery()`](https://evanbio.github.io/evanverse/reference/bio_palette_gallery.md)

##### Data Processing Tools

- [`map_column()`](https://evanbio.github.io/evanverse/reference/map_column.md),
  [`df2list()`](https://evanbio.github.io/evanverse/reference/df2list.md),
  [`gmt2df()`](https://evanbio.github.io/evanverse/reference/gmt2df.md),
  [`gmt2list()`](https://evanbio.github.io/evanverse/reference/gmt2list.md)
- [`convert_gene_id()`](https://evanbio.github.io/evanverse/reference/convert_gene_id.md),
  [`download_gene_ref()`](https://evanbio.github.io/evanverse/reference/download_gene_ref.md)

##### Development Helper Functions

- [`remind()`](https://evanbio.github.io/evanverse/reference/remind.md),
  [`with_timer()`](https://evanbio.github.io/evanverse/reference/with_timer.md),
  `%map%`, `%match%`, `%is%`, `%nin%`, `%p%`

##### Void Value Handling

- [`is_void()`](https://evanbio.github.io/evanverse/reference/void.md),
  [`any_void()`](https://evanbio.github.io/evanverse/reference/void.md),
  [`drop_void()`](https://evanbio.github.io/evanverse/reference/void.md),
  [`replace_void()`](https://evanbio.github.io/evanverse/reference/void.md)
- [`cols_with_void()`](https://evanbio.github.io/evanverse/reference/void.md),
  [`rows_with_void()`](https://evanbio.github.io/evanverse/reference/void.md)

##### Vector & Logic Operations

- [`combine_logic()`](https://evanbio.github.io/evanverse/reference/combine_logic.md),
  [`hex2rgb()`](https://evanbio.github.io/evanverse/reference/hex2rgb.md),
  [`rgb2hex()`](https://evanbio.github.io/evanverse/reference/rgb2hex.md)

##### Visualization Tools

- [`plot_venn()`](https://evanbio.github.io/evanverse/reference/plot_venn.md),
  [`plot_pie()`](https://evanbio.github.io/evanverse/reference/plot_pie.md)

------------------------------------------------------------------------

#### Internal Changes

- Removed GitHub Actions auto-deployment logic (`pkgdown.yaml`)
- Switched to local builds with `docs/` deployment to GitHub Pages
- Refactored documentation structure to improve package documentation
  readability

------------------------------------------------------------------------

#### Documentation

- **Online Documentation**:
  [evanbio.github.io/evanverse](https://evanbio.github.io/evanverse/)
- Comprehensive function reference with examples
- Getting started guides and tutorials

------------------------------------------------------------------------

## evanverse 0.1.0

**First Release**

- Introduced `%p%` operator for expressive string concatenation
- Built modular structure with dev/00_setup.R, tests, and MIT license
- Added GitHub integration and install instructions
