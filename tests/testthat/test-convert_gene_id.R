# =============================================================================
# Test: convert_gene_id()
# File: test-convert_gene_id.R
# Description: Unit tests for convert_gene_id() function
# =============================================================================

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
test_that("convert_gene_id() works on vector input (human)", {
  # Create a small test reference table
  ref <- data.frame(
    symbol = c("TP53", "BRCA1", "NOTAREAL"),
    ensembl_id = c("ENSG00000141510", "ENSG00000012048", NA),
    entrez_id = c("7157", "672", NA),
    stringsAsFactors = FALSE
  )
  res <- convert_gene_id(
    query = c("tp53", "brca1", "notareal"),
    from = "symbol", to = "ensembl_id", species = "human",
    ref_table = ref, preview = FALSE
  )
  expect_s3_class(res, "data.frame")
  expect_true("ensembl_id" %in% colnames(res))
  expect_equal(res$symbol[1], "TP53")
})

test_that("convert_gene_id() works on data.frame input (human)", {
  # Create a small test reference table
  ref <- data.frame(
    symbol = c("TP53", "BRCA1", "NOTAREAL"),
    ensembl_id = c("ENSG00000141510", "ENSG00000012048", NA),
    entrez_id = c("7157", "672", NA),
    stringsAsFactors = FALSE
  )
  df <- data.frame(symbol = c("tp53", "brca1", "notareal"))
  res <- convert_gene_id(
    df, from = "symbol", to = "ensembl_id",
    species = "human", query_col = "symbol",
    ref_table = ref, preview = FALSE
  )
  expect_true("symbol_upper" %in% colnames(res))
  expect_true("ensembl_id" %in% colnames(res))
})

test_that("convert_gene_id() works for mouse (lowercase)", {
  # Create a small test reference table
  ref <- data.frame(
    symbol = c("Trp53", "Cdkn1a", "FakeGene"),
    ensembl_id = c("ENSMUSG00000059552", "ENSMUSG00000023071", NA),
    entrez_id = c("22059", "12575", NA),
    stringsAsFactors = FALSE
  )
  df <- data.frame(symbol = c("Trp53", "Cdkn1a", "FakeGene"))
  res <- convert_gene_id(
    df, from = "symbol", to = "ensembl_id",
    species = "mouse", query_col = "symbol",
    ref_table = ref, preview = FALSE
  )
  expect_true("symbol_lower" %in% colnames(res))
  expect_true("ensembl_id" %in% colnames(res))
})

test_that("convert_gene_id() supports multiple target columns", {
  # Create a small test reference table
  ref <- data.frame(
    symbol = c("TP53", "BRCA1"),
    ensembl_id = c("ENSG00000141510", "ENSG00000012048"),
    entrez_id = c("7157", "672"),
    stringsAsFactors = FALSE
  )
  res <- convert_gene_id(
    c("TP53", "BRCA1"), from = "symbol",
    to = c("ensembl_id", "entrez_id"),
    species = "human", ref_table = ref, preview = FALSE
  )
  expect_true(all(c("ensembl_id", "entrez_id") %in% colnames(res)))
})

# ------------------------------------------------------------------------------
# Error handling tests
# ------------------------------------------------------------------------------
test_that("convert_gene_id() keeps NA when requested", {
  # Create a small test reference table
  ref <- data.frame(
    symbol = c("TP53", "NOTAGENE"),
    ensembl_id = c("ENSG00000141510", NA),
    entrez_id = c("7157", NA),
    stringsAsFactors = FALSE
  )
  res <- convert_gene_id(
    c("TP53", "NOTAGENE"), from = "symbol", to = "ensembl_id",
    species = "human", ref_table = ref, keep_na = TRUE, preview = FALSE
  )
  expect_equal(nrow(res), 2)
})

test_that("convert_gene_id() errors if query_col missing", {
  # Create a small test reference table
  ref <- data.frame(
    symbol = c("TP53", "BRCA1"),
    ensembl_id = c("ENSG00000141510", "ENSG00000012048"),
    entrez_id = c("7157", "672"),
    stringsAsFactors = FALSE
  )
  df <- data.frame(not_symbol = c("TP53", "BRCA1"))
  expect_error(
    convert_gene_id(df, from = "symbol", to = "ensembl_id",
                    species = "human", query_col = "symbol",
                    ref_table = ref, preview = FALSE),
    "must specify a valid"
  )
})

