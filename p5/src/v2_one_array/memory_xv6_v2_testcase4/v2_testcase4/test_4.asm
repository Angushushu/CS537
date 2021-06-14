
_test_4:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "stat.h"
#include "user.h"

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
		printf(1, "pipe() failed\n");
		exit();
	}*/

	int numframes = 10;
	int* frames = malloc(numframes * sizeof(int));
  14:	6a 28                	push   $0x28
  16:	e8 ba 05 00 00       	call   5d5 <malloc>
  1b:	89 c6                	mov    %eax,%esi
	int* pids = malloc(numframes * sizeof(int));
  1d:	c7 04 24 28 00 00 00 	movl   $0x28,(%esp)
  24:	e8 ac 05 00 00       	call   5d5 <malloc>
  29:	89 c7                	mov    %eax,%edi
	int cid = fork();
  2b:	e8 32 02 00 00       	call   262 <fork>
	if(cid == 0)
  30:	83 c4 10             	add    $0x10,%esp
  33:	85 c0                	test   %eax,%eax
  35:	75 52                	jne    89 <main+0x89>
	{//Child Process
		//fork();
		//wait();
		int flag = dump_physmem(frames, pids, numframes);
  37:	83 ec 04             	sub    $0x4,%esp
  3a:	6a 0a                	push   $0xa
  3c:	57                   	push   %edi
  3d:	56                   	push   %esi
  3e:	e8 c7 02 00 00       	call   30a <dump_physmem>
  43:	89 c3                	mov    %eax,%ebx

		if(flag == 0)
  45:	83 c4 10             	add    $0x10,%esp
  48:	85 c0                	test   %eax,%eax
  4a:	74 33                	je     7f <main+0x7f>
				//if(*(pids+i) > 0)
					printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
		}
		else// if(flag == -1)
		{
			printf(1,"error\n");
  4c:	83 ec 08             	sub    $0x8,%esp
  4f:	68 79 06 00 00       	push   $0x679
  54:	6a 01                	push   $0x1
  56:	e8 51 03 00 00       	call   3ac <printf>
  5b:	83 c4 10             	add    $0x10,%esp
  5e:	eb 24                	jmp    84 <main+0x84>
					printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  60:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  67:	ff 34 07             	pushl  (%edi,%eax,1)
  6a:	ff 34 06             	pushl  (%esi,%eax,1)
  6d:	68 64 06 00 00       	push   $0x664
  72:	6a 01                	push   $0x1
  74:	e8 33 03 00 00       	call   3ac <printf>
			for (int i = 0; i < numframes; i++)
  79:	83 c3 01             	add    $0x1,%ebx
  7c:	83 c4 10             	add    $0x10,%esp
  7f:	83 fb 09             	cmp    $0x9,%ebx
  82:	7e dc                	jle    60 <main+0x60>
		{
			printf(1,"error\n");
		}
		//write(p1[1], "Y", 1);
	}
	exit();
  84:	e8 e1 01 00 00       	call   26a <exit>
		wait();
  89:	e8 e4 01 00 00       	call   272 <wait>
		int flag2 = dump_physmem(frames, pids, numframes);
  8e:	83 ec 04             	sub    $0x4,%esp
  91:	6a 0a                	push   $0xa
  93:	57                   	push   %edi
  94:	56                   	push   %esi
  95:	e8 70 02 00 00       	call   30a <dump_physmem>
  9a:	89 c3                	mov    %eax,%ebx
		if(flag2 == 0)
  9c:	83 c4 10             	add    $0x10,%esp
  9f:	85 c0                	test   %eax,%eax
  a1:	74 33                	je     d6 <main+0xd6>
			printf(1,"error\n");
  a3:	83 ec 08             	sub    $0x8,%esp
  a6:	68 79 06 00 00       	push   $0x679
  ab:	6a 01                	push   $0x1
  ad:	e8 fa 02 00 00       	call   3ac <printf>
  b2:	83 c4 10             	add    $0x10,%esp
  b5:	eb cd                	jmp    84 <main+0x84>
					printf(1,"Frames: %x PIDs: %d\n", *(frames+i), *(pids+i));
  b7:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
  be:	ff 34 07             	pushl  (%edi,%eax,1)
  c1:	ff 34 06             	pushl  (%esi,%eax,1)
  c4:	68 64 06 00 00       	push   $0x664
  c9:	6a 01                	push   $0x1
  cb:	e8 dc 02 00 00       	call   3ac <printf>
			for (int i = 0; i < numframes; i++)
  d0:	83 c3 01             	add    $0x1,%ebx
  d3:	83 c4 10             	add    $0x10,%esp
  d6:	83 fb 09             	cmp    $0x9,%ebx
  d9:	7e dc                	jle    b7 <main+0xb7>
  db:	eb a7                	jmp    84 <main+0x84>

