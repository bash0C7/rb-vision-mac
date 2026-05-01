# rb-vision-mac

Ruby binding for Apple's Vision framework on macOS. Wraps `VNRecognizeTextRequest` and `VNDetectFaceRectanglesRequest` as Ruby singleton methods.

Built on top of [swift_gem](https://github.com/bash0C7/swift_gem). macOS / Apple Silicon only.

> **Note:** OCR functionality overlaps with [rb-vision-ocrmac](https://github.com/bash0C7/rb-vision-ocrmac), which remains as an OCR-only study piece. This gem is the broader Vision binding.

## Usage

```ruby
require "vision_mac"

VisionMac.recognize_text("path/to/image.png")
# => "Detected text line 1\nDetected text line 2\n..."

VisionMac.detect_faces("path/to/photo.png")
# => "0.123\t0.456\t0.234\t0.345\n..."   # x, y, width, height in normalized 0..1 coords
```

`recognize_text` uses ja-JP + en-US, `.accurate`, with language correction. `detect_faces` returns `CGRect` values normalized to the image (Vision's coordinate system: origin at lower-left).

On failure (unreadable file, OS error, 30s timeout) the methods return `""`.

## Reference Swift example

```bash
swift examples/vision_mac.swift path/to/image.png
```

## Development

```bash
bundle install
bundle exec rake test
```

## License

MIT.
