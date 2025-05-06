# test-pkg_functions.R

test_that("pkg_functions() returns all functions from a package", {
  funcs <- pkg_functions("stats")
  expect_true(is.character(funcs))
  expect_true("lm" %in% funcs)
})

test_that("pkg_functions() filters by keyword", {
  funcs <- pkg_functions("stats", key = "lm")
  expect_true(all(grepl("lm", funcs, ignore.case = TRUE)))
})

test_that("pkg_functions() returns empty vector when no match", {
  funcs <- pkg_functions("stats", key = "zzzzzz")
  expect_equal(length(funcs), 0)
})

test_that("pkg_functions() errors for non-installed package", {
  expect_error(pkg_functions("somefakepkgnotinstalled"))
})

test_that("pkg_functions() errors for non-character input", {
  expect_error(pkg_functions(123))
  expect_error(pkg_functions(TRUE))
})


