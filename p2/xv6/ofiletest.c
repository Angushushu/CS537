#include "types.h" 
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int main(int argc, char** argv){
  if(argc < 2){
    exit();
  }
  int nopen = atoi(argv[1]);
  if(argc > nopen+1 || nopen > 16){
    exit();
  }
  for(int i = 2; i < argc; i++){
    if(atoi(argv[i]) >= nopen){
      exit();
    }
  }

  int* files = malloc(nopen*sizeof(int));
  for(int i = 0; i < nopen; i++){
    char* fname;
    if(i < 10){
      fname = malloc(5*sizeof(char));
      fname[4] = '0'+i;
    }else{
      fname = malloc(6*sizeof(char));
      fname[5] = '0'+i%10;
      fname[4] = '0'+i/10;
    }
    fname[0]='f';fname[1]='i';fname[2]='l';fname[3]='e';
    files[i] = open(fname, O_CREATE|O_RDONLY);
    free(fname);
  }

  for(int i = 2; i < argc; i++){
    close(files[atoi(argv[i])]);
  }

  free(files);
  int nf = getofilecnt(getpid());
  int next = getofilenext(getpid());
  printf(1, "%d %d\n", nf, next);
  exit();
}
