#ifndef JQ_WIN32_UNISTD_H
#define JQ_WIN32_UNISTD_H

#if defined(_WIN32) || defined(_WIN64)

#include <BaseTsd.h>
#include <direct.h>
#include <io.h>
#include <process.h>
#include <stdlib.h>
#include <stdio.h>
#include <windows.h>

#ifndef ssize_t
typedef SSIZE_T ssize_t;
#endif

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
#define X_OK 0
#endif

#ifndef W_OK
#define W_OK 2
#endif

#ifndef R_OK
#define R_OK 4
#endif

#define access  _access
#define close   _close
#define dup     _dup
#define dup2    _dup2
#define unlink  _unlink
#define fileno  _fileno
#define isatty  _isatty
#define lseek   _lseek
#define read    _read
#define write   _write
#define pipe    _pipe
#define getpid  _getpid
#define chdir   _chdir
#define rmdir   _rmdir
#define fsync   _commit

static inline unsigned int sleep(unsigned int seconds) {
    Sleep(seconds * 1000);
    return 0;
}

static inline int usleep(unsigned int usec) {
    Sleep((usec + 999) / 1000);
    return 0;
}

#else
#include_next <unistd.h>
#endif /* defined(_WIN32) || defined(_WIN64) */

#endif /* JQ_WIN32_UNISTD_H */
