# =============================================================================
# Test: write_xlsx_flex()
# File: tests/testthat/test-write_xlsx_flex.R
# Description: Unit tests for the Excel writer utility
# Dependencies: testthat, fs, readxl, openxlsx
# =============================================================================

test_that("write_xlsx_flex writes a single data.frame to Excel", {
  skip_if_not_installed("openxlsx")
  skip_if_not_installed("readxl")
  skip_if_not_installed("fs")

  test_file <- tempfile(fileext = ".xlsx")
  on.exit(unlink(test_file, recursive = TRUE, force = TRUE), add = TRUE)

  df <- data.frame(Gene = c("TP53", "EGFR"), Score = c(5.1, 3.9))

  write_xlsx_flex(data = df, file_path = test_file)

  expect_true(fs::file_exists(test_file))
  sheets <- readxl::excel_sheets(test_file)
  expect_equal(sheets, "Sheet1")
})

test_that("write_xlsx_flex writes multiple sheets from a named list", {
  skip_if_not_installed("openxlsx")
  skip_if_not_installed("readxl")
  skip_if_not_installed("fs")

  test_file <- tempfile(fileext = ".xlsx")
  on.exit(unlink(test_file, recursive = TRUE, force = TRUE), add = TRUE)

  df1 <- data.frame(ID = 1:3, Name = letters[1:3])
  df2 <- data.frame(Score = c(3.5, 4.2))

  write_xlsx_flex(data = list(Info = df1, Scores = df2), file_path = test_file)

  expect_true(fs::file_exists(test_file))
  sheets <- readxl::excel_sheets(test_file)
  expect_equal(sheets, c("Info", "Scores"))
})

test_that("write_xlsx_flex handles overwrite cases", {
  skip_if_not_installed("openxlsx")
  skip_if_not_installed("fs")

  test_file <- tempfile(fileext = ".xlsx")
  on.exit(unlink(test_file, recursive = TRUE, force = TRUE), add = TRUE)

  df <- data.frame(X = 1:3)

  # First write
  write_xlsx_flex(data = df, file_path = test_file)

  # Second write should succeed when overwrite = TRUE (no error expected)
  expect_no_error(
    write_xlsx_flex(data = df, file_path = test_file, overwrite = TRUE)
  )

  # overwrite = FALSE should error with a helpful message
  expect_error(
    write_xlsx_flex(data = df, file_path = test_file, overwrite = FALSE),
    regexp = "File exists"
  )
})

test_that("write_xlsx_flex appends a date suffix when timestamp = TRUE", {
  skip_if_not_installed("openxlsx")
  skip_if_not_installed("fs")

  df <- data.frame(A = 1:2)
  file_path <- tempfile("test-write-", fileext = ".xlsx")

  # Expected path after timestamping
  file_base <- fs::path_ext_remove(file_path)
  expected  <- paste0(file_base, "_", format(Sys.Date(), "%Y-%m-%d"), ".xlsx")
  on.exit(unlink(expected, recursive = TRUE, force = TRUE), add = TRUE)

  write_xlsx_flex(data = df, file_path = file_path, timestamp = TRUE)

  expect_true(fs::file_exists(expected))
})
