# frozen_string_literal: true

require 'mini_magick'

# ImageRepresentation class for loading, processing, and edge detection on images
class ImageRepresentation
  attr_reader :width, :height, :pixels

  # Initialize with an image file path (PNG or JPG)
  # @param file_path [String] Path to the image file
  def initialize(file_path)
    @file_path = file_path
    load_image
  end

  # Load and convert image to grayscale representation
  def load_image
    image = MiniMagick::Image.open(@file_path)

    # Convert to grayscale
    image.colorspace('Gray')
    image.format('png')

    @width = image.width
    @height = image.height

    # Get pixel data as grayscale values (0-255)
    @pixels = extract_pixel_data(image)
  end

  # Extract pixel data from image
  # @param image [MiniMagick::Image] The image object
  # @return [Array<Array<Integer>>] 2D array of pixel values
  def extract_pixel_data(image)
    # Export pixels as grayscale values
    pixel_data = image.get_pixels

    # Convert to grayscale intensity values (0-255)
    pixel_data.map do |row|
      row.map do |pixel|
        # Average RGB values for grayscale (pixel is [r, g, b])
        (pixel[0] + pixel[1] + pixel[2]) / 3
      end
    end
  end

  # Apply Sobel edge detection
  # @return [ImageRepresentation] New image with detected edges
  def sobel
    sobel_x = [
      [-1, 0, 1],
      [-2, 0, 2],
      [-1, 0, 1]
    ]

    sobel_y = [
      [-1, -2, -1],
      [0, 0, 0],
      [1, 2, 1]
    ]

    gradient = Array.new(@height) { Array.new(@width, 0) }

    (1...@height - 1).each do |y|
      (1...@width - 1).each do |x|
        gx = apply_kernel(x, y, sobel_x)
        gy = apply_kernel(x, y, sobel_y)

        # Calculate gradient magnitude
        gradient[y][x] = Math.sqrt(gx ** 2 + gy ** 2).to_i
        gradient[y][x] = [gradient[y][x], 255].min
      end
    end

    create_from_pixels(gradient)
  end

  # Apply Canny edge detection
  # @param low_threshold [Integer] Low threshold for hysteresis (default: 50)
  # @param high_threshold [Integer] High threshold for hysteresis (default: 150)
  # @return [ImageRepresentation] New image with detected edges
  def canny(low_threshold: 50, high_threshold: 150)
    # Step 1: Gaussian blur to reduce noise
    blurred = gaussian_blur

    # Step 2: Calculate gradients
    gradients, angles = blurred.calculate_gradients

    # Step 3: Non-maximum suppression
    suppressed = blurred.non_maximum_suppression(gradients, angles)

    # Step 4: Double threshold and edge tracking by hysteresis
    edges = blurred.hysteresis(suppressed, low_threshold, high_threshold)

    create_from_pixels(edges)
  end

  # Apply Prewitt edge detection
  # @return [ImageRepresentation] New image with detected edges
  def prewitt
    prewitt_x = [
      [-1, 0, 1],
      [-1, 0, 1],
      [-1, 0, 1]
    ]

    prewitt_y = [
      [-1, -1, -1],
      [0, 0, 0],
      [1, 1, 1]
    ]

    gradient = Array.new(@height) { Array.new(@width, 0) }

    (1...@height - 1).each do |y|
      (1...@width - 1).each do |x|
        gx = apply_kernel(x, y, prewitt_x)
        gy = apply_kernel(x, y, prewitt_y)

        gradient[y][x] = Math.sqrt(gx ** 2 + gy ** 2).to_i
        gradient[y][x] = [gradient[y][x], 255].min
      end
    end

    create_from_pixels(gradient)
  end

  # Apply Laplacian edge detection
  # @return [ImageRepresentation] New image with detected edges
  def laplacian
    kernel = [
      [0, 1, 0],
      [1, -4, 1],
      [0, 1, 0]
    ]

    result = Array.new(@height) { Array.new(@width, 0) }

    (1...@height - 1).each do |y|
      (1...@width - 1).each do |x|
        value = apply_kernel(x, y, kernel)
        # Take absolute value and clamp to 0-255
        result[y][x] = [[value.abs, 255].min, 0].max
      end
    end

    create_from_pixels(result)
  end

  # Save the image to a file (PNG or JPG)
  # @param output_path [String] Path for the output file
  # @param format [String] Output format ('png' or 'jpg', default: 'png')
  def save(output_path, format: 'png')
    image = MiniMagick::Image.new(create_temp_file)

    # Import pixel data
    image.combine_options do |c|
      c.size "#{@width}x#{@height}"
      c.depth 8
    end

    # Create PGM format (Portable GrayMap) which MiniMagick can handle
    pgm_data = create_pgm_data
    temp_file = Tempfile.new(['image', '.pgm'])
    temp_file.binmode
    temp_file.write(pgm_data)
    temp_file.close

    # Load and convert
    output_image = MiniMagick::Image.open(temp_file.path)
    output_image.format(format)
    output_image.write(output_path)

    temp_file.unlink
  end

  protected

  # Apply a convolution kernel at a specific position
  # @param x [Integer] X coordinate
  # @param y [Integer] Y coordinate
  # @param kernel [Array<Array<Integer>>] Convolution kernel
  # @return [Integer] Convolved value
  def apply_kernel(x, y, kernel)
    sum = 0
    kernel_size = kernel.length
    offset = kernel_size / 2

    kernel.each_with_index do |row, ky|
      row.each_with_index do |weight, kx|
        pixel_y = y + ky - offset
        pixel_x = x + kx - offset

        # Boundary handling: clamp coordinates
        pixel_y = [[pixel_y, 0].max, @height - 1].min
        pixel_x = [[pixel_x, 0].max, @width - 1].min

        sum += @pixels[pixel_y][pixel_x] * weight
      end
    end

    sum
  end

  # Apply Gaussian blur to reduce noise
  # @return [ImageRepresentation] Blurred image
  def gaussian_blur(kernel_size: 5, sigma: 1.4)
    kernel = create_gaussian_kernel(kernel_size, sigma)
    blurred = Array.new(@height) { Array.new(@width, 0) }

    offset = kernel_size / 2

    (0...@height).each do |y|
      (0...@width).each do |x|
        sum = 0.0

        kernel.each_with_index do |row, ky|
          row.each_with_index do |weight, kx|
            pixel_y = y + ky - offset
            pixel_x = x + kx - offset

            # Boundary handling
            pixel_y = [[pixel_y, 0].max, @height - 1].min
            pixel_x = [[pixel_x, 0].max, @width - 1].min

            sum += @pixels[pixel_y][pixel_x] * weight
          end
        end

        blurred[y][x] = sum.to_i
      end
    end

    create_from_pixels(blurred)
  end

  # Create a Gaussian kernel
  # @param size [Integer] Kernel size (must be odd)
  # @param sigma [Float] Standard deviation
  # @return [Array<Array<Float>>] Gaussian kernel
  def create_gaussian_kernel(size, sigma)
    kernel = Array.new(size) { Array.new(size, 0.0) }
    sum = 0.0
    offset = size / 2

    (0...size).each do |y|
      (0...size).each do |x|
        dx = x - offset
        dy = y - offset
        value = Math.exp(-(dx ** 2 + dy ** 2) / (2.0 * sigma ** 2))
        kernel[y][x] = value
        sum += value
      end
    end

    # Normalize kernel
    kernel.map { |row| row.map { |v| v / sum } }
  end

  # Calculate gradients and angles for Canny edge detection
  # @return [Array<Array<Array<Integer>>, Array<Array<Float>>>] Gradients and angles
  def calculate_gradients
    sobel_x = [[-1, 0, 1], [-2, 0, 2], [-1, 0, 1]]
    sobel_y = [[-1, -2, -1], [0, 0, 0], [1, 2, 1]]

    gradients = Array.new(@height) { Array.new(@width, 0) }
    angles = Array.new(@height) { Array.new(@width, 0.0) }

    (1...@height - 1).each do |y|
      (1...@width - 1).each do |x|
        gx = apply_kernel(x, y, sobel_x)
        gy = apply_kernel(x, y, sobel_y)

        gradients[y][x] = Math.sqrt(gx ** 2 + gy ** 2).to_i
        angles[y][x] = Math.atan2(gy, gx)
      end
    end

    [gradients, angles]
  end

  # Non-maximum suppression for Canny edge detection
  # @param gradients [Array<Array<Integer>>] Gradient magnitudes
  # @param angles [Array<Array<Float>>] Gradient angles
  # @return [Array<Array<Integer>>] Suppressed gradients
  def non_maximum_suppression(gradients, angles)
    suppressed = Array.new(@height) { Array.new(@width, 0) }

    (1...@height - 1).each do |y|
      (1...@width - 1).each do |x|
        angle = angles[y][x] * 180.0 / Math::PI
        angle += 180 if angle < 0

        # Determine neighboring pixels based on gradient direction
        q = r = 255

        # Angle 0
        if (0 <= angle && angle < 22.5) || (157.5 <= angle && angle <= 180)
          q = gradients[y][x + 1]
          r = gradients[y][x - 1]
          # Angle 45
        elsif 22.5 <= angle && angle < 67.5
          q = gradients[y + 1][x - 1]
          r = gradients[y - 1][x + 1]
          # Angle 90
        elsif 67.5 <= angle && angle < 112.5
          q = gradients[y + 1][x]
          r = gradients[y - 1][x]
          # Angle 135
        elsif 112.5 <= angle && angle < 157.5
          q = gradients[y - 1][x - 1]
          r = gradients[y + 1][x + 1]
        end

        # Keep pixel if it's a local maximum
        if gradients[y][x] >= q && gradients[y][x] >= r
          suppressed[y][x] = gradients[y][x]
        end
      end
    end

    suppressed
  end

  # Hysteresis thresholding for Canny edge detection
  # @param image [Array<Array<Integer>>] Suppressed gradients
  # @param low [Integer] Low threshold
  # @param high [Integer] High threshold
  # @return [Array<Array<Integer>>] Binary edge image
  def hysteresis(image, low, high)
    edges = Array.new(@height) { Array.new(@width, 0) }

    # Classify pixels
    (0...@height).each do |y|
      (0...@width).each do |x|
        if image[y][x] >= high
          edges[y][x] = 255
        elsif image[y][x] >= low
          edges[y][x] = 128 # Weak edge
        end
      end
    end

    # Track weak edges connected to strong edges
    changed = true
    while changed
      changed = false
      (1...@height - 1).each do |y|
        (1...@width - 1).each do |x|
          if edges[y][x] == 128
            # Check if connected to a strong edge
            has_strong_neighbor = false
            (-1..1).each do |dy|
              (-1..1).each do |dx|
                next if dy == 0 && dx == 0
                if edges[y + dy][x + dx] == 255
                  has_strong_neighbor = true
                  break
                end
              end
              break if has_strong_neighbor
            end

            if has_strong_neighbor
              edges[y][x] = 255
              changed = true
            else
              edges[y][x] = 0
            end
          end
        end
      end
    end

    edges
  end

  # Create a new ImageRepresentation from pixel data
  # @param pixels [Array<Array<Integer>>] 2D array of pixel values
  # @return [ImageRepresentation] New image object
  def create_from_pixels(pixels)
    new_image = self.class.allocate
    new_image.instance_variable_set(:@pixels, pixels)
    new_image.instance_variable_set(:@width, pixels[0].length)
    new_image.instance_variable_set(:@height, pixels.length)
    new_image.instance_variable_set(:@file_path, nil)
    new_image
  end

  # Create PGM (Portable GrayMap) data for saving
  # @return [String] PGM format data
  def create_pgm_data
    header = "P2\n#{@width} #{@height}\n255\n"
    pixel_data = @pixels.map { |row| row.join(' ') }.join("\n")
    header + pixel_data
  end

  # Create a temporary file
  # @return [String] Path to temporary file
  def create_temp_file
    temp = Tempfile.new(['image', '.pgm'])
    temp.close
    temp.path
  end
end

