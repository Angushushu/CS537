
_test_7:     file format elf32-i386


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
  14:	c7 45 e4 54 06 00 00 	movl   $0x654,-0x1c(%ebp)
         int error=-11;
         int* frames = malloc(numframes * sizeof(int));
  1b:	68 a0 0f 00 00       	push   $0xfa0
  20:	e8 9e 05 00 00       	call   5c3 <malloc>
  25:	89 c6                	mov    %eax,%esi
         int* pids = malloc(numframes * sizeof(int));
  27:	c7 04 24 a0 0f 00 00 	movl   $0xfa0,(%esp)
  2e:	e8 90 05 00 00       	call   5c3 <malloc>
  33:	89 c7                	mov    %eax,%edi
         //cid = fork();
         //if(cid == 0)
         //{//Child Process
                 int cid=fork();
  35:	e8 16 02 00 00       	call   250 <fork>
                 if(cid==0)
  3a:	83 c4 10             	add    $0x10,%esp
  3d:	85 c0                	test   %eax,%eax
  3f:	74 32                	je     73 <main+0x73>
         int error=-11;
  41:	bb f5 ff ff ff       	mov    $0xfffffff5,%ebx
                 error = exec("ls", args);
                wait();
  46:	e8 15 02 00 00       	call   260 <wait>
                 int flag = dump_physmem(frames, pids, numframes);
  4b:	83 ec 04             	sub    $0x4,%esp
  4e:	68 e8 03 00 00       	push   $0x3e8
  53:	57                   	push   %edi
  54:	56                   	push   %esi
  55:	e8 9e 02 00 00       	call   2f8 <dump_physmem>
                 if(flag == 0 && error!=-10)
  5a:	83 c4 10             	add    $0x10,%esp
  5d:	85 c0                	test   %eax,%eax
  5f:	0f 94 c2             	sete   %dl
  62:	83 fb f6             	cmp    $0xfffffff6,%ebx
  65:	0f 95 c0             	setne  %al
  68:	84 c2                	test   %al,%dl
  6a:	74 4b                	je     b7 <main+0xb7>
                 {
                         for (int i = 0; i < numframes; i++)
  6c:	bb 00 00 00 00       	mov    $0x0,%ebx
  71:	eb 37                	jmp    aa <main+0xaa>
                 error = exec("ls", args);
  73:	83 ec 08             	sub    $0x8,%esp
  76:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  79:	50                   	push   %eax
  7a:	68 54 06 00 00       	push   $0x654
  7f:	e8 0c 02 00 00       	call   290 <exec>
  84:	89 c3                	mov    %eax,%ebx
  86:	83 c4 10             	add    $0x10,%esp
  89:	eb bb                	jmp    46 <main+0x46>
                                 //if(*(pids+i) > 0)
                                         printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  8b:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  92:	ff 34 07             	pushl  (%edi,%eax,1)
  95:	ff 34 06             	pushl  (%esi,%eax,1)
  98:	68 57 06 00 00       	push   $0x657
  9d:	6a 01                	push   $0x1
  9f:	e8 f6 02 00 00       	call   39a <printf>
                         for (int i = 0; i < numframes; i++)
  a4:	83 c3 01             	add    $0x1,%ebx
  a7:	83 c4 10             	add    $0x10,%esp
  aa:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  b0:	7e d9                	jle    8b <main+0x8b>
                 else// if(flag == -1)
                 {
                         printf(1,"error\n");
                 }
 
         exit();
  b2:	e8 a1 01 00 00       	call   258 <exit>
                         printf(1,"error\n");
  b7:	83 ec 08             	sub    $0x8,%esp
  ba:	68 6c 06 00 00       	push   $0x66c
  bf:	6a 01                	push   $0x1
  c1:	e8 d4 02 00 00       	call   39a <printf>
  c6:	83 c4 10             	add    $0x10,%esp
  c9:	eb e7                	jmp    b2 <main+0xb2>

000000cb <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  cb:	55                   	push   %ebp
  cc:	89 e5                	mov    %esp,%ebp
  ce:	53                   	push   %ebx
  cf:	8b 45 08             	mov    0x8(%ebp),%eax
  d2:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d5:	89 c2                	mov    %eax,%edx
  d7:	0f b6 19             	movzbl (%ecx),%ebx
  da:	88 1a                	mov    %bl,(%edx)
  dc:	8d 52 01             	lea    0x1(%edx),%edx
  df:	8d 49 01             	lea    0x1(%ecx),%ecx
  e2:	84 db                	test   %bl,%bl
  e4:	75 f1                	jne    d7 <strcpy+0xc>
    ;
  return os;
}
  e6:	5b                   	pop    %ebx
  e7:	5d                   	pop    %ebp
  e8:	c3                   	ret    

