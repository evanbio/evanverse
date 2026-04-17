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

test_that("toy_gmt genes are mappable with human toy_gene_ref", {
  path <- toy_gmt(n = 3L)
  long <- gmt2df(path)
  ref  <- toy_gene_ref("human", n = 100L)
  ids  <- gene2entrez(long$gene, ref = ref, species = "human")

  expect_false(anyNA(ids$entrez_id))
  expect_equal(ids$entrez_id[match(c("TP53", "BRCA1"), ids$symbol)],
               c(7157L, 672L))
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
  expect_named(
    out,
    c("symbol", "ensembl_id", "entrez_id", "gene_type", "species",
      "ensembl_version", "download_date")
  )
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

test_that("toy_gene_ref contains key GMT genes in human reference", {
  out <- toy_gene_ref("human", n = 100L)
  expect_true(all(c("TP53", "BRCA1", "MYC", "EGFR") %in% out$symbol))
  expect_equal(out$entrez_id[match("TP53", out$symbol)], 7157L)
  expect_equal(out$ensembl_id[match("BRCA1", out$symbol)], "ENSG00000012048")
})

test_that("toy_gene_ref contains mouse ortholog examples", {
  out <- toy_gene_ref("mouse", n = 100L)
  expect_true(all(c("Trp53", "Brca1", "Myc", "Egfr") %in% out$symbol))
  expect_equal(out$entrez_id[match("Trp53", out$symbol)], 22059L)
  expect_equal(out$ensembl_id[match("Trp53", out$symbol)], "ENSMUSG00000059552")
})

test_that("toy_gene_ref has no duplicated non-missing symbols or Ensembl IDs", {
  human <- toy_gene_ref("human", n = 100L)
  mouse <- toy_gene_ref("mouse", n = 100L)

  expect_equal(anyDuplicated(stats::na.omit(human$symbol)), 0L)
  expect_equal(anyDuplicated(human$ensembl_id), 0L)
  expect_equal(anyDuplicated(stats::na.omit(mouse$symbol)), 0L)
  expect_equal(anyDuplicated(mouse$ensembl_id), 0L)
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

test_that("toy_gene_ref human symbols are present and non-empty", {
  out <- toy_gene_ref(n = 20L)
  expect_false(anyNA(out$symbol))
  expect_false(any(out$symbol == "", na.rm = TRUE))
})

test_that("toy_gene_ref mouse symbols are present and non-empty", {
  out <- toy_gene_ref("mouse", n = 20L)
  expect_false(anyNA(out$symbol))
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
