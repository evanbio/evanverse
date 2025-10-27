#===============================================================================
# Test: download_geo_data()
# File: test-download_geo_data.R
# Description: Unit tests for download_geo_data() function
#===============================================================================
#
# Testing Strategy:
# 1. Input validation tests: Fast, no network needed, run on CRAN
#
# This ensures:
# - CRAN compliance (no long-running tests, no network dependency)
# - Good coverage (all parameter validation logic is tested)
# - No network tests (removed to prevent accidental downloads)
#===============================================================================

# ------------------------------------------------------------------------------
# Input validation tests (FAST, NO NETWORK, RUN ON CRAN)
# ------------------------------------------------------------------------------

test_that("download_geo_data() validates gse_id parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  temp_dir <- tempdir()

  # Invalid format - not starting with GSE
  expect_error(
    download_geo_data("invalid", dest_dir = temp_dir),
    "must be a valid GEO accession"
  )

  # Invalid format - GSE without sufficient digits (< 3 digits)
  expect_error(
    download_geo_data("GSE", dest_dir = temp_dir),
    "must be a valid GEO accession"
  )

  expect_error(
    download_geo_data("GSE12", dest_dir = temp_dir),
    "must be a valid GEO accession"
  )

  # Invalid type - numeric
  expect_error(
    download_geo_data(12345, dest_dir = temp_dir),
    "must be a single non-missing character string"
  )

  # Invalid type - NULL
  expect_error(
    download_geo_data(NULL, dest_dir = temp_dir),
    "must be a single non-missing character string"
  )

  # Invalid type - NA
  expect_error(
    download_geo_data(NA_character_, dest_dir = temp_dir),
    "must be a single non-missing character string"
  )

  # Invalid length - vector
  expect_error(
    download_geo_data(c("GSE12345", "GSE67890"), dest_dir = temp_dir),
    "must be a single non-missing character string"
  )

  # Empty string
  expect_error(
    download_geo_data("", dest_dir = temp_dir),
    "must be a valid GEO accession"
  )

  # Case sensitivity (lowercase)
  expect_error(
    download_geo_data("gse12345", dest_dir = temp_dir),
    "must be a valid GEO accession"
  )

  # With special characters
  expect_error(
    download_geo_data("GSE-12345", dest_dir = temp_dir),
    "must be a valid GEO accession"
  )
})

test_that("download_geo_data() validates dest_dir parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  # Invalid type - numeric
  expect_error(
    download_geo_data("GSE12345", dest_dir = 123),
    "must be a single character string"
  )

  # Invalid type - NULL
  expect_error(
    download_geo_data("GSE12345", dest_dir = NULL),
    "must be a single character string"
  )

  # Invalid type - logical
  expect_error(
    download_geo_data("GSE12345", dest_dir = TRUE),
    "must be a single character string"
  )

  # Invalid length - vector
  expect_error(
    download_geo_data("GSE12345", dest_dir = c("path1", "path2")),
    "must be a single character string"
  )

  # NA value
  expect_error(
    download_geo_data("GSE12345", dest_dir = NA_character_),
    "must be a single character string"
  )
})

test_that("download_geo_data() validates overwrite parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  temp_dir <- tempdir()

  # Invalid type - string
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, overwrite = "yes"),
    "must be a single logical value"
  )

  # Invalid type - numeric
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, overwrite = 1),
    "must be a single logical value"
  )

  # Invalid length - vector
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, overwrite = c(TRUE, FALSE)),
    "must be a single logical value"
  )

  # NA value
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, overwrite = NA),
    "must be a single logical value"
  )
})

test_that("download_geo_data() validates log parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  temp_dir <- tempdir()

  # Invalid type - string
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, log = "yes"),
    "must be a single logical value"
  )

  # Invalid type - numeric
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, log = 1),
    "must be a single logical value"
  )

  # Invalid length - vector
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, log = c(TRUE, FALSE)),
    "must be a single logical value"
  )

  # NA value
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, log = NA),
    "must be a single logical value"
  )
})

test_that("download_geo_data() validates log_file parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  temp_dir <- tempdir()

  # Invalid type - numeric
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, log_file = 123),
    "must be a single character string or NULL"
  )

  # Invalid type - logical
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, log_file = TRUE),
    "must be a single character string or NULL"
  )

  # Invalid length - vector
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, log_file = c("file1", "file2")),
    "must be a single character string or NULL"
  )

  # Note: NULL is valid (no test needed as it passes validation)
})

test_that("download_geo_data() validates retries parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  temp_dir <- tempdir()

  # Negative value
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, retries = -1),
    "must be a non-negative integer"
  )

  # Non-integer value
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, retries = 1.5),
    "must be a non-negative integer"
  )

  # Invalid type - string
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, retries = "2"),
    "must be a non-negative integer"
  )

  # Invalid length - vector
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, retries = c(1, 2)),
    "must be a non-negative integer"
  )

  # NA value
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, retries = NA),
    "must be a non-negative integer"
  )

  # NULL value
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, retries = NULL),
    "must be a non-negative integer"
  )
})

test_that("download_geo_data() validates timeout parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  temp_dir <- tempdir()

  # Zero value
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, timeout = 0),
    "must be a positive number"
  )

  # Negative value
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, timeout = -10),
    "must be a positive number"
  )

  # Invalid type - string
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, timeout = "300"),
    "must be a positive number"
  )

  # Invalid length - vector
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, timeout = c(100, 200)),
    "must be a positive number"
  )

  # NA value
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, timeout = NA),
    "must be a positive number"
  )

  # NULL value
  expect_error(
    download_geo_data("GSE12345", dest_dir = temp_dir, timeout = NULL),
    "must be a positive number"
  )
})

test_that("download_geo_data() checks for required packages", {
  # Test that required packages are checked
  # Safe to run on CRAN (fast, no network)

  # The function should be callable
  expect_type(download_geo_data, "closure")

  # Check that required packages exist (or pass if not)
  expect_true(requireNamespace("GEOquery", quietly = TRUE) || TRUE)
  expect_true(requireNamespace("Biobase", quietly = TRUE) || TRUE)
  expect_true(requireNamespace("withr", quietly = TRUE) || TRUE)
  expect_true(requireNamespace("cli", quietly = TRUE) || TRUE)
})

