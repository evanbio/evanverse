#===============================================================================
# Test: bio_palette_gallery()
# File: test-bio_palette_gallery.R
# Description: Unit tests for bio_palette_gallery() function
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------

test_that("bio_palette_gallery() returns named list of ggplot objects", {
  f <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(f), "Palette RDS not found")

  plots <- bio_palette_gallery(palette_rds = f, type = "qualitative",
                               max_palettes = 10, verbose = FALSE)
  expect_type(plots, "list")
  expect_true(all(sapply(plots, inherits, what = "ggplot")))
  expect_true(length(plots) >= 1)
})

test_that("bio_palette_gallery() handles multiple types", {
  f <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(f), "Palette RDS not found")

  plots <- bio_palette_gallery(palette_rds = f,
                               type = c("qualitative", "diverging"),
                               max_palettes = 5,
                               verbose = FALSE)
  expect_true(all(sapply(plots, inherits, what = "ggplot")))
})

#------------------------------------------------------------------------------
# Parameter variations
#------------------------------------------------------------------------------

test_that("bio_palette_gallery() supports page limits and row limits", {
  f <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(f), "Palette RDS not found")

  plots <- bio_palette_gallery(palette_rds = f, type = "qualitative",
                               max_palettes = 2, max_row = 6, verbose = FALSE)
  expect_type(plots, "list")
  expect_gt(length(plots), 0)
})

#------------------------------------------------------------------------------
# Error handling
#------------------------------------------------------------------------------

test_that("bio_palette_gallery() returns empty list if palette_rds is missing", {
  f <- tempfile(fileext = ".rds")  # deliberately not creating the file
  result <- bio_palette_gallery(palette_rds = f, verbose = FALSE)
  expect_type(result, "list")
  expect_length(result, 0)
})

test_that("bio_palette_gallery() throws error on invalid type", {
  f <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(f), "Palette RDS not found")

  expect_error(
    bio_palette_gallery(palette_rds = f, type = "unknown", verbose = FALSE),
    regexp = "should be one of"
  )
})

#------------------------------------------------------------------------------
# Edge cases
#------------------------------------------------------------------------------

test_that("bio_palette_gallery() returns NULL if type not in file", {
  f <- system.file("extdata", "palettes.rds", package = "evanverse")
  skip_if_not(file.exists(f), "Palette RDS not found")

  result <- bio_palette_gallery(palette_rds = f, type = "nonexistent", verbose = FALSE)
  expect_null(result)
})
