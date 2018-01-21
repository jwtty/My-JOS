
obj/kern/kernel:     file format elf32-littlearm


Disassembly of section .text:

f0100000 <_start>:
// preserve these registers as argument for kernel
_start:
.globl entry
entry:
	// Clear out bss.
	ldr r4, = edata
f0100000:	e59f4054 	ldr	r4, [pc, #84]	; f010005c <halt+0x8>
	ldr r9, = end
f0100004:	e59f9054 	ldr	r9, [pc, #84]	; f0100060 <halt+0xc>
	mov r5, #0
f0100008:	e3a05000 	mov	r5, #0
	mov r6, #0
f010000c:	e3a06000 	mov	r6, #0
	mov r7, #0
f0100010:	e3a07000 	mov	r7, #0
	mov r8, #0
f0100014:	e3a08000 	mov	r8, #0
	b	check
f0100018:	ea000000 	b	f0100020 <check>

f010001c <zero>:
 
zero:
	// store multiple at r4.
	stmia r4!, {r5-r8}
f010001c:	e8a401e0 	stmia	r4!, {r5, r6, r7, r8}

f0100020 <check>:
 
	// If we are still below bss_end, loop.
check:
	cmp r4, r9
f0100020:	e1540009 	cmp	r4, r9
	blo zero
f0100024:	3afffffc 	bcc	f010001c <zero>
	
	// Turn on the MMU
	ldr r0, =(entry_pgdir - KERNBASE)
f0100028:	e59f0034 	ldr	r0, [pc, #52]	; f0100064 <halt+0x10>
	mcr p15, 0, r0, c2, c0, 0
f010002c:	ee020f10 	mcr	15, 0, r0, cr2, cr0, {0}

	mov r0, #0xFFFFFFFF
f0100030:	e3e00000 	mvn	r0, #0
	mcr p15, 0, r0, c3, c0, 0
f0100034:	ee030f10 	mcr	15, 0, r0, cr3, cr0, {0}

	mrc p15, 0, r0, c1, c0, 0
f0100038:	ee110f10 	mrc	15, 0, r0, cr1, cr0, {0}
	orr r0, r0, #0x1
f010003c:	e3800001 	orr	r0, r0, #1
	mcr p15, 0, r0, c1, c0, 0
f0100040:	ee010f10 	mcr	15, 0, r0, cr1, cr0, {0}
	
	//Jump up above KERNBASE before entering C code
	ldr lr, =relocated
f0100044:	e59fe01c 	ldr	lr, [pc, #28]	; f0100068 <halt+0x14>
	bx lr
f0100048:	e12fff1e 	bx	lr

f010004c <relocated>:

relocated:
	ldr sp, =bootstacktop  // Setup the stack.
f010004c:	e59fd018 	ldr	sp, [pc, #24]	; f010006c <halt+0x18>
	bl arm_init
f0100050:	eb000006 	bl	f0100070 <arm_init>

f0100054 <halt>:

	// halt
halt:
	wfe
f0100054:	e320f002 	wfe
	b halt
f0100058:	eafffffd 	b	f0100054 <halt>
f010005c:	f020c004 	.word	0xf020c004
f0100060:	f0298000 	.word	0xf0298000
f0100064:	00208000 	.word	0x00208000
f0100068:	f010004c 	.word	0xf010004c
f010006c:	f0208000 	.word	0xf0208000

f0100070 <arm_init>:
#include <kern/pmap.h>
#include <kern/monitor.h>
#include <kern/console.h>

void arm_init()
{
f0100070:	e92d4818 	push	{r3, r4, fp, lr}
f0100074:	e28db00c 	add	fp, sp, #12
    cons_init();
f0100078:	eb00006e 	bl	f0100238 <cons_init>
    cprintf("6828 decimal is %o octal!\n", 6828);
f010007c:	e59f001c 	ldr	r0, [pc, #28]	; f01000a0 <arm_init+0x30>
f0100080:	e08f0000 	add	r0, pc, r0
f0100084:	e59f1018 	ldr	r1, [pc, #24]	; f01000a4 <arm_init+0x34>
f0100088:	eb0001c5 	bl	f01007a4 <cprintf>

    mem_init();
f010008c:	eb000384 	bl	f0100ea4 <mem_init>

    while (1)
	monitor(NULL);
f0100090:	e3a04000 	mov	r4, #0
f0100094:	e1a00004 	mov	r0, r4
f0100098:	eb000139 	bl	f0100584 <monitor>
f010009c:	eafffffc 	b	f0100094 <arm_init+0x24>
f01000a0:	000044a0 	.word	0x000044a0
f01000a4:	00001aac 	.word	0x00001aac

f01000a8 <_panic>:
 * Panic is called on unresolvable fatal errors.
 * It prints "panic: mesg", and then enters the kernel monitor.
 */
    void
_panic(const char *file, int line, const char *fmt,...)
{
f01000a8:	e92d000c 	push	{r2, r3}
f01000ac:	e92d4800 	push	{fp, lr}
f01000b0:	e28db004 	add	fp, sp, #4
f01000b4:	e24dd008 	sub	sp, sp, #8
f01000b8:	e1a02001 	mov	r2, r1
f01000bc:	e59b4004 	ldr	r4, [fp, #4]
f01000c0:	e59f3064 	ldr	r3, [pc, #100]	; f010012c <_panic+0x84>
f01000c4:	e08f3003 	add	r3, pc, r3
    va_list ap;

    if (panicstr)
f01000c8:	e59f1060 	ldr	r1, [pc, #96]	; f0100130 <_panic+0x88>
f01000cc:	e7931001 	ldr	r1, [r3, r1]
f01000d0:	e5911000 	ldr	r1, [r1]
f01000d4:	e3510000 	cmp	r1, #0
f01000d8:	1a00000f 	bne	f010011c <_panic+0x74>
f01000dc:	e1a0c000 	mov	ip, r0
	goto dead;
    panicstr = fmt;
f01000e0:	e59f1048 	ldr	r1, [pc, #72]	; f0100130 <_panic+0x88>
f01000e4:	e7933001 	ldr	r3, [r3, r1]
f01000e8:	e5834000 	str	r4, [r3]

    // Be extra sure that the machine is in as reasonable state
    // __asm __volatile("cli; cld");

    va_start(ap, fmt);
f01000ec:	e28b3008 	add	r3, fp, #8
f01000f0:	e50b3008 	str	r3, [fp, #-8]
    cprintf("kernel panic on CPU at %s:%d: ", file, line);
f01000f4:	e59f0038 	ldr	r0, [pc, #56]	; f0100134 <_panic+0x8c>
f01000f8:	e08f0000 	add	r0, pc, r0
f01000fc:	e1a0100c 	mov	r1, ip
f0100100:	eb0001a7 	bl	f01007a4 <cprintf>
    vcprintf(fmt, ap);
f0100104:	e1a00004 	mov	r0, r4
f0100108:	e51b1008 	ldr	r1, [fp, #-8]
f010010c:	eb000195 	bl	f0100768 <vcprintf>
    cprintf("\n");
f0100110:	e59f0020 	ldr	r0, [pc, #32]	; f0100138 <_panic+0x90>
f0100114:	e08f0000 	add	r0, pc, r0
f0100118:	eb0001a1 	bl	f01007a4 <cprintf>
    va_end(ap);

dead:
    /* break into the kernel monitor */
    while (1)
	monitor(NULL);
f010011c:	e3a04000 	mov	r4, #0
f0100120:	e1a00004 	mov	r0, r4
f0100124:	eb000116 	bl	f0100584 <monitor>
f0100128:	eafffffc 	b	f0100120 <_panic+0x78>
f010012c:	0010bf38 	.word	0x0010bf38
f0100130:	00000010 	.word	0x00000010
f0100134:	00004444 	.word	0x00004444
f0100138:	000046d8 	.word	0x000046d8

f010013c <raise>:
}

void raise() {for(;;);}
f010013c:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0100140:	e28db000 	add	fp, sp, #0
f0100144:	eafffffe 	b	f0100144 <raise+0x8>

f0100148 <uart_proc_data>:
};


static 
int uart_proc_data()
{
f0100148:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f010014c:	e28db000 	add	fp, sp, #0
	*(volatile uint32_t *)reg = data;
}
 
static inline uint32_t mmio_read(uint32_t reg)
{
	return *(volatile uint32_t *)reg;
f0100150:	e59f301c 	ldr	r3, [pc, #28]	; f0100174 <uart_proc_data+0x2c>
f0100154:	e5133fe7 	ldr	r3, [r3, #-4071]	; 0xfffff019


static 
int uart_proc_data()
{
    if (mmio_read(UART0_FR) & (1 << 4))
f0100158:	e3130010 	tst	r3, #16
	*(volatile uint32_t *)reg = data;
}
 
static inline uint32_t mmio_read(uint32_t reg)
{
	return *(volatile uint32_t *)reg;
f010015c:	059f3010 	ldreq	r3, [pc, #16]	; f0100174 <uart_proc_data+0x2c>
f0100160:	05130fff 	ldreq	r0, [r3, #-4095]	; 0xfffff001

static 
int uart_proc_data()
{
    if (mmio_read(UART0_FR) & (1 << 4))
    	return -1;
f0100164:	13e00000 	mvnne	r0, #0
    return mmio_read(UART0_DR);
}
f0100168:	e24bd000 	sub	sp, fp, #0
f010016c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0100170:	e12fff1e 	bx	lr
f0100174:	efd01fff 	.word	0xefd01fff

f0100178 <uart_intr>:

void
uart_intr(void)
{
f0100178:	e92d4878 	push	{r3, r4, r5, r6, fp, lr}
f010017c:	e28db014 	add	fp, sp, #20
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
			continue;
		cons.buf[cons.wpos++] = c;
f0100180:	e59f4040 	ldr	r4, [pc, #64]	; f01001c8 <uart_intr+0x50>
f0100184:	e08f4004 	add	r4, pc, r4
		if (cons.wpos == CONSBUFSIZE)
			cons.wpos = 0;
f0100188:	e59f603c 	ldr	r6, [pc, #60]	; f01001cc <uart_intr+0x54>
f010018c:	e08f6006 	add	r6, pc, r6
f0100190:	e3a05000 	mov	r5, #0
f0100194:	ea000007 	b	f01001b8 <uart_intr+0x40>
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
		if (c == 0)
f0100198:	e3500000 	cmp	r0, #0
f010019c:	0a000005 	beq	f01001b8 <uart_intr+0x40>
			continue;
		cons.buf[cons.wpos++] = c;
f01001a0:	e5942204 	ldr	r2, [r4, #516]	; 0x204
f01001a4:	e2823001 	add	r3, r2, #1
f01001a8:	e5843204 	str	r3, [r4, #516]	; 0x204
f01001ac:	e7c40002 	strb	r0, [r4, r2]
		if (cons.wpos == CONSBUFSIZE)
f01001b0:	e3530c02 	cmp	r3, #512	; 0x200
			cons.wpos = 0;
f01001b4:	05865204 	streq	r5, [r6, #516]	; 0x204
static void
cons_intr(int (*proc)(void))
{
	int c;

	while ((c = (*proc)()) != -1) {
f01001b8:	ebffffe2 	bl	f0100148 <uart_proc_data>
f01001bc:	e3700001 	cmn	r0, #1
f01001c0:	1afffff4 	bne	f0100198 <uart_intr+0x20>

void
uart_intr(void)
{
	cons_intr(uart_proc_data);
}
f01001c4:	e8bd8878 	pop	{r3, r4, r5, r6, fp, pc}
f01001c8:	0010fe74 	.word	0x0010fe74
f01001cc:	0010fe6c 	.word	0x0010fe6c

f01001d0 <cons_getc>:
}

// return the next input character from the console, or 0 if none waiting
int
cons_getc(void)
{
f01001d0:	e92d4800 	push	{fp, lr}
f01001d4:	e28db004 	add	fp, sp, #4
	unsigned char c;

	// poll for any pending input characters,
	// so that this function works even when interrupts are disabled
	// (e.g., when called from the kernel monitor).
	uart_intr();
f01001d8:	ebffffe6 	bl	f0100178 <uart_intr>

	// grab the next character from the input buffer.
	if (cons.rpos != cons.wpos) {
f01001dc:	e59f2048 	ldr	r2, [pc, #72]	; f010022c <cons_getc+0x5c>
f01001e0:	e08f2002 	add	r2, pc, r2
f01001e4:	e5923200 	ldr	r3, [r2, #512]	; 0x200
f01001e8:	e5922204 	ldr	r2, [r2, #516]	; 0x204
f01001ec:	e1530002 	cmp	r3, r2
f01001f0:	0a00000b 	beq	f0100224 <cons_getc+0x54>
		c = cons.buf[cons.rpos++];
f01001f4:	e2832001 	add	r2, r3, #1
f01001f8:	e59f1030 	ldr	r1, [pc, #48]	; f0100230 <cons_getc+0x60>
f01001fc:	e08f1001 	add	r1, pc, r1
f0100200:	e5812200 	str	r2, [r1, #512]	; 0x200
f0100204:	e7d10003 	ldrb	r0, [r1, r3]
		if (cons.rpos == CONSBUFSIZE)
f0100208:	e3520c02 	cmp	r2, #512	; 0x200
f010020c:	18bd8800 	popne	{fp, pc}
			cons.rpos = 0;
f0100210:	e3a02000 	mov	r2, #0
f0100214:	e59f3018 	ldr	r3, [pc, #24]	; f0100234 <cons_getc+0x64>
f0100218:	e08f3003 	add	r3, pc, r3
f010021c:	e5832200 	str	r2, [r3, #512]	; 0x200
		return c;
f0100220:	e8bd8800 	pop	{fp, pc}
	}
	return 0;
f0100224:	e3a00000 	mov	r0, #0
}
f0100228:	e8bd8800 	pop	{fp, pc}
f010022c:	0010fe18 	.word	0x0010fe18
f0100230:	0010fdfc 	.word	0x0010fdfc
f0100234:	0010fde0 	.word	0x0010fde0

f0100238 <cons_init>:
}

// initialize the console devices
void
cons_init(void)
{
f0100238:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f010023c:	e28db000 	add	fp, sp, #0
static void cons_intr(int (*proc)(void));
static void cons_putc(int c);

static inline void mmio_write(uint32_t reg, uint32_t data)
{
	*(volatile uint32_t *)reg = data;
f0100240:	e59f3054 	ldr	r3, [pc, #84]	; f010029c <cons_init+0x64>
f0100244:	e3a01000 	mov	r1, #0
f0100248:	e5031fcf 	str	r1, [r3, #-4047]	; 0xfffff031
f010024c:	e59f204c 	ldr	r2, [pc, #76]	; f01002a0 <cons_init+0x68>
f0100250:	e5821094 	str	r1, [r2, #148]	; 0x94
f0100254:	e3a00903 	mov	r0, #49152	; 0xc000
f0100258:	e5820098 	str	r0, [r2, #152]	; 0x98
f010025c:	e5821098 	str	r1, [r2, #152]	; 0x98
f0100260:	e59f203c 	ldr	r2, [pc, #60]	; f01002a4 <cons_init+0x6c>
f0100264:	e5032fbb 	str	r2, [r3, #-4027]	; 0xfffff045
f0100268:	e3a02001 	mov	r2, #1
f010026c:	e5032fdb 	str	r2, [r3, #-4059]	; 0xfffff025
f0100270:	e3a02028 	mov	r2, #40	; 0x28
f0100274:	e5032fd7 	str	r2, [r3, #-4055]	; 0xfffff029
f0100278:	e3a02070 	mov	r2, #112	; 0x70
f010027c:	e5032fd3 	str	r2, [r3, #-4051]	; 0xfffff02d
f0100280:	e59f2020 	ldr	r2, [pc, #32]	; f01002a8 <cons_init+0x70>
f0100284:	e5032fc7 	str	r2, [r3, #-4039]	; 0xfffff039
f0100288:	e59f201c 	ldr	r2, [pc, #28]	; f01002ac <cons_init+0x74>
f010028c:	e5032fcf 	str	r2, [r3, #-4047]	; 0xfffff031
// initialize the console devices
void
cons_init(void)
{
	uart_init();
}
f0100290:	e24bd000 	sub	sp, fp, #0
f0100294:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0100298:	e12fff1e 	bx	lr
f010029c:	efd01fff 	.word	0xefd01fff
f01002a0:	efd00000 	.word	0xefd00000
f01002a4:	000007ff 	.word	0x000007ff
f01002a8:	000007f2 	.word	0x000007f2
f01002ac:	00000301 	.word	0x00000301

f01002b0 <cputchar>:

// `High'-level console I/O.  Used by readline and cprintf.

void
cputchar(int c)
{
f01002b0:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f01002b4:	e28db000 	add	fp, sp, #0
	*(volatile uint32_t *)reg = data;
}
 
static inline uint32_t mmio_read(uint32_t reg)
{
	return *(volatile uint32_t *)reg;
f01002b8:	e59f2020 	ldr	r2, [pc, #32]	; f01002e0 <cputchar+0x30>
f01002bc:	e5123fe7 	ldr	r3, [r2, #-4071]	; 0xfffff019

static void
uart_putc(unsigned char byte)
{
	// Wait for UART to become ready to transmit.
	while ( mmio_read(UART0_FR) & (1 << 5) ) { }
f01002c0:	e3130020 	tst	r3, #32
f01002c4:	1afffffc 	bne	f01002bc <cputchar+0xc>
f01002c8:	e6ef0070 	uxtb	r0, r0
static void cons_intr(int (*proc)(void));
static void cons_putc(int c);

static inline void mmio_write(uint32_t reg, uint32_t data)
{
	*(volatile uint32_t *)reg = data;
f01002cc:	e59f300c 	ldr	r3, [pc, #12]	; f01002e0 <cputchar+0x30>
f01002d0:	e5030fff 	str	r0, [r3, #-4095]	; 0xfffff001

void
cputchar(int c)
{
	cons_putc(c);
}
f01002d4:	e24bd000 	sub	sp, fp, #0
f01002d8:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f01002dc:	e12fff1e 	bx	lr
f01002e0:	efd01fff 	.word	0xefd01fff

f01002e4 <getchar>:

int
getchar(void)
{
f01002e4:	e92d4800 	push	{fp, lr}
f01002e8:	e28db004 	add	fp, sp, #4
	int c;

	while ((c = cons_getc()) == 0)
f01002ec:	ebffffb7 	bl	f01001d0 <cons_getc>
f01002f0:	e3500000 	cmp	r0, #0
f01002f4:	0afffffc 	beq	f01002ec <getchar+0x8>
		/* do nothing */;
	return c;
}
f01002f8:	e8bd8800 	pop	{fp, pc}

f01002fc <iscons>:

int
iscons(int fdnum)
{
f01002fc:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0100300:	e28db000 	add	fp, sp, #0
	// used by readline
	return 1;
}
f0100304:	e3a00001 	mov	r0, #1
f0100308:	e24bd000 	sub	sp, fp, #0
f010030c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0100310:	e12fff1e 	bx	lr

f0100314 <mon_help>:

/***** Implementations of basic kernel monitor commands *****/

int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
f0100314:	e92d4818 	push	{r3, r4, fp, lr}
f0100318:	e28db00c 	add	fp, sp, #12
	int i;

	for (i = 0; i < NCOMMANDS; i++)
		cprintf("%s - %s\n", commands[i].name, commands[i].desc);
f010031c:	e59f4050 	ldr	r4, [pc, #80]	; f0100374 <mon_help+0x60>
f0100320:	e08f4004 	add	r4, pc, r4
f0100324:	e1a00004 	mov	r0, r4
f0100328:	e59f1048 	ldr	r1, [pc, #72]	; f0100378 <mon_help+0x64>
f010032c:	e08f1001 	add	r1, pc, r1
f0100330:	e59f2044 	ldr	r2, [pc, #68]	; f010037c <mon_help+0x68>
f0100334:	e08f2002 	add	r2, pc, r2
f0100338:	eb000119 	bl	f01007a4 <cprintf>
f010033c:	e1a00004 	mov	r0, r4
f0100340:	e59f1038 	ldr	r1, [pc, #56]	; f0100380 <mon_help+0x6c>
f0100344:	e08f1001 	add	r1, pc, r1
f0100348:	e59f2034 	ldr	r2, [pc, #52]	; f0100384 <mon_help+0x70>
f010034c:	e08f2002 	add	r2, pc, r2
f0100350:	eb000113 	bl	f01007a4 <cprintf>
f0100354:	e1a00004 	mov	r0, r4
f0100358:	e59f1028 	ldr	r1, [pc, #40]	; f0100388 <mon_help+0x74>
f010035c:	e08f1001 	add	r1, pc, r1
f0100360:	e59f2024 	ldr	r2, [pc, #36]	; f010038c <mon_help+0x78>
f0100364:	e08f2002 	add	r2, pc, r2
f0100368:	eb00010d 	bl	f01007a4 <cprintf>
	return 0;
}
f010036c:	e3a00000 	mov	r0, #0
f0100370:	e8bd8818 	pop	{r3, r4, fp, pc}
f0100374:	0000423c 	.word	0x0000423c
f0100378:	0000423c 	.word	0x0000423c
f010037c:	0000423c 	.word	0x0000423c
f0100380:	0000424c 	.word	0x0000424c
f0100384:	00004250 	.word	0x00004250
f0100388:	00004268 	.word	0x00004268
f010038c:	0000426c 	.word	0x0000426c

f0100390 <mon_kerninfo>:

int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
f0100390:	e92d4870 	push	{r4, r5, r6, fp, lr}
f0100394:	e28db010 	add	fp, sp, #16
f0100398:	e24dd00c 	sub	sp, sp, #12
f010039c:	e59f50d4 	ldr	r5, [pc, #212]	; f0100478 <mon_kerninfo+0xe8>
f01003a0:	e08f5005 	add	r5, pc, r5
	extern char start[], entry[], etext[], edata[],end[];
	//unsigned int BASE = 0x8000;
	cprintf("Special kernel symbols:\n");
f01003a4:	e59f00d0 	ldr	r0, [pc, #208]	; f010047c <mon_kerninfo+0xec>
f01003a8:	e08f0000 	add	r0, pc, r0
f01003ac:	eb0000fc 	bl	f01007a4 <cprintf>
	cprintf("  _start                  %08x (phys)\n", start);
f01003b0:	e59f30c8 	ldr	r3, [pc, #200]	; f0100480 <mon_kerninfo+0xf0>
f01003b4:	e7953003 	ldr	r3, [r5, r3]
f01003b8:	e50b3018 	str	r3, [fp, #-24]	; 0xffffffe8
f01003bc:	e59f00c0 	ldr	r0, [pc, #192]	; f0100484 <mon_kerninfo+0xf4>
f01003c0:	e08f0000 	add	r0, pc, r0
f01003c4:	e1a01003 	mov	r1, r3
f01003c8:	eb0000f5 	bl	f01007a4 <cprintf>
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
f01003cc:	e59f30b4 	ldr	r3, [pc, #180]	; f0100488 <mon_kerninfo+0xf8>
f01003d0:	e7956003 	ldr	r6, [r5, r3]
f01003d4:	e59f00b0 	ldr	r0, [pc, #176]	; f010048c <mon_kerninfo+0xfc>
f01003d8:	e08f0000 	add	r0, pc, r0
f01003dc:	e1a01006 	mov	r1, r6
f01003e0:	e2862201 	add	r2, r6, #268435456	; 0x10000000
f01003e4:	eb0000ee 	bl	f01007a4 <cprintf>
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
f01003e8:	e59f30a0 	ldr	r3, [pc, #160]	; f0100490 <mon_kerninfo+0x100>
f01003ec:	e7952003 	ldr	r2, [r5, r3]
f01003f0:	e59f009c 	ldr	r0, [pc, #156]	; f0100494 <mon_kerninfo+0x104>
f01003f4:	e08f0000 	add	r0, pc, r0
f01003f8:	e1a01002 	mov	r1, r2
f01003fc:	e2822201 	add	r2, r2, #268435456	; 0x10000000
f0100400:	eb0000e7 	bl	f01007a4 <cprintf>
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
f0100404:	e59f308c 	ldr	r3, [pc, #140]	; f0100498 <mon_kerninfo+0x108>
f0100408:	e7952003 	ldr	r2, [r5, r3]
f010040c:	e59f0088 	ldr	r0, [pc, #136]	; f010049c <mon_kerninfo+0x10c>
f0100410:	e08f0000 	add	r0, pc, r0
f0100414:	e1a01002 	mov	r1, r2
f0100418:	e2822201 	add	r2, r2, #268435456	; 0x10000000
f010041c:	eb0000e0 	bl	f01007a4 <cprintf>
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
f0100420:	e59f3078 	ldr	r3, [pc, #120]	; f01004a0 <mon_kerninfo+0x110>
f0100424:	e7954003 	ldr	r4, [r5, r3]
f0100428:	e59f0074 	ldr	r0, [pc, #116]	; f01004a4 <mon_kerninfo+0x114>
f010042c:	e08f0000 	add	r0, pc, r0
f0100430:	e1a01004 	mov	r1, r4
f0100434:	e2842201 	add	r2, r4, #268435456	; 0x10000000
f0100438:	eb0000d9 	bl	f01007a4 <cprintf>
f010043c:	e2841fff 	add	r1, r4, #1020	; 0x3fc
f0100440:	e2811003 	add	r1, r1, #3
	cprintf("Kernel executable memory footprint: %dKB\n",
		ROUNDUP(end - entry, 1024) / 1024);
f0100444:	e0661001 	rsb	r1, r6, r1
f0100448:	e1a04b01 	lsl	r4, r1, #22
f010044c:	e0411b24 	sub	r1, r1, r4, lsr #22
	cprintf("  _start                  %08x (phys)\n", start);
	cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
	cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
	cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
	cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
	cprintf("Kernel executable memory footprint: %dKB\n",
f0100450:	e2813fff 	add	r3, r1, #1020	; 0x3fc
f0100454:	e3510000 	cmp	r1, #0
f0100458:	b2831003 	addlt	r1, r3, #3
f010045c:	e59f0044 	ldr	r0, [pc, #68]	; f01004a8 <mon_kerninfo+0x118>
f0100460:	e08f0000 	add	r0, pc, r0
f0100464:	e1a01541 	asr	r1, r1, #10
f0100468:	eb0000cd 	bl	f01007a4 <cprintf>
		ROUNDUP(end - entry, 1024) / 1024);
	return 0;
}
f010046c:	e3a00000 	mov	r0, #0
f0100470:	e24bd010 	sub	sp, fp, #16
f0100474:	e8bd8870 	pop	{r4, r5, r6, fp, pc}
f0100478:	0010bc5c 	.word	0x0010bc5c
f010047c:	0000424c 	.word	0x0000424c
f0100480:	00000024 	.word	0x00000024
f0100484:	00004250 	.word	0x00004250
f0100488:	00000000 	.word	0x00000000
f010048c:	00004260 	.word	0x00004260
f0100490:	00000018 	.word	0x00000018
f0100494:	00004268 	.word	0x00004268
f0100498:	00000004 	.word	0x00000004
f010049c:	00004270 	.word	0x00004270
f01004a0:	00000014 	.word	0x00000014
f01004a4:	00004278 	.word	0x00004278
f01004a8:	00004268 	.word	0x00004268

f01004ac <mon_backtrace>:

int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
f01004ac:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
f01004b0:	e28db020 	add	fp, sp, #32
f01004b4:	e24dd024 	sub	sp, sp, #36	; 0x24
}

static inline uint32_t read_r11(void)
{
	uint32_t r11;
	asm volatile("mov %0, r11" : "=r" (r11));
f01004b8:	e1a0400b 	mov	r4, fp
	uint32_t tmp_ebp = read_r11(), tmp_eip;
	int debuginfo_ret, i;
	struct Eipdebuginfo info;

	cprintf("Stack backtrace:\n");
f01004bc:	e59f00ac 	ldr	r0, [pc, #172]	; f0100570 <mon_backtrace+0xc4>
f01004c0:	e08f0000 	add	r0, pc, r0
f01004c4:	eb0000b6 	bl	f01007a4 <cprintf>

	// in arm, r11 points to ret addr, and old r11 is just below ret addr

	while (tmp_ebp != 0x0) {
f01004c8:	e3540000 	cmp	r4, #0
f01004cc:	0a000024 	beq	f0100564 <mon_backtrace+0xb8>
		// ret addr stays just above ebp
		tmp_eip = *((uint32_t*)tmp_ebp);
		cprintf("  ebp %08x", tmp_ebp);
f01004d0:	e59f809c 	ldr	r8, [pc, #156]	; f0100574 <mon_backtrace+0xc8>
f01004d4:	e08f8008 	add	r8, pc, r8
		cprintf("  eip %08x", tmp_eip);
f01004d8:	e59f7098 	ldr	r7, [pc, #152]	; f0100578 <mon_backtrace+0xcc>
f01004dc:	e08f7007 	add	r7, pc, r7
		
		// find the debuginfo of the instruction which ret addr indicates
		// and check whether the debug info is valid
		if (debuginfo_eip(tmp_eip, &info) == 0) {
f01004e0:	e24b603c 	sub	r6, fp, #60	; 0x3c
			cprintf("         %s:%d: %.*s+%d\n", 
f01004e4:	e59fa090 	ldr	sl, [pc, #144]	; f010057c <mon_backtrace+0xd0>
f01004e8:	e08fa00a 	add	sl, pc, sl
					info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					(int)tmp_eip - (int)info.eip_fn_addr);
		}
		else {
			cprintf("         debuginfo not available\n");
f01004ec:	e59f908c 	ldr	r9, [pc, #140]	; f0100580 <mon_backtrace+0xd4>
f01004f0:	e08f9009 	add	r9, pc, r9

	// in arm, r11 points to ret addr, and old r11 is just below ret addr

	while (tmp_ebp != 0x0) {
		// ret addr stays just above ebp
		tmp_eip = *((uint32_t*)tmp_ebp);
f01004f4:	e5945000 	ldr	r5, [r4]
		cprintf("  ebp %08x", tmp_ebp);
f01004f8:	e1a00008 	mov	r0, r8
f01004fc:	e1a01004 	mov	r1, r4
f0100500:	eb0000a7 	bl	f01007a4 <cprintf>
		cprintf("  eip %08x", tmp_eip);
f0100504:	e1a00007 	mov	r0, r7
f0100508:	e1a01005 	mov	r1, r5
f010050c:	eb0000a4 	bl	f01007a4 <cprintf>
		
		// find the debuginfo of the instruction which ret addr indicates
		// and check whether the debug info is valid
		if (debuginfo_eip(tmp_eip, &info) == 0) {
f0100510:	e1a00005 	mov	r0, r5
f0100514:	e1a01006 	mov	r1, r6
f0100518:	eb000abc 	bl	f0103010 <debuginfo_eip>
f010051c:	e3500000 	cmp	r0, #0
f0100520:	1a00000a 	bne	f0100550 <mon_backtrace+0xa4>
			cprintf("         %s:%d: %.*s+%d\n", 
f0100524:	e51b3034 	ldr	r3, [fp, #-52]	; 0xffffffcc
f0100528:	e58d3000 	str	r3, [sp]
f010052c:	e51b302c 	ldr	r3, [fp, #-44]	; 0xffffffd4
f0100530:	e0635005 	rsb	r5, r3, r5
f0100534:	e58d5004 	str	r5, [sp, #4]
f0100538:	e1a0000a 	mov	r0, sl
f010053c:	e51b103c 	ldr	r1, [fp, #-60]	; 0xffffffc4
f0100540:	e51b2038 	ldr	r2, [fp, #-56]	; 0xffffffc8
f0100544:	e51b3030 	ldr	r3, [fp, #-48]	; 0xffffffd0
f0100548:	eb000095 	bl	f01007a4 <cprintf>
f010054c:	ea000001 	b	f0100558 <mon_backtrace+0xac>
					info.eip_line,
					info.eip_fn_namelen, info.eip_fn_name,
					(int)tmp_eip - (int)info.eip_fn_addr);
		}
		else {
			cprintf("         debuginfo not available\n");
f0100550:	e1a00009 	mov	r0, r9
f0100554:	eb000092 	bl	f01007a4 <cprintf>
		}

		// update tmp_ebp
		tmp_ebp = *((uint32_t*)tmp_ebp - 1);
f0100558:	e5144004 	ldr	r4, [r4, #-4]

	cprintf("Stack backtrace:\n");

	// in arm, r11 points to ret addr, and old r11 is just below ret addr

	while (tmp_ebp != 0x0) {
f010055c:	e3540000 	cmp	r4, #0
f0100560:	1affffe3 	bne	f01004f4 <mon_backtrace+0x48>

		// update tmp_ebp
		tmp_ebp = *((uint32_t*)tmp_ebp - 1);
	}
	return 0;
}
f0100564:	e3a00000 	mov	r0, #0
f0100568:	e24bd020 	sub	sp, fp, #32
f010056c:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
f0100570:	00004234 	.word	0x00004234
f0100574:	00004234 	.word	0x00004234
f0100578:	00004238 	.word	0x00004238
f010057c:	00004238 	.word	0x00004238
f0100580:	0000424c 	.word	0x0000424c

f0100584 <monitor>:
	return 0;
}

void
monitor(struct Trapframe *tf)
{
f0100584:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
f0100588:	e28db020 	add	fp, sp, #32
f010058c:	e24dd054 	sub	sp, sp, #84	; 0x54
f0100590:	e50b0070 	str	r0, [fp, #-112]	; 0xffffff90
	char *buf;

	cprintf("Welcome to the JOS kernel monitor!\n");
f0100594:	e59f0188 	ldr	r0, [pc, #392]	; f0100724 <monitor+0x1a0>
f0100598:	e08f0000 	add	r0, pc, r0
f010059c:	eb000080 	bl	f01007a4 <cprintf>
	cprintf("Type 'help' for a list of commands.\n");
f01005a0:	e59f0180 	ldr	r0, [pc, #384]	; f0100728 <monitor+0x1a4>
f01005a4:	e08f0000 	add	r0, pc, r0
f01005a8:	eb00007d 	bl	f01007a4 <cprintf>


	while (1) {
		buf = readline("K> ");
f01005ac:	e59f8178 	ldr	r8, [pc, #376]	; f010072c <monitor+0x1a8>
f01005b0:	e08f8008 	add	r8, pc, r8
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f01005b4:	e59f3174 	ldr	r3, [pc, #372]	; f0100730 <monitor+0x1ac>
f01005b8:	e08f3003 	add	r3, pc, r3
f01005bc:	e50b3068 	str	r3, [fp, #-104]	; 0xffffff98
		if (argc == MAXARGS-1) {
			cprintf("Too many arguments (max %d)\n", MAXARGS);
			return 0;
		}
		argv[argc++] = buf;
		while (*buf && !strchr(WHITESPACE, *buf))
f01005c0:	e59f516c 	ldr	r5, [pc, #364]	; f0100734 <monitor+0x1b0>
f01005c4:	e08f5005 	add	r5, pc, r5

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01005c8:	e59fa168 	ldr	sl, [pc, #360]	; f0100738 <monitor+0x1b4>
f01005cc:	e08fa00a 	add	sl, pc, sl
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f01005d0:	e59f3164 	ldr	r3, [pc, #356]	; f010073c <monitor+0x1b8>
f01005d4:	e08f3003 	add	r3, pc, r3
f01005d8:	e50b306c 	str	r3, [fp, #-108]	; 0xffffff94
	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
f01005dc:	e59f315c 	ldr	r3, [pc, #348]	; f0100740 <monitor+0x1bc>
f01005e0:	e08f3003 	add	r3, pc, r3
f01005e4:	e50b3074 	str	r3, [fp, #-116]	; 0xffffff8c
	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
f01005e8:	e1a00008 	mov	r0, r8
f01005ec:	eb000d2f 	bl	f0103ab0 <readline>
		if (buf != NULL)
f01005f0:	e2504000 	subs	r4, r0, #0
	char *argv[MAXARGS];
	int i;

	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
f01005f4:	13a06000 	movne	r6, #0
f01005f8:	150b6064 	strne	r6, [fp, #-100]	; 0xffffff9c
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f01005fc:	11a09006 	movne	r9, r6
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
f0100600:	1a000001 	bne	f010060c <monitor+0x88>
f0100604:	eafffff7 	b	f01005e8 <monitor+0x64>
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
			*buf++ = 0;
f0100608:	e1a06007 	mov	r6, r7
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f010060c:	e5d41000 	ldrb	r1, [r4]
f0100610:	e3510000 	cmp	r1, #0
f0100614:	0a000020 	beq	f010069c <monitor+0x118>
f0100618:	e51b0068 	ldr	r0, [fp, #-104]	; 0xffffff98
f010061c:	eb000e0c 	bl	f0103e54 <strchr>
f0100620:	e3500000 	cmp	r0, #0
			*buf++ = 0;
f0100624:	15c49000 	strbne	r9, [r4]
f0100628:	11a07006 	movne	r7, r6
f010062c:	12844001 	addne	r4, r4, #1
	// Parse the command buffer into whitespace-separated arguments
	argc = 0;
	argv[argc] = 0;
	while (1) {
		// gobble whitespace
		while (*buf && strchr(WHITESPACE, *buf))
f0100630:	1afffff4 	bne	f0100608 <monitor+0x84>
			*buf++ = 0;
		if (*buf == 0)
f0100634:	e5d43000 	ldrb	r3, [r4]
f0100638:	e3530000 	cmp	r3, #0
f010063c:	0a000016 	beq	f010069c <monitor+0x118>
			break;

		// save and scan past next arg
		if (argc == MAXARGS-1) {
f0100640:	e356000f 	cmp	r6, #15
f0100644:	1a000004 	bne	f010065c <monitor+0xd8>
			cprintf("Too many arguments (max %d)\n", MAXARGS);
f0100648:	e59f00f4 	ldr	r0, [pc, #244]	; f0100744 <monitor+0x1c0>
f010064c:	e08f0000 	add	r0, pc, r0
f0100650:	e3a01010 	mov	r1, #16
f0100654:	eb000052 	bl	f01007a4 <cprintf>
f0100658:	eaffffe2 	b	f01005e8 <monitor+0x64>
			return 0;
		}
		argv[argc++] = buf;
f010065c:	e2867001 	add	r7, r6, #1
f0100660:	e24b3024 	sub	r3, fp, #36	; 0x24
f0100664:	e0836106 	add	r6, r3, r6, lsl #2
f0100668:	e5064040 	str	r4, [r6, #-64]	; 0xffffffc0
		while (*buf && !strchr(WHITESPACE, *buf))
f010066c:	e5d41000 	ldrb	r1, [r4]
f0100670:	e3510000 	cmp	r1, #0
f0100674:	1a000003 	bne	f0100688 <monitor+0x104>
f0100678:	eaffffe2 	b	f0100608 <monitor+0x84>
f010067c:	e5f41001 	ldrb	r1, [r4, #1]!
f0100680:	e3510000 	cmp	r1, #0
f0100684:	0affffdf 	beq	f0100608 <monitor+0x84>
f0100688:	e1a00005 	mov	r0, r5
f010068c:	eb000df0 	bl	f0103e54 <strchr>
f0100690:	e3500000 	cmp	r0, #0
f0100694:	0afffff8 	beq	f010067c <monitor+0xf8>
f0100698:	eaffffda 	b	f0100608 <monitor+0x84>
			buf++;
	}
	argv[argc] = 0;
f010069c:	e3a02000 	mov	r2, #0
f01006a0:	e24b3024 	sub	r3, fp, #36	; 0x24
f01006a4:	e0833106 	add	r3, r3, r6, lsl #2
f01006a8:	e5032040 	str	r2, [r3, #-64]	; 0xffffffc0

	// Lookup and invoke the command
	if (argc == 0)
f01006ac:	e1560002 	cmp	r6, r2
f01006b0:	0affffcc 	beq	f01005e8 <monitor+0x64>
f01006b4:	e1a07002 	mov	r7, r2
f01006b8:	e1a04002 	mov	r4, r2
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
		if (strcmp(argv[0], commands[i].name) == 0)
f01006bc:	e51b0064 	ldr	r0, [fp, #-100]	; 0xffffff9c
f01006c0:	e79a1007 	ldr	r1, [sl, r7]
f01006c4:	eb000da7 	bl	f0103d68 <strcmp>
f01006c8:	e3500000 	cmp	r0, #0
f01006cc:	1a00000a 	bne	f01006fc <monitor+0x178>
			return commands[i].func(argc, argv, tf);
f01006d0:	e0844084 	add	r4, r4, r4, lsl #1
f01006d4:	e51b3074 	ldr	r3, [fp, #-116]	; 0xffffff8c
f01006d8:	e0833104 	add	r3, r3, r4, lsl #2
f01006dc:	e5933008 	ldr	r3, [r3, #8]
f01006e0:	e1a00006 	mov	r0, r6
f01006e4:	e24b1064 	sub	r1, fp, #100	; 0x64
f01006e8:	e51b2070 	ldr	r2, [fp, #-112]	; 0xffffff90
f01006ec:	e12fff33 	blx	r3


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
f01006f0:	e3500000 	cmp	r0, #0
f01006f4:	aaffffbb 	bge	f01005e8 <monitor+0x64>
f01006f8:	ea000007 	b	f010071c <monitor+0x198>
	argv[argc] = 0;

	// Lookup and invoke the command
	if (argc == 0)
		return 0;
	for (i = 0; i < NCOMMANDS; i++) {
f01006fc:	e2844001 	add	r4, r4, #1
f0100700:	e287700c 	add	r7, r7, #12
f0100704:	e3540003 	cmp	r4, #3
f0100708:	1affffeb 	bne	f01006bc <monitor+0x138>
		if (strcmp(argv[0], commands[i].name) == 0)
			return commands[i].func(argc, argv, tf);
	}
	cprintf("Unknown command '%s'\n", argv[0]);
f010070c:	e51b006c 	ldr	r0, [fp, #-108]	; 0xffffff94
f0100710:	e51b1064 	ldr	r1, [fp, #-100]	; 0xffffff9c
f0100714:	eb000022 	bl	f01007a4 <cprintf>
f0100718:	eaffffb2 	b	f01005e8 <monitor+0x64>
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
f010071c:	e24bd020 	sub	sp, fp, #32
f0100720:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
f0100724:	000041c8 	.word	0x000041c8
f0100728:	000041e0 	.word	0x000041e0
f010072c:	000041fc 	.word	0x000041fc
f0100730:	000041f8 	.word	0x000041f8
f0100734:	000041ec 	.word	0x000041ec
f0100738:	0010ba74 	.word	0x0010ba74
f010073c:	00004204 	.word	0x00004204
f0100740:	0010ba60 	.word	0x0010ba60
f0100744:	0000416c 	.word	0x0000416c

f0100748 <putch>:
#include <inc/stdarg.h>


static void
putch(int ch, int *cnt)
{
f0100748:	e92d4818 	push	{r3, r4, fp, lr}
f010074c:	e28db00c 	add	fp, sp, #12
f0100750:	e1a04001 	mov	r4, r1
	cputchar(ch);
f0100754:	ebfffed5 	bl	f01002b0 <cputchar>
	(*cnt)++;
f0100758:	e5943000 	ldr	r3, [r4]
f010075c:	e2833001 	add	r3, r3, #1
f0100760:	e5843000 	str	r3, [r4]
f0100764:	e8bd8818 	pop	{r3, r4, fp, pc}

f0100768 <vcprintf>:
}

int
vcprintf(const char *fmt, va_list ap)
{
f0100768:	e92d4800 	push	{fp, lr}
f010076c:	e28db004 	add	fp, sp, #4
f0100770:	e24dd008 	sub	sp, sp, #8
f0100774:	e1a02000 	mov	r2, r0
f0100778:	e1a03001 	mov	r3, r1
	int cnt = 0;
f010077c:	e24b1004 	sub	r1, fp, #4
f0100780:	e3a00000 	mov	r0, #0
f0100784:	e5210004 	str	r0, [r1, #-4]!

	vprintfmt((void*)putch, &cnt, fmt, ap);
f0100788:	e59f0010 	ldr	r0, [pc, #16]	; f01007a0 <vcprintf+0x38>
f010078c:	e08f0000 	add	r0, pc, r0
f0100790:	eb000b39 	bl	f010347c <vprintfmt>
	return cnt;
}
f0100794:	e51b0008 	ldr	r0, [fp, #-8]
f0100798:	e24bd004 	sub	sp, fp, #4
f010079c:	e8bd8800 	pop	{fp, pc}
f01007a0:	ffffffb4 	.word	0xffffffb4

f01007a4 <cprintf>:

int
cprintf(const char *fmt, ...)
{
f01007a4:	e92d000f 	push	{r0, r1, r2, r3}
f01007a8:	e92d4800 	push	{fp, lr}
f01007ac:	e28db004 	add	fp, sp, #4
f01007b0:	e24dd008 	sub	sp, sp, #8
	va_list ap;
	int cnt;

	va_start(ap, fmt);
f01007b4:	e28b1008 	add	r1, fp, #8
f01007b8:	e50b1008 	str	r1, [fp, #-8]
	cnt = vcprintf(fmt, ap);
f01007bc:	e59b0004 	ldr	r0, [fp, #4]
f01007c0:	ebffffe8 	bl	f0100768 <vcprintf>
	va_end(ap);

	return cnt;
}
f01007c4:	e24bd004 	sub	sp, fp, #4
f01007c8:	e8bd4800 	pop	{fp, lr}
f01007cc:	e28dd010 	add	sp, sp, #16
f01007d0:	e12fff1e 	bx	lr

f01007d4 <check_va2pa>:
// This function returns the physical address of the page containing 'va',
// defined by the page directory 'pgdir'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.
static physaddr_t check_va2pa(pde_t *pgdir, uintptr_t va)
{
f01007d4:	e59f20d8 	ldr	r2, [pc, #216]	; f01008b4 <check_va2pa+0xe0>
f01007d8:	e08f2002 	add	r2, pc, r2
    pte_t *p;

    pgdir = &pgdir[PDX(va)];
f01007dc:	e1a03a21 	lsr	r3, r1, #20
    if (!(*pgdir & PDE_P))
f01007e0:	e7900103 	ldr	r0, [r0, r3, lsl #2]
f01007e4:	e3100003 	tst	r0, #3
f01007e8:	0a00002d 	beq	f01008a4 <check_va2pa+0xd0>
	return ~0;

    if ((*pgdir & PDE_ENTRY_1M) == PDE_ENTRY_1M) {
f01007ec:	e3100002 	tst	r0, #2
f01007f0:	0a000004 	beq	f0100808 <check_va2pa+0x34>
	return (physaddr_t) (((*pgdir) & 0xFFF00000) + (va & 0xFFFFF));
f01007f4:	e1a00a20 	lsr	r0, r0, #20
f01007f8:	e3c114ff 	bic	r1, r1, #-16777216	; 0xff000000
f01007fc:	e3c1160f 	bic	r1, r1, #15728640	; 0xf00000
f0100800:	e0810a00 	add	r0, r1, r0, lsl #20
f0100804:	e12fff1e 	bx	lr
    } 
    else if ((*pgdir & PDE_ENTRY_16M) == PDE_ENTRY_16M){
f0100808:	e59f30a8 	ldr	r3, [pc, #168]	; f01008b8 <check_va2pa+0xe4>
f010080c:	e000c003 	and	ip, r0, r3
f0100810:	e15c0003 	cmp	ip, r3
f0100814:	1a000003 	bne	f0100828 <check_va2pa+0x54>
	return (physaddr_t) (((*pgdir) & 0xFF000000) + (va & 0xFFFFFF));
f0100818:	e20004ff 	and	r0, r0, #-16777216	; 0xff000000
f010081c:	e3c114ff 	bic	r1, r1, #-16777216	; 0xff000000
f0100820:	e0800001 	add	r0, r0, r1
f0100824:	e12fff1e 	bx	lr
    }
    else {
	p = (pte_t*) KADDR(PDE_ADDR(*pgdir));
f0100828:	e3c00fff 	bic	r0, r0, #1020	; 0x3fc
f010082c:	e3c03003 	bic	r3, r0, #3
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100830:	e59f0084 	ldr	r0, [pc, #132]	; f01008bc <check_va2pa+0xe8>
f0100834:	e7922000 	ldr	r2, [r2, r0]
f0100838:	e5922000 	ldr	r2, [r2]
f010083c:	e1520623 	cmp	r2, r3, lsr #12
f0100840:	8a000007 	bhi	f0100864 <check_va2pa+0x90>
// This function returns the physical address of the page containing 'va',
// defined by the page directory 'pgdir'.  The hardware normally performs
// this functionality for us!  We define our own version to help check
// the check_kern_pgdir() function; it shouldn't be used elsewhere.
static physaddr_t check_va2pa(pde_t *pgdir, uintptr_t va)
{
f0100844:	e92d4800 	push	{fp, lr}
f0100848:	e28db004 	add	fp, sp, #4
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010084c:	e59f006c 	ldr	r0, [pc, #108]	; f01008c0 <check_va2pa+0xec>
f0100850:	e08f0000 	add	r0, pc, r0
f0100854:	e3a01f5e 	mov	r1, #376	; 0x178
f0100858:	e59f2064 	ldr	r2, [pc, #100]	; f01008c4 <check_va2pa+0xf0>
f010085c:	e08f2002 	add	r2, pc, r2
f0100860:	ebfffe10 	bl	f01000a8 <_panic>
    else if ((*pgdir & PDE_ENTRY_16M) == PDE_ENTRY_16M){
	return (physaddr_t) (((*pgdir) & 0xFF000000) + (va & 0xFFFFFF));
    }
    else {
	p = (pte_t*) KADDR(PDE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
f0100864:	e1a00521 	lsr	r0, r1, #10
f0100868:	e2000fff 	and	r0, r0, #1020	; 0x3fc
f010086c:	e0803003 	add	r3, r0, r3
f0100870:	e283320f 	add	r3, r3, #-268435456	; 0xf0000000
f0100874:	e5930000 	ldr	r0, [r3]
f0100878:	e3100003 	tst	r0, #3
f010087c:	0a00000a 	beq	f01008ac <check_va2pa+0xd8>
	    return ~0;
	pte_t pte = p[PTX(va)];
	if ((pte & PTE_ENTRY_SMALL) == PTE_ENTRY_SMALL) {
f0100880:	e3100002 	tst	r0, #2
	    return PTE_SMALL_ADDR(p[PTX(va)]) + (va & 0xFFF);
f0100884:	13c00eff 	bicne	r0, r0, #4080	; 0xff0
f0100888:	13c0000f 	bicne	r0, r0, #15
f010088c:	11a01a01 	lslne	r1, r1, #20
f0100890:	10800a21 	addne	r0, r0, r1, lsr #20
	} else {
	    return PTE_LARGE_ADDR(p[PTX(va)]) + (va & 0xFFFF);
f0100894:	01a00820 	lsreq	r0, r0, #16
f0100898:	06ff1071 	uxtheq	r1, r1
f010089c:	00810800 	addeq	r0, r1, r0, lsl #16
f01008a0:	e12fff1e 	bx	lr
{
    pte_t *p;

    pgdir = &pgdir[PDX(va)];
    if (!(*pgdir & PDE_P))
	return ~0;
f01008a4:	e3e00000 	mvn	r0, #0
f01008a8:	e12fff1e 	bx	lr
	return (physaddr_t) (((*pgdir) & 0xFF000000) + (va & 0xFFFFFF));
    }
    else {
	p = (pte_t*) KADDR(PDE_ADDR(*pgdir));
	if (!(p[PTX(va)] & PTE_P))
	    return ~0;
f01008ac:	e3e00000 	mvn	r0, #0
	    return PTE_LARGE_ADDR(p[PTX(va)]) + (va & 0xFFFF);
	}
    }
    panic("unreachable area.\n");
    return ~0;
}
f01008b0:	e12fff1e 	bx	lr
f01008b4:	0010b824 	.word	0x0010b824
f01008b8:	00040002 	.word	0x00040002
f01008bc:	0000002c 	.word	0x0000002c
f01008c0:	00003fa0 	.word	0x00003fa0
f01008c4:	00003fa0 	.word	0x00003fa0

f01008c8 <page_init>:
    check_kern_pgdir();
    check_page_installed_pgdir();
}

void page_init(void)
{
f01008c8:	e92d48f0 	push	{r4, r5, r6, r7, fp, lr}
f01008cc:	e28db014 	add	fp, sp, #20
f01008d0:	e24dd008 	sub	sp, sp, #8
f01008d4:	e59fe0fc 	ldr	lr, [pc, #252]	; f01009d8 <page_init+0x110>
f01008d8:	e08fe00e 	add	lr, pc, lr
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01008dc:	e59f30f8 	ldr	r3, [pc, #248]	; f01009dc <page_init+0x114>
f01008e0:	e79e3003 	ldr	r3, [lr, r3]
f01008e4:	e593c000 	ldr	ip, [r3]
f01008e8:	e35c0000 	cmp	ip, #0
f01008ec:	1a00000e 	bne	f010092c <page_init+0x64>
f01008f0:	ea000007 	b	f0100914 <page_init+0x4c>
f01008f4:	e1a01622 	lsr	r1, r2, #12
f01008f8:	e2833a01 	add	r3, r3, #4096	; 0x1000
f01008fc:	e2822a01 	add	r2, r2, #4096	; 0x1000
f0100900:	e151000c 	cmp	r1, ip
f0100904:	3a000010 	bcc	f010094c <page_init+0x84>
f0100908:	e59f30d0 	ldr	r3, [pc, #208]	; f01009e0 <page_init+0x118>
f010090c:	e08f3003 	add	r3, pc, r3
f0100910:	e5835000 	str	r5, [r3]
		panic("pa2page called with invalid pa");
f0100914:	e59f00c8 	ldr	r0, [pc, #200]	; f01009e4 <page_init+0x11c>
f0100918:	e08f0000 	add	r0, pc, r0
f010091c:	e3a01048 	mov	r1, #72	; 0x48
f0100920:	e59f20c0 	ldr	r2, [pc, #192]	; f01009e8 <page_init+0x120>
f0100924:	e08f2002 	add	r2, pc, r2
f0100928:	ebfffdde 	bl	f01000a8 <_panic>
f010092c:	e59f30b8 	ldr	r3, [pc, #184]	; f01009ec <page_init+0x124>
f0100930:	e08f3003 	add	r3, pc, r3
f0100934:	e5935000 	ldr	r5, [r3]
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100938:	e3a02a01 	mov	r2, #4096	; 0x1000
f010093c:	e3a03000 	mov	r3, #0
f0100940:	e1a01003 	mov	r1, r3
    extern char end[];
    for (physaddr_t addr = 0; addr < TOTAL_PHYS_MEM; addr += PGSIZE) 
    {
        struct PageInfo *pg = pa2page(addr);
        if (addr == 0 || (0x100000 <= addr && addr < PADDR(end)))
f0100944:	e59f60a4 	ldr	r6, [pc, #164]	; f01009f0 <page_init+0x128>
            continue;
        pg->pp_ref = 0;
f0100948:	e1a07003 	mov	r7, r3
{
    extern char end[];
    for (physaddr_t addr = 0; addr < TOTAL_PHYS_MEM; addr += PGSIZE) 
    {
        struct PageInfo *pg = pa2page(addr);
        if (addr == 0 || (0x100000 <= addr && addr < PADDR(end)))
f010094c:	e3530000 	cmp	r3, #0
f0100950:	0affffe7 	beq	f01008f4 <page_init+0x2c>
f0100954:	e1530006 	cmp	r3, r6
f0100958:	9a000011 	bls	f01009a4 <page_init+0xdc>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f010095c:	e59f0090 	ldr	r0, [pc, #144]	; f01009f4 <page_init+0x12c>
f0100960:	e79e0000 	ldr	r0, [lr, r0]
f0100964:	e3700211 	cmn	r0, #268435457	; 0x10000001
f0100968:	8a00000a 	bhi	f0100998 <page_init+0xd0>
f010096c:	e59f3084 	ldr	r3, [pc, #132]	; f01009f8 <page_init+0x130>
f0100970:	e08f3003 	add	r3, pc, r3
f0100974:	e5835000 	str	r5, [r3]
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100978:	e59f3074 	ldr	r3, [pc, #116]	; f01009f4 <page_init+0x12c>
f010097c:	e79e3003 	ldr	r3, [lr, r3]
f0100980:	e59f0074 	ldr	r0, [pc, #116]	; f01009fc <page_init+0x134>
f0100984:	e08f0000 	add	r0, pc, r0
f0100988:	e3a01049 	mov	r1, #73	; 0x49
f010098c:	e59f206c 	ldr	r2, [pc, #108]	; f0100a00 <page_init+0x138>
f0100990:	e08f2002 	add	r2, pc, r2
f0100994:	ebfffdc3 	bl	f01000a8 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100998:	e2800201 	add	r0, r0, #268435456	; 0x10000000
f010099c:	e1530000 	cmp	r3, r0
f01009a0:	3a000005 	bcc	f01009bc <page_init+0xf4>
            continue;
        pg->pp_ref = 0;
f01009a4:	e59f0058 	ldr	r0, [pc, #88]	; f0100a04 <page_init+0x13c>
f01009a8:	e79e4000 	ldr	r4, [lr, r0]
f01009ac:	e0840181 	add	r0, r4, r1, lsl #3
f01009b0:	e1c070b4 	strh	r7, [r0, #4]
        pg->pp_link = page_free_list;
f01009b4:	e7845181 	str	r5, [r4, r1, lsl #3]
static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
		panic("pa2page called with invalid pa");
	return &pages[PGNUM(pa)];
f01009b8:	e1a05000 	mov	r5, r0
}

void page_init(void)
{
    extern char end[];
    for (physaddr_t addr = 0; addr < TOTAL_PHYS_MEM; addr += PGSIZE) 
f01009bc:	e372021f 	cmn	r2, #-268435455	; 0xf0000001
f01009c0:	9affffcb 	bls	f01008f4 <page_init+0x2c>
f01009c4:	e59f303c 	ldr	r3, [pc, #60]	; f0100a08 <page_init+0x140>
f01009c8:	e08f3003 	add	r3, pc, r3
f01009cc:	e5835000 	str	r5, [r3]
            continue;
        pg->pp_ref = 0;
        pg->pp_link = page_free_list;
        page_free_list = pg;
    }
}
f01009d0:	e24bd014 	sub	sp, fp, #20
f01009d4:	e8bd88f0 	pop	{r4, r5, r6, r7, fp, pc}
f01009d8:	0010b724 	.word	0x0010b724
f01009dc:	0000002c 	.word	0x0000002c
f01009e0:	0010f8f4 	.word	0x0010f8f4
f01009e4:	00003f08 	.word	0x00003f08
f01009e8:	00003f0c 	.word	0x00003f0c
f01009ec:	0010f8d0 	.word	0x0010f8d0
f01009f0:	000fffff 	.word	0x000fffff
f01009f4:	00000014 	.word	0x00000014
f01009f8:	0010f890 	.word	0x0010f890
f01009fc:	00003e6c 	.word	0x00003e6c
f0100a00:	00003ec0 	.word	0x00003ec0
f0100a04:	00000034 	.word	0x00000034
f0100a08:	0010f838 	.word	0x0010f838

f0100a0c <page_alloc>:

struct PageInfo * page_alloc(int alloc_flags)
{
f0100a0c:	e92d4818 	push	{r3, r4, fp, lr}
f0100a10:	e28db00c 	add	fp, sp, #12
f0100a14:	e59f208c 	ldr	r2, [pc, #140]	; f0100aa8 <page_alloc+0x9c>
f0100a18:	e08f2002 	add	r2, pc, r2
    if (page_free_list == NULL) 
f0100a1c:	e59f3088 	ldr	r3, [pc, #136]	; f0100aac <page_alloc+0xa0>
f0100a20:	e08f3003 	add	r3, pc, r3
f0100a24:	e5934000 	ldr	r4, [r3]
f0100a28:	e3540000 	cmp	r4, #0
f0100a2c:	0a00001b 	beq	f0100aa0 <page_alloc+0x94>
        return NULL;
    struct PageInfo* ret = page_free_list;
    page_free_list = ret->pp_link;
f0100a30:	e5941000 	ldr	r1, [r4]
f0100a34:	e59f3074 	ldr	r3, [pc, #116]	; f0100ab0 <page_alloc+0xa4>
f0100a38:	e08f3003 	add	r3, pc, r3
f0100a3c:	e5831000 	str	r1, [r3]
    if (alloc_flags & ALLOC_ZERO) 
f0100a40:	e3100001 	tst	r0, #1
f0100a44:	0a000013 	beq	f0100a98 <page_alloc+0x8c>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100a48:	e59f3064 	ldr	r3, [pc, #100]	; f0100ab4 <page_alloc+0xa8>
f0100a4c:	e7923003 	ldr	r3, [r2, r3]
f0100a50:	e0633004 	rsb	r3, r3, r4
f0100a54:	e1a031c3 	asr	r3, r3, #3
f0100a58:	e1a03603 	lsl	r3, r3, #12
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100a5c:	e59f1054 	ldr	r1, [pc, #84]	; f0100ab8 <page_alloc+0xac>
f0100a60:	e7922001 	ldr	r2, [r2, r1]
f0100a64:	e5922000 	ldr	r2, [r2]
f0100a68:	e1520623 	cmp	r2, r3, lsr #12
f0100a6c:	8a000005 	bhi	f0100a88 <page_alloc+0x7c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100a70:	e59f0044 	ldr	r0, [pc, #68]	; f0100abc <page_alloc+0xb0>
f0100a74:	e08f0000 	add	r0, pc, r0
f0100a78:	e3a0104f 	mov	r1, #79	; 0x4f
f0100a7c:	e59f203c 	ldr	r2, [pc, #60]	; f0100ac0 <page_alloc+0xb4>
f0100a80:	e08f2002 	add	r2, pc, r2
f0100a84:	ebfffd87 	bl	f01000a8 <_panic>
        memset(page2kva(ret), 0, PGSIZE);
f0100a88:	e283020f 	add	r0, r3, #-268435456	; 0xf0000000
f0100a8c:	e3a01000 	mov	r1, #0
f0100a90:	e3a02a01 	mov	r2, #4096	; 0x1000
f0100a94:	eb000d0e 	bl	f0103ed4 <memset>
    ret->pp_link = NULL;
f0100a98:	e3a03000 	mov	r3, #0
f0100a9c:	e5843000 	str	r3, [r4]
    return ret;
}
f0100aa0:	e1a00004 	mov	r0, r4
f0100aa4:	e8bd8818 	pop	{r3, r4, fp, pc}
f0100aa8:	0010b5e4 	.word	0x0010b5e4
f0100aac:	0010f7e0 	.word	0x0010f7e0
f0100ab0:	0010f7c8 	.word	0x0010f7c8
f0100ab4:	00000034 	.word	0x00000034
f0100ab8:	0000002c 	.word	0x0000002c
f0100abc:	00003dac 	.word	0x00003dac
f0100ac0:	00003d7c 	.word	0x00003d7c

f0100ac4 <page_free>:

void page_free(struct PageInfo *pp)
{
    if (pp->pp_ref == 0) 
f0100ac4:	e1d030b4 	ldrh	r3, [r0, #4]
f0100ac8:	e3530000 	cmp	r3, #0
f0100acc:	1a000005 	bne	f0100ae8 <page_free+0x24>
    {
        pp->pp_link = page_free_list;
f0100ad0:	e59f3030 	ldr	r3, [pc, #48]	; f0100b08 <page_free+0x44>
f0100ad4:	e08f3003 	add	r3, pc, r3
f0100ad8:	e5932000 	ldr	r2, [r3]
f0100adc:	e5802000 	str	r2, [r0]
        page_free_list = pp;
f0100ae0:	e5830000 	str	r0, [r3]
f0100ae4:	e12fff1e 	bx	lr
    ret->pp_link = NULL;
    return ret;
}

void page_free(struct PageInfo *pp)
{
f0100ae8:	e92d4800 	push	{fp, lr}
f0100aec:	e28db004 	add	fp, sp, #4
        pp->pp_link = page_free_list;
        page_free_list = pp;
    }
    else 
    {
        panic("pp->pp_ref is not zero. Wrong call of the page_free!!!");
f0100af0:	e59f0014 	ldr	r0, [pc, #20]	; f0100b0c <page_free+0x48>
f0100af4:	e08f0000 	add	r0, pc, r0
f0100af8:	e3a01066 	mov	r1, #102	; 0x66
f0100afc:	e59f200c 	ldr	r2, [pc, #12]	; f0100b10 <page_free+0x4c>
f0100b00:	e08f2002 	add	r2, pc, r2
f0100b04:	ebfffd67 	bl	f01000a8 <_panic>
f0100b08:	0010f72c 	.word	0x0010f72c
f0100b0c:	00003cfc 	.word	0x00003cfc
f0100b10:	00003d74 	.word	0x00003d74

f0100b14 <page_decref>:
    }
}

void page_decref(struct PageInfo* pp)
{
    if (--pp->pp_ref == 0)
f0100b14:	e1d030b4 	ldrh	r3, [r0, #4]
f0100b18:	e2433001 	sub	r3, r3, #1
f0100b1c:	e6ff3073 	uxth	r3, r3
f0100b20:	e1c030b4 	strh	r3, [r0, #4]
f0100b24:	e3530000 	cmp	r3, #0
f0100b28:	112fff1e 	bxne	lr
        panic("pp->pp_ref is not zero. Wrong call of the page_free!!!");
    }
}

void page_decref(struct PageInfo* pp)
{
f0100b2c:	e92d4800 	push	{fp, lr}
f0100b30:	e28db004 	add	fp, sp, #4
    if (--pp->pp_ref == 0)
	page_free(pp);
f0100b34:	ebffffe2 	bl	f0100ac4 <page_free>
f0100b38:	e8bd8800 	pop	{fp, pc}

f0100b3c <pgdir_walk>:
    tbl += NPTENTRIES * 4;
    return ret;
}

pte_t * pgdir_walk(pde_t *pgdir, const void *va, int create)
{
f0100b3c:	e92d48f0 	push	{r4, r5, r6, r7, fp, lr}
f0100b40:	e28db014 	add	fp, sp, #20
f0100b44:	e1a06000 	mov	r6, r0
f0100b48:	e1a04001 	mov	r4, r1
f0100b4c:	e59f5144 	ldr	r5, [pc, #324]	; f0100c98 <pgdir_walk+0x15c>
f0100b50:	e08f5005 	add	r5, pc, r5
    if (!(pgdir[PDX(va)] & PTE_P)) 
f0100b54:	e1a07a21 	lsr	r7, r1, #20
f0100b58:	e7903107 	ldr	r3, [r0, r7, lsl #2]
f0100b5c:	e3130003 	tst	r3, #3
f0100b60:	1a000033 	bne	f0100c34 <pgdir_walk+0xf8>
    {
        if (!create) 
f0100b64:	e3520000 	cmp	r2, #0
f0100b68:	0a000044 	beq	f0100c80 <pgdir_walk+0x144>
}

static pte_t* pgtbl_alloc()
{
    static pte_t* tbl = NULL;
    if ((uintptr_t)tbl % PGSIZE == 0) 
f0100b6c:	e59f3128 	ldr	r3, [pc, #296]	; f0100c9c <pgdir_walk+0x160>
f0100b70:	e08f3003 	add	r3, pc, r3
f0100b74:	e5933004 	ldr	r3, [r3, #4]
f0100b78:	e1b03a03 	lsls	r3, r3, #20
f0100b7c:	1a00001a 	bne	f0100bec <pgdir_walk+0xb0>
    {
        struct PageInfo *pg = page_alloc(ALLOC_ZERO);
f0100b80:	e3a00001 	mov	r0, #1
f0100b84:	ebffffa0 	bl	f0100a0c <page_alloc>
        if (pg == NULL) 
f0100b88:	e3500000 	cmp	r0, #0
f0100b8c:	0a00003d 	beq	f0100c88 <pgdir_walk+0x14c>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100b90:	e59f3108 	ldr	r3, [pc, #264]	; f0100ca0 <pgdir_walk+0x164>
f0100b94:	e7953003 	ldr	r3, [r5, r3]
f0100b98:	e0633000 	rsb	r3, r3, r0
f0100b9c:	e1a031c3 	asr	r3, r3, #3
f0100ba0:	e1a03603 	lsl	r3, r3, #12
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100ba4:	e59f20f8 	ldr	r2, [pc, #248]	; f0100ca4 <pgdir_walk+0x168>
f0100ba8:	e7952002 	ldr	r2, [r5, r2]
f0100bac:	e5922000 	ldr	r2, [r2]
f0100bb0:	e1520623 	cmp	r2, r3, lsr #12
f0100bb4:	8a000005 	bhi	f0100bd0 <pgdir_walk+0x94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100bb8:	e59f00e8 	ldr	r0, [pc, #232]	; f0100ca8 <pgdir_walk+0x16c>
f0100bbc:	e08f0000 	add	r0, pc, r0
f0100bc0:	e3a0104f 	mov	r1, #79	; 0x4f
f0100bc4:	e59f20e0 	ldr	r2, [pc, #224]	; f0100cac <pgdir_walk+0x170>
f0100bc8:	e08f2002 	add	r2, pc, r2
f0100bcc:	ebfffd35 	bl	f01000a8 <_panic>
	return (void *)(pa + KERNBASE);
f0100bd0:	e283320f 	add	r3, r3, #-268435456	; 0xf0000000
            return NULL;
        tbl = page2kva(pg);
f0100bd4:	e59f20d4 	ldr	r2, [pc, #212]	; f0100cb0 <pgdir_walk+0x174>
f0100bd8:	e08f2002 	add	r2, pc, r2
f0100bdc:	e5823004 	str	r3, [r2, #4]
        pg->pp_ref++;
f0100be0:	e1d030b4 	ldrh	r3, [r0, #4]
f0100be4:	e2833001 	add	r3, r3, #1
f0100be8:	e1c030b4 	strh	r3, [r0, #4]
    }
    pte_t *ret = tbl;
f0100bec:	e59f20c0 	ldr	r2, [pc, #192]	; f0100cb4 <pgdir_walk+0x178>
f0100bf0:	e08f2002 	add	r2, pc, r2
f0100bf4:	e5923004 	ldr	r3, [r2, #4]
    tbl += NPTENTRIES * 4;
f0100bf8:	e2831a01 	add	r1, r3, #4096	; 0x1000
f0100bfc:	e5821004 	str	r1, [r2, #4]
    if (!(pgdir[PDX(va)] & PTE_P)) 
    {
        if (!create) 
            return NULL;
        pte_t* pgtbl = pgtbl_alloc();
        if (!pgtbl) 
f0100c00:	e3530000 	cmp	r3, #0
f0100c04:	0a000021 	beq	f0100c90 <pgdir_walk+0x154>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c08:	e3730211 	cmn	r3, #268435457	; 0x10000001
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
	return (physaddr_t)kva - KERNBASE;
f0100c0c:	82833201 	addhi	r3, r3, #268435456	; 0x10000000
            return NULL;
        pgdir[PDX(va)] = PADDR(pgtbl) | PDE_ENTRY;
f0100c10:	83833001 	orrhi	r3, r3, #1
f0100c14:	87863107 	strhi	r3, [r6, r7, lsl #2]
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100c18:	8a000005 	bhi	f0100c34 <pgdir_walk+0xf8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100c1c:	e59f0094 	ldr	r0, [pc, #148]	; f0100cb8 <pgdir_walk+0x17c>
f0100c20:	e08f0000 	add	r0, pc, r0
f0100c24:	e3a01089 	mov	r1, #137	; 0x89
f0100c28:	e59f208c 	ldr	r2, [pc, #140]	; f0100cbc <pgdir_walk+0x180>
f0100c2c:	e08f2002 	add	r2, pc, r2
f0100c30:	ebfffd1c 	bl	f01000a8 <_panic>
    }
    pte_t *pgtbl = (pte_t*)KADDR(PDE_ADDR(pgdir[PDX(va)]));
f0100c34:	e7963107 	ldr	r3, [r6, r7, lsl #2]
f0100c38:	e3c33fff 	bic	r3, r3, #1020	; 0x3fc
f0100c3c:	e3c33003 	bic	r3, r3, #3
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100c40:	e59f205c 	ldr	r2, [pc, #92]	; f0100ca4 <pgdir_walk+0x168>
f0100c44:	e7952002 	ldr	r2, [r5, r2]
f0100c48:	e5922000 	ldr	r2, [r2]
f0100c4c:	e1520623 	cmp	r2, r3, lsr #12
f0100c50:	8a000005 	bhi	f0100c6c <pgdir_walk+0x130>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0100c54:	e59f0064 	ldr	r0, [pc, #100]	; f0100cc0 <pgdir_walk+0x184>
f0100c58:	e08f0000 	add	r0, pc, r0
f0100c5c:	e3a0108b 	mov	r1, #139	; 0x8b
f0100c60:	e59f205c 	ldr	r2, [pc, #92]	; f0100cc4 <pgdir_walk+0x188>
f0100c64:	e08f2002 	add	r2, pc, r2
f0100c68:	ebfffd0e 	bl	f01000a8 <_panic>
	return (void *)(pa + KERNBASE);
f0100c6c:	e283320f 	add	r3, r3, #-268435456	; 0xf0000000
    return &pgtbl[PTX(va)];
f0100c70:	e1a00524 	lsr	r0, r4, #10
f0100c74:	e2000fff 	and	r0, r0, #1020	; 0x3fc
f0100c78:	e0830000 	add	r0, r3, r0
f0100c7c:	e8bd88f0 	pop	{r4, r5, r6, r7, fp, pc}
pte_t * pgdir_walk(pde_t *pgdir, const void *va, int create)
{
    if (!(pgdir[PDX(va)] & PTE_P)) 
    {
        if (!create) 
            return NULL;
f0100c80:	e3a00000 	mov	r0, #0
f0100c84:	e8bd88f0 	pop	{r4, r5, r6, r7, fp, pc}
        pte_t* pgtbl = pgtbl_alloc();
        if (!pgtbl) 
            return NULL;
f0100c88:	e3a00000 	mov	r0, #0
f0100c8c:	e8bd88f0 	pop	{r4, r5, r6, r7, fp, pc}
f0100c90:	e3a00000 	mov	r0, #0
        pgdir[PDX(va)] = PADDR(pgtbl) | PDE_ENTRY;
    }
    pte_t *pgtbl = (pte_t*)KADDR(PDE_ADDR(pgdir[PDX(va)]));
    return &pgtbl[PTX(va)];
}
f0100c94:	e8bd88f0 	pop	{r4, r5, r6, r7, fp, pc}
f0100c98:	0010b4ac 	.word	0x0010b4ac
f0100c9c:	0010f690 	.word	0x0010f690
f0100ca0:	00000034 	.word	0x00000034
f0100ca4:	0000002c 	.word	0x0000002c
f0100ca8:	00003c64 	.word	0x00003c64
f0100cac:	00003c34 	.word	0x00003c34
f0100cb0:	0010f628 	.word	0x0010f628
f0100cb4:	0010f610 	.word	0x0010f610
f0100cb8:	00003bd0 	.word	0x00003bd0
f0100cbc:	00003c24 	.word	0x00003c24
f0100cc0:	00003b98 	.word	0x00003b98
f0100cc4:	00003b98 	.word	0x00003b98

f0100cc8 <page_lookup>:
    pp->pp_ref++;
    return 0;
}

struct PageInfo * page_lookup(pde_t *pgdir, void *va, pte_t **pte_store)
{
f0100cc8:	e92d4830 	push	{r4, r5, fp, lr}
f0100ccc:	e28db00c 	add	fp, sp, #12
f0100cd0:	e1a05002 	mov	r5, r2
f0100cd4:	e59f4074 	ldr	r4, [pc, #116]	; f0100d50 <page_lookup+0x88>
f0100cd8:	e08f4004 	add	r4, pc, r4
    pte_t *pte = pgdir_walk(pgdir, va, 0);
f0100cdc:	e3a02000 	mov	r2, #0
f0100ce0:	ebffff95 	bl	f0100b3c <pgdir_walk>
    if (pte_store != NULL) 
f0100ce4:	e3550000 	cmp	r5, #0
        *pte_store = pte;
f0100ce8:	15850000 	strne	r0, [r5]
    if (pte == NULL || !(*pte & PTE_P)) 
f0100cec:	e3500000 	cmp	r0, #0
f0100cf0:	0a000012 	beq	f0100d40 <page_lookup+0x78>
f0100cf4:	e5900000 	ldr	r0, [r0]
f0100cf8:	e3100003 	tst	r0, #3
f0100cfc:	0a000011 	beq	f0100d48 <page_lookup+0x80>
}

static inline struct PageInfo*
pa2page(physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0100d00:	e1a00620 	lsr	r0, r0, #12
f0100d04:	e59f3048 	ldr	r3, [pc, #72]	; f0100d54 <page_lookup+0x8c>
f0100d08:	e7943003 	ldr	r3, [r4, r3]
f0100d0c:	e5933000 	ldr	r3, [r3]
f0100d10:	e1500003 	cmp	r0, r3
f0100d14:	3a000005 	bcc	f0100d30 <page_lookup+0x68>
		panic("pa2page called with invalid pa");
f0100d18:	e59f0038 	ldr	r0, [pc, #56]	; f0100d58 <page_lookup+0x90>
f0100d1c:	e08f0000 	add	r0, pc, r0
f0100d20:	e3a01048 	mov	r1, #72	; 0x48
f0100d24:	e59f2030 	ldr	r2, [pc, #48]	; f0100d5c <page_lookup+0x94>
f0100d28:	e08f2002 	add	r2, pc, r2
f0100d2c:	ebfffcdd 	bl	f01000a8 <_panic>
	return &pages[PGNUM(pa)];
f0100d30:	e59f3028 	ldr	r3, [pc, #40]	; f0100d60 <page_lookup+0x98>
f0100d34:	e7943003 	ldr	r3, [r4, r3]
f0100d38:	e0830180 	add	r0, r3, r0, lsl #3
        return NULL;
    return pa2page(PTE_SMALL_ADDR(*pte));
f0100d3c:	e8bd8830 	pop	{r4, r5, fp, pc}
{
    pte_t *pte = pgdir_walk(pgdir, va, 0);
    if (pte_store != NULL) 
        *pte_store = pte;
    if (pte == NULL || !(*pte & PTE_P)) 
        return NULL;
f0100d40:	e3a00000 	mov	r0, #0
f0100d44:	e8bd8830 	pop	{r4, r5, fp, pc}
f0100d48:	e3a00000 	mov	r0, #0
    return pa2page(PTE_SMALL_ADDR(*pte));
}
f0100d4c:	e8bd8830 	pop	{r4, r5, fp, pc}
f0100d50:	0010b324 	.word	0x0010b324
f0100d54:	0000002c 	.word	0x0000002c
f0100d58:	00003b04 	.word	0x00003b04
f0100d5c:	00003b08 	.word	0x00003b08
f0100d60:	00000034 	.word	0x00000034

f0100d64 <tlb_invalidate>:
        tlb_invalidate(pgdir, va);
    }
}

void tlb_invalidate(pde_t *pgdir, void *va)
{
f0100d64:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0100d68:	e28db000 	add	fp, sp, #0
    asm("mcr p15, 0, %0, c8, c7, 1"
f0100d6c:	ee081f37 	mcr	15, 0, r1, cr8, cr7, {1}
	    :
	    : "r"(va)
	    :);
}
f0100d70:	e24bd000 	sub	sp, fp, #0
f0100d74:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0100d78:	e12fff1e 	bx	lr

f0100d7c <page_remove>:
        return NULL;
    return pa2page(PTE_SMALL_ADDR(*pte));
}

void page_remove(pde_t *pgdir, void *va)
{
f0100d7c:	e92d48f0 	push	{r4, r5, r6, r7, fp, lr}
f0100d80:	e28db014 	add	fp, sp, #20
f0100d84:	e1a05000 	mov	r5, r0
f0100d88:	e1a04001 	mov	r4, r1
    struct PageInfo *page = page_lookup(pgdir, va, 0);
f0100d8c:	e3a02000 	mov	r2, #0
f0100d90:	ebffffcc 	bl	f0100cc8 <page_lookup>
f0100d94:	e1a07000 	mov	r7, r0
    pte_t *pte = pgdir_walk(pgdir, va, 0);
f0100d98:	e1a00005 	mov	r0, r5
f0100d9c:	e1a01004 	mov	r1, r4
f0100da0:	e3a02000 	mov	r2, #0
f0100da4:	ebffff64 	bl	f0100b3c <pgdir_walk>
f0100da8:	e1a06000 	mov	r6, r0
    if (page != NULL) 
f0100dac:	e3570000 	cmp	r7, #0
f0100db0:	0a000001 	beq	f0100dbc <page_remove+0x40>
        page_decref(page);
f0100db4:	e1a00007 	mov	r0, r7
f0100db8:	ebffff55 	bl	f0100b14 <page_decref>
    if (pte != NULL) 
f0100dbc:	e3560000 	cmp	r6, #0
f0100dc0:	08bd88f0 	popeq	{r4, r5, r6, r7, fp, pc}
    {
        *pte = 0;
f0100dc4:	e3a03000 	mov	r3, #0
f0100dc8:	e5863000 	str	r3, [r6]
        tlb_invalidate(pgdir, va);
f0100dcc:	e1a00005 	mov	r0, r5
f0100dd0:	e1a01004 	mov	r1, r4
f0100dd4:	ebffffe2 	bl	f0100d64 <tlb_invalidate>
f0100dd8:	e8bd88f0 	pop	{r4, r5, r6, r7, fp, pc}

f0100ddc <page_insert>:
            panic("boot_map_region out of memory\n");
    }
}

int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
f0100ddc:	e92d4bf0 	push	{r4, r5, r6, r7, r8, r9, fp, lr}
f0100de0:	e28db01c 	add	fp, sp, #28
f0100de4:	e1a09000 	mov	r9, r0
f0100de8:	e1a05001 	mov	r5, r1
f0100dec:	e1a08002 	mov	r8, r2
f0100df0:	e1a04003 	mov	r4, r3
f0100df4:	e59f70a0 	ldr	r7, [pc, #160]	; f0100e9c <page_insert+0xc0>
f0100df8:	e08f7007 	add	r7, pc, r7
    pte_t *pte = pgdir_walk(pgdir, va, 1);
f0100dfc:	e1a01002 	mov	r1, r2
f0100e00:	e3a02001 	mov	r2, #1
f0100e04:	ebffff4c 	bl	f0100b3c <pgdir_walk>
    if (pte == NULL) 
f0100e08:	e2506000 	subs	r6, r0, #0
f0100e0c:	0a000020 	beq	f0100e94 <page_insert+0xb8>
        return -E_NO_MEM;
    if (*pte & PTE_P) 
f0100e10:	e5963000 	ldr	r3, [r6]
f0100e14:	e3130003 	tst	r3, #3
f0100e18:	0a000011 	beq	f0100e64 <page_insert+0x88>
    {
        if (PTE_SMALL_ADDR(*pte) == page2pa(pp)) 
f0100e1c:	e3c33eff 	bic	r3, r3, #4080	; 0xff0
f0100e20:	e3c3300f 	bic	r3, r3, #15
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0100e24:	e59f2074 	ldr	r2, [pc, #116]	; f0100ea0 <page_insert+0xc4>
f0100e28:	e7972002 	ldr	r2, [r7, r2]
f0100e2c:	e0622005 	rsb	r2, r2, r5
f0100e30:	e1a021c2 	asr	r2, r2, #3
f0100e34:	e1530602 	cmp	r3, r2, lsl #12
f0100e38:	1a000006 	bne	f0100e58 <page_insert+0x7c>
        {
            pp->pp_ref--;
f0100e3c:	e1d530b4 	ldrh	r3, [r5, #4]
f0100e40:	e2433001 	sub	r3, r3, #1
f0100e44:	e1c530b4 	strh	r3, [r5, #4]
            tlb_invalidate(pgdir, va);
f0100e48:	e1a00009 	mov	r0, r9
f0100e4c:	e1a01008 	mov	r1, r8
f0100e50:	ebffffc3 	bl	f0100d64 <tlb_invalidate>
f0100e54:	ea000002 	b	f0100e64 <page_insert+0x88>
        }
        else 
            page_remove(pgdir, va);
f0100e58:	e1a00009 	mov	r0, r9
f0100e5c:	e1a01008 	mov	r1, r8
f0100e60:	ebffffc5 	bl	f0100d7c <page_remove>
f0100e64:	e3844003 	orr	r4, r4, #3
f0100e68:	e59f3030 	ldr	r3, [pc, #48]	; f0100ea0 <page_insert+0xc4>
f0100e6c:	e7973003 	ldr	r3, [r7, r3]
f0100e70:	e0633005 	rsb	r3, r3, r5
f0100e74:	e1a031c3 	asr	r3, r3, #3
    }
    *pte = page2pa(pp) | perm | PTE_P;
f0100e78:	e1844603 	orr	r4, r4, r3, lsl #12
f0100e7c:	e5864000 	str	r4, [r6]
    pp->pp_ref++;
f0100e80:	e1d530b4 	ldrh	r3, [r5, #4]
f0100e84:	e2833001 	add	r3, r3, #1
f0100e88:	e1c530b4 	strh	r3, [r5, #4]
    return 0;
f0100e8c:	e3a00000 	mov	r0, #0
f0100e90:	e8bd8bf0 	pop	{r4, r5, r6, r7, r8, r9, fp, pc}

int page_insert(pde_t *pgdir, struct PageInfo *pp, void *va, int perm)
{
    pte_t *pte = pgdir_walk(pgdir, va, 1);
    if (pte == NULL) 
        return -E_NO_MEM;
f0100e94:	e3e00003 	mvn	r0, #3
            page_remove(pgdir, va);
    }
    *pte = page2pa(pp) | perm | PTE_P;
    pp->pp_ref++;
    return 0;
}
f0100e98:	e8bd8bf0 	pop	{r4, r5, r6, r7, r8, r9, fp, pc}
f0100e9c:	0010b204 	.word	0x0010b204
f0100ea0:	00000034 	.word	0x00000034

f0100ea4 <mem_init>:
	    : "r"(clear_bit), "r"(new_priv)
	    : "r0");
}

void mem_init()
{
f0100ea4:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
f0100ea8:	e28db020 	add	fp, sp, #32
f0100eac:	e24dd01c 	sub	sp, sp, #28
f0100eb0:	e59f4fd0 	ldr	r4, [pc, #4048]	; f0101e88 <mem_init+0xfe4>
f0100eb4:	e08f4004 	add	r4, pc, r4
    page_init();
f0100eb8:	ebfffe82 	bl	f01008c8 <page_init>


    // map physical memory
    for (uintptr_t addr = KERNBASE; addr != 0; addr += PTSIZE) 
    {
        kern_pgdir[PDX(addr)] = PADDR((void*)addr) | PDE_ENTRY_1M | PDE_NONE_U;
f0100ebc:	e59f3fc8 	ldr	r3, [pc, #4040]	; f0101e8c <mem_init+0xfe8>
f0100ec0:	e7943003 	ldr	r3, [r4, r3]
f0100ec4:	e2832a03 	add	r2, r3, #12288	; 0x3000
f0100ec8:	e59f1fc0 	ldr	r1, [pc, #4032]	; f0101e90 <mem_init+0xfec>
f0100ecc:	e5821c00 	str	r1, [r2, #3072]	; 0xc00
        kern_pgdir[PDX(PADDR((void*)addr))] = 0;
f0100ed0:	e3a02000 	mov	r2, #0
f0100ed4:	e5832000 	str	r2, [r3]
{
    page_init();


    // map physical memory
    for (uintptr_t addr = KERNBASE; addr != 0; addr += PTSIZE) 
f0100ed8:	e59f3fb4 	ldr	r3, [pc, #4020]	; f0101e94 <mem_init+0xff0>
    {
        kern_pgdir[PDX(addr)] = PADDR((void*)addr) | PDE_ENTRY_1M | PDE_NONE_U;
        kern_pgdir[PDX(PADDR((void*)addr))] = 0;
f0100edc:	e1a0e002 	mov	lr, r2


    // map physical memory
    for (uintptr_t addr = KERNBASE; addr != 0; addr += PTSIZE) 
    {
        kern_pgdir[PDX(addr)] = PADDR((void*)addr) | PDE_ENTRY_1M | PDE_NONE_U;
f0100ee0:	e1a0ca23 	lsr	ip, r3, #20
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100ee4:	e3730211 	cmn	r3, #268435457	; 0x10000001
f0100ee8:	8a000005 	bhi	f0100f04 <mem_init+0x60>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100eec:	e59f0fa4 	ldr	r0, [pc, #4004]	; f0101e98 <mem_init+0xff4>
f0100ef0:	e08f0000 	add	r0, pc, r0
f0100ef4:	e3a0102e 	mov	r1, #46	; 0x2e
f0100ef8:	e59f2f9c 	ldr	r2, [pc, #3996]	; f0101e9c <mem_init+0xff8>
f0100efc:	e08f2002 	add	r2, pc, r2
f0100f00:	ebfffc68 	bl	f01000a8 <_panic>
f0100f04:	e2832201 	add	r2, r3, #268435456	; 0x10000000
f0100f08:	e59f1f7c 	ldr	r1, [pc, #3964]	; f0101e8c <mem_init+0xfe8>
f0100f0c:	e7940001 	ldr	r0, [r4, r1]
f0100f10:	e3821b01 	orr	r1, r2, #1024	; 0x400
f0100f14:	e3811002 	orr	r1, r1, #2
f0100f18:	e780110c 	str	r1, [r0, ip, lsl #2]
        kern_pgdir[PDX(PADDR((void*)addr))] = 0;
f0100f1c:	e1a02a22 	lsr	r2, r2, #20
f0100f20:	e780e102 	str	lr, [r0, r2, lsl #2]
{
    page_init();


    // map physical memory
    for (uintptr_t addr = KERNBASE; addr != 0; addr += PTSIZE) 
f0100f24:	e2933601 	adds	r3, r3, #1048576	; 0x100000
f0100f28:	1affffec 	bne	f0100ee0 <mem_init+0x3c>
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f2c:	e59f3f6c 	ldr	r3, [pc, #3948]	; f0101ea0 <mem_init+0xffc>
f0100f30:	e7943003 	ldr	r3, [r4, r3]
f0100f34:	e3730211 	cmn	r3, #268435457	; 0x10000001
f0100f38:	8a000007 	bhi	f0100f5c <mem_init+0xb8>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f3c:	e59f3f5c 	ldr	r3, [pc, #3932]	; f0101ea0 <mem_init+0xffc>
f0100f40:	e7943003 	ldr	r3, [r4, r3]
f0100f44:	e59f0f58 	ldr	r0, [pc, #3928]	; f0101ea4 <mem_init+0x1000>
f0100f48:	e08f0000 	add	r0, pc, r0
f0100f4c:	e3a01033 	mov	r1, #51	; 0x33
f0100f50:	e59f2f50 	ldr	r2, [pc, #3920]	; f0101ea8 <mem_init+0x1004>
f0100f54:	e08f2002 	add	r2, pc, r2
f0100f58:	ebfffc52 	bl	f01000a8 <_panic>
        kern_pgdir[PDX(addr)] = PADDR((void*)addr) | PDE_ENTRY_1M | PDE_NONE_U;
        kern_pgdir[PDX(PADDR((void*)addr))] = 0;
    }

    // map kernel stack
    kern_pgdir[PDX(KSTACKTOP - KSTKSIZE)] = PADDR(bootstack) | PDE_ENTRY_1M | PDE_NONE_U;
f0100f5c:	e59f2f28 	ldr	r2, [pc, #3880]	; f0101e8c <mem_init+0xfe8>
f0100f60:	e7942002 	ldr	r2, [r4, r2]
f0100f64:	e1a01002 	mov	r1, r2
f0100f68:	e50b2034 	str	r2, [fp, #-52]	; 0xffffffcc
f0100f6c:	e2822a03 	add	r2, r2, #12288	; 0x3000
	return (physaddr_t)kva - KERNBASE;
f0100f70:	e2833201 	add	r3, r3, #268435456	; 0x10000000
f0100f74:	e3833b01 	orr	r3, r3, #1024	; 0x400
f0100f78:	e3833002 	orr	r3, r3, #2
f0100f7c:	e5823bfc 	str	r3, [r2, #3068]	; 0xbfc

    // map gpio memory-map
    kern_pgdir[PDX(GPIOBASE)] = 0x3F200000 | PDE_ENTRY_1M | PDE_NONE_U;
f0100f80:	e59f3f24 	ldr	r3, [pc, #3876]	; f0101eac <mem_init+0x1008>
f0100f84:	e5823bf4 	str	r3, [r2, #3060]	; 0xbf4
#define PADDR(kva) _paddr(__FILE__, __LINE__, kva)

static inline physaddr_t
_paddr(const char *file, int line, void *kva)
{
	if ((uint32_t)kva < KERNBASE)
f0100f88:	e3710211 	cmn	r1, #268435457	; 0x10000001
f0100f8c:	8a000007 	bhi	f0100fb0 <mem_init+0x10c>
		_panic(file, line, "PADDR called with invalid kva %08lx", kva);
f0100f90:	e59f3ef4 	ldr	r3, [pc, #3828]	; f0101e8c <mem_init+0xfe8>
f0100f94:	e7943003 	ldr	r3, [r4, r3]
f0100f98:	e59f0f10 	ldr	r0, [pc, #3856]	; f0101eb0 <mem_init+0x100c>
f0100f9c:	e08f0000 	add	r0, pc, r0
f0100fa0:	e3a01039 	mov	r1, #57	; 0x39
f0100fa4:	e59f2f08 	ldr	r2, [pc, #3848]	; f0101eb4 <mem_init+0x1010>
f0100fa8:	e08f2002 	add	r2, pc, r2
f0100fac:	ebfffc3d 	bl	f01000a8 <_panic>
	return (physaddr_t)kva - KERNBASE;
f0100fb0:	e51b3034 	ldr	r3, [fp, #-52]	; 0xffffffcc
f0100fb4:	e2833201 	add	r3, r3, #268435456	; 0x10000000
#ifndef JOS_INC_ARM_H
#define JOS_INC_ARM_H

static inline void load_pgdir(uint32_t value) {
	asm volatile ("mcr p15, 0, %0, c2, c0, 0" : : "r"(value));
f0100fb8:	ee023f10 	mcr	15, 0, r3, cr2, cr0, {0}
static void check_page_installed_pgdir(void);

static void set_domain(int did, int priv) {
    int clear_bit = ~(11 << (2 * did));
    int new_priv = priv << (2 * did);
    asm("mrc p15, 0, r0, c3, c0, 0\n"
f0100fbc:	e3a02001 	mov	r2, #1
f0100fc0:	e3e0300b 	mvn	r3, #11
f0100fc4:	ee130f10 	mrc	15, 0, r0, cr3, cr0, {0}
f0100fc8:	e0000003 	and	r0, r0, r3
f0100fcc:	e1800002 	orr	r0, r0, r2
f0100fd0:	ee030f10 	mcr	15, 0, r0, cr3, cr0, {0}
    static void
check_page_free_list()
{
    int count = 0;

    for (struct PageInfo* pg = page_free_list; pg != NULL; pg = pg->pp_link) {
f0100fd4:	e59f3edc 	ldr	r3, [pc, #3804]	; f0101eb8 <mem_init+0x1014>
f0100fd8:	e08f3003 	add	r3, pc, r3
f0100fdc:	e5933000 	ldr	r3, [r3]
f0100fe0:	e3530000 	cmp	r3, #0
f0100fe4:	0a000014 	beq	f010103c <mem_init+0x198>
	assert(pg->pp_ref == 0);
f0100fe8:	e1d320b4 	ldrh	r2, [r3, #4]
f0100fec:	e3520000 	cmp	r2, #0
f0100ff0:	1a000003 	bne	f0101004 <mem_init+0x160>
f0100ff4:	ea00000a 	b	f0101024 <mem_init+0x180>
f0100ff8:	e1d310b4 	ldrh	r1, [r3, #4]
f0100ffc:	e3510000 	cmp	r1, #0
f0101000:	0a000007 	beq	f0101024 <mem_init+0x180>
f0101004:	e59f0eb0 	ldr	r0, [pc, #3760]	; f0101ebc <mem_init+0x1018>
f0101008:	e08f0000 	add	r0, pc, r0
f010100c:	e3a010dd 	mov	r1, #221	; 0xdd
f0101010:	e59f2ea8 	ldr	r2, [pc, #3752]	; f0101ec0 <mem_init+0x101c>
f0101014:	e08f2002 	add	r2, pc, r2
f0101018:	e59f3ea4 	ldr	r3, [pc, #3748]	; f0101ec4 <mem_init+0x1020>
f010101c:	e08f3003 	add	r3, pc, r3
f0101020:	ebfffc20 	bl	f01000a8 <_panic>
	count++;
f0101024:	e2822001 	add	r2, r2, #1
    static void
check_page_free_list()
{
    int count = 0;

    for (struct PageInfo* pg = page_free_list; pg != NULL; pg = pg->pp_link) {
f0101028:	e5933000 	ldr	r3, [r3]
f010102c:	e3530000 	cmp	r3, #0
f0101030:	1afffff0 	bne	f0100ff8 <mem_init+0x154>
	assert(pg->pp_ref == 0);
	count++;
    }
    assert(count > 0);
f0101034:	e3520000 	cmp	r2, #0
f0101038:	ca000007 	bgt	f010105c <mem_init+0x1b8>
f010103c:	e59f0e84 	ldr	r0, [pc, #3716]	; f0101ec8 <mem_init+0x1024>
f0101040:	e08f0000 	add	r0, pc, r0
f0101044:	e3a010e0 	mov	r1, #224	; 0xe0
f0101048:	e59f2e7c 	ldr	r2, [pc, #3708]	; f0101ecc <mem_init+0x1028>
f010104c:	e08f2002 	add	r2, pc, r2
f0101050:	e59f3e78 	ldr	r3, [pc, #3704]	; f0101ed0 <mem_init+0x102c>
f0101054:	e08f3003 	add	r3, pc, r3
f0101058:	ebfffc12 	bl	f01000a8 <_panic>
    cprintf("check_page_free_list() succeeded!\n");
f010105c:	e59f0e70 	ldr	r0, [pc, #3696]	; f0101ed4 <mem_init+0x1030>
f0101060:	e08f0000 	add	r0, pc, r0
f0101064:	ebfffdce 	bl	f01007a4 <cprintf>
    struct PageInfo *fl;
    char *c;
    int i;

    // check number of free pages
    for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101068:	e59f3e68 	ldr	r3, [pc, #3688]	; f0101ed8 <mem_init+0x1034>
f010106c:	e08f3003 	add	r3, pc, r3
f0101070:	e5933000 	ldr	r3, [r3]
f0101074:	e3530000 	cmp	r3, #0
f0101078:	0a000005 	beq	f0101094 <mem_init+0x1f0>
f010107c:	e3a06000 	mov	r6, #0
	++nfree;
f0101080:	e2866001 	add	r6, r6, #1
    struct PageInfo *fl;
    char *c;
    int i;

    // check number of free pages
    for (pp = page_free_list, nfree = 0; pp; pp = pp->pp_link)
f0101084:	e5933000 	ldr	r3, [r3]
f0101088:	e3530000 	cmp	r3, #0
f010108c:	1afffffb 	bne	f0101080 <mem_init+0x1dc>
f0101090:	ea000000 	b	f0101098 <mem_init+0x1f4>
f0101094:	e3a06000 	mov	r6, #0
	++nfree;

    // should be able to allocate three pages
    pp0 = pp1 = pp2 = 0;
    assert((pp0 = page_alloc(0)));
f0101098:	e3a00000 	mov	r0, #0
f010109c:	ebfffe5a 	bl	f0100a0c <page_alloc>
f01010a0:	e2508000 	subs	r8, r0, #0
f01010a4:	1a000007 	bne	f01010c8 <mem_init+0x224>
f01010a8:	e59f0e2c 	ldr	r0, [pc, #3628]	; f0101edc <mem_init+0x1038>
f01010ac:	e08f0000 	add	r0, pc, r0
f01010b0:	e3a010f7 	mov	r1, #247	; 0xf7
f01010b4:	e59f2e24 	ldr	r2, [pc, #3620]	; f0101ee0 <mem_init+0x103c>
f01010b8:	e08f2002 	add	r2, pc, r2
f01010bc:	e59f3e20 	ldr	r3, [pc, #3616]	; f0101ee4 <mem_init+0x1040>
f01010c0:	e08f3003 	add	r3, pc, r3
f01010c4:	ebfffbf7 	bl	f01000a8 <_panic>
    assert((pp1 = page_alloc(0)));
f01010c8:	e3a00000 	mov	r0, #0
f01010cc:	ebfffe4e 	bl	f0100a0c <page_alloc>
f01010d0:	e2507000 	subs	r7, r0, #0
f01010d4:	1a000007 	bne	f01010f8 <mem_init+0x254>
f01010d8:	e59f0e08 	ldr	r0, [pc, #3592]	; f0101ee8 <mem_init+0x1044>
f01010dc:	e08f0000 	add	r0, pc, r0
f01010e0:	e3a010f8 	mov	r1, #248	; 0xf8
f01010e4:	e59f2e00 	ldr	r2, [pc, #3584]	; f0101eec <mem_init+0x1048>
f01010e8:	e08f2002 	add	r2, pc, r2
f01010ec:	e59f3dfc 	ldr	r3, [pc, #3580]	; f0101ef0 <mem_init+0x104c>
f01010f0:	e08f3003 	add	r3, pc, r3
f01010f4:	ebfffbeb 	bl	f01000a8 <_panic>
    assert((pp2 = page_alloc(0)));
f01010f8:	e3a00000 	mov	r0, #0
f01010fc:	ebfffe42 	bl	f0100a0c <page_alloc>
f0101100:	e2505000 	subs	r5, r0, #0
f0101104:	1a000007 	bne	f0101128 <mem_init+0x284>
f0101108:	e59f0de4 	ldr	r0, [pc, #3556]	; f0101ef4 <mem_init+0x1050>
f010110c:	e08f0000 	add	r0, pc, r0
f0101110:	e3a010f9 	mov	r1, #249	; 0xf9
f0101114:	e59f2ddc 	ldr	r2, [pc, #3548]	; f0101ef8 <mem_init+0x1054>
f0101118:	e08f2002 	add	r2, pc, r2
f010111c:	e59f3dd8 	ldr	r3, [pc, #3544]	; f0101efc <mem_init+0x1058>
f0101120:	e08f3003 	add	r3, pc, r3
f0101124:	ebfffbdf 	bl	f01000a8 <_panic>

    assert(pp0);
    assert(pp1 && pp1 != pp0);
f0101128:	e1580007 	cmp	r8, r7
f010112c:	1a000007 	bne	f0101150 <mem_init+0x2ac>
f0101130:	e59f0dc8 	ldr	r0, [pc, #3528]	; f0101f00 <mem_init+0x105c>
f0101134:	e08f0000 	add	r0, pc, r0
f0101138:	e3a010fc 	mov	r1, #252	; 0xfc
f010113c:	e59f2dc0 	ldr	r2, [pc, #3520]	; f0101f04 <mem_init+0x1060>
f0101140:	e08f2002 	add	r2, pc, r2
f0101144:	e59f3dbc 	ldr	r3, [pc, #3516]	; f0101f08 <mem_init+0x1064>
f0101148:	e08f3003 	add	r3, pc, r3
f010114c:	ebfffbd5 	bl	f01000a8 <_panic>
    assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101150:	e1570005 	cmp	r7, r5
f0101154:	11580005 	cmpne	r8, r5
f0101158:	1a000007 	bne	f010117c <mem_init+0x2d8>
f010115c:	e59f0da8 	ldr	r0, [pc, #3496]	; f0101f0c <mem_init+0x1068>
f0101160:	e08f0000 	add	r0, pc, r0
f0101164:	e3a010fd 	mov	r1, #253	; 0xfd
f0101168:	e59f2da0 	ldr	r2, [pc, #3488]	; f0101f10 <mem_init+0x106c>
f010116c:	e08f2002 	add	r2, pc, r2
f0101170:	e59f3d9c 	ldr	r3, [pc, #3484]	; f0101f14 <mem_init+0x1070>
f0101174:	e08f3003 	add	r3, pc, r3
f0101178:	ebfffbca 	bl	f01000a8 <_panic>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f010117c:	e59f3d94 	ldr	r3, [pc, #3476]	; f0101f18 <mem_init+0x1074>
f0101180:	e7943003 	ldr	r3, [r4, r3]
f0101184:	e1a02003 	mov	r2, r3
f0101188:	e50b3030 	str	r3, [fp, #-48]	; 0xffffffd0
    assert(page2pa(pp0) < npages*PGSIZE);
f010118c:	e59f3d88 	ldr	r3, [pc, #3464]	; f0101f1c <mem_init+0x1078>
f0101190:	e7943003 	ldr	r3, [r4, r3]
f0101194:	e5933000 	ldr	r3, [r3]
f0101198:	e1a03603 	lsl	r3, r3, #12
f010119c:	e0622008 	rsb	r2, r2, r8
f01011a0:	e1a021c2 	asr	r2, r2, #3
f01011a4:	e1530602 	cmp	r3, r2, lsl #12
f01011a8:	8a000007 	bhi	f01011cc <mem_init+0x328>
f01011ac:	e59f0d6c 	ldr	r0, [pc, #3436]	; f0101f20 <mem_init+0x107c>
f01011b0:	e08f0000 	add	r0, pc, r0
f01011b4:	e3a010fe 	mov	r1, #254	; 0xfe
f01011b8:	e59f2d64 	ldr	r2, [pc, #3428]	; f0101f24 <mem_init+0x1080>
f01011bc:	e08f2002 	add	r2, pc, r2
f01011c0:	e59f3d60 	ldr	r3, [pc, #3424]	; f0101f28 <mem_init+0x1084>
f01011c4:	e08f3003 	add	r3, pc, r3
f01011c8:	ebfffbb6 	bl	f01000a8 <_panic>
f01011cc:	e51b2030 	ldr	r2, [fp, #-48]	; 0xffffffd0
f01011d0:	e0622007 	rsb	r2, r2, r7
f01011d4:	e1a021c2 	asr	r2, r2, #3
    assert(page2pa(pp1) < npages*PGSIZE);
f01011d8:	e1530602 	cmp	r3, r2, lsl #12
f01011dc:	8a000007 	bhi	f0101200 <mem_init+0x35c>
f01011e0:	e59f0d44 	ldr	r0, [pc, #3396]	; f0101f2c <mem_init+0x1088>
f01011e4:	e08f0000 	add	r0, pc, r0
f01011e8:	e3a010ff 	mov	r1, #255	; 0xff
f01011ec:	e59f2d3c 	ldr	r2, [pc, #3388]	; f0101f30 <mem_init+0x108c>
f01011f0:	e08f2002 	add	r2, pc, r2
f01011f4:	e59f3d38 	ldr	r3, [pc, #3384]	; f0101f34 <mem_init+0x1090>
f01011f8:	e08f3003 	add	r3, pc, r3
f01011fc:	ebfffba9 	bl	f01000a8 <_panic>
f0101200:	e51b2030 	ldr	r2, [fp, #-48]	; 0xffffffd0
f0101204:	e0622005 	rsb	r2, r2, r5
f0101208:	e1a021c2 	asr	r2, r2, #3
    assert(page2pa(pp2) < npages*PGSIZE);
f010120c:	e1530602 	cmp	r3, r2, lsl #12
f0101210:	8a000007 	bhi	f0101234 <mem_init+0x390>
f0101214:	e59f0d1c 	ldr	r0, [pc, #3356]	; f0101f38 <mem_init+0x1094>
f0101218:	e08f0000 	add	r0, pc, r0
f010121c:	e3a01c01 	mov	r1, #256	; 0x100
f0101220:	e59f2d14 	ldr	r2, [pc, #3348]	; f0101f3c <mem_init+0x1098>
f0101224:	e08f2002 	add	r2, pc, r2
f0101228:	e59f3d10 	ldr	r3, [pc, #3344]	; f0101f40 <mem_init+0x109c>
f010122c:	e08f3003 	add	r3, pc, r3
f0101230:	ebfffb9c 	bl	f01000a8 <_panic>

    // temporarily steal the rest of the free pages
    fl = page_free_list;
f0101234:	e59f3d08 	ldr	r3, [pc, #3336]	; f0101f44 <mem_init+0x10a0>
f0101238:	e08f3003 	add	r3, pc, r3
f010123c:	e5932000 	ldr	r2, [r3]
f0101240:	e50b2038 	str	r2, [fp, #-56]	; 0xffffffc8
    page_free_list = 0;
f0101244:	e3a00000 	mov	r0, #0
f0101248:	e5830000 	str	r0, [r3]

    // should be no free memory
    assert(!page_alloc(0));
f010124c:	ebfffdee 	bl	f0100a0c <page_alloc>
f0101250:	e3500000 	cmp	r0, #0
f0101254:	0a000007 	beq	f0101278 <mem_init+0x3d4>
f0101258:	e59f0ce8 	ldr	r0, [pc, #3304]	; f0101f48 <mem_init+0x10a4>
f010125c:	e08f0000 	add	r0, pc, r0
f0101260:	e59f1ce4 	ldr	r1, [pc, #3300]	; f0101f4c <mem_init+0x10a8>
f0101264:	e59f2ce4 	ldr	r2, [pc, #3300]	; f0101f50 <mem_init+0x10ac>
f0101268:	e08f2002 	add	r2, pc, r2
f010126c:	e59f3ce0 	ldr	r3, [pc, #3296]	; f0101f54 <mem_init+0x10b0>
f0101270:	e08f3003 	add	r3, pc, r3
f0101274:	ebfffb8b 	bl	f01000a8 <_panic>

    // free and re-allocate?
    page_free(pp0);
f0101278:	e1a00008 	mov	r0, r8
f010127c:	ebfffe10 	bl	f0100ac4 <page_free>
    page_free(pp1);
f0101280:	e1a00007 	mov	r0, r7
f0101284:	ebfffe0e 	bl	f0100ac4 <page_free>
    page_free(pp2);
f0101288:	e1a00005 	mov	r0, r5
f010128c:	ebfffe0c 	bl	f0100ac4 <page_free>
    pp0 = pp1 = pp2 = 0;
    assert((pp0 = page_alloc(0)));
f0101290:	e3a00000 	mov	r0, #0
f0101294:	ebfffddc 	bl	f0100a0c <page_alloc>
f0101298:	e2507000 	subs	r7, r0, #0
f010129c:	1a000007 	bne	f01012c0 <mem_init+0x41c>
f01012a0:	e59f0cb0 	ldr	r0, [pc, #3248]	; f0101f58 <mem_init+0x10b4>
f01012a4:	e08f0000 	add	r0, pc, r0
f01012a8:	e59f1cac 	ldr	r1, [pc, #3244]	; f0101f5c <mem_init+0x10b8>
f01012ac:	e59f2cac 	ldr	r2, [pc, #3244]	; f0101f60 <mem_init+0x10bc>
f01012b0:	e08f2002 	add	r2, pc, r2
f01012b4:	e59f3ca8 	ldr	r3, [pc, #3240]	; f0101f64 <mem_init+0x10c0>
f01012b8:	e08f3003 	add	r3, pc, r3
f01012bc:	ebfffb79 	bl	f01000a8 <_panic>
    assert((pp1 = page_alloc(0)));
f01012c0:	e3a00000 	mov	r0, #0
f01012c4:	ebfffdd0 	bl	f0100a0c <page_alloc>
f01012c8:	e2509000 	subs	r9, r0, #0
f01012cc:	1a000007 	bne	f01012f0 <mem_init+0x44c>
f01012d0:	e59f0c90 	ldr	r0, [pc, #3216]	; f0101f68 <mem_init+0x10c4>
f01012d4:	e08f0000 	add	r0, pc, r0
f01012d8:	e59f1c8c 	ldr	r1, [pc, #3212]	; f0101f6c <mem_init+0x10c8>
f01012dc:	e59f2c8c 	ldr	r2, [pc, #3212]	; f0101f70 <mem_init+0x10cc>
f01012e0:	e08f2002 	add	r2, pc, r2
f01012e4:	e59f3c88 	ldr	r3, [pc, #3208]	; f0101f74 <mem_init+0x10d0>
f01012e8:	e08f3003 	add	r3, pc, r3
f01012ec:	ebfffb6d 	bl	f01000a8 <_panic>
    assert((pp2 = page_alloc(0)));
f01012f0:	e3a00000 	mov	r0, #0
f01012f4:	ebfffdc4 	bl	f0100a0c <page_alloc>
f01012f8:	e2508000 	subs	r8, r0, #0
f01012fc:	1a000007 	bne	f0101320 <mem_init+0x47c>
f0101300:	e59f0c70 	ldr	r0, [pc, #3184]	; f0101f78 <mem_init+0x10d4>
f0101304:	e08f0000 	add	r0, pc, r0
f0101308:	e3a01e11 	mov	r1, #272	; 0x110
f010130c:	e59f2c68 	ldr	r2, [pc, #3176]	; f0101f7c <mem_init+0x10d8>
f0101310:	e08f2002 	add	r2, pc, r2
f0101314:	e59f3c64 	ldr	r3, [pc, #3172]	; f0101f80 <mem_init+0x10dc>
f0101318:	e08f3003 	add	r3, pc, r3
f010131c:	ebfffb61 	bl	f01000a8 <_panic>
    assert(pp0);
    assert(pp1 && pp1 != pp0);
f0101320:	e1570009 	cmp	r7, r9
f0101324:	1a000007 	bne	f0101348 <mem_init+0x4a4>
f0101328:	e59f0c54 	ldr	r0, [pc, #3156]	; f0101f84 <mem_init+0x10e0>
f010132c:	e08f0000 	add	r0, pc, r0
f0101330:	e59f1c50 	ldr	r1, [pc, #3152]	; f0101f88 <mem_init+0x10e4>
f0101334:	e59f2c50 	ldr	r2, [pc, #3152]	; f0101f8c <mem_init+0x10e8>
f0101338:	e08f2002 	add	r2, pc, r2
f010133c:	e59f3c4c 	ldr	r3, [pc, #3148]	; f0101f90 <mem_init+0x10ec>
f0101340:	e08f3003 	add	r3, pc, r3
f0101344:	ebfffb57 	bl	f01000a8 <_panic>
    assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101348:	e1590008 	cmp	r9, r8
f010134c:	11570008 	cmpne	r7, r8
f0101350:	1a000007 	bne	f0101374 <mem_init+0x4d0>
f0101354:	e59f0c38 	ldr	r0, [pc, #3128]	; f0101f94 <mem_init+0x10f0>
f0101358:	e08f0000 	add	r0, pc, r0
f010135c:	e59f1c34 	ldr	r1, [pc, #3124]	; f0101f98 <mem_init+0x10f4>
f0101360:	e59f2c34 	ldr	r2, [pc, #3124]	; f0101f9c <mem_init+0x10f8>
f0101364:	e08f2002 	add	r2, pc, r2
f0101368:	e59f3c30 	ldr	r3, [pc, #3120]	; f0101fa0 <mem_init+0x10fc>
f010136c:	e08f3003 	add	r3, pc, r3
f0101370:	ebfffb4c 	bl	f01000a8 <_panic>
    assert(!page_alloc(0));
f0101374:	e3a00000 	mov	r0, #0
f0101378:	ebfffda3 	bl	f0100a0c <page_alloc>
f010137c:	e3500000 	cmp	r0, #0
f0101380:	0a000007 	beq	f01013a4 <mem_init+0x500>
f0101384:	e59f0c18 	ldr	r0, [pc, #3096]	; f0101fa4 <mem_init+0x1100>
f0101388:	e08f0000 	add	r0, pc, r0
f010138c:	e3a01f45 	mov	r1, #276	; 0x114
f0101390:	e59f2c10 	ldr	r2, [pc, #3088]	; f0101fa8 <mem_init+0x1104>
f0101394:	e08f2002 	add	r2, pc, r2
f0101398:	e59f3c0c 	ldr	r3, [pc, #3084]	; f0101fac <mem_init+0x1108>
f010139c:	e08f3003 	add	r3, pc, r3
f01013a0:	ebfffb40 	bl	f01000a8 <_panic>
f01013a4:	e51b3030 	ldr	r3, [fp, #-48]	; 0xffffffd0
f01013a8:	e0635007 	rsb	r5, r3, r7
f01013ac:	e1a051c5 	asr	r5, r5, #3
f01013b0:	e1a05605 	lsl	r5, r5, #12
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01013b4:	e1a0a625 	lsr	sl, r5, #12
f01013b8:	e59f3b5c 	ldr	r3, [pc, #2908]	; f0101f1c <mem_init+0x1078>
f01013bc:	e7943003 	ldr	r3, [r4, r3]
f01013c0:	e5933000 	ldr	r3, [r3]
f01013c4:	e15a0003 	cmp	sl, r3
f01013c8:	3a000006 	bcc	f01013e8 <mem_init+0x544>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01013cc:	e59f0bdc 	ldr	r0, [pc, #3036]	; f0101fb0 <mem_init+0x110c>
f01013d0:	e08f0000 	add	r0, pc, r0
f01013d4:	e3a0104f 	mov	r1, #79	; 0x4f
f01013d8:	e59f2bd4 	ldr	r2, [pc, #3028]	; f0101fb4 <mem_init+0x1110>
f01013dc:	e08f2002 	add	r2, pc, r2
f01013e0:	e1a03005 	mov	r3, r5
f01013e4:	ebfffb2f 	bl	f01000a8 <_panic>
	return (void *)(pa + KERNBASE);
f01013e8:	e285320f 	add	r3, r5, #-268435456	; 0xf0000000
f01013ec:	e50b303c 	str	r3, [fp, #-60]	; 0xffffffc4

    // test flags
    memset(page2kva(pp0), 1, PGSIZE);
f01013f0:	e1a00003 	mov	r0, r3
f01013f4:	e3a01001 	mov	r1, #1
f01013f8:	e3a02a01 	mov	r2, #4096	; 0x1000
f01013fc:	eb000ab4 	bl	f0103ed4 <memset>
    page_free(pp0);
f0101400:	e1a00007 	mov	r0, r7
f0101404:	ebfffdae 	bl	f0100ac4 <page_free>
    assert((pp = page_alloc(ALLOC_ZERO)));
f0101408:	e3a00001 	mov	r0, #1
f010140c:	ebfffd7e 	bl	f0100a0c <page_alloc>
f0101410:	e3500000 	cmp	r0, #0
f0101414:	1a000007 	bne	f0101438 <mem_init+0x594>
f0101418:	e59f0b98 	ldr	r0, [pc, #2968]	; f0101fb8 <mem_init+0x1114>
f010141c:	e08f0000 	add	r0, pc, r0
f0101420:	e59f1b94 	ldr	r1, [pc, #2964]	; f0101fbc <mem_init+0x1118>
f0101424:	e59f2b94 	ldr	r2, [pc, #2964]	; f0101fc0 <mem_init+0x111c>
f0101428:	e08f2002 	add	r2, pc, r2
f010142c:	e59f3b90 	ldr	r3, [pc, #2960]	; f0101fc4 <mem_init+0x1120>
f0101430:	e08f3003 	add	r3, pc, r3
f0101434:	ebfffb1b 	bl	f01000a8 <_panic>
    assert(pp && pp0 == pp);
f0101438:	e1570000 	cmp	r7, r0
f010143c:	0a000007 	beq	f0101460 <mem_init+0x5bc>
f0101440:	e59f0b80 	ldr	r0, [pc, #2944]	; f0101fc8 <mem_init+0x1124>
f0101444:	e08f0000 	add	r0, pc, r0
f0101448:	e59f1b7c 	ldr	r1, [pc, #2940]	; f0101fcc <mem_init+0x1128>
f010144c:	e59f2b7c 	ldr	r2, [pc, #2940]	; f0101fd0 <mem_init+0x112c>
f0101450:	e08f2002 	add	r2, pc, r2
f0101454:	e59f3b78 	ldr	r3, [pc, #2936]	; f0101fd4 <mem_init+0x1130>
f0101458:	e08f3003 	add	r3, pc, r3
f010145c:	ebfffb11 	bl	f01000a8 <_panic>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101460:	e59f3ab4 	ldr	r3, [pc, #2740]	; f0101f1c <mem_init+0x1078>
f0101464:	e7943003 	ldr	r3, [r4, r3]
f0101468:	e5933000 	ldr	r3, [r3]
f010146c:	e15a0003 	cmp	sl, r3
f0101470:	3a000006 	bcc	f0101490 <mem_init+0x5ec>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101474:	e59f0b5c 	ldr	r0, [pc, #2908]	; f0101fd8 <mem_init+0x1134>
f0101478:	e08f0000 	add	r0, pc, r0
f010147c:	e3a0104f 	mov	r1, #79	; 0x4f
f0101480:	e59f2b54 	ldr	r2, [pc, #2900]	; f0101fdc <mem_init+0x1138>
f0101484:	e08f2002 	add	r2, pc, r2
f0101488:	e1a03005 	mov	r3, r5
f010148c:	ebfffb05 	bl	f01000a8 <_panic>
    c = page2kva(pp);
    for (i = 0; i < PGSIZE; i++)
	assert(c[i] == 0);
f0101490:	e51b203c 	ldr	r2, [fp, #-60]	; 0xffffffc4
f0101494:	e5d23000 	ldrb	r3, [r2]
f0101498:	e3530000 	cmp	r3, #0
f010149c:	1a000005 	bne	f01014b8 <mem_init+0x614>
f01014a0:	e2851eff 	add	r1, r5, #4080	; 0xff0
f01014a4:	e28112ff 	add	r1, r1, #-268435441	; 0xf000000f
f01014a8:	e1a03002 	mov	r3, r2
f01014ac:	e5f32001 	ldrb	r2, [r3, #1]!
f01014b0:	e3520000 	cmp	r2, #0
f01014b4:	0a000007 	beq	f01014d8 <mem_init+0x634>
f01014b8:	e59f0b20 	ldr	r0, [pc, #2848]	; f0101fe0 <mem_init+0x113c>
f01014bc:	e08f0000 	add	r0, pc, r0
f01014c0:	e59f1b1c 	ldr	r1, [pc, #2844]	; f0101fe4 <mem_init+0x1140>
f01014c4:	e59f2b1c 	ldr	r2, [pc, #2844]	; f0101fe8 <mem_init+0x1144>
f01014c8:	e08f2002 	add	r2, pc, r2
f01014cc:	e59f3b18 	ldr	r3, [pc, #2840]	; f0101fec <mem_init+0x1148>
f01014d0:	e08f3003 	add	r3, pc, r3
f01014d4:	ebfffaf3 	bl	f01000a8 <_panic>
    memset(page2kva(pp0), 1, PGSIZE);
    page_free(pp0);
    assert((pp = page_alloc(ALLOC_ZERO)));
    assert(pp && pp0 == pp);
    c = page2kva(pp);
    for (i = 0; i < PGSIZE; i++)
f01014d8:	e1530001 	cmp	r3, r1
f01014dc:	1afffff2 	bne	f01014ac <mem_init+0x608>
	assert(c[i] == 0);

    // give free list back
    page_free_list = fl;
f01014e0:	e59f5b08 	ldr	r5, [pc, #2824]	; f0101ff0 <mem_init+0x114c>
f01014e4:	e08f5005 	add	r5, pc, r5
f01014e8:	e51b3038 	ldr	r3, [fp, #-56]	; 0xffffffc8
f01014ec:	e5853000 	str	r3, [r5]

    // free the pages we took
    page_free(pp0);
f01014f0:	e1a00007 	mov	r0, r7
f01014f4:	ebfffd72 	bl	f0100ac4 <page_free>
    page_free(pp1);
f01014f8:	e1a00009 	mov	r0, r9
f01014fc:	ebfffd70 	bl	f0100ac4 <page_free>
    page_free(pp2);
f0101500:	e1a00008 	mov	r0, r8
f0101504:	ebfffd6e 	bl	f0100ac4 <page_free>

    // number of free pages should be the same
    for (pp = page_free_list; pp; pp = pp->pp_link)
f0101508:	e5953000 	ldr	r3, [r5]
f010150c:	e3530000 	cmp	r3, #0
f0101510:	0a000003 	beq	f0101524 <mem_init+0x680>
	--nfree;
f0101514:	e2466001 	sub	r6, r6, #1
    page_free(pp0);
    page_free(pp1);
    page_free(pp2);

    // number of free pages should be the same
    for (pp = page_free_list; pp; pp = pp->pp_link)
f0101518:	e5933000 	ldr	r3, [r3]
f010151c:	e3530000 	cmp	r3, #0
f0101520:	1afffffb 	bne	f0101514 <mem_init+0x670>
	--nfree;
    assert(nfree == 0);
f0101524:	e3560000 	cmp	r6, #0
f0101528:	0a000007 	beq	f010154c <mem_init+0x6a8>
f010152c:	e59f0ac0 	ldr	r0, [pc, #2752]	; f0101ff4 <mem_init+0x1150>
f0101530:	e08f0000 	add	r0, pc, r0
f0101534:	e59f1abc 	ldr	r1, [pc, #2748]	; f0101ff8 <mem_init+0x1154>
f0101538:	e59f2abc 	ldr	r2, [pc, #2748]	; f0101ffc <mem_init+0x1158>
f010153c:	e08f2002 	add	r2, pc, r2
f0101540:	e59f3ab8 	ldr	r3, [pc, #2744]	; f0102000 <mem_init+0x115c>
f0101544:	e08f3003 	add	r3, pc, r3
f0101548:	ebfffad6 	bl	f01000a8 <_panic>

    cprintf("check_page_alloc() succeeded!\n");
f010154c:	e59f0ab0 	ldr	r0, [pc, #2736]	; f0102004 <mem_init+0x1160>
f0101550:	e08f0000 	add	r0, pc, r0
f0101554:	ebfffc92 	bl	f01007a4 <cprintf>
       int i;
       extern pde_t entry_pgdir[];

    // should be able to allocate three pages
    pp0 = pp1 = pp2 = 0;
    assert((pp0 = page_alloc(0)));
f0101558:	e3a00000 	mov	r0, #0
f010155c:	ebfffd2a 	bl	f0100a0c <page_alloc>
f0101560:	e2508000 	subs	r8, r0, #0
f0101564:	1a000007 	bne	f0101588 <mem_init+0x6e4>
f0101568:	e59f0a98 	ldr	r0, [pc, #2712]	; f0102008 <mem_init+0x1164>
f010156c:	e08f0000 	add	r0, pc, r0
f0101570:	e59f1a94 	ldr	r1, [pc, #2708]	; f010200c <mem_init+0x1168>
f0101574:	e59f2a94 	ldr	r2, [pc, #2708]	; f0102010 <mem_init+0x116c>
f0101578:	e08f2002 	add	r2, pc, r2
f010157c:	e59f3a90 	ldr	r3, [pc, #2704]	; f0102014 <mem_init+0x1170>
f0101580:	e08f3003 	add	r3, pc, r3
f0101584:	ebfffac7 	bl	f01000a8 <_panic>
    assert((pp1 = page_alloc(0)));
f0101588:	e3a00000 	mov	r0, #0
f010158c:	ebfffd1e 	bl	f0100a0c <page_alloc>
f0101590:	e2507000 	subs	r7, r0, #0
f0101594:	1a000007 	bne	f01015b8 <mem_init+0x714>
f0101598:	e59f0a78 	ldr	r0, [pc, #2680]	; f0102018 <mem_init+0x1174>
f010159c:	e08f0000 	add	r0, pc, r0
f01015a0:	e3a01f65 	mov	r1, #404	; 0x194
f01015a4:	e59f2a70 	ldr	r2, [pc, #2672]	; f010201c <mem_init+0x1178>
f01015a8:	e08f2002 	add	r2, pc, r2
f01015ac:	e59f3a6c 	ldr	r3, [pc, #2668]	; f0102020 <mem_init+0x117c>
f01015b0:	e08f3003 	add	r3, pc, r3
f01015b4:	ebfffabb 	bl	f01000a8 <_panic>
    assert((pp2 = page_alloc(0)));
f01015b8:	e3a00000 	mov	r0, #0
f01015bc:	ebfffd12 	bl	f0100a0c <page_alloc>
f01015c0:	e2506000 	subs	r6, r0, #0
f01015c4:	1a000007 	bne	f01015e8 <mem_init+0x744>
f01015c8:	e59f0a54 	ldr	r0, [pc, #2644]	; f0102024 <mem_init+0x1180>
f01015cc:	e08f0000 	add	r0, pc, r0
f01015d0:	e59f1a50 	ldr	r1, [pc, #2640]	; f0102028 <mem_init+0x1184>
f01015d4:	e59f2a50 	ldr	r2, [pc, #2640]	; f010202c <mem_init+0x1188>
f01015d8:	e08f2002 	add	r2, pc, r2
f01015dc:	e59f3a4c 	ldr	r3, [pc, #2636]	; f0102030 <mem_init+0x118c>
f01015e0:	e08f3003 	add	r3, pc, r3
f01015e4:	ebfffaaf 	bl	f01000a8 <_panic>

    assert(pp0);
    assert(pp1 && pp1 != pp0);
f01015e8:	e1580007 	cmp	r8, r7
f01015ec:	1a000007 	bne	f0101610 <mem_init+0x76c>
f01015f0:	e59f0a3c 	ldr	r0, [pc, #2620]	; f0102034 <mem_init+0x1190>
f01015f4:	e08f0000 	add	r0, pc, r0
f01015f8:	e3a01f66 	mov	r1, #408	; 0x198
f01015fc:	e59f2a34 	ldr	r2, [pc, #2612]	; f0102038 <mem_init+0x1194>
f0101600:	e08f2002 	add	r2, pc, r2
f0101604:	e59f3a30 	ldr	r3, [pc, #2608]	; f010203c <mem_init+0x1198>
f0101608:	e08f3003 	add	r3, pc, r3
f010160c:	ebfffaa5 	bl	f01000a8 <_panic>
    assert(pp2 && pp2 != pp1 && pp2 != pp0);
f0101610:	e1570006 	cmp	r7, r6
f0101614:	11580006 	cmpne	r8, r6
f0101618:	1a000007 	bne	f010163c <mem_init+0x798>
f010161c:	e59f0a1c 	ldr	r0, [pc, #2588]	; f0102040 <mem_init+0x119c>
f0101620:	e08f0000 	add	r0, pc, r0
f0101624:	e59f1a18 	ldr	r1, [pc, #2584]	; f0102044 <mem_init+0x11a0>
f0101628:	e59f2a18 	ldr	r2, [pc, #2584]	; f0102048 <mem_init+0x11a4>
f010162c:	e08f2002 	add	r2, pc, r2
f0101630:	e59f3a14 	ldr	r3, [pc, #2580]	; f010204c <mem_init+0x11a8>
f0101634:	e08f3003 	add	r3, pc, r3
f0101638:	ebfffa9a 	bl	f01000a8 <_panic>

    // temporarily steal the rest of the free pages
    fl = page_free_list;
f010163c:	e59f3a0c 	ldr	r3, [pc, #2572]	; f0102050 <mem_init+0x11ac>
f0101640:	e08f3003 	add	r3, pc, r3
f0101644:	e5932000 	ldr	r2, [r3]
f0101648:	e50b203c 	str	r2, [fp, #-60]	; 0xffffffc4
    page_free_list = 0;
f010164c:	e3a00000 	mov	r0, #0
f0101650:	e5830000 	str	r0, [r3]

    // should be no free memory
    assert(!page_alloc(0));
f0101654:	ebfffcec 	bl	f0100a0c <page_alloc>
f0101658:	e3500000 	cmp	r0, #0
f010165c:	0a000007 	beq	f0101680 <mem_init+0x7dc>
f0101660:	e59f09ec 	ldr	r0, [pc, #2540]	; f0102054 <mem_init+0x11b0>
f0101664:	e08f0000 	add	r0, pc, r0
f0101668:	e3a01e1a 	mov	r1, #416	; 0x1a0
f010166c:	e59f29e4 	ldr	r2, [pc, #2532]	; f0102058 <mem_init+0x11b4>
f0101670:	e08f2002 	add	r2, pc, r2
f0101674:	e59f39e0 	ldr	r3, [pc, #2528]	; f010205c <mem_init+0x11b8>
f0101678:	e08f3003 	add	r3, pc, r3
f010167c:	ebfffa89 	bl	f01000a8 <_panic>

    // there is no page allocated at address 0
    assert(page_lookup(kern_pgdir, (void *) 0x0, &ptep) == NULL);
f0101680:	e59f3804 	ldr	r3, [pc, #2052]	; f0101e8c <mem_init+0xfe8>
f0101684:	e7943003 	ldr	r3, [r4, r3]
f0101688:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f010168c:	e1a00003 	mov	r0, r3
f0101690:	e3a01000 	mov	r1, #0
f0101694:	e24b2028 	sub	r2, fp, #40	; 0x28
f0101698:	ebfffd8a 	bl	f0100cc8 <page_lookup>
f010169c:	e3500000 	cmp	r0, #0
f01016a0:	0a000007 	beq	f01016c4 <mem_init+0x820>
f01016a4:	e59f09b4 	ldr	r0, [pc, #2484]	; f0102060 <mem_init+0x11bc>
f01016a8:	e08f0000 	add	r0, pc, r0
f01016ac:	e59f19b0 	ldr	r1, [pc, #2480]	; f0102064 <mem_init+0x11c0>
f01016b0:	e59f29b0 	ldr	r2, [pc, #2480]	; f0102068 <mem_init+0x11c4>
f01016b4:	e08f2002 	add	r2, pc, r2
f01016b8:	e59f39ac 	ldr	r3, [pc, #2476]	; f010206c <mem_init+0x11c8>
f01016bc:	e08f3003 	add	r3, pc, r3
f01016c0:	ebfffa78 	bl	f01000a8 <_panic>

    // there is no free memory, so we can't allocate a page table
    assert(page_insert(kern_pgdir, pp1, 0x0, PTE_NONE_U) < 0);
f01016c4:	e59f37c0 	ldr	r3, [pc, #1984]	; f0101e8c <mem_init+0xfe8>
f01016c8:	e7943003 	ldr	r3, [r4, r3]
f01016cc:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f01016d0:	e1a00003 	mov	r0, r3
f01016d4:	e1a01007 	mov	r1, r7
f01016d8:	e3a02000 	mov	r2, #0
f01016dc:	e3a03010 	mov	r3, #16
f01016e0:	ebfffdbd 	bl	f0100ddc <page_insert>
f01016e4:	e3500000 	cmp	r0, #0
f01016e8:	ba000007 	blt	f010170c <mem_init+0x868>
f01016ec:	e59f097c 	ldr	r0, [pc, #2428]	; f0102070 <mem_init+0x11cc>
f01016f0:	e08f0000 	add	r0, pc, r0
f01016f4:	e59f1978 	ldr	r1, [pc, #2424]	; f0102074 <mem_init+0x11d0>
f01016f8:	e59f2978 	ldr	r2, [pc, #2424]	; f0102078 <mem_init+0x11d4>
f01016fc:	e08f2002 	add	r2, pc, r2
f0101700:	e59f3974 	ldr	r3, [pc, #2420]	; f010207c <mem_init+0x11d8>
f0101704:	e08f3003 	add	r3, pc, r3
f0101708:	ebfffa66 	bl	f01000a8 <_panic>

    // free pp0 and try again: pp0 should be used for page table
    page_free(pp0);
f010170c:	e1a00008 	mov	r0, r8
f0101710:	ebfffceb 	bl	f0100ac4 <page_free>
    assert(page_insert(kern_pgdir, pp1, 0x0, PTE_NONE_U) == 0);
f0101714:	e59f3770 	ldr	r3, [pc, #1904]	; f0101e8c <mem_init+0xfe8>
f0101718:	e7943003 	ldr	r3, [r4, r3]
f010171c:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101720:	e1a00003 	mov	r0, r3
f0101724:	e1a01007 	mov	r1, r7
f0101728:	e3a02000 	mov	r2, #0
f010172c:	e3a03010 	mov	r3, #16
f0101730:	ebfffda9 	bl	f0100ddc <page_insert>
f0101734:	e3500000 	cmp	r0, #0
f0101738:	0a000007 	beq	f010175c <mem_init+0x8b8>
f010173c:	e59f093c 	ldr	r0, [pc, #2364]	; f0102080 <mem_init+0x11dc>
f0101740:	e08f0000 	add	r0, pc, r0
f0101744:	e59f1938 	ldr	r1, [pc, #2360]	; f0102084 <mem_init+0x11e0>
f0101748:	e59f2938 	ldr	r2, [pc, #2360]	; f0102088 <mem_init+0x11e4>
f010174c:	e08f2002 	add	r2, pc, r2
f0101750:	e59f3934 	ldr	r3, [pc, #2356]	; f010208c <mem_init+0x11e8>
f0101754:	e08f3003 	add	r3, pc, r3
f0101758:	ebfffa52 	bl	f01000a8 <_panic>
    assert(PTE_SMALL_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010175c:	e59f3728 	ldr	r3, [pc, #1832]	; f0101e8c <mem_init+0xfe8>
f0101760:	e7943003 	ldr	r3, [r4, r3]
f0101764:	e593a000 	ldr	sl, [r3]
f0101768:	e3caaeff 	bic	sl, sl, #4080	; 0xff0
f010176c:	e3caa00f 	bic	sl, sl, #15
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0101770:	e51b3030 	ldr	r3, [fp, #-48]	; 0xffffffd0
f0101774:	e0633008 	rsb	r3, r3, r8
f0101778:	e1a031c3 	asr	r3, r3, #3
f010177c:	e15a0603 	cmp	sl, r3, lsl #12
f0101780:	0a000007 	beq	f01017a4 <mem_init+0x900>
f0101784:	e59f0904 	ldr	r0, [pc, #2308]	; f0102090 <mem_init+0x11ec>
f0101788:	e08f0000 	add	r0, pc, r0
f010178c:	e59f1900 	ldr	r1, [pc, #2304]	; f0102094 <mem_init+0x11f0>
f0101790:	e59f2900 	ldr	r2, [pc, #2304]	; f0102098 <mem_init+0x11f4>
f0101794:	e08f2002 	add	r2, pc, r2
f0101798:	e59f38fc 	ldr	r3, [pc, #2300]	; f010209c <mem_init+0x11f8>
f010179c:	e08f3003 	add	r3, pc, r3
f01017a0:	ebfffa40 	bl	f01000a8 <_panic>
    assert(check_va2pa(kern_pgdir, 0x0) == page2pa(pp1));
f01017a4:	e59f36e0 	ldr	r3, [pc, #1760]	; f0101e8c <mem_init+0xfe8>
f01017a8:	e7943003 	ldr	r3, [r4, r3]
f01017ac:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f01017b0:	e1a00003 	mov	r0, r3
f01017b4:	e3a01000 	mov	r1, #0
f01017b8:	ebfffc05 	bl	f01007d4 <check_va2pa>
f01017bc:	e1a09000 	mov	r9, r0
f01017c0:	e51b3030 	ldr	r3, [fp, #-48]	; 0xffffffd0
f01017c4:	e0633007 	rsb	r3, r3, r7
f01017c8:	e1a031c3 	asr	r3, r3, #3
f01017cc:	e1500603 	cmp	r0, r3, lsl #12
f01017d0:	0a000007 	beq	f01017f4 <mem_init+0x950>
f01017d4:	e59f08c4 	ldr	r0, [pc, #2244]	; f01020a0 <mem_init+0x11fc>
f01017d8:	e08f0000 	add	r0, pc, r0
f01017dc:	e3a01f6b 	mov	r1, #428	; 0x1ac
f01017e0:	e59f28bc 	ldr	r2, [pc, #2236]	; f01020a4 <mem_init+0x1200>
f01017e4:	e08f2002 	add	r2, pc, r2
f01017e8:	e59f38b8 	ldr	r3, [pc, #2232]	; f01020a8 <mem_init+0x1204>
f01017ec:	e08f3003 	add	r3, pc, r3
f01017f0:	ebfffa2c 	bl	f01000a8 <_panic>
    assert(pp1->pp_ref == 1);
f01017f4:	e1d730b4 	ldrh	r3, [r7, #4]
f01017f8:	e3530001 	cmp	r3, #1
f01017fc:	0a000007 	beq	f0101820 <mem_init+0x97c>
f0101800:	e59f08a4 	ldr	r0, [pc, #2212]	; f01020ac <mem_init+0x1208>
f0101804:	e08f0000 	add	r0, pc, r0
f0101808:	e59f18a0 	ldr	r1, [pc, #2208]	; f01020b0 <mem_init+0x120c>
f010180c:	e59f28a0 	ldr	r2, [pc, #2208]	; f01020b4 <mem_init+0x1210>
f0101810:	e08f2002 	add	r2, pc, r2
f0101814:	e59f389c 	ldr	r3, [pc, #2204]	; f01020b8 <mem_init+0x1214>
f0101818:	e08f3003 	add	r3, pc, r3
f010181c:	ebfffa21 	bl	f01000a8 <_panic>
    assert(pp0->pp_ref == 1);
f0101820:	e1d830b4 	ldrh	r3, [r8, #4]
f0101824:	e3530001 	cmp	r3, #1
f0101828:	0a000007 	beq	f010184c <mem_init+0x9a8>
f010182c:	e59f0888 	ldr	r0, [pc, #2184]	; f01020bc <mem_init+0x1218>
f0101830:	e08f0000 	add	r0, pc, r0
f0101834:	e59f1884 	ldr	r1, [pc, #2180]	; f01020c0 <mem_init+0x121c>
f0101838:	e59f2884 	ldr	r2, [pc, #2180]	; f01020c4 <mem_init+0x1220>
f010183c:	e08f2002 	add	r2, pc, r2
f0101840:	e59f3880 	ldr	r3, [pc, #2176]	; f01020c8 <mem_init+0x1224>
f0101844:	e08f3003 	add	r3, pc, r3
f0101848:	ebfffa16 	bl	f01000a8 <_panic>

    // should be able to map pp2 at PGSIZE because pp0 is already allocated for page table
    assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_NONE_U) == 0);
f010184c:	e59f3638 	ldr	r3, [pc, #1592]	; f0101e8c <mem_init+0xfe8>
f0101850:	e7943003 	ldr	r3, [r4, r3]
f0101854:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101858:	e1a00003 	mov	r0, r3
f010185c:	e1a01006 	mov	r1, r6
f0101860:	e3a02a01 	mov	r2, #4096	; 0x1000
f0101864:	e3a03010 	mov	r3, #16
f0101868:	ebfffd5b 	bl	f0100ddc <page_insert>
f010186c:	e3500000 	cmp	r0, #0
f0101870:	0a000007 	beq	f0101894 <mem_init+0x9f0>
f0101874:	e59f0850 	ldr	r0, [pc, #2128]	; f01020cc <mem_init+0x1228>
f0101878:	e08f0000 	add	r0, pc, r0
f010187c:	e59f184c 	ldr	r1, [pc, #2124]	; f01020d0 <mem_init+0x122c>
f0101880:	e59f284c 	ldr	r2, [pc, #2124]	; f01020d4 <mem_init+0x1230>
f0101884:	e08f2002 	add	r2, pc, r2
f0101888:	e59f3848 	ldr	r3, [pc, #2120]	; f01020d8 <mem_init+0x1234>
f010188c:	e08f3003 	add	r3, pc, r3
f0101890:	ebfffa04 	bl	f01000a8 <_panic>
    assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101894:	e59f35f0 	ldr	r3, [pc, #1520]	; f0101e8c <mem_init+0xfe8>
f0101898:	e7943003 	ldr	r3, [r4, r3]
f010189c:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f01018a0:	e1a00003 	mov	r0, r3
f01018a4:	e3a01a01 	mov	r1, #4096	; 0x1000
f01018a8:	ebfffbc9 	bl	f01007d4 <check_va2pa>
f01018ac:	e1a05000 	mov	r5, r0
f01018b0:	e51b3030 	ldr	r3, [fp, #-48]	; 0xffffffd0
f01018b4:	e0633006 	rsb	r3, r3, r6
f01018b8:	e1a031c3 	asr	r3, r3, #3
f01018bc:	e1500603 	cmp	r0, r3, lsl #12
f01018c0:	0a000007 	beq	f01018e4 <mem_init+0xa40>
f01018c4:	e59f0810 	ldr	r0, [pc, #2064]	; f01020dc <mem_init+0x1238>
f01018c8:	e08f0000 	add	r0, pc, r0
f01018cc:	e59f180c 	ldr	r1, [pc, #2060]	; f01020e0 <mem_init+0x123c>
f01018d0:	e59f280c 	ldr	r2, [pc, #2060]	; f01020e4 <mem_init+0x1240>
f01018d4:	e08f2002 	add	r2, pc, r2
f01018d8:	e59f3808 	ldr	r3, [pc, #2056]	; f01020e8 <mem_init+0x1244>
f01018dc:	e08f3003 	add	r3, pc, r3
f01018e0:	ebfff9f0 	bl	f01000a8 <_panic>
    assert(pp2->pp_ref == 1);
f01018e4:	e1d630b4 	ldrh	r3, [r6, #4]
f01018e8:	e3530001 	cmp	r3, #1
f01018ec:	0a000007 	beq	f0101910 <mem_init+0xa6c>
f01018f0:	e59f07f4 	ldr	r0, [pc, #2036]	; f01020ec <mem_init+0x1248>
f01018f4:	e08f0000 	add	r0, pc, r0
f01018f8:	e59f17f0 	ldr	r1, [pc, #2032]	; f01020f0 <mem_init+0x124c>
f01018fc:	e59f27f0 	ldr	r2, [pc, #2032]	; f01020f4 <mem_init+0x1250>
f0101900:	e08f2002 	add	r2, pc, r2
f0101904:	e59f37ec 	ldr	r3, [pc, #2028]	; f01020f8 <mem_init+0x1254>
f0101908:	e08f3003 	add	r3, pc, r3
f010190c:	ebfff9e5 	bl	f01000a8 <_panic>

    // should be no free memory
    assert(!page_alloc(0));
f0101910:	e3a00000 	mov	r0, #0
f0101914:	ebfffc3c 	bl	f0100a0c <page_alloc>
f0101918:	e3500000 	cmp	r0, #0
f010191c:	0a000007 	beq	f0101940 <mem_init+0xa9c>
f0101920:	e59f07d4 	ldr	r0, [pc, #2004]	; f01020fc <mem_init+0x1258>
f0101924:	e08f0000 	add	r0, pc, r0
f0101928:	e59f17d0 	ldr	r1, [pc, #2000]	; f0102100 <mem_init+0x125c>
f010192c:	e59f27d0 	ldr	r2, [pc, #2000]	; f0102104 <mem_init+0x1260>
f0101930:	e08f2002 	add	r2, pc, r2
f0101934:	e59f37cc 	ldr	r3, [pc, #1996]	; f0102108 <mem_init+0x1264>
f0101938:	e08f3003 	add	r3, pc, r3
f010193c:	ebfff9d9 	bl	f01000a8 <_panic>

    // should be able to map pp2 at PGSIZE because it's already there
    assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_NONE_U) == 0);
f0101940:	e59f3544 	ldr	r3, [pc, #1348]	; f0101e8c <mem_init+0xfe8>
f0101944:	e7943003 	ldr	r3, [r4, r3]
f0101948:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f010194c:	e1a00003 	mov	r0, r3
f0101950:	e1a01006 	mov	r1, r6
f0101954:	e3a02a01 	mov	r2, #4096	; 0x1000
f0101958:	e3a03010 	mov	r3, #16
f010195c:	ebfffd1e 	bl	f0100ddc <page_insert>
f0101960:	e3500000 	cmp	r0, #0
f0101964:	0a000007 	beq	f0101988 <mem_init+0xae4>
f0101968:	e59f079c 	ldr	r0, [pc, #1948]	; f010210c <mem_init+0x1268>
f010196c:	e08f0000 	add	r0, pc, r0
f0101970:	e59f1798 	ldr	r1, [pc, #1944]	; f0102110 <mem_init+0x126c>
f0101974:	e59f2798 	ldr	r2, [pc, #1944]	; f0102114 <mem_init+0x1270>
f0101978:	e08f2002 	add	r2, pc, r2
f010197c:	e59f3794 	ldr	r3, [pc, #1940]	; f0102118 <mem_init+0x1274>
f0101980:	e08f3003 	add	r3, pc, r3
f0101984:	ebfff9c7 	bl	f01000a8 <_panic>
    assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101988:	e59f34fc 	ldr	r3, [pc, #1276]	; f0101e8c <mem_init+0xfe8>
f010198c:	e7943003 	ldr	r3, [r4, r3]
f0101990:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101994:	e1a00003 	mov	r0, r3
f0101998:	e3a01a01 	mov	r1, #4096	; 0x1000
f010199c:	ebfffb8c 	bl	f01007d4 <check_va2pa>
f01019a0:	e1550000 	cmp	r5, r0
f01019a4:	0a000007 	beq	f01019c8 <mem_init+0xb24>
f01019a8:	e59f076c 	ldr	r0, [pc, #1900]	; f010211c <mem_init+0x1278>
f01019ac:	e08f0000 	add	r0, pc, r0
f01019b0:	e59f1768 	ldr	r1, [pc, #1896]	; f0102120 <mem_init+0x127c>
f01019b4:	e59f2768 	ldr	r2, [pc, #1896]	; f0102124 <mem_init+0x1280>
f01019b8:	e08f2002 	add	r2, pc, r2
f01019bc:	e59f3764 	ldr	r3, [pc, #1892]	; f0102128 <mem_init+0x1284>
f01019c0:	e08f3003 	add	r3, pc, r3
f01019c4:	ebfff9b7 	bl	f01000a8 <_panic>
    assert(pp2->pp_ref == 1);
f01019c8:	e1d630b4 	ldrh	r3, [r6, #4]
f01019cc:	e3530001 	cmp	r3, #1
f01019d0:	0a000007 	beq	f01019f4 <mem_init+0xb50>
f01019d4:	e59f0750 	ldr	r0, [pc, #1872]	; f010212c <mem_init+0x1288>
f01019d8:	e08f0000 	add	r0, pc, r0
f01019dc:	e59f174c 	ldr	r1, [pc, #1868]	; f0102130 <mem_init+0x128c>
f01019e0:	e59f274c 	ldr	r2, [pc, #1868]	; f0102134 <mem_init+0x1290>
f01019e4:	e08f2002 	add	r2, pc, r2
f01019e8:	e59f3748 	ldr	r3, [pc, #1864]	; f0102138 <mem_init+0x1294>
f01019ec:	e08f3003 	add	r3, pc, r3
f01019f0:	ebfff9ac 	bl	f01000a8 <_panic>

    // pp2 should NOT be on the free list
    // could happen in ref counts are handled sloppily in page_insert
    assert(!page_alloc(0));
f01019f4:	e3a00000 	mov	r0, #0
f01019f8:	ebfffc03 	bl	f0100a0c <page_alloc>
f01019fc:	e3500000 	cmp	r0, #0
f0101a00:	0a000007 	beq	f0101a24 <mem_init+0xb80>
f0101a04:	e59f0730 	ldr	r0, [pc, #1840]	; f010213c <mem_init+0x1298>
f0101a08:	e08f0000 	add	r0, pc, r0
f0101a0c:	e59f172c 	ldr	r1, [pc, #1836]	; f0102140 <mem_init+0x129c>
f0101a10:	e59f272c 	ldr	r2, [pc, #1836]	; f0102144 <mem_init+0x12a0>
f0101a14:	e08f2002 	add	r2, pc, r2
f0101a18:	e59f3728 	ldr	r3, [pc, #1832]	; f0102148 <mem_init+0x12a4>
f0101a1c:	e08f3003 	add	r3, pc, r3
f0101a20:	ebfff9a0 	bl	f01000a8 <_panic>

    // check that pgdir_walk returns a pointer to the pte
    ptep = (pte_t *) KADDR(PTE_SMALL_ADDR(kern_pgdir[PDX(PGSIZE)]));
f0101a24:	e59f3460 	ldr	r3, [pc, #1120]	; f0101e8c <mem_init+0xfe8>
f0101a28:	e7943003 	ldr	r3, [r4, r3]
f0101a2c:	e5933000 	ldr	r3, [r3]
f0101a30:	e3c33eff 	bic	r3, r3, #4080	; 0xff0
f0101a34:	e3c3300f 	bic	r3, r3, #15
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0101a38:	e59f24dc 	ldr	r2, [pc, #1244]	; f0101f1c <mem_init+0x1078>
f0101a3c:	e7942002 	ldr	r2, [r4, r2]
f0101a40:	e5922000 	ldr	r2, [r2]
f0101a44:	e1520623 	cmp	r2, r3, lsr #12
f0101a48:	8a000005 	bhi	f0101a64 <mem_init+0xbc0>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0101a4c:	e59f06f8 	ldr	r0, [pc, #1784]	; f010214c <mem_init+0x12a8>
f0101a50:	e08f0000 	add	r0, pc, r0
f0101a54:	e59f16f4 	ldr	r1, [pc, #1780]	; f0102150 <mem_init+0x12ac>
f0101a58:	e59f26f4 	ldr	r2, [pc, #1780]	; f0102154 <mem_init+0x12b0>
f0101a5c:	e08f2002 	add	r2, pc, r2
f0101a60:	ebfff990 	bl	f01000a8 <_panic>
	return (void *)(pa + KERNBASE);
f0101a64:	e283320f 	add	r3, r3, #-268435456	; 0xf0000000
f0101a68:	e50b3028 	str	r3, [fp, #-40]	; 0xffffffd8
    assert(pgdir_walk(kern_pgdir, (void*)PGSIZE, 0) == ptep+PTX(PGSIZE));
f0101a6c:	e59f3418 	ldr	r3, [pc, #1048]	; f0101e8c <mem_init+0xfe8>
f0101a70:	e7943003 	ldr	r3, [r4, r3]
f0101a74:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101a78:	e1a00003 	mov	r0, r3
f0101a7c:	e3a01a01 	mov	r1, #4096	; 0x1000
f0101a80:	e3a02000 	mov	r2, #0
f0101a84:	ebfffc2c 	bl	f0100b3c <pgdir_walk>
f0101a88:	e51b3028 	ldr	r3, [fp, #-40]	; 0xffffffd8
f0101a8c:	e2833004 	add	r3, r3, #4
f0101a90:	e1530000 	cmp	r3, r0
f0101a94:	0a000007 	beq	f0101ab8 <mem_init+0xc14>
f0101a98:	e59f06b8 	ldr	r0, [pc, #1720]	; f0102158 <mem_init+0x12b4>
f0101a9c:	e08f0000 	add	r0, pc, r0
f0101aa0:	e59f16b4 	ldr	r1, [pc, #1716]	; f010215c <mem_init+0x12b8>
f0101aa4:	e59f26b4 	ldr	r2, [pc, #1716]	; f0102160 <mem_init+0x12bc>
f0101aa8:	e08f2002 	add	r2, pc, r2
f0101aac:	e59f36b0 	ldr	r3, [pc, #1712]	; f0102164 <mem_init+0x12c0>
f0101ab0:	e08f3003 	add	r3, pc, r3
f0101ab4:	ebfff97b 	bl	f01000a8 <_panic>

    // should be able to change permissions too.
    assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_RW_U) == 0);
f0101ab8:	e59f33cc 	ldr	r3, [pc, #972]	; f0101e8c <mem_init+0xfe8>
f0101abc:	e7943003 	ldr	r3, [r4, r3]
f0101ac0:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101ac4:	e1a00003 	mov	r0, r3
f0101ac8:	e1a01006 	mov	r1, r6
f0101acc:	e3a02a01 	mov	r2, #4096	; 0x1000
f0101ad0:	e3a03030 	mov	r3, #48	; 0x30
f0101ad4:	ebfffcc0 	bl	f0100ddc <page_insert>
f0101ad8:	e3500000 	cmp	r0, #0
f0101adc:	0a000007 	beq	f0101b00 <mem_init+0xc5c>
f0101ae0:	e59f0680 	ldr	r0, [pc, #1664]	; f0102168 <mem_init+0x12c4>
f0101ae4:	e08f0000 	add	r0, pc, r0
f0101ae8:	e59f167c 	ldr	r1, [pc, #1660]	; f010216c <mem_init+0x12c8>
f0101aec:	e59f267c 	ldr	r2, [pc, #1660]	; f0102170 <mem_init+0x12cc>
f0101af0:	e08f2002 	add	r2, pc, r2
f0101af4:	e59f3678 	ldr	r3, [pc, #1656]	; f0102174 <mem_init+0x12d0>
f0101af8:	e08f3003 	add	r3, pc, r3
f0101afc:	ebfff969 	bl	f01000a8 <_panic>
    assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp2));
f0101b00:	e59f3384 	ldr	r3, [pc, #900]	; f0101e8c <mem_init+0xfe8>
f0101b04:	e7943003 	ldr	r3, [r4, r3]
f0101b08:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101b0c:	e1a00003 	mov	r0, r3
f0101b10:	e3a01a01 	mov	r1, #4096	; 0x1000
f0101b14:	ebfffb2e 	bl	f01007d4 <check_va2pa>
f0101b18:	e1550000 	cmp	r5, r0
f0101b1c:	0a000007 	beq	f0101b40 <mem_init+0xc9c>
f0101b20:	e59f0650 	ldr	r0, [pc, #1616]	; f0102178 <mem_init+0x12d4>
f0101b24:	e08f0000 	add	r0, pc, r0
f0101b28:	e59f164c 	ldr	r1, [pc, #1612]	; f010217c <mem_init+0x12d8>
f0101b2c:	e59f264c 	ldr	r2, [pc, #1612]	; f0102180 <mem_init+0x12dc>
f0101b30:	e08f2002 	add	r2, pc, r2
f0101b34:	e59f3648 	ldr	r3, [pc, #1608]	; f0102184 <mem_init+0x12e0>
f0101b38:	e08f3003 	add	r3, pc, r3
f0101b3c:	ebfff959 	bl	f01000a8 <_panic>
    assert(pp2->pp_ref == 1);
f0101b40:	e1d630b4 	ldrh	r3, [r6, #4]
f0101b44:	e3530001 	cmp	r3, #1
f0101b48:	0a000007 	beq	f0101b6c <mem_init+0xcc8>
f0101b4c:	e59f0634 	ldr	r0, [pc, #1588]	; f0102188 <mem_init+0x12e4>
f0101b50:	e08f0000 	add	r0, pc, r0
f0101b54:	e3a01f72 	mov	r1, #456	; 0x1c8
f0101b58:	e59f262c 	ldr	r2, [pc, #1580]	; f010218c <mem_init+0x12e8>
f0101b5c:	e08f2002 	add	r2, pc, r2
f0101b60:	e59f3628 	ldr	r3, [pc, #1576]	; f0102190 <mem_init+0x12ec>
f0101b64:	e08f3003 	add	r3, pc, r3
f0101b68:	ebfff94e 	bl	f01000a8 <_panic>
    assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_RW_U);
f0101b6c:	e59f3318 	ldr	r3, [pc, #792]	; f0101e8c <mem_init+0xfe8>
f0101b70:	e7943003 	ldr	r3, [r4, r3]
f0101b74:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101b78:	e1a00003 	mov	r0, r3
f0101b7c:	e3a01a01 	mov	r1, #4096	; 0x1000
f0101b80:	e3a02000 	mov	r2, #0
f0101b84:	ebfffbec 	bl	f0100b3c <pgdir_walk>
f0101b88:	e5903000 	ldr	r3, [r0]
f0101b8c:	e3130030 	tst	r3, #48	; 0x30
f0101b90:	1a000007 	bne	f0101bb4 <mem_init+0xd10>
f0101b94:	e59f05f8 	ldr	r0, [pc, #1528]	; f0102194 <mem_init+0x12f0>
f0101b98:	e08f0000 	add	r0, pc, r0
f0101b9c:	e59f15f4 	ldr	r1, [pc, #1524]	; f0102198 <mem_init+0x12f4>
f0101ba0:	e59f25f4 	ldr	r2, [pc, #1524]	; f010219c <mem_init+0x12f8>
f0101ba4:	e08f2002 	add	r2, pc, r2
f0101ba8:	e59f35f0 	ldr	r3, [pc, #1520]	; f01021a0 <mem_init+0x12fc>
f0101bac:	e08f3003 	add	r3, pc, r3
f0101bb0:	ebfff93c 	bl	f01000a8 <_panic>
    //assert(kern_pgdir[0] & PTE_U);

    // should be able to remap with fewer permissions
    assert(page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_NONE_U) == 0);
f0101bb4:	e59f32d0 	ldr	r3, [pc, #720]	; f0101e8c <mem_init+0xfe8>
f0101bb8:	e7943003 	ldr	r3, [r4, r3]
f0101bbc:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101bc0:	e1a00003 	mov	r0, r3
f0101bc4:	e1a01006 	mov	r1, r6
f0101bc8:	e3a02a01 	mov	r2, #4096	; 0x1000
f0101bcc:	e3a03010 	mov	r3, #16
f0101bd0:	ebfffc81 	bl	f0100ddc <page_insert>
f0101bd4:	e3500000 	cmp	r0, #0
f0101bd8:	0a000007 	beq	f0101bfc <mem_init+0xd58>
f0101bdc:	e59f05c0 	ldr	r0, [pc, #1472]	; f01021a4 <mem_init+0x1300>
f0101be0:	e08f0000 	add	r0, pc, r0
f0101be4:	e59f15bc 	ldr	r1, [pc, #1468]	; f01021a8 <mem_init+0x1304>
f0101be8:	e59f25bc 	ldr	r2, [pc, #1468]	; f01021ac <mem_init+0x1308>
f0101bec:	e08f2002 	add	r2, pc, r2
f0101bf0:	e59f35b8 	ldr	r3, [pc, #1464]	; f01021b0 <mem_init+0x130c>
f0101bf4:	e08f3003 	add	r3, pc, r3
f0101bf8:	ebfff92a 	bl	f01000a8 <_panic>
    assert(*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_NONE_U);
f0101bfc:	e59f3288 	ldr	r3, [pc, #648]	; f0101e8c <mem_init+0xfe8>
f0101c00:	e7943003 	ldr	r3, [r4, r3]
f0101c04:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101c08:	e1a00003 	mov	r0, r3
f0101c0c:	e3a01a01 	mov	r1, #4096	; 0x1000
f0101c10:	e3a02000 	mov	r2, #0
f0101c14:	ebfffbc8 	bl	f0100b3c <pgdir_walk>
f0101c18:	e5903000 	ldr	r3, [r0]
f0101c1c:	e3130010 	tst	r3, #16
f0101c20:	1a000007 	bne	f0101c44 <mem_init+0xda0>
f0101c24:	e59f0588 	ldr	r0, [pc, #1416]	; f01021b4 <mem_init+0x1310>
f0101c28:	e08f0000 	add	r0, pc, r0
f0101c2c:	e59f1584 	ldr	r1, [pc, #1412]	; f01021b8 <mem_init+0x1314>
f0101c30:	e59f2584 	ldr	r2, [pc, #1412]	; f01021bc <mem_init+0x1318>
f0101c34:	e08f2002 	add	r2, pc, r2
f0101c38:	e59f3580 	ldr	r3, [pc, #1408]	; f01021c0 <mem_init+0x131c>
f0101c3c:	e08f3003 	add	r3, pc, r3
f0101c40:	ebfff918 	bl	f01000a8 <_panic>
    assert((*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_RW_U) != PTE_RW_U);
f0101c44:	e59f3240 	ldr	r3, [pc, #576]	; f0101e8c <mem_init+0xfe8>
f0101c48:	e7943003 	ldr	r3, [r4, r3]
f0101c4c:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101c50:	e1a00003 	mov	r0, r3
f0101c54:	e3a01a01 	mov	r1, #4096	; 0x1000
f0101c58:	e3a02000 	mov	r2, #0
f0101c5c:	ebfffbb6 	bl	f0100b3c <pgdir_walk>
f0101c60:	e5903000 	ldr	r3, [r0]
f0101c64:	e2033030 	and	r3, r3, #48	; 0x30
f0101c68:	e3530030 	cmp	r3, #48	; 0x30
f0101c6c:	1a000007 	bne	f0101c90 <mem_init+0xdec>
f0101c70:	e59f054c 	ldr	r0, [pc, #1356]	; f01021c4 <mem_init+0x1320>
f0101c74:	e08f0000 	add	r0, pc, r0
f0101c78:	e59f1548 	ldr	r1, [pc, #1352]	; f01021c8 <mem_init+0x1324>
f0101c7c:	e59f2548 	ldr	r2, [pc, #1352]	; f01021cc <mem_init+0x1328>
f0101c80:	e08f2002 	add	r2, pc, r2
f0101c84:	e59f3544 	ldr	r3, [pc, #1348]	; f01021d0 <mem_init+0x132c>
f0101c88:	e08f3003 	add	r3, pc, r3
f0101c8c:	ebfff905 	bl	f01000a8 <_panic>

    // should not be able to map at PTSIZE because need free page for page table
    assert(page_insert(kern_pgdir, pp0, (void*) PTSIZE, PTE_NONE_U) < 0);
f0101c90:	e59f31f4 	ldr	r3, [pc, #500]	; f0101e8c <mem_init+0xfe8>
f0101c94:	e7943003 	ldr	r3, [r4, r3]
f0101c98:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101c9c:	e1a00003 	mov	r0, r3
f0101ca0:	e1a01008 	mov	r1, r8
f0101ca4:	e3a02601 	mov	r2, #1048576	; 0x100000
f0101ca8:	e3a03010 	mov	r3, #16
f0101cac:	ebfffc4a 	bl	f0100ddc <page_insert>
f0101cb0:	e3500000 	cmp	r0, #0
f0101cb4:	ba000007 	blt	f0101cd8 <mem_init+0xe34>
f0101cb8:	e59f0514 	ldr	r0, [pc, #1300]	; f01021d4 <mem_init+0x1330>
f0101cbc:	e08f0000 	add	r0, pc, r0
f0101cc0:	e59f1510 	ldr	r1, [pc, #1296]	; f01021d8 <mem_init+0x1334>
f0101cc4:	e59f2510 	ldr	r2, [pc, #1296]	; f01021dc <mem_init+0x1338>
f0101cc8:	e08f2002 	add	r2, pc, r2
f0101ccc:	e59f350c 	ldr	r3, [pc, #1292]	; f01021e0 <mem_init+0x133c>
f0101cd0:	e08f3003 	add	r3, pc, r3
f0101cd4:	ebfff8f3 	bl	f01000a8 <_panic>

    // insert pp1 at PGSIZE (replacing pp2)
    assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_NONE_U) == 0);
f0101cd8:	e59f31ac 	ldr	r3, [pc, #428]	; f0101e8c <mem_init+0xfe8>
f0101cdc:	e7943003 	ldr	r3, [r4, r3]
f0101ce0:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101ce4:	e1a00003 	mov	r0, r3
f0101ce8:	e1a01007 	mov	r1, r7
f0101cec:	e3a02a01 	mov	r2, #4096	; 0x1000
f0101cf0:	e3a03010 	mov	r3, #16
f0101cf4:	ebfffc38 	bl	f0100ddc <page_insert>
f0101cf8:	e3500000 	cmp	r0, #0
f0101cfc:	0a000007 	beq	f0101d20 <mem_init+0xe7c>
f0101d00:	e59f04dc 	ldr	r0, [pc, #1244]	; f01021e4 <mem_init+0x1340>
f0101d04:	e08f0000 	add	r0, pc, r0
f0101d08:	e59f14d8 	ldr	r1, [pc, #1240]	; f01021e8 <mem_init+0x1344>
f0101d0c:	e59f24d8 	ldr	r2, [pc, #1240]	; f01021ec <mem_init+0x1348>
f0101d10:	e08f2002 	add	r2, pc, r2
f0101d14:	e59f34d4 	ldr	r3, [pc, #1236]	; f01021f0 <mem_init+0x134c>
f0101d18:	e08f3003 	add	r3, pc, r3
f0101d1c:	ebfff8e1 	bl	f01000a8 <_panic>
    assert((*pgdir_walk(kern_pgdir, (void*) PGSIZE, 0) & PTE_RW_U) != PTE_RW_U);
f0101d20:	e59f3164 	ldr	r3, [pc, #356]	; f0101e8c <mem_init+0xfe8>
f0101d24:	e7943003 	ldr	r3, [r4, r3]
f0101d28:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101d2c:	e1a00003 	mov	r0, r3
f0101d30:	e3a01a01 	mov	r1, #4096	; 0x1000
f0101d34:	e3a02000 	mov	r2, #0
f0101d38:	ebfffb7f 	bl	f0100b3c <pgdir_walk>
f0101d3c:	e5903000 	ldr	r3, [r0]
f0101d40:	e2033030 	and	r3, r3, #48	; 0x30
f0101d44:	e3530030 	cmp	r3, #48	; 0x30
f0101d48:	1a000007 	bne	f0101d6c <mem_init+0xec8>
f0101d4c:	e59f04a0 	ldr	r0, [pc, #1184]	; f01021f4 <mem_init+0x1350>
f0101d50:	e08f0000 	add	r0, pc, r0
f0101d54:	e59f149c 	ldr	r1, [pc, #1180]	; f01021f8 <mem_init+0x1354>
f0101d58:	e59f249c 	ldr	r2, [pc, #1180]	; f01021fc <mem_init+0x1358>
f0101d5c:	e08f2002 	add	r2, pc, r2
f0101d60:	e59f3498 	ldr	r3, [pc, #1176]	; f0102200 <mem_init+0x135c>
f0101d64:	e08f3003 	add	r3, pc, r3
f0101d68:	ebfff8ce 	bl	f01000a8 <_panic>

    // should have pp1 at both 0 and PGSIZE, pp2 nowhere, ...
    assert(check_va2pa(kern_pgdir, 0) == page2pa(pp1));
f0101d6c:	e59f3118 	ldr	r3, [pc, #280]	; f0101e8c <mem_init+0xfe8>
f0101d70:	e7943003 	ldr	r3, [r4, r3]
f0101d74:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101d78:	e1a00003 	mov	r0, r3
f0101d7c:	e3a01000 	mov	r1, #0
f0101d80:	ebfffa93 	bl	f01007d4 <check_va2pa>
f0101d84:	e1590000 	cmp	r9, r0
f0101d88:	0a000007 	beq	f0101dac <mem_init+0xf08>
f0101d8c:	e59f0470 	ldr	r0, [pc, #1136]	; f0102204 <mem_init+0x1360>
f0101d90:	e08f0000 	add	r0, pc, r0
f0101d94:	e59f146c 	ldr	r1, [pc, #1132]	; f0102208 <mem_init+0x1364>
f0101d98:	e59f246c 	ldr	r2, [pc, #1132]	; f010220c <mem_init+0x1368>
f0101d9c:	e08f2002 	add	r2, pc, r2
f0101da0:	e59f3468 	ldr	r3, [pc, #1128]	; f0102210 <mem_init+0x136c>
f0101da4:	e08f3003 	add	r3, pc, r3
f0101da8:	ebfff8be 	bl	f01000a8 <_panic>
    assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f0101dac:	e59f30d8 	ldr	r3, [pc, #216]	; f0101e8c <mem_init+0xfe8>
f0101db0:	e7943003 	ldr	r3, [r4, r3]
f0101db4:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0101db8:	e1a00003 	mov	r0, r3
f0101dbc:	e3a01a01 	mov	r1, #4096	; 0x1000
f0101dc0:	ebfffa83 	bl	f01007d4 <check_va2pa>
f0101dc4:	e1590000 	cmp	r9, r0
f0101dc8:	0a000007 	beq	f0101dec <mem_init+0xf48>
f0101dcc:	e59f0440 	ldr	r0, [pc, #1088]	; f0102214 <mem_init+0x1370>
f0101dd0:	e08f0000 	add	r0, pc, r0
f0101dd4:	e59f143c 	ldr	r1, [pc, #1084]	; f0102218 <mem_init+0x1374>
f0101dd8:	e59f243c 	ldr	r2, [pc, #1084]	; f010221c <mem_init+0x1378>
f0101ddc:	e08f2002 	add	r2, pc, r2
f0101de0:	e59f3438 	ldr	r3, [pc, #1080]	; f0102220 <mem_init+0x137c>
f0101de4:	e08f3003 	add	r3, pc, r3
f0101de8:	ebfff8ae 	bl	f01000a8 <_panic>
    // ... and ref counts should reflect this
    assert(pp1->pp_ref == 2);
f0101dec:	e1d730b4 	ldrh	r3, [r7, #4]
f0101df0:	e3530002 	cmp	r3, #2
f0101df4:	0a000007 	beq	f0101e18 <mem_init+0xf74>
f0101df8:	e59f0424 	ldr	r0, [pc, #1060]	; f0102224 <mem_init+0x1380>
f0101dfc:	e08f0000 	add	r0, pc, r0
f0101e00:	e3a01f77 	mov	r1, #476	; 0x1dc
f0101e04:	e59f241c 	ldr	r2, [pc, #1052]	; f0102228 <mem_init+0x1384>
f0101e08:	e08f2002 	add	r2, pc, r2
f0101e0c:	e59f3418 	ldr	r3, [pc, #1048]	; f010222c <mem_init+0x1388>
f0101e10:	e08f3003 	add	r3, pc, r3
f0101e14:	ebfff8a3 	bl	f01000a8 <_panic>
    assert(pp2->pp_ref == 0);
f0101e18:	e1d630b4 	ldrh	r3, [r6, #4]
f0101e1c:	e3530000 	cmp	r3, #0
f0101e20:	0a000007 	beq	f0101e44 <mem_init+0xfa0>
f0101e24:	e59f0404 	ldr	r0, [pc, #1028]	; f0102230 <mem_init+0x138c>
f0101e28:	e08f0000 	add	r0, pc, r0
f0101e2c:	e59f1400 	ldr	r1, [pc, #1024]	; f0102234 <mem_init+0x1390>
f0101e30:	e59f2400 	ldr	r2, [pc, #1024]	; f0102238 <mem_init+0x1394>
f0101e34:	e08f2002 	add	r2, pc, r2
f0101e38:	e59f33fc 	ldr	r3, [pc, #1020]	; f010223c <mem_init+0x1398>
f0101e3c:	e08f3003 	add	r3, pc, r3
f0101e40:	ebfff898 	bl	f01000a8 <_panic>

    // pp2 should be returned by page_alloc
    assert((pp = page_alloc(0)) && pp == pp2);
f0101e44:	e3a00000 	mov	r0, #0
f0101e48:	ebfffaef 	bl	f0100a0c <page_alloc>
f0101e4c:	e0563000 	subs	r3, r6, r0
f0101e50:	13a03001 	movne	r3, #1
f0101e54:	e3500000 	cmp	r0, #0
f0101e58:	11a00003 	movne	r0, r3
f0101e5c:	03830001 	orreq	r0, r3, #1
f0101e60:	e3500000 	cmp	r0, #0
f0101e64:	0a000191 	beq	f01024b0 <mem_init+0x160c>
f0101e68:	e59f03d0 	ldr	r0, [pc, #976]	; f0102240 <mem_init+0x139c>
f0101e6c:	e08f0000 	add	r0, pc, r0
f0101e70:	e3a01e1e 	mov	r1, #480	; 0x1e0
f0101e74:	e59f23c8 	ldr	r2, [pc, #968]	; f0102244 <mem_init+0x13a0>
f0101e78:	e08f2002 	add	r2, pc, r2
f0101e7c:	e59f33c4 	ldr	r3, [pc, #964]	; f0102248 <mem_init+0x13a4>
f0101e80:	e08f3003 	add	r3, pc, r3
f0101e84:	ebfff887 	bl	f01000a8 <_panic>
f0101e88:	0010b148 	.word	0x0010b148
f0101e8c:	00000030 	.word	0x00000030
f0101e90:	00000402 	.word	0x00000402
f0101e94:	f0100000 	.word	0xf0100000
f0101e98:	00003900 	.word	0x00003900
f0101e9c:	00003954 	.word	0x00003954
f0101ea0:	00000020 	.word	0x00000020
f0101ea4:	000038a8 	.word	0x000038a8
f0101ea8:	000038fc 	.word	0x000038fc
f0101eac:	3f200402 	.word	0x3f200402
f0101eb0:	00003854 	.word	0x00003854
f0101eb4:	000038a8 	.word	0x000038a8
f0101eb8:	0010f228 	.word	0x0010f228
f0101ebc:	000037e8 	.word	0x000037e8
f0101ec0:	00003898 	.word	0x00003898
f0101ec4:	000038a8 	.word	0x000038a8
f0101ec8:	000037b0 	.word	0x000037b0
f0101ecc:	00003860 	.word	0x00003860
f0101ed0:	00003880 	.word	0x00003880
f0101ed4:	00003880 	.word	0x00003880
f0101ed8:	0010f194 	.word	0x0010f194
f0101edc:	00003744 	.word	0x00003744
f0101ee0:	000037f4 	.word	0x000037f4
f0101ee4:	00003844 	.word	0x00003844
f0101ee8:	00003714 	.word	0x00003714
f0101eec:	000037c4 	.word	0x000037c4
f0101ef0:	0000382c 	.word	0x0000382c
f0101ef4:	000036e4 	.word	0x000036e4
f0101ef8:	00003794 	.word	0x00003794
f0101efc:	00003814 	.word	0x00003814
f0101f00:	000036bc 	.word	0x000036bc
f0101f04:	0000376c 	.word	0x0000376c
f0101f08:	00003804 	.word	0x00003804
f0101f0c:	00003690 	.word	0x00003690
f0101f10:	00003740 	.word	0x00003740
f0101f14:	000037ec 	.word	0x000037ec
f0101f18:	00000034 	.word	0x00000034
f0101f1c:	0000002c 	.word	0x0000002c
f0101f20:	00003640 	.word	0x00003640
f0101f24:	000036f0 	.word	0x000036f0
f0101f28:	000037bc 	.word	0x000037bc
f0101f2c:	0000360c 	.word	0x0000360c
f0101f30:	000036bc 	.word	0x000036bc
f0101f34:	000037a8 	.word	0x000037a8
f0101f38:	000035d8 	.word	0x000035d8
f0101f3c:	00003688 	.word	0x00003688
f0101f40:	00003794 	.word	0x00003794
f0101f44:	0010efc8 	.word	0x0010efc8
f0101f48:	00003594 	.word	0x00003594
f0101f4c:	00000107 	.word	0x00000107
f0101f50:	00003644 	.word	0x00003644
f0101f54:	00003770 	.word	0x00003770
f0101f58:	0000354c 	.word	0x0000354c
f0101f5c:	0000010e 	.word	0x0000010e
f0101f60:	000035fc 	.word	0x000035fc
f0101f64:	0000364c 	.word	0x0000364c
f0101f68:	0000351c 	.word	0x0000351c
f0101f6c:	0000010f 	.word	0x0000010f
f0101f70:	000035cc 	.word	0x000035cc
f0101f74:	00003634 	.word	0x00003634
f0101f78:	000034ec 	.word	0x000034ec
f0101f7c:	0000359c 	.word	0x0000359c
f0101f80:	0000361c 	.word	0x0000361c
f0101f84:	000034c4 	.word	0x000034c4
f0101f88:	00000112 	.word	0x00000112
f0101f8c:	00003574 	.word	0x00003574
f0101f90:	0000360c 	.word	0x0000360c
f0101f94:	00003498 	.word	0x00003498
f0101f98:	00000113 	.word	0x00000113
f0101f9c:	00003548 	.word	0x00003548
f0101fa0:	000035f4 	.word	0x000035f4
f0101fa4:	00003468 	.word	0x00003468
f0101fa8:	00003518 	.word	0x00003518
f0101fac:	00003644 	.word	0x00003644
f0101fb0:	00003450 	.word	0x00003450
f0101fb4:	00003420 	.word	0x00003420
f0101fb8:	000033d4 	.word	0x000033d4
f0101fbc:	00000119 	.word	0x00000119
f0101fc0:	00003484 	.word	0x00003484
f0101fc4:	000035c0 	.word	0x000035c0
f0101fc8:	000033ac 	.word	0x000033ac
f0101fcc:	0000011a 	.word	0x0000011a
f0101fd0:	0000345c 	.word	0x0000345c
f0101fd4:	000035b8 	.word	0x000035b8
f0101fd8:	000033a8 	.word	0x000033a8
f0101fdc:	00003378 	.word	0x00003378
f0101fe0:	00003334 	.word	0x00003334
f0101fe4:	0000011d 	.word	0x0000011d
f0101fe8:	000033e4 	.word	0x000033e4
f0101fec:	00003550 	.word	0x00003550
f0101ff0:	0010ed1c 	.word	0x0010ed1c
f0101ff4:	000032c0 	.word	0x000032c0
f0101ff8:	0000012a 	.word	0x0000012a
f0101ffc:	00003370 	.word	0x00003370
f0102000:	000034e8 	.word	0x000034e8
f0102004:	000034e8 	.word	0x000034e8
f0102008:	00003284 	.word	0x00003284
f010200c:	00000193 	.word	0x00000193
f0102010:	00003334 	.word	0x00003334
f0102014:	00003384 	.word	0x00003384
f0102018:	00003254 	.word	0x00003254
f010201c:	00003304 	.word	0x00003304
f0102020:	0000336c 	.word	0x0000336c
f0102024:	00003224 	.word	0x00003224
f0102028:	00000195 	.word	0x00000195
f010202c:	000032d4 	.word	0x000032d4
f0102030:	00003354 	.word	0x00003354
f0102034:	000031fc 	.word	0x000031fc
f0102038:	000032ac 	.word	0x000032ac
f010203c:	00003344 	.word	0x00003344
f0102040:	000031d0 	.word	0x000031d0
f0102044:	00000199 	.word	0x00000199
f0102048:	00003280 	.word	0x00003280
f010204c:	0000332c 	.word	0x0000332c
f0102050:	0010ebc0 	.word	0x0010ebc0
f0102054:	0000318c 	.word	0x0000318c
f0102058:	0000323c 	.word	0x0000323c
f010205c:	00003368 	.word	0x00003368
f0102060:	00003148 	.word	0x00003148
f0102064:	000001a3 	.word	0x000001a3
f0102068:	000031f8 	.word	0x000031f8
f010206c:	0000339c 	.word	0x0000339c
f0102070:	00003100 	.word	0x00003100
f0102074:	000001a6 	.word	0x000001a6
f0102078:	000031b0 	.word	0x000031b0
f010207c:	0000338c 	.word	0x0000338c
f0102080:	000030b0 	.word	0x000030b0
f0102084:	000001aa 	.word	0x000001aa
f0102088:	00003160 	.word	0x00003160
f010208c:	00003370 	.word	0x00003370
f0102090:	00003068 	.word	0x00003068
f0102094:	000001ab 	.word	0x000001ab
f0102098:	00003118 	.word	0x00003118
f010209c:	0000335c 	.word	0x0000335c
f01020a0:	00003018 	.word	0x00003018
f01020a4:	000030c8 	.word	0x000030c8
f01020a8:	0000333c 	.word	0x0000333c
f01020ac:	00002fec 	.word	0x00002fec
f01020b0:	000001ad 	.word	0x000001ad
f01020b4:	0000309c 	.word	0x0000309c
f01020b8:	00003340 	.word	0x00003340
f01020bc:	00002fc0 	.word	0x00002fc0
f01020c0:	000001ae 	.word	0x000001ae
f01020c4:	00003070 	.word	0x00003070
f01020c8:	00003328 	.word	0x00003328
f01020cc:	00002f78 	.word	0x00002f78
f01020d0:	000001b1 	.word	0x000001b1
f01020d4:	00003028 	.word	0x00003028
f01020d8:	000032f4 	.word	0x000032f4
f01020dc:	00002f28 	.word	0x00002f28
f01020e0:	000001b2 	.word	0x000001b2
f01020e4:	00002fd8 	.word	0x00002fd8
f01020e8:	000032e4 	.word	0x000032e4
f01020ec:	00002efc 	.word	0x00002efc
f01020f0:	000001b3 	.word	0x000001b3
f01020f4:	00002fac 	.word	0x00002fac
f01020f8:	000032e8 	.word	0x000032e8
f01020fc:	00002ecc 	.word	0x00002ecc
f0102100:	000001b6 	.word	0x000001b6
f0102104:	00002f7c 	.word	0x00002f7c
f0102108:	000030a8 	.word	0x000030a8
f010210c:	00002e84 	.word	0x00002e84
f0102110:	000001b9 	.word	0x000001b9
f0102114:	00002f34 	.word	0x00002f34
f0102118:	00003200 	.word	0x00003200
f010211c:	00002e44 	.word	0x00002e44
f0102120:	000001ba 	.word	0x000001ba
f0102124:	00002ef4 	.word	0x00002ef4
f0102128:	00003200 	.word	0x00003200
f010212c:	00002e18 	.word	0x00002e18
f0102130:	000001bb 	.word	0x000001bb
f0102134:	00002ec8 	.word	0x00002ec8
f0102138:	00003204 	.word	0x00003204
f010213c:	00002de8 	.word	0x00002de8
f0102140:	000001bf 	.word	0x000001bf
f0102144:	00002e98 	.word	0x00002e98
f0102148:	00002fc4 	.word	0x00002fc4
f010214c:	00002da0 	.word	0x00002da0
f0102150:	000001c2 	.word	0x000001c2
f0102154:	00002da0 	.word	0x00002da0
f0102158:	00002d54 	.word	0x00002d54
f010215c:	000001c3 	.word	0x000001c3
f0102160:	00002e04 	.word	0x00002e04
f0102164:	00003154 	.word	0x00003154
f0102168:	00002d0c 	.word	0x00002d0c
f010216c:	000001c6 	.word	0x000001c6
f0102170:	00002dbc 	.word	0x00002dbc
f0102174:	0000314c 	.word	0x0000314c
f0102178:	00002ccc 	.word	0x00002ccc
f010217c:	000001c7 	.word	0x000001c7
f0102180:	00002d7c 	.word	0x00002d7c
f0102184:	00003088 	.word	0x00003088
f0102188:	00002ca0 	.word	0x00002ca0
f010218c:	00002d50 	.word	0x00002d50
f0102190:	0000308c 	.word	0x0000308c
f0102194:	00002c58 	.word	0x00002c58
f0102198:	000001c9 	.word	0x000001c9
f010219c:	00002d08 	.word	0x00002d08
f01021a0:	000030d4 	.word	0x000030d4
f01021a4:	00002c10 	.word	0x00002c10
f01021a8:	000001cd 	.word	0x000001cd
f01021ac:	00002cc0 	.word	0x00002cc0
f01021b0:	00002f8c 	.word	0x00002f8c
f01021b4:	00002bc8 	.word	0x00002bc8
f01021b8:	000001ce 	.word	0x000001ce
f01021bc:	00002c78 	.word	0x00002c78
f01021c0:	0000307c 	.word	0x0000307c
f01021c4:	00002b7c 	.word	0x00002b7c
f01021c8:	000001cf 	.word	0x000001cf
f01021cc:	00002c2c 	.word	0x00002c2c
f01021d0:	00003068 	.word	0x00003068
f01021d4:	00002b34 	.word	0x00002b34
f01021d8:	000001d2 	.word	0x000001d2
f01021dc:	00002be4 	.word	0x00002be4
f01021e0:	00003064 	.word	0x00003064
f01021e4:	00002aec 	.word	0x00002aec
f01021e8:	000001d5 	.word	0x000001d5
f01021ec:	00002b9c 	.word	0x00002b9c
f01021f0:	0000305c 	.word	0x0000305c
f01021f4:	00002aa0 	.word	0x00002aa0
f01021f8:	000001d6 	.word	0x000001d6
f01021fc:	00002b50 	.word	0x00002b50
f0102200:	00002f8c 	.word	0x00002f8c
f0102204:	00002a60 	.word	0x00002a60
f0102208:	000001d9 	.word	0x000001d9
f010220c:	00002b10 	.word	0x00002b10
f0102210:	00003010 	.word	0x00003010
f0102214:	00002a20 	.word	0x00002a20
f0102218:	000001da 	.word	0x000001da
f010221c:	00002ad0 	.word	0x00002ad0
f0102220:	00002ffc 	.word	0x00002ffc
f0102224:	000029f4 	.word	0x000029f4
f0102228:	00002aa4 	.word	0x00002aa4
f010222c:	00003000 	.word	0x00003000
f0102230:	000029c8 	.word	0x000029c8
f0102234:	000001dd 	.word	0x000001dd
f0102238:	00002a78 	.word	0x00002a78
f010223c:	00002fe8 	.word	0x00002fe8
f0102240:	00002984 	.word	0x00002984
f0102244:	00002a34 	.word	0x00002a34
f0102248:	00002fb8 	.word	0x00002fb8
f010224c:	00002310 	.word	0x00002310
f0102250:	000023c0 	.word	0x000023c0
f0102254:	00002968 	.word	0x00002968
f0102258:	000022d0 	.word	0x000022d0
f010225c:	000001e5 	.word	0x000001e5
f0102260:	00002380 	.word	0x00002380
f0102264:	000028ac 	.word	0x000028ac
f0102268:	000022a4 	.word	0x000022a4
f010226c:	000001e6 	.word	0x000001e6
f0102270:	00002354 	.word	0x00002354
f0102274:	000025f8 	.word	0x000025f8
f0102278:	00002278 	.word	0x00002278
f010227c:	000001e7 	.word	0x000001e7
f0102280:	00002328 	.word	0x00002328
f0102284:	00002898 	.word	0x00002898
f0102288:	00002230 	.word	0x00002230
f010228c:	000001ea 	.word	0x000001ea
f0102290:	000022e0 	.word	0x000022e0
f0102294:	000028ac 	.word	0x000028ac
f0102298:	00002204 	.word	0x00002204
f010229c:	000001eb 	.word	0x000001eb
f01022a0:	000022b4 	.word	0x000022b4
f01022a4:	000028b8 	.word	0x000028b8
f01022a8:	000021d8 	.word	0x000021d8
f01022ac:	00002288 	.word	0x00002288
f01022b0:	00002898 	.word	0x00002898
f01022b4:	0000218c 	.word	0x0000218c
f01022b8:	0000223c 	.word	0x0000223c
f01022bc:	000027e4 	.word	0x000027e4
f01022c0:	0000214c 	.word	0x0000214c
f01022c4:	000001f1 	.word	0x000001f1
f01022c8:	000021fc 	.word	0x000021fc
f01022cc:	00002824 	.word	0x00002824
f01022d0:	00002120 	.word	0x00002120
f01022d4:	000001f2 	.word	0x000001f2
f01022d8:	000021d0 	.word	0x000021d0
f01022dc:	00002820 	.word	0x00002820
f01022e0:	000020f4 	.word	0x000020f4
f01022e4:	000001f3 	.word	0x000001f3
f01022e8:	000021a4 	.word	0x000021a4
f01022ec:	00002714 	.word	0x00002714
f01022f0:	000020b0 	.word	0x000020b0
f01022f4:	000001f6 	.word	0x000001f6
f01022f8:	00002160 	.word	0x00002160
f01022fc:	000027c4 	.word	0x000027c4
f0102300:	00002080 	.word	0x00002080
f0102304:	000001f9 	.word	0x000001f9
f0102308:	00002130 	.word	0x00002130
f010230c:	0000225c 	.word	0x0000225c
f0102310:	00002044 	.word	0x00002044
f0102314:	000020f4 	.word	0x000020f4
f0102318:	00002338 	.word	0x00002338
f010231c:	00002008 	.word	0x00002008
f0102320:	000001fe 	.word	0x000001fe
f0102324:	000020b8 	.word	0x000020b8
f0102328:	00002370 	.word	0x00002370
f010232c:	01001000 	.word	0x01001000
f0102330:	00001f9c 	.word	0x00001f9c
f0102334:	00000205 	.word	0x00000205
f0102338:	00001f9c 	.word	0x00001f9c
f010233c:	00001f78 	.word	0x00001f78
f0102340:	00000206 	.word	0x00000206
f0102344:	00002028 	.word	0x00002028
f0102348:	000026b0 	.word	0x000026b0
f010234c:	00001f68 	.word	0x00001f68
f0102350:	00001f38 	.word	0x00001f38
f0102354:	00001f00 	.word	0x00001f00
f0102358:	00001ed0 	.word	0x00001ed0
f010235c:	00001e90 	.word	0x00001e90
f0102360:	00001f40 	.word	0x00001f40
f0102364:	000025e0 	.word	0x000025e0
f0102368:	0010d864 	.word	0x0010d864
f010236c:	000025a8 	.word	0x000025a8
f0102370:	00001dec 	.word	0x00001dec
f0102374:	00000147 	.word	0x00000147
f0102378:	00001e9c 	.word	0x00001e9c
f010237c:	00002570 	.word	0x00002570
f0102380:	00000efd 	.word	0x00000efd
f0102384:	00000eff 	.word	0x00000eff
f0102388:	00001d88 	.word	0x00001d88
f010238c:	00000157 	.word	0x00000157
f0102390:	00001e38 	.word	0x00001e38
f0102394:	00002534 	.word	0x00002534
f0102398:	00001d54 	.word	0x00001d54
f010239c:	0000015b 	.word	0x0000015b
f01023a0:	00001e04 	.word	0x00001e04
f01023a4:	00002514 	.word	0x00002514
f01023a8:	00001d2c 	.word	0x00001d2c
f01023ac:	00001ddc 	.word	0x00001ddc
f01023b0:	00002500 	.word	0x00002500
f01023b4:	00001d00 	.word	0x00001d00
f01023b8:	0000015e 	.word	0x0000015e
f01023bc:	00001db0 	.word	0x00001db0
f01023c0:	000024ec 	.word	0x000024ec
f01023c4:	000024e0 	.word	0x000024e0
f01023c8:	00001cb4 	.word	0x00001cb4
f01023cc:	0000022b 	.word	0x0000022b
f01023d0:	00001d64 	.word	0x00001d64
f01023d4:	00001db4 	.word	0x00001db4
f01023d8:	00001c84 	.word	0x00001c84
f01023dc:	00001d34 	.word	0x00001d34
f01023e0:	00001d9c 	.word	0x00001d9c
f01023e4:	00001c54 	.word	0x00001c54
f01023e8:	0000022d 	.word	0x0000022d
f01023ec:	00001d04 	.word	0x00001d04
f01023f0:	00001d84 	.word	0x00001d84
f01023f4:	00001c38 	.word	0x00001c38
f01023f8:	00001c08 	.word	0x00001c08
f01023fc:	00001be8 	.word	0x00001be8
f0102400:	00001bb8 	.word	0x00001bb8
f0102404:	00001b5c 	.word	0x00001b5c
f0102408:	00000232 	.word	0x00000232
f010240c:	00001c0c 	.word	0x00001c0c
f0102410:	00001eb0 	.word	0x00001eb0
f0102414:	01010101 	.word	0x01010101
f0102418:	00001b28 	.word	0x00001b28
f010241c:	00000233 	.word	0x00000233
f0102420:	00001bd8 	.word	0x00001bd8
f0102424:	00002344 	.word	0x00002344
f0102428:	02020202 	.word	0x02020202
f010242c:	00001ad4 	.word	0x00001ad4
f0102430:	00000235 	.word	0x00000235
f0102434:	00001b84 	.word	0x00001b84
f0102438:	00002314 	.word	0x00002314
f010243c:	00001aa8 	.word	0x00001aa8
f0102440:	00000236 	.word	0x00000236
f0102444:	00001b58 	.word	0x00001b58
f0102448:	00001e94 	.word	0x00001e94
f010244c:	00001a7c 	.word	0x00001a7c
f0102450:	00000237 	.word	0x00000237
f0102454:	00001b2c 	.word	0x00001b2c
f0102458:	0000217c 	.word	0x0000217c
f010245c:	0000002c 	.word	0x0000002c
f0102460:	00001a6c 	.word	0x00001a6c
f0102464:	00001a3c 	.word	0x00001a3c
f0102468:	03030303 	.word	0x03030303
f010246c:	00001a10 	.word	0x00001a10
f0102470:	00000239 	.word	0x00000239
f0102474:	00001ac0 	.word	0x00001ac0
f0102478:	00002274 	.word	0x00002274
f010247c:	000019cc 	.word	0x000019cc
f0102480:	0000023b 	.word	0x0000023b
f0102484:	00001a7c 	.word	0x00001a7c
f0102488:	00001fec 	.word	0x00001fec
f010248c:	00001984 	.word	0x00001984
f0102490:	0000023e 	.word	0x0000023e
f0102494:	00001a34 	.word	0x00001a34
f0102498:	00001c78 	.word	0x00001c78
f010249c:	00000030 	.word	0x00000030
f01024a0:	00001948 	.word	0x00001948
f01024a4:	000019f8 	.word	0x000019f8
f01024a8:	00001cb0 	.word	0x00001cb0
f01024ac:	000021bc 	.word	0x000021bc

    // unmapping pp1 at 0 should keep pp1 at PGSIZE
    page_remove(kern_pgdir, 0x0);
f01024b0:	e51f301c 	ldr	r3, [pc, #-28]	; f010249c <mem_init+0x15f8>
f01024b4:	e7943003 	ldr	r3, [r4, r3]
f01024b8:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f01024bc:	e1a00003 	mov	r0, r3
f01024c0:	e3a01000 	mov	r1, #0
f01024c4:	ebfffa2c 	bl	f0100d7c <page_remove>
    assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f01024c8:	e51b0038 	ldr	r0, [fp, #-56]	; 0xffffffc8
f01024cc:	e3a01000 	mov	r1, #0
f01024d0:	ebfff8bf 	bl	f01007d4 <check_va2pa>
f01024d4:	e3700001 	cmn	r0, #1
f01024d8:	0a000007 	beq	f01024fc <mem_init+0x1658>
f01024dc:	e51f0298 	ldr	r0, [pc, #-664]	; f010224c <mem_init+0x13a8>
f01024e0:	e08f0000 	add	r0, pc, r0
f01024e4:	e3a01f79 	mov	r1, #484	; 0x1e4
f01024e8:	e51f22a0 	ldr	r2, [pc, #-672]	; f0102250 <mem_init+0x13ac>
f01024ec:	e08f2002 	add	r2, pc, r2
f01024f0:	e51f32a4 	ldr	r3, [pc, #-676]	; f0102254 <mem_init+0x13b0>
f01024f4:	e08f3003 	add	r3, pc, r3
f01024f8:	ebfff6ea 	bl	f01000a8 <_panic>
    assert(check_va2pa(kern_pgdir, PGSIZE) == page2pa(pp1));
f01024fc:	e51f3068 	ldr	r3, [pc, #-104]	; f010249c <mem_init+0x15f8>
f0102500:	e7943003 	ldr	r3, [r4, r3]
f0102504:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0102508:	e1a00003 	mov	r0, r3
f010250c:	e3a01a01 	mov	r1, #4096	; 0x1000
f0102510:	ebfff8af 	bl	f01007d4 <check_va2pa>
f0102514:	e1590000 	cmp	r9, r0
f0102518:	0a000007 	beq	f010253c <mem_init+0x1698>
f010251c:	e51f02cc 	ldr	r0, [pc, #-716]	; f0102258 <mem_init+0x13b4>
f0102520:	e08f0000 	add	r0, pc, r0
f0102524:	e51f12d0 	ldr	r1, [pc, #-720]	; f010225c <mem_init+0x13b8>
f0102528:	e51f22d0 	ldr	r2, [pc, #-720]	; f0102260 <mem_init+0x13bc>
f010252c:	e08f2002 	add	r2, pc, r2
f0102530:	e51f32d4 	ldr	r3, [pc, #-724]	; f0102264 <mem_init+0x13c0>
f0102534:	e08f3003 	add	r3, pc, r3
f0102538:	ebfff6da 	bl	f01000a8 <_panic>
    assert(pp1->pp_ref == 1);
f010253c:	e1d730b4 	ldrh	r3, [r7, #4]
f0102540:	e3530001 	cmp	r3, #1
f0102544:	0a000007 	beq	f0102568 <mem_init+0x16c4>
f0102548:	e51f02e8 	ldr	r0, [pc, #-744]	; f0102268 <mem_init+0x13c4>
f010254c:	e08f0000 	add	r0, pc, r0
f0102550:	e51f12ec 	ldr	r1, [pc, #-748]	; f010226c <mem_init+0x13c8>
f0102554:	e51f22ec 	ldr	r2, [pc, #-748]	; f0102270 <mem_init+0x13cc>
f0102558:	e08f2002 	add	r2, pc, r2
f010255c:	e51f32f0 	ldr	r3, [pc, #-752]	; f0102274 <mem_init+0x13d0>
f0102560:	e08f3003 	add	r3, pc, r3
f0102564:	ebfff6cf 	bl	f01000a8 <_panic>
    assert(pp2->pp_ref == 0);
f0102568:	e1d630b4 	ldrh	r3, [r6, #4]
f010256c:	e3530000 	cmp	r3, #0
f0102570:	0a000007 	beq	f0102594 <mem_init+0x16f0>
f0102574:	e51f0304 	ldr	r0, [pc, #-772]	; f0102278 <mem_init+0x13d4>
f0102578:	e08f0000 	add	r0, pc, r0
f010257c:	e51f1308 	ldr	r1, [pc, #-776]	; f010227c <mem_init+0x13d8>
f0102580:	e51f2308 	ldr	r2, [pc, #-776]	; f0102280 <mem_init+0x13dc>
f0102584:	e08f2002 	add	r2, pc, r2
f0102588:	e51f330c 	ldr	r3, [pc, #-780]	; f0102284 <mem_init+0x13e0>
f010258c:	e08f3003 	add	r3, pc, r3
f0102590:	ebfff6c4 	bl	f01000a8 <_panic>

    // test re-inserting pp1 at PGSIZE
    assert(page_insert(kern_pgdir, pp1, (void*) PGSIZE, 0) == 0);
f0102594:	e51f3100 	ldr	r3, [pc, #-256]	; f010249c <mem_init+0x15f8>
f0102598:	e7943003 	ldr	r3, [r4, r3]
f010259c:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f01025a0:	e1a00003 	mov	r0, r3
f01025a4:	e1a01007 	mov	r1, r7
f01025a8:	e3a02a01 	mov	r2, #4096	; 0x1000
f01025ac:	e3a03000 	mov	r3, #0
f01025b0:	ebfffa09 	bl	f0100ddc <page_insert>
f01025b4:	e3500000 	cmp	r0, #0
f01025b8:	0a000007 	beq	f01025dc <mem_init+0x1738>
f01025bc:	e51f033c 	ldr	r0, [pc, #-828]	; f0102288 <mem_init+0x13e4>
f01025c0:	e08f0000 	add	r0, pc, r0
f01025c4:	e51f1340 	ldr	r1, [pc, #-832]	; f010228c <mem_init+0x13e8>
f01025c8:	e51f2340 	ldr	r2, [pc, #-832]	; f0102290 <mem_init+0x13ec>
f01025cc:	e08f2002 	add	r2, pc, r2
f01025d0:	e51f3344 	ldr	r3, [pc, #-836]	; f0102294 <mem_init+0x13f0>
f01025d4:	e08f3003 	add	r3, pc, r3
f01025d8:	ebfff6b2 	bl	f01000a8 <_panic>
    assert(pp1->pp_ref);
f01025dc:	e1d730b4 	ldrh	r3, [r7, #4]
f01025e0:	e3530000 	cmp	r3, #0
f01025e4:	1a000007 	bne	f0102608 <mem_init+0x1764>
f01025e8:	e51f0358 	ldr	r0, [pc, #-856]	; f0102298 <mem_init+0x13f4>
f01025ec:	e08f0000 	add	r0, pc, r0
f01025f0:	e51f135c 	ldr	r1, [pc, #-860]	; f010229c <mem_init+0x13f8>
f01025f4:	e51f235c 	ldr	r2, [pc, #-860]	; f01022a0 <mem_init+0x13fc>
f01025f8:	e08f2002 	add	r2, pc, r2
f01025fc:	e51f3360 	ldr	r3, [pc, #-864]	; f01022a4 <mem_init+0x1400>
f0102600:	e08f3003 	add	r3, pc, r3
f0102604:	ebfff6a7 	bl	f01000a8 <_panic>
    assert(pp1->pp_link == NULL);
f0102608:	e5973000 	ldr	r3, [r7]
f010260c:	e3530000 	cmp	r3, #0
f0102610:	0a000007 	beq	f0102634 <mem_init+0x1790>
f0102614:	e51f0374 	ldr	r0, [pc, #-884]	; f01022a8 <mem_init+0x1404>
f0102618:	e08f0000 	add	r0, pc, r0
f010261c:	e3a01f7b 	mov	r1, #492	; 0x1ec
f0102620:	e51f237c 	ldr	r2, [pc, #-892]	; f01022ac <mem_init+0x1408>
f0102624:	e08f2002 	add	r2, pc, r2
f0102628:	e51f3380 	ldr	r3, [pc, #-896]	; f01022b0 <mem_init+0x140c>
f010262c:	e08f3003 	add	r3, pc, r3
f0102630:	ebfff69c 	bl	f01000a8 <_panic>

    // unmapping pp1 at PGSIZE should free it
    page_remove(kern_pgdir, (void*) PGSIZE);
f0102634:	e51f31a0 	ldr	r3, [pc, #-416]	; f010249c <mem_init+0x15f8>
f0102638:	e7943003 	ldr	r3, [r4, r3]
f010263c:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f0102640:	e1a00003 	mov	r0, r3
f0102644:	e3a01a01 	mov	r1, #4096	; 0x1000
f0102648:	ebfff9cb 	bl	f0100d7c <page_remove>
    assert(check_va2pa(kern_pgdir, 0x0) == ~0);
f010264c:	e51b0038 	ldr	r0, [fp, #-56]	; 0xffffffc8
f0102650:	e3a01000 	mov	r1, #0
f0102654:	ebfff85e 	bl	f01007d4 <check_va2pa>
f0102658:	e3700001 	cmn	r0, #1
f010265c:	0a000007 	beq	f0102680 <mem_init+0x17dc>
f0102660:	e51f03b4 	ldr	r0, [pc, #-948]	; f01022b4 <mem_init+0x1410>
f0102664:	e08f0000 	add	r0, pc, r0
f0102668:	e3a01e1f 	mov	r1, #496	; 0x1f0
f010266c:	e51f23bc 	ldr	r2, [pc, #-956]	; f01022b8 <mem_init+0x1414>
f0102670:	e08f2002 	add	r2, pc, r2
f0102674:	e51f33c0 	ldr	r3, [pc, #-960]	; f01022bc <mem_init+0x1418>
f0102678:	e08f3003 	add	r3, pc, r3
f010267c:	ebfff689 	bl	f01000a8 <_panic>
    assert(check_va2pa(kern_pgdir, PGSIZE) == ~0);
f0102680:	e51f31ec 	ldr	r3, [pc, #-492]	; f010249c <mem_init+0x15f8>
f0102684:	e7943003 	ldr	r3, [r4, r3]
f0102688:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f010268c:	e1a00003 	mov	r0, r3
f0102690:	e3a01a01 	mov	r1, #4096	; 0x1000
f0102694:	ebfff84e 	bl	f01007d4 <check_va2pa>
f0102698:	e3700001 	cmn	r0, #1
f010269c:	0a000007 	beq	f01026c0 <mem_init+0x181c>
f01026a0:	e51f03e8 	ldr	r0, [pc, #-1000]	; f01022c0 <mem_init+0x141c>
f01026a4:	e08f0000 	add	r0, pc, r0
f01026a8:	e51f13ec 	ldr	r1, [pc, #-1004]	; f01022c4 <mem_init+0x1420>
f01026ac:	e51f23ec 	ldr	r2, [pc, #-1004]	; f01022c8 <mem_init+0x1424>
f01026b0:	e08f2002 	add	r2, pc, r2
f01026b4:	e51f33f0 	ldr	r3, [pc, #-1008]	; f01022cc <mem_init+0x1428>
f01026b8:	e08f3003 	add	r3, pc, r3
f01026bc:	ebfff679 	bl	f01000a8 <_panic>
    assert(pp1->pp_ref == 0);
f01026c0:	e1d730b4 	ldrh	r3, [r7, #4]
f01026c4:	e3530000 	cmp	r3, #0
f01026c8:	0a000007 	beq	f01026ec <mem_init+0x1848>
f01026cc:	e51f0404 	ldr	r0, [pc, #-1028]	; f01022d0 <mem_init+0x142c>
f01026d0:	e08f0000 	add	r0, pc, r0
f01026d4:	e51f1408 	ldr	r1, [pc, #-1032]	; f01022d4 <mem_init+0x1430>
f01026d8:	e51f2408 	ldr	r2, [pc, #-1032]	; f01022d8 <mem_init+0x1434>
f01026dc:	e08f2002 	add	r2, pc, r2
f01026e0:	e51f340c 	ldr	r3, [pc, #-1036]	; f01022dc <mem_init+0x1438>
f01026e4:	e08f3003 	add	r3, pc, r3
f01026e8:	ebfff66e 	bl	f01000a8 <_panic>
    assert(pp2->pp_ref == 0);
f01026ec:	e1d630b4 	ldrh	r3, [r6, #4]
f01026f0:	e3530000 	cmp	r3, #0
f01026f4:	0a000007 	beq	f0102718 <mem_init+0x1874>
f01026f8:	e51f0420 	ldr	r0, [pc, #-1056]	; f01022e0 <mem_init+0x143c>
f01026fc:	e08f0000 	add	r0, pc, r0
f0102700:	e51f1424 	ldr	r1, [pc, #-1060]	; f01022e4 <mem_init+0x1440>
f0102704:	e51f2424 	ldr	r2, [pc, #-1060]	; f01022e8 <mem_init+0x1444>
f0102708:	e08f2002 	add	r2, pc, r2
f010270c:	e51f3428 	ldr	r3, [pc, #-1064]	; f01022ec <mem_init+0x1448>
f0102710:	e08f3003 	add	r3, pc, r3
f0102714:	ebfff663 	bl	f01000a8 <_panic>

    // so it should be returned by page_alloc
    assert((pp = page_alloc(0)) && pp == pp1);
f0102718:	e3a00000 	mov	r0, #0
f010271c:	ebfff8ba 	bl	f0100a0c <page_alloc>
f0102720:	e0573000 	subs	r3, r7, r0
f0102724:	13a03001 	movne	r3, #1
f0102728:	e3500000 	cmp	r0, #0
f010272c:	11a00003 	movne	r0, r3
f0102730:	03830001 	orreq	r0, r3, #1
f0102734:	e3500000 	cmp	r0, #0
f0102738:	0a000007 	beq	f010275c <mem_init+0x18b8>
f010273c:	e51f0454 	ldr	r0, [pc, #-1108]	; f01022f0 <mem_init+0x144c>
f0102740:	e08f0000 	add	r0, pc, r0
f0102744:	e51f1458 	ldr	r1, [pc, #-1112]	; f01022f4 <mem_init+0x1450>
f0102748:	e51f2458 	ldr	r2, [pc, #-1112]	; f01022f8 <mem_init+0x1454>
f010274c:	e08f2002 	add	r2, pc, r2
f0102750:	e51f345c 	ldr	r3, [pc, #-1116]	; f01022fc <mem_init+0x1458>
f0102754:	e08f3003 	add	r3, pc, r3
f0102758:	ebfff652 	bl	f01000a8 <_panic>

    // should be no free memory
    assert(!page_alloc(0));
f010275c:	e3a00000 	mov	r0, #0
f0102760:	ebfff8a9 	bl	f0100a0c <page_alloc>
f0102764:	e3500000 	cmp	r0, #0
f0102768:	0a000007 	beq	f010278c <mem_init+0x18e8>
f010276c:	e51f0474 	ldr	r0, [pc, #-1140]	; f0102300 <mem_init+0x145c>
f0102770:	e08f0000 	add	r0, pc, r0
f0102774:	e51f1478 	ldr	r1, [pc, #-1144]	; f0102304 <mem_init+0x1460>
f0102778:	e51f2478 	ldr	r2, [pc, #-1144]	; f0102308 <mem_init+0x1464>
f010277c:	e08f2002 	add	r2, pc, r2
f0102780:	e51f347c 	ldr	r3, [pc, #-1148]	; f010230c <mem_init+0x1468>
f0102784:	e08f3003 	add	r3, pc, r3
f0102788:	ebfff646 	bl	f01000a8 <_panic>

    // forcibly take pp0 back
    assert(PTE_SMALL_ADDR(kern_pgdir[0]) == page2pa(pp0));
f010278c:	e51f32f8 	ldr	r3, [pc, #-760]	; f010249c <mem_init+0x15f8>
f0102790:	e7943003 	ldr	r3, [r4, r3]
f0102794:	e5933000 	ldr	r3, [r3]
f0102798:	e3c33eff 	bic	r3, r3, #4080	; 0xff0
f010279c:	e3c3300f 	bic	r3, r3, #15
f01027a0:	e15a0003 	cmp	sl, r3
f01027a4:	0a000007 	beq	f01027c8 <mem_init+0x1924>
f01027a8:	e51f04a0 	ldr	r0, [pc, #-1184]	; f0102310 <mem_init+0x146c>
f01027ac:	e08f0000 	add	r0, pc, r0
f01027b0:	e3a01f7f 	mov	r1, #508	; 0x1fc
f01027b4:	e51f24a8 	ldr	r2, [pc, #-1192]	; f0102314 <mem_init+0x1470>
f01027b8:	e08f2002 	add	r2, pc, r2
f01027bc:	e51f34ac 	ldr	r3, [pc, #-1196]	; f0102318 <mem_init+0x1474>
f01027c0:	e08f3003 	add	r3, pc, r3
f01027c4:	ebfff637 	bl	f01000a8 <_panic>
    kern_pgdir[0] = 0;
f01027c8:	e51f3334 	ldr	r3, [pc, #-820]	; f010249c <mem_init+0x15f8>
f01027cc:	e7943003 	ldr	r3, [r4, r3]
f01027d0:	e3a02000 	mov	r2, #0
f01027d4:	e5832000 	str	r2, [r3]
    assert(pp0->pp_ref == 1);
f01027d8:	e1d830b4 	ldrh	r3, [r8, #4]
f01027dc:	e3530001 	cmp	r3, #1
f01027e0:	0a000007 	beq	f0102804 <mem_init+0x1960>
f01027e4:	e51f04d0 	ldr	r0, [pc, #-1232]	; f010231c <mem_init+0x1478>
f01027e8:	e08f0000 	add	r0, pc, r0
f01027ec:	e51f14d4 	ldr	r1, [pc, #-1236]	; f0102320 <mem_init+0x147c>
f01027f0:	e51f24d4 	ldr	r2, [pc, #-1236]	; f0102324 <mem_init+0x1480>
f01027f4:	e08f2002 	add	r2, pc, r2
f01027f8:	e51f34d8 	ldr	r3, [pc, #-1240]	; f0102328 <mem_init+0x1484>
f01027fc:	e08f3003 	add	r3, pc, r3
f0102800:	ebfff628 	bl	f01000a8 <_panic>
    pp0->pp_ref = 0;
f0102804:	e3a03000 	mov	r3, #0
f0102808:	e1c830b4 	strh	r3, [r8, #4]

    // check pointer arithmetic in pgdir_walk
    page_free(pp0);
f010280c:	e1a00008 	mov	r0, r8
f0102810:	ebfff8ab 	bl	f0100ac4 <page_free>
    va = (void*)(PGSIZE * NPDENTRIES + PGSIZE);
    ptep = pgdir_walk(kern_pgdir, va, 1);
f0102814:	e51f3380 	ldr	r3, [pc, #-896]	; f010249c <mem_init+0x15f8>
f0102818:	e7945003 	ldr	r5, [r4, r3]
f010281c:	e1a00005 	mov	r0, r5
f0102820:	e51f14fc 	ldr	r1, [pc, #-1276]	; f010232c <mem_init+0x1488>
f0102824:	e3a02001 	mov	r2, #1
f0102828:	ebfff8c3 	bl	f0100b3c <pgdir_walk>
f010282c:	e50b0028 	str	r0, [fp, #-40]	; 0xffffffd8
    ptep1 = (pte_t *) KADDR(PTE_SMALL_ADDR(kern_pgdir[PDX(va)]));
f0102830:	e5953040 	ldr	r3, [r5, #64]	; 0x40
f0102834:	e3c33eff 	bic	r3, r3, #4080	; 0xff0
f0102838:	e3c3300f 	bic	r3, r3, #15
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f010283c:	e51f23e8 	ldr	r2, [pc, #-1000]	; f010245c <mem_init+0x15b8>
f0102840:	e7942002 	ldr	r2, [r4, r2]
f0102844:	e5922000 	ldr	r2, [r2]
f0102848:	e1520623 	cmp	r2, r3, lsr #12
f010284c:	8a000005 	bhi	f0102868 <mem_init+0x19c4>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102850:	e51f0528 	ldr	r0, [pc, #-1320]	; f0102330 <mem_init+0x148c>
f0102854:	e08f0000 	add	r0, pc, r0
f0102858:	e51f152c 	ldr	r1, [pc, #-1324]	; f0102334 <mem_init+0x1490>
f010285c:	e51f252c 	ldr	r2, [pc, #-1324]	; f0102338 <mem_init+0x1494>
f0102860:	e08f2002 	add	r2, pc, r2
f0102864:	ebfff60f 	bl	f01000a8 <_panic>
    assert(ptep == ptep1 + PTX(va));
f0102868:	e283324f 	add	r3, r3, #-268435452	; 0xf0000004
f010286c:	e1500003 	cmp	r0, r3
f0102870:	0a000007 	beq	f0102894 <mem_init+0x19f0>
f0102874:	e51f0540 	ldr	r0, [pc, #-1344]	; f010233c <mem_init+0x1498>
f0102878:	e08f0000 	add	r0, pc, r0
f010287c:	e51f1544 	ldr	r1, [pc, #-1348]	; f0102340 <mem_init+0x149c>
f0102880:	e51f2544 	ldr	r2, [pc, #-1348]	; f0102344 <mem_init+0x14a0>
f0102884:	e08f2002 	add	r2, pc, r2
f0102888:	e51f3548 	ldr	r3, [pc, #-1352]	; f0102348 <mem_init+0x14a4>
f010288c:	e08f3003 	add	r3, pc, r3
f0102890:	ebfff604 	bl	f01000a8 <_panic>
    kern_pgdir[PDX(va)] = 0;
f0102894:	e51f3400 	ldr	r3, [pc, #-1024]	; f010249c <mem_init+0x15f8>
f0102898:	e7941003 	ldr	r1, [r4, r3]
f010289c:	e3a03000 	mov	r3, #0
f01028a0:	e5813040 	str	r3, [r1, #64]	; 0x40
    pp0->pp_ref = 0;
f01028a4:	e1c830b4 	strh	r3, [r8, #4]
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f01028a8:	e1a0962a 	lsr	r9, sl, #12
f01028ac:	e1520009 	cmp	r2, r9
f01028b0:	8a000006 	bhi	f01028d0 <mem_init+0x1a2c>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f01028b4:	e51f0570 	ldr	r0, [pc, #-1392]	; f010234c <mem_init+0x14a8>
f01028b8:	e08f0000 	add	r0, pc, r0
f01028bc:	e3a0104f 	mov	r1, #79	; 0x4f
f01028c0:	e51f2578 	ldr	r2, [pc, #-1400]	; f0102350 <mem_init+0x14ac>
f01028c4:	e08f2002 	add	r2, pc, r2
f01028c8:	e1a0300a 	mov	r3, sl
f01028cc:	ebfff5f5 	bl	f01000a8 <_panic>
	return (void *)(pa + KERNBASE);
f01028d0:	e28a520f 	add	r5, sl, #-268435456	; 0xf0000000

    // check that new page tables get cleared
    memset(page2kva(pp0), 0xFF, PGSIZE);
f01028d4:	e1a00005 	mov	r0, r5
f01028d8:	e3a010ff 	mov	r1, #255	; 0xff
f01028dc:	e3a02a01 	mov	r2, #4096	; 0x1000
f01028e0:	eb00057b 	bl	f0103ed4 <memset>
    page_free(pp0);
f01028e4:	e1a00008 	mov	r0, r8
f01028e8:	ebfff875 	bl	f0100ac4 <page_free>
    pgdir_walk(kern_pgdir, 0x0, 1);
f01028ec:	e51f3458 	ldr	r3, [pc, #-1112]	; f010249c <mem_init+0x15f8>
f01028f0:	e7943003 	ldr	r3, [r4, r3]
f01028f4:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
f01028f8:	e1a00003 	mov	r0, r3
f01028fc:	e3a01000 	mov	r1, #0
f0102900:	e3a02001 	mov	r2, #1
f0102904:	ebfff88c 	bl	f0100b3c <pgdir_walk>
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102908:	e51f34b4 	ldr	r3, [pc, #-1204]	; f010245c <mem_init+0x15b8>
f010290c:	e7943003 	ldr	r3, [r4, r3]
f0102910:	e5933000 	ldr	r3, [r3]
f0102914:	e1590003 	cmp	r9, r3
f0102918:	3a000006 	bcc	f0102938 <mem_init+0x1a94>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f010291c:	e51f05d0 	ldr	r0, [pc, #-1488]	; f0102354 <mem_init+0x14b0>
f0102920:	e08f0000 	add	r0, pc, r0
f0102924:	e3a0104f 	mov	r1, #79	; 0x4f
f0102928:	e51f25d8 	ldr	r2, [pc, #-1496]	; f0102358 <mem_init+0x14b4>
f010292c:	e08f2002 	add	r2, pc, r2
f0102930:	e1a0300a 	mov	r3, sl
f0102934:	ebfff5db 	bl	f01000a8 <_panic>
    ptep = (pte_t *) page2kva(pp0);
f0102938:	e50b5028 	str	r5, [fp, #-40]	; 0xffffffd8
    for(i=0; i<NPTENTRIES; i++)
	assert((ptep[i] & PTE_P) == 0);
f010293c:	e5953000 	ldr	r3, [r5]
f0102940:	e3130003 	tst	r3, #3
f0102944:	1a000004 	bne	f010295c <mem_init+0x1ab8>
f0102948:	e28a220f 	add	r2, sl, #-268435456	; 0xf0000000
f010294c:	e2822fff 	add	r2, r2, #1020	; 0x3fc
f0102950:	e5b53004 	ldr	r3, [r5, #4]!
f0102954:	e3130003 	tst	r3, #3
f0102958:	0a000007 	beq	f010297c <mem_init+0x1ad8>
f010295c:	e51f0608 	ldr	r0, [pc, #-1544]	; f010235c <mem_init+0x14b8>
f0102960:	e08f0000 	add	r0, pc, r0
f0102964:	e3a01e21 	mov	r1, #528	; 0x210
f0102968:	e51f2610 	ldr	r2, [pc, #-1552]	; f0102360 <mem_init+0x14bc>
f010296c:	e08f2002 	add	r2, pc, r2
f0102970:	e51f3614 	ldr	r3, [pc, #-1556]	; f0102364 <mem_init+0x14c0>
f0102974:	e08f3003 	add	r3, pc, r3
f0102978:	ebfff5ca 	bl	f01000a8 <_panic>
    // check that new page tables get cleared
    memset(page2kva(pp0), 0xFF, PGSIZE);
    page_free(pp0);
    pgdir_walk(kern_pgdir, 0x0, 1);
    ptep = (pte_t *) page2kva(pp0);
    for(i=0; i<NPTENTRIES; i++)
f010297c:	e1550002 	cmp	r5, r2
f0102980:	1afffff2 	bne	f0102950 <mem_init+0x1aac>
	assert((ptep[i] & PTE_P) == 0);
    kern_pgdir[0] = 0;
f0102984:	e51f34f0 	ldr	r3, [pc, #-1264]	; f010249c <mem_init+0x15f8>
f0102988:	e7942003 	ldr	r2, [r4, r3]
f010298c:	e3a03000 	mov	r3, #0
f0102990:	e5823000 	str	r3, [r2]
    pp0->pp_ref = 0;
f0102994:	e1c830b4 	strh	r3, [r8, #4]

    // give free list back
    page_free_list = fl;
f0102998:	e51f3638 	ldr	r3, [pc, #-1592]	; f0102368 <mem_init+0x14c4>
f010299c:	e08f3003 	add	r3, pc, r3
f01029a0:	e51b203c 	ldr	r2, [fp, #-60]	; 0xffffffc4
f01029a4:	e5832000 	str	r2, [r3]

    // free the pages we took
    page_free(pp0);
f01029a8:	e1a00008 	mov	r0, r8
f01029ac:	ebfff844 	bl	f0100ac4 <page_free>
    page_free(pp1);
f01029b0:	e1a00007 	mov	r0, r7
f01029b4:	ebfff842 	bl	f0100ac4 <page_free>
    page_free(pp2);
f01029b8:	e1a00006 	mov	r0, r6
f01029bc:	ebfff840 	bl	f0100ac4 <page_free>

    cprintf("check_page() succeeded!\n");
f01029c0:	e51f065c 	ldr	r0, [pc, #-1628]	; f010236c <mem_init+0x14c8>
f01029c4:	e08f0000 	add	r0, pc, r0
f01029c8:	ebfff775 	bl	f01007a4 <cprintf>
    for (i = 0; i < n; i += PGSIZE)
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
     */

    // check phys mem
    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f01029cc:	e51f3578 	ldr	r3, [pc, #-1400]	; f010245c <mem_init+0x15b8>
f01029d0:	e7943003 	ldr	r3, [r4, r3]
f01029d4:	e5936000 	ldr	r6, [r3]
f01029d8:	e1b06606 	lsls	r6, r6, #12
f01029dc:	0a000015 	beq	f0102a38 <mem_init+0x1b94>
f01029e0:	e3a05000 	mov	r5, #0
	assert(check_va2pa(pgdir, KERNBASE + i) == i);
f01029e4:	e51f3550 	ldr	r3, [pc, #-1360]	; f010249c <mem_init+0x15f8>
f01029e8:	e7947003 	ldr	r7, [r4, r3]
f01029ec:	e1a00007 	mov	r0, r7
f01029f0:	e285120f 	add	r1, r5, #-268435456	; 0xf0000000
f01029f4:	ebfff776 	bl	f01007d4 <check_va2pa>
f01029f8:	e1550000 	cmp	r5, r0
f01029fc:	0a000007 	beq	f0102a20 <mem_init+0x1b7c>
f0102a00:	e51f0698 	ldr	r0, [pc, #-1688]	; f0102370 <mem_init+0x14cc>
f0102a04:	e08f0000 	add	r0, pc, r0
f0102a08:	e51f169c 	ldr	r1, [pc, #-1692]	; f0102374 <mem_init+0x14d0>
f0102a0c:	e51f269c 	ldr	r2, [pc, #-1692]	; f0102378 <mem_init+0x14d4>
f0102a10:	e08f2002 	add	r2, pc, r2
f0102a14:	e51f36a0 	ldr	r3, [pc, #-1696]	; f010237c <mem_init+0x14d8>
f0102a18:	e08f3003 	add	r3, pc, r3
f0102a1c:	ebfff5a1 	bl	f01000a8 <_panic>
    for (i = 0; i < n; i += PGSIZE)
    assert(check_va2pa(pgdir, UPAGES + i) == PADDR(pages) + i);
     */

    // check phys mem
    for (i = 0; i < npages * PGSIZE; i += PGSIZE)
f0102a20:	e2855a01 	add	r5, r5, #4096	; 0x1000
f0102a24:	e1560005 	cmp	r6, r5
f0102a28:	8affffef 	bhi	f01029ec <mem_init+0x1b48>
f0102a2c:	e51b2034 	ldr	r2, [fp, #-52]	; 0xffffffcc
f0102a30:	e3a03000 	mov	r3, #0
f0102a34:	ea000001 	b	f0102a40 <mem_init+0x1b9c>
f0102a38:	e51b2034 	ldr	r2, [fp, #-52]	; 0xffffffcc
f0102a3c:	e3a03000 	mov	r3, #0
    assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
     */

    // check PDE permissions
    for (i = 0; i < NPDENTRIES; i++) {
	switch (i) {
f0102a40:	e51f06c8 	ldr	r0, [pc, #-1736]	; f0102380 <mem_init+0x14dc>
f0102a44:	e51f16c8 	ldr	r1, [pc, #-1736]	; f0102384 <mem_init+0x14e0>
f0102a48:	e1530000 	cmp	r3, r0
f0102a4c:	0a000001 	beq	f0102a58 <mem_init+0x1bb4>
f0102a50:	e1530001 	cmp	r3, r1
f0102a54:	1a00000a 	bne	f0102a84 <mem_init+0x1be0>
	    //	    case PDX(UVPT):
	    case PDX(KSTACKTOP-1):
		//	    case PDX(UPAGES):
	    case PDX(GPIOBASE):
		assert(pgdir[i] & PTE_P);
f0102a58:	e592c000 	ldr	ip, [r2]
f0102a5c:	e31c0003 	tst	ip, #3
f0102a60:	1a000029 	bne	f0102b0c <mem_init+0x1c68>
f0102a64:	e51f06e4 	ldr	r0, [pc, #-1764]	; f0102388 <mem_init+0x14e4>
f0102a68:	e08f0000 	add	r0, pc, r0
f0102a6c:	e51f16e8 	ldr	r1, [pc, #-1768]	; f010238c <mem_init+0x14e8>
f0102a70:	e51f26e8 	ldr	r2, [pc, #-1768]	; f0102390 <mem_init+0x14ec>
f0102a74:	e08f2002 	add	r2, pc, r2
f0102a78:	e51f36ec 	ldr	r3, [pc, #-1772]	; f0102394 <mem_init+0x14f0>
f0102a7c:	e08f3003 	add	r3, pc, r3
f0102a80:	ebfff588 	bl	f01000a8 <_panic>
		break;
	    default:
		if (i >= PDX(KERNBASE)) {
f0102a84:	e1530001 	cmp	r3, r1
f0102a88:	9a000014 	bls	f0102ae0 <mem_init+0x1c3c>
		    assert(pgdir[i] & PDE_P);
f0102a8c:	e592c000 	ldr	ip, [r2]
f0102a90:	e31c0003 	tst	ip, #3
f0102a94:	1a000007 	bne	f0102ab8 <mem_init+0x1c14>
f0102a98:	e51f0708 	ldr	r0, [pc, #-1800]	; f0102398 <mem_init+0x14f4>
f0102a9c:	e08f0000 	add	r0, pc, r0
f0102aa0:	e51f170c 	ldr	r1, [pc, #-1804]	; f010239c <mem_init+0x14f8>
f0102aa4:	e51f270c 	ldr	r2, [pc, #-1804]	; f01023a0 <mem_init+0x14fc>
f0102aa8:	e08f2002 	add	r2, pc, r2
f0102aac:	e51f3710 	ldr	r3, [pc, #-1808]	; f01023a4 <mem_init+0x1500>
f0102ab0:	e08f3003 	add	r3, pc, r3
f0102ab4:	ebfff57b 	bl	f01000a8 <_panic>
		    assert(pgdir[i] & PDE_NONE_U);
f0102ab8:	e31c0b01 	tst	ip, #1024	; 0x400
f0102abc:	1a000012 	bne	f0102b0c <mem_init+0x1c68>
f0102ac0:	e51f0720 	ldr	r0, [pc, #-1824]	; f01023a8 <mem_init+0x1504>
f0102ac4:	e08f0000 	add	r0, pc, r0
f0102ac8:	e3a01f57 	mov	r1, #348	; 0x15c
f0102acc:	e51f2728 	ldr	r2, [pc, #-1832]	; f01023ac <mem_init+0x1508>
f0102ad0:	e08f2002 	add	r2, pc, r2
f0102ad4:	e51f372c 	ldr	r3, [pc, #-1836]	; f01023b0 <mem_init+0x150c>
f0102ad8:	e08f3003 	add	r3, pc, r3
f0102adc:	ebfff571 	bl	f01000a8 <_panic>
		} else
		    assert(pgdir[i] == 0);
f0102ae0:	e592c000 	ldr	ip, [r2]
f0102ae4:	e35c0000 	cmp	ip, #0
f0102ae8:	0a000007 	beq	f0102b0c <mem_init+0x1c68>
f0102aec:	e51f0740 	ldr	r0, [pc, #-1856]	; f01023b4 <mem_init+0x1510>
f0102af0:	e08f0000 	add	r0, pc, r0
f0102af4:	e51f1744 	ldr	r1, [pc, #-1860]	; f01023b8 <mem_init+0x1514>
f0102af8:	e51f2744 	ldr	r2, [pc, #-1860]	; f01023bc <mem_init+0x1518>
f0102afc:	e08f2002 	add	r2, pc, r2
f0102b00:	e51f3748 	ldr	r3, [pc, #-1864]	; f01023c0 <mem_init+0x151c>
f0102b04:	e08f3003 	add	r3, pc, r3
f0102b08:	ebfff566 	bl	f01000a8 <_panic>
    assert(check_va2pa(pgdir, KSTACKTOP - KSTKSIZE + i) == PADDR(bootstack) + i);
    assert(check_va2pa(pgdir, KSTACKTOP - PTSIZE) == ~0);
     */

    // check PDE permissions
    for (i = 0; i < NPDENTRIES; i++) {
f0102b0c:	e2833001 	add	r3, r3, #1
f0102b10:	e2822004 	add	r2, r2, #4
f0102b14:	e3530a01 	cmp	r3, #4096	; 0x1000
f0102b18:	1affffca 	bne	f0102a48 <mem_init+0x1ba4>
		} else
		    assert(pgdir[i] == 0);
		break;
	}
    }
    cprintf("check_kern_pgdir() succeeded!\n");
f0102b1c:	e51f0760 	ldr	r0, [pc, #-1888]	; f01023c4 <mem_init+0x1520>
f0102b20:	e08f0000 	add	r0, pc, r0
f0102b24:	ebfff71e 	bl	f01007a4 <cprintf>
    uintptr_t va;
    int i;

    // check that we can read and write installed pages
    pp1 = pp2 = 0;
    assert((pp0 = page_alloc(0)));
f0102b28:	e3a00000 	mov	r0, #0
f0102b2c:	ebfff7b6 	bl	f0100a0c <page_alloc>
f0102b30:	e2506000 	subs	r6, r0, #0
f0102b34:	1a000007 	bne	f0102b58 <mem_init+0x1cb4>
f0102b38:	e51f0778 	ldr	r0, [pc, #-1912]	; f01023c8 <mem_init+0x1524>
f0102b3c:	e08f0000 	add	r0, pc, r0
f0102b40:	e51f177c 	ldr	r1, [pc, #-1916]	; f01023cc <mem_init+0x1528>
f0102b44:	e51f277c 	ldr	r2, [pc, #-1916]	; f01023d0 <mem_init+0x152c>
f0102b48:	e08f2002 	add	r2, pc, r2
f0102b4c:	e51f3780 	ldr	r3, [pc, #-1920]	; f01023d4 <mem_init+0x1530>
f0102b50:	e08f3003 	add	r3, pc, r3
f0102b54:	ebfff553 	bl	f01000a8 <_panic>
    assert((pp1 = page_alloc(0)));
f0102b58:	e3a00000 	mov	r0, #0
f0102b5c:	ebfff7aa 	bl	f0100a0c <page_alloc>
f0102b60:	e2508000 	subs	r8, r0, #0
f0102b64:	1a000007 	bne	f0102b88 <mem_init+0x1ce4>
f0102b68:	e51f0798 	ldr	r0, [pc, #-1944]	; f01023d8 <mem_init+0x1534>
f0102b6c:	e08f0000 	add	r0, pc, r0
f0102b70:	e3a01f8b 	mov	r1, #556	; 0x22c
f0102b74:	e51f27a0 	ldr	r2, [pc, #-1952]	; f01023dc <mem_init+0x1538>
f0102b78:	e08f2002 	add	r2, pc, r2
f0102b7c:	e51f37a4 	ldr	r3, [pc, #-1956]	; f01023e0 <mem_init+0x153c>
f0102b80:	e08f3003 	add	r3, pc, r3
f0102b84:	ebfff547 	bl	f01000a8 <_panic>
    assert((pp2 = page_alloc(0)));
f0102b88:	e3a00000 	mov	r0, #0
f0102b8c:	ebfff79e 	bl	f0100a0c <page_alloc>
f0102b90:	e2507000 	subs	r7, r0, #0
f0102b94:	1a000007 	bne	f0102bb8 <mem_init+0x1d14>
f0102b98:	e51f07bc 	ldr	r0, [pc, #-1980]	; f01023e4 <mem_init+0x1540>
f0102b9c:	e08f0000 	add	r0, pc, r0
f0102ba0:	e51f17c0 	ldr	r1, [pc, #-1984]	; f01023e8 <mem_init+0x1544>
f0102ba4:	e51f27c0 	ldr	r2, [pc, #-1984]	; f01023ec <mem_init+0x1548>
f0102ba8:	e08f2002 	add	r2, pc, r2
f0102bac:	e51f37c4 	ldr	r3, [pc, #-1988]	; f01023f0 <mem_init+0x154c>
f0102bb0:	e08f3003 	add	r3, pc, r3
f0102bb4:	ebfff53b 	bl	f01000a8 <_panic>
    page_free(pp0);
f0102bb8:	e1a00006 	mov	r0, r6
f0102bbc:	ebfff7c0 	bl	f0100ac4 <page_free>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102bc0:	e51b3030 	ldr	r3, [fp, #-48]	; 0xffffffd0
f0102bc4:	e0633008 	rsb	r3, r3, r8
f0102bc8:	e1a031c3 	asr	r3, r3, #3
f0102bcc:	e1a03603 	lsl	r3, r3, #12
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102bd0:	e51f277c 	ldr	r2, [pc, #-1916]	; f010245c <mem_init+0x15b8>
f0102bd4:	e7942002 	ldr	r2, [r4, r2]
f0102bd8:	e5922000 	ldr	r2, [r2]
f0102bdc:	e1520623 	cmp	r2, r3, lsr #12
f0102be0:	8a000005 	bhi	f0102bfc <mem_init+0x1d58>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102be4:	e51f07f8 	ldr	r0, [pc, #-2040]	; f01023f4 <mem_init+0x1550>
f0102be8:	e08f0000 	add	r0, pc, r0
f0102bec:	e3a0104f 	mov	r1, #79	; 0x4f
f0102bf0:	e51f2800 	ldr	r2, [pc, #-2048]	; f01023f8 <mem_init+0x1554>
f0102bf4:	e08f2002 	add	r2, pc, r2
f0102bf8:	ebfff52a 	bl	f01000a8 <_panic>
    memset(page2kva(pp1), 1, PGSIZE);
f0102bfc:	e283020f 	add	r0, r3, #-268435456	; 0xf0000000
f0102c00:	e3a01001 	mov	r1, #1
f0102c04:	e3a02a01 	mov	r2, #4096	; 0x1000
f0102c08:	eb0004b1 	bl	f0103ed4 <memset>
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102c0c:	e51b3030 	ldr	r3, [fp, #-48]	; 0xffffffd0
f0102c10:	e0635007 	rsb	r5, r3, r7
f0102c14:	e1a051c5 	asr	r5, r5, #3
f0102c18:	e1a05605 	lsl	r5, r5, #12
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102c1c:	e1a0a625 	lsr	sl, r5, #12
f0102c20:	e51f37cc 	ldr	r3, [pc, #-1996]	; f010245c <mem_init+0x15b8>
f0102c24:	e7943003 	ldr	r3, [r4, r3]
f0102c28:	e5933000 	ldr	r3, [r3]
f0102c2c:	e15a0003 	cmp	sl, r3
f0102c30:	3a000006 	bcc	f0102c50 <mem_init+0x1dac>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102c34:	e51f0840 	ldr	r0, [pc, #-2112]	; f01023fc <mem_init+0x1558>
f0102c38:	e08f0000 	add	r0, pc, r0
f0102c3c:	e3a0104f 	mov	r1, #79	; 0x4f
f0102c40:	e51f2848 	ldr	r2, [pc, #-2120]	; f0102400 <mem_init+0x155c>
f0102c44:	e08f2002 	add	r2, pc, r2
f0102c48:	e1a03005 	mov	r3, r5
f0102c4c:	ebfff515 	bl	f01000a8 <_panic>
	return (void *)(pa + KERNBASE);
f0102c50:	e285920f 	add	r9, r5, #-268435456	; 0xf0000000
    memset(page2kva(pp2), 2, PGSIZE);
f0102c54:	e1a00009 	mov	r0, r9
f0102c58:	e3a01002 	mov	r1, #2
f0102c5c:	e3a02a01 	mov	r2, #4096	; 0x1000
f0102c60:	eb00049b 	bl	f0103ed4 <memset>
    page_insert(kern_pgdir, pp1, (void*) PGSIZE, PTE_NONE_U);
f0102c64:	e51f37d0 	ldr	r3, [pc, #-2000]	; f010249c <mem_init+0x15f8>
f0102c68:	e7943003 	ldr	r3, [r4, r3]
f0102c6c:	e50b3034 	str	r3, [fp, #-52]	; 0xffffffcc
f0102c70:	e1a00003 	mov	r0, r3
f0102c74:	e1a01008 	mov	r1, r8
f0102c78:	e3a02a01 	mov	r2, #4096	; 0x1000
f0102c7c:	e3a03010 	mov	r3, #16
f0102c80:	ebfff855 	bl	f0100ddc <page_insert>
    assert(pp1->pp_ref == 1);
f0102c84:	e1d830b4 	ldrh	r3, [r8, #4]
f0102c88:	e3530001 	cmp	r3, #1
f0102c8c:	0a000007 	beq	f0102cb0 <mem_init+0x1e0c>
f0102c90:	e51f0894 	ldr	r0, [pc, #-2196]	; f0102404 <mem_init+0x1560>
f0102c94:	e08f0000 	add	r0, pc, r0
f0102c98:	e51f1898 	ldr	r1, [pc, #-2200]	; f0102408 <mem_init+0x1564>
f0102c9c:	e51f2898 	ldr	r2, [pc, #-2200]	; f010240c <mem_init+0x1568>
f0102ca0:	e08f2002 	add	r2, pc, r2
f0102ca4:	e51f389c 	ldr	r3, [pc, #-2204]	; f0102410 <mem_init+0x156c>
f0102ca8:	e08f3003 	add	r3, pc, r3
f0102cac:	ebfff4fd 	bl	f01000a8 <_panic>
    assert(*(uint32_t *)PGSIZE == 0x01010101U);
f0102cb0:	e3a03a01 	mov	r3, #4096	; 0x1000
f0102cb4:	e5932000 	ldr	r2, [r3]
f0102cb8:	e51f38ac 	ldr	r3, [pc, #-2220]	; f0102414 <mem_init+0x1570>
f0102cbc:	e1520003 	cmp	r2, r3
f0102cc0:	0a000007 	beq	f0102ce4 <mem_init+0x1e40>
f0102cc4:	e51f08b4 	ldr	r0, [pc, #-2228]	; f0102418 <mem_init+0x1574>
f0102cc8:	e08f0000 	add	r0, pc, r0
f0102ccc:	e51f18b8 	ldr	r1, [pc, #-2232]	; f010241c <mem_init+0x1578>
f0102cd0:	e51f28b8 	ldr	r2, [pc, #-2232]	; f0102420 <mem_init+0x157c>
f0102cd4:	e08f2002 	add	r2, pc, r2
f0102cd8:	e51f38bc 	ldr	r3, [pc, #-2236]	; f0102424 <mem_init+0x1580>
f0102cdc:	e08f3003 	add	r3, pc, r3
f0102ce0:	ebfff4f0 	bl	f01000a8 <_panic>
    page_insert(kern_pgdir, pp2, (void*) PGSIZE, PTE_NONE_U);
f0102ce4:	e51f3850 	ldr	r3, [pc, #-2128]	; f010249c <mem_init+0x15f8>
f0102ce8:	e7943003 	ldr	r3, [r4, r3]
f0102cec:	e50b3034 	str	r3, [fp, #-52]	; 0xffffffcc
f0102cf0:	e1a00003 	mov	r0, r3
f0102cf4:	e1a01007 	mov	r1, r7
f0102cf8:	e3a02a01 	mov	r2, #4096	; 0x1000
f0102cfc:	e3a03010 	mov	r3, #16
f0102d00:	ebfff835 	bl	f0100ddc <page_insert>
    assert(*(uint32_t *)PGSIZE == 0x02020202U);
f0102d04:	e3a03a01 	mov	r3, #4096	; 0x1000
f0102d08:	e5932000 	ldr	r2, [r3]
f0102d0c:	e51f38ec 	ldr	r3, [pc, #-2284]	; f0102428 <mem_init+0x1584>
f0102d10:	e1520003 	cmp	r2, r3
f0102d14:	0a000007 	beq	f0102d38 <mem_init+0x1e94>
f0102d18:	e51f08f4 	ldr	r0, [pc, #-2292]	; f010242c <mem_init+0x1588>
f0102d1c:	e08f0000 	add	r0, pc, r0
f0102d20:	e51f18f8 	ldr	r1, [pc, #-2296]	; f0102430 <mem_init+0x158c>
f0102d24:	e51f28f8 	ldr	r2, [pc, #-2296]	; f0102434 <mem_init+0x1590>
f0102d28:	e08f2002 	add	r2, pc, r2
f0102d2c:	e51f38fc 	ldr	r3, [pc, #-2300]	; f0102438 <mem_init+0x1594>
f0102d30:	e08f3003 	add	r3, pc, r3
f0102d34:	ebfff4db 	bl	f01000a8 <_panic>
    assert(pp2->pp_ref == 1);
f0102d38:	e1d730b4 	ldrh	r3, [r7, #4]
f0102d3c:	e3530001 	cmp	r3, #1
f0102d40:	0a000007 	beq	f0102d64 <mem_init+0x1ec0>
f0102d44:	e51f0910 	ldr	r0, [pc, #-2320]	; f010243c <mem_init+0x1598>
f0102d48:	e08f0000 	add	r0, pc, r0
f0102d4c:	e51f1914 	ldr	r1, [pc, #-2324]	; f0102440 <mem_init+0x159c>
f0102d50:	e51f2914 	ldr	r2, [pc, #-2324]	; f0102444 <mem_init+0x15a0>
f0102d54:	e08f2002 	add	r2, pc, r2
f0102d58:	e51f3918 	ldr	r3, [pc, #-2328]	; f0102448 <mem_init+0x15a4>
f0102d5c:	e08f3003 	add	r3, pc, r3
f0102d60:	ebfff4d0 	bl	f01000a8 <_panic>
    assert(pp1->pp_ref == 0);
f0102d64:	e1d830b4 	ldrh	r3, [r8, #4]
f0102d68:	e3530000 	cmp	r3, #0
f0102d6c:	0a000007 	beq	f0102d90 <mem_init+0x1eec>
f0102d70:	e51f092c 	ldr	r0, [pc, #-2348]	; f010244c <mem_init+0x15a8>
f0102d74:	e08f0000 	add	r0, pc, r0
f0102d78:	e51f1930 	ldr	r1, [pc, #-2352]	; f0102450 <mem_init+0x15ac>
f0102d7c:	e51f2930 	ldr	r2, [pc, #-2352]	; f0102454 <mem_init+0x15b0>
f0102d80:	e08f2002 	add	r2, pc, r2
f0102d84:	e51f3934 	ldr	r3, [pc, #-2356]	; f0102458 <mem_init+0x15b4>
f0102d88:	e08f3003 	add	r3, pc, r3
f0102d8c:	ebfff4c5 	bl	f01000a8 <_panic>
    *(uint32_t *)PGSIZE = 0x03030303U;
f0102d90:	e51f2930 	ldr	r2, [pc, #-2352]	; f0102468 <mem_init+0x15c4>
f0102d94:	e3a03a01 	mov	r3, #4096	; 0x1000
f0102d98:	e5832000 	str	r2, [r3]
#define KADDR(pa) _kaddr(__FILE__, __LINE__, pa)

static inline void*
_kaddr(const char *file, int line, physaddr_t pa)
{
	if (PGNUM(pa) >= npages)
f0102d9c:	e51f3948 	ldr	r3, [pc, #-2376]	; f010245c <mem_init+0x15b8>
f0102da0:	e7943003 	ldr	r3, [r4, r3]
f0102da4:	e5933000 	ldr	r3, [r3]
f0102da8:	e15a0003 	cmp	sl, r3
f0102dac:	3a000006 	bcc	f0102dcc <mem_init+0x1f28>
		_panic(file, line, "KADDR called with invalid pa %08lx", pa);
f0102db0:	e51f0958 	ldr	r0, [pc, #-2392]	; f0102460 <mem_init+0x15bc>
f0102db4:	e08f0000 	add	r0, pc, r0
f0102db8:	e3a0104f 	mov	r1, #79	; 0x4f
f0102dbc:	e51f2960 	ldr	r2, [pc, #-2400]	; f0102464 <mem_init+0x15c0>
f0102dc0:	e08f2002 	add	r2, pc, r2
f0102dc4:	e1a03005 	mov	r3, r5
f0102dc8:	ebfff4b6 	bl	f01000a8 <_panic>
    assert(*(uint32_t *)page2kva(pp2) == 0x03030303U);
f0102dcc:	e5992000 	ldr	r2, [r9]
f0102dd0:	e51f3970 	ldr	r3, [pc, #-2416]	; f0102468 <mem_init+0x15c4>
f0102dd4:	e1520003 	cmp	r2, r3
f0102dd8:	0a000007 	beq	f0102dfc <mem_init+0x1f58>
f0102ddc:	e51f0978 	ldr	r0, [pc, #-2424]	; f010246c <mem_init+0x15c8>
f0102de0:	e08f0000 	add	r0, pc, r0
f0102de4:	e51f197c 	ldr	r1, [pc, #-2428]	; f0102470 <mem_init+0x15cc>
f0102de8:	e51f297c 	ldr	r2, [pc, #-2428]	; f0102474 <mem_init+0x15d0>
f0102dec:	e08f2002 	add	r2, pc, r2
f0102df0:	e51f3980 	ldr	r3, [pc, #-2432]	; f0102478 <mem_init+0x15d4>
f0102df4:	e08f3003 	add	r3, pc, r3
f0102df8:	ebfff4aa 	bl	f01000a8 <_panic>
    page_remove(kern_pgdir, (void*) PGSIZE);
f0102dfc:	e51f3968 	ldr	r3, [pc, #-2408]	; f010249c <mem_init+0x15f8>
f0102e00:	e7943003 	ldr	r3, [r4, r3]
f0102e04:	e50b3034 	str	r3, [fp, #-52]	; 0xffffffcc
f0102e08:	e1a00003 	mov	r0, r3
f0102e0c:	e3a01a01 	mov	r1, #4096	; 0x1000
f0102e10:	ebfff7d9 	bl	f0100d7c <page_remove>
    assert(pp2->pp_ref == 0);
f0102e14:	e1d730b4 	ldrh	r3, [r7, #4]
f0102e18:	e3530000 	cmp	r3, #0
f0102e1c:	0a000007 	beq	f0102e40 <mem_init+0x1f9c>
f0102e20:	e51f09ac 	ldr	r0, [pc, #-2476]	; f010247c <mem_init+0x15d8>
f0102e24:	e08f0000 	add	r0, pc, r0
f0102e28:	e51f19b0 	ldr	r1, [pc, #-2480]	; f0102480 <mem_init+0x15dc>
f0102e2c:	e51f29b0 	ldr	r2, [pc, #-2480]	; f0102484 <mem_init+0x15e0>
f0102e30:	e08f2002 	add	r2, pc, r2
f0102e34:	e51f39b4 	ldr	r3, [pc, #-2484]	; f0102488 <mem_init+0x15e4>
f0102e38:	e08f3003 	add	r3, pc, r3
f0102e3c:	ebfff499 	bl	f01000a8 <_panic>

    // forcibly take pp0 back
    assert(PTE_SMALL_ADDR(kern_pgdir[0]) == page2pa(pp0));
f0102e40:	e51f39ac 	ldr	r3, [pc, #-2476]	; f010249c <mem_init+0x15f8>
f0102e44:	e7943003 	ldr	r3, [r4, r3]
f0102e48:	e5932000 	ldr	r2, [r3]
f0102e4c:	e3c22eff 	bic	r2, r2, #4080	; 0xff0
f0102e50:	e3c2200f 	bic	r2, r2, #15
void	tlb_invalidate(pde_t *pgdir, void *va);

static inline physaddr_t
page2pa(struct PageInfo *pp)
{
	return (pp - pages) << PGSHIFT;
f0102e54:	e51b3030 	ldr	r3, [fp, #-48]	; 0xffffffd0
f0102e58:	e0633006 	rsb	r3, r3, r6
f0102e5c:	e1a031c3 	asr	r3, r3, #3
f0102e60:	e1520603 	cmp	r2, r3, lsl #12
f0102e64:	0a000007 	beq	f0102e88 <mem_init+0x1fe4>
f0102e68:	e51f09e4 	ldr	r0, [pc, #-2532]	; f010248c <mem_init+0x15e8>
f0102e6c:	e08f0000 	add	r0, pc, r0
f0102e70:	e51f19e8 	ldr	r1, [pc, #-2536]	; f0102490 <mem_init+0x15ec>
f0102e74:	e51f29e8 	ldr	r2, [pc, #-2536]	; f0102494 <mem_init+0x15f0>
f0102e78:	e08f2002 	add	r2, pc, r2
f0102e7c:	e51f39ec 	ldr	r3, [pc, #-2540]	; f0102498 <mem_init+0x15f4>
f0102e80:	e08f3003 	add	r3, pc, r3
f0102e84:	ebfff487 	bl	f01000a8 <_panic>
    kern_pgdir[0] = 0;
f0102e88:	e51f39f4 	ldr	r3, [pc, #-2548]	; f010249c <mem_init+0x15f8>
f0102e8c:	e7943003 	ldr	r3, [r4, r3]
f0102e90:	e3a02000 	mov	r2, #0
f0102e94:	e5832000 	str	r2, [r3]
    assert(pp0->pp_ref == 1);
f0102e98:	e1d630b4 	ldrh	r3, [r6, #4]
f0102e9c:	e3530001 	cmp	r3, #1
f0102ea0:	0a000007 	beq	f0102ec4 <mem_init+0x2020>
f0102ea4:	e51f0a0c 	ldr	r0, [pc, #-2572]	; f01024a0 <mem_init+0x15fc>
f0102ea8:	e08f0000 	add	r0, pc, r0
f0102eac:	e3a01d09 	mov	r1, #576	; 0x240
f0102eb0:	e51f2a14 	ldr	r2, [pc, #-2580]	; f01024a4 <mem_init+0x1600>
f0102eb4:	e08f2002 	add	r2, pc, r2
f0102eb8:	e51f3a18 	ldr	r3, [pc, #-2584]	; f01024a8 <mem_init+0x1604>
f0102ebc:	e08f3003 	add	r3, pc, r3
f0102ec0:	ebfff478 	bl	f01000a8 <_panic>
    pp0->pp_ref = 0;
f0102ec4:	e3a03000 	mov	r3, #0
f0102ec8:	e1c630b4 	strh	r3, [r6, #4]

    // free the pages we took
    page_free(pp0);
f0102ecc:	e1a00006 	mov	r0, r6
f0102ed0:	ebfff6fb 	bl	f0100ac4 <page_free>

    cprintf("check_page_installed_pgdir() succeeded!\n");
f0102ed4:	e51f0a30 	ldr	r0, [pc, #-2608]	; f01024ac <mem_init+0x1608>
f0102ed8:	e08f0000 	add	r0, pc, r0
f0102edc:	ebfff630 	bl	f01007a4 <cprintf>
    check_page_free_list();
    check_page_alloc();
    check_page();
    check_kern_pgdir();
    check_page_installed_pgdir();
}
f0102ee0:	e24bd020 	sub	sp, fp, #32
f0102ee4:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}

f0102ee8 <stab_binsearch>:
//	will exit setting left = 118, right = 554.
//
static void
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
f0102ee8:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
f0102eec:	e28db020 	add	fp, sp, #32
f0102ef0:	e59b6004 	ldr	r6, [fp, #4]
	int l = *region_left, r = *region_right, any_matches = 0;
f0102ef4:	e591e000 	ldr	lr, [r1]
f0102ef8:	e5925000 	ldr	r5, [r2]

	while (l <= r) {
f0102efc:	e15e0005 	cmp	lr, r5
f0102f00:	ca000023 	bgt	f0102f94 <stab_binsearch+0xac>
f0102f04:	e3a07000 	mov	r7, #0
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102f08:	e3a08001 	mov	r8, #1
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102f0c:	e08e4005 	add	r4, lr, r5
f0102f10:	e0844fa4 	add	r4, r4, r4, lsr #31
f0102f14:	e1a040c4 	asr	r4, r4, #1

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102f18:	e154000e 	cmp	r4, lr
f0102f1c:	ba000032 	blt	f0102fec <stab_binsearch+0x104>
f0102f20:	e084c084 	add	ip, r4, r4, lsl #1
f0102f24:	e080c10c 	add	ip, r0, ip, lsl #2
f0102f28:	e5dc9004 	ldrb	r9, [ip, #4]
f0102f2c:	e1590003 	cmp	r9, r3
f0102f30:	0a00002f 	beq	f0102ff4 <stab_binsearch+0x10c>
f0102f34:	e1a09004 	mov	r9, r4
			m--;
f0102f38:	e2499001 	sub	r9, r9, #1

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
f0102f3c:	e159000e 	cmp	r9, lr
f0102f40:	ba000029 	blt	f0102fec <stab_binsearch+0x104>
f0102f44:	e55ca008 	ldrb	sl, [ip, #-8]
f0102f48:	e24cc00c 	sub	ip, ip, #12
f0102f4c:	e15a0003 	cmp	sl, r3
f0102f50:	1afffff8 	bne	f0102f38 <stab_binsearch+0x50>
f0102f54:	ea000027 	b	f0102ff8 <stab_binsearch+0x110>
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
			*region_left = m;
f0102f58:	e5819000 	str	r9, [r1]
			l = true_m + 1;
f0102f5c:	e284e001 	add	lr, r4, #1
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102f60:	e1a07008 	mov	r7, r8
f0102f64:	ea000006 	b	f0102f84 <stab_binsearch+0x9c>
		if (stabs[m].n_value < addr) {
			*region_left = m;
			l = true_m + 1;
		} else if (stabs[m].n_value > addr) {
f0102f68:	e15c0006 	cmp	ip, r6
			*region_right = m - 1;
f0102f6c:	82495001 	subhi	r5, r9, #1
f0102f70:	85825000 	strhi	r5, [r2]
			r = m - 1;
		} else {
			// exact match for 'addr', but continue loop to find
			// *region_right
			*region_left = m;
f0102f74:	95819000 	strls	r9, [r1]
			l = m;
			addr++;
f0102f78:	92866001 	addls	r6, r6, #1
f0102f7c:	91a0e009 	movls	lr, r9
			l = true_m + 1;
			continue;
		}

		// actual binary search
		any_matches = 1;
f0102f80:	e1a07008 	mov	r7, r8
stab_binsearch(const struct Stab *stabs, int *region_left, int *region_right,
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
f0102f84:	e155000e 	cmp	r5, lr
f0102f88:	aaffffdf 	bge	f0102f0c <stab_binsearch+0x24>
			l = m;
			addr++;
		}
	}

	if (!any_matches)
f0102f8c:	e3570000 	cmp	r7, #0
f0102f90:	1a000003 	bne	f0102fa4 <stab_binsearch+0xbc>
		*region_right = *region_left - 1;
f0102f94:	e5913000 	ldr	r3, [r1]
f0102f98:	e2433001 	sub	r3, r3, #1
f0102f9c:	e5823000 	str	r3, [r2]
f0102fa0:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102fa4:	e5922000 	ldr	r2, [r2]
		     l > *region_left && stabs[l].n_type != type;
f0102fa8:	e591e000 	ldr	lr, [r1]

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102fac:	e152000e 	cmp	r2, lr
f0102fb0:	da00000b 	ble	f0102fe4 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102fb4:	e082c082 	add	ip, r2, r2, lsl #1
f0102fb8:	e080010c 	add	r0, r0, ip, lsl #2
f0102fbc:	e5d0c004 	ldrb	ip, [r0, #4]
f0102fc0:	e15c0003 	cmp	ip, r3
f0102fc4:	0a000006 	beq	f0102fe4 <stab_binsearch+0xfc>
		     l--)
f0102fc8:	e2422001 	sub	r2, r2, #1

	if (!any_matches)
		*region_right = *region_left - 1;
	else {
		// find rightmost region containing 'addr'
		for (l = *region_right;
f0102fcc:	e152000e 	cmp	r2, lr
f0102fd0:	da000003 	ble	f0102fe4 <stab_binsearch+0xfc>
		     l > *region_left && stabs[l].n_type != type;
f0102fd4:	e550c008 	ldrb	ip, [r0, #-8]
f0102fd8:	e240000c 	sub	r0, r0, #12
f0102fdc:	e15c0003 	cmp	ip, r3
f0102fe0:	1afffff8 	bne	f0102fc8 <stab_binsearch+0xe0>
		     l--)
			/* do nothing */;
		*region_left = l;
f0102fe4:	e5812000 	str	r2, [r1]
f0102fe8:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}

		// search for earliest stab with right type
		while (m >= l && stabs[m].n_type != type)
			m--;
		if (m < l) {	// no match in [l, m]
			l = true_m + 1;
f0102fec:	e284e001 	add	lr, r4, #1
			continue;
f0102ff0:	eaffffe3 	b	f0102f84 <stab_binsearch+0x9c>
	       int type, uintptr_t addr)
{
	int l = *region_left, r = *region_right, any_matches = 0;

	while (l <= r) {
		int true_m = (l + r) / 2, m = true_m;
f0102ff4:	e1a09004 	mov	r9, r4
			continue;
		}

		// actual binary search
		any_matches = 1;
		if (stabs[m].n_value < addr) {
f0102ff8:	e089c089 	add	ip, r9, r9, lsl #1
f0102ffc:	e080c10c 	add	ip, r0, ip, lsl #2
f0103000:	e59cc008 	ldr	ip, [ip, #8]
f0103004:	e15c0006 	cmp	ip, r6
f0103008:	3affffd2 	bcc	f0102f58 <stab_binsearch+0x70>
f010300c:	eaffffd5 	b	f0102f68 <stab_binsearch+0x80>

f0103010 <debuginfo_eip>:
//	negative if not.  But even if it returns negative it has stored some
//	information into '*info'.
//
int
debuginfo_eip(uintptr_t addr, struct Eipdebuginfo *info)
{
f0103010:	e92d48f0 	push	{r4, r5, r6, r7, fp, lr}
f0103014:	e28db014 	add	fp, sp, #20
f0103018:	e24dd020 	sub	sp, sp, #32
f010301c:	e59f52c4 	ldr	r5, [pc, #708]	; f01032e8 <debuginfo_eip+0x2d8>
f0103020:	e08f5005 	add	r5, pc, r5
	const struct Stab *stabs, *stab_end;
	const char *stabstr, *stabstr_end;
	int lfile, rfile, lfun, rfun, lline, rline;

	// Initialize *info
	info->eip_file = "<unknown>";
f0103024:	e59f22c0 	ldr	r2, [pc, #704]	; f01032ec <debuginfo_eip+0x2dc>
f0103028:	e08f2002 	add	r2, pc, r2
f010302c:	e5812000 	str	r2, [r1]
	info->eip_line = 0;
f0103030:	e3a03000 	mov	r3, #0
f0103034:	e5813004 	str	r3, [r1, #4]
	info->eip_fn_name = "<unknown>";
f0103038:	e5812008 	str	r2, [r1, #8]
	info->eip_fn_namelen = 9;
f010303c:	e3a02009 	mov	r2, #9
f0103040:	e581200c 	str	r2, [r1, #12]
	info->eip_fn_addr = addr;
f0103044:	e5810010 	str	r0, [r1, #16]
	info->eip_fn_narg = 0;
f0103048:	e5813014 	str	r3, [r1, #20]
		// Can't search for user-level addresses yet!
  	//        panic("User address");
	//}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
f010304c:	e59f329c 	ldr	r3, [pc, #668]	; f01032f0 <debuginfo_eip+0x2e0>
f0103050:	e7952003 	ldr	r2, [r5, r3]
f0103054:	e59f3298 	ldr	r3, [pc, #664]	; f01032f4 <debuginfo_eip+0x2e4>
f0103058:	e7953003 	ldr	r3, [r5, r3]
f010305c:	e1520003 	cmp	r2, r3
f0103060:	9a000093 	bls	f01032b4 <debuginfo_eip+0x2a4>
f0103064:	e5523001 	ldrb	r3, [r2, #-1]
f0103068:	e3530000 	cmp	r3, #0
f010306c:	1a000092 	bne	f01032bc <debuginfo_eip+0x2ac>
f0103070:	e1a06001 	mov	r6, r1
f0103074:	e1a07000 	mov	r7, r0
	// 'eip'.  First, we find the basic source file containing 'eip'.
	// Then, we look in that source file for the function.  Then we look
	// for the line number.

	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
f0103078:	e50b3018 	str	r3, [fp, #-24]	; 0xffffffe8
	rfile = (stab_end - stabs) - 1;
f010307c:	e59f3274 	ldr	r3, [pc, #628]	; f01032f8 <debuginfo_eip+0x2e8>
f0103080:	e7953003 	ldr	r3, [r5, r3]
f0103084:	e59f2270 	ldr	r2, [pc, #624]	; f01032fc <debuginfo_eip+0x2ec>
f0103088:	e7950002 	ldr	r0, [r5, r2]
f010308c:	e0603003 	rsb	r3, r0, r3
f0103090:	e1a03143 	asr	r3, r3, #2
f0103094:	e0832103 	add	r2, r3, r3, lsl #2
f0103098:	e0822202 	add	r2, r2, r2, lsl #4
f010309c:	e0822402 	add	r2, r2, r2, lsl #8
f01030a0:	e0822802 	add	r2, r2, r2, lsl #16
f01030a4:	e0833082 	add	r3, r3, r2, lsl #1
f01030a8:	e2433001 	sub	r3, r3, #1
f01030ac:	e50b301c 	str	r3, [fp, #-28]	; 0xffffffe4
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
f01030b0:	e58d7000 	str	r7, [sp]
f01030b4:	e24b1018 	sub	r1, fp, #24
f01030b8:	e24b201c 	sub	r2, fp, #28
f01030bc:	e3a03064 	mov	r3, #100	; 0x64
f01030c0:	ebffff88 	bl	f0102ee8 <stab_binsearch>
	if (lfile == 0)
f01030c4:	e51b3018 	ldr	r3, [fp, #-24]	; 0xffffffe8
f01030c8:	e3530000 	cmp	r3, #0
f01030cc:	0a00007c 	beq	f01032c4 <debuginfo_eip+0x2b4>
		return -1;

	// Search within that file's stabs for the function definition
	// (N_FUN).
	lfun = lfile;
f01030d0:	e50b3020 	str	r3, [fp, #-32]	; 0xffffffe0
	rfun = rfile;
f01030d4:	e51b301c 	ldr	r3, [fp, #-28]	; 0xffffffe4
f01030d8:	e50b3024 	str	r3, [fp, #-36]	; 0xffffffdc
	stab_binsearch(stabs, &lfun, &rfun, N_FUN, addr);
f01030dc:	e59f3218 	ldr	r3, [pc, #536]	; f01032fc <debuginfo_eip+0x2ec>
f01030e0:	e7953003 	ldr	r3, [r5, r3]
f01030e4:	e50b3028 	str	r3, [fp, #-40]	; 0xffffffd8
f01030e8:	e58d7000 	str	r7, [sp]
f01030ec:	e1a00003 	mov	r0, r3
f01030f0:	e24b1020 	sub	r1, fp, #32
f01030f4:	e24b2024 	sub	r2, fp, #36	; 0x24
f01030f8:	e3a03024 	mov	r3, #36	; 0x24
f01030fc:	ebffff79 	bl	f0102ee8 <stab_binsearch>

	if (lfun <= rfun) {
f0103100:	e51b4020 	ldr	r4, [fp, #-32]	; 0xffffffe0
f0103104:	e51b3024 	ldr	r3, [fp, #-36]	; 0xffffffdc
f0103108:	e1540003 	cmp	r4, r3
f010310c:	ca000010 	bgt	f0103154 <debuginfo_eip+0x144>
		// stabs[lfun] points to the function name
		// in the string table, but check bounds just in case.
		if (stabs[lfun].n_strx < stabstr_end - stabstr)
f0103110:	e0843084 	add	r3, r4, r4, lsl #1
f0103114:	e1a03103 	lsl	r3, r3, #2
f0103118:	e59f21dc 	ldr	r2, [pc, #476]	; f01032fc <debuginfo_eip+0x2ec>
f010311c:	e7952002 	ldr	r2, [r5, r2]
f0103120:	e0831002 	add	r1, r3, r2
f0103124:	e7932002 	ldr	r2, [r3, r2]
f0103128:	e59f31c0 	ldr	r3, [pc, #448]	; f01032f0 <debuginfo_eip+0x2e0>
f010312c:	e7953003 	ldr	r3, [r5, r3]
f0103130:	e59f01bc 	ldr	r0, [pc, #444]	; f01032f4 <debuginfo_eip+0x2e4>
f0103134:	e7950000 	ldr	r0, [r5, r0]
f0103138:	e0603003 	rsb	r3, r0, r3
f010313c:	e1520003 	cmp	r2, r3
			info->eip_fn_name = stabstr + stabs[lfun].n_strx;
f0103140:	30822000 	addcc	r2, r2, r0
f0103144:	35862008 	strcc	r2, [r6, #8]
		info->eip_fn_addr = stabs[lfun].n_value;
f0103148:	e5913008 	ldr	r3, [r1, #8]
f010314c:	e5863010 	str	r3, [r6, #16]
f0103150:	ea000001 	b	f010315c <debuginfo_eip+0x14c>
		lline = lfun;
		rline = rfun;
	} else {
		// Couldn't find function stab!  Maybe we're in an assembly
		// file.  Search the whole file for the line number.
		info->eip_fn_addr = addr;
f0103154:	e5867010 	str	r7, [r6, #16]
		lline = lfile;
f0103158:	e51b4018 	ldr	r4, [fp, #-24]	; 0xffffffe8
		rline = rfile;
	}
	// Ignore stuff after the colon.
	info->eip_fn_namelen = strfind(info->eip_fn_name, ':') - info->eip_fn_name;
f010315c:	e5960008 	ldr	r0, [r6, #8]
f0103160:	e3a0103a 	mov	r1, #58	; 0x3a
f0103164:	eb00034d 	bl	f0103ea0 <strfind>
f0103168:	e5963008 	ldr	r3, [r6, #8]
f010316c:	e0630000 	rsb	r0, r3, r0
f0103170:	e586000c 	str	r0, [r6, #12]
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f0103174:	e51bc018 	ldr	ip, [fp, #-24]	; 0xffffffe8
f0103178:	e154000c 	cmp	r4, ip
f010317c:	ba00002c 	blt	f0103234 <debuginfo_eip+0x224>
	       && stabs[lline].n_type != N_SOL
f0103180:	e0840084 	add	r0, r4, r4, lsl #1
f0103184:	e1a00100 	lsl	r0, r0, #2
f0103188:	e59f316c 	ldr	r3, [pc, #364]	; f01032fc <debuginfo_eip+0x2ec>
f010318c:	e7953003 	ldr	r3, [r5, r3]
f0103190:	e0833000 	add	r3, r3, r0
f0103194:	e5d31004 	ldrb	r1, [r3, #4]
f0103198:	e3510084 	cmp	r1, #132	; 0x84
f010319c:	0a000018 	beq	f0103204 <debuginfo_eip+0x1f4>
f01031a0:	e240e00c 	sub	lr, r0, #12
f01031a4:	e59f2150 	ldr	r2, [pc, #336]	; f01032fc <debuginfo_eip+0x2ec>
f01031a8:	e7952002 	ldr	r2, [r5, r2]
f01031ac:	e08e2002 	add	r2, lr, r2
f01031b0:	e0630000 	rsb	r0, r3, r0
f01031b4:	e240000c 	sub	r0, r0, #12
f01031b8:	ea00000a 	b	f01031e8 <debuginfo_eip+0x1d8>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
		lline--;
f01031bc:	e2444001 	sub	r4, r4, #1
	// Search backwards from the line number for the relevant filename
	// stab.
	// We can't just use the "lfile" stab because inlined functions
	// can interpolate code from a different file!
	// Such included source files use the N_SOL stab type.
	while (lline >= lfile
f01031c0:	e154000c 	cmp	r4, ip
f01031c4:	ba00001a 	blt	f0103234 <debuginfo_eip+0x224>
f01031c8:	e0833000 	add	r3, r3, r0
f01031cc:	e59f1128 	ldr	r1, [pc, #296]	; f01032fc <debuginfo_eip+0x2ec>
f01031d0:	e7951001 	ldr	r1, [r5, r1]
f01031d4:	e0833001 	add	r3, r3, r1
f01031d8:	e242200c 	sub	r2, r2, #12
	       && stabs[lline].n_type != N_SOL
f01031dc:	e5d21010 	ldrb	r1, [r2, #16]
f01031e0:	e3510084 	cmp	r1, #132	; 0x84
f01031e4:	0a000006 	beq	f0103204 <debuginfo_eip+0x1f4>
	       && (stabs[lline].n_type != N_SO || !stabs[lline].n_value))
f01031e8:	e3510064 	cmp	r1, #100	; 0x64
f01031ec:	1afffff2 	bne	f01031bc <debuginfo_eip+0x1ac>
f01031f0:	e5931008 	ldr	r1, [r3, #8]
f01031f4:	e3510000 	cmp	r1, #0
f01031f8:	0affffef 	beq	f01031bc <debuginfo_eip+0x1ac>
		lline--;
	if (lline >= lfile && stabs[lline].n_strx < stabstr_end - stabstr)
f01031fc:	e15c0004 	cmp	ip, r4
f0103200:	ca00000b 	bgt	f0103234 <debuginfo_eip+0x224>
f0103204:	e0844084 	add	r4, r4, r4, lsl #1
f0103208:	e59f30ec 	ldr	r3, [pc, #236]	; f01032fc <debuginfo_eip+0x2ec>
f010320c:	e7953003 	ldr	r3, [r5, r3]
f0103210:	e7932104 	ldr	r2, [r3, r4, lsl #2]
f0103214:	e59f30d4 	ldr	r3, [pc, #212]	; f01032f0 <debuginfo_eip+0x2e0>
f0103218:	e7953003 	ldr	r3, [r5, r3]
f010321c:	e59f10d0 	ldr	r1, [pc, #208]	; f01032f4 <debuginfo_eip+0x2e4>
f0103220:	e7951001 	ldr	r1, [r5, r1]
f0103224:	e0613003 	rsb	r3, r1, r3
f0103228:	e1520003 	cmp	r2, r3
		info->eip_file = stabstr + stabs[lline].n_strx;
f010322c:	30822001 	addcc	r2, r2, r1
f0103230:	35862000 	strcc	r2, [r6]


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103234:	e51b2020 	ldr	r2, [fp, #-32]	; 0xffffffe0
f0103238:	e51b0024 	ldr	r0, [fp, #-36]	; 0xffffffdc
f010323c:	e1520000 	cmp	r2, r0
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f0103240:	a3a00000 	movge	r0, #0
		info->eip_file = stabstr + stabs[lline].n_strx;


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
f0103244:	aa000025 	bge	f01032e0 <debuginfo_eip+0x2d0>
		for (lline = lfun + 1;
f0103248:	e2822001 	add	r2, r2, #1
f010324c:	e1500002 	cmp	r0, r2
f0103250:	da00001d 	ble	f01032cc <debuginfo_eip+0x2bc>
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f0103254:	e0821082 	add	r1, r2, r2, lsl #1
f0103258:	e1a01101 	lsl	r1, r1, #2
f010325c:	e59f3098 	ldr	r3, [pc, #152]	; f01032fc <debuginfo_eip+0x2ec>
f0103260:	e7953003 	ldr	r3, [r5, r3]
f0103264:	e0833001 	add	r3, r3, r1
f0103268:	e5d33004 	ldrb	r3, [r3, #4]
f010326c:	e35300a0 	cmp	r3, #160	; 0xa0
f0103270:	1a000017 	bne	f01032d4 <debuginfo_eip+0x2c4>
f0103274:	e241100c 	sub	r1, r1, #12
f0103278:	e59f307c 	ldr	r3, [pc, #124]	; f01032fc <debuginfo_eip+0x2ec>
f010327c:	e7953003 	ldr	r3, [r5, r3]
f0103280:	e0811003 	add	r1, r1, r3
		     lline++)
			info->eip_fn_narg++;
f0103284:	e5963014 	ldr	r3, [r6, #20]
f0103288:	e2833001 	add	r3, r3, #1
f010328c:	e5863014 	str	r3, [r6, #20]
	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
f0103290:	e2822001 	add	r2, r2, #1


	// Set eip_fn_narg to the number of arguments taken by the function,
	// or 0 if there was no containing function.
	if (lfun < rfun)
		for (lline = lfun + 1;
f0103294:	e1500002 	cmp	r0, r2
f0103298:	da00000f 	ble	f01032dc <debuginfo_eip+0x2cc>
f010329c:	e281100c 	add	r1, r1, #12
		     lline < rfun && stabs[lline].n_type == N_PSYM;
f01032a0:	e5d13010 	ldrb	r3, [r1, #16]
f01032a4:	e35300a0 	cmp	r3, #160	; 0xa0
f01032a8:	0afffff5 	beq	f0103284 <debuginfo_eip+0x274>
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01032ac:	e3a00000 	mov	r0, #0
f01032b0:	ea00000a 	b	f01032e0 <debuginfo_eip+0x2d0>
  	//        panic("User address");
	//}

	// String table validity checks
	if (stabstr_end <= stabstr || stabstr_end[-1] != 0)
		return -1;
f01032b4:	e3e00000 	mvn	r0, #0
f01032b8:	ea000008 	b	f01032e0 <debuginfo_eip+0x2d0>
f01032bc:	e3e00000 	mvn	r0, #0
f01032c0:	ea000006 	b	f01032e0 <debuginfo_eip+0x2d0>
	// Search the entire set of stabs for the source file (type N_SO).
	lfile = 0;
	rfile = (stab_end - stabs) - 1;
	stab_binsearch(stabs, &lfile, &rfile, N_SO, addr);
	if (lfile == 0)
		return -1;
f01032c4:	e3e00000 	mvn	r0, #0
f01032c8:	ea000004 	b	f01032e0 <debuginfo_eip+0x2d0>
		for (lline = lfun + 1;
		     lline < rfun && stabs[lline].n_type == N_PSYM;
		     lline++)
			info->eip_fn_narg++;

	return 0;
f01032cc:	e3a00000 	mov	r0, #0
f01032d0:	ea000002 	b	f01032e0 <debuginfo_eip+0x2d0>
f01032d4:	e3a00000 	mov	r0, #0
f01032d8:	ea000000 	b	f01032e0 <debuginfo_eip+0x2d0>
f01032dc:	e3a00000 	mov	r0, #0
}
f01032e0:	e24bd014 	sub	sp, fp, #20
f01032e4:	e8bd88f0 	pop	{r4, r5, r6, r7, fp, pc}
f01032e8:	00108fdc 	.word	0x00108fdc
f01032ec:	00002098 	.word	0x00002098
f01032f0:	0000001c 	.word	0x0000001c
f01032f4:	0000000c 	.word	0x0000000c
f01032f8:	00000008 	.word	0x00000008
f01032fc:	00000028 	.word	0x00000028

f0103300 <printnum>:
 * using specified putch function and associated pointer putdat.
 */
static void
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
f0103300:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
f0103304:	e28db020 	add	fp, sp, #32
f0103308:	e24dd01c 	sub	sp, sp, #28
f010330c:	e1a05000 	mov	r5, r0
f0103310:	e1a08001 	mov	r8, r1
f0103314:	e14b22fc 	strd	r2, [fp, #-44]	; 0xffffffd4
f0103318:	e59b9004 	ldr	r9, [fp, #4]
f010331c:	e59b4008 	ldr	r4, [fp, #8]
f0103320:	e59ba00c 	ldr	sl, [fp, #12]
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
f0103324:	e1a06009 	mov	r6, r9
f0103328:	e3a07000 	mov	r7, #0
f010332c:	e1570003 	cmp	r7, r3
f0103330:	01590002 	cmpeq	r9, r2
f0103334:	9a000003 	bls	f0103348 <printnum+0x48>
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f0103338:	e2444001 	sub	r4, r4, #1
f010333c:	e3540000 	cmp	r4, #0
f0103340:	ca00000e 	bgt	f0103380 <printnum+0x80>
f0103344:	ea000012 	b	f0103394 <printnum+0x94>
printnum(void (*putch)(int, void*), void *putdat,
	 unsigned long long num, unsigned base, int width, int padc)
{
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
f0103348:	e14b02dc 	ldrd	r0, [fp, #-44]	; 0xffffffd4
f010334c:	e1a02009 	mov	r2, r9
f0103350:	e1a03007 	mov	r3, r7
f0103354:	eb000380 	bl	f010415c <__aeabi_uldivmod>
f0103358:	e1a02000 	mov	r2, r0
f010335c:	e1a03001 	mov	r3, r1
f0103360:	e58d9000 	str	r9, [sp]
f0103364:	e2444001 	sub	r4, r4, #1
f0103368:	e58d4004 	str	r4, [sp, #4]
f010336c:	e58da008 	str	sl, [sp, #8]
f0103370:	e1a00005 	mov	r0, r5
f0103374:	e1a01008 	mov	r1, r8
f0103378:	ebffffe0 	bl	f0103300 <printnum>
f010337c:	ea000004 	b	f0103394 <printnum+0x94>
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
			putch(padc, putdat);
f0103380:	e1a0000a 	mov	r0, sl
f0103384:	e1a01008 	mov	r1, r8
f0103388:	e12fff35 	blx	r5
	// first recursively print all preceding (more significant) digits
	if (num >= base) {
		printnum(putch, putdat, num / base, base, width - 1, padc);
	} else {
		// print any needed pad characters before first digit
		while (--width > 0)
f010338c:	e2544001 	subs	r4, r4, #1
f0103390:	1afffffa 	bne	f0103380 <printnum+0x80>
			putch(padc, putdat);
	}

	// then print this (the least significant) digit
	putch("0123456789abcdef"[num % base], putdat);
f0103394:	e14b02dc 	ldrd	r0, [fp, #-44]	; 0xffffffd4
f0103398:	e1a02006 	mov	r2, r6
f010339c:	e1a03007 	mov	r3, r7
f01033a0:	eb00036d 	bl	f010415c <__aeabi_uldivmod>
f01033a4:	e59f3014 	ldr	r3, [pc, #20]	; f01033c0 <printnum+0xc0>
f01033a8:	e08f3003 	add	r3, pc, r3
f01033ac:	e7d30002 	ldrb	r0, [r3, r2]
f01033b0:	e1a01008 	mov	r1, r8
f01033b4:	e12fff35 	blx	r5
}
f01033b8:	e24bd020 	sub	sp, fp, #32
f01033bc:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
f01033c0:	00001d24 	.word	0x00001d24

f01033c4 <getuint>:

// Get an unsigned int of various possible sizes from a varargs list,
// depending on the lflag parameter.
static unsigned long long
getuint(va_list *ap, int lflag)
{
f01033c4:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f01033c8:	e28db000 	add	fp, sp, #0
	if (lflag >= 2)
f01033cc:	e3510001 	cmp	r1, #1
f01033d0:	da000007 	ble	f01033f4 <getuint+0x30>
		return va_arg(*ap, unsigned long long);
f01033d4:	e5903000 	ldr	r3, [r0]
f01033d8:	e2833007 	add	r3, r3, #7
f01033dc:	e3c33007 	bic	r3, r3, #7
f01033e0:	e2832008 	add	r2, r3, #8
f01033e4:	e5802000 	str	r2, [r0]
f01033e8:	e5930000 	ldr	r0, [r3]
f01033ec:	e5931004 	ldr	r1, [r3, #4]
f01033f0:	ea000004 	b	f0103408 <getuint+0x44>
	else if (lflag)
		return va_arg(*ap, unsigned long);
	else
		return va_arg(*ap, unsigned int);
f01033f4:	e5903000 	ldr	r3, [r0]
f01033f8:	e2832004 	add	r2, r3, #4
f01033fc:	e5802000 	str	r2, [r0]
f0103400:	e5930000 	ldr	r0, [r3]
f0103404:	e3a01000 	mov	r1, #0
}
f0103408:	e24bd000 	sub	sp, fp, #0
f010340c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103410:	e12fff1e 	bx	lr

f0103414 <sprintputch>:
	int cnt;
};

static void
sprintputch(int ch, struct sprintbuf *b)
{
f0103414:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103418:	e28db000 	add	fp, sp, #0
	b->cnt++;
f010341c:	e5913008 	ldr	r3, [r1, #8]
f0103420:	e2833001 	add	r3, r3, #1
f0103424:	e5813008 	str	r3, [r1, #8]
	if (b->buf < b->ebuf)
f0103428:	e5913000 	ldr	r3, [r1]
f010342c:	e5912004 	ldr	r2, [r1, #4]
f0103430:	e1530002 	cmp	r3, r2
		*b->buf++ = ch;
f0103434:	32832001 	addcc	r2, r3, #1
f0103438:	35812000 	strcc	r2, [r1]
f010343c:	35c30000 	strbcc	r0, [r3]
}
f0103440:	e24bd000 	sub	sp, fp, #0
f0103444:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103448:	e12fff1e 	bx	lr

f010344c <printfmt>:
	}
}

void
printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...)
{
f010344c:	e92d000c 	push	{r2, r3}
f0103450:	e92d4800 	push	{fp, lr}
f0103454:	e28db004 	add	fp, sp, #4
f0103458:	e24dd008 	sub	sp, sp, #8
	va_list ap;

	va_start(ap, fmt);
f010345c:	e28b3008 	add	r3, fp, #8
f0103460:	e50b3008 	str	r3, [fp, #-8]
	vprintfmt(putch, putdat, fmt, ap);
f0103464:	e59b2004 	ldr	r2, [fp, #4]
f0103468:	eb000003 	bl	f010347c <vprintfmt>
	va_end(ap);
}
f010346c:	e24bd004 	sub	sp, fp, #4
f0103470:	e8bd4800 	pop	{fp, lr}
f0103474:	e28dd008 	add	sp, sp, #8
f0103478:	e12fff1e 	bx	lr

f010347c <vprintfmt>:
// Main function to format and print a string.
void printfmt(void (*putch)(int, void*), void *putdat, const char *fmt, ...);

void
vprintfmt(void (*putch)(int, void*), void *putdat, const char *fmt, va_list ap)
{
f010347c:	e92d4ff0 	push	{r4, r5, r6, r7, r8, r9, sl, fp, lr}
f0103480:	e28db020 	add	fp, sp, #32
f0103484:	e24dd034 	sub	sp, sp, #52	; 0x34
f0103488:	e1a05000 	mov	r5, r0
f010348c:	e1a08001 	mov	r8, r1
f0103490:	e1a0a002 	mov	sl, r2
f0103494:	e50b3028 	str	r3, [fp, #-40]	; 0xffffffd8
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
f0103498:	e59f356c 	ldr	r3, [pc, #1388]	; f0103a0c <vprintfmt+0x590>
f010349c:	e08f3003 	add	r3, pc, r3
f01034a0:	e50b3030 	str	r3, [fp, #-48]	; 0xffffffd0
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
				printfmt(putch, putdat, "error %d", err);
f01034a4:	e59f3564 	ldr	r3, [pc, #1380]	; f0103a10 <vprintfmt+0x594>
f01034a8:	e08f3003 	add	r3, pc, r3
f01034ac:	e50b3038 	str	r3, [fp, #-56]	; 0xffffffc8
		// error message
		case 'e':
			err = va_arg(ap, int);
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f01034b0:	e59f355c 	ldr	r3, [pc, #1372]	; f0103a14 <vprintfmt+0x598>
f01034b4:	e08f3003 	add	r3, pc, r3
f01034b8:	e50b3034 	str	r3, [fp, #-52]	; 0xffffffcc
				printfmt(putch, putdat, "error %d", err);
			else
				printfmt(putch, putdat, "%s", p);
f01034bc:	e59f3554 	ldr	r3, [pc, #1364]	; f0103a18 <vprintfmt+0x59c>
f01034c0:	e08f3003 	add	r3, pc, r3
f01034c4:	e50b303c 	str	r3, [fp, #-60]	; 0xffffffc4
f01034c8:	ea000000 	b	f01034d0 <vprintfmt+0x54>
			break;

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
			for (fmt--; fmt[-1] != '%'; fmt--)
f01034cc:	e1a0a006 	mov	sl, r6
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01034d0:	e28a6001 	add	r6, sl, #1
f01034d4:	e5da0000 	ldrb	r0, [sl]
f01034d8:	e3500025 	cmp	r0, #37	; 0x25
f01034dc:	0a000009 	beq	f0103508 <vprintfmt+0x8c>
			if (ch == '\0')
f01034e0:	e3500000 	cmp	r0, #0
f01034e4:	1a000002 	bne	f01034f4 <vprintfmt+0x78>
f01034e8:	ea000145 	b	f0103a04 <vprintfmt+0x588>
f01034ec:	e3500000 	cmp	r0, #0
f01034f0:	0a000143 	beq	f0103a04 <vprintfmt+0x588>
				return;
			putch(ch, putdat);
f01034f4:	e1a01008 	mov	r1, r8
f01034f8:	e12fff35 	blx	r5
	unsigned long long num;
	int base, lflag, width, precision, altflag;
	char padc;

	while (1) {
		while ((ch = *(unsigned char *) fmt++) != '%') {
f01034fc:	e4d60001 	ldrb	r0, [r6], #1
f0103500:	e3500025 	cmp	r0, #37	; 0x25
f0103504:	1afffff8 	bne	f01034ec <vprintfmt+0x70>
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103508:	e3a03020 	mov	r3, #32
f010350c:	e50b302c 	str	r3, [fp, #-44]	; 0xffffffd4
f0103510:	e3a07000 	mov	r7, #0
f0103514:	e3e04000 	mvn	r4, #0
f0103518:	e1a09004 	mov	r9, r4
f010351c:	e1a01007 	mov	r1, r7
f0103520:	e3a0c001 	mov	ip, #1
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f0103524:	e3a0e030 	mov	lr, #48	; 0x30
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {

		// flag to pad on the right
		case '-':
			padc = '-';
f0103528:	e3a0202d 	mov	r2, #45	; 0x2d
f010352c:	ea000001 	b	f0103538 <vprintfmt+0xbc>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103530:	e1a0600a 	mov	r6, sl

		// flag to pad on the right
		case '-':
			padc = '-';
f0103534:	e50b202c 	str	r2, [fp, #-44]	; 0xffffffd4
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103538:	e286a001 	add	sl, r6, #1
f010353c:	e5d60000 	ldrb	r0, [r6]
f0103540:	e2403023 	sub	r3, r0, #35	; 0x23
f0103544:	e3530055 	cmp	r3, #85	; 0x55
f0103548:	908ff103 	addls	pc, pc, r3, lsl #2
f010354c:	ea000119 	b	f01039b8 <vprintfmt+0x53c>
f0103550:	ea00006e 	b	f0103710 <vprintfmt+0x294>
f0103554:	ea000117 	b	f01039b8 <vprintfmt+0x53c>
f0103558:	ea000113 	b	f01039ac <vprintfmt+0x530>
f010355c:	ea000115 	b	f01039b8 <vprintfmt+0x53c>
f0103560:	ea000114 	b	f01039b8 <vprintfmt+0x53c>
f0103564:	ea000113 	b	f01039b8 <vprintfmt+0x53c>
f0103568:	ea000112 	b	f01039b8 <vprintfmt+0x53c>
f010356c:	ea00005e 	b	f01036ec <vprintfmt+0x270>
f0103570:	ea000110 	b	f01039b8 <vprintfmt+0x53c>
f0103574:	ea00010f 	b	f01039b8 <vprintfmt+0x53c>
f0103578:	eaffffec 	b	f0103530 <vprintfmt+0xb4>
f010357c:	ea000060 	b	f0103704 <vprintfmt+0x288>
f0103580:	ea00010c 	b	f01039b8 <vprintfmt+0x53c>
f0103584:	ea000047 	b	f01036a8 <vprintfmt+0x22c>
f0103588:	ea000049 	b	f01036b4 <vprintfmt+0x238>
f010358c:	ea000048 	b	f01036b4 <vprintfmt+0x238>
f0103590:	ea000047 	b	f01036b4 <vprintfmt+0x238>
f0103594:	ea000046 	b	f01036b4 <vprintfmt+0x238>
f0103598:	ea000045 	b	f01036b4 <vprintfmt+0x238>
f010359c:	ea000044 	b	f01036b4 <vprintfmt+0x238>
f01035a0:	ea000043 	b	f01036b4 <vprintfmt+0x238>
f01035a4:	ea000042 	b	f01036b4 <vprintfmt+0x238>
f01035a8:	ea000041 	b	f01036b4 <vprintfmt+0x238>
f01035ac:	ea000101 	b	f01039b8 <vprintfmt+0x53c>
f01035b0:	ea000100 	b	f01039b8 <vprintfmt+0x53c>
f01035b4:	ea0000ff 	b	f01039b8 <vprintfmt+0x53c>
f01035b8:	ea0000fe 	b	f01039b8 <vprintfmt+0x53c>
f01035bc:	ea0000fd 	b	f01039b8 <vprintfmt+0x53c>
f01035c0:	ea0000fc 	b	f01039b8 <vprintfmt+0x53c>
f01035c4:	ea0000fb 	b	f01039b8 <vprintfmt+0x53c>
f01035c8:	ea0000fa 	b	f01039b8 <vprintfmt+0x53c>
f01035cc:	ea0000f9 	b	f01039b8 <vprintfmt+0x53c>
f01035d0:	ea0000f8 	b	f01039b8 <vprintfmt+0x53c>
f01035d4:	ea0000f7 	b	f01039b8 <vprintfmt+0x53c>
f01035d8:	ea0000f6 	b	f01039b8 <vprintfmt+0x53c>
f01035dc:	ea0000f5 	b	f01039b8 <vprintfmt+0x53c>
f01035e0:	ea0000f4 	b	f01039b8 <vprintfmt+0x53c>
f01035e4:	ea0000f3 	b	f01039b8 <vprintfmt+0x53c>
f01035e8:	ea0000f2 	b	f01039b8 <vprintfmt+0x53c>
f01035ec:	ea0000f1 	b	f01039b8 <vprintfmt+0x53c>
f01035f0:	ea0000f0 	b	f01039b8 <vprintfmt+0x53c>
f01035f4:	ea0000ef 	b	f01039b8 <vprintfmt+0x53c>
f01035f8:	ea0000ee 	b	f01039b8 <vprintfmt+0x53c>
f01035fc:	ea0000ed 	b	f01039b8 <vprintfmt+0x53c>
f0103600:	ea0000ec 	b	f01039b8 <vprintfmt+0x53c>
f0103604:	ea0000eb 	b	f01039b8 <vprintfmt+0x53c>
f0103608:	ea0000ea 	b	f01039b8 <vprintfmt+0x53c>
f010360c:	ea0000e9 	b	f01039b8 <vprintfmt+0x53c>
f0103610:	ea0000e8 	b	f01039b8 <vprintfmt+0x53c>
f0103614:	ea0000e7 	b	f01039b8 <vprintfmt+0x53c>
f0103618:	ea0000e6 	b	f01039b8 <vprintfmt+0x53c>
f010361c:	ea0000e5 	b	f01039b8 <vprintfmt+0x53c>
f0103620:	ea0000e4 	b	f01039b8 <vprintfmt+0x53c>
f0103624:	ea0000e3 	b	f01039b8 <vprintfmt+0x53c>
f0103628:	ea0000e2 	b	f01039b8 <vprintfmt+0x53c>
f010362c:	ea0000e1 	b	f01039b8 <vprintfmt+0x53c>
f0103630:	ea0000e0 	b	f01039b8 <vprintfmt+0x53c>
f0103634:	ea0000df 	b	f01039b8 <vprintfmt+0x53c>
f0103638:	ea0000de 	b	f01039b8 <vprintfmt+0x53c>
f010363c:	ea0000dd 	b	f01039b8 <vprintfmt+0x53c>
f0103640:	ea0000dc 	b	f01039b8 <vprintfmt+0x53c>
f0103644:	ea0000db 	b	f01039b8 <vprintfmt+0x53c>
f0103648:	ea0000da 	b	f01039b8 <vprintfmt+0x53c>
f010364c:	ea0000d9 	b	f01039b8 <vprintfmt+0x53c>
f0103650:	ea000039 	b	f010373c <vprintfmt+0x2c0>
f0103654:	ea000092 	b	f01038a4 <vprintfmt+0x428>
f0103658:	ea00003e 	b	f0103758 <vprintfmt+0x2dc>
f010365c:	ea0000d5 	b	f01039b8 <vprintfmt+0x53c>
f0103660:	ea0000d4 	b	f01039b8 <vprintfmt+0x53c>
f0103664:	ea0000d3 	b	f01039b8 <vprintfmt+0x53c>
f0103668:	ea0000d2 	b	f01039b8 <vprintfmt+0x53c>
f010366c:	ea0000d1 	b	f01039b8 <vprintfmt+0x53c>
f0103670:	ea0000d0 	b	f01039b8 <vprintfmt+0x53c>
f0103674:	ea00002d 	b	f0103730 <vprintfmt+0x2b4>
f0103678:	ea0000ce 	b	f01039b8 <vprintfmt+0x53c>
f010367c:	ea0000cd 	b	f01039b8 <vprintfmt+0x53c>
f0103680:	ea0000a8 	b	f0103928 <vprintfmt+0x4ac>
f0103684:	ea0000ad 	b	f0103940 <vprintfmt+0x4c4>
f0103688:	ea0000ca 	b	f01039b8 <vprintfmt+0x53c>
f010368c:	ea0000c9 	b	f01039b8 <vprintfmt+0x53c>
f0103690:	ea000047 	b	f01037b4 <vprintfmt+0x338>
f0103694:	ea0000c7 	b	f01039b8 <vprintfmt+0x53c>
f0103698:	ea00009c 	b	f0103910 <vprintfmt+0x494>
f010369c:	ea0000c5 	b	f01039b8 <vprintfmt+0x53c>
f01036a0:	ea0000c4 	b	f01039b8 <vprintfmt+0x53c>
f01036a4:	ea0000b2 	b	f0103974 <vprintfmt+0x4f8>
f01036a8:	e1a0600a 	mov	r6, sl
			padc = '-';
			goto reswitch;

		// flag to pad with 0's instead of spaces
		case '0':
			padc = '0';
f01036ac:	e50be02c 	str	lr, [fp, #-44]	; 0xffffffd4
f01036b0:	eaffffa0 	b	f0103538 <vprintfmt+0xbc>
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01036b4:	e2404030 	sub	r4, r0, #48	; 0x30
				ch = *fmt;
f01036b8:	e5d63001 	ldrb	r3, [r6, #1]
				if (ch < '0' || ch > '9')
f01036bc:	e2430030 	sub	r0, r3, #48	; 0x30
f01036c0:	e3500009 	cmp	r0, #9
f01036c4:	8a000014 	bhi	f010371c <vprintfmt+0x2a0>
f01036c8:	e1a0600a 	mov	r6, sl
		case '6':
		case '7':
		case '8':
		case '9':
			for (precision = 0; ; ++fmt) {
				precision = precision * 10 + ch - '0';
f01036cc:	e0844104 	add	r4, r4, r4, lsl #2
f01036d0:	e0834084 	add	r4, r3, r4, lsl #1
f01036d4:	e2444030 	sub	r4, r4, #48	; 0x30
				ch = *fmt;
f01036d8:	e5f63001 	ldrb	r3, [r6, #1]!
				if (ch < '0' || ch > '9')
f01036dc:	e2430030 	sub	r0, r3, #48	; 0x30
f01036e0:	e3500009 	cmp	r0, #9
f01036e4:	9afffff8 	bls	f01036cc <vprintfmt+0x250>
f01036e8:	ea00000c 	b	f0103720 <vprintfmt+0x2a4>
					break;
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
f01036ec:	e51b3028 	ldr	r3, [fp, #-40]	; 0xffffffd8
f01036f0:	e2830004 	add	r0, r3, #4
f01036f4:	e50b0028 	str	r0, [fp, #-40]	; 0xffffffd8
f01036f8:	e5934000 	ldr	r4, [r3]
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01036fc:	e1a0600a 	mov	r6, sl
			}
			goto process_precision;

		case '*':
			precision = va_arg(ap, int);
			goto process_precision;
f0103700:	ea000006 	b	f0103720 <vprintfmt+0x2a4>
f0103704:	e1c99fc9 	bic	r9, r9, r9, asr #31
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103708:	e1a0600a 	mov	r6, sl
f010370c:	eaffff89 	b	f0103538 <vprintfmt+0xbc>
f0103710:	e1a0600a 	mov	r6, sl
			if (width < 0)
				width = 0;
			goto reswitch;

		case '#':
			altflag = 1;
f0103714:	e1a0700c 	mov	r7, ip
			goto reswitch;
f0103718:	eaffff86 	b	f0103538 <vprintfmt+0xbc>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f010371c:	e1a0600a 	mov	r6, sl
		case '#':
			altflag = 1;
			goto reswitch;

		process_precision:
			if (width < 0)
f0103720:	e3590000 	cmp	r9, #0
				width = precision, precision = -1;
f0103724:	b1a09004 	movlt	r9, r4
f0103728:	b3e04000 	mvnlt	r4, #0
f010372c:	eaffff81 	b	f0103538 <vprintfmt+0xbc>
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
f0103730:	e2811001 	add	r1, r1, #1
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f0103734:	e1a0600a 	mov	r6, sl
			goto reswitch;

		// long flag (doubled for long long)
		case 'l':
			lflag++;
			goto reswitch;
f0103738:	eaffff7e 	b	f0103538 <vprintfmt+0xbc>

		// character
		case 'c':
			putch(va_arg(ap, int), putdat);
f010373c:	e51b3028 	ldr	r3, [fp, #-40]	; 0xffffffd8
f0103740:	e2832004 	add	r2, r3, #4
f0103744:	e50b2028 	str	r2, [fp, #-40]	; 0xffffffd8
f0103748:	e5930000 	ldr	r0, [r3]
f010374c:	e1a01008 	mov	r1, r8
f0103750:	e12fff35 	blx	r5
			break;
f0103754:	eaffff5d 	b	f01034d0 <vprintfmt+0x54>

		// error message
		case 'e':
			err = va_arg(ap, int);
f0103758:	e51b3028 	ldr	r3, [fp, #-40]	; 0xffffffd8
f010375c:	e2832004 	add	r2, r3, #4
f0103760:	e50b2028 	str	r2, [fp, #-40]	; 0xffffffd8
f0103764:	e5933000 	ldr	r3, [r3]
f0103768:	e3530000 	cmp	r3, #0
f010376c:	b2633000 	rsblt	r3, r3, #0
			if (err < 0)
				err = -err;
			if (err >= MAXERROR || (p = error_string[err]) == NULL)
f0103770:	e3530006 	cmp	r3, #6
f0103774:	ca000003 	bgt	f0103788 <vprintfmt+0x30c>
f0103778:	e51b2034 	ldr	r2, [fp, #-52]	; 0xffffffcc
f010377c:	e792c103 	ldr	ip, [r2, r3, lsl #2]
f0103780:	e35c0000 	cmp	ip, #0
f0103784:	1a000004 	bne	f010379c <vprintfmt+0x320>
				printfmt(putch, putdat, "error %d", err);
f0103788:	e1a00005 	mov	r0, r5
f010378c:	e1a01008 	mov	r1, r8
f0103790:	e51b2038 	ldr	r2, [fp, #-56]	; 0xffffffc8
f0103794:	ebffff2c 	bl	f010344c <printfmt>
f0103798:	eaffff4c 	b	f01034d0 <vprintfmt+0x54>
			else
				printfmt(putch, putdat, "%s", p);
f010379c:	e1a00005 	mov	r0, r5
f01037a0:	e1a01008 	mov	r1, r8
f01037a4:	e51b203c 	ldr	r2, [fp, #-60]	; 0xffffffc4
f01037a8:	e1a0300c 	mov	r3, ip
f01037ac:	ebffff26 	bl	f010344c <printfmt>
f01037b0:	eaffff46 	b	f01034d0 <vprintfmt+0x54>
		width = -1;
		precision = -1;
		lflag = 0;
		altflag = 0;
	reswitch:
		switch (ch = *(unsigned char *) fmt++) {
f01037b4:	e1a01004 	mov	r1, r4
				printfmt(putch, putdat, "%s", p);
			break;

		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
f01037b8:	e51b3028 	ldr	r3, [fp, #-40]	; 0xffffffd8
f01037bc:	e2832004 	add	r2, r3, #4
f01037c0:	e50b2028 	str	r2, [fp, #-40]	; 0xffffffd8
f01037c4:	e5933000 	ldr	r3, [r3]
f01037c8:	e3530000 	cmp	r3, #0
				p = "(null)";
f01037cc:	e51b2030 	ldr	r2, [fp, #-48]	; 0xffffffd0
f01037d0:	01a03002 	moveq	r3, r2
f01037d4:	e50b3040 	str	r3, [fp, #-64]	; 0xffffffc0
			if (width > 0 && padc != '-')
f01037d8:	e51b202c 	ldr	r2, [fp, #-44]	; 0xffffffd4
f01037dc:	e352002d 	cmp	r2, #45	; 0x2d
f01037e0:	13590000 	cmpne	r9, #0
f01037e4:	ca000005 	bgt	f0103800 <vprintfmt+0x384>
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01037e8:	e2836001 	add	r6, r3, #1
f01037ec:	e5d33000 	ldrb	r3, [r3]
f01037f0:	e1a00003 	mov	r0, r3
f01037f4:	e3530000 	cmp	r3, #0
f01037f8:	1a00001e 	bne	f0103878 <vprintfmt+0x3fc>
f01037fc:	ea00001a 	b	f010386c <vprintfmt+0x3f0>
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103800:	e51b0040 	ldr	r0, [fp, #-64]	; 0xffffffc0
f0103804:	eb0000ff 	bl	f0103c08 <strnlen>
f0103808:	e0609009 	rsb	r9, r0, r9
f010380c:	e3590000 	cmp	r9, #0
f0103810:	da000074 	ble	f01039e8 <vprintfmt+0x56c>
					putch(padc, putdat);
f0103814:	e51b002c 	ldr	r0, [fp, #-44]	; 0xffffffd4
f0103818:	e1a01008 	mov	r1, r8
f010381c:	e12fff35 	blx	r5
		// string
		case 's':
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
f0103820:	e2599001 	subs	r9, r9, #1
f0103824:	1afffffa 	bne	f0103814 <vprintfmt+0x398>
f0103828:	ea00006e 	b	f01039e8 <vprintfmt+0x56c>
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
f010382c:	e3570000 	cmp	r7, #0
f0103830:	0a000006 	beq	f0103850 <vprintfmt+0x3d4>
f0103834:	e2433020 	sub	r3, r3, #32
f0103838:	e353005e 	cmp	r3, #94	; 0x5e
f010383c:	9a000003 	bls	f0103850 <vprintfmt+0x3d4>
					putch('?', putdat);
f0103840:	e3a0003f 	mov	r0, #63	; 0x3f
f0103844:	e1a01008 	mov	r1, r8
f0103848:	e12fff35 	blx	r5
f010384c:	ea000001 	b	f0103858 <vprintfmt+0x3dc>
				else
					putch(ch, putdat);
f0103850:	e1a01008 	mov	r1, r8
f0103854:	e12fff35 	blx	r5
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103858:	e2499001 	sub	r9, r9, #1
f010385c:	e4d63001 	ldrb	r3, [r6], #1
f0103860:	e1a00003 	mov	r0, r3
f0103864:	e3530000 	cmp	r3, #0
f0103868:	1a000002 	bne	f0103878 <vprintfmt+0x3fc>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f010386c:	e3590000 	cmp	r9, #0
f0103870:	ca000005 	bgt	f010388c <vprintfmt+0x410>
f0103874:	eaffff15 	b	f01034d0 <vprintfmt+0x54>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f0103878:	e3540000 	cmp	r4, #0
f010387c:	baffffea 	blt	f010382c <vprintfmt+0x3b0>
f0103880:	e2544001 	subs	r4, r4, #1
f0103884:	5affffe8 	bpl	f010382c <vprintfmt+0x3b0>
f0103888:	eafffff7 	b	f010386c <vprintfmt+0x3f0>
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
				putch(' ', putdat);
f010388c:	e3a00020 	mov	r0, #32
f0103890:	e1a01008 	mov	r1, r8
f0103894:	e12fff35 	blx	r5
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
				if (altflag && (ch < ' ' || ch > '~'))
					putch('?', putdat);
				else
					putch(ch, putdat);
			for (; width > 0; width--)
f0103898:	e2599001 	subs	r9, r9, #1
f010389c:	1afffffa 	bne	f010388c <vprintfmt+0x410>
f01038a0:	eaffff0a 	b	f01034d0 <vprintfmt+0x54>
// Same as getuint but signed - can't use getuint
// because of sign extension
static long long
getint(va_list *ap, int lflag)
{
	if (lflag >= 2)
f01038a4:	e3510001 	cmp	r1, #1
f01038a8:	da000006 	ble	f01038c8 <vprintfmt+0x44c>
		return va_arg(*ap, long long);
f01038ac:	e51b3028 	ldr	r3, [fp, #-40]	; 0xffffffd8
f01038b0:	e2833007 	add	r3, r3, #7
f01038b4:	e3c33007 	bic	r3, r3, #7
f01038b8:	e2832008 	add	r2, r3, #8
f01038bc:	e50b2028 	str	r2, [fp, #-40]	; 0xffffffd8
f01038c0:	e1c360d0 	ldrd	r6, [r3]
f01038c4:	ea000004 	b	f01038dc <vprintfmt+0x460>
	else if (lflag)
		return va_arg(*ap, long);
	else
		return va_arg(*ap, int);
f01038c8:	e51b3028 	ldr	r3, [fp, #-40]	; 0xffffffd8
f01038cc:	e2832004 	add	r2, r3, #4
f01038d0:	e50b2028 	str	r2, [fp, #-40]	; 0xffffffd8
f01038d4:	e5936000 	ldr	r6, [r3]
f01038d8:	e1a07fc6 	asr	r7, r6, #31
				putch(' ', putdat);
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
f01038dc:	e1a02006 	mov	r2, r6
f01038e0:	e1a03007 	mov	r3, r7
			if ((long long) num < 0) {
f01038e4:	e3560000 	cmp	r6, #0
f01038e8:	e2d71000 	sbcs	r1, r7, #0
				putch('-', putdat);
				num = -(long long) num;
			}
			base = 10;
f01038ec:	a3a0100a 	movge	r1, #10
			break;

		// (signed) decimal
		case 'd':
			num = getint(&ap, lflag);
			if ((long long) num < 0) {
f01038f0:	aa000025 	bge	f010398c <vprintfmt+0x510>
				putch('-', putdat);
f01038f4:	e3a0002d 	mov	r0, #45	; 0x2d
f01038f8:	e1a01008 	mov	r1, r8
f01038fc:	e12fff35 	blx	r5
				num = -(long long) num;
f0103900:	e2762000 	rsbs	r2, r6, #0
f0103904:	e2e73000 	rsc	r3, r7, #0
			}
			base = 10;
f0103908:	e3a0100a 	mov	r1, #10
f010390c:	ea00001e 	b	f010398c <vprintfmt+0x510>
			goto number;

		// unsigned decimal
		case 'u':
			num = getuint(&ap, lflag);
f0103910:	e24b0028 	sub	r0, fp, #40	; 0x28
f0103914:	ebfffeaa 	bl	f01033c4 <getuint>
f0103918:	e1a02000 	mov	r2, r0
f010391c:	e1a03001 	mov	r3, r1
			base = 10;
f0103920:	e3a0100a 	mov	r1, #10
			goto number;
f0103924:	ea000018 	b	f010398c <vprintfmt+0x510>

		// (unsigned) octal
		case 'o':
			// Replace this with your code.
			num = getuint(&ap, lflag);
f0103928:	e24b0028 	sub	r0, fp, #40	; 0x28
f010392c:	ebfffea4 	bl	f01033c4 <getuint>
f0103930:	e1a02000 	mov	r2, r0
f0103934:	e1a03001 	mov	r3, r1
			base = 8;
f0103938:	e3a01008 	mov	r1, #8
			goto number;
f010393c:	ea000012 	b	f010398c <vprintfmt+0x510>
			break;

		// pointer
		case 'p':
			putch('0', putdat);
f0103940:	e3a00030 	mov	r0, #48	; 0x30
f0103944:	e1a01008 	mov	r1, r8
f0103948:	e12fff35 	blx	r5
			putch('x', putdat);
f010394c:	e3a00078 	mov	r0, #120	; 0x78
f0103950:	e1a01008 	mov	r1, r8
f0103954:	e12fff35 	blx	r5
			num = (unsigned long long)
				(uintptr_t) va_arg(ap, void *);
f0103958:	e51b3028 	ldr	r3, [fp, #-40]	; 0xffffffd8
f010395c:	e2832004 	add	r2, r3, #4
f0103960:	e50b2028 	str	r2, [fp, #-40]	; 0xffffffd8

		// pointer
		case 'p':
			putch('0', putdat);
			putch('x', putdat);
			num = (unsigned long long)
f0103964:	e5932000 	ldr	r2, [r3]
f0103968:	e3a03000 	mov	r3, #0
				(uintptr_t) va_arg(ap, void *);
			base = 16;
f010396c:	e3a01010 	mov	r1, #16
			goto number;
f0103970:	ea000005 	b	f010398c <vprintfmt+0x510>

		// (unsigned) hexadecimal
		case 'x':
			num = getuint(&ap, lflag);
f0103974:	e24b0028 	sub	r0, fp, #40	; 0x28
f0103978:	ebfffe91 	bl	f01033c4 <getuint>
f010397c:	e1a02000 	mov	r2, r0
f0103980:	e1a03001 	mov	r3, r1
			base = 16;
f0103984:	e3a01010 	mov	r1, #16
f0103988:	eaffffff 	b	f010398c <vprintfmt+0x510>
		number:
			printnum(putch, putdat, num, base, width, padc);
f010398c:	e58d1000 	str	r1, [sp]
f0103990:	e58d9004 	str	r9, [sp, #4]
f0103994:	e51b102c 	ldr	r1, [fp, #-44]	; 0xffffffd4
f0103998:	e58d1008 	str	r1, [sp, #8]
f010399c:	e1a00005 	mov	r0, r5
f01039a0:	e1a01008 	mov	r1, r8
f01039a4:	ebfffe55 	bl	f0103300 <printnum>
			break;
f01039a8:	eafffec8 	b	f01034d0 <vprintfmt+0x54>

		// escaped '%' character
		case '%':
			putch(ch, putdat);
f01039ac:	e1a01008 	mov	r1, r8
f01039b0:	e12fff35 	blx	r5
			break;
f01039b4:	eafffec5 	b	f01034d0 <vprintfmt+0x54>

		// unrecognized escape sequence - just print it literally
		default:
			putch('%', putdat);
f01039b8:	e3a00025 	mov	r0, #37	; 0x25
f01039bc:	e1a01008 	mov	r1, r8
f01039c0:	e12fff35 	blx	r5
			for (fmt--; fmt[-1] != '%'; fmt--)
f01039c4:	e5563001 	ldrb	r3, [r6, #-1]
f01039c8:	e3530025 	cmp	r3, #37	; 0x25
f01039cc:	0afffebe 	beq	f01034cc <vprintfmt+0x50>
f01039d0:	e2466001 	sub	r6, r6, #1
f01039d4:	e1a0a006 	mov	sl, r6
f01039d8:	e5763001 	ldrb	r3, [r6, #-1]!
f01039dc:	e3530025 	cmp	r3, #37	; 0x25
f01039e0:	1afffffb 	bne	f01039d4 <vprintfmt+0x558>
f01039e4:	eafffeb9 	b	f01034d0 <vprintfmt+0x54>
			if ((p = va_arg(ap, char *)) == NULL)
				p = "(null)";
			if (width > 0 && padc != '-')
				for (width -= strnlen(p, precision); width > 0; width--)
					putch(padc, putdat);
			for (; (ch = *p++) != '\0' && (precision < 0 || --precision >= 0); width--)
f01039e8:	e51b3040 	ldr	r3, [fp, #-64]	; 0xffffffc0
f01039ec:	e2836001 	add	r6, r3, #1
f01039f0:	e5d33000 	ldrb	r3, [r3]
f01039f4:	e1a00003 	mov	r0, r3
f01039f8:	e3530000 	cmp	r3, #0
f01039fc:	1affff9d 	bne	f0103878 <vprintfmt+0x3fc>
f0103a00:	eafffeb2 	b	f01034d0 <vprintfmt+0x54>
			for (fmt--; fmt[-1] != '%'; fmt--)
				/* do nothing */;
			break;
		}
	}
}
f0103a04:	e24bd020 	sub	sp, fp, #32
f0103a08:	e8bd8ff0 	pop	{r4, r5, r6, r7, r8, r9, sl, fp, pc}
f0103a0c:	00001c44 	.word	0x00001c44
f0103a10:	00001c40 	.word	0x00001c40
f0103a14:	00108bb0 	.word	0x00108bb0
f0103a18:	00001c34 	.word	0x00001c34

f0103a1c <vsnprintf>:
		*b->buf++ = ch;
}

int
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
f0103a1c:	e92d4800 	push	{fp, lr}
f0103a20:	e28db004 	add	fp, sp, #4
f0103a24:	e24dd010 	sub	sp, sp, #16
	struct sprintbuf b = {buf, buf+n-1, 0};
f0103a28:	e50b0010 	str	r0, [fp, #-16]
f0103a2c:	e241c001 	sub	ip, r1, #1
f0103a30:	e080c00c 	add	ip, r0, ip
f0103a34:	e50bc00c 	str	ip, [fp, #-12]
f0103a38:	e3a0c000 	mov	ip, #0
f0103a3c:	e50bc008 	str	ip, [fp, #-8]

	if (buf == NULL || n < 1)
f0103a40:	e150000c 	cmp	r0, ip
f0103a44:	1151000c 	cmpne	r1, ip
f0103a48:	da000008 	ble	f0103a70 <vsnprintf+0x54>
		return -E_INVAL;

	// print the string to the buffer
	vprintfmt((void*)sprintputch, &b, fmt, ap);
f0103a4c:	e59f0028 	ldr	r0, [pc, #40]	; f0103a7c <vsnprintf+0x60>
f0103a50:	e08f0000 	add	r0, pc, r0
f0103a54:	e24b1010 	sub	r1, fp, #16
f0103a58:	ebfffe87 	bl	f010347c <vprintfmt>

	// null terminate the buffer
	*b.buf = '\0';
f0103a5c:	e3a02000 	mov	r2, #0
f0103a60:	e51b3010 	ldr	r3, [fp, #-16]
f0103a64:	e5c32000 	strb	r2, [r3]

	return b.cnt;
f0103a68:	e51b0008 	ldr	r0, [fp, #-8]
f0103a6c:	ea000000 	b	f0103a74 <vsnprintf+0x58>
vsnprintf(char *buf, int n, const char *fmt, va_list ap)
{
	struct sprintbuf b = {buf, buf+n-1, 0};

	if (buf == NULL || n < 1)
		return -E_INVAL;
f0103a70:	e3e00002 	mvn	r0, #2

	// null terminate the buffer
	*b.buf = '\0';

	return b.cnt;
}
f0103a74:	e24bd004 	sub	sp, fp, #4
f0103a78:	e8bd8800 	pop	{fp, pc}
f0103a7c:	fffff9bc 	.word	0xfffff9bc

f0103a80 <snprintf>:

int
snprintf(char *buf, int n, const char *fmt, ...)
{
f0103a80:	e92d000c 	push	{r2, r3}
f0103a84:	e92d4800 	push	{fp, lr}
f0103a88:	e28db004 	add	fp, sp, #4
f0103a8c:	e24dd008 	sub	sp, sp, #8
	va_list ap;
	int rc;

	va_start(ap, fmt);
f0103a90:	e28b3008 	add	r3, fp, #8
f0103a94:	e50b3008 	str	r3, [fp, #-8]
	rc = vsnprintf(buf, n, fmt, ap);
f0103a98:	e59b2004 	ldr	r2, [fp, #4]
f0103a9c:	ebffffde 	bl	f0103a1c <vsnprintf>
	va_end(ap);

	return rc;
}
f0103aa0:	e24bd004 	sub	sp, fp, #4
f0103aa4:	e8bd4800 	pop	{fp, lr}
f0103aa8:	e28dd008 	add	sp, sp, #8
f0103aac:	e12fff1e 	bx	lr

f0103ab0 <readline>:
#define BUFLEN 1024
static char buf[BUFLEN];

char *
readline(const char *prompt)
{
f0103ab0:	e92d4bf0 	push	{r4, r5, r6, r7, r8, r9, fp, lr}
f0103ab4:	e28db01c 	add	fp, sp, #28
	int i, c, echoing;

	if (prompt != NULL)
f0103ab8:	e2501000 	subs	r1, r0, #0
f0103abc:	0a000002 	beq	f0103acc <readline+0x1c>
		cprintf("%s", prompt);
f0103ac0:	e59f00ec 	ldr	r0, [pc, #236]	; f0103bb4 <readline+0x104>
f0103ac4:	e08f0000 	add	r0, pc, r0
f0103ac8:	ebfff335 	bl	f01007a4 <cprintf>

	i = 0;
	echoing = iscons(0);
f0103acc:	e3a00000 	mov	r0, #0
f0103ad0:	ebfff209 	bl	f01002fc <iscons>
f0103ad4:	e1a06000 	mov	r6, r0
	int i, c, echoing;

	if (prompt != NULL)
		cprintf("%s", prompt);

	i = 0;
f0103ad8:	e3a05000 	mov	r5, #0
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
			if (echoing)
				cputchar('\b');
			i--;
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103adc:	e59f70d4 	ldr	r7, [pc, #212]	; f0103bb8 <readline+0x108>
			if (echoing)
				cputchar(c);
			buf[i++] = c;
f0103ae0:	e59f80d4 	ldr	r8, [pc, #212]	; f0103bbc <readline+0x10c>
f0103ae4:	e08f8008 	add	r8, pc, r8
		if (c < 0) {
			cprintf("read error: %e\n", c);
			return NULL;
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
			if (echoing)
				cputchar('\b');
f0103ae8:	e3a09008 	mov	r9, #8
		cprintf("%s", prompt);

	i = 0;
	echoing = iscons(0);
	while (1) {
		c = getchar();
f0103aec:	ebfff1fc 	bl	f01002e4 <getchar>
		if (c < 0) {
f0103af0:	e2504000 	subs	r4, r0, #0
f0103af4:	aa000005 	bge	f0103b10 <readline+0x60>
			cprintf("read error: %e\n", c);
f0103af8:	e59f00c0 	ldr	r0, [pc, #192]	; f0103bc0 <readline+0x110>
f0103afc:	e08f0000 	add	r0, pc, r0
f0103b00:	e1a01004 	mov	r1, r4
f0103b04:	ebfff326 	bl	f01007a4 <cprintf>
			return NULL;
f0103b08:	e3a00000 	mov	r0, #0
f0103b0c:	e8bd8bf0 	pop	{r4, r5, r6, r7, r8, r9, fp, pc}
		} else if ((c == '\b' || c == '\x7f') && i > 0) {
f0103b10:	e3540008 	cmp	r4, #8
f0103b14:	1354007f 	cmpne	r4, #127	; 0x7f
f0103b18:	03a03001 	moveq	r3, #1
f0103b1c:	13a03000 	movne	r3, #0
f0103b20:	e3550000 	cmp	r5, #0
f0103b24:	d3a03000 	movle	r3, #0
f0103b28:	c2033001 	andgt	r3, r3, #1
f0103b2c:	e3530000 	cmp	r3, #0
f0103b30:	0a000005 	beq	f0103b4c <readline+0x9c>
			if (echoing)
f0103b34:	e3560000 	cmp	r6, #0
f0103b38:	0a000001 	beq	f0103b44 <readline+0x94>
				cputchar('\b');
f0103b3c:	e1a00009 	mov	r0, r9
f0103b40:	ebfff1da 	bl	f01002b0 <cputchar>
			i--;
f0103b44:	e2455001 	sub	r5, r5, #1
f0103b48:	eaffffe7 	b	f0103aec <readline+0x3c>
		} else if (c >= ' ' && i < BUFLEN-1) {
f0103b4c:	e1550007 	cmp	r5, r7
f0103b50:	c3a03000 	movgt	r3, #0
f0103b54:	d3a03001 	movle	r3, #1
f0103b58:	e354001f 	cmp	r4, #31
f0103b5c:	d3a03000 	movle	r3, #0
f0103b60:	e3530000 	cmp	r3, #0
f0103b64:	0a000006 	beq	f0103b84 <readline+0xd4>
			if (echoing)
f0103b68:	e3560000 	cmp	r6, #0
f0103b6c:	0a000001 	beq	f0103b78 <readline+0xc8>
				cputchar(c);
f0103b70:	e1a00004 	mov	r0, r4
f0103b74:	ebfff1cd 	bl	f01002b0 <cputchar>
			buf[i++] = c;
f0103b78:	e7c84005 	strb	r4, [r8, r5]
f0103b7c:	e2855001 	add	r5, r5, #1
f0103b80:	eaffffd9 	b	f0103aec <readline+0x3c>
		} else if (c == '\n' || c == '\r') {
f0103b84:	e354000a 	cmp	r4, #10
f0103b88:	1354000d 	cmpne	r4, #13
f0103b8c:	1affffd6 	bne	f0103aec <readline+0x3c>
			if (echoing)
f0103b90:	e3560000 	cmp	r6, #0
f0103b94:	0a000001 	beq	f0103ba0 <readline+0xf0>
				cputchar('\n');
f0103b98:	e3a0000a 	mov	r0, #10
f0103b9c:	ebfff1c3 	bl	f01002b0 <cputchar>
			buf[i] = 0;
f0103ba0:	e59f001c 	ldr	r0, [pc, #28]	; f0103bc4 <readline+0x114>
f0103ba4:	e08f0000 	add	r0, pc, r0
f0103ba8:	e3a03000 	mov	r3, #0
f0103bac:	e7c03005 	strb	r3, [r0, r5]
			return buf;
		}
	}
}
f0103bb0:	e8bd8bf0 	pop	{r4, r5, r6, r7, r8, r9, fp, pc}
f0103bb4:	00001630 	.word	0x00001630
f0103bb8:	000003fe 	.word	0x000003fe
f0103bbc:	0010c724 	.word	0x0010c724
f0103bc0:	0000166c 	.word	0x0000166c
f0103bc4:	0010c664 	.word	0x0010c664

f0103bc8 <strlen>:

#include <inc/string.h>

int
strlen(const char *s)
{
f0103bc8:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103bcc:	e28db000 	add	fp, sp, #0
f0103bd0:	e1a03000 	mov	r3, r0
	int n;

	for (n = 0; *s != '\0'; s++)
f0103bd4:	e5d02000 	ldrb	r2, [r0]
f0103bd8:	e3520000 	cmp	r2, #0
f0103bdc:	0a000005 	beq	f0103bf8 <strlen+0x30>
f0103be0:	e3a00000 	mov	r0, #0
		n++;
f0103be4:	e2800001 	add	r0, r0, #1
int
strlen(const char *s)
{
	int n;

	for (n = 0; *s != '\0'; s++)
f0103be8:	e5f32001 	ldrb	r2, [r3, #1]!
f0103bec:	e3520000 	cmp	r2, #0
f0103bf0:	1afffffb 	bne	f0103be4 <strlen+0x1c>
f0103bf4:	ea000000 	b	f0103bfc <strlen+0x34>
f0103bf8:	e3a00000 	mov	r0, #0
		n++;
	return n;
}
f0103bfc:	e24bd000 	sub	sp, fp, #0
f0103c00:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103c04:	e12fff1e 	bx	lr

f0103c08 <strnlen>:

int
strnlen(const char *s, size_t size)
{
f0103c08:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103c0c:	e28db000 	add	fp, sp, #0
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c10:	e3510000 	cmp	r1, #0
f0103c14:	0a00000c 	beq	f0103c4c <strnlen+0x44>
f0103c18:	e5d03000 	ldrb	r3, [r0]
f0103c1c:	e3530000 	cmp	r3, #0
f0103c20:	0a00000b 	beq	f0103c54 <strnlen+0x4c>
f0103c24:	e2803001 	add	r3, r0, #1
f0103c28:	e0801001 	add	r1, r0, r1
f0103c2c:	e3a00000 	mov	r0, #0
		n++;
f0103c30:	e2800001 	add	r0, r0, #1
int
strnlen(const char *s, size_t size)
{
	int n;

	for (n = 0; size > 0 && *s != '\0'; s++, size--)
f0103c34:	e1530001 	cmp	r3, r1
f0103c38:	0a000006 	beq	f0103c58 <strnlen+0x50>
f0103c3c:	e4d32001 	ldrb	r2, [r3], #1
f0103c40:	e3520000 	cmp	r2, #0
f0103c44:	1afffff9 	bne	f0103c30 <strnlen+0x28>
f0103c48:	ea000002 	b	f0103c58 <strnlen+0x50>
f0103c4c:	e3a00000 	mov	r0, #0
f0103c50:	ea000000 	b	f0103c58 <strnlen+0x50>
f0103c54:	e3a00000 	mov	r0, #0
		n++;
	return n;
}
f0103c58:	e24bd000 	sub	sp, fp, #0
f0103c5c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103c60:	e12fff1e 	bx	lr

f0103c64 <strcpy>:

char *
strcpy(char *dst, const char *src)
{
f0103c64:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103c68:	e28db000 	add	fp, sp, #0
f0103c6c:	e2402001 	sub	r2, r0, #1
	char *ret;

	ret = dst;
	while ((*dst++ = *src++) != '\0')
f0103c70:	e4d13001 	ldrb	r3, [r1], #1
f0103c74:	e5e23001 	strb	r3, [r2, #1]!
f0103c78:	e3530000 	cmp	r3, #0
f0103c7c:	1afffffb 	bne	f0103c70 <strcpy+0xc>
		/* do nothing */;
	return ret;
}
f0103c80:	e24bd000 	sub	sp, fp, #0
f0103c84:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103c88:	e12fff1e 	bx	lr

f0103c8c <strcat>:

char *
strcat(char *dst, const char *src)
{
f0103c8c:	e92d4830 	push	{r4, r5, fp, lr}
f0103c90:	e28db00c 	add	fp, sp, #12
f0103c94:	e1a04000 	mov	r4, r0
f0103c98:	e1a05001 	mov	r5, r1
	int len = strlen(dst);
f0103c9c:	ebffffc9 	bl	f0103bc8 <strlen>
	strcpy(dst + len, src);
f0103ca0:	e0840000 	add	r0, r4, r0
f0103ca4:	e1a01005 	mov	r1, r5
f0103ca8:	ebffffed 	bl	f0103c64 <strcpy>
	return dst;
}
f0103cac:	e1a00004 	mov	r0, r4
f0103cb0:	e8bd8830 	pop	{r4, r5, fp, pc}

f0103cb4 <strncpy>:

char *
strncpy(char *dst, const char *src, size_t size) {
f0103cb4:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103cb8:	e28db000 	add	fp, sp, #0
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103cbc:	e3520000 	cmp	r2, #0
f0103cc0:	0a000008 	beq	f0103ce8 <strncpy+0x34>
f0103cc4:	e0802002 	add	r2, r0, r2
f0103cc8:	e1a03000 	mov	r3, r0
		*dst++ = *src;
f0103ccc:	e5d1c000 	ldrb	ip, [r1]
f0103cd0:	e4c3c001 	strb	ip, [r3], #1
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
f0103cd4:	e5d1c000 	ldrb	ip, [r1]
f0103cd8:	e35c0000 	cmp	ip, #0
			src++;
f0103cdc:	12811001 	addne	r1, r1, #1
strncpy(char *dst, const char *src, size_t size) {
	size_t i;
	char *ret;

	ret = dst;
	for (i = 0; i < size; i++) {
f0103ce0:	e1530002 	cmp	r3, r2
f0103ce4:	1afffff8 	bne	f0103ccc <strncpy+0x18>
		// If strlen(src) < size, null-pad 'dst' out to 'size' chars
		if (*src != '\0')
			src++;
	}
	return ret;
}
f0103ce8:	e24bd000 	sub	sp, fp, #0
f0103cec:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103cf0:	e12fff1e 	bx	lr

f0103cf4 <strlcpy>:

size_t
strlcpy(char *dst, const char *src, size_t size)
{
f0103cf4:	e92d4800 	push	{fp, lr}
f0103cf8:	e28db004 	add	fp, sp, #4
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
f0103cfc:	e3520000 	cmp	r2, #0
f0103d00:	01a0e000 	moveq	lr, r0
f0103d04:	0a000015 	beq	f0103d60 <strlcpy+0x6c>
		while (--size > 0 && *src != '\0')
f0103d08:	e3520001 	cmp	r2, #1
f0103d0c:	0a00000d 	beq	f0103d48 <strlcpy+0x54>
f0103d10:	e5d13000 	ldrb	r3, [r1]
f0103d14:	e3530000 	cmp	r3, #0
f0103d18:	0a00000c 	beq	f0103d50 <strlcpy+0x5c>
f0103d1c:	e1a0c001 	mov	ip, r1
f0103d20:	e2422002 	sub	r2, r2, #2
f0103d24:	e0811002 	add	r1, r1, r2
f0103d28:	e1a0e000 	mov	lr, r0
			*dst++ = *src++;
f0103d2c:	e4ce3001 	strb	r3, [lr], #1
{
	char *dst_in;

	dst_in = dst;
	if (size > 0) {
		while (--size > 0 && *src != '\0')
f0103d30:	e15c0001 	cmp	ip, r1
f0103d34:	0a000006 	beq	f0103d54 <strlcpy+0x60>
f0103d38:	e5fc3001 	ldrb	r3, [ip, #1]!
f0103d3c:	e3530000 	cmp	r3, #0
f0103d40:	1afffff9 	bne	f0103d2c <strlcpy+0x38>
f0103d44:	ea000002 	b	f0103d54 <strlcpy+0x60>
f0103d48:	e1a0e000 	mov	lr, r0
f0103d4c:	ea000000 	b	f0103d54 <strlcpy+0x60>
f0103d50:	e1a0e000 	mov	lr, r0
			*dst++ = *src++;
		*dst = '\0';
f0103d54:	e3a03000 	mov	r3, #0
f0103d58:	e5ce3000 	strb	r3, [lr]
f0103d5c:	eaffffff 	b	f0103d60 <strlcpy+0x6c>
	}
	return dst - dst_in;
}
f0103d60:	e060000e 	rsb	r0, r0, lr
f0103d64:	e8bd8800 	pop	{fp, pc}

f0103d68 <strcmp>:

int
strcmp(const char *p, const char *q)
{
f0103d68:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103d6c:	e28db000 	add	fp, sp, #0
	while (*p && *p == *q)
f0103d70:	e5d03000 	ldrb	r3, [r0]
f0103d74:	e3530000 	cmp	r3, #0
f0103d78:	0a00000b 	beq	f0103dac <strcmp+0x44>
f0103d7c:	e5d12000 	ldrb	r2, [r1]
f0103d80:	e1520003 	cmp	r2, r3
f0103d84:	1a000008 	bne	f0103dac <strcmp+0x44>
f0103d88:	e2812001 	add	r2, r1, #1
		p++, q++;
f0103d8c:	e1a01002 	mov	r1, r2
}

int
strcmp(const char *p, const char *q)
{
	while (*p && *p == *q)
f0103d90:	e5f03001 	ldrb	r3, [r0, #1]!
f0103d94:	e3530000 	cmp	r3, #0
f0103d98:	0a000003 	beq	f0103dac <strcmp+0x44>
f0103d9c:	e2822001 	add	r2, r2, #1
f0103da0:	e5d1c000 	ldrb	ip, [r1]
f0103da4:	e15c0003 	cmp	ip, r3
f0103da8:	0afffff7 	beq	f0103d8c <strcmp+0x24>
		p++, q++;
	return (int) ((unsigned char) *p - (unsigned char) *q);
f0103dac:	e5d10000 	ldrb	r0, [r1]
}
f0103db0:	e0600003 	rsb	r0, r0, r3
f0103db4:	e24bd000 	sub	sp, fp, #0
f0103db8:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103dbc:	e12fff1e 	bx	lr

f0103dc0 <strncmp>:

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103dc0:	e3520000 	cmp	r2, #0
f0103dc4:	0a000016 	beq	f0103e24 <strncmp+0x64>
f0103dc8:	e5d03000 	ldrb	r3, [r0]
f0103dcc:	e3530000 	cmp	r3, #0
f0103dd0:	0a00001b 	beq	f0103e44 <strncmp+0x84>
f0103dd4:	e5d1c000 	ldrb	ip, [r1]
f0103dd8:	e15c0003 	cmp	ip, r3
f0103ddc:	1a000018 	bne	f0103e44 <strncmp+0x84>
	return (int) ((unsigned char) *p - (unsigned char) *q);
}

int
strncmp(const char *p, const char *q, size_t n)
{
f0103de0:	e92d4810 	push	{r4, fp, lr}
f0103de4:	e28db008 	add	fp, sp, #8
f0103de8:	e2813001 	add	r3, r1, #1
f0103dec:	e280c001 	add	ip, r0, #1
f0103df0:	e0812002 	add	r2, r1, r2
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
f0103df4:	e1a0000c 	mov	r0, ip
f0103df8:	e1a01003 	mov	r1, r3
}

int
strncmp(const char *p, const char *q, size_t n)
{
	while (n > 0 && *p && *p == *q)
f0103dfc:	e1530002 	cmp	r3, r2
f0103e00:	0a000009 	beq	f0103e2c <strncmp+0x6c>
f0103e04:	e4dce001 	ldrb	lr, [ip], #1
f0103e08:	e35e0000 	cmp	lr, #0
f0103e0c:	0a000008 	beq	f0103e34 <strncmp+0x74>
f0103e10:	e2833001 	add	r3, r3, #1
f0103e14:	e5d14000 	ldrb	r4, [r1]
f0103e18:	e154000e 	cmp	r4, lr
f0103e1c:	0afffff4 	beq	f0103df4 <strncmp+0x34>
f0103e20:	ea000003 	b	f0103e34 <strncmp+0x74>
		n--, p++, q++;
	if (n == 0)
		return 0;
f0103e24:	e3a00000 	mov	r0, #0
f0103e28:	e12fff1e 	bx	lr
f0103e2c:	e3a00000 	mov	r0, #0
f0103e30:	e8bd8810 	pop	{r4, fp, pc}
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103e34:	e5d03000 	ldrb	r3, [r0]
f0103e38:	e5d10000 	ldrb	r0, [r1]
f0103e3c:	e0600003 	rsb	r0, r0, r3
}
f0103e40:	e8bd8810 	pop	{r4, fp, pc}
	while (n > 0 && *p && *p == *q)
		n--, p++, q++;
	if (n == 0)
		return 0;
	else
		return (int) ((unsigned char) *p - (unsigned char) *q);
f0103e44:	e5d03000 	ldrb	r3, [r0]
f0103e48:	e5d10000 	ldrb	r0, [r1]
f0103e4c:	e0600003 	rsb	r0, r0, r3
}
f0103e50:	e12fff1e 	bx	lr

f0103e54 <strchr>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
f0103e54:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103e58:	e28db000 	add	fp, sp, #0
	for (; *s; s++)
f0103e5c:	e5d03000 	ldrb	r3, [r0]
f0103e60:	e3530000 	cmp	r3, #0
f0103e64:	0a000009 	beq	f0103e90 <strchr+0x3c>
		if (*s == c)
f0103e68:	e1530001 	cmp	r3, r1
f0103e6c:	1a000002 	bne	f0103e7c <strchr+0x28>
f0103e70:	ea000007 	b	f0103e94 <strchr+0x40>
f0103e74:	e1530001 	cmp	r3, r1
f0103e78:	0a000005 	beq	f0103e94 <strchr+0x40>
// Return a pointer to the first occurrence of 'c' in 's',
// or a null pointer if the string has no 'c'.
char *
strchr(const char *s, char c)
{
	for (; *s; s++)
f0103e7c:	e5f03001 	ldrb	r3, [r0, #1]!
f0103e80:	e3530000 	cmp	r3, #0
f0103e84:	1afffffa 	bne	f0103e74 <strchr+0x20>
		if (*s == c)
			return (char *) s;
	return 0;
f0103e88:	e3a00000 	mov	r0, #0
f0103e8c:	ea000000 	b	f0103e94 <strchr+0x40>
f0103e90:	e3a00000 	mov	r0, #0
}
f0103e94:	e24bd000 	sub	sp, fp, #0
f0103e98:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103e9c:	e12fff1e 	bx	lr

f0103ea0 <strfind>:

// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
f0103ea0:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103ea4:	e28db000 	add	fp, sp, #0
	for (; *s; s++)
f0103ea8:	e5d03000 	ldrb	r3, [r0]
		if (*s == c)
f0103eac:	e1530001 	cmp	r3, r1
f0103eb0:	13530000 	cmpne	r3, #0
f0103eb4:	0a000003 	beq	f0103ec8 <strfind+0x28>
// Return a pointer to the first occurrence of 'c' in 's',
// or a pointer to the string-ending null character if the string has no 'c'.
char *
strfind(const char *s, char c)
{
	for (; *s; s++)
f0103eb8:	e5f03001 	ldrb	r3, [r0, #1]!
		if (*s == c)
f0103ebc:	e3530000 	cmp	r3, #0
f0103ec0:	11530001 	cmpne	r3, r1
f0103ec4:	1afffffb 	bne	f0103eb8 <strfind+0x18>
			break;
	return (char *) s;
}
f0103ec8:	e24bd000 	sub	sp, fp, #0
f0103ecc:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103ed0:	e12fff1e 	bx	lr

f0103ed4 <memset>:

void *
memset(void *v, int c, size_t n)
{
f0103ed4:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103ed8:	e28db000 	add	fp, sp, #0
	char *p;
	int m;

	p = v;
	m = n;
	while (m-- > 0)
f0103edc:	e3520000 	cmp	r2, #0
f0103ee0:	da000004 	ble	f0103ef8 <memset+0x24>
f0103ee4:	e0802002 	add	r2, r0, r2
f0103ee8:	e1a03000 	mov	r3, r0
		*p++ = c;
f0103eec:	e4c31001 	strb	r1, [r3], #1
	char *p;
	int m;

	p = v;
	m = n;
	while (m-- > 0)
f0103ef0:	e1530002 	cmp	r3, r2
f0103ef4:	1afffffc 	bne	f0103eec <memset+0x18>
		*p++ = c;

	return v;
}
f0103ef8:	e24bd000 	sub	sp, fp, #0
f0103efc:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103f00:	e12fff1e 	bx	lr

f0103f04 <memmove>:

void *
memmove(void *dst, const void *src, size_t n)
{
f0103f04:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103f08:	e28db000 	add	fp, sp, #0
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103f0c:	e1510000 	cmp	r1, r0
f0103f10:	3a000004 	bcc	f0103f28 <memmove+0x24>
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0103f14:	e3520000 	cmp	r2, #0
f0103f18:	12403001 	subne	r3, r0, #1
f0103f1c:	10812002 	addne	r2, r1, r2
f0103f20:	1a00000c 	bne	f0103f58 <memmove+0x54>
f0103f24:	ea00000f 	b	f0103f68 <memmove+0x64>
	const char *s;
	char *d;

	s = src;
	d = dst;
	if (s < d && s + n > d) {
f0103f28:	e0813002 	add	r3, r1, r2
f0103f2c:	e1500003 	cmp	r0, r3
f0103f30:	2afffff7 	bcs	f0103f14 <memmove+0x10>
		s += n;
		d += n;
f0103f34:	e0801002 	add	r1, r0, r2
		while (n-- > 0)
f0103f38:	e3520000 	cmp	r2, #0
f0103f3c:	0a000009 	beq	f0103f68 <memmove+0x64>
f0103f40:	e0622003 	rsb	r2, r2, r3
			*--d = *--s;
f0103f44:	e573c001 	ldrb	ip, [r3, #-1]!
f0103f48:	e561c001 	strb	ip, [r1, #-1]!
	s = src;
	d = dst;
	if (s < d && s + n > d) {
		s += n;
		d += n;
		while (n-- > 0)
f0103f4c:	e1530002 	cmp	r3, r2
f0103f50:	1afffffb 	bne	f0103f44 <memmove+0x40>
f0103f54:	ea000003 	b	f0103f68 <memmove+0x64>
			*--d = *--s;
	} else
		while (n-- > 0)
			*d++ = *s++;
f0103f58:	e4d1c001 	ldrb	ip, [r1], #1
f0103f5c:	e5e3c001 	strb	ip, [r3, #1]!
		s += n;
		d += n;
		while (n-- > 0)
			*--d = *--s;
	} else
		while (n-- > 0)
f0103f60:	e1510002 	cmp	r1, r2
f0103f64:	1afffffb 	bne	f0103f58 <memmove+0x54>
			*d++ = *s++;

	return dst;
}
f0103f68:	e24bd000 	sub	sp, fp, #0
f0103f6c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0103f70:	e12fff1e 	bx	lr

f0103f74 <memcpy>:

void *
memcpy(void *dst, const void *src, size_t n)
{
f0103f74:	e92d4800 	push	{fp, lr}
f0103f78:	e28db004 	add	fp, sp, #4
	return memmove(dst, src, n);
f0103f7c:	ebffffe0 	bl	f0103f04 <memmove>
}
f0103f80:	e8bd8800 	pop	{fp, pc}

f0103f84 <memcmp>:
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103f84:	e3520000 	cmp	r2, #0
f0103f88:	0a000012 	beq	f0103fd8 <memcmp+0x54>
	return memmove(dst, src, n);
}

int
memcmp(const void *v1, const void *v2, size_t n)
{
f0103f8c:	e92d4800 	push	{fp, lr}
f0103f90:	e28db004 	add	fp, sp, #4
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
		if (*s1 != *s2)
f0103f94:	e5d0c000 	ldrb	ip, [r0]
f0103f98:	e5d1e000 	ldrb	lr, [r1]
f0103f9c:	e15c000e 	cmp	ip, lr
f0103fa0:	02803001 	addeq	r3, r0, #1
f0103fa4:	00800002 	addeq	r0, r0, r2
f0103fa8:	0a000006 	beq	f0103fc8 <memcmp+0x44>
f0103fac:	ea000003 	b	f0103fc0 <memcmp+0x3c>
f0103fb0:	e4d3c001 	ldrb	ip, [r3], #1
f0103fb4:	e5f1e001 	ldrb	lr, [r1, #1]!
f0103fb8:	e15c000e 	cmp	ip, lr
f0103fbc:	0a000001 	beq	f0103fc8 <memcmp+0x44>
			return (int) *s1 - (int) *s2;
f0103fc0:	e06e000c 	rsb	r0, lr, ip
f0103fc4:	e8bd8800 	pop	{fp, pc}
memcmp(const void *v1, const void *v2, size_t n)
{
	const uint8_t *s1 = (const uint8_t *) v1;
	const uint8_t *s2 = (const uint8_t *) v2;

	while (n-- > 0) {
f0103fc8:	e1530000 	cmp	r3, r0
f0103fcc:	1afffff7 	bne	f0103fb0 <memcmp+0x2c>
		if (*s1 != *s2)
			return (int) *s1 - (int) *s2;
		s1++, s2++;
	}

	return 0;
f0103fd0:	e3a00000 	mov	r0, #0
f0103fd4:	e8bd8800 	pop	{fp, pc}
f0103fd8:	e3a00000 	mov	r0, #0
f0103fdc:	e12fff1e 	bx	lr

f0103fe0 <memfind>:
}

void *
memfind(const void *s, int c, size_t n)
{
f0103fe0:	e52db004 	push	{fp}		; (str fp, [sp, #-4]!)
f0103fe4:	e28db000 	add	fp, sp, #0
	const void *ends = (const char *) s + n;
f0103fe8:	e0802002 	add	r2, r0, r2
	for (; s < ends; s++)
f0103fec:	e1500002 	cmp	r0, r2
f0103ff0:	2a00000c 	bcs	f0104028 <memfind+0x48>
		if (*(const unsigned char *) s == (unsigned char) c)
f0103ff4:	e6ef1071 	uxtb	r1, r1
f0103ff8:	e5d03000 	ldrb	r3, [r0]
f0103ffc:	e1530001 	cmp	r3, r1
f0104000:	0a000008 	beq	f0104028 <memfind+0x48>
f0104004:	e2803001 	add	r3, r0, #1
f0104008:	ea000003 	b	f010401c <memfind+0x3c>
f010400c:	e2833001 	add	r3, r3, #1
f0104010:	e5d0c000 	ldrb	ip, [r0]
f0104014:	e15c0001 	cmp	ip, r1
f0104018:	0a000002 	beq	f0104028 <memfind+0x48>

void *
memfind(const void *s, int c, size_t n)
{
	const void *ends = (const char *) s + n;
	for (; s < ends; s++)
f010401c:	e1a00003 	mov	r0, r3
f0104020:	e1530002 	cmp	r3, r2
f0104024:	1afffff8 	bne	f010400c <memfind+0x2c>
		if (*(const unsigned char *) s == (unsigned char) c)
			break;
	return (void *) s;
}
f0104028:	e24bd000 	sub	sp, fp, #0
f010402c:	e49db004 	pop	{fp}		; (ldr fp, [sp], #4)
f0104030:	e12fff1e 	bx	lr

f0104034 <strtol>:

long
strtol(const char *s, char **endptr, int base)
{
f0104034:	e92d4830 	push	{r4, r5, fp, lr}
f0104038:	e28db00c 	add	fp, sp, #12
	int neg = 0;
	long val = 0;

	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
f010403c:	e5d03000 	ldrb	r3, [r0]
f0104040:	e3530020 	cmp	r3, #32
f0104044:	13530009 	cmpne	r3, #9
f0104048:	1a000003 	bne	f010405c <strtol+0x28>
f010404c:	e5f03001 	ldrb	r3, [r0, #1]!
f0104050:	e3530020 	cmp	r3, #32
f0104054:	13530009 	cmpne	r3, #9
f0104058:	0afffffb 	beq	f010404c <strtol+0x18>
		s++;

	// plus/minus sign
	if (*s == '+')
f010405c:	e353002b 	cmp	r3, #43	; 0x2b
		s++;
f0104060:	02800001 	addeq	r0, r0, #1
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104064:	03a05000 	moveq	r5, #0
	// gobble initial whitespace
	while (*s == ' ' || *s == '\t')
		s++;

	// plus/minus sign
	if (*s == '+')
f0104068:	0a000003 	beq	f010407c <strtol+0x48>
		s++;
	else if (*s == '-')
f010406c:	e353002d 	cmp	r3, #45	; 0x2d
		s++, neg = 1;
f0104070:	02800001 	addeq	r0, r0, #1
f0104074:	03a05001 	moveq	r5, #1
}

long
strtol(const char *s, char **endptr, int base)
{
	int neg = 0;
f0104078:	13a05000 	movne	r5, #0
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f010407c:	e16f3f12 	clz	r3, r2
f0104080:	e1a032a3 	lsr	r3, r3, #5
f0104084:	e3d2c010 	bics	ip, r2, #16
f0104088:	1a000008 	bne	f01040b0 <strtol+0x7c>
f010408c:	e5d0c000 	ldrb	ip, [r0]
f0104090:	e35c0030 	cmp	ip, #48	; 0x30
f0104094:	1a000005 	bne	f01040b0 <strtol+0x7c>
f0104098:	e5d0c001 	ldrb	ip, [r0, #1]
f010409c:	e35c0078 	cmp	ip, #120	; 0x78
		s += 2, base = 16;
f01040a0:	02800002 	addeq	r0, r0, #2
f01040a4:	03a02010 	moveq	r2, #16
		s++;
	else if (*s == '-')
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
f01040a8:	0a000009 	beq	f01040d4 <strtol+0xa0>
f01040ac:	ea000027 	b	f0104150 <strtol+0x11c>
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01040b0:	e3530000 	cmp	r3, #0
f01040b4:	0a000006 	beq	f01040d4 <strtol+0xa0>
f01040b8:	e5d03000 	ldrb	r3, [r0]
f01040bc:	e3530030 	cmp	r3, #48	; 0x30
		s++, base = 8;
	else if (base == 0)
		base = 10;
f01040c0:	13a0200a 	movne	r2, #10
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f01040c4:	1a000002 	bne	f01040d4 <strtol+0xa0>
		s++, base = 8;
f01040c8:	e2800001 	add	r0, r0, #1
f01040cc:	e3a02008 	mov	r2, #8
f01040d0:	eaffffff 	b	f01040d4 <strtol+0xa0>
f01040d4:	e1a0c000 	mov	ip, r0
	else if (base == 0)
		base = 10;
f01040d8:	e3a00000 	mov	r0, #0
f01040dc:	e1a0400c 	mov	r4, ip

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01040e0:	e4dc3001 	ldrb	r3, [ip], #1
f01040e4:	e243e030 	sub	lr, r3, #48	; 0x30
f01040e8:	e6efe07e 	uxtb	lr, lr
f01040ec:	e35e0009 	cmp	lr, #9
			dig = *s - '0';
f01040f0:	92433030 	subls	r3, r3, #48	; 0x30

	// digits
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
f01040f4:	9a000009 	bls	f0104120 <strtol+0xec>
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f01040f8:	e243e061 	sub	lr, r3, #97	; 0x61
f01040fc:	e6efe07e 	uxtb	lr, lr
f0104100:	e35e0019 	cmp	lr, #25
			dig = *s - 'a' + 10;
f0104104:	92433057 	subls	r3, r3, #87	; 0x57
	while (1) {
		int dig;

		if (*s >= '0' && *s <= '9')
			dig = *s - '0';
		else if (*s >= 'a' && *s <= 'z')
f0104108:	9a000004 	bls	f0104120 <strtol+0xec>
			dig = *s - 'a' + 10;
		else if (*s >= 'A' && *s <= 'Z')
f010410c:	e243e041 	sub	lr, r3, #65	; 0x41
f0104110:	e6efe07e 	uxtb	lr, lr
f0104114:	e35e0019 	cmp	lr, #25
f0104118:	8a000004 	bhi	f0104130 <strtol+0xfc>
			dig = *s - 'A' + 10;
f010411c:	e2433037 	sub	r3, r3, #55	; 0x37
		else
			break;
		if (dig >= base)
f0104120:	e1530002 	cmp	r3, r2
f0104124:	aa000003 	bge	f0104138 <strtol+0x104>
			break;
		s++, val = (val * base) + dig;
f0104128:	e0203092 	mla	r0, r2, r0, r3
		// we don't properly detect overflow!
	}
f010412c:	eaffffea 	b	f01040dc <strtol+0xa8>
f0104130:	e1a03000 	mov	r3, r0
f0104134:	ea000000 	b	f010413c <strtol+0x108>
f0104138:	e1a03000 	mov	r3, r0

	if (endptr)
f010413c:	e3510000 	cmp	r1, #0
		*endptr = (char *) s;
f0104140:	15814000 	strne	r4, [r1]
	return (neg ? -val : val);
f0104144:	e3550000 	cmp	r5, #0
f0104148:	12630000 	rsbne	r0, r3, #0
f010414c:	e8bd8830 	pop	{r4, r5, fp, pc}
		s++, neg = 1;

	// hex or octal base prefix
	if ((base == 0 || base == 16) && (s[0] == '0' && s[1] == 'x'))
		s += 2, base = 16;
	else if (base == 0 && s[0] == '0')
f0104150:	e3530000 	cmp	r3, #0
f0104154:	1affffdb 	bne	f01040c8 <strtol+0x94>
f0104158:	eaffffdd 	b	f01040d4 <strtol+0xa0>

f010415c <__aeabi_uldivmod>:
f010415c:	e3530000 	cmp	r3, #0
f0104160:	03520000 	cmpeq	r2, #0
f0104164:	1a000004 	bne	f010417c <__aeabi_uldivmod+0x20>
f0104168:	e3510000 	cmp	r1, #0
f010416c:	03500000 	cmpeq	r0, #0
f0104170:	13e01000 	mvnne	r1, #0
f0104174:	13e00000 	mvnne	r0, #0
f0104178:	ea000027 	b	f010421c <__aeabi_idiv0>
f010417c:	e24dd008 	sub	sp, sp, #8
f0104180:	e92d6000 	push	{sp, lr}
f0104184:	eb000014 	bl	f01041dc <__gnu_uldivmod_helper>
f0104188:	e59de004 	ldr	lr, [sp, #4]
f010418c:	e28dd008 	add	sp, sp, #8
f0104190:	e8bd000c 	pop	{r2, r3}
f0104194:	e12fff1e 	bx	lr

f0104198 <__gnu_ldivmod_helper>:
f0104198:	e92d47f0 	push	{r4, r5, r6, r7, r8, r9, sl, lr}
f010419c:	e59d6020 	ldr	r6, [sp, #32]
f01041a0:	e1a07002 	mov	r7, r2
f01041a4:	e1a0a003 	mov	sl, r3
f01041a8:	e1a04000 	mov	r4, r0
f01041ac:	e1a05001 	mov	r5, r1
f01041b0:	eb00001a 	bl	f0104220 <__divdi3>
f01041b4:	e1a03000 	mov	r3, r0
f01041b8:	e0020197 	mul	r2, r7, r1
f01041bc:	e0898097 	umull	r8, r9, r7, r0
f01041c0:	e023239a 	mla	r3, sl, r3, r2
f01041c4:	e0544008 	subs	r4, r4, r8
f01041c8:	e0839009 	add	r9, r3, r9
f01041cc:	e0c55009 	sbc	r5, r5, r9
f01041d0:	e8860030 	stm	r6, {r4, r5}
f01041d4:	e8bd47f0 	pop	{r4, r5, r6, r7, r8, r9, sl, lr}
f01041d8:	e12fff1e 	bx	lr

f01041dc <__gnu_uldivmod_helper>:
f01041dc:	e92d41f0 	push	{r4, r5, r6, r7, r8, lr}
f01041e0:	e59d5018 	ldr	r5, [sp, #24]
f01041e4:	e1a04002 	mov	r4, r2
f01041e8:	e1a08003 	mov	r8, r3
f01041ec:	e1a06000 	mov	r6, r0
f01041f0:	e1a07001 	mov	r7, r1
f01041f4:	eb000067 	bl	f0104398 <__udivdi3>
f01041f8:	e0080890 	mul	r8, r0, r8
f01041fc:	e0832490 	umull	r2, r3, r0, r4
f0104200:	e0248491 	mla	r4, r1, r4, r8
f0104204:	e0566002 	subs	r6, r6, r2
f0104208:	e0843003 	add	r3, r4, r3
f010420c:	e0c77003 	sbc	r7, r7, r3
f0104210:	e88500c0 	stm	r5, {r6, r7}
f0104214:	e8bd41f0 	pop	{r4, r5, r6, r7, r8, lr}
f0104218:	e12fff1e 	bx	lr

f010421c <__aeabi_idiv0>:
f010421c:	e12fff1e 	bx	lr

f0104220 <__divdi3>:
f0104220:	e3510000 	cmp	r1, #0
f0104224:	e92d4ff8 	push	{r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
f0104228:	a1a04000 	movge	r4, r0
f010422c:	a1a05001 	movge	r5, r1
f0104230:	a3a0a000 	movge	sl, #0
f0104234:	ba000053 	blt	f0104388 <__divdi3+0x168>
f0104238:	e3530000 	cmp	r3, #0
f010423c:	a1a08002 	movge	r8, r2
f0104240:	a1a09003 	movge	r9, r3
f0104244:	ba00004b 	blt	f0104378 <__divdi3+0x158>
f0104248:	e1550009 	cmp	r5, r9
f010424c:	01540008 	cmpeq	r4, r8
f0104250:	33a02000 	movcc	r2, #0
f0104254:	33a03000 	movcc	r3, #0
f0104258:	3a00003b 	bcc	f010434c <__divdi3+0x12c>
f010425c:	e1a01009 	mov	r1, r9
f0104260:	e1a00008 	mov	r0, r8
f0104264:	eb000093 	bl	f01044b8 <__clzdi2>
f0104268:	e1a01005 	mov	r1, r5
f010426c:	e1a0b000 	mov	fp, r0
f0104270:	e1a00004 	mov	r0, r4
f0104274:	eb00008f 	bl	f01044b8 <__clzdi2>
f0104278:	e060000b 	rsb	r0, r0, fp
f010427c:	e240e020 	sub	lr, r0, #32
f0104280:	e1a07019 	lsl	r7, r9, r0
f0104284:	e1877e18 	orr	r7, r7, r8, lsl lr
f0104288:	e260c020 	rsb	ip, r0, #32
f010428c:	e1877c38 	orr	r7, r7, r8, lsr ip
f0104290:	e1550007 	cmp	r5, r7
f0104294:	e1a06018 	lsl	r6, r8, r0
f0104298:	01540006 	cmpeq	r4, r6
f010429c:	e1a01000 	mov	r1, r0
f01042a0:	33a02000 	movcc	r2, #0
f01042a4:	33a03000 	movcc	r3, #0
f01042a8:	3a000005 	bcc	f01042c4 <__divdi3+0xa4>
f01042ac:	e3a08001 	mov	r8, #1
f01042b0:	e0544006 	subs	r4, r4, r6
f01042b4:	e1a03e18 	lsl	r3, r8, lr
f01042b8:	e1833c38 	orr	r3, r3, r8, lsr ip
f01042bc:	e0c55007 	sbc	r5, r5, r7
f01042c0:	e1a02018 	lsl	r2, r8, r0
f01042c4:	e3500000 	cmp	r0, #0
f01042c8:	0a00001f 	beq	f010434c <__divdi3+0x12c>
f01042cc:	e1b070a7 	lsrs	r7, r7, #1
f01042d0:	e1a06066 	rrx	r6, r6
f01042d4:	ea000007 	b	f01042f8 <__divdi3+0xd8>
f01042d8:	e0544006 	subs	r4, r4, r6
f01042dc:	e0c55007 	sbc	r5, r5, r7
f01042e0:	e0944004 	adds	r4, r4, r4
f01042e4:	e0a55005 	adc	r5, r5, r5
f01042e8:	e2944001 	adds	r4, r4, #1
f01042ec:	e2a55000 	adc	r5, r5, #0
f01042f0:	e2500001 	subs	r0, r0, #1
f01042f4:	0a000006 	beq	f0104314 <__divdi3+0xf4>
f01042f8:	e1570005 	cmp	r7, r5
f01042fc:	01560004 	cmpeq	r6, r4
f0104300:	9afffff4 	bls	f01042d8 <__divdi3+0xb8>
f0104304:	e0944004 	adds	r4, r4, r4
f0104308:	e0a55005 	adc	r5, r5, r5
f010430c:	e2500001 	subs	r0, r0, #1
f0104310:	1afffff8 	bne	f01042f8 <__divdi3+0xd8>
f0104314:	e261c020 	rsb	ip, r1, #32
f0104318:	e1a00134 	lsr	r0, r4, r1
f010431c:	e0922004 	adds	r2, r2, r4
f0104320:	e241e020 	sub	lr, r1, #32
f0104324:	e1800c15 	orr	r0, r0, r5, lsl ip
f0104328:	e1a04135 	lsr	r4, r5, r1
f010432c:	e1800e35 	orr	r0, r0, r5, lsr lr
f0104330:	e1a07114 	lsl	r7, r4, r1
f0104334:	e1877e10 	orr	r7, r7, r0, lsl lr
f0104338:	e1a06110 	lsl	r6, r0, r1
f010433c:	e0a33005 	adc	r3, r3, r5
f0104340:	e1877c30 	orr	r7, r7, r0, lsr ip
f0104344:	e0522006 	subs	r2, r2, r6
f0104348:	e0c33007 	sbc	r3, r3, r7
f010434c:	e29a0000 	adds	r0, sl, #0
f0104350:	13a00001 	movne	r0, #1
f0104354:	e3a01000 	mov	r1, #0
f0104358:	e2704000 	rsbs	r4, r0, #0
f010435c:	e2e15000 	rsc	r5, r1, #0
f0104360:	e0222004 	eor	r2, r2, r4
f0104364:	e0233005 	eor	r3, r3, r5
f0104368:	e0900002 	adds	r0, r0, r2
f010436c:	e0a11003 	adc	r1, r1, r3
f0104370:	e8bd4ff8 	pop	{r3, r4, r5, r6, r7, r8, r9, sl, fp, lr}
f0104374:	e12fff1e 	bx	lr
f0104378:	e2728000 	rsbs	r8, r2, #0
f010437c:	e1e0a00a 	mvn	sl, sl
f0104380:	e2e39000 	rsc	r9, r3, #0
f0104384:	eaffffaf 	b	f0104248 <__divdi3+0x28>
f0104388:	e2704000 	rsbs	r4, r0, #0
f010438c:	e2e15000 	rsc	r5, r1, #0
f0104390:	e3e0a000 	mvn	sl, #0
f0104394:	eaffffa7 	b	f0104238 <__divdi3+0x18>

f0104398 <__udivdi3>:
f0104398:	e1510003 	cmp	r1, r3
f010439c:	01500002 	cmpeq	r0, r2
f01043a0:	e92d47f0 	push	{r4, r5, r6, r7, r8, r9, sl, lr}
f01043a4:	e1a04000 	mov	r4, r0
f01043a8:	e1a05001 	mov	r5, r1
f01043ac:	e1a08002 	mov	r8, r2
f01043b0:	e1a09003 	mov	r9, r3
f01043b4:	33a00000 	movcc	r0, #0
f01043b8:	33a01000 	movcc	r1, #0
f01043bc:	3a00003b 	bcc	f01044b0 <__udivdi3+0x118>
f01043c0:	e1a01003 	mov	r1, r3
f01043c4:	e1a00002 	mov	r0, r2
f01043c8:	eb00003a 	bl	f01044b8 <__clzdi2>
f01043cc:	e1a01005 	mov	r1, r5
f01043d0:	e1a0a000 	mov	sl, r0
f01043d4:	e1a00004 	mov	r0, r4
f01043d8:	eb000036 	bl	f01044b8 <__clzdi2>
f01043dc:	e060300a 	rsb	r3, r0, sl
f01043e0:	e243e020 	sub	lr, r3, #32
f01043e4:	e1a07319 	lsl	r7, r9, r3
f01043e8:	e1877e18 	orr	r7, r7, r8, lsl lr
f01043ec:	e263c020 	rsb	ip, r3, #32
f01043f0:	e1877c38 	orr	r7, r7, r8, lsr ip
f01043f4:	e1550007 	cmp	r5, r7
f01043f8:	e1a06318 	lsl	r6, r8, r3
f01043fc:	01540006 	cmpeq	r4, r6
f0104400:	e1a02003 	mov	r2, r3
f0104404:	33a00000 	movcc	r0, #0
f0104408:	33a01000 	movcc	r1, #0
f010440c:	3a000005 	bcc	f0104428 <__udivdi3+0x90>
f0104410:	e3a08001 	mov	r8, #1
f0104414:	e0544006 	subs	r4, r4, r6
f0104418:	e1a01e18 	lsl	r1, r8, lr
f010441c:	e1811c38 	orr	r1, r1, r8, lsr ip
f0104420:	e0c55007 	sbc	r5, r5, r7
f0104424:	e1a00318 	lsl	r0, r8, r3
f0104428:	e3530000 	cmp	r3, #0
f010442c:	0a00001f 	beq	f01044b0 <__udivdi3+0x118>
f0104430:	e1b070a7 	lsrs	r7, r7, #1
f0104434:	e1a06066 	rrx	r6, r6
f0104438:	ea000007 	b	f010445c <__udivdi3+0xc4>
f010443c:	e0544006 	subs	r4, r4, r6
f0104440:	e0c55007 	sbc	r5, r5, r7
f0104444:	e0944004 	adds	r4, r4, r4
f0104448:	e0a55005 	adc	r5, r5, r5
f010444c:	e2944001 	adds	r4, r4, #1
f0104450:	e2a55000 	adc	r5, r5, #0
f0104454:	e2533001 	subs	r3, r3, #1
f0104458:	0a000006 	beq	f0104478 <__udivdi3+0xe0>
f010445c:	e1570005 	cmp	r7, r5
f0104460:	01560004 	cmpeq	r6, r4
f0104464:	9afffff4 	bls	f010443c <__udivdi3+0xa4>
f0104468:	e0944004 	adds	r4, r4, r4
f010446c:	e0a55005 	adc	r5, r5, r5
f0104470:	e2533001 	subs	r3, r3, #1
f0104474:	1afffff8 	bne	f010445c <__udivdi3+0xc4>
f0104478:	e0948000 	adds	r8, r4, r0
f010447c:	e0a59001 	adc	r9, r5, r1
f0104480:	e1a03234 	lsr	r3, r4, r2
f0104484:	e2621020 	rsb	r1, r2, #32
f0104488:	e2420020 	sub	r0, r2, #32
f010448c:	e1833115 	orr	r3, r3, r5, lsl r1
f0104490:	e1a0c235 	lsr	ip, r5, r2
f0104494:	e1833035 	orr	r3, r3, r5, lsr r0
f0104498:	e1a0721c 	lsl	r7, ip, r2
f010449c:	e1877013 	orr	r7, r7, r3, lsl r0
f01044a0:	e1a06213 	lsl	r6, r3, r2
f01044a4:	e1877133 	orr	r7, r7, r3, lsr r1
f01044a8:	e0580006 	subs	r0, r8, r6
f01044ac:	e0c91007 	sbc	r1, r9, r7
f01044b0:	e8bd47f0 	pop	{r4, r5, r6, r7, r8, r9, sl, lr}
f01044b4:	e12fff1e 	bx	lr

f01044b8 <__clzdi2>:
f01044b8:	e92d4010 	push	{r4, lr}
f01044bc:	e3510000 	cmp	r1, #0
f01044c0:	1a000002 	bne	f01044d0 <__clzdi2+0x18>
f01044c4:	eb000005 	bl	f01044e0 <__clzsi2>
f01044c8:	e2800020 	add	r0, r0, #32
f01044cc:	ea000001 	b	f01044d8 <__clzdi2+0x20>
f01044d0:	e1a00001 	mov	r0, r1
f01044d4:	eb000001 	bl	f01044e0 <__clzsi2>
f01044d8:	e8bd4010 	pop	{r4, lr}
f01044dc:	e12fff1e 	bx	lr

f01044e0 <__clzsi2>:
f01044e0:	e3a0101c 	mov	r1, #28
f01044e4:	e3500801 	cmp	r0, #65536	; 0x10000
f01044e8:	21a00820 	lsrcs	r0, r0, #16
f01044ec:	22411010 	subcs	r1, r1, #16
f01044f0:	e3500c01 	cmp	r0, #256	; 0x100
f01044f4:	21a00420 	lsrcs	r0, r0, #8
f01044f8:	22411008 	subcs	r1, r1, #8
f01044fc:	e3500010 	cmp	r0, #16
f0104500:	21a00220 	lsrcs	r0, r0, #4
f0104504:	22411004 	subcs	r1, r1, #4
f0104508:	e28f2008 	add	r2, pc, #8
f010450c:	e7d20000 	ldrb	r0, [r2, r0]
f0104510:	e0800001 	add	r0, r0, r1
f0104514:	e12fff1e 	bx	lr
f0104518:	02020304 	.word	0x02020304
f010451c:	01010101 	.word	0x01010101
	...
