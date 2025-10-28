#===============================================================================
# Test: preview_palette
# File: test-preview_palette.R
# Description: Tests for the preview_palette function (Visualize palettes)
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------
test_that("preview_palette generates plots for different types", {
  # Use the correct path for palettes.rds
  f <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(f), "Compiled palette RDS not found.")

  # Test different plot types
  expect_invisible(preview_palette("qual_vivid", type = "qualitative", plot_type = "bar", palette_rds = f, preview = FALSE))
  expect_invisible(preview_palette("qual_vivid", type = "qualitative", plot_type = "pie", palette_rds = f, preview = FALSE))
  expect_invisible(preview_palette("qual_vivid", type = "qualitative", plot_type = "point", palette_rds = f, preview = FALSE))
  expect_invisible(preview_palette("qual_vivid", type = "qualitative", plot_type = "rect", palette_rds = f, preview = FALSE))
  expect_invisible(preview_palette("qual_vivid", type = "qualitative", plot_type = "circle", palette_rds = f, preview = FALSE))
})

#------------------------------------------------------------------------------
# Parameter validation
#------------------------------------------------------------------------------
test_that("preview_palette validates name parameter", {
  # Test missing name
  expect_error(preview_palette(), "'name' must be a single non-empty character string")

  # Test invalid name types
  expect_error(preview_palette(123), "'name' must be a single non-empty character string")
  expect_error(preview_palette(c("a", "b")), "'name' must be a single non-empty character string")
  expect_error(preview_palette(NA), "'name' must be a single non-empty character string")
})

test_that("preview_palette validates n parameter", {
  # Test invalid n values
  expect_error(preview_palette("test", n = -1), "'n' must be a positive integer or NULL")
  expect_error(preview_palette("test", n = 0), "'n' must be a positive integer or NULL")
  expect_error(preview_palette("test", n = "invalid"), "'n' must be a positive integer or NULL")
  expect_error(preview_palette("test", n = c(1, 2)), "'n' must be a positive integer or NULL")
})

test_that("preview_palette validates title parameter", {
  # Test invalid title
  expect_error(preview_palette("test", title = 123), "'title' must be a single character string")
  expect_error(preview_palette("test", title = c("a", "b")), "'title' must be a single character string")
  expect_error(preview_palette("test", title = NA), "'title' must be a single character string")
})

test_that("preview_palette validates palette_rds parameter", {
  # Test invalid palette_rds
  expect_error(preview_palette("test", palette_rds = 123), "'palette_rds' must be a single character string")
  expect_error(preview_palette("test", palette_rds = c("a", "b")), "'palette_rds' must be a single character string")
  expect_error(preview_palette("test", palette_rds = NA), "'palette_rds' must be a single character string")
})

test_that("preview_palette validates preview parameter", {
  # Test invalid preview
  expect_error(preview_palette("test", preview = "yes"), "'preview' must be a single logical value")
  expect_error(preview_palette("test", preview = c(TRUE, FALSE)), "'preview' must be a single logical value")
  expect_error(preview_palette("test", preview = NA), "'preview' must be a single logical value")
})

test_that("preview_palette validates plot_type parameter", {
  # Test invalid plot_type
  expect_error(preview_palette("test", plot_type = "invalid"), "should be one of")
})

test_that("preview_palette validates type parameter", {
  # Test invalid type
  expect_error(preview_palette("test", type = "invalid"), "should be one of")
})

#------------------------------------------------------------------------------
# File handling
#------------------------------------------------------------------------------
test_that("preview_palette handles missing palette file", {
  # Test with non-existent file
  expect_error(preview_palette("test", palette_rds = "nonexistent.rds"), "Palette file not found")
})

#------------------------------------------------------------------------------
# Preview behavior
#------------------------------------------------------------------------------
test_that("preview_palette respects preview parameter", {
  f <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(f), "Compiled palette RDS not found.")

  # Test preview = FALSE returns invisible NULL
  expect_invisible(preview_palette("qual_vivid", type = "qualitative", preview = FALSE, palette_rds = f))
})
