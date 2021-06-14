
_test_11:     file format elf32-i386


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
  11:	83 ec 24             	sub    $0x24,%esp
        int numframes = 1000;
          char *args[1];
          args[0] = "ls";
  14:	c7 45 e4 84 06 00 00 	movl   $0x684,-0x1c(%ebp)
         int error=-11;
         int* frames = malloc(numframes * sizeof(int));
  1b:	68 a0 0f 00 00       	push   $0xfa0
  20:	e8 ce 05 00 00       	call   5f3 <malloc>
  25:	89 c6                	mov    %eax,%esi
         int* pids = malloc(numframes * sizeof(int));
  27:	c7 04 24 a0 0f 00 00 	movl   $0xfa0,(%esp)
  2e:	e8 c0 05 00 00       	call   5f3 <malloc>
  33:	89 c7                	mov    %eax,%edi
         //cid = fork();
         //if(cid == 0)
         //{//Child Process
                 int cid=fork();
  35:	e8 46 02 00 00       	call   280 <fork>
                 if(cid==0)
  3a:	83 c4 10             	add    $0x10,%esp
  3d:	85 c0                	test   %eax,%eax
  3f:	74 4a                	je     8b <main+0x8b>
         int error=-11;
  41:	bb f5 ff ff ff       	mov    $0xfffffff5,%ebx
                 error = exec("ls", args);
                 wait();
  46:	e8 45 02 00 00       	call   290 <wait>
 
                 cid=fork();
  4b:	e8 30 02 00 00       	call   280 <fork>
                 if(cid==0)
  50:	85 c0                	test   %eax,%eax
  52:	74 4f                	je     a3 <main+0xa3>
                 error = exec("ls", args);
 
                 sleep(10);
  54:	83 ec 0c             	sub    $0xc,%esp
  57:	6a 0a                	push   $0xa
  59:	e8 ba 02 00 00       	call   318 <sleep>
                 wait();
  5e:	e8 2d 02 00 00       	call   290 <wait>
                 int flag = dump_physmem(frames, pids, numframes);
  63:	83 c4 0c             	add    $0xc,%esp
  66:	68 e8 03 00 00       	push   $0x3e8
  6b:	57                   	push   %edi
  6c:	56                   	push   %esi
  6d:	e8 b6 02 00 00       	call   328 <dump_physmem>
                 if(flag == 0 && error!=-10)
  72:	83 c4 10             	add    $0x10,%esp
  75:	85 c0                	test   %eax,%eax
  77:	0f 94 c2             	sete   %dl
  7a:	83 fb f6             	cmp    $0xfffffff6,%ebx
  7d:	0f 95 c0             	setne  %al
  80:	84 c2                	test   %al,%dl
  82:	74 63                	je     e7 <main+0xe7>
                 {
                         for (int i = 0; i < numframes; i++)
  84:	bb 00 00 00 00       	mov    $0x0,%ebx
  89:	eb 4f                	jmp    da <main+0xda>
                 error = exec("ls", args);
  8b:	83 ec 08             	sub    $0x8,%esp
  8e:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  91:	50                   	push   %eax
  92:	68 84 06 00 00       	push   $0x684
  97:	e8 24 02 00 00       	call   2c0 <exec>
  9c:	89 c3                	mov    %eax,%ebx
  9e:	83 c4 10             	add    $0x10,%esp
  a1:	eb a3                	jmp    46 <main+0x46>
                 error = exec("ls", args);
  a3:	83 ec 08             	sub    $0x8,%esp
  a6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  a9:	50                   	push   %eax
  aa:	68 84 06 00 00       	push   $0x684
  af:	e8 0c 02 00 00       	call   2c0 <exec>
  b4:	89 c3                	mov    %eax,%ebx
  b6:	83 c4 10             	add    $0x10,%esp
  b9:	eb 99                	jmp    54 <main+0x54>
                                 //if(*(pids+i) > 0)
                                         printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  bb:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  c2:	ff 34 07             	pushl  (%edi,%eax,1)
  c5:	ff 34 06             	pushl  (%esi,%eax,1)
  c8:	68 87 06 00 00       	push   $0x687
  cd:	6a 01                	push   $0x1
  cf:	e8 f6 02 00 00       	call   3ca <printf>
                         for (int i = 0; i < numframes; i++)
  d4:	83 c3 01             	add    $0x1,%ebx
  d7:	83 c4 10             	add    $0x10,%esp
  da:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  e0:	7e d9                	jle    bb <main+0xbb>
                 else// if(flag == -1)
                 {
                         printf(1,"error\n");
                 }
 
         exit();
  e2:	e8 a1 01 00 00       	call   288 <exit>
                         printf(1,"error\n");
  e7:	83 ec 08             	sub    $0x8,%esp
  ea:	68 9c 06 00 00       	push   $0x69c
  ef:	6a 01                	push   $0x1
  f1:	e8 d4 02 00 00       	call   3ca <printf>
  f6:	83 c4 10             	add    $0x10,%esp
  f9:	eb e7                	jmp    e2 <main+0xe2>

000000fb <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  fb:	55                   	push   %ebp
  fc:	89 e5                	mov    %esp,%ebp
  fe:	53                   	push   %ebx
  ff:	8b 45 08             	mov    0x8(%ebp),%eax
 102:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 105:	89 c2                	mov    %eax,%edx
 107:	0f b6 19             	movzbl (%ecx),%ebx
 10a:	88 1a                	mov    %bl,(%edx)
 10c:	8d 52 01             	lea    0x1(%edx),%edx
 10f:	8d 49 01             	lea    0x1(%ecx),%ecx
 112:	84 db                	test   %bl,%bl
 114:	75 f1                	jne    107 <strcpy+0xc>
    ;
  return os;
}
 116:	5b                   	pop    %ebx
 117:	5d                   	pop    %ebp
 118:	c3                   	ret    

