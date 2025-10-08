// Minimal Windows compatibility shims for building jq as a C target
// in SwiftPM on Windows runners without MSYS/MinGW.

#ifndef JQ_SWIFT_WIN_COMPAT_H
#define JQ_SWIFT_WIN_COMPAT_H

#ifdef _WIN32

// Normalize Windows macro expected by jq sources
#ifndef WIN32
#define WIN32 1
#endif

// The flex-generated lexer tries to include <unistd.h>.
// That header does not exist on Windows/MSVC; tell it to skip.
#ifndef YY_NO_UNISTD_H
#define YY_NO_UNISTD_H 1
#endif

// Attribute hints used by jq become syntax errors on non-GNU compilers.
// Make them no-ops when __GNUC__ is not defined (MSVC/clang-cl mode).
#ifndef __GNUC__
#ifndef JV_PRINTF_LIKE
#define JV_PRINTF_LIKE(fmt_arg_num, args_num)
#endif
#ifndef JV_VPRINTF_LIKE
#define JV_VPRINTF_LIKE(fmt_arg_num)
#endif
#endif

// Basic POSIX I/O helpers used by jq
#include <io.h>
#include <windows.h>
#include <limits.h>
#include <stdlib.h>
#include <sys/stat.h>
#include <time.h>
#ifndef isatty
#define isatty _isatty
#endif
#ifndef fileno
#define fileno _fileno
#endif

// ssize_t compatibility
#ifndef _SSIZE_T_DEFINED
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#define _SSIZE_T_DEFINED
#endif

// PATH_MAX fallback for Windows (prefer large path capacity)
#ifndef PATH_MAX
#define PATH_MAX 32767
#endif

// stat macros parity
#ifndef S_ISDIR
#define S_ISDIR(m) (((m) & _S_IFMT) == _S_IFDIR)
#endif

// pthread_once emulation using Windows InitOnce
typedef INIT_ONCE pthread_once_t;
#ifndef PTHREAD_ONCE_INIT
#define PTHREAD_ONCE_INIT INIT_ONCE_STATIC_INIT
#endif
static BOOL CALLBACK jq_once_callback(PINIT_ONCE init_once, PVOID parameter, PVOID* context) {
  (void)init_once; (void)context;
  void (*fn)(void) = (void (*)(void))parameter;
  fn();
  return TRUE;
}
static inline int pthread_once(pthread_once_t* once_control, void (*init_routine)(void)) {
  return InitOnceExecuteOnce(once_control, jq_once_callback, (PVOID)init_routine, NULL) ? 0 : 1;
}

// tz globals mapping
#ifndef tzname
#define tzname _tzname
#endif
#ifndef timezone
#define timezone _timezone
#endif

// Declare MSVCRT timezone globals if headers don't
extern char *_tzname[2];
extern long _timezone;

#endif // _WIN32

#endif // JQ_SWIFT_WIN_COMPAT_H
