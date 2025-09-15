#===============================================================================
# Test: get_palette()
# File: test-get_palette.R
# Description: Unit tests for get_palette() from palettes.rds
#===============================================================================

#------------------------------------------------------------------------------
# Basic Functionality
#------------------------------------------------------------------------------

test_that("get_palette() loads full palette correctly", {
  palette_file <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(palette_file), "Compiled palette RDS not found")

  result <- get_palette("vividset", type = "qualitative")
  
  expect_type(result, "character")
  expect_true(length(result) > 0)
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", result)))
})

test_that("get_palette() loads subset of colors correctly", {
  palette_file <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(palette_file), "Compiled palette RDS not found")

  result <- get_palette("vividset", type = "qualitative", n = 3)
  
  expect_length(result, 3)
  expect_type(result, "character")
  expect_true(all(grepl("^#[0-9A-Fa-f]{6}$", result)))
})

#------------------------------------------------------------------------------
# Parameter Validation
#------------------------------------------------------------------------------

test_that("get_palette() validates name parameter correctly", {
  palette_file <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(palette_file), "Compiled palette RDS not found")

  expect_error(get_palette(123, type = "qualitative"), "'name' must be a single non-empty character string")
  expect_error(get_palette(c("a", "b"), type = "qualitative"), "'name' must be a single non-empty character string")
  expect_error(get_palette("", type = "qualitative"), "'name' must be a single non-empty character string")
  expect_error(get_palette(NA_character_, type = "qualitative"), "'name' must be a single non-empty character string")
})

test_that("get_palette() validates n parameter correctly", {
  palette_file <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(palette_file), "Compiled palette RDS not found")

  expect_error(get_palette("vividset", type = "qualitative", n = 1.5), "'n' must be a single positive integer")
  expect_error(get_palette("vividset", type = "qualitative", n = -2), "'n' must be a single positive integer")
  expect_error(get_palette("vividset", type = "qualitative", n = 0), "'n' must be a single positive integer")
  expect_error(get_palette("vividset", type = "qualitative", n = "a"), "'n' must be a single positive integer")
  expect_error(get_palette("vividset", type = "qualitative", n = c(1, 2)), "'n' must be a single positive integer")
})

test_that("get_palette() validates type parameter correctly", {
  palette_file <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(palette_file), "Compiled palette RDS not found")

  expect_error(get_palette("vividset", type = "invalid"), "'arg' should be one of")
})

#------------------------------------------------------------------------------
# Error Handling and Edge Cases
#------------------------------------------------------------------------------
test_that("get_palette() handles nonexistent palette names", {
  palette_file <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(palette_file), "Compiled palette RDS not found")

  expect_error(
    get_palette("nonexistent_palette", type = "qualitative"),
    "not found in any type"
  )
})

test_that("get_palette() handles requests for too many colors", {
  palette_file <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(palette_file), "Compiled palette RDS not found")

  expect_error(
    get_palette("vividset", type = "qualitative", n = 9999),
    "only has .* colors, but requested"
  )
})

test_that("get_palette() handles missing palette file", {
  expect_error(
    get_palette("vividset", type = "qualitative", palette_rds = "nonexistent.rds"),
    "Please compile palettes first"
  )
})

test_that("get_palette() validates palette_rds parameter", {
  expect_error(
    get_palette("vividset", type = "qualitative", palette_rds = 123),
    "'palette_rds' must be a single character string"
  )
  
  expect_error(
    get_palette("vividset", type = "qualitative", palette_rds = c("a", "b")),
    "'palette_rds' must be a single character string"
  )
})

#===============================================================================
# End: test-get_palette.R
#===============================================================================


