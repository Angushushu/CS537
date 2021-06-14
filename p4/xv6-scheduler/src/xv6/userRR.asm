
_userRR:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
//#include "stat.h"
#include "user.h"
#include "pstat.h"
//#include "proc.h"

int main(int argc, char** argv) {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	81 ec 28 0c 00 00    	sub    $0xc28,%esp
  17:	8b 59 04             	mov    0x4(%ecx),%ebx
    char* job;
    int jobcnt = 0;
    
//		printf(0, "-> welcome to userRR.c: PID = %d\n", getpid());

		if(argc != 5) {
  1a:	83 39 05             	cmpl   $0x5,(%ecx)
  1d:	74 05                	je     24 <main+0x24>
        exit();
  1f:	e8 88 03 00 00       	call   3ac <exit>
    }
    timeslice = atoi(argv[1]);
  24:	83 ec 0c             	sub    $0xc,%esp
  27:	ff 73 04             	pushl  0x4(%ebx)
  2a:	e8 1f 03 00 00       	call   34e <atoi>
  2f:	89 85 cc f3 ff ff    	mov    %eax,-0xc34(%ebp)
    iterations = atoi(argv[2]);
  35:	83 c4 04             	add    $0x4,%esp
  38:	ff 73 08             	pushl  0x8(%ebx)
  3b:	e8 0e 03 00 00       	call   34e <atoi>
  40:	89 85 d4 f3 ff ff    	mov    %eax,-0xc2c(%ebp)
    job = argv[3];
  46:	8b 7b 0c             	mov    0xc(%ebx),%edi
    jobcnt = atoi(argv[4]);
  49:	83 c4 04             	add    $0x4,%esp
  4c:	ff 73 10             	pushl  0x10(%ebx)
  4f:	e8 fa 02 00 00       	call   34e <atoi>
  54:	89 c2                	mov    %eax,%edx
  56:	89 85 d0 f3 ff ff    	mov    %eax,-0xc30(%ebp)
    int jobs[jobcnt];
  5c:	8d 04 85 12 00 00 00 	lea    0x12(,%eax,4),%eax
  63:	83 e0 f0             	and    $0xfffffff0,%eax
  66:	83 c4 10             	add    $0x10,%esp
  69:	29 c4                	sub    %eax,%esp
  6b:	89 e6                	mov    %esp,%esi
		printf(0, "  RR[%d]: iterations = %d\n", getpid(), iterations);
		printf(0, "  RR[%d]: job = %s\n", getpid(), job);
		printf(0, "  RR[%d]: jobcnt = %d\n", getpid(), jobcnt);*/

    // initialize each proc
    for(int i = 0; i < jobcnt; i++) {
  6d:	bb 00 00 00 00       	mov    $0x0,%ebx
  72:	89 bd c8 f3 ff ff    	mov    %edi,-0xc38(%ebp)
  78:	89 d7                	mov    %edx,%edi
  7a:	eb 25                	jmp    a1 <main+0xa1>
  //      printf(0, "RR[%d]: fork job %d\n", getpid(), i);
        int retpid = fork2(0);
        if(retpid == 0) {
						char* argn = "0";            
  7c:	c7 85 e4 f3 ff ff c0 	movl   $0x7c0,-0xc1c(%ebp)
  83:	07 00 00 
						exec(job, &argn);
  86:	83 ec 08             	sub    $0x8,%esp
  89:	8d 85 e4 f3 ff ff    	lea    -0xc1c(%ebp),%eax
  8f:	50                   	push   %eax
  90:	ff b5 c8 f3 ff ff    	pushl  -0xc38(%ebp)
  96:	e8 49 03 00 00       	call   3e4 <exec>
  9b:	83 c4 10             	add    $0x10,%esp
    for(int i = 0; i < jobcnt; i++) {
  9e:	83 c3 01             	add    $0x1,%ebx
  a1:	39 fb                	cmp    %edi,%ebx
  a3:	7d 16                	jge    bb <main+0xbb>
        int retpid = fork2(0);
  a5:	83 ec 0c             	sub    $0xc,%esp
  a8:	6a 00                	push   $0x0
  aa:	e8 ad 03 00 00       	call   45c <fork2>
        if(retpid == 0) {
  af:	83 c4 10             	add    $0x10,%esp
  b2:	85 c0                	test   %eax,%eax
  b4:	74 c6                	je     7c <main+0x7c>
						//printf(0, "  RR[%d]: A LOOP IS OVER! HOW CAN THIS BE POSSIBLE?\n", getpid());
        } else {
						//printf(0, "  RR[%d]: adding job %d\n", getpid(), i);
            jobs[i] = retpid;
  b6:	89 04 9e             	mov    %eax,(%esi,%ebx,4)
  b9:	eb e3                	jmp    9e <main+0x9e>
    		}
    }
		
		//printf(0, "  RR[%d]: start running proc\n", getpid());

    for(int i = 0; i < iterations; i++) { 
  bb:	bf 00 00 00 00       	mov    $0x0,%edi
  c0:	eb 56                	jmp    118 <main+0x118>
        // for each iteration, pick a proc to execute and put it back
		//		printf(0, "RR[%d]: %dth iteration:\n", getpid(), i);
				for(int j = 0; j < jobcnt; j++) {
  c2:	83 c3 01             	add    $0x1,%ebx
  c5:	3b 9d d0 f3 ff ff    	cmp    -0xc30(%ebp),%ebx
  cb:	7d 48                	jge    115 <main+0x115>
			//			printf(0, "RR[%d]: call setpri(jobs[%d] (pid = %d), 2)\n", getpid(), j, jobs[j]);
            setpri(jobs[j], 2);
  cd:	83 ec 08             	sub    $0x8,%esp
  d0:	6a 02                	push   $0x2
  d2:	ff 34 9e             	pushl  (%esi,%ebx,4)
  d5:	e8 72 03 00 00       	call   44c <setpri>
        //    printf(0, "setpri return %d\n", retv);
            sleep(timeslice);
  da:	83 c4 04             	add    $0x4,%esp
  dd:	ff b5 cc f3 ff ff    	pushl  -0xc34(%ebp)
  e3:	e8 54 03 00 00       	call   43c <sleep>
          //  printf(0, "RR[%d]: call setpri(jobs[%d] (pid = %d), 0)\n", getpid(), j, jobs[j]);
						setpri(jobs[j], 0);
  e8:	83 c4 08             	add    $0x8,%esp
  eb:	6a 00                	push   $0x0
  ed:	ff 34 9e             	pushl  (%esi,%ebx,4)
  f0:	e8 57 03 00 00       	call   44c <setpri>
            //printf(0, "RR[%d]: setpri return %d\n", retv);
						// kill jobs after the last iteration
						if(i == iterations - 1) {
  f5:	8b 85 d4 f3 ff ff    	mov    -0xc2c(%ebp),%eax
  fb:	83 e8 01             	sub    $0x1,%eax
  fe:	83 c4 10             	add    $0x10,%esp
 101:	39 c7                	cmp    %eax,%edi
 103:	75 bd                	jne    c2 <main+0xc2>
							//printf(0, "  RR[%d]: killing job %d\n", getpid(), j);
							kill(jobs[j]);
 105:	83 ec 0c             	sub    $0xc,%esp
 108:	ff 34 9e             	pushl  (%esi,%ebx,4)
 10b:	e8 cc 02 00 00       	call   3dc <kill>
 110:	83 c4 10             	add    $0x10,%esp
 113:	eb ad                	jmp    c2 <main+0xc2>
    for(int i = 0; i < iterations; i++) { 
 115:	83 c7 01             	add    $0x1,%edi
 118:	3b bd d4 f3 ff ff    	cmp    -0xc2c(%ebp),%edi
 11e:	7d 07                	jge    127 <main+0x127>
				for(int j = 0; j < jobcnt; j++) {
 120:	bb 00 00 00 00       	mov    $0x0,%ebx
 125:	eb 9e                	jmp    c5 <main+0xc5>
		//printf(0, "  RR[%d]: printing pstat\n", getpid());
		
    // print out pstat
    struct pstat pstates;
		// how to lock in user level?
    getpinfo(&pstates);
 127:	83 ec 0c             	sub    $0xc,%esp
 12a:	8d 85 e8 f3 ff ff    	lea    -0xc18(%ebp),%eax
 130:	50                   	push   %eax
 131:	e8 2e 03 00 00       	call   464 <getpinfo>
    for(int i = 0; i < NPROC; i++) {
 136:	83 c4 10             	add    $0x10,%esp
 139:	bb 00 00 00 00       	mov    $0x0,%ebx
 13e:	eb 56                	jmp    196 <main+0x196>
        printf(0, " inuse: %d \n", pstates.inuse[i]);
        printf(0, " pid: %d \n", pstates.pid[i]);
				printf(0, " priority: %d \n", pstates.priority[i]);
        printf(0, " state: %s \n", pstates.state[i]);
        for(int j = 0; j < 4; j++) {
            printf(0, " ticks of lvl %d: %d \n", j, pstates.ticks[i][j]);
 140:	8d 84 9e 00 01 00 00 	lea    0x100(%esi,%ebx,4),%eax
 147:	ff b4 85 e8 f3 ff ff 	pushl  -0xc18(%ebp,%eax,4)
 14e:	56                   	push   %esi
 14f:	68 0f 08 00 00       	push   $0x80f
 154:	6a 00                	push   $0x0
 156:	e8 ab 03 00 00       	call   506 <printf>
        for(int j = 0; j < 4; j++) {
 15b:	83 c6 01             	add    $0x1,%esi
 15e:	83 c4 10             	add    $0x10,%esp
 161:	83 fe 03             	cmp    $0x3,%esi
 164:	7e da                	jle    140 <main+0x140>
        }
				for(int j = 0; j < 4; j++) {
 166:	be 00 00 00 00       	mov    $0x0,%esi
 16b:	eb 21                	jmp    18e <main+0x18e>
						printf(0, " qtail of lvl %d: %d \n", j, pstates.qtail[i][j]);
 16d:	8d 84 9e 00 02 00 00 	lea    0x200(%esi,%ebx,4),%eax
 174:	ff b4 85 e8 f3 ff ff 	pushl  -0xc18(%ebp,%eax,4)
 17b:	56                   	push   %esi
 17c:	68 26 08 00 00       	push   $0x826
 181:	6a 00                	push   $0x0
 183:	e8 7e 03 00 00       	call   506 <printf>
				for(int j = 0; j < 4; j++) {
 188:	83 c6 01             	add    $0x1,%esi
 18b:	83 c4 10             	add    $0x10,%esp
 18e:	83 fe 03             	cmp    $0x3,%esi
 191:	7e da                	jle    16d <main+0x16d>
    for(int i = 0; i < NPROC; i++) {
 193:	83 c3 01             	add    $0x1,%ebx
 196:	83 fb 3f             	cmp    $0x3f,%ebx
 199:	7f 7f                	jg     21a <main+0x21a>
				if(pstates.inuse[i] != 1)
 19b:	83 bc 9d e8 f3 ff ff 	cmpl   $0x1,-0xc18(%ebp,%ebx,4)
 1a2:	01 
 1a3:	75 ee                	jne    193 <main+0x193>
        printf(0, ">> %d's proc in ptable\n", i);
 1a5:	83 ec 04             	sub    $0x4,%esp
 1a8:	53                   	push   %ebx
 1a9:	68 c2 07 00 00       	push   $0x7c2
 1ae:	6a 00                	push   $0x0
 1b0:	e8 51 03 00 00       	call   506 <printf>
        printf(0, " inuse: %d \n", pstates.inuse[i]);
 1b5:	83 c4 0c             	add    $0xc,%esp
 1b8:	ff b4 9d e8 f3 ff ff 	pushl  -0xc18(%ebp,%ebx,4)
 1bf:	68 da 07 00 00       	push   $0x7da
 1c4:	6a 00                	push   $0x0
 1c6:	e8 3b 03 00 00       	call   506 <printf>
        printf(0, " pid: %d \n", pstates.pid[i]);
 1cb:	83 c4 0c             	add    $0xc,%esp
 1ce:	ff b4 9d e8 f4 ff ff 	pushl  -0xb18(%ebp,%ebx,4)
 1d5:	68 e7 07 00 00       	push   $0x7e7
 1da:	6a 00                	push   $0x0
 1dc:	e8 25 03 00 00       	call   506 <printf>
				printf(0, " priority: %d \n", pstates.priority[i]);
 1e1:	83 c4 0c             	add    $0xc,%esp
 1e4:	ff b4 9d e8 f5 ff ff 	pushl  -0xa18(%ebp,%ebx,4)
 1eb:	68 f2 07 00 00       	push   $0x7f2
 1f0:	6a 00                	push   $0x0
 1f2:	e8 0f 03 00 00       	call   506 <printf>
        printf(0, " state: %s \n", pstates.state[i]);
 1f7:	83 c4 0c             	add    $0xc,%esp
 1fa:	ff b4 9d e8 f6 ff ff 	pushl  -0x918(%ebp,%ebx,4)
 201:	68 02 08 00 00       	push   $0x802
 206:	6a 00                	push   $0x0
 208:	e8 f9 02 00 00       	call   506 <printf>
        for(int j = 0; j < 4; j++) {
 20d:	83 c4 10             	add    $0x10,%esp
 210:	be 00 00 00 00       	mov    $0x0,%esi
 215:	e9 47 ff ff ff       	jmp    161 <main+0x161>
				}
    }

    exit();
 21a:	e8 8d 01 00 00       	call   3ac <exit>

0000021f <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 21f:	55                   	push   %ebp
 220:	89 e5                	mov    %esp,%ebp
 222:	53                   	push   %ebx
 223:	8b 45 08             	mov    0x8(%ebp),%eax
 226:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 229:	89 c2                	mov    %eax,%edx
 22b:	0f b6 19             	movzbl (%ecx),%ebx
 22e:	88 1a                	mov    %bl,(%edx)
 230:	8d 52 01             	lea    0x1(%edx),%edx
 233:	8d 49 01             	lea    0x1(%ecx),%ecx
 236:	84 db                	test   %bl,%bl
 238:	75 f1                	jne    22b <strcpy+0xc>
    ;
  return os;
}
 23a:	5b                   	pop    %ebx
 23b:	5d                   	pop    %ebp
 23c:	c3                   	ret    

0000023d <strcmp>:

int
strcmp(const char *p, const char *q)
{
 23d:	55                   	push   %ebp
 23e:	89 e5                	mov    %esp,%ebp
 240:	8b 4d 08             	mov    0x8(%ebp),%ecx
 243:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 246:	eb 06                	jmp    24e <strcmp+0x11>
    p++, q++;
 248:	83 c1 01             	add    $0x1,%ecx
 24b:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 24e:	0f b6 01             	movzbl (%ecx),%eax
 251:	84 c0                	test   %al,%al
 253:	74 04                	je     259 <strcmp+0x1c>
 255:	3a 02                	cmp    (%edx),%al
 257:	74 ef                	je     248 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 259:	0f b6 c0             	movzbl %al,%eax
 25c:	0f b6 12             	movzbl (%edx),%edx
 25f:	29 d0                	sub    %edx,%eax
}
 261:	5d                   	pop    %ebp
 262:	c3                   	ret    

00000263 <strlen>:

uint
strlen(const char *s)
{
 263:	55                   	push   %ebp
 264:	89 e5                	mov    %esp,%ebp
 266:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 269:	ba 00 00 00 00       	mov    $0x0,%edx
 26e:	eb 03                	jmp    273 <strlen+0x10>
 270:	83 c2 01             	add    $0x1,%edx
 273:	89 d0                	mov    %edx,%eax
 275:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 279:	75 f5                	jne    270 <strlen+0xd>
    ;
  return n;
}
 27b:	5d                   	pop    %ebp
 27c:	c3                   	ret    

0000027d <memset>:

void*
memset(void *dst, int c, uint n)
{
 27d:	55                   	push   %ebp
 27e:	89 e5                	mov    %esp,%ebp
 280:	57                   	push   %edi
 281:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 284:	89 d7                	mov    %edx,%edi
 286:	8b 4d 10             	mov    0x10(%ebp),%ecx
 289:	8b 45 0c             	mov    0xc(%ebp),%eax
 28c:	fc                   	cld    
 28d:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 28f:	89 d0                	mov    %edx,%eax
 291:	5f                   	pop    %edi
 292:	5d                   	pop    %ebp
 293:	c3                   	ret    

00000294 <strchr>:

char*
strchr(const char *s, char c)
{
 294:	55                   	push   %ebp
 295:	89 e5                	mov    %esp,%ebp
 297:	8b 45 08             	mov    0x8(%ebp),%eax
 29a:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 29e:	0f b6 10             	movzbl (%eax),%edx
 2a1:	84 d2                	test   %dl,%dl
 2a3:	74 09                	je     2ae <strchr+0x1a>
    if(*s == c)
 2a5:	38 ca                	cmp    %cl,%dl
 2a7:	74 0a                	je     2b3 <strchr+0x1f>
  for(; *s; s++)
 2a9:	83 c0 01             	add    $0x1,%eax
 2ac:	eb f0                	jmp    29e <strchr+0xa>
      return (char*)s;
  return 0;
 2ae:	b8 00 00 00 00       	mov    $0x0,%eax
}
 2b3:	5d                   	pop    %ebp
 2b4:	c3                   	ret    

000002b5 <gets>:

char*
gets(char *buf, int max)
{
 2b5:	55                   	push   %ebp
 2b6:	89 e5                	mov    %esp,%ebp
 2b8:	57                   	push   %edi
 2b9:	56                   	push   %esi
 2ba:	53                   	push   %ebx
 2bb:	83 ec 1c             	sub    $0x1c,%esp
 2be:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 2c1:	bb 00 00 00 00       	mov    $0x0,%ebx
 2c6:	8d 73 01             	lea    0x1(%ebx),%esi
 2c9:	3b 75 0c             	cmp    0xc(%ebp),%esi
 2cc:	7d 2e                	jge    2fc <gets+0x47>
    cc = read(0, &c, 1);
 2ce:	83 ec 04             	sub    $0x4,%esp
 2d1:	6a 01                	push   $0x1
 2d3:	8d 45 e7             	lea    -0x19(%ebp),%eax
 2d6:	50                   	push   %eax
 2d7:	6a 00                	push   $0x0
 2d9:	e8 e6 00 00 00       	call   3c4 <read>
    if(cc < 1)
 2de:	83 c4 10             	add    $0x10,%esp
 2e1:	85 c0                	test   %eax,%eax
 2e3:	7e 17                	jle    2fc <gets+0x47>
      break;
    buf[i++] = c;
 2e5:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 2e9:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 2ec:	3c 0a                	cmp    $0xa,%al
 2ee:	0f 94 c2             	sete   %dl
 2f1:	3c 0d                	cmp    $0xd,%al
 2f3:	0f 94 c0             	sete   %al
    buf[i++] = c;
 2f6:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 2f8:	08 c2                	or     %al,%dl
 2fa:	74 ca                	je     2c6 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 2fc:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 300:	89 f8                	mov    %edi,%eax
 302:	8d 65 f4             	lea    -0xc(%ebp),%esp
 305:	5b                   	pop    %ebx
 306:	5e                   	pop    %esi
 307:	5f                   	pop    %edi
 308:	5d                   	pop    %ebp
 309:	c3                   	ret    

0000030a <stat>:

int
stat(const char *n, struct stat *st)
{
 30a:	55                   	push   %ebp
 30b:	89 e5                	mov    %esp,%ebp
 30d:	56                   	push   %esi
 30e:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 30f:	83 ec 08             	sub    $0x8,%esp
 312:	6a 00                	push   $0x0
 314:	ff 75 08             	pushl  0x8(%ebp)
 317:	e8 d0 00 00 00       	call   3ec <open>
  if(fd < 0)
 31c:	83 c4 10             	add    $0x10,%esp
 31f:	85 c0                	test   %eax,%eax
 321:	78 24                	js     347 <stat+0x3d>
 323:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 325:	83 ec 08             	sub    $0x8,%esp
 328:	ff 75 0c             	pushl  0xc(%ebp)
 32b:	50                   	push   %eax
 32c:	e8 d3 00 00 00       	call   404 <fstat>
 331:	89 c6                	mov    %eax,%esi
  close(fd);
 333:	89 1c 24             	mov    %ebx,(%esp)
 336:	e8 99 00 00 00       	call   3d4 <close>
  return r;
 33b:	83 c4 10             	add    $0x10,%esp
}
 33e:	89 f0                	mov    %esi,%eax
 340:	8d 65 f8             	lea    -0x8(%ebp),%esp
 343:	5b                   	pop    %ebx
 344:	5e                   	pop    %esi
 345:	5d                   	pop    %ebp
 346:	c3                   	ret    
    return -1;
 347:	be ff ff ff ff       	mov    $0xffffffff,%esi
 34c:	eb f0                	jmp    33e <stat+0x34>

0000034e <atoi>:

int
atoi(const char *s)
{
 34e:	55                   	push   %ebp
 34f:	89 e5                	mov    %esp,%ebp
 351:	53                   	push   %ebx
 352:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 355:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 35a:	eb 10                	jmp    36c <atoi+0x1e>
    n = n*10 + *s++ - '0';
 35c:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 35f:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 362:	83 c1 01             	add    $0x1,%ecx
 365:	0f be d2             	movsbl %dl,%edx
 368:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 36c:	0f b6 11             	movzbl (%ecx),%edx
 36f:	8d 5a d0             	lea    -0x30(%edx),%ebx
 372:	80 fb 09             	cmp    $0x9,%bl
 375:	76 e5                	jbe    35c <atoi+0xe>
  return n;
}
 377:	5b                   	pop    %ebx
 378:	5d                   	pop    %ebp
 379:	c3                   	ret    

0000037a <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 37a:	55                   	push   %ebp
 37b:	89 e5                	mov    %esp,%ebp
 37d:	56                   	push   %esi
 37e:	53                   	push   %ebx
 37f:	8b 45 08             	mov    0x8(%ebp),%eax
 382:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 385:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 388:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 38a:	eb 0d                	jmp    399 <memmove+0x1f>
    *dst++ = *src++;
 38c:	0f b6 13             	movzbl (%ebx),%edx
 38f:	88 11                	mov    %dl,(%ecx)
 391:	8d 5b 01             	lea    0x1(%ebx),%ebx
 394:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 397:	89 f2                	mov    %esi,%edx
 399:	8d 72 ff             	lea    -0x1(%edx),%esi
 39c:	85 d2                	test   %edx,%edx
 39e:	7f ec                	jg     38c <memmove+0x12>
  return vdst;
}
 3a0:	5b                   	pop    %ebx
 3a1:	5e                   	pop    %esi
 3a2:	5d                   	pop    %ebp
 3a3:	c3                   	ret    

000003a4 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 3a4:	b8 01 00 00 00       	mov    $0x1,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <exit>:
SYSCALL(exit)
 3ac:	b8 02 00 00 00       	mov    $0x2,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <wait>:
SYSCALL(wait)
 3b4:	b8 03 00 00 00       	mov    $0x3,%eax
 3b9:	cd 40                	int    $0x40
 3bb:	c3                   	ret    

000003bc <pipe>:
SYSCALL(pipe)
 3bc:	b8 04 00 00 00       	mov    $0x4,%eax
 3c1:	cd 40                	int    $0x40
 3c3:	c3                   	ret    

000003c4 <read>:
SYSCALL(read)
 3c4:	b8 05 00 00 00       	mov    $0x5,%eax
 3c9:	cd 40                	int    $0x40
 3cb:	c3                   	ret    

000003cc <write>:
SYSCALL(write)
 3cc:	b8 10 00 00 00       	mov    $0x10,%eax
 3d1:	cd 40                	int    $0x40
 3d3:	c3                   	ret    

000003d4 <close>:
SYSCALL(close)
 3d4:	b8 15 00 00 00       	mov    $0x15,%eax
 3d9:	cd 40                	int    $0x40
 3db:	c3                   	ret    

000003dc <kill>:
SYSCALL(kill)
 3dc:	b8 06 00 00 00       	mov    $0x6,%eax
 3e1:	cd 40                	int    $0x40
 3e3:	c3                   	ret    

000003e4 <exec>:
SYSCALL(exec)
 3e4:	b8 07 00 00 00       	mov    $0x7,%eax
 3e9:	cd 40                	int    $0x40
 3eb:	c3                   	ret    

000003ec <open>:
SYSCALL(open)
 3ec:	b8 0f 00 00 00       	mov    $0xf,%eax
 3f1:	cd 40                	int    $0x40
 3f3:	c3                   	ret    

000003f4 <mknod>:
SYSCALL(mknod)
 3f4:	b8 11 00 00 00       	mov    $0x11,%eax
 3f9:	cd 40                	int    $0x40
 3fb:	c3                   	ret    

000003fc <unlink>:
SYSCALL(unlink)
 3fc:	b8 12 00 00 00       	mov    $0x12,%eax
 401:	cd 40                	int    $0x40
 403:	c3                   	ret    

00000404 <fstat>:
SYSCALL(fstat)
 404:	b8 08 00 00 00       	mov    $0x8,%eax
 409:	cd 40                	int    $0x40
 40b:	c3                   	ret    

0000040c <link>:
SYSCALL(link)
 40c:	b8 13 00 00 00       	mov    $0x13,%eax
 411:	cd 40                	int    $0x40
 413:	c3                   	ret    

00000414 <mkdir>:
SYSCALL(mkdir)
 414:	b8 14 00 00 00       	mov    $0x14,%eax
 419:	cd 40                	int    $0x40
 41b:	c3                   	ret    

0000041c <chdir>:
SYSCALL(chdir)
 41c:	b8 09 00 00 00       	mov    $0x9,%eax
 421:	cd 40                	int    $0x40
 423:	c3                   	ret    

00000424 <dup>:
SYSCALL(dup)
 424:	b8 0a 00 00 00       	mov    $0xa,%eax
 429:	cd 40                	int    $0x40
 42b:	c3                   	ret    

0000042c <getpid>:
SYSCALL(getpid)
 42c:	b8 0b 00 00 00       	mov    $0xb,%eax
 431:	cd 40                	int    $0x40
 433:	c3                   	ret    

00000434 <sbrk>:
SYSCALL(sbrk)
 434:	b8 0c 00 00 00       	mov    $0xc,%eax
 439:	cd 40                	int    $0x40
 43b:	c3                   	ret    

0000043c <sleep>:
SYSCALL(sleep)
 43c:	b8 0d 00 00 00       	mov    $0xd,%eax
 441:	cd 40                	int    $0x40
 443:	c3                   	ret    

00000444 <uptime>:
SYSCALL(uptime)
 444:	b8 0e 00 00 00       	mov    $0xe,%eax
 449:	cd 40                	int    $0x40
 44b:	c3                   	ret    

0000044c <setpri>:
SYSCALL(setpri)
 44c:	b8 16 00 00 00       	mov    $0x16,%eax
 451:	cd 40                	int    $0x40
 453:	c3                   	ret    

00000454 <getpri>:
SYSCALL(getpri)
 454:	b8 17 00 00 00       	mov    $0x17,%eax
 459:	cd 40                	int    $0x40
 45b:	c3                   	ret    

0000045c <fork2>:
SYSCALL(fork2)
 45c:	b8 18 00 00 00       	mov    $0x18,%eax
 461:	cd 40                	int    $0x40
 463:	c3                   	ret    

00000464 <getpinfo>:
SYSCALL(getpinfo)
 464:	b8 19 00 00 00       	mov    $0x19,%eax
 469:	cd 40                	int    $0x40
 46b:	c3                   	ret    

0000046c <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 46c:	55                   	push   %ebp
 46d:	89 e5                	mov    %esp,%ebp
 46f:	83 ec 1c             	sub    $0x1c,%esp
 472:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 475:	6a 01                	push   $0x1
 477:	8d 55 f4             	lea    -0xc(%ebp),%edx
 47a:	52                   	push   %edx
 47b:	50                   	push   %eax
 47c:	e8 4b ff ff ff       	call   3cc <write>
}
 481:	83 c4 10             	add    $0x10,%esp
 484:	c9                   	leave  
 485:	c3                   	ret    

00000486 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 486:	55                   	push   %ebp
 487:	89 e5                	mov    %esp,%ebp
 489:	57                   	push   %edi
 48a:	56                   	push   %esi
 48b:	53                   	push   %ebx
 48c:	83 ec 2c             	sub    $0x2c,%esp
 48f:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 491:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 495:	0f 95 c3             	setne  %bl
 498:	89 d0                	mov    %edx,%eax
 49a:	c1 e8 1f             	shr    $0x1f,%eax
 49d:	84 c3                	test   %al,%bl
 49f:	74 10                	je     4b1 <printint+0x2b>
    neg = 1;
    x = -xx;
 4a1:	f7 da                	neg    %edx
    neg = 1;
 4a3:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 4aa:	be 00 00 00 00       	mov    $0x0,%esi
 4af:	eb 0b                	jmp    4bc <printint+0x36>
  neg = 0;
 4b1:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 4b8:	eb f0                	jmp    4aa <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 4ba:	89 c6                	mov    %eax,%esi
 4bc:	89 d0                	mov    %edx,%eax
 4be:	ba 00 00 00 00       	mov    $0x0,%edx
 4c3:	f7 f1                	div    %ecx
 4c5:	89 c3                	mov    %eax,%ebx
 4c7:	8d 46 01             	lea    0x1(%esi),%eax
 4ca:	0f b6 92 44 08 00 00 	movzbl 0x844(%edx),%edx
 4d1:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 4d5:	89 da                	mov    %ebx,%edx
 4d7:	85 db                	test   %ebx,%ebx
 4d9:	75 df                	jne    4ba <printint+0x34>
 4db:	89 c3                	mov    %eax,%ebx
  if(neg)
 4dd:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 4e1:	74 16                	je     4f9 <printint+0x73>
    buf[i++] = '-';
 4e3:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 4e8:	8d 5e 02             	lea    0x2(%esi),%ebx
 4eb:	eb 0c                	jmp    4f9 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 4ed:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 4f2:	89 f8                	mov    %edi,%eax
 4f4:	e8 73 ff ff ff       	call   46c <putc>
  while(--i >= 0)
 4f9:	83 eb 01             	sub    $0x1,%ebx
 4fc:	79 ef                	jns    4ed <printint+0x67>
}
 4fe:	83 c4 2c             	add    $0x2c,%esp
 501:	5b                   	pop    %ebx
 502:	5e                   	pop    %esi
 503:	5f                   	pop    %edi
 504:	5d                   	pop    %ebp
 505:	c3                   	ret    

00000506 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 506:	55                   	push   %ebp
 507:	89 e5                	mov    %esp,%ebp
 509:	57                   	push   %edi
 50a:	56                   	push   %esi
 50b:	53                   	push   %ebx
 50c:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 50f:	8d 45 10             	lea    0x10(%ebp),%eax
 512:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 515:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 51a:	bb 00 00 00 00       	mov    $0x0,%ebx
 51f:	eb 14                	jmp    535 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 521:	89 fa                	mov    %edi,%edx
 523:	8b 45 08             	mov    0x8(%ebp),%eax
 526:	e8 41 ff ff ff       	call   46c <putc>
 52b:	eb 05                	jmp    532 <printf+0x2c>
      }
    } else if(state == '%'){
 52d:	83 fe 25             	cmp    $0x25,%esi
 530:	74 25                	je     557 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 532:	83 c3 01             	add    $0x1,%ebx
 535:	8b 45 0c             	mov    0xc(%ebp),%eax
 538:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 53c:	84 c0                	test   %al,%al
 53e:	0f 84 23 01 00 00    	je     667 <printf+0x161>
    c = fmt[i] & 0xff;
 544:	0f be f8             	movsbl %al,%edi
 547:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 54a:	85 f6                	test   %esi,%esi
 54c:	75 df                	jne    52d <printf+0x27>
      if(c == '%'){
 54e:	83 f8 25             	cmp    $0x25,%eax
 551:	75 ce                	jne    521 <printf+0x1b>
        state = '%';
 553:	89 c6                	mov    %eax,%esi
 555:	eb db                	jmp    532 <printf+0x2c>
      if(c == 'd'){
 557:	83 f8 64             	cmp    $0x64,%eax
 55a:	74 49                	je     5a5 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 55c:	83 f8 78             	cmp    $0x78,%eax
 55f:	0f 94 c1             	sete   %cl
 562:	83 f8 70             	cmp    $0x70,%eax
 565:	0f 94 c2             	sete   %dl
 568:	08 d1                	or     %dl,%cl
 56a:	75 63                	jne    5cf <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 56c:	83 f8 73             	cmp    $0x73,%eax
 56f:	0f 84 84 00 00 00    	je     5f9 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 575:	83 f8 63             	cmp    $0x63,%eax
 578:	0f 84 b7 00 00 00    	je     635 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 57e:	83 f8 25             	cmp    $0x25,%eax
 581:	0f 84 cc 00 00 00    	je     653 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 587:	ba 25 00 00 00       	mov    $0x25,%edx
 58c:	8b 45 08             	mov    0x8(%ebp),%eax
 58f:	e8 d8 fe ff ff       	call   46c <putc>
        putc(fd, c);
 594:	89 fa                	mov    %edi,%edx
 596:	8b 45 08             	mov    0x8(%ebp),%eax
 599:	e8 ce fe ff ff       	call   46c <putc>
      }
      state = 0;
 59e:	be 00 00 00 00       	mov    $0x0,%esi
 5a3:	eb 8d                	jmp    532 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 5a5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5a8:	8b 17                	mov    (%edi),%edx
 5aa:	83 ec 0c             	sub    $0xc,%esp
 5ad:	6a 01                	push   $0x1
 5af:	b9 0a 00 00 00       	mov    $0xa,%ecx
 5b4:	8b 45 08             	mov    0x8(%ebp),%eax
 5b7:	e8 ca fe ff ff       	call   486 <printint>
        ap++;
 5bc:	83 c7 04             	add    $0x4,%edi
 5bf:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5c2:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5c5:	be 00 00 00 00       	mov    $0x0,%esi
 5ca:	e9 63 ff ff ff       	jmp    532 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 5cf:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 5d2:	8b 17                	mov    (%edi),%edx
 5d4:	83 ec 0c             	sub    $0xc,%esp
 5d7:	6a 00                	push   $0x0
 5d9:	b9 10 00 00 00       	mov    $0x10,%ecx
 5de:	8b 45 08             	mov    0x8(%ebp),%eax
 5e1:	e8 a0 fe ff ff       	call   486 <printint>
        ap++;
 5e6:	83 c7 04             	add    $0x4,%edi
 5e9:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 5ec:	83 c4 10             	add    $0x10,%esp
      state = 0;
 5ef:	be 00 00 00 00       	mov    $0x0,%esi
 5f4:	e9 39 ff ff ff       	jmp    532 <printf+0x2c>
        s = (char*)*ap;
 5f9:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 5fc:	8b 30                	mov    (%eax),%esi
        ap++;
 5fe:	83 c0 04             	add    $0x4,%eax
 601:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 604:	85 f6                	test   %esi,%esi
 606:	75 28                	jne    630 <printf+0x12a>
          s = "(null)";
 608:	be 3d 08 00 00       	mov    $0x83d,%esi
 60d:	8b 7d 08             	mov    0x8(%ebp),%edi
 610:	eb 0d                	jmp    61f <printf+0x119>
          putc(fd, *s);
 612:	0f be d2             	movsbl %dl,%edx
 615:	89 f8                	mov    %edi,%eax
 617:	e8 50 fe ff ff       	call   46c <putc>
          s++;
 61c:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 61f:	0f b6 16             	movzbl (%esi),%edx
 622:	84 d2                	test   %dl,%dl
 624:	75 ec                	jne    612 <printf+0x10c>
      state = 0;
 626:	be 00 00 00 00       	mov    $0x0,%esi
 62b:	e9 02 ff ff ff       	jmp    532 <printf+0x2c>
 630:	8b 7d 08             	mov    0x8(%ebp),%edi
 633:	eb ea                	jmp    61f <printf+0x119>
        putc(fd, *ap);
 635:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 638:	0f be 17             	movsbl (%edi),%edx
 63b:	8b 45 08             	mov    0x8(%ebp),%eax
 63e:	e8 29 fe ff ff       	call   46c <putc>
        ap++;
 643:	83 c7 04             	add    $0x4,%edi
 646:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 649:	be 00 00 00 00       	mov    $0x0,%esi
 64e:	e9 df fe ff ff       	jmp    532 <printf+0x2c>
        putc(fd, c);
 653:	89 fa                	mov    %edi,%edx
 655:	8b 45 08             	mov    0x8(%ebp),%eax
 658:	e8 0f fe ff ff       	call   46c <putc>
      state = 0;
 65d:	be 00 00 00 00       	mov    $0x0,%esi
 662:	e9 cb fe ff ff       	jmp    532 <printf+0x2c>
    }
  }
}
 667:	8d 65 f4             	lea    -0xc(%ebp),%esp
 66a:	5b                   	pop    %ebx
 66b:	5e                   	pop    %esi
 66c:	5f                   	pop    %edi
 66d:	5d                   	pop    %ebp
 66e:	c3                   	ret    

0000066f <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 66f:	55                   	push   %ebp
 670:	89 e5                	mov    %esp,%ebp
 672:	57                   	push   %edi
 673:	56                   	push   %esi
 674:	53                   	push   %ebx
 675:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 678:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 67b:	a1 e8 0a 00 00       	mov    0xae8,%eax
 680:	eb 02                	jmp    684 <free+0x15>
 682:	89 d0                	mov    %edx,%eax
 684:	39 c8                	cmp    %ecx,%eax
 686:	73 04                	jae    68c <free+0x1d>
 688:	39 08                	cmp    %ecx,(%eax)
 68a:	77 12                	ja     69e <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 68c:	8b 10                	mov    (%eax),%edx
 68e:	39 c2                	cmp    %eax,%edx
 690:	77 f0                	ja     682 <free+0x13>
 692:	39 c8                	cmp    %ecx,%eax
 694:	72 08                	jb     69e <free+0x2f>
 696:	39 ca                	cmp    %ecx,%edx
 698:	77 04                	ja     69e <free+0x2f>
 69a:	89 d0                	mov    %edx,%eax
 69c:	eb e6                	jmp    684 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 69e:	8b 73 fc             	mov    -0x4(%ebx),%esi
 6a1:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 6a4:	8b 10                	mov    (%eax),%edx
 6a6:	39 d7                	cmp    %edx,%edi
 6a8:	74 19                	je     6c3 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 6aa:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 6ad:	8b 50 04             	mov    0x4(%eax),%edx
 6b0:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 6b3:	39 ce                	cmp    %ecx,%esi
 6b5:	74 1b                	je     6d2 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 6b7:	89 08                	mov    %ecx,(%eax)
  freep = p;
 6b9:	a3 e8 0a 00 00       	mov    %eax,0xae8
}
 6be:	5b                   	pop    %ebx
 6bf:	5e                   	pop    %esi
 6c0:	5f                   	pop    %edi
 6c1:	5d                   	pop    %ebp
 6c2:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 6c3:	03 72 04             	add    0x4(%edx),%esi
 6c6:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 6c9:	8b 10                	mov    (%eax),%edx
 6cb:	8b 12                	mov    (%edx),%edx
 6cd:	89 53 f8             	mov    %edx,-0x8(%ebx)
 6d0:	eb db                	jmp    6ad <free+0x3e>
    p->s.size += bp->s.size;
 6d2:	03 53 fc             	add    -0x4(%ebx),%edx
 6d5:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 6d8:	8b 53 f8             	mov    -0x8(%ebx),%edx
 6db:	89 10                	mov    %edx,(%eax)
 6dd:	eb da                	jmp    6b9 <free+0x4a>

000006df <morecore>:

static Header*
morecore(uint nu)
{
 6df:	55                   	push   %ebp
 6e0:	89 e5                	mov    %esp,%ebp
 6e2:	53                   	push   %ebx
 6e3:	83 ec 04             	sub    $0x4,%esp
 6e6:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 6e8:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 6ed:	77 05                	ja     6f4 <morecore+0x15>
    nu = 4096;
 6ef:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 6f4:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 6fb:	83 ec 0c             	sub    $0xc,%esp
 6fe:	50                   	push   %eax
 6ff:	e8 30 fd ff ff       	call   434 <sbrk>
  if(p == (char*)-1)
 704:	83 c4 10             	add    $0x10,%esp
 707:	83 f8 ff             	cmp    $0xffffffff,%eax
 70a:	74 1c                	je     728 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 70c:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 70f:	83 c0 08             	add    $0x8,%eax
 712:	83 ec 0c             	sub    $0xc,%esp
 715:	50                   	push   %eax
 716:	e8 54 ff ff ff       	call   66f <free>
  return freep;
 71b:	a1 e8 0a 00 00       	mov    0xae8,%eax
 720:	83 c4 10             	add    $0x10,%esp
}
 723:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 726:	c9                   	leave  
 727:	c3                   	ret    
    return 0;
 728:	b8 00 00 00 00       	mov    $0x0,%eax
 72d:	eb f4                	jmp    723 <morecore+0x44>

0000072f <malloc>:

void*
malloc(uint nbytes)
{
 72f:	55                   	push   %ebp
 730:	89 e5                	mov    %esp,%ebp
 732:	53                   	push   %ebx
 733:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 736:	8b 45 08             	mov    0x8(%ebp),%eax
 739:	8d 58 07             	lea    0x7(%eax),%ebx
 73c:	c1 eb 03             	shr    $0x3,%ebx
 73f:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 742:	8b 0d e8 0a 00 00    	mov    0xae8,%ecx
 748:	85 c9                	test   %ecx,%ecx
 74a:	74 04                	je     750 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 74c:	8b 01                	mov    (%ecx),%eax
 74e:	eb 4d                	jmp    79d <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 750:	c7 05 e8 0a 00 00 ec 	movl   $0xaec,0xae8
 757:	0a 00 00 
 75a:	c7 05 ec 0a 00 00 ec 	movl   $0xaec,0xaec
 761:	0a 00 00 
    base.s.size = 0;
 764:	c7 05 f0 0a 00 00 00 	movl   $0x0,0xaf0
 76b:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 76e:	b9 ec 0a 00 00       	mov    $0xaec,%ecx
 773:	eb d7                	jmp    74c <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 775:	39 da                	cmp    %ebx,%edx
 777:	74 1a                	je     793 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 779:	29 da                	sub    %ebx,%edx
 77b:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 77e:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 781:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 784:	89 0d e8 0a 00 00    	mov    %ecx,0xae8
      return (void*)(p + 1);
 78a:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 78d:	83 c4 04             	add    $0x4,%esp
 790:	5b                   	pop    %ebx
 791:	5d                   	pop    %ebp
 792:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 793:	8b 10                	mov    (%eax),%edx
 795:	89 11                	mov    %edx,(%ecx)
 797:	eb eb                	jmp    784 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 799:	89 c1                	mov    %eax,%ecx
 79b:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 79d:	8b 50 04             	mov    0x4(%eax),%edx
 7a0:	39 da                	cmp    %ebx,%edx
 7a2:	73 d1                	jae    775 <malloc+0x46>
    if(p == freep)
 7a4:	39 05 e8 0a 00 00    	cmp    %eax,0xae8
 7aa:	75 ed                	jne    799 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 7ac:	89 d8                	mov    %ebx,%eax
 7ae:	e8 2c ff ff ff       	call   6df <morecore>
 7b3:	85 c0                	test   %eax,%eax
 7b5:	75 e2                	jne    799 <malloc+0x6a>
        return 0;
 7b7:	b8 00 00 00 00       	mov    $0x0,%eax
 7bc:	eb cf                	jmp    78d <malloc+0x5e>
