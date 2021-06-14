#include "types.h"
#include "stat.h"
#include "user.h"

int main(int argc, char** argv) {
    if(fork() == 0) {
        char* c1 = malloc(5*sizeof(char));
        c1 = "01";
        printf(1, "child 1: %s\n", c1);
        exit();
    }
    wait();
    if(fork() == 0) {
        char* c2 = malloc(5*sizeof(char));
        c2 = "02";
        printf(1, "child 2: %s\n", c2);
        exit();
    }
    wait();

    int numframes = 100;
    int frames[numframes];
    int pids[numframes];
    dump_physmem(frames, pids, numframes);
    for(int i = 0; i < numframes; i++) {
        printf(1, "frames[%d] = %x; pids[%d] = %d\n", i, frames[i], i, pids[i]);
    }
    printf(1, "hi before return\n");
    exit();
}
