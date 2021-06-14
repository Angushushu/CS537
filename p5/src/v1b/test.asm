
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
  14:	e8 44 02 00 00       	call   25d <fork>
  19:	85 c0                	test   %eax,%eax
  1b:	74 33                	je     50 <main+0x50>
        char* c1 = malloc(5*sizeof(char));
        c1 = "01";
        printf(1, "child 1: %s\n", c1);
        exit();
    }
    if(fork() == 0) {
  1d:	e8 3b 02 00 00       	call   25d <fork>
  22:	85 c0                	test   %eax,%eax
  24:	74 4d                	je     73 <main+0x73>
        printf(1, "child 2: %s\n", c2);
        exit();
    }

    int numframes = 100;
    int frames[numframes];
  26:	81 ec a0 01 00 00    	sub    $0x1a0,%esp
  2c:	89 e0                	mov    %esp,%eax
  2e:	89 c7                	mov    %eax,%edi
    int pids[numframes];
  30:	81 ec a0 01 00 00    	sub    $0x1a0,%esp
  36:	89 e2                	mov    %esp,%edx
  38:	89 d6                	mov    %edx,%esi
    dump_physmem(frames, pids, numframes);
  3a:	83 ec 04             	sub    $0x4,%esp
  3d:	6a 64                	push   $0x64
  3f:	52                   	push   %edx
  40:	50                   	push   %eax
  41:	e8 bf 02 00 00       	call   305 <dump_physmem>
    for(int i = 0; i < numframes; i++) {
  46:	83 c4 10             	add    $0x10,%esp
  49:	bb 00 00 00 00       	mov    $0x0,%ebx
  4e:	eb 63                	jmp    b3 <main+0xb3>
        char* c1 = malloc(5*sizeof(char));
  50:	83 ec 0c             	sub    $0xc,%esp
  53:	6a 05                	push   $0x5
  55:	e8 76 05 00 00       	call   5d0 <malloc>
        printf(1, "child 1: %s\n", c1);
  5a:	83 c4 0c             	add    $0xc,%esp
  5d:	68 60 06 00 00       	push   $0x660
  62:	68 63 06 00 00       	push   $0x663
  67:	6a 01                	push   $0x1
  69:	e8 39 03 00 00       	call   3a7 <printf>
        exit();
  6e:	e8 f2 01 00 00       	call   265 <exit>
        char* c2 = malloc(5*sizeof(char));
  73:	83 ec 0c             	sub    $0xc,%esp
  76:	6a 05                	push   $0x5
  78:	e8 53 05 00 00       	call   5d0 <malloc>
        printf(1, "child 2: %s\n", c2);
  7d:	83 c4 0c             	add    $0xc,%esp
  80:	68 70 06 00 00       	push   $0x670
  85:	68 73 06 00 00       	push   $0x673
  8a:	6a 01                	push   $0x1
  8c:	e8 16 03 00 00       	call   3a7 <printf>
        exit();
  91:	e8 cf 01 00 00       	call   265 <exit>
        printf(1, "frames[%d] = %d; pids[%d] = %d\n", i, frames[i], i, pids[i]);
  96:	83 ec 08             	sub    $0x8,%esp
  99:	ff 34 9e             	pushl  (%esi,%ebx,4)
  9c:	53                   	push   %ebx
  9d:	ff 34 9f             	pushl  (%edi,%ebx,4)
  a0:	53                   	push   %ebx
  a1:	68 94 06 00 00       	push   $0x694
  a6:	6a 01                	push   $0x1
  a8:	e8 fa 02 00 00       	call   3a7 <printf>
    for(int i = 0; i < numframes; i++) {
  ad:	83 c3 01             	add    $0x1,%ebx
  b0:	83 c4 20             	add    $0x20,%esp
  b3:	83 fb 63             	cmp    $0x63,%ebx
  b6:	7e de                	jle    96 <main+0x96>
    }
    printf(1, "hi before return\n");
  b8:	83 ec 08             	sub    $0x8,%esp
  bb:	68 80 06 00 00       	push   $0x680
  c0:	6a 01                	push   $0x1
  c2:	e8 e0 02 00 00       	call   3a7 <printf>
    return 0;
}
  c7:	b8 00 00 00 00       	mov    $0x0,%eax
  cc:	8d 65 f0             	lea    -0x10(%ebp),%esp
  cf:	59                   	pop    %ecx
  d0:	5b                   	pop    %ebx
  d1:	5e                   	pop    %esi
  d2:	5f                   	pop    %edi
  d3:	5d                   	pop    %ebp
  d4:	8d 61 fc             	lea    -0x4(%ecx),%esp
  d7:	c3                   	ret    

