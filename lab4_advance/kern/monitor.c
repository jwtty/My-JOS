// Simple command-line kernel monitor useful for
// controlling the kernel and exploring the system interactively.

#include <inc/stdio.h>
#include <inc/string.h>
#include <inc/memlayout.h>
#include <inc/assert.h>
#include <inc/x86.h>

#include <kern/console.h>
#include <kern/monitor.h>
#include <kern/kdebug.h>
#include <kern/kclock.h>
#include <kern/trap.h>
#include <kern/pmap.h>
#include <kern/spinlock.h>


#define CMDBUF_SIZE	80	// enough for one VGA text line

int
mon_pgmap(int argc, char **argv, struct Trapframe *tf);
int
mon_memdump(int argc, char **argv, struct Trapframe *tf);
int
mon_pgperm(int argc, char **argv, struct Trapframe *tf);
int
mon_continue(int argc, char **argv, struct Trapframe *tf);
int
mon_stepins(int argc, char **argv, struct Trapframe *tf);
int 
mon_showtime(int argc, char **argv, struct Trapframe *tf);



struct Command {
    const char *name;
    const char *desc;
    // return -1 to force monitor to exit
    int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
    { "help", "Display this list of commands", mon_help },
    { "kerninfo", "Display information about the kernel", mon_kerninfo },
    { "pgmap", "Display the physical page mappings", mon_pgmap },
    { "pgperm", "set, clear, or change the permissions", mon_pgperm },
    { "memdump", "Dump the contents of a range of memory", mon_memdump },
    { "backtrace", "Backtrace", mon_backtrace },
    { "si", "single-step one instruction at a time", mon_stepins },
    { "c", "continue", mon_continue },
    { "showtime", "Show the system time", mon_showtime },
};


/***** Implementations of basic kernel monitor commands *****/

    int
mon_help(int argc, char **argv, struct Trapframe *tf)
{
    int i;

    for (i = 0; i < ARRAY_SIZE(commands); i++)
	cprintf("%s - %s\n", commands[i].name, commands[i].desc);
    return 0;
}

    int
mon_kerninfo(int argc, char **argv, struct Trapframe *tf)
{
    extern char _start[], entry[], etext[], edata[], end[];

    cprintf("Special kernel symbols:\n");
    cprintf("  _start                  %08x (phys)\n", _start);
    cprintf("  entry  %08x (virt)  %08x (phys)\n", entry, entry - KERNBASE);
    cprintf("  etext  %08x (virt)  %08x (phys)\n", etext, etext - KERNBASE);
    cprintf("  edata  %08x (virt)  %08x (phys)\n", edata, edata - KERNBASE);
    cprintf("  end    %08x (virt)  %08x (phys)\n", end, end - KERNBASE);
    cprintf("Kernel executable memory footprint: %dKB\n",
	    ROUNDUP(end - entry, 1024) / 1024);
    return 0;
}

    int
mon_backtrace(int argc, char **argv, struct Trapframe *tf)
{
    int *ebp, eip, *old_ebp;
    int ary[5]={};

    cprintf("Stack backtrace:\n");

    ebp=(int *)read_ebp();
    while((int)ebp!=0)
    {
	old_ebp=(int *)*(ebp);
	eip=*(ebp+1);
	for(int i=0;i<5;++i)
	{
	    int j=i+2;
	    ary[i]=*(ebp+j);
	}
	struct Eipdebuginfo eip_info;
	debuginfo_eip((uintptr_t)eip, &eip_info);
	cprintf("\033[16ebp %08x eip %08x args %08x %08x %08x %08x %08x\n",ebp,eip,ary[0],ary[1],ary[2],ary[3],ary[4]);
	cprintf("\033[28	%s:%d:", eip_info.eip_file, eip_info.eip_line);
	cprintf("\033[3a %.*s+%d\n", eip_info.eip_fn_namelen, eip_info.eip_fn_name, eip - eip_info.eip_fn_addr);
	ebp=old_ebp;
    }

    return 0;
}




    int
mon_pgmap(int argc, char **argv, struct Trapframe *tf)
{
    uintptr_t va1, va2, va;
    struct PageInfo *pg;
    pte_t *pte;
    if (argc != 3) {
	cprintf("Usage: pgmap va1 va2\n Display physical memory mapping from virtual memory va1 to va2\nva1 and va2 are hex\n");
	return 0;
    }
    else {
	for (va1 = strtol(argv[1], 0, 16), va2 = strtol(argv[2], 0, 16); va1 < va2; va1 += PGSIZE) {
	    va = va1 & ~0xfff;
	    pg = page_lookup(kern_pgdir, (void*)va, 0);
	    pte = pgdir_walk(kern_pgdir, (void* )va,0);
	    if (pg){
		cprintf("[%x, %x) ---> [%x, %x)    ", va, va + PGSIZE, page2pa(pg), page2pa(pg) + PGSIZE);
		if(*pte & PTE_U)
		    cprintf("user: ");
		else 
		    cprintf("kernel: ");

		if(*pte &PTE_W)
		    cprintf("read/write ");
		else 
		    cprintf("read only ");
	    }else
		cprintf("[%x, %x) ---> NULL    ", va, va + PGSIZE);

	    cprintf("\n");                                                                                       
	}
    }
    return 0;
}


    int
