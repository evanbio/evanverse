#===============================================================================
# 🧪 Test: %match%
# 📁 File: test-percent_match_operator.R
# 🔍 Description: Unit tests for the case-insensitive %match% operator
#===============================================================================

test_that("%match% performs case-insensitive match correctly", {
  x <- c("tp53", "BRCA1", "egfr")
  table <- c("TP53", "EGFR", "MYC")
  result <- x %match% table
  expect_equal(result, c(1, NA, 2))
})

test_that("%match% returns NA for all unmatched values", {
  x <- c("aaa", "bbb")
  table <- c("xxx", "yyy")
  result <- x %match% table
  expect_true(all(is.na(result)))
})

test_that("%match% handles empty input gracefully", {
  expect_equal(character(0) %match% c("a", "b"), integer(0))
  expect_equal(c("a", "b") %match% character(0), rep(NA_integer_, 2))
})

test_that("%match% is sensitive to order and returns first match", {
  x <- c("x")
  table <- c("X", "x", "x")
  result <- x %match% table
  expect_equal(result, 1)
})