000000d8 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  d8:	55                   	push   %ebp
  d9:	89 e5                	mov    %esp,%ebp
  db:	53                   	push   %ebx
  dc:	8b 45 08             	mov    0x8(%ebp),%eax
  df:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e2:	89 c2                	mov    %eax,%edx
  e4:	0f b6 19             	movzbl (%ecx),%ebx
  e7:	88 1a                	mov    %bl,(%edx)
  e9:	8d 52 01             	lea    0x1(%edx),%edx
  ec:	8d 49 01             	lea    0x1(%ecx),%ecx
  ef:	84 db                	test   %bl,%bl
  f1:	75 f1                	jne    e4 <strcpy+0xc>
    ;
  return os;
}
  f3:	5b                   	pop    %ebx
  f4:	5d                   	pop    %ebp
  f5:	c3                   	ret    

000000f6 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  f6:	55                   	push   %ebp
  f7:	89 e5                	mov    %esp,%ebp
  f9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  fc:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  ff:	eb 06                	jmp    107 <strcmp+0x11>
    p++, q++;
 101:	83 c1 01             	add    $0x1,%ecx
 104:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 107:	0f b6 01             	movzbl (%ecx),%eax
 10a:	84 c0                	test   %al,%al
 10c:	74 04                	je     112 <strcmp+0x1c>
 10e:	3a 02                	cmp    (%edx),%al
 110:	74 ef                	je     101 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 112:	0f b6 c0             	movzbl %al,%eax
 115:	0f b6 12             	movzbl (%edx),%edx
 118:	29 d0                	sub    %edx,%eax
}
 11a:	5d                   	pop    %ebp
 11b:	c3                   	ret    

0000011c <strlen>:

uint
strlen(const char *s)
{
 11c:	55                   	push   %ebp
 11d:	89 e5                	mov    %esp,%ebp
 11f:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 122:	ba 00 00 00 00       	mov    $0x0,%edx
 127:	eb 03                	jmp    12c <strlen+0x10>
 129:	83 c2 01             	add    $0x1,%edx
 12c:	89 d0                	mov    %edx,%eax
 12e:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 132:	75 f5                	jne    129 <strlen+0xd>
    ;
  return n;
}
 134:	5d                   	pop    %ebp
 135:	c3                   	ret    

00000136 <memset>:

