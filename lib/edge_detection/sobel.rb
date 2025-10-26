module EdgeDetection
  # Sobel edge detection implementation
  class Sobel
    # Detect edges using the Sobel algorithm
    # @param processor [ImageProcessor] The image processor wrapping the image
    # @param radius [Numeric] The radius of the convolution kernel (default: 0)
    # @param sigma [Numeric] The standard deviation for the convolution (default: 1)
    # @return [MiniMagick::Image, Magick::Image] The processed image
    def self.detect(processor, radius: nil, sigma: nil)
      options = {}
      options[:radius] = radius if radius
      options[:sigma] = sigma if sigma

      processor.apply_edge_detection(:sobel, **options)
    end
  end
end
