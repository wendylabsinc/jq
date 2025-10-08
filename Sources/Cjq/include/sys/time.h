// Minimal sys/time.h for Windows builds
#ifndef JQ_SWIFT_SYS_TIME_H
#define JQ_SWIFT_SYS_TIME_H

#ifdef _WIN32
#include <windows.h>
#include <time.h>

struct timeval {
  long tv_sec;   // seconds
  long tv_usec;  // microseconds
};

static inline int gettimeofday(struct timeval *tv, void *tz_unused) {
  (void)tz_unused;
  FILETIME ft;
  GetSystemTimeAsFileTime(&ft);
  ULARGE_INTEGER uli;
  uli.LowPart = ft.dwLowDateTime;
  uli.HighPart = ft.dwHighDateTime;
  unsigned long long usec = (uli.QuadPart - 116444736000000000ULL) / 10ULL; // to microseconds since Unix epoch
  tv->tv_sec = (long)(usec / 1000000ULL);
  tv->tv_usec = (long)(usec % 1000000ULL);
  return 0;
}

#else
#include_next <sys/time.h>
#endif

#endif // JQ_SWIFT_SYS_TIME_H

