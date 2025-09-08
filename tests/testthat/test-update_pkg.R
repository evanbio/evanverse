# Tests for update_pkg()
# -------------------------------------------------------------------
# Only input validation is tested on CRAN.
# Any network or installation behaviour is skipped entirely.

test_that("Throws error for invalid source", {
  expect_error(
    update_pkg(pkg = "dplyr", source = "unknown"),
    "Invalid source"
  )
})

test_that("Throws error if pkg is provided without source", {
  expect_error(
    update_pkg(pkg = "dplyr"),
    "Must provide 'source'"
  )
})

test_that("Throws error if GitHub source is used but pkg is missing", {
  expect_error(
    update_pkg(source = "GitHub"),
    "Must provide 'pkg'"
  )
})

# -------------------------------------------------------------------
# Network-related behaviour is not tested on CRAN,
# to avoid installation or update attempts.
# -------------------------------------------------------------------
