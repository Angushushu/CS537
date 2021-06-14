#include <stdio.h>
#include <stdlib.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/mman.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

#define T_DIR       1   // Directory
#define T_FILE      2   // File
#define T_DEV       3   // Special device

#define ROOTINO 1  // root i-number
#define BSIZE 512  // block size

// Disk layout:
// [ boot block | super block | log | inode blocks | free bit map | data blocks]
//
// mkfs computes the super block and builds an initial file system. The
// super block describes the disk layout:
struct superblock {
    uint size;         // Size of file system image (blocks)
    uint nblocks;      // Number of data blocks
    uint ninodes;      // Number of inodes.
    uint nlog;         // Number of log blocks
    uint logstart;     // Block number of first log block
    uint inodestart;   // Block number of first inode block
    uint bmapstart;    // Block number of first free map block
};

#define NDIRECT 12
#define NINDIRECT (BSIZE / sizeof(uint))
#define MAXFILE (NDIRECT + NINDIRECT)

// On-disk inode structure
struct dinode {
    short type;           // File type
    short major;          // Major device number (T_DEV only)
    short minor;          // Minor device number (T_DEV only)
    short nlink;          // Number of links to inode in file system
    uint size;            // Size of file (bytes)
    uint addrs[NDIRECT+1];   // Data block addresses
};

// Inodes per block.
#define IPB           (BSIZE / sizeof(struct dinode))
// Block containing inode i
#define IBLOCK(i, sb)     ((i) / IPB + sb.inodestart)
// Bits per block
#define BPB           (BSIZE*8)
// Block of free map containing bit for block b
#define BBLOCK(b, sb) (b/BPB + sb.bmapstart)
// Directory is a file containing a sequence of dirent structures.
#define DIRSIZ 14

struct dirent {
    ushort inum;
    char name[DIRSIZ];};

// ***Individual Inode Checks***
// 1. Each inode is either unallocated or one of the valid types (T_FILE, T_DIR, T_DEV).
// ERROR: bad inode.
void bad_inode(){
    fprintf(stderr, "ERROR: bad inode.\n");
    exit(1);
}
// 2. For in-use inodes, the size of the file is in a valid range given the number of valid datablocks.
// direct and indirect douyaokaolv  inode zhixiangde block is valid
// ERROR: bad size in inode.
void bad_size_inode(){
    fprintf(stderr, "ERROR: bad size in inode.\n");
    exit(1);
}
// ***Directory Checks***
// 3. Root directory exists, and it is inode number 1.
// ERROR: root directory does not exist.
void root_dir_not_exist(){
    fprintf(stderr, "ERROR: root directory does not exist.\n");
    exit(1);
}
// 4. The . entry in each directory refers to the correct inode.
// ERROR: current directory mismatch.
void curr_dir_mismatch(){
    fprintf(stderr, "ERROR: current directory mismatch.\n");
    exit(1);
}
// ***Bitmap Checks***
// 5. Each data block that is in use (pointed to by an allocated inode), is also marked in use in the bitmap.
// ERROR: bitmap marks data free but data block used by inode.
void bitmap_free_block_use(){
    fprintf(stderr, "ERROR: bitmap marks data free but data block used by inode.\n");
    exit(1);
}
// 6. For data blocks marked in-use in the bitmap, actually is in-use in an inode or indirect block somewhere.
// ERROR: bitmap marks data block in use but not used.
void bitmap_use_block_free(){
    fprintf(stderr, "ERROR: bitmap marks data block in use but not used.\n");
    exit(1);
}
// ***Multi-Structure Checks***
// 7. For inode numbers referred to in a valid directory, actually marked in use in inode table.
// ERROR: inode marked free but referred to in directory.
void inode_free_dir_referred(){
    fprintf(stderr, "ERROR: inode marked free but referred to in directory.\n");
    exit(1);
}
// 8. For inodes marked used in inode table, must be referred to in at least one directory.
// ERROR: inode marked in use but not found in a directory.
void inode_use_dir_not_found(){
    fprintf(stderr, "ERROR: inode marked in use but not found in a directory.\n");
    exit(1);
}

