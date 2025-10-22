# evanverse 0.3.7

*Released: October 16, 2025*
**Published on CRAN: October 21, 2025** 🎉

**CRAN Compliance Release** - Fixed file system operation policy violations.

### CRAN Publication

* **Status**: Successfully published on CRAN (October 21, 2025)
* **Platform**: Windows support confirmed
* **Installation**: `install.packages("evanverse")`
* **CRAN Page**: https://CRAN.R-project.org/package=evanverse

---

### CRAN Compliance Fixes

* **File operation policy compliance**: Removed all default file paths that write to user's home directory or working directory
  - Fixed 9 functions to require explicit path parameters instead of defaults
  - Functions updated: `create_palette()`, `remove_palette()`, `compile_palettes()`, `download_batch()`, `download_url()`, `download_geo_data()`
  - All examples and tests now use `tempdir()` for file operations

* **Updated function signatures** (Breaking Changes - Path Parameters Now Required):
  - `create_palette()`: `color_dir` parameter now required (no default)
  - `remove_palette()`: `color_dir` parameter now required (no default)
  - `compile_palettes()`: Both `palettes_dir` and `output_rds` parameters now required
  - `download_batch()`: `dest_dir` parameter now required (no default)
  - `download_url()`: `dest` parameter now required (no default)

* **Enhanced parameter validation**: All affected functions now provide clear error messages when required paths are missing
  - Error messages guide users to use `tempdir()` for examples and tests
  - Documentation updated to reflect required parameters

### Migration Guide

For users upgrading from 0.3.6:

```r
# OLD (0.3.6) - No longer works in 0.3.7
create_palette("my_palette", "sequential", colors)

# NEW (0.3.7) - Explicit path required
temp_dir <- file.path(tempdir(), "palettes")
create_palette("my_palette", "sequential", colors, color_dir = temp_dir)

# For production use, specify your desired directory
create_palette("my_palette", "sequential", colors,
               color_dir = "path/to/your/palette/directory")
```

### Technical Details

