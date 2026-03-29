# Get Started

## Overview

`evanverse` is a utility toolkit that combines package management, data
helpers, plotting tools, statistical workflows, and convenient
operators.

| Area               | Examples                                                                                                                                                                                                                                                                                                                                                                                              |
|--------------------|-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| Operators          | `%p%`, `%nin%`, `%match%`, `%map%`, `%is%`                                                                                                                                                                                                                                                                                                                                                            |
| Package management | [`set_mirror()`](https://evanbio.github.io/evanverse/reference/set_mirror.md), [`inst_pkg()`](https://evanbio.github.io/evanverse/reference/inst_pkg.md), [`check_pkg()`](https://evanbio.github.io/evanverse/reference/check_pkg.md), [`update_pkg()`](https://evanbio.github.io/evanverse/reference/update_pkg.md)                                                                                  |
| Data and parsing   | [`df2list()`](https://evanbio.github.io/evanverse/reference/df2list.md), [`df2vect()`](https://evanbio.github.io/evanverse/reference/df2vect.md), [`gmt2df()`](https://evanbio.github.io/evanverse/reference/gmt2df.md), [`gmt2list()`](https://evanbio.github.io/evanverse/reference/gmt2list.md)                                                                                                    |
| Statistics         | [`quick_ttest()`](https://evanbio.github.io/evanverse/reference/quick_ttest.md), [`quick_anova()`](https://evanbio.github.io/evanverse/reference/quick_anova.md), [`quick_chisq()`](https://evanbio.github.io/evanverse/reference/quick_chisq.md), [`quick_cor()`](https://evanbio.github.io/evanverse/reference/quick_cor.md)                                                                        |
| Plotting           | [`plot_bar()`](https://evanbio.github.io/evanverse/reference/plot_bar.md), [`plot_density()`](https://evanbio.github.io/evanverse/reference/plot_density.md), [`plot_pie()`](https://evanbio.github.io/evanverse/reference/plot_pie.md), [`plot_venn()`](https://evanbio.github.io/evanverse/reference/plot_venn.md), [`plot_forest()`](https://evanbio.github.io/evanverse/reference/plot_forest.md) |

``` r
library(evanverse)
```

> **Note:** All code examples are static (`eval = FALSE`). If you
> copy-paste everything at once and your fan starts roaring,
> congratulations: your laptop has entered “research mode”.

------------------------------------------------------------------------

## 1 First 30 Seconds

Try a few operators first:

``` r
"Good" %p% "morning"
#> [1] "Good morning"

c("A", "B", "C") %nin% c("B", "D")
#> [1]  TRUE FALSE  TRUE

c("tp53", "egfr") %match% c("TP53", "MYC", "EGFR")
#> [1] 1 3
```

------------------------------------------------------------------------

## 2 Install And Check Packages

Use built-in package-management helpers:

``` r
set_mirror("all", "tuna")

inst_pkg("dplyr", source = "CRAN")

check_pkg(c("dplyr", "ggplot2"), source = "CRAN")
#> # A tibble with installed status
```

Update packages when needed:

``` r
update_pkg(source = "CRAN")
```

------------------------------------------------------------------------

## 3 Quick Data Helpers

### `df2list()` and `df2vect()`

``` r
df <- data.frame(
  group = c("A", "A", "B"),
  gene  = c("TP53", "EGFR", "BRCA1"),
  score = c(1.2, 0.8, 1.6)
)

df2list(df, group_col = "group", value_col = "gene")
#> $A
#> [1] "TP53" "EGFR"
#> $B
#> [1] "BRCA1"

df2vect(df, name_col = "gene", value_col = "score")
#>  TP53  EGFR BRCA1
#>   1.2   0.8   1.6
```

### `toy_gmt()` with GMT parsers

``` r
path <- toy_gmt(n = 3)

gmt_df <- gmt2df(path)
head(gmt_df, 3)
#>                    term               description  gene
#> 1 HALLMARK_P53_PATHWAY   Genes regulated by p53  TP53
#> ...

gmt_list <- gmt2list(path)
names(gmt_list)
#> [1] "HALLMARK_P53_PATHWAY" "HALLMARK_MTORC1_SIGNALING" "HALLMARK_HYPOXIA"
```

------------------------------------------------------------------------

## 4 Quick Statistics

``` r
set.seed(42)
df <- data.frame(
  group = rep(c("A", "B"), each = 30),
  value = c(rnorm(30, 5), rnorm(30, 6))
)

res_t <- quick_ttest(df, group_col = "group", value_col = "value")
print(res_t)
#> t.test | p = ...
```

Correlation summary:

``` r
res_cor <- quick_cor(mtcars)
print(res_cor)
#> pearson | ... vars | ... significant pairs
```

------------------------------------------------------------------------

## 5 First Plot

``` r
plot_bar(
  data = data.frame(category = c("A", "B", "C"), value = c(10, 7, 12)),
  x_col = "category",
  y_col = "value"
)
#> # A ggplot object
```

------------------------------------------------------------------------

## 6 A Combined Workflow

``` r
# 1) Prepare toy reference and gene sets
ref  <- toy_gene_ref("human", n = 100)
path <- toy_gmt(n = 3)

# 2) Parse GMT and convert gene IDs
long <- gmt2df(path)
idm  <- gene2entrez(long$gene, ref = ref, species = "human")
long$entrez_id <- idm$entrez_id

# 3) Build list per term
long2 <- long[!is.na(long$entrez_id), ]
sets  <- df2list(long2, group_col = "term", value_col = "entrez_id")

# 4) Quick statistical and plotting step
res <- quick_cor(mtcars[, c("mpg", "hp", "wt", "qsec")])
plot(res, type = "upper", show_sig = TRUE)
```

------------------------------------------------------------------------

## Getting Help

- [`?"%p%"`](https://evanbio.github.io/evanverse/reference/grapes-p-grapes.md),
  [`?"%nin%"`](https://evanbio.github.io/evanverse/reference/grapes-nin-grapes.md),
  [`?"%match%"`](https://evanbio.github.io/evanverse/reference/grapes-match-grapes.md),
  [`?"%map%"`](https://evanbio.github.io/evanverse/reference/grapes-map-grapes.md),
  [`?"%is%"`](https://evanbio.github.io/evanverse/reference/grapes-is-grapes.md)
- [`?set_mirror`](https://evanbio.github.io/evanverse/reference/set_mirror.md),
  [`?inst_pkg`](https://evanbio.github.io/evanverse/reference/inst_pkg.md),
  [`?check_pkg`](https://evanbio.github.io/evanverse/reference/check_pkg.md),
  [`?update_pkg`](https://evanbio.github.io/evanverse/reference/update_pkg.md)
- [`?quick_ttest`](https://evanbio.github.io/evanverse/reference/quick_ttest.md),
  [`?quick_anova`](https://evanbio.github.io/evanverse/reference/quick_anova.md),
  [`?quick_chisq`](https://evanbio.github.io/evanverse/reference/quick_chisq.md),
  [`?quick_cor`](https://evanbio.github.io/evanverse/reference/quick_cor.md)
- [GitHub Issues](https://github.com/evanbio/evanverse/issues)
