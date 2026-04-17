#===============================================================================
# Test: pkg.R public functions
# File: test-pkg.R
# Description: Unit tests for set_mirror(), pkg_functions()
#===============================================================================

#==============================================================================
# set_mirror()
#==============================================================================

test_that("set_mirror() sets CRAN mirror correctly", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org")))

  set_mirror("cran", "tuna")
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.tuna.tsinghua.edu.cn/CRAN")

  set_mirror("cran", "ustc")
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.ustc.edu.cn/CRAN")

  set_mirror("cran", "westlake")
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.westlake.edu.cn/CRAN")
})

test_that("set_mirror() sets Bioconductor mirror correctly", {
  skip_on_cran()
  withr::local_options(list(BioC_mirror = "https://bioconductor.org"))

  set_mirror("bioc", "tuna")
  expect_equal(getOption("BioC_mirror"),
               "https://mirrors.tuna.tsinghua.edu.cn/bioconductor")

  set_mirror("bioc", "ustc")
  expect_equal(getOption("BioC_mirror"),
               "https://mirrors.ustc.edu.cn/bioconductor")
})

test_that("set_mirror() sets both mirrors with repo = 'all'", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org"),
                            BioC_mirror = "https://bioconductor.org"))

  set_mirror("all", "tuna")
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.tuna.tsinghua.edu.cn/CRAN")
  expect_equal(getOption("BioC_mirror"),
               "https://mirrors.tuna.tsinghua.edu.cn/bioconductor")
})

test_that("set_mirror() defaults to repo = 'all' and mirror = 'tuna'", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org"),
                            BioC_mirror = "https://bioconductor.org"))

  set_mirror()
  expect_equal(getOption("repos")[["CRAN"]],
               "https://mirrors.tuna.tsinghua.edu.cn/CRAN")
  expect_equal(getOption("BioC_mirror"),
               "https://mirrors.tuna.tsinghua.edu.cn/bioconductor")
})

test_that("set_mirror() returns previous settings invisibly", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org"),
                            BioC_mirror = "https://bioconductor.org"))

  prev <- set_mirror("all", "tuna")
  expect_type(prev, "list")
  expect_named(prev, c("repos", "BioC_mirror"))
  expect_equal(prev$repos[["CRAN"]], "https://cloud.r-project.org")
  expect_equal(prev$BioC_mirror, "https://bioconductor.org")
})

test_that("set_mirror() official mirrors set correct URLs", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org"),
                            BioC_mirror = "https://bioconductor.org"))

  set_mirror("cran", "official")
  expect_equal(getOption("repos")[["CRAN"]], "https://cloud.r-project.org")

  set_mirror("bioc", "official")
  expect_equal(getOption("BioC_mirror"), "https://bioconductor.org")
})

test_that("set_mirror() emits CLI messages", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org"),
                            BioC_mirror = "https://bioconductor.org"))

  expect_message(set_mirror("cran", "tuna"), "CRAN mirror set to")
  expect_message(set_mirror("bioc", "ustc"), "Bioconductor mirror set to")
})

test_that("set_mirror() errors on invalid repo", {
  expect_error(set_mirror("invalid", "tuna"), "should be one of")
})

test_that("set_mirror() errors on unknown CRAN mirror", {
  expect_error(set_mirror("cran", "nonexistent"), "Unknown CRAN mirror")
})

test_that("set_mirror() errors on unknown Bioconductor mirror", {
  expect_error(set_mirror("bioc", "nonexistent"), "Unknown Bioconductor mirror")
})

test_that("set_mirror() errors when CRAN-only mirror used for bioc", {
  expect_error(set_mirror("bioc", "rstudio"), "Unknown Bioconductor mirror")
})

test_that("set_mirror() errors when CRAN-only mirror used for all", {
  expect_error(set_mirror("all", "rstudio"), "CRAN-only")
  expect_error(set_mirror("all", "aliyun"), "CRAN-only")
})

test_that("set_mirror() errors on completely unknown mirror with all", {
  expect_error(set_mirror("all", "nonexistent"), "Unknown mirror")
})

test_that("set_mirror() preserves non-CRAN repo entries when setting CRAN mirror", {
  skip_on_cran()
  withr::local_options(list(repos = c(CRAN = "https://cloud.r-project.org",
                                      RSPM = "https://packagemanager.posit.co/cran/latest")))

  set_mirror("cran", "tuna")
  repos <- getOption("repos")
  expect_equal(repos[["CRAN"]], "https://mirrors.tuna.tsinghua.edu.cn/CRAN")
  expect_equal(repos[["RSPM"]], "https://packagemanager.posit.co/cran/latest")
})

test_that("set_mirror() creates CRAN repo entry when repos option is NULL", {
  skip_on_cran()
  withr::local_options(list(repos = NULL))

  set_mirror("cran", "official")
  expect_equal(getOption("repos"), c(CRAN = "https://cloud.r-project.org"))
})

#==============================================================================
# pkg_functions()
#==============================================================================

test_that("pkg_functions() returns sorted character vector of exports", {
  funcs <- pkg_functions("stats")
  expect_type(funcs, "character")
  expect_true(length(funcs) > 0L)
  expect_equal(funcs, sort(funcs))
  expect_true("lm" %in% funcs)
  expect_visible(funcs)
})

test_that("pkg_functions() filters by keyword case-insensitively", {
  lower <- pkg_functions("stats", key = "lm")
  upper <- pkg_functions("stats", key = "LM")

  expect_true(all(grepl("lm", lower, ignore.case = TRUE)))
  expect_true(length(lower) > 0L)
  expect_equal(lower, upper)
})

test_that("pkg_functions() returns empty vector when keyword has no match", {
  funcs <- pkg_functions("stats", key = "zzzzzz")
  expect_type(funcs, "character")
  expect_length(funcs, 0L)
})

test_that("pkg_functions() errors for uninstalled package", {
  expect_error(pkg_functions("somefakepkg_notinstalled"), "not installed")
})

test_that("pkg_functions() validates pkg argument", {
  expect_error(pkg_functions(123),           "single non-empty string")
  expect_error(pkg_functions(""),            "single non-empty string")
  expect_error(pkg_functions(NA_character_), "single non-empty string")
  expect_error(pkg_functions(c("a", "b")),   "single non-empty string")
})

test_that("pkg_functions() validates key argument", {
  expect_error(pkg_functions("stats", key = c("a", "b")),    "single non-empty string")
  expect_error(pkg_functions("stats", key = NA_character_),  "single non-empty string")
  expect_error(pkg_functions("stats", key = ""),             "single non-empty string")
})

