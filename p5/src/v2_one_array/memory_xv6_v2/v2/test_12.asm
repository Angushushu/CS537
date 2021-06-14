
_test_12:     file format elf32-i386


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
         //  char *args[1];
         // args[0] = "ls";
         int error=-11;
         int *e1 = 0;
  14:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
         int *e2 = 0;
         //int *e3;
         //int *e4;
         int* frames = malloc(numframes * sizeof(int));
  1b:	68 a0 0f 00 00       	push   $0xfa0
  20:	e8 b5 05 00 00       	call   5da <malloc>
  25:	89 c6                	mov    %eax,%esi
         int* pids = malloc(numframes * sizeof(int));
  27:	c7 04 24 a0 0f 00 00 	movl   $0xfa0,(%esp)
  2e:	e8 a7 05 00 00       	call   5da <malloc>
  33:	89 c7                	mov    %eax,%edi
         //cid = fork();
         //if(cid == 0)
         //{//Child Process
         if(e1==0 || e2==0) {}
         int cid=fork();
  35:	e8 2d 02 00 00       	call   267 <fork>
         if(cid==0)
  3a:	83 c4 10             	add    $0x10,%esp
  3d:	85 c0                	test   %eax,%eax
  3f:	74 4e                	je     8f <main+0x8f>
               e1 = malloc(1000000 * sizeof(int));
         wait();
  41:	e8 31 02 00 00       	call   277 <wait>
         free(&e1);
  46:	83 ec 0c             	sub    $0xc,%esp
  49:	8d 45 e4             	lea    -0x1c(%ebp),%eax
  4c:	50                   	push   %eax
  4d:	e8 c8 04 00 00       	call   51a <free>
         cid=fork();
  52:	e8 10 02 00 00       	call   267 <fork>
         if(cid==0)
  57:	83 c4 10             	add    $0x10,%esp
  5a:	85 c0                	test   %eax,%eax
  5c:	74 46                	je     a4 <main+0xa4>
               e2 = malloc(1000000 * sizeof(int));
 
         //sleep(10);
         wait();
  5e:	e8 14 02 00 00       	call   277 <wait>
 
         //sleep(10);
         wait();
         free(&e1);
 */
         int flag = dump_physmem(frames, pids, numframes);
  63:	83 ec 04             	sub    $0x4,%esp
  66:	68 e8 03 00 00       	push   $0x3e8
  6b:	57                   	push   %edi
  6c:	56                   	push   %esi
  6d:	e8 9d 02 00 00       	call   30f <dump_physmem>
  72:	89 c3                	mov    %eax,%ebx
         if(flag == 0 && error!=-10)
  74:	83 c4 10             	add    $0x10,%esp
  77:	85 c0                	test   %eax,%eax
  79:	74 5a                	je     d5 <main+0xd5>
                         //if(*(pids+i) > 0)
                         printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
         }
         else// if(flag == -1)
         {
                 printf(1,"error\n");
  7b:	83 ec 08             	sub    $0x8,%esp
  7e:	68 81 06 00 00       	push   $0x681
  83:	6a 01                	push   $0x1
  85:	e8 27 03 00 00       	call   3b1 <printf>
  8a:	83 c4 10             	add    $0x10,%esp
  8d:	eb 4e                	jmp    dd <main+0xdd>
               e1 = malloc(1000000 * sizeof(int));
  8f:	83 ec 0c             	sub    $0xc,%esp
  92:	68 00 09 3d 00       	push   $0x3d0900
  97:	e8 3e 05 00 00       	call   5da <malloc>
  9c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  9f:	83 c4 10             	add    $0x10,%esp
  a2:	eb 9d                	jmp    41 <main+0x41>
               e2 = malloc(1000000 * sizeof(int));
  a4:	83 ec 0c             	sub    $0xc,%esp
  a7:	68 00 09 3d 00       	push   $0x3d0900
  ac:	e8 29 05 00 00       	call   5da <malloc>
  b1:	83 c4 10             	add    $0x10,%esp
  b4:	eb a8                	jmp    5e <main+0x5e>
                         printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  b6:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  bd:	ff 34 07             	pushl  (%edi,%eax,1)
  c0:	ff 34 06             	pushl  (%esi,%eax,1)
  c3:	68 6c 06 00 00       	push   $0x66c
  c8:	6a 01                	push   $0x1
  ca:	e8 e2 02 00 00       	call   3b1 <printf>
                 for (int i = 0; i < numframes; i++)
  cf:	83 c3 01             	add    $0x1,%ebx
  d2:	83 c4 10             	add    $0x10,%esp
  d5:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
  db:	7e d9                	jle    b6 <main+0xb6>
         }
 
         exit();
  dd:	e8 8d 01 00 00       	call   26f <exit>