void*
memset(void *dst, int c, uint n)
{
 136:	55                   	push   %ebp
 137:	89 e5                	mov    %esp,%ebp
 139:	57                   	push   %edi
 13a:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 13d:	89 d7                	mov    %edx,%edi
 13f:	8b 4d 10             	mov    0x10(%ebp),%ecx
 142:	8b 45 0c             	mov    0xc(%ebp),%eax
 145:	fc                   	cld    
 146:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 148:	89 d0                	mov    %edx,%eax
 14a:	5f                   	pop    %edi
 14b:	5d                   	pop    %ebp
 14c:	c3                   	ret    

0000014d <strchr>:

char*
strchr(const char *s, char c)
{
 14d:	55                   	push   %ebp
 14e:	89 e5                	mov    %esp,%ebp
 150:	8b 45 08             	mov    0x8(%ebp),%eax
 153:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 157:	0f b6 10             	movzbl (%eax),%edx
 15a:	84 d2                	test   %dl,%dl
 15c:	74 09                	je     167 <strchr+0x1a>
    if(*s == c)
 15e:	38 ca                	cmp    %cl,%dl
 160:	74 0a                	je     16c <strchr+0x1f>
  for(; *s; s++)
 162:	83 c0 01             	add    $0x1,%eax
 165:	eb f0                	jmp    157 <strchr+0xa>
      return (char*)s;
  return 0;
 167:	b8 00 00 00 00       	mov    $0x0,%eax
}
 16c:	5d                   	pop    %ebp
 16d:	c3                   	ret    

0000016e <gets>:

char*
gets(char *buf, int max)
{
 16e:	55                   	push   %ebp
 16f:	89 e5                	mov    %esp,%ebp
 171:	57                   	push   %edi
 172:	56                   	push   %esi
 173:	53                   	push   %ebx
 174:	83 ec 1c             	sub    $0x1c,%esp
 177:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17a:	bb 00 00 00 00       	mov    $0x0,%ebx
 17f:	8d 73 01             	lea    0x1(%ebx),%esi
 182:	3b 75 0c             	cmp    0xc(%ebp),%esi
 185:	7d 2e                	jge    1b5 <gets+0x47>
    cc = read(0, &c, 1);
 187:	83 ec 04             	sub    $0x4,%esp
 18a:	6a 01                	push   $0x1
 18c:	8d 45 e7             	lea    -0x19(%ebp),%eax
 18f:	50                   	push   %eax
 190:	6a 00                	push   $0x0
 192:	e8 e6 00 00 00       	call   27d <read>
    if(cc < 1)
 197:	83 c4 10             	add    $0x10,%esp
 19a:	85 c0                	test   %eax,%eax
 19c:	7e 17                	jle    1b5 <gets+0x47>
      break;
    buf[i++] = c;
 19e:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1a2:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1a5:	3c 0a                	cmp    $0xa,%al
 1a7:	0f 94 c2             	sete   %dl
 1aa:	3c 0d                	cmp    $0xd,%al
 1ac:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1af:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1b1:	08 c2                	or     %al,%dl
 1b3:	74 ca                	je     17f <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1b5:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1b9:	89 f8                	mov    %edi,%eax
 1bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1be:	5b                   	pop    %ebx
 1bf:	5e                   	pop    %esi
 1c0:	5f                   	pop    %edi
 1c1:	5d                   	pop    %ebp
 1c2:	c3                   	ret    

000001c3 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c3:	55                   	push   %ebp
 1c4:	89 e5                	mov    %esp,%ebp
 1c6:	56                   	push   %esi
 1c7:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1c8:	83 ec 08             	sub    $0x8,%esp
 1cb:	6a 00                	push   $0x0
 1cd:	ff 75 08             	pushl  0x8(%ebp)
 1d0:	e8 d0 00 00 00       	call   2a5 <open>
  if(fd < 0)
 1d5:	83 c4 10             	add    $0x10,%esp
 1d8:	85 c0                	test   %eax,%eax
 1da:	78 24                	js     200 <stat+0x3d>
 1dc:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1de:	83 ec 08             	sub    $0x8,%esp
 1e1:	ff 75 0c             	pushl  0xc(%ebp)
 1e4:	50                   	push   %eax
 1e5:	e8 d3 00 00 00       	call   2bd <fstat>
 1ea:	89 c6                	mov    %eax,%esi
  close(fd);
 1ec:	89 1c 24             	mov    %ebx,(%esp)
 1ef:	e8 99 00 00 00       	call   28d <close>
  return r;
 1f4:	83 c4 10             	add    $0x10,%esp
}
 1f7:	89 f0                	mov    %esi,%eax
 1f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1fc:	5b                   	pop    %ebx
 1fd:	5e                   	pop    %esi
 1fe:	5d                   	pop    %ebp
 1ff:	c3                   	ret    
    return -1;
 200:	be ff ff ff ff       	mov    $0xffffffff,%esi
 205:	eb f0                	jmp    1f7 <stat+0x34>

00000207 <atoi>:

int
atoi(const char *s)
{
 207:	55                   	push   %ebp
 208:	89 e5                	mov    %esp,%ebp
 20a:	53                   	push   %ebx
 20b:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 20e:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 213:	eb 10                	jmp    225 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 215:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 218:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 21b:	83 c1 01             	add    $0x1,%ecx
 21e:	0f be d2             	movsbl %dl,%edx
 221:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 225:	0f b6 11             	movzbl (%ecx),%edx
 228:	8d 5a d0             	lea    -0x30(%edx),%ebx
 22b:	80 fb 09             	cmp    $0x9,%bl
 22e:	76 e5                	jbe    215 <atoi+0xe>
  return n;
}
 230:	5b                   	pop    %ebx
 231:	5d                   	pop    %ebp
 232:	c3                   	ret    

00000233 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 233:	55                   	push   %ebp
 234:	89 e5                	mov    %esp,%ebp
 236:	56                   	push   %esi
 237:	53                   	push   %ebx
 238:	8b 45 08             	mov    0x8(%ebp),%eax
 23b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 23e:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 241:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 243:	eb 0d                	jmp    252 <memmove+0x1f>
    *dst++ = *src++;
 245:	0f b6 13             	movzbl (%ebx),%edx
 248:	88 11                	mov    %dl,(%ecx)
 24a:	8d 5b 01             	lea    0x1(%ebx),%ebx
 24d:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 250:	89 f2                	mov    %esi,%edx
 252:	8d 72 ff             	lea    -0x1(%edx),%esi
 255:	85 d2                	test   %edx,%edx
 257:	7f ec                	jg     245 <memmove+0x12>
  return vdst;
}
 259:	5b                   	pop    %ebx
 25a:	5e                   	pop    %esi
 25b:	5d                   	pop    %ebp
 25c:	c3                   	ret    

