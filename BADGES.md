# Badge Guidelines for evanverse

This document explains the badge strategy for the evanverse package,
including which badges are displayed in the README and which are
available as optional references.

------------------------------------------------------------------------

## 🎯 Philosophy: Less is More

The README displays **only 5 essential badges** to maintain a clean,
modern appearance while conveying critical information. Additional
metrics are available here for reference.

------------------------------------------------------------------------

## ✅ Active Badges (Displayed in README)

These 5 badges appear in the main README, chosen for maximum signal and
minimal noise:

| Badge                                                                                             | Purpose         | Why Essential                                                                             |
|---------------------------------------------------------------------------------------------------|-----------------|-------------------------------------------------------------------------------------------|
| ![CRAN](https://www.r-pkg.org/badges/version/evanverse)                                           | CRAN version    | Shows current release version - primary indicator of package availability                 |
| ![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg) | Build status    | Real-time quality assurance across 5 platforms - critical for user confidence             |
| ![Codecov](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)                   | Test coverage   | Code quality indicator - shows how well-tested the package is                             |
| ![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)                       | Maturity stage  | Indicates production readiness - crucial for enterprise adoption                          |
| ![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/evanverse)                             | Total downloads | Shows package adoption and community usage - indicator of reliability and trustworthiness |

### Badge Markdown

``` markdown
[![CRAN](https://www.r-pkg.org/badges/version/evanverse)](https://CRAN.R-project.org/package=evanverse)
[![R-CMD-check](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml/badge.svg)](https://github.com/evanbio/evanverse/actions/workflows/R-CMD-check.yaml)
[![Codecov](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse?branch=main)
[![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)
[![Downloads](https://cranlogs.r-pkg.org/badges/grand-total/evanverse)](https://CRAN.R-project.org/package=evanverse)
```

------------------------------------------------------------------------

## 📊 Optional Reference Badges

These badges are available but **NOT displayed in README** to reduce
clutter. They’re useful for tracking but don’t convey essential
information to new users.

### License Information

| Badge                                                         | Description               |
|---------------------------------------------------------------|---------------------------|
| ![License](https://img.shields.io/badge/License-MIT-blue.svg) | MIT License - open source |

**Why not in README:** License information is already clearly stated in
the License section of README and LICENSE.md file. The badge provides no
additional value to users.

``` markdown
[![License](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE.md)
```

### Download Metrics

| Badge                                                             | Description                 |
|-------------------------------------------------------------------|-----------------------------|
| ![Monthly downloads](https://cranlogs.r-pkg.org/badges/evanverse) | Downloads in the last month |

**Why not in README:** Monthly download metrics are more volatile and
less representative of overall package adoption than total downloads.

``` markdown
[![Monthly](https://cranlogs.r-pkg.org/badges/evanverse)](https://CRAN.R-project.org/package=evanverse)
```

### CRAN Platform Checks

| Badge                                                              | Description                            |
|--------------------------------------------------------------------|----------------------------------------|
| ![CRAN checks](https://badges.cranchecks.info/worst/evanverse.svg) | CRAN automated checks across platforms |

**Why not in README:** Redundant with R-CMD-check badge. Both verify
builds, but GitHub Actions provides more granular control and
transparency.

``` markdown
[![CRAN checks](https://badges.cranchecks.info/worst/evanverse.svg)](https://cran.r-project.org/web/checks/check_results_evanverse.html)
```

### Development Activity

| Badge                                                                       | Description                |
|-----------------------------------------------------------------------------|----------------------------|
| ![Last commit](https://img.shields.io/github/last-commit/evanbio/evanverse) | Date of most recent commit |
| ![GitHub issues](https://img.shields.io/github/issues/evanbio/evanverse)    | Number of open issues      |

**Why not in README:** Activity metrics are misleading. Mature packages
may have infrequent commits (stability), and issue count depends on
project popularity, not quality.

``` markdown
[![Last commit](https://img.shields.io/github/last-commit/evanbio/evanverse)](https://github.com/evanbio/evanverse/commits/main)
[![Issues](https://img.shields.io/github/issues/evanbio/evanverse)](https://github.com/evanbio/evanverse/issues)
```

### Technical Specifications

| Badge                                                                         | Description            |
|-------------------------------------------------------------------------------|------------------------|
| \![Dependencies\](<https://img.shields.io/badge/dependencies-10%20imports%20> | %2015%20suggests-blue) |
| ![R version](https://img.shields.io/badge/R-%E2%89%A5%204.1.0-blue)           | Minimum R version      |

**Why not in README:** Technical details better placed in documentation.
R version requirement is mentioned in Installation section; dependency
info is in DESCRIPTION file.

``` markdown
[![Dependencies](https://img.shields.io/badge/dependencies-10%20imports%20|%2015%20suggests-blue)](https://CRAN.R-project.org/package=evanverse)
[![R version](https://img.shields.io/badge/R-%E2%89%A5%204.1.0-blue)](https://www.r-project.org/)
```

------------------------------------------------------------------------

## 🎨 Design Principles

### Why This Badge Selection?

1.  **User-Centric Focus**
    - Show what matters to package adopters (version, reliability,
      stability, popularity)
    - Hide metrics that matter only to maintainers (monthly downloads,
      commit frequency)
2.  **Signal vs. Noise**
    - Each badge must answer a key user question:
      - ✅ “Is it available?” → CRAN badge
      - ✅ “Does it work?” → R-CMD-check badge
      - ✅ “Is it well-tested?” → Codecov badge
      - ✅ “Is it production-ready?” → Lifecycle badge
      - ✅ “Is it widely used?” → Downloads badge
3.  **Visual Hierarchy**
    - 5 badges: Clean, scannable, professional
    - 11+ badges: Cluttered, intimidating, amateur
    - Centered layout with quick-links creates modern aesthetic
4.  **Trust Through Transparency**
    - All displayed badges link to verifiable external sources
    - No static/fake badges
    - Auto-updating metrics ensure accuracy

------------------------------------------------------------------------

## 🔄 Badge Update Policy

### Automatic Updates

These badges update automatically via external services: - ✅ CRAN
version (updates when new version published) - ✅ R-CMD-check (updates
on every push/PR) - ✅ Codecov (updates after test runs)

### Manual Updates Required

These need manual editing in README.md:

1.  **Lifecycle Badge** - Update when package status changes

    ``` markdown
    # Stable (current)
    [![Lifecycle](https://img.shields.io/badge/lifecycle-stable-brightgreen.svg)](https://lifecycle.r-lib.org/articles/stages.html#stable)

    # Other stages
    [![Lifecycle](https://img.shields.io/badge/lifecycle-experimental-orange.svg)](...)
    [![Lifecycle](https://img.shields.io/badge/lifecycle-superseded-blue.svg)](...)
    [![Lifecycle](https://img.shields.io/badge/lifecycle-deprecated-red.svg)](...)
    ```

------------------------------------------------------------------------

## 📏 Lifecycle Stage Guidelines

| Stage               | When to Use                                                          | Color  | Badge Status                                |
|---------------------|----------------------------------------------------------------------|--------|---------------------------------------------|
| **Experimental** 🧪 | Initial development, API unstable, breaking changes expected         | Orange | Not recommended for production              |
| **Stable** ✅       | API stable, CRAN published, thoroughly tested, production-ready      | Green  | **\[Current\]**                             |
| **Superseded** 🔵   | Still maintained, but better alternatives exist, no new features     | Blue   | Stable but not recommended for new projects |
| **Deprecated** ⛔   | Use strongly discouraged, will be removed, migration guide available | Red    | Do not use                                  |

**Current Status:** evanverse is **Stable** (green badge)

------------------------------------------------------------------------

## 🚀 Future Badge Considerations

### Badges to Add Later (When Applicable)

1.  **DOI Badge** - If package is archived on Zenodo for academic
    citations

    ``` markdown
    [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.XXXXX.svg)](https://doi.org/10.5281/zenodo.XXXXX)
    ```

2.  **JOSS Badge** - If published in Journal of Open Source Software

    ``` markdown
    [![JOSS](https://joss.theoj.org/papers/10.21105/joss.XXXXX/status.svg)](https://joss.theoj.org/papers/10.21105/joss.XXXXX)
    ```

3.  **pkgdown Badge** - If auto-deployment becomes critical

    ``` markdown
    [![pkgdown](https://github.com/evanbio/evanverse/actions/workflows/pkgdown.yaml/badge.svg)](https://evanbio.github.io/evanverse/)
    ```

### Badges to Avoid

- ❌ GitHub stars/forks (vanity metrics)
- ❌ Multiple overlapping CI badges
- ❌ Social media badges
- ❌ “Made with R” or similar obvious badges
- ❌ Too many shield.io custom badges

------------------------------------------------------------------------

## 🎓 Badge Interpretation Guide

### For Users

**Before installing evanverse, check:** 1. **CRAN badge** - Is it the
version you need? 2. **R-CMD-check** - Is it currently building
successfully? 3. **Lifecycle** - Is it production-ready?

**Green badges = Safe to use ✅**

### For Contributors

**Before contributing, check:** 1. **R-CMD-check** - Are tests passing?
2. **Codecov** - Where can test coverage improve? 3. **GitHub issues**
(not in README, but on repo)

### For Maintainers

**Regular checks:** - Weekly: R-CMD-check status - After commits:
Codecov changes - Before CRAN submission: All badges green - Quarterly:
Lifecycle appropriateness

------------------------------------------------------------------------

## 📦 Service Providers

| Service                                               | What It Does               | Badge Type         | Update Frequency |
|-------------------------------------------------------|----------------------------|--------------------|------------------|
| [r-pkg.org](https://www.r-pkg.org/)                   | CRAN version tracking      | CRAN version       | On CRAN publish  |
| [GitHub Actions](https://github.com/features/actions) | CI/CD pipelines            | R-CMD-check        | Every push/PR    |
| [Codecov](https://codecov.io/)                        | Test coverage reporting    | Coverage %         | After test runs  |
| [shields.io](https://shields.io/)                     | Custom badge generation    | Lifecycle, License | Manual update    |
| [lifecycle.r-lib.org](https://lifecycle.r-lib.org/)   | Package maturity framework | Lifecycle stage    | Manual update    |

------------------------------------------------------------------------

## 📞 Questions?

For badge-related questions: - 📧 Email: <evanzhou.bio@gmail.com> - 🐛
Issues: [GitHub Issues](https://github.com/evanbio/evanverse/issues) -
📚 Docs: [Package Website](https://evanbio.github.io/evanverse/)

------------------------------------------------------------------------

**Last Updated:** 2025-10-22 **Badge Count:** 5 active (down from 11) ✅
**Design Philosophy:** Modern, minimal, meaningful
