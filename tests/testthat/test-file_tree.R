#===============================================================================
# Test: file_tree()
# File: test-file_tree.R
# Description: Unit tests for the file_tree() utility function
#===============================================================================

#------------------------------------------------------------------------------
# Basic Functionality
#------------------------------------------------------------------------------

test_that("file_tree() returns invisible character vector", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "test.txt"))
  
  result <- file_tree(temp_dir, max_depth = 1, log = FALSE)
  
  expect_type(result, "character")
  expect_true(any(grepl("test.txt", result)))
  
  unlink(temp_dir, recursive = TRUE)
})

test_that("file_tree() works with nested directory structure", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "file1.txt"))
  dir.create(file.path(temp_dir, "subdir"))
  file.create(file.path(temp_dir, "subdir", "file2.txt"))
  
  result <- file_tree(temp_dir, max_depth = 2, log = FALSE)
  
  expect_true(any(grepl("file1.txt", result)))
  expect_true(any(grepl("subdir", result)))
  expect_true(any(grepl("file2.txt", result)))
  
  unlink(temp_dir, recursive = TRUE)
})

test_that("file_tree() respects max_depth parameter", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  dir.create(file.path(temp_dir, "level1"))
  dir.create(file.path(temp_dir, "level1", "level2"))
  file.create(file.path(temp_dir, "level1", "level2", "deep_file.txt"))
  
  result_shallow <- file_tree(temp_dir, max_depth = 1, log = FALSE)
  result_deep <- file_tree(temp_dir, max_depth = 3, log = FALSE)
  
  expect_false(any(grepl("deep_file.txt", result_shallow)))
  expect_true(any(grepl("deep_file.txt", result_deep)))
  
  unlink(temp_dir, recursive = TRUE)
})

#------------------------------------------------------------------------------
# Logging Functionality
#------------------------------------------------------------------------------

test_that("file_tree() creates log file when log = TRUE", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "example.txt"))
  
  log_dir <- file.path(temp_dir, "logs", "tree")
  log_file <- file.path(log_dir, "test.log")
  
  file_tree(temp_dir, log = TRUE, log_path = log_dir, file_name = "test.log")
  
  expect_true(file.exists(log_file))
  
  unlink(temp_dir, recursive = TRUE)
})

test_that("file_tree() log contains expected content", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "sample.txt"))
  
  log_dir <- file.path(temp_dir, "logs")
  log_file <- file.path(log_dir, "content_test.log")
  
  file_tree(temp_dir, log = TRUE, log_path = log_dir, file_name = "content_test.log")
  
  log_content <- readLines(log_file)
  expect_true(any(grepl("Timestamp", log_content)))
  expect_true(any(grepl("Directory", log_content)))
  expect_true(any(grepl("Max Depth", log_content)))
  expect_true(any(grepl("Tree Structure", log_content)))
  expect_true(any(grepl("sample.txt", log_content)))
  
  unlink(temp_dir, recursive = TRUE)
})

test_that("file_tree() generates timestamped filename when file_name is NULL", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "test.txt"))
  
  log_dir <- file.path(temp_dir, "logs")
  
  file_tree(temp_dir, log = TRUE, log_path = log_dir, file_name = NULL)
  
  log_files <- list.files(log_dir, pattern = "^file_tree_.*\\.log$")
  expect_length(log_files, 1)
  expect_true(grepl("\\d{8}_\\d{6}", log_files[1]))
  
  unlink(temp_dir, recursive = TRUE)
})

#------------------------------------------------------------------------------
# Append Mode
#------------------------------------------------------------------------------

#------------------------------------------------------------------------------
# Append Mode
#------------------------------------------------------------------------------

test_that("file_tree() overwrites when append = FALSE", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "file1.txt"))
  
  # Important: place log directory outside temp_dir
  log_dir <- tempfile()  # do not place inside temp_dir
  dir.create(log_dir)
  log_file <- file.path(log_dir, "overwrite_test.log")
  
  file_tree(temp_dir, log = TRUE, log_path = log_dir, file_name = "overwrite_test.log")
  lines_first <- readLines(log_file)
  
  file_tree(temp_dir, log = TRUE, log_path = log_dir, file_name = "overwrite_test.log", append = FALSE)
  lines_second <- readLines(log_file)
  
  expect_equal(length(lines_first), length(lines_second))
  
  unlink(temp_dir, recursive = TRUE)
  unlink(log_dir, recursive = TRUE)  # remember to clean up log directory
})

test_that("file_tree() appends when append = TRUE", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "file1.txt"))
  
  # Use separate log directory outside the tree structure
  log_dir <- tempfile()
  dir.create(log_dir)
  log_file <- file.path(log_dir, "append_test.log")
  
  file_tree(temp_dir, log = TRUE, log_path = log_dir, file_name = "append_test.log", append = FALSE)
  lines_first <- readLines(log_file)
  
  file_tree(temp_dir, log = TRUE, log_path = log_dir, file_name = "append_test.log", append = TRUE)
  lines_second <- readLines(log_file)
  
  expect_gt(length(lines_second), length(lines_first))
  
  unlink(temp_dir, recursive = TRUE)
  unlink(log_dir, recursive = TRUE)
})

#------------------------------------------------------------------------------
# Error and Edge Cases
#------------------------------------------------------------------------------

test_that("file_tree() returns NULL for nonexistent directory", {
  result <- file_tree("nonexistent/directory/path", log = FALSE)
  expect_null(result)
})

test_that("file_tree() handles empty directory", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  
  result <- file_tree(temp_dir, log = FALSE)
  expect_length(result, 0)
  
  unlink(temp_dir, recursive = TRUE)
})

test_that("file_tree() creates log directory if it doesn't exist", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "test.txt"))
  
  log_dir <- file.path(temp_dir, "new", "log", "path")
  
  file_tree(temp_dir, log = TRUE, log_path = log_dir, file_name = "test.log")
  
  expect_true(dir.exists(log_dir))
  expect_true(file.exists(file.path(log_dir, "test.log")))
  
  unlink(temp_dir, recursive = TRUE)
})

#===============================================================================
# End: test-file_tree.R
#===============================================================================

