000000e2 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  e2:	55                   	push   %ebp
  e3:	89 e5                	mov    %esp,%ebp
  e5:	53                   	push   %ebx
  e6:	8b 45 08             	mov    0x8(%ebp),%eax
  e9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  ec:	89 c2                	mov    %eax,%edx
  ee:	0f b6 19             	movzbl (%ecx),%ebx
  f1:	88 1a                	mov    %bl,(%edx)
  f3:	8d 52 01             	lea    0x1(%edx),%edx
  f6:	8d 49 01             	lea    0x1(%ecx),%ecx
  f9:	84 db                	test   %bl,%bl
  fb:	75 f1                	jne    ee <strcpy+0xc>
    ;
  return os;
}
  fd:	5b                   	pop    %ebx
  fe:	5d                   	pop    %ebp
  ff:	c3                   	ret    

00000100 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 100:	55                   	push   %ebp
 101:	89 e5                	mov    %esp,%ebp
 103:	8b 4d 08             	mov    0x8(%ebp),%ecx
 106:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 109:	eb 06                	jmp    111 <strcmp+0x11>
    p++, q++;
 10b:	83 c1 01             	add    $0x1,%ecx
 10e:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 111:	0f b6 01             	movzbl (%ecx),%eax
 114:	84 c0                	test   %al,%al
 116:	74 04                	je     11c <strcmp+0x1c>
 118:	3a 02                	cmp    (%edx),%al
 11a:	74 ef                	je     10b <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 11c:	0f b6 c0             	movzbl %al,%eax
 11f:	0f b6 12             	movzbl (%edx),%edx
 122:	29 d0                	sub    %edx,%eax
}
 124:	5d                   	pop    %ebp
 125:	c3                   	ret    

00000126 <strlen>:

uint
strlen(const char *s)
{
 126:	55                   	push   %ebp
 127:	89 e5                	mov    %esp,%ebp
 129:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 12c:	ba 00 00 00 00       	mov    $0x0,%edx
 131:	eb 03                	jmp    136 <strlen+0x10>
 133:	83 c2 01             	add    $0x1,%edx
 136:	89 d0                	mov    %edx,%eax
 138:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 13c:	75 f5                	jne    133 <strlen+0xd>
    ;
  return n;
}
 13e:	5d                   	pop    %ebp
 13f:	c3                   	ret    

00000140 <memset>:

void*
memset(void *dst, int c, uint n)
{
 140:	55                   	push   %ebp
 141:	89 e5                	mov    %esp,%ebp
 143:	57                   	push   %edi
 144:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 147:	89 d7                	mov    %edx,%edi
 149:	8b 4d 10             	mov    0x10(%ebp),%ecx
 14c:	8b 45 0c             	mov    0xc(%ebp),%eax
 14f:	fc                   	cld    
 150:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 152:	89 d0                	mov    %edx,%eax
 154:	5f                   	pop    %edi
 155:	5d                   	pop    %ebp
 156:	c3                   	ret    

00000157 <strchr>:

char*
strchr(const char *s, char c)
{
 157:	55                   	push   %ebp
 158:	89 e5                	mov    %esp,%ebp
 15a:	8b 45 08             	mov    0x8(%ebp),%eax
 15d:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 161:	0f b6 10             	movzbl (%eax),%edx
 164:	84 d2                	test   %dl,%dl
 166:	74 09                	je     171 <strchr+0x1a>
    if(*s == c)
 168:	38 ca                	cmp    %cl,%dl
 16a:	74 0a                	je     176 <strchr+0x1f>
  for(; *s; s++)
 16c:	83 c0 01             	add    $0x1,%eax
 16f:	eb f0                	jmp    161 <strchr+0xa>
      return (char*)s;
  return 0;
 171:	b8 00 00 00 00       	mov    $0x0,%eax
}
 176:	5d                   	pop    %ebp
 177:	c3                   	ret    

00000178 <gets>:

char*
gets(char *buf, int max)
{
 178:	55                   	push   %ebp
 179:	89 e5                	mov    %esp,%ebp
 17b:	57                   	push   %edi
 17c:	56                   	push   %esi
 17d:	53                   	push   %ebx
 17e:	83 ec 1c             	sub    $0x1c,%esp
 181:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 184:	bb 00 00 00 00       	mov    $0x0,%ebx
 189:	8d 73 01             	lea    0x1(%ebx),%esi
 18c:	3b 75 0c             	cmp    0xc(%ebp),%esi
 18f:	7d 2e                	jge    1bf <gets+0x47>
    cc = read(0, &c, 1);
 191:	83 ec 04             	sub    $0x4,%esp
 194:	6a 01                	push   $0x1
 196:	8d 45 e7             	lea    -0x19(%ebp),%eax
 199:	50                   	push   %eax
 19a:	6a 00                	push   $0x0
 19c:	e8 e6 00 00 00       	call   287 <read>
    if(cc < 1)
 1a1:	83 c4 10             	add    $0x10,%esp
 1a4:	85 c0                	test   %eax,%eax
 1a6:	7e 17                	jle    1bf <gets+0x47>
      break;
    buf[i++] = c;
 1a8:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1ac:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1af:	3c 0a                	cmp    $0xa,%al
 1b1:	0f 94 c2             	sete   %dl
 1b4:	3c 0d                	cmp    $0xd,%al
 1b6:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1b9:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1bb:	08 c2                	or     %al,%dl
 1bd:	74 ca                	je     189 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1bf:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1c3:	89 f8                	mov    %edi,%eax
 1c5:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1c8:	5b                   	pop    %ebx
 1c9:	5e                   	pop    %esi
 1ca:	5f                   	pop    %edi
 1cb:	5d                   	pop    %ebp
 1cc:	c3                   	ret    

000001cd <stat>:

int
stat(const char *n, struct stat *st)
{
 1cd:	55                   	push   %ebp
 1ce:	89 e5                	mov    %esp,%ebp
 1d0:	56                   	push   %esi
 1d1:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1d2:	83 ec 08             	sub    $0x8,%esp
 1d5:	6a 00                	push   $0x0
 1d7:	ff 75 08             	pushl  0x8(%ebp)
 1da:	e8 d0 00 00 00       	call   2af <open>
  if(fd < 0)
 1df:	83 c4 10             	add    $0x10,%esp
 1e2:	85 c0                	test   %eax,%eax
 1e4:	78 24                	js     20a <stat+0x3d>
 1e6:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1e8:	83 ec 08             	sub    $0x8,%esp
 1eb:	ff 75 0c             	pushl  0xc(%ebp)
 1ee:	50                   	push   %eax
 1ef:	e8 d3 00 00 00       	call   2c7 <fstat>
 1f4:	89 c6                	mov    %eax,%esi
  close(fd);
 1f6:	89 1c 24             	mov    %ebx,(%esp)
 1f9:	e8 99 00 00 00       	call   297 <close>
  return r;
 1fe:	83 c4 10             	add    $0x10,%esp
}
 201:	89 f0                	mov    %esi,%eax
 203:	8d 65 f8             	lea    -0x8(%ebp),%esp
 206:	5b                   	pop    %ebx
 207:	5e                   	pop    %esi
 208:	5d                   	pop    %ebp
 209:	c3                   	ret    
    return -1;
 20a:	be ff ff ff ff       	mov    $0xffffffff,%esi
 20f:	eb f0                	jmp    201 <stat+0x34>

00000211 <atoi>:

int
atoi(const char *s)
{
 211:	55                   	push   %ebp
 212:	89 e5                	mov    %esp,%ebp
 214:	53                   	push   %ebx
 215:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 218:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 21d:	eb 10                	jmp    22f <atoi+0x1e>
    n = n*10 + *s++ - '0';
 21f:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 222:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 225:	83 c1 01             	add    $0x1,%ecx
 228:	0f be d2             	movsbl %dl,%edx
 22b:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 22f:	0f b6 11             	movzbl (%ecx),%edx
 232:	8d 5a d0             	lea    -0x30(%edx),%ebx
 235:	80 fb 09             	cmp    $0x9,%bl
 238:	76 e5                	jbe    21f <atoi+0xe>
  return n;
}
 23a:	5b                   	pop    %ebx
 23b:	5d                   	pop    %ebp
 23c:	c3                   	ret    

0000023d <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 23d:	55                   	push   %ebp
 23e:	89 e5                	mov    %esp,%ebp
 240:	56                   	push   %esi
 241:	53                   	push   %ebx
 242:	8b 45 08             	mov    0x8(%ebp),%eax
 245:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 248:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 24b:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 24d:	eb 0d                	jmp    25c <memmove+0x1f>
    *dst++ = *src++;
 24f:	0f b6 13             	movzbl (%ebx),%edx
 252:	88 11                	mov    %dl,(%ecx)
 254:	8d 5b 01             	lea    0x1(%ebx),%ebx
 257:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 25a:	89 f2                	mov    %esi,%edx
 25c:	8d 72 ff             	lea    -0x1(%edx),%esi
 25f:	85 d2                	test   %edx,%edx
 261:	7f ec                	jg     24f <memmove+0x12>
  return vdst;
}
 263:	5b                   	pop    %ebx
 264:	5e                   	pop    %esi
 265:	5d                   	pop    %ebp
 266:	c3                   	ret    

00000267 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 267:	b8 01 00 00 00       	mov    $0x1,%eax
 26c:	cd 40                	int    $0x40
 26e:	c3                   	ret    

0000026f <exit>:
SYSCALL(exit)
 26f:	b8 02 00 00 00       	mov    $0x2,%eax
 274:	cd 40                	int    $0x40
 276:	c3                   	ret    

00000277 <wait>:
SYSCALL(wait)
 277:	b8 03 00 00 00       	mov    $0x3,%eax
 27c:	cd 40                	int    $0x40
 27e:	c3                   	ret    

0000027f <pipe>:
SYSCALL(pipe)
 27f:	b8 04 00 00 00       	mov    $0x4,%eax
 284:	cd 40                	int    $0x40
 286:	c3                   	ret    

00000287 <read>:
SYSCALL(read)
 287:	b8 05 00 00 00       	mov    $0x5,%eax
 28c:	cd 40                	int    $0x40
 28e:	c3                   	ret    

0000028f <write>:
SYSCALL(write)
 28f:	b8 10 00 00 00       	mov    $0x10,%eax
 294:	cd 40                	int    $0x40
 296:	c3                   	ret    

00000297 <close>:
SYSCALL(close)
 297:	b8 15 00 00 00       	mov    $0x15,%eax
 29c:	cd 40                	int    $0x40
 29e:	c3                   	ret    

0000029f <kill>:
SYSCALL(kill)
 29f:	b8 06 00 00 00       	mov    $0x6,%eax
 2a4:	cd 40                	int    $0x40
 2a6:	c3                   	ret    

000002a7 <exec>:
SYSCALL(exec)
 2a7:	b8 07 00 00 00       	mov    $0x7,%eax
 2ac:	cd 40                	int    $0x40
 2ae:	c3                   	ret    

000002af <open>:
SYSCALL(open)
 2af:	b8 0f 00 00 00       	mov    $0xf,%eax
 2b4:	cd 40                	int    $0x40
 2b6:	c3                   	ret    

000002b7 <mknod>:
SYSCALL(mknod)
 2b7:	b8 11 00 00 00       	mov    $0x11,%eax
 2bc:	cd 40                	int    $0x40
 2be:	c3                   	ret    

000002bf <unlink>:
SYSCALL(unlink)
 2bf:	b8 12 00 00 00       	mov    $0x12,%eax
 2c4:	cd 40                	int    $0x40
 2c6:	c3                   	ret    

000002c7 <fstat>:
SYSCALL(fstat)
 2c7:	b8 08 00 00 00       	mov    $0x8,%eax
 2cc:	cd 40                	int    $0x40
 2ce:	c3                   	ret    

000002cf <link>:
SYSCALL(link)
 2cf:	b8 13 00 00 00       	mov    $0x13,%eax
 2d4:	cd 40                	int    $0x40
 2d6:	c3                   	ret    

000002d7 <mkdir>:
SYSCALL(mkdir)
 2d7:	b8 14 00 00 00       	mov    $0x14,%eax
 2dc:	cd 40                	int    $0x40
 2de:	c3                   	ret    

000002df <chdir>:
SYSCALL(chdir)
 2df:	b8 09 00 00 00       	mov    $0x9,%eax
 2e4:	cd 40                	int    $0x40
 2e6:	c3                   	ret    

000002e7 <dup>:
SYSCALL(dup)
 2e7:	b8 0a 00 00 00       	mov    $0xa,%eax
 2ec:	cd 40                	int    $0x40
 2ee:	c3                   	ret    

000002ef <getpid>:
SYSCALL(getpid)
 2ef:	b8 0b 00 00 00       	mov    $0xb,%eax
 2f4:	cd 40                	int    $0x40
 2f6:	c3                   	ret    

000002f7 <sbrk>:
SYSCALL(sbrk)
 2f7:	b8 0c 00 00 00       	mov    $0xc,%eax
 2fc:	cd 40                	int    $0x40
 2fe:	c3                   	ret    

000002ff <sleep>:
SYSCALL(sleep)
 2ff:	b8 0d 00 00 00       	mov    $0xd,%eax
 304:	cd 40                	int    $0x40
 306:	c3                   	ret    

00000307 <uptime>:
SYSCALL(uptime)
 307:	b8 0e 00 00 00       	mov    $0xe,%eax
 30c:	cd 40                	int    $0x40
 30e:	c3                   	ret    

0000030f <dump_physmem>:
SYSCALL(dump_physmem)
 30f:	b8 16 00 00 00       	mov    $0x16,%eax
 314:	cd 40                	int    $0x40
 316:	c3                   	ret    

00000317 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 317:	55                   	push   %ebp
 318:	89 e5                	mov    %esp,%ebp
 31a:	83 ec 1c             	sub    $0x1c,%esp
 31d:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 320:	6a 01                	push   $0x1
 322:	8d 55 f4             	lea    -0xc(%ebp),%edx
 325:	52                   	push   %edx
 326:	50                   	push   %eax
 327:	e8 63 ff ff ff       	call   28f <write>
}
 32c:	83 c4 10             	add    $0x10,%esp
 32f:	c9                   	leave  
 330:	c3                   	ret    

