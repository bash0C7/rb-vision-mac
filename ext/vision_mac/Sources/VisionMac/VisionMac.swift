import Vision
import AppKit
import Foundation

private let timeoutSeconds: Int = 30

private func loadCGImage(path: String) -> CGImage? {
    guard let nsImage = NSImage(contentsOfFile: path) else { return nil }
    return nsImage.cgImage(forProposedRect: nil, context: nil, hints: nil)
}

func performRecognizeText(path: String) -> String {
    guard let cgImage = loadCGImage(path: path) else { return "" }

    var resultLines: [String] = []
    let semaphore = DispatchSemaphore(value: 0)

    let request = VNRecognizeTextRequest { request, _ in
        defer { semaphore.signal() }
        guard let observations = request.results as? [VNRecognizedTextObservation] else { return }
        for obs in observations {
            if let str = obs.topCandidates(1).first?.string {
                resultLines.append(str)
            }
        }
    }
    request.recognitionLanguages = ["ja-JP", "en-US"]
    request.recognitionLevel = .accurate
    request.usesLanguageCorrection = true

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
        try handler.perform([request])
        if semaphore.wait(timeout: DispatchTime.now() + .seconds(timeoutSeconds)) == .timedOut {
            return ""
        }
    } catch {
        return ""
    }

    return resultLines.joined(separator: "\n")
}

func performDetectFaces(path: String) -> String {
    guard let cgImage = loadCGImage(path: path) else { return "" }

    var resultLines: [String] = []
    let semaphore = DispatchSemaphore(value: 0)

    let request = VNDetectFaceRectanglesRequest { request, _ in
        defer { semaphore.signal() }
        guard let observations = request.results as? [VNFaceObservation] else { return }
        for obs in observations {
            let r = obs.boundingBox
            resultLines.append("\(r.origin.x)\t\(r.origin.y)\t\(r.size.width)\t\(r.size.height)")
        }
    }

    let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
    do {
        try handler.perform([request])
        if semaphore.wait(timeout: DispatchTime.now() + .seconds(timeoutSeconds)) == .timedOut {
            return ""
        }
    } catch {
        return ""
    }

    return resultLines.joined(separator: "\n")
}
