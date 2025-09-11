#===============================================================================
# Test: hex2rgb()
# File: test-hex2rgb.R
# Description: Unit tests for the hex2rgb() utility function
#===============================================================================

#------------------------------------------------------------------------------
# Basic Functionality
#------------------------------------------------------------------------------

test_that("hex2rgb() converts single HEX color to RGB vector", {
  result <- suppressMessages(hex2rgb("#FF8000"))
  
  expect_type(result, "double")
  expect_named(result, c("r", "g", "b"))
  expect_equal(result, c(r = 255, g = 128, b = 0))
})

test_that("hex2rgb() handles HEX codes without # prefix", {
  result <- suppressMessages(hex2rgb("00FF00"))
  
  expect_type(result, "double")
  expect_named(result, c("r", "g", "b"))
  expect_equal(result, c(r = 0, g = 255, b = 0))
})

test_that("hex2rgb() converts multiple HEX colors to named list", {
  hex_vec <- c("#FF8000", "#00FF00")
  result <- suppressMessages(hex2rgb(hex_vec))

  expect_type(result, "list")
  expect_named(result, hex_vec)
  expect_length(result, 2)
  expect_equal(result[[1]], c(r = 255, g = 128, b = 0))
  expect_equal(result[[2]], c(r = 0, g = 255, b = 0))
})

test_that("hex2rgb() handles mixed format inputs", {
  hex_vec <- c("#FF8000", "00FF00", "#0000FF")
  result <- suppressMessages(hex2rgb(hex_vec))
  
  expect_length(result, 3)
  expect_equal(result[[1]], c(r = 255, g = 128, b = 0))
  expect_equal(result[[2]], c(r = 0, g = 255, b = 0))
  expect_equal(result[[3]], c(r = 0, g = 0, b = 255))
})

test_that("hex2rgb() handles case insensitive HEX codes", {
  result_upper <- suppressMessages(hex2rgb("#FFFFFF"))
  result_lower <- suppressMessages(hex2rgb("#ffffff"))
  result_mixed <- suppressMessages(hex2rgb("#FfFfFf"))
  
  expected <- c(r = 255, g = 255, b = 255)
  expect_equal(result_upper, expected)
  expect_equal(result_lower, expected)
  expect_equal(result_mixed, expected)
})

#------------------------------------------------------------------------------
# Parameter Validation
#------------------------------------------------------------------------------

test_that("hex2rgb() validates input type correctly", {
  expect_error(hex2rgb(123), "'hex' must be a character vector")
  expect_error(hex2rgb(list("#FF8000")), "'hex' must be a character vector")
  expect_error(hex2rgb(factor("#FF8000")), "'hex' must be a character vector")
  expect_error(hex2rgb(TRUE), "'hex' must be a character vector")
  expect_error(hex2rgb(NULL), "'hex' must be a character vector")
})