00000331 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 331:	55                   	push   %ebp
 332:	89 e5                	mov    %esp,%ebp
 334:	57                   	push   %edi
 335:	56                   	push   %esi
 336:	53                   	push   %ebx
 337:	83 ec 2c             	sub    $0x2c,%esp
 33a:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 33c:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 340:	0f 95 c3             	setne  %bl
 343:	89 d0                	mov    %edx,%eax
 345:	c1 e8 1f             	shr    $0x1f,%eax
 348:	84 c3                	test   %al,%bl
 34a:	74 10                	je     35c <printint+0x2b>
    neg = 1;
    x = -xx;
 34c:	f7 da                	neg    %edx
    neg = 1;
 34e:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 355:	be 00 00 00 00       	mov    $0x0,%esi
 35a:	eb 0b                	jmp    367 <printint+0x36>
  neg = 0;
 35c:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 363:	eb f0                	jmp    355 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 365:	89 c6                	mov    %eax,%esi
 367:	89 d0                	mov    %edx,%eax
 369:	ba 00 00 00 00       	mov    $0x0,%edx
 36e:	f7 f1                	div    %ecx
 370:	89 c3                	mov    %eax,%ebx
 372:	8d 46 01             	lea    0x1(%esi),%eax
 375:	0f b6 92 90 06 00 00 	movzbl 0x690(%edx),%edx
 37c:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 380:	89 da                	mov    %ebx,%edx
 382:	85 db                	test   %ebx,%ebx
 384:	75 df                	jne    365 <printint+0x34>
 386:	89 c3                	mov    %eax,%ebx
  if(neg)
 388:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 38c:	74 16                	je     3a4 <printint+0x73>
    buf[i++] = '-';
 38e:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 393:	8d 5e 02             	lea    0x2(%esi),%ebx
 396:	eb 0c                	jmp    3a4 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 398:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 39d:	89 f8                	mov    %edi,%eax
 39f:	e8 73 ff ff ff       	call   317 <putc>
  while(--i >= 0)
 3a4:	83 eb 01             	sub    $0x1,%ebx
 3a7:	79 ef                	jns    398 <printint+0x67>
}
 3a9:	83 c4 2c             	add    $0x2c,%esp
 3ac:	5b                   	pop    %ebx
 3ad:	5e                   	pop    %esi
 3ae:	5f                   	pop    %edi
 3af:	5d                   	pop    %ebp
 3b0:	c3                   	ret    