0000025d <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 25d:	b8 01 00 00 00       	mov    $0x1,%eax
 262:	cd 40                	int    $0x40
 264:	c3                   	ret    

00000265 <exit>:
SYSCALL(exit)
 265:	b8 02 00 00 00       	mov    $0x2,%eax
 26a:	cd 40                	int    $0x40
 26c:	c3                   	ret    

0000026d <wait>:
SYSCALL(wait)
 26d:	b8 03 00 00 00       	mov    $0x3,%eax
 272:	cd 40                	int    $0x40
 274:	c3                   	ret    

00000275 <pipe>:
SYSCALL(pipe)
 275:	b8 04 00 00 00       	mov    $0x4,%eax
 27a:	cd 40                	int    $0x40
 27c:	c3                   	ret    

0000027d <read>:
SYSCALL(read)
 27d:	b8 05 00 00 00       	mov    $0x5,%eax
 282:	cd 40                	int    $0x40
 284:	c3                   	ret    

00000285 <write>:
SYSCALL(write)
 285:	b8 10 00 00 00       	mov    $0x10,%eax
 28a:	cd 40                	int    $0x40
 28c:	c3                   	ret    

0000028d <close>:
SYSCALL(close)
 28d:	b8 15 00 00 00       	mov    $0x15,%eax
 292:	cd 40                	int    $0x40
 294:	c3                   	ret    

00000295 <kill>:
SYSCALL(kill)
 295:	b8 06 00 00 00       	mov    $0x6,%eax
 29a:	cd 40                	int    $0x40
 29c:	c3                   	ret    

0000029d <exec>:
SYSCALL(exec)
 29d:	b8 07 00 00 00       	mov    $0x7,%eax
 2a2:	cd 40                	int    $0x40
 2a4:	c3                   	ret    

000002a5 <open>:
SYSCALL(open)
 2a5:	b8 0f 00 00 00       	mov    $0xf,%eax
 2aa:	cd 40                	int    $0x40
 2ac:	c3                   	ret    

000002ad <mknod>:
SYSCALL(mknod)
 2ad:	b8 11 00 00 00       	mov    $0x11,%eax
 2b2:	cd 40                	int    $0x40
 2b4:	c3                   	ret    

000002b5 <unlink>:
SYSCALL(unlink)
 2b5:	b8 12 00 00 00       	mov    $0x12,%eax
 2ba:	cd 40                	int    $0x40
 2bc:	c3                   	ret    

000002bd <fstat>:
SYSCALL(fstat)
 2bd:	b8 08 00 00 00       	mov    $0x8,%eax
 2c2:	cd 40                	int    $0x40
 2c4:	c3                   	ret    

000002c5 <link>:
SYSCALL(link)
 2c5:	b8 13 00 00 00       	mov    $0x13,%eax
 2ca:	cd 40                	int    $0x40
 2cc:	c3                   	ret    

000002cd <mkdir>:
SYSCALL(mkdir)
 2cd:	b8 14 00 00 00       	mov    $0x14,%eax
 2d2:	cd 40                	int    $0x40
 2d4:	c3                   	ret    

000002d5 <chdir>:
SYSCALL(chdir)
 2d5:	b8 09 00 00 00       	mov    $0x9,%eax
 2da:	cd 40                	int    $0x40
 2dc:	c3                   	ret    

000002dd <dup>:
SYSCALL(dup)
 2dd:	b8 0a 00 00 00       	mov    $0xa,%eax
 2e2:	cd 40                	int    $0x40
 2e4:	c3                   	ret    

000002e5 <getpid>:
SYSCALL(getpid)
 2e5:	b8 0b 00 00 00       	mov    $0xb,%eax
 2ea:	cd 40                	int    $0x40
 2ec:	c3                   	ret    

