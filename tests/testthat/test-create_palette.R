# =============================================================================
# Test: create_palette()
# File: test-create_palette.R
# Description: Tests for saving custom color palettes as JSON
# =============================================================================

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
test_that("create_palette() creates file in expected directory", {
  tmp_dir <- tempfile("palette_test_")
  dir.create(tmp_dir)

  result <- create_palette(
    name = "testset",
    type = "qualitative",
    colors = c("#FF0000", "#00FF00", "#0000FF"),
    color_dir = tmp_dir,
    log = FALSE
  )

  expect_type(result, "list")
  expect_true(file.exists(result$path))
  expect_true(grepl("testset\\.json$", result$path))
})

test_that("create_palette() refuses invalid hex codes", {
  expect_error(
    create_palette(
      name = "badhex",
      type = "sequential",
      colors = c("red", "blue", "#12345G"),
      color_dir = tempdir(),
      log = FALSE
    ),
    regexp = "not valid HEX"
  )
})

test_that("create_palette() reuses existing file", {
  tmp_dir <- tempfile("reuse_test_")
  dir.create(tmp_dir)

  path1 <- create_palette(
    name = "reused",
    type = "diverging",
    colors = c("#AAAAAA", "#BBBBBB"),
    color_dir = tmp_dir,
    log = FALSE
  )$path

  path2 <- create_palette(
    name = "reused",
    type = "diverging",
    colors = c("#AAAAAA", "#BBBBBB"),
    color_dir = tmp_dir,
    log = FALSE
  )$path

  expect_equal(path1, path2)
  expect_true(file.exists(path1))
})

test_that("create_palette() logs correctly when enabled", {
  tmp_dir <- tempfile("log_test_")
  dir.create(tmp_dir, recursive = TRUE)

  # Change to temp directory to avoid creating logs in package directory
  old_wd <- getwd()
  on.exit(setwd(old_wd))
  setwd(tmp_dir)

  log_file <- file.path("logs/palettes/create_palette.log")

  # Ensure clean start
  if (file.exists(log_file)) file.remove(log_file)

  create_palette(
    name = "logtest",
    type = "qualitative",
    colors = c("#123456", "#654321"),
    color_dir = tmp_dir,
    log = TRUE
  )

  expect_true(file.exists(log_file))
  log_content <- readLines(log_file)
  expect_true(any(grepl("logtest", log_content)))

  # Clean up logs directory
  unlink("logs", recursive = TRUE)
})

