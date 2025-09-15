#===============================================================================
# Test: plot_forest()
# File: test-plot_forest.R
# Description: Unit tests for the plot_forest() function
#===============================================================================

# ------------------------------------------------------------------------------
# Standard input
# ------------------------------------------------------------------------------
test_that("plot_forest runs correctly with standard input", {
  skip_on_cran()
  skip_if_not_installed("forestploter")
  skip_if_not_installed("grid")

  df <- data.frame(
    variable   = c("Age >= 65", "Male", "Hypertension", "Diabetes", "Smoker"),
    estimate   = c(1.45, 0.88, 1.67, 1.22, 0.95),
    conf.low   = c(1.10, 0.65, 1.23, 0.89, 0.71),
    conf.high  = c(1.91, 1.18, 2.26, 1.67, 1.28),
    p.value    = c(0.008, 0.387, 0.001, 0.213, 0.752),
    stringsAsFactors = FALSE
  )

  fp <- plot_forest(df)
  expect_true(inherits(fp, "gTree") || inherits(fp, "forestplot"))
})

# ------------------------------------------------------------------------------
# Significant rows (bold formatting)
# ------------------------------------------------------------------------------
test_that("plot_forest handles significant rows with bold formatting", {
  skip_on_cran()
  skip_if_not_installed("forestploter")
  skip_if_not_installed("grid")

  df <- data.frame(
    variable   = c("Factor A", "Factor B"),
    estimate   = c(1.2, 0.8),
    conf.low   = c(1.1, 0.6),
    conf.high  = c(1.4, 1.1),
    p.value    = c(0.01, 0.10),
    stringsAsFactors = FALSE
  )

  fp <- plot_forest(df, sig_level = 0.05, bold_sig = TRUE)
  expect_true(inherits(fp, "gTree") || inherits(fp, "forestplot"))
})

# ------------------------------------------------------------------------------
# Missing columns error
# ------------------------------------------------------------------------------
test_that("plot_forest throws error when required columns are missing", {
  skip_on_cran()
  skip_if_not_installed("forestploter")
  skip_if_not_installed("grid")

  bad_df <- data.frame(
    variable = c("A", "B"),
    estimate = c(1.2, 0.8),
    conf.low = c(1.0, 0.5),
    stringsAsFactors = FALSE
  )

  expect_error(plot_forest(bad_df), "Missing required columns")
})

# ------------------------------------------------------------------------------
# Box color recycling
# ------------------------------------------------------------------------------
test_that("plot_forest handles short boxcolor vectors by recycling", {
  skip_on_cran()
  skip_if_not_installed("forestploter")
  skip_if_not_installed("grid")

  set.seed(101)
  df <- data.frame(
    variable   = LETTERS[1:10],
    estimate   = stats::runif(10, 0.5, 2),
    conf.low   = stats::runif(10, 0.3, 1.5),
    conf.high  = stats::runif(10, 1.6, 3),
    p.value    = stats::runif(10),
    stringsAsFactors = FALSE
  )

  fp <- plot_forest(df, boxcolor = c("#E64B35", "#4DBBD5"))
  expect_true(inherits(fp, "gTree") || inherits(fp, "forestplot"))
})

# ------------------------------------------------------------------------------
# Column alignment options
# ------------------------------------------------------------------------------
test_that("plot_forest aligns columns correctly", {
  skip_on_cran()
  skip_if_not_installed("forestploter")
  skip_if_not_installed("grid")

  df <- data.frame(
    variable   = c("X", "Y"),
    estimate   = c(1.0, 1.5),
    conf.low   = c(0.8, 1.2),
    conf.high  = c(1.2, 1.8),
    p.value    = c(0.04, 0.10),
    stringsAsFactors = FALSE
  )

  fp <- plot_forest(
    df,
    align_left = 1,
    align_center = 2,
    align_right = 4
  )
  expect_true(inherits(fp, "gTree") || inherits(fp, "forestplot"))
})

# ------------------------------------------------------------------------------
# Arrow labels fallback
# ------------------------------------------------------------------------------
test_that("plot_forest handles improper arrow labels gracefully", {
  skip_on_cran()
  skip_if_not_installed("forestploter")
  skip_if_not_installed("grid")

  df <- data.frame(
    variable   = c("Treat", "Control"),
    estimate   = c(1.1, 0.9),
    conf.low   = c(0.9, 0.7),
    conf.high  = c(1.3, 1.1),
    p.value    = c(0.03, 0.25),
    stringsAsFactors = FALSE
  )

  fp <- plot_forest(df, arrow_lab = "Not enough")
  expect_true(inherits(fp, "gTree") || inherits(fp, "forestplot"))
})

# ------------------------------------------------------------------------------
# Custom axis range and ticks
# ------------------------------------------------------------------------------
test_that("plot_forest respects custom xlim and ticks", {
  skip_on_cran()
  skip_if_not_installed("forestploter")
  skip_if_not_installed("grid")

  df <- data.frame(
    variable   = c("A", "B", "C"),
    estimate   = c(0.9, 1.2, 1.8),
    conf.low   = c(0.7, 1.0, 1.3),
    conf.high  = c(1.1, 1.5, 2.4),
    p.value    = c(0.20, 0.03, 0.06),
    stringsAsFactors = FALSE
  )

  fp <- plot_forest(df, xlim = c(0.5, 2.5), ticks_at = c(0.5, 1, 1.5, 2, 2.5))
  expect_true(inherits(fp, "gTree") || inherits(fp, "forestplot"))
})
