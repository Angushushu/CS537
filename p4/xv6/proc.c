#include "types.h"
#include "defs.h"
#include "param.h"
#include "memlayout.h"
#include "mmu.h"
#include "x86.h"
#include "proc.h"
#include "spinlock.h"
// p(4)
#include "pstat.h"

struct {
  struct spinlock lock;
  struct proc proc[NPROC];
} ptable;

static struct proc *initproc;

int nextpid = 1;
extern void forkret(void);
extern void trapret(void);

static void wakeup1(void *chan);

// priority queues
struct {
  //struct spinlock lock;
  struct proc* proc[4][NPROC];
} q;

// helper func (p4)
// check q
int printq(void) {
  cprintf("->printq, NPROC = %d\n", NPROC);
  //acquire(&q.lock);
  for(int i = 0; i < 4; i++) {
    for(int j = 0; j < NPROC; j++){
      cprintf("%d , ", q.proc[i][j]);
    }
    cprintf("\n");
  }
  //release(&q.lock);
  return 0;
}

int printptable(void) {
  cprintf("->printptable, NPROC = %d\n", NPROC);
  acquire(&ptable.lock);
  for(int j = 0; j < NPROC; j++){
    cprintf("%d | ", ptable.proc[j]);
  }
  cprintf("\n");
  release(&ptable.lock);
  return 0;
}

// add a proc to back of queue
int addproc(int pri, struct proc* p) {
  //acquire(&q.lock);
  //cprintf(" addproc(%d, pid = %d):\n", pri, p->pid);
  for(int i = 0; i < NPROC; i++) {
    //cprintf("q[%d][%d] = %d\n", pri, i, q[pri][i]);
    
    //printq();
		if(q.proc[pri][i] == 0) {
      q.proc[pri][i] = p;
			//cprintf("pid = %d added to back of q[%d]\n", p->pid, pri);
			//cprintf("before: pid = %d -> qtail[%d] = %d\n", p->pid, pri, p->qtail[pri]);
			p->qtail[pri]++;
			//cprintf("after: pid = %d -> qtail[%d] = %d\n", p->pid, pri, p->qtail[pri]);
			p->pri = pri;
      //cprintf("pid = %d added to q[%d][%d]\n", p->pid, pri, i);
      //printq();
      //release(&q.lock);
			return 0;
    }
  }
  //release(&q.lock);
  return -1;
}

// remove and move later proc to left
int removefromq(int pri, int pid) {
  //cprintf(" removefromq(%d, %d)\n", pri, pid);
  //acquire(&q.lock);
  int move = 0;
  for(int i = 0; i < NPROC; i++) {
    if(move == 0 && q.proc[pri][i]->pid == pid) {
      //cprintf("removing\n");
			//cprintf("q[%d][%d] = %d\n", pri, i, q[pri][i]);
			q.proc[pri][i] = 0;
      move = 1;
			continue;
    }
		//cprintf("moving: q[]")
    if(move == 1 && i < NPROC-1)
      q.proc[pri][i] = q.proc[pri][i+1];
    if(move == 1 && i == NPROC-1)
      q.proc[pri][i] = 0;
  }
	//printq();
  //release(&q.lock);
  return 0;
}
// end

void
pinit(void)
{
  initlock(&ptable.lock, "ptable");
  // initlock for q?
  //initlock(&q.lock, "q");
}

// Must be called with interrupts disabled
int
cpuid() {
  return mycpu()-cpus;
}

// Must be called with interrupts disabled to avoid the caller being
// rescheduled between reading lapicid and running through the loop.
struct cpu*
mycpu(void)
{
  int apicid, i;
  
  if(readeflags()&FL_IF)
    panic("mycpu called with interrupts enabled\n");
  
  apicid = lapicid();
  // APIC IDs are not guaranteed to be contiguous. Maybe we should have
  // a reverse map, or reserve a register to store &cpus[i].
  for (i = 0; i < ncpu; ++i) {
    if (cpus[i].apicid == apicid)
      return &cpus[i];
  }
  panic("unknown apicid\n");
}

// Disable interrupts so that we are not rescheduled
// while reading proc from the cpu structure
struct proc*
myproc(void) {
  struct cpu *c;
  struct proc *p;
  pushcli();
  c = mycpu();
  p = c->proc;
  popcli();
  return p;
}

// Look in the process table for an UNUSED proc.
// If found, change state to EMBRYO and initialize
// state required to run in the kernel.
// Otherwise return 0.
static struct proc*
allocproc(void)
{
  struct proc *p;
  char *sp;

  acquire(&ptable.lock);

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == UNUSED)
      goto found;

  release(&ptable.lock);
  return 0;

