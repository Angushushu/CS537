
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
8010002d:	b8 2e 2c 10 80       	mov    $0x80102c2e,%eax
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
80100046:	e8 14 3d 00 00       	call   80103d5f <acquire>

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
8010007c:	e8 43 3d 00 00       	call   80103dc4 <release>
      acquiresleep(&b->lock);
80100081:	8d 43 0c             	lea    0xc(%ebx),%eax
80100084:	89 04 24             	mov    %eax,(%esp)
80100087:	e8 bf 3a 00 00       	call   80103b4b <acquiresleep>
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
801000ca:	e8 f5 3c 00 00       	call   80103dc4 <release>
      acquiresleep(&b->lock);
801000cf:	8d 43 0c             	lea    0xc(%ebx),%eax
801000d2:	89 04 24             	mov    %eax,(%esp)
801000d5:	e8 71 3a 00 00       	call   80103b4b <acquiresleep>
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
80100100:	68 e0 b5 10 80       	push   $0x8010b5e0
80100105:	e8 19 3b 00 00       	call   80103c23 <initlock>
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
8010013a:	68 78 66 10 80       	push   $0x80106678
8010013f:	8d 43 0c             	lea    0xc(%ebx),%eax
80100142:	50                   	push   %eax
80100143:	e8 d0 39 00 00       	call   80103b18 <initsleeplock>
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
801001a8:	e8 28 3a 00 00       	call   80103bd5 <holdingsleep>
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
801001e4:	e8 ec 39 00 00       	call   80103bd5 <holdingsleep>
801001e9:	83 c4 10             	add    $0x10,%esp
801001ec:	85 c0                	test   %eax,%eax
801001ee:	74 6b                	je     8010025b <brelse+0x86>
    panic("brelse");

  releasesleep(&b->lock);
801001f0:	83 ec 0c             	sub    $0xc,%esp
801001f3:	56                   	push   %esi
801001f4:	e8 a1 39 00 00       	call   80103b9a <releasesleep>

  acquire(&bcache.lock);
801001f9:	c7 04 24 e0 b5 10 80 	movl   $0x8010b5e0,(%esp)
80100200:	e8 5a 3b 00 00       	call   80103d5f <acquire>
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
8010024c:	e8 73 3b 00 00       	call   80103dc4 <release>
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
8010028a:	e8 d0 3a 00 00       	call   80103d5f <acquire>
  while(n > 0){
8010028f:	83 c4 10             	add    $0x10,%esp
80100292:	85 db                	test   %ebx,%ebx
80100294:	0f 8e 8f 00 00 00    	jle    80100329 <consoleread+0xc1>
    while(input.r == input.w){
8010029a:	a1 c0 ff 10 80       	mov    0x8010ffc0,%eax
8010029f:	3b 05 c4 ff 10 80    	cmp    0x8010ffc4,%eax
801002a5:	75 47                	jne    801002ee <consoleread+0x86>
      if(myproc()->killed){
801002a7:	e8 14 31 00 00       	call   801033c0 <myproc>
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
801002bf:	e8 a0 35 00 00       	call   80103864 <sleep>
801002c4:	83 c4 10             	add    $0x10,%esp
801002c7:	eb d1                	jmp    8010029a <consoleread+0x32>
        release(&cons.lock);
801002c9:	83 ec 0c             	sub    $0xc,%esp
801002cc:	68 20 a5 10 80       	push   $0x8010a520
801002d1:	e8 ee 3a 00 00       	call   80103dc4 <release>
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
80100331:	e8 8e 3a 00 00       	call   80103dc4 <release>
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
8010035a:	e8 e9 21 00 00       	call   80102548 <lapicid>
8010035f:	83 ec 08             	sub    $0x8,%esp
80100362:	50                   	push   %eax
80100363:	68 8d 66 10 80       	push   $0x8010668d
80100368:	e8 9e 02 00 00       	call   8010060b <cprintf>
  cprintf(s);
8010036d:	83 c4 04             	add    $0x4,%esp
80100370:	ff 75 08             	pushl  0x8(%ebp)
80100373:	e8 93 02 00 00       	call   8010060b <cprintf>
  cprintf("\n");
80100378:	c7 04 24 bf 70 10 80 	movl   $0x801070bf,(%esp)
8010037f:	e8 87 02 00 00       	call   8010060b <cprintf>
  getcallerpcs(&s, pcs);
80100384:	83 c4 08             	add    $0x8,%esp
80100387:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010038a:	50                   	push   %eax
8010038b:	8d 45 08             	lea    0x8(%ebp),%eax
8010038e:	50                   	push   %eax
8010038f:	e8 aa 38 00 00       	call   80103c3e <getcallerpcs>
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
801004ba:	e8 c7 39 00 00       	call   80103e86 <memmove>
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
801004d9:	e8 2d 39 00 00       	call   80103e0b <memset>
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
80100506:	e8 47 4d 00 00       	call   80105252 <uartputc>
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
8010051f:	e8 2e 4d 00 00       	call   80105252 <uartputc>
80100524:	c7 04 24 20 00 00 00 	movl   $0x20,(%esp)
8010052b:	e8 22 4d 00 00       	call   80105252 <uartputc>
80100530:	c7 04 24 08 00 00 00 	movl   $0x8,(%esp)
80100537:	e8 16 4d 00 00       	call   80105252 <uartputc>
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
801005ca:	e8 90 37 00 00       	call   80103d5f <acquire>
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
801005f1:	e8 ce 37 00 00       	call   80103dc4 <release>
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
80100638:	e8 22 37 00 00       	call   80103d5f <acquire>
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
80100734:	e8 8b 36 00 00       	call   80103dc4 <release>
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
8010074f:	e8 0b 36 00 00       	call   80103d5f <acquire>
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
801007de:	e8 e6 31 00 00       	call   801039c9 <wakeup>
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
80100873:	e8 4c 35 00 00       	call   80103dc4 <release>
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
80100887:	e8 da 31 00 00       	call   80103a66 <procdump>
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
8010089e:	e8 80 33 00 00       	call   80103c23 <initlock>

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
801008de:	e8 dd 2a 00 00       	call   801033c0 <myproc>
801008e3:	89 85 f4 fe ff ff    	mov    %eax,-0x10c(%ebp)

  begin_op();
801008e9:	e8 8a 20 00 00       	call   80102978 <begin_op>

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
80100935:	e8 b8 20 00 00       	call   801029f2 <end_op>
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
8010094a:	e8 a3 20 00 00       	call   801029f2 <end_op>
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
80100972:	e8 9b 5a 00 00       	call   80106412 <setupkvm>
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
80100a06:	e8 ad 58 00 00       	call   801062b8 <allocuvm>
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
80100a38:	e8 49 57 00 00       	call   80106186 <loaduvm>
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
80100a53:	e8 9a 1f 00 00       	call   801029f2 <end_op>
  sz = PGROUNDUP(sz);
80100a58:	8d 87 ff 0f 00 00    	lea    0xfff(%edi),%eax
80100a5e:	25 00 f0 ff ff       	and    $0xfffff000,%eax
  if((sz = allocuvm(pgdir, sz, sz + 2*PGSIZE)) == 0)
80100a63:	83 c4 0c             	add    $0xc,%esp
80100a66:	8d 90 00 20 00 00    	lea    0x2000(%eax),%edx
80100a6c:	52                   	push   %edx
80100a6d:	50                   	push   %eax
80100a6e:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100a74:	e8 3f 58 00 00       	call   801062b8 <allocuvm>
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
80100a9d:	e8 00 59 00 00       	call   801063a2 <freevm>
80100aa2:	83 c4 10             	add    $0x10,%esp
80100aa5:	e9 7a fe ff ff       	jmp    80100924 <exec+0x52>
  clearpteu(pgdir, (char*)(sz - 2*PGSIZE));
80100aaa:	89 c7                	mov    %eax,%edi
80100aac:	8d 80 00 e0 ff ff    	lea    -0x2000(%eax),%eax
80100ab2:	83 ec 08             	sub    $0x8,%esp
80100ab5:	50                   	push   %eax
80100ab6:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100abc:	e8 d6 59 00 00       	call   80106497 <clearpteu>
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
80100ae2:	e8 c6 34 00 00       	call   80103fad <strlen>
80100ae7:	29 c7                	sub    %eax,%edi
80100ae9:	83 ef 01             	sub    $0x1,%edi
80100aec:	83 e7 fc             	and    $0xfffffffc,%edi
    if(copyout(pgdir, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
80100aef:	83 c4 04             	add    $0x4,%esp
80100af2:	ff 36                	pushl  (%esi)
80100af4:	e8 b4 34 00 00       	call   80103fad <strlen>
80100af9:	83 c0 01             	add    $0x1,%eax
80100afc:	50                   	push   %eax
80100afd:	ff 36                	pushl  (%esi)
80100aff:	57                   	push   %edi
80100b00:	ff b5 ec fe ff ff    	pushl  -0x114(%ebp)
80100b06:	e8 da 5a 00 00       	call   801065e5 <copyout>
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
80100b66:	e8 7a 5a 00 00       	call   801065e5 <copyout>
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
80100ba3:	e8 ca 33 00 00       	call   80103f72 <safestrcpy>
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
80100bd1:	e8 2f 54 00 00       	call   80106005 <switchuvm>
  freevm(oldpgdir);
80100bd6:	89 1c 24             	mov    %ebx,(%esp)
80100bd9:	e8 c4 57 00 00       	call   801063a2 <freevm>
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
80100c1e:	68 e0 ff 10 80       	push   $0x8010ffe0
80100c23:	e8 fb 2f 00 00       	call   80103c23 <initlock>
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
80100c39:	e8 21 31 00 00       	call   80103d5f <acquire>
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
80100c68:	e8 57 31 00 00       	call   80103dc4 <release>
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
80100c7f:	e8 40 31 00 00       	call   80103dc4 <release>
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
80100c9d:	e8 bd 30 00 00       	call   80103d5f <acquire>
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
80100cba:	e8 05 31 00 00       	call   80103dc4 <release>
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
80100cdd:	68 e0 ff 10 80       	push   $0x8010ffe0
80100ce2:	e8 78 30 00 00       	call   80103d5f <acquire>
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
80100d03:	e8 bc 30 00 00       	call   80103dc4 <release>
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
80100d44:	68 e0 ff 10 80       	push   $0x8010ffe0
80100d49:	e8 76 30 00 00       	call   80103dc4 <release>
  if(ff.type == FD_PIPE)
80100d4e:	8b 45 e0             	mov    -0x20(%ebp),%eax
80100d51:	83 c4 10             	add    $0x10,%esp
80100d54:	83 f8 01             	cmp    $0x1,%eax
80100d57:	74 1f                	je     80100d78 <fileclose+0xa5>
  else if(ff.type == FD_INODE){
80100d59:	83 f8 02             	cmp    $0x2,%eax
80100d5c:	75 ad                	jne    80100d0b <fileclose+0x38>
    begin_op();
80100d5e:	e8 15 1c 00 00       	call   80102978 <begin_op>
    iput(ff.ip);
80100d63:	83 ec 0c             	sub    $0xc,%esp
80100d66:	ff 75 f0             	pushl  -0x10(%ebp)
80100d69:	e8 1a 09 00 00       	call   80101688 <iput>
    end_op();
80100d6e:	e8 7f 1c 00 00       	call   801029f2 <end_op>
80100d73:	83 c4 10             	add    $0x10,%esp
80100d76:	eb 93                	jmp    80100d0b <fileclose+0x38>
    pipeclose(ff.pipe, ff.writable);
80100d78:	83 ec 08             	sub    $0x8,%esp
80100d7b:	0f be 45 e9          	movsbl -0x17(%ebp),%eax
80100d7f:	50                   	push   %eax
80100d80:	ff 75 ec             	pushl  -0x14(%ebp)
80100d83:	e8 64 22 00 00       	call   80102fec <pipeclose>
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
80100e3c:	e8 03 23 00 00       	call   80103144 <piperead>
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
80100e95:	e8 de 21 00 00       	call   80103078 <pipewrite>
80100e9a:	83 c4 10             	add    $0x10,%esp
80100e9d:	e9 80 00 00 00       	jmp    80100f22 <filewrite+0xc6>
    while(i < n){
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
80100ea2:	e8 d1 1a 00 00       	call   80102978 <begin_op>
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
80100edd:	e8 10 1b 00 00       	call   801029f2 <end_op>

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
80100f8a:	e8 f7 2e 00 00       	call   80103e86 <memmove>
80100f8f:	83 c4 10             	add    $0x10,%esp
80100f92:	eb 17                	jmp    80100fab <skipelem+0x66>
  else {
    memmove(name, s, len);
80100f94:	83 ec 04             	sub    $0x4,%esp
80100f97:	56                   	push   %esi
80100f98:	50                   	push   %eax
80100f99:	57                   	push   %edi
80100f9a:	e8 e7 2e 00 00       	call   80103e86 <memmove>
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
80100fdf:	e8 27 2e 00 00       	call   80103e0b <memset>
  log_write(bp);
80100fe4:	89 1c 24             	mov    %ebx,(%esp)
80100fe7:	e8 b5 1a 00 00       	call   80102aa1 <log_write>
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
801010bf:	e8 dd 19 00 00       	call   80102aa1 <log_write>
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
80101170:	e8 2c 19 00 00       	call   80102aa1 <log_write>
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
80101195:	68 00 0a 11 80       	push   $0x80110a00
8010119a:	e8 c0 2b 00 00       	call   80103d5f <acquire>
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
801011e1:	e8 de 2b 00 00       	call   80103dc4 <release>
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
80101217:	e8 a8 2b 00 00       	call   80103dc4 <release>
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
80101255:	e8 2c 2c 00 00       	call   80103e86 <memmove>
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
801012c8:	e8 d4 17 00 00       	call   80102aa1 <log_write>
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
801012f8:	68 00 0a 11 80       	push   $0x80110a00
801012fd:	e8 21 29 00 00       	call   80103c23 <initlock>
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
8010131c:	05 40 0a 11 80       	add    $0x80110a40,%eax
80101321:	50                   	push   %eax
80101322:	e8 f1 27 00 00       	call   80103b18 <initsleeplock>
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
801013df:	68 78 67 10 80       	push   $0x80106778
801013e4:	e8 5f ef ff ff       	call   80100348 <panic>
      memset(dip, 0, sizeof(*dip));
801013e9:	83 ec 04             	sub    $0x4,%esp
801013ec:	6a 40                	push   $0x40
801013ee:	6a 00                	push   $0x0
801013f0:	57                   	push   %edi
801013f1:	e8 15 2a 00 00       	call   80103e0b <memset>
      dip->type = type;
801013f6:	0f b7 45 e0          	movzwl -0x20(%ebp),%eax
801013fa:	66 89 07             	mov    %ax,(%edi)
      log_write(bp);   // mark it allocated on the disk
801013fd:	89 34 24             	mov    %esi,(%esp)
80101400:	e8 9c 16 00 00       	call   80102aa1 <log_write>
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
80101480:	e8 01 2a 00 00       	call   80103e86 <memmove>
  log_write(bp);
80101485:	89 34 24             	mov    %esi,(%esp)
80101488:	e8 14 16 00 00       	call   80102aa1 <log_write>
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
80101560:	e8 fa 27 00 00       	call   80103d5f <acquire>
  ip->ref++;
80101565:	8b 43 08             	mov    0x8(%ebx),%eax
80101568:	83 c0 01             	add    $0x1,%eax
8010156b:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
8010156e:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
80101575:	e8 4a 28 00 00       	call   80103dc4 <release>
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
8010159a:	e8 ac 25 00 00       	call   80103b4b <acquiresleep>
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
80101614:	e8 6d 28 00 00       	call   80103e86 <memmove>
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
80101656:	e8 7a 25 00 00       	call   80103bd5 <holdingsleep>
8010165b:	83 c4 10             	add    $0x10,%esp
8010165e:	85 c0                	test   %eax,%eax
80101660:	74 19                	je     8010167b <iunlock+0x38>
80101662:	83 7b 08 00          	cmpl   $0x0,0x8(%ebx)
80101666:	7e 13                	jle    8010167b <iunlock+0x38>
  releasesleep(&ip->lock);
80101668:	83 ec 0c             	sub    $0xc,%esp
8010166b:	56                   	push   %esi
8010166c:	e8 29 25 00 00       	call   80103b9a <releasesleep>
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
80101698:	e8 ae 24 00 00       	call   80103b4b <acquiresleep>
  if(ip->valid && ip->nlink == 0){
8010169d:	83 c4 10             	add    $0x10,%esp
801016a0:	83 7b 4c 00          	cmpl   $0x0,0x4c(%ebx)
801016a4:	74 07                	je     801016ad <iput+0x25>
801016a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801016ab:	74 35                	je     801016e2 <iput+0x5a>
  releasesleep(&ip->lock);
801016ad:	83 ec 0c             	sub    $0xc,%esp
801016b0:	56                   	push   %esi
801016b1:	e8 e4 24 00 00       	call   80103b9a <releasesleep>
  acquire(&icache.lock);
801016b6:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801016bd:	e8 9d 26 00 00       	call   80103d5f <acquire>
  ip->ref--;
801016c2:	8b 43 08             	mov    0x8(%ebx),%eax
801016c5:	83 e8 01             	sub    $0x1,%eax
801016c8:	89 43 08             	mov    %eax,0x8(%ebx)
  release(&icache.lock);
801016cb:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801016d2:	e8 ed 26 00 00       	call   80103dc4 <release>
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
801016ea:	e8 70 26 00 00       	call   80103d5f <acquire>
    int r = ip->ref;
801016ef:	8b 7b 08             	mov    0x8(%ebx),%edi
    release(&icache.lock);
801016f2:	c7 04 24 00 0a 11 80 	movl   $0x80110a00,(%esp)
801016f9:	e8 c6 26 00 00       	call   80103dc4 <release>
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
8010182a:	e8 57 26 00 00       	call   80103e86 <memmove>
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
80101926:	e8 5b 25 00 00       	call   80103e86 <memmove>
    log_write(bp);
8010192b:	89 3c 24             	mov    %edi,(%esp)
8010192e:	e8 6e 11 00 00       	call   80102aa1 <log_write>
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
801019a9:	e8 3f 25 00 00       	call   80103eed <strncmp>
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
80101a5a:	e8 61 19 00 00       	call   801033c0 <myproc>
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
80101ba9:	e8 7c 23 00 00       	call   80103f2a <strncpy>
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
80101bd7:	68 94 6e 10 80       	push   $0x80106e94
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
80101d10:	e8 0e 1f 00 00       	call   80103c23 <initlock>
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
80101d80:	e8 da 1f 00 00       	call   80103d5f <acquire>

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
80101dad:	e8 17 1c 00 00       	call   801039c9 <wakeup>

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
80101dcb:	e8 f4 1f 00 00       	call   80103dc4 <release>
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
80101de2:	e8 dd 1f 00 00       	call   80103dc4 <release>
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
80101e1a:	e8 b6 1d 00 00       	call   80103bd5 <holdingsleep>
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
80101e47:	e8 13 1f 00 00       	call   80103d5f <acquire>

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
80101ea9:	e8 b6 19 00 00       	call   80103864 <sleep>
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
80101ec3:	e8 fc 1e 00 00       	call   80103dc4 <release>
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
80101fd6:	e8 30 1e 00 00       	call   80103e0b <memset>
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
80102005:	68 c6 68 10 80       	push   $0x801068c6
8010200a:	e8 39 e3 ff ff       	call   80100348 <panic>
    acquire(&kmem.lock);
8010200f:	83 ec 0c             	sub    $0xc,%esp
80102012:	68 60 26 11 80       	push   $0x80112660
80102017:	e8 43 1d 00 00       	call   80103d5f <acquire>
8010201c:	83 c4 10             	add    $0x10,%esp
8010201f:	eb c6                	jmp    80101fe7 <kfree+0x43>
    release(&kmem.lock);
80102021:	83 ec 0c             	sub    $0xc,%esp
80102024:	68 60 26 11 80       	push   $0x80112660
80102029:	e8 96 1d 00 00       	call   80103dc4 <release>
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
8010206f:	68 cc 68 10 80       	push   $0x801068cc
80102074:	68 60 26 11 80       	push   $0x80112660
80102079:	e8 a5 1b 00 00       	call   80103c23 <initlock>
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
801020c8:	56                   	push   %esi
801020c9:	53                   	push   %ebx
  struct run *r;

  if(kmem.use_lock)
801020ca:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
801020d1:	75 35                	jne    80102108 <kalloc+0x43>
    acquire(&kmem.lock);
  //r = kmem.freelist;
  // p5
  if(flagofinit == 1) {
801020d3:	83 3d b4 a5 10 80 01 	cmpl   $0x1,0x8010a5b4
801020da:	74 3e                	je     8010211a <kalloc+0x55>
      firsttime = 0;
    } else {
      r = kmem.freelist->next;
    }
  } else {
    r = kmem.freelist;
801020dc:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
  }
  // p5
  if(r)
801020e2:	85 db                	test   %ebx,%ebx
801020e4:	74 07                	je     801020ed <kalloc+0x28>
    kmem.freelist = r->next;
801020e6:	8b 03                	mov    (%ebx),%eax
801020e8:	a3 98 26 11 80       	mov    %eax,0x80112698
  if(kmem.use_lock)
801020ed:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
801020f4:	75 48                	jne    8010213e <kalloc+0x79>
    release(&kmem.lock);
  
  // p5
  if(flagofinit == 1) {
801020f6:	83 3d b4 a5 10 80 01 	cmpl   $0x1,0x8010a5b4
801020fd:	74 51                	je     80102150 <kalloc+0x8b>
    cprintf("allocuvm: frames[%d] = %x, pids[%d] = %d\n", index, frames[index], index, pids[index]);
    index++;
  }
  // p5
  return (char*)r;
}
801020ff:	89 d8                	mov    %ebx,%eax
80102101:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102104:	5b                   	pop    %ebx
80102105:	5e                   	pop    %esi
80102106:	5d                   	pop    %ebp
80102107:	c3                   	ret    
    acquire(&kmem.lock);
80102108:	83 ec 0c             	sub    $0xc,%esp
8010210b:	68 60 26 11 80       	push   $0x80112660
80102110:	e8 4a 1c 00 00       	call   80103d5f <acquire>
80102115:	83 c4 10             	add    $0x10,%esp
80102118:	eb b9                	jmp    801020d3 <kalloc+0xe>
    if(firsttime == 1) {
8010211a:	83 3d 00 80 10 80 01 	cmpl   $0x1,0x80108000
80102121:	74 09                	je     8010212c <kalloc+0x67>
      r = kmem.freelist->next;
80102123:	a1 98 26 11 80       	mov    0x80112698,%eax
80102128:	8b 18                	mov    (%eax),%ebx
8010212a:	eb b6                	jmp    801020e2 <kalloc+0x1d>
      r = kmem.freelist;
8010212c:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
      firsttime = 0;
80102132:	c7 05 00 80 10 80 00 	movl   $0x0,0x80108000
80102139:	00 00 00 
8010213c:	eb a4                	jmp    801020e2 <kalloc+0x1d>
    release(&kmem.lock);
8010213e:	83 ec 0c             	sub    $0xc,%esp
80102141:	68 60 26 11 80       	push   $0x80112660
80102146:	e8 79 1c 00 00       	call   80103dc4 <release>
8010214b:	83 c4 10             	add    $0x10,%esp
8010214e:	eb a6                	jmp    801020f6 <kalloc+0x31>
    cprintf("kalloc1 return addr w/ %x\n", V2P((char*)r));
80102150:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
80102156:	83 ec 08             	sub    $0x8,%esp
80102159:	56                   	push   %esi
8010215a:	68 d1 68 10 80       	push   $0x801068d1
8010215f:	e8 a7 e4 ff ff       	call   8010060b <cprintf>
    uint pfn = V2P((char*)r) >> 12;
80102164:	c1 ee 0c             	shr    $0xc,%esi
    frames[index] = pfn;
80102167:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
8010216c:	89 34 85 a0 26 11 80 	mov    %esi,-0x7feed960(,%eax,4)
    pids[index] = -2; //myproc()->pid; // can I get pid here?
80102173:	c7 04 85 a0 26 12 80 	movl   $0xfffffffe,-0x7fedd960(,%eax,4)
8010217a:	fe ff ff ff 
    cprintf("allocuvm: frames[%d] = %x, pids[%d] = %d\n", index, frames[index], index, pids[index]);
8010217e:	c7 04 24 fe ff ff ff 	movl   $0xfffffffe,(%esp)
80102185:	50                   	push   %eax
80102186:	56                   	push   %esi
80102187:	50                   	push   %eax
80102188:	68 24 69 10 80       	push   $0x80106924
8010218d:	e8 79 e4 ff ff       	call   8010060b <cprintf>
    index++;
80102192:	83 05 b8 a5 10 80 01 	addl   $0x1,0x8010a5b8
80102199:	83 c4 20             	add    $0x20,%esp
  return (char*)r;
8010219c:	e9 5e ff ff ff       	jmp    801020ff <kalloc+0x3a>

801021a1 <kalloc1>:

// used for p5
char*
kalloc1(int pid)
{
801021a1:	55                   	push   %ebp
801021a2:	89 e5                	mov    %esp,%ebp
801021a4:	56                   	push   %esi
801021a5:	53                   	push   %ebx
  struct run *r;

  if(kmem.use_lock)
801021a6:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
801021ad:	75 7b                	jne    8010222a <kalloc1+0x89>
    acquire(&kmem.lock);
  r = kmem.freelist;
801021af:	8b 1d 98 26 11 80    	mov    0x80112698,%ebx
  if(r) {
801021b5:	85 db                	test   %ebx,%ebx
801021b7:	74 5f                	je     80102218 <kalloc1+0x77>
    kmem.freelist = r->next;
801021b9:	8b 03                	mov    (%ebx),%eax
801021bb:	a3 98 26 11 80       	mov    %eax,0x80112698
    // p5
    cprintf("kalloc1 return addr w/ %x\n", V2P((char*)r));
801021c0:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
801021c6:	83 ec 08             	sub    $0x8,%esp
801021c9:	56                   	push   %esi
801021ca:	68 d1 68 10 80       	push   $0x801068d1
801021cf:	e8 37 e4 ff ff       	call   8010060b <cprintf>
    uint pfn = V2P((char*)r) >> 12;
801021d4:	c1 ee 0c             	shr    $0xc,%esi
    frames[index] = pfn;
801021d7:	a1 b8 a5 10 80       	mov    0x8010a5b8,%eax
801021dc:	89 34 85 a0 26 11 80 	mov    %esi,-0x7feed960(,%eax,4)
    pids[index] = myproc()->pid; // can I get pid here?
801021e3:	e8 d8 11 00 00       	call   801033c0 <myproc>
801021e8:	8b 15 b8 a5 10 80    	mov    0x8010a5b8,%edx
801021ee:	8b 40 10             	mov    0x10(%eax),%eax
801021f1:	89 04 95 a0 26 12 80 	mov    %eax,-0x7fedd960(,%edx,4)
    cprintf("allocuvm: frames[%d] = %x, pids[%d] = %d\n", index, frames[index], index, pids[index]);
801021f8:	89 04 24             	mov    %eax,(%esp)
801021fb:	52                   	push   %edx
801021fc:	ff 34 95 a0 26 11 80 	pushl  -0x7feed960(,%edx,4)
80102203:	52                   	push   %edx
80102204:	68 24 69 10 80       	push   $0x80106924
80102209:	e8 fd e3 ff ff       	call   8010060b <cprintf>
    index++;
8010220e:	83 05 b8 a5 10 80 01 	addl   $0x1,0x8010a5b8
80102215:	83 c4 20             	add    $0x20,%esp
    // p5
  }
  if(kmem.use_lock)
80102218:	83 3d 94 26 11 80 00 	cmpl   $0x0,0x80112694
8010221f:	75 1e                	jne    8010223f <kalloc1+0x9e>
    release(&kmem.lock);
  
  return (char*)r;
}
80102221:	89 d8                	mov    %ebx,%eax
80102223:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102226:	5b                   	pop    %ebx
80102227:	5e                   	pop    %esi
80102228:	5d                   	pop    %ebp
80102229:	c3                   	ret    
    acquire(&kmem.lock);
8010222a:	83 ec 0c             	sub    $0xc,%esp
8010222d:	68 60 26 11 80       	push   $0x80112660
80102232:	e8 28 1b 00 00       	call   80103d5f <acquire>
80102237:	83 c4 10             	add    $0x10,%esp
8010223a:	e9 70 ff ff ff       	jmp    801021af <kalloc1+0xe>
    release(&kmem.lock);
8010223f:	83 ec 0c             	sub    $0xc,%esp
80102242:	68 60 26 11 80       	push   $0x80112660
80102247:	e8 78 1b 00 00       	call   80103dc4 <release>
8010224c:	83 c4 10             	add    $0x10,%esp
  return (char*)r;
8010224f:	eb d0                	jmp    80102221 <kalloc1+0x80>

80102251 <dump_physmem>:

// used for p5
// by sysproc.c
int
dump_physmem(int *uframes, int *upids, int numframes)
{
80102251:	55                   	push   %ebp
80102252:	89 e5                	mov    %esp,%ebp
80102254:	57                   	push   %edi
80102255:	56                   	push   %esi
80102256:	53                   	push   %ebx
80102257:	83 ec 18             	sub    $0x18,%esp
8010225a:	8b 7d 08             	mov    0x8(%ebp),%edi
8010225d:	8b 75 0c             	mov    0xc(%ebp),%esi
  cprintf("dump_physmem in kalloc.c\n");
80102260:	68 ec 68 10 80       	push   $0x801068ec
80102265:	e8 a1 e3 ff ff       	call   8010060b <cprintf>
  for(int i = 0; i < numframes; i++) {
8010226a:	83 c4 10             	add    $0x10,%esp
8010226d:	bb 00 00 00 00       	mov    $0x0,%ebx
80102272:	eb 47                	jmp    801022bb <dump_physmem+0x6a>
    cprintf("  uframes[%d] = frames[%d](%d);\n", i, i, frames[i]);
80102274:	ff 34 9d a0 26 11 80 	pushl  -0x7feed960(,%ebx,4)
8010227b:	53                   	push   %ebx
8010227c:	53                   	push   %ebx
8010227d:	68 50 69 10 80       	push   $0x80106950
80102282:	e8 84 e3 ff ff       	call   8010060b <cprintf>
    cprintf("  upids[%d] = pids[%d](%d);\n", i, i, pids[i]);
80102287:	ff 34 9d a0 26 12 80 	pushl  -0x7fedd960(,%ebx,4)
8010228e:	53                   	push   %ebx
8010228f:	53                   	push   %ebx
80102290:	68 06 69 10 80       	push   $0x80106906
80102295:	e8 71 e3 ff ff       	call   8010060b <cprintf>
    uframes[i] = frames[i];
8010229a:	8d 04 9d 00 00 00 00 	lea    0x0(,%ebx,4),%eax
801022a1:	8b 14 9d a0 26 11 80 	mov    -0x7feed960(,%ebx,4),%edx
801022a8:	89 14 07             	mov    %edx,(%edi,%eax,1)
    upids[i] = pids[i];
801022ab:	8b 14 9d a0 26 12 80 	mov    -0x7fedd960(,%ebx,4),%edx
801022b2:	89 14 06             	mov    %edx,(%esi,%eax,1)
  for(int i = 0; i < numframes; i++) {
801022b5:	83 c3 01             	add    $0x1,%ebx
801022b8:	83 c4 20             	add    $0x20,%esp
801022bb:	3b 5d 10             	cmp    0x10(%ebp),%ebx
801022be:	7c b4                	jl     80102274 <dump_physmem+0x23>
  }
  cprintf("leaving dump_physmem in kalloc.c\n");
801022c0:	83 ec 0c             	sub    $0xc,%esp
801022c3:	68 74 69 10 80       	push   $0x80106974
801022c8:	e8 3e e3 ff ff       	call   8010060b <cprintf>
  return 0;
}
801022cd:	b8 00 00 00 00       	mov    $0x0,%eax
801022d2:	8d 65 f4             	lea    -0xc(%ebp),%esp
801022d5:	5b                   	pop    %ebx
801022d6:	5e                   	pop    %esi
801022d7:	5f                   	pop    %edi
801022d8:	5d                   	pop    %ebp
801022d9:	c3                   	ret    

801022da <kbdgetc>:
#include "defs.h"
#include "kbd.h"

int
kbdgetc(void)
{
801022da:	55                   	push   %ebp
801022db:	89 e5                	mov    %esp,%ebp
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801022dd:	ba 64 00 00 00       	mov    $0x64,%edx
801022e2:	ec                   	in     (%dx),%al
    normalmap, shiftmap, ctlmap, ctlmap
  };
  uint st, data, c;

  st = inb(KBSTATP);
  if((st & KBS_DIB) == 0)
801022e3:	a8 01                	test   $0x1,%al
801022e5:	0f 84 b5 00 00 00    	je     801023a0 <kbdgetc+0xc6>
801022eb:	ba 60 00 00 00       	mov    $0x60,%edx
801022f0:	ec                   	in     (%dx),%al
    return -1;
  data = inb(KBDATAP);
801022f1:	0f b6 d0             	movzbl %al,%edx

  if(data == 0xE0){
801022f4:	81 fa e0 00 00 00    	cmp    $0xe0,%edx
801022fa:	74 5c                	je     80102358 <kbdgetc+0x7e>
    shift |= E0ESC;
    return 0;
  } else if(data & 0x80){
801022fc:	84 c0                	test   %al,%al
801022fe:	78 66                	js     80102366 <kbdgetc+0x8c>
    // Key released
    data = (shift & E0ESC ? data : data & 0x7F);
    shift &= ~(shiftcode[data] | E0ESC);
    return 0;
  } else if(shift & E0ESC){
80102300:	8b 0d bc a5 10 80    	mov    0x8010a5bc,%ecx
80102306:	f6 c1 40             	test   $0x40,%cl
80102309:	74 0f                	je     8010231a <kbdgetc+0x40>
    // Last character was an E0 escape; or with 0x80
    data |= 0x80;
8010230b:	83 c8 80             	or     $0xffffff80,%eax
8010230e:	0f b6 d0             	movzbl %al,%edx
    shift &= ~E0ESC;
80102311:	83 e1 bf             	and    $0xffffffbf,%ecx
80102314:	89 0d bc a5 10 80    	mov    %ecx,0x8010a5bc
  }

  shift |= shiftcode[data];
8010231a:	0f b6 8a c0 6a 10 80 	movzbl -0x7fef9540(%edx),%ecx
80102321:	0b 0d bc a5 10 80    	or     0x8010a5bc,%ecx
  shift ^= togglecode[data];
80102327:	0f b6 82 c0 69 10 80 	movzbl -0x7fef9640(%edx),%eax
8010232e:	31 c1                	xor    %eax,%ecx
80102330:	89 0d bc a5 10 80    	mov    %ecx,0x8010a5bc
  c = charcode[shift & (CTL | SHIFT)][data];
80102336:	89 c8                	mov    %ecx,%eax
80102338:	83 e0 03             	and    $0x3,%eax
8010233b:	8b 04 85 a0 69 10 80 	mov    -0x7fef9660(,%eax,4),%eax
80102342:	0f b6 04 10          	movzbl (%eax,%edx,1),%eax
  if(shift & CAPSLOCK){
80102346:	f6 c1 08             	test   $0x8,%cl
80102349:	74 19                	je     80102364 <kbdgetc+0x8a>
    if('a' <= c && c <= 'z')
8010234b:	8d 50 9f             	lea    -0x61(%eax),%edx
8010234e:	83 fa 19             	cmp    $0x19,%edx
80102351:	77 40                	ja     80102393 <kbdgetc+0xb9>
      c += 'A' - 'a';
80102353:	83 e8 20             	sub    $0x20,%eax
80102356:	eb 0c                	jmp    80102364 <kbdgetc+0x8a>
    shift |= E0ESC;
80102358:	83 0d bc a5 10 80 40 	orl    $0x40,0x8010a5bc
    return 0;
8010235f:	b8 00 00 00 00       	mov    $0x0,%eax
    else if('A' <= c && c <= 'Z')
      c += 'a' - 'A';
  }
  return c;
}
80102364:	5d                   	pop    %ebp
80102365:	c3                   	ret    
    data = (shift & E0ESC ? data : data & 0x7F);
80102366:	8b 0d bc a5 10 80    	mov    0x8010a5bc,%ecx
8010236c:	f6 c1 40             	test   $0x40,%cl
8010236f:	75 05                	jne    80102376 <kbdgetc+0x9c>
80102371:	89 c2                	mov    %eax,%edx
80102373:	83 e2 7f             	and    $0x7f,%edx
    shift &= ~(shiftcode[data] | E0ESC);
80102376:	0f b6 82 c0 6a 10 80 	movzbl -0x7fef9540(%edx),%eax
8010237d:	83 c8 40             	or     $0x40,%eax
80102380:	0f b6 c0             	movzbl %al,%eax
80102383:	f7 d0                	not    %eax
80102385:	21 c8                	and    %ecx,%eax
80102387:	a3 bc a5 10 80       	mov    %eax,0x8010a5bc
    return 0;
8010238c:	b8 00 00 00 00       	mov    $0x0,%eax
80102391:	eb d1                	jmp    80102364 <kbdgetc+0x8a>
    else if('A' <= c && c <= 'Z')
80102393:	8d 50 bf             	lea    -0x41(%eax),%edx
80102396:	83 fa 19             	cmp    $0x19,%edx
80102399:	77 c9                	ja     80102364 <kbdgetc+0x8a>
      c += 'a' - 'A';
8010239b:	83 c0 20             	add    $0x20,%eax
  return c;
8010239e:	eb c4                	jmp    80102364 <kbdgetc+0x8a>
    return -1;
801023a0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801023a5:	eb bd                	jmp    80102364 <kbdgetc+0x8a>

801023a7 <kbdintr>:

void
kbdintr(void)
{
801023a7:	55                   	push   %ebp
801023a8:	89 e5                	mov    %esp,%ebp
801023aa:	83 ec 14             	sub    $0x14,%esp
  consoleintr(kbdgetc);
801023ad:	68 da 22 10 80       	push   $0x801022da
801023b2:	e8 87 e3 ff ff       	call   8010073e <consoleintr>
}
801023b7:	83 c4 10             	add    $0x10,%esp
801023ba:	c9                   	leave  
801023bb:	c3                   	ret    

801023bc <lapicw>:

volatile uint *lapic;  // Initialized in mp.c

static void
lapicw(int index, int value)
{
801023bc:	55                   	push   %ebp
801023bd:	89 e5                	mov    %esp,%ebp
  lapic[index] = value;
801023bf:	8b 0d a0 26 13 80    	mov    0x801326a0,%ecx
801023c5:	8d 04 81             	lea    (%ecx,%eax,4),%eax
801023c8:	89 10                	mov    %edx,(%eax)
  lapic[ID];  // wait for write to finish, by reading
801023ca:	a1 a0 26 13 80       	mov    0x801326a0,%eax
801023cf:	8b 40 20             	mov    0x20(%eax),%eax
}
801023d2:	5d                   	pop    %ebp
801023d3:	c3                   	ret    

801023d4 <cmos_read>:
#define MONTH   0x08
#define YEAR    0x09

static uint
cmos_read(uint reg)
{
801023d4:	55                   	push   %ebp
801023d5:	89 e5                	mov    %esp,%ebp
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
801023d7:	ba 70 00 00 00       	mov    $0x70,%edx
801023dc:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801023dd:	ba 71 00 00 00       	mov    $0x71,%edx
801023e2:	ec                   	in     (%dx),%al
  outb(CMOS_PORT,  reg);
  microdelay(200);

  return inb(CMOS_RETURN);
801023e3:	0f b6 c0             	movzbl %al,%eax
}
801023e6:	5d                   	pop    %ebp
801023e7:	c3                   	ret    

801023e8 <fill_rtcdate>:

static void
fill_rtcdate(struct rtcdate *r)
{
801023e8:	55                   	push   %ebp
801023e9:	89 e5                	mov    %esp,%ebp
801023eb:	53                   	push   %ebx
801023ec:	89 c3                	mov    %eax,%ebx
  r->second = cmos_read(SECS);
801023ee:	b8 00 00 00 00       	mov    $0x0,%eax
801023f3:	e8 dc ff ff ff       	call   801023d4 <cmos_read>
801023f8:	89 03                	mov    %eax,(%ebx)
  r->minute = cmos_read(MINS);
801023fa:	b8 02 00 00 00       	mov    $0x2,%eax
801023ff:	e8 d0 ff ff ff       	call   801023d4 <cmos_read>
80102404:	89 43 04             	mov    %eax,0x4(%ebx)
  r->hour   = cmos_read(HOURS);
80102407:	b8 04 00 00 00       	mov    $0x4,%eax
8010240c:	e8 c3 ff ff ff       	call   801023d4 <cmos_read>
80102411:	89 43 08             	mov    %eax,0x8(%ebx)
  r->day    = cmos_read(DAY);
80102414:	b8 07 00 00 00       	mov    $0x7,%eax
80102419:	e8 b6 ff ff ff       	call   801023d4 <cmos_read>
8010241e:	89 43 0c             	mov    %eax,0xc(%ebx)
  r->month  = cmos_read(MONTH);
80102421:	b8 08 00 00 00       	mov    $0x8,%eax
80102426:	e8 a9 ff ff ff       	call   801023d4 <cmos_read>
8010242b:	89 43 10             	mov    %eax,0x10(%ebx)
  r->year   = cmos_read(YEAR);
8010242e:	b8 09 00 00 00       	mov    $0x9,%eax
80102433:	e8 9c ff ff ff       	call   801023d4 <cmos_read>
80102438:	89 43 14             	mov    %eax,0x14(%ebx)
}
8010243b:	5b                   	pop    %ebx
8010243c:	5d                   	pop    %ebp
8010243d:	c3                   	ret    

8010243e <lapicinit>:
  if(!lapic)
8010243e:	83 3d a0 26 13 80 00 	cmpl   $0x0,0x801326a0
80102445:	0f 84 fb 00 00 00    	je     80102546 <lapicinit+0x108>
{
8010244b:	55                   	push   %ebp
8010244c:	89 e5                	mov    %esp,%ebp
  lapicw(SVR, ENABLE | (T_IRQ0 + IRQ_SPURIOUS));
8010244e:	ba 3f 01 00 00       	mov    $0x13f,%edx
80102453:	b8 3c 00 00 00       	mov    $0x3c,%eax
80102458:	e8 5f ff ff ff       	call   801023bc <lapicw>
  lapicw(TDCR, X1);
8010245d:	ba 0b 00 00 00       	mov    $0xb,%edx
80102462:	b8 f8 00 00 00       	mov    $0xf8,%eax
80102467:	e8 50 ff ff ff       	call   801023bc <lapicw>
  lapicw(TIMER, PERIODIC | (T_IRQ0 + IRQ_TIMER));
8010246c:	ba 20 00 02 00       	mov    $0x20020,%edx
80102471:	b8 c8 00 00 00       	mov    $0xc8,%eax
80102476:	e8 41 ff ff ff       	call   801023bc <lapicw>
  lapicw(TICR, 10000000);
8010247b:	ba 80 96 98 00       	mov    $0x989680,%edx
80102480:	b8 e0 00 00 00       	mov    $0xe0,%eax
80102485:	e8 32 ff ff ff       	call   801023bc <lapicw>
  lapicw(LINT0, MASKED);
8010248a:	ba 00 00 01 00       	mov    $0x10000,%edx
8010248f:	b8 d4 00 00 00       	mov    $0xd4,%eax
80102494:	e8 23 ff ff ff       	call   801023bc <lapicw>
  lapicw(LINT1, MASKED);
80102499:	ba 00 00 01 00       	mov    $0x10000,%edx
8010249e:	b8 d8 00 00 00       	mov    $0xd8,%eax
801024a3:	e8 14 ff ff ff       	call   801023bc <lapicw>
  if(((lapic[VER]>>16) & 0xFF) >= 4)
801024a8:	a1 a0 26 13 80       	mov    0x801326a0,%eax
801024ad:	8b 40 30             	mov    0x30(%eax),%eax
801024b0:	c1 e8 10             	shr    $0x10,%eax
801024b3:	3c 03                	cmp    $0x3,%al
801024b5:	77 7b                	ja     80102532 <lapicinit+0xf4>
  lapicw(ERROR, T_IRQ0 + IRQ_ERROR);
801024b7:	ba 33 00 00 00       	mov    $0x33,%edx
801024bc:	b8 dc 00 00 00       	mov    $0xdc,%eax
801024c1:	e8 f6 fe ff ff       	call   801023bc <lapicw>
  lapicw(ESR, 0);
801024c6:	ba 00 00 00 00       	mov    $0x0,%edx
801024cb:	b8 a0 00 00 00       	mov    $0xa0,%eax
801024d0:	e8 e7 fe ff ff       	call   801023bc <lapicw>
  lapicw(ESR, 0);
801024d5:	ba 00 00 00 00       	mov    $0x0,%edx
801024da:	b8 a0 00 00 00       	mov    $0xa0,%eax
801024df:	e8 d8 fe ff ff       	call   801023bc <lapicw>
  lapicw(EOI, 0);
801024e4:	ba 00 00 00 00       	mov    $0x0,%edx
801024e9:	b8 2c 00 00 00       	mov    $0x2c,%eax
801024ee:	e8 c9 fe ff ff       	call   801023bc <lapicw>
  lapicw(ICRHI, 0);
801024f3:	ba 00 00 00 00       	mov    $0x0,%edx
801024f8:	b8 c4 00 00 00       	mov    $0xc4,%eax
801024fd:	e8 ba fe ff ff       	call   801023bc <lapicw>
  lapicw(ICRLO, BCAST | INIT | LEVEL);
80102502:	ba 00 85 08 00       	mov    $0x88500,%edx
80102507:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010250c:	e8 ab fe ff ff       	call   801023bc <lapicw>
  while(lapic[ICRLO] & DELIVS)
80102511:	a1 a0 26 13 80       	mov    0x801326a0,%eax
80102516:	8b 80 00 03 00 00    	mov    0x300(%eax),%eax
8010251c:	f6 c4 10             	test   $0x10,%ah
8010251f:	75 f0                	jne    80102511 <lapicinit+0xd3>
  lapicw(TPR, 0);
80102521:	ba 00 00 00 00       	mov    $0x0,%edx
80102526:	b8 20 00 00 00       	mov    $0x20,%eax
8010252b:	e8 8c fe ff ff       	call   801023bc <lapicw>
}
80102530:	5d                   	pop    %ebp
80102531:	c3                   	ret    
    lapicw(PCINT, MASKED);
80102532:	ba 00 00 01 00       	mov    $0x10000,%edx
80102537:	b8 d0 00 00 00       	mov    $0xd0,%eax
8010253c:	e8 7b fe ff ff       	call   801023bc <lapicw>
80102541:	e9 71 ff ff ff       	jmp    801024b7 <lapicinit+0x79>
80102546:	f3 c3                	repz ret 

80102548 <lapicid>:
{
80102548:	55                   	push   %ebp
80102549:	89 e5                	mov    %esp,%ebp
  if (!lapic)
8010254b:	a1 a0 26 13 80       	mov    0x801326a0,%eax
80102550:	85 c0                	test   %eax,%eax
80102552:	74 08                	je     8010255c <lapicid+0x14>
  return lapic[ID] >> 24;
80102554:	8b 40 20             	mov    0x20(%eax),%eax
80102557:	c1 e8 18             	shr    $0x18,%eax
}
8010255a:	5d                   	pop    %ebp
8010255b:	c3                   	ret    
    return 0;
8010255c:	b8 00 00 00 00       	mov    $0x0,%eax
80102561:	eb f7                	jmp    8010255a <lapicid+0x12>

80102563 <lapiceoi>:
  if(lapic)
80102563:	83 3d a0 26 13 80 00 	cmpl   $0x0,0x801326a0
8010256a:	74 14                	je     80102580 <lapiceoi+0x1d>
{
8010256c:	55                   	push   %ebp
8010256d:	89 e5                	mov    %esp,%ebp
    lapicw(EOI, 0);
8010256f:	ba 00 00 00 00       	mov    $0x0,%edx
80102574:	b8 2c 00 00 00       	mov    $0x2c,%eax
80102579:	e8 3e fe ff ff       	call   801023bc <lapicw>
}
8010257e:	5d                   	pop    %ebp
8010257f:	c3                   	ret    
80102580:	f3 c3                	repz ret 

80102582 <microdelay>:
{
80102582:	55                   	push   %ebp
80102583:	89 e5                	mov    %esp,%ebp
}
80102585:	5d                   	pop    %ebp
80102586:	c3                   	ret    

80102587 <lapicstartap>:
{
80102587:	55                   	push   %ebp
80102588:	89 e5                	mov    %esp,%ebp
8010258a:	57                   	push   %edi
8010258b:	56                   	push   %esi
8010258c:	53                   	push   %ebx
8010258d:	8b 75 08             	mov    0x8(%ebp),%esi
80102590:	8b 7d 0c             	mov    0xc(%ebp),%edi
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102593:	b8 0f 00 00 00       	mov    $0xf,%eax
80102598:	ba 70 00 00 00       	mov    $0x70,%edx
8010259d:	ee                   	out    %al,(%dx)
8010259e:	b8 0a 00 00 00       	mov    $0xa,%eax
801025a3:	ba 71 00 00 00       	mov    $0x71,%edx
801025a8:	ee                   	out    %al,(%dx)
  wrv[0] = 0;
801025a9:	66 c7 05 67 04 00 80 	movw   $0x0,0x80000467
801025b0:	00 00 
  wrv[1] = addr >> 4;
801025b2:	89 f8                	mov    %edi,%eax
801025b4:	c1 e8 04             	shr    $0x4,%eax
801025b7:	66 a3 69 04 00 80    	mov    %ax,0x80000469
  lapicw(ICRHI, apicid<<24);
801025bd:	c1 e6 18             	shl    $0x18,%esi
801025c0:	89 f2                	mov    %esi,%edx
801025c2:	b8 c4 00 00 00       	mov    $0xc4,%eax
801025c7:	e8 f0 fd ff ff       	call   801023bc <lapicw>
  lapicw(ICRLO, INIT | LEVEL | ASSERT);
801025cc:	ba 00 c5 00 00       	mov    $0xc500,%edx
801025d1:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025d6:	e8 e1 fd ff ff       	call   801023bc <lapicw>
  lapicw(ICRLO, INIT | LEVEL);
801025db:	ba 00 85 00 00       	mov    $0x8500,%edx
801025e0:	b8 c0 00 00 00       	mov    $0xc0,%eax
801025e5:	e8 d2 fd ff ff       	call   801023bc <lapicw>
  for(i = 0; i < 2; i++){
801025ea:	bb 00 00 00 00       	mov    $0x0,%ebx
801025ef:	eb 21                	jmp    80102612 <lapicstartap+0x8b>
    lapicw(ICRHI, apicid<<24);
801025f1:	89 f2                	mov    %esi,%edx
801025f3:	b8 c4 00 00 00       	mov    $0xc4,%eax
801025f8:	e8 bf fd ff ff       	call   801023bc <lapicw>
    lapicw(ICRLO, STARTUP | (addr>>12));
801025fd:	89 fa                	mov    %edi,%edx
801025ff:	c1 ea 0c             	shr    $0xc,%edx
80102602:	80 ce 06             	or     $0x6,%dh
80102605:	b8 c0 00 00 00       	mov    $0xc0,%eax
8010260a:	e8 ad fd ff ff       	call   801023bc <lapicw>
  for(i = 0; i < 2; i++){
8010260f:	83 c3 01             	add    $0x1,%ebx
80102612:	83 fb 01             	cmp    $0x1,%ebx
80102615:	7e da                	jle    801025f1 <lapicstartap+0x6a>
}
80102617:	5b                   	pop    %ebx
80102618:	5e                   	pop    %esi
80102619:	5f                   	pop    %edi
8010261a:	5d                   	pop    %ebp
8010261b:	c3                   	ret    

8010261c <cmostime>:

// qemu seems to use 24-hour GWT and the values are BCD encoded
void
cmostime(struct rtcdate *r)
{
8010261c:	55                   	push   %ebp
8010261d:	89 e5                	mov    %esp,%ebp
8010261f:	57                   	push   %edi
80102620:	56                   	push   %esi
80102621:	53                   	push   %ebx
80102622:	83 ec 3c             	sub    $0x3c,%esp
80102625:	8b 75 08             	mov    0x8(%ebp),%esi
  struct rtcdate t1, t2;
  int sb, bcd;

  sb = cmos_read(CMOS_STATB);
80102628:	b8 0b 00 00 00       	mov    $0xb,%eax
8010262d:	e8 a2 fd ff ff       	call   801023d4 <cmos_read>

  bcd = (sb & (1 << 2)) == 0;
80102632:	83 e0 04             	and    $0x4,%eax
80102635:	89 c7                	mov    %eax,%edi

  // make sure CMOS doesn't modify time while we read it
  for(;;) {
    fill_rtcdate(&t1);
80102637:	8d 45 d0             	lea    -0x30(%ebp),%eax
8010263a:	e8 a9 fd ff ff       	call   801023e8 <fill_rtcdate>
    if(cmos_read(CMOS_STATA) & CMOS_UIP)
8010263f:	b8 0a 00 00 00       	mov    $0xa,%eax
80102644:	e8 8b fd ff ff       	call   801023d4 <cmos_read>
80102649:	a8 80                	test   $0x80,%al
8010264b:	75 ea                	jne    80102637 <cmostime+0x1b>
        continue;
    fill_rtcdate(&t2);
8010264d:	8d 5d b8             	lea    -0x48(%ebp),%ebx
80102650:	89 d8                	mov    %ebx,%eax
80102652:	e8 91 fd ff ff       	call   801023e8 <fill_rtcdate>
    if(memcmp(&t1, &t2, sizeof(t1)) == 0)
80102657:	83 ec 04             	sub    $0x4,%esp
8010265a:	6a 18                	push   $0x18
8010265c:	53                   	push   %ebx
8010265d:	8d 45 d0             	lea    -0x30(%ebp),%eax
80102660:	50                   	push   %eax
80102661:	e8 eb 17 00 00       	call   80103e51 <memcmp>
80102666:	83 c4 10             	add    $0x10,%esp
80102669:	85 c0                	test   %eax,%eax
8010266b:	75 ca                	jne    80102637 <cmostime+0x1b>
      break;
  }

  // convert
  if(bcd) {
8010266d:	85 ff                	test   %edi,%edi
8010266f:	0f 85 84 00 00 00    	jne    801026f9 <cmostime+0xdd>
#define    CONV(x)     (t1.x = ((t1.x >> 4) * 10) + (t1.x & 0xf))
    CONV(second);
80102675:	8b 55 d0             	mov    -0x30(%ebp),%edx
80102678:	89 d0                	mov    %edx,%eax
8010267a:	c1 e8 04             	shr    $0x4,%eax
8010267d:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102680:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102683:	83 e2 0f             	and    $0xf,%edx
80102686:	01 d0                	add    %edx,%eax
80102688:	89 45 d0             	mov    %eax,-0x30(%ebp)
    CONV(minute);
8010268b:	8b 55 d4             	mov    -0x2c(%ebp),%edx
8010268e:	89 d0                	mov    %edx,%eax
80102690:	c1 e8 04             	shr    $0x4,%eax
80102693:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
80102696:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
80102699:	83 e2 0f             	and    $0xf,%edx
8010269c:	01 d0                	add    %edx,%eax
8010269e:	89 45 d4             	mov    %eax,-0x2c(%ebp)
    CONV(hour  );
801026a1:	8b 55 d8             	mov    -0x28(%ebp),%edx
801026a4:	89 d0                	mov    %edx,%eax
801026a6:	c1 e8 04             	shr    $0x4,%eax
801026a9:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026ac:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026af:	83 e2 0f             	and    $0xf,%edx
801026b2:	01 d0                	add    %edx,%eax
801026b4:	89 45 d8             	mov    %eax,-0x28(%ebp)
    CONV(day   );
801026b7:	8b 55 dc             	mov    -0x24(%ebp),%edx
801026ba:	89 d0                	mov    %edx,%eax
801026bc:	c1 e8 04             	shr    $0x4,%eax
801026bf:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026c2:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026c5:	83 e2 0f             	and    $0xf,%edx
801026c8:	01 d0                	add    %edx,%eax
801026ca:	89 45 dc             	mov    %eax,-0x24(%ebp)
    CONV(month );
801026cd:	8b 55 e0             	mov    -0x20(%ebp),%edx
801026d0:	89 d0                	mov    %edx,%eax
801026d2:	c1 e8 04             	shr    $0x4,%eax
801026d5:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026d8:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026db:	83 e2 0f             	and    $0xf,%edx
801026de:	01 d0                	add    %edx,%eax
801026e0:	89 45 e0             	mov    %eax,-0x20(%ebp)
    CONV(year  );
801026e3:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801026e6:	89 d0                	mov    %edx,%eax
801026e8:	c1 e8 04             	shr    $0x4,%eax
801026eb:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801026ee:	8d 04 09             	lea    (%ecx,%ecx,1),%eax
801026f1:	83 e2 0f             	and    $0xf,%edx
801026f4:	01 d0                	add    %edx,%eax
801026f6:	89 45 e4             	mov    %eax,-0x1c(%ebp)
#undef     CONV
  }

  *r = t1;
801026f9:	8b 45 d0             	mov    -0x30(%ebp),%eax
801026fc:	89 06                	mov    %eax,(%esi)
801026fe:	8b 45 d4             	mov    -0x2c(%ebp),%eax
80102701:	89 46 04             	mov    %eax,0x4(%esi)
80102704:	8b 45 d8             	mov    -0x28(%ebp),%eax
80102707:	89 46 08             	mov    %eax,0x8(%esi)
8010270a:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010270d:	89 46 0c             	mov    %eax,0xc(%esi)
80102710:	8b 45 e0             	mov    -0x20(%ebp),%eax
80102713:	89 46 10             	mov    %eax,0x10(%esi)
80102716:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102719:	89 46 14             	mov    %eax,0x14(%esi)
  r->year += 2000;
8010271c:	81 46 14 d0 07 00 00 	addl   $0x7d0,0x14(%esi)
}
80102723:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102726:	5b                   	pop    %ebx
80102727:	5e                   	pop    %esi
80102728:	5f                   	pop    %edi
80102729:	5d                   	pop    %ebp
8010272a:	c3                   	ret    

8010272b <read_head>:
}

// Read the log header from disk into the in-memory log header
static void
read_head(void)
{
8010272b:	55                   	push   %ebp
8010272c:	89 e5                	mov    %esp,%ebp
8010272e:	53                   	push   %ebx
8010272f:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102732:	ff 35 f4 26 13 80    	pushl  0x801326f4
80102738:	ff 35 04 27 13 80    	pushl  0x80132704
8010273e:	e8 29 da ff ff       	call   8010016c <bread>
  struct logheader *lh = (struct logheader *) (buf->data);
  int i;
  log.lh.n = lh->n;
80102743:	8b 58 5c             	mov    0x5c(%eax),%ebx
80102746:	89 1d 08 27 13 80    	mov    %ebx,0x80132708
  for (i = 0; i < log.lh.n; i++) {
8010274c:	83 c4 10             	add    $0x10,%esp
8010274f:	ba 00 00 00 00       	mov    $0x0,%edx
80102754:	eb 0e                	jmp    80102764 <read_head+0x39>
    log.lh.block[i] = lh->block[i];
80102756:	8b 4c 90 60          	mov    0x60(%eax,%edx,4),%ecx
8010275a:	89 0c 95 0c 27 13 80 	mov    %ecx,-0x7fecd8f4(,%edx,4)
  for (i = 0; i < log.lh.n; i++) {
80102761:	83 c2 01             	add    $0x1,%edx
80102764:	39 d3                	cmp    %edx,%ebx
80102766:	7f ee                	jg     80102756 <read_head+0x2b>
  }
  brelse(buf);
80102768:	83 ec 0c             	sub    $0xc,%esp
8010276b:	50                   	push   %eax
8010276c:	e8 64 da ff ff       	call   801001d5 <brelse>
}
80102771:	83 c4 10             	add    $0x10,%esp
80102774:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102777:	c9                   	leave  
80102778:	c3                   	ret    

80102779 <install_trans>:
{
80102779:	55                   	push   %ebp
8010277a:	89 e5                	mov    %esp,%ebp
8010277c:	57                   	push   %edi
8010277d:	56                   	push   %esi
8010277e:	53                   	push   %ebx
8010277f:	83 ec 0c             	sub    $0xc,%esp
  for (tail = 0; tail < log.lh.n; tail++) {
80102782:	bb 00 00 00 00       	mov    $0x0,%ebx
80102787:	eb 66                	jmp    801027ef <install_trans+0x76>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
80102789:	89 d8                	mov    %ebx,%eax
8010278b:	03 05 f4 26 13 80    	add    0x801326f4,%eax
80102791:	83 c0 01             	add    $0x1,%eax
80102794:	83 ec 08             	sub    $0x8,%esp
80102797:	50                   	push   %eax
80102798:	ff 35 04 27 13 80    	pushl  0x80132704
8010279e:	e8 c9 d9 ff ff       	call   8010016c <bread>
801027a3:	89 c7                	mov    %eax,%edi
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
801027a5:	83 c4 08             	add    $0x8,%esp
801027a8:	ff 34 9d 0c 27 13 80 	pushl  -0x7fecd8f4(,%ebx,4)
801027af:	ff 35 04 27 13 80    	pushl  0x80132704
801027b5:	e8 b2 d9 ff ff       	call   8010016c <bread>
801027ba:	89 c6                	mov    %eax,%esi
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
801027bc:	8d 57 5c             	lea    0x5c(%edi),%edx
801027bf:	8d 40 5c             	lea    0x5c(%eax),%eax
801027c2:	83 c4 0c             	add    $0xc,%esp
801027c5:	68 00 02 00 00       	push   $0x200
801027ca:	52                   	push   %edx
801027cb:	50                   	push   %eax
801027cc:	e8 b5 16 00 00       	call   80103e86 <memmove>
    bwrite(dbuf);  // write dst to disk
801027d1:	89 34 24             	mov    %esi,(%esp)
801027d4:	e8 c1 d9 ff ff       	call   8010019a <bwrite>
    brelse(lbuf);
801027d9:	89 3c 24             	mov    %edi,(%esp)
801027dc:	e8 f4 d9 ff ff       	call   801001d5 <brelse>
    brelse(dbuf);
801027e1:	89 34 24             	mov    %esi,(%esp)
801027e4:	e8 ec d9 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801027e9:	83 c3 01             	add    $0x1,%ebx
801027ec:	83 c4 10             	add    $0x10,%esp
801027ef:	39 1d 08 27 13 80    	cmp    %ebx,0x80132708
801027f5:	7f 92                	jg     80102789 <install_trans+0x10>
}
801027f7:	8d 65 f4             	lea    -0xc(%ebp),%esp
801027fa:	5b                   	pop    %ebx
801027fb:	5e                   	pop    %esi
801027fc:	5f                   	pop    %edi
801027fd:	5d                   	pop    %ebp
801027fe:	c3                   	ret    

801027ff <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
801027ff:	55                   	push   %ebp
80102800:	89 e5                	mov    %esp,%ebp
80102802:	53                   	push   %ebx
80102803:	83 ec 0c             	sub    $0xc,%esp
  struct buf *buf = bread(log.dev, log.start);
80102806:	ff 35 f4 26 13 80    	pushl  0x801326f4
8010280c:	ff 35 04 27 13 80    	pushl  0x80132704
80102812:	e8 55 d9 ff ff       	call   8010016c <bread>
80102817:	89 c3                	mov    %eax,%ebx
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
80102819:	8b 0d 08 27 13 80    	mov    0x80132708,%ecx
8010281f:	89 48 5c             	mov    %ecx,0x5c(%eax)
  for (i = 0; i < log.lh.n; i++) {
80102822:	83 c4 10             	add    $0x10,%esp
80102825:	b8 00 00 00 00       	mov    $0x0,%eax
8010282a:	eb 0e                	jmp    8010283a <write_head+0x3b>
    hb->block[i] = log.lh.block[i];
8010282c:	8b 14 85 0c 27 13 80 	mov    -0x7fecd8f4(,%eax,4),%edx
80102833:	89 54 83 60          	mov    %edx,0x60(%ebx,%eax,4)
  for (i = 0; i < log.lh.n; i++) {
80102837:	83 c0 01             	add    $0x1,%eax
8010283a:	39 c1                	cmp    %eax,%ecx
8010283c:	7f ee                	jg     8010282c <write_head+0x2d>
  }
  bwrite(buf);
8010283e:	83 ec 0c             	sub    $0xc,%esp
80102841:	53                   	push   %ebx
80102842:	e8 53 d9 ff ff       	call   8010019a <bwrite>
  brelse(buf);
80102847:	89 1c 24             	mov    %ebx,(%esp)
8010284a:	e8 86 d9 ff ff       	call   801001d5 <brelse>
}
8010284f:	83 c4 10             	add    $0x10,%esp
80102852:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102855:	c9                   	leave  
80102856:	c3                   	ret    

80102857 <recover_from_log>:

static void
recover_from_log(void)
{
80102857:	55                   	push   %ebp
80102858:	89 e5                	mov    %esp,%ebp
8010285a:	83 ec 08             	sub    $0x8,%esp
  read_head();
8010285d:	e8 c9 fe ff ff       	call   8010272b <read_head>
  install_trans(); // if committed, copy from log to disk
80102862:	e8 12 ff ff ff       	call   80102779 <install_trans>
  log.lh.n = 0;
80102867:	c7 05 08 27 13 80 00 	movl   $0x0,0x80132708
8010286e:	00 00 00 
  write_head(); // clear the log
80102871:	e8 89 ff ff ff       	call   801027ff <write_head>
}
80102876:	c9                   	leave  
80102877:	c3                   	ret    

80102878 <write_log>:
}

// Copy modified blocks from cache to log.
static void
write_log(void)
{
80102878:	55                   	push   %ebp
80102879:	89 e5                	mov    %esp,%ebp
8010287b:	57                   	push   %edi
8010287c:	56                   	push   %esi
8010287d:	53                   	push   %ebx
8010287e:	83 ec 0c             	sub    $0xc,%esp
  int tail;

  for (tail = 0; tail < log.lh.n; tail++) {
80102881:	bb 00 00 00 00       	mov    $0x0,%ebx
80102886:	eb 66                	jmp    801028ee <write_log+0x76>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
80102888:	89 d8                	mov    %ebx,%eax
8010288a:	03 05 f4 26 13 80    	add    0x801326f4,%eax
80102890:	83 c0 01             	add    $0x1,%eax
80102893:	83 ec 08             	sub    $0x8,%esp
80102896:	50                   	push   %eax
80102897:	ff 35 04 27 13 80    	pushl  0x80132704
8010289d:	e8 ca d8 ff ff       	call   8010016c <bread>
801028a2:	89 c6                	mov    %eax,%esi
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
801028a4:	83 c4 08             	add    $0x8,%esp
801028a7:	ff 34 9d 0c 27 13 80 	pushl  -0x7fecd8f4(,%ebx,4)
801028ae:	ff 35 04 27 13 80    	pushl  0x80132704
801028b4:	e8 b3 d8 ff ff       	call   8010016c <bread>
801028b9:	89 c7                	mov    %eax,%edi
    memmove(to->data, from->data, BSIZE);
801028bb:	8d 50 5c             	lea    0x5c(%eax),%edx
801028be:	8d 46 5c             	lea    0x5c(%esi),%eax
801028c1:	83 c4 0c             	add    $0xc,%esp
801028c4:	68 00 02 00 00       	push   $0x200
801028c9:	52                   	push   %edx
801028ca:	50                   	push   %eax
801028cb:	e8 b6 15 00 00       	call   80103e86 <memmove>
    bwrite(to);  // write the log
801028d0:	89 34 24             	mov    %esi,(%esp)
801028d3:	e8 c2 d8 ff ff       	call   8010019a <bwrite>
    brelse(from);
801028d8:	89 3c 24             	mov    %edi,(%esp)
801028db:	e8 f5 d8 ff ff       	call   801001d5 <brelse>
    brelse(to);
801028e0:	89 34 24             	mov    %esi,(%esp)
801028e3:	e8 ed d8 ff ff       	call   801001d5 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
801028e8:	83 c3 01             	add    $0x1,%ebx
801028eb:	83 c4 10             	add    $0x10,%esp
801028ee:	39 1d 08 27 13 80    	cmp    %ebx,0x80132708
801028f4:	7f 92                	jg     80102888 <write_log+0x10>
  }
}
801028f6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801028f9:	5b                   	pop    %ebx
801028fa:	5e                   	pop    %esi
801028fb:	5f                   	pop    %edi
801028fc:	5d                   	pop    %ebp
801028fd:	c3                   	ret    

801028fe <commit>:

static void
commit()
{
  if (log.lh.n > 0) {
801028fe:	83 3d 08 27 13 80 00 	cmpl   $0x0,0x80132708
80102905:	7e 26                	jle    8010292d <commit+0x2f>
{
80102907:	55                   	push   %ebp
80102908:	89 e5                	mov    %esp,%ebp
8010290a:	83 ec 08             	sub    $0x8,%esp
    write_log();     // Write modified blocks from cache to log
8010290d:	e8 66 ff ff ff       	call   80102878 <write_log>
    write_head();    // Write header to disk -- the real commit
80102912:	e8 e8 fe ff ff       	call   801027ff <write_head>
    install_trans(); // Now install writes to home locations
80102917:	e8 5d fe ff ff       	call   80102779 <install_trans>
    log.lh.n = 0;
8010291c:	c7 05 08 27 13 80 00 	movl   $0x0,0x80132708
80102923:	00 00 00 
    write_head();    // Erase the transaction from the log
80102926:	e8 d4 fe ff ff       	call   801027ff <write_head>
  }
}
8010292b:	c9                   	leave  
8010292c:	c3                   	ret    
8010292d:	f3 c3                	repz ret 

8010292f <initlog>:
{
8010292f:	55                   	push   %ebp
80102930:	89 e5                	mov    %esp,%ebp
80102932:	53                   	push   %ebx
80102933:	83 ec 2c             	sub    $0x2c,%esp
80102936:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&log.lock, "log");
80102939:	68 c0 6b 10 80       	push   $0x80106bc0
8010293e:	68 c0 26 13 80       	push   $0x801326c0
80102943:	e8 db 12 00 00       	call   80103c23 <initlock>
  readsb(dev, &sb);
80102948:	83 c4 08             	add    $0x8,%esp
8010294b:	8d 45 dc             	lea    -0x24(%ebp),%eax
8010294e:	50                   	push   %eax
8010294f:	53                   	push   %ebx
80102950:	e8 e1 e8 ff ff       	call   80101236 <readsb>
  log.start = sb.logstart;
80102955:	8b 45 ec             	mov    -0x14(%ebp),%eax
80102958:	a3 f4 26 13 80       	mov    %eax,0x801326f4
  log.size = sb.nlog;
8010295d:	8b 45 e8             	mov    -0x18(%ebp),%eax
80102960:	a3 f8 26 13 80       	mov    %eax,0x801326f8
  log.dev = dev;
80102965:	89 1d 04 27 13 80    	mov    %ebx,0x80132704
  recover_from_log();
8010296b:	e8 e7 fe ff ff       	call   80102857 <recover_from_log>
}
80102970:	83 c4 10             	add    $0x10,%esp
80102973:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102976:	c9                   	leave  
80102977:	c3                   	ret    

80102978 <begin_op>:
{
80102978:	55                   	push   %ebp
80102979:	89 e5                	mov    %esp,%ebp
8010297b:	83 ec 14             	sub    $0x14,%esp
  acquire(&log.lock);
8010297e:	68 c0 26 13 80       	push   $0x801326c0
80102983:	e8 d7 13 00 00       	call   80103d5f <acquire>
80102988:	83 c4 10             	add    $0x10,%esp
8010298b:	eb 15                	jmp    801029a2 <begin_op+0x2a>
      sleep(&log, &log.lock);
8010298d:	83 ec 08             	sub    $0x8,%esp
80102990:	68 c0 26 13 80       	push   $0x801326c0
80102995:	68 c0 26 13 80       	push   $0x801326c0
8010299a:	e8 c5 0e 00 00       	call   80103864 <sleep>
8010299f:	83 c4 10             	add    $0x10,%esp
    if(log.committing){
801029a2:	83 3d 00 27 13 80 00 	cmpl   $0x0,0x80132700
801029a9:	75 e2                	jne    8010298d <begin_op+0x15>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
801029ab:	a1 fc 26 13 80       	mov    0x801326fc,%eax
801029b0:	83 c0 01             	add    $0x1,%eax
801029b3:	8d 0c 80             	lea    (%eax,%eax,4),%ecx
801029b6:	8d 14 09             	lea    (%ecx,%ecx,1),%edx
801029b9:	03 15 08 27 13 80    	add    0x80132708,%edx
801029bf:	83 fa 1e             	cmp    $0x1e,%edx
801029c2:	7e 17                	jle    801029db <begin_op+0x63>
      sleep(&log, &log.lock);
801029c4:	83 ec 08             	sub    $0x8,%esp
801029c7:	68 c0 26 13 80       	push   $0x801326c0
801029cc:	68 c0 26 13 80       	push   $0x801326c0
801029d1:	e8 8e 0e 00 00       	call   80103864 <sleep>
801029d6:	83 c4 10             	add    $0x10,%esp
801029d9:	eb c7                	jmp    801029a2 <begin_op+0x2a>
      log.outstanding += 1;
801029db:	a3 fc 26 13 80       	mov    %eax,0x801326fc
      release(&log.lock);
801029e0:	83 ec 0c             	sub    $0xc,%esp
801029e3:	68 c0 26 13 80       	push   $0x801326c0
801029e8:	e8 d7 13 00 00       	call   80103dc4 <release>
}
801029ed:	83 c4 10             	add    $0x10,%esp
801029f0:	c9                   	leave  
801029f1:	c3                   	ret    

801029f2 <end_op>:
{
801029f2:	55                   	push   %ebp
801029f3:	89 e5                	mov    %esp,%ebp
801029f5:	53                   	push   %ebx
801029f6:	83 ec 10             	sub    $0x10,%esp
  acquire(&log.lock);
801029f9:	68 c0 26 13 80       	push   $0x801326c0
801029fe:	e8 5c 13 00 00       	call   80103d5f <acquire>
  log.outstanding -= 1;
80102a03:	a1 fc 26 13 80       	mov    0x801326fc,%eax
80102a08:	83 e8 01             	sub    $0x1,%eax
80102a0b:	a3 fc 26 13 80       	mov    %eax,0x801326fc
  if(log.committing)
80102a10:	8b 1d 00 27 13 80    	mov    0x80132700,%ebx
80102a16:	83 c4 10             	add    $0x10,%esp
80102a19:	85 db                	test   %ebx,%ebx
80102a1b:	75 2c                	jne    80102a49 <end_op+0x57>
  if(log.outstanding == 0){
80102a1d:	85 c0                	test   %eax,%eax
80102a1f:	75 35                	jne    80102a56 <end_op+0x64>
    log.committing = 1;
80102a21:	c7 05 00 27 13 80 01 	movl   $0x1,0x80132700
80102a28:	00 00 00 
    do_commit = 1;
80102a2b:	bb 01 00 00 00       	mov    $0x1,%ebx
  release(&log.lock);
80102a30:	83 ec 0c             	sub    $0xc,%esp
80102a33:	68 c0 26 13 80       	push   $0x801326c0
80102a38:	e8 87 13 00 00       	call   80103dc4 <release>
  if(do_commit){
80102a3d:	83 c4 10             	add    $0x10,%esp
80102a40:	85 db                	test   %ebx,%ebx
80102a42:	75 24                	jne    80102a68 <end_op+0x76>
}
80102a44:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102a47:	c9                   	leave  
80102a48:	c3                   	ret    
    panic("log.committing");
80102a49:	83 ec 0c             	sub    $0xc,%esp
80102a4c:	68 c4 6b 10 80       	push   $0x80106bc4
80102a51:	e8 f2 d8 ff ff       	call   80100348 <panic>
    wakeup(&log);
80102a56:	83 ec 0c             	sub    $0xc,%esp
80102a59:	68 c0 26 13 80       	push   $0x801326c0
80102a5e:	e8 66 0f 00 00       	call   801039c9 <wakeup>
80102a63:	83 c4 10             	add    $0x10,%esp
80102a66:	eb c8                	jmp    80102a30 <end_op+0x3e>
    commit();
80102a68:	e8 91 fe ff ff       	call   801028fe <commit>
    acquire(&log.lock);
80102a6d:	83 ec 0c             	sub    $0xc,%esp
80102a70:	68 c0 26 13 80       	push   $0x801326c0
80102a75:	e8 e5 12 00 00       	call   80103d5f <acquire>
    log.committing = 0;
80102a7a:	c7 05 00 27 13 80 00 	movl   $0x0,0x80132700
80102a81:	00 00 00 
    wakeup(&log);
80102a84:	c7 04 24 c0 26 13 80 	movl   $0x801326c0,(%esp)
80102a8b:	e8 39 0f 00 00       	call   801039c9 <wakeup>
    release(&log.lock);
80102a90:	c7 04 24 c0 26 13 80 	movl   $0x801326c0,(%esp)
80102a97:	e8 28 13 00 00       	call   80103dc4 <release>
80102a9c:	83 c4 10             	add    $0x10,%esp
}
80102a9f:	eb a3                	jmp    80102a44 <end_op+0x52>

80102aa1 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
80102aa1:	55                   	push   %ebp
80102aa2:	89 e5                	mov    %esp,%ebp
80102aa4:	53                   	push   %ebx
80102aa5:	83 ec 04             	sub    $0x4,%esp
80102aa8:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
80102aab:	8b 15 08 27 13 80    	mov    0x80132708,%edx
80102ab1:	83 fa 1d             	cmp    $0x1d,%edx
80102ab4:	7f 45                	jg     80102afb <log_write+0x5a>
80102ab6:	a1 f8 26 13 80       	mov    0x801326f8,%eax
80102abb:	83 e8 01             	sub    $0x1,%eax
80102abe:	39 c2                	cmp    %eax,%edx
80102ac0:	7d 39                	jge    80102afb <log_write+0x5a>
    panic("too big a transaction");
  if (log.outstanding < 1)
80102ac2:	83 3d fc 26 13 80 00 	cmpl   $0x0,0x801326fc
80102ac9:	7e 3d                	jle    80102b08 <log_write+0x67>
    panic("log_write outside of trans");

  acquire(&log.lock);
80102acb:	83 ec 0c             	sub    $0xc,%esp
80102ace:	68 c0 26 13 80       	push   $0x801326c0
80102ad3:	e8 87 12 00 00       	call   80103d5f <acquire>
  for (i = 0; i < log.lh.n; i++) {
80102ad8:	83 c4 10             	add    $0x10,%esp
80102adb:	b8 00 00 00 00       	mov    $0x0,%eax
80102ae0:	8b 15 08 27 13 80    	mov    0x80132708,%edx
80102ae6:	39 c2                	cmp    %eax,%edx
80102ae8:	7e 2b                	jle    80102b15 <log_write+0x74>
    if (log.lh.block[i] == b->blockno)   // log absorbtion
80102aea:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102aed:	39 0c 85 0c 27 13 80 	cmp    %ecx,-0x7fecd8f4(,%eax,4)
80102af4:	74 1f                	je     80102b15 <log_write+0x74>
  for (i = 0; i < log.lh.n; i++) {
80102af6:	83 c0 01             	add    $0x1,%eax
80102af9:	eb e5                	jmp    80102ae0 <log_write+0x3f>
    panic("too big a transaction");
80102afb:	83 ec 0c             	sub    $0xc,%esp
80102afe:	68 d3 6b 10 80       	push   $0x80106bd3
80102b03:	e8 40 d8 ff ff       	call   80100348 <panic>
    panic("log_write outside of trans");
80102b08:	83 ec 0c             	sub    $0xc,%esp
80102b0b:	68 e9 6b 10 80       	push   $0x80106be9
80102b10:	e8 33 d8 ff ff       	call   80100348 <panic>
      break;
  }
  log.lh.block[i] = b->blockno;
80102b15:	8b 4b 08             	mov    0x8(%ebx),%ecx
80102b18:	89 0c 85 0c 27 13 80 	mov    %ecx,-0x7fecd8f4(,%eax,4)
  if (i == log.lh.n)
80102b1f:	39 c2                	cmp    %eax,%edx
80102b21:	74 18                	je     80102b3b <log_write+0x9a>
    log.lh.n++;
  b->flags |= B_DIRTY; // prevent eviction
80102b23:	83 0b 04             	orl    $0x4,(%ebx)
  release(&log.lock);
80102b26:	83 ec 0c             	sub    $0xc,%esp
80102b29:	68 c0 26 13 80       	push   $0x801326c0
80102b2e:	e8 91 12 00 00       	call   80103dc4 <release>
}
80102b33:	83 c4 10             	add    $0x10,%esp
80102b36:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102b39:	c9                   	leave  
80102b3a:	c3                   	ret    
    log.lh.n++;
80102b3b:	83 c2 01             	add    $0x1,%edx
80102b3e:	89 15 08 27 13 80    	mov    %edx,0x80132708
80102b44:	eb dd                	jmp    80102b23 <log_write+0x82>

80102b46 <startothers>:
pde_t entrypgdir[];  // For entry.S

// Start the non-boot (AP) processors.
static void
startothers(void)
{
80102b46:	55                   	push   %ebp
80102b47:	89 e5                	mov    %esp,%ebp
80102b49:	53                   	push   %ebx
80102b4a:	83 ec 08             	sub    $0x8,%esp

  // Write entry code to unused memory at 0x7000.
  // The linker has placed the image of entryother.S in
  // _binary_entryother_start.
  code = P2V(0x7000);
  memmove(code, _binary_entryother_start, (uint)_binary_entryother_size);
80102b4d:	68 8a 00 00 00       	push   $0x8a
80102b52:	68 8c a4 10 80       	push   $0x8010a48c
80102b57:	68 00 70 00 80       	push   $0x80007000
80102b5c:	e8 25 13 00 00       	call   80103e86 <memmove>

  for(c = cpus; c < cpus+ncpu; c++){
80102b61:	83 c4 10             	add    $0x10,%esp
80102b64:	bb c0 27 13 80       	mov    $0x801327c0,%ebx
80102b69:	eb 06                	jmp    80102b71 <startothers+0x2b>
80102b6b:	81 c3 b0 00 00 00    	add    $0xb0,%ebx
80102b71:	69 05 40 2d 13 80 b0 	imul   $0xb0,0x80132d40,%eax
80102b78:	00 00 00 
80102b7b:	05 c0 27 13 80       	add    $0x801327c0,%eax
80102b80:	39 d8                	cmp    %ebx,%eax
80102b82:	76 4c                	jbe    80102bd0 <startothers+0x8a>
    if(c == mycpu())  // We've started already.
80102b84:	e8 c0 07 00 00       	call   80103349 <mycpu>
80102b89:	39 d8                	cmp    %ebx,%eax
80102b8b:	74 de                	je     80102b6b <startothers+0x25>
      continue;

    // Tell entryother.S what stack to use, where to enter, and what
    // pgdir to use. We cannot use kpgdir yet, because the AP processor
    // is running in low  memory, so we use entrypgdir for the APs too.
    stack = kalloc();
80102b8d:	e8 33 f5 ff ff       	call   801020c5 <kalloc>
    *(void**)(code-4) = stack + KSTACKSIZE;
80102b92:	05 00 10 00 00       	add    $0x1000,%eax
80102b97:	a3 fc 6f 00 80       	mov    %eax,0x80006ffc
    *(void(**)(void))(code-8) = mpenter;
80102b9c:	c7 05 f8 6f 00 80 14 	movl   $0x80102c14,0x80006ff8
80102ba3:	2c 10 80 
    *(int**)(code-12) = (void *) V2P(entrypgdir);
80102ba6:	c7 05 f4 6f 00 80 00 	movl   $0x109000,0x80006ff4
80102bad:	90 10 00 

    lapicstartap(c->apicid, V2P(code));
80102bb0:	83 ec 08             	sub    $0x8,%esp
80102bb3:	68 00 70 00 00       	push   $0x7000
80102bb8:	0f b6 03             	movzbl (%ebx),%eax
80102bbb:	50                   	push   %eax
80102bbc:	e8 c6 f9 ff ff       	call   80102587 <lapicstartap>

    // wait for cpu to finish mpmain()
    while(c->started == 0)
80102bc1:	83 c4 10             	add    $0x10,%esp
80102bc4:	8b 83 a0 00 00 00    	mov    0xa0(%ebx),%eax
80102bca:	85 c0                	test   %eax,%eax
80102bcc:	74 f6                	je     80102bc4 <startothers+0x7e>
80102bce:	eb 9b                	jmp    80102b6b <startothers+0x25>
      ;
  }
}
80102bd0:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80102bd3:	c9                   	leave  
80102bd4:	c3                   	ret    

80102bd5 <mpmain>:
{
80102bd5:	55                   	push   %ebp
80102bd6:	89 e5                	mov    %esp,%ebp
80102bd8:	53                   	push   %ebx
80102bd9:	83 ec 04             	sub    $0x4,%esp
  cprintf("cpu%d: starting %d\n", cpuid(), cpuid());
80102bdc:	e8 c4 07 00 00       	call   801033a5 <cpuid>
80102be1:	89 c3                	mov    %eax,%ebx
80102be3:	e8 bd 07 00 00       	call   801033a5 <cpuid>
80102be8:	83 ec 04             	sub    $0x4,%esp
80102beb:	53                   	push   %ebx
80102bec:	50                   	push   %eax
80102bed:	68 04 6c 10 80       	push   $0x80106c04
80102bf2:	e8 14 da ff ff       	call   8010060b <cprintf>
  idtinit();       // load idt register
80102bf7:	e8 ee 23 00 00       	call   80104fea <idtinit>
  xchg(&(mycpu()->started), 1); // tell startothers() we're up
80102bfc:	e8 48 07 00 00       	call   80103349 <mycpu>
80102c01:	89 c2                	mov    %eax,%edx
xchg(volatile uint *addr, uint newval)
{
  uint result;

  // The + in "+m" denotes a read-modify-write operand.
  asm volatile("lock; xchgl %0, %1" :
80102c03:	b8 01 00 00 00       	mov    $0x1,%eax
80102c08:	f0 87 82 a0 00 00 00 	lock xchg %eax,0xa0(%edx)
  scheduler();     // start running processes
80102c0f:	e8 2b 0a 00 00       	call   8010363f <scheduler>

80102c14 <mpenter>:
{
80102c14:	55                   	push   %ebp
80102c15:	89 e5                	mov    %esp,%ebp
80102c17:	83 ec 08             	sub    $0x8,%esp
  switchkvm();
80102c1a:	e8 d4 33 00 00       	call   80105ff3 <switchkvm>
  seginit();
80102c1f:	e8 83 32 00 00       	call   80105ea7 <seginit>
  lapicinit();
80102c24:	e8 15 f8 ff ff       	call   8010243e <lapicinit>
  mpmain();
80102c29:	e8 a7 ff ff ff       	call   80102bd5 <mpmain>

80102c2e <main>:
{
80102c2e:	8d 4c 24 04          	lea    0x4(%esp),%ecx
80102c32:	83 e4 f0             	and    $0xfffffff0,%esp
80102c35:	ff 71 fc             	pushl  -0x4(%ecx)
80102c38:	55                   	push   %ebp
80102c39:	89 e5                	mov    %esp,%ebp
80102c3b:	51                   	push   %ecx
80102c3c:	83 ec 0c             	sub    $0xc,%esp
  kinit1(end, P2V(4*1024*1024)); // phys page allocator
80102c3f:	68 00 00 40 80       	push   $0x80400000
80102c44:	68 e8 54 13 80       	push   $0x801354e8
80102c49:	e8 1b f4 ff ff       	call   80102069 <kinit1>
  kvmalloc();      // kernel page table
80102c4e:	e8 2d 38 00 00       	call   80106480 <kvmalloc>
  mpinit();        // detect other processors
80102c53:	e8 c9 01 00 00       	call   80102e21 <mpinit>
  lapicinit();     // interrupt controller
80102c58:	e8 e1 f7 ff ff       	call   8010243e <lapicinit>
  seginit();       // segment descriptors
80102c5d:	e8 45 32 00 00       	call   80105ea7 <seginit>
  picinit();       // disable pic
80102c62:	e8 82 02 00 00       	call   80102ee9 <picinit>
  ioapicinit();    // another interrupt controller
80102c67:	e8 8e f2 ff ff       	call   80101efa <ioapicinit>
  consoleinit();   // console hardware
80102c6c:	e8 1d dc ff ff       	call   8010088e <consoleinit>
  uartinit();      // serial port
80102c71:	e8 22 26 00 00       	call   80105298 <uartinit>
  pinit();         // process table
80102c76:	e8 b4 06 00 00       	call   8010332f <pinit>
  tvinit();        // trap vectors
80102c7b:	e8 b9 22 00 00       	call   80104f39 <tvinit>
  binit();         // buffer cache
80102c80:	e8 6f d4 ff ff       	call   801000f4 <binit>
  fileinit();      // file table
80102c85:	e8 89 df ff ff       	call   80100c13 <fileinit>
  ideinit();       // disk 
80102c8a:	e8 71 f0 ff ff       	call   80101d00 <ideinit>
  startothers();   // start other processors
80102c8f:	e8 b2 fe ff ff       	call   80102b46 <startothers>
  kinit2(P2V(4*1024*1024), P2V(PHYSTOP)); // must come after startothers()
80102c94:	83 c4 08             	add    $0x8,%esp
80102c97:	68 00 00 00 8e       	push   $0x8e000000
80102c9c:	68 00 00 40 80       	push   $0x80400000
80102ca1:	e8 f5 f3 ff ff       	call   8010209b <kinit2>
  userinit();      // first user process
80102ca6:	e8 39 07 00 00       	call   801033e4 <userinit>
  mpmain();        // finish this processor's setup
80102cab:	e8 25 ff ff ff       	call   80102bd5 <mpmain>

80102cb0 <sum>:
int ncpu;
uchar ioapicid;

static uchar
sum(uchar *addr, int len)
{
80102cb0:	55                   	push   %ebp
80102cb1:	89 e5                	mov    %esp,%ebp
80102cb3:	56                   	push   %esi
80102cb4:	53                   	push   %ebx
  int i, sum;

  sum = 0;
80102cb5:	bb 00 00 00 00       	mov    $0x0,%ebx
  for(i=0; i<len; i++)
80102cba:	b9 00 00 00 00       	mov    $0x0,%ecx
80102cbf:	eb 09                	jmp    80102cca <sum+0x1a>
    sum += addr[i];
80102cc1:	0f b6 34 08          	movzbl (%eax,%ecx,1),%esi
80102cc5:	01 f3                	add    %esi,%ebx
  for(i=0; i<len; i++)
80102cc7:	83 c1 01             	add    $0x1,%ecx
80102cca:	39 d1                	cmp    %edx,%ecx
80102ccc:	7c f3                	jl     80102cc1 <sum+0x11>
  return sum;
}
80102cce:	89 d8                	mov    %ebx,%eax
80102cd0:	5b                   	pop    %ebx
80102cd1:	5e                   	pop    %esi
80102cd2:	5d                   	pop    %ebp
80102cd3:	c3                   	ret    

80102cd4 <mpsearch1>:

// Look for an MP structure in the len bytes at addr.
static struct mp*
mpsearch1(uint a, int len)
{
80102cd4:	55                   	push   %ebp
80102cd5:	89 e5                	mov    %esp,%ebp
80102cd7:	56                   	push   %esi
80102cd8:	53                   	push   %ebx
  uchar *e, *p, *addr;

  addr = P2V(a);
80102cd9:	8d b0 00 00 00 80    	lea    -0x80000000(%eax),%esi
80102cdf:	89 f3                	mov    %esi,%ebx
  e = addr+len;
80102ce1:	01 d6                	add    %edx,%esi
  for(p = addr; p < e; p += sizeof(struct mp))
80102ce3:	eb 03                	jmp    80102ce8 <mpsearch1+0x14>
80102ce5:	83 c3 10             	add    $0x10,%ebx
80102ce8:	39 f3                	cmp    %esi,%ebx
80102cea:	73 29                	jae    80102d15 <mpsearch1+0x41>
    if(memcmp(p, "_MP_", 4) == 0 && sum(p, sizeof(struct mp)) == 0)
80102cec:	83 ec 04             	sub    $0x4,%esp
80102cef:	6a 04                	push   $0x4
80102cf1:	68 18 6c 10 80       	push   $0x80106c18
80102cf6:	53                   	push   %ebx
80102cf7:	e8 55 11 00 00       	call   80103e51 <memcmp>
80102cfc:	83 c4 10             	add    $0x10,%esp
80102cff:	85 c0                	test   %eax,%eax
80102d01:	75 e2                	jne    80102ce5 <mpsearch1+0x11>
80102d03:	ba 10 00 00 00       	mov    $0x10,%edx
80102d08:	89 d8                	mov    %ebx,%eax
80102d0a:	e8 a1 ff ff ff       	call   80102cb0 <sum>
80102d0f:	84 c0                	test   %al,%al
80102d11:	75 d2                	jne    80102ce5 <mpsearch1+0x11>
80102d13:	eb 05                	jmp    80102d1a <mpsearch1+0x46>
      return (struct mp*)p;
  return 0;
80102d15:	bb 00 00 00 00       	mov    $0x0,%ebx
}
80102d1a:	89 d8                	mov    %ebx,%eax
80102d1c:	8d 65 f8             	lea    -0x8(%ebp),%esp
80102d1f:	5b                   	pop    %ebx
80102d20:	5e                   	pop    %esi
80102d21:	5d                   	pop    %ebp
80102d22:	c3                   	ret    

80102d23 <mpsearch>:
// 1) in the first KB of the EBDA;
// 2) in the last KB of system base memory;
// 3) in the BIOS ROM between 0xE0000 and 0xFFFFF.
static struct mp*
mpsearch(void)
{
80102d23:	55                   	push   %ebp
80102d24:	89 e5                	mov    %esp,%ebp
80102d26:	83 ec 08             	sub    $0x8,%esp
  uchar *bda;
  uint p;
  struct mp *mp;

  bda = (uchar *) P2V(0x400);
  if((p = ((bda[0x0F]<<8)| bda[0x0E]) << 4)){
80102d29:	0f b6 05 0f 04 00 80 	movzbl 0x8000040f,%eax
80102d30:	c1 e0 08             	shl    $0x8,%eax
80102d33:	0f b6 15 0e 04 00 80 	movzbl 0x8000040e,%edx
80102d3a:	09 d0                	or     %edx,%eax
80102d3c:	c1 e0 04             	shl    $0x4,%eax
80102d3f:	85 c0                	test   %eax,%eax
80102d41:	74 1f                	je     80102d62 <mpsearch+0x3f>
    if((mp = mpsearch1(p, 1024)))
80102d43:	ba 00 04 00 00       	mov    $0x400,%edx
80102d48:	e8 87 ff ff ff       	call   80102cd4 <mpsearch1>
80102d4d:	85 c0                	test   %eax,%eax
80102d4f:	75 0f                	jne    80102d60 <mpsearch+0x3d>
  } else {
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
    if((mp = mpsearch1(p-1024, 1024)))
      return mp;
  }
  return mpsearch1(0xF0000, 0x10000);
80102d51:	ba 00 00 01 00       	mov    $0x10000,%edx
80102d56:	b8 00 00 0f 00       	mov    $0xf0000,%eax
80102d5b:	e8 74 ff ff ff       	call   80102cd4 <mpsearch1>
}
80102d60:	c9                   	leave  
80102d61:	c3                   	ret    
    p = ((bda[0x14]<<8)|bda[0x13])*1024;
80102d62:	0f b6 05 14 04 00 80 	movzbl 0x80000414,%eax
80102d69:	c1 e0 08             	shl    $0x8,%eax
80102d6c:	0f b6 15 13 04 00 80 	movzbl 0x80000413,%edx
80102d73:	09 d0                	or     %edx,%eax
80102d75:	c1 e0 0a             	shl    $0xa,%eax
    if((mp = mpsearch1(p-1024, 1024)))
80102d78:	2d 00 04 00 00       	sub    $0x400,%eax
80102d7d:	ba 00 04 00 00       	mov    $0x400,%edx
80102d82:	e8 4d ff ff ff       	call   80102cd4 <mpsearch1>
80102d87:	85 c0                	test   %eax,%eax
80102d89:	75 d5                	jne    80102d60 <mpsearch+0x3d>
80102d8b:	eb c4                	jmp    80102d51 <mpsearch+0x2e>

80102d8d <mpconfig>:
// Check for correct signature, calculate the checksum and,
// if correct, check the version.
// To do: check extended table checksum.
static struct mpconf*
mpconfig(struct mp **pmp)
{
80102d8d:	55                   	push   %ebp
80102d8e:	89 e5                	mov    %esp,%ebp
80102d90:	57                   	push   %edi
80102d91:	56                   	push   %esi
80102d92:	53                   	push   %ebx
80102d93:	83 ec 1c             	sub    $0x1c,%esp
80102d96:	89 45 e4             	mov    %eax,-0x1c(%ebp)
  struct mpconf *conf;
  struct mp *mp;

  if((mp = mpsearch()) == 0 || mp->physaddr == 0)
80102d99:	e8 85 ff ff ff       	call   80102d23 <mpsearch>
80102d9e:	85 c0                	test   %eax,%eax
80102da0:	74 5c                	je     80102dfe <mpconfig+0x71>
80102da2:	89 c7                	mov    %eax,%edi
80102da4:	8b 58 04             	mov    0x4(%eax),%ebx
80102da7:	85 db                	test   %ebx,%ebx
80102da9:	74 5a                	je     80102e05 <mpconfig+0x78>
    return 0;
  conf = (struct mpconf*) P2V((uint) mp->physaddr);
80102dab:	8d b3 00 00 00 80    	lea    -0x80000000(%ebx),%esi
  if(memcmp(conf, "PCMP", 4) != 0)
80102db1:	83 ec 04             	sub    $0x4,%esp
80102db4:	6a 04                	push   $0x4
80102db6:	68 1d 6c 10 80       	push   $0x80106c1d
80102dbb:	56                   	push   %esi
80102dbc:	e8 90 10 00 00       	call   80103e51 <memcmp>
80102dc1:	83 c4 10             	add    $0x10,%esp
80102dc4:	85 c0                	test   %eax,%eax
80102dc6:	75 44                	jne    80102e0c <mpconfig+0x7f>
    return 0;
  if(conf->version != 1 && conf->version != 4)
80102dc8:	0f b6 83 06 00 00 80 	movzbl -0x7ffffffa(%ebx),%eax
80102dcf:	3c 01                	cmp    $0x1,%al
80102dd1:	0f 95 c2             	setne  %dl
80102dd4:	3c 04                	cmp    $0x4,%al
80102dd6:	0f 95 c0             	setne  %al
80102dd9:	84 c2                	test   %al,%dl
80102ddb:	75 36                	jne    80102e13 <mpconfig+0x86>
    return 0;
  if(sum((uchar*)conf, conf->length) != 0)
80102ddd:	0f b7 93 04 00 00 80 	movzwl -0x7ffffffc(%ebx),%edx
80102de4:	89 f0                	mov    %esi,%eax
80102de6:	e8 c5 fe ff ff       	call   80102cb0 <sum>
80102deb:	84 c0                	test   %al,%al
80102ded:	75 2b                	jne    80102e1a <mpconfig+0x8d>
    return 0;
  *pmp = mp;
80102def:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102df2:	89 38                	mov    %edi,(%eax)
  return conf;
}
80102df4:	89 f0                	mov    %esi,%eax
80102df6:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102df9:	5b                   	pop    %ebx
80102dfa:	5e                   	pop    %esi
80102dfb:	5f                   	pop    %edi
80102dfc:	5d                   	pop    %ebp
80102dfd:	c3                   	ret    
    return 0;
80102dfe:	be 00 00 00 00       	mov    $0x0,%esi
80102e03:	eb ef                	jmp    80102df4 <mpconfig+0x67>
80102e05:	be 00 00 00 00       	mov    $0x0,%esi
80102e0a:	eb e8                	jmp    80102df4 <mpconfig+0x67>
    return 0;
80102e0c:	be 00 00 00 00       	mov    $0x0,%esi
80102e11:	eb e1                	jmp    80102df4 <mpconfig+0x67>
    return 0;
80102e13:	be 00 00 00 00       	mov    $0x0,%esi
80102e18:	eb da                	jmp    80102df4 <mpconfig+0x67>
    return 0;
80102e1a:	be 00 00 00 00       	mov    $0x0,%esi
80102e1f:	eb d3                	jmp    80102df4 <mpconfig+0x67>

80102e21 <mpinit>:

void
mpinit(void)
{
80102e21:	55                   	push   %ebp
80102e22:	89 e5                	mov    %esp,%ebp
80102e24:	57                   	push   %edi
80102e25:	56                   	push   %esi
80102e26:	53                   	push   %ebx
80102e27:	83 ec 1c             	sub    $0x1c,%esp
  struct mp *mp;
  struct mpconf *conf;
  struct mpproc *proc;
  struct mpioapic *ioapic;

  if((conf = mpconfig(&mp)) == 0)
80102e2a:	8d 45 e4             	lea    -0x1c(%ebp),%eax
80102e2d:	e8 5b ff ff ff       	call   80102d8d <mpconfig>
80102e32:	85 c0                	test   %eax,%eax
80102e34:	74 19                	je     80102e4f <mpinit+0x2e>
    panic("Expect to run on an SMP");
  ismp = 1;
  lapic = (uint*)conf->lapicaddr;
80102e36:	8b 50 24             	mov    0x24(%eax),%edx
80102e39:	89 15 a0 26 13 80    	mov    %edx,0x801326a0
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e3f:	8d 50 2c             	lea    0x2c(%eax),%edx
80102e42:	0f b7 48 04          	movzwl 0x4(%eax),%ecx
80102e46:	01 c1                	add    %eax,%ecx
  ismp = 1;
80102e48:	bb 01 00 00 00       	mov    $0x1,%ebx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e4d:	eb 34                	jmp    80102e83 <mpinit+0x62>
    panic("Expect to run on an SMP");
80102e4f:	83 ec 0c             	sub    $0xc,%esp
80102e52:	68 22 6c 10 80       	push   $0x80106c22
80102e57:	e8 ec d4 ff ff       	call   80100348 <panic>
    switch(*p){
    case MPPROC:
      proc = (struct mpproc*)p;
      if(ncpu < NCPU) {
80102e5c:	8b 35 40 2d 13 80    	mov    0x80132d40,%esi
80102e62:	83 fe 07             	cmp    $0x7,%esi
80102e65:	7f 19                	jg     80102e80 <mpinit+0x5f>
        cpus[ncpu].apicid = proc->apicid;  // apicid may differ from ncpu
80102e67:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e6b:	69 fe b0 00 00 00    	imul   $0xb0,%esi,%edi
80102e71:	88 87 c0 27 13 80    	mov    %al,-0x7fecd840(%edi)
        ncpu++;
80102e77:	83 c6 01             	add    $0x1,%esi
80102e7a:	89 35 40 2d 13 80    	mov    %esi,0x80132d40
      }
      p += sizeof(struct mpproc);
80102e80:	83 c2 14             	add    $0x14,%edx
  for(p=(uchar*)(conf+1), e=(uchar*)conf+conf->length; p<e; ){
80102e83:	39 ca                	cmp    %ecx,%edx
80102e85:	73 2b                	jae    80102eb2 <mpinit+0x91>
    switch(*p){
80102e87:	0f b6 02             	movzbl (%edx),%eax
80102e8a:	3c 04                	cmp    $0x4,%al
80102e8c:	77 1d                	ja     80102eab <mpinit+0x8a>
80102e8e:	0f b6 c0             	movzbl %al,%eax
80102e91:	ff 24 85 5c 6c 10 80 	jmp    *-0x7fef93a4(,%eax,4)
      continue;
    case MPIOAPIC:
      ioapic = (struct mpioapic*)p;
      ioapicid = ioapic->apicno;
80102e98:	0f b6 42 01          	movzbl 0x1(%edx),%eax
80102e9c:	a2 a0 27 13 80       	mov    %al,0x801327a0
      p += sizeof(struct mpioapic);
80102ea1:	83 c2 08             	add    $0x8,%edx
      continue;
80102ea4:	eb dd                	jmp    80102e83 <mpinit+0x62>
    case MPBUS:
    case MPIOINTR:
    case MPLINTR:
      p += 8;
80102ea6:	83 c2 08             	add    $0x8,%edx
      continue;
80102ea9:	eb d8                	jmp    80102e83 <mpinit+0x62>
    default:
      ismp = 0;
80102eab:	bb 00 00 00 00       	mov    $0x0,%ebx
80102eb0:	eb d1                	jmp    80102e83 <mpinit+0x62>
      break;
    }
  }
  if(!ismp)
80102eb2:	85 db                	test   %ebx,%ebx
80102eb4:	74 26                	je     80102edc <mpinit+0xbb>
    panic("Didn't find a suitable machine");

  if(mp->imcrp){
80102eb6:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80102eb9:	80 78 0c 00          	cmpb   $0x0,0xc(%eax)
80102ebd:	74 15                	je     80102ed4 <mpinit+0xb3>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ebf:	b8 70 00 00 00       	mov    $0x70,%eax
80102ec4:	ba 22 00 00 00       	mov    $0x22,%edx
80102ec9:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
80102eca:	ba 23 00 00 00       	mov    $0x23,%edx
80102ecf:	ec                   	in     (%dx),%al
    // Bochs doesn't support IMCR, so this doesn't run on Bochs.
    // But it would on real hardware.
    outb(0x22, 0x70);   // Select IMCR
    outb(0x23, inb(0x23) | 1);  // Mask external interrupts.
80102ed0:	83 c8 01             	or     $0x1,%eax
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80102ed3:	ee                   	out    %al,(%dx)
  }
}
80102ed4:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102ed7:	5b                   	pop    %ebx
80102ed8:	5e                   	pop    %esi
80102ed9:	5f                   	pop    %edi
80102eda:	5d                   	pop    %ebp
80102edb:	c3                   	ret    
    panic("Didn't find a suitable machine");
80102edc:	83 ec 0c             	sub    $0xc,%esp
80102edf:	68 3c 6c 10 80       	push   $0x80106c3c
80102ee4:	e8 5f d4 ff ff       	call   80100348 <panic>

80102ee9 <picinit>:
#define IO_PIC2         0xA0    // Slave (IRQs 8-15)

// Don't use the 8259A interrupt controllers.  Xv6 assumes SMP hardware.
void
picinit(void)
{
80102ee9:	55                   	push   %ebp
80102eea:	89 e5                	mov    %esp,%ebp
80102eec:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102ef1:	ba 21 00 00 00       	mov    $0x21,%edx
80102ef6:	ee                   	out    %al,(%dx)
80102ef7:	ba a1 00 00 00       	mov    $0xa1,%edx
80102efc:	ee                   	out    %al,(%dx)
  // mask all interrupts
  outb(IO_PIC1+1, 0xFF);
  outb(IO_PIC2+1, 0xFF);
}
80102efd:	5d                   	pop    %ebp
80102efe:	c3                   	ret    

80102eff <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
80102eff:	55                   	push   %ebp
80102f00:	89 e5                	mov    %esp,%ebp
80102f02:	57                   	push   %edi
80102f03:	56                   	push   %esi
80102f04:	53                   	push   %ebx
80102f05:	83 ec 0c             	sub    $0xc,%esp
80102f08:	8b 5d 08             	mov    0x8(%ebp),%ebx
80102f0b:	8b 75 0c             	mov    0xc(%ebp),%esi
  struct pipe *p;

  p = 0;
  *f0 = *f1 = 0;
80102f0e:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
80102f14:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
80102f1a:	e8 0e dd ff ff       	call   80100c2d <filealloc>
80102f1f:	89 03                	mov    %eax,(%ebx)
80102f21:	85 c0                	test   %eax,%eax
80102f23:	74 16                	je     80102f3b <pipealloc+0x3c>
80102f25:	e8 03 dd ff ff       	call   80100c2d <filealloc>
80102f2a:	89 06                	mov    %eax,(%esi)
80102f2c:	85 c0                	test   %eax,%eax
80102f2e:	74 0b                	je     80102f3b <pipealloc+0x3c>
    goto bad;
  if((p = (struct pipe*)kalloc()) == 0)
80102f30:	e8 90 f1 ff ff       	call   801020c5 <kalloc>
80102f35:	89 c7                	mov    %eax,%edi
80102f37:	85 c0                	test   %eax,%eax
80102f39:	75 35                	jne    80102f70 <pipealloc+0x71>
  return 0;

 bad:
  if(p)
    kfree((char*)p);
  if(*f0)
80102f3b:	8b 03                	mov    (%ebx),%eax
80102f3d:	85 c0                	test   %eax,%eax
80102f3f:	74 0c                	je     80102f4d <pipealloc+0x4e>
    fileclose(*f0);
80102f41:	83 ec 0c             	sub    $0xc,%esp
80102f44:	50                   	push   %eax
80102f45:	e8 89 dd ff ff       	call   80100cd3 <fileclose>
80102f4a:	83 c4 10             	add    $0x10,%esp
  if(*f1)
80102f4d:	8b 06                	mov    (%esi),%eax
80102f4f:	85 c0                	test   %eax,%eax
80102f51:	0f 84 8b 00 00 00    	je     80102fe2 <pipealloc+0xe3>
    fileclose(*f1);
80102f57:	83 ec 0c             	sub    $0xc,%esp
80102f5a:	50                   	push   %eax
80102f5b:	e8 73 dd ff ff       	call   80100cd3 <fileclose>
80102f60:	83 c4 10             	add    $0x10,%esp
  return -1;
80102f63:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80102f68:	8d 65 f4             	lea    -0xc(%ebp),%esp
80102f6b:	5b                   	pop    %ebx
80102f6c:	5e                   	pop    %esi
80102f6d:	5f                   	pop    %edi
80102f6e:	5d                   	pop    %ebp
80102f6f:	c3                   	ret    
  p->readopen = 1;
80102f70:	c7 80 3c 02 00 00 01 	movl   $0x1,0x23c(%eax)
80102f77:	00 00 00 
  p->writeopen = 1;
80102f7a:	c7 80 40 02 00 00 01 	movl   $0x1,0x240(%eax)
80102f81:	00 00 00 
  p->nwrite = 0;
80102f84:	c7 80 38 02 00 00 00 	movl   $0x0,0x238(%eax)
80102f8b:	00 00 00 
  p->nread = 0;
80102f8e:	c7 80 34 02 00 00 00 	movl   $0x0,0x234(%eax)
80102f95:	00 00 00 
  initlock(&p->lock, "pipe");
80102f98:	83 ec 08             	sub    $0x8,%esp
80102f9b:	68 70 6c 10 80       	push   $0x80106c70
80102fa0:	50                   	push   %eax
80102fa1:	e8 7d 0c 00 00       	call   80103c23 <initlock>
  (*f0)->type = FD_PIPE;
80102fa6:	8b 03                	mov    (%ebx),%eax
80102fa8:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f0)->readable = 1;
80102fae:	8b 03                	mov    (%ebx),%eax
80102fb0:	c6 40 08 01          	movb   $0x1,0x8(%eax)
  (*f0)->writable = 0;
80102fb4:	8b 03                	mov    (%ebx),%eax
80102fb6:	c6 40 09 00          	movb   $0x0,0x9(%eax)
  (*f0)->pipe = p;
80102fba:	8b 03                	mov    (%ebx),%eax
80102fbc:	89 78 0c             	mov    %edi,0xc(%eax)
  (*f1)->type = FD_PIPE;
80102fbf:	8b 06                	mov    (%esi),%eax
80102fc1:	c7 00 01 00 00 00    	movl   $0x1,(%eax)
  (*f1)->readable = 0;
80102fc7:	8b 06                	mov    (%esi),%eax
80102fc9:	c6 40 08 00          	movb   $0x0,0x8(%eax)
  (*f1)->writable = 1;
80102fcd:	8b 06                	mov    (%esi),%eax
80102fcf:	c6 40 09 01          	movb   $0x1,0x9(%eax)
  (*f1)->pipe = p;
80102fd3:	8b 06                	mov    (%esi),%eax
80102fd5:	89 78 0c             	mov    %edi,0xc(%eax)
  return 0;
80102fd8:	83 c4 10             	add    $0x10,%esp
80102fdb:	b8 00 00 00 00       	mov    $0x0,%eax
80102fe0:	eb 86                	jmp    80102f68 <pipealloc+0x69>
  return -1;
80102fe2:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80102fe7:	e9 7c ff ff ff       	jmp    80102f68 <pipealloc+0x69>

80102fec <pipeclose>:

void
pipeclose(struct pipe *p, int writable)
{
80102fec:	55                   	push   %ebp
80102fed:	89 e5                	mov    %esp,%ebp
80102fef:	53                   	push   %ebx
80102ff0:	83 ec 10             	sub    $0x10,%esp
80102ff3:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&p->lock);
80102ff6:	53                   	push   %ebx
80102ff7:	e8 63 0d 00 00       	call   80103d5f <acquire>
  if(writable){
80102ffc:	83 c4 10             	add    $0x10,%esp
80102fff:	83 7d 0c 00          	cmpl   $0x0,0xc(%ebp)
80103003:	74 3f                	je     80103044 <pipeclose+0x58>
    p->writeopen = 0;
80103005:	c7 83 40 02 00 00 00 	movl   $0x0,0x240(%ebx)
8010300c:	00 00 00 
    wakeup(&p->nread);
8010300f:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103015:	83 ec 0c             	sub    $0xc,%esp
80103018:	50                   	push   %eax
80103019:	e8 ab 09 00 00       	call   801039c9 <wakeup>
8010301e:	83 c4 10             	add    $0x10,%esp
  } else {
    p->readopen = 0;
    wakeup(&p->nwrite);
  }
  if(p->readopen == 0 && p->writeopen == 0){
80103021:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
80103028:	75 09                	jne    80103033 <pipeclose+0x47>
8010302a:	83 bb 40 02 00 00 00 	cmpl   $0x0,0x240(%ebx)
80103031:	74 2f                	je     80103062 <pipeclose+0x76>
    release(&p->lock);
    kfree((char*)p);
  } else
    release(&p->lock);
80103033:	83 ec 0c             	sub    $0xc,%esp
80103036:	53                   	push   %ebx
80103037:	e8 88 0d 00 00       	call   80103dc4 <release>
8010303c:	83 c4 10             	add    $0x10,%esp
}
8010303f:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103042:	c9                   	leave  
80103043:	c3                   	ret    
    p->readopen = 0;
80103044:	c7 83 3c 02 00 00 00 	movl   $0x0,0x23c(%ebx)
8010304b:	00 00 00 
    wakeup(&p->nwrite);
8010304e:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
80103054:	83 ec 0c             	sub    $0xc,%esp
80103057:	50                   	push   %eax
80103058:	e8 6c 09 00 00       	call   801039c9 <wakeup>
8010305d:	83 c4 10             	add    $0x10,%esp
80103060:	eb bf                	jmp    80103021 <pipeclose+0x35>
    release(&p->lock);
80103062:	83 ec 0c             	sub    $0xc,%esp
80103065:	53                   	push   %ebx
80103066:	e8 59 0d 00 00       	call   80103dc4 <release>
    kfree((char*)p);
8010306b:	89 1c 24             	mov    %ebx,(%esp)
8010306e:	e8 31 ef ff ff       	call   80101fa4 <kfree>
80103073:	83 c4 10             	add    $0x10,%esp
80103076:	eb c7                	jmp    8010303f <pipeclose+0x53>

80103078 <pipewrite>:

int
pipewrite(struct pipe *p, char *addr, int n)
{
80103078:	55                   	push   %ebp
80103079:	89 e5                	mov    %esp,%ebp
8010307b:	57                   	push   %edi
8010307c:	56                   	push   %esi
8010307d:	53                   	push   %ebx
8010307e:	83 ec 18             	sub    $0x18,%esp
80103081:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103084:	89 de                	mov    %ebx,%esi
80103086:	53                   	push   %ebx
80103087:	e8 d3 0c 00 00       	call   80103d5f <acquire>
  for(i = 0; i < n; i++){
8010308c:	83 c4 10             	add    $0x10,%esp
8010308f:	bf 00 00 00 00       	mov    $0x0,%edi
80103094:	3b 7d 10             	cmp    0x10(%ebp),%edi
80103097:	0f 8d 88 00 00 00    	jge    80103125 <pipewrite+0xad>
    while(p->nwrite == p->nread + PIPESIZE){  //DOC: pipewrite-full
8010309d:	8b 93 38 02 00 00    	mov    0x238(%ebx),%edx
801030a3:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801030a9:	05 00 02 00 00       	add    $0x200,%eax
801030ae:	39 c2                	cmp    %eax,%edx
801030b0:	75 51                	jne    80103103 <pipewrite+0x8b>
      if(p->readopen == 0 || myproc()->killed){
801030b2:	83 bb 3c 02 00 00 00 	cmpl   $0x0,0x23c(%ebx)
801030b9:	74 2f                	je     801030ea <pipewrite+0x72>
801030bb:	e8 00 03 00 00       	call   801033c0 <myproc>
801030c0:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801030c4:	75 24                	jne    801030ea <pipewrite+0x72>
        release(&p->lock);
        return -1;
      }
      wakeup(&p->nread);
801030c6:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
801030cc:	83 ec 0c             	sub    $0xc,%esp
801030cf:	50                   	push   %eax
801030d0:	e8 f4 08 00 00       	call   801039c9 <wakeup>
      sleep(&p->nwrite, &p->lock);  //DOC: pipewrite-sleep
801030d5:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801030db:	83 c4 08             	add    $0x8,%esp
801030de:	56                   	push   %esi
801030df:	50                   	push   %eax
801030e0:	e8 7f 07 00 00       	call   80103864 <sleep>
801030e5:	83 c4 10             	add    $0x10,%esp
801030e8:	eb b3                	jmp    8010309d <pipewrite+0x25>
        release(&p->lock);
801030ea:	83 ec 0c             	sub    $0xc,%esp
801030ed:	53                   	push   %ebx
801030ee:	e8 d1 0c 00 00       	call   80103dc4 <release>
        return -1;
801030f3:	83 c4 10             	add    $0x10,%esp
801030f6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
  }
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
  release(&p->lock);
  return n;
}
801030fb:	8d 65 f4             	lea    -0xc(%ebp),%esp
801030fe:	5b                   	pop    %ebx
801030ff:	5e                   	pop    %esi
80103100:	5f                   	pop    %edi
80103101:	5d                   	pop    %ebp
80103102:	c3                   	ret    
    p->data[p->nwrite++ % PIPESIZE] = addr[i];
80103103:	8d 42 01             	lea    0x1(%edx),%eax
80103106:	89 83 38 02 00 00    	mov    %eax,0x238(%ebx)
8010310c:	81 e2 ff 01 00 00    	and    $0x1ff,%edx
80103112:	8b 45 0c             	mov    0xc(%ebp),%eax
80103115:	0f b6 04 38          	movzbl (%eax,%edi,1),%eax
80103119:	88 44 13 34          	mov    %al,0x34(%ebx,%edx,1)
  for(i = 0; i < n; i++){
8010311d:	83 c7 01             	add    $0x1,%edi
80103120:	e9 6f ff ff ff       	jmp    80103094 <pipewrite+0x1c>
  wakeup(&p->nread);  //DOC: pipewrite-wakeup1
80103125:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
8010312b:	83 ec 0c             	sub    $0xc,%esp
8010312e:	50                   	push   %eax
8010312f:	e8 95 08 00 00       	call   801039c9 <wakeup>
  release(&p->lock);
80103134:	89 1c 24             	mov    %ebx,(%esp)
80103137:	e8 88 0c 00 00       	call   80103dc4 <release>
  return n;
8010313c:	83 c4 10             	add    $0x10,%esp
8010313f:	8b 45 10             	mov    0x10(%ebp),%eax
80103142:	eb b7                	jmp    801030fb <pipewrite+0x83>

80103144 <piperead>:

int
piperead(struct pipe *p, char *addr, int n)
{
80103144:	55                   	push   %ebp
80103145:	89 e5                	mov    %esp,%ebp
80103147:	57                   	push   %edi
80103148:	56                   	push   %esi
80103149:	53                   	push   %ebx
8010314a:	83 ec 18             	sub    $0x18,%esp
8010314d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int i;

  acquire(&p->lock);
80103150:	89 df                	mov    %ebx,%edi
80103152:	53                   	push   %ebx
80103153:	e8 07 0c 00 00       	call   80103d5f <acquire>
  while(p->nread == p->nwrite && p->writeopen){  //DOC: pipe-empty
80103158:	83 c4 10             	add    $0x10,%esp
8010315b:	8b 83 38 02 00 00    	mov    0x238(%ebx),%eax
80103161:	39 83 34 02 00 00    	cmp    %eax,0x234(%ebx)
80103167:	75 3d                	jne    801031a6 <piperead+0x62>
80103169:	8b b3 40 02 00 00    	mov    0x240(%ebx),%esi
8010316f:	85 f6                	test   %esi,%esi
80103171:	74 38                	je     801031ab <piperead+0x67>
    if(myproc()->killed){
80103173:	e8 48 02 00 00       	call   801033c0 <myproc>
80103178:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010317c:	75 15                	jne    80103193 <piperead+0x4f>
      release(&p->lock);
      return -1;
    }
    sleep(&p->nread, &p->lock); //DOC: piperead-sleep
8010317e:	8d 83 34 02 00 00    	lea    0x234(%ebx),%eax
80103184:	83 ec 08             	sub    $0x8,%esp
80103187:	57                   	push   %edi
80103188:	50                   	push   %eax
80103189:	e8 d6 06 00 00       	call   80103864 <sleep>
8010318e:	83 c4 10             	add    $0x10,%esp
80103191:	eb c8                	jmp    8010315b <piperead+0x17>
      release(&p->lock);
80103193:	83 ec 0c             	sub    $0xc,%esp
80103196:	53                   	push   %ebx
80103197:	e8 28 0c 00 00       	call   80103dc4 <release>
      return -1;
8010319c:	83 c4 10             	add    $0x10,%esp
8010319f:	be ff ff ff ff       	mov    $0xffffffff,%esi
801031a4:	eb 50                	jmp    801031f6 <piperead+0xb2>
801031a6:	be 00 00 00 00       	mov    $0x0,%esi
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801031ab:	3b 75 10             	cmp    0x10(%ebp),%esi
801031ae:	7d 2c                	jge    801031dc <piperead+0x98>
    if(p->nread == p->nwrite)
801031b0:	8b 83 34 02 00 00    	mov    0x234(%ebx),%eax
801031b6:	3b 83 38 02 00 00    	cmp    0x238(%ebx),%eax
801031bc:	74 1e                	je     801031dc <piperead+0x98>
      break;
    addr[i] = p->data[p->nread++ % PIPESIZE];
801031be:	8d 50 01             	lea    0x1(%eax),%edx
801031c1:	89 93 34 02 00 00    	mov    %edx,0x234(%ebx)
801031c7:	25 ff 01 00 00       	and    $0x1ff,%eax
801031cc:	0f b6 44 03 34       	movzbl 0x34(%ebx,%eax,1),%eax
801031d1:	8b 4d 0c             	mov    0xc(%ebp),%ecx
801031d4:	88 04 31             	mov    %al,(%ecx,%esi,1)
  for(i = 0; i < n; i++){  //DOC: piperead-copy
801031d7:	83 c6 01             	add    $0x1,%esi
801031da:	eb cf                	jmp    801031ab <piperead+0x67>
  }
  wakeup(&p->nwrite);  //DOC: piperead-wakeup
801031dc:	8d 83 38 02 00 00    	lea    0x238(%ebx),%eax
801031e2:	83 ec 0c             	sub    $0xc,%esp
801031e5:	50                   	push   %eax
801031e6:	e8 de 07 00 00       	call   801039c9 <wakeup>
  release(&p->lock);
801031eb:	89 1c 24             	mov    %ebx,(%esp)
801031ee:	e8 d1 0b 00 00       	call   80103dc4 <release>
  return i;
801031f3:	83 c4 10             	add    $0x10,%esp
}
801031f6:	89 f0                	mov    %esi,%eax
801031f8:	8d 65 f4             	lea    -0xc(%ebp),%esp
801031fb:	5b                   	pop    %ebx
801031fc:	5e                   	pop    %esi
801031fd:	5f                   	pop    %edi
801031fe:	5d                   	pop    %ebp
801031ff:	c3                   	ret    

80103200 <wakeup1>:

// Wake up all processes sleeping on chan.
// The ptable lock must be held.
static void
wakeup1(void *chan)
{
80103200:	55                   	push   %ebp
80103201:	89 e5                	mov    %esp,%ebp
  struct proc *p;

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103203:	ba 94 2d 13 80       	mov    $0x80132d94,%edx
80103208:	eb 03                	jmp    8010320d <wakeup1+0xd>
8010320a:	83 c2 7c             	add    $0x7c,%edx
8010320d:	81 fa 94 4c 13 80    	cmp    $0x80134c94,%edx
80103213:	73 14                	jae    80103229 <wakeup1+0x29>
    if(p->state == SLEEPING && p->chan == chan)
80103215:	83 7a 0c 02          	cmpl   $0x2,0xc(%edx)
80103219:	75 ef                	jne    8010320a <wakeup1+0xa>
8010321b:	39 42 20             	cmp    %eax,0x20(%edx)
8010321e:	75 ea                	jne    8010320a <wakeup1+0xa>
      p->state = RUNNABLE;
80103220:	c7 42 0c 03 00 00 00 	movl   $0x3,0xc(%edx)
80103227:	eb e1                	jmp    8010320a <wakeup1+0xa>
}
80103229:	5d                   	pop    %ebp
8010322a:	c3                   	ret    

8010322b <allocproc>:
{
8010322b:	55                   	push   %ebp
8010322c:	89 e5                	mov    %esp,%ebp
8010322e:	53                   	push   %ebx
8010322f:	83 ec 10             	sub    $0x10,%esp
  acquire(&ptable.lock);
80103232:	68 60 2d 13 80       	push   $0x80132d60
80103237:	e8 23 0b 00 00       	call   80103d5f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
8010323c:	83 c4 10             	add    $0x10,%esp
8010323f:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
80103244:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
8010324a:	73 0b                	jae    80103257 <allocproc+0x2c>
    if(p->state == UNUSED)
8010324c:	83 7b 0c 00          	cmpl   $0x0,0xc(%ebx)
80103250:	74 1c                	je     8010326e <allocproc+0x43>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++)
80103252:	83 c3 7c             	add    $0x7c,%ebx
80103255:	eb ed                	jmp    80103244 <allocproc+0x19>
  release(&ptable.lock);
80103257:	83 ec 0c             	sub    $0xc,%esp
8010325a:	68 60 2d 13 80       	push   $0x80132d60
8010325f:	e8 60 0b 00 00       	call   80103dc4 <release>
  return 0;
80103264:	83 c4 10             	add    $0x10,%esp
80103267:	bb 00 00 00 00       	mov    $0x0,%ebx
8010326c:	eb 69                	jmp    801032d7 <allocproc+0xac>
  p->state = EMBRYO;
8010326e:	c7 43 0c 01 00 00 00 	movl   $0x1,0xc(%ebx)
  p->pid = nextpid++;
80103275:	a1 04 a0 10 80       	mov    0x8010a004,%eax
8010327a:	8d 50 01             	lea    0x1(%eax),%edx
8010327d:	89 15 04 a0 10 80    	mov    %edx,0x8010a004
80103283:	89 43 10             	mov    %eax,0x10(%ebx)
  release(&ptable.lock);
80103286:	83 ec 0c             	sub    $0xc,%esp
80103289:	68 60 2d 13 80       	push   $0x80132d60
8010328e:	e8 31 0b 00 00       	call   80103dc4 <release>
  if((p->kstack = kalloc()) == 0){
80103293:	e8 2d ee ff ff       	call   801020c5 <kalloc>
80103298:	89 43 08             	mov    %eax,0x8(%ebx)
8010329b:	83 c4 10             	add    $0x10,%esp
8010329e:	85 c0                	test   %eax,%eax
801032a0:	74 3c                	je     801032de <allocproc+0xb3>
  sp -= sizeof *p->tf;
801032a2:	8d 90 b4 0f 00 00    	lea    0xfb4(%eax),%edx
  p->tf = (struct trapframe*)sp;
801032a8:	89 53 18             	mov    %edx,0x18(%ebx)
  *(uint*)sp = (uint)trapret;
801032ab:	c7 80 b0 0f 00 00 2e 	movl   $0x80104f2e,0xfb0(%eax)
801032b2:	4f 10 80 
  sp -= sizeof *p->context;
801032b5:	05 9c 0f 00 00       	add    $0xf9c,%eax
  p->context = (struct context*)sp;
801032ba:	89 43 1c             	mov    %eax,0x1c(%ebx)
  memset(p->context, 0, sizeof *p->context);
801032bd:	83 ec 04             	sub    $0x4,%esp
801032c0:	6a 14                	push   $0x14
801032c2:	6a 00                	push   $0x0
801032c4:	50                   	push   %eax
801032c5:	e8 41 0b 00 00       	call   80103e0b <memset>
  p->context->eip = (uint)forkret;
801032ca:	8b 43 1c             	mov    0x1c(%ebx),%eax
801032cd:	c7 40 10 ec 32 10 80 	movl   $0x801032ec,0x10(%eax)
  return p;
801032d4:	83 c4 10             	add    $0x10,%esp
}
801032d7:	89 d8                	mov    %ebx,%eax
801032d9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801032dc:	c9                   	leave  
801032dd:	c3                   	ret    
    p->state = UNUSED;
801032de:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return 0;
801032e5:	bb 00 00 00 00       	mov    $0x0,%ebx
801032ea:	eb eb                	jmp    801032d7 <allocproc+0xac>

801032ec <forkret>:
{
801032ec:	55                   	push   %ebp
801032ed:	89 e5                	mov    %esp,%ebp
801032ef:	83 ec 14             	sub    $0x14,%esp
  release(&ptable.lock);
801032f2:	68 60 2d 13 80       	push   $0x80132d60
801032f7:	e8 c8 0a 00 00       	call   80103dc4 <release>
  if (first) {
801032fc:	83 c4 10             	add    $0x10,%esp
801032ff:	83 3d 00 a0 10 80 00 	cmpl   $0x0,0x8010a000
80103306:	75 02                	jne    8010330a <forkret+0x1e>
}
80103308:	c9                   	leave  
80103309:	c3                   	ret    
    first = 0;
8010330a:	c7 05 00 a0 10 80 00 	movl   $0x0,0x8010a000
80103311:	00 00 00 
    iinit(ROOTDEV);
80103314:	83 ec 0c             	sub    $0xc,%esp
80103317:	6a 01                	push   $0x1
80103319:	e8 ce df ff ff       	call   801012ec <iinit>
    initlog(ROOTDEV);
8010331e:	c7 04 24 01 00 00 00 	movl   $0x1,(%esp)
80103325:	e8 05 f6 ff ff       	call   8010292f <initlog>
8010332a:	83 c4 10             	add    $0x10,%esp
}
8010332d:	eb d9                	jmp    80103308 <forkret+0x1c>

8010332f <pinit>:
{
8010332f:	55                   	push   %ebp
80103330:	89 e5                	mov    %esp,%ebp
80103332:	83 ec 10             	sub    $0x10,%esp
  initlock(&ptable.lock, "ptable");
80103335:	68 75 6c 10 80       	push   $0x80106c75
8010333a:	68 60 2d 13 80       	push   $0x80132d60
8010333f:	e8 df 08 00 00       	call   80103c23 <initlock>
}
80103344:	83 c4 10             	add    $0x10,%esp
80103347:	c9                   	leave  
80103348:	c3                   	ret    

80103349 <mycpu>:
{
80103349:	55                   	push   %ebp
8010334a:	89 e5                	mov    %esp,%ebp
8010334c:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
8010334f:	9c                   	pushf  
80103350:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103351:	f6 c4 02             	test   $0x2,%ah
80103354:	75 28                	jne    8010337e <mycpu+0x35>
  apicid = lapicid();
80103356:	e8 ed f1 ff ff       	call   80102548 <lapicid>
  for (i = 0; i < ncpu; ++i) {
8010335b:	ba 00 00 00 00       	mov    $0x0,%edx
80103360:	39 15 40 2d 13 80    	cmp    %edx,0x80132d40
80103366:	7e 23                	jle    8010338b <mycpu+0x42>
    if (cpus[i].apicid == apicid)
80103368:	69 ca b0 00 00 00    	imul   $0xb0,%edx,%ecx
8010336e:	0f b6 89 c0 27 13 80 	movzbl -0x7fecd840(%ecx),%ecx
80103375:	39 c1                	cmp    %eax,%ecx
80103377:	74 1f                	je     80103398 <mycpu+0x4f>
  for (i = 0; i < ncpu; ++i) {
80103379:	83 c2 01             	add    $0x1,%edx
8010337c:	eb e2                	jmp    80103360 <mycpu+0x17>
    panic("mycpu called with interrupts enabled\n");
8010337e:	83 ec 0c             	sub    $0xc,%esp
80103381:	68 58 6d 10 80       	push   $0x80106d58
80103386:	e8 bd cf ff ff       	call   80100348 <panic>
  panic("unknown apicid\n");
8010338b:	83 ec 0c             	sub    $0xc,%esp
8010338e:	68 7c 6c 10 80       	push   $0x80106c7c
80103393:	e8 b0 cf ff ff       	call   80100348 <panic>
      return &cpus[i];
80103398:	69 c2 b0 00 00 00    	imul   $0xb0,%edx,%eax
8010339e:	05 c0 27 13 80       	add    $0x801327c0,%eax
}
801033a3:	c9                   	leave  
801033a4:	c3                   	ret    

801033a5 <cpuid>:
cpuid() {
801033a5:	55                   	push   %ebp
801033a6:	89 e5                	mov    %esp,%ebp
801033a8:	83 ec 08             	sub    $0x8,%esp
  return mycpu()-cpus;
801033ab:	e8 99 ff ff ff       	call   80103349 <mycpu>
801033b0:	2d c0 27 13 80       	sub    $0x801327c0,%eax
801033b5:	c1 f8 04             	sar    $0x4,%eax
801033b8:	69 c0 a3 8b 2e ba    	imul   $0xba2e8ba3,%eax,%eax
}
801033be:	c9                   	leave  
801033bf:	c3                   	ret    

801033c0 <myproc>:
myproc(void) {
801033c0:	55                   	push   %ebp
801033c1:	89 e5                	mov    %esp,%ebp
801033c3:	53                   	push   %ebx
801033c4:	83 ec 04             	sub    $0x4,%esp
  pushcli();
801033c7:	e8 b6 08 00 00       	call   80103c82 <pushcli>
  c = mycpu();
801033cc:	e8 78 ff ff ff       	call   80103349 <mycpu>
  p = c->proc;
801033d1:	8b 98 ac 00 00 00    	mov    0xac(%eax),%ebx
  popcli();
801033d7:	e8 e3 08 00 00       	call   80103cbf <popcli>
}
801033dc:	89 d8                	mov    %ebx,%eax
801033de:	83 c4 04             	add    $0x4,%esp
801033e1:	5b                   	pop    %ebx
801033e2:	5d                   	pop    %ebp
801033e3:	c3                   	ret    

801033e4 <userinit>:
{
801033e4:	55                   	push   %ebp
801033e5:	89 e5                	mov    %esp,%ebp
801033e7:	53                   	push   %ebx
801033e8:	83 ec 04             	sub    $0x4,%esp
  p = allocproc();
801033eb:	e8 3b fe ff ff       	call   8010322b <allocproc>
801033f0:	89 c3                	mov    %eax,%ebx
  initproc = p;
801033f2:	a3 c0 a5 10 80       	mov    %eax,0x8010a5c0
  if((p->pgdir = setupkvm()) == 0)
801033f7:	e8 16 30 00 00       	call   80106412 <setupkvm>
801033fc:	89 43 04             	mov    %eax,0x4(%ebx)
801033ff:	85 c0                	test   %eax,%eax
80103401:	0f 84 b7 00 00 00    	je     801034be <userinit+0xda>
  inituvm(p->pgdir, _binary_initcode_start, (int)_binary_initcode_size);
80103407:	83 ec 04             	sub    $0x4,%esp
8010340a:	68 2c 00 00 00       	push   $0x2c
8010340f:	68 60 a4 10 80       	push   $0x8010a460
80103414:	50                   	push   %eax
80103415:	e8 03 2d 00 00       	call   8010611d <inituvm>
  p->sz = PGSIZE;
8010341a:	c7 03 00 10 00 00    	movl   $0x1000,(%ebx)
  memset(p->tf, 0, sizeof(*p->tf));
80103420:	83 c4 0c             	add    $0xc,%esp
80103423:	6a 4c                	push   $0x4c
80103425:	6a 00                	push   $0x0
80103427:	ff 73 18             	pushl  0x18(%ebx)
8010342a:	e8 dc 09 00 00       	call   80103e0b <memset>
  p->tf->cs = (SEG_UCODE << 3) | DPL_USER;
8010342f:	8b 43 18             	mov    0x18(%ebx),%eax
80103432:	66 c7 40 3c 1b 00    	movw   $0x1b,0x3c(%eax)
  p->tf->ds = (SEG_UDATA << 3) | DPL_USER;
80103438:	8b 43 18             	mov    0x18(%ebx),%eax
8010343b:	66 c7 40 2c 23 00    	movw   $0x23,0x2c(%eax)
  p->tf->es = p->tf->ds;
80103441:	8b 43 18             	mov    0x18(%ebx),%eax
80103444:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103448:	66 89 50 28          	mov    %dx,0x28(%eax)
  p->tf->ss = p->tf->ds;
8010344c:	8b 43 18             	mov    0x18(%ebx),%eax
8010344f:	0f b7 50 2c          	movzwl 0x2c(%eax),%edx
80103453:	66 89 50 48          	mov    %dx,0x48(%eax)
  p->tf->eflags = FL_IF;
80103457:	8b 43 18             	mov    0x18(%ebx),%eax
8010345a:	c7 40 40 00 02 00 00 	movl   $0x200,0x40(%eax)
  p->tf->esp = PGSIZE;
80103461:	8b 43 18             	mov    0x18(%ebx),%eax
80103464:	c7 40 44 00 10 00 00 	movl   $0x1000,0x44(%eax)
  p->tf->eip = 0;  // beginning of initcode.S
8010346b:	8b 43 18             	mov    0x18(%ebx),%eax
8010346e:	c7 40 38 00 00 00 00 	movl   $0x0,0x38(%eax)
  safestrcpy(p->name, "initcode", sizeof(p->name));
80103475:	8d 43 6c             	lea    0x6c(%ebx),%eax
80103478:	83 c4 0c             	add    $0xc,%esp
8010347b:	6a 10                	push   $0x10
8010347d:	68 a5 6c 10 80       	push   $0x80106ca5
80103482:	50                   	push   %eax
80103483:	e8 ea 0a 00 00       	call   80103f72 <safestrcpy>
  p->cwd = namei("/");
80103488:	c7 04 24 ae 6c 10 80 	movl   $0x80106cae,(%esp)
8010348f:	e8 4d e7 ff ff       	call   80101be1 <namei>
80103494:	89 43 68             	mov    %eax,0x68(%ebx)
  acquire(&ptable.lock);
80103497:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
8010349e:	e8 bc 08 00 00       	call   80103d5f <acquire>
  p->state = RUNNABLE;
801034a3:	c7 43 0c 03 00 00 00 	movl   $0x3,0xc(%ebx)
  release(&ptable.lock);
801034aa:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
801034b1:	e8 0e 09 00 00       	call   80103dc4 <release>
}
801034b6:	83 c4 10             	add    $0x10,%esp
801034b9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
801034bc:	c9                   	leave  
801034bd:	c3                   	ret    
    panic("userinit: out of memory?");
801034be:	83 ec 0c             	sub    $0xc,%esp
801034c1:	68 8c 6c 10 80       	push   $0x80106c8c
801034c6:	e8 7d ce ff ff       	call   80100348 <panic>

801034cb <growproc>:
{
801034cb:	55                   	push   %ebp
801034cc:	89 e5                	mov    %esp,%ebp
801034ce:	56                   	push   %esi
801034cf:	53                   	push   %ebx
801034d0:	8b 75 08             	mov    0x8(%ebp),%esi
  struct proc *curproc = myproc();
801034d3:	e8 e8 fe ff ff       	call   801033c0 <myproc>
801034d8:	89 c3                	mov    %eax,%ebx
  sz = curproc->sz;
801034da:	8b 00                	mov    (%eax),%eax
  if(n > 0){
801034dc:	85 f6                	test   %esi,%esi
801034de:	7f 21                	jg     80103501 <growproc+0x36>
  } else if(n < 0){
801034e0:	85 f6                	test   %esi,%esi
801034e2:	79 33                	jns    80103517 <growproc+0x4c>
    if((sz = deallocuvm(curproc->pgdir, sz, sz + n)) == 0)
801034e4:	83 ec 04             	sub    $0x4,%esp
801034e7:	01 c6                	add    %eax,%esi
801034e9:	56                   	push   %esi
801034ea:	50                   	push   %eax
801034eb:	ff 73 04             	pushl  0x4(%ebx)
801034ee:	e8 33 2d 00 00       	call   80106226 <deallocuvm>
801034f3:	83 c4 10             	add    $0x10,%esp
801034f6:	85 c0                	test   %eax,%eax
801034f8:	75 1d                	jne    80103517 <growproc+0x4c>
      return -1;
801034fa:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801034ff:	eb 29                	jmp    8010352a <growproc+0x5f>
    if((sz = allocuvm(curproc->pgdir, sz, sz + n)) == 0)
80103501:	83 ec 04             	sub    $0x4,%esp
80103504:	01 c6                	add    %eax,%esi
80103506:	56                   	push   %esi
80103507:	50                   	push   %eax
80103508:	ff 73 04             	pushl  0x4(%ebx)
8010350b:	e8 a8 2d 00 00       	call   801062b8 <allocuvm>
80103510:	83 c4 10             	add    $0x10,%esp
80103513:	85 c0                	test   %eax,%eax
80103515:	74 1a                	je     80103531 <growproc+0x66>
  curproc->sz = sz;
80103517:	89 03                	mov    %eax,(%ebx)
  switchuvm(curproc);
80103519:	83 ec 0c             	sub    $0xc,%esp
8010351c:	53                   	push   %ebx
8010351d:	e8 e3 2a 00 00       	call   80106005 <switchuvm>
  return 0;
80103522:	83 c4 10             	add    $0x10,%esp
80103525:	b8 00 00 00 00       	mov    $0x0,%eax
}
8010352a:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010352d:	5b                   	pop    %ebx
8010352e:	5e                   	pop    %esi
8010352f:	5d                   	pop    %ebp
80103530:	c3                   	ret    
      return -1;
80103531:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103536:	eb f2                	jmp    8010352a <growproc+0x5f>

80103538 <fork>:
{
80103538:	55                   	push   %ebp
80103539:	89 e5                	mov    %esp,%ebp
8010353b:	57                   	push   %edi
8010353c:	56                   	push   %esi
8010353d:	53                   	push   %ebx
8010353e:	83 ec 1c             	sub    $0x1c,%esp
  struct proc *curproc = myproc();
80103541:	e8 7a fe ff ff       	call   801033c0 <myproc>
80103546:	89 c3                	mov    %eax,%ebx
  if((np = allocproc()) == 0){
80103548:	e8 de fc ff ff       	call   8010322b <allocproc>
8010354d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80103550:	85 c0                	test   %eax,%eax
80103552:	0f 84 e0 00 00 00    	je     80103638 <fork+0x100>
80103558:	89 c7                	mov    %eax,%edi
  if((np->pgdir = copyuvm(curproc->pgdir, curproc->sz)) == 0){
8010355a:	83 ec 08             	sub    $0x8,%esp
8010355d:	ff 33                	pushl  (%ebx)
8010355f:	ff 73 04             	pushl  0x4(%ebx)
80103562:	e8 5c 2f 00 00       	call   801064c3 <copyuvm>
80103567:	89 47 04             	mov    %eax,0x4(%edi)
8010356a:	83 c4 10             	add    $0x10,%esp
8010356d:	85 c0                	test   %eax,%eax
8010356f:	74 2a                	je     8010359b <fork+0x63>
  np->sz = curproc->sz;
80103571:	8b 03                	mov    (%ebx),%eax
80103573:	8b 4d e4             	mov    -0x1c(%ebp),%ecx
80103576:	89 01                	mov    %eax,(%ecx)
  np->parent = curproc;
80103578:	89 c8                	mov    %ecx,%eax
8010357a:	89 59 14             	mov    %ebx,0x14(%ecx)
  *np->tf = *curproc->tf;
8010357d:	8b 73 18             	mov    0x18(%ebx),%esi
80103580:	8b 79 18             	mov    0x18(%ecx),%edi
80103583:	b9 13 00 00 00       	mov    $0x13,%ecx
80103588:	f3 a5                	rep movsl %ds:(%esi),%es:(%edi)
  np->tf->eax = 0;
8010358a:	8b 40 18             	mov    0x18(%eax),%eax
8010358d:	c7 40 1c 00 00 00 00 	movl   $0x0,0x1c(%eax)
  for(i = 0; i < NOFILE; i++)
80103594:	be 00 00 00 00       	mov    $0x0,%esi
80103599:	eb 29                	jmp    801035c4 <fork+0x8c>
    kfree(np->kstack);
8010359b:	83 ec 0c             	sub    $0xc,%esp
8010359e:	8b 5d e4             	mov    -0x1c(%ebp),%ebx
801035a1:	ff 73 08             	pushl  0x8(%ebx)
801035a4:	e8 fb e9 ff ff       	call   80101fa4 <kfree>
    np->kstack = 0;
801035a9:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
    np->state = UNUSED;
801035b0:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
    return -1;
801035b7:	83 c4 10             	add    $0x10,%esp
801035ba:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
801035bf:	eb 6d                	jmp    8010362e <fork+0xf6>
  for(i = 0; i < NOFILE; i++)
801035c1:	83 c6 01             	add    $0x1,%esi
801035c4:	83 fe 0f             	cmp    $0xf,%esi
801035c7:	7f 1d                	jg     801035e6 <fork+0xae>
    if(curproc->ofile[i])
801035c9:	8b 44 b3 28          	mov    0x28(%ebx,%esi,4),%eax
801035cd:	85 c0                	test   %eax,%eax
801035cf:	74 f0                	je     801035c1 <fork+0x89>
      np->ofile[i] = filedup(curproc->ofile[i]);
801035d1:	83 ec 0c             	sub    $0xc,%esp
801035d4:	50                   	push   %eax
801035d5:	e8 b4 d6 ff ff       	call   80100c8e <filedup>
801035da:	8b 55 e4             	mov    -0x1c(%ebp),%edx
801035dd:	89 44 b2 28          	mov    %eax,0x28(%edx,%esi,4)
801035e1:	83 c4 10             	add    $0x10,%esp
801035e4:	eb db                	jmp    801035c1 <fork+0x89>
  np->cwd = idup(curproc->cwd);
801035e6:	83 ec 0c             	sub    $0xc,%esp
801035e9:	ff 73 68             	pushl  0x68(%ebx)
801035ec:	e8 60 df ff ff       	call   80101551 <idup>
801035f1:	8b 7d e4             	mov    -0x1c(%ebp),%edi
801035f4:	89 47 68             	mov    %eax,0x68(%edi)
  safestrcpy(np->name, curproc->name, sizeof(curproc->name));
801035f7:	83 c3 6c             	add    $0x6c,%ebx
801035fa:	8d 47 6c             	lea    0x6c(%edi),%eax
801035fd:	83 c4 0c             	add    $0xc,%esp
80103600:	6a 10                	push   $0x10
80103602:	53                   	push   %ebx
80103603:	50                   	push   %eax
80103604:	e8 69 09 00 00       	call   80103f72 <safestrcpy>
  pid = np->pid;
80103609:	8b 5f 10             	mov    0x10(%edi),%ebx
  acquire(&ptable.lock);
8010360c:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103613:	e8 47 07 00 00       	call   80103d5f <acquire>
  np->state = RUNNABLE;
80103618:	c7 47 0c 03 00 00 00 	movl   $0x3,0xc(%edi)
  release(&ptable.lock);
8010361f:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103626:	e8 99 07 00 00       	call   80103dc4 <release>
  return pid;
8010362b:	83 c4 10             	add    $0x10,%esp
}
8010362e:	89 d8                	mov    %ebx,%eax
80103630:	8d 65 f4             	lea    -0xc(%ebp),%esp
80103633:	5b                   	pop    %ebx
80103634:	5e                   	pop    %esi
80103635:	5f                   	pop    %edi
80103636:	5d                   	pop    %ebp
80103637:	c3                   	ret    
    return -1;
80103638:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
8010363d:	eb ef                	jmp    8010362e <fork+0xf6>

8010363f <scheduler>:
{
8010363f:	55                   	push   %ebp
80103640:	89 e5                	mov    %esp,%ebp
80103642:	56                   	push   %esi
80103643:	53                   	push   %ebx
  struct cpu *c = mycpu();
80103644:	e8 00 fd ff ff       	call   80103349 <mycpu>
80103649:	89 c6                	mov    %eax,%esi
  c->proc = 0;
8010364b:	c7 80 ac 00 00 00 00 	movl   $0x0,0xac(%eax)
80103652:	00 00 00 
80103655:	eb 5a                	jmp    801036b1 <scheduler+0x72>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103657:	83 c3 7c             	add    $0x7c,%ebx
8010365a:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
80103660:	73 3f                	jae    801036a1 <scheduler+0x62>
      if(p->state != RUNNABLE)
80103662:	83 7b 0c 03          	cmpl   $0x3,0xc(%ebx)
80103666:	75 ef                	jne    80103657 <scheduler+0x18>
      c->proc = p;
80103668:	89 9e ac 00 00 00    	mov    %ebx,0xac(%esi)
      switchuvm(p);
8010366e:	83 ec 0c             	sub    $0xc,%esp
80103671:	53                   	push   %ebx
80103672:	e8 8e 29 00 00       	call   80106005 <switchuvm>
      p->state = RUNNING;
80103677:	c7 43 0c 04 00 00 00 	movl   $0x4,0xc(%ebx)
      swtch(&(c->scheduler), p->context);
8010367e:	83 c4 08             	add    $0x8,%esp
80103681:	ff 73 1c             	pushl  0x1c(%ebx)
80103684:	8d 46 04             	lea    0x4(%esi),%eax
80103687:	50                   	push   %eax
80103688:	e8 38 09 00 00       	call   80103fc5 <swtch>
      switchkvm();
8010368d:	e8 61 29 00 00       	call   80105ff3 <switchkvm>
      c->proc = 0;
80103692:	c7 86 ac 00 00 00 00 	movl   $0x0,0xac(%esi)
80103699:	00 00 00 
8010369c:	83 c4 10             	add    $0x10,%esp
8010369f:	eb b6                	jmp    80103657 <scheduler+0x18>
    release(&ptable.lock);
801036a1:	83 ec 0c             	sub    $0xc,%esp
801036a4:	68 60 2d 13 80       	push   $0x80132d60
801036a9:	e8 16 07 00 00       	call   80103dc4 <release>
    sti();
801036ae:	83 c4 10             	add    $0x10,%esp
  asm volatile("sti");
801036b1:	fb                   	sti    
    acquire(&ptable.lock);
801036b2:	83 ec 0c             	sub    $0xc,%esp
801036b5:	68 60 2d 13 80       	push   $0x80132d60
801036ba:	e8 a0 06 00 00       	call   80103d5f <acquire>
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801036bf:	83 c4 10             	add    $0x10,%esp
801036c2:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
801036c7:	eb 91                	jmp    8010365a <scheduler+0x1b>

801036c9 <sched>:
{
801036c9:	55                   	push   %ebp
801036ca:	89 e5                	mov    %esp,%ebp
801036cc:	56                   	push   %esi
801036cd:	53                   	push   %ebx
  struct proc *p = myproc();
801036ce:	e8 ed fc ff ff       	call   801033c0 <myproc>
801036d3:	89 c3                	mov    %eax,%ebx
  if(!holding(&ptable.lock))
801036d5:	83 ec 0c             	sub    $0xc,%esp
801036d8:	68 60 2d 13 80       	push   $0x80132d60
801036dd:	e8 3d 06 00 00       	call   80103d1f <holding>
801036e2:	83 c4 10             	add    $0x10,%esp
801036e5:	85 c0                	test   %eax,%eax
801036e7:	74 4f                	je     80103738 <sched+0x6f>
  if(mycpu()->ncli != 1)
801036e9:	e8 5b fc ff ff       	call   80103349 <mycpu>
801036ee:	83 b8 a4 00 00 00 01 	cmpl   $0x1,0xa4(%eax)
801036f5:	75 4e                	jne    80103745 <sched+0x7c>
  if(p->state == RUNNING)
801036f7:	83 7b 0c 04          	cmpl   $0x4,0xc(%ebx)
801036fb:	74 55                	je     80103752 <sched+0x89>
  asm volatile("pushfl; popl %0" : "=r" (eflags));
801036fd:	9c                   	pushf  
801036fe:	58                   	pop    %eax
  if(readeflags()&FL_IF)
801036ff:	f6 c4 02             	test   $0x2,%ah
80103702:	75 5b                	jne    8010375f <sched+0x96>
  intena = mycpu()->intena;
80103704:	e8 40 fc ff ff       	call   80103349 <mycpu>
80103709:	8b b0 a8 00 00 00    	mov    0xa8(%eax),%esi
  swtch(&p->context, mycpu()->scheduler);
8010370f:	e8 35 fc ff ff       	call   80103349 <mycpu>
80103714:	83 ec 08             	sub    $0x8,%esp
80103717:	ff 70 04             	pushl  0x4(%eax)
8010371a:	83 c3 1c             	add    $0x1c,%ebx
8010371d:	53                   	push   %ebx
8010371e:	e8 a2 08 00 00       	call   80103fc5 <swtch>
  mycpu()->intena = intena;
80103723:	e8 21 fc ff ff       	call   80103349 <mycpu>
80103728:	89 b0 a8 00 00 00    	mov    %esi,0xa8(%eax)
}
8010372e:	83 c4 10             	add    $0x10,%esp
80103731:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103734:	5b                   	pop    %ebx
80103735:	5e                   	pop    %esi
80103736:	5d                   	pop    %ebp
80103737:	c3                   	ret    
    panic("sched ptable.lock");
80103738:	83 ec 0c             	sub    $0xc,%esp
8010373b:	68 b0 6c 10 80       	push   $0x80106cb0
80103740:	e8 03 cc ff ff       	call   80100348 <panic>
    panic("sched locks");
80103745:	83 ec 0c             	sub    $0xc,%esp
80103748:	68 c2 6c 10 80       	push   $0x80106cc2
8010374d:	e8 f6 cb ff ff       	call   80100348 <panic>
    panic("sched running");
80103752:	83 ec 0c             	sub    $0xc,%esp
80103755:	68 ce 6c 10 80       	push   $0x80106cce
8010375a:	e8 e9 cb ff ff       	call   80100348 <panic>
    panic("sched interruptible");
8010375f:	83 ec 0c             	sub    $0xc,%esp
80103762:	68 dc 6c 10 80       	push   $0x80106cdc
80103767:	e8 dc cb ff ff       	call   80100348 <panic>

8010376c <exit>:
{
8010376c:	55                   	push   %ebp
8010376d:	89 e5                	mov    %esp,%ebp
8010376f:	56                   	push   %esi
80103770:	53                   	push   %ebx
  struct proc *curproc = myproc();
80103771:	e8 4a fc ff ff       	call   801033c0 <myproc>
  if(curproc == initproc)
80103776:	39 05 c0 a5 10 80    	cmp    %eax,0x8010a5c0
8010377c:	74 09                	je     80103787 <exit+0x1b>
8010377e:	89 c6                	mov    %eax,%esi
  for(fd = 0; fd < NOFILE; fd++){
80103780:	bb 00 00 00 00       	mov    $0x0,%ebx
80103785:	eb 10                	jmp    80103797 <exit+0x2b>
    panic("init exiting");
80103787:	83 ec 0c             	sub    $0xc,%esp
8010378a:	68 f0 6c 10 80       	push   $0x80106cf0
8010378f:	e8 b4 cb ff ff       	call   80100348 <panic>
  for(fd = 0; fd < NOFILE; fd++){
80103794:	83 c3 01             	add    $0x1,%ebx
80103797:	83 fb 0f             	cmp    $0xf,%ebx
8010379a:	7f 1e                	jg     801037ba <exit+0x4e>
    if(curproc->ofile[fd]){
8010379c:	8b 44 9e 28          	mov    0x28(%esi,%ebx,4),%eax
801037a0:	85 c0                	test   %eax,%eax
801037a2:	74 f0                	je     80103794 <exit+0x28>
      fileclose(curproc->ofile[fd]);
801037a4:	83 ec 0c             	sub    $0xc,%esp
801037a7:	50                   	push   %eax
801037a8:	e8 26 d5 ff ff       	call   80100cd3 <fileclose>
      curproc->ofile[fd] = 0;
801037ad:	c7 44 9e 28 00 00 00 	movl   $0x0,0x28(%esi,%ebx,4)
801037b4:	00 
801037b5:	83 c4 10             	add    $0x10,%esp
801037b8:	eb da                	jmp    80103794 <exit+0x28>
  begin_op();
801037ba:	e8 b9 f1 ff ff       	call   80102978 <begin_op>
  iput(curproc->cwd);
801037bf:	83 ec 0c             	sub    $0xc,%esp
801037c2:	ff 76 68             	pushl  0x68(%esi)
801037c5:	e8 be de ff ff       	call   80101688 <iput>
  end_op();
801037ca:	e8 23 f2 ff ff       	call   801029f2 <end_op>
  curproc->cwd = 0;
801037cf:	c7 46 68 00 00 00 00 	movl   $0x0,0x68(%esi)
  acquire(&ptable.lock);
801037d6:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
801037dd:	e8 7d 05 00 00       	call   80103d5f <acquire>
  wakeup1(curproc->parent);
801037e2:	8b 46 14             	mov    0x14(%esi),%eax
801037e5:	e8 16 fa ff ff       	call   80103200 <wakeup1>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
801037ea:	83 c4 10             	add    $0x10,%esp
801037ed:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
801037f2:	eb 03                	jmp    801037f7 <exit+0x8b>
801037f4:	83 c3 7c             	add    $0x7c,%ebx
801037f7:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
801037fd:	73 1a                	jae    80103819 <exit+0xad>
    if(p->parent == curproc){
801037ff:	39 73 14             	cmp    %esi,0x14(%ebx)
80103802:	75 f0                	jne    801037f4 <exit+0x88>
      p->parent = initproc;
80103804:	a1 c0 a5 10 80       	mov    0x8010a5c0,%eax
80103809:	89 43 14             	mov    %eax,0x14(%ebx)
      if(p->state == ZOMBIE)
8010380c:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103810:	75 e2                	jne    801037f4 <exit+0x88>
        wakeup1(initproc);
80103812:	e8 e9 f9 ff ff       	call   80103200 <wakeup1>
80103817:	eb db                	jmp    801037f4 <exit+0x88>
  curproc->state = ZOMBIE;
80103819:	c7 46 0c 05 00 00 00 	movl   $0x5,0xc(%esi)
  sched();
80103820:	e8 a4 fe ff ff       	call   801036c9 <sched>
  panic("zombie exit");
80103825:	83 ec 0c             	sub    $0xc,%esp
80103828:	68 fd 6c 10 80       	push   $0x80106cfd
8010382d:	e8 16 cb ff ff       	call   80100348 <panic>

80103832 <yield>:
{
80103832:	55                   	push   %ebp
80103833:	89 e5                	mov    %esp,%ebp
80103835:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);  //DOC: yieldlock
80103838:	68 60 2d 13 80       	push   $0x80132d60
8010383d:	e8 1d 05 00 00       	call   80103d5f <acquire>
  myproc()->state = RUNNABLE;
80103842:	e8 79 fb ff ff       	call   801033c0 <myproc>
80103847:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
  sched();
8010384e:	e8 76 fe ff ff       	call   801036c9 <sched>
  release(&ptable.lock);
80103853:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
8010385a:	e8 65 05 00 00       	call   80103dc4 <release>
}
8010385f:	83 c4 10             	add    $0x10,%esp
80103862:	c9                   	leave  
80103863:	c3                   	ret    

80103864 <sleep>:
{
80103864:	55                   	push   %ebp
80103865:	89 e5                	mov    %esp,%ebp
80103867:	56                   	push   %esi
80103868:	53                   	push   %ebx
80103869:	8b 5d 0c             	mov    0xc(%ebp),%ebx
  struct proc *p = myproc();
8010386c:	e8 4f fb ff ff       	call   801033c0 <myproc>
  if(p == 0)
80103871:	85 c0                	test   %eax,%eax
80103873:	74 66                	je     801038db <sleep+0x77>
80103875:	89 c6                	mov    %eax,%esi
  if(lk == 0)
80103877:	85 db                	test   %ebx,%ebx
80103879:	74 6d                	je     801038e8 <sleep+0x84>
  if(lk != &ptable.lock){  //DOC: sleeplock0
8010387b:	81 fb 60 2d 13 80    	cmp    $0x80132d60,%ebx
80103881:	74 18                	je     8010389b <sleep+0x37>
    acquire(&ptable.lock);  //DOC: sleeplock1
80103883:	83 ec 0c             	sub    $0xc,%esp
80103886:	68 60 2d 13 80       	push   $0x80132d60
8010388b:	e8 cf 04 00 00       	call   80103d5f <acquire>
    release(lk);
80103890:	89 1c 24             	mov    %ebx,(%esp)
80103893:	e8 2c 05 00 00       	call   80103dc4 <release>
80103898:	83 c4 10             	add    $0x10,%esp
  p->chan = chan;
8010389b:	8b 45 08             	mov    0x8(%ebp),%eax
8010389e:	89 46 20             	mov    %eax,0x20(%esi)
  p->state = SLEEPING;
801038a1:	c7 46 0c 02 00 00 00 	movl   $0x2,0xc(%esi)
  sched();
801038a8:	e8 1c fe ff ff       	call   801036c9 <sched>
  p->chan = 0;
801038ad:	c7 46 20 00 00 00 00 	movl   $0x0,0x20(%esi)
  if(lk != &ptable.lock){  //DOC: sleeplock2
801038b4:	81 fb 60 2d 13 80    	cmp    $0x80132d60,%ebx
801038ba:	74 18                	je     801038d4 <sleep+0x70>
    release(&ptable.lock);
801038bc:	83 ec 0c             	sub    $0xc,%esp
801038bf:	68 60 2d 13 80       	push   $0x80132d60
801038c4:	e8 fb 04 00 00       	call   80103dc4 <release>
    acquire(lk);
801038c9:	89 1c 24             	mov    %ebx,(%esp)
801038cc:	e8 8e 04 00 00       	call   80103d5f <acquire>
801038d1:	83 c4 10             	add    $0x10,%esp
}
801038d4:	8d 65 f8             	lea    -0x8(%ebp),%esp
801038d7:	5b                   	pop    %ebx
801038d8:	5e                   	pop    %esi
801038d9:	5d                   	pop    %ebp
801038da:	c3                   	ret    
    panic("sleep");
801038db:	83 ec 0c             	sub    $0xc,%esp
801038de:	68 09 6d 10 80       	push   $0x80106d09
801038e3:	e8 60 ca ff ff       	call   80100348 <panic>
    panic("sleep without lk");
801038e8:	83 ec 0c             	sub    $0xc,%esp
801038eb:	68 0f 6d 10 80       	push   $0x80106d0f
801038f0:	e8 53 ca ff ff       	call   80100348 <panic>

801038f5 <wait>:
{
801038f5:	55                   	push   %ebp
801038f6:	89 e5                	mov    %esp,%ebp
801038f8:	56                   	push   %esi
801038f9:	53                   	push   %ebx
  struct proc *curproc = myproc();
801038fa:	e8 c1 fa ff ff       	call   801033c0 <myproc>
801038ff:	89 c6                	mov    %eax,%esi
  acquire(&ptable.lock);
80103901:	83 ec 0c             	sub    $0xc,%esp
80103904:	68 60 2d 13 80       	push   $0x80132d60
80103909:	e8 51 04 00 00       	call   80103d5f <acquire>
8010390e:	83 c4 10             	add    $0x10,%esp
    havekids = 0;
80103911:	b8 00 00 00 00       	mov    $0x0,%eax
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103916:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
8010391b:	eb 5b                	jmp    80103978 <wait+0x83>
        pid = p->pid;
8010391d:	8b 73 10             	mov    0x10(%ebx),%esi
        kfree(p->kstack);
80103920:	83 ec 0c             	sub    $0xc,%esp
80103923:	ff 73 08             	pushl  0x8(%ebx)
80103926:	e8 79 e6 ff ff       	call   80101fa4 <kfree>
        p->kstack = 0;
8010392b:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
        freevm(p->pgdir);
80103932:	83 c4 04             	add    $0x4,%esp
80103935:	ff 73 04             	pushl  0x4(%ebx)
80103938:	e8 65 2a 00 00       	call   801063a2 <freevm>
        p->pid = 0;
8010393d:	c7 43 10 00 00 00 00 	movl   $0x0,0x10(%ebx)
        p->parent = 0;
80103944:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
        p->name[0] = 0;
8010394b:	c6 43 6c 00          	movb   $0x0,0x6c(%ebx)
        p->killed = 0;
8010394f:	c7 43 24 00 00 00 00 	movl   $0x0,0x24(%ebx)
        p->state = UNUSED;
80103956:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
        release(&ptable.lock);
8010395d:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
80103964:	e8 5b 04 00 00       	call   80103dc4 <release>
        return pid;
80103969:	83 c4 10             	add    $0x10,%esp
}
8010396c:	89 f0                	mov    %esi,%eax
8010396e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103971:	5b                   	pop    %ebx
80103972:	5e                   	pop    %esi
80103973:	5d                   	pop    %ebp
80103974:	c3                   	ret    
    for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103975:	83 c3 7c             	add    $0x7c,%ebx
80103978:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
8010397e:	73 12                	jae    80103992 <wait+0x9d>
      if(p->parent != curproc)
80103980:	39 73 14             	cmp    %esi,0x14(%ebx)
80103983:	75 f0                	jne    80103975 <wait+0x80>
      if(p->state == ZOMBIE){
80103985:	83 7b 0c 05          	cmpl   $0x5,0xc(%ebx)
80103989:	74 92                	je     8010391d <wait+0x28>
      havekids = 1;
8010398b:	b8 01 00 00 00       	mov    $0x1,%eax
80103990:	eb e3                	jmp    80103975 <wait+0x80>
    if(!havekids || curproc->killed){
80103992:	85 c0                	test   %eax,%eax
80103994:	74 06                	je     8010399c <wait+0xa7>
80103996:	83 7e 24 00          	cmpl   $0x0,0x24(%esi)
8010399a:	74 17                	je     801039b3 <wait+0xbe>
      release(&ptable.lock);
8010399c:	83 ec 0c             	sub    $0xc,%esp
8010399f:	68 60 2d 13 80       	push   $0x80132d60
801039a4:	e8 1b 04 00 00       	call   80103dc4 <release>
      return -1;
801039a9:	83 c4 10             	add    $0x10,%esp
801039ac:	be ff ff ff ff       	mov    $0xffffffff,%esi
801039b1:	eb b9                	jmp    8010396c <wait+0x77>
    sleep(curproc, &ptable.lock);  //DOC: wait-sleep
801039b3:	83 ec 08             	sub    $0x8,%esp
801039b6:	68 60 2d 13 80       	push   $0x80132d60
801039bb:	56                   	push   %esi
801039bc:	e8 a3 fe ff ff       	call   80103864 <sleep>
    havekids = 0;
801039c1:	83 c4 10             	add    $0x10,%esp
801039c4:	e9 48 ff ff ff       	jmp    80103911 <wait+0x1c>

801039c9 <wakeup>:

// Wake up all processes sleeping on chan.
void
wakeup(void *chan)
{
801039c9:	55                   	push   %ebp
801039ca:	89 e5                	mov    %esp,%ebp
801039cc:	83 ec 14             	sub    $0x14,%esp
  acquire(&ptable.lock);
801039cf:	68 60 2d 13 80       	push   $0x80132d60
801039d4:	e8 86 03 00 00       	call   80103d5f <acquire>
  wakeup1(chan);
801039d9:	8b 45 08             	mov    0x8(%ebp),%eax
801039dc:	e8 1f f8 ff ff       	call   80103200 <wakeup1>
  release(&ptable.lock);
801039e1:	c7 04 24 60 2d 13 80 	movl   $0x80132d60,(%esp)
801039e8:	e8 d7 03 00 00       	call   80103dc4 <release>
}
801039ed:	83 c4 10             	add    $0x10,%esp
801039f0:	c9                   	leave  
801039f1:	c3                   	ret    

801039f2 <kill>:
// Kill the process with the given pid.
// Process won't exit until it returns
// to user space (see trap in trap.c).
int
kill(int pid)
{
801039f2:	55                   	push   %ebp
801039f3:	89 e5                	mov    %esp,%ebp
801039f5:	53                   	push   %ebx
801039f6:	83 ec 10             	sub    $0x10,%esp
801039f9:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *p;

  acquire(&ptable.lock);
801039fc:	68 60 2d 13 80       	push   $0x80132d60
80103a01:	e8 59 03 00 00       	call   80103d5f <acquire>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a06:	83 c4 10             	add    $0x10,%esp
80103a09:	b8 94 2d 13 80       	mov    $0x80132d94,%eax
80103a0e:	3d 94 4c 13 80       	cmp    $0x80134c94,%eax
80103a13:	73 3a                	jae    80103a4f <kill+0x5d>
    if(p->pid == pid){
80103a15:	39 58 10             	cmp    %ebx,0x10(%eax)
80103a18:	74 05                	je     80103a1f <kill+0x2d>
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a1a:	83 c0 7c             	add    $0x7c,%eax
80103a1d:	eb ef                	jmp    80103a0e <kill+0x1c>
      p->killed = 1;
80103a1f:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
      // Wake process from sleep if necessary.
      if(p->state == SLEEPING)
80103a26:	83 78 0c 02          	cmpl   $0x2,0xc(%eax)
80103a2a:	74 1a                	je     80103a46 <kill+0x54>
        p->state = RUNNABLE;
      release(&ptable.lock);
80103a2c:	83 ec 0c             	sub    $0xc,%esp
80103a2f:	68 60 2d 13 80       	push   $0x80132d60
80103a34:	e8 8b 03 00 00       	call   80103dc4 <release>
      return 0;
80103a39:	83 c4 10             	add    $0x10,%esp
80103a3c:	b8 00 00 00 00       	mov    $0x0,%eax
    }
  }
  release(&ptable.lock);
  return -1;
}
80103a41:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103a44:	c9                   	leave  
80103a45:	c3                   	ret    
        p->state = RUNNABLE;
80103a46:	c7 40 0c 03 00 00 00 	movl   $0x3,0xc(%eax)
80103a4d:	eb dd                	jmp    80103a2c <kill+0x3a>
  release(&ptable.lock);
80103a4f:	83 ec 0c             	sub    $0xc,%esp
80103a52:	68 60 2d 13 80       	push   $0x80132d60
80103a57:	e8 68 03 00 00       	call   80103dc4 <release>
  return -1;
80103a5c:	83 c4 10             	add    $0x10,%esp
80103a5f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80103a64:	eb db                	jmp    80103a41 <kill+0x4f>

80103a66 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
80103a66:	55                   	push   %ebp
80103a67:	89 e5                	mov    %esp,%ebp
80103a69:	56                   	push   %esi
80103a6a:	53                   	push   %ebx
80103a6b:	83 ec 30             	sub    $0x30,%esp
  int i;
  struct proc *p;
  char *state;
  uint pc[10];

  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103a6e:	bb 94 2d 13 80       	mov    $0x80132d94,%ebx
80103a73:	eb 33                	jmp    80103aa8 <procdump+0x42>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
      state = states[p->state];
    else
      state = "???";
80103a75:	b8 20 6d 10 80       	mov    $0x80106d20,%eax
    cprintf("%d %s %s", p->pid, state, p->name);
80103a7a:	8d 53 6c             	lea    0x6c(%ebx),%edx
80103a7d:	52                   	push   %edx
80103a7e:	50                   	push   %eax
80103a7f:	ff 73 10             	pushl  0x10(%ebx)
80103a82:	68 24 6d 10 80       	push   $0x80106d24
80103a87:	e8 7f cb ff ff       	call   8010060b <cprintf>
    if(p->state == SLEEPING){
80103a8c:	83 c4 10             	add    $0x10,%esp
80103a8f:	83 7b 0c 02          	cmpl   $0x2,0xc(%ebx)
80103a93:	74 39                	je     80103ace <procdump+0x68>
      getcallerpcs((uint*)p->context->ebp+2, pc);
      for(i=0; i<10 && pc[i] != 0; i++)
        cprintf(" %p", pc[i]);
    }
    cprintf("\n");
80103a95:	83 ec 0c             	sub    $0xc,%esp
80103a98:	68 bf 70 10 80       	push   $0x801070bf
80103a9d:	e8 69 cb ff ff       	call   8010060b <cprintf>
80103aa2:	83 c4 10             	add    $0x10,%esp
  for(p = ptable.proc; p < &ptable.proc[NPROC]; p++){
80103aa5:	83 c3 7c             	add    $0x7c,%ebx
80103aa8:	81 fb 94 4c 13 80    	cmp    $0x80134c94,%ebx
80103aae:	73 61                	jae    80103b11 <procdump+0xab>
    if(p->state == UNUSED)
80103ab0:	8b 43 0c             	mov    0xc(%ebx),%eax
80103ab3:	85 c0                	test   %eax,%eax
80103ab5:	74 ee                	je     80103aa5 <procdump+0x3f>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
80103ab7:	83 f8 05             	cmp    $0x5,%eax
80103aba:	77 b9                	ja     80103a75 <procdump+0xf>
80103abc:	8b 04 85 80 6d 10 80 	mov    -0x7fef9280(,%eax,4),%eax
80103ac3:	85 c0                	test   %eax,%eax
80103ac5:	75 b3                	jne    80103a7a <procdump+0x14>
      state = "???";
80103ac7:	b8 20 6d 10 80       	mov    $0x80106d20,%eax
80103acc:	eb ac                	jmp    80103a7a <procdump+0x14>
      getcallerpcs((uint*)p->context->ebp+2, pc);
80103ace:	8b 43 1c             	mov    0x1c(%ebx),%eax
80103ad1:	8b 40 0c             	mov    0xc(%eax),%eax
80103ad4:	83 c0 08             	add    $0x8,%eax
80103ad7:	83 ec 08             	sub    $0x8,%esp
80103ada:	8d 55 d0             	lea    -0x30(%ebp),%edx
80103add:	52                   	push   %edx
80103ade:	50                   	push   %eax
80103adf:	e8 5a 01 00 00       	call   80103c3e <getcallerpcs>
      for(i=0; i<10 && pc[i] != 0; i++)
80103ae4:	83 c4 10             	add    $0x10,%esp
80103ae7:	be 00 00 00 00       	mov    $0x0,%esi
80103aec:	eb 14                	jmp    80103b02 <procdump+0x9c>
        cprintf(" %p", pc[i]);
80103aee:	83 ec 08             	sub    $0x8,%esp
80103af1:	50                   	push   %eax
80103af2:	68 a1 66 10 80       	push   $0x801066a1
80103af7:	e8 0f cb ff ff       	call   8010060b <cprintf>
      for(i=0; i<10 && pc[i] != 0; i++)
80103afc:	83 c6 01             	add    $0x1,%esi
80103aff:	83 c4 10             	add    $0x10,%esp
80103b02:	83 fe 09             	cmp    $0x9,%esi
80103b05:	7f 8e                	jg     80103a95 <procdump+0x2f>
80103b07:	8b 44 b5 d0          	mov    -0x30(%ebp,%esi,4),%eax
80103b0b:	85 c0                	test   %eax,%eax
80103b0d:	75 df                	jne    80103aee <procdump+0x88>
80103b0f:	eb 84                	jmp    80103a95 <procdump+0x2f>
  }
}
80103b11:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b14:	5b                   	pop    %ebx
80103b15:	5e                   	pop    %esi
80103b16:	5d                   	pop    %ebp
80103b17:	c3                   	ret    

80103b18 <initsleeplock>:
#include "spinlock.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
80103b18:	55                   	push   %ebp
80103b19:	89 e5                	mov    %esp,%ebp
80103b1b:	53                   	push   %ebx
80103b1c:	83 ec 0c             	sub    $0xc,%esp
80103b1f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  initlock(&lk->lk, "sleep lock");
80103b22:	68 98 6d 10 80       	push   $0x80106d98
80103b27:	8d 43 04             	lea    0x4(%ebx),%eax
80103b2a:	50                   	push   %eax
80103b2b:	e8 f3 00 00 00       	call   80103c23 <initlock>
  lk->name = name;
80103b30:	8b 45 0c             	mov    0xc(%ebp),%eax
80103b33:	89 43 38             	mov    %eax,0x38(%ebx)
  lk->locked = 0;
80103b36:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103b3c:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
}
80103b43:	83 c4 10             	add    $0x10,%esp
80103b46:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103b49:	c9                   	leave  
80103b4a:	c3                   	ret    

80103b4b <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
80103b4b:	55                   	push   %ebp
80103b4c:	89 e5                	mov    %esp,%ebp
80103b4e:	56                   	push   %esi
80103b4f:	53                   	push   %ebx
80103b50:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103b53:	8d 73 04             	lea    0x4(%ebx),%esi
80103b56:	83 ec 0c             	sub    $0xc,%esp
80103b59:	56                   	push   %esi
80103b5a:	e8 00 02 00 00       	call   80103d5f <acquire>
  while (lk->locked) {
80103b5f:	83 c4 10             	add    $0x10,%esp
80103b62:	eb 0d                	jmp    80103b71 <acquiresleep+0x26>
    sleep(lk, &lk->lk);
80103b64:	83 ec 08             	sub    $0x8,%esp
80103b67:	56                   	push   %esi
80103b68:	53                   	push   %ebx
80103b69:	e8 f6 fc ff ff       	call   80103864 <sleep>
80103b6e:	83 c4 10             	add    $0x10,%esp
  while (lk->locked) {
80103b71:	83 3b 00             	cmpl   $0x0,(%ebx)
80103b74:	75 ee                	jne    80103b64 <acquiresleep+0x19>
  }
  lk->locked = 1;
80103b76:	c7 03 01 00 00 00    	movl   $0x1,(%ebx)
  lk->pid = myproc()->pid;
80103b7c:	e8 3f f8 ff ff       	call   801033c0 <myproc>
80103b81:	8b 40 10             	mov    0x10(%eax),%eax
80103b84:	89 43 3c             	mov    %eax,0x3c(%ebx)
  release(&lk->lk);
80103b87:	83 ec 0c             	sub    $0xc,%esp
80103b8a:	56                   	push   %esi
80103b8b:	e8 34 02 00 00       	call   80103dc4 <release>
}
80103b90:	83 c4 10             	add    $0x10,%esp
80103b93:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103b96:	5b                   	pop    %ebx
80103b97:	5e                   	pop    %esi
80103b98:	5d                   	pop    %ebp
80103b99:	c3                   	ret    

80103b9a <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
80103b9a:	55                   	push   %ebp
80103b9b:	89 e5                	mov    %esp,%ebp
80103b9d:	56                   	push   %esi
80103b9e:	53                   	push   %ebx
80103b9f:	8b 5d 08             	mov    0x8(%ebp),%ebx
  acquire(&lk->lk);
80103ba2:	8d 73 04             	lea    0x4(%ebx),%esi
80103ba5:	83 ec 0c             	sub    $0xc,%esp
80103ba8:	56                   	push   %esi
80103ba9:	e8 b1 01 00 00       	call   80103d5f <acquire>
  lk->locked = 0;
80103bae:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  lk->pid = 0;
80103bb4:	c7 43 3c 00 00 00 00 	movl   $0x0,0x3c(%ebx)
  wakeup(lk);
80103bbb:	89 1c 24             	mov    %ebx,(%esp)
80103bbe:	e8 06 fe ff ff       	call   801039c9 <wakeup>
  release(&lk->lk);
80103bc3:	89 34 24             	mov    %esi,(%esp)
80103bc6:	e8 f9 01 00 00       	call   80103dc4 <release>
}
80103bcb:	83 c4 10             	add    $0x10,%esp
80103bce:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103bd1:	5b                   	pop    %ebx
80103bd2:	5e                   	pop    %esi
80103bd3:	5d                   	pop    %ebp
80103bd4:	c3                   	ret    

80103bd5 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
80103bd5:	55                   	push   %ebp
80103bd6:	89 e5                	mov    %esp,%ebp
80103bd8:	56                   	push   %esi
80103bd9:	53                   	push   %ebx
80103bda:	8b 5d 08             	mov    0x8(%ebp),%ebx
  int r;
  
  acquire(&lk->lk);
80103bdd:	8d 73 04             	lea    0x4(%ebx),%esi
80103be0:	83 ec 0c             	sub    $0xc,%esp
80103be3:	56                   	push   %esi
80103be4:	e8 76 01 00 00       	call   80103d5f <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
80103be9:	83 c4 10             	add    $0x10,%esp
80103bec:	83 3b 00             	cmpl   $0x0,(%ebx)
80103bef:	75 17                	jne    80103c08 <holdingsleep+0x33>
80103bf1:	bb 00 00 00 00       	mov    $0x0,%ebx
  release(&lk->lk);
80103bf6:	83 ec 0c             	sub    $0xc,%esp
80103bf9:	56                   	push   %esi
80103bfa:	e8 c5 01 00 00       	call   80103dc4 <release>
  return r;
}
80103bff:	89 d8                	mov    %ebx,%eax
80103c01:	8d 65 f8             	lea    -0x8(%ebp),%esp
80103c04:	5b                   	pop    %ebx
80103c05:	5e                   	pop    %esi
80103c06:	5d                   	pop    %ebp
80103c07:	c3                   	ret    
  r = lk->locked && (lk->pid == myproc()->pid);
80103c08:	8b 5b 3c             	mov    0x3c(%ebx),%ebx
80103c0b:	e8 b0 f7 ff ff       	call   801033c0 <myproc>
80103c10:	3b 58 10             	cmp    0x10(%eax),%ebx
80103c13:	74 07                	je     80103c1c <holdingsleep+0x47>
80103c15:	bb 00 00 00 00       	mov    $0x0,%ebx
80103c1a:	eb da                	jmp    80103bf6 <holdingsleep+0x21>
80103c1c:	bb 01 00 00 00       	mov    $0x1,%ebx
80103c21:	eb d3                	jmp    80103bf6 <holdingsleep+0x21>

80103c23 <initlock>:
#include "proc.h"
#include "spinlock.h"

void
initlock(struct spinlock *lk, char *name)
{
80103c23:	55                   	push   %ebp
80103c24:	89 e5                	mov    %esp,%ebp
80103c26:	8b 45 08             	mov    0x8(%ebp),%eax
  lk->name = name;
80103c29:	8b 55 0c             	mov    0xc(%ebp),%edx
80103c2c:	89 50 04             	mov    %edx,0x4(%eax)
  lk->locked = 0;
80103c2f:	c7 00 00 00 00 00    	movl   $0x0,(%eax)
  lk->cpu = 0;
80103c35:	c7 40 08 00 00 00 00 	movl   $0x0,0x8(%eax)
}
80103c3c:	5d                   	pop    %ebp
80103c3d:	c3                   	ret    

80103c3e <getcallerpcs>:
}

// Record the current call stack in pcs[] by following the %ebp chain.
void
getcallerpcs(void *v, uint pcs[])
{
80103c3e:	55                   	push   %ebp
80103c3f:	89 e5                	mov    %esp,%ebp
80103c41:	53                   	push   %ebx
80103c42:	8b 4d 0c             	mov    0xc(%ebp),%ecx
  uint *ebp;
  int i;

  ebp = (uint*)v - 2;
80103c45:	8b 45 08             	mov    0x8(%ebp),%eax
80103c48:	8d 50 f8             	lea    -0x8(%eax),%edx
  for(i = 0; i < 10; i++){
80103c4b:	b8 00 00 00 00       	mov    $0x0,%eax
80103c50:	83 f8 09             	cmp    $0x9,%eax
80103c53:	7f 25                	jg     80103c7a <getcallerpcs+0x3c>
    if(ebp == 0 || ebp < (uint*)KERNBASE || ebp == (uint*)0xffffffff)
80103c55:	8d 9a 00 00 00 80    	lea    -0x80000000(%edx),%ebx
80103c5b:	81 fb fe ff ff 7f    	cmp    $0x7ffffffe,%ebx
80103c61:	77 17                	ja     80103c7a <getcallerpcs+0x3c>
      break;
    pcs[i] = ebp[1];     // saved %eip
80103c63:	8b 5a 04             	mov    0x4(%edx),%ebx
80103c66:	89 1c 81             	mov    %ebx,(%ecx,%eax,4)
    ebp = (uint*)ebp[0]; // saved %ebp
80103c69:	8b 12                	mov    (%edx),%edx
  for(i = 0; i < 10; i++){
80103c6b:	83 c0 01             	add    $0x1,%eax
80103c6e:	eb e0                	jmp    80103c50 <getcallerpcs+0x12>
  }
  for(; i < 10; i++)
    pcs[i] = 0;
80103c70:	c7 04 81 00 00 00 00 	movl   $0x0,(%ecx,%eax,4)
  for(; i < 10; i++)
80103c77:	83 c0 01             	add    $0x1,%eax
80103c7a:	83 f8 09             	cmp    $0x9,%eax
80103c7d:	7e f1                	jle    80103c70 <getcallerpcs+0x32>
}
80103c7f:	5b                   	pop    %ebx
80103c80:	5d                   	pop    %ebp
80103c81:	c3                   	ret    

80103c82 <pushcli>:
// it takes two popcli to undo two pushcli.  Also, if interrupts
// are off, then pushcli, popcli leaves them off.

void
pushcli(void)
{
80103c82:	55                   	push   %ebp
80103c83:	89 e5                	mov    %esp,%ebp
80103c85:	53                   	push   %ebx
80103c86:	83 ec 04             	sub    $0x4,%esp
80103c89:	9c                   	pushf  
80103c8a:	5b                   	pop    %ebx
  asm volatile("cli");
80103c8b:	fa                   	cli    
  int eflags;

  eflags = readeflags();
  cli();
  if(mycpu()->ncli == 0)
80103c8c:	e8 b8 f6 ff ff       	call   80103349 <mycpu>
80103c91:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103c98:	74 12                	je     80103cac <pushcli+0x2a>
    mycpu()->intena = eflags & FL_IF;
  mycpu()->ncli += 1;
80103c9a:	e8 aa f6 ff ff       	call   80103349 <mycpu>
80103c9f:	83 80 a4 00 00 00 01 	addl   $0x1,0xa4(%eax)
}
80103ca6:	83 c4 04             	add    $0x4,%esp
80103ca9:	5b                   	pop    %ebx
80103caa:	5d                   	pop    %ebp
80103cab:	c3                   	ret    
    mycpu()->intena = eflags & FL_IF;
80103cac:	e8 98 f6 ff ff       	call   80103349 <mycpu>
80103cb1:	81 e3 00 02 00 00    	and    $0x200,%ebx
80103cb7:	89 98 a8 00 00 00    	mov    %ebx,0xa8(%eax)
80103cbd:	eb db                	jmp    80103c9a <pushcli+0x18>

80103cbf <popcli>:

void
popcli(void)
{
80103cbf:	55                   	push   %ebp
80103cc0:	89 e5                	mov    %esp,%ebp
80103cc2:	83 ec 08             	sub    $0x8,%esp
  asm volatile("pushfl; popl %0" : "=r" (eflags));
80103cc5:	9c                   	pushf  
80103cc6:	58                   	pop    %eax
  if(readeflags()&FL_IF)
80103cc7:	f6 c4 02             	test   $0x2,%ah
80103cca:	75 28                	jne    80103cf4 <popcli+0x35>
    panic("popcli - interruptible");
  if(--mycpu()->ncli < 0)
80103ccc:	e8 78 f6 ff ff       	call   80103349 <mycpu>
80103cd1:	8b 88 a4 00 00 00    	mov    0xa4(%eax),%ecx
80103cd7:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103cda:	89 90 a4 00 00 00    	mov    %edx,0xa4(%eax)
80103ce0:	85 d2                	test   %edx,%edx
80103ce2:	78 1d                	js     80103d01 <popcli+0x42>
    panic("popcli");
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103ce4:	e8 60 f6 ff ff       	call   80103349 <mycpu>
80103ce9:	83 b8 a4 00 00 00 00 	cmpl   $0x0,0xa4(%eax)
80103cf0:	74 1c                	je     80103d0e <popcli+0x4f>
    sti();
}
80103cf2:	c9                   	leave  
80103cf3:	c3                   	ret    
    panic("popcli - interruptible");
80103cf4:	83 ec 0c             	sub    $0xc,%esp
80103cf7:	68 a3 6d 10 80       	push   $0x80106da3
80103cfc:	e8 47 c6 ff ff       	call   80100348 <panic>
    panic("popcli");
80103d01:	83 ec 0c             	sub    $0xc,%esp
80103d04:	68 ba 6d 10 80       	push   $0x80106dba
80103d09:	e8 3a c6 ff ff       	call   80100348 <panic>
  if(mycpu()->ncli == 0 && mycpu()->intena)
80103d0e:	e8 36 f6 ff ff       	call   80103349 <mycpu>
80103d13:	83 b8 a8 00 00 00 00 	cmpl   $0x0,0xa8(%eax)
80103d1a:	74 d6                	je     80103cf2 <popcli+0x33>
  asm volatile("sti");
80103d1c:	fb                   	sti    
}
80103d1d:	eb d3                	jmp    80103cf2 <popcli+0x33>

80103d1f <holding>:
{
80103d1f:	55                   	push   %ebp
80103d20:	89 e5                	mov    %esp,%ebp
80103d22:	53                   	push   %ebx
80103d23:	83 ec 04             	sub    $0x4,%esp
80103d26:	8b 5d 08             	mov    0x8(%ebp),%ebx
  pushcli();
80103d29:	e8 54 ff ff ff       	call   80103c82 <pushcli>
  r = lock->locked && lock->cpu == mycpu();
80103d2e:	83 3b 00             	cmpl   $0x0,(%ebx)
80103d31:	75 12                	jne    80103d45 <holding+0x26>
80103d33:	bb 00 00 00 00       	mov    $0x0,%ebx
  popcli();
80103d38:	e8 82 ff ff ff       	call   80103cbf <popcli>
}
80103d3d:	89 d8                	mov    %ebx,%eax
80103d3f:	83 c4 04             	add    $0x4,%esp
80103d42:	5b                   	pop    %ebx
80103d43:	5d                   	pop    %ebp
80103d44:	c3                   	ret    
  r = lock->locked && lock->cpu == mycpu();
80103d45:	8b 5b 08             	mov    0x8(%ebx),%ebx
80103d48:	e8 fc f5 ff ff       	call   80103349 <mycpu>
80103d4d:	39 c3                	cmp    %eax,%ebx
80103d4f:	74 07                	je     80103d58 <holding+0x39>
80103d51:	bb 00 00 00 00       	mov    $0x0,%ebx
80103d56:	eb e0                	jmp    80103d38 <holding+0x19>
80103d58:	bb 01 00 00 00       	mov    $0x1,%ebx
80103d5d:	eb d9                	jmp    80103d38 <holding+0x19>

80103d5f <acquire>:
{
80103d5f:	55                   	push   %ebp
80103d60:	89 e5                	mov    %esp,%ebp
80103d62:	53                   	push   %ebx
80103d63:	83 ec 04             	sub    $0x4,%esp
  pushcli(); // disable interrupts to avoid deadlock.
80103d66:	e8 17 ff ff ff       	call   80103c82 <pushcli>
  if(holding(lk))
80103d6b:	83 ec 0c             	sub    $0xc,%esp
80103d6e:	ff 75 08             	pushl  0x8(%ebp)
80103d71:	e8 a9 ff ff ff       	call   80103d1f <holding>
80103d76:	83 c4 10             	add    $0x10,%esp
80103d79:	85 c0                	test   %eax,%eax
80103d7b:	75 3a                	jne    80103db7 <acquire+0x58>
  while(xchg(&lk->locked, 1) != 0)
80103d7d:	8b 55 08             	mov    0x8(%ebp),%edx
  asm volatile("lock; xchgl %0, %1" :
80103d80:	b8 01 00 00 00       	mov    $0x1,%eax
80103d85:	f0 87 02             	lock xchg %eax,(%edx)
80103d88:	85 c0                	test   %eax,%eax
80103d8a:	75 f1                	jne    80103d7d <acquire+0x1e>
  __sync_synchronize();
80103d8c:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  lk->cpu = mycpu();
80103d91:	8b 5d 08             	mov    0x8(%ebp),%ebx
80103d94:	e8 b0 f5 ff ff       	call   80103349 <mycpu>
80103d99:	89 43 08             	mov    %eax,0x8(%ebx)
  getcallerpcs(&lk, lk->pcs);
80103d9c:	8b 45 08             	mov    0x8(%ebp),%eax
80103d9f:	83 c0 0c             	add    $0xc,%eax
80103da2:	83 ec 08             	sub    $0x8,%esp
80103da5:	50                   	push   %eax
80103da6:	8d 45 08             	lea    0x8(%ebp),%eax
80103da9:	50                   	push   %eax
80103daa:	e8 8f fe ff ff       	call   80103c3e <getcallerpcs>
}
80103daf:	83 c4 10             	add    $0x10,%esp
80103db2:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103db5:	c9                   	leave  
80103db6:	c3                   	ret    
    panic("acquire");
80103db7:	83 ec 0c             	sub    $0xc,%esp
80103dba:	68 c1 6d 10 80       	push   $0x80106dc1
80103dbf:	e8 84 c5 ff ff       	call   80100348 <panic>

80103dc4 <release>:
{
80103dc4:	55                   	push   %ebp
80103dc5:	89 e5                	mov    %esp,%ebp
80103dc7:	53                   	push   %ebx
80103dc8:	83 ec 10             	sub    $0x10,%esp
80103dcb:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(!holding(lk))
80103dce:	53                   	push   %ebx
80103dcf:	e8 4b ff ff ff       	call   80103d1f <holding>
80103dd4:	83 c4 10             	add    $0x10,%esp
80103dd7:	85 c0                	test   %eax,%eax
80103dd9:	74 23                	je     80103dfe <release+0x3a>
  lk->pcs[0] = 0;
80103ddb:	c7 43 0c 00 00 00 00 	movl   $0x0,0xc(%ebx)
  lk->cpu = 0;
80103de2:	c7 43 08 00 00 00 00 	movl   $0x0,0x8(%ebx)
  __sync_synchronize();
80103de9:	f0 83 0c 24 00       	lock orl $0x0,(%esp)
  asm volatile("movl $0, %0" : "+m" (lk->locked) : );
80103dee:	c7 03 00 00 00 00    	movl   $0x0,(%ebx)
  popcli();
80103df4:	e8 c6 fe ff ff       	call   80103cbf <popcli>
}
80103df9:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80103dfc:	c9                   	leave  
80103dfd:	c3                   	ret    
    panic("release");
80103dfe:	83 ec 0c             	sub    $0xc,%esp
80103e01:	68 c9 6d 10 80       	push   $0x80106dc9
80103e06:	e8 3d c5 ff ff       	call   80100348 <panic>

80103e0b <memset>:
#include "types.h"
#include "x86.h"

void*
memset(void *dst, int c, uint n)
{
80103e0b:	55                   	push   %ebp
80103e0c:	89 e5                	mov    %esp,%ebp
80103e0e:	57                   	push   %edi
80103e0f:	53                   	push   %ebx
80103e10:	8b 55 08             	mov    0x8(%ebp),%edx
80103e13:	8b 4d 10             	mov    0x10(%ebp),%ecx
  if ((int)dst%4 == 0 && n%4 == 0){
80103e16:	f6 c2 03             	test   $0x3,%dl
80103e19:	75 05                	jne    80103e20 <memset+0x15>
80103e1b:	f6 c1 03             	test   $0x3,%cl
80103e1e:	74 0e                	je     80103e2e <memset+0x23>
  asm volatile("cld; rep stosb" :
80103e20:	89 d7                	mov    %edx,%edi
80103e22:	8b 45 0c             	mov    0xc(%ebp),%eax
80103e25:	fc                   	cld    
80103e26:	f3 aa                	rep stos %al,%es:(%edi)
    c &= 0xFF;
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
  } else
    stosb(dst, c, n);
  return dst;
}
80103e28:	89 d0                	mov    %edx,%eax
80103e2a:	5b                   	pop    %ebx
80103e2b:	5f                   	pop    %edi
80103e2c:	5d                   	pop    %ebp
80103e2d:	c3                   	ret    
    c &= 0xFF;
80103e2e:	0f b6 7d 0c          	movzbl 0xc(%ebp),%edi
    stosl(dst, (c<<24)|(c<<16)|(c<<8)|c, n/4);
80103e32:	c1 e9 02             	shr    $0x2,%ecx
80103e35:	89 f8                	mov    %edi,%eax
80103e37:	c1 e0 18             	shl    $0x18,%eax
80103e3a:	89 fb                	mov    %edi,%ebx
80103e3c:	c1 e3 10             	shl    $0x10,%ebx
80103e3f:	09 d8                	or     %ebx,%eax
80103e41:	89 fb                	mov    %edi,%ebx
80103e43:	c1 e3 08             	shl    $0x8,%ebx
80103e46:	09 d8                	or     %ebx,%eax
80103e48:	09 f8                	or     %edi,%eax
  asm volatile("cld; rep stosl" :
80103e4a:	89 d7                	mov    %edx,%edi
80103e4c:	fc                   	cld    
80103e4d:	f3 ab                	rep stos %eax,%es:(%edi)
80103e4f:	eb d7                	jmp    80103e28 <memset+0x1d>

80103e51 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
80103e51:	55                   	push   %ebp
80103e52:	89 e5                	mov    %esp,%ebp
80103e54:	56                   	push   %esi
80103e55:	53                   	push   %ebx
80103e56:	8b 4d 08             	mov    0x8(%ebp),%ecx
80103e59:	8b 55 0c             	mov    0xc(%ebp),%edx
80103e5c:	8b 45 10             	mov    0x10(%ebp),%eax
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
80103e5f:	8d 70 ff             	lea    -0x1(%eax),%esi
80103e62:	85 c0                	test   %eax,%eax
80103e64:	74 1c                	je     80103e82 <memcmp+0x31>
    if(*s1 != *s2)
80103e66:	0f b6 01             	movzbl (%ecx),%eax
80103e69:	0f b6 1a             	movzbl (%edx),%ebx
80103e6c:	38 d8                	cmp    %bl,%al
80103e6e:	75 0a                	jne    80103e7a <memcmp+0x29>
      return *s1 - *s2;
    s1++, s2++;
80103e70:	83 c1 01             	add    $0x1,%ecx
80103e73:	83 c2 01             	add    $0x1,%edx
  while(n-- > 0){
80103e76:	89 f0                	mov    %esi,%eax
80103e78:	eb e5                	jmp    80103e5f <memcmp+0xe>
      return *s1 - *s2;
80103e7a:	0f b6 c0             	movzbl %al,%eax
80103e7d:	0f b6 db             	movzbl %bl,%ebx
80103e80:	29 d8                	sub    %ebx,%eax
  }

  return 0;
}
80103e82:	5b                   	pop    %ebx
80103e83:	5e                   	pop    %esi
80103e84:	5d                   	pop    %ebp
80103e85:	c3                   	ret    

80103e86 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
80103e86:	55                   	push   %ebp
80103e87:	89 e5                	mov    %esp,%ebp
80103e89:	56                   	push   %esi
80103e8a:	53                   	push   %ebx
80103e8b:	8b 45 08             	mov    0x8(%ebp),%eax
80103e8e:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103e91:	8b 55 10             	mov    0x10(%ebp),%edx
  const char *s;
  char *d;

  s = src;
  d = dst;
  if(s < d && s + n > d){
80103e94:	39 c1                	cmp    %eax,%ecx
80103e96:	73 3a                	jae    80103ed2 <memmove+0x4c>
80103e98:	8d 1c 11             	lea    (%ecx,%edx,1),%ebx
80103e9b:	39 c3                	cmp    %eax,%ebx
80103e9d:	76 37                	jbe    80103ed6 <memmove+0x50>
    s += n;
    d += n;
80103e9f:	8d 0c 10             	lea    (%eax,%edx,1),%ecx
    while(n-- > 0)
80103ea2:	eb 0d                	jmp    80103eb1 <memmove+0x2b>
      *--d = *--s;
80103ea4:	83 eb 01             	sub    $0x1,%ebx
80103ea7:	83 e9 01             	sub    $0x1,%ecx
80103eaa:	0f b6 13             	movzbl (%ebx),%edx
80103ead:	88 11                	mov    %dl,(%ecx)
    while(n-- > 0)
80103eaf:	89 f2                	mov    %esi,%edx
80103eb1:	8d 72 ff             	lea    -0x1(%edx),%esi
80103eb4:	85 d2                	test   %edx,%edx
80103eb6:	75 ec                	jne    80103ea4 <memmove+0x1e>
80103eb8:	eb 14                	jmp    80103ece <memmove+0x48>
  } else
    while(n-- > 0)
      *d++ = *s++;
80103eba:	0f b6 11             	movzbl (%ecx),%edx
80103ebd:	88 13                	mov    %dl,(%ebx)
80103ebf:	8d 5b 01             	lea    0x1(%ebx),%ebx
80103ec2:	8d 49 01             	lea    0x1(%ecx),%ecx
    while(n-- > 0)
80103ec5:	89 f2                	mov    %esi,%edx
80103ec7:	8d 72 ff             	lea    -0x1(%edx),%esi
80103eca:	85 d2                	test   %edx,%edx
80103ecc:	75 ec                	jne    80103eba <memmove+0x34>

  return dst;
}
80103ece:	5b                   	pop    %ebx
80103ecf:	5e                   	pop    %esi
80103ed0:	5d                   	pop    %ebp
80103ed1:	c3                   	ret    
80103ed2:	89 c3                	mov    %eax,%ebx
80103ed4:	eb f1                	jmp    80103ec7 <memmove+0x41>
80103ed6:	89 c3                	mov    %eax,%ebx
80103ed8:	eb ed                	jmp    80103ec7 <memmove+0x41>

80103eda <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
80103eda:	55                   	push   %ebp
80103edb:	89 e5                	mov    %esp,%ebp
  return memmove(dst, src, n);
80103edd:	ff 75 10             	pushl  0x10(%ebp)
80103ee0:	ff 75 0c             	pushl  0xc(%ebp)
80103ee3:	ff 75 08             	pushl  0x8(%ebp)
80103ee6:	e8 9b ff ff ff       	call   80103e86 <memmove>
}
80103eeb:	c9                   	leave  
80103eec:	c3                   	ret    

80103eed <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
80103eed:	55                   	push   %ebp
80103eee:	89 e5                	mov    %esp,%ebp
80103ef0:	53                   	push   %ebx
80103ef1:	8b 55 08             	mov    0x8(%ebp),%edx
80103ef4:	8b 4d 0c             	mov    0xc(%ebp),%ecx
80103ef7:	8b 45 10             	mov    0x10(%ebp),%eax
  while(n > 0 && *p && *p == *q)
80103efa:	eb 09                	jmp    80103f05 <strncmp+0x18>
    n--, p++, q++;
80103efc:	83 e8 01             	sub    $0x1,%eax
80103eff:	83 c2 01             	add    $0x1,%edx
80103f02:	83 c1 01             	add    $0x1,%ecx
  while(n > 0 && *p && *p == *q)
80103f05:	85 c0                	test   %eax,%eax
80103f07:	74 0b                	je     80103f14 <strncmp+0x27>
80103f09:	0f b6 1a             	movzbl (%edx),%ebx
80103f0c:	84 db                	test   %bl,%bl
80103f0e:	74 04                	je     80103f14 <strncmp+0x27>
80103f10:	3a 19                	cmp    (%ecx),%bl
80103f12:	74 e8                	je     80103efc <strncmp+0xf>
  if(n == 0)
80103f14:	85 c0                	test   %eax,%eax
80103f16:	74 0b                	je     80103f23 <strncmp+0x36>
    return 0;
  return (uchar)*p - (uchar)*q;
80103f18:	0f b6 02             	movzbl (%edx),%eax
80103f1b:	0f b6 11             	movzbl (%ecx),%edx
80103f1e:	29 d0                	sub    %edx,%eax
}
80103f20:	5b                   	pop    %ebx
80103f21:	5d                   	pop    %ebp
80103f22:	c3                   	ret    
    return 0;
80103f23:	b8 00 00 00 00       	mov    $0x0,%eax
80103f28:	eb f6                	jmp    80103f20 <strncmp+0x33>

80103f2a <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
80103f2a:	55                   	push   %ebp
80103f2b:	89 e5                	mov    %esp,%ebp
80103f2d:	57                   	push   %edi
80103f2e:	56                   	push   %esi
80103f2f:	53                   	push   %ebx
80103f30:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f33:	8b 4d 10             	mov    0x10(%ebp),%ecx
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
80103f36:	8b 45 08             	mov    0x8(%ebp),%eax
80103f39:	eb 04                	jmp    80103f3f <strncpy+0x15>
80103f3b:	89 fb                	mov    %edi,%ebx
80103f3d:	89 f0                	mov    %esi,%eax
80103f3f:	8d 51 ff             	lea    -0x1(%ecx),%edx
80103f42:	85 c9                	test   %ecx,%ecx
80103f44:	7e 1d                	jle    80103f63 <strncpy+0x39>
80103f46:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f49:	8d 70 01             	lea    0x1(%eax),%esi
80103f4c:	0f b6 1b             	movzbl (%ebx),%ebx
80103f4f:	88 18                	mov    %bl,(%eax)
80103f51:	89 d1                	mov    %edx,%ecx
80103f53:	84 db                	test   %bl,%bl
80103f55:	75 e4                	jne    80103f3b <strncpy+0x11>
80103f57:	89 f0                	mov    %esi,%eax
80103f59:	eb 08                	jmp    80103f63 <strncpy+0x39>
    ;
  while(n-- > 0)
    *s++ = 0;
80103f5b:	c6 00 00             	movb   $0x0,(%eax)
  while(n-- > 0)
80103f5e:	89 ca                	mov    %ecx,%edx
    *s++ = 0;
80103f60:	8d 40 01             	lea    0x1(%eax),%eax
  while(n-- > 0)
80103f63:	8d 4a ff             	lea    -0x1(%edx),%ecx
80103f66:	85 d2                	test   %edx,%edx
80103f68:	7f f1                	jg     80103f5b <strncpy+0x31>
  return os;
}
80103f6a:	8b 45 08             	mov    0x8(%ebp),%eax
80103f6d:	5b                   	pop    %ebx
80103f6e:	5e                   	pop    %esi
80103f6f:	5f                   	pop    %edi
80103f70:	5d                   	pop    %ebp
80103f71:	c3                   	ret    

80103f72 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
80103f72:	55                   	push   %ebp
80103f73:	89 e5                	mov    %esp,%ebp
80103f75:	57                   	push   %edi
80103f76:	56                   	push   %esi
80103f77:	53                   	push   %ebx
80103f78:	8b 45 08             	mov    0x8(%ebp),%eax
80103f7b:	8b 5d 0c             	mov    0xc(%ebp),%ebx
80103f7e:	8b 55 10             	mov    0x10(%ebp),%edx
  char *os;

  os = s;
  if(n <= 0)
80103f81:	85 d2                	test   %edx,%edx
80103f83:	7e 23                	jle    80103fa8 <safestrcpy+0x36>
80103f85:	89 c1                	mov    %eax,%ecx
80103f87:	eb 04                	jmp    80103f8d <safestrcpy+0x1b>
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
80103f89:	89 fb                	mov    %edi,%ebx
80103f8b:	89 f1                	mov    %esi,%ecx
80103f8d:	83 ea 01             	sub    $0x1,%edx
80103f90:	85 d2                	test   %edx,%edx
80103f92:	7e 11                	jle    80103fa5 <safestrcpy+0x33>
80103f94:	8d 7b 01             	lea    0x1(%ebx),%edi
80103f97:	8d 71 01             	lea    0x1(%ecx),%esi
80103f9a:	0f b6 1b             	movzbl (%ebx),%ebx
80103f9d:	88 19                	mov    %bl,(%ecx)
80103f9f:	84 db                	test   %bl,%bl
80103fa1:	75 e6                	jne    80103f89 <safestrcpy+0x17>
80103fa3:	89 f1                	mov    %esi,%ecx
    ;
  *s = 0;
80103fa5:	c6 01 00             	movb   $0x0,(%ecx)
  return os;
}
80103fa8:	5b                   	pop    %ebx
80103fa9:	5e                   	pop    %esi
80103faa:	5f                   	pop    %edi
80103fab:	5d                   	pop    %ebp
80103fac:	c3                   	ret    

80103fad <strlen>:

int
strlen(const char *s)
{
80103fad:	55                   	push   %ebp
80103fae:	89 e5                	mov    %esp,%ebp
80103fb0:	8b 55 08             	mov    0x8(%ebp),%edx
  int n;

  for(n = 0; s[n]; n++)
80103fb3:	b8 00 00 00 00       	mov    $0x0,%eax
80103fb8:	eb 03                	jmp    80103fbd <strlen+0x10>
80103fba:	83 c0 01             	add    $0x1,%eax
80103fbd:	80 3c 02 00          	cmpb   $0x0,(%edx,%eax,1)
80103fc1:	75 f7                	jne    80103fba <strlen+0xd>
    ;
  return n;
}
80103fc3:	5d                   	pop    %ebp
80103fc4:	c3                   	ret    

80103fc5 <swtch>:
# a struct context, and save its address in *old.
# Switch stacks to new and pop previously-saved registers.

.globl swtch
swtch:
  movl 4(%esp), %eax
80103fc5:	8b 44 24 04          	mov    0x4(%esp),%eax
  movl 8(%esp), %edx
80103fc9:	8b 54 24 08          	mov    0x8(%esp),%edx

  # Save old callee-saved registers
  pushl %ebp
80103fcd:	55                   	push   %ebp
  pushl %ebx
80103fce:	53                   	push   %ebx
  pushl %esi
80103fcf:	56                   	push   %esi
  pushl %edi
80103fd0:	57                   	push   %edi

  # Switch stacks
  movl %esp, (%eax)
80103fd1:	89 20                	mov    %esp,(%eax)
  movl %edx, %esp
80103fd3:	89 d4                	mov    %edx,%esp

  # Load new callee-saved registers
  popl %edi
80103fd5:	5f                   	pop    %edi
  popl %esi
80103fd6:	5e                   	pop    %esi
  popl %ebx
80103fd7:	5b                   	pop    %ebx
  popl %ebp
80103fd8:	5d                   	pop    %ebp
  ret
80103fd9:	c3                   	ret    

80103fda <fetchint>:
// to a saved program counter, and then the first argument.

// Fetch the int at addr from the current process.
int
fetchint(uint addr, int *ip)
{
80103fda:	55                   	push   %ebp
80103fdb:	89 e5                	mov    %esp,%ebp
80103fdd:	53                   	push   %ebx
80103fde:	83 ec 04             	sub    $0x4,%esp
80103fe1:	8b 5d 08             	mov    0x8(%ebp),%ebx
  struct proc *curproc = myproc();
80103fe4:	e8 d7 f3 ff ff       	call   801033c0 <myproc>

  if(addr >= curproc->sz || addr+4 > curproc->sz)
80103fe9:	8b 00                	mov    (%eax),%eax
80103feb:	39 d8                	cmp    %ebx,%eax
80103fed:	76 19                	jbe    80104008 <fetchint+0x2e>
80103fef:	8d 53 04             	lea    0x4(%ebx),%edx
80103ff2:	39 d0                	cmp    %edx,%eax
80103ff4:	72 19                	jb     8010400f <fetchint+0x35>
    return -1;
  *ip = *(int*)(addr);
80103ff6:	8b 13                	mov    (%ebx),%edx
80103ff8:	8b 45 0c             	mov    0xc(%ebp),%eax
80103ffb:	89 10                	mov    %edx,(%eax)
  return 0;
80103ffd:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104002:	83 c4 04             	add    $0x4,%esp
80104005:	5b                   	pop    %ebx
80104006:	5d                   	pop    %ebp
80104007:	c3                   	ret    
    return -1;
80104008:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010400d:	eb f3                	jmp    80104002 <fetchint+0x28>
8010400f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104014:	eb ec                	jmp    80104002 <fetchint+0x28>

80104016 <fetchstr>:
// Fetch the nul-terminated string at addr from the current process.
// Doesn't actually copy the string - just sets *pp to point at it.
// Returns length of string, not including nul.
int
fetchstr(uint addr, char **pp)
{
80104016:	55                   	push   %ebp
80104017:	89 e5                	mov    %esp,%ebp
80104019:	53                   	push   %ebx
8010401a:	83 ec 04             	sub    $0x4,%esp
8010401d:	8b 5d 08             	mov    0x8(%ebp),%ebx
  char *s, *ep;
  struct proc *curproc = myproc();
80104020:	e8 9b f3 ff ff       	call   801033c0 <myproc>

  if(addr >= curproc->sz)
80104025:	39 18                	cmp    %ebx,(%eax)
80104027:	76 26                	jbe    8010404f <fetchstr+0x39>
    return -1;
  *pp = (char*)addr;
80104029:	8b 55 0c             	mov    0xc(%ebp),%edx
8010402c:	89 1a                	mov    %ebx,(%edx)
  ep = (char*)curproc->sz;
8010402e:	8b 10                	mov    (%eax),%edx
  for(s = *pp; s < ep; s++){
80104030:	89 d8                	mov    %ebx,%eax
80104032:	39 d0                	cmp    %edx,%eax
80104034:	73 0e                	jae    80104044 <fetchstr+0x2e>
    if(*s == 0)
80104036:	80 38 00             	cmpb   $0x0,(%eax)
80104039:	74 05                	je     80104040 <fetchstr+0x2a>
  for(s = *pp; s < ep; s++){
8010403b:	83 c0 01             	add    $0x1,%eax
8010403e:	eb f2                	jmp    80104032 <fetchstr+0x1c>
      return s - *pp;
80104040:	29 d8                	sub    %ebx,%eax
80104042:	eb 05                	jmp    80104049 <fetchstr+0x33>
  }
  return -1;
80104044:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104049:	83 c4 04             	add    $0x4,%esp
8010404c:	5b                   	pop    %ebx
8010404d:	5d                   	pop    %ebp
8010404e:	c3                   	ret    
    return -1;
8010404f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104054:	eb f3                	jmp    80104049 <fetchstr+0x33>

80104056 <argint>:

// Fetch the nth 32-bit system call argument.
int
argint(int n, int *ip)
{
80104056:	55                   	push   %ebp
80104057:	89 e5                	mov    %esp,%ebp
80104059:	83 ec 08             	sub    $0x8,%esp
  return fetchint((myproc()->tf->esp) + 4 + 4*n, ip);
8010405c:	e8 5f f3 ff ff       	call   801033c0 <myproc>
80104061:	8b 50 18             	mov    0x18(%eax),%edx
80104064:	8b 45 08             	mov    0x8(%ebp),%eax
80104067:	c1 e0 02             	shl    $0x2,%eax
8010406a:	03 42 44             	add    0x44(%edx),%eax
8010406d:	83 ec 08             	sub    $0x8,%esp
80104070:	ff 75 0c             	pushl  0xc(%ebp)
80104073:	83 c0 04             	add    $0x4,%eax
80104076:	50                   	push   %eax
80104077:	e8 5e ff ff ff       	call   80103fda <fetchint>
}
8010407c:	c9                   	leave  
8010407d:	c3                   	ret    

8010407e <argptr>:
// Fetch the nth word-sized system call argument as a pointer
// to a block of memory of size bytes.  Check that the pointer
// lies within the process address space.
int
argptr(int n, char **pp, int size)
{
8010407e:	55                   	push   %ebp
8010407f:	89 e5                	mov    %esp,%ebp
80104081:	56                   	push   %esi
80104082:	53                   	push   %ebx
80104083:	83 ec 10             	sub    $0x10,%esp
80104086:	8b 5d 10             	mov    0x10(%ebp),%ebx
  int i;
  struct proc *curproc = myproc();
80104089:	e8 32 f3 ff ff       	call   801033c0 <myproc>
8010408e:	89 c6                	mov    %eax,%esi
 
  if(argint(n, &i) < 0)
80104090:	83 ec 08             	sub    $0x8,%esp
80104093:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104096:	50                   	push   %eax
80104097:	ff 75 08             	pushl  0x8(%ebp)
8010409a:	e8 b7 ff ff ff       	call   80104056 <argint>
8010409f:	83 c4 10             	add    $0x10,%esp
801040a2:	85 c0                	test   %eax,%eax
801040a4:	78 24                	js     801040ca <argptr+0x4c>
    return -1;
  if(size < 0 || (uint)i >= curproc->sz || (uint)i+size > curproc->sz)
801040a6:	85 db                	test   %ebx,%ebx
801040a8:	78 27                	js     801040d1 <argptr+0x53>
801040aa:	8b 16                	mov    (%esi),%edx
801040ac:	8b 45 f4             	mov    -0xc(%ebp),%eax
801040af:	39 c2                	cmp    %eax,%edx
801040b1:	76 25                	jbe    801040d8 <argptr+0x5a>
801040b3:	01 c3                	add    %eax,%ebx
801040b5:	39 da                	cmp    %ebx,%edx
801040b7:	72 26                	jb     801040df <argptr+0x61>
    return -1;
  *pp = (char*)i;
801040b9:	8b 55 0c             	mov    0xc(%ebp),%edx
801040bc:	89 02                	mov    %eax,(%edx)
  return 0;
801040be:	b8 00 00 00 00       	mov    $0x0,%eax
}
801040c3:	8d 65 f8             	lea    -0x8(%ebp),%esp
801040c6:	5b                   	pop    %ebx
801040c7:	5e                   	pop    %esi
801040c8:	5d                   	pop    %ebp
801040c9:	c3                   	ret    
    return -1;
801040ca:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040cf:	eb f2                	jmp    801040c3 <argptr+0x45>
    return -1;
801040d1:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040d6:	eb eb                	jmp    801040c3 <argptr+0x45>
801040d8:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040dd:	eb e4                	jmp    801040c3 <argptr+0x45>
801040df:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801040e4:	eb dd                	jmp    801040c3 <argptr+0x45>

801040e6 <argstr>:
// Check that the pointer is valid and the string is nul-terminated.
// (There is no shared writable memory, so the string can't change
// between this check and being used by the kernel.)
int
argstr(int n, char **pp)
{
801040e6:	55                   	push   %ebp
801040e7:	89 e5                	mov    %esp,%ebp
801040e9:	83 ec 20             	sub    $0x20,%esp
  int addr;
  if(argint(n, &addr) < 0)
801040ec:	8d 45 f4             	lea    -0xc(%ebp),%eax
801040ef:	50                   	push   %eax
801040f0:	ff 75 08             	pushl  0x8(%ebp)
801040f3:	e8 5e ff ff ff       	call   80104056 <argint>
801040f8:	83 c4 10             	add    $0x10,%esp
801040fb:	85 c0                	test   %eax,%eax
801040fd:	78 13                	js     80104112 <argstr+0x2c>
    return -1;
  return fetchstr(addr, pp);
801040ff:	83 ec 08             	sub    $0x8,%esp
80104102:	ff 75 0c             	pushl  0xc(%ebp)
80104105:	ff 75 f4             	pushl  -0xc(%ebp)
80104108:	e8 09 ff ff ff       	call   80104016 <fetchstr>
8010410d:	83 c4 10             	add    $0x10,%esp
}
80104110:	c9                   	leave  
80104111:	c3                   	ret    
    return -1;
80104112:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104117:	eb f7                	jmp    80104110 <argstr+0x2a>

80104119 <syscall>:
[SYS_dump_physmem] sys_dump_physmem,
};

void
syscall(void)
{
80104119:	55                   	push   %ebp
8010411a:	89 e5                	mov    %esp,%ebp
8010411c:	53                   	push   %ebx
8010411d:	83 ec 04             	sub    $0x4,%esp
  int num;
  struct proc *curproc = myproc();
80104120:	e8 9b f2 ff ff       	call   801033c0 <myproc>
80104125:	89 c3                	mov    %eax,%ebx

  num = curproc->tf->eax;
80104127:	8b 40 18             	mov    0x18(%eax),%eax
8010412a:	8b 40 1c             	mov    0x1c(%eax),%eax
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
8010412d:	8d 50 ff             	lea    -0x1(%eax),%edx
80104130:	83 fa 15             	cmp    $0x15,%edx
80104133:	77 18                	ja     8010414d <syscall+0x34>
80104135:	8b 14 85 00 6e 10 80 	mov    -0x7fef9200(,%eax,4),%edx
8010413c:	85 d2                	test   %edx,%edx
8010413e:	74 0d                	je     8010414d <syscall+0x34>
    curproc->tf->eax = syscalls[num]();
80104140:	ff d2                	call   *%edx
80104142:	8b 53 18             	mov    0x18(%ebx),%edx
80104145:	89 42 1c             	mov    %eax,0x1c(%edx)
  } else {
    cprintf("%d %s: unknown sys call %d\n",
            curproc->pid, curproc->name, num);
    curproc->tf->eax = -1;
  }
}
80104148:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010414b:	c9                   	leave  
8010414c:	c3                   	ret    
            curproc->pid, curproc->name, num);
8010414d:	8d 53 6c             	lea    0x6c(%ebx),%edx
    cprintf("%d %s: unknown sys call %d\n",
80104150:	50                   	push   %eax
80104151:	52                   	push   %edx
80104152:	ff 73 10             	pushl  0x10(%ebx)
80104155:	68 d1 6d 10 80       	push   $0x80106dd1
8010415a:	e8 ac c4 ff ff       	call   8010060b <cprintf>
    curproc->tf->eax = -1;
8010415f:	8b 43 18             	mov    0x18(%ebx),%eax
80104162:	c7 40 1c ff ff ff ff 	movl   $0xffffffff,0x1c(%eax)
80104169:	83 c4 10             	add    $0x10,%esp
}
8010416c:	eb da                	jmp    80104148 <syscall+0x2f>

8010416e <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
8010416e:	55                   	push   %ebp
8010416f:	89 e5                	mov    %esp,%ebp
80104171:	56                   	push   %esi
80104172:	53                   	push   %ebx
80104173:	83 ec 18             	sub    $0x18,%esp
80104176:	89 d6                	mov    %edx,%esi
80104178:	89 cb                	mov    %ecx,%ebx
  int fd;
  struct file *f;

  if(argint(n, &fd) < 0)
8010417a:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010417d:	52                   	push   %edx
8010417e:	50                   	push   %eax
8010417f:	e8 d2 fe ff ff       	call   80104056 <argint>
80104184:	83 c4 10             	add    $0x10,%esp
80104187:	85 c0                	test   %eax,%eax
80104189:	78 2e                	js     801041b9 <argfd+0x4b>
    return -1;
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
8010418b:	83 7d f4 0f          	cmpl   $0xf,-0xc(%ebp)
8010418f:	77 2f                	ja     801041c0 <argfd+0x52>
80104191:	e8 2a f2 ff ff       	call   801033c0 <myproc>
80104196:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104199:	8b 44 90 28          	mov    0x28(%eax,%edx,4),%eax
8010419d:	85 c0                	test   %eax,%eax
8010419f:	74 26                	je     801041c7 <argfd+0x59>
    return -1;
  if(pfd)
801041a1:	85 f6                	test   %esi,%esi
801041a3:	74 02                	je     801041a7 <argfd+0x39>
    *pfd = fd;
801041a5:	89 16                	mov    %edx,(%esi)
  if(pf)
801041a7:	85 db                	test   %ebx,%ebx
801041a9:	74 23                	je     801041ce <argfd+0x60>
    *pf = f;
801041ab:	89 03                	mov    %eax,(%ebx)
  return 0;
801041ad:	b8 00 00 00 00       	mov    $0x0,%eax
}
801041b2:	8d 65 f8             	lea    -0x8(%ebp),%esp
801041b5:	5b                   	pop    %ebx
801041b6:	5e                   	pop    %esi
801041b7:	5d                   	pop    %ebp
801041b8:	c3                   	ret    
    return -1;
801041b9:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041be:	eb f2                	jmp    801041b2 <argfd+0x44>
    return -1;
801041c0:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041c5:	eb eb                	jmp    801041b2 <argfd+0x44>
801041c7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801041cc:	eb e4                	jmp    801041b2 <argfd+0x44>
  return 0;
801041ce:	b8 00 00 00 00       	mov    $0x0,%eax
801041d3:	eb dd                	jmp    801041b2 <argfd+0x44>

801041d5 <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
801041d5:	55                   	push   %ebp
801041d6:	89 e5                	mov    %esp,%ebp
801041d8:	53                   	push   %ebx
801041d9:	83 ec 04             	sub    $0x4,%esp
801041dc:	89 c3                	mov    %eax,%ebx
  int fd;
  struct proc *curproc = myproc();
801041de:	e8 dd f1 ff ff       	call   801033c0 <myproc>

  for(fd = 0; fd < NOFILE; fd++){
801041e3:	ba 00 00 00 00       	mov    $0x0,%edx
801041e8:	83 fa 0f             	cmp    $0xf,%edx
801041eb:	7f 18                	jg     80104205 <fdalloc+0x30>
    if(curproc->ofile[fd] == 0){
801041ed:	83 7c 90 28 00       	cmpl   $0x0,0x28(%eax,%edx,4)
801041f2:	74 05                	je     801041f9 <fdalloc+0x24>
  for(fd = 0; fd < NOFILE; fd++){
801041f4:	83 c2 01             	add    $0x1,%edx
801041f7:	eb ef                	jmp    801041e8 <fdalloc+0x13>
      curproc->ofile[fd] = f;
801041f9:	89 5c 90 28          	mov    %ebx,0x28(%eax,%edx,4)
      return fd;
    }
  }
  return -1;
}
801041fd:	89 d0                	mov    %edx,%eax
801041ff:	83 c4 04             	add    $0x4,%esp
80104202:	5b                   	pop    %ebx
80104203:	5d                   	pop    %ebp
80104204:	c3                   	ret    
  return -1;
80104205:	ba ff ff ff ff       	mov    $0xffffffff,%edx
8010420a:	eb f1                	jmp    801041fd <fdalloc+0x28>

8010420c <isdirempty>:
}

// Is the directory dp empty except for "." and ".." ?
static int
isdirempty(struct inode *dp)
{
8010420c:	55                   	push   %ebp
8010420d:	89 e5                	mov    %esp,%ebp
8010420f:	56                   	push   %esi
80104210:	53                   	push   %ebx
80104211:	83 ec 10             	sub    $0x10,%esp
80104214:	89 c3                	mov    %eax,%ebx
  int off;
  struct dirent de;

  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
80104216:	b8 20 00 00 00       	mov    $0x20,%eax
8010421b:	89 c6                	mov    %eax,%esi
8010421d:	39 43 58             	cmp    %eax,0x58(%ebx)
80104220:	76 2e                	jbe    80104250 <isdirempty+0x44>
    if(readi(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
80104222:	6a 10                	push   $0x10
80104224:	50                   	push   %eax
80104225:	8d 45 e8             	lea    -0x18(%ebp),%eax
80104228:	50                   	push   %eax
80104229:	53                   	push   %ebx
8010422a:	e8 44 d5 ff ff       	call   80101773 <readi>
8010422f:	83 c4 10             	add    $0x10,%esp
80104232:	83 f8 10             	cmp    $0x10,%eax
80104235:	75 0c                	jne    80104243 <isdirempty+0x37>
      panic("isdirempty: readi");
    if(de.inum != 0)
80104237:	66 83 7d e8 00       	cmpw   $0x0,-0x18(%ebp)
8010423c:	75 1e                	jne    8010425c <isdirempty+0x50>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
8010423e:	8d 46 10             	lea    0x10(%esi),%eax
80104241:	eb d8                	jmp    8010421b <isdirempty+0xf>
      panic("isdirempty: readi");
80104243:	83 ec 0c             	sub    $0xc,%esp
80104246:	68 5c 6e 10 80       	push   $0x80106e5c
8010424b:	e8 f8 c0 ff ff       	call   80100348 <panic>
      return 0;
  }
  return 1;
80104250:	b8 01 00 00 00       	mov    $0x1,%eax
}
80104255:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104258:	5b                   	pop    %ebx
80104259:	5e                   	pop    %esi
8010425a:	5d                   	pop    %ebp
8010425b:	c3                   	ret    
      return 0;
8010425c:	b8 00 00 00 00       	mov    $0x0,%eax
80104261:	eb f2                	jmp    80104255 <isdirempty+0x49>

80104263 <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
80104263:	55                   	push   %ebp
80104264:	89 e5                	mov    %esp,%ebp
80104266:	57                   	push   %edi
80104267:	56                   	push   %esi
80104268:	53                   	push   %ebx
80104269:	83 ec 44             	sub    $0x44,%esp
8010426c:	89 55 c4             	mov    %edx,-0x3c(%ebp)
8010426f:	89 4d c0             	mov    %ecx,-0x40(%ebp)
80104272:	8b 7d 08             	mov    0x8(%ebp),%edi
  uint off;
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
80104275:	8d 55 d6             	lea    -0x2a(%ebp),%edx
80104278:	52                   	push   %edx
80104279:	50                   	push   %eax
8010427a:	e8 7a d9 ff ff       	call   80101bf9 <nameiparent>
8010427f:	89 c6                	mov    %eax,%esi
80104281:	83 c4 10             	add    $0x10,%esp
80104284:	85 c0                	test   %eax,%eax
80104286:	0f 84 3a 01 00 00    	je     801043c6 <create+0x163>
    return 0;
  ilock(dp);
8010428c:	83 ec 0c             	sub    $0xc,%esp
8010428f:	50                   	push   %eax
80104290:	e8 ec d2 ff ff       	call   80101581 <ilock>

  if((ip = dirlookup(dp, name, &off)) != 0){
80104295:	83 c4 0c             	add    $0xc,%esp
80104298:	8d 45 e4             	lea    -0x1c(%ebp),%eax
8010429b:	50                   	push   %eax
8010429c:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010429f:	50                   	push   %eax
801042a0:	56                   	push   %esi
801042a1:	e8 0a d7 ff ff       	call   801019b0 <dirlookup>
801042a6:	89 c3                	mov    %eax,%ebx
801042a8:	83 c4 10             	add    $0x10,%esp
801042ab:	85 c0                	test   %eax,%eax
801042ad:	74 3f                	je     801042ee <create+0x8b>
    iunlockput(dp);
801042af:	83 ec 0c             	sub    $0xc,%esp
801042b2:	56                   	push   %esi
801042b3:	e8 70 d4 ff ff       	call   80101728 <iunlockput>
    ilock(ip);
801042b8:	89 1c 24             	mov    %ebx,(%esp)
801042bb:	e8 c1 d2 ff ff       	call   80101581 <ilock>
    if(type == T_FILE && ip->type == T_FILE)
801042c0:	83 c4 10             	add    $0x10,%esp
801042c3:	66 83 7d c4 02       	cmpw   $0x2,-0x3c(%ebp)
801042c8:	75 11                	jne    801042db <create+0x78>
801042ca:	66 83 7b 50 02       	cmpw   $0x2,0x50(%ebx)
801042cf:	75 0a                	jne    801042db <create+0x78>
    panic("create: dirlink");

  iunlockput(dp);

  return ip;
}
801042d1:	89 d8                	mov    %ebx,%eax
801042d3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801042d6:	5b                   	pop    %ebx
801042d7:	5e                   	pop    %esi
801042d8:	5f                   	pop    %edi
801042d9:	5d                   	pop    %ebp
801042da:	c3                   	ret    
    iunlockput(ip);
801042db:	83 ec 0c             	sub    $0xc,%esp
801042de:	53                   	push   %ebx
801042df:	e8 44 d4 ff ff       	call   80101728 <iunlockput>
    return 0;
801042e4:	83 c4 10             	add    $0x10,%esp
801042e7:	bb 00 00 00 00       	mov    $0x0,%ebx
801042ec:	eb e3                	jmp    801042d1 <create+0x6e>
  if((ip = ialloc(dp->dev, type)) == 0)
801042ee:	0f bf 45 c4          	movswl -0x3c(%ebp),%eax
801042f2:	83 ec 08             	sub    $0x8,%esp
801042f5:	50                   	push   %eax
801042f6:	ff 36                	pushl  (%esi)
801042f8:	e8 81 d0 ff ff       	call   8010137e <ialloc>
801042fd:	89 c3                	mov    %eax,%ebx
801042ff:	83 c4 10             	add    $0x10,%esp
80104302:	85 c0                	test   %eax,%eax
80104304:	74 55                	je     8010435b <create+0xf8>
  ilock(ip);
80104306:	83 ec 0c             	sub    $0xc,%esp
80104309:	50                   	push   %eax
8010430a:	e8 72 d2 ff ff       	call   80101581 <ilock>
  ip->major = major;
8010430f:	0f b7 45 c0          	movzwl -0x40(%ebp),%eax
80104313:	66 89 43 52          	mov    %ax,0x52(%ebx)
  ip->minor = minor;
80104317:	66 89 7b 54          	mov    %di,0x54(%ebx)
  ip->nlink = 1;
8010431b:	66 c7 43 56 01 00    	movw   $0x1,0x56(%ebx)
  iupdate(ip);
80104321:	89 1c 24             	mov    %ebx,(%esp)
80104324:	e8 f7 d0 ff ff       	call   80101420 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
80104329:	83 c4 10             	add    $0x10,%esp
8010432c:	66 83 7d c4 01       	cmpw   $0x1,-0x3c(%ebp)
80104331:	74 35                	je     80104368 <create+0x105>
  if(dirlink(dp, name, ip->inum) < 0)
80104333:	83 ec 04             	sub    $0x4,%esp
80104336:	ff 73 04             	pushl  0x4(%ebx)
80104339:	8d 45 d6             	lea    -0x2a(%ebp),%eax
8010433c:	50                   	push   %eax
8010433d:	56                   	push   %esi
8010433e:	e8 ed d7 ff ff       	call   80101b30 <dirlink>
80104343:	83 c4 10             	add    $0x10,%esp
80104346:	85 c0                	test   %eax,%eax
80104348:	78 6f                	js     801043b9 <create+0x156>
  iunlockput(dp);
8010434a:	83 ec 0c             	sub    $0xc,%esp
8010434d:	56                   	push   %esi
8010434e:	e8 d5 d3 ff ff       	call   80101728 <iunlockput>
  return ip;
80104353:	83 c4 10             	add    $0x10,%esp
80104356:	e9 76 ff ff ff       	jmp    801042d1 <create+0x6e>
    panic("create: ialloc");
8010435b:	83 ec 0c             	sub    $0xc,%esp
8010435e:	68 6e 6e 10 80       	push   $0x80106e6e
80104363:	e8 e0 bf ff ff       	call   80100348 <panic>
    dp->nlink++;  // for ".."
80104368:	0f b7 46 56          	movzwl 0x56(%esi),%eax
8010436c:	83 c0 01             	add    $0x1,%eax
8010436f:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
80104373:	83 ec 0c             	sub    $0xc,%esp
80104376:	56                   	push   %esi
80104377:	e8 a4 d0 ff ff       	call   80101420 <iupdate>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
8010437c:	83 c4 0c             	add    $0xc,%esp
8010437f:	ff 73 04             	pushl  0x4(%ebx)
80104382:	68 7e 6e 10 80       	push   $0x80106e7e
80104387:	53                   	push   %ebx
80104388:	e8 a3 d7 ff ff       	call   80101b30 <dirlink>
8010438d:	83 c4 10             	add    $0x10,%esp
80104390:	85 c0                	test   %eax,%eax
80104392:	78 18                	js     801043ac <create+0x149>
80104394:	83 ec 04             	sub    $0x4,%esp
80104397:	ff 76 04             	pushl  0x4(%esi)
8010439a:	68 7d 6e 10 80       	push   $0x80106e7d
8010439f:	53                   	push   %ebx
801043a0:	e8 8b d7 ff ff       	call   80101b30 <dirlink>
801043a5:	83 c4 10             	add    $0x10,%esp
801043a8:	85 c0                	test   %eax,%eax
801043aa:	79 87                	jns    80104333 <create+0xd0>
      panic("create dots");
801043ac:	83 ec 0c             	sub    $0xc,%esp
801043af:	68 80 6e 10 80       	push   $0x80106e80
801043b4:	e8 8f bf ff ff       	call   80100348 <panic>
    panic("create: dirlink");
801043b9:	83 ec 0c             	sub    $0xc,%esp
801043bc:	68 8c 6e 10 80       	push   $0x80106e8c
801043c1:	e8 82 bf ff ff       	call   80100348 <panic>
    return 0;
801043c6:	89 c3                	mov    %eax,%ebx
801043c8:	e9 04 ff ff ff       	jmp    801042d1 <create+0x6e>

801043cd <sys_dup>:
{
801043cd:	55                   	push   %ebp
801043ce:	89 e5                	mov    %esp,%ebp
801043d0:	53                   	push   %ebx
801043d1:	83 ec 14             	sub    $0x14,%esp
  if(argfd(0, 0, &f) < 0)
801043d4:	8d 4d f4             	lea    -0xc(%ebp),%ecx
801043d7:	ba 00 00 00 00       	mov    $0x0,%edx
801043dc:	b8 00 00 00 00       	mov    $0x0,%eax
801043e1:	e8 88 fd ff ff       	call   8010416e <argfd>
801043e6:	85 c0                	test   %eax,%eax
801043e8:	78 23                	js     8010440d <sys_dup+0x40>
  if((fd=fdalloc(f)) < 0)
801043ea:	8b 45 f4             	mov    -0xc(%ebp),%eax
801043ed:	e8 e3 fd ff ff       	call   801041d5 <fdalloc>
801043f2:	89 c3                	mov    %eax,%ebx
801043f4:	85 c0                	test   %eax,%eax
801043f6:	78 1c                	js     80104414 <sys_dup+0x47>
  filedup(f);
801043f8:	83 ec 0c             	sub    $0xc,%esp
801043fb:	ff 75 f4             	pushl  -0xc(%ebp)
801043fe:	e8 8b c8 ff ff       	call   80100c8e <filedup>
  return fd;
80104403:	83 c4 10             	add    $0x10,%esp
}
80104406:	89 d8                	mov    %ebx,%eax
80104408:	8b 5d fc             	mov    -0x4(%ebp),%ebx
8010440b:	c9                   	leave  
8010440c:	c3                   	ret    
    return -1;
8010440d:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104412:	eb f2                	jmp    80104406 <sys_dup+0x39>
    return -1;
80104414:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104419:	eb eb                	jmp    80104406 <sys_dup+0x39>

8010441b <sys_read>:
{
8010441b:	55                   	push   %ebp
8010441c:	89 e5                	mov    %esp,%ebp
8010441e:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104421:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104424:	ba 00 00 00 00       	mov    $0x0,%edx
80104429:	b8 00 00 00 00       	mov    $0x0,%eax
8010442e:	e8 3b fd ff ff       	call   8010416e <argfd>
80104433:	85 c0                	test   %eax,%eax
80104435:	78 43                	js     8010447a <sys_read+0x5f>
80104437:	83 ec 08             	sub    $0x8,%esp
8010443a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010443d:	50                   	push   %eax
8010443e:	6a 02                	push   $0x2
80104440:	e8 11 fc ff ff       	call   80104056 <argint>
80104445:	83 c4 10             	add    $0x10,%esp
80104448:	85 c0                	test   %eax,%eax
8010444a:	78 35                	js     80104481 <sys_read+0x66>
8010444c:	83 ec 04             	sub    $0x4,%esp
8010444f:	ff 75 f0             	pushl  -0x10(%ebp)
80104452:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104455:	50                   	push   %eax
80104456:	6a 01                	push   $0x1
80104458:	e8 21 fc ff ff       	call   8010407e <argptr>
8010445d:	83 c4 10             	add    $0x10,%esp
80104460:	85 c0                	test   %eax,%eax
80104462:	78 24                	js     80104488 <sys_read+0x6d>
  return fileread(f, p, n);
80104464:	83 ec 04             	sub    $0x4,%esp
80104467:	ff 75 f0             	pushl  -0x10(%ebp)
8010446a:	ff 75 ec             	pushl  -0x14(%ebp)
8010446d:	ff 75 f4             	pushl  -0xc(%ebp)
80104470:	e8 62 c9 ff ff       	call   80100dd7 <fileread>
80104475:	83 c4 10             	add    $0x10,%esp
}
80104478:	c9                   	leave  
80104479:	c3                   	ret    
    return -1;
8010447a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010447f:	eb f7                	jmp    80104478 <sys_read+0x5d>
80104481:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104486:	eb f0                	jmp    80104478 <sys_read+0x5d>
80104488:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010448d:	eb e9                	jmp    80104478 <sys_read+0x5d>

8010448f <sys_write>:
{
8010448f:	55                   	push   %ebp
80104490:	89 e5                	mov    %esp,%ebp
80104492:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argint(2, &n) < 0 || argptr(1, &p, n) < 0)
80104495:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104498:	ba 00 00 00 00       	mov    $0x0,%edx
8010449d:	b8 00 00 00 00       	mov    $0x0,%eax
801044a2:	e8 c7 fc ff ff       	call   8010416e <argfd>
801044a7:	85 c0                	test   %eax,%eax
801044a9:	78 43                	js     801044ee <sys_write+0x5f>
801044ab:	83 ec 08             	sub    $0x8,%esp
801044ae:	8d 45 f0             	lea    -0x10(%ebp),%eax
801044b1:	50                   	push   %eax
801044b2:	6a 02                	push   $0x2
801044b4:	e8 9d fb ff ff       	call   80104056 <argint>
801044b9:	83 c4 10             	add    $0x10,%esp
801044bc:	85 c0                	test   %eax,%eax
801044be:	78 35                	js     801044f5 <sys_write+0x66>
801044c0:	83 ec 04             	sub    $0x4,%esp
801044c3:	ff 75 f0             	pushl  -0x10(%ebp)
801044c6:	8d 45 ec             	lea    -0x14(%ebp),%eax
801044c9:	50                   	push   %eax
801044ca:	6a 01                	push   $0x1
801044cc:	e8 ad fb ff ff       	call   8010407e <argptr>
801044d1:	83 c4 10             	add    $0x10,%esp
801044d4:	85 c0                	test   %eax,%eax
801044d6:	78 24                	js     801044fc <sys_write+0x6d>
  return filewrite(f, p, n);
801044d8:	83 ec 04             	sub    $0x4,%esp
801044db:	ff 75 f0             	pushl  -0x10(%ebp)
801044de:	ff 75 ec             	pushl  -0x14(%ebp)
801044e1:	ff 75 f4             	pushl  -0xc(%ebp)
801044e4:	e8 73 c9 ff ff       	call   80100e5c <filewrite>
801044e9:	83 c4 10             	add    $0x10,%esp
}
801044ec:	c9                   	leave  
801044ed:	c3                   	ret    
    return -1;
801044ee:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044f3:	eb f7                	jmp    801044ec <sys_write+0x5d>
801044f5:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801044fa:	eb f0                	jmp    801044ec <sys_write+0x5d>
801044fc:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104501:	eb e9                	jmp    801044ec <sys_write+0x5d>

80104503 <sys_close>:
{
80104503:	55                   	push   %ebp
80104504:	89 e5                	mov    %esp,%ebp
80104506:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, &fd, &f) < 0)
80104509:	8d 4d f0             	lea    -0x10(%ebp),%ecx
8010450c:	8d 55 f4             	lea    -0xc(%ebp),%edx
8010450f:	b8 00 00 00 00       	mov    $0x0,%eax
80104514:	e8 55 fc ff ff       	call   8010416e <argfd>
80104519:	85 c0                	test   %eax,%eax
8010451b:	78 25                	js     80104542 <sys_close+0x3f>
  myproc()->ofile[fd] = 0;
8010451d:	e8 9e ee ff ff       	call   801033c0 <myproc>
80104522:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104525:	c7 44 90 28 00 00 00 	movl   $0x0,0x28(%eax,%edx,4)
8010452c:	00 
  fileclose(f);
8010452d:	83 ec 0c             	sub    $0xc,%esp
80104530:	ff 75 f0             	pushl  -0x10(%ebp)
80104533:	e8 9b c7 ff ff       	call   80100cd3 <fileclose>
  return 0;
80104538:	83 c4 10             	add    $0x10,%esp
8010453b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104540:	c9                   	leave  
80104541:	c3                   	ret    
    return -1;
80104542:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104547:	eb f7                	jmp    80104540 <sys_close+0x3d>

80104549 <sys_fstat>:
{
80104549:	55                   	push   %ebp
8010454a:	89 e5                	mov    %esp,%ebp
8010454c:	83 ec 18             	sub    $0x18,%esp
  if(argfd(0, 0, &f) < 0 || argptr(1, (void*)&st, sizeof(*st)) < 0)
8010454f:	8d 4d f4             	lea    -0xc(%ebp),%ecx
80104552:	ba 00 00 00 00       	mov    $0x0,%edx
80104557:	b8 00 00 00 00       	mov    $0x0,%eax
8010455c:	e8 0d fc ff ff       	call   8010416e <argfd>
80104561:	85 c0                	test   %eax,%eax
80104563:	78 2a                	js     8010458f <sys_fstat+0x46>
80104565:	83 ec 04             	sub    $0x4,%esp
80104568:	6a 14                	push   $0x14
8010456a:	8d 45 f0             	lea    -0x10(%ebp),%eax
8010456d:	50                   	push   %eax
8010456e:	6a 01                	push   $0x1
80104570:	e8 09 fb ff ff       	call   8010407e <argptr>
80104575:	83 c4 10             	add    $0x10,%esp
80104578:	85 c0                	test   %eax,%eax
8010457a:	78 1a                	js     80104596 <sys_fstat+0x4d>
  return filestat(f, st);
8010457c:	83 ec 08             	sub    $0x8,%esp
8010457f:	ff 75 f0             	pushl  -0x10(%ebp)
80104582:	ff 75 f4             	pushl  -0xc(%ebp)
80104585:	e8 06 c8 ff ff       	call   80100d90 <filestat>
8010458a:	83 c4 10             	add    $0x10,%esp
}
8010458d:	c9                   	leave  
8010458e:	c3                   	ret    
    return -1;
8010458f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104594:	eb f7                	jmp    8010458d <sys_fstat+0x44>
80104596:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010459b:	eb f0                	jmp    8010458d <sys_fstat+0x44>

8010459d <sys_link>:
{
8010459d:	55                   	push   %ebp
8010459e:	89 e5                	mov    %esp,%ebp
801045a0:	56                   	push   %esi
801045a1:	53                   	push   %ebx
801045a2:	83 ec 28             	sub    $0x28,%esp
  if(argstr(0, &old) < 0 || argstr(1, &new) < 0)
801045a5:	8d 45 e0             	lea    -0x20(%ebp),%eax
801045a8:	50                   	push   %eax
801045a9:	6a 00                	push   $0x0
801045ab:	e8 36 fb ff ff       	call   801040e6 <argstr>
801045b0:	83 c4 10             	add    $0x10,%esp
801045b3:	85 c0                	test   %eax,%eax
801045b5:	0f 88 32 01 00 00    	js     801046ed <sys_link+0x150>
801045bb:	83 ec 08             	sub    $0x8,%esp
801045be:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801045c1:	50                   	push   %eax
801045c2:	6a 01                	push   $0x1
801045c4:	e8 1d fb ff ff       	call   801040e6 <argstr>
801045c9:	83 c4 10             	add    $0x10,%esp
801045cc:	85 c0                	test   %eax,%eax
801045ce:	0f 88 20 01 00 00    	js     801046f4 <sys_link+0x157>
  begin_op();
801045d4:	e8 9f e3 ff ff       	call   80102978 <begin_op>
  if((ip = namei(old)) == 0){
801045d9:	83 ec 0c             	sub    $0xc,%esp
801045dc:	ff 75 e0             	pushl  -0x20(%ebp)
801045df:	e8 fd d5 ff ff       	call   80101be1 <namei>
801045e4:	89 c3                	mov    %eax,%ebx
801045e6:	83 c4 10             	add    $0x10,%esp
801045e9:	85 c0                	test   %eax,%eax
801045eb:	0f 84 99 00 00 00    	je     8010468a <sys_link+0xed>
  ilock(ip);
801045f1:	83 ec 0c             	sub    $0xc,%esp
801045f4:	50                   	push   %eax
801045f5:	e8 87 cf ff ff       	call   80101581 <ilock>
  if(ip->type == T_DIR){
801045fa:	83 c4 10             	add    $0x10,%esp
801045fd:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104602:	0f 84 8e 00 00 00    	je     80104696 <sys_link+0xf9>
  ip->nlink++;
80104608:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
8010460c:	83 c0 01             	add    $0x1,%eax
8010460f:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104613:	83 ec 0c             	sub    $0xc,%esp
80104616:	53                   	push   %ebx
80104617:	e8 04 ce ff ff       	call   80101420 <iupdate>
  iunlock(ip);
8010461c:	89 1c 24             	mov    %ebx,(%esp)
8010461f:	e8 1f d0 ff ff       	call   80101643 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
80104624:	83 c4 08             	add    $0x8,%esp
80104627:	8d 45 ea             	lea    -0x16(%ebp),%eax
8010462a:	50                   	push   %eax
8010462b:	ff 75 e4             	pushl  -0x1c(%ebp)
8010462e:	e8 c6 d5 ff ff       	call   80101bf9 <nameiparent>
80104633:	89 c6                	mov    %eax,%esi
80104635:	83 c4 10             	add    $0x10,%esp
80104638:	85 c0                	test   %eax,%eax
8010463a:	74 7e                	je     801046ba <sys_link+0x11d>
  ilock(dp);
8010463c:	83 ec 0c             	sub    $0xc,%esp
8010463f:	50                   	push   %eax
80104640:	e8 3c cf ff ff       	call   80101581 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
80104645:	83 c4 10             	add    $0x10,%esp
80104648:	8b 03                	mov    (%ebx),%eax
8010464a:	39 06                	cmp    %eax,(%esi)
8010464c:	75 60                	jne    801046ae <sys_link+0x111>
8010464e:	83 ec 04             	sub    $0x4,%esp
80104651:	ff 73 04             	pushl  0x4(%ebx)
80104654:	8d 45 ea             	lea    -0x16(%ebp),%eax
80104657:	50                   	push   %eax
80104658:	56                   	push   %esi
80104659:	e8 d2 d4 ff ff       	call   80101b30 <dirlink>
8010465e:	83 c4 10             	add    $0x10,%esp
80104661:	85 c0                	test   %eax,%eax
80104663:	78 49                	js     801046ae <sys_link+0x111>
  iunlockput(dp);
80104665:	83 ec 0c             	sub    $0xc,%esp
80104668:	56                   	push   %esi
80104669:	e8 ba d0 ff ff       	call   80101728 <iunlockput>
  iput(ip);
8010466e:	89 1c 24             	mov    %ebx,(%esp)
80104671:	e8 12 d0 ff ff       	call   80101688 <iput>
  end_op();
80104676:	e8 77 e3 ff ff       	call   801029f2 <end_op>
  return 0;
8010467b:	83 c4 10             	add    $0x10,%esp
8010467e:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104683:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104686:	5b                   	pop    %ebx
80104687:	5e                   	pop    %esi
80104688:	5d                   	pop    %ebp
80104689:	c3                   	ret    
    end_op();
8010468a:	e8 63 e3 ff ff       	call   801029f2 <end_op>
    return -1;
8010468f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104694:	eb ed                	jmp    80104683 <sys_link+0xe6>
    iunlockput(ip);
80104696:	83 ec 0c             	sub    $0xc,%esp
80104699:	53                   	push   %ebx
8010469a:	e8 89 d0 ff ff       	call   80101728 <iunlockput>
    end_op();
8010469f:	e8 4e e3 ff ff       	call   801029f2 <end_op>
    return -1;
801046a4:	83 c4 10             	add    $0x10,%esp
801046a7:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046ac:	eb d5                	jmp    80104683 <sys_link+0xe6>
    iunlockput(dp);
801046ae:	83 ec 0c             	sub    $0xc,%esp
801046b1:	56                   	push   %esi
801046b2:	e8 71 d0 ff ff       	call   80101728 <iunlockput>
    goto bad;
801046b7:	83 c4 10             	add    $0x10,%esp
  ilock(ip);
801046ba:	83 ec 0c             	sub    $0xc,%esp
801046bd:	53                   	push   %ebx
801046be:	e8 be ce ff ff       	call   80101581 <ilock>
  ip->nlink--;
801046c3:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801046c7:	83 e8 01             	sub    $0x1,%eax
801046ca:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
801046ce:	89 1c 24             	mov    %ebx,(%esp)
801046d1:	e8 4a cd ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
801046d6:	89 1c 24             	mov    %ebx,(%esp)
801046d9:	e8 4a d0 ff ff       	call   80101728 <iunlockput>
  end_op();
801046de:	e8 0f e3 ff ff       	call   801029f2 <end_op>
  return -1;
801046e3:	83 c4 10             	add    $0x10,%esp
801046e6:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046eb:	eb 96                	jmp    80104683 <sys_link+0xe6>
    return -1;
801046ed:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046f2:	eb 8f                	jmp    80104683 <sys_link+0xe6>
801046f4:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801046f9:	eb 88                	jmp    80104683 <sys_link+0xe6>

801046fb <sys_unlink>:
{
801046fb:	55                   	push   %ebp
801046fc:	89 e5                	mov    %esp,%ebp
801046fe:	57                   	push   %edi
801046ff:	56                   	push   %esi
80104700:	53                   	push   %ebx
80104701:	83 ec 44             	sub    $0x44,%esp
  if(argstr(0, &path) < 0)
80104704:	8d 45 c4             	lea    -0x3c(%ebp),%eax
80104707:	50                   	push   %eax
80104708:	6a 00                	push   $0x0
8010470a:	e8 d7 f9 ff ff       	call   801040e6 <argstr>
8010470f:	83 c4 10             	add    $0x10,%esp
80104712:	85 c0                	test   %eax,%eax
80104714:	0f 88 83 01 00 00    	js     8010489d <sys_unlink+0x1a2>
  begin_op();
8010471a:	e8 59 e2 ff ff       	call   80102978 <begin_op>
  if((dp = nameiparent(path, name)) == 0){
8010471f:	83 ec 08             	sub    $0x8,%esp
80104722:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104725:	50                   	push   %eax
80104726:	ff 75 c4             	pushl  -0x3c(%ebp)
80104729:	e8 cb d4 ff ff       	call   80101bf9 <nameiparent>
8010472e:	89 c6                	mov    %eax,%esi
80104730:	83 c4 10             	add    $0x10,%esp
80104733:	85 c0                	test   %eax,%eax
80104735:	0f 84 ed 00 00 00    	je     80104828 <sys_unlink+0x12d>
  ilock(dp);
8010473b:	83 ec 0c             	sub    $0xc,%esp
8010473e:	50                   	push   %eax
8010473f:	e8 3d ce ff ff       	call   80101581 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
80104744:	83 c4 08             	add    $0x8,%esp
80104747:	68 7e 6e 10 80       	push   $0x80106e7e
8010474c:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010474f:	50                   	push   %eax
80104750:	e8 46 d2 ff ff       	call   8010199b <namecmp>
80104755:	83 c4 10             	add    $0x10,%esp
80104758:	85 c0                	test   %eax,%eax
8010475a:	0f 84 fc 00 00 00    	je     8010485c <sys_unlink+0x161>
80104760:	83 ec 08             	sub    $0x8,%esp
80104763:	68 7d 6e 10 80       	push   $0x80106e7d
80104768:	8d 45 ca             	lea    -0x36(%ebp),%eax
8010476b:	50                   	push   %eax
8010476c:	e8 2a d2 ff ff       	call   8010199b <namecmp>
80104771:	83 c4 10             	add    $0x10,%esp
80104774:	85 c0                	test   %eax,%eax
80104776:	0f 84 e0 00 00 00    	je     8010485c <sys_unlink+0x161>
  if((ip = dirlookup(dp, name, &off)) == 0)
8010477c:	83 ec 04             	sub    $0x4,%esp
8010477f:	8d 45 c0             	lea    -0x40(%ebp),%eax
80104782:	50                   	push   %eax
80104783:	8d 45 ca             	lea    -0x36(%ebp),%eax
80104786:	50                   	push   %eax
80104787:	56                   	push   %esi
80104788:	e8 23 d2 ff ff       	call   801019b0 <dirlookup>
8010478d:	89 c3                	mov    %eax,%ebx
8010478f:	83 c4 10             	add    $0x10,%esp
80104792:	85 c0                	test   %eax,%eax
80104794:	0f 84 c2 00 00 00    	je     8010485c <sys_unlink+0x161>
  ilock(ip);
8010479a:	83 ec 0c             	sub    $0xc,%esp
8010479d:	50                   	push   %eax
8010479e:	e8 de cd ff ff       	call   80101581 <ilock>
  if(ip->nlink < 1)
801047a3:	83 c4 10             	add    $0x10,%esp
801047a6:	66 83 7b 56 00       	cmpw   $0x0,0x56(%ebx)
801047ab:	0f 8e 83 00 00 00    	jle    80104834 <sys_unlink+0x139>
  if(ip->type == T_DIR && !isdirempty(ip)){
801047b1:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047b6:	0f 84 85 00 00 00    	je     80104841 <sys_unlink+0x146>
  memset(&de, 0, sizeof(de));
801047bc:	83 ec 04             	sub    $0x4,%esp
801047bf:	6a 10                	push   $0x10
801047c1:	6a 00                	push   $0x0
801047c3:	8d 7d d8             	lea    -0x28(%ebp),%edi
801047c6:	57                   	push   %edi
801047c7:	e8 3f f6 ff ff       	call   80103e0b <memset>
  if(writei(dp, (char*)&de, off, sizeof(de)) != sizeof(de))
801047cc:	6a 10                	push   $0x10
801047ce:	ff 75 c0             	pushl  -0x40(%ebp)
801047d1:	57                   	push   %edi
801047d2:	56                   	push   %esi
801047d3:	e8 98 d0 ff ff       	call   80101870 <writei>
801047d8:	83 c4 20             	add    $0x20,%esp
801047db:	83 f8 10             	cmp    $0x10,%eax
801047de:	0f 85 90 00 00 00    	jne    80104874 <sys_unlink+0x179>
  if(ip->type == T_DIR){
801047e4:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
801047e9:	0f 84 92 00 00 00    	je     80104881 <sys_unlink+0x186>
  iunlockput(dp);
801047ef:	83 ec 0c             	sub    $0xc,%esp
801047f2:	56                   	push   %esi
801047f3:	e8 30 cf ff ff       	call   80101728 <iunlockput>
  ip->nlink--;
801047f8:	0f b7 43 56          	movzwl 0x56(%ebx),%eax
801047fc:	83 e8 01             	sub    $0x1,%eax
801047ff:	66 89 43 56          	mov    %ax,0x56(%ebx)
  iupdate(ip);
80104803:	89 1c 24             	mov    %ebx,(%esp)
80104806:	e8 15 cc ff ff       	call   80101420 <iupdate>
  iunlockput(ip);
8010480b:	89 1c 24             	mov    %ebx,(%esp)
8010480e:	e8 15 cf ff ff       	call   80101728 <iunlockput>
  end_op();
80104813:	e8 da e1 ff ff       	call   801029f2 <end_op>
  return 0;
80104818:	83 c4 10             	add    $0x10,%esp
8010481b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104820:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104823:	5b                   	pop    %ebx
80104824:	5e                   	pop    %esi
80104825:	5f                   	pop    %edi
80104826:	5d                   	pop    %ebp
80104827:	c3                   	ret    
    end_op();
80104828:	e8 c5 e1 ff ff       	call   801029f2 <end_op>
    return -1;
8010482d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104832:	eb ec                	jmp    80104820 <sys_unlink+0x125>
    panic("unlink: nlink < 1");
80104834:	83 ec 0c             	sub    $0xc,%esp
80104837:	68 9c 6e 10 80       	push   $0x80106e9c
8010483c:	e8 07 bb ff ff       	call   80100348 <panic>
  if(ip->type == T_DIR && !isdirempty(ip)){
80104841:	89 d8                	mov    %ebx,%eax
80104843:	e8 c4 f9 ff ff       	call   8010420c <isdirempty>
80104848:	85 c0                	test   %eax,%eax
8010484a:	0f 85 6c ff ff ff    	jne    801047bc <sys_unlink+0xc1>
    iunlockput(ip);
80104850:	83 ec 0c             	sub    $0xc,%esp
80104853:	53                   	push   %ebx
80104854:	e8 cf ce ff ff       	call   80101728 <iunlockput>
    goto bad;
80104859:	83 c4 10             	add    $0x10,%esp
  iunlockput(dp);
8010485c:	83 ec 0c             	sub    $0xc,%esp
8010485f:	56                   	push   %esi
80104860:	e8 c3 ce ff ff       	call   80101728 <iunlockput>
  end_op();
80104865:	e8 88 e1 ff ff       	call   801029f2 <end_op>
  return -1;
8010486a:	83 c4 10             	add    $0x10,%esp
8010486d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104872:	eb ac                	jmp    80104820 <sys_unlink+0x125>
    panic("unlink: writei");
80104874:	83 ec 0c             	sub    $0xc,%esp
80104877:	68 ae 6e 10 80       	push   $0x80106eae
8010487c:	e8 c7 ba ff ff       	call   80100348 <panic>
    dp->nlink--;
80104881:	0f b7 46 56          	movzwl 0x56(%esi),%eax
80104885:	83 e8 01             	sub    $0x1,%eax
80104888:	66 89 46 56          	mov    %ax,0x56(%esi)
    iupdate(dp);
8010488c:	83 ec 0c             	sub    $0xc,%esp
8010488f:	56                   	push   %esi
80104890:	e8 8b cb ff ff       	call   80101420 <iupdate>
80104895:	83 c4 10             	add    $0x10,%esp
80104898:	e9 52 ff ff ff       	jmp    801047ef <sys_unlink+0xf4>
    return -1;
8010489d:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
801048a2:	e9 79 ff ff ff       	jmp    80104820 <sys_unlink+0x125>

801048a7 <sys_open>:

int
sys_open(void)
{
801048a7:	55                   	push   %ebp
801048a8:	89 e5                	mov    %esp,%ebp
801048aa:	57                   	push   %edi
801048ab:	56                   	push   %esi
801048ac:	53                   	push   %ebx
801048ad:	83 ec 24             	sub    $0x24,%esp
  char *path;
  int fd, omode;
  struct file *f;
  struct inode *ip;

  if(argstr(0, &path) < 0 || argint(1, &omode) < 0)
801048b0:	8d 45 e4             	lea    -0x1c(%ebp),%eax
801048b3:	50                   	push   %eax
801048b4:	6a 00                	push   $0x0
801048b6:	e8 2b f8 ff ff       	call   801040e6 <argstr>
801048bb:	83 c4 10             	add    $0x10,%esp
801048be:	85 c0                	test   %eax,%eax
801048c0:	0f 88 30 01 00 00    	js     801049f6 <sys_open+0x14f>
801048c6:	83 ec 08             	sub    $0x8,%esp
801048c9:	8d 45 e0             	lea    -0x20(%ebp),%eax
801048cc:	50                   	push   %eax
801048cd:	6a 01                	push   $0x1
801048cf:	e8 82 f7 ff ff       	call   80104056 <argint>
801048d4:	83 c4 10             	add    $0x10,%esp
801048d7:	85 c0                	test   %eax,%eax
801048d9:	0f 88 21 01 00 00    	js     80104a00 <sys_open+0x159>
    return -1;

  begin_op();
801048df:	e8 94 e0 ff ff       	call   80102978 <begin_op>

  if(omode & O_CREATE){
801048e4:	f6 45 e1 02          	testb  $0x2,-0x1f(%ebp)
801048e8:	0f 84 84 00 00 00    	je     80104972 <sys_open+0xcb>
    ip = create(path, T_FILE, 0, 0);
801048ee:	83 ec 0c             	sub    $0xc,%esp
801048f1:	6a 00                	push   $0x0
801048f3:	b9 00 00 00 00       	mov    $0x0,%ecx
801048f8:	ba 02 00 00 00       	mov    $0x2,%edx
801048fd:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80104900:	e8 5e f9 ff ff       	call   80104263 <create>
80104905:	89 c6                	mov    %eax,%esi
    if(ip == 0){
80104907:	83 c4 10             	add    $0x10,%esp
8010490a:	85 c0                	test   %eax,%eax
8010490c:	74 58                	je     80104966 <sys_open+0xbf>
      end_op();
      return -1;
    }
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
8010490e:	e8 1a c3 ff ff       	call   80100c2d <filealloc>
80104913:	89 c3                	mov    %eax,%ebx
80104915:	85 c0                	test   %eax,%eax
80104917:	0f 84 ae 00 00 00    	je     801049cb <sys_open+0x124>
8010491d:	e8 b3 f8 ff ff       	call   801041d5 <fdalloc>
80104922:	89 c7                	mov    %eax,%edi
80104924:	85 c0                	test   %eax,%eax
80104926:	0f 88 9f 00 00 00    	js     801049cb <sys_open+0x124>
      fileclose(f);
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
8010492c:	83 ec 0c             	sub    $0xc,%esp
8010492f:	56                   	push   %esi
80104930:	e8 0e cd ff ff       	call   80101643 <iunlock>
  end_op();
80104935:	e8 b8 e0 ff ff       	call   801029f2 <end_op>

  f->type = FD_INODE;
8010493a:	c7 03 02 00 00 00    	movl   $0x2,(%ebx)
  f->ip = ip;
80104940:	89 73 10             	mov    %esi,0x10(%ebx)
  f->off = 0;
80104943:	c7 43 14 00 00 00 00 	movl   $0x0,0x14(%ebx)
  f->readable = !(omode & O_WRONLY);
8010494a:	8b 45 e0             	mov    -0x20(%ebp),%eax
8010494d:	83 c4 10             	add    $0x10,%esp
80104950:	a8 01                	test   $0x1,%al
80104952:	0f 94 43 08          	sete   0x8(%ebx)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
80104956:	a8 03                	test   $0x3,%al
80104958:	0f 95 43 09          	setne  0x9(%ebx)
  return fd;
}
8010495c:	89 f8                	mov    %edi,%eax
8010495e:	8d 65 f4             	lea    -0xc(%ebp),%esp
80104961:	5b                   	pop    %ebx
80104962:	5e                   	pop    %esi
80104963:	5f                   	pop    %edi
80104964:	5d                   	pop    %ebp
80104965:	c3                   	ret    
      end_op();
80104966:	e8 87 e0 ff ff       	call   801029f2 <end_op>
      return -1;
8010496b:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104970:	eb ea                	jmp    8010495c <sys_open+0xb5>
    if((ip = namei(path)) == 0){
80104972:	83 ec 0c             	sub    $0xc,%esp
80104975:	ff 75 e4             	pushl  -0x1c(%ebp)
80104978:	e8 64 d2 ff ff       	call   80101be1 <namei>
8010497d:	89 c6                	mov    %eax,%esi
8010497f:	83 c4 10             	add    $0x10,%esp
80104982:	85 c0                	test   %eax,%eax
80104984:	74 39                	je     801049bf <sys_open+0x118>
    ilock(ip);
80104986:	83 ec 0c             	sub    $0xc,%esp
80104989:	50                   	push   %eax
8010498a:	e8 f2 cb ff ff       	call   80101581 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
8010498f:	83 c4 10             	add    $0x10,%esp
80104992:	66 83 7e 50 01       	cmpw   $0x1,0x50(%esi)
80104997:	0f 85 71 ff ff ff    	jne    8010490e <sys_open+0x67>
8010499d:	83 7d e0 00          	cmpl   $0x0,-0x20(%ebp)
801049a1:	0f 84 67 ff ff ff    	je     8010490e <sys_open+0x67>
      iunlockput(ip);
801049a7:	83 ec 0c             	sub    $0xc,%esp
801049aa:	56                   	push   %esi
801049ab:	e8 78 cd ff ff       	call   80101728 <iunlockput>
      end_op();
801049b0:	e8 3d e0 ff ff       	call   801029f2 <end_op>
      return -1;
801049b5:	83 c4 10             	add    $0x10,%esp
801049b8:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049bd:	eb 9d                	jmp    8010495c <sys_open+0xb5>
      end_op();
801049bf:	e8 2e e0 ff ff       	call   801029f2 <end_op>
      return -1;
801049c4:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049c9:	eb 91                	jmp    8010495c <sys_open+0xb5>
    if(f)
801049cb:	85 db                	test   %ebx,%ebx
801049cd:	74 0c                	je     801049db <sys_open+0x134>
      fileclose(f);
801049cf:	83 ec 0c             	sub    $0xc,%esp
801049d2:	53                   	push   %ebx
801049d3:	e8 fb c2 ff ff       	call   80100cd3 <fileclose>
801049d8:	83 c4 10             	add    $0x10,%esp
    iunlockput(ip);
801049db:	83 ec 0c             	sub    $0xc,%esp
801049de:	56                   	push   %esi
801049df:	e8 44 cd ff ff       	call   80101728 <iunlockput>
    end_op();
801049e4:	e8 09 e0 ff ff       	call   801029f2 <end_op>
    return -1;
801049e9:	83 c4 10             	add    $0x10,%esp
801049ec:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049f1:	e9 66 ff ff ff       	jmp    8010495c <sys_open+0xb5>
    return -1;
801049f6:	bf ff ff ff ff       	mov    $0xffffffff,%edi
801049fb:	e9 5c ff ff ff       	jmp    8010495c <sys_open+0xb5>
80104a00:	bf ff ff ff ff       	mov    $0xffffffff,%edi
80104a05:	e9 52 ff ff ff       	jmp    8010495c <sys_open+0xb5>

80104a0a <sys_mkdir>:

int
sys_mkdir(void)
{
80104a0a:	55                   	push   %ebp
80104a0b:	89 e5                	mov    %esp,%ebp
80104a0d:	83 ec 18             	sub    $0x18,%esp
  char *path;
  struct inode *ip;

  begin_op();
80104a10:	e8 63 df ff ff       	call   80102978 <begin_op>
  if(argstr(0, &path) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
80104a15:	83 ec 08             	sub    $0x8,%esp
80104a18:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a1b:	50                   	push   %eax
80104a1c:	6a 00                	push   $0x0
80104a1e:	e8 c3 f6 ff ff       	call   801040e6 <argstr>
80104a23:	83 c4 10             	add    $0x10,%esp
80104a26:	85 c0                	test   %eax,%eax
80104a28:	78 36                	js     80104a60 <sys_mkdir+0x56>
80104a2a:	83 ec 0c             	sub    $0xc,%esp
80104a2d:	6a 00                	push   $0x0
80104a2f:	b9 00 00 00 00       	mov    $0x0,%ecx
80104a34:	ba 01 00 00 00       	mov    $0x1,%edx
80104a39:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104a3c:	e8 22 f8 ff ff       	call   80104263 <create>
80104a41:	83 c4 10             	add    $0x10,%esp
80104a44:	85 c0                	test   %eax,%eax
80104a46:	74 18                	je     80104a60 <sys_mkdir+0x56>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104a48:	83 ec 0c             	sub    $0xc,%esp
80104a4b:	50                   	push   %eax
80104a4c:	e8 d7 cc ff ff       	call   80101728 <iunlockput>
  end_op();
80104a51:	e8 9c df ff ff       	call   801029f2 <end_op>
  return 0;
80104a56:	83 c4 10             	add    $0x10,%esp
80104a59:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104a5e:	c9                   	leave  
80104a5f:	c3                   	ret    
    end_op();
80104a60:	e8 8d df ff ff       	call   801029f2 <end_op>
    return -1;
80104a65:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104a6a:	eb f2                	jmp    80104a5e <sys_mkdir+0x54>

80104a6c <sys_mknod>:

int
sys_mknod(void)
{
80104a6c:	55                   	push   %ebp
80104a6d:	89 e5                	mov    %esp,%ebp
80104a6f:	83 ec 18             	sub    $0x18,%esp
  struct inode *ip;
  char *path;
  int major, minor;

  begin_op();
80104a72:	e8 01 df ff ff       	call   80102978 <begin_op>
  if((argstr(0, &path)) < 0 ||
80104a77:	83 ec 08             	sub    $0x8,%esp
80104a7a:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104a7d:	50                   	push   %eax
80104a7e:	6a 00                	push   $0x0
80104a80:	e8 61 f6 ff ff       	call   801040e6 <argstr>
80104a85:	83 c4 10             	add    $0x10,%esp
80104a88:	85 c0                	test   %eax,%eax
80104a8a:	78 62                	js     80104aee <sys_mknod+0x82>
     argint(1, &major) < 0 ||
80104a8c:	83 ec 08             	sub    $0x8,%esp
80104a8f:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104a92:	50                   	push   %eax
80104a93:	6a 01                	push   $0x1
80104a95:	e8 bc f5 ff ff       	call   80104056 <argint>
  if((argstr(0, &path)) < 0 ||
80104a9a:	83 c4 10             	add    $0x10,%esp
80104a9d:	85 c0                	test   %eax,%eax
80104a9f:	78 4d                	js     80104aee <sys_mknod+0x82>
     argint(2, &minor) < 0 ||
80104aa1:	83 ec 08             	sub    $0x8,%esp
80104aa4:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104aa7:	50                   	push   %eax
80104aa8:	6a 02                	push   $0x2
80104aaa:	e8 a7 f5 ff ff       	call   80104056 <argint>
     argint(1, &major) < 0 ||
80104aaf:	83 c4 10             	add    $0x10,%esp
80104ab2:	85 c0                	test   %eax,%eax
80104ab4:	78 38                	js     80104aee <sys_mknod+0x82>
     (ip = create(path, T_DEV, major, minor)) == 0){
80104ab6:	0f bf 45 ec          	movswl -0x14(%ebp),%eax
80104aba:	0f bf 4d f0          	movswl -0x10(%ebp),%ecx
     argint(2, &minor) < 0 ||
80104abe:	83 ec 0c             	sub    $0xc,%esp
80104ac1:	50                   	push   %eax
80104ac2:	ba 03 00 00 00       	mov    $0x3,%edx
80104ac7:	8b 45 f4             	mov    -0xc(%ebp),%eax
80104aca:	e8 94 f7 ff ff       	call   80104263 <create>
80104acf:	83 c4 10             	add    $0x10,%esp
80104ad2:	85 c0                	test   %eax,%eax
80104ad4:	74 18                	je     80104aee <sys_mknod+0x82>
    end_op();
    return -1;
  }
  iunlockput(ip);
80104ad6:	83 ec 0c             	sub    $0xc,%esp
80104ad9:	50                   	push   %eax
80104ada:	e8 49 cc ff ff       	call   80101728 <iunlockput>
  end_op();
80104adf:	e8 0e df ff ff       	call   801029f2 <end_op>
  return 0;
80104ae4:	83 c4 10             	add    $0x10,%esp
80104ae7:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104aec:	c9                   	leave  
80104aed:	c3                   	ret    
    end_op();
80104aee:	e8 ff de ff ff       	call   801029f2 <end_op>
    return -1;
80104af3:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104af8:	eb f2                	jmp    80104aec <sys_mknod+0x80>

80104afa <sys_chdir>:

int
sys_chdir(void)
{
80104afa:	55                   	push   %ebp
80104afb:	89 e5                	mov    %esp,%ebp
80104afd:	56                   	push   %esi
80104afe:	53                   	push   %ebx
80104aff:	83 ec 10             	sub    $0x10,%esp
  char *path;
  struct inode *ip;
  struct proc *curproc = myproc();
80104b02:	e8 b9 e8 ff ff       	call   801033c0 <myproc>
80104b07:	89 c6                	mov    %eax,%esi
  
  begin_op();
80104b09:	e8 6a de ff ff       	call   80102978 <begin_op>
  if(argstr(0, &path) < 0 || (ip = namei(path)) == 0){
80104b0e:	83 ec 08             	sub    $0x8,%esp
80104b11:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104b14:	50                   	push   %eax
80104b15:	6a 00                	push   $0x0
80104b17:	e8 ca f5 ff ff       	call   801040e6 <argstr>
80104b1c:	83 c4 10             	add    $0x10,%esp
80104b1f:	85 c0                	test   %eax,%eax
80104b21:	78 52                	js     80104b75 <sys_chdir+0x7b>
80104b23:	83 ec 0c             	sub    $0xc,%esp
80104b26:	ff 75 f4             	pushl  -0xc(%ebp)
80104b29:	e8 b3 d0 ff ff       	call   80101be1 <namei>
80104b2e:	89 c3                	mov    %eax,%ebx
80104b30:	83 c4 10             	add    $0x10,%esp
80104b33:	85 c0                	test   %eax,%eax
80104b35:	74 3e                	je     80104b75 <sys_chdir+0x7b>
    end_op();
    return -1;
  }
  ilock(ip);
80104b37:	83 ec 0c             	sub    $0xc,%esp
80104b3a:	50                   	push   %eax
80104b3b:	e8 41 ca ff ff       	call   80101581 <ilock>
  if(ip->type != T_DIR){
80104b40:	83 c4 10             	add    $0x10,%esp
80104b43:	66 83 7b 50 01       	cmpw   $0x1,0x50(%ebx)
80104b48:	75 37                	jne    80104b81 <sys_chdir+0x87>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
80104b4a:	83 ec 0c             	sub    $0xc,%esp
80104b4d:	53                   	push   %ebx
80104b4e:	e8 f0 ca ff ff       	call   80101643 <iunlock>
  iput(curproc->cwd);
80104b53:	83 c4 04             	add    $0x4,%esp
80104b56:	ff 76 68             	pushl  0x68(%esi)
80104b59:	e8 2a cb ff ff       	call   80101688 <iput>
  end_op();
80104b5e:	e8 8f de ff ff       	call   801029f2 <end_op>
  curproc->cwd = ip;
80104b63:	89 5e 68             	mov    %ebx,0x68(%esi)
  return 0;
80104b66:	83 c4 10             	add    $0x10,%esp
80104b69:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104b6e:	8d 65 f8             	lea    -0x8(%ebp),%esp
80104b71:	5b                   	pop    %ebx
80104b72:	5e                   	pop    %esi
80104b73:	5d                   	pop    %ebp
80104b74:	c3                   	ret    
    end_op();
80104b75:	e8 78 de ff ff       	call   801029f2 <end_op>
    return -1;
80104b7a:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b7f:	eb ed                	jmp    80104b6e <sys_chdir+0x74>
    iunlockput(ip);
80104b81:	83 ec 0c             	sub    $0xc,%esp
80104b84:	53                   	push   %ebx
80104b85:	e8 9e cb ff ff       	call   80101728 <iunlockput>
    end_op();
80104b8a:	e8 63 de ff ff       	call   801029f2 <end_op>
    return -1;
80104b8f:	83 c4 10             	add    $0x10,%esp
80104b92:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104b97:	eb d5                	jmp    80104b6e <sys_chdir+0x74>

80104b99 <sys_exec>:

int
sys_exec(void)
{
80104b99:	55                   	push   %ebp
80104b9a:	89 e5                	mov    %esp,%ebp
80104b9c:	53                   	push   %ebx
80104b9d:	81 ec 9c 00 00 00    	sub    $0x9c,%esp
  char *path, *argv[MAXARG];
  int i;
  uint uargv, uarg;

  if(argstr(0, &path) < 0 || argint(1, (int*)&uargv) < 0){
80104ba3:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104ba6:	50                   	push   %eax
80104ba7:	6a 00                	push   $0x0
80104ba9:	e8 38 f5 ff ff       	call   801040e6 <argstr>
80104bae:	83 c4 10             	add    $0x10,%esp
80104bb1:	85 c0                	test   %eax,%eax
80104bb3:	0f 88 a8 00 00 00    	js     80104c61 <sys_exec+0xc8>
80104bb9:	83 ec 08             	sub    $0x8,%esp
80104bbc:	8d 85 70 ff ff ff    	lea    -0x90(%ebp),%eax
80104bc2:	50                   	push   %eax
80104bc3:	6a 01                	push   $0x1
80104bc5:	e8 8c f4 ff ff       	call   80104056 <argint>
80104bca:	83 c4 10             	add    $0x10,%esp
80104bcd:	85 c0                	test   %eax,%eax
80104bcf:	0f 88 93 00 00 00    	js     80104c68 <sys_exec+0xcf>
    return -1;
  }
  memset(argv, 0, sizeof(argv));
80104bd5:	83 ec 04             	sub    $0x4,%esp
80104bd8:	68 80 00 00 00       	push   $0x80
80104bdd:	6a 00                	push   $0x0
80104bdf:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104be5:	50                   	push   %eax
80104be6:	e8 20 f2 ff ff       	call   80103e0b <memset>
80104beb:	83 c4 10             	add    $0x10,%esp
  for(i=0;; i++){
80104bee:	bb 00 00 00 00       	mov    $0x0,%ebx
    if(i >= NELEM(argv))
80104bf3:	83 fb 1f             	cmp    $0x1f,%ebx
80104bf6:	77 77                	ja     80104c6f <sys_exec+0xd6>
      return -1;
    if(fetchint(uargv+4*i, (int*)&uarg) < 0)
80104bf8:	83 ec 08             	sub    $0x8,%esp
80104bfb:	8d 85 6c ff ff ff    	lea    -0x94(%ebp),%eax
80104c01:	50                   	push   %eax
80104c02:	8b 85 70 ff ff ff    	mov    -0x90(%ebp),%eax
80104c08:	8d 04 98             	lea    (%eax,%ebx,4),%eax
80104c0b:	50                   	push   %eax
80104c0c:	e8 c9 f3 ff ff       	call   80103fda <fetchint>
80104c11:	83 c4 10             	add    $0x10,%esp
80104c14:	85 c0                	test   %eax,%eax
80104c16:	78 5e                	js     80104c76 <sys_exec+0xdd>
      return -1;
    if(uarg == 0){
80104c18:	8b 85 6c ff ff ff    	mov    -0x94(%ebp),%eax
80104c1e:	85 c0                	test   %eax,%eax
80104c20:	74 1d                	je     80104c3f <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    if(fetchstr(uarg, &argv[i]) < 0)
80104c22:	83 ec 08             	sub    $0x8,%esp
80104c25:	8d 94 9d 74 ff ff ff 	lea    -0x8c(%ebp,%ebx,4),%edx
80104c2c:	52                   	push   %edx
80104c2d:	50                   	push   %eax
80104c2e:	e8 e3 f3 ff ff       	call   80104016 <fetchstr>
80104c33:	83 c4 10             	add    $0x10,%esp
80104c36:	85 c0                	test   %eax,%eax
80104c38:	78 46                	js     80104c80 <sys_exec+0xe7>
  for(i=0;; i++){
80104c3a:	83 c3 01             	add    $0x1,%ebx
    if(i >= NELEM(argv))
80104c3d:	eb b4                	jmp    80104bf3 <sys_exec+0x5a>
      argv[i] = 0;
80104c3f:	c7 84 9d 74 ff ff ff 	movl   $0x0,-0x8c(%ebp,%ebx,4)
80104c46:	00 00 00 00 
      return -1;
  }
  return exec(path, argv);
80104c4a:	83 ec 08             	sub    $0x8,%esp
80104c4d:	8d 85 74 ff ff ff    	lea    -0x8c(%ebp),%eax
80104c53:	50                   	push   %eax
80104c54:	ff 75 f4             	pushl  -0xc(%ebp)
80104c57:	e8 76 bc ff ff       	call   801008d2 <exec>
80104c5c:	83 c4 10             	add    $0x10,%esp
80104c5f:	eb 1a                	jmp    80104c7b <sys_exec+0xe2>
    return -1;
80104c61:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c66:	eb 13                	jmp    80104c7b <sys_exec+0xe2>
80104c68:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c6d:	eb 0c                	jmp    80104c7b <sys_exec+0xe2>
      return -1;
80104c6f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c74:	eb 05                	jmp    80104c7b <sys_exec+0xe2>
      return -1;
80104c76:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
}
80104c7b:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104c7e:	c9                   	leave  
80104c7f:	c3                   	ret    
      return -1;
80104c80:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104c85:	eb f4                	jmp    80104c7b <sys_exec+0xe2>

80104c87 <sys_pipe>:

int
sys_pipe(void)
{
80104c87:	55                   	push   %ebp
80104c88:	89 e5                	mov    %esp,%ebp
80104c8a:	53                   	push   %ebx
80104c8b:	83 ec 18             	sub    $0x18,%esp
  int *fd;
  struct file *rf, *wf;
  int fd0, fd1;

  if(argptr(0, (void*)&fd, 2*sizeof(fd[0])) < 0)
80104c8e:	6a 08                	push   $0x8
80104c90:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104c93:	50                   	push   %eax
80104c94:	6a 00                	push   $0x0
80104c96:	e8 e3 f3 ff ff       	call   8010407e <argptr>
80104c9b:	83 c4 10             	add    $0x10,%esp
80104c9e:	85 c0                	test   %eax,%eax
80104ca0:	78 77                	js     80104d19 <sys_pipe+0x92>
    return -1;
  if(pipealloc(&rf, &wf) < 0)
80104ca2:	83 ec 08             	sub    $0x8,%esp
80104ca5:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104ca8:	50                   	push   %eax
80104ca9:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104cac:	50                   	push   %eax
80104cad:	e8 4d e2 ff ff       	call   80102eff <pipealloc>
80104cb2:	83 c4 10             	add    $0x10,%esp
80104cb5:	85 c0                	test   %eax,%eax
80104cb7:	78 67                	js     80104d20 <sys_pipe+0x99>
    return -1;
  fd0 = -1;
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
80104cb9:	8b 45 f0             	mov    -0x10(%ebp),%eax
80104cbc:	e8 14 f5 ff ff       	call   801041d5 <fdalloc>
80104cc1:	89 c3                	mov    %eax,%ebx
80104cc3:	85 c0                	test   %eax,%eax
80104cc5:	78 21                	js     80104ce8 <sys_pipe+0x61>
80104cc7:	8b 45 ec             	mov    -0x14(%ebp),%eax
80104cca:	e8 06 f5 ff ff       	call   801041d5 <fdalloc>
80104ccf:	85 c0                	test   %eax,%eax
80104cd1:	78 15                	js     80104ce8 <sys_pipe+0x61>
      myproc()->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  fd[0] = fd0;
80104cd3:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cd6:	89 1a                	mov    %ebx,(%edx)
  fd[1] = fd1;
80104cd8:	8b 55 f4             	mov    -0xc(%ebp),%edx
80104cdb:	89 42 04             	mov    %eax,0x4(%edx)
  return 0;
80104cde:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104ce3:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104ce6:	c9                   	leave  
80104ce7:	c3                   	ret    
    if(fd0 >= 0)
80104ce8:	85 db                	test   %ebx,%ebx
80104cea:	78 0d                	js     80104cf9 <sys_pipe+0x72>
      myproc()->ofile[fd0] = 0;
80104cec:	e8 cf e6 ff ff       	call   801033c0 <myproc>
80104cf1:	c7 44 98 28 00 00 00 	movl   $0x0,0x28(%eax,%ebx,4)
80104cf8:	00 
    fileclose(rf);
80104cf9:	83 ec 0c             	sub    $0xc,%esp
80104cfc:	ff 75 f0             	pushl  -0x10(%ebp)
80104cff:	e8 cf bf ff ff       	call   80100cd3 <fileclose>
    fileclose(wf);
80104d04:	83 c4 04             	add    $0x4,%esp
80104d07:	ff 75 ec             	pushl  -0x14(%ebp)
80104d0a:	e8 c4 bf ff ff       	call   80100cd3 <fileclose>
    return -1;
80104d0f:	83 c4 10             	add    $0x10,%esp
80104d12:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d17:	eb ca                	jmp    80104ce3 <sys_pipe+0x5c>
    return -1;
80104d19:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d1e:	eb c3                	jmp    80104ce3 <sys_pipe+0x5c>
    return -1;
80104d20:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d25:	eb bc                	jmp    80104ce3 <sys_pipe+0x5c>

80104d27 <sys_fork>:
#include "mmu.h"
#include "proc.h"

int
sys_fork(void)
{
80104d27:	55                   	push   %ebp
80104d28:	89 e5                	mov    %esp,%ebp
80104d2a:	83 ec 08             	sub    $0x8,%esp
  return fork();
80104d2d:	e8 06 e8 ff ff       	call   80103538 <fork>
}
80104d32:	c9                   	leave  
80104d33:	c3                   	ret    

80104d34 <sys_exit>:

int
sys_exit(void)
{
80104d34:	55                   	push   %ebp
80104d35:	89 e5                	mov    %esp,%ebp
80104d37:	83 ec 08             	sub    $0x8,%esp
  exit();
80104d3a:	e8 2d ea ff ff       	call   8010376c <exit>
  return 0;  // not reached
}
80104d3f:	b8 00 00 00 00       	mov    $0x0,%eax
80104d44:	c9                   	leave  
80104d45:	c3                   	ret    

80104d46 <sys_wait>:

int
sys_wait(void)
{
80104d46:	55                   	push   %ebp
80104d47:	89 e5                	mov    %esp,%ebp
80104d49:	83 ec 08             	sub    $0x8,%esp
  return wait();
80104d4c:	e8 a4 eb ff ff       	call   801038f5 <wait>
}
80104d51:	c9                   	leave  
80104d52:	c3                   	ret    

80104d53 <sys_kill>:

int
sys_kill(void)
{
80104d53:	55                   	push   %ebp
80104d54:	89 e5                	mov    %esp,%ebp
80104d56:	83 ec 20             	sub    $0x20,%esp
  int pid;

  if(argint(0, &pid) < 0)
80104d59:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d5c:	50                   	push   %eax
80104d5d:	6a 00                	push   $0x0
80104d5f:	e8 f2 f2 ff ff       	call   80104056 <argint>
80104d64:	83 c4 10             	add    $0x10,%esp
80104d67:	85 c0                	test   %eax,%eax
80104d69:	78 10                	js     80104d7b <sys_kill+0x28>
    return -1;
  return kill(pid);
80104d6b:	83 ec 0c             	sub    $0xc,%esp
80104d6e:	ff 75 f4             	pushl  -0xc(%ebp)
80104d71:	e8 7c ec ff ff       	call   801039f2 <kill>
80104d76:	83 c4 10             	add    $0x10,%esp
}
80104d79:	c9                   	leave  
80104d7a:	c3                   	ret    
    return -1;
80104d7b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104d80:	eb f7                	jmp    80104d79 <sys_kill+0x26>

80104d82 <sys_getpid>:

int
sys_getpid(void)
{
80104d82:	55                   	push   %ebp
80104d83:	89 e5                	mov    %esp,%ebp
80104d85:	83 ec 08             	sub    $0x8,%esp
  return myproc()->pid;
80104d88:	e8 33 e6 ff ff       	call   801033c0 <myproc>
80104d8d:	8b 40 10             	mov    0x10(%eax),%eax
}
80104d90:	c9                   	leave  
80104d91:	c3                   	ret    

80104d92 <sys_sbrk>:

int
sys_sbrk(void)
{
80104d92:	55                   	push   %ebp
80104d93:	89 e5                	mov    %esp,%ebp
80104d95:	53                   	push   %ebx
80104d96:	83 ec 1c             	sub    $0x1c,%esp
  int addr;
  int n;

  if(argint(0, &n) < 0)
80104d99:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104d9c:	50                   	push   %eax
80104d9d:	6a 00                	push   $0x0
80104d9f:	e8 b2 f2 ff ff       	call   80104056 <argint>
80104da4:	83 c4 10             	add    $0x10,%esp
80104da7:	85 c0                	test   %eax,%eax
80104da9:	78 27                	js     80104dd2 <sys_sbrk+0x40>
    return -1;
  addr = myproc()->sz;
80104dab:	e8 10 e6 ff ff       	call   801033c0 <myproc>
80104db0:	8b 18                	mov    (%eax),%ebx
  if(growproc(n) < 0)
80104db2:	83 ec 0c             	sub    $0xc,%esp
80104db5:	ff 75 f4             	pushl  -0xc(%ebp)
80104db8:	e8 0e e7 ff ff       	call   801034cb <growproc>
80104dbd:	83 c4 10             	add    $0x10,%esp
80104dc0:	85 c0                	test   %eax,%eax
80104dc2:	78 07                	js     80104dcb <sys_sbrk+0x39>
    return -1;
  return addr;
}
80104dc4:	89 d8                	mov    %ebx,%eax
80104dc6:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104dc9:	c9                   	leave  
80104dca:	c3                   	ret    
    return -1;
80104dcb:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104dd0:	eb f2                	jmp    80104dc4 <sys_sbrk+0x32>
    return -1;
80104dd2:	bb ff ff ff ff       	mov    $0xffffffff,%ebx
80104dd7:	eb eb                	jmp    80104dc4 <sys_sbrk+0x32>

80104dd9 <sys_sleep>:

int
sys_sleep(void)
{
80104dd9:	55                   	push   %ebp
80104dda:	89 e5                	mov    %esp,%ebp
80104ddc:	53                   	push   %ebx
80104ddd:	83 ec 1c             	sub    $0x1c,%esp
  int n;
  uint ticks0;

  if(argint(0, &n) < 0)
80104de0:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104de3:	50                   	push   %eax
80104de4:	6a 00                	push   $0x0
80104de6:	e8 6b f2 ff ff       	call   80104056 <argint>
80104deb:	83 c4 10             	add    $0x10,%esp
80104dee:	85 c0                	test   %eax,%eax
80104df0:	78 75                	js     80104e67 <sys_sleep+0x8e>
    return -1;
  acquire(&tickslock);
80104df2:	83 ec 0c             	sub    $0xc,%esp
80104df5:	68 a0 4c 13 80       	push   $0x80134ca0
80104dfa:	e8 60 ef ff ff       	call   80103d5f <acquire>
  ticks0 = ticks;
80104dff:	8b 1d e0 54 13 80    	mov    0x801354e0,%ebx
  while(ticks - ticks0 < n){
80104e05:	83 c4 10             	add    $0x10,%esp
80104e08:	a1 e0 54 13 80       	mov    0x801354e0,%eax
80104e0d:	29 d8                	sub    %ebx,%eax
80104e0f:	3b 45 f4             	cmp    -0xc(%ebp),%eax
80104e12:	73 39                	jae    80104e4d <sys_sleep+0x74>
    if(myproc()->killed){
80104e14:	e8 a7 e5 ff ff       	call   801033c0 <myproc>
80104e19:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80104e1d:	75 17                	jne    80104e36 <sys_sleep+0x5d>
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
80104e1f:	83 ec 08             	sub    $0x8,%esp
80104e22:	68 a0 4c 13 80       	push   $0x80134ca0
80104e27:	68 e0 54 13 80       	push   $0x801354e0
80104e2c:	e8 33 ea ff ff       	call   80103864 <sleep>
80104e31:	83 c4 10             	add    $0x10,%esp
80104e34:	eb d2                	jmp    80104e08 <sys_sleep+0x2f>
      release(&tickslock);
80104e36:	83 ec 0c             	sub    $0xc,%esp
80104e39:	68 a0 4c 13 80       	push   $0x80134ca0
80104e3e:	e8 81 ef ff ff       	call   80103dc4 <release>
      return -1;
80104e43:	83 c4 10             	add    $0x10,%esp
80104e46:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e4b:	eb 15                	jmp    80104e62 <sys_sleep+0x89>
  }
  release(&tickslock);
80104e4d:	83 ec 0c             	sub    $0xc,%esp
80104e50:	68 a0 4c 13 80       	push   $0x80134ca0
80104e55:	e8 6a ef ff ff       	call   80103dc4 <release>
  return 0;
80104e5a:	83 c4 10             	add    $0x10,%esp
80104e5d:	b8 00 00 00 00       	mov    $0x0,%eax
}
80104e62:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e65:	c9                   	leave  
80104e66:	c3                   	ret    
    return -1;
80104e67:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104e6c:	eb f4                	jmp    80104e62 <sys_sleep+0x89>

80104e6e <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
int
sys_uptime(void)
{
80104e6e:	55                   	push   %ebp
80104e6f:	89 e5                	mov    %esp,%ebp
80104e71:	53                   	push   %ebx
80104e72:	83 ec 10             	sub    $0x10,%esp
  uint xticks;

  acquire(&tickslock);
80104e75:	68 a0 4c 13 80       	push   $0x80134ca0
80104e7a:	e8 e0 ee ff ff       	call   80103d5f <acquire>
  xticks = ticks;
80104e7f:	8b 1d e0 54 13 80    	mov    0x801354e0,%ebx
  release(&tickslock);
80104e85:	c7 04 24 a0 4c 13 80 	movl   $0x80134ca0,(%esp)
80104e8c:	e8 33 ef ff ff       	call   80103dc4 <release>
  return xticks;
}
80104e91:	89 d8                	mov    %ebx,%eax
80104e93:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80104e96:	c9                   	leave  
80104e97:	c3                   	ret    

80104e98 <sys_dump_physmem>:

// used for p5
// find which process owns each frame of phys mem
int
sys_dump_physmem(void)
{
80104e98:	55                   	push   %ebp
80104e99:	89 e5                	mov    %esp,%ebp
80104e9b:	83 ec 24             	sub    $0x24,%esp
  int *frames;
  int *pids;
  int numframes;
  cprintf("sys_dump_physmem in sysproc.c\n");
80104e9e:	68 c0 6e 10 80       	push   $0x80106ec0
80104ea3:	e8 63 b7 ff ff       	call   8010060b <cprintf>
  if(argptr(0, (char**)&frames, sizeof(int*)) < 0)
80104ea8:	83 c4 0c             	add    $0xc,%esp
80104eab:	6a 04                	push   $0x4
80104ead:	8d 45 f4             	lea    -0xc(%ebp),%eax
80104eb0:	50                   	push   %eax
80104eb1:	6a 00                	push   $0x0
80104eb3:	e8 c6 f1 ff ff       	call   8010407e <argptr>
80104eb8:	83 c4 10             	add    $0x10,%esp
80104ebb:	85 c0                	test   %eax,%eax
80104ebd:	78 42                	js     80104f01 <sys_dump_physmem+0x69>
    return -1;
  if(argptr(1, (char**)&pids, sizeof(int*)) < 0)
80104ebf:	83 ec 04             	sub    $0x4,%esp
80104ec2:	6a 04                	push   $0x4
80104ec4:	8d 45 f0             	lea    -0x10(%ebp),%eax
80104ec7:	50                   	push   %eax
80104ec8:	6a 01                	push   $0x1
80104eca:	e8 af f1 ff ff       	call   8010407e <argptr>
80104ecf:	83 c4 10             	add    $0x10,%esp
80104ed2:	85 c0                	test   %eax,%eax
80104ed4:	78 32                	js     80104f08 <sys_dump_physmem+0x70>
    return -1;
  if(argint(2, &numframes) < 0)
80104ed6:	83 ec 08             	sub    $0x8,%esp
80104ed9:	8d 45 ec             	lea    -0x14(%ebp),%eax
80104edc:	50                   	push   %eax
80104edd:	6a 02                	push   $0x2
80104edf:	e8 72 f1 ff ff       	call   80104056 <argint>
80104ee4:	83 c4 10             	add    $0x10,%esp
80104ee7:	85 c0                	test   %eax,%eax
80104ee9:	78 24                	js     80104f0f <sys_dump_physmem+0x77>
    return -1;
  return dump_physmem(frames, pids, numframes);
80104eeb:	83 ec 04             	sub    $0x4,%esp
80104eee:	ff 75 ec             	pushl  -0x14(%ebp)
80104ef1:	ff 75 f0             	pushl  -0x10(%ebp)
80104ef4:	ff 75 f4             	pushl  -0xc(%ebp)
80104ef7:	e8 55 d3 ff ff       	call   80102251 <dump_physmem>
80104efc:	83 c4 10             	add    $0x10,%esp
}
80104eff:	c9                   	leave  
80104f00:	c3                   	ret    
    return -1;
80104f01:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f06:	eb f7                	jmp    80104eff <sys_dump_physmem+0x67>
    return -1;
80104f08:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f0d:	eb f0                	jmp    80104eff <sys_dump_physmem+0x67>
    return -1;
80104f0f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80104f14:	eb e9                	jmp    80104eff <sys_dump_physmem+0x67>

80104f16 <alltraps>:

  # vectors.S sends all traps here.
.globl alltraps
alltraps:
  # Build trap frame.
  pushl %ds
80104f16:	1e                   	push   %ds
  pushl %es
80104f17:	06                   	push   %es
  pushl %fs
80104f18:	0f a0                	push   %fs
  pushl %gs
80104f1a:	0f a8                	push   %gs
  pushal
80104f1c:	60                   	pusha  
  
  # Set up data segments.
  movw $(SEG_KDATA<<3), %ax
80104f1d:	66 b8 10 00          	mov    $0x10,%ax
  movw %ax, %ds
80104f21:	8e d8                	mov    %eax,%ds
  movw %ax, %es
80104f23:	8e c0                	mov    %eax,%es

  # Call trap(tf), where tf=%esp
  pushl %esp
80104f25:	54                   	push   %esp
  call trap
80104f26:	e8 e3 00 00 00       	call   8010500e <trap>
  addl $4, %esp
80104f2b:	83 c4 04             	add    $0x4,%esp

80104f2e <trapret>:

  # Return falls through to trapret...
.globl trapret
trapret:
  popal
80104f2e:	61                   	popa   
  popl %gs
80104f2f:	0f a9                	pop    %gs
  popl %fs
80104f31:	0f a1                	pop    %fs
  popl %es
80104f33:	07                   	pop    %es
  popl %ds
80104f34:	1f                   	pop    %ds
  addl $0x8, %esp  # trapno and errcode
80104f35:	83 c4 08             	add    $0x8,%esp
  iret
80104f38:	cf                   	iret   

80104f39 <tvinit>:
struct spinlock tickslock;
uint ticks;

void
tvinit(void)
{
80104f39:	55                   	push   %ebp
80104f3a:	89 e5                	mov    %esp,%ebp
80104f3c:	83 ec 08             	sub    $0x8,%esp
  int i;

  for(i = 0; i < 256; i++)
80104f3f:	b8 00 00 00 00       	mov    $0x0,%eax
80104f44:	eb 4a                	jmp    80104f90 <tvinit+0x57>
    SETGATE(idt[i], 0, SEG_KCODE<<3, vectors[i], 0);
80104f46:	8b 0c 85 08 a0 10 80 	mov    -0x7fef5ff8(,%eax,4),%ecx
80104f4d:	66 89 0c c5 e0 4c 13 	mov    %cx,-0x7fecb320(,%eax,8)
80104f54:	80 
80104f55:	66 c7 04 c5 e2 4c 13 	movw   $0x8,-0x7fecb31e(,%eax,8)
80104f5c:	80 08 00 
80104f5f:	c6 04 c5 e4 4c 13 80 	movb   $0x0,-0x7fecb31c(,%eax,8)
80104f66:	00 
80104f67:	0f b6 14 c5 e5 4c 13 	movzbl -0x7fecb31b(,%eax,8),%edx
80104f6e:	80 
80104f6f:	83 e2 f0             	and    $0xfffffff0,%edx
80104f72:	83 ca 0e             	or     $0xe,%edx
80104f75:	83 e2 8f             	and    $0xffffff8f,%edx
80104f78:	83 ca 80             	or     $0xffffff80,%edx
80104f7b:	88 14 c5 e5 4c 13 80 	mov    %dl,-0x7fecb31b(,%eax,8)
80104f82:	c1 e9 10             	shr    $0x10,%ecx
80104f85:	66 89 0c c5 e6 4c 13 	mov    %cx,-0x7fecb31a(,%eax,8)
80104f8c:	80 
  for(i = 0; i < 256; i++)
80104f8d:	83 c0 01             	add    $0x1,%eax
80104f90:	3d ff 00 00 00       	cmp    $0xff,%eax
80104f95:	7e af                	jle    80104f46 <tvinit+0xd>
  SETGATE(idt[T_SYSCALL], 1, SEG_KCODE<<3, vectors[T_SYSCALL], DPL_USER);
80104f97:	8b 15 08 a1 10 80    	mov    0x8010a108,%edx
80104f9d:	66 89 15 e0 4e 13 80 	mov    %dx,0x80134ee0
80104fa4:	66 c7 05 e2 4e 13 80 	movw   $0x8,0x80134ee2
80104fab:	08 00 
80104fad:	c6 05 e4 4e 13 80 00 	movb   $0x0,0x80134ee4
80104fb4:	0f b6 05 e5 4e 13 80 	movzbl 0x80134ee5,%eax
80104fbb:	83 c8 0f             	or     $0xf,%eax
80104fbe:	83 e0 ef             	and    $0xffffffef,%eax
80104fc1:	83 c8 e0             	or     $0xffffffe0,%eax
80104fc4:	a2 e5 4e 13 80       	mov    %al,0x80134ee5
80104fc9:	c1 ea 10             	shr    $0x10,%edx
80104fcc:	66 89 15 e6 4e 13 80 	mov    %dx,0x80134ee6

  initlock(&tickslock, "time");
80104fd3:	83 ec 08             	sub    $0x8,%esp
80104fd6:	68 df 6e 10 80       	push   $0x80106edf
80104fdb:	68 a0 4c 13 80       	push   $0x80134ca0
80104fe0:	e8 3e ec ff ff       	call   80103c23 <initlock>
}
80104fe5:	83 c4 10             	add    $0x10,%esp
80104fe8:	c9                   	leave  
80104fe9:	c3                   	ret    

80104fea <idtinit>:

void
idtinit(void)
{
80104fea:	55                   	push   %ebp
80104feb:	89 e5                	mov    %esp,%ebp
80104fed:	83 ec 10             	sub    $0x10,%esp
  pd[0] = size-1;
80104ff0:	66 c7 45 fa ff 07    	movw   $0x7ff,-0x6(%ebp)
  pd[1] = (uint)p;
80104ff6:	b8 e0 4c 13 80       	mov    $0x80134ce0,%eax
80104ffb:	66 89 45 fc          	mov    %ax,-0x4(%ebp)
  pd[2] = (uint)p >> 16;
80104fff:	c1 e8 10             	shr    $0x10,%eax
80105002:	66 89 45 fe          	mov    %ax,-0x2(%ebp)
  asm volatile("lidt (%0)" : : "r" (pd));
80105006:	8d 45 fa             	lea    -0x6(%ebp),%eax
80105009:	0f 01 18             	lidtl  (%eax)
  lidt(idt, sizeof(idt));
}
8010500c:	c9                   	leave  
8010500d:	c3                   	ret    

8010500e <trap>:

void
trap(struct trapframe *tf)
{
8010500e:	55                   	push   %ebp
8010500f:	89 e5                	mov    %esp,%ebp
80105011:	57                   	push   %edi
80105012:	56                   	push   %esi
80105013:	53                   	push   %ebx
80105014:	83 ec 1c             	sub    $0x1c,%esp
80105017:	8b 5d 08             	mov    0x8(%ebp),%ebx
  if(tf->trapno == T_SYSCALL){
8010501a:	8b 43 30             	mov    0x30(%ebx),%eax
8010501d:	83 f8 40             	cmp    $0x40,%eax
80105020:	74 13                	je     80105035 <trap+0x27>
    if(myproc()->killed)
      exit();
    return;
  }

  switch(tf->trapno){
80105022:	83 e8 20             	sub    $0x20,%eax
80105025:	83 f8 1f             	cmp    $0x1f,%eax
80105028:	0f 87 3a 01 00 00    	ja     80105168 <trap+0x15a>
8010502e:	ff 24 85 88 6f 10 80 	jmp    *-0x7fef9078(,%eax,4)
    if(myproc()->killed)
80105035:	e8 86 e3 ff ff       	call   801033c0 <myproc>
8010503a:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
8010503e:	75 1f                	jne    8010505f <trap+0x51>
    myproc()->tf = tf;
80105040:	e8 7b e3 ff ff       	call   801033c0 <myproc>
80105045:	89 58 18             	mov    %ebx,0x18(%eax)
    syscall();
80105048:	e8 cc f0 ff ff       	call   80104119 <syscall>
    if(myproc()->killed)
8010504d:	e8 6e e3 ff ff       	call   801033c0 <myproc>
80105052:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105056:	74 7e                	je     801050d6 <trap+0xc8>
      exit();
80105058:	e8 0f e7 ff ff       	call   8010376c <exit>
8010505d:	eb 77                	jmp    801050d6 <trap+0xc8>
      exit();
8010505f:	e8 08 e7 ff ff       	call   8010376c <exit>
80105064:	eb da                	jmp    80105040 <trap+0x32>
  case T_IRQ0 + IRQ_TIMER:
    if(cpuid() == 0){
80105066:	e8 3a e3 ff ff       	call   801033a5 <cpuid>
8010506b:	85 c0                	test   %eax,%eax
8010506d:	74 6f                	je     801050de <trap+0xd0>
      acquire(&tickslock);
      ticks++;
      wakeup(&ticks);
      release(&tickslock);
    }
    lapiceoi();
8010506f:	e8 ef d4 ff ff       	call   80102563 <lapiceoi>
  }

  // Force process exit if it has been killed and is in user space.
  // (If it is still executing in the kernel, let it keep running
  // until it gets to the regular system call return.)
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
80105074:	e8 47 e3 ff ff       	call   801033c0 <myproc>
80105079:	85 c0                	test   %eax,%eax
8010507b:	74 1c                	je     80105099 <trap+0x8b>
8010507d:	e8 3e e3 ff ff       	call   801033c0 <myproc>
80105082:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
80105086:	74 11                	je     80105099 <trap+0x8b>
80105088:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
8010508c:	83 e0 03             	and    $0x3,%eax
8010508f:	66 83 f8 03          	cmp    $0x3,%ax
80105093:	0f 84 62 01 00 00    	je     801051fb <trap+0x1ed>
    exit();

  // Force process to give up CPU on clock tick.
  // If interrupts were on while locks held, would need to check nlock.
  if(myproc() && myproc()->state == RUNNING &&
80105099:	e8 22 e3 ff ff       	call   801033c0 <myproc>
8010509e:	85 c0                	test   %eax,%eax
801050a0:	74 0f                	je     801050b1 <trap+0xa3>
801050a2:	e8 19 e3 ff ff       	call   801033c0 <myproc>
801050a7:	83 78 0c 04          	cmpl   $0x4,0xc(%eax)
801050ab:	0f 84 54 01 00 00    	je     80105205 <trap+0x1f7>
     tf->trapno == T_IRQ0+IRQ_TIMER)
    yield();

  // Check if the process has been killed since we yielded
  if(myproc() && myproc()->killed && (tf->cs&3) == DPL_USER)
801050b1:	e8 0a e3 ff ff       	call   801033c0 <myproc>
801050b6:	85 c0                	test   %eax,%eax
801050b8:	74 1c                	je     801050d6 <trap+0xc8>
801050ba:	e8 01 e3 ff ff       	call   801033c0 <myproc>
801050bf:	83 78 24 00          	cmpl   $0x0,0x24(%eax)
801050c3:	74 11                	je     801050d6 <trap+0xc8>
801050c5:	0f b7 43 3c          	movzwl 0x3c(%ebx),%eax
801050c9:	83 e0 03             	and    $0x3,%eax
801050cc:	66 83 f8 03          	cmp    $0x3,%ax
801050d0:	0f 84 43 01 00 00    	je     80105219 <trap+0x20b>
    exit();
}
801050d6:	8d 65 f4             	lea    -0xc(%ebp),%esp
801050d9:	5b                   	pop    %ebx
801050da:	5e                   	pop    %esi
801050db:	5f                   	pop    %edi
801050dc:	5d                   	pop    %ebp
801050dd:	c3                   	ret    
      acquire(&tickslock);
801050de:	83 ec 0c             	sub    $0xc,%esp
801050e1:	68 a0 4c 13 80       	push   $0x80134ca0
801050e6:	e8 74 ec ff ff       	call   80103d5f <acquire>
      ticks++;
801050eb:	83 05 e0 54 13 80 01 	addl   $0x1,0x801354e0
      wakeup(&ticks);
801050f2:	c7 04 24 e0 54 13 80 	movl   $0x801354e0,(%esp)
801050f9:	e8 cb e8 ff ff       	call   801039c9 <wakeup>
      release(&tickslock);
801050fe:	c7 04 24 a0 4c 13 80 	movl   $0x80134ca0,(%esp)
80105105:	e8 ba ec ff ff       	call   80103dc4 <release>
8010510a:	83 c4 10             	add    $0x10,%esp
8010510d:	e9 5d ff ff ff       	jmp    8010506f <trap+0x61>
    ideintr();
80105112:	e8 5c cc ff ff       	call   80101d73 <ideintr>
    lapiceoi();
80105117:	e8 47 d4 ff ff       	call   80102563 <lapiceoi>
    break;
8010511c:	e9 53 ff ff ff       	jmp    80105074 <trap+0x66>
    kbdintr();
80105121:	e8 81 d2 ff ff       	call   801023a7 <kbdintr>
    lapiceoi();
80105126:	e8 38 d4 ff ff       	call   80102563 <lapiceoi>
    break;
8010512b:	e9 44 ff ff ff       	jmp    80105074 <trap+0x66>
    uartintr();
80105130:	e8 05 02 00 00       	call   8010533a <uartintr>
    lapiceoi();
80105135:	e8 29 d4 ff ff       	call   80102563 <lapiceoi>
    break;
8010513a:	e9 35 ff ff ff       	jmp    80105074 <trap+0x66>
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
8010513f:	8b 7b 38             	mov    0x38(%ebx),%edi
            cpuid(), tf->cs, tf->eip);
80105142:	0f b7 73 3c          	movzwl 0x3c(%ebx),%esi
    cprintf("cpu%d: spurious interrupt at %x:%x\n",
80105146:	e8 5a e2 ff ff       	call   801033a5 <cpuid>
8010514b:	57                   	push   %edi
8010514c:	0f b7 f6             	movzwl %si,%esi
8010514f:	56                   	push   %esi
80105150:	50                   	push   %eax
80105151:	68 ec 6e 10 80       	push   $0x80106eec
80105156:	e8 b0 b4 ff ff       	call   8010060b <cprintf>
    lapiceoi();
8010515b:	e8 03 d4 ff ff       	call   80102563 <lapiceoi>
    break;
80105160:	83 c4 10             	add    $0x10,%esp
80105163:	e9 0c ff ff ff       	jmp    80105074 <trap+0x66>
    if(myproc() == 0 || (tf->cs&3) == 0){
80105168:	e8 53 e2 ff ff       	call   801033c0 <myproc>
8010516d:	85 c0                	test   %eax,%eax
8010516f:	74 5f                	je     801051d0 <trap+0x1c2>
80105171:	f6 43 3c 03          	testb  $0x3,0x3c(%ebx)
80105175:	74 59                	je     801051d0 <trap+0x1c2>

static inline uint
rcr2(void)
{
  uint val;
  asm volatile("movl %%cr2,%0" : "=r" (val));
80105177:	0f 20 d7             	mov    %cr2,%edi
    cprintf("pid %d %s: trap %d err %d on cpu %d "
8010517a:	8b 43 38             	mov    0x38(%ebx),%eax
8010517d:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105180:	e8 20 e2 ff ff       	call   801033a5 <cpuid>
80105185:	89 45 e0             	mov    %eax,-0x20(%ebp)
80105188:	8b 53 34             	mov    0x34(%ebx),%edx
8010518b:	89 55 dc             	mov    %edx,-0x24(%ebp)
8010518e:	8b 73 30             	mov    0x30(%ebx),%esi
            myproc()->pid, myproc()->name, tf->trapno,
80105191:	e8 2a e2 ff ff       	call   801033c0 <myproc>
80105196:	8d 48 6c             	lea    0x6c(%eax),%ecx
80105199:	89 4d d8             	mov    %ecx,-0x28(%ebp)
8010519c:	e8 1f e2 ff ff       	call   801033c0 <myproc>
    cprintf("pid %d %s: trap %d err %d on cpu %d "
801051a1:	57                   	push   %edi
801051a2:	ff 75 e4             	pushl  -0x1c(%ebp)
801051a5:	ff 75 e0             	pushl  -0x20(%ebp)
801051a8:	ff 75 dc             	pushl  -0x24(%ebp)
801051ab:	56                   	push   %esi
801051ac:	ff 75 d8             	pushl  -0x28(%ebp)
801051af:	ff 70 10             	pushl  0x10(%eax)
801051b2:	68 44 6f 10 80       	push   $0x80106f44
801051b7:	e8 4f b4 ff ff       	call   8010060b <cprintf>
    myproc()->killed = 1;
801051bc:	83 c4 20             	add    $0x20,%esp
801051bf:	e8 fc e1 ff ff       	call   801033c0 <myproc>
801051c4:	c7 40 24 01 00 00 00 	movl   $0x1,0x24(%eax)
801051cb:	e9 a4 fe ff ff       	jmp    80105074 <trap+0x66>
801051d0:	0f 20 d7             	mov    %cr2,%edi
      cprintf("unexpected trap %d from cpu %d eip %x (cr2=0x%x)\n",
801051d3:	8b 73 38             	mov    0x38(%ebx),%esi
801051d6:	e8 ca e1 ff ff       	call   801033a5 <cpuid>
801051db:	83 ec 0c             	sub    $0xc,%esp
801051de:	57                   	push   %edi
801051df:	56                   	push   %esi
801051e0:	50                   	push   %eax
801051e1:	ff 73 30             	pushl  0x30(%ebx)
801051e4:	68 10 6f 10 80       	push   $0x80106f10
801051e9:	e8 1d b4 ff ff       	call   8010060b <cprintf>
      panic("trap");
801051ee:	83 c4 14             	add    $0x14,%esp
801051f1:	68 e4 6e 10 80       	push   $0x80106ee4
801051f6:	e8 4d b1 ff ff       	call   80100348 <panic>
    exit();
801051fb:	e8 6c e5 ff ff       	call   8010376c <exit>
80105200:	e9 94 fe ff ff       	jmp    80105099 <trap+0x8b>
  if(myproc() && myproc()->state == RUNNING &&
80105205:	83 7b 30 20          	cmpl   $0x20,0x30(%ebx)
80105209:	0f 85 a2 fe ff ff    	jne    801050b1 <trap+0xa3>
    yield();
8010520f:	e8 1e e6 ff ff       	call   80103832 <yield>
80105214:	e9 98 fe ff ff       	jmp    801050b1 <trap+0xa3>
    exit();
80105219:	e8 4e e5 ff ff       	call   8010376c <exit>
8010521e:	e9 b3 fe ff ff       	jmp    801050d6 <trap+0xc8>

80105223 <uartgetc>:
  outb(COM1+0, c);
}

static int
uartgetc(void)
{
80105223:	55                   	push   %ebp
80105224:	89 e5                	mov    %esp,%ebp
  if(!uart)
80105226:	83 3d c4 a5 10 80 00 	cmpl   $0x0,0x8010a5c4
8010522d:	74 15                	je     80105244 <uartgetc+0x21>
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
8010522f:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105234:	ec                   	in     (%dx),%al
    return -1;
  if(!(inb(COM1+5) & 0x01))
80105235:	a8 01                	test   $0x1,%al
80105237:	74 12                	je     8010524b <uartgetc+0x28>
80105239:	ba f8 03 00 00       	mov    $0x3f8,%edx
8010523e:	ec                   	in     (%dx),%al
    return -1;
  return inb(COM1+0);
8010523f:	0f b6 c0             	movzbl %al,%eax
}
80105242:	5d                   	pop    %ebp
80105243:	c3                   	ret    
    return -1;
80105244:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105249:	eb f7                	jmp    80105242 <uartgetc+0x1f>
    return -1;
8010524b:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80105250:	eb f0                	jmp    80105242 <uartgetc+0x1f>

80105252 <uartputc>:
  if(!uart)
80105252:	83 3d c4 a5 10 80 00 	cmpl   $0x0,0x8010a5c4
80105259:	74 3b                	je     80105296 <uartputc+0x44>
{
8010525b:	55                   	push   %ebp
8010525c:	89 e5                	mov    %esp,%ebp
8010525e:	53                   	push   %ebx
8010525f:	83 ec 04             	sub    $0x4,%esp
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105262:	bb 00 00 00 00       	mov    $0x0,%ebx
80105267:	eb 10                	jmp    80105279 <uartputc+0x27>
    microdelay(10);
80105269:	83 ec 0c             	sub    $0xc,%esp
8010526c:	6a 0a                	push   $0xa
8010526e:	e8 0f d3 ff ff       	call   80102582 <microdelay>
  for(i = 0; i < 128 && !(inb(COM1+5) & 0x20); i++)
80105273:	83 c3 01             	add    $0x1,%ebx
80105276:	83 c4 10             	add    $0x10,%esp
80105279:	83 fb 7f             	cmp    $0x7f,%ebx
8010527c:	7f 0a                	jg     80105288 <uartputc+0x36>
8010527e:	ba fd 03 00 00       	mov    $0x3fd,%edx
80105283:	ec                   	in     (%dx),%al
80105284:	a8 20                	test   $0x20,%al
80105286:	74 e1                	je     80105269 <uartputc+0x17>
  asm volatile("out %0,%1" : : "a" (data), "d" (port));
80105288:	8b 45 08             	mov    0x8(%ebp),%eax
8010528b:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105290:	ee                   	out    %al,(%dx)
}
80105291:	8b 5d fc             	mov    -0x4(%ebp),%ebx
80105294:	c9                   	leave  
80105295:	c3                   	ret    
80105296:	f3 c3                	repz ret 

80105298 <uartinit>:
{
80105298:	55                   	push   %ebp
80105299:	89 e5                	mov    %esp,%ebp
8010529b:	56                   	push   %esi
8010529c:	53                   	push   %ebx
8010529d:	b9 00 00 00 00       	mov    $0x0,%ecx
801052a2:	ba fa 03 00 00       	mov    $0x3fa,%edx
801052a7:	89 c8                	mov    %ecx,%eax
801052a9:	ee                   	out    %al,(%dx)
801052aa:	be fb 03 00 00       	mov    $0x3fb,%esi
801052af:	b8 80 ff ff ff       	mov    $0xffffff80,%eax
801052b4:	89 f2                	mov    %esi,%edx
801052b6:	ee                   	out    %al,(%dx)
801052b7:	b8 0c 00 00 00       	mov    $0xc,%eax
801052bc:	ba f8 03 00 00       	mov    $0x3f8,%edx
801052c1:	ee                   	out    %al,(%dx)
801052c2:	bb f9 03 00 00       	mov    $0x3f9,%ebx
801052c7:	89 c8                	mov    %ecx,%eax
801052c9:	89 da                	mov    %ebx,%edx
801052cb:	ee                   	out    %al,(%dx)
801052cc:	b8 03 00 00 00       	mov    $0x3,%eax
801052d1:	89 f2                	mov    %esi,%edx
801052d3:	ee                   	out    %al,(%dx)
801052d4:	ba fc 03 00 00       	mov    $0x3fc,%edx
801052d9:	89 c8                	mov    %ecx,%eax
801052db:	ee                   	out    %al,(%dx)
801052dc:	b8 01 00 00 00       	mov    $0x1,%eax
801052e1:	89 da                	mov    %ebx,%edx
801052e3:	ee                   	out    %al,(%dx)
  asm volatile("in %1,%0" : "=a" (data) : "d" (port));
801052e4:	ba fd 03 00 00       	mov    $0x3fd,%edx
801052e9:	ec                   	in     (%dx),%al
  if(inb(COM1+5) == 0xFF)
801052ea:	3c ff                	cmp    $0xff,%al
801052ec:	74 45                	je     80105333 <uartinit+0x9b>
  uart = 1;
801052ee:	c7 05 c4 a5 10 80 01 	movl   $0x1,0x8010a5c4
801052f5:	00 00 00 
801052f8:	ba fa 03 00 00       	mov    $0x3fa,%edx
801052fd:	ec                   	in     (%dx),%al
801052fe:	ba f8 03 00 00       	mov    $0x3f8,%edx
80105303:	ec                   	in     (%dx),%al
  ioapicenable(IRQ_COM1, 0);
80105304:	83 ec 08             	sub    $0x8,%esp
80105307:	6a 00                	push   $0x0
80105309:	6a 04                	push   $0x4
8010530b:	e8 6e cc ff ff       	call   80101f7e <ioapicenable>
  for(p="xv6...\n"; *p; p++)
80105310:	83 c4 10             	add    $0x10,%esp
80105313:	bb 08 70 10 80       	mov    $0x80107008,%ebx
80105318:	eb 12                	jmp    8010532c <uartinit+0x94>
    uartputc(*p);
8010531a:	83 ec 0c             	sub    $0xc,%esp
8010531d:	0f be c0             	movsbl %al,%eax
80105320:	50                   	push   %eax
80105321:	e8 2c ff ff ff       	call   80105252 <uartputc>
  for(p="xv6...\n"; *p; p++)
80105326:	83 c3 01             	add    $0x1,%ebx
80105329:	83 c4 10             	add    $0x10,%esp
8010532c:	0f b6 03             	movzbl (%ebx),%eax
8010532f:	84 c0                	test   %al,%al
80105331:	75 e7                	jne    8010531a <uartinit+0x82>
}
80105333:	8d 65 f8             	lea    -0x8(%ebp),%esp
80105336:	5b                   	pop    %ebx
80105337:	5e                   	pop    %esi
80105338:	5d                   	pop    %ebp
80105339:	c3                   	ret    

8010533a <uartintr>:

void
uartintr(void)
{
8010533a:	55                   	push   %ebp
8010533b:	89 e5                	mov    %esp,%ebp
8010533d:	83 ec 14             	sub    $0x14,%esp
  consoleintr(uartgetc);
80105340:	68 23 52 10 80       	push   $0x80105223
80105345:	e8 f4 b3 ff ff       	call   8010073e <consoleintr>
}
8010534a:	83 c4 10             	add    $0x10,%esp
8010534d:	c9                   	leave  
8010534e:	c3                   	ret    

8010534f <vector0>:
# generated by vectors.pl - do not edit
# handlers
.globl alltraps
.globl vector0
vector0:
  pushl $0
8010534f:	6a 00                	push   $0x0
  pushl $0
80105351:	6a 00                	push   $0x0
  jmp alltraps
80105353:	e9 be fb ff ff       	jmp    80104f16 <alltraps>

80105358 <vector1>:
.globl vector1
vector1:
  pushl $0
80105358:	6a 00                	push   $0x0
  pushl $1
8010535a:	6a 01                	push   $0x1
  jmp alltraps
8010535c:	e9 b5 fb ff ff       	jmp    80104f16 <alltraps>

80105361 <vector2>:
.globl vector2
vector2:
  pushl $0
80105361:	6a 00                	push   $0x0
  pushl $2
80105363:	6a 02                	push   $0x2
  jmp alltraps
80105365:	e9 ac fb ff ff       	jmp    80104f16 <alltraps>

8010536a <vector3>:
.globl vector3
vector3:
  pushl $0
8010536a:	6a 00                	push   $0x0
  pushl $3
8010536c:	6a 03                	push   $0x3
  jmp alltraps
8010536e:	e9 a3 fb ff ff       	jmp    80104f16 <alltraps>

80105373 <vector4>:
.globl vector4
vector4:
  pushl $0
80105373:	6a 00                	push   $0x0
  pushl $4
80105375:	6a 04                	push   $0x4
  jmp alltraps
80105377:	e9 9a fb ff ff       	jmp    80104f16 <alltraps>

8010537c <vector5>:
.globl vector5
vector5:
  pushl $0
8010537c:	6a 00                	push   $0x0
  pushl $5
8010537e:	6a 05                	push   $0x5
  jmp alltraps
80105380:	e9 91 fb ff ff       	jmp    80104f16 <alltraps>

80105385 <vector6>:
.globl vector6
vector6:
  pushl $0
80105385:	6a 00                	push   $0x0
  pushl $6
80105387:	6a 06                	push   $0x6
  jmp alltraps
80105389:	e9 88 fb ff ff       	jmp    80104f16 <alltraps>

8010538e <vector7>:
.globl vector7
vector7:
  pushl $0
8010538e:	6a 00                	push   $0x0
  pushl $7
80105390:	6a 07                	push   $0x7
  jmp alltraps
80105392:	e9 7f fb ff ff       	jmp    80104f16 <alltraps>

80105397 <vector8>:
.globl vector8
vector8:
  pushl $8
80105397:	6a 08                	push   $0x8
  jmp alltraps
80105399:	e9 78 fb ff ff       	jmp    80104f16 <alltraps>

8010539e <vector9>:
.globl vector9
vector9:
  pushl $0
8010539e:	6a 00                	push   $0x0
  pushl $9
801053a0:	6a 09                	push   $0x9
  jmp alltraps
801053a2:	e9 6f fb ff ff       	jmp    80104f16 <alltraps>

801053a7 <vector10>:
.globl vector10
vector10:
  pushl $10
801053a7:	6a 0a                	push   $0xa
  jmp alltraps
801053a9:	e9 68 fb ff ff       	jmp    80104f16 <alltraps>

801053ae <vector11>:
.globl vector11
vector11:
  pushl $11
801053ae:	6a 0b                	push   $0xb
  jmp alltraps
801053b0:	e9 61 fb ff ff       	jmp    80104f16 <alltraps>

801053b5 <vector12>:
.globl vector12
vector12:
  pushl $12
801053b5:	6a 0c                	push   $0xc
  jmp alltraps
801053b7:	e9 5a fb ff ff       	jmp    80104f16 <alltraps>

801053bc <vector13>:
.globl vector13
vector13:
  pushl $13
801053bc:	6a 0d                	push   $0xd
  jmp alltraps
801053be:	e9 53 fb ff ff       	jmp    80104f16 <alltraps>

801053c3 <vector14>:
.globl vector14
vector14:
  pushl $14
801053c3:	6a 0e                	push   $0xe
  jmp alltraps
801053c5:	e9 4c fb ff ff       	jmp    80104f16 <alltraps>

801053ca <vector15>:
.globl vector15
vector15:
  pushl $0
801053ca:	6a 00                	push   $0x0
  pushl $15
801053cc:	6a 0f                	push   $0xf
  jmp alltraps
801053ce:	e9 43 fb ff ff       	jmp    80104f16 <alltraps>

801053d3 <vector16>:
.globl vector16
vector16:
  pushl $0
801053d3:	6a 00                	push   $0x0
  pushl $16
801053d5:	6a 10                	push   $0x10
  jmp alltraps
801053d7:	e9 3a fb ff ff       	jmp    80104f16 <alltraps>

801053dc <vector17>:
.globl vector17
vector17:
  pushl $17
801053dc:	6a 11                	push   $0x11
  jmp alltraps
801053de:	e9 33 fb ff ff       	jmp    80104f16 <alltraps>

801053e3 <vector18>:
.globl vector18
vector18:
  pushl $0
801053e3:	6a 00                	push   $0x0
  pushl $18
801053e5:	6a 12                	push   $0x12
  jmp alltraps
801053e7:	e9 2a fb ff ff       	jmp    80104f16 <alltraps>

801053ec <vector19>:
.globl vector19
vector19:
  pushl $0
801053ec:	6a 00                	push   $0x0
  pushl $19
801053ee:	6a 13                	push   $0x13
  jmp alltraps
801053f0:	e9 21 fb ff ff       	jmp    80104f16 <alltraps>

801053f5 <vector20>:
.globl vector20
vector20:
  pushl $0
801053f5:	6a 00                	push   $0x0
  pushl $20
801053f7:	6a 14                	push   $0x14
  jmp alltraps
801053f9:	e9 18 fb ff ff       	jmp    80104f16 <alltraps>

801053fe <vector21>:
.globl vector21
vector21:
  pushl $0
801053fe:	6a 00                	push   $0x0
  pushl $21
80105400:	6a 15                	push   $0x15
  jmp alltraps
80105402:	e9 0f fb ff ff       	jmp    80104f16 <alltraps>

80105407 <vector22>:
.globl vector22
vector22:
  pushl $0
80105407:	6a 00                	push   $0x0
  pushl $22
80105409:	6a 16                	push   $0x16
  jmp alltraps
8010540b:	e9 06 fb ff ff       	jmp    80104f16 <alltraps>

80105410 <vector23>:
.globl vector23
vector23:
  pushl $0
80105410:	6a 00                	push   $0x0
  pushl $23
80105412:	6a 17                	push   $0x17
  jmp alltraps
80105414:	e9 fd fa ff ff       	jmp    80104f16 <alltraps>

80105419 <vector24>:
.globl vector24
vector24:
  pushl $0
80105419:	6a 00                	push   $0x0
  pushl $24
8010541b:	6a 18                	push   $0x18
  jmp alltraps
8010541d:	e9 f4 fa ff ff       	jmp    80104f16 <alltraps>

80105422 <vector25>:
.globl vector25
vector25:
  pushl $0
80105422:	6a 00                	push   $0x0
  pushl $25
80105424:	6a 19                	push   $0x19
  jmp alltraps
80105426:	e9 eb fa ff ff       	jmp    80104f16 <alltraps>

8010542b <vector26>:
.globl vector26
vector26:
  pushl $0
8010542b:	6a 00                	push   $0x0
  pushl $26
8010542d:	6a 1a                	push   $0x1a
  jmp alltraps
8010542f:	e9 e2 fa ff ff       	jmp    80104f16 <alltraps>

80105434 <vector27>:
.globl vector27
vector27:
  pushl $0
80105434:	6a 00                	push   $0x0
  pushl $27
80105436:	6a 1b                	push   $0x1b
  jmp alltraps
80105438:	e9 d9 fa ff ff       	jmp    80104f16 <alltraps>

8010543d <vector28>:
.globl vector28
vector28:
  pushl $0
8010543d:	6a 00                	push   $0x0
  pushl $28
8010543f:	6a 1c                	push   $0x1c
  jmp alltraps
80105441:	e9 d0 fa ff ff       	jmp    80104f16 <alltraps>

80105446 <vector29>:
.globl vector29
vector29:
  pushl $0
80105446:	6a 00                	push   $0x0
  pushl $29
80105448:	6a 1d                	push   $0x1d
  jmp alltraps
8010544a:	e9 c7 fa ff ff       	jmp    80104f16 <alltraps>

8010544f <vector30>:
.globl vector30
vector30:
  pushl $0
8010544f:	6a 00                	push   $0x0
  pushl $30
80105451:	6a 1e                	push   $0x1e
  jmp alltraps
80105453:	e9 be fa ff ff       	jmp    80104f16 <alltraps>

80105458 <vector31>:
.globl vector31
vector31:
  pushl $0
80105458:	6a 00                	push   $0x0
  pushl $31
8010545a:	6a 1f                	push   $0x1f
  jmp alltraps
8010545c:	e9 b5 fa ff ff       	jmp    80104f16 <alltraps>

80105461 <vector32>:
.globl vector32
vector32:
  pushl $0
80105461:	6a 00                	push   $0x0
  pushl $32
80105463:	6a 20                	push   $0x20
  jmp alltraps
80105465:	e9 ac fa ff ff       	jmp    80104f16 <alltraps>

8010546a <vector33>:
.globl vector33
vector33:
  pushl $0
8010546a:	6a 00                	push   $0x0
  pushl $33
8010546c:	6a 21                	push   $0x21
  jmp alltraps
8010546e:	e9 a3 fa ff ff       	jmp    80104f16 <alltraps>

80105473 <vector34>:
.globl vector34
vector34:
  pushl $0
80105473:	6a 00                	push   $0x0
  pushl $34
80105475:	6a 22                	push   $0x22
  jmp alltraps
80105477:	e9 9a fa ff ff       	jmp    80104f16 <alltraps>

8010547c <vector35>:
.globl vector35
vector35:
  pushl $0
8010547c:	6a 00                	push   $0x0
  pushl $35
8010547e:	6a 23                	push   $0x23
  jmp alltraps
80105480:	e9 91 fa ff ff       	jmp    80104f16 <alltraps>

80105485 <vector36>:
.globl vector36
vector36:
  pushl $0
80105485:	6a 00                	push   $0x0
  pushl $36
80105487:	6a 24                	push   $0x24
  jmp alltraps
80105489:	e9 88 fa ff ff       	jmp    80104f16 <alltraps>

8010548e <vector37>:
.globl vector37
vector37:
  pushl $0
8010548e:	6a 00                	push   $0x0
  pushl $37
80105490:	6a 25                	push   $0x25
  jmp alltraps
80105492:	e9 7f fa ff ff       	jmp    80104f16 <alltraps>

80105497 <vector38>:
.globl vector38
vector38:
  pushl $0
80105497:	6a 00                	push   $0x0
  pushl $38
80105499:	6a 26                	push   $0x26
  jmp alltraps
8010549b:	e9 76 fa ff ff       	jmp    80104f16 <alltraps>

801054a0 <vector39>:
.globl vector39
vector39:
  pushl $0
801054a0:	6a 00                	push   $0x0
  pushl $39
801054a2:	6a 27                	push   $0x27
  jmp alltraps
801054a4:	e9 6d fa ff ff       	jmp    80104f16 <alltraps>

801054a9 <vector40>:
.globl vector40
vector40:
  pushl $0
801054a9:	6a 00                	push   $0x0
  pushl $40
801054ab:	6a 28                	push   $0x28
  jmp alltraps
801054ad:	e9 64 fa ff ff       	jmp    80104f16 <alltraps>

801054b2 <vector41>:
.globl vector41
vector41:
  pushl $0
801054b2:	6a 00                	push   $0x0
  pushl $41
801054b4:	6a 29                	push   $0x29
  jmp alltraps
801054b6:	e9 5b fa ff ff       	jmp    80104f16 <alltraps>

801054bb <vector42>:
.globl vector42
vector42:
  pushl $0
801054bb:	6a 00                	push   $0x0
  pushl $42
801054bd:	6a 2a                	push   $0x2a
  jmp alltraps
801054bf:	e9 52 fa ff ff       	jmp    80104f16 <alltraps>

801054c4 <vector43>:
.globl vector43
vector43:
  pushl $0
801054c4:	6a 00                	push   $0x0
  pushl $43
801054c6:	6a 2b                	push   $0x2b
  jmp alltraps
801054c8:	e9 49 fa ff ff       	jmp    80104f16 <alltraps>

801054cd <vector44>:
.globl vector44
vector44:
  pushl $0
801054cd:	6a 00                	push   $0x0
  pushl $44
801054cf:	6a 2c                	push   $0x2c
  jmp alltraps
801054d1:	e9 40 fa ff ff       	jmp    80104f16 <alltraps>

801054d6 <vector45>:
.globl vector45
vector45:
  pushl $0
801054d6:	6a 00                	push   $0x0
  pushl $45
801054d8:	6a 2d                	push   $0x2d
  jmp alltraps
801054da:	e9 37 fa ff ff       	jmp    80104f16 <alltraps>

801054df <vector46>:
.globl vector46
vector46:
  pushl $0
801054df:	6a 00                	push   $0x0
  pushl $46
801054e1:	6a 2e                	push   $0x2e
  jmp alltraps
801054e3:	e9 2e fa ff ff       	jmp    80104f16 <alltraps>

801054e8 <vector47>:
.globl vector47
vector47:
  pushl $0
801054e8:	6a 00                	push   $0x0
  pushl $47
801054ea:	6a 2f                	push   $0x2f
  jmp alltraps
801054ec:	e9 25 fa ff ff       	jmp    80104f16 <alltraps>

801054f1 <vector48>:
.globl vector48
vector48:
  pushl $0
801054f1:	6a 00                	push   $0x0
  pushl $48
801054f3:	6a 30                	push   $0x30
  jmp alltraps
801054f5:	e9 1c fa ff ff       	jmp    80104f16 <alltraps>

801054fa <vector49>:
.globl vector49
vector49:
  pushl $0
801054fa:	6a 00                	push   $0x0
  pushl $49
801054fc:	6a 31                	push   $0x31
  jmp alltraps
801054fe:	e9 13 fa ff ff       	jmp    80104f16 <alltraps>

80105503 <vector50>:
.globl vector50
vector50:
  pushl $0
80105503:	6a 00                	push   $0x0
  pushl $50
80105505:	6a 32                	push   $0x32
  jmp alltraps
80105507:	e9 0a fa ff ff       	jmp    80104f16 <alltraps>

8010550c <vector51>:
.globl vector51
vector51:
  pushl $0
8010550c:	6a 00                	push   $0x0
  pushl $51
8010550e:	6a 33                	push   $0x33
  jmp alltraps
80105510:	e9 01 fa ff ff       	jmp    80104f16 <alltraps>

80105515 <vector52>:
.globl vector52
vector52:
  pushl $0
80105515:	6a 00                	push   $0x0
  pushl $52
80105517:	6a 34                	push   $0x34
  jmp alltraps
80105519:	e9 f8 f9 ff ff       	jmp    80104f16 <alltraps>

8010551e <vector53>:
.globl vector53
vector53:
  pushl $0
8010551e:	6a 00                	push   $0x0
  pushl $53
80105520:	6a 35                	push   $0x35
  jmp alltraps
80105522:	e9 ef f9 ff ff       	jmp    80104f16 <alltraps>

80105527 <vector54>:
.globl vector54
vector54:
  pushl $0
80105527:	6a 00                	push   $0x0
  pushl $54
80105529:	6a 36                	push   $0x36
  jmp alltraps
8010552b:	e9 e6 f9 ff ff       	jmp    80104f16 <alltraps>

80105530 <vector55>:
.globl vector55
vector55:
  pushl $0
80105530:	6a 00                	push   $0x0
  pushl $55
80105532:	6a 37                	push   $0x37
  jmp alltraps
80105534:	e9 dd f9 ff ff       	jmp    80104f16 <alltraps>

80105539 <vector56>:
.globl vector56
vector56:
  pushl $0
80105539:	6a 00                	push   $0x0
  pushl $56
8010553b:	6a 38                	push   $0x38
  jmp alltraps
8010553d:	e9 d4 f9 ff ff       	jmp    80104f16 <alltraps>

80105542 <vector57>:
.globl vector57
vector57:
  pushl $0
80105542:	6a 00                	push   $0x0
  pushl $57
80105544:	6a 39                	push   $0x39
  jmp alltraps
80105546:	e9 cb f9 ff ff       	jmp    80104f16 <alltraps>

8010554b <vector58>:
.globl vector58
vector58:
  pushl $0
8010554b:	6a 00                	push   $0x0
  pushl $58
8010554d:	6a 3a                	push   $0x3a
  jmp alltraps
8010554f:	e9 c2 f9 ff ff       	jmp    80104f16 <alltraps>

80105554 <vector59>:
.globl vector59
vector59:
  pushl $0
80105554:	6a 00                	push   $0x0
  pushl $59
80105556:	6a 3b                	push   $0x3b
  jmp alltraps
80105558:	e9 b9 f9 ff ff       	jmp    80104f16 <alltraps>

8010555d <vector60>:
.globl vector60
vector60:
  pushl $0
8010555d:	6a 00                	push   $0x0
  pushl $60
8010555f:	6a 3c                	push   $0x3c
  jmp alltraps
80105561:	e9 b0 f9 ff ff       	jmp    80104f16 <alltraps>

80105566 <vector61>:
.globl vector61
vector61:
  pushl $0
80105566:	6a 00                	push   $0x0
  pushl $61
80105568:	6a 3d                	push   $0x3d
  jmp alltraps
8010556a:	e9 a7 f9 ff ff       	jmp    80104f16 <alltraps>

8010556f <vector62>:
.globl vector62
vector62:
  pushl $0
8010556f:	6a 00                	push   $0x0
  pushl $62
80105571:	6a 3e                	push   $0x3e
  jmp alltraps
80105573:	e9 9e f9 ff ff       	jmp    80104f16 <alltraps>

80105578 <vector63>:
.globl vector63
vector63:
  pushl $0
80105578:	6a 00                	push   $0x0
  pushl $63
8010557a:	6a 3f                	push   $0x3f
  jmp alltraps
8010557c:	e9 95 f9 ff ff       	jmp    80104f16 <alltraps>

80105581 <vector64>:
.globl vector64
vector64:
  pushl $0
80105581:	6a 00                	push   $0x0
  pushl $64
80105583:	6a 40                	push   $0x40
  jmp alltraps
80105585:	e9 8c f9 ff ff       	jmp    80104f16 <alltraps>

8010558a <vector65>:
.globl vector65
vector65:
  pushl $0
8010558a:	6a 00                	push   $0x0
  pushl $65
8010558c:	6a 41                	push   $0x41
  jmp alltraps
8010558e:	e9 83 f9 ff ff       	jmp    80104f16 <alltraps>

80105593 <vector66>:
.globl vector66
vector66:
  pushl $0
80105593:	6a 00                	push   $0x0
  pushl $66
80105595:	6a 42                	push   $0x42
  jmp alltraps
80105597:	e9 7a f9 ff ff       	jmp    80104f16 <alltraps>

8010559c <vector67>:
.globl vector67
vector67:
  pushl $0
8010559c:	6a 00                	push   $0x0
  pushl $67
8010559e:	6a 43                	push   $0x43
  jmp alltraps
801055a0:	e9 71 f9 ff ff       	jmp    80104f16 <alltraps>

801055a5 <vector68>:
.globl vector68
vector68:
  pushl $0
801055a5:	6a 00                	push   $0x0
  pushl $68
801055a7:	6a 44                	push   $0x44
  jmp alltraps
801055a9:	e9 68 f9 ff ff       	jmp    80104f16 <alltraps>

801055ae <vector69>:
.globl vector69
vector69:
  pushl $0
801055ae:	6a 00                	push   $0x0
  pushl $69
801055b0:	6a 45                	push   $0x45
  jmp alltraps
801055b2:	e9 5f f9 ff ff       	jmp    80104f16 <alltraps>

801055b7 <vector70>:
.globl vector70
vector70:
  pushl $0
801055b7:	6a 00                	push   $0x0
  pushl $70
801055b9:	6a 46                	push   $0x46
  jmp alltraps
801055bb:	e9 56 f9 ff ff       	jmp    80104f16 <alltraps>

801055c0 <vector71>:
.globl vector71
vector71:
  pushl $0
801055c0:	6a 00                	push   $0x0
  pushl $71
801055c2:	6a 47                	push   $0x47
  jmp alltraps
801055c4:	e9 4d f9 ff ff       	jmp    80104f16 <alltraps>

801055c9 <vector72>:
.globl vector72
vector72:
  pushl $0
801055c9:	6a 00                	push   $0x0
  pushl $72
801055cb:	6a 48                	push   $0x48
  jmp alltraps
801055cd:	e9 44 f9 ff ff       	jmp    80104f16 <alltraps>

801055d2 <vector73>:
.globl vector73
vector73:
  pushl $0
801055d2:	6a 00                	push   $0x0
  pushl $73
801055d4:	6a 49                	push   $0x49
  jmp alltraps
801055d6:	e9 3b f9 ff ff       	jmp    80104f16 <alltraps>

801055db <vector74>:
.globl vector74
vector74:
  pushl $0
801055db:	6a 00                	push   $0x0
  pushl $74
801055dd:	6a 4a                	push   $0x4a
  jmp alltraps
801055df:	e9 32 f9 ff ff       	jmp    80104f16 <alltraps>

801055e4 <vector75>:
.globl vector75
vector75:
  pushl $0
801055e4:	6a 00                	push   $0x0
  pushl $75
801055e6:	6a 4b                	push   $0x4b
  jmp alltraps
801055e8:	e9 29 f9 ff ff       	jmp    80104f16 <alltraps>

801055ed <vector76>:
.globl vector76
vector76:
  pushl $0
801055ed:	6a 00                	push   $0x0
  pushl $76
801055ef:	6a 4c                	push   $0x4c
  jmp alltraps
801055f1:	e9 20 f9 ff ff       	jmp    80104f16 <alltraps>

801055f6 <vector77>:
.globl vector77
vector77:
  pushl $0
801055f6:	6a 00                	push   $0x0
  pushl $77
801055f8:	6a 4d                	push   $0x4d
  jmp alltraps
801055fa:	e9 17 f9 ff ff       	jmp    80104f16 <alltraps>

801055ff <vector78>:
.globl vector78
vector78:
  pushl $0
801055ff:	6a 00                	push   $0x0
  pushl $78
80105601:	6a 4e                	push   $0x4e
  jmp alltraps
80105603:	e9 0e f9 ff ff       	jmp    80104f16 <alltraps>

80105608 <vector79>:
.globl vector79
vector79:
  pushl $0
80105608:	6a 00                	push   $0x0
  pushl $79
8010560a:	6a 4f                	push   $0x4f
  jmp alltraps
8010560c:	e9 05 f9 ff ff       	jmp    80104f16 <alltraps>

80105611 <vector80>:
.globl vector80
vector80:
  pushl $0
80105611:	6a 00                	push   $0x0
  pushl $80
80105613:	6a 50                	push   $0x50
  jmp alltraps
80105615:	e9 fc f8 ff ff       	jmp    80104f16 <alltraps>

8010561a <vector81>:
.globl vector81
vector81:
  pushl $0
8010561a:	6a 00                	push   $0x0
  pushl $81
8010561c:	6a 51                	push   $0x51
  jmp alltraps
8010561e:	e9 f3 f8 ff ff       	jmp    80104f16 <alltraps>

80105623 <vector82>:
.globl vector82
vector82:
  pushl $0
80105623:	6a 00                	push   $0x0
  pushl $82
80105625:	6a 52                	push   $0x52
  jmp alltraps
80105627:	e9 ea f8 ff ff       	jmp    80104f16 <alltraps>

8010562c <vector83>:
.globl vector83
vector83:
  pushl $0
8010562c:	6a 00                	push   $0x0
  pushl $83
8010562e:	6a 53                	push   $0x53
  jmp alltraps
80105630:	e9 e1 f8 ff ff       	jmp    80104f16 <alltraps>

80105635 <vector84>:
.globl vector84
vector84:
  pushl $0
80105635:	6a 00                	push   $0x0
  pushl $84
80105637:	6a 54                	push   $0x54
  jmp alltraps
80105639:	e9 d8 f8 ff ff       	jmp    80104f16 <alltraps>

8010563e <vector85>:
.globl vector85
vector85:
  pushl $0
8010563e:	6a 00                	push   $0x0
  pushl $85
80105640:	6a 55                	push   $0x55
  jmp alltraps
80105642:	e9 cf f8 ff ff       	jmp    80104f16 <alltraps>

80105647 <vector86>:
.globl vector86
vector86:
  pushl $0
80105647:	6a 00                	push   $0x0
  pushl $86
80105649:	6a 56                	push   $0x56
  jmp alltraps
8010564b:	e9 c6 f8 ff ff       	jmp    80104f16 <alltraps>

80105650 <vector87>:
.globl vector87
vector87:
  pushl $0
80105650:	6a 00                	push   $0x0
  pushl $87
80105652:	6a 57                	push   $0x57
  jmp alltraps
80105654:	e9 bd f8 ff ff       	jmp    80104f16 <alltraps>

80105659 <vector88>:
.globl vector88
vector88:
  pushl $0
80105659:	6a 00                	push   $0x0
  pushl $88
8010565b:	6a 58                	push   $0x58
  jmp alltraps
8010565d:	e9 b4 f8 ff ff       	jmp    80104f16 <alltraps>

80105662 <vector89>:
.globl vector89
vector89:
  pushl $0
80105662:	6a 00                	push   $0x0
  pushl $89
80105664:	6a 59                	push   $0x59
  jmp alltraps
80105666:	e9 ab f8 ff ff       	jmp    80104f16 <alltraps>

8010566b <vector90>:
.globl vector90
vector90:
  pushl $0
8010566b:	6a 00                	push   $0x0
  pushl $90
8010566d:	6a 5a                	push   $0x5a
  jmp alltraps
8010566f:	e9 a2 f8 ff ff       	jmp    80104f16 <alltraps>

80105674 <vector91>:
.globl vector91
vector91:
  pushl $0
80105674:	6a 00                	push   $0x0
  pushl $91
80105676:	6a 5b                	push   $0x5b
  jmp alltraps
80105678:	e9 99 f8 ff ff       	jmp    80104f16 <alltraps>

8010567d <vector92>:
.globl vector92
vector92:
  pushl $0
8010567d:	6a 00                	push   $0x0
  pushl $92
8010567f:	6a 5c                	push   $0x5c
  jmp alltraps
80105681:	e9 90 f8 ff ff       	jmp    80104f16 <alltraps>

80105686 <vector93>:
.globl vector93
vector93:
  pushl $0
80105686:	6a 00                	push   $0x0
  pushl $93
80105688:	6a 5d                	push   $0x5d
  jmp alltraps
8010568a:	e9 87 f8 ff ff       	jmp    80104f16 <alltraps>

8010568f <vector94>:
.globl vector94
vector94:
  pushl $0
8010568f:	6a 00                	push   $0x0
  pushl $94
80105691:	6a 5e                	push   $0x5e
  jmp alltraps
80105693:	e9 7e f8 ff ff       	jmp    80104f16 <alltraps>

80105698 <vector95>:
.globl vector95
vector95:
  pushl $0
80105698:	6a 00                	push   $0x0
  pushl $95
8010569a:	6a 5f                	push   $0x5f
  jmp alltraps
8010569c:	e9 75 f8 ff ff       	jmp    80104f16 <alltraps>

801056a1 <vector96>:
.globl vector96
vector96:
  pushl $0
801056a1:	6a 00                	push   $0x0
  pushl $96
801056a3:	6a 60                	push   $0x60
  jmp alltraps
801056a5:	e9 6c f8 ff ff       	jmp    80104f16 <alltraps>

801056aa <vector97>:
.globl vector97
vector97:
  pushl $0
801056aa:	6a 00                	push   $0x0
  pushl $97
801056ac:	6a 61                	push   $0x61
  jmp alltraps
801056ae:	e9 63 f8 ff ff       	jmp    80104f16 <alltraps>

801056b3 <vector98>:
.globl vector98
vector98:
  pushl $0
801056b3:	6a 00                	push   $0x0
  pushl $98
801056b5:	6a 62                	push   $0x62
  jmp alltraps
801056b7:	e9 5a f8 ff ff       	jmp    80104f16 <alltraps>

801056bc <vector99>:
.globl vector99
vector99:
  pushl $0
801056bc:	6a 00                	push   $0x0
  pushl $99
801056be:	6a 63                	push   $0x63
  jmp alltraps
801056c0:	e9 51 f8 ff ff       	jmp    80104f16 <alltraps>

801056c5 <vector100>:
.globl vector100
vector100:
  pushl $0
801056c5:	6a 00                	push   $0x0
  pushl $100
801056c7:	6a 64                	push   $0x64
  jmp alltraps
801056c9:	e9 48 f8 ff ff       	jmp    80104f16 <alltraps>

801056ce <vector101>:
.globl vector101
vector101:
  pushl $0
801056ce:	6a 00                	push   $0x0
  pushl $101
801056d0:	6a 65                	push   $0x65
  jmp alltraps
801056d2:	e9 3f f8 ff ff       	jmp    80104f16 <alltraps>

801056d7 <vector102>:
.globl vector102
vector102:
  pushl $0
801056d7:	6a 00                	push   $0x0
  pushl $102
801056d9:	6a 66                	push   $0x66
  jmp alltraps
801056db:	e9 36 f8 ff ff       	jmp    80104f16 <alltraps>

801056e0 <vector103>:
.globl vector103
vector103:
  pushl $0
801056e0:	6a 00                	push   $0x0
  pushl $103
801056e2:	6a 67                	push   $0x67
  jmp alltraps
801056e4:	e9 2d f8 ff ff       	jmp    80104f16 <alltraps>

801056e9 <vector104>:
.globl vector104
vector104:
  pushl $0
801056e9:	6a 00                	push   $0x0
  pushl $104
801056eb:	6a 68                	push   $0x68
  jmp alltraps
801056ed:	e9 24 f8 ff ff       	jmp    80104f16 <alltraps>

801056f2 <vector105>:
.globl vector105
vector105:
  pushl $0
801056f2:	6a 00                	push   $0x0
  pushl $105
801056f4:	6a 69                	push   $0x69
  jmp alltraps
801056f6:	e9 1b f8 ff ff       	jmp    80104f16 <alltraps>

801056fb <vector106>:
.globl vector106
vector106:
  pushl $0
801056fb:	6a 00                	push   $0x0
  pushl $106
801056fd:	6a 6a                	push   $0x6a
  jmp alltraps
801056ff:	e9 12 f8 ff ff       	jmp    80104f16 <alltraps>

80105704 <vector107>:
.globl vector107
vector107:
  pushl $0
80105704:	6a 00                	push   $0x0
  pushl $107
80105706:	6a 6b                	push   $0x6b
  jmp alltraps
80105708:	e9 09 f8 ff ff       	jmp    80104f16 <alltraps>

8010570d <vector108>:
.globl vector108
vector108:
  pushl $0
8010570d:	6a 00                	push   $0x0
  pushl $108
8010570f:	6a 6c                	push   $0x6c
  jmp alltraps
80105711:	e9 00 f8 ff ff       	jmp    80104f16 <alltraps>

80105716 <vector109>:
.globl vector109
vector109:
  pushl $0
80105716:	6a 00                	push   $0x0
  pushl $109
80105718:	6a 6d                	push   $0x6d
  jmp alltraps
8010571a:	e9 f7 f7 ff ff       	jmp    80104f16 <alltraps>

8010571f <vector110>:
.globl vector110
vector110:
  pushl $0
8010571f:	6a 00                	push   $0x0
  pushl $110
80105721:	6a 6e                	push   $0x6e
  jmp alltraps
80105723:	e9 ee f7 ff ff       	jmp    80104f16 <alltraps>

80105728 <vector111>:
.globl vector111
vector111:
  pushl $0
80105728:	6a 00                	push   $0x0
  pushl $111
8010572a:	6a 6f                	push   $0x6f
  jmp alltraps
8010572c:	e9 e5 f7 ff ff       	jmp    80104f16 <alltraps>

80105731 <vector112>:
.globl vector112
vector112:
  pushl $0
80105731:	6a 00                	push   $0x0
  pushl $112
80105733:	6a 70                	push   $0x70
  jmp alltraps
80105735:	e9 dc f7 ff ff       	jmp    80104f16 <alltraps>

8010573a <vector113>:
.globl vector113
vector113:
  pushl $0
8010573a:	6a 00                	push   $0x0
  pushl $113
8010573c:	6a 71                	push   $0x71
  jmp alltraps
8010573e:	e9 d3 f7 ff ff       	jmp    80104f16 <alltraps>

80105743 <vector114>:
.globl vector114
vector114:
  pushl $0
80105743:	6a 00                	push   $0x0
  pushl $114
80105745:	6a 72                	push   $0x72
  jmp alltraps
80105747:	e9 ca f7 ff ff       	jmp    80104f16 <alltraps>

8010574c <vector115>:
.globl vector115
vector115:
  pushl $0
8010574c:	6a 00                	push   $0x0
  pushl $115
8010574e:	6a 73                	push   $0x73
  jmp alltraps
80105750:	e9 c1 f7 ff ff       	jmp    80104f16 <alltraps>

80105755 <vector116>:
.globl vector116
vector116:
  pushl $0
80105755:	6a 00                	push   $0x0
  pushl $116
80105757:	6a 74                	push   $0x74
  jmp alltraps
80105759:	e9 b8 f7 ff ff       	jmp    80104f16 <alltraps>

8010575e <vector117>:
.globl vector117
vector117:
  pushl $0
8010575e:	6a 00                	push   $0x0
  pushl $117
80105760:	6a 75                	push   $0x75
  jmp alltraps
80105762:	e9 af f7 ff ff       	jmp    80104f16 <alltraps>

80105767 <vector118>:
.globl vector118
vector118:
  pushl $0
80105767:	6a 00                	push   $0x0
  pushl $118
80105769:	6a 76                	push   $0x76
  jmp alltraps
8010576b:	e9 a6 f7 ff ff       	jmp    80104f16 <alltraps>

80105770 <vector119>:
.globl vector119
vector119:
  pushl $0
80105770:	6a 00                	push   $0x0
  pushl $119
80105772:	6a 77                	push   $0x77
  jmp alltraps
80105774:	e9 9d f7 ff ff       	jmp    80104f16 <alltraps>

80105779 <vector120>:
.globl vector120
vector120:
  pushl $0
80105779:	6a 00                	push   $0x0
  pushl $120
8010577b:	6a 78                	push   $0x78
  jmp alltraps
8010577d:	e9 94 f7 ff ff       	jmp    80104f16 <alltraps>

80105782 <vector121>:
.globl vector121
vector121:
  pushl $0
80105782:	6a 00                	push   $0x0
  pushl $121
80105784:	6a 79                	push   $0x79
  jmp alltraps
80105786:	e9 8b f7 ff ff       	jmp    80104f16 <alltraps>

8010578b <vector122>:
.globl vector122
vector122:
  pushl $0
8010578b:	6a 00                	push   $0x0
  pushl $122
8010578d:	6a 7a                	push   $0x7a
  jmp alltraps
8010578f:	e9 82 f7 ff ff       	jmp    80104f16 <alltraps>

80105794 <vector123>:
.globl vector123
vector123:
  pushl $0
80105794:	6a 00                	push   $0x0
  pushl $123
80105796:	6a 7b                	push   $0x7b
  jmp alltraps
80105798:	e9 79 f7 ff ff       	jmp    80104f16 <alltraps>

8010579d <vector124>:
.globl vector124
vector124:
  pushl $0
8010579d:	6a 00                	push   $0x0
  pushl $124
8010579f:	6a 7c                	push   $0x7c
  jmp alltraps
801057a1:	e9 70 f7 ff ff       	jmp    80104f16 <alltraps>

801057a6 <vector125>:
.globl vector125
vector125:
  pushl $0
801057a6:	6a 00                	push   $0x0
  pushl $125
801057a8:	6a 7d                	push   $0x7d
  jmp alltraps
801057aa:	e9 67 f7 ff ff       	jmp    80104f16 <alltraps>

801057af <vector126>:
.globl vector126
vector126:
  pushl $0
801057af:	6a 00                	push   $0x0
  pushl $126
801057b1:	6a 7e                	push   $0x7e
  jmp alltraps
801057b3:	e9 5e f7 ff ff       	jmp    80104f16 <alltraps>

801057b8 <vector127>:
.globl vector127
vector127:
  pushl $0
801057b8:	6a 00                	push   $0x0
  pushl $127
801057ba:	6a 7f                	push   $0x7f
  jmp alltraps
801057bc:	e9 55 f7 ff ff       	jmp    80104f16 <alltraps>

801057c1 <vector128>:
.globl vector128
vector128:
  pushl $0
801057c1:	6a 00                	push   $0x0
  pushl $128
801057c3:	68 80 00 00 00       	push   $0x80
  jmp alltraps
801057c8:	e9 49 f7 ff ff       	jmp    80104f16 <alltraps>

801057cd <vector129>:
.globl vector129
vector129:
  pushl $0
801057cd:	6a 00                	push   $0x0
  pushl $129
801057cf:	68 81 00 00 00       	push   $0x81
  jmp alltraps
801057d4:	e9 3d f7 ff ff       	jmp    80104f16 <alltraps>

801057d9 <vector130>:
.globl vector130
vector130:
  pushl $0
801057d9:	6a 00                	push   $0x0
  pushl $130
801057db:	68 82 00 00 00       	push   $0x82
  jmp alltraps
801057e0:	e9 31 f7 ff ff       	jmp    80104f16 <alltraps>

801057e5 <vector131>:
.globl vector131
vector131:
  pushl $0
801057e5:	6a 00                	push   $0x0
  pushl $131
801057e7:	68 83 00 00 00       	push   $0x83
  jmp alltraps
801057ec:	e9 25 f7 ff ff       	jmp    80104f16 <alltraps>

801057f1 <vector132>:
.globl vector132
vector132:
  pushl $0
801057f1:	6a 00                	push   $0x0
  pushl $132
801057f3:	68 84 00 00 00       	push   $0x84
  jmp alltraps
801057f8:	e9 19 f7 ff ff       	jmp    80104f16 <alltraps>

801057fd <vector133>:
.globl vector133
vector133:
  pushl $0
801057fd:	6a 00                	push   $0x0
  pushl $133
801057ff:	68 85 00 00 00       	push   $0x85
  jmp alltraps
80105804:	e9 0d f7 ff ff       	jmp    80104f16 <alltraps>

80105809 <vector134>:
.globl vector134
vector134:
  pushl $0
80105809:	6a 00                	push   $0x0
  pushl $134
8010580b:	68 86 00 00 00       	push   $0x86
  jmp alltraps
80105810:	e9 01 f7 ff ff       	jmp    80104f16 <alltraps>

80105815 <vector135>:
.globl vector135
vector135:
  pushl $0
80105815:	6a 00                	push   $0x0
  pushl $135
80105817:	68 87 00 00 00       	push   $0x87
  jmp alltraps
8010581c:	e9 f5 f6 ff ff       	jmp    80104f16 <alltraps>

80105821 <vector136>:
.globl vector136
vector136:
  pushl $0
80105821:	6a 00                	push   $0x0
  pushl $136
80105823:	68 88 00 00 00       	push   $0x88
  jmp alltraps
80105828:	e9 e9 f6 ff ff       	jmp    80104f16 <alltraps>

8010582d <vector137>:
.globl vector137
vector137:
  pushl $0
8010582d:	6a 00                	push   $0x0
  pushl $137
8010582f:	68 89 00 00 00       	push   $0x89
  jmp alltraps
80105834:	e9 dd f6 ff ff       	jmp    80104f16 <alltraps>

80105839 <vector138>:
.globl vector138
vector138:
  pushl $0
80105839:	6a 00                	push   $0x0
  pushl $138
8010583b:	68 8a 00 00 00       	push   $0x8a
  jmp alltraps
80105840:	e9 d1 f6 ff ff       	jmp    80104f16 <alltraps>

80105845 <vector139>:
.globl vector139
vector139:
  pushl $0
80105845:	6a 00                	push   $0x0
  pushl $139
80105847:	68 8b 00 00 00       	push   $0x8b
  jmp alltraps
8010584c:	e9 c5 f6 ff ff       	jmp    80104f16 <alltraps>

80105851 <vector140>:
.globl vector140
vector140:
  pushl $0
80105851:	6a 00                	push   $0x0
  pushl $140
80105853:	68 8c 00 00 00       	push   $0x8c
  jmp alltraps
80105858:	e9 b9 f6 ff ff       	jmp    80104f16 <alltraps>

8010585d <vector141>:
.globl vector141
vector141:
  pushl $0
8010585d:	6a 00                	push   $0x0
  pushl $141
8010585f:	68 8d 00 00 00       	push   $0x8d
  jmp alltraps
80105864:	e9 ad f6 ff ff       	jmp    80104f16 <alltraps>

80105869 <vector142>:
.globl vector142
vector142:
  pushl $0
80105869:	6a 00                	push   $0x0
  pushl $142
8010586b:	68 8e 00 00 00       	push   $0x8e
  jmp alltraps
80105870:	e9 a1 f6 ff ff       	jmp    80104f16 <alltraps>

80105875 <vector143>:
.globl vector143
vector143:
  pushl $0
80105875:	6a 00                	push   $0x0
  pushl $143
80105877:	68 8f 00 00 00       	push   $0x8f
  jmp alltraps
8010587c:	e9 95 f6 ff ff       	jmp    80104f16 <alltraps>

80105881 <vector144>:
.globl vector144
vector144:
  pushl $0
80105881:	6a 00                	push   $0x0
  pushl $144
80105883:	68 90 00 00 00       	push   $0x90
  jmp alltraps
80105888:	e9 89 f6 ff ff       	jmp    80104f16 <alltraps>

8010588d <vector145>:
.globl vector145
vector145:
  pushl $0
8010588d:	6a 00                	push   $0x0
  pushl $145
8010588f:	68 91 00 00 00       	push   $0x91
  jmp alltraps
80105894:	e9 7d f6 ff ff       	jmp    80104f16 <alltraps>

80105899 <vector146>:
.globl vector146
vector146:
  pushl $0
80105899:	6a 00                	push   $0x0
  pushl $146
8010589b:	68 92 00 00 00       	push   $0x92
  jmp alltraps
801058a0:	e9 71 f6 ff ff       	jmp    80104f16 <alltraps>

801058a5 <vector147>:
.globl vector147
vector147:
  pushl $0
801058a5:	6a 00                	push   $0x0
  pushl $147
801058a7:	68 93 00 00 00       	push   $0x93
  jmp alltraps
801058ac:	e9 65 f6 ff ff       	jmp    80104f16 <alltraps>

801058b1 <vector148>:
.globl vector148
vector148:
  pushl $0
801058b1:	6a 00                	push   $0x0
  pushl $148
801058b3:	68 94 00 00 00       	push   $0x94
  jmp alltraps
801058b8:	e9 59 f6 ff ff       	jmp    80104f16 <alltraps>

801058bd <vector149>:
.globl vector149
vector149:
  pushl $0
801058bd:	6a 00                	push   $0x0
  pushl $149
801058bf:	68 95 00 00 00       	push   $0x95
  jmp alltraps
801058c4:	e9 4d f6 ff ff       	jmp    80104f16 <alltraps>

801058c9 <vector150>:
.globl vector150
vector150:
  pushl $0
801058c9:	6a 00                	push   $0x0
  pushl $150
801058cb:	68 96 00 00 00       	push   $0x96
  jmp alltraps
801058d0:	e9 41 f6 ff ff       	jmp    80104f16 <alltraps>

801058d5 <vector151>:
.globl vector151
vector151:
  pushl $0
801058d5:	6a 00                	push   $0x0
  pushl $151
801058d7:	68 97 00 00 00       	push   $0x97
  jmp alltraps
801058dc:	e9 35 f6 ff ff       	jmp    80104f16 <alltraps>

801058e1 <vector152>:
.globl vector152
vector152:
  pushl $0
801058e1:	6a 00                	push   $0x0
  pushl $152
801058e3:	68 98 00 00 00       	push   $0x98
  jmp alltraps
801058e8:	e9 29 f6 ff ff       	jmp    80104f16 <alltraps>

801058ed <vector153>:
.globl vector153
vector153:
  pushl $0
801058ed:	6a 00                	push   $0x0
  pushl $153
801058ef:	68 99 00 00 00       	push   $0x99
  jmp alltraps
801058f4:	e9 1d f6 ff ff       	jmp    80104f16 <alltraps>

801058f9 <vector154>:
.globl vector154
vector154:
  pushl $0
801058f9:	6a 00                	push   $0x0
  pushl $154
801058fb:	68 9a 00 00 00       	push   $0x9a
  jmp alltraps
80105900:	e9 11 f6 ff ff       	jmp    80104f16 <alltraps>

80105905 <vector155>:
.globl vector155
vector155:
  pushl $0
80105905:	6a 00                	push   $0x0
  pushl $155
80105907:	68 9b 00 00 00       	push   $0x9b
  jmp alltraps
8010590c:	e9 05 f6 ff ff       	jmp    80104f16 <alltraps>

80105911 <vector156>:
.globl vector156
vector156:
  pushl $0
80105911:	6a 00                	push   $0x0
  pushl $156
80105913:	68 9c 00 00 00       	push   $0x9c
  jmp alltraps
80105918:	e9 f9 f5 ff ff       	jmp    80104f16 <alltraps>

8010591d <vector157>:
.globl vector157
vector157:
  pushl $0
8010591d:	6a 00                	push   $0x0
  pushl $157
8010591f:	68 9d 00 00 00       	push   $0x9d
  jmp alltraps
80105924:	e9 ed f5 ff ff       	jmp    80104f16 <alltraps>

80105929 <vector158>:
.globl vector158
vector158:
  pushl $0
80105929:	6a 00                	push   $0x0
  pushl $158
8010592b:	68 9e 00 00 00       	push   $0x9e
  jmp alltraps
80105930:	e9 e1 f5 ff ff       	jmp    80104f16 <alltraps>

80105935 <vector159>:
.globl vector159
vector159:
  pushl $0
80105935:	6a 00                	push   $0x0
  pushl $159
80105937:	68 9f 00 00 00       	push   $0x9f
  jmp alltraps
8010593c:	e9 d5 f5 ff ff       	jmp    80104f16 <alltraps>

80105941 <vector160>:
.globl vector160
vector160:
  pushl $0
80105941:	6a 00                	push   $0x0
  pushl $160
80105943:	68 a0 00 00 00       	push   $0xa0
  jmp alltraps
80105948:	e9 c9 f5 ff ff       	jmp    80104f16 <alltraps>

8010594d <vector161>:
.globl vector161
vector161:
  pushl $0
8010594d:	6a 00                	push   $0x0
  pushl $161
8010594f:	68 a1 00 00 00       	push   $0xa1
  jmp alltraps
80105954:	e9 bd f5 ff ff       	jmp    80104f16 <alltraps>

80105959 <vector162>:
.globl vector162
vector162:
  pushl $0
80105959:	6a 00                	push   $0x0
  pushl $162
8010595b:	68 a2 00 00 00       	push   $0xa2
  jmp alltraps
80105960:	e9 b1 f5 ff ff       	jmp    80104f16 <alltraps>

80105965 <vector163>:
.globl vector163
vector163:
  pushl $0
80105965:	6a 00                	push   $0x0
  pushl $163
80105967:	68 a3 00 00 00       	push   $0xa3
  jmp alltraps
8010596c:	e9 a5 f5 ff ff       	jmp    80104f16 <alltraps>

80105971 <vector164>:
.globl vector164
vector164:
  pushl $0
80105971:	6a 00                	push   $0x0
  pushl $164
80105973:	68 a4 00 00 00       	push   $0xa4
  jmp alltraps
80105978:	e9 99 f5 ff ff       	jmp    80104f16 <alltraps>

8010597d <vector165>:
.globl vector165
vector165:
  pushl $0
8010597d:	6a 00                	push   $0x0
  pushl $165
8010597f:	68 a5 00 00 00       	push   $0xa5
  jmp alltraps
80105984:	e9 8d f5 ff ff       	jmp    80104f16 <alltraps>

80105989 <vector166>:
.globl vector166
vector166:
  pushl $0
80105989:	6a 00                	push   $0x0
  pushl $166
8010598b:	68 a6 00 00 00       	push   $0xa6
  jmp alltraps
80105990:	e9 81 f5 ff ff       	jmp    80104f16 <alltraps>

80105995 <vector167>:
.globl vector167
vector167:
  pushl $0
80105995:	6a 00                	push   $0x0
  pushl $167
80105997:	68 a7 00 00 00       	push   $0xa7
  jmp alltraps
8010599c:	e9 75 f5 ff ff       	jmp    80104f16 <alltraps>

801059a1 <vector168>:
.globl vector168
vector168:
  pushl $0
801059a1:	6a 00                	push   $0x0
  pushl $168
801059a3:	68 a8 00 00 00       	push   $0xa8
  jmp alltraps
801059a8:	e9 69 f5 ff ff       	jmp    80104f16 <alltraps>

801059ad <vector169>:
.globl vector169
vector169:
  pushl $0
801059ad:	6a 00                	push   $0x0
  pushl $169
801059af:	68 a9 00 00 00       	push   $0xa9
  jmp alltraps
801059b4:	e9 5d f5 ff ff       	jmp    80104f16 <alltraps>

801059b9 <vector170>:
.globl vector170
vector170:
  pushl $0
801059b9:	6a 00                	push   $0x0
  pushl $170
801059bb:	68 aa 00 00 00       	push   $0xaa
  jmp alltraps
801059c0:	e9 51 f5 ff ff       	jmp    80104f16 <alltraps>

801059c5 <vector171>:
.globl vector171
vector171:
  pushl $0
801059c5:	6a 00                	push   $0x0
  pushl $171
801059c7:	68 ab 00 00 00       	push   $0xab
  jmp alltraps
801059cc:	e9 45 f5 ff ff       	jmp    80104f16 <alltraps>

801059d1 <vector172>:
.globl vector172
vector172:
  pushl $0
801059d1:	6a 00                	push   $0x0
  pushl $172
801059d3:	68 ac 00 00 00       	push   $0xac
  jmp alltraps
801059d8:	e9 39 f5 ff ff       	jmp    80104f16 <alltraps>

801059dd <vector173>:
.globl vector173
vector173:
  pushl $0
801059dd:	6a 00                	push   $0x0
  pushl $173
801059df:	68 ad 00 00 00       	push   $0xad
  jmp alltraps
801059e4:	e9 2d f5 ff ff       	jmp    80104f16 <alltraps>

801059e9 <vector174>:
.globl vector174
vector174:
  pushl $0
801059e9:	6a 00                	push   $0x0
  pushl $174
801059eb:	68 ae 00 00 00       	push   $0xae
  jmp alltraps
801059f0:	e9 21 f5 ff ff       	jmp    80104f16 <alltraps>

801059f5 <vector175>:
.globl vector175
vector175:
  pushl $0
801059f5:	6a 00                	push   $0x0
  pushl $175
801059f7:	68 af 00 00 00       	push   $0xaf
  jmp alltraps
801059fc:	e9 15 f5 ff ff       	jmp    80104f16 <alltraps>

80105a01 <vector176>:
.globl vector176
vector176:
  pushl $0
80105a01:	6a 00                	push   $0x0
  pushl $176
80105a03:	68 b0 00 00 00       	push   $0xb0
  jmp alltraps
80105a08:	e9 09 f5 ff ff       	jmp    80104f16 <alltraps>

80105a0d <vector177>:
.globl vector177
vector177:
  pushl $0
80105a0d:	6a 00                	push   $0x0
  pushl $177
80105a0f:	68 b1 00 00 00       	push   $0xb1
  jmp alltraps
80105a14:	e9 fd f4 ff ff       	jmp    80104f16 <alltraps>

80105a19 <vector178>:
.globl vector178
vector178:
  pushl $0
80105a19:	6a 00                	push   $0x0
  pushl $178
80105a1b:	68 b2 00 00 00       	push   $0xb2
  jmp alltraps
80105a20:	e9 f1 f4 ff ff       	jmp    80104f16 <alltraps>

80105a25 <vector179>:
.globl vector179
vector179:
  pushl $0
80105a25:	6a 00                	push   $0x0
  pushl $179
80105a27:	68 b3 00 00 00       	push   $0xb3
  jmp alltraps
80105a2c:	e9 e5 f4 ff ff       	jmp    80104f16 <alltraps>

80105a31 <vector180>:
.globl vector180
vector180:
  pushl $0
80105a31:	6a 00                	push   $0x0
  pushl $180
80105a33:	68 b4 00 00 00       	push   $0xb4
  jmp alltraps
80105a38:	e9 d9 f4 ff ff       	jmp    80104f16 <alltraps>

80105a3d <vector181>:
.globl vector181
vector181:
  pushl $0
80105a3d:	6a 00                	push   $0x0
  pushl $181
80105a3f:	68 b5 00 00 00       	push   $0xb5
  jmp alltraps
80105a44:	e9 cd f4 ff ff       	jmp    80104f16 <alltraps>

80105a49 <vector182>:
.globl vector182
vector182:
  pushl $0
80105a49:	6a 00                	push   $0x0
  pushl $182
80105a4b:	68 b6 00 00 00       	push   $0xb6
  jmp alltraps
80105a50:	e9 c1 f4 ff ff       	jmp    80104f16 <alltraps>

80105a55 <vector183>:
.globl vector183
vector183:
  pushl $0
80105a55:	6a 00                	push   $0x0
  pushl $183
80105a57:	68 b7 00 00 00       	push   $0xb7
  jmp alltraps
80105a5c:	e9 b5 f4 ff ff       	jmp    80104f16 <alltraps>

80105a61 <vector184>:
.globl vector184
vector184:
  pushl $0
80105a61:	6a 00                	push   $0x0
  pushl $184
80105a63:	68 b8 00 00 00       	push   $0xb8
  jmp alltraps
80105a68:	e9 a9 f4 ff ff       	jmp    80104f16 <alltraps>

80105a6d <vector185>:
.globl vector185
vector185:
  pushl $0
80105a6d:	6a 00                	push   $0x0
  pushl $185
80105a6f:	68 b9 00 00 00       	push   $0xb9
  jmp alltraps
80105a74:	e9 9d f4 ff ff       	jmp    80104f16 <alltraps>

80105a79 <vector186>:
.globl vector186
vector186:
  pushl $0
80105a79:	6a 00                	push   $0x0
  pushl $186
80105a7b:	68 ba 00 00 00       	push   $0xba
  jmp alltraps
80105a80:	e9 91 f4 ff ff       	jmp    80104f16 <alltraps>

80105a85 <vector187>:
.globl vector187
vector187:
  pushl $0
80105a85:	6a 00                	push   $0x0
  pushl $187
80105a87:	68 bb 00 00 00       	push   $0xbb
  jmp alltraps
80105a8c:	e9 85 f4 ff ff       	jmp    80104f16 <alltraps>

80105a91 <vector188>:
.globl vector188
vector188:
  pushl $0
80105a91:	6a 00                	push   $0x0
  pushl $188
80105a93:	68 bc 00 00 00       	push   $0xbc
  jmp alltraps
80105a98:	e9 79 f4 ff ff       	jmp    80104f16 <alltraps>

80105a9d <vector189>:
.globl vector189
vector189:
  pushl $0
80105a9d:	6a 00                	push   $0x0
  pushl $189
80105a9f:	68 bd 00 00 00       	push   $0xbd
  jmp alltraps
80105aa4:	e9 6d f4 ff ff       	jmp    80104f16 <alltraps>

80105aa9 <vector190>:
.globl vector190
vector190:
  pushl $0
80105aa9:	6a 00                	push   $0x0
  pushl $190
80105aab:	68 be 00 00 00       	push   $0xbe
  jmp alltraps
80105ab0:	e9 61 f4 ff ff       	jmp    80104f16 <alltraps>

80105ab5 <vector191>:
.globl vector191
vector191:
  pushl $0
80105ab5:	6a 00                	push   $0x0
  pushl $191
80105ab7:	68 bf 00 00 00       	push   $0xbf
  jmp alltraps
80105abc:	e9 55 f4 ff ff       	jmp    80104f16 <alltraps>

80105ac1 <vector192>:
.globl vector192
vector192:
  pushl $0
80105ac1:	6a 00                	push   $0x0
  pushl $192
80105ac3:	68 c0 00 00 00       	push   $0xc0
  jmp alltraps
80105ac8:	e9 49 f4 ff ff       	jmp    80104f16 <alltraps>

80105acd <vector193>:
.globl vector193
vector193:
  pushl $0
80105acd:	6a 00                	push   $0x0
  pushl $193
80105acf:	68 c1 00 00 00       	push   $0xc1
  jmp alltraps
80105ad4:	e9 3d f4 ff ff       	jmp    80104f16 <alltraps>

80105ad9 <vector194>:
.globl vector194
vector194:
  pushl $0
80105ad9:	6a 00                	push   $0x0
  pushl $194
80105adb:	68 c2 00 00 00       	push   $0xc2
  jmp alltraps
80105ae0:	e9 31 f4 ff ff       	jmp    80104f16 <alltraps>

80105ae5 <vector195>:
.globl vector195
vector195:
  pushl $0
80105ae5:	6a 00                	push   $0x0
  pushl $195
80105ae7:	68 c3 00 00 00       	push   $0xc3
  jmp alltraps
80105aec:	e9 25 f4 ff ff       	jmp    80104f16 <alltraps>

80105af1 <vector196>:
.globl vector196
vector196:
  pushl $0
80105af1:	6a 00                	push   $0x0
  pushl $196
80105af3:	68 c4 00 00 00       	push   $0xc4
  jmp alltraps
80105af8:	e9 19 f4 ff ff       	jmp    80104f16 <alltraps>

80105afd <vector197>:
.globl vector197
vector197:
  pushl $0
80105afd:	6a 00                	push   $0x0
  pushl $197
80105aff:	68 c5 00 00 00       	push   $0xc5
  jmp alltraps
80105b04:	e9 0d f4 ff ff       	jmp    80104f16 <alltraps>

80105b09 <vector198>:
.globl vector198
vector198:
  pushl $0
80105b09:	6a 00                	push   $0x0
  pushl $198
80105b0b:	68 c6 00 00 00       	push   $0xc6
  jmp alltraps
80105b10:	e9 01 f4 ff ff       	jmp    80104f16 <alltraps>

80105b15 <vector199>:
.globl vector199
vector199:
  pushl $0
80105b15:	6a 00                	push   $0x0
  pushl $199
80105b17:	68 c7 00 00 00       	push   $0xc7
  jmp alltraps
80105b1c:	e9 f5 f3 ff ff       	jmp    80104f16 <alltraps>

80105b21 <vector200>:
.globl vector200
vector200:
  pushl $0
80105b21:	6a 00                	push   $0x0
  pushl $200
80105b23:	68 c8 00 00 00       	push   $0xc8
  jmp alltraps
80105b28:	e9 e9 f3 ff ff       	jmp    80104f16 <alltraps>

80105b2d <vector201>:
.globl vector201
vector201:
  pushl $0
80105b2d:	6a 00                	push   $0x0
  pushl $201
80105b2f:	68 c9 00 00 00       	push   $0xc9
  jmp alltraps
80105b34:	e9 dd f3 ff ff       	jmp    80104f16 <alltraps>

80105b39 <vector202>:
.globl vector202
vector202:
  pushl $0
80105b39:	6a 00                	push   $0x0
  pushl $202
80105b3b:	68 ca 00 00 00       	push   $0xca
  jmp alltraps
80105b40:	e9 d1 f3 ff ff       	jmp    80104f16 <alltraps>

80105b45 <vector203>:
.globl vector203
vector203:
  pushl $0
80105b45:	6a 00                	push   $0x0
  pushl $203
80105b47:	68 cb 00 00 00       	push   $0xcb
  jmp alltraps
80105b4c:	e9 c5 f3 ff ff       	jmp    80104f16 <alltraps>

80105b51 <vector204>:
.globl vector204
vector204:
  pushl $0
80105b51:	6a 00                	push   $0x0
  pushl $204
80105b53:	68 cc 00 00 00       	push   $0xcc
  jmp alltraps
80105b58:	e9 b9 f3 ff ff       	jmp    80104f16 <alltraps>

80105b5d <vector205>:
.globl vector205
vector205:
  pushl $0
80105b5d:	6a 00                	push   $0x0
  pushl $205
80105b5f:	68 cd 00 00 00       	push   $0xcd
  jmp alltraps
80105b64:	e9 ad f3 ff ff       	jmp    80104f16 <alltraps>

80105b69 <vector206>:
.globl vector206
vector206:
  pushl $0
80105b69:	6a 00                	push   $0x0
  pushl $206
80105b6b:	68 ce 00 00 00       	push   $0xce
  jmp alltraps
80105b70:	e9 a1 f3 ff ff       	jmp    80104f16 <alltraps>

80105b75 <vector207>:
.globl vector207
vector207:
  pushl $0
80105b75:	6a 00                	push   $0x0
  pushl $207
80105b77:	68 cf 00 00 00       	push   $0xcf
  jmp alltraps
80105b7c:	e9 95 f3 ff ff       	jmp    80104f16 <alltraps>

80105b81 <vector208>:
.globl vector208
vector208:
  pushl $0
80105b81:	6a 00                	push   $0x0
  pushl $208
80105b83:	68 d0 00 00 00       	push   $0xd0
  jmp alltraps
80105b88:	e9 89 f3 ff ff       	jmp    80104f16 <alltraps>

80105b8d <vector209>:
.globl vector209
vector209:
  pushl $0
80105b8d:	6a 00                	push   $0x0
  pushl $209
80105b8f:	68 d1 00 00 00       	push   $0xd1
  jmp alltraps
80105b94:	e9 7d f3 ff ff       	jmp    80104f16 <alltraps>

80105b99 <vector210>:
.globl vector210
vector210:
  pushl $0
80105b99:	6a 00                	push   $0x0
  pushl $210
80105b9b:	68 d2 00 00 00       	push   $0xd2
  jmp alltraps
80105ba0:	e9 71 f3 ff ff       	jmp    80104f16 <alltraps>

80105ba5 <vector211>:
.globl vector211
vector211:
  pushl $0
80105ba5:	6a 00                	push   $0x0
  pushl $211
80105ba7:	68 d3 00 00 00       	push   $0xd3
  jmp alltraps
80105bac:	e9 65 f3 ff ff       	jmp    80104f16 <alltraps>

80105bb1 <vector212>:
.globl vector212
vector212:
  pushl $0
80105bb1:	6a 00                	push   $0x0
  pushl $212
80105bb3:	68 d4 00 00 00       	push   $0xd4
  jmp alltraps
80105bb8:	e9 59 f3 ff ff       	jmp    80104f16 <alltraps>

80105bbd <vector213>:
.globl vector213
vector213:
  pushl $0
80105bbd:	6a 00                	push   $0x0
  pushl $213
80105bbf:	68 d5 00 00 00       	push   $0xd5
  jmp alltraps
80105bc4:	e9 4d f3 ff ff       	jmp    80104f16 <alltraps>

80105bc9 <vector214>:
.globl vector214
vector214:
  pushl $0
80105bc9:	6a 00                	push   $0x0
  pushl $214
80105bcb:	68 d6 00 00 00       	push   $0xd6
  jmp alltraps
80105bd0:	e9 41 f3 ff ff       	jmp    80104f16 <alltraps>

80105bd5 <vector215>:
.globl vector215
vector215:
  pushl $0
80105bd5:	6a 00                	push   $0x0
  pushl $215
80105bd7:	68 d7 00 00 00       	push   $0xd7
  jmp alltraps
80105bdc:	e9 35 f3 ff ff       	jmp    80104f16 <alltraps>

80105be1 <vector216>:
.globl vector216
vector216:
  pushl $0
80105be1:	6a 00                	push   $0x0
  pushl $216
80105be3:	68 d8 00 00 00       	push   $0xd8
  jmp alltraps
80105be8:	e9 29 f3 ff ff       	jmp    80104f16 <alltraps>

80105bed <vector217>:
.globl vector217
vector217:
  pushl $0
80105bed:	6a 00                	push   $0x0
  pushl $217
80105bef:	68 d9 00 00 00       	push   $0xd9
  jmp alltraps
80105bf4:	e9 1d f3 ff ff       	jmp    80104f16 <alltraps>

80105bf9 <vector218>:
.globl vector218
vector218:
  pushl $0
80105bf9:	6a 00                	push   $0x0
  pushl $218
80105bfb:	68 da 00 00 00       	push   $0xda
  jmp alltraps
80105c00:	e9 11 f3 ff ff       	jmp    80104f16 <alltraps>

80105c05 <vector219>:
.globl vector219
vector219:
  pushl $0
80105c05:	6a 00                	push   $0x0
  pushl $219
80105c07:	68 db 00 00 00       	push   $0xdb
  jmp alltraps
80105c0c:	e9 05 f3 ff ff       	jmp    80104f16 <alltraps>

80105c11 <vector220>:
.globl vector220
vector220:
  pushl $0
80105c11:	6a 00                	push   $0x0
  pushl $220
80105c13:	68 dc 00 00 00       	push   $0xdc
  jmp alltraps
80105c18:	e9 f9 f2 ff ff       	jmp    80104f16 <alltraps>

80105c1d <vector221>:
.globl vector221
vector221:
  pushl $0
80105c1d:	6a 00                	push   $0x0
  pushl $221
80105c1f:	68 dd 00 00 00       	push   $0xdd
  jmp alltraps
80105c24:	e9 ed f2 ff ff       	jmp    80104f16 <alltraps>

80105c29 <vector222>:
.globl vector222
vector222:
  pushl $0
80105c29:	6a 00                	push   $0x0
  pushl $222
80105c2b:	68 de 00 00 00       	push   $0xde
  jmp alltraps
80105c30:	e9 e1 f2 ff ff       	jmp    80104f16 <alltraps>

80105c35 <vector223>:
.globl vector223
vector223:
  pushl $0
80105c35:	6a 00                	push   $0x0
  pushl $223
80105c37:	68 df 00 00 00       	push   $0xdf
  jmp alltraps
80105c3c:	e9 d5 f2 ff ff       	jmp    80104f16 <alltraps>

80105c41 <vector224>:
.globl vector224
vector224:
  pushl $0
80105c41:	6a 00                	push   $0x0
  pushl $224
80105c43:	68 e0 00 00 00       	push   $0xe0
  jmp alltraps
80105c48:	e9 c9 f2 ff ff       	jmp    80104f16 <alltraps>

80105c4d <vector225>:
.globl vector225
vector225:
  pushl $0
80105c4d:	6a 00                	push   $0x0
  pushl $225
80105c4f:	68 e1 00 00 00       	push   $0xe1
  jmp alltraps
80105c54:	e9 bd f2 ff ff       	jmp    80104f16 <alltraps>

80105c59 <vector226>:
.globl vector226
vector226:
  pushl $0
80105c59:	6a 00                	push   $0x0
  pushl $226
80105c5b:	68 e2 00 00 00       	push   $0xe2
  jmp alltraps
80105c60:	e9 b1 f2 ff ff       	jmp    80104f16 <alltraps>

80105c65 <vector227>:
.globl vector227
vector227:
  pushl $0
80105c65:	6a 00                	push   $0x0
  pushl $227
80105c67:	68 e3 00 00 00       	push   $0xe3
  jmp alltraps
80105c6c:	e9 a5 f2 ff ff       	jmp    80104f16 <alltraps>

80105c71 <vector228>:
.globl vector228
vector228:
  pushl $0
80105c71:	6a 00                	push   $0x0
  pushl $228
80105c73:	68 e4 00 00 00       	push   $0xe4
  jmp alltraps
80105c78:	e9 99 f2 ff ff       	jmp    80104f16 <alltraps>

80105c7d <vector229>:
.globl vector229
vector229:
  pushl $0
80105c7d:	6a 00                	push   $0x0
  pushl $229
80105c7f:	68 e5 00 00 00       	push   $0xe5
  jmp alltraps
80105c84:	e9 8d f2 ff ff       	jmp    80104f16 <alltraps>

80105c89 <vector230>:
.globl vector230
vector230:
  pushl $0
80105c89:	6a 00                	push   $0x0
  pushl $230
80105c8b:	68 e6 00 00 00       	push   $0xe6
  jmp alltraps
80105c90:	e9 81 f2 ff ff       	jmp    80104f16 <alltraps>

80105c95 <vector231>:
.globl vector231
vector231:
  pushl $0
80105c95:	6a 00                	push   $0x0
  pushl $231
80105c97:	68 e7 00 00 00       	push   $0xe7
  jmp alltraps
80105c9c:	e9 75 f2 ff ff       	jmp    80104f16 <alltraps>

80105ca1 <vector232>:
.globl vector232
vector232:
  pushl $0
80105ca1:	6a 00                	push   $0x0
  pushl $232
80105ca3:	68 e8 00 00 00       	push   $0xe8
  jmp alltraps
80105ca8:	e9 69 f2 ff ff       	jmp    80104f16 <alltraps>

80105cad <vector233>:
.globl vector233
vector233:
  pushl $0
80105cad:	6a 00                	push   $0x0
  pushl $233
80105caf:	68 e9 00 00 00       	push   $0xe9
  jmp alltraps
80105cb4:	e9 5d f2 ff ff       	jmp    80104f16 <alltraps>

80105cb9 <vector234>:
.globl vector234
vector234:
  pushl $0
80105cb9:	6a 00                	push   $0x0
  pushl $234
80105cbb:	68 ea 00 00 00       	push   $0xea
  jmp alltraps
80105cc0:	e9 51 f2 ff ff       	jmp    80104f16 <alltraps>

80105cc5 <vector235>:
.globl vector235
vector235:
  pushl $0
80105cc5:	6a 00                	push   $0x0
  pushl $235
80105cc7:	68 eb 00 00 00       	push   $0xeb
  jmp alltraps
80105ccc:	e9 45 f2 ff ff       	jmp    80104f16 <alltraps>

80105cd1 <vector236>:
.globl vector236
vector236:
  pushl $0
80105cd1:	6a 00                	push   $0x0
  pushl $236
80105cd3:	68 ec 00 00 00       	push   $0xec
  jmp alltraps
80105cd8:	e9 39 f2 ff ff       	jmp    80104f16 <alltraps>

80105cdd <vector237>:
.globl vector237
vector237:
  pushl $0
80105cdd:	6a 00                	push   $0x0
  pushl $237
80105cdf:	68 ed 00 00 00       	push   $0xed
  jmp alltraps
80105ce4:	e9 2d f2 ff ff       	jmp    80104f16 <alltraps>

80105ce9 <vector238>:
.globl vector238
vector238:
  pushl $0
80105ce9:	6a 00                	push   $0x0
  pushl $238
80105ceb:	68 ee 00 00 00       	push   $0xee
  jmp alltraps
80105cf0:	e9 21 f2 ff ff       	jmp    80104f16 <alltraps>

80105cf5 <vector239>:
.globl vector239
vector239:
  pushl $0
80105cf5:	6a 00                	push   $0x0
  pushl $239
80105cf7:	68 ef 00 00 00       	push   $0xef
  jmp alltraps
80105cfc:	e9 15 f2 ff ff       	jmp    80104f16 <alltraps>

80105d01 <vector240>:
.globl vector240
vector240:
  pushl $0
80105d01:	6a 00                	push   $0x0
  pushl $240
80105d03:	68 f0 00 00 00       	push   $0xf0
  jmp alltraps
80105d08:	e9 09 f2 ff ff       	jmp    80104f16 <alltraps>

80105d0d <vector241>:
.globl vector241
vector241:
  pushl $0
80105d0d:	6a 00                	push   $0x0
  pushl $241
80105d0f:	68 f1 00 00 00       	push   $0xf1
  jmp alltraps
80105d14:	e9 fd f1 ff ff       	jmp    80104f16 <alltraps>

80105d19 <vector242>:
.globl vector242
vector242:
  pushl $0
80105d19:	6a 00                	push   $0x0
  pushl $242
80105d1b:	68 f2 00 00 00       	push   $0xf2
  jmp alltraps
80105d20:	e9 f1 f1 ff ff       	jmp    80104f16 <alltraps>

80105d25 <vector243>:
.globl vector243
vector243:
  pushl $0
80105d25:	6a 00                	push   $0x0
  pushl $243
80105d27:	68 f3 00 00 00       	push   $0xf3
  jmp alltraps
80105d2c:	e9 e5 f1 ff ff       	jmp    80104f16 <alltraps>

80105d31 <vector244>:
.globl vector244
vector244:
  pushl $0
80105d31:	6a 00                	push   $0x0
  pushl $244
80105d33:	68 f4 00 00 00       	push   $0xf4
  jmp alltraps
80105d38:	e9 d9 f1 ff ff       	jmp    80104f16 <alltraps>

80105d3d <vector245>:
.globl vector245
vector245:
  pushl $0
80105d3d:	6a 00                	push   $0x0
  pushl $245
80105d3f:	68 f5 00 00 00       	push   $0xf5
  jmp alltraps
80105d44:	e9 cd f1 ff ff       	jmp    80104f16 <alltraps>

80105d49 <vector246>:
.globl vector246
vector246:
  pushl $0
80105d49:	6a 00                	push   $0x0
  pushl $246
80105d4b:	68 f6 00 00 00       	push   $0xf6
  jmp alltraps
80105d50:	e9 c1 f1 ff ff       	jmp    80104f16 <alltraps>

80105d55 <vector247>:
.globl vector247
vector247:
  pushl $0
80105d55:	6a 00                	push   $0x0
  pushl $247
80105d57:	68 f7 00 00 00       	push   $0xf7
  jmp alltraps
80105d5c:	e9 b5 f1 ff ff       	jmp    80104f16 <alltraps>

80105d61 <vector248>:
.globl vector248
vector248:
  pushl $0
80105d61:	6a 00                	push   $0x0
  pushl $248
80105d63:	68 f8 00 00 00       	push   $0xf8
  jmp alltraps
80105d68:	e9 a9 f1 ff ff       	jmp    80104f16 <alltraps>

80105d6d <vector249>:
.globl vector249
vector249:
  pushl $0
80105d6d:	6a 00                	push   $0x0
  pushl $249
80105d6f:	68 f9 00 00 00       	push   $0xf9
  jmp alltraps
80105d74:	e9 9d f1 ff ff       	jmp    80104f16 <alltraps>

80105d79 <vector250>:
.globl vector250
vector250:
  pushl $0
80105d79:	6a 00                	push   $0x0
  pushl $250
80105d7b:	68 fa 00 00 00       	push   $0xfa
  jmp alltraps
80105d80:	e9 91 f1 ff ff       	jmp    80104f16 <alltraps>

80105d85 <vector251>:
.globl vector251
vector251:
  pushl $0
80105d85:	6a 00                	push   $0x0
  pushl $251
80105d87:	68 fb 00 00 00       	push   $0xfb
  jmp alltraps
80105d8c:	e9 85 f1 ff ff       	jmp    80104f16 <alltraps>

80105d91 <vector252>:
.globl vector252
vector252:
  pushl $0
80105d91:	6a 00                	push   $0x0
  pushl $252
80105d93:	68 fc 00 00 00       	push   $0xfc
  jmp alltraps
80105d98:	e9 79 f1 ff ff       	jmp    80104f16 <alltraps>

80105d9d <vector253>:
.globl vector253
vector253:
  pushl $0
80105d9d:	6a 00                	push   $0x0
  pushl $253
80105d9f:	68 fd 00 00 00       	push   $0xfd
  jmp alltraps
80105da4:	e9 6d f1 ff ff       	jmp    80104f16 <alltraps>

80105da9 <vector254>:
.globl vector254
vector254:
  pushl $0
80105da9:	6a 00                	push   $0x0
  pushl $254
80105dab:	68 fe 00 00 00       	push   $0xfe
  jmp alltraps
80105db0:	e9 61 f1 ff ff       	jmp    80104f16 <alltraps>

80105db5 <vector255>:
.globl vector255
vector255:
  pushl $0
80105db5:	6a 00                	push   $0x0
  pushl $255
80105db7:	68 ff 00 00 00       	push   $0xff
  jmp alltraps
80105dbc:	e9 55 f1 ff ff       	jmp    80104f16 <alltraps>

80105dc1 <walkpgdir>:
// Return the address of the PTE in page table pgdir
// that corresponds to virtual address va.  If alloc!=0,
// create any required page table pages.
static pte_t *
walkpgdir(pde_t *pgdir, const void *va, int alloc)
{
80105dc1:	55                   	push   %ebp
80105dc2:	89 e5                	mov    %esp,%ebp
80105dc4:	57                   	push   %edi
80105dc5:	56                   	push   %esi
80105dc6:	53                   	push   %ebx
80105dc7:	83 ec 0c             	sub    $0xc,%esp
80105dca:	89 d6                	mov    %edx,%esi
  pde_t *pde;
  pte_t *pgtab;

  pde = &pgdir[PDX(va)];
80105dcc:	c1 ea 16             	shr    $0x16,%edx
80105dcf:	8d 3c 90             	lea    (%eax,%edx,4),%edi
  if(*pde & PTE_P){
80105dd2:	8b 1f                	mov    (%edi),%ebx
80105dd4:	f6 c3 01             	test   $0x1,%bl
80105dd7:	74 22                	je     80105dfb <walkpgdir+0x3a>
    pgtab = (pte_t*)P2V(PTE_ADDR(*pde));
80105dd9:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
80105ddf:	81 c3 00 00 00 80    	add    $0x80000000,%ebx
    // The permissions here are overly generous, but they can
    // be further restricted by the permissions in the page table
    // entries, if necessary.
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
  }
  return &pgtab[PTX(va)];
80105de5:	c1 ee 0c             	shr    $0xc,%esi
80105de8:	81 e6 ff 03 00 00    	and    $0x3ff,%esi
80105dee:	8d 1c b3             	lea    (%ebx,%esi,4),%ebx
}
80105df1:	89 d8                	mov    %ebx,%eax
80105df3:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105df6:	5b                   	pop    %ebx
80105df7:	5e                   	pop    %esi
80105df8:	5f                   	pop    %edi
80105df9:	5d                   	pop    %ebp
80105dfa:	c3                   	ret    
    if(!alloc || (pgtab = (pte_t*)kalloc()) == 0)
80105dfb:	85 c9                	test   %ecx,%ecx
80105dfd:	74 2b                	je     80105e2a <walkpgdir+0x69>
80105dff:	e8 c1 c2 ff ff       	call   801020c5 <kalloc>
80105e04:	89 c3                	mov    %eax,%ebx
80105e06:	85 c0                	test   %eax,%eax
80105e08:	74 e7                	je     80105df1 <walkpgdir+0x30>
    memset(pgtab, 0, PGSIZE);
80105e0a:	83 ec 04             	sub    $0x4,%esp
80105e0d:	68 00 10 00 00       	push   $0x1000
80105e12:	6a 00                	push   $0x0
80105e14:	50                   	push   %eax
80105e15:	e8 f1 df ff ff       	call   80103e0b <memset>
    *pde = V2P(pgtab) | PTE_P | PTE_W | PTE_U;
80105e1a:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80105e20:	83 c8 07             	or     $0x7,%eax
80105e23:	89 07                	mov    %eax,(%edi)
80105e25:	83 c4 10             	add    $0x10,%esp
80105e28:	eb bb                	jmp    80105de5 <walkpgdir+0x24>
      return 0;
80105e2a:	bb 00 00 00 00       	mov    $0x0,%ebx
80105e2f:	eb c0                	jmp    80105df1 <walkpgdir+0x30>

80105e31 <mappages>:
// Create PTEs for virtual addresses starting at va that refer to
// physical addresses starting at pa. va and size might not
// be page-aligned.
static int
mappages(pde_t *pgdir, void *va, uint size, uint pa, int perm)
{
80105e31:	55                   	push   %ebp
80105e32:	89 e5                	mov    %esp,%ebp
80105e34:	57                   	push   %edi
80105e35:	56                   	push   %esi
80105e36:	53                   	push   %ebx
80105e37:	83 ec 1c             	sub    $0x1c,%esp
80105e3a:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80105e3d:	8b 75 08             	mov    0x8(%ebp),%esi
  char *a, *last;
  pte_t *pte;

  a = (char*)PGROUNDDOWN((uint)va);
80105e40:	89 d3                	mov    %edx,%ebx
80105e42:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  last = (char*)PGROUNDDOWN(((uint)va) + size - 1);
80105e48:	8d 7c 0a ff          	lea    -0x1(%edx,%ecx,1),%edi
80105e4c:	81 e7 00 f0 ff ff    	and    $0xfffff000,%edi
  for(;;){
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e52:	b9 01 00 00 00       	mov    $0x1,%ecx
80105e57:	89 da                	mov    %ebx,%edx
80105e59:	8b 45 e4             	mov    -0x1c(%ebp),%eax
80105e5c:	e8 60 ff ff ff       	call   80105dc1 <walkpgdir>
80105e61:	85 c0                	test   %eax,%eax
80105e63:	74 2e                	je     80105e93 <mappages+0x62>
      return -1;
    if(*pte & PTE_P)
80105e65:	f6 00 01             	testb  $0x1,(%eax)
80105e68:	75 1c                	jne    80105e86 <mappages+0x55>
      panic("remap");
    *pte = pa | perm | PTE_P;
80105e6a:	89 f2                	mov    %esi,%edx
80105e6c:	0b 55 0c             	or     0xc(%ebp),%edx
80105e6f:	83 ca 01             	or     $0x1,%edx
80105e72:	89 10                	mov    %edx,(%eax)
    if(a == last)
80105e74:	39 fb                	cmp    %edi,%ebx
80105e76:	74 28                	je     80105ea0 <mappages+0x6f>
      break;
    a += PGSIZE;
80105e78:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    pa += PGSIZE;
80105e7e:	81 c6 00 10 00 00    	add    $0x1000,%esi
    if((pte = walkpgdir(pgdir, a, 1)) == 0)
80105e84:	eb cc                	jmp    80105e52 <mappages+0x21>
      panic("remap");
80105e86:	83 ec 0c             	sub    $0xc,%esp
80105e89:	68 10 70 10 80       	push   $0x80107010
80105e8e:	e8 b5 a4 ff ff       	call   80100348 <panic>
      return -1;
80105e93:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
  }
  return 0;
}
80105e98:	8d 65 f4             	lea    -0xc(%ebp),%esp
80105e9b:	5b                   	pop    %ebx
80105e9c:	5e                   	pop    %esi
80105e9d:	5f                   	pop    %edi
80105e9e:	5d                   	pop    %ebp
80105e9f:	c3                   	ret    
  return 0;
80105ea0:	b8 00 00 00 00       	mov    $0x0,%eax
80105ea5:	eb f1                	jmp    80105e98 <mappages+0x67>

80105ea7 <seginit>:
{
80105ea7:	55                   	push   %ebp
80105ea8:	89 e5                	mov    %esp,%ebp
80105eaa:	53                   	push   %ebx
80105eab:	83 ec 14             	sub    $0x14,%esp
  c = &cpus[cpuid()];
80105eae:	e8 f2 d4 ff ff       	call   801033a5 <cpuid>
  c->gdt[SEG_KCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, 0);
80105eb3:	69 c0 b0 00 00 00    	imul   $0xb0,%eax,%eax
80105eb9:	66 c7 80 38 28 13 80 	movw   $0xffff,-0x7fecd7c8(%eax)
80105ec0:	ff ff 
80105ec2:	66 c7 80 3a 28 13 80 	movw   $0x0,-0x7fecd7c6(%eax)
80105ec9:	00 00 
80105ecb:	c6 80 3c 28 13 80 00 	movb   $0x0,-0x7fecd7c4(%eax)
80105ed2:	0f b6 88 3d 28 13 80 	movzbl -0x7fecd7c3(%eax),%ecx
80105ed9:	83 e1 f0             	and    $0xfffffff0,%ecx
80105edc:	83 c9 1a             	or     $0x1a,%ecx
80105edf:	83 e1 9f             	and    $0xffffff9f,%ecx
80105ee2:	83 c9 80             	or     $0xffffff80,%ecx
80105ee5:	88 88 3d 28 13 80    	mov    %cl,-0x7fecd7c3(%eax)
80105eeb:	0f b6 88 3e 28 13 80 	movzbl -0x7fecd7c2(%eax),%ecx
80105ef2:	83 c9 0f             	or     $0xf,%ecx
80105ef5:	83 e1 cf             	and    $0xffffffcf,%ecx
80105ef8:	83 c9 c0             	or     $0xffffffc0,%ecx
80105efb:	88 88 3e 28 13 80    	mov    %cl,-0x7fecd7c2(%eax)
80105f01:	c6 80 3f 28 13 80 00 	movb   $0x0,-0x7fecd7c1(%eax)
  c->gdt[SEG_KDATA] = SEG(STA_W, 0, 0xffffffff, 0);
80105f08:	66 c7 80 40 28 13 80 	movw   $0xffff,-0x7fecd7c0(%eax)
80105f0f:	ff ff 
80105f11:	66 c7 80 42 28 13 80 	movw   $0x0,-0x7fecd7be(%eax)
80105f18:	00 00 
80105f1a:	c6 80 44 28 13 80 00 	movb   $0x0,-0x7fecd7bc(%eax)
80105f21:	0f b6 88 45 28 13 80 	movzbl -0x7fecd7bb(%eax),%ecx
80105f28:	83 e1 f0             	and    $0xfffffff0,%ecx
80105f2b:	83 c9 12             	or     $0x12,%ecx
80105f2e:	83 e1 9f             	and    $0xffffff9f,%ecx
80105f31:	83 c9 80             	or     $0xffffff80,%ecx
80105f34:	88 88 45 28 13 80    	mov    %cl,-0x7fecd7bb(%eax)
80105f3a:	0f b6 88 46 28 13 80 	movzbl -0x7fecd7ba(%eax),%ecx
80105f41:	83 c9 0f             	or     $0xf,%ecx
80105f44:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f47:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f4a:	88 88 46 28 13 80    	mov    %cl,-0x7fecd7ba(%eax)
80105f50:	c6 80 47 28 13 80 00 	movb   $0x0,-0x7fecd7b9(%eax)
  c->gdt[SEG_UCODE] = SEG(STA_X|STA_R, 0, 0xffffffff, DPL_USER);
80105f57:	66 c7 80 48 28 13 80 	movw   $0xffff,-0x7fecd7b8(%eax)
80105f5e:	ff ff 
80105f60:	66 c7 80 4a 28 13 80 	movw   $0x0,-0x7fecd7b6(%eax)
80105f67:	00 00 
80105f69:	c6 80 4c 28 13 80 00 	movb   $0x0,-0x7fecd7b4(%eax)
80105f70:	c6 80 4d 28 13 80 fa 	movb   $0xfa,-0x7fecd7b3(%eax)
80105f77:	0f b6 88 4e 28 13 80 	movzbl -0x7fecd7b2(%eax),%ecx
80105f7e:	83 c9 0f             	or     $0xf,%ecx
80105f81:	83 e1 cf             	and    $0xffffffcf,%ecx
80105f84:	83 c9 c0             	or     $0xffffffc0,%ecx
80105f87:	88 88 4e 28 13 80    	mov    %cl,-0x7fecd7b2(%eax)
80105f8d:	c6 80 4f 28 13 80 00 	movb   $0x0,-0x7fecd7b1(%eax)
  c->gdt[SEG_UDATA] = SEG(STA_W, 0, 0xffffffff, DPL_USER);
80105f94:	66 c7 80 50 28 13 80 	movw   $0xffff,-0x7fecd7b0(%eax)
80105f9b:	ff ff 
80105f9d:	66 c7 80 52 28 13 80 	movw   $0x0,-0x7fecd7ae(%eax)
80105fa4:	00 00 
80105fa6:	c6 80 54 28 13 80 00 	movb   $0x0,-0x7fecd7ac(%eax)
80105fad:	c6 80 55 28 13 80 f2 	movb   $0xf2,-0x7fecd7ab(%eax)
80105fb4:	0f b6 88 56 28 13 80 	movzbl -0x7fecd7aa(%eax),%ecx
80105fbb:	83 c9 0f             	or     $0xf,%ecx
80105fbe:	83 e1 cf             	and    $0xffffffcf,%ecx
80105fc1:	83 c9 c0             	or     $0xffffffc0,%ecx
80105fc4:	88 88 56 28 13 80    	mov    %cl,-0x7fecd7aa(%eax)
80105fca:	c6 80 57 28 13 80 00 	movb   $0x0,-0x7fecd7a9(%eax)
  lgdt(c->gdt, sizeof(c->gdt));
80105fd1:	05 30 28 13 80       	add    $0x80132830,%eax
  pd[0] = size-1;
80105fd6:	66 c7 45 f2 2f 00    	movw   $0x2f,-0xe(%ebp)
  pd[1] = (uint)p;
80105fdc:	66 89 45 f4          	mov    %ax,-0xc(%ebp)
  pd[2] = (uint)p >> 16;
80105fe0:	c1 e8 10             	shr    $0x10,%eax
80105fe3:	66 89 45 f6          	mov    %ax,-0xa(%ebp)
  asm volatile("lgdt (%0)" : : "r" (pd));
80105fe7:	8d 45 f2             	lea    -0xe(%ebp),%eax
80105fea:	0f 01 10             	lgdtl  (%eax)
}
80105fed:	83 c4 14             	add    $0x14,%esp
80105ff0:	5b                   	pop    %ebx
80105ff1:	5d                   	pop    %ebp
80105ff2:	c3                   	ret    

80105ff3 <switchkvm>:

// Switch h/w page table register to the kernel-only page table,
// for when no process is running.
void
switchkvm(void)
{
80105ff3:	55                   	push   %ebp
80105ff4:	89 e5                	mov    %esp,%ebp
  lcr3(V2P(kpgdir));   // switch to the kernel page table
80105ff6:	a1 e4 54 13 80       	mov    0x801354e4,%eax
80105ffb:	05 00 00 00 80       	add    $0x80000000,%eax
}

static inline void
lcr3(uint val)
{
  asm volatile("movl %0,%%cr3" : : "r" (val));
80106000:	0f 22 d8             	mov    %eax,%cr3
}
80106003:	5d                   	pop    %ebp
80106004:	c3                   	ret    

80106005 <switchuvm>:

// Switch TSS and h/w page table to correspond to process p.
void
switchuvm(struct proc *p)
{
80106005:	55                   	push   %ebp
80106006:	89 e5                	mov    %esp,%ebp
80106008:	57                   	push   %edi
80106009:	56                   	push   %esi
8010600a:	53                   	push   %ebx
8010600b:	83 ec 1c             	sub    $0x1c,%esp
8010600e:	8b 75 08             	mov    0x8(%ebp),%esi
  if(p == 0)
80106011:	85 f6                	test   %esi,%esi
80106013:	0f 84 dd 00 00 00    	je     801060f6 <switchuvm+0xf1>
    panic("switchuvm: no process");
  if(p->kstack == 0)
80106019:	83 7e 08 00          	cmpl   $0x0,0x8(%esi)
8010601d:	0f 84 e0 00 00 00    	je     80106103 <switchuvm+0xfe>
    panic("switchuvm: no kstack");
  if(p->pgdir == 0)
80106023:	83 7e 04 00          	cmpl   $0x0,0x4(%esi)
80106027:	0f 84 e3 00 00 00    	je     80106110 <switchuvm+0x10b>
    panic("switchuvm: no pgdir");

  pushcli();
8010602d:	e8 50 dc ff ff       	call   80103c82 <pushcli>
  mycpu()->gdt[SEG_TSS] = SEG16(STS_T32A, &mycpu()->ts,
80106032:	e8 12 d3 ff ff       	call   80103349 <mycpu>
80106037:	89 c3                	mov    %eax,%ebx
80106039:	e8 0b d3 ff ff       	call   80103349 <mycpu>
8010603e:	8d 78 08             	lea    0x8(%eax),%edi
80106041:	e8 03 d3 ff ff       	call   80103349 <mycpu>
80106046:	83 c0 08             	add    $0x8,%eax
80106049:	c1 e8 10             	shr    $0x10,%eax
8010604c:	89 45 e4             	mov    %eax,-0x1c(%ebp)
8010604f:	e8 f5 d2 ff ff       	call   80103349 <mycpu>
80106054:	83 c0 08             	add    $0x8,%eax
80106057:	c1 e8 18             	shr    $0x18,%eax
8010605a:	66 c7 83 98 00 00 00 	movw   $0x67,0x98(%ebx)
80106061:	67 00 
80106063:	66 89 bb 9a 00 00 00 	mov    %di,0x9a(%ebx)
8010606a:	0f b6 4d e4          	movzbl -0x1c(%ebp),%ecx
8010606e:	88 8b 9c 00 00 00    	mov    %cl,0x9c(%ebx)
80106074:	0f b6 93 9d 00 00 00 	movzbl 0x9d(%ebx),%edx
8010607b:	83 e2 f0             	and    $0xfffffff0,%edx
8010607e:	83 ca 19             	or     $0x19,%edx
80106081:	83 e2 9f             	and    $0xffffff9f,%edx
80106084:	83 ca 80             	or     $0xffffff80,%edx
80106087:	88 93 9d 00 00 00    	mov    %dl,0x9d(%ebx)
8010608d:	c6 83 9e 00 00 00 40 	movb   $0x40,0x9e(%ebx)
80106094:	88 83 9f 00 00 00    	mov    %al,0x9f(%ebx)
                                sizeof(mycpu()->ts)-1, 0);
  mycpu()->gdt[SEG_TSS].s = 0;
8010609a:	e8 aa d2 ff ff       	call   80103349 <mycpu>
8010609f:	0f b6 90 9d 00 00 00 	movzbl 0x9d(%eax),%edx
801060a6:	83 e2 ef             	and    $0xffffffef,%edx
801060a9:	88 90 9d 00 00 00    	mov    %dl,0x9d(%eax)
  mycpu()->ts.ss0 = SEG_KDATA << 3;
801060af:	e8 95 d2 ff ff       	call   80103349 <mycpu>
801060b4:	66 c7 40 10 10 00    	movw   $0x10,0x10(%eax)
  mycpu()->ts.esp0 = (uint)p->kstack + KSTACKSIZE;
801060ba:	8b 5e 08             	mov    0x8(%esi),%ebx
801060bd:	e8 87 d2 ff ff       	call   80103349 <mycpu>
801060c2:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801060c8:	89 58 0c             	mov    %ebx,0xc(%eax)
  // setting IOPL=0 in eflags *and* iomb beyond the tss segment limit
  // forbids I/O instructions (e.g., inb and outb) from user space
  mycpu()->ts.iomb = (ushort) 0xFFFF;
801060cb:	e8 79 d2 ff ff       	call   80103349 <mycpu>
801060d0:	66 c7 40 6e ff ff    	movw   $0xffff,0x6e(%eax)
  asm volatile("ltr %0" : : "r" (sel));
801060d6:	b8 28 00 00 00       	mov    $0x28,%eax
801060db:	0f 00 d8             	ltr    %ax
  ltr(SEG_TSS << 3);
  lcr3(V2P(p->pgdir));  // switch to process's address space
801060de:	8b 46 04             	mov    0x4(%esi),%eax
801060e1:	05 00 00 00 80       	add    $0x80000000,%eax
  asm volatile("movl %0,%%cr3" : : "r" (val));
801060e6:	0f 22 d8             	mov    %eax,%cr3
  popcli();
801060e9:	e8 d1 db ff ff       	call   80103cbf <popcli>
}
801060ee:	8d 65 f4             	lea    -0xc(%ebp),%esp
801060f1:	5b                   	pop    %ebx
801060f2:	5e                   	pop    %esi
801060f3:	5f                   	pop    %edi
801060f4:	5d                   	pop    %ebp
801060f5:	c3                   	ret    
    panic("switchuvm: no process");
801060f6:	83 ec 0c             	sub    $0xc,%esp
801060f9:	68 16 70 10 80       	push   $0x80107016
801060fe:	e8 45 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no kstack");
80106103:	83 ec 0c             	sub    $0xc,%esp
80106106:	68 2c 70 10 80       	push   $0x8010702c
8010610b:	e8 38 a2 ff ff       	call   80100348 <panic>
    panic("switchuvm: no pgdir");
80106110:	83 ec 0c             	sub    $0xc,%esp
80106113:	68 41 70 10 80       	push   $0x80107041
80106118:	e8 2b a2 ff ff       	call   80100348 <panic>

8010611d <inituvm>:

// Load the initcode into address 0 of pgdir.
// sz must be less than a page.
void
inituvm(pde_t *pgdir, char *init, uint sz)
{
8010611d:	55                   	push   %ebp
8010611e:	89 e5                	mov    %esp,%ebp
80106120:	56                   	push   %esi
80106121:	53                   	push   %ebx
80106122:	8b 75 10             	mov    0x10(%ebp),%esi
  char *mem;

  if(sz >= PGSIZE)
80106125:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
8010612b:	77 4c                	ja     80106179 <inituvm+0x5c>
    panic("inituvm: more than a page");
  mem = kalloc();
8010612d:	e8 93 bf ff ff       	call   801020c5 <kalloc>
80106132:	89 c3                	mov    %eax,%ebx
  memset(mem, 0, PGSIZE);
80106134:	83 ec 04             	sub    $0x4,%esp
80106137:	68 00 10 00 00       	push   $0x1000
8010613c:	6a 00                	push   $0x0
8010613e:	50                   	push   %eax
8010613f:	e8 c7 dc ff ff       	call   80103e0b <memset>
  mappages(pgdir, 0, PGSIZE, V2P(mem), PTE_W|PTE_U);
80106144:	83 c4 08             	add    $0x8,%esp
80106147:	6a 06                	push   $0x6
80106149:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
8010614f:	50                   	push   %eax
80106150:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106155:	ba 00 00 00 00       	mov    $0x0,%edx
8010615a:	8b 45 08             	mov    0x8(%ebp),%eax
8010615d:	e8 cf fc ff ff       	call   80105e31 <mappages>
  memmove(mem, init, sz);
80106162:	83 c4 0c             	add    $0xc,%esp
80106165:	56                   	push   %esi
80106166:	ff 75 0c             	pushl  0xc(%ebp)
80106169:	53                   	push   %ebx
8010616a:	e8 17 dd ff ff       	call   80103e86 <memmove>
}
8010616f:	83 c4 10             	add    $0x10,%esp
80106172:	8d 65 f8             	lea    -0x8(%ebp),%esp
80106175:	5b                   	pop    %ebx
80106176:	5e                   	pop    %esi
80106177:	5d                   	pop    %ebp
80106178:	c3                   	ret    
    panic("inituvm: more than a page");
80106179:	83 ec 0c             	sub    $0xc,%esp
8010617c:	68 55 70 10 80       	push   $0x80107055
80106181:	e8 c2 a1 ff ff       	call   80100348 <panic>

80106186 <loaduvm>:

// Load a program segment into pgdir.  addr must be page-aligned
// and the pages from addr to addr+sz must already be mapped.
int
loaduvm(pde_t *pgdir, char *addr, struct inode *ip, uint offset, uint sz)
{
80106186:	55                   	push   %ebp
80106187:	89 e5                	mov    %esp,%ebp
80106189:	57                   	push   %edi
8010618a:	56                   	push   %esi
8010618b:	53                   	push   %ebx
8010618c:	83 ec 0c             	sub    $0xc,%esp
8010618f:	8b 7d 18             	mov    0x18(%ebp),%edi
  uint i, pa, n;
  pte_t *pte;

  if((uint) addr % PGSIZE != 0)
80106192:	f7 45 0c ff 0f 00 00 	testl  $0xfff,0xc(%ebp)
80106199:	75 07                	jne    801061a2 <loaduvm+0x1c>
    panic("loaduvm: addr must be page aligned");
  for(i = 0; i < sz; i += PGSIZE){
8010619b:	bb 00 00 00 00       	mov    $0x0,%ebx
801061a0:	eb 3c                	jmp    801061de <loaduvm+0x58>
    panic("loaduvm: addr must be page aligned");
801061a2:	83 ec 0c             	sub    $0xc,%esp
801061a5:	68 10 71 10 80       	push   $0x80107110
801061aa:	e8 99 a1 ff ff       	call   80100348 <panic>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
      panic("loaduvm: address should exist");
801061af:	83 ec 0c             	sub    $0xc,%esp
801061b2:	68 6f 70 10 80       	push   $0x8010706f
801061b7:	e8 8c a1 ff ff       	call   80100348 <panic>
    pa = PTE_ADDR(*pte);
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, P2V(pa), offset+i, n) != n)
801061bc:	05 00 00 00 80       	add    $0x80000000,%eax
801061c1:	56                   	push   %esi
801061c2:	89 da                	mov    %ebx,%edx
801061c4:	03 55 14             	add    0x14(%ebp),%edx
801061c7:	52                   	push   %edx
801061c8:	50                   	push   %eax
801061c9:	ff 75 10             	pushl  0x10(%ebp)
801061cc:	e8 a2 b5 ff ff       	call   80101773 <readi>
801061d1:	83 c4 10             	add    $0x10,%esp
801061d4:	39 f0                	cmp    %esi,%eax
801061d6:	75 47                	jne    8010621f <loaduvm+0x99>
  for(i = 0; i < sz; i += PGSIZE){
801061d8:	81 c3 00 10 00 00    	add    $0x1000,%ebx
801061de:	39 fb                	cmp    %edi,%ebx
801061e0:	73 30                	jae    80106212 <loaduvm+0x8c>
    if((pte = walkpgdir(pgdir, addr+i, 0)) == 0)
801061e2:	89 da                	mov    %ebx,%edx
801061e4:	03 55 0c             	add    0xc(%ebp),%edx
801061e7:	b9 00 00 00 00       	mov    $0x0,%ecx
801061ec:	8b 45 08             	mov    0x8(%ebp),%eax
801061ef:	e8 cd fb ff ff       	call   80105dc1 <walkpgdir>
801061f4:	85 c0                	test   %eax,%eax
801061f6:	74 b7                	je     801061af <loaduvm+0x29>
    pa = PTE_ADDR(*pte);
801061f8:	8b 00                	mov    (%eax),%eax
801061fa:	25 00 f0 ff ff       	and    $0xfffff000,%eax
    if(sz - i < PGSIZE)
801061ff:	89 fe                	mov    %edi,%esi
80106201:	29 de                	sub    %ebx,%esi
80106203:	81 fe ff 0f 00 00    	cmp    $0xfff,%esi
80106209:	76 b1                	jbe    801061bc <loaduvm+0x36>
      n = PGSIZE;
8010620b:	be 00 10 00 00       	mov    $0x1000,%esi
80106210:	eb aa                	jmp    801061bc <loaduvm+0x36>
      return -1;
  }
  return 0;
80106212:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106217:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010621a:	5b                   	pop    %ebx
8010621b:	5e                   	pop    %esi
8010621c:	5f                   	pop    %edi
8010621d:	5d                   	pop    %ebp
8010621e:	c3                   	ret    
      return -1;
8010621f:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
80106224:	eb f1                	jmp    80106217 <loaduvm+0x91>

80106226 <deallocuvm>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
int
deallocuvm(pde_t *pgdir, uint oldsz, uint newsz)
{
80106226:	55                   	push   %ebp
80106227:	89 e5                	mov    %esp,%ebp
80106229:	57                   	push   %edi
8010622a:	56                   	push   %esi
8010622b:	53                   	push   %ebx
8010622c:	83 ec 0c             	sub    $0xc,%esp
8010622f:	8b 7d 0c             	mov    0xc(%ebp),%edi
  pte_t *pte;
  uint a, pa;

  if(newsz >= oldsz)
80106232:	39 7d 10             	cmp    %edi,0x10(%ebp)
80106235:	73 11                	jae    80106248 <deallocuvm+0x22>
    return oldsz;

  a = PGROUNDUP(newsz);
80106237:	8b 45 10             	mov    0x10(%ebp),%eax
8010623a:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
80106240:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a  < oldsz; a += PGSIZE){
80106246:	eb 19                	jmp    80106261 <deallocuvm+0x3b>
    return oldsz;
80106248:	89 f8                	mov    %edi,%eax
8010624a:	eb 64                	jmp    801062b0 <deallocuvm+0x8a>
    pte = walkpgdir(pgdir, (char*)a, 0);
    if(!pte)
      a = PGADDR(PDX(a) + 1, 0, 0) - PGSIZE;
8010624c:	c1 eb 16             	shr    $0x16,%ebx
8010624f:	83 c3 01             	add    $0x1,%ebx
80106252:	c1 e3 16             	shl    $0x16,%ebx
80106255:	81 eb 00 10 00 00    	sub    $0x1000,%ebx
  for(; a  < oldsz; a += PGSIZE){
8010625b:	81 c3 00 10 00 00    	add    $0x1000,%ebx
80106261:	39 fb                	cmp    %edi,%ebx
80106263:	73 48                	jae    801062ad <deallocuvm+0x87>
    pte = walkpgdir(pgdir, (char*)a, 0);
80106265:	b9 00 00 00 00       	mov    $0x0,%ecx
8010626a:	89 da                	mov    %ebx,%edx
8010626c:	8b 45 08             	mov    0x8(%ebp),%eax
8010626f:	e8 4d fb ff ff       	call   80105dc1 <walkpgdir>
80106274:	89 c6                	mov    %eax,%esi
    if(!pte)
80106276:	85 c0                	test   %eax,%eax
80106278:	74 d2                	je     8010624c <deallocuvm+0x26>
    else if((*pte & PTE_P) != 0){
8010627a:	8b 00                	mov    (%eax),%eax
8010627c:	a8 01                	test   $0x1,%al
8010627e:	74 db                	je     8010625b <deallocuvm+0x35>
      pa = PTE_ADDR(*pte);
      if(pa == 0)
80106280:	25 00 f0 ff ff       	and    $0xfffff000,%eax
80106285:	74 19                	je     801062a0 <deallocuvm+0x7a>
        panic("kfree");
      char *v = P2V(pa);
80106287:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
8010628c:	83 ec 0c             	sub    $0xc,%esp
8010628f:	50                   	push   %eax
80106290:	e8 0f bd ff ff       	call   80101fa4 <kfree>
      *pte = 0;
80106295:	c7 06 00 00 00 00    	movl   $0x0,(%esi)
8010629b:	83 c4 10             	add    $0x10,%esp
8010629e:	eb bb                	jmp    8010625b <deallocuvm+0x35>
        panic("kfree");
801062a0:	83 ec 0c             	sub    $0xc,%esp
801062a3:	68 c6 68 10 80       	push   $0x801068c6
801062a8:	e8 9b a0 ff ff       	call   80100348 <panic>
    }
  }
  return newsz;
801062ad:	8b 45 10             	mov    0x10(%ebp),%eax
}
801062b0:	8d 65 f4             	lea    -0xc(%ebp),%esp
801062b3:	5b                   	pop    %ebx
801062b4:	5e                   	pop    %esi
801062b5:	5f                   	pop    %edi
801062b6:	5d                   	pop    %ebp
801062b7:	c3                   	ret    

801062b8 <allocuvm>:
{
801062b8:	55                   	push   %ebp
801062b9:	89 e5                	mov    %esp,%ebp
801062bb:	57                   	push   %edi
801062bc:	56                   	push   %esi
801062bd:	53                   	push   %ebx
801062be:	83 ec 1c             	sub    $0x1c,%esp
801062c1:	8b 7d 10             	mov    0x10(%ebp),%edi
  if(newsz >= KERNBASE)
801062c4:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801062c7:	85 ff                	test   %edi,%edi
801062c9:	0f 88 c1 00 00 00    	js     80106390 <allocuvm+0xd8>
  if(newsz < oldsz)
801062cf:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801062d2:	72 5c                	jb     80106330 <allocuvm+0x78>
  a = PGROUNDUP(oldsz);
801062d4:	8b 45 0c             	mov    0xc(%ebp),%eax
801062d7:	8d 98 ff 0f 00 00    	lea    0xfff(%eax),%ebx
801062dd:	81 e3 00 f0 ff ff    	and    $0xfffff000,%ebx
  for(; a < newsz; a += PGSIZE){
801062e3:	39 fb                	cmp    %edi,%ebx
801062e5:	0f 83 ac 00 00 00    	jae    80106397 <allocuvm+0xdf>
    mem = kalloc();
801062eb:	e8 d5 bd ff ff       	call   801020c5 <kalloc>
801062f0:	89 c6                	mov    %eax,%esi
    if(mem == 0){
801062f2:	85 c0                	test   %eax,%eax
801062f4:	74 42                	je     80106338 <allocuvm+0x80>
    memset(mem, 0, PGSIZE);
801062f6:	83 ec 04             	sub    $0x4,%esp
801062f9:	68 00 10 00 00       	push   $0x1000
801062fe:	6a 00                	push   $0x0
80106300:	50                   	push   %eax
80106301:	e8 05 db ff ff       	call   80103e0b <memset>
    if(mappages(pgdir, (char*)a, PGSIZE, V2P(mem), PTE_W|PTE_U) < 0){
80106306:	83 c4 08             	add    $0x8,%esp
80106309:	6a 06                	push   $0x6
8010630b:	8d 86 00 00 00 80    	lea    -0x80000000(%esi),%eax
80106311:	50                   	push   %eax
80106312:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106317:	89 da                	mov    %ebx,%edx
80106319:	8b 45 08             	mov    0x8(%ebp),%eax
8010631c:	e8 10 fb ff ff       	call   80105e31 <mappages>
80106321:	83 c4 10             	add    $0x10,%esp
80106324:	85 c0                	test   %eax,%eax
80106326:	78 38                	js     80106360 <allocuvm+0xa8>
  for(; a < newsz; a += PGSIZE){
80106328:	81 c3 00 10 00 00    	add    $0x1000,%ebx
8010632e:	eb b3                	jmp    801062e3 <allocuvm+0x2b>
    return oldsz;
80106330:	8b 45 0c             	mov    0xc(%ebp),%eax
80106333:	89 45 e4             	mov    %eax,-0x1c(%ebp)
80106336:	eb 5f                	jmp    80106397 <allocuvm+0xdf>
      cprintf("allocuvm out of memory\n");
80106338:	83 ec 0c             	sub    $0xc,%esp
8010633b:	68 8d 70 10 80       	push   $0x8010708d
80106340:	e8 c6 a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
80106345:	83 c4 0c             	add    $0xc,%esp
80106348:	ff 75 0c             	pushl  0xc(%ebp)
8010634b:	57                   	push   %edi
8010634c:	ff 75 08             	pushl  0x8(%ebp)
8010634f:	e8 d2 fe ff ff       	call   80106226 <deallocuvm>
      return 0;
80106354:	83 c4 10             	add    $0x10,%esp
80106357:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010635e:	eb 37                	jmp    80106397 <allocuvm+0xdf>
      cprintf("allocuvm out of memory (2)\n");
80106360:	83 ec 0c             	sub    $0xc,%esp
80106363:	68 a5 70 10 80       	push   $0x801070a5
80106368:	e8 9e a2 ff ff       	call   8010060b <cprintf>
      deallocuvm(pgdir, newsz, oldsz);
8010636d:	83 c4 0c             	add    $0xc,%esp
80106370:	ff 75 0c             	pushl  0xc(%ebp)
80106373:	57                   	push   %edi
80106374:	ff 75 08             	pushl  0x8(%ebp)
80106377:	e8 aa fe ff ff       	call   80106226 <deallocuvm>
      kfree(mem);
8010637c:	89 34 24             	mov    %esi,(%esp)
8010637f:	e8 20 bc ff ff       	call   80101fa4 <kfree>
      return 0;
80106384:	83 c4 10             	add    $0x10,%esp
80106387:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
8010638e:	eb 07                	jmp    80106397 <allocuvm+0xdf>
    return 0;
80106390:	c7 45 e4 00 00 00 00 	movl   $0x0,-0x1c(%ebp)
}
80106397:	8b 45 e4             	mov    -0x1c(%ebp),%eax
8010639a:	8d 65 f4             	lea    -0xc(%ebp),%esp
8010639d:	5b                   	pop    %ebx
8010639e:	5e                   	pop    %esi
8010639f:	5f                   	pop    %edi
801063a0:	5d                   	pop    %ebp
801063a1:	c3                   	ret    

801063a2 <freevm>:

// Free a page table and all the physical memory pages
// in the user part.
void
freevm(pde_t *pgdir)
{
801063a2:	55                   	push   %ebp
801063a3:	89 e5                	mov    %esp,%ebp
801063a5:	56                   	push   %esi
801063a6:	53                   	push   %ebx
801063a7:	8b 75 08             	mov    0x8(%ebp),%esi
  uint i;

  if(pgdir == 0)
801063aa:	85 f6                	test   %esi,%esi
801063ac:	74 1a                	je     801063c8 <freevm+0x26>
    panic("freevm: no pgdir");
  deallocuvm(pgdir, KERNBASE, 0);
801063ae:	83 ec 04             	sub    $0x4,%esp
801063b1:	6a 00                	push   $0x0
801063b3:	68 00 00 00 80       	push   $0x80000000
801063b8:	56                   	push   %esi
801063b9:	e8 68 fe ff ff       	call   80106226 <deallocuvm>
  for(i = 0; i < NPDENTRIES; i++){
801063be:	83 c4 10             	add    $0x10,%esp
801063c1:	bb 00 00 00 00       	mov    $0x0,%ebx
801063c6:	eb 10                	jmp    801063d8 <freevm+0x36>
    panic("freevm: no pgdir");
801063c8:	83 ec 0c             	sub    $0xc,%esp
801063cb:	68 c1 70 10 80       	push   $0x801070c1
801063d0:	e8 73 9f ff ff       	call   80100348 <panic>
  for(i = 0; i < NPDENTRIES; i++){
801063d5:	83 c3 01             	add    $0x1,%ebx
801063d8:	81 fb ff 03 00 00    	cmp    $0x3ff,%ebx
801063de:	77 1f                	ja     801063ff <freevm+0x5d>
    if(pgdir[i] & PTE_P){
801063e0:	8b 04 9e             	mov    (%esi,%ebx,4),%eax
801063e3:	a8 01                	test   $0x1,%al
801063e5:	74 ee                	je     801063d5 <freevm+0x33>
      char * v = P2V(PTE_ADDR(pgdir[i]));
801063e7:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801063ec:	05 00 00 00 80       	add    $0x80000000,%eax
      kfree(v);
801063f1:	83 ec 0c             	sub    $0xc,%esp
801063f4:	50                   	push   %eax
801063f5:	e8 aa bb ff ff       	call   80101fa4 <kfree>
801063fa:	83 c4 10             	add    $0x10,%esp
801063fd:	eb d6                	jmp    801063d5 <freevm+0x33>
    }
  }
  kfree((char*)pgdir);
801063ff:	83 ec 0c             	sub    $0xc,%esp
80106402:	56                   	push   %esi
80106403:	e8 9c bb ff ff       	call   80101fa4 <kfree>
}
80106408:	83 c4 10             	add    $0x10,%esp
8010640b:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010640e:	5b                   	pop    %ebx
8010640f:	5e                   	pop    %esi
80106410:	5d                   	pop    %ebp
80106411:	c3                   	ret    

80106412 <setupkvm>:
{
80106412:	55                   	push   %ebp
80106413:	89 e5                	mov    %esp,%ebp
80106415:	56                   	push   %esi
80106416:	53                   	push   %ebx
  if((pgdir = (pde_t*)kalloc()) == 0)
80106417:	e8 a9 bc ff ff       	call   801020c5 <kalloc>
8010641c:	89 c6                	mov    %eax,%esi
8010641e:	85 c0                	test   %eax,%eax
80106420:	74 55                	je     80106477 <setupkvm+0x65>
  memset(pgdir, 0, PGSIZE);
80106422:	83 ec 04             	sub    $0x4,%esp
80106425:	68 00 10 00 00       	push   $0x1000
8010642a:	6a 00                	push   $0x0
8010642c:	50                   	push   %eax
8010642d:	e8 d9 d9 ff ff       	call   80103e0b <memset>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106432:	83 c4 10             	add    $0x10,%esp
80106435:	bb 20 a4 10 80       	mov    $0x8010a420,%ebx
8010643a:	81 fb 60 a4 10 80    	cmp    $0x8010a460,%ebx
80106440:	73 35                	jae    80106477 <setupkvm+0x65>
                (uint)k->phys_start, k->perm) < 0) {
80106442:	8b 43 04             	mov    0x4(%ebx),%eax
    if(mappages(pgdir, k->virt, k->phys_end - k->phys_start,
80106445:	8b 4b 08             	mov    0x8(%ebx),%ecx
80106448:	29 c1                	sub    %eax,%ecx
8010644a:	83 ec 08             	sub    $0x8,%esp
8010644d:	ff 73 0c             	pushl  0xc(%ebx)
80106450:	50                   	push   %eax
80106451:	8b 13                	mov    (%ebx),%edx
80106453:	89 f0                	mov    %esi,%eax
80106455:	e8 d7 f9 ff ff       	call   80105e31 <mappages>
8010645a:	83 c4 10             	add    $0x10,%esp
8010645d:	85 c0                	test   %eax,%eax
8010645f:	78 05                	js     80106466 <setupkvm+0x54>
  for(k = kmap; k < &kmap[NELEM(kmap)]; k++)
80106461:	83 c3 10             	add    $0x10,%ebx
80106464:	eb d4                	jmp    8010643a <setupkvm+0x28>
      freevm(pgdir);
80106466:	83 ec 0c             	sub    $0xc,%esp
80106469:	56                   	push   %esi
8010646a:	e8 33 ff ff ff       	call   801063a2 <freevm>
      return 0;
8010646f:	83 c4 10             	add    $0x10,%esp
80106472:	be 00 00 00 00       	mov    $0x0,%esi
}
80106477:	89 f0                	mov    %esi,%eax
80106479:	8d 65 f8             	lea    -0x8(%ebp),%esp
8010647c:	5b                   	pop    %ebx
8010647d:	5e                   	pop    %esi
8010647e:	5d                   	pop    %ebp
8010647f:	c3                   	ret    

80106480 <kvmalloc>:
{
80106480:	55                   	push   %ebp
80106481:	89 e5                	mov    %esp,%ebp
80106483:	83 ec 08             	sub    $0x8,%esp
  kpgdir = setupkvm();
80106486:	e8 87 ff ff ff       	call   80106412 <setupkvm>
8010648b:	a3 e4 54 13 80       	mov    %eax,0x801354e4
  switchkvm();
80106490:	e8 5e fb ff ff       	call   80105ff3 <switchkvm>
}
80106495:	c9                   	leave  
80106496:	c3                   	ret    

80106497 <clearpteu>:

// Clear PTE_U on a page. Used to create an inaccessible
// page beneath the user stack.
void
clearpteu(pde_t *pgdir, char *uva)
{
80106497:	55                   	push   %ebp
80106498:	89 e5                	mov    %esp,%ebp
8010649a:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
8010649d:	b9 00 00 00 00       	mov    $0x0,%ecx
801064a2:	8b 55 0c             	mov    0xc(%ebp),%edx
801064a5:	8b 45 08             	mov    0x8(%ebp),%eax
801064a8:	e8 14 f9 ff ff       	call   80105dc1 <walkpgdir>
  if(pte == 0)
801064ad:	85 c0                	test   %eax,%eax
801064af:	74 05                	je     801064b6 <clearpteu+0x1f>
    panic("clearpteu");
  *pte &= ~PTE_U;
801064b1:	83 20 fb             	andl   $0xfffffffb,(%eax)
}
801064b4:	c9                   	leave  
801064b5:	c3                   	ret    
    panic("clearpteu");
801064b6:	83 ec 0c             	sub    $0xc,%esp
801064b9:	68 d2 70 10 80       	push   $0x801070d2
801064be:	e8 85 9e ff ff       	call   80100348 <panic>

801064c3 <copyuvm>:

// Given a parent process's page table, create a copy
// of it for a child.
pde_t*
copyuvm(pde_t *pgdir, uint sz)
{
801064c3:	55                   	push   %ebp
801064c4:	89 e5                	mov    %esp,%ebp
801064c6:	57                   	push   %edi
801064c7:	56                   	push   %esi
801064c8:	53                   	push   %ebx
801064c9:	83 ec 1c             	sub    $0x1c,%esp
  pde_t *d;
  pte_t *pte;
  uint pa, i, flags;
  char *mem;

  if((d = setupkvm()) == 0)
801064cc:	e8 41 ff ff ff       	call   80106412 <setupkvm>
801064d1:	89 45 dc             	mov    %eax,-0x24(%ebp)
801064d4:	85 c0                	test   %eax,%eax
801064d6:	0f 84 c4 00 00 00    	je     801065a0 <copyuvm+0xdd>
    return 0;
  for(i = 0; i < sz; i += PGSIZE){
801064dc:	bf 00 00 00 00       	mov    $0x0,%edi
801064e1:	3b 7d 0c             	cmp    0xc(%ebp),%edi
801064e4:	0f 83 b6 00 00 00    	jae    801065a0 <copyuvm+0xdd>
    if((pte = walkpgdir(pgdir, (void *) i, 0)) == 0)
801064ea:	89 7d e4             	mov    %edi,-0x1c(%ebp)
801064ed:	b9 00 00 00 00       	mov    $0x0,%ecx
801064f2:	89 fa                	mov    %edi,%edx
801064f4:	8b 45 08             	mov    0x8(%ebp),%eax
801064f7:	e8 c5 f8 ff ff       	call   80105dc1 <walkpgdir>
801064fc:	85 c0                	test   %eax,%eax
801064fe:	74 65                	je     80106565 <copyuvm+0xa2>
      panic("copyuvm: pte should exist");
    if(!(*pte & PTE_P))
80106500:	8b 00                	mov    (%eax),%eax
80106502:	a8 01                	test   $0x1,%al
80106504:	74 6c                	je     80106572 <copyuvm+0xaf>
      panic("copyuvm: page not present");
    pa = PTE_ADDR(*pte);
80106506:	89 c6                	mov    %eax,%esi
80106508:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    flags = PTE_FLAGS(*pte);
8010650e:	25 ff 0f 00 00       	and    $0xfff,%eax
80106513:	89 45 e0             	mov    %eax,-0x20(%ebp)
    if((mem = kalloc()) == 0)
80106516:	e8 aa bb ff ff       	call   801020c5 <kalloc>
8010651b:	89 c3                	mov    %eax,%ebx
8010651d:	85 c0                	test   %eax,%eax
8010651f:	74 6a                	je     8010658b <copyuvm+0xc8>
      goto bad;
    memmove(mem, (char*)P2V(pa), PGSIZE);
80106521:	81 c6 00 00 00 80    	add    $0x80000000,%esi
80106527:	83 ec 04             	sub    $0x4,%esp
8010652a:	68 00 10 00 00       	push   $0x1000
8010652f:	56                   	push   %esi
80106530:	50                   	push   %eax
80106531:	e8 50 d9 ff ff       	call   80103e86 <memmove>
    if(mappages(d, (void*)i, PGSIZE, V2P(mem), flags) < 0) {
80106536:	83 c4 08             	add    $0x8,%esp
80106539:	ff 75 e0             	pushl  -0x20(%ebp)
8010653c:	8d 83 00 00 00 80    	lea    -0x80000000(%ebx),%eax
80106542:	50                   	push   %eax
80106543:	b9 00 10 00 00       	mov    $0x1000,%ecx
80106548:	8b 55 e4             	mov    -0x1c(%ebp),%edx
8010654b:	8b 45 dc             	mov    -0x24(%ebp),%eax
8010654e:	e8 de f8 ff ff       	call   80105e31 <mappages>
80106553:	83 c4 10             	add    $0x10,%esp
80106556:	85 c0                	test   %eax,%eax
80106558:	78 25                	js     8010657f <copyuvm+0xbc>
  for(i = 0; i < sz; i += PGSIZE){
8010655a:	81 c7 00 10 00 00    	add    $0x1000,%edi
80106560:	e9 7c ff ff ff       	jmp    801064e1 <copyuvm+0x1e>
      panic("copyuvm: pte should exist");
80106565:	83 ec 0c             	sub    $0xc,%esp
80106568:	68 dc 70 10 80       	push   $0x801070dc
8010656d:	e8 d6 9d ff ff       	call   80100348 <panic>
      panic("copyuvm: page not present");
80106572:	83 ec 0c             	sub    $0xc,%esp
80106575:	68 f6 70 10 80       	push   $0x801070f6
8010657a:	e8 c9 9d ff ff       	call   80100348 <panic>
      kfree(mem);
8010657f:	83 ec 0c             	sub    $0xc,%esp
80106582:	53                   	push   %ebx
80106583:	e8 1c ba ff ff       	call   80101fa4 <kfree>
      goto bad;
80106588:	83 c4 10             	add    $0x10,%esp
    }
  }
  return d;

bad:
  freevm(d);
8010658b:	83 ec 0c             	sub    $0xc,%esp
8010658e:	ff 75 dc             	pushl  -0x24(%ebp)
80106591:	e8 0c fe ff ff       	call   801063a2 <freevm>
  return 0;
80106596:	83 c4 10             	add    $0x10,%esp
80106599:	c7 45 dc 00 00 00 00 	movl   $0x0,-0x24(%ebp)
}
801065a0:	8b 45 dc             	mov    -0x24(%ebp),%eax
801065a3:	8d 65 f4             	lea    -0xc(%ebp),%esp
801065a6:	5b                   	pop    %ebx
801065a7:	5e                   	pop    %esi
801065a8:	5f                   	pop    %edi
801065a9:	5d                   	pop    %ebp
801065aa:	c3                   	ret    

801065ab <uva2ka>:

// Map user virtual address to kernel address.
char*
uva2ka(pde_t *pgdir, char *uva)
{
801065ab:	55                   	push   %ebp
801065ac:	89 e5                	mov    %esp,%ebp
801065ae:	83 ec 08             	sub    $0x8,%esp
  pte_t *pte;

  pte = walkpgdir(pgdir, uva, 0);
801065b1:	b9 00 00 00 00       	mov    $0x0,%ecx
801065b6:	8b 55 0c             	mov    0xc(%ebp),%edx
801065b9:	8b 45 08             	mov    0x8(%ebp),%eax
801065bc:	e8 00 f8 ff ff       	call   80105dc1 <walkpgdir>
  if((*pte & PTE_P) == 0)
801065c1:	8b 00                	mov    (%eax),%eax
801065c3:	a8 01                	test   $0x1,%al
801065c5:	74 10                	je     801065d7 <uva2ka+0x2c>
    return 0;
  if((*pte & PTE_U) == 0)
801065c7:	a8 04                	test   $0x4,%al
801065c9:	74 13                	je     801065de <uva2ka+0x33>
    return 0;
  return (char*)P2V(PTE_ADDR(*pte));
801065cb:	25 00 f0 ff ff       	and    $0xfffff000,%eax
801065d0:	05 00 00 00 80       	add    $0x80000000,%eax
}
801065d5:	c9                   	leave  
801065d6:	c3                   	ret    
    return 0;
801065d7:	b8 00 00 00 00       	mov    $0x0,%eax
801065dc:	eb f7                	jmp    801065d5 <uva2ka+0x2a>
    return 0;
801065de:	b8 00 00 00 00       	mov    $0x0,%eax
801065e3:	eb f0                	jmp    801065d5 <uva2ka+0x2a>

801065e5 <copyout>:
// Copy len bytes from p to user address va in page table pgdir.
// Most useful when pgdir is not the current page table.
// uva2ka ensures this only works for PTE_U pages.
int
copyout(pde_t *pgdir, uint va, void *p, uint len)
{
801065e5:	55                   	push   %ebp
801065e6:	89 e5                	mov    %esp,%ebp
801065e8:	57                   	push   %edi
801065e9:	56                   	push   %esi
801065ea:	53                   	push   %ebx
801065eb:	83 ec 0c             	sub    $0xc,%esp
801065ee:	8b 7d 14             	mov    0x14(%ebp),%edi
  char *buf, *pa0;
  uint n, va0;

  buf = (char*)p;
  while(len > 0){
801065f1:	eb 25                	jmp    80106618 <copyout+0x33>
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (va - va0);
    if(n > len)
      n = len;
    memmove(pa0 + (va - va0), buf, n);
801065f3:	8b 55 0c             	mov    0xc(%ebp),%edx
801065f6:	29 f2                	sub    %esi,%edx
801065f8:	01 d0                	add    %edx,%eax
801065fa:	83 ec 04             	sub    $0x4,%esp
801065fd:	53                   	push   %ebx
801065fe:	ff 75 10             	pushl  0x10(%ebp)
80106601:	50                   	push   %eax
80106602:	e8 7f d8 ff ff       	call   80103e86 <memmove>
    len -= n;
80106607:	29 df                	sub    %ebx,%edi
    buf += n;
80106609:	01 5d 10             	add    %ebx,0x10(%ebp)
    va = va0 + PGSIZE;
8010660c:	8d 86 00 10 00 00    	lea    0x1000(%esi),%eax
80106612:	89 45 0c             	mov    %eax,0xc(%ebp)
80106615:	83 c4 10             	add    $0x10,%esp
  while(len > 0){
80106618:	85 ff                	test   %edi,%edi
8010661a:	74 2f                	je     8010664b <copyout+0x66>
    va0 = (uint)PGROUNDDOWN(va);
8010661c:	8b 75 0c             	mov    0xc(%ebp),%esi
8010661f:	81 e6 00 f0 ff ff    	and    $0xfffff000,%esi
    pa0 = uva2ka(pgdir, (char*)va0);
80106625:	83 ec 08             	sub    $0x8,%esp
80106628:	56                   	push   %esi
80106629:	ff 75 08             	pushl  0x8(%ebp)
8010662c:	e8 7a ff ff ff       	call   801065ab <uva2ka>
    if(pa0 == 0)
80106631:	83 c4 10             	add    $0x10,%esp
80106634:	85 c0                	test   %eax,%eax
80106636:	74 20                	je     80106658 <copyout+0x73>
    n = PGSIZE - (va - va0);
80106638:	89 f3                	mov    %esi,%ebx
8010663a:	2b 5d 0c             	sub    0xc(%ebp),%ebx
8010663d:	81 c3 00 10 00 00    	add    $0x1000,%ebx
    if(n > len)
80106643:	39 df                	cmp    %ebx,%edi
80106645:	73 ac                	jae    801065f3 <copyout+0xe>
      n = len;
80106647:	89 fb                	mov    %edi,%ebx
80106649:	eb a8                	jmp    801065f3 <copyout+0xe>
  }
  return 0;
8010664b:	b8 00 00 00 00       	mov    $0x0,%eax
}
80106650:	8d 65 f4             	lea    -0xc(%ebp),%esp
80106653:	5b                   	pop    %ebx
80106654:	5e                   	pop    %esi
80106655:	5f                   	pop    %edi
80106656:	5d                   	pop    %ebp
80106657:	c3                   	ret    
      return -1;
80106658:	b8 ff ff ff ff       	mov    $0xffffffff,%eax
8010665d:	eb f1                	jmp    80106650 <copyout+0x6b>
