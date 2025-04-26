# ==============================================================================
# 📦 Test: download_gene_ref()
# ------------------------------------------------------------------------------

# This file tests the `download_gene_ref()` function, which downloads standardized
# gene annotation tables for human or mouse using the biomaRt package. The tests
# include:
#   - Structure and class of the returned object
#   - Presence of expected columns
#   - Filtering behavior (e.g., remove_empty_symbol)
#   - Saving behavior with default and custom file paths
#
# Author: Chris (Evanverse Project)
# Created: {Sys.Date()}
# ==============================================================================

# Test: return is a valid data.frame with expected columns
test_that("download_gene_ref returns valid data.frame for human", {
  skip_if_not_installed("biomaRt")
  df <- download_gene_ref(species = "human")
  expect_s3_class(df, "data.frame")
  expect_true(all(c("ensembl_id", "symbol", "chromosome", "start", "end") %in% colnames(df)))
})

# Test: remove_empty_symbol works as intended
test_that("download_gene_ref filters out missing symbols", {
  skip_if_not_installed("biomaRt")
  df_all <- download_gene_ref(species = "human")
  df_filtered <- download_gene_ref(species = "human", remove_empty_symbol = TRUE)
  expect_lt(nrow(df_filtered), nrow(df_all))
})

# Test: save to default file path (auto-naming)
test_that("download_gene_ref can save file to default path", {
  skip_if_not_installed("biomaRt")
  filename <- paste0("gene_ref_human_", Sys.Date(), ".rds")
  if (file.exists(filename)) file.remove(filename)
  df <- download_gene_ref(species = "human", save = TRUE)
  expect_true(file.exists(filename))
  unlink(filename)  # cleanup
})

# Test: save to custom file path (auto-append .rds)
test_that("download_gene_ref can save to custom path without .rds", {
  skip_if_not_installed("biomaRt")
  outfile <- "test_gene_ref_custom"
  full_path <- paste0(outfile, ".rds")
  if (file.exists(full_path)) unlink(full_path)
  df <- download_gene_ref(species = "mouse", save = TRUE, save_path = outfile)
  expect_true(file.exists(full_path))
  unlink(full_path)  # cleanup
})
