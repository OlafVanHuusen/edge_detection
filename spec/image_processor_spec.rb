require 'spec_helper'

RSpec.describe EdgeDetection::ImageProcessor do
  describe '#initialize' do
    context 'with MiniMagick::Image' do
      it 'detects mini_magick type' do
        mini_magick_class = Class.new
        stub_const('MiniMagick::Image', mini_magick_class)
        image = mini_magick_class.new
        
        processor = EdgeDetection::ImageProcessor.new(image)
        expect(processor.image_type).to eq(:mini_magick)
        expect(processor.mini_magick?).to be true
        expect(processor.rmagick?).to be false
      end
    end

    context 'with Magick::Image (RMagick)' do
      it 'detects rmagick type' do
        magick_class = Class.new
        stub_const('Magick::Image', magick_class)
        image = magick_class.new
        
        processor = EdgeDetection::ImageProcessor.new(image)
        expect(processor.image_type).to eq(:rmagick)
        expect(processor.rmagick?).to be true
        expect(processor.mini_magick?).to be false
      end
    end

    context 'with unsupported image type' do
      it 'raises an error' do
        expect {
          EdgeDetection::ImageProcessor.new("not an image")
        }.to raise_error(EdgeDetection::Error, /Image must be a MiniMagick::Image or Magick::Image/)
      end
    end
  end

  describe '#apply_edge_detection' do
    context 'with MiniMagick' do
      let(:mini_magick_image) { double('MiniMagick::Image') }
      let(:processor) { EdgeDetection::ImageProcessor.new(mini_magick_image) }

      before do
        mini_magick_class = Class.new
        stub_const('MiniMagick::Image', mini_magick_class)
        allow(mini_magick_image).to receive(:is_a?).with(mini_magick_class).and_return(true)
      end

      it 'applies canny edge detection' do
        expect(mini_magick_image).to receive(:combine_options) do |&block|
          options = double('options')
          expect(options).to receive(:colorspace).with("Gray")
          expect(options).to receive(:canny).with("0x1+10%+30%")
          block.call(options)
        end

        result = processor.apply_edge_detection(:canny)
        expect(result).to eq(mini_magick_image)
      end

      it 'applies canny with custom parameters' do
        expect(mini_magick_image).to receive(:combine_options) do |&block|
          options = double('options')
          expect(options).to receive(:colorspace).with("Gray")
          expect(options).to receive(:canny).with("2x3+20%+40%")
          block.call(options)
        end

        processor.apply_edge_detection(:canny, radius: 2, sigma: 3, lower_threshold: 20, upper_threshold: 40)
      end

      it 'applies sobel edge detection' do
        expect(mini_magick_image).to receive(:combine_options) do |&block|
          options = double('options')
          expect(options).to receive(:colorspace).with("Gray")
          expect(options).to receive(:define).with("convolve:scale=50%!")
          expect(options).to receive(:bias).with("50%")
          expect(options).to receive(:morphology).with("Convolve", "Sobel:0x1")
          block.call(options)
        end

        result = processor.apply_edge_detection(:sobel)
        expect(result).to eq(mini_magick_image)
      end
    end

    context 'with RMagick' do
      let(:rmagick_image) { double('Magick::Image') }
      let(:processor) { EdgeDetection::ImageProcessor.new(rmagick_image) }
      let(:gray_image) { double('GrayImage') }
      let(:edge_image) { double('EdgeImage') }

      before do
        magick_class = Class.new
        stub_const('Magick::Image', magick_class)
        stub_const('Magick::GRAYColorspace', :gray_colorspace)
        allow(rmagick_image).to receive(:is_a?).with(magick_class).and_return(true)
      end

      it 'applies canny edge detection' do
        expect(rmagick_image).to receive(:quantize).with(256, :gray_colorspace).and_return(gray_image)
        expect(gray_image).to receive(:canny_edge_channel).with(0, 1, 0.1, 0.3).and_return(edge_image)

        result = processor.apply_edge_detection(:canny)
        expect(result).to eq(edge_image)
      end

      it 'applies canny with custom parameters' do
        expect(rmagick_image).to receive(:quantize).with(256, :gray_colorspace).and_return(gray_image)
        expect(gray_image).to receive(:canny_edge_channel).with(2, 3, 0.2, 0.4).and_return(edge_image)

        processor.apply_edge_detection(:canny, radius: 2, sigma: 3, lower_threshold: 0.2, upper_threshold: 0.4)
      end

      it 'applies sobel edge detection' do
        expect(rmagick_image).to receive(:quantize).with(256, :gray_colorspace).and_return(gray_image)
        expect(gray_image).to receive(:edge).with(0, 1).and_return(edge_image)

        result = processor.apply_edge_detection(:sobel)
        expect(result).to eq(edge_image)
      end
    end
  end
end
