import AppKit
import Foundation
import Vision

private func loadCGImage(path: String) -> CGImage? {
    NSImage(contentsOfFile: path)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
}

/// Recognizes text in the image at `path` with `VNRecognizeTextRequest`.
///
/// Recognition uses `ja-JP` and `en-US`, the `.accurate` level, and language correction.
/// ``cRecognizeText(_:)`` exposes this function to C.
///
/// - Parameter path: The path of an image file.
/// - Returns: The top candidate of each observation joined by newlines, or an empty string when the image cannot be loaded or Vision fails.
func recognizeText(path: String) -> String {
    guard let cgImage = loadCGImage(path: path) else { return "" }

    let request = VNRecognizeTextRequest()
    request.recognitionLanguages = ["ja-JP", "en-US"]
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    do {
        try VNImageRequestHandler(cgImage: cgImage).perform([request])
    } catch {
        return ""
    }

    return (request.results ?? [])
        .compactMap { $0.topCandidates(1).first?.string }
        .joined(separator: "\n")
}

/// Detects face rectangles in the image at `path` with `VNDetectFaceRectanglesRequest`.
///
/// ``cDetectFaces(_:)`` exposes this function to C.
///
/// - Parameter path: The path of an image file.
/// - Returns: One `x\ty\twidth\theight` line per face in normalized coordinates with the origin at the lower left, or an empty string when no face is found, the image cannot be loaded, or Vision fails.
func detectFaces(path: String) -> String {
    guard let cgImage = loadCGImage(path: path) else { return "" }

    let request = VNDetectFaceRectanglesRequest()

    do {
        try VNImageRequestHandler(cgImage: cgImage).perform([request])
    } catch {
        return ""
    }

    return (request.results ?? [])
        .map { face in
            let box = face.boundingBox
            return "\(box.origin.x)\t\(box.origin.y)\t\(box.width)\t\(box.height)"
        }
        .joined(separator: "\n")
}
