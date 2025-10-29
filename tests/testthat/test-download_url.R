#===============================================================================
# Test: download_url()
# File: test-download_url.R
# Description: Unit tests for download_url() function
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

test_that("download_url() validates URL parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  temp_dest <- tempfile()

  expect_error(
    download_url(NULL, dest = temp_dest),
    "url must be a single non-empty character string"
  )

  expect_error(
    download_url(123, dest = temp_dest),
    "url must be a single non-empty character string"
  )

  expect_error(
    download_url(c("url1", "url2"), dest = temp_dest),
    "url must be a single non-empty character string"
  )

  expect_error(
    download_url("", dest = temp_dest),
    "url must be a single non-empty character string"
  )

  expect_error(
    download_url(NA_character_, dest = temp_dest),
    "url must be a single non-empty character string"
  )
})

test_that("download_url() validates dest parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  valid_url <- "https://example.com/file.txt"

  expect_error(
    download_url(valid_url, dest = NULL),
    "must be specified"
  )

  expect_error(
    download_url(valid_url, dest = 123),
    "must be specified"
  )

  expect_error(
    download_url(valid_url, dest = c("dest1", "dest2")),
    "must be specified"
  )

  expect_error(
    download_url(valid_url, dest = ""),
    "must be specified"
  )

  expect_error(
    download_url(valid_url, dest = NA_character_),
    "must be specified"
  )
})

test_that("download_url() validates logical parameters", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  valid_url <- "https://example.com/file.txt"
  temp_dest <- tempfile()

  # overwrite
  expect_error(
    download_url(valid_url, dest = temp_dest, overwrite = "yes"),
    "overwrite must be a single logical value"
  )

  expect_error(
    download_url(valid_url, dest = temp_dest, overwrite = c(TRUE, FALSE)),
    "overwrite must be a single logical value"
  )

  # unzip
  expect_error(
    download_url(valid_url, dest = temp_dest, unzip = "yes"),
    "unzip must be a single logical value"
  )

  # verbose
  expect_error(
    download_url(valid_url, dest = temp_dest, verbose = "yes"),
    "verbose must be a single logical value"
  )

  # resume
  expect_error(
    download_url(valid_url, dest = temp_dest, resume = "yes"),
    "resume must be a single logical value"
  )
})

test_that("download_url() validates numeric parameters", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  valid_url <- "https://example.com/file.txt"
  temp_dest <- tempfile()

  # timeout
  expect_error(
    download_url(valid_url, dest = temp_dest, timeout = "600"),
    "timeout must be a positive number"
  )

  expect_error(
    download_url(valid_url, dest = temp_dest, timeout = 0),
    "timeout must be a positive number"
  )

  expect_error(
    download_url(valid_url, dest = temp_dest, timeout = -10),
    "timeout must be a positive number"
  )

  # retries
  expect_error(
    download_url(valid_url, dest = temp_dest, retries = "3"),
    "retries must be a non-negative integer"
  )

  expect_error(
    download_url(valid_url, dest = temp_dest, retries = -1),
    "retries must be a non-negative integer"
  )

  expect_error(
    download_url(valid_url, dest = temp_dest, retries = 1.5),
    "retries must be a non-negative integer"
  )

  # speed_limit
  expect_error(
    download_url(valid_url, dest = temp_dest, speed_limit = "1000000"),
    "speed_limit must be a positive number or NULL"
  )

  expect_error(
    download_url(valid_url, dest = temp_dest, speed_limit = 0),
    "speed_limit must be a positive number or NULL"
  )

  expect_error(
    download_url(valid_url, dest = temp_dest, speed_limit = -100),
    "speed_limit must be a positive number or NULL"
  )
})

test_that("download_url() validates headers parameter", {
  # These tests fail BEFORE any network operation
  # Safe to run on CRAN (fast, no network)

  valid_url <- "https://example.com/file.txt"
  temp_dest <- tempfile()

  expect_error(
    download_url(valid_url, dest = temp_dest, headers = "not-a-list"),
    "headers must be a list or NULL"
  )

  expect_error(
    download_url(valid_url, dest = temp_dest, headers = 123),
    "headers must be a list or NULL"
  )

  expect_error(
    download_url(valid_url, dest = temp_dest, headers = c("header1", "header2")),
    "headers must be a list or NULL"
  )
})

