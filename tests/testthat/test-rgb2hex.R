# 📌 Tests for rgb2hex(): RGB to HEX conversion

# ------------------------------------------------------------------------------
# ✅ Basic conversions
# ------------------------------------------------------------------------------

test_that("converts single RGB vector to HEX", {
  expect_equal(rgb2hex(c(255, 128, 0)), "#FF8000")
  expect_equal(rgb2hex(c(0, 0, 0)), "#000000")
  expect_equal(rgb2hex(c(255, 255, 255)), "#FFFFFF")
})

test_that("converts list of RGB vectors to HEX vector", {
  rgb_list <- list(c(255, 128, 0), c(0, 255, 0), c(0, 0, 255))
  hex <- rgb2hex(rgb_list)
  expect_equal(hex, c("#FF8000", "#00FF00", "#0000FF"))
})

# ------------------------------------------------------------------------------
# ✅ Input validation
# ------------------------------------------------------------------------------

test_that("throws error for RGB values outside 0-255", {
  expect_error(rgb2hex(c(256, 0, 0)), "All RGB values must be between 0 and 255.")
  expect_error(rgb2hex(c(-1, 0, 0)), "All RGB values must be between 0 and 255.")
})

test_that("throws error for invalid RGB vector length", {
  expect_error(rgb2hex(c(255, 0)), "RGB must be a numeric vector of length 3.")
  expect_error(rgb2hex(list(c(255, 0, 0), c(255, 0))), "Each RGB entry must be a numeric vector of length 3.")
})

test_that("throws error for non-numeric input", {
  expect_error(rgb2hex("red"), "numeric vector")
  expect_error(rgb2hex(list("red", "green")), "numeric vector")
})
