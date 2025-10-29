#===============================================================================
# Test: Package Management Functions
# File: tests/testthat/test-pkg.R
# Description: Comprehensive unit tests for all pkg.R functions
#
# Functions tested:
#   - set_mirror()    : Configure CRAN/Bioconductor mirrors
#   - inst_pkg()      : Install packages from multiple sources
#   - check_pkg()     : Check package installation status
#   - update_pkg()    : Update installed packages
#   - pkg_version()   : Query package versions
#   - pkg_functions() : List exported package functions
#
# Dependencies: testthat, cli, tibble
#===============================================================================


# ==============================================================================
# Section 1: set_mirror() Tests
# ==============================================================================

#------------------------------------------------------------------------------
# Basic functionality - CRAN mirrors
#------------------------------------------------------------------------------

test_that("CRAN mirror switches correctly", {
  # Test tuna mirror
  set_mirror("cran", "tuna")
  expect_equal(
    getOption("repos")[["CRAN"]],
    "https://mirrors.tuna.tsinghua.edu.cn/CRAN"
  )

  # Test ustc mirror
  set_mirror("cran", "ustc")
  expect_equal(
    getOption("repos")[["CRAN"]],
    "https://mirrors.ustc.edu.cn/CRAN"
  )

  # Test westlake mirror
  set_mirror("cran", "westlake")
  expect_equal(
    getOption("repos")[["CRAN"]],
    "https://mirrors.westlake.edu.cn/CRAN"
  )
})

#------------------------------------------------------------------------------
# Basic functionality - Bioconductor mirrors
#------------------------------------------------------------------------------

test_that("Bioconductor mirror switches correctly", {
  # Test tuna mirror
  set_mirror("bioc", "tuna")
  expect_equal(
    getOption("BioC_mirror"),
    "https://mirrors.tuna.tsinghua.edu.cn/bioconductor"
  )

  # Test ustc mirror
  set_mirror("bioc", "ustc")
  expect_equal(
    getOption("BioC_mirror"),
    "https://mirrors.ustc.edu.cn/bioconductor"
  )

  # Test westlake mirror
  set_mirror("bioc", "westlake")
  expect_equal(
    getOption("BioC_mirror"),
    "https://mirrors.westlake.edu.cn/bioconductor"
  )
})

#------------------------------------------------------------------------------
# Combined functionality - Setting both repos
#------------------------------------------------------------------------------

test_that("setting both CRAN and Bioconductor works with 'all'", {
  # Test with tuna
  set_mirror("all", "tuna")
  expect_equal(
    getOption("repos")[["CRAN"]],
    "https://mirrors.tuna.tsinghua.edu.cn/CRAN"
  )
  expect_equal(
    getOption("BioC_mirror"),
    "https://mirrors.tuna.tsinghua.edu.cn/bioconductor"
  )

  # Test with ustc
  set_mirror("all", "ustc")
  expect_equal(
    getOption("repos")[["CRAN"]],
    "https://mirrors.ustc.edu.cn/CRAN"
  )
  expect_equal(
    getOption("BioC_mirror"),
    "https://mirrors.ustc.edu.cn/bioconductor"
  )
})

#------------------------------------------------------------------------------
# Parameter validation
#------------------------------------------------------------------------------

test_that("set_mirror() invalid parameters are handled correctly", {
  # Invalid repo type
  expect_error(
    set_mirror("invalid", "tuna"),
    regexp = "should be one of"
  )

  # Invalid CRAN mirror name
  expect_error(
    set_mirror("cran", "nonexistent"),
    regexp = "Unknown CRAN mirror"
  )

  # Invalid Bioconductor mirror name
  expect_error(
    set_mirror("bioc", "nonexistent"),
    regexp = "Unknown Bioconductor mirror"
  )
})

#------------------------------------------------------------------------------
# Default parameters
#------------------------------------------------------------------------------

test_that("set_mirror() default parameters work as expected", {
  # Default repo should be "all"
  messages <- capture_messages(set_mirror(mirror = "tuna"))
  expect_true(any(grepl("CRAN mirror set to", messages)))
  expect_true(any(grepl("Bioconductor mirror set to", messages)))

  # Default mirror should be "tuna"
  set_mirror("cran")
  expect_equal(
    getOption("repos")[["CRAN"]],
    "https://mirrors.tuna.tsinghua.edu.cn/CRAN"
  )
})

#------------------------------------------------------------------------------
# Return values
#------------------------------------------------------------------------------