000003b1 <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3b1:	55                   	push   %ebp
 3b2:	89 e5                	mov    %esp,%ebp
 3b4:	57                   	push   %edi
 3b5:	56                   	push   %esi
 3b6:	53                   	push   %ebx
 3b7:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3ba:	8d 45 10             	lea    0x10(%ebp),%eax
 3bd:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3c0:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3c5:	bb 00 00 00 00       	mov    $0x0,%ebx
 3ca:	eb 14                	jmp    3e0 <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3cc:	89 fa                	mov    %edi,%edx
 3ce:	8b 45 08             	mov    0x8(%ebp),%eax
 3d1:	e8 41 ff ff ff       	call   317 <putc>
 3d6:	eb 05                	jmp    3dd <printf+0x2c>
      }
    } else if(state == '%'){
 3d8:	83 fe 25             	cmp    $0x25,%esi
 3db:	74 25                	je     402 <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3dd:	83 c3 01             	add    $0x1,%ebx
 3e0:	8b 45 0c             	mov    0xc(%ebp),%eax
 3e3:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3e7:	84 c0                	test   %al,%al
 3e9:	0f 84 23 01 00 00    	je     512 <printf+0x161>
    c = fmt[i] & 0xff;
 3ef:	0f be f8             	movsbl %al,%edi
 3f2:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3f5:	85 f6                	test   %esi,%esi
 3f7:	75 df                	jne    3d8 <printf+0x27>
      if(c == '%'){
 3f9:	83 f8 25             	cmp    $0x25,%eax
 3fc:	75 ce                	jne    3cc <printf+0x1b>
        state = '%';
 3fe:	89 c6                	mov    %eax,%esi
 400:	eb db                	jmp    3dd <printf+0x2c>
      if(c == 'd'){
 402:	83 f8 64             	cmp    $0x64,%eax
 405:	74 49                	je     450 <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 407:	83 f8 78             	cmp    $0x78,%eax
 40a:	0f 94 c1             	sete   %cl
 40d:	83 f8 70             	cmp    $0x70,%eax
 410:	0f 94 c2             	sete   %dl
 413:	08 d1                	or     %dl,%cl
 415:	75 63                	jne    47a <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 417:	83 f8 73             	cmp    $0x73,%eax
 41a:	0f 84 84 00 00 00    	je     4a4 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 420:	83 f8 63             	cmp    $0x63,%eax
 423:	0f 84 b7 00 00 00    	je     4e0 <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 429:	83 f8 25             	cmp    $0x25,%eax
 42c:	0f 84 cc 00 00 00    	je     4fe <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 432:	ba 25 00 00 00       	mov    $0x25,%edx
 437:	8b 45 08             	mov    0x8(%ebp),%eax
 43a:	e8 d8 fe ff ff       	call   317 <putc>
        putc(fd, c);
 43f:	89 fa                	mov    %edi,%edx
 441:	8b 45 08             	mov    0x8(%ebp),%eax
 444:	e8 ce fe ff ff       	call   317 <putc>
      }
      state = 0;
 449:	be 00 00 00 00       	mov    $0x0,%esi
 44e:	eb 8d                	jmp    3dd <printf+0x2c>
        printint(fd, *ap, 10, 1);
 450:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 453:	8b 17                	mov    (%edi),%edx
 455:	83 ec 0c             	sub    $0xc,%esp
 458:	6a 01                	push   $0x1
 45a:	b9 0a 00 00 00       	mov    $0xa,%ecx
 45f:	8b 45 08             	mov    0x8(%ebp),%eax
 462:	e8 ca fe ff ff       	call   331 <printint>
        ap++;
 467:	83 c7 04             	add    $0x4,%edi
 46a:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 46d:	83 c4 10             	add    $0x10,%esp
      state = 0;
 470:	be 00 00 00 00       	mov    $0x0,%esi
 475:	e9 63 ff ff ff       	jmp    3dd <printf+0x2c>
        printint(fd, *ap, 16, 0);
 47a:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 47d:	8b 17                	mov    (%edi),%edx
 47f:	83 ec 0c             	sub    $0xc,%esp
 482:	6a 00                	push   $0x0
 484:	b9 10 00 00 00       	mov    $0x10,%ecx
 489:	8b 45 08             	mov    0x8(%ebp),%eax
 48c:	e8 a0 fe ff ff       	call   331 <printint>
        ap++;
 491:	83 c7 04             	add    $0x4,%edi
 494:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 497:	83 c4 10             	add    $0x10,%esp
      state = 0;
 49a:	be 00 00 00 00       	mov    $0x0,%esi
 49f:	e9 39 ff ff ff       	jmp    3dd <printf+0x2c>
        s = (char*)*ap;
 4a4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4a7:	8b 30                	mov    (%eax),%esi
        ap++;
 4a9:	83 c0 04             	add    $0x4,%eax
 4ac:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4af:	85 f6                	test   %esi,%esi
 4b1:	75 28                	jne    4db <printf+0x12a>
          s = "(null)";
 4b3:	be 88 06 00 00       	mov    $0x688,%esi
 4b8:	8b 7d 08             	mov    0x8(%ebp),%edi
 4bb:	eb 0d                	jmp    4ca <printf+0x119>
          putc(fd, *s);
 4bd:	0f be d2             	movsbl %dl,%edx
 4c0:	89 f8                	mov    %edi,%eax
 4c2:	e8 50 fe ff ff       	call   317 <putc>
          s++;
 4c7:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4ca:	0f b6 16             	movzbl (%esi),%edx
 4cd:	84 d2                	test   %dl,%dl
 4cf:	75 ec                	jne    4bd <printf+0x10c>
      state = 0;
 4d1:	be 00 00 00 00       	mov    $0x0,%esi
 4d6:	e9 02 ff ff ff       	jmp    3dd <printf+0x2c>
 4db:	8b 7d 08             	mov    0x8(%ebp),%edi
 4de:	eb ea                	jmp    4ca <printf+0x119>
        putc(fd, *ap);
 4e0:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4e3:	0f be 17             	movsbl (%edi),%edx
 4e6:	8b 45 08             	mov    0x8(%ebp),%eax
 4e9:	e8 29 fe ff ff       	call   317 <putc>
        ap++;
 4ee:	83 c7 04             	add    $0x4,%edi
 4f1:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4f4:	be 00 00 00 00       	mov    $0x0,%esi
 4f9:	e9 df fe ff ff       	jmp    3dd <printf+0x2c>
        putc(fd, c);
 4fe:	89 fa                	mov    %edi,%edx
 500:	8b 45 08             	mov    0x8(%ebp),%eax
 503:	e8 0f fe ff ff       	call   317 <putc>
      state = 0;
 508:	be 00 00 00 00       	mov    $0x0,%esi
 50d:	e9 cb fe ff ff       	jmp    3dd <printf+0x2c>
    }
  }
}
 512:	8d 65 f4             	lea    -0xc(%ebp),%esp
 515:	5b                   	pop    %ebx
 516:	5e                   	pop    %esi
 517:	5f                   	pop    %edi
 518:	5d                   	pop    %ebp
 519:	c3                   	ret    

