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
    //printf("pick\n");
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
    struct keyNode *next;
    struct valNode *val_list;
    int partition;
    pthread_mutex_t lock;
};

// to improve the performance, we decided to try ArrayList
struct keyArray {
    int size;
    struct keyNode[100];
};

struct valArray {
    int size;
    struct valNode[100];
};

struct table {
    int size;
    struct keyNode **list;
    int *reduced; // for pick_partition
    pthread_mutex_t *lock;
};

struct table* createTable(int size) {
    //printf("createTable\n");
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
    }
    return t;
}
void insert(struct table* t, char* key, char* val, Partitioner partitioner) { // how to pass method
    //printf("insert\n");
    int p_num = partitioner(key, t->size);
    //printf(" adding (%s, %s) to hashmap3D[%i]\n", key, val, p_num);
    struct keyNode* new_keyNode = (struct keyNode*)malloc(sizeof(struct keyNode));
    struct valNode* new_valNode = (struct valNode*)malloc(sizeof(struct valNode));
    new_valNode->val = val;
    new_keyNode->key = malloc(sizeof(key));
    strcpy(new_keyNode->key, key);
    new_keyNode->partition = p_num;
    pthread_mutex_init(&new_keyNode->lock, NULL);
    new_keyNode->val_list = new_valNode;
    pthread_mutex_lock(&t->lock[p_num]);
    // new logic
    if(t->list[p_num] == NULL) {
        //printf(" a\n");
        new_keyNode->val_list = new_valNode;
        t->list[p_num] = new_keyNode;
        //printf(" %s\n", t->list[p_num]->key);
    } else {
        //printf(" b\n");
        struct keyNode* tmp = t->list[p_num];
        while(tmp != NULL) {
            int result = strcmp(key, tmp->key);
            //printf(" strcmp(key, tmp->key) = %i\n", result);
            if(result == 0) {
                //printf(" b-1\n");
                free(new_keyNode->key);
                free(new_keyNode); // don't need it, how can double free happens?
                new_valNode->next = tmp->val_list;
                tmp->val_list = new_valNode;
                //printf(" b-1 done\n");
                break;
            } else if(result > 0) {
                // check tmp->next
                //printf(" b-2\n");
                if(tmp->next == NULL || strcmp(key, tmp->next->key) < 0) {  // the key doesn't exist
                    // add the new node here
                    //printf(" b-2-1\n");
                    new_keyNode->next = tmp->next;
                    tmp->next = new_keyNode;
                    break;
                }
                if(tmp->next != NULL)
                    tmp = tmp->next;
            } else { // key < tmp->key (should only happen at the head)
                //printf(" b-3\n");
                // add new node at the beginning
                new_keyNode->next = tmp;
                t->list[p_num] = new_keyNode;
                break;
            }
        }
        //printf(" %s\n", t->list[p_num]->key);
        //printf(" %s\n", t->list[p_num]->next->key); // NULL?
    }
    // new logic ends here
    pthread_mutex_unlock(&t->lock[p_num]);
}
int pick_partition(struct table* t) { // pick the next partition for reducing
    // printf("pick_partition\n");
    for(int i = 0; i < t->size; i++) {
        // printf(" i = %i\n", i);
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
    // printf("get_next\n");
    struct keyNode* list = hashmap3D->list[partition_number]; // get the partition
    struct keyNode* tmp = list;
    while(tmp) {
        if(tmp->key == key) { // get to the key
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
    // printf("MR_Emit\n");
    insert(hashmap3D, key, value, partition_func); // add to partition
}

void* map_iterate(void * arg) { // can I pass map() like this?
    // printf("map_iterate\n");
    Mapper map = arg;
    char* f;
    while(1) {
        f = pick();
        if(f == NULL)
            break;
        map(f);
    }
    // printf(" hashmap3D->list[0]->key = %s\n", hashmap3D->list[0]->key);
    return NULL; // ?
    //exit(0);
}

void* reduce_thread(void * arg) {
    // printf("reduce_thread\n");
    Reducer reduce = arg;
    int p = -1;
    //struct keyNode* head;
    while((p = pick_partition(hashmap3D)) != -1) {
        // printf(" while in reduce_thread()\n");
        // printf(" hashmap3D->list[p = %i]->key = %s\n", p, hashmap3D->list[p]->key);
        struct keyNode* tmp = hashmap3D->list[p];
        while(tmp != NULL) {
            char* key = tmp->key;
            // printf(" key = %s\n", key);
            //int partition_number = tmp->partition;
            // printf(" calling reduce()\n");
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
    printf("hashmap3D initialized\n");
    partition_func = partition;
    pthread_mutex_init(&Q.lock, NULL); // lock init
    // add file names to Q
    for(int i = 1; i < argc; i++) {
        struct Node* tmp = malloc(sizeof(struct Node*));
        //tmp.file_name = malloc(sizeof(char*));
        //strcpy(tmp.file_name, argv[i]);
        tmp->file_name = argv[i];//malloc(sizeof(argv[i]));
        //strcpy(tmp->file_name, argv[i]);
        tmp->next = Q.head;
        Q.head = tmp;
    }
    printf("start mapping\n");
    // run mapper threads
    pthread_t threads_m[num_mappers];
    for(int i = 0; i < num_mappers; i++)
        pthread_create(&threads_m[i], NULL, map_iterate, map);
    // wait all threads done
    for(int i = 0; i < num_mappers; i++)
        pthread_join(threads_m[i], NULL);

    printf("start reducing\n");
    // run reducer threads
    pthread_t threads_r[num_reducers];
    for(int i = 0; i < num_reducers; i++)
        pthread_create(&threads_r[i], NULL, &reduce_thread, reduce);
    // wait all threads done
    for(int i = 0; i < num_reducers; i++)
        pthread_join(threads_r[i], NULL);
    printf("end\n");
}

unsigned long MR_DefaultHashPartition(char *key, int num_partitions) { // used by hashmap?
    // printf("MR_DefaultHashPartition\n");
    unsigned long hash = 5381;
    int c;
    while ((c = *key++) != '\0')
        hash = hash * 33 + c;
    return hash % num_partitions;
}

unsigned long MR_SortedPartition(char *key, int num_partitions) {
    // printf("MR_SortedPartition\n");
    unsigned long num = atoi(key); //?
    unsigned long mask = 0x0FFFFFFFF;
    num = num & mask;
    int log2 = 0;
    while (num_partitions >>= 1) ++log2;
    num = num >> (32 - log2);
    return num;
}

// remove when submit
//int main(){return 1;}
