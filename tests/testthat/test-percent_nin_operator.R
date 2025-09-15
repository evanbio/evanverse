#===============================================================================
# Test: %nin%
# File: test-percent_nin_operator.R
# Description: Tests for the `%nin%` binary operator (Negate %in%)
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------
test_that("%nin% works as logical negation of %in%", {
  x <- c("A", "B", "C")
  table <- c("B", "D")

  res_in  <- x %in% table
  res_nin <- x %nin% table

  expect_type(res_nin, "logical")
  expect_length(res_nin, length(x))
  expect_equal(res_nin, !res_in)
  expect_equal(1:5 %nin% c(2, 4), c(TRUE, FALSE, TRUE, FALSE, TRUE))
})

#------------------------------------------------------------------------------
# Edge cases
#------------------------------------------------------------------------------
test_that("%nin% handles empty input gracefully", {
  expect_equal(character(0) %nin% letters, logical(0))  # empty x
  expect_equal(1:3 %nin% numeric(0), rep(TRUE, 3))      # empty table -> all TRUE
})

#------------------------------------------------------------------------------
# NA semantics (base R consistent)
#------------------------------------------------------------------------------
test_that("%nin% behaves correctly with NA in x (table has no NA)", {
  x <- c("A", NA, "B")
  table <- c("B", "C")
  # x %in% table -> c(FALSE, NA, TRUE); negation -> c(TRUE, NA, FALSE)
  expect_equal(x %nin% table, c(TRUE, TRUE, FALSE))
})

test_that("%nin% behaves correctly when table contains NA", {
  x <- c(NA, "A", "B")
  table <- c(NA, "B")
  # x %in% table -> c(TRUE, FALSE, TRUE); negation -> c(FALSE, TRUE, FALSE)
  expect_equal(x %nin% table, c(FALSE, TRUE, FALSE))
})
