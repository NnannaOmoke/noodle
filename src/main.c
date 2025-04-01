#include <stdio.h>
//#include "include/common.h"
#include "utils/utils.h"


int main(int argc, const char* argv[]){
  if(argc == 1)
 	 printf("Welcome to the Noodle compiler!\n");
  fflush(stdout);
 //  else{
	// // please check this
	// fprintf(stderr,"Usage: noodle has no implementation yet ;\n");
 //  }
  printf("We got here in main!"); 
  test_with_builtin();
  
  return 0;
}
