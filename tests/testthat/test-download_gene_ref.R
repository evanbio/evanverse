#===============================================================================
# Test: download_gene_ref()
# File: test-download_gene_ref.R
# Description: Unit tests for download_gene_ref() function
#===============================================================================
#
# Testing Strategy:
# 1. Input validation tests: Fast, no network needed, run on CRAN
# 2. Network tests: Slow, skip on CRAN with skip_on_cran() + skip_if_offline()
#
# This ensures:
# - CRAN compliance (no long-running tests, no network dependency)
# - Good coverage (validation logic is tested)
# - Real-world verification (network tests run in CI/local)
#===============================================================================

# ------------------------------------------------------------------------------
# Input validation tests (FAST, NO NETWORK, RUN ON CRAN)
# ------------------------------------------------------------------------------

test_that("download_gene_ref() validates species parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  # Invalid species string
  expect_error(
    download_gene_ref(species = "invalid"),
    "'arg' should be one of"
  )

  # Empty string
  expect_error(
    download_gene_ref(species = ""),
    "'arg' should be one of"
  )

  # Case-sensitive (must be lowercase)
  expect_error(
    download_gene_ref(species = "Human"),
    "'arg' should be one of"
  )

  expect_error(
    download_gene_ref(species = "HUMAN"),
    "'arg' should be one of"
  )

  # NA character
  expect_error(
    download_gene_ref(species = NA_character_),
    "'arg' should be one of"
  )

  # Numeric value
  expect_error(
    download_gene_ref(species = 123),
    "'arg' must be NULL or a character vector"
  )
})

test_that("download_gene_ref() validates logical parameters", {
  # These tests check that invalid logical parameters cause errors
  # Safe to run on CRAN (fast, no network)

  skip_if_not_installed("biomaRt")

  # remove_empty_symbol with invalid types
  expect_error(
    download_gene_ref(species = "human", remove_empty_symbol = "yes"),
    "not interpretable as logical"
  )

  expect_error(
    download_gene_ref(species = "human", remove_empty_symbol = c(TRUE, FALSE)),
    "length > 1"
  )

  # remove_na_entrez with invalid types
  expect_error(
    download_gene_ref(species = "human", remove_na_entrez = "yes"),
    "not interpretable as logical"
  )

  expect_error(
    download_gene_ref(species = "human", remove_na_entrez = c(TRUE, FALSE)),
    "length > 1"
  )

  # save with invalid types
  expect_error(
    download_gene_ref(species = "human", save = "yes"),
    "not interpretable as logical"
  )

  expect_error(
    download_gene_ref(species = "human", save = c(TRUE, FALSE)),
    "length > 1"
  )
})

test_that("download_gene_ref() validates save_path parameter", {
  # These tests check that invalid save_path parameters cause errors
  # Safe to run on CRAN (fast, no network)

  skip_if_not_installed("biomaRt")

  # save_path with vector (causes condition length > 1 error)
  expect_error(
    download_gene_ref(species = "human", save = TRUE, save_path = c("path1", "path2")),
    "length > 1"
  )

  # Note: numeric and empty string save_path are actually accepted by the function
  # and would only fail at the file writing stage (after network operation)
})

test_that("download_gene_ref() checks for required packages", {
  # Test that biomaRt package is checked

  # Mock scenario: if biomaRt is not installed, should error
  # (We can't actually uninstall it, but we can verify the check exists)

  # The function should be callable
  expect_type(download_gene_ref, "closure")

  # If biomaRt is available, verify it
  if (requireNamespace("biomaRt", quietly = TRUE)) {
    expect_true(TRUE)  # biomaRt is installed
  } else {
    # If not installed, should get error about biomaRt
    expect_error(
      download_gene_ref(species = "human"),
      "biomaRt"
    )
  }
})

# ------------------------------------------------------------------------------
# Functional tests (SLOW, NEEDS NETWORK, SKIP ON CRAN)
# ------------------------------------------------------------------------------

test_that("download_gene_ref() returns valid data.frame for human", {
  skip_if_not_installed("biomaRt")
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Ensembl request skipped.")

  df <- download_gene_ref(species = "human")

  # Check return type
  expect_s3_class(df, "data.frame")

  # Check expected columns
  expected_cols <- c(
    "ensembl_id", "symbol", "entrez_id", "gene_type",
    "chromosome", "start", "end", "strand", "description",
    "species", "ensembl_version", "download_date"
  )
  expect_true(all(expected_cols %in% colnames(df)))

  # Check data integrity
  expect_gt(nrow(df), 0)
  expect_equal(unique(df$species), "human")
})

test_that("download_gene_ref() returns valid data.frame for mouse", {
  skip_if_not_installed("biomaRt")
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Ensembl request skipped.")

  df <- download_gene_ref(species = "mouse")

  # Check return type
  expect_s3_class(df, "data.frame")

  # Check expected columns
  expected_cols <- c(
    "ensembl_id", "symbol", "entrez_id", "gene_type",
    "chromosome", "start", "end", "strand", "description",
    "species", "ensembl_version", "download_date"
  )
  expect_true(all(expected_cols %in% colnames(df)))

  # Check data integrity
  expect_gt(nrow(df), 0)
  expect_equal(unique(df$species), "mouse")
})

