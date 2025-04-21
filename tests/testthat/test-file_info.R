#===============================================================================
# 📦 Test: file_info()
# 📁 File: test-file_info.R
# 🔍 Description: Unit tests for the file_info() utility function
#===============================================================================

# Load here (recommended in tests too)
library(here)

#------------------------------------------------------------------------------
# 🧪 Basic Functionality
#------------------------------------------------------------------------------

test_that("file_info() works on existing single file", {
  desc_file <- here("DESCRIPTION")
  skip_if_not(file.exists(desc_file), "DESCRIPTION file not found")

  info <- file_info(desc_file)
  expect_s3_class(info, "data.frame")
  expect_true(nrow(info) == 1)
  expect_named(info, c("file", "size_MB", "modified_time", "line_count", "path"))
})

test_that("file_info() works on multiple files", {
  files <- c(here("DESCRIPTION"), here("README.md"))
  files <- files[file.exists(files)]
  skip_if(length(files) < 1, "Test files not found")

  info <- file_info(files)
  expect_s3_class(info, "data.frame")
  expect_equal(nrow(info), length(files))
})

#------------------------------------------------------------------------------
# ⚙️ Parameter Variants
#------------------------------------------------------------------------------

test_that("file_info() skips line count when count_line = FALSE", {
  f <- here("DESCRIPTION")
  skip_if_not(file.exists(f), "DESCRIPTION file not found")

  info <- file_info(f, count_line = FALSE)
  expect_true(is.na(info$line_count))
})

test_that("file_info() returns relative path when full_name = FALSE", {
  f <- "DESCRIPTION"
  skip_if_not(file.exists(f), "DESCRIPTION file not found")

  info <- file_info(f, full_name = FALSE)
  expect_equal(info$path, f)
})


test_that("file_info() filters by regex pattern", {
  info <- file_info(here("R"), recursive = TRUE, filter_pattern = "\\.R$")
  skip_if(nrow(info) == 0, "No .R files found")
  expect_true(all(grepl("\\.R$", info$file)))
})

#------------------------------------------------------------------------------
# ❌ Error / Edge Handling
#------------------------------------------------------------------------------

test_that("file_info() returns empty data.frame on non-existent file", {
  info <- file_info("nonexistent_file_abcdef.txt", preview = FALSE)
  expect_s3_class(info, "data.frame")
  expect_equal(nrow(info), 0)
})

test_that("file_info() handles empty directory gracefully", {
  tmpdir <- tempfile()
  dir.create(tmpdir)
  info <- file_info(tmpdir, preview = FALSE)
  expect_equal(nrow(info), 0)
})

