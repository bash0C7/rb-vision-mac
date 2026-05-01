#ifndef VISION_MAC_H
#define VISION_MAC_H

char *vision_mac_recognize_text(const char *path);
char *vision_mac_detect_faces(const char *path);
void vision_mac_free(char *ptr);

#endif
