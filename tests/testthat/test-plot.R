# =============================================================================
# test-plot.R -- Tests for all exported functions in R/plot.R
# =============================================================================

# Shared fixtures --------------------------------------------------------------

.bar_df <- function() {
  data.frame(
    category = c("A", "B", "C", "D"),
    value    = c(10, 25, 15, 30),
    stringsAsFactors = FALSE
  )
}

.bar_df_grouped <- function() {
  data.frame(
    category = rep(c("A", "B", "C"), 2),
    group    = rep(c("X", "Y"), each = 3),
    value    = c(10, 25, 15, 30, 5, 20),
    stringsAsFactors = FALSE
  )
}

.pie_df <- function() {
  data.frame(
    group = c("X", "Y", "Z"),
    count = c(10, 25, 15),
    stringsAsFactors = FALSE
  )
}

.forest_df <- function() {
  data.frame(
    item      = c("Exposure vs. control", "Unadjusted", "Fully adjusted"),
    `Cases/N` = c("", "89/4521", "89/4521"),
    p_value   = c(NA_real_, 0.001, 0.006),
    check.names      = FALSE,
    stringsAsFactors = FALSE
  )
}


# =============================================================================
# plot_bar
# =============================================================================

test_that("plot_bar returns a ggplot for basic input", {
  p <- plot_bar(.bar_df(), x_col = "category", y_col = "value")
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar with horizontal = TRUE returns a ggplot", {
  p <- plot_bar(.bar_df(), x_col = "category", y_col = "value",
                horizontal = TRUE)
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar sort = TRUE orders factor levels by y descending", {
  p    <- plot_bar(.bar_df(), x_col = "category", y_col = "value",
                   sort = TRUE, decreasing = TRUE)
  lvls <- levels(p$data$category)
  # D(30) > B(25) > C(15) > A(10)
  expect_equal(lvls, c("D", "B", "C", "A"))
})

test_that("plot_bar sort = TRUE with decreasing = FALSE orders ascending", {
  p    <- plot_bar(.bar_df(), x_col = "category", y_col = "value",
                   sort = TRUE, decreasing = FALSE)
  lvls <- levels(p$data$category)
  # A(10) < C(15) < B(25) < D(30)
  expect_equal(lvls, c("A", "C", "B", "D"))
})

test_that("plot_bar with group_col returns a ggplot (dodge)", {
  p <- plot_bar(.bar_df_grouped(), x_col = "category", y_col = "value",
                group_col = "group")
  expect_s3_class(p, "ggplot")
})

test_that("plot_bar sort_by orders x by the specified group's y values", {
  p <- plot_bar(.bar_df_grouped(), x_col = "category", y_col = "value",
                group_col = "group", sort = TRUE, sort_by = "X",
                decreasing = TRUE)
  expect_s3_class(p, "ggplot")
  # group X: A=10, B=25, C=15 -- descending: B, C, A
  lvls <- levels(p$data$category)
  expect_equal(lvls[1:3], c("B", "C", "A"))
})

test_that("plot_bar sort_by appends x values not covered by sort_by at the end", {
  # Group "X" only covers A and B; C exists only in group "Y"
  df <- data.frame(
    category = c("A", "B", "C"),
    group    = c("X", "X", "Y"),
    value    = c(10, 30, 20),
    stringsAsFactors = FALSE
  )
  p    <- plot_bar(df, x_col = "category", y_col = "value",
                   group_col = "group", sort = TRUE, sort_by = "X",
                   decreasing = TRUE)
  lvls <- levels(p$data$category)
  # All 3 categories must be present -- no data dropped
  expect_equal(length(lvls), 3L)
  # C (not in sort_by group) is appended after X-group ordering (B, A)
  expect_equal(lvls[1:2], c("B", "A"))
  expect_equal(lvls[3], "C")
})

test_that("plot_bar errors on non-data.frame input", {
  expect_error(plot_bar(list(x = 1:3), "x", "y"), class = "rlang_error")
})

test_that("plot_bar errors when x_col is absent", {
  expect_error(
    plot_bar(.bar_df(), x_col = "missing", y_col = "value"),
    regexp  = "missing",
    class   = "rlang_error"
  )
})

test_that("plot_bar errors when y_col is absent", {
  expect_error(
    plot_bar(.bar_df(), x_col = "category", y_col = "missing"),
    regexp  = "missing",
    class   = "rlang_error"
  )
})

