
_test:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h"
#include "stat.h"
#include "user.h"

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
  11:	83 ec 08             	sub    $0x8,%esp
    if(fork() == 0) {
  14:	e8 4a 02 00 00       	call   263 <fork>
  19:	85 c0                	test   %eax,%eax
  1b:	74 36                	je     53 <main+0x53>
        char* c1 = malloc(5*sizeof(char));
        c1 = "01";
        printf(1, "child 1: %s\n", c1);
        exit();
    }
    if(fork() == 0) {
  1d:	e8 41 02 00 00       	call   263 <fork>
  22:	85 c0                	test   %eax,%eax
  24:	74 50                	je     76 <main+0x76>
        printf(1, "child 2: %s\n", c2);
        exit();
    }

    int numframes = 1024;
    int frames[numframes];
  26:	81 ec 10 10 00 00    	sub    $0x1010,%esp
  2c:	89 e0                	mov    %esp,%eax
  2e:	89 c7                	mov    %eax,%edi
    int pids[numframes];
  30:	81 ec 10 10 00 00    	sub    $0x1010,%esp
  36:	89 e2                	mov    %esp,%edx
  38:	89 d6                	mov    %edx,%esi
    dump_physmem(frames, pids, numframes);
  3a:	83 ec 04             	sub    $0x4,%esp
  3d:	68 00 04 00 00       	push   $0x400
  42:	52                   	push   %edx
  43:	50                   	push   %eax
  44:	e8 c2 02 00 00       	call   30b <dump_physmem>
    for(int i = 0; i < numframes; i++) {
  49:	83 c4 10             	add    $0x10,%esp
  4c:	bb 00 00 00 00       	mov    $0x0,%ebx
  51:	eb 63                	jmp    b6 <main+0xb6>
        char* c1 = malloc(5*sizeof(char));
  53:	83 ec 0c             	sub    $0xc,%esp
  56:	6a 05                	push   $0x5
  58:	e8 79 05 00 00       	call   5d6 <malloc>
        printf(1, "child 1: %s\n", c1);
  5d:	83 c4 0c             	add    $0xc,%esp
  60:	68 68 06 00 00       	push   $0x668
  65:	68 6b 06 00 00       	push   $0x66b
  6a:	6a 01                	push   $0x1
  6c:	e8 3c 03 00 00       	call   3ad <printf>
        exit();
  71:	e8 f5 01 00 00       	call   26b <exit>
        char* c2 = malloc(5*sizeof(char));
  76:	83 ec 0c             	sub    $0xc,%esp
  79:	6a 05                	push   $0x5
  7b:	e8 56 05 00 00       	call   5d6 <malloc>
        printf(1, "child 2: %s\n", c2);
  80:	83 c4 0c             	add    $0xc,%esp
  83:	68 78 06 00 00       	push   $0x678
  88:	68 7b 06 00 00       	push   $0x67b
  8d:	6a 01                	push   $0x1
  8f:	e8 19 03 00 00       	call   3ad <printf>
        exit();
  94:	e8 d2 01 00 00       	call   26b <exit>
        printf(1, "frames[%d] = %d; pids[%d] = %d\n", i, frames[i], i, pids[i]);
  99:	83 ec 08             	sub    $0x8,%esp
  9c:	ff 34 9e             	pushl  (%esi,%ebx,4)
  9f:	53                   	push   %ebx
  a0:	ff 34 9f             	pushl  (%edi,%ebx,4)
  a3:	53                   	push   %ebx
  a4:	68 9c 06 00 00       	push   $0x69c
  a9:	6a 01                	push   $0x1
  ab:	e8 fd 02 00 00       	call   3ad <printf>
    for(int i = 0; i < numframes; i++) {
  b0:	83 c3 01             	add    $0x1,%ebx
  b3:	83 c4 20             	add    $0x20,%esp
  b6:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
  bc:	7e db                	jle    99 <main+0x99>
    }
    printf(1, "hi before return\n");
  be:	83 ec 08             	sub    $0x8,%esp
  c1:	68 88 06 00 00       	push   $0x688
  c6:	6a 01                	push   $0x1
  c8:	e8 e0 02 00 00       	call   3ad <printf>
    return 0;
}
  cd:	b8 00 00 00 00       	mov    $0x0,%eax
  d2:	8d 65 f0             	lea    -0x10(%ebp),%esp
  d5:	59                   	pop    %ecx
  d6:	5b                   	pop    %ebx
  d7:	5e                   	pop    %esi
  d8:	5f                   	pop    %edi
  d9:	5d                   	pop    %ebp
  da:	8d 61 fc             	lea    -0x4(%ecx),%esp
  dd:	c3                   	ret    

