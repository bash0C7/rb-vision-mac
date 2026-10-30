# CLAUDE.md — rb-vision-mac

## Position

Ruby native binding for Apple's Vision framework on macOS, built on the `bash0C7/swift_gem` scaffold. Exposes text recognition and face detection. Sibling of `rb-vision-ocrmac` (OCR-only study piece).

OCR functionality is intentionally duplicated against `rb-vision-ocrmac`: that gem stays a thin OCR-only study piece, while this gem grows the multi-request Vision surface.

## Core design principles

1. Thin wrapper. Pass-through Vision API. One image → one string (newline separator, `\t` for sub-fields). No option expansion (language switching, confidence filtering, etc.) until needed.
2. Fixed defaults: text recognition uses ja-JP + en-US, `.accurate`, `usesLanguageCorrection`. Face detection uses `VNDetectFaceRectanglesRequest` (rect only, no landmarks). Changes go through new API methods; existing behavior stays.
3. Vision-side failure (unloadable image, `perform` throwing) → empty string, no exception. A path that fails `stat()` → `SystemCallError` (`Errno::ENOENT` for a missing file), raised by the C wrapper before handing off to Swift.
4. `VNImageRequestHandler.perform` is synchronous: it returns after every request has finished, and results are read from `request.results` afterwards.
5. C bridge string handoff. Each method has its own `@c(<c_name>)` (SE-0495) function (`cRecognizeText`, `cDetectFaces`) and a single shared `cFree` exported as `vision_mac_free`. Signatures are fixed at `UnsafePointer<CChar>` → `UnsafeMutablePointer<CChar>`.
6. Scaffold parity. `bundle exec rake "new[rb-vision-mac,<dir>]"` in swift_gem produces a skeleton whose only diffs against this repo are the implementation body, fixtures, `example.rb`, docs, and build artifacts.

## Architecture

```
[caller (Ruby)]
  │
  │   VisionMac.{recognize_text,detect_faces}(path) → String
  ▼
lib/vision_mac.rb            ← requires the ext + module declaration
  │
  ▼
ext/vision_mac/vision_mac.c   ← rb_define_singleton_method, stat() check
  │
  │   vision_mac_{recognize_text,detect_faces}(c_path)
  ▼
ext/vision_mac/Sources/VisionMac/VisionMacBridge.swift   ← @c(name) (SE-0495)
  │
  ▼
ext/vision_mac/Sources/VisionMac/VisionMac.swift   ← NSImage → CGImage → VNImageRequestHandler.perform
  │
  ▼
[Apple Vision framework]
```

## Public API

| Method | Returns | Notes |
|---|---|---|
| `VisionMac.recognize_text(path)` | newline-separated text | `VNRecognizeTextRequest`, ja-JP+en-US, `.accurate` |
| `VisionMac.detect_faces(path)` | newline-separated `"x\ty\tw\th"` (normalized 0..1, origin lower-left) | `VNDetectFaceRectanglesRequest`. Empty string if no faces |

Signatures and their documentation live in `sig/vision_mac.rbs`.

## Module boundaries

| Layer | Responsibility |
|---|---|
| `lib/vision_mac.rb` | `require_relative` to load the .bundle; host of `module VisionMac` |
| `sig/vision_mac.rbs` | RBS for `VERSION`, `Error`, `recognize_text`, `detect_faces` |
| `ext/vision_mac/vision_mac.c` | `Init_vision_mac` exposes the singleton methods; copies the Swift-returned `char*` into a Ruby UTF-8 String, then calls `vision_mac_free` |
| `VisionMacBridge.swift` | C ABI exports via `@c(name)`. Calls the Swift implementations and returns C strings via `strdup` |
| `VisionMac.swift` | `NSImage` load → `VNImageRequestHandler.perform` → format `request.results` |
| `ext/vision_mac/extconf.rb` | `require_relative "swift_mkmf"` + `SwiftGem::Mkmf.create_swift_makefile("vision_mac/vision_mac", package: "VisionMac", source_dir: __dir__)` |
| `ext/vision_mac/swift_mkmf.rb` | Vendored copy of swift_gem's `lib/swift_gem/mkmf.rb`, kept identical |
| `examples/vision_mac.swift` | Ruby-free Vision sample: `xcrun swift examples/vision_mac.swift <path>` |
| `example.rb` | Ruby sample running both methods on one image |
| `Rakefile` | `task :swift` + `task compile: :swift` before `Rake::ExtensionTask("vision_mac")`; `task :rbs`; `task test: %i[rbs compile]`; `task console: :compile` |

## Build flow

`bundle exec rake test` builds and tests in one shot. `xcrun swift build -c release --package-path ext/vision_mac` writes `VisionMac-Swift.h` under `ext/vision_mac/.build/out/Intermediates.noindex/GeneratedModuleMaps/` (added with `-I`) and the dylib under `ext/vision_mac/.build/release`. `bundle exec rbs -I sig validate` checks the RBS.

## Usage / why no CLI

Library only, same as `rb-vision-ocrmac`. Interactive checks via `bundle exec rake console`.

## TDD discipline

t-wada style RED → GREEN → REFACTOR independent commits. test-unit. Real fixtures under `test/fixtures/`: `sample_jp.png` (shared with rb-vision-ocrmac) holds text and no faces. The single-face test runs only when `VISION_MAC_TEST_FACE` names a local image holding exactly one face; no photo of a person is committed.

## Related projects

- `~/dev/src/github.com/bash0C7/swift_gem` — scaffold/Mkmf framework
- `~/dev/src/github.com/bash0C7/rb-vision-ocrmac` — OCR-only sibling, study piece
- `~/dev/src/github.com/bash0C7/archives_go_jp_searcher` — depends on rb-vision-ocrmac (not this gem); leave that wiring alone

## Environment requirements

macOS 27+, Apple Silicon, Xcode 27 (Swift 6.4, builds run `xcrun swift`), Ruby 4.0+, bundler 4.x, rake-compiler 1.2+. `Gemfile.lock` is not git-tracked.

## Prohibitions

- No Python source
- No code comments. Swift is documented with DocC (`///`, `- Parameter`, `- Returns`, ``` ``symbol`` ``` links); Ruby is documented with `#` comments above declarations in `sig/vision_mac.rbs`. History goes in commit messages
- Do not hand-edit `ext/vision_mac/swift_mkmf.rb`; re-copy it from swift_gem
- Do not commit photos of people
- Do not git-track `Gemfile.lock`
- Do not promise thread safety for concurrent calls — add a lock if needed
- Do not split PDFs / multi-page images here — leave that to callers
- Do not cache, normalize, or post-process Vision results here
- Do not migrate `archives_go_jp_searcher` off `rb-vision-ocrmac` to this gem without an explicit task
- Commit messages in English, conventional commits style
- `.claude/` is committed
