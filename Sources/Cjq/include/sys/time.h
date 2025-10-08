// Minimal sys/time.h for Windows builds
#ifndef JQ_SWIFT_SYS_TIME_H
#define JQ_SWIFT_SYS_TIME_H

#ifdef _WIN32
#include <time.h>
#include <sys/timeb.h>

// Define timeval if not defined and prevent later winsock redefinition
#ifndef _TIMEVAL_DEFINED
#define _TIMEVAL_DEFINED 1
struct timeval {
  long tv_sec;
  long tv_usec;
};
#endif

static inline int gettimeofday(struct timeval *tv, void *tz_unused) {
  (void)tz_unused;
  struct __timeb64 tb;
  _ftime64(&tb);
  tv->tv_sec = (long)tb.time;
  tv->tv_usec = (long)(tb.millitm * 1000);
  return 0;
}

#else
#include_next <sys/time.h>
#endif

#endif // JQ_SWIFT_SYS_TIME_H
