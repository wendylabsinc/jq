#ifndef JQ_WIN32_LIBGEN_H
#define JQ_WIN32_LIBGEN_H

#if defined(_WIN32) || defined(_WIN64)

#include <string.h>
#include <stdlib.h>

static inline char *jq_win32_basename(char *path) {
    if (path == NULL || path[0] == '\0') {
        return ".";
    }

    char *end = path + strlen(path) - 1;
    while (end > path && (*end == '\\' || *end == '/')) {
        *end-- = '\0';
    }
    char *last_sep = end;
    while (last_sep > path && *last_sep != '\\' && *last_sep != '/') {
        --last_sep;
    }
    if (last_sep == path && (*last_sep == '\\' || *last_sep == '/')) {
        return last_sep + 1;
    }
    if (*last_sep == '\\' || *last_sep == '/') {
        return last_sep + 1;
    }
    return path;
}

static inline char *jq_win32_dirname(char *path) {
    if (path == NULL || path[0] == '\0') {
        return ".";
    }

    char *end = path + strlen(path) - 1;
    while (end > path && (*end == '\\' || *end == '/')) {
        *end-- = '\0';
    }
    if (end == path && (*end == '\\' || *end == '/')) {
        *(end + 1) = '\0';
        return path;
    }
    while (end > path && *end != '\\' && *end != '/') {
        --end;
    }
    if (end == path) {
        if (*end == '\\' || *end == '/') {
            *(end + 1) = '\0';
            return path;
        }
        return ".";
    }
    *end = '\0';
    return path;
}

#define basename jq_win32_basename
#define dirname jq_win32_dirname

#else
#include_next <libgen.h>
#endif /* defined(_WIN32) || defined(_WIN64) */

#endif /* JQ_WIN32_LIBGEN_H */
