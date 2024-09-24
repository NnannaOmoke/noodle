#include <stdio.h>
#include "include/common.h"
#include "utils/utils.h"

int main(int argc, const char* argv[]){
  if(argc == 1)
 	 printf("Welcome to the Noodle compiler!\n");
  
  else{
	for(int i = 1; i < argc; i++)
	{
		if(validate_extension(argv[i]))
			printf("[noodle]	Valid File: %s\n", argv[i]);
		
		else
			fprintf(stderr, "[noodle]	Invalid File: %s\n", argv[i]);
	}
		
}
return 0;
}
