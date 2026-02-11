# CRAN Comments for evanverse 0.4.0

## Submission - Feature Release

This is a minor version update from 0.3.7 to 0.4.0. It addresses two CRAN-flagged issues and adds new functionality.

### CRAN Issues Resolved

1. **Test failures on 7 platforms (ERROR)**: `plot_pie()` tests failed due to dplyr 1.2.0 `case_when()` deprecation warning. Fixed by replacing `case_when()` with `switch()` (PR #4 from @DavisVaughan).

2. **Relative URL paths (NOTE)**: `../reference/` in vignette HTML flagged as possibly invalid URL. Fixed by replacing with absolute pkgdown URLs.

### Changes in v0.4.0

1. **New Statistical Analysis Functions** (6 new):
   - `quick_ttest()`: t-test analysis with automatic assumption checking
   - `quick_anova()`: One-way ANOVA with post-hoc tests
   - `quick_chisq()`: Chi-square test with visualization
   - `quick_cor()`: Correlation analysis with heatmap
   - `stat_power()`: Statistical power analysis
   - `stat_samplesize()`: Sample size calculation

2. **New ggplot2 Integration**:
   - `scale_color_evanverse()` / `scale_fill_evanverse()`: Discrete color scales

3. **Major Improvements**:
   - `plot_forest()`: Complete rewrite with advanced customization
   - Palette caching system for improved performance
   - Palette naming convention standardized
   - Void utilities and package management functions consolidated

4. **Bug Fixes**:
   - dplyr 1.2.0 compatibility (case_when → switch in plot_pie)
   - Relative URL paths in vignettes
   - Unicode Greek letters replaced with ASCII for cross-platform compatibility
   - NA validation in download_geo_data()

5. **Breaking Changes**:
   - `df_forest_test` dataset replaced by `forest_data`
   - `plot_forest()` API changed (complete rewrite)
   - Palette names changed to `type_name_source` format

## Test environments
* Local Windows install, R 4.5.0
* GitHub Actions (ubuntu-latest): R-release, R-devel
* GitHub Actions (windows-latest): R-release
* GitHub Actions (macOS-latest): R-release

## R CMD check results

0 errors ✔ | 0 warnings ✔ | 0 notes ✔

## Downstream dependencies

There are currently no downstream dependencies for this package.

## Quality Assurance

* **Test suite**: 2196 tests passing (0 failures, 0 warnings, 26 skipped)
* **Check time**: 2m 55s
* **Platform compatibility**: Verified on Windows, macOS, and Linux
