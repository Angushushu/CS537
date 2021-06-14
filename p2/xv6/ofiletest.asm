
_ofiletest:     file format elf32-i386


Disassembly of section .text:

00000000 <main>:
#include "types.h" 
#include "stat.h"
#include "user.h"
#include "fcntl.h"

int main(int argc, char** argv){
   0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
   4:	83 e4 f0             	and    $0xfffffff0,%esp
   7:	ff 71 fc             	pushl  -0x4(%ecx)
   a:	55                   	push   %ebp
   b:	89 e5                	mov    %esp,%ebp
   d:	57                   	push   %edi
   e:	56                   	push   %esi
   f:	53                   	push   %ebx
  10:	51                   	push   %ecx
  11:	83 ec 18             	sub    $0x18,%esp
  14:	8b 31                	mov    (%ecx),%esi
  16:	8b 79 04             	mov    0x4(%ecx),%edi
  if(argc < 2){
  19:	83 fe 01             	cmp    $0x1,%esi
  1c:	7e 24                	jle    42 <main+0x42>
    exit();
  }
  int nopen = atoi(argv[1]);
  1e:	83 ec 0c             	sub    $0xc,%esp
  21:	ff 77 04             	pushl  0x4(%edi)
  24:	e8 7d 02 00 00       	call   2a6 <atoi>
  29:	89 c2                	mov    %eax,%edx
  2b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(argc > nopen+1 || nopen > 16){
  2e:	8d 40 01             	lea    0x1(%eax),%eax
  31:	83 c4 10             	add    $0x10,%esp
  34:	39 f0                	cmp    %esi,%eax
  36:	7c 05                	jl     3d <main+0x3d>
  38:	83 fa 10             	cmp    $0x10,%edx
  3b:	7e 0f                	jle    4c <main+0x4c>
    exit();
  3d:	e8 c2 02 00 00       	call   304 <exit>
    exit();
  42:	e8 bd 02 00 00       	call   304 <exit>
  }
  for(int i = 2; i < argc; i++){
    if(atoi(argv[i]) >= nopen){
      exit();
  47:	e8 b8 02 00 00       	call   304 <exit>
  for(int i = 2; i < argc; i++){
  4c:	bb 02 00 00 00       	mov    $0x2,%ebx
  51:	39 f3                	cmp    %esi,%ebx
  53:	7d 18                	jge    6d <main+0x6d>
    if(atoi(argv[i]) >= nopen){
  55:	83 ec 0c             	sub    $0xc,%esp
  58:	ff 34 9f             	pushl  (%edi,%ebx,4)
  5b:	e8 46 02 00 00       	call   2a6 <atoi>
  60:	83 c4 10             	add    $0x10,%esp
  63:	3b 45 e4             	cmp    -0x1c(%ebp),%eax
  66:	7d df                	jge    47 <main+0x47>
  for(int i = 2; i < argc; i++){
  68:	83 c3 01             	add    $0x1,%ebx
  6b:	eb e4                	jmp    51 <main+0x51>
    }
  }

  int* files = malloc(nopen*sizeof(int));
  6d:	8b 45 e4             	mov    -0x1c(%ebp),%eax
  70:	c1 e0 02             	shl    $0x2,%eax
  73:	83 ec 0c             	sub    $0xc,%esp
  76:	50                   	push   %eax
  77:	e8 fb 05 00 00       	call   677 <malloc>
  7c:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(int i = 0; i < nopen; i++){
  7f:	83 c4 10             	add    $0x10,%esp
  82:	b8 00 00 00 00       	mov    $0x0,%eax
  87:	89 75 dc             	mov    %esi,-0x24(%ebp)
  8a:	89 c6                	mov    %eax,%esi
  8c:	89 7d d8             	mov    %edi,-0x28(%ebp)
  8f:	eb 48                	jmp    d9 <main+0xd9>
    char* fname;
    if(i < 10){
      fname = malloc(5*sizeof(char));
  91:	83 ec 0c             	sub    $0xc,%esp
  94:	6a 05                	push   $0x5
  96:	e8 dc 05 00 00       	call   677 <malloc>
  9b:	89 c3                	mov    %eax,%ebx
      fname[4] = '0'+i;
  9d:	8d 46 30             	lea    0x30(%esi),%eax
  a0:	88 43 04             	mov    %al,0x4(%ebx)
  a3:	83 c4 10             	add    $0x10,%esp
    }else{
      fname = malloc(6*sizeof(char));
      fname[5] = '0'+i%10;
      fname[4] = '0'+i/10;
    }
    fname[0]='f';fname[1]='i';fname[2]='l';fname[3]='e';
  a6:	c6 03 66             	movb   $0x66,(%ebx)
  a9:	c6 43 01 69          	movb   $0x69,0x1(%ebx)
  ad:	c6 43 02 6c          	movb   $0x6c,0x2(%ebx)
  b1:	c6 43 03 65          	movb   $0x65,0x3(%ebx)
    files[i] = open(fname, O_CREATE|O_RDONLY);
  b5:	8b 45 e0             	mov    -0x20(%ebp),%eax
  b8:	8d 3c b0             	lea    (%eax,%esi,4),%edi
  bb:	83 ec 08             	sub    $0x8,%esp
  be:	68 00 02 00 00       	push   $0x200
  c3:	53                   	push   %ebx
  c4:	e8 7b 02 00 00       	call   344 <open>
  c9:	89 07                	mov    %eax,(%edi)
    free(fname);
  cb:	89 1c 24             	mov    %ebx,(%esp)
  ce:	e8 e4 04 00 00       	call   5b7 <free>
  for(int i = 0; i < nopen; i++){
  d3:	83 c6 01             	add    $0x1,%esi
  d6:	83 c4 10             	add    $0x10,%esp
  d9:	3b 75 e4             	cmp    -0x1c(%ebp),%esi
  dc:	7d 2c                	jge    10a <main+0x10a>
    if(i < 10){
  de:	83 fe 09             	cmp    $0x9,%esi
  e1:	7e ae                	jle    91 <main+0x91>
      fname = malloc(6*sizeof(char));
  e3:	83 ec 0c             	sub    $0xc,%esp
  e6:	6a 06                	push   $0x6
  e8:	e8 8a 05 00 00       	call   677 <malloc>
  ed:	89 c3                	mov    %eax,%ebx
      fname[5] = '0'+i%10;
  ef:	b9 0a 00 00 00       	mov    $0xa,%ecx
  f4:	89 f0                	mov    %esi,%eax
  f6:	99                   	cltd   
  f7:	f7 f9                	idiv   %ecx
  f9:	83 c2 30             	add    $0x30,%edx
  fc:	88 53 05             	mov    %dl,0x5(%ebx)
      fname[4] = '0'+i/10;
  ff:	83 c0 30             	add    $0x30,%eax
 102:	88 43 04             	mov    %al,0x4(%ebx)
 105:	83 c4 10             	add    $0x10,%esp
 108:	eb 9c                	jmp    a6 <main+0xa6>
 10a:	8b 75 dc             	mov    -0x24(%ebp),%esi
 10d:	8b 7d d8             	mov    -0x28(%ebp),%edi
  }

  for(int i = 2; i < argc; i++){
 110:	bb 02 00 00 00       	mov    $0x2,%ebx
 115:	eb 1f                	jmp    136 <main+0x136>
    close(files[atoi(argv[i])]);
 117:	83 ec 0c             	sub    $0xc,%esp
 11a:	ff 34 9f             	pushl  (%edi,%ebx,4)
 11d:	e8 84 01 00 00       	call   2a6 <atoi>
 122:	83 c4 04             	add    $0x4,%esp
 125:	8b 4d e0             	mov    -0x20(%ebp),%ecx
 128:	ff 34 81             	pushl  (%ecx,%eax,4)
 12b:	e8 fc 01 00 00       	call   32c <close>
  for(int i = 2; i < argc; i++){
 130:	83 c3 01             	add    $0x1,%ebx
 133:	83 c4 10             	add    $0x10,%esp
 136:	39 f3                	cmp    %esi,%ebx
 138:	7c dd                	jl     117 <main+0x117>
  }

  free(files);
 13a:	83 ec 0c             	sub    $0xc,%esp
 13d:	ff 75 e0             	pushl  -0x20(%ebp)
 140:	e8 72 04 00 00       	call   5b7 <free>
  int nf = getofilecnt(getpid());
 145:	e8 3a 02 00 00       	call   384 <getpid>
 14a:	89 04 24             	mov    %eax,(%esp)
 14d:	e8 52 02 00 00       	call   3a4 <getofilecnt>
 152:	89 c3                	mov    %eax,%ebx
  int next = getofilenext(getpid());
 154:	e8 2b 02 00 00       	call   384 <getpid>
 159:	89 04 24             	mov    %eax,(%esp)
 15c:	e8 4b 02 00 00       	call   3ac <getofilenext>
  printf(1, "%d %d\n", nf, next);
 161:	50                   	push   %eax
 162:	53                   	push   %ebx
 163:	68 08 07 00 00       	push   $0x708
 168:	6a 01                	push   $0x1
 16a:	e8 df 02 00 00       	call   44e <printf>
  exit();
 16f:	83 c4 20             	add    $0x20,%esp
 172:	e8 8d 01 00 00       	call   304 <exit>

00000177 <strcpy>:
#include "user.h"
#include "x86.h"

char*
strcpy(char *s, const char *t)
{
 177:	55                   	push   %ebp
 178:	89 e5                	mov    %esp,%ebp
 17a:	53                   	push   %ebx
 17b:	8b 45 08             	mov    0x8(%ebp),%eax
 17e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 181:	89 c2                	mov    %eax,%edx
 183:	0f b6 19             	movzbl (%ecx),%ebx
 186:	88 1a                	mov    %bl,(%edx)
 188:	8d 52 01             	lea    0x1(%edx),%edx
 18b:	8d 49 01             	lea    0x1(%ecx),%ecx
 18e:	84 db                	test   %bl,%bl
 190:	75 f1                	jne    183 <strcpy+0xc>
    ;
  return os;
}
 192:	5b                   	pop    %ebx
 193:	5d                   	pop    %ebp
 194:	c3                   	ret    

00000195 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 195:	55                   	push   %ebp
 196:	89 e5                	mov    %esp,%ebp
 198:	8b 4d 08             	mov    0x8(%ebp),%ecx
 19b:	8b 55 0c             	mov    0xc(%ebp),%edx
  while(*p && *p == *q)
 19e:	eb 06                	jmp    1a6 <strcmp+0x11>
    p++, q++;
 1a0:	83 c1 01             	add    $0x1,%ecx
 1a3:	83 c2 01             	add    $0x1,%edx
  while(*p && *p == *q)
 1a6:	0f b6 01             	movzbl (%ecx),%eax
 1a9:	84 c0                	test   %al,%al
 1ab:	74 04                	je     1b1 <strcmp+0x1c>
 1ad:	3a 02                	cmp    (%edx),%al
 1af:	74 ef                	je     1a0 <strcmp+0xb>
  return (uchar)*p - (uchar)*q;
 1b1:	0f b6 c0             	movzbl %al,%eax
 1b4:	0f b6 12             	movzbl (%edx),%edx
 1b7:	29 d0                	sub    %edx,%eax
}
 1b9:	5d                   	pop    %ebp
 1ba:	c3                   	ret    

000001bb <strlen>:

uint
strlen(const char *s)
{
 1bb:	55                   	push   %ebp
 1bc:	89 e5                	mov    %esp,%ebp
 1be:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  for(n = 0; s[n]; n++)
 1c1:	ba 00 00 00 00       	mov    $0x0,%edx
 1c6:	eb 03                	jmp    1cb <strlen+0x10>
 1c8:	83 c2 01             	add    $0x1,%edx
 1cb:	89 d0                	mov    %edx,%eax
 1cd:	80 3c 11 00          	cmpb   $0x0,(%ecx,%edx,1)
 1d1:	75 f5                	jne    1c8 <strlen+0xd>
    ;
  return n;
}
 1d3:	5d                   	pop    %ebp
 1d4:	c3                   	ret    

000001d5 <memset>:

void*
memset(void *dst, int c, uint n)
{
 1d5:	55                   	push   %ebp
 1d6:	89 e5                	mov    %esp,%ebp
 1d8:	57                   	push   %edi
 1d9:	8b 55 08             	mov    0x8(%ebp),%edx
}

static inline void
stosb(void *addr, int data, int cnt)
{
  asm volatile("cld; rep stosb" :
 1dc:	89 d7                	mov    %edx,%edi
 1de:	8b 4d 10             	mov    0x10(%ebp),%ecx
 1e1:	8b 45 0c             	mov    0xc(%ebp),%eax
 1e4:	fc                   	cld    
 1e5:	f3 aa                	rep stos %al,%es:(%edi)
  stosb(dst, c, n);
  return dst;
}
 1e7:	89 d0                	mov    %edx,%eax
 1e9:	5f                   	pop    %edi
 1ea:	5d                   	pop    %ebp
 1eb:	c3                   	ret    

000001ec <strchr>:

char*
strchr(const char *s, char c)
{
 1ec:	55                   	push   %ebp
 1ed:	89 e5                	mov    %esp,%ebp
 1ef:	8b 45 08             	mov    0x8(%ebp),%eax
 1f2:	0f b6 4d 0c          	movzbl 0xc(%ebp),%ecx
  for(; *s; s++)
 1f6:	0f b6 10             	movzbl (%eax),%edx
 1f9:	84 d2                	test   %dl,%dl
 1fb:	74 09                	je     206 <strchr+0x1a>
    if(*s == c)
 1fd:	38 ca                	cmp    %cl,%dl
 1ff:	74 0a                	je     20b <strchr+0x1f>
  for(; *s; s++)
 201:	83 c0 01             	add    $0x1,%eax
 204:	eb f0                	jmp    1f6 <strchr+0xa>
      return (char*)s;
  return 0;
 206:	b8 00 00 00 00       	mov    $0x0,%eax
}
 20b:	5d                   	pop    %ebp
 20c:	c3                   	ret    

0000020d <gets>:

char*
gets(char *buf, int max)
{
 20d:	55                   	push   %ebp
 20e:	89 e5                	mov    %esp,%ebp
 210:	57                   	push   %edi
 211:	56                   	push   %esi
 212:	53                   	push   %ebx
 213:	83 ec 1c             	sub    $0x1c,%esp
 216:	8b 7d 08             	mov    0x8(%ebp),%edi
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 219:	bb 00 00 00 00       	mov    $0x0,%ebx
 21e:	8d 73 01             	lea    0x1(%ebx),%esi
 221:	3b 75 0c             	cmp    0xc(%ebp),%esi
 224:	7d 2e                	jge    254 <gets+0x47>
    cc = read(0, &c, 1);
 226:	83 ec 04             	sub    $0x4,%esp
 229:	6a 01                	push   $0x1
 22b:	8d 45 e7             	lea    -0x19(%ebp),%eax
 22e:	50                   	push   %eax
 22f:	6a 00                	push   $0x0
 231:	e8 e6 00 00 00       	call   31c <read>
    if(cc < 1)
 236:	83 c4 10             	add    $0x10,%esp
 239:	85 c0                	test   %eax,%eax
 23b:	7e 17                	jle    254 <gets+0x47>
      break;
    buf[i++] = c;
 23d:	0f b6 45 e7          	movzbl -0x19(%ebp),%eax
 241:	88 04 1f             	mov    %al,(%edi,%ebx,1)
    if(c == '\n' || c == '\r')
 244:	3c 0a                	cmp    $0xa,%al
 246:	0f 94 c2             	sete   %dl
 249:	3c 0d                	cmp    $0xd,%al
 24b:	0f 94 c0             	sete   %al
    buf[i++] = c;
 24e:	89 f3                	mov    %esi,%ebx
    if(c == '\n' || c == '\r')
 250:	08 c2                	or     %al,%dl
 252:	74 ca                	je     21e <gets+0x11>
      break;
  }
  buf[i] = '\0';
 254:	c6 04 1f 00          	movb   $0x0,(%edi,%ebx,1)
  return buf;
}
 258:	89 f8                	mov    %edi,%eax
 25a:	8d 65 f4             	lea    -0xc(%ebp),%esp
 25d:	5b                   	pop    %ebx
 25e:	5e                   	pop    %esi
 25f:	5f                   	pop    %edi
 260:	5d                   	pop    %ebp
 261:	c3                   	ret    

00000262 <stat>:

int
stat(const char *n, struct stat *st)
{
 262:	55                   	push   %ebp
 263:	89 e5                	mov    %esp,%ebp
 265:	56                   	push   %esi
 266:	53                   	push   %ebx
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 267:	83 ec 08             	sub    $0x8,%esp
 26a:	6a 00                	push   $0x0
 26c:	ff 75 08             	pushl  0x8(%ebp)
 26f:	e8 d0 00 00 00       	call   344 <open>
  if(fd < 0)
 274:	83 c4 10             	add    $0x10,%esp
 277:	85 c0                	test   %eax,%eax
 279:	78 24                	js     29f <stat+0x3d>
 27b:	89 c3                	mov    %eax,%ebx
    return -1;
  r = fstat(fd, st);
 27d:	83 ec 08             	sub    $0x8,%esp
 280:	ff 75 0c             	pushl  0xc(%ebp)
 283:	50                   	push   %eax
 284:	e8 d3 00 00 00       	call   35c <fstat>
 289:	89 c6                	mov    %eax,%esi
  close(fd);
 28b:	89 1c 24             	mov    %ebx,(%esp)
 28e:	e8 99 00 00 00       	call   32c <close>
  return r;
 293:	83 c4 10             	add    $0x10,%esp
}
 296:	89 f0                	mov    %esi,%eax
 298:	8d 65 f8             	lea    -0x8(%ebp),%esp
 29b:	5b                   	pop    %ebx
 29c:	5e                   	pop    %esi
 29d:	5d                   	pop    %ebp
 29e:	c3                   	ret    
    return -1;
 29f:	be ff ff ff ff       	mov    $0xffffffff,%esi
 2a4:	eb f0                	jmp    296 <stat+0x34>

000002a6 <atoi>:

int
atoi(const char *s)
{
 2a6:	55                   	push   %ebp
 2a7:	89 e5                	mov    %esp,%ebp
 2a9:	53                   	push   %ebx
 2aa:	8b 4d 08             	mov    0x8(%ebp),%ecx
  int n;

  n = 0;
 2ad:	b8 00 00 00 00       	mov    $0x0,%eax
  while('0' <= *s && *s <= '9')
 2b2:	eb 10                	jmp    2c4 <atoi+0x1e>
    n = n*10 + *s++ - '0';
 2b4:	8d 1c 80             	lea    (%eax,%eax,4),%ebx
 2b7:	8d 04 1b             	lea    (%ebx,%ebx,1),%eax
 2ba:	83 c1 01             	add    $0x1,%ecx
 2bd:	0f be d2             	movsbl %dl,%edx
 2c0:	8d 44 02 d0          	lea    -0x30(%edx,%eax,1),%eax
  while('0' <= *s && *s <= '9')
 2c4:	0f b6 11             	movzbl (%ecx),%edx
 2c7:	8d 5a d0             	lea    -0x30(%edx),%ebx
 2ca:	80 fb 09             	cmp    $0x9,%bl
 2cd:	76 e5                	jbe    2b4 <atoi+0xe>
  return n;
}
 2cf:	5b                   	pop    %ebx
 2d0:	5d                   	pop    %ebp
 2d1:	c3                   	ret    

000002d2 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 2d2:	55                   	push   %ebp
 2d3:	89 e5                	mov    %esp,%ebp
 2d5:	56                   	push   %esi
 2d6:	53                   	push   %ebx
 2d7:	8b 45 08             	mov    0x8(%ebp),%eax
 2da:	8b 5d 0c             	mov    0xc(%ebp),%ebx
 2dd:	8b 55 10             	mov    0x10(%ebp),%edx
  char *dst;
  const char *src;

  dst = vdst;
 2e0:	89 c1                	mov    %eax,%ecx
  src = vsrc;
  while(n-- > 0)
 2e2:	eb 0d                	jmp    2f1 <memmove+0x1f>
    *dst++ = *src++;
 2e4:	0f b6 13             	movzbl (%ebx),%edx
 2e7:	88 11                	mov    %dl,(%ecx)
 2e9:	8d 5b 01             	lea    0x1(%ebx),%ebx
 2ec:	8d 49 01             	lea    0x1(%ecx),%ecx
  while(n-- > 0)
 2ef:	89 f2                	mov    %esi,%edx
 2f1:	8d 72 ff             	lea    -0x1(%edx),%esi
 2f4:	85 d2                	test   %edx,%edx
 2f6:	7f ec                	jg     2e4 <memmove+0x12>
  return vdst;
}
 2f8:	5b                   	pop    %ebx
 2f9:	5e                   	pop    %esi
 2fa:	5d                   	pop    %ebp
 2fb:	c3                   	ret    

000002fc <fork>:
  name: \
    movl $SYS_ ## name, %eax; \
    int $T_SYSCALL; \
    ret

SYSCALL(fork)
 2fc:	b8 01 00 00 00       	mov    $0x1,%eax
 301:	cd 40                	int    $0x40
 303:	c3                   	ret    

00000304 <exit>:
SYSCALL(exit)
 304:	b8 02 00 00 00       	mov    $0x2,%eax
 309:	cd 40                	int    $0x40
 30b:	c3                   	ret    

0000030c <wait>:
SYSCALL(wait)
 30c:	b8 03 00 00 00       	mov    $0x3,%eax
 311:	cd 40                	int    $0x40
 313:	c3                   	ret    

00000314 <pipe>:
SYSCALL(pipe)
 314:	b8 04 00 00 00       	mov    $0x4,%eax
 319:	cd 40                	int    $0x40
 31b:	c3                   	ret    

0000031c <read>:
SYSCALL(read)
 31c:	b8 05 00 00 00       	mov    $0x5,%eax
 321:	cd 40                	int    $0x40
 323:	c3                   	ret    

00000324 <write>:
SYSCALL(write)
 324:	b8 10 00 00 00       	mov    $0x10,%eax
 329:	cd 40                	int    $0x40
 32b:	c3                   	ret    

0000032c <close>:
SYSCALL(close)
 32c:	b8 15 00 00 00       	mov    $0x15,%eax
 331:	cd 40                	int    $0x40
 333:	c3                   	ret    

00000334 <kill>:
SYSCALL(kill)
 334:	b8 06 00 00 00       	mov    $0x6,%eax
 339:	cd 40                	int    $0x40
 33b:	c3                   	ret    

0000033c <exec>:
SYSCALL(exec)
 33c:	b8 07 00 00 00       	mov    $0x7,%eax
 341:	cd 40                	int    $0x40
 343:	c3                   	ret    

00000344 <open>:
SYSCALL(open)
 344:	b8 0f 00 00 00       	mov    $0xf,%eax
 349:	cd 40                	int    $0x40
 34b:	c3                   	ret    

0000034c <mknod>:
SYSCALL(mknod)
 34c:	b8 11 00 00 00       	mov    $0x11,%eax
 351:	cd 40                	int    $0x40
 353:	c3                   	ret    

00000354 <unlink>:
SYSCALL(unlink)
 354:	b8 12 00 00 00       	mov    $0x12,%eax
 359:	cd 40                	int    $0x40
 35b:	c3                   	ret    

0000035c <fstat>:
SYSCALL(fstat)
 35c:	b8 08 00 00 00       	mov    $0x8,%eax
 361:	cd 40                	int    $0x40
 363:	c3                   	ret    

00000364 <link>:
SYSCALL(link)
 364:	b8 13 00 00 00       	mov    $0x13,%eax
 369:	cd 40                	int    $0x40
 36b:	c3                   	ret    

0000036c <mkdir>:
SYSCALL(mkdir)
 36c:	b8 14 00 00 00       	mov    $0x14,%eax
 371:	cd 40                	int    $0x40
 373:	c3                   	ret    

00000374 <chdir>:
SYSCALL(chdir)
 374:	b8 09 00 00 00       	mov    $0x9,%eax
 379:	cd 40                	int    $0x40
 37b:	c3                   	ret    

0000037c <dup>:
SYSCALL(dup)
 37c:	b8 0a 00 00 00       	mov    $0xa,%eax
 381:	cd 40                	int    $0x40
 383:	c3                   	ret    

00000384 <getpid>:
SYSCALL(getpid)
 384:	b8 0b 00 00 00       	mov    $0xb,%eax
 389:	cd 40                	int    $0x40
 38b:	c3                   	ret    

0000038c <sbrk>:
SYSCALL(sbrk)
 38c:	b8 0c 00 00 00       	mov    $0xc,%eax
 391:	cd 40                	int    $0x40
 393:	c3                   	ret    

00000394 <sleep>:
SYSCALL(sleep)
 394:	b8 0d 00 00 00       	mov    $0xd,%eax
 399:	cd 40                	int    $0x40
 39b:	c3                   	ret    

0000039c <uptime>:
SYSCALL(uptime)
 39c:	b8 0e 00 00 00       	mov    $0xe,%eax
 3a1:	cd 40                	int    $0x40
 3a3:	c3                   	ret    

000003a4 <getofilecnt>:
SYSCALL(getofilecnt)#
 3a4:	b8 16 00 00 00       	mov    $0x16,%eax
 3a9:	cd 40                	int    $0x40
 3ab:	c3                   	ret    

000003ac <getofilenext>:
SYSCALL(getofilenext)#
 3ac:	b8 17 00 00 00       	mov    $0x17,%eax
 3b1:	cd 40                	int    $0x40
 3b3:	c3                   	ret    

000003b4 <putc>:
#include "stat.h"
#include "user.h"

static void
putc(int fd, char c)
{
 3b4:	55                   	push   %ebp
 3b5:	89 e5                	mov    %esp,%ebp
 3b7:	83 ec 1c             	sub    $0x1c,%esp
 3ba:	88 55 f4             	mov    %dl,-0xc(%ebp)
  write(fd, &c, 1);
 3bd:	6a 01                	push   $0x1
 3bf:	8d 55 f4             	lea    -0xc(%ebp),%edx
 3c2:	52                   	push   %edx
 3c3:	50                   	push   %eax
 3c4:	e8 5b ff ff ff       	call   324 <write>
}
 3c9:	83 c4 10             	add    $0x10,%esp
 3cc:	c9                   	leave  
 3cd:	c3                   	ret    

000003ce <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3ce:	55                   	push   %ebp
 3cf:	89 e5                	mov    %esp,%ebp
 3d1:	57                   	push   %edi
 3d2:	56                   	push   %esi
 3d3:	53                   	push   %ebx
 3d4:	83 ec 2c             	sub    $0x2c,%esp
 3d7:	89 c7                	mov    %eax,%edi
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3d9:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
 3dd:	0f 95 c3             	setne  %bl
 3e0:	89 d0                	mov    %edx,%eax
 3e2:	c1 e8 1f             	shr    $0x1f,%eax
 3e5:	84 c3                	test   %al,%bl
 3e7:	74 10                	je     3f9 <printint+0x2b>
    neg = 1;
    x = -xx;
 3e9:	f7 da                	neg    %edx
    neg = 1;
 3eb:	c7 45 d4 01 00 00 00 	movl   $0x1,-0x2c(%ebp)
  } else {
    x = xx;
  }

  i = 0;
 3f2:	be 00 00 00 00       	mov    $0x0,%esi
 3f7:	eb 0b                	jmp    404 <printint+0x36>
  neg = 0;
 3f9:	c7 45 d4 00 00 00 00 	movl   $0x0,-0x2c(%ebp)
 400:	eb f0                	jmp    3f2 <printint+0x24>
  do{
    buf[i++] = digits[x % base];
 402:	89 c6                	mov    %eax,%esi
 404:	89 d0                	mov    %edx,%eax
 406:	ba 00 00 00 00       	mov    $0x0,%edx
 40b:	f7 f1                	div    %ecx
 40d:	89 c3                	mov    %eax,%ebx
 40f:	8d 46 01             	lea    0x1(%esi),%eax
 412:	0f b6 92 18 07 00 00 	movzbl 0x718(%edx),%edx
 419:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
 41d:	89 da                	mov    %ebx,%edx
 41f:	85 db                	test   %ebx,%ebx
 421:	75 df                	jne    402 <printint+0x34>
 423:	89 c3                	mov    %eax,%ebx
  if(neg)
 425:	83 7d d4 00          	cmpl   $0x0,-0x2c(%ebp)
 429:	74 16                	je     441 <printint+0x73>
    buf[i++] = '-';
 42b:	c6 44 05 d8 2d       	movb   $0x2d,-0x28(%ebp,%eax,1)
 430:	8d 5e 02             	lea    0x2(%esi),%ebx
 433:	eb 0c                	jmp    441 <printint+0x73>

  while(--i >= 0)
    putc(fd, buf[i]);
 435:	0f be 54 1d d8       	movsbl -0x28(%ebp,%ebx,1),%edx
 43a:	89 f8                	mov    %edi,%eax
 43c:	e8 73 ff ff ff       	call   3b4 <putc>
  while(--i >= 0)
 441:	83 eb 01             	sub    $0x1,%ebx
 444:	79 ef                	jns    435 <printint+0x67>
}
 446:	83 c4 2c             	add    $0x2c,%esp
 449:	5b                   	pop    %ebx
 44a:	5e                   	pop    %esi
 44b:	5f                   	pop    %edi
 44c:	5d                   	pop    %ebp
 44d:	c3                   	ret    

0000044e <printf>:

// Print to the given fd. Only understands %d, %x, %p, %s.
void
printf(int fd, const char *fmt, ...)
{
 44e:	55                   	push   %ebp
 44f:	89 e5                	mov    %esp,%ebp
 451:	57                   	push   %edi
 452:	56                   	push   %esi
 453:	53                   	push   %ebx
 454:	83 ec 1c             	sub    $0x1c,%esp
  char *s;
  int c, i, state;
  uint *ap;

  state = 0;
  ap = (uint*)(void*)&fmt + 1;
 457:	8d 45 10             	lea    0x10(%ebp),%eax
 45a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  state = 0;
 45d:	be 00 00 00 00       	mov    $0x0,%esi
  for(i = 0; fmt[i]; i++){
 462:	bb 00 00 00 00       	mov    $0x0,%ebx
 467:	eb 14                	jmp    47d <printf+0x2f>
    c = fmt[i] & 0xff;
    if(state == 0){
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
 469:	89 fa                	mov    %edi,%edx
 46b:	8b 45 08             	mov    0x8(%ebp),%eax
 46e:	e8 41 ff ff ff       	call   3b4 <putc>
 473:	eb 05                	jmp    47a <printf+0x2c>
      }
    } else if(state == '%'){
 475:	83 fe 25             	cmp    $0x25,%esi
 478:	74 25                	je     49f <printf+0x51>
  for(i = 0; fmt[i]; i++){
 47a:	83 c3 01             	add    $0x1,%ebx
 47d:	8b 45 0c             	mov    0xc(%ebp),%eax
 480:	0f b6 04 18          	movzbl (%eax,%ebx,1),%eax
 484:	84 c0                	test   %al,%al
 486:	0f 84 23 01 00 00    	je     5af <printf+0x161>
    c = fmt[i] & 0xff;
 48c:	0f be f8             	movsbl %al,%edi
 48f:	0f b6 c0             	movzbl %al,%eax
    if(state == 0){
 492:	85 f6                	test   %esi,%esi
 494:	75 df                	jne    475 <printf+0x27>
      if(c == '%'){
 496:	83 f8 25             	cmp    $0x25,%eax
 499:	75 ce                	jne    469 <printf+0x1b>
        state = '%';
 49b:	89 c6                	mov    %eax,%esi
 49d:	eb db                	jmp    47a <printf+0x2c>
      if(c == 'd'){
 49f:	83 f8 64             	cmp    $0x64,%eax
 4a2:	74 49                	je     4ed <printf+0x9f>
        printint(fd, *ap, 10, 1);
        ap++;
      } else if(c == 'x' || c == 'p'){
 4a4:	83 f8 78             	cmp    $0x78,%eax
 4a7:	0f 94 c1             	sete   %cl
 4aa:	83 f8 70             	cmp    $0x70,%eax
 4ad:	0f 94 c2             	sete   %dl
 4b0:	08 d1                	or     %dl,%cl
 4b2:	75 63                	jne    517 <printf+0xc9>
        printint(fd, *ap, 16, 0);
        ap++;
      } else if(c == 's'){
 4b4:	83 f8 73             	cmp    $0x73,%eax
 4b7:	0f 84 84 00 00 00    	je     541 <printf+0xf3>
          s = "(null)";
        while(*s != 0){
          putc(fd, *s);
          s++;
        }
      } else if(c == 'c'){
 4bd:	83 f8 63             	cmp    $0x63,%eax
 4c0:	0f 84 b7 00 00 00    	je     57d <printf+0x12f>
        putc(fd, *ap);
        ap++;
      } else if(c == '%'){
 4c6:	83 f8 25             	cmp    $0x25,%eax
 4c9:	0f 84 cc 00 00 00    	je     59b <printf+0x14d>
        putc(fd, c);
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
 4cf:	ba 25 00 00 00       	mov    $0x25,%edx
 4d4:	8b 45 08             	mov    0x8(%ebp),%eax
 4d7:	e8 d8 fe ff ff       	call   3b4 <putc>
        putc(fd, c);
 4dc:	89 fa                	mov    %edi,%edx
 4de:	8b 45 08             	mov    0x8(%ebp),%eax
 4e1:	e8 ce fe ff ff       	call   3b4 <putc>
      }
      state = 0;
 4e6:	be 00 00 00 00       	mov    $0x0,%esi
 4eb:	eb 8d                	jmp    47a <printf+0x2c>
        printint(fd, *ap, 10, 1);
 4ed:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 4f0:	8b 17                	mov    (%edi),%edx
 4f2:	83 ec 0c             	sub    $0xc,%esp
 4f5:	6a 01                	push   $0x1
 4f7:	b9 0a 00 00 00       	mov    $0xa,%ecx
 4fc:	8b 45 08             	mov    0x8(%ebp),%eax
 4ff:	e8 ca fe ff ff       	call   3ce <printint>
        ap++;
 504:	83 c7 04             	add    $0x4,%edi
 507:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 50a:	83 c4 10             	add    $0x10,%esp
      state = 0;
 50d:	be 00 00 00 00       	mov    $0x0,%esi
 512:	e9 63 ff ff ff       	jmp    47a <printf+0x2c>
        printint(fd, *ap, 16, 0);
 517:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 51a:	8b 17                	mov    (%edi),%edx
 51c:	83 ec 0c             	sub    $0xc,%esp
 51f:	6a 00                	push   $0x0
 521:	b9 10 00 00 00       	mov    $0x10,%ecx
 526:	8b 45 08             	mov    0x8(%ebp),%eax
 529:	e8 a0 fe ff ff       	call   3ce <printint>
        ap++;
 52e:	83 c7 04             	add    $0x4,%edi
 531:	89 7d e4             	mov    %edi,-0x1c(%ebp)
 534:	83 c4 10             	add    $0x10,%esp
      state = 0;
 537:	be 00 00 00 00       	mov    $0x0,%esi
 53c:	e9 39 ff ff ff       	jmp    47a <printf+0x2c>
        s = (char*)*ap;
 541:	8b 45 e4             	mov    -0x1c(%ebp),%eax
 544:	8b 30                	mov    (%eax),%esi
        ap++;
 546:	83 c0 04             	add    $0x4,%eax
 549:	89 45 e4             	mov    %eax,-0x1c(%ebp)
        if(s == 0)
 54c:	85 f6                	test   %esi,%esi
 54e:	75 28                	jne    578 <printf+0x12a>
          s = "(null)";
 550:	be 0f 07 00 00       	mov    $0x70f,%esi
 555:	8b 7d 08             	mov    0x8(%ebp),%edi
 558:	eb 0d                	jmp    567 <printf+0x119>
          putc(fd, *s);
 55a:	0f be d2             	movsbl %dl,%edx
 55d:	89 f8                	mov    %edi,%eax
 55f:	e8 50 fe ff ff       	call   3b4 <putc>
          s++;
 564:	83 c6 01             	add    $0x1,%esi
        while(*s != 0){
 567:	0f b6 16             	movzbl (%esi),%edx
 56a:	84 d2                	test   %dl,%dl
 56c:	75 ec                	jne    55a <printf+0x10c>
      state = 0;
 56e:	be 00 00 00 00       	mov    $0x0,%esi
 573:	e9 02 ff ff ff       	jmp    47a <printf+0x2c>
 578:	8b 7d 08             	mov    0x8(%ebp),%edi
 57b:	eb ea                	jmp    567 <printf+0x119>
        putc(fd, *ap);
 57d:	8b 7d e4             	mov    -0x1c(%ebp),%edi
 580:	0f be 17             	movsbl (%edi),%edx
 583:	8b 45 08             	mov    0x8(%ebp),%eax
 586:	e8 29 fe ff ff       	call   3b4 <putc>
        ap++;
 58b:	83 c7 04             	add    $0x4,%edi
 58e:	89 7d e4             	mov    %edi,-0x1c(%ebp)
      state = 0;
 591:	be 00 00 00 00       	mov    $0x0,%esi
 596:	e9 df fe ff ff       	jmp    47a <printf+0x2c>
        putc(fd, c);
 59b:	89 fa                	mov    %edi,%edx
 59d:	8b 45 08             	mov    0x8(%ebp),%eax
 5a0:	e8 0f fe ff ff       	call   3b4 <putc>
      state = 0;
 5a5:	be 00 00 00 00       	mov    $0x0,%esi
 5aa:	e9 cb fe ff ff       	jmp    47a <printf+0x2c>
    }
  }
}
 5af:	8d 65 f4             	lea    -0xc(%ebp),%esp
 5b2:	5b                   	pop    %ebx
 5b3:	5e                   	pop    %esi
 5b4:	5f                   	pop    %edi
 5b5:	5d                   	pop    %ebp
 5b6:	c3                   	ret    

000005b7 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 5b7:	55                   	push   %ebp
 5b8:	89 e5                	mov    %esp,%ebp
 5ba:	57                   	push   %edi
 5bb:	56                   	push   %esi
 5bc:	53                   	push   %ebx
 5bd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  Header *bp, *p;

  bp = (Header*)ap - 1;
 5c0:	8d 4b f8             	lea    -0x8(%ebx),%ecx
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 5c3:	a1 bc 09 00 00       	mov    0x9bc,%eax
 5c8:	eb 02                	jmp    5cc <free+0x15>
 5ca:	89 d0                	mov    %edx,%eax
 5cc:	39 c8                	cmp    %ecx,%eax
 5ce:	73 04                	jae    5d4 <free+0x1d>
 5d0:	39 08                	cmp    %ecx,(%eax)
 5d2:	77 12                	ja     5e6 <free+0x2f>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 5d4:	8b 10                	mov    (%eax),%edx
 5d6:	39 c2                	cmp    %eax,%edx
 5d8:	77 f0                	ja     5ca <free+0x13>
 5da:	39 c8                	cmp    %ecx,%eax
 5dc:	72 08                	jb     5e6 <free+0x2f>
 5de:	39 ca                	cmp    %ecx,%edx
 5e0:	77 04                	ja     5e6 <free+0x2f>
 5e2:	89 d0                	mov    %edx,%eax
 5e4:	eb e6                	jmp    5cc <free+0x15>
      break;
  if(bp + bp->s.size == p->s.ptr){
 5e6:	8b 73 fc             	mov    -0x4(%ebx),%esi
 5e9:	8d 3c f1             	lea    (%ecx,%esi,8),%edi
 5ec:	8b 10                	mov    (%eax),%edx
 5ee:	39 d7                	cmp    %edx,%edi
 5f0:	74 19                	je     60b <free+0x54>
    bp->s.size += p->s.ptr->s.size;
    bp->s.ptr = p->s.ptr->s.ptr;
  } else
    bp->s.ptr = p->s.ptr;
 5f2:	89 53 f8             	mov    %edx,-0x8(%ebx)
  if(p + p->s.size == bp){
 5f5:	8b 50 04             	mov    0x4(%eax),%edx
 5f8:	8d 34 d0             	lea    (%eax,%edx,8),%esi
 5fb:	39 ce                	cmp    %ecx,%esi
 5fd:	74 1b                	je     61a <free+0x63>
    p->s.size += bp->s.size;
    p->s.ptr = bp->s.ptr;
  } else
    p->s.ptr = bp;
 5ff:	89 08                	mov    %ecx,(%eax)
  freep = p;
 601:	a3 bc 09 00 00       	mov    %eax,0x9bc
}
 606:	5b                   	pop    %ebx
 607:	5e                   	pop    %esi
 608:	5f                   	pop    %edi
 609:	5d                   	pop    %ebp
 60a:	c3                   	ret    
    bp->s.size += p->s.ptr->s.size;
 60b:	03 72 04             	add    0x4(%edx),%esi
 60e:	89 73 fc             	mov    %esi,-0x4(%ebx)
    bp->s.ptr = p->s.ptr->s.ptr;
 611:	8b 10                	mov    (%eax),%edx
 613:	8b 12                	mov    (%edx),%edx
 615:	89 53 f8             	mov    %edx,-0x8(%ebx)
 618:	eb db                	jmp    5f5 <free+0x3e>
    p->s.size += bp->s.size;
 61a:	03 53 fc             	add    -0x4(%ebx),%edx
 61d:	89 50 04             	mov    %edx,0x4(%eax)
    p->s.ptr = bp->s.ptr;
 620:	8b 53 f8             	mov    -0x8(%ebx),%edx
 623:	89 10                	mov    %edx,(%eax)
 625:	eb da                	jmp    601 <free+0x4a>

00000627 <morecore>:

static Header*
morecore(uint nu)
{
 627:	55                   	push   %ebp
 628:	89 e5                	mov    %esp,%ebp
 62a:	53                   	push   %ebx
 62b:	83 ec 04             	sub    $0x4,%esp
 62e:	89 c3                	mov    %eax,%ebx
  char *p;
  Header *hp;

  if(nu < 4096)
 630:	3d ff 0f 00 00       	cmp    $0xfff,%eax
 635:	77 05                	ja     63c <morecore+0x15>
    nu = 4096;
 637:	bb 00 10 00 00       	mov    $0x1000,%ebx
  p = sbrk(nu * sizeof(Header));
 63c:	8d 04 dd 00 00 00 00 	lea    0x0(,%ebx,8),%eax
 643:	83 ec 0c             	sub    $0xc,%esp
 646:	50                   	push   %eax
 647:	e8 40 fd ff ff       	call   38c <sbrk>
  if(p == (char*)-1)
 64c:	83 c4 10             	add    $0x10,%esp
 64f:	83 f8 ff             	cmp    $0xffffffff,%eax
 652:	74 1c                	je     670 <morecore+0x49>
    return 0;
  hp = (Header*)p;
  hp->s.size = nu;
 654:	89 58 04             	mov    %ebx,0x4(%eax)
  free((void*)(hp + 1));
 657:	83 c0 08             	add    $0x8,%eax
 65a:	83 ec 0c             	sub    $0xc,%esp
 65d:	50                   	push   %eax
 65e:	e8 54 ff ff ff       	call   5b7 <free>
  return freep;
 663:	a1 bc 09 00 00       	mov    0x9bc,%eax
 668:	83 c4 10             	add    $0x10,%esp
}
 66b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
 66e:	c9                   	leave  
 66f:	c3                   	ret    
    return 0;
 670:	b8 00 00 00 00       	mov    $0x0,%eax
 675:	eb f4                	jmp    66b <morecore+0x44>

00000677 <malloc>:

void*
malloc(uint nbytes)
{
 677:	55                   	push   %ebp
 678:	89 e5                	mov    %esp,%ebp
 67a:	53                   	push   %ebx
 67b:	83 ec 04             	sub    $0x4,%esp
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 67e:	8b 45 08             	mov    0x8(%ebp),%eax
 681:	8d 58 07             	lea    0x7(%eax),%ebx
 684:	c1 eb 03             	shr    $0x3,%ebx
 687:	83 c3 01             	add    $0x1,%ebx
  if((prevp = freep) == 0){
 68a:	8b 0d bc 09 00 00    	mov    0x9bc,%ecx
 690:	85 c9                	test   %ecx,%ecx
 692:	74 04                	je     698 <malloc+0x21>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 694:	8b 01                	mov    (%ecx),%eax
 696:	eb 4d                	jmp    6e5 <malloc+0x6e>
    base.s.ptr = freep = prevp = &base;
 698:	c7 05 bc 09 00 00 c0 	movl   $0x9c0,0x9bc
 69f:	09 00 00 
 6a2:	c7 05 c0 09 00 00 c0 	movl   $0x9c0,0x9c0
 6a9:	09 00 00 
    base.s.size = 0;
 6ac:	c7 05 c4 09 00 00 00 	movl   $0x0,0x9c4
 6b3:	00 00 00 
    base.s.ptr = freep = prevp = &base;
 6b6:	b9 c0 09 00 00       	mov    $0x9c0,%ecx
 6bb:	eb d7                	jmp    694 <malloc+0x1d>
    if(p->s.size >= nunits){
      if(p->s.size == nunits)
 6bd:	39 da                	cmp    %ebx,%edx
 6bf:	74 1a                	je     6db <malloc+0x64>
        prevp->s.ptr = p->s.ptr;
      else {
        p->s.size -= nunits;
 6c1:	29 da                	sub    %ebx,%edx
 6c3:	89 50 04             	mov    %edx,0x4(%eax)
        p += p->s.size;
 6c6:	8d 04 d0             	lea    (%eax,%edx,8),%eax
        p->s.size = nunits;
 6c9:	89 58 04             	mov    %ebx,0x4(%eax)
      }
      freep = prevp;
 6cc:	89 0d bc 09 00 00    	mov    %ecx,0x9bc
      return (void*)(p + 1);
 6d2:	83 c0 08             	add    $0x8,%eax
    }
    if(p == freep)
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 6d5:	83 c4 04             	add    $0x4,%esp
 6d8:	5b                   	pop    %ebx
 6d9:	5d                   	pop    %ebp
 6da:	c3                   	ret    
        prevp->s.ptr = p->s.ptr;
 6db:	8b 10                	mov    (%eax),%edx
 6dd:	89 11                	mov    %edx,(%ecx)
 6df:	eb eb                	jmp    6cc <malloc+0x55>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 6e1:	89 c1                	mov    %eax,%ecx
 6e3:	8b 00                	mov    (%eax),%eax
    if(p->s.size >= nunits){
 6e5:	8b 50 04             	mov    0x4(%eax),%edx
 6e8:	39 da                	cmp    %ebx,%edx
 6ea:	73 d1                	jae    6bd <malloc+0x46>
    if(p == freep)
 6ec:	39 05 bc 09 00 00    	cmp    %eax,0x9bc
 6f2:	75 ed                	jne    6e1 <malloc+0x6a>
      if((p = morecore(nunits)) == 0)
 6f4:	89 d8                	mov    %ebx,%eax
 6f6:	e8 2c ff ff ff       	call   627 <morecore>
 6fb:	85 c0                	test   %eax,%eax
 6fd:	75 e2                	jne    6e1 <malloc+0x6a>
        return 0;
 6ff:	b8 00 00 00 00       	mov    $0x0,%eax
 704:	eb cf                	jmp    6d5 <malloc+0x5e>
