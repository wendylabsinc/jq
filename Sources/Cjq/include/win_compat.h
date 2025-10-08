// Minimal Windows compatibility shims for building jq as a C target
// in SwiftPM on Windows runners without MSYS/MinGW.

#ifndef JQ_SWIFT_WIN_COMPAT_H
#define JQ_SWIFT_WIN_COMPAT_H

#ifdef _WIN32

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

#endif // _WIN32

#endif // JQ_SWIFT_WIN_COMPAT_H
