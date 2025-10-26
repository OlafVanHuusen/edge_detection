require 'spec_helper'

RSpec.describe EdgeDetection::Canny do
  describe '.detect' do
    let(:processor) { instance_double(EdgeDetection::ImageProcessor) }
    let(:result_image) { double('ResultImage') }

    it 'calls apply_edge_detection with canny method' do
      expect(processor).to receive(:apply_edge_detection).with(:canny).and_return(result_image)
      result = EdgeDetection::Canny.detect(processor)
      expect(result).to eq(result_image)
    end

    it 'passes radius option' do
      expect(processor).to receive(:apply_edge_detection).with(:canny, radius: 2).and_return(result_image)
      EdgeDetection::Canny.detect(processor, radius: 2)
    end

    it 'passes sigma option' do
      expect(processor).to receive(:apply_edge_detection).with(:canny, sigma: 1.5).and_return(result_image)
      EdgeDetection::Canny.detect(processor, sigma: 1.5)
    end

    it 'passes threshold options' do
      expect(processor).to receive(:apply_edge_detection).with(
        :canny, 
        lower_threshold: 10, 
        upper_threshold: 30
      ).and_return(result_image)
      EdgeDetection::Canny.detect(processor, lower_threshold: 10, upper_threshold: 30)
    end

    it 'passes all options together' do
      expect(processor).to receive(:apply_edge_detection).with(
        :canny, 
        radius: 1,
        sigma: 2,
        lower_threshold: 15,
        upper_threshold: 35
      ).and_return(result_image)
      EdgeDetection::Canny.detect(
        processor, 
        radius: 1, 
        sigma: 2, 
        lower_threshold: 15, 
        upper_threshold: 35
      )
    end
  end
end