000000e9 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e9:	55                   	push   %ebp
  ea:	89 e5                	mov    %esp,%ebp
  ec:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ef:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  f2:	eb 06                	jmp    fa <strcmp+0x11>
    p++, q++;
  f4:	83 c1 01             	add    $0x1,%ecx
  f7:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  fa:	0f b6 01             	movzbl (%ecx),%eax
  fd:	84 c0                	test   %al,%al
  ff:	74 04                	je     105 <strcmp+0x1c>
 101:	3a 02                	cmp    (%edx),%al
 103:	74 ef                	je     f4 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 105:	0f b6 c0             	movzbl %al,%eax
 108:	0f b6 12             	movzbl (%edx),%edx
 10b:	29 d0                	sub    %edx,%eax
}
 10d:	5d                   	pop    %ebp
 10e:	c3                   	ret    

0000010f <strlen>:

uint
strlen(const char *s)
{
 10f:	55                   	push   %ebp
 110:	89 e5                	mov    %esp,%ebp
 112:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 115:	ba 00 00 00 00       	mov    $0x0,%edx
 11a:	eb 03                	jmp    11f <strlen+0x10>
 11c:	83 c2 01             	add    $0x1,%edx
 11f:	89 d0                	mov    %edx,%eax
 121:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 125:	75 f5                	jne    11c <strlen+0xd>
    ;
  return n;
}
 127:	5d                   	pop    %ebp
 128:	c3                   	ret    

00000129 <memset>:

void*
memset(void *dst, int c, uint n)
{
 129:	55                   	push   %ebp
 12a:	89 e5                	mov    %esp,%ebp
 12c:	57                   	push   %edi
 12d:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 130:	89 d7                	mov    %edx,%edi
 132:	8b 4d 10             	mov    0x10(%ebp),%ecx
 135:	8b 45 0c             	mov    0xc(%ebp),%eax
 138:	fc                   	cld    
 139:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 13b:	89 d0                	mov    %edx,%eax
 13d:	5f                   	pop    %edi
 13e:	5d                   	pop    %ebp
 13f:	c3                   	ret    

00000140 <strchr>:

char*
strchr(const char *s, char c)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	8b 45 08             	mov    0x8(%ebp),%eax
 146:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 14a:	0f b6 10             	movzbl (%eax),%edx
 14d:	84 d2                	test   %dl,%dl
 14f:	74 09                	je     15a <strchr+0x1a>
    if(*s == c)
 151:	38 ca                	cmp    %cl,%dl
 153:	74 0a                	je     15f <strchr+0x1f>
  for(; *s; s++)
 155:	83 c0 01             	add    $0x1,%eax
 158:	eb f0                	jmp    14a <strchr+0xa>
      return (char*)s;
  return 0;
 15a:	b8 00 00 00 00       	mov    $0x0,%eax
}
 15f:	5d                   	pop    %ebp
 160:	c3                   	ret    

00000161 <gets>:

char*
gets(char *buf, int max)
{
 161:	55                   	push   %ebp
 162:	89 e5                	mov    %esp,%ebp
 164:	57                   	push   %edi
 165:	56                   	push   %esi
 166:	53                   	push   %ebx
 167:	83 ec 1c             	sub    $0x1c,%esp
 16a:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16d:	bb 00 00 00 00       	mov    $0x0,%ebx
 172:	8d 73 01             	lea    0x1(%ebx),%esi
 175:	3b 75 0c             	cmp    0xc(%ebp),%esi
 178:	7d 2e                	jge    1a8 <gets+0x47>
    cc = read(0, &c, 1);
 17a:	83 ec 04             	sub    $0x4,%esp
 17d:	6a 01                	push   $0x1
 17f:	8d 45 e7             	lea    -0x19(%ebp),%eax
 182:	50                   	push   %eax
 183:	6a 00                	push   $0x0
 185:	e8 e6 00 00 00       	call   270 <read>
    if(cc < 1)
 18a:	83 c4 10             	add    $0x10,%esp
 18d:	85 c0                	test   %eax,%eax
 18f:	7e 17                	jle    1a8 <gets+0x47>
      break;
    buf[i++] = c;
 191:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 195:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 198:	3c 0a                	cmp    $0xa,%al
 19a:	0f 94 c2             	sete   %dl
 19d:	3c 0d                	cmp    $0xd,%al
 19f:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1a2:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1a4:	08 c2                	or     %al,%dl
 1a6:	74 ca                	je     172 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1a8:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1ac:	89 f8                	mov    %edi,%eax
 1ae:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1b1:	5b                   	pop    %ebx
 1b2:	5e                   	pop    %esi
 1b3:	5f                   	pop    %edi
 1b4:	5d                   	pop    %ebp
 1b5:	c3                   	ret    

000001b6 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b6:	55                   	push   %ebp
 1b7:	89 e5                	mov    %esp,%ebp
 1b9:	56                   	push   %esi
 1ba:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1bb:	83 ec 08             	sub    $0x8,%esp
 1be:	6a 00                	push   $0x0
 1c0:	ff 75 08             	pushl  0x8(%ebp)
 1c3:	e8 d0 00 00 00       	call   298 <open>
  if(fd < 0)
 1c8:	83 c4 10             	add    $0x10,%esp
 1cb:	85 c0                	test   %eax,%eax
 1cd:	78 24                	js     1f3 <stat+0x3d>
 1cf:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1d1:	83 ec 08             	sub    $0x8,%esp
 1d4:	ff 75 0c             	pushl  0xc(%ebp)
 1d7:	50                   	push   %eax
 1d8:	e8 d3 00 00 00       	call   2b0 <fstat>
 1dd:	89 c6                	mov    %eax,%esi
  close(fd);
 1df:	89 1c 24             	mov    %ebx,(%esp)
 1e2:	e8 99 00 00 00       	call   280 <close>
  return r;
 1e7:	83 c4 10             	add    $0x10,%esp
}
 1ea:	89 f0                	mov    %esi,%eax
 1ec:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1ef:	5b                   	pop    %ebx
 1f0:	5e                   	pop    %esi
 1f1:	5d                   	pop    %ebp
 1f2:	c3                   	ret    
    return -1;
 1f3:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1f8:	eb f0                	jmp    1ea <stat+0x34>

000001fa <atoi>:

int
atoi(const char *s)
{
 1fa:	55                   	push   %ebp
 1fb:	89 e5                	mov    %esp,%ebp
 1fd:	53                   	push   %ebx
 1fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 201:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 206:	eb 10                	jmp    218 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 208:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 20b:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 20e:	83 c1 01             	add    $0x1,%ecx
 211:	0f be d2             	movsbl %dl,%edx
 214:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 218:	0f b6 11             	movzbl (%ecx),%edx
 21b:	8d 5a d0             	lea    -0x30(%edx),%ebx
 21e:	80 fb 09             	cmp    $0x9,%bl
 221:	76 e5                	jbe    208 <atoi+0xe>
  return n;
}
 223:	5b                   	pop    %ebx
 224:	5d                   	pop    %ebp
 225:	c3                   	ret    

00000226 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 226:	55                   	push   %ebp
 227:	89 e5                	mov    %esp,%ebp
 229:	56                   	push   %esi
 22a:	53                   	push   %ebx
 22b:	8b 45 08             	mov    0x8(%ebp),%eax
 22e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 231:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 234:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 236:	eb 0d                	jmp    245 <memmove+0x1f>
    *dst++ = *src++;
 238:	0f b6 13             	movzbl (%ebx),%edx
 23b:	88 11                	mov    %dl,(%ecx)
 23d:	8d 5b 01             	lea    0x1(%ebx),%ebx
 240:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 243:	89 f2                	mov    %esi,%edx
 245:	8d 72 ff             	lea    -0x1(%edx),%esi
 248:	85 d2                	test   %edx,%edx
 24a:	7f ec                	jg     238 <memmove+0x12>
  return vdst;
}
 24c:	5b                   	pop    %ebx
 24d:	5e                   	pop    %esi
 24e:	5d                   	pop    %ebp
 24f:	c3                   	ret    

