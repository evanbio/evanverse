#===============================================================================
# Test: utils.R internal helpers
# File: test-utils.R
# Description: Unit tests for .assert_scalar_string(), .assert_dir_path(),
#              .assert_flag(), .assert_character_vector(), .assert_file_exists(),
#              .assert_count()
#              (accessed via evanverse:::)
#===============================================================================

#==============================================================================
# .assert_scalar_string()
#==============================================================================

test_that(".assert_scalar_string() accepts a valid single non-empty string", {
  expect_no_error(evanverse:::.assert_scalar_string("hello"))
  expect_no_error(evanverse:::.assert_scalar_string("a"))
  expect_no_error(evanverse:::.assert_scalar_string(" space "))
})

test_that(".assert_scalar_string() returns input invisibly on success", {
  result <- evanverse:::.assert_scalar_string("ok")
  expect_equal(result, "ok")
})

test_that(".assert_scalar_string() errors on non-character input", {
  expect_error(evanverse:::.assert_scalar_string(123),    "single non-empty string")
  expect_error(evanverse:::.assert_scalar_string(TRUE),   "single non-empty string")
  expect_error(evanverse:::.assert_scalar_string(NULL),   "single non-empty string")
  expect_error(evanverse:::.assert_scalar_string(list()), "single non-empty string")
})

test_that(".assert_scalar_string() errors on length != 1", {
  expect_error(evanverse:::.assert_scalar_string(c("a", "b")), "single non-empty string")
  expect_error(evanverse:::.assert_scalar_string(character(0)), "single non-empty string")
})

test_that(".assert_scalar_string() errors on empty string", {
  expect_error(evanverse:::.assert_scalar_string(""), "single non-empty string")
})

test_that(".assert_scalar_string() errors on NA", {
  expect_error(evanverse:::.assert_scalar_string(NA_character_), "single non-empty string")
  expect_error(evanverse:::.assert_scalar_string(NA),            "single non-empty string")
})

#==============================================================================
# .assert_dir_path()
#==============================================================================

test_that(".assert_dir_path() accepts a valid single non-empty string path", {
  expect_no_error(evanverse:::.assert_dir_path("/some/path"))
  expect_no_error(evanverse:::.assert_dir_path("relative/path"))
  expect_no_error(evanverse:::.assert_dir_path(tempdir()))
  # Path need not exist
  expect_no_error(evanverse:::.assert_dir_path("/nonexistent/path/to/nowhere"))
})

test_that(".assert_dir_path() returns input invisibly on success", {
  result <- evanverse:::.assert_dir_path("/tmp/test")
  expect_equal(result, "/tmp/test")
})

test_that(".assert_dir_path() errors on non-character input", {
  expect_error(evanverse:::.assert_dir_path(42),   "single non-empty string")
  expect_error(evanverse:::.assert_dir_path(NULL),  "single non-empty string")
  expect_error(evanverse:::.assert_dir_path(TRUE),  "single non-empty string")
})

test_that(".assert_dir_path() errors on empty string", {
  expect_error(evanverse:::.assert_dir_path(""), "single non-empty string")
})

test_that(".assert_dir_path() errors on length > 1", {
  expect_error(evanverse:::.assert_dir_path(c("/a", "/b")), "single non-empty string")
})

test_that(".assert_dir_path() errors on NA", {
  expect_error(evanverse:::.assert_dir_path(NA_character_), "single non-empty string")
})

#==============================================================================
# .assert_flag()
#==============================================================================

test_that(".assert_flag() accepts TRUE and FALSE", {
  expect_no_error(evanverse:::.assert_flag(TRUE))
  expect_no_error(evanverse:::.assert_flag(FALSE))
})

test_that(".assert_flag() returns input invisibly on success", {
  expect_equal(evanverse:::.assert_flag(TRUE),  TRUE)
  expect_equal(evanverse:::.assert_flag(FALSE), FALSE)
})

test_that(".assert_flag() errors on NA", {
  expect_error(evanverse:::.assert_flag(NA),         "TRUE or FALSE")
  expect_error(evanverse:::.assert_flag(NA_integer_), "TRUE or FALSE")
})

test_that(".assert_flag() errors on non-logical input", {
  expect_error(evanverse:::.assert_flag(1),       "TRUE or FALSE")
  expect_error(evanverse:::.assert_flag(0),       "TRUE or FALSE")
  expect_error(evanverse:::.assert_flag("TRUE"),  "TRUE or FALSE")
  expect_error(evanverse:::.assert_flag(NULL),    "TRUE or FALSE")
})

