/* Minimal config.h for Oniguruma on Apple/Linux platforms */
#ifndef CONFIG_H
#define CONFIG_H

#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_STDINT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_INTTYPES_H 1

#define SIZEOF_INT 4

#if defined(_WIN32) || defined(_WIN64)
#define SIZEOF_LONG 4
#define SIZEOF_LONG_LONG 8
#  if defined(_WIN64)
#    define SIZEOF_VOIDP 8
#  else
#    define SIZEOF_VOIDP 4
#  endif
#else
#define SIZEOF_LONG 8
#define SIZEOF_LONG_LONG 8
#define SIZEOF_VOIDP 8
#endif

#define PACKAGE_VERSION "6.9.9"

#endif /* CONFIG_H */
