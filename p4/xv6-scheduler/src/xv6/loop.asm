
_loop:     file format elf32-i386


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
   d:	51                   	push   %ecx
   e:	83 ec 04             	sub    $0x4,%esp
    //printf(0, "-> welcome to loop.c: PID = %d\n", getpid());
		for(;;) {
        sleep(10);
  11:	83 ec 0c             	sub    $0xc,%esp
  14:	6a 0a                	push   $0xa
  16:	e8 37 02 00 00       	call   252 <sleep>
        printf(0, "%d\n", getpid());
  1b:	e8 22 02 00 00       	call   242 <getpid>
  20:	83 c4 0c             	add    $0xc,%esp
  23:	50                   	push   %eax
  24:	68 d4 05 00 00       	push   $0x5d4
  29:	6a 00                	push   $0x0
  2b:	e8 ec 02 00 00       	call   31c <printf>
  30:	83 c4 10             	add    $0x10,%esp
  33:	eb dc                	jmp    11 <main+0x11>

00000035 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  35:	55                   	push   %ebp
  36:	89 e5                	mov    %esp,%ebp
  38:	53                   	push   %ebx
  39:	8b 45 08             	mov    0x8(%ebp),%eax
  3c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  3f:	89 c2                	mov    %eax,%edx
  41:	0f b6 19             	movzbl (%ecx),%ebx
  44:	88 1a                	mov    %bl,(%edx)
  46:	8d 52 01             	lea    0x1(%edx),%edx
  49:	8d 49 01             	lea    0x1(%ecx),%ecx
  4c:	84 db                	test   %bl,%bl
  4e:	75 f1                	jne    41 <strcpy+0xc>
    ;
  return os;
}
  50:	5b                   	pop    %ebx
  51:	5d                   	pop    %ebp
  52:	c3                   	ret    

00000053 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  53:	55                   	push   %ebp
  54:	89 e5                	mov    %esp,%ebp
  56:	8b 4d 08             	mov    0x8(%ebp),%ecx
  59:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
  5c:	eb 06                	jmp    64 <strcmp+0x11>
    p++, q++;
  5e:	83 c1 01             	add    $0x1,%ecx
  61:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
  64:	0f b6 01             	movzbl (%ecx),%eax
  67:	84 c0                	test   %al,%al
  69:	74 04                	je     6f <strcmp+0x1c>
  6b:	3a 02                	cmp    (%edx),%al
  6d:	74 ef                	je     5e <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
  6f:	0f b6 c0             	movzbl %al,%eax
  72:	0f b6 12             	movzbl (%edx),%edx
  75:	29 d0                	sub    %edx,%eax
}
  77:	5d                   	pop    %ebp
  78:	c3                   	ret    

00000079 <strlen>:

uint
strlen(const char *s)
{
  79:	55                   	push   %ebp
  7a:	89 e5                	mov    %esp,%ebp
  7c:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
  7f:	ba 00 00 00 00       	mov    $0x0,%edx
  84:	eb 03                	jmp    89 <strlen+0x10>
  86:	83 c2 01             	add    $0x1,%edx
  89:	89 d0                	mov    %edx,%eax
  8b:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
  8f:	75 f5                	jne    86 <strlen+0xd>
    ;
  return n;
}
  91:	5d                   	pop    %ebp
  92:	c3                   	ret    

00000093 <memset>:

void*
memset(void *dst, int c, uint n)
{
  93:	55                   	push   %ebp
  94:	89 e5                	mov    %esp,%ebp
  96:	57                   	push   %edi
  97:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
  9a:	89 d7                	mov    %edx,%edi
  9c:	8b 4d 10             	mov    0x10(%ebp),%ecx
  9f:	8b 45 0c             	mov    0xc(%ebp),%eax
  a2:	fc                   	cld    
  a3:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
  a5:	89 d0                	mov    %edx,%eax
  a7:	5f                   	pop    %edi
  a8:	5d                   	pop    %ebp
  a9:	c3                   	ret    

000000aa <strchr>:

char*
strchr(const char *s, char c)
{
  aa:	55                   	push   %ebp
  ab:	89 e5                	mov    %esp,%ebp
  ad:	8b 45 08             	mov    0x8(%ebp),%eax
  b0:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
  b4:	0f b6 10             	movzbl (%eax),%edx
  b7:	84 d2                	test   %dl,%dl
  b9:	74 09                	je     c4 <strchr+0x1a>
    if(*s == c)
  bb:	38 ca                	cmp    %cl,%dl
  bd:	74 0a                	je     c9 <strchr+0x1f>
  for(; *s; s++)
  bf:	83 c0 01             	add    $0x1,%eax
  c2:	eb f0                	jmp    b4 <strchr+0xa>
      return (char*)s;
  return 0;
  c4:	b8 00 00 00 00       	mov    $0x0,%eax
}
  c9:	5d                   	pop    %ebp
  ca:	c3                   	ret    

000000cb <gets>:

char*
gets(char *buf, int max)
{
  cb:	55                   	push   %ebp
  cc:	89 e5                	mov    %esp,%ebp
  ce:	57                   	push   %edi
  cf:	56                   	push   %esi
  d0:	53                   	push   %ebx
  d1:	83 ec 1c             	sub    $0x1c,%esp
  d4:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
  d7:	bb 00 00 00 00       	mov    $0x0,%ebx
  dc:	8d 73 01             	lea    0x1(%ebx),%esi
  df:	3b 75 0c             	cmp    0xc(%ebp),%esi
  e2:	7d 2e                	jge    112 <gets+0x47>
    cc = read(0, &c, 1);
  e4:	83 ec 04             	sub    $0x4,%esp
  e7:	6a 01                	push   $0x1
  e9:	8d 45 e7             	lea    -0x19(%ebp),%eax
  ec:	50                   	push   %eax
  ed:	6a 00                	push   $0x0
  ef:	e8 e6 00 00 00       	call   1da <read>
    if(cc < 1)
  f4:	83 c4 10             	add    $0x10,%esp
  f7:	85 c0                	test   %eax,%eax
  f9:	7e 17                	jle    112 <gets+0x47>
      break;
    buf[i++] = c;
  fb:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
  ff:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 102:	3c 0a                	cmp    $0xa,%al
 104:	0f 94 c2             	sete   %dl
 107:	3c 0d                	cmp    $0xd,%al
 109:	0f 94 c0             	sete   %al
    buf[i++] = c;
 10c:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 10e:	08 c2                	or     %al,%dl
 110:	74 ca                	je     dc <gets+0x11>
      break;
  }
  buf[i] = '\0';
 112:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 116:	89 f8                	mov    %edi,%eax
 118:	8d 65 f4             	lea    -0xc(%ebp),%esp
 11b:	5b                   	pop    %ebx
 11c:	5e                   	pop    %esi
 11d:	5f                   	pop    %edi
 11e:	5d                   	pop    %ebp
 11f:	c3                   	ret    

00000120 <stat>:

int
stat(const char *n, struct stat *st)
{
 120:	55                   	push   %ebp
 121:	89 e5                	mov    %esp,%ebp
 123:	56                   	push   %esi
 124:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 125:	83 ec 08             	sub    $0x8,%esp
 128:	6a 00                	push   $0x0
 12a:	ff 75 08             	pushl  0x8(%ebp)
 12d:	e8 d0 00 00 00       	call   202 <open>
  if(fd < 0)
 132:	83 c4 10             	add    $0x10,%esp
 135:	85 c0                	test   %eax,%eax
 137:	78 24                	js     15d <stat+0x3d>
 139:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 13b:	83 ec 08             	sub    $0x8,%esp
 13e:	ff 75 0c             	pushl  0xc(%ebp)
 141:	50                   	push   %eax
 142:	e8 d3 00 00 00       	call   21a <fstat>
 147:	89 c6                	mov    %eax,%esi
  close(fd);
 149:	89 1c 24             	mov    %ebx,(%esp)
 14c:	e8 99 00 00 00       	call   1ea <close>
  return r;
 151:	83 c4 10             	add    $0x10,%esp
}
 154:	89 f0                	mov    %esi,%eax
 156:	8d 65 f8             	lea    -0x8(%ebp),%esp
 159:	5b                   	pop    %ebx
 15a:	5e                   	pop    %esi
 15b:	5d                   	pop    %ebp
 15c:	c3                   	ret    
    return -1;
 15d:	be ff ff ff ff       	mov    $0xffffffff,%esi
 162:	eb f0                	jmp    154 <stat+0x34>

00000164 <atoi>:

int
atoi(const char *s)
{
 164:	55                   	push   %ebp
 165:	89 e5                	mov    %esp,%ebp
 167:	53                   	push   %ebx
 168:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 16b:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 170:	eb 10                	jmp    182 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 172:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 175:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 178:	83 c1 01             	add    $0x1,%ecx
 17b:	0f be d2             	movsbl %dl,%edx
 17e:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 182:	0f b6 11             	movzbl (%ecx),%edx
 185:	8d 5a d0             	lea    -0x30(%edx),%ebx
 188:	80 fb 09             	cmp    $0x9,%bl
 18b:	76 e5                	jbe    172 <atoi+0xe>
  return n;
}
 18d:	5b                   	pop    %ebx
 18e:	5d                   	pop    %ebp
 18f:	c3                   	ret    

00000190 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 190:	55                   	push   %ebp
 191:	89 e5                	mov    %esp,%ebp
 193:	56                   	push   %esi
 194:	53                   	push   %ebx
 195:	8b 45 08             	mov    0x8(%ebp),%eax
 198:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 19b:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 19e:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 1a0:	eb 0d                	jmp    1af <memmove+0x1f>
    *dst++ = *src++;
 1a2:	0f b6 13             	movzbl (%ebx),%edx
 1a5:	88 11                	mov    %dl,(%ecx)
 1a7:	8d 5b 01             	lea    0x1(%ebx),%ebx
 1aa:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 1ad:	89 f2                	mov    %esi,%edx
 1af:	8d 72 ff             	lea    -0x1(%edx),%esi
 1b2:	85 d2                	test   %edx,%edx
 1b4:	7f ec                	jg     1a2 <memmove+0x12>
  return vdst;
}
 1b6:	5b                   	pop    %ebx
 1b7:	5e                   	pop    %esi
 1b8:	5d                   	pop    %ebp
 1b9:	c3                   	ret    

