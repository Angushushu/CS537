
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/types.h>//for open()
#include <sys/stat.h>//
#include <fcntl.h>//
#include <unistd.h>

struct job{
	struct job* pre;
	struct job* next;
	int jid;
	pid_t pid;
	//int* status;//
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
		//write(1, "here's a job\n", 13);//prob here
		
		int status;
		waitpid(currentjob->pid, &status, WNOHANG);//was NULL or WNOHANG
		printf("--jobs test--\n");
		printf("status: %i\n", status);
		printf("pid: %i\n", currentjob->pid);
		printf("WIFSIGNALED(status): %i\n",WIFSIGNALED(status));
		printf("WIFEXITED(status): %i\n",WIFEXITED(status));
		printf("WCOREDUMP(status): %i\n",WCOREDUMP(status));
		printf("WIFSTOPPED(status): %i\n",WIFSTOPPED(status));
		printf("!(WIFEXITED(status)||WIFSIGNALED(status)||WCOREDUMP(status)||WIFSTOPPED(status)): %i\n",!(WIFEXITED(status)||WIFSIGNALED(status)||WCOREDUMP(status)||WIFSTOPPED(status)));
		
		printf("--jobs test end--\n");

		//if(!(WIFEXITED(status)||WIFSIGNALED(status)||WCOREDUMP(status)||WIFSTOPPED(status))){//if job still running
		if(!(WIFEXITED(status))){
			write(1, "here's a job\n", 13);
			char buff[100];
			sprintf(buff, "%d", currentjob->jid);
			write(1, buff, strlen(buff));
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

struct job* jidtopid(struct job* jobhead, int jid){
    struct job* currentjob = jobhead;
    while(currentjob != NULL){
        if(currentjob->jid == jid){
            return currentjob;
        }
    }
    return NULL;
}

char* combstr(char* str1, char* str2) {
    char* comb = malloc(strlen(str1) + strlen(str2) + 1);
    strcpy(comb, str1);
    strcat(comb, str2);
    return comb;
}


//add functions of > checking, put >'s in independent args, set args to NULL&
//argsandsize also need to store position of first >
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
	char** args = malloc((size+1)*sizeof(char*));//the last one should be NULL
	args[0] = strtok(linecpy, " ");
	for(int i=1; i<size; i++){
		args[i] = strtok(NULL, " ");
		//char* word = malloc(strlen(args[i]*sizeof(char)));
		//strcpy(word, args[i]);
		//store i
	}
	args[size] = NULL;//new
	if(size==0){args = NULL;}//for safe

	struct argsandsize* pair = malloc(sizeof(struct argsandsize));
	pair->args = args;
	pair->size = size;
	return pair;
}

int getredind(char* str){
	int redind = 0;
	int cnt = 0;
	for(int i=0; i<strlen(str); i++){
		if(str[i]=='>'){
			if(cnt>0){
				return -1;
			}else{
				redind = i;
			}
			cnt++;
		}
	}
	if(cnt == 0){return 513;}
	return redind;
}

int loop(int interact){
	//printf("loop\n");
	struct job* jobhead = NULL;
	struct job* jobend = NULL;
	//int infilenum = fileno(fdopen(STDIN_FILENO, "r"));//
	//int outfilenum = fileno(fdopen(STDOUT_FILENO, "w"));//
	int stdout_cpy = dup(STDOUT_FILENO);
	//int tempfile;
	int jid = 0;

	//int* status = malloc(sizeof(int));//?
	//int counter = 0;
	while(1){
		//reset to stdin
		//dup2(infilenum, STDIN_FILENO);//
		//dup2(outfilenum, STDOUT_FILENO);
		dup2(stdout_cpy, STDOUT_FILENO);
		//close(STDOUT_FILENO);
		char line[512];
		//char* line = malloc(512*sizeof(char));
		//counter++;
		//printf("how about printf\n");
		if(interact){
			write(STDOUT_FILENO, "mysh> ", 6*sizeof(char));
		}
        if(fgets(line, 512, stdin)==NULL){
			//printf("finish-%i\n",counter);
			//exit(0);
			break;
		}//why doesnt work
		//fgets(line, 512, stdin);
		//printf("  ca\n");
		//echo
		if(!interact){
			//write(1, "check\n", 6);
			write(STDOUT_FILENO, line, strlen(line));
			//write(1, "endcheck\n", 9);
		}//
		//strtok >
		int redind = getredind(line);
		//printf("  cb\n");
		if(redind==-1){
			continue;
		}else if(redind!=513){
			//printf("  cc\n");
			char* leftstr = malloc((strlen(line)-redind-1)*sizeof(char));//need malloc?
			char* cpline = malloc(strlen(line)*sizeof(char));
			strcpy(cpline, line);
			strtok(cpline, "\n");
			if(strtok_r(line, ">", &leftstr)!=NULL){

				//check
				//printf("  cpline: %s\n",line);
				//printf("  leftstr: %s\n",leftstr);

				struct argsandsize* tempair = getargs(leftstr);
				//printf("  cd\n");
				if(tempair==NULL||tempair->size != 1){continue;}
				//FILE* file = fopen(tempair->args[0], "w");
				int file = open(tempair->args[0], O_RDWR|O_CREAT|O_TRUNC, 0666);
				//printf("  tempair->args[0]: %s\n", tempair->args[0]);

				//printf("  ce\n");
				//close(STDOUT_FILENO);//trying
				dup2(file, STDOUT_FILENO);//consider about NULL case
				//printf("  cf\n");
				//dup2(fileno(file), STDOUT_FILENO);//?
				ftruncate(STDOUT_FILENO, 0);//set file size to 0
				//printf("  cg\n");
				
			}else{

				//printf("  test\n");
				
				strcpy(line, cpline);

				//printf("  line after: %s\n", line);
			}
		}
		
		

		char linecpy[strlen(line)];
		strcpy(linecpy, line);

		if(strlen(linecpy)>1){
			strtok(linecpy, "\n");
		}

		//printf("strlen(linecpy): %li\n", strlen(linecpy));
		//printf("linecpy: %s\n", linecpy);
		//printf("linecpy[strlen(linecpy)-1]: %c\n", linecpy[strlen(linecpy)-1]);
		//check & 10/2 9:20
		int background = 0;
		if(linecpy[strlen(linecpy)-1] == '&'){
			//whether is one args or last whole  arg
			//char* cpline = malloc(strlen(linecpy)*sizeof(char));
			background = 1;
			strtok(linecpy, "&");
		}

		//try clean line
		//for(int i=0;i<512;i++){line[i]=EOF;}


		struct argsandsize* pair = getargs(linecpy);//this change line
		//printf("  cb\n");
		char** args = pair->args;
		//printf("  cc\n");
		int sizeofargs = pair->size;

		/*if(sizeofargs>1 && strcmp(args[sizeofargs-2], ">") == 0){//redirection
            FILE* file = fopen(args[sizeofargs-1], "w");

            dup2(fileno(file), STDOUT_FILENO);//consider about NULL case
			//dup2(fileno(file), STDERR_FILENO);//?
            ftruncate(STDOUT_FILENO, 0);//set file size to 0
		}*/


        //check
        /*printf("line: %s\n", line);
		printf("linecpy: %s\n", linecpy);
        for(int i=0;i<sizeofargs;i++){
        	printf("args[%i]: \"%s\"\n", i, args[i]);
        }
		printf("sizeofargs: %i\n", sizeofargs);*/

		
		//when user type Ctrl-D
		if(sizeofargs == 1 && strcmp(args[0], "Ctrl-D")==0)
		//corner case
        if((sizeofargs == 1 && args[0][strlen(args[0]-1)] == '&')||sizeofargs == 0){continue;}

		if(sizeofargs == 1&&strcmp(args[0],"\n")==0){continue;}//args == NULL before
		
		if(strcmp(args[0], "exit")==0 && (sizeofargs == 1 || (sizeofargs == 2 && strcmp(args[1], "&") == 0))) {
			//write(1, "exiting with 1\n", 20);
			exit(0);
		}else if(sizeofargs == 1 && strcmp(args[0], "jobs") == 0) {
			printjobs(jobhead);
		}else if(strcmp(args[0], "wait") == 0) {
			if(jobhead!=NULL){
				struct job* thejob = jidtopid(jobhead, atoi(args[1]));
				if(sizeofargs == 2 && thejob!=NULL){
					//int *status = thejob->status;
                    int status = 0;
					waitpid(thejob->pid, &status, -1);//was NULL or WNOHANG
					//waitpid(thejob->pid, &status, 0);//?
					//if(WIFEXITED(status)||WIFSIGNALED(status)||WCOREDUMP(status)||WIFSTOPPED(status)){//if job terminated
					if(WIFEXITED(status)){
						write(STDERR_FILENO, "JID ", 4);//repeated
						write(STDERR_FILENO, args[1], sizeof(args[1]));
						write(STDERR_FILENO, " terminated", 11);
					}else if(waitpid(thejob->pid, NULL, 0)==-1){//?
						write(STDERR_FILENO, "Invalid JID\n", 12);
					}else{
						write(STDERR_FILENO, "JID ", 4);
						write(STDERR_FILENO, args[1], sizeof(args[1]));
						write(STDERR_FILENO, " terminated\n", 11);
					}
				}
			}else{
				write(STDERR_FILENO, "Invalid JID\n", 12);
				write(STDERR_FILENO, args[1], sizeof(args[1]));//?
			}
			
		}else{

			//printf("  c2\n");

			//the last char of command is & -> put child in background
			
			int cpid = fork();
			if(cpid == -1){// fail
				//printf("    c2-a\n");
			}else if(cpid == 0) {// child

				//printf("    c2-b\n");
				/*printf("  before execvp\n");
				for(int i=0;i<sizeofargs;i++){
					printf("  args[%i]: \"%s\"\n", i, args[i]);
				}
				printf("  sizeofargs: %i\n", sizeofargs);*/
				if(execvp(args[0], args) == -1) {
					write(STDERR_FILENO, args[0], strlen(args[0])*sizeof(char));
					write(STDERR_FILENO, ": Command not found\n", 20*sizeof(char));
					//exit(0);//
					//_Exit(3);
				}
				//printf("status: %i\n", *status);
				
				//exit(0);//
				_Exit(3);
			}else if(args != NULL){// parent

				//printf("    c2-c\n");
				//need to change this later*args[sizeofargs][strlen(args[sizeofargs])-1]
				//if(strcmp(args[sizeofargs-1], "&") == 0){//put child in background
				if(background == 1){
					//args[sizeofargs-1] = NULL; comment 10/2 9:23
					char** args1 = malloc((sizeofargs+1)*sizeof(char*));//add NULL in the end
                	for(int i=0; i<sizeofargs; i++){
						args1[i] = args[i];
					}
					args1[sizeofargs] = NULL;
					args = args1;
					sizeofargs++;//seems this part doesnt affect anything


					//initialize job
					struct job* cjob = malloc(sizeof(struct job));//no need to malloc for status?
                	cjob->jid = jid;
					cjob->pid = cpid;
					cjob->args = args;
                	cjob->size = sizeofargs;
					//cjob->status = status;//---
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
					//waitpid(cpid, cjob->status, WNOHANG);//set status pointer, need to put in child?

					//printf("    c2-d\n");

                }else{//child in foreground
					waitpid(cpid, NULL, 0);
				}
			}
		}
		jid++;
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
			write(STDERR_FILENO, "\n", 1);
			exit(1);
		}
    	dup2(fileno(file), STDIN_FILENO);
		//ftruncate(STDIN_FILENO, 0);
		return(loop(0));//0 for batch
    }else{
        write(STDERR_FILENO, "Usage: mysh [batchFile]\n", 24);
		exit(1);
    }
    return 0;
}
