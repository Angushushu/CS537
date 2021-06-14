
_test_8:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
 #endif
 
 
 int
 main(int argc, char *argv[])
 {
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 14             	sub    $0x14,%esp
        int numframes = 1000;
 //         char *args[1];
 //         args[0] = "usertests";
 //      int error=-11;
         int* frames = malloc(numframes * sizeof(int));
  14:	68 a0 0f 00 00       	push   $0xfa0
  19:	e8 60 05 00 00       	call   57e <malloc>
  1e:	89 c6                	mov    %eax,%esi
         int* pids = malloc(1000000 * sizeof(int));
  20:	c7 04 24 00 09 3d 00 	movl   $0x3d0900,(%esp)
  27:	e8 52 05 00 00       	call   57e <malloc>
  2c:	89 c7                	mov    %eax,%edi
         //{//Child Process
 //int cid=fork();
 //if(cid==0)
 //error = exec("usertests", args);
 //wait(); 
                 int flag = dump_physmem(frames, pids, numframes);
  2e:	83 c4 0c             	add    $0xc,%esp
  31:	68 e8 03 00 00       	push   $0x3e8
  36:	50                   	push   %eax
  37:	56                   	push   %esi
  38:	e8 76 02 00 00       	call   2b3 <dump_physmem>
  3d:	89 c3                	mov    %eax,%ebx
                 if(flag == 0)
  3f:	83 c4 10             	add    $0x10,%esp
  42:	85 c0                	test   %eax,%eax
  44:	74 33                	je     79 <main+0x79>
                                 //if(*(pids+i) > 0)
                                         printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
                 }
                 else// if(flag == -1)
                 {
                         printf(1,"error\n");
  46:	83 ec 08             	sub    $0x8,%esp
  49:	68 25 06 00 00       	push   $0x625
  4e:	6a 01                	push   $0x1
  50:	e8 00 03 00 00       	call   355 <printf>
  55:	83 c4 10             	add    $0x10,%esp
  58:	eb 27                	jmp    81 <main+0x81>
                                         printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  5a:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  61:	ff 34 07             	pushl  (%edi,%eax,1)
  64:	ff 34 06             	pushl  (%esi,%eax,1)
  67:	68 10 06 00 00       	push   $0x610
  6c:	6a 01                	push   $0x1
  6e:	e8 e2 02 00 00       	call   355 <printf>
                         for (int i = 0; i < numframes; i++)
  73:	83 c3 01             	add    $0x1,%ebx
  76:	83 c4 10             	add    $0x10,%esp
  79:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  7f:	7e d9                	jle    5a <main+0x5a>
                 }
 
         exit();
  81:	e8 8d 01 00 00       	call   213 <exit>

00000086 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  86:	55                   	push   %ebp
  87:	89 e5                	mov    %esp,%ebp
  89:	53                   	push   %ebx
  8a:	8b 45 08             	mov    0x8(%ebp),%eax
  8d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  90:	89 c2                	mov    %eax,%edx
  92:	0f b6 19             	movzbl (%ecx),%ebx
  95:	88 1a                	mov    %bl,(%edx)
  97:	8d 52 01             	lea    0x1(%edx),%edx
  9a:	8d 49 01             	lea    0x1(%ecx),%ecx
  9d:	84 db                	test   %bl,%bl
  9f:	75 f1                	jne    92 <strcpy+0xc>
    ;
  return os;
}
  a1:	5b                   	pop    %ebx
  a2:	5d                   	pop    %ebp
  a3:	c3                   	ret    

000000a4 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  a4:	55                   	push   %ebp
  a5:	89 e5                	mov    %esp,%ebp
  a7:	8b 4d 08             	mov    0x8(%ebp),%ecx
  aa:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  ad:	eb 06                	jmp    b5 <strcmp+0x11>
    p++, q++;
  af:	83 c1 01             	add    $0x1,%ecx
  b2:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  b5:	0f b6 01             	movzbl (%ecx),%eax
  b8:	84 c0                	test   %al,%al
  ba:	74 04                	je     c0 <strcmp+0x1c>
  bc:	3a 02                	cmp    (%edx),%al
  be:	74 ef                	je     af <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  c0:	0f b6 c0             	movzbl %al,%eax
  c3:	0f b6 12             	movzbl (%edx),%edx
  c6:	29 d0                	sub    %edx,%eax
}
  c8:	5d                   	pop    %ebp
  c9:	c3                   	ret    

