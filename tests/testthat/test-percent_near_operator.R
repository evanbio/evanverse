# test-percent_near_operator.R

test_that("%near% works for numeric vectors within tolerance", {
  x <- c(1 / 49 * 49, sqrt(2)^2)
  y <- c(1, 2)
  expect_true(x %near% y)
})

test_that("%near% returns FALSE when values differ beyond tolerance", {
  x <- c(1, 2, 3)
  y <- c(1, 2, 3.01)
  expect_false(x %near% y)
})

test_that("%near% throws informative error on length mismatch", {
  expect_snapshot({
    try(c(1, 2, 3) %near% c(1, 2), silent = TRUE)
  })
})

test_that("%near% works for numeric matrices", {
  m1 <- matrix(c(1, 2.00000001, 3), nrow = 1)
  m2 <- matrix(c(1, 2, 3), nrow = 1)
  expect_true(m1 %near% m2)
})

test_that("%near% reports difference in matrix when values differ", {
  m1 <- matrix(c(1, 2, 3.1), nrow = 1)
  m2 <- matrix(c(1, 2, 3), nrow = 1)
  expect_false(m1 %near% m2)
})

test_that("%near% works for numeric data.frames", {
  df1 <- data.frame(a = c(1, 2.00000001), b = c(3, 4))
  df2 <- data.frame(a = c(1, 2), b = c(3, 4))
  expect_true(df1 %near% df2)
})

test_that("%near% reports value difference in data.frame columns", {
  df1 <- data.frame(a = c(1, 2), b = c(3, 4.01))
  df2 <- data.frame(a = c(1, 2), b = c(3, 4))
  expect_false(df1 %near% df2)
})

test_that("%near% warns on different column names in data.frame", {
  df1 <- data.frame(x = c(1, 2))
  df2 <- data.frame(y = c(1, 2))
  expect_snapshot({
    result <- try(df1 %near% df2, silent = TRUE)
    result
  })
})

test_that("%near% throws error on unsupported types (character)", {
  expect_snapshot({
    result <- try(c("a", "b") %near% c("a", "b"), silent = TRUE)
    result
  })
})

test_that("%near% respects custom tolerance parameter", {
  x <- c(1, 2, 3.01)
  y <- c(1, 2, 3)
  expect_true(`%near%`(x, y, tol = 0.02)) 
  expect_false(`%near%`(x, y, tol = 0.001)) 
})