000000de <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  de:	55                   	push   %ebp
  df:	89 e5                	mov    %esp,%ebp
  e1:	53                   	push   %ebx
  e2:	8b 45 08             	mov    0x8(%ebp),%eax
  e5:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e8:	89 c2                	mov    %eax,%edx
  ea:	0f b6 19             	movzbl (%ecx),%ebx
  ed:	88 1a                	mov    %bl,(%edx)
  ef:	8d 52 01             	lea    0x1(%edx),%edx
  f2:	8d 49 01             	lea    0x1(%ecx),%ecx
  f5:	84 db                	test   %bl,%bl
  f7:	75 f1                	jne    ea <strcpy+0xc>
    ;
  return os;
}
  f9:	5b                   	pop    %ebx
  fa:	5d                   	pop    %ebp
  fb:	c3                   	ret    

000000fc <strcmp>:

int
strcmp(const char *p, const char *q)
{
  fc:	55                   	push   %ebp
  fd:	89 e5                	mov    %esp,%ebp
  ff:	8b 4d 08             	mov    0x8(%ebp),%ecx
 102:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 105:	eb 06                	jmp    10d <strcmp+0x11>
    p++, q++;
 107:	83 c1 01             	add    $0x1,%ecx
 10a:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 10d:	0f b6 01             	movzbl (%ecx),%eax
 110:	84 c0                	test   %al,%al
 112:	74 04                	je     118 <strcmp+0x1c>
 114:	3a 02                	cmp    (%edx),%al
 116:	74 ef                	je     107 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 118:	0f b6 c0             	movzbl %al,%eax
 11b:	0f b6 12             	movzbl (%edx),%edx
 11e:	29 d0                	sub    %edx,%eax
}
 120:	5d                   	pop    %ebp
 121:	c3                   	ret    

00000122 <strlen>:

uint
strlen(const char *s)
{
 122:	55                   	push   %ebp
 123:	89 e5                	mov    %esp,%ebp
 125:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 128:	ba 00 00 00 00       	mov    $0x0,%edx
 12d:	eb 03                	jmp    132 <strlen+0x10>
 12f:	83 c2 01             	add    $0x1,%edx
 132:	89 d0                	mov    %edx,%eax
 134:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 138:	75 f5                	jne    12f <strlen+0xd>
    ;
  return n;
}
 13a:	5d                   	pop    %ebp
 13b:	c3                   	ret    

0000013c <memset>:

