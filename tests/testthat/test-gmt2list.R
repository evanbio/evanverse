#===============================================================================
# Test: gmt2list()
# File: test-gmt2list.R
# Description: Unit tests for the gmt2list() utility function
#===============================================================================

#------------------------------------------------------------------------------
# Basic Functionality
#------------------------------------------------------------------------------

test_that("gmt2list() parses valid GMT file correctly", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
  skip_if_not(file.exists(gmt_file), "GMT test file not found")

  result <- gmt2list(gmt_file, verbose = FALSE)

  expect_type(result, "list")
  expect_gt(length(result), 0)
  expect_true(all(names(result) != ""))
  expect_true(all(!is.na(names(result))))
})

test_that("gmt2list() returns correct data structure", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
  skip_if_not(file.exists(gmt_file), "GMT test file not found")

  result <- gmt2list(gmt_file, verbose = FALSE)

  # Check that each gene set is a character vector
  expect_true(all(vapply(result, is.character, logical(1))))
  
  # Check that each gene set has at least one gene
  gene_set_lengths <- vapply(result, length, integer(1))
  expect_true(all(gene_set_lengths > 0))
  
  # Check that gene names are not empty
  all_genes <- unlist(result, use.names = FALSE)
  expect_true(all(!is.na(all_genes)))
  expect_true(all(all_genes != ""))
})

test_that("gmt2list() handles verbose parameter correctly", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
  skip_if_not(file.exists(gmt_file), "GMT test file not found")

  # Test verbose = FALSE (should not produce output)
  expect_silent(gmt2list(gmt_file, verbose = FALSE))
  
  # Test verbose = TRUE (should produce message)
  expect_message(gmt2list(gmt_file, verbose = TRUE), "Parsed .* gene sets")
})

#------------------------------------------------------------------------------
# Parameter Validation
#------------------------------------------------------------------------------

test_that("gmt2list() validates file parameter correctly", {
  expect_error(gmt2list(123), "'file' must be a single non-empty character string")
  expect_error(gmt2list(c("file1.gmt", "file2.gmt")), "'file' must be a single non-empty character string")
  expect_error(gmt2list(""), "'file' must be a single non-empty character string")
  expect_error(gmt2list(NA_character_), "'file' must be a single non-empty character string")
})

test_that("gmt2list() validates verbose parameter correctly", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
  skip_if_not(file.exists(gmt_file), "GMT test file not found")

  expect_error(gmt2list(gmt_file, verbose = "yes"), "'verbose' must be a single logical value")
  expect_error(gmt2list(gmt_file, verbose = c(TRUE, FALSE)), "'verbose' must be a single logical value")
  expect_error(gmt2list(gmt_file, verbose = NA), "'verbose' must be a single logical value")
  expect_error(gmt2list(gmt_file, verbose = 1), "'verbose' must be a single logical value")
})

#------------------------------------------------------------------------------
# Error Handling and Edge Cases
#------------------------------------------------------------------------------

test_that("gmt2list() handles nonexistent file", {
  expect_error(gmt2list("nonexistent_file.gmt"), "GMT file not found")
  expect_error(gmt2list("/path/to/nowhere.gmt"), "GMT file not found")
})

test_that("gmt2list() handles invalid GMT file format", {
  # Create a temporary invalid file
  temp_file <- tempfile(fileext = ".gmt")
  writeLines("invalid content", temp_file)
  
  expect_error(gmt2list(temp_file), "Failed to parse GMT file")
  
  unlink(temp_file)
})

test_that("gmt2list() handles empty GMT file", {
  skip_if_not(requireNamespace("GSEABase", quietly = TRUE), "GSEABase not available")
  
  # Create a temporary empty file
  temp_file <- tempfile(fileext = ".gmt")
  file.create(temp_file)
  
  expect_error(gmt2list(temp_file), "GMT file contains no gene sets|Failed to parse GMT file")
  
  unlink(temp_file)
})

test_that("gmt2list() produces consistent results with gmt2df()", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
  skip_if_not(file.exists(gmt_file), "GMT test file not found")

  # Compare results from both functions
  list_result <- gmt2list(gmt_file, verbose = FALSE)
  df_result <- gmt2df(gmt_file, verbose = FALSE)
  
  # Should have same number of unique gene sets
  expect_equal(length(list_result), length(unique(df_result$term)))
  
  # Gene set names should match
  expect_setequal(names(list_result), unique(df_result$term))
})

#===============================================================================
# End: test-gmt2list.R
#===============================================================================
