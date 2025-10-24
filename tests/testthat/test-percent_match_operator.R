#===============================================================================
# Test: %match%
# File: test-percent_match_operator.R
# Description: Unit tests for the case-insensitive %match% operator
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------
test_that("%match% returns correct indices for case-insensitive matching", {
  x <- c("tp53", "BRCA1", "egfr")
  tbl <- c("TP53", "EGFR", "MYC")
  result <- x %match% tbl

  # Should return integer vector
  expect_type(result, "integer")
  expect_length(result, 3)

  # tp53 matches TP53 (position 1), BRCA1 has no match (NA), egfr matches EGFR (position 2)
  expect_equal(result, c(1L, NA_integer_, 2L))
})

test_that("%match% is case-insensitive", {
  # Different case combinations should match
  expect_equal("abc" %match% c("ABC"), 1L)
  expect_equal("ABC" %match% c("abc"), 1L)
  expect_equal("AbC" %match% c("aBc"), 1L)

  # Vector test
  x <- c("tp53", "TP53", "Tp53")
  tbl <- c("TP53")
  expect_equal(x %match% tbl, c(1L, 1L, 1L))
})

test_that("%match% returns NA for non-matches", {
  x <- c("aaa", "bbb", "ccc")
  tbl <- c("xxx", "yyy")
  result <- x %match% tbl

  expect_type(result, "integer")
  expect_length(result, 3)
  expect_true(all(is.na(result)))
})

test_that("%match% behaves like base::match() for order", {
  # First match is returned (like base::match)
  x <- c("x")
  tbl <- c("X", "x", "X")  # case-insensitive, so all match
  result <- x %match% tbl

  expect_equal(result, 1L)  # Returns first match
})

test_that("%match% handles partial matches correctly", {
  x <- c("gene1", "gene2", "gene3")
  tbl <- c("GENE1", "GENE3")
  result <- x %match% tbl

  expect_equal(result, c(1L, NA_integer_, 2L))
})

#------------------------------------------------------------------------------
# Edge cases
#------------------------------------------------------------------------------
test_that("%match% handles empty input gracefully", {
  # Empty x
  r1 <- character(0) %match% c("a", "b")
  expect_type(r1, "integer")
  expect_length(r1, 0)

  # Empty table
  r2 <- c("a", "b") %match% character(0)
  expect_type(r2, "integer")
  expect_length(r2, 2)
  expect_true(all(is.na(r2)))

  # Both empty
  r3 <- character(0) %match% character(0)
  expect_type(r3, "integer")
  expect_length(r3, 0)
})

test_that("%match% handles duplicate values", {
  # Duplicates in x
  x <- c("a", "a", "b")
  tbl <- c("A", "B")
  result <- x %match% tbl
  expect_equal(result, c(1L, 1L, 2L))

  # Duplicates in table (returns first match)
  x2 <- c("a")
  tbl2 <- c("A", "a", "A")
  result2 <- x2 %match% tbl2
  expect_equal(result2, 1L)
})

test_that("%match% handles single-element vectors", {
  # Single element in x
  expect_equal("test" %match% c("TEST", "OTHER"), 1L)

  # Single element in table
  expect_equal(c("test", "other") %match% "TEST", c(1L, NA_integer_))

  # Both single element
  expect_equal("test" %match% "TEST", 1L)
  expect_equal("test" %match% "OTHER", NA_integer_)
})

test_that("%match% handles special characters", {
  x <- c("gene-1", "gene_2", "gene.3")
  tbl <- c("GENE-1", "GENE_2", "GENE.3")
  result <- x %match% tbl

  expect_equal(result, c(1L, 2L, 3L))
})

test_that("%match% handles whitespace", {
  # Whitespace is NOT trimmed (exact match including whitespace)
  x <- c("test", " test", "test ")
  tbl <- c("TEST")
  result <- x %match% tbl

  expect_equal(result, c(1L, NA_integer_, NA_integer_))
})

test_that("%match% handles NA values", {
  # NA in x
  x <- c("a", NA, "b")
  tbl <- c("A", "B")
  result <- x %match% tbl
  expect_equal(result[1], 1L)
  expect_true(is.na(result[2]))  # NA matches to NA
  expect_equal(result[3], 2L)

  # NA in table
  x2 <- c("a", "b")
  tbl2 <- c(NA, "A", "B")
  result2 <- x2 %match% tbl2
  expect_equal(result2, c(2L, 3L))  # a matches A (position 2), b matches B (position 3)
})

#------------------------------------------------------------------------------
# Error handling
#------------------------------------------------------------------------------
test_that("%match% throws error on invalid inputs", {
  # Non-character x
  expect_error(
    1:3 %match% c("a", "b"),
    "must be a character vector"
  )

  # Non-character table
  expect_error(
    c("a", "b") %match% 1:3,
    "must be a character vector"
  )

  # Numeric vectors
  expect_error(
    c(1, 2, 3) %match% c(1, 2),
    "must be a character vector"
  )

  # Logical vectors
  expect_error(
    c(TRUE, FALSE) %match% c("TRUE", "FALSE"),
    "must be a character vector"
  )

  # Factor (not character)
  expect_error(
    factor(c("a", "b")) %match% c("A", "B"),
    "must be a character vector"
  )
})

#------------------------------------------------------------------------------
# Real-world use cases
#------------------------------------------------------------------------------
test_that("%match% works for gene symbol matching", {
  # Common use case: matching gene symbols
  query_genes <- c("tp53", "brca1", "egfr", "kras", "pten")
  reference_genes <- c("TP53", "BRCA1", "EGFR", "MYC", "AKT1")

  result <- query_genes %match% reference_genes

  expect_equal(result, c(1L, 2L, 3L, NA_integer_, NA_integer_))

  # Get matched genes
  matched <- query_genes[!is.na(result)]
  expect_equal(matched, c("tp53", "brca1", "egfr"))
})

test_that("%match% allows subsetting like base::match()", {
  # Can use result to subset table
  x <- c("gene1", "gene2", "gene3")
  tbl <- c("GENE2", "GENE1", "GENE4")

  idx <- x %match% tbl
  matched_values <- tbl[idx]

  # gene1 -> position 2 -> GENE1
  # gene2 -> position 1 -> GENE2
  # gene3 -> NA -> NA
  expect_equal(matched_values, c("GENE1", "GENE2", NA_character_))
})

test_that("%match% returns correct type for all scenarios", {
  # Always returns integer, even for edge cases
  expect_type(character(0) %match% character(0), "integer")
  expect_type(c("a") %match% c("A"), "integer")
  expect_type(c("a") %match% character(0), "integer")
  expect_type(c("a", "b") %match% c("X", "Y"), "integer")
})