00000119 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 119:	55                   	push   %ebp
 11a:	89 e5                	mov    %esp,%ebp
 11c:	8b 4d 08             	mov    0x8(%ebp),%ecx
 11f:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 122:	eb 06                	jmp    12a <strcmp+0x11>
    p++, q++;
 124:	83 c1 01             	add    $0x1,%ecx
 127:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 12a:	0f b6 01             	movzbl (%ecx),%eax
 12d:	84 c0                	test   %al,%al
 12f:	74 04                	je     135 <strcmp+0x1c>
 131:	3a 02                	cmp    (%edx),%al
 133:	74 ef                	je     124 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 135:	0f b6 c0             	movzbl %al,%eax
 138:	0f b6 12             	movzbl (%edx),%edx
 13b:	29 d0                	sub    %edx,%eax
}
 13d:	5d                   	pop    %ebp
 13e:	c3                   	ret    

0000013f <strlen>:

uint
strlen(const char *s)
{
 13f:	55                   	push   %ebp
 140:	89 e5                	mov    %esp,%ebp
 142:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 145:	ba 00 00 00 00       	mov    $0x0,%edx
 14a:	eb 03                	jmp    14f <strlen+0x10>
 14c:	83 c2 01             	add    $0x1,%edx
 14f:	89 d0                	mov    %edx,%eax
 151:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 155:	75 f5                	jne    14c <strlen+0xd>
    ;
  return n;
}
 157:	5d                   	pop    %ebp
 158:	c3                   	ret    

00000159 <memset>:

void*
memset(void *dst, int c, uint n)
{
 159:	55                   	push   %ebp
 15a:	89 e5                	mov    %esp,%ebp
 15c:	57                   	push   %edi
 15d:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 160:	89 d7                	mov    %edx,%edi
 162:	8b 4d 10             	mov    0x10(%ebp),%ecx
 165:	8b 45 0c             	mov    0xc(%ebp),%eax
 168:	fc                   	cld    
 169:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 16b:	89 d0                	mov    %edx,%eax
 16d:	5f                   	pop    %edi
 16e:	5d                   	pop    %ebp
 16f:	c3                   	ret    

00000170 <strchr>:

char*
strchr(const char *s, char c)
{
 170:	55                   	push   %ebp
 171:	89 e5                	mov    %esp,%ebp
 173:	8b 45 08             	mov    0x8(%ebp),%eax
 176:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 17a:	0f b6 10             	movzbl (%eax),%edx
 17d:	84 d2                	test   %dl,%dl
 17f:	74 09                	je     18a <strchr+0x1a>
    if(*s == c)
 181:	38 ca                	cmp    %cl,%dl
 183:	74 0a                	je     18f <strchr+0x1f>
  for(; *s; s++)
 185:	83 c0 01             	add    $0x1,%eax
 188:	eb f0                	jmp    17a <strchr+0xa>
      return (char*)s;
  return 0;
 18a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 18f:	5d                   	pop    %ebp
 190:	c3                   	ret    

00000191 <gets>:

char*
gets(char *buf, int max)
{
 191:	55                   	push   %ebp
 192:	89 e5                	mov    %esp,%ebp
 194:	57                   	push   %edi
 195:	56                   	push   %esi
 196:	53                   	push   %ebx
 197:	83 ec 1c             	sub    $0x1c,%esp
 19a:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 19d:	bb 00 00 00 00       	mov    $0x0,%ebx
 1a2:	8d 73 01             	lea    0x1(%ebx),%esi
 1a5:	3b 75 0c             	cmp    0xc(%ebp),%esi
 1a8:	7d 2e                	jge    1d8 <gets+0x47>
    cc = read(0, &c, 1);
 1aa:	83 ec 04             	sub    $0x4,%esp
 1ad:	6a 01                	push   $0x1
 1af:	8d 45 e7             	lea    -0x19(%ebp),%eax
 1b2:	50                   	push   %eax
 1b3:	6a 00                	push   $0x0
 1b5:	e8 e6 00 00 00       	call   2a0 <read>
    if(cc < 1)
 1ba:	83 c4 10             	add    $0x10,%esp
 1bd:	85 c0                	test   %eax,%eax
 1bf:	7e 17                	jle    1d8 <gets+0x47>
      break;
    buf[i++] = c;
 1c1:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1c5:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1c8:	3c 0a                	cmp    $0xa,%al
 1ca:	0f 94 c2             	sete   %dl
 1cd:	3c 0d                	cmp    $0xd,%al
 1cf:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1d2:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1d4:	08 c2                	or     %al,%dl
 1d6:	74 ca                	je     1a2 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1d8:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1dc:	89 f8                	mov    %edi,%eax
 1de:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1e1:	5b                   	pop    %ebx
 1e2:	5e                   	pop    %esi
 1e3:	5f                   	pop    %edi
 1e4:	5d                   	pop    %ebp
 1e5:	c3                   	ret    

000001e6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1e6:	55                   	push   %ebp
 1e7:	89 e5                	mov    %esp,%ebp
 1e9:	56                   	push   %esi
 1ea:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1eb:	83 ec 08             	sub    $0x8,%esp
 1ee:	6a 00                	push   $0x0
 1f0:	ff 75 08             	pushl  0x8(%ebp)
 1f3:	e8 d0 00 00 00       	call   2c8 <open>
  if(fd < 0)
 1f8:	83 c4 10             	add    $0x10,%esp
 1fb:	85 c0                	test   %eax,%eax
 1fd:	78 24                	js     223 <stat+0x3d>
 1ff:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 201:	83 ec 08             	sub    $0x8,%esp
 204:	ff 75 0c             	pushl  0xc(%ebp)
 207:	50                   	push   %eax
 208:	e8 d3 00 00 00       	call   2e0 <fstat>
 20d:	89 c6                	mov    %eax,%esi
  close(fd);
 20f:	89 1c 24             	mov    %ebx,(%esp)
 212:	e8 99 00 00 00       	call   2b0 <close>
  return r;
 217:	83 c4 10             	add    $0x10,%esp
}
 21a:	89 f0                	mov    %esi,%eax
 21c:	8d 65 f8             	lea    -0x8(%ebp),%esp
 21f:	5b                   	pop    %ebx
 220:	5e                   	pop    %esi
 221:	5d                   	pop    %ebp
 222:	c3                   	ret    
    return -1;
 223:	be ff ff ff ff       	mov    $0xffffffff,%esi
 228:	eb f0                	jmp    21a <stat+0x34>

0000022a <atoi>:

int
atoi(const char *s)
{
 22a:	55                   	push   %ebp
 22b:	89 e5                	mov    %esp,%ebp
 22d:	53                   	push   %ebx
 22e:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 231:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 236:	eb 10                	jmp    248 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 238:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 23b:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 23e:	83 c1 01             	add    $0x1,%ecx
 241:	0f be d2             	movsbl %dl,%edx
 244:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 248:	0f b6 11             	movzbl (%ecx),%edx
 24b:	8d 5a d0             	lea    -0x30(%edx),%ebx
 24e:	80 fb 09             	cmp    $0x9,%bl
 251:	76 e5                	jbe    238 <atoi+0xe>
  return n;
}
 253:	5b                   	pop    %ebx
 254:	5d                   	pop    %ebp
 255:	c3                   	ret    

00000256 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 256:	55                   	push   %ebp
 257:	89 e5                	mov    %esp,%ebp
 259:	56                   	push   %esi
 25a:	53                   	push   %ebx
 25b:	8b 45 08             	mov    0x8(%ebp),%eax
 25e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 261:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 264:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 266:	eb 0d                	jmp    275 <memmove+0x1f>
    *dst++ = *src++;
 268:	0f b6 13             	movzbl (%ebx),%edx
 26b:	88 11                	mov    %dl,(%ecx)
 26d:	8d 5b 01             	lea    0x1(%ebx),%ebx
 270:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 273:	89 f2                	mov    %esi,%edx
 275:	8d 72 ff             	lea    -0x1(%edx),%esi
 278:	85 d2                	test   %edx,%edx
 27a:	7f ec                	jg     268 <memmove+0x12>
  return vdst;
}
 27c:	5b                   	pop    %ebx
 27d:	5e                   	pop    %esi
 27e:	5d                   	pop    %ebp
 27f:	c3                   	ret    

00000280 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 280:	b8 01 00 00 00       	mov    $0x1,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <exit>:
SYSCALL(exit)
 288:	b8 02 00 00 00       	mov    $0x2,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <wait>:
SYSCALL(wait)
 290:	b8 03 00 00 00       	mov    $0x3,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <pipe>:
SYSCALL(pipe)
 298:	b8 04 00 00 00       	mov    $0x4,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <read>:
SYSCALL(read)
 2a0:	b8 05 00 00 00       	mov    $0x5,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <write>:
SYSCALL(write)
 2a8:	b8 10 00 00 00       	mov    $0x10,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <close>:
SYSCALL(close)
 2b0:	b8 15 00 00 00       	mov    $0x15,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <kill>:
SYSCALL(kill)
 2b8:	b8 06 00 00 00       	mov    $0x6,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <exec>:
SYSCALL(exec)
 2c0:	b8 07 00 00 00       	mov    $0x7,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <open>:
SYSCALL(open)
 2c8:	b8 0f 00 00 00       	mov    $0xf,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <mknod>:
SYSCALL(mknod)
 2d0:	b8 11 00 00 00       	mov    $0x11,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <unlink>:
SYSCALL(unlink)
 2d8:	b8 12 00 00 00       	mov    $0x12,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <fstat>:
SYSCALL(fstat)
 2e0:	b8 08 00 00 00       	mov    $0x8,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <link>:
SYSCALL(link)
 2e8:	b8 13 00 00 00       	mov    $0x13,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <mkdir>:
SYSCALL(mkdir)
 2f0:	b8 14 00 00 00       	mov    $0x14,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <chdir>:
SYSCALL(chdir)
 2f8:	b8 09 00 00 00       	mov    $0x9,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <dup>:
SYSCALL(dup)
 300:	b8 0a 00 00 00       	mov    $0xa,%eax
 305:	cd 40                	int    $0x40
 307:	c3                   	ret    

00000308 <getpid>:
SYSCALL(getpid)
 308:	b8 0b 00 00 00       	mov    $0xb,%eax
 30d:	cd 40                	int    $0x40
 30f:	c3                   	ret    

00000310 <sbrk>:
SYSCALL(sbrk)
 310:	b8 0c 00 00 00       	mov    $0xc,%eax
 315:	cd 40                	int    $0x40
 317:	c3                   	ret    

00000318 <sleep>:
SYSCALL(sleep)
 318:	b8 0d 00 00 00       	mov    $0xd,%eax
 31d:	cd 40                	int    $0x40
 31f:	c3                   	ret    

00000320 <uptime>:
SYSCALL(uptime)
 320:	b8 0e 00 00 00       	mov    $0xe,%eax
 325:	cd 40                	int    $0x40
 327:	c3                   	ret    

00000328 <dump_physmem>:
SYSCALL(dump_physmem)
 328:	b8 16 00 00 00       	mov    $0x16,%eax
 32d:	cd 40                	int    $0x40
 32f:	c3                   	ret    

00000330 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 330:	55                   	push   %ebp
 331:	89 e5                	mov    %esp,%ebp
 333:	83 ec 1c             	sub    $0x1c,%esp
 336:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 339:	6a 01                	push   $0x1
 33b:	8d 55 f4             	lea    -0xc(%ebp),%edx
 33e:	52                   	push   %edx
 33f:	50                   	push   %eax
 340:	e8 63 ff ff ff       	call   2a8 <write>
}
 345:	83 c4 10             	add    $0x10,%esp
 348:	c9                   	leave  
 349:	c3                   	ret    

