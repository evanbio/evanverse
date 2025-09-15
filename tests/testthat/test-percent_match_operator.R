#===============================================================================
# Test: %map%
# File: test-percent_map_operator.R
# Description: Unit tests for the case-insensitive %map% operator
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------
test_that("%map% performs case-insensitive mapping correctly", {
  x <- c("tp53", "BRCA1", "egfr")
  tbl <- c("TP53", "EGFR", "MYC")
  result <- x %map% tbl
  expect_named(result, c("TP53", "EGFR"))
  expect_equal(unname(result), c("tp53", "egfr"))
})

test_that("%map% drops unmatched values", {
  x <- c("akt1", "tp53")
  tbl <- c("TP53", "EGFR")
  result <- x %map% tbl
  expect_named(result, "TP53")
  expect_equal(unname(result), "tp53")
})

#------------------------------------------------------------------------------
# Edge cases
#------------------------------------------------------------------------------
test_that("%map% returns empty when no values match", {
  x <- c("aaa", "bbb")
  tbl <- c("xxx", "yyy")
  result <- x %map% tbl
  expect_length(result, 0)
  expect_named(result, character(0))
})

test_that("%map% handles empty input gracefully", {
  r1 <- character(0) %map% c("a", "b")
  expect_true(is.character(r1))
  expect_length(r1, 0)
  expect_named(r1, character(0))

  r2 <- c("a", "b") %map% character(0)
  expect_true(is.character(r2))
  expect_length(r2, 0)
  expect_named(r2, character(0))
})

#------------------------------------------------------------------------------
# Error handling
#------------------------------------------------------------------------------
test_that("%map% throws error on invalid inputs", {
  expect_error(1:3 %map% c("a", "b"), "must be a character vector")
  expect_error(c("a", "b") %map% 1:3, "must be a character vector")
})
