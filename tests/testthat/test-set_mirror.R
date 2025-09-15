#===============================================================================
# Test: set_mirror()
# File: tests/testthat/test-set_mirror.R
# Description: Unit tests for the `set_mirror()` function
# Dependencies: testthat, cli
#===============================================================================

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

test_that("invalid parameters are handled correctly", {
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

test_that("default parameters work as expected", {
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

test_that("function returns previous settings correctly", {
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

test_that("CLI messages are displayed correctly", {
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

test_that("edge cases are handled properly", {
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

test_that("official mirrors work correctly", {
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
