require_relative 'lib/edge_detection/version'

Gem::Specification.new do |spec|
  spec.name          = "edge_detection"
  spec.version       = EdgeDetection::VERSION
  spec.authors       = ["Olaf Van Huusen"]
  spec.email         = ["olaf@example.com"]

  spec.summary       = "A Ruby gem for easy edge detection in images"
  spec.description   = "Provides easy-to-use edge extraction from images with support for Canny and Sobel edge detection algorithms. Works with MiniMagick::Image and RMagick objects."
  spec.homepage      = "https://github.com/OlafVanHuusen/edge_detection"
  spec.license       = "MIT"
  spec.required_ruby_version = Gem::Requirement.new(">= 2.5.0")

  spec.metadata["homepage_uri"] = spec.homepage
  spec.metadata["source_code_uri"] = "https://github.com/OlafVanHuusen/edge_detection"

  spec.files         = Dir["lib/**/*", "LICENSE", "README.md"]
  spec.require_paths = ["lib"]

  spec.add_dependency "mini_magick", "~> 4.11"
  spec.add_dependency "rmagick", "~> 4.2"

  spec.add_development_dependency "rake", "~> 13.0"
  spec.add_development_dependency "rspec", "~> 3.10"
end
