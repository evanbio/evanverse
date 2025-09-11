#===============================================================================
# Test: get_ext()
# File: test-get_ext.R
# Description: Unit tests for the get_ext() utility function
#===============================================================================

#------------------------------------------------------------------------------
# Basic Functionality
#------------------------------------------------------------------------------

test_that("get_ext() returns correct single extensions", {
  expect_equal(get_ext("report.csv"), "csv")
  expect_equal(get_ext("script.R"), "R")
  expect_equal(get_ext("README.md"), "md")
  expect_equal(get_ext("data.JSON"), "JSON")
})

test_that("get_ext() handles vector input correctly", {
  files <- c("a.txt", "b.md", "c.docx")
  expect_equal(get_ext(files), c("txt", "md", "docx"))
  
  mixed_files <- c("script.R", "data.csv", "image.PNG")
  expect_equal(get_ext(mixed_files), c("R", "csv", "PNG"))
})

test_that("get_ext() handles file paths correctly", {
  expect_equal(get_ext("path/to/file.txt"), "txt")
  expect_equal(get_ext("../relative/path.pdf"), "pdf")
  expect_equal(get_ext("/absolute/path/data.json"), "json")
})

#------------------------------------------------------------------------------
# Parameter Variants
#------------------------------------------------------------------------------

test_that("get_ext() handles compound extensions with keep_all = TRUE", {
  expect_equal(get_ext("archive.tar.gz"), "gz")
  expect_equal(get_ext("archive.tar.gz", keep_all = TRUE), "tar.gz")
  expect_equal(get_ext("backup.sql.bz2", keep_all = TRUE), "sql.bz2")
  expect_equal(get_ext("file.min.js", keep_all = TRUE), "min.js")
})

test_that("get_ext() includes dot when include_dot = TRUE", {
  expect_equal(get_ext("file.txt", include_dot = TRUE), ".txt")
  expect_equal(get_ext("archive.tar.gz", keep_all = TRUE, include_dot = TRUE), ".tar.gz")
  expect_equal(get_ext("no_extension", include_dot = TRUE), "")
})

test_that("get_ext() converts to lowercase when to_lower = TRUE", {
  expect_equal(get_ext("file.CSV", to_lower = TRUE), "csv")
  expect_equal(get_ext("script.R", to_lower = TRUE), "r")
  expect_equal(get_ext("archive.TAR.GZ", keep_all = TRUE, to_lower = TRUE), "tar.gz")
})

test_that("get_ext() combines multiple parameters correctly", {
  expect_equal(get_ext("FILE.TAR.GZ", keep_all = TRUE, include_dot = TRUE, to_lower = TRUE), ".tar.gz")
  expect_equal(get_ext("DATA.CSV", include_dot = TRUE, to_lower = TRUE), ".csv")
})

#------------------------------------------------------------------------------
# Edge Cases and Error Handling
#------------------------------------------------------------------------------

test_that("get_ext() handles files without extensions", {
  expect_equal(get_ext("LICENSE"), "")
  expect_equal(get_ext("README"), "")
  expect_equal(get_ext(c("file_no_ext", "file.txt")), c("", "txt"))
})

test_that("get_ext() handles files with dots in names but no extension", {
  expect_equal(get_ext("file.name.no.ext"), "ext")
  expect_equal(get_ext("v1.2.3"), "3")
})

test_that("get_ext() handles hidden files correctly", {
  expect_equal(get_ext(".gitignore"), "gitignore")
  expect_equal(get_ext(".env.example"), "example")
  expect_equal(get_ext(".env.example", keep_all = TRUE), "env.example")
})

test_that("get_ext() handles special cases", {
  expect_equal(get_ext(""), "")
  expect_equal(get_ext("."), "")
  expect_equal(get_ext(".."), "")
  expect_equal(get_ext("file."), "")
})

test_that("get_ext() returns empty vector for empty input", {
  expect_equal(get_ext(character(0)), character(0))
  expect_length(get_ext(character(0)), 0)
})

test_that("get_ext() throws error for invalid input types", {
  expect_error(get_ext(123), "'paths' must be a character vector")
  expect_error(get_ext(NULL), "'paths' must be a character vector")
  expect_error(get_ext(list("file.txt")), "'paths' must be a character vector")
})

#===============================================================================
# End: test-get_ext.R
#===============================================================================


