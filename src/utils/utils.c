#include "utils.h"


int validate_extension(const char str[])
{
    char pattern [] = ".nd";
    char pattern_lg[] = ".noodle";

    int i, j, k;
    for(i = 0; str[i] != '.'; i++);
    
    for(j = i, k = 0; pattern[k] != '\0' && str[j] == pattern[k]; j++, k++);

    if(k > 0 && pattern[k] == '\0')
        return 1;       // okay

    // check the second pattern
    else
    {
        for(j = i, k = 0; pattern_lg[k] != '\0' && str[j] == pattern_lg[k]; j++, k++);
        if(k > 0 && pattern_lg[k] == '\0')
            return 1;       // okay  
    }

    return 0;
}

