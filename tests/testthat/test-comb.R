# test-comb.R
test_that("comb calculates correct combination counts", {
  expect_equal(comb(5, 2), 10)
  expect_equal(comb(8, 4), 70)
  expect_equal(comb(10, 0), 1)
  expect_equal(comb(0, 0), 1)
  expect_equal(comb(5, 6), 0)
  expect_equal(comb(6, 6), 1)
})

test_that("comb handles invalid input gracefully", {
  expect_error(comb(-1, 3), "non-negative")
  expect_error(comb(5, -2), "non-negative")
  expect_error(comb(4.5, 2), "integers")
  expect_error(comb(6, 2.2), "integers")
  expect_error(comb("a", 2), "numeric")
  expect_error(comb(5, "b"), "numeric")
  expect_error(comb(c(1,2), 2), "single")
  expect_error(comb(5, c(1,2)), "single")
})

test_that("comb returns Inf for large n", {
  expect_equal(comb(171, 1), Inf)
})
