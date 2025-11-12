# Contributing to evanverse

Thank you for considering contributing to **evanverse**! This document
provides guidelines for contributing to the package.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [How Can I Contribute?](#how-can-i-contribute)
- [Development Setup](#development-setup)
- [Pull Request Process](#pull-request-process)
- [Coding Standards](#coding-standards)
- [Testing Guidelines](#testing-guidelines)
- [Documentation](#documentation)
- [CRAN Compliance](#cran-compliance)

------------------------------------------------------------------------

## Code of Conduct

This project follows the [Contributor Covenant Code of
Conduct](https://www.contributor-covenant.org/version/2/1/code_of_conduct/).
By participating, you are expected to uphold this code. Please report
unacceptable behavior to <evanzhou.bio@gmail.com>.

------------------------------------------------------------------------

## How Can I Contribute?

### Reporting Bugs

Before creating bug reports, please check the [issue
tracker](https://github.com/evanbio/evanverse/issues) to avoid
duplicates.

When filing a bug report, include:

- **Clear title and description**

- **Reproducible example** using `reprex::reprex()`

- **Environment details**:

  ``` r
  sessionInfo()
  packageVersion("evanverse")
  ```

- **Expected vs. actual behavior**

### Suggesting Enhancements

Enhancement suggestions are tracked as [GitHub
issues](https://github.com/evanbio/evanverse/issues).

When suggesting enhancements, include:

- **Use case description**
- **Proposed API design** (if applicable)
- **Examples** of how it would work
- **Alternative solutions** you’ve considered

### Contributing Code

1.  **Fork the repository** and create a feature branch from `dev`
2.  **Make your changes** following our coding standards
3.  **Add tests** for new functionality
4.  **Update documentation** (roxygen2 comments, vignettes if needed)
5.  **Run R CMD check** to ensure CRAN compliance
6.  **Submit a pull request** to the `dev` branch

------------------------------------------------------------------------

## Development Setup

### Prerequisites

- **R** (\>= 4.1.0)
- **RStudio** (recommended)
- **Git**

### Setup Instructions

``` r
# 1. Clone your fork
git clone https://github.com/YOUR-USERNAME/evanverse.git
cd evanverse

# 2. Install development dependencies
install.packages("devtools")
devtools::install_dev_deps()

# 3. Load the package for development
devtools::load_all()

# 4. Run tests
devtools::test()

# 5. Run R CMD check
devtools::check()
```

### Development Workflow

``` r
# Load package during development
devtools::load_all()

# Run specific tests
devtools::test_active_file()

# Update documentation
devtools::document()

# Check package
devtools::check()
```

------------------------------------------------------------------------

## Pull Request Process

### Branch Strategy

- **`main`**: Stable, CRAN-released code
- **`dev`**: Development branch (target for PRs)
- **Feature branches**: `feature/your-feature-name`
- **Bug fixes**: `fix/issue-description`

### PR Checklist

Before submitting a pull request, ensure:

Code follows the [tidyverse style guide](https://style.tidyverse.org/)

All tests pass
([`devtools::test()`](https://devtools.r-lib.org/reference/test.html))

R CMD check passes with 0 errors, 0 warnings, 0 notes
([`devtools::check()`](https://devtools.r-lib.org/reference/check.html))

New functions have roxygen2 documentation

New functions have corresponding tests

`NEWS.md` updated (if applicable)

Examples in documentation are executable

CI/CD checks pass on GitHub Actions

### Commit Messages

We follow the [Conventional
Commits](https://www.conventionalcommits.org/) specification with
emojis:

    <emoji> <type>: <description>

    [optional body]

**Types:** - `feat` ✨ - New feature - `fix` 🐛 - Bug fix - `docs` 📝 -
Documentation changes - `style` 💄 - Code style/formatting - `refactor`
♻️ - Code refactoring - `test` ✅ - Adding/updating tests - `chore` 🔧 -
Maintenance tasks - `ci` 🚀 - CI/CD changes - `perf` ⚡ - Performance
improvements

**Examples:**

    ✨ feat: add new color palette for single-cell data
    🐛 fix: handle NA values in plot_venn correctly
    📝 docs: update installation instructions for CRAN

------------------------------------------------------------------------

## Coding Standards

### Style Guide

Follow the [tidyverse style guide](https://style.tidyverse.org/):

``` r
# Good
calculate_mean <- function(x, na.rm = TRUE) {
  if (!is.numeric(x)) {
    stop("`x` must be numeric")
  }
  mean(x, na.rm = na.rm)
}

# Bad
calculateMean<-function(x,na.rm=TRUE){
if(!is.numeric(x)){stop("`x` must be numeric")}
mean(x,na.rm=na.rm)}
```

### Function Design

- **Use descriptive names** (verbs for functions, nouns for objects)
- **Validate inputs** at the beginning of functions
- **Return consistent types** (don’t return different types based on
  input)
- **Provide sensible defaults** for optional parameters
- **Use `cli` package** for user-facing messages

``` r
#' Calculate Summary Statistics
#'
#' @param data A data frame
#' @param col Column name (string or symbol)
#' @param na.rm Logical, remove NA values?
#' @return A named numeric vector
#' @export
#' @examples
#' calc_stats(mtcars, "mpg")
calc_stats <- function(data, col, na.rm = TRUE) {
  # Input validation
  if (!is.data.frame(data)) {
    cli::cli_abort("{.arg data} must be a data frame")
  }

  # Function logic
  x <- data[[col]]
  c(
    mean = mean(x, na.rm = na.rm),
    sd = sd(x, na.rm = na.rm)
  )
}
```

### Error Handling

Use `cli` package for consistent error messages:

``` r
# Good
cli::cli_abort("{.arg x} must be a single character string")
cli::cli_warn("Missing values detected in {.arg data}")
cli::cli_inform("Processing {nrow(data)} rows...")

# Avoid
stop("x must be a single character string")
warning("Missing values detected")
message("Processing...")
```

------------------------------------------------------------------------

## Testing Guidelines

### Test Structure

Every function should have corresponding tests in
`tests/testthat/test-<function_name>.R`:

``` r
#===============================================================================
# Test: my_function()
# File: test-my_function.R
# Description: Unit tests for my_function()
#===============================================================================

#------------------------------------------------------------------------------
# Basic functionality
#------------------------------------------------------------------------------

test_that("my_function() works with valid input", {
  result <- my_function(c(1, 2, 3))
  expect_type(result, "double")
  expect_length(result, 3)
})

#------------------------------------------------------------------------------
# Parameter validation
#------------------------------------------------------------------------------

test_that("my_function() validates input type", {
  expect_error(my_function("invalid"), "must be numeric")
  expect_error(my_function(NULL), "must be numeric")
})

#------------------------------------------------------------------------------
# Edge cases
#------------------------------------------------------------------------------

test_that("my_function() handles empty input", {
  expect_equal(my_function(numeric(0)), numeric(0))
})

test_that("my_function() handles NA values", {
  result <- my_function(c(1, NA, 3), na.rm = TRUE)
  expect_equal(length(result), 2)
})
```

### Test Coverage Requirements

- **Minimum 3 tests per function**:

  1.  Expected use case
  2.  Edge case
  3.  Error handling

- **Use appropriate skip conditions**:

  ``` r
  skip_on_cran()          # For slow or network-dependent tests
  skip_if_offline()       # For tests requiring internet
  skip_if_not_installed("pkg")  # For optional dependencies
  ```

### Running Tests

``` r
# All tests
devtools::test()

# Specific file
devtools::test_active_file()

# With coverage report
covr::package_coverage()
```

------------------------------------------------------------------------

## Documentation

### Roxygen2 Comments

All exported functions must have complete roxygen2 documentation:

``` r
#' Brief Function Description
#'
#' Detailed description of what the function does. Can span
#' multiple lines and include examples of use cases.
#'
#' @param x A numeric vector. Description of the parameter.
#' @param na.rm Logical; if TRUE, remove NA values before computation.
#'   Default is TRUE.
#' @param verbose Logical; print progress messages? Default is FALSE.
#'
#' @return A numeric vector of the same length as \code{x} containing
#'   the transformed values.
#'
#' @export
#' @examples
#' # Basic usage
#' transform_data(c(1, 2, 3))
#'
#' # Handle NA values
#' transform_data(c(1, NA, 3), na.rm = TRUE)
#'
#' # With custom options
#' transform_data(1:10, verbose = TRUE)
#'
#' @seealso \code{\link{related_function}}
```

### Documentation Standards

- **Title**: One line, describing what the function does
- **Description**: More detailed explanation
- **Parameters**: Document every parameter, including types and defaults
- **Return**: Describe the return value type and structure
- **Examples**: At least 2-3 working examples
- **Cross-references**: Link to related functions

### Updating Documentation

``` r
# Generate man pages from roxygen2 comments
devtools::document()

# Build and preview pkgdown site locally
pkgdown::build_site()
```

------------------------------------------------------------------------

## CRAN Compliance

### Pre-submission Checklist

Before contributing code that will go to CRAN:

`R CMD check` returns **0 errors, 0 warnings, 0 notes**

All examples are executable or wrapped in `\dontrun{}` / `\donttest{}`

File operations use [`tempdir()`](https://rdrr.io/r/base/tempfile.html)
in examples

Network operations are skipped on CRAN (`skip_on_cran()`)

No file writes to user’s home directory

All dependencies are declared in DESCRIPTION

License is clearly specified

No non-ASCII characters in code

### File System Guidelines

**Good:**

``` r
# Use tempdir() for temporary files
temp_file <- file.path(tempdir(), "output.csv")
write.csv(data, temp_file)

# Clean up
unlink(temp_file)
```

**Bad:**

``` r
# Never write to home or working directory
write.csv(data, "~/output.csv")  # ❌
write.csv(data, "output.csv")     # ❌
```

### Network Access

``` r
# Always skip network tests on CRAN
test_that("download_url() works", {
  skip_on_cran()
  skip_if_offline()

  result <- download_url("https://example.com/data.csv")
  expect_true(file.exists(result))
})
```

### Running CRAN Checks

``` r
# Local check
devtools::check()

# Check on multiple platforms (requires Docker)
rhub::check_for_cran()

# Windows check
devtools::check_win_release()
devtools::check_win_devel()

# macOS check (requires macOS)
rhub::check_on_macos()
```

------------------------------------------------------------------------

## Additional Resources

### R Package Development

- [R Packages (2e)](https://r-pkgs.org/) by Hadley Wickham & Jennifer
  Bryan
- [Writing R
  Extensions](https://cran.r-project.org/doc/manuals/r-release/R-exts.html)
- [CRAN Repository
  Policy](https://cran.r-project.org/web/packages/policies.html)

### Tools

- [devtools](https://devtools.r-lib.org/) - Package development tools
- [usethis](https://usethis.r-lib.org/) - Workflow automation
- [testthat](https://testthat.r-lib.org/) - Testing framework
- [roxygen2](https://roxygen2.r-lib.org/) - Documentation
- [pkgdown](https://pkgdown.r-lib.org/) - Website generation

### Style Guides

- [Tidyverse Style Guide](https://style.tidyverse.org/)
- [Google’s R Style
  Guide](https://google.github.io/styleguide/Rguide.html)

------------------------------------------------------------------------

## Questions?

If you have questions about contributing, please:

1.  Check the [documentation](https://evanbio.github.io/evanverse/)
2.  Search [existing
    issues](https://github.com/evanbio/evanverse/issues)
3.  Open a new issue with the `question` label
4.  Contact the maintainer: <evanzhou.bio@gmail.com>

------------------------------------------------------------------------

## License

By contributing to evanverse, you agree that your contributions will be
licensed under the [MIT
License](https://evanbio.github.io/evanverse/LICENSE.md).

------------------------------------------------------------------------

Thank you for contributing to evanverse! 🎉
