import Foundation

@c
public func vision_mac_recognize_text(_ path: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: path)
    return strdup(performRecognizeText(path: s))!
}

@c
public func vision_mac_detect_faces(_ path: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: path)
    return strdup(performDetectFaces(path: s))!
}

@c
public func vision_mac_free(_ ptr: UnsafeMutablePointer<CChar>?) {
    free(ptr)
}
