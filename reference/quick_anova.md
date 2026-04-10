# One-way comparison with automatic method selection

Performs a one-way ANOVA, Welch ANOVA, or Kruskal-Wallis test with
automatic assumption checking and optional post-hoc comparisons.

## Usage

``` r
quick_anova(
  data,
  group_col,
  value_col,
  method = c("auto", "anova", "welch", "kruskal"),
  post_hoc = c("auto", "none", "tukey", "welch", "wilcox"),
  alpha = 0.05
)

# S3 method for class 'quick_anova_result'
plot(
  x,
  y = NULL,
  plot_type = c("boxplot", "violin", "both"),
  add_jitter = TRUE,
  point_size = 2,
  point_alpha = 0.6,
  show_p_value = TRUE,
  p_label = c("p.format", "p.signif"),
  palette = "qual_vivid",
  ...
)
```

## Arguments

- data:

  A data frame.

- group_col:

  Character. Column name for the grouping factor (2 or more levels).

- value_col:

  Character. Column name for the numeric response variable.

- method:

  One of `"auto"` (default), `"anova"`, `"welch"`, or `"kruskal"`.

- post_hoc:

  One of `"auto"` (default), `"none"`, `"tukey"`, `"welch"`, or
  `"wilcox"`.

- alpha:

  Numeric. Significance level. Default `0.05`.

- x:

  A `quick_anova_result` object from `quick_anova()`.

- y:

  Ignored.

- plot_type:

  One of `"boxplot"` (default), `"violin"`, `"both"`.

- add_jitter:

  Logical. Add jittered points? Default `TRUE`.

- point_size:

  Numeric. Jitter point size. Default `2`.

- point_alpha:

  Numeric. Jitter point transparency (0-1). Default `0.6`.

- show_p_value:

  Logical. Annotate plot with omnibus p-value? Default `TRUE`.

- p_label:

  One of `"p.format"` (default) or `"p.signif"` (stars).

- palette:

  evanverse palette name. Default `"qual_vivid"`. `NULL` uses ggplot2
  defaults.

- ...:

  Additional arguments passed to the internal plotting backend.

## Value

An object of class `"quick_anova_result"` (invisibly) containing:

- `omnibus_result`:

  List with test object, p-value, and effect size

- `post_hoc`:

  Post-hoc table (or `NULL` if none)

- `method_used`:

  Character: `"anova"`, `"welch"`, or `"kruskal"`

- `descriptive_stats`:

  Per-group summary data frame

- `assumption_checks`:

  List with normality and variance test results (diagnostics even when
  method is forced)

- `params`:

  List of input parameters

- `data`:

  Cleaned data frame (for
  [`plot()`](https://rdrr.io/r/graphics/plot.default.html) method)

Use `print(result)` for a brief summary, `summary(result)` for full
details, and `plot(result)` for a comparison plot.

## Details

**Auto method selection logic:**

1.  Normality checked per group via Shapiro-Wilk (sample-size-adaptive
    thresholds — see
    [`quick_ttest`](https://evanbio.github.io/evanverse/reference/quick_ttest.md)
    for details).

2.  If normality passes: Levene's test decides between classical ANOVA
    (equal variances) and Welch ANOVA (unequal variances).

3.  If normality fails: Kruskal-Wallis is used.

**Post-hoc defaults when `post_hoc = "auto"`:**

- `"anova"` → Tukey HSD

- `"welch"` → Pairwise Welch t-tests (BH-adjusted)

- `"kruskal"` → Pairwise Wilcoxon (BH-adjusted)

## See also

[`aov`](https://rdrr.io/r/stats/aov.html),
[`oneway.test`](https://rdrr.io/r/stats/oneway.test.html),
[`kruskal.test`](https://rdrr.io/r/stats/kruskal.test.html)

## Examples

``` r
set.seed(123)
df <- data.frame(
  group = rep(LETTERS[1:3], each = 40),
  value = rnorm(120, mean = rep(c(0, 0.5, 1.2), each = 40), sd = 1)
)
result <- quick_anova(df, group_col = "group", value_col = "value")
print(result)
#> One-way ANOVA | p < 0.001* | A n=40, B n=40, C n=40
summary(result)
#> 
#> ── One-way Comparison ──────────────────────────────────────────────────────────
#> 
#> ── Parameters ──
#> 
#> Test: One-way ANOVA
#> alpha: 0.050
#> 
#> ── Omnibus Test ──
#> 
#> ✔ p < 0.001  (significant at alpha = 0.05)
#> eta_squared = 0.224, omega_squared = 0.210
#> 
#>              Df Sum Sq Mean Sq F value   Pr(>F)    
#> group         2  27.51  13.755   16.91 3.53e-07 ***
#> Residuals   117  95.14   0.813                     
#> ---
#> Signif. codes:  0 ‘***’ 0.001 ‘**’ 0.01 ‘*’ 0.05 ‘.’ 0.1 ‘ ’ 1
#> 
#> ── Descriptive statistics ──
#> 
#> # A tibble: 3 × 7
#>   group     n   mean    sd median    min   max
#>   <fct> <int>  <dbl> <dbl>  <dbl>  <dbl> <dbl>
#> 1 A        40 0.0452 0.898 0.0906 -1.97   1.79
#> 2 B        40 0.493  0.960 0.437  -1.81   2.67
#> 3 C        40 1.21   0.844 1.15   -0.468  3.39
#> ── Normality (Shapiro-Wilk) ──
#> 
#> A: n = 40, p = 0.953
#> B: n = 40, p = 0.940
#> C: n = 40, p = 0.913
#> -> Medium samples (min n = 40). Data reasonably normal (all Shapiro p ≥ 0.01).
#> 
#> ── Variance (Levene's test) ──
#> 
#> p = 0.854 | equal variances: TRUE
#> 
#> ── Post-hoc (tukey) ──
#> 
#> # A tibble: 3 × 6
#>   group2 group1  diff     lwr   upr     `p adj`
#>   <chr>  <chr>  <dbl>   <dbl> <dbl>       <dbl>
#> 1 B      A      0.448 -0.0306 0.927 0.0716     
#> 2 C      A      1.16   0.684  1.64  0.000000201
#> 3 C      B      0.715  0.236  1.19  0.00163    
#> 
plot(result)
#> ! Could not load palette "qual_vivid". Using ggplot2 defaults.

```
