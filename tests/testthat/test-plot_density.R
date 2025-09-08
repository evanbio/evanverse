# test-plot_density.R

library(testthat)
test_that("plot_density basic functionality works", {
  # Basic data
  data(iris)
  cols <- c("#66B3FF", "#FFB3C6", "#66CC66")

  # Basic call, only x
  expect_silent(p1 <- plot_density(iris, x = "Sepal.Length"))
  expect_s3_class(p1, "ggplot")

  # Grouped density with palette
  expect_silent(p2 <- plot_density(iris, x = "Sepal.Length", group = "Species", palette = cols))
  expect_s3_class(p2, "ggplot")

  # Grouped + Facet
  expect_silent(p3 <- plot_density(iris, x = "Sepal.Length", group = "Species", facet = "Species", palette = cols))
  expect_s3_class(p3, "ggplot")
})

test_that("palette vector is recycled or truncated", {
  data(iris)
  # Less colors than groups
  pal1 <- c("#66B3FF", "#FFB3C6") # Only 2 colors, 3 groups
  expect_silent(p <- plot_density(iris, x = "Sepal.Length", group = "Species", palette = pal1))
  expect_s3_class(p, "ggplot")

  # More colors than groups
  pal2 <- c("#66B3FF", "#FFB3C6", "#66CC66", "#8DD3C7")
  expect_silent(p <- plot_density(iris, x = "Sepal.Length", group = "Species", palette = pal2))
  expect_s3_class(p, "ggplot")
})

test_that("theme switching works", {
  data(iris)
  cols <- c("#66B3FF", "#FFB3C6", "#66CC66")
  expect_silent(p <- plot_density(iris, x = "Sepal.Length", group = "Species", palette = cols, theme = "bw"))
  expect_s3_class(p, "ggplot")
})

test_that("invalid palette input throws error", {
  data(iris)
  expect_error(
    plot_density(iris, x = "Sepal.Length", group = "Species", palette = "Set1")
  )
  expect_error(
    plot_density(iris, x = "Sepal.Length", group = "Species", palette = character(0))
  )
})

test_that("works with histogram and rug", {
  data(iris)
  cols <- c("#66B3FF", "#FFB3C6", "#66CC66")
  expect_silent(
    p <- plot_density(iris, x = "Sepal.Length", group = "Species", palette = cols,
                      add_hist = TRUE, add_rug = TRUE, hist_bins = 12)
  )
  expect_s3_class(p, "ggplot")
})