found:
  p->state = EMBRYO;
  p->pid = nextpid++;

  // set features for the proc (p4)
  if(p->parent == 0) { //NULL
    p->pri = 3;  // Default priority is 3 (p4)
  } else {
    p->pri = p->parent->pri;  // set to its parent's priority
  }
	// add to back of queue
	addproc(p->pri, p);
	//p->qtail[p->pri] = 1;  // first time of adding to back
  // testing (p4)
  //cprintf("A NEW PROC ALLOCATED\n");

  release(&ptable.lock);

  // Allocate kernel stack.
  if((p->kstack = kalloc()) == 0){
    p->state = UNUSED;
    return 0;
  }
  sp = p->kstack + KSTACKSIZE;

  // Leave room for trap frame.
  sp -= sizeof *p->tf;
  p->tf = (struct trapframe*)sp;

  // Set up new context to start executing at forkret,
  // which returns to trapret.
  sp -= 4;
  *(uint*)sp = (uint)trapret;

  sp -= sizeof *p->context;
  p->context = (struct context*)sp;
  memset(p->context, 0, sizeof *p->context);
  p->context->eip = (uint)forkret;

  return p;
}

// Set up first user process.
void
userinit(void)
{
  //cprintf("USERINIT\n");//
  struct proc *p;
  extern char _binary_initcode_start[], _binary_initcode_size[];

  p = allocproc();
  
  initproc = p;
  if((p->pgdir = setupkvm()) == 0)
    panic("userinit: out of memory?");
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
  p->sz = PGSIZE;
  memset(p->tf, 0, sizeof(*p->tf));
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
  p->tf->es = p->tf->ds;
  p->tf->ss = p->tf->ds;
  p->tf->eflags = FL_IF;
  p->tf->esp = PGSIZE;
  p->tf->eip = 0;  // beginning of initcode.S

  safestrcpy(p->name, "initcode", sizeof(p->name));
  p->cwd = namei("/");

  // this assignment to p->state lets other cores
  // run this process. the acquire forces the above
  // writes to be visible, and the lock is also needed
  // because the assignment might not be atomic.
  acquire(&ptable.lock);

  p->state = RUNNABLE;

  release(&ptable.lock);
}

// Grow current process's memory by n bytes.
// Return 0 on success, -1 on failure.
int
growproc(int n)
{
  uint sz;
  struct proc *curproc = myproc();

  sz = curproc->sz;
  if(n > 0){
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  } else if(n < 0){
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
      return -1;
  }
  curproc->sz = sz;
  switchuvm(curproc);
  return 0;
}

// Create a new process copying p as the parent.
// Sets up stack to return as if from system call.
// Caller must set state of returned proc to RUNNABLE.
int
fork(void)
{
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;

  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);

  safestrcpy(np->name, curproc->name, sizeof(curproc->name));

  pid = np->pid;

  acquire(&ptable.lock);

  np->state = RUNNABLE;

  release(&ptable.lock);

  return pid;
}

// Exit the current process.  Does not return.
// An exited process remains in the zombie state
// until its parent calls wait() to find out it exited.
void
exit(void)
{
  struct proc *curproc = myproc();
  struct proc *p;
  int fd;

  if(curproc == initproc)
    panic("init exiting");

  // Close all open files.
  for(fd = 0; fd < NOFILE; fd++){
    if(curproc->ofile[fd]){
      fileclose(curproc->ofile[fd]);
      curproc->ofile[fd] = 0;
    }
  }

  begin_op();
  iput(curproc->cwd);
  end_op();
  curproc->cwd = 0;

  acquire(&ptable.lock);

  // remove proc from queue (p4) -- not sure
  //cprintf("proc %d removed when exiting\n", curproc->pid);
  removefromq(curproc->pri, curproc->pid);

  // Parent might be sleeping in wait().
  wakeup1(curproc->parent);

  // Pass abandoned children to init.
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->parent == curproc){
      p->parent = initproc;
      if(p->state == ZOMBIE)
        wakeup1(initproc);
    }
  }

  // Jump into the scheduler, never to return.
  curproc->state = ZOMBIE;
  sched();
  panic("zombie exit");
}

