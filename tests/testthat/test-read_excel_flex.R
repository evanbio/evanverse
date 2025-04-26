# =============================================================================
# 📦 Test: read_excel_flex()
# File: tests/testthat/test-read_excel_flex.R
# Author: Evan
# Description: Unit tests for the flexible Excel reader utility
# Dependencies: testthat, readxl, writexl
# =============================================================================

test_that("✅ read_excel_flex reads a basic Excel file correctly", {
  skip_if_not_installed("openxlsx")
  # Create temporary Excel file
  test_file <- tempfile(fileext = ".xlsx")
  test_data <- data.frame("Gene ID" = c("TP53", "EGFR"), "Expr Level" = c(5.2, 3.8))

  # Write test file
  writexl::write_xlsx(test_data, path = test_file)

  # Read using custom function
  df <- read_excel_flex(file_path = test_file)

  # Check structure
  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 2)
  expect_named(df, c("gene_id", "expr_level"))  # should be cleaned
})


test_that("❌ read_excel_flex throws error if file does not exist", {
  skip_if_not_installed("openxlsx")
  expect_error(
    read_excel_flex(file_path = "non_existent.xlsx"),
    regexp = "File not found"
  )
})


test_that("⚙️ read_excel_flex supports col_types override", {
  skip_if_not_installed("openxlsx")
  test_file <- tempfile(fileext = ".xlsx")
  test_data <- data.frame(ID = c("001", "002"), Value = c(10, 20))
  writexl::write_xlsx(test_data, path = test_file)

  df <- read_excel_flex(
    file_path = test_file,
    col_types = c("text", "numeric")
  )

  expect_type(df$id, "character")
  expect_type(df$value, "double")
})