000000ca <strlen>:

uint
strlen(const char *s)
{
  ca:	55                   	push   %ebp
  cb:	89 e5                	mov    %esp,%ebp
  cd:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  d0:	ba 00 00 00 00       	mov    $0x0,%edx
  d5:	eb 03                	jmp    da <strlen+0x10>
  d7:	83 c2 01             	add    $0x1,%edx
  da:	89 d0                	mov    %edx,%eax
  dc:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  e0:	75 f5                	jne    d7 <strlen+0xd>
    ;
  return n;
}
  e2:	5d                   	pop    %ebp
  e3:	c3                   	ret    

000000e4 <memset>:

void*
memset(void *dst, int c, uint n)
{
  e4:	55                   	push   %ebp
  e5:	89 e5                	mov    %esp,%ebp
  e7:	57                   	push   %edi
  e8:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  eb:	89 d7                	mov    %edx,%edi
  ed:	8b 4d 10             	mov    0x10(%ebp),%ecx
  f0:	8b 45 0c             	mov    0xc(%ebp),%eax
  f3:	fc                   	cld    
  f4:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  f6:	89 d0                	mov    %edx,%eax
  f8:	5f                   	pop    %edi
  f9:	5d                   	pop    %ebp
  fa:	c3                   	ret    

000000fb <strchr>:

char*
strchr(const char *s, char c)
{
  fb:	55                   	push   %ebp
  fc:	89 e5                	mov    %esp,%ebp
  fe:	8b 45 08             	mov    0x8(%ebp),%eax
 101:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 105:	0f b6 10             	movzbl (%eax),%edx
 108:	84 d2                	test   %dl,%dl
 10a:	74 09                	je     115 <strchr+0x1a>
    if(*s == c)
 10c:	38 ca                	cmp    %cl,%dl
 10e:	74 0a                	je     11a <strchr+0x1f>
  for(; *s; s++)
 110:	83 c0 01             	add    $0x1,%eax
 113:	eb f0                	jmp    105 <strchr+0xa>
      return (char*)s;
  return 0;
 115:	b8 00 00 00 00       	mov    $0x0,%eax
}
 11a:	5d                   	pop    %ebp
 11b:	c3                   	ret    

0000011c <gets>:

char*
gets(char *buf, int max)
{
 11c:	55                   	push   %ebp
 11d:	89 e5                	mov    %esp,%ebp
 11f:	57                   	push   %edi
 120:	56                   	push   %esi
 121:	53                   	push   %ebx
 122:	83 ec 1c             	sub    $0x1c,%esp
 125:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 128:	bb 00 00 00 00       	mov    $0x0,%ebx
 12d:	8d 73 01             	lea    0x1(%ebx),%esi
 130:	3b 75 0c             	cmp    0xc(%ebp),%esi
 133:	7d 2e                	jge    163 <gets+0x47>
    cc = read(0, &c, 1);
 135:	83 ec 04             	sub    $0x4,%esp
 138:	6a 01                	push   $0x1
 13a:	8d 45 e7             	lea    -0x19(%ebp),%eax
 13d:	50                   	push   %eax
 13e:	6a 00                	push   $0x0
 140:	e8 e6 00 00 00       	call   22b <read>
    if(cc < 1)
 145:	83 c4 10             	add    $0x10,%esp
 148:	85 c0                	test   %eax,%eax
 14a:	7e 17                	jle    163 <gets+0x47>
      break;
    buf[i++] = c;
 14c:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 150:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 153:	3c 0a                	cmp    $0xa,%al
 155:	0f 94 c2             	sete   %dl
 158:	3c 0d                	cmp    $0xd,%al
 15a:	0f 94 c0             	sete   %al
    buf[i++] = c;
 15d:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 15f:	08 c2                	or     %al,%dl
 161:	74 ca                	je     12d <gets+0x11>
      break;
  }
  buf[i] = '\0';
 163:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 167:	89 f8                	mov    %edi,%eax
 169:	8d 65 f4             	lea    -0xc(%ebp),%esp
 16c:	5b                   	pop    %ebx
 16d:	5e                   	pop    %esi
 16e:	5f                   	pop    %edi
 16f:	5d                   	pop    %ebp
 170:	c3                   	ret    

00000171 <stat>:

int
stat(const char *n, struct stat *st)
{
 171:	55                   	push   %ebp
 172:	89 e5                	mov    %esp,%ebp
 174:	56                   	push   %esi
 175:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 176:	83 ec 08             	sub    $0x8,%esp
 179:	6a 00                	push   $0x0
 17b:	ff 75 08             	pushl  0x8(%ebp)
 17e:	e8 d0 00 00 00       	call   253 <open>
  if(fd < 0)
 183:	83 c4 10             	add    $0x10,%esp
 186:	85 c0                	test   %eax,%eax
 188:	78 24                	js     1ae <stat+0x3d>
 18a:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 18c:	83 ec 08             	sub    $0x8,%esp
 18f:	ff 75 0c             	pushl  0xc(%ebp)
 192:	50                   	push   %eax
 193:	e8 d3 00 00 00       	call   26b <fstat>
 198:	89 c6                	mov    %eax,%esi
  close(fd);
 19a:	89 1c 24             	mov    %ebx,(%esp)
 19d:	e8 99 00 00 00       	call   23b <close>
  return r;
 1a2:	83 c4 10             	add    $0x10,%esp
}
 1a5:	89 f0                	mov    %esi,%eax
 1a7:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1aa:	5b                   	pop    %ebx
 1ab:	5e                   	pop    %esi
 1ac:	5d                   	pop    %ebp
 1ad:	c3                   	ret    
    return -1;
 1ae:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1b3:	eb f0                	jmp    1a5 <stat+0x34>

000001b5 <atoi>:

int
atoi(const char *s)
{
 1b5:	55                   	push   %ebp
 1b6:	89 e5                	mov    %esp,%ebp
 1b8:	53                   	push   %ebx
 1b9:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1bc:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 1c1:	eb 10                	jmp    1d3 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 1c3:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 1c6:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 1c9:	83 c1 01             	add    $0x1,%ecx
 1cc:	0f be d2             	movsbl %dl,%edx
 1cf:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 1d3:	0f b6 11             	movzbl (%ecx),%edx
 1d6:	8d 5a d0             	lea    -0x30(%edx),%ebx
 1d9:	80 fb 09             	cmp    $0x9,%bl
 1dc:	76 e5                	jbe    1c3 <atoi+0xe>
  return n;
}
 1de:	5b                   	pop    %ebx
 1df:	5d                   	pop    %ebp
 1e0:	c3                   	ret    

000001e1 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 1e1:	55                   	push   %ebp
 1e2:	89 e5                	mov    %esp,%ebp
 1e4:	56                   	push   %esi
 1e5:	53                   	push   %ebx
 1e6:	8b 45 08             	mov    0x8(%ebp),%eax
 1e9:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 1ec:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 1ef:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1f1:	eb 0d                	jmp    200 <memmove+0x1f>
    *dst++ = *src++;
 1f3:	0f b6 13             	movzbl (%ebx),%edx
 1f6:	88 11                	mov    %dl,(%ecx)
 1f8:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1fb:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1fe:	89 f2                	mov    %esi,%edx
 200:	8d 72 ff             	lea    -0x1(%edx),%esi
 203:	85 d2                	test   %edx,%edx
 205:	7f ec                	jg     1f3 <memmove+0x12>
  return vdst;
}
 207:	5b                   	pop    %ebx
 208:	5e                   	pop    %esi
 209:	5d                   	pop    %ebp
 20a:	c3                   	ret    

