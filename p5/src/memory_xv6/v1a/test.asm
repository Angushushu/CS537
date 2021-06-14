
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
  14:	e8 42 02 00 00       	call   25b <fork>
  19:	85 c0                	test   %eax,%eax
  1b:	75 23                	jne    40 <main+0x40>
        char* c1 = malloc(5*sizeof(char));
  1d:	83 ec 0c             	sub    $0xc,%esp
  20:	6a 05                	push   $0x5
  22:	e8 a7 05 00 00       	call   5ce <malloc>
        c1 = "01";
        printf(1, "child 1: %s\n", c1);
  27:	83 c4 0c             	add    $0xc,%esp
  2a:	68 60 06 00 00       	push   $0x660
  2f:	68 63 06 00 00       	push   $0x663
  34:	6a 01                	push   $0x1
  36:	e8 6a 03 00 00       	call   3a5 <printf>
        exit();
  3b:	e8 23 02 00 00       	call   263 <exit>
    }
    wait();
  40:	e8 26 02 00 00       	call   26b <wait>
    if(fork() == 0) {
  45:	e8 11 02 00 00       	call   25b <fork>
  4a:	85 c0                	test   %eax,%eax
  4c:	75 23                	jne    71 <main+0x71>
        char* c2 = malloc(5*sizeof(char));
  4e:	83 ec 0c             	sub    $0xc,%esp
  51:	6a 05                	push   $0x5
  53:	e8 76 05 00 00       	call   5ce <malloc>
        c2 = "02";
        printf(1, "child 2: %s\n", c2);
  58:	83 c4 0c             	add    $0xc,%esp
  5b:	68 70 06 00 00       	push   $0x670
  60:	68 73 06 00 00       	push   $0x673
  65:	6a 01                	push   $0x1
  67:	e8 39 03 00 00       	call   3a5 <printf>
        exit();
  6c:	e8 f2 01 00 00       	call   263 <exit>
    }
    wait();
  71:	e8 f5 01 00 00       	call   26b <wait>

    int numframes = 100;
    int frames[numframes];
  76:	81 ec a0 01 00 00    	sub    $0x1a0,%esp
  7c:	89 e0                	mov    %esp,%eax
  7e:	89 c7                	mov    %eax,%edi
    int pids[numframes];
  80:	81 ec a0 01 00 00    	sub    $0x1a0,%esp
  86:	89 e2                	mov    %esp,%edx
  88:	89 d6                	mov    %edx,%esi
    dump_physmem(frames, pids, numframes);
  8a:	83 ec 04             	sub    $0x4,%esp
  8d:	6a 64                	push   $0x64
  8f:	52                   	push   %edx
  90:	50                   	push   %eax
  91:	e8 6d 02 00 00       	call   303 <dump_physmem>
    for(int i = 0; i < numframes; i++) {
  96:	83 c4 10             	add    $0x10,%esp
  99:	bb 00 00 00 00       	mov    $0x0,%ebx
  9e:	eb 1d                	jmp    bd <main+0xbd>
        printf(1, "frames[%d] = %x; pids[%d] = %d\n", i, frames[i], i, pids[i]);
  a0:	83 ec 08             	sub    $0x8,%esp
  a3:	ff 34 9e             	pushl  (%esi,%ebx,4)
  a6:	53                   	push   %ebx
  a7:	ff 34 9f             	pushl  (%edi,%ebx,4)
  aa:	53                   	push   %ebx
  ab:	68 94 06 00 00       	push   $0x694
  b0:	6a 01                	push   $0x1
  b2:	e8 ee 02 00 00       	call   3a5 <printf>
    for(int i = 0; i < numframes; i++) {
  b7:	83 c3 01             	add    $0x1,%ebx
  ba:	83 c4 20             	add    $0x20,%esp
  bd:	83 fb 63             	cmp    $0x63,%ebx
  c0:	7e de                	jle    a0 <main+0xa0>
    }
    printf(1, "hi before return\n");
  c2:	83 ec 08             	sub    $0x8,%esp
  c5:	68 80 06 00 00       	push   $0x680
  ca:	6a 01                	push   $0x1
  cc:	e8 d4 02 00 00       	call   3a5 <printf>
    exit();
  d1:	e8 8d 01 00 00       	call   263 <exit>

000000d6 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  d6:	55                   	push   %ebp
  d7:	89 e5                	mov    %esp,%ebp
  d9:	53                   	push   %ebx
  da:	8b 45 08             	mov    0x8(%ebp),%eax
  dd:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e0:	89 c2                	mov    %eax,%edx
  e2:	0f b6 19             	movzbl (%ecx),%ebx
  e5:	88 1a                	mov    %bl,(%edx)
  e7:	8d 52 01             	lea    0x1(%edx),%edx
  ea:	8d 49 01             	lea    0x1(%ecx),%ecx
  ed:	84 db                	test   %bl,%bl
  ef:	75 f1                	jne    e2 <strcpy+0xc>
    ;
  return os;
}
  f1:	5b                   	pop    %ebx
  f2:	5d                   	pop    %ebp
  f3:	c3                   	ret    

