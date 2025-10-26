# Branch Protection Setup

This document explains how to configure branch protection rules for the repository.

## Automated Checks

The following GitHub Actions workflows have been configured:

1. **Lint** (`lint.yml`) - Runs RuboCop to check Ruby code style and quality
2. **CI** (`ci.yml`) - Runs tests across multiple Ruby versions (2.7, 3.0, 3.1, 3.2)

## Configuring Branch Protection

To enable branch protection on GitHub:

1. Go to the repository on GitHub
2. Navigate to **Settings** → **Branches**
3. Click **Add rule** under "Branch protection rules"
4. Configure the following settings:

### Recommended Settings

**Branch name pattern:** `main` (or `master` depending on your default branch)

#### Protect matching branches:
- ✅ **Require a pull request before merging**
  - Require approvals: 1 (minimum)
  - Dismiss stale pull request approvals when new commits are pushed
  
- ✅ **Require status checks to pass before merging**
  - Require branches to be up to date before merging
  - Status checks that are required:
    - `RuboCop` (from the Lint workflow)
    - `Ruby 3.2` (from the CI workflow)
    
- ✅ **Require conversation resolution before merging**

- ✅ **Do not allow bypassing the above settings**

#### Optional but recommended:
- ✅ **Require linear history** - Prevents merge commits
- ✅ **Include administrators** - Apply rules to repository administrators too

### For Development Branch (if using)

If you use a `develop` branch, create a similar rule with:
- Branch name pattern: `develop`
- Same protection settings as above

## Local Development

### Running Linters Locally

Before pushing code, run RuboCop locally:

```bash
# Install RuboCop
gem install rubocop

# Run RuboCop
rubocop

# Auto-fix issues where possible
rubocop -a
```

### RuboCop Configuration

The repository includes a `.rubocop.yml` configuration file with:
- Target Ruby version: 2.7+
- Line length limit: 120 characters
- Single quotes for strings
- Documentation requirements disabled for now
- Test files excluded from some metrics

## Workflow Triggers

All workflows are triggered on:
- Pushes to `main`, `master`, or `develop` branches
- Pull requests targeting `main`, `master`, or `develop` branches

## Next Steps

1. Set up branch protection rules in GitHub Settings
2. Add tests to the repository (the CI workflow is ready for them)
3. Consider adding additional checks:
   - Code coverage requirements
   - Security scanning (Dependabot, CodeQL)
   - Documentation generation
   - Gem publishing automation