0000020b <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 20b:	b8 01 00 00 00       	mov    $0x1,%eax
 210:	cd 40                	int    $0x40
 212:	c3                   	ret    

00000213 <exit>:
SYSCALL(exit)
 213:	b8 02 00 00 00       	mov    $0x2,%eax
 218:	cd 40                	int    $0x40
 21a:	c3                   	ret    

0000021b <wait>:
SYSCALL(wait)
 21b:	b8 03 00 00 00       	mov    $0x3,%eax
 220:	cd 40                	int    $0x40
 222:	c3                   	ret    

00000223 <pipe>:
SYSCALL(pipe)
 223:	b8 04 00 00 00       	mov    $0x4,%eax
 228:	cd 40                	int    $0x40
 22a:	c3                   	ret    

0000022b <read>:
SYSCALL(read)
 22b:	b8 05 00 00 00       	mov    $0x5,%eax
 230:	cd 40                	int    $0x40
 232:	c3                   	ret    

00000233 <write>:
SYSCALL(write)
 233:	b8 10 00 00 00       	mov    $0x10,%eax
 238:	cd 40                	int    $0x40
 23a:	c3                   	ret    

0000023b <close>:
SYSCALL(close)
 23b:	b8 15 00 00 00       	mov    $0x15,%eax
 240:	cd 40                	int    $0x40
 242:	c3                   	ret    

