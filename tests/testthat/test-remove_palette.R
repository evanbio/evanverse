#===============================================================================
# Test: remove_palette()
# File: test-remove_palette.R
# Description: Unit tests for the remove_palette() function
#===============================================================================

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("remove_palette() validates name parameter correctly", {
  # Missing name
  expect_error(
    remove_palette(),
    "'name' must be a non-empty character string"
  )
  
  # Invalid name types
  expect_error(
    remove_palette(name = c("test1", "test2")),
    "'name' must be a non-empty character string"
  )
  
  expect_error(
    remove_palette(name = NA_character_),
    "'name' must be a non-empty character string"
  )
  
  expect_error(
    remove_palette(name = ""),
    "'name' must be a non-empty character string"
  )
  
  expect_error(
    remove_palette(name = 123),
    "'name' must be a non-empty character string"
  )
})

test_that("remove_palette() validates color_dir parameter correctly", {
  expect_error(
    remove_palette(name = "test", color_dir = c("dir1", "dir2")),
    "'color_dir' must be a character string"
  )
  
  expect_error(
    remove_palette(name = "test", color_dir = NA_character_),
    "'color_dir' must be a character string"
  )
  
  expect_error(
    remove_palette(name = "test", color_dir = 123),
    "'color_dir' must be a character string"
  )
})

test_that("remove_palette() validates log parameter correctly", {
  expect_error(
    remove_palette(name = "test", log = "TRUE"),
    "'log' must be TRUE or FALSE"
  )
  
  expect_error(
    remove_palette(name = "test", log = c(TRUE, FALSE)),
    "'log' must be TRUE or FALSE"
  )
  
  expect_error(
    remove_palette(name = "test", log = NA),
    "'log' must be TRUE or FALSE"
  )
})

test_that("remove_palette() validates type parameter correctly", {
  expect_error(
    remove_palette(name = "test", type = "invalid"),
    "'arg' should be one of"
  )
  
  # Valid types should work (but will show message about missing file)
  expect_message({
    result <- remove_palette(name = "nonexistent", type = "sequential")
    expect_false(result)
  }, "Palette not found")
})

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("remove_palette() works with existing palette", {
  # Create temporary directory and test palette
  temp_dir <- tempfile("palettes_test_")
  dir.create(temp_dir, recursive = TRUE)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  # Create test palette file
  palette_name <- "test_palette"
  palette_type <- "qualitative"
  palette_dir <- file.path(temp_dir, palette_type)
  dir.create(palette_dir, recursive = TRUE)
  
  palette_file <- file.path(palette_dir, paste0(palette_name, ".json"))
  writeLines('{"colors": ["#FF0000", "#00FF00", "#0000FF"]}', palette_file)
  
  # Test removal
  result <- remove_palette(
    name = palette_name,
    type = palette_type,
    color_dir = temp_dir,
    log = FALSE
  )
  
  expect_true(result)
  expect_false(file.exists(palette_file))
})

test_that("remove_palette() handles non-existent palette gracefully", {
  temp_dir <- tempfile("palettes_test_")
  dir.create(temp_dir, recursive = TRUE)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  result <- remove_palette(
    name = "nonexistent",
    color_dir = temp_dir,
    log = FALSE
  )
  
  expect_false(result)
})

test_that("remove_palette() searches across types when type is NULL", {
  temp_dir <- tempfile("palettes_test_")
  dir.create(temp_dir, recursive = TRUE)
  on.exit(unlink(temp_dir, recursive = TRUE))
  
  # Create palette in diverging type
  palette_name <- "test_palette"
  palette_type <- "diverging"
  palette_dir <- file.path(temp_dir, palette_type)
  dir.create(palette_dir, recursive = TRUE)
  
  palette_file <- file.path(palette_dir, paste0(palette_name, ".json"))
  writeLines('{"colors": ["#FF0000", "#00FF00"]}', palette_file)
  
  # Should find and remove even without specifying type
  result <- remove_palette(
    name = palette_name,
    color_dir = temp_dir,
    log = FALSE
  )
  
  expect_true(result)
  expect_false(file.exists(palette_file))
})

test_that("remove_palette() works with custom color_dir", {
  custom_dir <- tempfile("custom_palettes_")
  dir.create(custom_dir, recursive = TRUE)
  on.exit(unlink(custom_dir, recursive = TRUE))
  
  # Create test palette in custom location
  palette_name <- "custom_test"
  palette_type <- "qualitative"
  palette_dir <- file.path(custom_dir, palette_type)
  dir.create(palette_dir, recursive = TRUE)
  
  palette_file <- file.path(palette_dir, paste0(palette_name, ".json"))
  writeLines('{"colors": ["#123456"]}', palette_file)
  
  result <- remove_palette(
    name = palette_name,
    type = palette_type,
    color_dir = custom_dir,
    log = FALSE
  )
  
  expect_true(result)
  expect_false(file.exists(palette_file))
})
