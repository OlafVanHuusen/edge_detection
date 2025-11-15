# frozen_string_literal: true

require 'mini_magick'

# ImageRepresentation class for loading, processing, and edge detection on images
class ImageRepresentation
  attr_reader :width, :height, :pixels

  def initialize(image = nil, pixels = [])
    @image = image
    @pixels = pixels
    @height = pixels.length
    @width = pixels.any? ? pixels[0].length : 0
    to_grayscale
  end

  def load_image(file_path)
    @image = MiniMagick::Image.open(file_path)
    @width, @height = @image.dimensions
    @pixels = @image.get_pixels
    to_grayscale
  end

  def dilation(structuring_element)
    morphological_operation(structuring_element, 0) { |current, pixel| [current, pixel].max }
  end

  def erosion(structuring_element)
    morphological_operation(structuring_element, 255) { |current, pixel| [current, pixel].min }
  end

  def copy
    copied_pixels = @pixels.map { |row| row.map(&:dup) }
    ImageRepresentation.new(nil, copied_pixels)
  end

  def ==(other)
    return false unless other.is_a?(ImageRepresentation)
    return false if @width != other.width || @height != other.height

    @pixels == other.pixels
  end

  alias eql? ==

  def hash
    [@pixels, @width, @height].hash
  end

  def subtract(other_image)
    result_pixels = Array.new(@height) { Array.new(@width) }
    @height.times do |y|
      @width.times do |x|
        value = @pixels[y][x][0] - other_image.pixels[y][x][0]
        value = 0 if value.negative?
        result_pixels[y][x] = [value]
      end
    end
    ImageRepresentation.new(nil, result_pixels)
  end

  private

  def morphological_operation(structuring_element, initial_value)
    se_height = structuring_element.length
    se_width = structuring_element[0].length
    pad_y = se_height / 2
    pad_x = se_width / 2
    # Pre-compute active positions in structuring element
    active_positions = []
    se_height.times do |j|
      se_width.times do |i|
        active_positions << [j - pad_y, i - pad_x] if structuring_element[j][i] == 1
      end
    end
    # Pre-allocate output array
    output_pixels = Array.new(@height) { Array.new(@width) }
    # Process each pixel
    @height.times do |y|
      @width.times do |x|
        result_value = initial_value
        # Only iterate over active structuring element positions
        active_positions.each do |dy, dx|
          ny = y + dy
          nx = x + dx
          # Bounds check
          next unless ny >= 0 && ny < @height && nx >= 0 && nx < @width

          # Direct comparison without array allocation
          pixel_value = @pixels[ny][nx][0]
          result_value = yield(result_value, pixel_value)
        end
        output_pixels[y][x] = [result_value]
      end
    end
    @pixels = output_pixels
    copy
  end

  def is_grayscale?
    return false if @pixels.empty? || height.nil? || width.nil?

    (0...@height).each do |y|
      (0...@width).each do |x|
        return false if @pixels[y][x].length != 1
      end
    end
    true
  end

  def to_grayscale
    # Convert image to grayscale and return pixel data
    return if @pixels.empty? || height.nil? || width.nil?
    return if is_grayscale?

    (0...@height).each do |y|
      (0...@width).each do |x|
        r, g, b = @pixels[y][x]
        gray = ((0.3 * r) + (0.59 * g) + (0.11 * b)).to_i
        @pixels[y][x] = [gray]
      end
    end
  end
end
