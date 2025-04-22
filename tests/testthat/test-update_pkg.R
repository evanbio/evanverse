# 📦 Tests for `update_pkg()` — Unified R package updater
# -------------------------------------------------------------------
# These tests validate input logic, source handling, and function stability.
# Note: Updates are invoked in dry-mode when possible (non-blocking).
#       CRAN and GitHub tests are safe; Bioconductor may emit warnings.

test_that("Throws error for invalid source", {
  expect_error(
    update_pkg(pkg = "dplyr", source = "unknown"),
    "❌ Invalid source: unknown. Valid options: CRAN, GitHub, Bioconductor"
  )
})

test_that("Throws error if pkg is provided without source", {
  expect_error(
    update_pkg(pkg = "dplyr"),
    "❗ Must provide 'source' if 'pkg' is specified."
  )
})

test_that("Throws error if GitHub source is used but pkg is missing", {
  expect_error(
    update_pkg(source = "GitHub"),
    "❗ Must provide 'pkg' when updating GitHub packages."
  )
})

test_that("CRAN package update runs without error (dry mode)", {
  expect_invisible(update_pkg(pkg = "Matrix", source = "CRAN"))
})

test_that("GitHub package update runs without error (dry mode)", {
  expect_invisible(update_pkg(pkg = "r-lib/devtools", source = "GitHub"))
})

# ⚠ Bioconductor-related tests may generate version or update warnings.
# We wrap in `suppressWarnings()` and allow execution to continue.
test_that("Single Bioconductor package update runs (dry mode)", {
  expect_invisible(
    suppressWarnings(
      update_pkg(pkg = "limma", source = "Bioconductor")
    )
  )
})

# test_that("Update all Bioconductor packages runs without fatal error", {
#   expect_invisible(
#     suppressWarnings(
#       update_pkg(source = "Bioconductor")
#     )
#   )
# })

