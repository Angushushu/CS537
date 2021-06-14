#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char** argv){
	FILE* file = fopen(argv[1], "r");
    	dup2(fileno(file), STDIN_FILENO);
	char* line = malloc(512*sizeof(char));
	while(fgets(line, 512, stdin)!=NULL){
		printf("h\n");
	}
	return 0;
}