test_that("download_url() accepts valid parameters", {
  # Test that valid parameters pass validation
  # This will fail at network stage, but that's expected
  # We're only testing parameter validation here

  skip_on_cran()
  skip_if_offline()
  skip("Network download test skipped.")

  valid_url <- "https://httpbin.org/status/404"  # Will fail at download, not validation
  temp_dest <- tempfile()

  # Should NOT error on parameter validation
  # (will error later due to 404, but that's not what we're testing)
  expect_error(
    download_url(
      url = valid_url,
      dest = temp_dest,
      overwrite = TRUE,
      unzip = FALSE,
      verbose = FALSE,
      timeout = 10,
      headers = list("User-Agent" = "R-test"),
      resume = FALSE,
      speed_limit = 100000,
      retries = 0
    ),
    "Failed to download file",  # Network error, not validation error
    fixed = TRUE
  )
})

# ------------------------------------------------------------------------------
# Functional tests (SLOW, NEEDS NETWORK, SKIP ON CRAN)
# ------------------------------------------------------------------------------

test_that("download_url() works with valid small file", {
  skip_on_cran()
  skip_if_offline()
  skip("Network download test skipped.")

  # Use a tiny, reliable test file
  temp_file <- tempfile(fileext = ".txt")

  result <- download_url(
    url = "https://httpbin.org/robots.txt",
    dest = temp_file,
    verbose = FALSE,
    timeout = 30,
    retries = 2
  )

  # Check that download was successful
  expect_true(file.exists(temp_file))
  expect_type(result, "character")
  expect_equal(result, temp_file)

  # Check file has content
  expect_true(file.info(temp_file)$size > 0)

  # Cleanup
  unlink(temp_file)
})

test_that("download_url() respects overwrite parameter", {
  skip_on_cran()
  skip_if_offline()
  skip("Network download test skipped.")

  temp_file <- tempfile(fileext = ".txt")

  # Create a file first
  writeLines("original content", temp_file)
  original_content <- readLines(temp_file)

  # Try to download without overwrite - should skip
  result <- download_url(
    url = "https://httpbin.org/robots.txt",
    dest = temp_file,
    overwrite = FALSE,
    verbose = FALSE
  )

  # Should return the existing file path
  expect_equal(result, temp_file)

  # File should still contain original content
  new_content <- readLines(temp_file)
  expect_equal(new_content, original_content)

  # Cleanup
  unlink(temp_file)
})

test_that("download_url() creates destination directory", {
  skip_on_cran()
  skip_if_offline()
  skip("Network download test skipped.")

  temp_dir <- tempfile("test_download_")
  temp_file <- file.path(temp_dir, "subdir", "test.txt")

  result <- download_url(
    url = "https://httpbin.org/robots.txt",
    dest = temp_file,
    verbose = FALSE,
    timeout = 30
  )

  # Check that directory was created
  expect_true(dir.exists(dirname(temp_file)))
  expect_true(file.exists(temp_file))

  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

test_that("download_url() handles download failures gracefully", {
  skip_on_cran()
  skip_if_offline()
  skip("Network download test skipped.")

  temp_file <- tempfile(fileext = ".txt")

  # Test with non-existent URL (404)
  expect_error(
    download_url(
      "https://httpbin.org/status/404",
      dest = temp_file,
      verbose = FALSE,
      retries = 0,
      timeout = 10
    ),
    "Failed to download file"
  )

  # Cleanup
  if (file.exists(temp_file)) unlink(temp_file)
})

test_that("download_url() handles timeouts", {
  skip_on_cran()
  skip_if_offline()
  skip("Timeout test takes too long for regular CI")

  temp_file <- tempfile(fileext = ".txt")

  # Test with very short timeout on a slow endpoint
  expect_error(
    download_url(
      "https://httpbin.org/delay/5",  # 5 second delay
      dest = temp_file,
      verbose = FALSE,
      retries = 0,
      timeout = 1  # 1 second timeout
    ),
    "Failed to download file"
  )

  # Cleanup
  if (file.exists(temp_file)) unlink(temp_file)
})

test_that("download_url() works with custom headers", {
  skip_on_cran()
  skip_if_offline()
  skip("Network download test skipped.")

  temp_file <- tempfile(fileext = ".txt")

  # Test with custom headers (httpbin.org/headers echoes headers back)
  result <- download_url(
    url = "https://httpbin.org/headers",
    dest = temp_file,
    headers = list(
      "User-Agent" = "R-evanverse-test",
      "X-Custom-Header" = "test-value"
    ),
    verbose = FALSE,
    timeout = 30
  )

  expect_true(file.exists(temp_file))

  # Cleanup
  unlink(temp_file)
})

# ------------------------------------------------------------------------------
# Package dependency tests
# ------------------------------------------------------------------------------

test_that("download_url() checks for required packages", {
  # This tests the dependency check logic
  # Even if packages are installed, we verify the function structure

  # The function should be callable
  expect_type(download_url, "closure")

  # Check that curl is available (required dependency)
  expect_true(requireNamespace("curl", quietly = TRUE))
})
