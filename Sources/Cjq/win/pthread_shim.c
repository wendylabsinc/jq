#if defined(_WIN32)

#include <errno.h>
#include <windows.h>

#include "../jq/src/jv_thread.h"

int pthread_key_create(pthread_key_t *key, void (*destructor)(void *)) {
    DWORD slot = FlsAlloc(destructor);
    if (slot == FLS_OUT_OF_INDEXES) {
        return ENOMEM;
    }
    *key = slot;
    return 0;
}

int pthread_setspecific(pthread_key_t key, void *value) {
    return FlsSetValue(key, value) ? 0 : EINVAL;
}

void *pthread_getspecific(pthread_key_t key) {
    return FlsGetValue(key);
}

#endif /* defined(_WIN32) */