000002ed <sbrk>:
SYSCALL(sbrk)
 2ed:	b8 0c 00 00 00       	mov    $0xc,%eax
 2f2:	cd 40                	int    $0x40
 2f4:	c3                   	ret    

000002f5 <sleep>:
SYSCALL(sleep)
 2f5:	b8 0d 00 00 00       	mov    $0xd,%eax
 2fa:	cd 40                	int    $0x40
 2fc:	c3                   	ret    

000002fd <uptime>:
SYSCALL(uptime)
 2fd:	b8 0e 00 00 00       	mov    $0xe,%eax
 302:	cd 40                	int    $0x40
 304:	c3                   	ret    

00000305 <dump_physmem>:
SYSCALL(dump_physmem)
 305:	b8 16 00 00 00       	mov    $0x16,%eax
 30a:	cd 40                	int    $0x40
 30c:	c3                   	ret    

0000030d <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 30d:	55                   	push   %ebp
 30e:	89 e5                	mov    %esp,%ebp
 310:	83 ec 1c             	sub    $0x1c,%esp
 313:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 316:	6a 01                	push   $0x1
 318:	8d 55 f4             	lea    -0xc(%ebp),%edx
 31b:	52                   	push   %edx
 31c:	50                   	push   %eax
 31d:	e8 63 ff ff ff       	call   285 <write>
}
 322:	83 c4 10             	add    $0x10,%esp
 325:	c9                   	leave  
 326:	c3                   	ret    

00000327 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 327:	55                   	push   %ebp
 328:	89 e5                	mov    %esp,%ebp
 32a:	57                   	push   %edi
 32b:	56                   	push   %esi
 32c:	53                   	push   %ebx
 32d:	83 ec 2c             	sub    $0x2c,%esp
 330:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 332:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 336:	0f 95 c3             	setne  %bl
 339:	89 d0                	mov    %edx,%eax
 33b:	c1 e8 1f             	shr    $0x1f,%eax
 33e:	84 c3                	test   %al,%bl
 340:	74 10                	je     352 <printint+0x2b>
    neg = 1;
    x = -xx;
 342:	f7 da                	neg    %edx
    neg = 1;
 344:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 34b:	be 00 00 00 00       	mov    $0x0,%esi
 350:	eb 0b                	jmp    35d <printint+0x36>
  neg = 0;
 352:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 359:	eb f0                	jmp    34b <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 35b:	89 c6                	mov    %eax,%esi
 35d:	89 d0                	mov    %edx,%eax
 35f:	ba 00 00 00 00       	mov    $0x0,%edx
 364:	f7 f1                	div    %ecx
 366:	89 c3                	mov    %eax,%ebx
 368:	8d 46 01             	lea    0x1(%esi),%eax
 36b:	0f b6 92 bc 06 00 00 	movzbl 0x6bc(%edx),%edx
 372:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 376:	89 da                	mov    %ebx,%edx
 378:	85 db                	test   %ebx,%ebx
 37a:	75 df                	jne    35b <printint+0x34>
 37c:	89 c3                	mov    %eax,%ebx
  if(neg)
 37e:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 382:	74 16                	je     39a <printint+0x73>
    buf[i++] = '-';
 384:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 389:	8d 5e 02             	lea    0x2(%esi),%ebx
 38c:	eb 0c                	jmp    39a <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 38e:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 393:	89 f8                	mov    %edi,%eax
 395:	e8 73 ff ff ff       	call   30d <putc>
  while(--i >= 0)
 39a:	83 eb 01             	sub    $0x1,%ebx
 39d:	79 ef                	jns    38e <printint+0x67>
}
 39f:	83 c4 2c             	add    $0x2c,%esp
 3a2:	5b                   	pop    %ebx
 3a3:	5e                   	pop    %esi
 3a4:	5f                   	pop    %edi
 3a5:	5d                   	pop    %ebp
 3a6:	c3                   	ret    

