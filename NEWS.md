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

### New functions

* `plot_forest()` — Forest plots with publication-style defaults (forestploter), significance bolding, color recycling, and alignment options.
* `plot_bar()` — Bar charts with optional fill grouping, sorting, vertical/horizontal layout, and clean defaults.
* `read_excel_flex()` — Enhanced Excel reader (readxl) with optional name cleaning (janitor), range/col\_types controls, and CLI feedback.
* `write_xlsx_flex()` — Flexible Excel writer (openxlsx) with header styling, auto column width, overwrite/timestamp options.
* `view()` — Quick interactive data viewer (reactable) for exploration/QC.
* `set_mirror()` — Switch CRAN/Bioconductor mirrors with predefined, named endpoints.
* `pkg_functions()` — List exported functions from any installed package, with optional keyword filtering.

---

### Enhancements & refactors

* `read_table_flex()`

  * Inlined, robust delimiter detection for .csv/.tsv/.txt and .gz; stricter parameter checks; clearer CLI errors; encoding guardrails.

* `update_pkg()`

  * Source normalization via strict `match()`; supports only “CRAN”, “GitHub”, “Bioconductor”; clearer messages; mirror handling aligned with `set_mirror()`.

* `pkg_version()`

  * More robust CRAN/Bioconductor DB retrieval; helpful suggestions for GitHub installs; optional preview printing; clearer CLI.

* Diagnostic operators

  * `%is%` and `%near%` messages standardized (no emoji); tighter type/shape checks; cleaner examples.
  * `%nin%` implemented as `Negate(%in%)` with simple, predictable NA semantics.

* Data utilities

  * `map_column()` uses unified `cli` output, counts unmatched keys, skips numeric columns by design, removes emoji, and adds modular separators.
  * `with_timer()` simplified per request; uses `tictoc` timing and `cli` output without redundant dependency checks.
  * `remind()` rendering fixed for `cli` braces; supports partial/case-insensitive keyword matches; consistent invisible returns.
  * `rgb2hex()` input validation tightened; supports single vector or list input with concise CLI feedback.
  * `rows_with_void()` header/roxygen streamlined; delegates detection to existing `is_void()`.

* Startup and docs

  * `.onAttach` switched to plain `cli::cli_text()` messages (no emoji), CRAN-safe.
  * Roxygen examples trimmed or wrapped for non-interactive / CRAN environments; consistent headers and separators.

---

### Testing & QA

* Tests modularized and expanded with per-test `skip_on_cran()` / `skip_if_not_installed()`; removed nested `test_that()` blocks.
* Strengthened assertions with more tolerant regex messages to avoid brittle failures.
* Added/updated coverage for: `plot_forest()`, `plot_bar()`, `read_table_flex()`, `read_excel_flex()`, `write_xlsx_flex()`, `set_mirror()`, `pkg_functions()`, `remind()`, `%is%`, `%near%`, `%nin%`, `%p%`, `map_column()`, `replace_void()`, `rows_with_void()`, `rgb2hex()`.
* Marked environment-dependent tests (e.g., `file_info()`) with `skip_on_cran()`.

---

### Internal changes

* Fixed internal data access during package load to avoid namespace lookup errors; removed direct `pkg::object` dependency for bundled data.
* Consistent CLI style across functions; removed all emoji from code/comments/roxygen.

---

# evanverse 0.2.0

A comprehensive upgrade with expanded tools for R developers and bioinformaticians.

---

### ✨ New functions (by category)

#### 📁 File & Data Management
- `file_info()`, `file_tree()`, `get_ext()`, `read_table_flex()`, `download_url()`

#### 📦 Package Management Tools
- `check_pkg()`, `inst_pkg()`, `update_pkg()`, `pkg_version()`

#### 🎨 Bioinformatics Color Palettes
- `compile_palettes()`, `get_palette()`, `list_palettes()`, `create_palette()`, `preview_palette()`, `bio_palette_gallery()`

#### 🔁 Data Processing Tools
- `map_column()`, `df2list()`, `gmt2df()`, `gmt2list()`, `convert_gene_id()`, `download_gene_ref()`

#### ⚙️ Development Helper Functions
- `remind()`, `with_timer()`, `%map%`, `%match%`, `%is%`, `%nin%`, `%p%`

#### 🧽 Void Value Handling
- `is_void()`, `any_void()`, `drop_void()`, `replace_void()`, `cols_with_void()`, `rows_with_void()`

#### 🧮 Vector & Logic Operations
- `combine_logic()`, `hex2rgb()`, `rgb2hex()`

#### 📊 Visualization Tools
- `plot_venn()`, `plot_pie()`

---

### 🧰 Internal changes
- Removed GitHub Actions auto-deployment logic (`pkgdown.yaml`), switched to local builds with `docs/` deployment to GitHub Pages.
- Refactored documentation structure to improve package documentation readability.

---

### 🔗 Documentation
- 📖 Online docs: [evanbio.github.io/evanverse](https://evanbio.github.io/evanverse/)

---

# evanverse 0.1.0

✨ First Release 🎉

- Introduced `%p%` operator for expressive string concatenation
- Built modular structure with dev/00_setup.R, tests, and MIT license
- Added GitHub integration and install instructions
