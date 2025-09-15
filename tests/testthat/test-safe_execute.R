#===============================================================================
# Test: safe_execute()
# File: tests/testthat/test-safe_execute.R
# Description: Unit tests for safe_execute()
# Dependencies: testthat, cli
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------
test_that("safe_execute returns result when successful", {
  result <- safe_execute(log(1))
  expect_equal(result, 0)
})

test_that("safe_execute returns NULL when error occurs", {
  result <- safe_execute(log("a"))
  expect_null(result)
})

#------------------------------------------------------------------------------
# CLI messaging
#------------------------------------------------------------------------------
test_that("safe_execute emits CLI message on error", {
  skip_if_not_installed("cli")
  expect_message(
    safe_execute(log("a"), fail_message = "Custom failure message"),
    regexp = "Custom failure message"
  )
})

test_that("safe_execute is silent when quiet = TRUE", {
  skip_if_not_installed("cli")
  expect_silent(
    safe_execute(log("a"), fail_message = "Should not print", quiet = TRUE)
  )
})
