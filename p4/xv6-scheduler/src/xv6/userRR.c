#include "types.h"
//#include "stat.h"
#include "user.h"
#include "pstat.h"
//#include "proc.h"

int main(int argc, char** argv) {
    int timeslice = 0;
    int iterations = 0;
    char* job;
    int jobcnt = 0;
    
//		printf(0, "-> welcome to userRR.c: PID = %d\n", getpid());

		if(argc != 5) {
        exit();
    }
    timeslice = atoi(argv[1]);
    iterations = atoi(argv[2]);
    job = argv[3];
    jobcnt = atoi(argv[4]);
    int jobs[jobcnt];

		/*printf(0, "  RR[%d]: timeslice = %d\n", getpid(), timeslice);
		printf(0, "  RR[%d]: iterations = %d\n", getpid(), iterations);
		printf(0, "  RR[%d]: job = %s\n", getpid(), job);
		printf(0, "  RR[%d]: jobcnt = %d\n", getpid(), jobcnt);*/

    // initialize each proc
    for(int i = 0; i < jobcnt; i++) {
  //      printf(0, "RR[%d]: fork job %d\n", getpid(), i);
        int retpid = fork2(0);
        if(retpid == 0) {
						char* argn = "0";            
						exec(job, &argn);
						//printf(0, "  RR[%d]: A LOOP IS OVER! HOW CAN THIS BE POSSIBLE?\n", getpid());
        } else {
						//printf(0, "  RR[%d]: adding job %d\n", getpid(), i);
            jobs[i] = retpid;
    		}
    }
		
		//printf(0, "  RR[%d]: start running proc\n", getpid());

    for(int i = 0; i < iterations; i++) { 
        // for each iteration, pick a proc to execute and put it back
		//		printf(0, "RR[%d]: %dth iteration:\n", getpid(), i);
				for(int j = 0; j < jobcnt; j++) {
			//			printf(0, "RR[%d]: call setpri(jobs[%d] (pid = %d), 2)\n", getpid(), j, jobs[j]);
            setpri(jobs[j], 2);
        //    printf(0, "setpri return %d\n", retv);
            sleep(timeslice);
          //  printf(0, "RR[%d]: call setpri(jobs[%d] (pid = %d), 0)\n", getpid(), j, jobs[j]);
						setpri(jobs[j], 0);
            //printf(0, "RR[%d]: setpri return %d\n", retv);
						// kill jobs after the last iteration
						if(i == iterations - 1) {
							//printf(0, "  RR[%d]: killing job %d\n", getpid(), j);
							kill(jobs[j]);
						}
        }
    }

		//printf(0, "  RR[%d]: printing pstat\n", getpid());
		
    // print out pstat
    struct pstat pstates;
		// how to lock in user level?
    getpinfo(&pstates);
    for(int i = 0; i < NPROC; i++) {
				if(pstates.inuse[i] != 1)
					continue;
        printf(0, ">> %d's proc in ptable\n", i);
        printf(0, " inuse: %d \n", pstates.inuse[i]);
        printf(0, " pid: %d \n", pstates.pid[i]);
				printf(0, " priority: %d \n", pstates.priority[i]);
        printf(0, " state: %d \n", pstates.state[i]);
        for(int j = 0; j < 4; j++) {
            printf(0, " ticks of lvl %d: %d \n", j, pstates.ticks[i][j]);
        }
				for(int j = 0; j < 4; j++) {
						printf(0, " qtail of lvl %d: %d \n", j, pstates.qtail[i][j]);
				}
    }

    exit();
}