00000243 <kill>:
SYSCALL(kill)
 243:	b8 06 00 00 00       	mov    $0x6,%eax
 248:	cd 40                	int    $0x40
 24a:	c3                   	ret    

0000024b <exec>:
SYSCALL(exec)
 24b:	b8 07 00 00 00       	mov    $0x7,%eax
 250:	cd 40                	int    $0x40
 252:	c3                   	ret    

00000253 <open>:
SYSCALL(open)
 253:	b8 0f 00 00 00       	mov    $0xf,%eax
 258:	cd 40                	int    $0x40
 25a:	c3                   	ret    

0000025b <mknod>:
SYSCALL(mknod)
 25b:	b8 11 00 00 00       	mov    $0x11,%eax
 260:	cd 40                	int    $0x40
 262:	c3                   	ret    

00000263 <unlink>:
SYSCALL(unlink)
 263:	b8 12 00 00 00       	mov    $0x12,%eax
 268:	cd 40                	int    $0x40
 26a:	c3                   	ret    

0000026b <fstat>:
SYSCALL(fstat)
 26b:	b8 08 00 00 00       	mov    $0x8,%eax
 270:	cd 40                	int    $0x40
 272:	c3                   	ret    

00000273 <link>:
SYSCALL(link)
 273:	b8 13 00 00 00       	mov    $0x13,%eax
 278:	cd 40                	int    $0x40
 27a:	c3                   	ret    

0000027b <mkdir>:
SYSCALL(mkdir)
 27b:	b8 14 00 00 00       	mov    $0x14,%eax
 280:	cd 40                	int    $0x40
 282:	c3                   	ret    

00000283 <chdir>:
SYSCALL(chdir)
 283:	b8 09 00 00 00       	mov    $0x9,%eax
 288:	cd 40                	int    $0x40
 28a:	c3                   	ret    

0000028b <dup>:
SYSCALL(dup)
 28b:	b8 0a 00 00 00       	mov    $0xa,%eax
 290:	cd 40                	int    $0x40
 292:	c3                   	ret    

00000293 <getpid>:
SYSCALL(getpid)
 293:	b8 0b 00 00 00       	mov    $0xb,%eax
 298:	cd 40                	int    $0x40
 29a:	c3                   	ret    

0000029b <sbrk>:
SYSCALL(sbrk)
 29b:	b8 0c 00 00 00       	mov    $0xc,%eax
 2a0:	cd 40                	int    $0x40
 2a2:	c3                   	ret    

000002a3 <sleep>:
SYSCALL(sleep)
 2a3:	b8 0d 00 00 00       	mov    $0xd,%eax
 2a8:	cd 40                	int    $0x40
 2aa:	c3                   	ret    

000002ab <uptime>:
SYSCALL(uptime)
 2ab:	b8 0e 00 00 00       	mov    $0xe,%eax
 2b0:	cd 40                	int    $0x40
 2b2:	c3                   	ret    

000002b3 <dump_physmem>:
SYSCALL(dump_physmem)
 2b3:	b8 16 00 00 00       	mov    $0x16,%eax
 2b8:	cd 40                	int    $0x40
 2ba:	c3                   	ret    