test_that("plot_bar errors when y_col is non-numeric", {
  df <- data.frame(category = c("A", "B"), value = c("low", "high"))
  expect_error(
    plot_bar(df, x_col = "category", y_col = "value"),
    regexp = "value",
    class  = "rlang_error"
  )
})

test_that("plot_bar errors when sort = TRUE, group_col set, sort_by = NULL", {
  expect_error(
    plot_bar(.bar_df_grouped(), x_col = "category", y_col = "value",
             group_col = "group", sort = TRUE, sort_by = NULL),
    regexp = "sort_by",
    class  = "rlang_error"
  )
})

test_that("plot_bar errors when sort_by is not a valid group level", {
  expect_error(
    plot_bar(.bar_df_grouped(), x_col = "category", y_col = "value",
             group_col = "group", sort = TRUE, sort_by = "INVALID"),
    regexp = "INVALID",
    class  = "rlang_error"
  )
})

test_that("plot_bar errors when x_col has duplicates (no group_col)", {
  df <- data.frame(category = c("A", "A", "B"), value = 1:3)
  expect_error(
    plot_bar(df, x_col = "category", y_col = "value"),
    class = "rlang_error"
  )
})


# =============================================================================
# plot_density
# =============================================================================

test_that("plot_density returns a ggplot for basic input", {
  p <- plot_density(iris, x_col = "Sepal.Length")
  expect_s3_class(p, "ggplot")
})

test_that("plot_density with group_col adds fill aesthetic", {
  p <- plot_density(iris, x_col = "Sepal.Length", group_col = "Species")
  expect_s3_class(p, "ggplot")
  expect_true(!is.null(p$mapping$fill))
})

test_that("plot_density with facet_col adds a FacetWrap layer", {
  p <- plot_density(iris, x_col = "Sepal.Length", facet_col = "Species")
  expect_s3_class(p, "ggplot")
  expect_true(inherits(p$facet, "FacetWrap"))
})

test_that("plot_density with palette applies manual fill scale", {
  p       <- plot_density(iris, x_col = "Sepal.Length", group_col = "Species",
                          palette = c("red", "blue", "green"))
  aes_all <- unlist(lapply(p$scales$scales, function(s) s$aesthetics))
  expect_true("fill" %in% aes_all)
})

test_that("plot_density accepts alpha = 0 (fully transparent boundary)", {
  expect_s3_class(
    plot_density(iris, x_col = "Sepal.Length", alpha = 0),
    "ggplot"
  )
})

test_that("plot_density accepts alpha = 1 (fully opaque boundary)", {
  expect_s3_class(
    plot_density(iris, x_col = "Sepal.Length", alpha = 1),
    "ggplot"
  )
})

test_that("plot_density warns when palette supplied without group_col", {
  expect_warning(
    plot_density(iris, x_col = "Sepal.Length", palette = c("red", "blue")),
    regexp = "ignored"
  )
})

test_that("plot_density errors on non-data.frame input", {
  expect_error(plot_density(list(x = 1:10), x_col = "x"), class = "rlang_error")
})

test_that("plot_density errors when x_col is absent", {
  expect_error(
    plot_density(iris, x_col = "missing"),
    regexp = "missing",
    class  = "rlang_error"
  )
})

test_that("plot_density errors when x_col is non-numeric", {
  expect_error(
    plot_density(iris, x_col = "Species"),
    class = "rlang_error"
  )
})

test_that("plot_density errors when alpha > 1", {
  expect_error(
    plot_density(iris, x_col = "Sepal.Length", alpha = 1.5),
    regexp = "alpha",
    class  = "rlang_error"
  )
})

test_that("plot_density errors when alpha < 0", {
  expect_error(
    plot_density(iris, x_col = "Sepal.Length", alpha = -0.1),
    regexp = "alpha",
    class  = "rlang_error"
  )
})


# =============================================================================
# plot_pie
# =============================================================================

test_that("plot_pie returns a ggplot from a character vector", {
  p <- plot_pie(c("A", "A", "B", "C", "C", "C"))
  expect_s3_class(p, "ggplot")
})

test_that("plot_pie returns a ggplot from a factor vector", {
  p <- plot_pie(factor(c("X", "X", "Y", "Z")))
  expect_s3_class(p, "ggplot")
})

test_that("plot_pie returns a ggplot from a named numeric vector", {
  p <- plot_pie(c(A = 10, B = 25, C = 15))
  expect_s3_class(p, "ggplot")
  expect_equal(p$data$group, c("A", "B", "C"))
  expect_equal(p$data$count, c(10, 25, 15))
})

