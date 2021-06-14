// Copyright 2019 Shu Hu
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <ctype.h>

int main(int argc, char **argv) {
    char *str = NULL;
    char line[256];
    for (int i = 0; i < 256; i++) {
        line[i] = '\0';
    }
    size_t len_str = 0;
    FILE * file = NULL;
    char *fdir = "/usr/share/dict/words";
    if (argc == 2) {
        str = argv[1];
    } else if (argc == 3) {
        str = argv[1];
        fdir = argv[2];
    } else {
        printf("my-look: invalid number of arguments\n");
        exit(1);
    }

    len_str = strlen(str);
    char *lower_str = malloc(len_str* sizeof(char));
    for (int i = 0; i < len_str; i++) {
        lower_str[i] = tolower(str[i]);
    }

    file = fopen(fdir, "r");
    if (file == NULL) {
        printf("my-look: cannot open file\n");
        exit(1);
    }

    while (fgets(line, 256* sizeof(char), file) != NULL) {
        char *substr = malloc(len_str* sizeof(char));
        for (int i = 0; i < len_str; i++) {
            substr[i] = tolower(line[i]);
        }

        if (strcmp(lower_str, substr) == 0) {
            printf("%s", line);
        }
        free(substr);
    }
    free(lower_str);
    fclose(file);
    exit(0);
}