000000f4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f4:	55                   	push   %ebp
  f5:	89 e5                	mov    %esp,%ebp
  f7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  fa:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  fd:	eb 06                	jmp    105 <strcmp+0x11>
    p++, q++;
  ff:	83 c1 01             	add    $0x1,%ecx
 102:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 105:	0f b6 01             	movzbl (%ecx),%eax
 108:	84 c0                	test   %al,%al
 10a:	74 04                	je     110 <strcmp+0x1c>
 10c:	3a 02                	cmp    (%edx),%al
 10e:	74 ef                	je     ff <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 110:	0f b6 c0             	movzbl %al,%eax
 113:	0f b6 12             	movzbl (%edx),%edx
 116:	29 d0                	sub    %edx,%eax
}
 118:	5d                   	pop    %ebp
 119:	c3                   	ret    

0000011a <strlen>:

uint
strlen(const char *s)
{
 11a:	55                   	push   %ebp
 11b:	89 e5                	mov    %esp,%ebp
 11d:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 120:	ba 00 00 00 00       	mov    $0x0,%edx
 125:	eb 03                	jmp    12a <strlen+0x10>
 127:	83 c2 01             	add    $0x1,%edx
 12a:	89 d0                	mov    %edx,%eax
 12c:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 130:	75 f5                	jne    127 <strlen+0xd>
    ;
  return n;
}
 132:	5d                   	pop    %ebp
 133:	c3                   	ret    

00000134 <memset>:

