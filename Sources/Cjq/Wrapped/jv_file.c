#if defined(_WIN32)
#include <sys/stat.h>
#ifndef S_ISDIR
#define S_ISDIR(mode) (((mode) & S_IFMT) == S_IFDIR)
#endif
#endif
#include "../jq/src/jv_file.c"
