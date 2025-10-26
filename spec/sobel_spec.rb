require 'spec_helper'

RSpec.describe EdgeDetection::Sobel do
  describe '.detect' do
    let(:processor) { instance_double(EdgeDetection::ImageProcessor) }
    let(:result_image) { double('ResultImage') }

    it 'calls apply_edge_detection with sobel method' do
      expect(processor).to receive(:apply_edge_detection).with(:sobel).and_return(result_image)
      result = EdgeDetection::Sobel.detect(processor)
      expect(result).to eq(result_image)
    end

    it 'passes radius option' do
      expect(processor).to receive(:apply_edge_detection).with(:sobel, radius: 2).and_return(result_image)
      EdgeDetection::Sobel.detect(processor, radius: 2)
    end

    it 'passes sigma option' do
      expect(processor).to receive(:apply_edge_detection).with(:sobel, sigma: 1.5).and_return(result_image)
      EdgeDetection::Sobel.detect(processor, sigma: 1.5)
    end

    it 'passes all options together' do
      expect(processor).to receive(:apply_edge_detection).with(
        :sobel, 
        radius: 1,
        sigma: 2
      ).and_return(result_image)
      EdgeDetection::Sobel.detect(processor, radius: 1, sigma: 2)
    end
  end
end