void*
memset(void *dst, int c, uint n)
{
 13c:	55                   	push   %ebp
 13d:	89 e5                	mov    %esp,%ebp
 13f:	57                   	push   %edi
 140:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 143:	89 d7                	mov    %edx,%edi
 145:	8b 4d 10             	mov    0x10(%ebp),%ecx
 148:	8b 45 0c             	mov    0xc(%ebp),%eax
 14b:	fc                   	cld    
 14c:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 14e:	89 d0                	mov    %edx,%eax
 150:	5f                   	pop    %edi
 151:	5d                   	pop    %ebp
 152:	c3                   	ret    

00000153 <strchr>:

char*
strchr(const char *s, char c)
{
 153:	55                   	push   %ebp
 154:	89 e5                	mov    %esp,%ebp
 156:	8b 45 08             	mov    0x8(%ebp),%eax
 159:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 15d:	0f b6 10             	movzbl (%eax),%edx
 160:	84 d2                	test   %dl,%dl
 162:	74 09                	je     16d <strchr+0x1a>
    if(*s == c)
 164:	38 ca                	cmp    %cl,%dl
 166:	74 0a                	je     172 <strchr+0x1f>
  for(; *s; s++)
 168:	83 c0 01             	add    $0x1,%eax
 16b:	eb f0                	jmp    15d <strchr+0xa>
      return (char*)s;
  return 0;
 16d:	b8 00 00 00 00       	mov    $0x0,%eax
}
 172:	5d                   	pop    %ebp
 173:	c3                   	ret    

00000174 <gets>:

char*
gets(char *buf, int max)
{
 174:	55                   	push   %ebp
 175:	89 e5                	mov    %esp,%ebp
 177:	57                   	push   %edi
 178:	56                   	push   %esi
 179:	53                   	push   %ebx
 17a:	83 ec 1c             	sub    $0x1c,%esp
 17d:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 180:	bb 00 00 00 00       	mov    $0x0,%ebx
 185:	8d 73 01             	lea    0x1(%ebx),%esi
 188:	3b 75 0c             	cmp    0xc(%ebp),%esi
 18b:	7d 2e                	jge    1bb <gets+0x47>
    cc = read(0, &c, 1);
 18d:	83 ec 04             	sub    $0x4,%esp
 190:	6a 01                	push   $0x1
 192:	8d 45 e7             	lea    -0x19(%ebp),%eax
 195:	50                   	push   %eax
 196:	6a 00                	push   $0x0
 198:	e8 e6 00 00 00       	call   283 <read>
    if(cc < 1)
 19d:	83 c4 10             	add    $0x10,%esp
 1a0:	85 c0                	test   %eax,%eax
 1a2:	7e 17                	jle    1bb <gets+0x47>
      break;
    buf[i++] = c;
 1a4:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1a8:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1ab:	3c 0a                	cmp    $0xa,%al
 1ad:	0f 94 c2             	sete   %dl
 1b0:	3c 0d                	cmp    $0xd,%al
 1b2:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1b5:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1b7:	08 c2                	or     %al,%dl
 1b9:	74 ca                	je     185 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1bb:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1bf:	89 f8                	mov    %edi,%eax
 1c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1c4:	5b                   	pop    %ebx
 1c5:	5e                   	pop    %esi
 1c6:	5f                   	pop    %edi
 1c7:	5d                   	pop    %ebp
 1c8:	c3                   	ret    

000001c9 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c9:	55                   	push   %ebp
 1ca:	89 e5                	mov    %esp,%ebp
 1cc:	56                   	push   %esi
 1cd:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1ce:	83 ec 08             	sub    $0x8,%esp
 1d1:	6a 00                	push   $0x0
 1d3:	ff 75 08             	pushl  0x8(%ebp)
 1d6:	e8 d0 00 00 00       	call   2ab <open>
  if(fd < 0)
 1db:	83 c4 10             	add    $0x10,%esp
 1de:	85 c0                	test   %eax,%eax
 1e0:	78 24                	js     206 <stat+0x3d>
 1e2:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1e4:	83 ec 08             	sub    $0x8,%esp
 1e7:	ff 75 0c             	pushl  0xc(%ebp)
 1ea:	50                   	push   %eax
 1eb:	e8 d3 00 00 00       	call   2c3 <fstat>
 1f0:	89 c6                	mov    %eax,%esi
  close(fd);
 1f2:	89 1c 24             	mov    %ebx,(%esp)
 1f5:	e8 99 00 00 00       	call   293 <close>
  return r;
 1fa:	83 c4 10             	add    $0x10,%esp
}
 1fd:	89 f0                	mov    %esi,%eax
 1ff:	8d 65 f8             	lea    -0x8(%ebp),%esp
 202:	5b                   	pop    %ebx
 203:	5e                   	pop    %esi
 204:	5d                   	pop    %ebp
 205:	c3                   	ret    
    return -1;
 206:	be ff ff ff ff       	mov    $0xffffffff,%esi
 20b:	eb f0                	jmp    1fd <stat+0x34>

0000020d <atoi>:

int
atoi(const char *s)
{
 20d:	55                   	push   %ebp
 20e:	89 e5                	mov    %esp,%ebp
 210:	53                   	push   %ebx
 211:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 214:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 219:	eb 10                	jmp    22b <atoi+0x1e>
    n = n*10 + *s++ - '0';
 21b:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 21e:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 221:	83 c1 01             	add    $0x1,%ecx
 224:	0f be d2             	movsbl %dl,%edx
 227:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 22b:	0f b6 11             	movzbl (%ecx),%edx
 22e:	8d 5a d0             	lea    -0x30(%edx),%ebx
 231:	80 fb 09             	cmp    $0x9,%bl
 234:	76 e5                	jbe    21b <atoi+0xe>
  return n;
}
 236:	5b                   	pop    %ebx
 237:	5d                   	pop    %ebp
 238:	c3                   	ret    

00000239 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 239:	55                   	push   %ebp
 23a:	89 e5                	mov    %esp,%ebp
 23c:	56                   	push   %esi
 23d:	53                   	push   %ebx
 23e:	8b 45 08             	mov    0x8(%ebp),%eax
 241:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 244:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 247:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 249:	eb 0d                	jmp    258 <memmove+0x1f>
    *dst++ = *src++;
 24b:	0f b6 13             	movzbl (%ebx),%edx
 24e:	88 11                	mov    %dl,(%ecx)
 250:	8d 5b 01             	lea    0x1(%ebx),%ebx
 253:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 256:	89 f2                	mov    %esi,%edx
 258:	8d 72 ff             	lea    -0x1(%edx),%esi
 25b:	85 d2                	test   %edx,%edx
 25d:	7f ec                	jg     24b <memmove+0x12>
  return vdst;
}
 25f:	5b                   	pop    %ebx
 260:	5e                   	pop    %esi
 261:	5d                   	pop    %ebp
 262:	c3                   	ret    