test_that(".assert_flag() errors on logical vector of length != 1", {
  expect_error(evanverse:::.assert_flag(c(TRUE, FALSE)), "TRUE or FALSE")
  expect_error(evanverse:::.assert_flag(logical(0)),     "TRUE or FALSE")
})

#==============================================================================
# .assert_character_vector()
#==============================================================================

test_that(".assert_character_vector() accepts a non-empty character vector", {
  expect_no_error(evanverse:::.assert_character_vector("hello"))
  expect_no_error(evanverse:::.assert_character_vector(c("a", "b", "c")))
  expect_no_error(evanverse:::.assert_character_vector(letters))
})

test_that(".assert_character_vector() returns input invisibly on success", {
  result <- evanverse:::.assert_character_vector(c("x", "y"))
  expect_equal(result, c("x", "y"))
})

test_that(".assert_character_vector() errors on non-character input", {
  expect_error(evanverse:::.assert_character_vector(123),    "non-empty character vector")
  expect_error(evanverse:::.assert_character_vector(TRUE),   "non-empty character vector")
  expect_error(evanverse:::.assert_character_vector(NULL),   "non-empty character vector")
  expect_error(evanverse:::.assert_character_vector(list()), "non-empty character vector")
})

test_that(".assert_character_vector() errors on empty character vector", {
  expect_error(evanverse:::.assert_character_vector(character(0)), "non-empty character vector")
})

test_that(".assert_character_vector() errors when any element is NA", {
  expect_error(evanverse:::.assert_character_vector(NA_character_),     "non-empty character vector")
  expect_error(evanverse:::.assert_character_vector(c("a", NA)),        "non-empty character vector")
  expect_error(evanverse:::.assert_character_vector(c(NA_character_)),  "non-empty character vector")
})

#==============================================================================
# .assert_file_exists()
#==============================================================================

test_that(".assert_file_exists() accepts a path to an existing file", {
  tmp <- tempfile()
  writeLines("test", tmp)
  on.exit(unlink(tmp), add = TRUE)

  expect_no_error(evanverse:::.assert_file_exists(tmp))
})

test_that(".assert_file_exists() returns input invisibly on success", {
  tmp <- tempfile()
  writeLines("test", tmp)
  on.exit(unlink(tmp), add = TRUE)

  result <- evanverse:::.assert_file_exists(tmp)
  expect_equal(result, tmp)
})

test_that(".assert_file_exists() errors when file does not exist", {
  expect_error(
    evanverse:::.assert_file_exists("/nonexistent/path/file.txt"),
    "File not found"
  )
})

test_that(".assert_file_exists() errors on non-character input", {
  expect_error(evanverse:::.assert_file_exists(123),  "single non-empty string")
  expect_error(evanverse:::.assert_file_exists(NULL), "single non-empty string")
  expect_error(evanverse:::.assert_file_exists(TRUE), "single non-empty string")
})

test_that(".assert_file_exists() errors on empty string", {
  expect_error(evanverse:::.assert_file_exists(""), "single non-empty string")
})

test_that(".assert_file_exists() errors on NA", {
  expect_error(evanverse:::.assert_file_exists(NA_character_), "single non-empty string")
})

test_that(".assert_file_exists() errors on length > 1", {
  tmp <- tempfile()
  writeLines("test", tmp)
  on.exit(unlink(tmp), add = TRUE)

  expect_error(evanverse:::.assert_file_exists(c(tmp, tmp)), "single non-empty string")
})

#==============================================================================
# .assert_count()
#==============================================================================

test_that(".assert_count() accepts valid positive integers", {
  expect_no_error(evanverse:::.assert_count(1))
  expect_no_error(evanverse:::.assert_count(10))
  expect_no_error(evanverse:::.assert_count(1L))
  expect_no_error(evanverse:::.assert_count(100L))
})

test_that(".assert_count() returns as.integer(x) invisibly", {
  result <- evanverse:::.assert_count(5)
  expect_equal(result, 5L)
  expect_type(result, "integer")
})

test_that(".assert_count() accepts numeric that equals its floor", {
  expect_no_error(evanverse:::.assert_count(3.0))
  expect_no_error(evanverse:::.assert_count(1e2))  # 100
})

test_that(".assert_count() errors on zero and negative values", {
  expect_error(evanverse:::.assert_count(0),   "single positive integer")
  expect_error(evanverse:::.assert_count(-1),  "single positive integer")
  expect_error(evanverse:::.assert_count(-10), "single positive integer")
})

