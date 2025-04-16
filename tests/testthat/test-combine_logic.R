# tests/testthat/test-combine_logic.R
# 📌 Tests for `combine_logic()` — Flexible logical combiner

test_that("works for simple logical vectors", {
  x <- c(TRUE, FALSE, TRUE)
  y <- c(TRUE, TRUE, FALSE)

  expect_equal(combine_logic(x, y), c(TRUE, FALSE, FALSE))
  expect_equal(combine_logic(x, y, op = "|"), c(TRUE, TRUE, TRUE))
})

test_that("works with more than two conditions", {
  a <- c(TRUE, FALSE, TRUE)
  b <- c(TRUE, TRUE, FALSE)
  c <- c(TRUE, FALSE, FALSE)

  expect_equal(combine_logic(a, b, c), c(TRUE, FALSE, FALSE))
  expect_equal(combine_logic(a, b, c, op = "|"), c(TRUE, TRUE, TRUE))
})

test_that("returns NA if any NA present (na.rm = FALSE)", {
  x <- c(TRUE, NA, FALSE)
  y <- c(TRUE, TRUE, FALSE)

  expect_equal(combine_logic(x, y), c(TRUE, NA, FALSE))
})

test_that("removes NA if na.rm = TRUE", {
  x <- c(TRUE, NA, FALSE)
  y <- c(TRUE, TRUE, FALSE)

  expect_equal(combine_logic(x, y, na.rm = TRUE), c(TRUE, TRUE, FALSE))
})

test_that("fails for length mismatch", {
  expect_error(combine_logic(c(TRUE, FALSE), c(TRUE, TRUE, FALSE)),
               "All logical vectors must be the same length.")
})

test_that("fails for invalid operator", {
  expect_error(combine_logic(c(TRUE, FALSE), op = "&&&"),
               "Unsupported operator")
})

combine_logic(1:5 > 2, 1:5 < 5)
