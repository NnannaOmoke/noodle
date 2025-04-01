#include<string.h>
#include<assert.h>
#include "utils.h"
#include <stdio.h>

int validate_linux_fname(char* fname){
  char validfident [] = "nd";
  char validlongerfindent [] = "noodle";
  char* validptr = strtok(fname, ".");
  if (validptr == NULL){
    return 0;
  }
  if(strcmp(validptr + 1, validfident) == 0 || strcmp(validptr + 1, validlongerfindent) == 0){
    return 1;
  }
  return 0;
}

void test_with_builtin(){
  const char* test_string= "validfilename.noodle";
  const char* test_string_two = "validfilename.nd";
  const char* test_string_three= "nonvalidfilename.py";
 // char* empty_string = "";
  printf("We got here!");
  assert(validate_linux_fname(test_string) == 1);
  assert(validate_linux_fname(test_string_two) == 1);
  assert(validate_linux_fname(test_string_three) == 0);
  //assert(validate_linux_fname(empty_string) == 0);
}