void*
memset(void *dst, int c, uint n)
{
 134:	55                   	push   %ebp
 135:	89 e5                	mov    %esp,%ebp
 137:	57                   	push   %edi
 138:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 13b:	89 d7                	mov    %edx,%edi
 13d:	8b 4d 10             	mov    0x10(%ebp),%ecx
 140:	8b 45 0c             	mov    0xc(%ebp),%eax
 143:	fc                   	cld    
 144:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 146:	89 d0                	mov    %edx,%eax
 148:	5f                   	pop    %edi
 149:	5d                   	pop    %ebp
 14a:	c3                   	ret    

0000014b <strchr>:

char*
strchr(const char *s, char c)
{
 14b:	55                   	push   %ebp
 14c:	89 e5                	mov    %esp,%ebp
 14e:	8b 45 08             	mov    0x8(%ebp),%eax
 151:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 155:	0f b6 10             	movzbl (%eax),%edx
 158:	84 d2                	test   %dl,%dl
 15a:	74 09                	je     165 <strchr+0x1a>
    if(*s == c)
 15c:	38 ca                	cmp    %cl,%dl
 15e:	74 0a                	je     16a <strchr+0x1f>
  for(; *s; s++)
 160:	83 c0 01             	add    $0x1,%eax
 163:	eb f0                	jmp    155 <strchr+0xa>
      return (char*)s;
  return 0;
 165:	b8 00 00 00 00       	mov    $0x0,%eax
}
 16a:	5d                   	pop    %ebp
 16b:	c3                   	ret    

0000016c <gets>:

char*
gets(char *buf, int max)
{
 16c:	55                   	push   %ebp
 16d:	89 e5                	mov    %esp,%ebp
 16f:	57                   	push   %edi
 170:	56                   	push   %esi
 171:	53                   	push   %ebx
 172:	83 ec 1c             	sub    $0x1c,%esp
 175:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 178:	bb 00 00 00 00       	mov    $0x0,%ebx
 17d:	8d 73 01             	lea    0x1(%ebx),%esi
 180:	3b 75 0c             	cmp    0xc(%ebp),%esi
 183:	7d 2e                	jge    1b3 <gets+0x47>
    cc = read(0, &c, 1);
 185:	83 ec 04             	sub    $0x4,%esp
 188:	6a 01                	push   $0x1
 18a:	8d 45 e7             	lea    -0x19(%ebp),%eax
 18d:	50                   	push   %eax
 18e:	6a 00                	push   $0x0
 190:	e8 e6 00 00 00       	call   27b <read>
    if(cc < 1)
 195:	83 c4 10             	add    $0x10,%esp
 198:	85 c0                	test   %eax,%eax
 19a:	7e 17                	jle    1b3 <gets+0x47>
      break;
    buf[i++] = c;
 19c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1a0:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1a3:	3c 0a                	cmp    $0xa,%al
 1a5:	0f 94 c2             	sete   %dl
 1a8:	3c 0d                	cmp    $0xd,%al
 1aa:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1ad:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1af:	08 c2                	or     %al,%dl
 1b1:	74 ca                	je     17d <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1b3:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1b7:	89 f8                	mov    %edi,%eax
 1b9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1bc:	5b                   	pop    %ebx
 1bd:	5e                   	pop    %esi
 1be:	5f                   	pop    %edi
 1bf:	5d                   	pop    %ebp
 1c0:	c3                   	ret    

000001c1 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c1:	55                   	push   %ebp
 1c2:	89 e5                	mov    %esp,%ebp
 1c4:	56                   	push   %esi
 1c5:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c6:	83 ec 08             	sub    $0x8,%esp
 1c9:	6a 00                	push   $0x0
 1cb:	ff 75 08             	pushl  0x8(%ebp)
 1ce:	e8 d0 00 00 00       	call   2a3 <open>
  if(fd < 0)
 1d3:	83 c4 10             	add    $0x10,%esp
 1d6:	85 c0                	test   %eax,%eax
 1d8:	78 24                	js     1fe <stat+0x3d>
 1da:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1dc:	83 ec 08             	sub    $0x8,%esp
 1df:	ff 75 0c             	pushl  0xc(%ebp)
 1e2:	50                   	push   %eax
 1e3:	e8 d3 00 00 00       	call   2bb <fstat>
 1e8:	89 c6                	mov    %eax,%esi
  close(fd);
 1ea:	89 1c 24             	mov    %ebx,(%esp)
 1ed:	e8 99 00 00 00       	call   28b <close>
  return r;
 1f2:	83 c4 10             	add    $0x10,%esp
}
 1f5:	89 f0                	mov    %esi,%eax
 1f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1fa:	5b                   	pop    %ebx
 1fb:	5e                   	pop    %esi
 1fc:	5d                   	pop    %ebp
 1fd:	c3                   	ret    
    return -1;
 1fe:	be ff ff ff ff       	mov    $0xffffffff,%esi
 203:	eb f0                	jmp    1f5 <stat+0x34>

00000205 <atoi>:

int
atoi(const char *s)
{
 205:	55                   	push   %ebp
 206:	89 e5                	mov    %esp,%ebp
 208:	53                   	push   %ebx
 209:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 20c:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 211:	eb 10                	jmp    223 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 213:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 216:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 219:	83 c1 01             	add    $0x1,%ecx
 21c:	0f be d2             	movsbl %dl,%edx
 21f:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 223:	0f b6 11             	movzbl (%ecx),%edx
 226:	8d 5a d0             	lea    -0x30(%edx),%ebx
 229:	80 fb 09             	cmp    $0x9,%bl
 22c:	76 e5                	jbe    213 <atoi+0xe>
  return n;
}
 22e:	5b                   	pop    %ebx
 22f:	5d                   	pop    %ebp
 230:	c3                   	ret    

00000231 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 231:	55                   	push   %ebp
 232:	89 e5                	mov    %esp,%ebp
 234:	56                   	push   %esi
 235:	53                   	push   %ebx
 236:	8b 45 08             	mov    0x8(%ebp),%eax
 239:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 23c:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 23f:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 241:	eb 0d                	jmp    250 <memmove+0x1f>
    *dst++ = *src++;
 243:	0f b6 13             	movzbl (%ebx),%edx
 246:	88 11                	mov    %dl,(%ecx)
 248:	8d 5b 01             	lea    0x1(%ebx),%ebx
 24b:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 24e:	89 f2                	mov    %esi,%edx
 250:	8d 72 ff             	lea    -0x1(%edx),%esi
 253:	85 d2                	test   %edx,%edx
 255:	7f ec                	jg     243 <memmove+0x12>
  return vdst;
}
 257:	5b                   	pop    %ebx
 258:	5e                   	pop    %esi
 259:	5d                   	pop    %ebp
 25a:	c3                   	ret    

