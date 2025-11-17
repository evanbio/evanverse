# Calculate Statistical Power

Compute the statistical power (probability of correctly rejecting the
null hypothesis) for a given sample size, effect size, and significance
level. Supports multiple test types including t-tests, ANOVA, proportion
tests, correlation tests, and chi-square tests.

## Usage

``` r
stat_power(
  n,
  effect_size,
  test = c("t.test", "anova", "proportion", "correlation", "chisq"),
  type = c("two.sample", "one.sample", "paired"),
  alternative = c("two.sided", "less", "greater"),
  alpha = 0.05,
  k = NULL,
  df = NULL,
  plot = TRUE,
  plot_range = NULL,
  palette = "qual_vivid",
  verbose = TRUE
)
```

## Arguments

- n:

  Integer. Sample size. Interpretation depends on test type:

  - t-tests and ANOVA: Sample size per group

  - Proportion test: Total sample size (one-sample test)

  - Correlation: Total number of paired observations

  - Chi-square: Total sample size

- effect_size:

  Numeric. Effect size appropriate for the test (must be positive):

  - Cohen's d for t-tests (small: 0.2, medium: 0.5, large: 0.8)

  - Cohen's f for ANOVA (small: 0.1, medium: 0.25, large: 0.4)

  - Cohen's h for proportion tests (small: 0.2, medium: 0.5, large: 0.8)

  - Correlation coefficient r for correlation tests (small: 0.1, medium:
    0.3, large: 0.5). Use absolute value; power is the same for positive
    and negative correlations.

  - Cohen's w for chi-square tests (small: 0.1, medium: 0.3, large: 0.5)

- test:

  Character. Type of statistical test: "t.test" (default), "anova",
  "proportion", "correlation", or "chisq".

- type:

  Character. For t-tests only: "two.sample" (default), "one.sample", or
  "paired".

- alternative:

  Character. Direction of alternative hypothesis: "two.sided" (default),
  "less", or "greater". Note: Only applicable to t-tests, proportion
  tests, and correlation tests. Ignored for ANOVA and chi-square tests
  (which are inherently non-directional).

- alpha:

  Numeric. Significance level (Type I error rate). Default: 0.05.

- k:

  Integer. Number of groups (required for ANOVA).

- df:

  Integer. Degrees of freedom (required for chi-square tests).

- plot:

  Logical. Generate a power curve plot? Default: TRUE.

- plot_range:

  Numeric vector of length 2. Range of sample sizes for the power curve.
  If NULL (default), automatically determined.

- palette:

  Character. evanverse palette name for the plot. Default: "qual_vivid".

- verbose:

  Logical. Print detailed diagnostic information? Default: TRUE.

## Value

An object of class `stat_power_result` containing:

- power:

  The calculated statistical power (probability of detecting the effect)

- n:

  Sample size used in the calculation

- effect_size:

  Effect size used in the calculation

- alpha:

  Significance level

- test_type:

  Type of statistical test

- test_subtype:

  Subtype for t-tests (e.g., "two.sample", "one.sample", "paired"); NULL
  for other tests

- alternative:

  Direction of alternative hypothesis used in the test

- k:

  Number of groups (for ANOVA); NULL for other tests

- df:

  Degrees of freedom (for chi-square tests); NULL for other tests

- plot:

  ggplot2 object showing the power curve (if plot = TRUE); NULL
  otherwise

- pwr_object:

  Raw result object from the pwr package function

- details:

  List with interpretation and recommendation text

- timestamp:

  POSIXct timestamp of when the calculation was performed

## Details

Statistical power is the probability of correctly rejecting the null
hypothesis when it is false (i.e., detecting a true effect).
Conventionally, a power of 0.8 (80%) is considered adequate, though
higher power (0.9 or 0.95) may be desirable in some contexts.

The function uses the pwr package for all power calculations, ensuring
accurate results based on well-established statistical theory.

## Test-Specific Notes

**Proportion Test:** Uses `pwr.p.test`, which is for one-sample
proportion tests (testing a single proportion against a hypothesized
value). For two-sample proportion tests, consider using specialized
tools or packages. The `effect_size` parameter uses Cohen's h, which
quantifies the difference between two proportions. In one-sample
settings, Cohen's h is computed from the observed proportion *p* and the
null hypothesis proportion *p0*.

## Power Curve

When `plot = TRUE`, a power curve is generated showing how statistical
power changes with sample size. The curve helps visualize:

- The current power level (marked with a red point)

- The conventional 0.8 power threshold (red dashed line)

- How increasing sample size affects power

## Examples

``` r
if (FALSE) { # \dontrun{
# Example 1: Power for a two-sample t-test
result <- stat_power(
  n = 30,
  effect_size = 0.5,
  test = "t.test",
  type = "two.sample"
)
print(result)
plot(result)

# Example 2: Power for ANOVA with 3 groups
stat_power(
  n = 25,
  effect_size = 0.25,
  test = "anova",
  k = 3
)

# Example 3: Power for correlation test
stat_power(
  n = 50,
  effect_size = 0.3,
  test = "correlation"
)
} # }

```
