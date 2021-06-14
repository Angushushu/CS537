
kernel:     file format elf32-i386


Disassembly of section .text:

80100000 <multiboot_header>:
80100000:	02 b0 ad 1b 00 00    	add    0x1bad(%eax),%dh
80100006:	00 00                	add    %al,(%eax)
80100008:	fe 4f 52             	decb   0x52(%edi)
8010000b:	e4                   	.byte 0xe4

8010000c <entry>:

# Entering xv6 on boot processor, with paging off.
.globl entry
entry:
  # Turn on page size extension for 4Mbyte pages
  movl    %cr4, %eax
8010000c:	0f 20 e0             	mov    %cr4,%eax
  orl     $(CR4_PSE), %eax
8010000f:	83 c8 10             	or     $0x10,%eax
  movl    %eax, %cr4
80100012:	0f 22 e0             	mov    %eax,%cr4
  # Set page directory
  movl    $(V2P_WO(entrypgdir)), %eax
80100015:	b8 00 90 10 00       	mov    $0x109000,%eax
  movl    %eax, %cr3
8010001a:	0f 22 d8             	mov    %eax,%cr3
  # Turn on paging.
  movl    %cr0, %eax
8010001d:	0f 20 c0             	mov    %cr0,%eax
  orl     $(CR0_PG|CR0_WP), %eax
80100020:	0d 00 00 01 80       	or     $0x80010000,%eax
  movl    %eax, %cr0
80100025:	0f 22 c0             	mov    %eax,%cr0

  # Set up the stack pointer.
  movl $(stack + KSTACKSIZE), %esp
80100028:	bc d0 b5 10 80       	mov    $0x8010b5d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 c0 2b 10 80       	mov    $0x80102bc0,%eax
  jmp *%eax
80100032:	ff e0                	jmp    *%eax

80100034 <bget>:
// Look through buffer cache for block on device dev.
// If not found, allocate a buffer.
// In either case, return locked buffer.
static struct buf*
bget(uint dev, uint blockno)
{
80100034:	55                   	push   %ebp
80100035:	89 e5                	mov    %esp,%ebp
80100037:	57                   	push   %edi
80100038:	56                   	push   %esi
80100039:	53                   	push   %ebx
8010003a:	83 ec 18             	sub    $0x18,%esp
8010003d:	89 c6                	mov    %eax,%esi
8010003f:	89 d7                	mov    %edx,%edi
  struct buf *b;

  acquire(&bcache.lock);
80100041:	68 e0 b5 10 80       	push   $0x8010b5e0
80100046:	e8 a6 3c 00 00       	call   80103cf1 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 30 fd 10 80    	mov    0x8010fd30,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
8010005f:	74 30                	je     80100091 <bget+0x5d>
    if(b->dev == dev && b->blockno == blockno){
80100061:	39 73 04             	cmp    %esi,0x4(%ebx)
80100064:	75 f0                	jne    80100056 <bget+0x22>
80100066:	39 7b 08             	cmp    %edi,0x8(%ebx)
80100069:	75 eb                	jne    80100056 <bget+0x22>
      b->refcnt++;
8010006b:	8b 43 4c             	mov    0x4c(%ebx),%eax
8010006e:	83 c0 01             	add    $0x1,%eax
80100071:	89 43 4c             	mov    %eax,0x4c(%ebx)
      release(&bcache.lock);
80100074:	83 ec 0c             	sub    $0xc,%esp
80100077:	68 e0 b5 10 80       	push   $0x8010b5e0
8010007c:	e8 d5 3c 00 00       	call   80103d56 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 51 3a 00 00       	call   80103add <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 2c fd 10 80    	mov    0x8010fd2c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
801000a2:	74 43                	je     801000e7 <bget+0xb3>
    if(b->refcnt == 0 && (b->flags & B_DIRTY) == 0) {
801000a4:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801000a8:	75 ef                	jne    80100099 <bget+0x65>
801000aa:	f6 03 04             	testb  $0x4,(%ebx)
801000ad:	75 ea                	jne    80100099 <bget+0x65>
      b->dev = dev;
801000af:	89 73 04             	mov    %esi,0x4(%ebx)
      b->blockno = blockno;
801000b2:	89 7b 08             	mov    %edi,0x8(%ebx)
      b->flags = 0;
801000b5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
      b->refcnt = 1;
801000bb:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
      release(&bcache.lock);
801000c2:	83 ec 0c             	sub    $0xc,%esp
801000c5:	68 e0 b5 10 80       	push   $0x8010b5e0
801000ca:	e8 87 3c 00 00       	call   80103d56 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 03 3a 00 00       	call   80103add <acquiresleep>
      return b;
801000da:	83 c4 10             	add    $0x10,%esp
    }
  }
  panic("bget: no buffers");
}
801000dd:	89 d8                	mov    %ebx,%eax
801000df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801000e2:	5b                   	pop    %ebx
801000e3:	5e                   	pop    %esi
801000e4:	5f                   	pop    %edi
801000e5:	5d                   	pop    %ebp
801000e6:	c3                   	ret    
  panic("bget: no buffers");
801000e7:	83 ec 0c             	sub    $0xc,%esp
801000ea:	68 00 66 10 80       	push   $0x80106600
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 11 66 10 80       	push   $0x80106611
80100100:	68 e0 b5 10 80       	push   $0x8010b5e0
80100105:	e8 ab 3a 00 00       	call   80103bb5 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 2c fd 10 80 dc 	movl   $0x8010fcdc,0x8010fd2c
80100111:	fc 10 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 30 fd 10 80 dc 	movl   $0x8010fcdc,0x8010fd30
8010011b:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 14 b6 10 80       	mov    $0x8010b614,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 dc fc 10 80 	movl   $0x8010fcdc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 18 66 10 80       	push   $0x80106618
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 62 39 00 00       	call   80103aaa <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 30 fd 10 80    	mov    %ebx,0x8010fd30
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb dc fc 10 80    	cmp    $0x8010fcdc,%ebx
80100165:	72 c1                	jb     80100128 <binit+0x34>
}
80100167:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010016a:	c9                   	leave  
8010016b:	c3                   	ret    

8010016c <bread>:

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
8010016c:	55                   	push   %ebp
8010016d:	89 e5                	mov    %esp,%ebp
8010016f:	53                   	push   %ebx
80100170:	83 ec 04             	sub    $0x4,%esp
  struct buf *b;

  b = bget(dev, blockno);
80100173:	8b 55 0c             	mov    0xc(%ebp),%edx
80100176:	8b 45 08             	mov    0x8(%ebp),%eax
80100179:	e8 b6 fe ff ff       	call   80100034 <bget>
8010017e:	89 c3                	mov    %eax,%ebx
  if((b->flags & B_VALID) == 0) {
80100180:	f6 00 02             	testb  $0x2,(%eax)
80100183:	74 07                	je     8010018c <bread+0x20>
    iderw(b);
  }
  return b;
}
80100185:	89 d8                	mov    %ebx,%eax
80100187:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010018a:	c9                   	leave  
8010018b:	c3                   	ret    
    iderw(b);
8010018c:	83 ec 0c             	sub    $0xc,%esp
8010018f:	50                   	push   %eax
80100190:	e8 77 1c 00 00       	call   80101e0c <iderw>
80100195:	83 c4 10             	add    $0x10,%esp
  return b;
80100198:	eb eb                	jmp    80100185 <bread+0x19>

8010019a <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
8010019a:	55                   	push   %ebp
8010019b:	89 e5                	mov    %esp,%ebp
8010019d:	53                   	push   %ebx
8010019e:	83 ec 10             	sub    $0x10,%esp
801001a1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001a4:	8d 43 0c             	lea    0xc(%ebx),%eax
801001a7:	50                   	push   %eax
801001a8:	e8 ba 39 00 00       	call   80103b67 <holdingsleep>
801001ad:	83 c4 10             	add    $0x10,%esp
801001b0:	85 c0                	test   %eax,%eax
801001b2:	74 14                	je     801001c8 <bwrite+0x2e>
    panic("bwrite");
  b->flags |= B_DIRTY;
801001b4:	83 0b 04             	orl    $0x4,(%ebx)
  iderw(b);
801001b7:	83 ec 0c             	sub    $0xc,%esp
801001ba:	53                   	push   %ebx
801001bb:	e8 4c 1c 00 00       	call   80101e0c <iderw>
}
801001c0:	83 c4 10             	add    $0x10,%esp
801001c3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801001c6:	c9                   	leave  
801001c7:	c3                   	ret    
    panic("bwrite");
801001c8:	83 ec 0c             	sub    $0xc,%esp
801001cb:	68 1f 66 10 80       	push   $0x8010661f
801001d0:	e8 73 01 00 00       	call   80100348 <panic>

801001d5 <brelse>:

// Release a locked buffer.
// Move to the head of the MRU list.
void
brelse(struct buf *b)
{
801001d5:	55                   	push   %ebp
801001d6:	89 e5                	mov    %esp,%ebp
801001d8:	56                   	push   %esi
801001d9:	53                   	push   %ebx
801001da:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holdingsleep(&b->lock))
801001dd:	8d 73 0c             	lea    0xc(%ebx),%esi
801001e0:	83 ec 0c             	sub    $0xc,%esp
801001e3:	56                   	push   %esi
801001e4:	e8 7e 39 00 00       	call   80103b67 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 33 39 00 00       	call   80103b2c <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100200:	e8 ec 3a 00 00       	call   80103cf1 <acquire>
  b->refcnt--;
80100205:	8b 43 4c             	mov    0x4c(%ebx),%eax
80100208:	83 e8 01             	sub    $0x1,%eax
8010020b:	89 43 4c             	mov    %eax,0x4c(%ebx)
  if (b->refcnt == 0) {
8010020e:	83 c4 10             	add    $0x10,%esp
80100211:	85 c0                	test   %eax,%eax
80100213:	75 2f                	jne    80100244 <brelse+0x6f>
    // no one is waiting for it.
    b->next->prev = b->prev;
80100215:	8b 43 54             	mov    0x54(%ebx),%eax
80100218:	8b 53 50             	mov    0x50(%ebx),%edx
8010021b:	89 50 50             	mov    %edx,0x50(%eax)
    b->prev->next = b->next;
8010021e:	8b 43 50             	mov    0x50(%ebx),%eax
80100221:	8b 53 54             	mov    0x54(%ebx),%edx
80100224:	89 50 54             	mov    %edx,0x54(%eax)
    b->next = bcache.head.next;
80100227:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 dc fc 10 80 	movl   $0x8010fcdc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 30 fd 10 80       	mov    0x8010fd30,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 30 fd 10 80    	mov    %ebx,0x8010fd30
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 e0 b5 10 80       	push   $0x8010b5e0
8010024c:	e8 05 3b 00 00       	call   80103d56 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 26 66 10 80       	push   $0x80106626
80100263:	e8 e0 00 00 00       	call   80100348 <panic>

80100268 <consoleread>:
  }
}

int
consoleread(struct inode *ip, char *dst, int n)
{
80100268:	55                   	push   %ebp
80100269:	89 e5                	mov    %esp,%ebp
8010026b:	57                   	push   %edi
8010026c:	56                   	push   %esi
8010026d:	53                   	push   %ebx
8010026e:	83 ec 28             	sub    $0x28,%esp
80100271:	8b 7d 08             	mov    0x8(%ebp),%edi
80100274:	8b 75 0c             	mov    0xc(%ebp),%esi
80100277:	8b 5d 10             	mov    0x10(%ebp),%ebx
  uint target;
  int c;

  iunlock(ip);
8010027a:	57                   	push   %edi
8010027b:	e8 c3 13 00 00       	call   80101643 <iunlock>
  target = n;
80100280:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
  acquire(&cons.lock);
80100283:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
8010028a:	e8 62 3a 00 00       	call   80103cf1 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
8010029f:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 a6 30 00 00       	call   80103352 <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 a5 10 80       	push   $0x8010a520
801002ba:	68 c0 ff 10 80       	push   $0x8010ffc0
801002bf:	e8 32 35 00 00       	call   801037f6 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 80 3a 00 00       	call   80103d56 <release>
        ilock(ip);
801002d6:	89 3c 24             	mov    %edi,(%esp)
801002d9:	e8 a3 12 00 00       	call   80101581 <ilock>
        return -1;
801002de:	83 c4 10             	add    $0x10,%esp
801002e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  release(&cons.lock);
  ilock(ip);

  return target - n;
}
801002e6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801002e9:	5b                   	pop    %ebx
801002ea:	5e                   	pop    %esi
801002eb:	5f                   	pop    %edi
801002ec:	5d                   	pop    %ebp
801002ed:	c3                   	ret    
    c = input.buf[input.r++ % INPUT_BUF];
801002ee:	8d 50 01             	lea    0x1(%eax),%edx
801002f1:	89 15 c0 ff 10 80    	mov    %edx,0x8010ffc0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 40 ff 10 80 	movzbl -0x7fef00c0(%edx),%ecx
80100303:	0f be d1             	movsbl %cl,%edx
    if(c == C('D')){  // EOF
80100306:	83 fa 04             	cmp    $0x4,%edx
80100309:	74 14                	je     8010031f <consoleread+0xb7>
    *dst++ = c;
8010030b:	8d 46 01             	lea    0x1(%esi),%eax
8010030e:	88 0e                	mov    %cl,(%esi)
    --n;
80100310:	83 eb 01             	sub    $0x1,%ebx
    if(c == '\n')
80100313:	83 fa 0a             	cmp    $0xa,%edx
80100316:	74 11                	je     80100329 <consoleread+0xc1>
    *dst++ = c;
80100318:	89 c6                	mov    %eax,%esi
8010031a:	e9 73 ff ff ff       	jmp    80100292 <consoleread+0x2a>
      if(n < target){
8010031f:	3b 5d e4             	cmp    -0x1c(%ebp),%ebx
80100322:	73 05                	jae    80100329 <consoleread+0xc1>
        input.r--;
80100324:	a3 c0 ff 10 80       	mov    %eax,0x8010ffc0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 a5 10 80       	push   $0x8010a520
80100331:	e8 20 3a 00 00       	call   80103d56 <release>
  ilock(ip);
80100336:	89 3c 24             	mov    %edi,(%esp)
80100339:	e8 43 12 00 00       	call   80101581 <ilock>
  return target - n;
8010033e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80100341:	29 d8                	sub    %ebx,%eax
80100343:	83 c4 10             	add    $0x10,%esp
80100346:	eb 9e                	jmp    801002e6 <consoleread+0x7e>

80100348 <panic>:
{
80100348:	55                   	push   %ebp
80100349:	89 e5                	mov    %esp,%ebp
8010034b:	53                   	push   %ebx
8010034c:	83 ec 34             	sub    $0x34,%esp
}

static inline void
cli(void)
{
  asm volatile("cli");
8010034f:	fa                   	cli    
  cons.locking = 0;
80100350:	c7 05 54 a5 10 80 00 	movl   $0x0,0x8010a554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 7b 21 00 00       	call   801024da <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 2d 66 10 80       	push   $0x8010662d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 bb 6f 10 80 	movl   $0x80106fbb,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 3c 38 00 00       	call   80103bd0 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 41 66 10 80       	push   $0x80106641
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 a5 10 80 01 	movl   $0x1,0x8010a558
801003c1:	00 00 00 
801003c4:	eb fe                	jmp    801003c4 <panic+0x7c>

801003c6 <cgaputc>:
{
801003c6:	55                   	push   %ebp
801003c7:	89 e5                	mov    %esp,%ebp
801003c9:	57                   	push   %edi
801003ca:	56                   	push   %esi
801003cb:	53                   	push   %ebx
801003cc:	83 ec 0c             	sub    $0xc,%esp
801003cf:	89 c6                	mov    %eax,%esi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003d1:	b9 d4 03 00 00       	mov    $0x3d4,%ecx
801003d6:	b8 0e 00 00 00       	mov    $0xe,%eax
801003db:	89 ca                	mov    %ecx,%edx
801003dd:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003de:	bb d5 03 00 00       	mov    $0x3d5,%ebx
801003e3:	89 da                	mov    %ebx,%edx
801003e5:	ec                   	in     (%dx),%al
  pos = inb(CRTPORT+1) << 8;
801003e6:	0f b6 f8             	movzbl %al,%edi
801003e9:	c1 e7 08             	shl    $0x8,%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801003ec:	b8 0f 00 00 00       	mov    $0xf,%eax
801003f1:	89 ca                	mov    %ecx,%edx
801003f3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801003f4:	89 da                	mov    %ebx,%edx
801003f6:	ec                   	in     (%dx),%al
  pos |= inb(CRTPORT+1);
801003f7:	0f b6 c8             	movzbl %al,%ecx
801003fa:	09 f9                	or     %edi,%ecx
  if(c == '\n')
801003fc:	83 fe 0a             	cmp    $0xa,%esi
801003ff:	74 6a                	je     8010046b <cgaputc+0xa5>
  else if(c == BACKSPACE){
80100401:	81 fe 00 01 00 00    	cmp    $0x100,%esi
80100407:	0f 84 81 00 00 00    	je     8010048e <cgaputc+0xc8>
    crt[pos++] = (c&0xff) | 0x0700;  // black on white
8010040d:	89 f0                	mov    %esi,%eax
8010040f:	0f b6 f0             	movzbl %al,%esi
80100412:	8d 59 01             	lea    0x1(%ecx),%ebx
80100415:	66 81 ce 00 07       	or     $0x700,%si
8010041a:	66 89 b4 09 00 80 0b 	mov    %si,-0x7ff48000(%ecx,%ecx,1)
80100421:	80 
  if(pos < 0 || pos > 25*80)
80100422:	81 fb d0 07 00 00    	cmp    $0x7d0,%ebx
80100428:	77 71                	ja     8010049b <cgaputc+0xd5>
  if((pos/80) >= 24){  // Scroll up.
8010042a:	81 fb 7f 07 00 00    	cmp    $0x77f,%ebx
80100430:	7f 76                	jg     801004a8 <cgaputc+0xe2>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80100432:	be d4 03 00 00       	mov    $0x3d4,%esi
80100437:	b8 0e 00 00 00       	mov    $0xe,%eax
8010043c:	89 f2                	mov    %esi,%edx
8010043e:	ee                   	out    %al,(%dx)
  outb(CRTPORT+1, pos>>8);
8010043f:	89 d8                	mov    %ebx,%eax
80100441:	c1 f8 08             	sar    $0x8,%eax
80100444:	b9 d5 03 00 00       	mov    $0x3d5,%ecx
80100449:	89 ca                	mov    %ecx,%edx
8010044b:	ee                   	out    %al,(%dx)
8010044c:	b8 0f 00 00 00       	mov    $0xf,%eax
80100451:	89 f2                	mov    %esi,%edx
80100453:	ee                   	out    %al,(%dx)
80100454:	89 d8                	mov    %ebx,%eax
80100456:	89 ca                	mov    %ecx,%edx
80100458:	ee                   	out    %al,(%dx)
  crt[pos] = ' ' | 0x0700;
80100459:	66 c7 84 1b 00 80 0b 	movw   $0x720,-0x7ff48000(%ebx,%ebx,1)
80100460:	80 20 07 
}
80100463:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100466:	5b                   	pop    %ebx
80100467:	5e                   	pop    %esi
80100468:	5f                   	pop    %edi
80100469:	5d                   	pop    %ebp
8010046a:	c3                   	ret    
    pos += 80 - pos%80;
8010046b:	ba 67 66 66 66       	mov    $0x66666667,%edx
80100470:	89 c8                	mov    %ecx,%eax
80100472:	f7 ea                	imul   %edx
80100474:	c1 fa 05             	sar    $0x5,%edx
80100477:	8d 14 92             	lea    (%edx,%edx,4),%edx
8010047a:	89 d0                	mov    %edx,%eax
8010047c:	c1 e0 04             	shl    $0x4,%eax
8010047f:	89 ca                	mov    %ecx,%edx
80100481:	29 c2                	sub    %eax,%edx
80100483:	bb 50 00 00 00       	mov    $0x50,%ebx
80100488:	29 d3                	sub    %edx,%ebx
8010048a:	01 cb                	add    %ecx,%ebx
8010048c:	eb 94                	jmp    80100422 <cgaputc+0x5c>
    if(pos > 0) --pos;
8010048e:	85 c9                	test   %ecx,%ecx
80100490:	7e 05                	jle    80100497 <cgaputc+0xd1>
80100492:	8d 59 ff             	lea    -0x1(%ecx),%ebx
80100495:	eb 8b                	jmp    80100422 <cgaputc+0x5c>
  pos |= inb(CRTPORT+1);
80100497:	89 cb                	mov    %ecx,%ebx
80100499:	eb 87                	jmp    80100422 <cgaputc+0x5c>
    panic("pos under/overflow");
8010049b:	83 ec 0c             	sub    $0xc,%esp
8010049e:	68 45 66 10 80       	push   $0x80106645
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 59 39 00 00       	call   80103e18 <memmove>
    pos -= 80;
801004bf:	83 eb 50             	sub    $0x50,%ebx
    memset(crt+pos, 0, sizeof(crt[0])*(24*80 - pos));
801004c2:	b8 80 07 00 00       	mov    $0x780,%eax
801004c7:	29 d8                	sub    %ebx,%eax
801004c9:	8d 94 1b 00 80 0b 80 	lea    -0x7ff48000(%ebx,%ebx,1),%edx
801004d0:	83 c4 0c             	add    $0xc,%esp
801004d3:	01 c0                	add    %eax,%eax
801004d5:	50                   	push   %eax
801004d6:	6a 00                	push   $0x0
801004d8:	52                   	push   %edx
801004d9:	e8 bf 38 00 00       	call   80103d9d <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 a5 10 80 00 	cmpl   $0x0,0x8010a558
801004ed:	74 03                	je     801004f2 <consputc+0xc>
  asm volatile("cli");
801004ef:	fa                   	cli    
801004f0:	eb fe                	jmp    801004f0 <consputc+0xa>
{
801004f2:	55                   	push   %ebp
801004f3:	89 e5                	mov    %esp,%ebp
801004f5:	53                   	push   %ebx
801004f6:	83 ec 04             	sub    $0x4,%esp
801004f9:	89 c3                	mov    %eax,%ebx
  if(c == BACKSPACE){
801004fb:	3d 00 01 00 00       	cmp    $0x100,%eax
80100500:	74 18                	je     8010051a <consputc+0x34>
    uartputc(c);
80100502:	83 ec 0c             	sub    $0xc,%esp
80100505:	50                   	push   %eax
80100506:	e8 cc 4c 00 00       	call   801051d7 <uartputc>
8010050b:	83 c4 10             	add    $0x10,%esp
  cgaputc(c);
8010050e:	89 d8                	mov    %ebx,%eax
80100510:	e8 b1 fe ff ff       	call   801003c6 <cgaputc>
}
80100515:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100518:	c9                   	leave  
80100519:	c3                   	ret    
    uartputc('\b'); uartputc(' '); uartputc('\b');
8010051a:	83 ec 0c             	sub    $0xc,%esp
8010051d:	6a 08                	push   $0x8
8010051f:	e8 b3 4c 00 00       	call   801051d7 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 a7 4c 00 00       	call   801051d7 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 9b 4c 00 00       	call   801051d7 <uartputc>
8010053c:	83 c4 10             	add    $0x10,%esp
8010053f:	eb cd                	jmp    8010050e <consputc+0x28>

80100541 <printint>:
{
80100541:	55                   	push   %ebp
80100542:	89 e5                	mov    %esp,%ebp
80100544:	57                   	push   %edi
80100545:	56                   	push   %esi
80100546:	53                   	push   %ebx
80100547:	83 ec 1c             	sub    $0x1c,%esp
8010054a:	89 d7                	mov    %edx,%edi
  if(sign && (sign = xx < 0))
8010054c:	85 c9                	test   %ecx,%ecx
8010054e:	74 09                	je     80100559 <printint+0x18>
80100550:	89 c1                	mov    %eax,%ecx
80100552:	c1 e9 1f             	shr    $0x1f,%ecx
80100555:	85 c0                	test   %eax,%eax
80100557:	78 09                	js     80100562 <printint+0x21>
    x = xx;
80100559:	89 c2                	mov    %eax,%edx
  i = 0;
8010055b:	be 00 00 00 00       	mov    $0x0,%esi
80100560:	eb 08                	jmp    8010056a <printint+0x29>
    x = -xx;
80100562:	f7 d8                	neg    %eax
80100564:	89 c2                	mov    %eax,%edx
80100566:	eb f3                	jmp    8010055b <printint+0x1a>
    buf[i++] = digits[x % base];
80100568:	89 de                	mov    %ebx,%esi
8010056a:	89 d0                	mov    %edx,%eax
8010056c:	ba 00 00 00 00       	mov    $0x0,%edx
80100571:	f7 f7                	div    %edi
80100573:	8d 5e 01             	lea    0x1(%esi),%ebx
80100576:	0f b6 92 70 66 10 80 	movzbl -0x7fef9990(%edx),%edx
8010057d:	88 54 35 d8          	mov    %dl,-0x28(%ebp,%esi,1)
  }while((x /= base) != 0);
80100581:	89 c2                	mov    %eax,%edx
80100583:	85 c0                	test   %eax,%eax
80100585:	75 e1                	jne    80100568 <printint+0x27>
  if(sign)
80100587:	85 c9                	test   %ecx,%ecx
80100589:	74 14                	je     8010059f <printint+0x5e>
    buf[i++] = '-';
8010058b:	c6 44 1d d8 2d       	movb   $0x2d,-0x28(%ebp,%ebx,1)
80100590:	8d 5e 02             	lea    0x2(%esi),%ebx
80100593:	eb 0a                	jmp    8010059f <printint+0x5e>
    consputc(buf[i]);
80100595:	0f be 44 1d d8       	movsbl -0x28(%ebp,%ebx,1),%eax
8010059a:	e8 47 ff ff ff       	call   801004e6 <consputc>
  while(--i >= 0)
8010059f:	83 eb 01             	sub    $0x1,%ebx
801005a2:	79 f1                	jns    80100595 <printint+0x54>
}
801005a4:	83 c4 1c             	add    $0x1c,%esp
801005a7:	5b                   	pop    %ebx
801005a8:	5e                   	pop    %esi
801005a9:	5f                   	pop    %edi
801005aa:	5d                   	pop    %ebp
801005ab:	c3                   	ret    

801005ac <consolewrite>:

int
consolewrite(struct inode *ip, char *buf, int n)
{
801005ac:	55                   	push   %ebp
801005ad:	89 e5                	mov    %esp,%ebp
801005af:	57                   	push   %edi
801005b0:	56                   	push   %esi
801005b1:	53                   	push   %ebx
801005b2:	83 ec 18             	sub    $0x18,%esp
801005b5:	8b 7d 0c             	mov    0xc(%ebp),%edi
801005b8:	8b 75 10             	mov    0x10(%ebp),%esi
  int i;

  iunlock(ip);
801005bb:	ff 75 08             	pushl  0x8(%ebp)
801005be:	e8 80 10 00 00       	call   80101643 <iunlock>
  acquire(&cons.lock);
801005c3:	c7 04 24 20 a5 10 80 	movl   $0x8010a520,(%esp)
801005ca:	e8 22 37 00 00       	call   80103cf1 <acquire>
  for(i = 0; i < n; i++)
801005cf:	83 c4 10             	add    $0x10,%esp
801005d2:	bb 00 00 00 00       	mov    $0x0,%ebx
801005d7:	eb 0c                	jmp    801005e5 <consolewrite+0x39>
    consputc(buf[i] & 0xff);
801005d9:	0f b6 04 1f          	movzbl (%edi,%ebx,1),%eax
801005dd:	e8 04 ff ff ff       	call   801004e6 <consputc>
  for(i = 0; i < n; i++)
801005e2:	83 c3 01             	add    $0x1,%ebx
801005e5:	39 f3                	cmp    %esi,%ebx
801005e7:	7c f0                	jl     801005d9 <consolewrite+0x2d>
  release(&cons.lock);
801005e9:	83 ec 0c             	sub    $0xc,%esp
801005ec:	68 20 a5 10 80       	push   $0x8010a520
801005f1:	e8 60 37 00 00       	call   80103d56 <release>
  ilock(ip);
801005f6:	83 c4 04             	add    $0x4,%esp
801005f9:	ff 75 08             	pushl  0x8(%ebp)
801005fc:	e8 80 0f 00 00       	call   80101581 <ilock>

  return n;
}
80100601:	89 f0                	mov    %esi,%eax
80100603:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100606:	5b                   	pop    %ebx
80100607:	5e                   	pop    %esi
80100608:	5f                   	pop    %edi
80100609:	5d                   	pop    %ebp
8010060a:	c3                   	ret    

8010060b <cprintf>:
{
8010060b:	55                   	push   %ebp
8010060c:	89 e5                	mov    %esp,%ebp
8010060e:	57                   	push   %edi
8010060f:	56                   	push   %esi
80100610:	53                   	push   %ebx
80100611:	83 ec 1c             	sub    $0x1c,%esp
  locking = cons.locking;
80100614:	a1 54 a5 10 80       	mov    0x8010a554,%eax
80100619:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  if(locking)
8010061c:	85 c0                	test   %eax,%eax
8010061e:	75 10                	jne    80100630 <cprintf+0x25>
  if (fmt == 0)
80100620:	83 7d 08 00          	cmpl   $0x0,0x8(%ebp)
80100624:	74 1c                	je     80100642 <cprintf+0x37>
  argp = (uint*)(void*)(&fmt + 1);
80100626:	8d 7d 0c             	lea    0xc(%ebp),%edi
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100629:	bb 00 00 00 00       	mov    $0x0,%ebx
8010062e:	eb 27                	jmp    80100657 <cprintf+0x4c>
    acquire(&cons.lock);
80100630:	83 ec 0c             	sub    $0xc,%esp
80100633:	68 20 a5 10 80       	push   $0x8010a520
80100638:	e8 b4 36 00 00       	call   80103cf1 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 5f 66 10 80       	push   $0x8010665f
8010064a:	e8 f9 fc ff ff       	call   80100348 <panic>
      consputc(c);
8010064f:	e8 92 fe ff ff       	call   801004e6 <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
80100654:	83 c3 01             	add    $0x1,%ebx
80100657:	8b 55 08             	mov    0x8(%ebp),%edx
8010065a:	0f b6 04 1a          	movzbl (%edx,%ebx,1),%eax
8010065e:	85 c0                	test   %eax,%eax
80100660:	0f 84 b8 00 00 00    	je     8010071e <cprintf+0x113>
    if(c != '%'){
80100666:	83 f8 25             	cmp    $0x25,%eax
80100669:	75 e4                	jne    8010064f <cprintf+0x44>
    c = fmt[++i] & 0xff;
8010066b:	83 c3 01             	add    $0x1,%ebx
8010066e:	0f b6 34 1a          	movzbl (%edx,%ebx,1),%esi
    if(c == 0)
80100672:	85 f6                	test   %esi,%esi
80100674:	0f 84 a4 00 00 00    	je     8010071e <cprintf+0x113>
    switch(c){
8010067a:	83 fe 70             	cmp    $0x70,%esi
8010067d:	74 48                	je     801006c7 <cprintf+0xbc>
8010067f:	83 fe 70             	cmp    $0x70,%esi
80100682:	7f 26                	jg     801006aa <cprintf+0x9f>
80100684:	83 fe 25             	cmp    $0x25,%esi
80100687:	0f 84 82 00 00 00    	je     8010070f <cprintf+0x104>
8010068d:	83 fe 64             	cmp    $0x64,%esi
80100690:	75 22                	jne    801006b4 <cprintf+0xa9>
      printint(*argp++, 10, 1);
80100692:	8d 77 04             	lea    0x4(%edi),%esi
80100695:	8b 07                	mov    (%edi),%eax
80100697:	b9 01 00 00 00       	mov    $0x1,%ecx
8010069c:	ba 0a 00 00 00       	mov    $0xa,%edx
801006a1:	e8 9b fe ff ff       	call   80100541 <printint>
801006a6:	89 f7                	mov    %esi,%edi
      break;
801006a8:	eb aa                	jmp    80100654 <cprintf+0x49>
    switch(c){
801006aa:	83 fe 73             	cmp    $0x73,%esi
801006ad:	74 33                	je     801006e2 <cprintf+0xd7>
801006af:	83 fe 78             	cmp    $0x78,%esi
801006b2:	74 13                	je     801006c7 <cprintf+0xbc>
      consputc('%');
801006b4:	b8 25 00 00 00       	mov    $0x25,%eax
801006b9:	e8 28 fe ff ff       	call   801004e6 <consputc>
      consputc(c);
801006be:	89 f0                	mov    %esi,%eax
801006c0:	e8 21 fe ff ff       	call   801004e6 <consputc>
      break;
801006c5:	eb 8d                	jmp    80100654 <cprintf+0x49>
      printint(*argp++, 16, 0);
801006c7:	8d 77 04             	lea    0x4(%edi),%esi
801006ca:	8b 07                	mov    (%edi),%eax
801006cc:	b9 00 00 00 00       	mov    $0x0,%ecx
801006d1:	ba 10 00 00 00       	mov    $0x10,%edx
801006d6:	e8 66 fe ff ff       	call   80100541 <printint>
801006db:	89 f7                	mov    %esi,%edi
      break;
801006dd:	e9 72 ff ff ff       	jmp    80100654 <cprintf+0x49>
      if((s = (char*)*argp++) == 0)
801006e2:	8d 47 04             	lea    0x4(%edi),%eax
801006e5:	89 45 e0             	mov    %eax,-0x20(%ebp)
801006e8:	8b 37                	mov    (%edi),%esi
801006ea:	85 f6                	test   %esi,%esi
801006ec:	75 12                	jne    80100700 <cprintf+0xf5>
        s = "(null)";
801006ee:	be 58 66 10 80       	mov    $0x80106658,%esi
801006f3:	eb 0b                	jmp    80100700 <cprintf+0xf5>
        consputc(*s);
801006f5:	0f be c0             	movsbl %al,%eax
801006f8:	e8 e9 fd ff ff       	call   801004e6 <consputc>
      for(; *s; s++)
801006fd:	83 c6 01             	add    $0x1,%esi
80100700:	0f b6 06             	movzbl (%esi),%eax
80100703:	84 c0                	test   %al,%al
80100705:	75 ee                	jne    801006f5 <cprintf+0xea>
      if((s = (char*)*argp++) == 0)
80100707:	8b 7d e0             	mov    -0x20(%ebp),%edi
8010070a:	e9 45 ff ff ff       	jmp    80100654 <cprintf+0x49>
      consputc('%');
8010070f:	b8 25 00 00 00       	mov    $0x25,%eax
80100714:	e8 cd fd ff ff       	call   801004e6 <consputc>
      break;
80100719:	e9 36 ff ff ff       	jmp    80100654 <cprintf+0x49>
  if(locking)
8010071e:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80100722:	75 08                	jne    8010072c <cprintf+0x121>
}
80100724:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100727:	5b                   	pop    %ebx
80100728:	5e                   	pop    %esi
80100729:	5f                   	pop    %edi
8010072a:	5d                   	pop    %ebp
8010072b:	c3                   	ret    
    release(&cons.lock);
8010072c:	83 ec 0c             	sub    $0xc,%esp
8010072f:	68 20 a5 10 80       	push   $0x8010a520
80100734:	e8 1d 36 00 00       	call   80103d56 <release>
80100739:	83 c4 10             	add    $0x10,%esp
}
8010073c:	eb e6                	jmp    80100724 <cprintf+0x119>

8010073e <consoleintr>:
{
8010073e:	55                   	push   %ebp
8010073f:	89 e5                	mov    %esp,%ebp
80100741:	57                   	push   %edi
80100742:	56                   	push   %esi
80100743:	53                   	push   %ebx
80100744:	83 ec 18             	sub    $0x18,%esp
80100747:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&cons.lock);
8010074a:	68 20 a5 10 80       	push   $0x8010a520
8010074f:	e8 9d 35 00 00       	call   80103cf1 <acquire>
  while((c = getc()) >= 0){
80100754:	83 c4 10             	add    $0x10,%esp
  int c, doprocdump = 0;
80100757:	be 00 00 00 00       	mov    $0x0,%esi
  while((c = getc()) >= 0){
8010075c:	e9 c5 00 00 00       	jmp    80100826 <consoleintr+0xe8>
    switch(c){
80100761:	83 ff 08             	cmp    $0x8,%edi
80100764:	0f 84 e0 00 00 00    	je     8010084a <consoleintr+0x10c>
      if(c != 0 && input.e-input.r < INPUT_BUF){
8010076a:	85 ff                	test   %edi,%edi
8010076c:	0f 84 b4 00 00 00    	je     80100826 <consoleintr+0xe8>
80100772:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 c0 ff 10 80    	sub    0x8010ffc0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 c8 ff 10 80    	mov    %edx,0x8010ffc8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 40 ff 10 80    	mov    %cl,-0x7fef00c0(%eax)
        consputc(c);
801007a5:	89 f8                	mov    %edi,%eax
801007a7:	e8 3a fd ff ff       	call   801004e6 <consputc>
        if(c == '\n' || c == C('D') || input.e == input.r+INPUT_BUF){
801007ac:	83 ff 0a             	cmp    $0xa,%edi
801007af:	0f 94 c2             	sete   %dl
801007b2:	83 ff 04             	cmp    $0x4,%edi
801007b5:	0f 94 c0             	sete   %al
801007b8:	08 c2                	or     %al,%dl
801007ba:	75 10                	jne    801007cc <consoleintr+0x8e>
801007bc:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 c8 ff 10 80    	cmp    %eax,0x8010ffc8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
801007d1:	a3 c4 ff 10 80       	mov    %eax,0x8010ffc4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 c0 ff 10 80       	push   $0x8010ffc0
801007de:	e8 78 31 00 00       	call   8010395b <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 c8 ff 10 80       	mov    %eax,0x8010ffc8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
801007fc:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 40 ff 10 80 0a 	cmpb   $0xa,-0x7fef00c0(%edx)
80100813:	75 d3                	jne    801007e8 <consoleintr+0xaa>
80100815:	eb 0f                	jmp    80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100817:	bf 0a 00 00 00       	mov    $0xa,%edi
8010081c:	e9 70 ff ff ff       	jmp    80100791 <consoleintr+0x53>
      doprocdump = 1;
80100821:	be 01 00 00 00       	mov    $0x1,%esi
  while((c = getc()) >= 0){
80100826:	ff d3                	call   *%ebx
80100828:	89 c7                	mov    %eax,%edi
8010082a:	85 c0                	test   %eax,%eax
8010082c:	78 3d                	js     8010086b <consoleintr+0x12d>
    switch(c){
8010082e:	83 ff 10             	cmp    $0x10,%edi
80100831:	74 ee                	je     80100821 <consoleintr+0xe3>
80100833:	83 ff 10             	cmp    $0x10,%edi
80100836:	0f 8e 25 ff ff ff    	jle    80100761 <consoleintr+0x23>
8010083c:	83 ff 15             	cmp    $0x15,%edi
8010083f:	74 b6                	je     801007f7 <consoleintr+0xb9>
80100841:	83 ff 7f             	cmp    $0x7f,%edi
80100844:	0f 85 20 ff ff ff    	jne    8010076a <consoleintr+0x2c>
      if(input.e != input.w){
8010084a:	a1 c8 ff 10 80       	mov    0x8010ffc8,%eax
8010084f:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 c8 ff 10 80       	mov    %eax,0x8010ffc8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 a5 10 80       	push   $0x8010a520
80100873:	e8 de 34 00 00       	call   80103d56 <release>
  if(doprocdump) {
80100878:	83 c4 10             	add    $0x10,%esp
8010087b:	85 f6                	test   %esi,%esi
8010087d:	75 08                	jne    80100887 <consoleintr+0x149>
}
8010087f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100882:	5b                   	pop    %ebx
80100883:	5e                   	pop    %esi
80100884:	5f                   	pop    %edi
80100885:	5d                   	pop    %ebp
80100886:	c3                   	ret    
    procdump();  // now call procdump() wo. cons.lock held
80100887:	e8 6c 31 00 00       	call   801039f8 <procdump>
}
8010088c:	eb f1                	jmp    8010087f <consoleintr+0x141>

8010088e <consoleinit>:

void
consoleinit(void)
{
8010088e:	55                   	push   %ebp
8010088f:	89 e5                	mov    %esp,%ebp
80100891:	83 ec 10             	sub    $0x10,%esp
  initlock(&cons.lock, "console");
80100894:	68 68 66 10 80       	push   $0x80106668
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 12 33 00 00       	call   80103bb5 <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 8c 09 11 80 ac 	movl   $0x801005ac,0x8011098c
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 88 09 11 80 68 	movl   $0x80100268,0x80110988
801008b4:	02 10 80 
  cons.locking = 1;
801008b7:	c7 05 54 a5 10 80 01 	movl   $0x1,0x8010a554
801008be:	00 00 00 

  ioapicenable(IRQ_KBD, 0);
801008c1:	83 c4 08             	add    $0x8,%esp
801008c4:	6a 00                	push   $0x0
801008c6:	6a 01                	push   $0x1
801008c8:	e8 b1 16 00 00       	call   80101f7e <ioapicenable>
}
801008cd:	83 c4 10             	add    $0x10,%esp
801008d0:	c9                   	leave  
801008d1:	c3                   	ret    

801008d2 <exec>:
#include "x86.h"
#include "elf.h"

int
exec(char *path, char **argv)
{
801008d2:	55                   	push   %ebp
801008d3:	89 e5                	mov    %esp,%ebp
801008d5:	57                   	push   %edi
801008d6:	56                   	push   %esi
801008d7:	53                   	push   %ebx
801008d8:	81 ec 0c 01 00 00    	sub    $0x10c,%esp
  uint argc, sz, sp, ustack[3+MAXARG+1];
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pde_t *pgdir, *oldpgdir;
  struct proc *curproc = myproc();
801008de:	e8 6f 2a 00 00       	call   80103352 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 1c 20 00 00       	call   8010290a <begin_op>

  if((ip = namei(path)) == 0){
801008ee:	83 ec 0c             	sub    $0xc,%esp
801008f1:	ff 75 08             	pushl  0x8(%ebp)
801008f4:	e8 e8 12 00 00       	call   80101be1 <namei>
801008f9:	83 c4 10             	add    $0x10,%esp
801008fc:	85 c0                	test   %eax,%eax
801008fe:	74 4a                	je     8010094a <exec+0x78>
80100900:	89 c3                	mov    %eax,%ebx
    end_op();
    cprintf("exec: fail\n");
    return -1;
  }
  ilock(ip);
80100902:	83 ec 0c             	sub    $0xc,%esp
80100905:	50                   	push   %eax
80100906:	e8 76 0c 00 00       	call   80101581 <ilock>
  pgdir = 0;

  // Check ELF header
  if(readi(ip, (char*)&elf, 0, sizeof(elf)) != sizeof(elf))
8010090b:	6a 34                	push   $0x34
8010090d:	6a 00                	push   $0x0
8010090f:	8d 85 24 ff ff ff    	lea    -0xdc(%ebp),%eax
80100915:	50                   	push   %eax
80100916:	53                   	push   %ebx
80100917:	e8 57 0e 00 00       	call   80101773 <readi>
8010091c:	83 c4 20             	add    $0x20,%esp
8010091f:	83 f8 34             	cmp    $0x34,%eax
80100922:	74 42                	je     80100966 <exec+0x94>
  return 0;

 bad:
  if(pgdir)
    freevm(pgdir);
  if(ip){
80100924:	85 db                	test   %ebx,%ebx
80100926:	0f 84 dd 02 00 00    	je     80100c09 <exec+0x337>
    iunlockput(ip);
8010092c:	83 ec 0c             	sub    $0xc,%esp
8010092f:	53                   	push   %ebx
80100930:	e8 f3 0d 00 00       	call   80101728 <iunlockput>
    end_op();
80100935:	e8 4a 20 00 00       	call   80102984 <end_op>
8010093a:	83 c4 10             	add    $0x10,%esp
  }
  return -1;
8010093d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80100942:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100945:	5b                   	pop    %ebx
80100946:	5e                   	pop    %esi
80100947:	5f                   	pop    %edi
80100948:	5d                   	pop    %ebp
80100949:	c3                   	ret    
    end_op();
8010094a:	e8 35 20 00 00       	call   80102984 <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 81 66 10 80       	push   $0x80106681
80100957:	e8 af fc ff ff       	call   8010060b <cprintf>
    return -1;
8010095c:	83 c4 10             	add    $0x10,%esp
8010095f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100964:	eb dc                	jmp    80100942 <exec+0x70>
  if(elf.magic != ELF_MAGIC)
80100966:	81 bd 24 ff ff ff 7f 	cmpl   $0x464c457f,-0xdc(%ebp)
8010096d:	45 4c 46 
80100970:	75 b2                	jne    80100924 <exec+0x52>
  if((pgdir = setupkvm()) == 0)
80100972:	e8 20 5a 00 00       	call   80106397 <setupkvm>
80100977:	89 85 ec fe ff ff    	mov    %eax,-0x114(%ebp)
8010097d:	85 c0                	test   %eax,%eax
8010097f:	0f 84 06 01 00 00    	je     80100a8b <exec+0x1b9>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100985:	8b 85 40 ff ff ff    	mov    -0xc0(%ebp),%eax
  sz = 0;
8010098b:	bf 00 00 00 00       	mov    $0x0,%edi
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
80100990:	be 00 00 00 00       	mov    $0x0,%esi
80100995:	eb 0c                	jmp    801009a3 <exec+0xd1>
80100997:	83 c6 01             	add    $0x1,%esi
8010099a:	8b 85 f0 fe ff ff    	mov    -0x110(%ebp),%eax
801009a0:	83 c0 20             	add    $0x20,%eax
801009a3:	0f b7 95 50 ff ff ff 	movzwl -0xb0(%ebp),%edx
801009aa:	39 f2                	cmp    %esi,%edx
801009ac:	0f 8e 98 00 00 00    	jle    80100a4a <exec+0x178>
    if(readi(ip, (char*)&ph, off, sizeof(ph)) != sizeof(ph))
801009b2:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
801009b8:	6a 20                	push   $0x20
801009ba:	50                   	push   %eax
801009bb:	8d 85 04 ff ff ff    	lea    -0xfc(%ebp),%eax
801009c1:	50                   	push   %eax
801009c2:	53                   	push   %ebx
801009c3:	e8 ab 0d 00 00       	call   80101773 <readi>
801009c8:	83 c4 10             	add    $0x10,%esp
801009cb:	83 f8 20             	cmp    $0x20,%eax
801009ce:	0f 85 b7 00 00 00    	jne    80100a8b <exec+0x1b9>
    if(ph.type != ELF_PROG_LOAD)
801009d4:	83 bd 04 ff ff ff 01 	cmpl   $0x1,-0xfc(%ebp)
801009db:	75 ba                	jne    80100997 <exec+0xc5>
    if(ph.memsz < ph.filesz)
801009dd:	8b 85 18 ff ff ff    	mov    -0xe8(%ebp),%eax
801009e3:	3b 85 14 ff ff ff    	cmp    -0xec(%ebp),%eax
801009e9:	0f 82 9c 00 00 00    	jb     80100a8b <exec+0x1b9>
    if(ph.vaddr + ph.memsz < ph.vaddr)
801009ef:	03 85 0c ff ff ff    	add    -0xf4(%ebp),%eax
801009f5:	0f 82 90 00 00 00    	jb     80100a8b <exec+0x1b9>
    if((sz = allocuvm(pgdir, sz, ph.vaddr + ph.memsz)) == 0)
801009fb:	83 ec 04             	sub    $0x4,%esp
801009fe:	50                   	push   %eax
801009ff:	57                   	push   %edi
80100a00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a06:	e8 32 58 00 00       	call   8010623d <allocuvm>
80100a0b:	89 c7                	mov    %eax,%edi
80100a0d:	83 c4 10             	add    $0x10,%esp
80100a10:	85 c0                	test   %eax,%eax
80100a12:	74 77                	je     80100a8b <exec+0x1b9>
    if(ph.vaddr % PGSIZE != 0)
80100a14:	8b 85 0c ff ff ff    	mov    -0xf4(%ebp),%eax
80100a1a:	a9 ff 0f 00 00       	test   $0xfff,%eax
80100a1f:	75 6a                	jne    80100a8b <exec+0x1b9>
    if(loaduvm(pgdir, (char*)ph.vaddr, ip, ph.off, ph.filesz) < 0)
80100a21:	83 ec 0c             	sub    $0xc,%esp
80100a24:	ff b5 14 ff ff ff    	pushl  -0xec(%ebp)
80100a2a:	ff b5 08 ff ff ff    	pushl  -0xf8(%ebp)
80100a30:	53                   	push   %ebx
80100a31:	50                   	push   %eax
80100a32:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a38:	e8 ce 56 00 00       	call   8010610b <loaduvm>
80100a3d:	83 c4 20             	add    $0x20,%esp
80100a40:	85 c0                	test   %eax,%eax
80100a42:	0f 89 4f ff ff ff    	jns    80100997 <exec+0xc5>
 bad:
80100a48:	eb 41                	jmp    80100a8b <exec+0x1b9>
  iunlockput(ip);
80100a4a:	83 ec 0c             	sub    $0xc,%esp
80100a4d:	53                   	push   %ebx
80100a4e:	e8 d5 0c 00 00       	call   80101728 <iunlockput>
  end_op();
80100a53:	e8 2c 1f 00 00       	call   80102984 <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 c4 57 00 00       	call   8010623d <allocuvm>
80100a79:	89 85 f0 fe ff ff    	mov    %eax,-0x110(%ebp)
80100a7f:	83 c4 10             	add    $0x10,%esp
80100a82:	85 c0                	test   %eax,%eax
80100a84:	75 24                	jne    80100aaa <exec+0x1d8>
  ip = 0;
80100a86:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(pgdir)
80100a8b:	8b 85 ec fe ff ff    	mov    -0x114(%ebp),%eax
80100a91:	85 c0                	test   %eax,%eax
80100a93:	0f 84 8b fe ff ff    	je     80100924 <exec+0x52>
    freevm(pgdir);
80100a99:	83 ec 0c             	sub    $0xc,%esp
80100a9c:	50                   	push   %eax
80100a9d:	e8 85 58 00 00       	call   80106327 <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 5b 59 00 00       	call   8010641c <clearpteu>
  for(argc = 0; argv[argc]; argc++) {
80100ac1:	83 c4 10             	add    $0x10,%esp
80100ac4:	bb 00 00 00 00       	mov    $0x0,%ebx
80100ac9:	8b 45 0c             	mov    0xc(%ebp),%eax
80100acc:	8d 34 98             	lea    (%eax,%ebx,4),%esi
80100acf:	8b 06                	mov    (%esi),%eax
80100ad1:	85 c0                	test   %eax,%eax
80100ad3:	74 4d                	je     80100b22 <exec+0x250>
    if(argc >= MAXARG)
80100ad5:	83 fb 1f             	cmp    $0x1f,%ebx
80100ad8:	0f 87 0d 01 00 00    	ja     80100beb <exec+0x319>
    sp = (sp - (strlen(argv[argc]) + 1)) & ~3;
80100ade:	83 ec 0c             	sub    $0xc,%esp
80100ae1:	50                   	push   %eax
80100ae2:	e8 58 34 00 00       	call   80103f3f <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 46 34 00 00       	call   80103f3f <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 5f 5a 00 00       	call   8010656a <copyout>
80100b0b:	83 c4 20             	add    $0x20,%esp
80100b0e:	85 c0                	test   %eax,%eax
80100b10:	0f 88 df 00 00 00    	js     80100bf5 <exec+0x323>
    ustack[3+argc] = sp;
80100b16:	89 bc 9d 64 ff ff ff 	mov    %edi,-0x9c(%ebp,%ebx,4)
  for(argc = 0; argv[argc]; argc++) {
80100b1d:	83 c3 01             	add    $0x1,%ebx
80100b20:	eb a7                	jmp    80100ac9 <exec+0x1f7>
  ustack[3+argc] = 0;
80100b22:	c7 84 9d 64 ff ff ff 	movl   $0x0,-0x9c(%ebp,%ebx,4)
80100b29:	00 00 00 00 
  ustack[0] = 0xffffffff;  // fake return PC
80100b2d:	c7 85 58 ff ff ff ff 	movl   $0xffffffff,-0xa8(%ebp)
80100b34:	ff ff ff 
  ustack[1] = argc;
80100b37:	89 9d 5c ff ff ff    	mov    %ebx,-0xa4(%ebp)
  ustack[2] = sp - (argc+1)*4;  // argv pointer
80100b3d:	8d 04 9d 04 00 00 00 	lea    0x4(,%ebx,4),%eax
80100b44:	89 f9                	mov    %edi,%ecx
80100b46:	29 c1                	sub    %eax,%ecx
80100b48:	89 8d 60 ff ff ff    	mov    %ecx,-0xa0(%ebp)
  sp -= (3+argc+1) * 4;
80100b4e:	8d 04 9d 10 00 00 00 	lea    0x10(,%ebx,4),%eax
80100b55:	29 c7                	sub    %eax,%edi
  if(copyout(pgdir, sp, ustack, (3+argc+1)*4) < 0)
80100b57:	50                   	push   %eax
80100b58:	8d 85 58 ff ff ff    	lea    -0xa8(%ebp),%eax
80100b5e:	50                   	push   %eax
80100b5f:	57                   	push   %edi
80100b60:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b66:	e8 ff 59 00 00       	call   8010656a <copyout>
80100b6b:	83 c4 10             	add    $0x10,%esp
80100b6e:	85 c0                	test   %eax,%eax
80100b70:	0f 88 89 00 00 00    	js     80100bff <exec+0x32d>
  for(last=s=path; *s; s++)
80100b76:	8b 55 08             	mov    0x8(%ebp),%edx
80100b79:	89 d0                	mov    %edx,%eax
80100b7b:	eb 03                	jmp    80100b80 <exec+0x2ae>
80100b7d:	83 c0 01             	add    $0x1,%eax
80100b80:	0f b6 08             	movzbl (%eax),%ecx
80100b83:	84 c9                	test   %cl,%cl
80100b85:	74 0a                	je     80100b91 <exec+0x2bf>
    if(*s == '/')
80100b87:	80 f9 2f             	cmp    $0x2f,%cl
80100b8a:	75 f1                	jne    80100b7d <exec+0x2ab>
      last = s+1;
80100b8c:	8d 50 01             	lea    0x1(%eax),%edx
80100b8f:	eb ec                	jmp    80100b7d <exec+0x2ab>
  safestrcpy(curproc->name, last, sizeof(curproc->name));
80100b91:	8b b5 f4 fe ff ff    	mov    -0x10c(%ebp),%esi
80100b97:	89 f0                	mov    %esi,%eax
80100b99:	83 c0 6c             	add    $0x6c,%eax
80100b9c:	83 ec 04             	sub    $0x4,%esp
80100b9f:	6a 10                	push   $0x10
80100ba1:	52                   	push   %edx
80100ba2:	50                   	push   %eax
80100ba3:	e8 5c 33 00 00       	call   80103f04 <safestrcpy>
  oldpgdir = curproc->pgdir;
80100ba8:	8b 5e 04             	mov    0x4(%esi),%ebx
  curproc->pgdir = pgdir;
80100bab:	8b 8d ec fe ff ff    	mov    -0x114(%ebp),%ecx
80100bb1:	89 4e 04             	mov    %ecx,0x4(%esi)
  curproc->sz = sz;
80100bb4:	8b 8d f0 fe ff ff    	mov    -0x110(%ebp),%ecx
80100bba:	89 0e                	mov    %ecx,(%esi)
  curproc->tf->eip = elf.entry;  // main
80100bbc:	8b 46 18             	mov    0x18(%esi),%eax
80100bbf:	8b 95 3c ff ff ff    	mov    -0xc4(%ebp),%edx
80100bc5:	89 50 38             	mov    %edx,0x38(%eax)
  curproc->tf->esp = sp;
80100bc8:	8b 46 18             	mov    0x18(%esi),%eax
80100bcb:	89 78 44             	mov    %edi,0x44(%eax)
  switchuvm(curproc);
80100bce:	89 34 24             	mov    %esi,(%esp)
80100bd1:	e8 b4 53 00 00       	call   80105f8a <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 49 57 00 00       	call   80106327 <freevm>
  return 0;
80100bde:	83 c4 10             	add    $0x10,%esp
80100be1:	b8 00 00 00 00       	mov    $0x0,%eax
80100be6:	e9 57 fd ff ff       	jmp    80100942 <exec+0x70>
  ip = 0;
80100beb:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bf0:	e9 96 fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bf5:	bb 00 00 00 00       	mov    $0x0,%ebx
80100bfa:	e9 8c fe ff ff       	jmp    80100a8b <exec+0x1b9>
80100bff:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c04:	e9 82 fe ff ff       	jmp    80100a8b <exec+0x1b9>
  return -1;
80100c09:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100c0e:	e9 2f fd ff ff       	jmp    80100942 <exec+0x70>

80100c13 <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
80100c13:	55                   	push   %ebp
80100c14:	89 e5                	mov    %esp,%ebp
80100c16:	83 ec 10             	sub    $0x10,%esp
  initlock(&ftable.lock, "ftable");
80100c19:	68 8d 66 10 80       	push   $0x8010668d
80100c1e:	68 e0 ff 10 80       	push   $0x8010ffe0
80100c23:	e8 8d 2f 00 00       	call   80103bb5 <initlock>
}
80100c28:	83 c4 10             	add    $0x10,%esp
80100c2b:	c9                   	leave  
80100c2c:	c3                   	ret    

80100c2d <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
80100c2d:	55                   	push   %ebp
80100c2e:	89 e5                	mov    %esp,%ebp
80100c30:	53                   	push   %ebx
80100c31:	83 ec 10             	sub    $0x10,%esp
  struct file *f;

  acquire(&ftable.lock);
80100c34:	68 e0 ff 10 80       	push   $0x8010ffe0
80100c39:	e8 b3 30 00 00       	call   80103cf1 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c3e:	83 c4 10             	add    $0x10,%esp
80100c41:	bb 14 00 11 80       	mov    $0x80110014,%ebx
80100c46:	81 fb 74 09 11 80    	cmp    $0x80110974,%ebx
80100c4c:	73 29                	jae    80100c77 <filealloc+0x4a>
    if(f->ref == 0){
80100c4e:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80100c52:	74 05                	je     80100c59 <filealloc+0x2c>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c54:	83 c3 18             	add    $0x18,%ebx
80100c57:	eb ed                	jmp    80100c46 <filealloc+0x19>
      f->ref = 1;
80100c59:	c7 43 04 01 00 00 00 	movl   $0x1,0x4(%ebx)
      release(&ftable.lock);
80100c60:	83 ec 0c             	sub    $0xc,%esp
80100c63:	68 e0 ff 10 80       	push   $0x8010ffe0
80100c68:	e8 e9 30 00 00       	call   80103d56 <release>
      return f;
80100c6d:	83 c4 10             	add    $0x10,%esp
    }
  }
  release(&ftable.lock);
  return 0;
}
80100c70:	89 d8                	mov    %ebx,%eax
80100c72:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100c75:	c9                   	leave  
80100c76:	c3                   	ret    
  release(&ftable.lock);
80100c77:	83 ec 0c             	sub    $0xc,%esp
80100c7a:	68 e0 ff 10 80       	push   $0x8010ffe0
80100c7f:	e8 d2 30 00 00       	call   80103d56 <release>
  return 0;
80100c84:	83 c4 10             	add    $0x10,%esp
80100c87:	bb 00 00 00 00       	mov    $0x0,%ebx
80100c8c:	eb e2                	jmp    80100c70 <filealloc+0x43>

80100c8e <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
80100c8e:	55                   	push   %ebp
80100c8f:	89 e5                	mov    %esp,%ebp
80100c91:	53                   	push   %ebx
80100c92:	83 ec 10             	sub    $0x10,%esp
80100c95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&ftable.lock);
80100c98:	68 e0 ff 10 80       	push   $0x8010ffe0
80100c9d:	e8 4f 30 00 00       	call   80103cf1 <acquire>
  if(f->ref < 1)
80100ca2:	8b 43 04             	mov    0x4(%ebx),%eax
80100ca5:	83 c4 10             	add    $0x10,%esp
80100ca8:	85 c0                	test   %eax,%eax
80100caa:	7e 1a                	jle    80100cc6 <filedup+0x38>
    panic("filedup");
  f->ref++;
80100cac:	83 c0 01             	add    $0x1,%eax
80100caf:	89 43 04             	mov    %eax,0x4(%ebx)
  release(&ftable.lock);
80100cb2:	83 ec 0c             	sub    $0xc,%esp
80100cb5:	68 e0 ff 10 80       	push   $0x8010ffe0
80100cba:	e8 97 30 00 00       	call   80103d56 <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 94 66 10 80       	push   $0x80106694
80100cce:	e8 75 f6 ff ff       	call   80100348 <panic>

80100cd3 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
80100cd3:	55                   	push   %ebp
80100cd4:	89 e5                	mov    %esp,%ebp
80100cd6:	53                   	push   %ebx
80100cd7:	83 ec 30             	sub    $0x30,%esp
80100cda:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct file ff;

  acquire(&ftable.lock);
80100cdd:	68 e0 ff 10 80       	push   $0x8010ffe0
80100ce2:	e8 0a 30 00 00       	call   80103cf1 <acquire>
  if(f->ref < 1)
80100ce7:	8b 43 04             	mov    0x4(%ebx),%eax
80100cea:	83 c4 10             	add    $0x10,%esp
80100ced:	85 c0                	test   %eax,%eax
80100cef:	7e 1f                	jle    80100d10 <fileclose+0x3d>
    panic("fileclose");
  if(--f->ref > 0){
80100cf1:	83 e8 01             	sub    $0x1,%eax
80100cf4:	89 43 04             	mov    %eax,0x4(%ebx)
80100cf7:	85 c0                	test   %eax,%eax
80100cf9:	7e 22                	jle    80100d1d <fileclose+0x4a>
    release(&ftable.lock);
80100cfb:	83 ec 0c             	sub    $0xc,%esp
80100cfe:	68 e0 ff 10 80       	push   $0x8010ffe0
80100d03:	e8 4e 30 00 00       	call   80103d56 <release>
    return;
80100d08:	83 c4 10             	add    $0x10,%esp
  else if(ff.type == FD_INODE){
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
80100d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100d0e:	c9                   	leave  
80100d0f:	c3                   	ret    
    panic("fileclose");
80100d10:	83 ec 0c             	sub    $0xc,%esp
80100d13:	68 9c 66 10 80       	push   $0x8010669c
80100d18:	e8 2b f6 ff ff       	call   80100348 <panic>
  ff = *f;
80100d1d:	8b 03                	mov    (%ebx),%eax
80100d1f:	89 45 e0             	mov    %eax,-0x20(%ebp)
80100d22:	8b 43 08             	mov    0x8(%ebx),%eax
80100d25:	89 45 e8             	mov    %eax,-0x18(%ebp)
80100d28:	8b 43 0c             	mov    0xc(%ebx),%eax
80100d2b:	89 45 ec             	mov    %eax,-0x14(%ebp)
80100d2e:	8b 43 10             	mov    0x10(%ebx),%eax
80100d31:	89 45 f0             	mov    %eax,-0x10(%ebp)
  f->ref = 0;
80100d34:	c7 43 04 00 00 00 00 	movl   $0x0,0x4(%ebx)
  f->type = FD_NONE;
80100d3b:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  release(&ftable.lock);
80100d41:	83 ec 0c             	sub    $0xc,%esp
80100d44:	68 e0 ff 10 80       	push   $0x8010ffe0
80100d49:	e8 08 30 00 00       	call   80103d56 <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 a7 1b 00 00       	call   8010290a <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 11 1c 00 00       	call   80102984 <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 f6 21 00 00       	call   80102f7e <pipeclose>
80100d88:	83 c4 10             	add    $0x10,%esp
80100d8b:	e9 7b ff ff ff       	jmp    80100d0b <fileclose+0x38>

80100d90 <filestat>:

// Get metadata about file f.
int
filestat(struct file *f, struct stat *st)
{
80100d90:	55                   	push   %ebp
80100d91:	89 e5                	mov    %esp,%ebp
80100d93:	53                   	push   %ebx
80100d94:	83 ec 04             	sub    $0x4,%esp
80100d97:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(f->type == FD_INODE){
80100d9a:	83 3b 02             	cmpl   $0x2,(%ebx)
80100d9d:	75 31                	jne    80100dd0 <filestat+0x40>
    ilock(f->ip);
80100d9f:	83 ec 0c             	sub    $0xc,%esp
80100da2:	ff 73 10             	pushl  0x10(%ebx)
80100da5:	e8 d7 07 00 00       	call   80101581 <ilock>
    stati(f->ip, st);
80100daa:	83 c4 08             	add    $0x8,%esp
80100dad:	ff 75 0c             	pushl  0xc(%ebp)
80100db0:	ff 73 10             	pushl  0x10(%ebx)
80100db3:	e8 90 09 00 00       	call   80101748 <stati>
    iunlock(f->ip);
80100db8:	83 c4 04             	add    $0x4,%esp
80100dbb:	ff 73 10             	pushl  0x10(%ebx)
80100dbe:	e8 80 08 00 00       	call   80101643 <iunlock>
    return 0;
80100dc3:	83 c4 10             	add    $0x10,%esp
80100dc6:	b8 00 00 00 00       	mov    $0x0,%eax
  }
  return -1;
}
80100dcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100dce:	c9                   	leave  
80100dcf:	c3                   	ret    
  return -1;
80100dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100dd5:	eb f4                	jmp    80100dcb <filestat+0x3b>

80100dd7 <fileread>:

// Read from file f.
int
fileread(struct file *f, char *addr, int n)
{
80100dd7:	55                   	push   %ebp
80100dd8:	89 e5                	mov    %esp,%ebp
80100dda:	56                   	push   %esi
80100ddb:	53                   	push   %ebx
80100ddc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->readable == 0)
80100ddf:	80 7b 08 00          	cmpb   $0x0,0x8(%ebx)
80100de3:	74 70                	je     80100e55 <fileread+0x7e>
    return -1;
  if(f->type == FD_PIPE)
80100de5:	8b 03                	mov    (%ebx),%eax
80100de7:	83 f8 01             	cmp    $0x1,%eax
80100dea:	74 44                	je     80100e30 <fileread+0x59>
    return piperead(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100dec:	83 f8 02             	cmp    $0x2,%eax
80100def:	75 57                	jne    80100e48 <fileread+0x71>
    ilock(f->ip);
80100df1:	83 ec 0c             	sub    $0xc,%esp
80100df4:	ff 73 10             	pushl  0x10(%ebx)
80100df7:	e8 85 07 00 00       	call   80101581 <ilock>
    if((r = readi(f->ip, addr, f->off, n)) > 0)
80100dfc:	ff 75 10             	pushl  0x10(%ebp)
80100dff:	ff 73 14             	pushl  0x14(%ebx)
80100e02:	ff 75 0c             	pushl  0xc(%ebp)
80100e05:	ff 73 10             	pushl  0x10(%ebx)
80100e08:	e8 66 09 00 00       	call   80101773 <readi>
80100e0d:	89 c6                	mov    %eax,%esi
80100e0f:	83 c4 20             	add    $0x20,%esp
80100e12:	85 c0                	test   %eax,%eax
80100e14:	7e 03                	jle    80100e19 <fileread+0x42>
      f->off += r;
80100e16:	01 43 14             	add    %eax,0x14(%ebx)
    iunlock(f->ip);
80100e19:	83 ec 0c             	sub    $0xc,%esp
80100e1c:	ff 73 10             	pushl  0x10(%ebx)
80100e1f:	e8 1f 08 00 00       	call   80101643 <iunlock>
    return r;
80100e24:	83 c4 10             	add    $0x10,%esp
  }
  panic("fileread");
}
80100e27:	89 f0                	mov    %esi,%eax
80100e29:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100e2c:	5b                   	pop    %ebx
80100e2d:	5e                   	pop    %esi
80100e2e:	5d                   	pop    %ebp
80100e2f:	c3                   	ret    
    return piperead(f->pipe, addr, n);
80100e30:	83 ec 04             	sub    $0x4,%esp
80100e33:	ff 75 10             	pushl  0x10(%ebp)
80100e36:	ff 75 0c             	pushl  0xc(%ebp)
80100e39:	ff 73 0c             	pushl  0xc(%ebx)
80100e3c:	e8 95 22 00 00       	call   801030d6 <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 a6 66 10 80       	push   $0x801066a6
80100e50:	e8 f3 f4 ff ff       	call   80100348 <panic>
    return -1;
80100e55:	be ff ff ff ff       	mov    $0xffffffff,%esi
80100e5a:	eb cb                	jmp    80100e27 <fileread+0x50>

80100e5c <filewrite>:

// Write to file f.
int
filewrite(struct file *f, char *addr, int n)
{
80100e5c:	55                   	push   %ebp
80100e5d:	89 e5                	mov    %esp,%ebp
80100e5f:	57                   	push   %edi
80100e60:	56                   	push   %esi
80100e61:	53                   	push   %ebx
80100e62:	83 ec 1c             	sub    $0x1c,%esp
80100e65:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;

  if(f->writable == 0)
80100e68:	80 7b 09 00          	cmpb   $0x0,0x9(%ebx)
80100e6c:	0f 84 c5 00 00 00    	je     80100f37 <filewrite+0xdb>
    return -1;
  if(f->type == FD_PIPE)
80100e72:	8b 03                	mov    (%ebx),%eax
80100e74:	83 f8 01             	cmp    $0x1,%eax
80100e77:	74 10                	je     80100e89 <filewrite+0x2d>
    return pipewrite(f->pipe, addr, n);
  if(f->type == FD_INODE){
80100e79:	83 f8 02             	cmp    $0x2,%eax
80100e7c:	0f 85 a8 00 00 00    	jne    80100f2a <filewrite+0xce>
    // i-node, indirect block, allocation blocks,
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * 512;
    int i = 0;
80100e82:	bf 00 00 00 00       	mov    $0x0,%edi
80100e87:	eb 67                	jmp    80100ef0 <filewrite+0x94>
    return pipewrite(f->pipe, addr, n);
80100e89:	83 ec 04             	sub    $0x4,%esp
80100e8c:	ff 75 10             	pushl  0x10(%ebp)
80100e8f:	ff 75 0c             	pushl  0xc(%ebp)
80100e92:	ff 73 0c             	pushl  0xc(%ebx)
80100e95:	e8 70 21 00 00       	call   8010300a <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 63 1a 00 00       	call   8010290a <begin_op>
      ilock(f->ip);
80100ea7:	83 ec 0c             	sub    $0xc,%esp
80100eaa:	ff 73 10             	pushl  0x10(%ebx)
80100ead:	e8 cf 06 00 00       	call   80101581 <ilock>
      if ((r = writei(f->ip, addr + i, f->off, n1)) > 0)
80100eb2:	89 f8                	mov    %edi,%eax
80100eb4:	03 45 0c             	add    0xc(%ebp),%eax
80100eb7:	ff 75 e4             	pushl  -0x1c(%ebp)
80100eba:	ff 73 14             	pushl  0x14(%ebx)
80100ebd:	50                   	push   %eax
80100ebe:	ff 73 10             	pushl  0x10(%ebx)
80100ec1:	e8 aa 09 00 00       	call   80101870 <writei>
80100ec6:	89 c6                	mov    %eax,%esi
80100ec8:	83 c4 20             	add    $0x20,%esp
80100ecb:	85 c0                	test   %eax,%eax
80100ecd:	7e 03                	jle    80100ed2 <filewrite+0x76>
        f->off += r;
80100ecf:	01 43 14             	add    %eax,0x14(%ebx)
      iunlock(f->ip);
80100ed2:	83 ec 0c             	sub    $0xc,%esp
80100ed5:	ff 73 10             	pushl  0x10(%ebx)
80100ed8:	e8 66 07 00 00       	call   80101643 <iunlock>
      end_op();
80100edd:	e8 a2 1a 00 00       	call   80102984 <end_op>

      if(r < 0)
80100ee2:	83 c4 10             	add    $0x10,%esp
80100ee5:	85 f6                	test   %esi,%esi
80100ee7:	78 31                	js     80100f1a <filewrite+0xbe>
        break;
      if(r != n1)
80100ee9:	39 75 e4             	cmp    %esi,-0x1c(%ebp)
80100eec:	75 1f                	jne    80100f0d <filewrite+0xb1>
        panic("short filewrite");
      i += r;
80100eee:	01 f7                	add    %esi,%edi
    while(i < n){
80100ef0:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100ef3:	7d 25                	jge    80100f1a <filewrite+0xbe>
      int n1 = n - i;
80100ef5:	8b 45 10             	mov    0x10(%ebp),%eax
80100ef8:	29 f8                	sub    %edi,%eax
80100efa:	89 45 e4             	mov    %eax,-0x1c(%ebp)
      if(n1 > max)
80100efd:	3d 00 06 00 00       	cmp    $0x600,%eax
80100f02:	7e 9e                	jle    80100ea2 <filewrite+0x46>
        n1 = max;
80100f04:	c7 45 e4 00 06 00 00 	movl   $0x600,-0x1c(%ebp)
80100f0b:	eb 95                	jmp    80100ea2 <filewrite+0x46>
        panic("short filewrite");
80100f0d:	83 ec 0c             	sub    $0xc,%esp
80100f10:	68 af 66 10 80       	push   $0x801066af
80100f15:	e8 2e f4 ff ff       	call   80100348 <panic>
    }
    return i == n ? n : -1;
80100f1a:	3b 7d 10             	cmp    0x10(%ebp),%edi
80100f1d:	75 1f                	jne    80100f3e <filewrite+0xe2>
80100f1f:	8b 45 10             	mov    0x10(%ebp),%eax
  }
  panic("filewrite");
}
80100f22:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100f25:	5b                   	pop    %ebx
80100f26:	5e                   	pop    %esi
80100f27:	5f                   	pop    %edi
80100f28:	5d                   	pop    %ebp
80100f29:	c3                   	ret    
  panic("filewrite");
80100f2a:	83 ec 0c             	sub    $0xc,%esp
80100f2d:	68 b5 66 10 80       	push   $0x801066b5
80100f32:	e8 11 f4 ff ff       	call   80100348 <panic>
    return -1;
80100f37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f3c:	eb e4                	jmp    80100f22 <filewrite+0xc6>
    return i == n ? n : -1;
80100f3e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80100f43:	eb dd                	jmp    80100f22 <filewrite+0xc6>

80100f45 <skipelem>:
//   skipelem("a", name) = "", setting name = "a"
//   skipelem("", name) = skipelem("////", name) = 0
//
static char*
skipelem(char *path, char *name)
{
80100f45:	55                   	push   %ebp
80100f46:	89 e5                	mov    %esp,%ebp
80100f48:	57                   	push   %edi
80100f49:	56                   	push   %esi
80100f4a:	53                   	push   %ebx
80100f4b:	83 ec 0c             	sub    $0xc,%esp
80100f4e:	89 d7                	mov    %edx,%edi
  char *s;
  int len;

  while(*path == '/')
80100f50:	eb 03                	jmp    80100f55 <skipelem+0x10>
    path++;
80100f52:	83 c0 01             	add    $0x1,%eax
  while(*path == '/')
80100f55:	0f b6 10             	movzbl (%eax),%edx
80100f58:	80 fa 2f             	cmp    $0x2f,%dl
80100f5b:	74 f5                	je     80100f52 <skipelem+0xd>
  if(*path == 0)
80100f5d:	84 d2                	test   %dl,%dl
80100f5f:	74 59                	je     80100fba <skipelem+0x75>
80100f61:	89 c3                	mov    %eax,%ebx
80100f63:	eb 03                	jmp    80100f68 <skipelem+0x23>
    return 0;
  s = path;
  while(*path != '/' && *path != 0)
    path++;
80100f65:	83 c3 01             	add    $0x1,%ebx
  while(*path != '/' && *path != 0)
80100f68:	0f b6 13             	movzbl (%ebx),%edx
80100f6b:	80 fa 2f             	cmp    $0x2f,%dl
80100f6e:	0f 95 c1             	setne  %cl
80100f71:	84 d2                	test   %dl,%dl
80100f73:	0f 95 c2             	setne  %dl
80100f76:	84 d1                	test   %dl,%cl
80100f78:	75 eb                	jne    80100f65 <skipelem+0x20>
  len = path - s;
80100f7a:	89 de                	mov    %ebx,%esi
80100f7c:	29 c6                	sub    %eax,%esi
  if(len >= DIRSIZ)
80100f7e:	83 fe 0d             	cmp    $0xd,%esi
80100f81:	7e 11                	jle    80100f94 <skipelem+0x4f>
    memmove(name, s, DIRSIZ);
80100f83:	83 ec 04             	sub    $0x4,%esp
80100f86:	6a 0e                	push   $0xe
80100f88:	50                   	push   %eax
80100f89:	57                   	push   %edi
80100f8a:	e8 89 2e 00 00       	call   80103e18 <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 79 2e 00 00       	call   80103e18 <memmove>
    name[len] = 0;
80100f9f:	c6 04 37 00          	movb   $0x0,(%edi,%esi,1)
80100fa3:	83 c4 10             	add    $0x10,%esp
80100fa6:	eb 03                	jmp    80100fab <skipelem+0x66>
  }
  while(*path == '/')
    path++;
80100fa8:	83 c3 01             	add    $0x1,%ebx
  while(*path == '/')
80100fab:	80 3b 2f             	cmpb   $0x2f,(%ebx)
80100fae:	74 f8                	je     80100fa8 <skipelem+0x63>
  return path;
}
80100fb0:	89 d8                	mov    %ebx,%eax
80100fb2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80100fb5:	5b                   	pop    %ebx
80100fb6:	5e                   	pop    %esi
80100fb7:	5f                   	pop    %edi
80100fb8:	5d                   	pop    %ebp
80100fb9:	c3                   	ret    
    return 0;
80100fba:	bb 00 00 00 00       	mov    $0x0,%ebx
80100fbf:	eb ef                	jmp    80100fb0 <skipelem+0x6b>

80100fc1 <bzero>:
{
80100fc1:	55                   	push   %ebp
80100fc2:	89 e5                	mov    %esp,%ebp
80100fc4:	53                   	push   %ebx
80100fc5:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, bno);
80100fc8:	52                   	push   %edx
80100fc9:	50                   	push   %eax
80100fca:	e8 9d f1 ff ff       	call   8010016c <bread>
80100fcf:	89 c3                	mov    %eax,%ebx
  memset(bp->data, 0, BSIZE);
80100fd1:	8d 40 5c             	lea    0x5c(%eax),%eax
80100fd4:	83 c4 0c             	add    $0xc,%esp
80100fd7:	68 00 02 00 00       	push   $0x200
80100fdc:	6a 00                	push   $0x0
80100fde:	50                   	push   %eax
80100fdf:	e8 b9 2d 00 00       	call   80103d9d <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 47 1a 00 00       	call   80102a33 <log_write>
  brelse(bp);
80100fec:	89 1c 24             	mov    %ebx,(%esp)
80100fef:	e8 e1 f1 ff ff       	call   801001d5 <brelse>
}
80100ff4:	83 c4 10             	add    $0x10,%esp
80100ff7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100ffa:	c9                   	leave  
80100ffb:	c3                   	ret    

80100ffc <balloc>:
{
80100ffc:	55                   	push   %ebp
80100ffd:	89 e5                	mov    %esp,%ebp
80100fff:	57                   	push   %edi
80101000:	56                   	push   %esi
80101001:	53                   	push   %ebx
80101002:	83 ec 1c             	sub    $0x1c,%esp
80101005:	89 45 d8             	mov    %eax,-0x28(%ebp)
  for(b = 0; b < sb.size; b += BPB){
80101008:	be 00 00 00 00       	mov    $0x0,%esi
8010100d:	eb 14                	jmp    80101023 <balloc+0x27>
    brelse(bp);
8010100f:	83 ec 0c             	sub    $0xc,%esp
80101012:	ff 75 e4             	pushl  -0x1c(%ebp)
80101015:	e8 bb f1 ff ff       	call   801001d5 <brelse>
  for(b = 0; b < sb.size; b += BPB){
8010101a:	81 c6 00 10 00 00    	add    $0x1000,%esi
80101020:	83 c4 10             	add    $0x10,%esp
80101023:	39 35 e0 09 11 80    	cmp    %esi,0x801109e0
80101029:	76 75                	jbe    801010a0 <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
8010102b:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80101031:	85 f6                	test   %esi,%esi
80101033:	0f 49 c6             	cmovns %esi,%eax
80101036:	c1 f8 0c             	sar    $0xc,%eax
80101039:	03 05 f8 09 11 80    	add    0x801109f8,%eax
8010103f:	83 ec 08             	sub    $0x8,%esp
80101042:	50                   	push   %eax
80101043:	ff 75 d8             	pushl  -0x28(%ebp)
80101046:	e8 21 f1 ff ff       	call   8010016c <bread>
8010104b:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010104e:	83 c4 10             	add    $0x10,%esp
80101051:	b8 00 00 00 00       	mov    $0x0,%eax
80101056:	3d ff 0f 00 00       	cmp    $0xfff,%eax
8010105b:	7f b2                	jg     8010100f <balloc+0x13>
8010105d:	8d 1c 06             	lea    (%esi,%eax,1),%ebx
80101060:	89 5d e0             	mov    %ebx,-0x20(%ebp)
80101063:	3b 1d e0 09 11 80    	cmp    0x801109e0,%ebx
80101069:	73 a4                	jae    8010100f <balloc+0x13>
      m = 1 << (bi % 8);
8010106b:	99                   	cltd   
8010106c:	c1 ea 1d             	shr    $0x1d,%edx
8010106f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
80101072:	83 e1 07             	and    $0x7,%ecx
80101075:	29 d1                	sub    %edx,%ecx
80101077:	ba 01 00 00 00       	mov    $0x1,%edx
8010107c:	d3 e2                	shl    %cl,%edx
      if((bp->data[bi/8] & m) == 0){  // Is block free?
8010107e:	8d 48 07             	lea    0x7(%eax),%ecx
80101081:	85 c0                	test   %eax,%eax
80101083:	0f 49 c8             	cmovns %eax,%ecx
80101086:	c1 f9 03             	sar    $0x3,%ecx
80101089:	89 4d dc             	mov    %ecx,-0x24(%ebp)
8010108c:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010108f:	0f b6 4c 0f 5c       	movzbl 0x5c(%edi,%ecx,1),%ecx
80101094:	0f b6 f9             	movzbl %cl,%edi
80101097:	85 d7                	test   %edx,%edi
80101099:	74 12                	je     801010ad <balloc+0xb1>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
8010109b:	83 c0 01             	add    $0x1,%eax
8010109e:	eb b6                	jmp    80101056 <balloc+0x5a>
  panic("balloc: out of blocks");
801010a0:	83 ec 0c             	sub    $0xc,%esp
801010a3:	68 bf 66 10 80       	push   $0x801066bf
801010a8:	e8 9b f2 ff ff       	call   80100348 <panic>
        bp->data[bi/8] |= m;  // Mark block in use.
801010ad:	09 ca                	or     %ecx,%edx
801010af:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801010b2:	8b 75 dc             	mov    -0x24(%ebp),%esi
801010b5:	88 54 30 5c          	mov    %dl,0x5c(%eax,%esi,1)
        log_write(bp);
801010b9:	83 ec 0c             	sub    $0xc,%esp
801010bc:	89 c6                	mov    %eax,%esi
801010be:	50                   	push   %eax
801010bf:	e8 6f 19 00 00       	call   80102a33 <log_write>
        brelse(bp);
801010c4:	89 34 24             	mov    %esi,(%esp)
801010c7:	e8 09 f1 ff ff       	call   801001d5 <brelse>
        bzero(dev, b + bi);
801010cc:	89 da                	mov    %ebx,%edx
801010ce:	8b 45 d8             	mov    -0x28(%ebp),%eax
801010d1:	e8 eb fe ff ff       	call   80100fc1 <bzero>
}
801010d6:	8b 45 e0             	mov    -0x20(%ebp),%eax
801010d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801010dc:	5b                   	pop    %ebx
801010dd:	5e                   	pop    %esi
801010de:	5f                   	pop    %edi
801010df:	5d                   	pop    %ebp
801010e0:	c3                   	ret    

801010e1 <bmap>:
{
801010e1:	55                   	push   %ebp
801010e2:	89 e5                	mov    %esp,%ebp
801010e4:	57                   	push   %edi
801010e5:	56                   	push   %esi
801010e6:	53                   	push   %ebx
801010e7:	83 ec 1c             	sub    $0x1c,%esp
801010ea:	89 c6                	mov    %eax,%esi
801010ec:	89 d7                	mov    %edx,%edi
  if(bn < NDIRECT){
801010ee:	83 fa 0b             	cmp    $0xb,%edx
801010f1:	77 17                	ja     8010110a <bmap+0x29>
    if((addr = ip->addrs[bn]) == 0)
801010f3:	8b 5c 90 5c          	mov    0x5c(%eax,%edx,4),%ebx
801010f7:	85 db                	test   %ebx,%ebx
801010f9:	75 4a                	jne    80101145 <bmap+0x64>
      ip->addrs[bn] = addr = balloc(ip->dev);
801010fb:	8b 00                	mov    (%eax),%eax
801010fd:	e8 fa fe ff ff       	call   80100ffc <balloc>
80101102:	89 c3                	mov    %eax,%ebx
80101104:	89 44 be 5c          	mov    %eax,0x5c(%esi,%edi,4)
80101108:	eb 3b                	jmp    80101145 <bmap+0x64>
  bn -= NDIRECT;
8010110a:	8d 5a f4             	lea    -0xc(%edx),%ebx
  if(bn < NINDIRECT){
8010110d:	83 fb 7f             	cmp    $0x7f,%ebx
80101110:	77 68                	ja     8010117a <bmap+0x99>
    if((addr = ip->addrs[NDIRECT]) == 0)
80101112:	8b 80 8c 00 00 00    	mov    0x8c(%eax),%eax
80101118:	85 c0                	test   %eax,%eax
8010111a:	74 33                	je     8010114f <bmap+0x6e>
    bp = bread(ip->dev, addr);
8010111c:	83 ec 08             	sub    $0x8,%esp
8010111f:	50                   	push   %eax
80101120:	ff 36                	pushl  (%esi)
80101122:	e8 45 f0 ff ff       	call   8010016c <bread>
80101127:	89 c7                	mov    %eax,%edi
    if((addr = a[bn]) == 0){
80101129:	8d 44 98 5c          	lea    0x5c(%eax,%ebx,4),%eax
8010112d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80101130:	8b 18                	mov    (%eax),%ebx
80101132:	83 c4 10             	add    $0x10,%esp
80101135:	85 db                	test   %ebx,%ebx
80101137:	74 25                	je     8010115e <bmap+0x7d>
    brelse(bp);
80101139:	83 ec 0c             	sub    $0xc,%esp
8010113c:	57                   	push   %edi
8010113d:	e8 93 f0 ff ff       	call   801001d5 <brelse>
    return addr;
80101142:	83 c4 10             	add    $0x10,%esp
}
80101145:	89 d8                	mov    %ebx,%eax
80101147:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010114a:	5b                   	pop    %ebx
8010114b:	5e                   	pop    %esi
8010114c:	5f                   	pop    %edi
8010114d:	5d                   	pop    %ebp
8010114e:	c3                   	ret    
      ip->addrs[NDIRECT] = addr = balloc(ip->dev);
8010114f:	8b 06                	mov    (%esi),%eax
80101151:	e8 a6 fe ff ff       	call   80100ffc <balloc>
80101156:	89 86 8c 00 00 00    	mov    %eax,0x8c(%esi)
8010115c:	eb be                	jmp    8010111c <bmap+0x3b>
      a[bn] = addr = balloc(ip->dev);
8010115e:	8b 06                	mov    (%esi),%eax
80101160:	e8 97 fe ff ff       	call   80100ffc <balloc>
80101165:	89 c3                	mov    %eax,%ebx
80101167:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010116a:	89 18                	mov    %ebx,(%eax)
      log_write(bp);
8010116c:	83 ec 0c             	sub    $0xc,%esp
8010116f:	57                   	push   %edi
80101170:	e8 be 18 00 00       	call   80102a33 <log_write>
80101175:	83 c4 10             	add    $0x10,%esp
80101178:	eb bf                	jmp    80101139 <bmap+0x58>
  panic("bmap: out of range");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 d5 66 10 80       	push   $0x801066d5
80101182:	e8 c1 f1 ff ff       	call   80100348 <panic>

80101187 <iget>:
{
80101187:	55                   	push   %ebp
80101188:	89 e5                	mov    %esp,%ebp
8010118a:	57                   	push   %edi
8010118b:	56                   	push   %esi
8010118c:	53                   	push   %ebx
8010118d:	83 ec 28             	sub    $0x28,%esp
80101190:	89 c7                	mov    %eax,%edi
80101192:	89 55 e4             	mov    %edx,-0x1c(%ebp)
  acquire(&icache.lock);
80101195:	68 00 0a 11 80       	push   $0x80110a00
8010119a:	e8 52 2b 00 00       	call   80103cf1 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010119f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011a2:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011a7:	bb 34 0a 11 80       	mov    $0x80110a34,%ebx
801011ac:	eb 0a                	jmp    801011b8 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ae:	85 f6                	test   %esi,%esi
801011b0:	74 3b                	je     801011ed <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011b2:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011b8:	81 fb 54 26 11 80    	cmp    $0x80112654,%ebx
801011be:	73 35                	jae    801011f5 <iget+0x6e>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
801011c0:	8b 43 08             	mov    0x8(%ebx),%eax
801011c3:	85 c0                	test   %eax,%eax
801011c5:	7e e7                	jle    801011ae <iget+0x27>
801011c7:	39 3b                	cmp    %edi,(%ebx)
801011c9:	75 e3                	jne    801011ae <iget+0x27>
801011cb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801011ce:	39 4b 04             	cmp    %ecx,0x4(%ebx)
801011d1:	75 db                	jne    801011ae <iget+0x27>
      ip->ref++;
801011d3:	83 c0 01             	add    $0x1,%eax
801011d6:	89 43 08             	mov    %eax,0x8(%ebx)
      release(&icache.lock);
801011d9:	83 ec 0c             	sub    $0xc,%esp
801011dc:	68 00 0a 11 80       	push   $0x80110a00
801011e1:	e8 70 2b 00 00       	call   80103d56 <release>
      return ip;
801011e6:	83 c4 10             	add    $0x10,%esp
801011e9:	89 de                	mov    %ebx,%esi
801011eb:	eb 32                	jmp    8010121f <iget+0x98>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ed:	85 c0                	test   %eax,%eax
801011ef:	75 c1                	jne    801011b2 <iget+0x2b>
      empty = ip;
801011f1:	89 de                	mov    %ebx,%esi
801011f3:	eb bd                	jmp    801011b2 <iget+0x2b>
  if(empty == 0)
801011f5:	85 f6                	test   %esi,%esi
801011f7:	74 30                	je     80101229 <iget+0xa2>
  ip->dev = dev;
801011f9:	89 3e                	mov    %edi,(%esi)
  ip->inum = inum;
801011fb:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801011fe:	89 46 04             	mov    %eax,0x4(%esi)
  ip->ref = 1;
80101201:	c7 46 08 01 00 00 00 	movl   $0x1,0x8(%esi)
  ip->valid = 0;
80101208:	c7 46 4c 00 00 00 00 	movl   $0x0,0x4c(%esi)
  release(&icache.lock);
8010120f:	83 ec 0c             	sub    $0xc,%esp
80101212:	68 00 0a 11 80       	push   $0x80110a00
80101217:	e8 3a 2b 00 00       	call   80103d56 <release>
  return ip;
8010121c:	83 c4 10             	add    $0x10,%esp
}
8010121f:	89 f0                	mov    %esi,%eax
80101221:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101224:	5b                   	pop    %ebx
80101225:	5e                   	pop    %esi
80101226:	5f                   	pop    %edi
80101227:	5d                   	pop    %ebp
80101228:	c3                   	ret    
    panic("iget: no inodes");
80101229:	83 ec 0c             	sub    $0xc,%esp
8010122c:	68 e8 66 10 80       	push   $0x801066e8
80101231:	e8 12 f1 ff ff       	call   80100348 <panic>

80101236 <readsb>:
{
80101236:	55                   	push   %ebp
80101237:	89 e5                	mov    %esp,%ebp
80101239:	53                   	push   %ebx
8010123a:	83 ec 0c             	sub    $0xc,%esp
  bp = bread(dev, 1);
8010123d:	6a 01                	push   $0x1
8010123f:	ff 75 08             	pushl  0x8(%ebp)
80101242:	e8 25 ef ff ff       	call   8010016c <bread>
80101247:	89 c3                	mov    %eax,%ebx
  memmove(sb, bp->data, sizeof(*sb));
80101249:	8d 40 5c             	lea    0x5c(%eax),%eax
8010124c:	83 c4 0c             	add    $0xc,%esp
8010124f:	6a 1c                	push   $0x1c
80101251:	50                   	push   %eax
80101252:	ff 75 0c             	pushl  0xc(%ebp)
80101255:	e8 be 2b 00 00       	call   80103e18 <memmove>
  brelse(bp);
8010125a:	89 1c 24             	mov    %ebx,(%esp)
8010125d:	e8 73 ef ff ff       	call   801001d5 <brelse>
}
80101262:	83 c4 10             	add    $0x10,%esp
80101265:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101268:	c9                   	leave  
80101269:	c3                   	ret    

8010126a <bfree>:
{
8010126a:	55                   	push   %ebp
8010126b:	89 e5                	mov    %esp,%ebp
8010126d:	56                   	push   %esi
8010126e:	53                   	push   %ebx
8010126f:	89 c6                	mov    %eax,%esi
80101271:	89 d3                	mov    %edx,%ebx
  readsb(dev, &sb);
80101273:	83 ec 08             	sub    $0x8,%esp
80101276:	68 e0 09 11 80       	push   $0x801109e0
8010127b:	50                   	push   %eax
8010127c:	e8 b5 ff ff ff       	call   80101236 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101281:	89 d8                	mov    %ebx,%eax
80101283:	c1 e8 0c             	shr    $0xc,%eax
80101286:	03 05 f8 09 11 80    	add    0x801109f8,%eax
8010128c:	83 c4 08             	add    $0x8,%esp
8010128f:	50                   	push   %eax
80101290:	56                   	push   %esi
80101291:	e8 d6 ee ff ff       	call   8010016c <bread>
80101296:	89 c6                	mov    %eax,%esi
  m = 1 << (bi % 8);
80101298:	89 d9                	mov    %ebx,%ecx
8010129a:	83 e1 07             	and    $0x7,%ecx
8010129d:	b8 01 00 00 00       	mov    $0x1,%eax
801012a2:	d3 e0                	shl    %cl,%eax
  if((bp->data[bi/8] & m) == 0)
801012a4:	83 c4 10             	add    $0x10,%esp
801012a7:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801012ad:	c1 fb 03             	sar    $0x3,%ebx
801012b0:	0f b6 54 1e 5c       	movzbl 0x5c(%esi,%ebx,1),%edx
801012b5:	0f b6 ca             	movzbl %dl,%ecx
801012b8:	85 c1                	test   %eax,%ecx
801012ba:	74 23                	je     801012df <bfree+0x75>
  bp->data[bi/8] &= ~m;
801012bc:	f7 d0                	not    %eax
801012be:	21 d0                	and    %edx,%eax
801012c0:	88 44 1e 5c          	mov    %al,0x5c(%esi,%ebx,1)
  log_write(bp);
801012c4:	83 ec 0c             	sub    $0xc,%esp
801012c7:	56                   	push   %esi
801012c8:	e8 66 17 00 00       	call   80102a33 <log_write>
  brelse(bp);
801012cd:	89 34 24             	mov    %esi,(%esp)
801012d0:	e8 00 ef ff ff       	call   801001d5 <brelse>
}
801012d5:	83 c4 10             	add    $0x10,%esp
801012d8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801012db:	5b                   	pop    %ebx
801012dc:	5e                   	pop    %esi
801012dd:	5d                   	pop    %ebp
801012de:	c3                   	ret    
    panic("freeing free block");
801012df:	83 ec 0c             	sub    $0xc,%esp
801012e2:	68 f8 66 10 80       	push   $0x801066f8
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 0b 67 10 80       	push   $0x8010670b
801012f8:	68 00 0a 11 80       	push   $0x80110a00
801012fd:	e8 b3 28 00 00       	call   80103bb5 <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 12 67 10 80       	push   $0x80106712
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 40 0a 11 80       	add    $0x80110a40,%eax
80101321:	50                   	push   %eax
80101322:	e8 83 27 00 00       	call   80103aaa <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101327:	83 c3 01             	add    $0x1,%ebx
8010132a:	83 c4 10             	add    $0x10,%esp
8010132d:	83 fb 31             	cmp    $0x31,%ebx
80101330:	7e da                	jle    8010130c <iinit+0x20>
  readsb(dev, &sb);
80101332:	83 ec 08             	sub    $0x8,%esp
80101335:	68 e0 09 11 80       	push   $0x801109e0
8010133a:	ff 75 08             	pushl  0x8(%ebp)
8010133d:	e8 f4 fe ff ff       	call   80101236 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101342:	ff 35 f8 09 11 80    	pushl  0x801109f8
80101348:	ff 35 f4 09 11 80    	pushl  0x801109f4
8010134e:	ff 35 f0 09 11 80    	pushl  0x801109f0
80101354:	ff 35 ec 09 11 80    	pushl  0x801109ec
8010135a:	ff 35 e8 09 11 80    	pushl  0x801109e8
80101360:	ff 35 e4 09 11 80    	pushl  0x801109e4
80101366:	ff 35 e0 09 11 80    	pushl  0x801109e0
8010136c:	68 78 67 10 80       	push   $0x80106778
80101371:	e8 95 f2 ff ff       	call   8010060b <cprintf>
}
80101376:	83 c4 30             	add    $0x30,%esp
80101379:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010137c:	c9                   	leave  
8010137d:	c3                   	ret    

8010137e <ialloc>:
{
8010137e:	55                   	push   %ebp
8010137f:	89 e5                	mov    %esp,%ebp
80101381:	57                   	push   %edi
80101382:	56                   	push   %esi
80101383:	53                   	push   %ebx
80101384:	83 ec 1c             	sub    $0x1c,%esp
80101387:	8b 45 0c             	mov    0xc(%ebp),%eax
8010138a:	89 45 e0             	mov    %eax,-0x20(%ebp)
  for(inum = 1; inum < sb.ninodes; inum++){
8010138d:	bb 01 00 00 00       	mov    $0x1,%ebx
80101392:	89 5d e4             	mov    %ebx,-0x1c(%ebp)
80101395:	39 1d e8 09 11 80    	cmp    %ebx,0x801109e8
8010139b:	76 3f                	jbe    801013dc <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010139d:	89 d8                	mov    %ebx,%eax
8010139f:	c1 e8 03             	shr    $0x3,%eax
801013a2:	03 05 f4 09 11 80    	add    0x801109f4,%eax
801013a8:	83 ec 08             	sub    $0x8,%esp
801013ab:	50                   	push   %eax
801013ac:	ff 75 08             	pushl  0x8(%ebp)
801013af:	e8 b8 ed ff ff       	call   8010016c <bread>
801013b4:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + inum%IPB;
801013b6:	89 d8                	mov    %ebx,%eax
801013b8:	83 e0 07             	and    $0x7,%eax
801013bb:	c1 e0 06             	shl    $0x6,%eax
801013be:	8d 7c 06 5c          	lea    0x5c(%esi,%eax,1),%edi
    if(dip->type == 0){  // a free inode
801013c2:	83 c4 10             	add    $0x10,%esp
801013c5:	66 83 3f 00          	cmpw   $0x0,(%edi)
801013c9:	74 1e                	je     801013e9 <ialloc+0x6b>
    brelse(bp);
801013cb:	83 ec 0c             	sub    $0xc,%esp
801013ce:	56                   	push   %esi
801013cf:	e8 01 ee ff ff       	call   801001d5 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
801013d4:	83 c3 01             	add    $0x1,%ebx
801013d7:	83 c4 10             	add    $0x10,%esp
801013da:	eb b6                	jmp    80101392 <ialloc+0x14>
  panic("ialloc: no inodes");
801013dc:	83 ec 0c             	sub    $0xc,%esp
801013df:	68 18 67 10 80       	push   $0x80106718
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 a7 29 00 00       	call   80103d9d <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 2e 16 00 00       	call   80102a33 <log_write>
      brelse(bp);
80101405:	89 34 24             	mov    %esi,(%esp)
80101408:	e8 c8 ed ff ff       	call   801001d5 <brelse>
      return iget(dev, inum);
8010140d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101410:	8b 45 08             	mov    0x8(%ebp),%eax
80101413:	e8 6f fd ff ff       	call   80101187 <iget>
}
80101418:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010141b:	5b                   	pop    %ebx
8010141c:	5e                   	pop    %esi
8010141d:	5f                   	pop    %edi
8010141e:	5d                   	pop    %ebp
8010141f:	c3                   	ret    

80101420 <iupdate>:
{
80101420:	55                   	push   %ebp
80101421:	89 e5                	mov    %esp,%ebp
80101423:	56                   	push   %esi
80101424:	53                   	push   %ebx
80101425:	8b 5d 08             	mov    0x8(%ebp),%ebx
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
80101428:	8b 43 04             	mov    0x4(%ebx),%eax
8010142b:	c1 e8 03             	shr    $0x3,%eax
8010142e:	03 05 f4 09 11 80    	add    0x801109f4,%eax
80101434:	83 ec 08             	sub    $0x8,%esp
80101437:	50                   	push   %eax
80101438:	ff 33                	pushl  (%ebx)
8010143a:	e8 2d ed ff ff       	call   8010016c <bread>
8010143f:	89 c6                	mov    %eax,%esi
  dip = (struct dinode*)bp->data + ip->inum%IPB;
80101441:	8b 43 04             	mov    0x4(%ebx),%eax
80101444:	83 e0 07             	and    $0x7,%eax
80101447:	c1 e0 06             	shl    $0x6,%eax
8010144a:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
  dip->type = ip->type;
8010144e:	0f b7 53 50          	movzwl 0x50(%ebx),%edx
80101452:	66 89 10             	mov    %dx,(%eax)
  dip->major = ip->major;
80101455:	0f b7 53 52          	movzwl 0x52(%ebx),%edx
80101459:	66 89 50 02          	mov    %dx,0x2(%eax)
  dip->minor = ip->minor;
8010145d:	0f b7 53 54          	movzwl 0x54(%ebx),%edx
80101461:	66 89 50 04          	mov    %dx,0x4(%eax)
  dip->nlink = ip->nlink;
80101465:	0f b7 53 56          	movzwl 0x56(%ebx),%edx
80101469:	66 89 50 06          	mov    %dx,0x6(%eax)
  dip->size = ip->size;
8010146d:	8b 53 58             	mov    0x58(%ebx),%edx
80101470:	89 50 08             	mov    %edx,0x8(%eax)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
80101473:	83 c3 5c             	add    $0x5c,%ebx
80101476:	83 c0 0c             	add    $0xc,%eax
80101479:	83 c4 0c             	add    $0xc,%esp
8010147c:	6a 34                	push   $0x34
8010147e:	53                   	push   %ebx
8010147f:	50                   	push   %eax
80101480:	e8 93 29 00 00       	call   80103e18 <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 a6 15 00 00       	call   80102a33 <log_write>
  brelse(bp);
8010148d:	89 34 24             	mov    %esi,(%esp)
80101490:	e8 40 ed ff ff       	call   801001d5 <brelse>
}
80101495:	83 c4 10             	add    $0x10,%esp
80101498:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010149b:	5b                   	pop    %ebx
8010149c:	5e                   	pop    %esi
8010149d:	5d                   	pop    %ebp
8010149e:	c3                   	ret    

8010149f <itrunc>:
{
8010149f:	55                   	push   %ebp
801014a0:	89 e5                	mov    %esp,%ebp
801014a2:	57                   	push   %edi
801014a3:	56                   	push   %esi
801014a4:	53                   	push   %ebx
801014a5:	83 ec 1c             	sub    $0x1c,%esp
801014a8:	89 c6                	mov    %eax,%esi
  for(i = 0; i < NDIRECT; i++){
801014aa:	bb 00 00 00 00       	mov    $0x0,%ebx
801014af:	eb 03                	jmp    801014b4 <itrunc+0x15>
801014b1:	83 c3 01             	add    $0x1,%ebx
801014b4:	83 fb 0b             	cmp    $0xb,%ebx
801014b7:	7f 19                	jg     801014d2 <itrunc+0x33>
    if(ip->addrs[i]){
801014b9:	8b 54 9e 5c          	mov    0x5c(%esi,%ebx,4),%edx
801014bd:	85 d2                	test   %edx,%edx
801014bf:	74 f0                	je     801014b1 <itrunc+0x12>
      bfree(ip->dev, ip->addrs[i]);
801014c1:	8b 06                	mov    (%esi),%eax
801014c3:	e8 a2 fd ff ff       	call   8010126a <bfree>
      ip->addrs[i] = 0;
801014c8:	c7 44 9e 5c 00 00 00 	movl   $0x0,0x5c(%esi,%ebx,4)
801014cf:	00 
801014d0:	eb df                	jmp    801014b1 <itrunc+0x12>
  if(ip->addrs[NDIRECT]){
801014d2:	8b 86 8c 00 00 00    	mov    0x8c(%esi),%eax
801014d8:	85 c0                	test   %eax,%eax
801014da:	75 1b                	jne    801014f7 <itrunc+0x58>
  ip->size = 0;
801014dc:	c7 46 58 00 00 00 00 	movl   $0x0,0x58(%esi)
  iupdate(ip);
801014e3:	83 ec 0c             	sub    $0xc,%esp
801014e6:	56                   	push   %esi
801014e7:	e8 34 ff ff ff       	call   80101420 <iupdate>
}
801014ec:	83 c4 10             	add    $0x10,%esp
801014ef:	8d 65 f4             	lea    -0xc(%ebp),%esp
801014f2:	5b                   	pop    %ebx
801014f3:	5e                   	pop    %esi
801014f4:	5f                   	pop    %edi
801014f5:	5d                   	pop    %ebp
801014f6:	c3                   	ret    
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
801014f7:	83 ec 08             	sub    $0x8,%esp
801014fa:	50                   	push   %eax
801014fb:	ff 36                	pushl  (%esi)
801014fd:	e8 6a ec ff ff       	call   8010016c <bread>
80101502:	89 45 e4             	mov    %eax,-0x1c(%ebp)
    a = (uint*)bp->data;
80101505:	8d 78 5c             	lea    0x5c(%eax),%edi
    for(j = 0; j < NINDIRECT; j++){
80101508:	83 c4 10             	add    $0x10,%esp
8010150b:	bb 00 00 00 00       	mov    $0x0,%ebx
80101510:	eb 03                	jmp    80101515 <itrunc+0x76>
80101512:	83 c3 01             	add    $0x1,%ebx
80101515:	83 fb 7f             	cmp    $0x7f,%ebx
80101518:	77 10                	ja     8010152a <itrunc+0x8b>
      if(a[j])
8010151a:	8b 14 9f             	mov    (%edi,%ebx,4),%edx
8010151d:	85 d2                	test   %edx,%edx
8010151f:	74 f1                	je     80101512 <itrunc+0x73>
        bfree(ip->dev, a[j]);
80101521:	8b 06                	mov    (%esi),%eax
80101523:	e8 42 fd ff ff       	call   8010126a <bfree>
80101528:	eb e8                	jmp    80101512 <itrunc+0x73>
    brelse(bp);
8010152a:	83 ec 0c             	sub    $0xc,%esp
8010152d:	ff 75 e4             	pushl  -0x1c(%ebp)
80101530:	e8 a0 ec ff ff       	call   801001d5 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
80101535:	8b 06                	mov    (%esi),%eax
80101537:	8b 96 8c 00 00 00    	mov    0x8c(%esi),%edx
8010153d:	e8 28 fd ff ff       	call   8010126a <bfree>
    ip->addrs[NDIRECT] = 0;
80101542:	c7 86 8c 00 00 00 00 	movl   $0x0,0x8c(%esi)
80101549:	00 00 00 
8010154c:	83 c4 10             	add    $0x10,%esp
8010154f:	eb 8b                	jmp    801014dc <itrunc+0x3d>

80101551 <idup>:
{
80101551:	55                   	push   %ebp
80101552:	89 e5                	mov    %esp,%ebp
80101554:	53                   	push   %ebx
80101555:	83 ec 10             	sub    $0x10,%esp
80101558:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&icache.lock);
8010155b:	68 00 0a 11 80       	push   $0x80110a00
80101560:	e8 8c 27 00 00       	call   80103cf1 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101575:	e8 dc 27 00 00       	call   80103d56 <release>
}
8010157a:	89 d8                	mov    %ebx,%eax
8010157c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010157f:	c9                   	leave  
80101580:	c3                   	ret    

80101581 <ilock>:
{
80101581:	55                   	push   %ebp
80101582:	89 e5                	mov    %esp,%ebp
80101584:	56                   	push   %esi
80101585:	53                   	push   %ebx
80101586:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || ip->ref < 1)
80101589:	85 db                	test   %ebx,%ebx
8010158b:	74 22                	je     801015af <ilock+0x2e>
8010158d:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101591:	7e 1c                	jle    801015af <ilock+0x2e>
  acquiresleep(&ip->lock);
80101593:	83 ec 0c             	sub    $0xc,%esp
80101596:	8d 43 0c             	lea    0xc(%ebx),%eax
80101599:	50                   	push   %eax
8010159a:	e8 3e 25 00 00       	call   80103add <acquiresleep>
  if(ip->valid == 0){
8010159f:	83 c4 10             	add    $0x10,%esp
801015a2:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801015a6:	74 14                	je     801015bc <ilock+0x3b>
}
801015a8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801015ab:	5b                   	pop    %ebx
801015ac:	5e                   	pop    %esi
801015ad:	5d                   	pop    %ebp
801015ae:	c3                   	ret    
    panic("ilock");
801015af:	83 ec 0c             	sub    $0xc,%esp
801015b2:	68 2a 67 10 80       	push   $0x8010672a
801015b7:	e8 8c ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015bc:	8b 43 04             	mov    0x4(%ebx),%eax
801015bf:	c1 e8 03             	shr    $0x3,%eax
801015c2:	03 05 f4 09 11 80    	add    0x801109f4,%eax
801015c8:	83 ec 08             	sub    $0x8,%esp
801015cb:	50                   	push   %eax
801015cc:	ff 33                	pushl  (%ebx)
801015ce:	e8 99 eb ff ff       	call   8010016c <bread>
801015d3:	89 c6                	mov    %eax,%esi
    dip = (struct dinode*)bp->data + ip->inum%IPB;
801015d5:	8b 43 04             	mov    0x4(%ebx),%eax
801015d8:	83 e0 07             	and    $0x7,%eax
801015db:	c1 e0 06             	shl    $0x6,%eax
801015de:	8d 44 06 5c          	lea    0x5c(%esi,%eax,1),%eax
    ip->type = dip->type;
801015e2:	0f b7 10             	movzwl (%eax),%edx
801015e5:	66 89 53 50          	mov    %dx,0x50(%ebx)
    ip->major = dip->major;
801015e9:	0f b7 50 02          	movzwl 0x2(%eax),%edx
801015ed:	66 89 53 52          	mov    %dx,0x52(%ebx)
    ip->minor = dip->minor;
801015f1:	0f b7 50 04          	movzwl 0x4(%eax),%edx
801015f5:	66 89 53 54          	mov    %dx,0x54(%ebx)
    ip->nlink = dip->nlink;
801015f9:	0f b7 50 06          	movzwl 0x6(%eax),%edx
801015fd:	66 89 53 56          	mov    %dx,0x56(%ebx)
    ip->size = dip->size;
80101601:	8b 50 08             	mov    0x8(%eax),%edx
80101604:	89 53 58             	mov    %edx,0x58(%ebx)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
80101607:	83 c0 0c             	add    $0xc,%eax
8010160a:	8d 53 5c             	lea    0x5c(%ebx),%edx
8010160d:	83 c4 0c             	add    $0xc,%esp
80101610:	6a 34                	push   $0x34
80101612:	50                   	push   %eax
80101613:	52                   	push   %edx
80101614:	e8 ff 27 00 00       	call   80103e18 <memmove>
    brelse(bp);
80101619:	89 34 24             	mov    %esi,(%esp)
8010161c:	e8 b4 eb ff ff       	call   801001d5 <brelse>
    ip->valid = 1;
80101621:	c7 43 4c 01 00 00 00 	movl   $0x1,0x4c(%ebx)
    if(ip->type == 0)
80101628:	83 c4 10             	add    $0x10,%esp
8010162b:	66 83 7b 50 00       	cmpw   $0x0,0x50(%ebx)
80101630:	0f 85 72 ff ff ff    	jne    801015a8 <ilock+0x27>
      panic("ilock: no type");
80101636:	83 ec 0c             	sub    $0xc,%esp
80101639:	68 30 67 10 80       	push   $0x80106730
8010163e:	e8 05 ed ff ff       	call   80100348 <panic>

80101643 <iunlock>:
{
80101643:	55                   	push   %ebp
80101644:	89 e5                	mov    %esp,%ebp
80101646:	56                   	push   %esi
80101647:	53                   	push   %ebx
80101648:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
8010164b:	85 db                	test   %ebx,%ebx
8010164d:	74 2c                	je     8010167b <iunlock+0x38>
8010164f:	8d 73 0c             	lea    0xc(%ebx),%esi
80101652:	83 ec 0c             	sub    $0xc,%esp
80101655:	56                   	push   %esi
80101656:	e8 0c 25 00 00       	call   80103b67 <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 bb 24 00 00       	call   80103b2c <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 3f 67 10 80       	push   $0x8010673f
80101683:	e8 c0 ec ff ff       	call   80100348 <panic>

80101688 <iput>:
{
80101688:	55                   	push   %ebp
80101689:	89 e5                	mov    %esp,%ebp
8010168b:	57                   	push   %edi
8010168c:	56                   	push   %esi
8010168d:	53                   	push   %ebx
8010168e:	83 ec 18             	sub    $0x18,%esp
80101691:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquiresleep(&ip->lock);
80101694:	8d 73 0c             	lea    0xc(%ebx),%esi
80101697:	56                   	push   %esi
80101698:	e8 40 24 00 00       	call   80103add <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 76 24 00 00       	call   80103b2c <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801016bd:	e8 2f 26 00 00       	call   80103cf1 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801016d2:	e8 7f 26 00 00       	call   80103d56 <release>
}
801016d7:	83 c4 10             	add    $0x10,%esp
801016da:	8d 65 f4             	lea    -0xc(%ebp),%esp
801016dd:	5b                   	pop    %ebx
801016de:	5e                   	pop    %esi
801016df:	5f                   	pop    %edi
801016e0:	5d                   	pop    %ebp
801016e1:	c3                   	ret    
    acquire(&icache.lock);
801016e2:	83 ec 0c             	sub    $0xc,%esp
801016e5:	68 00 0a 11 80       	push   $0x80110a00
801016ea:	e8 02 26 00 00       	call   80103cf1 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801016f9:	e8 58 26 00 00       	call   80103d56 <release>
    if(r == 1){
801016fe:	83 c4 10             	add    $0x10,%esp
80101701:	83 ff 01             	cmp    $0x1,%edi
80101704:	75 a7                	jne    801016ad <iput+0x25>
      itrunc(ip);
80101706:	89 d8                	mov    %ebx,%eax
80101708:	e8 92 fd ff ff       	call   8010149f <itrunc>
      ip->type = 0;
8010170d:	66 c7 43 50 00 00    	movw   $0x0,0x50(%ebx)
      iupdate(ip);
80101713:	83 ec 0c             	sub    $0xc,%esp
80101716:	53                   	push   %ebx
80101717:	e8 04 fd ff ff       	call   80101420 <iupdate>
      ip->valid = 0;
8010171c:	c7 43 4c 00 00 00 00 	movl   $0x0,0x4c(%ebx)
80101723:	83 c4 10             	add    $0x10,%esp
80101726:	eb 85                	jmp    801016ad <iput+0x25>

80101728 <iunlockput>:
{
80101728:	55                   	push   %ebp
80101729:	89 e5                	mov    %esp,%ebp
8010172b:	53                   	push   %ebx
8010172c:	83 ec 10             	sub    $0x10,%esp
8010172f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  iunlock(ip);
80101732:	53                   	push   %ebx
80101733:	e8 0b ff ff ff       	call   80101643 <iunlock>
  iput(ip);
80101738:	89 1c 24             	mov    %ebx,(%esp)
8010173b:	e8 48 ff ff ff       	call   80101688 <iput>
}
80101740:	83 c4 10             	add    $0x10,%esp
80101743:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101746:	c9                   	leave  
80101747:	c3                   	ret    

80101748 <stati>:
{
80101748:	55                   	push   %ebp
80101749:	89 e5                	mov    %esp,%ebp
8010174b:	8b 55 08             	mov    0x8(%ebp),%edx
8010174e:	8b 45 0c             	mov    0xc(%ebp),%eax
  st->dev = ip->dev;
80101751:	8b 0a                	mov    (%edx),%ecx
80101753:	89 48 04             	mov    %ecx,0x4(%eax)
  st->ino = ip->inum;
80101756:	8b 4a 04             	mov    0x4(%edx),%ecx
80101759:	89 48 08             	mov    %ecx,0x8(%eax)
  st->type = ip->type;
8010175c:	0f b7 4a 50          	movzwl 0x50(%edx),%ecx
80101760:	66 89 08             	mov    %cx,(%eax)
  st->nlink = ip->nlink;
80101763:	0f b7 4a 56          	movzwl 0x56(%edx),%ecx
80101767:	66 89 48 0c          	mov    %cx,0xc(%eax)
  st->size = ip->size;
8010176b:	8b 52 58             	mov    0x58(%edx),%edx
8010176e:	89 50 10             	mov    %edx,0x10(%eax)
}
80101771:	5d                   	pop    %ebp
80101772:	c3                   	ret    

80101773 <readi>:
{
80101773:	55                   	push   %ebp
80101774:	89 e5                	mov    %esp,%ebp
80101776:	57                   	push   %edi
80101777:	56                   	push   %esi
80101778:	53                   	push   %ebx
80101779:	83 ec 1c             	sub    $0x1c,%esp
8010177c:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(ip->type == T_DEV){
8010177f:	8b 45 08             	mov    0x8(%ebp),%eax
80101782:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101787:	74 2c                	je     801017b5 <readi+0x42>
  if(off > ip->size || off + n < off)
80101789:	8b 45 08             	mov    0x8(%ebp),%eax
8010178c:	8b 40 58             	mov    0x58(%eax),%eax
8010178f:	39 f8                	cmp    %edi,%eax
80101791:	0f 82 cb 00 00 00    	jb     80101862 <readi+0xef>
80101797:	89 fa                	mov    %edi,%edx
80101799:	03 55 14             	add    0x14(%ebp),%edx
8010179c:	0f 82 c7 00 00 00    	jb     80101869 <readi+0xf6>
  if(off + n > ip->size)
801017a2:	39 d0                	cmp    %edx,%eax
801017a4:	73 05                	jae    801017ab <readi+0x38>
    n = ip->size - off;
801017a6:	29 f8                	sub    %edi,%eax
801017a8:	89 45 14             	mov    %eax,0x14(%ebp)
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
801017ab:	be 00 00 00 00       	mov    $0x0,%esi
801017b0:	e9 8f 00 00 00       	jmp    80101844 <readi+0xd1>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].read)
801017b5:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801017b9:	66 83 f8 09          	cmp    $0x9,%ax
801017bd:	0f 87 91 00 00 00    	ja     80101854 <readi+0xe1>
801017c3:	98                   	cwtl   
801017c4:	8b 04 c5 80 09 11 80 	mov    -0x7feef680(,%eax,8),%eax
801017cb:	85 c0                	test   %eax,%eax
801017cd:	0f 84 88 00 00 00    	je     8010185b <readi+0xe8>
    return devsw[ip->major].read(ip, dst, n);
801017d3:	83 ec 04             	sub    $0x4,%esp
801017d6:	ff 75 14             	pushl  0x14(%ebp)
801017d9:	ff 75 0c             	pushl  0xc(%ebp)
801017dc:	ff 75 08             	pushl  0x8(%ebp)
801017df:	ff d0                	call   *%eax
801017e1:	83 c4 10             	add    $0x10,%esp
801017e4:	eb 66                	jmp    8010184c <readi+0xd9>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801017e6:	89 fa                	mov    %edi,%edx
801017e8:	c1 ea 09             	shr    $0x9,%edx
801017eb:	8b 45 08             	mov    0x8(%ebp),%eax
801017ee:	e8 ee f8 ff ff       	call   801010e1 <bmap>
801017f3:	83 ec 08             	sub    $0x8,%esp
801017f6:	50                   	push   %eax
801017f7:	8b 45 08             	mov    0x8(%ebp),%eax
801017fa:	ff 30                	pushl  (%eax)
801017fc:	e8 6b e9 ff ff       	call   8010016c <bread>
80101801:	89 c1                	mov    %eax,%ecx
    m = min(n - tot, BSIZE - off%BSIZE);
80101803:	89 f8                	mov    %edi,%eax
80101805:	25 ff 01 00 00       	and    $0x1ff,%eax
8010180a:	bb 00 02 00 00       	mov    $0x200,%ebx
8010180f:	29 c3                	sub    %eax,%ebx
80101811:	8b 55 14             	mov    0x14(%ebp),%edx
80101814:	29 f2                	sub    %esi,%edx
80101816:	83 c4 0c             	add    $0xc,%esp
80101819:	39 d3                	cmp    %edx,%ebx
8010181b:	0f 47 da             	cmova  %edx,%ebx
    memmove(dst, bp->data + off%BSIZE, m);
8010181e:	53                   	push   %ebx
8010181f:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
80101822:	8d 44 01 5c          	lea    0x5c(%ecx,%eax,1),%eax
80101826:	50                   	push   %eax
80101827:	ff 75 0c             	pushl  0xc(%ebp)
8010182a:	e8 e9 25 00 00       	call   80103e18 <memmove>
    brelse(bp);
8010182f:	83 c4 04             	add    $0x4,%esp
80101832:	ff 75 e4             	pushl  -0x1c(%ebp)
80101835:	e8 9b e9 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
8010183a:	01 de                	add    %ebx,%esi
8010183c:	01 df                	add    %ebx,%edi
8010183e:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101841:	83 c4 10             	add    $0x10,%esp
80101844:	39 75 14             	cmp    %esi,0x14(%ebp)
80101847:	77 9d                	ja     801017e6 <readi+0x73>
  return n;
80101849:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010184c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010184f:	5b                   	pop    %ebx
80101850:	5e                   	pop    %esi
80101851:	5f                   	pop    %edi
80101852:	5d                   	pop    %ebp
80101853:	c3                   	ret    
      return -1;
80101854:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101859:	eb f1                	jmp    8010184c <readi+0xd9>
8010185b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101860:	eb ea                	jmp    8010184c <readi+0xd9>
    return -1;
80101862:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101867:	eb e3                	jmp    8010184c <readi+0xd9>
80101869:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010186e:	eb dc                	jmp    8010184c <readi+0xd9>

80101870 <writei>:
{
80101870:	55                   	push   %ebp
80101871:	89 e5                	mov    %esp,%ebp
80101873:	57                   	push   %edi
80101874:	56                   	push   %esi
80101875:	53                   	push   %ebx
80101876:	83 ec 0c             	sub    $0xc,%esp
  if(ip->type == T_DEV){
80101879:	8b 45 08             	mov    0x8(%ebp),%eax
8010187c:	66 83 78 50 03       	cmpw   $0x3,0x50(%eax)
80101881:	74 2f                	je     801018b2 <writei+0x42>
  if(off > ip->size || off + n < off)
80101883:	8b 45 08             	mov    0x8(%ebp),%eax
80101886:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101889:	39 48 58             	cmp    %ecx,0x58(%eax)
8010188c:	0f 82 f4 00 00 00    	jb     80101986 <writei+0x116>
80101892:	89 c8                	mov    %ecx,%eax
80101894:	03 45 14             	add    0x14(%ebp),%eax
80101897:	0f 82 f0 00 00 00    	jb     8010198d <writei+0x11d>
  if(off + n > MAXFILE*BSIZE)
8010189d:	3d 00 18 01 00       	cmp    $0x11800,%eax
801018a2:	0f 87 ec 00 00 00    	ja     80101994 <writei+0x124>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
801018a8:	be 00 00 00 00       	mov    $0x0,%esi
801018ad:	e9 94 00 00 00       	jmp    80101946 <writei+0xd6>
    if(ip->major < 0 || ip->major >= NDEV || !devsw[ip->major].write)
801018b2:	0f b7 40 52          	movzwl 0x52(%eax),%eax
801018b6:	66 83 f8 09          	cmp    $0x9,%ax
801018ba:	0f 87 b8 00 00 00    	ja     80101978 <writei+0x108>
801018c0:	98                   	cwtl   
801018c1:	8b 04 c5 84 09 11 80 	mov    -0x7feef67c(,%eax,8),%eax
801018c8:	85 c0                	test   %eax,%eax
801018ca:	0f 84 af 00 00 00    	je     8010197f <writei+0x10f>
    return devsw[ip->major].write(ip, src, n);
801018d0:	83 ec 04             	sub    $0x4,%esp
801018d3:	ff 75 14             	pushl  0x14(%ebp)
801018d6:	ff 75 0c             	pushl  0xc(%ebp)
801018d9:	ff 75 08             	pushl  0x8(%ebp)
801018dc:	ff d0                	call   *%eax
801018de:	83 c4 10             	add    $0x10,%esp
801018e1:	eb 7c                	jmp    8010195f <writei+0xef>
    bp = bread(ip->dev, bmap(ip, off/BSIZE));
801018e3:	8b 55 10             	mov    0x10(%ebp),%edx
801018e6:	c1 ea 09             	shr    $0x9,%edx
801018e9:	8b 45 08             	mov    0x8(%ebp),%eax
801018ec:	e8 f0 f7 ff ff       	call   801010e1 <bmap>
801018f1:	83 ec 08             	sub    $0x8,%esp
801018f4:	50                   	push   %eax
801018f5:	8b 45 08             	mov    0x8(%ebp),%eax
801018f8:	ff 30                	pushl  (%eax)
801018fa:	e8 6d e8 ff ff       	call   8010016c <bread>
801018ff:	89 c7                	mov    %eax,%edi
    m = min(n - tot, BSIZE - off%BSIZE);
80101901:	8b 45 10             	mov    0x10(%ebp),%eax
80101904:	25 ff 01 00 00       	and    $0x1ff,%eax
80101909:	bb 00 02 00 00       	mov    $0x200,%ebx
8010190e:	29 c3                	sub    %eax,%ebx
80101910:	8b 55 14             	mov    0x14(%ebp),%edx
80101913:	29 f2                	sub    %esi,%edx
80101915:	83 c4 0c             	add    $0xc,%esp
80101918:	39 d3                	cmp    %edx,%ebx
8010191a:	0f 47 da             	cmova  %edx,%ebx
    memmove(bp->data + off%BSIZE, src, m);
8010191d:	53                   	push   %ebx
8010191e:	ff 75 0c             	pushl  0xc(%ebp)
80101921:	8d 44 07 5c          	lea    0x5c(%edi,%eax,1),%eax
80101925:	50                   	push   %eax
80101926:	e8 ed 24 00 00       	call   80103e18 <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 00 11 00 00       	call   80102a33 <log_write>
    brelse(bp);
80101933:	89 3c 24             	mov    %edi,(%esp)
80101936:	e8 9a e8 ff ff       	call   801001d5 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
8010193b:	01 de                	add    %ebx,%esi
8010193d:	01 5d 10             	add    %ebx,0x10(%ebp)
80101940:	01 5d 0c             	add    %ebx,0xc(%ebp)
80101943:	83 c4 10             	add    $0x10,%esp
80101946:	3b 75 14             	cmp    0x14(%ebp),%esi
80101949:	72 98                	jb     801018e3 <writei+0x73>
  if(n > 0 && off > ip->size){
8010194b:	83 7d 14 00          	cmpl   $0x0,0x14(%ebp)
8010194f:	74 0b                	je     8010195c <writei+0xec>
80101951:	8b 45 08             	mov    0x8(%ebp),%eax
80101954:	8b 4d 10             	mov    0x10(%ebp),%ecx
80101957:	39 48 58             	cmp    %ecx,0x58(%eax)
8010195a:	72 0b                	jb     80101967 <writei+0xf7>
  return n;
8010195c:	8b 45 14             	mov    0x14(%ebp),%eax
}
8010195f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101962:	5b                   	pop    %ebx
80101963:	5e                   	pop    %esi
80101964:	5f                   	pop    %edi
80101965:	5d                   	pop    %ebp
80101966:	c3                   	ret    
    ip->size = off;
80101967:	89 48 58             	mov    %ecx,0x58(%eax)
    iupdate(ip);
8010196a:	83 ec 0c             	sub    $0xc,%esp
8010196d:	50                   	push   %eax
8010196e:	e8 ad fa ff ff       	call   80101420 <iupdate>
80101973:	83 c4 10             	add    $0x10,%esp
80101976:	eb e4                	jmp    8010195c <writei+0xec>
      return -1;
80101978:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010197d:	eb e0                	jmp    8010195f <writei+0xef>
8010197f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101984:	eb d9                	jmp    8010195f <writei+0xef>
    return -1;
80101986:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010198b:	eb d2                	jmp    8010195f <writei+0xef>
8010198d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101992:	eb cb                	jmp    8010195f <writei+0xef>
    return -1;
80101994:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101999:	eb c4                	jmp    8010195f <writei+0xef>

8010199b <namecmp>:
{
8010199b:	55                   	push   %ebp
8010199c:	89 e5                	mov    %esp,%ebp
8010199e:	83 ec 0c             	sub    $0xc,%esp
  return strncmp(s, t, DIRSIZ);
801019a1:	6a 0e                	push   $0xe
801019a3:	ff 75 0c             	pushl  0xc(%ebp)
801019a6:	ff 75 08             	pushl  0x8(%ebp)
801019a9:	e8 d1 24 00 00       	call   80103e7f <strncmp>
}
801019ae:	c9                   	leave  
801019af:	c3                   	ret    

801019b0 <dirlookup>:
{
801019b0:	55                   	push   %ebp
801019b1:	89 e5                	mov    %esp,%ebp
801019b3:	57                   	push   %edi
801019b4:	56                   	push   %esi
801019b5:	53                   	push   %ebx
801019b6:	83 ec 1c             	sub    $0x1c,%esp
801019b9:	8b 75 08             	mov    0x8(%ebp),%esi
801019bc:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(dp->type != T_DIR)
801019bf:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
801019c4:	75 07                	jne    801019cd <dirlookup+0x1d>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019c6:	bb 00 00 00 00       	mov    $0x0,%ebx
801019cb:	eb 1d                	jmp    801019ea <dirlookup+0x3a>
    panic("dirlookup not DIR");
801019cd:	83 ec 0c             	sub    $0xc,%esp
801019d0:	68 47 67 10 80       	push   $0x80106747
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 59 67 10 80       	push   $0x80106759
801019e2:	e8 61 e9 ff ff       	call   80100348 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
801019e7:	83 c3 10             	add    $0x10,%ebx
801019ea:	39 5e 58             	cmp    %ebx,0x58(%esi)
801019ed:	76 48                	jbe    80101a37 <dirlookup+0x87>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801019ef:	6a 10                	push   $0x10
801019f1:	53                   	push   %ebx
801019f2:	8d 45 d8             	lea    -0x28(%ebp),%eax
801019f5:	50                   	push   %eax
801019f6:	56                   	push   %esi
801019f7:	e8 77 fd ff ff       	call   80101773 <readi>
801019fc:	83 c4 10             	add    $0x10,%esp
801019ff:	83 f8 10             	cmp    $0x10,%eax
80101a02:	75 d6                	jne    801019da <dirlookup+0x2a>
    if(de.inum == 0)
80101a04:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101a09:	74 dc                	je     801019e7 <dirlookup+0x37>
    if(namecmp(name, de.name) == 0){
80101a0b:	83 ec 08             	sub    $0x8,%esp
80101a0e:	8d 45 da             	lea    -0x26(%ebp),%eax
80101a11:	50                   	push   %eax
80101a12:	57                   	push   %edi
80101a13:	e8 83 ff ff ff       	call   8010199b <namecmp>
80101a18:	83 c4 10             	add    $0x10,%esp
80101a1b:	85 c0                	test   %eax,%eax
80101a1d:	75 c8                	jne    801019e7 <dirlookup+0x37>
      if(poff)
80101a1f:	83 7d 10 00          	cmpl   $0x0,0x10(%ebp)
80101a23:	74 05                	je     80101a2a <dirlookup+0x7a>
        *poff = off;
80101a25:	8b 45 10             	mov    0x10(%ebp),%eax
80101a28:	89 18                	mov    %ebx,(%eax)
      inum = de.inum;
80101a2a:	0f b7 55 d8          	movzwl -0x28(%ebp),%edx
      return iget(dp->dev, inum);
80101a2e:	8b 06                	mov    (%esi),%eax
80101a30:	e8 52 f7 ff ff       	call   80101187 <iget>
80101a35:	eb 05                	jmp    80101a3c <dirlookup+0x8c>
  return 0;
80101a37:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101a3c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a3f:	5b                   	pop    %ebx
80101a40:	5e                   	pop    %esi
80101a41:	5f                   	pop    %edi
80101a42:	5d                   	pop    %ebp
80101a43:	c3                   	ret    

80101a44 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
80101a44:	55                   	push   %ebp
80101a45:	89 e5                	mov    %esp,%ebp
80101a47:	57                   	push   %edi
80101a48:	56                   	push   %esi
80101a49:	53                   	push   %ebx
80101a4a:	83 ec 1c             	sub    $0x1c,%esp
80101a4d:	89 c6                	mov    %eax,%esi
80101a4f:	89 55 e0             	mov    %edx,-0x20(%ebp)
80101a52:	89 4d e4             	mov    %ecx,-0x1c(%ebp)
  struct inode *ip, *next;

  if(*path == '/')
80101a55:	80 38 2f             	cmpb   $0x2f,(%eax)
80101a58:	74 17                	je     80101a71 <namex+0x2d>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
80101a5a:	e8 f3 18 00 00       	call   80103352 <myproc>
80101a5f:	83 ec 0c             	sub    $0xc,%esp
80101a62:	ff 70 68             	pushl  0x68(%eax)
80101a65:	e8 e7 fa ff ff       	call   80101551 <idup>
80101a6a:	89 c3                	mov    %eax,%ebx
80101a6c:	83 c4 10             	add    $0x10,%esp
80101a6f:	eb 53                	jmp    80101ac4 <namex+0x80>
    ip = iget(ROOTDEV, ROOTINO);
80101a71:	ba 01 00 00 00       	mov    $0x1,%edx
80101a76:	b8 01 00 00 00       	mov    $0x1,%eax
80101a7b:	e8 07 f7 ff ff       	call   80101187 <iget>
80101a80:	89 c3                	mov    %eax,%ebx
80101a82:	eb 40                	jmp    80101ac4 <namex+0x80>

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
      iunlockput(ip);
80101a84:	83 ec 0c             	sub    $0xc,%esp
80101a87:	53                   	push   %ebx
80101a88:	e8 9b fc ff ff       	call   80101728 <iunlockput>
      return 0;
80101a8d:	83 c4 10             	add    $0x10,%esp
80101a90:	bb 00 00 00 00       	mov    $0x0,%ebx
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
80101a95:	89 d8                	mov    %ebx,%eax
80101a97:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101a9a:	5b                   	pop    %ebx
80101a9b:	5e                   	pop    %esi
80101a9c:	5f                   	pop    %edi
80101a9d:	5d                   	pop    %ebp
80101a9e:	c3                   	ret    
    if((next = dirlookup(ip, name, 0)) == 0){
80101a9f:	83 ec 04             	sub    $0x4,%esp
80101aa2:	6a 00                	push   $0x0
80101aa4:	ff 75 e4             	pushl  -0x1c(%ebp)
80101aa7:	53                   	push   %ebx
80101aa8:	e8 03 ff ff ff       	call   801019b0 <dirlookup>
80101aad:	89 c7                	mov    %eax,%edi
80101aaf:	83 c4 10             	add    $0x10,%esp
80101ab2:	85 c0                	test   %eax,%eax
80101ab4:	74 4a                	je     80101b00 <namex+0xbc>
    iunlockput(ip);
80101ab6:	83 ec 0c             	sub    $0xc,%esp
80101ab9:	53                   	push   %ebx
80101aba:	e8 69 fc ff ff       	call   80101728 <iunlockput>
    ip = next;
80101abf:	83 c4 10             	add    $0x10,%esp
80101ac2:	89 fb                	mov    %edi,%ebx
  while((path = skipelem(path, name)) != 0){
80101ac4:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80101ac7:	89 f0                	mov    %esi,%eax
80101ac9:	e8 77 f4 ff ff       	call   80100f45 <skipelem>
80101ace:	89 c6                	mov    %eax,%esi
80101ad0:	85 c0                	test   %eax,%eax
80101ad2:	74 3c                	je     80101b10 <namex+0xcc>
    ilock(ip);
80101ad4:	83 ec 0c             	sub    $0xc,%esp
80101ad7:	53                   	push   %ebx
80101ad8:	e8 a4 fa ff ff       	call   80101581 <ilock>
    if(ip->type != T_DIR){
80101add:	83 c4 10             	add    $0x10,%esp
80101ae0:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80101ae5:	75 9d                	jne    80101a84 <namex+0x40>
    if(nameiparent && *path == '\0'){
80101ae7:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101aeb:	74 b2                	je     80101a9f <namex+0x5b>
80101aed:	80 3e 00             	cmpb   $0x0,(%esi)
80101af0:	75 ad                	jne    80101a9f <namex+0x5b>
      iunlock(ip);
80101af2:	83 ec 0c             	sub    $0xc,%esp
80101af5:	53                   	push   %ebx
80101af6:	e8 48 fb ff ff       	call   80101643 <iunlock>
      return ip;
80101afb:	83 c4 10             	add    $0x10,%esp
80101afe:	eb 95                	jmp    80101a95 <namex+0x51>
      iunlockput(ip);
80101b00:	83 ec 0c             	sub    $0xc,%esp
80101b03:	53                   	push   %ebx
80101b04:	e8 1f fc ff ff       	call   80101728 <iunlockput>
      return 0;
80101b09:	83 c4 10             	add    $0x10,%esp
80101b0c:	89 fb                	mov    %edi,%ebx
80101b0e:	eb 85                	jmp    80101a95 <namex+0x51>
  if(nameiparent){
80101b10:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80101b14:	0f 84 7b ff ff ff    	je     80101a95 <namex+0x51>
    iput(ip);
80101b1a:	83 ec 0c             	sub    $0xc,%esp
80101b1d:	53                   	push   %ebx
80101b1e:	e8 65 fb ff ff       	call   80101688 <iput>
    return 0;
80101b23:	83 c4 10             	add    $0x10,%esp
80101b26:	bb 00 00 00 00       	mov    $0x0,%ebx
80101b2b:	e9 65 ff ff ff       	jmp    80101a95 <namex+0x51>

80101b30 <dirlink>:
{
80101b30:	55                   	push   %ebp
80101b31:	89 e5                	mov    %esp,%ebp
80101b33:	57                   	push   %edi
80101b34:	56                   	push   %esi
80101b35:	53                   	push   %ebx
80101b36:	83 ec 20             	sub    $0x20,%esp
80101b39:	8b 5d 08             	mov    0x8(%ebp),%ebx
80101b3c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if((ip = dirlookup(dp, name, 0)) != 0){
80101b3f:	6a 00                	push   $0x0
80101b41:	57                   	push   %edi
80101b42:	53                   	push   %ebx
80101b43:	e8 68 fe ff ff       	call   801019b0 <dirlookup>
80101b48:	83 c4 10             	add    $0x10,%esp
80101b4b:	85 c0                	test   %eax,%eax
80101b4d:	75 2d                	jne    80101b7c <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b4f:	b8 00 00 00 00       	mov    $0x0,%eax
80101b54:	89 c6                	mov    %eax,%esi
80101b56:	39 43 58             	cmp    %eax,0x58(%ebx)
80101b59:	76 41                	jbe    80101b9c <dirlink+0x6c>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101b5b:	6a 10                	push   $0x10
80101b5d:	50                   	push   %eax
80101b5e:	8d 45 d8             	lea    -0x28(%ebp),%eax
80101b61:	50                   	push   %eax
80101b62:	53                   	push   %ebx
80101b63:	e8 0b fc ff ff       	call   80101773 <readi>
80101b68:	83 c4 10             	add    $0x10,%esp
80101b6b:	83 f8 10             	cmp    $0x10,%eax
80101b6e:	75 1f                	jne    80101b8f <dirlink+0x5f>
    if(de.inum == 0)
80101b70:	66 83 7d d8 00       	cmpw   $0x0,-0x28(%ebp)
80101b75:	74 25                	je     80101b9c <dirlink+0x6c>
  for(off = 0; off < dp->size; off += sizeof(de)){
80101b77:	8d 46 10             	lea    0x10(%esi),%eax
80101b7a:	eb d8                	jmp    80101b54 <dirlink+0x24>
    iput(ip);
80101b7c:	83 ec 0c             	sub    $0xc,%esp
80101b7f:	50                   	push   %eax
80101b80:	e8 03 fb ff ff       	call   80101688 <iput>
    return -1;
80101b85:	83 c4 10             	add    $0x10,%esp
80101b88:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101b8d:	eb 3d                	jmp    80101bcc <dirlink+0x9c>
      panic("dirlink read");
80101b8f:	83 ec 0c             	sub    $0xc,%esp
80101b92:	68 68 67 10 80       	push   $0x80106768
80101b97:	e8 ac e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b9c:	83 ec 04             	sub    $0x4,%esp
80101b9f:	6a 0e                	push   $0xe
80101ba1:	57                   	push   %edi
80101ba2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101ba5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ba8:	50                   	push   %eax
80101ba9:	e8 0e 23 00 00       	call   80103ebc <strncpy>
  de.inum = inum;
80101bae:	8b 45 10             	mov    0x10(%ebp),%eax
80101bb1:	66 89 45 d8          	mov    %ax,-0x28(%ebp)
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80101bb5:	6a 10                	push   $0x10
80101bb7:	56                   	push   %esi
80101bb8:	57                   	push   %edi
80101bb9:	53                   	push   %ebx
80101bba:	e8 b1 fc ff ff       	call   80101870 <writei>
80101bbf:	83 c4 20             	add    $0x20,%esp
80101bc2:	83 f8 10             	cmp    $0x10,%eax
80101bc5:	75 0d                	jne    80101bd4 <dirlink+0xa4>
  return 0;
80101bc7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101bcc:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101bcf:	5b                   	pop    %ebx
80101bd0:	5e                   	pop    %esi
80101bd1:	5f                   	pop    %edi
80101bd2:	5d                   	pop    %ebp
80101bd3:	c3                   	ret    
    panic("dirlink");
80101bd4:	83 ec 0c             	sub    $0xc,%esp
80101bd7:	68 b4 6d 10 80       	push   $0x80106db4
80101bdc:	e8 67 e7 ff ff       	call   80100348 <panic>

80101be1 <namei>:

struct inode*
namei(char *path)
{
80101be1:	55                   	push   %ebp
80101be2:	89 e5                	mov    %esp,%ebp
80101be4:	83 ec 18             	sub    $0x18,%esp
  char name[DIRSIZ];
  return namex(path, 0, name);
80101be7:	8d 4d ea             	lea    -0x16(%ebp),%ecx
80101bea:	ba 00 00 00 00       	mov    $0x0,%edx
80101bef:	8b 45 08             	mov    0x8(%ebp),%eax
80101bf2:	e8 4d fe ff ff       	call   80101a44 <namex>
}
80101bf7:	c9                   	leave  
80101bf8:	c3                   	ret    

80101bf9 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
80101bf9:	55                   	push   %ebp
80101bfa:	89 e5                	mov    %esp,%ebp
80101bfc:	83 ec 08             	sub    $0x8,%esp
  return namex(path, 1, name);
80101bff:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80101c02:	ba 01 00 00 00       	mov    $0x1,%edx
80101c07:	8b 45 08             	mov    0x8(%ebp),%eax
80101c0a:	e8 35 fe ff ff       	call   80101a44 <namex>
}
80101c0f:	c9                   	leave  
80101c10:	c3                   	ret    

80101c11 <idewait>:
static void idestart(struct buf*);

// Wait for IDE disk to become ready.
static int
idewait(int checkerr)
{
80101c11:	55                   	push   %ebp
80101c12:	89 e5                	mov    %esp,%ebp
80101c14:	89 c1                	mov    %eax,%ecx
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101c16:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101c1b:	ec                   	in     (%dx),%al
80101c1c:	89 c2                	mov    %eax,%edx
  int r;

  while(((r = inb(0x1f7)) & (IDE_BSY|IDE_DRDY)) != IDE_DRDY)
80101c1e:	83 e0 c0             	and    $0xffffffc0,%eax
80101c21:	3c 40                	cmp    $0x40,%al
80101c23:	75 f1                	jne    80101c16 <idewait+0x5>
    ;
  if(checkerr && (r & (IDE_DF|IDE_ERR)) != 0)
80101c25:	85 c9                	test   %ecx,%ecx
80101c27:	74 0c                	je     80101c35 <idewait+0x24>
80101c29:	f6 c2 21             	test   $0x21,%dl
80101c2c:	75 0e                	jne    80101c3c <idewait+0x2b>
    return -1;
  return 0;
80101c2e:	b8 00 00 00 00       	mov    $0x0,%eax
80101c33:	eb 05                	jmp    80101c3a <idewait+0x29>
80101c35:	b8 00 00 00 00       	mov    $0x0,%eax
}
80101c3a:	5d                   	pop    %ebp
80101c3b:	c3                   	ret    
    return -1;
80101c3c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80101c41:	eb f7                	jmp    80101c3a <idewait+0x29>

80101c43 <idestart>:
}

// Start the request for b.  Caller must hold idelock.
static void
idestart(struct buf *b)
{
80101c43:	55                   	push   %ebp
80101c44:	89 e5                	mov    %esp,%ebp
80101c46:	56                   	push   %esi
80101c47:	53                   	push   %ebx
  if(b == 0)
80101c48:	85 c0                	test   %eax,%eax
80101c4a:	74 7d                	je     80101cc9 <idestart+0x86>
80101c4c:	89 c6                	mov    %eax,%esi
    panic("idestart");
  if(b->blockno >= FSSIZE)
80101c4e:	8b 58 08             	mov    0x8(%eax),%ebx
80101c51:	81 fb e7 03 00 00    	cmp    $0x3e7,%ebx
80101c57:	77 7d                	ja     80101cd6 <idestart+0x93>
  int read_cmd = (sector_per_block == 1) ? IDE_CMD_READ :  IDE_CMD_RDMUL;
  int write_cmd = (sector_per_block == 1) ? IDE_CMD_WRITE : IDE_CMD_WRMUL;

  if (sector_per_block > 7) panic("idestart");

  idewait(0);
80101c59:	b8 00 00 00 00       	mov    $0x0,%eax
80101c5e:	e8 ae ff ff ff       	call   80101c11 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101c63:	b8 00 00 00 00       	mov    $0x0,%eax
80101c68:	ba f6 03 00 00       	mov    $0x3f6,%edx
80101c6d:	ee                   	out    %al,(%dx)
80101c6e:	b8 01 00 00 00       	mov    $0x1,%eax
80101c73:	ba f2 01 00 00       	mov    $0x1f2,%edx
80101c78:	ee                   	out    %al,(%dx)
80101c79:	ba f3 01 00 00       	mov    $0x1f3,%edx
80101c7e:	89 d8                	mov    %ebx,%eax
80101c80:	ee                   	out    %al,(%dx)
  outb(0x3f6, 0);  // generate interrupt
  outb(0x1f2, sector_per_block);  // number of sectors
  outb(0x1f3, sector & 0xff);
  outb(0x1f4, (sector >> 8) & 0xff);
80101c81:	89 d8                	mov    %ebx,%eax
80101c83:	c1 f8 08             	sar    $0x8,%eax
80101c86:	ba f4 01 00 00       	mov    $0x1f4,%edx
80101c8b:	ee                   	out    %al,(%dx)
  outb(0x1f5, (sector >> 16) & 0xff);
80101c8c:	89 d8                	mov    %ebx,%eax
80101c8e:	c1 f8 10             	sar    $0x10,%eax
80101c91:	ba f5 01 00 00       	mov    $0x1f5,%edx
80101c96:	ee                   	out    %al,(%dx)
  outb(0x1f6, 0xe0 | ((b->dev&1)<<4) | ((sector>>24)&0x0f));
80101c97:	0f b6 46 04          	movzbl 0x4(%esi),%eax
80101c9b:	c1 e0 04             	shl    $0x4,%eax
80101c9e:	83 e0 10             	and    $0x10,%eax
80101ca1:	c1 fb 18             	sar    $0x18,%ebx
80101ca4:	83 e3 0f             	and    $0xf,%ebx
80101ca7:	09 d8                	or     %ebx,%eax
80101ca9:	83 c8 e0             	or     $0xffffffe0,%eax
80101cac:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101cb1:	ee                   	out    %al,(%dx)
  if(b->flags & B_DIRTY){
80101cb2:	f6 06 04             	testb  $0x4,(%esi)
80101cb5:	75 2c                	jne    80101ce3 <idestart+0xa0>
80101cb7:	b8 20 00 00 00       	mov    $0x20,%eax
80101cbc:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101cc1:	ee                   	out    %al,(%dx)
    outb(0x1f7, write_cmd);
    outsl(0x1f0, b->data, BSIZE/4);
  } else {
    outb(0x1f7, read_cmd);
  }
}
80101cc2:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101cc5:	5b                   	pop    %ebx
80101cc6:	5e                   	pop    %esi
80101cc7:	5d                   	pop    %ebp
80101cc8:	c3                   	ret    
    panic("idestart");
80101cc9:	83 ec 0c             	sub    $0xc,%esp
80101ccc:	68 cb 67 10 80       	push   $0x801067cb
80101cd1:	e8 72 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 d4 67 10 80       	push   $0x801067d4
80101cde:	e8 65 e6 ff ff       	call   80100348 <panic>
80101ce3:	b8 30 00 00 00       	mov    $0x30,%eax
80101ce8:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101ced:	ee                   	out    %al,(%dx)
    outsl(0x1f0, b->data, BSIZE/4);
80101cee:	83 c6 5c             	add    $0x5c,%esi
  asm volatile("cld; rep outsl" :
80101cf1:	b9 80 00 00 00       	mov    $0x80,%ecx
80101cf6:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101cfb:	fc                   	cld    
80101cfc:	f3 6f                	rep outsl %ds:(%esi),(%dx)
80101cfe:	eb c2                	jmp    80101cc2 <idestart+0x7f>

80101d00 <ideinit>:
{
80101d00:	55                   	push   %ebp
80101d01:	89 e5                	mov    %esp,%ebp
80101d03:	83 ec 10             	sub    $0x10,%esp
  initlock(&idelock, "ide");
80101d06:	68 e6 67 10 80       	push   $0x801067e6
80101d0b:	68 80 a5 10 80       	push   $0x8010a580
80101d10:	e8 a0 1e 00 00       	call   80103bb5 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d15:	83 c4 08             	add    $0x8,%esp
80101d18:	a1 40 2d 13 80       	mov    0x80132d40,%eax
80101d1d:	83 e8 01             	sub    $0x1,%eax
80101d20:	50                   	push   %eax
80101d21:	6a 0e                	push   $0xe
80101d23:	e8 56 02 00 00       	call   80101f7e <ioapicenable>
  idewait(0);
80101d28:	b8 00 00 00 00       	mov    $0x0,%eax
80101d2d:	e8 df fe ff ff       	call   80101c11 <idewait>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d32:	b8 f0 ff ff ff       	mov    $0xfffffff0,%eax
80101d37:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d3c:	ee                   	out    %al,(%dx)
  for(i=0; i<1000; i++){
80101d3d:	83 c4 10             	add    $0x10,%esp
80101d40:	b9 00 00 00 00       	mov    $0x0,%ecx
80101d45:	81 f9 e7 03 00 00    	cmp    $0x3e7,%ecx
80101d4b:	7f 19                	jg     80101d66 <ideinit+0x66>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80101d4d:	ba f7 01 00 00       	mov    $0x1f7,%edx
80101d52:	ec                   	in     (%dx),%al
    if(inb(0x1f7) != 0){
80101d53:	84 c0                	test   %al,%al
80101d55:	75 05                	jne    80101d5c <ideinit+0x5c>
  for(i=0; i<1000; i++){
80101d57:	83 c1 01             	add    $0x1,%ecx
80101d5a:	eb e9                	jmp    80101d45 <ideinit+0x45>
      havedisk1 = 1;
80101d5c:	c7 05 60 a5 10 80 01 	movl   $0x1,0x8010a560
80101d63:	00 00 00 
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80101d66:	b8 e0 ff ff ff       	mov    $0xffffffe0,%eax
80101d6b:	ba f6 01 00 00       	mov    $0x1f6,%edx
80101d70:	ee                   	out    %al,(%dx)
}
80101d71:	c9                   	leave  
80101d72:	c3                   	ret    

80101d73 <ideintr>:

// Interrupt handler.
void
ideintr(void)
{
80101d73:	55                   	push   %ebp
80101d74:	89 e5                	mov    %esp,%ebp
80101d76:	57                   	push   %edi
80101d77:	53                   	push   %ebx
  struct buf *b;

  // First queued buffer is the active request.
  acquire(&idelock);
80101d78:	83 ec 0c             	sub    $0xc,%esp
80101d7b:	68 80 a5 10 80       	push   $0x8010a580
80101d80:	e8 6c 1f 00 00       	call   80103cf1 <acquire>

  if((b = idequeue) == 0){
80101d85:	8b 1d 64 a5 10 80    	mov    0x8010a564,%ebx
80101d8b:	83 c4 10             	add    $0x10,%esp
80101d8e:	85 db                	test   %ebx,%ebx
80101d90:	74 48                	je     80101dda <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d92:	8b 43 58             	mov    0x58(%ebx),%eax
80101d95:	a3 64 a5 10 80       	mov    %eax,0x8010a564

  // Read data if needed.
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101d9a:	f6 03 04             	testb  $0x4,(%ebx)
80101d9d:	74 4d                	je     80101dec <ideintr+0x79>
    insl(0x1f0, b->data, BSIZE/4);

  // Wake process waiting for this buf.
  b->flags |= B_VALID;
80101d9f:	8b 03                	mov    (%ebx),%eax
80101da1:	83 c8 02             	or     $0x2,%eax
  b->flags &= ~B_DIRTY;
80101da4:	83 e0 fb             	and    $0xfffffffb,%eax
80101da7:	89 03                	mov    %eax,(%ebx)
  wakeup(b);
80101da9:	83 ec 0c             	sub    $0xc,%esp
80101dac:	53                   	push   %ebx
80101dad:	e8 a9 1b 00 00       	call   8010395b <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101db2:	a1 64 a5 10 80       	mov    0x8010a564,%eax
80101db7:	83 c4 10             	add    $0x10,%esp
80101dba:	85 c0                	test   %eax,%eax
80101dbc:	74 05                	je     80101dc3 <ideintr+0x50>
    idestart(idequeue);
80101dbe:	e8 80 fe ff ff       	call   80101c43 <idestart>

  release(&idelock);
80101dc3:	83 ec 0c             	sub    $0xc,%esp
80101dc6:	68 80 a5 10 80       	push   $0x8010a580
80101dcb:	e8 86 1f 00 00       	call   80103d56 <release>
80101dd0:	83 c4 10             	add    $0x10,%esp
}
80101dd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dd6:	5b                   	pop    %ebx
80101dd7:	5f                   	pop    %edi
80101dd8:	5d                   	pop    %ebp
80101dd9:	c3                   	ret    
    release(&idelock);
80101dda:	83 ec 0c             	sub    $0xc,%esp
80101ddd:	68 80 a5 10 80       	push   $0x8010a580
80101de2:	e8 6f 1f 00 00       	call   80103d56 <release>
    return;
80101de7:	83 c4 10             	add    $0x10,%esp
80101dea:	eb e7                	jmp    80101dd3 <ideintr+0x60>
  if(!(b->flags & B_DIRTY) && idewait(1) >= 0)
80101dec:	b8 01 00 00 00       	mov    $0x1,%eax
80101df1:	e8 1b fe ff ff       	call   80101c11 <idewait>
80101df6:	85 c0                	test   %eax,%eax
80101df8:	78 a5                	js     80101d9f <ideintr+0x2c>
    insl(0x1f0, b->data, BSIZE/4);
80101dfa:	8d 7b 5c             	lea    0x5c(%ebx),%edi
  asm volatile("cld; rep insl" :
80101dfd:	b9 80 00 00 00       	mov    $0x80,%ecx
80101e02:	ba f0 01 00 00       	mov    $0x1f0,%edx
80101e07:	fc                   	cld    
80101e08:	f3 6d                	rep insl (%dx),%es:(%edi)
80101e0a:	eb 93                	jmp    80101d9f <ideintr+0x2c>

80101e0c <iderw>:
// Sync buf with disk.
// If B_DIRTY is set, write buf to disk, clear B_DIRTY, set B_VALID.
// Else if B_VALID is not set, read buf from disk, set B_VALID.
void
iderw(struct buf *b)
{
80101e0c:	55                   	push   %ebp
80101e0d:	89 e5                	mov    %esp,%ebp
80101e0f:	53                   	push   %ebx
80101e10:	83 ec 10             	sub    $0x10,%esp
80101e13:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct buf **pp;

  if(!holdingsleep(&b->lock))
80101e16:	8d 43 0c             	lea    0xc(%ebx),%eax
80101e19:	50                   	push   %eax
80101e1a:	e8 48 1d 00 00       	call   80103b67 <holdingsleep>
80101e1f:	83 c4 10             	add    $0x10,%esp
80101e22:	85 c0                	test   %eax,%eax
80101e24:	74 37                	je     80101e5d <iderw+0x51>
    panic("iderw: buf not locked");
  if((b->flags & (B_VALID|B_DIRTY)) == B_VALID)
80101e26:	8b 03                	mov    (%ebx),%eax
80101e28:	83 e0 06             	and    $0x6,%eax
80101e2b:	83 f8 02             	cmp    $0x2,%eax
80101e2e:	74 3a                	je     80101e6a <iderw+0x5e>
    panic("iderw: nothing to do");
  if(b->dev != 0 && !havedisk1)
80101e30:	83 7b 04 00          	cmpl   $0x0,0x4(%ebx)
80101e34:	74 09                	je     80101e3f <iderw+0x33>
80101e36:	83 3d 60 a5 10 80 00 	cmpl   $0x0,0x8010a560
80101e3d:	74 38                	je     80101e77 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	68 80 a5 10 80       	push   $0x8010a580
80101e47:	e8 a5 1e 00 00       	call   80103cf1 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e4c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e5b:	eb 2a                	jmp    80101e87 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e5d:	83 ec 0c             	sub    $0xc,%esp
80101e60:	68 ea 67 10 80       	push   $0x801067ea
80101e65:	e8 de e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 00 68 10 80       	push   $0x80106800
80101e72:	e8 d1 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e77:	83 ec 0c             	sub    $0xc,%esp
80101e7a:	68 15 68 10 80       	push   $0x80106815
80101e7f:	e8 c4 e4 ff ff       	call   80100348 <panic>
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e84:	8d 50 58             	lea    0x58(%eax),%edx
80101e87:	8b 02                	mov    (%edx),%eax
80101e89:	85 c0                	test   %eax,%eax
80101e8b:	75 f7                	jne    80101e84 <iderw+0x78>
    ;
  *pp = b;
80101e8d:	89 1a                	mov    %ebx,(%edx)

  // Start disk if necessary.
  if(idequeue == b)
80101e8f:	39 1d 64 a5 10 80    	cmp    %ebx,0x8010a564
80101e95:	75 1a                	jne    80101eb1 <iderw+0xa5>
    idestart(b);
80101e97:	89 d8                	mov    %ebx,%eax
80101e99:	e8 a5 fd ff ff       	call   80101c43 <idestart>
80101e9e:	eb 11                	jmp    80101eb1 <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101ea0:	83 ec 08             	sub    $0x8,%esp
80101ea3:	68 80 a5 10 80       	push   $0x8010a580
80101ea8:	53                   	push   %ebx
80101ea9:	e8 48 19 00 00       	call   801037f6 <sleep>
80101eae:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101eb1:	8b 03                	mov    (%ebx),%eax
80101eb3:	83 e0 06             	and    $0x6,%eax
80101eb6:	83 f8 02             	cmp    $0x2,%eax
80101eb9:	75 e5                	jne    80101ea0 <iderw+0x94>
  }


  release(&idelock);
80101ebb:	83 ec 0c             	sub    $0xc,%esp
80101ebe:	68 80 a5 10 80       	push   $0x8010a580
80101ec3:	e8 8e 1e 00 00       	call   80103d56 <release>
}
80101ec8:	83 c4 10             	add    $0x10,%esp
80101ecb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80101ece:	c9                   	leave  
80101ecf:	c3                   	ret    

80101ed0 <ioapicread>:
  uint data;
};

static uint
ioapicread(int reg)
{
80101ed0:	55                   	push   %ebp
80101ed1:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ed3:	8b 15 54 26 11 80    	mov    0x80112654,%edx
80101ed9:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101edb:	a1 54 26 11 80       	mov    0x80112654,%eax
80101ee0:	8b 40 10             	mov    0x10(%eax),%eax
}
80101ee3:	5d                   	pop    %ebp
80101ee4:	c3                   	ret    

80101ee5 <ioapicwrite>:

static void
ioapicwrite(int reg, uint data)
{
80101ee5:	55                   	push   %ebp
80101ee6:	89 e5                	mov    %esp,%ebp
  ioapic->reg = reg;
80101ee8:	8b 0d 54 26 11 80    	mov    0x80112654,%ecx
80101eee:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ef0:	a1 54 26 11 80       	mov    0x80112654,%eax
80101ef5:	89 50 10             	mov    %edx,0x10(%eax)
}
80101ef8:	5d                   	pop    %ebp
80101ef9:	c3                   	ret    

80101efa <ioapicinit>:

void
ioapicinit(void)
{
80101efa:	55                   	push   %ebp
80101efb:	89 e5                	mov    %esp,%ebp
80101efd:	57                   	push   %edi
80101efe:	56                   	push   %esi
80101eff:	53                   	push   %ebx
80101f00:	83 ec 0c             	sub    $0xc,%esp
  int i, id, maxintr;

  ioapic = (volatile struct ioapic*)IOAPIC;
80101f03:	c7 05 54 26 11 80 00 	movl   $0xfec00000,0x80112654
80101f0a:	00 c0 fe 
  maxintr = (ioapicread(REG_VER) >> 16) & 0xFF;
80101f0d:	b8 01 00 00 00       	mov    $0x1,%eax
80101f12:	e8 b9 ff ff ff       	call   80101ed0 <ioapicread>
80101f17:	c1 e8 10             	shr    $0x10,%eax
80101f1a:	0f b6 f8             	movzbl %al,%edi
  id = ioapicread(REG_ID) >> 24;
80101f1d:	b8 00 00 00 00       	mov    $0x0,%eax
80101f22:	e8 a9 ff ff ff       	call   80101ed0 <ioapicread>
80101f27:	c1 e8 18             	shr    $0x18,%eax
  if(id != ioapicid)
80101f2a:	0f b6 15 a0 27 13 80 	movzbl 0x801327a0,%edx
80101f31:	39 c2                	cmp    %eax,%edx
80101f33:	75 07                	jne    80101f3c <ioapicinit+0x42>
{
80101f35:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f3a:	eb 36                	jmp    80101f72 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f3c:	83 ec 0c             	sub    $0xc,%esp
80101f3f:	68 34 68 10 80       	push   $0x80106834
80101f44:	e8 c2 e6 ff ff       	call   8010060b <cprintf>
80101f49:	83 c4 10             	add    $0x10,%esp
80101f4c:	eb e7                	jmp    80101f35 <ioapicinit+0x3b>

  // Mark all interrupts edge-triggered, active high, disabled,
  // and not routed to any CPUs.
  for(i = 0; i <= maxintr; i++){
    ioapicwrite(REG_TABLE+2*i, INT_DISABLED | (T_IRQ0 + i));
80101f4e:	8d 53 20             	lea    0x20(%ebx),%edx
80101f51:	81 ca 00 00 01 00    	or     $0x10000,%edx
80101f57:	8d 74 1b 10          	lea    0x10(%ebx,%ebx,1),%esi
80101f5b:	89 f0                	mov    %esi,%eax
80101f5d:	e8 83 ff ff ff       	call   80101ee5 <ioapicwrite>
    ioapicwrite(REG_TABLE+2*i+1, 0);
80101f62:	8d 46 01             	lea    0x1(%esi),%eax
80101f65:	ba 00 00 00 00       	mov    $0x0,%edx
80101f6a:	e8 76 ff ff ff       	call   80101ee5 <ioapicwrite>
  for(i = 0; i <= maxintr; i++){
80101f6f:	83 c3 01             	add    $0x1,%ebx
80101f72:	39 fb                	cmp    %edi,%ebx
80101f74:	7e d8                	jle    80101f4e <ioapicinit+0x54>
  }
}
80101f76:	8d 65 f4             	lea    -0xc(%ebp),%esp
80101f79:	5b                   	pop    %ebx
80101f7a:	5e                   	pop    %esi
80101f7b:	5f                   	pop    %edi
80101f7c:	5d                   	pop    %ebp
80101f7d:	c3                   	ret    

80101f7e <ioapicenable>:

void
ioapicenable(int irq, int cpunum)
{
80101f7e:	55                   	push   %ebp
80101f7f:	89 e5                	mov    %esp,%ebp
80101f81:	53                   	push   %ebx
80101f82:	8b 45 08             	mov    0x8(%ebp),%eax
  // Mark interrupt edge-triggered, active high,
  // enabled, and routed to the given cpunum,
  // which happens to be that cpu's APIC ID.
  ioapicwrite(REG_TABLE+2*irq, T_IRQ0 + irq);
80101f85:	8d 50 20             	lea    0x20(%eax),%edx
80101f88:	8d 5c 00 10          	lea    0x10(%eax,%eax,1),%ebx
80101f8c:	89 d8                	mov    %ebx,%eax
80101f8e:	e8 52 ff ff ff       	call   80101ee5 <ioapicwrite>
  ioapicwrite(REG_TABLE+2*irq+1, cpunum << 24);
80101f93:	8b 55 0c             	mov    0xc(%ebp),%edx
80101f96:	c1 e2 18             	shl    $0x18,%edx
80101f99:	8d 43 01             	lea    0x1(%ebx),%eax
80101f9c:	e8 44 ff ff ff       	call   80101ee5 <ioapicwrite>
}
80101fa1:	5b                   	pop    %ebx
80101fa2:	5d                   	pop    %ebp
80101fa3:	c3                   	ret    

80101fa4 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80101fa4:	55                   	push   %ebp
80101fa5:	89 e5                	mov    %esp,%ebp
80101fa7:	53                   	push   %ebx
80101fa8:	83 ec 04             	sub    $0x4,%esp
80101fab:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101fae:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fb4:	75 4c                	jne    80102002 <kfree+0x5e>
80101fb6:	81 fb e8 54 13 80    	cmp    $0x801354e8,%ebx
80101fbc:	72 44                	jb     80102002 <kfree+0x5e>
80101fbe:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80101fc4:	3d ff ff ff 0d       	cmp    $0xdffffff,%eax
80101fc9:	77 37                	ja     80102002 <kfree+0x5e>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fcb:	83 ec 04             	sub    $0x4,%esp
80101fce:	68 00 10 00 00       	push   $0x1000
80101fd3:	6a 01                	push   $0x1
80101fd5:	53                   	push   %ebx
80101fd6:	e8 c2 1d 00 00       	call   80103d9d <memset>
  // p5 - v1
  //memset(v, 1, PGSIZE*2);
  // p5

  if(kmem.use_lock)
80101fdb:	83 c4 10             	add    $0x10,%esp
80101fde:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
80101fe5:	75 28                	jne    8010200f <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;
80101fe7:	a1 98 26 11 80       	mov    0x80112698,%eax
80101fec:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fee:	89 1d 98 26 11 80    	mov    %ebx,0x80112698
  if(kmem.use_lock)
80101ff4:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
80101ffb:	75 24                	jne    80102021 <kfree+0x7d>
    release(&kmem.lock);
}
80101ffd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102000:	c9                   	leave  
80102001:	c3                   	ret    
    panic("kfree");
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	68 66 68 10 80       	push   $0x80106866
8010200a:	e8 39 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
80102012:	68 60 26 11 80       	push   $0x80112660
80102017:	e8 d5 1c 00 00       	call   80103cf1 <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 60 26 11 80       	push   $0x80112660
80102029:	e8 28 1d 00 00       	call   80103d56 <release>
8010202e:	83 c4 10             	add    $0x10,%esp
}
80102031:	eb ca                	jmp    80101ffd <kfree+0x59>

80102033 <freerange>:
{
80102033:	55                   	push   %ebp
80102034:	89 e5                	mov    %esp,%ebp
80102036:	56                   	push   %esi
80102037:	53                   	push   %ebx
80102038:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
8010203b:	8b 45 08             	mov    0x8(%ebp),%eax
8010203e:	05 ff 0f 00 00       	add    $0xfff,%eax
80102043:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102048:	eb 0e                	jmp    80102058 <freerange+0x25>
    kfree(p);
8010204a:	83 ec 0c             	sub    $0xc,%esp
8010204d:	50                   	push   %eax
8010204e:	e8 51 ff ff ff       	call   80101fa4 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102053:	83 c4 10             	add    $0x10,%esp
80102056:	89 f0                	mov    %esi,%eax
80102058:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
8010205e:	39 de                	cmp    %ebx,%esi
80102060:	76 e8                	jbe    8010204a <freerange+0x17>
}
80102062:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102065:	5b                   	pop    %ebx
80102066:	5e                   	pop    %esi
80102067:	5d                   	pop    %ebp
80102068:	c3                   	ret    

80102069 <kinit1>:
{
80102069:	55                   	push   %ebp
8010206a:	89 e5                	mov    %esp,%ebp
8010206c:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
8010206f:	68 6c 68 10 80       	push   $0x8010686c
80102074:	68 60 26 11 80       	push   $0x80112660
80102079:	e8 37 1b 00 00       	call   80103bb5 <initlock>
  kmem.use_lock = 0;
8010207e:	c7 05 94 26 11 80 00 	movl   $0x0,0x80112694
80102085:	00 00 00 
  freerange(vstart, vend);
80102088:	83 c4 08             	add    $0x8,%esp
8010208b:	ff 75 0c             	pushl  0xc(%ebp)
8010208e:	ff 75 08             	pushl  0x8(%ebp)
80102091:	e8 9d ff ff ff       	call   80102033 <freerange>
}
80102096:	83 c4 10             	add    $0x10,%esp
80102099:	c9                   	leave  
8010209a:	c3                   	ret    

8010209b <kinit2>:
{
8010209b:	55                   	push   %ebp
8010209c:	89 e5                	mov    %esp,%ebp
8010209e:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020a1:	ff 75 0c             	pushl  0xc(%ebp)
801020a4:	ff 75 08             	pushl  0x8(%ebp)
801020a7:	e8 87 ff ff ff       	call   80102033 <freerange>
  kmem.use_lock = 1;
801020ac:	c7 05 94 26 11 80 01 	movl   $0x1,0x80112694
801020b3:	00 00 00 
  flagofinit = 1;
801020b6:	c7 05 b4 a5 10 80 01 	movl   $0x1,0x8010a5b4
801020bd:	00 00 00 
}
801020c0:	83 c4 10             	add    $0x10,%esp
801020c3:	c9                   	leave  
801020c4:	c3                   	ret    

801020c5 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020c5:	55                   	push   %ebp
801020c6:	89 e5                	mov    %esp,%ebp
801020c8:	53                   	push   %ebx
801020c9:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020cc:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
801020d3:	75 33                	jne    80102108 <kalloc+0x43>
    acquire(&kmem.lock);
  //r = kmem.freelist;
  // p5
  if(flagofinit == 1) {
801020d5:	83 3d b4 a5 10 80 01 	cmpl   $0x1,0x8010a5b4
801020dc:	74 3c                	je     8010211a <kalloc+0x55>
      firsttime = 0;
    } else {
      r = kmem.freelist->next;
    }
  } else {
    r = kmem.freelist;
801020de:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
  }
  // p5
  if(r)
801020e4:	85 db                	test   %ebx,%ebx
801020e6:	74 07                	je     801020ef <kalloc+0x2a>
    kmem.freelist = r->next;
801020e8:	8b 03                	mov    (%ebx),%eax
801020ea:	a3 98 26 11 80       	mov    %eax,0x80112698
  if(kmem.use_lock)
801020ef:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
801020f6:	75 46                	jne    8010213e <kalloc+0x79>
    release(&kmem.lock);
  
  // p5
  if(flagofinit == 1) {
801020f8:	83 3d b4 a5 10 80 01 	cmpl   $0x1,0x8010a5b4
801020ff:	74 4f                	je     80102150 <kalloc+0x8b>
    //cprintf("allocuvm: frames[%d] = %x, pids[%d] = %d\n", index, frames[index], index, pids[index]);
    index++;
  }
  // p5
  return (char*)r;
}
80102101:	89 d8                	mov    %ebx,%eax
80102103:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102106:	c9                   	leave  
80102107:	c3                   	ret    
    acquire(&kmem.lock);
80102108:	83 ec 0c             	sub    $0xc,%esp
8010210b:	68 60 26 11 80       	push   $0x80112660
80102110:	e8 dc 1b 00 00       	call   80103cf1 <acquire>
80102115:	83 c4 10             	add    $0x10,%esp
80102118:	eb bb                	jmp    801020d5 <kalloc+0x10>
    if(firsttime == 1) {
8010211a:	83 3d 00 80 10 80 01 	cmpl   $0x1,0x80108000
80102121:	74 09                	je     8010212c <kalloc+0x67>
      r = kmem.freelist->next;
80102123:	a1 98 26 11 80       	mov    0x80112698,%eax
80102128:	8b 18                	mov    (%eax),%ebx
8010212a:	eb b8                	jmp    801020e4 <kalloc+0x1f>
      r = kmem.freelist;
8010212c:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
      firsttime = 0;
80102132:	c7 05 00 80 10 80 00 	movl   $0x0,0x80108000
80102139:	00 00 00 
8010213c:	eb a6                	jmp    801020e4 <kalloc+0x1f>
    release(&kmem.lock);
8010213e:	83 ec 0c             	sub    $0xc,%esp
80102141:	68 60 26 11 80       	push   $0x80112660
80102146:	e8 0b 1c 00 00       	call   80103d56 <release>
8010214b:	83 c4 10             	add    $0x10,%esp
8010214e:	eb a8                	jmp    801020f8 <kalloc+0x33>
    uint pfn = V2P((char*)r) >> 12;
80102150:	8d 93 00 00 00 80    	lea    -0x80000000(%ebx),%edx
80102156:	c1 ea 0c             	shr    $0xc,%edx
    frames[index] = pfn;
80102159:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
8010215e:	89 14 85 a0 26 11 80 	mov    %edx,-0x7feed960(,%eax,4)
    pids[index] = -2; //myproc()->pid; // can I get pid here?
80102165:	c7 04 85 a0 26 12 80 	movl   $0xfffffffe,-0x7fedd960(,%eax,4)
8010216c:	fe ff ff ff 
    index++;
80102170:	83 c0 01             	add    $0x1,%eax
80102173:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  return (char*)r;
80102178:	eb 87                	jmp    80102101 <kalloc+0x3c>

8010217a <kalloc1>:

// used for p5
char*
kalloc1(int pid)
{
8010217a:	55                   	push   %ebp
8010217b:	89 e5                	mov    %esp,%ebp
8010217d:	56                   	push   %esi
8010217e:	53                   	push   %ebx
  struct run *r;

  if(kmem.use_lock)
8010217f:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
80102186:	75 7b                	jne    80102203 <kalloc1+0x89>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102188:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
  if(r) {
8010218e:	85 db                	test   %ebx,%ebx
80102190:	74 5f                	je     801021f1 <kalloc1+0x77>
    kmem.freelist = r->next;
80102192:	8b 03                	mov    (%ebx),%eax
80102194:	a3 98 26 11 80       	mov    %eax,0x80112698
    // p5
    cprintf("kalloc1 return addr w/ %x\n", V2P((char*)r));
80102199:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
8010219f:	83 ec 08             	sub    $0x8,%esp
801021a2:	56                   	push   %esi
801021a3:	68 71 68 10 80       	push   $0x80106871
801021a8:	e8 5e e4 ff ff       	call   8010060b <cprintf>
    uint pfn = V2P((char*)r) >> 12;
801021ad:	c1 ee 0c             	shr    $0xc,%esi
    frames[index] = pfn;
801021b0:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
801021b5:	89 34 85 a0 26 11 80 	mov    %esi,-0x7feed960(,%eax,4)
    pids[index] = myproc()->pid; // can I get pid here?
801021bc:	e8 91 11 00 00       	call   80103352 <myproc>
801021c1:	8b 15 b8 a5 10 80    	mov    0x8010a5b8,%edx
801021c7:	8b 40 10             	mov    0x10(%eax),%eax
801021ca:	89 04 95 a0 26 12 80 	mov    %eax,-0x7fedd960(,%edx,4)
    cprintf("allocuvm: frames[%d] = %x, pids[%d] = %d\n", index, frames[index], index, pids[index]);
801021d1:	89 04 24             	mov    %eax,(%esp)
801021d4:	52                   	push   %edx
801021d5:	ff 34 95 a0 26 11 80 	pushl  -0x7feed960(,%edx,4)
801021dc:	52                   	push   %edx
801021dd:	68 8c 68 10 80       	push   $0x8010688c
801021e2:	e8 24 e4 ff ff       	call   8010060b <cprintf>
    index++;
801021e7:	83 05 b8 a5 10 80 01 	addl   $0x1,0x8010a5b8
801021ee:	83 c4 20             	add    $0x20,%esp
    // p5
  }
  if(kmem.use_lock)
801021f1:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
801021f8:	75 1e                	jne    80102218 <kalloc1+0x9e>
    release(&kmem.lock);
  
  return (char*)r;
}
801021fa:	89 d8                	mov    %ebx,%eax
801021fc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801021ff:	5b                   	pop    %ebx
80102200:	5e                   	pop    %esi
80102201:	5d                   	pop    %ebp
80102202:	c3                   	ret    
    acquire(&kmem.lock);
80102203:	83 ec 0c             	sub    $0xc,%esp
80102206:	68 60 26 11 80       	push   $0x80112660
8010220b:	e8 e1 1a 00 00       	call   80103cf1 <acquire>
80102210:	83 c4 10             	add    $0x10,%esp
80102213:	e9 70 ff ff ff       	jmp    80102188 <kalloc1+0xe>
    release(&kmem.lock);
80102218:	83 ec 0c             	sub    $0xc,%esp
8010221b:	68 60 26 11 80       	push   $0x80112660
80102220:	e8 31 1b 00 00       	call   80103d56 <release>
80102225:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102228:	eb d0                	jmp    801021fa <kalloc1+0x80>

8010222a <dump_physmem>:

// used for p5
// by sysproc.c
int
dump_physmem(int *uframes, int *upids, int numframes)
{
8010222a:	55                   	push   %ebp
8010222b:	89 e5                	mov    %esp,%ebp
8010222d:	57                   	push   %edi
8010222e:	56                   	push   %esi
8010222f:	53                   	push   %ebx
80102230:	8b 7d 08             	mov    0x8(%ebp),%edi
80102233:	8b 75 0c             	mov    0xc(%ebp),%esi
80102236:	8b 5d 10             	mov    0x10(%ebp),%ebx
  //cprintf("dump_physmem in kalloc.c\n");
  for(int i = 0; i < numframes; i++) {
80102239:	b8 00 00 00 00       	mov    $0x0,%eax
8010223e:	eb 1e                	jmp    8010225e <dump_physmem+0x34>
    //cprintf("  uframes[%d] = frames[%d](%d);\n", i, i, frames[i]);
    //cprintf("  upids[%d] = pids[%d](%d);\n", i, i, pids[i]);
    uframes[i] = frames[i];
80102240:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102247:	8b 0c 85 a0 26 11 80 	mov    -0x7feed960(,%eax,4),%ecx
8010224e:	89 0c 17             	mov    %ecx,(%edi,%edx,1)
    upids[i] = pids[i];
80102251:	8b 0c 85 a0 26 12 80 	mov    -0x7fedd960(,%eax,4),%ecx
80102258:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
  for(int i = 0; i < numframes; i++) {
8010225b:	83 c0 01             	add    $0x1,%eax
8010225e:	39 d8                	cmp    %ebx,%eax
80102260:	7c de                	jl     80102240 <dump_physmem+0x16>
  }
  //cprintf("leaving dump_physmem in kalloc.c\n");
  return 0;
}
80102262:	b8 00 00 00 00       	mov    $0x0,%eax
80102267:	5b                   	pop    %ebx
80102268:	5e                   	pop    %esi
80102269:	5f                   	pop    %edi
8010226a:	5d                   	pop    %ebp
8010226b:	c3                   	ret    

8010226c <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
8010226c:	55                   	push   %ebp
8010226d:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010226f:	ba 64 00 00 00       	mov    $0x64,%edx
80102274:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
80102275:	a8 01                	test   $0x1,%al
80102277:	0f 84 b5 00 00 00    	je     80102332 <kbdgetc+0xc6>
8010227d:	ba 60 00 00 00       	mov    $0x60,%edx
80102282:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102283:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
80102286:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
8010228c:	74 5c                	je     801022ea <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
8010228e:	84 c0                	test   %al,%al
80102290:	78 66                	js     801022f8 <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102292:	8b 0d bc a5 10 80    	mov    0x8010a5bc,%ecx
80102298:	f6 c1 40             	test   $0x40,%cl
8010229b:	74 0f                	je     801022ac <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010229d:	83 c8 80             	or     $0xffffff80,%eax
801022a0:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
801022a3:	83 e1 bf             	and    $0xffffffbf,%ecx
801022a6:	89 0d bc a5 10 80    	mov    %ecx,0x8010a5bc
  }

  shift |= shiftcode[data];
801022ac:	0f b6 8a e0 69 10 80 	movzbl -0x7fef9620(%edx),%ecx
801022b3:	0b 0d bc a5 10 80    	or     0x8010a5bc,%ecx
  shift ^= togglecode[data];
801022b9:	0f b6 82 e0 68 10 80 	movzbl -0x7fef9720(%edx),%eax
801022c0:	31 c1                	xor    %eax,%ecx
801022c2:	89 0d bc a5 10 80    	mov    %ecx,0x8010a5bc
  c = charcode[shift & (CTL | SHIFT)][data];
801022c8:	89 c8                	mov    %ecx,%eax
801022ca:	83 e0 03             	and    $0x3,%eax
801022cd:	8b 04 85 c0 68 10 80 	mov    -0x7fef9740(,%eax,4),%eax
801022d4:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801022d8:	f6 c1 08             	test   $0x8,%cl
801022db:	74 19                	je     801022f6 <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
801022dd:	8d 50 9f             	lea    -0x61(%eax),%edx
801022e0:	83 fa 19             	cmp    $0x19,%edx
801022e3:	77 40                	ja     80102325 <kbdgetc+0xb9>
      c += 'A' - 'a';
801022e5:	83 e8 20             	sub    $0x20,%eax
801022e8:	eb 0c                	jmp    801022f6 <kbdgetc+0x8a>
    shift |= E0ESC;
801022ea:	83 0d bc a5 10 80 40 	orl    $0x40,0x8010a5bc
    return 0;
801022f1:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801022f6:	5d                   	pop    %ebp
801022f7:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801022f8:	8b 0d bc a5 10 80    	mov    0x8010a5bc,%ecx
801022fe:	f6 c1 40             	test   $0x40,%cl
80102301:	75 05                	jne    80102308 <kbdgetc+0x9c>
80102303:	89 c2                	mov    %eax,%edx
80102305:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
80102308:	0f b6 82 e0 69 10 80 	movzbl -0x7fef9620(%edx),%eax
8010230f:	83 c8 40             	or     $0x40,%eax
80102312:	0f b6 c0             	movzbl %al,%eax
80102315:	f7 d0                	not    %eax
80102317:	21 c8                	and    %ecx,%eax
80102319:	a3 bc a5 10 80       	mov    %eax,0x8010a5bc
    return 0;
8010231e:	b8 00 00 00 00       	mov    $0x0,%eax
80102323:	eb d1                	jmp    801022f6 <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
80102325:	8d 50 bf             	lea    -0x41(%eax),%edx
80102328:	83 fa 19             	cmp    $0x19,%edx
8010232b:	77 c9                	ja     801022f6 <kbdgetc+0x8a>
      c += 'a' - 'A';
8010232d:	83 c0 20             	add    $0x20,%eax
  return c;
80102330:	eb c4                	jmp    801022f6 <kbdgetc+0x8a>
    return -1;
80102332:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102337:	eb bd                	jmp    801022f6 <kbdgetc+0x8a>

80102339 <kbdintr>:

void
kbdintr(void)
{
80102339:	55                   	push   %ebp
8010233a:	89 e5                	mov    %esp,%ebp
8010233c:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
8010233f:	68 6c 22 10 80       	push   $0x8010226c
80102344:	e8 f5 e3 ff ff       	call   8010073e <consoleintr>
}
80102349:	83 c4 10             	add    $0x10,%esp
8010234c:	c9                   	leave  
8010234d:	c3                   	ret    

8010234e <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
8010234e:	55                   	push   %ebp
8010234f:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102351:	8b 0d a0 26 13 80    	mov    0x801326a0,%ecx
80102357:	8d 04 81             	lea    (%ecx,%eax,4),%eax
8010235a:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
8010235c:	a1 a0 26 13 80       	mov    0x801326a0,%eax
80102361:	8b 40 20             	mov    0x20(%eax),%eax
}
80102364:	5d                   	pop    %ebp
80102365:	c3                   	ret    

80102366 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80102366:	55                   	push   %ebp
80102367:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102369:	ba 70 00 00 00       	mov    $0x70,%edx
8010236e:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010236f:	ba 71 00 00 00       	mov    $0x71,%edx
80102374:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
80102375:	0f b6 c0             	movzbl %al,%eax
}
80102378:	5d                   	pop    %ebp
80102379:	c3                   	ret    

8010237a <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
8010237a:	55                   	push   %ebp
8010237b:	89 e5                	mov    %esp,%ebp
8010237d:	53                   	push   %ebx
8010237e:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102380:	b8 00 00 00 00       	mov    $0x0,%eax
80102385:	e8 dc ff ff ff       	call   80102366 <cmos_read>
8010238a:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
8010238c:	b8 02 00 00 00       	mov    $0x2,%eax
80102391:	e8 d0 ff ff ff       	call   80102366 <cmos_read>
80102396:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
80102399:	b8 04 00 00 00       	mov    $0x4,%eax
8010239e:	e8 c3 ff ff ff       	call   80102366 <cmos_read>
801023a3:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801023a6:	b8 07 00 00 00       	mov    $0x7,%eax
801023ab:	e8 b6 ff ff ff       	call   80102366 <cmos_read>
801023b0:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801023b3:	b8 08 00 00 00       	mov    $0x8,%eax
801023b8:	e8 a9 ff ff ff       	call   80102366 <cmos_read>
801023bd:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801023c0:	b8 09 00 00 00       	mov    $0x9,%eax
801023c5:	e8 9c ff ff ff       	call   80102366 <cmos_read>
801023ca:	89 43 14             	mov    %eax,0x14(%ebx)
}
801023cd:	5b                   	pop    %ebx
801023ce:	5d                   	pop    %ebp
801023cf:	c3                   	ret    

801023d0 <lapicinit>:
  if(!lapic)
801023d0:	83 3d a0 26 13 80 00 	cmpl   $0x0,0x801326a0
801023d7:	0f 84 fb 00 00 00    	je     801024d8 <lapicinit+0x108>
{
801023dd:	55                   	push   %ebp
801023de:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801023e0:	ba 3f 01 00 00       	mov    $0x13f,%edx
801023e5:	b8 3c 00 00 00       	mov    $0x3c,%eax
801023ea:	e8 5f ff ff ff       	call   8010234e <lapicw>
  lapicw(TDCR, X1);
801023ef:	ba 0b 00 00 00       	mov    $0xb,%edx
801023f4:	b8 f8 00 00 00       	mov    $0xf8,%eax
801023f9:	e8 50 ff ff ff       	call   8010234e <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801023fe:	ba 20 00 02 00       	mov    $0x20020,%edx
80102403:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102408:	e8 41 ff ff ff       	call   8010234e <lapicw>
  lapicw(TICR, 10000000);
8010240d:	ba 80 96 98 00       	mov    $0x989680,%edx
80102412:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102417:	e8 32 ff ff ff       	call   8010234e <lapicw>
  lapicw(LINT0, MASKED);
8010241c:	ba 00 00 01 00       	mov    $0x10000,%edx
80102421:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102426:	e8 23 ff ff ff       	call   8010234e <lapicw>
  lapicw(LINT1, MASKED);
8010242b:	ba 00 00 01 00       	mov    $0x10000,%edx
80102430:	b8 d8 00 00 00       	mov    $0xd8,%eax
80102435:	e8 14 ff ff ff       	call   8010234e <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
8010243a:	a1 a0 26 13 80       	mov    0x801326a0,%eax
8010243f:	8b 40 30             	mov    0x30(%eax),%eax
80102442:	c1 e8 10             	shr    $0x10,%eax
80102445:	3c 03                	cmp    $0x3,%al
80102447:	77 7b                	ja     801024c4 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102449:	ba 33 00 00 00       	mov    $0x33,%edx
8010244e:	b8 dc 00 00 00       	mov    $0xdc,%eax
80102453:	e8 f6 fe ff ff       	call   8010234e <lapicw>
  lapicw(ESR, 0);
80102458:	ba 00 00 00 00       	mov    $0x0,%edx
8010245d:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102462:	e8 e7 fe ff ff       	call   8010234e <lapicw>
  lapicw(ESR, 0);
80102467:	ba 00 00 00 00       	mov    $0x0,%edx
8010246c:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102471:	e8 d8 fe ff ff       	call   8010234e <lapicw>
  lapicw(EOI, 0);
80102476:	ba 00 00 00 00       	mov    $0x0,%edx
8010247b:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102480:	e8 c9 fe ff ff       	call   8010234e <lapicw>
  lapicw(ICRHI, 0);
80102485:	ba 00 00 00 00       	mov    $0x0,%edx
8010248a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010248f:	e8 ba fe ff ff       	call   8010234e <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102494:	ba 00 85 08 00       	mov    $0x88500,%edx
80102499:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010249e:	e8 ab fe ff ff       	call   8010234e <lapicw>
  while(lapic[ICRLO] & DELIVS)
801024a3:	a1 a0 26 13 80       	mov    0x801326a0,%eax
801024a8:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801024ae:	f6 c4 10             	test   $0x10,%ah
801024b1:	75 f0                	jne    801024a3 <lapicinit+0xd3>
  lapicw(TPR, 0);
801024b3:	ba 00 00 00 00       	mov    $0x0,%edx
801024b8:	b8 20 00 00 00       	mov    $0x20,%eax
801024bd:	e8 8c fe ff ff       	call   8010234e <lapicw>
}
801024c2:	5d                   	pop    %ebp
801024c3:	c3                   	ret    
    lapicw(PCINT, MASKED);
801024c4:	ba 00 00 01 00       	mov    $0x10000,%edx
801024c9:	b8 d0 00 00 00       	mov    $0xd0,%eax
801024ce:	e8 7b fe ff ff       	call   8010234e <lapicw>
801024d3:	e9 71 ff ff ff       	jmp    80102449 <lapicinit+0x79>
801024d8:	f3 c3                	repz ret 

801024da <lapicid>:
{
801024da:	55                   	push   %ebp
801024db:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801024dd:	a1 a0 26 13 80       	mov    0x801326a0,%eax
801024e2:	85 c0                	test   %eax,%eax
801024e4:	74 08                	je     801024ee <lapicid+0x14>
  return lapic[ID] >> 24;
801024e6:	8b 40 20             	mov    0x20(%eax),%eax
801024e9:	c1 e8 18             	shr    $0x18,%eax
}
801024ec:	5d                   	pop    %ebp
801024ed:	c3                   	ret    
    return 0;
801024ee:	b8 00 00 00 00       	mov    $0x0,%eax
801024f3:	eb f7                	jmp    801024ec <lapicid+0x12>

801024f5 <lapiceoi>:
  if(lapic)
801024f5:	83 3d a0 26 13 80 00 	cmpl   $0x0,0x801326a0
801024fc:	74 14                	je     80102512 <lapiceoi+0x1d>
{
801024fe:	55                   	push   %ebp
801024ff:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
80102501:	ba 00 00 00 00       	mov    $0x0,%edx
80102506:	b8 2c 00 00 00       	mov    $0x2c,%eax
8010250b:	e8 3e fe ff ff       	call   8010234e <lapicw>
}
80102510:	5d                   	pop    %ebp
80102511:	c3                   	ret    
80102512:	f3 c3                	repz ret 

80102514 <microdelay>:
{
80102514:	55                   	push   %ebp
80102515:	89 e5                	mov    %esp,%ebp
}
80102517:	5d                   	pop    %ebp
80102518:	c3                   	ret    

80102519 <lapicstartap>:
{
80102519:	55                   	push   %ebp
8010251a:	89 e5                	mov    %esp,%ebp
8010251c:	57                   	push   %edi
8010251d:	56                   	push   %esi
8010251e:	53                   	push   %ebx
8010251f:	8b 75 08             	mov    0x8(%ebp),%esi
80102522:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102525:	b8 0f 00 00 00       	mov    $0xf,%eax
8010252a:	ba 70 00 00 00       	mov    $0x70,%edx
8010252f:	ee                   	out    %al,(%dx)
80102530:	b8 0a 00 00 00       	mov    $0xa,%eax
80102535:	ba 71 00 00 00       	mov    $0x71,%edx
8010253a:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
8010253b:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102542:	00 00 
  wrv[1] = addr >> 4;
80102544:	89 f8                	mov    %edi,%eax
80102546:	c1 e8 04             	shr    $0x4,%eax
80102549:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
8010254f:	c1 e6 18             	shl    $0x18,%esi
80102552:	89 f2                	mov    %esi,%edx
80102554:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102559:	e8 f0 fd ff ff       	call   8010234e <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
8010255e:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102563:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102568:	e8 e1 fd ff ff       	call   8010234e <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
8010256d:	ba 00 85 00 00       	mov    $0x8500,%edx
80102572:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102577:	e8 d2 fd ff ff       	call   8010234e <lapicw>
  for(i = 0; i < 2; i++){
8010257c:	bb 00 00 00 00       	mov    $0x0,%ebx
80102581:	eb 21                	jmp    801025a4 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
80102583:	89 f2                	mov    %esi,%edx
80102585:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010258a:	e8 bf fd ff ff       	call   8010234e <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
8010258f:	89 fa                	mov    %edi,%edx
80102591:	c1 ea 0c             	shr    $0xc,%edx
80102594:	80 ce 06             	or     $0x6,%dh
80102597:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010259c:	e8 ad fd ff ff       	call   8010234e <lapicw>
  for(i = 0; i < 2; i++){
801025a1:	83 c3 01             	add    $0x1,%ebx
801025a4:	83 fb 01             	cmp    $0x1,%ebx
801025a7:	7e da                	jle    80102583 <lapicstartap+0x6a>
}
801025a9:	5b                   	pop    %ebx
801025aa:	5e                   	pop    %esi
801025ab:	5f                   	pop    %edi
801025ac:	5d                   	pop    %ebp
801025ad:	c3                   	ret    

801025ae <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801025ae:	55                   	push   %ebp
801025af:	89 e5                	mov    %esp,%ebp
801025b1:	57                   	push   %edi
801025b2:	56                   	push   %esi
801025b3:	53                   	push   %ebx
801025b4:	83 ec 3c             	sub    $0x3c,%esp
801025b7:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801025ba:	b8 0b 00 00 00       	mov    $0xb,%eax
801025bf:	e8 a2 fd ff ff       	call   80102366 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801025c4:	83 e0 04             	and    $0x4,%eax
801025c7:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801025c9:	8d 45 d0             	lea    -0x30(%ebp),%eax
801025cc:	e8 a9 fd ff ff       	call   8010237a <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801025d1:	b8 0a 00 00 00       	mov    $0xa,%eax
801025d6:	e8 8b fd ff ff       	call   80102366 <cmos_read>
801025db:	a8 80                	test   $0x80,%al
801025dd:	75 ea                	jne    801025c9 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801025df:	8d 5d b8             	lea    -0x48(%ebp),%ebx
801025e2:	89 d8                	mov    %ebx,%eax
801025e4:	e8 91 fd ff ff       	call   8010237a <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801025e9:	83 ec 04             	sub    $0x4,%esp
801025ec:	6a 18                	push   $0x18
801025ee:	53                   	push   %ebx
801025ef:	8d 45 d0             	lea    -0x30(%ebp),%eax
801025f2:	50                   	push   %eax
801025f3:	e8 eb 17 00 00       	call   80103de3 <memcmp>
801025f8:	83 c4 10             	add    $0x10,%esp
801025fb:	85 c0                	test   %eax,%eax
801025fd:	75 ca                	jne    801025c9 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801025ff:	85 ff                	test   %edi,%edi
80102601:	0f 85 84 00 00 00    	jne    8010268b <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102607:	8b 55 d0             	mov    -0x30(%ebp),%edx
8010260a:	89 d0                	mov    %edx,%eax
8010260c:	c1 e8 04             	shr    $0x4,%eax
8010260f:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102612:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102615:	83 e2 0f             	and    $0xf,%edx
80102618:	01 d0                	add    %edx,%eax
8010261a:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
8010261d:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102620:	89 d0                	mov    %edx,%eax
80102622:	c1 e8 04             	shr    $0x4,%eax
80102625:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102628:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010262b:	83 e2 0f             	and    $0xf,%edx
8010262e:	01 d0                	add    %edx,%eax
80102630:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102633:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102636:	89 d0                	mov    %edx,%eax
80102638:	c1 e8 04             	shr    $0x4,%eax
8010263b:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010263e:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102641:	83 e2 0f             	and    $0xf,%edx
80102644:	01 d0                	add    %edx,%eax
80102646:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102649:	8b 55 dc             	mov    -0x24(%ebp),%edx
8010264c:	89 d0                	mov    %edx,%eax
8010264e:	c1 e8 04             	shr    $0x4,%eax
80102651:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102654:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102657:	83 e2 0f             	and    $0xf,%edx
8010265a:	01 d0                	add    %edx,%eax
8010265c:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
8010265f:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102662:	89 d0                	mov    %edx,%eax
80102664:	c1 e8 04             	shr    $0x4,%eax
80102667:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010266a:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010266d:	83 e2 0f             	and    $0xf,%edx
80102670:	01 d0                	add    %edx,%eax
80102672:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
80102675:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102678:	89 d0                	mov    %edx,%eax
8010267a:	c1 e8 04             	shr    $0x4,%eax
8010267d:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102680:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102683:	83 e2 0f             	and    $0xf,%edx
80102686:	01 d0                	add    %edx,%eax
80102688:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
8010268b:	8b 45 d0             	mov    -0x30(%ebp),%eax
8010268e:	89 06                	mov    %eax,(%esi)
80102690:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102693:	89 46 04             	mov    %eax,0x4(%esi)
80102696:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102699:	89 46 08             	mov    %eax,0x8(%esi)
8010269c:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010269f:	89 46 0c             	mov    %eax,0xc(%esi)
801026a2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801026a5:	89 46 10             	mov    %eax,0x10(%esi)
801026a8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801026ab:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801026ae:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
801026b5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801026b8:	5b                   	pop    %ebx
801026b9:	5e                   	pop    %esi
801026ba:	5f                   	pop    %edi
801026bb:	5d                   	pop    %ebp
801026bc:	c3                   	ret    

801026bd <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801026bd:	55                   	push   %ebp
801026be:	89 e5                	mov    %esp,%ebp
801026c0:	53                   	push   %ebx
801026c1:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801026c4:	ff 35 f4 26 13 80    	pushl  0x801326f4
801026ca:	ff 35 04 27 13 80    	pushl  0x80132704
801026d0:	e8 97 da ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801026d5:	8b 58 5c             	mov    0x5c(%eax),%ebx
801026d8:	89 1d 08 27 13 80    	mov    %ebx,0x80132708
  for (i = 0; i < log.lh.n; i++) {
801026de:	83 c4 10             	add    $0x10,%esp
801026e1:	ba 00 00 00 00       	mov    $0x0,%edx
801026e6:	eb 0e                	jmp    801026f6 <read_head+0x39>
    log.lh.block[i] = lh->block[i];
801026e8:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801026ec:	89 0c 95 0c 27 13 80 	mov    %ecx,-0x7fecd8f4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801026f3:	83 c2 01             	add    $0x1,%edx
801026f6:	39 d3                	cmp    %edx,%ebx
801026f8:	7f ee                	jg     801026e8 <read_head+0x2b>
  }
  brelse(buf);
801026fa:	83 ec 0c             	sub    $0xc,%esp
801026fd:	50                   	push   %eax
801026fe:	e8 d2 da ff ff       	call   801001d5 <brelse>
}
80102703:	83 c4 10             	add    $0x10,%esp
80102706:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102709:	c9                   	leave  
8010270a:	c3                   	ret    

8010270b <install_trans>:
{
8010270b:	55                   	push   %ebp
8010270c:	89 e5                	mov    %esp,%ebp
8010270e:	57                   	push   %edi
8010270f:	56                   	push   %esi
80102710:	53                   	push   %ebx
80102711:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102714:	bb 00 00 00 00       	mov    $0x0,%ebx
80102719:	eb 66                	jmp    80102781 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
8010271b:	89 d8                	mov    %ebx,%eax
8010271d:	03 05 f4 26 13 80    	add    0x801326f4,%eax
80102723:	83 c0 01             	add    $0x1,%eax
80102726:	83 ec 08             	sub    $0x8,%esp
80102729:	50                   	push   %eax
8010272a:	ff 35 04 27 13 80    	pushl  0x80132704
80102730:	e8 37 da ff ff       	call   8010016c <bread>
80102735:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102737:	83 c4 08             	add    $0x8,%esp
8010273a:	ff 34 9d 0c 27 13 80 	pushl  -0x7fecd8f4(,%ebx,4)
80102741:	ff 35 04 27 13 80    	pushl  0x80132704
80102747:	e8 20 da ff ff       	call   8010016c <bread>
8010274c:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
8010274e:	8d 57 5c             	lea    0x5c(%edi),%edx
80102751:	8d 40 5c             	lea    0x5c(%eax),%eax
80102754:	83 c4 0c             	add    $0xc,%esp
80102757:	68 00 02 00 00       	push   $0x200
8010275c:	52                   	push   %edx
8010275d:	50                   	push   %eax
8010275e:	e8 b5 16 00 00       	call   80103e18 <memmove>
    bwrite(dbuf);  // write dst to disk
80102763:	89 34 24             	mov    %esi,(%esp)
80102766:	e8 2f da ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
8010276b:	89 3c 24             	mov    %edi,(%esp)
8010276e:	e8 62 da ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
80102773:	89 34 24             	mov    %esi,(%esp)
80102776:	e8 5a da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010277b:	83 c3 01             	add    $0x1,%ebx
8010277e:	83 c4 10             	add    $0x10,%esp
80102781:	39 1d 08 27 13 80    	cmp    %ebx,0x80132708
80102787:	7f 92                	jg     8010271b <install_trans+0x10>
}
80102789:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010278c:	5b                   	pop    %ebx
8010278d:	5e                   	pop    %esi
8010278e:	5f                   	pop    %edi
8010278f:	5d                   	pop    %ebp
80102790:	c3                   	ret    

80102791 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102791:	55                   	push   %ebp
80102792:	89 e5                	mov    %esp,%ebp
80102794:	53                   	push   %ebx
80102795:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102798:	ff 35 f4 26 13 80    	pushl  0x801326f4
8010279e:	ff 35 04 27 13 80    	pushl  0x80132704
801027a4:	e8 c3 d9 ff ff       	call   8010016c <bread>
801027a9:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801027ab:	8b 0d 08 27 13 80    	mov    0x80132708,%ecx
801027b1:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801027b4:	83 c4 10             	add    $0x10,%esp
801027b7:	b8 00 00 00 00       	mov    $0x0,%eax
801027bc:	eb 0e                	jmp    801027cc <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
801027be:	8b 14 85 0c 27 13 80 	mov    -0x7fecd8f4(,%eax,4),%edx
801027c5:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801027c9:	83 c0 01             	add    $0x1,%eax
801027cc:	39 c1                	cmp    %eax,%ecx
801027ce:	7f ee                	jg     801027be <write_head+0x2d>
  }
  bwrite(buf);
801027d0:	83 ec 0c             	sub    $0xc,%esp
801027d3:	53                   	push   %ebx
801027d4:	e8 c1 d9 ff ff       	call   8010019a <bwrite>
  brelse(buf);
801027d9:	89 1c 24             	mov    %ebx,(%esp)
801027dc:	e8 f4 d9 ff ff       	call   801001d5 <brelse>
}
801027e1:	83 c4 10             	add    $0x10,%esp
801027e4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027e7:	c9                   	leave  
801027e8:	c3                   	ret    

801027e9 <recover_from_log>:

static void
recover_from_log(void)
{
801027e9:	55                   	push   %ebp
801027ea:	89 e5                	mov    %esp,%ebp
801027ec:	83 ec 08             	sub    $0x8,%esp
  read_head();
801027ef:	e8 c9 fe ff ff       	call   801026bd <read_head>
  install_trans(); // if committed, copy from log to disk
801027f4:	e8 12 ff ff ff       	call   8010270b <install_trans>
  log.lh.n = 0;
801027f9:	c7 05 08 27 13 80 00 	movl   $0x0,0x80132708
80102800:	00 00 00 
  write_head(); // clear the log
80102803:	e8 89 ff ff ff       	call   80102791 <write_head>
}
80102808:	c9                   	leave  
80102809:	c3                   	ret    

8010280a <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
8010280a:	55                   	push   %ebp
8010280b:	89 e5                	mov    %esp,%ebp
8010280d:	57                   	push   %edi
8010280e:	56                   	push   %esi
8010280f:	53                   	push   %ebx
80102810:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102813:	bb 00 00 00 00       	mov    $0x0,%ebx
80102818:	eb 66                	jmp    80102880 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
8010281a:	89 d8                	mov    %ebx,%eax
8010281c:	03 05 f4 26 13 80    	add    0x801326f4,%eax
80102822:	83 c0 01             	add    $0x1,%eax
80102825:	83 ec 08             	sub    $0x8,%esp
80102828:	50                   	push   %eax
80102829:	ff 35 04 27 13 80    	pushl  0x80132704
8010282f:	e8 38 d9 ff ff       	call   8010016c <bread>
80102834:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102836:	83 c4 08             	add    $0x8,%esp
80102839:	ff 34 9d 0c 27 13 80 	pushl  -0x7fecd8f4(,%ebx,4)
80102840:	ff 35 04 27 13 80    	pushl  0x80132704
80102846:	e8 21 d9 ff ff       	call   8010016c <bread>
8010284b:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
8010284d:	8d 50 5c             	lea    0x5c(%eax),%edx
80102850:	8d 46 5c             	lea    0x5c(%esi),%eax
80102853:	83 c4 0c             	add    $0xc,%esp
80102856:	68 00 02 00 00       	push   $0x200
8010285b:	52                   	push   %edx
8010285c:	50                   	push   %eax
8010285d:	e8 b6 15 00 00       	call   80103e18 <memmove>
    bwrite(to);  // write the log
80102862:	89 34 24             	mov    %esi,(%esp)
80102865:	e8 30 d9 ff ff       	call   8010019a <bwrite>
    brelse(from);
8010286a:	89 3c 24             	mov    %edi,(%esp)
8010286d:	e8 63 d9 ff ff       	call   801001d5 <brelse>
    brelse(to);
80102872:	89 34 24             	mov    %esi,(%esp)
80102875:	e8 5b d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
8010287a:	83 c3 01             	add    $0x1,%ebx
8010287d:	83 c4 10             	add    $0x10,%esp
80102880:	39 1d 08 27 13 80    	cmp    %ebx,0x80132708
80102886:	7f 92                	jg     8010281a <write_log+0x10>
  }
}
80102888:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010288b:	5b                   	pop    %ebx
8010288c:	5e                   	pop    %esi
8010288d:	5f                   	pop    %edi
8010288e:	5d                   	pop    %ebp
8010288f:	c3                   	ret    

80102890 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102890:	83 3d 08 27 13 80 00 	cmpl   $0x0,0x80132708
80102897:	7e 26                	jle    801028bf <commit+0x2f>
{
80102899:	55                   	push   %ebp
8010289a:	89 e5                	mov    %esp,%ebp
8010289c:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
8010289f:	e8 66 ff ff ff       	call   8010280a <write_log>
    write_head();    // Write header to disk -- the real commit
801028a4:	e8 e8 fe ff ff       	call   80102791 <write_head>
    install_trans(); // Now install writes to home locations
801028a9:	e8 5d fe ff ff       	call   8010270b <install_trans>
    log.lh.n = 0;
801028ae:	c7 05 08 27 13 80 00 	movl   $0x0,0x80132708
801028b5:	00 00 00 
    write_head();    // Erase the transaction from the log
801028b8:	e8 d4 fe ff ff       	call   80102791 <write_head>
  }
}
801028bd:	c9                   	leave  
801028be:	c3                   	ret    
801028bf:	f3 c3                	repz ret 

801028c1 <initlog>:
{
801028c1:	55                   	push   %ebp
801028c2:	89 e5                	mov    %esp,%ebp
801028c4:	53                   	push   %ebx
801028c5:	83 ec 2c             	sub    $0x2c,%esp
801028c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801028cb:	68 e0 6a 10 80       	push   $0x80106ae0
801028d0:	68 c0 26 13 80       	push   $0x801326c0
801028d5:	e8 db 12 00 00       	call   80103bb5 <initlock>
  readsb(dev, &sb);
801028da:	83 c4 08             	add    $0x8,%esp
801028dd:	8d 45 dc             	lea    -0x24(%ebp),%eax
801028e0:	50                   	push   %eax
801028e1:	53                   	push   %ebx
801028e2:	e8 4f e9 ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
801028e7:	8b 45 ec             	mov    -0x14(%ebp),%eax
801028ea:	a3 f4 26 13 80       	mov    %eax,0x801326f4
  log.size = sb.nlog;
801028ef:	8b 45 e8             	mov    -0x18(%ebp),%eax
801028f2:	a3 f8 26 13 80       	mov    %eax,0x801326f8
  log.dev = dev;
801028f7:	89 1d 04 27 13 80    	mov    %ebx,0x80132704
  recover_from_log();
801028fd:	e8 e7 fe ff ff       	call   801027e9 <recover_from_log>
}
80102902:	83 c4 10             	add    $0x10,%esp
80102905:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102908:	c9                   	leave  
80102909:	c3                   	ret    

8010290a <begin_op>:
{
8010290a:	55                   	push   %ebp
8010290b:	89 e5                	mov    %esp,%ebp
8010290d:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102910:	68 c0 26 13 80       	push   $0x801326c0
80102915:	e8 d7 13 00 00       	call   80103cf1 <acquire>
8010291a:	83 c4 10             	add    $0x10,%esp
8010291d:	eb 15                	jmp    80102934 <begin_op+0x2a>
      sleep(&log, &log.lock);
8010291f:	83 ec 08             	sub    $0x8,%esp
80102922:	68 c0 26 13 80       	push   $0x801326c0
80102927:	68 c0 26 13 80       	push   $0x801326c0
8010292c:	e8 c5 0e 00 00       	call   801037f6 <sleep>
80102931:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102934:	83 3d 00 27 13 80 00 	cmpl   $0x0,0x80132700
8010293b:	75 e2                	jne    8010291f <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
8010293d:	a1 fc 26 13 80       	mov    0x801326fc,%eax
80102942:	83 c0 01             	add    $0x1,%eax
80102945:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102948:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
8010294b:	03 15 08 27 13 80    	add    0x80132708,%edx
80102951:	83 fa 1e             	cmp    $0x1e,%edx
80102954:	7e 17                	jle    8010296d <begin_op+0x63>
      sleep(&log, &log.lock);
80102956:	83 ec 08             	sub    $0x8,%esp
80102959:	68 c0 26 13 80       	push   $0x801326c0
8010295e:	68 c0 26 13 80       	push   $0x801326c0
80102963:	e8 8e 0e 00 00       	call   801037f6 <sleep>
80102968:	83 c4 10             	add    $0x10,%esp
8010296b:	eb c7                	jmp    80102934 <begin_op+0x2a>
      log.outstanding += 1;
8010296d:	a3 fc 26 13 80       	mov    %eax,0x801326fc
      release(&log.lock);
80102972:	83 ec 0c             	sub    $0xc,%esp
80102975:	68 c0 26 13 80       	push   $0x801326c0
8010297a:	e8 d7 13 00 00       	call   80103d56 <release>
}
8010297f:	83 c4 10             	add    $0x10,%esp
80102982:	c9                   	leave  
80102983:	c3                   	ret    

80102984 <end_op>:
{
80102984:	55                   	push   %ebp
80102985:	89 e5                	mov    %esp,%ebp
80102987:	53                   	push   %ebx
80102988:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
8010298b:	68 c0 26 13 80       	push   $0x801326c0
80102990:	e8 5c 13 00 00       	call   80103cf1 <acquire>
  log.outstanding -= 1;
80102995:	a1 fc 26 13 80       	mov    0x801326fc,%eax
8010299a:	83 e8 01             	sub    $0x1,%eax
8010299d:	a3 fc 26 13 80       	mov    %eax,0x801326fc
  if(log.committing)
801029a2:	8b 1d 00 27 13 80    	mov    0x80132700,%ebx
801029a8:	83 c4 10             	add    $0x10,%esp
801029ab:	85 db                	test   %ebx,%ebx
801029ad:	75 2c                	jne    801029db <end_op+0x57>
  if(log.outstanding == 0){
801029af:	85 c0                	test   %eax,%eax
801029b1:	75 35                	jne    801029e8 <end_op+0x64>
    log.committing = 1;
801029b3:	c7 05 00 27 13 80 01 	movl   $0x1,0x80132700
801029ba:	00 00 00 
    do_commit = 1;
801029bd:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
801029c2:	83 ec 0c             	sub    $0xc,%esp
801029c5:	68 c0 26 13 80       	push   $0x801326c0
801029ca:	e8 87 13 00 00       	call   80103d56 <release>
  if(do_commit){
801029cf:	83 c4 10             	add    $0x10,%esp
801029d2:	85 db                	test   %ebx,%ebx
801029d4:	75 24                	jne    801029fa <end_op+0x76>
}
801029d6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029d9:	c9                   	leave  
801029da:	c3                   	ret    
    panic("log.committing");
801029db:	83 ec 0c             	sub    $0xc,%esp
801029de:	68 e4 6a 10 80       	push   $0x80106ae4
801029e3:	e8 60 d9 ff ff       	call   80100348 <panic>
    wakeup(&log);
801029e8:	83 ec 0c             	sub    $0xc,%esp
801029eb:	68 c0 26 13 80       	push   $0x801326c0
801029f0:	e8 66 0f 00 00       	call   8010395b <wakeup>
801029f5:	83 c4 10             	add    $0x10,%esp
801029f8:	eb c8                	jmp    801029c2 <end_op+0x3e>
    commit();
801029fa:	e8 91 fe ff ff       	call   80102890 <commit>
    acquire(&log.lock);
801029ff:	83 ec 0c             	sub    $0xc,%esp
80102a02:	68 c0 26 13 80       	push   $0x801326c0
80102a07:	e8 e5 12 00 00       	call   80103cf1 <acquire>
    log.committing = 0;
80102a0c:	c7 05 00 27 13 80 00 	movl   $0x0,0x80132700
80102a13:	00 00 00 
    wakeup(&log);
80102a16:	c7 04 24 c0 26 13 80 	movl   $0x801326c0,(%esp)
80102a1d:	e8 39 0f 00 00       	call   8010395b <wakeup>
    release(&log.lock);
80102a22:	c7 04 24 c0 26 13 80 	movl   $0x801326c0,(%esp)
80102a29:	e8 28 13 00 00       	call   80103d56 <release>
80102a2e:	83 c4 10             	add    $0x10,%esp
}
80102a31:	eb a3                	jmp    801029d6 <end_op+0x52>

80102a33 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102a33:	55                   	push   %ebp
80102a34:	89 e5                	mov    %esp,%ebp
80102a36:	53                   	push   %ebx
80102a37:	83 ec 04             	sub    $0x4,%esp
80102a3a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102a3d:	8b 15 08 27 13 80    	mov    0x80132708,%edx
80102a43:	83 fa 1d             	cmp    $0x1d,%edx
80102a46:	7f 45                	jg     80102a8d <log_write+0x5a>
80102a48:	a1 f8 26 13 80       	mov    0x801326f8,%eax
80102a4d:	83 e8 01             	sub    $0x1,%eax
80102a50:	39 c2                	cmp    %eax,%edx
80102a52:	7d 39                	jge    80102a8d <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102a54:	83 3d fc 26 13 80 00 	cmpl   $0x0,0x801326fc
80102a5b:	7e 3d                	jle    80102a9a <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102a5d:	83 ec 0c             	sub    $0xc,%esp
80102a60:	68 c0 26 13 80       	push   $0x801326c0
80102a65:	e8 87 12 00 00       	call   80103cf1 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102a6a:	83 c4 10             	add    $0x10,%esp
80102a6d:	b8 00 00 00 00       	mov    $0x0,%eax
80102a72:	8b 15 08 27 13 80    	mov    0x80132708,%edx
80102a78:	39 c2                	cmp    %eax,%edx
80102a7a:	7e 2b                	jle    80102aa7 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102a7c:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102a7f:	39 0c 85 0c 27 13 80 	cmp    %ecx,-0x7fecd8f4(,%eax,4)
80102a86:	74 1f                	je     80102aa7 <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102a88:	83 c0 01             	add    $0x1,%eax
80102a8b:	eb e5                	jmp    80102a72 <log_write+0x3f>
    panic("too big a transaction");
80102a8d:	83 ec 0c             	sub    $0xc,%esp
80102a90:	68 f3 6a 10 80       	push   $0x80106af3
80102a95:	e8 ae d8 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102a9a:	83 ec 0c             	sub    $0xc,%esp
80102a9d:	68 09 6b 10 80       	push   $0x80106b09
80102aa2:	e8 a1 d8 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102aa7:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102aaa:	89 0c 85 0c 27 13 80 	mov    %ecx,-0x7fecd8f4(,%eax,4)
  if (i == log.lh.n)
80102ab1:	39 c2                	cmp    %eax,%edx
80102ab3:	74 18                	je     80102acd <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102ab5:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102ab8:	83 ec 0c             	sub    $0xc,%esp
80102abb:	68 c0 26 13 80       	push   $0x801326c0
80102ac0:	e8 91 12 00 00       	call   80103d56 <release>
}
80102ac5:	83 c4 10             	add    $0x10,%esp
80102ac8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102acb:	c9                   	leave  
80102acc:	c3                   	ret    
    log.lh.n++;
80102acd:	83 c2 01             	add    $0x1,%edx
80102ad0:	89 15 08 27 13 80    	mov    %edx,0x80132708
80102ad6:	eb dd                	jmp    80102ab5 <log_write+0x82>

80102ad8 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102ad8:	55                   	push   %ebp
80102ad9:	89 e5                	mov    %esp,%ebp
80102adb:	53                   	push   %ebx
80102adc:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102adf:	68 8a 00 00 00       	push   $0x8a
80102ae4:	68 8c a4 10 80       	push   $0x8010a48c
80102ae9:	68 00 70 00 80       	push   $0x80007000
80102aee:	e8 25 13 00 00       	call   80103e18 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102af3:	83 c4 10             	add    $0x10,%esp
80102af6:	bb c0 27 13 80       	mov    $0x801327c0,%ebx
80102afb:	eb 06                	jmp    80102b03 <startothers+0x2b>
80102afd:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102b03:	69 05 40 2d 13 80 b0 	imul   $0xb0,0x80132d40,%eax
80102b0a:	00 00 00 
80102b0d:	05 c0 27 13 80       	add    $0x801327c0,%eax
80102b12:	39 d8                	cmp    %ebx,%eax
80102b14:	76 4c                	jbe    80102b62 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
80102b16:	e8 c0 07 00 00       	call   801032db <mycpu>
80102b1b:	39 d8                	cmp    %ebx,%eax
80102b1d:	74 de                	je     80102afd <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102b1f:	e8 a1 f5 ff ff       	call   801020c5 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102b24:	05 00 10 00 00       	add    $0x1000,%eax
80102b29:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102b2e:	c7 05 f8 6f 00 80 a6 	movl   $0x80102ba6,0x80006ff8
80102b35:	2b 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102b38:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102b3f:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102b42:	83 ec 08             	sub    $0x8,%esp
80102b45:	68 00 70 00 00       	push   $0x7000
80102b4a:	0f b6 03             	movzbl (%ebx),%eax
80102b4d:	50                   	push   %eax
80102b4e:	e8 c6 f9 ff ff       	call   80102519 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102b53:	83 c4 10             	add    $0x10,%esp
80102b56:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102b5c:	85 c0                	test   %eax,%eax
80102b5e:	74 f6                	je     80102b56 <startothers+0x7e>
80102b60:	eb 9b                	jmp    80102afd <startothers+0x25>
      ;
  }
}
80102b62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b65:	c9                   	leave  
80102b66:	c3                   	ret    

80102b67 <mpmain>:
{
80102b67:	55                   	push   %ebp
80102b68:	89 e5                	mov    %esp,%ebp
80102b6a:	53                   	push   %ebx
80102b6b:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102b6e:	e8 c4 07 00 00       	call   80103337 <cpuid>
80102b73:	89 c3                	mov    %eax,%ebx
80102b75:	e8 bd 07 00 00       	call   80103337 <cpuid>
80102b7a:	83 ec 04             	sub    $0x4,%esp
80102b7d:	53                   	push   %ebx
80102b7e:	50                   	push   %eax
80102b7f:	68 24 6b 10 80       	push   $0x80106b24
80102b84:	e8 82 da ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102b89:	e8 e1 23 00 00       	call   80104f6f <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102b8e:	e8 48 07 00 00       	call   801032db <mycpu>
80102b93:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102b95:	b8 01 00 00 00       	mov    $0x1,%eax
80102b9a:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102ba1:	e8 2b 0a 00 00       	call   801035d1 <scheduler>

80102ba6 <mpenter>:
{
80102ba6:	55                   	push   %ebp
80102ba7:	89 e5                	mov    %esp,%ebp
80102ba9:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102bac:	e8 c7 33 00 00       	call   80105f78 <switchkvm>
  seginit();
80102bb1:	e8 76 32 00 00       	call   80105e2c <seginit>
  lapicinit();
80102bb6:	e8 15 f8 ff ff       	call   801023d0 <lapicinit>
  mpmain();
80102bbb:	e8 a7 ff ff ff       	call   80102b67 <mpmain>

80102bc0 <main>:
{
80102bc0:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102bc4:	83 e4 f0             	and    $0xfffffff0,%esp
80102bc7:	ff 71 fc             	pushl  -0x4(%ecx)
80102bca:	55                   	push   %ebp
80102bcb:	89 e5                	mov    %esp,%ebp
80102bcd:	51                   	push   %ecx
80102bce:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102bd1:	68 00 00 40 80       	push   $0x80400000
80102bd6:	68 e8 54 13 80       	push   $0x801354e8
80102bdb:	e8 89 f4 ff ff       	call   80102069 <kinit1>
  kvmalloc();      // kernel page table
80102be0:	e8 20 38 00 00       	call   80106405 <kvmalloc>
  mpinit();        // detect other processors
80102be5:	e8 c9 01 00 00       	call   80102db3 <mpinit>
  lapicinit();     // interrupt controller
80102bea:	e8 e1 f7 ff ff       	call   801023d0 <lapicinit>
  seginit();       // segment descriptors
80102bef:	e8 38 32 00 00       	call   80105e2c <seginit>
  picinit();       // disable pic
80102bf4:	e8 82 02 00 00       	call   80102e7b <picinit>
  ioapicinit();    // another interrupt controller
80102bf9:	e8 fc f2 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102bfe:	e8 8b dc ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102c03:	e8 15 26 00 00       	call   8010521d <uartinit>
  pinit();         // process table
80102c08:	e8 b4 06 00 00       	call   801032c1 <pinit>
  tvinit();        // trap vectors
80102c0d:	e8 ac 22 00 00       	call   80104ebe <tvinit>
  binit();         // buffer cache
80102c12:	e8 dd d4 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102c17:	e8 f7 df ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102c1c:	e8 df f0 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102c21:	e8 b2 fe ff ff       	call   80102ad8 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102c26:	83 c4 08             	add    $0x8,%esp
80102c29:	68 00 00 00 8e       	push   $0x8e000000
80102c2e:	68 00 00 40 80       	push   $0x80400000
80102c33:	e8 63 f4 ff ff       	call   8010209b <kinit2>
  userinit();      // first user process
80102c38:	e8 39 07 00 00       	call   80103376 <userinit>
  mpmain();        // finish this processor's setup
80102c3d:	e8 25 ff ff ff       	call   80102b67 <mpmain>

80102c42 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102c42:	55                   	push   %ebp
80102c43:	89 e5                	mov    %esp,%ebp
80102c45:	56                   	push   %esi
80102c46:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102c47:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102c4c:	b9 00 00 00 00       	mov    $0x0,%ecx
80102c51:	eb 09                	jmp    80102c5c <sum+0x1a>
    sum += addr[i];
80102c53:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102c57:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102c59:	83 c1 01             	add    $0x1,%ecx
80102c5c:	39 d1                	cmp    %edx,%ecx
80102c5e:	7c f3                	jl     80102c53 <sum+0x11>
  return sum;
}
80102c60:	89 d8                	mov    %ebx,%eax
80102c62:	5b                   	pop    %ebx
80102c63:	5e                   	pop    %esi
80102c64:	5d                   	pop    %ebp
80102c65:	c3                   	ret    

80102c66 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102c66:	55                   	push   %ebp
80102c67:	89 e5                	mov    %esp,%ebp
80102c69:	56                   	push   %esi
80102c6a:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102c6b:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102c71:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102c73:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102c75:	eb 03                	jmp    80102c7a <mpsearch1+0x14>
80102c77:	83 c3 10             	add    $0x10,%ebx
80102c7a:	39 f3                	cmp    %esi,%ebx
80102c7c:	73 29                	jae    80102ca7 <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102c7e:	83 ec 04             	sub    $0x4,%esp
80102c81:	6a 04                	push   $0x4
80102c83:	68 38 6b 10 80       	push   $0x80106b38
80102c88:	53                   	push   %ebx
80102c89:	e8 55 11 00 00       	call   80103de3 <memcmp>
80102c8e:	83 c4 10             	add    $0x10,%esp
80102c91:	85 c0                	test   %eax,%eax
80102c93:	75 e2                	jne    80102c77 <mpsearch1+0x11>
80102c95:	ba 10 00 00 00       	mov    $0x10,%edx
80102c9a:	89 d8                	mov    %ebx,%eax
80102c9c:	e8 a1 ff ff ff       	call   80102c42 <sum>
80102ca1:	84 c0                	test   %al,%al
80102ca3:	75 d2                	jne    80102c77 <mpsearch1+0x11>
80102ca5:	eb 05                	jmp    80102cac <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102ca7:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102cac:	89 d8                	mov    %ebx,%eax
80102cae:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102cb1:	5b                   	pop    %ebx
80102cb2:	5e                   	pop    %esi
80102cb3:	5d                   	pop    %ebp
80102cb4:	c3                   	ret    

80102cb5 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102cb5:	55                   	push   %ebp
80102cb6:	89 e5                	mov    %esp,%ebp
80102cb8:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102cbb:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102cc2:	c1 e0 08             	shl    $0x8,%eax
80102cc5:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102ccc:	09 d0                	or     %edx,%eax
80102cce:	c1 e0 04             	shl    $0x4,%eax
80102cd1:	85 c0                	test   %eax,%eax
80102cd3:	74 1f                	je     80102cf4 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102cd5:	ba 00 04 00 00       	mov    $0x400,%edx
80102cda:	e8 87 ff ff ff       	call   80102c66 <mpsearch1>
80102cdf:	85 c0                	test   %eax,%eax
80102ce1:	75 0f                	jne    80102cf2 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102ce3:	ba 00 00 01 00       	mov    $0x10000,%edx
80102ce8:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102ced:	e8 74 ff ff ff       	call   80102c66 <mpsearch1>
}
80102cf2:	c9                   	leave  
80102cf3:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102cf4:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102cfb:	c1 e0 08             	shl    $0x8,%eax
80102cfe:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102d05:	09 d0                	or     %edx,%eax
80102d07:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102d0a:	2d 00 04 00 00       	sub    $0x400,%eax
80102d0f:	ba 00 04 00 00       	mov    $0x400,%edx
80102d14:	e8 4d ff ff ff       	call   80102c66 <mpsearch1>
80102d19:	85 c0                	test   %eax,%eax
80102d1b:	75 d5                	jne    80102cf2 <mpsearch+0x3d>
80102d1d:	eb c4                	jmp    80102ce3 <mpsearch+0x2e>

80102d1f <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102d1f:	55                   	push   %ebp
80102d20:	89 e5                	mov    %esp,%ebp
80102d22:	57                   	push   %edi
80102d23:	56                   	push   %esi
80102d24:	53                   	push   %ebx
80102d25:	83 ec 1c             	sub    $0x1c,%esp
80102d28:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102d2b:	e8 85 ff ff ff       	call   80102cb5 <mpsearch>
80102d30:	85 c0                	test   %eax,%eax
80102d32:	74 5c                	je     80102d90 <mpconfig+0x71>
80102d34:	89 c7                	mov    %eax,%edi
80102d36:	8b 58 04             	mov    0x4(%eax),%ebx
80102d39:	85 db                	test   %ebx,%ebx
80102d3b:	74 5a                	je     80102d97 <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102d3d:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102d43:	83 ec 04             	sub    $0x4,%esp
80102d46:	6a 04                	push   $0x4
80102d48:	68 3d 6b 10 80       	push   $0x80106b3d
80102d4d:	56                   	push   %esi
80102d4e:	e8 90 10 00 00       	call   80103de3 <memcmp>
80102d53:	83 c4 10             	add    $0x10,%esp
80102d56:	85 c0                	test   %eax,%eax
80102d58:	75 44                	jne    80102d9e <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102d5a:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102d61:	3c 01                	cmp    $0x1,%al
80102d63:	0f 95 c2             	setne  %dl
80102d66:	3c 04                	cmp    $0x4,%al
80102d68:	0f 95 c0             	setne  %al
80102d6b:	84 c2                	test   %al,%dl
80102d6d:	75 36                	jne    80102da5 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102d6f:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102d76:	89 f0                	mov    %esi,%eax
80102d78:	e8 c5 fe ff ff       	call   80102c42 <sum>
80102d7d:	84 c0                	test   %al,%al
80102d7f:	75 2b                	jne    80102dac <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102d81:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d84:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102d86:	89 f0                	mov    %esi,%eax
80102d88:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d8b:	5b                   	pop    %ebx
80102d8c:	5e                   	pop    %esi
80102d8d:	5f                   	pop    %edi
80102d8e:	5d                   	pop    %ebp
80102d8f:	c3                   	ret    
    return 0;
80102d90:	be 00 00 00 00       	mov    $0x0,%esi
80102d95:	eb ef                	jmp    80102d86 <mpconfig+0x67>
80102d97:	be 00 00 00 00       	mov    $0x0,%esi
80102d9c:	eb e8                	jmp    80102d86 <mpconfig+0x67>
    return 0;
80102d9e:	be 00 00 00 00       	mov    $0x0,%esi
80102da3:	eb e1                	jmp    80102d86 <mpconfig+0x67>
    return 0;
80102da5:	be 00 00 00 00       	mov    $0x0,%esi
80102daa:	eb da                	jmp    80102d86 <mpconfig+0x67>
    return 0;
80102dac:	be 00 00 00 00       	mov    $0x0,%esi
80102db1:	eb d3                	jmp    80102d86 <mpconfig+0x67>

80102db3 <mpinit>:

void
mpinit(void)
{
80102db3:	55                   	push   %ebp
80102db4:	89 e5                	mov    %esp,%ebp
80102db6:	57                   	push   %edi
80102db7:	56                   	push   %esi
80102db8:	53                   	push   %ebx
80102db9:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102dbc:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102dbf:	e8 5b ff ff ff       	call   80102d1f <mpconfig>
80102dc4:	85 c0                	test   %eax,%eax
80102dc6:	74 19                	je     80102de1 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102dc8:	8b 50 24             	mov    0x24(%eax),%edx
80102dcb:	89 15 a0 26 13 80    	mov    %edx,0x801326a0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102dd1:	8d 50 2c             	lea    0x2c(%eax),%edx
80102dd4:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102dd8:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102dda:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ddf:	eb 34                	jmp    80102e15 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102de1:	83 ec 0c             	sub    $0xc,%esp
80102de4:	68 42 6b 10 80       	push   $0x80106b42
80102de9:	e8 5a d5 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102dee:	8b 35 40 2d 13 80    	mov    0x80132d40,%esi
80102df4:	83 fe 07             	cmp    $0x7,%esi
80102df7:	7f 19                	jg     80102e12 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102df9:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102dfd:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102e03:	88 87 c0 27 13 80    	mov    %al,-0x7fecd840(%edi)
        ncpu++;
80102e09:	83 c6 01             	add    $0x1,%esi
80102e0c:	89 35 40 2d 13 80    	mov    %esi,0x80132d40
      }
      p += sizeof(struct mpproc);
80102e12:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e15:	39 ca                	cmp    %ecx,%edx
80102e17:	73 2b                	jae    80102e44 <mpinit+0x91>
    switch(*p){
80102e19:	0f b6 02             	movzbl (%edx),%eax
80102e1c:	3c 04                	cmp    $0x4,%al
80102e1e:	77 1d                	ja     80102e3d <mpinit+0x8a>
80102e20:	0f b6 c0             	movzbl %al,%eax
80102e23:	ff 24 85 7c 6b 10 80 	jmp    *-0x7fef9484(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102e2a:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e2e:	a2 a0 27 13 80       	mov    %al,0x801327a0
      p += sizeof(struct mpioapic);
80102e33:	83 c2 08             	add    $0x8,%edx
      continue;
80102e36:	eb dd                	jmp    80102e15 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102e38:	83 c2 08             	add    $0x8,%edx
      continue;
80102e3b:	eb d8                	jmp    80102e15 <mpinit+0x62>
    default:
      ismp = 0;
80102e3d:	bb 00 00 00 00       	mov    $0x0,%ebx
80102e42:	eb d1                	jmp    80102e15 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102e44:	85 db                	test   %ebx,%ebx
80102e46:	74 26                	je     80102e6e <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102e48:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102e4b:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102e4f:	74 15                	je     80102e66 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e51:	b8 70 00 00 00       	mov    $0x70,%eax
80102e56:	ba 22 00 00 00       	mov    $0x22,%edx
80102e5b:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e5c:	ba 23 00 00 00       	mov    $0x23,%edx
80102e61:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102e62:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e65:	ee                   	out    %al,(%dx)
  }
}
80102e66:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102e69:	5b                   	pop    %ebx
80102e6a:	5e                   	pop    %esi
80102e6b:	5f                   	pop    %edi
80102e6c:	5d                   	pop    %ebp
80102e6d:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102e6e:	83 ec 0c             	sub    $0xc,%esp
80102e71:	68 5c 6b 10 80       	push   $0x80106b5c
80102e76:	e8 cd d4 ff ff       	call   80100348 <panic>

80102e7b <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102e7b:	55                   	push   %ebp
80102e7c:	89 e5                	mov    %esp,%ebp
80102e7e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e83:	ba 21 00 00 00       	mov    $0x21,%edx
80102e88:	ee                   	out    %al,(%dx)
80102e89:	ba a1 00 00 00       	mov    $0xa1,%edx
80102e8e:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102e8f:	5d                   	pop    %ebp
80102e90:	c3                   	ret    

80102e91 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102e91:	55                   	push   %ebp
80102e92:	89 e5                	mov    %esp,%ebp
80102e94:	57                   	push   %edi
80102e95:	56                   	push   %esi
80102e96:	53                   	push   %ebx
80102e97:	83 ec 0c             	sub    $0xc,%esp
80102e9a:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102e9d:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102ea0:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102ea6:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102eac:	e8 7c dd ff ff       	call   80100c2d <filealloc>
80102eb1:	89 03                	mov    %eax,(%ebx)
80102eb3:	85 c0                	test   %eax,%eax
80102eb5:	74 16                	je     80102ecd <pipealloc+0x3c>
80102eb7:	e8 71 dd ff ff       	call   80100c2d <filealloc>
80102ebc:	89 06                	mov    %eax,(%esi)
80102ebe:	85 c0                	test   %eax,%eax
80102ec0:	74 0b                	je     80102ecd <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102ec2:	e8 fe f1 ff ff       	call   801020c5 <kalloc>
80102ec7:	89 c7                	mov    %eax,%edi
80102ec9:	85 c0                	test   %eax,%eax
80102ecb:	75 35                	jne    80102f02 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102ecd:	8b 03                	mov    (%ebx),%eax
80102ecf:	85 c0                	test   %eax,%eax
80102ed1:	74 0c                	je     80102edf <pipealloc+0x4e>
    fileclose(*f0);
80102ed3:	83 ec 0c             	sub    $0xc,%esp
80102ed6:	50                   	push   %eax
80102ed7:	e8 f7 dd ff ff       	call   80100cd3 <fileclose>
80102edc:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102edf:	8b 06                	mov    (%esi),%eax
80102ee1:	85 c0                	test   %eax,%eax
80102ee3:	0f 84 8b 00 00 00    	je     80102f74 <pipealloc+0xe3>
    fileclose(*f1);
80102ee9:	83 ec 0c             	sub    $0xc,%esp
80102eec:	50                   	push   %eax
80102eed:	e8 e1 dd ff ff       	call   80100cd3 <fileclose>
80102ef2:	83 c4 10             	add    $0x10,%esp
  return -1;
80102ef5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102efa:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102efd:	5b                   	pop    %ebx
80102efe:	5e                   	pop    %esi
80102eff:	5f                   	pop    %edi
80102f00:	5d                   	pop    %ebp
80102f01:	c3                   	ret    
  p->readopen = 1;
80102f02:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102f09:	00 00 00 
  p->writeopen = 1;
80102f0c:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102f13:	00 00 00 
  p->nwrite = 0;
80102f16:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102f1d:	00 00 00 
  p->nread = 0;
80102f20:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102f27:	00 00 00 
  initlock(&p->lock, "pipe");
80102f2a:	83 ec 08             	sub    $0x8,%esp
80102f2d:	68 90 6b 10 80       	push   $0x80106b90
80102f32:	50                   	push   %eax
80102f33:	e8 7d 0c 00 00       	call   80103bb5 <initlock>
  (*f0)->type = FD_PIPE;
80102f38:	8b 03                	mov    (%ebx),%eax
80102f3a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102f40:	8b 03                	mov    (%ebx),%eax
80102f42:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102f46:	8b 03                	mov    (%ebx),%eax
80102f48:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102f4c:	8b 03                	mov    (%ebx),%eax
80102f4e:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102f51:	8b 06                	mov    (%esi),%eax
80102f53:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102f59:	8b 06                	mov    (%esi),%eax
80102f5b:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102f5f:	8b 06                	mov    (%esi),%eax
80102f61:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102f65:	8b 06                	mov    (%esi),%eax
80102f67:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102f6a:	83 c4 10             	add    $0x10,%esp
80102f6d:	b8 00 00 00 00       	mov    $0x0,%eax
80102f72:	eb 86                	jmp    80102efa <pipealloc+0x69>
  return -1;
80102f74:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f79:	e9 7c ff ff ff       	jmp    80102efa <pipealloc+0x69>

80102f7e <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102f7e:	55                   	push   %ebp
80102f7f:	89 e5                	mov    %esp,%ebp
80102f81:	53                   	push   %ebx
80102f82:	83 ec 10             	sub    $0x10,%esp
80102f85:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102f88:	53                   	push   %ebx
80102f89:	e8 63 0d 00 00       	call   80103cf1 <acquire>
  if(writable){
80102f8e:	83 c4 10             	add    $0x10,%esp
80102f91:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102f95:	74 3f                	je     80102fd6 <pipeclose+0x58>
    p->writeopen = 0;
80102f97:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102f9e:	00 00 00 
    wakeup(&p->nread);
80102fa1:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fa7:	83 ec 0c             	sub    $0xc,%esp
80102faa:	50                   	push   %eax
80102fab:	e8 ab 09 00 00       	call   8010395b <wakeup>
80102fb0:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102fb3:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102fba:	75 09                	jne    80102fc5 <pipeclose+0x47>
80102fbc:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102fc3:	74 2f                	je     80102ff4 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102fc5:	83 ec 0c             	sub    $0xc,%esp
80102fc8:	53                   	push   %ebx
80102fc9:	e8 88 0d 00 00       	call   80103d56 <release>
80102fce:	83 c4 10             	add    $0x10,%esp
}
80102fd1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102fd4:	c9                   	leave  
80102fd5:	c3                   	ret    
    p->readopen = 0;
80102fd6:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102fdd:	00 00 00 
    wakeup(&p->nwrite);
80102fe0:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102fe6:	83 ec 0c             	sub    $0xc,%esp
80102fe9:	50                   	push   %eax
80102fea:	e8 6c 09 00 00       	call   8010395b <wakeup>
80102fef:	83 c4 10             	add    $0x10,%esp
80102ff2:	eb bf                	jmp    80102fb3 <pipeclose+0x35>
    release(&p->lock);
80102ff4:	83 ec 0c             	sub    $0xc,%esp
80102ff7:	53                   	push   %ebx
80102ff8:	e8 59 0d 00 00       	call   80103d56 <release>
    kfree((char*)p);
80102ffd:	89 1c 24             	mov    %ebx,(%esp)
80103000:	e8 9f ef ff ff       	call   80101fa4 <kfree>
80103005:	83 c4 10             	add    $0x10,%esp
80103008:	eb c7                	jmp    80102fd1 <pipeclose+0x53>

8010300a <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
8010300a:	55                   	push   %ebp
8010300b:	89 e5                	mov    %esp,%ebp
8010300d:	57                   	push   %edi
8010300e:	56                   	push   %esi
8010300f:	53                   	push   %ebx
80103010:	83 ec 18             	sub    $0x18,%esp
80103013:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103016:	89 de                	mov    %ebx,%esi
80103018:	53                   	push   %ebx
80103019:	e8 d3 0c 00 00       	call   80103cf1 <acquire>
  for(i = 0; i < n; i++){
8010301e:	83 c4 10             	add    $0x10,%esp
80103021:	bf 00 00 00 00       	mov    $0x0,%edi
80103026:	3b 7d 10             	cmp    0x10(%ebp),%edi
80103029:	0f 8d 88 00 00 00    	jge    801030b7 <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010302f:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80103035:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010303b:	05 00 02 00 00       	add    $0x200,%eax
80103040:	39 c2                	cmp    %eax,%edx
80103042:	75 51                	jne    80103095 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80103044:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
8010304b:	74 2f                	je     8010307c <pipewrite+0x72>
8010304d:	e8 00 03 00 00       	call   80103352 <myproc>
80103052:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103056:	75 24                	jne    8010307c <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103058:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010305e:	83 ec 0c             	sub    $0xc,%esp
80103061:	50                   	push   %eax
80103062:	e8 f4 08 00 00       	call   8010395b <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103067:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010306d:	83 c4 08             	add    $0x8,%esp
80103070:	56                   	push   %esi
80103071:	50                   	push   %eax
80103072:	e8 7f 07 00 00       	call   801037f6 <sleep>
80103077:	83 c4 10             	add    $0x10,%esp
8010307a:	eb b3                	jmp    8010302f <pipewrite+0x25>
        release(&p->lock);
8010307c:	83 ec 0c             	sub    $0xc,%esp
8010307f:	53                   	push   %ebx
80103080:	e8 d1 0c 00 00       	call   80103d56 <release>
        return -1;
80103085:	83 c4 10             	add    $0x10,%esp
80103088:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
8010308d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103090:	5b                   	pop    %ebx
80103091:	5e                   	pop    %esi
80103092:	5f                   	pop    %edi
80103093:	5d                   	pop    %ebp
80103094:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103095:	8d 42 01             	lea    0x1(%edx),%eax
80103098:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
8010309e:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801030a4:	8b 45 0c             	mov    0xc(%ebp),%eax
801030a7:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
801030ab:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801030af:	83 c7 01             	add    $0x1,%edi
801030b2:	e9 6f ff ff ff       	jmp    80103026 <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801030b7:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030bd:	83 ec 0c             	sub    $0xc,%esp
801030c0:	50                   	push   %eax
801030c1:	e8 95 08 00 00       	call   8010395b <wakeup>
  release(&p->lock);
801030c6:	89 1c 24             	mov    %ebx,(%esp)
801030c9:	e8 88 0c 00 00       	call   80103d56 <release>
  return n;
801030ce:	83 c4 10             	add    $0x10,%esp
801030d1:	8b 45 10             	mov    0x10(%ebp),%eax
801030d4:	eb b7                	jmp    8010308d <pipewrite+0x83>

801030d6 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801030d6:	55                   	push   %ebp
801030d7:	89 e5                	mov    %esp,%ebp
801030d9:	57                   	push   %edi
801030da:	56                   	push   %esi
801030db:	53                   	push   %ebx
801030dc:	83 ec 18             	sub    $0x18,%esp
801030df:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801030e2:	89 df                	mov    %ebx,%edi
801030e4:	53                   	push   %ebx
801030e5:	e8 07 0c 00 00       	call   80103cf1 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
801030ea:	83 c4 10             	add    $0x10,%esp
801030ed:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
801030f3:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
801030f9:	75 3d                	jne    80103138 <piperead+0x62>
801030fb:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103101:	85 f6                	test   %esi,%esi
80103103:	74 38                	je     8010313d <piperead+0x67>
    if(myproc()->killed){
80103105:	e8 48 02 00 00       	call   80103352 <myproc>
8010310a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010310e:	75 15                	jne    80103125 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103110:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103116:	83 ec 08             	sub    $0x8,%esp
80103119:	57                   	push   %edi
8010311a:	50                   	push   %eax
8010311b:	e8 d6 06 00 00       	call   801037f6 <sleep>
80103120:	83 c4 10             	add    $0x10,%esp
80103123:	eb c8                	jmp    801030ed <piperead+0x17>
      release(&p->lock);
80103125:	83 ec 0c             	sub    $0xc,%esp
80103128:	53                   	push   %ebx
80103129:	e8 28 0c 00 00       	call   80103d56 <release>
      return -1;
8010312e:	83 c4 10             	add    $0x10,%esp
80103131:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103136:	eb 50                	jmp    80103188 <piperead+0xb2>
80103138:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010313d:	3b 75 10             	cmp    0x10(%ebp),%esi
80103140:	7d 2c                	jge    8010316e <piperead+0x98>
    if(p->nread == p->nwrite)
80103142:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103148:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
8010314e:	74 1e                	je     8010316e <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103150:	8d 50 01             	lea    0x1(%eax),%edx
80103153:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103159:	25 ff 01 00 00       	and    $0x1ff,%eax
8010315e:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103163:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103166:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103169:	83 c6 01             	add    $0x1,%esi
8010316c:	eb cf                	jmp    8010313d <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
8010316e:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103174:	83 ec 0c             	sub    $0xc,%esp
80103177:	50                   	push   %eax
80103178:	e8 de 07 00 00       	call   8010395b <wakeup>
  release(&p->lock);
8010317d:	89 1c 24             	mov    %ebx,(%esp)
80103180:	e8 d1 0b 00 00       	call   80103d56 <release>
  return i;
80103185:	83 c4 10             	add    $0x10,%esp
}
80103188:	89 f0                	mov    %esi,%eax
8010318a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010318d:	5b                   	pop    %ebx
8010318e:	5e                   	pop    %esi
8010318f:	5f                   	pop    %edi
80103190:	5d                   	pop    %ebp
80103191:	c3                   	ret    

80103192 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103192:	55                   	push   %ebp
80103193:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103195:	ba 94 2d 13 80       	mov    $0x80132d94,%edx
8010319a:	eb 03                	jmp    8010319f <wakeup1+0xd>
8010319c:	83 c2 7c             	add    $0x7c,%edx
8010319f:	81 fa 94 4c 13 80    	cmp    $0x80134c94,%edx
801031a5:	73 14                	jae    801031bb <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
801031a7:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801031ab:	75 ef                	jne    8010319c <wakeup1+0xa>
801031ad:	39 42 20             	cmp    %eax,0x20(%edx)
801031b0:	75 ea                	jne    8010319c <wakeup1+0xa>
      p->state = RUNNABLE;
801031b2:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
801031b9:	eb e1                	jmp    8010319c <wakeup1+0xa>
}
801031bb:	5d                   	pop    %ebp
801031bc:	c3                   	ret    

801031bd <allocproc>:
{
801031bd:	55                   	push   %ebp
801031be:	89 e5                	mov    %esp,%ebp
801031c0:	53                   	push   %ebx
801031c1:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801031c4:	68 60 2d 13 80       	push   $0x80132d60
801031c9:	e8 23 0b 00 00       	call   80103cf1 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031ce:	83 c4 10             	add    $0x10,%esp
801031d1:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
801031d6:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
801031dc:	73 0b                	jae    801031e9 <allocproc+0x2c>
    if(p->state == UNUSED)
801031de:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801031e2:	74 1c                	je     80103200 <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031e4:	83 c3 7c             	add    $0x7c,%ebx
801031e7:	eb ed                	jmp    801031d6 <allocproc+0x19>
  release(&ptable.lock);
801031e9:	83 ec 0c             	sub    $0xc,%esp
801031ec:	68 60 2d 13 80       	push   $0x80132d60
801031f1:	e8 60 0b 00 00       	call   80103d56 <release>
  return 0;
801031f6:	83 c4 10             	add    $0x10,%esp
801031f9:	bb 00 00 00 00       	mov    $0x0,%ebx
801031fe:	eb 69                	jmp    80103269 <allocproc+0xac>
  p->state = EMBRYO;
80103200:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103207:	a1 04 a0 10 80       	mov    0x8010a004,%eax
8010320c:	8d 50 01             	lea    0x1(%eax),%edx
8010320f:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80103215:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
80103218:	83 ec 0c             	sub    $0xc,%esp
8010321b:	68 60 2d 13 80       	push   $0x80132d60
80103220:	e8 31 0b 00 00       	call   80103d56 <release>
  if((p->kstack = kalloc()) == 0){
80103225:	e8 9b ee ff ff       	call   801020c5 <kalloc>
8010322a:	89 43 08             	mov    %eax,0x8(%ebx)
8010322d:	83 c4 10             	add    $0x10,%esp
80103230:	85 c0                	test   %eax,%eax
80103232:	74 3c                	je     80103270 <allocproc+0xb3>
  sp -= sizeof *p->tf;
80103234:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
8010323a:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010323d:	c7 80 b0 0f 00 00 b3 	movl   $0x80104eb3,0xfb0(%eax)
80103244:	4e 10 80 
  sp -= sizeof *p->context;
80103247:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
8010324c:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010324f:	83 ec 04             	sub    $0x4,%esp
80103252:	6a 14                	push   $0x14
80103254:	6a 00                	push   $0x0
80103256:	50                   	push   %eax
80103257:	e8 41 0b 00 00       	call   80103d9d <memset>
  p->context->eip = (uint)forkret;
8010325c:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010325f:	c7 40 10 7e 32 10 80 	movl   $0x8010327e,0x10(%eax)
  return p;
80103266:	83 c4 10             	add    $0x10,%esp
}
80103269:	89 d8                	mov    %ebx,%eax
8010326b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010326e:	c9                   	leave  
8010326f:	c3                   	ret    
    p->state = UNUSED;
80103270:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103277:	bb 00 00 00 00       	mov    $0x0,%ebx
8010327c:	eb eb                	jmp    80103269 <allocproc+0xac>

8010327e <forkret>:
{
8010327e:	55                   	push   %ebp
8010327f:	89 e5                	mov    %esp,%ebp
80103281:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
80103284:	68 60 2d 13 80       	push   $0x80132d60
80103289:	e8 c8 0a 00 00       	call   80103d56 <release>
  if (first) {
8010328e:	83 c4 10             	add    $0x10,%esp
80103291:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103298:	75 02                	jne    8010329c <forkret+0x1e>
}
8010329a:	c9                   	leave  
8010329b:	c3                   	ret    
    first = 0;
8010329c:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801032a3:	00 00 00 
    iinit(ROOTDEV);
801032a6:	83 ec 0c             	sub    $0xc,%esp
801032a9:	6a 01                	push   $0x1
801032ab:	e8 3c e0 ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
801032b0:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801032b7:	e8 05 f6 ff ff       	call   801028c1 <initlog>
801032bc:	83 c4 10             	add    $0x10,%esp
}
801032bf:	eb d9                	jmp    8010329a <forkret+0x1c>

801032c1 <pinit>:
{
801032c1:	55                   	push   %ebp
801032c2:	89 e5                	mov    %esp,%ebp
801032c4:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801032c7:	68 95 6b 10 80       	push   $0x80106b95
801032cc:	68 60 2d 13 80       	push   $0x80132d60
801032d1:	e8 df 08 00 00       	call   80103bb5 <initlock>
}
801032d6:	83 c4 10             	add    $0x10,%esp
801032d9:	c9                   	leave  
801032da:	c3                   	ret    

801032db <mycpu>:
{
801032db:	55                   	push   %ebp
801032dc:	89 e5                	mov    %esp,%ebp
801032de:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801032e1:	9c                   	pushf  
801032e2:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801032e3:	f6 c4 02             	test   $0x2,%ah
801032e6:	75 28                	jne    80103310 <mycpu+0x35>
  apicid = lapicid();
801032e8:	e8 ed f1 ff ff       	call   801024da <lapicid>
  for (i = 0; i < ncpu; ++i) {
801032ed:	ba 00 00 00 00       	mov    $0x0,%edx
801032f2:	39 15 40 2d 13 80    	cmp    %edx,0x80132d40
801032f8:	7e 23                	jle    8010331d <mycpu+0x42>
    if (cpus[i].apicid == apicid)
801032fa:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103300:	0f b6 89 c0 27 13 80 	movzbl -0x7fecd840(%ecx),%ecx
80103307:	39 c1                	cmp    %eax,%ecx
80103309:	74 1f                	je     8010332a <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
8010330b:	83 c2 01             	add    $0x1,%edx
8010330e:	eb e2                	jmp    801032f2 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103310:	83 ec 0c             	sub    $0xc,%esp
80103313:	68 78 6c 10 80       	push   $0x80106c78
80103318:	e8 2b d0 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
8010331d:	83 ec 0c             	sub    $0xc,%esp
80103320:	68 9c 6b 10 80       	push   $0x80106b9c
80103325:	e8 1e d0 ff ff       	call   80100348 <panic>
      return &cpus[i];
8010332a:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103330:	05 c0 27 13 80       	add    $0x801327c0,%eax
}
80103335:	c9                   	leave  
80103336:	c3                   	ret    

80103337 <cpuid>:
cpuid() {
80103337:	55                   	push   %ebp
80103338:	89 e5                	mov    %esp,%ebp
8010333a:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010333d:	e8 99 ff ff ff       	call   801032db <mycpu>
80103342:	2d c0 27 13 80       	sub    $0x801327c0,%eax
80103347:	c1 f8 04             	sar    $0x4,%eax
8010334a:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103350:	c9                   	leave  
80103351:	c3                   	ret    

80103352 <myproc>:
myproc(void) {
80103352:	55                   	push   %ebp
80103353:	89 e5                	mov    %esp,%ebp
80103355:	53                   	push   %ebx
80103356:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103359:	e8 b6 08 00 00       	call   80103c14 <pushcli>
  c = mycpu();
8010335e:	e8 78 ff ff ff       	call   801032db <mycpu>
  p = c->proc;
80103363:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
80103369:	e8 e3 08 00 00       	call   80103c51 <popcli>
}
8010336e:	89 d8                	mov    %ebx,%eax
80103370:	83 c4 04             	add    $0x4,%esp
80103373:	5b                   	pop    %ebx
80103374:	5d                   	pop    %ebp
80103375:	c3                   	ret    

80103376 <userinit>:
{
80103376:	55                   	push   %ebp
80103377:	89 e5                	mov    %esp,%ebp
80103379:	53                   	push   %ebx
8010337a:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
8010337d:	e8 3b fe ff ff       	call   801031bd <allocproc>
80103382:	89 c3                	mov    %eax,%ebx
  initproc = p;
80103384:	a3 c0 a5 10 80       	mov    %eax,0x8010a5c0
  if((p->pgdir = setupkvm()) == 0)
80103389:	e8 09 30 00 00       	call   80106397 <setupkvm>
8010338e:	89 43 04             	mov    %eax,0x4(%ebx)
80103391:	85 c0                	test   %eax,%eax
80103393:	0f 84 b7 00 00 00    	je     80103450 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103399:	83 ec 04             	sub    $0x4,%esp
8010339c:	68 2c 00 00 00       	push   $0x2c
801033a1:	68 60 a4 10 80       	push   $0x8010a460
801033a6:	50                   	push   %eax
801033a7:	e8 f6 2c 00 00       	call   801060a2 <inituvm>
  p->sz = PGSIZE;
801033ac:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801033b2:	83 c4 0c             	add    $0xc,%esp
801033b5:	6a 4c                	push   $0x4c
801033b7:	6a 00                	push   $0x0
801033b9:	ff 73 18             	pushl  0x18(%ebx)
801033bc:	e8 dc 09 00 00       	call   80103d9d <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801033c1:	8b 43 18             	mov    0x18(%ebx),%eax
801033c4:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801033ca:	8b 43 18             	mov    0x18(%ebx),%eax
801033cd:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801033d3:	8b 43 18             	mov    0x18(%ebx),%eax
801033d6:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801033da:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801033de:	8b 43 18             	mov    0x18(%ebx),%eax
801033e1:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801033e5:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801033e9:	8b 43 18             	mov    0x18(%ebx),%eax
801033ec:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801033f3:	8b 43 18             	mov    0x18(%ebx),%eax
801033f6:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801033fd:	8b 43 18             	mov    0x18(%ebx),%eax
80103400:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103407:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010340a:	83 c4 0c             	add    $0xc,%esp
8010340d:	6a 10                	push   $0x10
8010340f:	68 c5 6b 10 80       	push   $0x80106bc5
80103414:	50                   	push   %eax
80103415:	e8 ea 0a 00 00       	call   80103f04 <safestrcpy>
  p->cwd = namei("/");
8010341a:	c7 04 24 ce 6b 10 80 	movl   $0x80106bce,(%esp)
80103421:	e8 bb e7 ff ff       	call   80101be1 <namei>
80103426:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103429:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103430:	e8 bc 08 00 00       	call   80103cf1 <acquire>
  p->state = RUNNABLE;
80103435:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
8010343c:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103443:	e8 0e 09 00 00       	call   80103d56 <release>
}
80103448:	83 c4 10             	add    $0x10,%esp
8010344b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010344e:	c9                   	leave  
8010344f:	c3                   	ret    
    panic("userinit: out of memory?");
80103450:	83 ec 0c             	sub    $0xc,%esp
80103453:	68 ac 6b 10 80       	push   $0x80106bac
80103458:	e8 eb ce ff ff       	call   80100348 <panic>

8010345d <growproc>:
{
8010345d:	55                   	push   %ebp
8010345e:	89 e5                	mov    %esp,%ebp
80103460:	56                   	push   %esi
80103461:	53                   	push   %ebx
80103462:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
80103465:	e8 e8 fe ff ff       	call   80103352 <myproc>
8010346a:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
8010346c:	8b 00                	mov    (%eax),%eax
  if(n > 0){
8010346e:	85 f6                	test   %esi,%esi
80103470:	7f 21                	jg     80103493 <growproc+0x36>
  } else if(n < 0){
80103472:	85 f6                	test   %esi,%esi
80103474:	79 33                	jns    801034a9 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103476:	83 ec 04             	sub    $0x4,%esp
80103479:	01 c6                	add    %eax,%esi
8010347b:	56                   	push   %esi
8010347c:	50                   	push   %eax
8010347d:	ff 73 04             	pushl  0x4(%ebx)
80103480:	e8 26 2d 00 00       	call   801061ab <deallocuvm>
80103485:	83 c4 10             	add    $0x10,%esp
80103488:	85 c0                	test   %eax,%eax
8010348a:	75 1d                	jne    801034a9 <growproc+0x4c>
      return -1;
8010348c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103491:	eb 29                	jmp    801034bc <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103493:	83 ec 04             	sub    $0x4,%esp
80103496:	01 c6                	add    %eax,%esi
80103498:	56                   	push   %esi
80103499:	50                   	push   %eax
8010349a:	ff 73 04             	pushl  0x4(%ebx)
8010349d:	e8 9b 2d 00 00       	call   8010623d <allocuvm>
801034a2:	83 c4 10             	add    $0x10,%esp
801034a5:	85 c0                	test   %eax,%eax
801034a7:	74 1a                	je     801034c3 <growproc+0x66>
  curproc->sz = sz;
801034a9:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801034ab:	83 ec 0c             	sub    $0xc,%esp
801034ae:	53                   	push   %ebx
801034af:	e8 d6 2a 00 00       	call   80105f8a <switchuvm>
  return 0;
801034b4:	83 c4 10             	add    $0x10,%esp
801034b7:	b8 00 00 00 00       	mov    $0x0,%eax
}
801034bc:	8d 65 f8             	lea    -0x8(%ebp),%esp
801034bf:	5b                   	pop    %ebx
801034c0:	5e                   	pop    %esi
801034c1:	5d                   	pop    %ebp
801034c2:	c3                   	ret    
      return -1;
801034c3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034c8:	eb f2                	jmp    801034bc <growproc+0x5f>

801034ca <fork>:
{
801034ca:	55                   	push   %ebp
801034cb:	89 e5                	mov    %esp,%ebp
801034cd:	57                   	push   %edi
801034ce:	56                   	push   %esi
801034cf:	53                   	push   %ebx
801034d0:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801034d3:	e8 7a fe ff ff       	call   80103352 <myproc>
801034d8:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801034da:	e8 de fc ff ff       	call   801031bd <allocproc>
801034df:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801034e2:	85 c0                	test   %eax,%eax
801034e4:	0f 84 e0 00 00 00    	je     801035ca <fork+0x100>
801034ea:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801034ec:	83 ec 08             	sub    $0x8,%esp
801034ef:	ff 33                	pushl  (%ebx)
801034f1:	ff 73 04             	pushl  0x4(%ebx)
801034f4:	e8 4f 2f 00 00       	call   80106448 <copyuvm>
801034f9:	89 47 04             	mov    %eax,0x4(%edi)
801034fc:	83 c4 10             	add    $0x10,%esp
801034ff:	85 c0                	test   %eax,%eax
80103501:	74 2a                	je     8010352d <fork+0x63>
  np->sz = curproc->sz;
80103503:	8b 03                	mov    (%ebx),%eax
80103505:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103508:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
8010350a:	89 c8                	mov    %ecx,%eax
8010350c:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
8010350f:	8b 73 18             	mov    0x18(%ebx),%esi
80103512:	8b 79 18             	mov    0x18(%ecx),%edi
80103515:	b9 13 00 00 00       	mov    $0x13,%ecx
8010351a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
8010351c:	8b 40 18             	mov    0x18(%eax),%eax
8010351f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103526:	be 00 00 00 00       	mov    $0x0,%esi
8010352b:	eb 29                	jmp    80103556 <fork+0x8c>
    kfree(np->kstack);
8010352d:	83 ec 0c             	sub    $0xc,%esp
80103530:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103533:	ff 73 08             	pushl  0x8(%ebx)
80103536:	e8 69 ea ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
8010353b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103542:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103549:	83 c4 10             	add    $0x10,%esp
8010354c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103551:	eb 6d                	jmp    801035c0 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
80103553:	83 c6 01             	add    $0x1,%esi
80103556:	83 fe 0f             	cmp    $0xf,%esi
80103559:	7f 1d                	jg     80103578 <fork+0xae>
    if(curproc->ofile[i])
8010355b:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010355f:	85 c0                	test   %eax,%eax
80103561:	74 f0                	je     80103553 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103563:	83 ec 0c             	sub    $0xc,%esp
80103566:	50                   	push   %eax
80103567:	e8 22 d7 ff ff       	call   80100c8e <filedup>
8010356c:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010356f:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103573:	83 c4 10             	add    $0x10,%esp
80103576:	eb db                	jmp    80103553 <fork+0x89>
  np->cwd = idup(curproc->cwd);
80103578:	83 ec 0c             	sub    $0xc,%esp
8010357b:	ff 73 68             	pushl  0x68(%ebx)
8010357e:	e8 ce df ff ff       	call   80101551 <idup>
80103583:	8b 7d e4             	mov    -0x1c(%ebp),%edi
80103586:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
80103589:	83 c3 6c             	add    $0x6c,%ebx
8010358c:	8d 47 6c             	lea    0x6c(%edi),%eax
8010358f:	83 c4 0c             	add    $0xc,%esp
80103592:	6a 10                	push   $0x10
80103594:	53                   	push   %ebx
80103595:	50                   	push   %eax
80103596:	e8 69 09 00 00       	call   80103f04 <safestrcpy>
  pid = np->pid;
8010359b:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010359e:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
801035a5:	e8 47 07 00 00       	call   80103cf1 <acquire>
  np->state = RUNNABLE;
801035aa:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
801035b1:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
801035b8:	e8 99 07 00 00       	call   80103d56 <release>
  return pid;
801035bd:	83 c4 10             	add    $0x10,%esp
}
801035c0:	89 d8                	mov    %ebx,%eax
801035c2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801035c5:	5b                   	pop    %ebx
801035c6:	5e                   	pop    %esi
801035c7:	5f                   	pop    %edi
801035c8:	5d                   	pop    %ebp
801035c9:	c3                   	ret    
    return -1;
801035ca:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801035cf:	eb ef                	jmp    801035c0 <fork+0xf6>

801035d1 <scheduler>:
{
801035d1:	55                   	push   %ebp
801035d2:	89 e5                	mov    %esp,%ebp
801035d4:	56                   	push   %esi
801035d5:	53                   	push   %ebx
  struct cpu *c = mycpu();
801035d6:	e8 00 fd ff ff       	call   801032db <mycpu>
801035db:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801035dd:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801035e4:	00 00 00 
801035e7:	eb 5a                	jmp    80103643 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801035e9:	83 c3 7c             	add    $0x7c,%ebx
801035ec:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
801035f2:	73 3f                	jae    80103633 <scheduler+0x62>
      if(p->state != RUNNABLE)
801035f4:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801035f8:	75 ef                	jne    801035e9 <scheduler+0x18>
      c->proc = p;
801035fa:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103600:	83 ec 0c             	sub    $0xc,%esp
80103603:	53                   	push   %ebx
80103604:	e8 81 29 00 00       	call   80105f8a <switchuvm>
      p->state = RUNNING;
80103609:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103610:	83 c4 08             	add    $0x8,%esp
80103613:	ff 73 1c             	pushl  0x1c(%ebx)
80103616:	8d 46 04             	lea    0x4(%esi),%eax
80103619:	50                   	push   %eax
8010361a:	e8 38 09 00 00       	call   80103f57 <swtch>
      switchkvm();
8010361f:	e8 54 29 00 00       	call   80105f78 <switchkvm>
      c->proc = 0;
80103624:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
8010362b:	00 00 00 
8010362e:	83 c4 10             	add    $0x10,%esp
80103631:	eb b6                	jmp    801035e9 <scheduler+0x18>
    release(&ptable.lock);
80103633:	83 ec 0c             	sub    $0xc,%esp
80103636:	68 60 2d 13 80       	push   $0x80132d60
8010363b:	e8 16 07 00 00       	call   80103d56 <release>
    sti();
80103640:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103643:	fb                   	sti    
    acquire(&ptable.lock);
80103644:	83 ec 0c             	sub    $0xc,%esp
80103647:	68 60 2d 13 80       	push   $0x80132d60
8010364c:	e8 a0 06 00 00       	call   80103cf1 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103651:	83 c4 10             	add    $0x10,%esp
80103654:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
80103659:	eb 91                	jmp    801035ec <scheduler+0x1b>

8010365b <sched>:
{
8010365b:	55                   	push   %ebp
8010365c:	89 e5                	mov    %esp,%ebp
8010365e:	56                   	push   %esi
8010365f:	53                   	push   %ebx
  struct proc *p = myproc();
80103660:	e8 ed fc ff ff       	call   80103352 <myproc>
80103665:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
80103667:	83 ec 0c             	sub    $0xc,%esp
8010366a:	68 60 2d 13 80       	push   $0x80132d60
8010366f:	e8 3d 06 00 00       	call   80103cb1 <holding>
80103674:	83 c4 10             	add    $0x10,%esp
80103677:	85 c0                	test   %eax,%eax
80103679:	74 4f                	je     801036ca <sched+0x6f>
  if(mycpu()->ncli != 1)
8010367b:	e8 5b fc ff ff       	call   801032db <mycpu>
80103680:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
80103687:	75 4e                	jne    801036d7 <sched+0x7c>
  if(p->state == RUNNING)
80103689:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
8010368d:	74 55                	je     801036e4 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010368f:	9c                   	pushf  
80103690:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103691:	f6 c4 02             	test   $0x2,%ah
80103694:	75 5b                	jne    801036f1 <sched+0x96>
  intena = mycpu()->intena;
80103696:	e8 40 fc ff ff       	call   801032db <mycpu>
8010369b:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801036a1:	e8 35 fc ff ff       	call   801032db <mycpu>
801036a6:	83 ec 08             	sub    $0x8,%esp
801036a9:	ff 70 04             	pushl  0x4(%eax)
801036ac:	83 c3 1c             	add    $0x1c,%ebx
801036af:	53                   	push   %ebx
801036b0:	e8 a2 08 00 00       	call   80103f57 <swtch>
  mycpu()->intena = intena;
801036b5:	e8 21 fc ff ff       	call   801032db <mycpu>
801036ba:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801036c0:	83 c4 10             	add    $0x10,%esp
801036c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801036c6:	5b                   	pop    %ebx
801036c7:	5e                   	pop    %esi
801036c8:	5d                   	pop    %ebp
801036c9:	c3                   	ret    
    panic("sched ptable.lock");
801036ca:	83 ec 0c             	sub    $0xc,%esp
801036cd:	68 d0 6b 10 80       	push   $0x80106bd0
801036d2:	e8 71 cc ff ff       	call   80100348 <panic>
    panic("sched locks");
801036d7:	83 ec 0c             	sub    $0xc,%esp
801036da:	68 e2 6b 10 80       	push   $0x80106be2
801036df:	e8 64 cc ff ff       	call   80100348 <panic>
    panic("sched running");
801036e4:	83 ec 0c             	sub    $0xc,%esp
801036e7:	68 ee 6b 10 80       	push   $0x80106bee
801036ec:	e8 57 cc ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801036f1:	83 ec 0c             	sub    $0xc,%esp
801036f4:	68 fc 6b 10 80       	push   $0x80106bfc
801036f9:	e8 4a cc ff ff       	call   80100348 <panic>

801036fe <exit>:
{
801036fe:	55                   	push   %ebp
801036ff:	89 e5                	mov    %esp,%ebp
80103701:	56                   	push   %esi
80103702:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103703:	e8 4a fc ff ff       	call   80103352 <myproc>
  if(curproc == initproc)
80103708:	39 05 c0 a5 10 80    	cmp    %eax,0x8010a5c0
8010370e:	74 09                	je     80103719 <exit+0x1b>
80103710:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103712:	bb 00 00 00 00       	mov    $0x0,%ebx
80103717:	eb 10                	jmp    80103729 <exit+0x2b>
    panic("init exiting");
80103719:	83 ec 0c             	sub    $0xc,%esp
8010371c:	68 10 6c 10 80       	push   $0x80106c10
80103721:	e8 22 cc ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
80103726:	83 c3 01             	add    $0x1,%ebx
80103729:	83 fb 0f             	cmp    $0xf,%ebx
8010372c:	7f 1e                	jg     8010374c <exit+0x4e>
    if(curproc->ofile[fd]){
8010372e:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103732:	85 c0                	test   %eax,%eax
80103734:	74 f0                	je     80103726 <exit+0x28>
      fileclose(curproc->ofile[fd]);
80103736:	83 ec 0c             	sub    $0xc,%esp
80103739:	50                   	push   %eax
8010373a:	e8 94 d5 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
8010373f:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103746:	00 
80103747:	83 c4 10             	add    $0x10,%esp
8010374a:	eb da                	jmp    80103726 <exit+0x28>
  begin_op();
8010374c:	e8 b9 f1 ff ff       	call   8010290a <begin_op>
  iput(curproc->cwd);
80103751:	83 ec 0c             	sub    $0xc,%esp
80103754:	ff 76 68             	pushl  0x68(%esi)
80103757:	e8 2c df ff ff       	call   80101688 <iput>
  end_op();
8010375c:	e8 23 f2 ff ff       	call   80102984 <end_op>
  curproc->cwd = 0;
80103761:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
80103768:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
8010376f:	e8 7d 05 00 00       	call   80103cf1 <acquire>
  wakeup1(curproc->parent);
80103774:	8b 46 14             	mov    0x14(%esi),%eax
80103777:	e8 16 fa ff ff       	call   80103192 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010377c:	83 c4 10             	add    $0x10,%esp
8010377f:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
80103784:	eb 03                	jmp    80103789 <exit+0x8b>
80103786:	83 c3 7c             	add    $0x7c,%ebx
80103789:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
8010378f:	73 1a                	jae    801037ab <exit+0xad>
    if(p->parent == curproc){
80103791:	39 73 14             	cmp    %esi,0x14(%ebx)
80103794:	75 f0                	jne    80103786 <exit+0x88>
      p->parent = initproc;
80103796:	a1 c0 a5 10 80       	mov    0x8010a5c0,%eax
8010379b:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
8010379e:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801037a2:	75 e2                	jne    80103786 <exit+0x88>
        wakeup1(initproc);
801037a4:	e8 e9 f9 ff ff       	call   80103192 <wakeup1>
801037a9:	eb db                	jmp    80103786 <exit+0x88>
  curproc->state = ZOMBIE;
801037ab:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801037b2:	e8 a4 fe ff ff       	call   8010365b <sched>
  panic("zombie exit");
801037b7:	83 ec 0c             	sub    $0xc,%esp
801037ba:	68 1d 6c 10 80       	push   $0x80106c1d
801037bf:	e8 84 cb ff ff       	call   80100348 <panic>

801037c4 <yield>:
{
801037c4:	55                   	push   %ebp
801037c5:	89 e5                	mov    %esp,%ebp
801037c7:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801037ca:	68 60 2d 13 80       	push   $0x80132d60
801037cf:	e8 1d 05 00 00       	call   80103cf1 <acquire>
  myproc()->state = RUNNABLE;
801037d4:	e8 79 fb ff ff       	call   80103352 <myproc>
801037d9:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801037e0:	e8 76 fe ff ff       	call   8010365b <sched>
  release(&ptable.lock);
801037e5:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
801037ec:	e8 65 05 00 00       	call   80103d56 <release>
}
801037f1:	83 c4 10             	add    $0x10,%esp
801037f4:	c9                   	leave  
801037f5:	c3                   	ret    

801037f6 <sleep>:
{
801037f6:	55                   	push   %ebp
801037f7:	89 e5                	mov    %esp,%ebp
801037f9:	56                   	push   %esi
801037fa:	53                   	push   %ebx
801037fb:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
801037fe:	e8 4f fb ff ff       	call   80103352 <myproc>
  if(p == 0)
80103803:	85 c0                	test   %eax,%eax
80103805:	74 66                	je     8010386d <sleep+0x77>
80103807:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103809:	85 db                	test   %ebx,%ebx
8010380b:	74 6d                	je     8010387a <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010380d:	81 fb 60 2d 13 80    	cmp    $0x80132d60,%ebx
80103813:	74 18                	je     8010382d <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103815:	83 ec 0c             	sub    $0xc,%esp
80103818:	68 60 2d 13 80       	push   $0x80132d60
8010381d:	e8 cf 04 00 00       	call   80103cf1 <acquire>
    release(lk);
80103822:	89 1c 24             	mov    %ebx,(%esp)
80103825:	e8 2c 05 00 00       	call   80103d56 <release>
8010382a:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010382d:	8b 45 08             	mov    0x8(%ebp),%eax
80103830:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103833:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
8010383a:	e8 1c fe ff ff       	call   8010365b <sched>
  p->chan = 0;
8010383f:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103846:	81 fb 60 2d 13 80    	cmp    $0x80132d60,%ebx
8010384c:	74 18                	je     80103866 <sleep+0x70>
    release(&ptable.lock);
8010384e:	83 ec 0c             	sub    $0xc,%esp
80103851:	68 60 2d 13 80       	push   $0x80132d60
80103856:	e8 fb 04 00 00       	call   80103d56 <release>
    acquire(lk);
8010385b:	89 1c 24             	mov    %ebx,(%esp)
8010385e:	e8 8e 04 00 00       	call   80103cf1 <acquire>
80103863:	83 c4 10             	add    $0x10,%esp
}
80103866:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103869:	5b                   	pop    %ebx
8010386a:	5e                   	pop    %esi
8010386b:	5d                   	pop    %ebp
8010386c:	c3                   	ret    
    panic("sleep");
8010386d:	83 ec 0c             	sub    $0xc,%esp
80103870:	68 29 6c 10 80       	push   $0x80106c29
80103875:	e8 ce ca ff ff       	call   80100348 <panic>
    panic("sleep without lk");
8010387a:	83 ec 0c             	sub    $0xc,%esp
8010387d:	68 2f 6c 10 80       	push   $0x80106c2f
80103882:	e8 c1 ca ff ff       	call   80100348 <panic>

80103887 <wait>:
{
80103887:	55                   	push   %ebp
80103888:	89 e5                	mov    %esp,%ebp
8010388a:	56                   	push   %esi
8010388b:	53                   	push   %ebx
  struct proc *curproc = myproc();
8010388c:	e8 c1 fa ff ff       	call   80103352 <myproc>
80103891:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103893:	83 ec 0c             	sub    $0xc,%esp
80103896:	68 60 2d 13 80       	push   $0x80132d60
8010389b:	e8 51 04 00 00       	call   80103cf1 <acquire>
801038a0:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801038a3:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038a8:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
801038ad:	eb 5b                	jmp    8010390a <wait+0x83>
        pid = p->pid;
801038af:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801038b2:	83 ec 0c             	sub    $0xc,%esp
801038b5:	ff 73 08             	pushl  0x8(%ebx)
801038b8:	e8 e7 e6 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
801038bd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801038c4:	83 c4 04             	add    $0x4,%esp
801038c7:	ff 73 04             	pushl  0x4(%ebx)
801038ca:	e8 58 2a 00 00       	call   80106327 <freevm>
        p->pid = 0;
801038cf:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801038d6:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801038dd:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801038e1:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801038e8:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801038ef:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
801038f6:	e8 5b 04 00 00       	call   80103d56 <release>
        return pid;
801038fb:	83 c4 10             	add    $0x10,%esp
}
801038fe:	89 f0                	mov    %esi,%eax
80103900:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103903:	5b                   	pop    %ebx
80103904:	5e                   	pop    %esi
80103905:	5d                   	pop    %ebp
80103906:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103907:	83 c3 7c             	add    $0x7c,%ebx
8010390a:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
80103910:	73 12                	jae    80103924 <wait+0x9d>
      if(p->parent != curproc)
80103912:	39 73 14             	cmp    %esi,0x14(%ebx)
80103915:	75 f0                	jne    80103907 <wait+0x80>
      if(p->state == ZOMBIE){
80103917:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010391b:	74 92                	je     801038af <wait+0x28>
      havekids = 1;
8010391d:	b8 01 00 00 00       	mov    $0x1,%eax
80103922:	eb e3                	jmp    80103907 <wait+0x80>
    if(!havekids || curproc->killed){
80103924:	85 c0                	test   %eax,%eax
80103926:	74 06                	je     8010392e <wait+0xa7>
80103928:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
8010392c:	74 17                	je     80103945 <wait+0xbe>
      release(&ptable.lock);
8010392e:	83 ec 0c             	sub    $0xc,%esp
80103931:	68 60 2d 13 80       	push   $0x80132d60
80103936:	e8 1b 04 00 00       	call   80103d56 <release>
      return -1;
8010393b:	83 c4 10             	add    $0x10,%esp
8010393e:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103943:	eb b9                	jmp    801038fe <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103945:	83 ec 08             	sub    $0x8,%esp
80103948:	68 60 2d 13 80       	push   $0x80132d60
8010394d:	56                   	push   %esi
8010394e:	e8 a3 fe ff ff       	call   801037f6 <sleep>
    havekids = 0;
80103953:	83 c4 10             	add    $0x10,%esp
80103956:	e9 48 ff ff ff       	jmp    801038a3 <wait+0x1c>

8010395b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010395b:	55                   	push   %ebp
8010395c:	89 e5                	mov    %esp,%ebp
8010395e:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103961:	68 60 2d 13 80       	push   $0x80132d60
80103966:	e8 86 03 00 00       	call   80103cf1 <acquire>
  wakeup1(chan);
8010396b:	8b 45 08             	mov    0x8(%ebp),%eax
8010396e:	e8 1f f8 ff ff       	call   80103192 <wakeup1>
  release(&ptable.lock);
80103973:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
8010397a:	e8 d7 03 00 00       	call   80103d56 <release>
}
8010397f:	83 c4 10             	add    $0x10,%esp
80103982:	c9                   	leave  
80103983:	c3                   	ret    

80103984 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103984:	55                   	push   %ebp
80103985:	89 e5                	mov    %esp,%ebp
80103987:	53                   	push   %ebx
80103988:	83 ec 10             	sub    $0x10,%esp
8010398b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
8010398e:	68 60 2d 13 80       	push   $0x80132d60
80103993:	e8 59 03 00 00       	call   80103cf1 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103998:	83 c4 10             	add    $0x10,%esp
8010399b:	b8 94 2d 13 80       	mov    $0x80132d94,%eax
801039a0:	3d 94 4c 13 80       	cmp    $0x80134c94,%eax
801039a5:	73 3a                	jae    801039e1 <kill+0x5d>
    if(p->pid == pid){
801039a7:	39 58 10             	cmp    %ebx,0x10(%eax)
801039aa:	74 05                	je     801039b1 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039ac:	83 c0 7c             	add    $0x7c,%eax
801039af:	eb ef                	jmp    801039a0 <kill+0x1c>
      p->killed = 1;
801039b1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801039b8:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801039bc:	74 1a                	je     801039d8 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
801039be:	83 ec 0c             	sub    $0xc,%esp
801039c1:	68 60 2d 13 80       	push   $0x80132d60
801039c6:	e8 8b 03 00 00       	call   80103d56 <release>
      return 0;
801039cb:	83 c4 10             	add    $0x10,%esp
801039ce:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801039d3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039d6:	c9                   	leave  
801039d7:	c3                   	ret    
        p->state = RUNNABLE;
801039d8:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801039df:	eb dd                	jmp    801039be <kill+0x3a>
  release(&ptable.lock);
801039e1:	83 ec 0c             	sub    $0xc,%esp
801039e4:	68 60 2d 13 80       	push   $0x80132d60
801039e9:	e8 68 03 00 00       	call   80103d56 <release>
  return -1;
801039ee:	83 c4 10             	add    $0x10,%esp
801039f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801039f6:	eb db                	jmp    801039d3 <kill+0x4f>

801039f8 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801039f8:	55                   	push   %ebp
801039f9:	89 e5                	mov    %esp,%ebp
801039fb:	56                   	push   %esi
801039fc:	53                   	push   %ebx
801039fd:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a00:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
80103a05:	eb 33                	jmp    80103a3a <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103a07:	b8 40 6c 10 80       	mov    $0x80106c40,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103a0c:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103a0f:	52                   	push   %edx
80103a10:	50                   	push   %eax
80103a11:	ff 73 10             	pushl  0x10(%ebx)
80103a14:	68 44 6c 10 80       	push   $0x80106c44
80103a19:	e8 ed cb ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103a1e:	83 c4 10             	add    $0x10,%esp
80103a21:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103a25:	74 39                	je     80103a60 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103a27:	83 ec 0c             	sub    $0xc,%esp
80103a2a:	68 bb 6f 10 80       	push   $0x80106fbb
80103a2f:	e8 d7 cb ff ff       	call   8010060b <cprintf>
80103a34:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a37:	83 c3 7c             	add    $0x7c,%ebx
80103a3a:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
80103a40:	73 61                	jae    80103aa3 <procdump+0xab>
    if(p->state == UNUSED)
80103a42:	8b 43 0c             	mov    0xc(%ebx),%eax
80103a45:	85 c0                	test   %eax,%eax
80103a47:	74 ee                	je     80103a37 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a49:	83 f8 05             	cmp    $0x5,%eax
80103a4c:	77 b9                	ja     80103a07 <procdump+0xf>
80103a4e:	8b 04 85 a0 6c 10 80 	mov    -0x7fef9360(,%eax,4),%eax
80103a55:	85 c0                	test   %eax,%eax
80103a57:	75 b3                	jne    80103a0c <procdump+0x14>
      state = "???";
80103a59:	b8 40 6c 10 80       	mov    $0x80106c40,%eax
80103a5e:	eb ac                	jmp    80103a0c <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103a60:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103a63:	8b 40 0c             	mov    0xc(%eax),%eax
80103a66:	83 c0 08             	add    $0x8,%eax
80103a69:	83 ec 08             	sub    $0x8,%esp
80103a6c:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103a6f:	52                   	push   %edx
80103a70:	50                   	push   %eax
80103a71:	e8 5a 01 00 00       	call   80103bd0 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a76:	83 c4 10             	add    $0x10,%esp
80103a79:	be 00 00 00 00       	mov    $0x0,%esi
80103a7e:	eb 14                	jmp    80103a94 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103a80:	83 ec 08             	sub    $0x8,%esp
80103a83:	50                   	push   %eax
80103a84:	68 41 66 10 80       	push   $0x80106641
80103a89:	e8 7d cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103a8e:	83 c6 01             	add    $0x1,%esi
80103a91:	83 c4 10             	add    $0x10,%esp
80103a94:	83 fe 09             	cmp    $0x9,%esi
80103a97:	7f 8e                	jg     80103a27 <procdump+0x2f>
80103a99:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103a9d:	85 c0                	test   %eax,%eax
80103a9f:	75 df                	jne    80103a80 <procdump+0x88>
80103aa1:	eb 84                	jmp    80103a27 <procdump+0x2f>
  }
}
80103aa3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103aa6:	5b                   	pop    %ebx
80103aa7:	5e                   	pop    %esi
80103aa8:	5d                   	pop    %ebp
80103aa9:	c3                   	ret    

80103aaa <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103aaa:	55                   	push   %ebp
80103aab:	89 e5                	mov    %esp,%ebp
80103aad:	53                   	push   %ebx
80103aae:	83 ec 0c             	sub    $0xc,%esp
80103ab1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103ab4:	68 b8 6c 10 80       	push   $0x80106cb8
80103ab9:	8d 43 04             	lea    0x4(%ebx),%eax
80103abc:	50                   	push   %eax
80103abd:	e8 f3 00 00 00       	call   80103bb5 <initlock>
  lk->name = name;
80103ac2:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ac5:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103ac8:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103ace:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103ad5:	83 c4 10             	add    $0x10,%esp
80103ad8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103adb:	c9                   	leave  
80103adc:	c3                   	ret    

80103add <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103add:	55                   	push   %ebp
80103ade:	89 e5                	mov    %esp,%ebp
80103ae0:	56                   	push   %esi
80103ae1:	53                   	push   %ebx
80103ae2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103ae5:	8d 73 04             	lea    0x4(%ebx),%esi
80103ae8:	83 ec 0c             	sub    $0xc,%esp
80103aeb:	56                   	push   %esi
80103aec:	e8 00 02 00 00       	call   80103cf1 <acquire>
  while (lk->locked) {
80103af1:	83 c4 10             	add    $0x10,%esp
80103af4:	eb 0d                	jmp    80103b03 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103af6:	83 ec 08             	sub    $0x8,%esp
80103af9:	56                   	push   %esi
80103afa:	53                   	push   %ebx
80103afb:	e8 f6 fc ff ff       	call   801037f6 <sleep>
80103b00:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103b03:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b06:	75 ee                	jne    80103af6 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103b08:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103b0e:	e8 3f f8 ff ff       	call   80103352 <myproc>
80103b13:	8b 40 10             	mov    0x10(%eax),%eax
80103b16:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103b19:	83 ec 0c             	sub    $0xc,%esp
80103b1c:	56                   	push   %esi
80103b1d:	e8 34 02 00 00       	call   80103d56 <release>
}
80103b22:	83 c4 10             	add    $0x10,%esp
80103b25:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b28:	5b                   	pop    %ebx
80103b29:	5e                   	pop    %esi
80103b2a:	5d                   	pop    %ebp
80103b2b:	c3                   	ret    

80103b2c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103b2c:	55                   	push   %ebp
80103b2d:	89 e5                	mov    %esp,%ebp
80103b2f:	56                   	push   %esi
80103b30:	53                   	push   %ebx
80103b31:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b34:	8d 73 04             	lea    0x4(%ebx),%esi
80103b37:	83 ec 0c             	sub    $0xc,%esp
80103b3a:	56                   	push   %esi
80103b3b:	e8 b1 01 00 00       	call   80103cf1 <acquire>
  lk->locked = 0;
80103b40:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b46:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103b4d:	89 1c 24             	mov    %ebx,(%esp)
80103b50:	e8 06 fe ff ff       	call   8010395b <wakeup>
  release(&lk->lk);
80103b55:	89 34 24             	mov    %esi,(%esp)
80103b58:	e8 f9 01 00 00       	call   80103d56 <release>
}
80103b5d:	83 c4 10             	add    $0x10,%esp
80103b60:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b63:	5b                   	pop    %ebx
80103b64:	5e                   	pop    %esi
80103b65:	5d                   	pop    %ebp
80103b66:	c3                   	ret    

80103b67 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103b67:	55                   	push   %ebp
80103b68:	89 e5                	mov    %esp,%ebp
80103b6a:	56                   	push   %esi
80103b6b:	53                   	push   %ebx
80103b6c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103b6f:	8d 73 04             	lea    0x4(%ebx),%esi
80103b72:	83 ec 0c             	sub    $0xc,%esp
80103b75:	56                   	push   %esi
80103b76:	e8 76 01 00 00       	call   80103cf1 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103b7b:	83 c4 10             	add    $0x10,%esp
80103b7e:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b81:	75 17                	jne    80103b9a <holdingsleep+0x33>
80103b83:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103b88:	83 ec 0c             	sub    $0xc,%esp
80103b8b:	56                   	push   %esi
80103b8c:	e8 c5 01 00 00       	call   80103d56 <release>
  return r;
}
80103b91:	89 d8                	mov    %ebx,%eax
80103b93:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b96:	5b                   	pop    %ebx
80103b97:	5e                   	pop    %esi
80103b98:	5d                   	pop    %ebp
80103b99:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103b9a:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103b9d:	e8 b0 f7 ff ff       	call   80103352 <myproc>
80103ba2:	3b 58 10             	cmp    0x10(%eax),%ebx
80103ba5:	74 07                	je     80103bae <holdingsleep+0x47>
80103ba7:	bb 00 00 00 00       	mov    $0x0,%ebx
80103bac:	eb da                	jmp    80103b88 <holdingsleep+0x21>
80103bae:	bb 01 00 00 00       	mov    $0x1,%ebx
80103bb3:	eb d3                	jmp    80103b88 <holdingsleep+0x21>

80103bb5 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103bb5:	55                   	push   %ebp
80103bb6:	89 e5                	mov    %esp,%ebp
80103bb8:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103bbb:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bbe:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103bc1:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103bc7:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103bce:	5d                   	pop    %ebp
80103bcf:	c3                   	ret    

80103bd0 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103bd0:	55                   	push   %ebp
80103bd1:	89 e5                	mov    %esp,%ebp
80103bd3:	53                   	push   %ebx
80103bd4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103bd7:	8b 45 08             	mov    0x8(%ebp),%eax
80103bda:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103bdd:	b8 00 00 00 00       	mov    $0x0,%eax
80103be2:	83 f8 09             	cmp    $0x9,%eax
80103be5:	7f 25                	jg     80103c0c <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103be7:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103bed:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103bf3:	77 17                	ja     80103c0c <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103bf5:	8b 5a 04             	mov    0x4(%edx),%ebx
80103bf8:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103bfb:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103bfd:	83 c0 01             	add    $0x1,%eax
80103c00:	eb e0                	jmp    80103be2 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103c02:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103c09:	83 c0 01             	add    $0x1,%eax
80103c0c:	83 f8 09             	cmp    $0x9,%eax
80103c0f:	7e f1                	jle    80103c02 <getcallerpcs+0x32>
}
80103c11:	5b                   	pop    %ebx
80103c12:	5d                   	pop    %ebp
80103c13:	c3                   	ret    

80103c14 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103c14:	55                   	push   %ebp
80103c15:	89 e5                	mov    %esp,%ebp
80103c17:	53                   	push   %ebx
80103c18:	83 ec 04             	sub    $0x4,%esp
80103c1b:	9c                   	pushf  
80103c1c:	5b                   	pop    %ebx
  asm volatile("cli");
80103c1d:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103c1e:	e8 b8 f6 ff ff       	call   801032db <mycpu>
80103c23:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c2a:	74 12                	je     80103c3e <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103c2c:	e8 aa f6 ff ff       	call   801032db <mycpu>
80103c31:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103c38:	83 c4 04             	add    $0x4,%esp
80103c3b:	5b                   	pop    %ebx
80103c3c:	5d                   	pop    %ebp
80103c3d:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103c3e:	e8 98 f6 ff ff       	call   801032db <mycpu>
80103c43:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103c49:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103c4f:	eb db                	jmp    80103c2c <pushcli+0x18>

80103c51 <popcli>:

void
popcli(void)
{
80103c51:	55                   	push   %ebp
80103c52:	89 e5                	mov    %esp,%ebp
80103c54:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103c57:	9c                   	pushf  
80103c58:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103c59:	f6 c4 02             	test   $0x2,%ah
80103c5c:	75 28                	jne    80103c86 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103c5e:	e8 78 f6 ff ff       	call   801032db <mycpu>
80103c63:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103c69:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103c6c:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103c72:	85 d2                	test   %edx,%edx
80103c74:	78 1d                	js     80103c93 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103c76:	e8 60 f6 ff ff       	call   801032db <mycpu>
80103c7b:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c82:	74 1c                	je     80103ca0 <popcli+0x4f>
    sti();
}
80103c84:	c9                   	leave  
80103c85:	c3                   	ret    
    panic("popcli - interruptible");
80103c86:	83 ec 0c             	sub    $0xc,%esp
80103c89:	68 c3 6c 10 80       	push   $0x80106cc3
80103c8e:	e8 b5 c6 ff ff       	call   80100348 <panic>
    panic("popcli");
80103c93:	83 ec 0c             	sub    $0xc,%esp
80103c96:	68 da 6c 10 80       	push   $0x80106cda
80103c9b:	e8 a8 c6 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103ca0:	e8 36 f6 ff ff       	call   801032db <mycpu>
80103ca5:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103cac:	74 d6                	je     80103c84 <popcli+0x33>
  asm volatile("sti");
80103cae:	fb                   	sti    
}
80103caf:	eb d3                	jmp    80103c84 <popcli+0x33>

80103cb1 <holding>:
{
80103cb1:	55                   	push   %ebp
80103cb2:	89 e5                	mov    %esp,%ebp
80103cb4:	53                   	push   %ebx
80103cb5:	83 ec 04             	sub    $0x4,%esp
80103cb8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103cbb:	e8 54 ff ff ff       	call   80103c14 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103cc0:	83 3b 00             	cmpl   $0x0,(%ebx)
80103cc3:	75 12                	jne    80103cd7 <holding+0x26>
80103cc5:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103cca:	e8 82 ff ff ff       	call   80103c51 <popcli>
}
80103ccf:	89 d8                	mov    %ebx,%eax
80103cd1:	83 c4 04             	add    $0x4,%esp
80103cd4:	5b                   	pop    %ebx
80103cd5:	5d                   	pop    %ebp
80103cd6:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103cd7:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103cda:	e8 fc f5 ff ff       	call   801032db <mycpu>
80103cdf:	39 c3                	cmp    %eax,%ebx
80103ce1:	74 07                	je     80103cea <holding+0x39>
80103ce3:	bb 00 00 00 00       	mov    $0x0,%ebx
80103ce8:	eb e0                	jmp    80103cca <holding+0x19>
80103cea:	bb 01 00 00 00       	mov    $0x1,%ebx
80103cef:	eb d9                	jmp    80103cca <holding+0x19>

80103cf1 <acquire>:
{
80103cf1:	55                   	push   %ebp
80103cf2:	89 e5                	mov    %esp,%ebp
80103cf4:	53                   	push   %ebx
80103cf5:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103cf8:	e8 17 ff ff ff       	call   80103c14 <pushcli>
  if(holding(lk))
80103cfd:	83 ec 0c             	sub    $0xc,%esp
80103d00:	ff 75 08             	pushl  0x8(%ebp)
80103d03:	e8 a9 ff ff ff       	call   80103cb1 <holding>
80103d08:	83 c4 10             	add    $0x10,%esp
80103d0b:	85 c0                	test   %eax,%eax
80103d0d:	75 3a                	jne    80103d49 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103d0f:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103d12:	b8 01 00 00 00       	mov    $0x1,%eax
80103d17:	f0 87 02             	lock xchg %eax,(%edx)
80103d1a:	85 c0                	test   %eax,%eax
80103d1c:	75 f1                	jne    80103d0f <acquire+0x1e>
  __sync_synchronize();
80103d1e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103d23:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103d26:	e8 b0 f5 ff ff       	call   801032db <mycpu>
80103d2b:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103d2e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d31:	83 c0 0c             	add    $0xc,%eax
80103d34:	83 ec 08             	sub    $0x8,%esp
80103d37:	50                   	push   %eax
80103d38:	8d 45 08             	lea    0x8(%ebp),%eax
80103d3b:	50                   	push   %eax
80103d3c:	e8 8f fe ff ff       	call   80103bd0 <getcallerpcs>
}
80103d41:	83 c4 10             	add    $0x10,%esp
80103d44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d47:	c9                   	leave  
80103d48:	c3                   	ret    
    panic("acquire");
80103d49:	83 ec 0c             	sub    $0xc,%esp
80103d4c:	68 e1 6c 10 80       	push   $0x80106ce1
80103d51:	e8 f2 c5 ff ff       	call   80100348 <panic>

80103d56 <release>:
{
80103d56:	55                   	push   %ebp
80103d57:	89 e5                	mov    %esp,%ebp
80103d59:	53                   	push   %ebx
80103d5a:	83 ec 10             	sub    $0x10,%esp
80103d5d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103d60:	53                   	push   %ebx
80103d61:	e8 4b ff ff ff       	call   80103cb1 <holding>
80103d66:	83 c4 10             	add    $0x10,%esp
80103d69:	85 c0                	test   %eax,%eax
80103d6b:	74 23                	je     80103d90 <release+0x3a>
  lk->pcs[0] = 0;
80103d6d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103d74:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103d7b:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103d80:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103d86:	e8 c6 fe ff ff       	call   80103c51 <popcli>
}
80103d8b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d8e:	c9                   	leave  
80103d8f:	c3                   	ret    
    panic("release");
80103d90:	83 ec 0c             	sub    $0xc,%esp
80103d93:	68 e9 6c 10 80       	push   $0x80106ce9
80103d98:	e8 ab c5 ff ff       	call   80100348 <panic>

80103d9d <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103d9d:	55                   	push   %ebp
80103d9e:	89 e5                	mov    %esp,%ebp
80103da0:	57                   	push   %edi
80103da1:	53                   	push   %ebx
80103da2:	8b 55 08             	mov    0x8(%ebp),%edx
80103da5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103da8:	f6 c2 03             	test   $0x3,%dl
80103dab:	75 05                	jne    80103db2 <memset+0x15>
80103dad:	f6 c1 03             	test   $0x3,%cl
80103db0:	74 0e                	je     80103dc0 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103db2:	89 d7                	mov    %edx,%edi
80103db4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103db7:	fc                   	cld    
80103db8:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103dba:	89 d0                	mov    %edx,%eax
80103dbc:	5b                   	pop    %ebx
80103dbd:	5f                   	pop    %edi
80103dbe:	5d                   	pop    %ebp
80103dbf:	c3                   	ret    
    c &= 0xFF;
80103dc0:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103dc4:	c1 e9 02             	shr    $0x2,%ecx
80103dc7:	89 f8                	mov    %edi,%eax
80103dc9:	c1 e0 18             	shl    $0x18,%eax
80103dcc:	89 fb                	mov    %edi,%ebx
80103dce:	c1 e3 10             	shl    $0x10,%ebx
80103dd1:	09 d8                	or     %ebx,%eax
80103dd3:	89 fb                	mov    %edi,%ebx
80103dd5:	c1 e3 08             	shl    $0x8,%ebx
80103dd8:	09 d8                	or     %ebx,%eax
80103dda:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103ddc:	89 d7                	mov    %edx,%edi
80103dde:	fc                   	cld    
80103ddf:	f3 ab                	rep stos %eax,%es:(%edi)
80103de1:	eb d7                	jmp    80103dba <memset+0x1d>

80103de3 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103de3:	55                   	push   %ebp
80103de4:	89 e5                	mov    %esp,%ebp
80103de6:	56                   	push   %esi
80103de7:	53                   	push   %ebx
80103de8:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103deb:	8b 55 0c             	mov    0xc(%ebp),%edx
80103dee:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103df1:	8d 70 ff             	lea    -0x1(%eax),%esi
80103df4:	85 c0                	test   %eax,%eax
80103df6:	74 1c                	je     80103e14 <memcmp+0x31>
    if(*s1 != *s2)
80103df8:	0f b6 01             	movzbl (%ecx),%eax
80103dfb:	0f b6 1a             	movzbl (%edx),%ebx
80103dfe:	38 d8                	cmp    %bl,%al
80103e00:	75 0a                	jne    80103e0c <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103e02:	83 c1 01             	add    $0x1,%ecx
80103e05:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103e08:	89 f0                	mov    %esi,%eax
80103e0a:	eb e5                	jmp    80103df1 <memcmp+0xe>
      return *s1 - *s2;
80103e0c:	0f b6 c0             	movzbl %al,%eax
80103e0f:	0f b6 db             	movzbl %bl,%ebx
80103e12:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103e14:	5b                   	pop    %ebx
80103e15:	5e                   	pop    %esi
80103e16:	5d                   	pop    %ebp
80103e17:	c3                   	ret    

80103e18 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103e18:	55                   	push   %ebp
80103e19:	89 e5                	mov    %esp,%ebp
80103e1b:	56                   	push   %esi
80103e1c:	53                   	push   %ebx
80103e1d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e20:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e23:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103e26:	39 c1                	cmp    %eax,%ecx
80103e28:	73 3a                	jae    80103e64 <memmove+0x4c>
80103e2a:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103e2d:	39 c3                	cmp    %eax,%ebx
80103e2f:	76 37                	jbe    80103e68 <memmove+0x50>
    s += n;
    d += n;
80103e31:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103e34:	eb 0d                	jmp    80103e43 <memmove+0x2b>
      *--d = *--s;
80103e36:	83 eb 01             	sub    $0x1,%ebx
80103e39:	83 e9 01             	sub    $0x1,%ecx
80103e3c:	0f b6 13             	movzbl (%ebx),%edx
80103e3f:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103e41:	89 f2                	mov    %esi,%edx
80103e43:	8d 72 ff             	lea    -0x1(%edx),%esi
80103e46:	85 d2                	test   %edx,%edx
80103e48:	75 ec                	jne    80103e36 <memmove+0x1e>
80103e4a:	eb 14                	jmp    80103e60 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103e4c:	0f b6 11             	movzbl (%ecx),%edx
80103e4f:	88 13                	mov    %dl,(%ebx)
80103e51:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103e54:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103e57:	89 f2                	mov    %esi,%edx
80103e59:	8d 72 ff             	lea    -0x1(%edx),%esi
80103e5c:	85 d2                	test   %edx,%edx
80103e5e:	75 ec                	jne    80103e4c <memmove+0x34>

  return dst;
}
80103e60:	5b                   	pop    %ebx
80103e61:	5e                   	pop    %esi
80103e62:	5d                   	pop    %ebp
80103e63:	c3                   	ret    
80103e64:	89 c3                	mov    %eax,%ebx
80103e66:	eb f1                	jmp    80103e59 <memmove+0x41>
80103e68:	89 c3                	mov    %eax,%ebx
80103e6a:	eb ed                	jmp    80103e59 <memmove+0x41>

80103e6c <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103e6c:	55                   	push   %ebp
80103e6d:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103e6f:	ff 75 10             	pushl  0x10(%ebp)
80103e72:	ff 75 0c             	pushl  0xc(%ebp)
80103e75:	ff 75 08             	pushl  0x8(%ebp)
80103e78:	e8 9b ff ff ff       	call   80103e18 <memmove>
}
80103e7d:	c9                   	leave  
80103e7e:	c3                   	ret    

80103e7f <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103e7f:	55                   	push   %ebp
80103e80:	89 e5                	mov    %esp,%ebp
80103e82:	53                   	push   %ebx
80103e83:	8b 55 08             	mov    0x8(%ebp),%edx
80103e86:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e89:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103e8c:	eb 09                	jmp    80103e97 <strncmp+0x18>
    n--, p++, q++;
80103e8e:	83 e8 01             	sub    $0x1,%eax
80103e91:	83 c2 01             	add    $0x1,%edx
80103e94:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103e97:	85 c0                	test   %eax,%eax
80103e99:	74 0b                	je     80103ea6 <strncmp+0x27>
80103e9b:	0f b6 1a             	movzbl (%edx),%ebx
80103e9e:	84 db                	test   %bl,%bl
80103ea0:	74 04                	je     80103ea6 <strncmp+0x27>
80103ea2:	3a 19                	cmp    (%ecx),%bl
80103ea4:	74 e8                	je     80103e8e <strncmp+0xf>
  if(n == 0)
80103ea6:	85 c0                	test   %eax,%eax
80103ea8:	74 0b                	je     80103eb5 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103eaa:	0f b6 02             	movzbl (%edx),%eax
80103ead:	0f b6 11             	movzbl (%ecx),%edx
80103eb0:	29 d0                	sub    %edx,%eax
}
80103eb2:	5b                   	pop    %ebx
80103eb3:	5d                   	pop    %ebp
80103eb4:	c3                   	ret    
    return 0;
80103eb5:	b8 00 00 00 00       	mov    $0x0,%eax
80103eba:	eb f6                	jmp    80103eb2 <strncmp+0x33>

80103ebc <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103ebc:	55                   	push   %ebp
80103ebd:	89 e5                	mov    %esp,%ebp
80103ebf:	57                   	push   %edi
80103ec0:	56                   	push   %esi
80103ec1:	53                   	push   %ebx
80103ec2:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103ec5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103ec8:	8b 45 08             	mov    0x8(%ebp),%eax
80103ecb:	eb 04                	jmp    80103ed1 <strncpy+0x15>
80103ecd:	89 fb                	mov    %edi,%ebx
80103ecf:	89 f0                	mov    %esi,%eax
80103ed1:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103ed4:	85 c9                	test   %ecx,%ecx
80103ed6:	7e 1d                	jle    80103ef5 <strncpy+0x39>
80103ed8:	8d 7b 01             	lea    0x1(%ebx),%edi
80103edb:	8d 70 01             	lea    0x1(%eax),%esi
80103ede:	0f b6 1b             	movzbl (%ebx),%ebx
80103ee1:	88 18                	mov    %bl,(%eax)
80103ee3:	89 d1                	mov    %edx,%ecx
80103ee5:	84 db                	test   %bl,%bl
80103ee7:	75 e4                	jne    80103ecd <strncpy+0x11>
80103ee9:	89 f0                	mov    %esi,%eax
80103eeb:	eb 08                	jmp    80103ef5 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103eed:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103ef0:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103ef2:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103ef5:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103ef8:	85 d2                	test   %edx,%edx
80103efa:	7f f1                	jg     80103eed <strncpy+0x31>
  return os;
}
80103efc:	8b 45 08             	mov    0x8(%ebp),%eax
80103eff:	5b                   	pop    %ebx
80103f00:	5e                   	pop    %esi
80103f01:	5f                   	pop    %edi
80103f02:	5d                   	pop    %ebp
80103f03:	c3                   	ret    

80103f04 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103f04:	55                   	push   %ebp
80103f05:	89 e5                	mov    %esp,%ebp
80103f07:	57                   	push   %edi
80103f08:	56                   	push   %esi
80103f09:	53                   	push   %ebx
80103f0a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f10:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103f13:	85 d2                	test   %edx,%edx
80103f15:	7e 23                	jle    80103f3a <safestrcpy+0x36>
80103f17:	89 c1                	mov    %eax,%ecx
80103f19:	eb 04                	jmp    80103f1f <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103f1b:	89 fb                	mov    %edi,%ebx
80103f1d:	89 f1                	mov    %esi,%ecx
80103f1f:	83 ea 01             	sub    $0x1,%edx
80103f22:	85 d2                	test   %edx,%edx
80103f24:	7e 11                	jle    80103f37 <safestrcpy+0x33>
80103f26:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f29:	8d 71 01             	lea    0x1(%ecx),%esi
80103f2c:	0f b6 1b             	movzbl (%ebx),%ebx
80103f2f:	88 19                	mov    %bl,(%ecx)
80103f31:	84 db                	test   %bl,%bl
80103f33:	75 e6                	jne    80103f1b <safestrcpy+0x17>
80103f35:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103f37:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103f3a:	5b                   	pop    %ebx
80103f3b:	5e                   	pop    %esi
80103f3c:	5f                   	pop    %edi
80103f3d:	5d                   	pop    %ebp
80103f3e:	c3                   	ret    

80103f3f <strlen>:

int
strlen(const char *s)
{
80103f3f:	55                   	push   %ebp
80103f40:	89 e5                	mov    %esp,%ebp
80103f42:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103f45:	b8 00 00 00 00       	mov    $0x0,%eax
80103f4a:	eb 03                	jmp    80103f4f <strlen+0x10>
80103f4c:	83 c0 01             	add    $0x1,%eax
80103f4f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103f53:	75 f7                	jne    80103f4c <strlen+0xd>
    ;
  return n;
}
80103f55:	5d                   	pop    %ebp
80103f56:	c3                   	ret    

80103f57 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103f57:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103f5b:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103f5f:	55                   	push   %ebp
  pushl %ebx
80103f60:	53                   	push   %ebx
  pushl %esi
80103f61:	56                   	push   %esi
  pushl %edi
80103f62:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103f63:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103f65:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103f67:	5f                   	pop    %edi
  popl %esi
80103f68:	5e                   	pop    %esi
  popl %ebx
80103f69:	5b                   	pop    %ebx
  popl %ebp
80103f6a:	5d                   	pop    %ebp
  ret
80103f6b:	c3                   	ret    

80103f6c <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103f6c:	55                   	push   %ebp
80103f6d:	89 e5                	mov    %esp,%ebp
80103f6f:	53                   	push   %ebx
80103f70:	83 ec 04             	sub    $0x4,%esp
80103f73:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103f76:	e8 d7 f3 ff ff       	call   80103352 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103f7b:	8b 00                	mov    (%eax),%eax
80103f7d:	39 d8                	cmp    %ebx,%eax
80103f7f:	76 19                	jbe    80103f9a <fetchint+0x2e>
80103f81:	8d 53 04             	lea    0x4(%ebx),%edx
80103f84:	39 d0                	cmp    %edx,%eax
80103f86:	72 19                	jb     80103fa1 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103f88:	8b 13                	mov    (%ebx),%edx
80103f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103f8d:	89 10                	mov    %edx,(%eax)
  return 0;
80103f8f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f94:	83 c4 04             	add    $0x4,%esp
80103f97:	5b                   	pop    %ebx
80103f98:	5d                   	pop    %ebp
80103f99:	c3                   	ret    
    return -1;
80103f9a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f9f:	eb f3                	jmp    80103f94 <fetchint+0x28>
80103fa1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fa6:	eb ec                	jmp    80103f94 <fetchint+0x28>

80103fa8 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103fa8:	55                   	push   %ebp
80103fa9:	89 e5                	mov    %esp,%ebp
80103fab:	53                   	push   %ebx
80103fac:	83 ec 04             	sub    $0x4,%esp
80103faf:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103fb2:	e8 9b f3 ff ff       	call   80103352 <myproc>

  if(addr >= curproc->sz)
80103fb7:	39 18                	cmp    %ebx,(%eax)
80103fb9:	76 26                	jbe    80103fe1 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103fbb:	8b 55 0c             	mov    0xc(%ebp),%edx
80103fbe:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103fc0:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103fc2:	89 d8                	mov    %ebx,%eax
80103fc4:	39 d0                	cmp    %edx,%eax
80103fc6:	73 0e                	jae    80103fd6 <fetchstr+0x2e>
    if(*s == 0)
80103fc8:	80 38 00             	cmpb   $0x0,(%eax)
80103fcb:	74 05                	je     80103fd2 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80103fcd:	83 c0 01             	add    $0x1,%eax
80103fd0:	eb f2                	jmp    80103fc4 <fetchstr+0x1c>
      return s - *pp;
80103fd2:	29 d8                	sub    %ebx,%eax
80103fd4:	eb 05                	jmp    80103fdb <fetchstr+0x33>
  }
  return -1;
80103fd6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103fdb:	83 c4 04             	add    $0x4,%esp
80103fde:	5b                   	pop    %ebx
80103fdf:	5d                   	pop    %ebp
80103fe0:	c3                   	ret    
    return -1;
80103fe1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fe6:	eb f3                	jmp    80103fdb <fetchstr+0x33>

80103fe8 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103fe8:	55                   	push   %ebp
80103fe9:	89 e5                	mov    %esp,%ebp
80103feb:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103fee:	e8 5f f3 ff ff       	call   80103352 <myproc>
80103ff3:	8b 50 18             	mov    0x18(%eax),%edx
80103ff6:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff9:	c1 e0 02             	shl    $0x2,%eax
80103ffc:	03 42 44             	add    0x44(%edx),%eax
80103fff:	83 ec 08             	sub    $0x8,%esp
80104002:	ff 75 0c             	pushl  0xc(%ebp)
80104005:	83 c0 04             	add    $0x4,%eax
80104008:	50                   	push   %eax
80104009:	e8 5e ff ff ff       	call   80103f6c <fetchint>
}
8010400e:	c9                   	leave  
8010400f:	c3                   	ret    

80104010 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104010:	55                   	push   %ebp
80104011:	89 e5                	mov    %esp,%ebp
80104013:	56                   	push   %esi
80104014:	53                   	push   %ebx
80104015:	83 ec 10             	sub    $0x10,%esp
80104018:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010401b:	e8 32 f3 ff ff       	call   80103352 <myproc>
80104020:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104022:	83 ec 08             	sub    $0x8,%esp
80104025:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104028:	50                   	push   %eax
80104029:	ff 75 08             	pushl  0x8(%ebp)
8010402c:	e8 b7 ff ff ff       	call   80103fe8 <argint>
80104031:	83 c4 10             	add    $0x10,%esp
80104034:	85 c0                	test   %eax,%eax
80104036:	78 24                	js     8010405c <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104038:	85 db                	test   %ebx,%ebx
8010403a:	78 27                	js     80104063 <argptr+0x53>
8010403c:	8b 16                	mov    (%esi),%edx
8010403e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104041:	39 c2                	cmp    %eax,%edx
80104043:	76 25                	jbe    8010406a <argptr+0x5a>
80104045:	01 c3                	add    %eax,%ebx
80104047:	39 da                	cmp    %ebx,%edx
80104049:	72 26                	jb     80104071 <argptr+0x61>
    return -1;
  *pp = (char*)i;
8010404b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010404e:	89 02                	mov    %eax,(%edx)
  return 0;
80104050:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104055:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104058:	5b                   	pop    %ebx
80104059:	5e                   	pop    %esi
8010405a:	5d                   	pop    %ebp
8010405b:	c3                   	ret    
    return -1;
8010405c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104061:	eb f2                	jmp    80104055 <argptr+0x45>
    return -1;
80104063:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104068:	eb eb                	jmp    80104055 <argptr+0x45>
8010406a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010406f:	eb e4                	jmp    80104055 <argptr+0x45>
80104071:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104076:	eb dd                	jmp    80104055 <argptr+0x45>

80104078 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80104078:	55                   	push   %ebp
80104079:	89 e5                	mov    %esp,%ebp
8010407b:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
8010407e:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104081:	50                   	push   %eax
80104082:	ff 75 08             	pushl  0x8(%ebp)
80104085:	e8 5e ff ff ff       	call   80103fe8 <argint>
8010408a:	83 c4 10             	add    $0x10,%esp
8010408d:	85 c0                	test   %eax,%eax
8010408f:	78 13                	js     801040a4 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80104091:	83 ec 08             	sub    $0x8,%esp
80104094:	ff 75 0c             	pushl  0xc(%ebp)
80104097:	ff 75 f4             	pushl  -0xc(%ebp)
8010409a:	e8 09 ff ff ff       	call   80103fa8 <fetchstr>
8010409f:	83 c4 10             	add    $0x10,%esp
}
801040a2:	c9                   	leave  
801040a3:	c3                   	ret    
    return -1;
801040a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040a9:	eb f7                	jmp    801040a2 <argstr+0x2a>

801040ab <syscall>:
[SYS_dump_physmem] sys_dump_physmem,
};

void
syscall(void)
{
801040ab:	55                   	push   %ebp
801040ac:	89 e5                	mov    %esp,%ebp
801040ae:	53                   	push   %ebx
801040af:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801040b2:	e8 9b f2 ff ff       	call   80103352 <myproc>
801040b7:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
801040b9:	8b 40 18             	mov    0x18(%eax),%eax
801040bc:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801040bf:	8d 50 ff             	lea    -0x1(%eax),%edx
801040c2:	83 fa 15             	cmp    $0x15,%edx
801040c5:	77 18                	ja     801040df <syscall+0x34>
801040c7:	8b 14 85 20 6d 10 80 	mov    -0x7fef92e0(,%eax,4),%edx
801040ce:	85 d2                	test   %edx,%edx
801040d0:	74 0d                	je     801040df <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
801040d2:	ff d2                	call   *%edx
801040d4:	8b 53 18             	mov    0x18(%ebx),%edx
801040d7:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
801040da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801040dd:	c9                   	leave  
801040de:	c3                   	ret    
            curproc->pid, curproc->name, num);
801040df:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
801040e2:	50                   	push   %eax
801040e3:	52                   	push   %edx
801040e4:	ff 73 10             	pushl  0x10(%ebx)
801040e7:	68 f1 6c 10 80       	push   $0x80106cf1
801040ec:	e8 1a c5 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
801040f1:	8b 43 18             	mov    0x18(%ebx),%eax
801040f4:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
801040fb:	83 c4 10             	add    $0x10,%esp
}
801040fe:	eb da                	jmp    801040da <syscall+0x2f>

80104100 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104100:	55                   	push   %ebp
80104101:	89 e5                	mov    %esp,%ebp
80104103:	56                   	push   %esi
80104104:	53                   	push   %ebx
80104105:	83 ec 18             	sub    $0x18,%esp
80104108:	89 d6                	mov    %edx,%esi
8010410a:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010410c:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010410f:	52                   	push   %edx
80104110:	50                   	push   %eax
80104111:	e8 d2 fe ff ff       	call   80103fe8 <argint>
80104116:	83 c4 10             	add    $0x10,%esp
80104119:	85 c0                	test   %eax,%eax
8010411b:	78 2e                	js     8010414b <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010411d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104121:	77 2f                	ja     80104152 <argfd+0x52>
80104123:	e8 2a f2 ff ff       	call   80103352 <myproc>
80104128:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010412b:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
8010412f:	85 c0                	test   %eax,%eax
80104131:	74 26                	je     80104159 <argfd+0x59>
    return -1;
  if(pfd)
80104133:	85 f6                	test   %esi,%esi
80104135:	74 02                	je     80104139 <argfd+0x39>
    *pfd = fd;
80104137:	89 16                	mov    %edx,(%esi)
  if(pf)
80104139:	85 db                	test   %ebx,%ebx
8010413b:	74 23                	je     80104160 <argfd+0x60>
    *pf = f;
8010413d:	89 03                	mov    %eax,(%ebx)
  return 0;
8010413f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104144:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104147:	5b                   	pop    %ebx
80104148:	5e                   	pop    %esi
80104149:	5d                   	pop    %ebp
8010414a:	c3                   	ret    
    return -1;
8010414b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104150:	eb f2                	jmp    80104144 <argfd+0x44>
    return -1;
80104152:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104157:	eb eb                	jmp    80104144 <argfd+0x44>
80104159:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010415e:	eb e4                	jmp    80104144 <argfd+0x44>
  return 0;
80104160:	b8 00 00 00 00       	mov    $0x0,%eax
80104165:	eb dd                	jmp    80104144 <argfd+0x44>

80104167 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
80104167:	55                   	push   %ebp
80104168:	89 e5                	mov    %esp,%ebp
8010416a:	53                   	push   %ebx
8010416b:	83 ec 04             	sub    $0x4,%esp
8010416e:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104170:	e8 dd f1 ff ff       	call   80103352 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
80104175:	ba 00 00 00 00       	mov    $0x0,%edx
8010417a:	83 fa 0f             	cmp    $0xf,%edx
8010417d:	7f 18                	jg     80104197 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
8010417f:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
80104184:	74 05                	je     8010418b <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
80104186:	83 c2 01             	add    $0x1,%edx
80104189:	eb ef                	jmp    8010417a <fdalloc+0x13>
      curproc->ofile[fd] = f;
8010418b:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
8010418f:	89 d0                	mov    %edx,%eax
80104191:	83 c4 04             	add    $0x4,%esp
80104194:	5b                   	pop    %ebx
80104195:	5d                   	pop    %ebp
80104196:	c3                   	ret    
  return -1;
80104197:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010419c:	eb f1                	jmp    8010418f <fdalloc+0x28>

8010419e <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010419e:	55                   	push   %ebp
8010419f:	89 e5                	mov    %esp,%ebp
801041a1:	56                   	push   %esi
801041a2:	53                   	push   %ebx
801041a3:	83 ec 10             	sub    $0x10,%esp
801041a6:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801041a8:	b8 20 00 00 00       	mov    $0x20,%eax
801041ad:	89 c6                	mov    %eax,%esi
801041af:	39 43 58             	cmp    %eax,0x58(%ebx)
801041b2:	76 2e                	jbe    801041e2 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801041b4:	6a 10                	push   $0x10
801041b6:	50                   	push   %eax
801041b7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801041ba:	50                   	push   %eax
801041bb:	53                   	push   %ebx
801041bc:	e8 b2 d5 ff ff       	call   80101773 <readi>
801041c1:	83 c4 10             	add    $0x10,%esp
801041c4:	83 f8 10             	cmp    $0x10,%eax
801041c7:	75 0c                	jne    801041d5 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
801041c9:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
801041ce:	75 1e                	jne    801041ee <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801041d0:	8d 46 10             	lea    0x10(%esi),%eax
801041d3:	eb d8                	jmp    801041ad <isdirempty+0xf>
      panic("isdirempty: readi");
801041d5:	83 ec 0c             	sub    $0xc,%esp
801041d8:	68 7c 6d 10 80       	push   $0x80106d7c
801041dd:	e8 66 c1 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
801041e2:	b8 01 00 00 00       	mov    $0x1,%eax
}
801041e7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041ea:	5b                   	pop    %ebx
801041eb:	5e                   	pop    %esi
801041ec:	5d                   	pop    %ebp
801041ed:	c3                   	ret    
      return 0;
801041ee:	b8 00 00 00 00       	mov    $0x0,%eax
801041f3:	eb f2                	jmp    801041e7 <isdirempty+0x49>

801041f5 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801041f5:	55                   	push   %ebp
801041f6:	89 e5                	mov    %esp,%ebp
801041f8:	57                   	push   %edi
801041f9:	56                   	push   %esi
801041fa:	53                   	push   %ebx
801041fb:	83 ec 44             	sub    $0x44,%esp
801041fe:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104201:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104204:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104207:	8d 55 d6             	lea    -0x2a(%ebp),%edx
8010420a:	52                   	push   %edx
8010420b:	50                   	push   %eax
8010420c:	e8 e8 d9 ff ff       	call   80101bf9 <nameiparent>
80104211:	89 c6                	mov    %eax,%esi
80104213:	83 c4 10             	add    $0x10,%esp
80104216:	85 c0                	test   %eax,%eax
80104218:	0f 84 3a 01 00 00    	je     80104358 <create+0x163>
    return 0;
  ilock(dp);
8010421e:	83 ec 0c             	sub    $0xc,%esp
80104221:	50                   	push   %eax
80104222:	e8 5a d3 ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104227:	83 c4 0c             	add    $0xc,%esp
8010422a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010422d:	50                   	push   %eax
8010422e:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104231:	50                   	push   %eax
80104232:	56                   	push   %esi
80104233:	e8 78 d7 ff ff       	call   801019b0 <dirlookup>
80104238:	89 c3                	mov    %eax,%ebx
8010423a:	83 c4 10             	add    $0x10,%esp
8010423d:	85 c0                	test   %eax,%eax
8010423f:	74 3f                	je     80104280 <create+0x8b>
    iunlockput(dp);
80104241:	83 ec 0c             	sub    $0xc,%esp
80104244:	56                   	push   %esi
80104245:	e8 de d4 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
8010424a:	89 1c 24             	mov    %ebx,(%esp)
8010424d:	e8 2f d3 ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104252:	83 c4 10             	add    $0x10,%esp
80104255:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
8010425a:	75 11                	jne    8010426d <create+0x78>
8010425c:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104261:	75 0a                	jne    8010426d <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104263:	89 d8                	mov    %ebx,%eax
80104265:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104268:	5b                   	pop    %ebx
80104269:	5e                   	pop    %esi
8010426a:	5f                   	pop    %edi
8010426b:	5d                   	pop    %ebp
8010426c:	c3                   	ret    
    iunlockput(ip);
8010426d:	83 ec 0c             	sub    $0xc,%esp
80104270:	53                   	push   %ebx
80104271:	e8 b2 d4 ff ff       	call   80101728 <iunlockput>
    return 0;
80104276:	83 c4 10             	add    $0x10,%esp
80104279:	bb 00 00 00 00       	mov    $0x0,%ebx
8010427e:	eb e3                	jmp    80104263 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
80104280:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
80104284:	83 ec 08             	sub    $0x8,%esp
80104287:	50                   	push   %eax
80104288:	ff 36                	pushl  (%esi)
8010428a:	e8 ef d0 ff ff       	call   8010137e <ialloc>
8010428f:	89 c3                	mov    %eax,%ebx
80104291:	83 c4 10             	add    $0x10,%esp
80104294:	85 c0                	test   %eax,%eax
80104296:	74 55                	je     801042ed <create+0xf8>
  ilock(ip);
80104298:	83 ec 0c             	sub    $0xc,%esp
8010429b:	50                   	push   %eax
8010429c:	e8 e0 d2 ff ff       	call   80101581 <ilock>
  ip->major = major;
801042a1:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801042a5:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801042a9:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801042ad:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801042b3:	89 1c 24             	mov    %ebx,(%esp)
801042b6:	e8 65 d1 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801042bb:	83 c4 10             	add    $0x10,%esp
801042be:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
801042c3:	74 35                	je     801042fa <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
801042c5:	83 ec 04             	sub    $0x4,%esp
801042c8:	ff 73 04             	pushl  0x4(%ebx)
801042cb:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801042ce:	50                   	push   %eax
801042cf:	56                   	push   %esi
801042d0:	e8 5b d8 ff ff       	call   80101b30 <dirlink>
801042d5:	83 c4 10             	add    $0x10,%esp
801042d8:	85 c0                	test   %eax,%eax
801042da:	78 6f                	js     8010434b <create+0x156>
  iunlockput(dp);
801042dc:	83 ec 0c             	sub    $0xc,%esp
801042df:	56                   	push   %esi
801042e0:	e8 43 d4 ff ff       	call   80101728 <iunlockput>
  return ip;
801042e5:	83 c4 10             	add    $0x10,%esp
801042e8:	e9 76 ff ff ff       	jmp    80104263 <create+0x6e>
    panic("create: ialloc");
801042ed:	83 ec 0c             	sub    $0xc,%esp
801042f0:	68 8e 6d 10 80       	push   $0x80106d8e
801042f5:	e8 4e c0 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
801042fa:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801042fe:	83 c0 01             	add    $0x1,%eax
80104301:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104305:	83 ec 0c             	sub    $0xc,%esp
80104308:	56                   	push   %esi
80104309:	e8 12 d1 ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010430e:	83 c4 0c             	add    $0xc,%esp
80104311:	ff 73 04             	pushl  0x4(%ebx)
80104314:	68 9e 6d 10 80       	push   $0x80106d9e
80104319:	53                   	push   %ebx
8010431a:	e8 11 d8 ff ff       	call   80101b30 <dirlink>
8010431f:	83 c4 10             	add    $0x10,%esp
80104322:	85 c0                	test   %eax,%eax
80104324:	78 18                	js     8010433e <create+0x149>
80104326:	83 ec 04             	sub    $0x4,%esp
80104329:	ff 76 04             	pushl  0x4(%esi)
8010432c:	68 9d 6d 10 80       	push   $0x80106d9d
80104331:	53                   	push   %ebx
80104332:	e8 f9 d7 ff ff       	call   80101b30 <dirlink>
80104337:	83 c4 10             	add    $0x10,%esp
8010433a:	85 c0                	test   %eax,%eax
8010433c:	79 87                	jns    801042c5 <create+0xd0>
      panic("create dots");
8010433e:	83 ec 0c             	sub    $0xc,%esp
80104341:	68 a0 6d 10 80       	push   $0x80106da0
80104346:	e8 fd bf ff ff       	call   80100348 <panic>
    panic("create: dirlink");
8010434b:	83 ec 0c             	sub    $0xc,%esp
8010434e:	68 ac 6d 10 80       	push   $0x80106dac
80104353:	e8 f0 bf ff ff       	call   80100348 <panic>
    return 0;
80104358:	89 c3                	mov    %eax,%ebx
8010435a:	e9 04 ff ff ff       	jmp    80104263 <create+0x6e>

8010435f <sys_dup>:
{
8010435f:	55                   	push   %ebp
80104360:	89 e5                	mov    %esp,%ebp
80104362:	53                   	push   %ebx
80104363:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
80104366:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104369:	ba 00 00 00 00       	mov    $0x0,%edx
8010436e:	b8 00 00 00 00       	mov    $0x0,%eax
80104373:	e8 88 fd ff ff       	call   80104100 <argfd>
80104378:	85 c0                	test   %eax,%eax
8010437a:	78 23                	js     8010439f <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
8010437c:	8b 45 f4             	mov    -0xc(%ebp),%eax
8010437f:	e8 e3 fd ff ff       	call   80104167 <fdalloc>
80104384:	89 c3                	mov    %eax,%ebx
80104386:	85 c0                	test   %eax,%eax
80104388:	78 1c                	js     801043a6 <sys_dup+0x47>
  filedup(f);
8010438a:	83 ec 0c             	sub    $0xc,%esp
8010438d:	ff 75 f4             	pushl  -0xc(%ebp)
80104390:	e8 f9 c8 ff ff       	call   80100c8e <filedup>
  return fd;
80104395:	83 c4 10             	add    $0x10,%esp
}
80104398:	89 d8                	mov    %ebx,%eax
8010439a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010439d:	c9                   	leave  
8010439e:	c3                   	ret    
    return -1;
8010439f:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801043a4:	eb f2                	jmp    80104398 <sys_dup+0x39>
    return -1;
801043a6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801043ab:	eb eb                	jmp    80104398 <sys_dup+0x39>

801043ad <sys_read>:
{
801043ad:	55                   	push   %ebp
801043ae:	89 e5                	mov    %esp,%ebp
801043b0:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801043b3:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043b6:	ba 00 00 00 00       	mov    $0x0,%edx
801043bb:	b8 00 00 00 00       	mov    $0x0,%eax
801043c0:	e8 3b fd ff ff       	call   80104100 <argfd>
801043c5:	85 c0                	test   %eax,%eax
801043c7:	78 43                	js     8010440c <sys_read+0x5f>
801043c9:	83 ec 08             	sub    $0x8,%esp
801043cc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801043cf:	50                   	push   %eax
801043d0:	6a 02                	push   $0x2
801043d2:	e8 11 fc ff ff       	call   80103fe8 <argint>
801043d7:	83 c4 10             	add    $0x10,%esp
801043da:	85 c0                	test   %eax,%eax
801043dc:	78 35                	js     80104413 <sys_read+0x66>
801043de:	83 ec 04             	sub    $0x4,%esp
801043e1:	ff 75 f0             	pushl  -0x10(%ebp)
801043e4:	8d 45 ec             	lea    -0x14(%ebp),%eax
801043e7:	50                   	push   %eax
801043e8:	6a 01                	push   $0x1
801043ea:	e8 21 fc ff ff       	call   80104010 <argptr>
801043ef:	83 c4 10             	add    $0x10,%esp
801043f2:	85 c0                	test   %eax,%eax
801043f4:	78 24                	js     8010441a <sys_read+0x6d>
  return fileread(f, p, n);
801043f6:	83 ec 04             	sub    $0x4,%esp
801043f9:	ff 75 f0             	pushl  -0x10(%ebp)
801043fc:	ff 75 ec             	pushl  -0x14(%ebp)
801043ff:	ff 75 f4             	pushl  -0xc(%ebp)
80104402:	e8 d0 c9 ff ff       	call   80100dd7 <fileread>
80104407:	83 c4 10             	add    $0x10,%esp
}
8010440a:	c9                   	leave  
8010440b:	c3                   	ret    
    return -1;
8010440c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104411:	eb f7                	jmp    8010440a <sys_read+0x5d>
80104413:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104418:	eb f0                	jmp    8010440a <sys_read+0x5d>
8010441a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010441f:	eb e9                	jmp    8010440a <sys_read+0x5d>

80104421 <sys_write>:
{
80104421:	55                   	push   %ebp
80104422:	89 e5                	mov    %esp,%ebp
80104424:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104427:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010442a:	ba 00 00 00 00       	mov    $0x0,%edx
8010442f:	b8 00 00 00 00       	mov    $0x0,%eax
80104434:	e8 c7 fc ff ff       	call   80104100 <argfd>
80104439:	85 c0                	test   %eax,%eax
8010443b:	78 43                	js     80104480 <sys_write+0x5f>
8010443d:	83 ec 08             	sub    $0x8,%esp
80104440:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104443:	50                   	push   %eax
80104444:	6a 02                	push   $0x2
80104446:	e8 9d fb ff ff       	call   80103fe8 <argint>
8010444b:	83 c4 10             	add    $0x10,%esp
8010444e:	85 c0                	test   %eax,%eax
80104450:	78 35                	js     80104487 <sys_write+0x66>
80104452:	83 ec 04             	sub    $0x4,%esp
80104455:	ff 75 f0             	pushl  -0x10(%ebp)
80104458:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010445b:	50                   	push   %eax
8010445c:	6a 01                	push   $0x1
8010445e:	e8 ad fb ff ff       	call   80104010 <argptr>
80104463:	83 c4 10             	add    $0x10,%esp
80104466:	85 c0                	test   %eax,%eax
80104468:	78 24                	js     8010448e <sys_write+0x6d>
  return filewrite(f, p, n);
8010446a:	83 ec 04             	sub    $0x4,%esp
8010446d:	ff 75 f0             	pushl  -0x10(%ebp)
80104470:	ff 75 ec             	pushl  -0x14(%ebp)
80104473:	ff 75 f4             	pushl  -0xc(%ebp)
80104476:	e8 e1 c9 ff ff       	call   80100e5c <filewrite>
8010447b:	83 c4 10             	add    $0x10,%esp
}
8010447e:	c9                   	leave  
8010447f:	c3                   	ret    
    return -1;
80104480:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104485:	eb f7                	jmp    8010447e <sys_write+0x5d>
80104487:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010448c:	eb f0                	jmp    8010447e <sys_write+0x5d>
8010448e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104493:	eb e9                	jmp    8010447e <sys_write+0x5d>

80104495 <sys_close>:
{
80104495:	55                   	push   %ebp
80104496:	89 e5                	mov    %esp,%ebp
80104498:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
8010449b:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010449e:	8d 55 f4             	lea    -0xc(%ebp),%edx
801044a1:	b8 00 00 00 00       	mov    $0x0,%eax
801044a6:	e8 55 fc ff ff       	call   80104100 <argfd>
801044ab:	85 c0                	test   %eax,%eax
801044ad:	78 25                	js     801044d4 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801044af:	e8 9e ee ff ff       	call   80103352 <myproc>
801044b4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044b7:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801044be:	00 
  fileclose(f);
801044bf:	83 ec 0c             	sub    $0xc,%esp
801044c2:	ff 75 f0             	pushl  -0x10(%ebp)
801044c5:	e8 09 c8 ff ff       	call   80100cd3 <fileclose>
  return 0;
801044ca:	83 c4 10             	add    $0x10,%esp
801044cd:	b8 00 00 00 00       	mov    $0x0,%eax
}
801044d2:	c9                   	leave  
801044d3:	c3                   	ret    
    return -1;
801044d4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044d9:	eb f7                	jmp    801044d2 <sys_close+0x3d>

801044db <sys_fstat>:
{
801044db:	55                   	push   %ebp
801044dc:	89 e5                	mov    %esp,%ebp
801044de:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801044e1:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044e4:	ba 00 00 00 00       	mov    $0x0,%edx
801044e9:	b8 00 00 00 00       	mov    $0x0,%eax
801044ee:	e8 0d fc ff ff       	call   80104100 <argfd>
801044f3:	85 c0                	test   %eax,%eax
801044f5:	78 2a                	js     80104521 <sys_fstat+0x46>
801044f7:	83 ec 04             	sub    $0x4,%esp
801044fa:	6a 14                	push   $0x14
801044fc:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044ff:	50                   	push   %eax
80104500:	6a 01                	push   $0x1
80104502:	e8 09 fb ff ff       	call   80104010 <argptr>
80104507:	83 c4 10             	add    $0x10,%esp
8010450a:	85 c0                	test   %eax,%eax
8010450c:	78 1a                	js     80104528 <sys_fstat+0x4d>
  return filestat(f, st);
8010450e:	83 ec 08             	sub    $0x8,%esp
80104511:	ff 75 f0             	pushl  -0x10(%ebp)
80104514:	ff 75 f4             	pushl  -0xc(%ebp)
80104517:	e8 74 c8 ff ff       	call   80100d90 <filestat>
8010451c:	83 c4 10             	add    $0x10,%esp
}
8010451f:	c9                   	leave  
80104520:	c3                   	ret    
    return -1;
80104521:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104526:	eb f7                	jmp    8010451f <sys_fstat+0x44>
80104528:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010452d:	eb f0                	jmp    8010451f <sys_fstat+0x44>

8010452f <sys_link>:
{
8010452f:	55                   	push   %ebp
80104530:	89 e5                	mov    %esp,%ebp
80104532:	56                   	push   %esi
80104533:	53                   	push   %ebx
80104534:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104537:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010453a:	50                   	push   %eax
8010453b:	6a 00                	push   $0x0
8010453d:	e8 36 fb ff ff       	call   80104078 <argstr>
80104542:	83 c4 10             	add    $0x10,%esp
80104545:	85 c0                	test   %eax,%eax
80104547:	0f 88 32 01 00 00    	js     8010467f <sys_link+0x150>
8010454d:	83 ec 08             	sub    $0x8,%esp
80104550:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104553:	50                   	push   %eax
80104554:	6a 01                	push   $0x1
80104556:	e8 1d fb ff ff       	call   80104078 <argstr>
8010455b:	83 c4 10             	add    $0x10,%esp
8010455e:	85 c0                	test   %eax,%eax
80104560:	0f 88 20 01 00 00    	js     80104686 <sys_link+0x157>
  begin_op();
80104566:	e8 9f e3 ff ff       	call   8010290a <begin_op>
  if((ip = namei(old)) == 0){
8010456b:	83 ec 0c             	sub    $0xc,%esp
8010456e:	ff 75 e0             	pushl  -0x20(%ebp)
80104571:	e8 6b d6 ff ff       	call   80101be1 <namei>
80104576:	89 c3                	mov    %eax,%ebx
80104578:	83 c4 10             	add    $0x10,%esp
8010457b:	85 c0                	test   %eax,%eax
8010457d:	0f 84 99 00 00 00    	je     8010461c <sys_link+0xed>
  ilock(ip);
80104583:	83 ec 0c             	sub    $0xc,%esp
80104586:	50                   	push   %eax
80104587:	e8 f5 cf ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
8010458c:	83 c4 10             	add    $0x10,%esp
8010458f:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104594:	0f 84 8e 00 00 00    	je     80104628 <sys_link+0xf9>
  ip->nlink++;
8010459a:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010459e:	83 c0 01             	add    $0x1,%eax
801045a1:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045a5:	83 ec 0c             	sub    $0xc,%esp
801045a8:	53                   	push   %ebx
801045a9:	e8 72 ce ff ff       	call   80101420 <iupdate>
  iunlock(ip);
801045ae:	89 1c 24             	mov    %ebx,(%esp)
801045b1:	e8 8d d0 ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801045b6:	83 c4 08             	add    $0x8,%esp
801045b9:	8d 45 ea             	lea    -0x16(%ebp),%eax
801045bc:	50                   	push   %eax
801045bd:	ff 75 e4             	pushl  -0x1c(%ebp)
801045c0:	e8 34 d6 ff ff       	call   80101bf9 <nameiparent>
801045c5:	89 c6                	mov    %eax,%esi
801045c7:	83 c4 10             	add    $0x10,%esp
801045ca:	85 c0                	test   %eax,%eax
801045cc:	74 7e                	je     8010464c <sys_link+0x11d>
  ilock(dp);
801045ce:	83 ec 0c             	sub    $0xc,%esp
801045d1:	50                   	push   %eax
801045d2:	e8 aa cf ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801045d7:	83 c4 10             	add    $0x10,%esp
801045da:	8b 03                	mov    (%ebx),%eax
801045dc:	39 06                	cmp    %eax,(%esi)
801045de:	75 60                	jne    80104640 <sys_link+0x111>
801045e0:	83 ec 04             	sub    $0x4,%esp
801045e3:	ff 73 04             	pushl  0x4(%ebx)
801045e6:	8d 45 ea             	lea    -0x16(%ebp),%eax
801045e9:	50                   	push   %eax
801045ea:	56                   	push   %esi
801045eb:	e8 40 d5 ff ff       	call   80101b30 <dirlink>
801045f0:	83 c4 10             	add    $0x10,%esp
801045f3:	85 c0                	test   %eax,%eax
801045f5:	78 49                	js     80104640 <sys_link+0x111>
  iunlockput(dp);
801045f7:	83 ec 0c             	sub    $0xc,%esp
801045fa:	56                   	push   %esi
801045fb:	e8 28 d1 ff ff       	call   80101728 <iunlockput>
  iput(ip);
80104600:	89 1c 24             	mov    %ebx,(%esp)
80104603:	e8 80 d0 ff ff       	call   80101688 <iput>
  end_op();
80104608:	e8 77 e3 ff ff       	call   80102984 <end_op>
  return 0;
8010460d:	83 c4 10             	add    $0x10,%esp
80104610:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104615:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104618:	5b                   	pop    %ebx
80104619:	5e                   	pop    %esi
8010461a:	5d                   	pop    %ebp
8010461b:	c3                   	ret    
    end_op();
8010461c:	e8 63 e3 ff ff       	call   80102984 <end_op>
    return -1;
80104621:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104626:	eb ed                	jmp    80104615 <sys_link+0xe6>
    iunlockput(ip);
80104628:	83 ec 0c             	sub    $0xc,%esp
8010462b:	53                   	push   %ebx
8010462c:	e8 f7 d0 ff ff       	call   80101728 <iunlockput>
    end_op();
80104631:	e8 4e e3 ff ff       	call   80102984 <end_op>
    return -1;
80104636:	83 c4 10             	add    $0x10,%esp
80104639:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010463e:	eb d5                	jmp    80104615 <sys_link+0xe6>
    iunlockput(dp);
80104640:	83 ec 0c             	sub    $0xc,%esp
80104643:	56                   	push   %esi
80104644:	e8 df d0 ff ff       	call   80101728 <iunlockput>
    goto bad;
80104649:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
8010464c:	83 ec 0c             	sub    $0xc,%esp
8010464f:	53                   	push   %ebx
80104650:	e8 2c cf ff ff       	call   80101581 <ilock>
  ip->nlink--;
80104655:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104659:	83 e8 01             	sub    $0x1,%eax
8010465c:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104660:	89 1c 24             	mov    %ebx,(%esp)
80104663:	e8 b8 cd ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
80104668:	89 1c 24             	mov    %ebx,(%esp)
8010466b:	e8 b8 d0 ff ff       	call   80101728 <iunlockput>
  end_op();
80104670:	e8 0f e3 ff ff       	call   80102984 <end_op>
  return -1;
80104675:	83 c4 10             	add    $0x10,%esp
80104678:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010467d:	eb 96                	jmp    80104615 <sys_link+0xe6>
    return -1;
8010467f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104684:	eb 8f                	jmp    80104615 <sys_link+0xe6>
80104686:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010468b:	eb 88                	jmp    80104615 <sys_link+0xe6>

8010468d <sys_unlink>:
{
8010468d:	55                   	push   %ebp
8010468e:	89 e5                	mov    %esp,%ebp
80104690:	57                   	push   %edi
80104691:	56                   	push   %esi
80104692:	53                   	push   %ebx
80104693:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104696:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104699:	50                   	push   %eax
8010469a:	6a 00                	push   $0x0
8010469c:	e8 d7 f9 ff ff       	call   80104078 <argstr>
801046a1:	83 c4 10             	add    $0x10,%esp
801046a4:	85 c0                	test   %eax,%eax
801046a6:	0f 88 83 01 00 00    	js     8010482f <sys_unlink+0x1a2>
  begin_op();
801046ac:	e8 59 e2 ff ff       	call   8010290a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801046b1:	83 ec 08             	sub    $0x8,%esp
801046b4:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046b7:	50                   	push   %eax
801046b8:	ff 75 c4             	pushl  -0x3c(%ebp)
801046bb:	e8 39 d5 ff ff       	call   80101bf9 <nameiparent>
801046c0:	89 c6                	mov    %eax,%esi
801046c2:	83 c4 10             	add    $0x10,%esp
801046c5:	85 c0                	test   %eax,%eax
801046c7:	0f 84 ed 00 00 00    	je     801047ba <sys_unlink+0x12d>
  ilock(dp);
801046cd:	83 ec 0c             	sub    $0xc,%esp
801046d0:	50                   	push   %eax
801046d1:	e8 ab ce ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801046d6:	83 c4 08             	add    $0x8,%esp
801046d9:	68 9e 6d 10 80       	push   $0x80106d9e
801046de:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046e1:	50                   	push   %eax
801046e2:	e8 b4 d2 ff ff       	call   8010199b <namecmp>
801046e7:	83 c4 10             	add    $0x10,%esp
801046ea:	85 c0                	test   %eax,%eax
801046ec:	0f 84 fc 00 00 00    	je     801047ee <sys_unlink+0x161>
801046f2:	83 ec 08             	sub    $0x8,%esp
801046f5:	68 9d 6d 10 80       	push   $0x80106d9d
801046fa:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046fd:	50                   	push   %eax
801046fe:	e8 98 d2 ff ff       	call   8010199b <namecmp>
80104703:	83 c4 10             	add    $0x10,%esp
80104706:	85 c0                	test   %eax,%eax
80104708:	0f 84 e0 00 00 00    	je     801047ee <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010470e:	83 ec 04             	sub    $0x4,%esp
80104711:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104714:	50                   	push   %eax
80104715:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104718:	50                   	push   %eax
80104719:	56                   	push   %esi
8010471a:	e8 91 d2 ff ff       	call   801019b0 <dirlookup>
8010471f:	89 c3                	mov    %eax,%ebx
80104721:	83 c4 10             	add    $0x10,%esp
80104724:	85 c0                	test   %eax,%eax
80104726:	0f 84 c2 00 00 00    	je     801047ee <sys_unlink+0x161>
  ilock(ip);
8010472c:	83 ec 0c             	sub    $0xc,%esp
8010472f:	50                   	push   %eax
80104730:	e8 4c ce ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
80104735:	83 c4 10             	add    $0x10,%esp
80104738:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010473d:	0f 8e 83 00 00 00    	jle    801047c6 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104743:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104748:	0f 84 85 00 00 00    	je     801047d3 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
8010474e:	83 ec 04             	sub    $0x4,%esp
80104751:	6a 10                	push   $0x10
80104753:	6a 00                	push   $0x0
80104755:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104758:	57                   	push   %edi
80104759:	e8 3f f6 ff ff       	call   80103d9d <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010475e:	6a 10                	push   $0x10
80104760:	ff 75 c0             	pushl  -0x40(%ebp)
80104763:	57                   	push   %edi
80104764:	56                   	push   %esi
80104765:	e8 06 d1 ff ff       	call   80101870 <writei>
8010476a:	83 c4 20             	add    $0x20,%esp
8010476d:	83 f8 10             	cmp    $0x10,%eax
80104770:	0f 85 90 00 00 00    	jne    80104806 <sys_unlink+0x179>
  if(ip->type == T_DIR){
80104776:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010477b:	0f 84 92 00 00 00    	je     80104813 <sys_unlink+0x186>
  iunlockput(dp);
80104781:	83 ec 0c             	sub    $0xc,%esp
80104784:	56                   	push   %esi
80104785:	e8 9e cf ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
8010478a:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010478e:	83 e8 01             	sub    $0x1,%eax
80104791:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104795:	89 1c 24             	mov    %ebx,(%esp)
80104798:	e8 83 cc ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
8010479d:	89 1c 24             	mov    %ebx,(%esp)
801047a0:	e8 83 cf ff ff       	call   80101728 <iunlockput>
  end_op();
801047a5:	e8 da e1 ff ff       	call   80102984 <end_op>
  return 0;
801047aa:	83 c4 10             	add    $0x10,%esp
801047ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047b2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801047b5:	5b                   	pop    %ebx
801047b6:	5e                   	pop    %esi
801047b7:	5f                   	pop    %edi
801047b8:	5d                   	pop    %ebp
801047b9:	c3                   	ret    
    end_op();
801047ba:	e8 c5 e1 ff ff       	call   80102984 <end_op>
    return -1;
801047bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047c4:	eb ec                	jmp    801047b2 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
801047c6:	83 ec 0c             	sub    $0xc,%esp
801047c9:	68 bc 6d 10 80       	push   $0x80106dbc
801047ce:	e8 75 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801047d3:	89 d8                	mov    %ebx,%eax
801047d5:	e8 c4 f9 ff ff       	call   8010419e <isdirempty>
801047da:	85 c0                	test   %eax,%eax
801047dc:	0f 85 6c ff ff ff    	jne    8010474e <sys_unlink+0xc1>
    iunlockput(ip);
801047e2:	83 ec 0c             	sub    $0xc,%esp
801047e5:	53                   	push   %ebx
801047e6:	e8 3d cf ff ff       	call   80101728 <iunlockput>
    goto bad;
801047eb:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
801047ee:	83 ec 0c             	sub    $0xc,%esp
801047f1:	56                   	push   %esi
801047f2:	e8 31 cf ff ff       	call   80101728 <iunlockput>
  end_op();
801047f7:	e8 88 e1 ff ff       	call   80102984 <end_op>
  return -1;
801047fc:	83 c4 10             	add    $0x10,%esp
801047ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104804:	eb ac                	jmp    801047b2 <sys_unlink+0x125>
    panic("unlink: writei");
80104806:	83 ec 0c             	sub    $0xc,%esp
80104809:	68 ce 6d 10 80       	push   $0x80106dce
8010480e:	e8 35 bb ff ff       	call   80100348 <panic>
    dp->nlink--;
80104813:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104817:	83 e8 01             	sub    $0x1,%eax
8010481a:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010481e:	83 ec 0c             	sub    $0xc,%esp
80104821:	56                   	push   %esi
80104822:	e8 f9 cb ff ff       	call   80101420 <iupdate>
80104827:	83 c4 10             	add    $0x10,%esp
8010482a:	e9 52 ff ff ff       	jmp    80104781 <sys_unlink+0xf4>
    return -1;
8010482f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104834:	e9 79 ff ff ff       	jmp    801047b2 <sys_unlink+0x125>

80104839 <sys_open>:

int
sys_open(void)
{
80104839:	55                   	push   %ebp
8010483a:	89 e5                	mov    %esp,%ebp
8010483c:	57                   	push   %edi
8010483d:	56                   	push   %esi
8010483e:	53                   	push   %ebx
8010483f:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104842:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104845:	50                   	push   %eax
80104846:	6a 00                	push   $0x0
80104848:	e8 2b f8 ff ff       	call   80104078 <argstr>
8010484d:	83 c4 10             	add    $0x10,%esp
80104850:	85 c0                	test   %eax,%eax
80104852:	0f 88 30 01 00 00    	js     80104988 <sys_open+0x14f>
80104858:	83 ec 08             	sub    $0x8,%esp
8010485b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010485e:	50                   	push   %eax
8010485f:	6a 01                	push   $0x1
80104861:	e8 82 f7 ff ff       	call   80103fe8 <argint>
80104866:	83 c4 10             	add    $0x10,%esp
80104869:	85 c0                	test   %eax,%eax
8010486b:	0f 88 21 01 00 00    	js     80104992 <sys_open+0x159>
    return -1;

  begin_op();
80104871:	e8 94 e0 ff ff       	call   8010290a <begin_op>

  if(omode & O_CREATE){
80104876:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
8010487a:	0f 84 84 00 00 00    	je     80104904 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
80104880:	83 ec 0c             	sub    $0xc,%esp
80104883:	6a 00                	push   $0x0
80104885:	b9 00 00 00 00       	mov    $0x0,%ecx
8010488a:	ba 02 00 00 00       	mov    $0x2,%edx
8010488f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104892:	e8 5e f9 ff ff       	call   801041f5 <create>
80104897:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104899:	83 c4 10             	add    $0x10,%esp
8010489c:	85 c0                	test   %eax,%eax
8010489e:	74 58                	je     801048f8 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801048a0:	e8 88 c3 ff ff       	call   80100c2d <filealloc>
801048a5:	89 c3                	mov    %eax,%ebx
801048a7:	85 c0                	test   %eax,%eax
801048a9:	0f 84 ae 00 00 00    	je     8010495d <sys_open+0x124>
801048af:	e8 b3 f8 ff ff       	call   80104167 <fdalloc>
801048b4:	89 c7                	mov    %eax,%edi
801048b6:	85 c0                	test   %eax,%eax
801048b8:	0f 88 9f 00 00 00    	js     8010495d <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801048be:	83 ec 0c             	sub    $0xc,%esp
801048c1:	56                   	push   %esi
801048c2:	e8 7c cd ff ff       	call   80101643 <iunlock>
  end_op();
801048c7:	e8 b8 e0 ff ff       	call   80102984 <end_op>

  f->type = FD_INODE;
801048cc:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801048d2:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801048d5:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
801048dc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801048df:	83 c4 10             	add    $0x10,%esp
801048e2:	a8 01                	test   $0x1,%al
801048e4:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801048e8:	a8 03                	test   $0x3,%al
801048ea:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
801048ee:	89 f8                	mov    %edi,%eax
801048f0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048f3:	5b                   	pop    %ebx
801048f4:	5e                   	pop    %esi
801048f5:	5f                   	pop    %edi
801048f6:	5d                   	pop    %ebp
801048f7:	c3                   	ret    
      end_op();
801048f8:	e8 87 e0 ff ff       	call   80102984 <end_op>
      return -1;
801048fd:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104902:	eb ea                	jmp    801048ee <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104904:	83 ec 0c             	sub    $0xc,%esp
80104907:	ff 75 e4             	pushl  -0x1c(%ebp)
8010490a:	e8 d2 d2 ff ff       	call   80101be1 <namei>
8010490f:	89 c6                	mov    %eax,%esi
80104911:	83 c4 10             	add    $0x10,%esp
80104914:	85 c0                	test   %eax,%eax
80104916:	74 39                	je     80104951 <sys_open+0x118>
    ilock(ip);
80104918:	83 ec 0c             	sub    $0xc,%esp
8010491b:	50                   	push   %eax
8010491c:	e8 60 cc ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104921:	83 c4 10             	add    $0x10,%esp
80104924:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104929:	0f 85 71 ff ff ff    	jne    801048a0 <sys_open+0x67>
8010492f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104933:	0f 84 67 ff ff ff    	je     801048a0 <sys_open+0x67>
      iunlockput(ip);
80104939:	83 ec 0c             	sub    $0xc,%esp
8010493c:	56                   	push   %esi
8010493d:	e8 e6 cd ff ff       	call   80101728 <iunlockput>
      end_op();
80104942:	e8 3d e0 ff ff       	call   80102984 <end_op>
      return -1;
80104947:	83 c4 10             	add    $0x10,%esp
8010494a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010494f:	eb 9d                	jmp    801048ee <sys_open+0xb5>
      end_op();
80104951:	e8 2e e0 ff ff       	call   80102984 <end_op>
      return -1;
80104956:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010495b:	eb 91                	jmp    801048ee <sys_open+0xb5>
    if(f)
8010495d:	85 db                	test   %ebx,%ebx
8010495f:	74 0c                	je     8010496d <sys_open+0x134>
      fileclose(f);
80104961:	83 ec 0c             	sub    $0xc,%esp
80104964:	53                   	push   %ebx
80104965:	e8 69 c3 ff ff       	call   80100cd3 <fileclose>
8010496a:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
8010496d:	83 ec 0c             	sub    $0xc,%esp
80104970:	56                   	push   %esi
80104971:	e8 b2 cd ff ff       	call   80101728 <iunlockput>
    end_op();
80104976:	e8 09 e0 ff ff       	call   80102984 <end_op>
    return -1;
8010497b:	83 c4 10             	add    $0x10,%esp
8010497e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104983:	e9 66 ff ff ff       	jmp    801048ee <sys_open+0xb5>
    return -1;
80104988:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010498d:	e9 5c ff ff ff       	jmp    801048ee <sys_open+0xb5>
80104992:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104997:	e9 52 ff ff ff       	jmp    801048ee <sys_open+0xb5>

8010499c <sys_mkdir>:

int
sys_mkdir(void)
{
8010499c:	55                   	push   %ebp
8010499d:	89 e5                	mov    %esp,%ebp
8010499f:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801049a2:	e8 63 df ff ff       	call   8010290a <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801049a7:	83 ec 08             	sub    $0x8,%esp
801049aa:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049ad:	50                   	push   %eax
801049ae:	6a 00                	push   $0x0
801049b0:	e8 c3 f6 ff ff       	call   80104078 <argstr>
801049b5:	83 c4 10             	add    $0x10,%esp
801049b8:	85 c0                	test   %eax,%eax
801049ba:	78 36                	js     801049f2 <sys_mkdir+0x56>
801049bc:	83 ec 0c             	sub    $0xc,%esp
801049bf:	6a 00                	push   $0x0
801049c1:	b9 00 00 00 00       	mov    $0x0,%ecx
801049c6:	ba 01 00 00 00       	mov    $0x1,%edx
801049cb:	8b 45 f4             	mov    -0xc(%ebp),%eax
801049ce:	e8 22 f8 ff ff       	call   801041f5 <create>
801049d3:	83 c4 10             	add    $0x10,%esp
801049d6:	85 c0                	test   %eax,%eax
801049d8:	74 18                	je     801049f2 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
801049da:	83 ec 0c             	sub    $0xc,%esp
801049dd:	50                   	push   %eax
801049de:	e8 45 cd ff ff       	call   80101728 <iunlockput>
  end_op();
801049e3:	e8 9c df ff ff       	call   80102984 <end_op>
  return 0;
801049e8:	83 c4 10             	add    $0x10,%esp
801049eb:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049f0:	c9                   	leave  
801049f1:	c3                   	ret    
    end_op();
801049f2:	e8 8d df ff ff       	call   80102984 <end_op>
    return -1;
801049f7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049fc:	eb f2                	jmp    801049f0 <sys_mkdir+0x54>

801049fe <sys_mknod>:

int
sys_mknod(void)
{
801049fe:	55                   	push   %ebp
801049ff:	89 e5                	mov    %esp,%ebp
80104a01:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104a04:	e8 01 df ff ff       	call   8010290a <begin_op>
  if((argstr(0, &path)) < 0 ||
80104a09:	83 ec 08             	sub    $0x8,%esp
80104a0c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a0f:	50                   	push   %eax
80104a10:	6a 00                	push   $0x0
80104a12:	e8 61 f6 ff ff       	call   80104078 <argstr>
80104a17:	83 c4 10             	add    $0x10,%esp
80104a1a:	85 c0                	test   %eax,%eax
80104a1c:	78 62                	js     80104a80 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104a1e:	83 ec 08             	sub    $0x8,%esp
80104a21:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a24:	50                   	push   %eax
80104a25:	6a 01                	push   $0x1
80104a27:	e8 bc f5 ff ff       	call   80103fe8 <argint>
  if((argstr(0, &path)) < 0 ||
80104a2c:	83 c4 10             	add    $0x10,%esp
80104a2f:	85 c0                	test   %eax,%eax
80104a31:	78 4d                	js     80104a80 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104a33:	83 ec 08             	sub    $0x8,%esp
80104a36:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a39:	50                   	push   %eax
80104a3a:	6a 02                	push   $0x2
80104a3c:	e8 a7 f5 ff ff       	call   80103fe8 <argint>
     argint(1, &major) < 0 ||
80104a41:	83 c4 10             	add    $0x10,%esp
80104a44:	85 c0                	test   %eax,%eax
80104a46:	78 38                	js     80104a80 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104a48:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104a4c:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104a50:	83 ec 0c             	sub    $0xc,%esp
80104a53:	50                   	push   %eax
80104a54:	ba 03 00 00 00       	mov    $0x3,%edx
80104a59:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a5c:	e8 94 f7 ff ff       	call   801041f5 <create>
80104a61:	83 c4 10             	add    $0x10,%esp
80104a64:	85 c0                	test   %eax,%eax
80104a66:	74 18                	je     80104a80 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a68:	83 ec 0c             	sub    $0xc,%esp
80104a6b:	50                   	push   %eax
80104a6c:	e8 b7 cc ff ff       	call   80101728 <iunlockput>
  end_op();
80104a71:	e8 0e df ff ff       	call   80102984 <end_op>
  return 0;
80104a76:	83 c4 10             	add    $0x10,%esp
80104a79:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a7e:	c9                   	leave  
80104a7f:	c3                   	ret    
    end_op();
80104a80:	e8 ff de ff ff       	call   80102984 <end_op>
    return -1;
80104a85:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a8a:	eb f2                	jmp    80104a7e <sys_mknod+0x80>

80104a8c <sys_chdir>:

int
sys_chdir(void)
{
80104a8c:	55                   	push   %ebp
80104a8d:	89 e5                	mov    %esp,%ebp
80104a8f:	56                   	push   %esi
80104a90:	53                   	push   %ebx
80104a91:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104a94:	e8 b9 e8 ff ff       	call   80103352 <myproc>
80104a99:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104a9b:	e8 6a de ff ff       	call   8010290a <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104aa0:	83 ec 08             	sub    $0x8,%esp
80104aa3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104aa6:	50                   	push   %eax
80104aa7:	6a 00                	push   $0x0
80104aa9:	e8 ca f5 ff ff       	call   80104078 <argstr>
80104aae:	83 c4 10             	add    $0x10,%esp
80104ab1:	85 c0                	test   %eax,%eax
80104ab3:	78 52                	js     80104b07 <sys_chdir+0x7b>
80104ab5:	83 ec 0c             	sub    $0xc,%esp
80104ab8:	ff 75 f4             	pushl  -0xc(%ebp)
80104abb:	e8 21 d1 ff ff       	call   80101be1 <namei>
80104ac0:	89 c3                	mov    %eax,%ebx
80104ac2:	83 c4 10             	add    $0x10,%esp
80104ac5:	85 c0                	test   %eax,%eax
80104ac7:	74 3e                	je     80104b07 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104ac9:	83 ec 0c             	sub    $0xc,%esp
80104acc:	50                   	push   %eax
80104acd:	e8 af ca ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80104ad2:	83 c4 10             	add    $0x10,%esp
80104ad5:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104ada:	75 37                	jne    80104b13 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104adc:	83 ec 0c             	sub    $0xc,%esp
80104adf:	53                   	push   %ebx
80104ae0:	e8 5e cb ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80104ae5:	83 c4 04             	add    $0x4,%esp
80104ae8:	ff 76 68             	pushl  0x68(%esi)
80104aeb:	e8 98 cb ff ff       	call   80101688 <iput>
  end_op();
80104af0:	e8 8f de ff ff       	call   80102984 <end_op>
  curproc->cwd = ip;
80104af5:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104af8:	83 c4 10             	add    $0x10,%esp
80104afb:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b00:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b03:	5b                   	pop    %ebx
80104b04:	5e                   	pop    %esi
80104b05:	5d                   	pop    %ebp
80104b06:	c3                   	ret    
    end_op();
80104b07:	e8 78 de ff ff       	call   80102984 <end_op>
    return -1;
80104b0c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b11:	eb ed                	jmp    80104b00 <sys_chdir+0x74>
    iunlockput(ip);
80104b13:	83 ec 0c             	sub    $0xc,%esp
80104b16:	53                   	push   %ebx
80104b17:	e8 0c cc ff ff       	call   80101728 <iunlockput>
    end_op();
80104b1c:	e8 63 de ff ff       	call   80102984 <end_op>
    return -1;
80104b21:	83 c4 10             	add    $0x10,%esp
80104b24:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b29:	eb d5                	jmp    80104b00 <sys_chdir+0x74>

80104b2b <sys_exec>:

int
sys_exec(void)
{
80104b2b:	55                   	push   %ebp
80104b2c:	89 e5                	mov    %esp,%ebp
80104b2e:	53                   	push   %ebx
80104b2f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104b35:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b38:	50                   	push   %eax
80104b39:	6a 00                	push   $0x0
80104b3b:	e8 38 f5 ff ff       	call   80104078 <argstr>
80104b40:	83 c4 10             	add    $0x10,%esp
80104b43:	85 c0                	test   %eax,%eax
80104b45:	0f 88 a8 00 00 00    	js     80104bf3 <sys_exec+0xc8>
80104b4b:	83 ec 08             	sub    $0x8,%esp
80104b4e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104b54:	50                   	push   %eax
80104b55:	6a 01                	push   $0x1
80104b57:	e8 8c f4 ff ff       	call   80103fe8 <argint>
80104b5c:	83 c4 10             	add    $0x10,%esp
80104b5f:	85 c0                	test   %eax,%eax
80104b61:	0f 88 93 00 00 00    	js     80104bfa <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104b67:	83 ec 04             	sub    $0x4,%esp
80104b6a:	68 80 00 00 00       	push   $0x80
80104b6f:	6a 00                	push   $0x0
80104b71:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104b77:	50                   	push   %eax
80104b78:	e8 20 f2 ff ff       	call   80103d9d <memset>
80104b7d:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104b80:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104b85:	83 fb 1f             	cmp    $0x1f,%ebx
80104b88:	77 77                	ja     80104c01 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104b8a:	83 ec 08             	sub    $0x8,%esp
80104b8d:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104b93:	50                   	push   %eax
80104b94:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104b9a:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104b9d:	50                   	push   %eax
80104b9e:	e8 c9 f3 ff ff       	call   80103f6c <fetchint>
80104ba3:	83 c4 10             	add    $0x10,%esp
80104ba6:	85 c0                	test   %eax,%eax
80104ba8:	78 5e                	js     80104c08 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104baa:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104bb0:	85 c0                	test   %eax,%eax
80104bb2:	74 1d                	je     80104bd1 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104bb4:	83 ec 08             	sub    $0x8,%esp
80104bb7:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104bbe:	52                   	push   %edx
80104bbf:	50                   	push   %eax
80104bc0:	e8 e3 f3 ff ff       	call   80103fa8 <fetchstr>
80104bc5:	83 c4 10             	add    $0x10,%esp
80104bc8:	85 c0                	test   %eax,%eax
80104bca:	78 46                	js     80104c12 <sys_exec+0xe7>
  for(i=0;; i++){
80104bcc:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104bcf:	eb b4                	jmp    80104b85 <sys_exec+0x5a>
      argv[i] = 0;
80104bd1:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104bd8:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104bdc:	83 ec 08             	sub    $0x8,%esp
80104bdf:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104be5:	50                   	push   %eax
80104be6:	ff 75 f4             	pushl  -0xc(%ebp)
80104be9:	e8 e4 bc ff ff       	call   801008d2 <exec>
80104bee:	83 c4 10             	add    $0x10,%esp
80104bf1:	eb 1a                	jmp    80104c0d <sys_exec+0xe2>
    return -1;
80104bf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bf8:	eb 13                	jmp    80104c0d <sys_exec+0xe2>
80104bfa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bff:	eb 0c                	jmp    80104c0d <sys_exec+0xe2>
      return -1;
80104c01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c06:	eb 05                	jmp    80104c0d <sys_exec+0xe2>
      return -1;
80104c08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c10:	c9                   	leave  
80104c11:	c3                   	ret    
      return -1;
80104c12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c17:	eb f4                	jmp    80104c0d <sys_exec+0xe2>

80104c19 <sys_pipe>:

int
sys_pipe(void)
{
80104c19:	55                   	push   %ebp
80104c1a:	89 e5                	mov    %esp,%ebp
80104c1c:	53                   	push   %ebx
80104c1d:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104c20:	6a 08                	push   $0x8
80104c22:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c25:	50                   	push   %eax
80104c26:	6a 00                	push   $0x0
80104c28:	e8 e3 f3 ff ff       	call   80104010 <argptr>
80104c2d:	83 c4 10             	add    $0x10,%esp
80104c30:	85 c0                	test   %eax,%eax
80104c32:	78 77                	js     80104cab <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104c34:	83 ec 08             	sub    $0x8,%esp
80104c37:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c3a:	50                   	push   %eax
80104c3b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c3e:	50                   	push   %eax
80104c3f:	e8 4d e2 ff ff       	call   80102e91 <pipealloc>
80104c44:	83 c4 10             	add    $0x10,%esp
80104c47:	85 c0                	test   %eax,%eax
80104c49:	78 67                	js     80104cb2 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104c4b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c4e:	e8 14 f5 ff ff       	call   80104167 <fdalloc>
80104c53:	89 c3                	mov    %eax,%ebx
80104c55:	85 c0                	test   %eax,%eax
80104c57:	78 21                	js     80104c7a <sys_pipe+0x61>
80104c59:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c5c:	e8 06 f5 ff ff       	call   80104167 <fdalloc>
80104c61:	85 c0                	test   %eax,%eax
80104c63:	78 15                	js     80104c7a <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104c65:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c68:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104c6a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104c6d:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104c70:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c75:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c78:	c9                   	leave  
80104c79:	c3                   	ret    
    if(fd0 >= 0)
80104c7a:	85 db                	test   %ebx,%ebx
80104c7c:	78 0d                	js     80104c8b <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104c7e:	e8 cf e6 ff ff       	call   80103352 <myproc>
80104c83:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104c8a:	00 
    fileclose(rf);
80104c8b:	83 ec 0c             	sub    $0xc,%esp
80104c8e:	ff 75 f0             	pushl  -0x10(%ebp)
80104c91:	e8 3d c0 ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104c96:	83 c4 04             	add    $0x4,%esp
80104c99:	ff 75 ec             	pushl  -0x14(%ebp)
80104c9c:	e8 32 c0 ff ff       	call   80100cd3 <fileclose>
    return -1;
80104ca1:	83 c4 10             	add    $0x10,%esp
80104ca4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ca9:	eb ca                	jmp    80104c75 <sys_pipe+0x5c>
    return -1;
80104cab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cb0:	eb c3                	jmp    80104c75 <sys_pipe+0x5c>
    return -1;
80104cb2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cb7:	eb bc                	jmp    80104c75 <sys_pipe+0x5c>

80104cb9 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104cb9:	55                   	push   %ebp
80104cba:	89 e5                	mov    %esp,%ebp
80104cbc:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104cbf:	e8 06 e8 ff ff       	call   801034ca <fork>
}
80104cc4:	c9                   	leave  
80104cc5:	c3                   	ret    

80104cc6 <sys_exit>:

int
sys_exit(void)
{
80104cc6:	55                   	push   %ebp
80104cc7:	89 e5                	mov    %esp,%ebp
80104cc9:	83 ec 08             	sub    $0x8,%esp
  exit();
80104ccc:	e8 2d ea ff ff       	call   801036fe <exit>
  return 0;  // not reached
}
80104cd1:	b8 00 00 00 00       	mov    $0x0,%eax
80104cd6:	c9                   	leave  
80104cd7:	c3                   	ret    

80104cd8 <sys_wait>:

int
sys_wait(void)
{
80104cd8:	55                   	push   %ebp
80104cd9:	89 e5                	mov    %esp,%ebp
80104cdb:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104cde:	e8 a4 eb ff ff       	call   80103887 <wait>
}
80104ce3:	c9                   	leave  
80104ce4:	c3                   	ret    

80104ce5 <sys_kill>:

int
sys_kill(void)
{
80104ce5:	55                   	push   %ebp
80104ce6:	89 e5                	mov    %esp,%ebp
80104ce8:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104ceb:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104cee:	50                   	push   %eax
80104cef:	6a 00                	push   $0x0
80104cf1:	e8 f2 f2 ff ff       	call   80103fe8 <argint>
80104cf6:	83 c4 10             	add    $0x10,%esp
80104cf9:	85 c0                	test   %eax,%eax
80104cfb:	78 10                	js     80104d0d <sys_kill+0x28>
    return -1;
  return kill(pid);
80104cfd:	83 ec 0c             	sub    $0xc,%esp
80104d00:	ff 75 f4             	pushl  -0xc(%ebp)
80104d03:	e8 7c ec ff ff       	call   80103984 <kill>
80104d08:	83 c4 10             	add    $0x10,%esp
}
80104d0b:	c9                   	leave  
80104d0c:	c3                   	ret    
    return -1;
80104d0d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d12:	eb f7                	jmp    80104d0b <sys_kill+0x26>

80104d14 <sys_getpid>:

int
sys_getpid(void)
{
80104d14:	55                   	push   %ebp
80104d15:	89 e5                	mov    %esp,%ebp
80104d17:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104d1a:	e8 33 e6 ff ff       	call   80103352 <myproc>
80104d1f:	8b 40 10             	mov    0x10(%eax),%eax
}
80104d22:	c9                   	leave  
80104d23:	c3                   	ret    

80104d24 <sys_sbrk>:

int
sys_sbrk(void)
{
80104d24:	55                   	push   %ebp
80104d25:	89 e5                	mov    %esp,%ebp
80104d27:	53                   	push   %ebx
80104d28:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d2e:	50                   	push   %eax
80104d2f:	6a 00                	push   $0x0
80104d31:	e8 b2 f2 ff ff       	call   80103fe8 <argint>
80104d36:	83 c4 10             	add    $0x10,%esp
80104d39:	85 c0                	test   %eax,%eax
80104d3b:	78 27                	js     80104d64 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104d3d:	e8 10 e6 ff ff       	call   80103352 <myproc>
80104d42:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104d44:	83 ec 0c             	sub    $0xc,%esp
80104d47:	ff 75 f4             	pushl  -0xc(%ebp)
80104d4a:	e8 0e e7 ff ff       	call   8010345d <growproc>
80104d4f:	83 c4 10             	add    $0x10,%esp
80104d52:	85 c0                	test   %eax,%eax
80104d54:	78 07                	js     80104d5d <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104d56:	89 d8                	mov    %ebx,%eax
80104d58:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d5b:	c9                   	leave  
80104d5c:	c3                   	ret    
    return -1;
80104d5d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104d62:	eb f2                	jmp    80104d56 <sys_sbrk+0x32>
    return -1;
80104d64:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104d69:	eb eb                	jmp    80104d56 <sys_sbrk+0x32>

80104d6b <sys_sleep>:

int
sys_sleep(void)
{
80104d6b:	55                   	push   %ebp
80104d6c:	89 e5                	mov    %esp,%ebp
80104d6e:	53                   	push   %ebx
80104d6f:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104d72:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d75:	50                   	push   %eax
80104d76:	6a 00                	push   $0x0
80104d78:	e8 6b f2 ff ff       	call   80103fe8 <argint>
80104d7d:	83 c4 10             	add    $0x10,%esp
80104d80:	85 c0                	test   %eax,%eax
80104d82:	78 75                	js     80104df9 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104d84:	83 ec 0c             	sub    $0xc,%esp
80104d87:	68 a0 4c 13 80       	push   $0x80134ca0
80104d8c:	e8 60 ef ff ff       	call   80103cf1 <acquire>
  ticks0 = ticks;
80104d91:	8b 1d e0 54 13 80    	mov    0x801354e0,%ebx
  while(ticks - ticks0 < n){
80104d97:	83 c4 10             	add    $0x10,%esp
80104d9a:	a1 e0 54 13 80       	mov    0x801354e0,%eax
80104d9f:	29 d8                	sub    %ebx,%eax
80104da1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104da4:	73 39                	jae    80104ddf <sys_sleep+0x74>
    if(myproc()->killed){
80104da6:	e8 a7 e5 ff ff       	call   80103352 <myproc>
80104dab:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104daf:	75 17                	jne    80104dc8 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104db1:	83 ec 08             	sub    $0x8,%esp
80104db4:	68 a0 4c 13 80       	push   $0x80134ca0
80104db9:	68 e0 54 13 80       	push   $0x801354e0
80104dbe:	e8 33 ea ff ff       	call   801037f6 <sleep>
80104dc3:	83 c4 10             	add    $0x10,%esp
80104dc6:	eb d2                	jmp    80104d9a <sys_sleep+0x2f>
      release(&tickslock);
80104dc8:	83 ec 0c             	sub    $0xc,%esp
80104dcb:	68 a0 4c 13 80       	push   $0x80134ca0
80104dd0:	e8 81 ef ff ff       	call   80103d56 <release>
      return -1;
80104dd5:	83 c4 10             	add    $0x10,%esp
80104dd8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ddd:	eb 15                	jmp    80104df4 <sys_sleep+0x89>
  }
  release(&tickslock);
80104ddf:	83 ec 0c             	sub    $0xc,%esp
80104de2:	68 a0 4c 13 80       	push   $0x80134ca0
80104de7:	e8 6a ef ff ff       	call   80103d56 <release>
  return 0;
80104dec:	83 c4 10             	add    $0x10,%esp
80104def:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104df4:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104df7:	c9                   	leave  
80104df8:	c3                   	ret    
    return -1;
80104df9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dfe:	eb f4                	jmp    80104df4 <sys_sleep+0x89>

80104e00 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104e00:	55                   	push   %ebp
80104e01:	89 e5                	mov    %esp,%ebp
80104e03:	53                   	push   %ebx
80104e04:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104e07:	68 a0 4c 13 80       	push   $0x80134ca0
80104e0c:	e8 e0 ee ff ff       	call   80103cf1 <acquire>
  xticks = ticks;
80104e11:	8b 1d e0 54 13 80    	mov    0x801354e0,%ebx
  release(&tickslock);
80104e17:	c7 04 24 a0 4c 13 80 	movl   $0x80134ca0,(%esp)
80104e1e:	e8 33 ef ff ff       	call   80103d56 <release>
  return xticks;
}
80104e23:	89 d8                	mov    %ebx,%eax
80104e25:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e28:	c9                   	leave  
80104e29:	c3                   	ret    

80104e2a <sys_dump_physmem>:

// used for p5
// find which process owns each frame of phys mem
int
sys_dump_physmem(void)
{
80104e2a:	55                   	push   %ebp
80104e2b:	89 e5                	mov    %esp,%ebp
80104e2d:	83 ec 1c             	sub    $0x1c,%esp
  int *frames;
  int *pids;
  int numframes;
  //cprintf("sys_dump_physmem in sysproc.c\n");
  if(argptr(0, (char**)&frames, sizeof(int*)) < 0)
80104e30:	6a 04                	push   $0x4
80104e32:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e35:	50                   	push   %eax
80104e36:	6a 00                	push   $0x0
80104e38:	e8 d3 f1 ff ff       	call   80104010 <argptr>
80104e3d:	83 c4 10             	add    $0x10,%esp
80104e40:	85 c0                	test   %eax,%eax
80104e42:	78 42                	js     80104e86 <sys_dump_physmem+0x5c>
    return -1;
  if(argptr(1, (char**)&pids, sizeof(int*)) < 0)
80104e44:	83 ec 04             	sub    $0x4,%esp
80104e47:	6a 04                	push   $0x4
80104e49:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e4c:	50                   	push   %eax
80104e4d:	6a 01                	push   $0x1
80104e4f:	e8 bc f1 ff ff       	call   80104010 <argptr>
80104e54:	83 c4 10             	add    $0x10,%esp
80104e57:	85 c0                	test   %eax,%eax
80104e59:	78 32                	js     80104e8d <sys_dump_physmem+0x63>
    return -1;
  if(argint(2, &numframes) < 0)
80104e5b:	83 ec 08             	sub    $0x8,%esp
80104e5e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104e61:	50                   	push   %eax
80104e62:	6a 02                	push   $0x2
80104e64:	e8 7f f1 ff ff       	call   80103fe8 <argint>
80104e69:	83 c4 10             	add    $0x10,%esp
80104e6c:	85 c0                	test   %eax,%eax
80104e6e:	78 24                	js     80104e94 <sys_dump_physmem+0x6a>
    return -1;
  return dump_physmem(frames, pids, numframes);
80104e70:	83 ec 04             	sub    $0x4,%esp
80104e73:	ff 75 ec             	pushl  -0x14(%ebp)
80104e76:	ff 75 f0             	pushl  -0x10(%ebp)
80104e79:	ff 75 f4             	pushl  -0xc(%ebp)
80104e7c:	e8 a9 d3 ff ff       	call   8010222a <dump_physmem>
80104e81:	83 c4 10             	add    $0x10,%esp
}
80104e84:	c9                   	leave  
80104e85:	c3                   	ret    
    return -1;
80104e86:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e8b:	eb f7                	jmp    80104e84 <sys_dump_physmem+0x5a>
    return -1;
80104e8d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e92:	eb f0                	jmp    80104e84 <sys_dump_physmem+0x5a>
    return -1;
80104e94:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e99:	eb e9                	jmp    80104e84 <sys_dump_physmem+0x5a>

80104e9b <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104e9b:	1e                   	push   %ds
  pushl %es
80104e9c:	06                   	push   %es
  pushl %fs
80104e9d:	0f a0                	push   %fs
  pushl %gs
80104e9f:	0f a8                	push   %gs
  pushal
80104ea1:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104ea2:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104ea6:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104ea8:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104eaa:	54                   	push   %esp
  call trap
80104eab:	e8 e3 00 00 00       	call   80104f93 <trap>
  addl $4, %esp
80104eb0:	83 c4 04             	add    $0x4,%esp

80104eb3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104eb3:	61                   	popa   
  popl %gs
80104eb4:	0f a9                	pop    %gs
  popl %fs
80104eb6:	0f a1                	pop    %fs
  popl %es
80104eb8:	07                   	pop    %es
  popl %ds
80104eb9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104eba:	83 c4 08             	add    $0x8,%esp
  iret
80104ebd:	cf                   	iret   

80104ebe <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104ebe:	55                   	push   %ebp
80104ebf:	89 e5                	mov    %esp,%ebp
80104ec1:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104ec4:	b8 00 00 00 00       	mov    $0x0,%eax
80104ec9:	eb 4a                	jmp    80104f15 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104ecb:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104ed2:	66 89 0c c5 e0 4c 13 	mov    %cx,-0x7fecb320(,%eax,8)
80104ed9:	80 
80104eda:	66 c7 04 c5 e2 4c 13 	movw   $0x8,-0x7fecb31e(,%eax,8)
80104ee1:	80 08 00 
80104ee4:	c6 04 c5 e4 4c 13 80 	movb   $0x0,-0x7fecb31c(,%eax,8)
80104eeb:	00 
80104eec:	0f b6 14 c5 e5 4c 13 	movzbl -0x7fecb31b(,%eax,8),%edx
80104ef3:	80 
80104ef4:	83 e2 f0             	and    $0xfffffff0,%edx
80104ef7:	83 ca 0e             	or     $0xe,%edx
80104efa:	83 e2 8f             	and    $0xffffff8f,%edx
80104efd:	83 ca 80             	or     $0xffffff80,%edx
80104f00:	88 14 c5 e5 4c 13 80 	mov    %dl,-0x7fecb31b(,%eax,8)
80104f07:	c1 e9 10             	shr    $0x10,%ecx
80104f0a:	66 89 0c c5 e6 4c 13 	mov    %cx,-0x7fecb31a(,%eax,8)
80104f11:	80 
  for(i = 0; i < 256; i++)
80104f12:	83 c0 01             	add    $0x1,%eax
80104f15:	3d ff 00 00 00       	cmp    $0xff,%eax
80104f1a:	7e af                	jle    80104ecb <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104f1c:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104f22:	66 89 15 e0 4e 13 80 	mov    %dx,0x80134ee0
80104f29:	66 c7 05 e2 4e 13 80 	movw   $0x8,0x80134ee2
80104f30:	08 00 
80104f32:	c6 05 e4 4e 13 80 00 	movb   $0x0,0x80134ee4
80104f39:	0f b6 05 e5 4e 13 80 	movzbl 0x80134ee5,%eax
80104f40:	83 c8 0f             	or     $0xf,%eax
80104f43:	83 e0 ef             	and    $0xffffffef,%eax
80104f46:	83 c8 e0             	or     $0xffffffe0,%eax
80104f49:	a2 e5 4e 13 80       	mov    %al,0x80134ee5
80104f4e:	c1 ea 10             	shr    $0x10,%edx
80104f51:	66 89 15 e6 4e 13 80 	mov    %dx,0x80134ee6

  initlock(&tickslock, "time");
80104f58:	83 ec 08             	sub    $0x8,%esp
80104f5b:	68 dd 6d 10 80       	push   $0x80106ddd
80104f60:	68 a0 4c 13 80       	push   $0x80134ca0
80104f65:	e8 4b ec ff ff       	call   80103bb5 <initlock>
}
80104f6a:	83 c4 10             	add    $0x10,%esp
80104f6d:	c9                   	leave  
80104f6e:	c3                   	ret    

80104f6f <idtinit>:

void
idtinit(void)
{
80104f6f:	55                   	push   %ebp
80104f70:	89 e5                	mov    %esp,%ebp
80104f72:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104f75:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104f7b:	b8 e0 4c 13 80       	mov    $0x80134ce0,%eax
80104f80:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104f84:	c1 e8 10             	shr    $0x10,%eax
80104f87:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104f8b:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104f8e:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104f91:	c9                   	leave  
80104f92:	c3                   	ret    

80104f93 <trap>:

void
trap(struct trapframe *tf)
{
80104f93:	55                   	push   %ebp
80104f94:	89 e5                	mov    %esp,%ebp
80104f96:	57                   	push   %edi
80104f97:	56                   	push   %esi
80104f98:	53                   	push   %ebx
80104f99:	83 ec 1c             	sub    $0x1c,%esp
80104f9c:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104f9f:	8b 43 30             	mov    0x30(%ebx),%eax
80104fa2:	83 f8 40             	cmp    $0x40,%eax
80104fa5:	74 13                	je     80104fba <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104fa7:	83 e8 20             	sub    $0x20,%eax
80104faa:	83 f8 1f             	cmp    $0x1f,%eax
80104fad:	0f 87 3a 01 00 00    	ja     801050ed <trap+0x15a>
80104fb3:	ff 24 85 84 6e 10 80 	jmp    *-0x7fef917c(,%eax,4)
    if(myproc()->killed)
80104fba:	e8 93 e3 ff ff       	call   80103352 <myproc>
80104fbf:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104fc3:	75 1f                	jne    80104fe4 <trap+0x51>
    myproc()->tf = tf;
80104fc5:	e8 88 e3 ff ff       	call   80103352 <myproc>
80104fca:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104fcd:	e8 d9 f0 ff ff       	call   801040ab <syscall>
    if(myproc()->killed)
80104fd2:	e8 7b e3 ff ff       	call   80103352 <myproc>
80104fd7:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104fdb:	74 7e                	je     8010505b <trap+0xc8>
      exit();
80104fdd:	e8 1c e7 ff ff       	call   801036fe <exit>
80104fe2:	eb 77                	jmp    8010505b <trap+0xc8>
      exit();
80104fe4:	e8 15 e7 ff ff       	call   801036fe <exit>
80104fe9:	eb da                	jmp    80104fc5 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104feb:	e8 47 e3 ff ff       	call   80103337 <cpuid>
80104ff0:	85 c0                	test   %eax,%eax
80104ff2:	74 6f                	je     80105063 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104ff4:	e8 fc d4 ff ff       	call   801024f5 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104ff9:	e8 54 e3 ff ff       	call   80103352 <myproc>
80104ffe:	85 c0                	test   %eax,%eax
80105000:	74 1c                	je     8010501e <trap+0x8b>
80105002:	e8 4b e3 ff ff       	call   80103352 <myproc>
80105007:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010500b:	74 11                	je     8010501e <trap+0x8b>
8010500d:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105011:	83 e0 03             	and    $0x3,%eax
80105014:	66 83 f8 03          	cmp    $0x3,%ax
80105018:	0f 84 62 01 00 00    	je     80105180 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010501e:	e8 2f e3 ff ff       	call   80103352 <myproc>
80105023:	85 c0                	test   %eax,%eax
80105025:	74 0f                	je     80105036 <trap+0xa3>
80105027:	e8 26 e3 ff ff       	call   80103352 <myproc>
8010502c:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105030:	0f 84 54 01 00 00    	je     8010518a <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105036:	e8 17 e3 ff ff       	call   80103352 <myproc>
8010503b:	85 c0                	test   %eax,%eax
8010503d:	74 1c                	je     8010505b <trap+0xc8>
8010503f:	e8 0e e3 ff ff       	call   80103352 <myproc>
80105044:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105048:	74 11                	je     8010505b <trap+0xc8>
8010504a:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010504e:	83 e0 03             	and    $0x3,%eax
80105051:	66 83 f8 03          	cmp    $0x3,%ax
80105055:	0f 84 43 01 00 00    	je     8010519e <trap+0x20b>
    exit();
}
8010505b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010505e:	5b                   	pop    %ebx
8010505f:	5e                   	pop    %esi
80105060:	5f                   	pop    %edi
80105061:	5d                   	pop    %ebp
80105062:	c3                   	ret    
      acquire(&tickslock);
80105063:	83 ec 0c             	sub    $0xc,%esp
80105066:	68 a0 4c 13 80       	push   $0x80134ca0
8010506b:	e8 81 ec ff ff       	call   80103cf1 <acquire>
      ticks++;
80105070:	83 05 e0 54 13 80 01 	addl   $0x1,0x801354e0
      wakeup(&ticks);
80105077:	c7 04 24 e0 54 13 80 	movl   $0x801354e0,(%esp)
8010507e:	e8 d8 e8 ff ff       	call   8010395b <wakeup>
      release(&tickslock);
80105083:	c7 04 24 a0 4c 13 80 	movl   $0x80134ca0,(%esp)
8010508a:	e8 c7 ec ff ff       	call   80103d56 <release>
8010508f:	83 c4 10             	add    $0x10,%esp
80105092:	e9 5d ff ff ff       	jmp    80104ff4 <trap+0x61>
    ideintr();
80105097:	e8 d7 cc ff ff       	call   80101d73 <ideintr>
    lapiceoi();
8010509c:	e8 54 d4 ff ff       	call   801024f5 <lapiceoi>
    break;
801050a1:	e9 53 ff ff ff       	jmp    80104ff9 <trap+0x66>
    kbdintr();
801050a6:	e8 8e d2 ff ff       	call   80102339 <kbdintr>
    lapiceoi();
801050ab:	e8 45 d4 ff ff       	call   801024f5 <lapiceoi>
    break;
801050b0:	e9 44 ff ff ff       	jmp    80104ff9 <trap+0x66>
    uartintr();
801050b5:	e8 05 02 00 00       	call   801052bf <uartintr>
    lapiceoi();
801050ba:	e8 36 d4 ff ff       	call   801024f5 <lapiceoi>
    break;
801050bf:	e9 35 ff ff ff       	jmp    80104ff9 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801050c4:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801050c7:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801050cb:	e8 67 e2 ff ff       	call   80103337 <cpuid>
801050d0:	57                   	push   %edi
801050d1:	0f b7 f6             	movzwl %si,%esi
801050d4:	56                   	push   %esi
801050d5:	50                   	push   %eax
801050d6:	68 e8 6d 10 80       	push   $0x80106de8
801050db:	e8 2b b5 ff ff       	call   8010060b <cprintf>
    lapiceoi();
801050e0:	e8 10 d4 ff ff       	call   801024f5 <lapiceoi>
    break;
801050e5:	83 c4 10             	add    $0x10,%esp
801050e8:	e9 0c ff ff ff       	jmp    80104ff9 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
801050ed:	e8 60 e2 ff ff       	call   80103352 <myproc>
801050f2:	85 c0                	test   %eax,%eax
801050f4:	74 5f                	je     80105155 <trap+0x1c2>
801050f6:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
801050fa:	74 59                	je     80105155 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
801050fc:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801050ff:	8b 43 38             	mov    0x38(%ebx),%eax
80105102:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105105:	e8 2d e2 ff ff       	call   80103337 <cpuid>
8010510a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010510d:	8b 53 34             	mov    0x34(%ebx),%edx
80105110:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105113:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105116:	e8 37 e2 ff ff       	call   80103352 <myproc>
8010511b:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010511e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105121:	e8 2c e2 ff ff       	call   80103352 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105126:	57                   	push   %edi
80105127:	ff 75 e4             	pushl  -0x1c(%ebp)
8010512a:	ff 75 e0             	pushl  -0x20(%ebp)
8010512d:	ff 75 dc             	pushl  -0x24(%ebp)
80105130:	56                   	push   %esi
80105131:	ff 75 d8             	pushl  -0x28(%ebp)
80105134:	ff 70 10             	pushl  0x10(%eax)
80105137:	68 40 6e 10 80       	push   $0x80106e40
8010513c:	e8 ca b4 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105141:	83 c4 20             	add    $0x20,%esp
80105144:	e8 09 e2 ff ff       	call   80103352 <myproc>
80105149:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105150:	e9 a4 fe ff ff       	jmp    80104ff9 <trap+0x66>
80105155:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105158:	8b 73 38             	mov    0x38(%ebx),%esi
8010515b:	e8 d7 e1 ff ff       	call   80103337 <cpuid>
80105160:	83 ec 0c             	sub    $0xc,%esp
80105163:	57                   	push   %edi
80105164:	56                   	push   %esi
80105165:	50                   	push   %eax
80105166:	ff 73 30             	pushl  0x30(%ebx)
80105169:	68 0c 6e 10 80       	push   $0x80106e0c
8010516e:	e8 98 b4 ff ff       	call   8010060b <cprintf>
      panic("trap");
80105173:	83 c4 14             	add    $0x14,%esp
80105176:	68 e2 6d 10 80       	push   $0x80106de2
8010517b:	e8 c8 b1 ff ff       	call   80100348 <panic>
    exit();
80105180:	e8 79 e5 ff ff       	call   801036fe <exit>
80105185:	e9 94 fe ff ff       	jmp    8010501e <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
8010518a:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
8010518e:	0f 85 a2 fe ff ff    	jne    80105036 <trap+0xa3>
    yield();
80105194:	e8 2b e6 ff ff       	call   801037c4 <yield>
80105199:	e9 98 fe ff ff       	jmp    80105036 <trap+0xa3>
    exit();
8010519e:	e8 5b e5 ff ff       	call   801036fe <exit>
801051a3:	e9 b3 fe ff ff       	jmp    8010505b <trap+0xc8>

801051a8 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801051a8:	55                   	push   %ebp
801051a9:	89 e5                	mov    %esp,%ebp
  if(!uart)
801051ab:	83 3d c4 a5 10 80 00 	cmpl   $0x0,0x8010a5c4
801051b2:	74 15                	je     801051c9 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051b4:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051b9:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801051ba:	a8 01                	test   $0x1,%al
801051bc:	74 12                	je     801051d0 <uartgetc+0x28>
801051be:	ba f8 03 00 00       	mov    $0x3f8,%edx
801051c3:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801051c4:	0f b6 c0             	movzbl %al,%eax
}
801051c7:	5d                   	pop    %ebp
801051c8:	c3                   	ret    
    return -1;
801051c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051ce:	eb f7                	jmp    801051c7 <uartgetc+0x1f>
    return -1;
801051d0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801051d5:	eb f0                	jmp    801051c7 <uartgetc+0x1f>

801051d7 <uartputc>:
  if(!uart)
801051d7:	83 3d c4 a5 10 80 00 	cmpl   $0x0,0x8010a5c4
801051de:	74 3b                	je     8010521b <uartputc+0x44>
{
801051e0:	55                   	push   %ebp
801051e1:	89 e5                	mov    %esp,%ebp
801051e3:	53                   	push   %ebx
801051e4:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801051e7:	bb 00 00 00 00       	mov    $0x0,%ebx
801051ec:	eb 10                	jmp    801051fe <uartputc+0x27>
    microdelay(10);
801051ee:	83 ec 0c             	sub    $0xc,%esp
801051f1:	6a 0a                	push   $0xa
801051f3:	e8 1c d3 ff ff       	call   80102514 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801051f8:	83 c3 01             	add    $0x1,%ebx
801051fb:	83 c4 10             	add    $0x10,%esp
801051fe:	83 fb 7f             	cmp    $0x7f,%ebx
80105201:	7f 0a                	jg     8010520d <uartputc+0x36>
80105203:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105208:	ec                   	in     (%dx),%al
80105209:	a8 20                	test   $0x20,%al
8010520b:	74 e1                	je     801051ee <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010520d:	8b 45 08             	mov    0x8(%ebp),%eax
80105210:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105215:	ee                   	out    %al,(%dx)
}
80105216:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105219:	c9                   	leave  
8010521a:	c3                   	ret    
8010521b:	f3 c3                	repz ret 

8010521d <uartinit>:
{
8010521d:	55                   	push   %ebp
8010521e:	89 e5                	mov    %esp,%ebp
80105220:	56                   	push   %esi
80105221:	53                   	push   %ebx
80105222:	b9 00 00 00 00       	mov    $0x0,%ecx
80105227:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010522c:	89 c8                	mov    %ecx,%eax
8010522e:	ee                   	out    %al,(%dx)
8010522f:	be fb 03 00 00       	mov    $0x3fb,%esi
80105234:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105239:	89 f2                	mov    %esi,%edx
8010523b:	ee                   	out    %al,(%dx)
8010523c:	b8 0c 00 00 00       	mov    $0xc,%eax
80105241:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105246:	ee                   	out    %al,(%dx)
80105247:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010524c:	89 c8                	mov    %ecx,%eax
8010524e:	89 da                	mov    %ebx,%edx
80105250:	ee                   	out    %al,(%dx)
80105251:	b8 03 00 00 00       	mov    $0x3,%eax
80105256:	89 f2                	mov    %esi,%edx
80105258:	ee                   	out    %al,(%dx)
80105259:	ba fc 03 00 00       	mov    $0x3fc,%edx
8010525e:	89 c8                	mov    %ecx,%eax
80105260:	ee                   	out    %al,(%dx)
80105261:	b8 01 00 00 00       	mov    $0x1,%eax
80105266:	89 da                	mov    %ebx,%edx
80105268:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105269:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010526e:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
8010526f:	3c ff                	cmp    $0xff,%al
80105271:	74 45                	je     801052b8 <uartinit+0x9b>
  uart = 1;
80105273:	c7 05 c4 a5 10 80 01 	movl   $0x1,0x8010a5c4
8010527a:	00 00 00 
8010527d:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105282:	ec                   	in     (%dx),%al
80105283:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105288:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105289:	83 ec 08             	sub    $0x8,%esp
8010528c:	6a 00                	push   $0x0
8010528e:	6a 04                	push   $0x4
80105290:	e8 e9 cc ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105295:	83 c4 10             	add    $0x10,%esp
80105298:	bb 04 6f 10 80       	mov    $0x80106f04,%ebx
8010529d:	eb 12                	jmp    801052b1 <uartinit+0x94>
    uartputc(*p);
8010529f:	83 ec 0c             	sub    $0xc,%esp
801052a2:	0f be c0             	movsbl %al,%eax
801052a5:	50                   	push   %eax
801052a6:	e8 2c ff ff ff       	call   801051d7 <uartputc>
  for(p="xv6...\n"; *p; p++)
801052ab:	83 c3 01             	add    $0x1,%ebx
801052ae:	83 c4 10             	add    $0x10,%esp
801052b1:	0f b6 03             	movzbl (%ebx),%eax
801052b4:	84 c0                	test   %al,%al
801052b6:	75 e7                	jne    8010529f <uartinit+0x82>
}
801052b8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801052bb:	5b                   	pop    %ebx
801052bc:	5e                   	pop    %esi
801052bd:	5d                   	pop    %ebp
801052be:	c3                   	ret    

801052bf <uartintr>:

void
uartintr(void)
{
801052bf:	55                   	push   %ebp
801052c0:	89 e5                	mov    %esp,%ebp
801052c2:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801052c5:	68 a8 51 10 80       	push   $0x801051a8
801052ca:	e8 6f b4 ff ff       	call   8010073e <consoleintr>
}
801052cf:	83 c4 10             	add    $0x10,%esp
801052d2:	c9                   	leave  
801052d3:	c3                   	ret    

801052d4 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801052d4:	6a 00                	push   $0x0
  pushl $0
801052d6:	6a 00                	push   $0x0
  jmp alltraps
801052d8:	e9 be fb ff ff       	jmp    80104e9b <alltraps>

801052dd <vector1>:
.globl vector1
vector1:
  pushl $0
801052dd:	6a 00                	push   $0x0
  pushl $1
801052df:	6a 01                	push   $0x1
  jmp alltraps
801052e1:	e9 b5 fb ff ff       	jmp    80104e9b <alltraps>

801052e6 <vector2>:
.globl vector2
vector2:
  pushl $0
801052e6:	6a 00                	push   $0x0
  pushl $2
801052e8:	6a 02                	push   $0x2
  jmp alltraps
801052ea:	e9 ac fb ff ff       	jmp    80104e9b <alltraps>

801052ef <vector3>:
.globl vector3
vector3:
  pushl $0
801052ef:	6a 00                	push   $0x0
  pushl $3
801052f1:	6a 03                	push   $0x3
  jmp alltraps
801052f3:	e9 a3 fb ff ff       	jmp    80104e9b <alltraps>

801052f8 <vector4>:
.globl vector4
vector4:
  pushl $0
801052f8:	6a 00                	push   $0x0
  pushl $4
801052fa:	6a 04                	push   $0x4
  jmp alltraps
801052fc:	e9 9a fb ff ff       	jmp    80104e9b <alltraps>

80105301 <vector5>:
.globl vector5
vector5:
  pushl $0
80105301:	6a 00                	push   $0x0
  pushl $5
80105303:	6a 05                	push   $0x5
  jmp alltraps
80105305:	e9 91 fb ff ff       	jmp    80104e9b <alltraps>

8010530a <vector6>:
.globl vector6
vector6:
  pushl $0
8010530a:	6a 00                	push   $0x0
  pushl $6
8010530c:	6a 06                	push   $0x6
  jmp alltraps
8010530e:	e9 88 fb ff ff       	jmp    80104e9b <alltraps>

80105313 <vector7>:
.globl vector7
vector7:
  pushl $0
80105313:	6a 00                	push   $0x0
  pushl $7
80105315:	6a 07                	push   $0x7
  jmp alltraps
80105317:	e9 7f fb ff ff       	jmp    80104e9b <alltraps>

8010531c <vector8>:
.globl vector8
vector8:
  pushl $8
8010531c:	6a 08                	push   $0x8
  jmp alltraps
8010531e:	e9 78 fb ff ff       	jmp    80104e9b <alltraps>

80105323 <vector9>:
.globl vector9
vector9:
  pushl $0
80105323:	6a 00                	push   $0x0
  pushl $9
80105325:	6a 09                	push   $0x9
  jmp alltraps
80105327:	e9 6f fb ff ff       	jmp    80104e9b <alltraps>

8010532c <vector10>:
.globl vector10
vector10:
  pushl $10
8010532c:	6a 0a                	push   $0xa
  jmp alltraps
8010532e:	e9 68 fb ff ff       	jmp    80104e9b <alltraps>

80105333 <vector11>:
.globl vector11
vector11:
  pushl $11
80105333:	6a 0b                	push   $0xb
  jmp alltraps
80105335:	e9 61 fb ff ff       	jmp    80104e9b <alltraps>

8010533a <vector12>:
.globl vector12
vector12:
  pushl $12
8010533a:	6a 0c                	push   $0xc
  jmp alltraps
8010533c:	e9 5a fb ff ff       	jmp    80104e9b <alltraps>

80105341 <vector13>:
.globl vector13
vector13:
  pushl $13
80105341:	6a 0d                	push   $0xd
  jmp alltraps
80105343:	e9 53 fb ff ff       	jmp    80104e9b <alltraps>

80105348 <vector14>:
.globl vector14
vector14:
  pushl $14
80105348:	6a 0e                	push   $0xe
  jmp alltraps
8010534a:	e9 4c fb ff ff       	jmp    80104e9b <alltraps>

8010534f <vector15>:
.globl vector15
vector15:
  pushl $0
8010534f:	6a 00                	push   $0x0
  pushl $15
80105351:	6a 0f                	push   $0xf
  jmp alltraps
80105353:	e9 43 fb ff ff       	jmp    80104e9b <alltraps>

80105358 <vector16>:
.globl vector16
vector16:
  pushl $0
80105358:	6a 00                	push   $0x0
  pushl $16
8010535a:	6a 10                	push   $0x10
  jmp alltraps
8010535c:	e9 3a fb ff ff       	jmp    80104e9b <alltraps>

80105361 <vector17>:
.globl vector17
vector17:
  pushl $17
80105361:	6a 11                	push   $0x11
  jmp alltraps
80105363:	e9 33 fb ff ff       	jmp    80104e9b <alltraps>

80105368 <vector18>:
.globl vector18
vector18:
  pushl $0
80105368:	6a 00                	push   $0x0
  pushl $18
8010536a:	6a 12                	push   $0x12
  jmp alltraps
8010536c:	e9 2a fb ff ff       	jmp    80104e9b <alltraps>

80105371 <vector19>:
.globl vector19
vector19:
  pushl $0
80105371:	6a 00                	push   $0x0
  pushl $19
80105373:	6a 13                	push   $0x13
  jmp alltraps
80105375:	e9 21 fb ff ff       	jmp    80104e9b <alltraps>

8010537a <vector20>:
.globl vector20
vector20:
  pushl $0
8010537a:	6a 00                	push   $0x0
  pushl $20
8010537c:	6a 14                	push   $0x14
  jmp alltraps
8010537e:	e9 18 fb ff ff       	jmp    80104e9b <alltraps>

80105383 <vector21>:
.globl vector21
vector21:
  pushl $0
80105383:	6a 00                	push   $0x0
  pushl $21
80105385:	6a 15                	push   $0x15
  jmp alltraps
80105387:	e9 0f fb ff ff       	jmp    80104e9b <alltraps>

8010538c <vector22>:
.globl vector22
vector22:
  pushl $0
8010538c:	6a 00                	push   $0x0
  pushl $22
8010538e:	6a 16                	push   $0x16
  jmp alltraps
80105390:	e9 06 fb ff ff       	jmp    80104e9b <alltraps>

80105395 <vector23>:
.globl vector23
vector23:
  pushl $0
80105395:	6a 00                	push   $0x0
  pushl $23
80105397:	6a 17                	push   $0x17
  jmp alltraps
80105399:	e9 fd fa ff ff       	jmp    80104e9b <alltraps>

8010539e <vector24>:
.globl vector24
vector24:
  pushl $0
8010539e:	6a 00                	push   $0x0
  pushl $24
801053a0:	6a 18                	push   $0x18
  jmp alltraps
801053a2:	e9 f4 fa ff ff       	jmp    80104e9b <alltraps>

801053a7 <vector25>:
.globl vector25
vector25:
  pushl $0
801053a7:	6a 00                	push   $0x0
  pushl $25
801053a9:	6a 19                	push   $0x19
  jmp alltraps
801053ab:	e9 eb fa ff ff       	jmp    80104e9b <alltraps>

801053b0 <vector26>:
.globl vector26
vector26:
  pushl $0
801053b0:	6a 00                	push   $0x0
  pushl $26
801053b2:	6a 1a                	push   $0x1a
  jmp alltraps
801053b4:	e9 e2 fa ff ff       	jmp    80104e9b <alltraps>

801053b9 <vector27>:
.globl vector27
vector27:
  pushl $0
801053b9:	6a 00                	push   $0x0
  pushl $27
801053bb:	6a 1b                	push   $0x1b
  jmp alltraps
801053bd:	e9 d9 fa ff ff       	jmp    80104e9b <alltraps>

801053c2 <vector28>:
.globl vector28
vector28:
  pushl $0
801053c2:	6a 00                	push   $0x0
  pushl $28
801053c4:	6a 1c                	push   $0x1c
  jmp alltraps
801053c6:	e9 d0 fa ff ff       	jmp    80104e9b <alltraps>

801053cb <vector29>:
.globl vector29
vector29:
  pushl $0
801053cb:	6a 00                	push   $0x0
  pushl $29
801053cd:	6a 1d                	push   $0x1d
  jmp alltraps
801053cf:	e9 c7 fa ff ff       	jmp    80104e9b <alltraps>

801053d4 <vector30>:
.globl vector30
vector30:
  pushl $0
801053d4:	6a 00                	push   $0x0
  pushl $30
801053d6:	6a 1e                	push   $0x1e
  jmp alltraps
801053d8:	e9 be fa ff ff       	jmp    80104e9b <alltraps>

801053dd <vector31>:
.globl vector31
vector31:
  pushl $0
801053dd:	6a 00                	push   $0x0
  pushl $31
801053df:	6a 1f                	push   $0x1f
  jmp alltraps
801053e1:	e9 b5 fa ff ff       	jmp    80104e9b <alltraps>

801053e6 <vector32>:
.globl vector32
vector32:
  pushl $0
801053e6:	6a 00                	push   $0x0
  pushl $32
801053e8:	6a 20                	push   $0x20
  jmp alltraps
801053ea:	e9 ac fa ff ff       	jmp    80104e9b <alltraps>

801053ef <vector33>:
.globl vector33
vector33:
  pushl $0
801053ef:	6a 00                	push   $0x0
  pushl $33
801053f1:	6a 21                	push   $0x21
  jmp alltraps
801053f3:	e9 a3 fa ff ff       	jmp    80104e9b <alltraps>

801053f8 <vector34>:
.globl vector34
vector34:
  pushl $0
801053f8:	6a 00                	push   $0x0
  pushl $34
801053fa:	6a 22                	push   $0x22
  jmp alltraps
801053fc:	e9 9a fa ff ff       	jmp    80104e9b <alltraps>

80105401 <vector35>:
.globl vector35
vector35:
  pushl $0
80105401:	6a 00                	push   $0x0
  pushl $35
80105403:	6a 23                	push   $0x23
  jmp alltraps
80105405:	e9 91 fa ff ff       	jmp    80104e9b <alltraps>

8010540a <vector36>:
.globl vector36
vector36:
  pushl $0
8010540a:	6a 00                	push   $0x0
  pushl $36
8010540c:	6a 24                	push   $0x24
  jmp alltraps
8010540e:	e9 88 fa ff ff       	jmp    80104e9b <alltraps>

80105413 <vector37>:
.globl vector37
vector37:
  pushl $0
80105413:	6a 00                	push   $0x0
  pushl $37
80105415:	6a 25                	push   $0x25
  jmp alltraps
80105417:	e9 7f fa ff ff       	jmp    80104e9b <alltraps>

8010541c <vector38>:
.globl vector38
vector38:
  pushl $0
8010541c:	6a 00                	push   $0x0
  pushl $38
8010541e:	6a 26                	push   $0x26
  jmp alltraps
80105420:	e9 76 fa ff ff       	jmp    80104e9b <alltraps>

80105425 <vector39>:
.globl vector39
vector39:
  pushl $0
80105425:	6a 00                	push   $0x0
  pushl $39
80105427:	6a 27                	push   $0x27
  jmp alltraps
80105429:	e9 6d fa ff ff       	jmp    80104e9b <alltraps>

8010542e <vector40>:
.globl vector40
vector40:
  pushl $0
8010542e:	6a 00                	push   $0x0
  pushl $40
80105430:	6a 28                	push   $0x28
  jmp alltraps
80105432:	e9 64 fa ff ff       	jmp    80104e9b <alltraps>

80105437 <vector41>:
.globl vector41
vector41:
  pushl $0
80105437:	6a 00                	push   $0x0
  pushl $41
80105439:	6a 29                	push   $0x29
  jmp alltraps
8010543b:	e9 5b fa ff ff       	jmp    80104e9b <alltraps>

80105440 <vector42>:
.globl vector42
vector42:
  pushl $0
80105440:	6a 00                	push   $0x0
  pushl $42
80105442:	6a 2a                	push   $0x2a
  jmp alltraps
80105444:	e9 52 fa ff ff       	jmp    80104e9b <alltraps>

80105449 <vector43>:
.globl vector43
vector43:
  pushl $0
80105449:	6a 00                	push   $0x0
  pushl $43
8010544b:	6a 2b                	push   $0x2b
  jmp alltraps
8010544d:	e9 49 fa ff ff       	jmp    80104e9b <alltraps>

80105452 <vector44>:
.globl vector44
vector44:
  pushl $0
80105452:	6a 00                	push   $0x0
  pushl $44
80105454:	6a 2c                	push   $0x2c
  jmp alltraps
80105456:	e9 40 fa ff ff       	jmp    80104e9b <alltraps>

8010545b <vector45>:
.globl vector45
vector45:
  pushl $0
8010545b:	6a 00                	push   $0x0
  pushl $45
8010545d:	6a 2d                	push   $0x2d
  jmp alltraps
8010545f:	e9 37 fa ff ff       	jmp    80104e9b <alltraps>

80105464 <vector46>:
.globl vector46
vector46:
  pushl $0
80105464:	6a 00                	push   $0x0
  pushl $46
80105466:	6a 2e                	push   $0x2e
  jmp alltraps
80105468:	e9 2e fa ff ff       	jmp    80104e9b <alltraps>

8010546d <vector47>:
.globl vector47
vector47:
  pushl $0
8010546d:	6a 00                	push   $0x0
  pushl $47
8010546f:	6a 2f                	push   $0x2f
  jmp alltraps
80105471:	e9 25 fa ff ff       	jmp    80104e9b <alltraps>

80105476 <vector48>:
.globl vector48
vector48:
  pushl $0
80105476:	6a 00                	push   $0x0
  pushl $48
80105478:	6a 30                	push   $0x30
  jmp alltraps
8010547a:	e9 1c fa ff ff       	jmp    80104e9b <alltraps>

8010547f <vector49>:
.globl vector49
vector49:
  pushl $0
8010547f:	6a 00                	push   $0x0
  pushl $49
80105481:	6a 31                	push   $0x31
  jmp alltraps
80105483:	e9 13 fa ff ff       	jmp    80104e9b <alltraps>

80105488 <vector50>:
.globl vector50
vector50:
  pushl $0
80105488:	6a 00                	push   $0x0
  pushl $50
8010548a:	6a 32                	push   $0x32
  jmp alltraps
8010548c:	e9 0a fa ff ff       	jmp    80104e9b <alltraps>

80105491 <vector51>:
.globl vector51
vector51:
  pushl $0
80105491:	6a 00                	push   $0x0
  pushl $51
80105493:	6a 33                	push   $0x33
  jmp alltraps
80105495:	e9 01 fa ff ff       	jmp    80104e9b <alltraps>

8010549a <vector52>:
.globl vector52
vector52:
  pushl $0
8010549a:	6a 00                	push   $0x0
  pushl $52
8010549c:	6a 34                	push   $0x34
  jmp alltraps
8010549e:	e9 f8 f9 ff ff       	jmp    80104e9b <alltraps>

801054a3 <vector53>:
.globl vector53
vector53:
  pushl $0
801054a3:	6a 00                	push   $0x0
  pushl $53
801054a5:	6a 35                	push   $0x35
  jmp alltraps
801054a7:	e9 ef f9 ff ff       	jmp    80104e9b <alltraps>

801054ac <vector54>:
.globl vector54
vector54:
  pushl $0
801054ac:	6a 00                	push   $0x0
  pushl $54
801054ae:	6a 36                	push   $0x36
  jmp alltraps
801054b0:	e9 e6 f9 ff ff       	jmp    80104e9b <alltraps>

801054b5 <vector55>:
.globl vector55
vector55:
  pushl $0
801054b5:	6a 00                	push   $0x0
  pushl $55
801054b7:	6a 37                	push   $0x37
  jmp alltraps
801054b9:	e9 dd f9 ff ff       	jmp    80104e9b <alltraps>

801054be <vector56>:
.globl vector56
vector56:
  pushl $0
801054be:	6a 00                	push   $0x0
  pushl $56
801054c0:	6a 38                	push   $0x38
  jmp alltraps
801054c2:	e9 d4 f9 ff ff       	jmp    80104e9b <alltraps>

801054c7 <vector57>:
.globl vector57
vector57:
  pushl $0
801054c7:	6a 00                	push   $0x0
  pushl $57
801054c9:	6a 39                	push   $0x39
  jmp alltraps
801054cb:	e9 cb f9 ff ff       	jmp    80104e9b <alltraps>

801054d0 <vector58>:
.globl vector58
vector58:
  pushl $0
801054d0:	6a 00                	push   $0x0
  pushl $58
801054d2:	6a 3a                	push   $0x3a
  jmp alltraps
801054d4:	e9 c2 f9 ff ff       	jmp    80104e9b <alltraps>

801054d9 <vector59>:
.globl vector59
vector59:
  pushl $0
801054d9:	6a 00                	push   $0x0
  pushl $59
801054db:	6a 3b                	push   $0x3b
  jmp alltraps
801054dd:	e9 b9 f9 ff ff       	jmp    80104e9b <alltraps>

801054e2 <vector60>:
.globl vector60
vector60:
  pushl $0
801054e2:	6a 00                	push   $0x0
  pushl $60
801054e4:	6a 3c                	push   $0x3c
  jmp alltraps
801054e6:	e9 b0 f9 ff ff       	jmp    80104e9b <alltraps>

801054eb <vector61>:
.globl vector61
vector61:
  pushl $0
801054eb:	6a 00                	push   $0x0
  pushl $61
801054ed:	6a 3d                	push   $0x3d
  jmp alltraps
801054ef:	e9 a7 f9 ff ff       	jmp    80104e9b <alltraps>

801054f4 <vector62>:
.globl vector62
vector62:
  pushl $0
801054f4:	6a 00                	push   $0x0
  pushl $62
801054f6:	6a 3e                	push   $0x3e
  jmp alltraps
801054f8:	e9 9e f9 ff ff       	jmp    80104e9b <alltraps>

801054fd <vector63>:
.globl vector63
vector63:
  pushl $0
801054fd:	6a 00                	push   $0x0
  pushl $63
801054ff:	6a 3f                	push   $0x3f
  jmp alltraps
80105501:	e9 95 f9 ff ff       	jmp    80104e9b <alltraps>

80105506 <vector64>:
.globl vector64
vector64:
  pushl $0
80105506:	6a 00                	push   $0x0
  pushl $64
80105508:	6a 40                	push   $0x40
  jmp alltraps
8010550a:	e9 8c f9 ff ff       	jmp    80104e9b <alltraps>

8010550f <vector65>:
.globl vector65
vector65:
  pushl $0
8010550f:	6a 00                	push   $0x0
  pushl $65
80105511:	6a 41                	push   $0x41
  jmp alltraps
80105513:	e9 83 f9 ff ff       	jmp    80104e9b <alltraps>

80105518 <vector66>:
.globl vector66
vector66:
  pushl $0
80105518:	6a 00                	push   $0x0
  pushl $66
8010551a:	6a 42                	push   $0x42
  jmp alltraps
8010551c:	e9 7a f9 ff ff       	jmp    80104e9b <alltraps>

80105521 <vector67>:
.globl vector67
vector67:
  pushl $0
80105521:	6a 00                	push   $0x0
  pushl $67
80105523:	6a 43                	push   $0x43
  jmp alltraps
80105525:	e9 71 f9 ff ff       	jmp    80104e9b <alltraps>

8010552a <vector68>:
.globl vector68
vector68:
  pushl $0
8010552a:	6a 00                	push   $0x0
  pushl $68
8010552c:	6a 44                	push   $0x44
  jmp alltraps
8010552e:	e9 68 f9 ff ff       	jmp    80104e9b <alltraps>

80105533 <vector69>:
.globl vector69
vector69:
  pushl $0
80105533:	6a 00                	push   $0x0
  pushl $69
80105535:	6a 45                	push   $0x45
  jmp alltraps
80105537:	e9 5f f9 ff ff       	jmp    80104e9b <alltraps>

8010553c <vector70>:
.globl vector70
vector70:
  pushl $0
8010553c:	6a 00                	push   $0x0
  pushl $70
8010553e:	6a 46                	push   $0x46
  jmp alltraps
80105540:	e9 56 f9 ff ff       	jmp    80104e9b <alltraps>

80105545 <vector71>:
.globl vector71
vector71:
  pushl $0
80105545:	6a 00                	push   $0x0
  pushl $71
80105547:	6a 47                	push   $0x47
  jmp alltraps
80105549:	e9 4d f9 ff ff       	jmp    80104e9b <alltraps>

8010554e <vector72>:
.globl vector72
vector72:
  pushl $0
8010554e:	6a 00                	push   $0x0
  pushl $72
80105550:	6a 48                	push   $0x48
  jmp alltraps
80105552:	e9 44 f9 ff ff       	jmp    80104e9b <alltraps>

80105557 <vector73>:
.globl vector73
vector73:
  pushl $0
80105557:	6a 00                	push   $0x0
  pushl $73
80105559:	6a 49                	push   $0x49
  jmp alltraps
8010555b:	e9 3b f9 ff ff       	jmp    80104e9b <alltraps>

80105560 <vector74>:
.globl vector74
vector74:
  pushl $0
80105560:	6a 00                	push   $0x0
  pushl $74
80105562:	6a 4a                	push   $0x4a
  jmp alltraps
80105564:	e9 32 f9 ff ff       	jmp    80104e9b <alltraps>

80105569 <vector75>:
.globl vector75
vector75:
  pushl $0
80105569:	6a 00                	push   $0x0
  pushl $75
8010556b:	6a 4b                	push   $0x4b
  jmp alltraps
8010556d:	e9 29 f9 ff ff       	jmp    80104e9b <alltraps>

80105572 <vector76>:
.globl vector76
vector76:
  pushl $0
80105572:	6a 00                	push   $0x0
  pushl $76
80105574:	6a 4c                	push   $0x4c
  jmp alltraps
80105576:	e9 20 f9 ff ff       	jmp    80104e9b <alltraps>

8010557b <vector77>:
.globl vector77
vector77:
  pushl $0
8010557b:	6a 00                	push   $0x0
  pushl $77
8010557d:	6a 4d                	push   $0x4d
  jmp alltraps
8010557f:	e9 17 f9 ff ff       	jmp    80104e9b <alltraps>

80105584 <vector78>:
.globl vector78
vector78:
  pushl $0
80105584:	6a 00                	push   $0x0
  pushl $78
80105586:	6a 4e                	push   $0x4e
  jmp alltraps
80105588:	e9 0e f9 ff ff       	jmp    80104e9b <alltraps>

8010558d <vector79>:
.globl vector79
vector79:
  pushl $0
8010558d:	6a 00                	push   $0x0
  pushl $79
8010558f:	6a 4f                	push   $0x4f
  jmp alltraps
80105591:	e9 05 f9 ff ff       	jmp    80104e9b <alltraps>

80105596 <vector80>:
.globl vector80
vector80:
  pushl $0
80105596:	6a 00                	push   $0x0
  pushl $80
80105598:	6a 50                	push   $0x50
  jmp alltraps
8010559a:	e9 fc f8 ff ff       	jmp    80104e9b <alltraps>

8010559f <vector81>:
.globl vector81
vector81:
  pushl $0
8010559f:	6a 00                	push   $0x0
  pushl $81
801055a1:	6a 51                	push   $0x51
  jmp alltraps
801055a3:	e9 f3 f8 ff ff       	jmp    80104e9b <alltraps>

801055a8 <vector82>:
.globl vector82
vector82:
  pushl $0
801055a8:	6a 00                	push   $0x0
  pushl $82
801055aa:	6a 52                	push   $0x52
  jmp alltraps
801055ac:	e9 ea f8 ff ff       	jmp    80104e9b <alltraps>

801055b1 <vector83>:
.globl vector83
vector83:
  pushl $0
801055b1:	6a 00                	push   $0x0
  pushl $83
801055b3:	6a 53                	push   $0x53
  jmp alltraps
801055b5:	e9 e1 f8 ff ff       	jmp    80104e9b <alltraps>

801055ba <vector84>:
.globl vector84
vector84:
  pushl $0
801055ba:	6a 00                	push   $0x0
  pushl $84
801055bc:	6a 54                	push   $0x54
  jmp alltraps
801055be:	e9 d8 f8 ff ff       	jmp    80104e9b <alltraps>

801055c3 <vector85>:
.globl vector85
vector85:
  pushl $0
801055c3:	6a 00                	push   $0x0
  pushl $85
801055c5:	6a 55                	push   $0x55
  jmp alltraps
801055c7:	e9 cf f8 ff ff       	jmp    80104e9b <alltraps>

801055cc <vector86>:
.globl vector86
vector86:
  pushl $0
801055cc:	6a 00                	push   $0x0
  pushl $86
801055ce:	6a 56                	push   $0x56
  jmp alltraps
801055d0:	e9 c6 f8 ff ff       	jmp    80104e9b <alltraps>

801055d5 <vector87>:
.globl vector87
vector87:
  pushl $0
801055d5:	6a 00                	push   $0x0
  pushl $87
801055d7:	6a 57                	push   $0x57
  jmp alltraps
801055d9:	e9 bd f8 ff ff       	jmp    80104e9b <alltraps>

801055de <vector88>:
.globl vector88
vector88:
  pushl $0
801055de:	6a 00                	push   $0x0
  pushl $88
801055e0:	6a 58                	push   $0x58
  jmp alltraps
801055e2:	e9 b4 f8 ff ff       	jmp    80104e9b <alltraps>

801055e7 <vector89>:
.globl vector89
vector89:
  pushl $0
801055e7:	6a 00                	push   $0x0
  pushl $89
801055e9:	6a 59                	push   $0x59
  jmp alltraps
801055eb:	e9 ab f8 ff ff       	jmp    80104e9b <alltraps>

801055f0 <vector90>:
.globl vector90
vector90:
  pushl $0
801055f0:	6a 00                	push   $0x0
  pushl $90
801055f2:	6a 5a                	push   $0x5a
  jmp alltraps
801055f4:	e9 a2 f8 ff ff       	jmp    80104e9b <alltraps>

801055f9 <vector91>:
.globl vector91
vector91:
  pushl $0
801055f9:	6a 00                	push   $0x0
  pushl $91
801055fb:	6a 5b                	push   $0x5b
  jmp alltraps
801055fd:	e9 99 f8 ff ff       	jmp    80104e9b <alltraps>

80105602 <vector92>:
.globl vector92
vector92:
  pushl $0
80105602:	6a 00                	push   $0x0
  pushl $92
80105604:	6a 5c                	push   $0x5c
  jmp alltraps
80105606:	e9 90 f8 ff ff       	jmp    80104e9b <alltraps>

8010560b <vector93>:
.globl vector93
vector93:
  pushl $0
8010560b:	6a 00                	push   $0x0
  pushl $93
8010560d:	6a 5d                	push   $0x5d
  jmp alltraps
8010560f:	e9 87 f8 ff ff       	jmp    80104e9b <alltraps>

80105614 <vector94>:
.globl vector94
vector94:
  pushl $0
80105614:	6a 00                	push   $0x0
  pushl $94
80105616:	6a 5e                	push   $0x5e
  jmp alltraps
80105618:	e9 7e f8 ff ff       	jmp    80104e9b <alltraps>

8010561d <vector95>:
.globl vector95
vector95:
  pushl $0
8010561d:	6a 00                	push   $0x0
  pushl $95
8010561f:	6a 5f                	push   $0x5f
  jmp alltraps
80105621:	e9 75 f8 ff ff       	jmp    80104e9b <alltraps>

80105626 <vector96>:
.globl vector96
vector96:
  pushl $0
80105626:	6a 00                	push   $0x0
  pushl $96
80105628:	6a 60                	push   $0x60
  jmp alltraps
8010562a:	e9 6c f8 ff ff       	jmp    80104e9b <alltraps>

8010562f <vector97>:
.globl vector97
vector97:
  pushl $0
8010562f:	6a 00                	push   $0x0
  pushl $97
80105631:	6a 61                	push   $0x61
  jmp alltraps
80105633:	e9 63 f8 ff ff       	jmp    80104e9b <alltraps>

80105638 <vector98>:
.globl vector98
vector98:
  pushl $0
80105638:	6a 00                	push   $0x0
  pushl $98
8010563a:	6a 62                	push   $0x62
  jmp alltraps
8010563c:	e9 5a f8 ff ff       	jmp    80104e9b <alltraps>

80105641 <vector99>:
.globl vector99
vector99:
  pushl $0
80105641:	6a 00                	push   $0x0
  pushl $99
80105643:	6a 63                	push   $0x63
  jmp alltraps
80105645:	e9 51 f8 ff ff       	jmp    80104e9b <alltraps>

8010564a <vector100>:
.globl vector100
vector100:
  pushl $0
8010564a:	6a 00                	push   $0x0
  pushl $100
8010564c:	6a 64                	push   $0x64
  jmp alltraps
8010564e:	e9 48 f8 ff ff       	jmp    80104e9b <alltraps>

80105653 <vector101>:
.globl vector101
vector101:
  pushl $0
80105653:	6a 00                	push   $0x0
  pushl $101
80105655:	6a 65                	push   $0x65
  jmp alltraps
80105657:	e9 3f f8 ff ff       	jmp    80104e9b <alltraps>

8010565c <vector102>:
.globl vector102
vector102:
  pushl $0
8010565c:	6a 00                	push   $0x0
  pushl $102
8010565e:	6a 66                	push   $0x66
  jmp alltraps
80105660:	e9 36 f8 ff ff       	jmp    80104e9b <alltraps>

80105665 <vector103>:
.globl vector103
vector103:
  pushl $0
80105665:	6a 00                	push   $0x0
  pushl $103
80105667:	6a 67                	push   $0x67
  jmp alltraps
80105669:	e9 2d f8 ff ff       	jmp    80104e9b <alltraps>

8010566e <vector104>:
.globl vector104
vector104:
  pushl $0
8010566e:	6a 00                	push   $0x0
  pushl $104
80105670:	6a 68                	push   $0x68
  jmp alltraps
80105672:	e9 24 f8 ff ff       	jmp    80104e9b <alltraps>

80105677 <vector105>:
.globl vector105
vector105:
  pushl $0
80105677:	6a 00                	push   $0x0
  pushl $105
80105679:	6a 69                	push   $0x69
  jmp alltraps
8010567b:	e9 1b f8 ff ff       	jmp    80104e9b <alltraps>

80105680 <vector106>:
.globl vector106
vector106:
  pushl $0
80105680:	6a 00                	push   $0x0
  pushl $106
80105682:	6a 6a                	push   $0x6a
  jmp alltraps
80105684:	e9 12 f8 ff ff       	jmp    80104e9b <alltraps>

80105689 <vector107>:
.globl vector107
vector107:
  pushl $0
80105689:	6a 00                	push   $0x0
  pushl $107
8010568b:	6a 6b                	push   $0x6b
  jmp alltraps
8010568d:	e9 09 f8 ff ff       	jmp    80104e9b <alltraps>

80105692 <vector108>:
.globl vector108
vector108:
  pushl $0
80105692:	6a 00                	push   $0x0
  pushl $108
80105694:	6a 6c                	push   $0x6c
  jmp alltraps
80105696:	e9 00 f8 ff ff       	jmp    80104e9b <alltraps>

8010569b <vector109>:
.globl vector109
vector109:
  pushl $0
8010569b:	6a 00                	push   $0x0
  pushl $109
8010569d:	6a 6d                	push   $0x6d
  jmp alltraps
8010569f:	e9 f7 f7 ff ff       	jmp    80104e9b <alltraps>

801056a4 <vector110>:
.globl vector110
vector110:
  pushl $0
801056a4:	6a 00                	push   $0x0
  pushl $110
801056a6:	6a 6e                	push   $0x6e
  jmp alltraps
801056a8:	e9 ee f7 ff ff       	jmp    80104e9b <alltraps>

801056ad <vector111>:
.globl vector111
vector111:
  pushl $0
801056ad:	6a 00                	push   $0x0
  pushl $111
801056af:	6a 6f                	push   $0x6f
  jmp alltraps
801056b1:	e9 e5 f7 ff ff       	jmp    80104e9b <alltraps>

801056b6 <vector112>:
.globl vector112
vector112:
  pushl $0
801056b6:	6a 00                	push   $0x0
  pushl $112
801056b8:	6a 70                	push   $0x70
  jmp alltraps
801056ba:	e9 dc f7 ff ff       	jmp    80104e9b <alltraps>

801056bf <vector113>:
.globl vector113
vector113:
  pushl $0
801056bf:	6a 00                	push   $0x0
  pushl $113
801056c1:	6a 71                	push   $0x71
  jmp alltraps
801056c3:	e9 d3 f7 ff ff       	jmp    80104e9b <alltraps>

801056c8 <vector114>:
.globl vector114
vector114:
  pushl $0
801056c8:	6a 00                	push   $0x0
  pushl $114
801056ca:	6a 72                	push   $0x72
  jmp alltraps
801056cc:	e9 ca f7 ff ff       	jmp    80104e9b <alltraps>

801056d1 <vector115>:
.globl vector115
vector115:
  pushl $0
801056d1:	6a 00                	push   $0x0
  pushl $115
801056d3:	6a 73                	push   $0x73
  jmp alltraps
801056d5:	e9 c1 f7 ff ff       	jmp    80104e9b <alltraps>

801056da <vector116>:
.globl vector116
vector116:
  pushl $0
801056da:	6a 00                	push   $0x0
  pushl $116
801056dc:	6a 74                	push   $0x74
  jmp alltraps
801056de:	e9 b8 f7 ff ff       	jmp    80104e9b <alltraps>

801056e3 <vector117>:
.globl vector117
vector117:
  pushl $0
801056e3:	6a 00                	push   $0x0
  pushl $117
801056e5:	6a 75                	push   $0x75
  jmp alltraps
801056e7:	e9 af f7 ff ff       	jmp    80104e9b <alltraps>

801056ec <vector118>:
.globl vector118
vector118:
  pushl $0
801056ec:	6a 00                	push   $0x0
  pushl $118
801056ee:	6a 76                	push   $0x76
  jmp alltraps
801056f0:	e9 a6 f7 ff ff       	jmp    80104e9b <alltraps>

801056f5 <vector119>:
.globl vector119
vector119:
  pushl $0
801056f5:	6a 00                	push   $0x0
  pushl $119
801056f7:	6a 77                	push   $0x77
  jmp alltraps
801056f9:	e9 9d f7 ff ff       	jmp    80104e9b <alltraps>

801056fe <vector120>:
.globl vector120
vector120:
  pushl $0
801056fe:	6a 00                	push   $0x0
  pushl $120
80105700:	6a 78                	push   $0x78
  jmp alltraps
80105702:	e9 94 f7 ff ff       	jmp    80104e9b <alltraps>

80105707 <vector121>:
.globl vector121
vector121:
  pushl $0
80105707:	6a 00                	push   $0x0
  pushl $121
80105709:	6a 79                	push   $0x79
  jmp alltraps
8010570b:	e9 8b f7 ff ff       	jmp    80104e9b <alltraps>

80105710 <vector122>:
.globl vector122
vector122:
  pushl $0
80105710:	6a 00                	push   $0x0
  pushl $122
80105712:	6a 7a                	push   $0x7a
  jmp alltraps
80105714:	e9 82 f7 ff ff       	jmp    80104e9b <alltraps>

80105719 <vector123>:
.globl vector123
vector123:
  pushl $0
80105719:	6a 00                	push   $0x0
  pushl $123
8010571b:	6a 7b                	push   $0x7b
  jmp alltraps
8010571d:	e9 79 f7 ff ff       	jmp    80104e9b <alltraps>

80105722 <vector124>:
.globl vector124
vector124:
  pushl $0
80105722:	6a 00                	push   $0x0
  pushl $124
80105724:	6a 7c                	push   $0x7c
  jmp alltraps
80105726:	e9 70 f7 ff ff       	jmp    80104e9b <alltraps>

8010572b <vector125>:
.globl vector125
vector125:
  pushl $0
8010572b:	6a 00                	push   $0x0
  pushl $125
8010572d:	6a 7d                	push   $0x7d
  jmp alltraps
8010572f:	e9 67 f7 ff ff       	jmp    80104e9b <alltraps>

80105734 <vector126>:
.globl vector126
vector126:
  pushl $0
80105734:	6a 00                	push   $0x0
  pushl $126
80105736:	6a 7e                	push   $0x7e
  jmp alltraps
80105738:	e9 5e f7 ff ff       	jmp    80104e9b <alltraps>

8010573d <vector127>:
.globl vector127
vector127:
  pushl $0
8010573d:	6a 00                	push   $0x0
  pushl $127
8010573f:	6a 7f                	push   $0x7f
  jmp alltraps
80105741:	e9 55 f7 ff ff       	jmp    80104e9b <alltraps>

80105746 <vector128>:
.globl vector128
vector128:
  pushl $0
80105746:	6a 00                	push   $0x0
  pushl $128
80105748:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010574d:	e9 49 f7 ff ff       	jmp    80104e9b <alltraps>

80105752 <vector129>:
.globl vector129
vector129:
  pushl $0
80105752:	6a 00                	push   $0x0
  pushl $129
80105754:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105759:	e9 3d f7 ff ff       	jmp    80104e9b <alltraps>

8010575e <vector130>:
.globl vector130
vector130:
  pushl $0
8010575e:	6a 00                	push   $0x0
  pushl $130
80105760:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105765:	e9 31 f7 ff ff       	jmp    80104e9b <alltraps>

8010576a <vector131>:
.globl vector131
vector131:
  pushl $0
8010576a:	6a 00                	push   $0x0
  pushl $131
8010576c:	68 83 00 00 00       	push   $0x83
  jmp alltraps
80105771:	e9 25 f7 ff ff       	jmp    80104e9b <alltraps>

80105776 <vector132>:
.globl vector132
vector132:
  pushl $0
80105776:	6a 00                	push   $0x0
  pushl $132
80105778:	68 84 00 00 00       	push   $0x84
  jmp alltraps
8010577d:	e9 19 f7 ff ff       	jmp    80104e9b <alltraps>

80105782 <vector133>:
.globl vector133
vector133:
  pushl $0
80105782:	6a 00                	push   $0x0
  pushl $133
80105784:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105789:	e9 0d f7 ff ff       	jmp    80104e9b <alltraps>

8010578e <vector134>:
.globl vector134
vector134:
  pushl $0
8010578e:	6a 00                	push   $0x0
  pushl $134
80105790:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105795:	e9 01 f7 ff ff       	jmp    80104e9b <alltraps>

8010579a <vector135>:
.globl vector135
vector135:
  pushl $0
8010579a:	6a 00                	push   $0x0
  pushl $135
8010579c:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801057a1:	e9 f5 f6 ff ff       	jmp    80104e9b <alltraps>

801057a6 <vector136>:
.globl vector136
vector136:
  pushl $0
801057a6:	6a 00                	push   $0x0
  pushl $136
801057a8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801057ad:	e9 e9 f6 ff ff       	jmp    80104e9b <alltraps>

801057b2 <vector137>:
.globl vector137
vector137:
  pushl $0
801057b2:	6a 00                	push   $0x0
  pushl $137
801057b4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801057b9:	e9 dd f6 ff ff       	jmp    80104e9b <alltraps>

801057be <vector138>:
.globl vector138
vector138:
  pushl $0
801057be:	6a 00                	push   $0x0
  pushl $138
801057c0:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801057c5:	e9 d1 f6 ff ff       	jmp    80104e9b <alltraps>

801057ca <vector139>:
.globl vector139
vector139:
  pushl $0
801057ca:	6a 00                	push   $0x0
  pushl $139
801057cc:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801057d1:	e9 c5 f6 ff ff       	jmp    80104e9b <alltraps>

801057d6 <vector140>:
.globl vector140
vector140:
  pushl $0
801057d6:	6a 00                	push   $0x0
  pushl $140
801057d8:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801057dd:	e9 b9 f6 ff ff       	jmp    80104e9b <alltraps>

801057e2 <vector141>:
.globl vector141
vector141:
  pushl $0
801057e2:	6a 00                	push   $0x0
  pushl $141
801057e4:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801057e9:	e9 ad f6 ff ff       	jmp    80104e9b <alltraps>

801057ee <vector142>:
.globl vector142
vector142:
  pushl $0
801057ee:	6a 00                	push   $0x0
  pushl $142
801057f0:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801057f5:	e9 a1 f6 ff ff       	jmp    80104e9b <alltraps>

801057fa <vector143>:
.globl vector143
vector143:
  pushl $0
801057fa:	6a 00                	push   $0x0
  pushl $143
801057fc:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105801:	e9 95 f6 ff ff       	jmp    80104e9b <alltraps>

80105806 <vector144>:
.globl vector144
vector144:
  pushl $0
80105806:	6a 00                	push   $0x0
  pushl $144
80105808:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010580d:	e9 89 f6 ff ff       	jmp    80104e9b <alltraps>

80105812 <vector145>:
.globl vector145
vector145:
  pushl $0
80105812:	6a 00                	push   $0x0
  pushl $145
80105814:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105819:	e9 7d f6 ff ff       	jmp    80104e9b <alltraps>

8010581e <vector146>:
.globl vector146
vector146:
  pushl $0
8010581e:	6a 00                	push   $0x0
  pushl $146
80105820:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105825:	e9 71 f6 ff ff       	jmp    80104e9b <alltraps>

8010582a <vector147>:
.globl vector147
vector147:
  pushl $0
8010582a:	6a 00                	push   $0x0
  pushl $147
8010582c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105831:	e9 65 f6 ff ff       	jmp    80104e9b <alltraps>

80105836 <vector148>:
.globl vector148
vector148:
  pushl $0
80105836:	6a 00                	push   $0x0
  pushl $148
80105838:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010583d:	e9 59 f6 ff ff       	jmp    80104e9b <alltraps>

80105842 <vector149>:
.globl vector149
vector149:
  pushl $0
80105842:	6a 00                	push   $0x0
  pushl $149
80105844:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105849:	e9 4d f6 ff ff       	jmp    80104e9b <alltraps>

8010584e <vector150>:
.globl vector150
vector150:
  pushl $0
8010584e:	6a 00                	push   $0x0
  pushl $150
80105850:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105855:	e9 41 f6 ff ff       	jmp    80104e9b <alltraps>

8010585a <vector151>:
.globl vector151
vector151:
  pushl $0
8010585a:	6a 00                	push   $0x0
  pushl $151
8010585c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105861:	e9 35 f6 ff ff       	jmp    80104e9b <alltraps>

80105866 <vector152>:
.globl vector152
vector152:
  pushl $0
80105866:	6a 00                	push   $0x0
  pushl $152
80105868:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010586d:	e9 29 f6 ff ff       	jmp    80104e9b <alltraps>

80105872 <vector153>:
.globl vector153
vector153:
  pushl $0
80105872:	6a 00                	push   $0x0
  pushl $153
80105874:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105879:	e9 1d f6 ff ff       	jmp    80104e9b <alltraps>

8010587e <vector154>:
.globl vector154
vector154:
  pushl $0
8010587e:	6a 00                	push   $0x0
  pushl $154
80105880:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105885:	e9 11 f6 ff ff       	jmp    80104e9b <alltraps>

8010588a <vector155>:
.globl vector155
vector155:
  pushl $0
8010588a:	6a 00                	push   $0x0
  pushl $155
8010588c:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
80105891:	e9 05 f6 ff ff       	jmp    80104e9b <alltraps>

80105896 <vector156>:
.globl vector156
vector156:
  pushl $0
80105896:	6a 00                	push   $0x0
  pushl $156
80105898:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
8010589d:	e9 f9 f5 ff ff       	jmp    80104e9b <alltraps>

801058a2 <vector157>:
.globl vector157
vector157:
  pushl $0
801058a2:	6a 00                	push   $0x0
  pushl $157
801058a4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801058a9:	e9 ed f5 ff ff       	jmp    80104e9b <alltraps>

801058ae <vector158>:
.globl vector158
vector158:
  pushl $0
801058ae:	6a 00                	push   $0x0
  pushl $158
801058b0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801058b5:	e9 e1 f5 ff ff       	jmp    80104e9b <alltraps>

801058ba <vector159>:
.globl vector159
vector159:
  pushl $0
801058ba:	6a 00                	push   $0x0
  pushl $159
801058bc:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801058c1:	e9 d5 f5 ff ff       	jmp    80104e9b <alltraps>

801058c6 <vector160>:
.globl vector160
vector160:
  pushl $0
801058c6:	6a 00                	push   $0x0
  pushl $160
801058c8:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801058cd:	e9 c9 f5 ff ff       	jmp    80104e9b <alltraps>

801058d2 <vector161>:
.globl vector161
vector161:
  pushl $0
801058d2:	6a 00                	push   $0x0
  pushl $161
801058d4:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801058d9:	e9 bd f5 ff ff       	jmp    80104e9b <alltraps>

801058de <vector162>:
.globl vector162
vector162:
  pushl $0
801058de:	6a 00                	push   $0x0
  pushl $162
801058e0:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801058e5:	e9 b1 f5 ff ff       	jmp    80104e9b <alltraps>

801058ea <vector163>:
.globl vector163
vector163:
  pushl $0
801058ea:	6a 00                	push   $0x0
  pushl $163
801058ec:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801058f1:	e9 a5 f5 ff ff       	jmp    80104e9b <alltraps>

801058f6 <vector164>:
.globl vector164
vector164:
  pushl $0
801058f6:	6a 00                	push   $0x0
  pushl $164
801058f8:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
801058fd:	e9 99 f5 ff ff       	jmp    80104e9b <alltraps>

80105902 <vector165>:
.globl vector165
vector165:
  pushl $0
80105902:	6a 00                	push   $0x0
  pushl $165
80105904:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105909:	e9 8d f5 ff ff       	jmp    80104e9b <alltraps>

8010590e <vector166>:
.globl vector166
vector166:
  pushl $0
8010590e:	6a 00                	push   $0x0
  pushl $166
80105910:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105915:	e9 81 f5 ff ff       	jmp    80104e9b <alltraps>

8010591a <vector167>:
.globl vector167
vector167:
  pushl $0
8010591a:	6a 00                	push   $0x0
  pushl $167
8010591c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105921:	e9 75 f5 ff ff       	jmp    80104e9b <alltraps>

80105926 <vector168>:
.globl vector168
vector168:
  pushl $0
80105926:	6a 00                	push   $0x0
  pushl $168
80105928:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010592d:	e9 69 f5 ff ff       	jmp    80104e9b <alltraps>

80105932 <vector169>:
.globl vector169
vector169:
  pushl $0
80105932:	6a 00                	push   $0x0
  pushl $169
80105934:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105939:	e9 5d f5 ff ff       	jmp    80104e9b <alltraps>

8010593e <vector170>:
.globl vector170
vector170:
  pushl $0
8010593e:	6a 00                	push   $0x0
  pushl $170
80105940:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105945:	e9 51 f5 ff ff       	jmp    80104e9b <alltraps>

8010594a <vector171>:
.globl vector171
vector171:
  pushl $0
8010594a:	6a 00                	push   $0x0
  pushl $171
8010594c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105951:	e9 45 f5 ff ff       	jmp    80104e9b <alltraps>

80105956 <vector172>:
.globl vector172
vector172:
  pushl $0
80105956:	6a 00                	push   $0x0
  pushl $172
80105958:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010595d:	e9 39 f5 ff ff       	jmp    80104e9b <alltraps>

80105962 <vector173>:
.globl vector173
vector173:
  pushl $0
80105962:	6a 00                	push   $0x0
  pushl $173
80105964:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105969:	e9 2d f5 ff ff       	jmp    80104e9b <alltraps>

8010596e <vector174>:
.globl vector174
vector174:
  pushl $0
8010596e:	6a 00                	push   $0x0
  pushl $174
80105970:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105975:	e9 21 f5 ff ff       	jmp    80104e9b <alltraps>

8010597a <vector175>:
.globl vector175
vector175:
  pushl $0
8010597a:	6a 00                	push   $0x0
  pushl $175
8010597c:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105981:	e9 15 f5 ff ff       	jmp    80104e9b <alltraps>

80105986 <vector176>:
.globl vector176
vector176:
  pushl $0
80105986:	6a 00                	push   $0x0
  pushl $176
80105988:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
8010598d:	e9 09 f5 ff ff       	jmp    80104e9b <alltraps>

80105992 <vector177>:
.globl vector177
vector177:
  pushl $0
80105992:	6a 00                	push   $0x0
  pushl $177
80105994:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105999:	e9 fd f4 ff ff       	jmp    80104e9b <alltraps>

8010599e <vector178>:
.globl vector178
vector178:
  pushl $0
8010599e:	6a 00                	push   $0x0
  pushl $178
801059a0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801059a5:	e9 f1 f4 ff ff       	jmp    80104e9b <alltraps>

801059aa <vector179>:
.globl vector179
vector179:
  pushl $0
801059aa:	6a 00                	push   $0x0
  pushl $179
801059ac:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801059b1:	e9 e5 f4 ff ff       	jmp    80104e9b <alltraps>

801059b6 <vector180>:
.globl vector180
vector180:
  pushl $0
801059b6:	6a 00                	push   $0x0
  pushl $180
801059b8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801059bd:	e9 d9 f4 ff ff       	jmp    80104e9b <alltraps>

801059c2 <vector181>:
.globl vector181
vector181:
  pushl $0
801059c2:	6a 00                	push   $0x0
  pushl $181
801059c4:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801059c9:	e9 cd f4 ff ff       	jmp    80104e9b <alltraps>

801059ce <vector182>:
.globl vector182
vector182:
  pushl $0
801059ce:	6a 00                	push   $0x0
  pushl $182
801059d0:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801059d5:	e9 c1 f4 ff ff       	jmp    80104e9b <alltraps>

801059da <vector183>:
.globl vector183
vector183:
  pushl $0
801059da:	6a 00                	push   $0x0
  pushl $183
801059dc:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801059e1:	e9 b5 f4 ff ff       	jmp    80104e9b <alltraps>

801059e6 <vector184>:
.globl vector184
vector184:
  pushl $0
801059e6:	6a 00                	push   $0x0
  pushl $184
801059e8:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801059ed:	e9 a9 f4 ff ff       	jmp    80104e9b <alltraps>

801059f2 <vector185>:
.globl vector185
vector185:
  pushl $0
801059f2:	6a 00                	push   $0x0
  pushl $185
801059f4:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
801059f9:	e9 9d f4 ff ff       	jmp    80104e9b <alltraps>

801059fe <vector186>:
.globl vector186
vector186:
  pushl $0
801059fe:	6a 00                	push   $0x0
  pushl $186
80105a00:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105a05:	e9 91 f4 ff ff       	jmp    80104e9b <alltraps>

80105a0a <vector187>:
.globl vector187
vector187:
  pushl $0
80105a0a:	6a 00                	push   $0x0
  pushl $187
80105a0c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a11:	e9 85 f4 ff ff       	jmp    80104e9b <alltraps>

80105a16 <vector188>:
.globl vector188
vector188:
  pushl $0
80105a16:	6a 00                	push   $0x0
  pushl $188
80105a18:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a1d:	e9 79 f4 ff ff       	jmp    80104e9b <alltraps>

80105a22 <vector189>:
.globl vector189
vector189:
  pushl $0
80105a22:	6a 00                	push   $0x0
  pushl $189
80105a24:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105a29:	e9 6d f4 ff ff       	jmp    80104e9b <alltraps>

80105a2e <vector190>:
.globl vector190
vector190:
  pushl $0
80105a2e:	6a 00                	push   $0x0
  pushl $190
80105a30:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105a35:	e9 61 f4 ff ff       	jmp    80104e9b <alltraps>

80105a3a <vector191>:
.globl vector191
vector191:
  pushl $0
80105a3a:	6a 00                	push   $0x0
  pushl $191
80105a3c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105a41:	e9 55 f4 ff ff       	jmp    80104e9b <alltraps>

80105a46 <vector192>:
.globl vector192
vector192:
  pushl $0
80105a46:	6a 00                	push   $0x0
  pushl $192
80105a48:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105a4d:	e9 49 f4 ff ff       	jmp    80104e9b <alltraps>

80105a52 <vector193>:
.globl vector193
vector193:
  pushl $0
80105a52:	6a 00                	push   $0x0
  pushl $193
80105a54:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105a59:	e9 3d f4 ff ff       	jmp    80104e9b <alltraps>

80105a5e <vector194>:
.globl vector194
vector194:
  pushl $0
80105a5e:	6a 00                	push   $0x0
  pushl $194
80105a60:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105a65:	e9 31 f4 ff ff       	jmp    80104e9b <alltraps>

80105a6a <vector195>:
.globl vector195
vector195:
  pushl $0
80105a6a:	6a 00                	push   $0x0
  pushl $195
80105a6c:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105a71:	e9 25 f4 ff ff       	jmp    80104e9b <alltraps>

80105a76 <vector196>:
.globl vector196
vector196:
  pushl $0
80105a76:	6a 00                	push   $0x0
  pushl $196
80105a78:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105a7d:	e9 19 f4 ff ff       	jmp    80104e9b <alltraps>

80105a82 <vector197>:
.globl vector197
vector197:
  pushl $0
80105a82:	6a 00                	push   $0x0
  pushl $197
80105a84:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105a89:	e9 0d f4 ff ff       	jmp    80104e9b <alltraps>

80105a8e <vector198>:
.globl vector198
vector198:
  pushl $0
80105a8e:	6a 00                	push   $0x0
  pushl $198
80105a90:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105a95:	e9 01 f4 ff ff       	jmp    80104e9b <alltraps>

80105a9a <vector199>:
.globl vector199
vector199:
  pushl $0
80105a9a:	6a 00                	push   $0x0
  pushl $199
80105a9c:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105aa1:	e9 f5 f3 ff ff       	jmp    80104e9b <alltraps>

80105aa6 <vector200>:
.globl vector200
vector200:
  pushl $0
80105aa6:	6a 00                	push   $0x0
  pushl $200
80105aa8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105aad:	e9 e9 f3 ff ff       	jmp    80104e9b <alltraps>

80105ab2 <vector201>:
.globl vector201
vector201:
  pushl $0
80105ab2:	6a 00                	push   $0x0
  pushl $201
80105ab4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105ab9:	e9 dd f3 ff ff       	jmp    80104e9b <alltraps>

80105abe <vector202>:
.globl vector202
vector202:
  pushl $0
80105abe:	6a 00                	push   $0x0
  pushl $202
80105ac0:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105ac5:	e9 d1 f3 ff ff       	jmp    80104e9b <alltraps>

80105aca <vector203>:
.globl vector203
vector203:
  pushl $0
80105aca:	6a 00                	push   $0x0
  pushl $203
80105acc:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105ad1:	e9 c5 f3 ff ff       	jmp    80104e9b <alltraps>

80105ad6 <vector204>:
.globl vector204
vector204:
  pushl $0
80105ad6:	6a 00                	push   $0x0
  pushl $204
80105ad8:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105add:	e9 b9 f3 ff ff       	jmp    80104e9b <alltraps>

80105ae2 <vector205>:
.globl vector205
vector205:
  pushl $0
80105ae2:	6a 00                	push   $0x0
  pushl $205
80105ae4:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105ae9:	e9 ad f3 ff ff       	jmp    80104e9b <alltraps>

80105aee <vector206>:
.globl vector206
vector206:
  pushl $0
80105aee:	6a 00                	push   $0x0
  pushl $206
80105af0:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105af5:	e9 a1 f3 ff ff       	jmp    80104e9b <alltraps>

80105afa <vector207>:
.globl vector207
vector207:
  pushl $0
80105afa:	6a 00                	push   $0x0
  pushl $207
80105afc:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105b01:	e9 95 f3 ff ff       	jmp    80104e9b <alltraps>

80105b06 <vector208>:
.globl vector208
vector208:
  pushl $0
80105b06:	6a 00                	push   $0x0
  pushl $208
80105b08:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b0d:	e9 89 f3 ff ff       	jmp    80104e9b <alltraps>

80105b12 <vector209>:
.globl vector209
vector209:
  pushl $0
80105b12:	6a 00                	push   $0x0
  pushl $209
80105b14:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b19:	e9 7d f3 ff ff       	jmp    80104e9b <alltraps>

80105b1e <vector210>:
.globl vector210
vector210:
  pushl $0
80105b1e:	6a 00                	push   $0x0
  pushl $210
80105b20:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105b25:	e9 71 f3 ff ff       	jmp    80104e9b <alltraps>

80105b2a <vector211>:
.globl vector211
vector211:
  pushl $0
80105b2a:	6a 00                	push   $0x0
  pushl $211
80105b2c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105b31:	e9 65 f3 ff ff       	jmp    80104e9b <alltraps>

80105b36 <vector212>:
.globl vector212
vector212:
  pushl $0
80105b36:	6a 00                	push   $0x0
  pushl $212
80105b38:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105b3d:	e9 59 f3 ff ff       	jmp    80104e9b <alltraps>

80105b42 <vector213>:
.globl vector213
vector213:
  pushl $0
80105b42:	6a 00                	push   $0x0
  pushl $213
80105b44:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105b49:	e9 4d f3 ff ff       	jmp    80104e9b <alltraps>

80105b4e <vector214>:
.globl vector214
vector214:
  pushl $0
80105b4e:	6a 00                	push   $0x0
  pushl $214
80105b50:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105b55:	e9 41 f3 ff ff       	jmp    80104e9b <alltraps>

80105b5a <vector215>:
.globl vector215
vector215:
  pushl $0
80105b5a:	6a 00                	push   $0x0
  pushl $215
80105b5c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105b61:	e9 35 f3 ff ff       	jmp    80104e9b <alltraps>

80105b66 <vector216>:
.globl vector216
vector216:
  pushl $0
80105b66:	6a 00                	push   $0x0
  pushl $216
80105b68:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105b6d:	e9 29 f3 ff ff       	jmp    80104e9b <alltraps>

80105b72 <vector217>:
.globl vector217
vector217:
  pushl $0
80105b72:	6a 00                	push   $0x0
  pushl $217
80105b74:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105b79:	e9 1d f3 ff ff       	jmp    80104e9b <alltraps>

80105b7e <vector218>:
.globl vector218
vector218:
  pushl $0
80105b7e:	6a 00                	push   $0x0
  pushl $218
80105b80:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105b85:	e9 11 f3 ff ff       	jmp    80104e9b <alltraps>

80105b8a <vector219>:
.globl vector219
vector219:
  pushl $0
80105b8a:	6a 00                	push   $0x0
  pushl $219
80105b8c:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105b91:	e9 05 f3 ff ff       	jmp    80104e9b <alltraps>

80105b96 <vector220>:
.globl vector220
vector220:
  pushl $0
80105b96:	6a 00                	push   $0x0
  pushl $220
80105b98:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105b9d:	e9 f9 f2 ff ff       	jmp    80104e9b <alltraps>

80105ba2 <vector221>:
.globl vector221
vector221:
  pushl $0
80105ba2:	6a 00                	push   $0x0
  pushl $221
80105ba4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105ba9:	e9 ed f2 ff ff       	jmp    80104e9b <alltraps>

80105bae <vector222>:
.globl vector222
vector222:
  pushl $0
80105bae:	6a 00                	push   $0x0
  pushl $222
80105bb0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105bb5:	e9 e1 f2 ff ff       	jmp    80104e9b <alltraps>

80105bba <vector223>:
.globl vector223
vector223:
  pushl $0
80105bba:	6a 00                	push   $0x0
  pushl $223
80105bbc:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105bc1:	e9 d5 f2 ff ff       	jmp    80104e9b <alltraps>

80105bc6 <vector224>:
.globl vector224
vector224:
  pushl $0
80105bc6:	6a 00                	push   $0x0
  pushl $224
80105bc8:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105bcd:	e9 c9 f2 ff ff       	jmp    80104e9b <alltraps>

80105bd2 <vector225>:
.globl vector225
vector225:
  pushl $0
80105bd2:	6a 00                	push   $0x0
  pushl $225
80105bd4:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105bd9:	e9 bd f2 ff ff       	jmp    80104e9b <alltraps>

80105bde <vector226>:
.globl vector226
vector226:
  pushl $0
80105bde:	6a 00                	push   $0x0
  pushl $226
80105be0:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105be5:	e9 b1 f2 ff ff       	jmp    80104e9b <alltraps>

80105bea <vector227>:
.globl vector227
vector227:
  pushl $0
80105bea:	6a 00                	push   $0x0
  pushl $227
80105bec:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105bf1:	e9 a5 f2 ff ff       	jmp    80104e9b <alltraps>

80105bf6 <vector228>:
.globl vector228
vector228:
  pushl $0
80105bf6:	6a 00                	push   $0x0
  pushl $228
80105bf8:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105bfd:	e9 99 f2 ff ff       	jmp    80104e9b <alltraps>

80105c02 <vector229>:
.globl vector229
vector229:
  pushl $0
80105c02:	6a 00                	push   $0x0
  pushl $229
80105c04:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c09:	e9 8d f2 ff ff       	jmp    80104e9b <alltraps>

80105c0e <vector230>:
.globl vector230
vector230:
  pushl $0
80105c0e:	6a 00                	push   $0x0
  pushl $230
80105c10:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c15:	e9 81 f2 ff ff       	jmp    80104e9b <alltraps>

80105c1a <vector231>:
.globl vector231
vector231:
  pushl $0
80105c1a:	6a 00                	push   $0x0
  pushl $231
80105c1c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105c21:	e9 75 f2 ff ff       	jmp    80104e9b <alltraps>

80105c26 <vector232>:
.globl vector232
vector232:
  pushl $0
80105c26:	6a 00                	push   $0x0
  pushl $232
80105c28:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105c2d:	e9 69 f2 ff ff       	jmp    80104e9b <alltraps>

80105c32 <vector233>:
.globl vector233
vector233:
  pushl $0
80105c32:	6a 00                	push   $0x0
  pushl $233
80105c34:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105c39:	e9 5d f2 ff ff       	jmp    80104e9b <alltraps>

80105c3e <vector234>:
.globl vector234
vector234:
  pushl $0
80105c3e:	6a 00                	push   $0x0
  pushl $234
80105c40:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105c45:	e9 51 f2 ff ff       	jmp    80104e9b <alltraps>

80105c4a <vector235>:
.globl vector235
vector235:
  pushl $0
80105c4a:	6a 00                	push   $0x0
  pushl $235
80105c4c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105c51:	e9 45 f2 ff ff       	jmp    80104e9b <alltraps>

80105c56 <vector236>:
.globl vector236
vector236:
  pushl $0
80105c56:	6a 00                	push   $0x0
  pushl $236
80105c58:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105c5d:	e9 39 f2 ff ff       	jmp    80104e9b <alltraps>

80105c62 <vector237>:
.globl vector237
vector237:
  pushl $0
80105c62:	6a 00                	push   $0x0
  pushl $237
80105c64:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105c69:	e9 2d f2 ff ff       	jmp    80104e9b <alltraps>

80105c6e <vector238>:
.globl vector238
vector238:
  pushl $0
80105c6e:	6a 00                	push   $0x0
  pushl $238
80105c70:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105c75:	e9 21 f2 ff ff       	jmp    80104e9b <alltraps>

80105c7a <vector239>:
.globl vector239
vector239:
  pushl $0
80105c7a:	6a 00                	push   $0x0
  pushl $239
80105c7c:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105c81:	e9 15 f2 ff ff       	jmp    80104e9b <alltraps>

80105c86 <vector240>:
.globl vector240
vector240:
  pushl $0
80105c86:	6a 00                	push   $0x0
  pushl $240
80105c88:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105c8d:	e9 09 f2 ff ff       	jmp    80104e9b <alltraps>

80105c92 <vector241>:
.globl vector241
vector241:
  pushl $0
80105c92:	6a 00                	push   $0x0
  pushl $241
80105c94:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105c99:	e9 fd f1 ff ff       	jmp    80104e9b <alltraps>

80105c9e <vector242>:
.globl vector242
vector242:
  pushl $0
80105c9e:	6a 00                	push   $0x0
  pushl $242
80105ca0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105ca5:	e9 f1 f1 ff ff       	jmp    80104e9b <alltraps>

80105caa <vector243>:
.globl vector243
vector243:
  pushl $0
80105caa:	6a 00                	push   $0x0
  pushl $243
80105cac:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105cb1:	e9 e5 f1 ff ff       	jmp    80104e9b <alltraps>

80105cb6 <vector244>:
.globl vector244
vector244:
  pushl $0
80105cb6:	6a 00                	push   $0x0
  pushl $244
80105cb8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105cbd:	e9 d9 f1 ff ff       	jmp    80104e9b <alltraps>

80105cc2 <vector245>:
.globl vector245
vector245:
  pushl $0
80105cc2:	6a 00                	push   $0x0
  pushl $245
80105cc4:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105cc9:	e9 cd f1 ff ff       	jmp    80104e9b <alltraps>

80105cce <vector246>:
.globl vector246
vector246:
  pushl $0
80105cce:	6a 00                	push   $0x0
  pushl $246
80105cd0:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105cd5:	e9 c1 f1 ff ff       	jmp    80104e9b <alltraps>

80105cda <vector247>:
.globl vector247
vector247:
  pushl $0
80105cda:	6a 00                	push   $0x0
  pushl $247
80105cdc:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105ce1:	e9 b5 f1 ff ff       	jmp    80104e9b <alltraps>

80105ce6 <vector248>:
.globl vector248
vector248:
  pushl $0
80105ce6:	6a 00                	push   $0x0
  pushl $248
80105ce8:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105ced:	e9 a9 f1 ff ff       	jmp    80104e9b <alltraps>

80105cf2 <vector249>:
.globl vector249
vector249:
  pushl $0
80105cf2:	6a 00                	push   $0x0
  pushl $249
80105cf4:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105cf9:	e9 9d f1 ff ff       	jmp    80104e9b <alltraps>

80105cfe <vector250>:
.globl vector250
vector250:
  pushl $0
80105cfe:	6a 00                	push   $0x0
  pushl $250
80105d00:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105d05:	e9 91 f1 ff ff       	jmp    80104e9b <alltraps>

80105d0a <vector251>:
.globl vector251
vector251:
  pushl $0
80105d0a:	6a 00                	push   $0x0
  pushl $251
80105d0c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d11:	e9 85 f1 ff ff       	jmp    80104e9b <alltraps>

80105d16 <vector252>:
.globl vector252
vector252:
  pushl $0
80105d16:	6a 00                	push   $0x0
  pushl $252
80105d18:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d1d:	e9 79 f1 ff ff       	jmp    80104e9b <alltraps>

80105d22 <vector253>:
.globl vector253
vector253:
  pushl $0
80105d22:	6a 00                	push   $0x0
  pushl $253
80105d24:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105d29:	e9 6d f1 ff ff       	jmp    80104e9b <alltraps>

80105d2e <vector254>:
.globl vector254
vector254:
  pushl $0
80105d2e:	6a 00                	push   $0x0
  pushl $254
80105d30:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105d35:	e9 61 f1 ff ff       	jmp    80104e9b <alltraps>

80105d3a <vector255>:
.globl vector255
vector255:
  pushl $0
80105d3a:	6a 00                	push   $0x0
  pushl $255
80105d3c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105d41:	e9 55 f1 ff ff       	jmp    80104e9b <alltraps>

80105d46 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105d46:	55                   	push   %ebp
80105d47:	89 e5                	mov    %esp,%ebp
80105d49:	57                   	push   %edi
80105d4a:	56                   	push   %esi
80105d4b:	53                   	push   %ebx
80105d4c:	83 ec 0c             	sub    $0xc,%esp
80105d4f:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105d51:	c1 ea 16             	shr    $0x16,%edx
80105d54:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105d57:	8b 1f                	mov    (%edi),%ebx
80105d59:	f6 c3 01             	test   $0x1,%bl
80105d5c:	74 22                	je     80105d80 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105d5e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105d64:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105d6a:	c1 ee 0c             	shr    $0xc,%esi
80105d6d:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105d73:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105d76:	89 d8                	mov    %ebx,%eax
80105d78:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d7b:	5b                   	pop    %ebx
80105d7c:	5e                   	pop    %esi
80105d7d:	5f                   	pop    %edi
80105d7e:	5d                   	pop    %ebp
80105d7f:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105d80:	85 c9                	test   %ecx,%ecx
80105d82:	74 2b                	je     80105daf <walkpgdir+0x69>
80105d84:	e8 3c c3 ff ff       	call   801020c5 <kalloc>
80105d89:	89 c3                	mov    %eax,%ebx
80105d8b:	85 c0                	test   %eax,%eax
80105d8d:	74 e7                	je     80105d76 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105d8f:	83 ec 04             	sub    $0x4,%esp
80105d92:	68 00 10 00 00       	push   $0x1000
80105d97:	6a 00                	push   $0x0
80105d99:	50                   	push   %eax
80105d9a:	e8 fe df ff ff       	call   80103d9d <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105d9f:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105da5:	83 c8 07             	or     $0x7,%eax
80105da8:	89 07                	mov    %eax,(%edi)
80105daa:	83 c4 10             	add    $0x10,%esp
80105dad:	eb bb                	jmp    80105d6a <walkpgdir+0x24>
      return 0;
80105daf:	bb 00 00 00 00       	mov    $0x0,%ebx
80105db4:	eb c0                	jmp    80105d76 <walkpgdir+0x30>

80105db6 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105db6:	55                   	push   %ebp
80105db7:	89 e5                	mov    %esp,%ebp
80105db9:	57                   	push   %edi
80105dba:	56                   	push   %esi
80105dbb:	53                   	push   %ebx
80105dbc:	83 ec 1c             	sub    $0x1c,%esp
80105dbf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105dc2:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105dc5:	89 d3                	mov    %edx,%ebx
80105dc7:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105dcd:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105dd1:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105dd7:	b9 01 00 00 00       	mov    $0x1,%ecx
80105ddc:	89 da                	mov    %ebx,%edx
80105dde:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105de1:	e8 60 ff ff ff       	call   80105d46 <walkpgdir>
80105de6:	85 c0                	test   %eax,%eax
80105de8:	74 2e                	je     80105e18 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105dea:	f6 00 01             	testb  $0x1,(%eax)
80105ded:	75 1c                	jne    80105e0b <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105def:	89 f2                	mov    %esi,%edx
80105df1:	0b 55 0c             	or     0xc(%ebp),%edx
80105df4:	83 ca 01             	or     $0x1,%edx
80105df7:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105df9:	39 fb                	cmp    %edi,%ebx
80105dfb:	74 28                	je     80105e25 <mappages+0x6f>
      break;
    a += PGSIZE;
80105dfd:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105e03:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e09:	eb cc                	jmp    80105dd7 <mappages+0x21>
      panic("remap");
80105e0b:	83 ec 0c             	sub    $0xc,%esp
80105e0e:	68 0c 6f 10 80       	push   $0x80106f0c
80105e13:	e8 30 a5 ff ff       	call   80100348 <panic>
      return -1;
80105e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105e1d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e20:	5b                   	pop    %ebx
80105e21:	5e                   	pop    %esi
80105e22:	5f                   	pop    %edi
80105e23:	5d                   	pop    %ebp
80105e24:	c3                   	ret    
  return 0;
80105e25:	b8 00 00 00 00       	mov    $0x0,%eax
80105e2a:	eb f1                	jmp    80105e1d <mappages+0x67>

80105e2c <seginit>:
{
80105e2c:	55                   	push   %ebp
80105e2d:	89 e5                	mov    %esp,%ebp
80105e2f:	53                   	push   %ebx
80105e30:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105e33:	e8 ff d4 ff ff       	call   80103337 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105e38:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105e3e:	66 c7 80 38 28 13 80 	movw   $0xffff,-0x7fecd7c8(%eax)
80105e45:	ff ff 
80105e47:	66 c7 80 3a 28 13 80 	movw   $0x0,-0x7fecd7c6(%eax)
80105e4e:	00 00 
80105e50:	c6 80 3c 28 13 80 00 	movb   $0x0,-0x7fecd7c4(%eax)
80105e57:	0f b6 88 3d 28 13 80 	movzbl -0x7fecd7c3(%eax),%ecx
80105e5e:	83 e1 f0             	and    $0xfffffff0,%ecx
80105e61:	83 c9 1a             	or     $0x1a,%ecx
80105e64:	83 e1 9f             	and    $0xffffff9f,%ecx
80105e67:	83 c9 80             	or     $0xffffff80,%ecx
80105e6a:	88 88 3d 28 13 80    	mov    %cl,-0x7fecd7c3(%eax)
80105e70:	0f b6 88 3e 28 13 80 	movzbl -0x7fecd7c2(%eax),%ecx
80105e77:	83 c9 0f             	or     $0xf,%ecx
80105e7a:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e7d:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e80:	88 88 3e 28 13 80    	mov    %cl,-0x7fecd7c2(%eax)
80105e86:	c6 80 3f 28 13 80 00 	movb   $0x0,-0x7fecd7c1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105e8d:	66 c7 80 40 28 13 80 	movw   $0xffff,-0x7fecd7c0(%eax)
80105e94:	ff ff 
80105e96:	66 c7 80 42 28 13 80 	movw   $0x0,-0x7fecd7be(%eax)
80105e9d:	00 00 
80105e9f:	c6 80 44 28 13 80 00 	movb   $0x0,-0x7fecd7bc(%eax)
80105ea6:	0f b6 88 45 28 13 80 	movzbl -0x7fecd7bb(%eax),%ecx
80105ead:	83 e1 f0             	and    $0xfffffff0,%ecx
80105eb0:	83 c9 12             	or     $0x12,%ecx
80105eb3:	83 e1 9f             	and    $0xffffff9f,%ecx
80105eb6:	83 c9 80             	or     $0xffffff80,%ecx
80105eb9:	88 88 45 28 13 80    	mov    %cl,-0x7fecd7bb(%eax)
80105ebf:	0f b6 88 46 28 13 80 	movzbl -0x7fecd7ba(%eax),%ecx
80105ec6:	83 c9 0f             	or     $0xf,%ecx
80105ec9:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ecc:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ecf:	88 88 46 28 13 80    	mov    %cl,-0x7fecd7ba(%eax)
80105ed5:	c6 80 47 28 13 80 00 	movb   $0x0,-0x7fecd7b9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105edc:	66 c7 80 48 28 13 80 	movw   $0xffff,-0x7fecd7b8(%eax)
80105ee3:	ff ff 
80105ee5:	66 c7 80 4a 28 13 80 	movw   $0x0,-0x7fecd7b6(%eax)
80105eec:	00 00 
80105eee:	c6 80 4c 28 13 80 00 	movb   $0x0,-0x7fecd7b4(%eax)
80105ef5:	c6 80 4d 28 13 80 fa 	movb   $0xfa,-0x7fecd7b3(%eax)
80105efc:	0f b6 88 4e 28 13 80 	movzbl -0x7fecd7b2(%eax),%ecx
80105f03:	83 c9 0f             	or     $0xf,%ecx
80105f06:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f09:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f0c:	88 88 4e 28 13 80    	mov    %cl,-0x7fecd7b2(%eax)
80105f12:	c6 80 4f 28 13 80 00 	movb   $0x0,-0x7fecd7b1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f19:	66 c7 80 50 28 13 80 	movw   $0xffff,-0x7fecd7b0(%eax)
80105f20:	ff ff 
80105f22:	66 c7 80 52 28 13 80 	movw   $0x0,-0x7fecd7ae(%eax)
80105f29:	00 00 
80105f2b:	c6 80 54 28 13 80 00 	movb   $0x0,-0x7fecd7ac(%eax)
80105f32:	c6 80 55 28 13 80 f2 	movb   $0xf2,-0x7fecd7ab(%eax)
80105f39:	0f b6 88 56 28 13 80 	movzbl -0x7fecd7aa(%eax),%ecx
80105f40:	83 c9 0f             	or     $0xf,%ecx
80105f43:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f46:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f49:	88 88 56 28 13 80    	mov    %cl,-0x7fecd7aa(%eax)
80105f4f:	c6 80 57 28 13 80 00 	movb   $0x0,-0x7fecd7a9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105f56:	05 30 28 13 80       	add    $0x80132830,%eax
  pd[0] = size-1;
80105f5b:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105f61:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105f65:	c1 e8 10             	shr    $0x10,%eax
80105f68:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105f6c:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105f6f:	0f 01 10             	lgdtl  (%eax)
}
80105f72:	83 c4 14             	add    $0x14,%esp
80105f75:	5b                   	pop    %ebx
80105f76:	5d                   	pop    %ebp
80105f77:	c3                   	ret    

80105f78 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105f78:	55                   	push   %ebp
80105f79:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105f7b:	a1 e4 54 13 80       	mov    0x801354e4,%eax
80105f80:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105f85:	0f 22 d8             	mov    %eax,%cr3
}
80105f88:	5d                   	pop    %ebp
80105f89:	c3                   	ret    

80105f8a <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105f8a:	55                   	push   %ebp
80105f8b:	89 e5                	mov    %esp,%ebp
80105f8d:	57                   	push   %edi
80105f8e:	56                   	push   %esi
80105f8f:	53                   	push   %ebx
80105f90:	83 ec 1c             	sub    $0x1c,%esp
80105f93:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105f96:	85 f6                	test   %esi,%esi
80105f98:	0f 84 dd 00 00 00    	je     8010607b <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105f9e:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105fa2:	0f 84 e0 00 00 00    	je     80106088 <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105fa8:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105fac:	0f 84 e3 00 00 00    	je     80106095 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80105fb2:	e8 5d dc ff ff       	call   80103c14 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105fb7:	e8 1f d3 ff ff       	call   801032db <mycpu>
80105fbc:	89 c3                	mov    %eax,%ebx
80105fbe:	e8 18 d3 ff ff       	call   801032db <mycpu>
80105fc3:	8d 78 08             	lea    0x8(%eax),%edi
80105fc6:	e8 10 d3 ff ff       	call   801032db <mycpu>
80105fcb:	83 c0 08             	add    $0x8,%eax
80105fce:	c1 e8 10             	shr    $0x10,%eax
80105fd1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105fd4:	e8 02 d3 ff ff       	call   801032db <mycpu>
80105fd9:	83 c0 08             	add    $0x8,%eax
80105fdc:	c1 e8 18             	shr    $0x18,%eax
80105fdf:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105fe6:	67 00 
80105fe8:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80105fef:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80105ff3:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80105ff9:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106000:	83 e2 f0             	and    $0xfffffff0,%edx
80106003:	83 ca 19             	or     $0x19,%edx
80106006:	83 e2 9f             	and    $0xffffff9f,%edx
80106009:	83 ca 80             	or     $0xffffff80,%edx
8010600c:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106012:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106019:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010601f:	e8 b7 d2 ff ff       	call   801032db <mycpu>
80106024:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010602b:	83 e2 ef             	and    $0xffffffef,%edx
8010602e:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106034:	e8 a2 d2 ff ff       	call   801032db <mycpu>
80106039:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
8010603f:	8b 5e 08             	mov    0x8(%esi),%ebx
80106042:	e8 94 d2 ff ff       	call   801032db <mycpu>
80106047:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010604d:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106050:	e8 86 d2 ff ff       	call   801032db <mycpu>
80106055:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
8010605b:	b8 28 00 00 00       	mov    $0x28,%eax
80106060:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106063:	8b 46 04             	mov    0x4(%esi),%eax
80106066:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010606b:	0f 22 d8             	mov    %eax,%cr3
  popcli();
8010606e:	e8 de db ff ff       	call   80103c51 <popcli>
}
80106073:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106076:	5b                   	pop    %ebx
80106077:	5e                   	pop    %esi
80106078:	5f                   	pop    %edi
80106079:	5d                   	pop    %ebp
8010607a:	c3                   	ret    
    panic("switchuvm: no process");
8010607b:	83 ec 0c             	sub    $0xc,%esp
8010607e:	68 12 6f 10 80       	push   $0x80106f12
80106083:	e8 c0 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80106088:	83 ec 0c             	sub    $0xc,%esp
8010608b:	68 28 6f 10 80       	push   $0x80106f28
80106090:	e8 b3 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80106095:	83 ec 0c             	sub    $0xc,%esp
80106098:	68 3d 6f 10 80       	push   $0x80106f3d
8010609d:	e8 a6 a2 ff ff       	call   80100348 <panic>

801060a2 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801060a2:	55                   	push   %ebp
801060a3:	89 e5                	mov    %esp,%ebp
801060a5:	56                   	push   %esi
801060a6:	53                   	push   %ebx
801060a7:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801060aa:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801060b0:	77 4c                	ja     801060fe <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
801060b2:	e8 0e c0 ff ff       	call   801020c5 <kalloc>
801060b7:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801060b9:	83 ec 04             	sub    $0x4,%esp
801060bc:	68 00 10 00 00       	push   $0x1000
801060c1:	6a 00                	push   $0x0
801060c3:	50                   	push   %eax
801060c4:	e8 d4 dc ff ff       	call   80103d9d <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
801060c9:	83 c4 08             	add    $0x8,%esp
801060cc:	6a 06                	push   $0x6
801060ce:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801060d4:	50                   	push   %eax
801060d5:	b9 00 10 00 00       	mov    $0x1000,%ecx
801060da:	ba 00 00 00 00       	mov    $0x0,%edx
801060df:	8b 45 08             	mov    0x8(%ebp),%eax
801060e2:	e8 cf fc ff ff       	call   80105db6 <mappages>
  memmove(mem, init, sz);
801060e7:	83 c4 0c             	add    $0xc,%esp
801060ea:	56                   	push   %esi
801060eb:	ff 75 0c             	pushl  0xc(%ebp)
801060ee:	53                   	push   %ebx
801060ef:	e8 24 dd ff ff       	call   80103e18 <memmove>
}
801060f4:	83 c4 10             	add    $0x10,%esp
801060f7:	8d 65 f8             	lea    -0x8(%ebp),%esp
801060fa:	5b                   	pop    %ebx
801060fb:	5e                   	pop    %esi
801060fc:	5d                   	pop    %ebp
801060fd:	c3                   	ret    
    panic("inituvm: more than a page");
801060fe:	83 ec 0c             	sub    $0xc,%esp
80106101:	68 51 6f 10 80       	push   $0x80106f51
80106106:	e8 3d a2 ff ff       	call   80100348 <panic>

8010610b <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
8010610b:	55                   	push   %ebp
8010610c:	89 e5                	mov    %esp,%ebp
8010610e:	57                   	push   %edi
8010610f:	56                   	push   %esi
80106110:	53                   	push   %ebx
80106111:	83 ec 0c             	sub    $0xc,%esp
80106114:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106117:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010611e:	75 07                	jne    80106127 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
80106120:	bb 00 00 00 00       	mov    $0x0,%ebx
80106125:	eb 3c                	jmp    80106163 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106127:	83 ec 0c             	sub    $0xc,%esp
8010612a:	68 0c 70 10 80       	push   $0x8010700c
8010612f:	e8 14 a2 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106134:	83 ec 0c             	sub    $0xc,%esp
80106137:	68 6b 6f 10 80       	push   $0x80106f6b
8010613c:	e8 07 a2 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
80106141:	05 00 00 00 80       	add    $0x80000000,%eax
80106146:	56                   	push   %esi
80106147:	89 da                	mov    %ebx,%edx
80106149:	03 55 14             	add    0x14(%ebp),%edx
8010614c:	52                   	push   %edx
8010614d:	50                   	push   %eax
8010614e:	ff 75 10             	pushl  0x10(%ebp)
80106151:	e8 1d b6 ff ff       	call   80101773 <readi>
80106156:	83 c4 10             	add    $0x10,%esp
80106159:	39 f0                	cmp    %esi,%eax
8010615b:	75 47                	jne    801061a4 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
8010615d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106163:	39 fb                	cmp    %edi,%ebx
80106165:	73 30                	jae    80106197 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106167:	89 da                	mov    %ebx,%edx
80106169:	03 55 0c             	add    0xc(%ebp),%edx
8010616c:	b9 00 00 00 00       	mov    $0x0,%ecx
80106171:	8b 45 08             	mov    0x8(%ebp),%eax
80106174:	e8 cd fb ff ff       	call   80105d46 <walkpgdir>
80106179:	85 c0                	test   %eax,%eax
8010617b:	74 b7                	je     80106134 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
8010617d:	8b 00                	mov    (%eax),%eax
8010617f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
80106184:	89 fe                	mov    %edi,%esi
80106186:	29 de                	sub    %ebx,%esi
80106188:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010618e:	76 b1                	jbe    80106141 <loaduvm+0x36>
      n = PGSIZE;
80106190:	be 00 10 00 00       	mov    $0x1000,%esi
80106195:	eb aa                	jmp    80106141 <loaduvm+0x36>
      return -1;
  }
  return 0;
80106197:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010619c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010619f:	5b                   	pop    %ebx
801061a0:	5e                   	pop    %esi
801061a1:	5f                   	pop    %edi
801061a2:	5d                   	pop    %ebp
801061a3:	c3                   	ret    
      return -1;
801061a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061a9:	eb f1                	jmp    8010619c <loaduvm+0x91>

801061ab <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801061ab:	55                   	push   %ebp
801061ac:	89 e5                	mov    %esp,%ebp
801061ae:	57                   	push   %edi
801061af:	56                   	push   %esi
801061b0:	53                   	push   %ebx
801061b1:	83 ec 0c             	sub    $0xc,%esp
801061b4:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801061b7:	39 7d 10             	cmp    %edi,0x10(%ebp)
801061ba:	73 11                	jae    801061cd <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801061bc:	8b 45 10             	mov    0x10(%ebp),%eax
801061bf:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801061c5:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801061cb:	eb 19                	jmp    801061e6 <deallocuvm+0x3b>
    return oldsz;
801061cd:	89 f8                	mov    %edi,%eax
801061cf:	eb 64                	jmp    80106235 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801061d1:	c1 eb 16             	shr    $0x16,%ebx
801061d4:	83 c3 01             	add    $0x1,%ebx
801061d7:	c1 e3 16             	shl    $0x16,%ebx
801061da:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801061e0:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061e6:	39 fb                	cmp    %edi,%ebx
801061e8:	73 48                	jae    80106232 <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
801061ea:	b9 00 00 00 00       	mov    $0x0,%ecx
801061ef:	89 da                	mov    %ebx,%edx
801061f1:	8b 45 08             	mov    0x8(%ebp),%eax
801061f4:	e8 4d fb ff ff       	call   80105d46 <walkpgdir>
801061f9:	89 c6                	mov    %eax,%esi
    if(!pte)
801061fb:	85 c0                	test   %eax,%eax
801061fd:	74 d2                	je     801061d1 <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
801061ff:	8b 00                	mov    (%eax),%eax
80106201:	a8 01                	test   $0x1,%al
80106203:	74 db                	je     801061e0 <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106205:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010620a:	74 19                	je     80106225 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
8010620c:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106211:	83 ec 0c             	sub    $0xc,%esp
80106214:	50                   	push   %eax
80106215:	e8 8a bd ff ff       	call   80101fa4 <kfree>
      *pte = 0;
8010621a:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80106220:	83 c4 10             	add    $0x10,%esp
80106223:	eb bb                	jmp    801061e0 <deallocuvm+0x35>
        panic("kfree");
80106225:	83 ec 0c             	sub    $0xc,%esp
80106228:	68 66 68 10 80       	push   $0x80106866
8010622d:	e8 16 a1 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
80106232:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106235:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106238:	5b                   	pop    %ebx
80106239:	5e                   	pop    %esi
8010623a:	5f                   	pop    %edi
8010623b:	5d                   	pop    %ebp
8010623c:	c3                   	ret    

8010623d <allocuvm>:
{
8010623d:	55                   	push   %ebp
8010623e:	89 e5                	mov    %esp,%ebp
80106240:	57                   	push   %edi
80106241:	56                   	push   %esi
80106242:	53                   	push   %ebx
80106243:	83 ec 1c             	sub    $0x1c,%esp
80106246:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106249:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010624c:	85 ff                	test   %edi,%edi
8010624e:	0f 88 c1 00 00 00    	js     80106315 <allocuvm+0xd8>
  if(newsz < oldsz)
80106254:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106257:	72 5c                	jb     801062b5 <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
80106259:	8b 45 0c             	mov    0xc(%ebp),%eax
8010625c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106262:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
80106268:	39 fb                	cmp    %edi,%ebx
8010626a:	0f 83 ac 00 00 00    	jae    8010631c <allocuvm+0xdf>
    mem = kalloc();
80106270:	e8 50 be ff ff       	call   801020c5 <kalloc>
80106275:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80106277:	85 c0                	test   %eax,%eax
80106279:	74 42                	je     801062bd <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
8010627b:	83 ec 04             	sub    $0x4,%esp
8010627e:	68 00 10 00 00       	push   $0x1000
80106283:	6a 00                	push   $0x0
80106285:	50                   	push   %eax
80106286:	e8 12 db ff ff       	call   80103d9d <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
8010628b:	83 c4 08             	add    $0x8,%esp
8010628e:	6a 06                	push   $0x6
80106290:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106296:	50                   	push   %eax
80106297:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010629c:	89 da                	mov    %ebx,%edx
8010629e:	8b 45 08             	mov    0x8(%ebp),%eax
801062a1:	e8 10 fb ff ff       	call   80105db6 <mappages>
801062a6:	83 c4 10             	add    $0x10,%esp
801062a9:	85 c0                	test   %eax,%eax
801062ab:	78 38                	js     801062e5 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
801062ad:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062b3:	eb b3                	jmp    80106268 <allocuvm+0x2b>
    return oldsz;
801062b5:	8b 45 0c             	mov    0xc(%ebp),%eax
801062b8:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801062bb:	eb 5f                	jmp    8010631c <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
801062bd:	83 ec 0c             	sub    $0xc,%esp
801062c0:	68 89 6f 10 80       	push   $0x80106f89
801062c5:	e8 41 a3 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801062ca:	83 c4 0c             	add    $0xc,%esp
801062cd:	ff 75 0c             	pushl  0xc(%ebp)
801062d0:	57                   	push   %edi
801062d1:	ff 75 08             	pushl  0x8(%ebp)
801062d4:	e8 d2 fe ff ff       	call   801061ab <deallocuvm>
      return 0;
801062d9:	83 c4 10             	add    $0x10,%esp
801062dc:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801062e3:	eb 37                	jmp    8010631c <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
801062e5:	83 ec 0c             	sub    $0xc,%esp
801062e8:	68 a1 6f 10 80       	push   $0x80106fa1
801062ed:	e8 19 a3 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801062f2:	83 c4 0c             	add    $0xc,%esp
801062f5:	ff 75 0c             	pushl  0xc(%ebp)
801062f8:	57                   	push   %edi
801062f9:	ff 75 08             	pushl  0x8(%ebp)
801062fc:	e8 aa fe ff ff       	call   801061ab <deallocuvm>
      kfree(mem);
80106301:	89 34 24             	mov    %esi,(%esp)
80106304:	e8 9b bc ff ff       	call   80101fa4 <kfree>
      return 0;
80106309:	83 c4 10             	add    $0x10,%esp
8010630c:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
80106313:	eb 07                	jmp    8010631c <allocuvm+0xdf>
    return 0;
80106315:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
8010631c:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010631f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106322:	5b                   	pop    %ebx
80106323:	5e                   	pop    %esi
80106324:	5f                   	pop    %edi
80106325:	5d                   	pop    %ebp
80106326:	c3                   	ret    

80106327 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106327:	55                   	push   %ebp
80106328:	89 e5                	mov    %esp,%ebp
8010632a:	56                   	push   %esi
8010632b:	53                   	push   %ebx
8010632c:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010632f:	85 f6                	test   %esi,%esi
80106331:	74 1a                	je     8010634d <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
80106333:	83 ec 04             	sub    $0x4,%esp
80106336:	6a 00                	push   $0x0
80106338:	68 00 00 00 80       	push   $0x80000000
8010633d:	56                   	push   %esi
8010633e:	e8 68 fe ff ff       	call   801061ab <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
80106343:	83 c4 10             	add    $0x10,%esp
80106346:	bb 00 00 00 00       	mov    $0x0,%ebx
8010634b:	eb 10                	jmp    8010635d <freevm+0x36>
    panic("freevm: no pgdir");
8010634d:	83 ec 0c             	sub    $0xc,%esp
80106350:	68 bd 6f 10 80       	push   $0x80106fbd
80106355:	e8 ee 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
8010635a:	83 c3 01             	add    $0x1,%ebx
8010635d:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
80106363:	77 1f                	ja     80106384 <freevm+0x5d>
    if(pgdir[i] & PTE_P){
80106365:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106368:	a8 01                	test   $0x1,%al
8010636a:	74 ee                	je     8010635a <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
8010636c:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106371:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106376:	83 ec 0c             	sub    $0xc,%esp
80106379:	50                   	push   %eax
8010637a:	e8 25 bc ff ff       	call   80101fa4 <kfree>
8010637f:	83 c4 10             	add    $0x10,%esp
80106382:	eb d6                	jmp    8010635a <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
80106384:	83 ec 0c             	sub    $0xc,%esp
80106387:	56                   	push   %esi
80106388:	e8 17 bc ff ff       	call   80101fa4 <kfree>
}
8010638d:	83 c4 10             	add    $0x10,%esp
80106390:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106393:	5b                   	pop    %ebx
80106394:	5e                   	pop    %esi
80106395:	5d                   	pop    %ebp
80106396:	c3                   	ret    

80106397 <setupkvm>:
{
80106397:	55                   	push   %ebp
80106398:	89 e5                	mov    %esp,%ebp
8010639a:	56                   	push   %esi
8010639b:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
8010639c:	e8 24 bd ff ff       	call   801020c5 <kalloc>
801063a1:	89 c6                	mov    %eax,%esi
801063a3:	85 c0                	test   %eax,%eax
801063a5:	74 55                	je     801063fc <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801063a7:	83 ec 04             	sub    $0x4,%esp
801063aa:	68 00 10 00 00       	push   $0x1000
801063af:	6a 00                	push   $0x0
801063b1:	50                   	push   %eax
801063b2:	e8 e6 d9 ff ff       	call   80103d9d <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801063b7:	83 c4 10             	add    $0x10,%esp
801063ba:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
801063bf:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
801063c5:	73 35                	jae    801063fc <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
801063c7:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801063ca:	8b 4b 08             	mov    0x8(%ebx),%ecx
801063cd:	29 c1                	sub    %eax,%ecx
801063cf:	83 ec 08             	sub    $0x8,%esp
801063d2:	ff 73 0c             	pushl  0xc(%ebx)
801063d5:	50                   	push   %eax
801063d6:	8b 13                	mov    (%ebx),%edx
801063d8:	89 f0                	mov    %esi,%eax
801063da:	e8 d7 f9 ff ff       	call   80105db6 <mappages>
801063df:	83 c4 10             	add    $0x10,%esp
801063e2:	85 c0                	test   %eax,%eax
801063e4:	78 05                	js     801063eb <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801063e6:	83 c3 10             	add    $0x10,%ebx
801063e9:	eb d4                	jmp    801063bf <setupkvm+0x28>
      freevm(pgdir);
801063eb:	83 ec 0c             	sub    $0xc,%esp
801063ee:	56                   	push   %esi
801063ef:	e8 33 ff ff ff       	call   80106327 <freevm>
      return 0;
801063f4:	83 c4 10             	add    $0x10,%esp
801063f7:	be 00 00 00 00       	mov    $0x0,%esi
}
801063fc:	89 f0                	mov    %esi,%eax
801063fe:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106401:	5b                   	pop    %ebx
80106402:	5e                   	pop    %esi
80106403:	5d                   	pop    %ebp
80106404:	c3                   	ret    

80106405 <kvmalloc>:
{
80106405:	55                   	push   %ebp
80106406:	89 e5                	mov    %esp,%ebp
80106408:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010640b:	e8 87 ff ff ff       	call   80106397 <setupkvm>
80106410:	a3 e4 54 13 80       	mov    %eax,0x801354e4
  switchkvm();
80106415:	e8 5e fb ff ff       	call   80105f78 <switchkvm>
}
8010641a:	c9                   	leave  
8010641b:	c3                   	ret    

8010641c <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010641c:	55                   	push   %ebp
8010641d:	89 e5                	mov    %esp,%ebp
8010641f:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106422:	b9 00 00 00 00       	mov    $0x0,%ecx
80106427:	8b 55 0c             	mov    0xc(%ebp),%edx
8010642a:	8b 45 08             	mov    0x8(%ebp),%eax
8010642d:	e8 14 f9 ff ff       	call   80105d46 <walkpgdir>
  if(pte == 0)
80106432:	85 c0                	test   %eax,%eax
80106434:	74 05                	je     8010643b <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106436:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106439:	c9                   	leave  
8010643a:	c3                   	ret    
    panic("clearpteu");
8010643b:	83 ec 0c             	sub    $0xc,%esp
8010643e:	68 ce 6f 10 80       	push   $0x80106fce
80106443:	e8 00 9f ff ff       	call   80100348 <panic>

80106448 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106448:	55                   	push   %ebp
80106449:	89 e5                	mov    %esp,%ebp
8010644b:	57                   	push   %edi
8010644c:	56                   	push   %esi
8010644d:	53                   	push   %ebx
8010644e:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
80106451:	e8 41 ff ff ff       	call   80106397 <setupkvm>
80106456:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106459:	85 c0                	test   %eax,%eax
8010645b:	0f 84 c4 00 00 00    	je     80106525 <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
80106461:	bf 00 00 00 00       	mov    $0x0,%edi
80106466:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106469:	0f 83 b6 00 00 00    	jae    80106525 <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
8010646f:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106472:	b9 00 00 00 00       	mov    $0x0,%ecx
80106477:	89 fa                	mov    %edi,%edx
80106479:	8b 45 08             	mov    0x8(%ebp),%eax
8010647c:	e8 c5 f8 ff ff       	call   80105d46 <walkpgdir>
80106481:	85 c0                	test   %eax,%eax
80106483:	74 65                	je     801064ea <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106485:	8b 00                	mov    (%eax),%eax
80106487:	a8 01                	test   $0x1,%al
80106489:	74 6c                	je     801064f7 <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
8010648b:	89 c6                	mov    %eax,%esi
8010648d:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
80106493:	25 ff 0f 00 00       	and    $0xfff,%eax
80106498:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
8010649b:	e8 25 bc ff ff       	call   801020c5 <kalloc>
801064a0:	89 c3                	mov    %eax,%ebx
801064a2:	85 c0                	test   %eax,%eax
801064a4:	74 6a                	je     80106510 <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801064a6:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801064ac:	83 ec 04             	sub    $0x4,%esp
801064af:	68 00 10 00 00       	push   $0x1000
801064b4:	56                   	push   %esi
801064b5:	50                   	push   %eax
801064b6:	e8 5d d9 ff ff       	call   80103e18 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801064bb:	83 c4 08             	add    $0x8,%esp
801064be:	ff 75 e0             	pushl  -0x20(%ebp)
801064c1:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801064c7:	50                   	push   %eax
801064c8:	b9 00 10 00 00       	mov    $0x1000,%ecx
801064cd:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801064d0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801064d3:	e8 de f8 ff ff       	call   80105db6 <mappages>
801064d8:	83 c4 10             	add    $0x10,%esp
801064db:	85 c0                	test   %eax,%eax
801064dd:	78 25                	js     80106504 <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
801064df:	81 c7 00 10 00 00    	add    $0x1000,%edi
801064e5:	e9 7c ff ff ff       	jmp    80106466 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
801064ea:	83 ec 0c             	sub    $0xc,%esp
801064ed:	68 d8 6f 10 80       	push   $0x80106fd8
801064f2:	e8 51 9e ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
801064f7:	83 ec 0c             	sub    $0xc,%esp
801064fa:	68 f2 6f 10 80       	push   $0x80106ff2
801064ff:	e8 44 9e ff ff       	call   80100348 <panic>
      kfree(mem);
80106504:	83 ec 0c             	sub    $0xc,%esp
80106507:	53                   	push   %ebx
80106508:	e8 97 ba ff ff       	call   80101fa4 <kfree>
      goto bad;
8010650d:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106510:	83 ec 0c             	sub    $0xc,%esp
80106513:	ff 75 dc             	pushl  -0x24(%ebp)
80106516:	e8 0c fe ff ff       	call   80106327 <freevm>
  return 0;
8010651b:	83 c4 10             	add    $0x10,%esp
8010651e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106525:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106528:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010652b:	5b                   	pop    %ebx
8010652c:	5e                   	pop    %esi
8010652d:	5f                   	pop    %edi
8010652e:	5d                   	pop    %ebp
8010652f:	c3                   	ret    

80106530 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
80106530:	55                   	push   %ebp
80106531:	89 e5                	mov    %esp,%ebp
80106533:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106536:	b9 00 00 00 00       	mov    $0x0,%ecx
8010653b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010653e:	8b 45 08             	mov    0x8(%ebp),%eax
80106541:	e8 00 f8 ff ff       	call   80105d46 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106546:	8b 00                	mov    (%eax),%eax
80106548:	a8 01                	test   $0x1,%al
8010654a:	74 10                	je     8010655c <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
8010654c:	a8 04                	test   $0x4,%al
8010654e:	74 13                	je     80106563 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
80106550:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106555:	05 00 00 00 80       	add    $0x80000000,%eax
}
8010655a:	c9                   	leave  
8010655b:	c3                   	ret    
    return 0;
8010655c:	b8 00 00 00 00       	mov    $0x0,%eax
80106561:	eb f7                	jmp    8010655a <uva2ka+0x2a>
    return 0;
80106563:	b8 00 00 00 00       	mov    $0x0,%eax
80106568:	eb f0                	jmp    8010655a <uva2ka+0x2a>

8010656a <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
8010656a:	55                   	push   %ebp
8010656b:	89 e5                	mov    %esp,%ebp
8010656d:	57                   	push   %edi
8010656e:	56                   	push   %esi
8010656f:	53                   	push   %ebx
80106570:	83 ec 0c             	sub    $0xc,%esp
80106573:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106576:	eb 25                	jmp    8010659d <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106578:	8b 55 0c             	mov    0xc(%ebp),%edx
8010657b:	29 f2                	sub    %esi,%edx
8010657d:	01 d0                	add    %edx,%eax
8010657f:	83 ec 04             	sub    $0x4,%esp
80106582:	53                   	push   %ebx
80106583:	ff 75 10             	pushl  0x10(%ebp)
80106586:	50                   	push   %eax
80106587:	e8 8c d8 ff ff       	call   80103e18 <memmove>
    len -= n;
8010658c:	29 df                	sub    %ebx,%edi
    buf += n;
8010658e:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106591:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106597:	89 45 0c             	mov    %eax,0xc(%ebp)
8010659a:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
8010659d:	85 ff                	test   %edi,%edi
8010659f:	74 2f                	je     801065d0 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801065a1:	8b 75 0c             	mov    0xc(%ebp),%esi
801065a4:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801065aa:	83 ec 08             	sub    $0x8,%esp
801065ad:	56                   	push   %esi
801065ae:	ff 75 08             	pushl  0x8(%ebp)
801065b1:	e8 7a ff ff ff       	call   80106530 <uva2ka>
    if(pa0 == 0)
801065b6:	83 c4 10             	add    $0x10,%esp
801065b9:	85 c0                	test   %eax,%eax
801065bb:	74 20                	je     801065dd <copyout+0x73>
    n = PGSIZE - (va - va0);
801065bd:	89 f3                	mov    %esi,%ebx
801065bf:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801065c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801065c8:	39 df                	cmp    %ebx,%edi
801065ca:	73 ac                	jae    80106578 <copyout+0xe>
      n = len;
801065cc:	89 fb                	mov    %edi,%ebx
801065ce:	eb a8                	jmp    80106578 <copyout+0xe>
  }
  return 0;
801065d0:	b8 00 00 00 00       	mov    $0x0,%eax
}
801065d5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801065d8:	5b                   	pop    %ebx
801065d9:	5e                   	pop    %esi
801065da:	5f                   	pop    %edi
801065db:	5d                   	pop    %ebp
801065dc:	c3                   	ret    
      return -1;
801065dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801065e2:	eb f1                	jmp    801065d5 <copyout+0x6b>