00000250 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 250:	b8 01 00 00 00       	mov    $0x1,%eax
 255:	cd 40                	int    $0x40
 257:	c3                   	ret    

00000258 <exit>:
SYSCALL(exit)
 258:	b8 02 00 00 00       	mov    $0x2,%eax
 25d:	cd 40                	int    $0x40
 25f:	c3                   	ret    

00000260 <wait>:
SYSCALL(wait)
 260:	b8 03 00 00 00       	mov    $0x3,%eax
 265:	cd 40                	int    $0x40
 267:	c3                   	ret    

00000268 <pipe>:
SYSCALL(pipe)
 268:	b8 04 00 00 00       	mov    $0x4,%eax
 26d:	cd 40                	int    $0x40
 26f:	c3                   	ret    

00000270 <read>:
SYSCALL(read)
 270:	b8 05 00 00 00       	mov    $0x5,%eax
 275:	cd 40                	int    $0x40
 277:	c3                   	ret    

00000278 <write>:
SYSCALL(write)
 278:	b8 10 00 00 00       	mov    $0x10,%eax
 27d:	cd 40                	int    $0x40
 27f:	c3                   	ret    

00000280 <close>:
SYSCALL(close)
 280:	b8 15 00 00 00       	mov    $0x15,%eax
 285:	cd 40                	int    $0x40
 287:	c3                   	ret    

00000288 <kill>:
SYSCALL(kill)
 288:	b8 06 00 00 00       	mov    $0x6,%eax
 28d:	cd 40                	int    $0x40
 28f:	c3                   	ret    

00000290 <exec>:
SYSCALL(exec)
 290:	b8 07 00 00 00       	mov    $0x7,%eax
 295:	cd 40                	int    $0x40
 297:	c3                   	ret    

00000298 <open>:
SYSCALL(open)
 298:	b8 0f 00 00 00       	mov    $0xf,%eax
 29d:	cd 40                	int    $0x40
 29f:	c3                   	ret    

000002a0 <mknod>:
SYSCALL(mknod)
 2a0:	b8 11 00 00 00       	mov    $0x11,%eax
 2a5:	cd 40                	int    $0x40
 2a7:	c3                   	ret    

000002a8 <unlink>:
SYSCALL(unlink)
 2a8:	b8 12 00 00 00       	mov    $0x12,%eax
 2ad:	cd 40                	int    $0x40
 2af:	c3                   	ret    

000002b0 <fstat>:
SYSCALL(fstat)
 2b0:	b8 08 00 00 00       	mov    $0x8,%eax
 2b5:	cd 40                	int    $0x40
 2b7:	c3                   	ret    

000002b8 <link>:
SYSCALL(link)
 2b8:	b8 13 00 00 00       	mov    $0x13,%eax
 2bd:	cd 40                	int    $0x40
 2bf:	c3                   	ret    

000002c0 <mkdir>:
SYSCALL(mkdir)
 2c0:	b8 14 00 00 00       	mov    $0x14,%eax
 2c5:	cd 40                	int    $0x40
 2c7:	c3                   	ret    

000002c8 <chdir>:
SYSCALL(chdir)
 2c8:	b8 09 00 00 00       	mov    $0x9,%eax
 2cd:	cd 40                	int    $0x40
 2cf:	c3                   	ret    

000002d0 <dup>:
SYSCALL(dup)
 2d0:	b8 0a 00 00 00       	mov    $0xa,%eax
 2d5:	cd 40                	int    $0x40
 2d7:	c3                   	ret    

000002d8 <getpid>:
SYSCALL(getpid)
 2d8:	b8 0b 00 00 00       	mov    $0xb,%eax
 2dd:	cd 40                	int    $0x40
 2df:	c3                   	ret    

000002e0 <sbrk>:
SYSCALL(sbrk)
 2e0:	b8 0c 00 00 00       	mov    $0xc,%eax
 2e5:	cd 40                	int    $0x40
 2e7:	c3                   	ret    

000002e8 <sleep>:
SYSCALL(sleep)
 2e8:	b8 0d 00 00 00       	mov    $0xd,%eax
 2ed:	cd 40                	int    $0x40
 2ef:	c3                   	ret    

