# frozen_string_literal: true

require 'mini_magick'
require 'numo/narray'

# ImageRepresentation class for loading, processing, and edge detection on images
# Now using Numo::NArray for C-level performance
class ImageRepresentation
  attr_reader :width, :height

  def initialize(image = nil, pixels = [])
    @image = image

    if pixels.empty?
      @pixels = nil
      @height = 0
      @width = 0
    elsif pixels.is_a?(Numo::UInt8)
      # Already a NArray
      @pixels = pixels
      @height, @width = @pixels.shape
    else
      # Convert Ruby array to NArray
      ruby_pixels = pixels
      @height = ruby_pixels.length
      @width = ruby_pixels.any? ? ruby_pixels[0].length : 0
      @pixels = (ruby_array_to_narray(ruby_pixels) if @height.positive? && @width.positive?)
    end

    to_grayscale if @height.positive?
  end

  def load_image(file_path)
    @image = MiniMagick::Image.open(file_path)
    @width, @height = @image.dimensions
    ruby_pixels = @image.get_pixels
    @pixels = ruby_array_to_narray(ruby_pixels)
    to_grayscale
  end

  # Return pixels as Ruby array for backward compatibility
  def pixels
    return [] if @pixels.nil?

    narray_to_ruby_array(@pixels)
  end

  # Allow setting pixels (for tests) - automatically converts to NArray
  def pixels=(value)
    if value.is_a?(Numo::NArray)
      @pixels = value
      @height, @width = value.shape if value
    elsif value.is_a?(Array) && value.any?
      @height = value.length
      @width = value[0].length
      @pixels = ruby_array_to_narray(value)
    else
      @pixels = nil
      @height = 0
      @width = 0
    end
  end

  def dilation(structuring_element)
    morphological_operation(structuring_element, :max)
  end

  def erosion(structuring_element)
    morphological_operation(structuring_element, :min)
  end

  def copy
    copied_pixels = @pixels.dup
    ImageRepresentation.new(nil, copied_pixels)
  end

  def ==(other)
    return false unless other.is_a?(ImageRepresentation)
    return false if @width != other.width || @height != other.height

    pixels == other.pixels
  end

  alias eql? ==

  def hash
    [pixels, @width, @height].hash
  end

  def subtract(other_image)
    other_pixels_narray = other_image.instance_variable_get(:@pixels)
    return ImageRepresentation.new(nil, []) if @pixels.nil? || other_pixels_narray.nil?

    # Fast approach: Create mask first to detect underflow, then subtract
    result = @pixels - other_pixels_narray # This will wrap for negatives
    mask = @pixels < other_pixels_narray     # Find where underflow occurred
    result[mask] = 0                         # Fix wrapped values

    ImageRepresentation.new(nil, result)
  end

  private

  def morphological_operation(structuring_element, operation)
    return copy if @pixels.nil?

    se_height = structuring_element.length
    se_width = structuring_element[0].length
    pad_y = se_height / 2
    pad_x = se_width / 2

    # Pre-compute active positions
    active_positions = []
    se_height.times do |j|
      se_width.times do |i|
        active_positions << [j - pad_y, i - pad_x] if structuring_element[j][i] == 1
      end
    end

    # Create output array using NArray
    if operation == :max
      output = Numo::UInt8.zeros(@height, @width)

      # For dilation, start with the image itself
      output[] = @pixels

      # For each active position, shift the image and take max
      active_positions.each do |dy, dx|
        next if dy.zero? && dx.zero?

        # Calculate the region that overlaps after shifting
        src_y_start = [dy, 0].max
        src_y_end = [@height + dy, @height].min
        src_x_start = [dx, 0].max
        src_x_end = [@width + dx, @width].min

        dst_y_start = [-dy, 0].max
        dst_y_end = [@height - dy, @height].min
        dst_x_start = [-dx, 0].max
        dst_x_end = [@width - dx, @width].min

        next if src_y_start >= src_y_end || src_x_start >= src_x_end

        # Extract overlapping regions
        src_region = @pixels[src_y_start...src_y_end, src_x_start...src_x_end]
        dst_region = output[dst_y_start...dst_y_end, dst_x_start...dst_x_end]

        # Take element-wise maximum (vectorized in C)
        output[dst_y_start...dst_y_end, dst_x_start...dst_x_end] = Numo::UInt8.maximum(dst_region, src_region)
      end
    else
      # For erosion, start with max value
      output = Numo::UInt8.new(@height, @width).fill(255)

      # For erosion, check all positions and take minimum
      active_positions.each do |dy, dx|
        # Calculate the region that overlaps after shifting
        src_y_start = [dy, 0].max
        src_y_end = [@height + dy, @height].min
        src_x_start = [dx, 0].max
        src_x_end = [@width + dx, @width].min

        dst_y_start = [-dy, 0].max
        dst_y_end = [@height - dy, @height].min
        dst_x_start = [-dx, 0].max
        dst_x_end = [@width - dx, @width].min

        next if src_y_start >= src_y_end || src_x_start >= src_x_end

        # Extract overlapping regions
        src_region = @pixels[src_y_start...src_y_end, src_x_start...src_x_end]
        dst_region = output[dst_y_start...dst_y_end, dst_x_start...dst_x_end]

        # Take element-wise minimum (vectorized in C)
        output[dst_y_start...dst_y_end, dst_x_start...dst_x_end] = Numo::UInt8.minimum(dst_region, src_region)
      end
    end

    ImageRepresentation.new(nil, output)
  end

  def grayscale?
    return false if @pixels.nil? || @height.nil? || @width.nil?

    true if @pixels.ndim == 2
  end

  def to_grayscale
    return if @pixels.nil? || @height.nil? || @width.nil?
    return if grayscale?

    # Convert to grayscale using NArray for vectorized operations
    return unless @pixels.ndim == 3

    # RGB to grayscale: 0.3*R + 0.59*G + 0.11*B
    # Use integer math: (300*R + 590*G + 110*B) / 1000
    r = @pixels[true, true, 0]
    g = @pixels[true, true, 1]
    b = @pixels[true, true, 2]

    @pixels = (((300 * r) + (590 * g) + (110 * b)) / 1000).cast_to(Numo::UInt8)
  end

  # Helper methods to convert between Ruby arrays and NArray

  def ruby_array_to_narray(ruby_array)
    return nil if ruby_array.empty?

    height = ruby_array.length
    width = ruby_array[0].length

    # Check if grayscale (single value per pixel wrapped in array)
    # Grayscale: [[value]], RGB: [r, g, b]
    first_pixel = ruby_array[0][0]
    is_gray = first_pixel.is_a?(Array) && first_pixel.length == 1

    if is_gray
      # Create 2D array for grayscale
      data = ruby_array.flatten.map { |v| v.is_a?(Array) ? v[0] : v }
      Numo::UInt8.cast(data).reshape(height, width)
    else
      # Create 3D array for RGB/RGBA
      channels = first_pixel.is_a?(Array) ? first_pixel.length : 3

      flat_data = []
      ruby_array.each do |row|
        row.each do |pixel|
          if pixel.is_a?(Array)
            flat_data.concat(pixel)
          else
            flat_data << pixel
          end
        end
      end

      Numo::UInt8.cast(flat_data).reshape(height, width, channels)
    end
  end

  def narray_to_ruby_array(narray)
    return [] if narray.nil?

    if narray.ndim == 2
      # Grayscale: 2D array
      narray.to_a.map { |row| row.map { |v| [v] } }
    else
      # RGB: 3D array
      narray.to_a.map do |row|
        row.map { |pixel| pixel.is_a?(Array) ? pixel : [pixel] }
      end
    end
  end
end
