# data-raw/simulate_forest_data.R
# --------------------------------------------
# Simulate a forest plot dataset: df_forest_test
# This dataset is intended for testing and demonstrating
# the plot_forest() function or other forest plot utilities
# --------------------------------------------

# ---- Load required packages ----
library(tidyverse)
library(usethis)

# ---- Create simulated data ----
df_forest_test <- tibble(
  variable = c(
    "Age (≥60)", "Sex (Male)", "BMI (High)",
    "Treatment A", "Treatment B", "Smoking",
    "Comorbidity", "Hypertension", "Diabetes",
    "CRP (Elevated)", "LDL-C (High)", "Physical Activity (Low)"
  ),
  estimate = c(
    1.42, 0.88, 1.20,
    0.75, 1.65, 1.05,
    1.35, 1.28, 0.97,
    1.58, 1.44, 0.72
  ),
  conf.low = c(
    1.10, 0.68, 0.95,
    0.56, 1.22, 0.82,
    1.01, 1.01, 0.72,
    1.20, 1.10, 0.54
  ),
  conf.high = c(
    1.83, 1.13, 1.52,
    1.00, 2.23, 1.35,
    1.80, 1.63, 1.31,
    2.08, 1.90, 0.96
  ),
  p.value = c(
    0.005, 0.270, 0.090,
    0.045, 0.003, 0.600,
    0.040, 0.038, 0.780,
    0.004, 0.015, 0.030
  )
)

# ---- Save as internal dataset ----
# This will create data/df_forest_test.rda
usethis::use_data(df_forest_test, overwrite = TRUE)
