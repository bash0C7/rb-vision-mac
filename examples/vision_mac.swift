import Vision
import AppKit
import Foundation

// Run with: xcrun swift examples/vision_mac.swift <image-path>
//
// Use 'xcrun swift' (Xcode toolchain), not bare 'swift' (swiftly).
// swiftly 6.3's swift interpret mode fails to JIT-link Apple system
// frameworks (Vision, AppKit), so symbol resolution errors at startup.
// Xcode's swift uses dyld for framework linking and works as expected.
//
// VNImageRequestHandler.perform is synchronous on macOS — request completion
// handlers fire inline before perform returns, so no semaphore is needed.

guard CommandLine.arguments.count >= 2 else {
    FileHandle.standardError.write("usage: xcrun swift examples/vision_mac.swift <image-path>\n".data(using: .utf8)!)
    exit(1)
}

let path = CommandLine.arguments[1]
guard let nsImage = NSImage(contentsOfFile: path),
      let cgImage = nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    FileHandle.standardError.write("failed to load image: \(path)\n".data(using: .utf8)!)
    exit(2)
}

let textRequest = VNRecognizeTextRequest { request, _ in
    print("text:")
    if let observations = request.results as? [VNRecognizedTextObservation] {
        for obs in observations {
            if let str = obs.topCandidates(1).first?.string {
                print("  \(str)")
            }
        }
    }
}
textRequest.recognitionLanguages = ["ja-JP", "en-US"]
textRequest.recognitionLevel = .accurate
textRequest.usesLanguageCorrection = true

let faceRequest = VNDetectFaceRectanglesRequest { request, _ in
    print("faces:")
    if let observations = request.results as? [VNFaceObservation] {
        for obs in observations {
            let r = obs.boundingBox
            print("  \(r.origin.x)\t\(r.origin.y)\t\(r.size.width)\t\(r.size.height)")
        }
    }
}

let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
try handler.perform([textRequest, faceRequest])
