# GitHub Actions Workflows

This directory contains CI/CD workflows for the evanverse package.

## 📋 Active Workflows

### R-CMD-check.yaml

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

## 🔧 Maintenance

### Updating Workflows

Workflows are based on [r-lib/actions](https://github.com/r-lib/actions) templates.

To update to the latest version:
```r
# In R console
usethis::use_github_action("check-standard")
```

### Local Testing

Before pushing, test locally:
```r
# Run R CMD check
devtools::check()

# Test on different R versions with Docker
docker run -v $(pwd):/pkg r-base:latest R CMD check /pkg
```

## 📊 Workflow Status

Check workflow runs at: https://github.com/evanbio/evanverse/actions

## 🚀 Future Workflows (Planned)

- [ ] Test coverage reporting (codecov)
- [ ] Automatic pkgdown site deployment
- [ ] Code style checking (lintr)
- [ ] Release automation
- [ ] Dependency vulnerability scanning

## 📖 References

- [r-lib/actions Documentation](https://github.com/r-lib/actions)
- [GitHub Actions for R](https://orchid00.github.io/actions_sandbox/)
- [CRAN Repository Policy](https://cran.r-project.org/web/packages/policies.html)