test_that("plot_pie returns a ggplot from a data.frame", {
  p <- plot_pie(.pie_df(), group_col = "group", count_col = "count")
  expect_s3_class(p, "ggplot")
})

test_that("plot_pie label = 'percent' adds a GeomText layer", {
  p     <- plot_pie(.pie_df(), group_col = "group", count_col = "count",
                    label = "percent")
  geoms <- vapply(p$layers, function(l) class(l$geom)[1L], character(1L))
  expect_true("GeomText" %in% geoms)
})

test_that("plot_pie label = 'count' adds a GeomText layer", {
  p     <- plot_pie(.pie_df(), group_col = "group", count_col = "count",
                    label = "count")
  geoms <- vapply(p$layers, function(l) class(l$geom)[1L], character(1L))
  expect_true("GeomText" %in% geoms)
})

test_that("plot_pie label = 'both' adds a GeomText layer", {
  p     <- plot_pie(.pie_df(), group_col = "group", count_col = "count",
                    label = "both")
  geoms <- vapply(p$layers, function(l) class(l$geom)[1L], character(1L))
  expect_true("GeomText" %in% geoms)
})

test_that("plot_pie label = 'none' has no GeomText layer", {
  p     <- plot_pie(.pie_df(), group_col = "group", count_col = "count",
                    label = "none")
  geoms <- vapply(p$layers, function(l) class(l$geom)[1L], character(1L))
  expect_false("GeomText" %in% geoms)
})

test_that("plot_pie with palette applies manual fill scale", {
  p       <- plot_pie(.pie_df(), group_col = "group", count_col = "count",
                      palette = c("red", "blue", "green"))
  aes_all <- unlist(lapply(p$scales$scales, function(s) s$aesthetics))
  expect_true("fill" %in% aes_all)
})

test_that("plot_pie silently drops zero-count slices", {
  df <- data.frame(group = c("A", "B", "C"), count = c(10, 0, 5),
                   stringsAsFactors = FALSE)
  p  <- plot_pie(df, group_col = "group", count_col = "count")
  expect_equal(nrow(p$data), 2L)
})

test_that("plot_pie errors when vector contains NA", {
  expect_error(
    plot_pie(c("A", NA, "B", "B", "C")),
    regexp = "NA",
    class  = "rlang_error"
  )
})

test_that("plot_pie errors when count_col contains NA", {
  df <- data.frame(group = c("A", "B"), count = c(10, NA))
  expect_error(
    plot_pie(df, group_col = "group", count_col = "count"),
    regexp = "NA",
    class  = "rlang_error"
  )
})

test_that("plot_pie errors when count_col contains negative values", {
  df <- data.frame(group = c("A", "B"), count = c(10, -5))
  expect_error(
    plot_pie(df, group_col = "group", count_col = "count"),
    regexp = "non-negative",
    class  = "rlang_error"
  )
})

test_that("plot_pie errors when data.frame group values are duplicated", {
  df <- data.frame(group = c("A", "A", "B"), count = c(10, 5, 7))
  expect_error(
    plot_pie(df, group_col = "group", count_col = "count"),
    regexp = "duplicate",
    class  = "rlang_error"
  )
})

test_that("plot_pie errors when fewer than 2 non-zero groups remain", {
  df <- data.frame(group = c("A", "B"), count = c(10, 0),
                   stringsAsFactors = FALSE)
  expect_error(
    plot_pie(df, group_col = "group", count_col = "count"),
    regexp = "two",
    class  = "rlang_error"
  )
})

test_that("plot_pie errors on unsupported data type", {
  expect_error(plot_pie(42L), class = "rlang_error")
})


# =============================================================================
# plot_venn
# =============================================================================

# --- Parameter validation (no third-party package required) ------------------

test_that("plot_venn errors when a set is empty", {
  expect_error(
    plot_venn(c("A", "B"), character(0)),
    regexp = "empty",
    class  = "rlang_error"
  )
})

test_that("plot_venn errors when set_names length mismatches number of sets", {
  expect_error(
    plot_venn(c("A", "B"), c("B", "C"), set_names = c("only_one")),
    regexp = "set_names",
    class  = "rlang_error"
  )
})

test_that("plot_venn errors when ggvenn is not installed (classic)", {
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) FALSE,
    .package = "base"
  )
  expect_error(
    plot_venn(c("A", "B"), c("B", "C"), method = "classic"),
    regexp = "ggvenn",
    class  = "rlang_error"
  )
})

