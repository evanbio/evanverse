#===============================================================================
# 📦 Test: plot_pie()
# 📁 File: test-plot_pie.R
# 🔍 Description: Unit tests for the plot_pie() function
#===============================================================================

#------------------------------------------------------------------------------
# 🧪 Input Validation
#------------------------------------------------------------------------------

test_that("plot_pie() works with character vector input", {
  vec <- c("A", "A", "B", "C", "C", "C")
  expect_silent(p <- plot_pie(vec, preview = FALSE))
  expect_s3_class(p, "gg")
})

test_that("plot_pie() works with data.frame input", {
  df <- data.frame(group = c("A", "B", "C"), count = c(10, 20, 30))
  expect_silent(p <- plot_pie(df, group_col = "group", count_col = "count", preview = FALSE))
  expect_s3_class(p, "gg")
})

#------------------------------------------------------------------------------
# 🏷️ Label Parameter
#------------------------------------------------------------------------------

test_that("plot_pie() handles different label types", {
  df <- data.frame(group = c("X", "Y", "Z"), count = c(10, 20, 30))
  for (lbl in c("none", "count", "percent", "both")) {
    expect_silent(p <- plot_pie(df, label = lbl, preview = FALSE))
    expect_s3_class(p, "gg")
  }
})

#------------------------------------------------------------------------------
# 📦 Return Values
#------------------------------------------------------------------------------

test_that("plot_pie() returns both plot and data when return_data = TRUE", {
  df <- data.frame(group = c("A", "B"), count = c(1, 2))
  out <- plot_pie(df, return_data = TRUE, preview = FALSE)

  expect_type(out, "list")
  expect_named(out, c("plot", "data"))
  expect_s3_class(out$plot, "gg")
  expect_s3_class(out$data, "data.frame")
  expect_true(all(c("group", "count", "percent", "label_text") %in% colnames(out$data)))
})

#------------------------------------------------------------------------------
# ❌ Error Handling
#------------------------------------------------------------------------------

test_that("plot_pie() throws error for invalid input", {
  expect_error(plot_pie(1234), "at least two unique groups")

  bad_df <- data.frame(a = 1:3)
  expect_error(plot_pie(bad_df, group_col = "a", count_col = "b"))
})