// Global variables: The start point of each segment in the file system
int img;
void *img_ptr;          // pointer to *.img
struct superblock *sb;  // pointer to superblock
struct dinode *start;   // first inode block in list of inodes
char *bitmap;           // pointer to bitmap location
uint sbitmap_bytes;
uint bitmap_block;
int dircount;           // directory count
void* free_data_block;

void findIndex(int i, struct dirent** rootdir, struct dirent** parentdir);
void finish(){
    if(img != -1){
        close(img);
    }
}

void parse_file(){
    struct stat sbuf;
    fstat(img, &sbuf);
    if((img_ptr = mmap(NULL, sbuf.st_size, PROT_READ, MAP_PRIVATE, img, 0)) < 0){
        fprintf(stderr, "Failed to mmap\n");
        exit(1);
    }
    sb = (struct superblock*)(img_ptr + BSIZE);
    start = (struct dinode*)(img_ptr + sb->inodestart * BSIZE);
    bitmap_block = sb->ninodes / IPB + 3;
    bitmap = (char*) (img_ptr + (BSIZE * bitmap_block));
    sbitmap_bytes = 1024/8;
    dircount = 0;
    free_data_block = img_ptr + (BSIZE * (bitmap_block + 1));
}

void findIndex(int i, struct dirent** rootdir, struct dirent** parentdir){
    struct dinode* temp = &start[i];
//    printf("address of ith dinode: %p\n", &start[i]);
    short temp_type = temp->type;
    // Check root dir
    int root_count = 0;
    int parent_count = 0;
    if(temp_type == T_DIR) {
        for(int k = 0; k < NDIRECT; k++) {
            struct dirent* cur_dirent = img_ptr + (BSIZE * (temp -> addrs[k]));
            for(int b = 0; b < BSIZE/sizeof(struct dirent); b++){
                if(!(cur_dirent->inum)) {
                    cur_dirent++;
                    continue;
                }
                if(strcmp(".", cur_dirent -> name) == 0){
                    root_count++;
                    *rootdir = cur_dirent;
                }
                else if(strcmp("..", cur_dirent -> name) == 0){
                    parent_count++;
                    *parentdir = cur_dirent;
                }
                cur_dirent++;
            }
        }
        if(temp -> addrs[NDIRECT]){
            uint* dir_entry = (uint*)(img_ptr + (temp -> addrs[NDIRECT]) * BSIZE + 0x40);
            for(int j = 0; j < NINDIRECT; j++){
                struct dirent* cur_dirent = (struct dirent*)(img_ptr + (BSIZE*(dir_entry[j])) + 0x40);
                for(int c = 0; c < BSIZE/sizeof(struct dirent); c++){
                    if(!(cur_dirent -> inum)){
                        cur_dirent++;
                        continue;
                    }
                    if(strcmp(".", cur_dirent -> name) == 0){
                        root_count++;
                        *rootdir = cur_dirent;
                    }
                    else if(strcmp("..", cur_dirent -> name) == 0){
                        parent_count++;
                        *parentdir = cur_dirent;
                    }
                    cur_dirent++;
                }
            }
        }
    }
}

