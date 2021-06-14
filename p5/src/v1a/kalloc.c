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
#define MAX_FNUM 16384
int frames[MAX_FNUM];
int pids[MAX_FNUM];
int index = 0;
int flagofinit = 0;
int firsttime = 1;
// ---- val for syscall(p5) ----
// ---- record all available frames(p5) ----
//char* freemem[?];
// ---- record all available frames(p5) ----

struct run {
  struct run *next;
};

struct {
  struct spinlock lock;
  int use_lock;
  struct run *freelist;
} kmem;

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
  freerange(vstart, vend);
  kmem.use_lock = 1;
  // p5
  flagofinit = 1;
  // p5
}

void
freerange(void *vstart, void *vend)
{
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
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
  // p5 - v1
  //memset(v, 1, PGSIZE*2);
  // p5

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
  kmem.freelist = r;
  if(kmem.use_lock)
    release(&kmem.lock);
}

// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
  struct run *r;

  if(kmem.use_lock)
    acquire(&kmem.lock);
  //r = kmem.freelist;
  // p5
  if(flagofinit == 1) {
    if(firsttime == 1) {
      r = kmem.freelist;
      firsttime = 0;
    } else {
      r = kmem.freelist->next;
    }
  } else {
    r = kmem.freelist;
  }
  // p5
  if(r)
    kmem.freelist = r->next;
  if(kmem.use_lock)
    release(&kmem.lock);
  
  // p5
  if(flagofinit == 1) {
    //cprintf("kalloc1 return addr w/ %x\n", V2P((char*)r));
    uint pfn = V2P((char*)r) >> 12;
    frames[index] = pfn;
    pids[index] = -2; //myproc()->pid; // can I get pid here?
    //cprintf("allocuvm: frames[%d] = %x, pids[%d] = %d\n", index, frames[index], index, pids[index]);
    index++;
  }
  // p5
  return (char*)r;
}

// used for p5
char*
kalloc1(int pid)
{
  struct run *r;

  if(kmem.use_lock)
    acquire(&kmem.lock);
  r = kmem.freelist;
  if(r) {
    kmem.freelist = r->next;
    // p5
    cprintf("kalloc1 return addr w/ %x\n", V2P((char*)r));
    uint pfn = V2P((char*)r) >> 12;
    frames[index] = pfn;
    pids[index] = myproc()->pid; // can I get pid here?
    cprintf("allocuvm: frames[%d] = %x, pids[%d] = %d\n", index, frames[index], index, pids[index]);
    index++;
    // p5
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

