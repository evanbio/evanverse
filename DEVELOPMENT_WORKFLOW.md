# evanverse Development Workflow

This document outlines the complete development workflow for the evanverse R package, ensuring consistent, high-quality development practices and stable releases.

## 🏗️ Repository Structure

```
evanverse/
├── main        # 🚀 Production-ready releases only
├── dev         # 🔧 Main development integration branch
├── feature/*   # ✨ Individual feature development
├── hotfix/*    # 🚨 Emergency fixes to production
└── release/*   # 📦 Release preparation branches
```

## 🔄 Development Lifecycle

### 1. Feature Development

#### Starting a New Feature
```bash
# Always start from latest dev
git checkout dev
git pull origin dev

# Create feature branch
git checkout -b feature/descriptive-name
# Examples:
# feature/add-volcano-plot
# feature/improve-error-handling
# feature/update-documentation
```

#### During Development
```bash
# Regular commits with conventional format
git add .
git commit -m "feat(plotting): add volcano plot function"

# Keep your branch updated with dev
git checkout dev
git pull origin dev
git checkout feature/your-feature
git rebase dev  # Recommended over merge for cleaner history
```

#### Before Submitting PR
```bash
# Comprehensive testing
R -e "devtools::check()"      # Must pass with 0 errors/warnings
R -e "devtools::test()"       # All tests must pass
R -e "devtools::document()"   # Update documentation

# Check code style (optional but recommended)
R -e "styler::style_pkg()"
R -e "lintr::lint_package()"
```

### 2. Pull Request Process

#### Creating the PR
1. **Push your feature branch**:
   ```bash
   git push origin feature/your-feature
   ```

2. **Create PR on GitHub**:
   - **Base**: `main` (important: not `dev`)
   - **Head**: `feature/your-feature`
   - Use the PR template (auto-loaded)
   - Add descriptive title and details

#### PR Requirements
- ✅ All CI checks pass (R-CMD-check on multiple platforms)
- ✅ Test coverage maintained or improved
- ✅ Documentation updated (roxygen2, examples, NEWS.md)
- ✅ No merge conflicts with main
- ✅ Conventional commit messages
- ✅ Self-review completed

### 3. Code Review Process

