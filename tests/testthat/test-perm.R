#===============================================================================
# Test: perm
# File: test-perm.R
# Description: Tests for the perm function (Calculate permutations A(n,k))
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------
test_that("perm calculates correct permutation counts", {
  # Basic permutation calculations
  expect_equal(perm(5, 2), 20)
  expect_equal(perm(8, 4), 1680)
  expect_equal(perm(10, 0), 1L)  # k = 0 should return 1
  expect_equal(perm(0, 0), 1L)  # n = 0, k = 0 should return 1
  expect_equal(perm(5, 6), 0L)  # k > n should return 0
  expect_equal(perm(6, 6), 720) # k = n should return n!
})

#------------------------------------------------------------------------------
# Parameter validation
#------------------------------------------------------------------------------
test_that("perm validates n parameter", {
  # Test missing n
  expect_error(perm(), "'n' must be a single numeric value")

  # Test non-numeric n
  expect_error(perm("a", 2), "'n' must be a single numeric value")
  expect_error(perm(c(1, 2), 2), "'n' must be a single numeric value")

  # Test NA n
  expect_error(perm(NA, 2), "'n' must be a single numeric value")
})

test_that("perm validates k parameter", {
  # Test missing k
  expect_error(perm(5), "'k' must be a single numeric value")

  # Test non-numeric k
  expect_error(perm(5, "b"), "'k' must be a single numeric value")
  expect_error(perm(5, c(1, 2)), "'k' must be a single numeric value")

  # Test NA k
  expect_error(perm(5, NA), "'k' must be a single numeric value")
})

test_that("perm validates non-negative integers", {
  # Test negative values
  expect_error(perm(-1, 3), "'n' and 'k' must be non-negative")
  expect_error(perm(5, -2), "'n' and 'k' must be non-negative")

  # Test non-integer values
  expect_error(perm(4.5, 2), "'n' and 'k' must be integers")
  expect_error(perm(6, 2.2), "'n' and 'k' must be integers")
})

#------------------------------------------------------------------------------
# Edge cases and overflow handling
#------------------------------------------------------------------------------
#------------------------------------------------------------------------------
# Edge cases and overflow handling
#------------------------------------------------------------------------------
test_that("perm handles large n with warnings", {
  # Test warning for large n
  expect_message(perm(25, 5), "Large n")
  expect_equal(suppressWarnings(perm(25, 5)), 6375600)

  # Test very large n - should still work but may overflow
  expect_message(perm(171, 1), "Large n")
  expect_equal(suppressWarnings(perm(171, 1)), 171)
})
