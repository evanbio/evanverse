#===============================================================================
# 🧪 Test: get_ext()
# 📁 File: test-get_ext.R
# 🔍 Description: Unit tests for the get_ext() utility function
#===============================================================================

test_that("get_ext() returns correct single extensions", {
  expect_equal(get_ext("report.csv"), "csv")
  expect_equal(get_ext("script.R"), "R")
  expect_equal(get_ext("README.md"), "md")
})

test_that("get_ext() handles compound extensions correctly", {
  expect_equal(get_ext("archive.tar.gz"), "gz")
  expect_equal(get_ext("archive.tar.gz", keep_all = TRUE), "tar.gz")
})

test_that("get_ext() handles multiple inputs", {
  files <- c("a.txt", "b.md", "c.docx")
  expect_equal(get_ext(files), c("txt", "md", "docx"))
})

test_that("get_ext() handles files without extension", {
  expect_equal(get_ext("LICENSE"), "")
  expect_equal(get_ext(c("a", "b.txt")), c("", "txt"))
})

test_that("get_ext() returns empty vector on empty input", {
  expect_equal(get_ext(character(0)), character(0))
})

test_that("get_ext() throws error on non-character input", {
  expect_error(get_ext(123), "is.character")
})
