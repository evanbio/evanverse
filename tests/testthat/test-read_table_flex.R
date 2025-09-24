#===============================================================================
# Test: read_table_flex()
# File: test-read_table_flex.R
# Description: Unit tests for the read_table_flex() function
#===============================================================================

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("read_table_flex() validates file_path parameter correctly", {
  # Missing file_path
  expect_error(
    read_table_flex(),
    "'file_path' must be a non-empty character string"
  )

  # Invalid file_path types
  expect_error(
    read_table_flex(file_path = c("file1.csv", "file2.csv")),
    "'file_path' must be a non-empty character string"
  )

  expect_error(
    read_table_flex(file_path = NA_character_),
    "'file_path' must be a non-empty character string"
  )

  expect_error(
    read_table_flex(file_path = ""),
    "'file_path' must be a non-empty character string"
  )

  expect_error(
    read_table_flex(file_path = 123),
    "'file_path' must be a non-empty character string"
  )
})

test_that("read_table_flex() validates encoding parameter correctly", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  expect_error(
    read_table_flex(file_path = tmp, encoding = c("UTF-8", "ASCII")),
    "'encoding' must be a character string"
  )

  expect_error(
    read_table_flex(file_path = tmp, encoding = NA_character_),
    "'encoding' must be a character string"
  )

  expect_error(
    read_table_flex(file_path = tmp, encoding = 123),
    "'encoding' must be a character string"
  )

  unlink(tmp)
})

test_that("read_table_flex() validates header parameter correctly", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  expect_error(
    read_table_flex(file_path = tmp, header = "TRUE"),
    "'header' must be TRUE or FALSE"
  )

  expect_error(
    read_table_flex(file_path = tmp, header = c(TRUE, FALSE)),
    "'header' must be TRUE or FALSE"
  )

  expect_error(
    read_table_flex(file_path = tmp, header = NA),
    "'header' must be TRUE or FALSE"
  )

  unlink(tmp)
})

test_that("read_table_flex() validates df parameter correctly", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  expect_error(
    read_table_flex(file_path = tmp, df = "TRUE"),
    "'df' must be TRUE or FALSE"
  )

  expect_error(
    read_table_flex(file_path = tmp, df = c(TRUE, FALSE)),
    "'df' must be TRUE or FALSE"
  )

  expect_error(
    read_table_flex(file_path = tmp, df = NA),
    "'df' must be TRUE or FALSE"
  )

  unlink(tmp)
})

test_that("read_table_flex() validates verbose parameter correctly", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  expect_error(
    read_table_flex(file_path = tmp, verbose = "TRUE"),
    "'verbose' must be TRUE or FALSE"
  )

  expect_error(
    read_table_flex(file_path = tmp, verbose = c(TRUE, FALSE)),
    "'verbose' must be TRUE or FALSE"
  )

  expect_error(
    read_table_flex(file_path = tmp, verbose = NA),
    "'verbose' must be TRUE or FALSE"
  )

  unlink(tmp)
})

test_that("read_table_flex() validates sep parameter correctly", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  expect_error(
    read_table_flex(file_path = tmp, sep = c(",", ";")),
    "'sep' must be a single character string"
  )

  unlink(tmp)
})

test_that("read_table_flex() handles non-existent file correctly", {
  expect_error(
    read_table_flex(file_path = "nonexistent_file.csv"),
    "File not found"
  )
})

#------------------------------------------------------------------------------
# Separator Detection Tests
#------------------------------------------------------------------------------

test_that("read_table_flex() auto-detects CSV separator correctly", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  dt <- read_table_flex(tmp)
  expect_s3_class(dt, "data.frame")
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), 5)

  unlink(tmp)
})

test_that("read_table_flex() auto-detects TSV separator correctly", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".tsv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = "\t")

  dt <- read_table_flex(tmp)
  expect_s3_class(dt, "data.frame")
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), 5)

  unlink(tmp)
})

test_that("read_table_flex() auto-detects TXT separator correctly", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".txt")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = "\t")

  dt <- read_table_flex(tmp)
  expect_s3_class(dt, "data.frame")
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), 5)

  unlink(tmp)
})

test_that("read_table_flex() handles compressed CSV files correctly", {
  skip_if_not_installed("data.table")
  skip_if_not_installed("R.utils")

  tmp_csv <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp_csv, sep = ",")
  R.utils::gzip(tmp_csv, overwrite = TRUE)
  tmp_gz <- paste0(tmp_csv, ".gz")

  dt <- read_table_flex(tmp_gz)
  expect_s3_class(dt, "data.table")
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), 5)

  unlink(tmp_gz)
})

