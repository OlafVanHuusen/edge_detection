# Test Fixtures Structure

This folder contains the test images for edge detection testing.

## Folder Structure

```
fixtures/
├── input/          # Place your INPUT images here
├── expected/       # Place your EXPECTED edge detection results here
└── output/         # Test output will be generated here automatically
```

## How to Use

1. **Place your input image** in the `input/` folder
   - Default name: `test_image.png`
   - Can be any image format (png, jpg, etc.)

2. **Place your expected edge detection result** in the `expected/` folder
   - Default name: `expected_edges.png`
   - This should be the correctly edge-detected version of your input image

3. **Adjust the test** if you use different filenames:
   - Open: `spec/edge_detection_spec.rb`
   - Go to **Lines 14-16** (marked with comments)
   - Change the filenames to match your images

4. **Run the test**:
   ```bash
   bundle exec rspec spec/edge_detection_spec.rb
   ```

## Test Behavior

The test will:
- Load your input image
- Apply edge detection using `dilation_erosion_edge_detection`
- Save the result to `output/output_edges.png`
- Compare it with your expected image
- Calculate similarity percentage (expects at least 95% match)

## Notes

- The comparison allows for small pixel differences (tolerance of 5 units)
- Output folder will contain the actual edge detection results for manual review
- If test fails, check the similarity percentage in the output

