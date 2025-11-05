#ifndef Cjq_win_preamble_h
#define Cjq_win_preamble_h

#if defined(_WIN32)
#ifndef JV_PRINTF_LIKE
#define JV_PRINTF_LIKE(fmt_arg_num, args_num)
#endif

#ifndef JV_VPRINTF_LIKE
#define JV_VPRINTF_LIKE(fmt_arg_num)
#endif

#include <stdlib.h>
#include <windows.h>

typedef INIT_ONCE pthread_once_t;

#ifndef PTHREAD_ONCE_INIT
#define PTHREAD_ONCE_INIT INIT_ONCE_STATIC_INIT
#endif

static inline BOOL CALLBACK cjq_win_once_proxy(PINIT_ONCE once, PVOID param, PVOID *context) {
    (void)once;
    (void)context;
    if (param) {
        void (*routine)(void) = (void (*)(void))param;
        routine();
    }
    return TRUE;
}

static inline int pthread_once(pthread_once_t *once_control, void (*init_routine)(void)) {
    return InitOnceExecuteOnce(once_control, cjq_win_once_proxy, init_routine, NULL) ? 0 : (int)GetLastError();
}

#include <sys/stat.h>
#ifndef S_ISDIR
#define S_ISDIR(mode) (((mode) & _S_IFDIR) == _S_IFDIR)
#endif

#ifndef S_ISREG
#define S_ISREG(mode) (((mode) & _S_IFREG) == _S_IFREG)
#endif

#ifndef PATH_MAX
#define PATH_MAX 260
#endif

#endif /* _WIN32 */

#endif /* Cjq_win_preamble_h */