test_that("hex2rgb() validates HEX code length", {
  expect_error(hex2rgb(""), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("#"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("F"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("FF"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("FFF"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("#FFF"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("FFFF"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("FFFFF"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("#FF"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("FF80000"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("#FF80000"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb("##FF8000"), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb(c("#FF8000", "FFF")), "Each HEX value must be 6 hex digits")
  expect_error(hex2rgb(c("FF8000", "")), "Each HEX value must be 6 hex digits")
})

#------------------------------------------------------------------------------
# Edge Cases and Special Values
#------------------------------------------------------------------------------

test_that("hex2rgb() handles empty input", {
  result <- hex2rgb(character(0))
  expect_type(result, "list")
  expect_length(result, 0)
  expect_equal(result, list())
})

test_that("hex2rgb() handles extreme color values", {
  # Pure black
  black <- suppressMessages(hex2rgb("#000000"))
  expect_equal(black, c(r = 0, g = 0, b = 0))
  
  # Pure white
  white <- suppressMessages(hex2rgb("#FFFFFF"))
  expect_equal(white, c(r = 255, g = 255, b = 255))
  
  # Pure red, green, blue
  red <- suppressMessages(hex2rgb("#FF0000"))
  green <- suppressMessages(hex2rgb("#00FF00"))
  blue <- suppressMessages(hex2rgb("#0000FF"))
  
  expect_equal(red, c(r = 255, g = 0, b = 0))
  expect_equal(green, c(r = 0, g = 255, b = 0))
  expect_equal(blue, c(r = 0, g = 0, b = 255))
  
  # Gray scales
  gray50 <- suppressMessages(hex2rgb("#808080"))
  expect_equal(gray50, c(r = 128, g = 128, b = 128))
  
  gray25 <- suppressMessages(hex2rgb("#404040"))
  expect_equal(gray25, c(r = 64, g = 64, b = 64))
  
  gray75 <- suppressMessages(hex2rgb("#C0C0C0"))
  expect_equal(gray75, c(r = 192, g = 192, b = 192))
})

test_that("hex2rgb() produces consistent results", {
  # Test that same input produces same output
  hex_code <- "#FF8000"
  result1 <- suppressMessages(hex2rgb(hex_code))
  result2 <- suppressMessages(hex2rgb(hex_code))
  
  expect_identical(result1, result2)
  
  # Test vector vs individual calls
  hex_vec <- c("#FF8000", "#00FF00")
  list_result <- suppressMessages(hex2rgb(hex_vec))
  individual1 <- suppressMessages(hex2rgb("#FF8000"))
  individual2 <- suppressMessages(hex2rgb("#00FF00"))
  
  expect_equal(list_result[[1]], individual1)
  expect_equal(list_result[[2]], individual2)
})

test_that("hex2rgb() handles single element vectors correctly", {
  # Single element should return vector, not list
  result <- suppressMessages(hex2rgb(c("#FF8000")))
  expect_type(result, "double")
  expect_length(result, 3)
  expect_equal(result, c(r = 255, g = 128, b = 0))
  expect_named(result, c("r", "g", "b"))
})

test_that("hex2rgb() messaging behavior with cli", {
  skip_if_not_installed("cli")
  
  # Test single color messaging
  expect_message(hex2rgb("#FF8000"), "FF8000.*RGB.*255.*128.*0")
  
  # Test multiple colors messaging
  expect_message(hex2rgb(c("#FF8000", "#00FF00")), "Converted 2 HEX values to RGB")
})

test_that("hex2rgb() handles large vectors efficiently", {
  # Create a large vector of random hex colors
  set.seed(42)
  large_hex <- sprintf("#%06X", sample(0:16777215, 100))
  
  result <- suppressMessages(hex2rgb(large_hex))
  
  expect_type(result, "list")
  expect_length(result, 100)
  expect_named(result, large_hex)
  
  # Check that all results are valid RGB vectors
  for (i in seq_along(result)) {
    expect_type(result[[i]], "double")
    expect_length(result[[i]], 3)
    expect_named(result[[i]], c("r", "g", "b"))
    expect_true(all(result[[i]] >= 0 & result[[i]] <= 255))
  }
})

test_that("hex2rgb() preserves input names in output", {
  # Named vector input
  named_hex <- c(primary = "#FF0000", secondary = "#00FF00", tertiary = "#0000FF")
  result <- suppressMessages(hex2rgb(named_hex))
  
  expect_named(result, c("#FF0000", "#00FF00", "#0000FF"))
  expect_equal(result[["#FF0000"]], c(r = 255, g = 0, b = 0))
  expect_equal(result[["#00FF00"]], c(r = 0, g = 255, b = 0))
  expect_equal(result[["#0000FF"]], c(r = 0, g = 0, b = 255))
})

test_that("hex2rgb() handles numeric-like hex codes", {
  # Hex codes that look like numbers
  result1 <- suppressMessages(hex2rgb("#111111"))
  expect_equal(result1, c(r = 17, g = 17, b = 17))
  
  result2 <- suppressMessages(hex2rgb("#123456"))
  expect_equal(result2, c(r = 18, g = 52, b = 86))
  
  result3 <- suppressMessages(hex2rgb("#999999"))
  expect_equal(result3, c(r = 153, g = 153, b = 153))
})

test_that("hex2rgb() error messages are informative", {
  # Check exact error messages
  expect_error(hex2rgb(123), 
               "'hex' must be a character vector of HEX color codes.", 
               fixed = TRUE)
  
  expect_error(hex2rgb(c("#FF8000", NA)), 
               "NA values are not allowed in 'hex'.", 
               fixed = TRUE)
  
  expect_error(hex2rgb("#FFF"), 
               "Each HEX value must be 6 hex digits (optionally prefixed with '#').", 
               fixed = TRUE)
  
  expect_error(hex2rgb("#GGGGGG"), 
               "HEX values must be valid 6-digit hexadecimal codes.", 
               fixed = TRUE)
})

#===============================================================================
# End: test-hex2rgb.R
#===============================================================================

