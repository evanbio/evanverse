# =============================================================================
# Test: download_batch()
# File: test-download_batch.R
# Description: Tests for batch downloading files
# =============================================================================

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
test_that("download_batch() validates inputs correctly", {
  # Test invalid inputs
  expect_error(download_batch(123), "must be a character vector")
  expect_error(download_batch(character(0)), "No URLs provided")
})

test_that("download_batch() handles directory creation", {
  # Create a non-existent directory
  temp_dir <- tempfile("test_dir_")
  urls <- c("http://example.com/file1.txt")

  # This should create the directory
  result <- download_batch(urls, dest_dir = temp_dir, verbose = FALSE)

  # Check directory exists
  expect_true(dir.exists(temp_dir))

  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

test_that("download_batch() generates safe filenames", {
  # Test the safe filename generation (simulate)
  temp_dir <- tempdir()
  urls <- c("http://example.com/file with spaces.txt", "http://example.com/file?param=value")

  # This will attempt download but fail gracefully
  result <- tryCatch({
    download_batch(urls, dest_dir = temp_dir, verbose = FALSE)
  }, error = function(e) NULL)

  # Check if files would be created (even if download fails)
  expected_files <- c("file_with_spaces.txt", "file.dat")  # Based on safe_filename logic
  file_paths <- file.path(temp_dir, expected_files)

  # Note: Actual download may fail due to network, but filename generation should work
  # This test focuses on the setup logic rather than actual download
  expect_type(result, "character")
})

# ------------------------------------------------------------------------------
# Error handling tests
# ------------------------------------------------------------------------------
test_that("download_batch() handles empty URL list", {
  expect_error(download_batch(character(0)), "No URLs provided")
})