000003a7 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3a7:	55                   	push   %ebp
 3a8:	89 e5                	mov    %esp,%ebp
 3aa:	57                   	push   %edi
 3ab:	56                   	push   %esi
 3ac:	53                   	push   %ebx
 3ad:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3b0:	8d 45 10             	lea    0x10(%ebp),%eax
 3b3:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3b6:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3bb:	bb 00 00 00 00       	mov    $0x0,%ebx
 3c0:	eb 14                	jmp    3d6 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3c2:	89 fa                	mov    %edi,%edx
 3c4:	8b 45 08             	mov    0x8(%ebp),%eax
 3c7:	e8 41 ff ff ff       	call   30d <putc>
 3cc:	eb 05                	jmp    3d3 <printf+0x2c>
      }
    } else if(state == '%'){
 3ce:	83 fe 25             	cmp    $0x25,%esi
 3d1:	74 25                	je     3f8 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3d3:	83 c3 01             	add    $0x1,%ebx
 3d6:	8b 45 0c             	mov    0xc(%ebp),%eax
 3d9:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3dd:	84 c0                	test   %al,%al
 3df:	0f 84 23 01 00 00    	je     508 <printf+0x161>
    c = fmt[i] & 0xff;
 3e5:	0f be f8             	movsbl %al,%edi
 3e8:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3eb:	85 f6                	test   %esi,%esi
 3ed:	75 df                	jne    3ce <printf+0x27>
      if(c == '%'){
 3ef:	83 f8 25             	cmp    $0x25,%eax
 3f2:	75 ce                	jne    3c2 <printf+0x1b>
        state = '%';
 3f4:	89 c6                	mov    %eax,%esi
 3f6:	eb db                	jmp    3d3 <printf+0x2c>
      if(c == 'd'){
 3f8:	83 f8 64             	cmp    $0x64,%eax
 3fb:	74 49                	je     446 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3fd:	83 f8 78             	cmp    $0x78,%eax
 400:	0f 94 c1             	sete   %cl
 403:	83 f8 70             	cmp    $0x70,%eax
 406:	0f 94 c2             	sete   %dl
 409:	08 d1                	or     %dl,%cl
 40b:	75 63                	jne    470 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 40d:	83 f8 73             	cmp    $0x73,%eax
 410:	0f 84 84 00 00 00    	je     49a <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 416:	83 f8 63             	cmp    $0x63,%eax
 419:	0f 84 b7 00 00 00    	je     4d6 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 41f:	83 f8 25             	cmp    $0x25,%eax
 422:	0f 84 cc 00 00 00    	je     4f4 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 428:	ba 25 00 00 00       	mov    $0x25,%edx
 42d:	8b 45 08             	mov    0x8(%ebp),%eax
 430:	e8 d8 fe ff ff       	call   30d <putc>
        putc(fd, c);
 435:	89 fa                	mov    %edi,%edx
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	e8 ce fe ff ff       	call   30d <putc>
      }
      state = 0;
 43f:	be 00 00 00 00       	mov    $0x0,%esi
 444:	eb 8d                	jmp    3d3 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 446:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 449:	8b 17                	mov    (%edi),%edx
 44b:	83 ec 0c             	sub    $0xc,%esp
 44e:	6a 01                	push   $0x1
 450:	b9 0a 00 00 00       	mov    $0xa,%ecx
 455:	8b 45 08             	mov    0x8(%ebp),%eax
 458:	e8 ca fe ff ff       	call   327 <printint>
        ap++;
 45d:	83 c7 04             	add    $0x4,%edi
 460:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 463:	83 c4 10             	add    $0x10,%esp
      state = 0;
 466:	be 00 00 00 00       	mov    $0x0,%esi
 46b:	e9 63 ff ff ff       	jmp    3d3 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 470:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 473:	8b 17                	mov    (%edi),%edx
 475:	83 ec 0c             	sub    $0xc,%esp
 478:	6a 00                	push   $0x0
 47a:	b9 10 00 00 00       	mov    $0x10,%ecx
 47f:	8b 45 08             	mov    0x8(%ebp),%eax
 482:	e8 a0 fe ff ff       	call   327 <printint>
        ap++;
 487:	83 c7 04             	add    $0x4,%edi
 48a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 48d:	83 c4 10             	add    $0x10,%esp
      state = 0;
 490:	be 00 00 00 00       	mov    $0x0,%esi
 495:	e9 39 ff ff ff       	jmp    3d3 <printf+0x2c>
        s = (char*)*ap;
 49a:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 49d:	8b 30                	mov    (%eax),%esi
        ap++;
 49f:	83 c0 04             	add    $0x4,%eax
 4a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4a5:	85 f6                	test   %esi,%esi
 4a7:	75 28                	jne    4d1 <printf+0x12a>
          s = "(null)";
 4a9:	be b4 06 00 00       	mov    $0x6b4,%esi
 4ae:	8b 7d 08             	mov    0x8(%ebp),%edi
 4b1:	eb 0d                	jmp    4c0 <printf+0x119>
          putc(fd, *s);
 4b3:	0f be d2             	movsbl %dl,%edx
 4b6:	89 f8                	mov    %edi,%eax
 4b8:	e8 50 fe ff ff       	call   30d <putc>
          s++;
 4bd:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4c0:	0f b6 16             	movzbl (%esi),%edx
 4c3:	84 d2                	test   %dl,%dl
 4c5:	75 ec                	jne    4b3 <printf+0x10c>
      state = 0;
 4c7:	be 00 00 00 00       	mov    $0x0,%esi
 4cc:	e9 02 ff ff ff       	jmp    3d3 <printf+0x2c>
 4d1:	8b 7d 08             	mov    0x8(%ebp),%edi
 4d4:	eb ea                	jmp    4c0 <printf+0x119>
        putc(fd, *ap);
 4d6:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4d9:	0f be 17             	movsbl (%edi),%edx
 4dc:	8b 45 08             	mov    0x8(%ebp),%eax
 4df:	e8 29 fe ff ff       	call   30d <putc>
        ap++;
 4e4:	83 c7 04             	add    $0x4,%edi
 4e7:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4ea:	be 00 00 00 00       	mov    $0x0,%esi
 4ef:	e9 df fe ff ff       	jmp    3d3 <printf+0x2c>
        putc(fd, c);
 4f4:	89 fa                	mov    %edi,%edx
 4f6:	8b 45 08             	mov    0x8(%ebp),%eax
 4f9:	e8 0f fe ff ff       	call   30d <putc>
      state = 0;
 4fe:	be 00 00 00 00       	mov    $0x0,%esi
 503:	e9 cb fe ff ff       	jmp    3d3 <printf+0x2c>
    }
  }
}
 508:	8d 65 f4             	lea    -0xc(%ebp),%esp
 50b:	5b                   	pop    %ebx
 50c:	5e                   	pop    %esi
 50d:	5f                   	pop    %edi
 50e:	5d                   	pop    %ebp
 50f:	c3                   	ret    

