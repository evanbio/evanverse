#===============================================================================
# Test: plot_venn()
# File: test-plot_venn.R
# Description: Unit tests for the plot_venn() function
#===============================================================================

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("plot_venn() validates required sets", {
  expect_error(plot_venn(), "At least two sets")
  expect_error(plot_venn(set1 = letters[1:5]), "At least two sets")
})

test_that("plot_venn() validates character parameters", {
  s1 <- letters[1:5]
  s2 <- letters[3:7]

  expect_error(plot_venn(s1, s2, label_color = 123), "`label_color` must be a single non-NA character string")
  expect_error(plot_venn(s1, s2, label_color = c("red", "blue")), "`label_color` must be a single non-NA character string")
  expect_error(plot_venn(s1, s2, label_color = NA), "`label_color` must be a single non-NA character string")

  expect_error(plot_venn(s1, s2, set_color = 123), "`set_color` must be a single non-NA character string")
  expect_error(plot_venn(s1, s2, title_color = c("red", "blue")), "`title_color` must be a single non-NA character string")
  expect_error(plot_venn(s1, s2, title = 123), "`title` must be a single non-NA character string")
  expect_error(plot_venn(s1, s2, label_sep = 123), "`label_sep` must be a single non-NA character string")
  expect_error(plot_venn(s1, s2, palette = 123), "`palette` must be a single non-NA character string")
})

test_that("plot_venn() validates logical parameters", {
  s1 <- letters[1:5]
  s2 <- letters[3:7]

  expect_error(plot_venn(s1, s2, preview = "yes"), "`preview` must be a single logical value")
  expect_error(plot_venn(s1, s2, preview = c(TRUE, FALSE)), "`preview` must be a single logical value")

  expect_error(plot_venn(s1, s2, return_sets = "yes"), "`return_sets` must be a single logical value")
  expect_error(plot_venn(s1, s2, auto_scale = "yes"), "`auto_scale` must be a single logical value")
})

test_that("plot_venn() validates alpha parameters", {
  s1 <- letters[1:5]
  s2 <- letters[3:7]

  expect_error(plot_venn(s1, s2, label_alpha = -0.1), "`label_alpha` must be a numeric value between 0 and 1")
  expect_error(plot_venn(s1, s2, label_alpha = 1.1), "`label_alpha` must be a numeric value between 0 and 1")
  expect_error(plot_venn(s1, s2, label_alpha = "invalid"), "`label_alpha` must be a numeric value between 0 and 1")

  expect_error(plot_venn(s1, s2, fill_alpha = -0.1), "`fill_alpha` must be a numeric value between 0 and 1")
  expect_error(plot_venn(s1, s2, fill_alpha = 1.1), "`fill_alpha` must be a numeric value between 0 and 1")
})

test_that("plot_venn() validates label parameter", {
  s1 <- letters[1:5]
  s2 <- letters[3:7]

  expect_error(plot_venn(s1, s2, label = "invalid"), "`label` must be one of")
  expect_error(plot_venn(s1, s2, label = 123), "`label` must be one of")
  expect_error(plot_venn(s1, s2, label = c("count", "percent")), "`label` must be one of")
})

test_that("plot_venn() validates label_geom parameter", {
  s1 <- letters[1:5]
  s2 <- letters[3:7]

  expect_error(plot_venn(s1, s2, method = "gradient", label_geom = "invalid"), "`label_geom` must be one of")
  expect_error(plot_venn(s1, s2, method = "gradient", label_geom = 123), "`label_geom` must be one of")
})

test_that("plot_venn() validates method parameter", {
  s1 <- letters[1:5]
  s2 <- letters[3:7]

  expect_error(plot_venn(s1, s2, method = "invalid"), "'arg' should be one of")
})

#------------------------------------------------------------------------------
# Basic Functionality Tests
#------------------------------------------------------------------------------

test_that("plot_venn() gradient method returns a ggplot", {
  s1 <- sample(letters, 100, replace = TRUE)
  s2 <- sample(letters, 120, replace = TRUE)
  p <- plot_venn(s1, s2, method = "gradient", preview = FALSE)
  expect_s3_class(p, "ggplot")
})

test_that("plot_venn() return_sets returns a named list", {
  s1 <- sample(letters, 100, replace = TRUE)
  s2 <- sample(letters, 120, replace = TRUE)
  suppressWarnings(
    out <- plot_venn(s1, s2, return_sets = TRUE, preview = FALSE)
  )
  expect_type(out, "list")
  expect_named(out, c("plot", "sets"))
  expect_s3_class(out$plot, "ggplot")
  expect_type(out$sets, "list")
  expect_true(all(sapply(out$sets, is.vector)))
})

test_that("plot_venn() supports 3 and 4 sets", {
  g <- paste0("gene", 1:2000)
  a <- sample(g, 1000)
  b <- sample(g, 800)
  c <- sample(g, 600)
  d <- sample(g, 400)

  expect_s3_class(plot_venn(a, b, c, preview = FALSE), "ggplot")
  expect_s3_class(plot_venn(a, b, c, d, preview = FALSE), "ggplot")
})

#------------------------------------------------------------------------------
# Input Validation Tests
#------------------------------------------------------------------------------

test_that("plot_venn() category.names mismatch handled gracefully", {
  a <- sample(letters, 50, replace = TRUE)
  b <- sample(letters, 40, replace = TRUE)
  expect_warning(
    plot_venn(a, b, category.names = c("A"), preview = FALSE),
    regexp = "doesn't match number of sets"
  )
})

test_that("plot_venn() non-vector input triggers error", {
  a <- data.frame(x = 1:10)
  b <- 1:10
  expect_error(
    plot_venn(a, b, preview = FALSE),
    regexp = "not a vector"
  )
})

test_that("plot_venn() empty input triggers error", {
  a <- character(0)
  b <- letters[1:10]
  expect_error(
    plot_venn(a, b, preview = FALSE),
    regexp = "is empty"
  )
})

test_that("plot_venn() type mismatch triggers warning", {
  a <- letters[1:5]
  b <- 1:5
  expect_warning(
    plot_venn(a, b, preview = FALSE),
    regexp = "Type mismatch"
  )
})

#------------------------------------------------------------------------------
# Customization Tests
#------------------------------------------------------------------------------

test_that("plot_venn() handles custom colors and styling", {
  s1 <- letters[1:10]
  s2 <- letters[5:15]

  expect_s3_class(
    plot_venn(s1, s2,
              fill = c("red", "blue"),
              label_color = "white",
              set_color = "black",
              title = "Custom Venn",
              title_color = "purple",
              preview = FALSE),
    "ggplot"
  )
})

test_that("plot_venn() handles different label types", {
  s1 <- letters[1:10]
  s2 <- letters[5:15]

  for (lbl in c("count", "percent", "both", "none")) {
    expect_s3_class(
      plot_venn(s1, s2, label = lbl, preview = FALSE),
      "ggplot"
    )
  }
})

test_that("plot_venn() handles gradient method parameters", {
  s1 <- letters[1:10]
  s2 <- letters[5:15]

  expect_s3_class(
    plot_venn(s1, s2,
              method = "gradient",
              palette = "Blues",
              direction = -1,
              label_geom = "text",
              preview = FALSE),
    "ggplot"
  )
})

#===============================================================================
# End: test-plot_venn.R
#===============================================================================