000000dd <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
  dd:	55                   	push   %ebp
  de:	89 e5                	mov    %esp,%ebp
  e0:	53                   	push   %ebx
  e1:	8b 45 08             	mov    0x8(%ebp),%eax
  e4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  e7:	89 c2                	mov    %eax,%edx
  e9:	0f b6 19             	movzbl (%ecx),%ebx
  ec:	88 1a                	mov    %bl,(%edx)
  ee:	8d 52 01             	lea    0x1(%edx),%edx
  f1:	8d 49 01             	lea    0x1(%ecx),%ecx
  f4:	84 db                	test   %bl,%bl
  f6:	75 f1                	jne    e9 <strcpy+0xc>
    ;
  return os;
}
  f8:	5b                   	pop    %ebx
  f9:	5d                   	pop    %ebp
  fa:	c3                   	ret    

000000fb <strcmp>:

int
strcmp(const char *p, const char *q)
{
  fb:	55                   	push   %ebp
  fc:	89 e5                	mov    %esp,%ebp
  fe:	8b 4d 08             	mov    0x8(%ebp),%ecx
 101:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 104:	eb 06                	jmp    10c <strcmp+0x11>
    p++, q++;
 106:	83 c1 01             	add    $0x1,%ecx
 109:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 10c:	0f b6 01             	movzbl (%ecx),%eax
 10f:	84 c0                	test   %al,%al
 111:	74 04                	je     117 <strcmp+0x1c>
 113:	3a 02                	cmp    (%edx),%al
 115:	74 ef                	je     106 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 117:	0f b6 c0             	movzbl %al,%eax
 11a:	0f b6 12             	movzbl (%edx),%edx
 11d:	29 d0                	sub    %edx,%eax
}
 11f:	5d                   	pop    %ebp
 120:	c3                   	ret    

00000121 <strlen>:

uint
strlen(const char *s)
{
 121:	55                   	push   %ebp
 122:	89 e5                	mov    %esp,%ebp
 124:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 127:	ba 00 00 00 00       	mov    $0x0,%edx
 12c:	eb 03                	jmp    131 <strlen+0x10>
 12e:	83 c2 01             	add    $0x1,%edx
 131:	89 d0                	mov    %edx,%eax
 133:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 137:	75 f5                	jne    12e <strlen+0xd>
    ;
  return n;
}
 139:	5d                   	pop    %ebp
 13a:	c3                   	ret    

0000013b <memset>:

