#ifndef NOODLE_UTILS_H
#define NOODLE_UTILS_H
#include <stdio.h>
#include <string.h>
#include <stdlib.h>


#ifdef _WIN32
    #include <windows.h>

    #define USAGE_ERROR ERROR_BAD_ARGUMENTS

#else
    #include <sysexits.h>
    #define USAGE_ERROR EX_USAGE

#endif

char* readFile(const char* path);
int validate_extension(const char []);

#endif