000002bb <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2bb:	55                   	push   %ebp
 2bc:	89 e5                	mov    %esp,%ebp
 2be:	83 ec 1c             	sub    $0x1c,%esp
 2c1:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 2c4:	6a 01                	push   $0x1
 2c6:	8d 55 f4             	lea    -0xc(%ebp),%edx
 2c9:	52                   	push   %edx
 2ca:	50                   	push   %eax
 2cb:	e8 63 ff ff ff       	call   233 <write>
}
 2d0:	83 c4 10             	add    $0x10,%esp
 2d3:	c9                   	leave  
 2d4:	c3                   	ret    

000002d5 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 2d5:	55                   	push   %ebp
 2d6:	89 e5                	mov    %esp,%ebp
 2d8:	57                   	push   %edi
 2d9:	56                   	push   %esi
 2da:	53                   	push   %ebx
 2db:	83 ec 2c             	sub    $0x2c,%esp
 2de:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2e0:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2e4:	0f 95 c3             	setne  %bl
 2e7:	89 d0                	mov    %edx,%eax
 2e9:	c1 e8 1f             	shr    $0x1f,%eax
 2ec:	84 c3                	test   %al,%bl
 2ee:	74 10                	je     300 <printint+0x2b>
    neg = 1;
    x = -xx;
 2f0:	f7 da                	neg    %edx
    neg = 1;
 2f2:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2f9:	be 00 00 00 00       	mov    $0x0,%esi
 2fe:	eb 0b                	jmp    30b <printint+0x36>
  neg = 0;
 300:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 307:	eb f0                	jmp    2f9 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 309:	89 c6                	mov    %eax,%esi
 30b:	89 d0                	mov    %edx,%eax
 30d:	ba 00 00 00 00       	mov    $0x0,%edx
 312:	f7 f1                	div    %ecx
 314:	89 c3                	mov    %eax,%ebx
 316:	8d 46 01             	lea    0x1(%esi),%eax
 319:	0f b6 92 34 06 00 00 	movzbl 0x634(%edx),%edx
 320:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 324:	89 da                	mov    %ebx,%edx
 326:	85 db                	test   %ebx,%ebx
 328:	75 df                	jne    309 <printint+0x34>
 32a:	89 c3                	mov    %eax,%ebx
  if(neg)
 32c:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 330:	74 16                	je     348 <printint+0x73>
    buf[i++] = '-';
 332:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 337:	8d 5e 02             	lea    0x2(%esi),%ebx
 33a:	eb 0c                	jmp    348 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 33c:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 341:	89 f8                	mov    %edi,%eax
 343:	e8 73 ff ff ff       	call   2bb <putc>
  while(--i >= 0)
 348:	83 eb 01             	sub    $0x1,%ebx
 34b:	79 ef                	jns    33c <printint+0x67>
}
 34d:	83 c4 2c             	add    $0x2c,%esp
 350:	5b                   	pop    %ebx
 351:	5e                   	pop    %esi
 352:	5f                   	pop    %edi
 353:	5d                   	pop    %ebp
 354:	c3                   	ret    

