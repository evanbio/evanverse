#===============================================================================
# Test: rgb2hex()
# File: tests/testthat/test-rgb2hex.R
# Description: Unit tests for RGB to HEX conversion utility
# Dependencies: testthat
#===============================================================================

#------------------------------------------------------------------------------
# Basic conversions
#------------------------------------------------------------------------------
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

#------------------------------------------------------------------------------
# Input validation
#------------------------------------------------------------------------------
test_that("throws error for RGB values outside 0-255", {
  expect_error(rgb2hex(c(256, 0, 0)), regexp = "0, 255|in \\[0, 255\\]")
  expect_error(rgb2hex(c(-1, 0, 0)),  regexp = "0, 255|in \\[0, 255\\]")
  expect_error(rgb2hex(list(c(255, 0, 0), c(0, -3, 0))), regexp = "0, 255|in \\[0, 255\\]")
})

test_that("throws error for invalid RGB vector length", {
  expect_error(rgb2hex(c(255, 0)), regexp = "numeric vector of length 3")
  expect_error(rgb2hex(list(c(255, 0, 0), c(255, 0))), regexp = "numeric vector of length 3")
})

test_that("throws error for non-numeric or non-finite input", {
  expect_error(rgb2hex("red"), regexp = "numeric vector")
  expect_error(rgb2hex(list("red", "green")), regexp = "numeric vector")
  expect_error(rgb2hex(c(255, NA, 0)), regexp = "finite")
  expect_error(rgb2hex(c(255, Inf, 0)), regexp = "finite|in \\[0, 255\\]")
})

#------------------------------------------------------------------------------
# Behavior details
#------------------------------------------------------------------------------
test_that("values are rounded before conversion", {
  # 0.4 -> 0, 0.6 -> 1, 254.9 -> 255
  expect_equal(rgb2hex(c(0.4, 0.6, 254.9)), "#0001FF")
})

