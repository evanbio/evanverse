## code to prepare `msigdb_h_df` dataset goes here

# 📦 Load required packages
library(GSEABase)
library(tibble)
library(tidyr)
library(cli)

# 📄 Path to the GMT file (already placed in inst/extdata)
gmt_file <- "inst/extdata/h.all.v2024.1.Hs.symbols.gmt"

# ✅ Check if file exists
if (!file.exists(gmt_file)) {
  cli::cli_abort("❌ GMT file not found at: {.path {gmt_file}}")
}

# 🔍 Parse the GMT file
gmt_obj <- getGmt(gmt_file)

# 🧬 Convert to long-format tibble
msigdb_h_df <- tibble(
  term = names(geneIds(gmt_obj)),
  description = vapply(gmt_obj, function(x) x@shortDescription, character(1)),
  gene = unname(geneIds(gmt_obj))
) |>
  unnest_longer(gene)

# 💾 Save to /data/
usethis::use_data(msigdb_h_df, overwrite = TRUE)

# 👁️ View structure (for visual check)
dplyr::glimpse(msigdb_h_df)

# 🎉 Done
cli::cli_alert_success("Generated {.val msigdb_h_df} with {nrow(msigdb_h_df)} rows and saved to {.file data/}.")