void*
memset(void *dst, int c, uint n)
{
 13b:	55                   	push   %ebp
 13c:	89 e5                	mov    %esp,%ebp
 13e:	57                   	push   %edi
 13f:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 142:	89 d7                	mov    %edx,%edi
 144:	8b 4d 10             	mov    0x10(%ebp),%ecx
 147:	8b 45 0c             	mov    0xc(%ebp),%eax
 14a:	fc                   	cld    
 14b:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 14d:	89 d0                	mov    %edx,%eax
 14f:	5f                   	pop    %edi
 150:	5d                   	pop    %ebp
 151:	c3                   	ret    

00000152 <strchr>:

char*
strchr(const char *s, char c)
{
 152:	55                   	push   %ebp
 153:	89 e5                	mov    %esp,%ebp
 155:	8b 45 08             	mov    0x8(%ebp),%eax
 158:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 15c:	0f b6 10             	movzbl (%eax),%edx
 15f:	84 d2                	test   %dl,%dl
 161:	74 09                	je     16c <strchr+0x1a>
    if(*s == c)
 163:	38 ca                	cmp    %cl,%dl
 165:	74 0a                	je     171 <strchr+0x1f>
  for(; *s; s++)
 167:	83 c0 01             	add    $0x1,%eax
 16a:	eb f0                	jmp    15c <strchr+0xa>
      return (char*)s;
  return 0;
 16c:	b8 00 00 00 00       	mov    $0x0,%eax
}
 171:	5d                   	pop    %ebp
 172:	c3                   	ret    

00000173 <gets>:

char*
gets(char *buf, int max)
{
 173:	55                   	push   %ebp
 174:	89 e5                	mov    %esp,%ebp
 176:	57                   	push   %edi
 177:	56                   	push   %esi
 178:	53                   	push   %ebx
 179:	83 ec 1c             	sub    $0x1c,%esp
 17c:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 17f:	bb 00 00 00 00       	mov    $0x0,%ebx
 184:	8d 73 01             	lea    0x1(%ebx),%esi
 187:	3b 75 0c             	cmp    0xc(%ebp),%esi
 18a:	7d 2e                	jge    1ba <gets+0x47>
    cc = read(0, &c, 1);
 18c:	83 ec 04             	sub    $0x4,%esp
 18f:	6a 01                	push   $0x1
 191:	8d 45 e7             	lea    -0x19(%ebp),%eax
 194:	50                   	push   %eax
 195:	6a 00                	push   $0x0
 197:	e8 e6 00 00 00       	call   282 <read>
    if(cc < 1)
 19c:	83 c4 10             	add    $0x10,%esp
 19f:	85 c0                	test   %eax,%eax
 1a1:	7e 17                	jle    1ba <gets+0x47>
      break;
    buf[i++] = c;
 1a3:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 1a7:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 1aa:	3c 0a                	cmp    $0xa,%al
 1ac:	0f 94 c2             	sete   %dl
 1af:	3c 0d                	cmp    $0xd,%al
 1b1:	0f 94 c0             	sete   %al
    buf[i++] = c;
 1b4:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 1b6:	08 c2                	or     %al,%dl
 1b8:	74 ca                	je     184 <gets+0x11>
      break;
  }
  buf[i] = '\0';
 1ba:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 1be:	89 f8                	mov    %edi,%eax
 1c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
 1c3:	5b                   	pop    %ebx
 1c4:	5e                   	pop    %esi
 1c5:	5f                   	pop    %edi
 1c6:	5d                   	pop    %ebp
 1c7:	c3                   	ret    

000001c8 <stat>:

int
stat(const char *n, struct stat *st)
{
 1c8:	55                   	push   %ebp
 1c9:	89 e5                	mov    %esp,%ebp
 1cb:	56                   	push   %esi
 1cc:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1cd:	83 ec 08             	sub    $0x8,%esp
 1d0:	6a 00                	push   $0x0
 1d2:	ff 75 08             	pushl  0x8(%ebp)
 1d5:	e8 d0 00 00 00       	call   2aa <open>
  if(fd < 0)
 1da:	83 c4 10             	add    $0x10,%esp
 1dd:	85 c0                	test   %eax,%eax
 1df:	78 24                	js     205 <stat+0x3d>
 1e1:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 1e3:	83 ec 08             	sub    $0x8,%esp
 1e6:	ff 75 0c             	pushl  0xc(%ebp)
 1e9:	50                   	push   %eax
 1ea:	e8 d3 00 00 00       	call   2c2 <fstat>
 1ef:	89 c6                	mov    %eax,%esi
  close(fd);
 1f1:	89 1c 24             	mov    %ebx,(%esp)
 1f4:	e8 99 00 00 00       	call   292 <close>
  return r;
 1f9:	83 c4 10             	add    $0x10,%esp
}
 1fc:	89 f0                	mov    %esi,%eax
 1fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
 201:	5b                   	pop    %ebx
 202:	5e                   	pop    %esi
 203:	5d                   	pop    %ebp
 204:	c3                   	ret    
    return -1;
 205:	be ff ff ff ff       	mov    $0xffffffff,%esi
 20a:	eb f0                	jmp    1fc <stat+0x34>

0000020c <atoi>:

int
atoi(const char *s)
{
 20c:	55                   	push   %ebp
 20d:	89 e5                	mov    %esp,%ebp
 20f:	53                   	push   %ebx
 210:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 213:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 218:	eb 10                	jmp    22a <atoi+0x1e>
    n = n*10 + *s++ - '0';
 21a:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 21d:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 220:	83 c1 01             	add    $0x1,%ecx
 223:	0f be d2             	movsbl %dl,%edx
 226:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 22a:	0f b6 11             	movzbl (%ecx),%edx
 22d:	8d 5a d0             	lea    -0x30(%edx),%ebx
 230:	80 fb 09             	cmp    $0x9,%bl
 233:	76 e5                	jbe    21a <atoi+0xe>
  return n;
}
 235:	5b                   	pop    %ebx
 236:	5d                   	pop    %ebp
 237:	c3                   	ret    

00000238 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 238:	55                   	push   %ebp
 239:	89 e5                	mov    %esp,%ebp
 23b:	56                   	push   %esi
 23c:	53                   	push   %ebx
 23d:	8b 45 08             	mov    0x8(%ebp),%eax
 240:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 243:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 246:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 248:	eb 0d                	jmp    257 <memmove+0x1f>
    *dst++ = *src++;
 24a:	0f b6 13             	movzbl (%ebx),%edx
 24d:	88 11                	mov    %dl,(%ecx)
 24f:	8d 5b 01             	lea    0x1(%ebx),%ebx
 252:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 255:	89 f2                	mov    %esi,%edx
 257:	8d 72 ff             	lea    -0x1(%edx),%esi
 25a:	85 d2                	test   %edx,%edx
 25c:	7f ec                	jg     24a <memmove+0x12>
  return vdst;
}
 25e:	5b                   	pop    %ebx
 25f:	5e                   	pop    %esi
 260:	5d                   	pop    %ebp
 261:	c3                   	ret    

