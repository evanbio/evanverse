# =============================================================================
# 📦 Test: write_xlsx_flex()
# File: tests/testthat/test-write_xlsx_flex.R
# Author: Evan
# Description: Unit tests for the Excel writer utility
# Dependencies: testthat, fs, readxl
# =============================================================================

test_that("✅ write_xlsx_flex writes a single data.frame to Excel", {
  test_file <- tempfile(fileext = ".xlsx")
  df <- data.frame(Gene = c("TP53", "EGFR"), Score = c(5.1, 3.9))

  write_xlsx_flex(data = df, file_path = test_file)

  expect_true(fs::file_exists(test_file))
  sheets <- readxl::excel_sheets(test_file)
  expect_equal(sheets, "Sheet1")
})

test_that("✅ write_xlsx_flex writes multiple sheets from named list", {
  test_file <- tempfile(fileext = ".xlsx")
  df1 <- data.frame(ID = 1:3, Name = letters[1:3])
  df2 <- data.frame(Score = c(3.5, 4.2))

  write_xlsx_flex(data = list(Info = df1, Scores = df2), file_path = test_file)

  expect_true(fs::file_exists(test_file))
  sheets <- readxl::excel_sheets(test_file)
  expect_equal(sheets, c("Info", "Scores"))
})

test_that("⚠️ write_xlsx_flex shows warning when overwriting", {
  test_file <- tempfile(fileext = ".xlsx")
  df <- data.frame(X = 1:3)

  # First write
  write_xlsx_flex(data = df, file_path = test_file)

  # Second write should succeed (overwrite = TRUE)
  expect_no_error(
    write_xlsx_flex(data = df, file_path = test_file, overwrite = TRUE)
  )

  # Now test overwrite = FALSE (should fail)
  expect_error(
    write_xlsx_flex(data = df, file_path = test_file, overwrite = FALSE),
    regexp = "File exists"
  )
})

test_that("🕒 write_xlsx_flex appends timestamp to filename when enabled", {
  df <- data.frame(A = 1:2)

  file_path <- tempfile("test-write-", fileext = ".xlsx")

  write_xlsx_flex(data = df, file_path = file_path, timestamp = TRUE)

  file_base <- fs::path_ext_remove(file_path)  # 去掉 .xlsx
  expected <- paste0(file_base, "_", format(Sys.Date(), "%Y-%m-%d"), ".xlsx")

  expect_true(fs::file_exists(expected))
})
