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

test_that("%p% recycles length-1 argument over longer vector", {
  expect_equal("prefix" %p% c("a", "b", "c"), c("prefix a", "prefix b", "prefix c"))
  expect_equal(c("a", "b") %p% "suffix",      c("a suffix", "b suffix"))
})

test_that("%p% rejects incompatible vector lengths", {
  expect_error(
    c("a", "b", "c") %p% c("x", "y"),
    "equal lengths, or one side must have length 1"
  )
})

test_that("%p% preserves empty string (space is always inserted)", {
  expect_equal("" %p% "world", " world")
  expect_equal("hello" %p% "", "hello ")
})

test_that("%p% rejects NA values and non-character inputs", {
  expect_error("Hello" %p% NA,   "non-empty character vector")
  expect_error(NA %p% "world",   "non-empty character vector")
  expect_error(123 %p% "world",  "non-empty character vector")
  expect_error("hello" %p% TRUE, "non-empty character vector")
  expect_error(NULL %p% "world", "non-empty character vector")
})

#==============================================================================
# %nin%
#==============================================================================

test_that("%nin% returns correct logical vector", {
  expect_equal(c("A", "B", "C") %nin% c("B", "D"), c(TRUE, FALSE, TRUE))
  expect_equal(1:5 %nin% c(2, 4), c(TRUE, FALSE, TRUE, FALSE, TRUE))
})

test_that("%nin% returns all FALSE when every element is in table", {
  expect_equal(c("a", "b") %nin% c("a", "b", "c"), c(FALSE, FALSE))
})

test_that("%nin% returns all TRUE when no element is in table", {
  expect_equal(c("x", "y") %nin% c("a", "b"), c(TRUE, TRUE))
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

test_that("%nin% follows base R type coercion — character matches numeric by value", {
  # R coerces types in %in%: "1" matches 1, so %nin% returns FALSE
  expect_equal(c("1", "2") %nin% c(1, 2), c(FALSE, FALSE))
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
  expect_warning(
    out <- c("x") %match% c("X", "x", "X"),
    "duplicated value"
  )
  expect_equal(out, 1L)
})

test_that("%match% handles duplicate x elements", {
  expect_equal(c("tp53", "tp53") %match% c("TP53", "EGFR"), c(1L, 1L))
})

test_that("%match% rejects empty x", {
  expect_error(character(0) %match% c("a", "b"), "non-empty character vector")
})

test_that("%match% rejects empty table", {
  expect_error(c("a") %match% character(0), "non-empty character vector")
})

test_that("%match% rejects NA values and non-character inputs", {
  expect_error(c("tp53", NA) %match% c("TP53"),  "non-empty character vector")
  expect_error(c("tp53") %match% c("TP53", NA),  "non-empty character vector")
  expect_error(1:3 %match% c("a", "b"),          "non-empty character vector")
  expect_error(c("a", "b") %match% c(1, 2),      "non-empty character vector")
  expect_error(NULL %match% c("a"),              "non-empty character vector")
})

test_that("%match% rejects empty strings", {
  expect_error(c("tp53", "") %match% c("TP53"), "NA or empty string")
  expect_error(c("tp53") %match% c("TP53", ""), "NA or empty string")
})

#==============================================================================
# %map%
#==============================================================================

test_that("%map% returns named vector with canonical table names", {
  result <- c("tp53", "brca1", "egfr") %map% c("TP53", "EGFR", "MYC")
  expect_equal(result, c(TP53 = "tp53", EGFR = "egfr"))
})

test_that("%map% output order follows x, not table", {
  result <- c("egfr", "tp53") %map% c("TP53", "EGFR")
  expect_equal(result, c(EGFR = "egfr", TP53 = "tp53"))
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

test_that("%map% preserves duplicate x elements that match", {
  result <- c("tp53", "tp53") %map% c("TP53", "EGFR")
  expect_equal(result, c(TP53 = "tp53", TP53 = "tp53"))
})

test_that("%map% warns and uses first match when normalized table values duplicate", {
  expect_warning(
    result <- c("tp53") %map% c("TP53", "tp53"),
    "duplicated value"
  )
  expect_equal(result, c(TP53 = "tp53"))
})

test_that("%map% rejects empty x", {
  expect_error(character(0) %map% c("TP53"), "non-empty character vector")
})

test_that("%map% rejects empty table", {
  expect_error(c("tp53") %map% character(0), "non-empty character vector")
})

test_that("%map% rejects NA values and non-character inputs", {
  expect_error(c("tp53", NA) %map% c("TP53"),  "non-empty character vector")
  expect_error(c("tp53") %map% c("TP53", NA),  "non-empty character vector")
  expect_error(1:3 %map% c("a", "b"),          "non-empty character vector")
  expect_error(c("a", "b") %map% c(1, 2),      "non-empty character vector")
  expect_error(NULL %map% c("a"),              "non-empty character vector")
})

test_that("%map% rejects empty strings", {
  expect_error(c("tp53", "") %map% c("TP53"), "NA or empty string")
  expect_error(c("tp53") %map% c("TP53", ""), "NA or empty string")
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