0000051a <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 51a:	55                   	push   %ebp
 51b:	89 e5                	mov    %esp,%ebp
 51d:	57                   	push   %edi
 51e:	56                   	push   %esi
 51f:	53                   	push   %ebx
 520:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 523:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 526:	a1 34 09 00 00       	mov    0x934,%eax
 52b:	eb 02                	jmp    52f <free+0x15>
 52d:	89 d0                	mov    %edx,%eax
 52f:	39 c8                	cmp    %ecx,%eax
 531:	73 04                	jae    537 <free+0x1d>
 533:	39 08                	cmp    %ecx,(%eax)
 535:	77 12                	ja     549 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 537:	8b 10                	mov    (%eax),%edx
 539:	39 c2                	cmp    %eax,%edx
 53b:	77 f0                	ja     52d <free+0x13>
 53d:	39 c8                	cmp    %ecx,%eax
 53f:	72 08                	jb     549 <free+0x2f>
 541:	39 ca                	cmp    %ecx,%edx
 543:	77 04                	ja     549 <free+0x2f>
 545:	89 d0                	mov    %edx,%eax
 547:	eb e6                	jmp    52f <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 549:	8b 73 fc             	mov    -0x4(%ebx),%esi
 54c:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 54f:	8b 10                	mov    (%eax),%edx
 551:	39 d7                	cmp    %edx,%edi
 553:	74 19                	je     56e <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 555:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 558:	8b 50 04             	mov    0x4(%eax),%edx
 55b:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 55e:	39 ce                	cmp    %ecx,%esi
 560:	74 1b                	je     57d <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 562:	89 08                	mov    %ecx,(%eax)
  freep = p;
 564:	a3 34 09 00 00       	mov    %eax,0x934
}
 569:	5b                   	pop    %ebx
 56a:	5e                   	pop    %esi
 56b:	5f                   	pop    %edi
 56c:	5d                   	pop    %ebp
 56d:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 56e:	03 72 04             	add    0x4(%edx),%esi
 571:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 574:	8b 10                	mov    (%eax),%edx
 576:	8b 12                	mov    (%edx),%edx
 578:	89 53 f8             	mov    %edx,-0x8(%ebx)
 57b:	eb db                	jmp    558 <free+0x3e>
    p->s.size += bp->s.size;
 57d:	03 53 fc             	add    -0x4(%ebx),%edx
 580:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 583:	8b 53 f8             	mov    -0x8(%ebx),%edx
 586:	89 10                	mov    %edx,(%eax)
 588:	eb da                	jmp    564 <free+0x4a>

