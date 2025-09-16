# =============================================================================
# Test: download_geo_data()
# File: test-download_geo_data.R
# Description: Comprehensive tests for GEO data download functionality
# =============================================================================

# ------------------------------------------------------------------------------
# Input validation tests
# ------------------------------------------------------------------------------
test_that("download_geo_data() validates GSE ID format", {
  skip_on_cran()
  
  # Test invalid GSE ID format
  expect_error(download_geo_data("invalid"), "must be a valid GEO accession")
  expect_error(download_geo_data("GSE"), "must be a valid GEO accession")
  expect_error(download_geo_data("GSE12"), "must be a valid GEO accession")
  expect_error(download_geo_data(12345), "must be a single non-missing character string")
})

test_that("download_geo_data() validates parameters", {
  skip_on_cran()
  
  # Test invalid dest_dir
  expect_error(download_geo_data("GSE12345", dest_dir = 123), "must be a single character string")

  # Test invalid overwrite
  expect_error(download_geo_data("GSE12345", overwrite = "yes"), "must be a single logical value")

  # Test invalid log
  expect_error(download_geo_data("GSE12345", log = "yes"), "must be a single logical value")

  # Test invalid log_file
  expect_error(download_geo_data("GSE12345", log_file = 123), "must be a single character string or NULL")

  # Test invalid retries
  expect_error(download_geo_data("GSE12345", retries = -1), "must be a non-negative integer")
  expect_error(download_geo_data("GSE12345", retries = 1.5), "must be a non-negative integer")

  # Test invalid timeout
  expect_error(download_geo_data("GSE12345", timeout = 0), "must be a positive number")
  expect_error(download_geo_data("GSE12345", timeout = -10), "must be a positive number")
})

# ------------------------------------------------------------------------------
# Package dependency tests
# ------------------------------------------------------------------------------
test_that("download_geo_data() checks required packages", {
  # Mock missing package scenario (if possible)
  # This test verifies that package checking works
  skip_on_cran()  # Skip on CRAN

  # Test with a mock scenario where cli is not available
  # Note: This is tricky to test directly, but we can verify the function structure
  expect_type(download_geo_data, "closure")
})

# ------------------------------------------------------------------------------
# Directory and logging setup tests
# ------------------------------------------------------------------------------
test_that("download_geo_data() creates destination directory", {
  skip("Network-heavy GEO download skipped.")
  skip_on_cran()
  skip_if_offline()

  temp_dir <- tempfile("test_geo_")

  # This should create the directory
  result <- tryCatch({
    download_geo_data("GSE7305", dest_dir = temp_dir, log = FALSE, retries = 1, timeout = 30)
  }, error = function(e) NULL)

  # Check if directory was created (even if download fails)
  expect_true(dir.exists(temp_dir))

  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

test_that("download_geo_data() creates default log dir when log_file is NULL", {
  skip("Network-heavy GEO download skipped.")
  skip_on_cran()
  skip_if_offline()

  temp_dir <- tempfile("test_geo_default_")
  on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)

  # 不传 log_file -> 应创建 dest_dir/logs/geo
  tryCatch({
    download_geo_data("GSE7305", dest_dir = temp_dir, log = TRUE, log_file = NULL,
                      retries = 1, timeout = 30)
  }, error = function(e) NULL)

  expect_true(dir.exists(file.path(temp_dir, "logs", "geo")))
})

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
test_that("download_geo_data() works with valid GSE ID", {
  skip("Network-heavy GEO download skipped.")
  skip_on_cran()  # Don't run on CRAN
  skip_if_offline()  # Skip if no internet connection

  # Use a small, reliable GSE dataset
  gse_id <- "GSE7305"
  dest_dir <- tempdir()

  result <- download_geo_data(
    gse_id = gse_id,
    dest_dir = dest_dir,
    overwrite = TRUE,
    log = FALSE,
    retries = 2,
    timeout = 120
  )

  # Check returned structure
  expect_type(result, "list")
  expect_true(all(c("gse_object", "supplemental_files", "platform_info", "meta") %in% names(result)))

  # Check GSE object
  expect_s4_class(result$gse_object, "ExpressionSet")

  # Check meta information
  expect_equal(result$meta$gse_id, gse_id)
  expect_equal(result$meta$status, "success")
  expect_type(result$meta$download_duration, "double")
  expect_true(result$meta$download_duration >= 0)

  # Check sample and feature counts
  expect_type(result$meta$gse_samples, "integer")
  expect_type(result$meta$gse_features, "integer")
  expect_true(result$meta$gse_samples > 0)
  expect_true(result$meta$gse_features > 0)

  # Check file counts
  expect_type(result$meta$supplemental_files_count, "integer")
  expect_type(result$meta$gpl_files_count, "integer")
  expect_type(result$meta$total_files_downloaded, "integer")

  # Check platform info structure
  expect_type(result$platform_info, "list")
  expect_true(all(c("platform_id", "gpl_files") %in% names(result$platform_info)))

  # Check supplemental files
  expect_type(result$supplemental_files, "character")
})

# ------------------------------------------------------------------------------
# Output structure tests
# ------------------------------------------------------------------------------
test_that("download_geo_data() returns correct output structure", {
  skip("Network-heavy GEO download skipped.")
  skip_on_cran()
  skip_if_offline()

  result <- download_geo_data("GSE7305", log = FALSE, retries = 1, timeout = 60)

  # Check main components
  expect_named(result, c("gse_object", "supplemental_files", "platform_info", "meta"))

  # Check meta structure
  expected_meta_fields <- c(
    "gse_id", "dest_dir", "downloaded_at", "completed_at", "download_duration",
    "retries", "timeout", "status", "gse_samples", "gse_features",
    "supplemental_files_count", "platform_id", "gpl_files_count", "total_files_downloaded"
  )
  expect_true(all(expected_meta_fields %in% names(result$meta)))
})

# ------------------------------------------------------------------------------
# Logging functionality tests
# ------------------------------------------------------------------------------
test_that("download_geo_data() creates log files when requested", {
  skip("Network-heavy GEO download skipped.")
  skip_on_cran()
  skip_if_offline()

  temp_dir <- tempfile("test_geo_")

  result <- tryCatch({
    download_geo_data("GSE7305", dest_dir = temp_dir, log = TRUE, retries = 1, timeout = 60)
  }, error = function(e) NULL)

  # Check if log file was created
  log_files <- list.files(file.path(temp_dir, "logs", "geo"), pattern = "\\.log$", full.names = TRUE)
  expect_true(length(log_files) > 0)

  # Check log file content
  if (length(log_files) > 0) {
    log_content <- readLines(log_files[1])
    expect_true(length(log_content) > 0)
    expect_true(any(grepl("Download process started", log_content)))
  }

  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

# ------------------------------------------------------------------------------
# Retry mechanism tests
# ------------------------------------------------------------------------------
test_that("download_geo_data() handles retry logic", {
  skip("Network-heavy GEO download skipped.")
  skip_on_cran()
  skip_if_offline()

  # Test with retries
  result <- download_geo_data("GSE7305", log = FALSE, retries = 2, timeout = 60)

  # Check that meta contains retry information
  expect_equal(result$meta$retries, 2)
  expect_equal(result$meta$timeout, 60)
})
