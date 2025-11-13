# frozen_string_literal: true

# Minimal gemspec for the edge_detection gem
Gem::Specification.new do |spec|
  spec.name          = 'edge_detection'
  spec.version       = '0.1.0'
  spec.summary       = 'Edge detection utilities'
  spec.description   = 'Small library for edge detection helpers'
  spec.authors       = ['Lennard Clicque']
  spec.email         = ['l.clicque@gmail.com']

  spec.files         = Dir['lib/**/*.rb']
  spec.homepage      = 'https://example.com/edge_detection'
  spec.license       = 'MIT'

  # Ensure RuboCop and other tools can determine a target Ruby version
  spec.required_ruby_version = Gem::Requirement.new('>= 2.7')
  spec.metadata['rubygems_mfa_required'] = 'true'

  # Image processing dependencies
  spec.add_dependency 'mini_magick', '~> 4.11'

  # Post-install message
  spec.post_install_message = <<~MESSAGE
    ╔═══════════════════════════════════════════════════════════════════════╗
    ║  edge_detection requires ImageMagick to be installed on your system  ║
    ║                                                                       ║
    ║  Ubuntu/Debian: sudo apt-get install imagemagick libmagickwand-dev   ║
    ║  macOS: brew install imagemagick                                     ║
    ║  Windows: https://imagemagick.org/script/download.php#windows        ║
    ╚═══════════════════════════════════════════════════════════════════════╝
  MESSAGE
end
