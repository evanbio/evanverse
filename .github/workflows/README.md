# GitHub Actions Workflows

This directory contains CI/CD workflows for the evanverse package.

## 📋 Active Workflows

### 1. R-CMD-check.yaml

**Purpose**: Automated R package checking across multiple platforms and R versions.

**Triggers**:
- Push to `main` or `dev` branches
- Pull requests to `main` or `dev` branches

**Test Matrix**:
| Platform | R Version | Purpose |
|----------|-----------|---------|
| Windows (latest) | release | CRAN Windows support verification |
| macOS (latest) | release | CRAN macOS support verification |
| Ubuntu (latest) | devel | Future R version compatibility |
| Ubuntu (latest) | release | Current R version (primary) |
| Ubuntu (latest) | oldrel-1 | Backward compatibility (one version back) |

**Features**:
- ✅ Full `R CMD check` execution (0 errors, 0 warnings, 0 notes)
- ✅ Dependency caching for faster builds
- ✅ Automated package dependency installation
- ✅ Snapshot testing support
- ✅ Compact vignette building
- ✅ CRAN submission readiness validation

**CRAN Compliance**:
- Uses standard r-lib/actions maintained by Posit/RStudio
- Matches CRAN's testing infrastructure
- All workflow files excluded via `.Rbuildignore`
- No modification to package source during checks

**Badge**:
```markdown
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
```

---

### 2. test-coverage.yaml

**Purpose**: Automated test coverage reporting using covr and Codecov.

**Triggers**:
- Push to `main` or `dev` branches
- Pull requests to `main` or `dev` branches

**Test Platform**:
| Platform | R Version | Purpose |
|----------|-----------|---------|
| Ubuntu (latest) | release | Coverage analysis on primary platform |

**Features**:
- ✅ Uses `covr` package for coverage calculation
- ✅ Uploads results to Codecov for visualization
- ✅ Generates Cobertura XML format reports
- ✅ Shows testthat output on failures
- ✅ Uploads test artifacts on failure

**Coverage Configuration**:
- Target: Auto (maintains current coverage level)
- Threshold: 1% (allows minor variations)
- Range: 70-100% (acceptable coverage range)
- Ignores: tests/, man/, data/, vignettes/, docs/

**CRAN Compliance**:
- Coverage analysis runs on Ubuntu only
- Does not affect package build or installation
- Configuration file (`codecov.yml`) excluded via `.Rbuildignore`
- Uses official r-lib/actions workflow templates

**Badge**:
```markdown
[![Codecov test coverage](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse)
```

**Setup Requirements**:
1. Sign up for Codecov: https://codecov.io/
2. Add repository to Codecov
3. Add `CODECOV_TOKEN` to GitHub repository secrets
4. Token available at: https://codecov.io/gh/evanbio/evanverse/settings

**Viewing Coverage Reports**:
- Dashboard: https://codecov.io/gh/evanbio/evanverse
- PR comments show coverage changes automatically
- Sunburst and tree visualizations available

---

### 3. pkgdown.yaml

**Purpose**: Automated package documentation website building and deployment using pkgdown.

**Triggers**:
- Push to `main` or `dev` branches
- Pull requests to `main` or `dev` branches
- Release publication
- Manual workflow dispatch

**Deployment Platform**:
| Platform | R Version | Purpose |
|----------|-----------|---------|
| Ubuntu (latest) | release | Build and deploy documentation site |

**Features**:
- ✅ Automatic site generation from roxygen2 documentation
- ✅ Builds vignettes and articles
- ✅ Deploys to GitHub Pages (gh-pages branch)
- ✅ Custom theme with professional styling
- ✅ Search functionality and navigation
- ✅ Responsive design for mobile devices

**Deployment Strategy**:
- **Branch**: Deploys to `gh-pages` branch automatically
- **URL**: https://evanbio.github.io/evanverse/
- **On PRs**: Builds site but does not deploy (validation only)
- **On Push**: Builds and deploys to GitHub Pages
- **On Release**: Rebuilds with latest version info

**CRAN Compliance**:
- Documentation site is external to package
- Does not modify package source code
- Configuration file (`_pkgdown.yml`) excluded via `.Rbuildignore`
- Uses official r-lib/actions workflow templates
- Site generation uses standard pkgdown package

**Configuration**:
- Theme: Bootstrap 5 with Sandstone bootswatch
- Custom CSS: Professional styling with brand colors
- Navigation: Organized by function categories
- Articles: Multiple vignettes with progressive complexity
- Reference: Functions grouped by domain (visualization, data processing, bioinformatics)

**Setup Requirements**:
1. Enable GitHub Pages in repository settings
2. Set source to `gh-pages` branch
3. Ensure `_pkgdown.yml` is properly configured
4. Grant workflow write permissions (Settings → Actions → General → Workflow permissions)

**Viewing Documentation**:
- Production site: https://evanbio.github.io/evanverse/
- Local preview: Run `pkgdown::build_site()` in R console
- Development: Use `pkgdown::preview_site()` for live preview

**Badge**:
```markdown
[![pkgdown](https://github.com/evanbio/evanverse/actions/workflows/pkgdown.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/pkgdown.yaml)
```

## 🔧 Maintenance

### Updating Workflows

Workflows are based on [r-lib/actions](https://github.com/r-lib/actions) templates.

To update to the latest version:
```r
# In R console
usethis::use_github_action("check-standard")  # Update R-CMD-check
usethis::use_github_action("test-coverage")   # Update test coverage
usethis::use_github_action("pkgdown")         # Update pkgdown
```

### Local Testing

Before pushing, test locally:
```r
# Run R CMD check
devtools::check()

# Test coverage locally
covr::package_coverage()

# Build pkgdown site locally
pkgdown::build_site()

# Test on different R versions with Docker
docker run -v $(pwd):/pkg r-base:latest R CMD check /pkg
```

## 📊 Workflow Status

Check workflow runs at: https://github.com/evanbio/evanverse/actions

## 🚀 Future Workflows (Planned)

- [x] Test coverage reporting (codecov) - **Implemented**
- [x] Automatic pkgdown site deployment - **Implemented**
- [ ] Code style checking (lintr)
- [ ] Release automation
- [ ] Dependency vulnerability scanning

## 📖 References

- [r-lib/actions Documentation](https://github.com/r-lib/actions)
- [GitHub Actions for R](https://orchid00.github.io/actions_sandbox/)
- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