000001ba <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 1ba:	b8 01 00 00 00       	mov    $0x1,%eax
 1bf:	cd 40                	int    $0x40
 1c1:	c3                   	ret    

000001c2 <exit>:
SYSCALL(exit)
 1c2:	b8 02 00 00 00       	mov    $0x2,%eax
 1c7:	cd 40                	int    $0x40
 1c9:	c3                   	ret    

000001ca <wait>:
SYSCALL(wait)
 1ca:	b8 03 00 00 00       	mov    $0x3,%eax
 1cf:	cd 40                	int    $0x40
 1d1:	c3                   	ret    

000001d2 <pipe>:
SYSCALL(pipe)
 1d2:	b8 04 00 00 00       	mov    $0x4,%eax
 1d7:	cd 40                	int    $0x40
 1d9:	c3                   	ret    

000001da <read>:
SYSCALL(read)
 1da:	b8 05 00 00 00       	mov    $0x5,%eax
 1df:	cd 40                	int    $0x40
 1e1:	c3                   	ret    

000001e2 <write>:
SYSCALL(write)
 1e2:	b8 10 00 00 00       	mov    $0x10,%eax
 1e7:	cd 40                	int    $0x40
 1e9:	c3                   	ret    

000001ea <close>:
SYSCALL(close)
 1ea:	b8 15 00 00 00       	mov    $0x15,%eax
 1ef:	cd 40                	int    $0x40
 1f1:	c3                   	ret    

000001f2 <kill>:
SYSCALL(kill)
 1f2:	b8 06 00 00 00       	mov    $0x6,%eax
 1f7:	cd 40                	int    $0x40
 1f9:	c3                   	ret    