0000034a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 34a:	55                   	push   %ebp
 34b:	89 e5                	mov    %esp,%ebp
 34d:	57                   	push   %edi
 34e:	56                   	push   %esi
 34f:	53                   	push   %ebx
 350:	83 ec 2c             	sub    $0x2c,%esp
 353:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 355:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 359:	0f 95 c3             	setne  %bl
 35c:	89 d0                	mov    %edx,%eax
 35e:	c1 e8 1f             	shr    $0x1f,%eax
 361:	84 c3                	test   %al,%bl
 363:	74 10                	je     375 <printint+0x2b>
    neg = 1;
    x = -xx;
 365:	f7 da                	neg    %edx
    neg = 1;
 367:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 36e:	be 00 00 00 00       	mov    $0x0,%esi
 373:	eb 0b                	jmp    380 <printint+0x36>
  neg = 0;
 375:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 37c:	eb f0                	jmp    36e <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 37e:	89 c6                	mov    %eax,%esi
 380:	89 d0                	mov    %edx,%eax
 382:	ba 00 00 00 00       	mov    $0x0,%edx
 387:	f7 f1                	div    %ecx
 389:	89 c3                	mov    %eax,%ebx
 38b:	8d 46 01             	lea    0x1(%esi),%eax
 38e:	0f b6 92 ac 06 00 00 	movzbl 0x6ac(%edx),%edx
 395:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 399:	89 da                	mov    %ebx,%edx
 39b:	85 db                	test   %ebx,%ebx
 39d:	75 df                	jne    37e <printint+0x34>
 39f:	89 c3                	mov    %eax,%ebx
  if(neg)
 3a1:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 3a5:	74 16                	je     3bd <printint+0x73>
    buf[i++] = '-';
 3a7:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 3ac:	8d 5e 02             	lea    0x2(%esi),%ebx
 3af:	eb 0c                	jmp    3bd <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 3b1:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 3b6:	89 f8                	mov    %edi,%eax
 3b8:	e8 73 ff ff ff       	call   330 <putc>
  while(--i >= 0)
 3bd:	83 eb 01             	sub    $0x1,%ebx
 3c0:	79 ef                	jns    3b1 <printint+0x67>
}
 3c2:	83 c4 2c             	add    $0x2c,%esp
 3c5:	5b                   	pop    %ebx
 3c6:	5e                   	pop    %esi
 3c7:	5f                   	pop    %edi
 3c8:	5d                   	pop    %ebp
 3c9:	c3                   	ret    

