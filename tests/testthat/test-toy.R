# =============================================================================
# test-toy.R — Tests for all exported functions in R/toy.R
# =============================================================================


# =============================================================================
# toy_gmt
# =============================================================================

test_that("toy_gmt returns a character path to an existing file", {
  path <- toy_gmt()
  expect_type(path, "character")
  expect_length(path, 1L)
  expect_true(file.exists(path))
})

test_that("toy_gmt default produces a .gmt file extension", {
  path <- toy_gmt()
  expect_true(grepl("\\.gmt$", path))
})

test_that("toy_gmt default n = 5 produces 5 lines", {
  path  <- toy_gmt()
  lines <- readLines(path)
  expect_length(lines, 5L)
})

test_that("toy_gmt n = 1 produces exactly 1 line", {
  path  <- toy_gmt(n = 1L)
  lines <- readLines(path)
  expect_length(lines, 1L)
})

test_that("toy_gmt n = 3 produces exactly 3 lines", {
  path  <- toy_gmt(n = 3L)
  lines <- readLines(path)
  expect_length(lines, 3L)
})

test_that("toy_gmt each line has at least 3 tab-separated fields", {
  path  <- toy_gmt()
  lines <- readLines(path)
  fields_per_line <- vapply(strsplit(lines, "\t"), length, integer(1L))
  expect_true(all(fields_per_line >= 3L))
})

test_that("toy_gmt first field of each line is a non-empty term name", {
  path  <- toy_gmt()
  lines <- readLines(path)
  terms <- vapply(strsplit(lines, "\t"), `[[`, character(1L), 1L)
  expect_true(all(nchar(terms) > 0L))
})

test_that("toy_gmt term names are distinct", {
  path  <- toy_gmt()
  lines <- readLines(path)
  terms <- vapply(strsplit(lines, "\t"), `[[`, character(1L), 1L)
  expect_equal(length(terms), length(unique(terms)))
})

test_that("toy_gmt n > 5 silently caps at 5 (max available sets)", {
  path  <- toy_gmt(n = 99L)
  lines <- readLines(path)
  expect_length(lines, 5L)
})

test_that("toy_gmt output is compatible with gmt2df", {
  path <- toy_gmt()
  out  <- gmt2df(path)
  expect_s3_class(out, "data.frame")
  expect_named(out, c("term", "description", "gene"))
  expect_gt(nrow(out), 0L)
})

test_that("toy_gmt output is compatible with gmt2list", {
  path <- toy_gmt()
  out  <- gmt2list(path)
  expect_type(out, "list")
  expect_length(out, 5L)
  expect_true(all(vapply(out, is.character, logical(1L))))
})

test_that("toy_gmt gmt2list names match gmt2df terms", {
  path     <- toy_gmt()
  df_terms <- unique(gmt2df(path)$term)
  lst_names <- names(gmt2list(path))
  expect_equal(sort(df_terms), sort(lst_names))
})

test_that("toy_gmt n = 3 gmt2df returns exactly 3 distinct gene sets", {
  path  <- toy_gmt(n = 3L)
  out   <- gmt2df(path)
  expect_equal(length(unique(out$term)), 3L)
})

test_that("toy_gmt errors on n = 0", {
  expect_error(toy_gmt(n = 0L), class = "rlang_error")
})

test_that("toy_gmt errors on negative n", {
  expect_error(toy_gmt(n = -1L), class = "rlang_error")
})

test_that("toy_gmt errors on non-integer n", {
  expect_error(toy_gmt(n = 2.5), class = "rlang_error")
})

test_that("toy_gmt called twice produces different temp paths", {
  p1 <- toy_gmt()
  p2 <- toy_gmt()
  expect_false(identical(p1, p2))
})


# =============================================================================
# toy_gene_ref
# =============================================================================

test_that("toy_gene_ref returns a data.frame", {
  out <- toy_gene_ref()
  expect_s3_class(out, "data.frame")
})

test_that("toy_gene_ref default has expected columns", {
  out <- toy_gene_ref()
  expect_true(all(c("symbol", "ensembl_id", "entrez_id") %in% names(out)))
})

test_that("toy_gene_ref default returns 20 rows", {
  out <- toy_gene_ref()
  expect_equal(nrow(out), 20L)
})

test_that("toy_gene_ref human species returns human data", {
  out <- toy_gene_ref("human")
  expect_true(all(out$species == "human"))
})

test_that("toy_gene_ref mouse species returns mouse data", {
  out <- toy_gene_ref("mouse")
  expect_true(all(out$species == "mouse"))
})

test_that("toy_gene_ref n controls number of rows returned", {
  expect_equal(nrow(toy_gene_ref(n = 5L)),  5L)
  expect_equal(nrow(toy_gene_ref(n = 10L)), 10L)
  expect_equal(nrow(toy_gene_ref(n = 1L)),  1L)
})

test_that("toy_gene_ref n capped silently at available rows (100)", {
  out <- toy_gene_ref(n = 999L)
  expect_equal(nrow(out), 100L)
})

test_that("toy_gene_ref human and mouse return different data", {
  h <- toy_gene_ref("human", n = 5L)
  m <- toy_gene_ref("mouse", n = 5L)
  expect_false(identical(h$ensembl_id, m$ensembl_id))
})

test_that("toy_gene_ref ensembl_id column is character", {
  out <- toy_gene_ref()
  expect_type(out$ensembl_id, "character")
})

test_that("toy_gene_ref ensembl_id values are non-empty strings", {
  out <- toy_gene_ref()
  expect_true(all(nchar(out$ensembl_id) > 0L))
})

test_that("toy_gene_ref human ensembl_id starts with ENSG", {
  out <- toy_gene_ref("human")
  expect_true(all(grepl("^ENSG", out$ensembl_id)))
})

test_that("toy_gene_ref mouse ensembl_id starts with ENSMUSG", {
  out <- toy_gene_ref("mouse")
  expect_true(all(grepl("^ENSMUSG", out$ensembl_id)))
})

test_that("toy_gene_ref has species column consistent with argument", {
  expect_true(all(toy_gene_ref("human", n = 5L)$species == "human"))
  expect_true(all(toy_gene_ref("mouse", n = 5L)$species == "mouse"))
})

test_that("toy_gene_ref has gene_type column", {
  out <- toy_gene_ref()
  expect_true("gene_type" %in% names(out))
  expect_type(out$gene_type, "character")
})

test_that("toy_gene_ref symbol is NA (not empty string) for missing entries", {
  out <- toy_gene_ref(n = 20L)
  # Empty symbols must be NA, not ""
  expect_false(any(out$symbol == "", na.rm = TRUE))
})

test_that("toy_gene_ref mouse symbol is NA (not empty string) for missing entries", {
  out <- toy_gene_ref("mouse", n = 20L)
  expect_false(any(out$symbol == "", na.rm = TRUE))
})

test_that("toy_gene_ref errors on invalid species", {
  expect_error(toy_gene_ref("alien"),  class = "error")
  expect_error(toy_gene_ref("Human"),  class = "error")
})

test_that("toy_gene_ref errors on n = 0", {
  expect_error(toy_gene_ref(n = 0L), class = "rlang_error")
})

test_that("toy_gene_ref errors on negative n", {
  expect_error(toy_gene_ref(n = -1L), class = "rlang_error")
})

test_that("toy_gene_ref errors on non-integer n", {
  expect_error(toy_gene_ref(n = 3.5), class = "rlang_error")
})