000002f0 <uptime>:
SYSCALL(uptime)
 2f0:	b8 0e 00 00 00       	mov    $0xe,%eax
 2f5:	cd 40                	int    $0x40
 2f7:	c3                   	ret    

000002f8 <dump_physmem>:
SYSCALL(dump_physmem)
 2f8:	b8 16 00 00 00       	mov    $0x16,%eax
 2fd:	cd 40                	int    $0x40
 2ff:	c3                   	ret    

00000300 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 300:	55                   	push   %ebp
 301:	89 e5                	mov    %esp,%ebp
 303:	83 ec 1c             	sub    $0x1c,%esp
 306:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 309:	6a 01                	push   $0x1
 30b:	8d 55 f4             	lea    -0xc(%ebp),%edx
 30e:	52                   	push   %edx
 30f:	50                   	push   %eax
 310:	e8 63 ff ff ff       	call   278 <write>
}
 315:	83 c4 10             	add    $0x10,%esp
 318:	c9                   	leave  
 319:	c3                   	ret    

0000031a <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 31a:	55                   	push   %ebp
 31b:	89 e5                	mov    %esp,%ebp
 31d:	57                   	push   %edi
 31e:	56                   	push   %esi
 31f:	53                   	push   %ebx
 320:	83 ec 2c             	sub    $0x2c,%esp
 323:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 325:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 329:	0f 95 c3             	setne  %bl
 32c:	89 d0                	mov    %edx,%eax
 32e:	c1 e8 1f             	shr    $0x1f,%eax
 331:	84 c3                	test   %al,%bl
 333:	74 10                	je     345 <printint+0x2b>
    neg = 1;
    x = -xx;
 335:	f7 da                	neg    %edx
    neg = 1;
 337:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 33e:	be 00 00 00 00       	mov    $0x0,%esi
 343:	eb 0b                	jmp    350 <printint+0x36>
  neg = 0;
 345:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 34c:	eb f0                	jmp    33e <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 34e:	89 c6                	mov    %eax,%esi
 350:	89 d0                	mov    %edx,%eax
 352:	ba 00 00 00 00       	mov    $0x0,%edx
 357:	f7 f1                	div    %ecx
 359:	89 c3                	mov    %eax,%ebx
 35b:	8d 46 01             	lea    0x1(%esi),%eax
 35e:	0f b6 92 7c 06 00 00 	movzbl 0x67c(%edx),%edx
 365:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 369:	89 da                	mov    %ebx,%edx
 36b:	85 db                	test   %ebx,%ebx
 36d:	75 df                	jne    34e <printint+0x34>
 36f:	89 c3                	mov    %eax,%ebx
  if(neg)
 371:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 375:	74 16                	je     38d <printint+0x73>
    buf[i++] = '-';
 377:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 37c:	8d 5e 02             	lea    0x2(%esi),%ebx
 37f:	eb 0c                	jmp    38d <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 381:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 386:	89 f8                	mov    %edi,%eax
 388:	e8 73 ff ff ff       	call   300 <putc>
  while(--i >= 0)
 38d:	83 eb 01             	sub    $0x1,%ebx
 390:	79 ef                	jns    381 <printint+0x67>
}
 392:	83 c4 2c             	add    $0x2c,%esp
 395:	5b                   	pop    %ebx
 396:	5e                   	pop    %esi
 397:	5f                   	pop    %edi
 398:	5d                   	pop    %ebp
 399:	c3                   	ret    

