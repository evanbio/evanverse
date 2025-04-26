# tests/testthat/test-safe_execute.R
#-------------------------------------------------------------------------------
# Tests for safe_execute()
#-------------------------------------------------------------------------------

test_that("safe_execute returns result when successful", {
  result <- safe_execute(log(1))
  expect_equal(result, 0)
})

test_that("safe_execute returns NULL when error occurs", {
  result <- safe_execute(log("a"))
  expect_null(result)
})

test_that("safe_execute prints warning when error occurs", {
  expect_message(
    safe_execute(log("a"), fail_message = "Custom failure message"),
    regexp = "Custom failure message"
  )
})

test_that("safe_execute is silent when quiet = TRUE", {
  expect_silent(
    safe_execute(log("a"), fail_message = "Should not print", quiet = TRUE)
  )
})