test_that(".assert_count() errors on non-integer numeric values", {
  expect_error(evanverse:::.assert_count(1.5), "single positive integer")
  expect_error(evanverse:::.assert_count(2.9), "single positive integer")
  expect_error(evanverse:::.assert_count(0.1), "single positive integer")
})

test_that(".assert_count() errors on non-finite values", {
  expect_error(evanverse:::.assert_count(Inf),  "single positive integer")
  expect_error(evanverse:::.assert_count(-Inf), "single positive integer")
  expect_error(evanverse:::.assert_count(NaN),  "single positive integer")
})

test_that(".assert_count() errors on NA", {
  expect_error(evanverse:::.assert_count(NA),            "single positive integer")
  expect_error(evanverse:::.assert_count(NA_real_),      "single positive integer")
  expect_error(evanverse:::.assert_count(NA_integer_),   "single positive integer")
})

test_that(".assert_count() errors on non-numeric input", {
  expect_error(evanverse:::.assert_count("1"),    "single positive integer")
  expect_error(evanverse:::.assert_count(TRUE),   "single positive integer")
  expect_error(evanverse:::.assert_count(NULL),   "single positive integer")
})

test_that(".assert_count() errors on vector of length > 1", {
  expect_error(evanverse:::.assert_count(c(1, 2)), "single positive integer")
  expect_error(evanverse:::.assert_count(integer(0)), "single positive integer")
})

#==============================================================================
# .assert_dir_exists()
#==============================================================================

test_that(".assert_dir_exists() accepts an existing directory", {
  expect_no_error(evanverse:::.assert_dir_exists(tempdir()))
})

test_that(".assert_dir_exists() returns input invisibly on success", {
  path <- tempdir()
  expect_equal(evanverse:::.assert_dir_exists(path), path)
})

test_that(".assert_dir_exists() errors when directory does not exist", {
  path <- file.path(tempdir(), "evanverse_nonexistent_dir_12345")
  expect_error(evanverse:::.assert_dir_exists(path), "Directory not found")
})

test_that(".assert_dir_exists() errors on invalid scalar path inputs", {
  expect_error(evanverse:::.assert_dir_exists(123), "single non-empty string")
  expect_error(evanverse:::.assert_dir_exists(""), "single non-empty string")
  expect_error(evanverse:::.assert_dir_exists(NA_character_), "single non-empty string")
  expect_error(evanverse:::.assert_dir_exists(c("a", "b")), "single non-empty string")
})

#==============================================================================
# .assert_count_min()
#==============================================================================

test_that(".assert_count_min() accepts valid integer counts", {
  expect_no_error(evanverse:::.assert_count_min(1))
  expect_no_error(evanverse:::.assert_count_min(3, min = 2L))
  expect_no_error(evanverse:::.assert_count_min(0, min = 0L))
})

test_that(".assert_count_min() returns as.integer(x) invisibly", {
  out <- evanverse:::.assert_count_min(5, min = 2L)
  expect_equal(out, 5L)
  expect_type(out, "integer")
})

test_that(".assert_count_min() errors on values below min", {
  expect_error(evanverse:::.assert_count_min(1, min = 2L), "single integer >= 2")
  expect_error(evanverse:::.assert_count_min(-1, min = 0L), "single integer >= 0")
})

test_that(".assert_count_min() errors on invalid numeric forms", {
  expect_error(evanverse:::.assert_count_min(1.5, min = 1L), "single integer >=")
  expect_error(evanverse:::.assert_count_min(Inf, min = 1L), "single integer >=")
  expect_error(evanverse:::.assert_count_min(NaN, min = 1L), "single integer >=")
  expect_error(evanverse:::.assert_count_min(NA_real_, min = 1L), "single integer >=")
})

#==============================================================================
# .assert_data_frame()
#==============================================================================

test_that(".assert_data_frame() accepts data.frame input", {
  expect_no_error(evanverse:::.assert_data_frame(data.frame(x = 1:3)))
})

test_that(".assert_data_frame() returns input invisibly on success", {
  x <- data.frame(a = 1)
  expect_identical(evanverse:::.assert_data_frame(x), x)
})

test_that(".assert_data_frame() errors on non-data.frame input", {
  expect_error(evanverse:::.assert_data_frame(list(a = 1)), "must be a data.frame")
  expect_error(evanverse:::.assert_data_frame(matrix(1:4, 2)), "must be a data.frame")
  expect_error(evanverse:::.assert_data_frame(NULL), "must be a data.frame")
})

#==============================================================================
# .assert_dest_path()
#==============================================================================

