<div align="center">

<img src="man/figures/logo.png" width="180" alt="evanverse logo" />

# evanverse

### *现代化的 R 数据科学与生物信息学工具包*

[![CRAN](https://www.r-pkg.org/badges/version/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse?branch=main)
[![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/evanverse)](https://CRAN.R-project.org/package=evanverse)

[📚 文档](https://evanbio.github.io/evanverse/) •
[🚀 快速开始](https://evanbio.github.io/evanverse/articles/get-started.html) •
[💬 问题反馈](https://github.com/evanbio/evanverse/issues) •
[🤝 参与贡献](CONTRIBUTING.md)

---

**语言版本:** [English](README.md) | 简体中文

</div>

---

## 当前状态

`evanverse` 目前正在积极维护中。CRAN 版本已被归档，v0.5.2 修复完成后将重新提交。

开发版可通过 GitHub 安装：

```r
devtools::install_github("evanbio/evanverse")
```

---

## 项目简介

**evanverse** 是一个 R 工具包，提供约 50 个函数，涵盖包管理、数据可视化、统计检验、生物信息学等领域。由 [Evan Zhou](mailto:evanzhou.bio@gmail.com) 开发。

```r
library(evanverse)

"你好" %p% "世界"                      # 字符串拼接
set_mirror("cran", "tuna")            # 配置 CRAN 镜像
plot_venn(list(A = 1:5, B = 3:8))    # 快速绘制韦恩图
quick_ttest(df, "group", "value")     # 自动选择 t 检验方法
gene2ensembl(c("TP53", "BRCA1"))      # 基因 ID 转换
```

---

## 安装

```r
# 稳定版（CRAN）
install.packages("evanverse")

# 开发版
devtools::install_github("evanbio/evanverse")
```

**系统要求：** R ≥ 4.1.0

---

## 函数列表

<details>
<summary><b>📦 包管理</b>（2 个）</summary>

- `pkg_functions()` — 列出包中的函数
- `set_mirror()` — 配置 CRAN / Bioconductor 镜像

> **说明：** `inst_pkg()`、`check_pkg()`、`update_pkg()` 和 `pkg_version()` 已从本包移除。我们发现 [pak](https://pak.r-lib.org/) 提供了更加优雅、高性能的包管理工作流——并行安装、统一的 `pak::pkg_install()` 接口（支持 CRAN / GitHub / Bioconductor），并内置状态查询与更新功能。推荐直接使用 pak。

</details>

<details>
<summary><b>🎨 数据可视化</b>（5 个）</summary>

- `plot_venn()` — 韦恩图
- `plot_forest()` — 森林图
- `plot_bar()` — 柱状图
- `plot_pie()` — 饼图
- `plot_density()` — 密度图

</details>

<details>
<summary><b>📊 统计分析</b>（6 个）</summary>

- `quick_ttest()` — 自动方法选择的 t 检验
- `quick_anova()` — 单因素方差分析（含事后检验）
- `quick_chisq()` — 卡方 / Fisher 精确检验
- `quick_cor()` — 相关性分析（含热力图）
- `stat_power()` — 统计功效分析
- `stat_n()` — 样本量计算

</details>

<details>
<summary><b>🌈 配色方案</b>（9 个）</summary>

- `get_palette()` — 获取配色
- `list_palettes()` — 列出可用配色
- `create_palette()` — 创建自定义配色
- `preview_palette()` — 预览配色
- `palette_gallery()` — 浏览全部配色
- `compile_palettes()` — 编译配色数据
- `remove_palette()` — 删除配色
- `hex2rgb()` / `rgb2hex()` — 颜色格式转换

</details>

<details>
<summary><b>📁 文件与下载</b>（7 个）</summary>

- `download_url()` — 下载单个 URL
- `download_batch()` — 批量下载
- `download_geo()` — 下载 GEO 数据集
- `file_info()` — 文件元信息
- `file_ls()` — 列出文件及元信息
- `file_tree()` — 目录树可视化
- `view()` — 交互式数据查看

</details>

<details>
<summary><b>🧬 生物信息学</b>（5 个）</summary>

- `gene2ensembl()` — 基因符号转 Ensembl ID
- `gene2entrez()` — 基因符号转 Entrez ID
- `download_gene_ref()` — 下载基因参考表
- `gmt2df()` — GMT 解析为数据框
- `gmt2list()` — GMT 解析为列表

</details>

<details>
<summary><b>🔧 数据处理</b>（3 个）</summary>

- `df2list()` — 数据框转命名列表
- `df2vect()` — 数据框列转命名向量
- `recode_column()` — 按映射表重编码列值

</details>

<details>
<summary><b>🧮 操作符与组合数学</b>（7 个）</summary>

- `%p%` — 字符串拼接
- `%is%` — 身份比较
- `%nin%` — 非成员判断
- `%map%` — 映射操作符
- `%match%` — 匹配操作符
- `comb()` — 组合数
- `perm()` — 排列数

</details>

<details>
<summary><b>🧪 测试数据</b>（2 个）</summary>

- `toy_gene_ref()` — 用于测试的小型基因参考表
- `toy_gmt()` — 用于测试的小型 GMT 文件

</details>

---

## 文档资源

完整文档、教程和函数参考：

👉 **[https://evanbio.github.io/evanverse/](https://evanbio.github.io/evanverse/)**

---

## 开源协议

MIT License © 2025–2026 [Evan Zhou](mailto:evanzhou.bio@gmail.com)

<div align="center">

**用 ❤️ 制作 by [Evan Zhou](https://github.com/evanbio)**

</div>
