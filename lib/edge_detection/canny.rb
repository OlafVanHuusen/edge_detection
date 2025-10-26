module EdgeDetection
  # Canny edge detection implementation
  class Canny
    # Detect edges using the Canny algorithm
    # @param processor [ImageProcessor] The image processor wrapping the image
    # @param radius [Numeric] The radius of the Gaussian filter (default: 0)
    # @param sigma [Numeric] The standard deviation of the Gaussian filter (default: 1)
    # @param lower_threshold [Numeric] Lower threshold for edge detection (default: 10 for MiniMagick, 0.1 for RMagick)
    # @param upper_threshold [Numeric] Upper threshold for edge detection (default: 30 for MiniMagick, 0.3 for RMagick)
    # @return [MiniMagick::Image, Magick::Image] The processed image
    def self.detect(processor, radius: nil, sigma: nil, lower_threshold: nil, upper_threshold: nil)
      options = {}
      options[:radius] = radius if radius
      options[:sigma] = sigma if sigma
      options[:lower_threshold] = lower_threshold if lower_threshold
      options[:upper_threshold] = upper_threshold if upper_threshold

      processor.apply_edge_detection(:canny, **options)
    end
  end
end