00000355 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 355:	55                   	push   %ebp
 356:	89 e5                	mov    %esp,%ebp
 358:	57                   	push   %edi
 359:	56                   	push   %esi
 35a:	53                   	push   %ebx
 35b:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 35e:	8d 45 10             	lea    0x10(%ebp),%eax
 361:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 364:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 369:	bb 00 00 00 00       	mov    $0x0,%ebx
 36e:	eb 14                	jmp    384 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 370:	89 fa                	mov    %edi,%edx
 372:	8b 45 08             	mov    0x8(%ebp),%eax
 375:	e8 41 ff ff ff       	call   2bb <putc>
 37a:	eb 05                	jmp    381 <printf+0x2c>
      }
    } else if(state == '%'){
 37c:	83 fe 25             	cmp    $0x25,%esi
 37f:	74 25                	je     3a6 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 381:	83 c3 01             	add    $0x1,%ebx
 384:	8b 45 0c             	mov    0xc(%ebp),%eax
 387:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 38b:	84 c0                	test   %al,%al
 38d:	0f 84 23 01 00 00    	je     4b6 <printf+0x161>
    c = fmt[i] & 0xff;
 393:	0f be f8             	movsbl %al,%edi
 396:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 399:	85 f6                	test   %esi,%esi
 39b:	75 df                	jne    37c <printf+0x27>
      if(c == '%'){
 39d:	83 f8 25             	cmp    $0x25,%eax
 3a0:	75 ce                	jne    370 <printf+0x1b>
        state = '%';
 3a2:	89 c6                	mov    %eax,%esi
 3a4:	eb db                	jmp    381 <printf+0x2c>
      if(c == 'd'){
 3a6:	83 f8 64             	cmp    $0x64,%eax
 3a9:	74 49                	je     3f4 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3ab:	83 f8 78             	cmp    $0x78,%eax
 3ae:	0f 94 c1             	sete   %cl
 3b1:	83 f8 70             	cmp    $0x70,%eax
 3b4:	0f 94 c2             	sete   %dl
 3b7:	08 d1                	or     %dl,%cl
 3b9:	75 63                	jne    41e <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3bb:	83 f8 73             	cmp    $0x73,%eax
 3be:	0f 84 84 00 00 00    	je     448 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 3c4:	83 f8 63             	cmp    $0x63,%eax
 3c7:	0f 84 b7 00 00 00    	je     484 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 3cd:	83 f8 25             	cmp    $0x25,%eax
 3d0:	0f 84 cc 00 00 00    	je     4a2 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 3d6:	ba 25 00 00 00       	mov    $0x25,%edx
 3db:	8b 45 08             	mov    0x8(%ebp),%eax
 3de:	e8 d8 fe ff ff       	call   2bb <putc>
        putc(fd, c);
 3e3:	89 fa                	mov    %edi,%edx
 3e5:	8b 45 08             	mov    0x8(%ebp),%eax
 3e8:	e8 ce fe ff ff       	call   2bb <putc>
      }
      state = 0;
 3ed:	be 00 00 00 00       	mov    $0x0,%esi
 3f2:	eb 8d                	jmp    381 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3f4:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3f7:	8b 17                	mov    (%edi),%edx
 3f9:	83 ec 0c             	sub    $0xc,%esp
 3fc:	6a 01                	push   $0x1
 3fe:	b9 0a 00 00 00       	mov    $0xa,%ecx
 403:	8b 45 08             	mov    0x8(%ebp),%eax
 406:	e8 ca fe ff ff       	call   2d5 <printint>
        ap++;
 40b:	83 c7 04             	add    $0x4,%edi
 40e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 411:	83 c4 10             	add    $0x10,%esp
      state = 0;
 414:	be 00 00 00 00       	mov    $0x0,%esi
 419:	e9 63 ff ff ff       	jmp    381 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 41e:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 421:	8b 17                	mov    (%edi),%edx
 423:	83 ec 0c             	sub    $0xc,%esp
 426:	6a 00                	push   $0x0
 428:	b9 10 00 00 00       	mov    $0x10,%ecx
 42d:	8b 45 08             	mov    0x8(%ebp),%eax
 430:	e8 a0 fe ff ff       	call   2d5 <printint>
        ap++;
 435:	83 c7 04             	add    $0x4,%edi
 438:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 43b:	83 c4 10             	add    $0x10,%esp
      state = 0;
 43e:	be 00 00 00 00       	mov    $0x0,%esi
 443:	e9 39 ff ff ff       	jmp    381 <printf+0x2c>
        s = (char*)*ap;
 448:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 44b:	8b 30                	mov    (%eax),%esi
        ap++;
 44d:	83 c0 04             	add    $0x4,%eax
 450:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 453:	85 f6                	test   %esi,%esi
 455:	75 28                	jne    47f <printf+0x12a>
          s = "(null)";
 457:	be 2c 06 00 00       	mov    $0x62c,%esi
 45c:	8b 7d 08             	mov    0x8(%ebp),%edi
 45f:	eb 0d                	jmp    46e <printf+0x119>
          putc(fd, *s);
 461:	0f be d2             	movsbl %dl,%edx
 464:	89 f8                	mov    %edi,%eax
 466:	e8 50 fe ff ff       	call   2bb <putc>
          s++;
 46b:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 46e:	0f b6 16             	movzbl (%esi),%edx
 471:	84 d2                	test   %dl,%dl
 473:	75 ec                	jne    461 <printf+0x10c>
      state = 0;
 475:	be 00 00 00 00       	mov    $0x0,%esi
 47a:	e9 02 ff ff ff       	jmp    381 <printf+0x2c>
 47f:	8b 7d 08             	mov    0x8(%ebp),%edi
 482:	eb ea                	jmp    46e <printf+0x119>
        putc(fd, *ap);
 484:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 487:	0f be 17             	movsbl (%edi),%edx
 48a:	8b 45 08             	mov    0x8(%ebp),%eax
 48d:	e8 29 fe ff ff       	call   2bb <putc>
        ap++;
 492:	83 c7 04             	add    $0x4,%edi
 495:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 498:	be 00 00 00 00       	mov    $0x0,%esi
 49d:	e9 df fe ff ff       	jmp    381 <printf+0x2c>
        putc(fd, c);
 4a2:	89 fa                	mov    %edi,%edx
 4a4:	8b 45 08             	mov    0x8(%ebp),%eax
 4a7:	e8 0f fe ff ff       	call   2bb <putc>
      state = 0;
 4ac:	be 00 00 00 00       	mov    $0x0,%esi
 4b1:	e9 cb fe ff ff       	jmp    381 <printf+0x2c>
    }
  }
}
 4b6:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4b9:	5b                   	pop    %ebx
 4ba:	5e                   	pop    %esi
 4bb:	5f                   	pop    %edi
 4bc:	5d                   	pop    %ebp
 4bd:	c3                   	ret    