* **Reviewer**: Addressed feedback from Benjamin Altmann (CRAN)
* **Policy Reference**: [CRAN File Writing Policy](https://contributor.r-project.org/cran-cookbook/code_issues.html#writing-files-and-directories-to-the-home-filespace)
* **Functions modified**: 9 functions updated for CRAN compliance
* **Documentation**: All man pages regenerated with updated parameter descriptions
* **Backward compatibility**: This is a breaking change for functions that previously had default file paths

---

# evanverse 0.3.6

*Released: October 8, 2025*

**Maintenance Release** - Minor improvements and bug fixes.

---

### Bug Fixes

* Fixed plot_venn function to properly handle void values in list inputs
* Improved namespace consistency across package functions
* Minor documentation updates for clarity

### Technical Details

* Updated package version to 0.3.6
* All R CMD check tests passing (0 errors, 0 warnings, 0 notes)
* Maintained CRAN compliance standards

---

# evanverse 0.3.5

*Released: October 7, 2025*

**CRAN Resubmission** - Addressed all reviewer feedback with improved examples and file operation handling.

---

### CRAN Compliance Fixes

* **Fixed function examples**: Updated 10 functions with properly working examples per CRAN reviewer feedback
  - Replaced `\donttest{}` with `\dontrun{}` for network-dependent operations
  - Added `\donttest{}` with quick demos for appropriate functions
  - Fixed all commented examples in `@examples` sections
* **File operation improvements**: All examples now use `tempdir()` for temporary file creation
  - Enhanced `create_palette()` examples with proper cleanup code
  - Updated `file_tree()` examples to use appropriate paths
  - Fixed `preview_palette()` to use existing palette names
* **Network operation handling**: Properly wrapped all network-dependent examples
  - Functions updated: `download_geo_data()`, `download_url()`, `inst_pkg()`, `pkg_version()`, `set_mirror()`
* **GMT file examples**: Enhanced examples for `gmt2df()` and `gmt2list()` functions
* **Palette management**: Fixed examples for `compile_palettes()` and `remove_palette()`

### Technical Details

* **Reviewer**: Addressed feedback from Benjamin Altmann (CRAN)
* **Functions updated**: 10 functions with improved examples and documentation
* **Files modified**: 24 R and man files for consistency
* **Compliance**: All examples now follow CRAN policies for file operations and network access

---

# evanverse 0.3.4

*Released: September 28, 2025*

**CRAN Submission Ready** - Enhanced version with dependency optimization and improved documentation quality.

---

### Major Improvements

* **Dependency optimization**: Moved bioinformatics packages (GSEABase, Biobase, GEOquery, biomaRt) from Imports to Suggests for lighter base installation
* **Enhanced documentation**: Streamlined function documentation for improved readability and consistency across all 55+ functions
* **Test suite improvements**: Enhanced test reliability with better isolation and parameter validation (1358 tests passing)
* **Vignette optimizations**: Improved graphics parameter handling and execution speed with proper cleanup
* **Code style improvements**: Consistent formatting and improved maintainability across all functions

### CRAN Compliance Enhancements

* **Perfect clean check**: 0 errors ✔ | 0 warnings ✔ | 0 notes ✔
* **Package size optimization**: Reduced from 6.5MB to 1.5MB through dependency restructuring
* **Cross-platform validation**: Confirmed compatibility across Windows, macOS, and Linux
* **Installation time improvement**: Optimized to 5 seconds with reduced mandatory dependencies
* **Check time optimization**: Streamlined to 133 seconds through better test organization

### Documentation & Quality

* **Streamlined roxygen2 documentation**: Updated across 17 core R functions for clarity
* **Enhanced function examples**: All examples verified and optimized for CRAN compliance
* **Improved cross-references**: Validated all internal links and references
* **Better error handling**: Enhanced user-friendly error messages and validation

### Technical Details

* **R CMD check status**: All checks passing with perfect results across multiple platforms
* **Test coverage**: 1358 tests with 25 network-dependent tests properly skipped on CRAN
* **Documentation completeness**: All exported functions have comprehensive documentation
* **Dependency management**: Strategic use of Imports vs Suggests for optimal installation experience

---

# evanverse 0.3.3

*Released: September 19, 2025*

**CRAN Submission Ready** - Passed CRAN automatic checks; under manual review.

---

### CRAN Compliance Fixes

* **Resolved all R CMD check issues**: Eliminated remaining warnings and notes for full CRAN compliance
* **Enhanced documentation consistency**: Fixed all argument mismatches and improved parameter descriptions
* **Optimized package dependencies**: Streamlined imports and resolved namespace conflicts
* **Cross-platform validation**: Confirmed compatibility across Windows, macOS, and Linux environments
* **Test suite refinement**: Updated test conditions and skip logic for CRAN environment compatibility

### CRAN Check Results

* **Windows (R-release)**: ✅ PASS - 0 errors, 0 warnings, 0 notes
* **Debian (R-devel)**: ✅ PASS - 0 errors, 0 warnings, 0 notes
* **All test environments**: Successfully validated across multiple R versions and platforms

### What's New

* Final CRAN submission preparations completed
* Enhanced package robustness and reliability
* Improved documentation quality and consistency
* Streamlined codebase for production readiness

### Technical Details

* **R CMD check status**: All checks passing with clean results
* **Test coverage**: 1336+ tests with appropriate CRAN skip conditions
* **Documentation**: All man pages updated with proper formatting and examples
* **Vignettes**: Network-dependent code properly handled with `eval=FALSE`

### Next Steps

* **CRAN manual review**: Package submitted and awaiting final approval
* **Expected timeline**: Approval anticipated within 10 working days
* **Installation**: Will be available via `install.packages("evanverse")` upon approval

---

# evanverse 0.3.2

A maintenance release focusing on CRAN check compliance and package quality improvements.

---

### CRAN Compliance Fixes

* **Fixed namespace imports**: Added proper `package::function` prefixes for all base R functions
  - Added `stats::setNames`, `utils::install.packages`, `utils::available.packages`, etc.
  - Resolved "no visible global function definition" warnings
* **Removed Unicode characters**: Cleaned up emoji characters from R code files for better compatibility
* **Updated documentation**: Fixed argument mismatches in function documentation (e.g., `%nin%` operator)
* **Network dependency handling**: Ensured all network-dependent code in vignettes uses `eval=FALSE`
* **Enhanced examples**: Wrapped network-dependent examples in `\dontrun{}` blocks

### Code Quality Improvements

* Improved function documentation with accurate parameter descriptions
* Standardized error messages and validation patterns
* Enhanced CRAN submission readiness with better compliance checks
* Updated package structure for optimal build and check processes

---

# evanverse 0.3.1

A patch release focusing on CRAN submission preparation and cross-platform compatibility validation.

---

### Documentation & Release Preparation

* **CRAN Submission Checklist**: Added comprehensive checklist covering all policy
  requirements and compliance checks
* **Test Environment Documentation**: Created detailed `cran-comments.md` with
  test environments and submission documentation
* **Cross-Platform Compatibility**: Generated validation report confirming
  Windows/macOS/Linux support
* **Documentation Updates**: Updated package documentation with improved
  man pages and examples
* **Test Suite Validation**: Verified all 1336 tests pass with proper
  skip conditions for CRAN/CI environments

### Internal Improvements

* **File Path Handling**: Enhanced validation across all platforms with
  robust error handling
* **Platform-Specific Code**: Confirmed minimal platform dependencies with
  proper error handling
* **Dependency Validation**: Verified all dependencies are cross-platform compatible
* **Package Structure**: Cleaned up package structure by removing unnecessary `.here` file

---

# evanverse 0.3.0

A focused refactor release: unified CLI messaging, CRAN-safe startup, tighter parameter validation, stronger tests, and several new utilities.

---

### New Functions

* **`plot_forest()`** — Forest plots with publication-style defaults (forestploter),
  significance bolding, color recycling, and alignment options.

* **`plot_bar()`** — Bar charts with optional fill grouping, sorting,
  vertical/horizontal layout, and clean defaults.

* **`read_excel_flex()`** — Enhanced Excel reader (readxl) with optional name cleaning
  (janitor), range/col_types controls, and CLI feedback.

* **`write_xlsx_flex()`** — Flexible Excel writer (openxlsx) with header styling,
  auto column width, overwrite/timestamp options.

* **`view()`** — Quick interactive data viewer (reactable) for exploration/QC.

* **`set_mirror()`** — Switch CRAN/Bioconductor mirrors with predefined, named endpoints.

* **`pkg_functions()`** — List exported functions from any installed package,
  with optional keyword filtering.

---

### Enhancements & Refactors

* **`read_table_flex()`**
  - Inlined, robust delimiter detection for .csv/.tsv/.txt and .gz files
  - Stricter parameter checks and clearer CLI error messages
  - Enhanced encoding guardrails for better file handling

* **`update_pkg()`**
  - Source normalization via strict `match()` function
  - Supports only "CRAN", "GitHub", "Bioconductor" sources
  - Clearer messages and mirror handling aligned with `set_mirror()`

* **`pkg_version()`**
  - More robust CRAN/Bioconductor database retrieval
  - Helpful suggestions for GitHub package installations
  - Optional preview printing with clearer CLI output

* **Diagnostic Operators**
  - `%is%` and `%near%` messages standardized (no emoji)
  - Tighter type/shape checks with cleaner examples
  - `%nin%` implemented as `Negate(%in%)` with simple, predictable NA semantics

* **Data Utilities**
  - `map_column()` uses unified `cli` output and counts unmatched keys
  - Skips numeric columns by design, removes emoji, adds modular separators
  - `with_timer()` simplified using `tictoc` timing and `cli` output
  - `remind()` rendering fixed for `cli` braces with partial/case-insensitive matches
  - `rgb2hex()` input validation tightened with concise CLI feedback
  - `rows_with_void()` header streamlined, delegates detection to `is_void()`

* **Startup and Documentation**
  - `.onAttach` switched to plain `cli::cli_text()` messages (no emoji), CRAN-safe
  - Roxygen examples trimmed for non-interactive/CRAN environments
  - Consistent headers and separators throughout documentation

---

### Testing & QA

* **Test Structure Improvements**
  - Tests modularized and expanded with per-test `skip_on_cran()` / `skip_if_not_installed()`
  - Removed nested `test_that()` blocks for better organization
  - Strengthened assertions with more tolerant regex messages to avoid brittle failures

* **Enhanced Test Coverage**
  - Added/updated coverage for plotting functions: `plot_forest()`, `plot_bar()`
  - File I/O functions: `read_table_flex()`, `read_excel_flex()`, `write_xlsx_flex()`
  - Package management: `set_mirror()`, `pkg_functions()`
  - Utilities: `remind()`, `map_column()`, `replace_void()`, `rows_with_void()`, `rgb2hex()`
  - Operators: `%is%`, `%near%`, `%nin%`, `%p%`

* **Environment Compatibility**
  - Marked environment-dependent tests (e.g., `file_info()`) with `skip_on_cran()`
  - Ensured tests work reliably across different platforms and CI environments

---

### Internal Changes

* **Namespace and Data Access**
  - Fixed internal data access during package load to avoid namespace lookup errors
  - Removed direct `pkg::object` dependency for bundled data

* **Code Style and Standards**
  - Consistent CLI style implementation across all functions
  - Removed all emoji from code, comments, and roxygen documentation
  - Enhanced code readability and maintainability

---

# evanverse 0.2.0

A comprehensive upgrade with expanded tools for R developers and bioinformaticians.

---

### New Functions (by Category)

#### File & Data Management
- `file_info()`, `file_tree()`, `get_ext()`, `read_table_flex()`, `download_url()`

#### Package Management Tools
- `check_pkg()`, `inst_pkg()`, `update_pkg()`, `pkg_version()`

#### Bioinformatics Color Palettes
- `compile_palettes()`, `get_palette()`, `list_palettes()`, `create_palette()`
- `preview_palette()`, `bio_palette_gallery()`

#### Data Processing Tools
- `map_column()`, `df2list()`, `gmt2df()`, `gmt2list()`
- `convert_gene_id()`, `download_gene_ref()`

#### Development Helper Functions
- `remind()`, `with_timer()`, `%map%`, `%match%`, `%is%`, `%nin%`, `%p%`

#### Void Value Handling
- `is_void()`, `any_void()`, `drop_void()`, `replace_void()`
- `cols_with_void()`, `rows_with_void()`

#### Vector & Logic Operations
- `combine_logic()`, `hex2rgb()`, `rgb2hex()`

#### Visualization Tools
- `plot_venn()`, `plot_pie()`

---

### Internal Changes

- Removed GitHub Actions auto-deployment logic (`pkgdown.yaml`)
- Switched to local builds with `docs/` deployment to GitHub Pages
- Refactored documentation structure to improve package documentation readability

---

### Documentation

- **Online Documentation**: [evanbio.github.io/evanverse](https://evanbio.github.io/evanverse/)
- Comprehensive function reference with examples
- Getting started guides and tutorials

---

# evanverse 0.1.0

**First Release**

- Introduced `%p%` operator for expressive string concatenation
- Built modular structure with dev/00_setup.R, tests, and MIT license
- Added GitHub integration and install instructions
