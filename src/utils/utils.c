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

char* readFile(const char* path)
{
    FILE* file = fopen(path, "rb");

    // seek the full size to decide what memory to allocate
    fseek(file, 0L, SEEK_END);
    size_t fileSize = ftell(file);
    rewind(file);

    // actually read the file
    char* buffer = malloc(fileSize + 1);
    size_t bytesRead = fread(buffer, sizeof(char), fileSize, file);


    // put the null terminator and return the buffer
    buffer[bytesRead] = '\0';

    fclose(file);
    return buffer;
}
