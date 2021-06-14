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
	char** args;
    int size;
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
        		write(1, " : ", 3);
            		//print command
            		for(int i=0; i<currentjob->size-1; i++){
               			write(STDOUT_FILENO, currentjob->args[i], strlen(currentjob->args[i]));
               			write(STDOUT_FILENO, " ", 1);
            		}
            		if(strcmp(currentjob->args[currentjob->size-1], "\n")!=0){
                		write(1, currentjob->args[currentjob->size-1], strlen(currentjob->args[currentjob->size-1]));
           		}
		}
		currentjob = currentjob->next;
	}
}

int jidtopid(struct job* jobhead, int jid){
    struct job* currentjob = jobhead;
    while(currentjob != NULL){
        if(currentjob->jid == jid){
            return currentjob->pid;
        }
    }
    return -1;
}

char* combstr(char* str1, char* str2) {
    char* comb = malloc(strlen(str1) + strlen(str2) + 1);
    strcpy(comb, str1);
    strcat(comb, str2);
    return comb;
}

struct argsandsize* getargs(char* line){
    strtok(line, "\n");
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
	if(size==0){args = NULL;}//for safe

	struct argsandsize* pair = malloc(sizeof(struct argsandsize));
	pair->args = args;
	pair->size = size;
	return pair;
}

int loop(int interact){
	struct job* jobhead = NULL;
	struct job* jobend = NULL;
	int jid = 0;
	//int counter = 0;
	while(1){
		char line[512];
		//char* line = malloc(512*sizeof(char));
		//counter++;
		if(interact){write(STDOUT_FILENO, "mysh> ", 6*sizeof(char));}
        if(fgets(line, 512, stdin)==NULL){
			//printf("finish-%i\n",counter);
			//exit(0);
			break;
		}//why doesnt work
		//fgets(line, 512, stdin);
		//printf("  ca\n");
		char linecpy[512];
		strcpy(linecpy, line);
		//try clean line
		//for(int i=0;i<512;i++){line[i]=EOF;}
		struct argsandsize* pair = getargs(linecpy);//this change line
		//printf("  cb\n");
		char** args = pair->args;
		//printf("  cc\n");
		int sizeofargs = pair->size;

		if(sizeofargs>1 && strcmp(args[sizeofargs-2], ">") == 0){//redirection
            FILE* file = fopen(args[sizeofargs-1], "r");
            dup2(fileno(file), STDOUT_FILENO);//consider about NULL case
            ftruncate(STDOUT_FILENO, 0);//set file size to 0
		}

        //check
        //printf("line: %s\n", line);
		//printf("linecpy: %s\n", linecpy);
        //for(int i=0;i<sizeofargs;i++){
        //	printf("args[%i]: \"%s\"\n", i, args[i]);
        //}
		//printf("sizeofargs: %i\n", sizeofargs);

		
		//when user type Ctrl-D
		if(sizeofargs == 1 && strcmp(args[0], "Ctrl-D")==0)
		//corner case
        if((sizeofargs == 1 && args[0][strlen(args[0]-1)] == '&')||sizeofargs == 0){continue;}

		if(sizeofargs == 1&&strcmp(args[0],"\n")==0){continue;}//args == NULL before
		
		if(strcmp(args[0], "exit") == 0) {
			exit(1);
		}else if(sizeofargs == 1 && strcmp(args[0], "jobs") == 0) {
			printjobs(jobhead);
		}else if(strcmp(args[0], "wait") == 0) {
			int pid = jidtopid(jobhead, atoi(args[1]));
        	if(sizeofargs == 2 && pid!=-1){
                if(waitpid(pid, NULL, 0)==-1){
					write(STDOUT_FILENO, "Invalid JID\n", 11);
				}else{
					write(STDOUT_FILENO, "JID ", 4);
					write(STDOUT_FILENO, args[1], sizeof(args[1]));
					write(STDOUT_FILENO, " terminated", 11);
				}
			}else{
				write(STDOUT_FILENO, "Invalid JID\n", 11);
			}
		}else{

			//printf("  c2\n");

			//the last char of command is & -> put child in background
			int cpid = fork();
			if(cpid == -1){// fail

				//printf("    c2-a\n");
			}else if(cpid == 0) {// child

				//printf("    c2-b\n");
				
				if(execvp(args[0], args) == -1) {
					write(STDERR_FILENO, args[0], strlen(args[0])*sizeof(char));
					write(STDERR_FILENO, ": Command not found\n", 20*sizeof(char));
					//exit(0);
					_Exit(3);
				}
				//exit(0);
				_Exit(3);
			}else if(args != NULL){// parent problem here

				//printf("    c2-c\n");

				if(strcmp(args[sizeofargs-1], "&") == 0){//put child in background
					args[sizeofargs-1] = NULL;
                	//initialize job
					struct job* cjob = malloc(sizeof(struct job));//no need to malloc for status?
                	cjob->jid = jid;
					cjob->pid = cpid;
					cjob->args = args;
                	cjob->size = sizeofargs;
                	if(jobend == NULL){
						jobhead = cjob;
						cjob->pre = NULL;
						cjob->next = NULL;
					}else{
						jobend->next = cjob;
						cjob->pre = jobend;
						cjob->next = NULL;
					}					
					jobend = cjob;
					waitpid(cpid, &(cjob->status), WNOHANG);//set status pointer

					//printf("    c2-d\n");

                }else{//child in foreground
					waitpid(cpid, NULL, 0);
				}
				jid++;
			}
		}
        	//free(line);
		//return 0;
	}
	return 0;
}

int main(int argc, char** argv){
    if(argc == 1){
        return(loop(1));//1 for interactive
    }else if(argc == 2){
		FILE* file = fopen(argv[1], "r");
		if(file == NULL){
			write(STDERR_FILENO, "Error: Cannot open file ", 24);
			write(STDERR_FILENO, argv[1], strlen(argv[1]));
		}
    	dup2(fileno(file), STDIN_FILENO);
		//ftruncate(STDIN_FILENO, 0);
		return(loop(0));//0 for batch
    }else{
        write(STDERR_FILENO, "Usage: mysh [batchFile]\n", 24);
    }
    return 0;
}
