#ifndef JQ_WRAPPER_H
#define JQ_WRAPPER_H

#if defined(_WIN32) || defined(_WIN64)
// clang-cl does not emit GCC-style format attributes; stub them out so jq's
// headers compile without altering the vendored sources.
#ifndef JV_PRINTF_LIKE
#define JV_PRINTF_LIKE(fmt_arg_num, args_num)
#endif
#ifndef JV_VPRINTF_LIKE
#define JV_VPRINTF_LIKE(fmt_arg_num)
#endif
#endif

#include "../jq/src/jq.h"

#endif /* JQ_WRAPPER_H */
