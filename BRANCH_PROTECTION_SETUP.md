# GitHub Branch Protection Setup Guide

This guide will help you configure branch protection rules for the evanverse repository to ensure a stable main branch and proper development workflow.

## 🛡️ Branch Protection Configuration

### Step 1: Access Repository Settings

1. Go to your GitHub repository: `https://github.com/evanbio/evanverse`
2. Click **Settings** tab
3. Click **Branches** in the left sidebar

### Step 2: Protect the `main` Branch

Click **Add rule** or **Add branch protection rule** and configure:

#### Basic Settings
- **Branch name pattern**: `main`
- **Apply rule to**: ✅ Include administrators

#### Pull Request Requirements
- ✅ **Require a pull request before merging**
  - ✅ **Require approvals**: 1 (can be 0 for solo development)
  - ✅ **Dismiss stale reviews when new commits are pushed**
  - ✅ **Require review from code owners** (if you have CODEOWNERS file)
  - ✅ **Restrict pushes that create files larger than 100 MB**

#### Status Check Requirements
- ✅ **Require status checks to pass before merging**
- ✅ **Require branches to be up to date before merging**
- **Required status checks** (add these as they become available):
  - `R-CMD-check (ubuntu-latest, release)`
  - `R-CMD-check (windows-latest, release)`
  - `R-CMD-check (macOS-latest, release)`
  - `test-coverage`

#### Additional Restrictions
- ✅ **Require conversation resolution before merging**
- ✅ **Require signed commits** (optional, for extra security)
- ✅ **Require linear history** (optional, keeps clean git history)
- ✅ **Allow force pushes**: ❌ (disabled)
- ✅ **Allow deletions**: ❌ (disabled)

### Step 3: Protect the `dev` Branch (Optional)

Create another rule for development branch:

#### Basic Settings
- **Branch name pattern**: `dev`
- **Apply rule to**: ❌ Do not include administrators (more flexible for development)

#### Pull Request Requirements
- ✅ **Require a pull request before merging**
  - **Require approvals**: 0 (for faster development)
  - ✅ **Dismiss stale reviews when new commits are pushed**

#### Status Check Requirements
- ✅ **Require status checks to pass before merging**
- **Required status checks**:
  - `R-CMD-check (ubuntu-latest, release)` (minimum check)

## 🔧 Additional Repository Settings

### Step 4: General Repository Settings

Go to **Settings → General**:

#### Pull Requests
- ✅ **Allow merge commits**
- ✅ **Allow squash merging**
- ✅ **Allow rebase merging**
- ✅ **Always suggest updating pull request branches**
- ✅ **Allow auto-merge**
- ✅ **Automatically delete head branches**

#### Archives
- ❌ **Include Git LFS objects in archives** (unless you use LFS)

### Step 5: Actions Settings

Go to **Settings → Actions → General**:

#### Actions permissions
- ✅ **Allow all actions and reusable workflows**

#### Workflow permissions
- **Read and write permissions** (for GitHub Pages deployment)
- ✅ **Allow GitHub Actions to create and approve pull requests**

## 📋 Verification Checklist

After setting up branch protection, verify:

- [ ] Cannot push directly to `main` branch
- [ ] PRs are required to merge into `main`
- [ ] Status checks are required (will activate once workflows run)
- [ ] Force pushes to `main` are blocked
- [ ] Branch deletion is blocked for `main`

## 🚀 Testing the Setup

### Test 1: Direct Push Protection
```bash
# This should fail
git checkout main
echo "test" >> README.md
git add README.md
git commit -m "test direct push"
git push origin main
# Expected: remote rejected
```

### Test 2: PR Workflow
```bash
# This should work
git checkout dev
git checkout -b test/branch-protection
echo "# Test" >> TEST.md
git add TEST.md
git commit -m "test: verify branch protection"
git push origin test/branch-protection
# Then create PR via GitHub UI
```

## 🔄 Workflow Summary

With branch protection enabled, your development workflow becomes:

```
1. Developer creates feature branch from dev
   git checkout dev
   git checkout -b feature/new-feature

2. Developer makes changes and pushes
   git push origin feature/new-feature

3. Developer creates PR targeting main
   GitHub UI: feature/new-feature → main

4. CI runs automatically (R-CMD-check, test-coverage, etc.)

5. If CI passes and reviews approved → merge allowed
   Otherwise → merge blocked until issues resolved

6. After merge → feature branch auto-deleted
```

## 🚨 Emergency Override

If you need to bypass protection (repository owner only):

1. **Temporary disable**: Settings → Branches → Edit rule → Temporarily disable
2. **Make urgent fix**
3. **Re-enable protection**: Edit rule → Enable again

**Note**: This should only be used for critical hotfixes!

## 📋 Recommended Status Checks

As your CI matures, add these status checks to branch protection:

### Essential Checks
- `R-CMD-check (ubuntu-latest, release)` - Basic package check
- `R-CMD-check (windows-latest, release)` - Windows compatibility
- `R-CMD-check (macOS-latest, release)` - macOS compatibility

### Advanced Checks (add gradually)
- `R-CMD-check (ubuntu-latest, devel)` - R development version
- `R-CMD-check (ubuntu-latest, oldrel-1)` - Older R version
- `test-coverage` - Code coverage requirements
- `lintr` - Code style checks (if you add this workflow)

### Optional Checks
- `spelling` - Documentation spelling
- `urls` - URL validation
- `pkgdown` - Documentation site build

## 🔄 Updating Protection Rules

Branch protection rules can be updated anytime:

1. Go to **Settings → Branches**
2. Click **Edit** next to the rule
3. Modify settings as needed
4. Click **Save changes**

Changes take effect immediately for new PRs.

---

## ⚠️ Important Notes

- **First-time setup**: Some status checks won't appear until workflows run at least once
- **Solo development**: You can set approvals to 0, but keep other protections
- **Team development**: Increase required approvals and enable code owner reviews
- **Signed commits**: Requires developers to set up GPG signing (optional)
- **Linear history**: Requires rebase/squash merging only (optional)

This setup ensures your `main` branch remains stable and production-ready while allowing flexible development in feature branches! 🎉