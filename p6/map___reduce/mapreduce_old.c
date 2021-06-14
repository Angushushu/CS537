#include <assert.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <pthread.h>
#include <sys/stat.h>
#include <semaphore.h>
#include "mapreduce.h"

// The hashmap(table) used as partitions
struct table* partitions;

// global variable partitioner
Partitioner partition_func;

// linked list for mapping
struct Node {
    char* file_name;
    struct Node* next;
};

struct {
    struct Node* head;
    pthread_mutex_t lock;
} Q;

char* pick() {
    pthread_mutex_lock(&Q.lock);
    struct Node* n = Q.head;
    if(Q.head != NULL)
        Q.head = Q.head->next;
    pthread_mutex_unlock(&Q.lock);
    return n->file_name;
}

// linked list for reducing
struct Node2 {
    char* key;
    int partition_number;
    struct Node2* next;
};

struct {
    struct Node2* head;
    pthread_mutex_t lock;
} Q2;

void addtoQ2(struct Node2* newNode) {
    pthread_mutex_lock(&Q2.lock);
    struct Node2* tmp = Q2.head;
    while(tmp) {
        if(newNode->key == tmp->key && newNode->partition_number == tmp->partition_number) {
            break;
        }
        if(tmp->next == NULL) {
            tmp->next = newNode;
            break;
        }
        tmp = tmp->next;
    }
    pthread_mutex_lock(&Q2.lock);
}

struct Node2* pick2() {
    pthread_mutex_lock(&Q2.lock);
    struct Node2* n = Q2.head;
    if(Q2.head != NULL)
        Q2.head = Q2.head->next;
    pthread_mutex_unlock(&Q2.lock);
    return n;
}

// data structure of partitions (copied hasmap code from somewhere)
struct node{
    char* key;
    char* val;
    int reduced; // initialized to 0, for get_next()
    struct node *next;
};
struct table{
    int size;
    struct node **list;
};
struct table* createTable(int size){
    struct table *t = (struct table*)malloc(sizeof(struct table));
    t->size = size;
    t->list = (struct node**)malloc(sizeof(struct node*)*size);
    int i;
    for(i=0;i<size;i++)
        t->list[i] = NULL;
    return t;
}
void insert(struct table *t,char* key,char* val, Partitioner partitioner){ // how to pass method
    // pm said it's better to sort each partition
    int pos = partitioner(key, t->size);  // get partition number
    struct node *list = t->list[pos];  // get partition
    struct node *newNode = (struct node*)malloc(sizeof(struct node));
    struct node *temp = list;
    // add key-partition_num pair to Q2
    struct Node2 n;
    n.key = key;
    n.partition_number = pos;
    addtoQ2(&n);
    // sorting
    if(list == NULL){ // when first one is empty
        newNode->next = list;
        t->list[pos] = newNode;
    } else {
        while(temp->next != NULL && strcmp(key, temp->next->key) >= 0) { // while key is not smaller than tmp->next->key
            temp = temp->next;
        }
        newNode->next = temp->next;
        temp->next = newNode;
    }
    // sorting end
    newNode->key = key;
    newNode->val = val;
    newNode->next = list;
}
// hashmap finish here

// list of list for get_next


// Datastruct stores last accessed node w/ a key in a partition

// call the real getter
char* get_next(char *key, int partition_number) {
    struct node* list = partitions->list[partition_number]; // get the partition
    struct node* tmp = list;
    while(tmp) {
        if(tmp->key == key && !tmp->reduced) {
            tmp->reduced = 1;
            return tmp->val;
        }
        tmp = tmp->next;
    }
    return NULL;    
}

void MR_Emit(char *key, char *value) {
    insert(partitions, key, value, partition_func); // add to partitions
}

void map_iterate(Mapper map) { // can I pass map() like this?
    char* f;
    while(1) {
        f = pick();
        if(f == NULL)
            break;
        map(f);
    }
}

// struct ReduceArg { // used for passing arguement to reduce via reduce_thread
//     char* key;
//     Getter get_func;
//     int partition_number;
// }

void reduce_thread(Reducer reduce) {
    struct Node2 *arg;
    while(1) {
        arg = pick2();
        if(arg == NULL)
            break;
        reduce(arg->key, get_next, arg->partition_number);
    }
}

void MR_Run(int argc, char *argv[],
            Mapper map, int num_mappers,
            Reducer reduce, int num_reducers,
            Partitioner partition, int num_partitions) {
    // not sure: build num_partitions partitions via creating hashmap w/ num_partitions linkedlist?
    partitions = createTable(num_partitions);
    partition_func = partition;
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
        pthread_join(&threads_m[i], NULL);

    // run reducer threads
    pthread_t threads_r[num_reducers];
    for(int i = 0; i < num_reducers; i++)
        pthread_create(&threads_r[i], NULL, reduce_thread, reduce);
    // wait all threads done
    for(int i = 0; i < num_reducers; i++)
        pthread_join(&threads_r[i], NULL);
    
    
    
}

unsigned long MR_DefaultHashPartition(char *key, int num_partitions) { // used by hashmap?
    unsigned long hash = 5381;
    int c;
    while ((c = *key++) != '\0')
        hash = hash * 33 + c;
    return hash % num_partitions;
}

unsigned long MR_SortedPartition(char *key, int num_partitions) {
    pass;
}

// remove when submit
//int main(){return 1;}
