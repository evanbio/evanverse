#===============================================================================
# Test: ops.R public functions
# File: test-ops.R
# Description: Unit tests for %p%, %nin%, %match%, %map%, %is%
#===============================================================================

#==============================================================================
# %p%
#==============================================================================

test_that("%p% concatenates two strings with a space", {
  expect_equal("Hello" %p% "world", "Hello world")
  expect_equal("Good" %p% "job",    "Good job")
})

test_that("%p% is vectorised", {
  result <- c("hello", "good") %p% c("world", "morning")
  expect_equal(result, c("hello world", "good morning"))
})

test_that("%p% rejects non-character inputs", {
  expect_error(123 %p% "world",   "non-empty character vector")
  expect_error("hello" %p% TRUE,  "non-empty character vector")
  expect_error(NULL %p% "world",  "non-empty character vector")
})

#==============================================================================
# %nin%
#==============================================================================

test_that("%nin% returns correct logical vector", {
  expect_equal(c("A", "B", "C") %nin% c("B", "D"), c(TRUE, FALSE, TRUE))
  expect_equal(1:5 %nin% c(2, 4), c(TRUE, FALSE, TRUE, FALSE, TRUE))
})

test_that("%nin% handles NA following base R semantics", {
  expect_equal(NA %nin% c(NA, 1), FALSE)   # NA is in table -> FALSE
  expect_equal(NA %nin% c(1, 2),  TRUE)    # NA %in% c(1,2) is FALSE -> !FALSE = TRUE
})

test_that("%nin% works with empty table", {
  expect_equal(c("a", "b") %nin% character(0), c(TRUE, TRUE))
})

test_that("%nin% works with empty x", {
  expect_equal(character(0) %nin% c("a", "b"), logical(0))
})

#==============================================================================
# %match%
#==============================================================================

test_that("%match% returns correct indices case-insensitively", {
  result <- c("tp53", "BRCA1", "egfr") %match% c("TP53", "EGFR", "MYC")
  expect_equal(result, c(1L, NA, 2L))
})

test_that("%match% returns NA for all non-matches", {
  result <- c("aaa", "bbb") %match% c("xxx", "yyy")
  expect_equal(result, c(NA_integer_, NA_integer_))
})

test_that("%match% returns first match index when duplicates in table", {
  expect_equal(c("x") %match% c("X", "x", "X"), 1L)
})

test_that("%match% rejects empty character vector", {
  expect_error(character(0) %match% c("a", "b"), "non-empty character vector")
})

test_that("%match% rejects non-character inputs", {
  expect_error(1:3 %match% c("a", "b"),         "non-empty character vector")
  expect_error(c("a", "b") %match% c(1, 2),     "non-empty character vector")
  expect_error(NULL %match% c("a"),              "non-empty character vector")
})

#==============================================================================
# %map%
#==============================================================================

test_that("%map% returns named vector with canonical table names", {
  result <- c("tp53", "brca1", "egfr") %map% c("TP53", "EGFR", "MYC")
  expect_equal(result, c(TP53 = "tp53", EGFR = "egfr"))
})

test_that("%map% drops unmatched values", {
  result <- c("akt1", "tp53") %map% c("TP53", "EGFR")
  expect_equal(result, c(TP53 = "tp53"))
})

test_that("%map% returns empty named vector when no matches", {
  result <- c("none1", "none2") %map% c("TP53", "EGFR")
  expect_length(result, 0L)
  expect_type(result, "character")
})

test_that("%map% rejects non-character inputs", {
  expect_error(1:3 %map% c("a", "b"),        "non-empty character vector")
  expect_error(c("a", "b") %map% c(1, 2),    "non-empty character vector")
  expect_error(NULL %map% c("a"),             "non-empty character vector")
})

#==============================================================================
# %is%
#==============================================================================

test_that("%is% returns TRUE for identical objects", {
  expect_true(1:3 %is% 1:3)
  expect_true("hello" %is% "hello")
  expect_true(list(a = 1) %is% list(a = 1))
})

test_that("%is% returns FALSE for type mismatch", {
  expect_false(1:3 %is% c(1, 2, 3))   # integer vs double
})

test_that("%is% returns FALSE for different values", {
  expect_false(1:3 %is% 1:4)
  expect_false(c("a", "b") %is% c("a", "c"))
})

test_that("%is% returns FALSE for different names", {
  expect_false(c(a = 1, b = 2) %is% c(b = 1, a = 2))
})

test_that("%is% works with NULL and NA", {
  expect_true(NULL %is% NULL)
  expect_true(NA %is% NA)
  expect_false(NA %is% NA_real_)
})

#===============================================================================
# End: test-ops.R
#===============================================================================
