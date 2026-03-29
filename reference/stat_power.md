# Calculate Statistical Power

Computes statistical power for a planned study given sample size, effect
size, and design parameters. Supports t-tests (two-sample, one-sample,
paired), ANOVA, proportion tests, correlation tests, and chi-square
tests.

## Usage

``` r
stat_power(
  n,
  effect_size,
  test = c("t_two", "t_one", "t_paired", "anova", "proportion", "correlation", "chisq"),
  alternative = c("two.sided", "less", "greater"),
  alpha = 0.05,
  k = NULL,
  df = NULL
)

# S3 method for class 'power_result'
plot(x, y = NULL, plot_range = NULL, ...)
```

## Arguments

- n:

  Integer. Sample size. Interpretation depends on test:

  - `"t_two"`, `"anova"`: per group

  - `"t_paired"`: number of pairs

  - all others: total

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

- x:

  A `power_result` object returned by `stat_power()` or
  [`stat_n()`](https://evanbio.github.io/evanverse/reference/stat_n.md).

- y:

  Ignored.

- plot_range:

  Numeric vector of length 2. Custom axis range for the curve. For
  `stat_power()` results: range over sample sizes. For
  [`stat_n()`](https://evanbio.github.io/evanverse/reference/stat_n.md)
  results: range over effect sizes. `NULL` uses an automatic range.

- ...:

  Additional arguments (currently unused).

## Value

An object of class `"power_result"` (invisibly) containing:

- `params`:

  Named list of all input parameters

- `power`:

  Computed statistical power (numeric in `[0, 1]`)

- `computed`:

  `"power"` — distinguishes from
  [`stat_n()`](https://evanbio.github.io/evanverse/reference/stat_n.md)
  results where `computed = "n"`

- `interpretation`:

  Plain-text interpretation of the power value

- `recommendation`:

  Actionable recommendation, or `NULL` when power is between 0.8 and
  0.95

Use `print(result)` for a brief summary, `summary(result)` for full
details, and `plot(result)` to display the power curve.

## Examples

``` r
if (FALSE) { # \dontrun{
result <- stat_power(n = 30, effect_size = 0.5)
print(result)
summary(result)
plot(result)

stat_power(n = 25, effect_size = 0.25, test = "anova", k = 3)
stat_power(n = 50, effect_size = 0.3,  test = "correlation",
           alternative = "greater")
} # }
```
