#===============================================================================
# 🧪 Test: list_palettes()
# 📁 File: test-list_palettes.R
# 🔍 Description: Unit tests for list_palettes() function
#===============================================================================

test_that("list_palettes() loads and returns expected structure", {
  f <- here::here("data/palettes.rds")
  skip_if_not(file.exists(f), "Palette RDS not found")

  df <- list_palettes(palette_rds = f, verbose = FALSE)
  expect_s3_class(df, "data.frame")
  expect_true(all(c("name", "type", "n_color", "colors") %in% names(df)))
  expect_true(nrow(df) > 0)
  expect_type(df$colors[[1]], "character")
})

test_that("list_palettes() filters by type", {
  f <- here::here("data/palettes.rds")
  skip_if_not(file.exists(f), "Palette RDS not found")

  df <- list_palettes(palette_rds = f, type = "qualitative", verbose = FALSE)
  expect_true(all(df$type == "qualitative"))
})

test_that("list_palettes() throws error for invalid type", {
  f <- here::here("data/palettes.rds")
  skip_if_not(file.exists(f), "Palette RDS not found")

  expect_error(
    list_palettes(palette_rds = f, type = "nonexistent", verbose = FALSE),
    regexp = "'arg' should be one of"
  )
})

