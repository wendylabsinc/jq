#if defined(_WIN32)
#define WIN32_LEAN_AND_MEAN
#include <windows.h>
#include <processenv.h>
#include <shellapi.h>
#include <wchar.h>
#include <wtypes.h>
#ifndef PATH_MAX
#define PATH_MAX MAX_PATH
#endif
#endif
#include "../jq/src/util.c"
