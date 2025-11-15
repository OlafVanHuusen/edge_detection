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

      image_rep.pixels = test_pixels
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
        expect(result).to be_a(ImageRepresentation)
        expect(result).not_to eq(image_rep) # Returns a new object

        # Check that the center and surrounding pixels are now bright in the result
        expect(result.pixels[1][1][0]).to eq(255)
        expect(result.pixels[1][2][0]).to eq(255)
        expect(result.pixels[2][1][0]).to eq(255)
        expect(result.pixels[2][2][0]).to eq(255)

        # Corner pixels should still be dark
        expect(result.pixels[0][0][0]).to eq(0)
        expect(result.pixels[4][4][0]).to eq(0)
      end

      it 'returns a new image representation' do
        original_pixels = image_rep.pixels.dup
        result = image_rep.dilation(structuring_element)

        # Should return a new object
        expect(result).to be_a(ImageRepresentation)
        expect(result).not_to equal(image_rep)

        # Original should be unchanged
        expect(image_rep.pixels).to eq(original_pixels)

        # Result should be different
        expect(result.pixels).not_to eq(original_pixels)
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
        result = image_rep.dilation(structuring_element)

        # Check that only cross pattern is dilated in the result
        expect(result.pixels[2][1][0]).to eq(255)  # Left
        expect(result.pixels[2][3][0]).to eq(255)  # Right
        expect(result.pixels[1][2][0]).to eq(255)  # Top
        expect(result.pixels[3][2][0]).to eq(255)  # Bottom
        expect(result.pixels[2][2][0]).to eq(255)  # Center

        # Diagonal pixels should remain dark
        expect(result.pixels[1][1][0]).to eq(0)
        expect(result.pixels[1][3][0]).to eq(0)
      end
    end

    context 'edge cases' do
      it 'handles edge pixels correctly' do
        # Place bright pixel at corner
        test_pixels = Array.new(5) { Array.new(5) { [0] } }
        test_pixels[0][0] = [255]
        image_rep.pixels = test_pixels

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

      image_rep.pixels = test_pixels
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
        expect(result).to be_a(ImageRepresentation)
        expect(result).not_to eq(image_rep) # Returns a new object

        # Check that the center and surrounding pixels are now dark in the result
        expect(result.pixels[1][1][0]).to eq(0)
        expect(result.pixels[1][2][0]).to eq(0)
        expect(result.pixels[2][1][0]).to eq(0)
        expect(result.pixels[2][2][0]).to eq(0)

        # Corner pixels should still be bright
        expect(result.pixels[0][0][0]).to eq(255)
        expect(result.pixels[4][4][0]).to eq(255)
      end

      it 'returns a new image representation' do
        original_pixels = image_rep.pixels.dup
        result = image_rep.erosion(structuring_element)

        # Should return a new object
        expect(result).to be_a(ImageRepresentation)
        expect(result).not_to equal(image_rep)

        # Original should be unchanged
        expect(image_rep.pixels).to eq(original_pixels)

        # Result should be different
        expect(result.pixels).not_to eq(original_pixels)
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
        result = image_rep.erosion(structuring_element)

        # Check that only cross pattern is eroded in the result
        expect(result.pixels[2][1][0]).to eq(0)  # Left
        expect(result.pixels[2][3][0]).to eq(0)  # Right
        expect(result.pixels[1][2][0]).to eq(0)  # Top
        expect(result.pixels[3][2][0]).to eq(0)  # Bottom
        expect(result.pixels[2][2][0]).to eq(0)  # Center

        # Diagonal pixels should remain bright
        expect(result.pixels[1][1][0]).to eq(255)
        expect(result.pixels[1][3][0]).to eq(255)
      end
    end

    context 'edge cases' do
      it 'handles edge pixels correctly' do
        # Place dark pixel at corner
        test_pixels = Array.new(5) { Array.new(5) { [255] } }
        test_pixels[0][0] = [0]
        image_rep.pixels = test_pixels

        structuring_element = [[1, 1], [1, 1]]

        expect { image_rep.erosion(structuring_element) }.not_to raise_error
      end
    end
  end

  describe '#subtract' do
    let(:image1) { described_class.new }
    let(:image2) { described_class.new }

    before do
      # Create two simple 3x3 test images
      pixels1 = [
        [[200], [150], [100]],
        [[180], [120], [80]],
        [[160], [100], [60]]
      ]

      pixels2 = [
        [[50], [50], [50]],
        [[80], [20], [30]],
        [[60], [50], [40]]
      ]

      image1.pixels = pixels1
      image2.pixels = pixels2
    end

    it 'subtracts one image from another correctly' do
      result = image1.subtract(image2)

      # Check that result is a new ImageRepresentation
      expect(result).to be_a(ImageRepresentation)
      expect(result).not_to eq(image1)

      # Check specific pixel values (200-50=150, 150-50=100, etc.)
      expect(result.pixels[0][0][0]).to eq(150)
      expect(result.pixels[0][1][0]).to eq(100)
      expect(result.pixels[0][2][0]).to eq(50)
      expect(result.pixels[1][0][0]).to eq(100)
      expect(result.pixels[1][1][0]).to eq(100)
    end

    it 'clamps negative values to zero' do
      # Create case where subtraction would result in negative value
      pixels1 = [[[50], [30], [10]]]
      pixels2 = [[[100], [50], [20]]]

      image1.pixels = pixels1
      image2.pixels = pixels2

      result = image1.subtract(image2)

      # Negative results should be clamped to 0
      expect(result.pixels[0][0][0]).to eq(0)  # 50-100 = -50 -> 0
      expect(result.pixels[0][1][0]).to eq(0)  # 30-50 = -20 -> 0
      expect(result.pixels[0][2][0]).to eq(0)  # 10-20 = -10 -> 0
    end
  end

  describe 'array conversion methods' do
    describe '#ruby_array_to_narray' do
      it 'converts a grayscale Ruby array to NArray' do
        ruby_array = [
          [[100], [150], [200]],
          [[50], [75], [125]],
          [[25], [50], [75]]
        ]

        narray = image_rep.send(:ruby_array_to_narray, ruby_array)

        expect(narray).to be_a(Numo::NArray)
        expect(narray.shape).to eq([3, 3])
        expect(narray[0, 0]).to eq(100)
        expect(narray[1, 1]).to eq(75)
        expect(narray[2, 2]).to eq(75)
      end

      it 'converts an RGB Ruby array to NArray' do
        ruby_array = [
          [[255, 0, 0], [0, 255, 0]],
          [[0, 0, 255], [128, 128, 128]]
        ]

        narray = image_rep.send(:ruby_array_to_narray, ruby_array)

        expect(narray).to be_a(Numo::NArray)
        expect(narray.shape).to eq([2, 2, 3])
        expect(narray[0, 0, 0]).to eq(255) # Red channel
        expect(narray[0, 1, 1]).to eq(255) # Green channel
        expect(narray[1, 0, 2]).to eq(255) # Blue channel
      end

      it 'returns nil for empty array' do
        narray = image_rep.send(:ruby_array_to_narray, [])
        expect(narray).to be_nil
      end
    end

    describe '#narray_to_ruby_array' do
      it 'converts a grayscale NArray to Ruby array' do
        narray = Numo::UInt8[[100, 150], [50, 75]]

        ruby_array = image_rep.send(:narray_to_ruby_array, narray)

        expect(ruby_array).to be_a(Array)
        expect(ruby_array.length).to eq(2)
        expect(ruby_array[0][0]).to eq([100])
        expect(ruby_array[0][1]).to eq([150])
        expect(ruby_array[1][0]).to eq([50])
        expect(ruby_array[1][1]).to eq([75])
      end

      it 'converts an RGB NArray to Ruby array' do
        narray = Numo::UInt8.zeros(2, 2, 3)
        narray[0, 0, 0] = 255 # Red
        narray[0, 1, 1] = 255 # Green
        narray[1, 0, 2] = 255 # Blue

        ruby_array = image_rep.send(:narray_to_ruby_array, narray)

        expect(ruby_array).to be_a(Array)
        expect(ruby_array[0][0]).to eq([255, 0, 0])
        expect(ruby_array[0][1]).to eq([0, 255, 0])
        expect(ruby_array[1][0]).to eq([0, 0, 255])
      end

      it 'returns empty array for nil NArray' do
        ruby_array = image_rep.send(:narray_to_ruby_array, nil)
        expect(ruby_array).to eq([])
      end
    end

    describe 'round-trip conversion' do
      it 'maintains data integrity for grayscale images' do
        original = [
          [[10], [20], [30]],
          [[40], [50], [60]],
          [[70], [80], [90]]
        ]

        narray = image_rep.send(:ruby_array_to_narray, original)
        converted_back = image_rep.send(:narray_to_ruby_array, narray)

        expect(converted_back).to eq(original)
      end

      it 'maintains data integrity for RGB images' do
        original = [
          [[255, 0, 0], [0, 255, 0]],
          [[0, 0, 255], [255, 255, 255]]
        ]

        narray = image_rep.send(:ruby_array_to_narray, original)
        converted_back = image_rep.send(:narray_to_ruby_array, narray)

        expect(converted_back).to eq(original)
      end
    end
  end
end
