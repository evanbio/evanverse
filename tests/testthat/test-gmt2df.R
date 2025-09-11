#===============================================================================
# Test: gmt2df()
# File: test-gmt2df.R
# Description: Unit tests for the gmt2df() utility function
#===============================================================================

#------------------------------------------------------------------------------
# Basic Functionality
#------------------------------------------------------------------------------

test_that("gmt2df() parses valid GMT file correctly", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
  skip_if_not(file.exists(gmt_file), "GMT test file not found")

  result <- gmt2df(gmt_file, verbose = FALSE)

  expect_s3_class(result, "tbl_df")
  expect_named(result, c("term", "description", "gene"))
  expect_gt(nrow(result), 0)
  expect_type(result$term, "character")
  expect_type(result$description, "character")
  expect_type(result$gene, "character")
})

test_that("gmt2df() returns correct data structure", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
  skip_if_not(file.exists(gmt_file), "GMT test file not found")

  result <- gmt2df(gmt_file, verbose = FALSE)

  # Check that each gene set has at least one gene
  expect_true(all(!is.na(result$gene)))
  expect_true(all(result$gene != ""))
  
  # Check that term names are not empty
  expect_true(all(!is.na(result$term)))
  expect_true(all(result$term != ""))
  
  # Check uniqueness of gene-term combinations should equal total rows
  expect_equal(nrow(result), nrow(unique(result[c("term", "gene")])))
})

test_that("gmt2df() handles verbose parameter correctly", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
  skip_if_not(file.exists(gmt_file), "GMT test file not found")

  # Test verbose = FALSE (should not produce output)
  expect_silent(gmt2df(gmt_file, verbose = FALSE))
  
  # Test verbose = TRUE (should produce message)
  expect_message(gmt2df(gmt_file, verbose = TRUE), "Parsed .* rows")
})

#------------------------------------------------------------------------------
# Parameter Validation
#------------------------------------------------------------------------------

test_that("gmt2df() validates file parameter correctly", {
  expect_error(gmt2df(123), "'file' must be a single non-empty character string")
  expect_error(gmt2df(c("file1.gmt", "file2.gmt")), "'file' must be a single non-empty character string")
  expect_error(gmt2df(""), "'file' must be a single non-empty character string")
  expect_error(gmt2df(NA_character_), "'file' must be a single non-empty character string")
})

test_that("gmt2df() validates verbose parameter correctly", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")
  skip_if_not(file.exists(gmt_file), "GMT test file not found")

  expect_error(gmt2df(gmt_file, verbose = "yes"), "'verbose' must be a single logical value")
  expect_error(gmt2df(gmt_file, verbose = c(TRUE, FALSE)), "'verbose' must be a single logical value")
  expect_error(gmt2df(gmt_file, verbose = NA), "'verbose' must be a single logical value")
  expect_error(gmt2df(gmt_file, verbose = 1), "'verbose' must be a single logical value")
})

#------------------------------------------------------------------------------
# Error Handling and Edge Cases
#------------------------------------------------------------------------------

test_that("gmt2df() handles nonexistent file", {
  expect_error(gmt2df("nonexistent_file.gmt"), "GMT file not found")
  expect_error(gmt2df("/path/to/nowhere.gmt"), "GMT file not found")
})

test_that("gmt2df() handles invalid GMT file format", {
  # Create a temporary invalid file
  temp_file <- tempfile(fileext = ".gmt")
  writeLines("invalid content", temp_file)
  
  expect_error(gmt2df(temp_file), "Failed to parse GMT file")
  
  unlink(temp_file)
})

test_that("gmt2df() handles empty GMT file", {
  skip_if_not(requireNamespace("GSEABase", quietly = TRUE), "GSEABase not available")
  
  # Create a temporary empty file
  temp_file <- tempfile(fileext = ".gmt")
  file.create(temp_file)
  
  expect_error(gmt2df(temp_file), "GMT file contains no gene sets|Failed to parse GMT file")
  
  unlink(temp_file)
})

#===============================================================================
# End: test-gmt2df.R
#===============================================================================

