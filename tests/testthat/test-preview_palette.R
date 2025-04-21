#===============================================================================
# 🧪 Test: preview_palette()
# 📁 File: test-preview_palette.R
# 🔍 Description: Basic smoke tests for preview_palette() function
#===============================================================================

test_that("preview_palette() generates plots for different types", {
  f <- here::here("data", "palettes.rds")
  skip_if_not(file.exists(f), "Compiled palette RDS not found.")

  expect_invisible(preview_palette("vividset", type = "qualitative", plot_type = "bar", palette_rds = f))
  expect_invisible(preview_palette("vividset", type = "qualitative", plot_type = "pie", palette_rds = f))
  expect_invisible(preview_palette("vividset", type = "qualitative", plot_type = "point", palette_rds = f))
  expect_invisible(preview_palette("vividset", type = "qualitative", plot_type = "rect", palette_rds = f))
  expect_invisible(preview_palette("vividset", type = "qualitative", plot_type = "circle", palette_rds = f))
})

test_that("preview_palette() fails on invalid type", {
  f <- here::here("data", "palettes.rds")
  skip_if_not(file.exists(f), "Compiled palette RDS not found.")

  expect_error(preview_palette("vividset", type = "qualitative", plot_type = "banana", palette_rds = f))
})

