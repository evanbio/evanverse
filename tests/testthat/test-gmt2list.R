# 📄 Tests for gmt2list()
# File: tests/testthat/test-gmt2list.R

test_that("gmt2list parses valid GMT file correctly", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")  # 替换为你的包名

  gene_sets <- gmt2list(gmt_file, verbose = FALSE)

  expect_type(gene_sets, "list")
  expect_true(length(gene_sets) > 10)
  expect_true(all(names(gene_sets) != ""))  # All elements should be named
  expect_type(gene_sets[[1]], "character")
  expect_gt(length(gene_sets[[1]]), 1)
})

test_that("gmt2list throws error when file is missing", {
  expect_error(
    gmt2list("nonexistent_file.gmt"),
    regexp = "GMT file not found"
  )
})
