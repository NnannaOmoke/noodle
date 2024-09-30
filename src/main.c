#include <stdio.h>
#include <stdlib.h>
#include "include/common.h"
#include "utils/utils.h"

int main(int argc, const char* argv[]){
	if(argc == 1)
		printf("Welcome to the Noodle compiler!\n");
	
	else if(argc == 2)
	{

		if(validate_extension(argv[1]))
		{
			//runFile(argv[1]);
			// what we have for now
			printf("[noodle:Ok]	Valid File: %s\n", argv[1]);
			printf("%s\n", readFile(argv[1]));
		}
		else
		{
			fprintf(stderr, "[noodle:Error] Invalid File: %s \n", argv[1]);
			exit(USAGE_ERROR);
		}
		
	}
	
	else{
		fprintf(stderr, "[noodle: Error] Usage: noodle <path>\n");
		exit(USAGE_ERROR);
	}
	return 0;
}