000001fa <exec>:
SYSCALL(exec)
 1fa:	b8 07 00 00 00       	mov    $0x7,%eax
 1ff:	cd 40                	int    $0x40
 201:	c3                   	ret    

00000202 <open>:
SYSCALL(open)
 202:	b8 0f 00 00 00       	mov    $0xf,%eax
 207:	cd 40                	int    $0x40
 209:	c3                   	ret    

0000020a <mknod>:
SYSCALL(mknod)
 20a:	b8 11 00 00 00       	mov    $0x11,%eax
 20f:	cd 40                	int    $0x40
 211:	c3                   	ret    

00000212 <unlink>:
SYSCALL(unlink)
 212:	b8 12 00 00 00       	mov    $0x12,%eax
 217:	cd 40                	int    $0x40
 219:	c3                   	ret    

0000021a <fstat>:
SYSCALL(fstat)
 21a:	b8 08 00 00 00       	mov    $0x8,%eax
 21f:	cd 40                	int    $0x40
 221:	c3                   	ret    

00000222 <link>:
SYSCALL(link)
 222:	b8 13 00 00 00       	mov    $0x13,%eax
 227:	cd 40                	int    $0x40
 229:	c3                   	ret    

0000022a <mkdir>:
SYSCALL(mkdir)
 22a:	b8 14 00 00 00       	mov    $0x14,%eax
 22f:	cd 40                	int    $0x40
 231:	c3                   	ret    

00000232 <chdir>:
SYSCALL(chdir)
 232:	b8 09 00 00 00       	mov    $0x9,%eax
 237:	cd 40                	int    $0x40
 239:	c3                   	ret    

0000023a <dup>:
SYSCALL(dup)
 23a:	b8 0a 00 00 00       	mov    $0xa,%eax
 23f:	cd 40                	int    $0x40
 241:	c3                   	ret    

00000242 <getpid>:
SYSCALL(getpid)
 242:	b8 0b 00 00 00       	mov    $0xb,%eax
 247:	cd 40                	int    $0x40
 249:	c3                   	ret    

0000024a <sbrk>:
SYSCALL(sbrk)
 24a:	b8 0c 00 00 00       	mov    $0xc,%eax
 24f:	cd 40                	int    $0x40
 251:	c3                   	ret    

00000252 <sleep>:
SYSCALL(sleep)
 252:	b8 0d 00 00 00       	mov    $0xd,%eax
 257:	cd 40                	int    $0x40
 259:	c3                   	ret    

0000025a <uptime>:
SYSCALL(uptime)
 25a:	b8 0e 00 00 00       	mov    $0xe,%eax
 25f:	cd 40                	int    $0x40
 261:	c3                   	ret    

00000262 <setpri>:
SYSCALL(setpri)
 262:	b8 16 00 00 00       	mov    $0x16,%eax
 267:	cd 40                	int    $0x40
 269:	c3                   	ret    

0000026a <getpri>:
SYSCALL(getpri)
 26a:	b8 17 00 00 00       	mov    $0x17,%eax
 26f:	cd 40                	int    $0x40
 271:	c3                   	ret    

00000272 <fork2>:
SYSCALL(fork2)
 272:	b8 18 00 00 00       	mov    $0x18,%eax
 277:	cd 40                	int    $0x40
 279:	c3                   	ret    

0000027a <getpinfo>:
SYSCALL(getpinfo)
 27a:	b8 19 00 00 00       	mov    $0x19,%eax
 27f:	cd 40                	int    $0x40
 281:	c3                   	ret    

00000282 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 282:	55                   	push   %ebp
 283:	89 e5                	mov    %esp,%ebp
 285:	83 ec 1c             	sub    $0x1c,%esp
 288:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 28b:	6a 01                	push   $0x1
 28d:	8d 55 f4             	lea    -0xc(%ebp),%edx
 290:	52                   	push   %edx
 291:	50                   	push   %eax
 292:	e8 4b ff ff ff       	call   1e2 <write>
}
 297:	83 c4 10             	add    $0x10,%esp
 29a:	c9                   	leave  
 29b:	c3                   	ret    