000003ca <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3ca:	55                   	push   %ebp
 3cb:	89 e5                	mov    %esp,%ebp
 3cd:	57                   	push   %edi
 3ce:	56                   	push   %esi
 3cf:	53                   	push   %ebx
 3d0:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3d3:	8d 45 10             	lea    0x10(%ebp),%eax
 3d6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3d9:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3de:	bb 00 00 00 00       	mov    $0x0,%ebx
 3e3:	eb 14                	jmp    3f9 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3e5:	89 fa                	mov    %edi,%edx
 3e7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ea:	e8 41 ff ff ff       	call   330 <putc>
 3ef:	eb 05                	jmp    3f6 <printf+0x2c>
      }
    } else if(state == '%'){
 3f1:	83 fe 25             	cmp    $0x25,%esi
 3f4:	74 25                	je     41b <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3f6:	83 c3 01             	add    $0x1,%ebx
 3f9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3fc:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 400:	84 c0                	test   %al,%al
 402:	0f 84 23 01 00 00    	je     52b <printf+0x161>
    c = fmt[i] & 0xff;
 408:	0f be f8             	movsbl %al,%edi
 40b:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 40e:	85 f6                	test   %esi,%esi
 410:	75 df                	jne    3f1 <printf+0x27>
      if(c == '%'){
 412:	83 f8 25             	cmp    $0x25,%eax
 415:	75 ce                	jne    3e5 <printf+0x1b>
        state = '%';
 417:	89 c6                	mov    %eax,%esi
 419:	eb db                	jmp    3f6 <printf+0x2c>
      if(c == 'd'){
 41b:	83 f8 64             	cmp    $0x64,%eax
 41e:	74 49                	je     469 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 420:	83 f8 78             	cmp    $0x78,%eax
 423:	0f 94 c1             	sete   %cl
 426:	83 f8 70             	cmp    $0x70,%eax
 429:	0f 94 c2             	sete   %dl
 42c:	08 d1                	or     %dl,%cl
 42e:	75 63                	jne    493 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 430:	83 f8 73             	cmp    $0x73,%eax
 433:	0f 84 84 00 00 00    	je     4bd <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 439:	83 f8 63             	cmp    $0x63,%eax
 43c:	0f 84 b7 00 00 00    	je     4f9 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 442:	83 f8 25             	cmp    $0x25,%eax
 445:	0f 84 cc 00 00 00    	je     517 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 44b:	ba 25 00 00 00       	mov    $0x25,%edx
 450:	8b 45 08             	mov    0x8(%ebp),%eax
 453:	e8 d8 fe ff ff       	call   330 <putc>
        putc(fd, c);
 458:	89 fa                	mov    %edi,%edx
 45a:	8b 45 08             	mov    0x8(%ebp),%eax
 45d:	e8 ce fe ff ff       	call   330 <putc>
      }
      state = 0;
 462:	be 00 00 00 00       	mov    $0x0,%esi
 467:	eb 8d                	jmp    3f6 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 46c:	8b 17                	mov    (%edi),%edx
 46e:	83 ec 0c             	sub    $0xc,%esp
 471:	6a 01                	push   $0x1
 473:	b9 0a 00 00 00       	mov    $0xa,%ecx
 478:	8b 45 08             	mov    0x8(%ebp),%eax
 47b:	e8 ca fe ff ff       	call   34a <printint>
        ap++;
 480:	83 c7 04             	add    $0x4,%edi
 483:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 486:	83 c4 10             	add    $0x10,%esp
      state = 0;
 489:	be 00 00 00 00       	mov    $0x0,%esi
 48e:	e9 63 ff ff ff       	jmp    3f6 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 493:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 496:	8b 17                	mov    (%edi),%edx
 498:	83 ec 0c             	sub    $0xc,%esp
 49b:	6a 00                	push   $0x0
 49d:	b9 10 00 00 00       	mov    $0x10,%ecx
 4a2:	8b 45 08             	mov    0x8(%ebp),%eax
 4a5:	e8 a0 fe ff ff       	call   34a <printint>
        ap++;
 4aa:	83 c7 04             	add    $0x4,%edi
 4ad:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 4b0:	83 c4 10             	add    $0x10,%esp
      state = 0;
 4b3:	be 00 00 00 00       	mov    $0x0,%esi
 4b8:	e9 39 ff ff ff       	jmp    3f6 <printf+0x2c>
        s = (char*)*ap;
 4bd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4c0:	8b 30                	mov    (%eax),%esi
        ap++;
 4c2:	83 c0 04             	add    $0x4,%eax
 4c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4c8:	85 f6                	test   %esi,%esi
 4ca:	75 28                	jne    4f4 <printf+0x12a>
          s = "(null)";
 4cc:	be a3 06 00 00       	mov    $0x6a3,%esi
 4d1:	8b 7d 08             	mov    0x8(%ebp),%edi
 4d4:	eb 0d                	jmp    4e3 <printf+0x119>
          putc(fd, *s);
 4d6:	0f be d2             	movsbl %dl,%edx
 4d9:	89 f8                	mov    %edi,%eax
 4db:	e8 50 fe ff ff       	call   330 <putc>
          s++;
 4e0:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4e3:	0f b6 16             	movzbl (%esi),%edx
 4e6:	84 d2                	test   %dl,%dl
 4e8:	75 ec                	jne    4d6 <printf+0x10c>
      state = 0;
 4ea:	be 00 00 00 00       	mov    $0x0,%esi
 4ef:	e9 02 ff ff ff       	jmp    3f6 <printf+0x2c>
 4f4:	8b 7d 08             	mov    0x8(%ebp),%edi
 4f7:	eb ea                	jmp    4e3 <printf+0x119>
        putc(fd, *ap);
 4f9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4fc:	0f be 17             	movsbl (%edi),%edx
 4ff:	8b 45 08             	mov    0x8(%ebp),%eax
 502:	e8 29 fe ff ff       	call   330 <putc>
        ap++;
 507:	83 c7 04             	add    $0x4,%edi
 50a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 50d:	be 00 00 00 00       	mov    $0x0,%esi
 512:	e9 df fe ff ff       	jmp    3f6 <printf+0x2c>
        putc(fd, c);
 517:	89 fa                	mov    %edi,%edx
 519:	8b 45 08             	mov    0x8(%ebp),%eax
 51c:	e8 0f fe ff ff       	call   330 <putc>
      state = 0;
 521:	be 00 00 00 00       	mov    $0x0,%esi
 526:	e9 cb fe ff ff       	jmp    3f6 <printf+0x2c>
    }
  }
}
 52b:	8d 65 f4             	lea    -0xc(%ebp),%esp
 52e:	5b                   	pop    %ebx
 52f:	5e                   	pop    %esi
 530:	5f                   	pop    %edi
 531:	5d                   	pop    %ebp
 532:	c3                   	ret    