0000058a <morecore>:

static Header*
morecore(uint nu)
{
 58a:	55                   	push   %ebp
 58b:	89 e5                	mov    %esp,%ebp
 58d:	53                   	push   %ebx
 58e:	83 ec 04             	sub    $0x4,%esp
 591:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 593:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 598:	77 05                	ja     59f <morecore+0x15>
    nu = 4096;
 59a:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 59f:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5a6:	83 ec 0c             	sub    $0xc,%esp
 5a9:	50                   	push   %eax
 5aa:	e8 48 fd ff ff       	call   2f7 <sbrk>
  if(p == (char*)-1)
 5af:	83 c4 10             	add    $0x10,%esp
 5b2:	83 f8 ff             	cmp    $0xffffffff,%eax
 5b5:	74 1c                	je     5d3 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5b7:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5ba:	83 c0 08             	add    $0x8,%eax
 5bd:	83 ec 0c             	sub    $0xc,%esp
 5c0:	50                   	push   %eax
 5c1:	e8 54 ff ff ff       	call   51a <free>
  return freep;
 5c6:	a1 34 09 00 00       	mov    0x934,%eax
 5cb:	83 c4 10             	add    $0x10,%esp
}
 5ce:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5d1:	c9                   	leave  
 5d2:	c3                   	ret    
    return 0;
 5d3:	b8 00 00 00 00       	mov    $0x0,%eax
 5d8:	eb f4                	jmp    5ce <morecore+0x44>