test_that(".assert_dest_path() accepts destination in existing parent directory", {
  path <- file.path(tempdir(), "out.txt")
  expect_no_error(evanverse:::.assert_dest_path(path))
  expect_equal(evanverse:::.assert_dest_path(path), path)
})

test_that(".assert_dest_path() creates missing parent directories", {
  root <- tempfile("evanverse_dest_")
  path <- file.path(root, "nested", "file.txt")
  on.exit(unlink(root, recursive = TRUE, force = TRUE), add = TRUE)

  expect_no_error(evanverse:::.assert_dest_path(path))
  expect_true(dir.exists(dirname(path)))
})

test_that(".assert_dest_path() errors on invalid path input", {
  expect_error(evanverse:::.assert_dest_path(""), "single non-empty string")
  expect_error(evanverse:::.assert_dest_path(NA_character_), "single non-empty string")
  expect_error(evanverse:::.assert_dest_path(123), "single non-empty string")
})

#==============================================================================
# .assert_has_cols()
#==============================================================================

test_that(".assert_has_cols() accepts data with all required columns", {
  df <- data.frame(a = 1, b = 2)
  expect_no_error(evanverse:::.assert_has_cols(df, c("a", "b")))
  expect_identical(evanverse:::.assert_has_cols(df, c("a")), df)
})

test_that(".assert_has_cols() errors and reports missing columns", {
  df <- data.frame(a = 1, b = 2)
  expect_error(evanverse:::.assert_has_cols(df, c("a", "c")), "missing column")
  expect_error(evanverse:::.assert_has_cols(df, c("x", "y")), "x")
})

#==============================================================================
# .assert_no_dupes()
#==============================================================================

test_that(".assert_no_dupes() accepts vectors without duplicates", {
  expect_no_error(evanverse:::.assert_no_dupes(c("a", "b", "c")))
  expect_no_error(evanverse:::.assert_no_dupes(1:5))
})

test_that(".assert_no_dupes() errors on duplicated values", {
  expect_error(evanverse:::.assert_no_dupes(c("a", "b", "a")), "must not contain duplicate")
  expect_error(evanverse:::.assert_no_dupes(c(1, 2, 2)), "must not contain duplicate")
})

#==============================================================================
# .assert_no_blank()
#==============================================================================

test_that(".assert_no_blank() accepts character vectors without NA/empty values", {
  expect_no_error(evanverse:::.assert_no_blank(c("a", "b")))
  expect_identical(evanverse:::.assert_no_blank("x"), "x")
})

test_that(".assert_no_blank() errors on NA or empty values", {
  expect_error(evanverse:::.assert_no_blank(c("a", "")), "must not contain NA or empty string")
  expect_error(evanverse:::.assert_no_blank(c("a", NA_character_)), "must not contain NA or empty string")
})

#==============================================================================
# .assert_named_vector()
#==============================================================================

test_that(".assert_named_vector() accepts properly named atomic vectors", {
  x <- c(a = 1, b = 2)
  expect_no_error(evanverse:::.assert_named_vector(x))
  expect_identical(evanverse:::.assert_named_vector(x), x)
})

test_that(".assert_named_vector() errors on list input", {
  expect_error(evanverse:::.assert_named_vector(list(a = 1)), "must be a vector")
})

test_that(".assert_named_vector() errors on invalid names", {
  expect_error(evanverse:::.assert_named_vector(c(1, 2)), "named vector")
  expect_error(evanverse:::.assert_named_vector(stats::setNames(c(1, 2), c("", "b"))), "named vector")
  expect_error(
    evanverse:::.assert_named_vector(stats::setNames(c(1, 2), c(NA_character_, "b"))),
    "named vector"
  )
  expect_error(evanverse:::.assert_named_vector(c(a = 1, a = 2)), "duplicate")
})

#==============================================================================
# .assert_proportion()
#==============================================================================

test_that(".assert_proportion() accepts numbers between 0 and 1 (inclusive)", {
  expect_no_error(evanverse:::.assert_proportion(0))
  expect_no_error(evanverse:::.assert_proportion(0.5))
  expect_no_error(evanverse:::.assert_proportion(1))
})

test_that(".assert_proportion() errors on values outside [0, 1] or invalid input", {
  expect_error(evanverse:::.assert_proportion(-0.01), "between 0 and 1")
  expect_error(evanverse:::.assert_proportion(1.01), "between 0 and 1")
  expect_error(evanverse:::.assert_proportion(Inf), "between 0 and 1")
  expect_error(evanverse:::.assert_proportion(NA_real_), "between 0 and 1")
  expect_error(evanverse:::.assert_proportion("0.5"), "between 0 and 1")
  expect_error(evanverse:::.assert_proportion(c(0.1, 0.2)), "between 0 and 1")
})