test_that("read_table_flex() handles compressed TSV files correctly", {
  skip_if_not_installed("data.table")
  skip_if_not_installed("R.utils")

  tmp_tsv <- tempfile(fileext = ".tsv")
  data.table::fwrite(mtcars[1:5, ], file = tmp_tsv, sep = "\t")
  R.utils::gzip(tmp_tsv, overwrite = TRUE)
  tmp_gz <- paste0(tmp_tsv, ".gz")

  dt <- read_table_flex(tmp_gz)
  expect_s3_class(dt, "data.table")
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), 5)

  unlink(tmp_gz)
})

#------------------------------------------------------------------------------
# Custom Separator Tests
#------------------------------------------------------------------------------

test_that("read_table_flex() works with custom separator", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".pipe")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = "|")

  dt <- read_table_flex(tmp, sep = "|")
  expect_s3_class(dt, "data.frame")
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), 5)

  unlink(tmp)
})

test_that("read_table_flex() works with semicolon separator", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ";")

  dt <- read_table_flex(tmp, sep = ";")
  expect_s3_class(dt, "data.frame")
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), 5)

  unlink(tmp)
})

#------------------------------------------------------------------------------
# Header and Encoding Tests
#------------------------------------------------------------------------------

test_that("read_table_flex() handles header parameter correctly", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",", col.names = TRUE)

  # With header
  dt_with_header <- read_table_flex(tmp, header = TRUE)
  expect_s3_class(dt_with_header, "data.frame")
  expect_true("mpg" %in% names(dt_with_header))

  # Without header
  dt_without_header <- read_table_flex(tmp, header = FALSE)
  expect_s3_class(dt_without_header, "data.frame")
  expect_false("mpg" %in% names(dt_without_header))

  unlink(tmp)
})

test_that("read_table_flex() handles different encodings", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  # Test with different encodings
  dt_utf8 <- read_table_flex(tmp, encoding = "UTF-8")
  expect_s3_class(dt_utf8, "data.frame")

  dt_latin1 <- read_table_flex(tmp, encoding = "latin1")
  expect_s3_class(dt_latin1, "data.frame")

  unlink(tmp)
})

#------------------------------------------------------------------------------
# Error Handling Tests
#------------------------------------------------------------------------------

test_that("read_table_flex() handles invalid file content gracefully", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  # Create truly invalid content that will cause fread to fail
  writeLines("invalid\x01binary\x02content\x03that\x04fread\x05cannot\x06parse", con = tmp)

  # Expect an error when trying to read truly invalid content
  expect_error(read_table_flex(tmp))

  unlink(tmp)
})

test_that("read_table_flex() handles empty files gracefully", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  writeLines("", con = tmp)

  # Expect an error when trying to read empty file
  expect_error(read_table_flex(tmp))

  unlink(tmp)
})

#------------------------------------------------------------------------------
# Output Format Tests
#------------------------------------------------------------------------------

test_that("read_table_flex() returns data.frame by default", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  dt <- read_table_flex(tmp)
  expect_s3_class(dt, "data.frame")
  expect_false(inherits(dt, "data.table"))

  unlink(tmp)
})

test_that("read_table_flex() returns data.table when df=FALSE", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  dt <- read_table_flex(tmp, df = FALSE)
  expect_s3_class(dt, "data.table")
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), 5)

  unlink(tmp)
})

test_that("read_table_flex() returns data.frame when df=TRUE", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  dt <- read_table_flex(tmp, df = TRUE)
  expect_s3_class(dt, "data.frame")
  expect_false(inherits(dt, "data.table"))
  expect_equal(ncol(dt), ncol(mtcars))
  expect_equal(nrow(dt), 5)

  unlink(tmp)
})

#------------------------------------------------------------------------------
# Verbose Mode Tests
#------------------------------------------------------------------------------

test_that("read_table_flex() works in verbose mode", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  expect_message({
    dt <- read_table_flex(tmp, verbose = TRUE)
  }, "Reading table file")

  expect_s3_class(dt, "data.frame")
  expect_equal(nrow(dt), 5)

  unlink(tmp)
})

test_that("read_table_flex() works in non-verbose mode", {
  skip_if_not_installed("data.table")
  tmp <- tempfile(fileext = ".csv")
  data.table::fwrite(mtcars[1:5, ], file = tmp, sep = ",")

  expect_silent({
    dt <- read_table_flex(tmp, verbose = FALSE)
  })

  expect_s3_class(dt, "data.frame")
  expect_equal(nrow(dt), 5)

  unlink(tmp)
})
