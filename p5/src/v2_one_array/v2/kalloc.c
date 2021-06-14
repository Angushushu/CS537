// Physical memory allocator, intended to allocate
// memory for user processes, kernel stacks, page table pages,
// and pipe buffers. Allocates 4096-byte pages.

#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "spinlock.h"
// p5
#include "proc.h"
// p5

void freerange(void *vstart, void *vend);
extern char end[]; // first address after kernel loaded from ELF file
                   // defined by the kernel linker script in kernel.ld

// ---- val for syscall(p5) ----
#define MAX_FNUM 57343
//int index = 0;
//int kinit2ed = 0;
//int page_info[MAX_FNUM];

//int startpa;
//int endpa;
// ---- val for syscall(p5) ----

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  int use_lock;
  struct run *freelist;
	int page_info[MAX_FNUM];
} kmem;

// Initialization happens in two phases.
// 1. main() calls kinit1() while still using entrypgdir to place just
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
  //cprintf("kinit1\n");

  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
}

void
kinit2(void *vstart, void *vend)
{
  //cprintf("kinit2\n");

  // p5
  //kinit2ed = 1;
  // p5
  freerange(vstart, vend);
  kmem.use_lock = 1;
  // p5 - never used?
  //kinit2ed = 1;
  //startpa = V2P(vstart);
  //endpa = V2P(vend);
  /*
  uint a = 57343 - ((uint)V2P(vstart)>>12);
  uint b = 57343 - ((uint)V2P(vend)>>12);
  if(a > b){
    int t = b;
    b = a;
    a = t;
  }
  for(int i = a; i < b; i++) {
    page_info[i] = -1;
  }*/
  // p5
}

void
freerange(void *vstart, void *vend)
{
  //cprintf("freerange: vstart = %x , vend = %x\n", vstart, vend);
  //cprintf("freerange: (PA)vstart = %x , (PA)vend = %x\n", V2P(vstart), V2P(vend));

  char *p;
  p = (char*)PGROUNDUP((uint)vstart);
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
    kfree(p);
}
// Free the page of physical memory pointed at by v,
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
  //cprintf("FUCK\n");

  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);

  if(kmem.use_lock)
    acquire(&kmem.lock);
  
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  // p5
  //if(kinit2ed) {
    //if(V2P(v)>=startpa && V2P(v)<=endpa) {
  uint framenum = (uint)V2P((char*)v) >> 12;
  int index = MAX_FNUM - framenum;//framenum;
  kmem.page_info[index] = -1; //-1 indicates not allocated
    //}
    
  //} else {
    //r = (struct run*)v;
    //r->next = kmem.freelist;
    //kmem.freelist = r;
  //}
  
  // p5
  if(kmem.use_lock)
    release(&kmem.lock);
}

// used for p5
char*
kalloc1(int pid)
{
  //cprintf("kalloc1\n");

  int framen = 0;
  int index = 0;
  struct run *r = kmem.freelist;
  struct run *prer = 0;
  if(kmem.use_lock)
    acquire(&kmem.lock);
  
  if(pid == -2) {
    char* ta = kalloc();
    int tempframn = ((uint)V2P(ta)) >> 12;
    int tempindex = MAX_FNUM - tempframn;
    kmem.page_info[tempindex] = -2;
    // done
    if(kmem.use_lock)
      release(&kmem.lock);
    return ta;
  }
  
  while(r != 0) {
    framen = (uint)(V2P((char*)r)) >> 12;
    index = MAX_FNUM - framen;//framen;

    if(kmem.page_info[index] == -1) {
      if(index == 0 && (kmem.page_info[index+1] == -1 || kmem.page_info[index+1] == pid)) {
        kmem.page_info[index] = pid;
        // remove r from free list
        if(prer == 0) { // if at head, set r as the head
          //r->next = kmem.freelist;
          //kmem.freelist = r;
          kmem.freelist = r->next;
        } else {
          prer->next = r->next;
        }
        break;
      } else if((kmem.page_info[index-1] == pid || (kmem.page_info[index-1] == -1||kmem.page_info[index-1]==-2)) 
                && (kmem.page_info[index+1] == pid || (kmem.page_info[index+1] == -1||kmem.page_info[index+1]==-2))) {
        kmem.page_info[index] = pid;
        // remove r from free list
        if(prer == 0) { // if at head, set r as the head
          //r->next = kmem.freelist;
          //kmem.freelist = r;
          kmem.freelist = r->next;
        } else {
          prer->next = r->next;
        }
        break;
      }
    }

		prer = r;
    r = r->next;
  }
  
  if(kmem.use_lock)
    release(&kmem.lock);
  
  return (char*)r;
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
  //cprintf("kalloc\n");

  struct run *r;

  //if(kinit2ed) {
   // if(kmem.use_lock)
     // acquire(&kmem.lock);
    
  r = kmem.freelist;  
  if(r)
    kmem.freelist = r->next;
    
    //if(kmem.use_lock)
      //release(&kmem.lock);
    
  return (char*)r;
  //}
  
  //return kalloc1(-2);
}



// used for p5
// by sysproc.c
int
dump_physmem(int *uframes, int *upids, int numframes)
{
  if(uframes == 0 || upids == 0)
    return -1;
  //cprintf("dump_physmem in kalloc.c\n");
  int j = 0;
  for(int i = 0; i < MAX_FNUM; i++) {
    //cprintf("  uframes[%d] = frames[%d](%d);\n", i, i, frames[i]);
    //cprintf("  upids[%d] = pids[%d](%d);\n", i, i, pids[i]);
    if(kmem.page_info[i] != -1) {
      uframes[j] = MAX_FNUM - i;
      upids[j] = kmem.page_info[i];
      j++;
      if(j >= numframes) 
        break;
    }
    
  }
  return 0;
}

