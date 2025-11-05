#ifndef Cjq_win_libgen_h
#define Cjq_win_libgen_h

#if !defined(_WIN32)
#error "include/win/libgen.h is only intended for Windows builds"
#endif

#include <string.h>

static inline char *cjq_win_strip_trailing_separators(char *path) {
    size_t len;
    if (!path) {
        return path;
    }

    len = strlen(path);
    while (len > 1 && (path[len - 1] == '\\' || path[len - 1] == '/')) {
        path[--len] = '\0';
    }
    return path;
}

static inline char *dirname(char *path) {
    char *last;

    if (path == NULL || *path == '\0') {
        return ".";
    }

    path = cjq_win_strip_trailing_separators(path);
    last = strrchr(path, '\\');
    if (!last) {
        last = strrchr(path, '/');
    }
    if (!last) {
        return ".";
    }

    if (last == path) {
        // Root path like "\foo" -> "\"
        *(last + 1) = '\0';
        return path;
    }

    *last = '\0';
    return path;
}

static inline char *basename(char *path) {
    const char *last;
    if (!path || *path == '\0') {
        return ".";
    }

    path = cjq_win_strip_trailing_separators(path);
    last = strrchr(path, '\\');
    if (!last) {
        last = strrchr(path, '/');
    }
    if (!last) {
        return path;
    }
    return (char *)(last + 1);
}

#endif /* Cjq_win_libgen_h */