00000262 <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 262:	b8 01 00 00 00       	mov    $0x1,%eax
 267:	cd 40                	int    $0x40
 269:	c3                   	ret    

0000026a <exit>:
SYSCALL(exit)
 26a:	b8 02 00 00 00       	mov    $0x2,%eax
 26f:	cd 40                	int    $0x40
 271:	c3                   	ret    

00000272 <wait>:
SYSCALL(wait)
 272:	b8 03 00 00 00       	mov    $0x3,%eax
 277:	cd 40                	int    $0x40
 279:	c3                   	ret    

0000027a <pipe>:
SYSCALL(pipe)
 27a:	b8 04 00 00 00       	mov    $0x4,%eax
 27f:	cd 40                	int    $0x40
 281:	c3                   	ret    

00000282 <read>:
SYSCALL(read)
 282:	b8 05 00 00 00       	mov    $0x5,%eax
 287:	cd 40                	int    $0x40
 289:	c3                   	ret    

0000028a <write>:
SYSCALL(write)
 28a:	b8 10 00 00 00       	mov    $0x10,%eax
 28f:	cd 40                	int    $0x40
 291:	c3                   	ret    

00000292 <close>:
SYSCALL(close)
 292:	b8 15 00 00 00       	mov    $0x15,%eax
 297:	cd 40                	int    $0x40
 299:	c3                   	ret    

0000029a <kill>:
SYSCALL(kill)
 29a:	b8 06 00 00 00       	mov    $0x6,%eax
 29f:	cd 40                	int    $0x40
 2a1:	c3                   	ret    

000002a2 <exec>:
SYSCALL(exec)
 2a2:	b8 07 00 00 00       	mov    $0x7,%eax
 2a7:	cd 40                	int    $0x40
 2a9:	c3                   	ret    

000002aa <open>:
SYSCALL(open)
 2aa:	b8 0f 00 00 00       	mov    $0xf,%eax
 2af:	cd 40                	int    $0x40
 2b1:	c3                   	ret    

000002b2 <mknod>:
SYSCALL(mknod)
 2b2:	b8 11 00 00 00       	mov    $0x11,%eax
 2b7:	cd 40                	int    $0x40
 2b9:	c3                   	ret    

000002ba <unlink>:
SYSCALL(unlink)
 2ba:	b8 12 00 00 00       	mov    $0x12,%eax
 2bf:	cd 40                	int    $0x40
 2c1:	c3                   	ret    

000002c2 <fstat>:
SYSCALL(fstat)
 2c2:	b8 08 00 00 00       	mov    $0x8,%eax
 2c7:	cd 40                	int    $0x40
 2c9:	c3                   	ret    

000002ca <link>:
SYSCALL(link)
 2ca:	b8 13 00 00 00       	mov    $0x13,%eax
 2cf:	cd 40                	int    $0x40
 2d1:	c3                   	ret    

000002d2 <mkdir>:
SYSCALL(mkdir)
 2d2:	b8 14 00 00 00       	mov    $0x14,%eax
 2d7:	cd 40                	int    $0x40
 2d9:	c3                   	ret    

000002da <chdir>:
SYSCALL(chdir)
 2da:	b8 09 00 00 00       	mov    $0x9,%eax
 2df:	cd 40                	int    $0x40
 2e1:	c3                   	ret    

000002e2 <dup>:
SYSCALL(dup)
 2e2:	b8 0a 00 00 00       	mov    $0xa,%eax
 2e7:	cd 40                	int    $0x40
 2e9:	c3                   	ret    

