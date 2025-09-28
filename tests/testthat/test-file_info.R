#===============================================================================
# Test: file_info()
# File: test-file_info.R
# Description: Unit tests for the file_info() utility function
#===============================================================================

#------------------------------------------------------------------------------
# Basic Functionality
#------------------------------------------------------------------------------

test_that("file_info() works on existing single file", {
  skip_on_cran()
  # Create temporary test file
  temp_file <- tempfile(pattern = "test_file", fileext = ".txt")
  writeLines(c("line 1", "line 2", "line 3"), temp_file)
  on.exit(unlink(temp_file), add = TRUE)

  info <- file_info(temp_file)
  expect_s3_class(info, "data.frame")
  expect_true(nrow(info) == 1)
  expect_named(info, c("file", "size_MB", "modified_time", "line_count", "path"))
  expect_equal(info$line_count, 3)
})

test_that("file_info() works on multiple files", {
  skip_on_cran()
  # Create multiple temporary test files
  temp_file1 <- tempfile(pattern = "test1_", fileext = ".txt")
  temp_file2 <- tempfile(pattern = "test2_", fileext = ".md")
  writeLines(c("content 1", "content 2"), temp_file1)
  writeLines(c("markdown content"), temp_file2)
  on.exit({
    unlink(temp_file1)
    unlink(temp_file2)
  }, add = TRUE)

  files <- c(temp_file1, temp_file2)
  info <- file_info(files)
  expect_s3_class(info, "data.frame")
  expect_equal(nrow(info), 2)
})

#------------------------------------------------------------------------------
# Parameter Variants
#------------------------------------------------------------------------------

test_that("file_info() skips line count when count_line = FALSE", {
  skip_on_cran()
  # Create temporary test file
  temp_file <- tempfile(pattern = "test_nocount_", fileext = ".txt")
  writeLines(c("line 1", "line 2", "line 3"), temp_file)
  on.exit(unlink(temp_file), add = TRUE)

  info <- file_info(temp_file, count_line = FALSE)
  expect_true(is.na(info$line_count))
})

test_that("file_info() returns relative path when full_name = FALSE", {
  skip_on_cran()
  # Create temporary test file
  temp_file <- tempfile(pattern = "test_relpath_", fileext = ".txt")
  writeLines(c("test content"), temp_file)
  on.exit(unlink(temp_file), add = TRUE)

  info <- file_info(temp_file, full_name = FALSE)
  expect_equal(info$path, temp_file)
})


test_that("file_info() filters by regex pattern", {
  skip_on_cran()
  # Create temporary directory with test files
  temp_dir <- tempfile(pattern = "test_dir_")
  dir.create(temp_dir)
  on.exit(unlink(temp_dir, recursive = TRUE), add = TRUE)

  # Create files with different extensions
  r_file <- file.path(temp_dir, "test.R")
  txt_file <- file.path(temp_dir, "test.txt")
  writeLines(c("# R code", "x <- 1"), r_file)
  writeLines(c("text content"), txt_file)

  info <- file_info(temp_dir, recursive = TRUE, filter_pattern = "\\.R$")
  expect_true(nrow(info) >= 1)
  expect_true(all(grepl("\\.R$", info$file)))
})

#------------------------------------------------------------------------------
# Error / Edge Handling
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

#===============================================================================
# End: test-file_info.R
#===============================================================================


