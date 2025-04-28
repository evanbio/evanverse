# 📦 test-palettes.R
# Test create_palette() and remove_palette() functions

test_that("create_palette() and remove_palette() work correctly", {
  # Temporary directory for test
  temp_dir <- tempfile("palettes_test_")
  dir.create(temp_dir)

  # Define test palette
  test_palette_name <- "test_palette"
  test_palette_type <- "qualitative"
  test_palette_colors <- c("#E64B35", "#4DBBD5", "#00A087")

  # 1. Test create_palette()
  create_result <- create_palette(
    name = test_palette_name,
    type = test_palette_type,
    colors = test_palette_colors,
    color_dir = temp_dir,
    log = FALSE
  )

  expect_true(file.exists(file.path(temp_dir, test_palette_type, paste0(test_palette_name, ".json"))))
  expect_type(create_result, "list")
  expect_true("path" %in% names(create_result))
  expect_true("info" %in% names(create_result))

  # 2. Test remove_palette()
  remove_result <- remove_palette(
    name = test_palette_name,
    type = test_palette_type,
    color_dir = temp_dir,
    log = FALSE
  )

  expect_true(remove_result)
  expect_false(file.exists(file.path(temp_dir, test_palette_type, paste0(test_palette_name, ".json"))))

  # Clean up
  unlink(temp_dir, recursive = TRUE)
})

