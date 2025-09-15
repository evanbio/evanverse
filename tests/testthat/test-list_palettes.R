#===============================================================================
# Test: list_palettes()
# File: test-list_palettes.R
# Description: Unit tests for list_palettes() function
#===============================================================================

test_that("list_palettes() loads and returns expected structure", {
  palettes <- list(
    sequential = list(A = c("#000000", "#111111")),
    qualitative = list(B = c("red", "blue"))
  )
  tmp <- tempfile(fileext = ".rds")
  saveRDS(palettes, tmp)

  df <- list_palettes(palette_rds = tmp, verbose = FALSE)
  expect_s3_class(df, "data.frame")
  expect_true(all(c("name", "type", "n_color", "colors") %in% names(df)))
  expect_equal(nrow(df), 2)
  expect_type(df$colors[[1]], "character")

  unlink(tmp)
})

test_that("list_palettes() filters by type", {
  palettes <- list(
    sequential = list(A = c("#000000", "#111111")),
    qualitative = list(B = c("red", "blue"))
  )
  tmp <- tempfile(fileext = ".rds")
  saveRDS(palettes, tmp)

  df <- list_palettes(palette_rds = tmp, type = "qualitative", verbose = FALSE)
  expect_true(all(df$type == "qualitative"))

  unlink(tmp)
})

test_that("list_palettes() throws error for invalid type", {
  palettes <- list(
    sequential = list(A = c("#000000")),
    qualitative = list(B = c("red"))
  )
  tmp <- tempfile(fileext = ".rds")
  saveRDS(palettes, tmp)

  expect_error(
    list_palettes(palette_rds = tmp, type = "nonexistent", verbose = FALSE),
    regexp = "should be one of"
  )

  unlink(tmp)
})

