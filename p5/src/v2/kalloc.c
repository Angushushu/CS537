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
//#include "flags.h"
// p5

void freerange(void *vstart, void *vend);
extern char end[]; // first address after kernel loaded from ELF file
                   // defined by the kernel linker script in kernel.ld

// ---- val for syscall(p5) ---- moved to flags.h
#define MAX_FNUM 16384
int frames[MAX_FNUM];
int pids[MAX_FNUM];
int index = 0;
int kinit2ed = 0;
// ---- val for syscall(p5) ----

struct run {
  // p5
  int pid;
  // p5
  struct run *next;
};

struct {
  struct spinlock lock;
  int use_lock;
  struct run *freelist;
} kmem;

// p5 - print the freelist
void
check(){
  if(kmem.use_lock)
    acquire(&kmem.lock);
  struct run *tr = kmem.freelist;
  while(tr) {
    cprintf("[%d]", tr->pid);
    tr = tr->next;
  }
  cprintf("\n");
  if(kmem.use_lock)
    release(&kmem.lock);
}
// p5

// Initialization happens in two phases.
// 1. main() calls kinit1() while still using entrypgdir to place just
// the pages mapped by entrypgdir on free list.
// 2. main() calls kinit2() with the rest of the physical pages
// after installing a full page table that maps them on all cores.
void
kinit1(void *vstart, void *vend)
{
  initlock(&kmem.lock, "kmem");
  kmem.use_lock = 0;
  freerange(vstart, vend);
}

void
kinit2(void *vstart, void *vend)
{
  cprintf("kinit2\n");
  // p5 - v2
  //check();//
  kinit2ed = 1;
  kmem.freelist = 0; // clear all free pages from kinit1?
  // p5 - v2
  freerange(vstart, vend);
  kmem.use_lock = 1;
}

void
freerange(void *vstart, void *vend)
{
  cprintf("freerange\n");

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
  //cprintf("kfree\n");

  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);

  if(kmem.use_lock)
    acquire(&kmem.lock);
  
  //r = (struct run*)v;
  //r->next = kmem.freelist;
  //kmem.freelist = r;
  // p5
  if(kinit2ed == 1) {
    r = (struct run*)v;
    // decide r->pid by observing neighbors' pid
    int lpid = 0; // pid 0 for unallocated
    int rpid = 0;
    int rframe = (uint)(V2P(r) >> 12);
    // find the frame on left and right via frames first
    for(int i = 0; i < index; i++) {
      // remove the frame from frames record
      if(frames[i] == rframe) {
        for(int j = i; j < index; j++) {
          frames[j] = frames[j+1];
        }
        index--;
      }
      // get pid using the left frame
      if(frames[i] == rframe - 1)
        lpid = pids[i];
      // get pid using the right frame
      if(frames[i] == rframe + 1)
        rpid = pids[i];
    }
    
    if(lpid == 0 && rpid == 0) {
      r->pid = 0; // available for any
    } else if(lpid == rpid || lpid == 0) {
      r->pid = rpid;
    } else if(rpid == 0) {
      r->pid = lpid;
    } else {
      r->pid = -1; // invailable
    }

    // add the frame to freelist
    r->next = kmem.freelist;
    kmem.freelist = r;
  } else {
    r = (struct run*)v;
    r->next = kmem.freelist;
    r->pid = -2; // indicates it's freed before kinit2
    kmem.freelist = r;
  }
  // p5

  if(kmem.use_lock)
    release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
  cprintf("kalloc\n");

  struct run *r;

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = kmem.freelist;
  if(r)
    kmem.freelist = r->next;
  if(kmem.use_lock)
    release(&kmem.lock);
  return (char*)r;
}

// used for p5 - v2
char*
kalloc1(int pid)
{
  cprintf("kalloc1(%d)\n", pid);

  if()
  struct run *r = 0;

  // pick the first frame that available for the pid
  if(kmem.use_lock)
    acquire(&kmem.lock);
  
  struct run *tr = kmem.freelist;
  while(tr) {
    if(tr->pid == pid || tr->pid == 0) {
      r = tr;
      // record the info of allocation
      frames[index] = (uint)V2P(r) >> 12;
      pids[index] = pid;
      index++;
      //
      break;
    }
    tr = tr->next;
  }

  if(kmem.use_lock)
    release(&kmem.lock);
  
  return (char*)r;
}

// used for p5
// by sysproc.c
int
dump_physmem(int *uframes, int *upids, int numframes)
{
  //cprintf("dump_physmem in kalloc.c\n");
  for(int i = 0; i < numframes; i++) {
    //cprintf("  uframes[%d] = frames[%d](%d);\n", i, i, frames[i]);
    //cprintf("  upids[%d] = pids[%d](%d);\n", i, i, pids[i]);
    uframes[i] = frames[i];
    upids[i] = pids[i];
  }
  //cprintf("leaving dump_physmem in kalloc.c\n");
  return 0;
}

