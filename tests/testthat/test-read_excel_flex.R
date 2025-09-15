#===============================================================================
# Test: read_excel_flex()
# File: tests/testthat/test-read_excel_flex.R
# Description: Unit tests for the flexible Excel reader utility
# Dependencies: testthat, readxl, writexl, janitor
#===============================================================================

#------------------------------------------------------------------------------
# Basic read & name cleaning
#------------------------------------------------------------------------------
test_that("read_excel_flex reads a basic Excel file and cleans names", {
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")
  skip_if_not_installed("janitor")

  test_file <- tempfile(fileext = ".xlsx")
  test_data <- data.frame("Gene ID" = c("TP53", "EGFR"),
                          "Expr Level" = c(5.2, 3.8),
                          check.names = FALSE)
  writexl::write_xlsx(test_data, path = test_file)

  df <- read_excel_flex(file_path = test_file)

  expect_s3_class(df, "data.frame")
  expect_equal(nrow(df), 2)
  expect_named(df, c("gene_id", "expr_level"))  # cleaned by janitor
})

#------------------------------------------------------------------------------
# Missing file
#------------------------------------------------------------------------------
test_that("read_excel_flex throws error if file does not exist", {
  skip_if_not_installed("readxl")
  skip_if_not_installed("janitor")

  expect_error(
    read_excel_flex(file_path = "non_existent.xlsx"),
    regexp = "File not found"
  )
})

#------------------------------------------------------------------------------
# Column types override
#------------------------------------------------------------------------------
test_that("read_excel_flex supports col_types override", {
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")
  skip_if_not_installed("janitor")

  test_file <- tempfile(fileext = ".xlsx")
  test_data <- data.frame(ID = c("001", "002"), Value = c(10, 20))
  writexl::write_xlsx(test_data, path = test_file)

  df <- read_excel_flex(
    file_path  = test_file,
    col_types  = c("text", "numeric")
  )

  expect_type(df$id, "character")
  expect_type(df$value, "double")
})

#------------------------------------------------------------------------------
# Clean-names toggle
#------------------------------------------------------------------------------
test_that("read_excel_flex can skip cleaning names when clean_names = FALSE", {
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")

  test_file <- tempfile(fileext = ".xlsx")
  test_data <- data.frame("Gene ID" = c("TP53", "EGFR"),
                          "Expr Level" = c(5.2, 3.8),
                          check.names = FALSE)
  writexl::write_xlsx(test_data, path = test_file)

  df <- read_excel_flex(file_path = test_file, clean_names = FALSE)

  # Original header preserved
  expect_named(df, c("Gene ID", "Expr Level"))
})

#------------------------------------------------------------------------------
# Range reading
#------------------------------------------------------------------------------
test_that("read_excel_flex respects range parameter", {
  skip_if_not_installed("readxl")
  skip_if_not_installed("writexl")
  skip_if_not_installed("janitor")

  test_file <- tempfile(fileext = ".xlsx")
  test_data <- data.frame(
    A = c("h", "TP53", "EGFR", "MYC"),
    B = c("h2", 5.2, 3.8, 7.1)
  )
  writexl::write_xlsx(test_data, path = test_file)

  df <- read_excel_flex(file_path = test_file, range = "A3:B4", header = TRUE)

  expect_equal(nrow(df), 1)                 # only one data row (Row 4)
  expect_named(df, c("tp53", "x5_2"))      # cleaned from "TP53" and "5.2"
})

