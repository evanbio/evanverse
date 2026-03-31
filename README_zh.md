# evanverse

![evanverse logo](reference/figures/logo.png)

### *现代化的 R 数据科学与生物信息学工具包*

[![CRAN](https://www.r-pkg.org/badges/version/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse?branch=main)
[![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/evanverse)](https://CRAN.R-project.org/package=evanverse)

[📚 文档](https://evanbio.github.io/evanverse/) • [🚀
快速开始](https://evanbio.github.io/evanverse/articles/get-started.html)
• [💬 问题反馈](https://github.com/evanbio/evanverse/issues) • [🤝
参与贡献](https://evanbio.github.io/evanverse/CONTRIBUTING.md)

------------------------------------------------------------------------

**语言版本:** [English](https://evanbio.github.io/evanverse/README.md)
\| 简体中文

------------------------------------------------------------------------

## 当前状态

`evanverse` 目前正在积极维护中。CRAN 版本已被归档，v0.5.2
修复完成后将重新提交。

开发版可通过 GitHub 安装：

``` r
devtools::install_github("evanbio/evanverse")
```

------------------------------------------------------------------------

## 项目简介

**evanverse** 是一个 R 工具包，提供约 50
个函数，涵盖包管理、数据可视化、统计检验、生物信息学等领域。由 [Evan
Zhou](mailto:evanzhou.bio@gmail.com) 开发。

``` r
library(evanverse)

"你好" %p% "世界"                      # 字符串拼接
inst_pkg("limma", source = "Bioc")    # 多源安装包
plot_venn(list(A = 1:5, B = 3:8))    # 快速绘制韦恩图
quick_ttest(df, "group", "value")     # 自动选择 t 检验方法
gene2ensembl(c("TP53", "BRCA1"))      # 基因 ID 转换
```

------------------------------------------------------------------------

## 安装

``` r
# 稳定版（CRAN）
install.packages("evanverse")

# 开发版
devtools::install_github("evanbio/evanverse")
```

**系统要求：** R ≥ 4.1.0

------------------------------------------------------------------------

## 函数列表

**📦 包管理**（6 个）

- [`check_pkg()`](https://evanbio.github.io/evanverse/reference/check_pkg.md)
  — 检查包是否已安装
- [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md)
  — 从 CRAN / GitHub / Bioconductor 安装
- [`update_pkg()`](https://evanbio.github.io/evanverse/reference/update_pkg.md)
  — 更新已安装的包
- [`pkg_version()`](https://evanbio.github.io/evanverse/reference/pkg_version.md)
  — 获取包版本
- [`pkg_functions()`](https://evanbio.github.io/evanverse/reference/pkg_functions.md)
  — 列出包中的函数
- [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md)
  — 配置 CRAN 镜像

**🎨 数据可视化**（5 个）

- [`plot_venn()`](https://evanbio.github.io/evanverse/reference/plot_venn.md)
  — 韦恩图
- [`plot_forest()`](https://evanbio.github.io/evanverse/reference/plot_forest.md)
  — 森林图
- [`plot_bar()`](https://evanbio.github.io/evanverse/reference/plot_bar.md)
  — 柱状图
- [`plot_pie()`](https://evanbio.github.io/evanverse/reference/plot_pie.md)
  — 饼图
- [`plot_density()`](https://evanbio.github.io/evanverse/reference/plot_density.md)
  — 密度图

**📊 统计分析**（6 个）

- [`quick_ttest()`](https://evanbio.github.io/evanverse/reference/quick_ttest.md)
  — 自动方法选择的 t 检验
- [`quick_anova()`](https://evanbio.github.io/evanverse/reference/quick_anova.md)
  — 单因素方差分析（含事后检验）
- [`quick_chisq()`](https://evanbio.github.io/evanverse/reference/quick_chisq.md)
  — 卡方 / Fisher 精确检验
- [`quick_cor()`](https://evanbio.github.io/evanverse/reference/quick_cor.md)
  — 相关性分析（含热力图）
- [`stat_power()`](https://evanbio.github.io/evanverse/reference/stat_power.md)
  — 统计功效分析
- [`stat_n()`](https://evanbio.github.io/evanverse/reference/stat_n.md)
  — 样本量计算

**🌈 配色方案**（9 个）

- [`get_palette()`](https://evanbio.github.io/evanverse/reference/get_palette.md)
  — 获取配色
- [`list_palettes()`](https://evanbio.github.io/evanverse/reference/list_palettes.md)
  — 列出可用配色
- [`create_palette()`](https://evanbio.github.io/evanverse/reference/create_palette.md)
  — 创建自定义配色
- [`preview_palette()`](https://evanbio.github.io/evanverse/reference/preview_palette.md)
  — 预览配色
- [`palette_gallery()`](https://evanbio.github.io/evanverse/reference/palette_gallery.md)
  — 浏览全部配色
- [`compile_palettes()`](https://evanbio.github.io/evanverse/reference/compile_palettes.md)
  — 编译配色数据
- [`remove_palette()`](https://evanbio.github.io/evanverse/reference/remove_palette.md)
  — 删除配色
- [`hex2rgb()`](https://evanbio.github.io/evanverse/reference/hex2rgb.md)
  /
  [`rgb2hex()`](https://evanbio.github.io/evanverse/reference/rgb2hex.md)
  — 颜色格式转换

**📁 文件与下载**（7 个）

- [`download_url()`](https://evanbio.github.io/evanverse/reference/download_url.md)
  — 下载单个 URL
- [`download_batch()`](https://evanbio.github.io/evanverse/reference/download_batch.md)
  — 批量下载
- [`download_geo()`](https://evanbio.github.io/evanverse/reference/download_geo.md)
  — 下载 GEO 数据集
- [`file_info()`](https://evanbio.github.io/evanverse/reference/file_info.md)
  — 文件元信息
- [`file_ls()`](https://evanbio.github.io/evanverse/reference/file_ls.md)
  — 列出文件及元信息
- [`file_tree()`](https://evanbio.github.io/evanverse/reference/file_tree.md)
  — 目录树可视化
- [`view()`](https://evanbio.github.io/evanverse/reference/view.md) —
  交互式数据查看

**🧬 生物信息学**（5 个）

- [`gene2ensembl()`](https://evanbio.github.io/evanverse/reference/gene2ensembl.md)
  — 基因符号转 Ensembl ID
- [`gene2entrez()`](https://evanbio.github.io/evanverse/reference/gene2entrez.md)
  — 基因符号转 Entrez ID
- [`download_gene_ref()`](https://evanbio.github.io/evanverse/reference/download_gene_ref.md)
  — 下载基因参考表
- [`gmt2df()`](https://evanbio.github.io/evanverse/reference/gmt2df.md)
  — GMT 解析为数据框
- [`gmt2list()`](https://evanbio.github.io/evanverse/reference/gmt2list.md)
  — GMT 解析为列表

**🔧 数据处理**（3 个）

- [`df2list()`](https://evanbio.github.io/evanverse/reference/df2list.md)
  — 数据框转命名列表
- [`df2vect()`](https://evanbio.github.io/evanverse/reference/df2vect.md)
  — 数据框列转命名向量
- [`recode_column()`](https://evanbio.github.io/evanverse/reference/recode_column.md)
  — 按映射表重编码列值

**🧮 操作符与组合数学**（7 个）

- `%p%` — 字符串拼接
- `%is%` — 身份比较
- `%nin%` — 非成员判断
- `%map%` — 映射操作符
- `%match%` — 匹配操作符
- [`comb()`](https://evanbio.github.io/evanverse/reference/comb.md) —
  组合数
- [`perm()`](https://evanbio.github.io/evanverse/reference/perm.md) —
  排列数

**🧪 测试数据**（2 个）

- [`toy_gene_ref()`](https://evanbio.github.io/evanverse/reference/toy_gene_ref.md)
  — 用于测试的小型基因参考表
- [`toy_gmt()`](https://evanbio.github.io/evanverse/reference/toy_gmt.md)
  — 用于测试的小型 GMT 文件

------------------------------------------------------------------------

## 文档资源

完整文档、教程和函数参考：

👉 **<https://evanbio.github.io/evanverse/>**

------------------------------------------------------------------------

## 开源协议

MIT License © 2025–2026 [Evan Zhou](mailto:evanzhou.bio@gmail.com)

**用 ❤️ 制作 by [Evan Zhou](https://github.com/evanbio)**
