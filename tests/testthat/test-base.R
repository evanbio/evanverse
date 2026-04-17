# =============================================================================
# test-base.R — Tests for all exported functions in R/base.R
# =============================================================================

# Shared fixtures ---------------------------------------------------------------

.ref_human <- function() {
  data.frame(
    symbol     = c("TP53", "BRCA1", "MYC", "EGFR", "PTEN"),
    ensembl_id = c("ENSG00000141510", "ENSG00000012048",
                   "ENSG00000136997", "ENSG00000146648", "ENSG00000171862"),
    entrez_id  = c("7157", "672", "4609", "1956", "5728"),
    stringsAsFactors = FALSE
  )
}

.ref_mouse <- function() {
  data.frame(
    symbol     = c("Trp53", "Brca1", "Myc", "Egfr", "Pten"),
    ensembl_id = c("ENSMUSG00000059552", "ENSMUSG00000022722",
                   "ENSMUSG00000022346", "ENSMUSG00000020122", "ENSMUSG00000013663"),
    entrez_id  = c("22059", "12189", "17869", "13649", "19211"),
    stringsAsFactors = FALSE
  )
}


# =============================================================================
# df2list
# =============================================================================

test_that("df2list returns a named list grouped by group_col", {
  df <- data.frame(
    group = c("A", "A", "B", "B", "B"),
    value = c("x1", "x2", "y1", "y2", "y3"),
    stringsAsFactors = FALSE
  )
  out <- df2list(df, "group", "value")

  expect_type(out, "list")
  expect_named(out, c("A", "B"))
  expect_equal(out$A, c("x1", "x2"))
  expect_equal(out$B, c("y1", "y2", "y3"))
})

test_that("df2list works with a single group", {
  df <- data.frame(g = c("X", "X"), v = 1:2)
  out <- df2list(df, "g", "v")
  expect_length(out, 1L)
  expect_equal(out$X, 1:2)
})

test_that("df2list errors on non-data.frame input", {
  expect_error(df2list(list(a = 1), "a", "b"), class = "rlang_error")
})

test_that("df2list errors when group_col is absent", {
  df <- data.frame(a = 1:3, b = letters[1:3])
  expect_error(df2list(df, "missing", "b"), class = "rlang_error")
})

test_that("df2list errors when value_col is absent", {
  df <- data.frame(a = 1:3, b = letters[1:3])
  expect_error(df2list(df, "a", "missing"), class = "rlang_error")
})


# =============================================================================
# df2vect
# =============================================================================

test_that("df2vect returns a correctly named vector", {
  df <- data.frame(gene = c("TP53", "MYC"), score = c(0.9, 0.4),
                   stringsAsFactors = FALSE)
  out <- df2vect(df, "gene", "score")

  expect_type(out, "double")
  expect_named(out, c("TP53", "MYC"))
  expect_equal(unname(out), c(0.9, 0.4))
})

test_that("df2vect preserves character value type", {
  df <- data.frame(id = c("a", "b"), label = c("foo", "bar"),
                   stringsAsFactors = FALSE)
  out <- df2vect(df, "id", "label")
  expect_type(out, "character")
})

test_that("df2vect errors on NA in name_col", {
  df <- data.frame(id = c("a", NA), val = 1:2)
  expect_error(df2vect(df, "id", "val"), class = "rlang_error")
})

test_that("df2vect errors on duplicate names", {
  df <- data.frame(id = c("a", "a"), val = 1:2)
  expect_error(df2vect(df, "id", "val"), class = "rlang_error")
})

test_that("df2vect errors on empty string in name_col", {
  df <- data.frame(id = c("a", ""), val = 1:2, stringsAsFactors = FALSE)
  expect_error(df2vect(df, "id", "val"), class = "rlang_error")
})

test_that("df2vect errors on non-data.frame input", {
  expect_error(df2vect(list(a = 1), "a", "b"), class = "rlang_error")
})


# =============================================================================
# gene2entrez
# =============================================================================

