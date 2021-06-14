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
    pthread_mutex_t lock;
} Q;

char* pick() {
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
    for(int i = 0; i < size; i++) {
        t->list[i] = NULL;
        pthread_mutex_init(&t->lock[i], NULL);
    }
    return t;
}

// Merge sort for linked list pairNode: https://www.geeksforgeeks.org/merge-sort-for-linked-list/ thanks writter
/* function prototypes */
struct pairNode* SortedMerge(struct pairNode* a, struct pairNode* b);
void FrontBackSplit(struct pairNode* source,
                    struct pairNode** frontRef, struct pairNode** backRef);

/* sorts the linked list by changing next pointers (not data) */
void MergeSort(struct pairNode** headRef) {
    struct pairNode* head = *headRef;
    struct pairNode* a;
    struct pairNode* b;
    /* Base case -- length 0 or 1 */
    if ((head == NULL) || (head->next == NULL)) {
        return;
    }
    /* Split head into 'a' and 'b' sublists */
    FrontBackSplit(head, &a, &b);
    /* Recursively sort the sublists */
    MergeSort(&a);
    MergeSort(&b);
    
    /* answer = merge the two sorted lists together */
    *headRef = SortedMerge(a, b);

    // printf("Check result of sorting\n");
    struct pairNode* tmp = *headRef;
    while(tmp != NULL) {
        // printf(" tmp->key = %s (MergeSort)\n", tmp->key);
        tmp = tmp->next;
    }
}
struct pairNode* SortedMerge(struct pairNode* a, struct pairNode* b) {
    struct pairNode* result = NULL;
    /* Base cases */
    if (a == NULL)
        return (b);
    else if (b == NULL)
        return (a);
    /* Pick either a or b, and recur */
    if (strcmp(a->key, b->key) <= 0) {
        result = a;
        // printf(" a's key: %s\n", a->key);
        result->next = SortedMerge(a->next, b);
    }
    else {
        result = b;
        // printf(" b's key: %s\n", b->key);
        result->next = SortedMerge(a, b->next);
    }
    return (result);
}
/* UTILITY FUNCTIONS */
/* Split the nodes of the given list into front and back halves,
    and return the two lists using the reference parameters.
    If the length is odd, the extra node should go in the front list.
    Uses the fast/slow pointer strategy. */
void FrontBackSplit(struct pairNode* source,
                    struct pairNode** frontRef, struct pairNode** backRef)
{
    struct pairNode* fast;
    struct pairNode* slow;
    slow = source;
    fast = source->next;

    /* Advance 'fast' two nodes, and advance 'slow' one node */
    while (fast != NULL) {
        fast = fast->next;
        if (fast != NULL) {
            slow = slow->next;
            fast = fast->next;
        }
    }
    /* 'slow' is before the midpoint in the list, so split it in two
    at that point. */
    *frontRef = source;
    *backRef = slow->next;
    slow->next = NULL;
}
// merge sort ends here

void insert(struct table* t, char* key, char* val, Partitioner partitioner) {
    int p_num = partitioner(key, t->size);
    struct pairNode* new_pairNode = (struct pairNode*)malloc(sizeof(struct pairNode));
    new_pairNode->val = strdup(val);
    new_pairNode->key = strdup(key);
    new_pairNode->partition = p_num;
    pthread_mutex_init(&new_pairNode->lock, NULL);
    pthread_mutex_lock(&t->lock[p_num]);
    // new logic
    if(t->list[p_num] == NULL) {
        t->list[p_num] = new_pairNode;
    } else {
        //add at the head
        struct pairNode* tmp = t->list[p_num];
        new_pairNode->next = tmp;
        t->list[p_num] = new_pairNode;
    }
    // new logic ends here
    pthread_mutex_unlock(&t->lock[p_num]);
}
int pick_partition(struct table* t) { // pick the next partition for reducing
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

// call the real getter
char* get_next(char *key, int partition_number) {  // can be improved
    struct pairNode** list = &hashmap2D->list[partition_number]; // get the partition
    struct pairNode* tmp = *list, *prev;
    prev = tmp;
    if(tmp && strcmp(tmp->key, key) == 0) { // get to the key
        pthread_mutex_lock(&tmp->lock);
        char *ret_val = strdup(tmp->val);
        if(tmp == *list) {
            hashmap2D->list[partition_number] = tmp->next;
            pthread_mutex_unlock(&tmp->lock);
            //free tmp
            free(tmp->key);
            free(tmp->val);
            free(tmp);
            return ret_val;
        } else {
            prev->next = tmp->next;
            pthread_mutex_unlock(&tmp->lock);
            //free tmp
            free(tmp->key);
            free(tmp->val);
            free(tmp);
            return ret_val;
        }        
    }
    return NULL;
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
void* reduce_thread(void * arg) {
    Reducer reduce = arg;
    int p = -1;
    while((p = pick_partition(hashmap2D)) != -1) {
        if(hashmap2D->list[p] != NULL) {
            MergeSort(&(hashmap2D->list[p]));
        }
        struct pairNode* tmp = hashmap2D->list[p];
        while(tmp != NULL) {
            char* key = strdup(tmp->key);
            reduce(key, get_next, p);
            tmp = hashmap2D->list[p];
        }
    }
    return NULL;
}



void MR_Run(int argc, char *argv[],
            Mapper map, int num_mappers,
            Reducer reduce, int num_reducers,
            Partitioner partition, int num_partitions) {
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
    
    // free
    free(hashmap2D->lock);
    for (int i = 0; i < hashmap2D->size; i++) {
        struct pairNode* freed = hashmap2D->list[i];
        struct pairNode* freeing = hashmap2D->list[i];
        while(freeing) {
            freeing = freeing->next;
            free(freed->val);
            free(freed->key);
            free(freed);
            freed = freeing;
        }
    }
    free(hashmap2D->list);
    free(hashmap2D->reduced);
    free(hashmap2D);
    struct Node* freed = Q.head;
    struct Node* freeing = Q.head;
    while(freeing) {
        freeing = freeing->next;
        free(freed->file_name);
        free(freed->next);
        free(freed);
        freed = freeing;
    }
}

unsigned long MR_DefaultHashPartition(char *key, int num_partitions) { // used by hashmap
    unsigned long hash = 5381;
    int c;
    while ((c = *key++) != '\0')
        hash = hash * 33 + c;
    return hash % num_partitions;
}

unsigned long MR_SortedPartition(char *key, int num_partitions) {
    unsigned long num = atoi(key);
    unsigned long mask = 0x0FFFFFFFF;
    num = num & mask;
    int log2 = 0;
    while (num_partitions >>= 1) ++log2;
    num = num >> (32 - log2);
    return num;
}
