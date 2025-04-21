#===============================================================================
# 🧪 Test: get_palette()
# 📁 File: test-get_palette.R
# 🔍 Description: Unit tests for get_palette() from palettes.rds
#===============================================================================

# Skip if data file not present
test_that("get_palette() loads correctly from compiled palettes", {
  f <- here::here("data/palettes.rds")
  skip_if_not(file.exists(f), "Compiled palette RDS not found.")

  # Valid case: full palette
  p1 <- get_palette("vividset", type = "qualitative")
  expect_type(p1, "character")
  expect_true(length(p1) > 0)

  # Valid case: subset
  p2 <- get_palette("vividset", type = "qualitative", n = 3)
  expect_length(p2, 3)

  # Valid case: different type
  p3 <- get_palette("piyg", type = "diverging", n = 2)
  expect_true(all(grepl("^#", p3)))
})

#------------------------------------------------------------------------------
# ⚠️ Type mismatch & missing palette handling
#------------------------------------------------------------------------------

test_that("get_palette() gives type suggestion on mismatch", {
  f <- here::here("data","palettes.rds")
  skip_if_not(file.exists(f), "Compiled palette RDS not found.")

  expect_error(
    get_palette("vividset", type = "sequential"),
    regexp = "but exists under 'qualitative'"
  )
})

test_that("get_palette() throws for invalid palette name", {
  f <- here::here("data","palettes.rds")
  skip_if_not(file.exists(f), "Compiled palette RDS not found.")

  expect_error(
    get_palette("nonexistent", type = "qualitative"),
    regexp = "not found in any type"
  )
})

#------------------------------------------------------------------------------
# ❌ Parameter validation
#------------------------------------------------------------------------------

test_that("get_palette() throws error for bad n values", {
  f <- here::here("data/palettes.rds")
  skip_if_not(file.exists(f), "Compiled palette RDS not found.")

  expect_error(get_palette("vividset", "qualitative", n = 9999),
               regexp = "only has .* colors")

  expect_error(get_palette("vividset", "qualitative", n = 1.5))
  expect_error(get_palette("vividset", "qualitative", n = -2))
  expect_error(get_palette("vividset", "qualitative", n = "a"))
})

