# data-raw/import-trial.R

# 1. Load gtsummary package and extract example data
library(gtsummary)
data(trial)

# 2. Save trial to evanverse package data/ directory
#    overwrite = TRUE for future updates
usethis::use_data(trial, overwrite = TRUE)

