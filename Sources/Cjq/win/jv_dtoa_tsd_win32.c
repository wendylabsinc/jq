#if defined(_WIN32)

#include <stdlib.h>
#include <stdio.h>

#include "../jq/src/jv_thread.h"
#include "../jq/src/jv_dtoa.h"
#include "../jq/src/jv_alloc.h"
#include "../jq/src/jv_dtoa_tsd.h"

static pthread_once_t dtoa_once = PTHREAD_ONCE_INIT;
static pthread_key_t dtoa_key;

void jv_tsd_dtoa_ctx_init(void);
void jv_tsd_dtoa_ctx_fini(void);

static void tsd_dtoa_ctx_dtor(void *ctx) {
    if (ctx) {
        jvp_dtoa_context_free((struct dtoa_context *)ctx);
        jv_mem_free(ctx);
    }
}

static void dtoa_key_init(void) {
    if (pthread_key_create(&dtoa_key, tsd_dtoa_ctx_dtor) != 0) {
        fprintf(stderr, "error: cannot create thread specific key");
        abort();
    }
    atexit(jv_tsd_dtoa_ctx_fini);
}

void jv_tsd_dtoa_ctx_init(void) {
    pthread_once(&dtoa_once, dtoa_key_init);
}

void jv_tsd_dtoa_ctx_fini(void) {
    struct dtoa_context *ctx = pthread_getspecific(dtoa_key);
    tsd_dtoa_ctx_dtor(ctx);
    pthread_setspecific(dtoa_key, NULL);
}

struct dtoa_context *tsd_dtoa_context_get(void) {
    pthread_once(&dtoa_once, dtoa_key_init);
    struct dtoa_context *ctx = (struct dtoa_context *)pthread_getspecific(dtoa_key);
    if (!ctx) {
        ctx = (struct dtoa_context *)jv_mem_alloc(sizeof(struct dtoa_context));
        jvp_dtoa_context_init(ctx);
        if (pthread_setspecific(dtoa_key, ctx) != 0) {
            fprintf(stderr, "error: cannot set thread specific data");
            abort();
        }
    }
    return ctx;
}

#else

#include "../jq/src/jv_dtoa_tsd.c"

#endif /* defined(_WIN32) */
