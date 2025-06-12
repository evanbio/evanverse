# ------------------------------------------------------------------------------
# Tests for plot_forest()
# ------------------------------------------------------------------------------

test_that("plot_forest runs correctly with standard input", {
  skip_if_not_installed("forestploter")
  skip_if_not_installed("grid")
  skip_if_not_installed("dplyr")

  df <- tibble::tibble(
    variable   = c("Age ≥ 65", "Male", "Hypertension", "Diabetes", "Smoker"),
    estimate   = c(1.45, 0.88, 1.67, 1.22, 0.95),
    conf.low   = c(1.10, 0.65, 1.23, 0.89, 0.71),
    conf.high  = c(1.91, 1.18, 2.26, 1.67, 1.28),
    p.value    = c(0.008, 0.387, 0.001, 0.213, 0.752)
  )

  fp <- plot_forest(df)
  expect_s3_class(fp, "forestplot")
  expect_true(inherits(fp, "gTree"))
})

test_that("plot_forest handles significant rows with bold formatting", {
  df <- tibble::tibble(
    variable   = c("Factor A", "Factor B"),
    estimate   = c(1.2, 0.8),
    conf.low   = c(1.1, 0.6),
    conf.high  = c(1.4, 1.1),
    p.value    = c(0.01, 0.10)  # Only A is significant
  )

  fp <- plot_forest(df, sig_level = 0.05, bold_sig = TRUE)
  expect_s3_class(fp, "forestplot")
})

test_that("plot_forest throws error when required columns are missing", {
  bad_df <- tibble::tibble(
    variable = c("A", "B"),
    estimate = c(1.2, 0.8),
    conf.low = c(1.0, 0.5)
    # Missing conf.high and p.value
  )

  expect_error(plot_forest(bad_df), "Missing required columns")
})

test_that("plot_forest handles short boxcolor vectors by recycling", {
  df <- tibble::tibble(
    variable   = LETTERS[1:10],
    estimate   = runif(10, 0.5, 2),
    conf.low   = runif(10, 0.3, 1.5),
    conf.high  = runif(10, 1.6, 3),
    p.value    = runif(10)
  )

  fp <- plot_forest(df, boxcolor = c("#E64B35", "#4DBBD5"))
  expect_s3_class(fp, "forestplot")
})

test_that("plot_forest aligns columns correctly", {
  df <- tibble::tibble(
    variable   = c("X", "Y"),
    estimate   = c(1.0, 1.5),
    conf.low   = c(0.8, 1.2),
    conf.high  = c(1.2, 1.8),
    p.value    = c(0.04, 0.10)
  )

  fp <- plot_forest(
    df,
    align_left = 1,
    align_center = 2,
    align_right = 4
  )
  expect_s3_class(fp, "forestplot")
})

test_that("plot_forest handles improper arrow labels gracefully", {
  df <- tibble::tibble(
    variable   = c("Treat", "Control"),
    estimate   = c(1.1, 0.9),
    conf.low   = c(0.9, 0.7),
    conf.high  = c(1.3, 1.1),
    p.value    = c(0.03, 0.25)
  )

  fp <- plot_forest(df, arrow_lab = "Not enough")
  expect_s3_class(fp, "forestplot")
})