000004be <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 4be:	55                   	push   %ebp
 4bf:	89 e5                	mov    %esp,%ebp
 4c1:	57                   	push   %edi
 4c2:	56                   	push   %esi
 4c3:	53                   	push   %ebx
 4c4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 4c7:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 4ca:	a1 d8 08 00 00       	mov    0x8d8,%eax
 4cf:	eb 02                	jmp    4d3 <free+0x15>
 4d1:	89 d0                	mov    %edx,%eax
 4d3:	39 c8                	cmp    %ecx,%eax
 4d5:	73 04                	jae    4db <free+0x1d>
 4d7:	39 08                	cmp    %ecx,(%eax)
 4d9:	77 12                	ja     4ed <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4db:	8b 10                	mov    (%eax),%edx
 4dd:	39 c2                	cmp    %eax,%edx
 4df:	77 f0                	ja     4d1 <free+0x13>
 4e1:	39 c8                	cmp    %ecx,%eax
 4e3:	72 08                	jb     4ed <free+0x2f>
 4e5:	39 ca                	cmp    %ecx,%edx
 4e7:	77 04                	ja     4ed <free+0x2f>
 4e9:	89 d0                	mov    %edx,%eax
 4eb:	eb e6                	jmp    4d3 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4ed:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4f0:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4f3:	8b 10                	mov    (%eax),%edx
 4f5:	39 d7                	cmp    %edx,%edi
 4f7:	74 19                	je     512 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4f9:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4fc:	8b 50 04             	mov    0x4(%eax),%edx
 4ff:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 502:	39 ce                	cmp    %ecx,%esi
 504:	74 1b                	je     521 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 506:	89 08                	mov    %ecx,(%eax)
  freep = p;
 508:	a3 d8 08 00 00       	mov    %eax,0x8d8
}
 50d:	5b                   	pop    %ebx
 50e:	5e                   	pop    %esi
 50f:	5f                   	pop    %edi
 510:	5d                   	pop    %ebp
 511:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 512:	03 72 04             	add    0x4(%edx),%esi
 515:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 518:	8b 10                	mov    (%eax),%edx
 51a:	8b 12                	mov    (%edx),%edx
 51c:	89 53 f8             	mov    %edx,-0x8(%ebx)
 51f:	eb db                	jmp    4fc <free+0x3e>
    p->s.size += bp->s.size;
 521:	03 53 fc             	add    -0x4(%ebx),%edx
 524:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 527:	8b 53 f8             	mov    -0x8(%ebx),%edx
 52a:	89 10                	mov    %edx,(%eax)
 52c:	eb da                	jmp    508 <free+0x4a>

