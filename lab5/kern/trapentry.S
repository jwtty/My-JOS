/* See COPYRIGHT for copyright information. */

#include <inc/mmu.h>
#include <inc/memlayout.h>
#include <inc/trap.h>


#define IDTENTRY(name,num,dpl,istrap)           \
    .data;                      \
    .align 2;                   \
    .long name;                 \
    .long num;                  \
    .long dpl;                  \
    .long istrap;                   
    
###################################################################
# exceptions/interrupts
###################################################################

/* TRAPHANDLER defines a globally-visible function for handling a trap.
 * It pushes a trap number onto the stack, then jumps to _alltraps.
 * Use TRAPHANDLER for traps where the CPU automatically pushes an error code.
 *
 * You shouldn't call a TRAPHANDLER function from C, but you may
 * need to _declare_ one in C (for instance, to get a function pointer
 * during IDT setup).  You can declare the function with
 *   void NAME();
 * where NAME is the argument passed to TRAPHANDLER.
 */
#define TRAPHANDLER(name, num, dpl, istrap)                     \
    .text;                              \
    .globl name;        /* define global symbol for 'name' */   \
    .type name, @function;  /* symbol type is function */       \
    .align 2;       /* align function definition */     \
    name:           /* function starts here */      \
    pushl $(num);                           \
    jmp _alltraps;                          \
    IDTENTRY(name,num,dpl,istrap)

/* Use TRAPHANDLER_NOEC for traps where the CPU doesn't push an error code.
 * It pushes a 0 in place of the error code, so the trap frame has the same
 * format in either case.
 */
#define TRAPHANDLER_NOEC(name, num, dpl, istrap)                \
    .text;                              \
    .globl name;                            \
    .type name, @function;                      \
    .align 2;                           \
    name:                               \
    pushl $0;                           \
    pushl $(num);                           \
    jmp _alltraps;                          \
    IDTENTRY(name,num,dpl,istrap)
.text

/*
 * Lab 3: Your code here for generating entry points for the different traps.
 */
.data
.align 2
.globl idt_entry
idt_entry:
    TRAPHANDLER_NOEC(r_divide, T_DIVIDE, 0, 0 )
    TRAPHANDLER_NOEC(r_debug, T_DEBUG, 0, 0 ) 
    TRAPHANDLER_NOEC(r_nmi, T_NMI, 0, 0 )
    TRAPHANDLER_NOEC(r_brkpt, T_BRKPT, 3, 0 )
    TRAPHANDLER_NOEC(r_oflow, T_OFLOW, 0, 0 )
    TRAPHANDLER_NOEC(r_bound, T_BOUND, 0, 0 )
    TRAPHANDLER_NOEC(r_illop, T_ILLOP, 0, 0 )
    TRAPHANDLER_NOEC(r_device, T_DEVICE, 0, 0 )
    TRAPHANDLER(r_dblflt, T_DBLFLT, 0, 0 )
.fill 2,8,0
    TRAPHANDLER(r_tss, T_TSS, 0, 0 )
    TRAPHANDLER(r_segnp, T_SEGNP, 0, 0 )
    TRAPHANDLER(r_stack, T_STACK, 0, 0 )
    TRAPHANDLER(r_gpflt, T_GPFLT, 0, 0 )
    TRAPHANDLER(r_pgflt, T_PGFLT, 0, 0 )
.fill 2,8,0
    TRAPHANDLER_NOEC(r_fperr, T_FPERR, 0, 0 )
    TRAPHANDLER(r_align, T_ALIGN, 0, 0 )
    TRAPHANDLER_NOEC(r_mchk, T_MCHK, 0, 0 )
    TRAPHANDLER_NOEC(r_simderr, T_SIMDERR, 0, 0 )
.fill 24,8,0
    TRAPHANDLER_NOEC(r_irq0, IRQ_OFFSET + 0, 0, 0 )
    TRAPHANDLER_NOEC(r_irq1, IRQ_OFFSET + 1, 0, 0 )
    TRAPHANDLER_NOEC(r_irq2, IRQ_OFFSET + 2, 0, 0 )
    TRAPHANDLER_NOEC(r_irq3, IRQ_OFFSET + 3, 0, 0 )
    TRAPHANDLER_NOEC(r_irq4, IRQ_OFFSET + 4, 0, 0 )
    TRAPHANDLER_NOEC(r_irq5, IRQ_OFFSET + 5, 0, 0 )
    TRAPHANDLER_NOEC(r_irq6, IRQ_OFFSET + 6, 0, 0 )
    TRAPHANDLER_NOEC(r_irq7, IRQ_OFFSET + 7, 0, 0 )
    TRAPHANDLER_NOEC(r_irq8, IRQ_OFFSET + 8, 0, 0 )
    TRAPHANDLER_NOEC(r_irq9, IRQ_OFFSET + 9, 0, 0 )
    TRAPHANDLER_NOEC(r_irq10, IRQ_OFFSET + 10, 0, 0 )
    TRAPHANDLER_NOEC(r_irq11, IRQ_OFFSET + 11, 0, 0 )
    TRAPHANDLER_NOEC(r_irq12, IRQ_OFFSET + 12, 0, 0 )
    TRAPHANDLER_NOEC(r_irq13, IRQ_OFFSET + 13, 0, 0 )
    TRAPHANDLER_NOEC(r_irq14, IRQ_OFFSET + 14, 0, 0 )
    TRAPHANDLER_NOEC(r_irq15, IRQ_OFFSET + 15, 0, 0 )
    TRAPHANDLER_NOEC(r_syscall, T_SYSCALL, 3, 0 )


/*
 * Lab 3: Your code here for _alltraps
 */
_alltraps:
    pushw $0x0
    pushw %ds
    pushw $0x0
    pushw %es
    pushal
    
    movw $GD_KD, %ax
    movw %ax, %ds
    movw %ax, %es
    pushl %esp  
    call trap

