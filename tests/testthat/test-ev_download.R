# =============================================================================
# 📦 Test: ev_download()
# 📁 File: test-ev_download.R
# 📋 Description: Unit tests for the ev_download() helper function
# =============================================================================

test_that("ev_download() downloads and returns path", {
  skip_if_offline()
  skip_on_cran()

  f <- tempfile(fileext = ".txt")
  url <- "https://raw.githubusercontent.com/r-lib/testthat/main/NEWS.md"

  result <- ev_download(url, dest = f, verbose = FALSE)
  expect_true(file.exists(result))
  expect_match(result, "\\.txt$")
  file.remove(result)
})


test_that("ev_download() downloads and unzips .zip files", {
  skip_if_offline()
  skip_on_cran()

  zip_url <- "https://github.com/r-lib/testthat/archive/refs/heads/main.zip"
  dest_zip <- tempfile(fileext = ".zip")

  result <- ev_download(zip_url, dest = dest_zip, unzip = TRUE, verbose = FALSE)

  expect_true(file.exists(dest_zip))
  expect_true(any(file.exists(result)))  # Check at least one unzipped file

  unlink(dest_zip)
  unlink(result, recursive = TRUE)
})


test_that("ev_download() downloads and decompresses .gz files", {
  skip_if_offline()
  skip_on_cran()
  skip_if_not_installed("R.utils")

  gz_url <- "https://ftp.gnu.org/gnu/wget/wget-1.21.4.tar.gz"
  dest_gz <- tempfile(fileext = ".tar.gz")

  result <- ev_download(gz_url, dest = dest_gz, unzip = TRUE, verbose = FALSE)
  expect_true(file.exists(dest_gz))
  expect_true(any(file.exists(result)))
  unlink(dest_gz)
  unlink(result, recursive = TRUE)
})
