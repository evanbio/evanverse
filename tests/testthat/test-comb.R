#==============================================================================
# Test: comb()
# File: test-comb.R
# Description: Unit tests for comb() function
#==============================================================================

# ------------------------------------------------------------------------------
# Basic functionality tests
# ------------------------------------------------------------------------------
test_that("comb calculates correct combination counts", {
  expect_equal(comb(5, 2), 10)
  expect_equal(comb(8, 4), 70)
  expect_equal(comb(10, 0), 1)
  expect_equal(comb(0, 0), 1)
  expect_equal(comb(5, 6), 0)
  expect_equal(comb(6, 6), 1)
})

# ------------------------------------------------------------------------------
# Error handling tests
# ------------------------------------------------------------------------------
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

# ------------------------------------------------------------------------------
# Edge cases and large values tests
# ------------------------------------------------------------------------------
test_that("comb handles large n without overflow", {
  # With optimized calculation, large n should not return Inf immediately
  expect_true(is.finite(comb(171, 1)))
  expect_equal(comb(171, 1), 171)
})

test_that("comb handles symmetry correctly", {
  expect_equal(comb(10, 3), comb(10, 7))
  expect_equal(comb(15, 4), comb(15, 11))
})

test_that("comb handles small values", {
  expect_equal(comb(1, 0), 1)
  expect_equal(comb(1, 1), 1)
  expect_equal(comb(2, 1), 2)
})