0000025b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 25b:	b8 01 00 00 00       	mov    $0x1,%eax
 260:	cd 40                	int    $0x40
 262:	c3                   	ret    

00000263 <exit>:
SYSCALL(exit)
 263:	b8 02 00 00 00       	mov    $0x2,%eax
 268:	cd 40                	int    $0x40
 26a:	c3                   	ret    

0000026b <wait>:
SYSCALL(wait)
 26b:	b8 03 00 00 00       	mov    $0x3,%eax
 270:	cd 40                	int    $0x40
 272:	c3                   	ret    

00000273 <pipe>:
SYSCALL(pipe)
 273:	b8 04 00 00 00       	mov    $0x4,%eax
 278:	cd 40                	int    $0x40
 27a:	c3                   	ret    

0000027b <read>:
SYSCALL(read)
 27b:	b8 05 00 00 00       	mov    $0x5,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <write>:
SYSCALL(write)
 283:	b8 10 00 00 00       	mov    $0x10,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <close>:
SYSCALL(close)
 28b:	b8 15 00 00 00       	mov    $0x15,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <kill>:
SYSCALL(kill)
 293:	b8 06 00 00 00       	mov    $0x6,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <exec>:
SYSCALL(exec)
 29b:	b8 07 00 00 00       	mov    $0x7,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <open>:
SYSCALL(open)
 2a3:	b8 0f 00 00 00       	mov    $0xf,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <mknod>:
SYSCALL(mknod)
 2ab:	b8 11 00 00 00       	mov    $0x11,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <unlink>:
SYSCALL(unlink)
 2b3:	b8 12 00 00 00       	mov    $0x12,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <fstat>:
SYSCALL(fstat)
 2bb:	b8 08 00 00 00       	mov    $0x8,%eax
 2c0:	cd 40                	int    $0x40
 2c2:	c3                   	ret    

000002c3 <link>:
SYSCALL(link)
 2c3:	b8 13 00 00 00       	mov    $0x13,%eax
 2c8:	cd 40                	int    $0x40
 2ca:	c3                   	ret    

000002cb <mkdir>:
SYSCALL(mkdir)
 2cb:	b8 14 00 00 00       	mov    $0x14,%eax
 2d0:	cd 40                	int    $0x40
 2d2:	c3                   	ret    

000002d3 <chdir>:
SYSCALL(chdir)
 2d3:	b8 09 00 00 00       	mov    $0x9,%eax
 2d8:	cd 40                	int    $0x40
 2da:	c3                   	ret    

000002db <dup>:
SYSCALL(dup)
 2db:	b8 0a 00 00 00       	mov    $0xa,%eax
 2e0:	cd 40                	int    $0x40
 2e2:	c3                   	ret    

000002e3 <getpid>:
SYSCALL(getpid)
 2e3:	b8 0b 00 00 00       	mov    $0xb,%eax
 2e8:	cd 40                	int    $0x40
 2ea:	c3                   	ret    

000002eb <sbrk>:
SYSCALL(sbrk)
 2eb:	b8 0c 00 00 00       	mov    $0xc,%eax
 2f0:	cd 40                	int    $0x40
 2f2:	c3                   	ret    

000002f3 <sleep>:
SYSCALL(sleep)
 2f3:	b8 0d 00 00 00       	mov    $0xd,%eax
 2f8:	cd 40                	int    $0x40
 2fa:	c3                   	ret    

000002fb <uptime>:
SYSCALL(uptime)
 2fb:	b8 0e 00 00 00       	mov    $0xe,%eax
 300:	cd 40                	int    $0x40
 302:	c3                   	ret    

