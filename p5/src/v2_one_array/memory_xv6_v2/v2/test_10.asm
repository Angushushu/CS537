
_test_10:     file format elf32-i386


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
         // char *args[1];
         // args[0] = "ls";
          int* e1;
          int* e2;
         //int error=-11;
         int* frames = malloc(numframes * sizeof(int));
  14:	68 a0 0f 00 00       	push   $0xfa0
  19:	e8 a3 05 00 00       	call   5c1 <malloc>
  1e:	89 c6                	mov    %eax,%esi
         int* pids = malloc(numframes * sizeof(int));
  20:	c7 04 24 a0 0f 00 00 	movl   $0xfa0,(%esp)
  27:	e8 95 05 00 00       	call   5c1 <malloc>
  2c:	89 c7                	mov    %eax,%edi
         //cid = fork();
         //if(cid == 0)
         //{//Child Process
                 int cid=fork();
  2e:	e8 1b 02 00 00       	call   24e <fork>
                 if(cid==0){
  33:	83 c4 10             	add    $0x10,%esp
  36:	85 c0                	test   %eax,%eax
  38:	74 3f                	je     79 <main+0x79>
                 e1 = malloc(1000000 * sizeof(int));}
                 wait();
  3a:	e8 1f 02 00 00       	call   25e <wait>
 
                 cid=fork();
  3f:	e8 0a 02 00 00       	call   24e <fork>
                 if(cid==0){
  44:	85 c0                	test   %eax,%eax
  46:	74 43                	je     8b <main+0x8b>
                 e2 = malloc(1000000 * sizeof(int));}
 
                 if(e1==0 || e2==0) {}
                 wait();
  48:	e8 11 02 00 00       	call   25e <wait>
                 int flag = dump_physmem(frames, pids, numframes);
  4d:	83 ec 04             	sub    $0x4,%esp
  50:	68 e8 03 00 00       	push   $0x3e8
  55:	57                   	push   %edi
  56:	56                   	push   %esi
  57:	e8 9a 02 00 00       	call   2f6 <dump_physmem>
  5c:	89 c3                	mov    %eax,%ebx
                 if(flag == 0)
  5e:	83 c4 10             	add    $0x10,%esp
  61:	85 c0                	test   %eax,%eax
  63:	74 57                	je     bc <main+0xbc>
                                 //if(*(pids+i) > 0)
                                         printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
                 }
                 else// if(flag == -1)
                 {
                         printf(1,"error\n");
  65:	83 ec 08             	sub    $0x8,%esp
  68:	68 65 06 00 00       	push   $0x665
  6d:	6a 01                	push   $0x1
  6f:	e8 24 03 00 00       	call   398 <printf>
  74:	83 c4 10             	add    $0x10,%esp
  77:	eb 4b                	jmp    c4 <main+0xc4>
                 e1 = malloc(1000000 * sizeof(int));}
  79:	83 ec 0c             	sub    $0xc,%esp
  7c:	68 00 09 3d 00       	push   $0x3d0900
  81:	e8 3b 05 00 00       	call   5c1 <malloc>
  86:	83 c4 10             	add    $0x10,%esp
  89:	eb af                	jmp    3a <main+0x3a>
                 e2 = malloc(1000000 * sizeof(int));}
  8b:	83 ec 0c             	sub    $0xc,%esp
  8e:	68 00 09 3d 00       	push   $0x3d0900
  93:	e8 29 05 00 00       	call   5c1 <malloc>
  98:	83 c4 10             	add    $0x10,%esp
  9b:	eb ab                	jmp    48 <main+0x48>
                                         printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  9d:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  a4:	ff 34 07             	pushl  (%edi,%eax,1)
  a7:	ff 34 06             	pushl  (%esi,%eax,1)
  aa:	68 50 06 00 00       	push   $0x650
  af:	6a 01                	push   $0x1
  b1:	e8 e2 02 00 00       	call   398 <printf>
                         for (int i = 0; i < numframes; i++)
  b6:	83 c3 01             	add    $0x1,%ebx
  b9:	83 c4 10             	add    $0x10,%esp
  bc:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  c2:	7e d9                	jle    9d <main+0x9d>
                 }
 
         exit();
  c4:	e8 8d 01 00 00       	call   256 <exit>

