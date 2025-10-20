#ifndef JV_WRAPPER_H
#define JV_WRAPPER_H

#if defined(_WIN32) || defined(_WIN64)
#ifndef JV_PRINTF_LIKE
#define JV_PRINTF_LIKE(fmt_arg_num, args_num)
#endif
#ifndef JV_VPRINTF_LIKE
#define JV_VPRINTF_LIKE(fmt_arg_num)
#endif
#endif

#include "../jq/src/jv.h"

#endif /* JV_WRAPPER_H */
