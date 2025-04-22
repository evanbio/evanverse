# =============================================================================
# 📦 Test: download_url()
# 📁 File: test-download_url.R
# 📋 Description: Unit tests for the download_url() helper function
# =============================================================================

test_that("download_url() downloads and returns path", {
  skip_if_offline()
  skip_on_cran()

  f <- tempfile(fileext = ".txt")
  url <- "https://raw.githubusercontent.com/r-lib/testthat/main/NEWS.md"

  result <- download_url(url, dest = f, verbose = FALSE)
  expect_true(file.exists(result))
  expect_match(result, "\\.txt$")
  file.remove(result)
})


test_that("download_url() downloads and unzips .zip files", {
  skip_if_offline()
  skip_on_cran()

  zip_url <- "https://github.com/r-lib/testthat/archive/refs/heads/main.zip"
  dest_zip <- tempfile(fileext = ".zip")

  result <- download_url(zip_url, dest = dest_zip, unzip = TRUE, verbose = FALSE)

  expect_true(file.exists(dest_zip))
  expect_true(any(file.exists(result)))  # At least one file unzipped

  unlink(dest_zip)
  unlink(result, recursive = TRUE)
})


test_that("download_url() downloads and decompresses .gz files", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("R.utils")

  gz_url <- "https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz"
  dest_gz <- tempfile(fileext = ".tar.gz")

  result <- download_url(gz_url, dest = dest_gz, unzip = TRUE, verbose = FALSE)
  expect_true(file.exists(dest_gz))
  expect_true(any(file.exists(result)))
  unlink(dest_gz)
  unlink(result, recursive = TRUE)
})