00000510 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 510:	55                   	push   %ebp
 511:	89 e5                	mov    %esp,%ebp
 513:	57                   	push   %edi
 514:	56                   	push   %esi
 515:	53                   	push   %ebx
 516:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 519:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 51c:	a1 74 09 00 00       	mov    0x974,%eax
 521:	eb 02                	jmp    525 <free+0x15>
 523:	89 d0                	mov    %edx,%eax
 525:	39 c8                	cmp    %ecx,%eax
 527:	73 04                	jae    52d <free+0x1d>
 529:	39 08                	cmp    %ecx,(%eax)
 52b:	77 12                	ja     53f <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 52d:	8b 10                	mov    (%eax),%edx
 52f:	39 c2                	cmp    %eax,%edx
 531:	77 f0                	ja     523 <free+0x13>
 533:	39 c8                	cmp    %ecx,%eax
 535:	72 08                	jb     53f <free+0x2f>
 537:	39 ca                	cmp    %ecx,%edx
 539:	77 04                	ja     53f <free+0x2f>
 53b:	89 d0                	mov    %edx,%eax
 53d:	eb e6                	jmp    525 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 53f:	8b 73 fc             	mov    -0x4(%ebx),%esi
 542:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 545:	8b 10                	mov    (%eax),%edx
 547:	39 d7                	cmp    %edx,%edi
 549:	74 19                	je     564 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 54b:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 54e:	8b 50 04             	mov    0x4(%eax),%edx
 551:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 554:	39 ce                	cmp    %ecx,%esi
 556:	74 1b                	je     573 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 558:	89 08                	mov    %ecx,(%eax)
  freep = p;
 55a:	a3 74 09 00 00       	mov    %eax,0x974
}
 55f:	5b                   	pop    %ebx
 560:	5e                   	pop    %esi
 561:	5f                   	pop    %edi
 562:	5d                   	pop    %ebp
 563:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 564:	03 72 04             	add    0x4(%edx),%esi
 567:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 56a:	8b 10                	mov    (%eax),%edx
 56c:	8b 12                	mov    (%edx),%edx
 56e:	89 53 f8             	mov    %edx,-0x8(%ebx)
 571:	eb db                	jmp    54e <free+0x3e>
    p->s.size += bp->s.size;
 573:	03 53 fc             	add    -0x4(%ebx),%edx
 576:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 579:	8b 53 f8             	mov    -0x8(%ebx),%edx
 57c:	89 10                	mov    %edx,(%eax)
 57e:	eb da                	jmp    55a <free+0x4a>

