
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
80100028:	bc c0 b5 10 80       	mov    $0x8010b5c0,%esp

  # Jump to main(), and switch to executing at
  # high addresses. The indirect call is needed because
  # the assembler produces a PC-relative instruction
  # for a direct jump.
  mov $main, %eax
8010002d:	b8 f7 2b 10 80       	mov    $0x80102bf7,%eax
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
80100041:	68 c0 b5 10 80       	push   $0x8010b5c0
80100046:	e8 e6 3c 00 00       	call   80103d31 <acquire>

  // Is the block already cached?
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
8010004b:	8b 1d 10 fd 10 80    	mov    0x8010fd10,%ebx
80100051:	83 c4 10             	add    $0x10,%esp
80100054:	eb 03                	jmp    80100059 <bget+0x25>
80100056:	8b 5b 54             	mov    0x54(%ebx),%ebx
80100059:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
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
80100077:	68 c0 b5 10 80       	push   $0x8010b5c0
8010007c:	e8 15 3d 00 00       	call   80103d96 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 91 3a 00 00       	call   80103b1d <acquiresleep>
      return b;
8010008c:	83 c4 10             	add    $0x10,%esp
8010008f:	eb 4c                	jmp    801000dd <bget+0xa9>
  }

  // Not cached; recycle an unused buffer.
  // Even if refcnt==0, B_DIRTY indicates a buffer is in use
  // because log.c has modified it but not yet committed it.
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
80100091:	8b 1d 0c fd 10 80    	mov    0x8010fd0c,%ebx
80100097:	eb 03                	jmp    8010009c <bget+0x68>
80100099:	8b 5b 50             	mov    0x50(%ebx),%ebx
8010009c:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
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
801000c5:	68 c0 b5 10 80       	push   $0x8010b5c0
801000ca:	e8 c7 3c 00 00       	call   80103d96 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 43 3a 00 00       	call   80103b1d <acquiresleep>
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
801000ea:	68 60 66 10 80       	push   $0x80106660
801000ef:	e8 54 02 00 00       	call   80100348 <panic>

801000f4 <binit>:
{
801000f4:	55                   	push   %ebp
801000f5:	89 e5                	mov    %esp,%ebp
801000f7:	53                   	push   %ebx
801000f8:	83 ec 0c             	sub    $0xc,%esp
  initlock(&bcache.lock, "bcache");
801000fb:	68 71 66 10 80       	push   $0x80106671
80100100:	68 c0 b5 10 80       	push   $0x8010b5c0
80100105:	e8 eb 3a 00 00       	call   80103bf5 <initlock>
  bcache.head.prev = &bcache.head;
8010010a:	c7 05 0c fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd0c
80100111:	fc 10 80 
  bcache.head.next = &bcache.head;
80100114:	c7 05 10 fd 10 80 bc 	movl   $0x8010fcbc,0x8010fd10
8010011b:	fc 10 80 
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
8010011e:	83 c4 10             	add    $0x10,%esp
80100121:	bb f4 b5 10 80       	mov    $0x8010b5f4,%ebx
80100126:	eb 37                	jmp    8010015f <binit+0x6b>
    b->next = bcache.head.next;
80100128:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010012d:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
80100130:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    initsleeplock(&b->lock, "buffer");
80100137:	83 ec 08             	sub    $0x8,%esp
8010013a:	68 78 66 10 80       	push   $0x80106678
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 a2 39 00 00       	call   80103aea <initsleeplock>
    bcache.head.next->prev = b;
80100148:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010014d:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
80100150:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
80100156:	81 c3 5c 02 00 00    	add    $0x25c,%ebx
8010015c:	83 c4 10             	add    $0x10,%esp
8010015f:	81 fb bc fc 10 80    	cmp    $0x8010fcbc,%ebx
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
801001a8:	e8 fa 39 00 00       	call   80103ba7 <holdingsleep>
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
801001cb:	68 7f 66 10 80       	push   $0x8010667f
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
801001e4:	e8 be 39 00 00       	call   80103ba7 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 73 39 00 00       	call   80103b6c <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 c0 b5 10 80 	movl   $0x8010b5c0,(%esp)
80100200:	e8 2c 3b 00 00       	call   80103d31 <acquire>
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
80100227:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010022c:	89 43 54             	mov    %eax,0x54(%ebx)
    b->prev = &bcache.head;
8010022f:	c7 43 50 bc fc 10 80 	movl   $0x8010fcbc,0x50(%ebx)
    bcache.head.next->prev = b;
80100236:	a1 10 fd 10 80       	mov    0x8010fd10,%eax
8010023b:	89 58 50             	mov    %ebx,0x50(%eax)
    bcache.head.next = b;
8010023e:	89 1d 10 fd 10 80    	mov    %ebx,0x8010fd10
  }
  
  release(&bcache.lock);
80100244:	83 ec 0c             	sub    $0xc,%esp
80100247:	68 c0 b5 10 80       	push   $0x8010b5c0
8010024c:	e8 45 3b 00 00       	call   80103d96 <release>
}
80100251:	83 c4 10             	add    $0x10,%esp
80100254:	8d 65 f8             	lea    -0x8(%ebp),%esp
80100257:	5b                   	pop    %ebx
80100258:	5e                   	pop    %esi
80100259:	5d                   	pop    %ebp
8010025a:	c3                   	ret    
    panic("brelse");
8010025b:	83 ec 0c             	sub    $0xc,%esp
8010025e:	68 86 66 10 80       	push   $0x80106686
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
8010028a:	e8 a2 3a 00 00       	call   80103d31 <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
8010029f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 e3 30 00 00       	call   8010338f <myproc>
801002ac:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801002b0:	75 17                	jne    801002c9 <consoleread+0x61>
        release(&cons.lock);
        ilock(ip);
        return -1;
      }
      sleep(&input.r, &cons.lock);
801002b2:	83 ec 08             	sub    $0x8,%esp
801002b5:	68 20 a5 10 80       	push   $0x8010a520
801002ba:	68 a0 ff 10 80       	push   $0x8010ffa0
801002bf:	e8 72 35 00 00       	call   80103836 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 c0 3a 00 00       	call   80103d96 <release>
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
801002f1:	89 15 a0 ff 10 80    	mov    %edx,0x8010ffa0
801002f7:	89 c2                	mov    %eax,%edx
801002f9:	83 e2 7f             	and    $0x7f,%edx
801002fc:	0f b6 8a 20 ff 10 80 	movzbl -0x7fef00e0(%edx),%ecx
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
80100324:	a3 a0 ff 10 80       	mov    %eax,0x8010ffa0
  release(&cons.lock);
80100329:	83 ec 0c             	sub    $0xc,%esp
8010032c:	68 20 a5 10 80       	push   $0x8010a520
80100331:	e8 60 3a 00 00       	call   80103d96 <release>
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
8010035a:	e8 b2 21 00 00       	call   80102511 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 8d 66 10 80       	push   $0x8010668d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 db 6f 10 80 	movl   $0x80106fdb,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 7c 38 00 00       	call   80103c10 <getcallerpcs>
  for(i=0; i<10; i++)
80100394:	83 c4 10             	add    $0x10,%esp
80100397:	bb 00 00 00 00       	mov    $0x0,%ebx
8010039c:	eb 17                	jmp    801003b5 <panic+0x6d>
    cprintf(" %p", pcs[i]);
8010039e:	83 ec 08             	sub    $0x8,%esp
801003a1:	ff 74 9d d0          	pushl  -0x30(%ebp,%ebx,4)
801003a5:	68 a1 66 10 80       	push   $0x801066a1
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
8010049e:	68 a5 66 10 80       	push   $0x801066a5
801004a3:	e8 a0 fe ff ff       	call   80100348 <panic>
    memmove(crt, crt+80, sizeof(crt[0])*23*80);
801004a8:	83 ec 04             	sub    $0x4,%esp
801004ab:	68 60 0e 00 00       	push   $0xe60
801004b0:	68 a0 80 0b 80       	push   $0x800b80a0
801004b5:	68 00 80 0b 80       	push   $0x800b8000
801004ba:	e8 99 39 00 00       	call   80103e58 <memmove>
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
801004d9:	e8 ff 38 00 00       	call   80103ddd <memset>
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
80100506:	e8 0c 4d 00 00       	call   80105217 <uartputc>
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
8010051f:	e8 f3 4c 00 00       	call   80105217 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 e7 4c 00 00       	call   80105217 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 db 4c 00 00       	call   80105217 <uartputc>
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
80100576:	0f b6 92 d0 66 10 80 	movzbl -0x7fef9930(%edx),%edx
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
801005ca:	e8 62 37 00 00       	call   80103d31 <acquire>
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
801005f1:	e8 a0 37 00 00       	call   80103d96 <release>
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
80100638:	e8 f4 36 00 00       	call   80103d31 <acquire>
8010063d:	83 c4 10             	add    $0x10,%esp
80100640:	eb de                	jmp    80100620 <cprintf+0x15>
    panic("null fmt");
80100642:	83 ec 0c             	sub    $0xc,%esp
80100645:	68 bf 66 10 80       	push   $0x801066bf
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
801006ee:	be b8 66 10 80       	mov    $0x801066b8,%esi
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
80100734:	e8 5d 36 00 00       	call   80103d96 <release>
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
8010074f:	e8 dd 35 00 00       	call   80103d31 <acquire>
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
80100772:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
80100777:	89 c2                	mov    %eax,%edx
80100779:	2b 15 a0 ff 10 80    	sub    0x8010ffa0,%edx
8010077f:	83 fa 7f             	cmp    $0x7f,%edx
80100782:	0f 87 9e 00 00 00    	ja     80100826 <consoleintr+0xe8>
        c = (c == '\r') ? '\n' : c;
80100788:	83 ff 0d             	cmp    $0xd,%edi
8010078b:	0f 84 86 00 00 00    	je     80100817 <consoleintr+0xd9>
        input.buf[input.e++ % INPUT_BUF] = c;
80100791:	8d 50 01             	lea    0x1(%eax),%edx
80100794:	89 15 a8 ff 10 80    	mov    %edx,0x8010ffa8
8010079a:	83 e0 7f             	and    $0x7f,%eax
8010079d:	89 f9                	mov    %edi,%ecx
8010079f:	88 88 20 ff 10 80    	mov    %cl,-0x7fef00e0(%eax)
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
801007bc:	a1 a0 ff 10 80       	mov    0x8010ffa0,%eax
801007c1:	83 e8 80             	sub    $0xffffff80,%eax
801007c4:	39 05 a8 ff 10 80    	cmp    %eax,0x8010ffa8
801007ca:	75 5a                	jne    80100826 <consoleintr+0xe8>
          input.w = input.e;
801007cc:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
801007d1:	a3 a4 ff 10 80       	mov    %eax,0x8010ffa4
          wakeup(&input.r);
801007d6:	83 ec 0c             	sub    $0xc,%esp
801007d9:	68 a0 ff 10 80       	push   $0x8010ffa0
801007de:	e8 b8 31 00 00       	call   8010399b <wakeup>
801007e3:	83 c4 10             	add    $0x10,%esp
801007e6:	eb 3e                	jmp    80100826 <consoleintr+0xe8>
        input.e--;
801007e8:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
801007ed:	b8 00 01 00 00       	mov    $0x100,%eax
801007f2:	e8 ef fc ff ff       	call   801004e6 <consputc>
      while(input.e != input.w &&
801007f7:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
801007fc:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
80100802:	74 22                	je     80100826 <consoleintr+0xe8>
            input.buf[(input.e-1) % INPUT_BUF] != '\n'){
80100804:	83 e8 01             	sub    $0x1,%eax
80100807:	89 c2                	mov    %eax,%edx
80100809:	83 e2 7f             	and    $0x7f,%edx
      while(input.e != input.w &&
8010080c:	80 ba 20 ff 10 80 0a 	cmpb   $0xa,-0x7fef00e0(%edx)
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
8010084a:	a1 a8 ff 10 80       	mov    0x8010ffa8,%eax
8010084f:	3b 05 a4 ff 10 80    	cmp    0x8010ffa4,%eax
80100855:	74 cf                	je     80100826 <consoleintr+0xe8>
        input.e--;
80100857:	83 e8 01             	sub    $0x1,%eax
8010085a:	a3 a8 ff 10 80       	mov    %eax,0x8010ffa8
        consputc(BACKSPACE);
8010085f:	b8 00 01 00 00       	mov    $0x100,%eax
80100864:	e8 7d fc ff ff       	call   801004e6 <consputc>
80100869:	eb bb                	jmp    80100826 <consoleintr+0xe8>
  release(&cons.lock);
8010086b:	83 ec 0c             	sub    $0xc,%esp
8010086e:	68 20 a5 10 80       	push   $0x8010a520
80100873:	e8 1e 35 00 00       	call   80103d96 <release>
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
80100887:	e8 ac 31 00 00       	call   80103a38 <procdump>
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
80100894:	68 c8 66 10 80       	push   $0x801066c8
80100899:	68 20 a5 10 80       	push   $0x8010a520
8010089e:	e8 52 33 00 00       	call   80103bf5 <initlock>

  devsw[CONSOLE].write = consolewrite;
801008a3:	c7 05 6c 09 11 80 ac 	movl   $0x801005ac,0x8011096c
801008aa:	05 10 80 
  devsw[CONSOLE].read = consoleread;
801008ad:	c7 05 68 09 11 80 68 	movl   $0x80100268,0x80110968
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
801008de:	e8 ac 2a 00 00       	call   8010338f <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 53 20 00 00       	call   80102941 <begin_op>

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
80100935:	e8 81 20 00 00       	call   801029bb <end_op>
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
8010094a:	e8 6c 20 00 00       	call   801029bb <end_op>
    cprintf("exec: fail\n");
8010094f:	83 ec 0c             	sub    $0xc,%esp
80100952:	68 e1 66 10 80       	push   $0x801066e1
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
80100972:	e8 7b 5a 00 00       	call   801063f2 <setupkvm>
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
80100a06:	e8 7f 58 00 00       	call   8010628a <allocuvm>
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
80100a38:	e8 1b 57 00 00       	call   80106158 <loaduvm>
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
80100a53:	e8 63 1f 00 00       	call   801029bb <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 11 58 00 00       	call   8010628a <allocuvm>
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
80100a9d:	e8 e0 58 00 00       	call   80106382 <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 be 59 00 00       	call   8010647f <clearpteu>
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
80100ae2:	e8 98 34 00 00       	call   80103f7f <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 86 34 00 00       	call   80103f7f <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 cf 5a 00 00       	call   801065da <copyout>
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
80100b66:	e8 6f 5a 00 00       	call   801065da <copyout>
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
80100ba3:	e8 9c 33 00 00       	call   80103f44 <safestrcpy>
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
80100bd1:	e8 fc 53 00 00       	call   80105fd2 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 a4 57 00 00       	call   80106382 <freevm>
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
80100c19:	68 ed 66 10 80       	push   $0x801066ed
80100c1e:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c23:	e8 cd 2f 00 00       	call   80103bf5 <initlock>
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
80100c34:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c39:	e8 f3 30 00 00       	call   80103d31 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
80100c3e:	83 c4 10             	add    $0x10,%esp
80100c41:	bb f4 ff 10 80       	mov    $0x8010fff4,%ebx
80100c46:	81 fb 54 09 11 80    	cmp    $0x80110954,%ebx
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
80100c63:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c68:	e8 29 31 00 00       	call   80103d96 <release>
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
80100c7a:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c7f:	e8 12 31 00 00       	call   80103d96 <release>
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
80100c98:	68 c0 ff 10 80       	push   $0x8010ffc0
80100c9d:	e8 8f 30 00 00       	call   80103d31 <acquire>
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
80100cb5:	68 c0 ff 10 80       	push   $0x8010ffc0
80100cba:	e8 d7 30 00 00       	call   80103d96 <release>
  return f;
}
80100cbf:	89 d8                	mov    %ebx,%eax
80100cc1:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80100cc4:	c9                   	leave  
80100cc5:	c3                   	ret    
    panic("filedup");
80100cc6:	83 ec 0c             	sub    $0xc,%esp
80100cc9:	68 f4 66 10 80       	push   $0x801066f4
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
80100cdd:	68 c0 ff 10 80       	push   $0x8010ffc0
80100ce2:	e8 4a 30 00 00       	call   80103d31 <acquire>
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
80100cfe:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d03:	e8 8e 30 00 00       	call   80103d96 <release>
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
80100d13:	68 fc 66 10 80       	push   $0x801066fc
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
80100d44:	68 c0 ff 10 80       	push   $0x8010ffc0
80100d49:	e8 48 30 00 00       	call   80103d96 <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 de 1b 00 00       	call   80102941 <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 48 1c 00 00       	call   801029bb <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 2d 22 00 00       	call   80102fb5 <pipeclose>
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
80100e3c:	e8 cc 22 00 00       	call   8010310d <piperead>
80100e41:	89 c6                	mov    %eax,%esi
80100e43:	83 c4 10             	add    $0x10,%esp
80100e46:	eb df                	jmp    80100e27 <fileread+0x50>
  panic("fileread");
80100e48:	83 ec 0c             	sub    $0xc,%esp
80100e4b:	68 06 67 10 80       	push   $0x80106706
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
80100e95:	e8 a7 21 00 00       	call   80103041 <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 9a 1a 00 00       	call   80102941 <begin_op>
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
80100edd:	e8 d9 1a 00 00       	call   801029bb <end_op>

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
80100f10:	68 0f 67 10 80       	push   $0x8010670f
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
80100f2d:	68 15 67 10 80       	push   $0x80106715
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
80100f8a:	e8 c9 2e 00 00       	call   80103e58 <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 b9 2e 00 00       	call   80103e58 <memmove>
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
80100fdf:	e8 f9 2d 00 00       	call   80103ddd <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 7e 1a 00 00       	call   80102a6a <log_write>
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
80101023:	39 35 c0 09 11 80    	cmp    %esi,0x801109c0
80101029:	76 75                	jbe    801010a0 <balloc+0xa4>
    bp = bread(dev, BBLOCK(b, sb));
8010102b:	8d 86 ff 0f 00 00    	lea    0xfff(%esi),%eax
80101031:	85 f6                	test   %esi,%esi
80101033:	0f 49 c6             	cmovns %esi,%eax
80101036:	c1 f8 0c             	sar    $0xc,%eax
80101039:	03 05 d8 09 11 80    	add    0x801109d8,%eax
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
80101063:	3b 1d c0 09 11 80    	cmp    0x801109c0,%ebx
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
801010a3:	68 1f 67 10 80       	push   $0x8010671f
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
801010bf:	e8 a6 19 00 00       	call   80102a6a <log_write>
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
80101170:	e8 f5 18 00 00       	call   80102a6a <log_write>
80101175:	83 c4 10             	add    $0x10,%esp
80101178:	eb bf                	jmp    80101139 <bmap+0x58>
  panic("bmap: out of range");
8010117a:	83 ec 0c             	sub    $0xc,%esp
8010117d:	68 35 67 10 80       	push   $0x80106735
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
80101195:	68 e0 09 11 80       	push   $0x801109e0
8010119a:	e8 92 2b 00 00       	call   80103d31 <acquire>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
8010119f:	83 c4 10             	add    $0x10,%esp
  empty = 0;
801011a2:	be 00 00 00 00       	mov    $0x0,%esi
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011a7:	bb 14 0a 11 80       	mov    $0x80110a14,%ebx
801011ac:	eb 0a                	jmp    801011b8 <iget+0x31>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
801011ae:	85 f6                	test   %esi,%esi
801011b0:	74 3b                	je     801011ed <iget+0x66>
  for(ip = &icache.inode[0]; ip < &icache.inode[NINODE]; ip++){
801011b2:	81 c3 90 00 00 00    	add    $0x90,%ebx
801011b8:	81 fb 34 26 11 80    	cmp    $0x80112634,%ebx
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
801011dc:	68 e0 09 11 80       	push   $0x801109e0
801011e1:	e8 b0 2b 00 00       	call   80103d96 <release>
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
80101212:	68 e0 09 11 80       	push   $0x801109e0
80101217:	e8 7a 2b 00 00       	call   80103d96 <release>
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
8010122c:	68 48 67 10 80       	push   $0x80106748
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
80101255:	e8 fe 2b 00 00       	call   80103e58 <memmove>
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
80101276:	68 c0 09 11 80       	push   $0x801109c0
8010127b:	50                   	push   %eax
8010127c:	e8 b5 ff ff ff       	call   80101236 <readsb>
  bp = bread(dev, BBLOCK(b, sb));
80101281:	89 d8                	mov    %ebx,%eax
80101283:	c1 e8 0c             	shr    $0xc,%eax
80101286:	03 05 d8 09 11 80    	add    0x801109d8,%eax
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
801012c8:	e8 9d 17 00 00       	call   80102a6a <log_write>
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
801012e2:	68 58 67 10 80       	push   $0x80106758
801012e7:	e8 5c f0 ff ff       	call   80100348 <panic>

801012ec <iinit>:
{
801012ec:	55                   	push   %ebp
801012ed:	89 e5                	mov    %esp,%ebp
801012ef:	53                   	push   %ebx
801012f0:	83 ec 0c             	sub    $0xc,%esp
  initlock(&icache.lock, "icache");
801012f3:	68 6b 67 10 80       	push   $0x8010676b
801012f8:	68 e0 09 11 80       	push   $0x801109e0
801012fd:	e8 f3 28 00 00       	call   80103bf5 <initlock>
  for(i = 0; i < NINODE; i++) {
80101302:	83 c4 10             	add    $0x10,%esp
80101305:	bb 00 00 00 00       	mov    $0x0,%ebx
8010130a:	eb 21                	jmp    8010132d <iinit+0x41>
    initsleeplock(&icache.inode[i].lock, "inode");
8010130c:	83 ec 08             	sub    $0x8,%esp
8010130f:	68 72 67 10 80       	push   $0x80106772
80101314:	8d 14 db             	lea    (%ebx,%ebx,8),%edx
80101317:	89 d0                	mov    %edx,%eax
80101319:	c1 e0 04             	shl    $0x4,%eax
8010131c:	05 20 0a 11 80       	add    $0x80110a20,%eax
80101321:	50                   	push   %eax
80101322:	e8 c3 27 00 00       	call   80103aea <initsleeplock>
  for(i = 0; i < NINODE; i++) {
80101327:	83 c3 01             	add    $0x1,%ebx
8010132a:	83 c4 10             	add    $0x10,%esp
8010132d:	83 fb 31             	cmp    $0x31,%ebx
80101330:	7e da                	jle    8010130c <iinit+0x20>
  readsb(dev, &sb);
80101332:	83 ec 08             	sub    $0x8,%esp
80101335:	68 c0 09 11 80       	push   $0x801109c0
8010133a:	ff 75 08             	pushl  0x8(%ebp)
8010133d:	e8 f4 fe ff ff       	call   80101236 <readsb>
  cprintf("sb: size %d nblocks %d ninodes %d nlog %d logstart %d\
80101342:	ff 35 d8 09 11 80    	pushl  0x801109d8
80101348:	ff 35 d4 09 11 80    	pushl  0x801109d4
8010134e:	ff 35 d0 09 11 80    	pushl  0x801109d0
80101354:	ff 35 cc 09 11 80    	pushl  0x801109cc
8010135a:	ff 35 c8 09 11 80    	pushl  0x801109c8
80101360:	ff 35 c4 09 11 80    	pushl  0x801109c4
80101366:	ff 35 c0 09 11 80    	pushl  0x801109c0
8010136c:	68 d8 67 10 80       	push   $0x801067d8
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
80101395:	39 1d c8 09 11 80    	cmp    %ebx,0x801109c8
8010139b:	76 3f                	jbe    801013dc <ialloc+0x5e>
    bp = bread(dev, IBLOCK(inum, sb));
8010139d:	89 d8                	mov    %ebx,%eax
8010139f:	c1 e8 03             	shr    $0x3,%eax
801013a2:	03 05 d4 09 11 80    	add    0x801109d4,%eax
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
801013df:	68 78 67 10 80       	push   $0x80106778
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 e7 29 00 00       	call   80103ddd <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 65 16 00 00       	call   80102a6a <log_write>
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
8010142e:	03 05 d4 09 11 80    	add    0x801109d4,%eax
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
80101480:	e8 d3 29 00 00       	call   80103e58 <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 dd 15 00 00       	call   80102a6a <log_write>
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
8010155b:	68 e0 09 11 80       	push   $0x801109e0
80101560:	e8 cc 27 00 00       	call   80103d31 <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
80101575:	e8 1c 28 00 00       	call   80103d96 <release>
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
8010159a:	e8 7e 25 00 00       	call   80103b1d <acquiresleep>
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
801015b2:	68 8a 67 10 80       	push   $0x8010678a
801015b7:	e8 8c ed ff ff       	call   80100348 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
801015bc:	8b 43 04             	mov    0x4(%ebx),%eax
801015bf:	c1 e8 03             	shr    $0x3,%eax
801015c2:	03 05 d4 09 11 80    	add    0x801109d4,%eax
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
80101614:	e8 3f 28 00 00       	call   80103e58 <memmove>
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
80101639:	68 90 67 10 80       	push   $0x80106790
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
80101656:	e8 4c 25 00 00       	call   80103ba7 <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 fb 24 00 00       	call   80103b6c <releasesleep>
}
80101671:	83 c4 10             	add    $0x10,%esp
80101674:	8d 65 f8             	lea    -0x8(%ebp),%esp
80101677:	5b                   	pop    %ebx
80101678:	5e                   	pop    %esi
80101679:	5d                   	pop    %ebp
8010167a:	c3                   	ret    
    panic("iunlock");
8010167b:	83 ec 0c             	sub    $0xc,%esp
8010167e:	68 9f 67 10 80       	push   $0x8010679f
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
80101698:	e8 80 24 00 00       	call   80103b1d <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 b6 24 00 00       	call   80103b6c <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016bd:	e8 6f 26 00 00       	call   80103d31 <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016d2:	e8 bf 26 00 00       	call   80103d96 <release>
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
801016e5:	68 e0 09 11 80       	push   $0x801109e0
801016ea:	e8 42 26 00 00       	call   80103d31 <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 e0 09 11 80 	movl   $0x801109e0,(%esp)
801016f9:	e8 98 26 00 00       	call   80103d96 <release>
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
801017c4:	8b 04 c5 60 09 11 80 	mov    -0x7feef6a0(,%eax,8),%eax
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
8010182a:	e8 29 26 00 00       	call   80103e58 <memmove>
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
801018c1:	8b 04 c5 64 09 11 80 	mov    -0x7feef69c(,%eax,8),%eax
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
80101926:	e8 2d 25 00 00       	call   80103e58 <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 37 11 00 00       	call   80102a6a <log_write>
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
801019a9:	e8 11 25 00 00       	call   80103ebf <strncmp>
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
801019d0:	68 a7 67 10 80       	push   $0x801067a7
801019d5:	e8 6e e9 ff ff       	call   80100348 <panic>
      panic("dirlookup read");
801019da:	83 ec 0c             	sub    $0xc,%esp
801019dd:	68 b9 67 10 80       	push   $0x801067b9
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
80101a5a:	e8 30 19 00 00       	call   8010338f <myproc>
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
80101b92:	68 c8 67 10 80       	push   $0x801067c8
80101b97:	e8 ac e7 ff ff       	call   80100348 <panic>
  strncpy(de.name, name, DIRSIZ);
80101b9c:	83 ec 04             	sub    $0x4,%esp
80101b9f:	6a 0e                	push   $0xe
80101ba1:	57                   	push   %edi
80101ba2:	8d 7d d8             	lea    -0x28(%ebp),%edi
80101ba5:	8d 45 da             	lea    -0x26(%ebp),%eax
80101ba8:	50                   	push   %eax
80101ba9:	e8 4e 23 00 00       	call   80103efc <strncpy>
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
80101bd7:	68 d4 6d 10 80       	push   $0x80106dd4
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
80101ccc:	68 2b 68 10 80       	push   $0x8010682b
80101cd1:	e8 72 e6 ff ff       	call   80100348 <panic>
    panic("incorrect blockno");
80101cd6:	83 ec 0c             	sub    $0xc,%esp
80101cd9:	68 34 68 10 80       	push   $0x80106834
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
80101d06:	68 46 68 10 80       	push   $0x80106846
80101d0b:	68 80 a5 10 80       	push   $0x8010a580
80101d10:	e8 e0 1e 00 00       	call   80103bf5 <initlock>
  ioapicenable(IRQ_IDE, ncpu - 1);
80101d15:	83 c4 08             	add    $0x8,%esp
80101d18:	a1 00 ad 14 80       	mov    0x8014ad00,%eax
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
80101d80:	e8 ac 1f 00 00       	call   80103d31 <acquire>

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
80101dad:	e8 e9 1b 00 00       	call   8010399b <wakeup>

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
80101dcb:	e8 c6 1f 00 00       	call   80103d96 <release>
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
80101de2:	e8 af 1f 00 00       	call   80103d96 <release>
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
80101e1a:	e8 88 1d 00 00       	call   80103ba7 <holdingsleep>
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
80101e47:	e8 e5 1e 00 00       	call   80103d31 <acquire>

  // Append b to idequeue.
  b->qnext = 0;
80101e4c:	c7 43 58 00 00 00 00 	movl   $0x0,0x58(%ebx)
  for(pp=&idequeue; *pp; pp=&(*pp)->qnext)  //DOC:insert-queue
80101e53:	83 c4 10             	add    $0x10,%esp
80101e56:	ba 64 a5 10 80       	mov    $0x8010a564,%edx
80101e5b:	eb 2a                	jmp    80101e87 <iderw+0x7b>
    panic("iderw: buf not locked");
80101e5d:	83 ec 0c             	sub    $0xc,%esp
80101e60:	68 4a 68 10 80       	push   $0x8010684a
80101e65:	e8 de e4 ff ff       	call   80100348 <panic>
    panic("iderw: nothing to do");
80101e6a:	83 ec 0c             	sub    $0xc,%esp
80101e6d:	68 60 68 10 80       	push   $0x80106860
80101e72:	e8 d1 e4 ff ff       	call   80100348 <panic>
    panic("iderw: ide disk 1 not present");
80101e77:	83 ec 0c             	sub    $0xc,%esp
80101e7a:	68 75 68 10 80       	push   $0x80106875
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
80101ea9:	e8 88 19 00 00       	call   80103836 <sleep>
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
80101ec3:	e8 ce 1e 00 00       	call   80103d96 <release>
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
80101ed3:	8b 15 34 26 11 80    	mov    0x80112634,%edx
80101ed9:	89 02                	mov    %eax,(%edx)
  return ioapic->data;
80101edb:	a1 34 26 11 80       	mov    0x80112634,%eax
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
80101ee8:	8b 0d 34 26 11 80    	mov    0x80112634,%ecx
80101eee:	89 01                	mov    %eax,(%ecx)
  ioapic->data = data;
80101ef0:	a1 34 26 11 80       	mov    0x80112634,%eax
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
80101f03:	c7 05 34 26 11 80 00 	movl   $0xfec00000,0x80112634
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
80101f2a:	0f b6 15 60 a7 14 80 	movzbl 0x8014a760,%edx
80101f31:	39 c2                	cmp    %eax,%edx
80101f33:	75 07                	jne    80101f3c <ioapicinit+0x42>
{
80101f35:	bb 00 00 00 00       	mov    $0x0,%ebx
80101f3a:	eb 36                	jmp    80101f72 <ioapicinit+0x78>
    cprintf("ioapicinit: id isn't equal to ioapicid; not a MP\n");
80101f3c:	83 ec 0c             	sub    $0xc,%esp
80101f3f:	68 94 68 10 80       	push   $0x80106894
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
80101fa7:	56                   	push   %esi
80101fa8:	53                   	push   %ebx
80101fa9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  //cprintf("FUCK\n");

  struct run *r;

  if((uint)v % PGSIZE || v < end || V2P(v) >= PHYSTOP)
80101fac:	f7 c3 ff 0f 00 00    	test   $0xfff,%ebx
80101fb2:	75 64                	jne    80102018 <kfree+0x74>
80101fb4:	81 fb a8 d4 14 80    	cmp    $0x8014d4a8,%ebx
80101fba:	72 5c                	jb     80102018 <kfree+0x74>
80101fbc:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
80101fc2:	81 fe ff ff ff 0d    	cmp    $0xdffffff,%esi
80101fc8:	77 4e                	ja     80102018 <kfree+0x74>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(v, 1, PGSIZE);
80101fca:	83 ec 04             	sub    $0x4,%esp
80101fcd:	68 00 10 00 00       	push   $0x1000
80101fd2:	6a 01                	push   $0x1
80101fd4:	53                   	push   %ebx
80101fd5:	e8 03 1e 00 00       	call   80103ddd <memset>

  if(kmem.use_lock)
80101fda:	83 c4 10             	add    $0x10,%esp
80101fdd:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80101fe4:	75 3f                	jne    80102025 <kfree+0x81>
    acquire(&kmem.lock);
  
  r = (struct run*)v;
  r->next = kmem.freelist;
80101fe6:	a1 78 26 11 80       	mov    0x80112678,%eax
80101feb:	89 03                	mov    %eax,(%ebx)
  kmem.freelist = r;
80101fed:	89 1d 78 26 11 80    	mov    %ebx,0x80112678
  // p5
  //if(kinit2ed) {
    //if(V2P(v)>=startpa && V2P(v)<=endpa) {
  uint framenum = (uint)V2P((char*)v) >> 12;
80101ff3:	c1 ee 0c             	shr    $0xc,%esi
  int index = MAX_FNUM - framenum;//framenum;
80101ff6:	b8 ff df 00 00       	mov    $0xdfff,%eax
80101ffb:	29 f0                	sub    %esi,%eax
  kmem.page_info[index] = -1; //-1 indicates not allocated
80101ffd:	c7 04 85 7c 26 11 80 	movl   $0xffffffff,-0x7feed984(,%eax,4)
80102004:	ff ff ff ff 
    //r->next = kmem.freelist;
    //kmem.freelist = r;
  //}
  
  // p5
  if(kmem.use_lock)
80102008:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010200f:	75 26                	jne    80102037 <kfree+0x93>
    release(&kmem.lock);
}
80102011:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102014:	5b                   	pop    %ebx
80102015:	5e                   	pop    %esi
80102016:	5d                   	pop    %ebp
80102017:	c3                   	ret    
    panic("kfree");
80102018:	83 ec 0c             	sub    $0xc,%esp
8010201b:	68 c6 68 10 80       	push   $0x801068c6
80102020:	e8 23 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
80102025:	83 ec 0c             	sub    $0xc,%esp
80102028:	68 40 26 11 80       	push   $0x80112640
8010202d:	e8 ff 1c 00 00       	call   80103d31 <acquire>
80102032:	83 c4 10             	add    $0x10,%esp
80102035:	eb af                	jmp    80101fe6 <kfree+0x42>
    release(&kmem.lock);
80102037:	83 ec 0c             	sub    $0xc,%esp
8010203a:	68 40 26 11 80       	push   $0x80112640
8010203f:	e8 52 1d 00 00       	call   80103d96 <release>
80102044:	83 c4 10             	add    $0x10,%esp
}
80102047:	eb c8                	jmp    80102011 <kfree+0x6d>

80102049 <freerange>:
{
80102049:	55                   	push   %ebp
8010204a:	89 e5                	mov    %esp,%ebp
8010204c:	56                   	push   %esi
8010204d:	53                   	push   %ebx
8010204e:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  p = (char*)PGROUNDUP((uint)vstart);
80102051:	8b 45 08             	mov    0x8(%ebp),%eax
80102054:	05 ff 0f 00 00       	add    $0xfff,%eax
80102059:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
8010205e:	eb 0e                	jmp    8010206e <freerange+0x25>
    kfree(p);
80102060:	83 ec 0c             	sub    $0xc,%esp
80102063:	50                   	push   %eax
80102064:	e8 3b ff ff ff       	call   80101fa4 <kfree>
  for(; p + PGSIZE <= (char*)vend; p += PGSIZE)
80102069:	83 c4 10             	add    $0x10,%esp
8010206c:	89 f0                	mov    %esi,%eax
8010206e:	8d b0 00 10 00 00    	lea    0x1000(%eax),%esi
80102074:	39 de                	cmp    %ebx,%esi
80102076:	76 e8                	jbe    80102060 <freerange+0x17>
}
80102078:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010207b:	5b                   	pop    %ebx
8010207c:	5e                   	pop    %esi
8010207d:	5d                   	pop    %ebp
8010207e:	c3                   	ret    

8010207f <kinit1>:
{
8010207f:	55                   	push   %ebp
80102080:	89 e5                	mov    %esp,%ebp
80102082:	83 ec 10             	sub    $0x10,%esp
  initlock(&kmem.lock, "kmem");
80102085:	68 cc 68 10 80       	push   $0x801068cc
8010208a:	68 40 26 11 80       	push   $0x80112640
8010208f:	e8 61 1b 00 00       	call   80103bf5 <initlock>
  kmem.use_lock = 0;
80102094:	c7 05 74 26 11 80 00 	movl   $0x0,0x80112674
8010209b:	00 00 00 
  freerange(vstart, vend);
8010209e:	83 c4 08             	add    $0x8,%esp
801020a1:	ff 75 0c             	pushl  0xc(%ebp)
801020a4:	ff 75 08             	pushl  0x8(%ebp)
801020a7:	e8 9d ff ff ff       	call   80102049 <freerange>
}
801020ac:	83 c4 10             	add    $0x10,%esp
801020af:	c9                   	leave  
801020b0:	c3                   	ret    

801020b1 <kinit2>:
{
801020b1:	55                   	push   %ebp
801020b2:	89 e5                	mov    %esp,%ebp
801020b4:	83 ec 10             	sub    $0x10,%esp
  freerange(vstart, vend);
801020b7:	ff 75 0c             	pushl  0xc(%ebp)
801020ba:	ff 75 08             	pushl  0x8(%ebp)
801020bd:	e8 87 ff ff ff       	call   80102049 <freerange>
  kmem.use_lock = 1;
801020c2:	c7 05 74 26 11 80 01 	movl   $0x1,0x80112674
801020c9:	00 00 00 
}
801020cc:	83 c4 10             	add    $0x10,%esp
801020cf:	c9                   	leave  
801020d0:	c3                   	ret    

801020d1 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
char*
kalloc(void)
{
801020d1:	55                   	push   %ebp
801020d2:	89 e5                	mov    %esp,%ebp

  //if(kinit2ed) {
   // if(kmem.use_lock)
     // acquire(&kmem.lock);
    
  r = kmem.freelist;  
801020d4:	a1 78 26 11 80       	mov    0x80112678,%eax
  if(r)
801020d9:	85 c0                	test   %eax,%eax
801020db:	74 08                	je     801020e5 <kalloc+0x14>
    kmem.freelist = r->next;
801020dd:	8b 10                	mov    (%eax),%edx
801020df:	89 15 78 26 11 80    	mov    %edx,0x80112678
    
  return (char*)r;
  //}
  
  //return kalloc1(-2);
}
801020e5:	5d                   	pop    %ebp
801020e6:	c3                   	ret    

801020e7 <kalloc1>:
{
801020e7:	55                   	push   %ebp
801020e8:	89 e5                	mov    %esp,%ebp
801020ea:	57                   	push   %edi
801020eb:	56                   	push   %esi
801020ec:	53                   	push   %ebx
801020ed:	83 ec 0c             	sub    $0xc,%esp
801020f0:	8b 75 08             	mov    0x8(%ebp),%esi
  struct run *r = kmem.freelist;
801020f3:	8b 1d 78 26 11 80    	mov    0x80112678,%ebx
  if(kmem.use_lock)
801020f9:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102100:	75 0f                	jne    80102111 <kalloc1+0x2a>
  if(pid == -2) {
80102102:	83 fe fe             	cmp    $0xfffffffe,%esi
80102105:	74 1c                	je     80102123 <kalloc1+0x3c>
  struct run *prer = 0;
80102107:	b9 00 00 00 00       	mov    $0x0,%ecx
8010210c:	e9 8e 00 00 00       	jmp    8010219f <kalloc1+0xb8>
    acquire(&kmem.lock);
80102111:	83 ec 0c             	sub    $0xc,%esp
80102114:	68 40 26 11 80       	push   $0x80112640
80102119:	e8 13 1c 00 00       	call   80103d31 <acquire>
8010211e:	83 c4 10             	add    $0x10,%esp
80102121:	eb df                	jmp    80102102 <kalloc1+0x1b>
    char* ta = kalloc();
80102123:	e8 a9 ff ff ff       	call   801020d1 <kalloc>
80102128:	89 c3                	mov    %eax,%ebx
    int tempframn = ((uint)V2P(ta)) >> 12;
8010212a:	8d 90 00 00 00 80    	lea    -0x80000000(%eax),%edx
80102130:	c1 ea 0c             	shr    $0xc,%edx
    int tempindex = MAX_FNUM - tempframn;
80102133:	b8 ff df 00 00       	mov    $0xdfff,%eax
80102138:	29 d0                	sub    %edx,%eax
    kmem.page_info[tempindex] = -2;
8010213a:	c7 04 85 7c 26 11 80 	movl   $0xfffffffe,-0x7feed984(,%eax,4)
80102141:	fe ff ff ff 
    if(kmem.use_lock)
80102145:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
8010214c:	0f 84 b7 00 00 00    	je     80102209 <kalloc1+0x122>
      release(&kmem.lock);
80102152:	83 ec 0c             	sub    $0xc,%esp
80102155:	68 40 26 11 80       	push   $0x80112640
8010215a:	e8 37 1c 00 00       	call   80103d96 <release>
8010215f:	83 c4 10             	add    $0x10,%esp
80102162:	e9 a2 00 00 00       	jmp    80102209 <kalloc1+0x122>
        kmem.page_info[index] = pid;
80102167:	89 34 95 7c 26 11 80 	mov    %esi,-0x7feed984(,%edx,4)
        if(prer == 0) { // if at head, set r as the head
8010216e:	85 c9                	test   %ecx,%ecx
80102170:	74 09                	je     8010217b <kalloc1+0x94>
          prer->next = r->next;
80102172:	8b 03                	mov    (%ebx),%eax
80102174:	89 01                	mov    %eax,(%ecx)
80102176:	e9 85 00 00 00       	jmp    80102200 <kalloc1+0x119>
          kmem.freelist = r->next;
8010217b:	8b 03                	mov    (%ebx),%eax
8010217d:	a3 78 26 11 80       	mov    %eax,0x80112678
80102182:	eb 7c                	jmp    80102200 <kalloc1+0x119>
                && (kmem.page_info[index+1] == pid || (kmem.page_info[index+1] == -1||kmem.page_info[index+1]==-2))) {
80102184:	bf 00 e0 00 00       	mov    $0xe000,%edi
80102189:	29 c7                	sub    %eax,%edi
8010218b:	8b 04 bd 7c 26 11 80 	mov    -0x7feed984(,%edi,4),%eax
80102192:	39 f0                	cmp    %esi,%eax
80102194:	74 5b                	je     801021f1 <kalloc1+0x10a>
80102196:	83 f8 fe             	cmp    $0xfffffffe,%eax
80102199:	73 56                	jae    801021f1 <kalloc1+0x10a>
		prer = r;
8010219b:	89 d9                	mov    %ebx,%ecx
    r = r->next;
8010219d:	8b 1b                	mov    (%ebx),%ebx
  while(r != 0) {
8010219f:	85 db                	test   %ebx,%ebx
801021a1:	74 5d                	je     80102200 <kalloc1+0x119>
    framen = (uint)(V2P((char*)r)) >> 12;
801021a3:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
801021a9:	c1 e8 0c             	shr    $0xc,%eax
    index = MAX_FNUM - framen;//framen;
801021ac:	ba ff df 00 00       	mov    $0xdfff,%edx
801021b1:	29 c2                	sub    %eax,%edx
    if(kmem.page_info[index] == -1) {
801021b3:	83 3c 95 7c 26 11 80 	cmpl   $0xffffffff,-0x7feed984(,%edx,4)
801021ba:	ff 
801021bb:	75 de                	jne    8010219b <kalloc1+0xb4>
      if(index == 0 && (kmem.page_info[index+1] == -1 || kmem.page_info[index+1] == pid)) {
801021bd:	85 d2                	test   %edx,%edx
801021bf:	75 17                	jne    801021d8 <kalloc1+0xf1>
801021c1:	bf 00 e0 00 00       	mov    $0xe000,%edi
801021c6:	29 c7                	sub    %eax,%edi
801021c8:	8b 3c bd 7c 26 11 80 	mov    -0x7feed984(,%edi,4),%edi
801021cf:	83 ff ff             	cmp    $0xffffffff,%edi
801021d2:	74 93                	je     80102167 <kalloc1+0x80>
801021d4:	39 f7                	cmp    %esi,%edi
801021d6:	74 8f                	je     80102167 <kalloc1+0x80>
      } else if((kmem.page_info[index-1] == pid || (kmem.page_info[index-1] == -1||kmem.page_info[index-1]==-2)) 
801021d8:	bf fe df 00 00       	mov    $0xdffe,%edi
801021dd:	29 c7                	sub    %eax,%edi
801021df:	8b 3c bd 7c 26 11 80 	mov    -0x7feed984(,%edi,4),%edi
801021e6:	39 f7                	cmp    %esi,%edi
801021e8:	74 9a                	je     80102184 <kalloc1+0x9d>
801021ea:	83 ff fe             	cmp    $0xfffffffe,%edi
801021ed:	72 ac                	jb     8010219b <kalloc1+0xb4>
801021ef:	eb 93                	jmp    80102184 <kalloc1+0x9d>
        kmem.page_info[index] = pid;
801021f1:	89 34 95 7c 26 11 80 	mov    %esi,-0x7feed984(,%edx,4)
        if(prer == 0) { // if at head, set r as the head
801021f8:	85 c9                	test   %ecx,%ecx
801021fa:	74 17                	je     80102213 <kalloc1+0x12c>
          prer->next = r->next;
801021fc:	8b 03                	mov    (%ebx),%eax
801021fe:	89 01                	mov    %eax,(%ecx)
  if(kmem.use_lock)
80102200:	83 3d 74 26 11 80 00 	cmpl   $0x0,0x80112674
80102207:	75 13                	jne    8010221c <kalloc1+0x135>
}
80102209:	89 d8                	mov    %ebx,%eax
8010220b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010220e:	5b                   	pop    %ebx
8010220f:	5e                   	pop    %esi
80102210:	5f                   	pop    %edi
80102211:	5d                   	pop    %ebp
80102212:	c3                   	ret    
          kmem.freelist = r->next;
80102213:	8b 03                	mov    (%ebx),%eax
80102215:	a3 78 26 11 80       	mov    %eax,0x80112678
8010221a:	eb e4                	jmp    80102200 <kalloc1+0x119>
    release(&kmem.lock);
8010221c:	83 ec 0c             	sub    $0xc,%esp
8010221f:	68 40 26 11 80       	push   $0x80112640
80102224:	e8 6d 1b 00 00       	call   80103d96 <release>
80102229:	83 c4 10             	add    $0x10,%esp
8010222c:	eb db                	jmp    80102209 <kalloc1+0x122>

8010222e <dump_physmem>:

// used for p5
// by sysproc.c
int
dump_physmem(int *uframes, int *upids, int numframes)
{
8010222e:	55                   	push   %ebp
8010222f:	89 e5                	mov    %esp,%ebp
80102231:	57                   	push   %edi
80102232:	56                   	push   %esi
80102233:	53                   	push   %ebx
80102234:	8b 75 08             	mov    0x8(%ebp),%esi
80102237:	8b 7d 0c             	mov    0xc(%ebp),%edi
  if(uframes == 0 || upids == 0)
8010223a:	85 f6                	test   %esi,%esi
8010223c:	0f 94 c2             	sete   %dl
8010223f:	85 ff                	test   %edi,%edi
80102241:	0f 94 c0             	sete   %al
80102244:	08 c2                	or     %al,%dl
80102246:	75 54                	jne    8010229c <dump_physmem+0x6e>
    return -1;
  //cprintf("dump_physmem in kalloc.c\n");
  int j = 0;
  for(int i = 0; i < MAX_FNUM; i++) {
80102248:	b8 00 00 00 00       	mov    $0x0,%eax
  int j = 0;
8010224d:	ba 00 00 00 00       	mov    $0x0,%edx
80102252:	eb 03                	jmp    80102257 <dump_physmem+0x29>
  for(int i = 0; i < MAX_FNUM; i++) {
80102254:	83 c0 01             	add    $0x1,%eax
80102257:	3d fe df 00 00       	cmp    $0xdffe,%eax
8010225c:	7f 37                	jg     80102295 <dump_physmem+0x67>
    //cprintf("  uframes[%d] = frames[%d](%d);\n", i, i, frames[i]);
    //cprintf("  upids[%d] = pids[%d](%d);\n", i, i, pids[i]);
    if(kmem.page_info[i] != -1) {
8010225e:	83 3c 85 7c 26 11 80 	cmpl   $0xffffffff,-0x7feed984(,%eax,4)
80102265:	ff 
80102266:	74 ec                	je     80102254 <dump_physmem+0x26>
      uframes[j] = MAX_FNUM - i;
80102268:	8d 1c 95 00 00 00 00 	lea    0x0(,%edx,4),%ebx
8010226f:	b9 ff df 00 00       	mov    $0xdfff,%ecx
80102274:	29 c1                	sub    %eax,%ecx
80102276:	89 0c 1e             	mov    %ecx,(%esi,%ebx,1)
      upids[j] = kmem.page_info[i];
80102279:	8b 0c 85 7c 26 11 80 	mov    -0x7feed984(,%eax,4),%ecx
80102280:	89 0c 1f             	mov    %ecx,(%edi,%ebx,1)
      j++;
80102283:	83 c2 01             	add    $0x1,%edx
      if(j >= numframes) 
80102286:	3b 55 10             	cmp    0x10(%ebp),%edx
80102289:	7c c9                	jl     80102254 <dump_physmem+0x26>
        break;
    }
    
  }
  return 0;
8010228b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80102290:	5b                   	pop    %ebx
80102291:	5e                   	pop    %esi
80102292:	5f                   	pop    %edi
80102293:	5d                   	pop    %ebp
80102294:	c3                   	ret    
  return 0;
80102295:	b8 00 00 00 00       	mov    $0x0,%eax
8010229a:	eb f4                	jmp    80102290 <dump_physmem+0x62>
    return -1;
8010229c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801022a1:	eb ed                	jmp    80102290 <dump_physmem+0x62>

801022a3 <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801022a3:	55                   	push   %ebp
801022a4:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022a6:	ba 64 00 00 00       	mov    $0x64,%edx
801022ab:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801022ac:	a8 01                	test   $0x1,%al
801022ae:	0f 84 b5 00 00 00    	je     80102369 <kbdgetc+0xc6>
801022b4:	ba 60 00 00 00       	mov    $0x60,%edx
801022b9:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801022ba:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801022bd:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
801022c3:	74 5c                	je     80102321 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801022c5:	84 c0                	test   %al,%al
801022c7:	78 66                	js     8010232f <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
801022c9:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
801022cf:	f6 c1 40             	test   $0x40,%cl
801022d2:	74 0f                	je     801022e3 <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
801022d4:	83 c8 80             	or     $0xffffff80,%eax
801022d7:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
801022da:	83 e1 bf             	and    $0xffffffbf,%ecx
801022dd:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  }

  shift |= shiftcode[data];
801022e3:	0f b6 8a 00 6a 10 80 	movzbl -0x7fef9600(%edx),%ecx
801022ea:	0b 0d b4 a5 10 80    	or     0x8010a5b4,%ecx
  shift ^= togglecode[data];
801022f0:	0f b6 82 00 69 10 80 	movzbl -0x7fef9700(%edx),%eax
801022f7:	31 c1                	xor    %eax,%ecx
801022f9:	89 0d b4 a5 10 80    	mov    %ecx,0x8010a5b4
  c = charcode[shift & (CTL | SHIFT)][data];
801022ff:	89 c8                	mov    %ecx,%eax
80102301:	83 e0 03             	and    $0x3,%eax
80102304:	8b 04 85 e0 68 10 80 	mov    -0x7fef9720(,%eax,4),%eax
8010230b:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
8010230f:	f6 c1 08             	test   $0x8,%cl
80102312:	74 19                	je     8010232d <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
80102314:	8d 50 9f             	lea    -0x61(%eax),%edx
80102317:	83 fa 19             	cmp    $0x19,%edx
8010231a:	77 40                	ja     8010235c <kbdgetc+0xb9>
      c += 'A' - 'a';
8010231c:	83 e8 20             	sub    $0x20,%eax
8010231f:	eb 0c                	jmp    8010232d <kbdgetc+0x8a>
    shift |= E0ESC;
80102321:	83 0d b4 a5 10 80 40 	orl    $0x40,0x8010a5b4
    return 0;
80102328:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
8010232d:	5d                   	pop    %ebp
8010232e:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
8010232f:	8b 0d b4 a5 10 80    	mov    0x8010a5b4,%ecx
80102335:	f6 c1 40             	test   $0x40,%cl
80102338:	75 05                	jne    8010233f <kbdgetc+0x9c>
8010233a:	89 c2                	mov    %eax,%edx
8010233c:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
8010233f:	0f b6 82 00 6a 10 80 	movzbl -0x7fef9600(%edx),%eax
80102346:	83 c8 40             	or     $0x40,%eax
80102349:	0f b6 c0             	movzbl %al,%eax
8010234c:	f7 d0                	not    %eax
8010234e:	21 c8                	and    %ecx,%eax
80102350:	a3 b4 a5 10 80       	mov    %eax,0x8010a5b4
    return 0;
80102355:	b8 00 00 00 00       	mov    $0x0,%eax
8010235a:	eb d1                	jmp    8010232d <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
8010235c:	8d 50 bf             	lea    -0x41(%eax),%edx
8010235f:	83 fa 19             	cmp    $0x19,%edx
80102362:	77 c9                	ja     8010232d <kbdgetc+0x8a>
      c += 'a' - 'A';
80102364:	83 c0 20             	add    $0x20,%eax
  return c;
80102367:	eb c4                	jmp    8010232d <kbdgetc+0x8a>
    return -1;
80102369:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010236e:	eb bd                	jmp    8010232d <kbdgetc+0x8a>

80102370 <kbdintr>:

void
kbdintr(void)
{
80102370:	55                   	push   %ebp
80102371:	89 e5                	mov    %esp,%ebp
80102373:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
80102376:	68 a3 22 10 80       	push   $0x801022a3
8010237b:	e8 be e3 ff ff       	call   8010073e <consoleintr>
}
80102380:	83 c4 10             	add    $0x10,%esp
80102383:	c9                   	leave  
80102384:	c3                   	ret    

80102385 <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
80102385:	55                   	push   %ebp
80102386:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
80102388:	8b 0d 78 a6 14 80    	mov    0x8014a678,%ecx
8010238e:	8d 04 81             	lea    (%ecx,%eax,4),%eax
80102391:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
80102393:	a1 78 a6 14 80       	mov    0x8014a678,%eax
80102398:	8b 40 20             	mov    0x20(%eax),%eax
}
8010239b:	5d                   	pop    %ebp
8010239c:	c3                   	ret    

8010239d <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
8010239d:	55                   	push   %ebp
8010239e:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023a0:	ba 70 00 00 00       	mov    $0x70,%edx
801023a5:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801023a6:	ba 71 00 00 00       	mov    $0x71,%edx
801023ab:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801023ac:	0f b6 c0             	movzbl %al,%eax
}
801023af:	5d                   	pop    %ebp
801023b0:	c3                   	ret    

801023b1 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801023b1:	55                   	push   %ebp
801023b2:	89 e5                	mov    %esp,%ebp
801023b4:	53                   	push   %ebx
801023b5:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801023b7:	b8 00 00 00 00       	mov    $0x0,%eax
801023bc:	e8 dc ff ff ff       	call   8010239d <cmos_read>
801023c1:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801023c3:	b8 02 00 00 00       	mov    $0x2,%eax
801023c8:	e8 d0 ff ff ff       	call   8010239d <cmos_read>
801023cd:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
801023d0:	b8 04 00 00 00       	mov    $0x4,%eax
801023d5:	e8 c3 ff ff ff       	call   8010239d <cmos_read>
801023da:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
801023dd:	b8 07 00 00 00       	mov    $0x7,%eax
801023e2:	e8 b6 ff ff ff       	call   8010239d <cmos_read>
801023e7:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
801023ea:	b8 08 00 00 00       	mov    $0x8,%eax
801023ef:	e8 a9 ff ff ff       	call   8010239d <cmos_read>
801023f4:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
801023f7:	b8 09 00 00 00       	mov    $0x9,%eax
801023fc:	e8 9c ff ff ff       	call   8010239d <cmos_read>
80102401:	89 43 14             	mov    %eax,0x14(%ebx)
}
80102404:	5b                   	pop    %ebx
80102405:	5d                   	pop    %ebp
80102406:	c3                   	ret    

80102407 <lapicinit>:
  if(!lapic)
80102407:	83 3d 78 a6 14 80 00 	cmpl   $0x0,0x8014a678
8010240e:	0f 84 fb 00 00 00    	je     8010250f <lapicinit+0x108>
{
80102414:	55                   	push   %ebp
80102415:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
80102417:	ba 3f 01 00 00       	mov    $0x13f,%edx
8010241c:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102421:	e8 5f ff ff ff       	call   80102385 <lapicw>
  lapicw(TDCR, X1);
80102426:	ba 0b 00 00 00       	mov    $0xb,%edx
8010242b:	b8 f8 00 00 00       	mov    $0xf8,%eax
80102430:	e8 50 ff ff ff       	call   80102385 <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
80102435:	ba 20 00 02 00       	mov    $0x20020,%edx
8010243a:	b8 c8 00 00 00       	mov    $0xc8,%eax
8010243f:	e8 41 ff ff ff       	call   80102385 <lapicw>
  lapicw(TICR, 10000000);
80102444:	ba 80 96 98 00       	mov    $0x989680,%edx
80102449:	b8 e0 00 00 00       	mov    $0xe0,%eax
8010244e:	e8 32 ff ff ff       	call   80102385 <lapicw>
  lapicw(LINT0, MASKED);
80102453:	ba 00 00 01 00       	mov    $0x10000,%edx
80102458:	b8 d4 00 00 00       	mov    $0xd4,%eax
8010245d:	e8 23 ff ff ff       	call   80102385 <lapicw>
  lapicw(LINT1, MASKED);
80102462:	ba 00 00 01 00       	mov    $0x10000,%edx
80102467:	b8 d8 00 00 00       	mov    $0xd8,%eax
8010246c:	e8 14 ff ff ff       	call   80102385 <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
80102471:	a1 78 a6 14 80       	mov    0x8014a678,%eax
80102476:	8b 40 30             	mov    0x30(%eax),%eax
80102479:	c1 e8 10             	shr    $0x10,%eax
8010247c:	3c 03                	cmp    $0x3,%al
8010247e:	77 7b                	ja     801024fb <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
80102480:	ba 33 00 00 00       	mov    $0x33,%edx
80102485:	b8 dc 00 00 00       	mov    $0xdc,%eax
8010248a:	e8 f6 fe ff ff       	call   80102385 <lapicw>
  lapicw(ESR, 0);
8010248f:	ba 00 00 00 00       	mov    $0x0,%edx
80102494:	b8 a0 00 00 00       	mov    $0xa0,%eax
80102499:	e8 e7 fe ff ff       	call   80102385 <lapicw>
  lapicw(ESR, 0);
8010249e:	ba 00 00 00 00       	mov    $0x0,%edx
801024a3:	b8 a0 00 00 00       	mov    $0xa0,%eax
801024a8:	e8 d8 fe ff ff       	call   80102385 <lapicw>
  lapicw(EOI, 0);
801024ad:	ba 00 00 00 00       	mov    $0x0,%edx
801024b2:	b8 2c 00 00 00       	mov    $0x2c,%eax
801024b7:	e8 c9 fe ff ff       	call   80102385 <lapicw>
  lapicw(ICRHI, 0);
801024bc:	ba 00 00 00 00       	mov    $0x0,%edx
801024c1:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024c6:	e8 ba fe ff ff       	call   80102385 <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
801024cb:	ba 00 85 08 00       	mov    $0x88500,%edx
801024d0:	b8 c0 00 00 00       	mov    $0xc0,%eax
801024d5:	e8 ab fe ff ff       	call   80102385 <lapicw>
  while(lapic[ICRLO] & DELIVS)
801024da:	a1 78 a6 14 80       	mov    0x8014a678,%eax
801024df:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
801024e5:	f6 c4 10             	test   $0x10,%ah
801024e8:	75 f0                	jne    801024da <lapicinit+0xd3>
  lapicw(TPR, 0);
801024ea:	ba 00 00 00 00       	mov    $0x0,%edx
801024ef:	b8 20 00 00 00       	mov    $0x20,%eax
801024f4:	e8 8c fe ff ff       	call   80102385 <lapicw>
}
801024f9:	5d                   	pop    %ebp
801024fa:	c3                   	ret    
    lapicw(PCINT, MASKED);
801024fb:	ba 00 00 01 00       	mov    $0x10000,%edx
80102500:	b8 d0 00 00 00       	mov    $0xd0,%eax
80102505:	e8 7b fe ff ff       	call   80102385 <lapicw>
8010250a:	e9 71 ff ff ff       	jmp    80102480 <lapicinit+0x79>
8010250f:	f3 c3                	repz ret 

80102511 <lapicid>:
{
80102511:	55                   	push   %ebp
80102512:	89 e5                	mov    %esp,%ebp
  if (!lapic)
80102514:	a1 78 a6 14 80       	mov    0x8014a678,%eax
80102519:	85 c0                	test   %eax,%eax
8010251b:	74 08                	je     80102525 <lapicid+0x14>
  return lapic[ID] >> 24;
8010251d:	8b 40 20             	mov    0x20(%eax),%eax
80102520:	c1 e8 18             	shr    $0x18,%eax
}
80102523:	5d                   	pop    %ebp
80102524:	c3                   	ret    
    return 0;
80102525:	b8 00 00 00 00       	mov    $0x0,%eax
8010252a:	eb f7                	jmp    80102523 <lapicid+0x12>

8010252c <lapiceoi>:
  if(lapic)
8010252c:	83 3d 78 a6 14 80 00 	cmpl   $0x0,0x8014a678
80102533:	74 14                	je     80102549 <lapiceoi+0x1d>
{
80102535:	55                   	push   %ebp
80102536:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
80102538:	ba 00 00 00 00       	mov    $0x0,%edx
8010253d:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102542:	e8 3e fe ff ff       	call   80102385 <lapicw>
}
80102547:	5d                   	pop    %ebp
80102548:	c3                   	ret    
80102549:	f3 c3                	repz ret 

8010254b <microdelay>:
{
8010254b:	55                   	push   %ebp
8010254c:	89 e5                	mov    %esp,%ebp
}
8010254e:	5d                   	pop    %ebp
8010254f:	c3                   	ret    

80102550 <lapicstartap>:
{
80102550:	55                   	push   %ebp
80102551:	89 e5                	mov    %esp,%ebp
80102553:	57                   	push   %edi
80102554:	56                   	push   %esi
80102555:	53                   	push   %ebx
80102556:	8b 75 08             	mov    0x8(%ebp),%esi
80102559:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010255c:	b8 0f 00 00 00       	mov    $0xf,%eax
80102561:	ba 70 00 00 00       	mov    $0x70,%edx
80102566:	ee                   	out    %al,(%dx)
80102567:	b8 0a 00 00 00       	mov    $0xa,%eax
8010256c:	ba 71 00 00 00       	mov    $0x71,%edx
80102571:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
80102572:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
80102579:	00 00 
  wrv[1] = addr >> 4;
8010257b:	89 f8                	mov    %edi,%eax
8010257d:	c1 e8 04             	shr    $0x4,%eax
80102580:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
80102586:	c1 e6 18             	shl    $0x18,%esi
80102589:	89 f2                	mov    %esi,%edx
8010258b:	b8 c4 00 00 00       	mov    $0xc4,%eax
80102590:	e8 f0 fd ff ff       	call   80102385 <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
80102595:	ba 00 c5 00 00       	mov    $0xc500,%edx
8010259a:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010259f:	e8 e1 fd ff ff       	call   80102385 <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801025a4:	ba 00 85 00 00       	mov    $0x8500,%edx
801025a9:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025ae:	e8 d2 fd ff ff       	call   80102385 <lapicw>
  for(i = 0; i < 2; i++){
801025b3:	bb 00 00 00 00       	mov    $0x0,%ebx
801025b8:	eb 21                	jmp    801025db <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
801025ba:	89 f2                	mov    %esi,%edx
801025bc:	b8 c4 00 00 00       	mov    $0xc4,%eax
801025c1:	e8 bf fd ff ff       	call   80102385 <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801025c6:	89 fa                	mov    %edi,%edx
801025c8:	c1 ea 0c             	shr    $0xc,%edx
801025cb:	80 ce 06             	or     $0x6,%dh
801025ce:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025d3:	e8 ad fd ff ff       	call   80102385 <lapicw>
  for(i = 0; i < 2; i++){
801025d8:	83 c3 01             	add    $0x1,%ebx
801025db:	83 fb 01             	cmp    $0x1,%ebx
801025de:	7e da                	jle    801025ba <lapicstartap+0x6a>
}
801025e0:	5b                   	pop    %ebx
801025e1:	5e                   	pop    %esi
801025e2:	5f                   	pop    %edi
801025e3:	5d                   	pop    %ebp
801025e4:	c3                   	ret    

801025e5 <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
801025e5:	55                   	push   %ebp
801025e6:	89 e5                	mov    %esp,%ebp
801025e8:	57                   	push   %edi
801025e9:	56                   	push   %esi
801025ea:	53                   	push   %ebx
801025eb:	83 ec 3c             	sub    $0x3c,%esp
801025ee:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
801025f1:	b8 0b 00 00 00       	mov    $0xb,%eax
801025f6:	e8 a2 fd ff ff       	call   8010239d <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
801025fb:	83 e0 04             	and    $0x4,%eax
801025fe:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102600:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102603:	e8 a9 fd ff ff       	call   801023b1 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
80102608:	b8 0a 00 00 00       	mov    $0xa,%eax
8010260d:	e8 8b fd ff ff       	call   8010239d <cmos_read>
80102612:	a8 80                	test   $0x80,%al
80102614:	75 ea                	jne    80102600 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
80102616:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102619:	89 d8                	mov    %ebx,%eax
8010261b:	e8 91 fd ff ff       	call   801023b1 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102620:	83 ec 04             	sub    $0x4,%esp
80102623:	6a 18                	push   $0x18
80102625:	53                   	push   %ebx
80102626:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102629:	50                   	push   %eax
8010262a:	e8 f4 17 00 00       	call   80103e23 <memcmp>
8010262f:	83 c4 10             	add    $0x10,%esp
80102632:	85 c0                	test   %eax,%eax
80102634:	75 ca                	jne    80102600 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
80102636:	85 ff                	test   %edi,%edi
80102638:	0f 85 84 00 00 00    	jne    801026c2 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
8010263e:	8b 55 d0             	mov    -0x30(%ebp),%edx
80102641:	89 d0                	mov    %edx,%eax
80102643:	c1 e8 04             	shr    $0x4,%eax
80102646:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102649:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010264c:	83 e2 0f             	and    $0xf,%edx
8010264f:	01 d0                	add    %edx,%eax
80102651:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
80102654:	8b 55 d4             	mov    -0x2c(%ebp),%edx
80102657:	89 d0                	mov    %edx,%eax
80102659:	c1 e8 04             	shr    $0x4,%eax
8010265c:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010265f:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102662:	83 e2 0f             	and    $0xf,%edx
80102665:	01 d0                	add    %edx,%eax
80102667:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
8010266a:	8b 55 d8             	mov    -0x28(%ebp),%edx
8010266d:	89 d0                	mov    %edx,%eax
8010266f:	c1 e8 04             	shr    $0x4,%eax
80102672:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102675:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102678:	83 e2 0f             	and    $0xf,%edx
8010267b:	01 d0                	add    %edx,%eax
8010267d:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
80102680:	8b 55 dc             	mov    -0x24(%ebp),%edx
80102683:	89 d0                	mov    %edx,%eax
80102685:	c1 e8 04             	shr    $0x4,%eax
80102688:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010268b:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
8010268e:	83 e2 0f             	and    $0xf,%edx
80102691:	01 d0                	add    %edx,%eax
80102693:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
80102696:	8b 55 e0             	mov    -0x20(%ebp),%edx
80102699:	89 d0                	mov    %edx,%eax
8010269b:	c1 e8 04             	shr    $0x4,%eax
8010269e:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026a1:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026a4:	83 e2 0f             	and    $0xf,%edx
801026a7:	01 d0                	add    %edx,%eax
801026a9:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801026ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801026af:	89 d0                	mov    %edx,%eax
801026b1:	c1 e8 04             	shr    $0x4,%eax
801026b4:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026b7:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026ba:	83 e2 0f             	and    $0xf,%edx
801026bd:	01 d0                	add    %edx,%eax
801026bf:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
801026c2:	8b 45 d0             	mov    -0x30(%ebp),%eax
801026c5:	89 06                	mov    %eax,(%esi)
801026c7:	8b 45 d4             	mov    -0x2c(%ebp),%eax
801026ca:	89 46 04             	mov    %eax,0x4(%esi)
801026cd:	8b 45 d8             	mov    -0x28(%ebp),%eax
801026d0:	89 46 08             	mov    %eax,0x8(%esi)
801026d3:	8b 45 dc             	mov    -0x24(%ebp),%eax
801026d6:	89 46 0c             	mov    %eax,0xc(%esi)
801026d9:	8b 45 e0             	mov    -0x20(%ebp),%eax
801026dc:	89 46 10             	mov    %eax,0x10(%esi)
801026df:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801026e2:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
801026e5:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
801026ec:	8d 65 f4             	lea    -0xc(%ebp),%esp
801026ef:	5b                   	pop    %ebx
801026f0:	5e                   	pop    %esi
801026f1:	5f                   	pop    %edi
801026f2:	5d                   	pop    %ebp
801026f3:	c3                   	ret    

801026f4 <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
801026f4:	55                   	push   %ebp
801026f5:	89 e5                	mov    %esp,%ebp
801026f7:	53                   	push   %ebx
801026f8:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801026fb:	ff 35 b4 a6 14 80    	pushl  0x8014a6b4
80102701:	ff 35 c4 a6 14 80    	pushl  0x8014a6c4
80102707:	e8 60 da ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
8010270c:	8b 58 5c             	mov    0x5c(%eax),%ebx
8010270f:	89 1d c8 a6 14 80    	mov    %ebx,0x8014a6c8
  for (i = 0; i < log.lh.n; i++) {
80102715:	83 c4 10             	add    $0x10,%esp
80102718:	ba 00 00 00 00       	mov    $0x0,%edx
8010271d:	eb 0e                	jmp    8010272d <read_head+0x39>
    log.lh.block[i] = lh->block[i];
8010271f:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
80102723:	89 0c 95 cc a6 14 80 	mov    %ecx,-0x7feb5934(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
8010272a:	83 c2 01             	add    $0x1,%edx
8010272d:	39 d3                	cmp    %edx,%ebx
8010272f:	7f ee                	jg     8010271f <read_head+0x2b>
  }
  brelse(buf);
80102731:	83 ec 0c             	sub    $0xc,%esp
80102734:	50                   	push   %eax
80102735:	e8 9b da ff ff       	call   801001d5 <brelse>
}
8010273a:	83 c4 10             	add    $0x10,%esp
8010273d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102740:	c9                   	leave  
80102741:	c3                   	ret    

80102742 <install_trans>:
{
80102742:	55                   	push   %ebp
80102743:	89 e5                	mov    %esp,%ebp
80102745:	57                   	push   %edi
80102746:	56                   	push   %esi
80102747:	53                   	push   %ebx
80102748:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
8010274b:	bb 00 00 00 00       	mov    $0x0,%ebx
80102750:	eb 66                	jmp    801027b8 <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102752:	89 d8                	mov    %ebx,%eax
80102754:	03 05 b4 a6 14 80    	add    0x8014a6b4,%eax
8010275a:	83 c0 01             	add    $0x1,%eax
8010275d:	83 ec 08             	sub    $0x8,%esp
80102760:	50                   	push   %eax
80102761:	ff 35 c4 a6 14 80    	pushl  0x8014a6c4
80102767:	e8 00 da ff ff       	call   8010016c <bread>
8010276c:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
8010276e:	83 c4 08             	add    $0x8,%esp
80102771:	ff 34 9d cc a6 14 80 	pushl  -0x7feb5934(,%ebx,4)
80102778:	ff 35 c4 a6 14 80    	pushl  0x8014a6c4
8010277e:	e8 e9 d9 ff ff       	call   8010016c <bread>
80102783:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
80102785:	8d 57 5c             	lea    0x5c(%edi),%edx
80102788:	8d 40 5c             	lea    0x5c(%eax),%eax
8010278b:	83 c4 0c             	add    $0xc,%esp
8010278e:	68 00 02 00 00       	push   $0x200
80102793:	52                   	push   %edx
80102794:	50                   	push   %eax
80102795:	e8 be 16 00 00       	call   80103e58 <memmove>
    bwrite(dbuf);  // write dst to disk
8010279a:	89 34 24             	mov    %esi,(%esp)
8010279d:	e8 f8 d9 ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
801027a2:	89 3c 24             	mov    %edi,(%esp)
801027a5:	e8 2b da ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
801027aa:	89 34 24             	mov    %esi,(%esp)
801027ad:	e8 23 da ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801027b2:	83 c3 01             	add    $0x1,%ebx
801027b5:	83 c4 10             	add    $0x10,%esp
801027b8:	39 1d c8 a6 14 80    	cmp    %ebx,0x8014a6c8
801027be:	7f 92                	jg     80102752 <install_trans+0x10>
}
801027c0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801027c3:	5b                   	pop    %ebx
801027c4:	5e                   	pop    %esi
801027c5:	5f                   	pop    %edi
801027c6:	5d                   	pop    %ebp
801027c7:	c3                   	ret    

801027c8 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801027c8:	55                   	push   %ebp
801027c9:	89 e5                	mov    %esp,%ebp
801027cb:	53                   	push   %ebx
801027cc:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
801027cf:	ff 35 b4 a6 14 80    	pushl  0x8014a6b4
801027d5:	ff 35 c4 a6 14 80    	pushl  0x8014a6c4
801027db:	e8 8c d9 ff ff       	call   8010016c <bread>
801027e0:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
801027e2:	8b 0d c8 a6 14 80    	mov    0x8014a6c8,%ecx
801027e8:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
801027eb:	83 c4 10             	add    $0x10,%esp
801027ee:	b8 00 00 00 00       	mov    $0x0,%eax
801027f3:	eb 0e                	jmp    80102803 <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
801027f5:	8b 14 85 cc a6 14 80 	mov    -0x7feb5934(,%eax,4),%edx
801027fc:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
80102800:	83 c0 01             	add    $0x1,%eax
80102803:	39 c1                	cmp    %eax,%ecx
80102805:	7f ee                	jg     801027f5 <write_head+0x2d>
  }
  bwrite(buf);
80102807:	83 ec 0c             	sub    $0xc,%esp
8010280a:	53                   	push   %ebx
8010280b:	e8 8a d9 ff ff       	call   8010019a <bwrite>
  brelse(buf);
80102810:	89 1c 24             	mov    %ebx,(%esp)
80102813:	e8 bd d9 ff ff       	call   801001d5 <brelse>
}
80102818:	83 c4 10             	add    $0x10,%esp
8010281b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010281e:	c9                   	leave  
8010281f:	c3                   	ret    

80102820 <recover_from_log>:

static void
recover_from_log(void)
{
80102820:	55                   	push   %ebp
80102821:	89 e5                	mov    %esp,%ebp
80102823:	83 ec 08             	sub    $0x8,%esp
  read_head();
80102826:	e8 c9 fe ff ff       	call   801026f4 <read_head>
  install_trans(); // if committed, copy from log to disk
8010282b:	e8 12 ff ff ff       	call   80102742 <install_trans>
  log.lh.n = 0;
80102830:	c7 05 c8 a6 14 80 00 	movl   $0x0,0x8014a6c8
80102837:	00 00 00 
  write_head(); // clear the log
8010283a:	e8 89 ff ff ff       	call   801027c8 <write_head>
}
8010283f:	c9                   	leave  
80102840:	c3                   	ret    

80102841 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102841:	55                   	push   %ebp
80102842:	89 e5                	mov    %esp,%ebp
80102844:	57                   	push   %edi
80102845:	56                   	push   %esi
80102846:	53                   	push   %ebx
80102847:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
8010284a:	bb 00 00 00 00       	mov    $0x0,%ebx
8010284f:	eb 66                	jmp    801028b7 <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102851:	89 d8                	mov    %ebx,%eax
80102853:	03 05 b4 a6 14 80    	add    0x8014a6b4,%eax
80102859:	83 c0 01             	add    $0x1,%eax
8010285c:	83 ec 08             	sub    $0x8,%esp
8010285f:	50                   	push   %eax
80102860:	ff 35 c4 a6 14 80    	pushl  0x8014a6c4
80102866:	e8 01 d9 ff ff       	call   8010016c <bread>
8010286b:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
8010286d:	83 c4 08             	add    $0x8,%esp
80102870:	ff 34 9d cc a6 14 80 	pushl  -0x7feb5934(,%ebx,4)
80102877:	ff 35 c4 a6 14 80    	pushl  0x8014a6c4
8010287d:	e8 ea d8 ff ff       	call   8010016c <bread>
80102882:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
80102884:	8d 50 5c             	lea    0x5c(%eax),%edx
80102887:	8d 46 5c             	lea    0x5c(%esi),%eax
8010288a:	83 c4 0c             	add    $0xc,%esp
8010288d:	68 00 02 00 00       	push   $0x200
80102892:	52                   	push   %edx
80102893:	50                   	push   %eax
80102894:	e8 bf 15 00 00       	call   80103e58 <memmove>
    bwrite(to);  // write the log
80102899:	89 34 24             	mov    %esi,(%esp)
8010289c:	e8 f9 d8 ff ff       	call   8010019a <bwrite>
    brelse(from);
801028a1:	89 3c 24             	mov    %edi,(%esp)
801028a4:	e8 2c d9 ff ff       	call   801001d5 <brelse>
    brelse(to);
801028a9:	89 34 24             	mov    %esi,(%esp)
801028ac:	e8 24 d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801028b1:	83 c3 01             	add    $0x1,%ebx
801028b4:	83 c4 10             	add    $0x10,%esp
801028b7:	39 1d c8 a6 14 80    	cmp    %ebx,0x8014a6c8
801028bd:	7f 92                	jg     80102851 <write_log+0x10>
  }
}
801028bf:	8d 65 f4             	lea    -0xc(%ebp),%esp
801028c2:	5b                   	pop    %ebx
801028c3:	5e                   	pop    %esi
801028c4:	5f                   	pop    %edi
801028c5:	5d                   	pop    %ebp
801028c6:	c3                   	ret    

801028c7 <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
801028c7:	83 3d c8 a6 14 80 00 	cmpl   $0x0,0x8014a6c8
801028ce:	7e 26                	jle    801028f6 <commit+0x2f>
{
801028d0:	55                   	push   %ebp
801028d1:	89 e5                	mov    %esp,%ebp
801028d3:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
801028d6:	e8 66 ff ff ff       	call   80102841 <write_log>
    write_head();    // Write header to disk -- the real commit
801028db:	e8 e8 fe ff ff       	call   801027c8 <write_head>
    install_trans(); // Now install writes to home locations
801028e0:	e8 5d fe ff ff       	call   80102742 <install_trans>
    log.lh.n = 0;
801028e5:	c7 05 c8 a6 14 80 00 	movl   $0x0,0x8014a6c8
801028ec:	00 00 00 
    write_head();    // Erase the transaction from the log
801028ef:	e8 d4 fe ff ff       	call   801027c8 <write_head>
  }
}
801028f4:	c9                   	leave  
801028f5:	c3                   	ret    
801028f6:	f3 c3                	repz ret 

801028f8 <initlog>:
{
801028f8:	55                   	push   %ebp
801028f9:	89 e5                	mov    %esp,%ebp
801028fb:	53                   	push   %ebx
801028fc:	83 ec 2c             	sub    $0x2c,%esp
801028ff:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102902:	68 00 6b 10 80       	push   $0x80106b00
80102907:	68 80 a6 14 80       	push   $0x8014a680
8010290c:	e8 e4 12 00 00       	call   80103bf5 <initlock>
  readsb(dev, &sb);
80102911:	83 c4 08             	add    $0x8,%esp
80102914:	8d 45 dc             	lea    -0x24(%ebp),%eax
80102917:	50                   	push   %eax
80102918:	53                   	push   %ebx
80102919:	e8 18 e9 ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
8010291e:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102921:	a3 b4 a6 14 80       	mov    %eax,0x8014a6b4
  log.size = sb.nlog;
80102926:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102929:	a3 b8 a6 14 80       	mov    %eax,0x8014a6b8
  log.dev = dev;
8010292e:	89 1d c4 a6 14 80    	mov    %ebx,0x8014a6c4
  recover_from_log();
80102934:	e8 e7 fe ff ff       	call   80102820 <recover_from_log>
}
80102939:	83 c4 10             	add    $0x10,%esp
8010293c:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010293f:	c9                   	leave  
80102940:	c3                   	ret    

80102941 <begin_op>:
{
80102941:	55                   	push   %ebp
80102942:	89 e5                	mov    %esp,%ebp
80102944:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
80102947:	68 80 a6 14 80       	push   $0x8014a680
8010294c:	e8 e0 13 00 00       	call   80103d31 <acquire>
80102951:	83 c4 10             	add    $0x10,%esp
80102954:	eb 15                	jmp    8010296b <begin_op+0x2a>
      sleep(&log, &log.lock);
80102956:	83 ec 08             	sub    $0x8,%esp
80102959:	68 80 a6 14 80       	push   $0x8014a680
8010295e:	68 80 a6 14 80       	push   $0x8014a680
80102963:	e8 ce 0e 00 00       	call   80103836 <sleep>
80102968:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
8010296b:	83 3d c0 a6 14 80 00 	cmpl   $0x0,0x8014a6c0
80102972:	75 e2                	jne    80102956 <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
80102974:	a1 bc a6 14 80       	mov    0x8014a6bc,%eax
80102979:	83 c0 01             	add    $0x1,%eax
8010297c:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
8010297f:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
80102982:	03 15 c8 a6 14 80    	add    0x8014a6c8,%edx
80102988:	83 fa 1e             	cmp    $0x1e,%edx
8010298b:	7e 17                	jle    801029a4 <begin_op+0x63>
      sleep(&log, &log.lock);
8010298d:	83 ec 08             	sub    $0x8,%esp
80102990:	68 80 a6 14 80       	push   $0x8014a680
80102995:	68 80 a6 14 80       	push   $0x8014a680
8010299a:	e8 97 0e 00 00       	call   80103836 <sleep>
8010299f:	83 c4 10             	add    $0x10,%esp
801029a2:	eb c7                	jmp    8010296b <begin_op+0x2a>
      log.outstanding += 1;
801029a4:	a3 bc a6 14 80       	mov    %eax,0x8014a6bc
      release(&log.lock);
801029a9:	83 ec 0c             	sub    $0xc,%esp
801029ac:	68 80 a6 14 80       	push   $0x8014a680
801029b1:	e8 e0 13 00 00       	call   80103d96 <release>
}
801029b6:	83 c4 10             	add    $0x10,%esp
801029b9:	c9                   	leave  
801029ba:	c3                   	ret    

801029bb <end_op>:
{
801029bb:	55                   	push   %ebp
801029bc:	89 e5                	mov    %esp,%ebp
801029be:	53                   	push   %ebx
801029bf:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
801029c2:	68 80 a6 14 80       	push   $0x8014a680
801029c7:	e8 65 13 00 00       	call   80103d31 <acquire>
  log.outstanding -= 1;
801029cc:	a1 bc a6 14 80       	mov    0x8014a6bc,%eax
801029d1:	83 e8 01             	sub    $0x1,%eax
801029d4:	a3 bc a6 14 80       	mov    %eax,0x8014a6bc
  if(log.committing)
801029d9:	8b 1d c0 a6 14 80    	mov    0x8014a6c0,%ebx
801029df:	83 c4 10             	add    $0x10,%esp
801029e2:	85 db                	test   %ebx,%ebx
801029e4:	75 2c                	jne    80102a12 <end_op+0x57>
  if(log.outstanding == 0){
801029e6:	85 c0                	test   %eax,%eax
801029e8:	75 35                	jne    80102a1f <end_op+0x64>
    log.committing = 1;
801029ea:	c7 05 c0 a6 14 80 01 	movl   $0x1,0x8014a6c0
801029f1:	00 00 00 
    do_commit = 1;
801029f4:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
801029f9:	83 ec 0c             	sub    $0xc,%esp
801029fc:	68 80 a6 14 80       	push   $0x8014a680
80102a01:	e8 90 13 00 00       	call   80103d96 <release>
  if(do_commit){
80102a06:	83 c4 10             	add    $0x10,%esp
80102a09:	85 db                	test   %ebx,%ebx
80102a0b:	75 24                	jne    80102a31 <end_op+0x76>
}
80102a0d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a10:	c9                   	leave  
80102a11:	c3                   	ret    
    panic("log.committing");
80102a12:	83 ec 0c             	sub    $0xc,%esp
80102a15:	68 04 6b 10 80       	push   $0x80106b04
80102a1a:	e8 29 d9 ff ff       	call   80100348 <panic>
    wakeup(&log);
80102a1f:	83 ec 0c             	sub    $0xc,%esp
80102a22:	68 80 a6 14 80       	push   $0x8014a680
80102a27:	e8 6f 0f 00 00       	call   8010399b <wakeup>
80102a2c:	83 c4 10             	add    $0x10,%esp
80102a2f:	eb c8                	jmp    801029f9 <end_op+0x3e>
    commit();
80102a31:	e8 91 fe ff ff       	call   801028c7 <commit>
    acquire(&log.lock);
80102a36:	83 ec 0c             	sub    $0xc,%esp
80102a39:	68 80 a6 14 80       	push   $0x8014a680
80102a3e:	e8 ee 12 00 00       	call   80103d31 <acquire>
    log.committing = 0;
80102a43:	c7 05 c0 a6 14 80 00 	movl   $0x0,0x8014a6c0
80102a4a:	00 00 00 
    wakeup(&log);
80102a4d:	c7 04 24 80 a6 14 80 	movl   $0x8014a680,(%esp)
80102a54:	e8 42 0f 00 00       	call   8010399b <wakeup>
    release(&log.lock);
80102a59:	c7 04 24 80 a6 14 80 	movl   $0x8014a680,(%esp)
80102a60:	e8 31 13 00 00       	call   80103d96 <release>
80102a65:	83 c4 10             	add    $0x10,%esp
}
80102a68:	eb a3                	jmp    80102a0d <end_op+0x52>

80102a6a <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102a6a:	55                   	push   %ebp
80102a6b:	89 e5                	mov    %esp,%ebp
80102a6d:	53                   	push   %ebx
80102a6e:	83 ec 04             	sub    $0x4,%esp
80102a71:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102a74:	8b 15 c8 a6 14 80    	mov    0x8014a6c8,%edx
80102a7a:	83 fa 1d             	cmp    $0x1d,%edx
80102a7d:	7f 45                	jg     80102ac4 <log_write+0x5a>
80102a7f:	a1 b8 a6 14 80       	mov    0x8014a6b8,%eax
80102a84:	83 e8 01             	sub    $0x1,%eax
80102a87:	39 c2                	cmp    %eax,%edx
80102a89:	7d 39                	jge    80102ac4 <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102a8b:	83 3d bc a6 14 80 00 	cmpl   $0x0,0x8014a6bc
80102a92:	7e 3d                	jle    80102ad1 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102a94:	83 ec 0c             	sub    $0xc,%esp
80102a97:	68 80 a6 14 80       	push   $0x8014a680
80102a9c:	e8 90 12 00 00       	call   80103d31 <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102aa1:	83 c4 10             	add    $0x10,%esp
80102aa4:	b8 00 00 00 00       	mov    $0x0,%eax
80102aa9:	8b 15 c8 a6 14 80    	mov    0x8014a6c8,%edx
80102aaf:	39 c2                	cmp    %eax,%edx
80102ab1:	7e 2b                	jle    80102ade <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102ab3:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102ab6:	39 0c 85 cc a6 14 80 	cmp    %ecx,-0x7feb5934(,%eax,4)
80102abd:	74 1f                	je     80102ade <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102abf:	83 c0 01             	add    $0x1,%eax
80102ac2:	eb e5                	jmp    80102aa9 <log_write+0x3f>
    panic("too big a transaction");
80102ac4:	83 ec 0c             	sub    $0xc,%esp
80102ac7:	68 13 6b 10 80       	push   $0x80106b13
80102acc:	e8 77 d8 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102ad1:	83 ec 0c             	sub    $0xc,%esp
80102ad4:	68 29 6b 10 80       	push   $0x80106b29
80102ad9:	e8 6a d8 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102ade:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102ae1:	89 0c 85 cc a6 14 80 	mov    %ecx,-0x7feb5934(,%eax,4)
  if (i == log.lh.n)
80102ae8:	39 c2                	cmp    %eax,%edx
80102aea:	74 18                	je     80102b04 <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102aec:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102aef:	83 ec 0c             	sub    $0xc,%esp
80102af2:	68 80 a6 14 80       	push   $0x8014a680
80102af7:	e8 9a 12 00 00       	call   80103d96 <release>
}
80102afc:	83 c4 10             	add    $0x10,%esp
80102aff:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b02:	c9                   	leave  
80102b03:	c3                   	ret    
    log.lh.n++;
80102b04:	83 c2 01             	add    $0x1,%edx
80102b07:	89 15 c8 a6 14 80    	mov    %edx,0x8014a6c8
80102b0d:	eb dd                	jmp    80102aec <log_write+0x82>

80102b0f <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102b0f:	55                   	push   %ebp
80102b10:	89 e5                	mov    %esp,%ebp
80102b12:	53                   	push   %ebx
80102b13:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102b16:	68 8a 00 00 00       	push   $0x8a
80102b1b:	68 8c a4 10 80       	push   $0x8010a48c
80102b20:	68 00 70 00 80       	push   $0x80007000
80102b25:	e8 2e 13 00 00       	call   80103e58 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102b2a:	83 c4 10             	add    $0x10,%esp
80102b2d:	bb 80 a7 14 80       	mov    $0x8014a780,%ebx
80102b32:	eb 06                	jmp    80102b3a <startothers+0x2b>
80102b34:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102b3a:	69 05 00 ad 14 80 b0 	imul   $0xb0,0x8014ad00,%eax
80102b41:	00 00 00 
80102b44:	05 80 a7 14 80       	add    $0x8014a780,%eax
80102b49:	39 d8                	cmp    %ebx,%eax
80102b4b:	76 4c                	jbe    80102b99 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
80102b4d:	e8 c6 07 00 00       	call   80103318 <mycpu>
80102b52:	39 d8                	cmp    %ebx,%eax
80102b54:	74 de                	je     80102b34 <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102b56:	e8 76 f5 ff ff       	call   801020d1 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102b5b:	05 00 10 00 00       	add    $0x1000,%eax
80102b60:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102b65:	c7 05 f8 6f 00 80 dd 	movl   $0x80102bdd,0x80006ff8
80102b6c:	2b 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102b6f:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102b76:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102b79:	83 ec 08             	sub    $0x8,%esp
80102b7c:	68 00 70 00 00       	push   $0x7000
80102b81:	0f b6 03             	movzbl (%ebx),%eax
80102b84:	50                   	push   %eax
80102b85:	e8 c6 f9 ff ff       	call   80102550 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102b8a:	83 c4 10             	add    $0x10,%esp
80102b8d:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102b93:	85 c0                	test   %eax,%eax
80102b95:	74 f6                	je     80102b8d <startothers+0x7e>
80102b97:	eb 9b                	jmp    80102b34 <startothers+0x25>
      ;
  }
}
80102b99:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b9c:	c9                   	leave  
80102b9d:	c3                   	ret    

80102b9e <mpmain>:
{
80102b9e:	55                   	push   %ebp
80102b9f:	89 e5                	mov    %esp,%ebp
80102ba1:	53                   	push   %ebx
80102ba2:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102ba5:	e8 ca 07 00 00       	call   80103374 <cpuid>
80102baa:	89 c3                	mov    %eax,%ebx
80102bac:	e8 c3 07 00 00       	call   80103374 <cpuid>
80102bb1:	83 ec 04             	sub    $0x4,%esp
80102bb4:	53                   	push   %ebx
80102bb5:	50                   	push   %eax
80102bb6:	68 44 6b 10 80       	push   $0x80106b44
80102bbb:	e8 4b da ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102bc0:	e8 ea 23 00 00       	call   80104faf <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102bc5:	e8 4e 07 00 00       	call   80103318 <mycpu>
80102bca:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102bcc:	b8 01 00 00 00       	mov    $0x1,%eax
80102bd1:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102bd8:	e8 34 0a 00 00       	call   80103611 <scheduler>

80102bdd <mpenter>:
{
80102bdd:	55                   	push   %ebp
80102bde:	89 e5                	mov    %esp,%ebp
80102be0:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102be3:	e8 d8 33 00 00       	call   80105fc0 <switchkvm>
  seginit();
80102be8:	e8 87 32 00 00       	call   80105e74 <seginit>
  lapicinit();
80102bed:	e8 15 f8 ff ff       	call   80102407 <lapicinit>
  mpmain();
80102bf2:	e8 a7 ff ff ff       	call   80102b9e <mpmain>

80102bf7 <main>:
{
80102bf7:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102bfb:	83 e4 f0             	and    $0xfffffff0,%esp
80102bfe:	ff 71 fc             	pushl  -0x4(%ecx)
80102c01:	55                   	push   %ebp
80102c02:	89 e5                	mov    %esp,%ebp
80102c04:	51                   	push   %ecx
80102c05:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102c08:	68 00 00 40 80       	push   $0x80400000
80102c0d:	68 a8 d4 14 80       	push   $0x8014d4a8
80102c12:	e8 68 f4 ff ff       	call   8010207f <kinit1>
  kvmalloc();      // kernel page table
80102c17:	e8 4c 38 00 00       	call   80106468 <kvmalloc>
  mpinit();        // detect other processors
80102c1c:	e8 c9 01 00 00       	call   80102dea <mpinit>
  lapicinit();     // interrupt controller
80102c21:	e8 e1 f7 ff ff       	call   80102407 <lapicinit>
  seginit();       // segment descriptors
80102c26:	e8 49 32 00 00       	call   80105e74 <seginit>
  picinit();       // disable pic
80102c2b:	e8 82 02 00 00       	call   80102eb2 <picinit>
  ioapicinit();    // another interrupt controller
80102c30:	e8 c5 f2 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102c35:	e8 54 dc ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102c3a:	e8 1e 26 00 00       	call   8010525d <uartinit>
  pinit();         // process table
80102c3f:	e8 ba 06 00 00       	call   801032fe <pinit>
  tvinit();        // trap vectors
80102c44:	e8 b5 22 00 00       	call   80104efe <tvinit>
  binit();         // buffer cache
80102c49:	e8 a6 d4 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102c4e:	e8 c0 df ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102c53:	e8 a8 f0 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102c58:	e8 b2 fe ff ff       	call   80102b0f <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102c5d:	83 c4 08             	add    $0x8,%esp
80102c60:	68 00 00 00 8e       	push   $0x8e000000
80102c65:	68 00 00 40 80       	push   $0x80400000
80102c6a:	e8 42 f4 ff ff       	call   801020b1 <kinit2>
  userinit();      // first user process
80102c6f:	e8 3f 07 00 00       	call   801033b3 <userinit>
  mpmain();        // finish this processor's setup
80102c74:	e8 25 ff ff ff       	call   80102b9e <mpmain>

80102c79 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102c79:	55                   	push   %ebp
80102c7a:	89 e5                	mov    %esp,%ebp
80102c7c:	56                   	push   %esi
80102c7d:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102c7e:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102c83:	b9 00 00 00 00       	mov    $0x0,%ecx
80102c88:	eb 09                	jmp    80102c93 <sum+0x1a>
    sum += addr[i];
80102c8a:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102c8e:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102c90:	83 c1 01             	add    $0x1,%ecx
80102c93:	39 d1                	cmp    %edx,%ecx
80102c95:	7c f3                	jl     80102c8a <sum+0x11>
  return sum;
}
80102c97:	89 d8                	mov    %ebx,%eax
80102c99:	5b                   	pop    %ebx
80102c9a:	5e                   	pop    %esi
80102c9b:	5d                   	pop    %ebp
80102c9c:	c3                   	ret    

80102c9d <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102c9d:	55                   	push   %ebp
80102c9e:	89 e5                	mov    %esp,%ebp
80102ca0:	56                   	push   %esi
80102ca1:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102ca2:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102ca8:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102caa:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102cac:	eb 03                	jmp    80102cb1 <mpsearch1+0x14>
80102cae:	83 c3 10             	add    $0x10,%ebx
80102cb1:	39 f3                	cmp    %esi,%ebx
80102cb3:	73 29                	jae    80102cde <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102cb5:	83 ec 04             	sub    $0x4,%esp
80102cb8:	6a 04                	push   $0x4
80102cba:	68 58 6b 10 80       	push   $0x80106b58
80102cbf:	53                   	push   %ebx
80102cc0:	e8 5e 11 00 00       	call   80103e23 <memcmp>
80102cc5:	83 c4 10             	add    $0x10,%esp
80102cc8:	85 c0                	test   %eax,%eax
80102cca:	75 e2                	jne    80102cae <mpsearch1+0x11>
80102ccc:	ba 10 00 00 00       	mov    $0x10,%edx
80102cd1:	89 d8                	mov    %ebx,%eax
80102cd3:	e8 a1 ff ff ff       	call   80102c79 <sum>
80102cd8:	84 c0                	test   %al,%al
80102cda:	75 d2                	jne    80102cae <mpsearch1+0x11>
80102cdc:	eb 05                	jmp    80102ce3 <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102cde:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102ce3:	89 d8                	mov    %ebx,%eax
80102ce5:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102ce8:	5b                   	pop    %ebx
80102ce9:	5e                   	pop    %esi
80102cea:	5d                   	pop    %ebp
80102ceb:	c3                   	ret    

80102cec <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102cec:	55                   	push   %ebp
80102ced:	89 e5                	mov    %esp,%ebp
80102cef:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102cf2:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102cf9:	c1 e0 08             	shl    $0x8,%eax
80102cfc:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102d03:	09 d0                	or     %edx,%eax
80102d05:	c1 e0 04             	shl    $0x4,%eax
80102d08:	85 c0                	test   %eax,%eax
80102d0a:	74 1f                	je     80102d2b <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102d0c:	ba 00 04 00 00       	mov    $0x400,%edx
80102d11:	e8 87 ff ff ff       	call   80102c9d <mpsearch1>
80102d16:	85 c0                	test   %eax,%eax
80102d18:	75 0f                	jne    80102d29 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102d1a:	ba 00 00 01 00       	mov    $0x10000,%edx
80102d1f:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102d24:	e8 74 ff ff ff       	call   80102c9d <mpsearch1>
}
80102d29:	c9                   	leave  
80102d2a:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102d2b:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102d32:	c1 e0 08             	shl    $0x8,%eax
80102d35:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102d3c:	09 d0                	or     %edx,%eax
80102d3e:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102d41:	2d 00 04 00 00       	sub    $0x400,%eax
80102d46:	ba 00 04 00 00       	mov    $0x400,%edx
80102d4b:	e8 4d ff ff ff       	call   80102c9d <mpsearch1>
80102d50:	85 c0                	test   %eax,%eax
80102d52:	75 d5                	jne    80102d29 <mpsearch+0x3d>
80102d54:	eb c4                	jmp    80102d1a <mpsearch+0x2e>

80102d56 <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102d56:	55                   	push   %ebp
80102d57:	89 e5                	mov    %esp,%ebp
80102d59:	57                   	push   %edi
80102d5a:	56                   	push   %esi
80102d5b:	53                   	push   %ebx
80102d5c:	83 ec 1c             	sub    $0x1c,%esp
80102d5f:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102d62:	e8 85 ff ff ff       	call   80102cec <mpsearch>
80102d67:	85 c0                	test   %eax,%eax
80102d69:	74 5c                	je     80102dc7 <mpconfig+0x71>
80102d6b:	89 c7                	mov    %eax,%edi
80102d6d:	8b 58 04             	mov    0x4(%eax),%ebx
80102d70:	85 db                	test   %ebx,%ebx
80102d72:	74 5a                	je     80102dce <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102d74:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102d7a:	83 ec 04             	sub    $0x4,%esp
80102d7d:	6a 04                	push   $0x4
80102d7f:	68 5d 6b 10 80       	push   $0x80106b5d
80102d84:	56                   	push   %esi
80102d85:	e8 99 10 00 00       	call   80103e23 <memcmp>
80102d8a:	83 c4 10             	add    $0x10,%esp
80102d8d:	85 c0                	test   %eax,%eax
80102d8f:	75 44                	jne    80102dd5 <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102d91:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102d98:	3c 01                	cmp    $0x1,%al
80102d9a:	0f 95 c2             	setne  %dl
80102d9d:	3c 04                	cmp    $0x4,%al
80102d9f:	0f 95 c0             	setne  %al
80102da2:	84 c2                	test   %al,%dl
80102da4:	75 36                	jne    80102ddc <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102da6:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102dad:	89 f0                	mov    %esi,%eax
80102daf:	e8 c5 fe ff ff       	call   80102c79 <sum>
80102db4:	84 c0                	test   %al,%al
80102db6:	75 2b                	jne    80102de3 <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102db8:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102dbb:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102dbd:	89 f0                	mov    %esi,%eax
80102dbf:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102dc2:	5b                   	pop    %ebx
80102dc3:	5e                   	pop    %esi
80102dc4:	5f                   	pop    %edi
80102dc5:	5d                   	pop    %ebp
80102dc6:	c3                   	ret    
    return 0;
80102dc7:	be 00 00 00 00       	mov    $0x0,%esi
80102dcc:	eb ef                	jmp    80102dbd <mpconfig+0x67>
80102dce:	be 00 00 00 00       	mov    $0x0,%esi
80102dd3:	eb e8                	jmp    80102dbd <mpconfig+0x67>
    return 0;
80102dd5:	be 00 00 00 00       	mov    $0x0,%esi
80102dda:	eb e1                	jmp    80102dbd <mpconfig+0x67>
    return 0;
80102ddc:	be 00 00 00 00       	mov    $0x0,%esi
80102de1:	eb da                	jmp    80102dbd <mpconfig+0x67>
    return 0;
80102de3:	be 00 00 00 00       	mov    $0x0,%esi
80102de8:	eb d3                	jmp    80102dbd <mpconfig+0x67>

80102dea <mpinit>:

void
mpinit(void)
{
80102dea:	55                   	push   %ebp
80102deb:	89 e5                	mov    %esp,%ebp
80102ded:	57                   	push   %edi
80102dee:	56                   	push   %esi
80102def:	53                   	push   %ebx
80102df0:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102df3:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102df6:	e8 5b ff ff ff       	call   80102d56 <mpconfig>
80102dfb:	85 c0                	test   %eax,%eax
80102dfd:	74 19                	je     80102e18 <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102dff:	8b 50 24             	mov    0x24(%eax),%edx
80102e02:	89 15 78 a6 14 80    	mov    %edx,0x8014a678
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e08:	8d 50 2c             	lea    0x2c(%eax),%edx
80102e0b:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102e0f:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102e11:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e16:	eb 34                	jmp    80102e4c <mpinit+0x62>
    panic("Expect to run on an SMP");
80102e18:	83 ec 0c             	sub    $0xc,%esp
80102e1b:	68 62 6b 10 80       	push   $0x80106b62
80102e20:	e8 23 d5 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102e25:	8b 35 00 ad 14 80    	mov    0x8014ad00,%esi
80102e2b:	83 fe 07             	cmp    $0x7,%esi
80102e2e:	7f 19                	jg     80102e49 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102e30:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e34:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102e3a:	88 87 80 a7 14 80    	mov    %al,-0x7feb5880(%edi)
        ncpu++;
80102e40:	83 c6 01             	add    $0x1,%esi
80102e43:	89 35 00 ad 14 80    	mov    %esi,0x8014ad00
      }
      p += sizeof(struct mpproc);
80102e49:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e4c:	39 ca                	cmp    %ecx,%edx
80102e4e:	73 2b                	jae    80102e7b <mpinit+0x91>
    switch(*p){
80102e50:	0f b6 02             	movzbl (%edx),%eax
80102e53:	3c 04                	cmp    $0x4,%al
80102e55:	77 1d                	ja     80102e74 <mpinit+0x8a>
80102e57:	0f b6 c0             	movzbl %al,%eax
80102e5a:	ff 24 85 9c 6b 10 80 	jmp    *-0x7fef9464(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102e61:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e65:	a2 60 a7 14 80       	mov    %al,0x8014a760
      p += sizeof(struct mpioapic);
80102e6a:	83 c2 08             	add    $0x8,%edx
      continue;
80102e6d:	eb dd                	jmp    80102e4c <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102e6f:	83 c2 08             	add    $0x8,%edx
      continue;
80102e72:	eb d8                	jmp    80102e4c <mpinit+0x62>
    default:
      ismp = 0;
80102e74:	bb 00 00 00 00       	mov    $0x0,%ebx
80102e79:	eb d1                	jmp    80102e4c <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102e7b:	85 db                	test   %ebx,%ebx
80102e7d:	74 26                	je     80102ea5 <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102e7f:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102e82:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102e86:	74 15                	je     80102e9d <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e88:	b8 70 00 00 00       	mov    $0x70,%eax
80102e8d:	ba 22 00 00 00       	mov    $0x22,%edx
80102e92:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102e93:	ba 23 00 00 00       	mov    $0x23,%edx
80102e98:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102e99:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102e9c:	ee                   	out    %al,(%dx)
  }
}
80102e9d:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102ea0:	5b                   	pop    %ebx
80102ea1:	5e                   	pop    %esi
80102ea2:	5f                   	pop    %edi
80102ea3:	5d                   	pop    %ebp
80102ea4:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102ea5:	83 ec 0c             	sub    $0xc,%esp
80102ea8:	68 7c 6b 10 80       	push   $0x80106b7c
80102ead:	e8 96 d4 ff ff       	call   80100348 <panic>

80102eb2 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102eb2:	55                   	push   %ebp
80102eb3:	89 e5                	mov    %esp,%ebp
80102eb5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102eba:	ba 21 00 00 00       	mov    $0x21,%edx
80102ebf:	ee                   	out    %al,(%dx)
80102ec0:	ba a1 00 00 00       	mov    $0xa1,%edx
80102ec5:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102ec6:	5d                   	pop    %ebp
80102ec7:	c3                   	ret    

80102ec8 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102ec8:	55                   	push   %ebp
80102ec9:	89 e5                	mov    %esp,%ebp
80102ecb:	57                   	push   %edi
80102ecc:	56                   	push   %esi
80102ecd:	53                   	push   %ebx
80102ece:	83 ec 0c             	sub    $0xc,%esp
80102ed1:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102ed4:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102ed7:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102edd:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102ee3:	e8 45 dd ff ff       	call   80100c2d <filealloc>
80102ee8:	89 03                	mov    %eax,(%ebx)
80102eea:	85 c0                	test   %eax,%eax
80102eec:	74 16                	je     80102f04 <pipealloc+0x3c>
80102eee:	e8 3a dd ff ff       	call   80100c2d <filealloc>
80102ef3:	89 06                	mov    %eax,(%esi)
80102ef5:	85 c0                	test   %eax,%eax
80102ef7:	74 0b                	je     80102f04 <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102ef9:	e8 d3 f1 ff ff       	call   801020d1 <kalloc>
80102efe:	89 c7                	mov    %eax,%edi
80102f00:	85 c0                	test   %eax,%eax
80102f02:	75 35                	jne    80102f39 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102f04:	8b 03                	mov    (%ebx),%eax
80102f06:	85 c0                	test   %eax,%eax
80102f08:	74 0c                	je     80102f16 <pipealloc+0x4e>
    fileclose(*f0);
80102f0a:	83 ec 0c             	sub    $0xc,%esp
80102f0d:	50                   	push   %eax
80102f0e:	e8 c0 dd ff ff       	call   80100cd3 <fileclose>
80102f13:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102f16:	8b 06                	mov    (%esi),%eax
80102f18:	85 c0                	test   %eax,%eax
80102f1a:	0f 84 8b 00 00 00    	je     80102fab <pipealloc+0xe3>
    fileclose(*f1);
80102f20:	83 ec 0c             	sub    $0xc,%esp
80102f23:	50                   	push   %eax
80102f24:	e8 aa dd ff ff       	call   80100cd3 <fileclose>
80102f29:	83 c4 10             	add    $0x10,%esp
  return -1;
80102f2c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f31:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f34:	5b                   	pop    %ebx
80102f35:	5e                   	pop    %esi
80102f36:	5f                   	pop    %edi
80102f37:	5d                   	pop    %ebp
80102f38:	c3                   	ret    
  p->readopen = 1;
80102f39:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102f40:	00 00 00 
  p->writeopen = 1;
80102f43:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102f4a:	00 00 00 
  p->nwrite = 0;
80102f4d:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102f54:	00 00 00 
  p->nread = 0;
80102f57:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102f5e:	00 00 00 
  initlock(&p->lock, "pipe");
80102f61:	83 ec 08             	sub    $0x8,%esp
80102f64:	68 b0 6b 10 80       	push   $0x80106bb0
80102f69:	50                   	push   %eax
80102f6a:	e8 86 0c 00 00       	call   80103bf5 <initlock>
  (*f0)->type = FD_PIPE;
80102f6f:	8b 03                	mov    (%ebx),%eax
80102f71:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102f77:	8b 03                	mov    (%ebx),%eax
80102f79:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102f7d:	8b 03                	mov    (%ebx),%eax
80102f7f:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102f83:	8b 03                	mov    (%ebx),%eax
80102f85:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102f88:	8b 06                	mov    (%esi),%eax
80102f8a:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102f90:	8b 06                	mov    (%esi),%eax
80102f92:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102f96:	8b 06                	mov    (%esi),%eax
80102f98:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102f9c:	8b 06                	mov    (%esi),%eax
80102f9e:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102fa1:	83 c4 10             	add    $0x10,%esp
80102fa4:	b8 00 00 00 00       	mov    $0x0,%eax
80102fa9:	eb 86                	jmp    80102f31 <pipealloc+0x69>
  return -1;
80102fab:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fb0:	e9 7c ff ff ff       	jmp    80102f31 <pipealloc+0x69>

80102fb5 <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102fb5:	55                   	push   %ebp
80102fb6:	89 e5                	mov    %esp,%ebp
80102fb8:	53                   	push   %ebx
80102fb9:	83 ec 10             	sub    $0x10,%esp
80102fbc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102fbf:	53                   	push   %ebx
80102fc0:	e8 6c 0d 00 00       	call   80103d31 <acquire>
  if(writable){
80102fc5:	83 c4 10             	add    $0x10,%esp
80102fc8:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80102fcc:	74 3f                	je     8010300d <pipeclose+0x58>
    p->writeopen = 0;
80102fce:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
80102fd5:	00 00 00 
    wakeup(&p->nread);
80102fd8:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80102fde:	83 ec 0c             	sub    $0xc,%esp
80102fe1:	50                   	push   %eax
80102fe2:	e8 b4 09 00 00       	call   8010399b <wakeup>
80102fe7:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80102fea:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80102ff1:	75 09                	jne    80102ffc <pipeclose+0x47>
80102ff3:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80102ffa:	74 2f                	je     8010302b <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80102ffc:	83 ec 0c             	sub    $0xc,%esp
80102fff:	53                   	push   %ebx
80103000:	e8 91 0d 00 00       	call   80103d96 <release>
80103005:	83 c4 10             	add    $0x10,%esp
}
80103008:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010300b:	c9                   	leave  
8010300c:	c3                   	ret    
    p->readopen = 0;
8010300d:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
80103014:	00 00 00 
    wakeup(&p->nwrite);
80103017:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
8010301d:	83 ec 0c             	sub    $0xc,%esp
80103020:	50                   	push   %eax
80103021:	e8 75 09 00 00       	call   8010399b <wakeup>
80103026:	83 c4 10             	add    $0x10,%esp
80103029:	eb bf                	jmp    80102fea <pipeclose+0x35>
    release(&p->lock);
8010302b:	83 ec 0c             	sub    $0xc,%esp
8010302e:	53                   	push   %ebx
8010302f:	e8 62 0d 00 00       	call   80103d96 <release>
    kfree((char*)p);
80103034:	89 1c 24             	mov    %ebx,(%esp)
80103037:	e8 68 ef ff ff       	call   80101fa4 <kfree>
8010303c:	83 c4 10             	add    $0x10,%esp
8010303f:	eb c7                	jmp    80103008 <pipeclose+0x53>

80103041 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80103041:	55                   	push   %ebp
80103042:	89 e5                	mov    %esp,%ebp
80103044:	57                   	push   %edi
80103045:	56                   	push   %esi
80103046:	53                   	push   %ebx
80103047:	83 ec 18             	sub    $0x18,%esp
8010304a:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
8010304d:	89 de                	mov    %ebx,%esi
8010304f:	53                   	push   %ebx
80103050:	e8 dc 0c 00 00       	call   80103d31 <acquire>
  for(i = 0; i < n; i++){
80103055:	83 c4 10             	add    $0x10,%esp
80103058:	bf 00 00 00 00       	mov    $0x0,%edi
8010305d:	3b 7d 10             	cmp    0x10(%ebp),%edi
80103060:	0f 8d 88 00 00 00    	jge    801030ee <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
80103066:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
8010306c:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
80103072:	05 00 02 00 00       	add    $0x200,%eax
80103077:	39 c2                	cmp    %eax,%edx
80103079:	75 51                	jne    801030cc <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
8010307b:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103082:	74 2f                	je     801030b3 <pipewrite+0x72>
80103084:	e8 06 03 00 00       	call   8010338f <myproc>
80103089:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010308d:	75 24                	jne    801030b3 <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
8010308f:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103095:	83 ec 0c             	sub    $0xc,%esp
80103098:	50                   	push   %eax
80103099:	e8 fd 08 00 00       	call   8010399b <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
8010309e:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801030a4:	83 c4 08             	add    $0x8,%esp
801030a7:	56                   	push   %esi
801030a8:	50                   	push   %eax
801030a9:	e8 88 07 00 00       	call   80103836 <sleep>
801030ae:	83 c4 10             	add    $0x10,%esp
801030b1:	eb b3                	jmp    80103066 <pipewrite+0x25>
        release(&p->lock);
801030b3:	83 ec 0c             	sub    $0xc,%esp
801030b6:	53                   	push   %ebx
801030b7:	e8 da 0c 00 00       	call   80103d96 <release>
        return -1;
801030bc:	83 c4 10             	add    $0x10,%esp
801030bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
801030c4:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030c7:	5b                   	pop    %ebx
801030c8:	5e                   	pop    %esi
801030c9:	5f                   	pop    %edi
801030ca:	5d                   	pop    %ebp
801030cb:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
801030cc:	8d 42 01             	lea    0x1(%edx),%eax
801030cf:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
801030d5:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
801030db:	8b 45 0c             	mov    0xc(%ebp),%eax
801030de:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
801030e2:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
801030e6:	83 c7 01             	add    $0x1,%edi
801030e9:	e9 6f ff ff ff       	jmp    8010305d <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
801030ee:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030f4:	83 ec 0c             	sub    $0xc,%esp
801030f7:	50                   	push   %eax
801030f8:	e8 9e 08 00 00       	call   8010399b <wakeup>
  release(&p->lock);
801030fd:	89 1c 24             	mov    %ebx,(%esp)
80103100:	e8 91 0c 00 00       	call   80103d96 <release>
  return n;
80103105:	83 c4 10             	add    $0x10,%esp
80103108:	8b 45 10             	mov    0x10(%ebp),%eax
8010310b:	eb b7                	jmp    801030c4 <pipewrite+0x83>

8010310d <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
8010310d:	55                   	push   %ebp
8010310e:	89 e5                	mov    %esp,%ebp
80103110:	57                   	push   %edi
80103111:	56                   	push   %esi
80103112:	53                   	push   %ebx
80103113:	83 ec 18             	sub    $0x18,%esp
80103116:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103119:	89 df                	mov    %ebx,%edi
8010311b:	53                   	push   %ebx
8010311c:	e8 10 0c 00 00       	call   80103d31 <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103121:	83 c4 10             	add    $0x10,%esp
80103124:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
8010312a:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80103130:	75 3d                	jne    8010316f <piperead+0x62>
80103132:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
80103138:	85 f6                	test   %esi,%esi
8010313a:	74 38                	je     80103174 <piperead+0x67>
    if(myproc()->killed){
8010313c:	e8 4e 02 00 00       	call   8010338f <myproc>
80103141:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80103145:	75 15                	jne    8010315c <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
80103147:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010314d:	83 ec 08             	sub    $0x8,%esp
80103150:	57                   	push   %edi
80103151:	50                   	push   %eax
80103152:	e8 df 06 00 00       	call   80103836 <sleep>
80103157:	83 c4 10             	add    $0x10,%esp
8010315a:	eb c8                	jmp    80103124 <piperead+0x17>
      release(&p->lock);
8010315c:	83 ec 0c             	sub    $0xc,%esp
8010315f:	53                   	push   %ebx
80103160:	e8 31 0c 00 00       	call   80103d96 <release>
      return -1;
80103165:	83 c4 10             	add    $0x10,%esp
80103168:	be ff ff ff ff       	mov    $0xffffffff,%esi
8010316d:	eb 50                	jmp    801031bf <piperead+0xb2>
8010316f:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
80103174:	3b 75 10             	cmp    0x10(%ebp),%esi
80103177:	7d 2c                	jge    801031a5 <piperead+0x98>
    if(p->nread == p->nwrite)
80103179:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
8010317f:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
80103185:	74 1e                	je     801031a5 <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
80103187:	8d 50 01             	lea    0x1(%eax),%edx
8010318a:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
80103190:	25 ff 01 00 00       	and    $0x1ff,%eax
80103195:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
8010319a:	8b 4d 0c             	mov    0xc(%ebp),%ecx
8010319d:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801031a0:	83 c6 01             	add    $0x1,%esi
801031a3:	eb cf                	jmp    80103174 <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801031a5:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801031ab:	83 ec 0c             	sub    $0xc,%esp
801031ae:	50                   	push   %eax
801031af:	e8 e7 07 00 00       	call   8010399b <wakeup>
  release(&p->lock);
801031b4:	89 1c 24             	mov    %ebx,(%esp)
801031b7:	e8 da 0b 00 00       	call   80103d96 <release>
  return i;
801031bc:	83 c4 10             	add    $0x10,%esp
}
801031bf:	89 f0                	mov    %esi,%eax
801031c1:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031c4:	5b                   	pop    %ebx
801031c5:	5e                   	pop    %esi
801031c6:	5f                   	pop    %edi
801031c7:	5d                   	pop    %ebp
801031c8:	c3                   	ret    

801031c9 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
801031c9:	55                   	push   %ebp
801031ca:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
801031cc:	ba 54 ad 14 80       	mov    $0x8014ad54,%edx
801031d1:	eb 03                	jmp    801031d6 <wakeup1+0xd>
801031d3:	83 c2 7c             	add    $0x7c,%edx
801031d6:	81 fa 54 cc 14 80    	cmp    $0x8014cc54,%edx
801031dc:	73 14                	jae    801031f2 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
801031de:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
801031e2:	75 ef                	jne    801031d3 <wakeup1+0xa>
801031e4:	39 42 20             	cmp    %eax,0x20(%edx)
801031e7:	75 ea                	jne    801031d3 <wakeup1+0xa>
      p->state = RUNNABLE;
801031e9:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
801031f0:	eb e1                	jmp    801031d3 <wakeup1+0xa>
}
801031f2:	5d                   	pop    %ebp
801031f3:	c3                   	ret    

801031f4 <allocproc>:
{
801031f4:	55                   	push   %ebp
801031f5:	89 e5                	mov    %esp,%ebp
801031f7:	53                   	push   %ebx
801031f8:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
801031fb:	68 20 ad 14 80       	push   $0x8014ad20
80103200:	e8 2c 0b 00 00       	call   80103d31 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103205:	83 c4 10             	add    $0x10,%esp
80103208:	bb 54 ad 14 80       	mov    $0x8014ad54,%ebx
8010320d:	81 fb 54 cc 14 80    	cmp    $0x8014cc54,%ebx
80103213:	73 0b                	jae    80103220 <allocproc+0x2c>
    if(p->state == UNUSED)
80103215:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103219:	74 1c                	je     80103237 <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010321b:	83 c3 7c             	add    $0x7c,%ebx
8010321e:	eb ed                	jmp    8010320d <allocproc+0x19>
  release(&ptable.lock);
80103220:	83 ec 0c             	sub    $0xc,%esp
80103223:	68 20 ad 14 80       	push   $0x8014ad20
80103228:	e8 69 0b 00 00       	call   80103d96 <release>
  return 0;
8010322d:	83 c4 10             	add    $0x10,%esp
80103230:	bb 00 00 00 00       	mov    $0x0,%ebx
80103235:	eb 6f                	jmp    801032a6 <allocproc+0xb2>
  p->state = EMBRYO;
80103237:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
8010323e:	a1 04 a0 10 80       	mov    0x8010a004,%eax
80103243:	8d 50 01             	lea    0x1(%eax),%edx
80103246:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
8010324c:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
8010324f:	83 ec 0c             	sub    $0xc,%esp
80103252:	68 20 ad 14 80       	push   $0x8014ad20
80103257:	e8 3a 0b 00 00       	call   80103d96 <release>
  if((p->kstack = kalloc1(p->pid)) == 0){
8010325c:	83 c4 04             	add    $0x4,%esp
8010325f:	ff 73 10             	pushl  0x10(%ebx)
80103262:	e8 80 ee ff ff       	call   801020e7 <kalloc1>
80103267:	89 43 08             	mov    %eax,0x8(%ebx)
8010326a:	83 c4 10             	add    $0x10,%esp
8010326d:	85 c0                	test   %eax,%eax
8010326f:	74 3c                	je     801032ad <allocproc+0xb9>
  sp -= sizeof *p->tf;
80103271:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
80103277:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
8010327a:	c7 80 b0 0f 00 00 f3 	movl   $0x80104ef3,0xfb0(%eax)
80103281:	4e 10 80 
  sp -= sizeof *p->context;
80103284:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
80103289:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
8010328c:	83 ec 04             	sub    $0x4,%esp
8010328f:	6a 14                	push   $0x14
80103291:	6a 00                	push   $0x0
80103293:	50                   	push   %eax
80103294:	e8 44 0b 00 00       	call   80103ddd <memset>
  p->context->eip = (uint)forkret;
80103299:	8b 43 1c             	mov    0x1c(%ebx),%eax
8010329c:	c7 40 10 bb 32 10 80 	movl   $0x801032bb,0x10(%eax)
  return p;
801032a3:	83 c4 10             	add    $0x10,%esp
}
801032a6:	89 d8                	mov    %ebx,%eax
801032a8:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801032ab:	c9                   	leave  
801032ac:	c3                   	ret    
    p->state = UNUSED;
801032ad:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801032b4:	bb 00 00 00 00       	mov    $0x0,%ebx
801032b9:	eb eb                	jmp    801032a6 <allocproc+0xb2>

801032bb <forkret>:
{
801032bb:	55                   	push   %ebp
801032bc:	89 e5                	mov    %esp,%ebp
801032be:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
801032c1:	68 20 ad 14 80       	push   $0x8014ad20
801032c6:	e8 cb 0a 00 00       	call   80103d96 <release>
  if (first) {
801032cb:	83 c4 10             	add    $0x10,%esp
801032ce:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
801032d5:	75 02                	jne    801032d9 <forkret+0x1e>
}
801032d7:	c9                   	leave  
801032d8:	c3                   	ret    
    first = 0;
801032d9:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
801032e0:	00 00 00 
    iinit(ROOTDEV);
801032e3:	83 ec 0c             	sub    $0xc,%esp
801032e6:	6a 01                	push   $0x1
801032e8:	e8 ff df ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
801032ed:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
801032f4:	e8 ff f5 ff ff       	call   801028f8 <initlog>
801032f9:	83 c4 10             	add    $0x10,%esp
}
801032fc:	eb d9                	jmp    801032d7 <forkret+0x1c>

801032fe <pinit>:
{
801032fe:	55                   	push   %ebp
801032ff:	89 e5                	mov    %esp,%ebp
80103301:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103304:	68 b5 6b 10 80       	push   $0x80106bb5
80103309:	68 20 ad 14 80       	push   $0x8014ad20
8010330e:	e8 e2 08 00 00       	call   80103bf5 <initlock>
}
80103313:	83 c4 10             	add    $0x10,%esp
80103316:	c9                   	leave  
80103317:	c3                   	ret    

80103318 <mycpu>:
{
80103318:	55                   	push   %ebp
80103319:	89 e5                	mov    %esp,%ebp
8010331b:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010331e:	9c                   	pushf  
8010331f:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103320:	f6 c4 02             	test   $0x2,%ah
80103323:	75 28                	jne    8010334d <mycpu+0x35>
  apicid = lapicid();
80103325:	e8 e7 f1 ff ff       	call   80102511 <lapicid>
  for (i = 0; i < ncpu; ++i) {
8010332a:	ba 00 00 00 00       	mov    $0x0,%edx
8010332f:	39 15 00 ad 14 80    	cmp    %edx,0x8014ad00
80103335:	7e 23                	jle    8010335a <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103337:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010333d:	0f b6 89 80 a7 14 80 	movzbl -0x7feb5880(%ecx),%ecx
80103344:	39 c1                	cmp    %eax,%ecx
80103346:	74 1f                	je     80103367 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103348:	83 c2 01             	add    $0x1,%edx
8010334b:	eb e2                	jmp    8010332f <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
8010334d:	83 ec 0c             	sub    $0xc,%esp
80103350:	68 98 6c 10 80       	push   $0x80106c98
80103355:	e8 ee cf ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
8010335a:	83 ec 0c             	sub    $0xc,%esp
8010335d:	68 bc 6b 10 80       	push   $0x80106bbc
80103362:	e8 e1 cf ff ff       	call   80100348 <panic>
      return &cpus[i];
80103367:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
8010336d:	05 80 a7 14 80       	add    $0x8014a780,%eax
}
80103372:	c9                   	leave  
80103373:	c3                   	ret    

80103374 <cpuid>:
cpuid() {
80103374:	55                   	push   %ebp
80103375:	89 e5                	mov    %esp,%ebp
80103377:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
8010337a:	e8 99 ff ff ff       	call   80103318 <mycpu>
8010337f:	2d 80 a7 14 80       	sub    $0x8014a780,%eax
80103384:	c1 f8 04             	sar    $0x4,%eax
80103387:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
8010338d:	c9                   	leave  
8010338e:	c3                   	ret    

8010338f <myproc>:
myproc(void) {
8010338f:	55                   	push   %ebp
80103390:	89 e5                	mov    %esp,%ebp
80103392:	53                   	push   %ebx
80103393:	83 ec 04             	sub    $0x4,%esp
  pushcli();
80103396:	e8 b9 08 00 00       	call   80103c54 <pushcli>
  c = mycpu();
8010339b:	e8 78 ff ff ff       	call   80103318 <mycpu>
  p = c->proc;
801033a0:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801033a6:	e8 e6 08 00 00       	call   80103c91 <popcli>
}
801033ab:	89 d8                	mov    %ebx,%eax
801033ad:	83 c4 04             	add    $0x4,%esp
801033b0:	5b                   	pop    %ebx
801033b1:	5d                   	pop    %ebp
801033b2:	c3                   	ret    

801033b3 <userinit>:
{
801033b3:	55                   	push   %ebp
801033b4:	89 e5                	mov    %esp,%ebp
801033b6:	53                   	push   %ebx
801033b7:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801033ba:	e8 35 fe ff ff       	call   801031f4 <allocproc>
801033bf:	89 c3                	mov    %eax,%ebx
  initproc = p;
801033c1:	a3 b8 a5 10 80       	mov    %eax,0x8010a5b8
  if((p->pgdir = setupkvm()) == 0)
801033c6:	e8 27 30 00 00       	call   801063f2 <setupkvm>
801033cb:	89 43 04             	mov    %eax,0x4(%ebx)
801033ce:	85 c0                	test   %eax,%eax
801033d0:	0f 84 b7 00 00 00    	je     8010348d <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);//p->pid?
801033d6:	83 ec 04             	sub    $0x4,%esp
801033d9:	68 2c 00 00 00       	push   $0x2c
801033de:	68 60 a4 10 80       	push   $0x8010a460
801033e3:	50                   	push   %eax
801033e4:	e8 01 2d 00 00       	call   801060ea <inituvm>
  p->sz = PGSIZE;
801033e9:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
801033ef:	83 c4 0c             	add    $0xc,%esp
801033f2:	6a 4c                	push   $0x4c
801033f4:	6a 00                	push   $0x0
801033f6:	ff 73 18             	pushl  0x18(%ebx)
801033f9:	e8 df 09 00 00       	call   80103ddd <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
801033fe:	8b 43 18             	mov    0x18(%ebx),%eax
80103401:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103407:	8b 43 18             	mov    0x18(%ebx),%eax
8010340a:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103410:	8b 43 18             	mov    0x18(%ebx),%eax
80103413:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103417:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010341b:	8b 43 18             	mov    0x18(%ebx),%eax
8010341e:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103422:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103426:	8b 43 18             	mov    0x18(%ebx),%eax
80103429:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103430:	8b 43 18             	mov    0x18(%ebx),%eax
80103433:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010343a:	8b 43 18             	mov    0x18(%ebx),%eax
8010343d:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103444:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103447:	83 c4 0c             	add    $0xc,%esp
8010344a:	6a 10                	push   $0x10
8010344c:	68 e5 6b 10 80       	push   $0x80106be5
80103451:	50                   	push   %eax
80103452:	e8 ed 0a 00 00       	call   80103f44 <safestrcpy>
  p->cwd = namei("/");
80103457:	c7 04 24 ee 6b 10 80 	movl   $0x80106bee,(%esp)
8010345e:	e8 7e e7 ff ff       	call   80101be1 <namei>
80103463:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103466:	c7 04 24 20 ad 14 80 	movl   $0x8014ad20,(%esp)
8010346d:	e8 bf 08 00 00       	call   80103d31 <acquire>
  p->state = RUNNABLE;
80103472:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
80103479:	c7 04 24 20 ad 14 80 	movl   $0x8014ad20,(%esp)
80103480:	e8 11 09 00 00       	call   80103d96 <release>
}
80103485:	83 c4 10             	add    $0x10,%esp
80103488:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010348b:	c9                   	leave  
8010348c:	c3                   	ret    
    panic("userinit: out of memory?");
8010348d:	83 ec 0c             	sub    $0xc,%esp
80103490:	68 cc 6b 10 80       	push   $0x80106bcc
80103495:	e8 ae ce ff ff       	call   80100348 <panic>

8010349a <growproc>:
{
8010349a:	55                   	push   %ebp
8010349b:	89 e5                	mov    %esp,%ebp
8010349d:	56                   	push   %esi
8010349e:	53                   	push   %ebx
8010349f:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801034a2:	e8 e8 fe ff ff       	call   8010338f <myproc>
801034a7:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801034a9:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801034ab:	85 f6                	test   %esi,%esi
801034ad:	7f 21                	jg     801034d0 <growproc+0x36>
  } else if(n < 0){
801034af:	85 f6                	test   %esi,%esi
801034b1:	79 33                	jns    801034e6 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034b3:	83 ec 04             	sub    $0x4,%esp
801034b6:	01 c6                	add    %eax,%esi
801034b8:	56                   	push   %esi
801034b9:	50                   	push   %eax
801034ba:	ff 73 04             	pushl  0x4(%ebx)
801034bd:	e8 36 2d 00 00       	call   801061f8 <deallocuvm>
801034c2:	83 c4 10             	add    $0x10,%esp
801034c5:	85 c0                	test   %eax,%eax
801034c7:	75 1d                	jne    801034e6 <growproc+0x4c>
      return -1;
801034c9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034ce:	eb 29                	jmp    801034f9 <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034d0:	83 ec 04             	sub    $0x4,%esp
801034d3:	01 c6                	add    %eax,%esi
801034d5:	56                   	push   %esi
801034d6:	50                   	push   %eax
801034d7:	ff 73 04             	pushl  0x4(%ebx)
801034da:	e8 ab 2d 00 00       	call   8010628a <allocuvm>
801034df:	83 c4 10             	add    $0x10,%esp
801034e2:	85 c0                	test   %eax,%eax
801034e4:	74 1a                	je     80103500 <growproc+0x66>
  curproc->sz = sz;
801034e6:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
801034e8:	83 ec 0c             	sub    $0xc,%esp
801034eb:	53                   	push   %ebx
801034ec:	e8 e1 2a 00 00       	call   80105fd2 <switchuvm>
  return 0;
801034f1:	83 c4 10             	add    $0x10,%esp
801034f4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801034f9:	8d 65 f8             	lea    -0x8(%ebp),%esp
801034fc:	5b                   	pop    %ebx
801034fd:	5e                   	pop    %esi
801034fe:	5d                   	pop    %ebp
801034ff:	c3                   	ret    
      return -1;
80103500:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103505:	eb f2                	jmp    801034f9 <growproc+0x5f>

80103507 <fork>:
{
80103507:	55                   	push   %ebp
80103508:	89 e5                	mov    %esp,%ebp
8010350a:	57                   	push   %edi
8010350b:	56                   	push   %esi
8010350c:	53                   	push   %ebx
8010350d:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103510:	e8 7a fe ff ff       	call   8010338f <myproc>
80103515:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103517:	e8 d8 fc ff ff       	call   801031f4 <allocproc>
8010351c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010351f:	85 c0                	test   %eax,%eax
80103521:	0f 84 e3 00 00 00    	je     8010360a <fork+0x103>
80103527:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz, np->pid)) == 0){// np->pid
80103529:	83 ec 04             	sub    $0x4,%esp
8010352c:	ff 70 10             	pushl  0x10(%eax)
8010352f:	ff 33                	pushl  (%ebx)
80103531:	ff 73 04             	pushl  0x4(%ebx)
80103534:	e8 72 2f 00 00       	call   801064ab <copyuvm>
80103539:	89 47 04             	mov    %eax,0x4(%edi)
8010353c:	83 c4 10             	add    $0x10,%esp
8010353f:	85 c0                	test   %eax,%eax
80103541:	74 2a                	je     8010356d <fork+0x66>
  np->sz = curproc->sz;
80103543:	8b 03                	mov    (%ebx),%eax
80103545:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103548:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
8010354a:	89 c8                	mov    %ecx,%eax
8010354c:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
8010354f:	8b 73 18             	mov    0x18(%ebx),%esi
80103552:	8b 79 18             	mov    0x18(%ecx),%edi
80103555:	b9 13 00 00 00       	mov    $0x13,%ecx
8010355a:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
8010355c:	8b 40 18             	mov    0x18(%eax),%eax
8010355f:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103566:	be 00 00 00 00       	mov    $0x0,%esi
8010356b:	eb 29                	jmp    80103596 <fork+0x8f>
    kfree(np->kstack);
8010356d:	83 ec 0c             	sub    $0xc,%esp
80103570:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
80103573:	ff 73 08             	pushl  0x8(%ebx)
80103576:	e8 29 ea ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
8010357b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
80103582:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
80103589:	83 c4 10             	add    $0x10,%esp
8010358c:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80103591:	eb 6d                	jmp    80103600 <fork+0xf9>
  for(i = 0; i < NOFILE; i++)
80103593:	83 c6 01             	add    $0x1,%esi
80103596:	83 fe 0f             	cmp    $0xf,%esi
80103599:	7f 1d                	jg     801035b8 <fork+0xb1>
    if(curproc->ofile[i])
8010359b:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
8010359f:	85 c0                	test   %eax,%eax
801035a1:	74 f0                	je     80103593 <fork+0x8c>
      np->ofile[i] = filedup(curproc->ofile[i]);
801035a3:	83 ec 0c             	sub    $0xc,%esp
801035a6:	50                   	push   %eax
801035a7:	e8 e2 d6 ff ff       	call   80100c8e <filedup>
801035ac:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801035af:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801035b3:	83 c4 10             	add    $0x10,%esp
801035b6:	eb db                	jmp    80103593 <fork+0x8c>
  np->cwd = idup(curproc->cwd);
801035b8:	83 ec 0c             	sub    $0xc,%esp
801035bb:	ff 73 68             	pushl  0x68(%ebx)
801035be:	e8 8e df ff ff       	call   80101551 <idup>
801035c3:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801035c6:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801035c9:	83 c3 6c             	add    $0x6c,%ebx
801035cc:	8d 47 6c             	lea    0x6c(%edi),%eax
801035cf:	83 c4 0c             	add    $0xc,%esp
801035d2:	6a 10                	push   $0x10
801035d4:	53                   	push   %ebx
801035d5:	50                   	push   %eax
801035d6:	e8 69 09 00 00       	call   80103f44 <safestrcpy>
  pid = np->pid;
801035db:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
801035de:	c7 04 24 20 ad 14 80 	movl   $0x8014ad20,(%esp)
801035e5:	e8 47 07 00 00       	call   80103d31 <acquire>
  np->state = RUNNABLE;
801035ea:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
801035f1:	c7 04 24 20 ad 14 80 	movl   $0x8014ad20,(%esp)
801035f8:	e8 99 07 00 00       	call   80103d96 <release>
  return pid;
801035fd:	83 c4 10             	add    $0x10,%esp
}
80103600:	89 d8                	mov    %ebx,%eax
80103602:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103605:	5b                   	pop    %ebx
80103606:	5e                   	pop    %esi
80103607:	5f                   	pop    %edi
80103608:	5d                   	pop    %ebp
80103609:	c3                   	ret    
    return -1;
8010360a:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010360f:	eb ef                	jmp    80103600 <fork+0xf9>

80103611 <scheduler>:
{
80103611:	55                   	push   %ebp
80103612:	89 e5                	mov    %esp,%ebp
80103614:	56                   	push   %esi
80103615:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103616:	e8 fd fc ff ff       	call   80103318 <mycpu>
8010361b:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010361d:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103624:	00 00 00 
80103627:	eb 5a                	jmp    80103683 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103629:	83 c3 7c             	add    $0x7c,%ebx
8010362c:	81 fb 54 cc 14 80    	cmp    $0x8014cc54,%ebx
80103632:	73 3f                	jae    80103673 <scheduler+0x62>
      if(p->state != RUNNABLE)
80103634:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103638:	75 ef                	jne    80103629 <scheduler+0x18>
      c->proc = p;
8010363a:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
80103640:	83 ec 0c             	sub    $0xc,%esp
80103643:	53                   	push   %ebx
80103644:	e8 89 29 00 00       	call   80105fd2 <switchuvm>
      p->state = RUNNING;
80103649:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
80103650:	83 c4 08             	add    $0x8,%esp
80103653:	ff 73 1c             	pushl  0x1c(%ebx)
80103656:	8d 46 04             	lea    0x4(%esi),%eax
80103659:	50                   	push   %eax
8010365a:	e8 38 09 00 00       	call   80103f97 <swtch>
      switchkvm();
8010365f:	e8 5c 29 00 00       	call   80105fc0 <switchkvm>
      c->proc = 0;
80103664:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
8010366b:	00 00 00 
8010366e:	83 c4 10             	add    $0x10,%esp
80103671:	eb b6                	jmp    80103629 <scheduler+0x18>
    release(&ptable.lock);
80103673:	83 ec 0c             	sub    $0xc,%esp
80103676:	68 20 ad 14 80       	push   $0x8014ad20
8010367b:	e8 16 07 00 00       	call   80103d96 <release>
    sti();
80103680:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
80103683:	fb                   	sti    
    acquire(&ptable.lock);
80103684:	83 ec 0c             	sub    $0xc,%esp
80103687:	68 20 ad 14 80       	push   $0x8014ad20
8010368c:	e8 a0 06 00 00       	call   80103d31 <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103691:	83 c4 10             	add    $0x10,%esp
80103694:	bb 54 ad 14 80       	mov    $0x8014ad54,%ebx
80103699:	eb 91                	jmp    8010362c <scheduler+0x1b>

8010369b <sched>:
{
8010369b:	55                   	push   %ebp
8010369c:	89 e5                	mov    %esp,%ebp
8010369e:	56                   	push   %esi
8010369f:	53                   	push   %ebx
  struct proc *p = myproc();
801036a0:	e8 ea fc ff ff       	call   8010338f <myproc>
801036a5:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801036a7:	83 ec 0c             	sub    $0xc,%esp
801036aa:	68 20 ad 14 80       	push   $0x8014ad20
801036af:	e8 3d 06 00 00       	call   80103cf1 <holding>
801036b4:	83 c4 10             	add    $0x10,%esp
801036b7:	85 c0                	test   %eax,%eax
801036b9:	74 4f                	je     8010370a <sched+0x6f>
  if(mycpu()->ncli != 1)
801036bb:	e8 58 fc ff ff       	call   80103318 <mycpu>
801036c0:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801036c7:	75 4e                	jne    80103717 <sched+0x7c>
  if(p->state == RUNNING)
801036c9:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801036cd:	74 55                	je     80103724 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801036cf:	9c                   	pushf  
801036d0:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801036d1:	f6 c4 02             	test   $0x2,%ah
801036d4:	75 5b                	jne    80103731 <sched+0x96>
  intena = mycpu()->intena;
801036d6:	e8 3d fc ff ff       	call   80103318 <mycpu>
801036db:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
801036e1:	e8 32 fc ff ff       	call   80103318 <mycpu>
801036e6:	83 ec 08             	sub    $0x8,%esp
801036e9:	ff 70 04             	pushl  0x4(%eax)
801036ec:	83 c3 1c             	add    $0x1c,%ebx
801036ef:	53                   	push   %ebx
801036f0:	e8 a2 08 00 00       	call   80103f97 <swtch>
  mycpu()->intena = intena;
801036f5:	e8 1e fc ff ff       	call   80103318 <mycpu>
801036fa:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
80103700:	83 c4 10             	add    $0x10,%esp
80103703:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103706:	5b                   	pop    %ebx
80103707:	5e                   	pop    %esi
80103708:	5d                   	pop    %ebp
80103709:	c3                   	ret    
    panic("sched ptable.lock");
8010370a:	83 ec 0c             	sub    $0xc,%esp
8010370d:	68 f0 6b 10 80       	push   $0x80106bf0
80103712:	e8 31 cc ff ff       	call   80100348 <panic>
    panic("sched locks");
80103717:	83 ec 0c             	sub    $0xc,%esp
8010371a:	68 02 6c 10 80       	push   $0x80106c02
8010371f:	e8 24 cc ff ff       	call   80100348 <panic>
    panic("sched running");
80103724:	83 ec 0c             	sub    $0xc,%esp
80103727:	68 0e 6c 10 80       	push   $0x80106c0e
8010372c:	e8 17 cc ff ff       	call   80100348 <panic>
    panic("sched interruptible");
80103731:	83 ec 0c             	sub    $0xc,%esp
80103734:	68 1c 6c 10 80       	push   $0x80106c1c
80103739:	e8 0a cc ff ff       	call   80100348 <panic>

8010373e <exit>:
{
8010373e:	55                   	push   %ebp
8010373f:	89 e5                	mov    %esp,%ebp
80103741:	56                   	push   %esi
80103742:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103743:	e8 47 fc ff ff       	call   8010338f <myproc>
  if(curproc == initproc)
80103748:	39 05 b8 a5 10 80    	cmp    %eax,0x8010a5b8
8010374e:	74 09                	je     80103759 <exit+0x1b>
80103750:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103752:	bb 00 00 00 00       	mov    $0x0,%ebx
80103757:	eb 10                	jmp    80103769 <exit+0x2b>
    panic("init exiting");
80103759:	83 ec 0c             	sub    $0xc,%esp
8010375c:	68 30 6c 10 80       	push   $0x80106c30
80103761:	e8 e2 cb ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
80103766:	83 c3 01             	add    $0x1,%ebx
80103769:	83 fb 0f             	cmp    $0xf,%ebx
8010376c:	7f 1e                	jg     8010378c <exit+0x4e>
    if(curproc->ofile[fd]){
8010376e:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
80103772:	85 c0                	test   %eax,%eax
80103774:	74 f0                	je     80103766 <exit+0x28>
      fileclose(curproc->ofile[fd]);
80103776:	83 ec 0c             	sub    $0xc,%esp
80103779:	50                   	push   %eax
8010377a:	e8 54 d5 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
8010377f:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
80103786:	00 
80103787:	83 c4 10             	add    $0x10,%esp
8010378a:	eb da                	jmp    80103766 <exit+0x28>
  begin_op();
8010378c:	e8 b0 f1 ff ff       	call   80102941 <begin_op>
  iput(curproc->cwd);
80103791:	83 ec 0c             	sub    $0xc,%esp
80103794:	ff 76 68             	pushl  0x68(%esi)
80103797:	e8 ec de ff ff       	call   80101688 <iput>
  end_op();
8010379c:	e8 1a f2 ff ff       	call   801029bb <end_op>
  curproc->cwd = 0;
801037a1:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801037a8:	c7 04 24 20 ad 14 80 	movl   $0x8014ad20,(%esp)
801037af:	e8 7d 05 00 00       	call   80103d31 <acquire>
  wakeup1(curproc->parent);
801037b4:	8b 46 14             	mov    0x14(%esi),%eax
801037b7:	e8 0d fa ff ff       	call   801031c9 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037bc:	83 c4 10             	add    $0x10,%esp
801037bf:	bb 54 ad 14 80       	mov    $0x8014ad54,%ebx
801037c4:	eb 03                	jmp    801037c9 <exit+0x8b>
801037c6:	83 c3 7c             	add    $0x7c,%ebx
801037c9:	81 fb 54 cc 14 80    	cmp    $0x8014cc54,%ebx
801037cf:	73 1a                	jae    801037eb <exit+0xad>
    if(p->parent == curproc){
801037d1:	39 73 14             	cmp    %esi,0x14(%ebx)
801037d4:	75 f0                	jne    801037c6 <exit+0x88>
      p->parent = initproc;
801037d6:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
801037db:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
801037de:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
801037e2:	75 e2                	jne    801037c6 <exit+0x88>
        wakeup1(initproc);
801037e4:	e8 e0 f9 ff ff       	call   801031c9 <wakeup1>
801037e9:	eb db                	jmp    801037c6 <exit+0x88>
  curproc->state = ZOMBIE;
801037eb:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
801037f2:	e8 a4 fe ff ff       	call   8010369b <sched>
  panic("zombie exit");
801037f7:	83 ec 0c             	sub    $0xc,%esp
801037fa:	68 3d 6c 10 80       	push   $0x80106c3d
801037ff:	e8 44 cb ff ff       	call   80100348 <panic>

80103804 <yield>:
{
80103804:	55                   	push   %ebp
80103805:	89 e5                	mov    %esp,%ebp
80103807:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
8010380a:	68 20 ad 14 80       	push   $0x8014ad20
8010380f:	e8 1d 05 00 00       	call   80103d31 <acquire>
  myproc()->state = RUNNABLE;
80103814:	e8 76 fb ff ff       	call   8010338f <myproc>
80103819:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
80103820:	e8 76 fe ff ff       	call   8010369b <sched>
  release(&ptable.lock);
80103825:	c7 04 24 20 ad 14 80 	movl   $0x8014ad20,(%esp)
8010382c:	e8 65 05 00 00       	call   80103d96 <release>
}
80103831:	83 c4 10             	add    $0x10,%esp
80103834:	c9                   	leave  
80103835:	c3                   	ret    

80103836 <sleep>:
{
80103836:	55                   	push   %ebp
80103837:	89 e5                	mov    %esp,%ebp
80103839:	56                   	push   %esi
8010383a:	53                   	push   %ebx
8010383b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
8010383e:	e8 4c fb ff ff       	call   8010338f <myproc>
  if(p == 0)
80103843:	85 c0                	test   %eax,%eax
80103845:	74 66                	je     801038ad <sleep+0x77>
80103847:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103849:	85 db                	test   %ebx,%ebx
8010384b:	74 6d                	je     801038ba <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010384d:	81 fb 20 ad 14 80    	cmp    $0x8014ad20,%ebx
80103853:	74 18                	je     8010386d <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103855:	83 ec 0c             	sub    $0xc,%esp
80103858:	68 20 ad 14 80       	push   $0x8014ad20
8010385d:	e8 cf 04 00 00       	call   80103d31 <acquire>
    release(lk);
80103862:	89 1c 24             	mov    %ebx,(%esp)
80103865:	e8 2c 05 00 00       	call   80103d96 <release>
8010386a:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010386d:	8b 45 08             	mov    0x8(%ebp),%eax
80103870:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
80103873:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
8010387a:	e8 1c fe ff ff       	call   8010369b <sched>
  p->chan = 0;
8010387f:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
80103886:	81 fb 20 ad 14 80    	cmp    $0x8014ad20,%ebx
8010388c:	74 18                	je     801038a6 <sleep+0x70>
    release(&ptable.lock);
8010388e:	83 ec 0c             	sub    $0xc,%esp
80103891:	68 20 ad 14 80       	push   $0x8014ad20
80103896:	e8 fb 04 00 00       	call   80103d96 <release>
    acquire(lk);
8010389b:	89 1c 24             	mov    %ebx,(%esp)
8010389e:	e8 8e 04 00 00       	call   80103d31 <acquire>
801038a3:	83 c4 10             	add    $0x10,%esp
}
801038a6:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038a9:	5b                   	pop    %ebx
801038aa:	5e                   	pop    %esi
801038ab:	5d                   	pop    %ebp
801038ac:	c3                   	ret    
    panic("sleep");
801038ad:	83 ec 0c             	sub    $0xc,%esp
801038b0:	68 49 6c 10 80       	push   $0x80106c49
801038b5:	e8 8e ca ff ff       	call   80100348 <panic>
    panic("sleep without lk");
801038ba:	83 ec 0c             	sub    $0xc,%esp
801038bd:	68 4f 6c 10 80       	push   $0x80106c4f
801038c2:	e8 81 ca ff ff       	call   80100348 <panic>

801038c7 <wait>:
{
801038c7:	55                   	push   %ebp
801038c8:	89 e5                	mov    %esp,%ebp
801038ca:	56                   	push   %esi
801038cb:	53                   	push   %ebx
  struct proc *curproc = myproc();
801038cc:	e8 be fa ff ff       	call   8010338f <myproc>
801038d1:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
801038d3:	83 ec 0c             	sub    $0xc,%esp
801038d6:	68 20 ad 14 80       	push   $0x8014ad20
801038db:	e8 51 04 00 00       	call   80103d31 <acquire>
801038e0:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
801038e3:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801038e8:	bb 54 ad 14 80       	mov    $0x8014ad54,%ebx
801038ed:	eb 5b                	jmp    8010394a <wait+0x83>
        pid = p->pid;
801038ef:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
801038f2:	83 ec 0c             	sub    $0xc,%esp
801038f5:	ff 73 08             	pushl  0x8(%ebx)
801038f8:	e8 a7 e6 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
801038fd:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103904:	83 c4 04             	add    $0x4,%esp
80103907:	ff 73 04             	pushl  0x4(%ebx)
8010390a:	e8 73 2a 00 00       	call   80106382 <freevm>
        p->pid = 0;
8010390f:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103916:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010391d:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
80103921:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103928:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
8010392f:	c7 04 24 20 ad 14 80 	movl   $0x8014ad20,(%esp)
80103936:	e8 5b 04 00 00       	call   80103d96 <release>
        return pid;
8010393b:	83 c4 10             	add    $0x10,%esp
}
8010393e:	89 f0                	mov    %esi,%eax
80103940:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103943:	5b                   	pop    %ebx
80103944:	5e                   	pop    %esi
80103945:	5d                   	pop    %ebp
80103946:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103947:	83 c3 7c             	add    $0x7c,%ebx
8010394a:	81 fb 54 cc 14 80    	cmp    $0x8014cc54,%ebx
80103950:	73 12                	jae    80103964 <wait+0x9d>
      if(p->parent != curproc)
80103952:	39 73 14             	cmp    %esi,0x14(%ebx)
80103955:	75 f0                	jne    80103947 <wait+0x80>
      if(p->state == ZOMBIE){
80103957:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
8010395b:	74 92                	je     801038ef <wait+0x28>
      havekids = 1;
8010395d:	b8 01 00 00 00       	mov    $0x1,%eax
80103962:	eb e3                	jmp    80103947 <wait+0x80>
    if(!havekids || curproc->killed){
80103964:	85 c0                	test   %eax,%eax
80103966:	74 06                	je     8010396e <wait+0xa7>
80103968:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
8010396c:	74 17                	je     80103985 <wait+0xbe>
      release(&ptable.lock);
8010396e:	83 ec 0c             	sub    $0xc,%esp
80103971:	68 20 ad 14 80       	push   $0x8014ad20
80103976:	e8 1b 04 00 00       	call   80103d96 <release>
      return -1;
8010397b:	83 c4 10             	add    $0x10,%esp
8010397e:	be ff ff ff ff       	mov    $0xffffffff,%esi
80103983:	eb b9                	jmp    8010393e <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
80103985:	83 ec 08             	sub    $0x8,%esp
80103988:	68 20 ad 14 80       	push   $0x8014ad20
8010398d:	56                   	push   %esi
8010398e:	e8 a3 fe ff ff       	call   80103836 <sleep>
    havekids = 0;
80103993:	83 c4 10             	add    $0x10,%esp
80103996:	e9 48 ff ff ff       	jmp    801038e3 <wait+0x1c>

8010399b <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
8010399b:	55                   	push   %ebp
8010399c:	89 e5                	mov    %esp,%ebp
8010399e:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801039a1:	68 20 ad 14 80       	push   $0x8014ad20
801039a6:	e8 86 03 00 00       	call   80103d31 <acquire>
  wakeup1(chan);
801039ab:	8b 45 08             	mov    0x8(%ebp),%eax
801039ae:	e8 16 f8 ff ff       	call   801031c9 <wakeup1>
  release(&ptable.lock);
801039b3:	c7 04 24 20 ad 14 80 	movl   $0x8014ad20,(%esp)
801039ba:	e8 d7 03 00 00       	call   80103d96 <release>
}
801039bf:	83 c4 10             	add    $0x10,%esp
801039c2:	c9                   	leave  
801039c3:	c3                   	ret    

801039c4 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801039c4:	55                   	push   %ebp
801039c5:	89 e5                	mov    %esp,%ebp
801039c7:	53                   	push   %ebx
801039c8:	83 ec 10             	sub    $0x10,%esp
801039cb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801039ce:	68 20 ad 14 80       	push   $0x8014ad20
801039d3:	e8 59 03 00 00       	call   80103d31 <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039d8:	83 c4 10             	add    $0x10,%esp
801039db:	b8 54 ad 14 80       	mov    $0x8014ad54,%eax
801039e0:	3d 54 cc 14 80       	cmp    $0x8014cc54,%eax
801039e5:	73 3a                	jae    80103a21 <kill+0x5d>
    if(p->pid == pid){
801039e7:	39 58 10             	cmp    %ebx,0x10(%eax)
801039ea:	74 05                	je     801039f1 <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801039ec:	83 c0 7c             	add    $0x7c,%eax
801039ef:	eb ef                	jmp    801039e0 <kill+0x1c>
      p->killed = 1;
801039f1:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
801039f8:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
801039fc:	74 1a                	je     80103a18 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
801039fe:	83 ec 0c             	sub    $0xc,%esp
80103a01:	68 20 ad 14 80       	push   $0x8014ad20
80103a06:	e8 8b 03 00 00       	call   80103d96 <release>
      return 0;
80103a0b:	83 c4 10             	add    $0x10,%esp
80103a0e:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103a13:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a16:	c9                   	leave  
80103a17:	c3                   	ret    
        p->state = RUNNABLE;
80103a18:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103a1f:	eb dd                	jmp    801039fe <kill+0x3a>
  release(&ptable.lock);
80103a21:	83 ec 0c             	sub    $0xc,%esp
80103a24:	68 20 ad 14 80       	push   $0x8014ad20
80103a29:	e8 68 03 00 00       	call   80103d96 <release>
  return -1;
80103a2e:	83 c4 10             	add    $0x10,%esp
80103a31:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a36:	eb db                	jmp    80103a13 <kill+0x4f>

80103a38 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103a38:	55                   	push   %ebp
80103a39:	89 e5                	mov    %esp,%ebp
80103a3b:	56                   	push   %esi
80103a3c:	53                   	push   %ebx
80103a3d:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a40:	bb 54 ad 14 80       	mov    $0x8014ad54,%ebx
80103a45:	eb 33                	jmp    80103a7a <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103a47:	b8 60 6c 10 80       	mov    $0x80106c60,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103a4c:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103a4f:	52                   	push   %edx
80103a50:	50                   	push   %eax
80103a51:	ff 73 10             	pushl  0x10(%ebx)
80103a54:	68 64 6c 10 80       	push   $0x80106c64
80103a59:	e8 ad cb ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103a5e:	83 c4 10             	add    $0x10,%esp
80103a61:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103a65:	74 39                	je     80103aa0 <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103a67:	83 ec 0c             	sub    $0xc,%esp
80103a6a:	68 db 6f 10 80       	push   $0x80106fdb
80103a6f:	e8 97 cb ff ff       	call   8010060b <cprintf>
80103a74:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a77:	83 c3 7c             	add    $0x7c,%ebx
80103a7a:	81 fb 54 cc 14 80    	cmp    $0x8014cc54,%ebx
80103a80:	73 61                	jae    80103ae3 <procdump+0xab>
    if(p->state == UNUSED)
80103a82:	8b 43 0c             	mov    0xc(%ebx),%eax
80103a85:	85 c0                	test   %eax,%eax
80103a87:	74 ee                	je     80103a77 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103a89:	83 f8 05             	cmp    $0x5,%eax
80103a8c:	77 b9                	ja     80103a47 <procdump+0xf>
80103a8e:	8b 04 85 c0 6c 10 80 	mov    -0x7fef9340(,%eax,4),%eax
80103a95:	85 c0                	test   %eax,%eax
80103a97:	75 b3                	jne    80103a4c <procdump+0x14>
      state = "???";
80103a99:	b8 60 6c 10 80       	mov    $0x80106c60,%eax
80103a9e:	eb ac                	jmp    80103a4c <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103aa0:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103aa3:	8b 40 0c             	mov    0xc(%eax),%eax
80103aa6:	83 c0 08             	add    $0x8,%eax
80103aa9:	83 ec 08             	sub    $0x8,%esp
80103aac:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103aaf:	52                   	push   %edx
80103ab0:	50                   	push   %eax
80103ab1:	e8 5a 01 00 00       	call   80103c10 <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103ab6:	83 c4 10             	add    $0x10,%esp
80103ab9:	be 00 00 00 00       	mov    $0x0,%esi
80103abe:	eb 14                	jmp    80103ad4 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103ac0:	83 ec 08             	sub    $0x8,%esp
80103ac3:	50                   	push   %eax
80103ac4:	68 a1 66 10 80       	push   $0x801066a1
80103ac9:	e8 3d cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103ace:	83 c6 01             	add    $0x1,%esi
80103ad1:	83 c4 10             	add    $0x10,%esp
80103ad4:	83 fe 09             	cmp    $0x9,%esi
80103ad7:	7f 8e                	jg     80103a67 <procdump+0x2f>
80103ad9:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103add:	85 c0                	test   %eax,%eax
80103adf:	75 df                	jne    80103ac0 <procdump+0x88>
80103ae1:	eb 84                	jmp    80103a67 <procdump+0x2f>
  }
}
80103ae3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ae6:	5b                   	pop    %ebx
80103ae7:	5e                   	pop    %esi
80103ae8:	5d                   	pop    %ebp
80103ae9:	c3                   	ret    

80103aea <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103aea:	55                   	push   %ebp
80103aeb:	89 e5                	mov    %esp,%ebp
80103aed:	53                   	push   %ebx
80103aee:	83 ec 0c             	sub    $0xc,%esp
80103af1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103af4:	68 d8 6c 10 80       	push   $0x80106cd8
80103af9:	8d 43 04             	lea    0x4(%ebx),%eax
80103afc:	50                   	push   %eax
80103afd:	e8 f3 00 00 00       	call   80103bf5 <initlock>
  lk->name = name;
80103b02:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b05:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103b08:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b0e:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103b15:	83 c4 10             	add    $0x10,%esp
80103b18:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b1b:	c9                   	leave  
80103b1c:	c3                   	ret    

80103b1d <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103b1d:	55                   	push   %ebp
80103b1e:	89 e5                	mov    %esp,%ebp
80103b20:	56                   	push   %esi
80103b21:	53                   	push   %ebx
80103b22:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b25:	8d 73 04             	lea    0x4(%ebx),%esi
80103b28:	83 ec 0c             	sub    $0xc,%esp
80103b2b:	56                   	push   %esi
80103b2c:	e8 00 02 00 00       	call   80103d31 <acquire>
  while (lk->locked) {
80103b31:	83 c4 10             	add    $0x10,%esp
80103b34:	eb 0d                	jmp    80103b43 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103b36:	83 ec 08             	sub    $0x8,%esp
80103b39:	56                   	push   %esi
80103b3a:	53                   	push   %ebx
80103b3b:	e8 f6 fc ff ff       	call   80103836 <sleep>
80103b40:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103b43:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b46:	75 ee                	jne    80103b36 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103b48:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103b4e:	e8 3c f8 ff ff       	call   8010338f <myproc>
80103b53:	8b 40 10             	mov    0x10(%eax),%eax
80103b56:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103b59:	83 ec 0c             	sub    $0xc,%esp
80103b5c:	56                   	push   %esi
80103b5d:	e8 34 02 00 00       	call   80103d96 <release>
}
80103b62:	83 c4 10             	add    $0x10,%esp
80103b65:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b68:	5b                   	pop    %ebx
80103b69:	5e                   	pop    %esi
80103b6a:	5d                   	pop    %ebp
80103b6b:	c3                   	ret    

80103b6c <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103b6c:	55                   	push   %ebp
80103b6d:	89 e5                	mov    %esp,%ebp
80103b6f:	56                   	push   %esi
80103b70:	53                   	push   %ebx
80103b71:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b74:	8d 73 04             	lea    0x4(%ebx),%esi
80103b77:	83 ec 0c             	sub    $0xc,%esp
80103b7a:	56                   	push   %esi
80103b7b:	e8 b1 01 00 00       	call   80103d31 <acquire>
  lk->locked = 0;
80103b80:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b86:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103b8d:	89 1c 24             	mov    %ebx,(%esp)
80103b90:	e8 06 fe ff ff       	call   8010399b <wakeup>
  release(&lk->lk);
80103b95:	89 34 24             	mov    %esi,(%esp)
80103b98:	e8 f9 01 00 00       	call   80103d96 <release>
}
80103b9d:	83 c4 10             	add    $0x10,%esp
80103ba0:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103ba3:	5b                   	pop    %ebx
80103ba4:	5e                   	pop    %esi
80103ba5:	5d                   	pop    %ebp
80103ba6:	c3                   	ret    

80103ba7 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103ba7:	55                   	push   %ebp
80103ba8:	89 e5                	mov    %esp,%ebp
80103baa:	56                   	push   %esi
80103bab:	53                   	push   %ebx
80103bac:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103baf:	8d 73 04             	lea    0x4(%ebx),%esi
80103bb2:	83 ec 0c             	sub    $0xc,%esp
80103bb5:	56                   	push   %esi
80103bb6:	e8 76 01 00 00       	call   80103d31 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103bbb:	83 c4 10             	add    $0x10,%esp
80103bbe:	83 3b 00             	cmpl   $0x0,(%ebx)
80103bc1:	75 17                	jne    80103bda <holdingsleep+0x33>
80103bc3:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103bc8:	83 ec 0c             	sub    $0xc,%esp
80103bcb:	56                   	push   %esi
80103bcc:	e8 c5 01 00 00       	call   80103d96 <release>
  return r;
}
80103bd1:	89 d8                	mov    %ebx,%eax
80103bd3:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bd6:	5b                   	pop    %ebx
80103bd7:	5e                   	pop    %esi
80103bd8:	5d                   	pop    %ebp
80103bd9:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103bda:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103bdd:	e8 ad f7 ff ff       	call   8010338f <myproc>
80103be2:	3b 58 10             	cmp    0x10(%eax),%ebx
80103be5:	74 07                	je     80103bee <holdingsleep+0x47>
80103be7:	bb 00 00 00 00       	mov    $0x0,%ebx
80103bec:	eb da                	jmp    80103bc8 <holdingsleep+0x21>
80103bee:	bb 01 00 00 00       	mov    $0x1,%ebx
80103bf3:	eb d3                	jmp    80103bc8 <holdingsleep+0x21>

80103bf5 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103bf5:	55                   	push   %ebp
80103bf6:	89 e5                	mov    %esp,%ebp
80103bf8:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103bfb:	8b 55 0c             	mov    0xc(%ebp),%edx
80103bfe:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103c01:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103c07:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103c0e:	5d                   	pop    %ebp
80103c0f:	c3                   	ret    

80103c10 <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103c10:	55                   	push   %ebp
80103c11:	89 e5                	mov    %esp,%ebp
80103c13:	53                   	push   %ebx
80103c14:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103c17:	8b 45 08             	mov    0x8(%ebp),%eax
80103c1a:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103c1d:	b8 00 00 00 00       	mov    $0x0,%eax
80103c22:	83 f8 09             	cmp    $0x9,%eax
80103c25:	7f 25                	jg     80103c4c <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103c27:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103c2d:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103c33:	77 17                	ja     80103c4c <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103c35:	8b 5a 04             	mov    0x4(%edx),%ebx
80103c38:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103c3b:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103c3d:	83 c0 01             	add    $0x1,%eax
80103c40:	eb e0                	jmp    80103c22 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103c42:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103c49:	83 c0 01             	add    $0x1,%eax
80103c4c:	83 f8 09             	cmp    $0x9,%eax
80103c4f:	7e f1                	jle    80103c42 <getcallerpcs+0x32>
}
80103c51:	5b                   	pop    %ebx
80103c52:	5d                   	pop    %ebp
80103c53:	c3                   	ret    

80103c54 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103c54:	55                   	push   %ebp
80103c55:	89 e5                	mov    %esp,%ebp
80103c57:	53                   	push   %ebx
80103c58:	83 ec 04             	sub    $0x4,%esp
80103c5b:	9c                   	pushf  
80103c5c:	5b                   	pop    %ebx
  asm volatile("cli");
80103c5d:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103c5e:	e8 b5 f6 ff ff       	call   80103318 <mycpu>
80103c63:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c6a:	74 12                	je     80103c7e <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103c6c:	e8 a7 f6 ff ff       	call   80103318 <mycpu>
80103c71:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103c78:	83 c4 04             	add    $0x4,%esp
80103c7b:	5b                   	pop    %ebx
80103c7c:	5d                   	pop    %ebp
80103c7d:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103c7e:	e8 95 f6 ff ff       	call   80103318 <mycpu>
80103c83:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103c89:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103c8f:	eb db                	jmp    80103c6c <pushcli+0x18>

80103c91 <popcli>:

void
popcli(void)
{
80103c91:	55                   	push   %ebp
80103c92:	89 e5                	mov    %esp,%ebp
80103c94:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103c97:	9c                   	pushf  
80103c98:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103c99:	f6 c4 02             	test   $0x2,%ah
80103c9c:	75 28                	jne    80103cc6 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103c9e:	e8 75 f6 ff ff       	call   80103318 <mycpu>
80103ca3:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103ca9:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103cac:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103cb2:	85 d2                	test   %edx,%edx
80103cb4:	78 1d                	js     80103cd3 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103cb6:	e8 5d f6 ff ff       	call   80103318 <mycpu>
80103cbb:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103cc2:	74 1c                	je     80103ce0 <popcli+0x4f>
    sti();
}
80103cc4:	c9                   	leave  
80103cc5:	c3                   	ret    
    panic("popcli - interruptible");
80103cc6:	83 ec 0c             	sub    $0xc,%esp
80103cc9:	68 e3 6c 10 80       	push   $0x80106ce3
80103cce:	e8 75 c6 ff ff       	call   80100348 <panic>
    panic("popcli");
80103cd3:	83 ec 0c             	sub    $0xc,%esp
80103cd6:	68 fa 6c 10 80       	push   $0x80106cfa
80103cdb:	e8 68 c6 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103ce0:	e8 33 f6 ff ff       	call   80103318 <mycpu>
80103ce5:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103cec:	74 d6                	je     80103cc4 <popcli+0x33>
  asm volatile("sti");
80103cee:	fb                   	sti    
}
80103cef:	eb d3                	jmp    80103cc4 <popcli+0x33>

80103cf1 <holding>:
{
80103cf1:	55                   	push   %ebp
80103cf2:	89 e5                	mov    %esp,%ebp
80103cf4:	53                   	push   %ebx
80103cf5:	83 ec 04             	sub    $0x4,%esp
80103cf8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103cfb:	e8 54 ff ff ff       	call   80103c54 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103d00:	83 3b 00             	cmpl   $0x0,(%ebx)
80103d03:	75 12                	jne    80103d17 <holding+0x26>
80103d05:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103d0a:	e8 82 ff ff ff       	call   80103c91 <popcli>
}
80103d0f:	89 d8                	mov    %ebx,%eax
80103d11:	83 c4 04             	add    $0x4,%esp
80103d14:	5b                   	pop    %ebx
80103d15:	5d                   	pop    %ebp
80103d16:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103d17:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103d1a:	e8 f9 f5 ff ff       	call   80103318 <mycpu>
80103d1f:	39 c3                	cmp    %eax,%ebx
80103d21:	74 07                	je     80103d2a <holding+0x39>
80103d23:	bb 00 00 00 00       	mov    $0x0,%ebx
80103d28:	eb e0                	jmp    80103d0a <holding+0x19>
80103d2a:	bb 01 00 00 00       	mov    $0x1,%ebx
80103d2f:	eb d9                	jmp    80103d0a <holding+0x19>

80103d31 <acquire>:
{
80103d31:	55                   	push   %ebp
80103d32:	89 e5                	mov    %esp,%ebp
80103d34:	53                   	push   %ebx
80103d35:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103d38:	e8 17 ff ff ff       	call   80103c54 <pushcli>
  if(holding(lk))
80103d3d:	83 ec 0c             	sub    $0xc,%esp
80103d40:	ff 75 08             	pushl  0x8(%ebp)
80103d43:	e8 a9 ff ff ff       	call   80103cf1 <holding>
80103d48:	83 c4 10             	add    $0x10,%esp
80103d4b:	85 c0                	test   %eax,%eax
80103d4d:	75 3a                	jne    80103d89 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103d4f:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103d52:	b8 01 00 00 00       	mov    $0x1,%eax
80103d57:	f0 87 02             	lock xchg %eax,(%edx)
80103d5a:	85 c0                	test   %eax,%eax
80103d5c:	75 f1                	jne    80103d4f <acquire+0x1e>
  __sync_synchronize();
80103d5e:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103d63:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103d66:	e8 ad f5 ff ff       	call   80103318 <mycpu>
80103d6b:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103d6e:	8b 45 08             	mov    0x8(%ebp),%eax
80103d71:	83 c0 0c             	add    $0xc,%eax
80103d74:	83 ec 08             	sub    $0x8,%esp
80103d77:	50                   	push   %eax
80103d78:	8d 45 08             	lea    0x8(%ebp),%eax
80103d7b:	50                   	push   %eax
80103d7c:	e8 8f fe ff ff       	call   80103c10 <getcallerpcs>
}
80103d81:	83 c4 10             	add    $0x10,%esp
80103d84:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103d87:	c9                   	leave  
80103d88:	c3                   	ret    
    panic("acquire");
80103d89:	83 ec 0c             	sub    $0xc,%esp
80103d8c:	68 01 6d 10 80       	push   $0x80106d01
80103d91:	e8 b2 c5 ff ff       	call   80100348 <panic>

80103d96 <release>:
{
80103d96:	55                   	push   %ebp
80103d97:	89 e5                	mov    %esp,%ebp
80103d99:	53                   	push   %ebx
80103d9a:	83 ec 10             	sub    $0x10,%esp
80103d9d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103da0:	53                   	push   %ebx
80103da1:	e8 4b ff ff ff       	call   80103cf1 <holding>
80103da6:	83 c4 10             	add    $0x10,%esp
80103da9:	85 c0                	test   %eax,%eax
80103dab:	74 23                	je     80103dd0 <release+0x3a>
  lk->pcs[0] = 0;
80103dad:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103db4:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103dbb:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103dc0:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103dc6:	e8 c6 fe ff ff       	call   80103c91 <popcli>
}
80103dcb:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dce:	c9                   	leave  
80103dcf:	c3                   	ret    
    panic("release");
80103dd0:	83 ec 0c             	sub    $0xc,%esp
80103dd3:	68 09 6d 10 80       	push   $0x80106d09
80103dd8:	e8 6b c5 ff ff       	call   80100348 <panic>

80103ddd <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103ddd:	55                   	push   %ebp
80103dde:	89 e5                	mov    %esp,%ebp
80103de0:	57                   	push   %edi
80103de1:	53                   	push   %ebx
80103de2:	8b 55 08             	mov    0x8(%ebp),%edx
80103de5:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103de8:	f6 c2 03             	test   $0x3,%dl
80103deb:	75 05                	jne    80103df2 <memset+0x15>
80103ded:	f6 c1 03             	test   $0x3,%cl
80103df0:	74 0e                	je     80103e00 <memset+0x23>
  asm volatile("cld; rep stosb" :
80103df2:	89 d7                	mov    %edx,%edi
80103df4:	8b 45 0c             	mov    0xc(%ebp),%eax
80103df7:	fc                   	cld    
80103df8:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103dfa:	89 d0                	mov    %edx,%eax
80103dfc:	5b                   	pop    %ebx
80103dfd:	5f                   	pop    %edi
80103dfe:	5d                   	pop    %ebp
80103dff:	c3                   	ret    
    c &= 0xFF;
80103e00:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103e04:	c1 e9 02             	shr    $0x2,%ecx
80103e07:	89 f8                	mov    %edi,%eax
80103e09:	c1 e0 18             	shl    $0x18,%eax
80103e0c:	89 fb                	mov    %edi,%ebx
80103e0e:	c1 e3 10             	shl    $0x10,%ebx
80103e11:	09 d8                	or     %ebx,%eax
80103e13:	89 fb                	mov    %edi,%ebx
80103e15:	c1 e3 08             	shl    $0x8,%ebx
80103e18:	09 d8                	or     %ebx,%eax
80103e1a:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103e1c:	89 d7                	mov    %edx,%edi
80103e1e:	fc                   	cld    
80103e1f:	f3 ab                	rep stos %eax,%es:(%edi)
80103e21:	eb d7                	jmp    80103dfa <memset+0x1d>

80103e23 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103e23:	55                   	push   %ebp
80103e24:	89 e5                	mov    %esp,%ebp
80103e26:	56                   	push   %esi
80103e27:	53                   	push   %ebx
80103e28:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103e2b:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e2e:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e31:	8d 70 ff             	lea    -0x1(%eax),%esi
80103e34:	85 c0                	test   %eax,%eax
80103e36:	74 1c                	je     80103e54 <memcmp+0x31>
    if(*s1 != *s2)
80103e38:	0f b6 01             	movzbl (%ecx),%eax
80103e3b:	0f b6 1a             	movzbl (%edx),%ebx
80103e3e:	38 d8                	cmp    %bl,%al
80103e40:	75 0a                	jne    80103e4c <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103e42:	83 c1 01             	add    $0x1,%ecx
80103e45:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103e48:	89 f0                	mov    %esi,%eax
80103e4a:	eb e5                	jmp    80103e31 <memcmp+0xe>
      return *s1 - *s2;
80103e4c:	0f b6 c0             	movzbl %al,%eax
80103e4f:	0f b6 db             	movzbl %bl,%ebx
80103e52:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103e54:	5b                   	pop    %ebx
80103e55:	5e                   	pop    %esi
80103e56:	5d                   	pop    %ebp
80103e57:	c3                   	ret    

80103e58 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103e58:	55                   	push   %ebp
80103e59:	89 e5                	mov    %esp,%ebp
80103e5b:	56                   	push   %esi
80103e5c:	53                   	push   %ebx
80103e5d:	8b 45 08             	mov    0x8(%ebp),%eax
80103e60:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e63:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103e66:	39 c1                	cmp    %eax,%ecx
80103e68:	73 3a                	jae    80103ea4 <memmove+0x4c>
80103e6a:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103e6d:	39 c3                	cmp    %eax,%ebx
80103e6f:	76 37                	jbe    80103ea8 <memmove+0x50>
    s += n;
    d += n;
80103e71:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103e74:	eb 0d                	jmp    80103e83 <memmove+0x2b>
      *--d = *--s;
80103e76:	83 eb 01             	sub    $0x1,%ebx
80103e79:	83 e9 01             	sub    $0x1,%ecx
80103e7c:	0f b6 13             	movzbl (%ebx),%edx
80103e7f:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103e81:	89 f2                	mov    %esi,%edx
80103e83:	8d 72 ff             	lea    -0x1(%edx),%esi
80103e86:	85 d2                	test   %edx,%edx
80103e88:	75 ec                	jne    80103e76 <memmove+0x1e>
80103e8a:	eb 14                	jmp    80103ea0 <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103e8c:	0f b6 11             	movzbl (%ecx),%edx
80103e8f:	88 13                	mov    %dl,(%ebx)
80103e91:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103e94:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103e97:	89 f2                	mov    %esi,%edx
80103e99:	8d 72 ff             	lea    -0x1(%edx),%esi
80103e9c:	85 d2                	test   %edx,%edx
80103e9e:	75 ec                	jne    80103e8c <memmove+0x34>

  return dst;
}
80103ea0:	5b                   	pop    %ebx
80103ea1:	5e                   	pop    %esi
80103ea2:	5d                   	pop    %ebp
80103ea3:	c3                   	ret    
80103ea4:	89 c3                	mov    %eax,%ebx
80103ea6:	eb f1                	jmp    80103e99 <memmove+0x41>
80103ea8:	89 c3                	mov    %eax,%ebx
80103eaa:	eb ed                	jmp    80103e99 <memmove+0x41>

80103eac <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103eac:	55                   	push   %ebp
80103ead:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103eaf:	ff 75 10             	pushl  0x10(%ebp)
80103eb2:	ff 75 0c             	pushl  0xc(%ebp)
80103eb5:	ff 75 08             	pushl  0x8(%ebp)
80103eb8:	e8 9b ff ff ff       	call   80103e58 <memmove>
}
80103ebd:	c9                   	leave  
80103ebe:	c3                   	ret    

80103ebf <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103ebf:	55                   	push   %ebp
80103ec0:	89 e5                	mov    %esp,%ebp
80103ec2:	53                   	push   %ebx
80103ec3:	8b 55 08             	mov    0x8(%ebp),%edx
80103ec6:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103ec9:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103ecc:	eb 09                	jmp    80103ed7 <strncmp+0x18>
    n--, p++, q++;
80103ece:	83 e8 01             	sub    $0x1,%eax
80103ed1:	83 c2 01             	add    $0x1,%edx
80103ed4:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103ed7:	85 c0                	test   %eax,%eax
80103ed9:	74 0b                	je     80103ee6 <strncmp+0x27>
80103edb:	0f b6 1a             	movzbl (%edx),%ebx
80103ede:	84 db                	test   %bl,%bl
80103ee0:	74 04                	je     80103ee6 <strncmp+0x27>
80103ee2:	3a 19                	cmp    (%ecx),%bl
80103ee4:	74 e8                	je     80103ece <strncmp+0xf>
  if(n == 0)
80103ee6:	85 c0                	test   %eax,%eax
80103ee8:	74 0b                	je     80103ef5 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103eea:	0f b6 02             	movzbl (%edx),%eax
80103eed:	0f b6 11             	movzbl (%ecx),%edx
80103ef0:	29 d0                	sub    %edx,%eax
}
80103ef2:	5b                   	pop    %ebx
80103ef3:	5d                   	pop    %ebp
80103ef4:	c3                   	ret    
    return 0;
80103ef5:	b8 00 00 00 00       	mov    $0x0,%eax
80103efa:	eb f6                	jmp    80103ef2 <strncmp+0x33>

80103efc <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103efc:	55                   	push   %ebp
80103efd:	89 e5                	mov    %esp,%ebp
80103eff:	57                   	push   %edi
80103f00:	56                   	push   %esi
80103f01:	53                   	push   %ebx
80103f02:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f05:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103f08:	8b 45 08             	mov    0x8(%ebp),%eax
80103f0b:	eb 04                	jmp    80103f11 <strncpy+0x15>
80103f0d:	89 fb                	mov    %edi,%ebx
80103f0f:	89 f0                	mov    %esi,%eax
80103f11:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103f14:	85 c9                	test   %ecx,%ecx
80103f16:	7e 1d                	jle    80103f35 <strncpy+0x39>
80103f18:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f1b:	8d 70 01             	lea    0x1(%eax),%esi
80103f1e:	0f b6 1b             	movzbl (%ebx),%ebx
80103f21:	88 18                	mov    %bl,(%eax)
80103f23:	89 d1                	mov    %edx,%ecx
80103f25:	84 db                	test   %bl,%bl
80103f27:	75 e4                	jne    80103f0d <strncpy+0x11>
80103f29:	89 f0                	mov    %esi,%eax
80103f2b:	eb 08                	jmp    80103f35 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103f2d:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103f30:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103f32:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103f35:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103f38:	85 d2                	test   %edx,%edx
80103f3a:	7f f1                	jg     80103f2d <strncpy+0x31>
  return os;
}
80103f3c:	8b 45 08             	mov    0x8(%ebp),%eax
80103f3f:	5b                   	pop    %ebx
80103f40:	5e                   	pop    %esi
80103f41:	5f                   	pop    %edi
80103f42:	5d                   	pop    %ebp
80103f43:	c3                   	ret    

80103f44 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103f44:	55                   	push   %ebp
80103f45:	89 e5                	mov    %esp,%ebp
80103f47:	57                   	push   %edi
80103f48:	56                   	push   %esi
80103f49:	53                   	push   %ebx
80103f4a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f4d:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f50:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103f53:	85 d2                	test   %edx,%edx
80103f55:	7e 23                	jle    80103f7a <safestrcpy+0x36>
80103f57:	89 c1                	mov    %eax,%ecx
80103f59:	eb 04                	jmp    80103f5f <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103f5b:	89 fb                	mov    %edi,%ebx
80103f5d:	89 f1                	mov    %esi,%ecx
80103f5f:	83 ea 01             	sub    $0x1,%edx
80103f62:	85 d2                	test   %edx,%edx
80103f64:	7e 11                	jle    80103f77 <safestrcpy+0x33>
80103f66:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f69:	8d 71 01             	lea    0x1(%ecx),%esi
80103f6c:	0f b6 1b             	movzbl (%ebx),%ebx
80103f6f:	88 19                	mov    %bl,(%ecx)
80103f71:	84 db                	test   %bl,%bl
80103f73:	75 e6                	jne    80103f5b <safestrcpy+0x17>
80103f75:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103f77:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103f7a:	5b                   	pop    %ebx
80103f7b:	5e                   	pop    %esi
80103f7c:	5f                   	pop    %edi
80103f7d:	5d                   	pop    %ebp
80103f7e:	c3                   	ret    

80103f7f <strlen>:

int
strlen(const char *s)
{
80103f7f:	55                   	push   %ebp
80103f80:	89 e5                	mov    %esp,%ebp
80103f82:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103f85:	b8 00 00 00 00       	mov    $0x0,%eax
80103f8a:	eb 03                	jmp    80103f8f <strlen+0x10>
80103f8c:	83 c0 01             	add    $0x1,%eax
80103f8f:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103f93:	75 f7                	jne    80103f8c <strlen+0xd>
    ;
  return n;
}
80103f95:	5d                   	pop    %ebp
80103f96:	c3                   	ret    

80103f97 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103f97:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103f9b:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103f9f:	55                   	push   %ebp
  pushl %ebx
80103fa0:	53                   	push   %ebx
  pushl %esi
80103fa1:	56                   	push   %esi
  pushl %edi
80103fa2:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103fa3:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103fa5:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103fa7:	5f                   	pop    %edi
  popl %esi
80103fa8:	5e                   	pop    %esi
  popl %ebx
80103fa9:	5b                   	pop    %ebx
  popl %ebp
80103faa:	5d                   	pop    %ebp
  ret
80103fab:	c3                   	ret    

80103fac <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103fac:	55                   	push   %ebp
80103fad:	89 e5                	mov    %esp,%ebp
80103faf:	53                   	push   %ebx
80103fb0:	83 ec 04             	sub    $0x4,%esp
80103fb3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103fb6:	e8 d4 f3 ff ff       	call   8010338f <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103fbb:	8b 00                	mov    (%eax),%eax
80103fbd:	39 d8                	cmp    %ebx,%eax
80103fbf:	76 19                	jbe    80103fda <fetchint+0x2e>
80103fc1:	8d 53 04             	lea    0x4(%ebx),%edx
80103fc4:	39 d0                	cmp    %edx,%eax
80103fc6:	72 19                	jb     80103fe1 <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103fc8:	8b 13                	mov    (%ebx),%edx
80103fca:	8b 45 0c             	mov    0xc(%ebp),%eax
80103fcd:	89 10                	mov    %edx,(%eax)
  return 0;
80103fcf:	b8 00 00 00 00       	mov    $0x0,%eax
}
80103fd4:	83 c4 04             	add    $0x4,%esp
80103fd7:	5b                   	pop    %ebx
80103fd8:	5d                   	pop    %ebp
80103fd9:	c3                   	ret    
    return -1;
80103fda:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fdf:	eb f3                	jmp    80103fd4 <fetchint+0x28>
80103fe1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103fe6:	eb ec                	jmp    80103fd4 <fetchint+0x28>

80103fe8 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80103fe8:	55                   	push   %ebp
80103fe9:	89 e5                	mov    %esp,%ebp
80103feb:	53                   	push   %ebx
80103fec:	83 ec 04             	sub    $0x4,%esp
80103fef:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80103ff2:	e8 98 f3 ff ff       	call   8010338f <myproc>

  if(addr >= curproc->sz)
80103ff7:	39 18                	cmp    %ebx,(%eax)
80103ff9:	76 26                	jbe    80104021 <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80103ffb:	8b 55 0c             	mov    0xc(%ebp),%edx
80103ffe:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
80104000:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104002:	89 d8                	mov    %ebx,%eax
80104004:	39 d0                	cmp    %edx,%eax
80104006:	73 0e                	jae    80104016 <fetchstr+0x2e>
    if(*s == 0)
80104008:	80 38 00             	cmpb   $0x0,(%eax)
8010400b:	74 05                	je     80104012 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
8010400d:	83 c0 01             	add    $0x1,%eax
80104010:	eb f2                	jmp    80104004 <fetchstr+0x1c>
      return s - *pp;
80104012:	29 d8                	sub    %ebx,%eax
80104014:	eb 05                	jmp    8010401b <fetchstr+0x33>
  }
  return -1;
80104016:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
8010401b:	83 c4 04             	add    $0x4,%esp
8010401e:	5b                   	pop    %ebx
8010401f:	5d                   	pop    %ebp
80104020:	c3                   	ret    
    return -1;
80104021:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104026:	eb f3                	jmp    8010401b <fetchstr+0x33>

80104028 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104028:	55                   	push   %ebp
80104029:	89 e5                	mov    %esp,%ebp
8010402b:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010402e:	e8 5c f3 ff ff       	call   8010338f <myproc>
80104033:	8b 50 18             	mov    0x18(%eax),%edx
80104036:	8b 45 08             	mov    0x8(%ebp),%eax
80104039:	c1 e0 02             	shl    $0x2,%eax
8010403c:	03 42 44             	add    0x44(%edx),%eax
8010403f:	83 ec 08             	sub    $0x8,%esp
80104042:	ff 75 0c             	pushl  0xc(%ebp)
80104045:	83 c0 04             	add    $0x4,%eax
80104048:	50                   	push   %eax
80104049:	e8 5e ff ff ff       	call   80103fac <fetchint>
}
8010404e:	c9                   	leave  
8010404f:	c3                   	ret    

80104050 <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
80104050:	55                   	push   %ebp
80104051:	89 e5                	mov    %esp,%ebp
80104053:	56                   	push   %esi
80104054:	53                   	push   %ebx
80104055:	83 ec 10             	sub    $0x10,%esp
80104058:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
8010405b:	e8 2f f3 ff ff       	call   8010338f <myproc>
80104060:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104062:	83 ec 08             	sub    $0x8,%esp
80104065:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104068:	50                   	push   %eax
80104069:	ff 75 08             	pushl  0x8(%ebp)
8010406c:	e8 b7 ff ff ff       	call   80104028 <argint>
80104071:	83 c4 10             	add    $0x10,%esp
80104074:	85 c0                	test   %eax,%eax
80104076:	78 24                	js     8010409c <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
80104078:	85 db                	test   %ebx,%ebx
8010407a:	78 27                	js     801040a3 <argptr+0x53>
8010407c:	8b 16                	mov    (%esi),%edx
8010407e:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104081:	39 c2                	cmp    %eax,%edx
80104083:	76 25                	jbe    801040aa <argptr+0x5a>
80104085:	01 c3                	add    %eax,%ebx
80104087:	39 da                	cmp    %ebx,%edx
80104089:	72 26                	jb     801040b1 <argptr+0x61>
    return -1;
  *pp = (char*)i;
8010408b:	8b 55 0c             	mov    0xc(%ebp),%edx
8010408e:	89 02                	mov    %eax,(%edx)
  return 0;
80104090:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104095:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104098:	5b                   	pop    %ebx
80104099:	5e                   	pop    %esi
8010409a:	5d                   	pop    %ebp
8010409b:	c3                   	ret    
    return -1;
8010409c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040a1:	eb f2                	jmp    80104095 <argptr+0x45>
    return -1;
801040a3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040a8:	eb eb                	jmp    80104095 <argptr+0x45>
801040aa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040af:	eb e4                	jmp    80104095 <argptr+0x45>
801040b1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040b6:	eb dd                	jmp    80104095 <argptr+0x45>

801040b8 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801040b8:	55                   	push   %ebp
801040b9:	89 e5                	mov    %esp,%ebp
801040bb:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801040be:	8d 45 f4             	lea    -0xc(%ebp),%eax
801040c1:	50                   	push   %eax
801040c2:	ff 75 08             	pushl  0x8(%ebp)
801040c5:	e8 5e ff ff ff       	call   80104028 <argint>
801040ca:	83 c4 10             	add    $0x10,%esp
801040cd:	85 c0                	test   %eax,%eax
801040cf:	78 13                	js     801040e4 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801040d1:	83 ec 08             	sub    $0x8,%esp
801040d4:	ff 75 0c             	pushl  0xc(%ebp)
801040d7:	ff 75 f4             	pushl  -0xc(%ebp)
801040da:	e8 09 ff ff ff       	call   80103fe8 <fetchstr>
801040df:	83 c4 10             	add    $0x10,%esp
}
801040e2:	c9                   	leave  
801040e3:	c3                   	ret    
    return -1;
801040e4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e9:	eb f7                	jmp    801040e2 <argstr+0x2a>

801040eb <syscall>:
[SYS_dump_physmem]  sys_dump_physmem,
};

void
syscall(void)
{
801040eb:	55                   	push   %ebp
801040ec:	89 e5                	mov    %esp,%ebp
801040ee:	53                   	push   %ebx
801040ef:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
801040f2:	e8 98 f2 ff ff       	call   8010338f <myproc>
801040f7:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
801040f9:	8b 40 18             	mov    0x18(%eax),%eax
801040fc:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
801040ff:	8d 50 ff             	lea    -0x1(%eax),%edx
80104102:	83 fa 15             	cmp    $0x15,%edx
80104105:	77 18                	ja     8010411f <syscall+0x34>
80104107:	8b 14 85 40 6d 10 80 	mov    -0x7fef92c0(,%eax,4),%edx
8010410e:	85 d2                	test   %edx,%edx
80104110:	74 0d                	je     8010411f <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104112:	ff d2                	call   *%edx
80104114:	8b 53 18             	mov    0x18(%ebx),%edx
80104117:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
8010411a:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010411d:	c9                   	leave  
8010411e:	c3                   	ret    
            curproc->pid, curproc->name, num);
8010411f:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104122:	50                   	push   %eax
80104123:	52                   	push   %edx
80104124:	ff 73 10             	pushl  0x10(%ebx)
80104127:	68 11 6d 10 80       	push   $0x80106d11
8010412c:	e8 da c4 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
80104131:	8b 43 18             	mov    0x18(%ebx),%eax
80104134:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
8010413b:	83 c4 10             	add    $0x10,%esp
}
8010413e:	eb da                	jmp    8010411a <syscall+0x2f>

80104140 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
80104140:	55                   	push   %ebp
80104141:	89 e5                	mov    %esp,%ebp
80104143:	56                   	push   %esi
80104144:	53                   	push   %ebx
80104145:	83 ec 18             	sub    $0x18,%esp
80104148:	89 d6                	mov    %edx,%esi
8010414a:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010414c:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010414f:	52                   	push   %edx
80104150:	50                   	push   %eax
80104151:	e8 d2 fe ff ff       	call   80104028 <argint>
80104156:	83 c4 10             	add    $0x10,%esp
80104159:	85 c0                	test   %eax,%eax
8010415b:	78 2e                	js     8010418b <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010415d:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
80104161:	77 2f                	ja     80104192 <argfd+0x52>
80104163:	e8 27 f2 ff ff       	call   8010338f <myproc>
80104168:	8b 55 f4             	mov    -0xc(%ebp),%edx
8010416b:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
8010416f:	85 c0                	test   %eax,%eax
80104171:	74 26                	je     80104199 <argfd+0x59>
    return -1;
  if(pfd)
80104173:	85 f6                	test   %esi,%esi
80104175:	74 02                	je     80104179 <argfd+0x39>
    *pfd = fd;
80104177:	89 16                	mov    %edx,(%esi)
  if(pf)
80104179:	85 db                	test   %ebx,%ebx
8010417b:	74 23                	je     801041a0 <argfd+0x60>
    *pf = f;
8010417d:	89 03                	mov    %eax,(%ebx)
  return 0;
8010417f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104184:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104187:	5b                   	pop    %ebx
80104188:	5e                   	pop    %esi
80104189:	5d                   	pop    %ebp
8010418a:	c3                   	ret    
    return -1;
8010418b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104190:	eb f2                	jmp    80104184 <argfd+0x44>
    return -1;
80104192:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104197:	eb eb                	jmp    80104184 <argfd+0x44>
80104199:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010419e:	eb e4                	jmp    80104184 <argfd+0x44>
  return 0;
801041a0:	b8 00 00 00 00       	mov    $0x0,%eax
801041a5:	eb dd                	jmp    80104184 <argfd+0x44>

801041a7 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801041a7:	55                   	push   %ebp
801041a8:	89 e5                	mov    %esp,%ebp
801041aa:	53                   	push   %ebx
801041ab:	83 ec 04             	sub    $0x4,%esp
801041ae:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801041b0:	e8 da f1 ff ff       	call   8010338f <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801041b5:	ba 00 00 00 00       	mov    $0x0,%edx
801041ba:	83 fa 0f             	cmp    $0xf,%edx
801041bd:	7f 18                	jg     801041d7 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801041bf:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801041c4:	74 05                	je     801041cb <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801041c6:	83 c2 01             	add    $0x1,%edx
801041c9:	eb ef                	jmp    801041ba <fdalloc+0x13>
      curproc->ofile[fd] = f;
801041cb:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801041cf:	89 d0                	mov    %edx,%eax
801041d1:	83 c4 04             	add    $0x4,%esp
801041d4:	5b                   	pop    %ebx
801041d5:	5d                   	pop    %ebp
801041d6:	c3                   	ret    
  return -1;
801041d7:	ba ff ff ff ff       	mov    $0xffffffff,%edx
801041dc:	eb f1                	jmp    801041cf <fdalloc+0x28>

801041de <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
801041de:	55                   	push   %ebp
801041df:	89 e5                	mov    %esp,%ebp
801041e1:	56                   	push   %esi
801041e2:	53                   	push   %ebx
801041e3:	83 ec 10             	sub    $0x10,%esp
801041e6:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
801041e8:	b8 20 00 00 00       	mov    $0x20,%eax
801041ed:	89 c6                	mov    %eax,%esi
801041ef:	39 43 58             	cmp    %eax,0x58(%ebx)
801041f2:	76 2e                	jbe    80104222 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801041f4:	6a 10                	push   $0x10
801041f6:	50                   	push   %eax
801041f7:	8d 45 e8             	lea    -0x18(%ebp),%eax
801041fa:	50                   	push   %eax
801041fb:	53                   	push   %ebx
801041fc:	e8 72 d5 ff ff       	call   80101773 <readi>
80104201:	83 c4 10             	add    $0x10,%esp
80104204:	83 f8 10             	cmp    $0x10,%eax
80104207:	75 0c                	jne    80104215 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104209:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010420e:	75 1e                	jne    8010422e <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104210:	8d 46 10             	lea    0x10(%esi),%eax
80104213:	eb d8                	jmp    801041ed <isdirempty+0xf>
      panic("isdirempty: readi");
80104215:	83 ec 0c             	sub    $0xc,%esp
80104218:	68 9c 6d 10 80       	push   $0x80106d9c
8010421d:	e8 26 c1 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104222:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104227:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010422a:	5b                   	pop    %ebx
8010422b:	5e                   	pop    %esi
8010422c:	5d                   	pop    %ebp
8010422d:	c3                   	ret    
      return 0;
8010422e:	b8 00 00 00 00       	mov    $0x0,%eax
80104233:	eb f2                	jmp    80104227 <isdirempty+0x49>

80104235 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104235:	55                   	push   %ebp
80104236:	89 e5                	mov    %esp,%ebp
80104238:	57                   	push   %edi
80104239:	56                   	push   %esi
8010423a:	53                   	push   %ebx
8010423b:	83 ec 44             	sub    $0x44,%esp
8010423e:	89 55 c4             	mov    %edx,-0x3c(%ebp)
80104241:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104244:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104247:	8d 55 d6             	lea    -0x2a(%ebp),%edx
8010424a:	52                   	push   %edx
8010424b:	50                   	push   %eax
8010424c:	e8 a8 d9 ff ff       	call   80101bf9 <nameiparent>
80104251:	89 c6                	mov    %eax,%esi
80104253:	83 c4 10             	add    $0x10,%esp
80104256:	85 c0                	test   %eax,%eax
80104258:	0f 84 3a 01 00 00    	je     80104398 <create+0x163>
    return 0;
  ilock(dp);
8010425e:	83 ec 0c             	sub    $0xc,%esp
80104261:	50                   	push   %eax
80104262:	e8 1a d3 ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104267:	83 c4 0c             	add    $0xc,%esp
8010426a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010426d:	50                   	push   %eax
8010426e:	8d 45 d6             	lea    -0x2a(%ebp),%eax
80104271:	50                   	push   %eax
80104272:	56                   	push   %esi
80104273:	e8 38 d7 ff ff       	call   801019b0 <dirlookup>
80104278:	89 c3                	mov    %eax,%ebx
8010427a:	83 c4 10             	add    $0x10,%esp
8010427d:	85 c0                	test   %eax,%eax
8010427f:	74 3f                	je     801042c0 <create+0x8b>
    iunlockput(dp);
80104281:	83 ec 0c             	sub    $0xc,%esp
80104284:	56                   	push   %esi
80104285:	e8 9e d4 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
8010428a:	89 1c 24             	mov    %ebx,(%esp)
8010428d:	e8 ef d2 ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
80104292:	83 c4 10             	add    $0x10,%esp
80104295:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
8010429a:	75 11                	jne    801042ad <create+0x78>
8010429c:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801042a1:	75 0a                	jne    801042ad <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801042a3:	89 d8                	mov    %ebx,%eax
801042a5:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042a8:	5b                   	pop    %ebx
801042a9:	5e                   	pop    %esi
801042aa:	5f                   	pop    %edi
801042ab:	5d                   	pop    %ebp
801042ac:	c3                   	ret    
    iunlockput(ip);
801042ad:	83 ec 0c             	sub    $0xc,%esp
801042b0:	53                   	push   %ebx
801042b1:	e8 72 d4 ff ff       	call   80101728 <iunlockput>
    return 0;
801042b6:	83 c4 10             	add    $0x10,%esp
801042b9:	bb 00 00 00 00       	mov    $0x0,%ebx
801042be:	eb e3                	jmp    801042a3 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801042c0:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801042c4:	83 ec 08             	sub    $0x8,%esp
801042c7:	50                   	push   %eax
801042c8:	ff 36                	pushl  (%esi)
801042ca:	e8 af d0 ff ff       	call   8010137e <ialloc>
801042cf:	89 c3                	mov    %eax,%ebx
801042d1:	83 c4 10             	add    $0x10,%esp
801042d4:	85 c0                	test   %eax,%eax
801042d6:	74 55                	je     8010432d <create+0xf8>
  ilock(ip);
801042d8:	83 ec 0c             	sub    $0xc,%esp
801042db:	50                   	push   %eax
801042dc:	e8 a0 d2 ff ff       	call   80101581 <ilock>
  ip->major = major;
801042e1:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
801042e5:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
801042e9:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
801042ed:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
801042f3:	89 1c 24             	mov    %ebx,(%esp)
801042f6:	e8 25 d1 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
801042fb:	83 c4 10             	add    $0x10,%esp
801042fe:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104303:	74 35                	je     8010433a <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104305:	83 ec 04             	sub    $0x4,%esp
80104308:	ff 73 04             	pushl  0x4(%ebx)
8010430b:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010430e:	50                   	push   %eax
8010430f:	56                   	push   %esi
80104310:	e8 1b d8 ff ff       	call   80101b30 <dirlink>
80104315:	83 c4 10             	add    $0x10,%esp
80104318:	85 c0                	test   %eax,%eax
8010431a:	78 6f                	js     8010438b <create+0x156>
  iunlockput(dp);
8010431c:	83 ec 0c             	sub    $0xc,%esp
8010431f:	56                   	push   %esi
80104320:	e8 03 d4 ff ff       	call   80101728 <iunlockput>
  return ip;
80104325:	83 c4 10             	add    $0x10,%esp
80104328:	e9 76 ff ff ff       	jmp    801042a3 <create+0x6e>
    panic("create: ialloc");
8010432d:	83 ec 0c             	sub    $0xc,%esp
80104330:	68 ae 6d 10 80       	push   $0x80106dae
80104335:	e8 0e c0 ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
8010433a:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010433e:	83 c0 01             	add    $0x1,%eax
80104341:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104345:	83 ec 0c             	sub    $0xc,%esp
80104348:	56                   	push   %esi
80104349:	e8 d2 d0 ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010434e:	83 c4 0c             	add    $0xc,%esp
80104351:	ff 73 04             	pushl  0x4(%ebx)
80104354:	68 be 6d 10 80       	push   $0x80106dbe
80104359:	53                   	push   %ebx
8010435a:	e8 d1 d7 ff ff       	call   80101b30 <dirlink>
8010435f:	83 c4 10             	add    $0x10,%esp
80104362:	85 c0                	test   %eax,%eax
80104364:	78 18                	js     8010437e <create+0x149>
80104366:	83 ec 04             	sub    $0x4,%esp
80104369:	ff 76 04             	pushl  0x4(%esi)
8010436c:	68 bd 6d 10 80       	push   $0x80106dbd
80104371:	53                   	push   %ebx
80104372:	e8 b9 d7 ff ff       	call   80101b30 <dirlink>
80104377:	83 c4 10             	add    $0x10,%esp
8010437a:	85 c0                	test   %eax,%eax
8010437c:	79 87                	jns    80104305 <create+0xd0>
      panic("create dots");
8010437e:	83 ec 0c             	sub    $0xc,%esp
80104381:	68 c0 6d 10 80       	push   $0x80106dc0
80104386:	e8 bd bf ff ff       	call   80100348 <panic>
    panic("create: dirlink");
8010438b:	83 ec 0c             	sub    $0xc,%esp
8010438e:	68 cc 6d 10 80       	push   $0x80106dcc
80104393:	e8 b0 bf ff ff       	call   80100348 <panic>
    return 0;
80104398:	89 c3                	mov    %eax,%ebx
8010439a:	e9 04 ff ff ff       	jmp    801042a3 <create+0x6e>

8010439f <sys_dup>:
{
8010439f:	55                   	push   %ebp
801043a0:	89 e5                	mov    %esp,%ebp
801043a2:	53                   	push   %ebx
801043a3:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801043a6:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043a9:	ba 00 00 00 00       	mov    $0x0,%edx
801043ae:	b8 00 00 00 00       	mov    $0x0,%eax
801043b3:	e8 88 fd ff ff       	call   80104140 <argfd>
801043b8:	85 c0                	test   %eax,%eax
801043ba:	78 23                	js     801043df <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801043bc:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043bf:	e8 e3 fd ff ff       	call   801041a7 <fdalloc>
801043c4:	89 c3                	mov    %eax,%ebx
801043c6:	85 c0                	test   %eax,%eax
801043c8:	78 1c                	js     801043e6 <sys_dup+0x47>
  filedup(f);
801043ca:	83 ec 0c             	sub    $0xc,%esp
801043cd:	ff 75 f4             	pushl  -0xc(%ebp)
801043d0:	e8 b9 c8 ff ff       	call   80100c8e <filedup>
  return fd;
801043d5:	83 c4 10             	add    $0x10,%esp
}
801043d8:	89 d8                	mov    %ebx,%eax
801043da:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801043dd:	c9                   	leave  
801043de:	c3                   	ret    
    return -1;
801043df:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801043e4:	eb f2                	jmp    801043d8 <sys_dup+0x39>
    return -1;
801043e6:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801043eb:	eb eb                	jmp    801043d8 <sys_dup+0x39>

801043ed <sys_read>:
{
801043ed:	55                   	push   %ebp
801043ee:	89 e5                	mov    %esp,%ebp
801043f0:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
801043f3:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043f6:	ba 00 00 00 00       	mov    $0x0,%edx
801043fb:	b8 00 00 00 00       	mov    $0x0,%eax
80104400:	e8 3b fd ff ff       	call   80104140 <argfd>
80104405:	85 c0                	test   %eax,%eax
80104407:	78 43                	js     8010444c <sys_read+0x5f>
80104409:	83 ec 08             	sub    $0x8,%esp
8010440c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010440f:	50                   	push   %eax
80104410:	6a 02                	push   $0x2
80104412:	e8 11 fc ff ff       	call   80104028 <argint>
80104417:	83 c4 10             	add    $0x10,%esp
8010441a:	85 c0                	test   %eax,%eax
8010441c:	78 35                	js     80104453 <sys_read+0x66>
8010441e:	83 ec 04             	sub    $0x4,%esp
80104421:	ff 75 f0             	pushl  -0x10(%ebp)
80104424:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104427:	50                   	push   %eax
80104428:	6a 01                	push   $0x1
8010442a:	e8 21 fc ff ff       	call   80104050 <argptr>
8010442f:	83 c4 10             	add    $0x10,%esp
80104432:	85 c0                	test   %eax,%eax
80104434:	78 24                	js     8010445a <sys_read+0x6d>
  return fileread(f, p, n);
80104436:	83 ec 04             	sub    $0x4,%esp
80104439:	ff 75 f0             	pushl  -0x10(%ebp)
8010443c:	ff 75 ec             	pushl  -0x14(%ebp)
8010443f:	ff 75 f4             	pushl  -0xc(%ebp)
80104442:	e8 90 c9 ff ff       	call   80100dd7 <fileread>
80104447:	83 c4 10             	add    $0x10,%esp
}
8010444a:	c9                   	leave  
8010444b:	c3                   	ret    
    return -1;
8010444c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104451:	eb f7                	jmp    8010444a <sys_read+0x5d>
80104453:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104458:	eb f0                	jmp    8010444a <sys_read+0x5d>
8010445a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010445f:	eb e9                	jmp    8010444a <sys_read+0x5d>

80104461 <sys_write>:
{
80104461:	55                   	push   %ebp
80104462:	89 e5                	mov    %esp,%ebp
80104464:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104467:	8d 4d f4             	lea    -0xc(%ebp),%ecx
8010446a:	ba 00 00 00 00       	mov    $0x0,%edx
8010446f:	b8 00 00 00 00       	mov    $0x0,%eax
80104474:	e8 c7 fc ff ff       	call   80104140 <argfd>
80104479:	85 c0                	test   %eax,%eax
8010447b:	78 43                	js     801044c0 <sys_write+0x5f>
8010447d:	83 ec 08             	sub    $0x8,%esp
80104480:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104483:	50                   	push   %eax
80104484:	6a 02                	push   $0x2
80104486:	e8 9d fb ff ff       	call   80104028 <argint>
8010448b:	83 c4 10             	add    $0x10,%esp
8010448e:	85 c0                	test   %eax,%eax
80104490:	78 35                	js     801044c7 <sys_write+0x66>
80104492:	83 ec 04             	sub    $0x4,%esp
80104495:	ff 75 f0             	pushl  -0x10(%ebp)
80104498:	8d 45 ec             	lea    -0x14(%ebp),%eax
8010449b:	50                   	push   %eax
8010449c:	6a 01                	push   $0x1
8010449e:	e8 ad fb ff ff       	call   80104050 <argptr>
801044a3:	83 c4 10             	add    $0x10,%esp
801044a6:	85 c0                	test   %eax,%eax
801044a8:	78 24                	js     801044ce <sys_write+0x6d>
  return filewrite(f, p, n);
801044aa:	83 ec 04             	sub    $0x4,%esp
801044ad:	ff 75 f0             	pushl  -0x10(%ebp)
801044b0:	ff 75 ec             	pushl  -0x14(%ebp)
801044b3:	ff 75 f4             	pushl  -0xc(%ebp)
801044b6:	e8 a1 c9 ff ff       	call   80100e5c <filewrite>
801044bb:	83 c4 10             	add    $0x10,%esp
}
801044be:	c9                   	leave  
801044bf:	c3                   	ret    
    return -1;
801044c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044c5:	eb f7                	jmp    801044be <sys_write+0x5d>
801044c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044cc:	eb f0                	jmp    801044be <sys_write+0x5d>
801044ce:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044d3:	eb e9                	jmp    801044be <sys_write+0x5d>

801044d5 <sys_close>:
{
801044d5:	55                   	push   %ebp
801044d6:	89 e5                	mov    %esp,%ebp
801044d8:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
801044db:	8d 4d f0             	lea    -0x10(%ebp),%ecx
801044de:	8d 55 f4             	lea    -0xc(%ebp),%edx
801044e1:	b8 00 00 00 00       	mov    $0x0,%eax
801044e6:	e8 55 fc ff ff       	call   80104140 <argfd>
801044eb:	85 c0                	test   %eax,%eax
801044ed:	78 25                	js     80104514 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
801044ef:	e8 9b ee ff ff       	call   8010338f <myproc>
801044f4:	8b 55 f4             	mov    -0xc(%ebp),%edx
801044f7:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
801044fe:	00 
  fileclose(f);
801044ff:	83 ec 0c             	sub    $0xc,%esp
80104502:	ff 75 f0             	pushl  -0x10(%ebp)
80104505:	e8 c9 c7 ff ff       	call   80100cd3 <fileclose>
  return 0;
8010450a:	83 c4 10             	add    $0x10,%esp
8010450d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104512:	c9                   	leave  
80104513:	c3                   	ret    
    return -1;
80104514:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104519:	eb f7                	jmp    80104512 <sys_close+0x3d>

8010451b <sys_fstat>:
{
8010451b:	55                   	push   %ebp
8010451c:	89 e5                	mov    %esp,%ebp
8010451e:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
80104521:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104524:	ba 00 00 00 00       	mov    $0x0,%edx
80104529:	b8 00 00 00 00       	mov    $0x0,%eax
8010452e:	e8 0d fc ff ff       	call   80104140 <argfd>
80104533:	85 c0                	test   %eax,%eax
80104535:	78 2a                	js     80104561 <sys_fstat+0x46>
80104537:	83 ec 04             	sub    $0x4,%esp
8010453a:	6a 14                	push   $0x14
8010453c:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010453f:	50                   	push   %eax
80104540:	6a 01                	push   $0x1
80104542:	e8 09 fb ff ff       	call   80104050 <argptr>
80104547:	83 c4 10             	add    $0x10,%esp
8010454a:	85 c0                	test   %eax,%eax
8010454c:	78 1a                	js     80104568 <sys_fstat+0x4d>
  return filestat(f, st);
8010454e:	83 ec 08             	sub    $0x8,%esp
80104551:	ff 75 f0             	pushl  -0x10(%ebp)
80104554:	ff 75 f4             	pushl  -0xc(%ebp)
80104557:	e8 34 c8 ff ff       	call   80100d90 <filestat>
8010455c:	83 c4 10             	add    $0x10,%esp
}
8010455f:	c9                   	leave  
80104560:	c3                   	ret    
    return -1;
80104561:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104566:	eb f7                	jmp    8010455f <sys_fstat+0x44>
80104568:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010456d:	eb f0                	jmp    8010455f <sys_fstat+0x44>

8010456f <sys_link>:
{
8010456f:	55                   	push   %ebp
80104570:	89 e5                	mov    %esp,%ebp
80104572:	56                   	push   %esi
80104573:	53                   	push   %ebx
80104574:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
80104577:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010457a:	50                   	push   %eax
8010457b:	6a 00                	push   $0x0
8010457d:	e8 36 fb ff ff       	call   801040b8 <argstr>
80104582:	83 c4 10             	add    $0x10,%esp
80104585:	85 c0                	test   %eax,%eax
80104587:	0f 88 32 01 00 00    	js     801046bf <sys_link+0x150>
8010458d:	83 ec 08             	sub    $0x8,%esp
80104590:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104593:	50                   	push   %eax
80104594:	6a 01                	push   $0x1
80104596:	e8 1d fb ff ff       	call   801040b8 <argstr>
8010459b:	83 c4 10             	add    $0x10,%esp
8010459e:	85 c0                	test   %eax,%eax
801045a0:	0f 88 20 01 00 00    	js     801046c6 <sys_link+0x157>
  begin_op();
801045a6:	e8 96 e3 ff ff       	call   80102941 <begin_op>
  if((ip = namei(old)) == 0){
801045ab:	83 ec 0c             	sub    $0xc,%esp
801045ae:	ff 75 e0             	pushl  -0x20(%ebp)
801045b1:	e8 2b d6 ff ff       	call   80101be1 <namei>
801045b6:	89 c3                	mov    %eax,%ebx
801045b8:	83 c4 10             	add    $0x10,%esp
801045bb:	85 c0                	test   %eax,%eax
801045bd:	0f 84 99 00 00 00    	je     8010465c <sys_link+0xed>
  ilock(ip);
801045c3:	83 ec 0c             	sub    $0xc,%esp
801045c6:	50                   	push   %eax
801045c7:	e8 b5 cf ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
801045cc:	83 c4 10             	add    $0x10,%esp
801045cf:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801045d4:	0f 84 8e 00 00 00    	je     80104668 <sys_link+0xf9>
  ip->nlink++;
801045da:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801045de:	83 c0 01             	add    $0x1,%eax
801045e1:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801045e5:	83 ec 0c             	sub    $0xc,%esp
801045e8:	53                   	push   %ebx
801045e9:	e8 32 ce ff ff       	call   80101420 <iupdate>
  iunlock(ip);
801045ee:	89 1c 24             	mov    %ebx,(%esp)
801045f1:	e8 4d d0 ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
801045f6:	83 c4 08             	add    $0x8,%esp
801045f9:	8d 45 ea             	lea    -0x16(%ebp),%eax
801045fc:	50                   	push   %eax
801045fd:	ff 75 e4             	pushl  -0x1c(%ebp)
80104600:	e8 f4 d5 ff ff       	call   80101bf9 <nameiparent>
80104605:	89 c6                	mov    %eax,%esi
80104607:	83 c4 10             	add    $0x10,%esp
8010460a:	85 c0                	test   %eax,%eax
8010460c:	74 7e                	je     8010468c <sys_link+0x11d>
  ilock(dp);
8010460e:	83 ec 0c             	sub    $0xc,%esp
80104611:	50                   	push   %eax
80104612:	e8 6a cf ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104617:	83 c4 10             	add    $0x10,%esp
8010461a:	8b 03                	mov    (%ebx),%eax
8010461c:	39 06                	cmp    %eax,(%esi)
8010461e:	75 60                	jne    80104680 <sys_link+0x111>
80104620:	83 ec 04             	sub    $0x4,%esp
80104623:	ff 73 04             	pushl  0x4(%ebx)
80104626:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104629:	50                   	push   %eax
8010462a:	56                   	push   %esi
8010462b:	e8 00 d5 ff ff       	call   80101b30 <dirlink>
80104630:	83 c4 10             	add    $0x10,%esp
80104633:	85 c0                	test   %eax,%eax
80104635:	78 49                	js     80104680 <sys_link+0x111>
  iunlockput(dp);
80104637:	83 ec 0c             	sub    $0xc,%esp
8010463a:	56                   	push   %esi
8010463b:	e8 e8 d0 ff ff       	call   80101728 <iunlockput>
  iput(ip);
80104640:	89 1c 24             	mov    %ebx,(%esp)
80104643:	e8 40 d0 ff ff       	call   80101688 <iput>
  end_op();
80104648:	e8 6e e3 ff ff       	call   801029bb <end_op>
  return 0;
8010464d:	83 c4 10             	add    $0x10,%esp
80104650:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104655:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104658:	5b                   	pop    %ebx
80104659:	5e                   	pop    %esi
8010465a:	5d                   	pop    %ebp
8010465b:	c3                   	ret    
    end_op();
8010465c:	e8 5a e3 ff ff       	call   801029bb <end_op>
    return -1;
80104661:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104666:	eb ed                	jmp    80104655 <sys_link+0xe6>
    iunlockput(ip);
80104668:	83 ec 0c             	sub    $0xc,%esp
8010466b:	53                   	push   %ebx
8010466c:	e8 b7 d0 ff ff       	call   80101728 <iunlockput>
    end_op();
80104671:	e8 45 e3 ff ff       	call   801029bb <end_op>
    return -1;
80104676:	83 c4 10             	add    $0x10,%esp
80104679:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010467e:	eb d5                	jmp    80104655 <sys_link+0xe6>
    iunlockput(dp);
80104680:	83 ec 0c             	sub    $0xc,%esp
80104683:	56                   	push   %esi
80104684:	e8 9f d0 ff ff       	call   80101728 <iunlockput>
    goto bad;
80104689:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
8010468c:	83 ec 0c             	sub    $0xc,%esp
8010468f:	53                   	push   %ebx
80104690:	e8 ec ce ff ff       	call   80101581 <ilock>
  ip->nlink--;
80104695:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
80104699:	83 e8 01             	sub    $0x1,%eax
8010469c:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046a0:	89 1c 24             	mov    %ebx,(%esp)
801046a3:	e8 78 cd ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801046a8:	89 1c 24             	mov    %ebx,(%esp)
801046ab:	e8 78 d0 ff ff       	call   80101728 <iunlockput>
  end_op();
801046b0:	e8 06 e3 ff ff       	call   801029bb <end_op>
  return -1;
801046b5:	83 c4 10             	add    $0x10,%esp
801046b8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046bd:	eb 96                	jmp    80104655 <sys_link+0xe6>
    return -1;
801046bf:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046c4:	eb 8f                	jmp    80104655 <sys_link+0xe6>
801046c6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046cb:	eb 88                	jmp    80104655 <sys_link+0xe6>

801046cd <sys_unlink>:
{
801046cd:	55                   	push   %ebp
801046ce:	89 e5                	mov    %esp,%ebp
801046d0:	57                   	push   %edi
801046d1:	56                   	push   %esi
801046d2:	53                   	push   %ebx
801046d3:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
801046d6:	8d 45 c4             	lea    -0x3c(%ebp),%eax
801046d9:	50                   	push   %eax
801046da:	6a 00                	push   $0x0
801046dc:	e8 d7 f9 ff ff       	call   801040b8 <argstr>
801046e1:	83 c4 10             	add    $0x10,%esp
801046e4:	85 c0                	test   %eax,%eax
801046e6:	0f 88 83 01 00 00    	js     8010486f <sys_unlink+0x1a2>
  begin_op();
801046ec:	e8 50 e2 ff ff       	call   80102941 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
801046f1:	83 ec 08             	sub    $0x8,%esp
801046f4:	8d 45 ca             	lea    -0x36(%ebp),%eax
801046f7:	50                   	push   %eax
801046f8:	ff 75 c4             	pushl  -0x3c(%ebp)
801046fb:	e8 f9 d4 ff ff       	call   80101bf9 <nameiparent>
80104700:	89 c6                	mov    %eax,%esi
80104702:	83 c4 10             	add    $0x10,%esp
80104705:	85 c0                	test   %eax,%eax
80104707:	0f 84 ed 00 00 00    	je     801047fa <sys_unlink+0x12d>
  ilock(dp);
8010470d:	83 ec 0c             	sub    $0xc,%esp
80104710:	50                   	push   %eax
80104711:	e8 6b ce ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104716:	83 c4 08             	add    $0x8,%esp
80104719:	68 be 6d 10 80       	push   $0x80106dbe
8010471e:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104721:	50                   	push   %eax
80104722:	e8 74 d2 ff ff       	call   8010199b <namecmp>
80104727:	83 c4 10             	add    $0x10,%esp
8010472a:	85 c0                	test   %eax,%eax
8010472c:	0f 84 fc 00 00 00    	je     8010482e <sys_unlink+0x161>
80104732:	83 ec 08             	sub    $0x8,%esp
80104735:	68 bd 6d 10 80       	push   $0x80106dbd
8010473a:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010473d:	50                   	push   %eax
8010473e:	e8 58 d2 ff ff       	call   8010199b <namecmp>
80104743:	83 c4 10             	add    $0x10,%esp
80104746:	85 c0                	test   %eax,%eax
80104748:	0f 84 e0 00 00 00    	je     8010482e <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010474e:	83 ec 04             	sub    $0x4,%esp
80104751:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104754:	50                   	push   %eax
80104755:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104758:	50                   	push   %eax
80104759:	56                   	push   %esi
8010475a:	e8 51 d2 ff ff       	call   801019b0 <dirlookup>
8010475f:	89 c3                	mov    %eax,%ebx
80104761:	83 c4 10             	add    $0x10,%esp
80104764:	85 c0                	test   %eax,%eax
80104766:	0f 84 c2 00 00 00    	je     8010482e <sys_unlink+0x161>
  ilock(ip);
8010476c:	83 ec 0c             	sub    $0xc,%esp
8010476f:	50                   	push   %eax
80104770:	e8 0c ce ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
80104775:	83 c4 10             	add    $0x10,%esp
80104778:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
8010477d:	0f 8e 83 00 00 00    	jle    80104806 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104783:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104788:	0f 84 85 00 00 00    	je     80104813 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
8010478e:	83 ec 04             	sub    $0x4,%esp
80104791:	6a 10                	push   $0x10
80104793:	6a 00                	push   $0x0
80104795:	8d 7d d8             	lea    -0x28(%ebp),%edi
80104798:	57                   	push   %edi
80104799:	e8 3f f6 ff ff       	call   80103ddd <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
8010479e:	6a 10                	push   $0x10
801047a0:	ff 75 c0             	pushl  -0x40(%ebp)
801047a3:	57                   	push   %edi
801047a4:	56                   	push   %esi
801047a5:	e8 c6 d0 ff ff       	call   80101870 <writei>
801047aa:	83 c4 20             	add    $0x20,%esp
801047ad:	83 f8 10             	cmp    $0x10,%eax
801047b0:	0f 85 90 00 00 00    	jne    80104846 <sys_unlink+0x179>
  if(ip->type == T_DIR){
801047b6:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047bb:	0f 84 92 00 00 00    	je     80104853 <sys_unlink+0x186>
  iunlockput(dp);
801047c1:	83 ec 0c             	sub    $0xc,%esp
801047c4:	56                   	push   %esi
801047c5:	e8 5e cf ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
801047ca:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801047ce:	83 e8 01             	sub    $0x1,%eax
801047d1:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801047d5:	89 1c 24             	mov    %ebx,(%esp)
801047d8:	e8 43 cc ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801047dd:	89 1c 24             	mov    %ebx,(%esp)
801047e0:	e8 43 cf ff ff       	call   80101728 <iunlockput>
  end_op();
801047e5:	e8 d1 e1 ff ff       	call   801029bb <end_op>
  return 0;
801047ea:	83 c4 10             	add    $0x10,%esp
801047ed:	b8 00 00 00 00       	mov    $0x0,%eax
}
801047f2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801047f5:	5b                   	pop    %ebx
801047f6:	5e                   	pop    %esi
801047f7:	5f                   	pop    %edi
801047f8:	5d                   	pop    %ebp
801047f9:	c3                   	ret    
    end_op();
801047fa:	e8 bc e1 ff ff       	call   801029bb <end_op>
    return -1;
801047ff:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104804:	eb ec                	jmp    801047f2 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104806:	83 ec 0c             	sub    $0xc,%esp
80104809:	68 dc 6d 10 80       	push   $0x80106ddc
8010480e:	e8 35 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104813:	89 d8                	mov    %ebx,%eax
80104815:	e8 c4 f9 ff ff       	call   801041de <isdirempty>
8010481a:	85 c0                	test   %eax,%eax
8010481c:	0f 85 6c ff ff ff    	jne    8010478e <sys_unlink+0xc1>
    iunlockput(ip);
80104822:	83 ec 0c             	sub    $0xc,%esp
80104825:	53                   	push   %ebx
80104826:	e8 fd ce ff ff       	call   80101728 <iunlockput>
    goto bad;
8010482b:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010482e:	83 ec 0c             	sub    $0xc,%esp
80104831:	56                   	push   %esi
80104832:	e8 f1 ce ff ff       	call   80101728 <iunlockput>
  end_op();
80104837:	e8 7f e1 ff ff       	call   801029bb <end_op>
  return -1;
8010483c:	83 c4 10             	add    $0x10,%esp
8010483f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104844:	eb ac                	jmp    801047f2 <sys_unlink+0x125>
    panic("unlink: writei");
80104846:	83 ec 0c             	sub    $0xc,%esp
80104849:	68 ee 6d 10 80       	push   $0x80106dee
8010484e:	e8 f5 ba ff ff       	call   80100348 <panic>
    dp->nlink--;
80104853:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104857:	83 e8 01             	sub    $0x1,%eax
8010485a:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010485e:	83 ec 0c             	sub    $0xc,%esp
80104861:	56                   	push   %esi
80104862:	e8 b9 cb ff ff       	call   80101420 <iupdate>
80104867:	83 c4 10             	add    $0x10,%esp
8010486a:	e9 52 ff ff ff       	jmp    801047c1 <sys_unlink+0xf4>
    return -1;
8010486f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104874:	e9 79 ff ff ff       	jmp    801047f2 <sys_unlink+0x125>

80104879 <sys_open>:

int
sys_open(void)
{
80104879:	55                   	push   %ebp
8010487a:	89 e5                	mov    %esp,%ebp
8010487c:	57                   	push   %edi
8010487d:	56                   	push   %esi
8010487e:	53                   	push   %ebx
8010487f:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
80104882:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80104885:	50                   	push   %eax
80104886:	6a 00                	push   $0x0
80104888:	e8 2b f8 ff ff       	call   801040b8 <argstr>
8010488d:	83 c4 10             	add    $0x10,%esp
80104890:	85 c0                	test   %eax,%eax
80104892:	0f 88 30 01 00 00    	js     801049c8 <sys_open+0x14f>
80104898:	83 ec 08             	sub    $0x8,%esp
8010489b:	8d 45 e0             	lea    -0x20(%ebp),%eax
8010489e:	50                   	push   %eax
8010489f:	6a 01                	push   $0x1
801048a1:	e8 82 f7 ff ff       	call   80104028 <argint>
801048a6:	83 c4 10             	add    $0x10,%esp
801048a9:	85 c0                	test   %eax,%eax
801048ab:	0f 88 21 01 00 00    	js     801049d2 <sys_open+0x159>
    return -1;

  begin_op();
801048b1:	e8 8b e0 ff ff       	call   80102941 <begin_op>

  if(omode & O_CREATE){
801048b6:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801048ba:	0f 84 84 00 00 00    	je     80104944 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801048c0:	83 ec 0c             	sub    $0xc,%esp
801048c3:	6a 00                	push   $0x0
801048c5:	b9 00 00 00 00       	mov    $0x0,%ecx
801048ca:	ba 02 00 00 00       	mov    $0x2,%edx
801048cf:	8b 45 e4             	mov    -0x1c(%ebp),%eax
801048d2:	e8 5e f9 ff ff       	call   80104235 <create>
801048d7:	89 c6                	mov    %eax,%esi
    if(ip == 0){
801048d9:	83 c4 10             	add    $0x10,%esp
801048dc:	85 c0                	test   %eax,%eax
801048de:	74 58                	je     80104938 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
801048e0:	e8 48 c3 ff ff       	call   80100c2d <filealloc>
801048e5:	89 c3                	mov    %eax,%ebx
801048e7:	85 c0                	test   %eax,%eax
801048e9:	0f 84 ae 00 00 00    	je     8010499d <sys_open+0x124>
801048ef:	e8 b3 f8 ff ff       	call   801041a7 <fdalloc>
801048f4:	89 c7                	mov    %eax,%edi
801048f6:	85 c0                	test   %eax,%eax
801048f8:	0f 88 9f 00 00 00    	js     8010499d <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
801048fe:	83 ec 0c             	sub    $0xc,%esp
80104901:	56                   	push   %esi
80104902:	e8 3c cd ff ff       	call   80101643 <iunlock>
  end_op();
80104907:	e8 af e0 ff ff       	call   801029bb <end_op>

  f->type = FD_INODE;
8010490c:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104912:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104915:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
8010491c:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010491f:	83 c4 10             	add    $0x10,%esp
80104922:	a8 01                	test   $0x1,%al
80104924:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104928:	a8 03                	test   $0x3,%al
8010492a:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010492e:	89 f8                	mov    %edi,%eax
80104930:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104933:	5b                   	pop    %ebx
80104934:	5e                   	pop    %esi
80104935:	5f                   	pop    %edi
80104936:	5d                   	pop    %ebp
80104937:	c3                   	ret    
      end_op();
80104938:	e8 7e e0 ff ff       	call   801029bb <end_op>
      return -1;
8010493d:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104942:	eb ea                	jmp    8010492e <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104944:	83 ec 0c             	sub    $0xc,%esp
80104947:	ff 75 e4             	pushl  -0x1c(%ebp)
8010494a:	e8 92 d2 ff ff       	call   80101be1 <namei>
8010494f:	89 c6                	mov    %eax,%esi
80104951:	83 c4 10             	add    $0x10,%esp
80104954:	85 c0                	test   %eax,%eax
80104956:	74 39                	je     80104991 <sys_open+0x118>
    ilock(ip);
80104958:	83 ec 0c             	sub    $0xc,%esp
8010495b:	50                   	push   %eax
8010495c:	e8 20 cc ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
80104961:	83 c4 10             	add    $0x10,%esp
80104964:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104969:	0f 85 71 ff ff ff    	jne    801048e0 <sys_open+0x67>
8010496f:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
80104973:	0f 84 67 ff ff ff    	je     801048e0 <sys_open+0x67>
      iunlockput(ip);
80104979:	83 ec 0c             	sub    $0xc,%esp
8010497c:	56                   	push   %esi
8010497d:	e8 a6 cd ff ff       	call   80101728 <iunlockput>
      end_op();
80104982:	e8 34 e0 ff ff       	call   801029bb <end_op>
      return -1;
80104987:	83 c4 10             	add    $0x10,%esp
8010498a:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010498f:	eb 9d                	jmp    8010492e <sys_open+0xb5>
      end_op();
80104991:	e8 25 e0 ff ff       	call   801029bb <end_op>
      return -1;
80104996:	bf ff ff ff ff       	mov    $0xffffffff,%edi
8010499b:	eb 91                	jmp    8010492e <sys_open+0xb5>
    if(f)
8010499d:	85 db                	test   %ebx,%ebx
8010499f:	74 0c                	je     801049ad <sys_open+0x134>
      fileclose(f);
801049a1:	83 ec 0c             	sub    $0xc,%esp
801049a4:	53                   	push   %ebx
801049a5:	e8 29 c3 ff ff       	call   80100cd3 <fileclose>
801049aa:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801049ad:	83 ec 0c             	sub    $0xc,%esp
801049b0:	56                   	push   %esi
801049b1:	e8 72 cd ff ff       	call   80101728 <iunlockput>
    end_op();
801049b6:	e8 00 e0 ff ff       	call   801029bb <end_op>
    return -1;
801049bb:	83 c4 10             	add    $0x10,%esp
801049be:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049c3:	e9 66 ff ff ff       	jmp    8010492e <sys_open+0xb5>
    return -1;
801049c8:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049cd:	e9 5c ff ff ff       	jmp    8010492e <sys_open+0xb5>
801049d2:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049d7:	e9 52 ff ff ff       	jmp    8010492e <sys_open+0xb5>

801049dc <sys_mkdir>:

int
sys_mkdir(void)
{
801049dc:	55                   	push   %ebp
801049dd:	89 e5                	mov    %esp,%ebp
801049df:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
801049e2:	e8 5a df ff ff       	call   80102941 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
801049e7:	83 ec 08             	sub    $0x8,%esp
801049ea:	8d 45 f4             	lea    -0xc(%ebp),%eax
801049ed:	50                   	push   %eax
801049ee:	6a 00                	push   $0x0
801049f0:	e8 c3 f6 ff ff       	call   801040b8 <argstr>
801049f5:	83 c4 10             	add    $0x10,%esp
801049f8:	85 c0                	test   %eax,%eax
801049fa:	78 36                	js     80104a32 <sys_mkdir+0x56>
801049fc:	83 ec 0c             	sub    $0xc,%esp
801049ff:	6a 00                	push   $0x0
80104a01:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a06:	ba 01 00 00 00       	mov    $0x1,%edx
80104a0b:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a0e:	e8 22 f8 ff ff       	call   80104235 <create>
80104a13:	83 c4 10             	add    $0x10,%esp
80104a16:	85 c0                	test   %eax,%eax
80104a18:	74 18                	je     80104a32 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a1a:	83 ec 0c             	sub    $0xc,%esp
80104a1d:	50                   	push   %eax
80104a1e:	e8 05 cd ff ff       	call   80101728 <iunlockput>
  end_op();
80104a23:	e8 93 df ff ff       	call   801029bb <end_op>
  return 0;
80104a28:	83 c4 10             	add    $0x10,%esp
80104a2b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a30:	c9                   	leave  
80104a31:	c3                   	ret    
    end_op();
80104a32:	e8 84 df ff ff       	call   801029bb <end_op>
    return -1;
80104a37:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a3c:	eb f2                	jmp    80104a30 <sys_mkdir+0x54>

80104a3e <sys_mknod>:

int
sys_mknod(void)
{
80104a3e:	55                   	push   %ebp
80104a3f:	89 e5                	mov    %esp,%ebp
80104a41:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104a44:	e8 f8 de ff ff       	call   80102941 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104a49:	83 ec 08             	sub    $0x8,%esp
80104a4c:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a4f:	50                   	push   %eax
80104a50:	6a 00                	push   $0x0
80104a52:	e8 61 f6 ff ff       	call   801040b8 <argstr>
80104a57:	83 c4 10             	add    $0x10,%esp
80104a5a:	85 c0                	test   %eax,%eax
80104a5c:	78 62                	js     80104ac0 <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104a5e:	83 ec 08             	sub    $0x8,%esp
80104a61:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a64:	50                   	push   %eax
80104a65:	6a 01                	push   $0x1
80104a67:	e8 bc f5 ff ff       	call   80104028 <argint>
  if((argstr(0, &path)) < 0 ||
80104a6c:	83 c4 10             	add    $0x10,%esp
80104a6f:	85 c0                	test   %eax,%eax
80104a71:	78 4d                	js     80104ac0 <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104a73:	83 ec 08             	sub    $0x8,%esp
80104a76:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104a79:	50                   	push   %eax
80104a7a:	6a 02                	push   $0x2
80104a7c:	e8 a7 f5 ff ff       	call   80104028 <argint>
     argint(1, &major) < 0 ||
80104a81:	83 c4 10             	add    $0x10,%esp
80104a84:	85 c0                	test   %eax,%eax
80104a86:	78 38                	js     80104ac0 <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104a88:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104a8c:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104a90:	83 ec 0c             	sub    $0xc,%esp
80104a93:	50                   	push   %eax
80104a94:	ba 03 00 00 00       	mov    $0x3,%edx
80104a99:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a9c:	e8 94 f7 ff ff       	call   80104235 <create>
80104aa1:	83 c4 10             	add    $0x10,%esp
80104aa4:	85 c0                	test   %eax,%eax
80104aa6:	74 18                	je     80104ac0 <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104aa8:	83 ec 0c             	sub    $0xc,%esp
80104aab:	50                   	push   %eax
80104aac:	e8 77 cc ff ff       	call   80101728 <iunlockput>
  end_op();
80104ab1:	e8 05 df ff ff       	call   801029bb <end_op>
  return 0;
80104ab6:	83 c4 10             	add    $0x10,%esp
80104ab9:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104abe:	c9                   	leave  
80104abf:	c3                   	ret    
    end_op();
80104ac0:	e8 f6 de ff ff       	call   801029bb <end_op>
    return -1;
80104ac5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104aca:	eb f2                	jmp    80104abe <sys_mknod+0x80>

80104acc <sys_chdir>:

int
sys_chdir(void)
{
80104acc:	55                   	push   %ebp
80104acd:	89 e5                	mov    %esp,%ebp
80104acf:	56                   	push   %esi
80104ad0:	53                   	push   %ebx
80104ad1:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104ad4:	e8 b6 e8 ff ff       	call   8010338f <myproc>
80104ad9:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104adb:	e8 61 de ff ff       	call   80102941 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104ae0:	83 ec 08             	sub    $0x8,%esp
80104ae3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ae6:	50                   	push   %eax
80104ae7:	6a 00                	push   $0x0
80104ae9:	e8 ca f5 ff ff       	call   801040b8 <argstr>
80104aee:	83 c4 10             	add    $0x10,%esp
80104af1:	85 c0                	test   %eax,%eax
80104af3:	78 52                	js     80104b47 <sys_chdir+0x7b>
80104af5:	83 ec 0c             	sub    $0xc,%esp
80104af8:	ff 75 f4             	pushl  -0xc(%ebp)
80104afb:	e8 e1 d0 ff ff       	call   80101be1 <namei>
80104b00:	89 c3                	mov    %eax,%ebx
80104b02:	83 c4 10             	add    $0x10,%esp
80104b05:	85 c0                	test   %eax,%eax
80104b07:	74 3e                	je     80104b47 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104b09:	83 ec 0c             	sub    $0xc,%esp
80104b0c:	50                   	push   %eax
80104b0d:	e8 6f ca ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80104b12:	83 c4 10             	add    $0x10,%esp
80104b15:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104b1a:	75 37                	jne    80104b53 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b1c:	83 ec 0c             	sub    $0xc,%esp
80104b1f:	53                   	push   %ebx
80104b20:	e8 1e cb ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80104b25:	83 c4 04             	add    $0x4,%esp
80104b28:	ff 76 68             	pushl  0x68(%esi)
80104b2b:	e8 58 cb ff ff       	call   80101688 <iput>
  end_op();
80104b30:	e8 86 de ff ff       	call   801029bb <end_op>
  curproc->cwd = ip;
80104b35:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104b38:	83 c4 10             	add    $0x10,%esp
80104b3b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b40:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b43:	5b                   	pop    %ebx
80104b44:	5e                   	pop    %esi
80104b45:	5d                   	pop    %ebp
80104b46:	c3                   	ret    
    end_op();
80104b47:	e8 6f de ff ff       	call   801029bb <end_op>
    return -1;
80104b4c:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b51:	eb ed                	jmp    80104b40 <sys_chdir+0x74>
    iunlockput(ip);
80104b53:	83 ec 0c             	sub    $0xc,%esp
80104b56:	53                   	push   %ebx
80104b57:	e8 cc cb ff ff       	call   80101728 <iunlockput>
    end_op();
80104b5c:	e8 5a de ff ff       	call   801029bb <end_op>
    return -1;
80104b61:	83 c4 10             	add    $0x10,%esp
80104b64:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b69:	eb d5                	jmp    80104b40 <sys_chdir+0x74>

80104b6b <sys_exec>:

int
sys_exec(void)
{
80104b6b:	55                   	push   %ebp
80104b6c:	89 e5                	mov    %esp,%ebp
80104b6e:	53                   	push   %ebx
80104b6f:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104b75:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b78:	50                   	push   %eax
80104b79:	6a 00                	push   $0x0
80104b7b:	e8 38 f5 ff ff       	call   801040b8 <argstr>
80104b80:	83 c4 10             	add    $0x10,%esp
80104b83:	85 c0                	test   %eax,%eax
80104b85:	0f 88 a8 00 00 00    	js     80104c33 <sys_exec+0xc8>
80104b8b:	83 ec 08             	sub    $0x8,%esp
80104b8e:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104b94:	50                   	push   %eax
80104b95:	6a 01                	push   $0x1
80104b97:	e8 8c f4 ff ff       	call   80104028 <argint>
80104b9c:	83 c4 10             	add    $0x10,%esp
80104b9f:	85 c0                	test   %eax,%eax
80104ba1:	0f 88 93 00 00 00    	js     80104c3a <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104ba7:	83 ec 04             	sub    $0x4,%esp
80104baa:	68 80 00 00 00       	push   $0x80
80104baf:	6a 00                	push   $0x0
80104bb1:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104bb7:	50                   	push   %eax
80104bb8:	e8 20 f2 ff ff       	call   80103ddd <memset>
80104bbd:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104bc0:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104bc5:	83 fb 1f             	cmp    $0x1f,%ebx
80104bc8:	77 77                	ja     80104c41 <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104bca:	83 ec 08             	sub    $0x8,%esp
80104bcd:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104bd3:	50                   	push   %eax
80104bd4:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104bda:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104bdd:	50                   	push   %eax
80104bde:	e8 c9 f3 ff ff       	call   80103fac <fetchint>
80104be3:	83 c4 10             	add    $0x10,%esp
80104be6:	85 c0                	test   %eax,%eax
80104be8:	78 5e                	js     80104c48 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104bea:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104bf0:	85 c0                	test   %eax,%eax
80104bf2:	74 1d                	je     80104c11 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104bf4:	83 ec 08             	sub    $0x8,%esp
80104bf7:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104bfe:	52                   	push   %edx
80104bff:	50                   	push   %eax
80104c00:	e8 e3 f3 ff ff       	call   80103fe8 <fetchstr>
80104c05:	83 c4 10             	add    $0x10,%esp
80104c08:	85 c0                	test   %eax,%eax
80104c0a:	78 46                	js     80104c52 <sys_exec+0xe7>
  for(i=0;; i++){
80104c0c:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104c0f:	eb b4                	jmp    80104bc5 <sys_exec+0x5a>
      argv[i] = 0;
80104c11:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104c18:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104c1c:	83 ec 08             	sub    $0x8,%esp
80104c1f:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c25:	50                   	push   %eax
80104c26:	ff 75 f4             	pushl  -0xc(%ebp)
80104c29:	e8 a4 bc ff ff       	call   801008d2 <exec>
80104c2e:	83 c4 10             	add    $0x10,%esp
80104c31:	eb 1a                	jmp    80104c4d <sys_exec+0xe2>
    return -1;
80104c33:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c38:	eb 13                	jmp    80104c4d <sys_exec+0xe2>
80104c3a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c3f:	eb 0c                	jmp    80104c4d <sys_exec+0xe2>
      return -1;
80104c41:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c46:	eb 05                	jmp    80104c4d <sys_exec+0xe2>
      return -1;
80104c48:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c4d:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c50:	c9                   	leave  
80104c51:	c3                   	ret    
      return -1;
80104c52:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c57:	eb f4                	jmp    80104c4d <sys_exec+0xe2>

80104c59 <sys_pipe>:

int
sys_pipe(void)
{
80104c59:	55                   	push   %ebp
80104c5a:	89 e5                	mov    %esp,%ebp
80104c5c:	53                   	push   %ebx
80104c5d:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104c60:	6a 08                	push   $0x8
80104c62:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c65:	50                   	push   %eax
80104c66:	6a 00                	push   $0x0
80104c68:	e8 e3 f3 ff ff       	call   80104050 <argptr>
80104c6d:	83 c4 10             	add    $0x10,%esp
80104c70:	85 c0                	test   %eax,%eax
80104c72:	78 77                	js     80104ceb <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104c74:	83 ec 08             	sub    $0x8,%esp
80104c77:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104c7a:	50                   	push   %eax
80104c7b:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104c7e:	50                   	push   %eax
80104c7f:	e8 44 e2 ff ff       	call   80102ec8 <pipealloc>
80104c84:	83 c4 10             	add    $0x10,%esp
80104c87:	85 c0                	test   %eax,%eax
80104c89:	78 67                	js     80104cf2 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104c8b:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104c8e:	e8 14 f5 ff ff       	call   801041a7 <fdalloc>
80104c93:	89 c3                	mov    %eax,%ebx
80104c95:	85 c0                	test   %eax,%eax
80104c97:	78 21                	js     80104cba <sys_pipe+0x61>
80104c99:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104c9c:	e8 06 f5 ff ff       	call   801041a7 <fdalloc>
80104ca1:	85 c0                	test   %eax,%eax
80104ca3:	78 15                	js     80104cba <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104ca5:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104ca8:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104caa:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cad:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104cb0:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104cb5:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104cb8:	c9                   	leave  
80104cb9:	c3                   	ret    
    if(fd0 >= 0)
80104cba:	85 db                	test   %ebx,%ebx
80104cbc:	78 0d                	js     80104ccb <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104cbe:	e8 cc e6 ff ff       	call   8010338f <myproc>
80104cc3:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104cca:	00 
    fileclose(rf);
80104ccb:	83 ec 0c             	sub    $0xc,%esp
80104cce:	ff 75 f0             	pushl  -0x10(%ebp)
80104cd1:	e8 fd bf ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104cd6:	83 c4 04             	add    $0x4,%esp
80104cd9:	ff 75 ec             	pushl  -0x14(%ebp)
80104cdc:	e8 f2 bf ff ff       	call   80100cd3 <fileclose>
    return -1;
80104ce1:	83 c4 10             	add    $0x10,%esp
80104ce4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ce9:	eb ca                	jmp    80104cb5 <sys_pipe+0x5c>
    return -1;
80104ceb:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cf0:	eb c3                	jmp    80104cb5 <sys_pipe+0x5c>
    return -1;
80104cf2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104cf7:	eb bc                	jmp    80104cb5 <sys_pipe+0x5c>

80104cf9 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104cf9:	55                   	push   %ebp
80104cfa:	89 e5                	mov    %esp,%ebp
80104cfc:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104cff:	e8 03 e8 ff ff       	call   80103507 <fork>
}
80104d04:	c9                   	leave  
80104d05:	c3                   	ret    

80104d06 <sys_exit>:

int
sys_exit(void)
{
80104d06:	55                   	push   %ebp
80104d07:	89 e5                	mov    %esp,%ebp
80104d09:	83 ec 08             	sub    $0x8,%esp
  exit();
80104d0c:	e8 2d ea ff ff       	call   8010373e <exit>
  return 0;  // not reached
}
80104d11:	b8 00 00 00 00       	mov    $0x0,%eax
80104d16:	c9                   	leave  
80104d17:	c3                   	ret    

80104d18 <sys_wait>:

int
sys_wait(void)
{
80104d18:	55                   	push   %ebp
80104d19:	89 e5                	mov    %esp,%ebp
80104d1b:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104d1e:	e8 a4 eb ff ff       	call   801038c7 <wait>
}
80104d23:	c9                   	leave  
80104d24:	c3                   	ret    

80104d25 <sys_kill>:

int
sys_kill(void)
{
80104d25:	55                   	push   %ebp
80104d26:	89 e5                	mov    %esp,%ebp
80104d28:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104d2b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d2e:	50                   	push   %eax
80104d2f:	6a 00                	push   $0x0
80104d31:	e8 f2 f2 ff ff       	call   80104028 <argint>
80104d36:	83 c4 10             	add    $0x10,%esp
80104d39:	85 c0                	test   %eax,%eax
80104d3b:	78 10                	js     80104d4d <sys_kill+0x28>
    return -1;
  return kill(pid);
80104d3d:	83 ec 0c             	sub    $0xc,%esp
80104d40:	ff 75 f4             	pushl  -0xc(%ebp)
80104d43:	e8 7c ec ff ff       	call   801039c4 <kill>
80104d48:	83 c4 10             	add    $0x10,%esp
}
80104d4b:	c9                   	leave  
80104d4c:	c3                   	ret    
    return -1;
80104d4d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d52:	eb f7                	jmp    80104d4b <sys_kill+0x26>

80104d54 <sys_getpid>:

int
sys_getpid(void)
{
80104d54:	55                   	push   %ebp
80104d55:	89 e5                	mov    %esp,%ebp
80104d57:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104d5a:	e8 30 e6 ff ff       	call   8010338f <myproc>
80104d5f:	8b 40 10             	mov    0x10(%eax),%eax
}
80104d62:	c9                   	leave  
80104d63:	c3                   	ret    

80104d64 <sys_sbrk>:

int
sys_sbrk(void)
{
80104d64:	55                   	push   %ebp
80104d65:	89 e5                	mov    %esp,%ebp
80104d67:	53                   	push   %ebx
80104d68:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104d6b:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d6e:	50                   	push   %eax
80104d6f:	6a 00                	push   $0x0
80104d71:	e8 b2 f2 ff ff       	call   80104028 <argint>
80104d76:	83 c4 10             	add    $0x10,%esp
80104d79:	85 c0                	test   %eax,%eax
80104d7b:	78 27                	js     80104da4 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104d7d:	e8 0d e6 ff ff       	call   8010338f <myproc>
80104d82:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104d84:	83 ec 0c             	sub    $0xc,%esp
80104d87:	ff 75 f4             	pushl  -0xc(%ebp)
80104d8a:	e8 0b e7 ff ff       	call   8010349a <growproc>
80104d8f:	83 c4 10             	add    $0x10,%esp
80104d92:	85 c0                	test   %eax,%eax
80104d94:	78 07                	js     80104d9d <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104d96:	89 d8                	mov    %ebx,%eax
80104d98:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104d9b:	c9                   	leave  
80104d9c:	c3                   	ret    
    return -1;
80104d9d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104da2:	eb f2                	jmp    80104d96 <sys_sbrk+0x32>
    return -1;
80104da4:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104da9:	eb eb                	jmp    80104d96 <sys_sbrk+0x32>

80104dab <sys_sleep>:

int
sys_sleep(void)
{
80104dab:	55                   	push   %ebp
80104dac:	89 e5                	mov    %esp,%ebp
80104dae:	53                   	push   %ebx
80104daf:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104db2:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104db5:	50                   	push   %eax
80104db6:	6a 00                	push   $0x0
80104db8:	e8 6b f2 ff ff       	call   80104028 <argint>
80104dbd:	83 c4 10             	add    $0x10,%esp
80104dc0:	85 c0                	test   %eax,%eax
80104dc2:	78 75                	js     80104e39 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104dc4:	83 ec 0c             	sub    $0xc,%esp
80104dc7:	68 60 cc 14 80       	push   $0x8014cc60
80104dcc:	e8 60 ef ff ff       	call   80103d31 <acquire>
  ticks0 = ticks;
80104dd1:	8b 1d a0 d4 14 80    	mov    0x8014d4a0,%ebx
  while(ticks - ticks0 < n){
80104dd7:	83 c4 10             	add    $0x10,%esp
80104dda:	a1 a0 d4 14 80       	mov    0x8014d4a0,%eax
80104ddf:	29 d8                	sub    %ebx,%eax
80104de1:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104de4:	73 39                	jae    80104e1f <sys_sleep+0x74>
    if(myproc()->killed){
80104de6:	e8 a4 e5 ff ff       	call   8010338f <myproc>
80104deb:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104def:	75 17                	jne    80104e08 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104df1:	83 ec 08             	sub    $0x8,%esp
80104df4:	68 60 cc 14 80       	push   $0x8014cc60
80104df9:	68 a0 d4 14 80       	push   $0x8014d4a0
80104dfe:	e8 33 ea ff ff       	call   80103836 <sleep>
80104e03:	83 c4 10             	add    $0x10,%esp
80104e06:	eb d2                	jmp    80104dda <sys_sleep+0x2f>
      release(&tickslock);
80104e08:	83 ec 0c             	sub    $0xc,%esp
80104e0b:	68 60 cc 14 80       	push   $0x8014cc60
80104e10:	e8 81 ef ff ff       	call   80103d96 <release>
      return -1;
80104e15:	83 c4 10             	add    $0x10,%esp
80104e18:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e1d:	eb 15                	jmp    80104e34 <sys_sleep+0x89>
  }
  release(&tickslock);
80104e1f:	83 ec 0c             	sub    $0xc,%esp
80104e22:	68 60 cc 14 80       	push   $0x8014cc60
80104e27:	e8 6a ef ff ff       	call   80103d96 <release>
  return 0;
80104e2c:	83 c4 10             	add    $0x10,%esp
80104e2f:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e34:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e37:	c9                   	leave  
80104e38:	c3                   	ret    
    return -1;
80104e39:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e3e:	eb f4                	jmp    80104e34 <sys_sleep+0x89>

80104e40 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104e40:	55                   	push   %ebp
80104e41:	89 e5                	mov    %esp,%ebp
80104e43:	53                   	push   %ebx
80104e44:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104e47:	68 60 cc 14 80       	push   $0x8014cc60
80104e4c:	e8 e0 ee ff ff       	call   80103d31 <acquire>
  xticks = ticks;
80104e51:	8b 1d a0 d4 14 80    	mov    0x8014d4a0,%ebx
  release(&tickslock);
80104e57:	c7 04 24 60 cc 14 80 	movl   $0x8014cc60,(%esp)
80104e5e:	e8 33 ef ff ff       	call   80103d96 <release>
  return xticks;
}
80104e63:	89 d8                	mov    %ebx,%eax
80104e65:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e68:	c9                   	leave  
80104e69:	c3                   	ret    

80104e6a <sys_dump_physmem>:

// used for p5
// find which process owns each frame of phys mem
int
sys_dump_physmem(void)
{
80104e6a:	55                   	push   %ebp
80104e6b:	89 e5                	mov    %esp,%ebp
80104e6d:	83 ec 1c             	sub    $0x1c,%esp
  int *frames;
  int *pids;
  int numframes;
  //cprintf("sys_dump_physmem in sysproc.c\n");
  if(argptr(0, (char**)&frames, sizeof(int*)) < 0)
80104e70:	6a 04                	push   $0x4
80104e72:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104e75:	50                   	push   %eax
80104e76:	6a 00                	push   $0x0
80104e78:	e8 d3 f1 ff ff       	call   80104050 <argptr>
80104e7d:	83 c4 10             	add    $0x10,%esp
80104e80:	85 c0                	test   %eax,%eax
80104e82:	78 42                	js     80104ec6 <sys_dump_physmem+0x5c>
    return -1;
  if(argptr(1, (char**)&pids, sizeof(int*)) < 0)
80104e84:	83 ec 04             	sub    $0x4,%esp
80104e87:	6a 04                	push   $0x4
80104e89:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104e8c:	50                   	push   %eax
80104e8d:	6a 01                	push   $0x1
80104e8f:	e8 bc f1 ff ff       	call   80104050 <argptr>
80104e94:	83 c4 10             	add    $0x10,%esp
80104e97:	85 c0                	test   %eax,%eax
80104e99:	78 32                	js     80104ecd <sys_dump_physmem+0x63>
    return -1;
  if(argint(2, &numframes) < 0)
80104e9b:	83 ec 08             	sub    $0x8,%esp
80104e9e:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ea1:	50                   	push   %eax
80104ea2:	6a 02                	push   $0x2
80104ea4:	e8 7f f1 ff ff       	call   80104028 <argint>
80104ea9:	83 c4 10             	add    $0x10,%esp
80104eac:	85 c0                	test   %eax,%eax
80104eae:	78 24                	js     80104ed4 <sys_dump_physmem+0x6a>
    return -1;
  return dump_physmem(frames, pids, numframes);
80104eb0:	83 ec 04             	sub    $0x4,%esp
80104eb3:	ff 75 ec             	pushl  -0x14(%ebp)
80104eb6:	ff 75 f0             	pushl  -0x10(%ebp)
80104eb9:	ff 75 f4             	pushl  -0xc(%ebp)
80104ebc:	e8 6d d3 ff ff       	call   8010222e <dump_physmem>
80104ec1:	83 c4 10             	add    $0x10,%esp
80104ec4:	c9                   	leave  
80104ec5:	c3                   	ret    
    return -1;
80104ec6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ecb:	eb f7                	jmp    80104ec4 <sys_dump_physmem+0x5a>
    return -1;
80104ecd:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ed2:	eb f0                	jmp    80104ec4 <sys_dump_physmem+0x5a>
    return -1;
80104ed4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104ed9:	eb e9                	jmp    80104ec4 <sys_dump_physmem+0x5a>

80104edb <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104edb:	1e                   	push   %ds
  pushl %es
80104edc:	06                   	push   %es
  pushl %fs
80104edd:	0f a0                	push   %fs
  pushl %gs
80104edf:	0f a8                	push   %gs
  pushal
80104ee1:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104ee2:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104ee6:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104ee8:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104eea:	54                   	push   %esp
  call trap
80104eeb:	e8 e3 00 00 00       	call   80104fd3 <trap>
  addl $4, %esp
80104ef0:	83 c4 04             	add    $0x4,%esp

80104ef3 <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104ef3:	61                   	popa   
  popl %gs
80104ef4:	0f a9                	pop    %gs
  popl %fs
80104ef6:	0f a1                	pop    %fs
  popl %es
80104ef8:	07                   	pop    %es
  popl %ds
80104ef9:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104efa:	83 c4 08             	add    $0x8,%esp
  iret
80104efd:	cf                   	iret   

80104efe <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104efe:	55                   	push   %ebp
80104eff:	89 e5                	mov    %esp,%ebp
80104f01:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104f04:	b8 00 00 00 00       	mov    $0x0,%eax
80104f09:	eb 4a                	jmp    80104f55 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104f0b:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104f12:	66 89 0c c5 a0 cc 14 	mov    %cx,-0x7feb3360(,%eax,8)
80104f19:	80 
80104f1a:	66 c7 04 c5 a2 cc 14 	movw   $0x8,-0x7feb335e(,%eax,8)
80104f21:	80 08 00 
80104f24:	c6 04 c5 a4 cc 14 80 	movb   $0x0,-0x7feb335c(,%eax,8)
80104f2b:	00 
80104f2c:	0f b6 14 c5 a5 cc 14 	movzbl -0x7feb335b(,%eax,8),%edx
80104f33:	80 
80104f34:	83 e2 f0             	and    $0xfffffff0,%edx
80104f37:	83 ca 0e             	or     $0xe,%edx
80104f3a:	83 e2 8f             	and    $0xffffff8f,%edx
80104f3d:	83 ca 80             	or     $0xffffff80,%edx
80104f40:	88 14 c5 a5 cc 14 80 	mov    %dl,-0x7feb335b(,%eax,8)
80104f47:	c1 e9 10             	shr    $0x10,%ecx
80104f4a:	66 89 0c c5 a6 cc 14 	mov    %cx,-0x7feb335a(,%eax,8)
80104f51:	80 
  for(i = 0; i < 256; i++)
80104f52:	83 c0 01             	add    $0x1,%eax
80104f55:	3d ff 00 00 00       	cmp    $0xff,%eax
80104f5a:	7e af                	jle    80104f0b <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104f5c:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104f62:	66 89 15 a0 ce 14 80 	mov    %dx,0x8014cea0
80104f69:	66 c7 05 a2 ce 14 80 	movw   $0x8,0x8014cea2
80104f70:	08 00 
80104f72:	c6 05 a4 ce 14 80 00 	movb   $0x0,0x8014cea4
80104f79:	0f b6 05 a5 ce 14 80 	movzbl 0x8014cea5,%eax
80104f80:	83 c8 0f             	or     $0xf,%eax
80104f83:	83 e0 ef             	and    $0xffffffef,%eax
80104f86:	83 c8 e0             	or     $0xffffffe0,%eax
80104f89:	a2 a5 ce 14 80       	mov    %al,0x8014cea5
80104f8e:	c1 ea 10             	shr    $0x10,%edx
80104f91:	66 89 15 a6 ce 14 80 	mov    %dx,0x8014cea6

  initlock(&tickslock, "time");
80104f98:	83 ec 08             	sub    $0x8,%esp
80104f9b:	68 fd 6d 10 80       	push   $0x80106dfd
80104fa0:	68 60 cc 14 80       	push   $0x8014cc60
80104fa5:	e8 4b ec ff ff       	call   80103bf5 <initlock>
}
80104faa:	83 c4 10             	add    $0x10,%esp
80104fad:	c9                   	leave  
80104fae:	c3                   	ret    

80104faf <idtinit>:

void
idtinit(void)
{
80104faf:	55                   	push   %ebp
80104fb0:	89 e5                	mov    %esp,%ebp
80104fb2:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104fb5:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104fbb:	b8 a0 cc 14 80       	mov    $0x8014cca0,%eax
80104fc0:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104fc4:	c1 e8 10             	shr    $0x10,%eax
80104fc7:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80104fcb:	8d 45 fa             	lea    -0x6(%ebp),%eax
80104fce:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
80104fd1:	c9                   	leave  
80104fd2:	c3                   	ret    

80104fd3 <trap>:

void
trap(struct trapframe *tf)
{
80104fd3:	55                   	push   %ebp
80104fd4:	89 e5                	mov    %esp,%ebp
80104fd6:	57                   	push   %edi
80104fd7:	56                   	push   %esi
80104fd8:	53                   	push   %ebx
80104fd9:	83 ec 1c             	sub    $0x1c,%esp
80104fdc:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
80104fdf:	8b 43 30             	mov    0x30(%ebx),%eax
80104fe2:	83 f8 40             	cmp    $0x40,%eax
80104fe5:	74 13                	je     80104ffa <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80104fe7:	83 e8 20             	sub    $0x20,%eax
80104fea:	83 f8 1f             	cmp    $0x1f,%eax
80104fed:	0f 87 3a 01 00 00    	ja     8010512d <trap+0x15a>
80104ff3:	ff 24 85 a4 6e 10 80 	jmp    *-0x7fef915c(,%eax,4)
    if(myproc()->killed)
80104ffa:	e8 90 e3 ff ff       	call   8010338f <myproc>
80104fff:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105003:	75 1f                	jne    80105024 <trap+0x51>
    myproc()->tf = tf;
80105005:	e8 85 e3 ff ff       	call   8010338f <myproc>
8010500a:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
8010500d:	e8 d9 f0 ff ff       	call   801040eb <syscall>
    if(myproc()->killed)
80105012:	e8 78 e3 ff ff       	call   8010338f <myproc>
80105017:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010501b:	74 7e                	je     8010509b <trap+0xc8>
      exit();
8010501d:	e8 1c e7 ff ff       	call   8010373e <exit>
80105022:	eb 77                	jmp    8010509b <trap+0xc8>
      exit();
80105024:	e8 15 e7 ff ff       	call   8010373e <exit>
80105029:	eb da                	jmp    80105005 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
8010502b:	e8 44 e3 ff ff       	call   80103374 <cpuid>
80105030:	85 c0                	test   %eax,%eax
80105032:	74 6f                	je     801050a3 <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
80105034:	e8 f3 d4 ff ff       	call   8010252c <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105039:	e8 51 e3 ff ff       	call   8010338f <myproc>
8010503e:	85 c0                	test   %eax,%eax
80105040:	74 1c                	je     8010505e <trap+0x8b>
80105042:	e8 48 e3 ff ff       	call   8010338f <myproc>
80105047:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010504b:	74 11                	je     8010505e <trap+0x8b>
8010504d:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
80105051:	83 e0 03             	and    $0x3,%eax
80105054:	66 83 f8 03          	cmp    $0x3,%ax
80105058:	0f 84 62 01 00 00    	je     801051c0 <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
8010505e:	e8 2c e3 ff ff       	call   8010338f <myproc>
80105063:	85 c0                	test   %eax,%eax
80105065:	74 0f                	je     80105076 <trap+0xa3>
80105067:	e8 23 e3 ff ff       	call   8010338f <myproc>
8010506c:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
80105070:	0f 84 54 01 00 00    	je     801051ca <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105076:	e8 14 e3 ff ff       	call   8010338f <myproc>
8010507b:	85 c0                	test   %eax,%eax
8010507d:	74 1c                	je     8010509b <trap+0xc8>
8010507f:	e8 0b e3 ff ff       	call   8010338f <myproc>
80105084:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105088:	74 11                	je     8010509b <trap+0xc8>
8010508a:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010508e:	83 e0 03             	and    $0x3,%eax
80105091:	66 83 f8 03          	cmp    $0x3,%ax
80105095:	0f 84 43 01 00 00    	je     801051de <trap+0x20b>
    exit();
}
8010509b:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010509e:	5b                   	pop    %ebx
8010509f:	5e                   	pop    %esi
801050a0:	5f                   	pop    %edi
801050a1:	5d                   	pop    %ebp
801050a2:	c3                   	ret    
      acquire(&tickslock);
801050a3:	83 ec 0c             	sub    $0xc,%esp
801050a6:	68 60 cc 14 80       	push   $0x8014cc60
801050ab:	e8 81 ec ff ff       	call   80103d31 <acquire>
      ticks++;
801050b0:	83 05 a0 d4 14 80 01 	addl   $0x1,0x8014d4a0
      wakeup(&ticks);
801050b7:	c7 04 24 a0 d4 14 80 	movl   $0x8014d4a0,(%esp)
801050be:	e8 d8 e8 ff ff       	call   8010399b <wakeup>
      release(&tickslock);
801050c3:	c7 04 24 60 cc 14 80 	movl   $0x8014cc60,(%esp)
801050ca:	e8 c7 ec ff ff       	call   80103d96 <release>
801050cf:	83 c4 10             	add    $0x10,%esp
801050d2:	e9 5d ff ff ff       	jmp    80105034 <trap+0x61>
    ideintr();
801050d7:	e8 97 cc ff ff       	call   80101d73 <ideintr>
    lapiceoi();
801050dc:	e8 4b d4 ff ff       	call   8010252c <lapiceoi>
    break;
801050e1:	e9 53 ff ff ff       	jmp    80105039 <trap+0x66>
    kbdintr();
801050e6:	e8 85 d2 ff ff       	call   80102370 <kbdintr>
    lapiceoi();
801050eb:	e8 3c d4 ff ff       	call   8010252c <lapiceoi>
    break;
801050f0:	e9 44 ff ff ff       	jmp    80105039 <trap+0x66>
    uartintr();
801050f5:	e8 05 02 00 00       	call   801052ff <uartintr>
    lapiceoi();
801050fa:	e8 2d d4 ff ff       	call   8010252c <lapiceoi>
    break;
801050ff:	e9 35 ff ff ff       	jmp    80105039 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105104:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105107:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010510b:	e8 64 e2 ff ff       	call   80103374 <cpuid>
80105110:	57                   	push   %edi
80105111:	0f b7 f6             	movzwl %si,%esi
80105114:	56                   	push   %esi
80105115:	50                   	push   %eax
80105116:	68 08 6e 10 80       	push   $0x80106e08
8010511b:	e8 eb b4 ff ff       	call   8010060b <cprintf>
    lapiceoi();
80105120:	e8 07 d4 ff ff       	call   8010252c <lapiceoi>
    break;
80105125:	83 c4 10             	add    $0x10,%esp
80105128:	e9 0c ff ff ff       	jmp    80105039 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
8010512d:	e8 5d e2 ff ff       	call   8010338f <myproc>
80105132:	85 c0                	test   %eax,%eax
80105134:	74 5f                	je     80105195 <trap+0x1c2>
80105136:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
8010513a:	74 59                	je     80105195 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
8010513c:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010513f:	8b 43 38             	mov    0x38(%ebx),%eax
80105142:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105145:	e8 2a e2 ff ff       	call   80103374 <cpuid>
8010514a:	89 45 e0             	mov    %eax,-0x20(%ebp)
8010514d:	8b 53 34             	mov    0x34(%ebx),%edx
80105150:	89 55 dc             	mov    %edx,-0x24(%ebp)
80105153:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105156:	e8 34 e2 ff ff       	call   8010338f <myproc>
8010515b:	8d 48 6c             	lea    0x6c(%eax),%ecx
8010515e:	89 4d d8             	mov    %ecx,-0x28(%ebp)
80105161:	e8 29 e2 ff ff       	call   8010338f <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
80105166:	57                   	push   %edi
80105167:	ff 75 e4             	pushl  -0x1c(%ebp)
8010516a:	ff 75 e0             	pushl  -0x20(%ebp)
8010516d:	ff 75 dc             	pushl  -0x24(%ebp)
80105170:	56                   	push   %esi
80105171:	ff 75 d8             	pushl  -0x28(%ebp)
80105174:	ff 70 10             	pushl  0x10(%eax)
80105177:	68 60 6e 10 80       	push   $0x80106e60
8010517c:	e8 8a b4 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
80105181:	83 c4 20             	add    $0x20,%esp
80105184:	e8 06 e2 ff ff       	call   8010338f <myproc>
80105189:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
80105190:	e9 a4 fe ff ff       	jmp    80105039 <trap+0x66>
80105195:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
80105198:	8b 73 38             	mov    0x38(%ebx),%esi
8010519b:	e8 d4 e1 ff ff       	call   80103374 <cpuid>
801051a0:	83 ec 0c             	sub    $0xc,%esp
801051a3:	57                   	push   %edi
801051a4:	56                   	push   %esi
801051a5:	50                   	push   %eax
801051a6:	ff 73 30             	pushl  0x30(%ebx)
801051a9:	68 2c 6e 10 80       	push   $0x80106e2c
801051ae:	e8 58 b4 ff ff       	call   8010060b <cprintf>
      panic("trap");
801051b3:	83 c4 14             	add    $0x14,%esp
801051b6:	68 02 6e 10 80       	push   $0x80106e02
801051bb:	e8 88 b1 ff ff       	call   80100348 <panic>
    exit();
801051c0:	e8 79 e5 ff ff       	call   8010373e <exit>
801051c5:	e9 94 fe ff ff       	jmp    8010505e <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
801051ca:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
801051ce:	0f 85 a2 fe ff ff    	jne    80105076 <trap+0xa3>
    yield();
801051d4:	e8 2b e6 ff ff       	call   80103804 <yield>
801051d9:	e9 98 fe ff ff       	jmp    80105076 <trap+0xa3>
    exit();
801051de:	e8 5b e5 ff ff       	call   8010373e <exit>
801051e3:	e9 b3 fe ff ff       	jmp    8010509b <trap+0xc8>

801051e8 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
801051e8:	55                   	push   %ebp
801051e9:	89 e5                	mov    %esp,%ebp
  if(!uart)
801051eb:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
801051f2:	74 15                	je     80105209 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801051f4:	ba fd 03 00 00       	mov    $0x3fd,%edx
801051f9:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
801051fa:	a8 01                	test   $0x1,%al
801051fc:	74 12                	je     80105210 <uartgetc+0x28>
801051fe:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105203:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
80105204:	0f b6 c0             	movzbl %al,%eax
}
80105207:	5d                   	pop    %ebp
80105208:	c3                   	ret    
    return -1;
80105209:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010520e:	eb f7                	jmp    80105207 <uartgetc+0x1f>
    return -1;
80105210:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105215:	eb f0                	jmp    80105207 <uartgetc+0x1f>

80105217 <uartputc>:
  if(!uart)
80105217:	83 3d bc a5 10 80 00 	cmpl   $0x0,0x8010a5bc
8010521e:	74 3b                	je     8010525b <uartputc+0x44>
{
80105220:	55                   	push   %ebp
80105221:	89 e5                	mov    %esp,%ebp
80105223:	53                   	push   %ebx
80105224:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105227:	bb 00 00 00 00       	mov    $0x0,%ebx
8010522c:	eb 10                	jmp    8010523e <uartputc+0x27>
    microdelay(10);
8010522e:	83 ec 0c             	sub    $0xc,%esp
80105231:	6a 0a                	push   $0xa
80105233:	e8 13 d3 ff ff       	call   8010254b <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105238:	83 c3 01             	add    $0x1,%ebx
8010523b:	83 c4 10             	add    $0x10,%esp
8010523e:	83 fb 7f             	cmp    $0x7f,%ebx
80105241:	7f 0a                	jg     8010524d <uartputc+0x36>
80105243:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105248:	ec                   	in     (%dx),%al
80105249:	a8 20                	test   $0x20,%al
8010524b:	74 e1                	je     8010522e <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
8010524d:	8b 45 08             	mov    0x8(%ebp),%eax
80105250:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105255:	ee                   	out    %al,(%dx)
}
80105256:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105259:	c9                   	leave  
8010525a:	c3                   	ret    
8010525b:	f3 c3                	repz ret 

8010525d <uartinit>:
{
8010525d:	55                   	push   %ebp
8010525e:	89 e5                	mov    %esp,%ebp
80105260:	56                   	push   %esi
80105261:	53                   	push   %ebx
80105262:	b9 00 00 00 00       	mov    $0x0,%ecx
80105267:	ba fa 03 00 00       	mov    $0x3fa,%edx
8010526c:	89 c8                	mov    %ecx,%eax
8010526e:	ee                   	out    %al,(%dx)
8010526f:	be fb 03 00 00       	mov    $0x3fb,%esi
80105274:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
80105279:	89 f2                	mov    %esi,%edx
8010527b:	ee                   	out    %al,(%dx)
8010527c:	b8 0c 00 00 00       	mov    $0xc,%eax
80105281:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105286:	ee                   	out    %al,(%dx)
80105287:	bb f9 03 00 00       	mov    $0x3f9,%ebx
8010528c:	89 c8                	mov    %ecx,%eax
8010528e:	89 da                	mov    %ebx,%edx
80105290:	ee                   	out    %al,(%dx)
80105291:	b8 03 00 00 00       	mov    $0x3,%eax
80105296:	89 f2                	mov    %esi,%edx
80105298:	ee                   	out    %al,(%dx)
80105299:	ba fc 03 00 00       	mov    $0x3fc,%edx
8010529e:	89 c8                	mov    %ecx,%eax
801052a0:	ee                   	out    %al,(%dx)
801052a1:	b8 01 00 00 00       	mov    $0x1,%eax
801052a6:	89 da                	mov    %ebx,%edx
801052a8:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801052a9:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052ae:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801052af:	3c ff                	cmp    $0xff,%al
801052b1:	74 45                	je     801052f8 <uartinit+0x9b>
  uart = 1;
801052b3:	c7 05 bc a5 10 80 01 	movl   $0x1,0x8010a5bc
801052ba:	00 00 00 
801052bd:	ba fa 03 00 00       	mov    $0x3fa,%edx
801052c2:	ec                   	in     (%dx),%al
801052c3:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052c8:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
801052c9:	83 ec 08             	sub    $0x8,%esp
801052cc:	6a 00                	push   $0x0
801052ce:	6a 04                	push   $0x4
801052d0:	e8 a9 cc ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
801052d5:	83 c4 10             	add    $0x10,%esp
801052d8:	bb 24 6f 10 80       	mov    $0x80106f24,%ebx
801052dd:	eb 12                	jmp    801052f1 <uartinit+0x94>
    uartputc(*p);
801052df:	83 ec 0c             	sub    $0xc,%esp
801052e2:	0f be c0             	movsbl %al,%eax
801052e5:	50                   	push   %eax
801052e6:	e8 2c ff ff ff       	call   80105217 <uartputc>
  for(p="xv6...\n"; *p; p++)
801052eb:	83 c3 01             	add    $0x1,%ebx
801052ee:	83 c4 10             	add    $0x10,%esp
801052f1:	0f b6 03             	movzbl (%ebx),%eax
801052f4:	84 c0                	test   %al,%al
801052f6:	75 e7                	jne    801052df <uartinit+0x82>
}
801052f8:	8d 65 f8             	lea    -0x8(%ebp),%esp
801052fb:	5b                   	pop    %ebx
801052fc:	5e                   	pop    %esi
801052fd:	5d                   	pop    %ebp
801052fe:	c3                   	ret    

801052ff <uartintr>:

void
uartintr(void)
{
801052ff:	55                   	push   %ebp
80105300:	89 e5                	mov    %esp,%ebp
80105302:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105305:	68 e8 51 10 80       	push   $0x801051e8
8010530a:	e8 2f b4 ff ff       	call   8010073e <consoleintr>
}
8010530f:	83 c4 10             	add    $0x10,%esp
80105312:	c9                   	leave  
80105313:	c3                   	ret    

80105314 <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
80105314:	6a 00                	push   $0x0
  pushl $0
80105316:	6a 00                	push   $0x0
  jmp alltraps
80105318:	e9 be fb ff ff       	jmp    80104edb <alltraps>

8010531d <vector1>:
.globl vector1
vector1:
  pushl $0
8010531d:	6a 00                	push   $0x0
  pushl $1
8010531f:	6a 01                	push   $0x1
  jmp alltraps
80105321:	e9 b5 fb ff ff       	jmp    80104edb <alltraps>

80105326 <vector2>:
.globl vector2
vector2:
  pushl $0
80105326:	6a 00                	push   $0x0
  pushl $2
80105328:	6a 02                	push   $0x2
  jmp alltraps
8010532a:	e9 ac fb ff ff       	jmp    80104edb <alltraps>

8010532f <vector3>:
.globl vector3
vector3:
  pushl $0
8010532f:	6a 00                	push   $0x0
  pushl $3
80105331:	6a 03                	push   $0x3
  jmp alltraps
80105333:	e9 a3 fb ff ff       	jmp    80104edb <alltraps>

80105338 <vector4>:
.globl vector4
vector4:
  pushl $0
80105338:	6a 00                	push   $0x0
  pushl $4
8010533a:	6a 04                	push   $0x4
  jmp alltraps
8010533c:	e9 9a fb ff ff       	jmp    80104edb <alltraps>

80105341 <vector5>:
.globl vector5
vector5:
  pushl $0
80105341:	6a 00                	push   $0x0
  pushl $5
80105343:	6a 05                	push   $0x5
  jmp alltraps
80105345:	e9 91 fb ff ff       	jmp    80104edb <alltraps>

8010534a <vector6>:
.globl vector6
vector6:
  pushl $0
8010534a:	6a 00                	push   $0x0
  pushl $6
8010534c:	6a 06                	push   $0x6
  jmp alltraps
8010534e:	e9 88 fb ff ff       	jmp    80104edb <alltraps>

80105353 <vector7>:
.globl vector7
vector7:
  pushl $0
80105353:	6a 00                	push   $0x0
  pushl $7
80105355:	6a 07                	push   $0x7
  jmp alltraps
80105357:	e9 7f fb ff ff       	jmp    80104edb <alltraps>

8010535c <vector8>:
.globl vector8
vector8:
  pushl $8
8010535c:	6a 08                	push   $0x8
  jmp alltraps
8010535e:	e9 78 fb ff ff       	jmp    80104edb <alltraps>

80105363 <vector9>:
.globl vector9
vector9:
  pushl $0
80105363:	6a 00                	push   $0x0
  pushl $9
80105365:	6a 09                	push   $0x9
  jmp alltraps
80105367:	e9 6f fb ff ff       	jmp    80104edb <alltraps>

8010536c <vector10>:
.globl vector10
vector10:
  pushl $10
8010536c:	6a 0a                	push   $0xa
  jmp alltraps
8010536e:	e9 68 fb ff ff       	jmp    80104edb <alltraps>

80105373 <vector11>:
.globl vector11
vector11:
  pushl $11
80105373:	6a 0b                	push   $0xb
  jmp alltraps
80105375:	e9 61 fb ff ff       	jmp    80104edb <alltraps>

8010537a <vector12>:
.globl vector12
vector12:
  pushl $12
8010537a:	6a 0c                	push   $0xc
  jmp alltraps
8010537c:	e9 5a fb ff ff       	jmp    80104edb <alltraps>

80105381 <vector13>:
.globl vector13
vector13:
  pushl $13
80105381:	6a 0d                	push   $0xd
  jmp alltraps
80105383:	e9 53 fb ff ff       	jmp    80104edb <alltraps>

80105388 <vector14>:
.globl vector14
vector14:
  pushl $14
80105388:	6a 0e                	push   $0xe
  jmp alltraps
8010538a:	e9 4c fb ff ff       	jmp    80104edb <alltraps>

8010538f <vector15>:
.globl vector15
vector15:
  pushl $0
8010538f:	6a 00                	push   $0x0
  pushl $15
80105391:	6a 0f                	push   $0xf
  jmp alltraps
80105393:	e9 43 fb ff ff       	jmp    80104edb <alltraps>

80105398 <vector16>:
.globl vector16
vector16:
  pushl $0
80105398:	6a 00                	push   $0x0
  pushl $16
8010539a:	6a 10                	push   $0x10
  jmp alltraps
8010539c:	e9 3a fb ff ff       	jmp    80104edb <alltraps>

801053a1 <vector17>:
.globl vector17
vector17:
  pushl $17
801053a1:	6a 11                	push   $0x11
  jmp alltraps
801053a3:	e9 33 fb ff ff       	jmp    80104edb <alltraps>

801053a8 <vector18>:
.globl vector18
vector18:
  pushl $0
801053a8:	6a 00                	push   $0x0
  pushl $18
801053aa:	6a 12                	push   $0x12
  jmp alltraps
801053ac:	e9 2a fb ff ff       	jmp    80104edb <alltraps>

801053b1 <vector19>:
.globl vector19
vector19:
  pushl $0
801053b1:	6a 00                	push   $0x0
  pushl $19
801053b3:	6a 13                	push   $0x13
  jmp alltraps
801053b5:	e9 21 fb ff ff       	jmp    80104edb <alltraps>

801053ba <vector20>:
.globl vector20
vector20:
  pushl $0
801053ba:	6a 00                	push   $0x0
  pushl $20
801053bc:	6a 14                	push   $0x14
  jmp alltraps
801053be:	e9 18 fb ff ff       	jmp    80104edb <alltraps>

801053c3 <vector21>:
.globl vector21
vector21:
  pushl $0
801053c3:	6a 00                	push   $0x0
  pushl $21
801053c5:	6a 15                	push   $0x15
  jmp alltraps
801053c7:	e9 0f fb ff ff       	jmp    80104edb <alltraps>

801053cc <vector22>:
.globl vector22
vector22:
  pushl $0
801053cc:	6a 00                	push   $0x0
  pushl $22
801053ce:	6a 16                	push   $0x16
  jmp alltraps
801053d0:	e9 06 fb ff ff       	jmp    80104edb <alltraps>

801053d5 <vector23>:
.globl vector23
vector23:
  pushl $0
801053d5:	6a 00                	push   $0x0
  pushl $23
801053d7:	6a 17                	push   $0x17
  jmp alltraps
801053d9:	e9 fd fa ff ff       	jmp    80104edb <alltraps>

801053de <vector24>:
.globl vector24
vector24:
  pushl $0
801053de:	6a 00                	push   $0x0
  pushl $24
801053e0:	6a 18                	push   $0x18
  jmp alltraps
801053e2:	e9 f4 fa ff ff       	jmp    80104edb <alltraps>

801053e7 <vector25>:
.globl vector25
vector25:
  pushl $0
801053e7:	6a 00                	push   $0x0
  pushl $25
801053e9:	6a 19                	push   $0x19
  jmp alltraps
801053eb:	e9 eb fa ff ff       	jmp    80104edb <alltraps>

801053f0 <vector26>:
.globl vector26
vector26:
  pushl $0
801053f0:	6a 00                	push   $0x0
  pushl $26
801053f2:	6a 1a                	push   $0x1a
  jmp alltraps
801053f4:	e9 e2 fa ff ff       	jmp    80104edb <alltraps>

801053f9 <vector27>:
.globl vector27
vector27:
  pushl $0
801053f9:	6a 00                	push   $0x0
  pushl $27
801053fb:	6a 1b                	push   $0x1b
  jmp alltraps
801053fd:	e9 d9 fa ff ff       	jmp    80104edb <alltraps>

80105402 <vector28>:
.globl vector28
vector28:
  pushl $0
80105402:	6a 00                	push   $0x0
  pushl $28
80105404:	6a 1c                	push   $0x1c
  jmp alltraps
80105406:	e9 d0 fa ff ff       	jmp    80104edb <alltraps>

8010540b <vector29>:
.globl vector29
vector29:
  pushl $0
8010540b:	6a 00                	push   $0x0
  pushl $29
8010540d:	6a 1d                	push   $0x1d
  jmp alltraps
8010540f:	e9 c7 fa ff ff       	jmp    80104edb <alltraps>

80105414 <vector30>:
.globl vector30
vector30:
  pushl $0
80105414:	6a 00                	push   $0x0
  pushl $30
80105416:	6a 1e                	push   $0x1e
  jmp alltraps
80105418:	e9 be fa ff ff       	jmp    80104edb <alltraps>

8010541d <vector31>:
.globl vector31
vector31:
  pushl $0
8010541d:	6a 00                	push   $0x0
  pushl $31
8010541f:	6a 1f                	push   $0x1f
  jmp alltraps
80105421:	e9 b5 fa ff ff       	jmp    80104edb <alltraps>

80105426 <vector32>:
.globl vector32
vector32:
  pushl $0
80105426:	6a 00                	push   $0x0
  pushl $32
80105428:	6a 20                	push   $0x20
  jmp alltraps
8010542a:	e9 ac fa ff ff       	jmp    80104edb <alltraps>

8010542f <vector33>:
.globl vector33
vector33:
  pushl $0
8010542f:	6a 00                	push   $0x0
  pushl $33
80105431:	6a 21                	push   $0x21
  jmp alltraps
80105433:	e9 a3 fa ff ff       	jmp    80104edb <alltraps>

80105438 <vector34>:
.globl vector34
vector34:
  pushl $0
80105438:	6a 00                	push   $0x0
  pushl $34
8010543a:	6a 22                	push   $0x22
  jmp alltraps
8010543c:	e9 9a fa ff ff       	jmp    80104edb <alltraps>

80105441 <vector35>:
.globl vector35
vector35:
  pushl $0
80105441:	6a 00                	push   $0x0
  pushl $35
80105443:	6a 23                	push   $0x23
  jmp alltraps
80105445:	e9 91 fa ff ff       	jmp    80104edb <alltraps>

8010544a <vector36>:
.globl vector36
vector36:
  pushl $0
8010544a:	6a 00                	push   $0x0
  pushl $36
8010544c:	6a 24                	push   $0x24
  jmp alltraps
8010544e:	e9 88 fa ff ff       	jmp    80104edb <alltraps>

80105453 <vector37>:
.globl vector37
vector37:
  pushl $0
80105453:	6a 00                	push   $0x0
  pushl $37
80105455:	6a 25                	push   $0x25
  jmp alltraps
80105457:	e9 7f fa ff ff       	jmp    80104edb <alltraps>

8010545c <vector38>:
.globl vector38
vector38:
  pushl $0
8010545c:	6a 00                	push   $0x0
  pushl $38
8010545e:	6a 26                	push   $0x26
  jmp alltraps
80105460:	e9 76 fa ff ff       	jmp    80104edb <alltraps>

80105465 <vector39>:
.globl vector39
vector39:
  pushl $0
80105465:	6a 00                	push   $0x0
  pushl $39
80105467:	6a 27                	push   $0x27
  jmp alltraps
80105469:	e9 6d fa ff ff       	jmp    80104edb <alltraps>

8010546e <vector40>:
.globl vector40
vector40:
  pushl $0
8010546e:	6a 00                	push   $0x0
  pushl $40
80105470:	6a 28                	push   $0x28
  jmp alltraps
80105472:	e9 64 fa ff ff       	jmp    80104edb <alltraps>

80105477 <vector41>:
.globl vector41
vector41:
  pushl $0
80105477:	6a 00                	push   $0x0
  pushl $41
80105479:	6a 29                	push   $0x29
  jmp alltraps
8010547b:	e9 5b fa ff ff       	jmp    80104edb <alltraps>

80105480 <vector42>:
.globl vector42
vector42:
  pushl $0
80105480:	6a 00                	push   $0x0
  pushl $42
80105482:	6a 2a                	push   $0x2a
  jmp alltraps
80105484:	e9 52 fa ff ff       	jmp    80104edb <alltraps>

80105489 <vector43>:
.globl vector43
vector43:
  pushl $0
80105489:	6a 00                	push   $0x0
  pushl $43
8010548b:	6a 2b                	push   $0x2b
  jmp alltraps
8010548d:	e9 49 fa ff ff       	jmp    80104edb <alltraps>

80105492 <vector44>:
.globl vector44
vector44:
  pushl $0
80105492:	6a 00                	push   $0x0
  pushl $44
80105494:	6a 2c                	push   $0x2c
  jmp alltraps
80105496:	e9 40 fa ff ff       	jmp    80104edb <alltraps>

8010549b <vector45>:
.globl vector45
vector45:
  pushl $0
8010549b:	6a 00                	push   $0x0
  pushl $45
8010549d:	6a 2d                	push   $0x2d
  jmp alltraps
8010549f:	e9 37 fa ff ff       	jmp    80104edb <alltraps>

801054a4 <vector46>:
.globl vector46
vector46:
  pushl $0
801054a4:	6a 00                	push   $0x0
  pushl $46
801054a6:	6a 2e                	push   $0x2e
  jmp alltraps
801054a8:	e9 2e fa ff ff       	jmp    80104edb <alltraps>

801054ad <vector47>:
.globl vector47
vector47:
  pushl $0
801054ad:	6a 00                	push   $0x0
  pushl $47
801054af:	6a 2f                	push   $0x2f
  jmp alltraps
801054b1:	e9 25 fa ff ff       	jmp    80104edb <alltraps>

801054b6 <vector48>:
.globl vector48
vector48:
  pushl $0
801054b6:	6a 00                	push   $0x0
  pushl $48
801054b8:	6a 30                	push   $0x30
  jmp alltraps
801054ba:	e9 1c fa ff ff       	jmp    80104edb <alltraps>

801054bf <vector49>:
.globl vector49
vector49:
  pushl $0
801054bf:	6a 00                	push   $0x0
  pushl $49
801054c1:	6a 31                	push   $0x31
  jmp alltraps
801054c3:	e9 13 fa ff ff       	jmp    80104edb <alltraps>

801054c8 <vector50>:
.globl vector50
vector50:
  pushl $0
801054c8:	6a 00                	push   $0x0
  pushl $50
801054ca:	6a 32                	push   $0x32
  jmp alltraps
801054cc:	e9 0a fa ff ff       	jmp    80104edb <alltraps>

801054d1 <vector51>:
.globl vector51
vector51:
  pushl $0
801054d1:	6a 00                	push   $0x0
  pushl $51
801054d3:	6a 33                	push   $0x33
  jmp alltraps
801054d5:	e9 01 fa ff ff       	jmp    80104edb <alltraps>

801054da <vector52>:
.globl vector52
vector52:
  pushl $0
801054da:	6a 00                	push   $0x0
  pushl $52
801054dc:	6a 34                	push   $0x34
  jmp alltraps
801054de:	e9 f8 f9 ff ff       	jmp    80104edb <alltraps>

801054e3 <vector53>:
.globl vector53
vector53:
  pushl $0
801054e3:	6a 00                	push   $0x0
  pushl $53
801054e5:	6a 35                	push   $0x35
  jmp alltraps
801054e7:	e9 ef f9 ff ff       	jmp    80104edb <alltraps>

801054ec <vector54>:
.globl vector54
vector54:
  pushl $0
801054ec:	6a 00                	push   $0x0
  pushl $54
801054ee:	6a 36                	push   $0x36
  jmp alltraps
801054f0:	e9 e6 f9 ff ff       	jmp    80104edb <alltraps>

801054f5 <vector55>:
.globl vector55
vector55:
  pushl $0
801054f5:	6a 00                	push   $0x0
  pushl $55
801054f7:	6a 37                	push   $0x37
  jmp alltraps
801054f9:	e9 dd f9 ff ff       	jmp    80104edb <alltraps>

801054fe <vector56>:
.globl vector56
vector56:
  pushl $0
801054fe:	6a 00                	push   $0x0
  pushl $56
80105500:	6a 38                	push   $0x38
  jmp alltraps
80105502:	e9 d4 f9 ff ff       	jmp    80104edb <alltraps>

80105507 <vector57>:
.globl vector57
vector57:
  pushl $0
80105507:	6a 00                	push   $0x0
  pushl $57
80105509:	6a 39                	push   $0x39
  jmp alltraps
8010550b:	e9 cb f9 ff ff       	jmp    80104edb <alltraps>

80105510 <vector58>:
.globl vector58
vector58:
  pushl $0
80105510:	6a 00                	push   $0x0
  pushl $58
80105512:	6a 3a                	push   $0x3a
  jmp alltraps
80105514:	e9 c2 f9 ff ff       	jmp    80104edb <alltraps>

80105519 <vector59>:
.globl vector59
vector59:
  pushl $0
80105519:	6a 00                	push   $0x0
  pushl $59
8010551b:	6a 3b                	push   $0x3b
  jmp alltraps
8010551d:	e9 b9 f9 ff ff       	jmp    80104edb <alltraps>

80105522 <vector60>:
.globl vector60
vector60:
  pushl $0
80105522:	6a 00                	push   $0x0
  pushl $60
80105524:	6a 3c                	push   $0x3c
  jmp alltraps
80105526:	e9 b0 f9 ff ff       	jmp    80104edb <alltraps>

8010552b <vector61>:
.globl vector61
vector61:
  pushl $0
8010552b:	6a 00                	push   $0x0
  pushl $61
8010552d:	6a 3d                	push   $0x3d
  jmp alltraps
8010552f:	e9 a7 f9 ff ff       	jmp    80104edb <alltraps>

80105534 <vector62>:
.globl vector62
vector62:
  pushl $0
80105534:	6a 00                	push   $0x0
  pushl $62
80105536:	6a 3e                	push   $0x3e
  jmp alltraps
80105538:	e9 9e f9 ff ff       	jmp    80104edb <alltraps>

8010553d <vector63>:
.globl vector63
vector63:
  pushl $0
8010553d:	6a 00                	push   $0x0
  pushl $63
8010553f:	6a 3f                	push   $0x3f
  jmp alltraps
80105541:	e9 95 f9 ff ff       	jmp    80104edb <alltraps>

80105546 <vector64>:
.globl vector64
vector64:
  pushl $0
80105546:	6a 00                	push   $0x0
  pushl $64
80105548:	6a 40                	push   $0x40
  jmp alltraps
8010554a:	e9 8c f9 ff ff       	jmp    80104edb <alltraps>

8010554f <vector65>:
.globl vector65
vector65:
  pushl $0
8010554f:	6a 00                	push   $0x0
  pushl $65
80105551:	6a 41                	push   $0x41
  jmp alltraps
80105553:	e9 83 f9 ff ff       	jmp    80104edb <alltraps>

80105558 <vector66>:
.globl vector66
vector66:
  pushl $0
80105558:	6a 00                	push   $0x0
  pushl $66
8010555a:	6a 42                	push   $0x42
  jmp alltraps
8010555c:	e9 7a f9 ff ff       	jmp    80104edb <alltraps>

80105561 <vector67>:
.globl vector67
vector67:
  pushl $0
80105561:	6a 00                	push   $0x0
  pushl $67
80105563:	6a 43                	push   $0x43
  jmp alltraps
80105565:	e9 71 f9 ff ff       	jmp    80104edb <alltraps>

8010556a <vector68>:
.globl vector68
vector68:
  pushl $0
8010556a:	6a 00                	push   $0x0
  pushl $68
8010556c:	6a 44                	push   $0x44
  jmp alltraps
8010556e:	e9 68 f9 ff ff       	jmp    80104edb <alltraps>

80105573 <vector69>:
.globl vector69
vector69:
  pushl $0
80105573:	6a 00                	push   $0x0
  pushl $69
80105575:	6a 45                	push   $0x45
  jmp alltraps
80105577:	e9 5f f9 ff ff       	jmp    80104edb <alltraps>

8010557c <vector70>:
.globl vector70
vector70:
  pushl $0
8010557c:	6a 00                	push   $0x0
  pushl $70
8010557e:	6a 46                	push   $0x46
  jmp alltraps
80105580:	e9 56 f9 ff ff       	jmp    80104edb <alltraps>

80105585 <vector71>:
.globl vector71
vector71:
  pushl $0
80105585:	6a 00                	push   $0x0
  pushl $71
80105587:	6a 47                	push   $0x47
  jmp alltraps
80105589:	e9 4d f9 ff ff       	jmp    80104edb <alltraps>

8010558e <vector72>:
.globl vector72
vector72:
  pushl $0
8010558e:	6a 00                	push   $0x0
  pushl $72
80105590:	6a 48                	push   $0x48
  jmp alltraps
80105592:	e9 44 f9 ff ff       	jmp    80104edb <alltraps>

80105597 <vector73>:
.globl vector73
vector73:
  pushl $0
80105597:	6a 00                	push   $0x0
  pushl $73
80105599:	6a 49                	push   $0x49
  jmp alltraps
8010559b:	e9 3b f9 ff ff       	jmp    80104edb <alltraps>

801055a0 <vector74>:
.globl vector74
vector74:
  pushl $0
801055a0:	6a 00                	push   $0x0
  pushl $74
801055a2:	6a 4a                	push   $0x4a
  jmp alltraps
801055a4:	e9 32 f9 ff ff       	jmp    80104edb <alltraps>

801055a9 <vector75>:
.globl vector75
vector75:
  pushl $0
801055a9:	6a 00                	push   $0x0
  pushl $75
801055ab:	6a 4b                	push   $0x4b
  jmp alltraps
801055ad:	e9 29 f9 ff ff       	jmp    80104edb <alltraps>

801055b2 <vector76>:
.globl vector76
vector76:
  pushl $0
801055b2:	6a 00                	push   $0x0
  pushl $76
801055b4:	6a 4c                	push   $0x4c
  jmp alltraps
801055b6:	e9 20 f9 ff ff       	jmp    80104edb <alltraps>

801055bb <vector77>:
.globl vector77
vector77:
  pushl $0
801055bb:	6a 00                	push   $0x0
  pushl $77
801055bd:	6a 4d                	push   $0x4d
  jmp alltraps
801055bf:	e9 17 f9 ff ff       	jmp    80104edb <alltraps>

801055c4 <vector78>:
.globl vector78
vector78:
  pushl $0
801055c4:	6a 00                	push   $0x0
  pushl $78
801055c6:	6a 4e                	push   $0x4e
  jmp alltraps
801055c8:	e9 0e f9 ff ff       	jmp    80104edb <alltraps>

801055cd <vector79>:
.globl vector79
vector79:
  pushl $0
801055cd:	6a 00                	push   $0x0
  pushl $79
801055cf:	6a 4f                	push   $0x4f
  jmp alltraps
801055d1:	e9 05 f9 ff ff       	jmp    80104edb <alltraps>

801055d6 <vector80>:
.globl vector80
vector80:
  pushl $0
801055d6:	6a 00                	push   $0x0
  pushl $80
801055d8:	6a 50                	push   $0x50
  jmp alltraps
801055da:	e9 fc f8 ff ff       	jmp    80104edb <alltraps>

801055df <vector81>:
.globl vector81
vector81:
  pushl $0
801055df:	6a 00                	push   $0x0
  pushl $81
801055e1:	6a 51                	push   $0x51
  jmp alltraps
801055e3:	e9 f3 f8 ff ff       	jmp    80104edb <alltraps>

801055e8 <vector82>:
.globl vector82
vector82:
  pushl $0
801055e8:	6a 00                	push   $0x0
  pushl $82
801055ea:	6a 52                	push   $0x52
  jmp alltraps
801055ec:	e9 ea f8 ff ff       	jmp    80104edb <alltraps>

801055f1 <vector83>:
.globl vector83
vector83:
  pushl $0
801055f1:	6a 00                	push   $0x0
  pushl $83
801055f3:	6a 53                	push   $0x53
  jmp alltraps
801055f5:	e9 e1 f8 ff ff       	jmp    80104edb <alltraps>

801055fa <vector84>:
.globl vector84
vector84:
  pushl $0
801055fa:	6a 00                	push   $0x0
  pushl $84
801055fc:	6a 54                	push   $0x54
  jmp alltraps
801055fe:	e9 d8 f8 ff ff       	jmp    80104edb <alltraps>

80105603 <vector85>:
.globl vector85
vector85:
  pushl $0
80105603:	6a 00                	push   $0x0
  pushl $85
80105605:	6a 55                	push   $0x55
  jmp alltraps
80105607:	e9 cf f8 ff ff       	jmp    80104edb <alltraps>

8010560c <vector86>:
.globl vector86
vector86:
  pushl $0
8010560c:	6a 00                	push   $0x0
  pushl $86
8010560e:	6a 56                	push   $0x56
  jmp alltraps
80105610:	e9 c6 f8 ff ff       	jmp    80104edb <alltraps>

80105615 <vector87>:
.globl vector87
vector87:
  pushl $0
80105615:	6a 00                	push   $0x0
  pushl $87
80105617:	6a 57                	push   $0x57
  jmp alltraps
80105619:	e9 bd f8 ff ff       	jmp    80104edb <alltraps>

8010561e <vector88>:
.globl vector88
vector88:
  pushl $0
8010561e:	6a 00                	push   $0x0
  pushl $88
80105620:	6a 58                	push   $0x58
  jmp alltraps
80105622:	e9 b4 f8 ff ff       	jmp    80104edb <alltraps>

80105627 <vector89>:
.globl vector89
vector89:
  pushl $0
80105627:	6a 00                	push   $0x0
  pushl $89
80105629:	6a 59                	push   $0x59
  jmp alltraps
8010562b:	e9 ab f8 ff ff       	jmp    80104edb <alltraps>

80105630 <vector90>:
.globl vector90
vector90:
  pushl $0
80105630:	6a 00                	push   $0x0
  pushl $90
80105632:	6a 5a                	push   $0x5a
  jmp alltraps
80105634:	e9 a2 f8 ff ff       	jmp    80104edb <alltraps>

80105639 <vector91>:
.globl vector91
vector91:
  pushl $0
80105639:	6a 00                	push   $0x0
  pushl $91
8010563b:	6a 5b                	push   $0x5b
  jmp alltraps
8010563d:	e9 99 f8 ff ff       	jmp    80104edb <alltraps>

80105642 <vector92>:
.globl vector92
vector92:
  pushl $0
80105642:	6a 00                	push   $0x0
  pushl $92
80105644:	6a 5c                	push   $0x5c
  jmp alltraps
80105646:	e9 90 f8 ff ff       	jmp    80104edb <alltraps>

8010564b <vector93>:
.globl vector93
vector93:
  pushl $0
8010564b:	6a 00                	push   $0x0
  pushl $93
8010564d:	6a 5d                	push   $0x5d
  jmp alltraps
8010564f:	e9 87 f8 ff ff       	jmp    80104edb <alltraps>

80105654 <vector94>:
.globl vector94
vector94:
  pushl $0
80105654:	6a 00                	push   $0x0
  pushl $94
80105656:	6a 5e                	push   $0x5e
  jmp alltraps
80105658:	e9 7e f8 ff ff       	jmp    80104edb <alltraps>

8010565d <vector95>:
.globl vector95
vector95:
  pushl $0
8010565d:	6a 00                	push   $0x0
  pushl $95
8010565f:	6a 5f                	push   $0x5f
  jmp alltraps
80105661:	e9 75 f8 ff ff       	jmp    80104edb <alltraps>

80105666 <vector96>:
.globl vector96
vector96:
  pushl $0
80105666:	6a 00                	push   $0x0
  pushl $96
80105668:	6a 60                	push   $0x60
  jmp alltraps
8010566a:	e9 6c f8 ff ff       	jmp    80104edb <alltraps>

8010566f <vector97>:
.globl vector97
vector97:
  pushl $0
8010566f:	6a 00                	push   $0x0
  pushl $97
80105671:	6a 61                	push   $0x61
  jmp alltraps
80105673:	e9 63 f8 ff ff       	jmp    80104edb <alltraps>

80105678 <vector98>:
.globl vector98
vector98:
  pushl $0
80105678:	6a 00                	push   $0x0
  pushl $98
8010567a:	6a 62                	push   $0x62
  jmp alltraps
8010567c:	e9 5a f8 ff ff       	jmp    80104edb <alltraps>

80105681 <vector99>:
.globl vector99
vector99:
  pushl $0
80105681:	6a 00                	push   $0x0
  pushl $99
80105683:	6a 63                	push   $0x63
  jmp alltraps
80105685:	e9 51 f8 ff ff       	jmp    80104edb <alltraps>

8010568a <vector100>:
.globl vector100
vector100:
  pushl $0
8010568a:	6a 00                	push   $0x0
  pushl $100
8010568c:	6a 64                	push   $0x64
  jmp alltraps
8010568e:	e9 48 f8 ff ff       	jmp    80104edb <alltraps>

80105693 <vector101>:
.globl vector101
vector101:
  pushl $0
80105693:	6a 00                	push   $0x0
  pushl $101
80105695:	6a 65                	push   $0x65
  jmp alltraps
80105697:	e9 3f f8 ff ff       	jmp    80104edb <alltraps>

8010569c <vector102>:
.globl vector102
vector102:
  pushl $0
8010569c:	6a 00                	push   $0x0
  pushl $102
8010569e:	6a 66                	push   $0x66
  jmp alltraps
801056a0:	e9 36 f8 ff ff       	jmp    80104edb <alltraps>

801056a5 <vector103>:
.globl vector103
vector103:
  pushl $0
801056a5:	6a 00                	push   $0x0
  pushl $103
801056a7:	6a 67                	push   $0x67
  jmp alltraps
801056a9:	e9 2d f8 ff ff       	jmp    80104edb <alltraps>

801056ae <vector104>:
.globl vector104
vector104:
  pushl $0
801056ae:	6a 00                	push   $0x0
  pushl $104
801056b0:	6a 68                	push   $0x68
  jmp alltraps
801056b2:	e9 24 f8 ff ff       	jmp    80104edb <alltraps>

801056b7 <vector105>:
.globl vector105
vector105:
  pushl $0
801056b7:	6a 00                	push   $0x0
  pushl $105
801056b9:	6a 69                	push   $0x69
  jmp alltraps
801056bb:	e9 1b f8 ff ff       	jmp    80104edb <alltraps>

801056c0 <vector106>:
.globl vector106
vector106:
  pushl $0
801056c0:	6a 00                	push   $0x0
  pushl $106
801056c2:	6a 6a                	push   $0x6a
  jmp alltraps
801056c4:	e9 12 f8 ff ff       	jmp    80104edb <alltraps>

801056c9 <vector107>:
.globl vector107
vector107:
  pushl $0
801056c9:	6a 00                	push   $0x0
  pushl $107
801056cb:	6a 6b                	push   $0x6b
  jmp alltraps
801056cd:	e9 09 f8 ff ff       	jmp    80104edb <alltraps>

801056d2 <vector108>:
.globl vector108
vector108:
  pushl $0
801056d2:	6a 00                	push   $0x0
  pushl $108
801056d4:	6a 6c                	push   $0x6c
  jmp alltraps
801056d6:	e9 00 f8 ff ff       	jmp    80104edb <alltraps>

801056db <vector109>:
.globl vector109
vector109:
  pushl $0
801056db:	6a 00                	push   $0x0
  pushl $109
801056dd:	6a 6d                	push   $0x6d
  jmp alltraps
801056df:	e9 f7 f7 ff ff       	jmp    80104edb <alltraps>

801056e4 <vector110>:
.globl vector110
vector110:
  pushl $0
801056e4:	6a 00                	push   $0x0
  pushl $110
801056e6:	6a 6e                	push   $0x6e
  jmp alltraps
801056e8:	e9 ee f7 ff ff       	jmp    80104edb <alltraps>

801056ed <vector111>:
.globl vector111
vector111:
  pushl $0
801056ed:	6a 00                	push   $0x0
  pushl $111
801056ef:	6a 6f                	push   $0x6f
  jmp alltraps
801056f1:	e9 e5 f7 ff ff       	jmp    80104edb <alltraps>

801056f6 <vector112>:
.globl vector112
vector112:
  pushl $0
801056f6:	6a 00                	push   $0x0
  pushl $112
801056f8:	6a 70                	push   $0x70
  jmp alltraps
801056fa:	e9 dc f7 ff ff       	jmp    80104edb <alltraps>

801056ff <vector113>:
.globl vector113
vector113:
  pushl $0
801056ff:	6a 00                	push   $0x0
  pushl $113
80105701:	6a 71                	push   $0x71
  jmp alltraps
80105703:	e9 d3 f7 ff ff       	jmp    80104edb <alltraps>

80105708 <vector114>:
.globl vector114
vector114:
  pushl $0
80105708:	6a 00                	push   $0x0
  pushl $114
8010570a:	6a 72                	push   $0x72
  jmp alltraps
8010570c:	e9 ca f7 ff ff       	jmp    80104edb <alltraps>

80105711 <vector115>:
.globl vector115
vector115:
  pushl $0
80105711:	6a 00                	push   $0x0
  pushl $115
80105713:	6a 73                	push   $0x73
  jmp alltraps
80105715:	e9 c1 f7 ff ff       	jmp    80104edb <alltraps>

8010571a <vector116>:
.globl vector116
vector116:
  pushl $0
8010571a:	6a 00                	push   $0x0
  pushl $116
8010571c:	6a 74                	push   $0x74
  jmp alltraps
8010571e:	e9 b8 f7 ff ff       	jmp    80104edb <alltraps>

80105723 <vector117>:
.globl vector117
vector117:
  pushl $0
80105723:	6a 00                	push   $0x0
  pushl $117
80105725:	6a 75                	push   $0x75
  jmp alltraps
80105727:	e9 af f7 ff ff       	jmp    80104edb <alltraps>

8010572c <vector118>:
.globl vector118
vector118:
  pushl $0
8010572c:	6a 00                	push   $0x0
  pushl $118
8010572e:	6a 76                	push   $0x76
  jmp alltraps
80105730:	e9 a6 f7 ff ff       	jmp    80104edb <alltraps>

80105735 <vector119>:
.globl vector119
vector119:
  pushl $0
80105735:	6a 00                	push   $0x0
  pushl $119
80105737:	6a 77                	push   $0x77
  jmp alltraps
80105739:	e9 9d f7 ff ff       	jmp    80104edb <alltraps>

8010573e <vector120>:
.globl vector120
vector120:
  pushl $0
8010573e:	6a 00                	push   $0x0
  pushl $120
80105740:	6a 78                	push   $0x78
  jmp alltraps
80105742:	e9 94 f7 ff ff       	jmp    80104edb <alltraps>

80105747 <vector121>:
.globl vector121
vector121:
  pushl $0
80105747:	6a 00                	push   $0x0
  pushl $121
80105749:	6a 79                	push   $0x79
  jmp alltraps
8010574b:	e9 8b f7 ff ff       	jmp    80104edb <alltraps>

80105750 <vector122>:
.globl vector122
vector122:
  pushl $0
80105750:	6a 00                	push   $0x0
  pushl $122
80105752:	6a 7a                	push   $0x7a
  jmp alltraps
80105754:	e9 82 f7 ff ff       	jmp    80104edb <alltraps>

80105759 <vector123>:
.globl vector123
vector123:
  pushl $0
80105759:	6a 00                	push   $0x0
  pushl $123
8010575b:	6a 7b                	push   $0x7b
  jmp alltraps
8010575d:	e9 79 f7 ff ff       	jmp    80104edb <alltraps>

80105762 <vector124>:
.globl vector124
vector124:
  pushl $0
80105762:	6a 00                	push   $0x0
  pushl $124
80105764:	6a 7c                	push   $0x7c
  jmp alltraps
80105766:	e9 70 f7 ff ff       	jmp    80104edb <alltraps>

8010576b <vector125>:
.globl vector125
vector125:
  pushl $0
8010576b:	6a 00                	push   $0x0
  pushl $125
8010576d:	6a 7d                	push   $0x7d
  jmp alltraps
8010576f:	e9 67 f7 ff ff       	jmp    80104edb <alltraps>

80105774 <vector126>:
.globl vector126
vector126:
  pushl $0
80105774:	6a 00                	push   $0x0
  pushl $126
80105776:	6a 7e                	push   $0x7e
  jmp alltraps
80105778:	e9 5e f7 ff ff       	jmp    80104edb <alltraps>

8010577d <vector127>:
.globl vector127
vector127:
  pushl $0
8010577d:	6a 00                	push   $0x0
  pushl $127
8010577f:	6a 7f                	push   $0x7f
  jmp alltraps
80105781:	e9 55 f7 ff ff       	jmp    80104edb <alltraps>

80105786 <vector128>:
.globl vector128
vector128:
  pushl $0
80105786:	6a 00                	push   $0x0
  pushl $128
80105788:	68 80 00 00 00       	push   $0x80
  jmp alltraps
8010578d:	e9 49 f7 ff ff       	jmp    80104edb <alltraps>

80105792 <vector129>:
.globl vector129
vector129:
  pushl $0
80105792:	6a 00                	push   $0x0
  pushl $129
80105794:	68 81 00 00 00       	push   $0x81
  jmp alltraps
80105799:	e9 3d f7 ff ff       	jmp    80104edb <alltraps>

8010579e <vector130>:
.globl vector130
vector130:
  pushl $0
8010579e:	6a 00                	push   $0x0
  pushl $130
801057a0:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801057a5:	e9 31 f7 ff ff       	jmp    80104edb <alltraps>

801057aa <vector131>:
.globl vector131
vector131:
  pushl $0
801057aa:	6a 00                	push   $0x0
  pushl $131
801057ac:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801057b1:	e9 25 f7 ff ff       	jmp    80104edb <alltraps>

801057b6 <vector132>:
.globl vector132
vector132:
  pushl $0
801057b6:	6a 00                	push   $0x0
  pushl $132
801057b8:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801057bd:	e9 19 f7 ff ff       	jmp    80104edb <alltraps>

801057c2 <vector133>:
.globl vector133
vector133:
  pushl $0
801057c2:	6a 00                	push   $0x0
  pushl $133
801057c4:	68 85 00 00 00       	push   $0x85
  jmp alltraps
801057c9:	e9 0d f7 ff ff       	jmp    80104edb <alltraps>

801057ce <vector134>:
.globl vector134
vector134:
  pushl $0
801057ce:	6a 00                	push   $0x0
  pushl $134
801057d0:	68 86 00 00 00       	push   $0x86
  jmp alltraps
801057d5:	e9 01 f7 ff ff       	jmp    80104edb <alltraps>

801057da <vector135>:
.globl vector135
vector135:
  pushl $0
801057da:	6a 00                	push   $0x0
  pushl $135
801057dc:	68 87 00 00 00       	push   $0x87
  jmp alltraps
801057e1:	e9 f5 f6 ff ff       	jmp    80104edb <alltraps>

801057e6 <vector136>:
.globl vector136
vector136:
  pushl $0
801057e6:	6a 00                	push   $0x0
  pushl $136
801057e8:	68 88 00 00 00       	push   $0x88
  jmp alltraps
801057ed:	e9 e9 f6 ff ff       	jmp    80104edb <alltraps>

801057f2 <vector137>:
.globl vector137
vector137:
  pushl $0
801057f2:	6a 00                	push   $0x0
  pushl $137
801057f4:	68 89 00 00 00       	push   $0x89
  jmp alltraps
801057f9:	e9 dd f6 ff ff       	jmp    80104edb <alltraps>

801057fe <vector138>:
.globl vector138
vector138:
  pushl $0
801057fe:	6a 00                	push   $0x0
  pushl $138
80105800:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105805:	e9 d1 f6 ff ff       	jmp    80104edb <alltraps>

8010580a <vector139>:
.globl vector139
vector139:
  pushl $0
8010580a:	6a 00                	push   $0x0
  pushl $139
8010580c:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
80105811:	e9 c5 f6 ff ff       	jmp    80104edb <alltraps>

80105816 <vector140>:
.globl vector140
vector140:
  pushl $0
80105816:	6a 00                	push   $0x0
  pushl $140
80105818:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
8010581d:	e9 b9 f6 ff ff       	jmp    80104edb <alltraps>

80105822 <vector141>:
.globl vector141
vector141:
  pushl $0
80105822:	6a 00                	push   $0x0
  pushl $141
80105824:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105829:	e9 ad f6 ff ff       	jmp    80104edb <alltraps>

8010582e <vector142>:
.globl vector142
vector142:
  pushl $0
8010582e:	6a 00                	push   $0x0
  pushl $142
80105830:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105835:	e9 a1 f6 ff ff       	jmp    80104edb <alltraps>

8010583a <vector143>:
.globl vector143
vector143:
  pushl $0
8010583a:	6a 00                	push   $0x0
  pushl $143
8010583c:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
80105841:	e9 95 f6 ff ff       	jmp    80104edb <alltraps>

80105846 <vector144>:
.globl vector144
vector144:
  pushl $0
80105846:	6a 00                	push   $0x0
  pushl $144
80105848:	68 90 00 00 00       	push   $0x90
  jmp alltraps
8010584d:	e9 89 f6 ff ff       	jmp    80104edb <alltraps>

80105852 <vector145>:
.globl vector145
vector145:
  pushl $0
80105852:	6a 00                	push   $0x0
  pushl $145
80105854:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105859:	e9 7d f6 ff ff       	jmp    80104edb <alltraps>

8010585e <vector146>:
.globl vector146
vector146:
  pushl $0
8010585e:	6a 00                	push   $0x0
  pushl $146
80105860:	68 92 00 00 00       	push   $0x92
  jmp alltraps
80105865:	e9 71 f6 ff ff       	jmp    80104edb <alltraps>

8010586a <vector147>:
.globl vector147
vector147:
  pushl $0
8010586a:	6a 00                	push   $0x0
  pushl $147
8010586c:	68 93 00 00 00       	push   $0x93
  jmp alltraps
80105871:	e9 65 f6 ff ff       	jmp    80104edb <alltraps>

80105876 <vector148>:
.globl vector148
vector148:
  pushl $0
80105876:	6a 00                	push   $0x0
  pushl $148
80105878:	68 94 00 00 00       	push   $0x94
  jmp alltraps
8010587d:	e9 59 f6 ff ff       	jmp    80104edb <alltraps>

80105882 <vector149>:
.globl vector149
vector149:
  pushl $0
80105882:	6a 00                	push   $0x0
  pushl $149
80105884:	68 95 00 00 00       	push   $0x95
  jmp alltraps
80105889:	e9 4d f6 ff ff       	jmp    80104edb <alltraps>

8010588e <vector150>:
.globl vector150
vector150:
  pushl $0
8010588e:	6a 00                	push   $0x0
  pushl $150
80105890:	68 96 00 00 00       	push   $0x96
  jmp alltraps
80105895:	e9 41 f6 ff ff       	jmp    80104edb <alltraps>

8010589a <vector151>:
.globl vector151
vector151:
  pushl $0
8010589a:	6a 00                	push   $0x0
  pushl $151
8010589c:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801058a1:	e9 35 f6 ff ff       	jmp    80104edb <alltraps>

801058a6 <vector152>:
.globl vector152
vector152:
  pushl $0
801058a6:	6a 00                	push   $0x0
  pushl $152
801058a8:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801058ad:	e9 29 f6 ff ff       	jmp    80104edb <alltraps>

801058b2 <vector153>:
.globl vector153
vector153:
  pushl $0
801058b2:	6a 00                	push   $0x0
  pushl $153
801058b4:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801058b9:	e9 1d f6 ff ff       	jmp    80104edb <alltraps>

801058be <vector154>:
.globl vector154
vector154:
  pushl $0
801058be:	6a 00                	push   $0x0
  pushl $154
801058c0:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
801058c5:	e9 11 f6 ff ff       	jmp    80104edb <alltraps>

801058ca <vector155>:
.globl vector155
vector155:
  pushl $0
801058ca:	6a 00                	push   $0x0
  pushl $155
801058cc:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
801058d1:	e9 05 f6 ff ff       	jmp    80104edb <alltraps>

801058d6 <vector156>:
.globl vector156
vector156:
  pushl $0
801058d6:	6a 00                	push   $0x0
  pushl $156
801058d8:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
801058dd:	e9 f9 f5 ff ff       	jmp    80104edb <alltraps>

801058e2 <vector157>:
.globl vector157
vector157:
  pushl $0
801058e2:	6a 00                	push   $0x0
  pushl $157
801058e4:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
801058e9:	e9 ed f5 ff ff       	jmp    80104edb <alltraps>

801058ee <vector158>:
.globl vector158
vector158:
  pushl $0
801058ee:	6a 00                	push   $0x0
  pushl $158
801058f0:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
801058f5:	e9 e1 f5 ff ff       	jmp    80104edb <alltraps>

801058fa <vector159>:
.globl vector159
vector159:
  pushl $0
801058fa:	6a 00                	push   $0x0
  pushl $159
801058fc:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
80105901:	e9 d5 f5 ff ff       	jmp    80104edb <alltraps>

80105906 <vector160>:
.globl vector160
vector160:
  pushl $0
80105906:	6a 00                	push   $0x0
  pushl $160
80105908:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
8010590d:	e9 c9 f5 ff ff       	jmp    80104edb <alltraps>

80105912 <vector161>:
.globl vector161
vector161:
  pushl $0
80105912:	6a 00                	push   $0x0
  pushl $161
80105914:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105919:	e9 bd f5 ff ff       	jmp    80104edb <alltraps>

8010591e <vector162>:
.globl vector162
vector162:
  pushl $0
8010591e:	6a 00                	push   $0x0
  pushl $162
80105920:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105925:	e9 b1 f5 ff ff       	jmp    80104edb <alltraps>

8010592a <vector163>:
.globl vector163
vector163:
  pushl $0
8010592a:	6a 00                	push   $0x0
  pushl $163
8010592c:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
80105931:	e9 a5 f5 ff ff       	jmp    80104edb <alltraps>

80105936 <vector164>:
.globl vector164
vector164:
  pushl $0
80105936:	6a 00                	push   $0x0
  pushl $164
80105938:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
8010593d:	e9 99 f5 ff ff       	jmp    80104edb <alltraps>

80105942 <vector165>:
.globl vector165
vector165:
  pushl $0
80105942:	6a 00                	push   $0x0
  pushl $165
80105944:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105949:	e9 8d f5 ff ff       	jmp    80104edb <alltraps>

8010594e <vector166>:
.globl vector166
vector166:
  pushl $0
8010594e:	6a 00                	push   $0x0
  pushl $166
80105950:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105955:	e9 81 f5 ff ff       	jmp    80104edb <alltraps>

8010595a <vector167>:
.globl vector167
vector167:
  pushl $0
8010595a:	6a 00                	push   $0x0
  pushl $167
8010595c:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
80105961:	e9 75 f5 ff ff       	jmp    80104edb <alltraps>

80105966 <vector168>:
.globl vector168
vector168:
  pushl $0
80105966:	6a 00                	push   $0x0
  pushl $168
80105968:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
8010596d:	e9 69 f5 ff ff       	jmp    80104edb <alltraps>

80105972 <vector169>:
.globl vector169
vector169:
  pushl $0
80105972:	6a 00                	push   $0x0
  pushl $169
80105974:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
80105979:	e9 5d f5 ff ff       	jmp    80104edb <alltraps>

8010597e <vector170>:
.globl vector170
vector170:
  pushl $0
8010597e:	6a 00                	push   $0x0
  pushl $170
80105980:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
80105985:	e9 51 f5 ff ff       	jmp    80104edb <alltraps>

8010598a <vector171>:
.globl vector171
vector171:
  pushl $0
8010598a:	6a 00                	push   $0x0
  pushl $171
8010598c:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
80105991:	e9 45 f5 ff ff       	jmp    80104edb <alltraps>

80105996 <vector172>:
.globl vector172
vector172:
  pushl $0
80105996:	6a 00                	push   $0x0
  pushl $172
80105998:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
8010599d:	e9 39 f5 ff ff       	jmp    80104edb <alltraps>

801059a2 <vector173>:
.globl vector173
vector173:
  pushl $0
801059a2:	6a 00                	push   $0x0
  pushl $173
801059a4:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801059a9:	e9 2d f5 ff ff       	jmp    80104edb <alltraps>

801059ae <vector174>:
.globl vector174
vector174:
  pushl $0
801059ae:	6a 00                	push   $0x0
  pushl $174
801059b0:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801059b5:	e9 21 f5 ff ff       	jmp    80104edb <alltraps>

801059ba <vector175>:
.globl vector175
vector175:
  pushl $0
801059ba:	6a 00                	push   $0x0
  pushl $175
801059bc:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801059c1:	e9 15 f5 ff ff       	jmp    80104edb <alltraps>

801059c6 <vector176>:
.globl vector176
vector176:
  pushl $0
801059c6:	6a 00                	push   $0x0
  pushl $176
801059c8:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
801059cd:	e9 09 f5 ff ff       	jmp    80104edb <alltraps>

801059d2 <vector177>:
.globl vector177
vector177:
  pushl $0
801059d2:	6a 00                	push   $0x0
  pushl $177
801059d4:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
801059d9:	e9 fd f4 ff ff       	jmp    80104edb <alltraps>

801059de <vector178>:
.globl vector178
vector178:
  pushl $0
801059de:	6a 00                	push   $0x0
  pushl $178
801059e0:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
801059e5:	e9 f1 f4 ff ff       	jmp    80104edb <alltraps>

801059ea <vector179>:
.globl vector179
vector179:
  pushl $0
801059ea:	6a 00                	push   $0x0
  pushl $179
801059ec:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
801059f1:	e9 e5 f4 ff ff       	jmp    80104edb <alltraps>

801059f6 <vector180>:
.globl vector180
vector180:
  pushl $0
801059f6:	6a 00                	push   $0x0
  pushl $180
801059f8:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
801059fd:	e9 d9 f4 ff ff       	jmp    80104edb <alltraps>

80105a02 <vector181>:
.globl vector181
vector181:
  pushl $0
80105a02:	6a 00                	push   $0x0
  pushl $181
80105a04:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105a09:	e9 cd f4 ff ff       	jmp    80104edb <alltraps>

80105a0e <vector182>:
.globl vector182
vector182:
  pushl $0
80105a0e:	6a 00                	push   $0x0
  pushl $182
80105a10:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105a15:	e9 c1 f4 ff ff       	jmp    80104edb <alltraps>

80105a1a <vector183>:
.globl vector183
vector183:
  pushl $0
80105a1a:	6a 00                	push   $0x0
  pushl $183
80105a1c:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105a21:	e9 b5 f4 ff ff       	jmp    80104edb <alltraps>

80105a26 <vector184>:
.globl vector184
vector184:
  pushl $0
80105a26:	6a 00                	push   $0x0
  pushl $184
80105a28:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105a2d:	e9 a9 f4 ff ff       	jmp    80104edb <alltraps>

80105a32 <vector185>:
.globl vector185
vector185:
  pushl $0
80105a32:	6a 00                	push   $0x0
  pushl $185
80105a34:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105a39:	e9 9d f4 ff ff       	jmp    80104edb <alltraps>

80105a3e <vector186>:
.globl vector186
vector186:
  pushl $0
80105a3e:	6a 00                	push   $0x0
  pushl $186
80105a40:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105a45:	e9 91 f4 ff ff       	jmp    80104edb <alltraps>

80105a4a <vector187>:
.globl vector187
vector187:
  pushl $0
80105a4a:	6a 00                	push   $0x0
  pushl $187
80105a4c:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a51:	e9 85 f4 ff ff       	jmp    80104edb <alltraps>

80105a56 <vector188>:
.globl vector188
vector188:
  pushl $0
80105a56:	6a 00                	push   $0x0
  pushl $188
80105a58:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a5d:	e9 79 f4 ff ff       	jmp    80104edb <alltraps>

80105a62 <vector189>:
.globl vector189
vector189:
  pushl $0
80105a62:	6a 00                	push   $0x0
  pushl $189
80105a64:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105a69:	e9 6d f4 ff ff       	jmp    80104edb <alltraps>

80105a6e <vector190>:
.globl vector190
vector190:
  pushl $0
80105a6e:	6a 00                	push   $0x0
  pushl $190
80105a70:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105a75:	e9 61 f4 ff ff       	jmp    80104edb <alltraps>

80105a7a <vector191>:
.globl vector191
vector191:
  pushl $0
80105a7a:	6a 00                	push   $0x0
  pushl $191
80105a7c:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105a81:	e9 55 f4 ff ff       	jmp    80104edb <alltraps>

80105a86 <vector192>:
.globl vector192
vector192:
  pushl $0
80105a86:	6a 00                	push   $0x0
  pushl $192
80105a88:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105a8d:	e9 49 f4 ff ff       	jmp    80104edb <alltraps>

80105a92 <vector193>:
.globl vector193
vector193:
  pushl $0
80105a92:	6a 00                	push   $0x0
  pushl $193
80105a94:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105a99:	e9 3d f4 ff ff       	jmp    80104edb <alltraps>

80105a9e <vector194>:
.globl vector194
vector194:
  pushl $0
80105a9e:	6a 00                	push   $0x0
  pushl $194
80105aa0:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105aa5:	e9 31 f4 ff ff       	jmp    80104edb <alltraps>

80105aaa <vector195>:
.globl vector195
vector195:
  pushl $0
80105aaa:	6a 00                	push   $0x0
  pushl $195
80105aac:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105ab1:	e9 25 f4 ff ff       	jmp    80104edb <alltraps>

80105ab6 <vector196>:
.globl vector196
vector196:
  pushl $0
80105ab6:	6a 00                	push   $0x0
  pushl $196
80105ab8:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105abd:	e9 19 f4 ff ff       	jmp    80104edb <alltraps>

80105ac2 <vector197>:
.globl vector197
vector197:
  pushl $0
80105ac2:	6a 00                	push   $0x0
  pushl $197
80105ac4:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105ac9:	e9 0d f4 ff ff       	jmp    80104edb <alltraps>

80105ace <vector198>:
.globl vector198
vector198:
  pushl $0
80105ace:	6a 00                	push   $0x0
  pushl $198
80105ad0:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105ad5:	e9 01 f4 ff ff       	jmp    80104edb <alltraps>

80105ada <vector199>:
.globl vector199
vector199:
  pushl $0
80105ada:	6a 00                	push   $0x0
  pushl $199
80105adc:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105ae1:	e9 f5 f3 ff ff       	jmp    80104edb <alltraps>

80105ae6 <vector200>:
.globl vector200
vector200:
  pushl $0
80105ae6:	6a 00                	push   $0x0
  pushl $200
80105ae8:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105aed:	e9 e9 f3 ff ff       	jmp    80104edb <alltraps>

80105af2 <vector201>:
.globl vector201
vector201:
  pushl $0
80105af2:	6a 00                	push   $0x0
  pushl $201
80105af4:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105af9:	e9 dd f3 ff ff       	jmp    80104edb <alltraps>

80105afe <vector202>:
.globl vector202
vector202:
  pushl $0
80105afe:	6a 00                	push   $0x0
  pushl $202
80105b00:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105b05:	e9 d1 f3 ff ff       	jmp    80104edb <alltraps>

80105b0a <vector203>:
.globl vector203
vector203:
  pushl $0
80105b0a:	6a 00                	push   $0x0
  pushl $203
80105b0c:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105b11:	e9 c5 f3 ff ff       	jmp    80104edb <alltraps>

80105b16 <vector204>:
.globl vector204
vector204:
  pushl $0
80105b16:	6a 00                	push   $0x0
  pushl $204
80105b18:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105b1d:	e9 b9 f3 ff ff       	jmp    80104edb <alltraps>

80105b22 <vector205>:
.globl vector205
vector205:
  pushl $0
80105b22:	6a 00                	push   $0x0
  pushl $205
80105b24:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105b29:	e9 ad f3 ff ff       	jmp    80104edb <alltraps>

80105b2e <vector206>:
.globl vector206
vector206:
  pushl $0
80105b2e:	6a 00                	push   $0x0
  pushl $206
80105b30:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105b35:	e9 a1 f3 ff ff       	jmp    80104edb <alltraps>

80105b3a <vector207>:
.globl vector207
vector207:
  pushl $0
80105b3a:	6a 00                	push   $0x0
  pushl $207
80105b3c:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105b41:	e9 95 f3 ff ff       	jmp    80104edb <alltraps>

80105b46 <vector208>:
.globl vector208
vector208:
  pushl $0
80105b46:	6a 00                	push   $0x0
  pushl $208
80105b48:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b4d:	e9 89 f3 ff ff       	jmp    80104edb <alltraps>

80105b52 <vector209>:
.globl vector209
vector209:
  pushl $0
80105b52:	6a 00                	push   $0x0
  pushl $209
80105b54:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b59:	e9 7d f3 ff ff       	jmp    80104edb <alltraps>

80105b5e <vector210>:
.globl vector210
vector210:
  pushl $0
80105b5e:	6a 00                	push   $0x0
  pushl $210
80105b60:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105b65:	e9 71 f3 ff ff       	jmp    80104edb <alltraps>

80105b6a <vector211>:
.globl vector211
vector211:
  pushl $0
80105b6a:	6a 00                	push   $0x0
  pushl $211
80105b6c:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105b71:	e9 65 f3 ff ff       	jmp    80104edb <alltraps>

80105b76 <vector212>:
.globl vector212
vector212:
  pushl $0
80105b76:	6a 00                	push   $0x0
  pushl $212
80105b78:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105b7d:	e9 59 f3 ff ff       	jmp    80104edb <alltraps>

80105b82 <vector213>:
.globl vector213
vector213:
  pushl $0
80105b82:	6a 00                	push   $0x0
  pushl $213
80105b84:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105b89:	e9 4d f3 ff ff       	jmp    80104edb <alltraps>

80105b8e <vector214>:
.globl vector214
vector214:
  pushl $0
80105b8e:	6a 00                	push   $0x0
  pushl $214
80105b90:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105b95:	e9 41 f3 ff ff       	jmp    80104edb <alltraps>

80105b9a <vector215>:
.globl vector215
vector215:
  pushl $0
80105b9a:	6a 00                	push   $0x0
  pushl $215
80105b9c:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105ba1:	e9 35 f3 ff ff       	jmp    80104edb <alltraps>

80105ba6 <vector216>:
.globl vector216
vector216:
  pushl $0
80105ba6:	6a 00                	push   $0x0
  pushl $216
80105ba8:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105bad:	e9 29 f3 ff ff       	jmp    80104edb <alltraps>

80105bb2 <vector217>:
.globl vector217
vector217:
  pushl $0
80105bb2:	6a 00                	push   $0x0
  pushl $217
80105bb4:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105bb9:	e9 1d f3 ff ff       	jmp    80104edb <alltraps>

80105bbe <vector218>:
.globl vector218
vector218:
  pushl $0
80105bbe:	6a 00                	push   $0x0
  pushl $218
80105bc0:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105bc5:	e9 11 f3 ff ff       	jmp    80104edb <alltraps>

80105bca <vector219>:
.globl vector219
vector219:
  pushl $0
80105bca:	6a 00                	push   $0x0
  pushl $219
80105bcc:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105bd1:	e9 05 f3 ff ff       	jmp    80104edb <alltraps>

80105bd6 <vector220>:
.globl vector220
vector220:
  pushl $0
80105bd6:	6a 00                	push   $0x0
  pushl $220
80105bd8:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105bdd:	e9 f9 f2 ff ff       	jmp    80104edb <alltraps>

80105be2 <vector221>:
.globl vector221
vector221:
  pushl $0
80105be2:	6a 00                	push   $0x0
  pushl $221
80105be4:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105be9:	e9 ed f2 ff ff       	jmp    80104edb <alltraps>

80105bee <vector222>:
.globl vector222
vector222:
  pushl $0
80105bee:	6a 00                	push   $0x0
  pushl $222
80105bf0:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105bf5:	e9 e1 f2 ff ff       	jmp    80104edb <alltraps>

80105bfa <vector223>:
.globl vector223
vector223:
  pushl $0
80105bfa:	6a 00                	push   $0x0
  pushl $223
80105bfc:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105c01:	e9 d5 f2 ff ff       	jmp    80104edb <alltraps>

80105c06 <vector224>:
.globl vector224
vector224:
  pushl $0
80105c06:	6a 00                	push   $0x0
  pushl $224
80105c08:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105c0d:	e9 c9 f2 ff ff       	jmp    80104edb <alltraps>

80105c12 <vector225>:
.globl vector225
vector225:
  pushl $0
80105c12:	6a 00                	push   $0x0
  pushl $225
80105c14:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105c19:	e9 bd f2 ff ff       	jmp    80104edb <alltraps>

80105c1e <vector226>:
.globl vector226
vector226:
  pushl $0
80105c1e:	6a 00                	push   $0x0
  pushl $226
80105c20:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105c25:	e9 b1 f2 ff ff       	jmp    80104edb <alltraps>

80105c2a <vector227>:
.globl vector227
vector227:
  pushl $0
80105c2a:	6a 00                	push   $0x0
  pushl $227
80105c2c:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105c31:	e9 a5 f2 ff ff       	jmp    80104edb <alltraps>

80105c36 <vector228>:
.globl vector228
vector228:
  pushl $0
80105c36:	6a 00                	push   $0x0
  pushl $228
80105c38:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105c3d:	e9 99 f2 ff ff       	jmp    80104edb <alltraps>

80105c42 <vector229>:
.globl vector229
vector229:
  pushl $0
80105c42:	6a 00                	push   $0x0
  pushl $229
80105c44:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c49:	e9 8d f2 ff ff       	jmp    80104edb <alltraps>

80105c4e <vector230>:
.globl vector230
vector230:
  pushl $0
80105c4e:	6a 00                	push   $0x0
  pushl $230
80105c50:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c55:	e9 81 f2 ff ff       	jmp    80104edb <alltraps>

80105c5a <vector231>:
.globl vector231
vector231:
  pushl $0
80105c5a:	6a 00                	push   $0x0
  pushl $231
80105c5c:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105c61:	e9 75 f2 ff ff       	jmp    80104edb <alltraps>

80105c66 <vector232>:
.globl vector232
vector232:
  pushl $0
80105c66:	6a 00                	push   $0x0
  pushl $232
80105c68:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105c6d:	e9 69 f2 ff ff       	jmp    80104edb <alltraps>

80105c72 <vector233>:
.globl vector233
vector233:
  pushl $0
80105c72:	6a 00                	push   $0x0
  pushl $233
80105c74:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105c79:	e9 5d f2 ff ff       	jmp    80104edb <alltraps>

80105c7e <vector234>:
.globl vector234
vector234:
  pushl $0
80105c7e:	6a 00                	push   $0x0
  pushl $234
80105c80:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105c85:	e9 51 f2 ff ff       	jmp    80104edb <alltraps>

80105c8a <vector235>:
.globl vector235
vector235:
  pushl $0
80105c8a:	6a 00                	push   $0x0
  pushl $235
80105c8c:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105c91:	e9 45 f2 ff ff       	jmp    80104edb <alltraps>

80105c96 <vector236>:
.globl vector236
vector236:
  pushl $0
80105c96:	6a 00                	push   $0x0
  pushl $236
80105c98:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105c9d:	e9 39 f2 ff ff       	jmp    80104edb <alltraps>

80105ca2 <vector237>:
.globl vector237
vector237:
  pushl $0
80105ca2:	6a 00                	push   $0x0
  pushl $237
80105ca4:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105ca9:	e9 2d f2 ff ff       	jmp    80104edb <alltraps>

80105cae <vector238>:
.globl vector238
vector238:
  pushl $0
80105cae:	6a 00                	push   $0x0
  pushl $238
80105cb0:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105cb5:	e9 21 f2 ff ff       	jmp    80104edb <alltraps>

80105cba <vector239>:
.globl vector239
vector239:
  pushl $0
80105cba:	6a 00                	push   $0x0
  pushl $239
80105cbc:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105cc1:	e9 15 f2 ff ff       	jmp    80104edb <alltraps>

80105cc6 <vector240>:
.globl vector240
vector240:
  pushl $0
80105cc6:	6a 00                	push   $0x0
  pushl $240
80105cc8:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105ccd:	e9 09 f2 ff ff       	jmp    80104edb <alltraps>

80105cd2 <vector241>:
.globl vector241
vector241:
  pushl $0
80105cd2:	6a 00                	push   $0x0
  pushl $241
80105cd4:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105cd9:	e9 fd f1 ff ff       	jmp    80104edb <alltraps>

80105cde <vector242>:
.globl vector242
vector242:
  pushl $0
80105cde:	6a 00                	push   $0x0
  pushl $242
80105ce0:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105ce5:	e9 f1 f1 ff ff       	jmp    80104edb <alltraps>

80105cea <vector243>:
.globl vector243
vector243:
  pushl $0
80105cea:	6a 00                	push   $0x0
  pushl $243
80105cec:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105cf1:	e9 e5 f1 ff ff       	jmp    80104edb <alltraps>

80105cf6 <vector244>:
.globl vector244
vector244:
  pushl $0
80105cf6:	6a 00                	push   $0x0
  pushl $244
80105cf8:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105cfd:	e9 d9 f1 ff ff       	jmp    80104edb <alltraps>

80105d02 <vector245>:
.globl vector245
vector245:
  pushl $0
80105d02:	6a 00                	push   $0x0
  pushl $245
80105d04:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105d09:	e9 cd f1 ff ff       	jmp    80104edb <alltraps>

80105d0e <vector246>:
.globl vector246
vector246:
  pushl $0
80105d0e:	6a 00                	push   $0x0
  pushl $246
80105d10:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105d15:	e9 c1 f1 ff ff       	jmp    80104edb <alltraps>

80105d1a <vector247>:
.globl vector247
vector247:
  pushl $0
80105d1a:	6a 00                	push   $0x0
  pushl $247
80105d1c:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105d21:	e9 b5 f1 ff ff       	jmp    80104edb <alltraps>

80105d26 <vector248>:
.globl vector248
vector248:
  pushl $0
80105d26:	6a 00                	push   $0x0
  pushl $248
80105d28:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105d2d:	e9 a9 f1 ff ff       	jmp    80104edb <alltraps>

80105d32 <vector249>:
.globl vector249
vector249:
  pushl $0
80105d32:	6a 00                	push   $0x0
  pushl $249
80105d34:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105d39:	e9 9d f1 ff ff       	jmp    80104edb <alltraps>

80105d3e <vector250>:
.globl vector250
vector250:
  pushl $0
80105d3e:	6a 00                	push   $0x0
  pushl $250
80105d40:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105d45:	e9 91 f1 ff ff       	jmp    80104edb <alltraps>

80105d4a <vector251>:
.globl vector251
vector251:
  pushl $0
80105d4a:	6a 00                	push   $0x0
  pushl $251
80105d4c:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d51:	e9 85 f1 ff ff       	jmp    80104edb <alltraps>

80105d56 <vector252>:
.globl vector252
vector252:
  pushl $0
80105d56:	6a 00                	push   $0x0
  pushl $252
80105d58:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d5d:	e9 79 f1 ff ff       	jmp    80104edb <alltraps>

80105d62 <vector253>:
.globl vector253
vector253:
  pushl $0
80105d62:	6a 00                	push   $0x0
  pushl $253
80105d64:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105d69:	e9 6d f1 ff ff       	jmp    80104edb <alltraps>

80105d6e <vector254>:
.globl vector254
vector254:
  pushl $0
80105d6e:	6a 00                	push   $0x0
  pushl $254
80105d70:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105d75:	e9 61 f1 ff ff       	jmp    80104edb <alltraps>

80105d7a <vector255>:
.globl vector255
vector255:
  pushl $0
80105d7a:	6a 00                	push   $0x0
  pushl $255
80105d7c:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105d81:	e9 55 f1 ff ff       	jmp    80104edb <alltraps>

80105d86 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105d86:	55                   	push   %ebp
80105d87:	89 e5                	mov    %esp,%ebp
80105d89:	57                   	push   %edi
80105d8a:	56                   	push   %esi
80105d8b:	53                   	push   %ebx
80105d8c:	83 ec 0c             	sub    $0xc,%esp
80105d8f:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105d91:	c1 ea 16             	shr    $0x16,%edx
80105d94:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105d97:	8b 1f                	mov    (%edi),%ebx
80105d99:	f6 c3 01             	test   $0x1,%bl
80105d9c:	74 22                	je     80105dc0 <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105d9e:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105da4:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105daa:	c1 ee 0c             	shr    $0xc,%esi
80105dad:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105db3:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105db6:	89 d8                	mov    %ebx,%eax
80105db8:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105dbb:	5b                   	pop    %ebx
80105dbc:	5e                   	pop    %esi
80105dbd:	5f                   	pop    %edi
80105dbe:	5d                   	pop    %ebp
80105dbf:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc1(-2)) == 0)
80105dc0:	85 c9                	test   %ecx,%ecx
80105dc2:	74 33                	je     80105df7 <walkpgdir+0x71>
80105dc4:	83 ec 0c             	sub    $0xc,%esp
80105dc7:	6a fe                	push   $0xfffffffe
80105dc9:	e8 19 c3 ff ff       	call   801020e7 <kalloc1>
80105dce:	89 c3                	mov    %eax,%ebx
80105dd0:	83 c4 10             	add    $0x10,%esp
80105dd3:	85 c0                	test   %eax,%eax
80105dd5:	74 df                	je     80105db6 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105dd7:	83 ec 04             	sub    $0x4,%esp
80105dda:	68 00 10 00 00       	push   $0x1000
80105ddf:	6a 00                	push   $0x0
80105de1:	50                   	push   %eax
80105de2:	e8 f6 df ff ff       	call   80103ddd <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105de7:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105ded:	83 c8 07             	or     $0x7,%eax
80105df0:	89 07                	mov    %eax,(%edi)
80105df2:	83 c4 10             	add    $0x10,%esp
80105df5:	eb b3                	jmp    80105daa <walkpgdir+0x24>
      return 0;
80105df7:	bb 00 00 00 00       	mov    $0x0,%ebx
80105dfc:	eb b8                	jmp    80105db6 <walkpgdir+0x30>

80105dfe <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105dfe:	55                   	push   %ebp
80105dff:	89 e5                	mov    %esp,%ebp
80105e01:	57                   	push   %edi
80105e02:	56                   	push   %esi
80105e03:	53                   	push   %ebx
80105e04:	83 ec 1c             	sub    $0x1c,%esp
80105e07:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105e0a:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105e0d:	89 d3                	mov    %edx,%ebx
80105e0f:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105e15:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105e19:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e1f:	b9 01 00 00 00       	mov    $0x1,%ecx
80105e24:	89 da                	mov    %ebx,%edx
80105e26:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e29:	e8 58 ff ff ff       	call   80105d86 <walkpgdir>
80105e2e:	85 c0                	test   %eax,%eax
80105e30:	74 2e                	je     80105e60 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105e32:	f6 00 01             	testb  $0x1,(%eax)
80105e35:	75 1c                	jne    80105e53 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105e37:	89 f2                	mov    %esi,%edx
80105e39:	0b 55 0c             	or     0xc(%ebp),%edx
80105e3c:	83 ca 01             	or     $0x1,%edx
80105e3f:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105e41:	39 fb                	cmp    %edi,%ebx
80105e43:	74 28                	je     80105e6d <mappages+0x6f>
      break;
    a += PGSIZE;
80105e45:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105e4b:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e51:	eb cc                	jmp    80105e1f <mappages+0x21>
      panic("remap");
80105e53:	83 ec 0c             	sub    $0xc,%esp
80105e56:	68 2c 6f 10 80       	push   $0x80106f2c
80105e5b:	e8 e8 a4 ff ff       	call   80100348 <panic>
      return -1;
80105e60:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105e65:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e68:	5b                   	pop    %ebx
80105e69:	5e                   	pop    %esi
80105e6a:	5f                   	pop    %edi
80105e6b:	5d                   	pop    %ebp
80105e6c:	c3                   	ret    
  return 0;
80105e6d:	b8 00 00 00 00       	mov    $0x0,%eax
80105e72:	eb f1                	jmp    80105e65 <mappages+0x67>

80105e74 <seginit>:
{
80105e74:	55                   	push   %ebp
80105e75:	89 e5                	mov    %esp,%ebp
80105e77:	53                   	push   %ebx
80105e78:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105e7b:	e8 f4 d4 ff ff       	call   80103374 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105e80:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105e86:	66 c7 80 f8 a7 14 80 	movw   $0xffff,-0x7feb5808(%eax)
80105e8d:	ff ff 
80105e8f:	66 c7 80 fa a7 14 80 	movw   $0x0,-0x7feb5806(%eax)
80105e96:	00 00 
80105e98:	c6 80 fc a7 14 80 00 	movb   $0x0,-0x7feb5804(%eax)
80105e9f:	0f b6 88 fd a7 14 80 	movzbl -0x7feb5803(%eax),%ecx
80105ea6:	83 e1 f0             	and    $0xfffffff0,%ecx
80105ea9:	83 c9 1a             	or     $0x1a,%ecx
80105eac:	83 e1 9f             	and    $0xffffff9f,%ecx
80105eaf:	83 c9 80             	or     $0xffffff80,%ecx
80105eb2:	88 88 fd a7 14 80    	mov    %cl,-0x7feb5803(%eax)
80105eb8:	0f b6 88 fe a7 14 80 	movzbl -0x7feb5802(%eax),%ecx
80105ebf:	83 c9 0f             	or     $0xf,%ecx
80105ec2:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ec5:	83 c9 c0             	or     $0xffffffc0,%ecx
80105ec8:	88 88 fe a7 14 80    	mov    %cl,-0x7feb5802(%eax)
80105ece:	c6 80 ff a7 14 80 00 	movb   $0x0,-0x7feb5801(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105ed5:	66 c7 80 00 a8 14 80 	movw   $0xffff,-0x7feb5800(%eax)
80105edc:	ff ff 
80105ede:	66 c7 80 02 a8 14 80 	movw   $0x0,-0x7feb57fe(%eax)
80105ee5:	00 00 
80105ee7:	c6 80 04 a8 14 80 00 	movb   $0x0,-0x7feb57fc(%eax)
80105eee:	0f b6 88 05 a8 14 80 	movzbl -0x7feb57fb(%eax),%ecx
80105ef5:	83 e1 f0             	and    $0xfffffff0,%ecx
80105ef8:	83 c9 12             	or     $0x12,%ecx
80105efb:	83 e1 9f             	and    $0xffffff9f,%ecx
80105efe:	83 c9 80             	or     $0xffffff80,%ecx
80105f01:	88 88 05 a8 14 80    	mov    %cl,-0x7feb57fb(%eax)
80105f07:	0f b6 88 06 a8 14 80 	movzbl -0x7feb57fa(%eax),%ecx
80105f0e:	83 c9 0f             	or     $0xf,%ecx
80105f11:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f14:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f17:	88 88 06 a8 14 80    	mov    %cl,-0x7feb57fa(%eax)
80105f1d:	c6 80 07 a8 14 80 00 	movb   $0x0,-0x7feb57f9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105f24:	66 c7 80 08 a8 14 80 	movw   $0xffff,-0x7feb57f8(%eax)
80105f2b:	ff ff 
80105f2d:	66 c7 80 0a a8 14 80 	movw   $0x0,-0x7feb57f6(%eax)
80105f34:	00 00 
80105f36:	c6 80 0c a8 14 80 00 	movb   $0x0,-0x7feb57f4(%eax)
80105f3d:	c6 80 0d a8 14 80 fa 	movb   $0xfa,-0x7feb57f3(%eax)
80105f44:	0f b6 88 0e a8 14 80 	movzbl -0x7feb57f2(%eax),%ecx
80105f4b:	83 c9 0f             	or     $0xf,%ecx
80105f4e:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f51:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f54:	88 88 0e a8 14 80    	mov    %cl,-0x7feb57f2(%eax)
80105f5a:	c6 80 0f a8 14 80 00 	movb   $0x0,-0x7feb57f1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f61:	66 c7 80 10 a8 14 80 	movw   $0xffff,-0x7feb57f0(%eax)
80105f68:	ff ff 
80105f6a:	66 c7 80 12 a8 14 80 	movw   $0x0,-0x7feb57ee(%eax)
80105f71:	00 00 
80105f73:	c6 80 14 a8 14 80 00 	movb   $0x0,-0x7feb57ec(%eax)
80105f7a:	c6 80 15 a8 14 80 f2 	movb   $0xf2,-0x7feb57eb(%eax)
80105f81:	0f b6 88 16 a8 14 80 	movzbl -0x7feb57ea(%eax),%ecx
80105f88:	83 c9 0f             	or     $0xf,%ecx
80105f8b:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f8e:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f91:	88 88 16 a8 14 80    	mov    %cl,-0x7feb57ea(%eax)
80105f97:	c6 80 17 a8 14 80 00 	movb   $0x0,-0x7feb57e9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105f9e:	05 f0 a7 14 80       	add    $0x8014a7f0,%eax
  pd[0] = size-1;
80105fa3:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105fa9:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105fad:	c1 e8 10             	shr    $0x10,%eax
80105fb0:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105fb4:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105fb7:	0f 01 10             	lgdtl  (%eax)
}
80105fba:	83 c4 14             	add    $0x14,%esp
80105fbd:	5b                   	pop    %ebx
80105fbe:	5d                   	pop    %ebp
80105fbf:	c3                   	ret    

80105fc0 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105fc0:	55                   	push   %ebp
80105fc1:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105fc3:	a1 a4 d4 14 80       	mov    0x8014d4a4,%eax
80105fc8:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80105fcd:	0f 22 d8             	mov    %eax,%cr3
}
80105fd0:	5d                   	pop    %ebp
80105fd1:	c3                   	ret    

80105fd2 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80105fd2:	55                   	push   %ebp
80105fd3:	89 e5                	mov    %esp,%ebp
80105fd5:	57                   	push   %edi
80105fd6:	56                   	push   %esi
80105fd7:	53                   	push   %ebx
80105fd8:	83 ec 1c             	sub    $0x1c,%esp
80105fdb:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80105fde:	85 f6                	test   %esi,%esi
80105fe0:	0f 84 dd 00 00 00    	je     801060c3 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80105fe6:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
80105fea:	0f 84 e0 00 00 00    	je     801060d0 <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80105ff0:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80105ff4:	0f 84 e3 00 00 00    	je     801060dd <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
80105ffa:	e8 55 dc ff ff       	call   80103c54 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80105fff:	e8 14 d3 ff ff       	call   80103318 <mycpu>
80106004:	89 c3                	mov    %eax,%ebx
80106006:	e8 0d d3 ff ff       	call   80103318 <mycpu>
8010600b:	8d 78 08             	lea    0x8(%eax),%edi
8010600e:	e8 05 d3 ff ff       	call   80103318 <mycpu>
80106013:	83 c0 08             	add    $0x8,%eax
80106016:	c1 e8 10             	shr    $0x10,%eax
80106019:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010601c:	e8 f7 d2 ff ff       	call   80103318 <mycpu>
80106021:	83 c0 08             	add    $0x8,%eax
80106024:	c1 e8 18             	shr    $0x18,%eax
80106027:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
8010602e:	67 00 
80106030:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
80106037:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
8010603b:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106041:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
80106048:	83 e2 f0             	and    $0xfffffff0,%edx
8010604b:	83 ca 19             	or     $0x19,%edx
8010604e:	83 e2 9f             	and    $0xffffff9f,%edx
80106051:	83 ca 80             	or     $0xffffff80,%edx
80106054:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010605a:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106061:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
80106067:	e8 ac d2 ff ff       	call   80103318 <mycpu>
8010606c:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
80106073:	83 e2 ef             	and    $0xffffffef,%edx
80106076:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
8010607c:	e8 97 d2 ff ff       	call   80103318 <mycpu>
80106081:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
80106087:	8b 5e 08             	mov    0x8(%esi),%ebx
8010608a:	e8 89 d2 ff ff       	call   80103318 <mycpu>
8010608f:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106095:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
80106098:	e8 7b d2 ff ff       	call   80103318 <mycpu>
8010609d:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801060a3:	b8 28 00 00 00       	mov    $0x28,%eax
801060a8:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801060ab:	8b 46 04             	mov    0x4(%esi),%eax
801060ae:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060b3:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801060b6:	e8 d6 db ff ff       	call   80103c91 <popcli>
}
801060bb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060be:	5b                   	pop    %ebx
801060bf:	5e                   	pop    %esi
801060c0:	5f                   	pop    %edi
801060c1:	5d                   	pop    %ebp
801060c2:	c3                   	ret    
    panic("switchuvm: no process");
801060c3:	83 ec 0c             	sub    $0xc,%esp
801060c6:	68 32 6f 10 80       	push   $0x80106f32
801060cb:	e8 78 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
801060d0:	83 ec 0c             	sub    $0xc,%esp
801060d3:	68 48 6f 10 80       	push   $0x80106f48
801060d8:	e8 6b a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
801060dd:	83 ec 0c             	sub    $0xc,%esp
801060e0:	68 5d 6f 10 80       	push   $0x80106f5d
801060e5:	e8 5e a2 ff ff       	call   80100348 <panic>

801060ea <inituvm>:
// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
//inituvm(pde_t *pgdir, char *init, uint sz, int pid)
{
801060ea:	55                   	push   %ebp
801060eb:	89 e5                	mov    %esp,%ebp
801060ed:	56                   	push   %esi
801060ee:	53                   	push   %ebx
801060ef:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
801060f2:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801060f8:	77 51                	ja     8010614b <inituvm+0x61>
    panic("inituvm: more than a page");
  mem = kalloc1(-2);//
801060fa:	83 ec 0c             	sub    $0xc,%esp
801060fd:	6a fe                	push   $0xfffffffe
801060ff:	e8 e3 bf ff ff       	call   801020e7 <kalloc1>
80106104:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106106:	83 c4 0c             	add    $0xc,%esp
80106109:	68 00 10 00 00       	push   $0x1000
8010610e:	6a 00                	push   $0x0
80106110:	50                   	push   %eax
80106111:	e8 c7 dc ff ff       	call   80103ddd <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106116:	83 c4 08             	add    $0x8,%esp
80106119:	6a 06                	push   $0x6
8010611b:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106121:	50                   	push   %eax
80106122:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106127:	ba 00 00 00 00       	mov    $0x0,%edx
8010612c:	8b 45 08             	mov    0x8(%ebp),%eax
8010612f:	e8 ca fc ff ff       	call   80105dfe <mappages>
  memmove(mem, init, sz);
80106134:	83 c4 0c             	add    $0xc,%esp
80106137:	56                   	push   %esi
80106138:	ff 75 0c             	pushl  0xc(%ebp)
8010613b:	53                   	push   %ebx
8010613c:	e8 17 dd ff ff       	call   80103e58 <memmove>
}
80106141:	83 c4 10             	add    $0x10,%esp
80106144:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106147:	5b                   	pop    %ebx
80106148:	5e                   	pop    %esi
80106149:	5d                   	pop    %ebp
8010614a:	c3                   	ret    
    panic("inituvm: more than a page");
8010614b:	83 ec 0c             	sub    $0xc,%esp
8010614e:	68 71 6f 10 80       	push   $0x80106f71
80106153:	e8 f0 a1 ff ff       	call   80100348 <panic>

80106158 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106158:	55                   	push   %ebp
80106159:	89 e5                	mov    %esp,%ebp
8010615b:	57                   	push   %edi
8010615c:	56                   	push   %esi
8010615d:	53                   	push   %ebx
8010615e:	83 ec 0c             	sub    $0xc,%esp
80106161:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106164:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
8010616b:	75 07                	jne    80106174 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010616d:	bb 00 00 00 00       	mov    $0x0,%ebx
80106172:	eb 3c                	jmp    801061b0 <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
80106174:	83 ec 0c             	sub    $0xc,%esp
80106177:	68 2c 70 10 80       	push   $0x8010702c
8010617c:	e8 c7 a1 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
80106181:	83 ec 0c             	sub    $0xc,%esp
80106184:	68 8b 6f 10 80       	push   $0x80106f8b
80106189:	e8 ba a1 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
8010618e:	05 00 00 00 80       	add    $0x80000000,%eax
80106193:	56                   	push   %esi
80106194:	89 da                	mov    %ebx,%edx
80106196:	03 55 14             	add    0x14(%ebp),%edx
80106199:	52                   	push   %edx
8010619a:	50                   	push   %eax
8010619b:	ff 75 10             	pushl  0x10(%ebp)
8010619e:	e8 d0 b5 ff ff       	call   80101773 <readi>
801061a3:	83 c4 10             	add    $0x10,%esp
801061a6:	39 f0                	cmp    %esi,%eax
801061a8:	75 47                	jne    801061f1 <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
801061aa:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061b0:	39 fb                	cmp    %edi,%ebx
801061b2:	73 30                	jae    801061e4 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801061b4:	89 da                	mov    %ebx,%edx
801061b6:	03 55 0c             	add    0xc(%ebp),%edx
801061b9:	b9 00 00 00 00       	mov    $0x0,%ecx
801061be:	8b 45 08             	mov    0x8(%ebp),%eax
801061c1:	e8 c0 fb ff ff       	call   80105d86 <walkpgdir>
801061c6:	85 c0                	test   %eax,%eax
801061c8:	74 b7                	je     80106181 <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801061ca:	8b 00                	mov    (%eax),%eax
801061cc:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801061d1:	89 fe                	mov    %edi,%esi
801061d3:	29 de                	sub    %ebx,%esi
801061d5:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
801061db:	76 b1                	jbe    8010618e <loaduvm+0x36>
      n = PGSIZE;
801061dd:	be 00 10 00 00       	mov    $0x1000,%esi
801061e2:	eb aa                	jmp    8010618e <loaduvm+0x36>
      return -1;
  }
  return 0;
801061e4:	b8 00 00 00 00       	mov    $0x0,%eax
}
801061e9:	8d 65 f4             	lea    -0xc(%ebp),%esp
801061ec:	5b                   	pop    %ebx
801061ed:	5e                   	pop    %esi
801061ee:	5f                   	pop    %edi
801061ef:	5d                   	pop    %ebp
801061f0:	c3                   	ret    
      return -1;
801061f1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801061f6:	eb f1                	jmp    801061e9 <loaduvm+0x91>

801061f8 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
801061f8:	55                   	push   %ebp
801061f9:	89 e5                	mov    %esp,%ebp
801061fb:	57                   	push   %edi
801061fc:	56                   	push   %esi
801061fd:	53                   	push   %ebx
801061fe:	83 ec 0c             	sub    $0xc,%esp
80106201:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106204:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106207:	73 11                	jae    8010621a <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106209:	8b 45 10             	mov    0x10(%ebp),%eax
8010620c:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106212:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106218:	eb 19                	jmp    80106233 <deallocuvm+0x3b>
    return oldsz;
8010621a:	89 f8                	mov    %edi,%eax
8010621c:	eb 64                	jmp    80106282 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010621e:	c1 eb 16             	shr    $0x16,%ebx
80106221:	83 c3 01             	add    $0x1,%ebx
80106224:	c1 e3 16             	shl    $0x16,%ebx
80106227:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010622d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106233:	39 fb                	cmp    %edi,%ebx
80106235:	73 48                	jae    8010627f <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106237:	b9 00 00 00 00       	mov    $0x0,%ecx
8010623c:	89 da                	mov    %ebx,%edx
8010623e:	8b 45 08             	mov    0x8(%ebp),%eax
80106241:	e8 40 fb ff ff       	call   80105d86 <walkpgdir>
80106246:	89 c6                	mov    %eax,%esi
    if(!pte)
80106248:	85 c0                	test   %eax,%eax
8010624a:	74 d2                	je     8010621e <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010624c:	8b 00                	mov    (%eax),%eax
8010624e:	a8 01                	test   $0x1,%al
80106250:	74 db                	je     8010622d <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106252:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106257:	74 19                	je     80106272 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
80106259:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010625e:	83 ec 0c             	sub    $0xc,%esp
80106261:	50                   	push   %eax
80106262:	e8 3d bd ff ff       	call   80101fa4 <kfree>
      *pte = 0;
80106267:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010626d:	83 c4 10             	add    $0x10,%esp
80106270:	eb bb                	jmp    8010622d <deallocuvm+0x35>
        panic("kfree");
80106272:	83 ec 0c             	sub    $0xc,%esp
80106275:	68 c6 68 10 80       	push   $0x801068c6
8010627a:	e8 c9 a0 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
8010627f:	8b 45 10             	mov    0x10(%ebp),%eax
}
80106282:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106285:	5b                   	pop    %ebx
80106286:	5e                   	pop    %esi
80106287:	5f                   	pop    %edi
80106288:	5d                   	pop    %ebp
80106289:	c3                   	ret    

8010628a <allocuvm>:
{
8010628a:	55                   	push   %ebp
8010628b:	89 e5                	mov    %esp,%ebp
8010628d:	57                   	push   %edi
8010628e:	56                   	push   %esi
8010628f:	53                   	push   %ebx
80106290:	83 ec 1c             	sub    $0x1c,%esp
80106293:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
80106296:	89 7d e4             	mov    %edi,-0x1c(%ebp)
80106299:	85 ff                	test   %edi,%edi
8010629b:	0f 88 cf 00 00 00    	js     80106370 <allocuvm+0xe6>
  if(newsz < oldsz)
801062a1:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801062a4:	72 6a                	jb     80106310 <allocuvm+0x86>
  a = PGROUNDUP(oldsz);
801062a6:	8b 45 0c             	mov    0xc(%ebp),%eax
801062a9:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062af:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801062b5:	39 fb                	cmp    %edi,%ebx
801062b7:	0f 83 ba 00 00 00    	jae    80106377 <allocuvm+0xed>
    mem = kalloc1(myproc()->pid);
801062bd:	e8 cd d0 ff ff       	call   8010338f <myproc>
801062c2:	83 ec 0c             	sub    $0xc,%esp
801062c5:	ff 70 10             	pushl  0x10(%eax)
801062c8:	e8 1a be ff ff       	call   801020e7 <kalloc1>
801062cd:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801062cf:	83 c4 10             	add    $0x10,%esp
801062d2:	85 c0                	test   %eax,%eax
801062d4:	74 42                	je     80106318 <allocuvm+0x8e>
    memset(mem, 0, PGSIZE);
801062d6:	83 ec 04             	sub    $0x4,%esp
801062d9:	68 00 10 00 00       	push   $0x1000
801062de:	6a 00                	push   $0x0
801062e0:	50                   	push   %eax
801062e1:	e8 f7 da ff ff       	call   80103ddd <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
801062e6:	83 c4 08             	add    $0x8,%esp
801062e9:	6a 06                	push   $0x6
801062eb:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
801062f1:	50                   	push   %eax
801062f2:	b9 00 10 00 00       	mov    $0x1000,%ecx
801062f7:	89 da                	mov    %ebx,%edx
801062f9:	8b 45 08             	mov    0x8(%ebp),%eax
801062fc:	e8 fd fa ff ff       	call   80105dfe <mappages>
80106301:	83 c4 10             	add    $0x10,%esp
80106304:	85 c0                	test   %eax,%eax
80106306:	78 38                	js     80106340 <allocuvm+0xb6>
  for(; a < newsz; a += PGSIZE){
80106308:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010630e:	eb a5                	jmp    801062b5 <allocuvm+0x2b>
    return oldsz;
80106310:	8b 45 0c             	mov    0xc(%ebp),%eax
80106313:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106316:	eb 5f                	jmp    80106377 <allocuvm+0xed>
      cprintf("allocuvm out of memory\n");
80106318:	83 ec 0c             	sub    $0xc,%esp
8010631b:	68 a9 6f 10 80       	push   $0x80106fa9
80106320:	e8 e6 a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106325:	83 c4 0c             	add    $0xc,%esp
80106328:	ff 75 0c             	pushl  0xc(%ebp)
8010632b:	57                   	push   %edi
8010632c:	ff 75 08             	pushl  0x8(%ebp)
8010632f:	e8 c4 fe ff ff       	call   801061f8 <deallocuvm>
      return 0;
80106334:	83 c4 10             	add    $0x10,%esp
80106337:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010633e:	eb 37                	jmp    80106377 <allocuvm+0xed>
      cprintf("allocuvm out of memory (2)\n");
80106340:	83 ec 0c             	sub    $0xc,%esp
80106343:	68 c1 6f 10 80       	push   $0x80106fc1
80106348:	e8 be a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010634d:	83 c4 0c             	add    $0xc,%esp
80106350:	ff 75 0c             	pushl  0xc(%ebp)
80106353:	57                   	push   %edi
80106354:	ff 75 08             	pushl  0x8(%ebp)
80106357:	e8 9c fe ff ff       	call   801061f8 <deallocuvm>
      kfree(mem);
8010635c:	89 34 24             	mov    %esi,(%esp)
8010635f:	e8 40 bc ff ff       	call   80101fa4 <kfree>
      return 0;
80106364:	83 c4 10             	add    $0x10,%esp
80106367:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010636e:	eb 07                	jmp    80106377 <allocuvm+0xed>
    return 0;
80106370:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106377:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010637a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010637d:	5b                   	pop    %ebx
8010637e:	5e                   	pop    %esi
8010637f:	5f                   	pop    %edi
80106380:	5d                   	pop    %ebp
80106381:	c3                   	ret    

80106382 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
80106382:	55                   	push   %ebp
80106383:	89 e5                	mov    %esp,%ebp
80106385:	56                   	push   %esi
80106386:	53                   	push   %ebx
80106387:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
8010638a:	85 f6                	test   %esi,%esi
8010638c:	74 1a                	je     801063a8 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
8010638e:	83 ec 04             	sub    $0x4,%esp
80106391:	6a 00                	push   $0x0
80106393:	68 00 00 00 80       	push   $0x80000000
80106398:	56                   	push   %esi
80106399:	e8 5a fe ff ff       	call   801061f8 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
8010639e:	83 c4 10             	add    $0x10,%esp
801063a1:	bb 00 00 00 00       	mov    $0x0,%ebx
801063a6:	eb 10                	jmp    801063b8 <freevm+0x36>
    panic("freevm: no pgdir");
801063a8:	83 ec 0c             	sub    $0xc,%esp
801063ab:	68 dd 6f 10 80       	push   $0x80106fdd
801063b0:	e8 93 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801063b5:	83 c3 01             	add    $0x1,%ebx
801063b8:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801063be:	77 1f                	ja     801063df <freevm+0x5d>
    if(pgdir[i] & PTE_P){
801063c0:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801063c3:	a8 01                	test   $0x1,%al
801063c5:	74 ee                	je     801063b5 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801063c7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801063cc:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801063d1:	83 ec 0c             	sub    $0xc,%esp
801063d4:	50                   	push   %eax
801063d5:	e8 ca bb ff ff       	call   80101fa4 <kfree>
801063da:	83 c4 10             	add    $0x10,%esp
801063dd:	eb d6                	jmp    801063b5 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801063df:	83 ec 0c             	sub    $0xc,%esp
801063e2:	56                   	push   %esi
801063e3:	e8 bc bb ff ff       	call   80101fa4 <kfree>
}
801063e8:	83 c4 10             	add    $0x10,%esp
801063eb:	8d 65 f8             	lea    -0x8(%ebp),%esp
801063ee:	5b                   	pop    %ebx
801063ef:	5e                   	pop    %esi
801063f0:	5d                   	pop    %ebp
801063f1:	c3                   	ret    

801063f2 <setupkvm>:
{
801063f2:	55                   	push   %ebp
801063f3:	89 e5                	mov    %esp,%ebp
801063f5:	56                   	push   %esi
801063f6:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc1(-2)) == 0)
801063f7:	83 ec 0c             	sub    $0xc,%esp
801063fa:	6a fe                	push   $0xfffffffe
801063fc:	e8 e6 bc ff ff       	call   801020e7 <kalloc1>
80106401:	89 c6                	mov    %eax,%esi
80106403:	83 c4 10             	add    $0x10,%esp
80106406:	85 c0                	test   %eax,%eax
80106408:	74 55                	je     8010645f <setupkvm+0x6d>
  memset(pgdir, 0, PGSIZE);
8010640a:	83 ec 04             	sub    $0x4,%esp
8010640d:	68 00 10 00 00       	push   $0x1000
80106412:	6a 00                	push   $0x0
80106414:	50                   	push   %eax
80106415:	e8 c3 d9 ff ff       	call   80103ddd <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
8010641a:	83 c4 10             	add    $0x10,%esp
8010641d:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
80106422:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106428:	73 35                	jae    8010645f <setupkvm+0x6d>
                (uint)k->phys_start, k->perm) < 0) {
8010642a:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
8010642d:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106430:	29 c1                	sub    %eax,%ecx
80106432:	83 ec 08             	sub    $0x8,%esp
80106435:	ff 73 0c             	pushl  0xc(%ebx)
80106438:	50                   	push   %eax
80106439:	8b 13                	mov    (%ebx),%edx
8010643b:	89 f0                	mov    %esi,%eax
8010643d:	e8 bc f9 ff ff       	call   80105dfe <mappages>
80106442:	83 c4 10             	add    $0x10,%esp
80106445:	85 c0                	test   %eax,%eax
80106447:	78 05                	js     8010644e <setupkvm+0x5c>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106449:	83 c3 10             	add    $0x10,%ebx
8010644c:	eb d4                	jmp    80106422 <setupkvm+0x30>
      freevm(pgdir);
8010644e:	83 ec 0c             	sub    $0xc,%esp
80106451:	56                   	push   %esi
80106452:	e8 2b ff ff ff       	call   80106382 <freevm>
      return 0;
80106457:	83 c4 10             	add    $0x10,%esp
8010645a:	be 00 00 00 00       	mov    $0x0,%esi
}
8010645f:	89 f0                	mov    %esi,%eax
80106461:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106464:	5b                   	pop    %ebx
80106465:	5e                   	pop    %esi
80106466:	5d                   	pop    %ebp
80106467:	c3                   	ret    

80106468 <kvmalloc>:
{
80106468:	55                   	push   %ebp
80106469:	89 e5                	mov    %esp,%ebp
8010646b:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
8010646e:	e8 7f ff ff ff       	call   801063f2 <setupkvm>
80106473:	a3 a4 d4 14 80       	mov    %eax,0x8014d4a4
  switchkvm();
80106478:	e8 43 fb ff ff       	call   80105fc0 <switchkvm>
}
8010647d:	c9                   	leave  
8010647e:	c3                   	ret    

8010647f <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
8010647f:	55                   	push   %ebp
80106480:	89 e5                	mov    %esp,%ebp
80106482:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
80106485:	b9 00 00 00 00       	mov    $0x0,%ecx
8010648a:	8b 55 0c             	mov    0xc(%ebp),%edx
8010648d:	8b 45 08             	mov    0x8(%ebp),%eax
80106490:	e8 f1 f8 ff ff       	call   80105d86 <walkpgdir>
  if(pte == 0)
80106495:	85 c0                	test   %eax,%eax
80106497:	74 05                	je     8010649e <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
80106499:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
8010649c:	c9                   	leave  
8010649d:	c3                   	ret    
    panic("clearpteu");
8010649e:	83 ec 0c             	sub    $0xc,%esp
801064a1:	68 ee 6f 10 80       	push   $0x80106fee
801064a6:	e8 9d 9e ff ff       	call   80100348 <panic>

801064ab <copyuvm>:
// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
//copyuvm(pde_t *pgdir, uint sz)
copyuvm(pde_t *pgdir, uint sz, int pid)
{
801064ab:	55                   	push   %ebp
801064ac:	89 e5                	mov    %esp,%ebp
801064ae:	57                   	push   %edi
801064af:	56                   	push   %esi
801064b0:	53                   	push   %ebx
801064b1:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801064b4:	e8 39 ff ff ff       	call   801063f2 <setupkvm>
801064b9:	89 45 dc             	mov    %eax,-0x24(%ebp)
801064bc:	85 c0                	test   %eax,%eax
801064be:	0f 84 d1 00 00 00    	je     80106595 <copyuvm+0xea>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801064c4:	bf 00 00 00 00       	mov    $0x0,%edi
801064c9:	89 fe                	mov    %edi,%esi
801064cb:	3b 75 0c             	cmp    0xc(%ebp),%esi
801064ce:	0f 83 c1 00 00 00    	jae    80106595 <copyuvm+0xea>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801064d4:	89 75 e4             	mov    %esi,-0x1c(%ebp)
801064d7:	b9 00 00 00 00       	mov    $0x0,%ecx
801064dc:	89 f2                	mov    %esi,%edx
801064de:	8b 45 08             	mov    0x8(%ebp),%eax
801064e1:	e8 a0 f8 ff ff       	call   80105d86 <walkpgdir>
801064e6:	85 c0                	test   %eax,%eax
801064e8:	74 70                	je     8010655a <copyuvm+0xaf>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
801064ea:	8b 18                	mov    (%eax),%ebx
801064ec:	f6 c3 01             	test   $0x1,%bl
801064ef:	74 76                	je     80106567 <copyuvm+0xbc>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
801064f1:	89 df                	mov    %ebx,%edi
801064f3:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
    flags = PTE_FLAGS(*pte);
801064f9:	81 e3 ff 0f 00 00    	and    $0xfff,%ebx
801064ff:	89 5d e0             	mov    %ebx,-0x20(%ebp)
    if((mem = kalloc1(pid)) == 0)//
80106502:	83 ec 0c             	sub    $0xc,%esp
80106505:	ff 75 10             	pushl  0x10(%ebp)
80106508:	e8 da bb ff ff       	call   801020e7 <kalloc1>
8010650d:	89 c3                	mov    %eax,%ebx
8010650f:	83 c4 10             	add    $0x10,%esp
80106512:	85 c0                	test   %eax,%eax
80106514:	74 6a                	je     80106580 <copyuvm+0xd5>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106516:	81 c7 00 00 00 80    	add    $0x80000000,%edi
8010651c:	83 ec 04             	sub    $0x4,%esp
8010651f:	68 00 10 00 00       	push   $0x1000
80106524:	57                   	push   %edi
80106525:	50                   	push   %eax
80106526:	e8 2d d9 ff ff       	call   80103e58 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
8010652b:	83 c4 08             	add    $0x8,%esp
8010652e:	ff 75 e0             	pushl  -0x20(%ebp)
80106531:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106537:	50                   	push   %eax
80106538:	b9 00 10 00 00       	mov    $0x1000,%ecx
8010653d:	8b 55 e4             	mov    -0x1c(%ebp),%edx
80106540:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106543:	e8 b6 f8 ff ff       	call   80105dfe <mappages>
80106548:	83 c4 10             	add    $0x10,%esp
8010654b:	85 c0                	test   %eax,%eax
8010654d:	78 25                	js     80106574 <copyuvm+0xc9>
  for(i = 0; i < sz; i += PGSIZE){
8010654f:	81 c6 00 10 00 00    	add    $0x1000,%esi
80106555:	e9 71 ff ff ff       	jmp    801064cb <copyuvm+0x20>
      panic("copyuvm: pte should exist");
8010655a:	83 ec 0c             	sub    $0xc,%esp
8010655d:	68 f8 6f 10 80       	push   $0x80106ff8
80106562:	e8 e1 9d ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106567:	83 ec 0c             	sub    $0xc,%esp
8010656a:	68 12 70 10 80       	push   $0x80107012
8010656f:	e8 d4 9d ff ff       	call   80100348 <panic>
      kfree(mem);
80106574:	83 ec 0c             	sub    $0xc,%esp
80106577:	53                   	push   %ebx
80106578:	e8 27 ba ff ff       	call   80101fa4 <kfree>
      goto bad;
8010657d:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
80106580:	83 ec 0c             	sub    $0xc,%esp
80106583:	ff 75 dc             	pushl  -0x24(%ebp)
80106586:	e8 f7 fd ff ff       	call   80106382 <freevm>
  return 0;
8010658b:	83 c4 10             	add    $0x10,%esp
8010658e:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
80106595:	8b 45 dc             	mov    -0x24(%ebp),%eax
80106598:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010659b:	5b                   	pop    %ebx
8010659c:	5e                   	pop    %esi
8010659d:	5f                   	pop    %edi
8010659e:	5d                   	pop    %ebp
8010659f:	c3                   	ret    

801065a0 <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801065a0:	55                   	push   %ebp
801065a1:	89 e5                	mov    %esp,%ebp
801065a3:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801065a6:	b9 00 00 00 00       	mov    $0x0,%ecx
801065ab:	8b 55 0c             	mov    0xc(%ebp),%edx
801065ae:	8b 45 08             	mov    0x8(%ebp),%eax
801065b1:	e8 d0 f7 ff ff       	call   80105d86 <walkpgdir>
  if((*pte & PTE_P) == 0)
801065b6:	8b 00                	mov    (%eax),%eax
801065b8:	a8 01                	test   $0x1,%al
801065ba:	74 10                	je     801065cc <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
801065bc:	a8 04                	test   $0x4,%al
801065be:	74 13                	je     801065d3 <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801065c0:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065c5:	05 00 00 00 80       	add    $0x80000000,%eax
}
801065ca:	c9                   	leave  
801065cb:	c3                   	ret    
    return 0;
801065cc:	b8 00 00 00 00       	mov    $0x0,%eax
801065d1:	eb f7                	jmp    801065ca <uva2ka+0x2a>
    return 0;
801065d3:	b8 00 00 00 00       	mov    $0x0,%eax
801065d8:	eb f0                	jmp    801065ca <uva2ka+0x2a>

801065da <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801065da:	55                   	push   %ebp
801065db:	89 e5                	mov    %esp,%ebp
801065dd:	57                   	push   %edi
801065de:	56                   	push   %esi
801065df:	53                   	push   %ebx
801065e0:	83 ec 0c             	sub    $0xc,%esp
801065e3:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801065e6:	eb 25                	jmp    8010660d <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801065e8:	8b 55 0c             	mov    0xc(%ebp),%edx
801065eb:	29 f2                	sub    %esi,%edx
801065ed:	01 d0                	add    %edx,%eax
801065ef:	83 ec 04             	sub    $0x4,%esp
801065f2:	53                   	push   %ebx
801065f3:	ff 75 10             	pushl  0x10(%ebp)
801065f6:	50                   	push   %eax
801065f7:	e8 5c d8 ff ff       	call   80103e58 <memmove>
    len -= n;
801065fc:	29 df                	sub    %ebx,%edi
    buf += n;
801065fe:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
80106601:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106607:	89 45 0c             	mov    %eax,0xc(%ebp)
8010660a:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
8010660d:	85 ff                	test   %edi,%edi
8010660f:	74 2f                	je     80106640 <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
80106611:	8b 75 0c             	mov    0xc(%ebp),%esi
80106614:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
8010661a:	83 ec 08             	sub    $0x8,%esp
8010661d:	56                   	push   %esi
8010661e:	ff 75 08             	pushl  0x8(%ebp)
80106621:	e8 7a ff ff ff       	call   801065a0 <uva2ka>
    if(pa0 == 0)
80106626:	83 c4 10             	add    $0x10,%esp
80106629:	85 c0                	test   %eax,%eax
8010662b:	74 20                	je     8010664d <copyout+0x73>
    n = PGSIZE - (va - va0);
8010662d:	89 f3                	mov    %esi,%ebx
8010662f:	2b 5d 0c             	sub    0xc(%ebp),%ebx
80106632:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106638:	39 df                	cmp    %ebx,%edi
8010663a:	73 ac                	jae    801065e8 <copyout+0xe>
      n = len;
8010663c:	89 fb                	mov    %edi,%ebx
8010663e:	eb a8                	jmp    801065e8 <copyout+0xe>
  }
  return 0;
80106640:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106645:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106648:	5b                   	pop    %ebx
80106649:	5e                   	pop    %esi
8010664a:	5f                   	pop    %edi
8010664b:	5d                   	pop    %ebp
8010664c:	c3                   	ret    
      return -1;
8010664d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106652:	eb f1                	jmp    80106645 <copyout+0x6b>