00000263 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 263:	b8 01 00 00 00       	mov    $0x1,%eax
 268:	cd 40                	int    $0x40
 26a:	c3                   	ret    

0000026b <exit>:
SYSCALL(exit)
 26b:	b8 02 00 00 00       	mov    $0x2,%eax
 270:	cd 40                	int    $0x40
 272:	c3                   	ret    

00000273 <wait>:
SYSCALL(wait)
 273:	b8 03 00 00 00       	mov    $0x3,%eax
 278:	cd 40                	int    $0x40
 27a:	c3                   	ret    

0000027b <pipe>:
SYSCALL(pipe)
 27b:	b8 04 00 00 00       	mov    $0x4,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <read>:
SYSCALL(read)
 283:	b8 05 00 00 00       	mov    $0x5,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <write>:
SYSCALL(write)
 28b:	b8 10 00 00 00       	mov    $0x10,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <close>:
SYSCALL(close)
 293:	b8 15 00 00 00       	mov    $0x15,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <kill>:
SYSCALL(kill)
 29b:	b8 06 00 00 00       	mov    $0x6,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <exec>:
SYSCALL(exec)
 2a3:	b8 07 00 00 00       	mov    $0x7,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <open>:
SYSCALL(open)
 2ab:	b8 0f 00 00 00       	mov    $0xf,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <mknod>:
SYSCALL(mknod)
 2b3:	b8 11 00 00 00       	mov    $0x11,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <unlink>:
SYSCALL(unlink)
 2bb:	b8 12 00 00 00       	mov    $0x12,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret    

000002c3 <fstat>:
SYSCALL(fstat)
 2c3:	b8 08 00 00 00       	mov    $0x8,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <link>:
SYSCALL(link)
 2cb:	b8 13 00 00 00       	mov    $0x13,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <mkdir>:
SYSCALL(mkdir)
 2d3:	b8 14 00 00 00       	mov    $0x14,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <chdir>:
SYSCALL(chdir)
 2db:	b8 09 00 00 00       	mov    $0x9,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <dup>:
SYSCALL(dup)
 2e3:	b8 0a 00 00 00       	mov    $0xa,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <getpid>:
SYSCALL(getpid)
 2eb:	b8 0b 00 00 00       	mov    $0xb,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <sbrk>:
SYSCALL(sbrk)
 2f3:	b8 0c 00 00 00       	mov    $0xc,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <sleep>:
SYSCALL(sleep)
 2fb:	b8 0d 00 00 00       	mov    $0xd,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <uptime>:
SYSCALL(uptime)
 303:	b8 0e 00 00 00       	mov    $0xe,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <dump_physmem>:
SYSCALL(dump_physmem)
 30b:	b8 16 00 00 00       	mov    $0x16,%eax
 310:	cd 40                	int    $0x40
 312:	c3                   	ret    