0000029c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 29c:	55                   	push   %ebp
 29d:	89 e5                	mov    %esp,%ebp
 29f:	57                   	push   %edi
 2a0:	56                   	push   %esi
 2a1:	53                   	push   %ebx
 2a2:	83 ec 2c             	sub    $0x2c,%esp
 2a5:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 2a7:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 2ab:	0f 95 c3             	setne  %bl
 2ae:	89 d0                	mov    %edx,%eax
 2b0:	c1 e8 1f             	shr    $0x1f,%eax
 2b3:	84 c3                	test   %al,%bl
 2b5:	74 10                	je     2c7 <printint+0x2b>
    neg = 1;
    x = -xx;
 2b7:	f7 da                	neg    %edx
    neg = 1;
 2b9:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 2c0:	be 00 00 00 00       	mov    $0x0,%esi
 2c5:	eb 0b                	jmp    2d2 <printint+0x36>
  neg = 0;
 2c7:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 2ce:	eb f0                	jmp    2c0 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 2d0:	89 c6                	mov    %eax,%esi
 2d2:	89 d0                	mov    %edx,%eax
 2d4:	ba 00 00 00 00       	mov    $0x0,%edx
 2d9:	f7 f1                	div    %ecx
 2db:	89 c3                	mov    %eax,%ebx
 2dd:	8d 46 01             	lea    0x1(%esi),%eax
 2e0:	0f b6 92 e0 05 00 00 	movzbl 0x5e0(%edx),%edx
 2e7:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 2eb:	89 da                	mov    %ebx,%edx
 2ed:	85 db                	test   %ebx,%ebx
 2ef:	75 df                	jne    2d0 <printint+0x34>
 2f1:	89 c3                	mov    %eax,%ebx
  if(neg)
 2f3:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 2f7:	74 16                	je     30f <printint+0x73>
    buf[i++] = '-';
 2f9:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 2fe:	8d 5e 02             	lea    0x2(%esi),%ebx
 301:	eb 0c                	jmp    30f <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 303:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 308:	89 f8                	mov    %edi,%eax
 30a:	e8 73 ff ff ff       	call   282 <putc>
  while(--i >= 0)
 30f:	83 eb 01             	sub    $0x1,%ebx
 312:	79 ef                	jns    303 <printint+0x67>
}
 314:	83 c4 2c             	add    $0x2c,%esp
 317:	5b                   	pop    %ebx
 318:	5e                   	pop    %esi
 319:	5f                   	pop    %edi
 31a:	5d                   	pop    %ebp
 31b:	c3                   	ret    