000000c9 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  c9:	55                   	push   %ebp
  ca:	89 e5                	mov    %esp,%ebp
  cc:	53                   	push   %ebx
  cd:	8b 45 08             	mov    0x8(%ebp),%eax
  d0:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  d3:	89 c2                	mov    %eax,%edx
  d5:	0f b6 19             	movzbl (%ecx),%ebx
  d8:	88 1a                	mov    %bl,(%edx)
  da:	8d 52 01             	lea    0x1(%edx),%edx
  dd:	8d 49 01             	lea    0x1(%ecx),%ecx
  e0:	84 db                	test   %bl,%bl
  e2:	75 f1                	jne    d5 <strcpy+0xc>
    ;
  return os;
}
  e4:	5b                   	pop    %ebx
  e5:	5d                   	pop    %ebp
  e6:	c3                   	ret    

000000e7 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  e7:	55                   	push   %ebp
  e8:	89 e5                	mov    %esp,%ebp
  ea:	8b 4d 08             	mov    0x8(%ebp),%ecx
  ed:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  f0:	eb 06                	jmp    f8 <strcmp+0x11>
    p++, q++;
  f2:	83 c1 01             	add    $0x1,%ecx
  f5:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  f8:	0f b6 01             	movzbl (%ecx),%eax
  fb:	84 c0                	test   %al,%al
  fd:	74 04                	je     103 <strcmp+0x1c>
  ff:	3a 02                	cmp    (%edx),%al
 101:	74 ef                	je     f2 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 103:	0f b6 c0             	movzbl %al,%eax
 106:	0f b6 12             	movzbl (%edx),%edx
 109:	29 d0                	sub    %edx,%eax
}
 10b:	5d                   	pop    %ebp
 10c:	c3                   	ret    

0000010d <strlen>:

uint
strlen(const char *s)
{
 10d:	55                   	push   %ebp
 10e:	89 e5                	mov    %esp,%ebp
 110:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 113:	ba 00 00 00 00       	mov    $0x0,%edx
 118:	eb 03                	jmp    11d <strlen+0x10>
 11a:	83 c2 01             	add    $0x1,%edx
 11d:	89 d0                	mov    %edx,%eax
 11f:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 123:	75 f5                	jne    11a <strlen+0xd>
    ;
  return n;
}
 125:	5d                   	pop    %ebp
 126:	c3                   	ret    

00000127 <memset>:

