# Codecov Setup Guide for evanverse

This guide explains how to set up Codecov integration for automated test coverage reporting.

## 📊 Overview

Codecov provides:
- **Visual coverage reports** with sunburst diagrams and file trees
- **PR comments** showing coverage changes
- **Historical tracking** of coverage trends
- **Badge display** showing current coverage percentage

## 🚀 Initial Setup

### Step 1: Sign Up for Codecov

1. Visit https://codecov.io/
2. Sign in with your GitHub account
3. Grant Codecov access to your repositories

### Step 2: Add evanverse Repository

1. Go to https://app.codecov.io/gh/evanbio
2. Click "Add new repository"
3. Select `evanverse` from the list
4. Codecov will automatically detect the repository

### Step 3: Get Codecov Token

1. Navigate to https://codecov.io/gh/evanbio/evanverse/settings
2. Copy the **Repository Upload Token**
3. Keep this token secure (treat like a password)

### Step 4: Add Token to GitHub Secrets

1. Go to https://github.com/evanbio/evanverse/settings/secrets/actions
2. Click "New repository secret"
3. Name: `CODECOV_TOKEN`
4. Value: Paste the token from Step 3
5. Click "Add secret"

### Step 5: Push Workflow to GitHub

The test-coverage.yaml workflow is already configured. After pushing:

```bash
git add .github/workflows/test-coverage.yaml codecov.yml
git commit -m "ci: add test coverage workflow"
git push origin dev
```

## ✅ Verification

### Check Workflow Run

1. Go to https://github.com/evanbio/evanverse/actions
2. Look for "test-coverage" workflow
3. Verify it runs successfully (green checkmark)

### View Coverage Report

1. Go to https://codecov.io/gh/evanbio/evanverse
2. You should see:
   - Overall coverage percentage
   - File-by-file breakdown
   - Coverage trends over time

### Check Badge

The README badge will update automatically:
```markdown
[![Codecov test coverage](https://codecov.io/gh/evanbio/evanverse/branch/main/graph/badge.svg)](https://codecov.io/gh/evanbio/evanverse)
```

## 📋 Configuration Details

### codecov.yml Settings

**Coverage Targets**:
- **Project**: Auto-adjust based on current coverage
- **Patch**: New code must meet coverage threshold
- **Threshold**: 1% variation allowed

**Coverage Range**: 70-100%
- Green: >70%
- Yellow: 50-70%
- Red: <50%

**Ignored Paths**:
- `tests/` - Test code itself
- `man/` - Documentation
- `data/` - Data files
- `vignettes/` - Tutorial code
- `inst/` - Installed files

### Workflow Triggers

The coverage workflow runs on:
- ✅ Push to `main` branch
- ✅ Push to `dev` branch
- ✅ Pull requests to `main` or `dev`

It does **not** run on:
- ❌ Push to feature branches (unless PR opened)
- ❌ Draft pull requests
- ❌ Tag creation

## 📈 Understanding Coverage Reports

### Coverage Percentage

```
Total Coverage: 85%
```

This means 85% of your code lines are executed by tests.

**Good coverage targets**:
- ✅ 90-100%: Excellent
- ✅ 80-90%: Good
- ⚠️ 70-80%: Acceptable
- ❌ <70%: Needs improvement

### File-Level Coverage

Codecov shows coverage for each file:
- **Green**: High coverage (>80%)
- **Yellow**: Medium coverage (50-80%)
- **Red**: Low coverage (<50%)

### PR Comments

On pull requests, Codecov automatically comments with:
- Coverage change (e.g., "+2.5%")
- Newly covered lines
- Uncovered lines in changes
- Overall impact

## 🎯 Improving Coverage

### Identify Gaps

1. Go to Codecov dashboard
2. Click on files with low coverage
3. Red highlights show uncovered lines

### Add Tests

For uncovered code in `R/my_function.R`:

```r
# tests/testthat/test-my_function.R
test_that("my_function() handles edge case", {
  result <- my_function(edge_case_input)
  expect_equal(result, expected_output)
})
```

### Run Coverage Locally

```r
# Install covr
install.packages("covr")

# Check package coverage
covr::package_coverage()

# View in browser
covr::report()

# Check specific file
covr::file_coverage("R/my_function.R", "tests/testthat/test-my_function.R")
```

## 🔧 Troubleshooting

### Issue: Workflow Fails with "Token not found"

**Solution**: Verify `CODECOV_TOKEN` is added to repository secrets
```
Settings → Secrets and variables → Actions → Repository secrets
```

### Issue: Coverage shows 0%

**Causes**:
1. Tests didn't run successfully
2. Coverage report not generated
3. Token authentication failed

**Debug**:
```r
# Check local coverage
covr::package_coverage()

# View workflow logs
# Go to Actions → test-coverage → View logs
```

### Issue: Badge shows "unknown"

**Solution**: Badge updates after first successful run. Wait 5-10 minutes after workflow completes.

### Issue: Codecov comment not appearing on PRs

**Solution**:
1. Ensure workflow runs on PR trigger
2. Check Codecov app has PR comment permissions
3. Verify repository is public or has Codecov Pro

## 📚 Advanced Configuration

### Custom Coverage Thresholds

Edit `codecov.yml`:

```yaml
coverage:
  status:
    project:
      default:
        target: 85%  # Require 85% coverage
        threshold: 2%  # Allow 2% drop
```

### Exclude Specific Lines

Use `# nocov` comments:

```r
# This code won't be counted in coverage
result <- complex_function()  # nocov start
debug_print(result)
log_details(result)
# nocov end
```

### Multiple Coverage Targets

```yaml
coverage:
  status:
    project:
      default:
        target: auto
    patch:
      default:
        target: 80%  # New code must have 80% coverage
```

## 📊 Coverage Goals for evanverse

Based on your current test suite (444 tests, 1017 assertions):

### Current Status
- **Test files**: 53
- **Test quality**: 9.1/10 (excellent)
- **Expected initial coverage**: 85-90%

### Targets
- **Short-term**: Maintain >85% coverage
- **Medium-term**: Achieve >90% coverage
- **Long-term**: Maintain >90% coverage for new code

### Priority Areas
1. Core utility functions (void handling, operators)
2. Data processing functions (df2list, map_column)
3. Bioinformatics functions (gene ID conversion)

## 🔗 Useful Links

- **Codecov Dashboard**: https://codecov.io/gh/evanbio/evanverse
- **Codecov Documentation**: https://docs.codecov.com/
- **covr Package**: https://covr.r-lib.org/
- **r-lib/actions**: https://github.com/r-lib/actions

## 📧 Support

For issues with Codecov setup:
- Check workflow logs: https://github.com/evanbio/evanverse/actions
- Codecov support: https://codecov.io/support
- r-lib/actions issues: https://github.com/r-lib/actions/issues

---

**Setup completed**: Run workflow and verify coverage reporting works
**Last updated**: 2025-10-22