000002ea <getpid>:
SYSCALL(getpid)
 2ea:	b8 0b 00 00 00       	mov    $0xb,%eax
 2ef:	cd 40                	int    $0x40
 2f1:	c3                   	ret    

000002f2 <sbrk>:
SYSCALL(sbrk)
 2f2:	b8 0c 00 00 00       	mov    $0xc,%eax
 2f7:	cd 40                	int    $0x40
 2f9:	c3                   	ret    

000002fa <sleep>:
SYSCALL(sleep)
 2fa:	b8 0d 00 00 00       	mov    $0xd,%eax
 2ff:	cd 40                	int    $0x40
 301:	c3                   	ret    

00000302 <uptime>:
SYSCALL(uptime)
 302:	b8 0e 00 00 00       	mov    $0xe,%eax
 307:	cd 40                	int    $0x40
 309:	c3                   	ret    

0000030a <dump_physmem>:
SYSCALL(dump_physmem)
 30a:	b8 16 00 00 00       	mov    $0x16,%eax
 30f:	cd 40                	int    $0x40
 311:	c3                   	ret    

00000312 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 312:	55                   	push   %ebp
 313:	89 e5                	mov    %esp,%ebp
 315:	83 ec 1c             	sub    $0x1c,%esp
 318:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 31b:	6a 01                	push   $0x1
 31d:	8d 55 f4             	lea    -0xc(%ebp),%edx
 320:	52                   	push   %edx
 321:	50                   	push   %eax
 322:	e8 63 ff ff ff       	call   28a <write>
}
 327:	83 c4 10             	add    $0x10,%esp
 32a:	c9                   	leave  
 32b:	c3                   	ret    

0000032c <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 32c:	55                   	push   %ebp
 32d:	89 e5                	mov    %esp,%ebp
 32f:	57                   	push   %edi
 330:	56                   	push   %esi
 331:	53                   	push   %ebx
 332:	83 ec 2c             	sub    $0x2c,%esp
 335:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 337:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 33b:	0f 95 c3             	setne  %bl
 33e:	89 d0                	mov    %edx,%eax
 340:	c1 e8 1f             	shr    $0x1f,%eax
 343:	84 c3                	test   %al,%bl
 345:	74 10                	je     357 <printint+0x2b>
    neg = 1;
    x = -xx;
 347:	f7 da                	neg    %edx
    neg = 1;
 349:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 350:	be 00 00 00 00       	mov    $0x0,%esi
 355:	eb 0b                	jmp    362 <printint+0x36>
  neg = 0;
 357:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 35e:	eb f0                	jmp    350 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 360:	89 c6                	mov    %eax,%esi
 362:	89 d0                	mov    %edx,%eax
 364:	ba 00 00 00 00       	mov    $0x0,%edx
 369:	f7 f1                	div    %ecx
 36b:	89 c3                	mov    %eax,%ebx
 36d:	8d 46 01             	lea    0x1(%esi),%eax
 370:	0f b6 92 88 06 00 00 	movzbl 0x688(%edx),%edx
 377:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 37b:	89 da                	mov    %ebx,%edx
 37d:	85 db                	test   %ebx,%ebx
 37f:	75 df                	jne    360 <printint+0x34>
 381:	89 c3                	mov    %eax,%ebx
  if(neg)
 383:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 387:	74 16                	je     39f <printint+0x73>
    buf[i++] = '-';
 389:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 38e:	8d 5e 02             	lea    0x2(%esi),%ebx
 391:	eb 0c                	jmp    39f <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 393:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 398:	89 f8                	mov    %edi,%eax
 39a:	e8 73 ff ff ff       	call   312 <putc>
  while(--i >= 0)
 39f:	83 eb 01             	sub    $0x1,%ebx
 3a2:	79 ef                	jns    393 <printint+0x67>
}
 3a4:	83 c4 2c             	add    $0x2c,%esp
 3a7:	5b                   	pop    %ebx
 3a8:	5e                   	pop    %esi
 3a9:	5f                   	pop    %edi
 3aa:	5d                   	pop    %ebp
 3ab:	c3                   	ret    