00000313 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 313:	55                   	push   %ebp
 314:	89 e5                	mov    %esp,%ebp
 316:	83 ec 1c             	sub    $0x1c,%esp
 319:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 31c:	6a 01                	push   $0x1
 31e:	8d 55 f4             	lea    -0xc(%ebp),%edx
 321:	52                   	push   %edx
 322:	50                   	push   %eax
 323:	e8 63 ff ff ff       	call   28b <write>
}
 328:	83 c4 10             	add    $0x10,%esp
 32b:	c9                   	leave  
 32c:	c3                   	ret    

0000032d <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 32d:	55                   	push   %ebp
 32e:	89 e5                	mov    %esp,%ebp
 330:	57                   	push   %edi
 331:	56                   	push   %esi
 332:	53                   	push   %ebx
 333:	83 ec 2c             	sub    $0x2c,%esp
 336:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 338:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 33c:	0f 95 c3             	setne  %bl
 33f:	89 d0                	mov    %edx,%eax
 341:	c1 e8 1f             	shr    $0x1f,%eax
 344:	84 c3                	test   %al,%bl
 346:	74 10                	je     358 <printint+0x2b>
    neg = 1;
    x = -xx;
 348:	f7 da                	neg    %edx
    neg = 1;
 34a:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 351:	be 00 00 00 00       	mov    $0x0,%esi
 356:	eb 0b                	jmp    363 <printint+0x36>
  neg = 0;
 358:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 35f:	eb f0                	jmp    351 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 361:	89 c6                	mov    %eax,%esi
 363:	89 d0                	mov    %edx,%eax
 365:	ba 00 00 00 00       	mov    $0x0,%edx
 36a:	f7 f1                	div    %ecx
 36c:	89 c3                	mov    %eax,%ebx
 36e:	8d 46 01             	lea    0x1(%esi),%eax
 371:	0f b6 92 c4 06 00 00 	movzbl 0x6c4(%edx),%edx
 378:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 37c:	89 da                	mov    %ebx,%edx
 37e:	85 db                	test   %ebx,%ebx
 380:	75 df                	jne    361 <printint+0x34>
 382:	89 c3                	mov    %eax,%ebx
  if(neg)
 384:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 388:	74 16                	je     3a0 <printint+0x73>
    buf[i++] = '-';
 38a:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 38f:	8d 5e 02             	lea    0x2(%esi),%ebx
 392:	eb 0c                	jmp    3a0 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 394:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 399:	89 f8                	mov    %edi,%eax
 39b:	e8 73 ff ff ff       	call   313 <putc>
  while(--i >= 0)
 3a0:	83 eb 01             	sub    $0x1,%ebx
 3a3:	79 ef                	jns    394 <printint+0x67>
}
 3a5:	83 c4 2c             	add    $0x2c,%esp
 3a8:	5b                   	pop    %ebx
 3a9:	5e                   	pop    %esi
 3aa:	5f                   	pop    %edi
 3ab:	5d                   	pop    %ebp
 3ac:	c3                   	ret    

