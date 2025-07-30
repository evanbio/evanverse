# test-perm.R
test_that("perm calculates correct permutation counts", {
  expect_equal(perm(5, 2), 20)
  expect_equal(perm(8, 4), 1680)
  expect_equal(perm(10, 0), 1)
  expect_equal(perm(0, 0), 1)
  expect_equal(perm(5, 6), 0)
  expect_equal(perm(6, 6), 720)
})

test_that("perm handles invalid input gracefully", {
  expect_error(perm(-1, 3), "non-negative")
  expect_error(perm(5, -2), "non-negative")
  expect_error(perm(4.5, 2), "integers")
  expect_error(perm(6, 2.2), "integers")
  expect_error(perm("a", 2), "numeric")
  expect_error(perm(5, "b"), "numeric")
  expect_error(perm(c(1,2), 2), "single")
  expect_error(perm(5, c(1,2)), "single")
})

test_that("perm returns Inf for large n", {
  expect_equal(perm(171, 1), Inf)
})
