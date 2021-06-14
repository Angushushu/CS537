#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <unistd.h>

struct job{
	struct job* pre;
	struct job* next;
	int jid;
	int pid;
	int status;
	char* command;
};

struct argsandsize{
	char** args;
	int size;
};

void printjobs(struct job* jobhead){
	struct job* currentjob = jobhead;
	while(currentjob != NULL){

		if(!(WIFEXITED(currentjob->status)||WIFSIGNALED(currentjob->status)||WCOREDUMP(currentjob->status)||WIFSTOPPED(currentjob->status))){//if job still running
			write(1, &(currentjob->status), sizeof(currentjob->status));
        	write(1, ": ", 3);
        	write(1, currentjob->command, sizeof(currentjob->command));//strlen(currentjob->line)
		}
		currentjob = currentjob->next;
	}
}

char* combstr(char* str1, char* str2) {
    char* comb = malloc(strlen(str1) + strlen(str2) + 1);
    strcpy(comb, str1);
    strcat(comb, str2);
    return comb;
}

char* getjobline(char** args, int size){

	char* tempstr = "";
	for(int i=0; i<size-1; i++){
		tempstr = combstr(tempstr, args[i]);
		tempstr = combstr(tempstr, " ");
	}

	tempstr = combstr(tempstr, args[size-1]);
	// make sure command of line stored in heap
	char* str = malloc(strlen(tempstr)*sizeof(char));

	strcpy(str, tempstr);
	return str;
}

struct argsandsize* getargs(char* line){
	char* linecpy = malloc(strlen(line)*sizeof(char));
	strcpy(linecpy, line);
	int size = 1;
	char* tok = strtok(line, " ");
	if(tok == NULL){return NULL;}
	// get size first
	while((tok = strtok(NULL, " ")) != NULL){size++;}

	// start getting args
	char** args = malloc(size*sizeof(char*));
	args[0] = strtok(linecpy, " ");
	for(int i=1; i<size; i++){
		args[i] = strtok(NULL, " ");
	}
	strtok(args[size-1], "\n");//remove \n

	if(strcmp(args[size-1], "&") == 0||strcmp(args[size-1], "\n") == 0){size--;}
	if(size==0){args = NULL;}//for safe

	struct argsandsize* pair = malloc(sizeof(struct argsandsize));
	pair->args = args;
	pair->size = size;
	return pair;
}

void loop(FILE* in, int std){
	struct job* jobhead = NULL;
    	struct job* jobend = NULL;
	int jid = 0;
	while(1){
		char* line = malloc(512*sizeof(char));
		if(std){write(1, "mysh> ", 6*sizeof(char));}
		fgets(line, 512, in);
		struct argsandsize* pair = getargs(line);
		char** args = pair->args;
		int sizeofargs = pair->size;
		if(sizeofargs == 0){continue;}//args == NULL before
		char* jobline = getjobline(args, sizeofargs);
		
		if(strcmp(args[0], "exit") == 0) {
	    	exit(0);
		}else if(strcmp(args[0], "jobs") == 0) {
			printjobs(jobhead);
	       	}else if(strcmp(args[0], "wait") == 0) {
			if(sizeofargs == 2){
				if(waitpid(, NULL, 0)==-1){
					write(1, "Invalid JID\n", 11);
				}else{
					write(1, "JID ", 4);
					write(1, args[1], sizeof(args[1]));
					write(1, " terminated", 11);
				}
			}else{
				write(1, "Invalid JID\n", 11);
			}
			//wait for specific child
		}else{
			//the last char of command is & -> put child in background
			int cpid = fork();
			if(cpid == -1){// fail

			}else if(cpid == 0) {// child
				if(execvp(args[0], args) == -1) {
					write(STDERR_FILENO, args[0], strlen(args[0])*sizeof(char));
					write(STDERR_FILENO, ": Command not found\n", 20*sizeof(char));
					exit(0);
				}
			}else if(args != NULL){// parent problem here
				if(jobline[strlen(jobline)-1] == '&'){//put child in background
					//initialize job
					struct job* cjob = malloc(sizeof(struct job));//no need to malloc for status?
					if(jid == 0){
						jobhead = cjob;
						cjob->pre = NULL;
						cjob->next = NULL;
					}else{
						jobend->next = cjob;
						cjob->pre = jobend;
						cjob->next = NULL;
					}
					cjob->jid = jid;
					cjob->pid = cpid;
					cjob->command = jobline;
					jobend = cjob;

					waitpid(cpid, &(cjob->status), WNOHANG);//set status pointer

				}else{//child in foreground
					waitpid(cpid, NULL, 0);
				}
				jid++;
			}
		}
	}
}

int main(int argc, char** argv){
    if(argc == 1){
        loop(stdin, 1);
    }else if(argc == 2){
	FILE* file = fopen(argv[1], "r");
    	dup2(fileno(file), STDIN_FILENO);
	loop(stdin, 0);
    }else{
        //error
    }
    return 0;
}
