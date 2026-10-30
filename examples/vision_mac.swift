import AppKit
import Foundation
import Vision

guard let path = CommandLine.arguments.dropFirst().first else {
    FileHandle.standardError.write(Data("usage: xcrun swift examples/vision_mac.swift <image-path>\n".utf8))
    exit(1)
}

guard let cgImage = NSImage(contentsOfFile: path)?.cgImage(forProposedRect: nil, context: nil, hints: nil) else {
    FileHandle.standardError.write(Data("failed to load image: \(path)\n".utf8))
    exit(2)
}

let textRequest = VNRecognizeTextRequest()
textRequest.recognitionLanguages = ["ja-JP", "en-US"]
textRequest.recognitionLevel = .accurate
textRequest.usesLanguageCorrection = true

let faceRequest = VNDetectFaceRectanglesRequest()

try VNImageRequestHandler(cgImage: cgImage).perform([textRequest, faceRequest])

print("text:")
for observation in textRequest.results ?? [] {
    if let string = observation.topCandidates(1).first?.string {
        print("  \(string)")
    }
}

print("faces:")
for face in faceRequest.results ?? [] {
    let box = face.boundingBox
    print("  \(box.origin.x)\t\(box.origin.y)\t\(box.width)\t\(box.height)")
}
