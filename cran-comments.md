# CRAN Comments for evanverse 0.5.1

## Submission — CRAN Patch

This is a patch release from 0.5.0 to 0.5.1, fixing a documentation issue
that caused the PDF manual build to fail on CRAN.

### Summary of Changes

* Replaced Unicode character `≤` (U+2264) with `<=` in `quick_chisq()` roxygen2
  documentation, which caused a LaTeX error when building the PDF version of the manual

### R CMD check results

```
── R CMD check results ─────────────────────────────────── evanverse 0.5.1 ────
Duration: 2m 24.4s

0 errors ✔ | 0 warnings ✔ | 0 notes ✔
```

### Test environments

* Local: Windows 11 x64 (build 26200), R 4.5.1 (2025-06-13 ucrt)
* GitHub Actions (ubuntu-latest): R-release, R-devel
* GitHub Actions (windows-latest): R-release
* GitHub Actions (macOS-latest): R-release

### Downstream dependencies

There are currently no downstream dependencies for this package.