test_that("gene2entrez matches human symbols case-insensitively", {
  out <- gene2entrez(c("tp53", "BRCA1", "Myc"), ref = .ref_human(), species = "human")

  expect_s3_class(out, "data.frame")
  expect_named(out, c("symbol", "symbol_std", "entrez_id"))
  expect_equal(out$symbol,    c("tp53", "BRCA1", "Myc"))
  expect_equal(out$entrez_id, c("7157", "672", "4609"))
})

test_that("gene2entrez matches mouse symbols case-insensitively", {
  out <- gene2entrez(c("TRP53", "brca1"), ref = .ref_mouse(), species = "mouse")

  expect_equal(out$entrez_id, c("22059", "12189"))
})

test_that("gene2entrez returns NA for unmatched symbols", {
  out <- gene2entrez("NOTREAL", ref = .ref_human(), species = "human")
  expect_true(is.na(out$entrez_id))
})

test_that("gene2entrez errors when ref is missing required columns", {
  bad_ref <- data.frame(symbol = "TP53", stringsAsFactors = FALSE)
  expect_error(gene2entrez("TP53", ref = bad_ref, species = "human"),
               class = "rlang_error")
})

test_that("gene2entrez errors on non-character input", {
  expect_error(gene2entrez(123, ref = .ref_human()), class = "rlang_error")
})

test_that("gene2entrez errors on invalid species argument", {
  expect_error(gene2entrez("TP53", ref = .ref_human(), species = "alien"),
               class = "error")
})

test_that("gene2entrez warns and uses first match for duplicated normalized symbols", {
  ref <- data.frame(
    symbol = c("TP53", "tp53"),
    entrez_id = c("7157", "9999"),
    stringsAsFactors = FALSE
  )

  expect_warning(
    out <- gene2entrez("tp53", ref = ref, species = "human"),
    "duplicated gene symbol"
  )
  expect_equal(out$entrez_id, "7157")
})


# =============================================================================
# gene2ensembl
# =============================================================================

test_that("gene2ensembl matches human symbols case-insensitively", {
  out <- gene2ensembl(c("tp53", "EGFR"), ref = .ref_human(), species = "human")

  expect_named(out, c("symbol", "symbol_std", "ensembl_id"))
  expect_equal(out$ensembl_id, c("ENSG00000141510", "ENSG00000146648"))
})

test_that("gene2ensembl matches mouse symbols case-insensitively", {
  out <- gene2ensembl(c("MYC", "PTEN"), ref = .ref_mouse(), species = "mouse")

  expect_equal(out$ensembl_id, c("ENSMUSG00000022346", "ENSMUSG00000013663"))
})

test_that("gene2ensembl returns NA for unmatched symbols", {
  out <- gene2ensembl("GHOST", ref = .ref_human(), species = "human")
  expect_true(is.na(out$ensembl_id))
})

test_that("gene2ensembl errors when ref is missing required columns", {
  bad_ref <- data.frame(symbol = "TP53", stringsAsFactors = FALSE)
  expect_error(gene2ensembl("TP53", ref = bad_ref, species = "human"),
               class = "rlang_error")
})

test_that("gene2ensembl errors on invalid species argument", {
  expect_error(gene2ensembl("TP53", ref = .ref_human(), species = "fly"),
               class = "error")
})

test_that("gene2ensembl warns and uses first match for duplicated normalized symbols", {
  ref <- data.frame(
    symbol = c("Trp53", "TRP53"),
    ensembl_id = c("ENSMUSG00000059552", "DUPLICATE"),
    stringsAsFactors = FALSE
  )

  expect_warning(
    out <- gene2ensembl("trp53", ref = ref, species = "mouse"),
    "duplicated gene symbol"
  )
  expect_equal(out$ensembl_id, "ENSMUSG00000059552")
})


# =============================================================================
# file_ls
# =============================================================================

test_that("file_ls returns a data.frame with expected columns", {
  tmp <- withr::local_tempdir()
  writeLines("a", file.path(tmp, "a.txt"))
  writeLines("b", file.path(tmp, "b.txt"))

  out <- file_ls(tmp)
  expect_s3_class(out, "data.frame")
  expect_named(out, c("file", "size_MB", "modified_time", "path"))
  expect_equal(nrow(out), 2L)
})

