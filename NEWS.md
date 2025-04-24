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
