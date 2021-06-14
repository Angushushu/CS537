#include <stdlib.h>
#include <stdio.h>
#include <time.h>

int main()
{
	//struct timespec init, start, end;
	/*clock_gettime(CLOCK_MONOTONIC_RAW, &init);
	while (1) {
		//do stuff
		clock_gettime(CLOCK_MONOTONIC_RAW, &end);
		printf(".\n");
		unsigned int delta_es = (end.tv_sec - init.tv_sec) * 1000000 + (end.tv_nsec - init.tv_nsec) / 1000;
		if (delta_es >= 120000000) {
			break ;
		}
	}
	return 0;*/
	int main(void) {
   time_t start, end;
   double elapsed;  // seconds
   start = time(NULL);
   int terminate = 1;
   while (terminate) {
     end = time(NULL);
     elapsed = difftime(end, start);
     if (elapsed >= 90.0 /* seconds */)
       terminate = 0;
     else  // No need to sleep when 90.0 seconds elapsed.
       usleep(50000);
   }
   printf("done..\n");
   return 0;
 }
}