void*
memset(void *dst, int c, uint n)
{
 127:	55                   	push   %ebp
 128:	89 e5                	mov    %esp,%ebp
 12a:	57                   	push   %edi
 12b:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 12e:	89 d7                	mov    %edx,%edi
 130:	8b 4d 10             	mov    0x10(%ebp),%ecx
 133:	8b 45 0c             	mov    0xc(%ebp),%eax
 136:	fc                   	cld    
 137:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 139:	89 d0                	mov    %edx,%eax
 13b:	5f                   	pop    %edi
 13c:	5d                   	pop    %ebp
 13d:	c3                   	ret    

0000013e <strchr>:

char*
strchr(const char *s, char c)
{
 13e:	55                   	push   %ebp
 13f:	89 e5                	mov    %esp,%ebp
 141:	8b 45 08             	mov    0x8(%ebp),%eax
 144:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 148:	0f b6 10             	movzbl (%eax),%edx
 14b:	84 d2                	test   %dl,%dl
 14d:	74 09                	je     158 <strchr+0x1a>
    if(*s == c)
 14f:	38 ca                	cmp    %cl,%dl
 151:	74 0a                	je     15d <strchr+0x1f>
  for(; *s; s++)
 153:	83 c0 01             	add    $0x1,%eax
 156:	eb f0                	jmp    148 <strchr+0xa>
      return (char*)s;
  return 0;
 158:	b8 00 00 00 00       	mov    $0x0,%eax
}
 15d:	5d                   	pop    %ebp
 15e:	c3                   	ret    

0000015f <gets>:

char*
gets(char *buf, int max)
{
 15f:	55                   	push   %ebp
 160:	89 e5                	mov    %esp,%ebp
 162:	57                   	push   %edi
 163:	56                   	push   %esi
 164:	53                   	push   %ebx
 165:	83 ec 1c             	sub    $0x1c,%esp
 168:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 16b:	bb 00 00 00 00       	mov    $0x0,%ebx
 170:	8d 73 01             	lea    0x1(%ebx),%esi
 173:	3b 75 0c             	cmp    0xc(%ebp),%esi
 176:	7d 2e                	jge    1a6 <gets+0x47>
    cc = read(0, &c, 1);
 178:	83 ec 04             	sub    $0x4,%esp
 17b:	6a 01                	push   $0x1
 17d:	8d 45 e7             	lea    -0x19(%ebp),%eax
 180:	50                   	push   %eax
 181:	6a 00                	push   $0x0
 183:	e8 e6 00 00 00       	call   26e <read>
    if(cc < 1)
 188:	83 c4 10             	add    $0x10,%esp
 18b:	85 c0                	test   %eax,%eax
 18d:	7e 17                	jle    1a6 <gets+0x47>
      break;
    buf[i++] = c;
 18f:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 193:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 196:	3c 0a                	cmp    $0xa,%al
 198:	0f 94 c2             	sete   %dl
 19b:	3c 0d                	cmp    $0xd,%al
 19d:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1a0:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1a2:	08 c2                	or     %al,%dl
 1a4:	74 ca                	je     170 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1a6:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1aa:	89 f8                	mov    %edi,%eax
 1ac:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1af:	5b                   	pop    %ebx
 1b0:	5e                   	pop    %esi
 1b1:	5f                   	pop    %edi
 1b2:	5d                   	pop    %ebp
 1b3:	c3                   	ret    

000001b4 <stat>:

int
stat(const char *n, struct stat *st)
{
 1b4:	55                   	push   %ebp
 1b5:	89 e5                	mov    %esp,%ebp
 1b7:	56                   	push   %esi
 1b8:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1b9:	83 ec 08             	sub    $0x8,%esp
 1bc:	6a 00                	push   $0x0
 1be:	ff 75 08             	pushl  0x8(%ebp)
 1c1:	e8 d0 00 00 00       	call   296 <open>
  if(fd < 0)
 1c6:	83 c4 10             	add    $0x10,%esp
 1c9:	85 c0                	test   %eax,%eax
 1cb:	78 24                	js     1f1 <stat+0x3d>
 1cd:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1cf:	83 ec 08             	sub    $0x8,%esp
 1d2:	ff 75 0c             	pushl  0xc(%ebp)
 1d5:	50                   	push   %eax
 1d6:	e8 d3 00 00 00       	call   2ae <fstat>
 1db:	89 c6                	mov    %eax,%esi
  close(fd);
 1dd:	89 1c 24             	mov    %ebx,(%esp)
 1e0:	e8 99 00 00 00       	call   27e <close>
  return r;
 1e5:	83 c4 10             	add    $0x10,%esp
}
 1e8:	89 f0                	mov    %esi,%eax
 1ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
 1ed:	5b                   	pop    %ebx
 1ee:	5e                   	pop    %esi
 1ef:	5d                   	pop    %ebp
 1f0:	c3                   	ret    
    return -1;
 1f1:	be ff ff ff ff       	mov    $0xffffffff,%esi
 1f6:	eb f0                	jmp    1e8 <stat+0x34>

000001f8 <atoi>:

int
atoi(const char *s)
{
 1f8:	55                   	push   %ebp
 1f9:	89 e5                	mov    %esp,%ebp
 1fb:	53                   	push   %ebx
 1fc:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 1ff:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 204:	eb 10                	jmp    216 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 206:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 209:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 20c:	83 c1 01             	add    $0x1,%ecx
 20f:	0f be d2             	movsbl %dl,%edx
 212:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 216:	0f b6 11             	movzbl (%ecx),%edx
 219:	8d 5a d0             	lea    -0x30(%edx),%ebx
 21c:	80 fb 09             	cmp    $0x9,%bl
 21f:	76 e5                	jbe    206 <atoi+0xe>
  return n;
}
 221:	5b                   	pop    %ebx
 222:	5d                   	pop    %ebp
 223:	c3                   	ret    

00000224 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 224:	55                   	push   %ebp
 225:	89 e5                	mov    %esp,%ebp
 227:	56                   	push   %esi
 228:	53                   	push   %ebx
 229:	8b 45 08             	mov    0x8(%ebp),%eax
 22c:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 22f:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 232:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 234:	eb 0d                	jmp    243 <memmove+0x1f>
    *dst++ = *src++;
 236:	0f b6 13             	movzbl (%ebx),%edx
 239:	88 11                	mov    %dl,(%ecx)
 23b:	8d 5b 01             	lea    0x1(%ebx),%ebx
 23e:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 241:	89 f2                	mov    %esi,%edx
 243:	8d 72 ff             	lea    -0x1(%edx),%esi
 246:	85 d2                	test   %edx,%edx
 248:	7f ec                	jg     236 <memmove+0x12>
  return vdst;
}
 24a:	5b                   	pop    %ebx
 24b:	5e                   	pop    %esi
 24c:	5d                   	pop    %ebp
 24d:	c3                   	ret    

0000024e <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 24e:	b8 01 00 00 00       	mov    $0x1,%eax
 253:	cd 40                	int    $0x40
 255:	c3                   	ret    

00000256 <exit>:
SYSCALL(exit)
 256:	b8 02 00 00 00       	mov    $0x2,%eax
 25b:	cd 40                	int    $0x40
 25d:	c3                   	ret    

0000025e <wait>:
SYSCALL(wait)
 25e:	b8 03 00 00 00       	mov    $0x3,%eax
 263:	cd 40                	int    $0x40
 265:	c3                   	ret    

00000266 <pipe>:
SYSCALL(pipe)
 266:	b8 04 00 00 00       	mov    $0x4,%eax
 26b:	cd 40                	int    $0x40
 26d:	c3                   	ret    

0000026e <read>:
SYSCALL(read)
 26e:	b8 05 00 00 00       	mov    $0x5,%eax
 273:	cd 40                	int    $0x40
 275:	c3                   	ret    

00000276 <write>:
SYSCALL(write)
 276:	b8 10 00 00 00       	mov    $0x10,%eax
 27b:	cd 40                	int    $0x40
 27d:	c3                   	ret    

0000027e <close>:
SYSCALL(close)
 27e:	b8 15 00 00 00       	mov    $0x15,%eax
 283:	cd 40                	int    $0x40
 285:	c3                   	ret    

00000286 <kill>:
SYSCALL(kill)
 286:	b8 06 00 00 00       	mov    $0x6,%eax
 28b:	cd 40                	int    $0x40
 28d:	c3                   	ret    

0000028e <exec>:
SYSCALL(exec)
 28e:	b8 07 00 00 00       	mov    $0x7,%eax
 293:	cd 40                	int    $0x40
 295:	c3                   	ret    

00000296 <open>:
SYSCALL(open)
 296:	b8 0f 00 00 00       	mov    $0xf,%eax
 29b:	cd 40                	int    $0x40
 29d:	c3                   	ret    

0000029e <mknod>:
SYSCALL(mknod)
 29e:	b8 11 00 00 00       	mov    $0x11,%eax
 2a3:	cd 40                	int    $0x40
 2a5:	c3                   	ret    

000002a6 <unlink>:
SYSCALL(unlink)
 2a6:	b8 12 00 00 00       	mov    $0x12,%eax
 2ab:	cd 40                	int    $0x40
 2ad:	c3                   	ret    

000002ae <fstat>:
SYSCALL(fstat)
 2ae:	b8 08 00 00 00       	mov    $0x8,%eax
 2b3:	cd 40                	int    $0x40
 2b5:	c3                   	ret    

000002b6 <link>:
SYSCALL(link)
 2b6:	b8 13 00 00 00       	mov    $0x13,%eax
 2bb:	cd 40                	int    $0x40
 2bd:	c3                   	ret    

000002be <mkdir>:
SYSCALL(mkdir)
 2be:	b8 14 00 00 00       	mov    $0x14,%eax
 2c3:	cd 40                	int    $0x40
 2c5:	c3                   	ret    

000002c6 <chdir>:
SYSCALL(chdir)
 2c6:	b8 09 00 00 00       	mov    $0x9,%eax
 2cb:	cd 40                	int    $0x40
 2cd:	c3                   	ret    

000002ce <dup>:
SYSCALL(dup)
 2ce:	b8 0a 00 00 00       	mov    $0xa,%eax
 2d3:	cd 40                	int    $0x40
 2d5:	c3                   	ret    

000002d6 <getpid>:
SYSCALL(getpid)
 2d6:	b8 0b 00 00 00       	mov    $0xb,%eax
 2db:	cd 40                	int    $0x40
 2dd:	c3                   	ret    

000002de <sbrk>:
SYSCALL(sbrk)
 2de:	b8 0c 00 00 00       	mov    $0xc,%eax
 2e3:	cd 40                	int    $0x40
 2e5:	c3                   	ret    

000002e6 <sleep>:
SYSCALL(sleep)
 2e6:	b8 0d 00 00 00       	mov    $0xd,%eax
 2eb:	cd 40                	int    $0x40
 2ed:	c3                   	ret    

000002ee <uptime>:
SYSCALL(uptime)
 2ee:	b8 0e 00 00 00       	mov    $0xe,%eax
 2f3:	cd 40                	int    $0x40
 2f5:	c3                   	ret    

000002f6 <dump_physmem>:
SYSCALL(dump_physmem)
 2f6:	b8 16 00 00 00       	mov    $0x16,%eax
 2fb:	cd 40                	int    $0x40
 2fd:	c3                   	ret    

000002fe <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 2fe:	55                   	push   %ebp
 2ff:	89 e5                	mov    %esp,%ebp
 301:	83 ec 1c             	sub    $0x1c,%esp
 304:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 307:	6a 01                	push   $0x1
 309:	8d 55 f4             	lea    -0xc(%ebp),%edx
 30c:	52                   	push   %edx
 30d:	50                   	push   %eax
 30e:	e8 63 ff ff ff       	call   276 <write>
}
 313:	83 c4 10             	add    $0x10,%esp
 316:	c9                   	leave  
 317:	c3                   	ret    

