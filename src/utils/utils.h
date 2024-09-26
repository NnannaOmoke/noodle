#ifndef NOODLE_UTILS_H
#define NOODLE_UTILS_H

#ifdef _WIN32
    #include <windows.h>

    #define USAGE_ERROR ERROR_BAD_ARGUMENTS

#else
    #include <sysexits.h>
    #define USAGE_ERROR EX_USAGE

#endif

int validate_extension(const char []);

#endif

