#===============================================================================
# Test: view()
# File: tests/testthat/test-view.R
# Description: Unit tests for the interactive table viewer `view()`
# Dependencies: testthat, reactable, tibble
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------
test_that("view() renders without error on valid input and returns a widget", {
  skip_if_not_installed("reactable")
  test_data <- mtcars

  expect_silent({
    result <- evanverse::view(test_data, page_size = 10)
    expect_s3_class(result, "reactable")
  })
})

test_that("view() handles tibble input", {
  skip_if_not_installed("reactable")
  skip_if_not_installed("tibble")

  test_data <- tibble::tibble(x = 1:5, y = letters[1:5])

  expect_silent({
    result <- evanverse::view(test_data, page_size = 5)
    expect_s3_class(result, "reactable")
  })
})

#------------------------------------------------------------------------------
# Parameter variants
#------------------------------------------------------------------------------
test_that("view() accepts common option combinations", {
  skip_if_not_installed("reactable")
  df <- head(iris, 20)

  expect_silent(evanverse::view(df, page_size = 5, searchable = TRUE,  filterable = TRUE))
  expect_silent(evanverse::view(df, page_size = 7, striped    = FALSE, highlight  = TRUE))
  expect_silent(evanverse::view(df, page_size = 10, compact   = TRUE))
})

#------------------------------------------------------------------------------
# Error & edge handling
#------------------------------------------------------------------------------
test_that("view() errors when input is not a data.frame/tibble", {
  skip_if_not_installed("reactable")
  invalid_input <- list(a = 1, b = 2)

  expect_error(
    evanverse::view(invalid_input),
    regexp = "data\\.frame or tibble"
  )
})
