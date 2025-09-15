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

### ✨ 新增函数（按功能分类）

#### 📁 文件与数据管理
- `file_info()`, `file_tree()`, `get_ext()`, `read_table_flex()`, `download_url()`

#### 📦 包管理工具
- `check_pkg()`, `inst_pkg()`, `update_pkg()`, `pkg_version()`

#### 🎨 生信色板管理
- `compile_palettes()`, `get_palette()`, `list_palettes()`, `create_palette()`, `preview_palette()`, `bio_palette_gallery()`

#### 🔁 数据处理工具
- `map_column()`, `df2list()`, `gmt2df()`, `gmt2list()`, `convert_gene_id()`, `download_gene_ref()`

#### ⚙️ 辅助开发函数
- `remind()`, `with_timer()`, `%map%`, `%match%`, `%is%`, `%nin%`, `%p%`

#### 🧽 空值处理工具
- `is_void()`, `any_void()`, `drop_void()`, `replace_void()`, `cols_with_void()`, `rows_with_void()`

#### 🧮 向量/逻辑运算
- `combine_logic()`, `hex2rgb()`, `rgb2hex()`

#### 📊 可视化工具
- `plot_venn()`, `plot_pie()`

---

### 🧰 内部变更
- 移除了 GitHub Actions 自动部署逻辑（`pkgdown.yaml`），统一改为本地构建并通过 `docs/` 部署 GitHub Pages。
- 重构文档结构，提升包文档可读性。

---

### 🔗 文档链接
- 📖 在线文档: [[evanbio.github.io/evanverse](https://evanbio.github.io/evanverse/)](https://evanbio.github.io/evanverse/)

---

# evanverse 0.1.0

✨ First Release 🎉

- Introduced `%p%` operator for expressive string concatenation
- Built modular structure with dev/00_setup.R, tests, and MIT license
- Added GitHub integration and install instructions
