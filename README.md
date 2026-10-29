# rb-vision-mac

Ruby binding for Apple's Vision framework on macOS / Apple Silicon. Calls `VNRecognizeTextRequest` (OCR) and `VNDetectFaceRectanglesRequest` (face rectangles) from Ruby via Swift Package Manager and a thin C bridge. Built on [swift_gem](https://github.com/bash0C7/swift_gem).

OCR functionality overlaps with [rb-vision-ocrmac](https://github.com/bash0C7/rb-vision-ocrmac), an OCR-only gem. This gem is the broader Vision binding.

## Requirements

- macOS 27+, Apple Silicon
- Xcode 27 (builds run `xcrun swift`)
- Ruby 4.0+, Bundler 4.x

## Installation

```bash
bundle add rb-vision-mac
```

```bash
gem install rb-vision-mac
```

## Usage

```ruby
require "vision_mac"

VisionMac.recognize_text("path/to/image.png")
# => "Detected text line 1\nDetected text line 2\n..."

VisionMac.detect_faces("path/to/photo.png")
# => "0.123\t0.456\t0.234\t0.345\n..."
```

`recognize_text` uses ja-JP + en-US, `.accurate`, with language correction, and returns one line per observation. `detect_faces` returns one `x\ty\twidth\theight` line per face, normalized to 0..1 with the origin at the lower left. Both return `""` when Vision finds nothing, cannot read the image, or fails. A path that cannot be `stat`ed raises `Errno::ENOENT` (or another `SystemCallError`).

Open an IRB console with the gem preloaded:

```bash
bundle exec rake console
```

## Preconditions: caller is responsible for image preprocessing

This gem passes the image to Vision as-is. It does no rotation, scaling, orientation correction, page splitting, or layout normalization.

Cases where Vision tends to return nothing or miss content:

- Vertical Japanese book pages with densely packed text columns (`recognize_text`). Rotate the page 90° so columns become rows, or upscale scans of about 1000px or less on the long side.
- Low-resolution scans (`recognize_text`). Upscale before calling.
- Multi-page PDFs or multi-region images. Split them into one image per page or region.
- Skew, heavy noise, faint text. Deskew, denoise, or boost contrast first.
- Faces at unusual angles, occluded, or in low light (`detect_faces`). Normalize lighting or rotate first.

Both methods return `""` for "Vision found nothing" and "Vision could not segment the image" alike. Branch on `output.empty?` to apply a fallback chain.

## Reference: Ruby example

`example.rb` runs both methods on one image, defaulting to `test/fixtures/sample_jp.png`:

```bash
bundle exec rake compile
bundle exec ruby example.rb path/to/image.png
```

## Reference: pure Swift sample

`examples/vision_mac.swift` runs the same Vision requests without Ruby:

```bash
xcrun swift examples/vision_mac.swift path/to/image.png
```

## Development

```bash
bundle install
bundle exec rake test
```

`rake test` runs `xcrun swift build -c release --package-path ext/vision_mac`, builds the C extension into `lib/vision_mac/vision_mac.bundle`, then runs the tests. `bundle exec rake compile` runs only the build. `bundle exec rbs -I sig validate` checks `sig/vision_mac.rbs`.

## License

MIT.
