#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char** argv) {
    printf(0, "-> welcome to loop.c: PID = %d\n", getpid());
		for(;;) {
        sleep(10);
        printf(0, "%d\n", getpid());
    }
    exit();
}