test_that("file_ls returns zero-row data.frame for empty directory", {
  tmp <- withr::local_tempdir()
  out <- file_ls(tmp)
  expect_equal(nrow(out), 0L)
})

test_that("file_ls pattern argument filters files", {
  tmp <- withr::local_tempdir()
  writeLines("", file.path(tmp, "keep.csv"))
  writeLines("", file.path(tmp, "skip.txt"))

  out <- file_ls(tmp, pattern = "\\.csv$")
  expect_equal(nrow(out), 1L)
  expect_equal(out$file, "keep.csv")
})

test_that("file_ls recursive finds files in subdirectories", {
  tmp  <- withr::local_tempdir()
  sub  <- file.path(tmp, "sub")
  dir.create(sub)
  writeLines("", file.path(tmp, "root.R"))
  writeLines("", file.path(sub,  "nested.R"))

  out <- file_ls(tmp, recursive = TRUE)
  expect_equal(nrow(out), 2L)
})

test_that("file_ls errors on non-existent directory", {
  expect_error(file_ls("/no/such/path"), class = "rlang_error")
})


# =============================================================================
# file_info
# =============================================================================

test_that("file_info returns metadata for existing file", {
  tmp  <- withr::local_tempfile(fileext = ".txt")
  writeLines("hello", tmp)

  out <- file_info(tmp)
  expect_s3_class(out, "data.frame")
  expect_named(out, c("file", "size_MB", "modified_time", "path"))
  expect_equal(nrow(out), 1L)
  expect_equal(out$file, basename(tmp))
})

test_that("file_info accepts a vector of file paths", {
  f1 <- withr::local_tempfile(fileext = ".txt")
  f2 <- withr::local_tempfile(fileext = ".txt")
  writeLines("a", f1)
  writeLines("b", f2)

  out <- file_info(c(f1, f2))
  expect_equal(nrow(out), 2L)
})

test_that("file_info errors when a file does not exist", {
  expect_error(file_info("/no/such/file.txt"), class = "rlang_error")
})

test_that("file_info deduplicates repeated file paths", {
  f <- withr::local_tempfile(fileext = ".txt")
  writeLines("hello", f)

  out <- file_info(c(f, f, f))
  expect_equal(nrow(out), 1L)
})


# =============================================================================
# file_tree
# =============================================================================

test_that("file_tree returns a character vector invisibly", {
  tmp <- withr::local_tempdir()
  writeLines("", file.path(tmp, "a.R"))
  out <- withVisible(file_tree(tmp, max_depth = 1))

  expect_false(out$visible)
  expect_type(out$value, "character")
  expect_true(length(out$value) >= 1L)
})

test_that("file_tree with max_depth = 0 returns only root", {
  tmp <- withr::local_tempdir()
  sub <- file.path(tmp, "sub"); dir.create(sub)
  writeLines("", file.path(sub, "nested.R"))

  out <- file_tree(tmp, max_depth = 0)
  expect_equal(length(out), 1L)
})

test_that("file_tree errors on non-existent directory", {
  expect_error(file_tree("/no/such/path"), class = "rlang_error")
})


# =============================================================================
# gmt2df
# =============================================================================

test_that("gmt2df returns a data.frame with term/description/gene columns", {
  tmp <- toy_gmt(n = 3)
  out <- gmt2df(tmp)

  expect_s3_class(out, "data.frame")
  expect_named(out, c("term", "description", "gene"))
  expect_true(nrow(out) > 0L)
})

test_that("gmt2df expands multiple gene sets into long format", {
  tmp  <- toy_gmt(n = 2)
  out  <- gmt2df(tmp)
  sets <- unique(out$term)
  expect_equal(length(sets), 2L)
})

test_that("gmt2df errors on non-existent file", {
  expect_error(gmt2df("/no/such/file.gmt"), class = "rlang_error")
})

test_that("gmt2df errors on empty GMT file", {
  tmp <- withr::local_tempfile(fileext = ".gmt")
  writeLines(character(0), tmp)
  expect_error(gmt2df(tmp), class = "rlang_error")
})

