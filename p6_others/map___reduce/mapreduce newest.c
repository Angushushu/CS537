#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sys/stat.h>
#include <semaphore.h>
#include "mapreduce.h"

// The hashmap(table) used as partitions
struct table* hashmap2D;
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

// 2D data
struct pairNode {
    char* key;
    char* val;
    struct pairNode *next;
    int partition;
    pthread_mutex_t lock;
};

struct table {
    int size;
    struct pairNode*** arr; // the arrays
    int* lsize; // for transf from list to array
    int* index; // for reduce_thread
    struct pairNode **list;
    int *reduced; // for pick_partition
    pthread_mutex_t *lock;
};
struct table* createTable(int size) {
    struct table *t = (struct table*)malloc(sizeof(struct table));
    t->size = size;
    t->list = (struct pairNode**)malloc(sizeof(struct pairNode*)*size);
    t->reduced = (int*)malloc(sizeof(int)*size);
    t->lock = (pthread_mutex_t*)malloc(sizeof(pthread_mutex_t)*size);  // using lock[] only have mem on stack, will be removed after function finish
    t->arr = (struct pairNode***)malloc(sizeof(struct pairNode**)*size);

    t->lsize = (int*)malloc(sizeof(int)*size);
    t->index = (int*)malloc(sizeof(int)*size);

    for(int i = 0; i < size; i++) {
        t->list[i] = NULL;
        t->arr[i] = NULL;
        pthread_mutex_init(&t->lock[i], NULL);
    }
//    printf("createTable\n");
    return t;
}
void insert(struct table* t, char* key, char* val, Partitioner partitioner) { // how to pass method
//    printf("insert\n");
    int p_num = partitioner(key, t->size);
    struct pairNode* new_pairNode = (struct pairNode*)malloc(sizeof(struct pairNode));
    new_pairNode->val = strdup(val);
    new_pairNode->key = strdup(key);
//    printf("fuck?\n");
    new_pairNode->partition = p_num;
    pthread_mutex_init(&new_pairNode->lock, NULL);
    pthread_mutex_lock(&t->lock[p_num]);
//    printf("locked\n");
    // new logic
    if(t->list[p_num] == NULL) {
        t->list[p_num] = new_pairNode;
        // printf(" %s - %s pair added to partition %i (1st)\n", new_pairNode->key, new_pairNode->val, p_num);
    } else {
        //add at the head
        struct pairNode* tmp = t->list[p_num];
        new_pairNode->next = tmp;
        t->list[p_num] = new_pairNode;
        // printf(" %s - %s pair added to partition %i\n", new_pairNode->key, new_pairNode->val, p_num);
    }
    // new logic ends here
    pthread_mutex_unlock(&t->lock[p_num]);
    t->lsize[p_num]++;
}
int pick_partition(struct table* t) { // pick the next partition for reducing
    //printf("pick_partition\n");
    for(int i = 0; i < t->size; i++) {
        pthread_mutex_lock(&t->lock[i]);
        // partition should have been reduced
        if(t->reduced[i] == 0) {
            t->reduced[i] = 1;
            pthread_mutex_unlock(&t->lock[i]);
            return i;
        }
        pthread_mutex_unlock(&t->lock[i]);
    }
    return -1;
}

char* get_next(char *key, int partition_number) {  // can be improved
    //printf("get_next\n"); // the key should at the index
    if(hashmap2D->index[partition_number] >= hashmap2D->lsize[partition_number])
        return NULL;
    char* thiskey = strdup((hashmap2D->arr[partition_number])[hashmap2D->index[partition_number]]->key);
    if(strcmp(key, thiskey) == 0) {
        char* ret_val = strdup((hashmap2D->arr[partition_number])[hashmap2D->index[partition_number]]->val);
        //printf(" got ret_val %s from index %i\n", ret_val, hashmap2D->index[partition_number]);
        hashmap2D->index[partition_number]++;
        return ret_val;
    } else {
        //printf(" no more w/ this key, return NULL\n");
        return NULL;
    }
    
    
}

void MR_Emit(char *key, char *value) {
    insert(hashmap2D, key, value, partition_func); // add to partition
}
void* map_iterate(void * arg) {
    Mapper map = arg;
    char* f;
    while(1) {
        f = pick();
        if(f == NULL)
            break;
        map(f);
    }
    return NULL;
}