000003ac <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 3ac:	55                   	push   %ebp
 3ad:	89 e5                	mov    %esp,%ebp
 3af:	57                   	push   %edi
 3b0:	56                   	push   %esi
 3b1:	53                   	push   %ebx
 3b2:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 3b5:	8d 45 10             	lea    0x10(%ebp),%eax
 3b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 3bb:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 3c0:	bb 00 00 00 00       	mov    $0x0,%ebx
 3c5:	eb 14                	jmp    3db <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 3c7:	89 fa                	mov    %edi,%edx
 3c9:	8b 45 08             	mov    0x8(%ebp),%eax
 3cc:	e8 41 ff ff ff       	call   312 <putc>
 3d1:	eb 05                	jmp    3d8 <printf+0x2c>
      }
    } else if(state == '%'){
 3d3:	83 fe 25             	cmp    $0x25,%esi
 3d6:	74 25                	je     3fd <printf+0x51>
  for(i = 0; fmt[i]; i++){
 3d8:	83 c3 01             	add    $0x1,%ebx
 3db:	8b 45 0c             	mov    0xc(%ebp),%eax
 3de:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 3e2:	84 c0                	test   %al,%al
 3e4:	0f 84 23 01 00 00    	je     50d <printf+0x161>
    c = fmt[i] & 0xff;
 3ea:	0f be f8             	movsbl %al,%edi
 3ed:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 3f0:	85 f6                	test   %esi,%esi
 3f2:	75 df                	jne    3d3 <printf+0x27>
      if(c == '%'){
 3f4:	83 f8 25             	cmp    $0x25,%eax
 3f7:	75 ce                	jne    3c7 <printf+0x1b>
        state = '%';
 3f9:	89 c6                	mov    %eax,%esi
 3fb:	eb db                	jmp    3d8 <printf+0x2c>
      if(c == 'd'){
 3fd:	83 f8 64             	cmp    $0x64,%eax
 400:	74 49                	je     44b <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 402:	83 f8 78             	cmp    $0x78,%eax
 405:	0f 94 c1             	sete   %cl
 408:	83 f8 70             	cmp    $0x70,%eax
 40b:	0f 94 c2             	sete   %dl
 40e:	08 d1                	or     %dl,%cl
 410:	75 63                	jne    475 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 412:	83 f8 73             	cmp    $0x73,%eax
 415:	0f 84 84 00 00 00    	je     49f <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 41b:	83 f8 63             	cmp    $0x63,%eax
 41e:	0f 84 b7 00 00 00    	je     4db <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 424:	83 f8 25             	cmp    $0x25,%eax
 427:	0f 84 cc 00 00 00    	je     4f9 <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 42d:	ba 25 00 00 00       	mov    $0x25,%edx
 432:	8b 45 08             	mov    0x8(%ebp),%eax
 435:	e8 d8 fe ff ff       	call   312 <putc>
        putc(fd, c);
 43a:	89 fa                	mov    %edi,%edx
 43c:	8b 45 08             	mov    0x8(%ebp),%eax
 43f:	e8 ce fe ff ff       	call   312 <putc>
      }
      state = 0;
 444:	be 00 00 00 00       	mov    $0x0,%esi
 449:	eb 8d                	jmp    3d8 <printf+0x2c>
        printint(fd, *ap, 10, 1);
 44b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 44e:	8b 17                	mov    (%edi),%edx
 450:	83 ec 0c             	sub    $0xc,%esp
 453:	6a 01                	push   $0x1
 455:	b9 0a 00 00 00       	mov    $0xa,%ecx
 45a:	8b 45 08             	mov    0x8(%ebp),%eax
 45d:	e8 ca fe ff ff       	call   32c <printint>
        ap++;
 462:	83 c7 04             	add    $0x4,%edi
 465:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 468:	83 c4 10             	add    $0x10,%esp
      state = 0;
 46b:	be 00 00 00 00       	mov    $0x0,%esi
 470:	e9 63 ff ff ff       	jmp    3d8 <printf+0x2c>
        printint(fd, *ap, 16, 0);
 475:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 478:	8b 17                	mov    (%edi),%edx
 47a:	83 ec 0c             	sub    $0xc,%esp
 47d:	6a 00                	push   $0x0
 47f:	b9 10 00 00 00       	mov    $0x10,%ecx
 484:	8b 45 08             	mov    0x8(%ebp),%eax
 487:	e8 a0 fe ff ff       	call   32c <printint>
        ap++;
 48c:	83 c7 04             	add    $0x4,%edi
 48f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 492:	83 c4 10             	add    $0x10,%esp
      state = 0;
 495:	be 00 00 00 00       	mov    $0x0,%esi
 49a:	e9 39 ff ff ff       	jmp    3d8 <printf+0x2c>
        s = (char*)*ap;
 49f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 4a2:	8b 30                	mov    (%eax),%esi
        ap++;
 4a4:	83 c0 04             	add    $0x4,%eax
 4a7:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 4aa:	85 f6                	test   %esi,%esi
 4ac:	75 28                	jne    4d6 <printf+0x12a>
          s = "(null)";
 4ae:	be 80 06 00 00       	mov    $0x680,%esi
 4b3:	8b 7d 08             	mov    0x8(%ebp),%edi
 4b6:	eb 0d                	jmp    4c5 <printf+0x119>
          putc(fd, *s);
 4b8:	0f be d2             	movsbl %dl,%edx
 4bb:	89 f8                	mov    %edi,%eax
 4bd:	e8 50 fe ff ff       	call   312 <putc>
          s++;
 4c2:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 4c5:	0f b6 16             	movzbl (%esi),%edx
 4c8:	84 d2                	test   %dl,%dl
 4ca:	75 ec                	jne    4b8 <printf+0x10c>
      state = 0;
 4cc:	be 00 00 00 00       	mov    $0x0,%esi
 4d1:	e9 02 ff ff ff       	jmp    3d8 <printf+0x2c>
 4d6:	8b 7d 08             	mov    0x8(%ebp),%edi
 4d9:	eb ea                	jmp    4c5 <printf+0x119>
        putc(fd, *ap);
 4db:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4de:	0f be 17             	movsbl (%edi),%edx
 4e1:	8b 45 08             	mov    0x8(%ebp),%eax
 4e4:	e8 29 fe ff ff       	call   312 <putc>
        ap++;
 4e9:	83 c7 04             	add    $0x4,%edi
 4ec:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 4ef:	be 00 00 00 00       	mov    $0x0,%esi
 4f4:	e9 df fe ff ff       	jmp    3d8 <printf+0x2c>
        putc(fd, c);
 4f9:	89 fa                	mov    %edi,%edx
 4fb:	8b 45 08             	mov    0x8(%ebp),%eax
 4fe:	e8 0f fe ff ff       	call   312 <putc>
      state = 0;
 503:	be 00 00 00 00       	mov    $0x0,%esi
 508:	e9 cb fe ff ff       	jmp    3d8 <printf+0x2c>
    }
  }
}
 50d:	8d 65 f4             	lea    -0xc(%ebp),%esp
 510:	5b                   	pop    %ebx
 511:	5e                   	pop    %esi
 512:	5f                   	pop    %edi
 513:	5d                   	pop    %ebp
 514:	c3                   	ret    