000003ad <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3ad:	55                   	push   %ebp
 3ae:	89 e5                	mov    %esp,%ebp
 3b0:	57                   	push   %edi
 3b1:	56                   	push   %esi
 3b2:	53                   	push   %ebx
 3b3:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3b6:	8d 45 10             	lea    0x10(%ebp),%eax
 3b9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3bc:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3c1:	bb 00 00 00 00       	mov    $0x0,%ebx
 3c6:	eb 14                	jmp    3dc <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3c8:	89 fa                	mov    %edi,%edx
 3ca:	8b 45 08             	mov    0x8(%ebp),%eax
 3cd:	e8 41 ff ff ff       	call   313 <putc>
 3d2:	eb 05                	jmp    3d9 <printf+0x2c>
      }
    } else if(state == '%'){
 3d4:	83 fe 25             	cmp    $0x25,%esi
 3d7:	74 25                	je     3fe <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3d9:	83 c3 01             	add    $0x1,%ebx
 3dc:	8b 45 0c             	mov    0xc(%ebp),%eax
 3df:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3e3:	84 c0                	test   %al,%al
 3e5:	0f 84 23 01 00 00    	je     50e <printf+0x161>
    c = fmt[i] & 0xff;
 3eb:	0f be f8             	movsbl %al,%edi
 3ee:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3f1:	85 f6                	test   %esi,%esi
 3f3:	75 df                	jne    3d4 <printf+0x27>
      if(c == '%'){
 3f5:	83 f8 25             	cmp    $0x25,%eax
 3f8:	75 ce                	jne    3c8 <printf+0x1b>
        state = '%';
 3fa:	89 c6                	mov    %eax,%esi
 3fc:	eb db                	jmp    3d9 <printf+0x2c>
      if(c == 'd'){
 3fe:	83 f8 64             	cmp    $0x64,%eax
 401:	74 49                	je     44c <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 403:	83 f8 78             	cmp    $0x78,%eax
 406:	0f 94 c1             	sete   %cl
 409:	83 f8 70             	cmp    $0x70,%eax
 40c:	0f 94 c2             	sete   %dl
 40f:	08 d1                	or     %dl,%cl
 411:	75 63                	jne    476 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 413:	83 f8 73             	cmp    $0x73,%eax
 416:	0f 84 84 00 00 00    	je     4a0 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 41c:	83 f8 63             	cmp    $0x63,%eax
 41f:	0f 84 b7 00 00 00    	je     4dc <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 425:	83 f8 25             	cmp    $0x25,%eax
 428:	0f 84 cc 00 00 00    	je     4fa <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 42e:	ba 25 00 00 00       	mov    $0x25,%edx
 433:	8b 45 08             	mov    0x8(%ebp),%eax
 436:	e8 d8 fe ff ff       	call   313 <putc>
        putc(fd, c);
 43b:	89 fa                	mov    %edi,%edx
 43d:	8b 45 08             	mov    0x8(%ebp),%eax
 440:	e8 ce fe ff ff       	call   313 <putc>
      }
      state = 0;
 445:	be 00 00 00 00       	mov    $0x0,%esi
 44a:	eb 8d                	jmp    3d9 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 44c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 44f:	8b 17                	mov    (%edi),%edx
 451:	83 ec 0c             	sub    $0xc,%esp
 454:	6a 01                	push   $0x1
 456:	b9 0a 00 00 00       	mov    $0xa,%ecx
 45b:	8b 45 08             	mov    0x8(%ebp),%eax
 45e:	e8 ca fe ff ff       	call   32d <printint>
        ap++;
 463:	83 c7 04             	add    $0x4,%edi
 466:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 469:	83 c4 10             	add    $0x10,%esp
      state = 0;
 46c:	be 00 00 00 00       	mov    $0x0,%esi
 471:	e9 63 ff ff ff       	jmp    3d9 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 476:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 479:	8b 17                	mov    (%edi),%edx
 47b:	83 ec 0c             	sub    $0xc,%esp
 47e:	6a 00                	push   $0x0
 480:	b9 10 00 00 00       	mov    $0x10,%ecx
 485:	8b 45 08             	mov    0x8(%ebp),%eax
 488:	e8 a0 fe ff ff       	call   32d <printint>
        ap++;
 48d:	83 c7 04             	add    $0x4,%edi
 490:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 493:	83 c4 10             	add    $0x10,%esp
      state = 0;
 496:	be 00 00 00 00       	mov    $0x0,%esi
 49b:	e9 39 ff ff ff       	jmp    3d9 <printf+0x2c>
        s = (char*)*ap;
 4a0:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4a3:	8b 30                	mov    (%eax),%esi
        ap++;
 4a5:	83 c0 04             	add    $0x4,%eax
 4a8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4ab:	85 f6                	test   %esi,%esi
 4ad:	75 28                	jne    4d7 <printf+0x12a>
          s = "(null)";
 4af:	be bc 06 00 00       	mov    $0x6bc,%esi
 4b4:	8b 7d 08             	mov    0x8(%ebp),%edi
 4b7:	eb 0d                	jmp    4c6 <printf+0x119>
          putc(fd, *s);
 4b9:	0f be d2             	movsbl %dl,%edx
 4bc:	89 f8                	mov    %edi,%eax
 4be:	e8 50 fe ff ff       	call   313 <putc>
          s++;
 4c3:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4c6:	0f b6 16             	movzbl (%esi),%edx
 4c9:	84 d2                	test   %dl,%dl
 4cb:	75 ec                	jne    4b9 <printf+0x10c>
      state = 0;
 4cd:	be 00 00 00 00       	mov    $0x0,%esi
 4d2:	e9 02 ff ff ff       	jmp    3d9 <printf+0x2c>
 4d7:	8b 7d 08             	mov    0x8(%ebp),%edi
 4da:	eb ea                	jmp    4c6 <printf+0x119>
        putc(fd, *ap);
 4dc:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4df:	0f be 17             	movsbl (%edi),%edx
 4e2:	8b 45 08             	mov    0x8(%ebp),%eax
 4e5:	e8 29 fe ff ff       	call   313 <putc>
        ap++;
 4ea:	83 c7 04             	add    $0x4,%edi
 4ed:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4f0:	be 00 00 00 00       	mov    $0x0,%esi
 4f5:	e9 df fe ff ff       	jmp    3d9 <printf+0x2c>
        putc(fd, c);
 4fa:	89 fa                	mov    %edi,%edx
 4fc:	8b 45 08             	mov    0x8(%ebp),%eax
 4ff:	e8 0f fe ff ff       	call   313 <putc>
      state = 0;
 504:	be 00 00 00 00       	mov    $0x0,%esi
 509:	e9 cb fe ff ff       	jmp    3d9 <printf+0x2c>
    }
  }
}
 50e:	8d 65 f4             	lea    -0xc(%ebp),%esp
 511:	5b                   	pop    %ebx
 512:	5e                   	pop    %esi
 513:	5f                   	pop    %edi
 514:	5d                   	pop    %ebp
 515:	c3                   	ret    

