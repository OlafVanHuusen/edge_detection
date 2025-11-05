# frozen_string_literal: true

require 'mini_magick'

# ImageRepresentation class for loading, processing, and edge detection on images
class ImageRepresentation
  attr_reader :width, :height, :pixels

  def initialize(image = nil, pixels = [])
    @image = image
    @pixels = pixels
    @width = pixels.length
    @height = pixels.any? ? pixels[0].length : 0
    to_grayscale
  end

  def load_image(file_path)
    @image = MiniMagick::Image.open(file_path)
    @width, @height = @image.dimensions
    @pixels = @image.get_pixels
    to_grayscale
  end

  def dilation(structuring_element)
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
    dilated_pixels = Array.new(@height) { Array.new(@width) }
    # Process each pixel
    @height.times do |y|
      @width.times do |x|
        max_value = 0
        # Only iterate over active structuring element positions
        active_positions.each do |dy, dx|
          ny = y + dy
          nx = x + dx
          # Bounds check
          next unless ny >= 0 && ny < @height && nx >= 0 && nx < @width

          # Direct comparison without array allocation
          pixel_value = @pixels[ny][nx][0]
          max_value = pixel_value if pixel_value > max_value
        end
        dilated_pixels[y][x] = [max_value]
      end
    end
    @pixels = dilated_pixels
    self
  end

  def erosion(structuring_element)
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
    eroded_pixels = Array.new(@height) { Array.new(@width) }
    # Process each pixel
    @height.times do |y|
      @width.times do |x|
        min_value = 255
        # Only iterate over active structuring element positions
        active_positions.each do |dy, dx|
          ny = y + dy
          nx = x + dx
          # Bounds check
          next unless ny >= 0 && ny < @height && nx >= 0 && nx < @width

          # Direct comparison without array allocation
          pixel_value = @pixels[ny][nx][0]
          min_value = pixel_value if pixel_value < min_value
        end
        eroded_pixels[y][x] = [min_value]
      end
    end
    @pixels = eroded_pixels
    self
  end

  def copy
    copied_pixels = @pixels.map { |row| row.map(&:dup) }
    ImageRepresentation.new(nil, copied_pixels)
  end

  private

  def to_grayscale
    # Convert image to grayscale and return pixel data
    return if @pixels.empty? || height.nil? || width.nil?

    (0...@height).each do |y|
      (0...@width).each do |x|
        r, g, b = @pixels[y][x]
        gray = ((0.3 * r) + (0.59 * g) + (0.11 * b)).to_i
        @pixels[y][x] = [gray]
      end
    end
  end
end