int cmpfunc (const void* a, const void* b) { // for qsort
    // printf("cmpfunc\n");
    // printf(" check in cmpfunc:\n");
    // printf(" (hashmap2D->arr[0])[0]->key = %s\n", (hashmap2D->arr[0])[0]->key);
    // printf(" (hashmap2D->arr[0])[1]->key = %s\n", (hashmap2D->arr[0])[1]->key);
    // printf(" (hashmap2D->arr[0])[2]->key = %s\n", (hashmap2D->arr[0])[2]->key);
    struct pairNode* n1 = (struct pairNode*)a;
    struct pairNode* n2 = (struct pairNode*)b;
    char* c1 = *(char**)(n1->key);
    char* c2 = *(char**)(n2->key);
    // printf(" c1 = %s\n", c1);
    // printf(" c2 = %s\n", c2);
    int result = strcmp(c1, c2);
    // printf(" strcmp gives %i\n", result);
    return result;
}

void* reduce_thread(void * arg) {
    // printf("reduce_thread\n");
    Reducer reduce = arg;
    int p = -1;
    while((p = pick_partition(hashmap2D)) != -1) {

        // trans linkedlist to array
        hashmap2D->arr[p] = malloc(sizeof(struct pairNode*)*(hashmap2D->lsize[p]));
        struct pairNode* tmp = hashmap2D->list[p];
        // printf(" adding pairNode to arr[%i]\n", p);
        // printf(" hashmap2D->lsize[%i] = %i\n", p, hashmap2D->lsize[p]);

        for(int i = 0; i < hashmap2D->lsize[p]; i++) {
            (hashmap2D->arr[p])[i] = tmp;
            // printf(" (hashmap2D->arr[%i])[%i]->key = %s\n", p, i, (hashmap2D->arr[p])[i]->key);
            tmp = tmp->next;
        }
        // printf(" Before sort:\n");
        // printf(" (hashmap2D->arr[0])[0]->key = %s\n", (hashmap2D->arr[p])[0]->key);
        // printf(" (hashmap2D->arr[0])[1]->key = %s\n", (hashmap2D->arr[p])[1]->key);
        // printf(" (hashmap2D->arr[0])[2]->key = %s\n", (hashmap2D->arr[p])[2]->key);

        // sort array
        qsort(hashmap2D->arr[p], hashmap2D->lsize[p], sizeof(struct pairNode*), cmpfunc); // qsort doesn't finish

        // printf(" After sort:\n");
        // printf(" (hashmap2D->arr[0])[0]->key = %s\n", (hashmap2D->arr[p])[0]->key);
        // printf(" (hashmap2D->arr[0])[1]->key = %s\n", (hashmap2D->arr[p])[1]->key);
        // printf(" (hashmap2D->arr[0])[2]->key = %s\n", (hashmap2D->arr[p])[2]->key);
        // call reduce
        // printf(" lsize: %d\n", hashmap2D->lsize[p]);
        // printf(" index: %d\n", hashmap2D->index[p]); // didn't initialiws?
        
        while(hashmap2D->index[p] < hashmap2D->lsize[p]) {
            // printf("Calling reduce w/ key %s\n", (hashmap2D->arr[p])[hashmap2D->index[p]]->key);
            reduce((hashmap2D->arr[p])[hashmap2D->index[p]]->key, get_next, p);
        }
    }
    return NULL;
}

void MR_Run(int argc, char *argv[],
            Mapper map, int num_mappers,
            Reducer reduce, int num_reducers,
            Partitioner partition, int num_partitions) {
    // printf("MR_Run\n");
    // not sure: build num_partitions partitions via creating hashmap w/ num_partitions linkedlist?
    hashmap2D = createTable(num_partitions);
    partition_func = partition;
    pthread_mutex_init(&Q.lock, NULL); // lock init
    // add file names to Q
    for(int i = 1; i < argc; i++) {
        struct Node *tmp = malloc(sizeof(struct Node *));
        tmp->file_name = argv[i];
        tmp->next = Q.head;
        Q.head = tmp;
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
//    printf("hi\n");
    free(hashmap2D->lock);
    for (int i = 0; i < hashmap2D->size; i++) {
        free(hashmap2D->list[i]);
    }
    free(hashmap2D->list);
    free(hashmap2D->reduced);
    free(hashmap2D);
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
//    printf("%s, %lu \n", key, num);
    return num;
}


// remove when submit
//int main(){return 1;}