0000039a <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 39a:	55                   	push   %ebp
 39b:	89 e5                	mov    %esp,%ebp
 39d:	57                   	push   %edi
 39e:	56                   	push   %esi
 39f:	53                   	push   %ebx
 3a0:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3a3:	8d 45 10             	lea    0x10(%ebp),%eax
 3a6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3a9:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3ae:	bb 00 00 00 00       	mov    $0x0,%ebx
 3b3:	eb 14                	jmp    3c9 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3b5:	89 fa                	mov    %edi,%edx
 3b7:	8b 45 08             	mov    0x8(%ebp),%eax
 3ba:	e8 41 ff ff ff       	call   300 <putc>
 3bf:	eb 05                	jmp    3c6 <printf+0x2c>
      }
    } else if(state == '%'){
 3c1:	83 fe 25             	cmp    $0x25,%esi
 3c4:	74 25                	je     3eb <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3c6:	83 c3 01             	add    $0x1,%ebx
 3c9:	8b 45 0c             	mov    0xc(%ebp),%eax
 3cc:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3d0:	84 c0                	test   %al,%al
 3d2:	0f 84 23 01 00 00    	je     4fb <printf+0x161>
    c = fmt[i] & 0xff;
 3d8:	0f be f8             	movsbl %al,%edi
 3db:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3de:	85 f6                	test   %esi,%esi
 3e0:	75 df                	jne    3c1 <printf+0x27>
      if(c == '%'){
 3e2:	83 f8 25             	cmp    $0x25,%eax
 3e5:	75 ce                	jne    3b5 <printf+0x1b>
        state = '%';
 3e7:	89 c6                	mov    %eax,%esi
 3e9:	eb db                	jmp    3c6 <printf+0x2c>
      if(c == 'd'){
 3eb:	83 f8 64             	cmp    $0x64,%eax
 3ee:	74 49                	je     439 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3f0:	83 f8 78             	cmp    $0x78,%eax
 3f3:	0f 94 c1             	sete   %cl
 3f6:	83 f8 70             	cmp    $0x70,%eax
 3f9:	0f 94 c2             	sete   %dl
 3fc:	08 d1                	or     %dl,%cl
 3fe:	75 63                	jne    463 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 400:	83 f8 73             	cmp    $0x73,%eax
 403:	0f 84 84 00 00 00    	je     48d <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 409:	83 f8 63             	cmp    $0x63,%eax
 40c:	0f 84 b7 00 00 00    	je     4c9 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 412:	83 f8 25             	cmp    $0x25,%eax
 415:	0f 84 cc 00 00 00    	je     4e7 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 41b:	ba 25 00 00 00       	mov    $0x25,%edx
 420:	8b 45 08             	mov    0x8(%ebp),%eax
 423:	e8 d8 fe ff ff       	call   300 <putc>
        putc(fd, c);
 428:	89 fa                	mov    %edi,%edx
 42a:	8b 45 08             	mov    0x8(%ebp),%eax
 42d:	e8 ce fe ff ff       	call   300 <putc>
      }
      state = 0;
 432:	be 00 00 00 00       	mov    $0x0,%esi
 437:	eb 8d                	jmp    3c6 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 439:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 43c:	8b 17                	mov    (%edi),%edx
 43e:	83 ec 0c             	sub    $0xc,%esp
 441:	6a 01                	push   $0x1
 443:	b9 0a 00 00 00       	mov    $0xa,%ecx
 448:	8b 45 08             	mov    0x8(%ebp),%eax
 44b:	e8 ca fe ff ff       	call   31a <printint>
        ap++;
 450:	83 c7 04             	add    $0x4,%edi
 453:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 456:	83 c4 10             	add    $0x10,%esp
      state = 0;
 459:	be 00 00 00 00       	mov    $0x0,%esi
 45e:	e9 63 ff ff ff       	jmp    3c6 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 463:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 466:	8b 17                	mov    (%edi),%edx
 468:	83 ec 0c             	sub    $0xc,%esp
 46b:	6a 00                	push   $0x0
 46d:	b9 10 00 00 00       	mov    $0x10,%ecx
 472:	8b 45 08             	mov    0x8(%ebp),%eax
 475:	e8 a0 fe ff ff       	call   31a <printint>
        ap++;
 47a:	83 c7 04             	add    $0x4,%edi
 47d:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 480:	83 c4 10             	add    $0x10,%esp
      state = 0;
 483:	be 00 00 00 00       	mov    $0x0,%esi
 488:	e9 39 ff ff ff       	jmp    3c6 <printf+0x2c>
        s = (char*)*ap;
 48d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 490:	8b 30                	mov    (%eax),%esi
        ap++;
 492:	83 c0 04             	add    $0x4,%eax
 495:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 498:	85 f6                	test   %esi,%esi
 49a:	75 28                	jne    4c4 <printf+0x12a>
          s = "(null)";
 49c:	be 73 06 00 00       	mov    $0x673,%esi
 4a1:	8b 7d 08             	mov    0x8(%ebp),%edi
 4a4:	eb 0d                	jmp    4b3 <printf+0x119>
          putc(fd, *s);
 4a6:	0f be d2             	movsbl %dl,%edx
 4a9:	89 f8                	mov    %edi,%eax
 4ab:	e8 50 fe ff ff       	call   300 <putc>
          s++;
 4b0:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4b3:	0f b6 16             	movzbl (%esi),%edx
 4b6:	84 d2                	test   %dl,%dl
 4b8:	75 ec                	jne    4a6 <printf+0x10c>
      state = 0;
 4ba:	be 00 00 00 00       	mov    $0x0,%esi
 4bf:	e9 02 ff ff ff       	jmp    3c6 <printf+0x2c>
 4c4:	8b 7d 08             	mov    0x8(%ebp),%edi
 4c7:	eb ea                	jmp    4b3 <printf+0x119>
        putc(fd, *ap);
 4c9:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4cc:	0f be 17             	movsbl (%edi),%edx
 4cf:	8b 45 08             	mov    0x8(%ebp),%eax
 4d2:	e8 29 fe ff ff       	call   300 <putc>
        ap++;
 4d7:	83 c7 04             	add    $0x4,%edi
 4da:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4dd:	be 00 00 00 00       	mov    $0x0,%esi
 4e2:	e9 df fe ff ff       	jmp    3c6 <printf+0x2c>
        putc(fd, c);
 4e7:	89 fa                	mov    %edi,%edx
 4e9:	8b 45 08             	mov    0x8(%ebp),%eax
 4ec:	e8 0f fe ff ff       	call   300 <putc>
      state = 0;
 4f1:	be 00 00 00 00       	mov    $0x0,%esi
 4f6:	e9 cb fe ff ff       	jmp    3c6 <printf+0x2c>
    }
  }
}
 4fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4fe:	5b                   	pop    %ebx
 4ff:	5e                   	pop    %esi
 500:	5f                   	pop    %edi
 501:	5d                   	pop    %ebp
 502:	c3                   	ret    

