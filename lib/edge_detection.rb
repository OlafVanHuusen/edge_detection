# frozen_string_literal: true

require_relative 'Image/image_representation'
require 'mini_magick'
require 'tempfile'

module EdgeDetection

  def dilation_erosion_edge_detection(input_image_path, output_image_path, structuring_element = nil, repeats = 0)
    structuring_element ||= get_default_structuring_element_3x3
    image_rep = create_image_representation(input_image_path)
    edge_image_rep = dilation_erosion_substraction(image_rep, structuring_element, repeats)
    store_image(edge_image_rep, output_image_path)
  end

  private

  def store_image(image_rep, output_path)
    # Flatten the 2D array of [gray_value] arrays to a single byte array
    pixels = image_rep.pixels
    pixel_data = pixels.flatten.flatten.pack('C*')

    # Write raw pixel data to a temporary file
    temp_file = Tempfile.new(['raw_image', '.gray'])
    temp_file.binmode
    temp_file.write(pixel_data)
    temp_file.close

    # Use ImageMagick's convert to create PNG from raw gray data
    MiniMagick::Tool::Convert.new do |convert|
      convert.size "#{image_rep.width}x#{image_rep.height}"
      convert.depth 8
      convert << "gray:#{temp_file.path}"
      convert << output_path
    end

    temp_file.unlink
  end

  def dilation_erosion_substraction(image_rep, structuring_element, repeats = 0)
    dilated_image = image_rep.dilation(structuring_element)
    eroded_image = image_rep.erosion(structuring_element)

    repeats.times do
      dilated_image = dilated_image.dilation(structuring_element)
      eroded_image = eroded_image.erosion(structuring_element)
    end
    dilated_image.subtract(eroded_image)
  end

  def create_image_representation(image_path)
    image_rep = ImageRepresentation.new
    image_rep.load_image(image_path)
    image_rep
  end

  def get_default_structuring_element_3x3
    [
      [1, 1, 1],
      [1, 1, 1],
      [1, 1, 1]
    ]
  end
end
