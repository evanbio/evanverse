#===============================================================================
# Test: remind()
# File: tests/testthat/test-remind.R
# Description: Keyword-based usage reminder
# Dependencies: testthat, cli
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------
test_that("returns matched keywords (exact)", {
  res <- expect_invisible(remind("glimpse"))
  expect_type(res, "character")
  expect_true("glimpse" %in% res)
})

test_that("supports partial matching for keywords", {
  res <- expect_invisible(remind("glim"))
  expect_true("glimpse" %in% res)

  res2 <- expect_invisible(remind("excel"))
  expect_true("read_excel" %in% res2)
})

test_that("is case-insensitive", {
  res <- expect_invisible(remind("Glim"))
  expect_true("glimpse" %in% res)
})

#------------------------------------------------------------------------------
# NULL keyword shows all entries
#------------------------------------------------------------------------------
test_that("NULL keyword returns full keyword list (invisibly)", {
  res <- expect_invisible(remind())
  expect_type(res, "character")
  expect_true(all(c("glimpse", "read_excel") %in% res))
  expect_gt(length(res), 10)
})

#------------------------------------------------------------------------------
# Unmatched keyword
#------------------------------------------------------------------------------
test_that("unmatched keyword returns empty character vector", {
  res <- expect_invisible(remind("notakeyword"))
  expect_type(res, "character")
  expect_length(res, 0)
})

#------------------------------------------------------------------------------
# Multiple matches
#------------------------------------------------------------------------------
test_that("pattern can return multiple matches", {
  res <- expect_invisible(remind("rank"))
  # e.g., min_rank, dense_rank, percent_rank are possible matches
  expect_true(any(grepl("^.*rank$", res)))
  expect_gte(length(res), 2)
})
