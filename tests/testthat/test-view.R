# tests/testthat/test-view.R
#-------------------------------------------------------------------------------
# 🧪 Test: view()
#-------------------------------------------------------------------------------

test_that("view() renders without error on valid input", {
  test_data <- mtcars

  expect_silent({
    result <- evanverse::view(test_data, page_size = 10)
  })
})

test_that("view() throws error when input is not a data.frame", {
  invalid_input <- list(a = 1, b = 2)

  expect_error(
    evanverse::view(invalid_input),
    regexp = "Input must be a data.frame or tibble."
  )
})

test_that("view() handles tibble input correctly", {
  library(tibble)
  test_data <- tibble(x = 1:5, y = letters[1:5])

  expect_silent({
    result <- evanverse::view(test_data, page_size = 5)
  })
})



