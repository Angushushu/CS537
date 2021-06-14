
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
80100015:	b8 00 80 10 00       	mov    $0x108000,%eax
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
80100028:	bc d0 a5 10 80       	mov    $0x8010a5d0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 a6 2a 10 80       	mov    $0x80102aa6,%eax
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
80100041:	68 e0 a5 10 80       	push   $0x8010a5e0
80100046:	e8 8c 3b 00 00       	call   80103bd7 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 30 ed 10 80    	mov    0x8010ed30,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb dc ec 10 80    	cmp    $0x8010ecdc,%ebx
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
80100077:	68 e0 a5 10 80       	push   $0x8010a5e0
8010007c:	e8 bb 3b 00 00       	call   80103c3c <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 37 39 00 00       	call   801039c3 <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 2c ed 10 80    	mov    0x8010ed2c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb dc ec 10 80    	cmp    $0x8010ecdc,%ebx
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
801000c5:	68 e0 a5 10 80       	push   $0x8010a5e0
801000ca:	e8 6d 3b 00 00       	call   80103c3c <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 e9 38 00 00       	call   801039c3 <acquiresleep>
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
801000ea:	68 00 65 10 80       	push   $0x80106500
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 11 65 10 80       	push   $0x80106511
80100100:	68 e0 a5 10 80       	push   $0x8010a5e0
80100105:	e8 91 39 00 00       	call   80103a9b <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 2c ed 10 80 dc 	movl   $0x8010ecdc,0x8010ed2c
80100111:	ec 10 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 30 ed 10 80 dc 	movl   $0x8010ecdc,0x8010ed30
8010011b:	ec 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb 14 a6 10 80       	mov    $0x8010a614,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 30 ed 10 80       	mov    0x8010ed30,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 dc ec 10 80 	movl   $0x8010ecdc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 18 65 10 80       	push   $0x80106518
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 48 38 00 00       	call   80103990 <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 30 ed 10 80       	mov    0x8010ed30,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 30 ed 10 80    	mov    %ebx,0x8010ed30
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb dc ec 10 80    	cmp    $0x8010ecdc,%ebx
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
801001a8:	e8 a0 38 00 00       	call   80103a4d <holdingsleep>
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
801001cb:	68 1f 65 10 80       	push   $0x8010651f
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
801001e4:	e8 64 38 00 00       	call   80103a4d <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 19 38 00 00       	call   80103a12 <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 e0 a5 10 80 	movl   $0x8010a5e0,(%esp)
80100200:	e8 d2 39 00 00       	call   80103bd7 <acquire>
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
80100227:	a1 30 ed 10 80       	mov    0x8010ed30,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 dc ec 10 80 	movl   $0x8010ecdc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 30 ed 10 80       	mov    0x8010ed30,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 30 ed 10 80    	mov    %ebx,0x8010ed30
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 e0 a5 10 80       	push   $0x8010a5e0
8010024c:	e8 eb 39 00 00       	call   80103c3c <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 26 65 10 80       	push   $0x80106526
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
80100283:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
8010028a:	e8 48 39 00 00       	call   80103bd7 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 c0 ef 10 80       	mov    0x8010efc0,%eax
8010029f:	3b 05 c4 ef 10 80    	cmp    0x8010efc4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 8c 2f 00 00       	call   80103238 <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 95 10 80       	push   $0x80109520
801002ba:	68 c0 ef 10 80       	push   $0x8010efc0
801002bf:	e8 18 34 00 00       	call   801036dc <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 95 10 80       	push   $0x80109520
801002d1:	e8 66 39 00 00       	call   80103c3c <release>
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
801002f1:	89 15 c0 ef 10 80    	mov    %edx,0x8010efc0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 40 ef 10 80 	movzbl -0x7fef10c0(%edx),%ecx
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
80100324:	a3 c0 ef 10 80       	mov    %eax,0x8010efc0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 95 10 80       	push   $0x80109520
80100331:	e8 06 39 00 00       	call   80103c3c <release>
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
80100350:	c7 05 54 95 10 80 00 	movl   $0x0,0x80109554
80100357:	00 00 00 
  cprintf("lapicid %d: panic: ", lapicid());
8010035a:	e8 61 20 00 00       	call   801023c0 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 2d 65 10 80       	push   $0x8010652d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 9f 6e 10 80 	movl   $0x80106e9f,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 22 37 00 00       	call   80103ab6 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 41 65 10 80       	push   $0x80106541
801003aa:	e8 5c 02 00 00       	call   8010060b <cprintf>
  for(i=0; i<10; i++)
801003af:	83 c3 01             	add    $0x1,%ebx
801003b2:	83 c4 10             	add    $0x10,%esp
801003b5:	83 fb 09             	cmp    $0x9,%ebx
801003b8:	7e e4                	jle    8010039e <panic+0x56>
  panicked = 1; // freeze other CPU
801003ba:	c7 05 58 95 10 80 01 	movl   $0x1,0x80109558
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
8010049e:	68 45 65 10 80       	push   $0x80106545
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 3f 38 00 00       	call   80103cfe <memmove>
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
801004d9:	e8 a5 37 00 00       	call   80103c83 <memset>
801004de:	83 c4 10             	add    $0x10,%esp
801004e1:	e9 4c ff ff ff       	jmp    80100432 <cgaputc+0x6c>

801004e6 <consputc>:
  if(panicked){
801004e6:	83 3d 58 95 10 80 00 	cmpl   $0x0,0x80109558
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
80100506:	e8 d6 4b 00 00       	call   801050e1 <uartputc>
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
8010051f:	e8 bd 4b 00 00       	call   801050e1 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 b1 4b 00 00       	call   801050e1 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 a5 4b 00 00       	call   801050e1 <uartputc>
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
80100576:	0f b6 92 70 65 10 80 	movzbl -0x7fef9a90(%edx),%edx
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
801005c3:	c7 04 24 20 95 10 80 	movl   $0x80109520,(%esp)
801005ca:	e8 08 36 00 00       	call   80103bd7 <acquire>
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
801005ec:	68 20 95 10 80       	push   $0x80109520
801005f1:	e8 46 36 00 00       	call   80103c3c <release>
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
80100614:	a1 54 95 10 80       	mov    0x80109554,%eax
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
80100633:	68 20 95 10 80       	push   $0x80109520
80100638:	e8 9a 35 00 00       	call   80103bd7 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 5f 65 10 80       	push   $0x8010655f
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
801006ee:	be 58 65 10 80       	mov    $0x80106558,%esi
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
8010072f:	68 20 95 10 80       	push   $0x80109520
80100734:	e8 03 35 00 00       	call   80103c3c <release>
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
8010074a:	68 20 95 10 80       	push   $0x80109520
8010074f:	e8 83 34 00 00       	call   80103bd7 <acquire>
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
80100772:	a1 c8 ef 10 80       	mov    0x8010efc8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 c0 ef 10 80    	sub    0x8010efc0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 c8 ef 10 80    	mov    %edx,0x8010efc8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 40 ef 10 80    	mov    %cl,-0x7fef10c0(%eax)
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
801007bc:	a1 c0 ef 10 80       	mov    0x8010efc0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 c8 ef 10 80    	cmp    %eax,0x8010efc8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 c8 ef 10 80       	mov    0x8010efc8,%eax
801007d1:	a3 c4 ef 10 80       	mov    %eax,0x8010efc4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 c0 ef 10 80       	push   $0x8010efc0
801007de:	e8 5e 30 00 00       	call   80103841 <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 c8 ef 10 80       	mov    %eax,0x8010efc8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 c8 ef 10 80       	mov    0x8010efc8,%eax
801007fc:	3b 05 c4 ef 10 80    	cmp    0x8010efc4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 40 ef 10 80 0a 	cmpb   $0xa,-0x7fef10c0(%edx)
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
8010084a:	a1 c8 ef 10 80       	mov    0x8010efc8,%eax
8010084f:	3b 05 c4 ef 10 80    	cmp    0x8010efc4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 c8 ef 10 80       	mov    %eax,0x8010efc8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 95 10 80       	push   $0x80109520
80100873:	e8 c4 33 00 00       	call   80103c3c <release>
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
80100887:	e8 52 30 00 00       	call   801038de <procdump>
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
80100894:	68 68 65 10 80       	push   $0x80106568
80100899:	68 20 95 10 80       	push   $0x80109520
8010089e:	e8 f8 31 00 00       	call   80103a9b <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 8c f9 10 80 ac 	movl   $0x801005ac,0x8010f98c
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 88 f9 10 80 68 	movl   $0x80100268,0x8010f988
801008b4:	02 10 80 
  cons.locking = 1;
801008b7:	c7 05 54 95 10 80 01 	movl   $0x1,0x80109554
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
801008de:	e8 55 29 00 00       	call   80103238 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 02 1f 00 00       	call   801027f0 <begin_op>

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
80100935:	e8 30 1f 00 00       	call   8010286a <end_op>
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
8010094a:	e8 1b 1f 00 00       	call   8010286a <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 81 65 10 80       	push   $0x80106581
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
80100972:	e8 2a 59 00 00       	call   801062a1 <setupkvm>
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
80100a06:	e8 3c 57 00 00       	call   80106147 <allocuvm>
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
80100a38:	e8 d8 55 00 00       	call   80106015 <loaduvm>
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
80100a53:	e8 12 1e 00 00       	call   8010286a <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 ce 56 00 00       	call   80106147 <allocuvm>
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
80100a9d:	e8 8f 57 00 00       	call   80106231 <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 65 58 00 00       	call   80106326 <clearpteu>
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
80100ae2:	e8 3e 33 00 00       	call   80103e25 <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 2c 33 00 00       	call   80103e25 <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 69 59 00 00       	call   80106474 <copyout>
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
80100b66:	e8 09 59 00 00       	call   80106474 <copyout>
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
80100ba3:	e8 42 32 00 00       	call   80103dea <safestrcpy>
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
80100bd1:	e8 be 52 00 00       	call   80105e94 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 53 56 00 00       	call   80106231 <freevm>
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
80100c19:	68 8d 65 10 80       	push   $0x8010658d
80100c1e:	68 e0 ef 10 80       	push   $0x8010efe0
80100c23:	e8 73 2e 00 00       	call   80103a9b <initlock>
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
80100c34:	68 e0 ef 10 80       	push   $0x8010efe0
80100c39:	e8 99 2f 00 00       	call   80103bd7 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c3e:	83 c4 10             	add    $0x10,%esp
80100c41:	bb 14 f0 10 80       	mov    $0x8010f014,%ebx
80100c46:	81 fb 74 f9 10 80    	cmp    $0x8010f974,%ebx
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
80100c63:	68 e0 ef 10 80       	push   $0x8010efe0
80100c68:	e8 cf 2f 00 00       	call   80103c3c <release>
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
80100c7a:	68 e0 ef 10 80       	push   $0x8010efe0
80100c7f:	e8 b8 2f 00 00       	call   80103c3c <release>
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
80100c98:	68 e0 ef 10 80       	push   $0x8010efe0
80100c9d:	e8 35 2f 00 00       	call   80103bd7 <acquire>
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
80100cb5:	68 e0 ef 10 80       	push   $0x8010efe0
80100cba:	e8 7d 2f 00 00       	call   80103c3c <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 94 65 10 80       	push   $0x80106594
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
80100cdd:	68 e0 ef 10 80       	push   $0x8010efe0
80100ce2:	e8 f0 2e 00 00       	call   80103bd7 <acquire>
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
80100cfe:	68 e0 ef 10 80       	push   $0x8010efe0
80100d03:	e8 34 2f 00 00       	call   80103c3c <release>
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
80100d13:	68 9c 65 10 80       	push   $0x8010659c
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
80100d44:	68 e0 ef 10 80       	push   $0x8010efe0
80100d49:	e8 ee 2e 00 00       	call   80103c3c <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 8d 1a 00 00       	call   801027f0 <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 f7 1a 00 00       	call   8010286a <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 dc 20 00 00       	call   80102e64 <pipeclose>
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
80100e3c:	e8 7b 21 00 00       	call   80102fbc <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 a6 65 10 80       	push   $0x801065a6
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
80100e95:	e8 56 20 00 00       	call   80102ef0 <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 49 19 00 00       	call   801027f0 <begin_op>
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
80100edd:	e8 88 19 00 00       	call   8010286a <end_op>

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
80100f10:	68 af 65 10 80       	push   $0x801065af
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
80100f2d:	68 b5 65 10 80       	push   $0x801065b5
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
80100f8a:	e8 6f 2d 00 00       	call   80103cfe <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 5f 2d 00 00       	call   80103cfe <memmove>
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
80100fdf:	e8 9f 2c 00 00       	call   80103c83 <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 2d 19 00 00       	call   80102919 <log_write>
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
80101023:	39 35 e0 f9 10 80    	cmp    %esi,0x8010f9e0
80101029:	76 75                	jbe    801010a0 <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
8010102b:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80101031:	85 f6                	test   %esi,%esi
80101033:	0f 49 c6             	cmovns %esi,%eax
80101036:	c1 f8 0c             	sar    $0xc,%eax
80101039:	03 05 f8 f9 10 80    	add    0x8010f9f8,%eax
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
80101063:	3b 1d e0 f9 10 80    	cmp    0x8010f9e0,%ebx
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
801010a3:	68 bf 65 10 80       	push   $0x801065bf
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
801010bf:	e8 55 18 00 00       	call   80102919 <log_write>
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
80101170:	e8 a4 17 00 00       	call   80102919 <log_write>
80101175:	83 c4 10             	add    $0x10,%esp
80101178:	eb bf                	jmp    80101139 <bmap+0x58>
  panic("bmap: out of range");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 d5 65 10 80       	push   $0x801065d5
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
80101195:	68 00 fa 10 80       	push   $0x8010fa00
8010119a:	e8 38 2a 00 00       	call   80103bd7 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010119f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011a2:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011a7:	bb 34 fa 10 80       	mov    $0x8010fa34,%ebx
801011ac:	eb 0a                	jmp    801011b8 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ae:	85 f6                	test   %esi,%esi
801011b0:	74 3b                	je     801011ed <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011b2:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011b8:	81 fb 54 16 11 80    	cmp    $0x80111654,%ebx
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
801011dc:	68 00 fa 10 80       	push   $0x8010fa00
801011e1:	e8 56 2a 00 00       	call   80103c3c <release>
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
80101212:	68 00 fa 10 80       	push   $0x8010fa00
80101217:	e8 20 2a 00 00       	call   80103c3c <release>
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
8010122c:	68 e8 65 10 80       	push   $0x801065e8
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
80101255:	e8 a4 2a 00 00       	call   80103cfe <memmove>
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
80101276:	68 e0 f9 10 80       	push   $0x8010f9e0
8010127b:	50                   	push   %eax
8010127c:	e8 b5 ff ff ff       	call   80101236 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101281:	89 d8                	mov    %ebx,%eax
80101283:	c1 e8 0c             	shr    $0xc,%eax
80101286:	03 05 f8 f9 10 80    	add    0x8010f9f8,%eax
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
801012c8:	e8 4c 16 00 00       	call   80102919 <log_write>
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
801012e2:	68 f8 65 10 80       	push   $0x801065f8
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 0b 66 10 80       	push   $0x8010660b
801012f8:	68 00 fa 10 80       	push   $0x8010fa00
801012fd:	e8 99 27 00 00       	call   80103a9b <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 12 66 10 80       	push   $0x80106612
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 40 fa 10 80       	add    $0x8010fa40,%eax
80101321:	50                   	push   %eax
80101322:	e8 69 26 00 00       	call   80103990 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101327:	83 c3 01             	add    $0x1,%ebx
8010132a:	83 c4 10             	add    $0x10,%esp
8010132d:	83 fb 31             	cmp    $0x31,%ebx
80101330:	7e da                	jle    8010130c <iinit+0x20>
  readsb(dev, &sb);
80101332:	83 ec 08             	sub    $0x8,%esp
80101335:	68 e0 f9 10 80       	push   $0x8010f9e0
8010133a:	ff 75 08             	pushl  0x8(%ebp)
8010133d:	e8 f4 fe ff ff       	call   80101236 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101342:	ff 35 f8 f9 10 80    	pushl  0x8010f9f8
80101348:	ff 35 f4 f9 10 80    	pushl  0x8010f9f4
8010134e:	ff 35 f0 f9 10 80    	pushl  0x8010f9f0
80101354:	ff 35 ec f9 10 80    	pushl  0x8010f9ec
8010135a:	ff 35 e8 f9 10 80    	pushl  0x8010f9e8
80101360:	ff 35 e4 f9 10 80    	pushl  0x8010f9e4
80101366:	ff 35 e0 f9 10 80    	pushl  0x8010f9e0
8010136c:	68 78 66 10 80       	push   $0x80106678
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
80101395:	39 1d e8 f9 10 80    	cmp    %ebx,0x8010f9e8
8010139b:	76 3f                	jbe    801013dc <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010139d:	89 d8                	mov    %ebx,%eax
8010139f:	c1 e8 03             	shr    $0x3,%eax
801013a2:	03 05 f4 f9 10 80    	add    0x8010f9f4,%eax
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
801013df:	68 18 66 10 80       	push   $0x80106618
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 8d 28 00 00       	call   80103c83 <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 14 15 00 00       	call   80102919 <log_write>
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
8010142e:	03 05 f4 f9 10 80    	add    0x8010f9f4,%eax
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
80101480:	e8 79 28 00 00       	call   80103cfe <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 8c 14 00 00       	call   80102919 <log_write>
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
8010155b:	68 00 fa 10 80       	push   $0x8010fa00
80101560:	e8 72 26 00 00       	call   80103bd7 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 00 fa 10 80 	movl   $0x8010fa00,(%esp)
80101575:	e8 c2 26 00 00       	call   80103c3c <release>
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
8010159a:	e8 24 24 00 00       	call   801039c3 <acquiresleep>
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
801015b2:	68 2a 66 10 80       	push   $0x8010662a
801015b7:	e8 8c ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015bc:	8b 43 04             	mov    0x4(%ebx),%eax
801015bf:	c1 e8 03             	shr    $0x3,%eax
801015c2:	03 05 f4 f9 10 80    	add    0x8010f9f4,%eax
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
80101614:	e8 e5 26 00 00       	call   80103cfe <memmove>
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
80101639:	68 30 66 10 80       	push   $0x80106630
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
80101656:	e8 f2 23 00 00       	call   80103a4d <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 a1 23 00 00       	call   80103a12 <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 3f 66 10 80       	push   $0x8010663f
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
80101698:	e8 26 23 00 00       	call   801039c3 <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 5c 23 00 00       	call   80103a12 <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 00 fa 10 80 	movl   $0x8010fa00,(%esp)
801016bd:	e8 15 25 00 00       	call   80103bd7 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 00 fa 10 80 	movl   $0x8010fa00,(%esp)
801016d2:	e8 65 25 00 00       	call   80103c3c <release>
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
801016e5:	68 00 fa 10 80       	push   $0x8010fa00
801016ea:	e8 e8 24 00 00       	call   80103bd7 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 00 fa 10 80 	movl   $0x8010fa00,(%esp)
801016f9:	e8 3e 25 00 00       	call   80103c3c <release>
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
801017c4:	8b 04 c5 80 f9 10 80 	mov    -0x7fef0680(,%eax,8),%eax
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
8010182a:	e8 cf 24 00 00       	call   80103cfe <memmove>
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
801018c1:	8b 04 c5 84 f9 10 80 	mov    -0x7fef067c(,%eax,8),%eax
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
80101926:	e8 d3 23 00 00       	call   80103cfe <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 e6 0f 00 00       	call   80102919 <log_write>
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
801019a9:	e8 b7 23 00 00       	call   80103d65 <strncmp>
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
801019d0:	68 47 66 10 80       	push   $0x80106647
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 59 66 10 80       	push   $0x80106659
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
80101a5a:	e8 d9 17 00 00       	call   80103238 <myproc>
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
80101b92:	68 68 66 10 80       	push   $0x80106668
80101b97:	e8 ac e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b9c:	83 ec 04             	sub    $0x4,%esp
80101b9f:	6a 0e                	push   $0xe
80101ba1:	57                   	push   %edi
80101ba2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101ba5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ba8:	50                   	push   %eax
80101ba9:	e8 f4 21 00 00       	call   80103da2 <strncpy>
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
80101bd7:	68 74 6c 10 80       	push   $0x80106c74
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
80101ccc:	68 cb 66 10 80       	push   $0x801066cb
80101cd1:	e8 72 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 d4 66 10 80       	push   $0x801066d4
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
80101d06:	68 e6 66 10 80       	push   $0x801066e6
80101d0b:	68 80 95 10 80       	push   $0x80109580
80101d10:	e8 86 1d 00 00       	call   80103a9b <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d15:	83 c4 08             	add    $0x8,%esp
80101d18:	a1 40 9d 16 80       	mov    0x80169d40,%eax
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
80101d5c:	c7 05 60 95 10 80 01 	movl   $0x1,0x80109560
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
80101d7b:	68 80 95 10 80       	push   $0x80109580
80101d80:	e8 52 1e 00 00       	call   80103bd7 <acquire>

  if((b = idequeue) == 0){
80101d85:	8b 1d 64 95 10 80    	mov    0x80109564,%ebx
80101d8b:	83 c4 10             	add    $0x10,%esp
80101d8e:	85 db                	test   %ebx,%ebx
80101d90:	74 48                	je     80101dda <ideintr+0x67>
    release(&idelock);
    return;
  }
  idequeue = b->qnext;
80101d92:	8b 43 58             	mov    0x58(%ebx),%eax
80101d95:	a3 64 95 10 80       	mov    %eax,0x80109564

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
80101dad:	e8 8f 1a 00 00       	call   80103841 <wakeup>

  // Start disk on next buf in queue.
  if(idequeue != 0)
80101db2:	a1 64 95 10 80       	mov    0x80109564,%eax
80101db7:	83 c4 10             	add    $0x10,%esp
80101dba:	85 c0                	test   %eax,%eax
80101dbc:	74 05                	je     80101dc3 <ideintr+0x50>
    idestart(idequeue);
80101dbe:	e8 80 fe ff ff       	call   80101c43 <idestart>

  release(&idelock);
80101dc3:	83 ec 0c             	sub    $0xc,%esp
80101dc6:	68 80 95 10 80       	push   $0x80109580
80101dcb:	e8 6c 1e 00 00       	call   80103c3c <release>
80101dd0:	83 c4 10             	add    $0x10,%esp
}
80101dd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101dd6:	5b                   	pop    %ebx
80101dd7:	5f                   	pop    %edi
80101dd8:	5d                   	pop    %ebp
80101dd9:	c3                   	ret    
    release(&idelock);
80101dda:	83 ec 0c             	sub    $0xc,%esp
80101ddd:	68 80 95 10 80       	push   $0x80109580
80101de2:	e8 55 1e 00 00       	call   80103c3c <release>
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
80101e1a:	e8 2e 1c 00 00       	call   80103a4d <holdingsleep>
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
80101e36:	83 3d 60 95 10 80 00 	cmpl   $0x0,0x80109560
80101e3d:	74 38                	je     80101e77 <iderw+0x6b>
    panic("iderw: ide disk 1 not present");

  acquire(&idelock);  //DOC:acquire-lock
80101e3f:	83 ec 0c             	sub    $0xc,%esp
80101e42:	68 80 95 10 80       	push   $0x80109580
80101e47:	e8 8b 1d 00 00       	call   80103bd7 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e4c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	ba 64 95 10 80       	mov    $0x80109564,%edx
80101e5b:	eb 2a                	jmp    80101e87 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e5d:	83 ec 0c             	sub    $0xc,%esp
80101e60:	68 ea 66 10 80       	push   $0x801066ea
80101e65:	e8 de e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 00 67 10 80       	push   $0x80106700
80101e72:	e8 d1 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e77:	83 ec 0c             	sub    $0xc,%esp
80101e7a:	68 15 67 10 80       	push   $0x80106715
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
80101e8f:	39 1d 64 95 10 80    	cmp    %ebx,0x80109564
80101e95:	75 1a                	jne    80101eb1 <iderw+0xa5>
    idestart(b);
80101e97:	89 d8                	mov    %ebx,%eax
80101e99:	e8 a5 fd ff ff       	call   80101c43 <idestart>
80101e9e:	eb 11                	jmp    80101eb1 <iderw+0xa5>

  // Wait for request to finish.
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
    sleep(b, &idelock);
80101ea0:	83 ec 08             	sub    $0x8,%esp
80101ea3:	68 80 95 10 80       	push   $0x80109580
80101ea8:	53                   	push   %ebx
80101ea9:	e8 2e 18 00 00       	call   801036dc <sleep>
80101eae:	83 c4 10             	add    $0x10,%esp
  while((b->flags & (B_VALID|B_DIRTY)) != B_VALID){
80101eb1:	8b 03                	mov    (%ebx),%eax
80101eb3:	83 e0 06             	and    $0x6,%eax
80101eb6:	83 f8 02             	cmp    $0x2,%eax
80101eb9:	75 e5                	jne    80101ea0 <iderw+0x94>
  }


  release(&idelock);
80101ebb:	83 ec 0c             	sub    $0xc,%esp
80101ebe:	68 80 95 10 80       	push   $0x80109580
80101ec3:	e8 74 1d 00 00       	call   80103c3c <release>
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
80101ed3:	8b 15 54 16 11 80    	mov    0x80111654,%edx
80101ed9:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101edb:	a1 54 16 11 80       	mov    0x80111654,%eax
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
80101ee8:	8b 0d 54 16 11 80    	mov    0x80111654,%ecx
80101eee:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ef0:	a1 54 16 11 80       	mov    0x80111654,%eax
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
80101f03:	c7 05 54 16 11 80 00 	movl   $0xfec00000,0x80111654
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
80101f2a:	0f b6 15 a0 97 16 80 	movzbl 0x801697a0,%edx
80101f31:	39 c2                	cmp    %eax,%edx
80101f33:	75 07                	jne    80101f3c <ioapicinit+0x42>
{
80101f35:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f3a:	eb 36                	jmp    80101f72 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f3c:	83 ec 0c             	sub    $0xc,%esp
80101f3f:	68 34 67 10 80       	push   $0x80106734
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
80101fb6:	81 fb e8 c4 16 80    	cmp    $0x8016c4e8,%ebx
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
80101fd6:	e8 a8 1c 00 00       	call   80103c83 <memset>

  if(kmem.use_lock)
80101fdb:	83 c4 10             	add    $0x10,%esp
80101fde:	83 3d 94 16 11 80 00 	cmpl   $0x0,0x80111694
80101fe5:	75 28                	jne    8010200f <kfree+0x6b>
    acquire(&kmem.lock);
  r = (struct run*)v;
  r->next = kmem.freelist;         
80101fe7:	a1 98 16 11 80       	mov    0x80111698,%eax
80101fec:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fee:	89 1d 98 16 11 80    	mov    %ebx,0x80111698
  if(kmem.use_lock)
80101ff4:	83 3d 94 16 11 80 00 	cmpl   $0x0,0x80111694
80101ffb:	75 24                	jne    80102021 <kfree+0x7d>
    release(&kmem.lock);
}
80101ffd:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102000:	c9                   	leave  
80102001:	c3                   	ret    
    panic("kfree");
80102002:	83 ec 0c             	sub    $0xc,%esp
80102005:	68 66 67 10 80       	push   $0x80106766
8010200a:	e8 39 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
80102012:	68 60 16 11 80       	push   $0x80111660
80102017:	e8 bb 1b 00 00       	call   80103bd7 <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 60 16 11 80       	push   $0x80111660
80102029:	e8 0e 1c 00 00       	call   80103c3c <release>
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
8010206f:	68 6c 67 10 80       	push   $0x8010676c
80102074:	68 60 16 11 80       	push   $0x80111660
80102079:	e8 1d 1a 00 00       	call   80103a9b <initlock>
  kmem.use_lock = 0;
8010207e:	c7 05 94 16 11 80 00 	movl   $0x0,0x80111694
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
801020ac:	c7 05 94 16 11 80 01 	movl   $0x1,0x80111694
801020b3:	00 00 00 
}
801020b6:	83 c4 10             	add    $0x10,%esp
801020b9:	c9                   	leave  
801020ba:	c3                   	ret    

801020bb <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020bb:	55                   	push   %ebp
801020bc:	89 e5                	mov    %esp,%ebp
801020be:	53                   	push   %ebx
801020bf:	83 ec 04             	sub    $0x4,%esp
  struct run *r;

  if(kmem.use_lock)
801020c2:	83 3d 94 16 11 80 00 	cmpl   $0x0,0x80111694
801020c9:	75 21                	jne    801020ec <kalloc+0x31>
    acquire(&kmem.lock);
  r = kmem.freelist;
801020cb:	8b 1d 98 16 11 80    	mov    0x80111698,%ebx
  if(r)
801020d1:	85 db                	test   %ebx,%ebx
801020d3:	74 07                	je     801020dc <kalloc+0x21>
    kmem.freelist = r->next;
801020d5:	8b 03                	mov    (%ebx),%eax
801020d7:	a3 98 16 11 80       	mov    %eax,0x80111698

  if(kmem.use_lock)
801020dc:	83 3d 94 16 11 80 00 	cmpl   $0x0,0x80111694
801020e3:	75 19                	jne    801020fe <kalloc+0x43>
    release(&kmem.lock);
  return (char*)r;
}
801020e5:	89 d8                	mov    %ebx,%eax
801020e7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801020ea:	c9                   	leave  
801020eb:	c3                   	ret    
    acquire(&kmem.lock);
801020ec:	83 ec 0c             	sub    $0xc,%esp
801020ef:	68 60 16 11 80       	push   $0x80111660
801020f4:	e8 de 1a 00 00       	call   80103bd7 <acquire>
801020f9:	83 c4 10             	add    $0x10,%esp
801020fc:	eb cd                	jmp    801020cb <kalloc+0x10>
    release(&kmem.lock);
801020fe:	83 ec 0c             	sub    $0xc,%esp
80102101:	68 60 16 11 80       	push   $0x80111660
80102106:	e8 31 1b 00 00       	call   80103c3c <release>
8010210b:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010210e:	eb d5                	jmp    801020e5 <kalloc+0x2a>

80102110 <dump_physmem>:

// p5
int
dump_physmem(int *uframes, int *upids, int numframes)
{
80102110:	55                   	push   %ebp
80102111:	89 e5                	mov    %esp,%ebp
80102113:	57                   	push   %edi
80102114:	56                   	push   %esi
80102115:	53                   	push   %ebx
80102116:	8b 7d 08             	mov    0x8(%ebp),%edi
80102119:	8b 75 0c             	mov    0xc(%ebp),%esi
8010211c:	8b 5d 10             	mov    0x10(%ebp),%ebx
  //cprintf("dump_physmem in vm.c\n");
  for(int i = 0; i < numframes; i++) {
8010211f:	b8 00 00 00 00       	mov    $0x0,%eax
80102124:	eb 1e                	jmp    80102144 <dump_physmem+0x34>
    uframes[i] = frames[i];
80102126:	8d 14 85 00 00 00 00 	lea    0x0(,%eax,4),%edx
8010212d:	8b 0c 85 a0 96 14 80 	mov    -0x7feb6960(,%eax,4),%ecx
80102134:	89 0c 17             	mov    %ecx,(%edi,%edx,1)
    upids[i] = pids[i];
80102137:	8b 0c 85 a0 96 15 80 	mov    -0x7fea6960(,%eax,4),%ecx
8010213e:	89 0c 16             	mov    %ecx,(%esi,%edx,1)
  for(int i = 0; i < numframes; i++) {
80102141:	83 c0 01             	add    $0x1,%eax
80102144:	39 d8                	cmp    %ebx,%eax
80102146:	7c de                	jl     80102126 <dump_physmem+0x16>
  }
  return 0;
}
80102148:	b8 00 00 00 00       	mov    $0x0,%eax
8010214d:	5b                   	pop    %ebx
8010214e:	5e                   	pop    %esi
8010214f:	5f                   	pop    %edi
80102150:	5d                   	pop    %ebp
80102151:	c3                   	ret    

80102152 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
80102152:	55                   	push   %ebp
80102153:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102155:	ba 64 00 00 00       	mov    $0x64,%edx
8010215a:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
8010215b:	a8 01                	test   $0x1,%al
8010215d:	0f 84 b5 00 00 00    	je     80102218 <kbdgetc+0xc6>
80102163:	ba 60 00 00 00       	mov    $0x60,%edx
80102168:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
80102169:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
8010216c:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
80102172:	74 5c                	je     801021d0 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
80102174:	84 c0                	test   %al,%al
80102176:	78 66                	js     801021de <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102178:	8b 0d b8 95 10 80    	mov    0x801095b8,%ecx
8010217e:	f6 c1 40             	test   $0x40,%cl
80102181:	74 0f                	je     80102192 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
80102183:	83 c8 80             	or     $0xffffff80,%eax
80102186:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102189:	83 e1 bf             	and    $0xffffffbf,%ecx
8010218c:	89 0d b8 95 10 80    	mov    %ecx,0x801095b8
  }

  shift |= shiftcode[data];
80102192:	0f b6 8a a0 68 10 80 	movzbl -0x7fef9760(%edx),%ecx
80102199:	0b 0d b8 95 10 80    	or     0x801095b8,%ecx
  shift ^= togglecode[data];
8010219f:	0f b6 82 a0 67 10 80 	movzbl -0x7fef9860(%edx),%eax
801021a6:	31 c1                	xor    %eax,%ecx
801021a8:	89 0d b8 95 10 80    	mov    %ecx,0x801095b8
  c = charcode[shift & (CTL | SHIFT)][data];
801021ae:	89 c8                	mov    %ecx,%eax
801021b0:	83 e0 03             	and    $0x3,%eax
801021b3:	8b 04 85 80 67 10 80 	mov    -0x7fef9880(,%eax,4),%eax
801021ba:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
801021be:	f6 c1 08             	test   $0x8,%cl
801021c1:	74 19                	je     801021dc <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
801021c3:	8d 50 9f             	lea    -0x61(%eax),%edx
801021c6:	83 fa 19             	cmp    $0x19,%edx
801021c9:	77 40                	ja     8010220b <kbdgetc+0xb9>
      c += 'A' - 'a';
801021cb:	83 e8 20             	sub    $0x20,%eax
801021ce:	eb 0c                	jmp    801021dc <kbdgetc+0x8a>
    shift |= E0ESC;
801021d0:	83 0d b8 95 10 80 40 	orl    $0x40,0x801095b8
    return 0;
801021d7:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
801021dc:	5d                   	pop    %ebp
801021dd:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
801021de:	8b 0d b8 95 10 80    	mov    0x801095b8,%ecx
801021e4:	f6 c1 40             	test   $0x40,%cl
801021e7:	75 05                	jne    801021ee <kbdgetc+0x9c>
801021e9:	89 c2                	mov    %eax,%edx
801021eb:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
801021ee:	0f b6 82 a0 68 10 80 	movzbl -0x7fef9760(%edx),%eax
801021f5:	83 c8 40             	or     $0x40,%eax
801021f8:	0f b6 c0             	movzbl %al,%eax
801021fb:	f7 d0                	not    %eax
801021fd:	21 c8                	and    %ecx,%eax
801021ff:	a3 b8 95 10 80       	mov    %eax,0x801095b8
    return 0;
80102204:	b8 00 00 00 00       	mov    $0x0,%eax
80102209:	eb d1                	jmp    801021dc <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
8010220b:	8d 50 bf             	lea    -0x41(%eax),%edx
8010220e:	83 fa 19             	cmp    $0x19,%edx
80102211:	77 c9                	ja     801021dc <kbdgetc+0x8a>
      c += 'a' - 'A';
80102213:	83 c0 20             	add    $0x20,%eax
  return c;
80102216:	eb c4                	jmp    801021dc <kbdgetc+0x8a>
    return -1;
80102218:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010221d:	eb bd                	jmp    801021dc <kbdgetc+0x8a>

8010221f <kbdintr>:

void
kbdintr(void)
{
8010221f:	55                   	push   %ebp
80102220:	89 e5                	mov    %esp,%ebp
80102222:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102225:	68 52 21 10 80       	push   $0x80102152
8010222a:	e8 0f e5 ff ff       	call   8010073e <consoleintr>
}
8010222f:	83 c4 10             	add    $0x10,%esp
80102232:	c9                   	leave  
80102233:	c3                   	ret    

80102234 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102234:	55                   	push   %ebp
80102235:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102237:	8b 0d a0 96 16 80    	mov    0x801696a0,%ecx
8010223d:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102240:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102242:	a1 a0 96 16 80       	mov    0x801696a0,%eax
80102247:	8b 40 20             	mov    0x20(%eax),%eax
}
8010224a:	5d                   	pop    %ebp
8010224b:	c3                   	ret    

8010224c <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
8010224c:	55                   	push   %ebp
8010224d:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010224f:	ba 70 00 00 00       	mov    $0x70,%edx
80102254:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102255:	ba 71 00 00 00       	mov    $0x71,%edx
8010225a:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
8010225b:	0f b6 c0             	movzbl %al,%eax
}
8010225e:	5d                   	pop    %ebp
8010225f:	c3                   	ret    

80102260 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
80102260:	55                   	push   %ebp
80102261:	89 e5                	mov    %esp,%ebp
80102263:	53                   	push   %ebx
80102264:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
80102266:	b8 00 00 00 00       	mov    $0x0,%eax
8010226b:	e8 dc ff ff ff       	call   8010224c <cmos_read>
80102270:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
80102272:	b8 02 00 00 00       	mov    $0x2,%eax
80102277:	e8 d0 ff ff ff       	call   8010224c <cmos_read>
8010227c:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
8010227f:	b8 04 00 00 00       	mov    $0x4,%eax
80102284:	e8 c3 ff ff ff       	call   8010224c <cmos_read>
80102289:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
8010228c:	b8 07 00 00 00       	mov    $0x7,%eax
80102291:	e8 b6 ff ff ff       	call   8010224c <cmos_read>
80102296:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102299:	b8 08 00 00 00       	mov    $0x8,%eax
8010229e:	e8 a9 ff ff ff       	call   8010224c <cmos_read>
801022a3:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801022a6:	b8 09 00 00 00       	mov    $0x9,%eax
801022ab:	e8 9c ff ff ff       	call   8010224c <cmos_read>
801022b0:	89 43 14             	mov    %eax,0x14(%ebx)
}
801022b3:	5b                   	pop    %ebx
801022b4:	5d                   	pop    %ebp
801022b5:	c3                   	ret    

801022b6 <lapicinit>:
  if(!lapic)
801022b6:	83 3d a0 96 16 80 00 	cmpl   $0x0,0x801696a0
801022bd:	0f 84 fb 00 00 00    	je     801023be <lapicinit+0x108>
{
801022c3:	55                   	push   %ebp
801022c4:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
801022c6:	ba 3f 01 00 00       	mov    $0x13f,%edx
801022cb:	b8 3c 00 00 00       	mov    $0x3c,%eax
801022d0:	e8 5f ff ff ff       	call   80102234 <lapicw>
  lapicw(TDCR, X1);
801022d5:	ba 0b 00 00 00       	mov    $0xb,%edx
801022da:	b8 f8 00 00 00       	mov    $0xf8,%eax
801022df:	e8 50 ff ff ff       	call   80102234 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
801022e4:	ba 20 00 02 00       	mov    $0x20020,%edx
801022e9:	b8 c8 00 00 00       	mov    $0xc8,%eax
801022ee:	e8 41 ff ff ff       	call   80102234 <lapicw>
  lapicw(TICR, 10000000);
801022f3:	ba 80 96 98 00       	mov    $0x989680,%edx
801022f8:	b8 e0 00 00 00       	mov    $0xe0,%eax
801022fd:	e8 32 ff ff ff       	call   80102234 <lapicw>
  lapicw(LINT0, MASKED);
80102302:	ba 00 00 01 00       	mov    $0x10000,%edx
80102307:	b8 d4 00 00 00       	mov    $0xd4,%eax
8010230c:	e8 23 ff ff ff       	call   80102234 <lapicw>
  lapicw(LINT1, MASKED);
80102311:	ba 00 00 01 00       	mov    $0x10000,%edx
80102316:	b8 d8 00 00 00       	mov    $0xd8,%eax
8010231b:	e8 14 ff ff ff       	call   80102234 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102320:	a1 a0 96 16 80       	mov    0x801696a0,%eax
80102325:	8b 40 30             	mov    0x30(%eax),%eax
80102328:	c1 e8 10             	shr    $0x10,%eax
8010232b:	3c 03                	cmp    $0x3,%al
8010232d:	77 7b                	ja     801023aa <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
8010232f:	ba 33 00 00 00       	mov    $0x33,%edx
80102334:	b8 dc 00 00 00       	mov    $0xdc,%eax
80102339:	e8 f6 fe ff ff       	call   80102234 <lapicw>
  lapicw(ESR, 0);
8010233e:	ba 00 00 00 00       	mov    $0x0,%edx
80102343:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102348:	e8 e7 fe ff ff       	call   80102234 <lapicw>
  lapicw(ESR, 0);
8010234d:	ba 00 00 00 00       	mov    $0x0,%edx
80102352:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102357:	e8 d8 fe ff ff       	call   80102234 <lapicw>
  lapicw(EOI, 0);
8010235c:	ba 00 00 00 00       	mov    $0x0,%edx
80102361:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102366:	e8 c9 fe ff ff       	call   80102234 <lapicw>
  lapicw(ICRHI, 0);
8010236b:	ba 00 00 00 00       	mov    $0x0,%edx
80102370:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102375:	e8 ba fe ff ff       	call   80102234 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
8010237a:	ba 00 85 08 00       	mov    $0x88500,%edx
8010237f:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102384:	e8 ab fe ff ff       	call   80102234 <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102389:	a1 a0 96 16 80       	mov    0x801696a0,%eax
8010238e:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
80102394:	f6 c4 10             	test   $0x10,%ah
80102397:	75 f0                	jne    80102389 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102399:	ba 00 00 00 00       	mov    $0x0,%edx
8010239e:	b8 20 00 00 00       	mov    $0x20,%eax
801023a3:	e8 8c fe ff ff       	call   80102234 <lapicw>
}
801023a8:	5d                   	pop    %ebp
801023a9:	c3                   	ret    
    lapicw(PCINT, MASKED);
801023aa:	ba 00 00 01 00       	mov    $0x10000,%edx
801023af:	b8 d0 00 00 00       	mov    $0xd0,%eax
801023b4:	e8 7b fe ff ff       	call   80102234 <lapicw>
801023b9:	e9 71 ff ff ff       	jmp    8010232f <lapicinit+0x79>
801023be:	f3 c3                	repz ret 

801023c0 <lapicid>:
{
801023c0:	55                   	push   %ebp
801023c1:	89 e5                	mov    %esp,%ebp
  if (!lapic)
801023c3:	a1 a0 96 16 80       	mov    0x801696a0,%eax
801023c8:	85 c0                	test   %eax,%eax
801023ca:	74 08                	je     801023d4 <lapicid+0x14>
  return lapic[ID] >> 24;
801023cc:	8b 40 20             	mov    0x20(%eax),%eax
801023cf:	c1 e8 18             	shr    $0x18,%eax
}
801023d2:	5d                   	pop    %ebp
801023d3:	c3                   	ret    
    return 0;
801023d4:	b8 00 00 00 00       	mov    $0x0,%eax
801023d9:	eb f7                	jmp    801023d2 <lapicid+0x12>

801023db <lapiceoi>:
  if(lapic)
801023db:	83 3d a0 96 16 80 00 	cmpl   $0x0,0x801696a0
801023e2:	74 14                	je     801023f8 <lapiceoi+0x1d>
{
801023e4:	55                   	push   %ebp
801023e5:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
801023e7:	ba 00 00 00 00       	mov    $0x0,%edx
801023ec:	b8 2c 00 00 00       	mov    $0x2c,%eax
801023f1:	e8 3e fe ff ff       	call   80102234 <lapicw>
}
801023f6:	5d                   	pop    %ebp
801023f7:	c3                   	ret    
801023f8:	f3 c3                	repz ret 

801023fa <microdelay>:
{
801023fa:	55                   	push   %ebp
801023fb:	89 e5                	mov    %esp,%ebp
}
801023fd:	5d                   	pop    %ebp
801023fe:	c3                   	ret    

801023ff <lapicstartap>:
{
801023ff:	55                   	push   %ebp
80102400:	89 e5                	mov    %esp,%ebp
80102402:	57                   	push   %edi
80102403:	56                   	push   %esi
80102404:	53                   	push   %ebx
80102405:	8b 75 08             	mov    0x8(%ebp),%esi
80102408:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010240b:	b8 0f 00 00 00       	mov    $0xf,%eax
80102410:	ba 70 00 00 00       	mov    $0x70,%edx
80102415:	ee                   	out    %al,(%dx)
80102416:	b8 0a 00 00 00       	mov    $0xa,%eax
8010241b:	ba 71 00 00 00       	mov    $0x71,%edx
80102420:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102421:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102428:	00 00 
  wrv[1] = addr >> 4;
8010242a:	89 f8                	mov    %edi,%eax
8010242c:	c1 e8 04             	shr    $0x4,%eax
8010242f:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102435:	c1 e6 18             	shl    $0x18,%esi
80102438:	89 f2                	mov    %esi,%edx
8010243a:	b8 c4 00 00 00       	mov    $0xc4,%eax
8010243f:	e8 f0 fd ff ff       	call   80102234 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102444:	ba 00 c5 00 00       	mov    $0xc500,%edx
80102449:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010244e:	e8 e1 fd ff ff       	call   80102234 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
80102453:	ba 00 85 00 00       	mov    $0x8500,%edx
80102458:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010245d:	e8 d2 fd ff ff       	call   80102234 <lapicw>
  for(i = 0; i < 2; i++){
80102462:	bb 00 00 00 00       	mov    $0x0,%ebx
80102467:	eb 21                	jmp    8010248a <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
80102469:	89 f2                	mov    %esi,%edx
8010246b:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102470:	e8 bf fd ff ff       	call   80102234 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
80102475:	89 fa                	mov    %edi,%edx
80102477:	c1 ea 0c             	shr    $0xc,%edx
8010247a:	80 ce 06             	or     $0x6,%dh
8010247d:	b8 c0 00 00 00       	mov    $0xc0,%eax
80102482:	e8 ad fd ff ff       	call   80102234 <lapicw>
  for(i = 0; i < 2; i++){
80102487:	83 c3 01             	add    $0x1,%ebx
8010248a:	83 fb 01             	cmp    $0x1,%ebx
8010248d:	7e da                	jle    80102469 <lapicstartap+0x6a>
}
8010248f:	5b                   	pop    %ebx
80102490:	5e                   	pop    %esi
80102491:	5f                   	pop    %edi
80102492:	5d                   	pop    %ebp
80102493:	c3                   	ret    

80102494 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
80102494:	55                   	push   %ebp
80102495:	89 e5                	mov    %esp,%ebp
80102497:	57                   	push   %edi
80102498:	56                   	push   %esi
80102499:	53                   	push   %ebx
8010249a:	83 ec 3c             	sub    $0x3c,%esp
8010249d:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801024a0:	b8 0b 00 00 00       	mov    $0xb,%eax
801024a5:	e8 a2 fd ff ff       	call   8010224c <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801024aa:	83 e0 04             	and    $0x4,%eax
801024ad:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
801024af:	8d 45 d0             	lea    -0x30(%ebp),%eax
801024b2:	e8 a9 fd ff ff       	call   80102260 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
801024b7:	b8 0a 00 00 00       	mov    $0xa,%eax
801024bc:	e8 8b fd ff ff       	call   8010224c <cmos_read>
801024c1:	a8 80                	test   $0x80,%al
801024c3:	75 ea                	jne    801024af <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
801024c5:	8d 5d b8             	lea    -0x48(%ebp),%ebx
801024c8:	89 d8                	mov    %ebx,%eax
801024ca:	e8 91 fd ff ff       	call   80102260 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
801024cf:	83 ec 04             	sub    $0x4,%esp
801024d2:	6a 18                	push   $0x18
801024d4:	53                   	push   %ebx
801024d5:	8d 45 d0             	lea    -0x30(%ebp),%eax
801024d8:	50                   	push   %eax
801024d9:	e8 eb 17 00 00       	call   80103cc9 <memcmp>
801024de:	83 c4 10             	add    $0x10,%esp
801024e1:	85 c0                	test   %eax,%eax
801024e3:	75 ca                	jne    801024af <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
801024e5:	85 ff                	test   %edi,%edi
801024e7:	0f 85 84 00 00 00    	jne    80102571 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
801024ed:	8b 55 d0             	mov    -0x30(%ebp),%edx
801024f0:	89 d0                	mov    %edx,%eax
801024f2:	c1 e8 04             	shr    $0x4,%eax
801024f5:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801024f8:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801024fb:	83 e2 0f             	and    $0xf,%edx
801024fe:	01 d0                	add    %edx,%eax
80102500:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102503:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102506:	89 d0                	mov    %edx,%eax
80102508:	c1 e8 04             	shr    $0x4,%eax
8010250b:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010250e:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102511:	83 e2 0f             	and    $0xf,%edx
80102514:	01 d0                	add    %edx,%eax
80102516:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
80102519:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010251c:	89 d0                	mov    %edx,%eax
8010251e:	c1 e8 04             	shr    $0x4,%eax
80102521:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102524:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102527:	83 e2 0f             	and    $0xf,%edx
8010252a:	01 d0                	add    %edx,%eax
8010252c:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
8010252f:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102532:	89 d0                	mov    %edx,%eax
80102534:	c1 e8 04             	shr    $0x4,%eax
80102537:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010253a:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010253d:	83 e2 0f             	and    $0xf,%edx
80102540:	01 d0                	add    %edx,%eax
80102542:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102545:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102548:	89 d0                	mov    %edx,%eax
8010254a:	c1 e8 04             	shr    $0x4,%eax
8010254d:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102550:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102553:	83 e2 0f             	and    $0xf,%edx
80102556:	01 d0                	add    %edx,%eax
80102558:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
8010255b:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010255e:	89 d0                	mov    %edx,%eax
80102560:	c1 e8 04             	shr    $0x4,%eax
80102563:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102566:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102569:	83 e2 0f             	and    $0xf,%edx
8010256c:	01 d0                	add    %edx,%eax
8010256e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
80102571:	8b 45 d0             	mov    -0x30(%ebp),%eax
80102574:	89 06                	mov    %eax,(%esi)
80102576:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102579:	89 46 04             	mov    %eax,0x4(%esi)
8010257c:	8b 45 d8             	mov    -0x28(%ebp),%eax
8010257f:	89 46 08             	mov    %eax,0x8(%esi)
80102582:	8b 45 dc             	mov    -0x24(%ebp),%eax
80102585:	89 46 0c             	mov    %eax,0xc(%esi)
80102588:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010258b:	89 46 10             	mov    %eax,0x10(%esi)
8010258e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102591:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
80102594:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
8010259b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010259e:	5b                   	pop    %ebx
8010259f:	5e                   	pop    %esi
801025a0:	5f                   	pop    %edi
801025a1:	5d                   	pop    %ebp
801025a2:	c3                   	ret    

801025a3 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801025a3:	55                   	push   %ebp
801025a4:	89 e5                	mov    %esp,%ebp
801025a6:	53                   	push   %ebx
801025a7:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801025aa:	ff 35 f4 96 16 80    	pushl  0x801696f4
801025b0:	ff 35 04 97 16 80    	pushl  0x80169704
801025b6:	e8 b1 db ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
801025bb:	8b 58 5c             	mov    0x5c(%eax),%ebx
801025be:	89 1d 08 97 16 80    	mov    %ebx,0x80169708
  for (i = 0; i < log.lh.n; i++) {
801025c4:	83 c4 10             	add    $0x10,%esp
801025c7:	ba 00 00 00 00       	mov    $0x0,%edx
801025cc:	eb 0e                	jmp    801025dc <read_head+0x39>
    log.lh.block[i] = lh->block[i];
801025ce:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
801025d2:	89 0c 95 0c 97 16 80 	mov    %ecx,-0x7fe968f4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
801025d9:	83 c2 01             	add    $0x1,%edx
801025dc:	39 d3                	cmp    %edx,%ebx
801025de:	7f ee                	jg     801025ce <read_head+0x2b>
  }
  brelse(buf);
801025e0:	83 ec 0c             	sub    $0xc,%esp
801025e3:	50                   	push   %eax
801025e4:	e8 ec db ff ff       	call   801001d5 <brelse>
}
801025e9:	83 c4 10             	add    $0x10,%esp
801025ec:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801025ef:	c9                   	leave  
801025f0:	c3                   	ret    

801025f1 <install_trans>:
{
801025f1:	55                   	push   %ebp
801025f2:	89 e5                	mov    %esp,%ebp
801025f4:	57                   	push   %edi
801025f5:	56                   	push   %esi
801025f6:	53                   	push   %ebx
801025f7:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
801025fa:	bb 00 00 00 00       	mov    $0x0,%ebx
801025ff:	eb 66                	jmp    80102667 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102601:	89 d8                	mov    %ebx,%eax
80102603:	03 05 f4 96 16 80    	add    0x801696f4,%eax
80102609:	83 c0 01             	add    $0x1,%eax
8010260c:	83 ec 08             	sub    $0x8,%esp
8010260f:	50                   	push   %eax
80102610:	ff 35 04 97 16 80    	pushl  0x80169704
80102616:	e8 51 db ff ff       	call   8010016c <bread>
8010261b:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010261d:	83 c4 08             	add    $0x8,%esp
80102620:	ff 34 9d 0c 97 16 80 	pushl  -0x7fe968f4(,%ebx,4)
80102627:	ff 35 04 97 16 80    	pushl  0x80169704
8010262d:	e8 3a db ff ff       	call   8010016c <bread>
80102632:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102634:	8d 57 5c             	lea    0x5c(%edi),%edx
80102637:	8d 40 5c             	lea    0x5c(%eax),%eax
8010263a:	83 c4 0c             	add    $0xc,%esp
8010263d:	68 00 02 00 00       	push   $0x200
80102642:	52                   	push   %edx
80102643:	50                   	push   %eax
80102644:	e8 b5 16 00 00       	call   80103cfe <memmove>
    bwrite(dbuf);  // write dst to disk
80102649:	89 34 24             	mov    %esi,(%esp)
8010264c:	e8 49 db ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
80102651:	89 3c 24             	mov    %edi,(%esp)
80102654:	e8 7c db ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
80102659:	89 34 24             	mov    %esi,(%esp)
8010265c:	e8 74 db ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102661:	83 c3 01             	add    $0x1,%ebx
80102664:	83 c4 10             	add    $0x10,%esp
80102667:	39 1d 08 97 16 80    	cmp    %ebx,0x80169708
8010266d:	7f 92                	jg     80102601 <install_trans+0x10>
}
8010266f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102672:	5b                   	pop    %ebx
80102673:	5e                   	pop    %esi
80102674:	5f                   	pop    %edi
80102675:	5d                   	pop    %ebp
80102676:	c3                   	ret    

80102677 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
80102677:	55                   	push   %ebp
80102678:	89 e5                	mov    %esp,%ebp
8010267a:	53                   	push   %ebx
8010267b:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
8010267e:	ff 35 f4 96 16 80    	pushl  0x801696f4
80102684:	ff 35 04 97 16 80    	pushl  0x80169704
8010268a:	e8 dd da ff ff       	call   8010016c <bread>
8010268f:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102691:	8b 0d 08 97 16 80    	mov    0x80169708,%ecx
80102697:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
8010269a:	83 c4 10             	add    $0x10,%esp
8010269d:	b8 00 00 00 00       	mov    $0x0,%eax
801026a2:	eb 0e                	jmp    801026b2 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
801026a4:	8b 14 85 0c 97 16 80 	mov    -0x7fe968f4(,%eax,4),%edx
801026ab:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
801026af:	83 c0 01             	add    $0x1,%eax
801026b2:	39 c1                	cmp    %eax,%ecx
801026b4:	7f ee                	jg     801026a4 <write_head+0x2d>
  }
  bwrite(buf);
801026b6:	83 ec 0c             	sub    $0xc,%esp
801026b9:	53                   	push   %ebx
801026ba:	e8 db da ff ff       	call   8010019a <bwrite>
  brelse(buf);
801026bf:	89 1c 24             	mov    %ebx,(%esp)
801026c2:	e8 0e db ff ff       	call   801001d5 <brelse>
}
801026c7:	83 c4 10             	add    $0x10,%esp
801026ca:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801026cd:	c9                   	leave  
801026ce:	c3                   	ret    

801026cf <recover_from_log>:

static void
recover_from_log(void)
{
801026cf:	55                   	push   %ebp
801026d0:	89 e5                	mov    %esp,%ebp
801026d2:	83 ec 08             	sub    $0x8,%esp
  read_head();
801026d5:	e8 c9 fe ff ff       	call   801025a3 <read_head>
  install_trans(); // if committed, copy from log to disk
801026da:	e8 12 ff ff ff       	call   801025f1 <install_trans>
  log.lh.n = 0;
801026df:	c7 05 08 97 16 80 00 	movl   $0x0,0x80169708
801026e6:	00 00 00 
  write_head(); // clear the log
801026e9:	e8 89 ff ff ff       	call   80102677 <write_head>
}
801026ee:	c9                   	leave  
801026ef:	c3                   	ret    

801026f0 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
801026f0:	55                   	push   %ebp
801026f1:	89 e5                	mov    %esp,%ebp
801026f3:	57                   	push   %edi
801026f4:	56                   	push   %esi
801026f5:	53                   	push   %ebx
801026f6:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
801026f9:	bb 00 00 00 00       	mov    $0x0,%ebx
801026fe:	eb 66                	jmp    80102766 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102700:	89 d8                	mov    %ebx,%eax
80102702:	03 05 f4 96 16 80    	add    0x801696f4,%eax
80102708:	83 c0 01             	add    $0x1,%eax
8010270b:	83 ec 08             	sub    $0x8,%esp
8010270e:	50                   	push   %eax
8010270f:	ff 35 04 97 16 80    	pushl  0x80169704
80102715:	e8 52 da ff ff       	call   8010016c <bread>
8010271a:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010271c:	83 c4 08             	add    $0x8,%esp
8010271f:	ff 34 9d 0c 97 16 80 	pushl  -0x7fe968f4(,%ebx,4)
80102726:	ff 35 04 97 16 80    	pushl  0x80169704
8010272c:	e8 3b da ff ff       	call   8010016c <bread>
80102731:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102733:	8d 50 5c             	lea    0x5c(%eax),%edx
80102736:	8d 46 5c             	lea    0x5c(%esi),%eax
80102739:	83 c4 0c             	add    $0xc,%esp
8010273c:	68 00 02 00 00       	push   $0x200
80102741:	52                   	push   %edx
80102742:	50                   	push   %eax
80102743:	e8 b6 15 00 00       	call   80103cfe <memmove>
    bwrite(to);  // write the log
80102748:	89 34 24             	mov    %esi,(%esp)
8010274b:	e8 4a da ff ff       	call   8010019a <bwrite>
    brelse(from);
80102750:	89 3c 24             	mov    %edi,(%esp)
80102753:	e8 7d da ff ff       	call   801001d5 <brelse>
    brelse(to);
80102758:	89 34 24             	mov    %esi,(%esp)
8010275b:	e8 75 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
80102760:	83 c3 01             	add    $0x1,%ebx
80102763:	83 c4 10             	add    $0x10,%esp
80102766:	39 1d 08 97 16 80    	cmp    %ebx,0x80169708
8010276c:	7f 92                	jg     80102700 <write_log+0x10>
  }
}
8010276e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102771:	5b                   	pop    %ebx
80102772:	5e                   	pop    %esi
80102773:	5f                   	pop    %edi
80102774:	5d                   	pop    %ebp
80102775:	c3                   	ret    

80102776 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
80102776:	83 3d 08 97 16 80 00 	cmpl   $0x0,0x80169708
8010277d:	7e 26                	jle    801027a5 <commit+0x2f>
{
8010277f:	55                   	push   %ebp
80102780:	89 e5                	mov    %esp,%ebp
80102782:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
80102785:	e8 66 ff ff ff       	call   801026f0 <write_log>
    write_head();    // Write header to disk -- the real commit
8010278a:	e8 e8 fe ff ff       	call   80102677 <write_head>
    install_trans(); // Now install writes to home locations
8010278f:	e8 5d fe ff ff       	call   801025f1 <install_trans>
    log.lh.n = 0;
80102794:	c7 05 08 97 16 80 00 	movl   $0x0,0x80169708
8010279b:	00 00 00 
    write_head();    // Erase the transaction from the log
8010279e:	e8 d4 fe ff ff       	call   80102677 <write_head>
  }
}
801027a3:	c9                   	leave  
801027a4:	c3                   	ret    
801027a5:	f3 c3                	repz ret 

801027a7 <initlog>:
{
801027a7:	55                   	push   %ebp
801027a8:	89 e5                	mov    %esp,%ebp
801027aa:	53                   	push   %ebx
801027ab:	83 ec 2c             	sub    $0x2c,%esp
801027ae:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
801027b1:	68 a0 69 10 80       	push   $0x801069a0
801027b6:	68 c0 96 16 80       	push   $0x801696c0
801027bb:	e8 db 12 00 00       	call   80103a9b <initlock>
  readsb(dev, &sb);
801027c0:	83 c4 08             	add    $0x8,%esp
801027c3:	8d 45 dc             	lea    -0x24(%ebp),%eax
801027c6:	50                   	push   %eax
801027c7:	53                   	push   %ebx
801027c8:	e8 69 ea ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
801027cd:	8b 45 ec             	mov    -0x14(%ebp),%eax
801027d0:	a3 f4 96 16 80       	mov    %eax,0x801696f4
  log.size = sb.nlog;
801027d5:	8b 45 e8             	mov    -0x18(%ebp),%eax
801027d8:	a3 f8 96 16 80       	mov    %eax,0x801696f8
  log.dev = dev;
801027dd:	89 1d 04 97 16 80    	mov    %ebx,0x80169704
  recover_from_log();
801027e3:	e8 e7 fe ff ff       	call   801026cf <recover_from_log>
}
801027e8:	83 c4 10             	add    $0x10,%esp
801027eb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801027ee:	c9                   	leave  
801027ef:	c3                   	ret    

801027f0 <begin_op>:
{
801027f0:	55                   	push   %ebp
801027f1:	89 e5                	mov    %esp,%ebp
801027f3:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
801027f6:	68 c0 96 16 80       	push   $0x801696c0
801027fb:	e8 d7 13 00 00       	call   80103bd7 <acquire>
80102800:	83 c4 10             	add    $0x10,%esp
80102803:	eb 15                	jmp    8010281a <begin_op+0x2a>
      sleep(&log, &log.lock);
80102805:	83 ec 08             	sub    $0x8,%esp
80102808:	68 c0 96 16 80       	push   $0x801696c0
8010280d:	68 c0 96 16 80       	push   $0x801696c0
80102812:	e8 c5 0e 00 00       	call   801036dc <sleep>
80102817:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
8010281a:	83 3d 00 97 16 80 00 	cmpl   $0x0,0x80169700
80102821:	75 e2                	jne    80102805 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102823:	a1 fc 96 16 80       	mov    0x801696fc,%eax
80102828:	83 c0 01             	add    $0x1,%eax
8010282b:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010282e:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102831:	03 15 08 97 16 80    	add    0x80169708,%edx
80102837:	83 fa 1e             	cmp    $0x1e,%edx
8010283a:	7e 17                	jle    80102853 <begin_op+0x63>
      sleep(&log, &log.lock);
8010283c:	83 ec 08             	sub    $0x8,%esp
8010283f:	68 c0 96 16 80       	push   $0x801696c0
80102844:	68 c0 96 16 80       	push   $0x801696c0
80102849:	e8 8e 0e 00 00       	call   801036dc <sleep>
8010284e:	83 c4 10             	add    $0x10,%esp
80102851:	eb c7                	jmp    8010281a <begin_op+0x2a>
      log.outstanding += 1;
80102853:	a3 fc 96 16 80       	mov    %eax,0x801696fc
      release(&log.lock);
80102858:	83 ec 0c             	sub    $0xc,%esp
8010285b:	68 c0 96 16 80       	push   $0x801696c0
80102860:	e8 d7 13 00 00       	call   80103c3c <release>
}
80102865:	83 c4 10             	add    $0x10,%esp
80102868:	c9                   	leave  
80102869:	c3                   	ret    

8010286a <end_op>:
{
8010286a:	55                   	push   %ebp
8010286b:	89 e5                	mov    %esp,%ebp
8010286d:	53                   	push   %ebx
8010286e:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
80102871:	68 c0 96 16 80       	push   $0x801696c0
80102876:	e8 5c 13 00 00       	call   80103bd7 <acquire>
  log.outstanding -= 1;
8010287b:	a1 fc 96 16 80       	mov    0x801696fc,%eax
80102880:	83 e8 01             	sub    $0x1,%eax
80102883:	a3 fc 96 16 80       	mov    %eax,0x801696fc
  if(log.committing)
80102888:	8b 1d 00 97 16 80    	mov    0x80169700,%ebx
8010288e:	83 c4 10             	add    $0x10,%esp
80102891:	85 db                	test   %ebx,%ebx
80102893:	75 2c                	jne    801028c1 <end_op+0x57>
  if(log.outstanding == 0){
80102895:	85 c0                	test   %eax,%eax
80102897:	75 35                	jne    801028ce <end_op+0x64>
    log.committing = 1;
80102899:	c7 05 00 97 16 80 01 	movl   $0x1,0x80169700
801028a0:	00 00 00 
    do_commit = 1;
801028a3:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
801028a8:	83 ec 0c             	sub    $0xc,%esp
801028ab:	68 c0 96 16 80       	push   $0x801696c0
801028b0:	e8 87 13 00 00       	call   80103c3c <release>
  if(do_commit){
801028b5:	83 c4 10             	add    $0x10,%esp
801028b8:	85 db                	test   %ebx,%ebx
801028ba:	75 24                	jne    801028e0 <end_op+0x76>
}
801028bc:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801028bf:	c9                   	leave  
801028c0:	c3                   	ret    
    panic("log.committing");
801028c1:	83 ec 0c             	sub    $0xc,%esp
801028c4:	68 a4 69 10 80       	push   $0x801069a4
801028c9:	e8 7a da ff ff       	call   80100348 <panic>
    wakeup(&log);
801028ce:	83 ec 0c             	sub    $0xc,%esp
801028d1:	68 c0 96 16 80       	push   $0x801696c0
801028d6:	e8 66 0f 00 00       	call   80103841 <wakeup>
801028db:	83 c4 10             	add    $0x10,%esp
801028de:	eb c8                	jmp    801028a8 <end_op+0x3e>
    commit();
801028e0:	e8 91 fe ff ff       	call   80102776 <commit>
    acquire(&log.lock);
801028e5:	83 ec 0c             	sub    $0xc,%esp
801028e8:	68 c0 96 16 80       	push   $0x801696c0
801028ed:	e8 e5 12 00 00       	call   80103bd7 <acquire>
    log.committing = 0;
801028f2:	c7 05 00 97 16 80 00 	movl   $0x0,0x80169700
801028f9:	00 00 00 
    wakeup(&log);
801028fc:	c7 04 24 c0 96 16 80 	movl   $0x801696c0,(%esp)
80102903:	e8 39 0f 00 00       	call   80103841 <wakeup>
    release(&log.lock);
80102908:	c7 04 24 c0 96 16 80 	movl   $0x801696c0,(%esp)
8010290f:	e8 28 13 00 00       	call   80103c3c <release>
80102914:	83 c4 10             	add    $0x10,%esp
}
80102917:	eb a3                	jmp    801028bc <end_op+0x52>

80102919 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102919:	55                   	push   %ebp
8010291a:	89 e5                	mov    %esp,%ebp
8010291c:	53                   	push   %ebx
8010291d:	83 ec 04             	sub    $0x4,%esp
80102920:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102923:	8b 15 08 97 16 80    	mov    0x80169708,%edx
80102929:	83 fa 1d             	cmp    $0x1d,%edx
8010292c:	7f 45                	jg     80102973 <log_write+0x5a>
8010292e:	a1 f8 96 16 80       	mov    0x801696f8,%eax
80102933:	83 e8 01             	sub    $0x1,%eax
80102936:	39 c2                	cmp    %eax,%edx
80102938:	7d 39                	jge    80102973 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
8010293a:	83 3d fc 96 16 80 00 	cmpl   $0x0,0x801696fc
80102941:	7e 3d                	jle    80102980 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102943:	83 ec 0c             	sub    $0xc,%esp
80102946:	68 c0 96 16 80       	push   $0x801696c0
8010294b:	e8 87 12 00 00       	call   80103bd7 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102950:	83 c4 10             	add    $0x10,%esp
80102953:	b8 00 00 00 00       	mov    $0x0,%eax
80102958:	8b 15 08 97 16 80    	mov    0x80169708,%edx
8010295e:	39 c2                	cmp    %eax,%edx
80102960:	7e 2b                	jle    8010298d <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102962:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102965:	39 0c 85 0c 97 16 80 	cmp    %ecx,-0x7fe968f4(,%eax,4)
8010296c:	74 1f                	je     8010298d <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
8010296e:	83 c0 01             	add    $0x1,%eax
80102971:	eb e5                	jmp    80102958 <log_write+0x3f>
    panic("too big a transaction");
80102973:	83 ec 0c             	sub    $0xc,%esp
80102976:	68 b3 69 10 80       	push   $0x801069b3
8010297b:	e8 c8 d9 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102980:	83 ec 0c             	sub    $0xc,%esp
80102983:	68 c9 69 10 80       	push   $0x801069c9
80102988:	e8 bb d9 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
8010298d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102990:	89 0c 85 0c 97 16 80 	mov    %ecx,-0x7fe968f4(,%eax,4)
  if (i == log.lh.n)
80102997:	39 c2                	cmp    %eax,%edx
80102999:	74 18                	je     801029b3 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
8010299b:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
8010299e:	83 ec 0c             	sub    $0xc,%esp
801029a1:	68 c0 96 16 80       	push   $0x801696c0
801029a6:	e8 91 12 00 00       	call   80103c3c <release>
}
801029ab:	83 c4 10             	add    $0x10,%esp
801029ae:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801029b1:	c9                   	leave  
801029b2:	c3                   	ret    
    log.lh.n++;
801029b3:	83 c2 01             	add    $0x1,%edx
801029b6:	89 15 08 97 16 80    	mov    %edx,0x80169708
801029bc:	eb dd                	jmp    8010299b <log_write+0x82>

801029be <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
801029be:	55                   	push   %ebp
801029bf:	89 e5                	mov    %esp,%ebp
801029c1:	53                   	push   %ebx
801029c2:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
801029c5:	68 8a 00 00 00       	push   $0x8a
801029ca:	68 8c 94 10 80       	push   $0x8010948c
801029cf:	68 00 70 00 80       	push   $0x80007000
801029d4:	e8 25 13 00 00       	call   80103cfe <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
801029d9:	83 c4 10             	add    $0x10,%esp
801029dc:	bb c0 97 16 80       	mov    $0x801697c0,%ebx
801029e1:	eb 06                	jmp    801029e9 <startothers+0x2b>
801029e3:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
801029e9:	69 05 40 9d 16 80 b0 	imul   $0xb0,0x80169d40,%eax
801029f0:	00 00 00 
801029f3:	05 c0 97 16 80       	add    $0x801697c0,%eax
801029f8:	39 d8                	cmp    %ebx,%eax
801029fa:	76 4c                	jbe    80102a48 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
801029fc:	e8 c0 07 00 00       	call   801031c1 <mycpu>
80102a01:	39 d8                	cmp    %ebx,%eax
80102a03:	74 de                	je     801029e3 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102a05:	e8 b1 f6 ff ff       	call   801020bb <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102a0a:	05 00 10 00 00       	add    $0x1000,%eax
80102a0f:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102a14:	c7 05 f8 6f 00 80 8c 	movl   $0x80102a8c,0x80006ff8
80102a1b:	2a 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102a1e:	c7 05 f4 6f 00 80 00 	movl   $0x108000,0x80006ff4
80102a25:	80 10 00 

    lapicstartap(c->apicid, V2P(code));
80102a28:	83 ec 08             	sub    $0x8,%esp
80102a2b:	68 00 70 00 00       	push   $0x7000
80102a30:	0f b6 03             	movzbl (%ebx),%eax
80102a33:	50                   	push   %eax
80102a34:	e8 c6 f9 ff ff       	call   801023ff <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102a39:	83 c4 10             	add    $0x10,%esp
80102a3c:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102a42:	85 c0                	test   %eax,%eax
80102a44:	74 f6                	je     80102a3c <startothers+0x7e>
80102a46:	eb 9b                	jmp    801029e3 <startothers+0x25>
      ;
  }
}
80102a48:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a4b:	c9                   	leave  
80102a4c:	c3                   	ret    

80102a4d <mpmain>:
{
80102a4d:	55                   	push   %ebp
80102a4e:	89 e5                	mov    %esp,%ebp
80102a50:	53                   	push   %ebx
80102a51:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102a54:	e8 c4 07 00 00       	call   8010321d <cpuid>
80102a59:	89 c3                	mov    %eax,%ebx
80102a5b:	e8 bd 07 00 00       	call   8010321d <cpuid>
80102a60:	83 ec 04             	sub    $0x4,%esp
80102a63:	53                   	push   %ebx
80102a64:	50                   	push   %eax
80102a65:	68 e4 69 10 80       	push   $0x801069e4
80102a6a:	e8 9c db ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102a6f:	e8 05 24 00 00       	call   80104e79 <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102a74:	e8 48 07 00 00       	call   801031c1 <mycpu>
80102a79:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102a7b:	b8 01 00 00 00       	mov    $0x1,%eax
80102a80:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102a87:	e8 2b 0a 00 00       	call   801034b7 <scheduler>

80102a8c <mpenter>:
{
80102a8c:	55                   	push   %ebp
80102a8d:	89 e5                	mov    %esp,%ebp
80102a8f:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102a92:	e8 eb 33 00 00       	call   80105e82 <switchkvm>
  seginit();
80102a97:	e8 9a 32 00 00       	call   80105d36 <seginit>
  lapicinit();
80102a9c:	e8 15 f8 ff ff       	call   801022b6 <lapicinit>
  mpmain();
80102aa1:	e8 a7 ff ff ff       	call   80102a4d <mpmain>

80102aa6 <main>:
{
80102aa6:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102aaa:	83 e4 f0             	and    $0xfffffff0,%esp
80102aad:	ff 71 fc             	pushl  -0x4(%ecx)
80102ab0:	55                   	push   %ebp
80102ab1:	89 e5                	mov    %esp,%ebp
80102ab3:	51                   	push   %ecx
80102ab4:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102ab7:	68 00 00 40 80       	push   $0x80400000
80102abc:	68 e8 c4 16 80       	push   $0x8016c4e8
80102ac1:	e8 a3 f5 ff ff       	call   80102069 <kinit1>
  kvmalloc();      // kernel page table
80102ac6:	e8 44 38 00 00       	call   8010630f <kvmalloc>
  mpinit();        // detect other processors
80102acb:	e8 c9 01 00 00       	call   80102c99 <mpinit>
  lapicinit();     // interrupt controller
80102ad0:	e8 e1 f7 ff ff       	call   801022b6 <lapicinit>
  seginit();       // segment descriptors
80102ad5:	e8 5c 32 00 00       	call   80105d36 <seginit>
  picinit();       // disable pic
80102ada:	e8 82 02 00 00       	call   80102d61 <picinit>
  ioapicinit();    // another interrupt controller
80102adf:	e8 16 f4 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102ae4:	e8 a5 dd ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102ae9:	e8 39 26 00 00       	call   80105127 <uartinit>
  pinit();         // process table
80102aee:	e8 b4 06 00 00       	call   801031a7 <pinit>
  tvinit();        // trap vectors
80102af3:	e8 d0 22 00 00       	call   80104dc8 <tvinit>
  binit();         // buffer cache
80102af8:	e8 f7 d5 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102afd:	e8 11 e1 ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102b02:	e8 f9 f1 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102b07:	e8 b2 fe ff ff       	call   801029be <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102b0c:	83 c4 08             	add    $0x8,%esp
80102b0f:	68 00 00 00 8e       	push   $0x8e000000
80102b14:	68 00 00 40 80       	push   $0x80400000
80102b19:	e8 7d f5 ff ff       	call   8010209b <kinit2>
  userinit();      // first user process
80102b1e:	e8 39 07 00 00       	call   8010325c <userinit>
  mpmain();        // finish this processor's setup
80102b23:	e8 25 ff ff ff       	call   80102a4d <mpmain>

80102b28 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102b28:	55                   	push   %ebp
80102b29:	89 e5                	mov    %esp,%ebp
80102b2b:	56                   	push   %esi
80102b2c:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102b2d:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102b32:	b9 00 00 00 00       	mov    $0x0,%ecx
80102b37:	eb 09                	jmp    80102b42 <sum+0x1a>
    sum += addr[i];
80102b39:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102b3d:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102b3f:	83 c1 01             	add    $0x1,%ecx
80102b42:	39 d1                	cmp    %edx,%ecx
80102b44:	7c f3                	jl     80102b39 <sum+0x11>
  return sum;
}
80102b46:	89 d8                	mov    %ebx,%eax
80102b48:	5b                   	pop    %ebx
80102b49:	5e                   	pop    %esi
80102b4a:	5d                   	pop    %ebp
80102b4b:	c3                   	ret    

80102b4c <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102b4c:	55                   	push   %ebp
80102b4d:	89 e5                	mov    %esp,%ebp
80102b4f:	56                   	push   %esi
80102b50:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102b51:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102b57:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102b59:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102b5b:	eb 03                	jmp    80102b60 <mpsearch1+0x14>
80102b5d:	83 c3 10             	add    $0x10,%ebx
80102b60:	39 f3                	cmp    %esi,%ebx
80102b62:	73 29                	jae    80102b8d <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102b64:	83 ec 04             	sub    $0x4,%esp
80102b67:	6a 04                	push   $0x4
80102b69:	68 f8 69 10 80       	push   $0x801069f8
80102b6e:	53                   	push   %ebx
80102b6f:	e8 55 11 00 00       	call   80103cc9 <memcmp>
80102b74:	83 c4 10             	add    $0x10,%esp
80102b77:	85 c0                	test   %eax,%eax
80102b79:	75 e2                	jne    80102b5d <mpsearch1+0x11>
80102b7b:	ba 10 00 00 00       	mov    $0x10,%edx
80102b80:	89 d8                	mov    %ebx,%eax
80102b82:	e8 a1 ff ff ff       	call   80102b28 <sum>
80102b87:	84 c0                	test   %al,%al
80102b89:	75 d2                	jne    80102b5d <mpsearch1+0x11>
80102b8b:	eb 05                	jmp    80102b92 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102b8d:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102b92:	89 d8                	mov    %ebx,%eax
80102b94:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102b97:	5b                   	pop    %ebx
80102b98:	5e                   	pop    %esi
80102b99:	5d                   	pop    %ebp
80102b9a:	c3                   	ret    

80102b9b <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102b9b:	55                   	push   %ebp
80102b9c:	89 e5                	mov    %esp,%ebp
80102b9e:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102ba1:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102ba8:	c1 e0 08             	shl    $0x8,%eax
80102bab:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102bb2:	09 d0                	or     %edx,%eax
80102bb4:	c1 e0 04             	shl    $0x4,%eax
80102bb7:	85 c0                	test   %eax,%eax
80102bb9:	74 1f                	je     80102bda <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102bbb:	ba 00 04 00 00       	mov    $0x400,%edx
80102bc0:	e8 87 ff ff ff       	call   80102b4c <mpsearch1>
80102bc5:	85 c0                	test   %eax,%eax
80102bc7:	75 0f                	jne    80102bd8 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102bc9:	ba 00 00 01 00       	mov    $0x10000,%edx
80102bce:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102bd3:	e8 74 ff ff ff       	call   80102b4c <mpsearch1>
}
80102bd8:	c9                   	leave  
80102bd9:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102bda:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102be1:	c1 e0 08             	shl    $0x8,%eax
80102be4:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102beb:	09 d0                	or     %edx,%eax
80102bed:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102bf0:	2d 00 04 00 00       	sub    $0x400,%eax
80102bf5:	ba 00 04 00 00       	mov    $0x400,%edx
80102bfa:	e8 4d ff ff ff       	call   80102b4c <mpsearch1>
80102bff:	85 c0                	test   %eax,%eax
80102c01:	75 d5                	jne    80102bd8 <mpsearch+0x3d>
80102c03:	eb c4                	jmp    80102bc9 <mpsearch+0x2e>

80102c05 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102c05:	55                   	push   %ebp
80102c06:	89 e5                	mov    %esp,%ebp
80102c08:	57                   	push   %edi
80102c09:	56                   	push   %esi
80102c0a:	53                   	push   %ebx
80102c0b:	83 ec 1c             	sub    $0x1c,%esp
80102c0e:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102c11:	e8 85 ff ff ff       	call   80102b9b <mpsearch>
80102c16:	85 c0                	test   %eax,%eax
80102c18:	74 5c                	je     80102c76 <mpconfig+0x71>
80102c1a:	89 c7                	mov    %eax,%edi
80102c1c:	8b 58 04             	mov    0x4(%eax),%ebx
80102c1f:	85 db                	test   %ebx,%ebx
80102c21:	74 5a                	je     80102c7d <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102c23:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102c29:	83 ec 04             	sub    $0x4,%esp
80102c2c:	6a 04                	push   $0x4
80102c2e:	68 fd 69 10 80       	push   $0x801069fd
80102c33:	56                   	push   %esi
80102c34:	e8 90 10 00 00       	call   80103cc9 <memcmp>
80102c39:	83 c4 10             	add    $0x10,%esp
80102c3c:	85 c0                	test   %eax,%eax
80102c3e:	75 44                	jne    80102c84 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102c40:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102c47:	3c 01                	cmp    $0x1,%al
80102c49:	0f 95 c2             	setne  %dl
80102c4c:	3c 04                	cmp    $0x4,%al
80102c4e:	0f 95 c0             	setne  %al
80102c51:	84 c2                	test   %al,%dl
80102c53:	75 36                	jne    80102c8b <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102c55:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102c5c:	89 f0                	mov    %esi,%eax
80102c5e:	e8 c5 fe ff ff       	call   80102b28 <sum>
80102c63:	84 c0                	test   %al,%al
80102c65:	75 2b                	jne    80102c92 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102c67:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102c6a:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102c6c:	89 f0                	mov    %esi,%eax
80102c6e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102c71:	5b                   	pop    %ebx
80102c72:	5e                   	pop    %esi
80102c73:	5f                   	pop    %edi
80102c74:	5d                   	pop    %ebp
80102c75:	c3                   	ret    
    return 0;
80102c76:	be 00 00 00 00       	mov    $0x0,%esi
80102c7b:	eb ef                	jmp    80102c6c <mpconfig+0x67>
80102c7d:	be 00 00 00 00       	mov    $0x0,%esi
80102c82:	eb e8                	jmp    80102c6c <mpconfig+0x67>
    return 0;
80102c84:	be 00 00 00 00       	mov    $0x0,%esi
80102c89:	eb e1                	jmp    80102c6c <mpconfig+0x67>
    return 0;
80102c8b:	be 00 00 00 00       	mov    $0x0,%esi
80102c90:	eb da                	jmp    80102c6c <mpconfig+0x67>
    return 0;
80102c92:	be 00 00 00 00       	mov    $0x0,%esi
80102c97:	eb d3                	jmp    80102c6c <mpconfig+0x67>

80102c99 <mpinit>:

void
mpinit(void)
{
80102c99:	55                   	push   %ebp
80102c9a:	89 e5                	mov    %esp,%ebp
80102c9c:	57                   	push   %edi
80102c9d:	56                   	push   %esi
80102c9e:	53                   	push   %ebx
80102c9f:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102ca2:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102ca5:	e8 5b ff ff ff       	call   80102c05 <mpconfig>
80102caa:	85 c0                	test   %eax,%eax
80102cac:	74 19                	je     80102cc7 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102cae:	8b 50 24             	mov    0x24(%eax),%edx
80102cb1:	89 15 a0 96 16 80    	mov    %edx,0x801696a0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cb7:	8d 50 2c             	lea    0x2c(%eax),%edx
80102cba:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102cbe:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102cc0:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cc5:	eb 34                	jmp    80102cfb <mpinit+0x62>
    panic("Expect to run on an SMP");
80102cc7:	83 ec 0c             	sub    $0xc,%esp
80102cca:	68 02 6a 10 80       	push   $0x80106a02
80102ccf:	e8 74 d6 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102cd4:	8b 35 40 9d 16 80    	mov    0x80169d40,%esi
80102cda:	83 fe 07             	cmp    $0x7,%esi
80102cdd:	7f 19                	jg     80102cf8 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102cdf:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102ce3:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102ce9:	88 87 c0 97 16 80    	mov    %al,-0x7fe96840(%edi)
        ncpu++;
80102cef:	83 c6 01             	add    $0x1,%esi
80102cf2:	89 35 40 9d 16 80    	mov    %esi,0x80169d40
      }
      p += sizeof(struct mpproc);
80102cf8:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102cfb:	39 ca                	cmp    %ecx,%edx
80102cfd:	73 2b                	jae    80102d2a <mpinit+0x91>
    switch(*p){
80102cff:	0f b6 02             	movzbl (%edx),%eax
80102d02:	3c 04                	cmp    $0x4,%al
80102d04:	77 1d                	ja     80102d23 <mpinit+0x8a>
80102d06:	0f b6 c0             	movzbl %al,%eax
80102d09:	ff 24 85 3c 6a 10 80 	jmp    *-0x7fef95c4(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102d10:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102d14:	a2 a0 97 16 80       	mov    %al,0x801697a0
      p += sizeof(struct mpioapic);
80102d19:	83 c2 08             	add    $0x8,%edx
      continue;
80102d1c:	eb dd                	jmp    80102cfb <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102d1e:	83 c2 08             	add    $0x8,%edx
      continue;
80102d21:	eb d8                	jmp    80102cfb <mpinit+0x62>
    default:
      ismp = 0;
80102d23:	bb 00 00 00 00       	mov    $0x0,%ebx
80102d28:	eb d1                	jmp    80102cfb <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102d2a:	85 db                	test   %ebx,%ebx
80102d2c:	74 26                	je     80102d54 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102d2e:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102d31:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102d35:	74 15                	je     80102d4c <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d37:	b8 70 00 00 00       	mov    $0x70,%eax
80102d3c:	ba 22 00 00 00       	mov    $0x22,%edx
80102d41:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102d42:	ba 23 00 00 00       	mov    $0x23,%edx
80102d47:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102d48:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102d4b:	ee                   	out    %al,(%dx)
  }
}
80102d4c:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102d4f:	5b                   	pop    %ebx
80102d50:	5e                   	pop    %esi
80102d51:	5f                   	pop    %edi
80102d52:	5d                   	pop    %ebp
80102d53:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102d54:	83 ec 0c             	sub    $0xc,%esp
80102d57:	68 1c 6a 10 80       	push   $0x80106a1c
80102d5c:	e8 e7 d5 ff ff       	call   80100348 <panic>

80102d61 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102d61:	55                   	push   %ebp
80102d62:	89 e5                	mov    %esp,%ebp
80102d64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102d69:	ba 21 00 00 00       	mov    $0x21,%edx
80102d6e:	ee                   	out    %al,(%dx)
80102d6f:	ba a1 00 00 00       	mov    $0xa1,%edx
80102d74:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102d75:	5d                   	pop    %ebp
80102d76:	c3                   	ret    

80102d77 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102d77:	55                   	push   %ebp
80102d78:	89 e5                	mov    %esp,%ebp
80102d7a:	57                   	push   %edi
80102d7b:	56                   	push   %esi
80102d7c:	53                   	push   %ebx
80102d7d:	83 ec 0c             	sub    $0xc,%esp
80102d80:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102d83:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102d86:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102d8c:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102d92:	e8 96 de ff ff       	call   80100c2d <filealloc>
80102d97:	89 03                	mov    %eax,(%ebx)
80102d99:	85 c0                	test   %eax,%eax
80102d9b:	74 16                	je     80102db3 <pipealloc+0x3c>
80102d9d:	e8 8b de ff ff       	call   80100c2d <filealloc>
80102da2:	89 06                	mov    %eax,(%esi)
80102da4:	85 c0                	test   %eax,%eax
80102da6:	74 0b                	je     80102db3 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102da8:	e8 0e f3 ff ff       	call   801020bb <kalloc>
80102dad:	89 c7                	mov    %eax,%edi
80102daf:	85 c0                	test   %eax,%eax
80102db1:	75 35                	jne    80102de8 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102db3:	8b 03                	mov    (%ebx),%eax
80102db5:	85 c0                	test   %eax,%eax
80102db7:	74 0c                	je     80102dc5 <pipealloc+0x4e>
    fileclose(*f0);
80102db9:	83 ec 0c             	sub    $0xc,%esp
80102dbc:	50                   	push   %eax
80102dbd:	e8 11 df ff ff       	call   80100cd3 <fileclose>
80102dc2:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102dc5:	8b 06                	mov    (%esi),%eax
80102dc7:	85 c0                	test   %eax,%eax
80102dc9:	0f 84 8b 00 00 00    	je     80102e5a <pipealloc+0xe3>
    fileclose(*f1);
80102dcf:	83 ec 0c             	sub    $0xc,%esp
80102dd2:	50                   	push   %eax
80102dd3:	e8 fb de ff ff       	call   80100cd3 <fileclose>
80102dd8:	83 c4 10             	add    $0x10,%esp
  return -1;
80102ddb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102de0:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102de3:	5b                   	pop    %ebx
80102de4:	5e                   	pop    %esi
80102de5:	5f                   	pop    %edi
80102de6:	5d                   	pop    %ebp
80102de7:	c3                   	ret    
  p->readopen = 1;
80102de8:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102def:	00 00 00 
  p->writeopen = 1;
80102df2:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102df9:	00 00 00 
  p->nwrite = 0;
80102dfc:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102e03:	00 00 00 
  p->nread = 0;
80102e06:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102e0d:	00 00 00 
  initlock(&p->lock, "pipe");
80102e10:	83 ec 08             	sub    $0x8,%esp
80102e13:	68 50 6a 10 80       	push   $0x80106a50
80102e18:	50                   	push   %eax
80102e19:	e8 7d 0c 00 00       	call   80103a9b <initlock>
  (*f0)->type = FD_PIPE;
80102e1e:	8b 03                	mov    (%ebx),%eax
80102e20:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102e26:	8b 03                	mov    (%ebx),%eax
80102e28:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102e2c:	8b 03                	mov    (%ebx),%eax
80102e2e:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102e32:	8b 03                	mov    (%ebx),%eax
80102e34:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102e37:	8b 06                	mov    (%esi),%eax
80102e39:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102e3f:	8b 06                	mov    (%esi),%eax
80102e41:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102e45:	8b 06                	mov    (%esi),%eax
80102e47:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102e4b:	8b 06                	mov    (%esi),%eax
80102e4d:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102e50:	83 c4 10             	add    $0x10,%esp
80102e53:	b8 00 00 00 00       	mov    $0x0,%eax
80102e58:	eb 86                	jmp    80102de0 <pipealloc+0x69>
  return -1;
80102e5a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102e5f:	e9 7c ff ff ff       	jmp    80102de0 <pipealloc+0x69>

80102e64 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102e64:	55                   	push   %ebp
80102e65:	89 e5                	mov    %esp,%ebp
80102e67:	53                   	push   %ebx
80102e68:	83 ec 10             	sub    $0x10,%esp
80102e6b:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102e6e:	53                   	push   %ebx
80102e6f:	e8 63 0d 00 00       	call   80103bd7 <acquire>
  if(writable){
80102e74:	83 c4 10             	add    $0x10,%esp
80102e77:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102e7b:	74 3f                	je     80102ebc <pipeclose+0x58>
    p->writeopen = 0;
80102e7d:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102e84:	00 00 00 
    wakeup(&p->nread);
80102e87:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102e8d:	83 ec 0c             	sub    $0xc,%esp
80102e90:	50                   	push   %eax
80102e91:	e8 ab 09 00 00       	call   80103841 <wakeup>
80102e96:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102e99:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102ea0:	75 09                	jne    80102eab <pipeclose+0x47>
80102ea2:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102ea9:	74 2f                	je     80102eda <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102eab:	83 ec 0c             	sub    $0xc,%esp
80102eae:	53                   	push   %ebx
80102eaf:	e8 88 0d 00 00       	call   80103c3c <release>
80102eb4:	83 c4 10             	add    $0x10,%esp
}
80102eb7:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102eba:	c9                   	leave  
80102ebb:	c3                   	ret    
    p->readopen = 0;
80102ebc:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80102ec3:	00 00 00 
    wakeup(&p->nwrite);
80102ec6:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102ecc:	83 ec 0c             	sub    $0xc,%esp
80102ecf:	50                   	push   %eax
80102ed0:	e8 6c 09 00 00       	call   80103841 <wakeup>
80102ed5:	83 c4 10             	add    $0x10,%esp
80102ed8:	eb bf                	jmp    80102e99 <pipeclose+0x35>
    release(&p->lock);
80102eda:	83 ec 0c             	sub    $0xc,%esp
80102edd:	53                   	push   %ebx
80102ede:	e8 59 0d 00 00       	call   80103c3c <release>
    kfree((char*)p);
80102ee3:	89 1c 24             	mov    %ebx,(%esp)
80102ee6:	e8 b9 f0 ff ff       	call   80101fa4 <kfree>
80102eeb:	83 c4 10             	add    $0x10,%esp
80102eee:	eb c7                	jmp    80102eb7 <pipeclose+0x53>

80102ef0 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80102ef0:	55                   	push   %ebp
80102ef1:	89 e5                	mov    %esp,%ebp
80102ef3:	57                   	push   %edi
80102ef4:	56                   	push   %esi
80102ef5:	53                   	push   %ebx
80102ef6:	83 ec 18             	sub    $0x18,%esp
80102ef9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102efc:	89 de                	mov    %ebx,%esi
80102efe:	53                   	push   %ebx
80102eff:	e8 d3 0c 00 00       	call   80103bd7 <acquire>
  for(i = 0; i < n; i++){
80102f04:	83 c4 10             	add    $0x10,%esp
80102f07:	bf 00 00 00 00       	mov    $0x0,%edi
80102f0c:	3b 7d 10             	cmp    0x10(%ebp),%edi
80102f0f:	0f 8d 88 00 00 00    	jge    80102f9d <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80102f15:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
80102f1b:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80102f21:	05 00 02 00 00       	add    $0x200,%eax
80102f26:	39 c2                	cmp    %eax,%edx
80102f28:	75 51                	jne    80102f7b <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
80102f2a:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102f31:	74 2f                	je     80102f62 <pipewrite+0x72>
80102f33:	e8 00 03 00 00       	call   80103238 <myproc>
80102f38:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102f3c:	75 24                	jne    80102f62 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
80102f3e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102f44:	83 ec 0c             	sub    $0xc,%esp
80102f47:	50                   	push   %eax
80102f48:	e8 f4 08 00 00       	call   80103841 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
80102f4d:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80102f53:	83 c4 08             	add    $0x8,%esp
80102f56:	56                   	push   %esi
80102f57:	50                   	push   %eax
80102f58:	e8 7f 07 00 00       	call   801036dc <sleep>
80102f5d:	83 c4 10             	add    $0x10,%esp
80102f60:	eb b3                	jmp    80102f15 <pipewrite+0x25>
        release(&p->lock);
80102f62:	83 ec 0c             	sub    $0xc,%esp
80102f65:	53                   	push   %ebx
80102f66:	e8 d1 0c 00 00       	call   80103c3c <release>
        return -1;
80102f6b:	83 c4 10             	add    $0x10,%esp
80102f6e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
80102f73:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f76:	5b                   	pop    %ebx
80102f77:	5e                   	pop    %esi
80102f78:	5f                   	pop    %edi
80102f79:	5d                   	pop    %ebp
80102f7a:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80102f7b:	8d 42 01             	lea    0x1(%edx),%eax
80102f7e:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
80102f84:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80102f8a:	8b 45 0c             	mov    0xc(%ebp),%eax
80102f8d:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80102f91:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
80102f95:	83 c7 01             	add    $0x1,%edi
80102f98:	e9 6f ff ff ff       	jmp    80102f0c <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80102f9d:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fa3:	83 ec 0c             	sub    $0xc,%esp
80102fa6:	50                   	push   %eax
80102fa7:	e8 95 08 00 00       	call   80103841 <wakeup>
  release(&p->lock);
80102fac:	89 1c 24             	mov    %ebx,(%esp)
80102faf:	e8 88 0c 00 00       	call   80103c3c <release>
  return n;
80102fb4:	83 c4 10             	add    $0x10,%esp
80102fb7:	8b 45 10             	mov    0x10(%ebp),%eax
80102fba:	eb b7                	jmp    80102f73 <pipewrite+0x83>

80102fbc <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80102fbc:	55                   	push   %ebp
80102fbd:	89 e5                	mov    %esp,%ebp
80102fbf:	57                   	push   %edi
80102fc0:	56                   	push   %esi
80102fc1:	53                   	push   %ebx
80102fc2:	83 ec 18             	sub    $0x18,%esp
80102fc5:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80102fc8:	89 df                	mov    %ebx,%edi
80102fca:	53                   	push   %ebx
80102fcb:	e8 07 0c 00 00       	call   80103bd7 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80102fd0:	83 c4 10             	add    $0x10,%esp
80102fd3:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80102fd9:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80102fdf:	75 3d                	jne    8010301e <piperead+0x62>
80102fe1:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80102fe7:	85 f6                	test   %esi,%esi
80102fe9:	74 38                	je     80103023 <piperead+0x67>
    if(myproc()->killed){
80102feb:	e8 48 02 00 00       	call   80103238 <myproc>
80102ff0:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80102ff4:	75 15                	jne    8010300b <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80102ff6:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102ffc:	83 ec 08             	sub    $0x8,%esp
80102fff:	57                   	push   %edi
80103000:	50                   	push   %eax
80103001:	e8 d6 06 00 00       	call   801036dc <sleep>
80103006:	83 c4 10             	add    $0x10,%esp
80103009:	eb c8                	jmp    80102fd3 <piperead+0x17>
      release(&p->lock);
8010300b:	83 ec 0c             	sub    $0xc,%esp
8010300e:	53                   	push   %ebx
8010300f:	e8 28 0c 00 00       	call   80103c3c <release>
      return -1;
80103014:	83 c4 10             	add    $0x10,%esp
80103017:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010301c:	eb 50                	jmp    8010306e <piperead+0xb2>
8010301e:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103023:	3b 75 10             	cmp    0x10(%ebp),%esi
80103026:	7d 2c                	jge    80103054 <piperead+0x98>
    if(p->nread == p->nwrite)
80103028:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010302e:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103034:	74 1e                	je     80103054 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103036:	8d 50 01             	lea    0x1(%eax),%edx
80103039:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
8010303f:	25 ff 01 00 00       	and    $0x1ff,%eax
80103044:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
80103049:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010304c:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
8010304f:	83 c6 01             	add    $0x1,%esi
80103052:	eb cf                	jmp    80103023 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
80103054:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010305a:	83 ec 0c             	sub    $0xc,%esp
8010305d:	50                   	push   %eax
8010305e:	e8 de 07 00 00       	call   80103841 <wakeup>
  release(&p->lock);
80103063:	89 1c 24             	mov    %ebx,(%esp)
80103066:	e8 d1 0b 00 00       	call   80103c3c <release>
  return i;
8010306b:	83 c4 10             	add    $0x10,%esp
}
8010306e:	89 f0                	mov    %esi,%eax
80103070:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103073:	5b                   	pop    %ebx
80103074:	5e                   	pop    %esi
80103075:	5f                   	pop    %edi
80103076:	5d                   	pop    %ebp
80103077:	c3                   	ret    

80103078 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103078:	55                   	push   %ebp
80103079:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010307b:	ba 94 9d 16 80       	mov    $0x80169d94,%edx
80103080:	eb 03                	jmp    80103085 <wakeup1+0xd>
80103082:	83 c2 7c             	add    $0x7c,%edx
80103085:	81 fa 94 bc 16 80    	cmp    $0x8016bc94,%edx
8010308b:	73 14                	jae    801030a1 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
8010308d:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103091:	75 ef                	jne    80103082 <wakeup1+0xa>
80103093:	39 42 20             	cmp    %eax,0x20(%edx)
80103096:	75 ea                	jne    80103082 <wakeup1+0xa>
      p->state = RUNNABLE;
80103098:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
8010309f:	eb e1                	jmp    80103082 <wakeup1+0xa>
}
801030a1:	5d                   	pop    %ebp
801030a2:	c3                   	ret    

801030a3 <allocproc>:
{
801030a3:	55                   	push   %ebp
801030a4:	89 e5                	mov    %esp,%ebp
801030a6:	53                   	push   %ebx
801030a7:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801030aa:	68 60 9d 16 80       	push   $0x80169d60
801030af:	e8 23 0b 00 00       	call   80103bd7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030b4:	83 c4 10             	add    $0x10,%esp
801030b7:	bb 94 9d 16 80       	mov    $0x80169d94,%ebx
801030bc:	81 fb 94 bc 16 80    	cmp    $0x8016bc94,%ebx
801030c2:	73 0b                	jae    801030cf <allocproc+0x2c>
    if(p->state == UNUSED)
801030c4:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
801030c8:	74 1c                	je     801030e6 <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801030ca:	83 c3 7c             	add    $0x7c,%ebx
801030cd:	eb ed                	jmp    801030bc <allocproc+0x19>
  release(&ptable.lock);
801030cf:	83 ec 0c             	sub    $0xc,%esp
801030d2:	68 60 9d 16 80       	push   $0x80169d60
801030d7:	e8 60 0b 00 00       	call   80103c3c <release>
  return 0;
801030dc:	83 c4 10             	add    $0x10,%esp
801030df:	bb 00 00 00 00       	mov    $0x0,%ebx
801030e4:	eb 69                	jmp    8010314f <allocproc+0xac>
  p->state = EMBRYO;
801030e6:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
801030ed:	a1 04 90 10 80       	mov    0x80109004,%eax
801030f2:	8d 50 01             	lea    0x1(%eax),%edx
801030f5:	89 15 04 90 10 80    	mov    %edx,0x80109004
801030fb:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
801030fe:	83 ec 0c             	sub    $0xc,%esp
80103101:	68 60 9d 16 80       	push   $0x80169d60
80103106:	e8 31 0b 00 00       	call   80103c3c <release>
  if((p->kstack = kalloc()) == 0){
8010310b:	e8 ab ef ff ff       	call   801020bb <kalloc>
80103110:	89 43 08             	mov    %eax,0x8(%ebx)
80103113:	83 c4 10             	add    $0x10,%esp
80103116:	85 c0                	test   %eax,%eax
80103118:	74 3c                	je     80103156 <allocproc+0xb3>
  sp -= sizeof *p->tf;
8010311a:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103120:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
80103123:	c7 80 b0 0f 00 00 bd 	movl   $0x80104dbd,0xfb0(%eax)
8010312a:	4d 10 80 
  sp -= sizeof *p->context;
8010312d:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103132:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
80103135:	83 ec 04             	sub    $0x4,%esp
80103138:	6a 14                	push   $0x14
8010313a:	6a 00                	push   $0x0
8010313c:	50                   	push   %eax
8010313d:	e8 41 0b 00 00       	call   80103c83 <memset>
  p->context->eip = (uint)forkret;
80103142:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103145:	c7 40 10 64 31 10 80 	movl   $0x80103164,0x10(%eax)
  return p;
8010314c:	83 c4 10             	add    $0x10,%esp
}
8010314f:	89 d8                	mov    %ebx,%eax
80103151:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103154:	c9                   	leave  
80103155:	c3                   	ret    
    p->state = UNUSED;
80103156:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
8010315d:	bb 00 00 00 00       	mov    $0x0,%ebx
80103162:	eb eb                	jmp    8010314f <allocproc+0xac>

80103164 <forkret>:
{
80103164:	55                   	push   %ebp
80103165:	89 e5                	mov    %esp,%ebp
80103167:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
8010316a:	68 60 9d 16 80       	push   $0x80169d60
8010316f:	e8 c8 0a 00 00       	call   80103c3c <release>
  if (first) {
80103174:	83 c4 10             	add    $0x10,%esp
80103177:	83 3d 00 90 10 80 00 	cmpl   $0x0,0x80109000
8010317e:	75 02                	jne    80103182 <forkret+0x1e>
}
80103180:	c9                   	leave  
80103181:	c3                   	ret    
    first = 0;
80103182:	c7 05 00 90 10 80 00 	movl   $0x0,0x80109000
80103189:	00 00 00 
    iinit(ROOTDEV);
8010318c:	83 ec 0c             	sub    $0xc,%esp
8010318f:	6a 01                	push   $0x1
80103191:	e8 56 e1 ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
80103196:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
8010319d:	e8 05 f6 ff ff       	call   801027a7 <initlog>
801031a2:	83 c4 10             	add    $0x10,%esp
}
801031a5:	eb d9                	jmp    80103180 <forkret+0x1c>

801031a7 <pinit>:
{
801031a7:	55                   	push   %ebp
801031a8:	89 e5                	mov    %esp,%ebp
801031aa:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
801031ad:	68 55 6a 10 80       	push   $0x80106a55
801031b2:	68 60 9d 16 80       	push   $0x80169d60
801031b7:	e8 df 08 00 00       	call   80103a9b <initlock>
}
801031bc:	83 c4 10             	add    $0x10,%esp
801031bf:	c9                   	leave  
801031c0:	c3                   	ret    

801031c1 <mycpu>:
{
801031c1:	55                   	push   %ebp
801031c2:	89 e5                	mov    %esp,%ebp
801031c4:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801031c7:	9c                   	pushf  
801031c8:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801031c9:	f6 c4 02             	test   $0x2,%ah
801031cc:	75 28                	jne    801031f6 <mycpu+0x35>
  apicid = lapicid();
801031ce:	e8 ed f1 ff ff       	call   801023c0 <lapicid>
  for (i = 0; i < ncpu; ++i) {
801031d3:	ba 00 00 00 00       	mov    $0x0,%edx
801031d8:	39 15 40 9d 16 80    	cmp    %edx,0x80169d40
801031de:	7e 23                	jle    80103203 <mycpu+0x42>
    if (cpus[i].apicid == apicid)
801031e0:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
801031e6:	0f b6 89 c0 97 16 80 	movzbl -0x7fe96840(%ecx),%ecx
801031ed:	39 c1                	cmp    %eax,%ecx
801031ef:	74 1f                	je     80103210 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
801031f1:	83 c2 01             	add    $0x1,%edx
801031f4:	eb e2                	jmp    801031d8 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
801031f6:	83 ec 0c             	sub    $0xc,%esp
801031f9:	68 38 6b 10 80       	push   $0x80106b38
801031fe:	e8 45 d1 ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
80103203:	83 ec 0c             	sub    $0xc,%esp
80103206:	68 5c 6a 10 80       	push   $0x80106a5c
8010320b:	e8 38 d1 ff ff       	call   80100348 <panic>
      return &cpus[i];
80103210:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
80103216:	05 c0 97 16 80       	add    $0x801697c0,%eax
}
8010321b:	c9                   	leave  
8010321c:	c3                   	ret    

8010321d <cpuid>:
cpuid() {
8010321d:	55                   	push   %ebp
8010321e:	89 e5                	mov    %esp,%ebp
80103220:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
80103223:	e8 99 ff ff ff       	call   801031c1 <mycpu>
80103228:	2d c0 97 16 80       	sub    $0x801697c0,%eax
8010322d:	c1 f8 04             	sar    $0x4,%eax
80103230:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
80103236:	c9                   	leave  
80103237:	c3                   	ret    

80103238 <myproc>:
myproc(void) {
80103238:	55                   	push   %ebp
80103239:	89 e5                	mov    %esp,%ebp
8010323b:	53                   	push   %ebx
8010323c:	83 ec 04             	sub    $0x4,%esp
  pushcli();
8010323f:	e8 b6 08 00 00       	call   80103afa <pushcli>
  c = mycpu();
80103244:	e8 78 ff ff ff       	call   801031c1 <mycpu>
  p = c->proc;
80103249:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
8010324f:	e8 e3 08 00 00       	call   80103b37 <popcli>
}
80103254:	89 d8                	mov    %ebx,%eax
80103256:	83 c4 04             	add    $0x4,%esp
80103259:	5b                   	pop    %ebx
8010325a:	5d                   	pop    %ebp
8010325b:	c3                   	ret    

8010325c <userinit>:
{
8010325c:	55                   	push   %ebp
8010325d:	89 e5                	mov    %esp,%ebp
8010325f:	53                   	push   %ebx
80103260:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
80103263:	e8 3b fe ff ff       	call   801030a3 <allocproc>
80103268:	89 c3                	mov    %eax,%ebx
  initproc = p;
8010326a:	a3 bc 95 10 80       	mov    %eax,0x801095bc
  if((p->pgdir = setupkvm()) == 0)
8010326f:	e8 2d 30 00 00       	call   801062a1 <setupkvm>
80103274:	89 43 04             	mov    %eax,0x4(%ebx)
80103277:	85 c0                	test   %eax,%eax
80103279:	0f 84 b7 00 00 00    	je     80103336 <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
8010327f:	83 ec 04             	sub    $0x4,%esp
80103282:	68 2c 00 00 00       	push   $0x2c
80103287:	68 60 94 10 80       	push   $0x80109460
8010328c:	50                   	push   %eax
8010328d:	e8 1a 2d 00 00       	call   80105fac <inituvm>
  p->sz = PGSIZE;
80103292:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103298:	83 c4 0c             	add    $0xc,%esp
8010329b:	6a 4c                	push   $0x4c
8010329d:	6a 00                	push   $0x0
8010329f:	ff 73 18             	pushl  0x18(%ebx)
801032a2:	e8 dc 09 00 00       	call   80103c83 <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801032a7:	8b 43 18             	mov    0x18(%ebx),%eax
801032aa:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
801032b0:	8b 43 18             	mov    0x18(%ebx),%eax
801032b3:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
801032b9:	8b 43 18             	mov    0x18(%ebx),%eax
801032bc:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801032c0:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
801032c4:	8b 43 18             	mov    0x18(%ebx),%eax
801032c7:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
801032cb:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
801032cf:	8b 43 18             	mov    0x18(%ebx),%eax
801032d2:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
801032d9:	8b 43 18             	mov    0x18(%ebx),%eax
801032dc:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
801032e3:	8b 43 18             	mov    0x18(%ebx),%eax
801032e6:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
801032ed:	8d 43 6c             	lea    0x6c(%ebx),%eax
801032f0:	83 c4 0c             	add    $0xc,%esp
801032f3:	6a 10                	push   $0x10
801032f5:	68 85 6a 10 80       	push   $0x80106a85
801032fa:	50                   	push   %eax
801032fb:	e8 ea 0a 00 00       	call   80103dea <safestrcpy>
  p->cwd = namei("/");
80103300:	c7 04 24 8e 6a 10 80 	movl   $0x80106a8e,(%esp)
80103307:	e8 d5 e8 ff ff       	call   80101be1 <namei>
8010330c:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
8010330f:	c7 04 24 60 9d 16 80 	movl   $0x80169d60,(%esp)
80103316:	e8 bc 08 00 00       	call   80103bd7 <acquire>
  p->state = RUNNABLE;
8010331b:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103322:	c7 04 24 60 9d 16 80 	movl   $0x80169d60,(%esp)
80103329:	e8 0e 09 00 00       	call   80103c3c <release>
}
8010332e:	83 c4 10             	add    $0x10,%esp
80103331:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103334:	c9                   	leave  
80103335:	c3                   	ret    
    panic("userinit: out of memory?");
80103336:	83 ec 0c             	sub    $0xc,%esp
80103339:	68 6c 6a 10 80       	push   $0x80106a6c
8010333e:	e8 05 d0 ff ff       	call   80100348 <panic>

80103343 <growproc>:
{
80103343:	55                   	push   %ebp
80103344:	89 e5                	mov    %esp,%ebp
80103346:	56                   	push   %esi
80103347:	53                   	push   %ebx
80103348:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
8010334b:	e8 e8 fe ff ff       	call   80103238 <myproc>
80103350:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
80103352:	8b 00                	mov    (%eax),%eax
  if(n > 0){
80103354:	85 f6                	test   %esi,%esi
80103356:	7f 21                	jg     80103379 <growproc+0x36>
  } else if(n < 0){
80103358:	85 f6                	test   %esi,%esi
8010335a:	79 33                	jns    8010338f <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
8010335c:	83 ec 04             	sub    $0x4,%esp
8010335f:	01 c6                	add    %eax,%esi
80103361:	56                   	push   %esi
80103362:	50                   	push   %eax
80103363:	ff 73 04             	pushl  0x4(%ebx)
80103366:	e8 4a 2d 00 00       	call   801060b5 <deallocuvm>
8010336b:	83 c4 10             	add    $0x10,%esp
8010336e:	85 c0                	test   %eax,%eax
80103370:	75 1d                	jne    8010338f <growproc+0x4c>
      return -1;
80103372:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103377:	eb 29                	jmp    801033a2 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103379:	83 ec 04             	sub    $0x4,%esp
8010337c:	01 c6                	add    %eax,%esi
8010337e:	56                   	push   %esi
8010337f:	50                   	push   %eax
80103380:	ff 73 04             	pushl  0x4(%ebx)
80103383:	e8 bf 2d 00 00       	call   80106147 <allocuvm>
80103388:	83 c4 10             	add    $0x10,%esp
8010338b:	85 c0                	test   %eax,%eax
8010338d:	74 1a                	je     801033a9 <growproc+0x66>
  curproc->sz = sz;
8010338f:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103391:	83 ec 0c             	sub    $0xc,%esp
80103394:	53                   	push   %ebx
80103395:	e8 fa 2a 00 00       	call   80105e94 <switchuvm>
  return 0;
8010339a:	83 c4 10             	add    $0x10,%esp
8010339d:	b8 00 00 00 00       	mov    $0x0,%eax
}
801033a2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801033a5:	5b                   	pop    %ebx
801033a6:	5e                   	pop    %esi
801033a7:	5d                   	pop    %ebp
801033a8:	c3                   	ret    
      return -1;
801033a9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801033ae:	eb f2                	jmp    801033a2 <growproc+0x5f>

801033b0 <fork>:
{
801033b0:	55                   	push   %ebp
801033b1:	89 e5                	mov    %esp,%ebp
801033b3:	57                   	push   %edi
801033b4:	56                   	push   %esi
801033b5:	53                   	push   %ebx
801033b6:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
801033b9:	e8 7a fe ff ff       	call   80103238 <myproc>
801033be:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
801033c0:	e8 de fc ff ff       	call   801030a3 <allocproc>
801033c5:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801033c8:	85 c0                	test   %eax,%eax
801033ca:	0f 84 e0 00 00 00    	je     801034b0 <fork+0x100>
801033d0:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
801033d2:	83 ec 08             	sub    $0x8,%esp
801033d5:	ff 33                	pushl  (%ebx)
801033d7:	ff 73 04             	pushl  0x4(%ebx)
801033da:	e8 73 2f 00 00       	call   80106352 <copyuvm>
801033df:	89 47 04             	mov    %eax,0x4(%edi)
801033e2:	83 c4 10             	add    $0x10,%esp
801033e5:	85 c0                	test   %eax,%eax
801033e7:	74 2a                	je     80103413 <fork+0x63>
  np->sz = curproc->sz;
801033e9:	8b 03                	mov    (%ebx),%eax
801033eb:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
801033ee:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
801033f0:	89 c8                	mov    %ecx,%eax
801033f2:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
801033f5:	8b 73 18             	mov    0x18(%ebx),%esi
801033f8:	8b 79 18             	mov    0x18(%ecx),%edi
801033fb:	b9 13 00 00 00       	mov    $0x13,%ecx
80103400:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
80103402:	8b 40 18             	mov    0x18(%eax),%eax
80103405:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
8010340c:	be 00 00 00 00       	mov    $0x0,%esi
80103411:	eb 29                	jmp    8010343c <fork+0x8c>
    kfree(np->kstack);
80103413:	83 ec 0c             	sub    $0xc,%esp
80103416:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103419:	ff 73 08             	pushl  0x8(%ebx)
8010341c:	e8 83 eb ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
80103421:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103428:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
8010342f:	83 c4 10             	add    $0x10,%esp
80103432:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103437:	eb 6d                	jmp    801034a6 <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
80103439:	83 c6 01             	add    $0x1,%esi
8010343c:	83 fe 0f             	cmp    $0xf,%esi
8010343f:	7f 1d                	jg     8010345e <fork+0xae>
    if(curproc->ofile[i])
80103441:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
80103445:	85 c0                	test   %eax,%eax
80103447:	74 f0                	je     80103439 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
80103449:	83 ec 0c             	sub    $0xc,%esp
8010344c:	50                   	push   %eax
8010344d:	e8 3c d8 ff ff       	call   80100c8e <filedup>
80103452:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80103455:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
80103459:	83 c4 10             	add    $0x10,%esp
8010345c:	eb db                	jmp    80103439 <fork+0x89>
  np->cwd = idup(curproc->cwd);
8010345e:	83 ec 0c             	sub    $0xc,%esp
80103461:	ff 73 68             	pushl  0x68(%ebx)
80103464:	e8 e8 e0 ff ff       	call   80101551 <idup>
80103469:	8b 7d e4             	mov    -0x1c(%ebp),%edi
8010346c:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
8010346f:	83 c3 6c             	add    $0x6c,%ebx
80103472:	8d 47 6c             	lea    0x6c(%edi),%eax
80103475:	83 c4 0c             	add    $0xc,%esp
80103478:	6a 10                	push   $0x10
8010347a:	53                   	push   %ebx
8010347b:	50                   	push   %eax
8010347c:	e8 69 09 00 00       	call   80103dea <safestrcpy>
  pid = np->pid;
80103481:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
80103484:	c7 04 24 60 9d 16 80 	movl   $0x80169d60,(%esp)
8010348b:	e8 47 07 00 00       	call   80103bd7 <acquire>
  np->state = RUNNABLE;
80103490:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
80103497:	c7 04 24 60 9d 16 80 	movl   $0x80169d60,(%esp)
8010349e:	e8 99 07 00 00       	call   80103c3c <release>
  return pid;
801034a3:	83 c4 10             	add    $0x10,%esp
}
801034a6:	89 d8                	mov    %ebx,%eax
801034a8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801034ab:	5b                   	pop    %ebx
801034ac:	5e                   	pop    %esi
801034ad:	5f                   	pop    %edi
801034ae:	5d                   	pop    %ebp
801034af:	c3                   	ret    
    return -1;
801034b0:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801034b5:	eb ef                	jmp    801034a6 <fork+0xf6>

801034b7 <scheduler>:
{
801034b7:	55                   	push   %ebp
801034b8:	89 e5                	mov    %esp,%ebp
801034ba:	56                   	push   %esi
801034bb:	53                   	push   %ebx
  struct cpu *c = mycpu();
801034bc:	e8 00 fd ff ff       	call   801031c1 <mycpu>
801034c1:	89 c6                	mov    %eax,%esi
  c->proc = 0;
801034c3:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
801034ca:	00 00 00 
801034cd:	eb 5a                	jmp    80103529 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801034cf:	83 c3 7c             	add    $0x7c,%ebx
801034d2:	81 fb 94 bc 16 80    	cmp    $0x8016bc94,%ebx
801034d8:	73 3f                	jae    80103519 <scheduler+0x62>
      if(p->state != RUNNABLE)
801034da:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
801034de:	75 ef                	jne    801034cf <scheduler+0x18>
      c->proc = p;
801034e0:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
801034e6:	83 ec 0c             	sub    $0xc,%esp
801034e9:	53                   	push   %ebx
801034ea:	e8 a5 29 00 00       	call   80105e94 <switchuvm>
      p->state = RUNNING;
801034ef:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
801034f6:	83 c4 08             	add    $0x8,%esp
801034f9:	ff 73 1c             	pushl  0x1c(%ebx)
801034fc:	8d 46 04             	lea    0x4(%esi),%eax
801034ff:	50                   	push   %eax
80103500:	e8 38 09 00 00       	call   80103e3d <swtch>
      switchkvm();
80103505:	e8 78 29 00 00       	call   80105e82 <switchkvm>
      c->proc = 0;
8010350a:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103511:	00 00 00 
80103514:	83 c4 10             	add    $0x10,%esp
80103517:	eb b6                	jmp    801034cf <scheduler+0x18>
    release(&ptable.lock);
80103519:	83 ec 0c             	sub    $0xc,%esp
8010351c:	68 60 9d 16 80       	push   $0x80169d60
80103521:	e8 16 07 00 00       	call   80103c3c <release>
    sti();
80103526:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103529:	fb                   	sti    
    acquire(&ptable.lock);
8010352a:	83 ec 0c             	sub    $0xc,%esp
8010352d:	68 60 9d 16 80       	push   $0x80169d60
80103532:	e8 a0 06 00 00       	call   80103bd7 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103537:	83 c4 10             	add    $0x10,%esp
8010353a:	bb 94 9d 16 80       	mov    $0x80169d94,%ebx
8010353f:	eb 91                	jmp    801034d2 <scheduler+0x1b>

80103541 <sched>:
{
80103541:	55                   	push   %ebp
80103542:	89 e5                	mov    %esp,%ebp
80103544:	56                   	push   %esi
80103545:	53                   	push   %ebx
  struct proc *p = myproc();
80103546:	e8 ed fc ff ff       	call   80103238 <myproc>
8010354b:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
8010354d:	83 ec 0c             	sub    $0xc,%esp
80103550:	68 60 9d 16 80       	push   $0x80169d60
80103555:	e8 3d 06 00 00       	call   80103b97 <holding>
8010355a:	83 c4 10             	add    $0x10,%esp
8010355d:	85 c0                	test   %eax,%eax
8010355f:	74 4f                	je     801035b0 <sched+0x6f>
  if(mycpu()->ncli != 1)
80103561:	e8 5b fc ff ff       	call   801031c1 <mycpu>
80103566:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
8010356d:	75 4e                	jne    801035bd <sched+0x7c>
  if(p->state == RUNNING)
8010356f:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
80103573:	74 55                	je     801035ca <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103575:	9c                   	pushf  
80103576:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103577:	f6 c4 02             	test   $0x2,%ah
8010357a:	75 5b                	jne    801035d7 <sched+0x96>
  intena = mycpu()->intena;
8010357c:	e8 40 fc ff ff       	call   801031c1 <mycpu>
80103581:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
80103587:	e8 35 fc ff ff       	call   801031c1 <mycpu>
8010358c:	83 ec 08             	sub    $0x8,%esp
8010358f:	ff 70 04             	pushl  0x4(%eax)
80103592:	83 c3 1c             	add    $0x1c,%ebx
80103595:	53                   	push   %ebx
80103596:	e8 a2 08 00 00       	call   80103e3d <swtch>
  mycpu()->intena = intena;
8010359b:	e8 21 fc ff ff       	call   801031c1 <mycpu>
801035a0:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
801035a6:	83 c4 10             	add    $0x10,%esp
801035a9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801035ac:	5b                   	pop    %ebx
801035ad:	5e                   	pop    %esi
801035ae:	5d                   	pop    %ebp
801035af:	c3                   	ret    
    panic("sched ptable.lock");
801035b0:	83 ec 0c             	sub    $0xc,%esp
801035b3:	68 90 6a 10 80       	push   $0x80106a90
801035b8:	e8 8b cd ff ff       	call   80100348 <panic>
    panic("sched locks");
801035bd:	83 ec 0c             	sub    $0xc,%esp
801035c0:	68 a2 6a 10 80       	push   $0x80106aa2
801035c5:	e8 7e cd ff ff       	call   80100348 <panic>
    panic("sched running");
801035ca:	83 ec 0c             	sub    $0xc,%esp
801035cd:	68 ae 6a 10 80       	push   $0x80106aae
801035d2:	e8 71 cd ff ff       	call   80100348 <panic>
    panic("sched interruptible");
801035d7:	83 ec 0c             	sub    $0xc,%esp
801035da:	68 bc 6a 10 80       	push   $0x80106abc
801035df:	e8 64 cd ff ff       	call   80100348 <panic>

801035e4 <exit>:
{
801035e4:	55                   	push   %ebp
801035e5:	89 e5                	mov    %esp,%ebp
801035e7:	56                   	push   %esi
801035e8:	53                   	push   %ebx
  struct proc *curproc = myproc();
801035e9:	e8 4a fc ff ff       	call   80103238 <myproc>
  if(curproc == initproc)
801035ee:	39 05 bc 95 10 80    	cmp    %eax,0x801095bc
801035f4:	74 09                	je     801035ff <exit+0x1b>
801035f6:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
801035f8:	bb 00 00 00 00       	mov    $0x0,%ebx
801035fd:	eb 10                	jmp    8010360f <exit+0x2b>
    panic("init exiting");
801035ff:	83 ec 0c             	sub    $0xc,%esp
80103602:	68 d0 6a 10 80       	push   $0x80106ad0
80103607:	e8 3c cd ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
8010360c:	83 c3 01             	add    $0x1,%ebx
8010360f:	83 fb 0f             	cmp    $0xf,%ebx
80103612:	7f 1e                	jg     80103632 <exit+0x4e>
    if(curproc->ofile[fd]){
80103614:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103618:	85 c0                	test   %eax,%eax
8010361a:	74 f0                	je     8010360c <exit+0x28>
      fileclose(curproc->ofile[fd]);
8010361c:	83 ec 0c             	sub    $0xc,%esp
8010361f:	50                   	push   %eax
80103620:	e8 ae d6 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
80103625:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
8010362c:	00 
8010362d:	83 c4 10             	add    $0x10,%esp
80103630:	eb da                	jmp    8010360c <exit+0x28>
  begin_op();
80103632:	e8 b9 f1 ff ff       	call   801027f0 <begin_op>
  iput(curproc->cwd);
80103637:	83 ec 0c             	sub    $0xc,%esp
8010363a:	ff 76 68             	pushl  0x68(%esi)
8010363d:	e8 46 e0 ff ff       	call   80101688 <iput>
  end_op();
80103642:	e8 23 f2 ff ff       	call   8010286a <end_op>
  curproc->cwd = 0;
80103647:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
8010364e:	c7 04 24 60 9d 16 80 	movl   $0x80169d60,(%esp)
80103655:	e8 7d 05 00 00       	call   80103bd7 <acquire>
  wakeup1(curproc->parent);
8010365a:	8b 46 14             	mov    0x14(%esi),%eax
8010365d:	e8 16 fa ff ff       	call   80103078 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103662:	83 c4 10             	add    $0x10,%esp
80103665:	bb 94 9d 16 80       	mov    $0x80169d94,%ebx
8010366a:	eb 03                	jmp    8010366f <exit+0x8b>
8010366c:	83 c3 7c             	add    $0x7c,%ebx
8010366f:	81 fb 94 bc 16 80    	cmp    $0x8016bc94,%ebx
80103675:	73 1a                	jae    80103691 <exit+0xad>
    if(p->parent == curproc){
80103677:	39 73 14             	cmp    %esi,0x14(%ebx)
8010367a:	75 f0                	jne    8010366c <exit+0x88>
      p->parent = initproc;
8010367c:	a1 bc 95 10 80       	mov    0x801095bc,%eax
80103681:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
80103684:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103688:	75 e2                	jne    8010366c <exit+0x88>
        wakeup1(initproc);
8010368a:	e8 e9 f9 ff ff       	call   80103078 <wakeup1>
8010368f:	eb db                	jmp    8010366c <exit+0x88>
  curproc->state = ZOMBIE;
80103691:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103698:	e8 a4 fe ff ff       	call   80103541 <sched>
  panic("zombie exit");
8010369d:	83 ec 0c             	sub    $0xc,%esp
801036a0:	68 dd 6a 10 80       	push   $0x80106add
801036a5:	e8 9e cc ff ff       	call   80100348 <panic>

801036aa <yield>:
{
801036aa:	55                   	push   %ebp
801036ab:	89 e5                	mov    %esp,%ebp
801036ad:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
801036b0:	68 60 9d 16 80       	push   $0x80169d60
801036b5:	e8 1d 05 00 00       	call   80103bd7 <acquire>
  myproc()->state = RUNNABLE;
801036ba:	e8 79 fb ff ff       	call   80103238 <myproc>
801036bf:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
801036c6:	e8 76 fe ff ff       	call   80103541 <sched>
  release(&ptable.lock);
801036cb:	c7 04 24 60 9d 16 80 	movl   $0x80169d60,(%esp)
801036d2:	e8 65 05 00 00       	call   80103c3c <release>
}
801036d7:	83 c4 10             	add    $0x10,%esp
801036da:	c9                   	leave  
801036db:	c3                   	ret    

801036dc <sleep>:
{
801036dc:	55                   	push   %ebp
801036dd:	89 e5                	mov    %esp,%ebp
801036df:	56                   	push   %esi
801036e0:	53                   	push   %ebx
801036e1:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
801036e4:	e8 4f fb ff ff       	call   80103238 <myproc>
  if(p == 0)
801036e9:	85 c0                	test   %eax,%eax
801036eb:	74 66                	je     80103753 <sleep+0x77>
801036ed:	89 c6                	mov    %eax,%esi
  if(lk == 0)
801036ef:	85 db                	test   %ebx,%ebx
801036f1:	74 6d                	je     80103760 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
801036f3:	81 fb 60 9d 16 80    	cmp    $0x80169d60,%ebx
801036f9:	74 18                	je     80103713 <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
801036fb:	83 ec 0c             	sub    $0xc,%esp
801036fe:	68 60 9d 16 80       	push   $0x80169d60
80103703:	e8 cf 04 00 00       	call   80103bd7 <acquire>
    release(lk);
80103708:	89 1c 24             	mov    %ebx,(%esp)
8010370b:	e8 2c 05 00 00       	call   80103c3c <release>
80103710:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
80103713:	8b 45 08             	mov    0x8(%ebp),%eax
80103716:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103719:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
80103720:	e8 1c fe ff ff       	call   80103541 <sched>
  p->chan = 0;
80103725:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
8010372c:	81 fb 60 9d 16 80    	cmp    $0x80169d60,%ebx
80103732:	74 18                	je     8010374c <sleep+0x70>
    release(&ptable.lock);
80103734:	83 ec 0c             	sub    $0xc,%esp
80103737:	68 60 9d 16 80       	push   $0x80169d60
8010373c:	e8 fb 04 00 00       	call   80103c3c <release>
    acquire(lk);
80103741:	89 1c 24             	mov    %ebx,(%esp)
80103744:	e8 8e 04 00 00       	call   80103bd7 <acquire>
80103749:	83 c4 10             	add    $0x10,%esp
}
8010374c:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010374f:	5b                   	pop    %ebx
80103750:	5e                   	pop    %esi
80103751:	5d                   	pop    %ebp
80103752:	c3                   	ret    
    panic("sleep");
80103753:	83 ec 0c             	sub    $0xc,%esp
80103756:	68 e9 6a 10 80       	push   $0x80106ae9
8010375b:	e8 e8 cb ff ff       	call   80100348 <panic>
    panic("sleep without lk");
80103760:	83 ec 0c             	sub    $0xc,%esp
80103763:	68 ef 6a 10 80       	push   $0x80106aef
80103768:	e8 db cb ff ff       	call   80100348 <panic>

8010376d <wait>:
{
8010376d:	55                   	push   %ebp
8010376e:	89 e5                	mov    %esp,%ebp
80103770:	56                   	push   %esi
80103771:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103772:	e8 c1 fa ff ff       	call   80103238 <myproc>
80103777:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103779:	83 ec 0c             	sub    $0xc,%esp
8010377c:	68 60 9d 16 80       	push   $0x80169d60
80103781:	e8 51 04 00 00       	call   80103bd7 <acquire>
80103786:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103789:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010378e:	bb 94 9d 16 80       	mov    $0x80169d94,%ebx
80103793:	eb 5b                	jmp    801037f0 <wait+0x83>
        pid = p->pid;
80103795:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103798:	83 ec 0c             	sub    $0xc,%esp
8010379b:	ff 73 08             	pushl  0x8(%ebx)
8010379e:	e8 01 e8 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
801037a3:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
801037aa:	83 c4 04             	add    $0x4,%esp
801037ad:	ff 73 04             	pushl  0x4(%ebx)
801037b0:	e8 7c 2a 00 00       	call   80106231 <freevm>
        p->pid = 0;
801037b5:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
801037bc:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
801037c3:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
801037c7:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
801037ce:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
801037d5:	c7 04 24 60 9d 16 80 	movl   $0x80169d60,(%esp)
801037dc:	e8 5b 04 00 00       	call   80103c3c <release>
        return pid;
801037e1:	83 c4 10             	add    $0x10,%esp
}
801037e4:	89 f0                	mov    %esi,%eax
801037e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801037e9:	5b                   	pop    %ebx
801037ea:	5e                   	pop    %esi
801037eb:	5d                   	pop    %ebp
801037ec:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037ed:	83 c3 7c             	add    $0x7c,%ebx
801037f0:	81 fb 94 bc 16 80    	cmp    $0x8016bc94,%ebx
801037f6:	73 12                	jae    8010380a <wait+0x9d>
      if(p->parent != curproc)
801037f8:	39 73 14             	cmp    %esi,0x14(%ebx)
801037fb:	75 f0                	jne    801037ed <wait+0x80>
      if(p->state == ZOMBIE){
801037fd:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103801:	74 92                	je     80103795 <wait+0x28>
      havekids = 1;
80103803:	b8 01 00 00 00       	mov    $0x1,%eax
80103808:	eb e3                	jmp    801037ed <wait+0x80>
    if(!havekids || curproc->killed){
8010380a:	85 c0                	test   %eax,%eax
8010380c:	74 06                	je     80103814 <wait+0xa7>
8010380e:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
80103812:	74 17                	je     8010382b <wait+0xbe>
      release(&ptable.lock);
80103814:	83 ec 0c             	sub    $0xc,%esp
80103817:	68 60 9d 16 80       	push   $0x80169d60
8010381c:	e8 1b 04 00 00       	call   80103c3c <release>
      return -1;
80103821:	83 c4 10             	add    $0x10,%esp
80103824:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103829:	eb b9                	jmp    801037e4 <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
8010382b:	83 ec 08             	sub    $0x8,%esp
8010382e:	68 60 9d 16 80       	push   $0x80169d60
80103833:	56                   	push   %esi
80103834:	e8 a3 fe ff ff       	call   801036dc <sleep>
    havekids = 0;
80103839:	83 c4 10             	add    $0x10,%esp
8010383c:	e9 48 ff ff ff       	jmp    80103789 <wait+0x1c>

80103841 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
80103841:	55                   	push   %ebp
80103842:	89 e5                	mov    %esp,%ebp
80103844:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
80103847:	68 60 9d 16 80       	push   $0x80169d60
8010384c:	e8 86 03 00 00       	call   80103bd7 <acquire>
  wakeup1(chan);
80103851:	8b 45 08             	mov    0x8(%ebp),%eax
80103854:	e8 1f f8 ff ff       	call   80103078 <wakeup1>
  release(&ptable.lock);
80103859:	c7 04 24 60 9d 16 80 	movl   $0x80169d60,(%esp)
80103860:	e8 d7 03 00 00       	call   80103c3c <release>
}
80103865:	83 c4 10             	add    $0x10,%esp
80103868:	c9                   	leave  
80103869:	c3                   	ret    

8010386a <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
8010386a:	55                   	push   %ebp
8010386b:	89 e5                	mov    %esp,%ebp
8010386d:	53                   	push   %ebx
8010386e:	83 ec 10             	sub    $0x10,%esp
80103871:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
80103874:	68 60 9d 16 80       	push   $0x80169d60
80103879:	e8 59 03 00 00       	call   80103bd7 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010387e:	83 c4 10             	add    $0x10,%esp
80103881:	b8 94 9d 16 80       	mov    $0x80169d94,%eax
80103886:	3d 94 bc 16 80       	cmp    $0x8016bc94,%eax
8010388b:	73 3a                	jae    801038c7 <kill+0x5d>
    if(p->pid == pid){
8010388d:	39 58 10             	cmp    %ebx,0x10(%eax)
80103890:	74 05                	je     80103897 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103892:	83 c0 7c             	add    $0x7c,%eax
80103895:	eb ef                	jmp    80103886 <kill+0x1c>
      p->killed = 1;
80103897:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
8010389e:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801038a2:	74 1a                	je     801038be <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
801038a4:	83 ec 0c             	sub    $0xc,%esp
801038a7:	68 60 9d 16 80       	push   $0x80169d60
801038ac:	e8 8b 03 00 00       	call   80103c3c <release>
      return 0;
801038b1:	83 c4 10             	add    $0x10,%esp
801038b4:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
801038b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801038bc:	c9                   	leave  
801038bd:	c3                   	ret    
        p->state = RUNNABLE;
801038be:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
801038c5:	eb dd                	jmp    801038a4 <kill+0x3a>
  release(&ptable.lock);
801038c7:	83 ec 0c             	sub    $0xc,%esp
801038ca:	68 60 9d 16 80       	push   $0x80169d60
801038cf:	e8 68 03 00 00       	call   80103c3c <release>
  return -1;
801038d4:	83 c4 10             	add    $0x10,%esp
801038d7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801038dc:	eb db                	jmp    801038b9 <kill+0x4f>

801038de <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
801038de:	55                   	push   %ebp
801038df:	89 e5                	mov    %esp,%ebp
801038e1:	56                   	push   %esi
801038e2:	53                   	push   %ebx
801038e3:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038e6:	bb 94 9d 16 80       	mov    $0x80169d94,%ebx
801038eb:	eb 33                	jmp    80103920 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
801038ed:	b8 00 6b 10 80       	mov    $0x80106b00,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
801038f2:	8d 53 6c             	lea    0x6c(%ebx),%edx
801038f5:	52                   	push   %edx
801038f6:	50                   	push   %eax
801038f7:	ff 73 10             	pushl  0x10(%ebx)
801038fa:	68 04 6b 10 80       	push   $0x80106b04
801038ff:	e8 07 cd ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103904:	83 c4 10             	add    $0x10,%esp
80103907:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
8010390b:	74 39                	je     80103946 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
8010390d:	83 ec 0c             	sub    $0xc,%esp
80103910:	68 9f 6e 10 80       	push   $0x80106e9f
80103915:	e8 f1 cc ff ff       	call   8010060b <cprintf>
8010391a:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
8010391d:	83 c3 7c             	add    $0x7c,%ebx
80103920:	81 fb 94 bc 16 80    	cmp    $0x8016bc94,%ebx
80103926:	73 61                	jae    80103989 <procdump+0xab>
    if(p->state == UNUSED)
80103928:	8b 43 0c             	mov    0xc(%ebx),%eax
8010392b:	85 c0                	test   %eax,%eax
8010392d:	74 ee                	je     8010391d <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
8010392f:	83 f8 05             	cmp    $0x5,%eax
80103932:	77 b9                	ja     801038ed <procdump+0xf>
80103934:	8b 04 85 60 6b 10 80 	mov    -0x7fef94a0(,%eax,4),%eax
8010393b:	85 c0                	test   %eax,%eax
8010393d:	75 b3                	jne    801038f2 <procdump+0x14>
      state = "???";
8010393f:	b8 00 6b 10 80       	mov    $0x80106b00,%eax
80103944:	eb ac                	jmp    801038f2 <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103946:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103949:	8b 40 0c             	mov    0xc(%eax),%eax
8010394c:	83 c0 08             	add    $0x8,%eax
8010394f:	83 ec 08             	sub    $0x8,%esp
80103952:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103955:	52                   	push   %edx
80103956:	50                   	push   %eax
80103957:	e8 5a 01 00 00       	call   80103ab6 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
8010395c:	83 c4 10             	add    $0x10,%esp
8010395f:	be 00 00 00 00       	mov    $0x0,%esi
80103964:	eb 14                	jmp    8010397a <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103966:	83 ec 08             	sub    $0x8,%esp
80103969:	50                   	push   %eax
8010396a:	68 41 65 10 80       	push   $0x80106541
8010396f:	e8 97 cc ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103974:	83 c6 01             	add    $0x1,%esi
80103977:	83 c4 10             	add    $0x10,%esp
8010397a:	83 fe 09             	cmp    $0x9,%esi
8010397d:	7f 8e                	jg     8010390d <procdump+0x2f>
8010397f:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103983:	85 c0                	test   %eax,%eax
80103985:	75 df                	jne    80103966 <procdump+0x88>
80103987:	eb 84                	jmp    8010390d <procdump+0x2f>
  }
}
80103989:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010398c:	5b                   	pop    %ebx
8010398d:	5e                   	pop    %esi
8010398e:	5d                   	pop    %ebp
8010398f:	c3                   	ret    

80103990 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103990:	55                   	push   %ebp
80103991:	89 e5                	mov    %esp,%ebp
80103993:	53                   	push   %ebx
80103994:	83 ec 0c             	sub    $0xc,%esp
80103997:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
8010399a:	68 78 6b 10 80       	push   $0x80106b78
8010399f:	8d 43 04             	lea    0x4(%ebx),%eax
801039a2:	50                   	push   %eax
801039a3:	e8 f3 00 00 00       	call   80103a9b <initlock>
  lk->name = name;
801039a8:	8b 45 0c             	mov    0xc(%ebp),%eax
801039ab:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
801039ae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
801039b4:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
801039bb:	83 c4 10             	add    $0x10,%esp
801039be:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801039c1:	c9                   	leave  
801039c2:	c3                   	ret    

801039c3 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
801039c3:	55                   	push   %ebp
801039c4:	89 e5                	mov    %esp,%ebp
801039c6:	56                   	push   %esi
801039c7:	53                   	push   %ebx
801039c8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
801039cb:	8d 73 04             	lea    0x4(%ebx),%esi
801039ce:	83 ec 0c             	sub    $0xc,%esp
801039d1:	56                   	push   %esi
801039d2:	e8 00 02 00 00       	call   80103bd7 <acquire>
  while (lk->locked) {
801039d7:	83 c4 10             	add    $0x10,%esp
801039da:	eb 0d                	jmp    801039e9 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
801039dc:	83 ec 08             	sub    $0x8,%esp
801039df:	56                   	push   %esi
801039e0:	53                   	push   %ebx
801039e1:	e8 f6 fc ff ff       	call   801036dc <sleep>
801039e6:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
801039e9:	83 3b 00             	cmpl   $0x0,(%ebx)
801039ec:	75 ee                	jne    801039dc <acquiresleep+0x19>
  }
  lk->locked = 1;
801039ee:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
801039f4:	e8 3f f8 ff ff       	call   80103238 <myproc>
801039f9:	8b 40 10             	mov    0x10(%eax),%eax
801039fc:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
801039ff:	83 ec 0c             	sub    $0xc,%esp
80103a02:	56                   	push   %esi
80103a03:	e8 34 02 00 00       	call   80103c3c <release>
}
80103a08:	83 c4 10             	add    $0x10,%esp
80103a0b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a0e:	5b                   	pop    %ebx
80103a0f:	5e                   	pop    %esi
80103a10:	5d                   	pop    %ebp
80103a11:	c3                   	ret    

80103a12 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103a12:	55                   	push   %ebp
80103a13:	89 e5                	mov    %esp,%ebp
80103a15:	56                   	push   %esi
80103a16:	53                   	push   %ebx
80103a17:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103a1a:	8d 73 04             	lea    0x4(%ebx),%esi
80103a1d:	83 ec 0c             	sub    $0xc,%esp
80103a20:	56                   	push   %esi
80103a21:	e8 b1 01 00 00       	call   80103bd7 <acquire>
  lk->locked = 0;
80103a26:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103a2c:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103a33:	89 1c 24             	mov    %ebx,(%esp)
80103a36:	e8 06 fe ff ff       	call   80103841 <wakeup>
  release(&lk->lk);
80103a3b:	89 34 24             	mov    %esi,(%esp)
80103a3e:	e8 f9 01 00 00       	call   80103c3c <release>
}
80103a43:	83 c4 10             	add    $0x10,%esp
80103a46:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a49:	5b                   	pop    %ebx
80103a4a:	5e                   	pop    %esi
80103a4b:	5d                   	pop    %ebp
80103a4c:	c3                   	ret    

80103a4d <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103a4d:	55                   	push   %ebp
80103a4e:	89 e5                	mov    %esp,%ebp
80103a50:	56                   	push   %esi
80103a51:	53                   	push   %ebx
80103a52:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103a55:	8d 73 04             	lea    0x4(%ebx),%esi
80103a58:	83 ec 0c             	sub    $0xc,%esp
80103a5b:	56                   	push   %esi
80103a5c:	e8 76 01 00 00       	call   80103bd7 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103a61:	83 c4 10             	add    $0x10,%esp
80103a64:	83 3b 00             	cmpl   $0x0,(%ebx)
80103a67:	75 17                	jne    80103a80 <holdingsleep+0x33>
80103a69:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103a6e:	83 ec 0c             	sub    $0xc,%esp
80103a71:	56                   	push   %esi
80103a72:	e8 c5 01 00 00       	call   80103c3c <release>
  return r;
}
80103a77:	89 d8                	mov    %ebx,%eax
80103a79:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103a7c:	5b                   	pop    %ebx
80103a7d:	5e                   	pop    %esi
80103a7e:	5d                   	pop    %ebp
80103a7f:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103a80:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103a83:	e8 b0 f7 ff ff       	call   80103238 <myproc>
80103a88:	3b 58 10             	cmp    0x10(%eax),%ebx
80103a8b:	74 07                	je     80103a94 <holdingsleep+0x47>
80103a8d:	bb 00 00 00 00       	mov    $0x0,%ebx
80103a92:	eb da                	jmp    80103a6e <holdingsleep+0x21>
80103a94:	bb 01 00 00 00       	mov    $0x1,%ebx
80103a99:	eb d3                	jmp    80103a6e <holdingsleep+0x21>

80103a9b <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103a9b:	55                   	push   %ebp
80103a9c:	89 e5                	mov    %esp,%ebp
80103a9e:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103aa1:	8b 55 0c             	mov    0xc(%ebp),%edx
80103aa4:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103aa7:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103aad:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103ab4:	5d                   	pop    %ebp
80103ab5:	c3                   	ret    

80103ab6 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103ab6:	55                   	push   %ebp
80103ab7:	89 e5                	mov    %esp,%ebp
80103ab9:	53                   	push   %ebx
80103aba:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103abd:	8b 45 08             	mov    0x8(%ebp),%eax
80103ac0:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103ac3:	b8 00 00 00 00       	mov    $0x0,%eax
80103ac8:	83 f8 09             	cmp    $0x9,%eax
80103acb:	7f 25                	jg     80103af2 <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103acd:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103ad3:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103ad9:	77 17                	ja     80103af2 <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103adb:	8b 5a 04             	mov    0x4(%edx),%ebx
80103ade:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103ae1:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103ae3:	83 c0 01             	add    $0x1,%eax
80103ae6:	eb e0                	jmp    80103ac8 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103ae8:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103aef:	83 c0 01             	add    $0x1,%eax
80103af2:	83 f8 09             	cmp    $0x9,%eax
80103af5:	7e f1                	jle    80103ae8 <getcallerpcs+0x32>
}
80103af7:	5b                   	pop    %ebx
80103af8:	5d                   	pop    %ebp
80103af9:	c3                   	ret    

80103afa <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103afa:	55                   	push   %ebp
80103afb:	89 e5                	mov    %esp,%ebp
80103afd:	53                   	push   %ebx
80103afe:	83 ec 04             	sub    $0x4,%esp
80103b01:	9c                   	pushf  
80103b02:	5b                   	pop    %ebx
  asm volatile("cli");
80103b03:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103b04:	e8 b8 f6 ff ff       	call   801031c1 <mycpu>
80103b09:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103b10:	74 12                	je     80103b24 <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103b12:	e8 aa f6 ff ff       	call   801031c1 <mycpu>
80103b17:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103b1e:	83 c4 04             	add    $0x4,%esp
80103b21:	5b                   	pop    %ebx
80103b22:	5d                   	pop    %ebp
80103b23:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103b24:	e8 98 f6 ff ff       	call   801031c1 <mycpu>
80103b29:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103b2f:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103b35:	eb db                	jmp    80103b12 <pushcli+0x18>

80103b37 <popcli>:

void
popcli(void)
{
80103b37:	55                   	push   %ebp
80103b38:	89 e5                	mov    %esp,%ebp
80103b3a:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103b3d:	9c                   	pushf  
80103b3e:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103b3f:	f6 c4 02             	test   $0x2,%ah
80103b42:	75 28                	jne    80103b6c <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103b44:	e8 78 f6 ff ff       	call   801031c1 <mycpu>
80103b49:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103b4f:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103b52:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103b58:	85 d2                	test   %edx,%edx
80103b5a:	78 1d                	js     80103b79 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103b5c:	e8 60 f6 ff ff       	call   801031c1 <mycpu>
80103b61:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103b68:	74 1c                	je     80103b86 <popcli+0x4f>
    sti();
}
80103b6a:	c9                   	leave  
80103b6b:	c3                   	ret    
    panic("popcli - interruptible");
80103b6c:	83 ec 0c             	sub    $0xc,%esp
80103b6f:	68 83 6b 10 80       	push   $0x80106b83
80103b74:	e8 cf c7 ff ff       	call   80100348 <panic>
    panic("popcli");
80103b79:	83 ec 0c             	sub    $0xc,%esp
80103b7c:	68 9a 6b 10 80       	push   $0x80106b9a
80103b81:	e8 c2 c7 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103b86:	e8 36 f6 ff ff       	call   801031c1 <mycpu>
80103b8b:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103b92:	74 d6                	je     80103b6a <popcli+0x33>
  asm volatile("sti");
80103b94:	fb                   	sti    
}
80103b95:	eb d3                	jmp    80103b6a <popcli+0x33>

80103b97 <holding>:
{
80103b97:	55                   	push   %ebp
80103b98:	89 e5                	mov    %esp,%ebp
80103b9a:	53                   	push   %ebx
80103b9b:	83 ec 04             	sub    $0x4,%esp
80103b9e:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103ba1:	e8 54 ff ff ff       	call   80103afa <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103ba6:	83 3b 00             	cmpl   $0x0,(%ebx)
80103ba9:	75 12                	jne    80103bbd <holding+0x26>
80103bab:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103bb0:	e8 82 ff ff ff       	call   80103b37 <popcli>
}
80103bb5:	89 d8                	mov    %ebx,%eax
80103bb7:	83 c4 04             	add    $0x4,%esp
80103bba:	5b                   	pop    %ebx
80103bbb:	5d                   	pop    %ebp
80103bbc:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103bbd:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103bc0:	e8 fc f5 ff ff       	call   801031c1 <mycpu>
80103bc5:	39 c3                	cmp    %eax,%ebx
80103bc7:	74 07                	je     80103bd0 <holding+0x39>
80103bc9:	bb 00 00 00 00       	mov    $0x0,%ebx
80103bce:	eb e0                	jmp    80103bb0 <holding+0x19>
80103bd0:	bb 01 00 00 00       	mov    $0x1,%ebx
80103bd5:	eb d9                	jmp    80103bb0 <holding+0x19>

80103bd7 <acquire>:
{
80103bd7:	55                   	push   %ebp
80103bd8:	89 e5                	mov    %esp,%ebp
80103bda:	53                   	push   %ebx
80103bdb:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103bde:	e8 17 ff ff ff       	call   80103afa <pushcli>
  if(holding(lk))
80103be3:	83 ec 0c             	sub    $0xc,%esp
80103be6:	ff 75 08             	pushl  0x8(%ebp)
80103be9:	e8 a9 ff ff ff       	call   80103b97 <holding>
80103bee:	83 c4 10             	add    $0x10,%esp
80103bf1:	85 c0                	test   %eax,%eax
80103bf3:	75 3a                	jne    80103c2f <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103bf5:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103bf8:	b8 01 00 00 00       	mov    $0x1,%eax
80103bfd:	f0 87 02             	lock xchg %eax,(%edx)
80103c00:	85 c0                	test   %eax,%eax
80103c02:	75 f1                	jne    80103bf5 <acquire+0x1e>
  __sync_synchronize();
80103c04:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103c09:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103c0c:	e8 b0 f5 ff ff       	call   801031c1 <mycpu>
80103c11:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103c14:	8b 45 08             	mov    0x8(%ebp),%eax
80103c17:	83 c0 0c             	add    $0xc,%eax
80103c1a:	83 ec 08             	sub    $0x8,%esp
80103c1d:	50                   	push   %eax
80103c1e:	8d 45 08             	lea    0x8(%ebp),%eax
80103c21:	50                   	push   %eax
80103c22:	e8 8f fe ff ff       	call   80103ab6 <getcallerpcs>
}
80103c27:	83 c4 10             	add    $0x10,%esp
80103c2a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c2d:	c9                   	leave  
80103c2e:	c3                   	ret    
    panic("acquire");
80103c2f:	83 ec 0c             	sub    $0xc,%esp
80103c32:	68 a1 6b 10 80       	push   $0x80106ba1
80103c37:	e8 0c c7 ff ff       	call   80100348 <panic>

80103c3c <release>:
{
80103c3c:	55                   	push   %ebp
80103c3d:	89 e5                	mov    %esp,%ebp
80103c3f:	53                   	push   %ebx
80103c40:	83 ec 10             	sub    $0x10,%esp
80103c43:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103c46:	53                   	push   %ebx
80103c47:	e8 4b ff ff ff       	call   80103b97 <holding>
80103c4c:	83 c4 10             	add    $0x10,%esp
80103c4f:	85 c0                	test   %eax,%eax
80103c51:	74 23                	je     80103c76 <release+0x3a>
  lk->pcs[0] = 0;
80103c53:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103c5a:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103c61:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103c66:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103c6c:	e8 c6 fe ff ff       	call   80103b37 <popcli>
}
80103c71:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103c74:	c9                   	leave  
80103c75:	c3                   	ret    
    panic("release");
80103c76:	83 ec 0c             	sub    $0xc,%esp
80103c79:	68 a9 6b 10 80       	push   $0x80106ba9
80103c7e:	e8 c5 c6 ff ff       	call   80100348 <panic>

80103c83 <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103c83:	55                   	push   %ebp
80103c84:	89 e5                	mov    %esp,%ebp
80103c86:	57                   	push   %edi
80103c87:	53                   	push   %ebx
80103c88:	8b 55 08             	mov    0x8(%ebp),%edx
80103c8b:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103c8e:	f6 c2 03             	test   $0x3,%dl
80103c91:	75 05                	jne    80103c98 <memset+0x15>
80103c93:	f6 c1 03             	test   $0x3,%cl
80103c96:	74 0e                	je     80103ca6 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103c98:	89 d7                	mov    %edx,%edi
80103c9a:	8b 45 0c             	mov    0xc(%ebp),%eax
80103c9d:	fc                   	cld    
80103c9e:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103ca0:	89 d0                	mov    %edx,%eax
80103ca2:	5b                   	pop    %ebx
80103ca3:	5f                   	pop    %edi
80103ca4:	5d                   	pop    %ebp
80103ca5:	c3                   	ret    
    c &= 0xFF;
80103ca6:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103caa:	c1 e9 02             	shr    $0x2,%ecx
80103cad:	89 f8                	mov    %edi,%eax
80103caf:	c1 e0 18             	shl    $0x18,%eax
80103cb2:	89 fb                	mov    %edi,%ebx
80103cb4:	c1 e3 10             	shl    $0x10,%ebx
80103cb7:	09 d8                	or     %ebx,%eax
80103cb9:	89 fb                	mov    %edi,%ebx
80103cbb:	c1 e3 08             	shl    $0x8,%ebx
80103cbe:	09 d8                	or     %ebx,%eax
80103cc0:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103cc2:	89 d7                	mov    %edx,%edi
80103cc4:	fc                   	cld    
80103cc5:	f3 ab                	rep stos %eax,%es:(%edi)
80103cc7:	eb d7                	jmp    80103ca0 <memset+0x1d>

80103cc9 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103cc9:	55                   	push   %ebp
80103cca:	89 e5                	mov    %esp,%ebp
80103ccc:	56                   	push   %esi
80103ccd:	53                   	push   %ebx
80103cce:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103cd1:	8b 55 0c             	mov    0xc(%ebp),%edx
80103cd4:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103cd7:	8d 70 ff             	lea    -0x1(%eax),%esi
80103cda:	85 c0                	test   %eax,%eax
80103cdc:	74 1c                	je     80103cfa <memcmp+0x31>
    if(*s1 != *s2)
80103cde:	0f b6 01             	movzbl (%ecx),%eax
80103ce1:	0f b6 1a             	movzbl (%edx),%ebx
80103ce4:	38 d8                	cmp    %bl,%al
80103ce6:	75 0a                	jne    80103cf2 <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103ce8:	83 c1 01             	add    $0x1,%ecx
80103ceb:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103cee:	89 f0                	mov    %esi,%eax
80103cf0:	eb e5                	jmp    80103cd7 <memcmp+0xe>
      return *s1 - *s2;
80103cf2:	0f b6 c0             	movzbl %al,%eax
80103cf5:	0f b6 db             	movzbl %bl,%ebx
80103cf8:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103cfa:	5b                   	pop    %ebx
80103cfb:	5e                   	pop    %esi
80103cfc:	5d                   	pop    %ebp
80103cfd:	c3                   	ret    

80103cfe <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103cfe:	55                   	push   %ebp
80103cff:	89 e5                	mov    %esp,%ebp
80103d01:	56                   	push   %esi
80103d02:	53                   	push   %ebx
80103d03:	8b 45 08             	mov    0x8(%ebp),%eax
80103d06:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103d09:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103d0c:	39 c1                	cmp    %eax,%ecx
80103d0e:	73 3a                	jae    80103d4a <memmove+0x4c>
80103d10:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103d13:	39 c3                	cmp    %eax,%ebx
80103d15:	76 37                	jbe    80103d4e <memmove+0x50>
    s += n;
    d += n;
80103d17:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103d1a:	eb 0d                	jmp    80103d29 <memmove+0x2b>
      *--d = *--s;
80103d1c:	83 eb 01             	sub    $0x1,%ebx
80103d1f:	83 e9 01             	sub    $0x1,%ecx
80103d22:	0f b6 13             	movzbl (%ebx),%edx
80103d25:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103d27:	89 f2                	mov    %esi,%edx
80103d29:	8d 72 ff             	lea    -0x1(%edx),%esi
80103d2c:	85 d2                	test   %edx,%edx
80103d2e:	75 ec                	jne    80103d1c <memmove+0x1e>
80103d30:	eb 14                	jmp    80103d46 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103d32:	0f b6 11             	movzbl (%ecx),%edx
80103d35:	88 13                	mov    %dl,(%ebx)
80103d37:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103d3a:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103d3d:	89 f2                	mov    %esi,%edx
80103d3f:	8d 72 ff             	lea    -0x1(%edx),%esi
80103d42:	85 d2                	test   %edx,%edx
80103d44:	75 ec                	jne    80103d32 <memmove+0x34>

  return dst;
}
80103d46:	5b                   	pop    %ebx
80103d47:	5e                   	pop    %esi
80103d48:	5d                   	pop    %ebp
80103d49:	c3                   	ret    
80103d4a:	89 c3                	mov    %eax,%ebx
80103d4c:	eb f1                	jmp    80103d3f <memmove+0x41>
80103d4e:	89 c3                	mov    %eax,%ebx
80103d50:	eb ed                	jmp    80103d3f <memmove+0x41>

80103d52 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103d52:	55                   	push   %ebp
80103d53:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103d55:	ff 75 10             	pushl  0x10(%ebp)
80103d58:	ff 75 0c             	pushl  0xc(%ebp)
80103d5b:	ff 75 08             	pushl  0x8(%ebp)
80103d5e:	e8 9b ff ff ff       	call   80103cfe <memmove>
}
80103d63:	c9                   	leave  
80103d64:	c3                   	ret    

80103d65 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103d65:	55                   	push   %ebp
80103d66:	89 e5                	mov    %esp,%ebp
80103d68:	53                   	push   %ebx
80103d69:	8b 55 08             	mov    0x8(%ebp),%edx
80103d6c:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103d6f:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103d72:	eb 09                	jmp    80103d7d <strncmp+0x18>
    n--, p++, q++;
80103d74:	83 e8 01             	sub    $0x1,%eax
80103d77:	83 c2 01             	add    $0x1,%edx
80103d7a:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103d7d:	85 c0                	test   %eax,%eax
80103d7f:	74 0b                	je     80103d8c <strncmp+0x27>
80103d81:	0f b6 1a             	movzbl (%edx),%ebx
80103d84:	84 db                	test   %bl,%bl
80103d86:	74 04                	je     80103d8c <strncmp+0x27>
80103d88:	3a 19                	cmp    (%ecx),%bl
80103d8a:	74 e8                	je     80103d74 <strncmp+0xf>
  if(n == 0)
80103d8c:	85 c0                	test   %eax,%eax
80103d8e:	74 0b                	je     80103d9b <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103d90:	0f b6 02             	movzbl (%edx),%eax
80103d93:	0f b6 11             	movzbl (%ecx),%edx
80103d96:	29 d0                	sub    %edx,%eax
}
80103d98:	5b                   	pop    %ebx
80103d99:	5d                   	pop    %ebp
80103d9a:	c3                   	ret    
    return 0;
80103d9b:	b8 00 00 00 00       	mov    $0x0,%eax
80103da0:	eb f6                	jmp    80103d98 <strncmp+0x33>

80103da2 <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103da2:	55                   	push   %ebp
80103da3:	89 e5                	mov    %esp,%ebp
80103da5:	57                   	push   %edi
80103da6:	56                   	push   %esi
80103da7:	53                   	push   %ebx
80103da8:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103dab:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103dae:	8b 45 08             	mov    0x8(%ebp),%eax
80103db1:	eb 04                	jmp    80103db7 <strncpy+0x15>
80103db3:	89 fb                	mov    %edi,%ebx
80103db5:	89 f0                	mov    %esi,%eax
80103db7:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103dba:	85 c9                	test   %ecx,%ecx
80103dbc:	7e 1d                	jle    80103ddb <strncpy+0x39>
80103dbe:	8d 7b 01             	lea    0x1(%ebx),%edi
80103dc1:	8d 70 01             	lea    0x1(%eax),%esi
80103dc4:	0f b6 1b             	movzbl (%ebx),%ebx
80103dc7:	88 18                	mov    %bl,(%eax)
80103dc9:	89 d1                	mov    %edx,%ecx
80103dcb:	84 db                	test   %bl,%bl
80103dcd:	75 e4                	jne    80103db3 <strncpy+0x11>
80103dcf:	89 f0                	mov    %esi,%eax
80103dd1:	eb 08                	jmp    80103ddb <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103dd3:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103dd6:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103dd8:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103ddb:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103dde:	85 d2                	test   %edx,%edx
80103de0:	7f f1                	jg     80103dd3 <strncpy+0x31>
  return os;
}
80103de2:	8b 45 08             	mov    0x8(%ebp),%eax
80103de5:	5b                   	pop    %ebx
80103de6:	5e                   	pop    %esi
80103de7:	5f                   	pop    %edi
80103de8:	5d                   	pop    %ebp
80103de9:	c3                   	ret    

80103dea <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103dea:	55                   	push   %ebp
80103deb:	89 e5                	mov    %esp,%ebp
80103ded:	57                   	push   %edi
80103dee:	56                   	push   %esi
80103def:	53                   	push   %ebx
80103df0:	8b 45 08             	mov    0x8(%ebp),%eax
80103df3:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103df6:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103df9:	85 d2                	test   %edx,%edx
80103dfb:	7e 23                	jle    80103e20 <safestrcpy+0x36>
80103dfd:	89 c1                	mov    %eax,%ecx
80103dff:	eb 04                	jmp    80103e05 <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103e01:	89 fb                	mov    %edi,%ebx
80103e03:	89 f1                	mov    %esi,%ecx
80103e05:	83 ea 01             	sub    $0x1,%edx
80103e08:	85 d2                	test   %edx,%edx
80103e0a:	7e 11                	jle    80103e1d <safestrcpy+0x33>
80103e0c:	8d 7b 01             	lea    0x1(%ebx),%edi
80103e0f:	8d 71 01             	lea    0x1(%ecx),%esi
80103e12:	0f b6 1b             	movzbl (%ebx),%ebx
80103e15:	88 19                	mov    %bl,(%ecx)
80103e17:	84 db                	test   %bl,%bl
80103e19:	75 e6                	jne    80103e01 <safestrcpy+0x17>
80103e1b:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103e1d:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103e20:	5b                   	pop    %ebx
80103e21:	5e                   	pop    %esi
80103e22:	5f                   	pop    %edi
80103e23:	5d                   	pop    %ebp
80103e24:	c3                   	ret    

80103e25 <strlen>:

int
strlen(const char *s)
{
80103e25:	55                   	push   %ebp
80103e26:	89 e5                	mov    %esp,%ebp
80103e28:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103e2b:	b8 00 00 00 00       	mov    $0x0,%eax
80103e30:	eb 03                	jmp    80103e35 <strlen+0x10>
80103e32:	83 c0 01             	add    $0x1,%eax
80103e35:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103e39:	75 f7                	jne    80103e32 <strlen+0xd>
    ;
  return n;
}
80103e3b:	5d                   	pop    %ebp
80103e3c:	c3                   	ret    

80103e3d <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103e3d:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103e41:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103e45:	55                   	push   %ebp
  pushl %ebx
80103e46:	53                   	push   %ebx
  pushl %esi
80103e47:	56                   	push   %esi
  pushl %edi
80103e48:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103e49:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103e4b:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103e4d:	5f                   	pop    %edi
  popl %esi
80103e4e:	5e                   	pop    %esi
  popl %ebx
80103e4f:	5b                   	pop    %ebx
  popl %ebp
80103e50:	5d                   	pop    %ebp
  ret
80103e51:	c3                   	ret    

80103e52 <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103e52:	55                   	push   %ebp
80103e53:	89 e5                	mov    %esp,%ebp
80103e55:	53                   	push   %ebx
80103e56:	83 ec 04             	sub    $0x4,%esp
80103e59:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103e5c:	e8 d7 f3 ff ff       	call   80103238 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103e61:	8b 00                	mov    (%eax),%eax
80103e63:	39 d8                	cmp    %ebx,%eax
80103e65:	76 19                	jbe    80103e80 <fetchint+0x2e>
80103e67:	8d 53 04             	lea    0x4(%ebx),%edx
80103e6a:	39 d0                	cmp    %edx,%eax
80103e6c:	72 19                	jb     80103e87 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103e6e:	8b 13                	mov    (%ebx),%edx
80103e70:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e73:	89 10                	mov    %edx,(%eax)
  return 0;
80103e75:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103e7a:	83 c4 04             	add    $0x4,%esp
80103e7d:	5b                   	pop    %ebx
80103e7e:	5d                   	pop    %ebp
80103e7f:	c3                   	ret    
    return -1;
80103e80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e85:	eb f3                	jmp    80103e7a <fetchint+0x28>
80103e87:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103e8c:	eb ec                	jmp    80103e7a <fetchint+0x28>

80103e8e <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103e8e:	55                   	push   %ebp
80103e8f:	89 e5                	mov    %esp,%ebp
80103e91:	53                   	push   %ebx
80103e92:	83 ec 04             	sub    $0x4,%esp
80103e95:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103e98:	e8 9b f3 ff ff       	call   80103238 <myproc>

  if(addr >= curproc->sz)
80103e9d:	39 18                	cmp    %ebx,(%eax)
80103e9f:	76 26                	jbe    80103ec7 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103ea1:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ea4:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80103ea6:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80103ea8:	89 d8                	mov    %ebx,%eax
80103eaa:	39 d0                	cmp    %edx,%eax
80103eac:	73 0e                	jae    80103ebc <fetchstr+0x2e>
    if(*s == 0)
80103eae:	80 38 00             	cmpb   $0x0,(%eax)
80103eb1:	74 05                	je     80103eb8 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
80103eb3:	83 c0 01             	add    $0x1,%eax
80103eb6:	eb f2                	jmp    80103eaa <fetchstr+0x1c>
      return s - *pp;
80103eb8:	29 d8                	sub    %ebx,%eax
80103eba:	eb 05                	jmp    80103ec1 <fetchstr+0x33>
  }
  return -1;
80103ebc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80103ec1:	83 c4 04             	add    $0x4,%esp
80103ec4:	5b                   	pop    %ebx
80103ec5:	5d                   	pop    %ebp
80103ec6:	c3                   	ret    
    return -1;
80103ec7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103ecc:	eb f3                	jmp    80103ec1 <fetchstr+0x33>

80103ece <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80103ece:	55                   	push   %ebp
80103ecf:	89 e5                	mov    %esp,%ebp
80103ed1:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
80103ed4:	e8 5f f3 ff ff       	call   80103238 <myproc>
80103ed9:	8b 50 18             	mov    0x18(%eax),%edx
80103edc:	8b 45 08             	mov    0x8(%ebp),%eax
80103edf:	c1 e0 02             	shl    $0x2,%eax
80103ee2:	03 42 44             	add    0x44(%edx),%eax
80103ee5:	83 ec 08             	sub    $0x8,%esp
80103ee8:	ff 75 0c             	pushl  0xc(%ebp)
80103eeb:	83 c0 04             	add    $0x4,%eax
80103eee:	50                   	push   %eax
80103eef:	e8 5e ff ff ff       	call   80103e52 <fetchint>
}
80103ef4:	c9                   	leave  
80103ef5:	c3                   	ret    

80103ef6 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80103ef6:	55                   	push   %ebp
80103ef7:	89 e5                	mov    %esp,%ebp
80103ef9:	56                   	push   %esi
80103efa:	53                   	push   %ebx
80103efb:	83 ec 10             	sub    $0x10,%esp
80103efe:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80103f01:	e8 32 f3 ff ff       	call   80103238 <myproc>
80103f06:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80103f08:	83 ec 08             	sub    $0x8,%esp
80103f0b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103f0e:	50                   	push   %eax
80103f0f:	ff 75 08             	pushl  0x8(%ebp)
80103f12:	e8 b7 ff ff ff       	call   80103ece <argint>
80103f17:	83 c4 10             	add    $0x10,%esp
80103f1a:	85 c0                	test   %eax,%eax
80103f1c:	78 24                	js     80103f42 <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80103f1e:	85 db                	test   %ebx,%ebx
80103f20:	78 27                	js     80103f49 <argptr+0x53>
80103f22:	8b 16                	mov    (%esi),%edx
80103f24:	8b 45 f4             	mov    -0xc(%ebp),%eax
80103f27:	39 c2                	cmp    %eax,%edx
80103f29:	76 25                	jbe    80103f50 <argptr+0x5a>
80103f2b:	01 c3                	add    %eax,%ebx
80103f2d:	39 da                	cmp    %ebx,%edx
80103f2f:	72 26                	jb     80103f57 <argptr+0x61>
    return -1;
  *pp = (char*)i;
80103f31:	8b 55 0c             	mov    0xc(%ebp),%edx
80103f34:	89 02                	mov    %eax,(%edx)
  return 0;
80103f36:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103f3b:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103f3e:	5b                   	pop    %ebx
80103f3f:	5e                   	pop    %esi
80103f40:	5d                   	pop    %ebp
80103f41:	c3                   	ret    
    return -1;
80103f42:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f47:	eb f2                	jmp    80103f3b <argptr+0x45>
    return -1;
80103f49:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f4e:	eb eb                	jmp    80103f3b <argptr+0x45>
80103f50:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f55:	eb e4                	jmp    80103f3b <argptr+0x45>
80103f57:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f5c:	eb dd                	jmp    80103f3b <argptr+0x45>

80103f5e <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
80103f5e:	55                   	push   %ebp
80103f5f:	89 e5                	mov    %esp,%ebp
80103f61:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
80103f64:	8d 45 f4             	lea    -0xc(%ebp),%eax
80103f67:	50                   	push   %eax
80103f68:	ff 75 08             	pushl  0x8(%ebp)
80103f6b:	e8 5e ff ff ff       	call   80103ece <argint>
80103f70:	83 c4 10             	add    $0x10,%esp
80103f73:	85 c0                	test   %eax,%eax
80103f75:	78 13                	js     80103f8a <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
80103f77:	83 ec 08             	sub    $0x8,%esp
80103f7a:	ff 75 0c             	pushl  0xc(%ebp)
80103f7d:	ff 75 f4             	pushl  -0xc(%ebp)
80103f80:	e8 09 ff ff ff       	call   80103e8e <fetchstr>
80103f85:	83 c4 10             	add    $0x10,%esp
}
80103f88:	c9                   	leave  
80103f89:	c3                   	ret    
    return -1;
80103f8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103f8f:	eb f7                	jmp    80103f88 <argstr+0x2a>

80103f91 <syscall>:
[SYS_dump_physmem] sys_dump_physmem,
};

void
syscall(void)
{
80103f91:	55                   	push   %ebp
80103f92:	89 e5                	mov    %esp,%ebp
80103f94:	53                   	push   %ebx
80103f95:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80103f98:	e8 9b f2 ff ff       	call   80103238 <myproc>
80103f9d:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80103f9f:	8b 40 18             	mov    0x18(%eax),%eax
80103fa2:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
80103fa5:	8d 50 ff             	lea    -0x1(%eax),%edx
80103fa8:	83 fa 15             	cmp    $0x15,%edx
80103fab:	77 18                	ja     80103fc5 <syscall+0x34>
80103fad:	8b 14 85 e0 6b 10 80 	mov    -0x7fef9420(,%eax,4),%edx
80103fb4:	85 d2                	test   %edx,%edx
80103fb6:	74 0d                	je     80103fc5 <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80103fb8:	ff d2                	call   *%edx
80103fba:	8b 53 18             	mov    0x18(%ebx),%edx
80103fbd:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80103fc0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103fc3:	c9                   	leave  
80103fc4:	c3                   	ret    
            curproc->pid, curproc->name, num);
80103fc5:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80103fc8:	50                   	push   %eax
80103fc9:	52                   	push   %edx
80103fca:	ff 73 10             	pushl  0x10(%ebx)
80103fcd:	68 b1 6b 10 80       	push   $0x80106bb1
80103fd2:	e8 34 c6 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80103fd7:	8b 43 18             	mov    0x18(%ebx),%eax
80103fda:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80103fe1:	83 c4 10             	add    $0x10,%esp
}
80103fe4:	eb da                	jmp    80103fc0 <syscall+0x2f>

80103fe6 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80103fe6:	55                   	push   %ebp
80103fe7:	89 e5                	mov    %esp,%ebp
80103fe9:	56                   	push   %esi
80103fea:	53                   	push   %ebx
80103feb:	83 ec 18             	sub    $0x18,%esp
80103fee:	89 d6                	mov    %edx,%esi
80103ff0:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
80103ff2:	8d 55 f4             	lea    -0xc(%ebp),%edx
80103ff5:	52                   	push   %edx
80103ff6:	50                   	push   %eax
80103ff7:	e8 d2 fe ff ff       	call   80103ece <argint>
80103ffc:	83 c4 10             	add    $0x10,%esp
80103fff:	85 c0                	test   %eax,%eax
80104001:	78 2e                	js     80104031 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
80104003:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104007:	77 2f                	ja     80104038 <argfd+0x52>
80104009:	e8 2a f2 ff ff       	call   80103238 <myproc>
8010400e:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104011:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
80104015:	85 c0                	test   %eax,%eax
80104017:	74 26                	je     8010403f <argfd+0x59>
    return -1;
  if(pfd)
80104019:	85 f6                	test   %esi,%esi
8010401b:	74 02                	je     8010401f <argfd+0x39>
    *pfd = fd;
8010401d:	89 16                	mov    %edx,(%esi)
  if(pf)
8010401f:	85 db                	test   %ebx,%ebx
80104021:	74 23                	je     80104046 <argfd+0x60>
    *pf = f;
80104023:	89 03                	mov    %eax,(%ebx)
  return 0;
80104025:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010402a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010402d:	5b                   	pop    %ebx
8010402e:	5e                   	pop    %esi
8010402f:	5d                   	pop    %ebp
80104030:	c3                   	ret    
    return -1;
80104031:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104036:	eb f2                	jmp    8010402a <argfd+0x44>
    return -1;
80104038:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010403d:	eb eb                	jmp    8010402a <argfd+0x44>
8010403f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104044:	eb e4                	jmp    8010402a <argfd+0x44>
  return 0;
80104046:	b8 00 00 00 00       	mov    $0x0,%eax
8010404b:	eb dd                	jmp    8010402a <argfd+0x44>

8010404d <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
8010404d:	55                   	push   %ebp
8010404e:	89 e5                	mov    %esp,%ebp
80104050:	53                   	push   %ebx
80104051:	83 ec 04             	sub    $0x4,%esp
80104054:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
80104056:	e8 dd f1 ff ff       	call   80103238 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
8010405b:	ba 00 00 00 00       	mov    $0x0,%edx
80104060:	83 fa 0f             	cmp    $0xf,%edx
80104063:	7f 18                	jg     8010407d <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
80104065:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
8010406a:	74 05                	je     80104071 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
8010406c:	83 c2 01             	add    $0x1,%edx
8010406f:	eb ef                	jmp    80104060 <fdalloc+0x13>
      curproc->ofile[fd] = f;
80104071:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
80104075:	89 d0                	mov    %edx,%eax
80104077:	83 c4 04             	add    $0x4,%esp
8010407a:	5b                   	pop    %ebx
8010407b:	5d                   	pop    %ebp
8010407c:	c3                   	ret    
  return -1;
8010407d:	ba ff ff ff ff       	mov    $0xffffffff,%edx
80104082:	eb f1                	jmp    80104075 <fdalloc+0x28>

80104084 <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
80104084:	55                   	push   %ebp
80104085:	89 e5                	mov    %esp,%ebp
80104087:	56                   	push   %esi
80104088:	53                   	push   %ebx
80104089:	83 ec 10             	sub    $0x10,%esp
8010408c:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010408e:	b8 20 00 00 00       	mov    $0x20,%eax
80104093:	89 c6                	mov    %eax,%esi
80104095:	39 43 58             	cmp    %eax,0x58(%ebx)
80104098:	76 2e                	jbe    801040c8 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010409a:	6a 10                	push   $0x10
8010409c:	50                   	push   %eax
8010409d:	8d 45 e8             	lea    -0x18(%ebp),%eax
801040a0:	50                   	push   %eax
801040a1:	53                   	push   %ebx
801040a2:	e8 cc d6 ff ff       	call   80101773 <readi>
801040a7:	83 c4 10             	add    $0x10,%esp
801040aa:	83 f8 10             	cmp    $0x10,%eax
801040ad:	75 0c                	jne    801040bb <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
801040af:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
801040b4:	75 1e                	jne    801040d4 <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801040b6:	8d 46 10             	lea    0x10(%esi),%eax
801040b9:	eb d8                	jmp    80104093 <isdirempty+0xf>
      panic("isdirempty: readi");
801040bb:	83 ec 0c             	sub    $0xc,%esp
801040be:	68 3c 6c 10 80       	push   $0x80106c3c
801040c3:	e8 80 c2 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
801040c8:	b8 01 00 00 00       	mov    $0x1,%eax
}
801040cd:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040d0:	5b                   	pop    %ebx
801040d1:	5e                   	pop    %esi
801040d2:	5d                   	pop    %ebp
801040d3:	c3                   	ret    
      return 0;
801040d4:	b8 00 00 00 00       	mov    $0x0,%eax
801040d9:	eb f2                	jmp    801040cd <isdirempty+0x49>

801040db <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
801040db:	55                   	push   %ebp
801040dc:	89 e5                	mov    %esp,%ebp
801040de:	57                   	push   %edi
801040df:	56                   	push   %esi
801040e0:	53                   	push   %ebx
801040e1:	83 ec 44             	sub    $0x44,%esp
801040e4:	89 55 c4             	mov    %edx,-0x3c(%ebp)
801040e7:	89 4d c0             	mov    %ecx,-0x40(%ebp)
801040ea:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
801040ed:	8d 55 d6             	lea    -0x2a(%ebp),%edx
801040f0:	52                   	push   %edx
801040f1:	50                   	push   %eax
801040f2:	e8 02 db ff ff       	call   80101bf9 <nameiparent>
801040f7:	89 c6                	mov    %eax,%esi
801040f9:	83 c4 10             	add    $0x10,%esp
801040fc:	85 c0                	test   %eax,%eax
801040fe:	0f 84 3a 01 00 00    	je     8010423e <create+0x163>
    return 0;
  ilock(dp);
80104104:	83 ec 0c             	sub    $0xc,%esp
80104107:	50                   	push   %eax
80104108:	e8 74 d4 ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
8010410d:	83 c4 0c             	add    $0xc,%esp
80104110:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104113:	50                   	push   %eax
80104114:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104117:	50                   	push   %eax
80104118:	56                   	push   %esi
80104119:	e8 92 d8 ff ff       	call   801019b0 <dirlookup>
8010411e:	89 c3                	mov    %eax,%ebx
80104120:	83 c4 10             	add    $0x10,%esp
80104123:	85 c0                	test   %eax,%eax
80104125:	74 3f                	je     80104166 <create+0x8b>
    iunlockput(dp);
80104127:	83 ec 0c             	sub    $0xc,%esp
8010412a:	56                   	push   %esi
8010412b:	e8 f8 d5 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
80104130:	89 1c 24             	mov    %ebx,(%esp)
80104133:	e8 49 d4 ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104138:	83 c4 10             	add    $0x10,%esp
8010413b:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
80104140:	75 11                	jne    80104153 <create+0x78>
80104142:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
80104147:	75 0a                	jne    80104153 <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
80104149:	89 d8                	mov    %ebx,%eax
8010414b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010414e:	5b                   	pop    %ebx
8010414f:	5e                   	pop    %esi
80104150:	5f                   	pop    %edi
80104151:	5d                   	pop    %ebp
80104152:	c3                   	ret    
    iunlockput(ip);
80104153:	83 ec 0c             	sub    $0xc,%esp
80104156:	53                   	push   %ebx
80104157:	e8 cc d5 ff ff       	call   80101728 <iunlockput>
    return 0;
8010415c:	83 c4 10             	add    $0x10,%esp
8010415f:	bb 00 00 00 00       	mov    $0x0,%ebx
80104164:	eb e3                	jmp    80104149 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
80104166:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
8010416a:	83 ec 08             	sub    $0x8,%esp
8010416d:	50                   	push   %eax
8010416e:	ff 36                	pushl  (%esi)
80104170:	e8 09 d2 ff ff       	call   8010137e <ialloc>
80104175:	89 c3                	mov    %eax,%ebx
80104177:	83 c4 10             	add    $0x10,%esp
8010417a:	85 c0                	test   %eax,%eax
8010417c:	74 55                	je     801041d3 <create+0xf8>
  ilock(ip);
8010417e:	83 ec 0c             	sub    $0xc,%esp
80104181:	50                   	push   %eax
80104182:	e8 fa d3 ff ff       	call   80101581 <ilock>
  ip->major = major;
80104187:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
8010418b:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
8010418f:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
80104193:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104199:	89 1c 24             	mov    %ebx,(%esp)
8010419c:	e8 7f d2 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801041a1:	83 c4 10             	add    $0x10,%esp
801041a4:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
801041a9:	74 35                	je     801041e0 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
801041ab:	83 ec 04             	sub    $0x4,%esp
801041ae:	ff 73 04             	pushl  0x4(%ebx)
801041b1:	8d 45 d6             	lea    -0x2a(%ebp),%eax
801041b4:	50                   	push   %eax
801041b5:	56                   	push   %esi
801041b6:	e8 75 d9 ff ff       	call   80101b30 <dirlink>
801041bb:	83 c4 10             	add    $0x10,%esp
801041be:	85 c0                	test   %eax,%eax
801041c0:	78 6f                	js     80104231 <create+0x156>
  iunlockput(dp);
801041c2:	83 ec 0c             	sub    $0xc,%esp
801041c5:	56                   	push   %esi
801041c6:	e8 5d d5 ff ff       	call   80101728 <iunlockput>
  return ip;
801041cb:	83 c4 10             	add    $0x10,%esp
801041ce:	e9 76 ff ff ff       	jmp    80104149 <create+0x6e>
    panic("create: ialloc");
801041d3:	83 ec 0c             	sub    $0xc,%esp
801041d6:	68 4e 6c 10 80       	push   $0x80106c4e
801041db:	e8 68 c1 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
801041e0:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801041e4:	83 c0 01             	add    $0x1,%eax
801041e7:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
801041eb:	83 ec 0c             	sub    $0xc,%esp
801041ee:	56                   	push   %esi
801041ef:	e8 2c d2 ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
801041f4:	83 c4 0c             	add    $0xc,%esp
801041f7:	ff 73 04             	pushl  0x4(%ebx)
801041fa:	68 5e 6c 10 80       	push   $0x80106c5e
801041ff:	53                   	push   %ebx
80104200:	e8 2b d9 ff ff       	call   80101b30 <dirlink>
80104205:	83 c4 10             	add    $0x10,%esp
80104208:	85 c0                	test   %eax,%eax
8010420a:	78 18                	js     80104224 <create+0x149>
8010420c:	83 ec 04             	sub    $0x4,%esp
8010420f:	ff 76 04             	pushl  0x4(%esi)
80104212:	68 5d 6c 10 80       	push   $0x80106c5d
80104217:	53                   	push   %ebx
80104218:	e8 13 d9 ff ff       	call   80101b30 <dirlink>
8010421d:	83 c4 10             	add    $0x10,%esp
80104220:	85 c0                	test   %eax,%eax
80104222:	79 87                	jns    801041ab <create+0xd0>
      panic("create dots");
80104224:	83 ec 0c             	sub    $0xc,%esp
80104227:	68 60 6c 10 80       	push   $0x80106c60
8010422c:	e8 17 c1 ff ff       	call   80100348 <panic>
    panic("create: dirlink");
80104231:	83 ec 0c             	sub    $0xc,%esp
80104234:	68 6c 6c 10 80       	push   $0x80106c6c
80104239:	e8 0a c1 ff ff       	call   80100348 <panic>
    return 0;
8010423e:	89 c3                	mov    %eax,%ebx
80104240:	e9 04 ff ff ff       	jmp    80104149 <create+0x6e>

80104245 <sys_dup>:
{
80104245:	55                   	push   %ebp
80104246:	89 e5                	mov    %esp,%ebp
80104248:	53                   	push   %ebx
80104249:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
8010424c:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010424f:	ba 00 00 00 00       	mov    $0x0,%edx
80104254:	b8 00 00 00 00       	mov    $0x0,%eax
80104259:	e8 88 fd ff ff       	call   80103fe6 <argfd>
8010425e:	85 c0                	test   %eax,%eax
80104260:	78 23                	js     80104285 <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
80104262:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104265:	e8 e3 fd ff ff       	call   8010404d <fdalloc>
8010426a:	89 c3                	mov    %eax,%ebx
8010426c:	85 c0                	test   %eax,%eax
8010426e:	78 1c                	js     8010428c <sys_dup+0x47>
  filedup(f);
80104270:	83 ec 0c             	sub    $0xc,%esp
80104273:	ff 75 f4             	pushl  -0xc(%ebp)
80104276:	e8 13 ca ff ff       	call   80100c8e <filedup>
  return fd;
8010427b:	83 c4 10             	add    $0x10,%esp
}
8010427e:	89 d8                	mov    %ebx,%eax
80104280:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104283:	c9                   	leave  
80104284:	c3                   	ret    
    return -1;
80104285:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010428a:	eb f2                	jmp    8010427e <sys_dup+0x39>
    return -1;
8010428c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104291:	eb eb                	jmp    8010427e <sys_dup+0x39>

80104293 <sys_read>:
{
80104293:	55                   	push   %ebp
80104294:	89 e5                	mov    %esp,%ebp
80104296:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104299:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010429c:	ba 00 00 00 00       	mov    $0x0,%edx
801042a1:	b8 00 00 00 00       	mov    $0x0,%eax
801042a6:	e8 3b fd ff ff       	call   80103fe6 <argfd>
801042ab:	85 c0                	test   %eax,%eax
801042ad:	78 43                	js     801042f2 <sys_read+0x5f>
801042af:	83 ec 08             	sub    $0x8,%esp
801042b2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801042b5:	50                   	push   %eax
801042b6:	6a 02                	push   $0x2
801042b8:	e8 11 fc ff ff       	call   80103ece <argint>
801042bd:	83 c4 10             	add    $0x10,%esp
801042c0:	85 c0                	test   %eax,%eax
801042c2:	78 35                	js     801042f9 <sys_read+0x66>
801042c4:	83 ec 04             	sub    $0x4,%esp
801042c7:	ff 75 f0             	pushl  -0x10(%ebp)
801042ca:	8d 45 ec             	lea    -0x14(%ebp),%eax
801042cd:	50                   	push   %eax
801042ce:	6a 01                	push   $0x1
801042d0:	e8 21 fc ff ff       	call   80103ef6 <argptr>
801042d5:	83 c4 10             	add    $0x10,%esp
801042d8:	85 c0                	test   %eax,%eax
801042da:	78 24                	js     80104300 <sys_read+0x6d>
  return fileread(f, p, n);
801042dc:	83 ec 04             	sub    $0x4,%esp
801042df:	ff 75 f0             	pushl  -0x10(%ebp)
801042e2:	ff 75 ec             	pushl  -0x14(%ebp)
801042e5:	ff 75 f4             	pushl  -0xc(%ebp)
801042e8:	e8 ea ca ff ff       	call   80100dd7 <fileread>
801042ed:	83 c4 10             	add    $0x10,%esp
}
801042f0:	c9                   	leave  
801042f1:	c3                   	ret    
    return -1;
801042f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042f7:	eb f7                	jmp    801042f0 <sys_read+0x5d>
801042f9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801042fe:	eb f0                	jmp    801042f0 <sys_read+0x5d>
80104300:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104305:	eb e9                	jmp    801042f0 <sys_read+0x5d>

80104307 <sys_write>:
{
80104307:	55                   	push   %ebp
80104308:	89 e5                	mov    %esp,%ebp
8010430a:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
8010430d:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104310:	ba 00 00 00 00       	mov    $0x0,%edx
80104315:	b8 00 00 00 00       	mov    $0x0,%eax
8010431a:	e8 c7 fc ff ff       	call   80103fe6 <argfd>
8010431f:	85 c0                	test   %eax,%eax
80104321:	78 43                	js     80104366 <sys_write+0x5f>
80104323:	83 ec 08             	sub    $0x8,%esp
80104326:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104329:	50                   	push   %eax
8010432a:	6a 02                	push   $0x2
8010432c:	e8 9d fb ff ff       	call   80103ece <argint>
80104331:	83 c4 10             	add    $0x10,%esp
80104334:	85 c0                	test   %eax,%eax
80104336:	78 35                	js     8010436d <sys_write+0x66>
80104338:	83 ec 04             	sub    $0x4,%esp
8010433b:	ff 75 f0             	pushl  -0x10(%ebp)
8010433e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104341:	50                   	push   %eax
80104342:	6a 01                	push   $0x1
80104344:	e8 ad fb ff ff       	call   80103ef6 <argptr>
80104349:	83 c4 10             	add    $0x10,%esp
8010434c:	85 c0                	test   %eax,%eax
8010434e:	78 24                	js     80104374 <sys_write+0x6d>
  return filewrite(f, p, n);
80104350:	83 ec 04             	sub    $0x4,%esp
80104353:	ff 75 f0             	pushl  -0x10(%ebp)
80104356:	ff 75 ec             	pushl  -0x14(%ebp)
80104359:	ff 75 f4             	pushl  -0xc(%ebp)
8010435c:	e8 fb ca ff ff       	call   80100e5c <filewrite>
80104361:	83 c4 10             	add    $0x10,%esp
}
80104364:	c9                   	leave  
80104365:	c3                   	ret    
    return -1;
80104366:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010436b:	eb f7                	jmp    80104364 <sys_write+0x5d>
8010436d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104372:	eb f0                	jmp    80104364 <sys_write+0x5d>
80104374:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104379:	eb e9                	jmp    80104364 <sys_write+0x5d>

8010437b <sys_close>:
{
8010437b:	55                   	push   %ebp
8010437c:	89 e5                	mov    %esp,%ebp
8010437e:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104381:	8d 4d f0             	lea    -0x10(%ebp),%ecx
80104384:	8d 55 f4             	lea    -0xc(%ebp),%edx
80104387:	b8 00 00 00 00       	mov    $0x0,%eax
8010438c:	e8 55 fc ff ff       	call   80103fe6 <argfd>
80104391:	85 c0                	test   %eax,%eax
80104393:	78 25                	js     801043ba <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
80104395:	e8 9e ee ff ff       	call   80103238 <myproc>
8010439a:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010439d:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801043a4:	00 
  fileclose(f);
801043a5:	83 ec 0c             	sub    $0xc,%esp
801043a8:	ff 75 f0             	pushl  -0x10(%ebp)
801043ab:	e8 23 c9 ff ff       	call   80100cd3 <fileclose>
  return 0;
801043b0:	83 c4 10             	add    $0x10,%esp
801043b3:	b8 00 00 00 00       	mov    $0x0,%eax
}
801043b8:	c9                   	leave  
801043b9:	c3                   	ret    
    return -1;
801043ba:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801043bf:	eb f7                	jmp    801043b8 <sys_close+0x3d>

801043c1 <sys_fstat>:
{
801043c1:	55                   	push   %ebp
801043c2:	89 e5                	mov    %esp,%ebp
801043c4:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
801043c7:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043ca:	ba 00 00 00 00       	mov    $0x0,%edx
801043cf:	b8 00 00 00 00       	mov    $0x0,%eax
801043d4:	e8 0d fc ff ff       	call   80103fe6 <argfd>
801043d9:	85 c0                	test   %eax,%eax
801043db:	78 2a                	js     80104407 <sys_fstat+0x46>
801043dd:	83 ec 04             	sub    $0x4,%esp
801043e0:	6a 14                	push   $0x14
801043e2:	8d 45 f0             	lea    -0x10(%ebp),%eax
801043e5:	50                   	push   %eax
801043e6:	6a 01                	push   $0x1
801043e8:	e8 09 fb ff ff       	call   80103ef6 <argptr>
801043ed:	83 c4 10             	add    $0x10,%esp
801043f0:	85 c0                	test   %eax,%eax
801043f2:	78 1a                	js     8010440e <sys_fstat+0x4d>
  return filestat(f, st);
801043f4:	83 ec 08             	sub    $0x8,%esp
801043f7:	ff 75 f0             	pushl  -0x10(%ebp)
801043fa:	ff 75 f4             	pushl  -0xc(%ebp)
801043fd:	e8 8e c9 ff ff       	call   80100d90 <filestat>
80104402:	83 c4 10             	add    $0x10,%esp
}
80104405:	c9                   	leave  
80104406:	c3                   	ret    
    return -1;
80104407:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010440c:	eb f7                	jmp    80104405 <sys_fstat+0x44>
8010440e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104413:	eb f0                	jmp    80104405 <sys_fstat+0x44>

80104415 <sys_link>:
{
80104415:	55                   	push   %ebp
80104416:	89 e5                	mov    %esp,%ebp
80104418:	56                   	push   %esi
80104419:	53                   	push   %ebx
8010441a:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
8010441d:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104420:	50                   	push   %eax
80104421:	6a 00                	push   $0x0
80104423:	e8 36 fb ff ff       	call   80103f5e <argstr>
80104428:	83 c4 10             	add    $0x10,%esp
8010442b:	85 c0                	test   %eax,%eax
8010442d:	0f 88 32 01 00 00    	js     80104565 <sys_link+0x150>
80104433:	83 ec 08             	sub    $0x8,%esp
80104436:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104439:	50                   	push   %eax
8010443a:	6a 01                	push   $0x1
8010443c:	e8 1d fb ff ff       	call   80103f5e <argstr>
80104441:	83 c4 10             	add    $0x10,%esp
80104444:	85 c0                	test   %eax,%eax
80104446:	0f 88 20 01 00 00    	js     8010456c <sys_link+0x157>
  begin_op();
8010444c:	e8 9f e3 ff ff       	call   801027f0 <begin_op>
  if((ip = namei(old)) == 0){
80104451:	83 ec 0c             	sub    $0xc,%esp
80104454:	ff 75 e0             	pushl  -0x20(%ebp)
80104457:	e8 85 d7 ff ff       	call   80101be1 <namei>
8010445c:	89 c3                	mov    %eax,%ebx
8010445e:	83 c4 10             	add    $0x10,%esp
80104461:	85 c0                	test   %eax,%eax
80104463:	0f 84 99 00 00 00    	je     80104502 <sys_link+0xed>
  ilock(ip);
80104469:	83 ec 0c             	sub    $0xc,%esp
8010446c:	50                   	push   %eax
8010446d:	e8 0f d1 ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
80104472:	83 c4 10             	add    $0x10,%esp
80104475:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010447a:	0f 84 8e 00 00 00    	je     8010450e <sys_link+0xf9>
  ip->nlink++;
80104480:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104484:	83 c0 01             	add    $0x1,%eax
80104487:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010448b:	83 ec 0c             	sub    $0xc,%esp
8010448e:	53                   	push   %ebx
8010448f:	e8 8c cf ff ff       	call   80101420 <iupdate>
  iunlock(ip);
80104494:	89 1c 24             	mov    %ebx,(%esp)
80104497:	e8 a7 d1 ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
8010449c:	83 c4 08             	add    $0x8,%esp
8010449f:	8d 45 ea             	lea    -0x16(%ebp),%eax
801044a2:	50                   	push   %eax
801044a3:	ff 75 e4             	pushl  -0x1c(%ebp)
801044a6:	e8 4e d7 ff ff       	call   80101bf9 <nameiparent>
801044ab:	89 c6                	mov    %eax,%esi
801044ad:	83 c4 10             	add    $0x10,%esp
801044b0:	85 c0                	test   %eax,%eax
801044b2:	74 7e                	je     80104532 <sys_link+0x11d>
  ilock(dp);
801044b4:	83 ec 0c             	sub    $0xc,%esp
801044b7:	50                   	push   %eax
801044b8:	e8 c4 d0 ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
801044bd:	83 c4 10             	add    $0x10,%esp
801044c0:	8b 03                	mov    (%ebx),%eax
801044c2:	39 06                	cmp    %eax,(%esi)
801044c4:	75 60                	jne    80104526 <sys_link+0x111>
801044c6:	83 ec 04             	sub    $0x4,%esp
801044c9:	ff 73 04             	pushl  0x4(%ebx)
801044cc:	8d 45 ea             	lea    -0x16(%ebp),%eax
801044cf:	50                   	push   %eax
801044d0:	56                   	push   %esi
801044d1:	e8 5a d6 ff ff       	call   80101b30 <dirlink>
801044d6:	83 c4 10             	add    $0x10,%esp
801044d9:	85 c0                	test   %eax,%eax
801044db:	78 49                	js     80104526 <sys_link+0x111>
  iunlockput(dp);
801044dd:	83 ec 0c             	sub    $0xc,%esp
801044e0:	56                   	push   %esi
801044e1:	e8 42 d2 ff ff       	call   80101728 <iunlockput>
  iput(ip);
801044e6:	89 1c 24             	mov    %ebx,(%esp)
801044e9:	e8 9a d1 ff ff       	call   80101688 <iput>
  end_op();
801044ee:	e8 77 e3 ff ff       	call   8010286a <end_op>
  return 0;
801044f3:	83 c4 10             	add    $0x10,%esp
801044f6:	b8 00 00 00 00       	mov    $0x0,%eax
}
801044fb:	8d 65 f8             	lea    -0x8(%ebp),%esp
801044fe:	5b                   	pop    %ebx
801044ff:	5e                   	pop    %esi
80104500:	5d                   	pop    %ebp
80104501:	c3                   	ret    
    end_op();
80104502:	e8 63 e3 ff ff       	call   8010286a <end_op>
    return -1;
80104507:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010450c:	eb ed                	jmp    801044fb <sys_link+0xe6>
    iunlockput(ip);
8010450e:	83 ec 0c             	sub    $0xc,%esp
80104511:	53                   	push   %ebx
80104512:	e8 11 d2 ff ff       	call   80101728 <iunlockput>
    end_op();
80104517:	e8 4e e3 ff ff       	call   8010286a <end_op>
    return -1;
8010451c:	83 c4 10             	add    $0x10,%esp
8010451f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104524:	eb d5                	jmp    801044fb <sys_link+0xe6>
    iunlockput(dp);
80104526:	83 ec 0c             	sub    $0xc,%esp
80104529:	56                   	push   %esi
8010452a:	e8 f9 d1 ff ff       	call   80101728 <iunlockput>
    goto bad;
8010452f:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
80104532:	83 ec 0c             	sub    $0xc,%esp
80104535:	53                   	push   %ebx
80104536:	e8 46 d0 ff ff       	call   80101581 <ilock>
  ip->nlink--;
8010453b:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010453f:	83 e8 01             	sub    $0x1,%eax
80104542:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104546:	89 1c 24             	mov    %ebx,(%esp)
80104549:	e8 d2 ce ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
8010454e:	89 1c 24             	mov    %ebx,(%esp)
80104551:	e8 d2 d1 ff ff       	call   80101728 <iunlockput>
  end_op();
80104556:	e8 0f e3 ff ff       	call   8010286a <end_op>
  return -1;
8010455b:	83 c4 10             	add    $0x10,%esp
8010455e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104563:	eb 96                	jmp    801044fb <sys_link+0xe6>
    return -1;
80104565:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010456a:	eb 8f                	jmp    801044fb <sys_link+0xe6>
8010456c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104571:	eb 88                	jmp    801044fb <sys_link+0xe6>

80104573 <sys_unlink>:
{
80104573:	55                   	push   %ebp
80104574:	89 e5                	mov    %esp,%ebp
80104576:	57                   	push   %edi
80104577:	56                   	push   %esi
80104578:	53                   	push   %ebx
80104579:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
8010457c:	8d 45 c4             	lea    -0x3c(%ebp),%eax
8010457f:	50                   	push   %eax
80104580:	6a 00                	push   $0x0
80104582:	e8 d7 f9 ff ff       	call   80103f5e <argstr>
80104587:	83 c4 10             	add    $0x10,%esp
8010458a:	85 c0                	test   %eax,%eax
8010458c:	0f 88 83 01 00 00    	js     80104715 <sys_unlink+0x1a2>
  begin_op();
80104592:	e8 59 e2 ff ff       	call   801027f0 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
80104597:	83 ec 08             	sub    $0x8,%esp
8010459a:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010459d:	50                   	push   %eax
8010459e:	ff 75 c4             	pushl  -0x3c(%ebp)
801045a1:	e8 53 d6 ff ff       	call   80101bf9 <nameiparent>
801045a6:	89 c6                	mov    %eax,%esi
801045a8:	83 c4 10             	add    $0x10,%esp
801045ab:	85 c0                	test   %eax,%eax
801045ad:	0f 84 ed 00 00 00    	je     801046a0 <sys_unlink+0x12d>
  ilock(dp);
801045b3:	83 ec 0c             	sub    $0xc,%esp
801045b6:	50                   	push   %eax
801045b7:	e8 c5 cf ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
801045bc:	83 c4 08             	add    $0x8,%esp
801045bf:	68 5e 6c 10 80       	push   $0x80106c5e
801045c4:	8d 45 ca             	lea    -0x36(%ebp),%eax
801045c7:	50                   	push   %eax
801045c8:	e8 ce d3 ff ff       	call   8010199b <namecmp>
801045cd:	83 c4 10             	add    $0x10,%esp
801045d0:	85 c0                	test   %eax,%eax
801045d2:	0f 84 fc 00 00 00    	je     801046d4 <sys_unlink+0x161>
801045d8:	83 ec 08             	sub    $0x8,%esp
801045db:	68 5d 6c 10 80       	push   $0x80106c5d
801045e0:	8d 45 ca             	lea    -0x36(%ebp),%eax
801045e3:	50                   	push   %eax
801045e4:	e8 b2 d3 ff ff       	call   8010199b <namecmp>
801045e9:	83 c4 10             	add    $0x10,%esp
801045ec:	85 c0                	test   %eax,%eax
801045ee:	0f 84 e0 00 00 00    	je     801046d4 <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
801045f4:	83 ec 04             	sub    $0x4,%esp
801045f7:	8d 45 c0             	lea    -0x40(%ebp),%eax
801045fa:	50                   	push   %eax
801045fb:	8d 45 ca             	lea    -0x36(%ebp),%eax
801045fe:	50                   	push   %eax
801045ff:	56                   	push   %esi
80104600:	e8 ab d3 ff ff       	call   801019b0 <dirlookup>
80104605:	89 c3                	mov    %eax,%ebx
80104607:	83 c4 10             	add    $0x10,%esp
8010460a:	85 c0                	test   %eax,%eax
8010460c:	0f 84 c2 00 00 00    	je     801046d4 <sys_unlink+0x161>
  ilock(ip);
80104612:	83 ec 0c             	sub    $0xc,%esp
80104615:	50                   	push   %eax
80104616:	e8 66 cf ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
8010461b:	83 c4 10             	add    $0x10,%esp
8010461e:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
80104623:	0f 8e 83 00 00 00    	jle    801046ac <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104629:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
8010462e:	0f 84 85 00 00 00    	je     801046b9 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
80104634:	83 ec 04             	sub    $0x4,%esp
80104637:	6a 10                	push   $0x10
80104639:	6a 00                	push   $0x0
8010463b:	8d 7d d8             	lea    -0x28(%ebp),%edi
8010463e:	57                   	push   %edi
8010463f:	e8 3f f6 ff ff       	call   80103c83 <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104644:	6a 10                	push   $0x10
80104646:	ff 75 c0             	pushl  -0x40(%ebp)
80104649:	57                   	push   %edi
8010464a:	56                   	push   %esi
8010464b:	e8 20 d2 ff ff       	call   80101870 <writei>
80104650:	83 c4 20             	add    $0x20,%esp
80104653:	83 f8 10             	cmp    $0x10,%eax
80104656:	0f 85 90 00 00 00    	jne    801046ec <sys_unlink+0x179>
  if(ip->type == T_DIR){
8010465c:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104661:	0f 84 92 00 00 00    	je     801046f9 <sys_unlink+0x186>
  iunlockput(dp);
80104667:	83 ec 0c             	sub    $0xc,%esp
8010466a:	56                   	push   %esi
8010466b:	e8 b8 d0 ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
80104670:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104674:	83 e8 01             	sub    $0x1,%eax
80104677:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
8010467b:	89 1c 24             	mov    %ebx,(%esp)
8010467e:	e8 9d cd ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
80104683:	89 1c 24             	mov    %ebx,(%esp)
80104686:	e8 9d d0 ff ff       	call   80101728 <iunlockput>
  end_op();
8010468b:	e8 da e1 ff ff       	call   8010286a <end_op>
  return 0;
80104690:	83 c4 10             	add    $0x10,%esp
80104693:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104698:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010469b:	5b                   	pop    %ebx
8010469c:	5e                   	pop    %esi
8010469d:	5f                   	pop    %edi
8010469e:	5d                   	pop    %ebp
8010469f:	c3                   	ret    
    end_op();
801046a0:	e8 c5 e1 ff ff       	call   8010286a <end_op>
    return -1;
801046a5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046aa:	eb ec                	jmp    80104698 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
801046ac:	83 ec 0c             	sub    $0xc,%esp
801046af:	68 7c 6c 10 80       	push   $0x80106c7c
801046b4:	e8 8f bc ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
801046b9:	89 d8                	mov    %ebx,%eax
801046bb:	e8 c4 f9 ff ff       	call   80104084 <isdirempty>
801046c0:	85 c0                	test   %eax,%eax
801046c2:	0f 85 6c ff ff ff    	jne    80104634 <sys_unlink+0xc1>
    iunlockput(ip);
801046c8:	83 ec 0c             	sub    $0xc,%esp
801046cb:	53                   	push   %ebx
801046cc:	e8 57 d0 ff ff       	call   80101728 <iunlockput>
    goto bad;
801046d1:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
801046d4:	83 ec 0c             	sub    $0xc,%esp
801046d7:	56                   	push   %esi
801046d8:	e8 4b d0 ff ff       	call   80101728 <iunlockput>
  end_op();
801046dd:	e8 88 e1 ff ff       	call   8010286a <end_op>
  return -1;
801046e2:	83 c4 10             	add    $0x10,%esp
801046e5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ea:	eb ac                	jmp    80104698 <sys_unlink+0x125>
    panic("unlink: writei");
801046ec:	83 ec 0c             	sub    $0xc,%esp
801046ef:	68 8e 6c 10 80       	push   $0x80106c8e
801046f4:	e8 4f bc ff ff       	call   80100348 <panic>
    dp->nlink--;
801046f9:	0f b7 46 56          	movzwl 0x56(%esi),%eax
801046fd:	83 e8 01             	sub    $0x1,%eax
80104700:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104704:	83 ec 0c             	sub    $0xc,%esp
80104707:	56                   	push   %esi
80104708:	e8 13 cd ff ff       	call   80101420 <iupdate>
8010470d:	83 c4 10             	add    $0x10,%esp
80104710:	e9 52 ff ff ff       	jmp    80104667 <sys_unlink+0xf4>
    return -1;
80104715:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010471a:	e9 79 ff ff ff       	jmp    80104698 <sys_unlink+0x125>

8010471f <sys_open>:

int
sys_open(void)
{
8010471f:	55                   	push   %ebp
80104720:	89 e5                	mov    %esp,%ebp
80104722:	57                   	push   %edi
80104723:	56                   	push   %esi
80104724:	53                   	push   %ebx
80104725:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104728:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010472b:	50                   	push   %eax
8010472c:	6a 00                	push   $0x0
8010472e:	e8 2b f8 ff ff       	call   80103f5e <argstr>
80104733:	83 c4 10             	add    $0x10,%esp
80104736:	85 c0                	test   %eax,%eax
80104738:	0f 88 30 01 00 00    	js     8010486e <sys_open+0x14f>
8010473e:	83 ec 08             	sub    $0x8,%esp
80104741:	8d 45 e0             	lea    -0x20(%ebp),%eax
80104744:	50                   	push   %eax
80104745:	6a 01                	push   $0x1
80104747:	e8 82 f7 ff ff       	call   80103ece <argint>
8010474c:	83 c4 10             	add    $0x10,%esp
8010474f:	85 c0                	test   %eax,%eax
80104751:	0f 88 21 01 00 00    	js     80104878 <sys_open+0x159>
    return -1;

  begin_op();
80104757:	e8 94 e0 ff ff       	call   801027f0 <begin_op>

  if(omode & O_CREATE){
8010475c:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
80104760:	0f 84 84 00 00 00    	je     801047ea <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
80104766:	83 ec 0c             	sub    $0xc,%esp
80104769:	6a 00                	push   $0x0
8010476b:	b9 00 00 00 00       	mov    $0x0,%ecx
80104770:	ba 02 00 00 00       	mov    $0x2,%edx
80104775:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104778:	e8 5e f9 ff ff       	call   801040db <create>
8010477d:	89 c6                	mov    %eax,%esi
    if(ip == 0){
8010477f:	83 c4 10             	add    $0x10,%esp
80104782:	85 c0                	test   %eax,%eax
80104784:	74 58                	je     801047de <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
80104786:	e8 a2 c4 ff ff       	call   80100c2d <filealloc>
8010478b:	89 c3                	mov    %eax,%ebx
8010478d:	85 c0                	test   %eax,%eax
8010478f:	0f 84 ae 00 00 00    	je     80104843 <sys_open+0x124>
80104795:	e8 b3 f8 ff ff       	call   8010404d <fdalloc>
8010479a:	89 c7                	mov    %eax,%edi
8010479c:	85 c0                	test   %eax,%eax
8010479e:	0f 88 9f 00 00 00    	js     80104843 <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801047a4:	83 ec 0c             	sub    $0xc,%esp
801047a7:	56                   	push   %esi
801047a8:	e8 96 ce ff ff       	call   80101643 <iunlock>
  end_op();
801047ad:	e8 b8 e0 ff ff       	call   8010286a <end_op>

  f->type = FD_INODE;
801047b2:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
801047b8:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
801047bb:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
801047c2:	8b 45 e0             	mov    -0x20(%ebp),%eax
801047c5:	83 c4 10             	add    $0x10,%esp
801047c8:	a8 01                	test   $0x1,%al
801047ca:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
801047ce:	a8 03                	test   $0x3,%al
801047d0:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
801047d4:	89 f8                	mov    %edi,%eax
801047d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801047d9:	5b                   	pop    %ebx
801047da:	5e                   	pop    %esi
801047db:	5f                   	pop    %edi
801047dc:	5d                   	pop    %ebp
801047dd:	c3                   	ret    
      end_op();
801047de:	e8 87 e0 ff ff       	call   8010286a <end_op>
      return -1;
801047e3:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801047e8:	eb ea                	jmp    801047d4 <sys_open+0xb5>
    if((ip = namei(path)) == 0){
801047ea:	83 ec 0c             	sub    $0xc,%esp
801047ed:	ff 75 e4             	pushl  -0x1c(%ebp)
801047f0:	e8 ec d3 ff ff       	call   80101be1 <namei>
801047f5:	89 c6                	mov    %eax,%esi
801047f7:	83 c4 10             	add    $0x10,%esp
801047fa:	85 c0                	test   %eax,%eax
801047fc:	74 39                	je     80104837 <sys_open+0x118>
    ilock(ip);
801047fe:	83 ec 0c             	sub    $0xc,%esp
80104801:	50                   	push   %eax
80104802:	e8 7a cd ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104807:	83 c4 10             	add    $0x10,%esp
8010480a:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
8010480f:	0f 85 71 ff ff ff    	jne    80104786 <sys_open+0x67>
80104815:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104819:	0f 84 67 ff ff ff    	je     80104786 <sys_open+0x67>
      iunlockput(ip);
8010481f:	83 ec 0c             	sub    $0xc,%esp
80104822:	56                   	push   %esi
80104823:	e8 00 cf ff ff       	call   80101728 <iunlockput>
      end_op();
80104828:	e8 3d e0 ff ff       	call   8010286a <end_op>
      return -1;
8010482d:	83 c4 10             	add    $0x10,%esp
80104830:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104835:	eb 9d                	jmp    801047d4 <sys_open+0xb5>
      end_op();
80104837:	e8 2e e0 ff ff       	call   8010286a <end_op>
      return -1;
8010483c:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104841:	eb 91                	jmp    801047d4 <sys_open+0xb5>
    if(f)
80104843:	85 db                	test   %ebx,%ebx
80104845:	74 0c                	je     80104853 <sys_open+0x134>
      fileclose(f);
80104847:	83 ec 0c             	sub    $0xc,%esp
8010484a:	53                   	push   %ebx
8010484b:	e8 83 c4 ff ff       	call   80100cd3 <fileclose>
80104850:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
80104853:	83 ec 0c             	sub    $0xc,%esp
80104856:	56                   	push   %esi
80104857:	e8 cc ce ff ff       	call   80101728 <iunlockput>
    end_op();
8010485c:	e8 09 e0 ff ff       	call   8010286a <end_op>
    return -1;
80104861:	83 c4 10             	add    $0x10,%esp
80104864:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104869:	e9 66 ff ff ff       	jmp    801047d4 <sys_open+0xb5>
    return -1;
8010486e:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104873:	e9 5c ff ff ff       	jmp    801047d4 <sys_open+0xb5>
80104878:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010487d:	e9 52 ff ff ff       	jmp    801047d4 <sys_open+0xb5>

80104882 <sys_mkdir>:

int
sys_mkdir(void)
{
80104882:	55                   	push   %ebp
80104883:	89 e5                	mov    %esp,%ebp
80104885:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104888:	e8 63 df ff ff       	call   801027f0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
8010488d:	83 ec 08             	sub    $0x8,%esp
80104890:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104893:	50                   	push   %eax
80104894:	6a 00                	push   $0x0
80104896:	e8 c3 f6 ff ff       	call   80103f5e <argstr>
8010489b:	83 c4 10             	add    $0x10,%esp
8010489e:	85 c0                	test   %eax,%eax
801048a0:	78 36                	js     801048d8 <sys_mkdir+0x56>
801048a2:	83 ec 0c             	sub    $0xc,%esp
801048a5:	6a 00                	push   $0x0
801048a7:	b9 00 00 00 00       	mov    $0x0,%ecx
801048ac:	ba 01 00 00 00       	mov    $0x1,%edx
801048b1:	8b 45 f4             	mov    -0xc(%ebp),%eax
801048b4:	e8 22 f8 ff ff       	call   801040db <create>
801048b9:	83 c4 10             	add    $0x10,%esp
801048bc:	85 c0                	test   %eax,%eax
801048be:	74 18                	je     801048d8 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
801048c0:	83 ec 0c             	sub    $0xc,%esp
801048c3:	50                   	push   %eax
801048c4:	e8 5f ce ff ff       	call   80101728 <iunlockput>
  end_op();
801048c9:	e8 9c df ff ff       	call   8010286a <end_op>
  return 0;
801048ce:	83 c4 10             	add    $0x10,%esp
801048d1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801048d6:	c9                   	leave  
801048d7:	c3                   	ret    
    end_op();
801048d8:	e8 8d df ff ff       	call   8010286a <end_op>
    return -1;
801048dd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048e2:	eb f2                	jmp    801048d6 <sys_mkdir+0x54>

801048e4 <sys_mknod>:

int
sys_mknod(void)
{
801048e4:	55                   	push   %ebp
801048e5:	89 e5                	mov    %esp,%ebp
801048e7:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
801048ea:	e8 01 df ff ff       	call   801027f0 <begin_op>
  if((argstr(0, &path)) < 0 ||
801048ef:	83 ec 08             	sub    $0x8,%esp
801048f2:	8d 45 f4             	lea    -0xc(%ebp),%eax
801048f5:	50                   	push   %eax
801048f6:	6a 00                	push   $0x0
801048f8:	e8 61 f6 ff ff       	call   80103f5e <argstr>
801048fd:	83 c4 10             	add    $0x10,%esp
80104900:	85 c0                	test   %eax,%eax
80104902:	78 62                	js     80104966 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104904:	83 ec 08             	sub    $0x8,%esp
80104907:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010490a:	50                   	push   %eax
8010490b:	6a 01                	push   $0x1
8010490d:	e8 bc f5 ff ff       	call   80103ece <argint>
  if((argstr(0, &path)) < 0 ||
80104912:	83 c4 10             	add    $0x10,%esp
80104915:	85 c0                	test   %eax,%eax
80104917:	78 4d                	js     80104966 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104919:	83 ec 08             	sub    $0x8,%esp
8010491c:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010491f:	50                   	push   %eax
80104920:	6a 02                	push   $0x2
80104922:	e8 a7 f5 ff ff       	call   80103ece <argint>
     argint(1, &major) < 0 ||
80104927:	83 c4 10             	add    $0x10,%esp
8010492a:	85 c0                	test   %eax,%eax
8010492c:	78 38                	js     80104966 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
8010492e:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104932:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104936:	83 ec 0c             	sub    $0xc,%esp
80104939:	50                   	push   %eax
8010493a:	ba 03 00 00 00       	mov    $0x3,%edx
8010493f:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104942:	e8 94 f7 ff ff       	call   801040db <create>
80104947:	83 c4 10             	add    $0x10,%esp
8010494a:	85 c0                	test   %eax,%eax
8010494c:	74 18                	je     80104966 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
8010494e:	83 ec 0c             	sub    $0xc,%esp
80104951:	50                   	push   %eax
80104952:	e8 d1 cd ff ff       	call   80101728 <iunlockput>
  end_op();
80104957:	e8 0e df ff ff       	call   8010286a <end_op>
  return 0;
8010495c:	83 c4 10             	add    $0x10,%esp
8010495f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104964:	c9                   	leave  
80104965:	c3                   	ret    
    end_op();
80104966:	e8 ff de ff ff       	call   8010286a <end_op>
    return -1;
8010496b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104970:	eb f2                	jmp    80104964 <sys_mknod+0x80>

80104972 <sys_chdir>:

int
sys_chdir(void)
{
80104972:	55                   	push   %ebp
80104973:	89 e5                	mov    %esp,%ebp
80104975:	56                   	push   %esi
80104976:	53                   	push   %ebx
80104977:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
8010497a:	e8 b9 e8 ff ff       	call   80103238 <myproc>
8010497f:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104981:	e8 6a de ff ff       	call   801027f0 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104986:	83 ec 08             	sub    $0x8,%esp
80104989:	8d 45 f4             	lea    -0xc(%ebp),%eax
8010498c:	50                   	push   %eax
8010498d:	6a 00                	push   $0x0
8010498f:	e8 ca f5 ff ff       	call   80103f5e <argstr>
80104994:	83 c4 10             	add    $0x10,%esp
80104997:	85 c0                	test   %eax,%eax
80104999:	78 52                	js     801049ed <sys_chdir+0x7b>
8010499b:	83 ec 0c             	sub    $0xc,%esp
8010499e:	ff 75 f4             	pushl  -0xc(%ebp)
801049a1:	e8 3b d2 ff ff       	call   80101be1 <namei>
801049a6:	89 c3                	mov    %eax,%ebx
801049a8:	83 c4 10             	add    $0x10,%esp
801049ab:	85 c0                	test   %eax,%eax
801049ad:	74 3e                	je     801049ed <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
801049af:	83 ec 0c             	sub    $0xc,%esp
801049b2:	50                   	push   %eax
801049b3:	e8 c9 cb ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
801049b8:	83 c4 10             	add    $0x10,%esp
801049bb:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801049c0:	75 37                	jne    801049f9 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801049c2:	83 ec 0c             	sub    $0xc,%esp
801049c5:	53                   	push   %ebx
801049c6:	e8 78 cc ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
801049cb:	83 c4 04             	add    $0x4,%esp
801049ce:	ff 76 68             	pushl  0x68(%esi)
801049d1:	e8 b2 cc ff ff       	call   80101688 <iput>
  end_op();
801049d6:	e8 8f de ff ff       	call   8010286a <end_op>
  curproc->cwd = ip;
801049db:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
801049de:	83 c4 10             	add    $0x10,%esp
801049e1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801049e6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801049e9:	5b                   	pop    %ebx
801049ea:	5e                   	pop    %esi
801049eb:	5d                   	pop    %ebp
801049ec:	c3                   	ret    
    end_op();
801049ed:	e8 78 de ff ff       	call   8010286a <end_op>
    return -1;
801049f2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801049f7:	eb ed                	jmp    801049e6 <sys_chdir+0x74>
    iunlockput(ip);
801049f9:	83 ec 0c             	sub    $0xc,%esp
801049fc:	53                   	push   %ebx
801049fd:	e8 26 cd ff ff       	call   80101728 <iunlockput>
    end_op();
80104a02:	e8 63 de ff ff       	call   8010286a <end_op>
    return -1;
80104a07:	83 c4 10             	add    $0x10,%esp
80104a0a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a0f:	eb d5                	jmp    801049e6 <sys_chdir+0x74>

80104a11 <sys_exec>:

int
sys_exec(void)
{
80104a11:	55                   	push   %ebp
80104a12:	89 e5                	mov    %esp,%ebp
80104a14:	53                   	push   %ebx
80104a15:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104a1b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a1e:	50                   	push   %eax
80104a1f:	6a 00                	push   $0x0
80104a21:	e8 38 f5 ff ff       	call   80103f5e <argstr>
80104a26:	83 c4 10             	add    $0x10,%esp
80104a29:	85 c0                	test   %eax,%eax
80104a2b:	0f 88 a8 00 00 00    	js     80104ad9 <sys_exec+0xc8>
80104a31:	83 ec 08             	sub    $0x8,%esp
80104a34:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104a3a:	50                   	push   %eax
80104a3b:	6a 01                	push   $0x1
80104a3d:	e8 8c f4 ff ff       	call   80103ece <argint>
80104a42:	83 c4 10             	add    $0x10,%esp
80104a45:	85 c0                	test   %eax,%eax
80104a47:	0f 88 93 00 00 00    	js     80104ae0 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104a4d:	83 ec 04             	sub    $0x4,%esp
80104a50:	68 80 00 00 00       	push   $0x80
80104a55:	6a 00                	push   $0x0
80104a57:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104a5d:	50                   	push   %eax
80104a5e:	e8 20 f2 ff ff       	call   80103c83 <memset>
80104a63:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104a66:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104a6b:	83 fb 1f             	cmp    $0x1f,%ebx
80104a6e:	77 77                	ja     80104ae7 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104a70:	83 ec 08             	sub    $0x8,%esp
80104a73:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104a79:	50                   	push   %eax
80104a7a:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104a80:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104a83:	50                   	push   %eax
80104a84:	e8 c9 f3 ff ff       	call   80103e52 <fetchint>
80104a89:	83 c4 10             	add    $0x10,%esp
80104a8c:	85 c0                	test   %eax,%eax
80104a8e:	78 5e                	js     80104aee <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104a90:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104a96:	85 c0                	test   %eax,%eax
80104a98:	74 1d                	je     80104ab7 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104a9a:	83 ec 08             	sub    $0x8,%esp
80104a9d:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104aa4:	52                   	push   %edx
80104aa5:	50                   	push   %eax
80104aa6:	e8 e3 f3 ff ff       	call   80103e8e <fetchstr>
80104aab:	83 c4 10             	add    $0x10,%esp
80104aae:	85 c0                	test   %eax,%eax
80104ab0:	78 46                	js     80104af8 <sys_exec+0xe7>
  for(i=0;; i++){
80104ab2:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104ab5:	eb b4                	jmp    80104a6b <sys_exec+0x5a>
      argv[i] = 0;
80104ab7:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104abe:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104ac2:	83 ec 08             	sub    $0x8,%esp
80104ac5:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104acb:	50                   	push   %eax
80104acc:	ff 75 f4             	pushl  -0xc(%ebp)
80104acf:	e8 fe bd ff ff       	call   801008d2 <exec>
80104ad4:	83 c4 10             	add    $0x10,%esp
80104ad7:	eb 1a                	jmp    80104af3 <sys_exec+0xe2>
    return -1;
80104ad9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ade:	eb 13                	jmp    80104af3 <sys_exec+0xe2>
80104ae0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ae5:	eb 0c                	jmp    80104af3 <sys_exec+0xe2>
      return -1;
80104ae7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aec:	eb 05                	jmp    80104af3 <sys_exec+0xe2>
      return -1;
80104aee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104af3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104af6:	c9                   	leave  
80104af7:	c3                   	ret    
      return -1;
80104af8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104afd:	eb f4                	jmp    80104af3 <sys_exec+0xe2>

80104aff <sys_pipe>:

int
sys_pipe(void)
{
80104aff:	55                   	push   %ebp
80104b00:	89 e5                	mov    %esp,%ebp
80104b02:	53                   	push   %ebx
80104b03:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104b06:	6a 08                	push   $0x8
80104b08:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b0b:	50                   	push   %eax
80104b0c:	6a 00                	push   $0x0
80104b0e:	e8 e3 f3 ff ff       	call   80103ef6 <argptr>
80104b13:	83 c4 10             	add    $0x10,%esp
80104b16:	85 c0                	test   %eax,%eax
80104b18:	78 77                	js     80104b91 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104b1a:	83 ec 08             	sub    $0x8,%esp
80104b1d:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104b20:	50                   	push   %eax
80104b21:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104b24:	50                   	push   %eax
80104b25:	e8 4d e2 ff ff       	call   80102d77 <pipealloc>
80104b2a:	83 c4 10             	add    $0x10,%esp
80104b2d:	85 c0                	test   %eax,%eax
80104b2f:	78 67                	js     80104b98 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104b31:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104b34:	e8 14 f5 ff ff       	call   8010404d <fdalloc>
80104b39:	89 c3                	mov    %eax,%ebx
80104b3b:	85 c0                	test   %eax,%eax
80104b3d:	78 21                	js     80104b60 <sys_pipe+0x61>
80104b3f:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104b42:	e8 06 f5 ff ff       	call   8010404d <fdalloc>
80104b47:	85 c0                	test   %eax,%eax
80104b49:	78 15                	js     80104b60 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104b4b:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b4e:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104b50:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104b53:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104b56:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b5b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104b5e:	c9                   	leave  
80104b5f:	c3                   	ret    
    if(fd0 >= 0)
80104b60:	85 db                	test   %ebx,%ebx
80104b62:	78 0d                	js     80104b71 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104b64:	e8 cf e6 ff ff       	call   80103238 <myproc>
80104b69:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104b70:	00 
    fileclose(rf);
80104b71:	83 ec 0c             	sub    $0xc,%esp
80104b74:	ff 75 f0             	pushl  -0x10(%ebp)
80104b77:	e8 57 c1 ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104b7c:	83 c4 04             	add    $0x4,%esp
80104b7f:	ff 75 ec             	pushl  -0x14(%ebp)
80104b82:	e8 4c c1 ff ff       	call   80100cd3 <fileclose>
    return -1;
80104b87:	83 c4 10             	add    $0x10,%esp
80104b8a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b8f:	eb ca                	jmp    80104b5b <sys_pipe+0x5c>
    return -1;
80104b91:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b96:	eb c3                	jmp    80104b5b <sys_pipe+0x5c>
    return -1;
80104b98:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b9d:	eb bc                	jmp    80104b5b <sys_pipe+0x5c>

80104b9f <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104b9f:	55                   	push   %ebp
80104ba0:	89 e5                	mov    %esp,%ebp
80104ba2:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104ba5:	e8 06 e8 ff ff       	call   801033b0 <fork>
}
80104baa:	c9                   	leave  
80104bab:	c3                   	ret    

80104bac <sys_exit>:

int
sys_exit(void)
{
80104bac:	55                   	push   %ebp
80104bad:	89 e5                	mov    %esp,%ebp
80104baf:	83 ec 08             	sub    $0x8,%esp
  exit();
80104bb2:	e8 2d ea ff ff       	call   801035e4 <exit>
  return 0;  // not reached
}
80104bb7:	b8 00 00 00 00       	mov    $0x0,%eax
80104bbc:	c9                   	leave  
80104bbd:	c3                   	ret    

80104bbe <sys_wait>:

int
sys_wait(void)
{
80104bbe:	55                   	push   %ebp
80104bbf:	89 e5                	mov    %esp,%ebp
80104bc1:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104bc4:	e8 a4 eb ff ff       	call   8010376d <wait>
}
80104bc9:	c9                   	leave  
80104bca:	c3                   	ret    

80104bcb <sys_kill>:

int
sys_kill(void)
{
80104bcb:	55                   	push   %ebp
80104bcc:	89 e5                	mov    %esp,%ebp
80104bce:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104bd1:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104bd4:	50                   	push   %eax
80104bd5:	6a 00                	push   $0x0
80104bd7:	e8 f2 f2 ff ff       	call   80103ece <argint>
80104bdc:	83 c4 10             	add    $0x10,%esp
80104bdf:	85 c0                	test   %eax,%eax
80104be1:	78 10                	js     80104bf3 <sys_kill+0x28>
    return -1;
  return kill(pid);
80104be3:	83 ec 0c             	sub    $0xc,%esp
80104be6:	ff 75 f4             	pushl  -0xc(%ebp)
80104be9:	e8 7c ec ff ff       	call   8010386a <kill>
80104bee:	83 c4 10             	add    $0x10,%esp
}
80104bf1:	c9                   	leave  
80104bf2:	c3                   	ret    
    return -1;
80104bf3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104bf8:	eb f7                	jmp    80104bf1 <sys_kill+0x26>

80104bfa <sys_getpid>:

int
sys_getpid(void)
{
80104bfa:	55                   	push   %ebp
80104bfb:	89 e5                	mov    %esp,%ebp
80104bfd:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104c00:	e8 33 e6 ff ff       	call   80103238 <myproc>
80104c05:	8b 40 10             	mov    0x10(%eax),%eax
}
80104c08:	c9                   	leave  
80104c09:	c3                   	ret    

80104c0a <sys_sbrk>:

int
sys_sbrk(void)
{
80104c0a:	55                   	push   %ebp
80104c0b:	89 e5                	mov    %esp,%ebp
80104c0d:	53                   	push   %ebx
80104c0e:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104c11:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c14:	50                   	push   %eax
80104c15:	6a 00                	push   $0x0
80104c17:	e8 b2 f2 ff ff       	call   80103ece <argint>
80104c1c:	83 c4 10             	add    $0x10,%esp
80104c1f:	85 c0                	test   %eax,%eax
80104c21:	78 27                	js     80104c4a <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104c23:	e8 10 e6 ff ff       	call   80103238 <myproc>
80104c28:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104c2a:	83 ec 0c             	sub    $0xc,%esp
80104c2d:	ff 75 f4             	pushl  -0xc(%ebp)
80104c30:	e8 0e e7 ff ff       	call   80103343 <growproc>
80104c35:	83 c4 10             	add    $0x10,%esp
80104c38:	85 c0                	test   %eax,%eax
80104c3a:	78 07                	js     80104c43 <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104c3c:	89 d8                	mov    %ebx,%eax
80104c3e:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c41:	c9                   	leave  
80104c42:	c3                   	ret    
    return -1;
80104c43:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104c48:	eb f2                	jmp    80104c3c <sys_sbrk+0x32>
    return -1;
80104c4a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104c4f:	eb eb                	jmp    80104c3c <sys_sbrk+0x32>

80104c51 <sys_sleep>:

int
sys_sleep(void)
{
80104c51:	55                   	push   %ebp
80104c52:	89 e5                	mov    %esp,%ebp
80104c54:	53                   	push   %ebx
80104c55:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104c58:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c5b:	50                   	push   %eax
80104c5c:	6a 00                	push   $0x0
80104c5e:	e8 6b f2 ff ff       	call   80103ece <argint>
80104c63:	83 c4 10             	add    $0x10,%esp
80104c66:	85 c0                	test   %eax,%eax
80104c68:	78 75                	js     80104cdf <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104c6a:	83 ec 0c             	sub    $0xc,%esp
80104c6d:	68 a0 bc 16 80       	push   $0x8016bca0
80104c72:	e8 60 ef ff ff       	call   80103bd7 <acquire>
  ticks0 = ticks;
80104c77:	8b 1d e0 c4 16 80    	mov    0x8016c4e0,%ebx
  while(ticks - ticks0 < n){
80104c7d:	83 c4 10             	add    $0x10,%esp
80104c80:	a1 e0 c4 16 80       	mov    0x8016c4e0,%eax
80104c85:	29 d8                	sub    %ebx,%eax
80104c87:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104c8a:	73 39                	jae    80104cc5 <sys_sleep+0x74>
    if(myproc()->killed){
80104c8c:	e8 a7 e5 ff ff       	call   80103238 <myproc>
80104c91:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104c95:	75 17                	jne    80104cae <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104c97:	83 ec 08             	sub    $0x8,%esp
80104c9a:	68 a0 bc 16 80       	push   $0x8016bca0
80104c9f:	68 e0 c4 16 80       	push   $0x8016c4e0
80104ca4:	e8 33 ea ff ff       	call   801036dc <sleep>
80104ca9:	83 c4 10             	add    $0x10,%esp
80104cac:	eb d2                	jmp    80104c80 <sys_sleep+0x2f>
      release(&tickslock);
80104cae:	83 ec 0c             	sub    $0xc,%esp
80104cb1:	68 a0 bc 16 80       	push   $0x8016bca0
80104cb6:	e8 81 ef ff ff       	call   80103c3c <release>
      return -1;
80104cbb:	83 c4 10             	add    $0x10,%esp
80104cbe:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cc3:	eb 15                	jmp    80104cda <sys_sleep+0x89>
  }
  release(&tickslock);
80104cc5:	83 ec 0c             	sub    $0xc,%esp
80104cc8:	68 a0 bc 16 80       	push   $0x8016bca0
80104ccd:	e8 6a ef ff ff       	call   80103c3c <release>
  return 0;
80104cd2:	83 c4 10             	add    $0x10,%esp
80104cd5:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cda:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cdd:	c9                   	leave  
80104cde:	c3                   	ret    
    return -1;
80104cdf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ce4:	eb f4                	jmp    80104cda <sys_sleep+0x89>

80104ce6 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104ce6:	55                   	push   %ebp
80104ce7:	89 e5                	mov    %esp,%ebp
80104ce9:	53                   	push   %ebx
80104cea:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104ced:	68 a0 bc 16 80       	push   $0x8016bca0
80104cf2:	e8 e0 ee ff ff       	call   80103bd7 <acquire>
  xticks = ticks;
80104cf7:	8b 1d e0 c4 16 80    	mov    0x8016c4e0,%ebx
  release(&tickslock);
80104cfd:	c7 04 24 a0 bc 16 80 	movl   $0x8016bca0,(%esp)
80104d04:	e8 33 ef ff ff       	call   80103c3c <release>
  return xticks;
}
80104d09:	89 d8                	mov    %ebx,%eax
80104d0b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d0e:	c9                   	leave  
80104d0f:	c3                   	ret    

80104d10 <sys_dump_physmem>:

// used for p5
// find which process owns each frame of phys mem
int
sys_dump_physmem(void)
{
80104d10:	55                   	push   %ebp
80104d11:	89 e5                	mov    %esp,%ebp
80104d13:	81 ec 24 00 02 00    	sub    $0x20024,%esp
  #define MAX_FNUM 16384
  int frames[MAX_FNUM];
  int pids[MAX_FNUM];
  int numframes;
  cprintf("sys_dump_physmem in sysproc.c\n");
80104d19:	68 a0 6c 10 80       	push   $0x80106ca0
80104d1e:	e8 e8 b8 ff ff       	call   8010060b <cprintf>
  if(argptr(0, (char**)&frames, sizeof(int*)) < 0)
80104d23:	83 c4 0c             	add    $0xc,%esp
80104d26:	6a 04                	push   $0x4
80104d28:	8d 85 f8 ff fe ff    	lea    -0x10008(%ebp),%eax
80104d2e:	50                   	push   %eax
80104d2f:	6a 00                	push   $0x0
80104d31:	e8 c0 f1 ff ff       	call   80103ef6 <argptr>
80104d36:	83 c4 10             	add    $0x10,%esp
80104d39:	85 c0                	test   %eax,%eax
80104d3b:	78 53                	js     80104d90 <sys_dump_physmem+0x80>
    return -1;
  if(argptr(1, (char**)&pids, sizeof(int*)) < 0)
80104d3d:	83 ec 04             	sub    $0x4,%esp
80104d40:	6a 04                	push   $0x4
80104d42:	8d 85 f8 ff fd ff    	lea    -0x20008(%ebp),%eax
80104d48:	50                   	push   %eax
80104d49:	6a 01                	push   $0x1
80104d4b:	e8 a6 f1 ff ff       	call   80103ef6 <argptr>
80104d50:	83 c4 10             	add    $0x10,%esp
80104d53:	85 c0                	test   %eax,%eax
80104d55:	78 40                	js     80104d97 <sys_dump_physmem+0x87>
    return -1;
  if(argint(2, &numframes) < 0)
80104d57:	83 ec 08             	sub    $0x8,%esp
80104d5a:	8d 85 f4 ff fd ff    	lea    -0x2000c(%ebp),%eax
80104d60:	50                   	push   %eax
80104d61:	6a 02                	push   $0x2
80104d63:	e8 66 f1 ff ff       	call   80103ece <argint>
80104d68:	83 c4 10             	add    $0x10,%esp
80104d6b:	85 c0                	test   %eax,%eax
80104d6d:	78 2f                	js     80104d9e <sys_dump_physmem+0x8e>
    return -1;
  return dump_physmem(frames, pids, numframes);
80104d6f:	83 ec 04             	sub    $0x4,%esp
80104d72:	ff b5 f4 ff fd ff    	pushl  -0x2000c(%ebp)
80104d78:	8d 85 f8 ff fd ff    	lea    -0x20008(%ebp),%eax
80104d7e:	50                   	push   %eax
80104d7f:	8d 85 f8 ff fe ff    	lea    -0x10008(%ebp),%eax
80104d85:	50                   	push   %eax
80104d86:	e8 85 d3 ff ff       	call   80102110 <dump_physmem>
80104d8b:	83 c4 10             	add    $0x10,%esp
}
80104d8e:	c9                   	leave  
80104d8f:	c3                   	ret    
    return -1;
80104d90:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d95:	eb f7                	jmp    80104d8e <sys_dump_physmem+0x7e>
    return -1;
80104d97:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d9c:	eb f0                	jmp    80104d8e <sys_dump_physmem+0x7e>
    return -1;
80104d9e:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104da3:	eb e9                	jmp    80104d8e <sys_dump_physmem+0x7e>

80104da5 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104da5:	1e                   	push   %ds
  pushl %es
80104da6:	06                   	push   %es
  pushl %fs
80104da7:	0f a0                	push   %fs
  pushl %gs
80104da9:	0f a8                	push   %gs
  pushal
80104dab:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104dac:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104db0:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104db2:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104db4:	54                   	push   %esp
  call trap
80104db5:	e8 e3 00 00 00       	call   80104e9d <trap>
  addl $4, %esp
80104dba:	83 c4 04             	add    $0x4,%esp

80104dbd <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104dbd:	61                   	popa   
  popl %gs
80104dbe:	0f a9                	pop    %gs
  popl %fs
80104dc0:	0f a1                	pop    %fs
  popl %es
80104dc2:	07                   	pop    %es
  popl %ds
80104dc3:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104dc4:	83 c4 08             	add    $0x8,%esp
  iret
80104dc7:	cf                   	iret   

80104dc8 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104dc8:	55                   	push   %ebp
80104dc9:	89 e5                	mov    %esp,%ebp
80104dcb:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104dce:	b8 00 00 00 00       	mov    $0x0,%eax
80104dd3:	eb 4a                	jmp    80104e1f <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104dd5:	8b 0c 85 08 90 10 80 	mov    -0x7fef6ff8(,%eax,4),%ecx
80104ddc:	66 89 0c c5 e0 bc 16 	mov    %cx,-0x7fe94320(,%eax,8)
80104de3:	80 
80104de4:	66 c7 04 c5 e2 bc 16 	movw   $0x8,-0x7fe9431e(,%eax,8)
80104deb:	80 08 00 
80104dee:	c6 04 c5 e4 bc 16 80 	movb   $0x0,-0x7fe9431c(,%eax,8)
80104df5:	00 
80104df6:	0f b6 14 c5 e5 bc 16 	movzbl -0x7fe9431b(,%eax,8),%edx
80104dfd:	80 
80104dfe:	83 e2 f0             	and    $0xfffffff0,%edx
80104e01:	83 ca 0e             	or     $0xe,%edx
80104e04:	83 e2 8f             	and    $0xffffff8f,%edx
80104e07:	83 ca 80             	or     $0xffffff80,%edx
80104e0a:	88 14 c5 e5 bc 16 80 	mov    %dl,-0x7fe9431b(,%eax,8)
80104e11:	c1 e9 10             	shr    $0x10,%ecx
80104e14:	66 89 0c c5 e6 bc 16 	mov    %cx,-0x7fe9431a(,%eax,8)
80104e1b:	80 
  for(i = 0; i < 256; i++)
80104e1c:	83 c0 01             	add    $0x1,%eax
80104e1f:	3d ff 00 00 00       	cmp    $0xff,%eax
80104e24:	7e af                	jle    80104dd5 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104e26:	8b 15 08 91 10 80    	mov    0x80109108,%edx
80104e2c:	66 89 15 e0 be 16 80 	mov    %dx,0x8016bee0
80104e33:	66 c7 05 e2 be 16 80 	movw   $0x8,0x8016bee2
80104e3a:	08 00 
80104e3c:	c6 05 e4 be 16 80 00 	movb   $0x0,0x8016bee4
80104e43:	0f b6 05 e5 be 16 80 	movzbl 0x8016bee5,%eax
80104e4a:	83 c8 0f             	or     $0xf,%eax
80104e4d:	83 e0 ef             	and    $0xffffffef,%eax
80104e50:	83 c8 e0             	or     $0xffffffe0,%eax
80104e53:	a2 e5 be 16 80       	mov    %al,0x8016bee5
80104e58:	c1 ea 10             	shr    $0x10,%edx
80104e5b:	66 89 15 e6 be 16 80 	mov    %dx,0x8016bee6

  initlock(&tickslock, "time");
80104e62:	83 ec 08             	sub    $0x8,%esp
80104e65:	68 bf 6c 10 80       	push   $0x80106cbf
80104e6a:	68 a0 bc 16 80       	push   $0x8016bca0
80104e6f:	e8 27 ec ff ff       	call   80103a9b <initlock>
}
80104e74:	83 c4 10             	add    $0x10,%esp
80104e77:	c9                   	leave  
80104e78:	c3                   	ret    

80104e79 <idtinit>:

void
idtinit(void)
{
80104e79:	55                   	push   %ebp
80104e7a:	89 e5                	mov    %esp,%ebp
80104e7c:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104e7f:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104e85:	b8 e0 bc 16 80       	mov    $0x8016bce0,%eax
80104e8a:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104e8e:	c1 e8 10             	shr    $0x10,%eax
80104e91:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104e95:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104e98:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104e9b:	c9                   	leave  
80104e9c:	c3                   	ret    

80104e9d <trap>:

void
trap(struct trapframe *tf)
{
80104e9d:	55                   	push   %ebp
80104e9e:	89 e5                	mov    %esp,%ebp
80104ea0:	57                   	push   %edi
80104ea1:	56                   	push   %esi
80104ea2:	53                   	push   %ebx
80104ea3:	83 ec 1c             	sub    $0x1c,%esp
80104ea6:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104ea9:	8b 43 30             	mov    0x30(%ebx),%eax
80104eac:	83 f8 40             	cmp    $0x40,%eax
80104eaf:	74 13                	je     80104ec4 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104eb1:	83 e8 20             	sub    $0x20,%eax
80104eb4:	83 f8 1f             	cmp    $0x1f,%eax
80104eb7:	0f 87 3a 01 00 00    	ja     80104ff7 <trap+0x15a>
80104ebd:	ff 24 85 68 6d 10 80 	jmp    *-0x7fef9298(,%eax,4)
    if(myproc()->killed)
80104ec4:	e8 6f e3 ff ff       	call   80103238 <myproc>
80104ec9:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ecd:	75 1f                	jne    80104eee <trap+0x51>
    myproc()->tf = tf;
80104ecf:	e8 64 e3 ff ff       	call   80103238 <myproc>
80104ed4:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80104ed7:	e8 b5 f0 ff ff       	call   80103f91 <syscall>
    if(myproc()->killed)
80104edc:	e8 57 e3 ff ff       	call   80103238 <myproc>
80104ee1:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104ee5:	74 7e                	je     80104f65 <trap+0xc8>
      exit();
80104ee7:	e8 f8 e6 ff ff       	call   801035e4 <exit>
80104eec:	eb 77                	jmp    80104f65 <trap+0xc8>
      exit();
80104eee:	e8 f1 e6 ff ff       	call   801035e4 <exit>
80104ef3:	eb da                	jmp    80104ecf <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80104ef5:	e8 23 e3 ff ff       	call   8010321d <cpuid>
80104efa:	85 c0                	test   %eax,%eax
80104efc:	74 6f                	je     80104f6d <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80104efe:	e8 d8 d4 ff ff       	call   801023db <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f03:	e8 30 e3 ff ff       	call   80103238 <myproc>
80104f08:	85 c0                	test   %eax,%eax
80104f0a:	74 1c                	je     80104f28 <trap+0x8b>
80104f0c:	e8 27 e3 ff ff       	call   80103238 <myproc>
80104f11:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f15:	74 11                	je     80104f28 <trap+0x8b>
80104f17:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f1b:	83 e0 03             	and    $0x3,%eax
80104f1e:	66 83 f8 03          	cmp    $0x3,%ax
80104f22:	0f 84 62 01 00 00    	je     8010508a <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80104f28:	e8 0b e3 ff ff       	call   80103238 <myproc>
80104f2d:	85 c0                	test   %eax,%eax
80104f2f:	74 0f                	je     80104f40 <trap+0xa3>
80104f31:	e8 02 e3 ff ff       	call   80103238 <myproc>
80104f36:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80104f3a:	0f 84 54 01 00 00    	je     80105094 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80104f40:	e8 f3 e2 ff ff       	call   80103238 <myproc>
80104f45:	85 c0                	test   %eax,%eax
80104f47:	74 1c                	je     80104f65 <trap+0xc8>
80104f49:	e8 ea e2 ff ff       	call   80103238 <myproc>
80104f4e:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104f52:	74 11                	je     80104f65 <trap+0xc8>
80104f54:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80104f58:	83 e0 03             	and    $0x3,%eax
80104f5b:	66 83 f8 03          	cmp    $0x3,%ax
80104f5f:	0f 84 43 01 00 00    	je     801050a8 <trap+0x20b>
    exit();
}
80104f65:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104f68:	5b                   	pop    %ebx
80104f69:	5e                   	pop    %esi
80104f6a:	5f                   	pop    %edi
80104f6b:	5d                   	pop    %ebp
80104f6c:	c3                   	ret    
      acquire(&tickslock);
80104f6d:	83 ec 0c             	sub    $0xc,%esp
80104f70:	68 a0 bc 16 80       	push   $0x8016bca0
80104f75:	e8 5d ec ff ff       	call   80103bd7 <acquire>
      ticks++;
80104f7a:	83 05 e0 c4 16 80 01 	addl   $0x1,0x8016c4e0
      wakeup(&ticks);
80104f81:	c7 04 24 e0 c4 16 80 	movl   $0x8016c4e0,(%esp)
80104f88:	e8 b4 e8 ff ff       	call   80103841 <wakeup>
      release(&tickslock);
80104f8d:	c7 04 24 a0 bc 16 80 	movl   $0x8016bca0,(%esp)
80104f94:	e8 a3 ec ff ff       	call   80103c3c <release>
80104f99:	83 c4 10             	add    $0x10,%esp
80104f9c:	e9 5d ff ff ff       	jmp    80104efe <trap+0x61>
    ideintr();
80104fa1:	e8 cd cd ff ff       	call   80101d73 <ideintr>
    lapiceoi();
80104fa6:	e8 30 d4 ff ff       	call   801023db <lapiceoi>
    break;
80104fab:	e9 53 ff ff ff       	jmp    80104f03 <trap+0x66>
    kbdintr();
80104fb0:	e8 6a d2 ff ff       	call   8010221f <kbdintr>
    lapiceoi();
80104fb5:	e8 21 d4 ff ff       	call   801023db <lapiceoi>
    break;
80104fba:	e9 44 ff ff ff       	jmp    80104f03 <trap+0x66>
    uartintr();
80104fbf:	e8 05 02 00 00       	call   801051c9 <uartintr>
    lapiceoi();
80104fc4:	e8 12 d4 ff ff       	call   801023db <lapiceoi>
    break;
80104fc9:	e9 35 ff ff ff       	jmp    80104f03 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fce:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80104fd1:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80104fd5:	e8 43 e2 ff ff       	call   8010321d <cpuid>
80104fda:	57                   	push   %edi
80104fdb:	0f b7 f6             	movzwl %si,%esi
80104fde:	56                   	push   %esi
80104fdf:	50                   	push   %eax
80104fe0:	68 cc 6c 10 80       	push   $0x80106ccc
80104fe5:	e8 21 b6 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80104fea:	e8 ec d3 ff ff       	call   801023db <lapiceoi>
    break;
80104fef:	83 c4 10             	add    $0x10,%esp
80104ff2:	e9 0c ff ff ff       	jmp    80104f03 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80104ff7:	e8 3c e2 ff ff       	call   80103238 <myproc>
80104ffc:	85 c0                	test   %eax,%eax
80104ffe:	74 5f                	je     8010505f <trap+0x1c2>
80105000:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105004:	74 59                	je     8010505f <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105006:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105009:	8b 43 38             	mov    0x38(%ebx),%eax
8010500c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010500f:	e8 09 e2 ff ff       	call   8010321d <cpuid>
80105014:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105017:	8b 53 34             	mov    0x34(%ebx),%edx
8010501a:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010501d:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105020:	e8 13 e2 ff ff       	call   80103238 <myproc>
80105025:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105028:	89 4d d8             	mov    %ecx,-0x28(%ebp)
8010502b:	e8 08 e2 ff ff       	call   80103238 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105030:	57                   	push   %edi
80105031:	ff 75 e4             	pushl  -0x1c(%ebp)
80105034:	ff 75 e0             	pushl  -0x20(%ebp)
80105037:	ff 75 dc             	pushl  -0x24(%ebp)
8010503a:	56                   	push   %esi
8010503b:	ff 75 d8             	pushl  -0x28(%ebp)
8010503e:	ff 70 10             	pushl  0x10(%eax)
80105041:	68 24 6d 10 80       	push   $0x80106d24
80105046:	e8 c0 b5 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
8010504b:	83 c4 20             	add    $0x20,%esp
8010504e:	e8 e5 e1 ff ff       	call   80103238 <myproc>
80105053:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
8010505a:	e9 a4 fe ff ff       	jmp    80104f03 <trap+0x66>
8010505f:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105062:	8b 73 38             	mov    0x38(%ebx),%esi
80105065:	e8 b3 e1 ff ff       	call   8010321d <cpuid>
8010506a:	83 ec 0c             	sub    $0xc,%esp
8010506d:	57                   	push   %edi
8010506e:	56                   	push   %esi
8010506f:	50                   	push   %eax
80105070:	ff 73 30             	pushl  0x30(%ebx)
80105073:	68 f0 6c 10 80       	push   $0x80106cf0
80105078:	e8 8e b5 ff ff       	call   8010060b <cprintf>
      panic("trap");
8010507d:	83 c4 14             	add    $0x14,%esp
80105080:	68 c4 6c 10 80       	push   $0x80106cc4
80105085:	e8 be b2 ff ff       	call   80100348 <panic>
    exit();
8010508a:	e8 55 e5 ff ff       	call   801035e4 <exit>
8010508f:	e9 94 fe ff ff       	jmp    80104f28 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105094:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105098:	0f 85 a2 fe ff ff    	jne    80104f40 <trap+0xa3>
    yield();
8010509e:	e8 07 e6 ff ff       	call   801036aa <yield>
801050a3:	e9 98 fe ff ff       	jmp    80104f40 <trap+0xa3>
    exit();
801050a8:	e8 37 e5 ff ff       	call   801035e4 <exit>
801050ad:	e9 b3 fe ff ff       	jmp    80104f65 <trap+0xc8>

801050b2 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801050b2:	55                   	push   %ebp
801050b3:	89 e5                	mov    %esp,%ebp
  if(!uart)
801050b5:	83 3d c0 95 10 80 00 	cmpl   $0x0,0x801095c0
801050bc:	74 15                	je     801050d3 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801050be:	ba fd 03 00 00       	mov    $0x3fd,%edx
801050c3:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801050c4:	a8 01                	test   $0x1,%al
801050c6:	74 12                	je     801050da <uartgetc+0x28>
801050c8:	ba f8 03 00 00       	mov    $0x3f8,%edx
801050cd:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
801050ce:	0f b6 c0             	movzbl %al,%eax
}
801050d1:	5d                   	pop    %ebp
801050d2:	c3                   	ret    
    return -1;
801050d3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050d8:	eb f7                	jmp    801050d1 <uartgetc+0x1f>
    return -1;
801050da:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801050df:	eb f0                	jmp    801050d1 <uartgetc+0x1f>

801050e1 <uartputc>:
  if(!uart)
801050e1:	83 3d c0 95 10 80 00 	cmpl   $0x0,0x801095c0
801050e8:	74 3b                	je     80105125 <uartputc+0x44>
{
801050ea:	55                   	push   %ebp
801050eb:	89 e5                	mov    %esp,%ebp
801050ed:	53                   	push   %ebx
801050ee:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
801050f1:	bb 00 00 00 00       	mov    $0x0,%ebx
801050f6:	eb 10                	jmp    80105108 <uartputc+0x27>
    microdelay(10);
801050f8:	83 ec 0c             	sub    $0xc,%esp
801050fb:	6a 0a                	push   $0xa
801050fd:	e8 f8 d2 ff ff       	call   801023fa <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105102:	83 c3 01             	add    $0x1,%ebx
80105105:	83 c4 10             	add    $0x10,%esp
80105108:	83 fb 7f             	cmp    $0x7f,%ebx
8010510b:	7f 0a                	jg     80105117 <uartputc+0x36>
8010510d:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105112:	ec                   	in     (%dx),%al
80105113:	a8 20                	test   $0x20,%al
80105115:	74 e1                	je     801050f8 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105117:	8b 45 08             	mov    0x8(%ebp),%eax
8010511a:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010511f:	ee                   	out    %al,(%dx)
}
80105120:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105123:	c9                   	leave  
80105124:	c3                   	ret    
80105125:	f3 c3                	repz ret 

80105127 <uartinit>:
{
80105127:	55                   	push   %ebp
80105128:	89 e5                	mov    %esp,%ebp
8010512a:	56                   	push   %esi
8010512b:	53                   	push   %ebx
8010512c:	b9 00 00 00 00       	mov    $0x0,%ecx
80105131:	ba fa 03 00 00       	mov    $0x3fa,%edx
80105136:	89 c8                	mov    %ecx,%eax
80105138:	ee                   	out    %al,(%dx)
80105139:	be fb 03 00 00       	mov    $0x3fb,%esi
8010513e:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105143:	89 f2                	mov    %esi,%edx
80105145:	ee                   	out    %al,(%dx)
80105146:	b8 0c 00 00 00       	mov    $0xc,%eax
8010514b:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105150:	ee                   	out    %al,(%dx)
80105151:	bb f9 03 00 00       	mov    $0x3f9,%ebx
80105156:	89 c8                	mov    %ecx,%eax
80105158:	89 da                	mov    %ebx,%edx
8010515a:	ee                   	out    %al,(%dx)
8010515b:	b8 03 00 00 00       	mov    $0x3,%eax
80105160:	89 f2                	mov    %esi,%edx
80105162:	ee                   	out    %al,(%dx)
80105163:	ba fc 03 00 00       	mov    $0x3fc,%edx
80105168:	89 c8                	mov    %ecx,%eax
8010516a:	ee                   	out    %al,(%dx)
8010516b:	b8 01 00 00 00       	mov    $0x1,%eax
80105170:	89 da                	mov    %ebx,%edx
80105172:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80105173:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105178:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
80105179:	3c ff                	cmp    $0xff,%al
8010517b:	74 45                	je     801051c2 <uartinit+0x9b>
  uart = 1;
8010517d:	c7 05 c0 95 10 80 01 	movl   $0x1,0x801095c0
80105184:	00 00 00 
80105187:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010518c:	ec                   	in     (%dx),%al
8010518d:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105192:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105193:	83 ec 08             	sub    $0x8,%esp
80105196:	6a 00                	push   $0x0
80105198:	6a 04                	push   $0x4
8010519a:	e8 df cd ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
8010519f:	83 c4 10             	add    $0x10,%esp
801051a2:	bb e8 6d 10 80       	mov    $0x80106de8,%ebx
801051a7:	eb 12                	jmp    801051bb <uartinit+0x94>
    uartputc(*p);
801051a9:	83 ec 0c             	sub    $0xc,%esp
801051ac:	0f be c0             	movsbl %al,%eax
801051af:	50                   	push   %eax
801051b0:	e8 2c ff ff ff       	call   801050e1 <uartputc>
  for(p="xv6...\n"; *p; p++)
801051b5:	83 c3 01             	add    $0x1,%ebx
801051b8:	83 c4 10             	add    $0x10,%esp
801051bb:	0f b6 03             	movzbl (%ebx),%eax
801051be:	84 c0                	test   %al,%al
801051c0:	75 e7                	jne    801051a9 <uartinit+0x82>
}
801051c2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801051c5:	5b                   	pop    %ebx
801051c6:	5e                   	pop    %esi
801051c7:	5d                   	pop    %ebp
801051c8:	c3                   	ret    

801051c9 <uartintr>:

void
uartintr(void)
{
801051c9:	55                   	push   %ebp
801051ca:	89 e5                	mov    %esp,%ebp
801051cc:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
801051cf:	68 b2 50 10 80       	push   $0x801050b2
801051d4:	e8 65 b5 ff ff       	call   8010073e <consoleintr>
}
801051d9:	83 c4 10             	add    $0x10,%esp
801051dc:	c9                   	leave  
801051dd:	c3                   	ret    

801051de <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
801051de:	6a 00                	push   $0x0
  pushl $0
801051e0:	6a 00                	push   $0x0
  jmp alltraps
801051e2:	e9 be fb ff ff       	jmp    80104da5 <alltraps>

801051e7 <vector1>:
.globl vector1
vector1:
  pushl $0
801051e7:	6a 00                	push   $0x0
  pushl $1
801051e9:	6a 01                	push   $0x1
  jmp alltraps
801051eb:	e9 b5 fb ff ff       	jmp    80104da5 <alltraps>

801051f0 <vector2>:
.globl vector2
vector2:
  pushl $0
801051f0:	6a 00                	push   $0x0
  pushl $2
801051f2:	6a 02                	push   $0x2
  jmp alltraps
801051f4:	e9 ac fb ff ff       	jmp    80104da5 <alltraps>

801051f9 <vector3>:
.globl vector3
vector3:
  pushl $0
801051f9:	6a 00                	push   $0x0
  pushl $3
801051fb:	6a 03                	push   $0x3
  jmp alltraps
801051fd:	e9 a3 fb ff ff       	jmp    80104da5 <alltraps>

80105202 <vector4>:
.globl vector4
vector4:
  pushl $0
80105202:	6a 00                	push   $0x0
  pushl $4
80105204:	6a 04                	push   $0x4
  jmp alltraps
80105206:	e9 9a fb ff ff       	jmp    80104da5 <alltraps>

8010520b <vector5>:
.globl vector5
vector5:
  pushl $0
8010520b:	6a 00                	push   $0x0
  pushl $5
8010520d:	6a 05                	push   $0x5
  jmp alltraps
8010520f:	e9 91 fb ff ff       	jmp    80104da5 <alltraps>

80105214 <vector6>:
.globl vector6
vector6:
  pushl $0
80105214:	6a 00                	push   $0x0
  pushl $6
80105216:	6a 06                	push   $0x6
  jmp alltraps
80105218:	e9 88 fb ff ff       	jmp    80104da5 <alltraps>

8010521d <vector7>:
.globl vector7
vector7:
  pushl $0
8010521d:	6a 00                	push   $0x0
  pushl $7
8010521f:	6a 07                	push   $0x7
  jmp alltraps
80105221:	e9 7f fb ff ff       	jmp    80104da5 <alltraps>

80105226 <vector8>:
.globl vector8
vector8:
  pushl $8
80105226:	6a 08                	push   $0x8
  jmp alltraps
80105228:	e9 78 fb ff ff       	jmp    80104da5 <alltraps>

8010522d <vector9>:
.globl vector9
vector9:
  pushl $0
8010522d:	6a 00                	push   $0x0
  pushl $9
8010522f:	6a 09                	push   $0x9
  jmp alltraps
80105231:	e9 6f fb ff ff       	jmp    80104da5 <alltraps>

80105236 <vector10>:
.globl vector10
vector10:
  pushl $10
80105236:	6a 0a                	push   $0xa
  jmp alltraps
80105238:	e9 68 fb ff ff       	jmp    80104da5 <alltraps>

8010523d <vector11>:
.globl vector11
vector11:
  pushl $11
8010523d:	6a 0b                	push   $0xb
  jmp alltraps
8010523f:	e9 61 fb ff ff       	jmp    80104da5 <alltraps>

80105244 <vector12>:
.globl vector12
vector12:
  pushl $12
80105244:	6a 0c                	push   $0xc
  jmp alltraps
80105246:	e9 5a fb ff ff       	jmp    80104da5 <alltraps>

8010524b <vector13>:
.globl vector13
vector13:
  pushl $13
8010524b:	6a 0d                	push   $0xd
  jmp alltraps
8010524d:	e9 53 fb ff ff       	jmp    80104da5 <alltraps>

80105252 <vector14>:
.globl vector14
vector14:
  pushl $14
80105252:	6a 0e                	push   $0xe
  jmp alltraps
80105254:	e9 4c fb ff ff       	jmp    80104da5 <alltraps>

80105259 <vector15>:
.globl vector15
vector15:
  pushl $0
80105259:	6a 00                	push   $0x0
  pushl $15
8010525b:	6a 0f                	push   $0xf
  jmp alltraps
8010525d:	e9 43 fb ff ff       	jmp    80104da5 <alltraps>

80105262 <vector16>:
.globl vector16
vector16:
  pushl $0
80105262:	6a 00                	push   $0x0
  pushl $16
80105264:	6a 10                	push   $0x10
  jmp alltraps
80105266:	e9 3a fb ff ff       	jmp    80104da5 <alltraps>

8010526b <vector17>:
.globl vector17
vector17:
  pushl $17
8010526b:	6a 11                	push   $0x11
  jmp alltraps
8010526d:	e9 33 fb ff ff       	jmp    80104da5 <alltraps>

80105272 <vector18>:
.globl vector18
vector18:
  pushl $0
80105272:	6a 00                	push   $0x0
  pushl $18
80105274:	6a 12                	push   $0x12
  jmp alltraps
80105276:	e9 2a fb ff ff       	jmp    80104da5 <alltraps>

8010527b <vector19>:
.globl vector19
vector19:
  pushl $0
8010527b:	6a 00                	push   $0x0
  pushl $19
8010527d:	6a 13                	push   $0x13
  jmp alltraps
8010527f:	e9 21 fb ff ff       	jmp    80104da5 <alltraps>

80105284 <vector20>:
.globl vector20
vector20:
  pushl $0
80105284:	6a 00                	push   $0x0
  pushl $20
80105286:	6a 14                	push   $0x14
  jmp alltraps
80105288:	e9 18 fb ff ff       	jmp    80104da5 <alltraps>

8010528d <vector21>:
.globl vector21
vector21:
  pushl $0
8010528d:	6a 00                	push   $0x0
  pushl $21
8010528f:	6a 15                	push   $0x15
  jmp alltraps
80105291:	e9 0f fb ff ff       	jmp    80104da5 <alltraps>

80105296 <vector22>:
.globl vector22
vector22:
  pushl $0
80105296:	6a 00                	push   $0x0
  pushl $22
80105298:	6a 16                	push   $0x16
  jmp alltraps
8010529a:	e9 06 fb ff ff       	jmp    80104da5 <alltraps>

8010529f <vector23>:
.globl vector23
vector23:
  pushl $0
8010529f:	6a 00                	push   $0x0
  pushl $23
801052a1:	6a 17                	push   $0x17
  jmp alltraps
801052a3:	e9 fd fa ff ff       	jmp    80104da5 <alltraps>

801052a8 <vector24>:
.globl vector24
vector24:
  pushl $0
801052a8:	6a 00                	push   $0x0
  pushl $24
801052aa:	6a 18                	push   $0x18
  jmp alltraps
801052ac:	e9 f4 fa ff ff       	jmp    80104da5 <alltraps>

801052b1 <vector25>:
.globl vector25
vector25:
  pushl $0
801052b1:	6a 00                	push   $0x0
  pushl $25
801052b3:	6a 19                	push   $0x19
  jmp alltraps
801052b5:	e9 eb fa ff ff       	jmp    80104da5 <alltraps>

801052ba <vector26>:
.globl vector26
vector26:
  pushl $0
801052ba:	6a 00                	push   $0x0
  pushl $26
801052bc:	6a 1a                	push   $0x1a
  jmp alltraps
801052be:	e9 e2 fa ff ff       	jmp    80104da5 <alltraps>

801052c3 <vector27>:
.globl vector27
vector27:
  pushl $0
801052c3:	6a 00                	push   $0x0
  pushl $27
801052c5:	6a 1b                	push   $0x1b
  jmp alltraps
801052c7:	e9 d9 fa ff ff       	jmp    80104da5 <alltraps>

801052cc <vector28>:
.globl vector28
vector28:
  pushl $0
801052cc:	6a 00                	push   $0x0
  pushl $28
801052ce:	6a 1c                	push   $0x1c
  jmp alltraps
801052d0:	e9 d0 fa ff ff       	jmp    80104da5 <alltraps>

801052d5 <vector29>:
.globl vector29
vector29:
  pushl $0
801052d5:	6a 00                	push   $0x0
  pushl $29
801052d7:	6a 1d                	push   $0x1d
  jmp alltraps
801052d9:	e9 c7 fa ff ff       	jmp    80104da5 <alltraps>

801052de <vector30>:
.globl vector30
vector30:
  pushl $0
801052de:	6a 00                	push   $0x0
  pushl $30
801052e0:	6a 1e                	push   $0x1e
  jmp alltraps
801052e2:	e9 be fa ff ff       	jmp    80104da5 <alltraps>

801052e7 <vector31>:
.globl vector31
vector31:
  pushl $0
801052e7:	6a 00                	push   $0x0
  pushl $31
801052e9:	6a 1f                	push   $0x1f
  jmp alltraps
801052eb:	e9 b5 fa ff ff       	jmp    80104da5 <alltraps>

801052f0 <vector32>:
.globl vector32
vector32:
  pushl $0
801052f0:	6a 00                	push   $0x0
  pushl $32
801052f2:	6a 20                	push   $0x20
  jmp alltraps
801052f4:	e9 ac fa ff ff       	jmp    80104da5 <alltraps>

801052f9 <vector33>:
.globl vector33
vector33:
  pushl $0
801052f9:	6a 00                	push   $0x0
  pushl $33
801052fb:	6a 21                	push   $0x21
  jmp alltraps
801052fd:	e9 a3 fa ff ff       	jmp    80104da5 <alltraps>

80105302 <vector34>:
.globl vector34
vector34:
  pushl $0
80105302:	6a 00                	push   $0x0
  pushl $34
80105304:	6a 22                	push   $0x22
  jmp alltraps
80105306:	e9 9a fa ff ff       	jmp    80104da5 <alltraps>

8010530b <vector35>:
.globl vector35
vector35:
  pushl $0
8010530b:	6a 00                	push   $0x0
  pushl $35
8010530d:	6a 23                	push   $0x23
  jmp alltraps
8010530f:	e9 91 fa ff ff       	jmp    80104da5 <alltraps>

80105314 <vector36>:
.globl vector36
vector36:
  pushl $0
80105314:	6a 00                	push   $0x0
  pushl $36
80105316:	6a 24                	push   $0x24
  jmp alltraps
80105318:	e9 88 fa ff ff       	jmp    80104da5 <alltraps>

8010531d <vector37>:
.globl vector37
vector37:
  pushl $0
8010531d:	6a 00                	push   $0x0
  pushl $37
8010531f:	6a 25                	push   $0x25
  jmp alltraps
80105321:	e9 7f fa ff ff       	jmp    80104da5 <alltraps>

80105326 <vector38>:
.globl vector38
vector38:
  pushl $0
80105326:	6a 00                	push   $0x0
  pushl $38
80105328:	6a 26                	push   $0x26
  jmp alltraps
8010532a:	e9 76 fa ff ff       	jmp    80104da5 <alltraps>

8010532f <vector39>:
.globl vector39
vector39:
  pushl $0
8010532f:	6a 00                	push   $0x0
  pushl $39
80105331:	6a 27                	push   $0x27
  jmp alltraps
80105333:	e9 6d fa ff ff       	jmp    80104da5 <alltraps>

80105338 <vector40>:
.globl vector40
vector40:
  pushl $0
80105338:	6a 00                	push   $0x0
  pushl $40
8010533a:	6a 28                	push   $0x28
  jmp alltraps
8010533c:	e9 64 fa ff ff       	jmp    80104da5 <alltraps>

80105341 <vector41>:
.globl vector41
vector41:
  pushl $0
80105341:	6a 00                	push   $0x0
  pushl $41
80105343:	6a 29                	push   $0x29
  jmp alltraps
80105345:	e9 5b fa ff ff       	jmp    80104da5 <alltraps>

8010534a <vector42>:
.globl vector42
vector42:
  pushl $0
8010534a:	6a 00                	push   $0x0
  pushl $42
8010534c:	6a 2a                	push   $0x2a
  jmp alltraps
8010534e:	e9 52 fa ff ff       	jmp    80104da5 <alltraps>

80105353 <vector43>:
.globl vector43
vector43:
  pushl $0
80105353:	6a 00                	push   $0x0
  pushl $43
80105355:	6a 2b                	push   $0x2b
  jmp alltraps
80105357:	e9 49 fa ff ff       	jmp    80104da5 <alltraps>

8010535c <vector44>:
.globl vector44
vector44:
  pushl $0
8010535c:	6a 00                	push   $0x0
  pushl $44
8010535e:	6a 2c                	push   $0x2c
  jmp alltraps
80105360:	e9 40 fa ff ff       	jmp    80104da5 <alltraps>

80105365 <vector45>:
.globl vector45
vector45:
  pushl $0
80105365:	6a 00                	push   $0x0
  pushl $45
80105367:	6a 2d                	push   $0x2d
  jmp alltraps
80105369:	e9 37 fa ff ff       	jmp    80104da5 <alltraps>

8010536e <vector46>:
.globl vector46
vector46:
  pushl $0
8010536e:	6a 00                	push   $0x0
  pushl $46
80105370:	6a 2e                	push   $0x2e
  jmp alltraps
80105372:	e9 2e fa ff ff       	jmp    80104da5 <alltraps>

80105377 <vector47>:
.globl vector47
vector47:
  pushl $0
80105377:	6a 00                	push   $0x0
  pushl $47
80105379:	6a 2f                	push   $0x2f
  jmp alltraps
8010537b:	e9 25 fa ff ff       	jmp    80104da5 <alltraps>

80105380 <vector48>:
.globl vector48
vector48:
  pushl $0
80105380:	6a 00                	push   $0x0
  pushl $48
80105382:	6a 30                	push   $0x30
  jmp alltraps
80105384:	e9 1c fa ff ff       	jmp    80104da5 <alltraps>

80105389 <vector49>:
.globl vector49
vector49:
  pushl $0
80105389:	6a 00                	push   $0x0
  pushl $49
8010538b:	6a 31                	push   $0x31
  jmp alltraps
8010538d:	e9 13 fa ff ff       	jmp    80104da5 <alltraps>

80105392 <vector50>:
.globl vector50
vector50:
  pushl $0
80105392:	6a 00                	push   $0x0
  pushl $50
80105394:	6a 32                	push   $0x32
  jmp alltraps
80105396:	e9 0a fa ff ff       	jmp    80104da5 <alltraps>

8010539b <vector51>:
.globl vector51
vector51:
  pushl $0
8010539b:	6a 00                	push   $0x0
  pushl $51
8010539d:	6a 33                	push   $0x33
  jmp alltraps
8010539f:	e9 01 fa ff ff       	jmp    80104da5 <alltraps>

801053a4 <vector52>:
.globl vector52
vector52:
  pushl $0
801053a4:	6a 00                	push   $0x0
  pushl $52
801053a6:	6a 34                	push   $0x34
  jmp alltraps
801053a8:	e9 f8 f9 ff ff       	jmp    80104da5 <alltraps>

801053ad <vector53>:
.globl vector53
vector53:
  pushl $0
801053ad:	6a 00                	push   $0x0
  pushl $53
801053af:	6a 35                	push   $0x35
  jmp alltraps
801053b1:	e9 ef f9 ff ff       	jmp    80104da5 <alltraps>

801053b6 <vector54>:
.globl vector54
vector54:
  pushl $0
801053b6:	6a 00                	push   $0x0
  pushl $54
801053b8:	6a 36                	push   $0x36
  jmp alltraps
801053ba:	e9 e6 f9 ff ff       	jmp    80104da5 <alltraps>

801053bf <vector55>:
.globl vector55
vector55:
  pushl $0
801053bf:	6a 00                	push   $0x0
  pushl $55
801053c1:	6a 37                	push   $0x37
  jmp alltraps
801053c3:	e9 dd f9 ff ff       	jmp    80104da5 <alltraps>

801053c8 <vector56>:
.globl vector56
vector56:
  pushl $0
801053c8:	6a 00                	push   $0x0
  pushl $56
801053ca:	6a 38                	push   $0x38
  jmp alltraps
801053cc:	e9 d4 f9 ff ff       	jmp    80104da5 <alltraps>

801053d1 <vector57>:
.globl vector57
vector57:
  pushl $0
801053d1:	6a 00                	push   $0x0
  pushl $57
801053d3:	6a 39                	push   $0x39
  jmp alltraps
801053d5:	e9 cb f9 ff ff       	jmp    80104da5 <alltraps>

801053da <vector58>:
.globl vector58
vector58:
  pushl $0
801053da:	6a 00                	push   $0x0
  pushl $58
801053dc:	6a 3a                	push   $0x3a
  jmp alltraps
801053de:	e9 c2 f9 ff ff       	jmp    80104da5 <alltraps>

801053e3 <vector59>:
.globl vector59
vector59:
  pushl $0
801053e3:	6a 00                	push   $0x0
  pushl $59
801053e5:	6a 3b                	push   $0x3b
  jmp alltraps
801053e7:	e9 b9 f9 ff ff       	jmp    80104da5 <alltraps>

801053ec <vector60>:
.globl vector60
vector60:
  pushl $0
801053ec:	6a 00                	push   $0x0
  pushl $60
801053ee:	6a 3c                	push   $0x3c
  jmp alltraps
801053f0:	e9 b0 f9 ff ff       	jmp    80104da5 <alltraps>

801053f5 <vector61>:
.globl vector61
vector61:
  pushl $0
801053f5:	6a 00                	push   $0x0
  pushl $61
801053f7:	6a 3d                	push   $0x3d
  jmp alltraps
801053f9:	e9 a7 f9 ff ff       	jmp    80104da5 <alltraps>

801053fe <vector62>:
.globl vector62
vector62:
  pushl $0
801053fe:	6a 00                	push   $0x0
  pushl $62
80105400:	6a 3e                	push   $0x3e
  jmp alltraps
80105402:	e9 9e f9 ff ff       	jmp    80104da5 <alltraps>

80105407 <vector63>:
.globl vector63
vector63:
  pushl $0
80105407:	6a 00                	push   $0x0
  pushl $63
80105409:	6a 3f                	push   $0x3f
  jmp alltraps
8010540b:	e9 95 f9 ff ff       	jmp    80104da5 <alltraps>

80105410 <vector64>:
.globl vector64
vector64:
  pushl $0
80105410:	6a 00                	push   $0x0
  pushl $64
80105412:	6a 40                	push   $0x40
  jmp alltraps
80105414:	e9 8c f9 ff ff       	jmp    80104da5 <alltraps>

80105419 <vector65>:
.globl vector65
vector65:
  pushl $0
80105419:	6a 00                	push   $0x0
  pushl $65
8010541b:	6a 41                	push   $0x41
  jmp alltraps
8010541d:	e9 83 f9 ff ff       	jmp    80104da5 <alltraps>

80105422 <vector66>:
.globl vector66
vector66:
  pushl $0
80105422:	6a 00                	push   $0x0
  pushl $66
80105424:	6a 42                	push   $0x42
  jmp alltraps
80105426:	e9 7a f9 ff ff       	jmp    80104da5 <alltraps>

8010542b <vector67>:
.globl vector67
vector67:
  pushl $0
8010542b:	6a 00                	push   $0x0
  pushl $67
8010542d:	6a 43                	push   $0x43
  jmp alltraps
8010542f:	e9 71 f9 ff ff       	jmp    80104da5 <alltraps>

80105434 <vector68>:
.globl vector68
vector68:
  pushl $0
80105434:	6a 00                	push   $0x0
  pushl $68
80105436:	6a 44                	push   $0x44
  jmp alltraps
80105438:	e9 68 f9 ff ff       	jmp    80104da5 <alltraps>

8010543d <vector69>:
.globl vector69
vector69:
  pushl $0
8010543d:	6a 00                	push   $0x0
  pushl $69
8010543f:	6a 45                	push   $0x45
  jmp alltraps
80105441:	e9 5f f9 ff ff       	jmp    80104da5 <alltraps>

80105446 <vector70>:
.globl vector70
vector70:
  pushl $0
80105446:	6a 00                	push   $0x0
  pushl $70
80105448:	6a 46                	push   $0x46
  jmp alltraps
8010544a:	e9 56 f9 ff ff       	jmp    80104da5 <alltraps>

8010544f <vector71>:
.globl vector71
vector71:
  pushl $0
8010544f:	6a 00                	push   $0x0
  pushl $71
80105451:	6a 47                	push   $0x47
  jmp alltraps
80105453:	e9 4d f9 ff ff       	jmp    80104da5 <alltraps>

80105458 <vector72>:
.globl vector72
vector72:
  pushl $0
80105458:	6a 00                	push   $0x0
  pushl $72
8010545a:	6a 48                	push   $0x48
  jmp alltraps
8010545c:	e9 44 f9 ff ff       	jmp    80104da5 <alltraps>

80105461 <vector73>:
.globl vector73
vector73:
  pushl $0
80105461:	6a 00                	push   $0x0
  pushl $73
80105463:	6a 49                	push   $0x49
  jmp alltraps
80105465:	e9 3b f9 ff ff       	jmp    80104da5 <alltraps>

8010546a <vector74>:
.globl vector74
vector74:
  pushl $0
8010546a:	6a 00                	push   $0x0
  pushl $74
8010546c:	6a 4a                	push   $0x4a
  jmp alltraps
8010546e:	e9 32 f9 ff ff       	jmp    80104da5 <alltraps>

80105473 <vector75>:
.globl vector75
vector75:
  pushl $0
80105473:	6a 00                	push   $0x0
  pushl $75
80105475:	6a 4b                	push   $0x4b
  jmp alltraps
80105477:	e9 29 f9 ff ff       	jmp    80104da5 <alltraps>

8010547c <vector76>:
.globl vector76
vector76:
  pushl $0
8010547c:	6a 00                	push   $0x0
  pushl $76
8010547e:	6a 4c                	push   $0x4c
  jmp alltraps
80105480:	e9 20 f9 ff ff       	jmp    80104da5 <alltraps>

80105485 <vector77>:
.globl vector77
vector77:
  pushl $0
80105485:	6a 00                	push   $0x0
  pushl $77
80105487:	6a 4d                	push   $0x4d
  jmp alltraps
80105489:	e9 17 f9 ff ff       	jmp    80104da5 <alltraps>

8010548e <vector78>:
.globl vector78
vector78:
  pushl $0
8010548e:	6a 00                	push   $0x0
  pushl $78
80105490:	6a 4e                	push   $0x4e
  jmp alltraps
80105492:	e9 0e f9 ff ff       	jmp    80104da5 <alltraps>

80105497 <vector79>:
.globl vector79
vector79:
  pushl $0
80105497:	6a 00                	push   $0x0
  pushl $79
80105499:	6a 4f                	push   $0x4f
  jmp alltraps
8010549b:	e9 05 f9 ff ff       	jmp    80104da5 <alltraps>

801054a0 <vector80>:
.globl vector80
vector80:
  pushl $0
801054a0:	6a 00                	push   $0x0
  pushl $80
801054a2:	6a 50                	push   $0x50
  jmp alltraps
801054a4:	e9 fc f8 ff ff       	jmp    80104da5 <alltraps>

801054a9 <vector81>:
.globl vector81
vector81:
  pushl $0
801054a9:	6a 00                	push   $0x0
  pushl $81
801054ab:	6a 51                	push   $0x51
  jmp alltraps
801054ad:	e9 f3 f8 ff ff       	jmp    80104da5 <alltraps>

801054b2 <vector82>:
.globl vector82
vector82:
  pushl $0
801054b2:	6a 00                	push   $0x0
  pushl $82
801054b4:	6a 52                	push   $0x52
  jmp alltraps
801054b6:	e9 ea f8 ff ff       	jmp    80104da5 <alltraps>

801054bb <vector83>:
.globl vector83
vector83:
  pushl $0
801054bb:	6a 00                	push   $0x0
  pushl $83
801054bd:	6a 53                	push   $0x53
  jmp alltraps
801054bf:	e9 e1 f8 ff ff       	jmp    80104da5 <alltraps>

801054c4 <vector84>:
.globl vector84
vector84:
  pushl $0
801054c4:	6a 00                	push   $0x0
  pushl $84
801054c6:	6a 54                	push   $0x54
  jmp alltraps
801054c8:	e9 d8 f8 ff ff       	jmp    80104da5 <alltraps>

801054cd <vector85>:
.globl vector85
vector85:
  pushl $0
801054cd:	6a 00                	push   $0x0
  pushl $85
801054cf:	6a 55                	push   $0x55
  jmp alltraps
801054d1:	e9 cf f8 ff ff       	jmp    80104da5 <alltraps>

801054d6 <vector86>:
.globl vector86
vector86:
  pushl $0
801054d6:	6a 00                	push   $0x0
  pushl $86
801054d8:	6a 56                	push   $0x56
  jmp alltraps
801054da:	e9 c6 f8 ff ff       	jmp    80104da5 <alltraps>

801054df <vector87>:
.globl vector87
vector87:
  pushl $0
801054df:	6a 00                	push   $0x0
  pushl $87
801054e1:	6a 57                	push   $0x57
  jmp alltraps
801054e3:	e9 bd f8 ff ff       	jmp    80104da5 <alltraps>

801054e8 <vector88>:
.globl vector88
vector88:
  pushl $0
801054e8:	6a 00                	push   $0x0
  pushl $88
801054ea:	6a 58                	push   $0x58
  jmp alltraps
801054ec:	e9 b4 f8 ff ff       	jmp    80104da5 <alltraps>

801054f1 <vector89>:
.globl vector89
vector89:
  pushl $0
801054f1:	6a 00                	push   $0x0
  pushl $89
801054f3:	6a 59                	push   $0x59
  jmp alltraps
801054f5:	e9 ab f8 ff ff       	jmp    80104da5 <alltraps>

801054fa <vector90>:
.globl vector90
vector90:
  pushl $0
801054fa:	6a 00                	push   $0x0
  pushl $90
801054fc:	6a 5a                	push   $0x5a
  jmp alltraps
801054fe:	e9 a2 f8 ff ff       	jmp    80104da5 <alltraps>

80105503 <vector91>:
.globl vector91
vector91:
  pushl $0
80105503:	6a 00                	push   $0x0
  pushl $91
80105505:	6a 5b                	push   $0x5b
  jmp alltraps
80105507:	e9 99 f8 ff ff       	jmp    80104da5 <alltraps>

8010550c <vector92>:
.globl vector92
vector92:
  pushl $0
8010550c:	6a 00                	push   $0x0
  pushl $92
8010550e:	6a 5c                	push   $0x5c
  jmp alltraps
80105510:	e9 90 f8 ff ff       	jmp    80104da5 <alltraps>

80105515 <vector93>:
.globl vector93
vector93:
  pushl $0
80105515:	6a 00                	push   $0x0
  pushl $93
80105517:	6a 5d                	push   $0x5d
  jmp alltraps
80105519:	e9 87 f8 ff ff       	jmp    80104da5 <alltraps>

8010551e <vector94>:
.globl vector94
vector94:
  pushl $0
8010551e:	6a 00                	push   $0x0
  pushl $94
80105520:	6a 5e                	push   $0x5e
  jmp alltraps
80105522:	e9 7e f8 ff ff       	jmp    80104da5 <alltraps>

80105527 <vector95>:
.globl vector95
vector95:
  pushl $0
80105527:	6a 00                	push   $0x0
  pushl $95
80105529:	6a 5f                	push   $0x5f
  jmp alltraps
8010552b:	e9 75 f8 ff ff       	jmp    80104da5 <alltraps>

80105530 <vector96>:
.globl vector96
vector96:
  pushl $0
80105530:	6a 00                	push   $0x0
  pushl $96
80105532:	6a 60                	push   $0x60
  jmp alltraps
80105534:	e9 6c f8 ff ff       	jmp    80104da5 <alltraps>

80105539 <vector97>:
.globl vector97
vector97:
  pushl $0
80105539:	6a 00                	push   $0x0
  pushl $97
8010553b:	6a 61                	push   $0x61
  jmp alltraps
8010553d:	e9 63 f8 ff ff       	jmp    80104da5 <alltraps>

80105542 <vector98>:
.globl vector98
vector98:
  pushl $0
80105542:	6a 00                	push   $0x0
  pushl $98
80105544:	6a 62                	push   $0x62
  jmp alltraps
80105546:	e9 5a f8 ff ff       	jmp    80104da5 <alltraps>

8010554b <vector99>:
.globl vector99
vector99:
  pushl $0
8010554b:	6a 00                	push   $0x0
  pushl $99
8010554d:	6a 63                	push   $0x63
  jmp alltraps
8010554f:	e9 51 f8 ff ff       	jmp    80104da5 <alltraps>

80105554 <vector100>:
.globl vector100
vector100:
  pushl $0
80105554:	6a 00                	push   $0x0
  pushl $100
80105556:	6a 64                	push   $0x64
  jmp alltraps
80105558:	e9 48 f8 ff ff       	jmp    80104da5 <alltraps>

8010555d <vector101>:
.globl vector101
vector101:
  pushl $0
8010555d:	6a 00                	push   $0x0
  pushl $101
8010555f:	6a 65                	push   $0x65
  jmp alltraps
80105561:	e9 3f f8 ff ff       	jmp    80104da5 <alltraps>

80105566 <vector102>:
.globl vector102
vector102:
  pushl $0
80105566:	6a 00                	push   $0x0
  pushl $102
80105568:	6a 66                	push   $0x66
  jmp alltraps
8010556a:	e9 36 f8 ff ff       	jmp    80104da5 <alltraps>

8010556f <vector103>:
.globl vector103
vector103:
  pushl $0
8010556f:	6a 00                	push   $0x0
  pushl $103
80105571:	6a 67                	push   $0x67
  jmp alltraps
80105573:	e9 2d f8 ff ff       	jmp    80104da5 <alltraps>

80105578 <vector104>:
.globl vector104
vector104:
  pushl $0
80105578:	6a 00                	push   $0x0
  pushl $104
8010557a:	6a 68                	push   $0x68
  jmp alltraps
8010557c:	e9 24 f8 ff ff       	jmp    80104da5 <alltraps>

80105581 <vector105>:
.globl vector105
vector105:
  pushl $0
80105581:	6a 00                	push   $0x0
  pushl $105
80105583:	6a 69                	push   $0x69
  jmp alltraps
80105585:	e9 1b f8 ff ff       	jmp    80104da5 <alltraps>

8010558a <vector106>:
.globl vector106
vector106:
  pushl $0
8010558a:	6a 00                	push   $0x0
  pushl $106
8010558c:	6a 6a                	push   $0x6a
  jmp alltraps
8010558e:	e9 12 f8 ff ff       	jmp    80104da5 <alltraps>

80105593 <vector107>:
.globl vector107
vector107:
  pushl $0
80105593:	6a 00                	push   $0x0
  pushl $107
80105595:	6a 6b                	push   $0x6b
  jmp alltraps
80105597:	e9 09 f8 ff ff       	jmp    80104da5 <alltraps>

8010559c <vector108>:
.globl vector108
vector108:
  pushl $0
8010559c:	6a 00                	push   $0x0
  pushl $108
8010559e:	6a 6c                	push   $0x6c
  jmp alltraps
801055a0:	e9 00 f8 ff ff       	jmp    80104da5 <alltraps>

801055a5 <vector109>:
.globl vector109
vector109:
  pushl $0
801055a5:	6a 00                	push   $0x0
  pushl $109
801055a7:	6a 6d                	push   $0x6d
  jmp alltraps
801055a9:	e9 f7 f7 ff ff       	jmp    80104da5 <alltraps>

801055ae <vector110>:
.globl vector110
vector110:
  pushl $0
801055ae:	6a 00                	push   $0x0
  pushl $110
801055b0:	6a 6e                	push   $0x6e
  jmp alltraps
801055b2:	e9 ee f7 ff ff       	jmp    80104da5 <alltraps>

801055b7 <vector111>:
.globl vector111
vector111:
  pushl $0
801055b7:	6a 00                	push   $0x0
  pushl $111
801055b9:	6a 6f                	push   $0x6f
  jmp alltraps
801055bb:	e9 e5 f7 ff ff       	jmp    80104da5 <alltraps>

801055c0 <vector112>:
.globl vector112
vector112:
  pushl $0
801055c0:	6a 00                	push   $0x0
  pushl $112
801055c2:	6a 70                	push   $0x70
  jmp alltraps
801055c4:	e9 dc f7 ff ff       	jmp    80104da5 <alltraps>

801055c9 <vector113>:
.globl vector113
vector113:
  pushl $0
801055c9:	6a 00                	push   $0x0
  pushl $113
801055cb:	6a 71                	push   $0x71
  jmp alltraps
801055cd:	e9 d3 f7 ff ff       	jmp    80104da5 <alltraps>

801055d2 <vector114>:
.globl vector114
vector114:
  pushl $0
801055d2:	6a 00                	push   $0x0
  pushl $114
801055d4:	6a 72                	push   $0x72
  jmp alltraps
801055d6:	e9 ca f7 ff ff       	jmp    80104da5 <alltraps>

801055db <vector115>:
.globl vector115
vector115:
  pushl $0
801055db:	6a 00                	push   $0x0
  pushl $115
801055dd:	6a 73                	push   $0x73
  jmp alltraps
801055df:	e9 c1 f7 ff ff       	jmp    80104da5 <alltraps>

801055e4 <vector116>:
.globl vector116
vector116:
  pushl $0
801055e4:	6a 00                	push   $0x0
  pushl $116
801055e6:	6a 74                	push   $0x74
  jmp alltraps
801055e8:	e9 b8 f7 ff ff       	jmp    80104da5 <alltraps>

801055ed <vector117>:
.globl vector117
vector117:
  pushl $0
801055ed:	6a 00                	push   $0x0
  pushl $117
801055ef:	6a 75                	push   $0x75
  jmp alltraps
801055f1:	e9 af f7 ff ff       	jmp    80104da5 <alltraps>

801055f6 <vector118>:
.globl vector118
vector118:
  pushl $0
801055f6:	6a 00                	push   $0x0
  pushl $118
801055f8:	6a 76                	push   $0x76
  jmp alltraps
801055fa:	e9 a6 f7 ff ff       	jmp    80104da5 <alltraps>

801055ff <vector119>:
.globl vector119
vector119:
  pushl $0
801055ff:	6a 00                	push   $0x0
  pushl $119
80105601:	6a 77                	push   $0x77
  jmp alltraps
80105603:	e9 9d f7 ff ff       	jmp    80104da5 <alltraps>

80105608 <vector120>:
.globl vector120
vector120:
  pushl $0
80105608:	6a 00                	push   $0x0
  pushl $120
8010560a:	6a 78                	push   $0x78
  jmp alltraps
8010560c:	e9 94 f7 ff ff       	jmp    80104da5 <alltraps>

80105611 <vector121>:
.globl vector121
vector121:
  pushl $0
80105611:	6a 00                	push   $0x0
  pushl $121
80105613:	6a 79                	push   $0x79
  jmp alltraps
80105615:	e9 8b f7 ff ff       	jmp    80104da5 <alltraps>

8010561a <vector122>:
.globl vector122
vector122:
  pushl $0
8010561a:	6a 00                	push   $0x0
  pushl $122
8010561c:	6a 7a                	push   $0x7a
  jmp alltraps
8010561e:	e9 82 f7 ff ff       	jmp    80104da5 <alltraps>

80105623 <vector123>:
.globl vector123
vector123:
  pushl $0
80105623:	6a 00                	push   $0x0
  pushl $123
80105625:	6a 7b                	push   $0x7b
  jmp alltraps
80105627:	e9 79 f7 ff ff       	jmp    80104da5 <alltraps>

8010562c <vector124>:
.globl vector124
vector124:
  pushl $0
8010562c:	6a 00                	push   $0x0
  pushl $124
8010562e:	6a 7c                	push   $0x7c
  jmp alltraps
80105630:	e9 70 f7 ff ff       	jmp    80104da5 <alltraps>

80105635 <vector125>:
.globl vector125
vector125:
  pushl $0
80105635:	6a 00                	push   $0x0
  pushl $125
80105637:	6a 7d                	push   $0x7d
  jmp alltraps
80105639:	e9 67 f7 ff ff       	jmp    80104da5 <alltraps>

8010563e <vector126>:
.globl vector126
vector126:
  pushl $0
8010563e:	6a 00                	push   $0x0
  pushl $126
80105640:	6a 7e                	push   $0x7e
  jmp alltraps
80105642:	e9 5e f7 ff ff       	jmp    80104da5 <alltraps>

80105647 <vector127>:
.globl vector127
vector127:
  pushl $0
80105647:	6a 00                	push   $0x0
  pushl $127
80105649:	6a 7f                	push   $0x7f
  jmp alltraps
8010564b:	e9 55 f7 ff ff       	jmp    80104da5 <alltraps>

80105650 <vector128>:
.globl vector128
vector128:
  pushl $0
80105650:	6a 00                	push   $0x0
  pushl $128
80105652:	68 80 00 00 00       	push   $0x80
  jmp alltraps
80105657:	e9 49 f7 ff ff       	jmp    80104da5 <alltraps>

8010565c <vector129>:
.globl vector129
vector129:
  pushl $0
8010565c:	6a 00                	push   $0x0
  pushl $129
8010565e:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105663:	e9 3d f7 ff ff       	jmp    80104da5 <alltraps>

80105668 <vector130>:
.globl vector130
vector130:
  pushl $0
80105668:	6a 00                	push   $0x0
  pushl $130
8010566a:	68 82 00 00 00       	push   $0x82
  jmp alltraps
8010566f:	e9 31 f7 ff ff       	jmp    80104da5 <alltraps>

80105674 <vector131>:
.globl vector131
vector131:
  pushl $0
80105674:	6a 00                	push   $0x0
  pushl $131
80105676:	68 83 00 00 00       	push   $0x83
  jmp alltraps
8010567b:	e9 25 f7 ff ff       	jmp    80104da5 <alltraps>

80105680 <vector132>:
.globl vector132
vector132:
  pushl $0
80105680:	6a 00                	push   $0x0
  pushl $132
80105682:	68 84 00 00 00       	push   $0x84
  jmp alltraps
80105687:	e9 19 f7 ff ff       	jmp    80104da5 <alltraps>

8010568c <vector133>:
.globl vector133
vector133:
  pushl $0
8010568c:	6a 00                	push   $0x0
  pushl $133
8010568e:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105693:	e9 0d f7 ff ff       	jmp    80104da5 <alltraps>

80105698 <vector134>:
.globl vector134
vector134:
  pushl $0
80105698:	6a 00                	push   $0x0
  pushl $134
8010569a:	68 86 00 00 00       	push   $0x86
  jmp alltraps
8010569f:	e9 01 f7 ff ff       	jmp    80104da5 <alltraps>

801056a4 <vector135>:
.globl vector135
vector135:
  pushl $0
801056a4:	6a 00                	push   $0x0
  pushl $135
801056a6:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801056ab:	e9 f5 f6 ff ff       	jmp    80104da5 <alltraps>

801056b0 <vector136>:
.globl vector136
vector136:
  pushl $0
801056b0:	6a 00                	push   $0x0
  pushl $136
801056b2:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801056b7:	e9 e9 f6 ff ff       	jmp    80104da5 <alltraps>

801056bc <vector137>:
.globl vector137
vector137:
  pushl $0
801056bc:	6a 00                	push   $0x0
  pushl $137
801056be:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801056c3:	e9 dd f6 ff ff       	jmp    80104da5 <alltraps>

801056c8 <vector138>:
.globl vector138
vector138:
  pushl $0
801056c8:	6a 00                	push   $0x0
  pushl $138
801056ca:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
801056cf:	e9 d1 f6 ff ff       	jmp    80104da5 <alltraps>

801056d4 <vector139>:
.globl vector139
vector139:
  pushl $0
801056d4:	6a 00                	push   $0x0
  pushl $139
801056d6:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
801056db:	e9 c5 f6 ff ff       	jmp    80104da5 <alltraps>

801056e0 <vector140>:
.globl vector140
vector140:
  pushl $0
801056e0:	6a 00                	push   $0x0
  pushl $140
801056e2:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
801056e7:	e9 b9 f6 ff ff       	jmp    80104da5 <alltraps>

801056ec <vector141>:
.globl vector141
vector141:
  pushl $0
801056ec:	6a 00                	push   $0x0
  pushl $141
801056ee:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
801056f3:	e9 ad f6 ff ff       	jmp    80104da5 <alltraps>

801056f8 <vector142>:
.globl vector142
vector142:
  pushl $0
801056f8:	6a 00                	push   $0x0
  pushl $142
801056fa:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
801056ff:	e9 a1 f6 ff ff       	jmp    80104da5 <alltraps>

80105704 <vector143>:
.globl vector143
vector143:
  pushl $0
80105704:	6a 00                	push   $0x0
  pushl $143
80105706:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010570b:	e9 95 f6 ff ff       	jmp    80104da5 <alltraps>

80105710 <vector144>:
.globl vector144
vector144:
  pushl $0
80105710:	6a 00                	push   $0x0
  pushl $144
80105712:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105717:	e9 89 f6 ff ff       	jmp    80104da5 <alltraps>

8010571c <vector145>:
.globl vector145
vector145:
  pushl $0
8010571c:	6a 00                	push   $0x0
  pushl $145
8010571e:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105723:	e9 7d f6 ff ff       	jmp    80104da5 <alltraps>

80105728 <vector146>:
.globl vector146
vector146:
  pushl $0
80105728:	6a 00                	push   $0x0
  pushl $146
8010572a:	68 92 00 00 00       	push   $0x92
  jmp alltraps
8010572f:	e9 71 f6 ff ff       	jmp    80104da5 <alltraps>

80105734 <vector147>:
.globl vector147
vector147:
  pushl $0
80105734:	6a 00                	push   $0x0
  pushl $147
80105736:	68 93 00 00 00       	push   $0x93
  jmp alltraps
8010573b:	e9 65 f6 ff ff       	jmp    80104da5 <alltraps>

80105740 <vector148>:
.globl vector148
vector148:
  pushl $0
80105740:	6a 00                	push   $0x0
  pushl $148
80105742:	68 94 00 00 00       	push   $0x94
  jmp alltraps
80105747:	e9 59 f6 ff ff       	jmp    80104da5 <alltraps>

8010574c <vector149>:
.globl vector149
vector149:
  pushl $0
8010574c:	6a 00                	push   $0x0
  pushl $149
8010574e:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105753:	e9 4d f6 ff ff       	jmp    80104da5 <alltraps>

80105758 <vector150>:
.globl vector150
vector150:
  pushl $0
80105758:	6a 00                	push   $0x0
  pushl $150
8010575a:	68 96 00 00 00       	push   $0x96
  jmp alltraps
8010575f:	e9 41 f6 ff ff       	jmp    80104da5 <alltraps>

80105764 <vector151>:
.globl vector151
vector151:
  pushl $0
80105764:	6a 00                	push   $0x0
  pushl $151
80105766:	68 97 00 00 00       	push   $0x97
  jmp alltraps
8010576b:	e9 35 f6 ff ff       	jmp    80104da5 <alltraps>

80105770 <vector152>:
.globl vector152
vector152:
  pushl $0
80105770:	6a 00                	push   $0x0
  pushl $152
80105772:	68 98 00 00 00       	push   $0x98
  jmp alltraps
80105777:	e9 29 f6 ff ff       	jmp    80104da5 <alltraps>

8010577c <vector153>:
.globl vector153
vector153:
  pushl $0
8010577c:	6a 00                	push   $0x0
  pushl $153
8010577e:	68 99 00 00 00       	push   $0x99
  jmp alltraps
80105783:	e9 1d f6 ff ff       	jmp    80104da5 <alltraps>

80105788 <vector154>:
.globl vector154
vector154:
  pushl $0
80105788:	6a 00                	push   $0x0
  pushl $154
8010578a:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
8010578f:	e9 11 f6 ff ff       	jmp    80104da5 <alltraps>

80105794 <vector155>:
.globl vector155
vector155:
  pushl $0
80105794:	6a 00                	push   $0x0
  pushl $155
80105796:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010579b:	e9 05 f6 ff ff       	jmp    80104da5 <alltraps>

801057a0 <vector156>:
.globl vector156
vector156:
  pushl $0
801057a0:	6a 00                	push   $0x0
  pushl $156
801057a2:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801057a7:	e9 f9 f5 ff ff       	jmp    80104da5 <alltraps>

801057ac <vector157>:
.globl vector157
vector157:
  pushl $0
801057ac:	6a 00                	push   $0x0
  pushl $157
801057ae:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801057b3:	e9 ed f5 ff ff       	jmp    80104da5 <alltraps>

801057b8 <vector158>:
.globl vector158
vector158:
  pushl $0
801057b8:	6a 00                	push   $0x0
  pushl $158
801057ba:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801057bf:	e9 e1 f5 ff ff       	jmp    80104da5 <alltraps>

801057c4 <vector159>:
.globl vector159
vector159:
  pushl $0
801057c4:	6a 00                	push   $0x0
  pushl $159
801057c6:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
801057cb:	e9 d5 f5 ff ff       	jmp    80104da5 <alltraps>

801057d0 <vector160>:
.globl vector160
vector160:
  pushl $0
801057d0:	6a 00                	push   $0x0
  pushl $160
801057d2:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
801057d7:	e9 c9 f5 ff ff       	jmp    80104da5 <alltraps>

801057dc <vector161>:
.globl vector161
vector161:
  pushl $0
801057dc:	6a 00                	push   $0x0
  pushl $161
801057de:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
801057e3:	e9 bd f5 ff ff       	jmp    80104da5 <alltraps>

801057e8 <vector162>:
.globl vector162
vector162:
  pushl $0
801057e8:	6a 00                	push   $0x0
  pushl $162
801057ea:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
801057ef:	e9 b1 f5 ff ff       	jmp    80104da5 <alltraps>

801057f4 <vector163>:
.globl vector163
vector163:
  pushl $0
801057f4:	6a 00                	push   $0x0
  pushl $163
801057f6:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
801057fb:	e9 a5 f5 ff ff       	jmp    80104da5 <alltraps>

80105800 <vector164>:
.globl vector164
vector164:
  pushl $0
80105800:	6a 00                	push   $0x0
  pushl $164
80105802:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105807:	e9 99 f5 ff ff       	jmp    80104da5 <alltraps>

8010580c <vector165>:
.globl vector165
vector165:
  pushl $0
8010580c:	6a 00                	push   $0x0
  pushl $165
8010580e:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105813:	e9 8d f5 ff ff       	jmp    80104da5 <alltraps>

80105818 <vector166>:
.globl vector166
vector166:
  pushl $0
80105818:	6a 00                	push   $0x0
  pushl $166
8010581a:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
8010581f:	e9 81 f5 ff ff       	jmp    80104da5 <alltraps>

80105824 <vector167>:
.globl vector167
vector167:
  pushl $0
80105824:	6a 00                	push   $0x0
  pushl $167
80105826:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010582b:	e9 75 f5 ff ff       	jmp    80104da5 <alltraps>

80105830 <vector168>:
.globl vector168
vector168:
  pushl $0
80105830:	6a 00                	push   $0x0
  pushl $168
80105832:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
80105837:	e9 69 f5 ff ff       	jmp    80104da5 <alltraps>

8010583c <vector169>:
.globl vector169
vector169:
  pushl $0
8010583c:	6a 00                	push   $0x0
  pushl $169
8010583e:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105843:	e9 5d f5 ff ff       	jmp    80104da5 <alltraps>

80105848 <vector170>:
.globl vector170
vector170:
  pushl $0
80105848:	6a 00                	push   $0x0
  pushl $170
8010584a:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
8010584f:	e9 51 f5 ff ff       	jmp    80104da5 <alltraps>

80105854 <vector171>:
.globl vector171
vector171:
  pushl $0
80105854:	6a 00                	push   $0x0
  pushl $171
80105856:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
8010585b:	e9 45 f5 ff ff       	jmp    80104da5 <alltraps>

80105860 <vector172>:
.globl vector172
vector172:
  pushl $0
80105860:	6a 00                	push   $0x0
  pushl $172
80105862:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
80105867:	e9 39 f5 ff ff       	jmp    80104da5 <alltraps>

8010586c <vector173>:
.globl vector173
vector173:
  pushl $0
8010586c:	6a 00                	push   $0x0
  pushl $173
8010586e:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
80105873:	e9 2d f5 ff ff       	jmp    80104da5 <alltraps>

80105878 <vector174>:
.globl vector174
vector174:
  pushl $0
80105878:	6a 00                	push   $0x0
  pushl $174
8010587a:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
8010587f:	e9 21 f5 ff ff       	jmp    80104da5 <alltraps>

80105884 <vector175>:
.globl vector175
vector175:
  pushl $0
80105884:	6a 00                	push   $0x0
  pushl $175
80105886:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
8010588b:	e9 15 f5 ff ff       	jmp    80104da5 <alltraps>

80105890 <vector176>:
.globl vector176
vector176:
  pushl $0
80105890:	6a 00                	push   $0x0
  pushl $176
80105892:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105897:	e9 09 f5 ff ff       	jmp    80104da5 <alltraps>

8010589c <vector177>:
.globl vector177
vector177:
  pushl $0
8010589c:	6a 00                	push   $0x0
  pushl $177
8010589e:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801058a3:	e9 fd f4 ff ff       	jmp    80104da5 <alltraps>

801058a8 <vector178>:
.globl vector178
vector178:
  pushl $0
801058a8:	6a 00                	push   $0x0
  pushl $178
801058aa:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801058af:	e9 f1 f4 ff ff       	jmp    80104da5 <alltraps>

801058b4 <vector179>:
.globl vector179
vector179:
  pushl $0
801058b4:	6a 00                	push   $0x0
  pushl $179
801058b6:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801058bb:	e9 e5 f4 ff ff       	jmp    80104da5 <alltraps>

801058c0 <vector180>:
.globl vector180
vector180:
  pushl $0
801058c0:	6a 00                	push   $0x0
  pushl $180
801058c2:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801058c7:	e9 d9 f4 ff ff       	jmp    80104da5 <alltraps>

801058cc <vector181>:
.globl vector181
vector181:
  pushl $0
801058cc:	6a 00                	push   $0x0
  pushl $181
801058ce:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
801058d3:	e9 cd f4 ff ff       	jmp    80104da5 <alltraps>

801058d8 <vector182>:
.globl vector182
vector182:
  pushl $0
801058d8:	6a 00                	push   $0x0
  pushl $182
801058da:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
801058df:	e9 c1 f4 ff ff       	jmp    80104da5 <alltraps>

801058e4 <vector183>:
.globl vector183
vector183:
  pushl $0
801058e4:	6a 00                	push   $0x0
  pushl $183
801058e6:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
801058eb:	e9 b5 f4 ff ff       	jmp    80104da5 <alltraps>

801058f0 <vector184>:
.globl vector184
vector184:
  pushl $0
801058f0:	6a 00                	push   $0x0
  pushl $184
801058f2:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
801058f7:	e9 a9 f4 ff ff       	jmp    80104da5 <alltraps>

801058fc <vector185>:
.globl vector185
vector185:
  pushl $0
801058fc:	6a 00                	push   $0x0
  pushl $185
801058fe:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105903:	e9 9d f4 ff ff       	jmp    80104da5 <alltraps>

80105908 <vector186>:
.globl vector186
vector186:
  pushl $0
80105908:	6a 00                	push   $0x0
  pushl $186
8010590a:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
8010590f:	e9 91 f4 ff ff       	jmp    80104da5 <alltraps>

80105914 <vector187>:
.globl vector187
vector187:
  pushl $0
80105914:	6a 00                	push   $0x0
  pushl $187
80105916:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
8010591b:	e9 85 f4 ff ff       	jmp    80104da5 <alltraps>

80105920 <vector188>:
.globl vector188
vector188:
  pushl $0
80105920:	6a 00                	push   $0x0
  pushl $188
80105922:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105927:	e9 79 f4 ff ff       	jmp    80104da5 <alltraps>

8010592c <vector189>:
.globl vector189
vector189:
  pushl $0
8010592c:	6a 00                	push   $0x0
  pushl $189
8010592e:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105933:	e9 6d f4 ff ff       	jmp    80104da5 <alltraps>

80105938 <vector190>:
.globl vector190
vector190:
  pushl $0
80105938:	6a 00                	push   $0x0
  pushl $190
8010593a:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
8010593f:	e9 61 f4 ff ff       	jmp    80104da5 <alltraps>

80105944 <vector191>:
.globl vector191
vector191:
  pushl $0
80105944:	6a 00                	push   $0x0
  pushl $191
80105946:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
8010594b:	e9 55 f4 ff ff       	jmp    80104da5 <alltraps>

80105950 <vector192>:
.globl vector192
vector192:
  pushl $0
80105950:	6a 00                	push   $0x0
  pushl $192
80105952:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105957:	e9 49 f4 ff ff       	jmp    80104da5 <alltraps>

8010595c <vector193>:
.globl vector193
vector193:
  pushl $0
8010595c:	6a 00                	push   $0x0
  pushl $193
8010595e:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105963:	e9 3d f4 ff ff       	jmp    80104da5 <alltraps>

80105968 <vector194>:
.globl vector194
vector194:
  pushl $0
80105968:	6a 00                	push   $0x0
  pushl $194
8010596a:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
8010596f:	e9 31 f4 ff ff       	jmp    80104da5 <alltraps>

80105974 <vector195>:
.globl vector195
vector195:
  pushl $0
80105974:	6a 00                	push   $0x0
  pushl $195
80105976:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
8010597b:	e9 25 f4 ff ff       	jmp    80104da5 <alltraps>

80105980 <vector196>:
.globl vector196
vector196:
  pushl $0
80105980:	6a 00                	push   $0x0
  pushl $196
80105982:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105987:	e9 19 f4 ff ff       	jmp    80104da5 <alltraps>

8010598c <vector197>:
.globl vector197
vector197:
  pushl $0
8010598c:	6a 00                	push   $0x0
  pushl $197
8010598e:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105993:	e9 0d f4 ff ff       	jmp    80104da5 <alltraps>

80105998 <vector198>:
.globl vector198
vector198:
  pushl $0
80105998:	6a 00                	push   $0x0
  pushl $198
8010599a:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
8010599f:	e9 01 f4 ff ff       	jmp    80104da5 <alltraps>

801059a4 <vector199>:
.globl vector199
vector199:
  pushl $0
801059a4:	6a 00                	push   $0x0
  pushl $199
801059a6:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
801059ab:	e9 f5 f3 ff ff       	jmp    80104da5 <alltraps>

801059b0 <vector200>:
.globl vector200
vector200:
  pushl $0
801059b0:	6a 00                	push   $0x0
  pushl $200
801059b2:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
801059b7:	e9 e9 f3 ff ff       	jmp    80104da5 <alltraps>

801059bc <vector201>:
.globl vector201
vector201:
  pushl $0
801059bc:	6a 00                	push   $0x0
  pushl $201
801059be:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
801059c3:	e9 dd f3 ff ff       	jmp    80104da5 <alltraps>

801059c8 <vector202>:
.globl vector202
vector202:
  pushl $0
801059c8:	6a 00                	push   $0x0
  pushl $202
801059ca:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
801059cf:	e9 d1 f3 ff ff       	jmp    80104da5 <alltraps>

801059d4 <vector203>:
.globl vector203
vector203:
  pushl $0
801059d4:	6a 00                	push   $0x0
  pushl $203
801059d6:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
801059db:	e9 c5 f3 ff ff       	jmp    80104da5 <alltraps>

801059e0 <vector204>:
.globl vector204
vector204:
  pushl $0
801059e0:	6a 00                	push   $0x0
  pushl $204
801059e2:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
801059e7:	e9 b9 f3 ff ff       	jmp    80104da5 <alltraps>

801059ec <vector205>:
.globl vector205
vector205:
  pushl $0
801059ec:	6a 00                	push   $0x0
  pushl $205
801059ee:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
801059f3:	e9 ad f3 ff ff       	jmp    80104da5 <alltraps>

801059f8 <vector206>:
.globl vector206
vector206:
  pushl $0
801059f8:	6a 00                	push   $0x0
  pushl $206
801059fa:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
801059ff:	e9 a1 f3 ff ff       	jmp    80104da5 <alltraps>

80105a04 <vector207>:
.globl vector207
vector207:
  pushl $0
80105a04:	6a 00                	push   $0x0
  pushl $207
80105a06:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105a0b:	e9 95 f3 ff ff       	jmp    80104da5 <alltraps>

80105a10 <vector208>:
.globl vector208
vector208:
  pushl $0
80105a10:	6a 00                	push   $0x0
  pushl $208
80105a12:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105a17:	e9 89 f3 ff ff       	jmp    80104da5 <alltraps>

80105a1c <vector209>:
.globl vector209
vector209:
  pushl $0
80105a1c:	6a 00                	push   $0x0
  pushl $209
80105a1e:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105a23:	e9 7d f3 ff ff       	jmp    80104da5 <alltraps>

80105a28 <vector210>:
.globl vector210
vector210:
  pushl $0
80105a28:	6a 00                	push   $0x0
  pushl $210
80105a2a:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105a2f:	e9 71 f3 ff ff       	jmp    80104da5 <alltraps>

80105a34 <vector211>:
.globl vector211
vector211:
  pushl $0
80105a34:	6a 00                	push   $0x0
  pushl $211
80105a36:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105a3b:	e9 65 f3 ff ff       	jmp    80104da5 <alltraps>

80105a40 <vector212>:
.globl vector212
vector212:
  pushl $0
80105a40:	6a 00                	push   $0x0
  pushl $212
80105a42:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105a47:	e9 59 f3 ff ff       	jmp    80104da5 <alltraps>

80105a4c <vector213>:
.globl vector213
vector213:
  pushl $0
80105a4c:	6a 00                	push   $0x0
  pushl $213
80105a4e:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105a53:	e9 4d f3 ff ff       	jmp    80104da5 <alltraps>

80105a58 <vector214>:
.globl vector214
vector214:
  pushl $0
80105a58:	6a 00                	push   $0x0
  pushl $214
80105a5a:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105a5f:	e9 41 f3 ff ff       	jmp    80104da5 <alltraps>

80105a64 <vector215>:
.globl vector215
vector215:
  pushl $0
80105a64:	6a 00                	push   $0x0
  pushl $215
80105a66:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105a6b:	e9 35 f3 ff ff       	jmp    80104da5 <alltraps>

80105a70 <vector216>:
.globl vector216
vector216:
  pushl $0
80105a70:	6a 00                	push   $0x0
  pushl $216
80105a72:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105a77:	e9 29 f3 ff ff       	jmp    80104da5 <alltraps>

80105a7c <vector217>:
.globl vector217
vector217:
  pushl $0
80105a7c:	6a 00                	push   $0x0
  pushl $217
80105a7e:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105a83:	e9 1d f3 ff ff       	jmp    80104da5 <alltraps>

80105a88 <vector218>:
.globl vector218
vector218:
  pushl $0
80105a88:	6a 00                	push   $0x0
  pushl $218
80105a8a:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105a8f:	e9 11 f3 ff ff       	jmp    80104da5 <alltraps>

80105a94 <vector219>:
.globl vector219
vector219:
  pushl $0
80105a94:	6a 00                	push   $0x0
  pushl $219
80105a96:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105a9b:	e9 05 f3 ff ff       	jmp    80104da5 <alltraps>

80105aa0 <vector220>:
.globl vector220
vector220:
  pushl $0
80105aa0:	6a 00                	push   $0x0
  pushl $220
80105aa2:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105aa7:	e9 f9 f2 ff ff       	jmp    80104da5 <alltraps>

80105aac <vector221>:
.globl vector221
vector221:
  pushl $0
80105aac:	6a 00                	push   $0x0
  pushl $221
80105aae:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105ab3:	e9 ed f2 ff ff       	jmp    80104da5 <alltraps>

80105ab8 <vector222>:
.globl vector222
vector222:
  pushl $0
80105ab8:	6a 00                	push   $0x0
  pushl $222
80105aba:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105abf:	e9 e1 f2 ff ff       	jmp    80104da5 <alltraps>

80105ac4 <vector223>:
.globl vector223
vector223:
  pushl $0
80105ac4:	6a 00                	push   $0x0
  pushl $223
80105ac6:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105acb:	e9 d5 f2 ff ff       	jmp    80104da5 <alltraps>

80105ad0 <vector224>:
.globl vector224
vector224:
  pushl $0
80105ad0:	6a 00                	push   $0x0
  pushl $224
80105ad2:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105ad7:	e9 c9 f2 ff ff       	jmp    80104da5 <alltraps>

80105adc <vector225>:
.globl vector225
vector225:
  pushl $0
80105adc:	6a 00                	push   $0x0
  pushl $225
80105ade:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105ae3:	e9 bd f2 ff ff       	jmp    80104da5 <alltraps>

80105ae8 <vector226>:
.globl vector226
vector226:
  pushl $0
80105ae8:	6a 00                	push   $0x0
  pushl $226
80105aea:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105aef:	e9 b1 f2 ff ff       	jmp    80104da5 <alltraps>

80105af4 <vector227>:
.globl vector227
vector227:
  pushl $0
80105af4:	6a 00                	push   $0x0
  pushl $227
80105af6:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105afb:	e9 a5 f2 ff ff       	jmp    80104da5 <alltraps>

80105b00 <vector228>:
.globl vector228
vector228:
  pushl $0
80105b00:	6a 00                	push   $0x0
  pushl $228
80105b02:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105b07:	e9 99 f2 ff ff       	jmp    80104da5 <alltraps>

80105b0c <vector229>:
.globl vector229
vector229:
  pushl $0
80105b0c:	6a 00                	push   $0x0
  pushl $229
80105b0e:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105b13:	e9 8d f2 ff ff       	jmp    80104da5 <alltraps>

80105b18 <vector230>:
.globl vector230
vector230:
  pushl $0
80105b18:	6a 00                	push   $0x0
  pushl $230
80105b1a:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105b1f:	e9 81 f2 ff ff       	jmp    80104da5 <alltraps>

80105b24 <vector231>:
.globl vector231
vector231:
  pushl $0
80105b24:	6a 00                	push   $0x0
  pushl $231
80105b26:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105b2b:	e9 75 f2 ff ff       	jmp    80104da5 <alltraps>

80105b30 <vector232>:
.globl vector232
vector232:
  pushl $0
80105b30:	6a 00                	push   $0x0
  pushl $232
80105b32:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105b37:	e9 69 f2 ff ff       	jmp    80104da5 <alltraps>

80105b3c <vector233>:
.globl vector233
vector233:
  pushl $0
80105b3c:	6a 00                	push   $0x0
  pushl $233
80105b3e:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105b43:	e9 5d f2 ff ff       	jmp    80104da5 <alltraps>

80105b48 <vector234>:
.globl vector234
vector234:
  pushl $0
80105b48:	6a 00                	push   $0x0
  pushl $234
80105b4a:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105b4f:	e9 51 f2 ff ff       	jmp    80104da5 <alltraps>

80105b54 <vector235>:
.globl vector235
vector235:
  pushl $0
80105b54:	6a 00                	push   $0x0
  pushl $235
80105b56:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105b5b:	e9 45 f2 ff ff       	jmp    80104da5 <alltraps>

80105b60 <vector236>:
.globl vector236
vector236:
  pushl $0
80105b60:	6a 00                	push   $0x0
  pushl $236
80105b62:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105b67:	e9 39 f2 ff ff       	jmp    80104da5 <alltraps>

80105b6c <vector237>:
.globl vector237
vector237:
  pushl $0
80105b6c:	6a 00                	push   $0x0
  pushl $237
80105b6e:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105b73:	e9 2d f2 ff ff       	jmp    80104da5 <alltraps>

80105b78 <vector238>:
.globl vector238
vector238:
  pushl $0
80105b78:	6a 00                	push   $0x0
  pushl $238
80105b7a:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105b7f:	e9 21 f2 ff ff       	jmp    80104da5 <alltraps>

80105b84 <vector239>:
.globl vector239
vector239:
  pushl $0
80105b84:	6a 00                	push   $0x0
  pushl $239
80105b86:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105b8b:	e9 15 f2 ff ff       	jmp    80104da5 <alltraps>

80105b90 <vector240>:
.globl vector240
vector240:
  pushl $0
80105b90:	6a 00                	push   $0x0
  pushl $240
80105b92:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105b97:	e9 09 f2 ff ff       	jmp    80104da5 <alltraps>

80105b9c <vector241>:
.globl vector241
vector241:
  pushl $0
80105b9c:	6a 00                	push   $0x0
  pushl $241
80105b9e:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105ba3:	e9 fd f1 ff ff       	jmp    80104da5 <alltraps>

80105ba8 <vector242>:
.globl vector242
vector242:
  pushl $0
80105ba8:	6a 00                	push   $0x0
  pushl $242
80105baa:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105baf:	e9 f1 f1 ff ff       	jmp    80104da5 <alltraps>

80105bb4 <vector243>:
.globl vector243
vector243:
  pushl $0
80105bb4:	6a 00                	push   $0x0
  pushl $243
80105bb6:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105bbb:	e9 e5 f1 ff ff       	jmp    80104da5 <alltraps>

80105bc0 <vector244>:
.globl vector244
vector244:
  pushl $0
80105bc0:	6a 00                	push   $0x0
  pushl $244
80105bc2:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105bc7:	e9 d9 f1 ff ff       	jmp    80104da5 <alltraps>

80105bcc <vector245>:
.globl vector245
vector245:
  pushl $0
80105bcc:	6a 00                	push   $0x0
  pushl $245
80105bce:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105bd3:	e9 cd f1 ff ff       	jmp    80104da5 <alltraps>

80105bd8 <vector246>:
.globl vector246
vector246:
  pushl $0
80105bd8:	6a 00                	push   $0x0
  pushl $246
80105bda:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105bdf:	e9 c1 f1 ff ff       	jmp    80104da5 <alltraps>

80105be4 <vector247>:
.globl vector247
vector247:
  pushl $0
80105be4:	6a 00                	push   $0x0
  pushl $247
80105be6:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105beb:	e9 b5 f1 ff ff       	jmp    80104da5 <alltraps>

80105bf0 <vector248>:
.globl vector248
vector248:
  pushl $0
80105bf0:	6a 00                	push   $0x0
  pushl $248
80105bf2:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105bf7:	e9 a9 f1 ff ff       	jmp    80104da5 <alltraps>

80105bfc <vector249>:
.globl vector249
vector249:
  pushl $0
80105bfc:	6a 00                	push   $0x0
  pushl $249
80105bfe:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105c03:	e9 9d f1 ff ff       	jmp    80104da5 <alltraps>

80105c08 <vector250>:
.globl vector250
vector250:
  pushl $0
80105c08:	6a 00                	push   $0x0
  pushl $250
80105c0a:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105c0f:	e9 91 f1 ff ff       	jmp    80104da5 <alltraps>

80105c14 <vector251>:
.globl vector251
vector251:
  pushl $0
80105c14:	6a 00                	push   $0x0
  pushl $251
80105c16:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105c1b:	e9 85 f1 ff ff       	jmp    80104da5 <alltraps>

80105c20 <vector252>:
.globl vector252
vector252:
  pushl $0
80105c20:	6a 00                	push   $0x0
  pushl $252
80105c22:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105c27:	e9 79 f1 ff ff       	jmp    80104da5 <alltraps>

80105c2c <vector253>:
.globl vector253
vector253:
  pushl $0
80105c2c:	6a 00                	push   $0x0
  pushl $253
80105c2e:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105c33:	e9 6d f1 ff ff       	jmp    80104da5 <alltraps>

80105c38 <vector254>:
.globl vector254
vector254:
  pushl $0
80105c38:	6a 00                	push   $0x0
  pushl $254
80105c3a:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105c3f:	e9 61 f1 ff ff       	jmp    80104da5 <alltraps>

80105c44 <vector255>:
.globl vector255
vector255:
  pushl $0
80105c44:	6a 00                	push   $0x0
  pushl $255
80105c46:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105c4b:	e9 55 f1 ff ff       	jmp    80104da5 <alltraps>

80105c50 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105c50:	55                   	push   %ebp
80105c51:	89 e5                	mov    %esp,%ebp
80105c53:	57                   	push   %edi
80105c54:	56                   	push   %esi
80105c55:	53                   	push   %ebx
80105c56:	83 ec 0c             	sub    $0xc,%esp
80105c59:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105c5b:	c1 ea 16             	shr    $0x16,%edx
80105c5e:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105c61:	8b 1f                	mov    (%edi),%ebx
80105c63:	f6 c3 01             	test   $0x1,%bl
80105c66:	74 22                	je     80105c8a <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105c68:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105c6e:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105c74:	c1 ee 0c             	shr    $0xc,%esi
80105c77:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105c7d:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105c80:	89 d8                	mov    %ebx,%eax
80105c82:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105c85:	5b                   	pop    %ebx
80105c86:	5e                   	pop    %esi
80105c87:	5f                   	pop    %edi
80105c88:	5d                   	pop    %ebp
80105c89:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105c8a:	85 c9                	test   %ecx,%ecx
80105c8c:	74 2b                	je     80105cb9 <walkpgdir+0x69>
80105c8e:	e8 28 c4 ff ff       	call   801020bb <kalloc>
80105c93:	89 c3                	mov    %eax,%ebx
80105c95:	85 c0                	test   %eax,%eax
80105c97:	74 e7                	je     80105c80 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105c99:	83 ec 04             	sub    $0x4,%esp
80105c9c:	68 00 10 00 00       	push   $0x1000
80105ca1:	6a 00                	push   $0x0
80105ca3:	50                   	push   %eax
80105ca4:	e8 da df ff ff       	call   80103c83 <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105ca9:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105caf:	83 c8 07             	or     $0x7,%eax
80105cb2:	89 07                	mov    %eax,(%edi)
80105cb4:	83 c4 10             	add    $0x10,%esp
80105cb7:	eb bb                	jmp    80105c74 <walkpgdir+0x24>
      return 0;
80105cb9:	bb 00 00 00 00       	mov    $0x0,%ebx
80105cbe:	eb c0                	jmp    80105c80 <walkpgdir+0x30>

80105cc0 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105cc0:	55                   	push   %ebp
80105cc1:	89 e5                	mov    %esp,%ebp
80105cc3:	57                   	push   %edi
80105cc4:	56                   	push   %esi
80105cc5:	53                   	push   %ebx
80105cc6:	83 ec 1c             	sub    $0x1c,%esp
80105cc9:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105ccc:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105ccf:	89 d3                	mov    %edx,%ebx
80105cd1:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105cd7:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105cdb:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105ce1:	b9 01 00 00 00       	mov    $0x1,%ecx
80105ce6:	89 da                	mov    %ebx,%edx
80105ce8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105ceb:	e8 60 ff ff ff       	call   80105c50 <walkpgdir>
80105cf0:	85 c0                	test   %eax,%eax
80105cf2:	74 2e                	je     80105d22 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105cf4:	f6 00 01             	testb  $0x1,(%eax)
80105cf7:	75 1c                	jne    80105d15 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105cf9:	89 f2                	mov    %esi,%edx
80105cfb:	0b 55 0c             	or     0xc(%ebp),%edx
80105cfe:	83 ca 01             	or     $0x1,%edx
80105d01:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105d03:	39 fb                	cmp    %edi,%ebx
80105d05:	74 28                	je     80105d2f <mappages+0x6f>
      break;
    a += PGSIZE;
80105d07:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105d0d:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105d13:	eb cc                	jmp    80105ce1 <mappages+0x21>
      panic("remap");
80105d15:	83 ec 0c             	sub    $0xc,%esp
80105d18:	68 f0 6d 10 80       	push   $0x80106df0
80105d1d:	e8 26 a6 ff ff       	call   80100348 <panic>
      return -1;
80105d22:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105d27:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105d2a:	5b                   	pop    %ebx
80105d2b:	5e                   	pop    %esi
80105d2c:	5f                   	pop    %edi
80105d2d:	5d                   	pop    %ebp
80105d2e:	c3                   	ret    
  return 0;
80105d2f:	b8 00 00 00 00       	mov    $0x0,%eax
80105d34:	eb f1                	jmp    80105d27 <mappages+0x67>

80105d36 <seginit>:
{
80105d36:	55                   	push   %ebp
80105d37:	89 e5                	mov    %esp,%ebp
80105d39:	53                   	push   %ebx
80105d3a:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105d3d:	e8 db d4 ff ff       	call   8010321d <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105d42:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105d48:	66 c7 80 38 98 16 80 	movw   $0xffff,-0x7fe967c8(%eax)
80105d4f:	ff ff 
80105d51:	66 c7 80 3a 98 16 80 	movw   $0x0,-0x7fe967c6(%eax)
80105d58:	00 00 
80105d5a:	c6 80 3c 98 16 80 00 	movb   $0x0,-0x7fe967c4(%eax)
80105d61:	0f b6 88 3d 98 16 80 	movzbl -0x7fe967c3(%eax),%ecx
80105d68:	83 e1 f0             	and    $0xfffffff0,%ecx
80105d6b:	83 c9 1a             	or     $0x1a,%ecx
80105d6e:	83 e1 9f             	and    $0xffffff9f,%ecx
80105d71:	83 c9 80             	or     $0xffffff80,%ecx
80105d74:	88 88 3d 98 16 80    	mov    %cl,-0x7fe967c3(%eax)
80105d7a:	0f b6 88 3e 98 16 80 	movzbl -0x7fe967c2(%eax),%ecx
80105d81:	83 c9 0f             	or     $0xf,%ecx
80105d84:	83 e1 cf             	and    $0xffffffcf,%ecx
80105d87:	83 c9 c0             	or     $0xffffffc0,%ecx
80105d8a:	88 88 3e 98 16 80    	mov    %cl,-0x7fe967c2(%eax)
80105d90:	c6 80 3f 98 16 80 00 	movb   $0x0,-0x7fe967c1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105d97:	66 c7 80 40 98 16 80 	movw   $0xffff,-0x7fe967c0(%eax)
80105d9e:	ff ff 
80105da0:	66 c7 80 42 98 16 80 	movw   $0x0,-0x7fe967be(%eax)
80105da7:	00 00 
80105da9:	c6 80 44 98 16 80 00 	movb   $0x0,-0x7fe967bc(%eax)
80105db0:	0f b6 88 45 98 16 80 	movzbl -0x7fe967bb(%eax),%ecx
80105db7:	83 e1 f0             	and    $0xfffffff0,%ecx
80105dba:	83 c9 12             	or     $0x12,%ecx
80105dbd:	83 e1 9f             	and    $0xffffff9f,%ecx
80105dc0:	83 c9 80             	or     $0xffffff80,%ecx
80105dc3:	88 88 45 98 16 80    	mov    %cl,-0x7fe967bb(%eax)
80105dc9:	0f b6 88 46 98 16 80 	movzbl -0x7fe967ba(%eax),%ecx
80105dd0:	83 c9 0f             	or     $0xf,%ecx
80105dd3:	83 e1 cf             	and    $0xffffffcf,%ecx
80105dd6:	83 c9 c0             	or     $0xffffffc0,%ecx
80105dd9:	88 88 46 98 16 80    	mov    %cl,-0x7fe967ba(%eax)
80105ddf:	c6 80 47 98 16 80 00 	movb   $0x0,-0x7fe967b9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105de6:	66 c7 80 48 98 16 80 	movw   $0xffff,-0x7fe967b8(%eax)
80105ded:	ff ff 
80105def:	66 c7 80 4a 98 16 80 	movw   $0x0,-0x7fe967b6(%eax)
80105df6:	00 00 
80105df8:	c6 80 4c 98 16 80 00 	movb   $0x0,-0x7fe967b4(%eax)
80105dff:	c6 80 4d 98 16 80 fa 	movb   $0xfa,-0x7fe967b3(%eax)
80105e06:	0f b6 88 4e 98 16 80 	movzbl -0x7fe967b2(%eax),%ecx
80105e0d:	83 c9 0f             	or     $0xf,%ecx
80105e10:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e13:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e16:	88 88 4e 98 16 80    	mov    %cl,-0x7fe967b2(%eax)
80105e1c:	c6 80 4f 98 16 80 00 	movb   $0x0,-0x7fe967b1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105e23:	66 c7 80 50 98 16 80 	movw   $0xffff,-0x7fe967b0(%eax)
80105e2a:	ff ff 
80105e2c:	66 c7 80 52 98 16 80 	movw   $0x0,-0x7fe967ae(%eax)
80105e33:	00 00 
80105e35:	c6 80 54 98 16 80 00 	movb   $0x0,-0x7fe967ac(%eax)
80105e3c:	c6 80 55 98 16 80 f2 	movb   $0xf2,-0x7fe967ab(%eax)
80105e43:	0f b6 88 56 98 16 80 	movzbl -0x7fe967aa(%eax),%ecx
80105e4a:	83 c9 0f             	or     $0xf,%ecx
80105e4d:	83 e1 cf             	and    $0xffffffcf,%ecx
80105e50:	83 c9 c0             	or     $0xffffffc0,%ecx
80105e53:	88 88 56 98 16 80    	mov    %cl,-0x7fe967aa(%eax)
80105e59:	c6 80 57 98 16 80 00 	movb   $0x0,-0x7fe967a9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105e60:	05 30 98 16 80       	add    $0x80169830,%eax
  pd[0] = size-1;
80105e65:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105e6b:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105e6f:	c1 e8 10             	shr    $0x10,%eax
80105e72:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105e76:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105e79:	0f 01 10             	lgdtl  (%eax)
}
80105e7c:	83 c4 14             	add    $0x14,%esp
80105e7f:	5b                   	pop    %ebx
80105e80:	5d                   	pop    %ebp
80105e81:	c3                   	ret    

80105e82 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105e82:	55                   	push   %ebp
80105e83:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105e85:	a1 e4 c4 16 80       	mov    0x8016c4e4,%eax
80105e8a:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105e8f:	0f 22 d8             	mov    %eax,%cr3
}
80105e92:	5d                   	pop    %ebp
80105e93:	c3                   	ret    

80105e94 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105e94:	55                   	push   %ebp
80105e95:	89 e5                	mov    %esp,%ebp
80105e97:	57                   	push   %edi
80105e98:	56                   	push   %esi
80105e99:	53                   	push   %ebx
80105e9a:	83 ec 1c             	sub    $0x1c,%esp
80105e9d:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105ea0:	85 f6                	test   %esi,%esi
80105ea2:	0f 84 dd 00 00 00    	je     80105f85 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105ea8:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105eac:	0f 84 e0 00 00 00    	je     80105f92 <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105eb2:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105eb6:	0f 84 e3 00 00 00    	je     80105f9f <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80105ebc:	e8 39 dc ff ff       	call   80103afa <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105ec1:	e8 fb d2 ff ff       	call   801031c1 <mycpu>
80105ec6:	89 c3                	mov    %eax,%ebx
80105ec8:	e8 f4 d2 ff ff       	call   801031c1 <mycpu>
80105ecd:	8d 78 08             	lea    0x8(%eax),%edi
80105ed0:	e8 ec d2 ff ff       	call   801031c1 <mycpu>
80105ed5:	83 c0 08             	add    $0x8,%eax
80105ed8:	c1 e8 10             	shr    $0x10,%eax
80105edb:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105ede:	e8 de d2 ff ff       	call   801031c1 <mycpu>
80105ee3:	83 c0 08             	add    $0x8,%eax
80105ee6:	c1 e8 18             	shr    $0x18,%eax
80105ee9:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80105ef0:	67 00 
80105ef2:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80105ef9:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
80105efd:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80105f03:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80105f0a:	83 e2 f0             	and    $0xfffffff0,%edx
80105f0d:	83 ca 19             	or     $0x19,%edx
80105f10:	83 e2 9f             	and    $0xffffff9f,%edx
80105f13:	83 ca 80             	or     $0xffffff80,%edx
80105f16:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
80105f1c:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80105f23:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80105f29:	e8 93 d2 ff ff       	call   801031c1 <mycpu>
80105f2e:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80105f35:	83 e2 ef             	and    $0xffffffef,%edx
80105f38:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
80105f3e:	e8 7e d2 ff ff       	call   801031c1 <mycpu>
80105f43:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80105f49:	8b 5e 08             	mov    0x8(%esi),%ebx
80105f4c:	e8 70 d2 ff ff       	call   801031c1 <mycpu>
80105f51:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80105f57:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80105f5a:	e8 62 d2 ff ff       	call   801031c1 <mycpu>
80105f5f:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
80105f65:	b8 28 00 00 00       	mov    $0x28,%eax
80105f6a:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
80105f6d:	8b 46 04             	mov    0x4(%esi),%eax
80105f70:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105f75:	0f 22 d8             	mov    %eax,%cr3
  popcli();
80105f78:	e8 ba db ff ff       	call   80103b37 <popcli>
}
80105f7d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105f80:	5b                   	pop    %ebx
80105f81:	5e                   	pop    %esi
80105f82:	5f                   	pop    %edi
80105f83:	5d                   	pop    %ebp
80105f84:	c3                   	ret    
    panic("switchuvm: no process");
80105f85:	83 ec 0c             	sub    $0xc,%esp
80105f88:	68 f6 6d 10 80       	push   $0x80106df6
80105f8d:	e8 b6 a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80105f92:	83 ec 0c             	sub    $0xc,%esp
80105f95:	68 0c 6e 10 80       	push   $0x80106e0c
80105f9a:	e8 a9 a3 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80105f9f:	83 ec 0c             	sub    $0xc,%esp
80105fa2:	68 21 6e 10 80       	push   $0x80106e21
80105fa7:	e8 9c a3 ff ff       	call   80100348 <panic>

80105fac <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
80105fac:	55                   	push   %ebp
80105fad:	89 e5                	mov    %esp,%ebp
80105faf:	56                   	push   %esi
80105fb0:	53                   	push   %ebx
80105fb1:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80105fb4:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80105fba:	77 4c                	ja     80106008 <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
80105fbc:	e8 fa c0 ff ff       	call   801020bb <kalloc>
80105fc1:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80105fc3:	83 ec 04             	sub    $0x4,%esp
80105fc6:	68 00 10 00 00       	push   $0x1000
80105fcb:	6a 00                	push   $0x0
80105fcd:	50                   	push   %eax
80105fce:	e8 b0 dc ff ff       	call   80103c83 <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80105fd3:	83 c4 08             	add    $0x8,%esp
80105fd6:	6a 06                	push   $0x6
80105fd8:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105fde:	50                   	push   %eax
80105fdf:	b9 00 10 00 00       	mov    $0x1000,%ecx
80105fe4:	ba 00 00 00 00       	mov    $0x0,%edx
80105fe9:	8b 45 08             	mov    0x8(%ebp),%eax
80105fec:	e8 cf fc ff ff       	call   80105cc0 <mappages>
  memmove(mem, init, sz);
80105ff1:	83 c4 0c             	add    $0xc,%esp
80105ff4:	56                   	push   %esi
80105ff5:	ff 75 0c             	pushl  0xc(%ebp)
80105ff8:	53                   	push   %ebx
80105ff9:	e8 00 dd ff ff       	call   80103cfe <memmove>
}
80105ffe:	83 c4 10             	add    $0x10,%esp
80106001:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106004:	5b                   	pop    %ebx
80106005:	5e                   	pop    %esi
80106006:	5d                   	pop    %ebp
80106007:	c3                   	ret    
    panic("inituvm: more than a page");
80106008:	83 ec 0c             	sub    $0xc,%esp
8010600b:	68 35 6e 10 80       	push   $0x80106e35
80106010:	e8 33 a3 ff ff       	call   80100348 <panic>

80106015 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106015:	55                   	push   %ebp
80106016:	89 e5                	mov    %esp,%ebp
80106018:	57                   	push   %edi
80106019:	56                   	push   %esi
8010601a:	53                   	push   %ebx
8010601b:	83 ec 0c             	sub    $0xc,%esp
8010601e:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106021:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106028:	75 07                	jne    80106031 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010602a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010602f:	eb 3c                	jmp    8010606d <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106031:	83 ec 0c             	sub    $0xc,%esp
80106034:	68 f0 6e 10 80       	push   $0x80106ef0
80106039:	e8 0a a3 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
8010603e:	83 ec 0c             	sub    $0xc,%esp
80106041:	68 4f 6e 10 80       	push   $0x80106e4f
80106046:	e8 fd a2 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010604b:	05 00 00 00 80       	add    $0x80000000,%eax
80106050:	56                   	push   %esi
80106051:	89 da                	mov    %ebx,%edx
80106053:	03 55 14             	add    0x14(%ebp),%edx
80106056:	52                   	push   %edx
80106057:	50                   	push   %eax
80106058:	ff 75 10             	pushl  0x10(%ebp)
8010605b:	e8 13 b7 ff ff       	call   80101773 <readi>
80106060:	83 c4 10             	add    $0x10,%esp
80106063:	39 f0                	cmp    %esi,%eax
80106065:	75 47                	jne    801060ae <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
80106067:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010606d:	39 fb                	cmp    %edi,%ebx
8010606f:	73 30                	jae    801060a1 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
80106071:	89 da                	mov    %ebx,%edx
80106073:	03 55 0c             	add    0xc(%ebp),%edx
80106076:	b9 00 00 00 00       	mov    $0x0,%ecx
8010607b:	8b 45 08             	mov    0x8(%ebp),%eax
8010607e:	e8 cd fb ff ff       	call   80105c50 <walkpgdir>
80106083:	85 c0                	test   %eax,%eax
80106085:	74 b7                	je     8010603e <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
80106087:	8b 00                	mov    (%eax),%eax
80106089:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
8010608e:	89 fe                	mov    %edi,%esi
80106090:	29 de                	sub    %ebx,%esi
80106092:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106098:	76 b1                	jbe    8010604b <loaduvm+0x36>
      n = PGSIZE;
8010609a:	be 00 10 00 00       	mov    $0x1000,%esi
8010609f:	eb aa                	jmp    8010604b <loaduvm+0x36>
      return -1;
  }
  return 0;
801060a1:	b8 00 00 00 00       	mov    $0x0,%eax
}
801060a6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060a9:	5b                   	pop    %ebx
801060aa:	5e                   	pop    %esi
801060ab:	5f                   	pop    %edi
801060ac:	5d                   	pop    %ebp
801060ad:	c3                   	ret    
      return -1;
801060ae:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801060b3:	eb f1                	jmp    801060a6 <loaduvm+0x91>

801060b5 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801060b5:	55                   	push   %ebp
801060b6:	89 e5                	mov    %esp,%ebp
801060b8:	57                   	push   %edi
801060b9:	56                   	push   %esi
801060ba:	53                   	push   %ebx
801060bb:	83 ec 0c             	sub    $0xc,%esp
801060be:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
801060c1:	39 7d 10             	cmp    %edi,0x10(%ebp)
801060c4:	73 11                	jae    801060d7 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
801060c6:	8b 45 10             	mov    0x10(%ebp),%eax
801060c9:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801060cf:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801060d5:	eb 19                	jmp    801060f0 <deallocuvm+0x3b>
    return oldsz;
801060d7:	89 f8                	mov    %edi,%eax
801060d9:	eb 64                	jmp    8010613f <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
801060db:	c1 eb 16             	shr    $0x16,%ebx
801060de:	83 c3 01             	add    $0x1,%ebx
801060e1:	c1 e3 16             	shl    $0x16,%ebx
801060e4:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
801060ea:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060f0:	39 fb                	cmp    %edi,%ebx
801060f2:	73 48                	jae    8010613c <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
801060f4:	b9 00 00 00 00       	mov    $0x0,%ecx
801060f9:	89 da                	mov    %ebx,%edx
801060fb:	8b 45 08             	mov    0x8(%ebp),%eax
801060fe:	e8 4d fb ff ff       	call   80105c50 <walkpgdir>
80106103:	89 c6                	mov    %eax,%esi
    if(!pte)
80106105:	85 c0                	test   %eax,%eax
80106107:	74 d2                	je     801060db <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
80106109:	8b 00                	mov    (%eax),%eax
8010610b:	a8 01                	test   $0x1,%al
8010610d:	74 db                	je     801060ea <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
8010610f:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106114:	74 19                	je     8010612f <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
80106116:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010611b:	83 ec 0c             	sub    $0xc,%esp
8010611e:	50                   	push   %eax
8010611f:	e8 80 be ff ff       	call   80101fa4 <kfree>
      *pte = 0;
80106124:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010612a:	83 c4 10             	add    $0x10,%esp
8010612d:	eb bb                	jmp    801060ea <deallocuvm+0x35>
        panic("kfree");
8010612f:	83 ec 0c             	sub    $0xc,%esp
80106132:	68 66 67 10 80       	push   $0x80106766
80106137:	e8 0c a2 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
8010613c:	8b 45 10             	mov    0x10(%ebp),%eax
}
8010613f:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106142:	5b                   	pop    %ebx
80106143:	5e                   	pop    %esi
80106144:	5f                   	pop    %edi
80106145:	5d                   	pop    %ebp
80106146:	c3                   	ret    

80106147 <allocuvm>:
{
80106147:	55                   	push   %ebp
80106148:	89 e5                	mov    %esp,%ebp
8010614a:	57                   	push   %edi
8010614b:	56                   	push   %esi
8010614c:	53                   	push   %ebx
8010614d:	83 ec 1c             	sub    $0x1c,%esp
80106150:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106153:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106156:	85 ff                	test   %edi,%edi
80106158:	0f 88 c1 00 00 00    	js     8010621f <allocuvm+0xd8>
  if(newsz < oldsz)
8010615e:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106161:	72 5c                	jb     801061bf <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
80106163:	8b 45 0c             	mov    0xc(%ebp),%eax
80106166:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
8010616c:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
80106172:	39 fb                	cmp    %edi,%ebx
80106174:	0f 83 ac 00 00 00    	jae    80106226 <allocuvm+0xdf>
    mem = kalloc();
8010617a:	e8 3c bf ff ff       	call   801020bb <kalloc>
8010617f:	89 c6                	mov    %eax,%esi
    if(mem == 0){
80106181:	85 c0                	test   %eax,%eax
80106183:	74 42                	je     801061c7 <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
80106185:	83 ec 04             	sub    $0x4,%esp
80106188:	68 00 10 00 00       	push   $0x1000
8010618d:	6a 00                	push   $0x0
8010618f:	50                   	push   %eax
80106190:	e8 ee da ff ff       	call   80103c83 <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106195:	83 c4 08             	add    $0x8,%esp
80106198:	6a 06                	push   $0x6
8010619a:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801061a0:	50                   	push   %eax
801061a1:	b9 00 10 00 00       	mov    $0x1000,%ecx
801061a6:	89 da                	mov    %ebx,%edx
801061a8:	8b 45 08             	mov    0x8(%ebp),%eax
801061ab:	e8 10 fb ff ff       	call   80105cc0 <mappages>
801061b0:	83 c4 10             	add    $0x10,%esp
801061b3:	85 c0                	test   %eax,%eax
801061b5:	78 38                	js     801061ef <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
801061b7:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061bd:	eb b3                	jmp    80106172 <allocuvm+0x2b>
    return oldsz;
801061bf:	8b 45 0c             	mov    0xc(%ebp),%eax
801061c2:	89 45 e4             	mov    %eax,-0x1c(%ebp)
801061c5:	eb 5f                	jmp    80106226 <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
801061c7:	83 ec 0c             	sub    $0xc,%esp
801061ca:	68 6d 6e 10 80       	push   $0x80106e6d
801061cf:	e8 37 a4 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801061d4:	83 c4 0c             	add    $0xc,%esp
801061d7:	ff 75 0c             	pushl  0xc(%ebp)
801061da:	57                   	push   %edi
801061db:	ff 75 08             	pushl  0x8(%ebp)
801061de:	e8 d2 fe ff ff       	call   801060b5 <deallocuvm>
      return 0;
801061e3:	83 c4 10             	add    $0x10,%esp
801061e6:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
801061ed:	eb 37                	jmp    80106226 <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
801061ef:	83 ec 0c             	sub    $0xc,%esp
801061f2:	68 85 6e 10 80       	push   $0x80106e85
801061f7:	e8 0f a4 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
801061fc:	83 c4 0c             	add    $0xc,%esp
801061ff:	ff 75 0c             	pushl  0xc(%ebp)
80106202:	57                   	push   %edi
80106203:	ff 75 08             	pushl  0x8(%ebp)
80106206:	e8 aa fe ff ff       	call   801060b5 <deallocuvm>
      kfree(mem);
8010620b:	89 34 24             	mov    %esi,(%esp)
8010620e:	e8 91 bd ff ff       	call   80101fa4 <kfree>
      return 0;
80106213:	83 c4 10             	add    $0x10,%esp
80106216:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010621d:	eb 07                	jmp    80106226 <allocuvm+0xdf>
    return 0;
8010621f:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106226:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80106229:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010622c:	5b                   	pop    %ebx
8010622d:	5e                   	pop    %esi
8010622e:	5f                   	pop    %edi
8010622f:	5d                   	pop    %ebp
80106230:	c3                   	ret    

80106231 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106231:	55                   	push   %ebp
80106232:	89 e5                	mov    %esp,%ebp
80106234:	56                   	push   %esi
80106235:	53                   	push   %ebx
80106236:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
80106239:	85 f6                	test   %esi,%esi
8010623b:	74 1a                	je     80106257 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010623d:	83 ec 04             	sub    $0x4,%esp
80106240:	6a 00                	push   $0x0
80106242:	68 00 00 00 80       	push   $0x80000000
80106247:	56                   	push   %esi
80106248:	e8 68 fe ff ff       	call   801060b5 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010624d:	83 c4 10             	add    $0x10,%esp
80106250:	bb 00 00 00 00       	mov    $0x0,%ebx
80106255:	eb 10                	jmp    80106267 <freevm+0x36>
    panic("freevm: no pgdir");
80106257:	83 ec 0c             	sub    $0xc,%esp
8010625a:	68 a1 6e 10 80       	push   $0x80106ea1
8010625f:	e8 e4 a0 ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
80106264:	83 c3 01             	add    $0x1,%ebx
80106267:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
8010626d:	77 1f                	ja     8010628e <freevm+0x5d>
    if(pgdir[i] & PTE_P){
8010626f:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
80106272:	a8 01                	test   $0x1,%al
80106274:	74 ee                	je     80106264 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
80106276:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010627b:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
80106280:	83 ec 0c             	sub    $0xc,%esp
80106283:	50                   	push   %eax
80106284:	e8 1b bd ff ff       	call   80101fa4 <kfree>
80106289:	83 c4 10             	add    $0x10,%esp
8010628c:	eb d6                	jmp    80106264 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
8010628e:	83 ec 0c             	sub    $0xc,%esp
80106291:	56                   	push   %esi
80106292:	e8 0d bd ff ff       	call   80101fa4 <kfree>
}
80106297:	83 c4 10             	add    $0x10,%esp
8010629a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010629d:	5b                   	pop    %ebx
8010629e:	5e                   	pop    %esi
8010629f:	5d                   	pop    %ebp
801062a0:	c3                   	ret    

801062a1 <setupkvm>:
{
801062a1:	55                   	push   %ebp
801062a2:	89 e5                	mov    %esp,%ebp
801062a4:	56                   	push   %esi
801062a5:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
801062a6:	e8 10 be ff ff       	call   801020bb <kalloc>
801062ab:	89 c6                	mov    %eax,%esi
801062ad:	85 c0                	test   %eax,%eax
801062af:	74 55                	je     80106306 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
801062b1:	83 ec 04             	sub    $0x4,%esp
801062b4:	68 00 10 00 00       	push   $0x1000
801062b9:	6a 00                	push   $0x0
801062bb:	50                   	push   %eax
801062bc:	e8 c2 d9 ff ff       	call   80103c83 <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801062c1:	83 c4 10             	add    $0x10,%esp
801062c4:	bb 20 94 10 80       	mov    $0x80109420,%ebx
801062c9:	81 fb 60 94 10 80    	cmp    $0x80109460,%ebx
801062cf:	73 35                	jae    80106306 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
801062d1:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
801062d4:	8b 4b 08             	mov    0x8(%ebx),%ecx
801062d7:	29 c1                	sub    %eax,%ecx
801062d9:	83 ec 08             	sub    $0x8,%esp
801062dc:	ff 73 0c             	pushl  0xc(%ebx)
801062df:	50                   	push   %eax
801062e0:	8b 13                	mov    (%ebx),%edx
801062e2:	89 f0                	mov    %esi,%eax
801062e4:	e8 d7 f9 ff ff       	call   80105cc0 <mappages>
801062e9:	83 c4 10             	add    $0x10,%esp
801062ec:	85 c0                	test   %eax,%eax
801062ee:	78 05                	js     801062f5 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
801062f0:	83 c3 10             	add    $0x10,%ebx
801062f3:	eb d4                	jmp    801062c9 <setupkvm+0x28>
      freevm(pgdir);
801062f5:	83 ec 0c             	sub    $0xc,%esp
801062f8:	56                   	push   %esi
801062f9:	e8 33 ff ff ff       	call   80106231 <freevm>
      return 0;
801062fe:	83 c4 10             	add    $0x10,%esp
80106301:	be 00 00 00 00       	mov    $0x0,%esi
}
80106306:	89 f0                	mov    %esi,%eax
80106308:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010630b:	5b                   	pop    %ebx
8010630c:	5e                   	pop    %esi
8010630d:	5d                   	pop    %ebp
8010630e:	c3                   	ret    

8010630f <kvmalloc>:
{
8010630f:	55                   	push   %ebp
80106310:	89 e5                	mov    %esp,%ebp
80106312:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106315:	e8 87 ff ff ff       	call   801062a1 <setupkvm>
8010631a:	a3 e4 c4 16 80       	mov    %eax,0x8016c4e4
  switchkvm();
8010631f:	e8 5e fb ff ff       	call   80105e82 <switchkvm>
}
80106324:	c9                   	leave  
80106325:	c3                   	ret    

80106326 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106326:	55                   	push   %ebp
80106327:	89 e5                	mov    %esp,%ebp
80106329:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010632c:	b9 00 00 00 00       	mov    $0x0,%ecx
80106331:	8b 55 0c             	mov    0xc(%ebp),%edx
80106334:	8b 45 08             	mov    0x8(%ebp),%eax
80106337:	e8 14 f9 ff ff       	call   80105c50 <walkpgdir>
  if(pte == 0)
8010633c:	85 c0                	test   %eax,%eax
8010633e:	74 05                	je     80106345 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106340:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
80106343:	c9                   	leave  
80106344:	c3                   	ret    
    panic("clearpteu");
80106345:	83 ec 0c             	sub    $0xc,%esp
80106348:	68 b2 6e 10 80       	push   $0x80106eb2
8010634d:	e8 f6 9f ff ff       	call   80100348 <panic>

80106352 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
80106352:	55                   	push   %ebp
80106353:	89 e5                	mov    %esp,%ebp
80106355:	57                   	push   %edi
80106356:	56                   	push   %esi
80106357:	53                   	push   %ebx
80106358:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
8010635b:	e8 41 ff ff ff       	call   801062a1 <setupkvm>
80106360:	89 45 dc             	mov    %eax,-0x24(%ebp)
80106363:	85 c0                	test   %eax,%eax
80106365:	0f 84 c4 00 00 00    	je     8010642f <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
8010636b:	bf 00 00 00 00       	mov    $0x0,%edi
80106370:	3b 7d 0c             	cmp    0xc(%ebp),%edi
80106373:	0f 83 b6 00 00 00    	jae    8010642f <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
80106379:	89 7d e4             	mov    %edi,-0x1c(%ebp)
8010637c:	b9 00 00 00 00       	mov    $0x0,%ecx
80106381:	89 fa                	mov    %edi,%edx
80106383:	8b 45 08             	mov    0x8(%ebp),%eax
80106386:	e8 c5 f8 ff ff       	call   80105c50 <walkpgdir>
8010638b:	85 c0                	test   %eax,%eax
8010638d:	74 65                	je     801063f4 <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
8010638f:	8b 00                	mov    (%eax),%eax
80106391:	a8 01                	test   $0x1,%al
80106393:	74 6c                	je     80106401 <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106395:	89 c6                	mov    %eax,%esi
80106397:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
8010639d:	25 ff 0f 00 00       	and    $0xfff,%eax
801063a2:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
801063a5:	e8 11 bd ff ff       	call   801020bb <kalloc>
801063aa:	89 c3                	mov    %eax,%ebx
801063ac:	85 c0                	test   %eax,%eax
801063ae:	74 6a                	je     8010641a <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
801063b0:	81 c6 00 00 00 80    	add    $0x80000000,%esi
801063b6:	83 ec 04             	sub    $0x4,%esp
801063b9:	68 00 10 00 00       	push   $0x1000
801063be:	56                   	push   %esi
801063bf:	50                   	push   %eax
801063c0:	e8 39 d9 ff ff       	call   80103cfe <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
801063c5:	83 c4 08             	add    $0x8,%esp
801063c8:	ff 75 e0             	pushl  -0x20(%ebp)
801063cb:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801063d1:	50                   	push   %eax
801063d2:	b9 00 10 00 00       	mov    $0x1000,%ecx
801063d7:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801063da:	8b 45 dc             	mov    -0x24(%ebp),%eax
801063dd:	e8 de f8 ff ff       	call   80105cc0 <mappages>
801063e2:	83 c4 10             	add    $0x10,%esp
801063e5:	85 c0                	test   %eax,%eax
801063e7:	78 25                	js     8010640e <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
801063e9:	81 c7 00 10 00 00    	add    $0x1000,%edi
801063ef:	e9 7c ff ff ff       	jmp    80106370 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
801063f4:	83 ec 0c             	sub    $0xc,%esp
801063f7:	68 bc 6e 10 80       	push   $0x80106ebc
801063fc:	e8 47 9f ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106401:	83 ec 0c             	sub    $0xc,%esp
80106404:	68 d6 6e 10 80       	push   $0x80106ed6
80106409:	e8 3a 9f ff ff       	call   80100348 <panic>
      kfree(mem);
8010640e:	83 ec 0c             	sub    $0xc,%esp
80106411:	53                   	push   %ebx
80106412:	e8 8d bb ff ff       	call   80101fa4 <kfree>
      goto bad;
80106417:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
8010641a:	83 ec 0c             	sub    $0xc,%esp
8010641d:	ff 75 dc             	pushl  -0x24(%ebp)
80106420:	e8 0c fe ff ff       	call   80106231 <freevm>
  return 0;
80106425:	83 c4 10             	add    $0x10,%esp
80106428:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
8010642f:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106432:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106435:	5b                   	pop    %ebx
80106436:	5e                   	pop    %esi
80106437:	5f                   	pop    %edi
80106438:	5d                   	pop    %ebp
80106439:	c3                   	ret    

8010643a <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
8010643a:	55                   	push   %ebp
8010643b:	89 e5                	mov    %esp,%ebp
8010643d:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106440:	b9 00 00 00 00       	mov    $0x0,%ecx
80106445:	8b 55 0c             	mov    0xc(%ebp),%edx
80106448:	8b 45 08             	mov    0x8(%ebp),%eax
8010644b:	e8 00 f8 ff ff       	call   80105c50 <walkpgdir>
  if((*pte & PTE_P) == 0)
80106450:	8b 00                	mov    (%eax),%eax
80106452:	a8 01                	test   $0x1,%al
80106454:	74 10                	je     80106466 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
80106456:	a8 04                	test   $0x4,%al
80106458:	74 13                	je     8010646d <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
8010645a:	25 00 f0 ff ff       	and    $0xfffff000,%eax
8010645f:	05 00 00 00 80       	add    $0x80000000,%eax
}
80106464:	c9                   	leave  
80106465:	c3                   	ret    
    return 0;
80106466:	b8 00 00 00 00       	mov    $0x0,%eax
8010646b:	eb f7                	jmp    80106464 <uva2ka+0x2a>
    return 0;
8010646d:	b8 00 00 00 00       	mov    $0x0,%eax
80106472:	eb f0                	jmp    80106464 <uva2ka+0x2a>

80106474 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
80106474:	55                   	push   %ebp
80106475:	89 e5                	mov    %esp,%ebp
80106477:	57                   	push   %edi
80106478:	56                   	push   %esi
80106479:	53                   	push   %ebx
8010647a:	83 ec 0c             	sub    $0xc,%esp
8010647d:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
80106480:	eb 25                	jmp    801064a7 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
80106482:	8b 55 0c             	mov    0xc(%ebp),%edx
80106485:	29 f2                	sub    %esi,%edx
80106487:	01 d0                	add    %edx,%eax
80106489:	83 ec 04             	sub    $0x4,%esp
8010648c:	53                   	push   %ebx
8010648d:	ff 75 10             	pushl  0x10(%ebp)
80106490:	50                   	push   %eax
80106491:	e8 68 d8 ff ff       	call   80103cfe <memmove>
    len -= n;
80106496:	29 df                	sub    %ebx,%edi
    buf += n;
80106498:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
8010649b:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
801064a1:	89 45 0c             	mov    %eax,0xc(%ebp)
801064a4:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
801064a7:	85 ff                	test   %edi,%edi
801064a9:	74 2f                	je     801064da <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
801064ab:	8b 75 0c             	mov    0xc(%ebp),%esi
801064ae:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
801064b4:	83 ec 08             	sub    $0x8,%esp
801064b7:	56                   	push   %esi
801064b8:	ff 75 08             	pushl  0x8(%ebp)
801064bb:	e8 7a ff ff ff       	call   8010643a <uva2ka>
    if(pa0 == 0)
801064c0:	83 c4 10             	add    $0x10,%esp
801064c3:	85 c0                	test   %eax,%eax
801064c5:	74 20                	je     801064e7 <copyout+0x73>
    n = PGSIZE - (va - va0);
801064c7:	89 f3                	mov    %esi,%ebx
801064c9:	2b 5d 0c             	sub    0xc(%ebp),%ebx
801064cc:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
801064d2:	39 df                	cmp    %ebx,%edi
801064d4:	73 ac                	jae    80106482 <copyout+0xe>
      n = len;
801064d6:	89 fb                	mov    %edi,%ebx
801064d8:	eb a8                	jmp    80106482 <copyout+0xe>
  }
  return 0;
801064da:	b8 00 00 00 00       	mov    $0x0,%eax
}
801064df:	8d 65 f4             	lea    -0xc(%ebp),%esp
801064e2:	5b                   	pop    %ebx
801064e3:	5e                   	pop    %esi
801064e4:	5f                   	pop    %edi
801064e5:	5d                   	pop    %ebp
801064e6:	c3                   	ret    
      return -1;
801064e7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801064ec:	eb f1                	jmp    801064df <copyout+0x6b>
