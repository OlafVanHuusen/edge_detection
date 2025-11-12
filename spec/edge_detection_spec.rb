# frozen_string_literal: true

require 'spec_helper'
require 'mini_magick'

RSpec.describe EdgeDetection do
  include EdgeDetection

  describe '#dilation_erosion_edge_detection' do
    it 'performs edge detection and matches expected output' do
      # ========================================================================
      # ADJUST THESE PATHS: Replace 'test_image.png' and 'expected_edges.png'
      # with the actual names of your images
      # ========================================================================
      input_image_path = File.join(__dir__, 'fixtures', 'input', 'test_image.png')
      expected_image_path = File.join(__dir__, 'fixtures', 'expected', 'expected_edges.png')
      output_image_path = File.join(__dir__, 'fixtures', 'output', 'output_edges.png')
      # ========================================================================

      # Verify input image exists
      expect(File.exist?(input_image_path)).to be true, "Input image not found at: #{input_image_path}"

      # Verify expected image exists
      expect(File.exist?(expected_image_path)).to be true, "Expected image not found at: #{expected_image_path}"

      # Perform edge detection
      dilation_erosion_edge_detection(input_image_path, output_image_path)

      # Verify output was created
      expect(File.exist?(output_image_path)).to be true

      # Load both images for comparison
      output_image = MiniMagick::Image.open(output_image_path)
      expected_image = MiniMagick::Image.open(expected_image_path)

      # Compare dimensions
      expect(output_image.dimensions).to eq(expected_image.dimensions)

      # Compare pixel data
      output_pixels = output_image.get_pixels
      expected_pixels = expected_image.get_pixels

      # Calculate similarity (allowing for minor differences)
      total_pixels = output_pixels.length * output_pixels[0].length
      matching_pixels = 0

      output_pixels.each_with_index do |row, y|
        row.each_with_index do |pixel, x|
          # Compare grayscale values (first channel)
          expected_val = expected_pixels[y][x][0]
          output_val = pixel[0]
          # Allow small tolerance of 5 units
          matching_pixels += 1 if (expected_val - output_val).abs <= 5
        end
      end

      similarity_percentage = (matching_pixels.to_f / total_pixels * 100).round(2)

      puts "\nSimilarity: #{similarity_percentage}%"

      # Expect at least 95% similarity
      expect(similarity_percentage).to be >= 95.0,
        "Output image similarity is #{similarity_percentage}%, expected at least 95%"
    end
  end
end