00000318 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 318:	55                   	push   %ebp
 319:	89 e5                	mov    %esp,%ebp
 31b:	57                   	push   %edi
 31c:	56                   	push   %esi
 31d:	53                   	push   %ebx
 31e:	83 ec 2c             	sub    $0x2c,%esp
 321:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 323:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 327:	0f 95 c3             	setne  %bl
 32a:	89 d0                	mov    %edx,%eax
 32c:	c1 e8 1f             	shr    $0x1f,%eax
 32f:	84 c3                	test   %al,%bl
 331:	74 10                	je     343 <printint+0x2b>
    neg = 1;
    x = -xx;
 333:	f7 da                	neg    %edx
    neg = 1;
 335:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 33c:	be 00 00 00 00       	mov    $0x0,%esi
 341:	eb 0b                	jmp    34e <printint+0x36>
  neg = 0;
 343:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 34a:	eb f0                	jmp    33c <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 34c:	89 c6                	mov    %eax,%esi
 34e:	89 d0                	mov    %edx,%eax
 350:	ba 00 00 00 00       	mov    $0x0,%edx
 355:	f7 f1                	div    %ecx
 357:	89 c3                	mov    %eax,%ebx
 359:	8d 46 01             	lea    0x1(%esi),%eax
 35c:	0f b6 92 74 06 00 00 	movzbl 0x674(%edx),%edx
 363:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 367:	89 da                	mov    %ebx,%edx
 369:	85 db                	test   %ebx,%ebx
 36b:	75 df                	jne    34c <printint+0x34>
 36d:	89 c3                	mov    %eax,%ebx
  if(neg)
 36f:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 373:	74 16                	je     38b <printint+0x73>
    buf[i++] = '-';
 375:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 37a:	8d 5e 02             	lea    0x2(%esi),%ebx
 37d:	eb 0c                	jmp    38b <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 37f:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 384:	89 f8                	mov    %edi,%eax
 386:	e8 73 ff ff ff       	call   2fe <putc>
  while(--i >= 0)
 38b:	83 eb 01             	sub    $0x1,%ebx
 38e:	79 ef                	jns    37f <printint+0x67>
}
 390:	83 c4 2c             	add    $0x2c,%esp
 393:	5b                   	pop    %ebx
 394:	5e                   	pop    %esi
 395:	5f                   	pop    %edi
 396:	5d                   	pop    %ebp
 397:	c3                   	ret    

