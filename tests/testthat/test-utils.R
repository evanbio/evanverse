#===============================================================================
# Test: utils.R internal helpers
# File: test-utils.R
# Description: Unit tests for .assert_scalar_string(), .assert_dir_path(),
#              .assert_flag(), .assert_count()
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
# Integration: validate helpers work end-to-end through public API
#==============================================================================

test_that("public functions propagate .assert_scalar_string errors correctly", {
  expect_error(get_palette(123),          "single non-empty string")
  expect_error(hex2rgb(character(0)),     "non-empty character vector")
})

test_that("public functions propagate .assert_count errors correctly", {
  skip_if_not({
    f <- system.file("extdata", "palettes.rds", package = "evanverse")
    file.exists(f)
  }, "Compiled palette RDS not found")

  expect_error(
    get_palette("qual_vivid", type = "qualitative", n = 0),
    "single positive integer"
  )
  expect_error(
    get_palette("qual_vivid", type = "qualitative", n = Inf),
    "single positive integer"
  )
})

test_that("public functions propagate .assert_flag errors correctly", {
  expect_error(list_palettes(sort = "yes"), "TRUE or FALSE")
  expect_error(list_palettes(sort = NA),    "TRUE or FALSE")
})

#===============================================================================
# End: test-utils.R
#===============================================================================
