/* Minimal config.h for Oniguruma on Apple/Linux platforms */
#ifndef CONFIG_H
#define CONFIG_H

#define HAVE_STDLIB_H 1
#define HAVE_STRING_H 1
#define HAVE_STDINT_H 1
#define HAVE_SYS_TYPES_H 1
#define HAVE_INTTYPES_H 1

#define SIZEOF_INT 4
#define SIZEOF_LONG 8
#define SIZEOF_LONG_LONG 8
#define SIZEOF_VOIDP 8

#define PACKAGE_VERSION "6.9.9"

#endif /* CONFIG_H */
