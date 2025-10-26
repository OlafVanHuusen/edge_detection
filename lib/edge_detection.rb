require_relative "edge_detection/version"
require_relative "edge_detection/canny"
require_relative "edge_detection/sobel"
require_relative "edge_detection/image_processor"

module EdgeDetection
  class Error < StandardError; end

  class << self
    attr_accessor :default_algorithm

    def configure
      yield self if block_given?
    end
  end

  # Set default algorithm to :canny
  @default_algorithm = :canny

  # Main entry point for edge detection
  # @param image [MiniMagick::Image, Magick::Image] The image to process
  # @param algorithm [Symbol] The edge detection algorithm to use (:canny or :sobel)
  # @param options [Hash] Additional options for the algorithm
  # @return [MiniMagick::Image, Magick::Image] Processed image with edges detected
  def self.detect(image, algorithm: nil, **options)
    algorithm ||= @default_algorithm
    
    processor = ImageProcessor.new(image)
    
    case algorithm
    when :canny
      Canny.detect(processor, **options)
    when :sobel
      Sobel.detect(processor, **options)
    else
      raise Error, "Unknown algorithm: #{algorithm}. Use :canny or :sobel"
    end
  end
end
