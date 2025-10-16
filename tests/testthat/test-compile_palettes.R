#==============================================================================
# Test: compile_palettes()
# File: test-compile_palettes.R
# Description: Unit tests for compile_palettes() from JSON files
#==============================================================================

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
test_that("compile_palettes() compiles valid palettes and returns path", {
  # Create temporary directory with JSON file
  tmp_dir <- tempfile("palettes_")
  dir.create(file.path(tmp_dir, "qualitative"), recursive = TRUE)

  json_path <- file.path(tmp_dir, "qualitative", "demo_palette.json")
  jsonlite::write_json(
    list(
      name = "demo_palette",
      type = "qualitative",
      colors = c("#123456", "#654321")
    ),
    path = json_path,
    pretty = TRUE, auto_unbox = TRUE
  )

  # Output path
  out_rds <- tempfile(fileext = ".rds")

  # Call function
  result <- compile_palettes(
    palettes_dir = tmp_dir,
    output_rds = out_rds,
    log = FALSE
  )

  expect_type(result, "character")
  expect_true(file.exists(result))

  palettes <- readRDS(result)
  expect_true("demo_palette" %in% names(palettes$qualitative))

  # Cleanup
  unlink(tmp_dir, recursive = TRUE)
  unlink(out_rds)
})

# ------------------------------------------------------------------------------
# Error handling tests
# ------------------------------------------------------------------------------
test_that("compile_palettes() fails for non-existent directory", {
  out_rds <- tempfile(fileext = ".rds")
  expect_error(compile_palettes("nonexistent_directory", output_rds = out_rds, log = FALSE),
               "Palettes directory does not exist")
})

test_that("compile_palettes() handles invalid JSON gracefully", {
  # Create temporary directory with invalid JSON
  tmp_dir <- tempfile("palettes_")
  dir.create(file.path(tmp_dir, "qualitative"), recursive = TRUE)

  json_path <- file.path(tmp_dir, "qualitative", "invalid.json")
  writeLines("invalid json content", json_path)

  out_rds <- tempfile(fileext = ".rds")

  # Should not crash, should handle gracefully
  result <- compile_palettes(
    palettes_dir = tmp_dir,
    output_rds = out_rds,
    log = FALSE
  )

  # Should return the output path even if no valid palettes
  expect_type(result, "character")
  expect_true(file.exists(result))

  # Cleanup
  unlink(tmp_dir, recursive = TRUE)
  unlink(out_rds)
})

test_that("compile_palettes() handles missing required fields", {
  # Create temporary directory with incomplete JSON
  tmp_dir <- tempfile("palettes_")
  dir.create(file.path(tmp_dir, "qualitative"), recursive = TRUE)

  json_path <- file.path(tmp_dir, "qualitative", "incomplete.json")
  jsonlite::write_json(
    list(
      name = "incomplete_palette",
      type = "qualitative"
      # Missing colors
    ),
    path = json_path,
    pretty = TRUE, auto_unbox = TRUE
  )

  out_rds <- tempfile(fileext = ".rds")

  # Should handle missing fields gracefully
  result <- compile_palettes(
    palettes_dir = tmp_dir,
    output_rds = out_rds,
    log = FALSE
  )

  # Should return the output path
  expect_type(result, "character")
  expect_true(file.exists(result))

  # Cleanup
  unlink(tmp_dir, recursive = TRUE)
  unlink(out_rds)
})

# ------------------------------------------------------------------------------
# Multiple types test
# ------------------------------------------------------------------------------
test_that("compile_palettes() handles multiple palette types", {
  # Create temporary directory with multiple types
  tmp_dir <- tempfile("palettes_")

  # Create subdirectories for each type
  types <- c("sequential", "diverging", "qualitative")
  for (type in types) {
    dir.create(file.path(tmp_dir, type), recursive = TRUE)
  }

  # Sequential palette
  jsonlite::write_json(
    list(name = "seq_pal", type = "sequential", colors = c("#111111", "#222222")),
    file.path(tmp_dir, "sequential", "seq.json"), pretty = TRUE, auto_unbox = TRUE
  )

  # Diverging palette
  jsonlite::write_json(
    list(name = "div_pal", type = "diverging", colors = c("#333333", "#444444")),
    file.path(tmp_dir, "diverging", "div.json"), pretty = TRUE, auto_unbox = TRUE
  )

  out_rds <- tempfile(fileext = ".rds")

  result <- compile_palettes(
    palettes_dir = tmp_dir,
    output_rds = out_rds,
    log = FALSE
  )

  palettes <- readRDS(result)
  expect_true("seq_pal" %in% names(palettes$sequential))
  expect_true("div_pal" %in% names(palettes$diverging))

  # Cleanup
  unlink(tmp_dir, recursive = TRUE)
  unlink(out_rds)
})

