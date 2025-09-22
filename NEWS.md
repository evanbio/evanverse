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

* Added comprehensive **CRAN submission checklist** covering all policy requirements and compliance checks
* Created **cran-comments.md** with detailed test environments and submission documentation
* Generated **cross-platform compatibility report** validating Windows/macOS/Linux support
* Updated package documentation with improved man pages and examples
* Verified all 1336 tests pass with proper skip conditions for CRAN/CI environments

### Internal Improvements

* Enhanced file path handling validation across all platforms
* Confirmed minimal platform-specific code with proper error handling
* Validated all dependencies are cross-platform compatible
* Cleaned up package structure by removing unnecessary `.here` file

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
