#include "stdio.h"
#include "stdlib.h"
#include "string.h"
#include "unistd.h"
#include "sys/wait.h"

struct job {
    struct job* pre;
    char* line;
    int jid;
    struct job* next;
    int status;
    int pid;
};

int getjobpid(struct job* jobc, int jid) {
    while(jobc != NULL) {
        if(jobc->jid == jid) {
	    return jobc->pid;
	}
	jobc = jobc->next;
    }
    return -1;
}

int* getjobstatus(struct job* jobc, int pid) {
    while(jobc != NULL) {
        if(jobc->pid == pid) {
	    return &(jobc->status);
	}
	jobc = jobc->next;
    }
    return NULL;
}

void itoa(int number, char* str) {
   sprintf(str, "%d", number); 
}

void pjobs(struct job* jobc) {
    while(jobc != NULL){
       char* str = malloc(512*sizeof(char));
       itoa(jobc->jid, str);
       int stt = jobc->status;
       if(!(WIFEXITED(stt)||WIFSIGNALED(stt)||WIFSTOPPED(stt))){//means jobc is still running?
           write(1, str, strlen(str));
           write(1, ": ", 3);
           write(1, jobc->line, strlen(jobc->line));
           jobc = jobc->next;
       }
    }
}

char* combstr(char* str1, char* str2) {
    char* comb = malloc(strlen(str1) + strlen(str2) + 1);
    strcpy(comb, str1);
    strcat(comb, str2);
    return comb;
}

void loop(FILE* in) {
    char ln[512];
    int jidcnt = 0;
    struct job* jobh = NULL;
    struct job* jobn = NULL;
    char* args[257];
    while(1) {
	printf("entered the outer loop\n");
        write(1, "mysh> ", 6*sizeof(char));
	fgets(ln, 512, in);
	char* word = strtok(ln, " ");
	char* jobln = malloc(strlen(ln)*sizeof(char));
	int argcnt = 0;
	while(word != NULL) {
	    printf("1\n");
	    if(argcnt != 0) {
		printf("1a\n");
	        word = strtok(NULL, " ");
		if(word != NULL) {jobln = combstr(jobln, " ");}
	    }
	    if(word != NULL) {
		printf("1b\n");
		jobln = combstr(jobln, word);
		args[argcnt] = word;
		argcnt++;
	    }
	    printf("1c\n");
        }
        args[argcnt] = NULL;// make sure the args ends
	printf("args[%i]: %s\n", argcnt, args[argcnt]);
	if(jidcnt == 0){
	    printf("jidcnt == 0:\n");
	    struct job* job0 = malloc(sizeof(struct job));
	    job0->pre = NULL;
	    job0->line = jobln;
	    //strcpy(job0->line, jobln);
            job0->jid = jidcnt;
	    jobh = job0;
	    jobn = job0;
	    printf("finish\n");
	}else{
	    struct job* jobnext = malloc(sizeof(struct job));
	    jobn->next = jobnext;
	    jobnext->pre = jobn;
	    jobnext->next = NULL;
	    jobnext->line = jobln;
	    //strcpy(jobnext->line, jobln);
	    jobnext->jid = jidcnt;
	    jobn = jobnext;
	}
	printf(">> struct created\n");
	printf(">> jobh->line: %s\n", jobh->line);
	// built in commands
	if(strncmp(args[0], "exit", 4) == 0) {
	    exit(0);
	}else if(strncmp(args[0], "jobs", 4) == 0) {
	    pjobs(jobh);
        }else if(strncmp(args[0], "wait", 4) == 0) {
	    if(argcnt > 1){
	        int cjid = atoi(args[1]);
		int cpid = getjobpid(jobh, cjid);
                if(waitpid(cpid, getjobstatus(jobh, cpid), 0) != 0) {//?
                    write(1, "Invalid JID\n", 20);
                }else{
                    if(WIFEXITED(*getjobstatus(jobh, cpid)) != 0){//terminated normally
                        write(1, "JID ", 3);
			char* str = malloc(20*sizeof(char));
		       	itoa(cpid, str);
                        write(1, str, strlen(str));
                        write(1, " terminated", 10);
                    }
                }
	    }
	}
	else{
	    printf(">> received non-built-in command\n");
	    //show all args
	    for(int i=0; i<argcnt; i++){
	        printf("  >> args[%i]: %s\n", i, args[i]);
	    }
	    int thepid = fork();
	    jobn->pid = thepid;
	    if(thepid == 0){//child
		if(execvp(args[0], args) == -1) {
		    printf("  [c] in the child process\n");
	            write(STDERR_FILENO, args[0], strlen(args[0])*sizeof(char));
		    write(STDERR_FILENO, ": Command not found\n", 20*sizeof(char));
		    printf("  [c] child proc exit\n");
	            exit(0);
		}
	    }else{//parent
		printf("  [p] parent continue\n");
		char* str = args[argcnt-1];
		printf("  [p] ...\n");
		printf("  [p] args[argcnt-1]: %s\n", args[argcnt-1]);
		if(str[strlen(str)-1] != '&') {//foreground
		    printf("  [p] parent wait for child\n");
		    printf("  [p] jobn.line: %s\n", jobln);
		    int stt = jobn->status;// segmentation fault!
		    printf("  [p] stt = %d\n", stt);
		    waitpid(thepid, &stt, WNOHANG);
		}//otherwise backgrounds keep running
		printf("  [p] parent going to next loop\n");
	    }
	}
	jidcnt++;
    }
}

int main(int argc, char** argv) {
    if(argc == 1){
        loop(stdin);
    }else if(argc == 2){
    
    }else{
        //error
    }
    return 0;
}
