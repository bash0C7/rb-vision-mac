import Foundation

/// Calls `recognizeText(path:)` from C as `vision_mac_recognize_text`.
///
/// The returned buffer is allocated with `strdup`. Release it with ``cFree(_:)``.
///
/// - Parameter path: A NUL-terminated UTF-8 image path.
/// - Returns: A newly allocated NUL-terminated UTF-8 string owned by the caller.
@c(vision_mac_recognize_text)
public func cRecognizeText(_ path: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let result = recognizeText(path: String(cString: path))
    return strdup(result)!
}

/// Calls `detectFaces(path:)` from C as `vision_mac_detect_faces`.
///
/// The returned buffer is allocated with `strdup`. Release it with ``cFree(_:)``.
///
/// - Parameter path: A NUL-terminated UTF-8 image path.
/// - Returns: A newly allocated NUL-terminated UTF-8 string owned by the caller.
@c(vision_mac_detect_faces)
public func cDetectFaces(_ path: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let result = detectFaces(path: String(cString: path))
    return strdup(result)!
}

/// Releases a buffer returned by ``cRecognizeText(_:)`` or ``cDetectFaces(_:)``, exposed to C as `vision_mac_free`.
///
/// The caller owns every buffer those functions return and must pass it to this function exactly once.
///
/// - Parameter ptr: The buffer to release, or `nil`.
@c(vision_mac_free)
public func cFree(_ ptr: UnsafeMutablePointer<CChar>?) {
    free(ptr)
}