test_that("plot_venn gradient errors when palette has length > 1", {
  skip_if_not_installed("ggvenn")
  skip_if_not_installed("ggVennDiagram")
  local_mocked_bindings(
    requireNamespace = function(pkg, ...) TRUE,
    .package = "base"
  )
  expect_error(
    plot_venn(c("A", "B"), c("B", "C"),
              method  = "gradient",
              palette = c("Blues", "Reds")),
    regexp = "length 1",
    class  = "rlang_error"
  )
})

# --- Rendering (requires ggvenn / ggVennDiagram) -----------------------------

test_that("plot_venn returns a ggplot for 2 sets (classic)", {
  skip_if_not_installed("ggvenn")
  p <- plot_venn(c("A", "B", "C"), c("B", "C", "D"))
  expect_s3_class(p, "ggplot")
})

test_that("plot_venn returns a ggplot for 3 sets (classic)", {
  skip_if_not_installed("ggvenn")
  p <- plot_venn(c("A", "B"), c("B", "C"), c("C", "D"))
  expect_s3_class(p, "ggplot")
})

test_that("plot_venn returns a ggplot for 4 sets (classic)", {
  skip_if_not_installed("ggvenn")
  p <- plot_venn(c("A", "B"), c("B", "C"), c("C", "D"), c("D", "E"))
  expect_s3_class(p, "ggplot")
})

test_that("plot_venn return_sets = TRUE returns a list with plot and sets", {
  skip_if_not_installed("ggvenn")
  out <- plot_venn(c("A", "B"), c("B", "C"), return_sets = TRUE)
  expect_type(out, "list")
  expect_named(out, c("plot", "sets"))
  expect_s3_class(out$plot, "ggplot")
  expect_type(out$sets, "list")
  expect_length(out$sets, 2L)
})

test_that("plot_venn set_names are applied to the set list", {
  skip_if_not_installed("ggvenn")
  out <- plot_venn(c("A", "B"), c("B", "C"),
                   set_names   = c("Group1", "Group2"),
                   return_sets = TRUE)
  expect_equal(names(out$sets), c("Group1", "Group2"))
})

test_that("plot_venn deduplicates set elements silently", {
  skip_if_not_installed("ggvenn")
  out <- plot_venn(c("A", "A", "B"), c("B", "C"), return_sets = TRUE)
  expect_equal(length(out$sets[[1L]]), 2L)   # A, B -- duplicate removed
})

test_that("plot_venn gradient accepts a length-1 palette name", {
  skip_if_not_installed("ggVennDiagram")
  p <- plot_venn(c("A", "B"), c("B", "C"),
                 method = "gradient", palette = "Blues")
  expect_s3_class(p, "ggplot")
})


# =============================================================================
# plot_forest
# =============================================================================

# --- Parameter validation (no forestploter required) -------------------------

test_that("plot_forest errors on non-data.frame input", {
  expect_error(
    plot_forest(list(item = "A"), est = 1, lower = 0.5, upper = 1.5),
    class = "rlang_error"
  )
})

test_that("plot_forest errors when est length != nrow(data)", {
  expect_error(
    plot_forest(.forest_df(),
                est   = c(1, 2),
                lower = c(0.5, 1),
                upper = c(1.5, 2.5)),
    class = "rlang_error"
  )
})

test_that("plot_forest errors when lower length != nrow(data)", {
  expect_error(
    plot_forest(.forest_df(),
                est   = c(NA, 1.52, 1.43),
                lower = c(NA, 1.18),
                upper = c(NA, 1.96, 1.85)),
    class = "rlang_error"
  )
})

test_that("plot_forest errors when ci_column is out of valid range", {
  expect_error(
    plot_forest(.forest_df(),
                est       = c(NA, 1.52, 1.43),
                lower     = c(NA, 1.18, 1.11),
                upper     = c(NA, 1.96, 1.85),
                ci_column = 10L),
    regexp = "ci_column",
    class  = "rlang_error"
  )
})

test_that("plot_forest errors when save = TRUE and dest = NULL", {
  expect_error(
    plot_forest(.forest_df(),
                est   = c(NA, 1.52, 1.43),
                lower = c(NA, 1.18, 1.11),
                upper = c(NA, 1.96, 1.85),
                save  = TRUE,
                dest  = NULL),
    regexp = "dest",
    class  = "rlang_error"
  )
})

