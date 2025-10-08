// Lightweight unistd.h shim for Windows builds of jq via SwiftPM.
// Only included on Windows because we put this directory first in the
// header search path and inject it with -include elsewhere.

#ifndef JQ_SWIFT_FAKE_UNISTD_H
#define JQ_SWIFT_FAKE_UNISTD_H

#ifdef _WIN32
#include <io.h>
#include <direct.h>
#include <process.h>

// Map common POSIX APIs to MSVCRT names
#ifndef access
#define access _access
#endif
#ifndef close
#define close _close
#endif
#ifndef dup
#define dup _dup
#endif
#ifndef dup2
#define dup2 _dup2
#endif
#ifndef read
#define read _read
#endif
#ifndef write
#define write _write
#endif
#ifndef unlink
#define unlink _unlink
#endif

// ssize_t is not defined by MSVCRT headers
#ifndef _SSIZE_T_DEFINED
#include <BaseTsd.h>
typedef SSIZE_T ssize_t;
#define _SSIZE_T_DEFINED
#endif

#else
#include_next <unistd.h>
#endif

#endif // JQ_SWIFT_FAKE_UNISTD_H

