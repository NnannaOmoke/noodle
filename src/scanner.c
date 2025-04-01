#include "include/scanner.h"

void initScanner(Scanner *scanner_obj, const char *source)
{
    scanner_obj->start = source;
    scanner_obj->current = source;
    scanner_obj->line = 1;
}

