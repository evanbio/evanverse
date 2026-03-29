# CRAN Comments for evanverse 0.5.0

## Submission — Major Refactor Release

This is a major release from 0.4.4 to 0.5.0. It consolidates modules, cleans up the API,
trims dependencies, and expands test and documentation coverage.

### Summary of Changes

* Removed deprecated/unused functions (void utilities, ggplot2 scales, I/O helpers, workflow tools)
* Renamed several functions for consistency (`stat_samplesize` → `stat_n`, `convert_gene_id` → `gene2ensembl`/`gene2entrez`, etc.)
* Consolidated stat module into `stat.R` + `utils_stat.R`
* Overhauled palette module with JSON-based storage
* Added new vignettes for all major modules
* Trimmed dependencies: removed `data.table`, `openxlsx`, `readxl`, `tictoc`, `fs`, `magrittr`

### R CMD check results

```
── R CMD check results ─────────────────────────────────── evanverse 0.5.0 ────
Duration: 2m 1.6s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```

### Test environments

* Local: Windows 11 x64 (build 26200), R 4.5.1 (2025-06-13 ucrt)
* GitHub Actions (ubuntu-latest): R-release, R-devel
* GitHub Actions (windows-latest): R-release
* GitHub Actions (macOS-latest): R-release

### Downstream dependencies

There are currently no downstream dependencies for this package.