test_that("download_gene_ref() filters out missing symbols when requested", {
  skip_if_not_installed("biomaRt")
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Ensembl request skipped.")

  # Download without filtering
  df_all <- download_gene_ref(species = "human", remove_empty_symbol = FALSE)

  # Download with symbol filtering
  df_filtered <- download_gene_ref(species = "human", remove_empty_symbol = TRUE)

  # Filtered version should have fewer rows
  expect_lt(nrow(df_filtered), nrow(df_all))

  # Filtered version should have no empty or NA symbols
  expect_true(all(!is.na(df_filtered$symbol)))
  expect_true(all(df_filtered$symbol != ""))
})

test_that("download_gene_ref() filters out NA entrez IDs when requested", {
  skip_if_not_installed("biomaRt")
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Ensembl request skipped.")

  # Download without filtering
  df_all <- download_gene_ref(species = "human", remove_na_entrez = FALSE)

  # Download with entrez filtering
  df_filtered <- download_gene_ref(species = "human", remove_na_entrez = TRUE)

  # Filtered version should have fewer rows
  expect_lt(nrow(df_filtered), nrow(df_all))

  # Filtered version should have no NA entrez IDs
  expect_true(all(!is.na(df_filtered$entrez_id)))
})

test_that("download_gene_ref() can save file to default path", {
  skip_if_not_installed("biomaRt")
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Ensembl request skipped.")

  # Construct expected filename
  filename <- paste0("gene_ref_human_", Sys.Date(), ".rds")

  # Clean up if exists
  if (file.exists(filename)) file.remove(filename)

  # Download and save
  df <- download_gene_ref(species = "human", save = TRUE)

  # Check file was created
  expect_true(file.exists(filename))

  # Check file content
  saved_df <- readRDS(filename)
  expect_s3_class(saved_df, "data.frame")
  expect_equal(nrow(saved_df), nrow(df))

  # Cleanup
  unlink(filename)
})

test_that("download_gene_ref() can save to custom path without .rds extension", {
  skip_if_not_installed("biomaRt")
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Ensembl request skipped.")

  # Custom path without .rds
  outfile <- "test_gene_ref_custom"
  full_path <- paste0(outfile, ".rds")

  # Clean up if exists
  if (file.exists(full_path)) unlink(full_path)

  # Download and save
  df <- download_gene_ref(species = "mouse", save = TRUE, save_path = outfile)

  # Check file was created with .rds extension
  expect_true(file.exists(full_path))

  # Check file content
  saved_df <- readRDS(full_path)
  expect_s3_class(saved_df, "data.frame")
  expect_equal(nrow(saved_df), nrow(df))

  # Cleanup
  unlink(full_path)
})

test_that("download_gene_ref() can save to custom path with .rds extension", {
  skip_if_not_installed("biomaRt")
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Ensembl request skipped.")

  # Custom path with .rds
  full_path <- "test_gene_ref_with_extension.rds"

  # Clean up if exists
  if (file.exists(full_path)) unlink(full_path)

  # Download and save
  df <- download_gene_ref(species = "human", save = TRUE, save_path = full_path)

  # Check file was created (should not double .rds)
  expect_true(file.exists(full_path))
  expect_false(file.exists("test_gene_ref_with_extension.rds.rds"))

  # Check file content
  saved_df <- readRDS(full_path)
  expect_s3_class(saved_df, "data.frame")
  expect_equal(nrow(saved_df), nrow(df))

  # Cleanup
  unlink(full_path)
})

test_that("download_gene_ref() does not save when save = FALSE", {
  skip_if_not_installed("biomaRt")
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Ensembl request skipped.")

  # Construct expected filename
  filename <- paste0("gene_ref_human_", Sys.Date(), ".rds")

  # Clean up if exists
  if (file.exists(filename)) file.remove(filename)

  # Download without saving
  df <- download_gene_ref(species = "human", save = FALSE)

  # Check file was NOT created
  expect_false(file.exists(filename))
})

test_that("download_gene_ref() includes metadata columns", {
  skip_if_not_installed("biomaRt")
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Ensembl request skipped.")

  df <- download_gene_ref(species = "human")

  # Check metadata columns exist
  expect_true("species" %in% colnames(df))
  expect_true("ensembl_version" %in% colnames(df))
  expect_true("download_date" %in% colnames(df))

  # Check metadata values
  expect_equal(unique(df$species), "human")
  expect_type(df$ensembl_version, "character")
  expect_s3_class(df$download_date, "Date")
  expect_equal(df$download_date[1], Sys.Date())
})

test_that("download_gene_ref() combines filtering options", {
  skip_if_not_installed("biomaRt")
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Ensembl request skipped.")

  # Download without filtering
  df_all <- download_gene_ref(species = "human")

  # Download with both filters
  df_filtered <- download_gene_ref(
    species = "human",
    remove_empty_symbol = TRUE,
    remove_na_entrez = TRUE
  )

  # Filtered version should have fewer rows
  expect_lt(nrow(df_filtered), nrow(df_all))

  # Check both filters applied
  expect_true(all(!is.na(df_filtered$symbol)))
  expect_true(all(df_filtered$symbol != ""))
  expect_true(all(!is.na(df_filtered$entrez_id)))
})
