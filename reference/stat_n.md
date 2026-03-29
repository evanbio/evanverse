# Calculate Required Sample Size

Computes the minimum sample size needed to achieve a target statistical
power for detecting a given effect size. Supports t-tests (two-sample,
one-sample, paired), ANOVA, proportion tests, correlation tests, and
chi-square tests.

## Usage

``` r
stat_n(
  power = 0.8,
  effect_size,
  test = c("t_two", "t_one", "t_paired", "anova", "proportion", "correlation", "chisq"),
  alternative = c("two.sided", "less", "greater"),
  alpha = 0.05,
  k = NULL,
  df = NULL
)
```

## Arguments

- power:

  Numeric. Target statistical power. Default: 0.8.

- effect_size:

  Numeric. Effect size appropriate for the chosen test (must be
  positive). Conventions:

  - Cohen's d for t-tests (small 0.2, medium 0.5, large 0.8)

  - Cohen's f for ANOVA (small 0.1, medium 0.25, large 0.4)

  - Cohen's h for proportion tests (small 0.2, medium 0.5, large 0.8)

  - Pearson r for correlation (small 0.1, medium 0.3, large 0.5)

  - Cohen's w for chi-square (small 0.1, medium 0.3, large 0.5)

- test:

  Character. Test type: `"t_two"` (two-sample t-test, default),
  `"t_one"` (one-sample t-test), `"t_paired"` (paired t-test),
  `"anova"`, `"proportion"`, `"correlation"`, or `"chisq"`.

- alternative:

  Character. Direction of the alternative hypothesis: `"two.sided"`
  (default), `"less"`, or `"greater"`. Ignored for `"anova"` and
  `"chisq"`.

- alpha:

  Numeric. Significance level (Type I error rate). Default: 0.05.

- k:

  Integer \\\ge 2\\. Number of groups. Required when `test = "anova"`.

- df:

  Integer \\\ge 1\\. Degrees of freedom. Required when `test = "chisq"`.

## Value

An object of class `"power_result"` (invisibly) containing:

- `params`:

  Named list of all input parameters

- `n`:

  Required sample size, rounded up. Per group for `"t_two"` and
  `"anova"`; number of pairs for `"t_paired"`; total for all others.

- `computed`:

  `"n"` — distinguishes from
  [`stat_power()`](https://evanbio.github.io/evanverse/reference/stat_power.md)
  results where `computed = "power"`

- `interpretation`:

  Plain-text interpretation

- `recommendation`:

  Practical recruitment advice

Use `print(result)` for a brief summary, `summary(result)` for full
details, and `plot(result)` to display the sample size curve.

## See also

[`stat_power`](https://evanbio.github.io/evanverse/reference/stat_power.md)
for computing power given sample size.

## Examples

``` r
if (FALSE) { # \dontrun{
# Two-sample t-test (default)
result <- stat_n(power = 0.8, effect_size = 0.5)
print(result)
summary(result)
plot(result)

# ANOVA with 4 groups, higher power target
stat_n(power = 0.9, effect_size = 0.25, test = "anova", k = 4)

# Correlation, one-sided
stat_n(power = 0.8, effect_size = 0.3, test = "correlation",
       alternative = "greater")
} # }
```
