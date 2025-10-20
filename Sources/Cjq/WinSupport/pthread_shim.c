#if defined(_WIN32) && !defined(__MINGW32__)
#include <windows.h>
#include <errno.h>
#include <stdlib.h>

#include "jv_thread.h"

typedef struct key_entry {
    DWORD fls_index;
    void (*destructor)(void *);
} key_entry;

typedef struct tls_record {
    key_entry *entry;
    void *value;
} tls_record;

static key_entry **key_table = NULL;
static size_t key_count = 0;
static size_t key_capacity = 0;

static INIT_ONCE key_once = INIT_ONCE_STATIC_INIT;
static CRITICAL_SECTION key_lock;

static BOOL CALLBACK init_key_table(PINIT_ONCE init_once, PVOID parameter, PVOID *context) {
    (void)init_once;
    (void)parameter;
    (void)context;
    InitializeCriticalSection(&key_lock);
    return TRUE;
}

static void ensure_initialized(void) {
    InitOnceExecuteOnce(&key_once, init_key_table, NULL, NULL);
}

static VOID CALLBACK win_pthread_fls_callback(PVOID data) {
    tls_record *record = (tls_record *)data;
    if (!record) {
        return;
    }
    if (record->entry && record->entry->destructor && record->value) {
        record->entry->destructor(record->value);
    }
    free(record);
}

static key_entry *lookup_entry(pthread_key_t key) {
    if (key == 0) {
        return NULL;
    }
    size_t index = (size_t)(key - 1);
    if (index >= key_count) {
        return NULL;
    }
    return key_table[index];
}

int pthread_key_create(pthread_key_t *key, void (*destructor)(void *)) {
    if (!key) {
        return EINVAL;
    }

    ensure_initialized();
    key_entry *entry = (key_entry *)malloc(sizeof(key_entry));
    if (!entry) {
        return ENOMEM;
    }

    DWORD fls_index = FlsAlloc(win_pthread_fls_callback);
    if (fls_index == FLS_OUT_OF_INDEXES) {
        free(entry);
        return ENOMEM;
    }

    entry->fls_index = fls_index;
    entry->destructor = destructor;

    EnterCriticalSection(&key_lock);
    if (key_count == key_capacity) {
        size_t new_capacity = key_capacity == 0 ? 8 : key_capacity * 2;
        key_entry **new_table = (key_entry **)realloc(key_table, new_capacity * sizeof(key_entry *));
        if (!new_table) {
            LeaveCriticalSection(&key_lock);
            FlsFree(fls_index);
            free(entry);
            return ENOMEM;
        }
        key_table = new_table;
        key_capacity = new_capacity;
    }

    key_table[key_count] = entry;
    *key = (pthread_key_t)(key_count + 1);
    key_count++;
    LeaveCriticalSection(&key_lock);

    return 0;
}

int pthread_setspecific(pthread_key_t key, void *value) {
    ensure_initialized();

    key_entry *entry = lookup_entry(key);
    if (!entry) {
        return EINVAL;
    }

    tls_record *record = (tls_record *)FlsGetValue(entry->fls_index);

    if (!value) {
        if (record) {
            FlsSetValue(entry->fls_index, NULL);
            free(record);
        }
        return 0;
    }

    if (!record) {
        record = (tls_record *)malloc(sizeof(tls_record));
        if (!record) {
            return ENOMEM;
        }
        record->entry = entry;
        record->value = value;
        if (!FlsSetValue(entry->fls_index, record)) {
            free(record);
            return ENOMEM;
        }
        return 0;
    }

    record->value = value;
    return 0;
}

void *pthread_getspecific(pthread_key_t key) {
    ensure_initialized();

    key_entry *entry = lookup_entry(key);
    if (!entry) {
        return NULL;
    }

    tls_record *record = (tls_record *)FlsGetValue(entry->fls_index);
    return record ? record->value : NULL;
}

static BOOL CALLBACK once_proxy(PINIT_ONCE init_once, PVOID parameter, PVOID *context) {
    (void)init_once;
    (void)context;
    void (*func)(void) = (void (*)(void))parameter;
    func();
    return TRUE;
}

int pthread_once(pthread_once_t *once_control, void (*init_routine)(void)) {
    if (InitOnceExecuteOnce(once_control, once_proxy, init_routine, NULL)) {
        return 0;
    }
    return GetLastError();
}

#endif /* _WIN32 && !__MINGW32__ */
