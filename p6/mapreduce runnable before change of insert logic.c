#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sys/stat.h>
#include <semaphore.h>
#include "mapreduce.h"

// The hashmap(table) used as partitions
struct table* hashmap3D;
// global variable partitioner
Partitioner partition_func;

// linked list for mapping
struct Node {
    char* file_name;
    struct Node* next;
};

struct queue{
    struct Node* head;
    pthread_mutex_t lock;// = PTHREAD_MUTEX_INITIALIZER;
} Q;

char* pick() {
    printf("pick\n");
    pthread_mutex_lock(&Q.lock);
    struct Node* n = Q.head;
    if(n == NULL) {
        pthread_mutex_unlock(&Q.lock);
        return NULL;
    } else {
        Q.head = Q.head->next;
        pthread_mutex_unlock(&Q.lock);
        return n->file_name;
    }
}

// newest 3D data structure of partitions & reducing
struct valNode {
    char* val;
    //int reduced; // initialized to 0, for get_next()
    struct valNode *next;
};
struct keyNode {
    char* key;
    int reduced;
    struct keyNode *next;
    struct valNode *val_list;
    int partition;
    pthread_mutex_t lock;
};
struct table {
    int size;
    struct keyNode **list;
    int *reduced; // for pick_partition
    pthread_mutex_t *lock;
};