test_that("plot_forest border_width scalar is recycled to length 3 without error", {
  skip_if_not_installed("forestploter")
  # scalar border_width is a valid input -- must not error
  out <- plot_forest(.forest_df(),
                     est          = c(NA, 1.52, 1.43),
                     lower        = c(NA, 1.18, 1.11),
                     upper        = c(NA, 1.96, 1.85),
                     border_width = 2)
  expect_true(inherits(out, "gtable"))
})

test_that("plot_forest errors when p_cols points to a non-numeric column", {
  df        <- .forest_df()
  df$label  <- c("a", "b", "c")   # non-numeric column
  expect_error(
    plot_forest(df,
                est    = c(NA, 1.52, 1.43),
                lower  = c(NA, 1.18, 1.11),
                upper  = c(NA, 1.96, 1.85),
                p_cols = "label"),
    regexp = "numeric",
    class  = "rlang_error"
  )
})

# --- Rendering (requires forestploter) ---------------------------------------

test_that("plot_forest returns invisibly as a gtable", {
  skip_if_not_installed("forestploter")
  out <- withVisible(
    plot_forest(.forest_df(),
                est   = c(NA, 1.52, 1.43),
                lower = c(NA, 1.18, 1.11),
                upper = c(NA, 1.96, 1.85))
  )
  expect_false(out$visible)
  expect_true(inherits(out$value, "gtable"))
})

test_that("plot_forest with indent and bold_label produces a gtable", {
  skip_if_not_installed("forestploter")
  out <- plot_forest(
    .forest_df(),
    est        = c(NA, 1.52, 1.43),
    lower      = c(NA, 1.18, 1.11),
    upper      = c(NA, 1.96, 1.85),
    indent     = c(0L, 1L, 1L),
    bold_label = c(TRUE, FALSE, FALSE)
  )
  expect_true(inherits(out, "gtable"))
})

test_that("plot_forest with p_cols formats p-value column", {
  skip_if_not_installed("forestploter")
  out <- plot_forest(
    .forest_df(),
    est    = c(NA, 1.52, 1.43),
    lower  = c(NA, 1.18, 1.11),
    upper  = c(NA, 1.96, 1.85),
    p_cols = "p_value"
  )
  expect_true(inherits(out, "gtable"))
})

test_that("plot_forest with custom xlim and ticks_at produces a gtable", {
  skip_if_not_installed("forestploter")
  out <- plot_forest(
    .forest_df(),
    est      = c(NA, 1.52, 1.43),
    lower    = c(NA, 1.18, 1.11),
    upper    = c(NA, 1.96, 1.85),
    xlim     = c(0.5, 3.0),
    ticks_at = c(0.5, 1.0, 2.0, 3.0)
  )
  expect_true(inherits(out, "gtable"))
})

test_that("plot_forest with background = 'bold_label' produces a gtable", {
  skip_if_not_installed("forestploter")
  out <- plot_forest(
    .forest_df(),
    est        = c(NA, 1.52, 1.43),
    lower      = c(NA, 1.18, 1.11),
    upper      = c(NA, 1.96, 1.85),
    indent     = c(0L, 1L, 1L),
    background = "bold_label"
  )
  expect_true(inherits(out, "gtable"))
})

test_that("plot_forest with background = 'none' produces a gtable", {
  skip_if_not_installed("forestploter")
  out <- plot_forest(
    .forest_df(),
    est        = c(NA, 1.52, 1.43),
    lower      = c(NA, 1.18, 1.11),
    upper      = c(NA, 1.96, 1.85),
    background = "none"
  )
  expect_true(inherits(out, "gtable"))
})

test_that("plot_forest with border = 'none' produces a gtable", {
  skip_if_not_installed("forestploter")
  out <- plot_forest(
    .forest_df(),
    est    = c(NA, 1.52, 1.43),
    lower  = c(NA, 1.18, 1.11),
    upper  = c(NA, 1.96, 1.85),
    border = "none"
  )
  expect_true(inherits(out, "gtable"))
})

test_that("plot_forest NA rows in est/lower/upper do not draw CI (no error)", {
  skip_if_not_installed("forestploter")
  out <- plot_forest(
    .forest_df(),
    est   = c(NA, 1.52, 1.43),
    lower = c(NA, 1.18, 1.11),
    upper = c(NA, 1.96, 1.85)
  )
  expect_true(inherits(out, "gtable"))
})
