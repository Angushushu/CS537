// Copyright 2019 Shu Hu
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

int main(int argc, char** argv) {
    if (argc != 3) {
        printf("my-diff: invalid number of arguments\n");
        exit(1);
    }
    FILE* file1 = fopen(argv[1], "r");
    FILE* file2 = fopen(argv[2], "r");
    if (file1 == NULL || file2 == NULL) {
        printf("my-diff: cannot open file\n");
        exit(1);
    }
    size_t size = 1024;
    char* line1 = malloc(size*sizeof(char));
    char* line2 = malloc(size*sizeof(char));
    int line = 0;
    int need_print_line = 1;
    int get1 = getline(&line1, &size, file1);
    int get2 = getline(&line2, &size, file2);
    while (get1 != -1 || get2 != -1) {
        line++;
        if (get1 == -1 || get2 == -1 || strcmp(line1, line2) != 0) {
            if (need_print_line == 1) {
                printf("%i\n", line);
                need_print_line = 0;
            }
            if (get1 == -1) {
                printf("> %s", line2);
            } else if (get2 == -1) {
                printf("< %s", line1);
        } else {
                printf("< %s", line1);
                printf("> %s", line2);
            }
        } else {
            need_print_line = 1;
        }
        get1 = getline(&line1, &size, file1);
        get2 = getline(&line2, &size, file2);
    }
    free(line1);
    free(line2);
    fclose(file1);
    fclose(file2);
    exit(0);
}
