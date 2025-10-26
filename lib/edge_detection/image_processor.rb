module EdgeDetection
  # Wrapper class to handle both MiniMagick::Image and Magick::Image objects
  class ImageProcessor
    # Default parameter values for edge detection algorithms
    MINIMAGICK_CANNY_LOWER_THRESHOLD = 10
    MINIMAGICK_CANNY_UPPER_THRESHOLD = 30
    RMAGICK_CANNY_LOWER_THRESHOLD = 0.1
    RMAGICK_CANNY_UPPER_THRESHOLD = 0.3

    attr_reader :image, :image_type

    def initialize(image)
      @image = image
      @image_type = detect_image_type(image)
    end

    def mini_magick?
      @image_type == :mini_magick
    end

    def rmagick?
      @image_type == :rmagick
    end

    def apply_edge_detection(method_name, **options)
      case @image_type
      when :mini_magick
        apply_mini_magick_edge(method_name, **options)
      when :rmagick
        apply_rmagick_edge(method_name, **options)
      else
        raise Error, "Unsupported image type: #{@image.class}"
      end
    end

    private

    def detect_image_type(image)
      if defined?(MiniMagick::Image) && image.is_a?(MiniMagick::Image)
        :mini_magick
      elsif defined?(Magick::Image) && image.is_a?(Magick::Image)
        :rmagick
      else
        raise Error, "Image must be a MiniMagick::Image or Magick::Image (RMagick), got #{image.class}"
      end
    end

    def apply_mini_magick_edge(method_name, **options)
      case method_name
      when :canny
        # MiniMagick canny edge detection
        radius = options[:radius] || 0
        sigma = options[:sigma] || 1
        lower_threshold = options[:lower_threshold] || MINIMAGICK_CANNY_LOWER_THRESHOLD
        upper_threshold = options[:upper_threshold] || MINIMAGICK_CANNY_UPPER_THRESHOLD

        @image.combine_options do |c|
          c.colorspace "Gray"
          c.canny "#{radius}x#{sigma}+#{lower_threshold}%+#{upper_threshold}%"
        end
      when :sobel
        # MiniMagick sobel edge detection
        radius = options[:radius] || 0
        sigma = options[:sigma] || 1

        @image.combine_options do |c|
          c.colorspace "Gray"
          c.define "convolve:scale=50%!"
          c.bias "50%"
          c.morphology "Convolve", "Sobel:#{radius}x#{sigma}"
        end
      end
      @image
    end

    def apply_rmagick_edge(method_name, **options)
      case method_name
      when :canny
        # RMagick canny edge detection
        radius = options[:radius] || 0
        sigma = options[:sigma] || 1
        lower_threshold = options[:lower_threshold] || RMAGICK_CANNY_LOWER_THRESHOLD
        upper_threshold = options[:upper_threshold] || RMAGICK_CANNY_UPPER_THRESHOLD

        result = @image.quantize(256, Magick::GRAYColorspace)
        result = result.canny_edge_channel(radius, sigma, lower_threshold, upper_threshold)
        result
      when :sobel
        # RMagick edge detection using edge method
        radius = options[:radius] || 0
        sigma = options[:sigma] || 1

        result = @image.quantize(256, Magick::GRAYColorspace)
        result = result.edge(radius, sigma)
        result
      end
    end
  end
end
