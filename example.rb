#!/usr/bin/env ruby
# frozen_string_literal: true

require_relative 'lib/edge_detection'

# Example usage of the ImageRepresentation class
def main
  puts 'Edge Detection Example'
  puts '=' * 50

  # Check if an image file is provided
  if ARGV.empty?
    puts 'Usage: ruby example.rb <image_path>'
    puts 'Example: ruby example.rb test_image.jpg'
    exit 1
  end

  input_file = ARGV[0]

  unless File.exist?(input_file)
    puts "Error: File '#{input_file}' not found!"
    exit 1
  end

  puts "Loading image: #{input_file}"

  begin
    # Load the image
    image = EdgeDetection::ImageRepresentation.new(input_file)
    puts "Image loaded successfully (#{image.width}x#{image.height})"

    # Apply Sobel edge detection
    puts "\nApplying Sobel edge detection..."
    sobel_result = image.sobel
    output_file = 'output_sobel.png'
    sobel_result.save(output_file)
    puts "Saved: #{output_file}"

    # Apply Prewitt edge detection
    puts "\nApplying Prewitt edge detection..."
    prewitt_result = image.prewitt
    output_file = 'output_prewitt.png'
    prewitt_result.save(output_file)
    puts "Saved: #{output_file}"

    # Apply Laplacian edge detection
    puts "\nApplying Laplacian edge detection..."
    laplacian_result = image.laplacian
    output_file = 'output_laplacian.png'
    laplacian_result.save(output_file)
    puts "Saved: #{output_file}"

    # Apply Canny edge detection
    puts "\nApplying Canny edge detection..."
    canny_result = image.canny(low_threshold: 50, high_threshold: 150)
    output_file = 'output_canny.png'
    canny_result.save(output_file)
    puts "Saved: #{output_file}"

    # Save as JPG format
    puts "\nSaving Sobel result as JPG..."
    sobel_result.save('output_sobel.jpg', format: 'jpg')
    puts "Saved: output_sobel.jpg"

    puts "\n" + '=' * 50
    puts 'All edge detection methods completed successfully!'

  rescue StandardError => e
    puts "Error: #{e.message}"
    puts e.backtrace.join("\n")
    exit 1
  end
end

main if __FILE__ == $PROGRAM_NAME

