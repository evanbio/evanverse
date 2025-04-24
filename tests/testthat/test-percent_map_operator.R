#===============================================================================
# 🧪 Test: %map%
# 📁 File: test-percent_map_operator.R
# 🔍 Description: Unit tests for the %map% operator (case-insensitive matching)
#===============================================================================

test_that("%map% returns named vector with matched entries only", {
  x <- c("tp53", "brca1", "egfr", "abc")
  tbl <- c("TP53", "EGFR", "MYC")

  result <- x %map% tbl

  expect_type(result, "character")
  expect_named(result)
  expect_equal(names(result), c("TP53", "EGFR"))
  expect_equal(unname(result), c("tp53", "egfr"))
})

test_that("%map% removes unmatched entries named as 'unknown'", {
  x <- c("MYC", "NOTFOUND")
  tbl <- c("MYC", "TP53")

  result <- x %map% tbl

  expect_equal(names(result), "MYC")
  expect_equal(unname(result), "MYC")
  expect_false("unknown" %in% names(result))
})
