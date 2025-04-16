# tests/testthat/test-hex2rgb.R
# 📌 Tests for `hex2rgb()` — Convert HEX to RGB color format

# ------------------------------------------------------------------------------
# ✅ Core functionality
# ------------------------------------------------------------------------------

test_that("converts a single HEX color to RGB vector", {
  expect_equal(hex2rgb("#FF8000"), c(255, 128, 0))
  expect_equal(hex2rgb("00FF00"), c(0, 255, 0))
})

test_that("converts multiple HEX colors to RGB list", {
  hex_vec <- c("#FF8000", "#00FF00")
  rgb_list <- hex2rgb(hex_vec)

  expect_type(rgb_list, "list")
  expect_named(rgb_list, hex_vec)
  expect_equal(rgb_list[[1]], c(255, 128, 0))
  expect_equal(rgb_list[[2]], c(0, 255, 0))
})

# ------------------------------------------------------------------------------
# ✅ Input validation
# ------------------------------------------------------------------------------

test_that("throws error for non-character input", {
  expect_error(hex2rgb(123), "character string or vector")
  expect_error(hex2rgb(list("#FF8000")), "character string or vector")
})


test_that("throws error for invalid HEX format", {
  expect_error(hex2rgb("FFF"), "Each HEX value must be 6 characters")
  expect_error(hex2rgb("GGGGGG"), "must be valid 6-digit hex code")
  expect_error(hex2rgb(c("#FF8000", "00GG00")), "must be valid 6-digit hex code")
})
