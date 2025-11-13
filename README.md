# edge_detection

[![Lint](https://github.com/OlafVanHuusen/edge_detection/actions/workflows/lint.yml/badge.svg)](https://github.com/OlafVanHuusen/edge_detection/actions/workflows/lint.yml)
[![CI](https://github.com/OlafVanHuusen/edge_detection/actions/workflows/ci.yml/badge.svg)](https://github.com/OlafVanHuusen/edge_detection/actions/workflows/ci.yml)

A Ruby gem for easy edge detection in images.

## Development

### Prerequisites

- Ruby 2.7 or higher
- Bundler
- ImageMagick (system dependency)

### Setup

Install ImageMagick first:

**On Ubuntu/Debian:**
```bash
sudo apt-get update
sudo apt-get install -y imagemagick libmagickwand-dev
```

**On macOS:**
```bash
brew install imagemagick
```

**On Windows:**
Download and install from [ImageMagick website](https://imagemagick.org/script/download.php#windows)

Then install Ruby dependencies:
```bash
bundle install
```

### Code Quality

This project uses RuboCop for code quality and style checking:

```bash
# Install RuboCop (until a Gemfile is added)
gem install rubocop

# Run linting
rubocop

# Auto-fix issues where possible
rubocop -a
```

*Note: Once the gem structure is fully set up, RuboCop will be managed via Bundler.*

### Running Tests

```bash
# Tests will be added soon
rake test
```

## Contributing

Please read [CONTRIBUTING.md](.github/CONTRIBUTING.md) for details on our code of conduct and the process for submitting pull requests.

### Branch Protection

This repository uses branch protection rules. See [BRANCH_PROTECTION.md](.github/BRANCH_PROTECTION.md) for configuration details.

## CI/CD Pipeline

This project includes automated workflows:

- **Lint**: Automatic RuboCop checks on all PRs
- **CI**: Test suite runs across Ruby 2.7, 3.0, 3.1, and 3.2
- **Dependabot**: Automated dependency updates

## License

See [LICENSE](LICENSE) file for details