00000533 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 533:	55                   	push   %ebp
 534:	89 e5                	mov    %esp,%ebp
 536:	57                   	push   %edi
 537:	56                   	push   %esi
 538:	53                   	push   %ebx
 539:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 53c:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 53f:	a1 50 09 00 00       	mov    0x950,%eax
 544:	eb 02                	jmp    548 <free+0x15>
 546:	89 d0                	mov    %edx,%eax
 548:	39 c8                	cmp    %ecx,%eax
 54a:	73 04                	jae    550 <free+0x1d>
 54c:	39 08                	cmp    %ecx,(%eax)
 54e:	77 12                	ja     562 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 550:	8b 10                	mov    (%eax),%edx
 552:	39 c2                	cmp    %eax,%edx
 554:	77 f0                	ja     546 <free+0x13>
 556:	39 c8                	cmp    %ecx,%eax
 558:	72 08                	jb     562 <free+0x2f>
 55a:	39 ca                	cmp    %ecx,%edx
 55c:	77 04                	ja     562 <free+0x2f>
 55e:	89 d0                	mov    %edx,%eax
 560:	eb e6                	jmp    548 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 562:	8b 73 fc             	mov    -0x4(%ebx),%esi
 565:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 568:	8b 10                	mov    (%eax),%edx
 56a:	39 d7                	cmp    %edx,%edi
 56c:	74 19                	je     587 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 56e:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 571:	8b 50 04             	mov    0x4(%eax),%edx
 574:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 577:	39 ce                	cmp    %ecx,%esi
 579:	74 1b                	je     596 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 57b:	89 08                	mov    %ecx,(%eax)
  freep = p;
 57d:	a3 50 09 00 00       	mov    %eax,0x950
}
 582:	5b                   	pop    %ebx
 583:	5e                   	pop    %esi
 584:	5f                   	pop    %edi
 585:	5d                   	pop    %ebp
 586:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 587:	03 72 04             	add    0x4(%edx),%esi
 58a:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 58d:	8b 10                	mov    (%eax),%edx
 58f:	8b 12                	mov    (%edx),%edx
 591:	89 53 f8             	mov    %edx,-0x8(%ebx)
 594:	eb db                	jmp    571 <free+0x3e>
    p->s.size += bp->s.size;
 596:	03 53 fc             	add    -0x4(%ebx),%edx
 599:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 59c:	8b 53 f8             	mov    -0x8(%ebx),%edx
 59f:	89 10                	mov    %edx,(%eax)
 5a1:	eb da                	jmp    57d <free+0x4a>

