# ==============================================================================
# data-raw/create_forest_data.R
# ==============================================================================
# Create comprehensive forest plot test dataset: forest_data
# ==============================================================================

library(usethis)

forest_data <- data.frame(
  variable = c(
    "Age", "BMI", "Sex", "Male", "Female",
    "BMI category", "<25", "25-30", "≥30",
    "Smoking", "Current/Former",
    "Treatment", "Control", "Treatment A", "Treatment B",
    "CRP quartiles", "Q1", "Q2", "Q3", "Q4",
    "LDL-C quartiles", "Q1", "Q2", "Q3", "Q4",
    "Region", "North America", "Europe", "Asia",
    "Multi-model", "Hypertension", "Diabetes", "Physical inactivity"
  ),
  est = c(
    1.28, 1.05, NA, 1.42, 0.88,
    NA, 1.00, 1.35, 1.78,
    NA, 1.52,
    NA, 1.00, 0.68, 0.55,
    NA, 1.00, 1.28, 1.65, 2.15,
    NA, 1.00, 1.18, 1.42, 1.88,
    NA, 1.35, 1.22, 0.98,
    NA, 1.85, 2.12, 1.42
  ),
  lower = c(
    1.15, 1.02, NA, 1.10, 0.65,
    NA, 0.75, 0.95, 1.25,
    NA, 1.18,
    NA, 0.80, 0.48, 0.38,
    NA, 0.78, 0.82, 1.08, 1.42,
    NA, 0.82, 0.76, 0.93, 1.25,
    NA, 0.98, 0.88, 0.68,
    NA, 1.42, 1.58, 1.08
  ),
  upper = c(
    1.43, 1.09, NA, 1.83, 1.18,
    NA, 1.33, 1.92, 2.53,
    NA, 1.96,
    NA, 1.25, 0.96, 0.80,
    NA, 1.28, 2.00, 2.52, 3.25,
    NA, 1.22, 1.84, 2.17, 2.83,
    NA, 1.86, 1.69, 1.41,
    NA, 2.41, 2.84, 1.87
  ),
  pval = c(
    0.001, 0.003, NA, 0.007, 0.380,
    NA, 1.000, 0.095, 0.002,
    NA, 0.001,
    NA, 1.000, 0.028, 0.002,
    NA, 1.000, 0.280, 0.020, 0.001,
    NA, 1.000, 0.460, 0.105, 0.003,
    NA, 0.068, 0.235, 0.910,
    NA, 0.001, 0.001, 0.012
  ),
  est_2 = c(
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    1.72, 1.95, 1.35
  ),
  lower_2 = c(
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    1.32, 1.45, 1.03
  ),
  upper_2 = c(
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    2.24, 2.62, 1.77
  ),
  pval_2 = c(
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    0.001, 0.001, 0.030
  ),
  est_3 = c(
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    1.58, 1.78, 1.28
  ),
  lower_3 = c(
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    1.20, 1.31, 0.97
  ),
  upper_3 = c(
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    2.08, 2.42, 1.69
  ),
  pval_3 = c(
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    0.001, 0.001, 0.082
  ),
  n_total = c(
    850, 850, NA, 425, 425,
    NA, 320, 310, 220,
    NA, 380,
    NA, 280, 285, 285,
    NA, 212, 213, 212, 213,
    NA, 212, 213, 212, 213,
    NA, 320, 285, 245,
    NA, 850, 850, 850
  ),
  n_event = c(
    210, 210, NA, 120, 90,
    NA, 55, 72, 83,
    NA, 105,
    NA, 85, 58, 45,
    NA, 35, 48, 58, 69,
    NA, 38, 46, 55, 71,
    NA, 82, 68, 60,
    NA, 195, 168, 178
  ),
  event_pct = c(
    24.7, 24.7, NA, 28.2, 21.2,
    NA, 17.2, 23.2, 37.7,
    NA, 27.6,
    NA, 30.4, 20.4, 15.8,
    NA, 16.5, 22.5, 27.4, 32.4,
    NA, 17.9, 21.6, 25.9, 33.3,
    NA, 25.6, 23.9, 24.5,
    NA, 22.9, 19.8, 20.9
  ),
  color_id = c(
    "cont", "cont", NA, "sex", "sex",
    NA, "bmi", "bmi", "bmi",
    NA, "smoking",
    NA, "treat", "treat", "treat",
    NA, "crp", "crp", "crp", "crp",
    NA, "ldl", "ldl", "ldl", "ldl",
    NA, "region", "region", "region",
    NA, "multi", "multi", "multi"
  ),
  note = c(
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA, NA,
    NA, NA, NA, NA, NA, NA, NA, NA, NA,
    "Model 1: Crude; Model 2: Age+Sex adjusted; Model 3: Fully adjusted",
    NA, NA, NA
  ),
  stringsAsFactors = FALSE
)

cat("\n=== Data Structure ===\n")
cat("Rows:", nrow(forest_data), "\n")
cat("Columns:", ncol(forest_data), "\n\n")

usethis::use_data(forest_data, overwrite = TRUE)

cat("✅ Successfully created: data/forest_data.rda\n\n")

cat("=== Preview ===\n")
print(head(forest_data[, c("variable", "est", "lower", "upper", "pval", "n_total")], 15))