00000516 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 516:	55                   	push   %ebp
 517:	89 e5                	mov    %esp,%ebp
 519:	57                   	push   %edi
 51a:	56                   	push   %esi
 51b:	53                   	push   %ebx
 51c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 51f:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 522:	a1 7c 09 00 00       	mov    0x97c,%eax
 527:	eb 02                	jmp    52b <free+0x15>
 529:	89 d0                	mov    %edx,%eax
 52b:	39 c8                	cmp    %ecx,%eax
 52d:	73 04                	jae    533 <free+0x1d>
 52f:	39 08                	cmp    %ecx,(%eax)
 531:	77 12                	ja     545 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 533:	8b 10                	mov    (%eax),%edx
 535:	39 c2                	cmp    %eax,%edx
 537:	77 f0                	ja     529 <free+0x13>
 539:	39 c8                	cmp    %ecx,%eax
 53b:	72 08                	jb     545 <free+0x2f>
 53d:	39 ca                	cmp    %ecx,%edx
 53f:	77 04                	ja     545 <free+0x2f>
 541:	89 d0                	mov    %edx,%eax
 543:	eb e6                	jmp    52b <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 545:	8b 73 fc             	mov    -0x4(%ebx),%esi
 548:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 54b:	8b 10                	mov    (%eax),%edx
 54d:	39 d7                	cmp    %edx,%edi
 54f:	74 19                	je     56a <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 551:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 554:	8b 50 04             	mov    0x4(%eax),%edx
 557:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 55a:	39 ce                	cmp    %ecx,%esi
 55c:	74 1b                	je     579 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 55e:	89 08                	mov    %ecx,(%eax)
  freep = p;
 560:	a3 7c 09 00 00       	mov    %eax,0x97c
}
 565:	5b                   	pop    %ebx
 566:	5e                   	pop    %esi
 567:	5f                   	pop    %edi
 568:	5d                   	pop    %ebp
 569:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 56a:	03 72 04             	add    0x4(%edx),%esi
 56d:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 570:	8b 10                	mov    (%eax),%edx
 572:	8b 12                	mov    (%edx),%edx
 574:	89 53 f8             	mov    %edx,-0x8(%ebx)
 577:	eb db                	jmp    554 <free+0x3e>
    p->s.size += bp->s.size;
 579:	03 53 fc             	add    -0x4(%ebx),%edx
 57c:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 57f:	8b 53 f8             	mov    -0x8(%ebx),%edx
 582:	89 10                	mov    %edx,(%eax)
 584:	eb da                	jmp    560 <free+0x4a>

