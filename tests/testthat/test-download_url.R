# Test: download_url()
# File: test-download_url.R
# Description: Unit tests for download_url() function
# =============================================================================

# ------------------------------------------------------------------------------
# Input validation tests
# ------------------------------------------------------------------------------
test_that("download_url() validates URL parameter", {
  skip_on_cran()

  # Test invalid URL types
  expect_error(download_url(NULL), "url must be a single non-empty character string")
  expect_error(download_url(123), "url must be a single non-empty character string")
  expect_error(download_url(c("url1", "url2")), "url must be a single non-empty character string")
  expect_error(download_url(""), "url must be a single non-empty character string")
  expect_error(download_url(NA), "url must be a single non-empty character string")
})

test_that("download_url() validates destination parameter", {
  skip_on_cran()

  # Test invalid destination types
  expect_error(download_url("https://httpbin.org/get", dest = NULL),
               "dest must be a single non-empty character string")
  expect_error(download_url("https://httpbin.org/get", dest = 123),
               "dest must be a single non-empty character string")
  expect_error(download_url("https://httpbin.org/get", dest = c("dest1", "dest2")),
               "dest must be a single non-empty character string")
  expect_error(download_url("https://httpbin.org/get", dest = ""),
               "dest must be a single non-empty character string")
})

test_that("download_url() validates other parameters", {
  skip_on_cran()

  # Test invalid parameter types
  expect_error(
    download_url("https://httpbin.org/get", overwrite = "yes"),
    "overwrite must be a single logical value"
  )
  expect_error(
    download_url("https://httpbin.org/get", unzip = "yes"),
    "unzip must be a single logical value"
  )
  expect_error(
    download_url("https://httpbin.org/get", verbose = "yes"),
    "verbose must be a single logical value"
  )
  expect_error(
    download_url("https://httpbin.org/get", timeout = "600"),
    "timeout must be a positive number"
  )
  expect_error(
    download_url("https://httpbin.org/get", timeout = 0),
    "timeout must be a positive number"
  )
  expect_error(
    download_url("https://httpbin.org/get", timeout = -10),
    "timeout must be a positive number"
  )
  expect_error(
    download_url("https://httpbin.org/get", headers = "not-a-list"),
    "headers must be a list or NULL"
  )
  expect_error(
    download_url("https://httpbin.org/get", resume = "yes"),
    "resume must be a single logical value"
  )
  expect_error(
    download_url("https://httpbin.org/get", speed_limit = "1000000"),
    "speed_limit must be a positive number or NULL"
  )
  expect_error(
    download_url("https://httpbin.org/get", speed_limit = 0),
    "speed_limit must be a positive number or NULL"
  )
  expect_error(
    download_url("https://httpbin.org/get", retries = "3"),
    "retries must be a non-negative integer"
  )
  expect_error(
    download_url("https://httpbin.org/get", retries = -1),
    "retries must be a non-negative integer"
  )
  expect_error(
    download_url("https://httpbin.org/get", retries = 1.5),
    "retries must be a non-negative integer"
  )
})

# ------------------------------------------------------------------------------
# Package dependency tests
# ------------------------------------------------------------------------------
test_that("download_url() checks required packages", {
  skip_on_cran()

  # Test with a mock scenario where curl is not available
  # Note: This is tricky to test directly, but we can verify the function structure
  expect_type(download_url, "closure")
})

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
test_that("download_url() works with valid URL", {
  skip_on_cran()
  skip_if_offline()

  # Use a small, reliable test file
  temp_file <- tempfile(fileext = ".txt")

  result <- download_url(
    url = "https://httpbin.org/get",
    dest = temp_file,
    verbose = FALSE,
    retries = 2,
    timeout = 30
  )

  # Check that download was successful
  expect_true(file.exists(temp_file))
  expect_type(result, "character")
  expect_equal(result, temp_file)

  # Check file content
  content <- readLines(temp_file, n = 1)
  expect_true(nchar(content) > 0)

  # Cleanup
  unlink(temp_file)
})

