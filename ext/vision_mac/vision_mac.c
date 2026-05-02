#include <ruby.h>
#include "VisionMac-Swift.h"

static VALUE call_swift_string(char *(*fn)(const char *), VALUE input) {
    const char *c_input = StringValueCStr(input);
    char *result = fn(c_input);
    if (result == NULL) {
        return rb_utf8_str_new_cstr("");
    }
    VALUE rb_result = rb_utf8_str_new_cstr(result);
    vision_mac_free(result);
    return rb_result;
}

static VALUE rb_vision_mac_recognize_text(VALUE self, VALUE path) {
    return call_swift_string(vision_mac_recognize_text, path);
}

static VALUE rb_vision_mac_detect_faces(VALUE self, VALUE path) {
    return call_swift_string(vision_mac_detect_faces, path);
}

void Init_vision_mac(void) {
    VALUE module = rb_define_module("VisionMac");
    rb_define_singleton_method(module, "recognize_text", rb_vision_mac_recognize_text, 1);
    rb_define_singleton_method(module, "detect_faces", rb_vision_mac_detect_faces, 1);
}
