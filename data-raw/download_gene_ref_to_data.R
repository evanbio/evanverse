# ==============================================================================
# 📦 Script: data-raw/download_gene_ref_to_data.R
# ------------------------------------------------------------------------------

# This script downloads and saves four versions of gene annotation reference
# tables using `download_gene_ref()`:
#   - Human (all)
#   - Human (filtered)
#   - Mouse (all)
#   - Mouse (filtered)
#
# Output files will be saved to `data/` for use as internal package data.
# ==============================================================================

library(evanverse)  # or devtools::load_all(".") if testing locally

# Create output directory if needed
if (!dir.exists("data")) dir.create("data")

# Human (all)
gene_ref_human_all <- download_gene_ref("human")
usethis::use_data(gene_ref_human_all, overwrite = TRUE)

# Human (filtered)
gene_ref_human_filtered <- download_gene_ref("human", remove_empty_symbol = TRUE, remove_na_entrez = TRUE)
usethis::use_data(gene_ref_human_filtered, overwrite = TRUE)

# Mouse (all)
gene_ref_mouse_all <- download_gene_ref("mouse")
usethis::use_data(gene_ref_mouse_all, overwrite = TRUE)

# Mouse (filtered)
gene_ref_mouse_filtered <- download_gene_ref("mouse", remove_empty_symbol = TRUE, remove_na_entrez = TRUE)
usethis::use_data(gene_ref_mouse_filtered, overwrite = TRUE)