000005a3 <morecore>:

static Header*
morecore(uint nu)
{
 5a3:	55                   	push   %ebp
 5a4:	89 e5                	mov    %esp,%ebp
 5a6:	53                   	push   %ebx
 5a7:	83 ec 04             	sub    $0x4,%esp
 5aa:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 5ac:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 5b1:	77 05                	ja     5b8 <morecore+0x15>
    nu = 4096;
 5b3:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 5b8:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5bf:	83 ec 0c             	sub    $0xc,%esp
 5c2:	50                   	push   %eax
 5c3:	e8 48 fd ff ff       	call   310 <sbrk>
  if(p == (char*)-1)
 5c8:	83 c4 10             	add    $0x10,%esp
 5cb:	83 f8 ff             	cmp    $0xffffffff,%eax
 5ce:	74 1c                	je     5ec <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5d0:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5d3:	83 c0 08             	add    $0x8,%eax
 5d6:	83 ec 0c             	sub    $0xc,%esp
 5d9:	50                   	push   %eax
 5da:	e8 54 ff ff ff       	call   533 <free>
  return freep;
 5df:	a1 50 09 00 00       	mov    0x950,%eax
 5e4:	83 c4 10             	add    $0x10,%esp
}
 5e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5ea:	c9                   	leave  
 5eb:	c3                   	ret    
    return 0;
 5ec:	b8 00 00 00 00       	mov    $0x0,%eax
 5f1:	eb f4                	jmp    5e7 <morecore+0x44>

