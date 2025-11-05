# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/Image/image_representation'
require 'mini_magick'

RSpec.describe ImageRepresentation do
  let(:image_rep) { described_class.new }

  describe '#initialize' do
    it 'initializes with empty dimensions' do
      expect(image_rep.width).to eq(0)
      expect(image_rep.height).to eq(0)
      expect(image_rep.pixels).to eq([])
    end
  end

  describe '#dilation' do
    before do
      # Create a simple 5x5 test image manually
      test_pixels = Array.new(5) { Array.new(5) { [0] } }
      test_pixels[2][2] = [255] # Center pixel is bright

      image_rep.instance_variable_set(:@width, 5)
      image_rep.instance_variable_set(:@height, 5)
      image_rep.instance_variable_set(:@pixels, test_pixels)
    end

    context 'with a 3x3 square structuring element' do
      let(:structuring_element) do
        [
          [1, 1, 1],
          [1, 1, 1],
          [1, 1, 1]
        ]
      end

      it 'dilates the image correctly' do
        result = image_rep.dilation(structuring_element)

        # The dilation should spread the bright pixel to its neighbors
        expect(result).to eq(image_rep) # Returns self for chaining

        # Check that the center and surrounding pixels are now bright
        expect(image_rep.pixels[1][1][0]).to eq(255)
        expect(image_rep.pixels[1][2][0]).to eq(255)
        expect(image_rep.pixels[2][1][0]).to eq(255)
        expect(image_rep.pixels[2][2][0]).to eq(255)

        # Corner pixels should still be dark
        expect(image_rep.pixels[0][0][0]).to eq(0)
        expect(image_rep.pixels[4][4][0]).to eq(0)
      end

      it 'updates the pixels array' do
        original_pixels = image_rep.pixels
        image_rep.dilation(structuring_element)

        # Should have updated the pixels
        expect(image_rep.pixels).not_to equal(original_pixels)
      end
    end

    context 'with a cross-shaped structuring element' do
      let(:structuring_element) do
        [
          [0, 1, 0],
          [1, 1, 1],
          [0, 1, 0]
        ]
      end

      it 'dilates only in cross pattern' do
        image_rep.dilation(structuring_element)

        # Check that only cross pattern is dilated
        expect(image_rep.pixels[2][1][0]).to eq(255)  # Left
        expect(image_rep.pixels[2][3][0]).to eq(255)  # Right
        expect(image_rep.pixels[1][2][0]).to eq(255)  # Top
        expect(image_rep.pixels[3][2][0]).to eq(255)  # Bottom
        expect(image_rep.pixels[2][2][0]).to eq(255)  # Center

        # Diagonal pixels should remain dark
        expect(image_rep.pixels[1][1][0]).to eq(0)
        expect(image_rep.pixels[1][3][0]).to eq(0)
      end
    end

    context 'edge cases' do
      it 'handles edge pixels correctly' do
        # Place bright pixel at corner
        test_pixels = Array.new(5) { Array.new(5) { [0] } }
        test_pixels[0][0] = [255]
        image_rep.instance_variable_set(:@pixels, test_pixels)

        structuring_element = [[1, 1], [1, 1]]

        expect { image_rep.dilation(structuring_element) }.not_to raise_error
      end
    end
  end

  describe '#erosion' do
    before do
      # Create a simple 5x5 test image manually
      test_pixels = Array.new(5) { Array.new(5) { [255] } }
      test_pixels[2][2] = [0] # Center pixel is dark

      image_rep.instance_variable_set(:@width, 5)
      image_rep.instance_variable_set(:@height, 5)
      image_rep.instance_variable_set(:@pixels, test_pixels)
    end

    context 'with a 3x3 square structuring element' do
      let(:structuring_element) do
        [
          [1, 1, 1],
          [1, 1, 1],
          [1, 1, 1]
        ]
      end

      it 'erodes the image correctly' do
        result = image_rep.erosion(structuring_element)

        # The erosion should spread the dark pixel to its neighbors
        expect(result).to eq(image_rep) # Returns self for chaining

        # Check that the center and surrounding pixels are now dark
        expect(image_rep.pixels[1][1][0]).to eq(0)
        expect(image_rep.pixels[1][2][0]).to eq(0)
        expect(image_rep.pixels[2][1][0]).to eq(0)
        expect(image_rep.pixels[2][2][0]).to eq(0)

        # Corner pixels should still be bright
        expect(image_rep.pixels[0][0][0]).to eq(255)
        expect(image_rep.pixels[4][4][0]).to eq(255)
      end

      it 'updates the pixels array' do
        original_pixels = image_rep.pixels
        image_rep.erosion(structuring_element)

        # Should have updated the pixels
        expect(image_rep.pixels).not_to equal(original_pixels)
      end
    end

    context 'with a cross-shaped structuring element' do
      let(:structuring_element) do
        [
          [0, 1, 0],
          [1, 1, 1],
          [0, 1, 0]
        ]
      end

      it 'erodes only in cross pattern' do
        image_rep.erosion(structuring_element)

        # Check that only cross pattern is eroded
        expect(image_rep.pixels[2][1][0]).to eq(0)  # Left
        expect(image_rep.pixels[2][3][0]).to eq(0)  # Right
        expect(image_rep.pixels[1][2][0]).to eq(0)  # Top
        expect(image_rep.pixels[3][2][0]).to eq(0)  # Bottom
        expect(image_rep.pixels[2][2][0]).to eq(0)  # Center

        # Diagonal pixels should remain bright
        expect(image_rep.pixels[1][1][0]).to eq(255)
        expect(image_rep.pixels[1][3][0]).to eq(255)
      end
    end

    context 'edge cases' do
      it 'handles edge pixels correctly' do
        # Place dark pixel at corner
        test_pixels = Array.new(5) { Array.new(5) { [255] } }
        test_pixels[0][0] = [0]
        image_rep.instance_variable_set(:@pixels, test_pixels)

        structuring_element = [[1, 1], [1, 1]]

        expect { image_rep.erosion(structuring_element) }.not_to raise_error
      end
    end
  end
end