00000580 <morecore>:

static Header*
morecore(uint nu)
{
 580:	55                   	push   %ebp
 581:	89 e5                	mov    %esp,%ebp
 583:	53                   	push   %ebx
 584:	83 ec 04             	sub    $0x4,%esp
 587:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 589:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 58e:	77 05                	ja     595 <morecore+0x15>
    nu = 4096;
 590:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 595:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 59c:	83 ec 0c             	sub    $0xc,%esp
 59f:	50                   	push   %eax
 5a0:	e8 48 fd ff ff       	call   2ed <sbrk>
  if(p == (char*)-1)
 5a5:	83 c4 10             	add    $0x10,%esp
 5a8:	83 f8 ff             	cmp    $0xffffffff,%eax
 5ab:	74 1c                	je     5c9 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5ad:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5b0:	83 c0 08             	add    $0x8,%eax
 5b3:	83 ec 0c             	sub    $0xc,%esp
 5b6:	50                   	push   %eax
 5b7:	e8 54 ff ff ff       	call   510 <free>
  return freep;
 5bc:	a1 74 09 00 00       	mov    0x974,%eax
 5c1:	83 c4 10             	add    $0x10,%esp
}
 5c4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5c7:	c9                   	leave  
 5c8:	c3                   	ret    
    return 0;
 5c9:	b8 00 00 00 00       	mov    $0x0,%eax
 5ce:	eb f4                	jmp    5c4 <morecore+0x44>

000005d0 <malloc>:

void*
malloc(uint nbytes)
{
 5d0:	55                   	push   %ebp
 5d1:	89 e5                	mov    %esp,%ebp
 5d3:	53                   	push   %ebx
 5d4:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5d7:	8b 45 08             	mov    0x8(%ebp),%eax
 5da:	8d 58 07             	lea    0x7(%eax),%ebx
 5dd:	c1 eb 03             	shr    $0x3,%ebx
 5e0:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5e3:	8b 0d 74 09 00 00    	mov    0x974,%ecx
 5e9:	85 c9                	test   %ecx,%ecx
 5eb:	74 04                	je     5f1 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5ed:	8b 01                	mov    (%ecx),%eax
 5ef:	eb 4d                	jmp    63e <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5f1:	c7 05 74 09 00 00 78 	movl   $0x978,0x974
 5f8:	09 00 00 
 5fb:	c7 05 78 09 00 00 78 	movl   $0x978,0x978
 602:	09 00 00 
    base.s.size = 0;
 605:	c7 05 7c 09 00 00 00 	movl   $0x0,0x97c
 60c:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 60f:	b9 78 09 00 00       	mov    $0x978,%ecx
 614:	eb d7                	jmp    5ed <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 616:	39 da                	cmp    %ebx,%edx
 618:	74 1a                	je     634 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 61a:	29 da                	sub    %ebx,%edx
 61c:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 61f:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 622:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 625:	89 0d 74 09 00 00    	mov    %ecx,0x974
      return (void*)(p + 1);
 62b:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 62e:	83 c4 04             	add    $0x4,%esp
 631:	5b                   	pop    %ebx
 632:	5d                   	pop    %ebp
 633:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 634:	8b 10                	mov    (%eax),%edx
 636:	89 11                	mov    %edx,(%ecx)
 638:	eb eb                	jmp    625 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 63a:	89 c1                	mov    %eax,%ecx
 63c:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 63e:	8b 50 04             	mov    0x4(%eax),%edx
 641:	39 da                	cmp    %ebx,%edx
 643:	73 d1                	jae    616 <malloc+0x46>
    if(p == freep)
 645:	39 05 74 09 00 00    	cmp    %eax,0x974
 64b:	75 ed                	jne    63a <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 64d:	89 d8                	mov    %ebx,%eax
 64f:	e8 2c ff ff ff       	call   580 <morecore>
 654:	85 c0                	test   %eax,%eax
 656:	75 e2                	jne    63a <malloc+0x6a>
        return 0;
 658:	b8 00 00 00 00       	mov    $0x0,%eax
 65d:	eb cf                	jmp    62e <malloc+0x5e>
