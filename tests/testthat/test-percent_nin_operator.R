#===============================================================================
# 🔁 Test: %nin%
# 📁 File: test-percent_nin_operator.R
# 🔍 Description: Tests for the `%nin%` binary operator (Negate %in%)
#===============================================================================

test_that("%nin% works as logical negation of %in%", {
  x <- c("A", "B", "C")
  table <- c("B", "D")

  expect_equal(x %nin% table, !(x %in% table))
  expect_equal(1:5 %nin% c(2, 4), c(TRUE, FALSE, TRUE, FALSE, TRUE))
})

test_that("%nin% handles empty input gracefully", {
  expect_equal(character(0) %nin% letters, logical(0))
  expect_equal(1:3 %nin% numeric(0), rep(TRUE, 3))
})

test_that("%nin% behaves correctly with NA values", {
  x <- c("A", NA, "B")
  table <- c("B", "C")

  result <- x %nin% table
  expect_equal(result, c(TRUE, TRUE, FALSE))  # consistent with base behavior
})