0000031c <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 31c:	55                   	push   %ebp
 31d:	89 e5                	mov    %esp,%ebp
 31f:	57                   	push   %edi
 320:	56                   	push   %esi
 321:	53                   	push   %ebx
 322:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 325:	8d 45 10             	lea    0x10(%ebp),%eax
 328:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 32b:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 330:	bb 00 00 00 00       	mov    $0x0,%ebx
 335:	eb 14                	jmp    34b <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 337:	89 fa                	mov    %edi,%edx
 339:	8b 45 08             	mov    0x8(%ebp),%eax
 33c:	e8 41 ff ff ff       	call   282 <putc>
 341:	eb 05                	jmp    348 <printf+0x2c>
      }
    } else if(state == '%'){
 343:	83 fe 25             	cmp    $0x25,%esi
 346:	74 25                	je     36d <printf+0x51>
  for(i = 0; fmt[i]; i++){
 348:	83 c3 01             	add    $0x1,%ebx
 34b:	8b 45 0c             	mov    0xc(%ebp),%eax
 34e:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 352:	84 c0                	test   %al,%al
 354:	0f 84 23 01 00 00    	je     47d <printf+0x161>
    c = fmt[i] & 0xff;
 35a:	0f be f8             	movsbl %al,%edi
 35d:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 360:	85 f6                	test   %esi,%esi
 362:	75 df                	jne    343 <printf+0x27>
      if(c == '%'){
 364:	83 f8 25             	cmp    $0x25,%eax
 367:	75 ce                	jne    337 <printf+0x1b>
        state = '%';
 369:	89 c6                	mov    %eax,%esi
 36b:	eb db                	jmp    348 <printf+0x2c>
      if(c == 'd'){
 36d:	83 f8 64             	cmp    $0x64,%eax
 370:	74 49                	je     3bb <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 372:	83 f8 78             	cmp    $0x78,%eax
 375:	0f 94 c1             	sete   %cl
 378:	83 f8 70             	cmp    $0x70,%eax
 37b:	0f 94 c2             	sete   %dl
 37e:	08 d1                	or     %dl,%cl
 380:	75 63                	jne    3e5 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 382:	83 f8 73             	cmp    $0x73,%eax
 385:	0f 84 84 00 00 00    	je     40f <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 38b:	83 f8 63             	cmp    $0x63,%eax
 38e:	0f 84 b7 00 00 00    	je     44b <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 394:	83 f8 25             	cmp    $0x25,%eax
 397:	0f 84 cc 00 00 00    	je     469 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 39d:	ba 25 00 00 00       	mov    $0x25,%edx
 3a2:	8b 45 08             	mov    0x8(%ebp),%eax
 3a5:	e8 d8 fe ff ff       	call   282 <putc>
        putc(fd, c);
 3aa:	89 fa                	mov    %edi,%edx
 3ac:	8b 45 08             	mov    0x8(%ebp),%eax
 3af:	e8 ce fe ff ff       	call   282 <putc>
      }
      state = 0;
 3b4:	be 00 00 00 00       	mov    $0x0,%esi
 3b9:	eb 8d                	jmp    348 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 3bb:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3be:	8b 17                	mov    (%edi),%edx
 3c0:	83 ec 0c             	sub    $0xc,%esp
 3c3:	6a 01                	push   $0x1
 3c5:	b9 0a 00 00 00       	mov    $0xa,%ecx
 3ca:	8b 45 08             	mov    0x8(%ebp),%eax
 3cd:	e8 ca fe ff ff       	call   29c <printint>
        ap++;
 3d2:	83 c7 04             	add    $0x4,%edi
 3d5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 3d8:	83 c4 10             	add    $0x10,%esp
      state = 0;
 3db:	be 00 00 00 00       	mov    $0x0,%esi
 3e0:	e9 63 ff ff ff       	jmp    348 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 3e5:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 3e8:	8b 17                	mov    (%edi),%edx
 3ea:	83 ec 0c             	sub    $0xc,%esp
 3ed:	6a 00                	push   $0x0
 3ef:	b9 10 00 00 00       	mov    $0x10,%ecx
 3f4:	8b 45 08             	mov    0x8(%ebp),%eax
 3f7:	e8 a0 fe ff ff       	call   29c <printint>
        ap++;
 3fc:	83 c7 04             	add    $0x4,%edi
 3ff:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 402:	83 c4 10             	add    $0x10,%esp
      state = 0;
 405:	be 00 00 00 00       	mov    $0x0,%esi
 40a:	e9 39 ff ff ff       	jmp    348 <printf+0x2c>
        s = (char*)*ap;
 40f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 412:	8b 30                	mov    (%eax),%esi
        ap++;
 414:	83 c0 04             	add    $0x4,%eax
 417:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 41a:	85 f6                	test   %esi,%esi
 41c:	75 28                	jne    446 <printf+0x12a>
          s = "(null)";
 41e:	be d8 05 00 00       	mov    $0x5d8,%esi
 423:	8b 7d 08             	mov    0x8(%ebp),%edi
 426:	eb 0d                	jmp    435 <printf+0x119>
          putc(fd, *s);
 428:	0f be d2             	movsbl %dl,%edx
 42b:	89 f8                	mov    %edi,%eax
 42d:	e8 50 fe ff ff       	call   282 <putc>
          s++;
 432:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 435:	0f b6 16             	movzbl (%esi),%edx
 438:	84 d2                	test   %dl,%dl
 43a:	75 ec                	jne    428 <printf+0x10c>
      state = 0;
 43c:	be 00 00 00 00       	mov    $0x0,%esi
 441:	e9 02 ff ff ff       	jmp    348 <printf+0x2c>
 446:	8b 7d 08             	mov    0x8(%ebp),%edi
 449:	eb ea                	jmp    435 <printf+0x119>
        putc(fd, *ap);
 44b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 44e:	0f be 17             	movsbl (%edi),%edx
 451:	8b 45 08             	mov    0x8(%ebp),%eax
 454:	e8 29 fe ff ff       	call   282 <putc>
        ap++;
 459:	83 c7 04             	add    $0x4,%edi
 45c:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 45f:	be 00 00 00 00       	mov    $0x0,%esi
 464:	e9 df fe ff ff       	jmp    348 <printf+0x2c>
        putc(fd, c);
 469:	89 fa                	mov    %edi,%edx
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
 46e:	e8 0f fe ff ff       	call   282 <putc>
      state = 0;
 473:	be 00 00 00 00       	mov    $0x0,%esi
 478:	e9 cb fe ff ff       	jmp    348 <printf+0x2c>
    }
  }
}
 47d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 480:	5b                   	pop    %ebx
 481:	5e                   	pop    %esi
 482:	5f                   	pop    %edi
 483:	5d                   	pop    %ebp
 484:	c3                   	ret    

