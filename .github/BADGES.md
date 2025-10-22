# evanverse Badges Guide

This document explains all the badges displayed in the README and what they represent.

## 📊 Badge Overview

The evanverse README displays 11 badges organized into 4 categories:

### 1. CRAN Status & Distribution (4 badges)

| Badge | Description | Link |
|-------|-------------|------|
| ![CRAN status](https://www.r-pkg.org/badges/version/evanverse) | Current version on CRAN | https://CRAN.R-project.org/package=evanverse |
| ![CRAN downloads](https://cranlogs.r-pkg.org/badges/grand-total/evanverse) | Total downloads since first CRAN release | https://CRAN.R-project.org/package=evanverse |
| ![CRAN monthly](https://cranlogs.r-pkg.org/badges/evanverse) | Downloads in the last month | https://CRAN.R-project.org/package=evanverse |
| ![CRAN checks](https://badges.cranchecks.info/worst/evanverse.svg) | CRAN's automated checks across platforms | https://cran.r-project.org/web/checks/check_results_evanverse.html |

**Interpretation:**
- **CRAN status**: Shows the current CRAN version (e.g., 0.3.7)
- **Total downloads**: Cumulative downloads since CRAN publication
- **Monthly downloads**: Recent popularity indicator
- **CRAN checks**: Shows worst status across all CRAN platforms
  - `OK` (green) = All checks pass
  - `NOTE` (yellow) = Minor issues
  - `WARN` (orange) = Warnings present
  - `ERROR` (red) = Errors detected

### 2. Build & Quality Status (2 badges)

| Badge | Description | Link |
|-------|-------------|------|
| ![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg) | GitHub Actions CI/CD status | https://github.com/evanbio/evanverse/actions |
| ![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg) | Development stage indicator | https://lifecycle.r-lib.org/articles/stages.html |

**Interpretation:**
- **R-CMD-check**: Real-time build status across 5 platforms
  - ✅ Green = All checks passing
  - 🟡 Yellow = Running
  - ❌ Red = Build failed
- **Lifecycle**: Package maturity stage
  - `experimental` (orange) = Early development
  - `stable` (green) = Production-ready
  - `superseded` (blue) = Maintained but superseded
  - `deprecated` (red) = Use discouraged

### 3. Development Activity (2 badges)

| Badge | Description | Link |
|-------|-------------|------|
| ![Last commit](https://img.shields.io/github/last-commit/evanbio/evanverse) | Date of most recent commit | https://github.com/evanbio/evanverse/commits |
| ![GitHub issues](https://img.shields.io/github/issues/evanbio/evanverse) | Number of open issues | https://github.com/evanbio/evanverse/issues |

**Interpretation:**
- **Last commit**: Shows how actively maintained the package is
  - Recent (green) = Active development
  - Older (yellow/red) = Less frequent updates
- **Open issues**: Indicator of known problems or feature requests
  - Low number = Well-maintained
  - High number = Active community or backlog

### 4. Technical Specifications (3 badges)

| Badge | Description | Link |
|-------|-------------|------|
| ![Dependencies](https://img.shields.io/badge/dependencies-10%20imports%20|%2015%20suggests-blue) | Dependency counts | https://CRAN.R-project.org/package=evanverse |
| ![License](https://img.shields.io/badge/License-MIT-blue.svg) | Open source license type | LICENSE.md |
| ![R version](https://img.shields.io/badge/R-%E2%89%A5%204.1.0-blue) | Minimum R version required | https://www.r-project.org/ |

**Interpretation:**
- **Dependencies**:
  - Imports = Required packages (always installed)
  - Suggests = Optional packages (for specific features)
- **License**: MIT = Permissive open source license
- **R version**: Minimum R version needed to use the package

---

## 🎯 Badge Best Practices

### When to Update Badges

1. **Version bumps**: Badges auto-update from CRAN/GitHub
2. **Lifecycle changes**: Manually update when package status changes
3. **Dependency changes**: Update badge text in README when DESCRIPTION changes
4. **Logo size**: Adjusted logo width from 105px to 120px for better visibility

### Badge Ordering Logic

Badges are ordered by importance to users:
1. **CRAN status first**: Primary distribution channel
2. **Build status**: Quality assurance
3. **Activity metrics**: Maintenance confidence
4. **Technical specs**: System requirements

### Lifecycle Badge Guidelines

**When to use each stage:**

- **Experimental** (🟠):
  - Initial development
  - API may change significantly
  - Not recommended for production

- **Stable** (🟢): **[Current]**
  - API is stable
  - Thoroughly tested
  - Production-ready
  - CRAN published

- **Superseded** (🔵):
  - Still maintained
  - Better alternatives exist
  - No new features planned

- **Deprecated** (🔴):
  - Use strongly discouraged
  - Will be removed in future
  - Migration guide provided

---

## 📈 Badge Performance Tracking

### CRAN Downloads Milestones

Track and celebrate download milestones:
- 🎯 1,000 downloads
- 🎯 5,000 downloads
- 🎯 10,000 downloads
- 🎯 50,000 downloads
- 🎯 100,000 downloads

### CRAN Check Quality Goals

Maintain perfect CRAN check status:
- ✅ All platforms: OK (green)
- ✅ 0 errors
- ✅ 0 warnings
- ✅ 0 notes

### GitHub Actions Success Rate

Target: 100% pass rate for R-CMD-check across all platforms

---

## 🔧 Maintaining Badges

### Automatic Updates

These badges update automatically:
- ✅ CRAN status (via r-pkg.org)
- ✅ CRAN downloads (via cranlogs.r-pkg.org)
- ✅ CRAN checks (via cranchecks.info)
- ✅ R-CMD-check (via GitHub Actions)
- ✅ Last commit (via GitHub)
- ✅ Open issues (via GitHub)

### Manual Updates Required

These need manual updates in README.md:
- ⚠️ Lifecycle badge (when package stage changes)
- ⚠️ Dependencies badge (when DESCRIPTION changes)
- ⚠️ R version badge (if minimum version changes)

### How to Update Manual Badges

1. **Lifecycle badge:**
   ```markdown
   [![Lifecycle: stable](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](...)
   ```
   Change `stable` to: `experimental`, `superseded`, or `deprecated`

2. **Dependencies badge:**
   ```markdown
   [![Dependencies](https://img.shields.io/badge/dependencies-X%20imports%20|%20Y%20suggests-blue)](...)
   ```
   Update X and Y to match DESCRIPTION file counts

3. **R version badge:**
   ```markdown
   [![R version](https://img.shields.io/badge/R-%E2%89%A5%204.1.0-blue)](...)
   ```
   Update version to match DESCRIPTION `Depends: R (>= X.Y.Z)`

---

## 🌐 Badge Services Used

| Service | Purpose | URL |
|---------|---------|-----|
| r-pkg.org | CRAN version badge | https://www.r-pkg.org/services |
| cranlogs.r-pkg.org | Download statistics | https://r-hub.github.io/cranlogs/ |
| cranchecks.info | CRAN check results | https://cran-checks.info/ |
| shields.io | Custom badge generation | https://shields.io/ |
| GitHub | Repository metrics | https://github.com |
| lifecycle.r-lib.org | Lifecycle stages | https://lifecycle.r-lib.org/ |

---

## 📚 Additional Badge Options

### Future Badges to Consider

When implementing additional CI/CD features:

1. **Code Coverage** (after implementing codecov):
   ```markdown
   [![Codecov](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse)
   ```

2. **pkgdown Site Status**:
   ```markdown
   [![pkgdown](https://github.com/evanbio/evanverse/actions/workflows/pkgdown.yaml/badge.svg)](https://evanbio.github.io/evanverse/)
   ```

3. **DOI Badge** (if archived on Zenodo):
   ```markdown
   [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXX)
   ```

4. **Contributor Count**:
   ```markdown
   [![Contributors](https://img.shields.io/github/contributors/evanbio/evanverse)](https://github.com/evanbio/evanverse/graphs/contributors)
   ```

### Badges NOT Recommended

Avoid these to prevent clutter:
- ❌ Multiple duplicate metrics
- ❌ Vanity metrics (stars, forks) for utility packages
- ❌ Too many CI badges (stick to comprehensive one)
- ❌ Outdated or unmaintained badge services

---

## 🎨 Badge Styling Guidelines

### Current Style
- **Layout**: Vertical list (one per line) for readability
- **Order**: Importance-based (CRAN → CI → Activity → Technical)
- **Logo**: Right-aligned, 120px width
- **Links**: All badges link to relevant pages

### Alternative Layouts

If horizontal layout is preferred:
```markdown
[![Badge1](url)](link) [![Badge2](url)](link) [![Badge3](url)](link)
```

**Current vertical layout is recommended for:**
- ✅ Better mobile viewing
- ✅ Easier to scan
- ✅ Clear visual hierarchy
- ✅ Professional appearance

---

## 📞 Support

For questions about badges or to report broken badges:
- Open an issue: https://github.com/evanbio/evanverse/issues
- Email: evanzhou.bio@gmail.com

---

**Last Updated:** 2025-10-22