00000398 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 398:	55                   	push   %ebp
 399:	89 e5                	mov    %esp,%ebp
 39b:	57                   	push   %edi
 39c:	56                   	push   %esi
 39d:	53                   	push   %ebx
 39e:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3a1:	8d 45 10             	lea    0x10(%ebp),%eax
 3a4:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3a7:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3ac:	bb 00 00 00 00       	mov    $0x0,%ebx
 3b1:	eb 14                	jmp    3c7 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3b3:	89 fa                	mov    %edi,%edx
 3b5:	8b 45 08             	mov    0x8(%ebp),%eax
 3b8:	e8 41 ff ff ff       	call   2fe <putc>
 3bd:	eb 05                	jmp    3c4 <printf+0x2c>
      }
    } else if(state == '%'){
 3bf:	83 fe 25             	cmp    $0x25,%esi
 3c2:	74 25                	je     3e9 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3c4:	83 c3 01             	add    $0x1,%ebx
 3c7:	8b 45 0c             	mov    0xc(%ebp),%eax
 3ca:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3ce:	84 c0                	test   %al,%al
 3d0:	0f 84 23 01 00 00    	je     4f9 <printf+0x161>
    c = fmt[i] & 0xff;
 3d6:	0f be f8             	movsbl %al,%edi
 3d9:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3dc:	85 f6                	test   %esi,%esi
 3de:	75 df                	jne    3bf <printf+0x27>
      if(c == '%'){
 3e0:	83 f8 25             	cmp    $0x25,%eax
 3e3:	75 ce                	jne    3b3 <printf+0x1b>
        state = '%';
 3e5:	89 c6                	mov    %eax,%esi
 3e7:	eb db                	jmp    3c4 <printf+0x2c>
      if(c == 'd'){
 3e9:	83 f8 64             	cmp    $0x64,%eax
 3ec:	74 49                	je     437 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 3ee:	83 f8 78             	cmp    $0x78,%eax
 3f1:	0f 94 c1             	sete   %cl
 3f4:	83 f8 70             	cmp    $0x70,%eax
 3f7:	0f 94 c2             	sete   %dl
 3fa:	08 d1                	or     %dl,%cl
 3fc:	75 63                	jne    461 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 3fe:	83 f8 73             	cmp    $0x73,%eax
 401:	0f 84 84 00 00 00    	je     48b <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 407:	83 f8 63             	cmp    $0x63,%eax
 40a:	0f 84 b7 00 00 00    	je     4c7 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 410:	83 f8 25             	cmp    $0x25,%eax
 413:	0f 84 cc 00 00 00    	je     4e5 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 419:	ba 25 00 00 00       	mov    $0x25,%edx
 41e:	8b 45 08             	mov    0x8(%ebp),%eax
 421:	e8 d8 fe ff ff       	call   2fe <putc>
        putc(fd, c);
 426:	89 fa                	mov    %edi,%edx
 428:	8b 45 08             	mov    0x8(%ebp),%eax
 42b:	e8 ce fe ff ff       	call   2fe <putc>
      }
      state = 0;
 430:	be 00 00 00 00       	mov    $0x0,%esi
 435:	eb 8d                	jmp    3c4 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 437:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 43a:	8b 17                	mov    (%edi),%edx
 43c:	83 ec 0c             	sub    $0xc,%esp
 43f:	6a 01                	push   $0x1
 441:	b9 0a 00 00 00       	mov    $0xa,%ecx
 446:	8b 45 08             	mov    0x8(%ebp),%eax
 449:	e8 ca fe ff ff       	call   318 <printint>
        ap++;
 44e:	83 c7 04             	add    $0x4,%edi
 451:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 454:	83 c4 10             	add    $0x10,%esp
      state = 0;
 457:	be 00 00 00 00       	mov    $0x0,%esi
 45c:	e9 63 ff ff ff       	jmp    3c4 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 461:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 464:	8b 17                	mov    (%edi),%edx
 466:	83 ec 0c             	sub    $0xc,%esp
 469:	6a 00                	push   $0x0
 46b:	b9 10 00 00 00       	mov    $0x10,%ecx
 470:	8b 45 08             	mov    0x8(%ebp),%eax
 473:	e8 a0 fe ff ff       	call   318 <printint>
        ap++;
 478:	83 c7 04             	add    $0x4,%edi
 47b:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 47e:	83 c4 10             	add    $0x10,%esp
      state = 0;
 481:	be 00 00 00 00       	mov    $0x0,%esi
 486:	e9 39 ff ff ff       	jmp    3c4 <printf+0x2c>
        s = (char*)*ap;
 48b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 48e:	8b 30                	mov    (%eax),%esi
        ap++;
 490:	83 c0 04             	add    $0x4,%eax
 493:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 496:	85 f6                	test   %esi,%esi
 498:	75 28                	jne    4c2 <printf+0x12a>
          s = "(null)";
 49a:	be 6c 06 00 00       	mov    $0x66c,%esi
 49f:	8b 7d 08             	mov    0x8(%ebp),%edi
 4a2:	eb 0d                	jmp    4b1 <printf+0x119>
          putc(fd, *s);
 4a4:	0f be d2             	movsbl %dl,%edx
 4a7:	89 f8                	mov    %edi,%eax
 4a9:	e8 50 fe ff ff       	call   2fe <putc>
          s++;
 4ae:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4b1:	0f b6 16             	movzbl (%esi),%edx
 4b4:	84 d2                	test   %dl,%dl
 4b6:	75 ec                	jne    4a4 <printf+0x10c>
      state = 0;
 4b8:	be 00 00 00 00       	mov    $0x0,%esi
 4bd:	e9 02 ff ff ff       	jmp    3c4 <printf+0x2c>
 4c2:	8b 7d 08             	mov    0x8(%ebp),%edi
 4c5:	eb ea                	jmp    4b1 <printf+0x119>
        putc(fd, *ap);
 4c7:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4ca:	0f be 17             	movsbl (%edi),%edx
 4cd:	8b 45 08             	mov    0x8(%ebp),%eax
 4d0:	e8 29 fe ff ff       	call   2fe <putc>
        ap++;
 4d5:	83 c7 04             	add    $0x4,%edi
 4d8:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4db:	be 00 00 00 00       	mov    $0x0,%esi
 4e0:	e9 df fe ff ff       	jmp    3c4 <printf+0x2c>
        putc(fd, c);
 4e5:	89 fa                	mov    %edi,%edx
 4e7:	8b 45 08             	mov    0x8(%ebp),%eax
 4ea:	e8 0f fe ff ff       	call   2fe <putc>
      state = 0;
 4ef:	be 00 00 00 00       	mov    $0x0,%esi
 4f4:	e9 cb fe ff ff       	jmp    3c4 <printf+0x2c>
    }
  }
}
 4f9:	8d 65 f4             	lea    -0xc(%ebp),%esp
 4fc:	5b                   	pop    %ebx
 4fd:	5e                   	pop    %esi
 4fe:	5f                   	pop    %edi
 4ff:	5d                   	pop    %ebp
 500:	c3                   	ret    

