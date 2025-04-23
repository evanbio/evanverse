#===============================================================================
# 🧪 Test: map_column()
# 📁 File: test-map_column.R
# 🔍 Description: Unit tests for the map_column() function
#===============================================================================

test_that("map_column() creates a new column correctly", {
  df <- data.frame(id = c("A", "B", "C"))
  label_map <- c("A" = "Apple", "C" = "Cherry")

  result <- map_column(df, by = "id", map = label_map, to = "fruit", preview = FALSE)
  expect_equal(result$fruit, c("Apple", "unknown", "Cherry"))
})

test_that("map_column() overwrites the existing column when overwrite = TRUE", {
  df <- data.frame(id = c("A", "B", "C"))
  label_map <- c("A" = "Apple", "B" = "Banana")

  result <- map_column(df, by = "id", map = label_map, overwrite = TRUE, preview = FALSE)
  expect_equal(result$id, c("Apple", "Banana", "unknown"))
})

test_that("map_column() handles list input as map", {
  df <- data.frame(group = c("G1", "G2", "G3"))
  group_map <- list("G1" = "Control", "G3" = "Treatment")

  result <- map_column(df, by = "group", map = group_map, to = "condition", preview = FALSE)
  expect_equal(result$condition, c("Control", "unknown", "Treatment"))
})

test_that("map_column() throws error on invalid input", {
  df <- data.frame(x = c("A", "B"))
  expect_error(map_column(df, by = "y", map = c("A" = "a"), preview = FALSE))
  expect_error(map_column(df, by = "x", map = c("A", "B"), preview = FALSE))
})

