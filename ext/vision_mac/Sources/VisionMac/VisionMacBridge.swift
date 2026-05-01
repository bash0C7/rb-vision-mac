import Foundation

@_cdecl("vision_mac_recognize_text")
public func vision_mac_recognize_text(_ path: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: path)
    return strdup(performRecognizeText(path: s))!
}

@_cdecl("vision_mac_detect_faces")
public func vision_mac_detect_faces(_ path: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: path)
    return strdup(performDetectFaces(path: s))!
}

@_cdecl("vision_mac_free")
public func vision_mac_free(_ ptr: UnsafeMutablePointer<CChar>?) {
    free(ptr)
}