00000515 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 515:	55                   	push   %ebp
 516:	89 e5                	mov    %esp,%ebp
 518:	57                   	push   %edi
 519:	56                   	push   %esi
 51a:	53                   	push   %ebx
 51b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 51e:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 521:	a1 2c 09 00 00       	mov    0x92c,%eax
 526:	eb 02                	jmp    52a <free+0x15>
 528:	89 d0                	mov    %edx,%eax
 52a:	39 c8                	cmp    %ecx,%eax
 52c:	73 04                	jae    532 <free+0x1d>
 52e:	39 08                	cmp    %ecx,(%eax)
 530:	77 12                	ja     544 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 532:	8b 10                	mov    (%eax),%edx
 534:	39 c2                	cmp    %eax,%edx
 536:	77 f0                	ja     528 <free+0x13>
 538:	39 c8                	cmp    %ecx,%eax
 53a:	72 08                	jb     544 <free+0x2f>
 53c:	39 ca                	cmp    %ecx,%edx
 53e:	77 04                	ja     544 <free+0x2f>
 540:	89 d0                	mov    %edx,%eax
 542:	eb e6                	jmp    52a <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 544:	8b 73 fc             	mov    -0x4(%ebx),%esi
 547:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 54a:	8b 10                	mov    (%eax),%edx
 54c:	39 d7                	cmp    %edx,%edi
 54e:	74 19                	je     569 <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 550:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 553:	8b 50 04             	mov    0x4(%eax),%edx
 556:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 559:	39 ce                	cmp    %ecx,%esi
 55b:	74 1b                	je     578 <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 55d:	89 08                	mov    %ecx,(%eax)
  freep = p;
 55f:	a3 2c 09 00 00       	mov    %eax,0x92c
}
 564:	5b                   	pop    %ebx
 565:	5e                   	pop    %esi
 566:	5f                   	pop    %edi
 567:	5d                   	pop    %ebp
 568:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 569:	03 72 04             	add    0x4(%edx),%esi
 56c:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 56f:	8b 10                	mov    (%eax),%edx
 571:	8b 12                	mov    (%edx),%edx
 573:	89 53 f8             	mov    %edx,-0x8(%ebx)
 576:	eb db                	jmp    553 <free+0x3e>
    p->s.size += bp->s.size;
 578:	03 53 fc             	add    -0x4(%ebx),%edx
 57b:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 57e:	8b 53 f8             	mov    -0x8(%ebx),%edx
 581:	89 10                	mov    %edx,(%eax)
 583:	eb da                	jmp    55f <free+0x4a>

