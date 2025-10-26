# Contributing to edge_detection

Thank you for your interest in contributing to edge_detection! This guide will help you get started.

## Development Setup

1. Fork and clone the repository
2. Install Ruby (version 2.7 or higher recommended)
3. Install dependencies (when Gemfile is added):
   ```bash
   bundle install
   ```

## Code Quality

This project uses automated linting and testing to maintain code quality.

### Linting with RuboCop

Before submitting a pull request, ensure your code passes RuboCop checks:

```bash
# Install RuboCop
gem install rubocop

# Check your code
rubocop

# Auto-fix issues where possible
rubocop -a
```

RuboCop configuration is in `.rubocop.yml`. Please follow the project's style guidelines.

## Pull Request Process

1. Create a feature branch from `main`
2. Make your changes
3. Run linters locally: `rubocop`
4. Run tests locally (when available): `rake test` or `rake spec`
5. Commit your changes with clear commit messages
6. Push to your fork
7. Open a pull request against the `main` branch

### Pull Request Requirements

All pull requests must:
- ✅ Pass RuboCop linting checks
- ✅ Pass all test suites (when tests are added)
- ✅ Include appropriate test coverage for new features
- ✅ Have a clear description of changes
- ✅ Reference any related issues

The automated CI/CD pipeline will run these checks automatically when you open a PR.

## Branch Protection

The `main` branch is protected with the following requirements:
- Pull request reviews required
- Status checks must pass (RuboCop, tests)
- Conversations must be resolved

See `.github/BRANCH_PROTECTION.md` for detailed information about branch protection setup.

## Code Style

- Follow the Ruby Style Guide
- Use single quotes for strings (unless interpolation is needed)
- Maximum line length: 120 characters
- Write clear, descriptive variable and method names
- Add comments for complex logic

## Getting Help

If you have questions or need help:
- Open an issue for bugs or feature requests
- Check existing issues and pull requests
- Review the project documentation

## License

By contributing, you agree that your contributions will be licensed under the same license as the project.
