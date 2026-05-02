# CLAUDE.md — rb-vision-mac

## Position

Ruby native binding for Apple's Vision framework on macOS. Sibling of `rb-vision-ocrmac` (which is OCR-only, study/legacy) and built on the same `bash0C7/swift_gem` scaffold. Exposes a broader Vision surface beyond OCR, starting with text recognition and face detection.

OCR functionality is intentionally duplicated against `rb-vision-ocrmac`: that gem stays a thin OCR-only study piece, while this gem grows the multi-request Vision surface.

## Core design principles

1. Thin wrapper. Pass-through Vision API. One image → one string (newline separator, optional `\t` for sub-fields). Option expansion (multi-language switching, confidence filtering, etc.) is intentionally not added until needed.
2. Fixed defaults: text recognition uses ja-JP + en-US, `.accurate`, `usesLanguageCorrection`. Face detection uses VNDetectFaceRectanglesRequest (rect only, no landmarks). Changes go through new API methods; never break existing behavior.
3. 30s timeout, failure represented as an empty string. Does not raise exceptions.
4. C bridge string handoff. Each method has its own `@c` (SE-0495) pair. Single shared `vision_mac_free`. Bridge function signatures fixed at `UnsafePointer<CChar>` ↔ `UnsafeMutablePointer<CChar>`.
5. Scaffold parity. `swift_gem new rb-vision-mac` produces a skeleton whose only diffs against this repo are the implementation body, fixtures, and build artifacts.

## Architecture

```
[caller (Ruby)]
  │
  │   VisionMac.{recognize_text,detect_faces}(path) → String
  ▼
lib/vision_mac.rb            ← requires the ext + module declaration
  │
  ▼
ext/vision_mac/vision_mac.c   ← rb_define_singleton_method
  │
  │   vision_mac_{recognize_text,detect_faces}(c_path)
  ▼
ext/vision_mac/Sources/VisionMac/VisionMacBridge.swift   ← @c (SE-0495)
  │
  ▼
ext/vision_mac/Sources/VisionMac/VisionMac.swift   ← NSImage + VNRecognizeTextRequest / VNDetectFaceRectanglesRequest
  │
  ▼
[Apple Vision framework]
```

## Public API

| Method | Returns | Notes |
|---|---|---|
| `VisionMac.recognize_text(path)` | newline-separated text | VNRecognizeTextRequest, ja-JP+en-US, `.accurate` |
| `VisionMac.detect_faces(path)` | newline-separated `"x\ty\tw\th"` (CGRect normalized 0..1) | VNDetectFaceRectanglesRequest. Empty string if no faces |

## Module boundaries

| Layer | Responsibility |
|---|---|
| `lib/vision_mac.rb` | `require_relative` to load the .bundle; host of `module VisionMac` |
| `ext/vision_mac/vision_mac.c` | `Init_vision_mac` exposes the singleton methods; copies Swift-returned `char*` into a Ruby UTF-8 String, then calls `vision_mac_free` |
| `VisionMacBridge.swift` | C ABI exports via `@c` (SE-0495). Calls Swift implementations and returns C strings via `strdup` |
| `VisionMac.swift` | Real implementation: `NSImage` load → `VNImageRequestHandler.perform` → request-specific handlers. `DispatchSemaphore` enforces the 30s timeout |
| `ext/vision_mac/extconf.rb` | `SwiftGem::Mkmf.create_swift_makefile("vision_mac/vision_mac", package: "VisionMac", source_dir: __dir__)` |
| `examples/vision_mac.swift` | Pure-Swift sample script. Ruby-free, kept as a Vision-behavior reference |
| `Rakefile` | `Rake::ExtensionTask("vision_mac")` + `task test: :compile`. `task console: :compile` for IRB |

## Build flow

`bundle exec rake test` in one shot — same as `rb-vision-ocrmac`.

## Usage / why no CLI

Library only — same rationale as `rb-vision-ocrmac`. Interactive checks via `bundle exec rake console`.

## TDD discipline

t-wada style RED → GREEN → REFACTOR independent commits. test-unit. Real fixtures under `test/fixtures/` (`sample_jp.png` shared with rb-vision-ocrmac for OCR; face detection currently asserts behavior on the same image since it has no faces).

## Related projects

- `~/dev/src/github.com/bash0C7/swift_gem` — scaffold/Mkmf framework
- `~/dev/src/github.com/bash0C7/rb-vision-ocrmac` — OCR-only sibling, study piece
- `~/dev/src/github.com/bash0C7/archives_go_jp_searcher` — depends on rb-vision-ocrmac (NOT this gem); leave that wiring alone

## Environment requirements

macOS 12+, Apple Silicon, Swift 6.3+ (SE-0495 `@c` requires 6.3; install via [swiftly](https://www.swift.org/install/macos/)), Ruby 3.2+, bundler 4.x, rake-compiler 1.2+. `Gemfile` references swift_gem via `path: "../swift_gem"` until publish. `Gemfile.lock` not git-tracked.

## Prohibitions

- No Python source
- Do not git-track `Gemfile.lock`
- Do not promise thread safety for concurrent calls — add a lock if needed
- Do not split PDFs / multi-page images here — leave that to callers
- Do not cache, normalize, or post-process Vision results here
- Do not migrate `archives_go_jp_searcher` off `rb-vision-ocrmac` to this gem without an explicit task
- Commit messages in English, conventional commits style
- `.claude/` is committed