test_that("gmt2df warns and skips malformed lines, keeps valid ones", {
  tmp <- withr::local_tempfile(fileext = ".gmt")
  # line 1: valid; line 2: only 2 fields (malformed)
  writeLines(c("GOOD_SET\tdesc\tGENE1\tGENE2", "BAD\tonly_two"), tmp)
  expect_warning(
    out <- gmt2df(tmp)
  )
  expect_s3_class(out, "data.frame")
  expect_true(all(out$term == "GOOD_SET"))
})

test_that("gmt2df errors when all lines are malformed", {
  tmp <- withr::local_tempfile(fileext = ".gmt")
  writeLines(c("only_one_field", "also_bad"), tmp)
  expect_error(suppressWarnings(gmt2df(tmp)), class = "rlang_error")
})

test_that("gmt2df always returns a data.frame, never NULL", {
  tmp <- toy_gmt(n = 1)
  out <- gmt2df(tmp)
  expect_s3_class(out, "data.frame")
  expect_named(out, c("term", "description", "gene"))
})


# =============================================================================
# gmt2list
# =============================================================================

test_that("gmt2list returns a named list of character vectors", {
  tmp <- toy_gmt(n = 3)
  out <- gmt2list(tmp)

  expect_type(out, "list")
  expect_equal(length(out), 3L)
  expect_true(all(vapply(out, is.character, logical(1L))))
})

test_that("gmt2list names match the term column of gmt2df", {
  tmp      <- toy_gmt(n = 5)
  lst      <- gmt2list(tmp)
  df_terms <- unique(gmt2df(tmp)$term)

  expect_equal(sort(names(lst)), sort(df_terms))
})

test_that("gmt2list errors on non-existent file", {
  expect_error(gmt2list("/no/such/file.gmt"), class = "rlang_error")
})

test_that("gmt2list errors when all lines are malformed", {
  tmp <- withr::local_tempfile(fileext = ".gmt")
  writeLines(c("only_one_field", "also_bad"), tmp)
  expect_error(suppressWarnings(gmt2list(tmp)), class = "rlang_error")
})


# =============================================================================
# recode_column
# =============================================================================

test_that("recode_column replaces values in-place when name is NULL", {
  df   <- data.frame(x = c("a", "b", "c"), stringsAsFactors = FALSE)
  dict <- c(a = "alpha", b = "beta")
  out  <- recode_column(df, "x", dict)

  expect_equal(out$x, c("alpha", "beta", NA))
  expect_equal(ncol(out), 1L)
})

test_that("recode_column creates a new column when name is provided", {
  df   <- data.frame(x = c("a", "b"), stringsAsFactors = FALSE)
  out  <- recode_column(df, "x", c(a = "A"), name = "y")

  expect_true("y" %in% names(out))
  expect_true("x" %in% names(out))
})

test_that("recode_column applies custom default for unmatched values", {
  df   <- data.frame(x = c("a", "z"), stringsAsFactors = FALSE)
  out  <- recode_column(df, "x", c(a = "alpha"), default = "other")

  expect_equal(out$x, c("alpha", "other"))
})

test_that("recode_column preserves explicit NA mappings", {
  df   <- data.frame(x = c("a", "b", "z"), stringsAsFactors = FALSE)
  dict <- c(a = NA_character_, b = "beta")
  out  <- recode_column(df, "x", dict, default = "other")

  expect_equal(out$x, c(NA_character_, "beta", "other"))
})

test_that("recode_column errors on non-data.frame input", {
  expect_error(recode_column(list(x = 1), "x", c(a = "A")), class = "rlang_error")
})

test_that("recode_column errors when column is absent", {
  df <- data.frame(x = "a", stringsAsFactors = FALSE)
  expect_error(recode_column(df, "missing", c(a = "A")), class = "rlang_error")
})

test_that("recode_column errors when dict is not a named vector", {
  df <- data.frame(x = "a", stringsAsFactors = FALSE)
  expect_error(recode_column(df, "x", c("A", "B")), class = "rlang_error")
})

