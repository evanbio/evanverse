# Comprehensive Forest Plot Dataset

A comprehensive dataset for demonstrating advanced forest plot
functionality. Contains multiple variable types (continuous,
categorical, hierarchical), multi-model comparisons, sample sizes, and
color grouping information.

## Format

A data frame with 33 rows and 15 columns:

- variable:

  Character vector of variable names and group headers

- est:

  Numeric vector of effect estimates (Model 1 or single model)

- lower:

  Numeric vector of lower confidence limits (Model 1)

- upper:

  Numeric vector of upper confidence limits (Model 1)

- pval:

  Numeric vector of p-values (Model 1)

- est_2:

  Numeric vector of effect estimates for Model 2 (NA for single-model
  rows)

- lower_2:

  Numeric vector of lower confidence limits for Model 2

- upper_2:

  Numeric vector of upper confidence limits for Model 2

- pval_2:

  Numeric vector of p-values for Model 2

- est_3:

  Numeric vector of effect estimates for Model 3

- lower_3:

  Numeric vector of lower confidence limits for Model 3

- upper_3:

  Numeric vector of upper confidence limits for Model 3

- pval_3:

  Numeric vector of p-values for Model 3

- n_total:

  Numeric vector of total sample sizes

- n_event:

  Numeric vector of event counts

- event_pct:

  Numeric vector of event percentages

- color_id:

  Character vector of color group identifiers for visualization

- note:

  Character vector of notes and model descriptions

## Source

Created for testing and demonstration of plot_forest() functionality.

## Details

This dataset demonstrates various forest plot scenarios:

- Continuous variables (Age, BMI)

- Categorical variables with subgroups (Sex, BMI category, Treatment)

- Multi-level hierarchical structures

- Multi-model comparisons (Models 1-3 for last 3 rows)

- Sample size and event information

- Color grouping for enhanced visualizations