void check_inodes(){
    struct dinode *temp = start;
    struct dirent* rootdir;
    struct dirent* parentdir;
    for(int i = 0; i < sb -> ninodes; i++){
        short temp_type = temp->type;
        /** first check**/
        if(temp_type < 0 || temp_type > T_DEV){
            bad_inode();
        }
        // Check root dir
        findIndex(i, &rootdir, &parentdir);

        if(i == ROOTINO && temp_type != T_DIR){
            root_dir_not_exist();
        }
        else if(i == ROOTINO && temp_type == T_DIR){
            if (rootdir->inum != parentdir->inum  && (rootdir->inum == ROOTINO || parentdir->inum == ROOTINO)){
                root_dir_not_exist();
            }
        }
        temp ++;
    }
    temp = start;
    for(int i=0; i< sb->ninodes; i++) {
        if(temp->type != 0) {
            // printf("dip->address[0]: %d\n", dip->addrs[0]);
            int nblock = 0;
            for(int j = 0; j < NDIRECT; j++) {
                uint blk_ptr = temp->addrs[j];
                if(blk_ptr != 0) {
                    nblock++;
                }
            }
            uint blk_num = temp->addrs[NDIRECT];
            uint *addr = (uint *) (img_ptr + (blk_num * BSIZE));
            if (blk_num != 0) {
                for(int k = 0; k < NINDIRECT; k++) {
                    if(*addr != 0) {
                        nblock++;
                    }
                    addr++;
                }
            }
            if((nblock * BSIZE) - temp->size >= BSIZE) {
                bad_size_inode();
            }
        }
        if(temp->type == 1) {
            struct dirent *dir = (struct dirent*)(img_ptr + (temp->addrs[0] * BSIZE));
            if(dir->inum != i) {
                curr_dir_mismatch();
            }
        }
        temp++;
    }
}

void check_data(){  // multi-structure checks
    struct dinode *temp;
    int* ref_inode;
    int* ref_dirent;
    int* ref_link;
    int* ref_dir;
    int i;
    temp = start;
    if((ref_inode = (int*)calloc(sb->ninodes, sizeof(int))) == NULL){
        printf("ERROR: calloc() failed.\n");
        finish();
        exit(1);
    }
    if((ref_dirent = (int*)calloc(sb->ninodes, sizeof(int))) == NULL){
        printf("ERROR: calloc() failed.\n");
        finish();
        exit(1);
    }
    if((ref_link = (int*)calloc(sb->ninodes, sizeof(int))) == NULL){
        printf("ERROR: calloc() failed.\n");
        finish();
        exit(1);
    }
    if((ref_dir = (int*)calloc(sb->ninodes, sizeof(int))) == NULL){
        printf("ERROR: calloc() failed.\n");
        finish();
        exit(1);
    }
    // check inuse
    for(i = 0; i < sb -> ninodes; i++){
        if(temp -> type){
            ref_inode[i] = 1;
            dircount += temp->nlink;
        }
        temp++;
    }
    temp = start;  // restart temp
    // loop inodes
    for(i = 0; i < sb -> ninodes; i++){
        if(temp -> type == T_DIR){  // if a dir
            // loop data block
            int j;
            for(j = 0; j < NDIRECT; j ++){
                struct dirent* data_entry = (struct dirent*)(img_ptr + BSIZE*(temp->addrs[j]));
                // loop directory entry
                for(int k = 0; k < BSIZE/sizeof(struct dirent); k++){
                    if(data_entry->inum && data_entry->inum != i){
                        ref_dirent[data_entry->inum] ++;
                        if(start[data_entry->inum].type == T_FILE){
                            ref_link[data_entry->inum] ++;
                        }
                        else if(start[data_entry->inum].type == T_DIR){
                            if (strcmp(data_entry->name, ".") != 0 && strcmp(data_entry->name, "..") != 0){
                                ref_dir[data_entry->inum]++;
                            }
                        }
                    }
                    data_entry ++;
                }
            }
            // indir
            uint* entry = (uint*)(img_ptr + (temp -> addrs[NDIRECT]) * BSIZE);
            for(j = 0; j < NINDIRECT; j++){
                struct dirent* data_entry = (struct dirent*)(img_ptr + BSIZE*(entry[j]));
                for(int k = 0; k < BSIZE/sizeof(struct dirent); k++){
                    if(data_entry->inum && data_entry->inum != i){
                        ref_dirent[data_entry->inum] ++;
                        if(start[data_entry->inum].type == T_FILE){
                            ref_link[data_entry->inum] ++;
                        }
                        else if(start[data_entry->inum].type == T_DIR){
                            if (strcmp(data_entry->name, ".") != 0 && strcmp(data_entry->name, "..") != 0){
                                ref_dir[data_entry->inum]++;
                            }
                        }
                    }
                    data_entry ++;
                }
            }
        }
        temp ++;
    }
    ref_dirent[ROOTINO] ++;
    for(i = 0; i < sb -> ninodes; i++){
        if(!ref_dirent[i] && ref_inode[i]){ // empty dirent but referred inode
            inode_use_dir_not_found();
        }
    }
    //save file
    for(i = 0; i < sb -> ninodes; i++){
        if(ref_dirent[i] && !ref_inode[i]){  // referred dirent but empty inode
            inode_free_dir_referred();
        }
    }
    free(ref_inode);
    free(ref_dirent);
    free(ref_link);
    free(ref_dir);
}