00000303 <dump_physmem>:
SYSCALL(dump_physmem)
 303:	b8 16 00 00 00       	mov    $0x16,%eax
 308:	cd 40                	int    $0x40
 30a:	c3                   	ret    

0000030b <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 30b:	55                   	push   %ebp
 30c:	89 e5                	mov    %esp,%ebp
 30e:	83 ec 1c             	sub    $0x1c,%esp
 311:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 314:	6a 01                	push   $0x1
 316:	8d 55 f4             	lea    -0xc(%ebp),%edx
 319:	52                   	push   %edx
 31a:	50                   	push   %eax
 31b:	e8 63 ff ff ff       	call   283 <write>
}
 320:	83 c4 10             	add    $0x10,%esp
 323:	c9                   	leave  
 324:	c3                   	ret    

00000325 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 325:	55                   	push   %ebp
 326:	89 e5                	mov    %esp,%ebp
 328:	57                   	push   %edi
 329:	56                   	push   %esi
 32a:	53                   	push   %ebx
 32b:	83 ec 2c             	sub    $0x2c,%esp
 32e:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 330:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 334:	0f 95 c3             	setne  %bl
 337:	89 d0                	mov    %edx,%eax
 339:	c1 e8 1f             	shr    $0x1f,%eax
 33c:	84 c3                	test   %al,%bl
 33e:	74 10                	je     350 <printint+0x2b>
    neg = 1;
    x = -xx;
 340:	f7 da                	neg    %edx
    neg = 1;
 342:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 349:	be 00 00 00 00       	mov    $0x0,%esi
 34e:	eb 0b                	jmp    35b <printint+0x36>
  neg = 0;
 350:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 357:	eb f0                	jmp    349 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 359:	89 c6                	mov    %eax,%esi
 35b:	89 d0                	mov    %edx,%eax
 35d:	ba 00 00 00 00       	mov    $0x0,%edx
 362:	f7 f1                	div    %ecx
 364:	89 c3                	mov    %eax,%ebx
 366:	8d 46 01             	lea    0x1(%esi),%eax
 369:	0f b6 92 bc 06 00 00 	movzbl 0x6bc(%edx),%edx
 370:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 374:	89 da                	mov    %ebx,%edx
 376:	85 db                	test   %ebx,%ebx
 378:	75 df                	jne    359 <printint+0x34>
 37a:	89 c3                	mov    %eax,%ebx
  if(neg)
 37c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 380:	74 16                	je     398 <printint+0x73>
    buf[i++] = '-';
 382:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 387:	8d 5e 02             	lea    0x2(%esi),%ebx
 38a:	eb 0c                	jmp    398 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 38c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 391:	89 f8                	mov    %edi,%eax
 393:	e8 73 ff ff ff       	call   30b <putc>
  while(--i >= 0)
 398:	83 eb 01             	sub    $0x1,%ebx
 39b:	79 ef                	jns    38c <printint+0x67>
}
 39d:	83 c4 2c             	add    $0x2c,%esp
 3a0:	5b                   	pop    %ebx
 3a1:	5e                   	pop    %esi
 3a2:	5f                   	pop    %edi
 3a3:	5d                   	pop    %ebp
 3a4:	c3                   	ret    

