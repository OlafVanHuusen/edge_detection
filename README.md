# EdgeDetection

A Ruby gem for easy edge detection in images. Supports both Canny and Sobel edge detection algorithms and works seamlessly with MiniMagick::Image and RMagick (Magick::Image) objects.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'edge_detection'
```

And then execute:

```bash
$ bundle install
```

Or install it yourself as:

```bash
$ gem install edge_detection
```

## Usage

### Basic Usage

```ruby
require 'edge_detection'
require 'mini_magick'

# Load an image with MiniMagick
image = MiniMagick::Image.open('path/to/image.jpg')

# Detect edges using Canny (default algorithm)
result = EdgeDetection.detect(image)

# Or explicitly specify the algorithm
result = EdgeDetection.detect(image, algorithm: :canny)

# Use Sobel edge detection
result = EdgeDetection.detect(image, algorithm: :sobel)

# Save the result
result.write('output.jpg')
```

### With RMagick

```ruby
require 'edge_detection'
require 'rmagick'

# Load an image with RMagick
image = Magick::Image.read('path/to/image.jpg').first

# Detect edges
result = EdgeDetection.detect(image, algorithm: :canny)

# Save the result
result.write('output.jpg')
```

### Advanced Options

#### Canny Edge Detection

```ruby
# Customize Canny parameters
result = EdgeDetection.detect(image, 
  algorithm: :canny,
  radius: 0,                # Gaussian filter radius (default: 0)
  sigma: 1,                 # Gaussian filter sigma (default: 1)
  lower_threshold: 10,      # Lower threshold (default: 10 for MiniMagick, 0.1 for RMagick)
  upper_threshold: 30       # Upper threshold (default: 30 for MiniMagick, 0.3 for RMagick)
)
```

#### Sobel Edge Detection

```ruby
# Customize Sobel parameters
result = EdgeDetection.detect(image,
  algorithm: :sobel,
  radius: 0,                # Convolution kernel radius (default: 0)
  sigma: 1                  # Standard deviation (default: 1)
)
```

### Configuration

You can set a default algorithm:

```ruby
EdgeDetection.configure do |config|
  config.default_algorithm = :sobel
end

# Now :sobel will be used by default
result = EdgeDetection.detect(image)
```

## Algorithms

### Canny Edge Detection

The Canny edge detector is a multi-stage algorithm that detects a wide range of edges in images. It's particularly good at detecting edges while suppressing noise.

**Parameters:**
- `radius`: The radius of the Gaussian filter
- `sigma`: The standard deviation of the Gaussian filter
- `lower_threshold`: Lower threshold for hysteresis
- `upper_threshold`: Upper threshold for hysteresis

### Sobel Edge Detection

The Sobel operator performs a 2D spatial gradient measurement on an image and emphasizes regions of high spatial frequency (edges).

**Parameters:**
- `radius`: The radius of the convolution kernel
- `sigma`: The standard deviation for the convolution

## Requirements

- Ruby >= 2.5.0
- ImageMagick (required by both MiniMagick and RMagick)

## Development

After checking out the repo, run `bundle install` to install dependencies. Then, run `rake spec` to run the tests.

## Contributing

Bug reports and pull requests are welcome on GitHub at https://github.com/OlafVanHuusen/edge_detection.

## License

The gem is available as open source under the terms of the [MIT License](https://opensource.org/licenses/MIT).