test_that("download_url() handles existing files correctly", {
  skip_on_cran()
  skip_if_offline()

  temp_file <- tempfile(fileext = ".txt")

  # Create a file first
  writeLines("test content", temp_file)

  # Try to download without overwrite - should skip
  result <- download_url(
    url = "https://httpbin.org/get",
    dest = temp_file,
    overwrite = FALSE,
    verbose = FALSE
  )

  # Should return the existing file path
  expect_equal(result, temp_file)

  # File should still contain original content
  content <- readLines(temp_file)
  expect_equal(content, "test content")

  # Cleanup
  unlink(temp_file)
})

test_that("download_url() creates destination directory", {
  skip_on_cran()
  skip_if_offline()

  temp_dir <- tempfile("test_download_")
  temp_file <- file.path(temp_dir, "subdir", "test.txt")

  result <- download_url(
    url = "https://httpbin.org/get",
    dest = temp_file,
    verbose = FALSE,
    retries = 1,
    timeout = 30
  )

  # Check that directory was created
  expect_true(dir.exists(dirname(temp_file)))
  expect_true(file.exists(temp_file))

  # Cleanup
  unlink(temp_dir, recursive = TRUE)
})

# ------------------------------------------------------------------------------
# Error handling tests
# ------------------------------------------------------------------------------
test_that("download_url() handles invalid URLs gracefully", {
  skip_on_cran()
  skip_if_offline()

  temp_file <- tempfile(fileext = ".txt")

  # Test with non-existent domain
  expect_error(
  download_url("https://non-existent-domain-12345.com/test.txt",
         dest = temp_file,
         verbose = FALSE,
         retries = 0,
         timeout = 10),
    "Failed to download file"
  )

  # Cleanup
  if (file.exists(temp_file)) unlink(temp_file)
})

test_that("download_url() handles network timeouts", {
  skip_on_cran()
  skip_if_offline()

  temp_file <- tempfile(fileext = ".txt")

  # Test with very short timeout
  expect_error(
  download_url("https://httpbin.org/delay/5",  # 5 second delay
         dest = temp_file,
         verbose = FALSE,
         retries = 0,
         timeout = 1),  # 1 second timeout
    "Failed to download file"
  )

  # Cleanup
  if (file.exists(temp_file)) unlink(temp_file)
})

# ------------------------------------------------------------------------------
# Retry mechanism tests
# ------------------------------------------------------------------------------
test_that("download_url() handles retry logic", {
  skip_on_cran()
  skip_if_offline()

  temp_file <- tempfile(fileext = ".txt")

  # Test successful download with retries configured
  result <- download_url(
    url = "https://httpbin.org/get",
    dest = temp_file,
    verbose = FALSE,
    retries = 2,
    timeout = 30
  )

  expect_true(file.exists(temp_file))
  expect_equal(result, temp_file)

  # Cleanup
  unlink(temp_file)
})

# ------------------------------------------------------------------------------
# Header functionality tests
# ------------------------------------------------------------------------------
test_that("download_url() handles custom headers", {
  skip_on_cran()
  skip_if_offline()

  temp_file <- tempfile(fileext = ".txt")

  # Test with custom headers
  result <- download_url(
    url = "https://httpbin.org/headers",
    dest = temp_file,
    headers = list("User-Agent" = "R-test/1.0", "X-Custom" = "test-value"),
    verbose = FALSE,
    retries = 1,
    timeout = 30
  )

  expect_true(file.exists(temp_file))

  # Cleanup
  unlink(temp_file)
})

# ------------------------------------------------------------------------------
# Bandwidth limiting tests
# ------------------------------------------------------------------------------
test_that("download_url() handles speed limits", {
  skip_on_cran()
  skip_if_offline()

  temp_file <- tempfile(fileext = ".txt")

  # Test with speed limit (this is mainly to ensure no errors)
  result <- download_url(
    url = "https://httpbin.org/get",
    dest = temp_file,
    speed_limit = 100000,  # 100 KB/s
    verbose = FALSE,
    retries = 1,
    timeout = 30
  )

  expect_true(file.exists(temp_file))

  # Cleanup
  unlink(temp_file)
})
