# rb-vision-mac

Ruby binding for Apple's Vision framework on macOS / Apple Silicon. Calls `VNRecognizeTextRequest` (OCR) and `VNDetectFaceRectanglesRequest` (face rectangles) directly from Ruby via Swift Package Manager and a thin C bridge. Built on [swift_gem](https://github.com/bash0C7/swift_gem).

> OCR functionality overlaps with [rb-vision-ocrmac](https://github.com/bash0C7/rb-vision-ocrmac), which remains as an OCR-only study piece. This gem is the broader Vision binding.

## Requirements

- macOS 12+, Apple Silicon
- Swift 6.3+ (SE-0495 `@c` attribute). Install via [swiftly](https://www.swift.org/install/macos/) — Xcode not required.
- Ruby 3.2+, Bundler 4.x

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
# => "0.123\t0.456\t0.234\t0.345\n..."   # x, y, width, height in normalized 0..1 coords
```

`recognize_text` uses ja-JP + en-US, `.accurate`, with language correction. `detect_faces` returns `CGRect` values normalized to the image (Vision's coordinate system: origin at lower-left). On Vision-side failure (unreadable image content, OS error, 30s timeout) the methods return `""`. **A missing path raises `Errno::ENOENT`** rather than silently returning `""`, so callers can distinguish bad input from a genuine empty result.

Or open an IRB console with the gem preloaded:

```bash
bundle exec rake console
```

## Reference: Ruby example

`example.rb` at the repo root demonstrates both methods end-to-end:

```bash
bundle exec ruby example.rb path/to/image.png
```

It defaults to `test/fixtures/sample_jp.png` if no argument is given.

## Reference: pure Swift sample

A self-contained Swift script lives at `examples/vision_mac.swift` for sanity-checking Vision behavior without going through Ruby:

```bash
xcrun swift examples/vision_mac.swift path/to/image.png
```

Use `xcrun swift` (Xcode toolchain), not bare `swift` from swiftly — swiftly 6.3's interpret mode does not JIT-link Apple system frameworks (Vision, AppKit) and fails at startup with symbol-resolution errors. Xcode's swift uses dyld and works as-is.

## Development

```bash
bundle install
bundle exec rake test
```

`rake test` automatically compiles the Swift Package (`swift build -c release`) and links the C bridge into `lib/vision_mac/vision_mac.bundle` before running the spec, via `Rake::ExtensionTask`.

To run only the build step: `bundle exec rake compile`.

## License

MIT.
