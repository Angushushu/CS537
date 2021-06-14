// "Copyright 2019 Shu Hu
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char **argv) {
    char *substr = NULL;
    int ind = 0;
    int len = 0;
    char *dir = "/usr/share/dict/words";
    FILE *file = NULL;
    char line[256];
    if (argc == 4 || argc == 5) {
        substr = argv[1];
        ind = atoi(argv[2]);
        len = atoi(argv[3]);
        if (argc == 5)
            dir = argv[4];
    } else {
        printf("across: invalid number of arguments\n");
        exit(1);
    }

    if ((len - ind) < strlen(substr) || ind < 0) {
        printf("across: invalid position\n");
        exit(1);
    }

    file = fopen(dir, "r");
    if (file == NULL) {
        printf("across: cannot open file\n");
        exit(1);
    }

    while (fgets(line, 256* sizeof(char), file) != NULL) {
        int cont = 0;
        if ((strlen(line) - 1) != len) {
            continue;
        }
        for (int i = 0; i < len; i++) {
            if ('a' > line[i] || 'z' < line[i]) {
                cont = 1;
                break;
            }
        }
        if (cont == 1) {
            continue;
        }
        if (strncmp(substr, &(line[ind]), strlen(substr)) == 0) {
            printf("%s", line);
        }
    }
    fclose(file);
    exit(0);
}
