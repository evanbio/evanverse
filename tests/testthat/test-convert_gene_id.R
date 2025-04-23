# =============================================================================
# 📦 Test: convert_gene_id()
# =============================================================================

test_that("convert_gene_id() works on vector input (human)", {
  ref <- download_gene_ref("human", TRUE, TRUE)
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
  ref <- download_gene_ref("human", TRUE, TRUE)
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
  ref <- download_gene_ref("mouse", TRUE, TRUE)
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
  ref <- download_gene_ref("human", TRUE, TRUE)
  res <- convert_gene_id(
    c("TP53", "BRCA1"), from = "symbol",
    to = c("ensembl_id", "entrez_id"),
    species = "human", ref_table = ref, preview = FALSE
  )
  expect_true(all(c("ensembl_id", "entrez_id") %in% colnames(res)))
})

test_that("convert_gene_id() keeps NA when requested", {
  ref <- download_gene_ref("human", TRUE, TRUE)
  res <- convert_gene_id(
    c("TP53", "NOTAGENE"), from = "symbol", to = "ensembl_id",
    species = "human", ref_table = ref, keep_na = TRUE, preview = FALSE
  )
  expect_equal(nrow(res), 2)
})

test_that("convert_gene_id() errors if query_col missing", {
  ref <- download_gene_ref("human", TRUE, TRUE)
  df <- data.frame(not_symbol = c("TP53", "BRCA1"))
  expect_error(
    convert_gene_id(df, from = "symbol", to = "ensembl_id",
                    species = "human", query_col = "symbol",
                    ref_table = ref, preview = FALSE),
    "must specify a valid"
  )
})
