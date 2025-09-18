# Contributing to evanverse

Thank you for your interest in contributing to evanverse! This guide will help you get started with our development workflow.

## 🚀 Quick Start

1. **Fork** the repository on GitHub
2. **Clone** your fork locally: `git clone https://github.com/YOUR-USERNAME/evanverse.git`
3. **Switch to dev branch**: `git checkout dev`
4. **Create your feature branch**: `git checkout -b feature/amazing-new-feature`
5. **Make your changes** and commit them
6. **Push** to your fork: `git push origin feature/amazing-new-feature`
7. **Create a Pull Request** from your fork to the main repository's `main` branch

## 📋 Development Workflow

### Branch Strategy

We use a **Git Flow** inspired workflow:

```
main     (production-ready releases)
  ↑
dev      (integration branch for development)
  ↑
feature/* (feature development branches)
hotfix/* (urgent fixes to main)
release/* (release preparation branches)
```

#### Branch Descriptions

- **`main`**: Production-ready code. Only accepts PRs from `dev` or `hotfix/*` branches
- **`dev`**: Main development branch. All feature branches merge here first
- **`feature/*`**: Individual feature development (e.g., `feature/new-plotting-function`)
- **`hotfix/*`**: Emergency fixes that need to go directly to `main`
- **`release/*`**: Prepare new releases (version bumps, documentation updates)

### Development Process

1. **Start from `dev`**: Always branch from the latest `dev` branch
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b feature/your-feature-name
   ```

2. **Work on your feature**: Make commits with clear, descriptive messages
   ```bash
   git add .
   git commit -m "feat: add new plotting function for forest plots"
   ```

3. **Keep your branch updated**:
   ```bash
   git checkout dev
   git pull origin dev
   git checkout feature/your-feature-name
   git merge dev  # or git rebase dev
   ```

4. **Test thoroughly**:
   ```bash
   # Run package checks
   R -e "devtools::check()"

   # Run tests
   R -e "devtools::test()"

   # Update documentation
   R -e "devtools::document()"
   ```

5. **Create Pull Request**: Target the `main` branch (not `dev`)

## 🧪 Testing Requirements

### Before Submitting a PR

- [ ] **R CMD check passes**: `devtools::check()` must return 0 errors, 0 warnings
- [ ] **All tests pass**: `devtools::test()` must succeed
- [ ] **Documentation updated**: Run `devtools::document()` if you added/modified functions
- [ ] **Examples work**: All `@examples` in your functions must run without errors
- [ ] **News updated**: Add entry to `NEWS.md` for user-facing changes

### Writing Tests

- Place tests in `tests/testthat/test-functionname.R`
- Use descriptive test names: `test_that("plot_density handles missing data correctly", ...)`
- Include edge cases and error conditions
- Use `skip_on_cran()` for tests requiring network access
- Use `skip_if_not_installed("package")` for optional dependencies

Example test structure:
```r
test_that("new_function works with basic input", {
  result <- new_function(data = mtcars)
  expect_s3_class(result, "ggplot")
  expect_equal(nrow(result$data), 32)
})

test_that("new_function handles edge cases", {
  expect_error(new_function(data = NULL), "data cannot be NULL")
  expect_warning(new_function(data = data.frame()), "empty data")
})
```

## 📚 Documentation Standards

### Function Documentation

Use roxygen2 for all exported functions:

```r
#' Brief Description of Function
#'
#' Longer description explaining what the function does,
#' its purpose, and how it fits into the package.
#'
#' @param param1 Description of first parameter
#' @param param2 Description of second parameter
#' @param ... Additional arguments passed to other functions
#'
#' @return Description of what the function returns
#'
#' @export
#'
#' @examples
#' # Simple example
#' result <- your_function(data = mtcars)
#'
#' # More complex example
#' result <- your_function(
#'   data = mtcars,
#'   param2 = "custom_value"
#' )
```

### Code Style

- **Follow R conventions**: Use `snake_case` for function names and variables
- **Meaningful names**: Functions should be verbs, variables should be nouns
- **Consistent spacing**: Use spaces around operators (`x + y`, not `x+y`)
- **Line length**: Keep lines under 80 characters when possible
- **Comments**: Use `#` for single-line comments, explain the "why" not the "what"

### Commit Message Format

Use conventional commits format:

```
type(scope): brief description

Extended description if needed.

- List specific changes
- Use bullet points for multiple changes
```

Types:
- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation changes
- `style`: Code style changes (formatting, etc.)
- `refactor`: Code refactoring
- `test`: Adding or modifying tests
- `chore`: Maintenance tasks

Examples:
```
feat(plotting): add forest plot functionality

Add plot_forest() function with forestploter backend.
Includes significance highlighting and customizable themes.

- Add plot_forest() function
- Update NAMESPACE exports
- Add comprehensive tests and examples
```

## 🔧 Setting Up Development Environment

### Required Tools

1. **R** (≥ 4.1.0)
2. **RStudio** (recommended) or another R IDE
3. **Git**
4. **GitHub CLI** (optional but helpful): `gh`

### R Package Dependencies

```r
# Development tools
install.packages(c(
  "devtools",
  "usethis",
  "testthat",
  "roxygen2",
  "pkgdown",
  "styler",
  "lintr"
))

# Package dependencies (automatically managed by devtools)
devtools::install_deps()
```

### IDE Setup

#### RStudio Configuration
1. **Tools → Project Options → Build Tools**
   - Build Tools: Package
   - Generate documentation with Roxygen: ✓
   - Use devtools package functions if available: ✓

2. **Tools → Global Options → Code**
   - Insert spaces for tab: ✓ (2 spaces)
   - Strip trailing whitespace: ✓

## 🚨 Common Issues & Solutions

### R CMD check Warnings

**"undefined global variable"**: Add variables to `globalVariables()` in `R/zzz.R`
```r
utils::globalVariables(c("variable_name", "another_var"))
```

**Missing documentation**: Ensure all exported functions have complete roxygen documentation

**Example failures**: Wrap examples that require special packages:
```r
#' @examples
#' \dontrun{
#'   # Code that requires special setup
#'   plot_forest(data)
#' }
```

### Git Issues

**Merge conflicts**:
```bash
git checkout dev
git pull origin dev
git checkout your-branch
git rebase dev
# Resolve conflicts, then:
git rebase --continue
```

**Accidentally committed to main**:
```bash
git checkout main
git reset --hard origin/main
git checkout -b fix/your-fix
# Make your changes again
```

## 📋 Release Process

### For Maintainers

1. **Prepare release branch**:
   ```bash
   git checkout dev
   git pull origin dev
   git checkout -b release/0.x.y
   ```

2. **Update version and documentation**:
   - Bump version in `DESCRIPTION`
   - Update `NEWS.md`
   - Update `cran-comments.md`
   - Run `devtools::check()`

3. **Create release PR**: From `release/0.x.y` to `main`

4. **After merge**: Create GitHub release and tag

## 🆘 Getting Help

- **GitHub Issues**: For bugs, feature requests, and questions
- **GitHub Discussions**: For general discussion and ideas
- **Email**: Contact maintainers for sensitive issues

## 📜 Code of Conduct

- Be respectful and inclusive
- Focus on constructive feedback
- Help others learn and contribute
- Follow the GitHub Community Guidelines

---

**Happy coding! 🎉**

Your contributions make evanverse better for everyone in the R community.