# tests/testthat/test-plot_venn.R

test_that("classic method returns a ggplot", {
  s1 <- sample(letters, 100, replace = TRUE)
  s2 <- sample(letters, 120, replace = TRUE)
  p <- plot_venn(s1, s2, method = "classic", preview = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("gradient method returns a ggplot", {
  s1 <- sample(letters, 100, replace = TRUE)
  s2 <- sample(letters, 120, replace = TRUE)
  p <- plot_venn(s1, s2, method = "gradient", preview = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("return_sets returns a named list", {
  s1 <- sample(letters, 100, replace = TRUE)
  s2 <- sample(letters, 120, replace = TRUE)
  out <- plot_venn(s1, s2, return_sets = TRUE, preview = FALSE)
  expect_type(out, "list")
  expect_named(out, c("plot", "sets"))
  expect_s3_class(out$plot, "ggplot")
  expect_type(out$sets, "list")
  expect_true(all(sapply(out$sets, is.vector)))
})

test_that("supports 3 and 4 sets", {
  g <- paste0("gene", 1:2000)
  a <- sample(g, 1000)
  b <- sample(g, 800)
  c <- sample(g, 600)
  d <- sample(g, 400)

  expect_s3_class(plot_venn(a, b, c, preview = FALSE), "ggplot")
  expect_s3_class(plot_venn(a, b, c, d, preview = FALSE), "ggplot")
})

test_that("category.names mismatch handled gracefully", {
  a <- sample(letters, 50, replace = TRUE)
  b <- sample(letters, 40, replace = TRUE)
  expect_warning(
    plot_venn(a, b, category.names = c("A"), preview = FALSE),
    regexp = "doesn't match number of sets"
  )
})

test_that("non-vector input triggers error", {
  a <- data.frame(x = 1:10)
  b <- 1:10
  expect_error(
    plot_venn(a, b, preview = FALSE),
    regexp = "not a vector"
  )
})

test_that("empty input triggers error", {
  a <- character(0)
  b <- letters[1:10]
  expect_error(
    plot_venn(a, b, preview = FALSE),
    regexp = "is empty"
  )
})

test_that("type mismatch triggers warning", {
  a <- letters[1:5]
  b <- 1:5
  expect_warning(
    plot_venn(a, b, preview = FALSE),
    regexp = "Type mismatch"
  )
})
