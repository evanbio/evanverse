# =============================================================================
# 📦 Test: read_table_flex()
# 📁 File: test-read_table_flex.R
# 📋 Description: Unit tests for read_table_flex() using internal datasets
# =============================================================================

library(data.table)

test_that("read_table_flex reads .csv correctly", {
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars, file = tmp, sep = ",")

  dt <- read_table_flex(tmp)
  expect_s3_class(dt, "data.table")
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), nrow(mtcars))

  unlink(tmp)
})

test_that("read_table_flex reads .tsv correctly", {
  tmp <- tempfile(fileext = ".tsv")
  data.table::fwrite(iris, file = tmp, sep = "\t")

  dt <- read_table_flex(tmp)
  expect_equal(ncol(dt), ncol(iris))
  expect_equal(nrow(dt), nrow(iris))

  unlink(tmp)
})

test_that("read_table_flex reads .csv.gz correctly", {
  tmp_csv <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars, file = tmp_csv, sep = ",")
  R.utils::gzip(tmp_csv, overwrite = TRUE)
  tmp_gz <- paste0(tmp_csv, ".gz")

  dt <- read_table_flex(tmp_gz)
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), nrow(mtcars))

  unlink(tmp_gz)
})

test_that("read_table_flex works with custom sep", {
  tmp <- tempfile(fileext = ".pipe")
  data.table::fwrite(mtcars, file = tmp, sep = "|")

  dt <- read_table_flex(tmp, sep = "|")
  expect_equal(ncol(dt), ncol(mtcars))

  unlink(tmp)
})

test_that("read_table_flex returns empty table on read failure", {
  tmp <- tempfile()
  writeLines("this is not a valid table", con = tmp)

  dt <- read_table_flex(tmp)
  expect_s3_class(dt, "data.table")
  expect_equal(nrow(dt), 0)

  unlink(tmp)
})