0000052e <morecore>:

static Header*
morecore(uint nu)
{
 52e:	55                   	push   %ebp
 52f:	89 e5                	mov    %esp,%ebp
 531:	53                   	push   %ebx
 532:	83 ec 04             	sub    $0x4,%esp
 535:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 537:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 53c:	77 05                	ja     543 <morecore+0x15>
    nu = 4096;
 53e:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 543:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 54a:	83 ec 0c             	sub    $0xc,%esp
 54d:	50                   	push   %eax
 54e:	e8 48 fd ff ff       	call   29b <sbrk>
  if(p == (char*)-1)
 553:	83 c4 10             	add    $0x10,%esp
 556:	83 f8 ff             	cmp    $0xffffffff,%eax
 559:	74 1c                	je     577 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 55b:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 55e:	83 c0 08             	add    $0x8,%eax
 561:	83 ec 0c             	sub    $0xc,%esp
 564:	50                   	push   %eax
 565:	e8 54 ff ff ff       	call   4be <free>
  return freep;
 56a:	a1 d8 08 00 00       	mov    0x8d8,%eax
 56f:	83 c4 10             	add    $0x10,%esp
}
 572:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 575:	c9                   	leave  
 576:	c3                   	ret    
    return 0;
 577:	b8 00 00 00 00       	mov    $0x0,%eax
 57c:	eb f4                	jmp    572 <morecore+0x44>

0000057e <malloc>:

void*
malloc(uint nbytes)
{
 57e:	55                   	push   %ebp
 57f:	89 e5                	mov    %esp,%ebp
 581:	53                   	push   %ebx
 582:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 585:	8b 45 08             	mov    0x8(%ebp),%eax
 588:	8d 58 07             	lea    0x7(%eax),%ebx
 58b:	c1 eb 03             	shr    $0x3,%ebx
 58e:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 591:	8b 0d d8 08 00 00    	mov    0x8d8,%ecx
 597:	85 c9                	test   %ecx,%ecx
 599:	74 04                	je     59f <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 59b:	8b 01                	mov    (%ecx),%eax
 59d:	eb 4d                	jmp    5ec <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 59f:	c7 05 d8 08 00 00 dc 	movl   $0x8dc,0x8d8
 5a6:	08 00 00 
 5a9:	c7 05 dc 08 00 00 dc 	movl   $0x8dc,0x8dc
 5b0:	08 00 00 
    base.s.size = 0;
 5b3:	c7 05 e0 08 00 00 00 	movl   $0x0,0x8e0
 5ba:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 5bd:	b9 dc 08 00 00       	mov    $0x8dc,%ecx
 5c2:	eb d7                	jmp    59b <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 5c4:	39 da                	cmp    %ebx,%edx
 5c6:	74 1a                	je     5e2 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 5c8:	29 da                	sub    %ebx,%edx
 5ca:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 5cd:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 5d0:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 5d3:	89 0d d8 08 00 00    	mov    %ecx,0x8d8
      return (void*)(p + 1);
 5d9:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5dc:	83 c4 04             	add    $0x4,%esp
 5df:	5b                   	pop    %ebx
 5e0:	5d                   	pop    %ebp
 5e1:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5e2:	8b 10                	mov    (%eax),%edx
 5e4:	89 11                	mov    %edx,(%ecx)
 5e6:	eb eb                	jmp    5d3 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5e8:	89 c1                	mov    %eax,%ecx
 5ea:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5ec:	8b 50 04             	mov    0x4(%eax),%edx
 5ef:	39 da                	cmp    %ebx,%edx
 5f1:	73 d1                	jae    5c4 <malloc+0x46>
    if(p == freep)
 5f3:	39 05 d8 08 00 00    	cmp    %eax,0x8d8
 5f9:	75 ed                	jne    5e8 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5fb:	89 d8                	mov    %ebx,%eax
 5fd:	e8 2c ff ff ff       	call   52e <morecore>
 602:	85 c0                	test   %eax,%eax
 604:	75 e2                	jne    5e8 <malloc+0x6a>
        return 0;
 606:	b8 00 00 00 00       	mov    $0x0,%eax
 60b:	eb cf                	jmp    5dc <malloc+0x5e>