00000485 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 485:	55                   	push   %ebp
 486:	89 e5                	mov    %esp,%ebp
 488:	57                   	push   %edi
 489:	56                   	push   %esi
 48a:	53                   	push   %ebx
 48b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 48e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 491:	a1 78 08 00 00       	mov    0x878,%eax
 496:	eb 02                	jmp    49a <free+0x15>
 498:	89 d0                	mov    %edx,%eax
 49a:	39 c8                	cmp    %ecx,%eax
 49c:	73 04                	jae    4a2 <free+0x1d>
 49e:	39 08                	cmp    %ecx,(%eax)
 4a0:	77 12                	ja     4b4 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 4a2:	8b 10                	mov    (%eax),%edx
 4a4:	39 c2                	cmp    %eax,%edx
 4a6:	77 f0                	ja     498 <free+0x13>
 4a8:	39 c8                	cmp    %ecx,%eax
 4aa:	72 08                	jb     4b4 <free+0x2f>
 4ac:	39 ca                	cmp    %ecx,%edx
 4ae:	77 04                	ja     4b4 <free+0x2f>
 4b0:	89 d0                	mov    %edx,%eax
 4b2:	eb e6                	jmp    49a <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 4b4:	8b 73 fc             	mov    -0x4(%ebx),%esi
 4b7:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 4ba:	8b 10                	mov    (%eax),%edx
 4bc:	39 d7                	cmp    %edx,%edi
 4be:	74 19                	je     4d9 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 4c0:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 4c3:	8b 50 04             	mov    0x4(%eax),%edx
 4c6:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 4c9:	39 ce                	cmp    %ecx,%esi
 4cb:	74 1b                	je     4e8 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 4cd:	89 08                	mov    %ecx,(%eax)
  freep = p;
 4cf:	a3 78 08 00 00       	mov    %eax,0x878
}
 4d4:	5b                   	pop    %ebx
 4d5:	5e                   	pop    %esi
 4d6:	5f                   	pop    %edi
 4d7:	5d                   	pop    %ebp
 4d8:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 4d9:	03 72 04             	add    0x4(%edx),%esi
 4dc:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 4df:	8b 10                	mov    (%eax),%edx
 4e1:	8b 12                	mov    (%edx),%edx
 4e3:	89 53 f8             	mov    %edx,-0x8(%ebx)
 4e6:	eb db                	jmp    4c3 <free+0x3e>
    p->s.size += bp->s.size;
 4e8:	03 53 fc             	add    -0x4(%ebx),%edx
 4eb:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 4ee:	8b 53 f8             	mov    -0x8(%ebx),%edx
 4f1:	89 10                	mov    %edx,(%eax)
 4f3:	eb da                	jmp    4cf <free+0x4a>

000004f5 <morecore>:

static Header*
morecore(uint nu)
{
 4f5:	55                   	push   %ebp
 4f6:	89 e5                	mov    %esp,%ebp
 4f8:	53                   	push   %ebx
 4f9:	83 ec 04             	sub    $0x4,%esp
 4fc:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 4fe:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 503:	77 05                	ja     50a <morecore+0x15>
    nu = 4096;
 505:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 50a:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 511:	83 ec 0c             	sub    $0xc,%esp
 514:	50                   	push   %eax
 515:	e8 30 fd ff ff       	call   24a <sbrk>
  if(p == (char*)-1)
 51a:	83 c4 10             	add    $0x10,%esp
 51d:	83 f8 ff             	cmp    $0xffffffff,%eax
 520:	74 1c                	je     53e <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 522:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 525:	83 c0 08             	add    $0x8,%eax
 528:	83 ec 0c             	sub    $0xc,%esp
 52b:	50                   	push   %eax
 52c:	e8 54 ff ff ff       	call   485 <free>
  return freep;
 531:	a1 78 08 00 00       	mov    0x878,%eax
 536:	83 c4 10             	add    $0x10,%esp
}
 539:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 53c:	c9                   	leave  
 53d:	c3                   	ret    
    return 0;
 53e:	b8 00 00 00 00       	mov    $0x0,%eax
 543:	eb f4                	jmp    539 <morecore+0x44>

00000545 <malloc>:

void*
malloc(uint nbytes)
{
 545:	55                   	push   %ebp
 546:	89 e5                	mov    %esp,%ebp
 548:	53                   	push   %ebx
 549:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 54c:	8b 45 08             	mov    0x8(%ebp),%eax
 54f:	8d 58 07             	lea    0x7(%eax),%ebx
 552:	c1 eb 03             	shr    $0x3,%ebx
 555:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 558:	8b 0d 78 08 00 00    	mov    0x878,%ecx
 55e:	85 c9                	test   %ecx,%ecx
 560:	74 04                	je     566 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 562:	8b 01                	mov    (%ecx),%eax
 564:	eb 4d                	jmp    5b3 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 566:	c7 05 78 08 00 00 7c 	movl   $0x87c,0x878
 56d:	08 00 00 
 570:	c7 05 7c 08 00 00 7c 	movl   $0x87c,0x87c
 577:	08 00 00 
    base.s.size = 0;
 57a:	c7 05 80 08 00 00 00 	movl   $0x0,0x880
 581:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 584:	b9 7c 08 00 00       	mov    $0x87c,%ecx
 589:	eb d7                	jmp    562 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 58b:	39 da                	cmp    %ebx,%edx
 58d:	74 1a                	je     5a9 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 58f:	29 da                	sub    %ebx,%edx
 591:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 594:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 597:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 59a:	89 0d 78 08 00 00    	mov    %ecx,0x878
      return (void*)(p + 1);
 5a0:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 5a3:	83 c4 04             	add    $0x4,%esp
 5a6:	5b                   	pop    %ebx
 5a7:	5d                   	pop    %ebp
 5a8:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 5a9:	8b 10                	mov    (%eax),%edx
 5ab:	89 11                	mov    %edx,(%ecx)
 5ad:	eb eb                	jmp    59a <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5af:	89 c1                	mov    %eax,%ecx
 5b1:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 5b3:	8b 50 04             	mov    0x4(%eax),%edx
 5b6:	39 da                	cmp    %ebx,%edx
 5b8:	73 d1                	jae    58b <malloc+0x46>
    if(p == freep)
 5ba:	39 05 78 08 00 00    	cmp    %eax,0x878
 5c0:	75 ed                	jne    5af <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 5c2:	89 d8                	mov    %ebx,%eax
 5c4:	e8 2c ff ff ff       	call   4f5 <morecore>
 5c9:	85 c0                	test   %eax,%eax
 5cb:	75 e2                	jne    5af <malloc+0x6a>
        return 0;
 5cd:	b8 00 00 00 00       	mov    $0x0,%eax
 5d2:	eb cf                	jmp    5a3 <malloc+0x5e>