mon_pgperm(int argc, char **argv, struct Trapframe *tf)
{
    uintptr_t va, perm;
    if (argc != 4) {
	cprintf("Usage: pgperm +/-/= perm va\nset perm of page which contains va, va is hex\n");
	return 0;
    }
    else {
	va = strtol(argv[3], 0, 16);
	perm = strtol(argv[2], 0, 16);
	pte_t *pte = pgdir_walk(kern_pgdir, (void*)va, 0);
	if (!pte) {
	    cprintf("0x%x is not mapped\n", va);
	}
	else {
	    if (argv[1][0] == '+') *pte |= perm;
	    if (argv[1][0] == '0') *pte &= ~perm;
	    if (argv[1][0] == '=') *pte = PTE_ADDR(*pte) | perm;
	}
    }
    return 0;
}

    int
mon_memdump(int argc, char **argv, struct Trapframe *tf)
{
    uintptr_t a1, a2, a;
    struct PageInfo *pg;
    if (argc != 4) {
	cprintf("Usage: memdump p/v a1 a2\n Dump memory content via virtual or physical address\na1 and a2 are hex\n");
	return 0;
    }
    else {
	a1 = strtol(argv[2], 0, 16), a2 = strtol(argv[3], 0, 16);
	if (argv[1][0] == 'p') a1 = (int)KADDR(a1), a2 = (int)KADDR(a2);
	for (a = a1; a < a2 && a >= KERNBASE; a += 4) {
	    if (!((a - a1) & 0xf)) cprintf("\n%x:\t", a);
	    cprintf(" %x", *(int*)(a));
	}
	cprintf("\n");
    }
    return 0;
}


/***** Kernel monitor command interpreter *****/

#define WHITESPACE "\t\r\n "
#define MAXARGS 16

    static int
runcmd(char *buf, struct Trapframe *tf)
{
    int argc;
    char *argv[MAXARGS];
    int i;

    // Parse the command buffer into whitespace-separated arguments
    argc = 0;
    argv[argc] = 0;
    while (1) {
	// gobble whitespace
	while (*buf && strchr(WHITESPACE, *buf))
	    *buf++ = 0;
	if (*buf == 0)
	    break;

	// save and scan past next arg
	if (argc == MAXARGS-1) {
	    cprintf("Too many arguments (max %d)\n", MAXARGS);
	    return 0;
	}
	argv[argc++] = buf;
	while (*buf && !strchr(WHITESPACE, *buf))
	    buf++;
    }
    argv[argc] = 0;

    // Lookup and invoke the command
    if (argc == 0)
	return 0;
    for (i = 0; i < ARRAY_SIZE(commands); i++) {
	if (strcmp(argv[0], commands[i].name) == 0)
	    return commands[i].func(argc, argv, tf);
    }
    cprintf("Unknown command '%s'\n", argv[0]);
    return 0;
}

    void
monitor(struct Trapframe *tf)
{
    char *buf;

    lock(&monitor_lock);

    cprintf("Welcome to the JOS kernel monitor!\n");
    cprintf("Type 'help' for a list of commands.\n");

    if (tf != NULL)
	print_trapframe(tf);

    while (1) {
	buf = readline("K> ");
	if (buf != NULL)
	    if (runcmd(buf, tf) < 0)
		break;
    }
    unlock(&monitor_lock);
}

extern void env_pop_tf(struct Trapframe *tf);
    int
mon_continue(int argc, char **argv, struct Trapframe *tf)
{
    if (tf->tf_trapno == T_BRKPT || tf->tf_trapno == T_DEBUG) {
	tf->tf_eflags &= ~FL_TF;
	env_pop_tf(tf);
    }
    return 0;
}

    int
mon_stepins(int argc, char **argv, struct Trapframe *tf)
{
    if (tf->tf_trapno == T_BRKPT || tf->tf_trapno == T_DEBUG) {
	tf->tf_eflags |= FL_TF;
	env_pop_tf(tf);
    }
    return 0;
}

int
mon_showtime(int argc, char **argv, struct Trapframe *tf)
{
    int i;
    uint32_t sec, min, hour, day, mon, year;
    for (i = 0; i < 1000000; ++i)
    {
        if(mc146818_read(RTC_FREQ_SELECT) & RTC_UIP)
            break;
    }
    for (i = 0; i < 1000000; ++i)
    {
        if(!(mc146818_read(RTC_FREQ_SELECT) & RTC_UIP))
            break;
    }
    do
    {
        sec = mc146818_read(RTC_SECONDS);
        min = mc146818_read(RTC_MINUTES);
        hour = mc146818_read(RTC_HOURS);
        day = mc146818_read(RTC_DAY_OF_MONTH);
        mon = mc146818_read(RTC_MONTH);
        year = mc146818_read(RTC_YEAR);
    }
    while(sec != mc146818_read(0));
    if(!(mc146818_read(RTC_CONTROL) & RTC_DM_BINARY))
    {
        BCD_TO_BIN(sec);
        BCD_TO_BIN(min);
        BCD_TO_BIN(hour);
        BCD_TO_BIN(day);
        BCD_TO_BIN(mon);
        BCD_TO_BIN(year);
    }
    if((year += 1900) < 1970)
        year += 100;
    cprintf("System Time: %d-%d-%d %d:%d:%d\n", year, mon, day, hour, min, sec);
    //cprintf("year: %d\n", year);
    return 0;
}
