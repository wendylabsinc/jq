#ifndef Cjq_win_sys_time_h
#define Cjq_win_sys_time_h

#if !defined(_WIN32)
#error "include/win/sys/time.h is only intended for Windows builds"
#endif

#include <windows.h>

struct timeval {
    long tv_sec;
    long tv_usec;
};

static inline int gettimeofday(struct timeval *tv, void *tz) {
    (void)tz;
    if (!tv) {
        return -1;
    }

    FILETIME ft;
    GetSystemTimeAsFileTime(&ft);

    ULARGE_INTEGER uli;
    uli.LowPart = ft.dwLowDateTime;
    uli.HighPart = ft.dwHighDateTime;

    const unsigned long long epoch_diff = 116444736000000000ULL; // 1/1/1970 vs 1/1/1601
    unsigned long long time64 = uli.QuadPart;
    if (time64 < epoch_diff) {
        return -1;
    }
    time64 -= epoch_diff;

    tv->tv_sec = (long)(time64 / 10000000ULL);
    tv->tv_usec = (long)((time64 % 10000000ULL) / 10ULL);
    return 0;
}

#endif /* Cjq_win_sys_time_h */
