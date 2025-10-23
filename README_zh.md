<div align="center">

<img src="man/figures/logo.png" width="180" alt="evanverse logo" />

# evanverse

### *现代化的 R 数据科学与生物信息学工具包*

[![CRAN](https://www.r-pkg.org/badges/version/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse?branch=main)
[![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)

[📚 文档](https://evanbio.github.io/evanverse/) •
[🚀 快速开始](#安装) •
[💬 问题反馈](https://github.com/evanbio/evanverse/issues) •
[🤝 参与贡献](CONTRIBUTING.md)

---

**语言版本:** [English](README.md) | 简体中文

</div>

---

## ✨ 项目简介

**evanverse** 是一个全面的 R 工具包，旨在简化您的数据分析工作流程。由 [Evan Zhou](mailto:evanzhou.bio@gmail.com) 开发，将 55+ 个精心设计的函数集成到一个统一的工具包中，涵盖数据分析、可视化和生物信息学等领域。

### 为什么选择 evanverse？

```r
# 🎯 直观的操作符
"你好" %p% "世界"                      # → "你好世界"

# 🎨 优雅的可视化
plot_venn(list(A = 1:5, B = 3:8))     # 快速绘制韦恩图

# 📦 智能包管理
inst_pkg("dplyr", source = "CRAN")     # 多源安装包

# 🧬 生物信息学变简单
convert_gene_id(genes, from = "SYMBOL", to = "ENSEMBL")
```

---

## 🚀 安装

### 稳定版本 (CRAN)

```r
install.packages("evanverse")
```

### 开发版本

```r
# install.packages("devtools")
devtools::install_github("evanbio/evanverse")
```

**系统要求:** R ≥ 4.1.0

---

## 🎯 核心功能

<table>
<tr>
<td width="50%">

### 📦 包管理
- 多源安装 (CRAN、GitHub、Bioconductor)
- 版本检查与更新
- 包函数探索
- 镜像配置

</td>
<td width="50%">

### 🎨 数据可视化
- 开箱即用的绘图函数
- 生物信息学配色方案
- 韦恩图、森林图
- 柱状图、饼图、密度图

</td>
</tr>
<tr>
<td width="50%">

### 🧬 生物信息学
- 基因 ID 转换
- GMT 文件处理
- GEO 数据下载
- 参考数据管理

</td>
<td width="50%">

### 🔧 数据处理
- 灵活的文件读写
- 列映射工具
- 空值处理
- 数据转换

</td>
</tr>
<tr>
<td width="50%">

### 🧮 自定义操作符
- `%p%` - 字符串拼接
- `%is%` - 身份比较
- `%nin%` - 非成员运算
- `%map%`、`%match%` - 映射工具

</td>
<td width="50%">

### ⚙️ 工作流工具
- 计时器包装
- 安全执行
- 提醒系统
- 交互式查看

</td>
</tr>
</table>

---

## 💡 快速示例

### 字符串操作
```r
library(evanverse)

# 使用 %p% 拼接字符串
first_name %p% " " %p% last_name

# 检查元素不在集合中
5 %nin% c(1, 2, 3, 4)  # TRUE
```

### 配色方案
```r
# 列出所有可用配色
list_palettes()

# 获取配色方案
colors <- get_palette("celltype", n = 5)

# 预览配色
preview_palette("celltype")
```

### 文件操作
```r
# 灵活读取表格数据
data <- read_table_flex("data.csv")

# 可视化目录树
file_tree(".", max_depth = 2)
```

### 生物信息学工作流
```r
# 转换基因 ID
genes <- c("TP53", "BRCA1", "EGFR")
ensembl_ids <- convert_gene_id(genes, from = "SYMBOL", to = "ENSEMBL")

# 解析 GMT 文件
pathways <- gmt2list("pathway.gmt")
```

### 包管理
```r
# 从多个源安装包
inst_pkg(c("dplyr", "ggplot2"), source = "CRAN")
inst_pkg("limma", source = "Bioconductor")
inst_pkg("user/repo", source = "GitHub")

# 检查版本
pkg_version("evanverse")
```

---

## 📖 功能分类

<details>
<summary><b>📦 包管理</b> (6 个函数)</summary>

- `check_pkg()` - 检查包是否已安装
- `inst_pkg()` - 从多个源安装包
- `update_pkg()` - 更新已安装的包
- `pkg_version()` - 获取包版本
- `pkg_functions()` - 列出包中的函数
- `set_mirror()` - 配置 CRAN 镜像

</details>

<details>
<summary><b>🎨 可视化与绘图</b> (5 个函数)</summary>

- `plot_venn()` - 韦恩图
- `plot_forest()` - 森林图
- `plot_bar()` - 柱状图
- `plot_pie()` - 饼图
- `plot_density()` - 密度图

</details>

<details>
<summary><b>🌈 配色方案</b> (9 个函数)</summary>

- `get_palette()` - 获取配色方案
- `list_palettes()` - 列出可用配色
- `create_palette()` - 创建自定义配色
- `preview_palette()` - 预览配色
- `bio_palette_gallery()` - 浏览生物配色库
- `compile_palettes()` - 编译配色数据
- `remove_palette()` - 删除配色
- `hex2rgb()` - 十六进制转 RGB
- `rgb2hex()` - RGB 转十六进制

</details>

<details>
<summary><b>📁 文件与数据读写</b> (10 个函数)</summary>

- `read_table_flex()` - 灵活读取表格
- `read_excel_flex()` - 灵活读取 Excel
- `write_xlsx_flex()` - 灵活写入 Excel
- `download_url()` - 从 URL 下载
- `download_batch()` - 批量下载
- `download_geo_data()` - 下载 GEO 数据集
- `file_info()` - 文件信息
- `file_tree()` - 目录树
- `get_ext()` - 获取文件扩展名
- `view()` - 交互式数据查看器

</details>

<details>
<summary><b>🧬 生物信息学</b> (4 个函数)</summary>

- `convert_gene_id()` - 基因 ID 转换
- `download_gene_ref()` - 下载基因参考数据
- `gmt2df()` - GMT 转数据框
- `gmt2list()` - GMT 转列表

</details>

<details>
<summary><b>🔧 数据处理</b> (10 个函数)</summary>

- `df2list()` - 数据框转列表
- `map_column()` - 映射列值
- `is_void()` - 检查空值
- `any_void()` - 是否有空值
- `drop_void()` - 删除空值
- `replace_void()` - 替换空值
- `cols_with_void()` - 含空值的列
- `rows_with_void()` - 含空值的行

</details>

<details>
<summary><b>🧮 操作符与逻辑</b> (8 个函数)</summary>

- `%p%` - 字符串拼接操作符
- `%is%` - 身份比较
- `%nin%` - 非成员操作符
- `%map%` - 映射操作符
- `%match%` - 匹配操作符
- `combine_logic()` - 组合逻辑向量
- `comb()` - 组合数
- `perm()` - 排列数

</details>

<details>
<summary><b>⚙️ 工作流工具</b> (3 个函数)</summary>

- `with_timer()` - 计时执行
- `remind()` - 设置提醒
- `safe_execute()` - 安全函数执行

</details>

---

## 📚 文档资源

完整的文档、示例和教程：

👉 **[https://evanbio.github.io/evanverse/](https://evanbio.github.io/evanverse/)**

---

## 🤝 参与贡献

我们欢迎各种形式的贡献！详情请参阅 [贡献指南](CONTRIBUTING.md)。

- 🐛 [报告 Bug](https://github.com/evanbio/evanverse/issues/new?template=bug_report.yml)
- 💡 [功能建议](https://github.com/evanbio/evanverse/issues/new?template=feature_request.yml)
- 📖 [改进文档](https://github.com/evanbio/evanverse/issues/new?template=documentation.yml)
- ❓ [提问交流](https://github.com/evanbio/evanverse/issues/new?template=question.yml)

---

## 📜 开源协议

MIT License © 2025 [Evan Zhou](mailto:evanzhou.bio@gmail.com)

详见 [LICENSE.md](LICENSE.md)。

---

## 📊 项目状态

- ✅ **已发布至 CRAN** - 版本 0.3.7
- ✅ **稳定生命周期** - 生产环境可用
- ✅ **全面测试覆盖** - 完善的测试套件
- ✅ **持续维护** - 定期更新

---

<div align="center">

**用 ❤️ 制作 by [Evan Zhou](https://github.com/evanbio)**

[⬆ 返回顶部](#evanverse)

</div>
