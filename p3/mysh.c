#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/wait.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>


void* mem[8];  // malloc

struct job {
  struct job* pre;
  struct job* next;
  int jid;
  pid_t pid;
  char** args;
    int size;
};

struct argsandsize {
  char** args;
  int size;
};


void freemem(){
  for(int i = 0; i < 8; i++) {
    if(mem[i] != NULL) {
      printf("free\n");
      free(mem[i]);
    }
  }
}

void printjobs(struct job* jobhead) {
  struct job* currentjob = jobhead;
  while (currentjob != NULL) {
    int status;
    waitpid(currentjob->pid, &status, WNOHANG);
    if (!(WIFEXITED(status))) {
      char buff[20];
      sprintf(buff, "%d", currentjob->jid);
      write(1, buff, strlen(buff));
      write(1, " : ", 3);
      if (currentjob->size == 1) {
        write(STDOUT_FILENO, currentjob->args[0], strlen(currentjob->args[0]));
      } else {
        for (int i = 0; i < currentjob->size - 1; i++) {
          int tempsl = strlen(currentjob->args[i]);
          write(STDOUT_FILENO, currentjob->args[i], tempsl);
          if (i < currentjob->size-2) {
            write(STDOUT_FILENO, " ", 1);
          } else {
            write(STDOUT_FILENO, "\n", 1);
          }
        }
      }
    }
    currentjob = currentjob->next;
  }
}

struct job* getjob(struct job* jobhead, int jid) {
    struct job* currentjob = jobhead;
    while (currentjob->next != NULL) {
        if (currentjob->jid == jid) {
            return currentjob;
        }
    currentjob = currentjob->next;
    }
  if (currentjob->jid == jid) {
        return currentjob;
    }
    return NULL;
}

struct argsandsize* getargs(char* line) {
  char* linecpy = malloc(strlen(line)*sizeof(char));
  printf("malloc\n");
  mem[0] = linecpy;
  strcpy(linecpy, line);
  int size = 1;
  char* tok = strtok(line, " ");
  if (tok == NULL) {
    return NULL;
  }
  while ((tok = strtok(NULL, " ")) != NULL) {size++;}
  char** args = malloc((size+1)*sizeof(char*));
  mem[1] = args;
  args[0] = strtok(linecpy, " ");
  for (int i = 1; i < size; i++) {
    args[i] = strtok(NULL, " ");
  }
  args[size] = NULL;
  if (size == 0) {args = NULL;}
  struct argsandsize* pair = malloc(sizeof(struct argsandsize));
  mem[2] = pair;
  pair->args = args;
  pair->size = size;
  return pair;
}

int getredind(char* str) {
  int redind = 0;
  int cnt = 0;
  for (int i = 0; i < strlen(str); i++) {
    if (str[i] == '>') {
      if (cnt > 0) {
        return -1;
      } else {
        redind = i;
      }
      cnt++;
    }
  }
  if (cnt == 0) {return 513;}
  return redind;
}

