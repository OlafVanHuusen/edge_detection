# Testing Guide for Edge Detection Gem

## Test Structure

```
spec/
├── spec_helper.rb              # RSpec configuration
├── .gitignore                  # Ignore test artifacts
├── fixtures/                   # Test images and data
└── image/
    └── image_representation_spec.rb  # Tests for ImageRepresentation class
```

## Running Tests

### Run all tests
```bash
bundle exec rspec
```

### Run specific test file
```bash
bundle exec rspec spec/image/image_representation_spec.rb
```

### Run specific test by line number
```bash
bundle exec rspec spec/image/image_representation_spec.rb:25
```

### Run with Rake (includes RuboCop)
```bash
bundle exec rake
```

### Run only RSpec tests
```bash
bundle exec rake spec
```

## Code Coverage

After running tests, SimpleCov generates a coverage report in `coverage/index.html`. 
Open it in a browser to see detailed coverage information.

## Test Files Included

### `spec_helper.rb`
- Configures RSpec
- Enables SimpleCov code coverage
- Sets up test formatting and options

### `image_representation_spec.rb`
- Tests for ImageRepresentation class
- Includes tests for:
  - `#initialize` - Object initialization
  - `#load_image` - Image loading and grayscale conversion
  - `#dilation` - Morphological dilation operation
  - Edge cases and boundary conditions

## Writing New Tests

1. Create a new file in `spec/` matching the structure of `lib/`
2. Follow naming convention: `*_spec.rb`
3. Require `spec_helper` at the top
4. Use RSpec's `describe` and `context` blocks for organization

### Example Test Structure

```ruby
require 'spec_helper'
require_relative '../../lib/your_file'

RSpec.describe YourClass do
  describe '#method_name' do
    it 'describes expected behavior' do
      # Arrange
      subject = YourClass.new
      
      # Act
      result = subject.method_name
      
      # Assert
      expect(result).to eq(expected_value)
    end
  end
end
```

## Test Fixtures

Place test images and data in `spec/fixtures/`. The test suite will automatically 
create simple test images using MiniMagick if needed.

## Useful RSpec Options

- `--fail-fast` - Stop after first failure
- `--only-failures` - Run only previously failed tests
- `--format documentation` - Verbose output (default in this setup)
- `--format progress` - Minimal dot output

Example:
```bash
bundle exec rspec --fail-fast --format documentation
```

## Debugging Tests

Add `binding.pry` (after adding `gem 'pry'` to Gemfile) in your test or code to 
open an interactive debugging session.

## Performance Testing

To benchmark the dilation method performance, you can add:

```ruby
require 'benchmark'

it 'performs dilation efficiently' do
  large_image = create_large_test_image(1000, 1000)
  
  time = Benchmark.realtime do
    large_image.dilation(structuring_element)
  end
  
  expect(time).to be < 1.0  # Should complete in under 1 second
end
```

