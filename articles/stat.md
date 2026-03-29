# Statistical Utilities

## Overview

The stat module provides six functions across five common statistical
tasks:

| Task                           | Functions                                                                                                                                            |
|--------------------------------|------------------------------------------------------------------------------------------------------------------------------------------------------|
| Power and sample-size planning | [`stat_power()`](https://evanbio.github.io/evanverse/reference/stat_power.md), [`stat_n()`](https://evanbio.github.io/evanverse/reference/stat_n.md) |
| Two-group comparison           | [`quick_ttest()`](https://evanbio.github.io/evanverse/reference/quick_ttest.md)                                                                      |
| Multi-group comparison         | [`quick_anova()`](https://evanbio.github.io/evanverse/reference/quick_anova.md)                                                                      |
| Categorical association        | [`quick_chisq()`](https://evanbio.github.io/evanverse/reference/quick_chisq.md)                                                                      |
| Correlation analysis           | [`quick_cor()`](https://evanbio.github.io/evanverse/reference/quick_cor.md)                                                                          |

``` r
library(evanverse)
```

> **Note:** All code examples in this vignette are static
> (`eval = FALSE`). Output is hand-written to reflect the current
> implementation.

------------------------------------------------------------------------

## 1 Power And Sample-Size Planning

Both
[`stat_power()`](https://evanbio.github.io/evanverse/reference/stat_power.md)
and
[`stat_n()`](https://evanbio.github.io/evanverse/reference/stat_n.md)
support the same test families:

| `test`          | Meaning                    | Effect size |
|-----------------|----------------------------|-------------|
| `"t_two"`       | Two-sample t-test          | Cohen’s d   |
| `"t_one"`       | One-sample t-test          | Cohen’s d   |
| `"t_paired"`    | Paired t-test              | Cohen’s d   |
| `"anova"`       | One-way ANOVA              | Cohen’s f   |
| `"proportion"`  | One-sample proportion test | Cohen’s h   |
| `"correlation"` | Correlation test           | Pearson r   |
| `"chisq"`       | Chi-square test            | Cohen’s w   |

### `stat_power()` - Compute power from sample size

Given `n`, `effect_size`, and test settings, returns a `power_result`
object with computed power plus interpretation and recommendation.

``` r
res <- stat_power(n = 30, effect_size = 0.5)
print(res)
#> Power: 47.8%  (very low) | Two-sample t-test
#> n = 30 per group,  effect size = 0.500,  alpha = 0.050
```

For ANOVA, `k` is required:

``` r
stat_power(n = 25, effect_size = 0.25, test = "anova", k = 3)
#> # power_result object
```

For chi-square, `df` is required:

``` r
stat_power(n = 120, effect_size = 0.3, test = "chisq", df = 2)
#> # power_result object
```

Use S3 methods for reporting and visualization:

``` r
summary(res)
plot(res)
#> # A ggplot object: power curve over sample size
```

------------------------------------------------------------------------

### `stat_n()` - Compute required sample size

Given target `power` and expected `effect_size`, returns the minimum
required sample size (rounded up) as a `power_result` object.

``` r
res_n <- stat_n(power = 0.8, effect_size = 0.5)
print(res_n)
#> n = 64 per group (128 total) | Two-sample t-test
#> Target power = 80%,  effect size = 0.500,  alpha = 0.050
```

One-sided correlation example:

``` r
stat_n(
  power = 0.9,
  effect_size = 0.3,
  test = "correlation",
  alternative = "greater"
)
#> # power_result object
```

Use S3 methods as with
[`stat_power()`](https://evanbio.github.io/evanverse/reference/stat_power.md):

``` r
summary(res_n)
plot(res_n)
#> # A ggplot object: required n as a function of effect size
```

------------------------------------------------------------------------

## 2 Two-Group Comparison

### `quick_ttest()` - Automatic t-test / Wilcoxon test

[`quick_ttest()`](https://evanbio.github.io/evanverse/reference/quick_ttest.md)
compares exactly two groups for a numeric outcome. With
`method = "auto"`, it chooses `t.test` or `wilcox.test` based on
normality checks and sample-size-aware rules.

``` r
set.seed(42)
df <- data.frame(
  group = rep(c("A", "B"), each = 30),
  value = c(rnorm(30, 5), rnorm(30, 6))
)

res_t <- quick_ttest(df, group_col = "group", value_col = "value")
print(res_t)
#> t.test | p = 0.0012* | A n=30, B n=30
summary(res_t)
```

Paired comparison requires `paired = TRUE` and `id_col`:

``` r
set.seed(7)
df_p <- data.frame(
  id    = rep(1:20, 2),
  group = rep(c("pre", "post"), each = 20),
  value = c(rnorm(20, 10, 2), rnorm(20, 11, 2))
)

res_p <- quick_ttest(
  df_p,
  group_col = "group",
  value_col = "value",
  paired = TRUE,
  id_col = "id"
)
plot(res_p, plot_type = "both", p_label = "p.format")
```

------------------------------------------------------------------------

## 3 Multi-Group Comparison

### `quick_anova()` - Automatic ANOVA / Welch / Kruskal

[`quick_anova()`](https://evanbio.github.io/evanverse/reference/quick_anova.md)
compares 2+ groups for a numeric outcome and performs assumption
diagnostics.

Auto-selection logic:

1.  Check group normality.
2.  If normality passes, choose ANOVA vs Welch by variance equality.
3.  If normality fails, use Kruskal-Wallis.

``` r
set.seed(123)
df_a <- data.frame(
  group = rep(LETTERS[1:3], each = 40),
  value = rnorm(120, mean = rep(c(0, 0.5, 1.2), each = 40), sd = 1)
)

res_a <- quick_anova(df_a, group_col = "group", value_col = "value")
print(res_a)
#> One-way ANOVA | p < 0.001* | A n=40, B n=40, C n=40
summary(res_a)
```

You can force method and post-hoc behavior explicitly:

``` r
res_a2 <- quick_anova(
  df_a,
  group_col = "group",
  value_col = "value",
  method = "anova",
  post_hoc = "tukey"
)
plot(res_a2, plot_type = "violin")
```

------------------------------------------------------------------------

## 4 Categorical Association

### `quick_chisq()` - Auto chi-square / Fisher / McNemar

[`quick_chisq()`](https://evanbio.github.io/evanverse/reference/quick_chisq.md)
tests association between two categorical variables. With
`method = "auto"`, method choice depends on table shape and expected
frequencies.

``` r
set.seed(123)
df_c <- data.frame(
  treatment = sample(c("A", "B", "C"), 100, replace = TRUE),
  response  = sample(c("Success", "Failure"), 100, replace = TRUE,
                     prob = c(0.6, 0.4))
)

res_c <- quick_chisq(df_c, x_col = "treatment", y_col = "response")
print(res_c)
#> Chi-square test | p = 0.0410* | 3x2 | V = 0.20 (small)
summary(res_c)
```

2x2 small-sample Fisher example:

``` r
df_2x2 <- data.frame(
  exposed = c("Yes", "Yes", "No", "No", "Yes", "No"),
  event   = c("Yes", "No", "Yes", "No", "Yes", "No")
)

res_f <- quick_chisq(df_2x2, x_col = "exposed", y_col = "event", method = "fisher")
plot(res_f, plot_type = "heatmap")
```

`method = "mcnemar"` is for paired/matched categorical outcomes only.

------------------------------------------------------------------------

## 5 Correlation Analysis

### `quick_cor()` - Correlation matrix with significance summary

[`quick_cor()`](https://evanbio.github.io/evanverse/reference/quick_cor.md)
computes pairwise correlations, p-values, optional multiple-testing
adjustment, and returns a heatmap-ready result object.

``` r
res_cor <- quick_cor(mtcars)
print(res_cor)
#> pearson | 11 vars | 24/55 significant pairs (alpha = 0.05)
summary(res_cor)
```

Restrict variables and use BH-adjusted p-values:

``` r
res_cor2 <- quick_cor(
  mtcars,
  vars = c("mpg", "hp", "wt", "qsec"),
  method = "spearman",
  p_adjust_method = "BH"
)
plot(res_cor2, type = "upper", show_sig = TRUE)
```

If `p_adjust_method != "none"`, significance is based on adjusted
p-values.

------------------------------------------------------------------------

## 6 A Combined Workflow

The planning and analysis functions compose naturally in practice:

``` r
library(evanverse)

# 1. Plan sample size
plan <- stat_n(power = 0.8, effect_size = 0.5, test = "t_two")

# 2. Collect / prepare data and run a primary two-group test
set.seed(101)
df <- data.frame(
  group = rep(c("Control", "Treatment"), each = plan$n),
  value = c(rnorm(plan$n, 10, 2), rnorm(plan$n, 11, 2))
)
res_t <- quick_ttest(df, group_col = "group", value_col = "value")

# 3. Explore correlation structure among related numeric variables
res_c <- quick_cor(mtcars[, c("mpg", "disp", "hp", "wt", "qsec")])

# 4. Report + visualize
print(res_t)
plot(res_t)
print(res_c)
plot(res_c, type = "upper", show_sig = TRUE)
```

------------------------------------------------------------------------

## Getting Help

- [`?stat_power`](https://evanbio.github.io/evanverse/reference/stat_power.md),
  [`?stat_n`](https://evanbio.github.io/evanverse/reference/stat_n.md)
- [`?quick_ttest`](https://evanbio.github.io/evanverse/reference/quick_ttest.md),
  [`?quick_anova`](https://evanbio.github.io/evanverse/reference/quick_anova.md),
  [`?quick_chisq`](https://evanbio.github.io/evanverse/reference/quick_chisq.md),
  [`?quick_cor`](https://evanbio.github.io/evanverse/reference/quick_cor.md)
- `?print.power_result`, `?summary.power_result`,
  [`?plot.power_result`](https://evanbio.github.io/evanverse/reference/stat_power.md)
- [GitHub Issues](https://github.com/evanbio/evanverse/issues)