00000501 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 501:	55                   	push   %ebp
 502:	89 e5                	mov    %esp,%ebp
 504:	57                   	push   %edi
 505:	56                   	push   %esi
 506:	53                   	push   %ebx
 507:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 50a:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 50d:	a1 18 09 00 00       	mov    0x918,%eax
 512:	eb 02                	jmp    516 <free+0x15>
 514:	89 d0                	mov    %edx,%eax
 516:	39 c8                	cmp    %ecx,%eax
 518:	73 04                	jae    51e <free+0x1d>
 51a:	39 08                	cmp    %ecx,(%eax)
 51c:	77 12                	ja     530 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 51e:	8b 10                	mov    (%eax),%edx
 520:	39 c2                	cmp    %eax,%edx
 522:	77 f0                	ja     514 <free+0x13>
 524:	39 c8                	cmp    %ecx,%eax
 526:	72 08                	jb     530 <free+0x2f>
 528:	39 ca                	cmp    %ecx,%edx
 52a:	77 04                	ja     530 <free+0x2f>
 52c:	89 d0                	mov    %edx,%eax
 52e:	eb e6                	jmp    516 <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 530:	8b 73 fc             	mov    -0x4(%ebx),%esi
 533:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 536:	8b 10                	mov    (%eax),%edx
 538:	39 d7                	cmp    %edx,%edi
 53a:	74 19                	je     555 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 53c:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 53f:	8b 50 04             	mov    0x4(%eax),%edx
 542:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 545:	39 ce                	cmp    %ecx,%esi
 547:	74 1b                	je     564 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 549:	89 08                	mov    %ecx,(%eax)
  freep = p;
 54b:	a3 18 09 00 00       	mov    %eax,0x918
}
 550:	5b                   	pop    %ebx
 551:	5e                   	pop    %esi
 552:	5f                   	pop    %edi
 553:	5d                   	pop    %ebp
 554:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 555:	03 72 04             	add    0x4(%edx),%esi
 558:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 55b:	8b 10                	mov    (%eax),%edx
 55d:	8b 12                	mov    (%edx),%edx
 55f:	89 53 f8             	mov    %edx,-0x8(%ebx)
 562:	eb db                	jmp    53f <free+0x3e>
    p->s.size += bp->s.size;
 564:	03 53 fc             	add    -0x4(%ebx),%edx
 567:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 56a:	8b 53 f8             	mov    -0x8(%ebx),%edx
 56d:	89 10                	mov    %edx,(%eax)
 56f:	eb da                	jmp    54b <free+0x4a>

