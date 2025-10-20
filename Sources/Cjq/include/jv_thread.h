#ifndef JQ_WRAPPER_JV_THREAD_H
#define JQ_WRAPPER_JV_THREAD_H

#if defined(_WIN32) && !defined(__MINGW32__)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <winnt.h>
typedef INIT_ONCE pthread_once_t;
int pthread_once(pthread_once_t *, void (*)(void));
#endif

#include "../jq/src/jv_thread.h"

#endif /* JQ_WRAPPER_JV_THREAD_H */
