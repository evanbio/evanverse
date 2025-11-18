# Calculate Required Sample Size

Compute the minimum sample size required to achieve a specified
statistical power for detecting a given effect size. Supports multiple
test types including t-tests, ANOVA, proportion tests, correlation
tests, and chi-square tests.

## Usage

``` r
stat_samplesize(
  power = 0.8,
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

- power:

  Numeric. Target statistical power (probability of correctly rejecting
  the null hypothesis). Default: 0.8 (80%).

- effect_size:

  Numeric. Effect size appropriate for the test:

  - Cohen's d for t-tests (small: 0.2, medium: 0.5, large: 0.8)

  - Cohen's f for ANOVA (small: 0.1, medium: 0.25, large: 0.4)

  - Cohen's h for proportion tests (small: 0.2, medium: 0.5, large: 0.8)

  - Correlation coefficient r for correlation tests (small: 0.1, medium:
    0.3, large: 0.5)

  - Cohen's w for chi-square tests (small: 0.1, medium: 0.3, large: 0.5)

- test:

  Character. Type of statistical test: "t.test" (default), "anova",
  "proportion", "correlation", or "chisq".

- type:

  Character. For t-tests only: "two.sample" (default), "one.sample", or
  "paired".

- alternative:

  Character. Direction of alternative hypothesis: "two.sided" (default),
  "less", or "greater".

- alpha:

  Numeric. Significance level (Type I error rate). Default: 0.05.

- k:

  Integer. Number of groups (required for ANOVA).

- df:

  Integer. Degrees of freedom (required for chi-square tests).

- plot:

  Logical. Generate a sample size curve plot? Default: TRUE.

- plot_range:

  Numeric vector of length 2. Range of effect sizes for the curve. If
  NULL (default), automatically determined.

- palette:

  Character. evanverse palette name for the plot. Default: "qual_vivid".

- verbose:

  Logical. Print detailed diagnostic information? Default: TRUE.

## Value

An object of class `stat_samplesize_result` containing:

- n:

  Required sample size (per group for t-tests and ANOVA)

- n_total:

  Total sample size across all groups

- power:

  Target statistical power

- effect_size:

  Effect size used in the calculation

- alpha:

  Significance level

- test_type:

  Type of statistical test

- plot:

  ggplot2 object showing the sample size curve (if plot = TRUE)

- details:

  List with interpretation and recommendations

## Details

Sample size estimation is a critical step in research planning. This
function calculates the minimum number of participants needed to achieve
a specified statistical power (typically 0.8 or 80%) for detecting an
effect of a given size.

The function uses the pwr package for all calculations, ensuring
accurate results based on well-established statistical theory. Sample
sizes are always rounded up to the nearest integer.

## Sample Size Curve

When `plot = TRUE`, a sample size curve is generated showing how
required sample size changes with effect size. The curve helps
visualize:

- The current required sample size (marked with a red point)

- Reference lines for small, medium, and large effects

- How detecting smaller effects requires larger samples

## Important Notes

- Sample sizes are calculated per group for t-tests and ANOVA

- Consider adding 10-15% to account for potential dropout

- Very small effect sizes may require impractically large samples

## See also

[`stat_power`](https://evanbio.github.io/evanverse/reference/stat_power.md)
for calculating statistical power.

## Examples

``` r
if (FALSE) { # \dontrun{
# Example 1: Sample size for a two-sample t-test
result <- stat_samplesize(
  power = 0.8,
  effect_size = 0.5,
  test = "t.test",
  type = "two.sample"
)
print(result)
plot(result)

# Example 2: Sample size for ANOVA with 3 groups
stat_samplesize(
  power = 0.8,
  effect_size = 0.25,
  test = "anova",
  k = 3
)

# Example 3: Sample size for correlation test
stat_samplesize(
  power = 0.9,
  effect_size = 0.3,
  test = "correlation"
)
} # }
```