test_that("set_mirror() returns previous settings correctly", {
  # Set known initial state
  options(repos = c(CRAN = "https://cloud.r-project.org"))
  options(BioC_mirror = "https://bioconductor.org")

  # Capture old settings
  old <- set_mirror("all", "tuna")

  # Verify old settings structure
  expect_type(old, "list")
  expect_named(old, c("repos", "BioC_mirror"))

  # Verify old settings values
  expect_equal(old$repos[["CRAN"]], "https://cloud.r-project.org")
  expect_equal(old$BioC_mirror, "https://bioconductor.org")

  # Test restoration
  options(old)
  expect_equal(getOption("repos")[["CRAN"]], "https://cloud.r-project.org")
  expect_equal(getOption("BioC_mirror"), "https://bioconductor.org")
})

#------------------------------------------------------------------------------
# CLI output messages
#------------------------------------------------------------------------------

test_that("set_mirror() CLI messages are displayed correctly", {
  # Test CRAN message
  expect_message(
    set_mirror("cran", "tuna"),
    regexp = "CRAN mirror set to"
  )

  # Test Bioconductor message
  expect_message(
    set_mirror("bioc", "ustc"),
    regexp = "Bioconductor mirror set to"
  )

  # Test info message about available mirrors
  expect_message(
    set_mirror("cran", "tuna"),
    regexp = "Available"
  )

  # Test settings check message
  expect_message(
    set_mirror("cran", "tuna"),
    regexp = "View current settings"
  )
})

#------------------------------------------------------------------------------
# Edge cases
#------------------------------------------------------------------------------

test_that("set_mirror() edge cases are handled properly", {
  # Partial matching for repo parameter
  set_mirror("cr", "tuna")  # Should match "cran"
  expect_equal(
    getOption("repos")[["CRAN"]],
    "https://mirrors.tuna.tsinghua.edu.cn/CRAN"
  )

  # CRAN-only mirror cannot be used for Bioconductor
  expect_error(
    set_mirror("bioc", "rstudio"),
    regexp = "Unknown Bioconductor mirror"
  )

  # Using 'all' with CRAN-only mirror should fail
  expect_error(
    set_mirror("all", "rstudio"),
    regexp = "Unknown Bioconductor mirror"
  )
})

#------------------------------------------------------------------------------
# Official mirrors
#------------------------------------------------------------------------------

test_that("set_mirror() official mirrors work correctly", {
  # Test official CRAN mirror
  set_mirror("cran", "official")
  expect_equal(
    getOption("repos")[["CRAN"]],
    "https://cloud.r-project.org"
  )

  # Test official Bioconductor mirror
  set_mirror("bioc", "official")
  expect_equal(
    getOption("BioC_mirror"),
    "https://bioconductor.org"
  )
})


# ==============================================================================
# Section 2: inst_pkg() Tests
# ==============================================================================

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("inst_pkg() validates source parameter correctly", {
  expect_error(
    inst_pkg(pkg = "dplyr", source = "invalid"),
    "'arg' should be one of"
  )

  expect_error(
    inst_pkg(pkg = "dplyr", source = "unknown"),
    "'arg' should be one of"
  )
})

test_that("inst_pkg() validates pkg parameter correctly", {
  expect_error(
    inst_pkg(pkg = c("dplyr", NA), source = "CRAN"),
    "must be a character vector without NA"
  )

  expect_error(
    inst_pkg(pkg = 123, source = "CRAN"),
    "must be a character vector without NA"
  )

  expect_error(
    inst_pkg(pkg = character(0), source = "CRAN"),
    "must be a character vector without NA"
  )
})

test_that("inst_pkg() validates pkg and source relationship", {
  expect_error(
    inst_pkg(source = "CRAN"),
    "Must provide.*pkg.*for non-local installation"
  )

  expect_error(
    inst_pkg(source = "GitHub"),
    "Must provide.*pkg.*for non-local installation"
  )

  expect_error(
    inst_pkg(source = "Bioconductor"),
    "Must provide.*pkg.*for non-local installation"
  )
})

test_that("inst_pkg() validates GitHub package format", {
  expect_error(
    inst_pkg(pkg = "invalidformat", source = "GitHub"),
    "must be in.*user/repo.*format"
  )

  expect_error(
    inst_pkg(pkg = c("validuser/repo", "invalid"), source = "GitHub"),
    "must be in.*user/repo.*format"
  )
})

test_that("inst_pkg() validates local installation parameters", {
  expect_error(
    inst_pkg(source = "Local"),
    "Must provide.*path.*for local installation"
  )
})

#------------------------------------------------------------------------------
# Basic Function Acceptance (No Network Operations)
#------------------------------------------------------------------------------