// Wait for a child process to exit and return its pid.
// Return -1 if this process has no children.
int
wait(void)
{
  struct proc *p;
  int havekids, pid;
  struct proc *curproc = myproc();
  
  acquire(&ptable.lock);
  for(;;){
    // Scan through table looking for exited children.
    havekids = 0;
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
      if(p->parent != curproc)
        continue;
      havekids = 1;
      if(p->state == ZOMBIE){
        // Found one.
        pid = p->pid;
        kfree(p->kstack);
        p->kstack = 0;
        freevm(p->pgdir);
        p->pid = 0;
        p->parent = 0;
        p->name[0] = 0;
        p->killed = 0;
        p->state = UNUSED;
        release(&ptable.lock);
        return pid;
      }
    }

    // No point waiting if we don't have any children.
    if(!havekids || curproc->killed){
      release(&ptable.lock);
      return -1;
    }

    // Wait for children to exit.  (See wakeup1 call in proc_exit.)
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
  }
}

// Per-CPU process scheduler.
// Each CPU calls scheduler() after setting itself up.
// Scheduler never returns.  It loops, doing:
//  - choose a process to run
//  - swtch to start running that process
//  - eventually that process transfers control
//      via swtch back to the scheduler.
void
scheduler(void)
{
  struct proc *p;
  struct cpu *c = mycpu();
  c->proc = 0;
  // timeslice of each priority
  int timeslice[4] = {8, 12, 16, 20};
  
  for(;;){
    // Enable interrupts on this processor.
    sti();

		// use lock to protect
		//struct spinlock lk;
    
		//initlock(&q.lock, "q");
    acquire(&ptable.lock);
		//acquire(&lk);
    for(int i = 3; i >= 0; i--) {  // pri lvl
      for(int j = 0; j < NPROC; j++) {
        p = q.proc[i][j];
				//if(p->state == RUNNABLE) cprintf("Scheduler: found 1 runnable\n");
        if(p != 0 && p->state == RUNNABLE) {
					//cprintf("Scheduler: p = q[%d][%d]: p!=0 && p->state==RUNNABLE\n", i, j);
          //cprintf("p = %d\n", p);
					//cprintf("p->runtime[%d] = %d\n", i, p->runtime[i]);
					
          // switch to user lvl
          c->proc = p;
          switchuvm(p);
          p->state = RUNNING;
          swtch(&(c->scheduler), p->context);
          switchkvm();
          c->proc = 0;

          // clear runtime for proc
          if(p->runtime[i] == timeslice[i]) {
            p->runtime[i] = 0;
            //q[i][j]->qtail[i]++;
            removefromq(i, p->pid);
            addproc(i, p);
						//p->qtail[p->pri]++;  // update qtail
          } else {
						//cprintf("runtime++\n");
						p->runtime[i]++;
					}
					//go to next round
					goto finish;
        }
      }
    }
finish:
		//release(&lk);
    //printq(); //
    release(&ptable.lock);
  }
}

// Enter scheduler.  Must hold only ptable.lock
// and have changed proc->state. Saves and restores
// intena because intena is a property of this
// kernel thread, not this CPU. It should
// be proc->intena and proc->ncli, but that would
// break in the few places where a lock is held but
// there's no process.
void
sched(void)
{
  int intena;
  struct proc *p = myproc();

  if(!holding(&ptable.lock))
    panic("sched ptable.lock");
  if(mycpu()->ncli != 1)
    panic("sched locks");
  if(p->state == RUNNING)
    panic("sched running");
  if(readeflags()&FL_IF)
    panic("sched interruptible");
  intena = mycpu()->intena;
  swtch(&p->context, mycpu()->scheduler);
  mycpu()->intena = intena;
}

// Give up the CPU for one scheduling round.
void
yield(void)
{
  acquire(&ptable.lock);  //DOC: yieldlock
  myproc()->state = RUNNABLE;
  sched();
  release(&ptable.lock);
}

// A fork child's very first scheduling by scheduler()
// will swtch here.  "Return" to user space.
void
forkret(void)
{
  static int first = 1;
  // Still holding ptable.lock from scheduler.
  release(&ptable.lock);

  if (first) {
    // Some initialization functions must be run in the context
    // of a regular process (e.g., they call sleep), and thus cannot
    // be run from main().
    first = 0;
    iinit(ROOTDEV);
    initlog(ROOTDEV);
  }

  // Return to "caller", actually trapret (see allocproc).
}

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
  struct proc *p = myproc();
  
  if(p == 0)
    panic("sleep");

  if(lk == 0)
    panic("sleep without lk");

  // Must acquire ptable.lock in order to
  // change p->state and then call sched.
  // Once we hold ptable.lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup runs with ptable.lock locked),
  // so it's okay to release lk.
  if(lk != &ptable.lock){  //DOC: sleeplock0
    acquire(&ptable.lock);  //DOC: sleeplock1
    release(lk);
  }
  // Go to sleep.
  p->chan = chan;
  p->state = SLEEPING;

  sched();

  // Tidy up.
  p->chan = 0;

  // Reacquire original lock.
  if(lk != &ptable.lock){  //DOC: sleeplock2
    release(&ptable.lock);
    acquire(lk);
  }
}

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
    if(p->state == SLEEPING && p->chan == chan)
      p->state = RUNNABLE;
}

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
  acquire(&ptable.lock);
  wakeup1(chan);
  release(&ptable.lock);
}

// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
  struct proc *p;

  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid){
      // remove from queue when killed (p4) - not sure
      //cprintf("proc %d removed when killed\n", pid);
      removefromq(p->pri, pid);

      p->killed = 1;
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
        p->state = RUNNABLE;
      release(&ptable.lock);
      return 0;
    }
  }
  release(&ptable.lock);
  return -1;
}

// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
  static char *states[] = {
  [UNUSED]    "unused",
  [EMBRYO]    "embryo",
  [SLEEPING]  "sleep ",
  [RUNNABLE]  "runble",
  [RUNNING]   "run   ",
  [ZOMBIE]    "zombie"
  };
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
    cprintf("%d %s %s", p->pid, state, p->name);
    if(p->state == SLEEPING){
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
  }

  
}

// funcs for syscalls (p4)
int setpri(int pid, int pri) {
  struct proc* p;
  //cprintf(" setpri(%d, %d):\n", pid, pri);
	//acquire(&ptable.lock);
  
	for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == pid) {
      // remove p
      removefromq(p->pri, pid);
      // change features
      //p->pri = pri;
      
			// add p
      addproc(pri, p);

      //release(&ptable.lock);
      return 0;
    }
  }
  //release(&ptable.lock);
  return -1;
}

int getpri(int PID)
{
	struct proc* p;
  acquire(&ptable.lock);
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
    if(p->pid == PID) {
      release(&ptable.lock);
      return p->pri;
    }
  }
  release(&ptable.lock);
  return -1;
}

int getpinfo(struct pstat* pstates)
{
	//cprintf("getpinfo: welcome to getpinfo in proc.c\n");
	struct proc* p;
  acquire(&ptable.lock);
	//cprintf("getpinfo: just used lock\n");
  // inuse
	int i = 0;
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++) {
    //int i = p->pid;
		if(p->state == SLEEPING || p->state == RUNNABLE || p->state == RUNNING) {
			//cprintf("getpinfo: proc %d is inuse\n", i);
			//cprintf("pstates->inuse[%d]: %d\n", i, pstates->inuse[i]);
			pstates->inuse[i] = 1;
			//cprintf("getpinfo: adjusted pstates->inuse\n");
			
			//cprintf("getpinfo: \n");
    	pstates->pid[i] = p->pid;
    	pstates->priority[i] = p->pri;
    	pstates->state[i] = p->state;
    	for(int j = 0; j < 4; j++) {
    	  pstates->ticks[i][j] = p->runtime[j];
  	    pstates->qtail[i][j] = p->qtail[j];
	    }

		}
		// do I need record info for unused proc?
		/*cprintf("getpinfo: \n");
    pstates->pid[i] = p->pid;
    pstates->priority[i] = p->pri;
    pstates->state[i] = p->state;
    for(int j = 0; j < 4; j++) {
			pstates->ticks[i][j] = p->runtime[j];
    	pstates->qtail[i][j] = p->qtail[j];
		}*/
		i++;
  }
	release(&ptable.lock);
  return 0;
}

int fork2(int pri) {
  int i, pid;
  struct proc *np;
  struct proc *curproc = myproc();

  // Allocate process.
  if((np = allocproc()) == 0){
    return -1;
  }

  // Copy process state from proc.
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
    kfree(np->kstack);
    np->kstack = 0;
    np->state = UNUSED;
    return -1;
  }
  np->sz = curproc->sz;
  np->parent = curproc;
  *np->tf = *curproc->tf;

  // Clear %eax so that fork returns 0 in the child.
  np->tf->eax = 0;
  for(i = 0; i < NOFILE; i++)
    if(curproc->ofile[i])
      np->ofile[i] = filedup(curproc->ofile[i]);
  np->cwd = idup(curproc->cwd);
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
  pid = np->pid;
  acquire(&ptable.lock);
  np->state = RUNNABLE;

  // reset the new proc's priority -not sure whether affect the queues (p4)
  setpri(np->pid, pri);

  release(&ptable.lock);

  return pid;
}