00000571 <morecore>:

static Header*
morecore(uint nu)
{
 571:	55                   	push   %ebp
 572:	89 e5                	mov    %esp,%ebp
 574:	53                   	push   %ebx
 575:	83 ec 04             	sub    $0x4,%esp
 578:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 57a:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 57f:	77 05                	ja     586 <morecore+0x15>
    nu = 4096;
 581:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 586:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 58d:	83 ec 0c             	sub    $0xc,%esp
 590:	50                   	push   %eax
 591:	e8 48 fd ff ff       	call   2de <sbrk>
  if(p == (char*)-1)
 596:	83 c4 10             	add    $0x10,%esp
 599:	83 f8 ff             	cmp    $0xffffffff,%eax
 59c:	74 1c                	je     5ba <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 59e:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5a1:	83 c0 08             	add    $0x8,%eax
 5a4:	83 ec 0c             	sub    $0xc,%esp
 5a7:	50                   	push   %eax
 5a8:	e8 54 ff ff ff       	call   501 <free>
  return freep;
 5ad:	a1 18 09 00 00       	mov    0x918,%eax
 5b2:	83 c4 10             	add    $0x10,%esp
}
 5b5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5b8:	c9                   	leave  
 5b9:	c3                   	ret    
    return 0;
 5ba:	b8 00 00 00 00       	mov    $0x0,%eax
 5bf:	eb f4                	jmp    5b5 <morecore+0x44>

