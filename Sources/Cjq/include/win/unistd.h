#ifndef Cjq_win_unistd_h
#define Cjq_win_unistd_h

#if !defined(_WIN32)
#error "include/win/unistd.h is only intended for Windows builds"
#endif

#include <io.h>
#include <process.h>
#include <direct.h>
#include <stdlib.h>

#ifndef STDIN_FILENO
#define STDIN_FILENO 0
#endif

#ifndef STDOUT_FILENO
#define STDOUT_FILENO 1
#endif

#ifndef STDERR_FILENO
#define STDERR_FILENO 2
#endif

#ifndef F_OK
#define F_OK 0
#endif

#ifndef X_OK
#define X_OK 1
#endif

#ifndef W_OK
#define W_OK 2
#endif

#ifndef R_OK
#define R_OK 4
#endif

#ifndef ssize_t
#define ssize_t long
#endif

#define access  _access
#define close   _close
#define dup     _dup
#define dup2    _dup2
#define fileno  _fileno
#define isatty  _isatty
#define lseek   _lseek
#define read    _read
#define unlink  _unlink
#define write   _write

#define usleep(usec) _sleep((unsigned)((usec) / 1000))

#endif /* Cjq_win_unistd_h */
