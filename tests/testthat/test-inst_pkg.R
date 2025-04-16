# 📦 Tests for `inst_pkg()` — Unified installer for CRAN, GitHub, Bioconductor, local

# ------------------------------------------------------------------------------
# ✅ Basic functionality: Skip if already installed
# ------------------------------------------------------------------------------

test_that("skips already installed CRAN package", {
  expect_invisible(inst_pkg("utils", source = "CRAN"))
})

# ------------------------------------------------------------------------------
# ✅ Source handling: case-insensitive and shorthand accepted
# ------------------------------------------------------------------------------

test_that("accepts valid sources and abbreviations", {
  # Should succeed because 'utils' is base R
  expect_invisible(inst_pkg("utils", source = "cran"))

  # Use real GitHub repo (won't re-install if already there)
  expect_invisible(inst_pkg("r-lib/cli", source = "gh"))

  # Use real Bioconductor package
  expect_invisible(inst_pkg("BiocGenerics", source = "bio"))
})

# ------------------------------------------------------------------------------
# ❌ Invalid source input
# ------------------------------------------------------------------------------

test_that("throws error for invalid source input", {
  expect_error(inst_pkg("dplyr", source = "invalid"), "Invalid source")
})

# ------------------------------------------------------------------------------
# ❌ Missing arguments
# ------------------------------------------------------------------------------

test_that("throws error when pkg is missing for non-local source", {
  expect_error(inst_pkg(source = "CRAN"), "provide a package name")
})

test_that("throws error when path is missing for local source", {
  expect_error(inst_pkg(source = "local"), "provide a local path")
})

# ------------------------------------------------------------------------------
# ✅ Allows local install without pkg (structure only)
# ------------------------------------------------------------------------------

test_that("local install runs without pkg when path is provided", {
  dummy_path <- tempfile(fileext = ".tar.gz")
  file.create(dummy_path)
  expect_invisible(inst_pkg(source = "local", path = dummy_path))
  unlink(dummy_path)
})