000003a5 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3a5:	55                   	push   %ebp
 3a6:	89 e5                	mov    %esp,%ebp
 3a8:	57                   	push   %edi
 3a9:	56                   	push   %esi
 3aa:	53                   	push   %ebx
 3ab:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3ae:	8d 45 10             	lea    0x10(%ebp),%eax
 3b1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3b4:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3b9:	bb 00 00 00 00       	mov    $0x0,%ebx
 3be:	eb 14                	jmp    3d4 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3c0:	89 fa                	mov    %edi,%edx
 3c2:	8b 45 08             	mov    0x8(%ebp),%eax
 3c5:	e8 41 ff ff ff       	call   30b <putc>
 3ca:	eb 05                	jmp    3d1 <printf+0x2c>
      }
    } else if(state == '%'){
 3cc:	83 fe 25             	cmp    $0x25,%esi
 3cf:	74 25                	je     3f6 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3d1:	83 c3 01             	add    $0x1,%ebx
 3d4:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d7:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3db:	84 c0                	test   %al,%al
 3dd:	0f 84 23 01 00 00    	je     506 <printf+0x161>
    c = fmt[i] & 0xff;
 3e3:	0f be f8             	movsbl %al,%edi
 3e6:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3e9:	85 f6                	test   %esi,%esi
 3eb:	75 df                	jne    3cc <printf+0x27>
      if(c == '%'){
 3ed:	83 f8 25             	cmp    $0x25,%eax
 3f0:	75 ce                	jne    3c0 <printf+0x1b>
        state = '%';
 3f2:	89 c6                	mov    %eax,%esi
 3f4:	eb db                	jmp    3d1 <printf+0x2c>
      if(c == 'd'){
 3f6:	83 f8 64             	cmp    $0x64,%eax
 3f9:	74 49                	je     444 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3fb:	83 f8 78             	cmp    $0x78,%eax
 3fe:	0f 94 c1             	sete   %cl
 401:	83 f8 70             	cmp    $0x70,%eax
 404:	0f 94 c2             	sete   %dl
 407:	08 d1                	or     %dl,%cl
 409:	75 63                	jne    46e <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 40b:	83 f8 73             	cmp    $0x73,%eax
 40e:	0f 84 84 00 00 00    	je     498 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 414:	83 f8 63             	cmp    $0x63,%eax
 417:	0f 84 b7 00 00 00    	je     4d4 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 41d:	83 f8 25             	cmp    $0x25,%eax
 420:	0f 84 cc 00 00 00    	je     4f2 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 426:	ba 25 00 00 00       	mov    $0x25,%edx
 42b:	8b 45 08             	mov    0x8(%ebp),%eax
 42e:	e8 d8 fe ff ff       	call   30b <putc>
        putc(fd, c);
 433:	89 fa                	mov    %edi,%edx
 435:	8b 45 08             	mov    0x8(%ebp),%eax
 438:	e8 ce fe ff ff       	call   30b <putc>
      }
      state = 0;
 43d:	be 00 00 00 00       	mov    $0x0,%esi
 442:	eb 8d                	jmp    3d1 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 444:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 447:	8b 17                	mov    (%edi),%edx
 449:	83 ec 0c             	sub    $0xc,%esp
 44c:	6a 01                	push   $0x1
 44e:	b9 0a 00 00 00       	mov    $0xa,%ecx
 453:	8b 45 08             	mov    0x8(%ebp),%eax
 456:	e8 ca fe ff ff       	call   325 <printint>
        ap++;
 45b:	83 c7 04             	add    $0x4,%edi
 45e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 461:	83 c4 10             	add    $0x10,%esp
      state = 0;
 464:	be 00 00 00 00       	mov    $0x0,%esi
 469:	e9 63 ff ff ff       	jmp    3d1 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 46e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 471:	8b 17                	mov    (%edi),%edx
 473:	83 ec 0c             	sub    $0xc,%esp
 476:	6a 00                	push   $0x0
 478:	b9 10 00 00 00       	mov    $0x10,%ecx
 47d:	8b 45 08             	mov    0x8(%ebp),%eax
 480:	e8 a0 fe ff ff       	call   325 <printint>
        ap++;
 485:	83 c7 04             	add    $0x4,%edi
 488:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 48b:	83 c4 10             	add    $0x10,%esp
      state = 0;
 48e:	be 00 00 00 00       	mov    $0x0,%esi
 493:	e9 39 ff ff ff       	jmp    3d1 <printf+0x2c>
        s = (char*)*ap;
 498:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 49b:	8b 30                	mov    (%eax),%esi
        ap++;
 49d:	83 c0 04             	add    $0x4,%eax
 4a0:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4a3:	85 f6                	test   %esi,%esi
 4a5:	75 28                	jne    4cf <printf+0x12a>
          s = "(null)";
 4a7:	be b4 06 00 00       	mov    $0x6b4,%esi
 4ac:	8b 7d 08             	mov    0x8(%ebp),%edi
 4af:	eb 0d                	jmp    4be <printf+0x119>
          putc(fd, *s);
 4b1:	0f be d2             	movsbl %dl,%edx
 4b4:	89 f8                	mov    %edi,%eax
 4b6:	e8 50 fe ff ff       	call   30b <putc>
          s++;
 4bb:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4be:	0f b6 16             	movzbl (%esi),%edx
 4c1:	84 d2                	test   %dl,%dl
 4c3:	75 ec                	jne    4b1 <printf+0x10c>
      state = 0;
 4c5:	be 00 00 00 00       	mov    $0x0,%esi
 4ca:	e9 02 ff ff ff       	jmp    3d1 <printf+0x2c>
 4cf:	8b 7d 08             	mov    0x8(%ebp),%edi
 4d2:	eb ea                	jmp    4be <printf+0x119>
        putc(fd, *ap);
 4d4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4d7:	0f be 17             	movsbl (%edi),%edx
 4da:	8b 45 08             	mov    0x8(%ebp),%eax
 4dd:	e8 29 fe ff ff       	call   30b <putc>
        ap++;
 4e2:	83 c7 04             	add    $0x4,%edi
 4e5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4e8:	be 00 00 00 00       	mov    $0x0,%esi
 4ed:	e9 df fe ff ff       	jmp    3d1 <printf+0x2c>
        putc(fd, c);
 4f2:	89 fa                	mov    %edi,%edx
 4f4:	8b 45 08             	mov    0x8(%ebp),%eax
 4f7:	e8 0f fe ff ff       	call   30b <putc>
      state = 0;
 4fc:	be 00 00 00 00       	mov    $0x0,%esi
 501:	e9 cb fe ff ff       	jmp    3d1 <printf+0x2c>
    }
  }
}
 506:	8d 65 f4             	lea    -0xc(%ebp),%esp
 509:	5b                   	pop    %ebx
 50a:	5e                   	pop    %esi
 50b:	5f                   	pop    %edi
 50c:	5d                   	pop    %ebp
 50d:	c3                   	ret    

