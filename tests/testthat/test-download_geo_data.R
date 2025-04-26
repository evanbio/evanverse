# tests/testthat/test-download_geo_data.R
#-------------------------------------------------------------------------------
# Tests for download_geo_data()
#-------------------------------------------------------------------------------

test_that("download_geo_data works correctly for a small GSE", {
  skip_on_cran()  # Don't run on CRAN
  skip_if_offline()  # Skip if no internet connection

  # Use a very small public GSE (example: GSE7305, but could be any small one)
  gse_id <- "GSE7305"
  dest_dir <- tempdir()  # Temporary directory

  result <- download_geo_data(
    gse_id = gse_id,
    dest_dir = dest_dir,
    overwrite = TRUE,
    log = FALSE,  # Skip log for testing
    retries = 1,
    timeout = 60
  )

  # Check returned structure
  expect_type(result, "list")
  expect_true(all(c("gse_object", "supplemental_files", "platform_info", "meta") %in% names(result)))

  # Check that gse_object is an ExpressionSet
  expect_s4_class(result$gse_object, "ExpressionSet")

  # Check meta information
  expect_equal(result$meta$gse_id, gse_id)
  expect_equal(result$meta$status, "success")
})