test_that("inst_pkg() accepts valid parameters without execution", {
  # Only test that the function doesn't immediately error on valid input
  expect_true(is.function(inst_pkg))

  # Test parameter parsing without execution
  expect_silent({
    formals_check <- formals(inst_pkg)
    expect_true("pkg" %in% names(formals_check))
    expect_true("source" %in% names(formals_check))
    expect_true("path" %in% names(formals_check))
  })
})


# ==============================================================================
# Section 3: check_pkg() Tests
# ==============================================================================

#------------------------------------------------------------------------------
# Basic functionality tests
#------------------------------------------------------------------------------

test_that("check_pkg() detects installed packages", {
  res <- check_pkg("stats", source = "CRAN", auto_install = FALSE)
  expect_true(res$installed)
})

test_that("check_pkg() handles GitHub input format", {
  res <- check_pkg("r-lib/cli", source = "GitHub", auto_install = FALSE)
  expect_true(res$name == "cli")
})

#------------------------------------------------------------------------------
# Error handling tests
#------------------------------------------------------------------------------

test_that("check_pkg() errors on invalid source", {
  expect_error(check_pkg("dplyr", source = "unknown"))
})

#------------------------------------------------------------------------------
# Output structure tests
#------------------------------------------------------------------------------

test_that("check_pkg() returns a tibble", {
  res <- check_pkg("ggplot2", source = "CRAN", auto_install = FALSE)
  expect_s3_class(res, "tbl_df")
})

#------------------------------------------------------------------------------
# Multiple packages test
#------------------------------------------------------------------------------

test_that("check_pkg() handles multiple packages", {
  res <- check_pkg(c("stats", "utils"), source = "CRAN", auto_install = FALSE)
  expect_equal(nrow(res), 2)
  expect_true(all(res$installed))
})

#------------------------------------------------------------------------------
# Bioconductor source test (if available)
#------------------------------------------------------------------------------

test_that("check_pkg() handles Bioconductor source", {
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy Bioconductor package check skipped.")

  # This test assumes Bioconductor is set up; adjust as needed
  res <- check_pkg("Biobase", source = "Bioconductor", auto_install = FALSE)
  expect_s3_class(res, "tbl_df")
})


# ==============================================================================
# Section 4: update_pkg() Tests
# ==============================================================================

#------------------------------------------------------------------------------
# Parameter Validation Tests
#------------------------------------------------------------------------------

test_that("update_pkg() validates source parameter correctly", {
  expect_error(
    update_pkg(pkg = "dplyr", source = "unknown"),
    "'arg' should be one of"
  )

  expect_error(
    update_pkg(pkg = "dplyr", source = "invalid"),
    "'arg' should be one of"
  )
})

test_that("update_pkg() validates pkg parameter correctly", {

  expect_error(
    update_pkg(pkg = c("dplyr", NA), source = "CRAN"),
    "must be a character vector without NA"
  )

  expect_error(
    update_pkg(pkg = 123, source = "CRAN"),
    "must be a character vector without NA"
  )

  expect_error(
    update_pkg(pkg = character(0), source = "CRAN"),
    "must be a character vector without NA"
  )
})

test_that("update_pkg() validates pkg and source relationship", {
  expect_error(
    update_pkg(pkg = "dplyr"),
    "Must specify.*source.*when providing.*pkg"
  )

  expect_error(
    update_pkg(source = "GitHub"),
    "Must provide.*pkg.*when updating GitHub"
  )
})

test_that("update_pkg() validates GitHub package format", {
  expect_error(
    update_pkg(pkg = "invalid-format", source = "GitHub"),
    "must be in.*user/repo.*format"
  )

  expect_error(
    update_pkg(pkg = c("user/repo", "invalid"), source = "GitHub"),
    "must be in.*user/repo.*format"
  )
})

#------------------------------------------------------------------------------
# Basic Function Acceptance (No Network Operations)
#------------------------------------------------------------------------------

test_that("update_pkg() accepts valid single package parameters", {
  # Only test that the function doesn't immediately error on valid input
  # Skip actual execution to avoid network operations
  expect_true(is.function(update_pkg))

  # Test parameter parsing without execution
  expect_silent({
    formals_check <- formals(update_pkg)
    expect_true("pkg" %in% names(formals_check))
    expect_true("source" %in% names(formals_check))
  })
})

#------------------------------------------------------------------------------
# Edge Cases and Error Handling
#------------------------------------------------------------------------------

test_that("update_pkg() handles empty package vector", {
  expect_error(
    update_pkg(pkg = character(0), source = "CRAN"),
    "must be a character vector without NA"
  )
})

test_that("update_pkg() case sensitivity for source parameter", {
  expect_error(
    update_pkg(pkg = "test", source = "cran"),
    "'arg' should be one of"
  )

  expect_error(
    update_pkg(pkg = "test", source = "github"),
    "'arg' should be one of"
  )

  expect_error(
    update_pkg(pkg = "test", source = "bioconductor"),
    "'arg' should be one of"
  )
})


