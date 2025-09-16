# data‑raw/import‑trial.R

# 1. 加载 gtsummary 包并取出示例数据
library(gtsummary)
data(trial)

# 2. 保存 trial 到 evanverse 包的 data/ 目录
#    overwrite = TRUE 如果以后想更新也方便
usethis::use_data(trial, overwrite = TRUE)