000005da <malloc>:

void*
malloc(uint nbytes)
{
 5da:	55                   	push   %ebp
 5db:	89 e5                	mov    %esp,%ebp
 5dd:	53                   	push   %ebx
 5de:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5e1:	8b 45 08             	mov    0x8(%ebp),%eax
 5e4:	8d 58 07             	lea    0x7(%eax),%ebx
 5e7:	c1 eb 03             	shr    $0x3,%ebx
 5ea:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5ed:	8b 0d 34 09 00 00    	mov    0x934,%ecx
 5f3:	85 c9                	test   %ecx,%ecx
 5f5:	74 04                	je     5fb <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5f7:	8b 01                	mov    (%ecx),%eax
 5f9:	eb 4d                	jmp    648 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5fb:	c7 05 34 09 00 00 38 	movl   $0x938,0x934
 602:	09 00 00 
 605:	c7 05 38 09 00 00 38 	movl   $0x938,0x938
 60c:	09 00 00 
    base.s.size = 0;
 60f:	c7 05 3c 09 00 00 00 	movl   $0x0,0x93c
 616:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 619:	b9 38 09 00 00       	mov    $0x938,%ecx
 61e:	eb d7                	jmp    5f7 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 620:	39 da                	cmp    %ebx,%edx
 622:	74 1a                	je     63e <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 624:	29 da                	sub    %ebx,%edx
 626:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 629:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 62c:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 62f:	89 0d 34 09 00 00    	mov    %ecx,0x934
      return (void*)(p + 1);
 635:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 638:	83 c4 04             	add    $0x4,%esp
 63b:	5b                   	pop    %ebx
 63c:	5d                   	pop    %ebp
 63d:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 63e:	8b 10                	mov    (%eax),%edx
 640:	89 11                	mov    %edx,(%ecx)
 642:	eb eb                	jmp    62f <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 644:	89 c1                	mov    %eax,%ecx
 646:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 648:	8b 50 04             	mov    0x4(%eax),%edx
 64b:	39 da                	cmp    %ebx,%edx
 64d:	73 d1                	jae    620 <malloc+0x46>
    if(p == freep)
 64f:	39 05 34 09 00 00    	cmp    %eax,0x934
 655:	75 ed                	jne    644 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 657:	89 d8                	mov    %ebx,%eax
 659:	e8 2c ff ff ff       	call   58a <morecore>
 65e:	85 c0                	test   %eax,%eax
 660:	75 e2                	jne    644 <malloc+0x6a>
        return 0;
 662:	b8 00 00 00 00       	mov    $0x0,%eax
 667:	eb cf                	jmp    638 <malloc+0x5e>