000005f3 <malloc>:

void*
malloc(uint nbytes)
{
 5f3:	55                   	push   %ebp
 5f4:	89 e5                	mov    %esp,%ebp
 5f6:	53                   	push   %ebx
 5f7:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5fa:	8b 45 08             	mov    0x8(%ebp),%eax
 5fd:	8d 58 07             	lea    0x7(%eax),%ebx
 600:	c1 eb 03             	shr    $0x3,%ebx
 603:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 606:	8b 0d 50 09 00 00    	mov    0x950,%ecx
 60c:	85 c9                	test   %ecx,%ecx
 60e:	74 04                	je     614 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 610:	8b 01                	mov    (%ecx),%eax
 612:	eb 4d                	jmp    661 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 614:	c7 05 50 09 00 00 54 	movl   $0x954,0x950
 61b:	09 00 00 
 61e:	c7 05 54 09 00 00 54 	movl   $0x954,0x954
 625:	09 00 00 
    base.s.size = 0;
 628:	c7 05 58 09 00 00 00 	movl   $0x0,0x958
 62f:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 632:	b9 54 09 00 00       	mov    $0x954,%ecx
 637:	eb d7                	jmp    610 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 639:	39 da                	cmp    %ebx,%edx
 63b:	74 1a                	je     657 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 63d:	29 da                	sub    %ebx,%edx
 63f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 642:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 645:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 648:	89 0d 50 09 00 00    	mov    %ecx,0x950
      return (void*)(p + 1);
 64e:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 651:	83 c4 04             	add    $0x4,%esp
 654:	5b                   	pop    %ebx
 655:	5d                   	pop    %ebp
 656:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 657:	8b 10                	mov    (%eax),%edx
 659:	89 11                	mov    %edx,(%ecx)
 65b:	eb eb                	jmp    648 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 65d:	89 c1                	mov    %eax,%ecx
 65f:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 661:	8b 50 04             	mov    0x4(%eax),%edx
 664:	39 da                	cmp    %ebx,%edx
 666:	73 d1                	jae    639 <malloc+0x46>
    if(p == freep)
 668:	39 05 50 09 00 00    	cmp    %eax,0x950
 66e:	75 ed                	jne    65d <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 670:	89 d8                	mov    %ebx,%eax
 672:	e8 2c ff ff ff       	call   5a3 <morecore>
 677:	85 c0                	test   %eax,%eax
 679:	75 e2                	jne    65d <malloc+0x6a>
        return 0;
 67b:	b8 00 00 00 00       	mov    $0x0,%eax
 680:	eb cf                	jmp    651 <malloc+0x5e>