0000050e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 50e:	55                   	push   %ebp
 50f:	89 e5                	mov    %esp,%ebp
 511:	57                   	push   %edi
 512:	56                   	push   %esi
 513:	53                   	push   %ebx
 514:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 517:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 51a:	a1 60 09 00 00       	mov    0x960,%eax
 51f:	eb 02                	jmp    523 <free+0x15>
 521:	89 d0                	mov    %edx,%eax
 523:	39 c8                	cmp    %ecx,%eax
 525:	73 04                	jae    52b <free+0x1d>
 527:	39 08                	cmp    %ecx,(%eax)
 529:	77 12                	ja     53d <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 52b:	8b 10                	mov    (%eax),%edx
 52d:	39 c2                	cmp    %eax,%edx
 52f:	77 f0                	ja     521 <free+0x13>
 531:	39 c8                	cmp    %ecx,%eax
 533:	72 08                	jb     53d <free+0x2f>
 535:	39 ca                	cmp    %ecx,%edx
 537:	77 04                	ja     53d <free+0x2f>
 539:	89 d0                	mov    %edx,%eax
 53b:	eb e6                	jmp    523 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 53d:	8b 73 fc             	mov    -0x4(%ebx),%esi
 540:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 543:	8b 10                	mov    (%eax),%edx
 545:	39 d7                	cmp    %edx,%edi
 547:	74 19                	je     562 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 549:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 54c:	8b 50 04             	mov    0x4(%eax),%edx
 54f:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 552:	39 ce                	cmp    %ecx,%esi
 554:	74 1b                	je     571 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 556:	89 08                	mov    %ecx,(%eax)
  freep = p;
 558:	a3 60 09 00 00       	mov    %eax,0x960
}
 55d:	5b                   	pop    %ebx
 55e:	5e                   	pop    %esi
 55f:	5f                   	pop    %edi
 560:	5d                   	pop    %ebp
 561:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 562:	03 72 04             	add    0x4(%edx),%esi
 565:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 568:	8b 10                	mov    (%eax),%edx
 56a:	8b 12                	mov    (%edx),%edx
 56c:	89 53 f8             	mov    %edx,-0x8(%ebx)
 56f:	eb db                	jmp    54c <free+0x3e>
    p->s.size += bp->s.size;
 571:	03 53 fc             	add    -0x4(%ebx),%edx
 574:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 577:	8b 53 f8             	mov    -0x8(%ebx),%edx
 57a:	89 10                	mov    %edx,(%eax)
 57c:	eb da                	jmp    558 <free+0x4a>