struct table* createTable(int size) {
    printf("createTable\n");
    struct table *t = (struct table*)malloc(sizeof(struct table));
    //printf("test\n");
    t->size = size;
    //printf(" size = %i\n", size);
    t->list = (struct keyNode**)malloc(sizeof(struct keyNode*)*size);
    t->reduced = (int*)malloc(sizeof(int)*size);
    t->lock = (pthread_mutex_t*)malloc(sizeof(pthread_mutex_t)*size);  // using lock[] only have mem on stack, will be removed after function finish
    for(int i = 0; i < size; i++) {
        t->list[i] = NULL;
        pthread_mutex_init(&t->lock[i], NULL);
        //int r = pthread_mutex_init(&t->lock[i], NULL);
        //printf(" r = %i\n", r);
        //printf(" t->lock[%i] initialized\n", i);
        //t->lock[i] = PTHREAD_MUTEX_INITIALIZER;
    }
    return t;
}
void insert(struct table* t, char* key, char* val, Partitioner partitioner) { // how to pass method
    printf("insert\n");
    int p_num = partitioner(key, t->size);
    printf(" adding (%s, %s) to hashmap3D[%i]\n", key, val, p_num);
    struct keyNode* list = t->list[p_num];
    pthread_mutex_lock(&t->lock[p_num]);
    //printf(" t->lock[%i] acquired\n", p_num);
    if(list == NULL) {  // if no key yet, add keyNode
        // test
        printf(" 86\n");
        //
        struct keyNode* new_keyNode = (struct keyNode*)malloc(sizeof(struct keyNode));
        //new_keyNode->key = key;
        new_keyNode->key = malloc(sizeof(key));
        strcpy(new_keyNode->key, key); // must use strcpy, but when to alloc mem?
        printf("everything ok?\n");
        new_keyNode->partition = p_num;
        pthread_mutex_init(&new_keyNode->lock, NULL);
        t->list[p_num] = new_keyNode;
        // add valNode to the key
        struct valNode* new_valNode = (struct valNode*)malloc(sizeof(struct valNode));
        new_valNode->val = val;
        t->list[p_num]->val_list = new_valNode;
        // test
        printf(" t->list[%i] : key = %s, partition = %i\n", p_num, t->list[p_num]->key, t->list[p_num]->partition);
        printf(" t->list[%i] : 1st_val = %s\n", p_num, t->list[p_num]->val_list->val);
        printf(" added key %s to partition %i\n", new_keyNode->key, p_num);
        printf(" hashmap3D->list[0]->key = %s\n", hashmap3D->list[0]->key);
        //
        //printf("no seg fault in NULL\n");
    } else {
        // find the keyNode
        printf(" 100\n");
        struct keyNode* tmp = list;
        // create new valNode will be added
        struct valNode* new_valNode = (struct valNode*)malloc(sizeof(struct valNode));
        new_valNode->val = val;
        // forgot to consider the case tmp is the first one
        if(strcmp(key, tmp->key) == 0) { // the first one has the same key, break
            printf(" first key is the same , add val\n");
            struct valNode* vtmp = tmp->val_list;  // for sure the val_list is not empty (since val added when keyNode created)
            // add valNode to the val_list and don't need to care about repeat
            new_valNode->next = vtmp;
            tmp->val_list = new_valNode;
        } else if(strcmp(key, tmp->key) < 0) { // the first one has larger key
            printf(" first key is larger than this\n");
            struct keyNode* new_keyNode = (struct keyNode*)malloc(sizeof(struct keyNode));  // create a new keyNode
            //new_keyNode->key = key;
            new_keyNode->key = malloc(sizeof(key));
            strcpy(new_keyNode->key, key);
            new_keyNode->partition = p_num;
            pthread_mutex_init(&new_keyNode->lock, NULL);
            new_keyNode->next = tmp;
            t->list[p_num] = new_keyNode;
            new_keyNode->val_list = new_valNode;
            printf(" added key %s to partition %i\n", new_keyNode->key, p_num);
        } else {
            printf(" looking for the position to put this\n");
            while(tmp->next != NULL && strcmp(key, tmp->next->key) > 0) // while key > tmp->next->key, keep going
                tmp = tmp->next;
            if(tmp->next == NULL || strcmp(key, tmp->next->key) < 0) {  // if the key doesn't exist yet, add it
                printf(" add this new key\n");
                struct keyNode* new_keyNode = (struct keyNode*)malloc(sizeof(struct keyNode));  // create a new keyNode
                //new_keyNode->key = key;
                new_keyNode->key = malloc(sizeof(key));
                strcpy(new_keyNode->key, key);
                new_keyNode->partition = p_num;
                pthread_mutex_init(&new_keyNode->lock, NULL);
                //new_keyNode->lock = PTHREAD_MUTEX_INITIALIZER;
                tmp->next = new_keyNode;
                new_keyNode->val_list = new_valNode;  // add valNode to the val_list
                printf(" added key %s to partition %i\n", new_keyNode->key, p_num);
            } else if(strcmp(key, tmp->next->key) == 0) {  // if the key already exist, add the valNode
                struct valNode* vtmp = tmp->next->val_list;  // for sure the val_list is not empty (since val added when keyNode created)
                // add valNode to the val_list and don't need to care about repeat
                new_valNode->next = vtmp;
                tmp->next->val_list = new_valNode;
            }
        }
        
    }
    pthread_mutex_unlock(&t->lock[p_num]);
}
int pick_partition(struct table* t) { // pick the next partition for reducing
    printf("pick_partition\n");
    for(int i = 0; i < t->size; i++) {
        printf(" i = %i\n", i);
        //struct keyNode* tmp = t->list[i];
        //pthread_mutex_lock(&tmp->lock);
        pthread_mutex_lock(&t->lock[i]);
        //if(tmp->reduced == 0) { // partition should has reduced
        if(t->reduced[i] == 0) {
            //tmp->reduced = 1;
            t->reduced[i] = 1;
            //pthread_mutex_unlock(&tmp->lock);
            pthread_mutex_unlock(&t->lock[i]);
            return i;
        }
        //pthread_mutex_unlock(&tmp->lock);
        pthread_mutex_unlock(&t->lock[i]);
    }
    return -1;
}
// hashmap finish here

