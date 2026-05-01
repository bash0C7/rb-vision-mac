import Foundation

@_cdecl("vision_mac_perform")
public func vision_mac_perform(_ input: UnsafePointer<CChar>) -> UnsafeMutablePointer<CChar> {
    let s = String(cString: input)
    let result = vision_mac_perform(s)
    return strdup(result)!
}

@_cdecl("vision_mac_free")
public func vision_mac_free(_ ptr: UnsafeMutablePointer<CChar>?) {
    free(ptr)
}
