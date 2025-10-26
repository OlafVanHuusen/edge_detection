require 'spec_helper'

RSpec.describe EdgeDetection do
  it "has a version number" do
    expect(EdgeDetection::VERSION).not_to be nil
  end

  describe '.configure' do
    it 'allows setting default algorithm' do
      EdgeDetection.configure do |config|
        config.default_algorithm = :sobel
      end
      expect(EdgeDetection.default_algorithm).to eq(:sobel)
      
      # Reset to default
      EdgeDetection.default_algorithm = :canny
    end
  end

  describe '.detect' do
    let(:mock_image) { double('Image') }
    let(:mock_processor) { instance_double(EdgeDetection::ImageProcessor) }

    before do
      allow(EdgeDetection::ImageProcessor).to receive(:new).with(mock_image).and_return(mock_processor)
    end

    context 'with canny algorithm' do
      it 'calls Canny.detect with the processor' do
        expect(EdgeDetection::Canny).to receive(:detect).with(mock_processor)
        EdgeDetection.detect(mock_image, algorithm: :canny)
      end

      it 'passes options to Canny.detect' do
        expect(EdgeDetection::Canny).to receive(:detect).with(mock_processor, radius: 1, sigma: 2)
        EdgeDetection.detect(mock_image, algorithm: :canny, radius: 1, sigma: 2)
      end
    end

    context 'with sobel algorithm' do
      it 'calls Sobel.detect with the processor' do
        expect(EdgeDetection::Sobel).to receive(:detect).with(mock_processor)
        EdgeDetection.detect(mock_image, algorithm: :sobel)
      end

      it 'passes options to Sobel.detect' do
        expect(EdgeDetection::Sobel).to receive(:detect).with(mock_processor, radius: 1, sigma: 2)
        EdgeDetection.detect(mock_image, algorithm: :sobel, radius: 1, sigma: 2)
      end
    end

    context 'with default algorithm' do
      it 'uses canny by default' do
        expect(EdgeDetection::Canny).to receive(:detect).with(mock_processor)
        EdgeDetection.detect(mock_image)
      end
    end

    context 'with unknown algorithm' do
      it 'raises an error' do
        expect {
          EdgeDetection.detect(mock_image, algorithm: :unknown)
        }.to raise_error(EdgeDetection::Error, /Unknown algorithm/)
      end
    end
  end
end