000005c1 <malloc>:

void*
malloc(uint nbytes)
{
 5c1:	55                   	push   %ebp
 5c2:	89 e5                	mov    %esp,%ebp
 5c4:	53                   	push   %ebx
 5c5:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5c8:	8b 45 08             	mov    0x8(%ebp),%eax
 5cb:	8d 58 07             	lea    0x7(%eax),%ebx
 5ce:	c1 eb 03             	shr    $0x3,%ebx
 5d1:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5d4:	8b 0d 18 09 00 00    	mov    0x918,%ecx
 5da:	85 c9                	test   %ecx,%ecx
 5dc:	74 04                	je     5e2 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5de:	8b 01                	mov    (%ecx),%eax
 5e0:	eb 4d                	jmp    62f <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5e2:	c7 05 18 09 00 00 1c 	movl   $0x91c,0x918
 5e9:	09 00 00 
 5ec:	c7 05 1c 09 00 00 1c 	movl   $0x91c,0x91c
 5f3:	09 00 00 
    base.s.size = 0;
 5f6:	c7 05 20 09 00 00 00 	movl   $0x0,0x920
 5fd:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 600:	b9 1c 09 00 00       	mov    $0x91c,%ecx
 605:	eb d7                	jmp    5de <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 607:	39 da                	cmp    %ebx,%edx
 609:	74 1a                	je     625 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 60b:	29 da                	sub    %ebx,%edx
 60d:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 610:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 613:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 616:	89 0d 18 09 00 00    	mov    %ecx,0x918
      return (void*)(p + 1);
 61c:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 61f:	83 c4 04             	add    $0x4,%esp
 622:	5b                   	pop    %ebx
 623:	5d                   	pop    %ebp
 624:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 625:	8b 10                	mov    (%eax),%edx
 627:	89 11                	mov    %edx,(%ecx)
 629:	eb eb                	jmp    616 <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 62b:	89 c1                	mov    %eax,%ecx
 62d:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 62f:	8b 50 04             	mov    0x4(%eax),%edx
 632:	39 da                	cmp    %ebx,%edx
 634:	73 d1                	jae    607 <malloc+0x46>
    if(p == freep)
 636:	39 05 18 09 00 00    	cmp    %eax,0x918
 63c:	75 ed                	jne    62b <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 63e:	89 d8                	mov    %ebx,%eax
 640:	e8 2c ff ff ff       	call   571 <morecore>
 645:	85 c0                	test   %eax,%eax
 647:	75 e2                	jne    62b <malloc+0x6a>
        return 0;
 649:	b8 00 00 00 00       	mov    $0x0,%eax
 64e:	eb cf                	jmp    61f <malloc+0x5e>
