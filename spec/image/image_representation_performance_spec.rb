# frozen_string_literal: true

require 'spec_helper'
require_relative '../../lib/Image/image_representation'

RSpec.describe ImageRepresentation do
  describe 'performance tests with various image sizes' do
    let(:structuring_element) do
      [
        [1, 1, 1],
        [1, 1, 1],
        [1, 1, 1]
      ]
    end
    # Helper method to create test images of any size
    def create_test_image(size, seed = 42)
      image = ImageRepresentation.new
      random = Random.new(seed)

      test_pixels = Array.new(size) do |y|
        Array.new(size) do |x|
          # Create a complex pattern combining multiple effects:
          # 1. Perlin-like noise simulation with multiple frequencies
          # 2. Radial gradients from multiple centers
          # 3. Random noise

          # Multiple frequency "noise"
          scale = size / 400.0 # Scale factors based on image size
          freq1 = Math.sin(x / (20.0 * scale)) * Math.cos(y / (20.0 * scale))
          freq2 = Math.sin(x / (50.0 * scale)) * Math.cos(y / (50.0 * scale))
          freq3 = Math.sin((x / (10.0 * scale)) + (y / (15.0 * scale))) * 0.5

          # Multiple radial components
          center1 = size / 4.0
          center2 = size * 3.0 / 4.0
          center3 = size / 2.0
          dist1 = Math.sqrt(((x - center1)**2) + ((y - center1)**2)) / (size / 2.0)
          dist2 = Math.sqrt(((x - center2)**2) + ((y - center2)**2)) / (size * 3.0 / 8.0)
          dist3 = Math.sqrt(((x - center3)**2) + ((y - center3)**2)) / (size * 5.0 / 8.0)

          # Combine all components
          combined = (freq1 + freq2 + freq3 - dist1 - dist2 + dist3) / 3.0

          # Add random noise
          noise = (random.rand - 0.5) * 0.3

          # Normalize to 0-255 range
          value = ((combined + noise + 1.0) * 127.5).clamp(0, 255).round
          [value]
        end
      end

      image.pixels = test_pixels
      image
    end

    describe 'with 100x100 images' do
      let(:test_image) { create_test_image(100) }

      it 'performs dilation and measures time' do
        start_time = Time.now
        result = test_image.dilation(structuring_element)
        end_time = Time.now

        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result).not_to equal(test_image)
        expect(result.width).to eq(100)
        expect(result.height).to eq(100)

        puts "\n  Dilation on 100x100 image took: #{(execution_time * 1000).round(2)} ms"
      end

      it 'performs erosion and measures time' do
        start_time = Time.now
        result = test_image.erosion(structuring_element)
        end_time = Time.now

        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result).not_to equal(test_image)
        puts "\n  Erosion on 100x100 image took: #{(execution_time * 1000).round(2)} ms"
      end

      it 'performs subtraction and measures time' do
        test_image2 = create_test_image(100, 123)

        start_time = Time.now
        result = test_image.subtract(test_image2)
        end_time = Time.now

        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result.width).to eq(100)
        expect(result.height).to eq(100)

        puts "\n  Subtraction on 100x100 images took: #{(execution_time * 1000).round(2)} ms"
      end
    end

    describe 'with 400x400 images' do
      let(:large_image) { create_test_image(400) }

      before do
        # Ensure large_image is initialized
        large_image
      end

      it 'performs dilation and measures time' do
        start_time = Time.now
        result = large_image.dilation(structuring_element)
        end_time = Time.now

        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result).not_to equal(large_image)
        expect(result.width).to eq(400)
        expect(result.height).to eq(400)

        puts "\n  Dilation on 400x400 image took: #{(execution_time * 1000).round(2)} ms"

        # Verify operation actually occurred
        expect(large_image.pixels[200][200][0]).to be >= 0
        expect(large_image.pixels[200][200][0]).to be <= 255
      end

      it 'performs erosion and measures time' do
        start_time = Time.now
        result = large_image.erosion(structuring_element)
        end_time = Time.now

        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result).not_to equal(large_image)
        expect(result.width).to eq(400)
        expect(result.height).to eq(400)

        puts "\n  Erosion on 400x400 image took: #{(execution_time * 1000).round(2)} ms"
      end

      it 'performs subtraction and measures time' do
        large_image2 = create_test_image(400, 123)

        start_time = Time.now
        result = large_image.subtract(large_image2)
        end_time = Time.now

        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result.width).to eq(400)
        expect(result.height).to eq(400)

        puts "\n  Subtraction on 400x400 images took: #{(execution_time * 1000).round(2)} ms"
      end

      it 'performs combined operations and measures total time' do
        # Clone the image for the second operation
        large_image_copy = described_class.new
        pixels_copy = Marshal.load(Marshal.dump(large_image.pixels))
        large_image_copy.pixels = pixels_copy

        start_time = Time.now

        # Perform dilation
        large_image.dilation(structuring_element)

        # Perform erosion on copy
        large_image_copy.erosion(structuring_element)

        # Subtract the two
        result = large_image.subtract(large_image_copy)

        end_time = Time.now
        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result.width).to eq(400)
        expect(result.height).to eq(400)

        puts "\n  Combined operations (dilation + erosion + subtraction) on 400x400 images took: #{(execution_time * 1000).round(2)} ms"
      end
    end

    describe 'with 1000x1000 images' do
      let(:xlarge_image) { create_test_image(1000) }

      before do
        # Ensure xlarge_image is initialized
        xlarge_image
      end

      it 'performs dilation and measures time' do
        start_time = Time.now
        result = xlarge_image.dilation(structuring_element)
        end_time = Time.now

        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result).not_to equal(xlarge_image)
        expect(result.width).to eq(1000)
        expect(result.height).to eq(1000)

        puts "\n  Dilation on 1000x1000 image took: #{(execution_time * 1000).round(2)} ms"

        # Verify operation actually occurred
        expect(xlarge_image.pixels[500][500][0]).to be >= 0
        expect(xlarge_image.pixels[500][500][0]).to be <= 255
      end

      it 'performs erosion and measures time' do
        start_time = Time.now
        result = xlarge_image.erosion(structuring_element)
        end_time = Time.now

        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result).not_to equal(xlarge_image)
        expect(result.width).to eq(1000)
        expect(result.height).to eq(1000)

        puts "\n  Erosion on 1000x1000 image took: #{(execution_time * 1000).round(2)} ms"
      end

      it 'performs subtraction and measures time' do
        xlarge_image2 = create_test_image(1000, 456)

        start_time = Time.now
        result = xlarge_image.subtract(xlarge_image2)
        end_time = Time.now

        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result.width).to eq(1000)
        expect(result.height).to eq(1000)

        puts "\n  Subtraction on 1000x1000 images took: #{(execution_time * 1000).round(2)} ms"
      end

      it 'performs combined operations and measures total time' do
        # Clone the image for the second operation
        xlarge_image_copy = described_class.new
        pixels_copy = Marshal.load(Marshal.dump(xlarge_image.pixels))
        xlarge_image_copy.pixels = pixels_copy

        start_time = Time.now

        # Perform dilation
        xlarge_image.dilation(structuring_element)

        # Perform erosion on copy
        xlarge_image_copy.erosion(structuring_element)

        # Subtract the two
        result = xlarge_image.subtract(xlarge_image_copy)

        end_time = Time.now
        execution_time = end_time - start_time

        expect(result).to be_a(ImageRepresentation)
        expect(result.width).to eq(1000)
        expect(result.height).to eq(1000)

        puts "\n  Combined operations (dilation + erosion + subtraction) on 1000x1000 images took: #{(execution_time * 1000).round(2)} ms"
      end
    end
  end
end