00000503 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 503:	55                   	push   %ebp
 504:	89 e5                	mov    %esp,%ebp
 506:	57                   	push   %edi
 507:	56                   	push   %esi
 508:	53                   	push   %ebx
 509:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 50c:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 50f:	a1 20 09 00 00       	mov    0x920,%eax
 514:	eb 02                	jmp    518 <free+0x15>
 516:	89 d0                	mov    %edx,%eax
 518:	39 c8                	cmp    %ecx,%eax
 51a:	73 04                	jae    520 <free+0x1d>
 51c:	39 08                	cmp    %ecx,(%eax)
 51e:	77 12                	ja     532 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 520:	8b 10                	mov    (%eax),%edx
 522:	39 c2                	cmp    %eax,%edx
 524:	77 f0                	ja     516 <free+0x13>
 526:	39 c8                	cmp    %ecx,%eax
 528:	72 08                	jb     532 <free+0x2f>
 52a:	39 ca                	cmp    %ecx,%edx
 52c:	77 04                	ja     532 <free+0x2f>
 52e:	89 d0                	mov    %edx,%eax
 530:	eb e6                	jmp    518 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 532:	8b 73 fc             	mov    -0x4(%ebx),%esi
 535:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 538:	8b 10                	mov    (%eax),%edx
 53a:	39 d7                	cmp    %edx,%edi
 53c:	74 19                	je     557 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 53e:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 541:	8b 50 04             	mov    0x4(%eax),%edx
 544:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 547:	39 ce                	cmp    %ecx,%esi
 549:	74 1b                	je     566 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 54b:	89 08                	mov    %ecx,(%eax)
  freep = p;
 54d:	a3 20 09 00 00       	mov    %eax,0x920
}
 552:	5b                   	pop    %ebx
 553:	5e                   	pop    %esi
 554:	5f                   	pop    %edi
 555:	5d                   	pop    %ebp
 556:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 557:	03 72 04             	add    0x4(%edx),%esi
 55a:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 55d:	8b 10                	mov    (%eax),%edx
 55f:	8b 12                	mov    (%edx),%edx
 561:	89 53 f8             	mov    %edx,-0x8(%ebx)
 564:	eb db                	jmp    541 <free+0x3e>
    p->s.size += bp->s.size;
 566:	03 53 fc             	add    -0x4(%ebx),%edx
 569:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 56c:	8b 53 f8             	mov    -0x8(%ebx),%edx
 56f:	89 10                	mov    %edx,(%eax)
 571:	eb da                	jmp    54d <free+0x4a>

