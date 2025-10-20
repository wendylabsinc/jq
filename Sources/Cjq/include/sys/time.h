#ifndef JQ_WIN32_SYS_TIME_H
#define JQ_WIN32_SYS_TIME_H

#if defined(_WIN32) || defined(_WIN64)

#include <windows.h>
#include <time.h>

struct timeval {
    long tv_sec;
    long tv_usec;
};

static inline int gettimeofday(struct timeval *tp, void *tzp) {
    (void)tzp;
    if (!tp) {
        return -1;
    }

    FILETIME ft;
    GetSystemTimeAsFileTime(&ft);

    ULARGE_INTEGER uli;
    uli.LowPart = ft.dwLowDateTime;
    uli.HighPart = ft.dwHighDateTime;

    const ULONGLONG WINDOWS_TO_UNIX_EPOCH = 11644473600ULL; // seconds
    ULONGLONG totalMicroseconds = uli.QuadPart / 10ULL;
    totalMicroseconds -= WINDOWS_TO_UNIX_EPOCH * 1000000ULL;

    tp->tv_sec = (long)(totalMicroseconds / 1000000ULL);
    tp->tv_usec = (long)(totalMicroseconds % 1000000ULL);
    return 0;
}

#else
#include_next <sys/time.h>
#endif

#endif /* JQ_WIN32_SYS_TIME_H */
