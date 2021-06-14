
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
8010002d:	b8 da 2c 10 80       	mov    $0x80102cda,%eax
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
80100046:	e8 cb 3d 00 00       	call   80103e16 <acquire>

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
8010007c:	e8 fa 3d 00 00       	call   80103e7b <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 76 3b 00 00       	call   80103c02 <acquiresleep>
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
801000ca:	e8 ac 3d 00 00       	call   80103e7b <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 28 3b 00 00       	call   80103c02 <acquiresleep>
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
801000ea:	68 60 67 10 80       	push   $0x80106760
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 71 67 10 80       	push   $0x80106771
80100100:	68 e0 b5 10 80       	push   $0x8010b5e0
80100105:	e8 d0 3b 00 00       	call   80103cda <initlock>
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
8010013a:	68 78 67 10 80       	push   $0x80106778
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 87 3a 00 00       	call   80103bcf <initsleeplock>
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
801001a8:	e8 df 3a 00 00       	call   80103c8c <holdingsleep>
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
801001cb:	68 7f 67 10 80       	push   $0x8010677f
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
801001e4:	e8 a3 3a 00 00       	call   80103c8c <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 58 3a 00 00       	call   80103c51 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100200:	e8 11 3c 00 00       	call   80103e16 <acquire>
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
8010024c:	e8 2a 3c 00 00       	call   80103e7b <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 86 67 10 80       	push   $0x80106786
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
8010028a:	e8 87 3b 00 00       	call   80103e16 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
8010029f:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 ff 30 00 00       	call   801033ab <myproc>
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
801002bf:	e8 57 36 00 00       	call   8010391b <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 a5 3b 00 00       	call   80103e7b <release>
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
80100331:	e8 45 3b 00 00       	call   80103e7b <release>
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
8010035a:	e8 95 22 00 00       	call   801025f4 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 8d 67 10 80       	push   $0x8010678d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 29 71 10 80 	movl   $0x80107129,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 61 39 00 00       	call   80103cf5 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 a1 67 10 80       	push   $0x801067a1
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
8010049e:	68 a5 67 10 80       	push   $0x801067a5
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 7e 3a 00 00       	call   80103f3d <memmove>
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
801004d9:	e8 e4 39 00 00       	call   80103ec2 <memset>
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
80100506:	e8 fe 4d 00 00       	call   80105309 <uartputc>
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
8010051f:	e8 e5 4d 00 00       	call   80105309 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 d9 4d 00 00       	call   80105309 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 cd 4d 00 00       	call   80105309 <uartputc>
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
80100576:	0f b6 92 d0 67 10 80 	movzbl -0x7fef9830(%edx),%edx
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
801005ca:	e8 47 38 00 00       	call   80103e16 <acquire>
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
801005f1:	e8 85 38 00 00       	call   80103e7b <release>
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
80100638:	e8 d9 37 00 00       	call   80103e16 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 bf 67 10 80       	push   $0x801067bf
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
801006ee:	be b8 67 10 80       	mov    $0x801067b8,%esi
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
80100734:	e8 42 37 00 00       	call   80103e7b <release>
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
8010074f:	e8 c2 36 00 00       	call   80103e16 <acquire>
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
801007de:	e8 9d 32 00 00       	call   80103a80 <wakeup>
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
80100873:	e8 03 36 00 00       	call   80103e7b <release>
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
80100887:	e8 91 32 00 00       	call   80103b1d <procdump>
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
80100894:	68 c8 67 10 80       	push   $0x801067c8
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 37 34 00 00       	call   80103cda <initlock>

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
801008de:	e8 c8 2a 00 00       	call   801033ab <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 36 21 00 00       	call   80102a24 <begin_op>

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
80100935:	e8 64 21 00 00       	call   80102a9e <end_op>
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
8010094a:	e8 4f 21 00 00       	call   80102a9e <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 e1 67 10 80       	push   $0x801067e1
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
80100972:	e8 78 5b 00 00       	call   801064ef <setupkvm>
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
80100a06:	e8 6f 59 00 00       	call   8010637a <allocuvm>
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
80100a38:	e8 0b 58 00 00       	call   80106248 <loaduvm>
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
80100a53:	e8 46 20 00 00       	call   80102a9e <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 01 59 00 00       	call   8010637a <allocuvm>
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
80100a9d:	e8 dd 59 00 00       	call   8010647f <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 c1 5a 00 00       	call   80106582 <clearpteu>
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
80100ae2:	e8 7d 35 00 00       	call   80104064 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 6b 35 00 00       	call   80104064 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 d3 5b 00 00       	call   801066de <copyout>
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
80100b66:	e8 73 5b 00 00       	call   801066de <copyout>
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
80100ba3:	e8 81 34 00 00       	call   80104029 <safestrcpy>
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
80100bd1:	e8 e6 54 00 00       	call   801060bc <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 a1 58 00 00       	call   8010647f <freevm>
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
80100c19:	68 ed 67 10 80       	push   $0x801067ed
80100c1e:	68 e0 ff 10 80       	push   $0x8010ffe0
80100c23:	e8 b2 30 00 00       	call   80103cda <initlock>
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
80100c39:	e8 d8 31 00 00       	call   80103e16 <acquire>
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
80100c68:	e8 0e 32 00 00       	call   80103e7b <release>
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
80100c7f:	e8 f7 31 00 00       	call   80103e7b <release>
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
80100c9d:	e8 74 31 00 00       	call   80103e16 <acquire>
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
80100cba:	e8 bc 31 00 00       	call   80103e7b <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 f4 67 10 80       	push   $0x801067f4
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
80100ce2:	e8 2f 31 00 00       	call   80103e16 <acquire>
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
80100d03:	e8 73 31 00 00       	call   80103e7b <release>
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
80100d13:	68 fc 67 10 80       	push   $0x801067fc
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
80100d49:	e8 2d 31 00 00       	call   80103e7b <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 c1 1c 00 00       	call   80102a24 <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 2b 1d 00 00       	call   80102a9e <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 10 23 00 00       	call   80103098 <pipeclose>
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
80100e3c:	e8 af 23 00 00       	call   801031f0 <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 06 68 10 80       	push   $0x80106806
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
80100e95:	e8 8a 22 00 00       	call   80103124 <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 7d 1b 00 00       	call   80102a24 <begin_op>
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
80100edd:	e8 bc 1b 00 00       	call   80102a9e <end_op>

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
80100f10:	68 0f 68 10 80       	push   $0x8010680f
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
80100f2d:	68 15 68 10 80       	push   $0x80106815
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
80100f8a:	e8 ae 2f 00 00       	call   80103f3d <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 9e 2f 00 00       	call   80103f3d <memmove>
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
80100fdf:	e8 de 2e 00 00       	call   80103ec2 <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 61 1b 00 00       	call   80102b4d <log_write>
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
801010a3:	68 1f 68 10 80       	push   $0x8010681f
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
801010bf:	e8 89 1a 00 00       	call   80102b4d <log_write>
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
80101170:	e8 d8 19 00 00       	call   80102b4d <log_write>
80101175:	83 c4 10             	add    $0x10,%esp
80101178:	eb bf                	jmp    80101139 <bmap+0x58>
  panic("bmap: out of range");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 35 68 10 80       	push   $0x80106835
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
8010119a:	e8 77 2c 00 00       	call   80103e16 <acquire>
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
801011e1:	e8 95 2c 00 00       	call   80103e7b <release>
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
80101217:	e8 5f 2c 00 00       	call   80103e7b <release>
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
8010122c:	68 48 68 10 80       	push   $0x80106848
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
80101255:	e8 e3 2c 00 00       	call   80103f3d <memmove>
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
801012c8:	e8 80 18 00 00       	call   80102b4d <log_write>
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
801012e2:	68 58 68 10 80       	push   $0x80106858
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 6b 68 10 80       	push   $0x8010686b
801012f8:	68 00 0a 11 80       	push   $0x80110a00
801012fd:	e8 d8 29 00 00       	call   80103cda <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 72 68 10 80       	push   $0x80106872
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 40 0a 11 80       	add    $0x80110a40,%eax
80101321:	50                   	push   %eax
80101322:	e8 a8 28 00 00       	call   80103bcf <initsleeplock>
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
8010136c:	68 d8 68 10 80       	push   $0x801068d8
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
801013df:	68 78 68 10 80       	push   $0x80106878
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 cc 2a 00 00       	call   80103ec2 <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 48 17 00 00       	call   80102b4d <log_write>
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
80101480:	e8 b8 2a 00 00       	call   80103f3d <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 c0 16 00 00       	call   80102b4d <log_write>
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
80101560:	e8 b1 28 00 00       	call   80103e16 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101575:	e8 01 29 00 00       	call   80103e7b <release>
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
8010159a:	e8 63 26 00 00       	call   80103c02 <acquiresleep>
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
801015b2:	68 8a 68 10 80       	push   $0x8010688a
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
80101614:	e8 24 29 00 00       	call   80103f3d <memmove>
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
80101639:	68 90 68 10 80       	push   $0x80106890
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
80101656:	e8 31 26 00 00       	call   80103c8c <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 e0 25 00 00       	call   80103c51 <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 9f 68 10 80       	push   $0x8010689f
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
80101698:	e8 65 25 00 00       	call   80103c02 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 9b 25 00 00       	call   80103c51 <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801016bd:	e8 54 27 00 00       	call   80103e16 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801016d2:	e8 a4 27 00 00       	call   80103e7b <release>
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
801016ea:	e8 27 27 00 00       	call   80103e16 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801016f9:	e8 7d 27 00 00       	call   80103e7b <release>
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
8010182a:	e8 0e 27 00 00       	call   80103f3d <memmove>
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
80101926:	e8 12 26 00 00       	call   80103f3d <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 1a 12 00 00       	call   80102b4d <log_write>
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
801019a9:	e8 f6 25 00 00       	call   80103fa4 <strncmp>
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
801019d0:	68 a7 68 10 80       	push   $0x801068a7
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 b9 68 10 80       	push   $0x801068b9
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
80101a5a:	e8 4c 19 00 00       	call   801033ab <myproc>
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
80101b92:	68 c8 68 10 80       	push   $0x801068c8
80101b97:	e8 ac e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b9c:	83 ec 04             	sub    $0x4,%esp
80101b9f:	6a 0e                	push   $0xe
80101ba1:	57                   	push   %edi
80101ba2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101ba5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ba8:	50                   	push   %eax
80101ba9:	e8 33 24 00 00       	call   80103fe1 <strncpy>
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
80101bd7:	68 f4 6e 10 80       	push   $0x80106ef4
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
80101ccc:	68 2b 69 10 80       	push   $0x8010692b
80101cd1:	e8 72 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 34 69 10 80       	push   $0x80106934
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
80101d06:	68 46 69 10 80       	push   $0x80106946
80101d0b:	68 80 a5 10 80       	push   $0x8010a580
80101d10:	e8 c5 1f 00 00       	call   80103cda <initlock>
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
80101d80:	e8 91 20 00 00       	call   80103e16 <acquire>

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
80101dad:	e8 ce 1c 00 00       	call   80103a80 <wakeup>

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
80101dcb:	e8 ab 20 00 00       	call   80103e7b <release>
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
80101de2:	e8 94 20 00 00       	call   80103e7b <release>
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
80101e1a:	e8 6d 1e 00 00       	call   80103c8c <holdingsleep>
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
80101e47:	e8 ca 1f 00 00       	call   80103e16 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e4c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e5b:	eb 2a                	jmp    80101e87 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e5d:	83 ec 0c             	sub    $0xc,%esp
80101e60:	68 4a 69 10 80       	push   $0x8010694a
80101e65:	e8 de e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 60 69 10 80       	push   $0x80106960
80101e72:	e8 d1 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e77:	83 ec 0c             	sub    $0xc,%esp
80101e7a:	68 75 69 10 80       	push   $0x80106975
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
80101ea9:	e8 6d 1a 00 00       	call   8010391b <sleep>
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
80101ec3:	e8 b3 1f 00 00       	call   80103e7b <release>
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
80101f3f:	68 94 69 10 80       	push   $0x80106994
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

80101fa4 <check>:
  struct run *freelist;
} kmem;

// p5 - print the freelist
void
check(){
80101fa4:	55                   	push   %ebp
80101fa5:	89 e5                	mov    %esp,%ebp
80101fa7:	53                   	push   %ebx
80101fa8:	83 ec 04             	sub    $0x4,%esp
  if(kmem.use_lock)
80101fab:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
80101fb2:	75 08                	jne    80101fbc <check+0x18>
    acquire(&kmem.lock);
  struct run *tr = kmem.freelist;
80101fb4:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
  while(tr) {
80101fba:	eb 27                	jmp    80101fe3 <check+0x3f>
    acquire(&kmem.lock);
80101fbc:	83 ec 0c             	sub    $0xc,%esp
80101fbf:	68 60 26 11 80       	push   $0x80112660
80101fc4:	e8 4d 1e 00 00       	call   80103e16 <acquire>
80101fc9:	83 c4 10             	add    $0x10,%esp
80101fcc:	eb e6                	jmp    80101fb4 <check+0x10>
    cprintf("[%d]", tr->pid);
80101fce:	83 ec 08             	sub    $0x8,%esp
80101fd1:	ff 33                	pushl  (%ebx)
80101fd3:	68 c6 69 10 80       	push   $0x801069c6
80101fd8:	e8 2e e6 ff ff       	call   8010060b <cprintf>
    tr = tr->next;
80101fdd:	8b 5b 04             	mov    0x4(%ebx),%ebx
80101fe0:	83 c4 10             	add    $0x10,%esp
  while(tr) {
80101fe3:	85 db                	test   %ebx,%ebx
80101fe5:	75 e7                	jne    80101fce <check+0x2a>
  }
  cprintf("\n");
80101fe7:	83 ec 0c             	sub    $0xc,%esp
80101fea:	68 29 71 10 80       	push   $0x80107129
80101fef:	e8 17 e6 ff ff       	call   8010060b <cprintf>
  if(kmem.use_lock)
80101ff4:	83 c4 10             	add    $0x10,%esp
80101ff7:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
80101ffe:	75 05                	jne    80102005 <check+0x61>
    release(&kmem.lock);
}
80102000:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102003:	c9                   	leave  
80102004:	c3                   	ret    
    release(&kmem.lock);
80102005:	83 ec 0c             	sub    $0xc,%esp
80102008:	68 60 26 11 80       	push   $0x80112660
8010200d:	e8 69 1e 00 00       	call   80103e7b <release>
80102012:	83 c4 10             	add    $0x10,%esp
}
80102015:	eb e9                	jmp    80102000 <check+0x5c>

80102017 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(char *v)
{
80102017:	55                   	push   %ebp
80102018:	89 e5                	mov    %esp,%ebp
8010201a:	57                   	push   %edi
8010201b:	56                   	push   %esi
8010201c:	53                   	push   %ebx
8010201d:	83 ec 1c             	sub    $0x1c,%esp
80102020:	8b 5d 08             	mov    0x8(%ebp),%ebx
  //cprintf("kfree\n");

  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80102023:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80102029:	75 64                	jne    8010208f <kfree+0x78>
8010202b:	81 fb e8 54 13 80    	cmp    $0x801354e8,%ebx
80102031:	72 5c                	jb     8010208f <kfree+0x78>
80102033:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
80102039:	81 fe ff ff ff 0d    	cmp    $0xdffffff,%esi
8010203f:	77 4e                	ja     8010208f <kfree+0x78>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80102041:	83 ec 04             	sub    $0x4,%esp
80102044:	68 00 10 00 00       	push   $0x1000
80102049:	6a 01                	push   $0x1
8010204b:	53                   	push   %ebx
8010204c:	e8 71 1e 00 00       	call   80103ec2 <memset>

  if(kmem.use_lock)
80102051:	83 c4 10             	add    $0x10,%esp
80102054:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
8010205b:	75 3f                	jne    8010209c <kfree+0x85>
  
  //r = (struct run*)v;
  //r->next = kmem.freelist;
  //kmem.freelist = r;
  // p5
  if(kinit2ed == 1) {
8010205d:	83 3d b4 a5 10 80 01 	cmpl   $0x1,0x8010a5b4
80102064:	74 48                	je     801020ae <kfree+0x97>
    // add the frame to freelist
    r->next = kmem.freelist;
    kmem.freelist = r;
  } else {
    r = (struct run*)v;
    r->next = kmem.freelist;
80102066:	a1 98 26 11 80       	mov    0x80112698,%eax
8010206b:	89 43 04             	mov    %eax,0x4(%ebx)
    r->pid = -2; // indicates it's freed before kinit2
8010206e:	c7 03 fe ff ff ff    	movl   $0xfffffffe,(%ebx)
    kmem.freelist = r;
80102074:	89 1d 98 26 11 80    	mov    %ebx,0x80112698
  }
  // p5

  if(kmem.use_lock)
8010207a:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
80102081:	0f 85 fe 00 00 00    	jne    80102185 <kfree+0x16e>
    release(&kmem.lock);
}
80102087:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010208a:	5b                   	pop    %ebx
8010208b:	5e                   	pop    %esi
8010208c:	5f                   	pop    %edi
8010208d:	5d                   	pop    %ebp
8010208e:	c3                   	ret    
    panic("kfree");
8010208f:	83 ec 0c             	sub    $0xc,%esp
80102092:	68 cb 69 10 80       	push   $0x801069cb
80102097:	e8 ac e2 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010209c:	83 ec 0c             	sub    $0xc,%esp
8010209f:	68 60 26 11 80       	push   $0x80112660
801020a4:	e8 6d 1d 00 00       	call   80103e16 <acquire>
801020a9:	83 c4 10             	add    $0x10,%esp
801020ac:	eb af                	jmp    8010205d <kfree+0x46>
    int rframe = (uint)(V2P(r) >> 12);
801020ae:	89 f1                	mov    %esi,%ecx
801020b0:	c1 e9 0c             	shr    $0xc,%ecx
    for(int i = 0; i < index; i++) {
801020b3:	b8 00 00 00 00       	mov    $0x0,%eax
    int rpid = 0;
801020b8:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
    int lpid = 0; // pid 0 for unallocated
801020bf:	c7 45 e0 00 00 00 00 	movl   $0x0,-0x20(%ebp)
    for(int i = 0; i < index; i++) {
801020c6:	eb 3b                	jmp    80102103 <kfree+0xec>
          frames[j] = frames[j+1];
801020c8:	8d 7a 01             	lea    0x1(%edx),%edi
801020cb:	8b 04 bd a0 26 11 80 	mov    -0x7feed960(,%edi,4),%eax
801020d2:	89 04 95 a0 26 11 80 	mov    %eax,-0x7feed960(,%edx,4)
        for(int j = i; j < index; j++) {
801020d9:	89 fa                	mov    %edi,%edx
801020db:	39 d6                	cmp    %edx,%esi
801020dd:	7f e9                	jg     801020c8 <kfree+0xb1>
801020df:	8b 45 dc             	mov    -0x24(%ebp),%eax
        index--;
801020e2:	83 ee 01             	sub    $0x1,%esi
801020e5:	89 35 b8 a5 10 80    	mov    %esi,0x8010a5b8
801020eb:	eb 29                	jmp    80102116 <kfree+0xff>
        for(int j = i; j < index; j++) {
801020ed:	89 c2                	mov    %eax,%edx
801020ef:	89 45 dc             	mov    %eax,-0x24(%ebp)
801020f2:	eb e7                	jmp    801020db <kfree+0xc4>
        lpid = pids[i];
801020f4:	8b 3c 85 a0 26 12 80 	mov    -0x7fedd960(,%eax,4),%edi
801020fb:	89 7d e0             	mov    %edi,-0x20(%ebp)
801020fe:	eb 24                	jmp    80102124 <kfree+0x10d>
    for(int i = 0; i < index; i++) {
80102100:	83 c0 01             	add    $0x1,%eax
80102103:	8b 35 b8 a5 10 80    	mov    0x8010a5b8,%esi
80102109:	39 c6                	cmp    %eax,%esi
8010210b:	7e 2a                	jle    80102137 <kfree+0x120>
      if(frames[i] == rframe) {
8010210d:	39 0c 85 a0 26 11 80 	cmp    %ecx,-0x7feed960(,%eax,4)
80102114:	74 d7                	je     801020ed <kfree+0xd6>
      if(frames[i] == rframe - 1)
80102116:	8b 14 85 a0 26 11 80 	mov    -0x7feed960(,%eax,4),%edx
8010211d:	8d 71 ff             	lea    -0x1(%ecx),%esi
80102120:	39 f2                	cmp    %esi,%edx
80102122:	74 d0                	je     801020f4 <kfree+0xdd>
      if(frames[i] == rframe + 1)
80102124:	8d 71 01             	lea    0x1(%ecx),%esi
80102127:	39 f2                	cmp    %esi,%edx
80102129:	75 d5                	jne    80102100 <kfree+0xe9>
        rpid = pids[i];
8010212b:	8b 3c 85 a0 26 12 80 	mov    -0x7fedd960(,%eax,4),%edi
80102132:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80102135:	eb c9                	jmp    80102100 <kfree+0xe9>
    if(lpid == 0 && rpid == 0) {
80102137:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010213a:	0b 45 e4             	or     -0x1c(%ebp),%eax
8010213d:	75 19                	jne    80102158 <kfree+0x141>
      r->pid = 0; // available for any
8010213f:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
    r->next = kmem.freelist;
80102145:	a1 98 26 11 80       	mov    0x80112698,%eax
8010214a:	89 43 04             	mov    %eax,0x4(%ebx)
    kmem.freelist = r;
8010214d:	89 1d 98 26 11 80    	mov    %ebx,0x80112698
80102153:	e9 22 ff ff ff       	jmp    8010207a <kfree+0x63>
    } else if(lpid == rpid || lpid == 0) {
80102158:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010215b:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010215e:	39 f8                	cmp    %edi,%eax
80102160:	0f 94 c2             	sete   %dl
80102163:	85 c0                	test   %eax,%eax
80102165:	0f 94 c0             	sete   %al
80102168:	08 c2                	or     %al,%dl
8010216a:	74 04                	je     80102170 <kfree+0x159>
      r->pid = rpid;
8010216c:	89 3b                	mov    %edi,(%ebx)
8010216e:	eb d5                	jmp    80102145 <kfree+0x12e>
    } else if(rpid == 0) {
80102170:	83 7d e4 00          	cmpl   $0x0,-0x1c(%ebp)
80102174:	75 07                	jne    8010217d <kfree+0x166>
      r->pid = lpid;
80102176:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102179:	89 03                	mov    %eax,(%ebx)
8010217b:	eb c8                	jmp    80102145 <kfree+0x12e>
      r->pid = -1; // invailable
8010217d:	c7 03 ff ff ff ff    	movl   $0xffffffff,(%ebx)
80102183:	eb c0                	jmp    80102145 <kfree+0x12e>
    release(&kmem.lock);
80102185:	83 ec 0c             	sub    $0xc,%esp
80102188:	68 60 26 11 80       	push   $0x80112660
8010218d:	e8 e9 1c 00 00       	call   80103e7b <release>
80102192:	83 c4 10             	add    $0x10,%esp
}
80102195:	e9 ed fe ff ff       	jmp    80102087 <kfree+0x70>

8010219a <freerange>:
{
8010219a:	55                   	push   %ebp
8010219b:	89 e5                	mov    %esp,%ebp
8010219d:	56                   	push   %esi
8010219e:	53                   	push   %ebx
8010219f:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  cprintf("freerange\n");
801021a2:	83 ec 0c             	sub    $0xc,%esp
801021a5:	68 d1 69 10 80       	push   $0x801069d1
801021aa:	e8 5c e4 ff ff       	call   8010060b <cprintf>
  p = (char*)PGROUNDUP((uint)vstart);
801021af:	8b 45 08             	mov    0x8(%ebp),%eax
801021b2:	05 ff 0f 00 00       	add    $0xfff,%eax
801021b7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801021bc:	83 c4 10             	add    $0x10,%esp
801021bf:	eb 0e                	jmp    801021cf <freerange+0x35>
    kfree(p);
801021c1:	83 ec 0c             	sub    $0xc,%esp
801021c4:	50                   	push   %eax
801021c5:	e8 4d fe ff ff       	call   80102017 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
801021ca:	83 c4 10             	add    $0x10,%esp
801021cd:	89 f0                	mov    %esi,%eax
801021cf:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
801021d5:	39 de                	cmp    %ebx,%esi
801021d7:	76 e8                	jbe    801021c1 <freerange+0x27>
}
801021d9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801021dc:	5b                   	pop    %ebx
801021dd:	5e                   	pop    %esi
801021de:	5d                   	pop    %ebp
801021df:	c3                   	ret    

801021e0 <kinit1>:
{
801021e0:	55                   	push   %ebp
801021e1:	89 e5                	mov    %esp,%ebp
801021e3:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
801021e6:	68 dc 69 10 80       	push   $0x801069dc
801021eb:	68 60 26 11 80       	push   $0x80112660
801021f0:	e8 e5 1a 00 00       	call   80103cda <initlock>
  kmem.use_lock = 0;
801021f5:	c7 05 94 26 11 80 00 	movl   $0x0,0x80112694
801021fc:	00 00 00 
  freerange(vstart, vend);
801021ff:	83 c4 08             	add    $0x8,%esp
80102202:	ff 75 0c             	pushl  0xc(%ebp)
80102205:	ff 75 08             	pushl  0x8(%ebp)
80102208:	e8 8d ff ff ff       	call   8010219a <freerange>
}
8010220d:	83 c4 10             	add    $0x10,%esp
80102210:	c9                   	leave  
80102211:	c3                   	ret    

80102212 <kinit2>:
{
80102212:	55                   	push   %ebp
80102213:	89 e5                	mov    %esp,%ebp
80102215:	83 ec 14             	sub    $0x14,%esp
  cprintf("kinit2\n");
80102218:	68 e1 69 10 80       	push   $0x801069e1
8010221d:	e8 e9 e3 ff ff       	call   8010060b <cprintf>
  kinit2ed = 1;
80102222:	c7 05 b4 a5 10 80 01 	movl   $0x1,0x8010a5b4
80102229:	00 00 00 
  kmem.freelist = 0; // clear all free pages from kinit1?
8010222c:	c7 05 98 26 11 80 00 	movl   $0x0,0x80112698
80102233:	00 00 00 
  freerange(vstart, vend);
80102236:	83 c4 08             	add    $0x8,%esp
80102239:	ff 75 0c             	pushl  0xc(%ebp)
8010223c:	ff 75 08             	pushl  0x8(%ebp)
8010223f:	e8 56 ff ff ff       	call   8010219a <freerange>
  kmem.use_lock = 1;
80102244:	c7 05 94 26 11 80 01 	movl   $0x1,0x80112694
8010224b:	00 00 00 
}
8010224e:	83 c4 10             	add    $0x10,%esp
80102251:	c9                   	leave  
80102252:	c3                   	ret    

80102253 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
80102253:	55                   	push   %ebp
80102254:	89 e5                	mov    %esp,%ebp
80102256:	53                   	push   %ebx
80102257:	83 ec 10             	sub    $0x10,%esp
  cprintf("kalloc\n");
8010225a:	68 e9 69 10 80       	push   $0x801069e9
8010225f:	e8 a7 e3 ff ff       	call   8010060b <cprintf>

  struct run *r;

  if(kmem.use_lock)
80102264:	83 c4 10             	add    $0x10,%esp
80102267:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
8010226e:	75 22                	jne    80102292 <kalloc+0x3f>
    acquire(&kmem.lock);
  r = kmem.freelist;
80102270:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
  if(r)
80102276:	85 db                	test   %ebx,%ebx
80102278:	74 08                	je     80102282 <kalloc+0x2f>
    kmem.freelist = r->next;
8010227a:	8b 43 04             	mov    0x4(%ebx),%eax
8010227d:	a3 98 26 11 80       	mov    %eax,0x80112698
  if(kmem.use_lock)
80102282:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
80102289:	75 19                	jne    801022a4 <kalloc+0x51>
    release(&kmem.lock);
  return (char*)r;
}
8010228b:	89 d8                	mov    %ebx,%eax
8010228d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102290:	c9                   	leave  
80102291:	c3                   	ret    
    acquire(&kmem.lock);
80102292:	83 ec 0c             	sub    $0xc,%esp
80102295:	68 60 26 11 80       	push   $0x80112660
8010229a:	e8 77 1b 00 00       	call   80103e16 <acquire>
8010229f:	83 c4 10             	add    $0x10,%esp
801022a2:	eb cc                	jmp    80102270 <kalloc+0x1d>
    release(&kmem.lock);
801022a4:	83 ec 0c             	sub    $0xc,%esp
801022a7:	68 60 26 11 80       	push   $0x80112660
801022ac:	e8 ca 1b 00 00       	call   80103e7b <release>
801022b1:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
801022b4:	eb d5                	jmp    8010228b <kalloc+0x38>

801022b6 <kalloc1>:

// used for p5 - v2
char*
kalloc1(int pid)
{
801022b6:	55                   	push   %ebp
801022b7:	89 e5                	mov    %esp,%ebp
801022b9:	56                   	push   %esi
801022ba:	53                   	push   %ebx
801022bb:	8b 75 08             	mov    0x8(%ebp),%esi
  cprintf("kalloc1(%d)\n", pid);
801022be:	83 ec 08             	sub    $0x8,%esp
801022c1:	56                   	push   %esi
801022c2:	68 f1 69 10 80       	push   $0x801069f1
801022c7:	e8 3f e3 ff ff       	call   8010060b <cprintf>
  struct run *r = 0;

  // pick the first frame that available for the pid
  if(kmem.use_lock)
801022cc:	83 c4 10             	add    $0x10,%esp
801022cf:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
801022d6:	75 19                	jne    801022f1 <kalloc1+0x3b>
    acquire(&kmem.lock);
  
  struct run *tr = kmem.freelist;
801022d8:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
  while(tr) {
801022de:	85 db                	test   %ebx,%ebx
801022e0:	74 3e                	je     80102320 <kalloc1+0x6a>
    if(tr->pid == pid || tr->pid == 0) {
801022e2:	8b 03                	mov    (%ebx),%eax
801022e4:	39 f0                	cmp    %esi,%eax
801022e6:	74 1b                	je     80102303 <kalloc1+0x4d>
801022e8:	85 c0                	test   %eax,%eax
801022ea:	74 17                	je     80102303 <kalloc1+0x4d>
      frames[index] = (uint)V2P(r) >> 12;
      pids[index] = pid;
      //
      break;
    }
    tr = tr->next;
801022ec:	8b 5b 04             	mov    0x4(%ebx),%ebx
801022ef:	eb ed                	jmp    801022de <kalloc1+0x28>
    acquire(&kmem.lock);
801022f1:	83 ec 0c             	sub    $0xc,%esp
801022f4:	68 60 26 11 80       	push   $0x80112660
801022f9:	e8 18 1b 00 00       	call   80103e16 <acquire>
801022fe:	83 c4 10             	add    $0x10,%esp
80102301:	eb d5                	jmp    801022d8 <kalloc1+0x22>
      frames[index] = (uint)V2P(r) >> 12;
80102303:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80102309:	8b 15 b8 a5 10 80    	mov    0x8010a5b8,%edx
8010230f:	c1 e8 0c             	shr    $0xc,%eax
80102312:	89 04 95 a0 26 11 80 	mov    %eax,-0x7feed960(,%edx,4)
      pids[index] = pid;
80102319:	89 34 95 a0 26 12 80 	mov    %esi,-0x7fedd960(,%edx,4)
  }

  if(kmem.use_lock)
80102320:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
80102327:	75 09                	jne    80102332 <kalloc1+0x7c>
    release(&kmem.lock);
  
  return (char*)r;
}
80102329:	89 d8                	mov    %ebx,%eax
8010232b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010232e:	5b                   	pop    %ebx
8010232f:	5e                   	pop    %esi
80102330:	5d                   	pop    %ebp
80102331:	c3                   	ret    
    release(&kmem.lock);
80102332:	83 ec 0c             	sub    $0xc,%esp
80102335:	68 60 26 11 80       	push   $0x80112660
8010233a:	e8 3c 1b 00 00       	call   80103e7b <release>
8010233f:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
80102342:	eb e5                	jmp    80102329 <kalloc1+0x73>

80102344 <dump_physmem>:

// used for p5
// by sysproc.c
int
dump_physmem(int *uframes, int *upids, int numframes)
{
80102344:	55                   	push   %ebp
80102345:	89 e5                	mov    %esp,%ebp
80102347:	57                   	push   %edi
80102348:	56                   	push   %esi
80102349:	53                   	push   %ebx
8010234a:	8b 7d 08             	mov    0x8(%ebp),%edi
8010234d:	8b 75 0c             	mov    0xc(%ebp),%esi
80102350:	8b 5d 10             	mov    0x10(%ebp),%ebx
  //cprintf("dump_physmem in kalloc.c\n");
  for(int i = 0; i < numframes; i++) {
80102353:	b8 00 00 00 00       	mov    $0x0,%eax
80102358:	eb 1e                	jmp    80102378 <dump_physmem+0x34>
    //cprintf("  uframes[%d] = frames[%d](%d);\n", i, i, frames[i]);
    //cprintf("  upids[%d] = pids[%d](%d);\n", i, i, pids[i]);
    uframes[i] = frames[i];
8010235a:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
80102361:	8b 0c 85 a0 26 11 80 	mov    -0x7feed960(,%eax,4),%ecx
80102368:	89 0c 17             	mov    %ecx,(%edi,%edx,1)
    upids[i] = pids[i];
8010236b:	8b 0c 85 a0 26 12 80 	mov    -0x7fedd960(,%eax,4),%ecx
80102372:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
  for(int i = 0; i < numframes; i++) {
80102375:	83 c0 01             	add    $0x1,%eax
80102378:	39 d8                	cmp    %ebx,%eax
8010237a:	7c de                	jl     8010235a <dump_physmem+0x16>
  }
  //cprintf("leaving dump_physmem in kalloc.c\n");
  return 0;
}
8010237c:	b8 00 00 00 00       	mov    $0x0,%eax
80102381:	5b                   	pop    %ebx
80102382:	5e                   	pop    %esi
80102383:	5f                   	pop    %edi
80102384:	5d                   	pop    %ebp
80102385:	c3                   	ret    

80102386 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102386:	55                   	push   %ebp
80102387:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102389:	ba 64 00 00 00       	mov    $0x64,%edx
8010238e:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
8010238f:	a8 01                	test   $0x1,%al
80102391:	0f 84 b5 00 00 00    	je     8010244c <kbdgetc+0xc6>
80102397:	ba 60 00 00 00       	mov    $0x60,%edx
8010239c:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
8010239d:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801023a0:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
801023a6:	74 5c                	je     80102404 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801023a8:	84 c0                	test   %al,%al
801023aa:	78 66                	js     80102412 <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801023ac:	8b 0d bc a5 10 80    	mov    0x8010a5bc,%ecx
801023b2:	f6 c1 40             	test   $0x40,%cl
801023b5:	74 0f                	je     801023c6 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801023b7:	83 c8 80             	or     $0xffffff80,%eax
801023ba:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
801023bd:	83 e1 bf             	and    $0xffffffbf,%ecx
801023c0:	89 0d bc a5 10 80    	mov    %ecx,0x8010a5bc
  }

  shift |= shiftcode[data];
801023c6:	0f b6 8a 20 6b 10 80 	movzbl -0x7fef94e0(%edx),%ecx
801023cd:	0b 0d bc a5 10 80    	or     0x8010a5bc,%ecx
  shift ^= togglecode[data];
801023d3:	0f b6 82 20 6a 10 80 	movzbl -0x7fef95e0(%edx),%eax
801023da:	31 c1                	xor    %eax,%ecx
801023dc:	89 0d bc a5 10 80    	mov    %ecx,0x8010a5bc
  c = charcode[shift & (CTL | SHIFT)][data];
801023e2:	89 c8                	mov    %ecx,%eax
801023e4:	83 e0 03             	and    $0x3,%eax
801023e7:	8b 04 85 00 6a 10 80 	mov    -0x7fef9600(,%eax,4),%eax
801023ee:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801023f2:	f6 c1 08             	test   $0x8,%cl
801023f5:	74 19                	je     80102410 <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
801023f7:	8d 50 9f             	lea    -0x61(%eax),%edx
801023fa:	83 fa 19             	cmp    $0x19,%edx
801023fd:	77 40                	ja     8010243f <kbdgetc+0xb9>
      c += 'A' - 'a';
801023ff:	83 e8 20             	sub    $0x20,%eax
80102402:	eb 0c                	jmp    80102410 <kbdgetc+0x8a>
    shift |= E0ESC;
80102404:	83 0d bc a5 10 80 40 	orl    $0x40,0x8010a5bc
    return 0;
8010240b:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102410:	5d                   	pop    %ebp
80102411:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102412:	8b 0d bc a5 10 80    	mov    0x8010a5bc,%ecx
80102418:	f6 c1 40             	test   $0x40,%cl
8010241b:	75 05                	jne    80102422 <kbdgetc+0x9c>
8010241d:	89 c2                	mov    %eax,%edx
8010241f:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
80102422:	0f b6 82 20 6b 10 80 	movzbl -0x7fef94e0(%edx),%eax
80102429:	83 c8 40             	or     $0x40,%eax
8010242c:	0f b6 c0             	movzbl %al,%eax
8010242f:	f7 d0                	not    %eax
80102431:	21 c8                	and    %ecx,%eax
80102433:	a3 bc a5 10 80       	mov    %eax,0x8010a5bc
    return 0;
80102438:	b8 00 00 00 00       	mov    $0x0,%eax
8010243d:	eb d1                	jmp    80102410 <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
8010243f:	8d 50 bf             	lea    -0x41(%eax),%edx
80102442:	83 fa 19             	cmp    $0x19,%edx
80102445:	77 c9                	ja     80102410 <kbdgetc+0x8a>
      c += 'a' - 'A';
80102447:	83 c0 20             	add    $0x20,%eax
  return c;
8010244a:	eb c4                	jmp    80102410 <kbdgetc+0x8a>
    return -1;
8010244c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102451:	eb bd                	jmp    80102410 <kbdgetc+0x8a>

80102453 <kbdintr>:

void
kbdintr(void)
{
80102453:	55                   	push   %ebp
80102454:	89 e5                	mov    %esp,%ebp
80102456:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102459:	68 86 23 10 80       	push   $0x80102386
8010245e:	e8 db e2 ff ff       	call   8010073e <consoleintr>
}
80102463:	83 c4 10             	add    $0x10,%esp
80102466:	c9                   	leave  
80102467:	c3                   	ret    

80102468 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102468:	55                   	push   %ebp
80102469:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
8010246b:	8b 0d a0 26 13 80    	mov    0x801326a0,%ecx
80102471:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102474:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102476:	a1 a0 26 13 80       	mov    0x801326a0,%eax
8010247b:	8b 40 20             	mov    0x20(%eax),%eax
}
8010247e:	5d                   	pop    %ebp
8010247f:	c3                   	ret    

80102480 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
80102480:	55                   	push   %ebp
80102481:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102483:	ba 70 00 00 00       	mov    $0x70,%edx
80102488:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102489:	ba 71 00 00 00       	mov    $0x71,%edx
8010248e:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
8010248f:	0f b6 c0             	movzbl %al,%eax
}
80102492:	5d                   	pop    %ebp
80102493:	c3                   	ret    

80102494 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80102494:	55                   	push   %ebp
80102495:	89 e5                	mov    %esp,%ebp
80102497:	53                   	push   %ebx
80102498:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
8010249a:	b8 00 00 00 00       	mov    $0x0,%eax
8010249f:	e8 dc ff ff ff       	call   80102480 <cmos_read>
801024a4:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801024a6:	b8 02 00 00 00       	mov    $0x2,%eax
801024ab:	e8 d0 ff ff ff       	call   80102480 <cmos_read>
801024b0:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801024b3:	b8 04 00 00 00       	mov    $0x4,%eax
801024b8:	e8 c3 ff ff ff       	call   80102480 <cmos_read>
801024bd:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801024c0:	b8 07 00 00 00       	mov    $0x7,%eax
801024c5:	e8 b6 ff ff ff       	call   80102480 <cmos_read>
801024ca:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801024cd:	b8 08 00 00 00       	mov    $0x8,%eax
801024d2:	e8 a9 ff ff ff       	call   80102480 <cmos_read>
801024d7:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801024da:	b8 09 00 00 00       	mov    $0x9,%eax
801024df:	e8 9c ff ff ff       	call   80102480 <cmos_read>
801024e4:	89 43 14             	mov    %eax,0x14(%ebx)
}
801024e7:	5b                   	pop    %ebx
801024e8:	5d                   	pop    %ebp
801024e9:	c3                   	ret    

801024ea <lapicinit>:
  if(!lapic)
801024ea:	83 3d a0 26 13 80 00 	cmpl   $0x0,0x801326a0
801024f1:	0f 84 fb 00 00 00    	je     801025f2 <lapicinit+0x108>
{
801024f7:	55                   	push   %ebp
801024f8:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801024fa:	ba 3f 01 00 00       	mov    $0x13f,%edx
801024ff:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102504:	e8 5f ff ff ff       	call   80102468 <lapicw>
  lapicw(TDCR, X1);
80102509:	ba 0b 00 00 00       	mov    $0xb,%edx
8010250e:	b8 f8 00 00 00       	mov    $0xf8,%eax
80102513:	e8 50 ff ff ff       	call   80102468 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102518:	ba 20 00 02 00       	mov    $0x20020,%edx
8010251d:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102522:	e8 41 ff ff ff       	call   80102468 <lapicw>
  lapicw(TICR, 10000000);
80102527:	ba 80 96 98 00       	mov    $0x989680,%edx
8010252c:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102531:	e8 32 ff ff ff       	call   80102468 <lapicw>
  lapicw(LINT0, MASKED);
80102536:	ba 00 00 01 00       	mov    $0x10000,%edx
8010253b:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102540:	e8 23 ff ff ff       	call   80102468 <lapicw>
  lapicw(LINT1, MASKED);
80102545:	ba 00 00 01 00       	mov    $0x10000,%edx
8010254a:	b8 d8 00 00 00       	mov    $0xd8,%eax
8010254f:	e8 14 ff ff ff       	call   80102468 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102554:	a1 a0 26 13 80       	mov    0x801326a0,%eax
80102559:	8b 40 30             	mov    0x30(%eax),%eax
8010255c:	c1 e8 10             	shr    $0x10,%eax
8010255f:	3c 03                	cmp    $0x3,%al
80102561:	77 7b                	ja     801025de <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102563:	ba 33 00 00 00       	mov    $0x33,%edx
80102568:	b8 dc 00 00 00       	mov    $0xdc,%eax
8010256d:	e8 f6 fe ff ff       	call   80102468 <lapicw>
  lapicw(ESR, 0);
80102572:	ba 00 00 00 00       	mov    $0x0,%edx
80102577:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010257c:	e8 e7 fe ff ff       	call   80102468 <lapicw>
  lapicw(ESR, 0);
80102581:	ba 00 00 00 00       	mov    $0x0,%edx
80102586:	b8 a0 00 00 00       	mov    $0xa0,%eax
8010258b:	e8 d8 fe ff ff       	call   80102468 <lapicw>
  lapicw(EOI, 0);
80102590:	ba 00 00 00 00       	mov    $0x0,%edx
80102595:	b8 2c 00 00 00       	mov    $0x2c,%eax
8010259a:	e8 c9 fe ff ff       	call   80102468 <lapicw>
  lapicw(ICRHI, 0);
8010259f:	ba 00 00 00 00       	mov    $0x0,%edx
801025a4:	b8 c4 00 00 00       	mov    $0xc4,%eax
801025a9:	e8 ba fe ff ff       	call   80102468 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801025ae:	ba 00 85 08 00       	mov    $0x88500,%edx
801025b3:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025b8:	e8 ab fe ff ff       	call   80102468 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801025bd:	a1 a0 26 13 80       	mov    0x801326a0,%eax
801025c2:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801025c8:	f6 c4 10             	test   $0x10,%ah
801025cb:	75 f0                	jne    801025bd <lapicinit+0xd3>
  lapicw(TPR, 0);
801025cd:	ba 00 00 00 00       	mov    $0x0,%edx
801025d2:	b8 20 00 00 00       	mov    $0x20,%eax
801025d7:	e8 8c fe ff ff       	call   80102468 <lapicw>
}
801025dc:	5d                   	pop    %ebp
801025dd:	c3                   	ret    
    lapicw(PCINT, MASKED);
801025de:	ba 00 00 01 00       	mov    $0x10000,%edx
801025e3:	b8 d0 00 00 00       	mov    $0xd0,%eax
801025e8:	e8 7b fe ff ff       	call   80102468 <lapicw>
801025ed:	e9 71 ff ff ff       	jmp    80102563 <lapicinit+0x79>
801025f2:	f3 c3                	repz ret 

801025f4 <lapicid>:
{
801025f4:	55                   	push   %ebp
801025f5:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801025f7:	a1 a0 26 13 80       	mov    0x801326a0,%eax
801025fc:	85 c0                	test   %eax,%eax
801025fe:	74 08                	je     80102608 <lapicid+0x14>
  return lapic[ID] >> 24;
80102600:	8b 40 20             	mov    0x20(%eax),%eax
80102603:	c1 e8 18             	shr    $0x18,%eax
}
80102606:	5d                   	pop    %ebp
80102607:	c3                   	ret    
    return 0;
80102608:	b8 00 00 00 00       	mov    $0x0,%eax
8010260d:	eb f7                	jmp    80102606 <lapicid+0x12>

8010260f <lapiceoi>:
  if(lapic)
8010260f:	83 3d a0 26 13 80 00 	cmpl   $0x0,0x801326a0
80102616:	74 14                	je     8010262c <lapiceoi+0x1d>
{
80102618:	55                   	push   %ebp
80102619:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
8010261b:	ba 00 00 00 00       	mov    $0x0,%edx
80102620:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102625:	e8 3e fe ff ff       	call   80102468 <lapicw>
}
8010262a:	5d                   	pop    %ebp
8010262b:	c3                   	ret    
8010262c:	f3 c3                	repz ret 

8010262e <microdelay>:
{
8010262e:	55                   	push   %ebp
8010262f:	89 e5                	mov    %esp,%ebp
}
80102631:	5d                   	pop    %ebp
80102632:	c3                   	ret    

80102633 <lapicstartap>:
{
80102633:	55                   	push   %ebp
80102634:	89 e5                	mov    %esp,%ebp
80102636:	57                   	push   %edi
80102637:	56                   	push   %esi
80102638:	53                   	push   %ebx
80102639:	8b 75 08             	mov    0x8(%ebp),%esi
8010263c:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010263f:	b8 0f 00 00 00       	mov    $0xf,%eax
80102644:	ba 70 00 00 00       	mov    $0x70,%edx
80102649:	ee                   	out    %al,(%dx)
8010264a:	b8 0a 00 00 00       	mov    $0xa,%eax
8010264f:	ba 71 00 00 00       	mov    $0x71,%edx
80102654:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102655:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
8010265c:	00 00 
  wrv[1] = addr >> 4;
8010265e:	89 f8                	mov    %edi,%eax
80102660:	c1 e8 04             	shr    $0x4,%eax
80102663:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102669:	c1 e6 18             	shl    $0x18,%esi
8010266c:	89 f2                	mov    %esi,%edx
8010266e:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102673:	e8 f0 fd ff ff       	call   80102468 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102678:	ba 00 c5 00 00       	mov    $0xc500,%edx
8010267d:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102682:	e8 e1 fd ff ff       	call   80102468 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102687:	ba 00 85 00 00       	mov    $0x8500,%edx
8010268c:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102691:	e8 d2 fd ff ff       	call   80102468 <lapicw>
  for(i = 0; i < 2; i++){
80102696:	bb 00 00 00 00       	mov    $0x0,%ebx
8010269b:	eb 21                	jmp    801026be <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
8010269d:	89 f2                	mov    %esi,%edx
8010269f:	b8 c4 00 00 00       	mov    $0xc4,%eax
801026a4:	e8 bf fd ff ff       	call   80102468 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801026a9:	89 fa                	mov    %edi,%edx
801026ab:	c1 ea 0c             	shr    $0xc,%edx
801026ae:	80 ce 06             	or     $0x6,%dh
801026b1:	b8 c0 00 00 00       	mov    $0xc0,%eax
801026b6:	e8 ad fd ff ff       	call   80102468 <lapicw>
  for(i = 0; i < 2; i++){
801026bb:	83 c3 01             	add    $0x1,%ebx
801026be:	83 fb 01             	cmp    $0x1,%ebx
801026c1:	7e da                	jle    8010269d <lapicstartap+0x6a>
}
801026c3:	5b                   	pop    %ebx
801026c4:	5e                   	pop    %esi
801026c5:	5f                   	pop    %edi
801026c6:	5d                   	pop    %ebp
801026c7:	c3                   	ret    

801026c8 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801026c8:	55                   	push   %ebp
801026c9:	89 e5                	mov    %esp,%ebp
801026cb:	57                   	push   %edi
801026cc:	56                   	push   %esi
801026cd:	53                   	push   %ebx
801026ce:	83 ec 3c             	sub    $0x3c,%esp
801026d1:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801026d4:	b8 0b 00 00 00       	mov    $0xb,%eax
801026d9:	e8 a2 fd ff ff       	call   80102480 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801026de:	83 e0 04             	and    $0x4,%eax
801026e1:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801026e3:	8d 45 d0             	lea    -0x30(%ebp),%eax
801026e6:	e8 a9 fd ff ff       	call   80102494 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801026eb:	b8 0a 00 00 00       	mov    $0xa,%eax
801026f0:	e8 8b fd ff ff       	call   80102480 <cmos_read>
801026f5:	a8 80                	test   $0x80,%al
801026f7:	75 ea                	jne    801026e3 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801026f9:	8d 5d b8             	lea    -0x48(%ebp),%ebx
801026fc:	89 d8                	mov    %ebx,%eax
801026fe:	e8 91 fd ff ff       	call   80102494 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102703:	83 ec 04             	sub    $0x4,%esp
80102706:	6a 18                	push   $0x18
80102708:	53                   	push   %ebx
80102709:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010270c:	50                   	push   %eax
8010270d:	e8 f6 17 00 00       	call   80103f08 <memcmp>
80102712:	83 c4 10             	add    $0x10,%esp
80102715:	85 c0                	test   %eax,%eax
80102717:	75 ca                	jne    801026e3 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102719:	85 ff                	test   %edi,%edi
8010271b:	0f 85 84 00 00 00    	jne    801027a5 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102721:	8b 55 d0             	mov    -0x30(%ebp),%edx
80102724:	89 d0                	mov    %edx,%eax
80102726:	c1 e8 04             	shr    $0x4,%eax
80102729:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010272c:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010272f:	83 e2 0f             	and    $0xf,%edx
80102732:	01 d0                	add    %edx,%eax
80102734:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102737:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010273a:	89 d0                	mov    %edx,%eax
8010273c:	c1 e8 04             	shr    $0x4,%eax
8010273f:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102742:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102745:	83 e2 0f             	and    $0xf,%edx
80102748:	01 d0                	add    %edx,%eax
8010274a:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
8010274d:	8b 55 d8             	mov    -0x28(%ebp),%edx
80102750:	89 d0                	mov    %edx,%eax
80102752:	c1 e8 04             	shr    $0x4,%eax
80102755:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102758:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010275b:	83 e2 0f             	and    $0xf,%edx
8010275e:	01 d0                	add    %edx,%eax
80102760:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102763:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102766:	89 d0                	mov    %edx,%eax
80102768:	c1 e8 04             	shr    $0x4,%eax
8010276b:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010276e:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102771:	83 e2 0f             	and    $0xf,%edx
80102774:	01 d0                	add    %edx,%eax
80102776:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102779:	8b 55 e0             	mov    -0x20(%ebp),%edx
8010277c:	89 d0                	mov    %edx,%eax
8010277e:	c1 e8 04             	shr    $0x4,%eax
80102781:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102784:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102787:	83 e2 0f             	and    $0xf,%edx
8010278a:	01 d0                	add    %edx,%eax
8010278c:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
8010278f:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80102792:	89 d0                	mov    %edx,%eax
80102794:	c1 e8 04             	shr    $0x4,%eax
80102797:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010279a:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010279d:	83 e2 0f             	and    $0xf,%edx
801027a0:	01 d0                	add    %edx,%eax
801027a2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
801027a5:	8b 45 d0             	mov    -0x30(%ebp),%eax
801027a8:	89 06                	mov    %eax,(%esi)
801027aa:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801027ad:	89 46 04             	mov    %eax,0x4(%esi)
801027b0:	8b 45 d8             	mov    -0x28(%ebp),%eax
801027b3:	89 46 08             	mov    %eax,0x8(%esi)
801027b6:	8b 45 dc             	mov    -0x24(%ebp),%eax
801027b9:	89 46 0c             	mov    %eax,0xc(%esi)
801027bc:	8b 45 e0             	mov    -0x20(%ebp),%eax
801027bf:	89 46 10             	mov    %eax,0x10(%esi)
801027c2:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801027c5:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801027c8:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
801027cf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801027d2:	5b                   	pop    %ebx
801027d3:	5e                   	pop    %esi
801027d4:	5f                   	pop    %edi
801027d5:	5d                   	pop    %ebp
801027d6:	c3                   	ret    

801027d7 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801027d7:	55                   	push   %ebp
801027d8:	89 e5                	mov    %esp,%ebp
801027da:	53                   	push   %ebx
801027db:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801027de:	ff 35 f4 26 13 80    	pushl  0x801326f4
801027e4:	ff 35 04 27 13 80    	pushl  0x80132704
801027ea:	e8 7d d9 ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801027ef:	8b 58 5c             	mov    0x5c(%eax),%ebx
801027f2:	89 1d 08 27 13 80    	mov    %ebx,0x80132708
  for (i = 0; i < log.lh.n; i++) {
801027f8:	83 c4 10             	add    $0x10,%esp
801027fb:	ba 00 00 00 00       	mov    $0x0,%edx
80102800:	eb 0e                	jmp    80102810 <read_head+0x39>
    log.lh.block[i] = lh->block[i];
80102802:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102806:	89 0c 95 0c 27 13 80 	mov    %ecx,-0x7fecd8f4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010280d:	83 c2 01             	add    $0x1,%edx
80102810:	39 d3                	cmp    %edx,%ebx
80102812:	7f ee                	jg     80102802 <read_head+0x2b>
  }
  brelse(buf);
80102814:	83 ec 0c             	sub    $0xc,%esp
80102817:	50                   	push   %eax
80102818:	e8 b8 d9 ff ff       	call   801001d5 <brelse>
}
8010281d:	83 c4 10             	add    $0x10,%esp
80102820:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102823:	c9                   	leave  
80102824:	c3                   	ret    

80102825 <install_trans>:
{
80102825:	55                   	push   %ebp
80102826:	89 e5                	mov    %esp,%ebp
80102828:	57                   	push   %edi
80102829:	56                   	push   %esi
8010282a:	53                   	push   %ebx
8010282b:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010282e:	bb 00 00 00 00       	mov    $0x0,%ebx
80102833:	eb 66                	jmp    8010289b <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102835:	89 d8                	mov    %ebx,%eax
80102837:	03 05 f4 26 13 80    	add    0x801326f4,%eax
8010283d:	83 c0 01             	add    $0x1,%eax
80102840:	83 ec 08             	sub    $0x8,%esp
80102843:	50                   	push   %eax
80102844:	ff 35 04 27 13 80    	pushl  0x80132704
8010284a:	e8 1d d9 ff ff       	call   8010016c <bread>
8010284f:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
80102851:	83 c4 08             	add    $0x8,%esp
80102854:	ff 34 9d 0c 27 13 80 	pushl  -0x7fecd8f4(,%ebx,4)
8010285b:	ff 35 04 27 13 80    	pushl  0x80132704
80102861:	e8 06 d9 ff ff       	call   8010016c <bread>
80102866:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102868:	8d 57 5c             	lea    0x5c(%edi),%edx
8010286b:	8d 40 5c             	lea    0x5c(%eax),%eax
8010286e:	83 c4 0c             	add    $0xc,%esp
80102871:	68 00 02 00 00       	push   $0x200
80102876:	52                   	push   %edx
80102877:	50                   	push   %eax
80102878:	e8 c0 16 00 00       	call   80103f3d <memmove>
    bwrite(dbuf);  // write dst to disk
8010287d:	89 34 24             	mov    %esi,(%esp)
80102880:	e8 15 d9 ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102885:	89 3c 24             	mov    %edi,(%esp)
80102888:	e8 48 d9 ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
8010288d:	89 34 24             	mov    %esi,(%esp)
80102890:	e8 40 d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102895:	83 c3 01             	add    $0x1,%ebx
80102898:	83 c4 10             	add    $0x10,%esp
8010289b:	39 1d 08 27 13 80    	cmp    %ebx,0x80132708
801028a1:	7f 92                	jg     80102835 <install_trans+0x10>
}
801028a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801028a6:	5b                   	pop    %ebx
801028a7:	5e                   	pop    %esi
801028a8:	5f                   	pop    %edi
801028a9:	5d                   	pop    %ebp
801028aa:	c3                   	ret    

801028ab <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801028ab:	55                   	push   %ebp
801028ac:	89 e5                	mov    %esp,%ebp
801028ae:	53                   	push   %ebx
801028af:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801028b2:	ff 35 f4 26 13 80    	pushl  0x801326f4
801028b8:	ff 35 04 27 13 80    	pushl  0x80132704
801028be:	e8 a9 d8 ff ff       	call   8010016c <bread>
801028c3:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801028c5:	8b 0d 08 27 13 80    	mov    0x80132708,%ecx
801028cb:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801028ce:	83 c4 10             	add    $0x10,%esp
801028d1:	b8 00 00 00 00       	mov    $0x0,%eax
801028d6:	eb 0e                	jmp    801028e6 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
801028d8:	8b 14 85 0c 27 13 80 	mov    -0x7fecd8f4(,%eax,4),%edx
801028df:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801028e3:	83 c0 01             	add    $0x1,%eax
801028e6:	39 c1                	cmp    %eax,%ecx
801028e8:	7f ee                	jg     801028d8 <write_head+0x2d>
  }
  bwrite(buf);
801028ea:	83 ec 0c             	sub    $0xc,%esp
801028ed:	53                   	push   %ebx
801028ee:	e8 a7 d8 ff ff       	call   8010019a <bwrite>
  brelse(buf);
801028f3:	89 1c 24             	mov    %ebx,(%esp)
801028f6:	e8 da d8 ff ff       	call   801001d5 <brelse>
}
801028fb:	83 c4 10             	add    $0x10,%esp
801028fe:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102901:	c9                   	leave  
80102902:	c3                   	ret    

80102903 <recover_from_log>:

static void
recover_from_log(void)
{
80102903:	55                   	push   %ebp
80102904:	89 e5                	mov    %esp,%ebp
80102906:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102909:	e8 c9 fe ff ff       	call   801027d7 <read_head>
  install_trans(); // if committed, copy from log to disk
8010290e:	e8 12 ff ff ff       	call   80102825 <install_trans>
  log.lh.n = 0;
80102913:	c7 05 08 27 13 80 00 	movl   $0x0,0x80132708
8010291a:	00 00 00 
  write_head(); // clear the log
8010291d:	e8 89 ff ff ff       	call   801028ab <write_head>
}
80102922:	c9                   	leave  
80102923:	c3                   	ret    

80102924 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102924:	55                   	push   %ebp
80102925:	89 e5                	mov    %esp,%ebp
80102927:	57                   	push   %edi
80102928:	56                   	push   %esi
80102929:	53                   	push   %ebx
8010292a:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010292d:	bb 00 00 00 00       	mov    $0x0,%ebx
80102932:	eb 66                	jmp    8010299a <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102934:	89 d8                	mov    %ebx,%eax
80102936:	03 05 f4 26 13 80    	add    0x801326f4,%eax
8010293c:	83 c0 01             	add    $0x1,%eax
8010293f:	83 ec 08             	sub    $0x8,%esp
80102942:	50                   	push   %eax
80102943:	ff 35 04 27 13 80    	pushl  0x80132704
80102949:	e8 1e d8 ff ff       	call   8010016c <bread>
8010294e:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
80102950:	83 c4 08             	add    $0x8,%esp
80102953:	ff 34 9d 0c 27 13 80 	pushl  -0x7fecd8f4(,%ebx,4)
8010295a:	ff 35 04 27 13 80    	pushl  0x80132704
80102960:	e8 07 d8 ff ff       	call   8010016c <bread>
80102965:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102967:	8d 50 5c             	lea    0x5c(%eax),%edx
8010296a:	8d 46 5c             	lea    0x5c(%esi),%eax
8010296d:	83 c4 0c             	add    $0xc,%esp
80102970:	68 00 02 00 00       	push   $0x200
80102975:	52                   	push   %edx
80102976:	50                   	push   %eax
80102977:	e8 c1 15 00 00       	call   80103f3d <memmove>
    bwrite(to);  // write the log
8010297c:	89 34 24             	mov    %esi,(%esp)
8010297f:	e8 16 d8 ff ff       	call   8010019a <bwrite>
    brelse(from);
80102984:	89 3c 24             	mov    %edi,(%esp)
80102987:	e8 49 d8 ff ff       	call   801001d5 <brelse>
    brelse(to);
8010298c:	89 34 24             	mov    %esi,(%esp)
8010298f:	e8 41 d8 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102994:	83 c3 01             	add    $0x1,%ebx
80102997:	83 c4 10             	add    $0x10,%esp
8010299a:	39 1d 08 27 13 80    	cmp    %ebx,0x80132708
801029a0:	7f 92                	jg     80102934 <write_log+0x10>
  }
}
801029a2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801029a5:	5b                   	pop    %ebx
801029a6:	5e                   	pop    %esi
801029a7:	5f                   	pop    %edi
801029a8:	5d                   	pop    %ebp
801029a9:	c3                   	ret    

801029aa <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
801029aa:	83 3d 08 27 13 80 00 	cmpl   $0x0,0x80132708
801029b1:	7e 26                	jle    801029d9 <commit+0x2f>
{
801029b3:	55                   	push   %ebp
801029b4:	89 e5                	mov    %esp,%ebp
801029b6:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
801029b9:	e8 66 ff ff ff       	call   80102924 <write_log>
    write_head();    // Write header to disk -- the real commit
801029be:	e8 e8 fe ff ff       	call   801028ab <write_head>
    install_trans(); // Now install writes to home locations
801029c3:	e8 5d fe ff ff       	call   80102825 <install_trans>
    log.lh.n = 0;
801029c8:	c7 05 08 27 13 80 00 	movl   $0x0,0x80132708
801029cf:	00 00 00 
    write_head();    // Erase the transaction from the log
801029d2:	e8 d4 fe ff ff       	call   801028ab <write_head>
  }
}
801029d7:	c9                   	leave  
801029d8:	c3                   	ret    
801029d9:	f3 c3                	repz ret 

801029db <initlog>:
{
801029db:	55                   	push   %ebp
801029dc:	89 e5                	mov    %esp,%ebp
801029de:	53                   	push   %ebx
801029df:	83 ec 2c             	sub    $0x2c,%esp
801029e2:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801029e5:	68 20 6c 10 80       	push   $0x80106c20
801029ea:	68 c0 26 13 80       	push   $0x801326c0
801029ef:	e8 e6 12 00 00       	call   80103cda <initlock>
  readsb(dev, &sb);
801029f4:	83 c4 08             	add    $0x8,%esp
801029f7:	8d 45 dc             	lea    -0x24(%ebp),%eax
801029fa:	50                   	push   %eax
801029fb:	53                   	push   %ebx
801029fc:	e8 35 e8 ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
80102a01:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102a04:	a3 f4 26 13 80       	mov    %eax,0x801326f4
  log.size = sb.nlog;
80102a09:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102a0c:	a3 f8 26 13 80       	mov    %eax,0x801326f8
  log.dev = dev;
80102a11:	89 1d 04 27 13 80    	mov    %ebx,0x80132704
  recover_from_log();
80102a17:	e8 e7 fe ff ff       	call   80102903 <recover_from_log>
}
80102a1c:	83 c4 10             	add    $0x10,%esp
80102a1f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a22:	c9                   	leave  
80102a23:	c3                   	ret    

80102a24 <begin_op>:
{
80102a24:	55                   	push   %ebp
80102a25:	89 e5                	mov    %esp,%ebp
80102a27:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102a2a:	68 c0 26 13 80       	push   $0x801326c0
80102a2f:	e8 e2 13 00 00       	call   80103e16 <acquire>
80102a34:	83 c4 10             	add    $0x10,%esp
80102a37:	eb 15                	jmp    80102a4e <begin_op+0x2a>
      sleep(&log, &log.lock);
80102a39:	83 ec 08             	sub    $0x8,%esp
80102a3c:	68 c0 26 13 80       	push   $0x801326c0
80102a41:	68 c0 26 13 80       	push   $0x801326c0
80102a46:	e8 d0 0e 00 00       	call   8010391b <sleep>
80102a4b:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
80102a4e:	83 3d 00 27 13 80 00 	cmpl   $0x0,0x80132700
80102a55:	75 e2                	jne    80102a39 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102a57:	a1 fc 26 13 80       	mov    0x801326fc,%eax
80102a5c:	83 c0 01             	add    $0x1,%eax
80102a5f:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102a62:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102a65:	03 15 08 27 13 80    	add    0x80132708,%edx
80102a6b:	83 fa 1e             	cmp    $0x1e,%edx
80102a6e:	7e 17                	jle    80102a87 <begin_op+0x63>
      sleep(&log, &log.lock);
80102a70:	83 ec 08             	sub    $0x8,%esp
80102a73:	68 c0 26 13 80       	push   $0x801326c0
80102a78:	68 c0 26 13 80       	push   $0x801326c0
80102a7d:	e8 99 0e 00 00       	call   8010391b <sleep>
80102a82:	83 c4 10             	add    $0x10,%esp
80102a85:	eb c7                	jmp    80102a4e <begin_op+0x2a>
      log.outstanding += 1;
80102a87:	a3 fc 26 13 80       	mov    %eax,0x801326fc
      release(&log.lock);
80102a8c:	83 ec 0c             	sub    $0xc,%esp
80102a8f:	68 c0 26 13 80       	push   $0x801326c0
80102a94:	e8 e2 13 00 00       	call   80103e7b <release>
}
80102a99:	83 c4 10             	add    $0x10,%esp
80102a9c:	c9                   	leave  
80102a9d:	c3                   	ret    

80102a9e <end_op>:
{
80102a9e:	55                   	push   %ebp
80102a9f:	89 e5                	mov    %esp,%ebp
80102aa1:	53                   	push   %ebx
80102aa2:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102aa5:	68 c0 26 13 80       	push   $0x801326c0
80102aaa:	e8 67 13 00 00       	call   80103e16 <acquire>
  log.outstanding -= 1;
80102aaf:	a1 fc 26 13 80       	mov    0x801326fc,%eax
80102ab4:	83 e8 01             	sub    $0x1,%eax
80102ab7:	a3 fc 26 13 80       	mov    %eax,0x801326fc
  if(log.committing)
80102abc:	8b 1d 00 27 13 80    	mov    0x80132700,%ebx
80102ac2:	83 c4 10             	add    $0x10,%esp
80102ac5:	85 db                	test   %ebx,%ebx
80102ac7:	75 2c                	jne    80102af5 <end_op+0x57>
  if(log.outstanding == 0){
80102ac9:	85 c0                	test   %eax,%eax
80102acb:	75 35                	jne    80102b02 <end_op+0x64>
    log.committing = 1;
80102acd:	c7 05 00 27 13 80 01 	movl   $0x1,0x80132700
80102ad4:	00 00 00 
    do_commit = 1;
80102ad7:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102adc:	83 ec 0c             	sub    $0xc,%esp
80102adf:	68 c0 26 13 80       	push   $0x801326c0
80102ae4:	e8 92 13 00 00       	call   80103e7b <release>
  if(do_commit){
80102ae9:	83 c4 10             	add    $0x10,%esp
80102aec:	85 db                	test   %ebx,%ebx
80102aee:	75 24                	jne    80102b14 <end_op+0x76>
}
80102af0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102af3:	c9                   	leave  
80102af4:	c3                   	ret    
    panic("log.committing");
80102af5:	83 ec 0c             	sub    $0xc,%esp
80102af8:	68 24 6c 10 80       	push   $0x80106c24
80102afd:	e8 46 d8 ff ff       	call   80100348 <panic>
    wakeup(&log);
80102b02:	83 ec 0c             	sub    $0xc,%esp
80102b05:	68 c0 26 13 80       	push   $0x801326c0
80102b0a:	e8 71 0f 00 00       	call   80103a80 <wakeup>
80102b0f:	83 c4 10             	add    $0x10,%esp
80102b12:	eb c8                	jmp    80102adc <end_op+0x3e>
    commit();
80102b14:	e8 91 fe ff ff       	call   801029aa <commit>
    acquire(&log.lock);
80102b19:	83 ec 0c             	sub    $0xc,%esp
80102b1c:	68 c0 26 13 80       	push   $0x801326c0
80102b21:	e8 f0 12 00 00       	call   80103e16 <acquire>
    log.committing = 0;
80102b26:	c7 05 00 27 13 80 00 	movl   $0x0,0x80132700
80102b2d:	00 00 00 
    wakeup(&log);
80102b30:	c7 04 24 c0 26 13 80 	movl   $0x801326c0,(%esp)
80102b37:	e8 44 0f 00 00       	call   80103a80 <wakeup>
    release(&log.lock);
80102b3c:	c7 04 24 c0 26 13 80 	movl   $0x801326c0,(%esp)
80102b43:	e8 33 13 00 00       	call   80103e7b <release>
80102b48:	83 c4 10             	add    $0x10,%esp
}
80102b4b:	eb a3                	jmp    80102af0 <end_op+0x52>

80102b4d <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102b4d:	55                   	push   %ebp
80102b4e:	89 e5                	mov    %esp,%ebp
80102b50:	53                   	push   %ebx
80102b51:	83 ec 04             	sub    $0x4,%esp
80102b54:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102b57:	8b 15 08 27 13 80    	mov    0x80132708,%edx
80102b5d:	83 fa 1d             	cmp    $0x1d,%edx
80102b60:	7f 45                	jg     80102ba7 <log_write+0x5a>
80102b62:	a1 f8 26 13 80       	mov    0x801326f8,%eax
80102b67:	83 e8 01             	sub    $0x1,%eax
80102b6a:	39 c2                	cmp    %eax,%edx
80102b6c:	7d 39                	jge    80102ba7 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102b6e:	83 3d fc 26 13 80 00 	cmpl   $0x0,0x801326fc
80102b75:	7e 3d                	jle    80102bb4 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102b77:	83 ec 0c             	sub    $0xc,%esp
80102b7a:	68 c0 26 13 80       	push   $0x801326c0
80102b7f:	e8 92 12 00 00       	call   80103e16 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102b84:	83 c4 10             	add    $0x10,%esp
80102b87:	b8 00 00 00 00       	mov    $0x0,%eax
80102b8c:	8b 15 08 27 13 80    	mov    0x80132708,%edx
80102b92:	39 c2                	cmp    %eax,%edx
80102b94:	7e 2b                	jle    80102bc1 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102b96:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102b99:	39 0c 85 0c 27 13 80 	cmp    %ecx,-0x7fecd8f4(,%eax,4)
80102ba0:	74 1f                	je     80102bc1 <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102ba2:	83 c0 01             	add    $0x1,%eax
80102ba5:	eb e5                	jmp    80102b8c <log_write+0x3f>
    panic("too big a transaction");
80102ba7:	83 ec 0c             	sub    $0xc,%esp
80102baa:	68 33 6c 10 80       	push   $0x80106c33
80102baf:	e8 94 d7 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102bb4:	83 ec 0c             	sub    $0xc,%esp
80102bb7:	68 49 6c 10 80       	push   $0x80106c49
80102bbc:	e8 87 d7 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102bc1:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102bc4:	89 0c 85 0c 27 13 80 	mov    %ecx,-0x7fecd8f4(,%eax,4)
  if (i == log.lh.n)
80102bcb:	39 c2                	cmp    %eax,%edx
80102bcd:	74 18                	je     80102be7 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102bcf:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102bd2:	83 ec 0c             	sub    $0xc,%esp
80102bd5:	68 c0 26 13 80       	push   $0x801326c0
80102bda:	e8 9c 12 00 00       	call   80103e7b <release>
}
80102bdf:	83 c4 10             	add    $0x10,%esp
80102be2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102be5:	c9                   	leave  
80102be6:	c3                   	ret    
    log.lh.n++;
80102be7:	83 c2 01             	add    $0x1,%edx
80102bea:	89 15 08 27 13 80    	mov    %edx,0x80132708
80102bf0:	eb dd                	jmp    80102bcf <log_write+0x82>

80102bf2 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102bf2:	55                   	push   %ebp
80102bf3:	89 e5                	mov    %esp,%ebp
80102bf5:	53                   	push   %ebx
80102bf6:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102bf9:	68 8a 00 00 00       	push   $0x8a
80102bfe:	68 8c a4 10 80       	push   $0x8010a48c
80102c03:	68 00 70 00 80       	push   $0x80007000
80102c08:	e8 30 13 00 00       	call   80103f3d <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102c0d:	83 c4 10             	add    $0x10,%esp
80102c10:	bb c0 27 13 80       	mov    $0x801327c0,%ebx
80102c15:	eb 06                	jmp    80102c1d <startothers+0x2b>
80102c17:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102c1d:	69 05 40 2d 13 80 b0 	imul   $0xb0,0x80132d40,%eax
80102c24:	00 00 00 
80102c27:	05 c0 27 13 80       	add    $0x801327c0,%eax
80102c2c:	39 d8                	cmp    %ebx,%eax
80102c2e:	76 4c                	jbe    80102c7c <startothers+0x8a>
    if(c == mycpu())  // We've started already.
80102c30:	e8 ff 06 00 00       	call   80103334 <mycpu>
80102c35:	39 d8                	cmp    %ebx,%eax
80102c37:	74 de                	je     80102c17 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102c39:	e8 15 f6 ff ff       	call   80102253 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102c3e:	05 00 10 00 00       	add    $0x1000,%eax
80102c43:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102c48:	c7 05 f8 6f 00 80 c0 	movl   $0x80102cc0,0x80006ff8
80102c4f:	2c 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102c52:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102c59:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102c5c:	83 ec 08             	sub    $0x8,%esp
80102c5f:	68 00 70 00 00       	push   $0x7000
80102c64:	0f b6 03             	movzbl (%ebx),%eax
80102c67:	50                   	push   %eax
80102c68:	e8 c6 f9 ff ff       	call   80102633 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102c6d:	83 c4 10             	add    $0x10,%esp
80102c70:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102c76:	85 c0                	test   %eax,%eax
80102c78:	74 f6                	je     80102c70 <startothers+0x7e>
80102c7a:	eb 9b                	jmp    80102c17 <startothers+0x25>
      ;
  }
}
80102c7c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102c7f:	c9                   	leave  
80102c80:	c3                   	ret    

80102c81 <mpmain>:
{
80102c81:	55                   	push   %ebp
80102c82:	89 e5                	mov    %esp,%ebp
80102c84:	53                   	push   %ebx
80102c85:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102c88:	e8 03 07 00 00       	call   80103390 <cpuid>
80102c8d:	89 c3                	mov    %eax,%ebx
80102c8f:	e8 fc 06 00 00       	call   80103390 <cpuid>
80102c94:	83 ec 04             	sub    $0x4,%esp
80102c97:	53                   	push   %ebx
80102c98:	50                   	push   %eax
80102c99:	68 64 6c 10 80       	push   $0x80106c64
80102c9e:	e8 68 d9 ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102ca3:	e8 f9 23 00 00       	call   801050a1 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102ca8:	e8 87 06 00 00       	call   80103334 <mycpu>
80102cad:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102caf:	b8 01 00 00 00       	mov    $0x1,%eax
80102cb4:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102cbb:	e8 36 0a 00 00       	call   801036f6 <scheduler>

80102cc0 <mpenter>:
{
80102cc0:	55                   	push   %ebp
80102cc1:	89 e5                	mov    %esp,%ebp
80102cc3:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102cc6:	e8 df 33 00 00       	call   801060aa <switchkvm>
  seginit();
80102ccb:	e8 8e 32 00 00       	call   80105f5e <seginit>
  lapicinit();
80102cd0:	e8 15 f8 ff ff       	call   801024ea <lapicinit>
  mpmain();
80102cd5:	e8 a7 ff ff ff       	call   80102c81 <mpmain>

80102cda <main>:
{
80102cda:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102cde:	83 e4 f0             	and    $0xfffffff0,%esp
80102ce1:	ff 71 fc             	pushl  -0x4(%ecx)
80102ce4:	55                   	push   %ebp
80102ce5:	89 e5                	mov    %esp,%ebp
80102ce7:	51                   	push   %ecx
80102ce8:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102ceb:	68 00 00 40 80       	push   $0x80400000
80102cf0:	68 e8 54 13 80       	push   $0x801354e8
80102cf5:	e8 e6 f4 ff ff       	call   801021e0 <kinit1>
  kvmalloc();      // kernel page table
80102cfa:	e8 6c 38 00 00       	call   8010656b <kvmalloc>
  mpinit();        // detect other processors
80102cff:	e8 c9 01 00 00       	call   80102ecd <mpinit>
  lapicinit();     // interrupt controller
80102d04:	e8 e1 f7 ff ff       	call   801024ea <lapicinit>
  seginit();       // segment descriptors
80102d09:	e8 50 32 00 00       	call   80105f5e <seginit>
  picinit();       // disable pic
80102d0e:	e8 82 02 00 00       	call   80102f95 <picinit>
  ioapicinit();    // another interrupt controller
80102d13:	e8 e2 f1 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102d18:	e8 71 db ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102d1d:	e8 2d 26 00 00       	call   8010534f <uartinit>
  pinit();         // process table
80102d22:	e8 f3 05 00 00       	call   8010331a <pinit>
  tvinit();        // trap vectors
80102d27:	e8 c4 22 00 00       	call   80104ff0 <tvinit>
  binit();         // buffer cache
80102d2c:	e8 c3 d3 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102d31:	e8 dd de ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102d36:	e8 c5 ef ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102d3b:	e8 b2 fe ff ff       	call   80102bf2 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102d40:	83 c4 08             	add    $0x8,%esp
80102d43:	68 00 00 00 8e       	push   $0x8e000000
80102d48:	68 00 00 40 80       	push   $0x80400000
80102d4d:	e8 c0 f4 ff ff       	call   80102212 <kinit2>
  userinit();      // first user process
80102d52:	e8 44 07 00 00       	call   8010349b <userinit>
  mpmain();        // finish this processor's setup
80102d57:	e8 25 ff ff ff       	call   80102c81 <mpmain>

80102d5c <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102d5c:	55                   	push   %ebp
80102d5d:	89 e5                	mov    %esp,%ebp
80102d5f:	56                   	push   %esi
80102d60:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102d61:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102d66:	b9 00 00 00 00       	mov    $0x0,%ecx
80102d6b:	eb 09                	jmp    80102d76 <sum+0x1a>
    sum += addr[i];
80102d6d:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102d71:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102d73:	83 c1 01             	add    $0x1,%ecx
80102d76:	39 d1                	cmp    %edx,%ecx
80102d78:	7c f3                	jl     80102d6d <sum+0x11>
  return sum;
}
80102d7a:	89 d8                	mov    %ebx,%eax
80102d7c:	5b                   	pop    %ebx
80102d7d:	5e                   	pop    %esi
80102d7e:	5d                   	pop    %ebp
80102d7f:	c3                   	ret    

80102d80 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102d80:	55                   	push   %ebp
80102d81:	89 e5                	mov    %esp,%ebp
80102d83:	56                   	push   %esi
80102d84:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102d85:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102d8b:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102d8d:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102d8f:	eb 03                	jmp    80102d94 <mpsearch1+0x14>
80102d91:	83 c3 10             	add    $0x10,%ebx
80102d94:	39 f3                	cmp    %esi,%ebx
80102d96:	73 29                	jae    80102dc1 <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102d98:	83 ec 04             	sub    $0x4,%esp
80102d9b:	6a 04                	push   $0x4
80102d9d:	68 78 6c 10 80       	push   $0x80106c78
80102da2:	53                   	push   %ebx
80102da3:	e8 60 11 00 00       	call   80103f08 <memcmp>
80102da8:	83 c4 10             	add    $0x10,%esp
80102dab:	85 c0                	test   %eax,%eax
80102dad:	75 e2                	jne    80102d91 <mpsearch1+0x11>
80102daf:	ba 10 00 00 00       	mov    $0x10,%edx
80102db4:	89 d8                	mov    %ebx,%eax
80102db6:	e8 a1 ff ff ff       	call   80102d5c <sum>
80102dbb:	84 c0                	test   %al,%al
80102dbd:	75 d2                	jne    80102d91 <mpsearch1+0x11>
80102dbf:	eb 05                	jmp    80102dc6 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102dc1:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102dc6:	89 d8                	mov    %ebx,%eax
80102dc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102dcb:	5b                   	pop    %ebx
80102dcc:	5e                   	pop    %esi
80102dcd:	5d                   	pop    %ebp
80102dce:	c3                   	ret    

80102dcf <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102dcf:	55                   	push   %ebp
80102dd0:	89 e5                	mov    %esp,%ebp
80102dd2:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102dd5:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102ddc:	c1 e0 08             	shl    $0x8,%eax
80102ddf:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102de6:	09 d0                	or     %edx,%eax
80102de8:	c1 e0 04             	shl    $0x4,%eax
80102deb:	85 c0                	test   %eax,%eax
80102ded:	74 1f                	je     80102e0e <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102def:	ba 00 04 00 00       	mov    $0x400,%edx
80102df4:	e8 87 ff ff ff       	call   80102d80 <mpsearch1>
80102df9:	85 c0                	test   %eax,%eax
80102dfb:	75 0f                	jne    80102e0c <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102dfd:	ba 00 00 01 00       	mov    $0x10000,%edx
80102e02:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102e07:	e8 74 ff ff ff       	call   80102d80 <mpsearch1>
}
80102e0c:	c9                   	leave  
80102e0d:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102e0e:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102e15:	c1 e0 08             	shl    $0x8,%eax
80102e18:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102e1f:	09 d0                	or     %edx,%eax
80102e21:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102e24:	2d 00 04 00 00       	sub    $0x400,%eax
80102e29:	ba 00 04 00 00       	mov    $0x400,%edx
80102e2e:	e8 4d ff ff ff       	call   80102d80 <mpsearch1>
80102e33:	85 c0                	test   %eax,%eax
80102e35:	75 d5                	jne    80102e0c <mpsearch+0x3d>
80102e37:	eb c4                	jmp    80102dfd <mpsearch+0x2e>

80102e39 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102e39:	55                   	push   %ebp
80102e3a:	89 e5                	mov    %esp,%ebp
80102e3c:	57                   	push   %edi
80102e3d:	56                   	push   %esi
80102e3e:	53                   	push   %ebx
80102e3f:	83 ec 1c             	sub    $0x1c,%esp
80102e42:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102e45:	e8 85 ff ff ff       	call   80102dcf <mpsearch>
80102e4a:	85 c0                	test   %eax,%eax
80102e4c:	74 5c                	je     80102eaa <mpconfig+0x71>
80102e4e:	89 c7                	mov    %eax,%edi
80102e50:	8b 58 04             	mov    0x4(%eax),%ebx
80102e53:	85 db                	test   %ebx,%ebx
80102e55:	74 5a                	je     80102eb1 <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102e57:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102e5d:	83 ec 04             	sub    $0x4,%esp
80102e60:	6a 04                	push   $0x4
80102e62:	68 7d 6c 10 80       	push   $0x80106c7d
80102e67:	56                   	push   %esi
80102e68:	e8 9b 10 00 00       	call   80103f08 <memcmp>
80102e6d:	83 c4 10             	add    $0x10,%esp
80102e70:	85 c0                	test   %eax,%eax
80102e72:	75 44                	jne    80102eb8 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102e74:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102e7b:	3c 01                	cmp    $0x1,%al
80102e7d:	0f 95 c2             	setne  %dl
80102e80:	3c 04                	cmp    $0x4,%al
80102e82:	0f 95 c0             	setne  %al
80102e85:	84 c2                	test   %al,%dl
80102e87:	75 36                	jne    80102ebf <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102e89:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102e90:	89 f0                	mov    %esi,%eax
80102e92:	e8 c5 fe ff ff       	call   80102d5c <sum>
80102e97:	84 c0                	test   %al,%al
80102e99:	75 2b                	jne    80102ec6 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102e9b:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102e9e:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102ea0:	89 f0                	mov    %esi,%eax
80102ea2:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102ea5:	5b                   	pop    %ebx
80102ea6:	5e                   	pop    %esi
80102ea7:	5f                   	pop    %edi
80102ea8:	5d                   	pop    %ebp
80102ea9:	c3                   	ret    
    return 0;
80102eaa:	be 00 00 00 00       	mov    $0x0,%esi
80102eaf:	eb ef                	jmp    80102ea0 <mpconfig+0x67>
80102eb1:	be 00 00 00 00       	mov    $0x0,%esi
80102eb6:	eb e8                	jmp    80102ea0 <mpconfig+0x67>
    return 0;
80102eb8:	be 00 00 00 00       	mov    $0x0,%esi
80102ebd:	eb e1                	jmp    80102ea0 <mpconfig+0x67>
    return 0;
80102ebf:	be 00 00 00 00       	mov    $0x0,%esi
80102ec4:	eb da                	jmp    80102ea0 <mpconfig+0x67>
    return 0;
80102ec6:	be 00 00 00 00       	mov    $0x0,%esi
80102ecb:	eb d3                	jmp    80102ea0 <mpconfig+0x67>

80102ecd <mpinit>:

void
mpinit(void)
{
80102ecd:	55                   	push   %ebp
80102ece:	89 e5                	mov    %esp,%ebp
80102ed0:	57                   	push   %edi
80102ed1:	56                   	push   %esi
80102ed2:	53                   	push   %ebx
80102ed3:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102ed6:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102ed9:	e8 5b ff ff ff       	call   80102e39 <mpconfig>
80102ede:	85 c0                	test   %eax,%eax
80102ee0:	74 19                	je     80102efb <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102ee2:	8b 50 24             	mov    0x24(%eax),%edx
80102ee5:	89 15 a0 26 13 80    	mov    %edx,0x801326a0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102eeb:	8d 50 2c             	lea    0x2c(%eax),%edx
80102eee:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102ef2:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102ef4:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102ef9:	eb 34                	jmp    80102f2f <mpinit+0x62>
    panic("Expect to run on an SMP");
80102efb:	83 ec 0c             	sub    $0xc,%esp
80102efe:	68 82 6c 10 80       	push   $0x80106c82
80102f03:	e8 40 d4 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102f08:	8b 35 40 2d 13 80    	mov    0x80132d40,%esi
80102f0e:	83 fe 07             	cmp    $0x7,%esi
80102f11:	7f 19                	jg     80102f2c <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102f13:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102f17:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102f1d:	88 87 c0 27 13 80    	mov    %al,-0x7fecd840(%edi)
        ncpu++;
80102f23:	83 c6 01             	add    $0x1,%esi
80102f26:	89 35 40 2d 13 80    	mov    %esi,0x80132d40
      }
      p += sizeof(struct mpproc);
80102f2c:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102f2f:	39 ca                	cmp    %ecx,%edx
80102f31:	73 2b                	jae    80102f5e <mpinit+0x91>
    switch(*p){
80102f33:	0f b6 02             	movzbl (%edx),%eax
80102f36:	3c 04                	cmp    $0x4,%al
80102f38:	77 1d                	ja     80102f57 <mpinit+0x8a>
80102f3a:	0f b6 c0             	movzbl %al,%eax
80102f3d:	ff 24 85 bc 6c 10 80 	jmp    *-0x7fef9344(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102f44:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102f48:	a2 a0 27 13 80       	mov    %al,0x801327a0
      p += sizeof(struct mpioapic);
80102f4d:	83 c2 08             	add    $0x8,%edx
      continue;
80102f50:	eb dd                	jmp    80102f2f <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102f52:	83 c2 08             	add    $0x8,%edx
      continue;
80102f55:	eb d8                	jmp    80102f2f <mpinit+0x62>
    default:
      ismp = 0;
80102f57:	bb 00 00 00 00       	mov    $0x0,%ebx
80102f5c:	eb d1                	jmp    80102f2f <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102f5e:	85 db                	test   %ebx,%ebx
80102f60:	74 26                	je     80102f88 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102f62:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102f65:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102f69:	74 15                	je     80102f80 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f6b:	b8 70 00 00 00       	mov    $0x70,%eax
80102f70:	ba 22 00 00 00       	mov    $0x22,%edx
80102f75:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102f76:	ba 23 00 00 00       	mov    $0x23,%edx
80102f7b:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102f7c:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102f7f:	ee                   	out    %al,(%dx)
  }
}
80102f80:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f83:	5b                   	pop    %ebx
80102f84:	5e                   	pop    %esi
80102f85:	5f                   	pop    %edi
80102f86:	5d                   	pop    %ebp
80102f87:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102f88:	83 ec 0c             	sub    $0xc,%esp
80102f8b:	68 9c 6c 10 80       	push   $0x80106c9c
80102f90:	e8 b3 d3 ff ff       	call   80100348 <panic>

80102f95 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102f95:	55                   	push   %ebp
80102f96:	89 e5                	mov    %esp,%ebp
80102f98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102f9d:	ba 21 00 00 00       	mov    $0x21,%edx
80102fa2:	ee                   	out    %al,(%dx)
80102fa3:	ba a1 00 00 00       	mov    $0xa1,%edx
80102fa8:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102fa9:	5d                   	pop    %ebp
80102faa:	c3                   	ret    

80102fab <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102fab:	55                   	push   %ebp
80102fac:	89 e5                	mov    %esp,%ebp
80102fae:	57                   	push   %edi
80102faf:	56                   	push   %esi
80102fb0:	53                   	push   %ebx
80102fb1:	83 ec 0c             	sub    $0xc,%esp
80102fb4:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102fb7:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102fba:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102fc0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102fc6:	e8 62 dc ff ff       	call   80100c2d <filealloc>
80102fcb:	89 03                	mov    %eax,(%ebx)
80102fcd:	85 c0                	test   %eax,%eax
80102fcf:	74 16                	je     80102fe7 <pipealloc+0x3c>
80102fd1:	e8 57 dc ff ff       	call   80100c2d <filealloc>
80102fd6:	89 06                	mov    %eax,(%esi)
80102fd8:	85 c0                	test   %eax,%eax
80102fda:	74 0b                	je     80102fe7 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102fdc:	e8 72 f2 ff ff       	call   80102253 <kalloc>
80102fe1:	89 c7                	mov    %eax,%edi
80102fe3:	85 c0                	test   %eax,%eax
80102fe5:	75 35                	jne    8010301c <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102fe7:	8b 03                	mov    (%ebx),%eax
80102fe9:	85 c0                	test   %eax,%eax
80102feb:	74 0c                	je     80102ff9 <pipealloc+0x4e>
    fileclose(*f0);
80102fed:	83 ec 0c             	sub    $0xc,%esp
80102ff0:	50                   	push   %eax
80102ff1:	e8 dd dc ff ff       	call   80100cd3 <fileclose>
80102ff6:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102ff9:	8b 06                	mov    (%esi),%eax
80102ffb:	85 c0                	test   %eax,%eax
80102ffd:	0f 84 8b 00 00 00    	je     8010308e <pipealloc+0xe3>
    fileclose(*f1);
80103003:	83 ec 0c             	sub    $0xc,%esp
80103006:	50                   	push   %eax
80103007:	e8 c7 dc ff ff       	call   80100cd3 <fileclose>
8010300c:	83 c4 10             	add    $0x10,%esp
  return -1;
8010300f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103014:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103017:	5b                   	pop    %ebx
80103018:	5e                   	pop    %esi
80103019:	5f                   	pop    %edi
8010301a:	5d                   	pop    %ebp
8010301b:	c3                   	ret    
  p->readopen = 1;
8010301c:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80103023:	00 00 00 
  p->writeopen = 1;
80103026:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
8010302d:	00 00 00 
  p->nwrite = 0;
80103030:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80103037:	00 00 00 
  p->nread = 0;
8010303a:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80103041:	00 00 00 
  initlock(&p->lock, "pipe");
80103044:	83 ec 08             	sub    $0x8,%esp
80103047:	68 d0 6c 10 80       	push   $0x80106cd0
8010304c:	50                   	push   %eax
8010304d:	e8 88 0c 00 00       	call   80103cda <initlock>
  (*f0)->type = FD_PIPE;
80103052:	8b 03                	mov    (%ebx),%eax
80103054:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
8010305a:	8b 03                	mov    (%ebx),%eax
8010305c:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80103060:	8b 03                	mov    (%ebx),%eax
80103062:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80103066:	8b 03                	mov    (%ebx),%eax
80103068:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
8010306b:	8b 06                	mov    (%esi),%eax
8010306d:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80103073:	8b 06                	mov    (%esi),%eax
80103075:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80103079:	8b 06                	mov    (%esi),%eax
8010307b:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
8010307f:	8b 06                	mov    (%esi),%eax
80103081:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80103084:	83 c4 10             	add    $0x10,%esp
80103087:	b8 00 00 00 00       	mov    $0x0,%eax
8010308c:	eb 86                	jmp    80103014 <pipealloc+0x69>
  return -1;
8010308e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103093:	e9 7c ff ff ff       	jmp    80103014 <pipealloc+0x69>

80103098 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80103098:	55                   	push   %ebp
80103099:	89 e5                	mov    %esp,%ebp
8010309b:	53                   	push   %ebx
8010309c:	83 ec 10             	sub    $0x10,%esp
8010309f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
801030a2:	53                   	push   %ebx
801030a3:	e8 6e 0d 00 00       	call   80103e16 <acquire>
  if(writable){
801030a8:	83 c4 10             	add    $0x10,%esp
801030ab:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
801030af:	74 3f                	je     801030f0 <pipeclose+0x58>
    p->writeopen = 0;
801030b1:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
801030b8:	00 00 00 
    wakeup(&p->nread);
801030bb:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030c1:	83 ec 0c             	sub    $0xc,%esp
801030c4:	50                   	push   %eax
801030c5:	e8 b6 09 00 00       	call   80103a80 <wakeup>
801030ca:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
801030cd:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
801030d4:	75 09                	jne    801030df <pipeclose+0x47>
801030d6:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
801030dd:	74 2f                	je     8010310e <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
801030df:	83 ec 0c             	sub    $0xc,%esp
801030e2:	53                   	push   %ebx
801030e3:	e8 93 0d 00 00       	call   80103e7b <release>
801030e8:	83 c4 10             	add    $0x10,%esp
}
801030eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801030ee:	c9                   	leave  
801030ef:	c3                   	ret    
    p->readopen = 0;
801030f0:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
801030f7:	00 00 00 
    wakeup(&p->nwrite);
801030fa:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103100:	83 ec 0c             	sub    $0xc,%esp
80103103:	50                   	push   %eax
80103104:	e8 77 09 00 00       	call   80103a80 <wakeup>
80103109:	83 c4 10             	add    $0x10,%esp
8010310c:	eb bf                	jmp    801030cd <pipeclose+0x35>
    release(&p->lock);
8010310e:	83 ec 0c             	sub    $0xc,%esp
80103111:	53                   	push   %ebx
80103112:	e8 64 0d 00 00       	call   80103e7b <release>
    kfree((char*)p);
80103117:	89 1c 24             	mov    %ebx,(%esp)
8010311a:	e8 f8 ee ff ff       	call   80102017 <kfree>
8010311f:	83 c4 10             	add    $0x10,%esp
80103122:	eb c7                	jmp    801030eb <pipeclose+0x53>

80103124 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80103124:	55                   	push   %ebp
80103125:	89 e5                	mov    %esp,%ebp
80103127:	57                   	push   %edi
80103128:	56                   	push   %esi
80103129:	53                   	push   %ebx
8010312a:	83 ec 18             	sub    $0x18,%esp
8010312d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103130:	89 de                	mov    %ebx,%esi
80103132:	53                   	push   %ebx
80103133:	e8 de 0c 00 00       	call   80103e16 <acquire>
  for(i = 0; i < n; i++){
80103138:	83 c4 10             	add    $0x10,%esp
8010313b:	bf 00 00 00 00       	mov    $0x0,%edi
80103140:	3b 7d 10             	cmp    0x10(%ebp),%edi
80103143:	0f 8d 88 00 00 00    	jge    801031d1 <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103149:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
8010314f:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103155:	05 00 02 00 00       	add    $0x200,%eax
8010315a:	39 c2                	cmp    %eax,%edx
8010315c:	75 51                	jne    801031af <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
8010315e:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103165:	74 2f                	je     80103196 <pipewrite+0x72>
80103167:	e8 3f 02 00 00       	call   801033ab <myproc>
8010316c:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103170:	75 24                	jne    80103196 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80103172:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103178:	83 ec 0c             	sub    $0xc,%esp
8010317b:	50                   	push   %eax
8010317c:	e8 ff 08 00 00       	call   80103a80 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80103181:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103187:	83 c4 08             	add    $0x8,%esp
8010318a:	56                   	push   %esi
8010318b:	50                   	push   %eax
8010318c:	e8 8a 07 00 00       	call   8010391b <sleep>
80103191:	83 c4 10             	add    $0x10,%esp
80103194:	eb b3                	jmp    80103149 <pipewrite+0x25>
        release(&p->lock);
80103196:	83 ec 0c             	sub    $0xc,%esp
80103199:	53                   	push   %ebx
8010319a:	e8 dc 0c 00 00       	call   80103e7b <release>
        return -1;
8010319f:	83 c4 10             	add    $0x10,%esp
801031a2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
801031a7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031aa:	5b                   	pop    %ebx
801031ab:	5e                   	pop    %esi
801031ac:	5f                   	pop    %edi
801031ad:	5d                   	pop    %ebp
801031ae:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801031af:	8d 42 01             	lea    0x1(%edx),%eax
801031b2:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
801031b8:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801031be:	8b 45 0c             	mov    0xc(%ebp),%eax
801031c1:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
801031c5:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801031c9:	83 c7 01             	add    $0x1,%edi
801031cc:	e9 6f ff ff ff       	jmp    80103140 <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801031d1:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801031d7:	83 ec 0c             	sub    $0xc,%esp
801031da:	50                   	push   %eax
801031db:	e8 a0 08 00 00       	call   80103a80 <wakeup>
  release(&p->lock);
801031e0:	89 1c 24             	mov    %ebx,(%esp)
801031e3:	e8 93 0c 00 00       	call   80103e7b <release>
  return n;
801031e8:	83 c4 10             	add    $0x10,%esp
801031eb:	8b 45 10             	mov    0x10(%ebp),%eax
801031ee:	eb b7                	jmp    801031a7 <pipewrite+0x83>

801031f0 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
801031f0:	55                   	push   %ebp
801031f1:	89 e5                	mov    %esp,%ebp
801031f3:	57                   	push   %edi
801031f4:	56                   	push   %esi
801031f5:	53                   	push   %ebx
801031f6:	83 ec 18             	sub    $0x18,%esp
801031f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
801031fc:	89 df                	mov    %ebx,%edi
801031fe:	53                   	push   %ebx
801031ff:	e8 12 0c 00 00       	call   80103e16 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103204:	83 c4 10             	add    $0x10,%esp
80103207:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
8010320d:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80103213:	75 3d                	jne    80103252 <piperead+0x62>
80103215:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
8010321b:	85 f6                	test   %esi,%esi
8010321d:	74 38                	je     80103257 <piperead+0x67>
    if(myproc()->killed){
8010321f:	e8 87 01 00 00       	call   801033ab <myproc>
80103224:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103228:	75 15                	jne    8010323f <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010322a:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103230:	83 ec 08             	sub    $0x8,%esp
80103233:	57                   	push   %edi
80103234:	50                   	push   %eax
80103235:	e8 e1 06 00 00       	call   8010391b <sleep>
8010323a:	83 c4 10             	add    $0x10,%esp
8010323d:	eb c8                	jmp    80103207 <piperead+0x17>
      release(&p->lock);
8010323f:	83 ec 0c             	sub    $0xc,%esp
80103242:	53                   	push   %ebx
80103243:	e8 33 0c 00 00       	call   80103e7b <release>
      return -1;
80103248:	83 c4 10             	add    $0x10,%esp
8010324b:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103250:	eb 50                	jmp    801032a2 <piperead+0xb2>
80103252:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103257:	3b 75 10             	cmp    0x10(%ebp),%esi
8010325a:	7d 2c                	jge    80103288 <piperead+0x98>
    if(p->nread == p->nwrite)
8010325c:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103262:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103268:	74 1e                	je     80103288 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
8010326a:	8d 50 01             	lea    0x1(%eax),%edx
8010326d:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103273:	25 ff 01 00 00       	and    $0x1ff,%eax
80103278:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
8010327d:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103280:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103283:	83 c6 01             	add    $0x1,%esi
80103286:	eb cf                	jmp    80103257 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103288:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010328e:	83 ec 0c             	sub    $0xc,%esp
80103291:	50                   	push   %eax
80103292:	e8 e9 07 00 00       	call   80103a80 <wakeup>
  release(&p->lock);
80103297:	89 1c 24             	mov    %ebx,(%esp)
8010329a:	e8 dc 0b 00 00       	call   80103e7b <release>
  return i;
8010329f:	83 c4 10             	add    $0x10,%esp
}
801032a2:	89 f0                	mov    %esi,%eax
801032a4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801032a7:	5b                   	pop    %ebx
801032a8:	5e                   	pop    %esi
801032a9:	5f                   	pop    %edi
801032aa:	5d                   	pop    %ebp
801032ab:	c3                   	ret    

801032ac <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801032ac:	55                   	push   %ebp
801032ad:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801032af:	ba 94 2d 13 80       	mov    $0x80132d94,%edx
801032b4:	eb 03                	jmp    801032b9 <wakeup1+0xd>
801032b6:	83 c2 7c             	add    $0x7c,%edx
801032b9:	81 fa 94 4c 13 80    	cmp    $0x80134c94,%edx
801032bf:	73 14                	jae    801032d5 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
801032c1:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801032c5:	75 ef                	jne    801032b6 <wakeup1+0xa>
801032c7:	39 42 20             	cmp    %eax,0x20(%edx)
801032ca:	75 ea                	jne    801032b6 <wakeup1+0xa>
      p->state = RUNNABLE;
801032cc:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
801032d3:	eb e1                	jmp    801032b6 <wakeup1+0xa>
}
801032d5:	5d                   	pop    %ebp
801032d6:	c3                   	ret    

801032d7 <forkret>:
{
801032d7:	55                   	push   %ebp
801032d8:	89 e5                	mov    %esp,%ebp
801032da:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
801032dd:	68 60 2d 13 80       	push   $0x80132d60
801032e2:	e8 94 0b 00 00       	call   80103e7b <release>
  if (first) {
801032e7:	83 c4 10             	add    $0x10,%esp
801032ea:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
801032f1:	75 02                	jne    801032f5 <forkret+0x1e>
}
801032f3:	c9                   	leave  
801032f4:	c3                   	ret    
    first = 0;
801032f5:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801032fc:	00 00 00 
    iinit(ROOTDEV);
801032ff:	83 ec 0c             	sub    $0xc,%esp
80103302:	6a 01                	push   $0x1
80103304:	e8 e3 df ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
80103309:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103310:	e8 c6 f6 ff ff       	call   801029db <initlog>
80103315:	83 c4 10             	add    $0x10,%esp
}
80103318:	eb d9                	jmp    801032f3 <forkret+0x1c>

8010331a <pinit>:
{
8010331a:	55                   	push   %ebp
8010331b:	89 e5                	mov    %esp,%ebp
8010331d:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103320:	68 d5 6c 10 80       	push   $0x80106cd5
80103325:	68 60 2d 13 80       	push   $0x80132d60
8010332a:	e8 ab 09 00 00       	call   80103cda <initlock>
}
8010332f:	83 c4 10             	add    $0x10,%esp
80103332:	c9                   	leave  
80103333:	c3                   	ret    

80103334 <mycpu>:
{
80103334:	55                   	push   %ebp
80103335:	89 e5                	mov    %esp,%ebp
80103337:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010333a:	9c                   	pushf  
8010333b:	58                   	pop    %eax
  if(readeflags()&FL_IF)
8010333c:	f6 c4 02             	test   $0x2,%ah
8010333f:	75 28                	jne    80103369 <mycpu+0x35>
  apicid = lapicid();
80103341:	e8 ae f2 ff ff       	call   801025f4 <lapicid>
  for (i = 0; i < ncpu; ++i) {
80103346:	ba 00 00 00 00       	mov    $0x0,%edx
8010334b:	39 15 40 2d 13 80    	cmp    %edx,0x80132d40
80103351:	7e 23                	jle    80103376 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103353:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
80103359:	0f b6 89 c0 27 13 80 	movzbl -0x7fecd840(%ecx),%ecx
80103360:	39 c1                	cmp    %eax,%ecx
80103362:	74 1f                	je     80103383 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103364:	83 c2 01             	add    $0x1,%edx
80103367:	eb e2                	jmp    8010334b <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
80103369:	83 ec 0c             	sub    $0xc,%esp
8010336c:	68 b8 6d 10 80       	push   $0x80106db8
80103371:	e8 d2 cf ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103376:	83 ec 0c             	sub    $0xc,%esp
80103379:	68 dc 6c 10 80       	push   $0x80106cdc
8010337e:	e8 c5 cf ff ff       	call   80100348 <panic>
      return &cpus[i];
80103383:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103389:	05 c0 27 13 80       	add    $0x801327c0,%eax
}
8010338e:	c9                   	leave  
8010338f:	c3                   	ret    

80103390 <cpuid>:
cpuid() {
80103390:	55                   	push   %ebp
80103391:	89 e5                	mov    %esp,%ebp
80103393:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103396:	e8 99 ff ff ff       	call   80103334 <mycpu>
8010339b:	2d c0 27 13 80       	sub    $0x801327c0,%eax
801033a0:	c1 f8 04             	sar    $0x4,%eax
801033a3:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801033a9:	c9                   	leave  
801033aa:	c3                   	ret    

801033ab <myproc>:
myproc(void) {
801033ab:	55                   	push   %ebp
801033ac:	89 e5                	mov    %esp,%ebp
801033ae:	53                   	push   %ebx
801033af:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801033b2:	e8 82 09 00 00       	call   80103d39 <pushcli>
  c = mycpu();
801033b7:	e8 78 ff ff ff       	call   80103334 <mycpu>
  p = c->proc;
801033bc:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801033c2:	e8 af 09 00 00       	call   80103d76 <popcli>
}
801033c7:	89 d8                	mov    %ebx,%eax
801033c9:	83 c4 04             	add    $0x4,%esp
801033cc:	5b                   	pop    %ebx
801033cd:	5d                   	pop    %ebp
801033ce:	c3                   	ret    

801033cf <allocproc>:
{
801033cf:	55                   	push   %ebp
801033d0:	89 e5                	mov    %esp,%ebp
801033d2:	53                   	push   %ebx
801033d3:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801033d6:	68 60 2d 13 80       	push   $0x80132d60
801033db:	e8 36 0a 00 00       	call   80103e16 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801033e0:	83 c4 10             	add    $0x10,%esp
801033e3:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
801033e8:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
801033ee:	73 0b                	jae    801033fb <allocproc+0x2c>
    if(p->state == UNUSED)
801033f0:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801033f4:	74 1c                	je     80103412 <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801033f6:	83 c3 7c             	add    $0x7c,%ebx
801033f9:	eb ed                	jmp    801033e8 <allocproc+0x19>
  release(&ptable.lock);
801033fb:	83 ec 0c             	sub    $0xc,%esp
801033fe:	68 60 2d 13 80       	push   $0x80132d60
80103403:	e8 73 0a 00 00       	call   80103e7b <release>
  return 0;
80103408:	83 c4 10             	add    $0x10,%esp
8010340b:	bb 00 00 00 00       	mov    $0x0,%ebx
80103410:	eb 74                	jmp    80103486 <allocproc+0xb7>
  p->state = EMBRYO;
80103412:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103419:	a1 04 a0 10 80       	mov    0x8010a004,%eax
8010341e:	8d 50 01             	lea    0x1(%eax),%edx
80103421:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80103427:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
8010342a:	83 ec 0c             	sub    $0xc,%esp
8010342d:	68 60 2d 13 80       	push   $0x80132d60
80103432:	e8 44 0a 00 00       	call   80103e7b <release>
  if((p->kstack = kalloc1(myproc()->pid)) == 0){
80103437:	e8 6f ff ff ff       	call   801033ab <myproc>
8010343c:	83 c4 04             	add    $0x4,%esp
8010343f:	ff 70 10             	pushl  0x10(%eax)
80103442:	e8 6f ee ff ff       	call   801022b6 <kalloc1>
80103447:	89 43 08             	mov    %eax,0x8(%ebx)
8010344a:	83 c4 10             	add    $0x10,%esp
8010344d:	85 c0                	test   %eax,%eax
8010344f:	74 3c                	je     8010348d <allocproc+0xbe>
  sp -= sizeof *p->tf;
80103451:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103457:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010345a:	c7 80 b0 0f 00 00 e5 	movl   $0x80104fe5,0xfb0(%eax)
80103461:	4f 10 80 
  sp -= sizeof *p->context;
80103464:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103469:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010346c:	83 ec 04             	sub    $0x4,%esp
8010346f:	6a 14                	push   $0x14
80103471:	6a 00                	push   $0x0
80103473:	50                   	push   %eax
80103474:	e8 49 0a 00 00       	call   80103ec2 <memset>
  p->context->eip = (uint)forkret;
80103479:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010347c:	c7 40 10 d7 32 10 80 	movl   $0x801032d7,0x10(%eax)
  return p;
80103483:	83 c4 10             	add    $0x10,%esp
}
80103486:	89 d8                	mov    %ebx,%eax
80103488:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010348b:	c9                   	leave  
8010348c:	c3                   	ret    
    p->state = UNUSED;
8010348d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
80103494:	bb 00 00 00 00       	mov    $0x0,%ebx
80103499:	eb eb                	jmp    80103486 <allocproc+0xb7>

8010349b <userinit>:
{
8010349b:	55                   	push   %ebp
8010349c:	89 e5                	mov    %esp,%ebp
8010349e:	53                   	push   %ebx
8010349f:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801034a2:	e8 28 ff ff ff       	call   801033cf <allocproc>
801034a7:	89 c3                	mov    %eax,%ebx
  initproc = p;
801034a9:	a3 c0 a5 10 80       	mov    %eax,0x8010a5c0
  if((p->pgdir = setupkvm()) == 0)
801034ae:	e8 3c 30 00 00       	call   801064ef <setupkvm>
801034b3:	89 43 04             	mov    %eax,0x4(%ebx)
801034b6:	85 c0                	test   %eax,%eax
801034b8:	0f 84 b7 00 00 00    	je     80103575 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
801034be:	83 ec 04             	sub    $0x4,%esp
801034c1:	68 2c 00 00 00       	push   $0x2c
801034c6:	68 60 a4 10 80       	push   $0x8010a460
801034cb:	50                   	push   %eax
801034cc:	e8 03 2d 00 00       	call   801061d4 <inituvm>
  p->sz = PGSIZE;
801034d1:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801034d7:	83 c4 0c             	add    $0xc,%esp
801034da:	6a 4c                	push   $0x4c
801034dc:	6a 00                	push   $0x0
801034de:	ff 73 18             	pushl  0x18(%ebx)
801034e1:	e8 dc 09 00 00       	call   80103ec2 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801034e6:	8b 43 18             	mov    0x18(%ebx),%eax
801034e9:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801034ef:	8b 43 18             	mov    0x18(%ebx),%eax
801034f2:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801034f8:	8b 43 18             	mov    0x18(%ebx),%eax
801034fb:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801034ff:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
80103503:	8b 43 18             	mov    0x18(%ebx),%eax
80103506:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
8010350a:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
8010350e:	8b 43 18             	mov    0x18(%ebx),%eax
80103511:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103518:	8b 43 18             	mov    0x18(%ebx),%eax
8010351b:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
80103522:	8b 43 18             	mov    0x18(%ebx),%eax
80103525:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
8010352c:	8d 43 6c             	lea    0x6c(%ebx),%eax
8010352f:	83 c4 0c             	add    $0xc,%esp
80103532:	6a 10                	push   $0x10
80103534:	68 05 6d 10 80       	push   $0x80106d05
80103539:	50                   	push   %eax
8010353a:	e8 ea 0a 00 00       	call   80104029 <safestrcpy>
  p->cwd = namei("/");
8010353f:	c7 04 24 0e 6d 10 80 	movl   $0x80106d0e,(%esp)
80103546:	e8 96 e6 ff ff       	call   80101be1 <namei>
8010354b:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
8010354e:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103555:	e8 bc 08 00 00       	call   80103e16 <acquire>
  p->state = RUNNABLE;
8010355a:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103561:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103568:	e8 0e 09 00 00       	call   80103e7b <release>
}
8010356d:	83 c4 10             	add    $0x10,%esp
80103570:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103573:	c9                   	leave  
80103574:	c3                   	ret    
    panic("userinit: out of memory?");
80103575:	83 ec 0c             	sub    $0xc,%esp
80103578:	68 ec 6c 10 80       	push   $0x80106cec
8010357d:	e8 c6 cd ff ff       	call   80100348 <panic>

80103582 <growproc>:
{
80103582:	55                   	push   %ebp
80103583:	89 e5                	mov    %esp,%ebp
80103585:	56                   	push   %esi
80103586:	53                   	push   %ebx
80103587:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010358a:	e8 1c fe ff ff       	call   801033ab <myproc>
8010358f:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103591:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103593:	85 f6                	test   %esi,%esi
80103595:	7f 21                	jg     801035b8 <growproc+0x36>
  } else if(n < 0){
80103597:	85 f6                	test   %esi,%esi
80103599:	79 33                	jns    801035ce <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010359b:	83 ec 04             	sub    $0x4,%esp
8010359e:	01 c6                	add    %eax,%esi
801035a0:	56                   	push   %esi
801035a1:	50                   	push   %eax
801035a2:	ff 73 04             	pushl  0x4(%ebx)
801035a5:	e8 3e 2d 00 00       	call   801062e8 <deallocuvm>
801035aa:	83 c4 10             	add    $0x10,%esp
801035ad:	85 c0                	test   %eax,%eax
801035af:	75 1d                	jne    801035ce <growproc+0x4c>
      return -1;
801035b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035b6:	eb 29                	jmp    801035e1 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801035b8:	83 ec 04             	sub    $0x4,%esp
801035bb:	01 c6                	add    %eax,%esi
801035bd:	56                   	push   %esi
801035be:	50                   	push   %eax
801035bf:	ff 73 04             	pushl  0x4(%ebx)
801035c2:	e8 b3 2d 00 00       	call   8010637a <allocuvm>
801035c7:	83 c4 10             	add    $0x10,%esp
801035ca:	85 c0                	test   %eax,%eax
801035cc:	74 1a                	je     801035e8 <growproc+0x66>
  curproc->sz = sz;
801035ce:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801035d0:	83 ec 0c             	sub    $0xc,%esp
801035d3:	53                   	push   %ebx
801035d4:	e8 e3 2a 00 00       	call   801060bc <switchuvm>
  return 0;
801035d9:	83 c4 10             	add    $0x10,%esp
801035dc:	b8 00 00 00 00       	mov    $0x0,%eax
}
801035e1:	8d 65 f8             	lea    -0x8(%ebp),%esp
801035e4:	5b                   	pop    %ebx
801035e5:	5e                   	pop    %esi
801035e6:	5d                   	pop    %ebp
801035e7:	c3                   	ret    
      return -1;
801035e8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801035ed:	eb f2                	jmp    801035e1 <growproc+0x5f>

801035ef <fork>:
{
801035ef:	55                   	push   %ebp
801035f0:	89 e5                	mov    %esp,%ebp
801035f2:	57                   	push   %edi
801035f3:	56                   	push   %esi
801035f4:	53                   	push   %ebx
801035f5:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801035f8:	e8 ae fd ff ff       	call   801033ab <myproc>
801035fd:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801035ff:	e8 cb fd ff ff       	call   801033cf <allocproc>
80103604:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103607:	85 c0                	test   %eax,%eax
80103609:	0f 84 e0 00 00 00    	je     801036ef <fork+0x100>
8010360f:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
80103611:	83 ec 08             	sub    $0x8,%esp
80103614:	ff 33                	pushl  (%ebx)
80103616:	ff 73 04             	pushl  0x4(%ebx)
80103619:	e8 90 2f 00 00       	call   801065ae <copyuvm>
8010361e:	89 47 04             	mov    %eax,0x4(%edi)
80103621:	83 c4 10             	add    $0x10,%esp
80103624:	85 c0                	test   %eax,%eax
80103626:	74 2a                	je     80103652 <fork+0x63>
  np->sz = curproc->sz;
80103628:	8b 03                	mov    (%ebx),%eax
8010362a:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
8010362d:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
8010362f:	89 c8                	mov    %ecx,%eax
80103631:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
80103634:	8b 73 18             	mov    0x18(%ebx),%esi
80103637:	8b 79 18             	mov    0x18(%ecx),%edi
8010363a:	b9 13 00 00 00       	mov    $0x13,%ecx
8010363f:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103641:	8b 40 18             	mov    0x18(%eax),%eax
80103644:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010364b:	be 00 00 00 00       	mov    $0x0,%esi
80103650:	eb 29                	jmp    8010367b <fork+0x8c>
    kfree(np->kstack);
80103652:	83 ec 0c             	sub    $0xc,%esp
80103655:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103658:	ff 73 08             	pushl  0x8(%ebx)
8010365b:	e8 b7 e9 ff ff       	call   80102017 <kfree>
    np->kstack = 0;
80103660:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103667:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
8010366e:	83 c4 10             	add    $0x10,%esp
80103671:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103676:	eb 6d                	jmp    801036e5 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
80103678:	83 c6 01             	add    $0x1,%esi
8010367b:	83 fe 0f             	cmp    $0xf,%esi
8010367e:	7f 1d                	jg     8010369d <fork+0xae>
    if(curproc->ofile[i])
80103680:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103684:	85 c0                	test   %eax,%eax
80103686:	74 f0                	je     80103678 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103688:	83 ec 0c             	sub    $0xc,%esp
8010368b:	50                   	push   %eax
8010368c:	e8 fd d5 ff ff       	call   80100c8e <filedup>
80103691:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103694:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103698:	83 c4 10             	add    $0x10,%esp
8010369b:	eb db                	jmp    80103678 <fork+0x89>
  np->cwd = idup(curproc->cwd);
8010369d:	83 ec 0c             	sub    $0xc,%esp
801036a0:	ff 73 68             	pushl  0x68(%ebx)
801036a3:	e8 a9 de ff ff       	call   80101551 <idup>
801036a8:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801036ab:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801036ae:	83 c3 6c             	add    $0x6c,%ebx
801036b1:	8d 47 6c             	lea    0x6c(%edi),%eax
801036b4:	83 c4 0c             	add    $0xc,%esp
801036b7:	6a 10                	push   $0x10
801036b9:	53                   	push   %ebx
801036ba:	50                   	push   %eax
801036bb:	e8 69 09 00 00       	call   80104029 <safestrcpy>
  pid = np->pid;
801036c0:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801036c3:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
801036ca:	e8 47 07 00 00       	call   80103e16 <acquire>
  np->state = RUNNABLE;
801036cf:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
801036d6:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
801036dd:	e8 99 07 00 00       	call   80103e7b <release>
  return pid;
801036e2:	83 c4 10             	add    $0x10,%esp
}
801036e5:	89 d8                	mov    %ebx,%eax
801036e7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801036ea:	5b                   	pop    %ebx
801036eb:	5e                   	pop    %esi
801036ec:	5f                   	pop    %edi
801036ed:	5d                   	pop    %ebp
801036ee:	c3                   	ret    
    return -1;
801036ef:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801036f4:	eb ef                	jmp    801036e5 <fork+0xf6>

801036f6 <scheduler>:
{
801036f6:	55                   	push   %ebp
801036f7:	89 e5                	mov    %esp,%ebp
801036f9:	56                   	push   %esi
801036fa:	53                   	push   %ebx
  struct cpu *c = mycpu();
801036fb:	e8 34 fc ff ff       	call   80103334 <mycpu>
80103700:	89 c6                	mov    %eax,%esi
  c->proc = 0;
80103702:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103709:	00 00 00 
8010370c:	eb 5a                	jmp    80103768 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010370e:	83 c3 7c             	add    $0x7c,%ebx
80103711:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
80103717:	73 3f                	jae    80103758 <scheduler+0x62>
      if(p->state != RUNNABLE)
80103719:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
8010371d:	75 ef                	jne    8010370e <scheduler+0x18>
      c->proc = p;
8010371f:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103725:	83 ec 0c             	sub    $0xc,%esp
80103728:	53                   	push   %ebx
80103729:	e8 8e 29 00 00       	call   801060bc <switchuvm>
      p->state = RUNNING;
8010372e:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103735:	83 c4 08             	add    $0x8,%esp
80103738:	ff 73 1c             	pushl  0x1c(%ebx)
8010373b:	8d 46 04             	lea    0x4(%esi),%eax
8010373e:	50                   	push   %eax
8010373f:	e8 38 09 00 00       	call   8010407c <swtch>
      switchkvm();
80103744:	e8 61 29 00 00       	call   801060aa <switchkvm>
      c->proc = 0;
80103749:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103750:	00 00 00 
80103753:	83 c4 10             	add    $0x10,%esp
80103756:	eb b6                	jmp    8010370e <scheduler+0x18>
    release(&ptable.lock);
80103758:	83 ec 0c             	sub    $0xc,%esp
8010375b:	68 60 2d 13 80       	push   $0x80132d60
80103760:	e8 16 07 00 00       	call   80103e7b <release>
    sti();
80103765:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103768:	fb                   	sti    
    acquire(&ptable.lock);
80103769:	83 ec 0c             	sub    $0xc,%esp
8010376c:	68 60 2d 13 80       	push   $0x80132d60
80103771:	e8 a0 06 00 00       	call   80103e16 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103776:	83 c4 10             	add    $0x10,%esp
80103779:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
8010377e:	eb 91                	jmp    80103711 <scheduler+0x1b>

80103780 <sched>:
{
80103780:	55                   	push   %ebp
80103781:	89 e5                	mov    %esp,%ebp
80103783:	56                   	push   %esi
80103784:	53                   	push   %ebx
  struct proc *p = myproc();
80103785:	e8 21 fc ff ff       	call   801033ab <myproc>
8010378a:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010378c:	83 ec 0c             	sub    $0xc,%esp
8010378f:	68 60 2d 13 80       	push   $0x80132d60
80103794:	e8 3d 06 00 00       	call   80103dd6 <holding>
80103799:	83 c4 10             	add    $0x10,%esp
8010379c:	85 c0                	test   %eax,%eax
8010379e:	74 4f                	je     801037ef <sched+0x6f>
  if(mycpu()->ncli != 1)
801037a0:	e8 8f fb ff ff       	call   80103334 <mycpu>
801037a5:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801037ac:	75 4e                	jne    801037fc <sched+0x7c>
  if(p->state == RUNNING)
801037ae:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801037b2:	74 55                	je     80103809 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801037b4:	9c                   	pushf  
801037b5:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801037b6:	f6 c4 02             	test   $0x2,%ah
801037b9:	75 5b                	jne    80103816 <sched+0x96>
  intena = mycpu()->intena;
801037bb:	e8 74 fb ff ff       	call   80103334 <mycpu>
801037c0:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801037c6:	e8 69 fb ff ff       	call   80103334 <mycpu>
801037cb:	83 ec 08             	sub    $0x8,%esp
801037ce:	ff 70 04             	pushl  0x4(%eax)
801037d1:	83 c3 1c             	add    $0x1c,%ebx
801037d4:	53                   	push   %ebx
801037d5:	e8 a2 08 00 00       	call   8010407c <swtch>
  mycpu()->intena = intena;
801037da:	e8 55 fb ff ff       	call   80103334 <mycpu>
801037df:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801037e5:	83 c4 10             	add    $0x10,%esp
801037e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801037eb:	5b                   	pop    %ebx
801037ec:	5e                   	pop    %esi
801037ed:	5d                   	pop    %ebp
801037ee:	c3                   	ret    
    panic("sched ptable.lock");
801037ef:	83 ec 0c             	sub    $0xc,%esp
801037f2:	68 10 6d 10 80       	push   $0x80106d10
801037f7:	e8 4c cb ff ff       	call   80100348 <panic>
    panic("sched locks");
801037fc:	83 ec 0c             	sub    $0xc,%esp
801037ff:	68 22 6d 10 80       	push   $0x80106d22
80103804:	e8 3f cb ff ff       	call   80100348 <panic>
    panic("sched running");
80103809:	83 ec 0c             	sub    $0xc,%esp
8010380c:	68 2e 6d 10 80       	push   $0x80106d2e
80103811:	e8 32 cb ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103816:	83 ec 0c             	sub    $0xc,%esp
80103819:	68 3c 6d 10 80       	push   $0x80106d3c
8010381e:	e8 25 cb ff ff       	call   80100348 <panic>

80103823 <exit>:
{
80103823:	55                   	push   %ebp
80103824:	89 e5                	mov    %esp,%ebp
80103826:	56                   	push   %esi
80103827:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103828:	e8 7e fb ff ff       	call   801033ab <myproc>
  if(curproc == initproc)
8010382d:	39 05 c0 a5 10 80    	cmp    %eax,0x8010a5c0
80103833:	74 09                	je     8010383e <exit+0x1b>
80103835:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103837:	bb 00 00 00 00       	mov    $0x0,%ebx
8010383c:	eb 10                	jmp    8010384e <exit+0x2b>
    panic("init exiting");
8010383e:	83 ec 0c             	sub    $0xc,%esp
80103841:	68 50 6d 10 80       	push   $0x80106d50
80103846:	e8 fd ca ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
8010384b:	83 c3 01             	add    $0x1,%ebx
8010384e:	83 fb 0f             	cmp    $0xf,%ebx
80103851:	7f 1e                	jg     80103871 <exit+0x4e>
    if(curproc->ofile[fd]){
80103853:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103857:	85 c0                	test   %eax,%eax
80103859:	74 f0                	je     8010384b <exit+0x28>
      fileclose(curproc->ofile[fd]);
8010385b:	83 ec 0c             	sub    $0xc,%esp
8010385e:	50                   	push   %eax
8010385f:	e8 6f d4 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
80103864:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
8010386b:	00 
8010386c:	83 c4 10             	add    $0x10,%esp
8010386f:	eb da                	jmp    8010384b <exit+0x28>
  begin_op();
80103871:	e8 ae f1 ff ff       	call   80102a24 <begin_op>
  iput(curproc->cwd);
80103876:	83 ec 0c             	sub    $0xc,%esp
80103879:	ff 76 68             	pushl  0x68(%esi)
8010387c:	e8 07 de ff ff       	call   80101688 <iput>
  end_op();
80103881:	e8 18 f2 ff ff       	call   80102a9e <end_op>
  curproc->cwd = 0;
80103886:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
8010388d:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103894:	e8 7d 05 00 00       	call   80103e16 <acquire>
  wakeup1(curproc->parent);
80103899:	8b 46 14             	mov    0x14(%esi),%eax
8010389c:	e8 0b fa ff ff       	call   801032ac <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038a1:	83 c4 10             	add    $0x10,%esp
801038a4:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
801038a9:	eb 03                	jmp    801038ae <exit+0x8b>
801038ab:	83 c3 7c             	add    $0x7c,%ebx
801038ae:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
801038b4:	73 1a                	jae    801038d0 <exit+0xad>
    if(p->parent == curproc){
801038b6:	39 73 14             	cmp    %esi,0x14(%ebx)
801038b9:	75 f0                	jne    801038ab <exit+0x88>
      p->parent = initproc;
801038bb:	a1 c0 a5 10 80       	mov    0x8010a5c0,%eax
801038c0:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801038c3:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801038c7:	75 e2                	jne    801038ab <exit+0x88>
        wakeup1(initproc);
801038c9:	e8 de f9 ff ff       	call   801032ac <wakeup1>
801038ce:	eb db                	jmp    801038ab <exit+0x88>
  curproc->state = ZOMBIE;
801038d0:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801038d7:	e8 a4 fe ff ff       	call   80103780 <sched>
  panic("zombie exit");
801038dc:	83 ec 0c             	sub    $0xc,%esp
801038df:	68 5d 6d 10 80       	push   $0x80106d5d
801038e4:	e8 5f ca ff ff       	call   80100348 <panic>

801038e9 <yield>:
{
801038e9:	55                   	push   %ebp
801038ea:	89 e5                	mov    %esp,%ebp
801038ec:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801038ef:	68 60 2d 13 80       	push   $0x80132d60
801038f4:	e8 1d 05 00 00       	call   80103e16 <acquire>
  myproc()->state = RUNNABLE;
801038f9:	e8 ad fa ff ff       	call   801033ab <myproc>
801038fe:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103905:	e8 76 fe ff ff       	call   80103780 <sched>
  release(&ptable.lock);
8010390a:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103911:	e8 65 05 00 00       	call   80103e7b <release>
}
80103916:	83 c4 10             	add    $0x10,%esp
80103919:	c9                   	leave  
8010391a:	c3                   	ret    

8010391b <sleep>:
{
8010391b:	55                   	push   %ebp
8010391c:	89 e5                	mov    %esp,%ebp
8010391e:	56                   	push   %esi
8010391f:	53                   	push   %ebx
80103920:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
80103923:	e8 83 fa ff ff       	call   801033ab <myproc>
  if(p == 0)
80103928:	85 c0                	test   %eax,%eax
8010392a:	74 66                	je     80103992 <sleep+0x77>
8010392c:	89 c6                	mov    %eax,%esi
  if(lk == 0)
8010392e:	85 db                	test   %ebx,%ebx
80103930:	74 6d                	je     8010399f <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
80103932:	81 fb 60 2d 13 80    	cmp    $0x80132d60,%ebx
80103938:	74 18                	je     80103952 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
8010393a:	83 ec 0c             	sub    $0xc,%esp
8010393d:	68 60 2d 13 80       	push   $0x80132d60
80103942:	e8 cf 04 00 00       	call   80103e16 <acquire>
    release(lk);
80103947:	89 1c 24             	mov    %ebx,(%esp)
8010394a:	e8 2c 05 00 00       	call   80103e7b <release>
8010394f:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103952:	8b 45 08             	mov    0x8(%ebp),%eax
80103955:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103958:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
8010395f:	e8 1c fe ff ff       	call   80103780 <sched>
  p->chan = 0;
80103964:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010396b:	81 fb 60 2d 13 80    	cmp    $0x80132d60,%ebx
80103971:	74 18                	je     8010398b <sleep+0x70>
    release(&ptable.lock);
80103973:	83 ec 0c             	sub    $0xc,%esp
80103976:	68 60 2d 13 80       	push   $0x80132d60
8010397b:	e8 fb 04 00 00       	call   80103e7b <release>
    acquire(lk);
80103980:	89 1c 24             	mov    %ebx,(%esp)
80103983:	e8 8e 04 00 00       	call   80103e16 <acquire>
80103988:	83 c4 10             	add    $0x10,%esp
}
8010398b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010398e:	5b                   	pop    %ebx
8010398f:	5e                   	pop    %esi
80103990:	5d                   	pop    %ebp
80103991:	c3                   	ret    
    panic("sleep");
80103992:	83 ec 0c             	sub    $0xc,%esp
80103995:	68 69 6d 10 80       	push   $0x80106d69
8010399a:	e8 a9 c9 ff ff       	call   80100348 <panic>
    panic("sleep without lk");
8010399f:	83 ec 0c             	sub    $0xc,%esp
801039a2:	68 6f 6d 10 80       	push   $0x80106d6f
801039a7:	e8 9c c9 ff ff       	call   80100348 <panic>

801039ac <wait>:
{
801039ac:	55                   	push   %ebp
801039ad:	89 e5                	mov    %esp,%ebp
801039af:	56                   	push   %esi
801039b0:	53                   	push   %ebx
  struct proc *curproc = myproc();
801039b1:	e8 f5 f9 ff ff       	call   801033ab <myproc>
801039b6:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801039b8:	83 ec 0c             	sub    $0xc,%esp
801039bb:	68 60 2d 13 80       	push   $0x80132d60
801039c0:	e8 51 04 00 00       	call   80103e16 <acquire>
801039c5:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801039c8:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039cd:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
801039d2:	eb 5b                	jmp    80103a2f <wait+0x83>
        pid = p->pid;
801039d4:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801039d7:	83 ec 0c             	sub    $0xc,%esp
801039da:	ff 73 08             	pushl  0x8(%ebx)
801039dd:	e8 35 e6 ff ff       	call   80102017 <kfree>
        p->kstack = 0;
801039e2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801039e9:	83 c4 04             	add    $0x4,%esp
801039ec:	ff 73 04             	pushl  0x4(%ebx)
801039ef:	e8 8b 2a 00 00       	call   8010647f <freevm>
        p->pid = 0;
801039f4:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801039fb:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
80103a02:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103a06:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103a0d:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
80103a14:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103a1b:	e8 5b 04 00 00       	call   80103e7b <release>
        return pid;
80103a20:	83 c4 10             	add    $0x10,%esp
}
80103a23:	89 f0                	mov    %esi,%eax
80103a25:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a28:	5b                   	pop    %ebx
80103a29:	5e                   	pop    %esi
80103a2a:	5d                   	pop    %ebp
80103a2b:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a2c:	83 c3 7c             	add    $0x7c,%ebx
80103a2f:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
80103a35:	73 12                	jae    80103a49 <wait+0x9d>
      if(p->parent != curproc)
80103a37:	39 73 14             	cmp    %esi,0x14(%ebx)
80103a3a:	75 f0                	jne    80103a2c <wait+0x80>
      if(p->state == ZOMBIE){
80103a3c:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103a40:	74 92                	je     801039d4 <wait+0x28>
      havekids = 1;
80103a42:	b8 01 00 00 00       	mov    $0x1,%eax
80103a47:	eb e3                	jmp    80103a2c <wait+0x80>
    if(!havekids || curproc->killed){
80103a49:	85 c0                	test   %eax,%eax
80103a4b:	74 06                	je     80103a53 <wait+0xa7>
80103a4d:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103a51:	74 17                	je     80103a6a <wait+0xbe>
      release(&ptable.lock);
80103a53:	83 ec 0c             	sub    $0xc,%esp
80103a56:	68 60 2d 13 80       	push   $0x80132d60
80103a5b:	e8 1b 04 00 00       	call   80103e7b <release>
      return -1;
80103a60:	83 c4 10             	add    $0x10,%esp
80103a63:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103a68:	eb b9                	jmp    80103a23 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103a6a:	83 ec 08             	sub    $0x8,%esp
80103a6d:	68 60 2d 13 80       	push   $0x80132d60
80103a72:	56                   	push   %esi
80103a73:	e8 a3 fe ff ff       	call   8010391b <sleep>
    havekids = 0;
80103a78:	83 c4 10             	add    $0x10,%esp
80103a7b:	e9 48 ff ff ff       	jmp    801039c8 <wait+0x1c>

80103a80 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103a80:	55                   	push   %ebp
80103a81:	89 e5                	mov    %esp,%ebp
80103a83:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103a86:	68 60 2d 13 80       	push   $0x80132d60
80103a8b:	e8 86 03 00 00       	call   80103e16 <acquire>
  wakeup1(chan);
80103a90:	8b 45 08             	mov    0x8(%ebp),%eax
80103a93:	e8 14 f8 ff ff       	call   801032ac <wakeup1>
  release(&ptable.lock);
80103a98:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103a9f:	e8 d7 03 00 00       	call   80103e7b <release>
}
80103aa4:	83 c4 10             	add    $0x10,%esp
80103aa7:	c9                   	leave  
80103aa8:	c3                   	ret    

80103aa9 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
80103aa9:	55                   	push   %ebp
80103aaa:	89 e5                	mov    %esp,%ebp
80103aac:	53                   	push   %ebx
80103aad:	83 ec 10             	sub    $0x10,%esp
80103ab0:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103ab3:	68 60 2d 13 80       	push   $0x80132d60
80103ab8:	e8 59 03 00 00       	call   80103e16 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103abd:	83 c4 10             	add    $0x10,%esp
80103ac0:	b8 94 2d 13 80       	mov    $0x80132d94,%eax
80103ac5:	3d 94 4c 13 80       	cmp    $0x80134c94,%eax
80103aca:	73 3a                	jae    80103b06 <kill+0x5d>
    if(p->pid == pid){
80103acc:	39 58 10             	cmp    %ebx,0x10(%eax)
80103acf:	74 05                	je     80103ad6 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103ad1:	83 c0 7c             	add    $0x7c,%eax
80103ad4:	eb ef                	jmp    80103ac5 <kill+0x1c>
      p->killed = 1;
80103ad6:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103add:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103ae1:	74 1a                	je     80103afd <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103ae3:	83 ec 0c             	sub    $0xc,%esp
80103ae6:	68 60 2d 13 80       	push   $0x80132d60
80103aeb:	e8 8b 03 00 00       	call   80103e7b <release>
      return 0;
80103af0:	83 c4 10             	add    $0x10,%esp
80103af3:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103af8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103afb:	c9                   	leave  
80103afc:	c3                   	ret    
        p->state = RUNNABLE;
80103afd:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103b04:	eb dd                	jmp    80103ae3 <kill+0x3a>
  release(&ptable.lock);
80103b06:	83 ec 0c             	sub    $0xc,%esp
80103b09:	68 60 2d 13 80       	push   $0x80132d60
80103b0e:	e8 68 03 00 00       	call   80103e7b <release>
  return -1;
80103b13:	83 c4 10             	add    $0x10,%esp
80103b16:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103b1b:	eb db                	jmp    80103af8 <kill+0x4f>

80103b1d <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103b1d:	55                   	push   %ebp
80103b1e:	89 e5                	mov    %esp,%ebp
80103b20:	56                   	push   %esi
80103b21:	53                   	push   %ebx
80103b22:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b25:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
80103b2a:	eb 33                	jmp    80103b5f <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103b2c:	b8 80 6d 10 80       	mov    $0x80106d80,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103b31:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103b34:	52                   	push   %edx
80103b35:	50                   	push   %eax
80103b36:	ff 73 10             	pushl  0x10(%ebx)
80103b39:	68 84 6d 10 80       	push   $0x80106d84
80103b3e:	e8 c8 ca ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103b43:	83 c4 10             	add    $0x10,%esp
80103b46:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103b4a:	74 39                	je     80103b85 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103b4c:	83 ec 0c             	sub    $0xc,%esp
80103b4f:	68 29 71 10 80       	push   $0x80107129
80103b54:	e8 b2 ca ff ff       	call   8010060b <cprintf>
80103b59:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103b5c:	83 c3 7c             	add    $0x7c,%ebx
80103b5f:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
80103b65:	73 61                	jae    80103bc8 <procdump+0xab>
    if(p->state == UNUSED)
80103b67:	8b 43 0c             	mov    0xc(%ebx),%eax
80103b6a:	85 c0                	test   %eax,%eax
80103b6c:	74 ee                	je     80103b5c <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103b6e:	83 f8 05             	cmp    $0x5,%eax
80103b71:	77 b9                	ja     80103b2c <procdump+0xf>
80103b73:	8b 04 85 e0 6d 10 80 	mov    -0x7fef9220(,%eax,4),%eax
80103b7a:	85 c0                	test   %eax,%eax
80103b7c:	75 b3                	jne    80103b31 <procdump+0x14>
      state = "???";
80103b7e:	b8 80 6d 10 80       	mov    $0x80106d80,%eax
80103b83:	eb ac                	jmp    80103b31 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103b85:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103b88:	8b 40 0c             	mov    0xc(%eax),%eax
80103b8b:	83 c0 08             	add    $0x8,%eax
80103b8e:	83 ec 08             	sub    $0x8,%esp
80103b91:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103b94:	52                   	push   %edx
80103b95:	50                   	push   %eax
80103b96:	e8 5a 01 00 00       	call   80103cf5 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103b9b:	83 c4 10             	add    $0x10,%esp
80103b9e:	be 00 00 00 00       	mov    $0x0,%esi
80103ba3:	eb 14                	jmp    80103bb9 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103ba5:	83 ec 08             	sub    $0x8,%esp
80103ba8:	50                   	push   %eax
80103ba9:	68 a1 67 10 80       	push   $0x801067a1
80103bae:	e8 58 ca ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103bb3:	83 c6 01             	add    $0x1,%esi
80103bb6:	83 c4 10             	add    $0x10,%esp
80103bb9:	83 fe 09             	cmp    $0x9,%esi
80103bbc:	7f 8e                	jg     80103b4c <procdump+0x2f>
80103bbe:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103bc2:	85 c0                	test   %eax,%eax
80103bc4:	75 df                	jne    80103ba5 <procdump+0x88>
80103bc6:	eb 84                	jmp    80103b4c <procdump+0x2f>
  }
}
80103bc8:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bcb:	5b                   	pop    %ebx
80103bcc:	5e                   	pop    %esi
80103bcd:	5d                   	pop    %ebp
80103bce:	c3                   	ret    

80103bcf <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103bcf:	55                   	push   %ebp
80103bd0:	89 e5                	mov    %esp,%ebp
80103bd2:	53                   	push   %ebx
80103bd3:	83 ec 0c             	sub    $0xc,%esp
80103bd6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103bd9:	68 f8 6d 10 80       	push   $0x80106df8
80103bde:	8d 43 04             	lea    0x4(%ebx),%eax
80103be1:	50                   	push   %eax
80103be2:	e8 f3 00 00 00       	call   80103cda <initlock>
  lk->name = name;
80103be7:	8b 45 0c             	mov    0xc(%ebp),%eax
80103bea:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103bed:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103bf3:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103bfa:	83 c4 10             	add    $0x10,%esp
80103bfd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c00:	c9                   	leave  
80103c01:	c3                   	ret    

80103c02 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103c02:	55                   	push   %ebp
80103c03:	89 e5                	mov    %esp,%ebp
80103c05:	56                   	push   %esi
80103c06:	53                   	push   %ebx
80103c07:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c0a:	8d 73 04             	lea    0x4(%ebx),%esi
80103c0d:	83 ec 0c             	sub    $0xc,%esp
80103c10:	56                   	push   %esi
80103c11:	e8 00 02 00 00       	call   80103e16 <acquire>
  while (lk->locked) {
80103c16:	83 c4 10             	add    $0x10,%esp
80103c19:	eb 0d                	jmp    80103c28 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103c1b:	83 ec 08             	sub    $0x8,%esp
80103c1e:	56                   	push   %esi
80103c1f:	53                   	push   %ebx
80103c20:	e8 f6 fc ff ff       	call   8010391b <sleep>
80103c25:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103c28:	83 3b 00             	cmpl   $0x0,(%ebx)
80103c2b:	75 ee                	jne    80103c1b <acquiresleep+0x19>
  }
  lk->locked = 1;
80103c2d:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103c33:	e8 73 f7 ff ff       	call   801033ab <myproc>
80103c38:	8b 40 10             	mov    0x10(%eax),%eax
80103c3b:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103c3e:	83 ec 0c             	sub    $0xc,%esp
80103c41:	56                   	push   %esi
80103c42:	e8 34 02 00 00       	call   80103e7b <release>
}
80103c47:	83 c4 10             	add    $0x10,%esp
80103c4a:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c4d:	5b                   	pop    %ebx
80103c4e:	5e                   	pop    %esi
80103c4f:	5d                   	pop    %ebp
80103c50:	c3                   	ret    

80103c51 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103c51:	55                   	push   %ebp
80103c52:	89 e5                	mov    %esp,%ebp
80103c54:	56                   	push   %esi
80103c55:	53                   	push   %ebx
80103c56:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103c59:	8d 73 04             	lea    0x4(%ebx),%esi
80103c5c:	83 ec 0c             	sub    $0xc,%esp
80103c5f:	56                   	push   %esi
80103c60:	e8 b1 01 00 00       	call   80103e16 <acquire>
  lk->locked = 0;
80103c65:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103c6b:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103c72:	89 1c 24             	mov    %ebx,(%esp)
80103c75:	e8 06 fe ff ff       	call   80103a80 <wakeup>
  release(&lk->lk);
80103c7a:	89 34 24             	mov    %esi,(%esp)
80103c7d:	e8 f9 01 00 00       	call   80103e7b <release>
}
80103c82:	83 c4 10             	add    $0x10,%esp
80103c85:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c88:	5b                   	pop    %ebx
80103c89:	5e                   	pop    %esi
80103c8a:	5d                   	pop    %ebp
80103c8b:	c3                   	ret    

80103c8c <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103c8c:	55                   	push   %ebp
80103c8d:	89 e5                	mov    %esp,%ebp
80103c8f:	56                   	push   %esi
80103c90:	53                   	push   %ebx
80103c91:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103c94:	8d 73 04             	lea    0x4(%ebx),%esi
80103c97:	83 ec 0c             	sub    $0xc,%esp
80103c9a:	56                   	push   %esi
80103c9b:	e8 76 01 00 00       	call   80103e16 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103ca0:	83 c4 10             	add    $0x10,%esp
80103ca3:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ca6:	75 17                	jne    80103cbf <holdingsleep+0x33>
80103ca8:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103cad:	83 ec 0c             	sub    $0xc,%esp
80103cb0:	56                   	push   %esi
80103cb1:	e8 c5 01 00 00       	call   80103e7b <release>
  return r;
}
80103cb6:	89 d8                	mov    %ebx,%eax
80103cb8:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103cbb:	5b                   	pop    %ebx
80103cbc:	5e                   	pop    %esi
80103cbd:	5d                   	pop    %ebp
80103cbe:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103cbf:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103cc2:	e8 e4 f6 ff ff       	call   801033ab <myproc>
80103cc7:	3b 58 10             	cmp    0x10(%eax),%ebx
80103cca:	74 07                	je     80103cd3 <holdingsleep+0x47>
80103ccc:	bb 00 00 00 00       	mov    $0x0,%ebx
80103cd1:	eb da                	jmp    80103cad <holdingsleep+0x21>
80103cd3:	bb 01 00 00 00       	mov    $0x1,%ebx
80103cd8:	eb d3                	jmp    80103cad <holdingsleep+0x21>

80103cda <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103cda:	55                   	push   %ebp
80103cdb:	89 e5                	mov    %esp,%ebp
80103cdd:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103ce0:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ce3:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103ce6:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103cec:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103cf3:	5d                   	pop    %ebp
80103cf4:	c3                   	ret    

80103cf5 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103cf5:	55                   	push   %ebp
80103cf6:	89 e5                	mov    %esp,%ebp
80103cf8:	53                   	push   %ebx
80103cf9:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103cfc:	8b 45 08             	mov    0x8(%ebp),%eax
80103cff:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103d02:	b8 00 00 00 00       	mov    $0x0,%eax
80103d07:	83 f8 09             	cmp    $0x9,%eax
80103d0a:	7f 25                	jg     80103d31 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103d0c:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103d12:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103d18:	77 17                	ja     80103d31 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103d1a:	8b 5a 04             	mov    0x4(%edx),%ebx
80103d1d:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103d20:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103d22:	83 c0 01             	add    $0x1,%eax
80103d25:	eb e0                	jmp    80103d07 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103d27:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103d2e:	83 c0 01             	add    $0x1,%eax
80103d31:	83 f8 09             	cmp    $0x9,%eax
80103d34:	7e f1                	jle    80103d27 <getcallerpcs+0x32>
}
80103d36:	5b                   	pop    %ebx
80103d37:	5d                   	pop    %ebp
80103d38:	c3                   	ret    

80103d39 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103d39:	55                   	push   %ebp
80103d3a:	89 e5                	mov    %esp,%ebp
80103d3c:	53                   	push   %ebx
80103d3d:	83 ec 04             	sub    $0x4,%esp
80103d40:	9c                   	pushf  
80103d41:	5b                   	pop    %ebx
  asm volatile("cli");
80103d42:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103d43:	e8 ec f5 ff ff       	call   80103334 <mycpu>
80103d48:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103d4f:	74 12                	je     80103d63 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103d51:	e8 de f5 ff ff       	call   80103334 <mycpu>
80103d56:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103d5d:	83 c4 04             	add    $0x4,%esp
80103d60:	5b                   	pop    %ebx
80103d61:	5d                   	pop    %ebp
80103d62:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103d63:	e8 cc f5 ff ff       	call   80103334 <mycpu>
80103d68:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103d6e:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103d74:	eb db                	jmp    80103d51 <pushcli+0x18>

80103d76 <popcli>:

void
popcli(void)
{
80103d76:	55                   	push   %ebp
80103d77:	89 e5                	mov    %esp,%ebp
80103d79:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103d7c:	9c                   	pushf  
80103d7d:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103d7e:	f6 c4 02             	test   $0x2,%ah
80103d81:	75 28                	jne    80103dab <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103d83:	e8 ac f5 ff ff       	call   80103334 <mycpu>
80103d88:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103d8e:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103d91:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103d97:	85 d2                	test   %edx,%edx
80103d99:	78 1d                	js     80103db8 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103d9b:	e8 94 f5 ff ff       	call   80103334 <mycpu>
80103da0:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103da7:	74 1c                	je     80103dc5 <popcli+0x4f>
    sti();
}
80103da9:	c9                   	leave  
80103daa:	c3                   	ret    
    panic("popcli - interruptible");
80103dab:	83 ec 0c             	sub    $0xc,%esp
80103dae:	68 03 6e 10 80       	push   $0x80106e03
80103db3:	e8 90 c5 ff ff       	call   80100348 <panic>
    panic("popcli");
80103db8:	83 ec 0c             	sub    $0xc,%esp
80103dbb:	68 1a 6e 10 80       	push   $0x80106e1a
80103dc0:	e8 83 c5 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103dc5:	e8 6a f5 ff ff       	call   80103334 <mycpu>
80103dca:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103dd1:	74 d6                	je     80103da9 <popcli+0x33>
  asm volatile("sti");
80103dd3:	fb                   	sti    
}
80103dd4:	eb d3                	jmp    80103da9 <popcli+0x33>

80103dd6 <holding>:
{
80103dd6:	55                   	push   %ebp
80103dd7:	89 e5                	mov    %esp,%ebp
80103dd9:	53                   	push   %ebx
80103dda:	83 ec 04             	sub    $0x4,%esp
80103ddd:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103de0:	e8 54 ff ff ff       	call   80103d39 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103de5:	83 3b 00             	cmpl   $0x0,(%ebx)
80103de8:	75 12                	jne    80103dfc <holding+0x26>
80103dea:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103def:	e8 82 ff ff ff       	call   80103d76 <popcli>
}
80103df4:	89 d8                	mov    %ebx,%eax
80103df6:	83 c4 04             	add    $0x4,%esp
80103df9:	5b                   	pop    %ebx
80103dfa:	5d                   	pop    %ebp
80103dfb:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103dfc:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103dff:	e8 30 f5 ff ff       	call   80103334 <mycpu>
80103e04:	39 c3                	cmp    %eax,%ebx
80103e06:	74 07                	je     80103e0f <holding+0x39>
80103e08:	bb 00 00 00 00       	mov    $0x0,%ebx
80103e0d:	eb e0                	jmp    80103def <holding+0x19>
80103e0f:	bb 01 00 00 00       	mov    $0x1,%ebx
80103e14:	eb d9                	jmp    80103def <holding+0x19>

80103e16 <acquire>:
{
80103e16:	55                   	push   %ebp
80103e17:	89 e5                	mov    %esp,%ebp
80103e19:	53                   	push   %ebx
80103e1a:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103e1d:	e8 17 ff ff ff       	call   80103d39 <pushcli>
  if(holding(lk))
80103e22:	83 ec 0c             	sub    $0xc,%esp
80103e25:	ff 75 08             	pushl  0x8(%ebp)
80103e28:	e8 a9 ff ff ff       	call   80103dd6 <holding>
80103e2d:	83 c4 10             	add    $0x10,%esp
80103e30:	85 c0                	test   %eax,%eax
80103e32:	75 3a                	jne    80103e6e <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103e34:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103e37:	b8 01 00 00 00       	mov    $0x1,%eax
80103e3c:	f0 87 02             	lock xchg %eax,(%edx)
80103e3f:	85 c0                	test   %eax,%eax
80103e41:	75 f1                	jne    80103e34 <acquire+0x1e>
  __sync_synchronize();
80103e43:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103e48:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103e4b:	e8 e4 f4 ff ff       	call   80103334 <mycpu>
80103e50:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103e53:	8b 45 08             	mov    0x8(%ebp),%eax
80103e56:	83 c0 0c             	add    $0xc,%eax
80103e59:	83 ec 08             	sub    $0x8,%esp
80103e5c:	50                   	push   %eax
80103e5d:	8d 45 08             	lea    0x8(%ebp),%eax
80103e60:	50                   	push   %eax
80103e61:	e8 8f fe ff ff       	call   80103cf5 <getcallerpcs>
}
80103e66:	83 c4 10             	add    $0x10,%esp
80103e69:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103e6c:	c9                   	leave  
80103e6d:	c3                   	ret    
    panic("acquire");
80103e6e:	83 ec 0c             	sub    $0xc,%esp
80103e71:	68 21 6e 10 80       	push   $0x80106e21
80103e76:	e8 cd c4 ff ff       	call   80100348 <panic>

80103e7b <release>:
{
80103e7b:	55                   	push   %ebp
80103e7c:	89 e5                	mov    %esp,%ebp
80103e7e:	53                   	push   %ebx
80103e7f:	83 ec 10             	sub    $0x10,%esp
80103e82:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103e85:	53                   	push   %ebx
80103e86:	e8 4b ff ff ff       	call   80103dd6 <holding>
80103e8b:	83 c4 10             	add    $0x10,%esp
80103e8e:	85 c0                	test   %eax,%eax
80103e90:	74 23                	je     80103eb5 <release+0x3a>
  lk->pcs[0] = 0;
80103e92:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103e99:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103ea0:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103ea5:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103eab:	e8 c6 fe ff ff       	call   80103d76 <popcli>
}
80103eb0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103eb3:	c9                   	leave  
80103eb4:	c3                   	ret    
    panic("release");
80103eb5:	83 ec 0c             	sub    $0xc,%esp
80103eb8:	68 29 6e 10 80       	push   $0x80106e29
80103ebd:	e8 86 c4 ff ff       	call   80100348 <panic>

80103ec2 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103ec2:	55                   	push   %ebp
80103ec3:	89 e5                	mov    %esp,%ebp
80103ec5:	57                   	push   %edi
80103ec6:	53                   	push   %ebx
80103ec7:	8b 55 08             	mov    0x8(%ebp),%edx
80103eca:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103ecd:	f6 c2 03             	test   $0x3,%dl
80103ed0:	75 05                	jne    80103ed7 <memset+0x15>
80103ed2:	f6 c1 03             	test   $0x3,%cl
80103ed5:	74 0e                	je     80103ee5 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103ed7:	89 d7                	mov    %edx,%edi
80103ed9:	8b 45 0c             	mov    0xc(%ebp),%eax
80103edc:	fc                   	cld    
80103edd:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103edf:	89 d0                	mov    %edx,%eax
80103ee1:	5b                   	pop    %ebx
80103ee2:	5f                   	pop    %edi
80103ee3:	5d                   	pop    %ebp
80103ee4:	c3                   	ret    
    c &= 0xFF;
80103ee5:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103ee9:	c1 e9 02             	shr    $0x2,%ecx
80103eec:	89 f8                	mov    %edi,%eax
80103eee:	c1 e0 18             	shl    $0x18,%eax
80103ef1:	89 fb                	mov    %edi,%ebx
80103ef3:	c1 e3 10             	shl    $0x10,%ebx
80103ef6:	09 d8                	or     %ebx,%eax
80103ef8:	89 fb                	mov    %edi,%ebx
80103efa:	c1 e3 08             	shl    $0x8,%ebx
80103efd:	09 d8                	or     %ebx,%eax
80103eff:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103f01:	89 d7                	mov    %edx,%edi
80103f03:	fc                   	cld    
80103f04:	f3 ab                	rep stos %eax,%es:(%edi)
80103f06:	eb d7                	jmp    80103edf <memset+0x1d>

80103f08 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103f08:	55                   	push   %ebp
80103f09:	89 e5                	mov    %esp,%ebp
80103f0b:	56                   	push   %esi
80103f0c:	53                   	push   %ebx
80103f0d:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103f10:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f13:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103f16:	8d 70 ff             	lea    -0x1(%eax),%esi
80103f19:	85 c0                	test   %eax,%eax
80103f1b:	74 1c                	je     80103f39 <memcmp+0x31>
    if(*s1 != *s2)
80103f1d:	0f b6 01             	movzbl (%ecx),%eax
80103f20:	0f b6 1a             	movzbl (%edx),%ebx
80103f23:	38 d8                	cmp    %bl,%al
80103f25:	75 0a                	jne    80103f31 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103f27:	83 c1 01             	add    $0x1,%ecx
80103f2a:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103f2d:	89 f0                	mov    %esi,%eax
80103f2f:	eb e5                	jmp    80103f16 <memcmp+0xe>
      return *s1 - *s2;
80103f31:	0f b6 c0             	movzbl %al,%eax
80103f34:	0f b6 db             	movzbl %bl,%ebx
80103f37:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103f39:	5b                   	pop    %ebx
80103f3a:	5e                   	pop    %esi
80103f3b:	5d                   	pop    %ebp
80103f3c:	c3                   	ret    

80103f3d <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103f3d:	55                   	push   %ebp
80103f3e:	89 e5                	mov    %esp,%ebp
80103f40:	56                   	push   %esi
80103f41:	53                   	push   %ebx
80103f42:	8b 45 08             	mov    0x8(%ebp),%eax
80103f45:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103f48:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103f4b:	39 c1                	cmp    %eax,%ecx
80103f4d:	73 3a                	jae    80103f89 <memmove+0x4c>
80103f4f:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103f52:	39 c3                	cmp    %eax,%ebx
80103f54:	76 37                	jbe    80103f8d <memmove+0x50>
    s += n;
    d += n;
80103f56:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103f59:	eb 0d                	jmp    80103f68 <memmove+0x2b>
      *--d = *--s;
80103f5b:	83 eb 01             	sub    $0x1,%ebx
80103f5e:	83 e9 01             	sub    $0x1,%ecx
80103f61:	0f b6 13             	movzbl (%ebx),%edx
80103f64:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103f66:	89 f2                	mov    %esi,%edx
80103f68:	8d 72 ff             	lea    -0x1(%edx),%esi
80103f6b:	85 d2                	test   %edx,%edx
80103f6d:	75 ec                	jne    80103f5b <memmove+0x1e>
80103f6f:	eb 14                	jmp    80103f85 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103f71:	0f b6 11             	movzbl (%ecx),%edx
80103f74:	88 13                	mov    %dl,(%ebx)
80103f76:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103f79:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103f7c:	89 f2                	mov    %esi,%edx
80103f7e:	8d 72 ff             	lea    -0x1(%edx),%esi
80103f81:	85 d2                	test   %edx,%edx
80103f83:	75 ec                	jne    80103f71 <memmove+0x34>

  return dst;
}
80103f85:	5b                   	pop    %ebx
80103f86:	5e                   	pop    %esi
80103f87:	5d                   	pop    %ebp
80103f88:	c3                   	ret    
80103f89:	89 c3                	mov    %eax,%ebx
80103f8b:	eb f1                	jmp    80103f7e <memmove+0x41>
80103f8d:	89 c3                	mov    %eax,%ebx
80103f8f:	eb ed                	jmp    80103f7e <memmove+0x41>

80103f91 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103f91:	55                   	push   %ebp
80103f92:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103f94:	ff 75 10             	pushl  0x10(%ebp)
80103f97:	ff 75 0c             	pushl  0xc(%ebp)
80103f9a:	ff 75 08             	pushl  0x8(%ebp)
80103f9d:	e8 9b ff ff ff       	call   80103f3d <memmove>
}
80103fa2:	c9                   	leave  
80103fa3:	c3                   	ret    

80103fa4 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103fa4:	55                   	push   %ebp
80103fa5:	89 e5                	mov    %esp,%ebp
80103fa7:	53                   	push   %ebx
80103fa8:	8b 55 08             	mov    0x8(%ebp),%edx
80103fab:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103fae:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103fb1:	eb 09                	jmp    80103fbc <strncmp+0x18>
    n--, p++, q++;
80103fb3:	83 e8 01             	sub    $0x1,%eax
80103fb6:	83 c2 01             	add    $0x1,%edx
80103fb9:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103fbc:	85 c0                	test   %eax,%eax
80103fbe:	74 0b                	je     80103fcb <strncmp+0x27>
80103fc0:	0f b6 1a             	movzbl (%edx),%ebx
80103fc3:	84 db                	test   %bl,%bl
80103fc5:	74 04                	je     80103fcb <strncmp+0x27>
80103fc7:	3a 19                	cmp    (%ecx),%bl
80103fc9:	74 e8                	je     80103fb3 <strncmp+0xf>
  if(n == 0)
80103fcb:	85 c0                	test   %eax,%eax
80103fcd:	74 0b                	je     80103fda <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103fcf:	0f b6 02             	movzbl (%edx),%eax
80103fd2:	0f b6 11             	movzbl (%ecx),%edx
80103fd5:	29 d0                	sub    %edx,%eax
}
80103fd7:	5b                   	pop    %ebx
80103fd8:	5d                   	pop    %ebp
80103fd9:	c3                   	ret    
    return 0;
80103fda:	b8 00 00 00 00       	mov    $0x0,%eax
80103fdf:	eb f6                	jmp    80103fd7 <strncmp+0x33>

80103fe1 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103fe1:	55                   	push   %ebp
80103fe2:	89 e5                	mov    %esp,%ebp
80103fe4:	57                   	push   %edi
80103fe5:	56                   	push   %esi
80103fe6:	53                   	push   %ebx
80103fe7:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103fea:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103fed:	8b 45 08             	mov    0x8(%ebp),%eax
80103ff0:	eb 04                	jmp    80103ff6 <strncpy+0x15>
80103ff2:	89 fb                	mov    %edi,%ebx
80103ff4:	89 f0                	mov    %esi,%eax
80103ff6:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103ff9:	85 c9                	test   %ecx,%ecx
80103ffb:	7e 1d                	jle    8010401a <strncpy+0x39>
80103ffd:	8d 7b 01             	lea    0x1(%ebx),%edi
80104000:	8d 70 01             	lea    0x1(%eax),%esi
80104003:	0f b6 1b             	movzbl (%ebx),%ebx
80104006:	88 18                	mov    %bl,(%eax)
80104008:	89 d1                	mov    %edx,%ecx
8010400a:	84 db                	test   %bl,%bl
8010400c:	75 e4                	jne    80103ff2 <strncpy+0x11>
8010400e:	89 f0                	mov    %esi,%eax
80104010:	eb 08                	jmp    8010401a <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80104012:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80104015:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80104017:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
8010401a:	8d 4a ff             	lea    -0x1(%edx),%ecx
8010401d:	85 d2                	test   %edx,%edx
8010401f:	7f f1                	jg     80104012 <strncpy+0x31>
  return os;
}
80104021:	8b 45 08             	mov    0x8(%ebp),%eax
80104024:	5b                   	pop    %ebx
80104025:	5e                   	pop    %esi
80104026:	5f                   	pop    %edi
80104027:	5d                   	pop    %ebp
80104028:	c3                   	ret    

80104029 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80104029:	55                   	push   %ebp
8010402a:	89 e5                	mov    %esp,%ebp
8010402c:	57                   	push   %edi
8010402d:	56                   	push   %esi
8010402e:	53                   	push   %ebx
8010402f:	8b 45 08             	mov    0x8(%ebp),%eax
80104032:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80104035:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80104038:	85 d2                	test   %edx,%edx
8010403a:	7e 23                	jle    8010405f <safestrcpy+0x36>
8010403c:	89 c1                	mov    %eax,%ecx
8010403e:	eb 04                	jmp    80104044 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80104040:	89 fb                	mov    %edi,%ebx
80104042:	89 f1                	mov    %esi,%ecx
80104044:	83 ea 01             	sub    $0x1,%edx
80104047:	85 d2                	test   %edx,%edx
80104049:	7e 11                	jle    8010405c <safestrcpy+0x33>
8010404b:	8d 7b 01             	lea    0x1(%ebx),%edi
8010404e:	8d 71 01             	lea    0x1(%ecx),%esi
80104051:	0f b6 1b             	movzbl (%ebx),%ebx
80104054:	88 19                	mov    %bl,(%ecx)
80104056:	84 db                	test   %bl,%bl
80104058:	75 e6                	jne    80104040 <safestrcpy+0x17>
8010405a:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
8010405c:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
8010405f:	5b                   	pop    %ebx
80104060:	5e                   	pop    %esi
80104061:	5f                   	pop    %edi
80104062:	5d                   	pop    %ebp
80104063:	c3                   	ret    

80104064 <strlen>:

int
strlen(const char *s)
{
80104064:	55                   	push   %ebp
80104065:	89 e5                	mov    %esp,%ebp
80104067:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
8010406a:	b8 00 00 00 00       	mov    $0x0,%eax
8010406f:	eb 03                	jmp    80104074 <strlen+0x10>
80104071:	83 c0 01             	add    $0x1,%eax
80104074:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80104078:	75 f7                	jne    80104071 <strlen+0xd>
    ;
  return n;
}
8010407a:	5d                   	pop    %ebp
8010407b:	c3                   	ret    

8010407c <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
8010407c:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80104080:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80104084:	55                   	push   %ebp
  pushl %ebx
80104085:	53                   	push   %ebx
  pushl %esi
80104086:	56                   	push   %esi
  pushl %edi
80104087:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80104088:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
8010408a:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
8010408c:	5f                   	pop    %edi
  popl %esi
8010408d:	5e                   	pop    %esi
  popl %ebx
8010408e:	5b                   	pop    %ebx
  popl %ebp
8010408f:	5d                   	pop    %ebp
  ret
80104090:	c3                   	ret    

80104091 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80104091:	55                   	push   %ebp
80104092:	89 e5                	mov    %esp,%ebp
80104094:	53                   	push   %ebx
80104095:	83 ec 04             	sub    $0x4,%esp
80104098:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
8010409b:	e8 0b f3 ff ff       	call   801033ab <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
801040a0:	8b 00                	mov    (%eax),%eax
801040a2:	39 d8                	cmp    %ebx,%eax
801040a4:	76 19                	jbe    801040bf <fetchint+0x2e>
801040a6:	8d 53 04             	lea    0x4(%ebx),%edx
801040a9:	39 d0                	cmp    %edx,%eax
801040ab:	72 19                	jb     801040c6 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
801040ad:	8b 13                	mov    (%ebx),%edx
801040af:	8b 45 0c             	mov    0xc(%ebp),%eax
801040b2:	89 10                	mov    %edx,(%eax)
  return 0;
801040b4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040b9:	83 c4 04             	add    $0x4,%esp
801040bc:	5b                   	pop    %ebx
801040bd:	5d                   	pop    %ebp
801040be:	c3                   	ret    
    return -1;
801040bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040c4:	eb f3                	jmp    801040b9 <fetchint+0x28>
801040c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cb:	eb ec                	jmp    801040b9 <fetchint+0x28>

801040cd <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
801040cd:	55                   	push   %ebp
801040ce:	89 e5                	mov    %esp,%ebp
801040d0:	53                   	push   %ebx
801040d1:	83 ec 04             	sub    $0x4,%esp
801040d4:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
801040d7:	e8 cf f2 ff ff       	call   801033ab <myproc>

  if(addr >= curproc->sz)
801040dc:	39 18                	cmp    %ebx,(%eax)
801040de:	76 26                	jbe    80104106 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
801040e0:	8b 55 0c             	mov    0xc(%ebp),%edx
801040e3:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
801040e5:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
801040e7:	89 d8                	mov    %ebx,%eax
801040e9:	39 d0                	cmp    %edx,%eax
801040eb:	73 0e                	jae    801040fb <fetchstr+0x2e>
    if(*s == 0)
801040ed:	80 38 00             	cmpb   $0x0,(%eax)
801040f0:	74 05                	je     801040f7 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
801040f2:	83 c0 01             	add    $0x1,%eax
801040f5:	eb f2                	jmp    801040e9 <fetchstr+0x1c>
      return s - *pp;
801040f7:	29 d8                	sub    %ebx,%eax
801040f9:	eb 05                	jmp    80104100 <fetchstr+0x33>
  }
  return -1;
801040fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104100:	83 c4 04             	add    $0x4,%esp
80104103:	5b                   	pop    %ebx
80104104:	5d                   	pop    %ebp
80104105:	c3                   	ret    
    return -1;
80104106:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010410b:	eb f3                	jmp    80104100 <fetchstr+0x33>

8010410d <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
8010410d:	55                   	push   %ebp
8010410e:	89 e5                	mov    %esp,%ebp
80104110:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80104113:	e8 93 f2 ff ff       	call   801033ab <myproc>
80104118:	8b 50 18             	mov    0x18(%eax),%edx
8010411b:	8b 45 08             	mov    0x8(%ebp),%eax
8010411e:	c1 e0 02             	shl    $0x2,%eax
80104121:	03 42 44             	add    0x44(%edx),%eax
80104124:	83 ec 08             	sub    $0x8,%esp
80104127:	ff 75 0c             	pushl  0xc(%ebp)
8010412a:	83 c0 04             	add    $0x4,%eax
8010412d:	50                   	push   %eax
8010412e:	e8 5e ff ff ff       	call   80104091 <fetchint>
}
80104133:	c9                   	leave  
80104134:	c3                   	ret    

80104135 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104135:	55                   	push   %ebp
80104136:	89 e5                	mov    %esp,%ebp
80104138:	56                   	push   %esi
80104139:	53                   	push   %ebx
8010413a:	83 ec 10             	sub    $0x10,%esp
8010413d:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104140:	e8 66 f2 ff ff       	call   801033ab <myproc>
80104145:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104147:	83 ec 08             	sub    $0x8,%esp
8010414a:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010414d:	50                   	push   %eax
8010414e:	ff 75 08             	pushl  0x8(%ebp)
80104151:	e8 b7 ff ff ff       	call   8010410d <argint>
80104156:	83 c4 10             	add    $0x10,%esp
80104159:	85 c0                	test   %eax,%eax
8010415b:	78 24                	js     80104181 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
8010415d:	85 db                	test   %ebx,%ebx
8010415f:	78 27                	js     80104188 <argptr+0x53>
80104161:	8b 16                	mov    (%esi),%edx
80104163:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104166:	39 c2                	cmp    %eax,%edx
80104168:	76 25                	jbe    8010418f <argptr+0x5a>
8010416a:	01 c3                	add    %eax,%ebx
8010416c:	39 da                	cmp    %ebx,%edx
8010416e:	72 26                	jb     80104196 <argptr+0x61>
    return -1;
  *pp = (char*)i;
80104170:	8b 55 0c             	mov    0xc(%ebp),%edx
80104173:	89 02                	mov    %eax,(%edx)
  return 0;
80104175:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010417a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010417d:	5b                   	pop    %ebx
8010417e:	5e                   	pop    %esi
8010417f:	5d                   	pop    %ebp
80104180:	c3                   	ret    
    return -1;
80104181:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104186:	eb f2                	jmp    8010417a <argptr+0x45>
    return -1;
80104188:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010418d:	eb eb                	jmp    8010417a <argptr+0x45>
8010418f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104194:	eb e4                	jmp    8010417a <argptr+0x45>
80104196:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010419b:	eb dd                	jmp    8010417a <argptr+0x45>

8010419d <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
8010419d:	55                   	push   %ebp
8010419e:	89 e5                	mov    %esp,%ebp
801041a0:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801041a3:	8d 45 f4             	lea    -0xc(%ebp),%eax
801041a6:	50                   	push   %eax
801041a7:	ff 75 08             	pushl  0x8(%ebp)
801041aa:	e8 5e ff ff ff       	call   8010410d <argint>
801041af:	83 c4 10             	add    $0x10,%esp
801041b2:	85 c0                	test   %eax,%eax
801041b4:	78 13                	js     801041c9 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801041b6:	83 ec 08             	sub    $0x8,%esp
801041b9:	ff 75 0c             	pushl  0xc(%ebp)
801041bc:	ff 75 f4             	pushl  -0xc(%ebp)
801041bf:	e8 09 ff ff ff       	call   801040cd <fetchstr>
801041c4:	83 c4 10             	add    $0x10,%esp
}
801041c7:	c9                   	leave  
801041c8:	c3                   	ret    
    return -1;
801041c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041ce:	eb f7                	jmp    801041c7 <argstr+0x2a>

801041d0 <syscall>:
[SYS_dump_physmem] sys_dump_physmem,
};

void
syscall(void)
{
801041d0:	55                   	push   %ebp
801041d1:	89 e5                	mov    %esp,%ebp
801041d3:	53                   	push   %ebx
801041d4:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801041d7:	e8 cf f1 ff ff       	call   801033ab <myproc>
801041dc:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
801041de:	8b 40 18             	mov    0x18(%eax),%eax
801041e1:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801041e4:	8d 50 ff             	lea    -0x1(%eax),%edx
801041e7:	83 fa 15             	cmp    $0x15,%edx
801041ea:	77 18                	ja     80104204 <syscall+0x34>
801041ec:	8b 14 85 60 6e 10 80 	mov    -0x7fef91a0(,%eax,4),%edx
801041f3:	85 d2                	test   %edx,%edx
801041f5:	74 0d                	je     80104204 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
801041f7:	ff d2                	call   *%edx
801041f9:	8b 53 18             	mov    0x18(%ebx),%edx
801041fc:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
801041ff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104202:	c9                   	leave  
80104203:	c3                   	ret    
            curproc->pid, curproc->name, num);
80104204:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104207:	50                   	push   %eax
80104208:	52                   	push   %edx
80104209:	ff 73 10             	pushl  0x10(%ebx)
8010420c:	68 31 6e 10 80       	push   $0x80106e31
80104211:	e8 f5 c3 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104216:	8b 43 18             	mov    0x18(%ebx),%eax
80104219:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104220:	83 c4 10             	add    $0x10,%esp
}
80104223:	eb da                	jmp    801041ff <syscall+0x2f>

80104225 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104225:	55                   	push   %ebp
80104226:	89 e5                	mov    %esp,%ebp
80104228:	56                   	push   %esi
80104229:	53                   	push   %ebx
8010422a:	83 ec 18             	sub    $0x18,%esp
8010422d:	89 d6                	mov    %edx,%esi
8010422f:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80104231:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104234:	52                   	push   %edx
80104235:	50                   	push   %eax
80104236:	e8 d2 fe ff ff       	call   8010410d <argint>
8010423b:	83 c4 10             	add    $0x10,%esp
8010423e:	85 c0                	test   %eax,%eax
80104240:	78 2e                	js     80104270 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104242:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104246:	77 2f                	ja     80104277 <argfd+0x52>
80104248:	e8 5e f1 ff ff       	call   801033ab <myproc>
8010424d:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104250:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104254:	85 c0                	test   %eax,%eax
80104256:	74 26                	je     8010427e <argfd+0x59>
    return -1;
  if(pfd)
80104258:	85 f6                	test   %esi,%esi
8010425a:	74 02                	je     8010425e <argfd+0x39>
    *pfd = fd;
8010425c:	89 16                	mov    %edx,(%esi)
  if(pf)
8010425e:	85 db                	test   %ebx,%ebx
80104260:	74 23                	je     80104285 <argfd+0x60>
    *pf = f;
80104262:	89 03                	mov    %eax,(%ebx)
  return 0;
80104264:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104269:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010426c:	5b                   	pop    %ebx
8010426d:	5e                   	pop    %esi
8010426e:	5d                   	pop    %ebp
8010426f:	c3                   	ret    
    return -1;
80104270:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104275:	eb f2                	jmp    80104269 <argfd+0x44>
    return -1;
80104277:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010427c:	eb eb                	jmp    80104269 <argfd+0x44>
8010427e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104283:	eb e4                	jmp    80104269 <argfd+0x44>
  return 0;
80104285:	b8 00 00 00 00       	mov    $0x0,%eax
8010428a:	eb dd                	jmp    80104269 <argfd+0x44>

8010428c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010428c:	55                   	push   %ebp
8010428d:	89 e5                	mov    %esp,%ebp
8010428f:	53                   	push   %ebx
80104290:	83 ec 04             	sub    $0x4,%esp
80104293:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104295:	e8 11 f1 ff ff       	call   801033ab <myproc>

  for(fd = 0; fd < NOFILE; fd++){
8010429a:	ba 00 00 00 00       	mov    $0x0,%edx
8010429f:	83 fa 0f             	cmp    $0xf,%edx
801042a2:	7f 18                	jg     801042bc <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801042a4:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801042a9:	74 05                	je     801042b0 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801042ab:	83 c2 01             	add    $0x1,%edx
801042ae:	eb ef                	jmp    8010429f <fdalloc+0x13>
      curproc->ofile[fd] = f;
801042b0:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801042b4:	89 d0                	mov    %edx,%eax
801042b6:	83 c4 04             	add    $0x4,%esp
801042b9:	5b                   	pop    %ebx
801042ba:	5d                   	pop    %ebp
801042bb:	c3                   	ret    
  return -1;
801042bc:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801042c1:	eb f1                	jmp    801042b4 <fdalloc+0x28>

801042c3 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801042c3:	55                   	push   %ebp
801042c4:	89 e5                	mov    %esp,%ebp
801042c6:	56                   	push   %esi
801042c7:	53                   	push   %ebx
801042c8:	83 ec 10             	sub    $0x10,%esp
801042cb:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801042cd:	b8 20 00 00 00       	mov    $0x20,%eax
801042d2:	89 c6                	mov    %eax,%esi
801042d4:	39 43 58             	cmp    %eax,0x58(%ebx)
801042d7:	76 2e                	jbe    80104307 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801042d9:	6a 10                	push   $0x10
801042db:	50                   	push   %eax
801042dc:	8d 45 e8             	lea    -0x18(%ebp),%eax
801042df:	50                   	push   %eax
801042e0:	53                   	push   %ebx
801042e1:	e8 8d d4 ff ff       	call   80101773 <readi>
801042e6:	83 c4 10             	add    $0x10,%esp
801042e9:	83 f8 10             	cmp    $0x10,%eax
801042ec:	75 0c                	jne    801042fa <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
801042ee:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
801042f3:	75 1e                	jne    80104313 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801042f5:	8d 46 10             	lea    0x10(%esi),%eax
801042f8:	eb d8                	jmp    801042d2 <isdirempty+0xf>
      panic("isdirempty: readi");
801042fa:	83 ec 0c             	sub    $0xc,%esp
801042fd:	68 bc 6e 10 80       	push   $0x80106ebc
80104302:	e8 41 c0 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104307:	b8 01 00 00 00       	mov    $0x1,%eax
}
8010430c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010430f:	5b                   	pop    %ebx
80104310:	5e                   	pop    %esi
80104311:	5d                   	pop    %ebp
80104312:	c3                   	ret    
      return 0;
80104313:	b8 00 00 00 00       	mov    $0x0,%eax
80104318:	eb f2                	jmp    8010430c <isdirempty+0x49>

8010431a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
8010431a:	55                   	push   %ebp
8010431b:	89 e5                	mov    %esp,%ebp
8010431d:	57                   	push   %edi
8010431e:	56                   	push   %esi
8010431f:	53                   	push   %ebx
80104320:	83 ec 44             	sub    $0x44,%esp
80104323:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104326:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104329:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
8010432c:	8d 55 d6             	lea    -0x2a(%ebp),%edx
8010432f:	52                   	push   %edx
80104330:	50                   	push   %eax
80104331:	e8 c3 d8 ff ff       	call   80101bf9 <nameiparent>
80104336:	89 c6                	mov    %eax,%esi
80104338:	83 c4 10             	add    $0x10,%esp
8010433b:	85 c0                	test   %eax,%eax
8010433d:	0f 84 3a 01 00 00    	je     8010447d <create+0x163>
    return 0;
  ilock(dp);
80104343:	83 ec 0c             	sub    $0xc,%esp
80104346:	50                   	push   %eax
80104347:	e8 35 d2 ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010434c:	83 c4 0c             	add    $0xc,%esp
8010434f:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104352:	50                   	push   %eax
80104353:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104356:	50                   	push   %eax
80104357:	56                   	push   %esi
80104358:	e8 53 d6 ff ff       	call   801019b0 <dirlookup>
8010435d:	89 c3                	mov    %eax,%ebx
8010435f:	83 c4 10             	add    $0x10,%esp
80104362:	85 c0                	test   %eax,%eax
80104364:	74 3f                	je     801043a5 <create+0x8b>
    iunlockput(dp);
80104366:	83 ec 0c             	sub    $0xc,%esp
80104369:	56                   	push   %esi
8010436a:	e8 b9 d3 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
8010436f:	89 1c 24             	mov    %ebx,(%esp)
80104372:	e8 0a d2 ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104377:	83 c4 10             	add    $0x10,%esp
8010437a:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
8010437f:	75 11                	jne    80104392 <create+0x78>
80104381:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104386:	75 0a                	jne    80104392 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104388:	89 d8                	mov    %ebx,%eax
8010438a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010438d:	5b                   	pop    %ebx
8010438e:	5e                   	pop    %esi
8010438f:	5f                   	pop    %edi
80104390:	5d                   	pop    %ebp
80104391:	c3                   	ret    
    iunlockput(ip);
80104392:	83 ec 0c             	sub    $0xc,%esp
80104395:	53                   	push   %ebx
80104396:	e8 8d d3 ff ff       	call   80101728 <iunlockput>
    return 0;
8010439b:	83 c4 10             	add    $0x10,%esp
8010439e:	bb 00 00 00 00       	mov    $0x0,%ebx
801043a3:	eb e3                	jmp    80104388 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801043a5:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801043a9:	83 ec 08             	sub    $0x8,%esp
801043ac:	50                   	push   %eax
801043ad:	ff 36                	pushl  (%esi)
801043af:	e8 ca cf ff ff       	call   8010137e <ialloc>
801043b4:	89 c3                	mov    %eax,%ebx
801043b6:	83 c4 10             	add    $0x10,%esp
801043b9:	85 c0                	test   %eax,%eax
801043bb:	74 55                	je     80104412 <create+0xf8>
  ilock(ip);
801043bd:	83 ec 0c             	sub    $0xc,%esp
801043c0:	50                   	push   %eax
801043c1:	e8 bb d1 ff ff       	call   80101581 <ilock>
  ip->major = major;
801043c6:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801043ca:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801043ce:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801043d2:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801043d8:	89 1c 24             	mov    %ebx,(%esp)
801043db:	e8 40 d0 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801043e0:	83 c4 10             	add    $0x10,%esp
801043e3:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
801043e8:	74 35                	je     8010441f <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
801043ea:	83 ec 04             	sub    $0x4,%esp
801043ed:	ff 73 04             	pushl  0x4(%ebx)
801043f0:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801043f3:	50                   	push   %eax
801043f4:	56                   	push   %esi
801043f5:	e8 36 d7 ff ff       	call   80101b30 <dirlink>
801043fa:	83 c4 10             	add    $0x10,%esp
801043fd:	85 c0                	test   %eax,%eax
801043ff:	78 6f                	js     80104470 <create+0x156>
  iunlockput(dp);
80104401:	83 ec 0c             	sub    $0xc,%esp
80104404:	56                   	push   %esi
80104405:	e8 1e d3 ff ff       	call   80101728 <iunlockput>
  return ip;
8010440a:	83 c4 10             	add    $0x10,%esp
8010440d:	e9 76 ff ff ff       	jmp    80104388 <create+0x6e>
    panic("create: ialloc");
80104412:	83 ec 0c             	sub    $0xc,%esp
80104415:	68 ce 6e 10 80       	push   $0x80106ece
8010441a:	e8 29 bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
8010441f:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104423:	83 c0 01             	add    $0x1,%eax
80104426:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010442a:	83 ec 0c             	sub    $0xc,%esp
8010442d:	56                   	push   %esi
8010442e:	e8 ed cf ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
80104433:	83 c4 0c             	add    $0xc,%esp
80104436:	ff 73 04             	pushl  0x4(%ebx)
80104439:	68 de 6e 10 80       	push   $0x80106ede
8010443e:	53                   	push   %ebx
8010443f:	e8 ec d6 ff ff       	call   80101b30 <dirlink>
80104444:	83 c4 10             	add    $0x10,%esp
80104447:	85 c0                	test   %eax,%eax
80104449:	78 18                	js     80104463 <create+0x149>
8010444b:	83 ec 04             	sub    $0x4,%esp
8010444e:	ff 76 04             	pushl  0x4(%esi)
80104451:	68 dd 6e 10 80       	push   $0x80106edd
80104456:	53                   	push   %ebx
80104457:	e8 d4 d6 ff ff       	call   80101b30 <dirlink>
8010445c:	83 c4 10             	add    $0x10,%esp
8010445f:	85 c0                	test   %eax,%eax
80104461:	79 87                	jns    801043ea <create+0xd0>
      panic("create dots");
80104463:	83 ec 0c             	sub    $0xc,%esp
80104466:	68 e0 6e 10 80       	push   $0x80106ee0
8010446b:	e8 d8 be ff ff       	call   80100348 <panic>
    panic("create: dirlink");
80104470:	83 ec 0c             	sub    $0xc,%esp
80104473:	68 ec 6e 10 80       	push   $0x80106eec
80104478:	e8 cb be ff ff       	call   80100348 <panic>
    return 0;
8010447d:	89 c3                	mov    %eax,%ebx
8010447f:	e9 04 ff ff ff       	jmp    80104388 <create+0x6e>

80104484 <sys_dup>:
{
80104484:	55                   	push   %ebp
80104485:	89 e5                	mov    %esp,%ebp
80104487:	53                   	push   %ebx
80104488:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010448b:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010448e:	ba 00 00 00 00       	mov    $0x0,%edx
80104493:	b8 00 00 00 00       	mov    $0x0,%eax
80104498:	e8 88 fd ff ff       	call   80104225 <argfd>
8010449d:	85 c0                	test   %eax,%eax
8010449f:	78 23                	js     801044c4 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801044a1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801044a4:	e8 e3 fd ff ff       	call   8010428c <fdalloc>
801044a9:	89 c3                	mov    %eax,%ebx
801044ab:	85 c0                	test   %eax,%eax
801044ad:	78 1c                	js     801044cb <sys_dup+0x47>
  filedup(f);
801044af:	83 ec 0c             	sub    $0xc,%esp
801044b2:	ff 75 f4             	pushl  -0xc(%ebp)
801044b5:	e8 d4 c7 ff ff       	call   80100c8e <filedup>
  return fd;
801044ba:	83 c4 10             	add    $0x10,%esp
}
801044bd:	89 d8                	mov    %ebx,%eax
801044bf:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801044c2:	c9                   	leave  
801044c3:	c3                   	ret    
    return -1;
801044c4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044c9:	eb f2                	jmp    801044bd <sys_dup+0x39>
    return -1;
801044cb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801044d0:	eb eb                	jmp    801044bd <sys_dup+0x39>

801044d2 <sys_read>:
{
801044d2:	55                   	push   %ebp
801044d3:	89 e5                	mov    %esp,%ebp
801044d5:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801044d8:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801044db:	ba 00 00 00 00       	mov    $0x0,%edx
801044e0:	b8 00 00 00 00       	mov    $0x0,%eax
801044e5:	e8 3b fd ff ff       	call   80104225 <argfd>
801044ea:	85 c0                	test   %eax,%eax
801044ec:	78 43                	js     80104531 <sys_read+0x5f>
801044ee:	83 ec 08             	sub    $0x8,%esp
801044f1:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044f4:	50                   	push   %eax
801044f5:	6a 02                	push   $0x2
801044f7:	e8 11 fc ff ff       	call   8010410d <argint>
801044fc:	83 c4 10             	add    $0x10,%esp
801044ff:	85 c0                	test   %eax,%eax
80104501:	78 35                	js     80104538 <sys_read+0x66>
80104503:	83 ec 04             	sub    $0x4,%esp
80104506:	ff 75 f0             	pushl  -0x10(%ebp)
80104509:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010450c:	50                   	push   %eax
8010450d:	6a 01                	push   $0x1
8010450f:	e8 21 fc ff ff       	call   80104135 <argptr>
80104514:	83 c4 10             	add    $0x10,%esp
80104517:	85 c0                	test   %eax,%eax
80104519:	78 24                	js     8010453f <sys_read+0x6d>
  return fileread(f, p, n);
8010451b:	83 ec 04             	sub    $0x4,%esp
8010451e:	ff 75 f0             	pushl  -0x10(%ebp)
80104521:	ff 75 ec             	pushl  -0x14(%ebp)
80104524:	ff 75 f4             	pushl  -0xc(%ebp)
80104527:	e8 ab c8 ff ff       	call   80100dd7 <fileread>
8010452c:	83 c4 10             	add    $0x10,%esp
}
8010452f:	c9                   	leave  
80104530:	c3                   	ret    
    return -1;
80104531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104536:	eb f7                	jmp    8010452f <sys_read+0x5d>
80104538:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010453d:	eb f0                	jmp    8010452f <sys_read+0x5d>
8010453f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104544:	eb e9                	jmp    8010452f <sys_read+0x5d>

80104546 <sys_write>:
{
80104546:	55                   	push   %ebp
80104547:	89 e5                	mov    %esp,%ebp
80104549:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010454c:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010454f:	ba 00 00 00 00       	mov    $0x0,%edx
80104554:	b8 00 00 00 00       	mov    $0x0,%eax
80104559:	e8 c7 fc ff ff       	call   80104225 <argfd>
8010455e:	85 c0                	test   %eax,%eax
80104560:	78 43                	js     801045a5 <sys_write+0x5f>
80104562:	83 ec 08             	sub    $0x8,%esp
80104565:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104568:	50                   	push   %eax
80104569:	6a 02                	push   $0x2
8010456b:	e8 9d fb ff ff       	call   8010410d <argint>
80104570:	83 c4 10             	add    $0x10,%esp
80104573:	85 c0                	test   %eax,%eax
80104575:	78 35                	js     801045ac <sys_write+0x66>
80104577:	83 ec 04             	sub    $0x4,%esp
8010457a:	ff 75 f0             	pushl  -0x10(%ebp)
8010457d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104580:	50                   	push   %eax
80104581:	6a 01                	push   $0x1
80104583:	e8 ad fb ff ff       	call   80104135 <argptr>
80104588:	83 c4 10             	add    $0x10,%esp
8010458b:	85 c0                	test   %eax,%eax
8010458d:	78 24                	js     801045b3 <sys_write+0x6d>
  return filewrite(f, p, n);
8010458f:	83 ec 04             	sub    $0x4,%esp
80104592:	ff 75 f0             	pushl  -0x10(%ebp)
80104595:	ff 75 ec             	pushl  -0x14(%ebp)
80104598:	ff 75 f4             	pushl  -0xc(%ebp)
8010459b:	e8 bc c8 ff ff       	call   80100e5c <filewrite>
801045a0:	83 c4 10             	add    $0x10,%esp
}
801045a3:	c9                   	leave  
801045a4:	c3                   	ret    
    return -1;
801045a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045aa:	eb f7                	jmp    801045a3 <sys_write+0x5d>
801045ac:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b1:	eb f0                	jmp    801045a3 <sys_write+0x5d>
801045b3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045b8:	eb e9                	jmp    801045a3 <sys_write+0x5d>

801045ba <sys_close>:
{
801045ba:	55                   	push   %ebp
801045bb:	89 e5                	mov    %esp,%ebp
801045bd:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801045c0:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801045c3:	8d 55 f4             	lea    -0xc(%ebp),%edx
801045c6:	b8 00 00 00 00       	mov    $0x0,%eax
801045cb:	e8 55 fc ff ff       	call   80104225 <argfd>
801045d0:	85 c0                	test   %eax,%eax
801045d2:	78 25                	js     801045f9 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801045d4:	e8 d2 ed ff ff       	call   801033ab <myproc>
801045d9:	8b 55 f4             	mov    -0xc(%ebp),%edx
801045dc:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801045e3:	00 
  fileclose(f);
801045e4:	83 ec 0c             	sub    $0xc,%esp
801045e7:	ff 75 f0             	pushl  -0x10(%ebp)
801045ea:	e8 e4 c6 ff ff       	call   80100cd3 <fileclose>
  return 0;
801045ef:	83 c4 10             	add    $0x10,%esp
801045f2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801045f7:	c9                   	leave  
801045f8:	c3                   	ret    
    return -1;
801045f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801045fe:	eb f7                	jmp    801045f7 <sys_close+0x3d>

80104600 <sys_fstat>:
{
80104600:	55                   	push   %ebp
80104601:	89 e5                	mov    %esp,%ebp
80104603:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104606:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104609:	ba 00 00 00 00       	mov    $0x0,%edx
8010460e:	b8 00 00 00 00       	mov    $0x0,%eax
80104613:	e8 0d fc ff ff       	call   80104225 <argfd>
80104618:	85 c0                	test   %eax,%eax
8010461a:	78 2a                	js     80104646 <sys_fstat+0x46>
8010461c:	83 ec 04             	sub    $0x4,%esp
8010461f:	6a 14                	push   $0x14
80104621:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104624:	50                   	push   %eax
80104625:	6a 01                	push   $0x1
80104627:	e8 09 fb ff ff       	call   80104135 <argptr>
8010462c:	83 c4 10             	add    $0x10,%esp
8010462f:	85 c0                	test   %eax,%eax
80104631:	78 1a                	js     8010464d <sys_fstat+0x4d>
  return filestat(f, st);
80104633:	83 ec 08             	sub    $0x8,%esp
80104636:	ff 75 f0             	pushl  -0x10(%ebp)
80104639:	ff 75 f4             	pushl  -0xc(%ebp)
8010463c:	e8 4f c7 ff ff       	call   80100d90 <filestat>
80104641:	83 c4 10             	add    $0x10,%esp
}
80104644:	c9                   	leave  
80104645:	c3                   	ret    
    return -1;
80104646:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010464b:	eb f7                	jmp    80104644 <sys_fstat+0x44>
8010464d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104652:	eb f0                	jmp    80104644 <sys_fstat+0x44>

80104654 <sys_link>:
{
80104654:	55                   	push   %ebp
80104655:	89 e5                	mov    %esp,%ebp
80104657:	56                   	push   %esi
80104658:	53                   	push   %ebx
80104659:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010465c:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010465f:	50                   	push   %eax
80104660:	6a 00                	push   $0x0
80104662:	e8 36 fb ff ff       	call   8010419d <argstr>
80104667:	83 c4 10             	add    $0x10,%esp
8010466a:	85 c0                	test   %eax,%eax
8010466c:	0f 88 32 01 00 00    	js     801047a4 <sys_link+0x150>
80104672:	83 ec 08             	sub    $0x8,%esp
80104675:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104678:	50                   	push   %eax
80104679:	6a 01                	push   $0x1
8010467b:	e8 1d fb ff ff       	call   8010419d <argstr>
80104680:	83 c4 10             	add    $0x10,%esp
80104683:	85 c0                	test   %eax,%eax
80104685:	0f 88 20 01 00 00    	js     801047ab <sys_link+0x157>
  begin_op();
8010468b:	e8 94 e3 ff ff       	call   80102a24 <begin_op>
  if((ip = namei(old)) == 0){
80104690:	83 ec 0c             	sub    $0xc,%esp
80104693:	ff 75 e0             	pushl  -0x20(%ebp)
80104696:	e8 46 d5 ff ff       	call   80101be1 <namei>
8010469b:	89 c3                	mov    %eax,%ebx
8010469d:	83 c4 10             	add    $0x10,%esp
801046a0:	85 c0                	test   %eax,%eax
801046a2:	0f 84 99 00 00 00    	je     80104741 <sys_link+0xed>
  ilock(ip);
801046a8:	83 ec 0c             	sub    $0xc,%esp
801046ab:	50                   	push   %eax
801046ac:	e8 d0 ce ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
801046b1:	83 c4 10             	add    $0x10,%esp
801046b4:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801046b9:	0f 84 8e 00 00 00    	je     8010474d <sys_link+0xf9>
  ip->nlink++;
801046bf:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046c3:	83 c0 01             	add    $0x1,%eax
801046c6:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046ca:	83 ec 0c             	sub    $0xc,%esp
801046cd:	53                   	push   %ebx
801046ce:	e8 4d cd ff ff       	call   80101420 <iupdate>
  iunlock(ip);
801046d3:	89 1c 24             	mov    %ebx,(%esp)
801046d6:	e8 68 cf ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801046db:	83 c4 08             	add    $0x8,%esp
801046de:	8d 45 ea             	lea    -0x16(%ebp),%eax
801046e1:	50                   	push   %eax
801046e2:	ff 75 e4             	pushl  -0x1c(%ebp)
801046e5:	e8 0f d5 ff ff       	call   80101bf9 <nameiparent>
801046ea:	89 c6                	mov    %eax,%esi
801046ec:	83 c4 10             	add    $0x10,%esp
801046ef:	85 c0                	test   %eax,%eax
801046f1:	74 7e                	je     80104771 <sys_link+0x11d>
  ilock(dp);
801046f3:	83 ec 0c             	sub    $0xc,%esp
801046f6:	50                   	push   %eax
801046f7:	e8 85 ce ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801046fc:	83 c4 10             	add    $0x10,%esp
801046ff:	8b 03                	mov    (%ebx),%eax
80104701:	39 06                	cmp    %eax,(%esi)
80104703:	75 60                	jne    80104765 <sys_link+0x111>
80104705:	83 ec 04             	sub    $0x4,%esp
80104708:	ff 73 04             	pushl  0x4(%ebx)
8010470b:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010470e:	50                   	push   %eax
8010470f:	56                   	push   %esi
80104710:	e8 1b d4 ff ff       	call   80101b30 <dirlink>
80104715:	83 c4 10             	add    $0x10,%esp
80104718:	85 c0                	test   %eax,%eax
8010471a:	78 49                	js     80104765 <sys_link+0x111>
  iunlockput(dp);
8010471c:	83 ec 0c             	sub    $0xc,%esp
8010471f:	56                   	push   %esi
80104720:	e8 03 d0 ff ff       	call   80101728 <iunlockput>
  iput(ip);
80104725:	89 1c 24             	mov    %ebx,(%esp)
80104728:	e8 5b cf ff ff       	call   80101688 <iput>
  end_op();
8010472d:	e8 6c e3 ff ff       	call   80102a9e <end_op>
  return 0;
80104732:	83 c4 10             	add    $0x10,%esp
80104735:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010473a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010473d:	5b                   	pop    %ebx
8010473e:	5e                   	pop    %esi
8010473f:	5d                   	pop    %ebp
80104740:	c3                   	ret    
    end_op();
80104741:	e8 58 e3 ff ff       	call   80102a9e <end_op>
    return -1;
80104746:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010474b:	eb ed                	jmp    8010473a <sys_link+0xe6>
    iunlockput(ip);
8010474d:	83 ec 0c             	sub    $0xc,%esp
80104750:	53                   	push   %ebx
80104751:	e8 d2 cf ff ff       	call   80101728 <iunlockput>
    end_op();
80104756:	e8 43 e3 ff ff       	call   80102a9e <end_op>
    return -1;
8010475b:	83 c4 10             	add    $0x10,%esp
8010475e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104763:	eb d5                	jmp    8010473a <sys_link+0xe6>
    iunlockput(dp);
80104765:	83 ec 0c             	sub    $0xc,%esp
80104768:	56                   	push   %esi
80104769:	e8 ba cf ff ff       	call   80101728 <iunlockput>
    goto bad;
8010476e:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104771:	83 ec 0c             	sub    $0xc,%esp
80104774:	53                   	push   %ebx
80104775:	e8 07 ce ff ff       	call   80101581 <ilock>
  ip->nlink--;
8010477a:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010477e:	83 e8 01             	sub    $0x1,%eax
80104781:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104785:	89 1c 24             	mov    %ebx,(%esp)
80104788:	e8 93 cc ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
8010478d:	89 1c 24             	mov    %ebx,(%esp)
80104790:	e8 93 cf ff ff       	call   80101728 <iunlockput>
  end_op();
80104795:	e8 04 e3 ff ff       	call   80102a9e <end_op>
  return -1;
8010479a:	83 c4 10             	add    $0x10,%esp
8010479d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a2:	eb 96                	jmp    8010473a <sys_link+0xe6>
    return -1;
801047a4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047a9:	eb 8f                	jmp    8010473a <sys_link+0xe6>
801047ab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801047b0:	eb 88                	jmp    8010473a <sys_link+0xe6>

801047b2 <sys_unlink>:
{
801047b2:	55                   	push   %ebp
801047b3:	89 e5                	mov    %esp,%ebp
801047b5:	57                   	push   %edi
801047b6:	56                   	push   %esi
801047b7:	53                   	push   %ebx
801047b8:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801047bb:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801047be:	50                   	push   %eax
801047bf:	6a 00                	push   $0x0
801047c1:	e8 d7 f9 ff ff       	call   8010419d <argstr>
801047c6:	83 c4 10             	add    $0x10,%esp
801047c9:	85 c0                	test   %eax,%eax
801047cb:	0f 88 83 01 00 00    	js     80104954 <sys_unlink+0x1a2>
  begin_op();
801047d1:	e8 4e e2 ff ff       	call   80102a24 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801047d6:	83 ec 08             	sub    $0x8,%esp
801047d9:	8d 45 ca             	lea    -0x36(%ebp),%eax
801047dc:	50                   	push   %eax
801047dd:	ff 75 c4             	pushl  -0x3c(%ebp)
801047e0:	e8 14 d4 ff ff       	call   80101bf9 <nameiparent>
801047e5:	89 c6                	mov    %eax,%esi
801047e7:	83 c4 10             	add    $0x10,%esp
801047ea:	85 c0                	test   %eax,%eax
801047ec:	0f 84 ed 00 00 00    	je     801048df <sys_unlink+0x12d>
  ilock(dp);
801047f2:	83 ec 0c             	sub    $0xc,%esp
801047f5:	50                   	push   %eax
801047f6:	e8 86 cd ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801047fb:	83 c4 08             	add    $0x8,%esp
801047fe:	68 de 6e 10 80       	push   $0x80106ede
80104803:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104806:	50                   	push   %eax
80104807:	e8 8f d1 ff ff       	call   8010199b <namecmp>
8010480c:	83 c4 10             	add    $0x10,%esp
8010480f:	85 c0                	test   %eax,%eax
80104811:	0f 84 fc 00 00 00    	je     80104913 <sys_unlink+0x161>
80104817:	83 ec 08             	sub    $0x8,%esp
8010481a:	68 dd 6e 10 80       	push   $0x80106edd
8010481f:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104822:	50                   	push   %eax
80104823:	e8 73 d1 ff ff       	call   8010199b <namecmp>
80104828:	83 c4 10             	add    $0x10,%esp
8010482b:	85 c0                	test   %eax,%eax
8010482d:	0f 84 e0 00 00 00    	je     80104913 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
80104833:	83 ec 04             	sub    $0x4,%esp
80104836:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104839:	50                   	push   %eax
8010483a:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010483d:	50                   	push   %eax
8010483e:	56                   	push   %esi
8010483f:	e8 6c d1 ff ff       	call   801019b0 <dirlookup>
80104844:	89 c3                	mov    %eax,%ebx
80104846:	83 c4 10             	add    $0x10,%esp
80104849:	85 c0                	test   %eax,%eax
8010484b:	0f 84 c2 00 00 00    	je     80104913 <sys_unlink+0x161>
  ilock(ip);
80104851:	83 ec 0c             	sub    $0xc,%esp
80104854:	50                   	push   %eax
80104855:	e8 27 cd ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
8010485a:	83 c4 10             	add    $0x10,%esp
8010485d:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104862:	0f 8e 83 00 00 00    	jle    801048eb <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104868:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010486d:	0f 84 85 00 00 00    	je     801048f8 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104873:	83 ec 04             	sub    $0x4,%esp
80104876:	6a 10                	push   $0x10
80104878:	6a 00                	push   $0x0
8010487a:	8d 7d d8             	lea    -0x28(%ebp),%edi
8010487d:	57                   	push   %edi
8010487e:	e8 3f f6 ff ff       	call   80103ec2 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104883:	6a 10                	push   $0x10
80104885:	ff 75 c0             	pushl  -0x40(%ebp)
80104888:	57                   	push   %edi
80104889:	56                   	push   %esi
8010488a:	e8 e1 cf ff ff       	call   80101870 <writei>
8010488f:	83 c4 20             	add    $0x20,%esp
80104892:	83 f8 10             	cmp    $0x10,%eax
80104895:	0f 85 90 00 00 00    	jne    8010492b <sys_unlink+0x179>
  if(ip->type == T_DIR){
8010489b:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801048a0:	0f 84 92 00 00 00    	je     80104938 <sys_unlink+0x186>
  iunlockput(dp);
801048a6:	83 ec 0c             	sub    $0xc,%esp
801048a9:	56                   	push   %esi
801048aa:	e8 79 ce ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
801048af:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801048b3:	83 e8 01             	sub    $0x1,%eax
801048b6:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801048ba:	89 1c 24             	mov    %ebx,(%esp)
801048bd:	e8 5e cb ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801048c2:	89 1c 24             	mov    %ebx,(%esp)
801048c5:	e8 5e ce ff ff       	call   80101728 <iunlockput>
  end_op();
801048ca:	e8 cf e1 ff ff       	call   80102a9e <end_op>
  return 0;
801048cf:	83 c4 10             	add    $0x10,%esp
801048d2:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048d7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801048da:	5b                   	pop    %ebx
801048db:	5e                   	pop    %esi
801048dc:	5f                   	pop    %edi
801048dd:	5d                   	pop    %ebp
801048de:	c3                   	ret    
    end_op();
801048df:	e8 ba e1 ff ff       	call   80102a9e <end_op>
    return -1;
801048e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048e9:	eb ec                	jmp    801048d7 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
801048eb:	83 ec 0c             	sub    $0xc,%esp
801048ee:	68 fc 6e 10 80       	push   $0x80106efc
801048f3:	e8 50 ba ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801048f8:	89 d8                	mov    %ebx,%eax
801048fa:	e8 c4 f9 ff ff       	call   801042c3 <isdirempty>
801048ff:	85 c0                	test   %eax,%eax
80104901:	0f 85 6c ff ff ff    	jne    80104873 <sys_unlink+0xc1>
    iunlockput(ip);
80104907:	83 ec 0c             	sub    $0xc,%esp
8010490a:	53                   	push   %ebx
8010490b:	e8 18 ce ff ff       	call   80101728 <iunlockput>
    goto bad;
80104910:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
80104913:	83 ec 0c             	sub    $0xc,%esp
80104916:	56                   	push   %esi
80104917:	e8 0c ce ff ff       	call   80101728 <iunlockput>
  end_op();
8010491c:	e8 7d e1 ff ff       	call   80102a9e <end_op>
  return -1;
80104921:	83 c4 10             	add    $0x10,%esp
80104924:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104929:	eb ac                	jmp    801048d7 <sys_unlink+0x125>
    panic("unlink: writei");
8010492b:	83 ec 0c             	sub    $0xc,%esp
8010492e:	68 0e 6f 10 80       	push   $0x80106f0e
80104933:	e8 10 ba ff ff       	call   80100348 <panic>
    dp->nlink--;
80104938:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010493c:	83 e8 01             	sub    $0x1,%eax
8010493f:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104943:	83 ec 0c             	sub    $0xc,%esp
80104946:	56                   	push   %esi
80104947:	e8 d4 ca ff ff       	call   80101420 <iupdate>
8010494c:	83 c4 10             	add    $0x10,%esp
8010494f:	e9 52 ff ff ff       	jmp    801048a6 <sys_unlink+0xf4>
    return -1;
80104954:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104959:	e9 79 ff ff ff       	jmp    801048d7 <sys_unlink+0x125>

8010495e <sys_open>:

int
sys_open(void)
{
8010495e:	55                   	push   %ebp
8010495f:	89 e5                	mov    %esp,%ebp
80104961:	57                   	push   %edi
80104962:	56                   	push   %esi
80104963:	53                   	push   %ebx
80104964:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104967:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010496a:	50                   	push   %eax
8010496b:	6a 00                	push   $0x0
8010496d:	e8 2b f8 ff ff       	call   8010419d <argstr>
80104972:	83 c4 10             	add    $0x10,%esp
80104975:	85 c0                	test   %eax,%eax
80104977:	0f 88 30 01 00 00    	js     80104aad <sys_open+0x14f>
8010497d:	83 ec 08             	sub    $0x8,%esp
80104980:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104983:	50                   	push   %eax
80104984:	6a 01                	push   $0x1
80104986:	e8 82 f7 ff ff       	call   8010410d <argint>
8010498b:	83 c4 10             	add    $0x10,%esp
8010498e:	85 c0                	test   %eax,%eax
80104990:	0f 88 21 01 00 00    	js     80104ab7 <sys_open+0x159>
    return -1;

  begin_op();
80104996:	e8 89 e0 ff ff       	call   80102a24 <begin_op>

  if(omode & O_CREATE){
8010499b:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
8010499f:	0f 84 84 00 00 00    	je     80104a29 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801049a5:	83 ec 0c             	sub    $0xc,%esp
801049a8:	6a 00                	push   $0x0
801049aa:	b9 00 00 00 00       	mov    $0x0,%ecx
801049af:	ba 02 00 00 00       	mov    $0x2,%edx
801049b4:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801049b7:	e8 5e f9 ff ff       	call   8010431a <create>
801049bc:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801049be:	83 c4 10             	add    $0x10,%esp
801049c1:	85 c0                	test   %eax,%eax
801049c3:	74 58                	je     80104a1d <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801049c5:	e8 63 c2 ff ff       	call   80100c2d <filealloc>
801049ca:	89 c3                	mov    %eax,%ebx
801049cc:	85 c0                	test   %eax,%eax
801049ce:	0f 84 ae 00 00 00    	je     80104a82 <sys_open+0x124>
801049d4:	e8 b3 f8 ff ff       	call   8010428c <fdalloc>
801049d9:	89 c7                	mov    %eax,%edi
801049db:	85 c0                	test   %eax,%eax
801049dd:	0f 88 9f 00 00 00    	js     80104a82 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801049e3:	83 ec 0c             	sub    $0xc,%esp
801049e6:	56                   	push   %esi
801049e7:	e8 57 cc ff ff       	call   80101643 <iunlock>
  end_op();
801049ec:	e8 ad e0 ff ff       	call   80102a9e <end_op>

  f->type = FD_INODE;
801049f1:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801049f7:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801049fa:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
80104a01:	8b 45 e0             	mov    -0x20(%ebp),%eax
80104a04:	83 c4 10             	add    $0x10,%esp
80104a07:	a8 01                	test   $0x1,%al
80104a09:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104a0d:	a8 03                	test   $0x3,%al
80104a0f:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
80104a13:	89 f8                	mov    %edi,%eax
80104a15:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104a18:	5b                   	pop    %ebx
80104a19:	5e                   	pop    %esi
80104a1a:	5f                   	pop    %edi
80104a1b:	5d                   	pop    %ebp
80104a1c:	c3                   	ret    
      end_op();
80104a1d:	e8 7c e0 ff ff       	call   80102a9e <end_op>
      return -1;
80104a22:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a27:	eb ea                	jmp    80104a13 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104a29:	83 ec 0c             	sub    $0xc,%esp
80104a2c:	ff 75 e4             	pushl  -0x1c(%ebp)
80104a2f:	e8 ad d1 ff ff       	call   80101be1 <namei>
80104a34:	89 c6                	mov    %eax,%esi
80104a36:	83 c4 10             	add    $0x10,%esp
80104a39:	85 c0                	test   %eax,%eax
80104a3b:	74 39                	je     80104a76 <sys_open+0x118>
    ilock(ip);
80104a3d:	83 ec 0c             	sub    $0xc,%esp
80104a40:	50                   	push   %eax
80104a41:	e8 3b cb ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104a46:	83 c4 10             	add    $0x10,%esp
80104a49:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104a4e:	0f 85 71 ff ff ff    	jne    801049c5 <sys_open+0x67>
80104a54:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104a58:	0f 84 67 ff ff ff    	je     801049c5 <sys_open+0x67>
      iunlockput(ip);
80104a5e:	83 ec 0c             	sub    $0xc,%esp
80104a61:	56                   	push   %esi
80104a62:	e8 c1 cc ff ff       	call   80101728 <iunlockput>
      end_op();
80104a67:	e8 32 e0 ff ff       	call   80102a9e <end_op>
      return -1;
80104a6c:	83 c4 10             	add    $0x10,%esp
80104a6f:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a74:	eb 9d                	jmp    80104a13 <sys_open+0xb5>
      end_op();
80104a76:	e8 23 e0 ff ff       	call   80102a9e <end_op>
      return -1;
80104a7b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a80:	eb 91                	jmp    80104a13 <sys_open+0xb5>
    if(f)
80104a82:	85 db                	test   %ebx,%ebx
80104a84:	74 0c                	je     80104a92 <sys_open+0x134>
      fileclose(f);
80104a86:	83 ec 0c             	sub    $0xc,%esp
80104a89:	53                   	push   %ebx
80104a8a:	e8 44 c2 ff ff       	call   80100cd3 <fileclose>
80104a8f:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104a92:	83 ec 0c             	sub    $0xc,%esp
80104a95:	56                   	push   %esi
80104a96:	e8 8d cc ff ff       	call   80101728 <iunlockput>
    end_op();
80104a9b:	e8 fe df ff ff       	call   80102a9e <end_op>
    return -1;
80104aa0:	83 c4 10             	add    $0x10,%esp
80104aa3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104aa8:	e9 66 ff ff ff       	jmp    80104a13 <sys_open+0xb5>
    return -1;
80104aad:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104ab2:	e9 5c ff ff ff       	jmp    80104a13 <sys_open+0xb5>
80104ab7:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104abc:	e9 52 ff ff ff       	jmp    80104a13 <sys_open+0xb5>

80104ac1 <sys_mkdir>:

int
sys_mkdir(void)
{
80104ac1:	55                   	push   %ebp
80104ac2:	89 e5                	mov    %esp,%ebp
80104ac4:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104ac7:	e8 58 df ff ff       	call   80102a24 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104acc:	83 ec 08             	sub    $0x8,%esp
80104acf:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ad2:	50                   	push   %eax
80104ad3:	6a 00                	push   $0x0
80104ad5:	e8 c3 f6 ff ff       	call   8010419d <argstr>
80104ada:	83 c4 10             	add    $0x10,%esp
80104add:	85 c0                	test   %eax,%eax
80104adf:	78 36                	js     80104b17 <sys_mkdir+0x56>
80104ae1:	83 ec 0c             	sub    $0xc,%esp
80104ae4:	6a 00                	push   $0x0
80104ae6:	b9 00 00 00 00       	mov    $0x0,%ecx
80104aeb:	ba 01 00 00 00       	mov    $0x1,%edx
80104af0:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104af3:	e8 22 f8 ff ff       	call   8010431a <create>
80104af8:	83 c4 10             	add    $0x10,%esp
80104afb:	85 c0                	test   %eax,%eax
80104afd:	74 18                	je     80104b17 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104aff:	83 ec 0c             	sub    $0xc,%esp
80104b02:	50                   	push   %eax
80104b03:	e8 20 cc ff ff       	call   80101728 <iunlockput>
  end_op();
80104b08:	e8 91 df ff ff       	call   80102a9e <end_op>
  return 0;
80104b0d:	83 c4 10             	add    $0x10,%esp
80104b10:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b15:	c9                   	leave  
80104b16:	c3                   	ret    
    end_op();
80104b17:	e8 82 df ff ff       	call   80102a9e <end_op>
    return -1;
80104b1c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b21:	eb f2                	jmp    80104b15 <sys_mkdir+0x54>

80104b23 <sys_mknod>:

int
sys_mknod(void)
{
80104b23:	55                   	push   %ebp
80104b24:	89 e5                	mov    %esp,%ebp
80104b26:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104b29:	e8 f6 de ff ff       	call   80102a24 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104b2e:	83 ec 08             	sub    $0x8,%esp
80104b31:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b34:	50                   	push   %eax
80104b35:	6a 00                	push   $0x0
80104b37:	e8 61 f6 ff ff       	call   8010419d <argstr>
80104b3c:	83 c4 10             	add    $0x10,%esp
80104b3f:	85 c0                	test   %eax,%eax
80104b41:	78 62                	js     80104ba5 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104b43:	83 ec 08             	sub    $0x8,%esp
80104b46:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b49:	50                   	push   %eax
80104b4a:	6a 01                	push   $0x1
80104b4c:	e8 bc f5 ff ff       	call   8010410d <argint>
  if((argstr(0, &path)) < 0 ||
80104b51:	83 c4 10             	add    $0x10,%esp
80104b54:	85 c0                	test   %eax,%eax
80104b56:	78 4d                	js     80104ba5 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104b58:	83 ec 08             	sub    $0x8,%esp
80104b5b:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b5e:	50                   	push   %eax
80104b5f:	6a 02                	push   $0x2
80104b61:	e8 a7 f5 ff ff       	call   8010410d <argint>
     argint(1, &major) < 0 ||
80104b66:	83 c4 10             	add    $0x10,%esp
80104b69:	85 c0                	test   %eax,%eax
80104b6b:	78 38                	js     80104ba5 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104b6d:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104b71:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104b75:	83 ec 0c             	sub    $0xc,%esp
80104b78:	50                   	push   %eax
80104b79:	ba 03 00 00 00       	mov    $0x3,%edx
80104b7e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104b81:	e8 94 f7 ff ff       	call   8010431a <create>
80104b86:	83 c4 10             	add    $0x10,%esp
80104b89:	85 c0                	test   %eax,%eax
80104b8b:	74 18                	je     80104ba5 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104b8d:	83 ec 0c             	sub    $0xc,%esp
80104b90:	50                   	push   %eax
80104b91:	e8 92 cb ff ff       	call   80101728 <iunlockput>
  end_op();
80104b96:	e8 03 df ff ff       	call   80102a9e <end_op>
  return 0;
80104b9b:	83 c4 10             	add    $0x10,%esp
80104b9e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ba3:	c9                   	leave  
80104ba4:	c3                   	ret    
    end_op();
80104ba5:	e8 f4 de ff ff       	call   80102a9e <end_op>
    return -1;
80104baa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104baf:	eb f2                	jmp    80104ba3 <sys_mknod+0x80>

80104bb1 <sys_chdir>:

int
sys_chdir(void)
{
80104bb1:	55                   	push   %ebp
80104bb2:	89 e5                	mov    %esp,%ebp
80104bb4:	56                   	push   %esi
80104bb5:	53                   	push   %ebx
80104bb6:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104bb9:	e8 ed e7 ff ff       	call   801033ab <myproc>
80104bbe:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104bc0:	e8 5f de ff ff       	call   80102a24 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104bc5:	83 ec 08             	sub    $0x8,%esp
80104bc8:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bcb:	50                   	push   %eax
80104bcc:	6a 00                	push   $0x0
80104bce:	e8 ca f5 ff ff       	call   8010419d <argstr>
80104bd3:	83 c4 10             	add    $0x10,%esp
80104bd6:	85 c0                	test   %eax,%eax
80104bd8:	78 52                	js     80104c2c <sys_chdir+0x7b>
80104bda:	83 ec 0c             	sub    $0xc,%esp
80104bdd:	ff 75 f4             	pushl  -0xc(%ebp)
80104be0:	e8 fc cf ff ff       	call   80101be1 <namei>
80104be5:	89 c3                	mov    %eax,%ebx
80104be7:	83 c4 10             	add    $0x10,%esp
80104bea:	85 c0                	test   %eax,%eax
80104bec:	74 3e                	je     80104c2c <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104bee:	83 ec 0c             	sub    $0xc,%esp
80104bf1:	50                   	push   %eax
80104bf2:	e8 8a c9 ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80104bf7:	83 c4 10             	add    $0x10,%esp
80104bfa:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104bff:	75 37                	jne    80104c38 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104c01:	83 ec 0c             	sub    $0xc,%esp
80104c04:	53                   	push   %ebx
80104c05:	e8 39 ca ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80104c0a:	83 c4 04             	add    $0x4,%esp
80104c0d:	ff 76 68             	pushl  0x68(%esi)
80104c10:	e8 73 ca ff ff       	call   80101688 <iput>
  end_op();
80104c15:	e8 84 de ff ff       	call   80102a9e <end_op>
  curproc->cwd = ip;
80104c1a:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104c1d:	83 c4 10             	add    $0x10,%esp
80104c20:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104c25:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104c28:	5b                   	pop    %ebx
80104c29:	5e                   	pop    %esi
80104c2a:	5d                   	pop    %ebp
80104c2b:	c3                   	ret    
    end_op();
80104c2c:	e8 6d de ff ff       	call   80102a9e <end_op>
    return -1;
80104c31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c36:	eb ed                	jmp    80104c25 <sys_chdir+0x74>
    iunlockput(ip);
80104c38:	83 ec 0c             	sub    $0xc,%esp
80104c3b:	53                   	push   %ebx
80104c3c:	e8 e7 ca ff ff       	call   80101728 <iunlockput>
    end_op();
80104c41:	e8 58 de ff ff       	call   80102a9e <end_op>
    return -1;
80104c46:	83 c4 10             	add    $0x10,%esp
80104c49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c4e:	eb d5                	jmp    80104c25 <sys_chdir+0x74>

80104c50 <sys_exec>:

int
sys_exec(void)
{
80104c50:	55                   	push   %ebp
80104c51:	89 e5                	mov    %esp,%ebp
80104c53:	53                   	push   %ebx
80104c54:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104c5a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c5d:	50                   	push   %eax
80104c5e:	6a 00                	push   $0x0
80104c60:	e8 38 f5 ff ff       	call   8010419d <argstr>
80104c65:	83 c4 10             	add    $0x10,%esp
80104c68:	85 c0                	test   %eax,%eax
80104c6a:	0f 88 a8 00 00 00    	js     80104d18 <sys_exec+0xc8>
80104c70:	83 ec 08             	sub    $0x8,%esp
80104c73:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104c79:	50                   	push   %eax
80104c7a:	6a 01                	push   $0x1
80104c7c:	e8 8c f4 ff ff       	call   8010410d <argint>
80104c81:	83 c4 10             	add    $0x10,%esp
80104c84:	85 c0                	test   %eax,%eax
80104c86:	0f 88 93 00 00 00    	js     80104d1f <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104c8c:	83 ec 04             	sub    $0x4,%esp
80104c8f:	68 80 00 00 00       	push   $0x80
80104c94:	6a 00                	push   $0x0
80104c96:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c9c:	50                   	push   %eax
80104c9d:	e8 20 f2 ff ff       	call   80103ec2 <memset>
80104ca2:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104ca5:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104caa:	83 fb 1f             	cmp    $0x1f,%ebx
80104cad:	77 77                	ja     80104d26 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104caf:	83 ec 08             	sub    $0x8,%esp
80104cb2:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104cb8:	50                   	push   %eax
80104cb9:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104cbf:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104cc2:	50                   	push   %eax
80104cc3:	e8 c9 f3 ff ff       	call   80104091 <fetchint>
80104cc8:	83 c4 10             	add    $0x10,%esp
80104ccb:	85 c0                	test   %eax,%eax
80104ccd:	78 5e                	js     80104d2d <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104ccf:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104cd5:	85 c0                	test   %eax,%eax
80104cd7:	74 1d                	je     80104cf6 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104cd9:	83 ec 08             	sub    $0x8,%esp
80104cdc:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104ce3:	52                   	push   %edx
80104ce4:	50                   	push   %eax
80104ce5:	e8 e3 f3 ff ff       	call   801040cd <fetchstr>
80104cea:	83 c4 10             	add    $0x10,%esp
80104ced:	85 c0                	test   %eax,%eax
80104cef:	78 46                	js     80104d37 <sys_exec+0xe7>
  for(i=0;; i++){
80104cf1:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104cf4:	eb b4                	jmp    80104caa <sys_exec+0x5a>
      argv[i] = 0;
80104cf6:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104cfd:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104d01:	83 ec 08             	sub    $0x8,%esp
80104d04:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104d0a:	50                   	push   %eax
80104d0b:	ff 75 f4             	pushl  -0xc(%ebp)
80104d0e:	e8 bf bb ff ff       	call   801008d2 <exec>
80104d13:	83 c4 10             	add    $0x10,%esp
80104d16:	eb 1a                	jmp    80104d32 <sys_exec+0xe2>
    return -1;
80104d18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d1d:	eb 13                	jmp    80104d32 <sys_exec+0xe2>
80104d1f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d24:	eb 0c                	jmp    80104d32 <sys_exec+0xe2>
      return -1;
80104d26:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d2b:	eb 05                	jmp    80104d32 <sys_exec+0xe2>
      return -1;
80104d2d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104d32:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d35:	c9                   	leave  
80104d36:	c3                   	ret    
      return -1;
80104d37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d3c:	eb f4                	jmp    80104d32 <sys_exec+0xe2>

80104d3e <sys_pipe>:

int
sys_pipe(void)
{
80104d3e:	55                   	push   %ebp
80104d3f:	89 e5                	mov    %esp,%ebp
80104d41:	53                   	push   %ebx
80104d42:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104d45:	6a 08                	push   $0x8
80104d47:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d4a:	50                   	push   %eax
80104d4b:	6a 00                	push   $0x0
80104d4d:	e8 e3 f3 ff ff       	call   80104135 <argptr>
80104d52:	83 c4 10             	add    $0x10,%esp
80104d55:	85 c0                	test   %eax,%eax
80104d57:	78 77                	js     80104dd0 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104d59:	83 ec 08             	sub    $0x8,%esp
80104d5c:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104d5f:	50                   	push   %eax
80104d60:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104d63:	50                   	push   %eax
80104d64:	e8 42 e2 ff ff       	call   80102fab <pipealloc>
80104d69:	83 c4 10             	add    $0x10,%esp
80104d6c:	85 c0                	test   %eax,%eax
80104d6e:	78 67                	js     80104dd7 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104d70:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104d73:	e8 14 f5 ff ff       	call   8010428c <fdalloc>
80104d78:	89 c3                	mov    %eax,%ebx
80104d7a:	85 c0                	test   %eax,%eax
80104d7c:	78 21                	js     80104d9f <sys_pipe+0x61>
80104d7e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104d81:	e8 06 f5 ff ff       	call   8010428c <fdalloc>
80104d86:	85 c0                	test   %eax,%eax
80104d88:	78 15                	js     80104d9f <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104d8a:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d8d:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104d8f:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104d92:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104d95:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104d9a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d9d:	c9                   	leave  
80104d9e:	c3                   	ret    
    if(fd0 >= 0)
80104d9f:	85 db                	test   %ebx,%ebx
80104da1:	78 0d                	js     80104db0 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104da3:	e8 03 e6 ff ff       	call   801033ab <myproc>
80104da8:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104daf:	00 
    fileclose(rf);
80104db0:	83 ec 0c             	sub    $0xc,%esp
80104db3:	ff 75 f0             	pushl  -0x10(%ebp)
80104db6:	e8 18 bf ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104dbb:	83 c4 04             	add    $0x4,%esp
80104dbe:	ff 75 ec             	pushl  -0x14(%ebp)
80104dc1:	e8 0d bf ff ff       	call   80100cd3 <fileclose>
    return -1;
80104dc6:	83 c4 10             	add    $0x10,%esp
80104dc9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dce:	eb ca                	jmp    80104d9a <sys_pipe+0x5c>
    return -1;
80104dd0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104dd5:	eb c3                	jmp    80104d9a <sys_pipe+0x5c>
    return -1;
80104dd7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ddc:	eb bc                	jmp    80104d9a <sys_pipe+0x5c>

80104dde <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104dde:	55                   	push   %ebp
80104ddf:	89 e5                	mov    %esp,%ebp
80104de1:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104de4:	e8 06 e8 ff ff       	call   801035ef <fork>
}
80104de9:	c9                   	leave  
80104dea:	c3                   	ret    

80104deb <sys_exit>:

int
sys_exit(void)
{
80104deb:	55                   	push   %ebp
80104dec:	89 e5                	mov    %esp,%ebp
80104dee:	83 ec 08             	sub    $0x8,%esp
  exit();
80104df1:	e8 2d ea ff ff       	call   80103823 <exit>
  return 0;  // not reached
}
80104df6:	b8 00 00 00 00       	mov    $0x0,%eax
80104dfb:	c9                   	leave  
80104dfc:	c3                   	ret    

80104dfd <sys_wait>:

int
sys_wait(void)
{
80104dfd:	55                   	push   %ebp
80104dfe:	89 e5                	mov    %esp,%ebp
80104e00:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104e03:	e8 a4 eb ff ff       	call   801039ac <wait>
}
80104e08:	c9                   	leave  
80104e09:	c3                   	ret    

80104e0a <sys_kill>:

int
sys_kill(void)
{
80104e0a:	55                   	push   %ebp
80104e0b:	89 e5                	mov    %esp,%ebp
80104e0d:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104e10:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e13:	50                   	push   %eax
80104e14:	6a 00                	push   $0x0
80104e16:	e8 f2 f2 ff ff       	call   8010410d <argint>
80104e1b:	83 c4 10             	add    $0x10,%esp
80104e1e:	85 c0                	test   %eax,%eax
80104e20:	78 10                	js     80104e32 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104e22:	83 ec 0c             	sub    $0xc,%esp
80104e25:	ff 75 f4             	pushl  -0xc(%ebp)
80104e28:	e8 7c ec ff ff       	call   80103aa9 <kill>
80104e2d:	83 c4 10             	add    $0x10,%esp
}
80104e30:	c9                   	leave  
80104e31:	c3                   	ret    
    return -1;
80104e32:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e37:	eb f7                	jmp    80104e30 <sys_kill+0x26>

80104e39 <sys_getpid>:

int
sys_getpid(void)
{
80104e39:	55                   	push   %ebp
80104e3a:	89 e5                	mov    %esp,%ebp
80104e3c:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104e3f:	e8 67 e5 ff ff       	call   801033ab <myproc>
80104e44:	8b 40 10             	mov    0x10(%eax),%eax
}
80104e47:	c9                   	leave  
80104e48:	c3                   	ret    

80104e49 <sys_sbrk>:

int
sys_sbrk(void)
{
80104e49:	55                   	push   %ebp
80104e4a:	89 e5                	mov    %esp,%ebp
80104e4c:	53                   	push   %ebx
80104e4d:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104e50:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e53:	50                   	push   %eax
80104e54:	6a 00                	push   $0x0
80104e56:	e8 b2 f2 ff ff       	call   8010410d <argint>
80104e5b:	83 c4 10             	add    $0x10,%esp
80104e5e:	85 c0                	test   %eax,%eax
80104e60:	78 27                	js     80104e89 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104e62:	e8 44 e5 ff ff       	call   801033ab <myproc>
80104e67:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104e69:	83 ec 0c             	sub    $0xc,%esp
80104e6c:	ff 75 f4             	pushl  -0xc(%ebp)
80104e6f:	e8 0e e7 ff ff       	call   80103582 <growproc>
80104e74:	83 c4 10             	add    $0x10,%esp
80104e77:	85 c0                	test   %eax,%eax
80104e79:	78 07                	js     80104e82 <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104e7b:	89 d8                	mov    %ebx,%eax
80104e7d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e80:	c9                   	leave  
80104e81:	c3                   	ret    
    return -1;
80104e82:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e87:	eb f2                	jmp    80104e7b <sys_sbrk+0x32>
    return -1;
80104e89:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104e8e:	eb eb                	jmp    80104e7b <sys_sbrk+0x32>

80104e90 <sys_sleep>:

int
sys_sleep(void)
{
80104e90:	55                   	push   %ebp
80104e91:	89 e5                	mov    %esp,%ebp
80104e93:	53                   	push   %ebx
80104e94:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104e97:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e9a:	50                   	push   %eax
80104e9b:	6a 00                	push   $0x0
80104e9d:	e8 6b f2 ff ff       	call   8010410d <argint>
80104ea2:	83 c4 10             	add    $0x10,%esp
80104ea5:	85 c0                	test   %eax,%eax
80104ea7:	78 75                	js     80104f1e <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104ea9:	83 ec 0c             	sub    $0xc,%esp
80104eac:	68 a0 4c 13 80       	push   $0x80134ca0
80104eb1:	e8 60 ef ff ff       	call   80103e16 <acquire>
  ticks0 = ticks;
80104eb6:	8b 1d e0 54 13 80    	mov    0x801354e0,%ebx
  while(ticks - ticks0 < n){
80104ebc:	83 c4 10             	add    $0x10,%esp
80104ebf:	a1 e0 54 13 80       	mov    0x801354e0,%eax
80104ec4:	29 d8                	sub    %ebx,%eax
80104ec6:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104ec9:	73 39                	jae    80104f04 <sys_sleep+0x74>
    if(myproc()->killed){
80104ecb:	e8 db e4 ff ff       	call   801033ab <myproc>
80104ed0:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ed4:	75 17                	jne    80104eed <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104ed6:	83 ec 08             	sub    $0x8,%esp
80104ed9:	68 a0 4c 13 80       	push   $0x80134ca0
80104ede:	68 e0 54 13 80       	push   $0x801354e0
80104ee3:	e8 33 ea ff ff       	call   8010391b <sleep>
80104ee8:	83 c4 10             	add    $0x10,%esp
80104eeb:	eb d2                	jmp    80104ebf <sys_sleep+0x2f>
      release(&tickslock);
80104eed:	83 ec 0c             	sub    $0xc,%esp
80104ef0:	68 a0 4c 13 80       	push   $0x80134ca0
80104ef5:	e8 81 ef ff ff       	call   80103e7b <release>
      return -1;
80104efa:	83 c4 10             	add    $0x10,%esp
80104efd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f02:	eb 15                	jmp    80104f19 <sys_sleep+0x89>
  }
  release(&tickslock);
80104f04:	83 ec 0c             	sub    $0xc,%esp
80104f07:	68 a0 4c 13 80       	push   $0x80134ca0
80104f0c:	e8 6a ef ff ff       	call   80103e7b <release>
  return 0;
80104f11:	83 c4 10             	add    $0x10,%esp
80104f14:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104f19:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f1c:	c9                   	leave  
80104f1d:	c3                   	ret    
    return -1;
80104f1e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f23:	eb f4                	jmp    80104f19 <sys_sleep+0x89>

80104f25 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104f25:	55                   	push   %ebp
80104f26:	89 e5                	mov    %esp,%ebp
80104f28:	53                   	push   %ebx
80104f29:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104f2c:	68 a0 4c 13 80       	push   $0x80134ca0
80104f31:	e8 e0 ee ff ff       	call   80103e16 <acquire>
  xticks = ticks;
80104f36:	8b 1d e0 54 13 80    	mov    0x801354e0,%ebx
  release(&tickslock);
80104f3c:	c7 04 24 a0 4c 13 80 	movl   $0x80134ca0,(%esp)
80104f43:	e8 33 ef ff ff       	call   80103e7b <release>
  return xticks;
}
80104f48:	89 d8                	mov    %ebx,%eax
80104f4a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104f4d:	c9                   	leave  
80104f4e:	c3                   	ret    

80104f4f <sys_dump_physmem>:

// used for p5
// find which process owns each frame of phys mem
int
sys_dump_physmem(void)
{
80104f4f:	55                   	push   %ebp
80104f50:	89 e5                	mov    %esp,%ebp
80104f52:	83 ec 24             	sub    $0x24,%esp
  int *frames;
  int *pids;
  int numframes;
  cprintf("sys_dump_physmem in sysproc.c\n");
80104f55:	68 20 6f 10 80       	push   $0x80106f20
80104f5a:	e8 ac b6 ff ff       	call   8010060b <cprintf>
  if(argptr(0, (char**)&frames, sizeof(int*)) < 0)
80104f5f:	83 c4 0c             	add    $0xc,%esp
80104f62:	6a 04                	push   $0x4
80104f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104f67:	50                   	push   %eax
80104f68:	6a 00                	push   $0x0
80104f6a:	e8 c6 f1 ff ff       	call   80104135 <argptr>
80104f6f:	83 c4 10             	add    $0x10,%esp
80104f72:	85 c0                	test   %eax,%eax
80104f74:	78 42                	js     80104fb8 <sys_dump_physmem+0x69>
    return -1;
  if(argptr(1, (char**)&pids, sizeof(int*)) < 0)
80104f76:	83 ec 04             	sub    $0x4,%esp
80104f79:	6a 04                	push   $0x4
80104f7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104f7e:	50                   	push   %eax
80104f7f:	6a 01                	push   $0x1
80104f81:	e8 af f1 ff ff       	call   80104135 <argptr>
80104f86:	83 c4 10             	add    $0x10,%esp
80104f89:	85 c0                	test   %eax,%eax
80104f8b:	78 32                	js     80104fbf <sys_dump_physmem+0x70>
    return -1;
  if(argint(2, &numframes) < 0)
80104f8d:	83 ec 08             	sub    $0x8,%esp
80104f90:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104f93:	50                   	push   %eax
80104f94:	6a 02                	push   $0x2
80104f96:	e8 72 f1 ff ff       	call   8010410d <argint>
80104f9b:	83 c4 10             	add    $0x10,%esp
80104f9e:	85 c0                	test   %eax,%eax
80104fa0:	78 24                	js     80104fc6 <sys_dump_physmem+0x77>
    return -1;
  return dump_physmem(frames, pids, numframes);
80104fa2:	83 ec 04             	sub    $0x4,%esp
80104fa5:	ff 75 ec             	pushl  -0x14(%ebp)
80104fa8:	ff 75 f0             	pushl  -0x10(%ebp)
80104fab:	ff 75 f4             	pushl  -0xc(%ebp)
80104fae:	e8 91 d3 ff ff       	call   80102344 <dump_physmem>
80104fb3:	83 c4 10             	add    $0x10,%esp
}
80104fb6:	c9                   	leave  
80104fb7:	c3                   	ret    
    return -1;
80104fb8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fbd:	eb f7                	jmp    80104fb6 <sys_dump_physmem+0x67>
    return -1;
80104fbf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fc4:	eb f0                	jmp    80104fb6 <sys_dump_physmem+0x67>
    return -1;
80104fc6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104fcb:	eb e9                	jmp    80104fb6 <sys_dump_physmem+0x67>

80104fcd <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104fcd:	1e                   	push   %ds
  pushl %es
80104fce:	06                   	push   %es
  pushl %fs
80104fcf:	0f a0                	push   %fs
  pushl %gs
80104fd1:	0f a8                	push   %gs
  pushal
80104fd3:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104fd4:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104fd8:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104fda:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104fdc:	54                   	push   %esp
  call trap
80104fdd:	e8 e3 00 00 00       	call   801050c5 <trap>
  addl $4, %esp
80104fe2:	83 c4 04             	add    $0x4,%esp

80104fe5 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104fe5:	61                   	popa   
  popl %gs
80104fe6:	0f a9                	pop    %gs
  popl %fs
80104fe8:	0f a1                	pop    %fs
  popl %es
80104fea:	07                   	pop    %es
  popl %ds
80104feb:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104fec:	83 c4 08             	add    $0x8,%esp
  iret
80104fef:	cf                   	iret   

80104ff0 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104ff0:	55                   	push   %ebp
80104ff1:	89 e5                	mov    %esp,%ebp
80104ff3:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104ff6:	b8 00 00 00 00       	mov    $0x0,%eax
80104ffb:	eb 4a                	jmp    80105047 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104ffd:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80105004:	66 89 0c c5 e0 4c 13 	mov    %cx,-0x7fecb320(,%eax,8)
8010500b:	80 
8010500c:	66 c7 04 c5 e2 4c 13 	movw   $0x8,-0x7fecb31e(,%eax,8)
80105013:	80 08 00 
80105016:	c6 04 c5 e4 4c 13 80 	movb   $0x0,-0x7fecb31c(,%eax,8)
8010501d:	00 
8010501e:	0f b6 14 c5 e5 4c 13 	movzbl -0x7fecb31b(,%eax,8),%edx
80105025:	80 
80105026:	83 e2 f0             	and    $0xfffffff0,%edx
80105029:	83 ca 0e             	or     $0xe,%edx
8010502c:	83 e2 8f             	and    $0xffffff8f,%edx
8010502f:	83 ca 80             	or     $0xffffff80,%edx
80105032:	88 14 c5 e5 4c 13 80 	mov    %dl,-0x7fecb31b(,%eax,8)
80105039:	c1 e9 10             	shr    $0x10,%ecx
8010503c:	66 89 0c c5 e6 4c 13 	mov    %cx,-0x7fecb31a(,%eax,8)
80105043:	80 
  for(i = 0; i < 256; i++)
80105044:	83 c0 01             	add    $0x1,%eax
80105047:	3d ff 00 00 00       	cmp    $0xff,%eax
8010504c:	7e af                	jle    80104ffd <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
8010504e:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80105054:	66 89 15 e0 4e 13 80 	mov    %dx,0x80134ee0
8010505b:	66 c7 05 e2 4e 13 80 	movw   $0x8,0x80134ee2
80105062:	08 00 
80105064:	c6 05 e4 4e 13 80 00 	movb   $0x0,0x80134ee4
8010506b:	0f b6 05 e5 4e 13 80 	movzbl 0x80134ee5,%eax
80105072:	83 c8 0f             	or     $0xf,%eax
80105075:	83 e0 ef             	and    $0xffffffef,%eax
80105078:	83 c8 e0             	or     $0xffffffe0,%eax
8010507b:	a2 e5 4e 13 80       	mov    %al,0x80134ee5
80105080:	c1 ea 10             	shr    $0x10,%edx
80105083:	66 89 15 e6 4e 13 80 	mov    %dx,0x80134ee6

  initlock(&tickslock, "time");
8010508a:	83 ec 08             	sub    $0x8,%esp
8010508d:	68 3f 6f 10 80       	push   $0x80106f3f
80105092:	68 a0 4c 13 80       	push   $0x80134ca0
80105097:	e8 3e ec ff ff       	call   80103cda <initlock>
}
8010509c:	83 c4 10             	add    $0x10,%esp
8010509f:	c9                   	leave  
801050a0:	c3                   	ret    

801050a1 <idtinit>:

void
idtinit(void)
{
801050a1:	55                   	push   %ebp
801050a2:	89 e5                	mov    %esp,%ebp
801050a4:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
801050a7:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
801050ad:	b8 e0 4c 13 80       	mov    $0x80134ce0,%eax
801050b2:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
801050b6:	c1 e8 10             	shr    $0x10,%eax
801050b9:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
801050bd:	8d 45 fa             	lea    -0x6(%ebp),%eax
801050c0:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
801050c3:	c9                   	leave  
801050c4:	c3                   	ret    

801050c5 <trap>:

void
trap(struct trapframe *tf)
{
801050c5:	55                   	push   %ebp
801050c6:	89 e5                	mov    %esp,%ebp
801050c8:	57                   	push   %edi
801050c9:	56                   	push   %esi
801050ca:	53                   	push   %ebx
801050cb:	83 ec 1c             	sub    $0x1c,%esp
801050ce:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
801050d1:	8b 43 30             	mov    0x30(%ebx),%eax
801050d4:	83 f8 40             	cmp    $0x40,%eax
801050d7:	74 13                	je     801050ec <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
801050d9:	83 e8 20             	sub    $0x20,%eax
801050dc:	83 f8 1f             	cmp    $0x1f,%eax
801050df:	0f 87 3a 01 00 00    	ja     8010521f <trap+0x15a>
801050e5:	ff 24 85 e8 6f 10 80 	jmp    *-0x7fef9018(,%eax,4)
    if(myproc()->killed)
801050ec:	e8 ba e2 ff ff       	call   801033ab <myproc>
801050f1:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050f5:	75 1f                	jne    80105116 <trap+0x51>
    myproc()->tf = tf;
801050f7:	e8 af e2 ff ff       	call   801033ab <myproc>
801050fc:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
801050ff:	e8 cc f0 ff ff       	call   801041d0 <syscall>
    if(myproc()->killed)
80105104:	e8 a2 e2 ff ff       	call   801033ab <myproc>
80105109:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010510d:	74 7e                	je     8010518d <trap+0xc8>
      exit();
8010510f:	e8 0f e7 ff ff       	call   80103823 <exit>
80105114:	eb 77                	jmp    8010518d <trap+0xc8>
      exit();
80105116:	e8 08 e7 ff ff       	call   80103823 <exit>
8010511b:	eb da                	jmp    801050f7 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010511d:	e8 6e e2 ff ff       	call   80103390 <cpuid>
80105122:	85 c0                	test   %eax,%eax
80105124:	74 6f                	je     80105195 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105126:	e8 e4 d4 ff ff       	call   8010260f <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
8010512b:	e8 7b e2 ff ff       	call   801033ab <myproc>
80105130:	85 c0                	test   %eax,%eax
80105132:	74 1c                	je     80105150 <trap+0x8b>
80105134:	e8 72 e2 ff ff       	call   801033ab <myproc>
80105139:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010513d:	74 11                	je     80105150 <trap+0x8b>
8010513f:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105143:	83 e0 03             	and    $0x3,%eax
80105146:	66 83 f8 03          	cmp    $0x3,%ax
8010514a:	0f 84 62 01 00 00    	je     801052b2 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105150:	e8 56 e2 ff ff       	call   801033ab <myproc>
80105155:	85 c0                	test   %eax,%eax
80105157:	74 0f                	je     80105168 <trap+0xa3>
80105159:	e8 4d e2 ff ff       	call   801033ab <myproc>
8010515e:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105162:	0f 84 54 01 00 00    	je     801052bc <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105168:	e8 3e e2 ff ff       	call   801033ab <myproc>
8010516d:	85 c0                	test   %eax,%eax
8010516f:	74 1c                	je     8010518d <trap+0xc8>
80105171:	e8 35 e2 ff ff       	call   801033ab <myproc>
80105176:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010517a:	74 11                	je     8010518d <trap+0xc8>
8010517c:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105180:	83 e0 03             	and    $0x3,%eax
80105183:	66 83 f8 03          	cmp    $0x3,%ax
80105187:	0f 84 43 01 00 00    	je     801052d0 <trap+0x20b>
    exit();
}
8010518d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105190:	5b                   	pop    %ebx
80105191:	5e                   	pop    %esi
80105192:	5f                   	pop    %edi
80105193:	5d                   	pop    %ebp
80105194:	c3                   	ret    
      acquire(&tickslock);
80105195:	83 ec 0c             	sub    $0xc,%esp
80105198:	68 a0 4c 13 80       	push   $0x80134ca0
8010519d:	e8 74 ec ff ff       	call   80103e16 <acquire>
      ticks++;
801051a2:	83 05 e0 54 13 80 01 	addl   $0x1,0x801354e0
      wakeup(&ticks);
801051a9:	c7 04 24 e0 54 13 80 	movl   $0x801354e0,(%esp)
801051b0:	e8 cb e8 ff ff       	call   80103a80 <wakeup>
      release(&tickslock);
801051b5:	c7 04 24 a0 4c 13 80 	movl   $0x80134ca0,(%esp)
801051bc:	e8 ba ec ff ff       	call   80103e7b <release>
801051c1:	83 c4 10             	add    $0x10,%esp
801051c4:	e9 5d ff ff ff       	jmp    80105126 <trap+0x61>
    ideintr();
801051c9:	e8 a5 cb ff ff       	call   80101d73 <ideintr>
    lapiceoi();
801051ce:	e8 3c d4 ff ff       	call   8010260f <lapiceoi>
    break;
801051d3:	e9 53 ff ff ff       	jmp    8010512b <trap+0x66>
    kbdintr();
801051d8:	e8 76 d2 ff ff       	call   80102453 <kbdintr>
    lapiceoi();
801051dd:	e8 2d d4 ff ff       	call   8010260f <lapiceoi>
    break;
801051e2:	e9 44 ff ff ff       	jmp    8010512b <trap+0x66>
    uartintr();
801051e7:	e8 05 02 00 00       	call   801053f1 <uartintr>
    lapiceoi();
801051ec:	e8 1e d4 ff ff       	call   8010260f <lapiceoi>
    break;
801051f1:	e9 35 ff ff ff       	jmp    8010512b <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051f6:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
801051f9:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
801051fd:	e8 8e e1 ff ff       	call   80103390 <cpuid>
80105202:	57                   	push   %edi
80105203:	0f b7 f6             	movzwl %si,%esi
80105206:	56                   	push   %esi
80105207:	50                   	push   %eax
80105208:	68 4c 6f 10 80       	push   $0x80106f4c
8010520d:	e8 f9 b3 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80105212:	e8 f8 d3 ff ff       	call   8010260f <lapiceoi>
    break;
80105217:	83 c4 10             	add    $0x10,%esp
8010521a:	e9 0c ff ff ff       	jmp    8010512b <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
8010521f:	e8 87 e1 ff ff       	call   801033ab <myproc>
80105224:	85 c0                	test   %eax,%eax
80105226:	74 5f                	je     80105287 <trap+0x1c2>
80105228:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010522c:	74 59                	je     80105287 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010522e:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105231:	8b 43 38             	mov    0x38(%ebx),%eax
80105234:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105237:	e8 54 e1 ff ff       	call   80103390 <cpuid>
8010523c:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010523f:	8b 53 34             	mov    0x34(%ebx),%edx
80105242:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105245:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105248:	e8 5e e1 ff ff       	call   801033ab <myproc>
8010524d:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105250:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105253:	e8 53 e1 ff ff       	call   801033ab <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105258:	57                   	push   %edi
80105259:	ff 75 e4             	pushl  -0x1c(%ebp)
8010525c:	ff 75 e0             	pushl  -0x20(%ebp)
8010525f:	ff 75 dc             	pushl  -0x24(%ebp)
80105262:	56                   	push   %esi
80105263:	ff 75 d8             	pushl  -0x28(%ebp)
80105266:	ff 70 10             	pushl  0x10(%eax)
80105269:	68 a4 6f 10 80       	push   $0x80106fa4
8010526e:	e8 98 b3 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105273:	83 c4 20             	add    $0x20,%esp
80105276:	e8 30 e1 ff ff       	call   801033ab <myproc>
8010527b:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105282:	e9 a4 fe ff ff       	jmp    8010512b <trap+0x66>
80105287:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
8010528a:	8b 73 38             	mov    0x38(%ebx),%esi
8010528d:	e8 fe e0 ff ff       	call   80103390 <cpuid>
80105292:	83 ec 0c             	sub    $0xc,%esp
80105295:	57                   	push   %edi
80105296:	56                   	push   %esi
80105297:	50                   	push   %eax
80105298:	ff 73 30             	pushl  0x30(%ebx)
8010529b:	68 70 6f 10 80       	push   $0x80106f70
801052a0:	e8 66 b3 ff ff       	call   8010060b <cprintf>
      panic("trap");
801052a5:	83 c4 14             	add    $0x14,%esp
801052a8:	68 44 6f 10 80       	push   $0x80106f44
801052ad:	e8 96 b0 ff ff       	call   80100348 <panic>
    exit();
801052b2:	e8 6c e5 ff ff       	call   80103823 <exit>
801052b7:	e9 94 fe ff ff       	jmp    80105150 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801052bc:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801052c0:	0f 85 a2 fe ff ff    	jne    80105168 <trap+0xa3>
    yield();
801052c6:	e8 1e e6 ff ff       	call   801038e9 <yield>
801052cb:	e9 98 fe ff ff       	jmp    80105168 <trap+0xa3>
    exit();
801052d0:	e8 4e e5 ff ff       	call   80103823 <exit>
801052d5:	e9 b3 fe ff ff       	jmp    8010518d <trap+0xc8>

801052da <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801052da:	55                   	push   %ebp
801052db:	89 e5                	mov    %esp,%ebp
  if(!uart)
801052dd:	83 3d c4 a5 10 80 00 	cmpl   $0x0,0x8010a5c4
801052e4:	74 15                	je     801052fb <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801052e6:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052eb:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801052ec:	a8 01                	test   $0x1,%al
801052ee:	74 12                	je     80105302 <uartgetc+0x28>
801052f0:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052f5:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801052f6:	0f b6 c0             	movzbl %al,%eax
}
801052f9:	5d                   	pop    %ebp
801052fa:	c3                   	ret    
    return -1;
801052fb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105300:	eb f7                	jmp    801052f9 <uartgetc+0x1f>
    return -1;
80105302:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105307:	eb f0                	jmp    801052f9 <uartgetc+0x1f>

80105309 <uartputc>:
  if(!uart)
80105309:	83 3d c4 a5 10 80 00 	cmpl   $0x0,0x8010a5c4
80105310:	74 3b                	je     8010534d <uartputc+0x44>
{
80105312:	55                   	push   %ebp
80105313:	89 e5                	mov    %esp,%ebp
80105315:	53                   	push   %ebx
80105316:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105319:	bb 00 00 00 00       	mov    $0x0,%ebx
8010531e:	eb 10                	jmp    80105330 <uartputc+0x27>
    microdelay(10);
80105320:	83 ec 0c             	sub    $0xc,%esp
80105323:	6a 0a                	push   $0xa
80105325:	e8 04 d3 ff ff       	call   8010262e <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
8010532a:	83 c3 01             	add    $0x1,%ebx
8010532d:	83 c4 10             	add    $0x10,%esp
80105330:	83 fb 7f             	cmp    $0x7f,%ebx
80105333:	7f 0a                	jg     8010533f <uartputc+0x36>
80105335:	ba fd 03 00 00       	mov    $0x3fd,%edx
8010533a:	ec                   	in     (%dx),%al
8010533b:	a8 20                	test   $0x20,%al
8010533d:	74 e1                	je     80105320 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010533f:	8b 45 08             	mov    0x8(%ebp),%eax
80105342:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105347:	ee                   	out    %al,(%dx)
}
80105348:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010534b:	c9                   	leave  
8010534c:	c3                   	ret    
8010534d:	f3 c3                	repz ret 

8010534f <uartinit>:
{
8010534f:	55                   	push   %ebp
80105350:	89 e5                	mov    %esp,%ebp
80105352:	56                   	push   %esi
80105353:	53                   	push   %ebx
80105354:	b9 00 00 00 00       	mov    $0x0,%ecx
80105359:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010535e:	89 c8                	mov    %ecx,%eax
80105360:	ee                   	out    %al,(%dx)
80105361:	be fb 03 00 00       	mov    $0x3fb,%esi
80105366:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
8010536b:	89 f2                	mov    %esi,%edx
8010536d:	ee                   	out    %al,(%dx)
8010536e:	b8 0c 00 00 00       	mov    $0xc,%eax
80105373:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105378:	ee                   	out    %al,(%dx)
80105379:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010537e:	89 c8                	mov    %ecx,%eax
80105380:	89 da                	mov    %ebx,%edx
80105382:	ee                   	out    %al,(%dx)
80105383:	b8 03 00 00 00       	mov    $0x3,%eax
80105388:	89 f2                	mov    %esi,%edx
8010538a:	ee                   	out    %al,(%dx)
8010538b:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105390:	89 c8                	mov    %ecx,%eax
80105392:	ee                   	out    %al,(%dx)
80105393:	b8 01 00 00 00       	mov    $0x1,%eax
80105398:	89 da                	mov    %ebx,%edx
8010539a:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010539b:	ba fd 03 00 00       	mov    $0x3fd,%edx
801053a0:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801053a1:	3c ff                	cmp    $0xff,%al
801053a3:	74 45                	je     801053ea <uartinit+0x9b>
  uart = 1;
801053a5:	c7 05 c4 a5 10 80 01 	movl   $0x1,0x8010a5c4
801053ac:	00 00 00 
801053af:	ba fa 03 00 00       	mov    $0x3fa,%edx
801053b4:	ec                   	in     (%dx),%al
801053b5:	ba f8 03 00 00       	mov    $0x3f8,%edx
801053ba:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801053bb:	83 ec 08             	sub    $0x8,%esp
801053be:	6a 00                	push   $0x0
801053c0:	6a 04                	push   $0x4
801053c2:	e8 b7 cb ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801053c7:	83 c4 10             	add    $0x10,%esp
801053ca:	bb 68 70 10 80       	mov    $0x80107068,%ebx
801053cf:	eb 12                	jmp    801053e3 <uartinit+0x94>
    uartputc(*p);
801053d1:	83 ec 0c             	sub    $0xc,%esp
801053d4:	0f be c0             	movsbl %al,%eax
801053d7:	50                   	push   %eax
801053d8:	e8 2c ff ff ff       	call   80105309 <uartputc>
  for(p="xv6...\n"; *p; p++)
801053dd:	83 c3 01             	add    $0x1,%ebx
801053e0:	83 c4 10             	add    $0x10,%esp
801053e3:	0f b6 03             	movzbl (%ebx),%eax
801053e6:	84 c0                	test   %al,%al
801053e8:	75 e7                	jne    801053d1 <uartinit+0x82>
}
801053ea:	8d 65 f8             	lea    -0x8(%ebp),%esp
801053ed:	5b                   	pop    %ebx
801053ee:	5e                   	pop    %esi
801053ef:	5d                   	pop    %ebp
801053f0:	c3                   	ret    

801053f1 <uartintr>:

void
uartintr(void)
{
801053f1:	55                   	push   %ebp
801053f2:	89 e5                	mov    %esp,%ebp
801053f4:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801053f7:	68 da 52 10 80       	push   $0x801052da
801053fc:	e8 3d b3 ff ff       	call   8010073e <consoleintr>
}
80105401:	83 c4 10             	add    $0x10,%esp
80105404:	c9                   	leave  
80105405:	c3                   	ret    

80105406 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105406:	6a 00                	push   $0x0
  pushl $0
80105408:	6a 00                	push   $0x0
  jmp alltraps
8010540a:	e9 be fb ff ff       	jmp    80104fcd <alltraps>

8010540f <vector1>:
.globl vector1
vector1:
  pushl $0
8010540f:	6a 00                	push   $0x0
  pushl $1
80105411:	6a 01                	push   $0x1
  jmp alltraps
80105413:	e9 b5 fb ff ff       	jmp    80104fcd <alltraps>

80105418 <vector2>:
.globl vector2
vector2:
  pushl $0
80105418:	6a 00                	push   $0x0
  pushl $2
8010541a:	6a 02                	push   $0x2
  jmp alltraps
8010541c:	e9 ac fb ff ff       	jmp    80104fcd <alltraps>

80105421 <vector3>:
.globl vector3
vector3:
  pushl $0
80105421:	6a 00                	push   $0x0
  pushl $3
80105423:	6a 03                	push   $0x3
  jmp alltraps
80105425:	e9 a3 fb ff ff       	jmp    80104fcd <alltraps>

8010542a <vector4>:
.globl vector4
vector4:
  pushl $0
8010542a:	6a 00                	push   $0x0
  pushl $4
8010542c:	6a 04                	push   $0x4
  jmp alltraps
8010542e:	e9 9a fb ff ff       	jmp    80104fcd <alltraps>

80105433 <vector5>:
.globl vector5
vector5:
  pushl $0
80105433:	6a 00                	push   $0x0
  pushl $5
80105435:	6a 05                	push   $0x5
  jmp alltraps
80105437:	e9 91 fb ff ff       	jmp    80104fcd <alltraps>

8010543c <vector6>:
.globl vector6
vector6:
  pushl $0
8010543c:	6a 00                	push   $0x0
  pushl $6
8010543e:	6a 06                	push   $0x6
  jmp alltraps
80105440:	e9 88 fb ff ff       	jmp    80104fcd <alltraps>

80105445 <vector7>:
.globl vector7
vector7:
  pushl $0
80105445:	6a 00                	push   $0x0
  pushl $7
80105447:	6a 07                	push   $0x7
  jmp alltraps
80105449:	e9 7f fb ff ff       	jmp    80104fcd <alltraps>

8010544e <vector8>:
.globl vector8
vector8:
  pushl $8
8010544e:	6a 08                	push   $0x8
  jmp alltraps
80105450:	e9 78 fb ff ff       	jmp    80104fcd <alltraps>

80105455 <vector9>:
.globl vector9
vector9:
  pushl $0
80105455:	6a 00                	push   $0x0
  pushl $9
80105457:	6a 09                	push   $0x9
  jmp alltraps
80105459:	e9 6f fb ff ff       	jmp    80104fcd <alltraps>

8010545e <vector10>:
.globl vector10
vector10:
  pushl $10
8010545e:	6a 0a                	push   $0xa
  jmp alltraps
80105460:	e9 68 fb ff ff       	jmp    80104fcd <alltraps>

80105465 <vector11>:
.globl vector11
vector11:
  pushl $11
80105465:	6a 0b                	push   $0xb
  jmp alltraps
80105467:	e9 61 fb ff ff       	jmp    80104fcd <alltraps>

8010546c <vector12>:
.globl vector12
vector12:
  pushl $12
8010546c:	6a 0c                	push   $0xc
  jmp alltraps
8010546e:	e9 5a fb ff ff       	jmp    80104fcd <alltraps>

80105473 <vector13>:
.globl vector13
vector13:
  pushl $13
80105473:	6a 0d                	push   $0xd
  jmp alltraps
80105475:	e9 53 fb ff ff       	jmp    80104fcd <alltraps>

8010547a <vector14>:
.globl vector14
vector14:
  pushl $14
8010547a:	6a 0e                	push   $0xe
  jmp alltraps
8010547c:	e9 4c fb ff ff       	jmp    80104fcd <alltraps>

80105481 <vector15>:
.globl vector15
vector15:
  pushl $0
80105481:	6a 00                	push   $0x0
  pushl $15
80105483:	6a 0f                	push   $0xf
  jmp alltraps
80105485:	e9 43 fb ff ff       	jmp    80104fcd <alltraps>

8010548a <vector16>:
.globl vector16
vector16:
  pushl $0
8010548a:	6a 00                	push   $0x0
  pushl $16
8010548c:	6a 10                	push   $0x10
  jmp alltraps
8010548e:	e9 3a fb ff ff       	jmp    80104fcd <alltraps>

80105493 <vector17>:
.globl vector17
vector17:
  pushl $17
80105493:	6a 11                	push   $0x11
  jmp alltraps
80105495:	e9 33 fb ff ff       	jmp    80104fcd <alltraps>

8010549a <vector18>:
.globl vector18
vector18:
  pushl $0
8010549a:	6a 00                	push   $0x0
  pushl $18
8010549c:	6a 12                	push   $0x12
  jmp alltraps
8010549e:	e9 2a fb ff ff       	jmp    80104fcd <alltraps>

801054a3 <vector19>:
.globl vector19
vector19:
  pushl $0
801054a3:	6a 00                	push   $0x0
  pushl $19
801054a5:	6a 13                	push   $0x13
  jmp alltraps
801054a7:	e9 21 fb ff ff       	jmp    80104fcd <alltraps>

801054ac <vector20>:
.globl vector20
vector20:
  pushl $0
801054ac:	6a 00                	push   $0x0
  pushl $20
801054ae:	6a 14                	push   $0x14
  jmp alltraps
801054b0:	e9 18 fb ff ff       	jmp    80104fcd <alltraps>

801054b5 <vector21>:
.globl vector21
vector21:
  pushl $0
801054b5:	6a 00                	push   $0x0
  pushl $21
801054b7:	6a 15                	push   $0x15
  jmp alltraps
801054b9:	e9 0f fb ff ff       	jmp    80104fcd <alltraps>

801054be <vector22>:
.globl vector22
vector22:
  pushl $0
801054be:	6a 00                	push   $0x0
  pushl $22
801054c0:	6a 16                	push   $0x16
  jmp alltraps
801054c2:	e9 06 fb ff ff       	jmp    80104fcd <alltraps>

801054c7 <vector23>:
.globl vector23
vector23:
  pushl $0
801054c7:	6a 00                	push   $0x0
  pushl $23
801054c9:	6a 17                	push   $0x17
  jmp alltraps
801054cb:	e9 fd fa ff ff       	jmp    80104fcd <alltraps>

801054d0 <vector24>:
.globl vector24
vector24:
  pushl $0
801054d0:	6a 00                	push   $0x0
  pushl $24
801054d2:	6a 18                	push   $0x18
  jmp alltraps
801054d4:	e9 f4 fa ff ff       	jmp    80104fcd <alltraps>

801054d9 <vector25>:
.globl vector25
vector25:
  pushl $0
801054d9:	6a 00                	push   $0x0
  pushl $25
801054db:	6a 19                	push   $0x19
  jmp alltraps
801054dd:	e9 eb fa ff ff       	jmp    80104fcd <alltraps>

801054e2 <vector26>:
.globl vector26
vector26:
  pushl $0
801054e2:	6a 00                	push   $0x0
  pushl $26
801054e4:	6a 1a                	push   $0x1a
  jmp alltraps
801054e6:	e9 e2 fa ff ff       	jmp    80104fcd <alltraps>

801054eb <vector27>:
.globl vector27
vector27:
  pushl $0
801054eb:	6a 00                	push   $0x0
  pushl $27
801054ed:	6a 1b                	push   $0x1b
  jmp alltraps
801054ef:	e9 d9 fa ff ff       	jmp    80104fcd <alltraps>

801054f4 <vector28>:
.globl vector28
vector28:
  pushl $0
801054f4:	6a 00                	push   $0x0
  pushl $28
801054f6:	6a 1c                	push   $0x1c
  jmp alltraps
801054f8:	e9 d0 fa ff ff       	jmp    80104fcd <alltraps>

801054fd <vector29>:
.globl vector29
vector29:
  pushl $0
801054fd:	6a 00                	push   $0x0
  pushl $29
801054ff:	6a 1d                	push   $0x1d
  jmp alltraps
80105501:	e9 c7 fa ff ff       	jmp    80104fcd <alltraps>

80105506 <vector30>:
.globl vector30
vector30:
  pushl $0
80105506:	6a 00                	push   $0x0
  pushl $30
80105508:	6a 1e                	push   $0x1e
  jmp alltraps
8010550a:	e9 be fa ff ff       	jmp    80104fcd <alltraps>

8010550f <vector31>:
.globl vector31
vector31:
  pushl $0
8010550f:	6a 00                	push   $0x0
  pushl $31
80105511:	6a 1f                	push   $0x1f
  jmp alltraps
80105513:	e9 b5 fa ff ff       	jmp    80104fcd <alltraps>

80105518 <vector32>:
.globl vector32
vector32:
  pushl $0
80105518:	6a 00                	push   $0x0
  pushl $32
8010551a:	6a 20                	push   $0x20
  jmp alltraps
8010551c:	e9 ac fa ff ff       	jmp    80104fcd <alltraps>

80105521 <vector33>:
.globl vector33
vector33:
  pushl $0
80105521:	6a 00                	push   $0x0
  pushl $33
80105523:	6a 21                	push   $0x21
  jmp alltraps
80105525:	e9 a3 fa ff ff       	jmp    80104fcd <alltraps>

8010552a <vector34>:
.globl vector34
vector34:
  pushl $0
8010552a:	6a 00                	push   $0x0
  pushl $34
8010552c:	6a 22                	push   $0x22
  jmp alltraps
8010552e:	e9 9a fa ff ff       	jmp    80104fcd <alltraps>

80105533 <vector35>:
.globl vector35
vector35:
  pushl $0
80105533:	6a 00                	push   $0x0
  pushl $35
80105535:	6a 23                	push   $0x23
  jmp alltraps
80105537:	e9 91 fa ff ff       	jmp    80104fcd <alltraps>

8010553c <vector36>:
.globl vector36
vector36:
  pushl $0
8010553c:	6a 00                	push   $0x0
  pushl $36
8010553e:	6a 24                	push   $0x24
  jmp alltraps
80105540:	e9 88 fa ff ff       	jmp    80104fcd <alltraps>

80105545 <vector37>:
.globl vector37
vector37:
  pushl $0
80105545:	6a 00                	push   $0x0
  pushl $37
80105547:	6a 25                	push   $0x25
  jmp alltraps
80105549:	e9 7f fa ff ff       	jmp    80104fcd <alltraps>

8010554e <vector38>:
.globl vector38
vector38:
  pushl $0
8010554e:	6a 00                	push   $0x0
  pushl $38
80105550:	6a 26                	push   $0x26
  jmp alltraps
80105552:	e9 76 fa ff ff       	jmp    80104fcd <alltraps>

80105557 <vector39>:
.globl vector39
vector39:
  pushl $0
80105557:	6a 00                	push   $0x0
  pushl $39
80105559:	6a 27                	push   $0x27
  jmp alltraps
8010555b:	e9 6d fa ff ff       	jmp    80104fcd <alltraps>

80105560 <vector40>:
.globl vector40
vector40:
  pushl $0
80105560:	6a 00                	push   $0x0
  pushl $40
80105562:	6a 28                	push   $0x28
  jmp alltraps
80105564:	e9 64 fa ff ff       	jmp    80104fcd <alltraps>

80105569 <vector41>:
.globl vector41
vector41:
  pushl $0
80105569:	6a 00                	push   $0x0
  pushl $41
8010556b:	6a 29                	push   $0x29
  jmp alltraps
8010556d:	e9 5b fa ff ff       	jmp    80104fcd <alltraps>

80105572 <vector42>:
.globl vector42
vector42:
  pushl $0
80105572:	6a 00                	push   $0x0
  pushl $42
80105574:	6a 2a                	push   $0x2a
  jmp alltraps
80105576:	e9 52 fa ff ff       	jmp    80104fcd <alltraps>

8010557b <vector43>:
.globl vector43
vector43:
  pushl $0
8010557b:	6a 00                	push   $0x0
  pushl $43
8010557d:	6a 2b                	push   $0x2b
  jmp alltraps
8010557f:	e9 49 fa ff ff       	jmp    80104fcd <alltraps>

80105584 <vector44>:
.globl vector44
vector44:
  pushl $0
80105584:	6a 00                	push   $0x0
  pushl $44
80105586:	6a 2c                	push   $0x2c
  jmp alltraps
80105588:	e9 40 fa ff ff       	jmp    80104fcd <alltraps>

8010558d <vector45>:
.globl vector45
vector45:
  pushl $0
8010558d:	6a 00                	push   $0x0
  pushl $45
8010558f:	6a 2d                	push   $0x2d
  jmp alltraps
80105591:	e9 37 fa ff ff       	jmp    80104fcd <alltraps>

80105596 <vector46>:
.globl vector46
vector46:
  pushl $0
80105596:	6a 00                	push   $0x0
  pushl $46
80105598:	6a 2e                	push   $0x2e
  jmp alltraps
8010559a:	e9 2e fa ff ff       	jmp    80104fcd <alltraps>

8010559f <vector47>:
.globl vector47
vector47:
  pushl $0
8010559f:	6a 00                	push   $0x0
  pushl $47
801055a1:	6a 2f                	push   $0x2f
  jmp alltraps
801055a3:	e9 25 fa ff ff       	jmp    80104fcd <alltraps>

801055a8 <vector48>:
.globl vector48
vector48:
  pushl $0
801055a8:	6a 00                	push   $0x0
  pushl $48
801055aa:	6a 30                	push   $0x30
  jmp alltraps
801055ac:	e9 1c fa ff ff       	jmp    80104fcd <alltraps>

801055b1 <vector49>:
.globl vector49
vector49:
  pushl $0
801055b1:	6a 00                	push   $0x0
  pushl $49
801055b3:	6a 31                	push   $0x31
  jmp alltraps
801055b5:	e9 13 fa ff ff       	jmp    80104fcd <alltraps>

801055ba <vector50>:
.globl vector50
vector50:
  pushl $0
801055ba:	6a 00                	push   $0x0
  pushl $50
801055bc:	6a 32                	push   $0x32
  jmp alltraps
801055be:	e9 0a fa ff ff       	jmp    80104fcd <alltraps>

801055c3 <vector51>:
.globl vector51
vector51:
  pushl $0
801055c3:	6a 00                	push   $0x0
  pushl $51
801055c5:	6a 33                	push   $0x33
  jmp alltraps
801055c7:	e9 01 fa ff ff       	jmp    80104fcd <alltraps>

801055cc <vector52>:
.globl vector52
vector52:
  pushl $0
801055cc:	6a 00                	push   $0x0
  pushl $52
801055ce:	6a 34                	push   $0x34
  jmp alltraps
801055d0:	e9 f8 f9 ff ff       	jmp    80104fcd <alltraps>

801055d5 <vector53>:
.globl vector53
vector53:
  pushl $0
801055d5:	6a 00                	push   $0x0
  pushl $53
801055d7:	6a 35                	push   $0x35
  jmp alltraps
801055d9:	e9 ef f9 ff ff       	jmp    80104fcd <alltraps>

801055de <vector54>:
.globl vector54
vector54:
  pushl $0
801055de:	6a 00                	push   $0x0
  pushl $54
801055e0:	6a 36                	push   $0x36
  jmp alltraps
801055e2:	e9 e6 f9 ff ff       	jmp    80104fcd <alltraps>

801055e7 <vector55>:
.globl vector55
vector55:
  pushl $0
801055e7:	6a 00                	push   $0x0
  pushl $55
801055e9:	6a 37                	push   $0x37
  jmp alltraps
801055eb:	e9 dd f9 ff ff       	jmp    80104fcd <alltraps>

801055f0 <vector56>:
.globl vector56
vector56:
  pushl $0
801055f0:	6a 00                	push   $0x0
  pushl $56
801055f2:	6a 38                	push   $0x38
  jmp alltraps
801055f4:	e9 d4 f9 ff ff       	jmp    80104fcd <alltraps>

801055f9 <vector57>:
.globl vector57
vector57:
  pushl $0
801055f9:	6a 00                	push   $0x0
  pushl $57
801055fb:	6a 39                	push   $0x39
  jmp alltraps
801055fd:	e9 cb f9 ff ff       	jmp    80104fcd <alltraps>

80105602 <vector58>:
.globl vector58
vector58:
  pushl $0
80105602:	6a 00                	push   $0x0
  pushl $58
80105604:	6a 3a                	push   $0x3a
  jmp alltraps
80105606:	e9 c2 f9 ff ff       	jmp    80104fcd <alltraps>

8010560b <vector59>:
.globl vector59
vector59:
  pushl $0
8010560b:	6a 00                	push   $0x0
  pushl $59
8010560d:	6a 3b                	push   $0x3b
  jmp alltraps
8010560f:	e9 b9 f9 ff ff       	jmp    80104fcd <alltraps>

80105614 <vector60>:
.globl vector60
vector60:
  pushl $0
80105614:	6a 00                	push   $0x0
  pushl $60
80105616:	6a 3c                	push   $0x3c
  jmp alltraps
80105618:	e9 b0 f9 ff ff       	jmp    80104fcd <alltraps>

8010561d <vector61>:
.globl vector61
vector61:
  pushl $0
8010561d:	6a 00                	push   $0x0
  pushl $61
8010561f:	6a 3d                	push   $0x3d
  jmp alltraps
80105621:	e9 a7 f9 ff ff       	jmp    80104fcd <alltraps>

80105626 <vector62>:
.globl vector62
vector62:
  pushl $0
80105626:	6a 00                	push   $0x0
  pushl $62
80105628:	6a 3e                	push   $0x3e
  jmp alltraps
8010562a:	e9 9e f9 ff ff       	jmp    80104fcd <alltraps>

8010562f <vector63>:
.globl vector63
vector63:
  pushl $0
8010562f:	6a 00                	push   $0x0
  pushl $63
80105631:	6a 3f                	push   $0x3f
  jmp alltraps
80105633:	e9 95 f9 ff ff       	jmp    80104fcd <alltraps>

80105638 <vector64>:
.globl vector64
vector64:
  pushl $0
80105638:	6a 00                	push   $0x0
  pushl $64
8010563a:	6a 40                	push   $0x40
  jmp alltraps
8010563c:	e9 8c f9 ff ff       	jmp    80104fcd <alltraps>

80105641 <vector65>:
.globl vector65
vector65:
  pushl $0
80105641:	6a 00                	push   $0x0
  pushl $65
80105643:	6a 41                	push   $0x41
  jmp alltraps
80105645:	e9 83 f9 ff ff       	jmp    80104fcd <alltraps>

8010564a <vector66>:
.globl vector66
vector66:
  pushl $0
8010564a:	6a 00                	push   $0x0
  pushl $66
8010564c:	6a 42                	push   $0x42
  jmp alltraps
8010564e:	e9 7a f9 ff ff       	jmp    80104fcd <alltraps>

80105653 <vector67>:
.globl vector67
vector67:
  pushl $0
80105653:	6a 00                	push   $0x0
  pushl $67
80105655:	6a 43                	push   $0x43
  jmp alltraps
80105657:	e9 71 f9 ff ff       	jmp    80104fcd <alltraps>

8010565c <vector68>:
.globl vector68
vector68:
  pushl $0
8010565c:	6a 00                	push   $0x0
  pushl $68
8010565e:	6a 44                	push   $0x44
  jmp alltraps
80105660:	e9 68 f9 ff ff       	jmp    80104fcd <alltraps>

80105665 <vector69>:
.globl vector69
vector69:
  pushl $0
80105665:	6a 00                	push   $0x0
  pushl $69
80105667:	6a 45                	push   $0x45
  jmp alltraps
80105669:	e9 5f f9 ff ff       	jmp    80104fcd <alltraps>

8010566e <vector70>:
.globl vector70
vector70:
  pushl $0
8010566e:	6a 00                	push   $0x0
  pushl $70
80105670:	6a 46                	push   $0x46
  jmp alltraps
80105672:	e9 56 f9 ff ff       	jmp    80104fcd <alltraps>

80105677 <vector71>:
.globl vector71
vector71:
  pushl $0
80105677:	6a 00                	push   $0x0
  pushl $71
80105679:	6a 47                	push   $0x47
  jmp alltraps
8010567b:	e9 4d f9 ff ff       	jmp    80104fcd <alltraps>

80105680 <vector72>:
.globl vector72
vector72:
  pushl $0
80105680:	6a 00                	push   $0x0
  pushl $72
80105682:	6a 48                	push   $0x48
  jmp alltraps
80105684:	e9 44 f9 ff ff       	jmp    80104fcd <alltraps>

80105689 <vector73>:
.globl vector73
vector73:
  pushl $0
80105689:	6a 00                	push   $0x0
  pushl $73
8010568b:	6a 49                	push   $0x49
  jmp alltraps
8010568d:	e9 3b f9 ff ff       	jmp    80104fcd <alltraps>

80105692 <vector74>:
.globl vector74
vector74:
  pushl $0
80105692:	6a 00                	push   $0x0
  pushl $74
80105694:	6a 4a                	push   $0x4a
  jmp alltraps
80105696:	e9 32 f9 ff ff       	jmp    80104fcd <alltraps>

8010569b <vector75>:
.globl vector75
vector75:
  pushl $0
8010569b:	6a 00                	push   $0x0
  pushl $75
8010569d:	6a 4b                	push   $0x4b
  jmp alltraps
8010569f:	e9 29 f9 ff ff       	jmp    80104fcd <alltraps>

801056a4 <vector76>:
.globl vector76
vector76:
  pushl $0
801056a4:	6a 00                	push   $0x0
  pushl $76
801056a6:	6a 4c                	push   $0x4c
  jmp alltraps
801056a8:	e9 20 f9 ff ff       	jmp    80104fcd <alltraps>

801056ad <vector77>:
.globl vector77
vector77:
  pushl $0
801056ad:	6a 00                	push   $0x0
  pushl $77
801056af:	6a 4d                	push   $0x4d
  jmp alltraps
801056b1:	e9 17 f9 ff ff       	jmp    80104fcd <alltraps>

801056b6 <vector78>:
.globl vector78
vector78:
  pushl $0
801056b6:	6a 00                	push   $0x0
  pushl $78
801056b8:	6a 4e                	push   $0x4e
  jmp alltraps
801056ba:	e9 0e f9 ff ff       	jmp    80104fcd <alltraps>

801056bf <vector79>:
.globl vector79
vector79:
  pushl $0
801056bf:	6a 00                	push   $0x0
  pushl $79
801056c1:	6a 4f                	push   $0x4f
  jmp alltraps
801056c3:	e9 05 f9 ff ff       	jmp    80104fcd <alltraps>

801056c8 <vector80>:
.globl vector80
vector80:
  pushl $0
801056c8:	6a 00                	push   $0x0
  pushl $80
801056ca:	6a 50                	push   $0x50
  jmp alltraps
801056cc:	e9 fc f8 ff ff       	jmp    80104fcd <alltraps>

801056d1 <vector81>:
.globl vector81
vector81:
  pushl $0
801056d1:	6a 00                	push   $0x0
  pushl $81
801056d3:	6a 51                	push   $0x51
  jmp alltraps
801056d5:	e9 f3 f8 ff ff       	jmp    80104fcd <alltraps>

801056da <vector82>:
.globl vector82
vector82:
  pushl $0
801056da:	6a 00                	push   $0x0
  pushl $82
801056dc:	6a 52                	push   $0x52
  jmp alltraps
801056de:	e9 ea f8 ff ff       	jmp    80104fcd <alltraps>

801056e3 <vector83>:
.globl vector83
vector83:
  pushl $0
801056e3:	6a 00                	push   $0x0
  pushl $83
801056e5:	6a 53                	push   $0x53
  jmp alltraps
801056e7:	e9 e1 f8 ff ff       	jmp    80104fcd <alltraps>

801056ec <vector84>:
.globl vector84
vector84:
  pushl $0
801056ec:	6a 00                	push   $0x0
  pushl $84
801056ee:	6a 54                	push   $0x54
  jmp alltraps
801056f0:	e9 d8 f8 ff ff       	jmp    80104fcd <alltraps>

801056f5 <vector85>:
.globl vector85
vector85:
  pushl $0
801056f5:	6a 00                	push   $0x0
  pushl $85
801056f7:	6a 55                	push   $0x55
  jmp alltraps
801056f9:	e9 cf f8 ff ff       	jmp    80104fcd <alltraps>

801056fe <vector86>:
.globl vector86
vector86:
  pushl $0
801056fe:	6a 00                	push   $0x0
  pushl $86
80105700:	6a 56                	push   $0x56
  jmp alltraps
80105702:	e9 c6 f8 ff ff       	jmp    80104fcd <alltraps>

80105707 <vector87>:
.globl vector87
vector87:
  pushl $0
80105707:	6a 00                	push   $0x0
  pushl $87
80105709:	6a 57                	push   $0x57
  jmp alltraps
8010570b:	e9 bd f8 ff ff       	jmp    80104fcd <alltraps>

80105710 <vector88>:
.globl vector88
vector88:
  pushl $0
80105710:	6a 00                	push   $0x0
  pushl $88
80105712:	6a 58                	push   $0x58
  jmp alltraps
80105714:	e9 b4 f8 ff ff       	jmp    80104fcd <alltraps>

80105719 <vector89>:
.globl vector89
vector89:
  pushl $0
80105719:	6a 00                	push   $0x0
  pushl $89
8010571b:	6a 59                	push   $0x59
  jmp alltraps
8010571d:	e9 ab f8 ff ff       	jmp    80104fcd <alltraps>

80105722 <vector90>:
.globl vector90
vector90:
  pushl $0
80105722:	6a 00                	push   $0x0
  pushl $90
80105724:	6a 5a                	push   $0x5a
  jmp alltraps
80105726:	e9 a2 f8 ff ff       	jmp    80104fcd <alltraps>

8010572b <vector91>:
.globl vector91
vector91:
  pushl $0
8010572b:	6a 00                	push   $0x0
  pushl $91
8010572d:	6a 5b                	push   $0x5b
  jmp alltraps
8010572f:	e9 99 f8 ff ff       	jmp    80104fcd <alltraps>

80105734 <vector92>:
.globl vector92
vector92:
  pushl $0
80105734:	6a 00                	push   $0x0
  pushl $92
80105736:	6a 5c                	push   $0x5c
  jmp alltraps
80105738:	e9 90 f8 ff ff       	jmp    80104fcd <alltraps>

8010573d <vector93>:
.globl vector93
vector93:
  pushl $0
8010573d:	6a 00                	push   $0x0
  pushl $93
8010573f:	6a 5d                	push   $0x5d
  jmp alltraps
80105741:	e9 87 f8 ff ff       	jmp    80104fcd <alltraps>

80105746 <vector94>:
.globl vector94
vector94:
  pushl $0
80105746:	6a 00                	push   $0x0
  pushl $94
80105748:	6a 5e                	push   $0x5e
  jmp alltraps
8010574a:	e9 7e f8 ff ff       	jmp    80104fcd <alltraps>

8010574f <vector95>:
.globl vector95
vector95:
  pushl $0
8010574f:	6a 00                	push   $0x0
  pushl $95
80105751:	6a 5f                	push   $0x5f
  jmp alltraps
80105753:	e9 75 f8 ff ff       	jmp    80104fcd <alltraps>

80105758 <vector96>:
.globl vector96
vector96:
  pushl $0
80105758:	6a 00                	push   $0x0
  pushl $96
8010575a:	6a 60                	push   $0x60
  jmp alltraps
8010575c:	e9 6c f8 ff ff       	jmp    80104fcd <alltraps>

80105761 <vector97>:
.globl vector97
vector97:
  pushl $0
80105761:	6a 00                	push   $0x0
  pushl $97
80105763:	6a 61                	push   $0x61
  jmp alltraps
80105765:	e9 63 f8 ff ff       	jmp    80104fcd <alltraps>

8010576a <vector98>:
.globl vector98
vector98:
  pushl $0
8010576a:	6a 00                	push   $0x0
  pushl $98
8010576c:	6a 62                	push   $0x62
  jmp alltraps
8010576e:	e9 5a f8 ff ff       	jmp    80104fcd <alltraps>

80105773 <vector99>:
.globl vector99
vector99:
  pushl $0
80105773:	6a 00                	push   $0x0
  pushl $99
80105775:	6a 63                	push   $0x63
  jmp alltraps
80105777:	e9 51 f8 ff ff       	jmp    80104fcd <alltraps>

8010577c <vector100>:
.globl vector100
vector100:
  pushl $0
8010577c:	6a 00                	push   $0x0
  pushl $100
8010577e:	6a 64                	push   $0x64
  jmp alltraps
80105780:	e9 48 f8 ff ff       	jmp    80104fcd <alltraps>

80105785 <vector101>:
.globl vector101
vector101:
  pushl $0
80105785:	6a 00                	push   $0x0
  pushl $101
80105787:	6a 65                	push   $0x65
  jmp alltraps
80105789:	e9 3f f8 ff ff       	jmp    80104fcd <alltraps>

8010578e <vector102>:
.globl vector102
vector102:
  pushl $0
8010578e:	6a 00                	push   $0x0
  pushl $102
80105790:	6a 66                	push   $0x66
  jmp alltraps
80105792:	e9 36 f8 ff ff       	jmp    80104fcd <alltraps>

80105797 <vector103>:
.globl vector103
vector103:
  pushl $0
80105797:	6a 00                	push   $0x0
  pushl $103
80105799:	6a 67                	push   $0x67
  jmp alltraps
8010579b:	e9 2d f8 ff ff       	jmp    80104fcd <alltraps>

801057a0 <vector104>:
.globl vector104
vector104:
  pushl $0
801057a0:	6a 00                	push   $0x0
  pushl $104
801057a2:	6a 68                	push   $0x68
  jmp alltraps
801057a4:	e9 24 f8 ff ff       	jmp    80104fcd <alltraps>

801057a9 <vector105>:
.globl vector105
vector105:
  pushl $0
801057a9:	6a 00                	push   $0x0
  pushl $105
801057ab:	6a 69                	push   $0x69
  jmp alltraps
801057ad:	e9 1b f8 ff ff       	jmp    80104fcd <alltraps>

801057b2 <vector106>:
.globl vector106
vector106:
  pushl $0
801057b2:	6a 00                	push   $0x0
  pushl $106
801057b4:	6a 6a                	push   $0x6a
  jmp alltraps
801057b6:	e9 12 f8 ff ff       	jmp    80104fcd <alltraps>

801057bb <vector107>:
.globl vector107
vector107:
  pushl $0
801057bb:	6a 00                	push   $0x0
  pushl $107
801057bd:	6a 6b                	push   $0x6b
  jmp alltraps
801057bf:	e9 09 f8 ff ff       	jmp    80104fcd <alltraps>

801057c4 <vector108>:
.globl vector108
vector108:
  pushl $0
801057c4:	6a 00                	push   $0x0
  pushl $108
801057c6:	6a 6c                	push   $0x6c
  jmp alltraps
801057c8:	e9 00 f8 ff ff       	jmp    80104fcd <alltraps>

801057cd <vector109>:
.globl vector109
vector109:
  pushl $0
801057cd:	6a 00                	push   $0x0
  pushl $109
801057cf:	6a 6d                	push   $0x6d
  jmp alltraps
801057d1:	e9 f7 f7 ff ff       	jmp    80104fcd <alltraps>

801057d6 <vector110>:
.globl vector110
vector110:
  pushl $0
801057d6:	6a 00                	push   $0x0
  pushl $110
801057d8:	6a 6e                	push   $0x6e
  jmp alltraps
801057da:	e9 ee f7 ff ff       	jmp    80104fcd <alltraps>

801057df <vector111>:
.globl vector111
vector111:
  pushl $0
801057df:	6a 00                	push   $0x0
  pushl $111
801057e1:	6a 6f                	push   $0x6f
  jmp alltraps
801057e3:	e9 e5 f7 ff ff       	jmp    80104fcd <alltraps>

801057e8 <vector112>:
.globl vector112
vector112:
  pushl $0
801057e8:	6a 00                	push   $0x0
  pushl $112
801057ea:	6a 70                	push   $0x70
  jmp alltraps
801057ec:	e9 dc f7 ff ff       	jmp    80104fcd <alltraps>

801057f1 <vector113>:
.globl vector113
vector113:
  pushl $0
801057f1:	6a 00                	push   $0x0
  pushl $113
801057f3:	6a 71                	push   $0x71
  jmp alltraps
801057f5:	e9 d3 f7 ff ff       	jmp    80104fcd <alltraps>

801057fa <vector114>:
.globl vector114
vector114:
  pushl $0
801057fa:	6a 00                	push   $0x0
  pushl $114
801057fc:	6a 72                	push   $0x72
  jmp alltraps
801057fe:	e9 ca f7 ff ff       	jmp    80104fcd <alltraps>

80105803 <vector115>:
.globl vector115
vector115:
  pushl $0
80105803:	6a 00                	push   $0x0
  pushl $115
80105805:	6a 73                	push   $0x73
  jmp alltraps
80105807:	e9 c1 f7 ff ff       	jmp    80104fcd <alltraps>

8010580c <vector116>:
.globl vector116
vector116:
  pushl $0
8010580c:	6a 00                	push   $0x0
  pushl $116
8010580e:	6a 74                	push   $0x74
  jmp alltraps
80105810:	e9 b8 f7 ff ff       	jmp    80104fcd <alltraps>

80105815 <vector117>:
.globl vector117
vector117:
  pushl $0
80105815:	6a 00                	push   $0x0
  pushl $117
80105817:	6a 75                	push   $0x75
  jmp alltraps
80105819:	e9 af f7 ff ff       	jmp    80104fcd <alltraps>

8010581e <vector118>:
.globl vector118
vector118:
  pushl $0
8010581e:	6a 00                	push   $0x0
  pushl $118
80105820:	6a 76                	push   $0x76
  jmp alltraps
80105822:	e9 a6 f7 ff ff       	jmp    80104fcd <alltraps>

80105827 <vector119>:
.globl vector119
vector119:
  pushl $0
80105827:	6a 00                	push   $0x0
  pushl $119
80105829:	6a 77                	push   $0x77
  jmp alltraps
8010582b:	e9 9d f7 ff ff       	jmp    80104fcd <alltraps>

80105830 <vector120>:
.globl vector120
vector120:
  pushl $0
80105830:	6a 00                	push   $0x0
  pushl $120
80105832:	6a 78                	push   $0x78
  jmp alltraps
80105834:	e9 94 f7 ff ff       	jmp    80104fcd <alltraps>

80105839 <vector121>:
.globl vector121
vector121:
  pushl $0
80105839:	6a 00                	push   $0x0
  pushl $121
8010583b:	6a 79                	push   $0x79
  jmp alltraps
8010583d:	e9 8b f7 ff ff       	jmp    80104fcd <alltraps>

80105842 <vector122>:
.globl vector122
vector122:
  pushl $0
80105842:	6a 00                	push   $0x0
  pushl $122
80105844:	6a 7a                	push   $0x7a
  jmp alltraps
80105846:	e9 82 f7 ff ff       	jmp    80104fcd <alltraps>

8010584b <vector123>:
.globl vector123
vector123:
  pushl $0
8010584b:	6a 00                	push   $0x0
  pushl $123
8010584d:	6a 7b                	push   $0x7b
  jmp alltraps
8010584f:	e9 79 f7 ff ff       	jmp    80104fcd <alltraps>

80105854 <vector124>:
.globl vector124
vector124:
  pushl $0
80105854:	6a 00                	push   $0x0
  pushl $124
80105856:	6a 7c                	push   $0x7c
  jmp alltraps
80105858:	e9 70 f7 ff ff       	jmp    80104fcd <alltraps>

8010585d <vector125>:
.globl vector125
vector125:
  pushl $0
8010585d:	6a 00                	push   $0x0
  pushl $125
8010585f:	6a 7d                	push   $0x7d
  jmp alltraps
80105861:	e9 67 f7 ff ff       	jmp    80104fcd <alltraps>

80105866 <vector126>:
.globl vector126
vector126:
  pushl $0
80105866:	6a 00                	push   $0x0
  pushl $126
80105868:	6a 7e                	push   $0x7e
  jmp alltraps
8010586a:	e9 5e f7 ff ff       	jmp    80104fcd <alltraps>

8010586f <vector127>:
.globl vector127
vector127:
  pushl $0
8010586f:	6a 00                	push   $0x0
  pushl $127
80105871:	6a 7f                	push   $0x7f
  jmp alltraps
80105873:	e9 55 f7 ff ff       	jmp    80104fcd <alltraps>

80105878 <vector128>:
.globl vector128
vector128:
  pushl $0
80105878:	6a 00                	push   $0x0
  pushl $128
8010587a:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010587f:	e9 49 f7 ff ff       	jmp    80104fcd <alltraps>

80105884 <vector129>:
.globl vector129
vector129:
  pushl $0
80105884:	6a 00                	push   $0x0
  pushl $129
80105886:	68 81 00 00 00       	push   $0x81
  jmp alltraps
8010588b:	e9 3d f7 ff ff       	jmp    80104fcd <alltraps>

80105890 <vector130>:
.globl vector130
vector130:
  pushl $0
80105890:	6a 00                	push   $0x0
  pushl $130
80105892:	68 82 00 00 00       	push   $0x82
  jmp alltraps
80105897:	e9 31 f7 ff ff       	jmp    80104fcd <alltraps>

8010589c <vector131>:
.globl vector131
vector131:
  pushl $0
8010589c:	6a 00                	push   $0x0
  pushl $131
8010589e:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801058a3:	e9 25 f7 ff ff       	jmp    80104fcd <alltraps>

801058a8 <vector132>:
.globl vector132
vector132:
  pushl $0
801058a8:	6a 00                	push   $0x0
  pushl $132
801058aa:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801058af:	e9 19 f7 ff ff       	jmp    80104fcd <alltraps>

801058b4 <vector133>:
.globl vector133
vector133:
  pushl $0
801058b4:	6a 00                	push   $0x0
  pushl $133
801058b6:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801058bb:	e9 0d f7 ff ff       	jmp    80104fcd <alltraps>

801058c0 <vector134>:
.globl vector134
vector134:
  pushl $0
801058c0:	6a 00                	push   $0x0
  pushl $134
801058c2:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801058c7:	e9 01 f7 ff ff       	jmp    80104fcd <alltraps>

801058cc <vector135>:
.globl vector135
vector135:
  pushl $0
801058cc:	6a 00                	push   $0x0
  pushl $135
801058ce:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801058d3:	e9 f5 f6 ff ff       	jmp    80104fcd <alltraps>

801058d8 <vector136>:
.globl vector136
vector136:
  pushl $0
801058d8:	6a 00                	push   $0x0
  pushl $136
801058da:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801058df:	e9 e9 f6 ff ff       	jmp    80104fcd <alltraps>

801058e4 <vector137>:
.globl vector137
vector137:
  pushl $0
801058e4:	6a 00                	push   $0x0
  pushl $137
801058e6:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801058eb:	e9 dd f6 ff ff       	jmp    80104fcd <alltraps>

801058f0 <vector138>:
.globl vector138
vector138:
  pushl $0
801058f0:	6a 00                	push   $0x0
  pushl $138
801058f2:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801058f7:	e9 d1 f6 ff ff       	jmp    80104fcd <alltraps>

801058fc <vector139>:
.globl vector139
vector139:
  pushl $0
801058fc:	6a 00                	push   $0x0
  pushl $139
801058fe:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105903:	e9 c5 f6 ff ff       	jmp    80104fcd <alltraps>

80105908 <vector140>:
.globl vector140
vector140:
  pushl $0
80105908:	6a 00                	push   $0x0
  pushl $140
8010590a:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010590f:	e9 b9 f6 ff ff       	jmp    80104fcd <alltraps>

80105914 <vector141>:
.globl vector141
vector141:
  pushl $0
80105914:	6a 00                	push   $0x0
  pushl $141
80105916:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
8010591b:	e9 ad f6 ff ff       	jmp    80104fcd <alltraps>

80105920 <vector142>:
.globl vector142
vector142:
  pushl $0
80105920:	6a 00                	push   $0x0
  pushl $142
80105922:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105927:	e9 a1 f6 ff ff       	jmp    80104fcd <alltraps>

8010592c <vector143>:
.globl vector143
vector143:
  pushl $0
8010592c:	6a 00                	push   $0x0
  pushl $143
8010592e:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105933:	e9 95 f6 ff ff       	jmp    80104fcd <alltraps>

80105938 <vector144>:
.globl vector144
vector144:
  pushl $0
80105938:	6a 00                	push   $0x0
  pushl $144
8010593a:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010593f:	e9 89 f6 ff ff       	jmp    80104fcd <alltraps>

80105944 <vector145>:
.globl vector145
vector145:
  pushl $0
80105944:	6a 00                	push   $0x0
  pushl $145
80105946:	68 91 00 00 00       	push   $0x91
  jmp alltraps
8010594b:	e9 7d f6 ff ff       	jmp    80104fcd <alltraps>

80105950 <vector146>:
.globl vector146
vector146:
  pushl $0
80105950:	6a 00                	push   $0x0
  pushl $146
80105952:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105957:	e9 71 f6 ff ff       	jmp    80104fcd <alltraps>

8010595c <vector147>:
.globl vector147
vector147:
  pushl $0
8010595c:	6a 00                	push   $0x0
  pushl $147
8010595e:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105963:	e9 65 f6 ff ff       	jmp    80104fcd <alltraps>

80105968 <vector148>:
.globl vector148
vector148:
  pushl $0
80105968:	6a 00                	push   $0x0
  pushl $148
8010596a:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010596f:	e9 59 f6 ff ff       	jmp    80104fcd <alltraps>

80105974 <vector149>:
.globl vector149
vector149:
  pushl $0
80105974:	6a 00                	push   $0x0
  pushl $149
80105976:	68 95 00 00 00       	push   $0x95
  jmp alltraps
8010597b:	e9 4d f6 ff ff       	jmp    80104fcd <alltraps>

80105980 <vector150>:
.globl vector150
vector150:
  pushl $0
80105980:	6a 00                	push   $0x0
  pushl $150
80105982:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105987:	e9 41 f6 ff ff       	jmp    80104fcd <alltraps>

8010598c <vector151>:
.globl vector151
vector151:
  pushl $0
8010598c:	6a 00                	push   $0x0
  pushl $151
8010598e:	68 97 00 00 00       	push   $0x97
  jmp alltraps
80105993:	e9 35 f6 ff ff       	jmp    80104fcd <alltraps>

80105998 <vector152>:
.globl vector152
vector152:
  pushl $0
80105998:	6a 00                	push   $0x0
  pushl $152
8010599a:	68 98 00 00 00       	push   $0x98
  jmp alltraps
8010599f:	e9 29 f6 ff ff       	jmp    80104fcd <alltraps>

801059a4 <vector153>:
.globl vector153
vector153:
  pushl $0
801059a4:	6a 00                	push   $0x0
  pushl $153
801059a6:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801059ab:	e9 1d f6 ff ff       	jmp    80104fcd <alltraps>

801059b0 <vector154>:
.globl vector154
vector154:
  pushl $0
801059b0:	6a 00                	push   $0x0
  pushl $154
801059b2:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801059b7:	e9 11 f6 ff ff       	jmp    80104fcd <alltraps>

801059bc <vector155>:
.globl vector155
vector155:
  pushl $0
801059bc:	6a 00                	push   $0x0
  pushl $155
801059be:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801059c3:	e9 05 f6 ff ff       	jmp    80104fcd <alltraps>

801059c8 <vector156>:
.globl vector156
vector156:
  pushl $0
801059c8:	6a 00                	push   $0x0
  pushl $156
801059ca:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801059cf:	e9 f9 f5 ff ff       	jmp    80104fcd <alltraps>

801059d4 <vector157>:
.globl vector157
vector157:
  pushl $0
801059d4:	6a 00                	push   $0x0
  pushl $157
801059d6:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801059db:	e9 ed f5 ff ff       	jmp    80104fcd <alltraps>

801059e0 <vector158>:
.globl vector158
vector158:
  pushl $0
801059e0:	6a 00                	push   $0x0
  pushl $158
801059e2:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801059e7:	e9 e1 f5 ff ff       	jmp    80104fcd <alltraps>

801059ec <vector159>:
.globl vector159
vector159:
  pushl $0
801059ec:	6a 00                	push   $0x0
  pushl $159
801059ee:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801059f3:	e9 d5 f5 ff ff       	jmp    80104fcd <alltraps>

801059f8 <vector160>:
.globl vector160
vector160:
  pushl $0
801059f8:	6a 00                	push   $0x0
  pushl $160
801059fa:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801059ff:	e9 c9 f5 ff ff       	jmp    80104fcd <alltraps>

80105a04 <vector161>:
.globl vector161
vector161:
  pushl $0
80105a04:	6a 00                	push   $0x0
  pushl $161
80105a06:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105a0b:	e9 bd f5 ff ff       	jmp    80104fcd <alltraps>

80105a10 <vector162>:
.globl vector162
vector162:
  pushl $0
80105a10:	6a 00                	push   $0x0
  pushl $162
80105a12:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105a17:	e9 b1 f5 ff ff       	jmp    80104fcd <alltraps>

80105a1c <vector163>:
.globl vector163
vector163:
  pushl $0
80105a1c:	6a 00                	push   $0x0
  pushl $163
80105a1e:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105a23:	e9 a5 f5 ff ff       	jmp    80104fcd <alltraps>

80105a28 <vector164>:
.globl vector164
vector164:
  pushl $0
80105a28:	6a 00                	push   $0x0
  pushl $164
80105a2a:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105a2f:	e9 99 f5 ff ff       	jmp    80104fcd <alltraps>

80105a34 <vector165>:
.globl vector165
vector165:
  pushl $0
80105a34:	6a 00                	push   $0x0
  pushl $165
80105a36:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105a3b:	e9 8d f5 ff ff       	jmp    80104fcd <alltraps>

80105a40 <vector166>:
.globl vector166
vector166:
  pushl $0
80105a40:	6a 00                	push   $0x0
  pushl $166
80105a42:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105a47:	e9 81 f5 ff ff       	jmp    80104fcd <alltraps>

80105a4c <vector167>:
.globl vector167
vector167:
  pushl $0
80105a4c:	6a 00                	push   $0x0
  pushl $167
80105a4e:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105a53:	e9 75 f5 ff ff       	jmp    80104fcd <alltraps>

80105a58 <vector168>:
.globl vector168
vector168:
  pushl $0
80105a58:	6a 00                	push   $0x0
  pushl $168
80105a5a:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105a5f:	e9 69 f5 ff ff       	jmp    80104fcd <alltraps>

80105a64 <vector169>:
.globl vector169
vector169:
  pushl $0
80105a64:	6a 00                	push   $0x0
  pushl $169
80105a66:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105a6b:	e9 5d f5 ff ff       	jmp    80104fcd <alltraps>

80105a70 <vector170>:
.globl vector170
vector170:
  pushl $0
80105a70:	6a 00                	push   $0x0
  pushl $170
80105a72:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105a77:	e9 51 f5 ff ff       	jmp    80104fcd <alltraps>

80105a7c <vector171>:
.globl vector171
vector171:
  pushl $0
80105a7c:	6a 00                	push   $0x0
  pushl $171
80105a7e:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105a83:	e9 45 f5 ff ff       	jmp    80104fcd <alltraps>

80105a88 <vector172>:
.globl vector172
vector172:
  pushl $0
80105a88:	6a 00                	push   $0x0
  pushl $172
80105a8a:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105a8f:	e9 39 f5 ff ff       	jmp    80104fcd <alltraps>

80105a94 <vector173>:
.globl vector173
vector173:
  pushl $0
80105a94:	6a 00                	push   $0x0
  pushl $173
80105a96:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105a9b:	e9 2d f5 ff ff       	jmp    80104fcd <alltraps>

80105aa0 <vector174>:
.globl vector174
vector174:
  pushl $0
80105aa0:	6a 00                	push   $0x0
  pushl $174
80105aa2:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
80105aa7:	e9 21 f5 ff ff       	jmp    80104fcd <alltraps>

80105aac <vector175>:
.globl vector175
vector175:
  pushl $0
80105aac:	6a 00                	push   $0x0
  pushl $175
80105aae:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
80105ab3:	e9 15 f5 ff ff       	jmp    80104fcd <alltraps>

80105ab8 <vector176>:
.globl vector176
vector176:
  pushl $0
80105ab8:	6a 00                	push   $0x0
  pushl $176
80105aba:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105abf:	e9 09 f5 ff ff       	jmp    80104fcd <alltraps>

80105ac4 <vector177>:
.globl vector177
vector177:
  pushl $0
80105ac4:	6a 00                	push   $0x0
  pushl $177
80105ac6:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105acb:	e9 fd f4 ff ff       	jmp    80104fcd <alltraps>

80105ad0 <vector178>:
.globl vector178
vector178:
  pushl $0
80105ad0:	6a 00                	push   $0x0
  pushl $178
80105ad2:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105ad7:	e9 f1 f4 ff ff       	jmp    80104fcd <alltraps>

80105adc <vector179>:
.globl vector179
vector179:
  pushl $0
80105adc:	6a 00                	push   $0x0
  pushl $179
80105ade:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105ae3:	e9 e5 f4 ff ff       	jmp    80104fcd <alltraps>

80105ae8 <vector180>:
.globl vector180
vector180:
  pushl $0
80105ae8:	6a 00                	push   $0x0
  pushl $180
80105aea:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105aef:	e9 d9 f4 ff ff       	jmp    80104fcd <alltraps>

80105af4 <vector181>:
.globl vector181
vector181:
  pushl $0
80105af4:	6a 00                	push   $0x0
  pushl $181
80105af6:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105afb:	e9 cd f4 ff ff       	jmp    80104fcd <alltraps>

80105b00 <vector182>:
.globl vector182
vector182:
  pushl $0
80105b00:	6a 00                	push   $0x0
  pushl $182
80105b02:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105b07:	e9 c1 f4 ff ff       	jmp    80104fcd <alltraps>

80105b0c <vector183>:
.globl vector183
vector183:
  pushl $0
80105b0c:	6a 00                	push   $0x0
  pushl $183
80105b0e:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105b13:	e9 b5 f4 ff ff       	jmp    80104fcd <alltraps>

80105b18 <vector184>:
.globl vector184
vector184:
  pushl $0
80105b18:	6a 00                	push   $0x0
  pushl $184
80105b1a:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105b1f:	e9 a9 f4 ff ff       	jmp    80104fcd <alltraps>

80105b24 <vector185>:
.globl vector185
vector185:
  pushl $0
80105b24:	6a 00                	push   $0x0
  pushl $185
80105b26:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105b2b:	e9 9d f4 ff ff       	jmp    80104fcd <alltraps>

80105b30 <vector186>:
.globl vector186
vector186:
  pushl $0
80105b30:	6a 00                	push   $0x0
  pushl $186
80105b32:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105b37:	e9 91 f4 ff ff       	jmp    80104fcd <alltraps>

80105b3c <vector187>:
.globl vector187
vector187:
  pushl $0
80105b3c:	6a 00                	push   $0x0
  pushl $187
80105b3e:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105b43:	e9 85 f4 ff ff       	jmp    80104fcd <alltraps>

80105b48 <vector188>:
.globl vector188
vector188:
  pushl $0
80105b48:	6a 00                	push   $0x0
  pushl $188
80105b4a:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105b4f:	e9 79 f4 ff ff       	jmp    80104fcd <alltraps>

80105b54 <vector189>:
.globl vector189
vector189:
  pushl $0
80105b54:	6a 00                	push   $0x0
  pushl $189
80105b56:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105b5b:	e9 6d f4 ff ff       	jmp    80104fcd <alltraps>

80105b60 <vector190>:
.globl vector190
vector190:
  pushl $0
80105b60:	6a 00                	push   $0x0
  pushl $190
80105b62:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105b67:	e9 61 f4 ff ff       	jmp    80104fcd <alltraps>

80105b6c <vector191>:
.globl vector191
vector191:
  pushl $0
80105b6c:	6a 00                	push   $0x0
  pushl $191
80105b6e:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105b73:	e9 55 f4 ff ff       	jmp    80104fcd <alltraps>

80105b78 <vector192>:
.globl vector192
vector192:
  pushl $0
80105b78:	6a 00                	push   $0x0
  pushl $192
80105b7a:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105b7f:	e9 49 f4 ff ff       	jmp    80104fcd <alltraps>

80105b84 <vector193>:
.globl vector193
vector193:
  pushl $0
80105b84:	6a 00                	push   $0x0
  pushl $193
80105b86:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105b8b:	e9 3d f4 ff ff       	jmp    80104fcd <alltraps>

80105b90 <vector194>:
.globl vector194
vector194:
  pushl $0
80105b90:	6a 00                	push   $0x0
  pushl $194
80105b92:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105b97:	e9 31 f4 ff ff       	jmp    80104fcd <alltraps>

80105b9c <vector195>:
.globl vector195
vector195:
  pushl $0
80105b9c:	6a 00                	push   $0x0
  pushl $195
80105b9e:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105ba3:	e9 25 f4 ff ff       	jmp    80104fcd <alltraps>

80105ba8 <vector196>:
.globl vector196
vector196:
  pushl $0
80105ba8:	6a 00                	push   $0x0
  pushl $196
80105baa:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105baf:	e9 19 f4 ff ff       	jmp    80104fcd <alltraps>

80105bb4 <vector197>:
.globl vector197
vector197:
  pushl $0
80105bb4:	6a 00                	push   $0x0
  pushl $197
80105bb6:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105bbb:	e9 0d f4 ff ff       	jmp    80104fcd <alltraps>

80105bc0 <vector198>:
.globl vector198
vector198:
  pushl $0
80105bc0:	6a 00                	push   $0x0
  pushl $198
80105bc2:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105bc7:	e9 01 f4 ff ff       	jmp    80104fcd <alltraps>

80105bcc <vector199>:
.globl vector199
vector199:
  pushl $0
80105bcc:	6a 00                	push   $0x0
  pushl $199
80105bce:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105bd3:	e9 f5 f3 ff ff       	jmp    80104fcd <alltraps>

80105bd8 <vector200>:
.globl vector200
vector200:
  pushl $0
80105bd8:	6a 00                	push   $0x0
  pushl $200
80105bda:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105bdf:	e9 e9 f3 ff ff       	jmp    80104fcd <alltraps>

80105be4 <vector201>:
.globl vector201
vector201:
  pushl $0
80105be4:	6a 00                	push   $0x0
  pushl $201
80105be6:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105beb:	e9 dd f3 ff ff       	jmp    80104fcd <alltraps>

80105bf0 <vector202>:
.globl vector202
vector202:
  pushl $0
80105bf0:	6a 00                	push   $0x0
  pushl $202
80105bf2:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105bf7:	e9 d1 f3 ff ff       	jmp    80104fcd <alltraps>

80105bfc <vector203>:
.globl vector203
vector203:
  pushl $0
80105bfc:	6a 00                	push   $0x0
  pushl $203
80105bfe:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105c03:	e9 c5 f3 ff ff       	jmp    80104fcd <alltraps>

80105c08 <vector204>:
.globl vector204
vector204:
  pushl $0
80105c08:	6a 00                	push   $0x0
  pushl $204
80105c0a:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105c0f:	e9 b9 f3 ff ff       	jmp    80104fcd <alltraps>

80105c14 <vector205>:
.globl vector205
vector205:
  pushl $0
80105c14:	6a 00                	push   $0x0
  pushl $205
80105c16:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105c1b:	e9 ad f3 ff ff       	jmp    80104fcd <alltraps>

80105c20 <vector206>:
.globl vector206
vector206:
  pushl $0
80105c20:	6a 00                	push   $0x0
  pushl $206
80105c22:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105c27:	e9 a1 f3 ff ff       	jmp    80104fcd <alltraps>

80105c2c <vector207>:
.globl vector207
vector207:
  pushl $0
80105c2c:	6a 00                	push   $0x0
  pushl $207
80105c2e:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105c33:	e9 95 f3 ff ff       	jmp    80104fcd <alltraps>

80105c38 <vector208>:
.globl vector208
vector208:
  pushl $0
80105c38:	6a 00                	push   $0x0
  pushl $208
80105c3a:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105c3f:	e9 89 f3 ff ff       	jmp    80104fcd <alltraps>

80105c44 <vector209>:
.globl vector209
vector209:
  pushl $0
80105c44:	6a 00                	push   $0x0
  pushl $209
80105c46:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105c4b:	e9 7d f3 ff ff       	jmp    80104fcd <alltraps>

80105c50 <vector210>:
.globl vector210
vector210:
  pushl $0
80105c50:	6a 00                	push   $0x0
  pushl $210
80105c52:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105c57:	e9 71 f3 ff ff       	jmp    80104fcd <alltraps>

80105c5c <vector211>:
.globl vector211
vector211:
  pushl $0
80105c5c:	6a 00                	push   $0x0
  pushl $211
80105c5e:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105c63:	e9 65 f3 ff ff       	jmp    80104fcd <alltraps>

80105c68 <vector212>:
.globl vector212
vector212:
  pushl $0
80105c68:	6a 00                	push   $0x0
  pushl $212
80105c6a:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105c6f:	e9 59 f3 ff ff       	jmp    80104fcd <alltraps>

80105c74 <vector213>:
.globl vector213
vector213:
  pushl $0
80105c74:	6a 00                	push   $0x0
  pushl $213
80105c76:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105c7b:	e9 4d f3 ff ff       	jmp    80104fcd <alltraps>

80105c80 <vector214>:
.globl vector214
vector214:
  pushl $0
80105c80:	6a 00                	push   $0x0
  pushl $214
80105c82:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105c87:	e9 41 f3 ff ff       	jmp    80104fcd <alltraps>

80105c8c <vector215>:
.globl vector215
vector215:
  pushl $0
80105c8c:	6a 00                	push   $0x0
  pushl $215
80105c8e:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105c93:	e9 35 f3 ff ff       	jmp    80104fcd <alltraps>

80105c98 <vector216>:
.globl vector216
vector216:
  pushl $0
80105c98:	6a 00                	push   $0x0
  pushl $216
80105c9a:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105c9f:	e9 29 f3 ff ff       	jmp    80104fcd <alltraps>

80105ca4 <vector217>:
.globl vector217
vector217:
  pushl $0
80105ca4:	6a 00                	push   $0x0
  pushl $217
80105ca6:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105cab:	e9 1d f3 ff ff       	jmp    80104fcd <alltraps>

80105cb0 <vector218>:
.globl vector218
vector218:
  pushl $0
80105cb0:	6a 00                	push   $0x0
  pushl $218
80105cb2:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105cb7:	e9 11 f3 ff ff       	jmp    80104fcd <alltraps>

80105cbc <vector219>:
.globl vector219
vector219:
  pushl $0
80105cbc:	6a 00                	push   $0x0
  pushl $219
80105cbe:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105cc3:	e9 05 f3 ff ff       	jmp    80104fcd <alltraps>

80105cc8 <vector220>:
.globl vector220
vector220:
  pushl $0
80105cc8:	6a 00                	push   $0x0
  pushl $220
80105cca:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105ccf:	e9 f9 f2 ff ff       	jmp    80104fcd <alltraps>

80105cd4 <vector221>:
.globl vector221
vector221:
  pushl $0
80105cd4:	6a 00                	push   $0x0
  pushl $221
80105cd6:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105cdb:	e9 ed f2 ff ff       	jmp    80104fcd <alltraps>

80105ce0 <vector222>:
.globl vector222
vector222:
  pushl $0
80105ce0:	6a 00                	push   $0x0
  pushl $222
80105ce2:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105ce7:	e9 e1 f2 ff ff       	jmp    80104fcd <alltraps>

80105cec <vector223>:
.globl vector223
vector223:
  pushl $0
80105cec:	6a 00                	push   $0x0
  pushl $223
80105cee:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105cf3:	e9 d5 f2 ff ff       	jmp    80104fcd <alltraps>

80105cf8 <vector224>:
.globl vector224
vector224:
  pushl $0
80105cf8:	6a 00                	push   $0x0
  pushl $224
80105cfa:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105cff:	e9 c9 f2 ff ff       	jmp    80104fcd <alltraps>

80105d04 <vector225>:
.globl vector225
vector225:
  pushl $0
80105d04:	6a 00                	push   $0x0
  pushl $225
80105d06:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105d0b:	e9 bd f2 ff ff       	jmp    80104fcd <alltraps>

80105d10 <vector226>:
.globl vector226
vector226:
  pushl $0
80105d10:	6a 00                	push   $0x0
  pushl $226
80105d12:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105d17:	e9 b1 f2 ff ff       	jmp    80104fcd <alltraps>

80105d1c <vector227>:
.globl vector227
vector227:
  pushl $0
80105d1c:	6a 00                	push   $0x0
  pushl $227
80105d1e:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105d23:	e9 a5 f2 ff ff       	jmp    80104fcd <alltraps>

80105d28 <vector228>:
.globl vector228
vector228:
  pushl $0
80105d28:	6a 00                	push   $0x0
  pushl $228
80105d2a:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105d2f:	e9 99 f2 ff ff       	jmp    80104fcd <alltraps>

80105d34 <vector229>:
.globl vector229
vector229:
  pushl $0
80105d34:	6a 00                	push   $0x0
  pushl $229
80105d36:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105d3b:	e9 8d f2 ff ff       	jmp    80104fcd <alltraps>

80105d40 <vector230>:
.globl vector230
vector230:
  pushl $0
80105d40:	6a 00                	push   $0x0
  pushl $230
80105d42:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105d47:	e9 81 f2 ff ff       	jmp    80104fcd <alltraps>

80105d4c <vector231>:
.globl vector231
vector231:
  pushl $0
80105d4c:	6a 00                	push   $0x0
  pushl $231
80105d4e:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105d53:	e9 75 f2 ff ff       	jmp    80104fcd <alltraps>

80105d58 <vector232>:
.globl vector232
vector232:
  pushl $0
80105d58:	6a 00                	push   $0x0
  pushl $232
80105d5a:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105d5f:	e9 69 f2 ff ff       	jmp    80104fcd <alltraps>

80105d64 <vector233>:
.globl vector233
vector233:
  pushl $0
80105d64:	6a 00                	push   $0x0
  pushl $233
80105d66:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105d6b:	e9 5d f2 ff ff       	jmp    80104fcd <alltraps>

80105d70 <vector234>:
.globl vector234
vector234:
  pushl $0
80105d70:	6a 00                	push   $0x0
  pushl $234
80105d72:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105d77:	e9 51 f2 ff ff       	jmp    80104fcd <alltraps>

80105d7c <vector235>:
.globl vector235
vector235:
  pushl $0
80105d7c:	6a 00                	push   $0x0
  pushl $235
80105d7e:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105d83:	e9 45 f2 ff ff       	jmp    80104fcd <alltraps>

80105d88 <vector236>:
.globl vector236
vector236:
  pushl $0
80105d88:	6a 00                	push   $0x0
  pushl $236
80105d8a:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105d8f:	e9 39 f2 ff ff       	jmp    80104fcd <alltraps>

80105d94 <vector237>:
.globl vector237
vector237:
  pushl $0
80105d94:	6a 00                	push   $0x0
  pushl $237
80105d96:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105d9b:	e9 2d f2 ff ff       	jmp    80104fcd <alltraps>

80105da0 <vector238>:
.globl vector238
vector238:
  pushl $0
80105da0:	6a 00                	push   $0x0
  pushl $238
80105da2:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105da7:	e9 21 f2 ff ff       	jmp    80104fcd <alltraps>

80105dac <vector239>:
.globl vector239
vector239:
  pushl $0
80105dac:	6a 00                	push   $0x0
  pushl $239
80105dae:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105db3:	e9 15 f2 ff ff       	jmp    80104fcd <alltraps>

80105db8 <vector240>:
.globl vector240
vector240:
  pushl $0
80105db8:	6a 00                	push   $0x0
  pushl $240
80105dba:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105dbf:	e9 09 f2 ff ff       	jmp    80104fcd <alltraps>

80105dc4 <vector241>:
.globl vector241
vector241:
  pushl $0
80105dc4:	6a 00                	push   $0x0
  pushl $241
80105dc6:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105dcb:	e9 fd f1 ff ff       	jmp    80104fcd <alltraps>

80105dd0 <vector242>:
.globl vector242
vector242:
  pushl $0
80105dd0:	6a 00                	push   $0x0
  pushl $242
80105dd2:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105dd7:	e9 f1 f1 ff ff       	jmp    80104fcd <alltraps>

80105ddc <vector243>:
.globl vector243
vector243:
  pushl $0
80105ddc:	6a 00                	push   $0x0
  pushl $243
80105dde:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105de3:	e9 e5 f1 ff ff       	jmp    80104fcd <alltraps>

80105de8 <vector244>:
.globl vector244
vector244:
  pushl $0
80105de8:	6a 00                	push   $0x0
  pushl $244
80105dea:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105def:	e9 d9 f1 ff ff       	jmp    80104fcd <alltraps>

80105df4 <vector245>:
.globl vector245
vector245:
  pushl $0
80105df4:	6a 00                	push   $0x0
  pushl $245
80105df6:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105dfb:	e9 cd f1 ff ff       	jmp    80104fcd <alltraps>

80105e00 <vector246>:
.globl vector246
vector246:
  pushl $0
80105e00:	6a 00                	push   $0x0
  pushl $246
80105e02:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105e07:	e9 c1 f1 ff ff       	jmp    80104fcd <alltraps>

80105e0c <vector247>:
.globl vector247
vector247:
  pushl $0
80105e0c:	6a 00                	push   $0x0
  pushl $247
80105e0e:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105e13:	e9 b5 f1 ff ff       	jmp    80104fcd <alltraps>

80105e18 <vector248>:
.globl vector248
vector248:
  pushl $0
80105e18:	6a 00                	push   $0x0
  pushl $248
80105e1a:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105e1f:	e9 a9 f1 ff ff       	jmp    80104fcd <alltraps>

80105e24 <vector249>:
.globl vector249
vector249:
  pushl $0
80105e24:	6a 00                	push   $0x0
  pushl $249
80105e26:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105e2b:	e9 9d f1 ff ff       	jmp    80104fcd <alltraps>

80105e30 <vector250>:
.globl vector250
vector250:
  pushl $0
80105e30:	6a 00                	push   $0x0
  pushl $250
80105e32:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105e37:	e9 91 f1 ff ff       	jmp    80104fcd <alltraps>

80105e3c <vector251>:
.globl vector251
vector251:
  pushl $0
80105e3c:	6a 00                	push   $0x0
  pushl $251
80105e3e:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105e43:	e9 85 f1 ff ff       	jmp    80104fcd <alltraps>

80105e48 <vector252>:
.globl vector252
vector252:
  pushl $0
80105e48:	6a 00                	push   $0x0
  pushl $252
80105e4a:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105e4f:	e9 79 f1 ff ff       	jmp    80104fcd <alltraps>

80105e54 <vector253>:
.globl vector253
vector253:
  pushl $0
80105e54:	6a 00                	push   $0x0
  pushl $253
80105e56:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105e5b:	e9 6d f1 ff ff       	jmp    80104fcd <alltraps>

80105e60 <vector254>:
.globl vector254
vector254:
  pushl $0
80105e60:	6a 00                	push   $0x0
  pushl $254
80105e62:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105e67:	e9 61 f1 ff ff       	jmp    80104fcd <alltraps>

80105e6c <vector255>:
.globl vector255
vector255:
  pushl $0
80105e6c:	6a 00                	push   $0x0
  pushl $255
80105e6e:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105e73:	e9 55 f1 ff ff       	jmp    80104fcd <alltraps>

80105e78 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105e78:	55                   	push   %ebp
80105e79:	89 e5                	mov    %esp,%ebp
80105e7b:	57                   	push   %edi
80105e7c:	56                   	push   %esi
80105e7d:	53                   	push   %ebx
80105e7e:	83 ec 0c             	sub    $0xc,%esp
80105e81:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105e83:	c1 ea 16             	shr    $0x16,%edx
80105e86:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105e89:	8b 1f                	mov    (%edi),%ebx
80105e8b:	f6 c3 01             	test   $0x1,%bl
80105e8e:	74 22                	je     80105eb2 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105e90:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105e96:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105e9c:	c1 ee 0c             	shr    $0xc,%esi
80105e9f:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105ea5:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105ea8:	89 d8                	mov    %ebx,%eax
80105eaa:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105ead:	5b                   	pop    %ebx
80105eae:	5e                   	pop    %esi
80105eaf:	5f                   	pop    %edi
80105eb0:	5d                   	pop    %ebp
80105eb1:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105eb2:	85 c9                	test   %ecx,%ecx
80105eb4:	74 2b                	je     80105ee1 <walkpgdir+0x69>
80105eb6:	e8 98 c3 ff ff       	call   80102253 <kalloc>
80105ebb:	89 c3                	mov    %eax,%ebx
80105ebd:	85 c0                	test   %eax,%eax
80105ebf:	74 e7                	je     80105ea8 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105ec1:	83 ec 04             	sub    $0x4,%esp
80105ec4:	68 00 10 00 00       	push   $0x1000
80105ec9:	6a 00                	push   $0x0
80105ecb:	50                   	push   %eax
80105ecc:	e8 f1 df ff ff       	call   80103ec2 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105ed1:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105ed7:	83 c8 07             	or     $0x7,%eax
80105eda:	89 07                	mov    %eax,(%edi)
80105edc:	83 c4 10             	add    $0x10,%esp
80105edf:	eb bb                	jmp    80105e9c <walkpgdir+0x24>
      return 0;
80105ee1:	bb 00 00 00 00       	mov    $0x0,%ebx
80105ee6:	eb c0                	jmp    80105ea8 <walkpgdir+0x30>

80105ee8 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105ee8:	55                   	push   %ebp
80105ee9:	89 e5                	mov    %esp,%ebp
80105eeb:	57                   	push   %edi
80105eec:	56                   	push   %esi
80105eed:	53                   	push   %ebx
80105eee:	83 ec 1c             	sub    $0x1c,%esp
80105ef1:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105ef4:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105ef7:	89 d3                	mov    %edx,%ebx
80105ef9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105eff:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105f03:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105f09:	b9 01 00 00 00       	mov    $0x1,%ecx
80105f0e:	89 da                	mov    %ebx,%edx
80105f10:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105f13:	e8 60 ff ff ff       	call   80105e78 <walkpgdir>
80105f18:	85 c0                	test   %eax,%eax
80105f1a:	74 2e                	je     80105f4a <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105f1c:	f6 00 01             	testb  $0x1,(%eax)
80105f1f:	75 1c                	jne    80105f3d <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105f21:	89 f2                	mov    %esi,%edx
80105f23:	0b 55 0c             	or     0xc(%ebp),%edx
80105f26:	83 ca 01             	or     $0x1,%edx
80105f29:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105f2b:	39 fb                	cmp    %edi,%ebx
80105f2d:	74 28                	je     80105f57 <mappages+0x6f>
      break;
    a += PGSIZE;
80105f2f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105f35:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105f3b:	eb cc                	jmp    80105f09 <mappages+0x21>
      panic("remap");
80105f3d:	83 ec 0c             	sub    $0xc,%esp
80105f40:	68 70 70 10 80       	push   $0x80107070
80105f45:	e8 fe a3 ff ff       	call   80100348 <panic>
      return -1;
80105f4a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105f4f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f52:	5b                   	pop    %ebx
80105f53:	5e                   	pop    %esi
80105f54:	5f                   	pop    %edi
80105f55:	5d                   	pop    %ebp
80105f56:	c3                   	ret    
  return 0;
80105f57:	b8 00 00 00 00       	mov    $0x0,%eax
80105f5c:	eb f1                	jmp    80105f4f <mappages+0x67>

80105f5e <seginit>:
{
80105f5e:	55                   	push   %ebp
80105f5f:	89 e5                	mov    %esp,%ebp
80105f61:	53                   	push   %ebx
80105f62:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105f65:	e8 26 d4 ff ff       	call   80103390 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105f6a:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105f70:	66 c7 80 38 28 13 80 	movw   $0xffff,-0x7fecd7c8(%eax)
80105f77:	ff ff 
80105f79:	66 c7 80 3a 28 13 80 	movw   $0x0,-0x7fecd7c6(%eax)
80105f80:	00 00 
80105f82:	c6 80 3c 28 13 80 00 	movb   $0x0,-0x7fecd7c4(%eax)
80105f89:	0f b6 88 3d 28 13 80 	movzbl -0x7fecd7c3(%eax),%ecx
80105f90:	83 e1 f0             	and    $0xfffffff0,%ecx
80105f93:	83 c9 1a             	or     $0x1a,%ecx
80105f96:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f99:	83 c9 80             	or     $0xffffff80,%ecx
80105f9c:	88 88 3d 28 13 80    	mov    %cl,-0x7fecd7c3(%eax)
80105fa2:	0f b6 88 3e 28 13 80 	movzbl -0x7fecd7c2(%eax),%ecx
80105fa9:	83 c9 0f             	or     $0xf,%ecx
80105fac:	83 e1 cf             	and    $0xffffffcf,%ecx
80105faf:	83 c9 c0             	or     $0xffffffc0,%ecx
80105fb2:	88 88 3e 28 13 80    	mov    %cl,-0x7fecd7c2(%eax)
80105fb8:	c6 80 3f 28 13 80 00 	movb   $0x0,-0x7fecd7c1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105fbf:	66 c7 80 40 28 13 80 	movw   $0xffff,-0x7fecd7c0(%eax)
80105fc6:	ff ff 
80105fc8:	66 c7 80 42 28 13 80 	movw   $0x0,-0x7fecd7be(%eax)
80105fcf:	00 00 
80105fd1:	c6 80 44 28 13 80 00 	movb   $0x0,-0x7fecd7bc(%eax)
80105fd8:	0f b6 88 45 28 13 80 	movzbl -0x7fecd7bb(%eax),%ecx
80105fdf:	83 e1 f0             	and    $0xfffffff0,%ecx
80105fe2:	83 c9 12             	or     $0x12,%ecx
80105fe5:	83 e1 9f             	and    $0xffffff9f,%ecx
80105fe8:	83 c9 80             	or     $0xffffff80,%ecx
80105feb:	88 88 45 28 13 80    	mov    %cl,-0x7fecd7bb(%eax)
80105ff1:	0f b6 88 46 28 13 80 	movzbl -0x7fecd7ba(%eax),%ecx
80105ff8:	83 c9 0f             	or     $0xf,%ecx
80105ffb:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ffe:	83 c9 c0             	or     $0xffffffc0,%ecx
80106001:	88 88 46 28 13 80    	mov    %cl,-0x7fecd7ba(%eax)
80106007:	c6 80 47 28 13 80 00 	movb   $0x0,-0x7fecd7b9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
8010600e:	66 c7 80 48 28 13 80 	movw   $0xffff,-0x7fecd7b8(%eax)
80106015:	ff ff 
80106017:	66 c7 80 4a 28 13 80 	movw   $0x0,-0x7fecd7b6(%eax)
8010601e:	00 00 
80106020:	c6 80 4c 28 13 80 00 	movb   $0x0,-0x7fecd7b4(%eax)
80106027:	c6 80 4d 28 13 80 fa 	movb   $0xfa,-0x7fecd7b3(%eax)
8010602e:	0f b6 88 4e 28 13 80 	movzbl -0x7fecd7b2(%eax),%ecx
80106035:	83 c9 0f             	or     $0xf,%ecx
80106038:	83 e1 cf             	and    $0xffffffcf,%ecx
8010603b:	83 c9 c0             	or     $0xffffffc0,%ecx
8010603e:	88 88 4e 28 13 80    	mov    %cl,-0x7fecd7b2(%eax)
80106044:	c6 80 4f 28 13 80 00 	movb   $0x0,-0x7fecd7b1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
8010604b:	66 c7 80 50 28 13 80 	movw   $0xffff,-0x7fecd7b0(%eax)
80106052:	ff ff 
80106054:	66 c7 80 52 28 13 80 	movw   $0x0,-0x7fecd7ae(%eax)
8010605b:	00 00 
8010605d:	c6 80 54 28 13 80 00 	movb   $0x0,-0x7fecd7ac(%eax)
80106064:	c6 80 55 28 13 80 f2 	movb   $0xf2,-0x7fecd7ab(%eax)
8010606b:	0f b6 88 56 28 13 80 	movzbl -0x7fecd7aa(%eax),%ecx
80106072:	83 c9 0f             	or     $0xf,%ecx
80106075:	83 e1 cf             	and    $0xffffffcf,%ecx
80106078:	83 c9 c0             	or     $0xffffffc0,%ecx
8010607b:	88 88 56 28 13 80    	mov    %cl,-0x7fecd7aa(%eax)
80106081:	c6 80 57 28 13 80 00 	movb   $0x0,-0x7fecd7a9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80106088:	05 30 28 13 80       	add    $0x80132830,%eax
  pd[0] = size-1;
8010608d:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80106093:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80106097:	c1 e8 10             	shr    $0x10,%eax
8010609a:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
8010609e:	8d 45 f2             	lea    -0xe(%ebp),%eax
801060a1:	0f 01 10             	lgdtl  (%eax)
}
801060a4:	83 c4 14             	add    $0x14,%esp
801060a7:	5b                   	pop    %ebx
801060a8:	5d                   	pop    %ebp
801060a9:	c3                   	ret    

801060aa <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
801060aa:	55                   	push   %ebp
801060ab:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
801060ad:	a1 e4 54 13 80       	mov    0x801354e4,%eax
801060b2:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060b7:	0f 22 d8             	mov    %eax,%cr3
}
801060ba:	5d                   	pop    %ebp
801060bb:	c3                   	ret    

801060bc <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
801060bc:	55                   	push   %ebp
801060bd:	89 e5                	mov    %esp,%ebp
801060bf:	57                   	push   %edi
801060c0:	56                   	push   %esi
801060c1:	53                   	push   %ebx
801060c2:	83 ec 1c             	sub    $0x1c,%esp
801060c5:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
801060c8:	85 f6                	test   %esi,%esi
801060ca:	0f 84 dd 00 00 00    	je     801061ad <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
801060d0:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
801060d4:	0f 84 e0 00 00 00    	je     801061ba <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
801060da:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
801060de:	0f 84 e3 00 00 00    	je     801061c7 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
801060e4:	e8 50 dc ff ff       	call   80103d39 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
801060e9:	e8 46 d2 ff ff       	call   80103334 <mycpu>
801060ee:	89 c3                	mov    %eax,%ebx
801060f0:	e8 3f d2 ff ff       	call   80103334 <mycpu>
801060f5:	8d 78 08             	lea    0x8(%eax),%edi
801060f8:	e8 37 d2 ff ff       	call   80103334 <mycpu>
801060fd:	83 c0 08             	add    $0x8,%eax
80106100:	c1 e8 10             	shr    $0x10,%eax
80106103:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106106:	e8 29 d2 ff ff       	call   80103334 <mycpu>
8010610b:	83 c0 08             	add    $0x8,%eax
8010610e:	c1 e8 18             	shr    $0x18,%eax
80106111:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106118:	67 00 
8010611a:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106121:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80106125:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
8010612b:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106132:	83 e2 f0             	and    $0xfffffff0,%edx
80106135:	83 ca 19             	or     $0x19,%edx
80106138:	83 e2 9f             	and    $0xffffff9f,%edx
8010613b:	83 ca 80             	or     $0xffffff80,%edx
8010613e:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80106144:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
8010614b:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106151:	e8 de d1 ff ff       	call   80103334 <mycpu>
80106156:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
8010615d:	83 e2 ef             	and    $0xffffffef,%edx
80106160:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80106166:	e8 c9 d1 ff ff       	call   80103334 <mycpu>
8010616b:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106171:	8b 5e 08             	mov    0x8(%esi),%ebx
80106174:	e8 bb d1 ff ff       	call   80103334 <mycpu>
80106179:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010617f:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106182:	e8 ad d1 ff ff       	call   80103334 <mycpu>
80106187:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
8010618d:	b8 28 00 00 00       	mov    $0x28,%eax
80106192:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80106195:	8b 46 04             	mov    0x4(%esi),%eax
80106198:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
8010619d:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801061a0:	e8 d1 db ff ff       	call   80103d76 <popcli>
}
801061a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061a8:	5b                   	pop    %ebx
801061a9:	5e                   	pop    %esi
801061aa:	5f                   	pop    %edi
801061ab:	5d                   	pop    %ebp
801061ac:	c3                   	ret    
    panic("switchuvm: no process");
801061ad:	83 ec 0c             	sub    $0xc,%esp
801061b0:	68 76 70 10 80       	push   $0x80107076
801061b5:	e8 8e a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801061ba:	83 ec 0c             	sub    $0xc,%esp
801061bd:	68 8c 70 10 80       	push   $0x8010708c
801061c2:	e8 81 a1 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801061c7:	83 ec 0c             	sub    $0xc,%esp
801061ca:	68 a1 70 10 80       	push   $0x801070a1
801061cf:	e8 74 a1 ff ff       	call   80100348 <panic>

801061d4 <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
801061d4:	55                   	push   %ebp
801061d5:	89 e5                	mov    %esp,%ebp
801061d7:	56                   	push   %esi
801061d8:	53                   	push   %ebx
801061d9:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801061dc:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061e2:	77 57                	ja     8010623b <inituvm+0x67>
    panic("inituvm: more than a page");
  //mem = kalloc();
  mem = kalloc1(myproc()->pid);
801061e4:	e8 c2 d1 ff ff       	call   801033ab <myproc>
801061e9:	83 ec 0c             	sub    $0xc,%esp
801061ec:	ff 70 10             	pushl  0x10(%eax)
801061ef:	e8 c2 c0 ff ff       	call   801022b6 <kalloc1>
801061f4:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
801061f6:	83 c4 0c             	add    $0xc,%esp
801061f9:	68 00 10 00 00       	push   $0x1000
801061fe:	6a 00                	push   $0x0
80106200:	50                   	push   %eax
80106201:	e8 bc dc ff ff       	call   80103ec2 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106206:	83 c4 08             	add    $0x8,%esp
80106209:	6a 06                	push   $0x6
8010620b:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106211:	50                   	push   %eax
80106212:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106217:	ba 00 00 00 00       	mov    $0x0,%edx
8010621c:	8b 45 08             	mov    0x8(%ebp),%eax
8010621f:	e8 c4 fc ff ff       	call   80105ee8 <mappages>
  memmove(mem, init, sz);
80106224:	83 c4 0c             	add    $0xc,%esp
80106227:	56                   	push   %esi
80106228:	ff 75 0c             	pushl  0xc(%ebp)
8010622b:	53                   	push   %ebx
8010622c:	e8 0c dd ff ff       	call   80103f3d <memmove>
}
80106231:	83 c4 10             	add    $0x10,%esp
80106234:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106237:	5b                   	pop    %ebx
80106238:	5e                   	pop    %esi
80106239:	5d                   	pop    %ebp
8010623a:	c3                   	ret    
    panic("inituvm: more than a page");
8010623b:	83 ec 0c             	sub    $0xc,%esp
8010623e:	68 b5 70 10 80       	push   $0x801070b5
80106243:	e8 00 a1 ff ff       	call   80100348 <panic>

80106248 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106248:	55                   	push   %ebp
80106249:	89 e5                	mov    %esp,%ebp
8010624b:	57                   	push   %edi
8010624c:	56                   	push   %esi
8010624d:	53                   	push   %ebx
8010624e:	83 ec 0c             	sub    $0xc,%esp
80106251:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106254:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010625b:	75 07                	jne    80106264 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010625d:	bb 00 00 00 00       	mov    $0x0,%ebx
80106262:	eb 3c                	jmp    801062a0 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106264:	83 ec 0c             	sub    $0xc,%esp
80106267:	68 7c 71 10 80       	push   $0x8010717c
8010626c:	e8 d7 a0 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106271:	83 ec 0c             	sub    $0xc,%esp
80106274:	68 cf 70 10 80       	push   $0x801070cf
80106279:	e8 ca a0 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010627e:	05 00 00 00 80       	add    $0x80000000,%eax
80106283:	56                   	push   %esi
80106284:	89 da                	mov    %ebx,%edx
80106286:	03 55 14             	add    0x14(%ebp),%edx
80106289:	52                   	push   %edx
8010628a:	50                   	push   %eax
8010628b:	ff 75 10             	pushl  0x10(%ebp)
8010628e:	e8 e0 b4 ff ff       	call   80101773 <readi>
80106293:	83 c4 10             	add    $0x10,%esp
80106296:	39 f0                	cmp    %esi,%eax
80106298:	75 47                	jne    801062e1 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
8010629a:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801062a0:	39 fb                	cmp    %edi,%ebx
801062a2:	73 30                	jae    801062d4 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801062a4:	89 da                	mov    %ebx,%edx
801062a6:	03 55 0c             	add    0xc(%ebp),%edx
801062a9:	b9 00 00 00 00       	mov    $0x0,%ecx
801062ae:	8b 45 08             	mov    0x8(%ebp),%eax
801062b1:	e8 c2 fb ff ff       	call   80105e78 <walkpgdir>
801062b6:	85 c0                	test   %eax,%eax
801062b8:	74 b7                	je     80106271 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801062ba:	8b 00                	mov    (%eax),%eax
801062bc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801062c1:	89 fe                	mov    %edi,%esi
801062c3:	29 de                	sub    %ebx,%esi
801062c5:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801062cb:	76 b1                	jbe    8010627e <loaduvm+0x36>
      n = PGSIZE;
801062cd:	be 00 10 00 00       	mov    $0x1000,%esi
801062d2:	eb aa                	jmp    8010627e <loaduvm+0x36>
      return -1;
  }
  return 0;
801062d4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801062d9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062dc:	5b                   	pop    %ebx
801062dd:	5e                   	pop    %esi
801062de:	5f                   	pop    %edi
801062df:	5d                   	pop    %ebp
801062e0:	c3                   	ret    
      return -1;
801062e1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801062e6:	eb f1                	jmp    801062d9 <loaduvm+0x91>

801062e8 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801062e8:	55                   	push   %ebp
801062e9:	89 e5                	mov    %esp,%ebp
801062eb:	57                   	push   %edi
801062ec:	56                   	push   %esi
801062ed:	53                   	push   %ebx
801062ee:	83 ec 0c             	sub    $0xc,%esp
801062f1:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801062f4:	39 7d 10             	cmp    %edi,0x10(%ebp)
801062f7:	73 11                	jae    8010630a <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801062f9:	8b 45 10             	mov    0x10(%ebp),%eax
801062fc:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106302:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106308:	eb 19                	jmp    80106323 <deallocuvm+0x3b>
    return oldsz;
8010630a:	89 f8                	mov    %edi,%eax
8010630c:	eb 64                	jmp    80106372 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010630e:	c1 eb 16             	shr    $0x16,%ebx
80106311:	83 c3 01             	add    $0x1,%ebx
80106314:	c1 e3 16             	shl    $0x16,%ebx
80106317:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010631d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106323:	39 fb                	cmp    %edi,%ebx
80106325:	73 48                	jae    8010636f <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106327:	b9 00 00 00 00       	mov    $0x0,%ecx
8010632c:	89 da                	mov    %ebx,%edx
8010632e:	8b 45 08             	mov    0x8(%ebp),%eax
80106331:	e8 42 fb ff ff       	call   80105e78 <walkpgdir>
80106336:	89 c6                	mov    %eax,%esi
    if(!pte)
80106338:	85 c0                	test   %eax,%eax
8010633a:	74 d2                	je     8010630e <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010633c:	8b 00                	mov    (%eax),%eax
8010633e:	a8 01                	test   $0x1,%al
80106340:	74 db                	je     8010631d <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106342:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106347:	74 19                	je     80106362 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
80106349:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010634e:	83 ec 0c             	sub    $0xc,%esp
80106351:	50                   	push   %eax
80106352:	e8 c0 bc ff ff       	call   80102017 <kfree>
      *pte = 0;
80106357:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010635d:	83 c4 10             	add    $0x10,%esp
80106360:	eb bb                	jmp    8010631d <deallocuvm+0x35>
        panic("kfree");
80106362:	83 ec 0c             	sub    $0xc,%esp
80106365:	68 cb 69 10 80       	push   $0x801069cb
8010636a:	e8 d9 9f ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
8010636f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106372:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106375:	5b                   	pop    %ebx
80106376:	5e                   	pop    %esi
80106377:	5f                   	pop    %edi
80106378:	5d                   	pop    %ebp
80106379:	c3                   	ret    

8010637a <allocuvm>:
{
8010637a:	55                   	push   %ebp
8010637b:	89 e5                	mov    %esp,%ebp
8010637d:	57                   	push   %edi
8010637e:	56                   	push   %esi
8010637f:	53                   	push   %ebx
80106380:	83 ec 28             	sub    $0x28,%esp
80106383:	8b 7d 10             	mov    0x10(%ebp),%edi
  cprintf("allocuvm\n");
80106386:	68 ed 70 10 80       	push   $0x801070ed
8010638b:	e8 7b a2 ff ff       	call   8010060b <cprintf>
  if(newsz >= KERNBASE)
80106390:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106393:	83 c4 10             	add    $0x10,%esp
80106396:	85 ff                	test   %edi,%edi
80106398:	0f 88 cf 00 00 00    	js     8010646d <allocuvm+0xf3>
  if(newsz < oldsz)
8010639e:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801063a1:	72 6a                	jb     8010640d <allocuvm+0x93>
  a = PGROUNDUP(oldsz);
801063a3:	8b 45 0c             	mov    0xc(%ebp),%eax
801063a6:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801063ac:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801063b2:	39 fb                	cmp    %edi,%ebx
801063b4:	0f 83 ba 00 00 00    	jae    80106474 <allocuvm+0xfa>
    mem = kalloc1(myproc()->pid);
801063ba:	e8 ec cf ff ff       	call   801033ab <myproc>
801063bf:	83 ec 0c             	sub    $0xc,%esp
801063c2:	ff 70 10             	pushl  0x10(%eax)
801063c5:	e8 ec be ff ff       	call   801022b6 <kalloc1>
801063ca:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801063cc:	83 c4 10             	add    $0x10,%esp
801063cf:	85 c0                	test   %eax,%eax
801063d1:	74 42                	je     80106415 <allocuvm+0x9b>
    memset(mem, 0, PGSIZE);
801063d3:	83 ec 04             	sub    $0x4,%esp
801063d6:	68 00 10 00 00       	push   $0x1000
801063db:	6a 00                	push   $0x0
801063dd:	50                   	push   %eax
801063de:	e8 df da ff ff       	call   80103ec2 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801063e3:	83 c4 08             	add    $0x8,%esp
801063e6:	6a 06                	push   $0x6
801063e8:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801063ee:	50                   	push   %eax
801063ef:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063f4:	89 da                	mov    %ebx,%edx
801063f6:	8b 45 08             	mov    0x8(%ebp),%eax
801063f9:	e8 ea fa ff ff       	call   80105ee8 <mappages>
801063fe:	83 c4 10             	add    $0x10,%esp
80106401:	85 c0                	test   %eax,%eax
80106403:	78 38                	js     8010643d <allocuvm+0xc3>
  for(; a < newsz; a += PGSIZE){
80106405:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010640b:	eb a5                	jmp    801063b2 <allocuvm+0x38>
    return oldsz;
8010640d:	8b 45 0c             	mov    0xc(%ebp),%eax
80106410:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106413:	eb 5f                	jmp    80106474 <allocuvm+0xfa>
      cprintf("allocuvm out of memory\n");
80106415:	83 ec 0c             	sub    $0xc,%esp
80106418:	68 f7 70 10 80       	push   $0x801070f7
8010641d:	e8 e9 a1 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106422:	83 c4 0c             	add    $0xc,%esp
80106425:	ff 75 0c             	pushl  0xc(%ebp)
80106428:	57                   	push   %edi
80106429:	ff 75 08             	pushl  0x8(%ebp)
8010642c:	e8 b7 fe ff ff       	call   801062e8 <deallocuvm>
      return 0;
80106431:	83 c4 10             	add    $0x10,%esp
80106434:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010643b:	eb 37                	jmp    80106474 <allocuvm+0xfa>
      cprintf("allocuvm out of memory (2)\n");
8010643d:	83 ec 0c             	sub    $0xc,%esp
80106440:	68 0f 71 10 80       	push   $0x8010710f
80106445:	e8 c1 a1 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010644a:	83 c4 0c             	add    $0xc,%esp
8010644d:	ff 75 0c             	pushl  0xc(%ebp)
80106450:	57                   	push   %edi
80106451:	ff 75 08             	pushl  0x8(%ebp)
80106454:	e8 8f fe ff ff       	call   801062e8 <deallocuvm>
      kfree(mem);
80106459:	89 34 24             	mov    %esi,(%esp)
8010645c:	e8 b6 bb ff ff       	call   80102017 <kfree>
      return 0;
80106461:	83 c4 10             	add    $0x10,%esp
80106464:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010646b:	eb 07                	jmp    80106474 <allocuvm+0xfa>
    return 0;
8010646d:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106474:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106477:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010647a:	5b                   	pop    %ebx
8010647b:	5e                   	pop    %esi
8010647c:	5f                   	pop    %edi
8010647d:	5d                   	pop    %ebp
8010647e:	c3                   	ret    

8010647f <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
8010647f:	55                   	push   %ebp
80106480:	89 e5                	mov    %esp,%ebp
80106482:	56                   	push   %esi
80106483:	53                   	push   %ebx
80106484:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106487:	85 f6                	test   %esi,%esi
80106489:	74 1a                	je     801064a5 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010648b:	83 ec 04             	sub    $0x4,%esp
8010648e:	6a 00                	push   $0x0
80106490:	68 00 00 00 80       	push   $0x80000000
80106495:	56                   	push   %esi
80106496:	e8 4d fe ff ff       	call   801062e8 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010649b:	83 c4 10             	add    $0x10,%esp
8010649e:	bb 00 00 00 00       	mov    $0x0,%ebx
801064a3:	eb 10                	jmp    801064b5 <freevm+0x36>
    panic("freevm: no pgdir");
801064a5:	83 ec 0c             	sub    $0xc,%esp
801064a8:	68 2b 71 10 80       	push   $0x8010712b
801064ad:	e8 96 9e ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801064b2:	83 c3 01             	add    $0x1,%ebx
801064b5:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801064bb:	77 1f                	ja     801064dc <freevm+0x5d>
    if(pgdir[i] & PTE_P){
801064bd:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801064c0:	a8 01                	test   $0x1,%al
801064c2:	74 ee                	je     801064b2 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801064c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801064c9:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801064ce:	83 ec 0c             	sub    $0xc,%esp
801064d1:	50                   	push   %eax
801064d2:	e8 40 bb ff ff       	call   80102017 <kfree>
801064d7:	83 c4 10             	add    $0x10,%esp
801064da:	eb d6                	jmp    801064b2 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801064dc:	83 ec 0c             	sub    $0xc,%esp
801064df:	56                   	push   %esi
801064e0:	e8 32 bb ff ff       	call   80102017 <kfree>
}
801064e5:	83 c4 10             	add    $0x10,%esp
801064e8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801064eb:	5b                   	pop    %ebx
801064ec:	5e                   	pop    %esi
801064ed:	5d                   	pop    %ebp
801064ee:	c3                   	ret    

801064ef <setupkvm>:
{
801064ef:	55                   	push   %ebp
801064f0:	89 e5                	mov    %esp,%ebp
801064f2:	56                   	push   %esi
801064f3:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc1(myproc()->pid)) == 0)
801064f4:	e8 b2 ce ff ff       	call   801033ab <myproc>
801064f9:	83 ec 0c             	sub    $0xc,%esp
801064fc:	ff 70 10             	pushl  0x10(%eax)
801064ff:	e8 b2 bd ff ff       	call   801022b6 <kalloc1>
80106504:	89 c6                	mov    %eax,%esi
80106506:	83 c4 10             	add    $0x10,%esp
80106509:	85 c0                	test   %eax,%eax
8010650b:	74 55                	je     80106562 <setupkvm+0x73>
  memset(pgdir, 0, PGSIZE);
8010650d:	83 ec 04             	sub    $0x4,%esp
80106510:	68 00 10 00 00       	push   $0x1000
80106515:	6a 00                	push   $0x0
80106517:	50                   	push   %eax
80106518:	e8 a5 d9 ff ff       	call   80103ec2 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010651d:	83 c4 10             	add    $0x10,%esp
80106520:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106525:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
8010652b:	73 35                	jae    80106562 <setupkvm+0x73>
                (uint)k->phys_start, k->perm) < 0) {
8010652d:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106530:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106533:	29 c1                	sub    %eax,%ecx
80106535:	83 ec 08             	sub    $0x8,%esp
80106538:	ff 73 0c             	pushl  0xc(%ebx)
8010653b:	50                   	push   %eax
8010653c:	8b 13                	mov    (%ebx),%edx
8010653e:	89 f0                	mov    %esi,%eax
80106540:	e8 a3 f9 ff ff       	call   80105ee8 <mappages>
80106545:	83 c4 10             	add    $0x10,%esp
80106548:	85 c0                	test   %eax,%eax
8010654a:	78 05                	js     80106551 <setupkvm+0x62>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010654c:	83 c3 10             	add    $0x10,%ebx
8010654f:	eb d4                	jmp    80106525 <setupkvm+0x36>
      freevm(pgdir);
80106551:	83 ec 0c             	sub    $0xc,%esp
80106554:	56                   	push   %esi
80106555:	e8 25 ff ff ff       	call   8010647f <freevm>
      return 0;
8010655a:	83 c4 10             	add    $0x10,%esp
8010655d:	be 00 00 00 00       	mov    $0x0,%esi
}
80106562:	89 f0                	mov    %esi,%eax
80106564:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106567:	5b                   	pop    %ebx
80106568:	5e                   	pop    %esi
80106569:	5d                   	pop    %ebp
8010656a:	c3                   	ret    

8010656b <kvmalloc>:
{
8010656b:	55                   	push   %ebp
8010656c:	89 e5                	mov    %esp,%ebp
8010656e:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106571:	e8 79 ff ff ff       	call   801064ef <setupkvm>
80106576:	a3 e4 54 13 80       	mov    %eax,0x801354e4
  switchkvm();
8010657b:	e8 2a fb ff ff       	call   801060aa <switchkvm>
}
80106580:	c9                   	leave  
80106581:	c3                   	ret    

80106582 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106582:	55                   	push   %ebp
80106583:	89 e5                	mov    %esp,%ebp
80106585:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106588:	b9 00 00 00 00       	mov    $0x0,%ecx
8010658d:	8b 55 0c             	mov    0xc(%ebp),%edx
80106590:	8b 45 08             	mov    0x8(%ebp),%eax
80106593:	e8 e0 f8 ff ff       	call   80105e78 <walkpgdir>
  if(pte == 0)
80106598:	85 c0                	test   %eax,%eax
8010659a:	74 05                	je     801065a1 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
8010659c:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010659f:	c9                   	leave  
801065a0:	c3                   	ret    
    panic("clearpteu");
801065a1:	83 ec 0c             	sub    $0xc,%esp
801065a4:	68 3c 71 10 80       	push   $0x8010713c
801065a9:	e8 9a 9d ff ff       	call   80100348 <panic>

801065ae <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801065ae:	55                   	push   %ebp
801065af:	89 e5                	mov    %esp,%ebp
801065b1:	57                   	push   %edi
801065b2:	56                   	push   %esi
801065b3:	53                   	push   %ebx
801065b4:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801065b7:	e8 33 ff ff ff       	call   801064ef <setupkvm>
801065bc:	89 45 dc             	mov    %eax,-0x24(%ebp)
801065bf:	85 c0                	test   %eax,%eax
801065c1:	0f 84 d2 00 00 00    	je     80106699 <copyuvm+0xeb>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801065c7:	bf 00 00 00 00       	mov    $0x0,%edi
801065cc:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801065cf:	0f 83 c4 00 00 00    	jae    80106699 <copyuvm+0xeb>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801065d5:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801065d8:	b9 00 00 00 00       	mov    $0x0,%ecx
801065dd:	89 fa                	mov    %edi,%edx
801065df:	8b 45 08             	mov    0x8(%ebp),%eax
801065e2:	e8 91 f8 ff ff       	call   80105e78 <walkpgdir>
801065e7:	85 c0                	test   %eax,%eax
801065e9:	74 73                	je     8010665e <copyuvm+0xb0>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801065eb:	8b 00                	mov    (%eax),%eax
801065ed:	a8 01                	test   $0x1,%al
801065ef:	74 7a                	je     8010666b <copyuvm+0xbd>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801065f1:	89 c6                	mov    %eax,%esi
801065f3:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
801065f9:	25 ff 0f 00 00       	and    $0xfff,%eax
801065fe:	89 45 e0             	mov    %eax,-0x20(%ebp)
    //if((mem = kalloc()) == 0)
    if((mem = kalloc1(myproc()->pid)) == 0)
80106601:	e8 a5 cd ff ff       	call   801033ab <myproc>
80106606:	83 ec 0c             	sub    $0xc,%esp
80106609:	ff 70 10             	pushl  0x10(%eax)
8010660c:	e8 a5 bc ff ff       	call   801022b6 <kalloc1>
80106611:	89 c3                	mov    %eax,%ebx
80106613:	83 c4 10             	add    $0x10,%esp
80106616:	85 c0                	test   %eax,%eax
80106618:	74 6a                	je     80106684 <copyuvm+0xd6>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
8010661a:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80106620:	83 ec 04             	sub    $0x4,%esp
80106623:	68 00 10 00 00       	push   $0x1000
80106628:	56                   	push   %esi
80106629:	50                   	push   %eax
8010662a:	e8 0e d9 ff ff       	call   80103f3d <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010662f:	83 c4 08             	add    $0x8,%esp
80106632:	ff 75 e0             	pushl  -0x20(%ebp)
80106635:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010663b:	50                   	push   %eax
8010663c:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106641:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106644:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106647:	e8 9c f8 ff ff       	call   80105ee8 <mappages>
8010664c:	83 c4 10             	add    $0x10,%esp
8010664f:	85 c0                	test   %eax,%eax
80106651:	78 25                	js     80106678 <copyuvm+0xca>
  for(i = 0; i < sz; i += PGSIZE){
80106653:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106659:	e9 6e ff ff ff       	jmp    801065cc <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
8010665e:	83 ec 0c             	sub    $0xc,%esp
80106661:	68 46 71 10 80       	push   $0x80107146
80106666:	e8 dd 9c ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
8010666b:	83 ec 0c             	sub    $0xc,%esp
8010666e:	68 60 71 10 80       	push   $0x80107160
80106673:	e8 d0 9c ff ff       	call   80100348 <panic>
      kfree(mem);
80106678:	83 ec 0c             	sub    $0xc,%esp
8010667b:	53                   	push   %ebx
8010667c:	e8 96 b9 ff ff       	call   80102017 <kfree>
      goto bad;
80106681:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106684:	83 ec 0c             	sub    $0xc,%esp
80106687:	ff 75 dc             	pushl  -0x24(%ebp)
8010668a:	e8 f0 fd ff ff       	call   8010647f <freevm>
  return 0;
8010668f:	83 c4 10             	add    $0x10,%esp
80106692:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106699:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010669c:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010669f:	5b                   	pop    %ebx
801066a0:	5e                   	pop    %esi
801066a1:	5f                   	pop    %edi
801066a2:	5d                   	pop    %ebp
801066a3:	c3                   	ret    

801066a4 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801066a4:	55                   	push   %ebp
801066a5:	89 e5                	mov    %esp,%ebp
801066a7:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801066aa:	b9 00 00 00 00       	mov    $0x0,%ecx
801066af:	8b 55 0c             	mov    0xc(%ebp),%edx
801066b2:	8b 45 08             	mov    0x8(%ebp),%eax
801066b5:	e8 be f7 ff ff       	call   80105e78 <walkpgdir>
  if((*pte & PTE_P) == 0)
801066ba:	8b 00                	mov    (%eax),%eax
801066bc:	a8 01                	test   $0x1,%al
801066be:	74 10                	je     801066d0 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
801066c0:	a8 04                	test   $0x4,%al
801066c2:	74 13                	je     801066d7 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801066c4:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801066c9:	05 00 00 00 80       	add    $0x80000000,%eax
}
801066ce:	c9                   	leave  
801066cf:	c3                   	ret    
    return 0;
801066d0:	b8 00 00 00 00       	mov    $0x0,%eax
801066d5:	eb f7                	jmp    801066ce <uva2ka+0x2a>
    return 0;
801066d7:	b8 00 00 00 00       	mov    $0x0,%eax
801066dc:	eb f0                	jmp    801066ce <uva2ka+0x2a>

801066de <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801066de:	55                   	push   %ebp
801066df:	89 e5                	mov    %esp,%ebp
801066e1:	57                   	push   %edi
801066e2:	56                   	push   %esi
801066e3:	53                   	push   %ebx
801066e4:	83 ec 0c             	sub    $0xc,%esp
801066e7:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801066ea:	eb 25                	jmp    80106711 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801066ec:	8b 55 0c             	mov    0xc(%ebp),%edx
801066ef:	29 f2                	sub    %esi,%edx
801066f1:	01 d0                	add    %edx,%eax
801066f3:	83 ec 04             	sub    $0x4,%esp
801066f6:	53                   	push   %ebx
801066f7:	ff 75 10             	pushl  0x10(%ebp)
801066fa:	50                   	push   %eax
801066fb:	e8 3d d8 ff ff       	call   80103f3d <memmove>
    len -= n;
80106700:	29 df                	sub    %ebx,%edi
    buf += n;
80106702:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106705:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
8010670b:	89 45 0c             	mov    %eax,0xc(%ebp)
8010670e:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106711:	85 ff                	test   %edi,%edi
80106713:	74 2f                	je     80106744 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106715:	8b 75 0c             	mov    0xc(%ebp),%esi
80106718:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
8010671e:	83 ec 08             	sub    $0x8,%esp
80106721:	56                   	push   %esi
80106722:	ff 75 08             	pushl  0x8(%ebp)
80106725:	e8 7a ff ff ff       	call   801066a4 <uva2ka>
    if(pa0 == 0)
8010672a:	83 c4 10             	add    $0x10,%esp
8010672d:	85 c0                	test   %eax,%eax
8010672f:	74 20                	je     80106751 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106731:	89 f3                	mov    %esi,%ebx
80106733:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106736:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
8010673c:	39 df                	cmp    %ebx,%edi
8010673e:	73 ac                	jae    801066ec <copyout+0xe>
      n = len;
80106740:	89 fb                	mov    %edi,%ebx
80106742:	eb a8                	jmp    801066ec <copyout+0xe>
  }
  return 0;
80106744:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106749:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010674c:	5b                   	pop    %ebx
8010674d:	5e                   	pop    %esi
8010674e:	5f                   	pop    %edi
8010674f:	5d                   	pop    %ebp
80106750:	c3                   	ret    
      return -1;
80106751:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106756:	eb f1                	jmp    80106749 <copyout+0x6b>