00000573 <morecore>:

static Header*
morecore(uint nu)
{
 573:	55                   	push   %ebp
 574:	89 e5                	mov    %esp,%ebp
 576:	53                   	push   %ebx
 577:	83 ec 04             	sub    $0x4,%esp
 57a:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 57c:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 581:	77 05                	ja     588 <morecore+0x15>
    nu = 4096;
 583:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 588:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 58f:	83 ec 0c             	sub    $0xc,%esp
 592:	50                   	push   %eax
 593:	e8 48 fd ff ff       	call   2e0 <sbrk>
  if(p == (char*)-1)
 598:	83 c4 10             	add    $0x10,%esp
 59b:	83 f8 ff             	cmp    $0xffffffff,%eax
 59e:	74 1c                	je     5bc <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5a0:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5a3:	83 c0 08             	add    $0x8,%eax
 5a6:	83 ec 0c             	sub    $0xc,%esp
 5a9:	50                   	push   %eax
 5aa:	e8 54 ff ff ff       	call   503 <free>
  return freep;
 5af:	a1 20 09 00 00       	mov    0x920,%eax
 5b4:	83 c4 10             	add    $0x10,%esp
}
 5b7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5ba:	c9                   	leave  
 5bb:	c3                   	ret    
    return 0;
 5bc:	b8 00 00 00 00       	mov    $0x0,%eax
 5c1:	eb f4                	jmp    5b7 <morecore+0x44>

000005c3 <malloc>:

void*
malloc(uint nbytes)
{
 5c3:	55                   	push   %ebp
 5c4:	89 e5                	mov    %esp,%ebp
 5c6:	53                   	push   %ebx
 5c7:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5ca:	8b 45 08             	mov    0x8(%ebp),%eax
 5cd:	8d 58 07             	lea    0x7(%eax),%ebx
 5d0:	c1 eb 03             	shr    $0x3,%ebx
 5d3:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5d6:	8b 0d 20 09 00 00    	mov    0x920,%ecx
 5dc:	85 c9                	test   %ecx,%ecx
 5de:	74 04                	je     5e4 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5e0:	8b 01                	mov    (%ecx),%eax
 5e2:	eb 4d                	jmp    631 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5e4:	c7 05 20 09 00 00 24 	movl   $0x924,0x920
 5eb:	09 00 00 
 5ee:	c7 05 24 09 00 00 24 	movl   $0x924,0x924
 5f5:	09 00 00 
    base.s.size = 0;
 5f8:	c7 05 28 09 00 00 00 	movl   $0x0,0x928
 5ff:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 602:	b9 24 09 00 00       	mov    $0x924,%ecx
 607:	eb d7                	jmp    5e0 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 609:	39 da                	cmp    %ebx,%edx
 60b:	74 1a                	je     627 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 60d:	29 da                	sub    %ebx,%edx
 60f:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 612:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 615:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 618:	89 0d 20 09 00 00    	mov    %ecx,0x920
      return (void*)(p + 1);
 61e:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 621:	83 c4 04             	add    $0x4,%esp
 624:	5b                   	pop    %ebx
 625:	5d                   	pop    %ebp
 626:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 627:	8b 10                	mov    (%eax),%edx
 629:	89 11                	mov    %edx,(%ecx)
 62b:	eb eb                	jmp    618 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 62d:	89 c1                	mov    %eax,%ecx
 62f:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 631:	8b 50 04             	mov    0x4(%eax),%edx
 634:	39 da                	cmp    %ebx,%edx
 636:	73 d1                	jae    609 <malloc+0x46>
    if(p == freep)
 638:	39 05 20 09 00 00    	cmp    %eax,0x920
 63e:	75 ed                	jne    62d <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 640:	89 d8                	mov    %ebx,%eax
 642:	e8 2c ff ff ff       	call   573 <morecore>
 647:	85 c0                	test   %eax,%eax
 649:	75 e2                	jne    62d <malloc+0x6a>
        return 0;
 64b:	b8 00 00 00 00       	mov    $0x0,%eax
 650:	eb cf                	jmp    621 <malloc+0x5e>