0000057e <morecore>:

static Header*
morecore(uint nu)
{
 57e:	55                   	push   %ebp
 57f:	89 e5                	mov    %esp,%ebp
 581:	53                   	push   %ebx
 582:	83 ec 04             	sub    $0x4,%esp
 585:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 587:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 58c:	77 05                	ja     593 <morecore+0x15>
    nu = 4096;
 58e:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 593:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 59a:	83 ec 0c             	sub    $0xc,%esp
 59d:	50                   	push   %eax
 59e:	e8 48 fd ff ff       	call   2eb <sbrk>
  if(p == (char*)-1)
 5a3:	83 c4 10             	add    $0x10,%esp
 5a6:	83 f8 ff             	cmp    $0xffffffff,%eax
 5a9:	74 1c                	je     5c7 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5ab:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5ae:	83 c0 08             	add    $0x8,%eax
 5b1:	83 ec 0c             	sub    $0xc,%esp
 5b4:	50                   	push   %eax
 5b5:	e8 54 ff ff ff       	call   50e <free>
  return freep;
 5ba:	a1 60 09 00 00       	mov    0x960,%eax
 5bf:	83 c4 10             	add    $0x10,%esp
}
 5c2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5c5:	c9                   	leave  
 5c6:	c3                   	ret    
    return 0;
 5c7:	b8 00 00 00 00       	mov    $0x0,%eax
 5cc:	eb f4                	jmp    5c2 <morecore+0x44>

000005ce <malloc>:

void*
malloc(uint nbytes)
{
 5ce:	55                   	push   %ebp
 5cf:	89 e5                	mov    %esp,%ebp
 5d1:	53                   	push   %ebx
 5d2:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5d5:	8b 45 08             	mov    0x8(%ebp),%eax
 5d8:	8d 58 07             	lea    0x7(%eax),%ebx
 5db:	c1 eb 03             	shr    $0x3,%ebx
 5de:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5e1:	8b 0d 60 09 00 00    	mov    0x960,%ecx
 5e7:	85 c9                	test   %ecx,%ecx
 5e9:	74 04                	je     5ef <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5eb:	8b 01                	mov    (%ecx),%eax
 5ed:	eb 4d                	jmp    63c <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5ef:	c7 05 60 09 00 00 64 	movl   $0x964,0x960
 5f6:	09 00 00 
 5f9:	c7 05 64 09 00 00 64 	movl   $0x964,0x964
 600:	09 00 00 
    base.s.size = 0;
 603:	c7 05 68 09 00 00 00 	movl   $0x0,0x968
 60a:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 60d:	b9 64 09 00 00       	mov    $0x964,%ecx
 612:	eb d7                	jmp    5eb <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 614:	39 da                	cmp    %ebx,%edx
 616:	74 1a                	je     632 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 618:	29 da                	sub    %ebx,%edx
 61a:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 61d:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 620:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 623:	89 0d 60 09 00 00    	mov    %ecx,0x960
      return (void*)(p + 1);
 629:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 62c:	83 c4 04             	add    $0x4,%esp
 62f:	5b                   	pop    %ebx
 630:	5d                   	pop    %ebp
 631:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 632:	8b 10                	mov    (%eax),%edx
 634:	89 11                	mov    %edx,(%ecx)
 636:	eb eb                	jmp    623 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 638:	89 c1                	mov    %eax,%ecx
 63a:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 63c:	8b 50 04             	mov    0x4(%eax),%edx
 63f:	39 da                	cmp    %ebx,%edx
 641:	73 d1                	jae    614 <malloc+0x46>
    if(p == freep)
 643:	39 05 60 09 00 00    	cmp    %eax,0x960
 649:	75 ed                	jne    638 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 64b:	89 d8                	mov    %ebx,%eax
 64d:	e8 2c ff ff ff       	call   57e <morecore>
 652:	85 c0                	test   %eax,%eax
 654:	75 e2                	jne    638 <malloc+0x6a>
        return 0;
 656:	b8 00 00 00 00       	mov    $0x0,%eax
 65b:	eb cf                	jmp    62c <malloc+0x5e>