void check_bitmap() {
    struct dinode *temp = start;
    uint block_ptr[sb->size];  // direct or indirect data block numbers, index = blk_num
    uint bmap_arr[sb->size];
    for(int i = 0; i < sb->size; i++) {
        block_ptr[i] = 0;
    }
    for(int i = 0; i < sb->ninodes; i++) {
        if(temp->type != 0) {
            for(int j = 0; j < NDIRECT; j++) {
                uint blk_num = temp->addrs[j];
                // printf("blk_num: %d\n", blk_num);
                if(blk_num != 0) {
                    block_ptr[blk_num] = 1;
                }
            }
            uint blk_num = temp->addrs[NDIRECT];
            block_ptr[blk_num] = 1;
            uint *addr = (uint *) (img_ptr + (blk_num * BSIZE));
            // printf("blk_num: %d\n", blk_num);
            if (blk_num != 0) {
                for(int k = 0; k < NINDIRECT; k++) {
                    // printf("*addr = %d \n",*addr);
                    if(*addr != 0) {
                        block_ptr[*addr] = 1;
                    }
                    addr++;
                }
            }
        }
        temp++;
    }
    // store bmap_arr
    char *bitmap = (char *)(img_ptr + (sb->bmapstart * BSIZE));
    int index = 0;
    while(index < sb->size) {
        int mask = 1;
        for(int j = 0; j < 8 && index < sb->size; j++) {
            int value = (*bitmap & mask);
            if(value > 0) {
                value = 1;
            }
            bmap_arr[index] = value;
            index++;
            mask = mask << 1;
        }
        bitmap++;
    }

    int data_blk_init = sb->bmapstart; // + 1;
    int count = 0;
    for(int i = data_blk_init; i < sb->size; i++) {
        //printf("bitmap: %d, block_ptr[%d]: %d\n",bmap_arr[i], i, block_ptr[i]);
        if(bmap_arr[i] == 0 && block_ptr[i] == 1) {
            bitmap_free_block_use();
        }
    }
    for(int i = data_blk_init; i < sb->size; i++) {
        //printf("block_ptr[%d]: %d\n", i, block_ptr[i]);
        if(bmap_arr[i] == 1 && block_ptr[i] == 0) {
            if(count >0) {
                // printf("bit map %d , block ptr %d \n", bmap_arr[i], block_ptr[i]);
                // printf("index: %d\n", i);
                bitmap_use_block_free();
            }
            count++;
        }
    }
}

int main(int argc, char** argv) {
    char* image_name = argv[1];
    img = open(image_name, O_RDONLY);
    parse_file();
//    int type;
//
//    for (int i = 0; i < sb->ninodes; i++) {
//        type = start->type;
//        printf("type %d: %d\n", i, type);
//        start++;
//    }
    check_bitmap();
    check_inodes();
    check_data();
    finish();
    exit(0);
}