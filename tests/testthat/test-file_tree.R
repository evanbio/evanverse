#-------------------------------------------------------------------------------
# 📁 file_tree.R — Tests
#-------------------------------------------------------------------------------
# Purpose   : Unit tests for `file_tree()` utility function
# Author    : Evan Zhou
# Created   : 2025-04-20
# Framework : testthat
#-------------------------------------------------------------------------------

# SECTION 1: 🔍 Core functionality ------------------------------------------------

test_that("file_tree prints tree structure to console", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "a.txt"))
  dir.create(file.path(temp_dir, "subdir"))
  file.create(file.path(temp_dir, "subdir", "b.txt"))

  expect_invisible(file_tree(temp_dir, max_depth = 2, log = FALSE))

  unlink(temp_dir, recursive = TRUE)
})


# SECTION 2: 📄 Log file creation -------------------------------------------------

test_that("file_tree creates a log file with expected fields", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "example.txt"))

  log_dir <- file.path(temp_dir, "logs/tree")
  log_file <- file.path(log_dir, "test.log")

  file_tree(temp_dir, log = TRUE, log_path = log_dir, file_name = "test.log")

  expect_true(file.exists(log_file))

  # Check log file contents
  log_lines <- readLines(log_file, encoding = "UTF-8")
  expect_true(any(grepl("📅 Timestamp", log_lines)))
  expect_true(any(grepl("🧭 Directory", log_lines)))
  expect_true(any(grepl("⚙️ Max Depth", log_lines)))
  expect_true(any(grepl("📂 Tree Structure", log_lines)))
  expect_true(any(grepl("example.txt", log_lines)))

  unlink(temp_dir, recursive = TRUE)
})


# SECTION 3: ➕ Log append mode ---------------------------------------------------

test_that("file_tree correctly appends when append = TRUE", {
  temp_dir <- tempfile()
  dir.create(temp_dir)
  file.create(file.path(temp_dir, "file1.txt"))

  log_path <- file.path(temp_dir, "logs/tree")
  log_file <- file.path(log_path, "append_test.log")

  # First write
  file_tree(temp_dir, log = TRUE, log_path = log_path, file_name = "append_test.log", append = FALSE)
  lines_1 <- readLines(log_file)

  # Append again
  file_tree(temp_dir, log = TRUE, log_path = log_path, file_name = "append_test.log", append = TRUE)
  lines_2 <- readLines(log_file)

  expect_gt(length(lines_2), length(lines_1))

  unlink(temp_dir, recursive = TRUE)
})


# SECTION 4: ⚠️ Edge cases --------------------------------------------------------

test_that("file_tree handles nonexistent path gracefully", {
  expect_invisible(file_tree("path/does/not/exist", log = FALSE))
})