00000585 <morecore>:

static Header*
morecore(uint nu)
{
 585:	55                   	push   %ebp
 586:	89 e5                	mov    %esp,%ebp
 588:	53                   	push   %ebx
 589:	83 ec 04             	sub    $0x4,%esp
 58c:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 58e:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 593:	77 05                	ja     59a <morecore+0x15>
    nu = 4096;
 595:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 59a:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 5a1:	83 ec 0c             	sub    $0xc,%esp
 5a4:	50                   	push   %eax
 5a5:	e8 48 fd ff ff       	call   2f2 <sbrk>
  if(p == (char*)-1)
 5aa:	83 c4 10             	add    $0x10,%esp
 5ad:	83 f8 ff             	cmp    $0xffffffff,%eax
 5b0:	74 1c                	je     5ce <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 5b2:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 5b5:	83 c0 08             	add    $0x8,%eax
 5b8:	83 ec 0c             	sub    $0xc,%esp
 5bb:	50                   	push   %eax
 5bc:	e8 54 ff ff ff       	call   515 <free>
  return freep;
 5c1:	a1 2c 09 00 00       	mov    0x92c,%eax
 5c6:	83 c4 10             	add    $0x10,%esp
}
 5c9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 5cc:	c9                   	leave  
 5cd:	c3                   	ret    
    return 0;
 5ce:	b8 00 00 00 00       	mov    $0x0,%eax
 5d3:	eb f4                	jmp    5c9 <morecore+0x44>

000005d5 <malloc>:

void*
malloc(uint nbytes)
{
 5d5:	55                   	push   %ebp
 5d6:	89 e5                	mov    %esp,%ebp
 5d8:	53                   	push   %ebx
 5d9:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 5dc:	8b 45 08             	mov    0x8(%ebp),%eax
 5df:	8d 58 07             	lea    0x7(%eax),%ebx
 5e2:	c1 eb 03             	shr    $0x3,%ebx
 5e5:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 5e8:	8b 0d 2c 09 00 00    	mov    0x92c,%ecx
 5ee:	85 c9                	test   %ecx,%ecx
 5f0:	74 04                	je     5f6 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 5f2:	8b 01                	mov    (%ecx),%eax
 5f4:	eb 4d                	jmp    643 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 5f6:	c7 05 2c 09 00 00 30 	movl   $0x930,0x92c
 5fd:	09 00 00 
 600:	c7 05 30 09 00 00 30 	movl   $0x930,0x930
 607:	09 00 00 
    base.s.size = 0;
 60a:	c7 05 34 09 00 00 00 	movl   $0x0,0x934
 611:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 614:	b9 30 09 00 00       	mov    $0x930,%ecx
 619:	eb d7                	jmp    5f2 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 61b:	39 da                	cmp    %ebx,%edx
 61d:	74 1a                	je     639 <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 61f:	29 da                	sub    %ebx,%edx
 621:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 624:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 627:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 62a:	89 0d 2c 09 00 00    	mov    %ecx,0x92c
      return (void*)(p + 1);
 630:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 633:	83 c4 04             	add    $0x4,%esp
 636:	5b                   	pop    %ebx
 637:	5d                   	pop    %ebp
 638:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 639:	8b 10                	mov    (%eax),%edx
 63b:	89 11                	mov    %edx,(%ecx)
 63d:	eb eb                	jmp    62a <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 63f:	89 c1                	mov    %eax,%ecx
 641:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 643:	8b 50 04             	mov    0x4(%eax),%edx
 646:	39 da                	cmp    %ebx,%edx
 648:	73 d1                	jae    61b <malloc+0x46>
    if(p == freep)
 64a:	39 05 2c 09 00 00    	cmp    %eax,0x92c
 650:	75 ed                	jne    63f <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 652:	89 d8                	mov    %ebx,%eax
 654:	e8 2c ff ff ff       	call   585 <morecore>
 659:	85 c0                	test   %eax,%eax
 65b:	75 e2                	jne    63f <malloc+0x6a>
        return 0;
 65d:	b8 00 00 00 00       	mov    $0x0,%eax
 662:	eb cf                	jmp    633 <malloc+0x5e>
