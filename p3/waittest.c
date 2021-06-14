#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

int main(int argc, char** argv) {
	//while(1) {
		int status = 0;
		int cpid = fork();
		if(cpid == -1) {// fail
		
		}else if(cpid == 0) {// child
			for(int i=0; i<50; i++) {
				printf("  [c] - status = %i\n", status);
			}
		}else {
			for(int i=0; i<50; i++) {
				//waitpid(cpid, &status, WNOHANG);//put child in background
				//waitpid(cpid, &status, 0);//put child in foreground
				printf("[p] - status = %i\n", status);
			}
		}
	//}
	return 0;
}
