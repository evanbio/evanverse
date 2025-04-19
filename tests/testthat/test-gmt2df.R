# 📄 Tests for gmt2df()
# File: tests/testthat/test-gmt2df.R

test_that("gmt2df parses valid GMT file correctly", {
  gmt_file <- system.file("extdata", "h.all.v2024.1.Hs.symbols.gmt", package = "evanverse")

  df <- gmt2df(gmt_file, verbose = FALSE)

  expect_s3_class(df, "tbl_df")
  expect_true(all(c("term", "description", "gene") %in% colnames(df)))
  expect_gt(nrow(df), 1000)
  expect_type(df$term, "character")
  expect_type(df$gene, "character")
})

test_that("gmt2df throws error if file does not exist", {
  fake_path <- "nonexistent_file.gmt"
  expect_error(gmt2df(fake_path), "GMT file not found")
})