// call the real getter
char* get_next(char *key, int partition_number) {
    printf("get_next\n");
    struct keyNode* list = hashmap3D->list[partition_number]; // get the partition
    struct keyNode* tmp = list;
    while(tmp) {
        if(tmp->key == key && !tmp->reduced) { // get to the key
            pthread_mutex_lock(&tmp->lock);
            struct valNode* vtmp = tmp->val_list; // pop the first one in the keyNode's val_list
            if(vtmp != NULL) {
                tmp->val_list = vtmp->next; // how to free? add to an array?
                char* ret_val = vtmp->val;
                free(vtmp);
                pthread_mutex_unlock(&tmp->lock);
                return ret_val;
            } else {
                pthread_mutex_unlock(&tmp->lock);
                return NULL;
            }
        }
        tmp = tmp->next;
    }
    return NULL;    
}

void MR_Emit(char *key, char *value) {
    printf("MR_Emit\n");
    insert(hashmap3D, key, value, partition_func); // add to partition
}

void* map_iterate(void * arg) { // can I pass map() like this?
    printf("map_iterate\n");
    Mapper map = arg;
    char* f;
    while(1) {
        f = pick();
        if(f == NULL)
            break;
        map(f);
    }
    printf(" hashmap3D->list[0]->key = %s\n", hashmap3D->list[0]->key);
    return NULL; // ?
    //exit(0);
}

void* reduce_thread(void * arg) {
    printf("reduce_thread\n");
    Reducer reduce = arg;
    int p = -1;
    //struct keyNode* head;
    while((p = pick_partition(hashmap3D)) != -1) {
        printf(" while in reduce_thread()\n");
        printf(" hashmap3D->list[p = %i]->key = %s\n", p, hashmap3D->list[p]->key);
        struct keyNode* tmp = hashmap3D->list[p];
        while(tmp != NULL) {
            char* key = tmp->key;
            printf(" key = %s\n", key);
            //int partition_number = tmp->partition;
            printf(" calling reduce()\n");
            //reduce(key, get_next, partition_number);
            reduce(key, get_next, p);
            tmp = tmp->next;
        }
    }
    return NULL; // ?
    //exit(0);
}

void MR_Run(int argc, char *argv[],
            Mapper map, int num_mappers,
            Reducer reduce, int num_reducers,
            Partitioner partition, int num_partitions) {
    printf("MR_Run\n");
    // not sure: build num_partitions partitions via creating hashmap w/ num_partitions linkedlist?
    hashmap3D = createTable(num_partitions);
    partition_func = partition;
    pthread_mutex_init(&Q.lock, NULL); // lock init
    // add file names to Q
    for(int i = 1; i < argc; i++) {
        struct Node tmp;
        tmp.file_name = argv[i];
        tmp.next = Q.head;
        Q.head = &tmp;
    }
    // run mapper threads
    pthread_t threads_m[num_mappers];
    for(int i = 0; i < num_mappers; i++)
        pthread_create(&threads_m[i], NULL, map_iterate, map);
    // wait all threads done
    for(int i = 0; i < num_mappers; i++)
        pthread_join(threads_m[i], NULL);

    // run reducer threads
    pthread_t threads_r[num_reducers];
    for(int i = 0; i < num_reducers; i++)
        pthread_create(&threads_r[i], NULL, &reduce_thread, reduce);
    // wait all threads done
    for(int i = 0; i < num_reducers; i++)
        pthread_join(threads_r[i], NULL);
}

unsigned long MR_DefaultHashPartition(char *key, int num_partitions) { // used by hashmap?
    printf("MR_DefaultHashPartition\n");
    unsigned long hash = 5381;
    int c;
    while ((c = *key++) != '\0')
        hash = hash * 33 + c;
    return hash % num_partitions;
}

unsigned long MR_SortedPartition(char *key, int num_partitions) {
    printf("MR_SortedPartition\n");
    unsigned long num = atoi(key); //?
    unsigned long mask = 0x0FFFFFFF;
    num = num & mask;
    int log2 = 0;
    while (num_partitions >>= 1) ++log2;
    num = num >> (32 - log2);
    return num;
}

// remove when submit
//int main(){return 1;}