test_that("recode_column scalar default does not recycle silently across rows", {
  # Every unmatched row must receive exactly the scalar default, not a recycled
  # vector — guards against accidental vector default being passed.
  df   <- data.frame(x = c("a", "z", "z"), stringsAsFactors = FALSE)
  out  <- recode_column(df, "x", c(a = "alpha"), default = "other")
  expect_equal(out$x, c("alpha", "other", "other"))
  expect_length(out$x, 3L)
})

test_that("recode_column errors when default is not scalar", {
  df <- data.frame(x = c("a", "z"), stringsAsFactors = FALSE)
  expect_error(
    recode_column(df, "x", c(a = "alpha"), default = c("other", "missing")),
    class = "rlang_error"
  )
})


# =============================================================================
# view
# =============================================================================

test_that("view returns a reactable widget for a valid data.frame", {
  skip_if_not_installed("reactable")
  out <- view(iris, n = 5)
  expect_s3_class(out, "reactable")
})

test_that("view errors on non-data.frame input", {
  skip_if_not_installed("reactable")
  expect_error(view(list(a = 1)), class = "rlang_error")
})

test_that("view errors when reactable is not installed", {
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) FALSE,
    .package = "base"
  )
  expect_error(view(iris), class = "rlang_error")
})


# =============================================================================
# perm
# =============================================================================

test_that("perm returns correct values for standard inputs", {
  expect_equal(perm(8, 4), 1680)
  expect_equal(perm(5, 2), 20)
  expect_equal(perm(10, 3), 720)
})

test_that("perm(n, 0) returns 1 for any n", {
  expect_equal(perm(0,  0), 1)
  expect_equal(perm(5,  0), 1)
  expect_equal(perm(100, 0), 1)
})

test_that("perm(n, n) returns n!", {
  expect_equal(perm(1, 1), 1)
  expect_equal(perm(4, 4), 24)
  expect_equal(perm(6, 6), 720)
})

test_that("perm returns 0 when k > n", {
  expect_equal(perm(5, 6), 0)
  expect_equal(perm(0, 1), 0)
})

test_that("perm warns on overflow-prone inputs", {
  expect_warning(perm(1000L, 999L), "exceeds double range")
})

test_that("perm errors on negative inputs", {
  expect_error(perm(-1, 2), class = "rlang_error")
  expect_error(perm(5, -1), class = "rlang_error")
})

test_that("perm errors on non-integer inputs", {
  expect_error(perm(5.5, 2), class = "rlang_error")
  expect_error(perm(5, 1.5), class = "rlang_error")
})


# =============================================================================
# comb
# =============================================================================

test_that("comb returns correct values for standard inputs", {
  expect_equal(comb(8, 4), 70)
  expect_equal(comb(5, 2), 10)
  expect_equal(comb(10, 3), 120)
})

test_that("comb(n, 0) returns 1 for any n", {
  expect_equal(comb(0,  0), 1)
  expect_equal(comb(5,  0), 1)
  expect_equal(comb(100, 0), 1)
})

test_that("comb(n, n) returns 1 for any n", {
  expect_equal(comb(1, 1), 1)
  expect_equal(comb(8, 8), 1)
  expect_equal(comb(50, 50), 1)
})

test_that("comb satisfies symmetry C(n,k) == C(n,n-k)", {
  expect_equal(comb(10, 3), comb(10, 7))
  expect_equal(comb(20, 5), comb(20, 15))
})

test_that("comb returns 0 when k > n", {
  expect_equal(comb(5, 6), 0)
  expect_equal(comb(0, 1), 0)
})

test_that("comb result is always <= perm result for same inputs", {
  # C(n,k) <= P(n,k) for all valid n,k (they are equal only when k <= 1)
  expect_true(comb(10, 4) <= perm(10, 4))
  expect_true(comb(7, 3)  <= perm(7, 3))
})

test_that("comb warns on overflow-prone inputs", {
  expect_warning(comb(2000L, 1000L), "exceeds double range")
})

test_that("comb errors on negative inputs", {
  expect_error(comb(-1, 2), class = "rlang_error")
  expect_error(comb(5, -1), class = "rlang_error")
})

test_that("comb errors on non-integer inputs", {
  expect_error(comb(5.5, 2), class = "rlang_error")
  expect_error(comb(5, 1.5), class = "rlang_error")
})