#### For Contributors
- Respond to feedback promptly
- Make requested changes in new commits (don't force-push during review)
- Mark conversations as resolved when addressed
- Request re-review when ready

#### For Maintainers
- Review within 48 hours when possible
- Focus on code quality, testing, and documentation
- Check cross-platform compatibility for significant changes
- Ensure breaking changes are properly documented

### 4. Release Management

#### Patch Releases (0.0.x)
For bug fixes and minor improvements:

```bash
# Create release branch from main
git checkout main
git pull origin main
git checkout -b release/0.3.2

# Update version and documentation
# Edit DESCRIPTION: Version: 0.3.2
# Update NEWS.md with patch notes
# Update cran-comments.md

# Test thoroughly
R -e "devtools::check()"

# Commit and create PR to main
git add .
git commit -m "release: bump version to 0.3.2"
git push origin release/0.3.2
# Create PR: release/0.3.2 → main
```

#### Minor Releases (0.x.0)
For new features and enhancements:

```bash
# Merge dev into release branch
git checkout dev
git pull origin dev
git checkout -b release/0.4.0

# Update version and documentation
# Edit DESCRIPTION: Version: 0.4.0
# Update NEWS.md with comprehensive changes
# Update cran-comments.md

# Final testing and checks
R -e "devtools::check()"
R -e "devtools::build()"

# Create PR to main
git push origin release/0.4.0
# Create PR: release/0.4.0 → main
```

#### Post-Release Actions
After merging release PR:

```bash
# Switch to main and tag release
git checkout main
git pull origin main
git tag v0.3.2
git push origin v0.3.2

# Create GitHub release
gh release create v0.3.2 --title "evanverse 0.3.2" --notes-file RELEASE_NOTES.md

# Merge main back to dev
git checkout dev
git merge main
git push origin dev
```

## 🚨 Hotfix Process

For critical bugs in production:

```bash
# Create hotfix from main
git checkout main
git pull origin main
git checkout -b hotfix/fix-critical-bug

# Make minimal fix
# Update version (patch increment)
# Add to NEWS.md

# Test and create PR directly to main
R -e "devtools::check()"
git push origin hotfix/fix-critical-bug
# Create PR: hotfix/fix-critical-bug → main

# After merge, tag and merge back to dev
git checkout main
git pull origin main
git tag v0.3.3
git push origin v0.3.3
git checkout dev
git merge main
git push origin dev
```

## 🛠️ Development Tools & Commands

### Essential R Commands
```r
# Package development
devtools::load_all()          # Load package for testing
devtools::check()             # Comprehensive package check
devtools::test()              # Run test suite
devtools::document()          # Generate documentation

# Code quality
styler::style_pkg()           # Format code
lintr::lint_package()         # Code linting
spelling::spell_check_package() # Spell check

# Building and installing
devtools::build()             # Build source package
devtools::install()           # Install locally
devtools::build_vignettes()   # Build vignettes
```

### GitHub CLI Commands
```bash
# PR management
gh pr create --title "feat: add new function" --body "Description"
gh pr list --state open
gh pr checkout 123
gh pr merge 123 --squash

# Release management
gh release create v0.3.2 --title "Release 0.3.2"
gh release list

# Repository management
gh repo view
gh workflow list
gh run list
```

### Git Workflow Commands
```bash
# Daily workflow
git status
git log --oneline -5
git diff HEAD~1

# Branch management
git branch -a                 # List all branches
git branch -d feature/done    # Delete merged feature branch
git remote prune origin       # Clean up stale remote branches

# Conflict resolution
git rebase dev
# Fix conflicts, then:
git add .
git rebase --continue
```

## 📋 Quality Gates

### Pre-commit Checklist
- [ ] `devtools::check()` passes (0 errors, 0 warnings)
- [ ] All tests pass (`devtools::test()`)
- [ ] Documentation updated (`devtools::document()`)
- [ ] Examples run without errors
- [ ] NEWS.md updated for user-facing changes
- [ ] Commit messages follow conventional format

### Pre-release Checklist
- [ ] Version number updated in DESCRIPTION
- [ ] NEWS.md comprehensively updated
- [ ] cran-comments.md updated
- [ ] All CI checks pass
- [ ] Cross-platform testing completed
- [ ] Breaking changes documented
- [ ] CRAN submission ready (if applicable)

## 🎯 Best Practices

### Code Organization
- **One feature per branch**: Keep changes focused and reviewable
- **Atomic commits**: Each commit should represent a single logical change
- **Clear naming**: Use descriptive branch and commit names
- **Regular updates**: Rebase feature branches frequently to avoid conflicts

### Testing Strategy
- **Test-driven development**: Write tests before or alongside code
- **Comprehensive coverage**: Test normal cases, edge cases, and error conditions
- **Skip appropriately**: Use `skip_on_cran()` for network/long-running tests
- **Platform testing**: Consider cross-platform implications

### Documentation Standards
- **Roxygen2 for all exports**: Complete parameter and return documentation
- **Executable examples**: All examples should run without errors
- **User guides**: Update vignettes for major new features
- **API stability**: Document breaking changes clearly

### Performance Considerations
- **Profile before optimizing**: Use `profvis` to identify bottlenecks
- **Memory efficiency**: Consider memory usage for large datasets
- **Dependencies**: Minimize heavy dependencies, use Suggests when possible
- **Backwards compatibility**: Avoid breaking changes when possible

## 🔍 Troubleshooting

### Common Issues

#### "R CMD check" Failures
```r
# Fix missing documentation
devtools::document()

# Fix failing examples
# Wrap problematic examples:
#' @examples
#' \dontrun{
#'   # Code that requires special setup
#' }

# Fix global variable NOTEs
# Add to R/zzz.R:
utils::globalVariables(c("variable_name"))
```

#### CI Failures
```bash
# Download CI logs
gh run download RUN_ID

# Reproduce locally
R -e "devtools::check(env_vars = c('NOT_CRAN' = 'false'))"
```

#### Merge Conflicts
```bash
# Rebase approach (recommended)
git checkout feature/your-branch
git rebase dev
# Resolve conflicts in files
git add .
git rebase --continue

# Merge approach (alternative)
git checkout feature/your-branch
git merge dev
# Resolve conflicts in files
git commit
```

### Getting Help
- **Package issues**: Use GitHub Issues with reproducible examples
- **Workflow questions**: Check this document or ask in Discussions
- **R-specific help**: Use R help system (`?function_name`) or Stack Overflow
- **Git problems**: Git documentation or GitHub support

## 📊 Monitoring & Metrics

### Repository Health
- **CI success rate**: Aim for >95% passing builds
- **Test coverage**: Maintain >80% code coverage
- **Issue resolution**: Respond to issues within 48 hours
- **PR turnaround**: Review PRs within 2-3 days

### Release Cadence
- **Patch releases**: As needed for bug fixes
- **Minor releases**: Every 2-3 months
- **Major releases**: Annually or for significant changes
- **CRAN submissions**: After thorough testing and validation

---

## 🎉 Success Metrics

A successful development workflow should achieve:

- ✅ **Stable main branch**: Always deployable and release-ready
- ✅ **Fast feedback**: CI results within 10-15 minutes
- ✅ **High quality**: Minimal bugs in releases
- ✅ **Good documentation**: Users can easily adopt new features
- ✅ **Active development**: Regular improvements and community engagement

**Happy developing! 🚀**

Remember: This workflow is designed to support both solo development and team collaboration. Adjust the strictness of requirements based on your team size and release frequency.