#==============================================================================
# .assert_numeric_vector()
#==============================================================================

test_that(".assert_numeric_vector() accepts non-empty numeric vectors without NA", {
  expect_no_error(evanverse:::.assert_numeric_vector(c(1, 2, 3)))
  expect_no_error(evanverse:::.assert_numeric_vector(1L))
})

test_that(".assert_numeric_vector() errors on invalid inputs", {
  expect_error(evanverse:::.assert_numeric_vector(numeric(0)), "non-empty numeric vector")
  expect_error(evanverse:::.assert_numeric_vector(c(1, NA_real_)), "non-empty numeric vector")
  expect_error(evanverse:::.assert_numeric_vector("a"), "non-empty numeric vector")
})

#==============================================================================
# .assert_numeric_min()
#==============================================================================

test_that(".assert_numeric_min() accepts finite numeric scalar >= min", {
  expect_no_error(evanverse:::.assert_numeric_min(0))
  expect_no_error(evanverse:::.assert_numeric_min(2, min = 2))
  expect_no_error(evanverse:::.assert_numeric_min(3.5, min = 1))
})

test_that(".assert_numeric_min() errors on invalid inputs", {
  expect_error(evanverse:::.assert_numeric_min(-1, min = 0), ">= 0")
  expect_error(evanverse:::.assert_numeric_min(Inf, min = 0), "finite numeric value")
  expect_error(evanverse:::.assert_numeric_min(NA_real_, min = 0), "finite numeric value")
  expect_error(evanverse:::.assert_numeric_min("1", min = 0), "finite numeric value")
  expect_error(evanverse:::.assert_numeric_min(c(1, 2), min = 0), "finite numeric value")
})

#==============================================================================
# .assert_positive_numeric()
#==============================================================================

test_that(".assert_positive_numeric() accepts finite numeric scalar > 0", {
  expect_no_error(evanverse:::.assert_positive_numeric(0.1))
  expect_no_error(evanverse:::.assert_positive_numeric(10))
})

test_that(".assert_positive_numeric() errors on invalid inputs", {
  expect_error(evanverse:::.assert_positive_numeric(0), "positive numeric value")
  expect_error(evanverse:::.assert_positive_numeric(-1), "positive numeric value")
  expect_error(evanverse:::.assert_positive_numeric(Inf), "positive numeric value")
  expect_error(evanverse:::.assert_positive_numeric(NA_real_), "positive numeric value")
  expect_error(evanverse:::.assert_positive_numeric("1"), "positive numeric value")
  expect_error(evanverse:::.assert_positive_numeric(c(1, 2)), "positive numeric value")
})

#==============================================================================
# .assert_length_n()
#==============================================================================

test_that(".assert_length_n() accepts exact length", {
  x <- c("a", "b")
  expect_no_error(evanverse:::.assert_length_n(x, 2))
  expect_identical(evanverse:::.assert_length_n(x, 2), x)
})

test_that(".assert_length_n() errors on non-matching length", {
  expect_error(evanverse:::.assert_length_n(1:3, 2), "must have length 2")
  expect_error(evanverse:::.assert_length_n(integer(0), 1), "must have length 1")
})

#==============================================================================
# .assert_logical()
#==============================================================================

test_that(".assert_logical() accepts logical vectors", {
  expect_no_error(evanverse:::.assert_logical(TRUE))
  expect_no_error(evanverse:::.assert_logical(c(TRUE, FALSE, NA)))
})

test_that(".assert_logical() errors on non-logical input", {
  expect_error(evanverse:::.assert_logical(1), "must be a logical vector")
  expect_error(evanverse:::.assert_logical("TRUE"), "must be a logical vector")
  expect_error(evanverse:::.assert_logical(NULL), "must be a logical vector")
})

#==============================================================================
# Integration: validate helpers work end-to-end through public API
#==============================================================================

test_that("public functions propagate .assert_scalar_string errors correctly", {
  expect_error(pkg_functions(""),         "single non-empty string")
})

test_that("public functions propagate .assert_flag errors correctly", {
  df <- data.frame(x = letters[1:3], y = 1:3)
  expect_error(plot_bar(df, "x", "y", sort = "yes"), "TRUE or FALSE")
  expect_error(plot_bar(df, "x", "y", sort = NA),    "TRUE or FALSE")
})