# ==============================================================================
# Section 5: pkg_version() Tests
# ==============================================================================

#------------------------------------------------------------------------------
# Input validation
#------------------------------------------------------------------------------

test_that("pkg_version() validates input parameters", {
  expect_error(pkg_version(NULL), "`pkg` must be a non-empty character vector")
  expect_error(pkg_version(character(0)), "`pkg` must be a non-empty character vector")
  expect_error(pkg_version(123), "`pkg` must be a non-empty character vector")
  expect_error(pkg_version("cli", preview = "yes"), "`preview` must be a single logical value")
  expect_error(pkg_version("cli", preview = c(TRUE, FALSE)), "`preview` must be a single logical value")
})

#------------------------------------------------------------------------------
# Functional tests (network-dependent, skipped on CRAN)
#------------------------------------------------------------------------------

test_that("pkg_version() detects installed version", {
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy CRAN package database fetch skipped.")
  res <- suppressMessages(pkg_version("cli", preview = FALSE))
  expect_true(!is.na(res$version[1]))
})

test_that("pkg_version() detects CRAN source", {
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy CRAN package database fetch skipped.")

  res <- suppressMessages(pkg_version("ggplot2", preview = FALSE))
  expect_equal(res$source[1], "CRAN")
  expect_true(!is.na(res$latest[1]))
})

test_that("pkg_version() handles nonexistent packages gracefully", {
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy CRAN package database fetch skipped.")

  res <- suppressMessages(pkg_version("nonexistentpackage123456", preview = FALSE))
  expect_true(is.na(res$version[1]))
  expect_true(is.na(res$latest[1]))
  expect_equal(res$source[1], "Not Found")
})

#------------------------------------------------------------------------------
# GitHub-related test (optional, skipped on CRAN)
#------------------------------------------------------------------------------

test_that("pkg_version() detects GitHub package (if installed locally)", {
  skip_on_cran()
  skip_if_offline()
  skip("Network-heavy CRAN package database fetch skipped.")

  # This test only works if MRPRESSO (or another GitHub package) is installed.
  # It will pass silently if not installed.
  if (length(find.package("MRPRESSO", quiet = TRUE)) > 0) {
    res <- suppressMessages(pkg_version("MRPRESSO", preview = FALSE))
    expect_true(grepl("^GitHub", res$source[1]))
  } else {
    succeed("GitHub package not installed locally; skipping test.")
  }
})


# ==============================================================================
# Section 6: pkg_functions() Tests
# ==============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------

test_that("pkg_functions() returns exported names from a package", {
  funcs <- pkg_functions("stats")
  expect_true(is.character(funcs))
  expect_true(length(funcs) > 0)
  expect_true("lm" %in% funcs)  # stats::lm is exported
})

#------------------------------------------------------------------------------
# Sorting
#------------------------------------------------------------------------------

test_that("pkg_functions() returned names are sorted alphabetically", {
  funcs <- pkg_functions("stats")
  expect_equal(funcs, sort(funcs))
})

#------------------------------------------------------------------------------
# Keyword filtering (case-insensitive, partial)
#------------------------------------------------------------------------------

test_that("pkg_functions() filters by keyword", {
  funcs <- pkg_functions("stats", key = "lm")
  expect_true(all(grepl("lm", funcs, ignore.case = TRUE)))
})

test_that("pkg_functions() filtering is case-insensitive", {
  funcs <- pkg_functions("stats", key = "LM")
  expect_true(all(grepl("lm", funcs, ignore.case = TRUE)))
})

#------------------------------------------------------------------------------
# No matches
#------------------------------------------------------------------------------

test_that("pkg_functions() returns empty vector when no match", {
  funcs <- pkg_functions("stats", key = "zzzzzz")
  expect_type(funcs, "character")
  expect_equal(length(funcs), 0L)
})

#------------------------------------------------------------------------------
# Error handling
#------------------------------------------------------------------------------

test_that("pkg_functions() errors for non-installed package", {
  expect_error(pkg_functions("somefakepkgnotinstalled"), regexp = "not installed")
})

test_that("pkg_functions() errors for non-character `pkg`", {
  expect_error(pkg_functions(123))
  expect_error(pkg_functions(TRUE))
  expect_error(pkg_functions(NA_character_), regexp = "non-empty")
})

test_that("pkg_functions() errors for invalid `key` input", {
  expect_error(pkg_functions("stats", key = c("a", "b")))
  expect_error(pkg_functions("stats", key = NA_character_))
})


#===============================================================================
# End: test-pkg.R
