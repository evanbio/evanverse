# test-set_mirror.R
library(testthat)
library(cli)

test_that("CRAN mirror switches correctly", {
  set_mirror("cran", "tuna")
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.tuna.tsinghua.edu.cn/CRAN")
})

test_that("Bioconductor mirror switches correctly", {
  set_mirror("bioc", "bioc_ustc")
  expect_equal(getOption("BioC_mirror"),
               "https://mirrors.ustc.edu.cn/bioconductor")
})

test_that("Switching both CRAN and Bioconductor works", {
  set_mirror("all", "westlake")
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.westlake.edu.cn/CRAN")
  expect_equal(getOption("BioC_mirror"),
               "https://mirrors.westlake.edu.cn/CRAN") # all 默认同 URL
})

test_that("Custom URL works for CRAN", {
  custom_url <- "https://custom.example.com/CRAN"
  set_mirror("cran", custom_url)
  expect_equal(getOption("repos")[["CRAN"]], custom_url)
})

test_that("Output messages do not cause errors", {
  expect_message(set_mirror("cran", "rstudio"))
})

