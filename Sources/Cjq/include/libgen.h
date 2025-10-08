// Minimal libgen replacements for Windows builds (dirname)
#ifndef JQ_SWIFT_FAKE_LIBGEN_H
#define JQ_SWIFT_FAKE_LIBGEN_H

#ifdef _WIN32
#include <string.h>

static inline char *dirname(char *path) {
  if (path == NULL || *path == '\0') return ".";
  // Remove trailing separators in-place
  size_t len = strlen(path);
  while (len > 0 && (path[len-1] == '/' || path[len-1] == '\\')) {
    path[--len] = '\0';
  }
  if (len == 0) return "/";
  // Find last separator
  char *sep1 = strrchr(path, '/');
  char *sep2 = strrchr(path, '\\');
  char *p = sep1;
  if (sep2 && (!p || sep2 > p)) p = sep2;
  if (!p) return ".";
  if (p == path) { p[1] = '\0'; return path; }
  *p = '\0';
  return path;
}

#else
#include_next <libgen.h>
#endif

#endif // JQ_SWIFT_FAKE_LIBGEN_H