int loop(int interact) {

  struct job* jobhead = NULL;
  struct job* jobend = NULL;
  int stdout_cpy = dup(STDOUT_FILENO);
  int stderr_cpy = dup(STDERR_FILENO);
  int jid = 0;

  while (1) {
    freemem();  // mem
    for(int i = 0; i < 8; i++){
      mem[i] = NULL;
    }
    dup2(stdout_cpy, STDOUT_FILENO);
    dup2(stderr_cpy, STDERR_FILENO);
    char* line = malloc(512*sizeof(char));
    printf("malloc\n");
    mem[3] = line;  // mem
    if (interact) {
      write(STDOUT_FILENO, "mysh> ", 6*sizeof(char));
    }
        if (fgets(line, 512, stdin) == NULL) {
      break;
    }
    if (!interact) {
      write(STDOUT_FILENO, line, strlen(line));
    }
    if (strlen(line) > 0 && line[strlen(line) - 1] != '\n') {
      freemem();  // mem
      continue;
    }
    if (strlen(line) > 1 && line[strlen(line) - 1] == '\n') {
      strtok(line, "\n");
    }
    if (line == NULL || strlen(line) == 0) {
      freemem();  // mem
      continue;
    }

    int redind = getredind(line);
    if (redind == -1) {
      freemem();  // mem
      continue;
    } else if (redind != 513) {
      char* rightstr = malloc((strlen(line) - redind - 1)*sizeof(char));
      printf("malloc\n");
      char* cpline = malloc(strlen(line)*sizeof(char));
      printf("malloc\n");
      mem[4] = rightstr;
      mem[5] = cpline;
      strcpy(cpline, line);
      if (strtok_r(cpline, ">", &rightstr) != NULL) {
        struct argsandsize* tempair = getargs(rightstr);
        if (tempair == NULL || tempair->size != 1) {
          freemem();  // mem
          continue;
        }
        int file = open(tempair->args[0], O_RDWR|O_CREAT|O_TRUNC, 0666);
        if (file < 0) {
          freemem();  // mem
          continue;
        }
        dup2(file, STDOUT_FILENO);
        dup2(file, STDERR_FILENO);
        line = cpline;
      }
    }
    char* linecpy = malloc(strlen(line)*sizeof(char));
    printf("malloc\n");
    mem[6] = linecpy;
    strcpy(linecpy, line);
    if (strlen(linecpy) > 1 && linecpy[strlen(linecpy) - 1] == '\n') {
      strtok(linecpy, "\n");
    }

    int background = 0;
    if (linecpy[strlen(linecpy)-1] == '&') {
      if (strlen(linecpy) == 1) {
        freemem();  // mem
        continue;
      }
      background = 1;
      strtok(linecpy, "&");
    }
    struct argsandsize* pair = getargs(linecpy);
    if (pair == NULL) {
      freemem();  // mem
      continue;
    }
    char** args = pair->args;
    int sizeofargs = pair->size;
    // if (sizeofargs == 1 && strcmp(args[0], "Ctrl-D") == 0)
    // corner case
    int tempa = (sizeofargs == 1);
    int tempb = (args[0][strlen(args[0]-1)] == '&');
    if ((tempa && tempb) || sizeofargs == 0) {
      freemem();  // mem
      continue;
    }
    if (sizeofargs == 1 && strcmp(args[0], "\n") == 0) {
      freemem();  // mem
      continue;
    }
    int tempc = sizeofargs == 2 && strcmp(args[1], "&") == 0;
    int tempd = sizeofargs == 1 || tempc;
    if (strcmp(args[0], "exit") == 0 && tempd) {
      freemem();  // mem
      exit(0);
    } else if (sizeofargs == 1 && strcmp(args[0], "jobs") == 0) {
      printjobs(jobhead);
      freemem();  // mem
      continue;  // jid dont +
    } else if (strcmp(args[0], "wait") == 0) {
      if (jobhead != NULL) {
        struct job* thejob = getjob(jobhead, atoi(args[1]));
        if (sizeofargs == 2 && thejob != NULL) {
                    int status = 0;
          if (waitpid(thejob->pid, &status, 0) == -1) {
            write(STDERR_FILENO, "Invalid JID\n", 12);
          } else {
            write(STDOUT_FILENO, "JID ", 4);
            write(STDOUT_FILENO, args[1], strlen(args[1]));
            write(STDOUT_FILENO, " terminated\n", 12);
          }
        }
      } else {
        write(STDERR_FILENO, "Invalid JID ", 12);
        write(STDERR_FILENO, args[1], strlen(args[1]));
        write(STDERR_FILENO, "\n", 1);
      }
      freemem();  // mem
      continue;
    } else {
      if (background == 1) {
        char** args1 = malloc((sizeofargs + 1)*sizeof(char*));
        printf("malloc\n");
        mem[7] = args1;
        // add NULL in the end
        for (int i = 0; i < sizeofargs; i++) {
          args1[i] = args[i];
        }
        args1[sizeofargs] = NULL;
        args = args1;
        sizeofargs++;  // seems this part doesnt affect anything
      }

      int cpid = fork();
      if (cpid == -1) {
        write(STDERR_FILENO, "fork failed\n", 12);
      } else if (cpid == 0) {
        if (execvp(args[0], args) == -1) {
          write(STDERR_FILENO, args[0], strlen(args[0])*sizeof(char));
          write(STDERR_FILENO, ": Command not found\n", 20*sizeof(char));
        }
        freemem();  // mem
        _Exit(3);
      } else if (args != NULL) {  // parent
        if (background == 1) {
          struct job* cjob = malloc(sizeof(struct job));
          printf("malloc\n");
          mem[8] = cjob;
          cjob->jid = jid;
          cjob->pid = cpid;
          cjob->args = args;
          cjob->size = sizeofargs;
          if (jobend == NULL) {
            jobhead = cjob;
          } else {
            jobend->next = cjob;
          }
          cjob->next = NULL;
        } else {  // child in foreground
          waitpid(cpid, NULL, 0);
        }
      }
    }
    jid++;
  }
  freemem();  // mem
  return 0;
}
int main(int argc, char** argv) {
    if (argc == 1) {
        return(loop(1));  // 1 for interactive
    } else if (argc == 2) {
    FILE* file = fopen(argv[1], "r");
    if (file == NULL) {
      write(STDERR_FILENO, "Error: Cannot open file ", 24);
      write(STDERR_FILENO, argv[1], strlen(argv[1]));
      write(STDERR_FILENO, "\n", 1);
      freemem();  // mem
      exit(1);
    }
  dup2(fileno(file), STDIN_FILENO);
    return(loop(0));  // 0 for batch
    } else {
        write(STDERR_FILENO, "Usage: mysh [batchFile]\n", 24);
        freemem();  // mem
        exit(1);
    }
    return 0;
}
