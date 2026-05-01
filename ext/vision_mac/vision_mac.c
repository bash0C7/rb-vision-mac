#include <ruby.h>
#include "vision_mac.h"

static VALUE rb_vision_mac_perform(VALUE self, VALUE input) {
    const char *c_input = StringValueCStr(input);
    char *result = vision_mac_perform(c_input);
    if (result == NULL) {
        return rb_utf8_str_new_cstr("");
    }
    VALUE rb_result = rb_utf8_str_new_cstr(result);
    vision_mac_free(result);
    return rb_result;
}

void Init_vision_mac(void) {
    VALUE module = rb_define_module("VisionMac");
    rb_define_singleton_method(module, "perform", rb_vision_mac_perform, 1);
}