00000586 <morecore>:

static Header*
morecore(uint nu)
{
 586:	55                   	push   %ebp
 587:	89 e5                	mov    %esp,%ebp
 589:	53                   	push   %ebx
 58a:	83 ec 04             	sub    $0x4,%esp
 58d:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 58f:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 594:	77 05                	ja     59b <morecore+0x15>
    nu = 4096;
 596:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 59b:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5a2:	83 ec 0c             	sub    $0xc,%esp
 5a5:	50                   	push   %eax
 5a6:	e8 48 fd ff ff       	call   2f3 <sbrk>
  if(p == (char*)-1)
 5ab:	83 c4 10             	add    $0x10,%esp
 5ae:	83 f8 ff             	cmp    $0xffffffff,%eax
 5b1:	74 1c                	je     5cf <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5b3:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5b6:	83 c0 08             	add    $0x8,%eax
 5b9:	83 ec 0c             	sub    $0xc,%esp
 5bc:	50                   	push   %eax
 5bd:	e8 54 ff ff ff       	call   516 <free>
  return freep;
 5c2:	a1 7c 09 00 00       	mov    0x97c,%eax
 5c7:	83 c4 10             	add    $0x10,%esp
}
 5ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5cd:	c9                   	leave  
 5ce:	c3                   	ret    
    return 0;
 5cf:	b8 00 00 00 00       	mov    $0x0,%eax
 5d4:	eb f4                	jmp    5ca <morecore+0x44>

000005d6 <malloc>:

void*
malloc(uint nbytes)
{
 5d6:	55                   	push   %ebp
 5d7:	89 e5                	mov    %esp,%ebp
 5d9:	53                   	push   %ebx
 5da:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5dd:	8b 45 08             	mov    0x8(%ebp),%eax
 5e0:	8d 58 07             	lea    0x7(%eax),%ebx
 5e3:	c1 eb 03             	shr    $0x3,%ebx
 5e6:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5e9:	8b 0d 7c 09 00 00    	mov    0x97c,%ecx
 5ef:	85 c9                	test   %ecx,%ecx
 5f1:	74 04                	je     5f7 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5f3:	8b 01                	mov    (%ecx),%eax
 5f5:	eb 4d                	jmp    644 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5f7:	c7 05 7c 09 00 00 80 	movl   $0x980,0x97c
 5fe:	09 00 00 
 601:	c7 05 80 09 00 00 80 	movl   $0x980,0x980
 608:	09 00 00 
    base.s.size = 0;
 60b:	c7 05 84 09 00 00 00 	movl   $0x0,0x984
 612:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 615:	b9 80 09 00 00       	mov    $0x980,%ecx
 61a:	eb d7                	jmp    5f3 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 61c:	39 da                	cmp    %ebx,%edx
 61e:	74 1a                	je     63a <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 620:	29 da                	sub    %ebx,%edx
 622:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 625:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 628:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 62b:	89 0d 7c 09 00 00    	mov    %ecx,0x97c
      return (void*)(p + 1);
 631:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 634:	83 c4 04             	add    $0x4,%esp
 637:	5b                   	pop    %ebx
 638:	5d                   	pop    %ebp
 639:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 63a:	8b 10                	mov    (%eax),%edx
 63c:	89 11                	mov    %edx,(%ecx)
 63e:	eb eb                	jmp    62b <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 640:	89 c1                	mov    %eax,%ecx
 642:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 644:	8b 50 04             	mov    0x4(%eax),%edx
 647:	39 da                	cmp    %ebx,%edx
 649:	73 d1                	jae    61c <malloc+0x46>
    if(p == freep)
 64b:	39 05 7c 09 00 00    	cmp    %eax,0x97c
 651:	75 ed                	jne    640 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 653:	89 d8                	mov    %ebx,%eax
 655:	e8 2c ff ff ff       	call   586 <morecore>
 65a:	85 c0                	test   %eax,%eax
 65c:	75 e2                	jne    640 <malloc+0x6a>
        return 0;
 65e:	b8 00 00 00 00       	mov    $0x0,%eax
 663:	eb cf                	jmp    634 <malloc+0x5e>
