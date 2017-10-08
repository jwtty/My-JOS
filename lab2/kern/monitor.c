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
#include <kern/pmap.h>

#define CMDBUF_SIZE	80	// enough for one VGA text line


struct Command {
	const char *name;
	const char *desc;
	// return -1 to force monitor to exit
	int (*func)(int argc, char** argv, struct Trapframe* tf);
};

static struct Command commands[] = {
	{ "help", "Display this list of commands", mon_help },
	{ "kerninfo", "Display information about the kernel", mon_kerninfo },
	{ "backtrace", "Display stack backtrace for call", mon_backtrace },
	{ "showmappings", "Display physical memory mappings", mon_showmappings },
	{ "setperm", "Set permission bits of any mapping", mon_setperm },
	{ "dumpmem", "Dump physical or virtual memory", mon_dumpmem },
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
	uint32_t *ebp, *eip;
	uint32_t arg[5];
	ebp = (uint32_t*)read_ebp();
	eip = (uint32_t*)*(ebp + 1);
	for (int i = 0; i < 5; ++i)
	{
		arg[i] = *(ebp + i + 2);
	}
	cprintf("Stack backtrace:\n");
	while(ebp != 0)
	{
		cprintf("  ebp %08x  eip %08x  args %08x %08x %08x %08x %08x\n", ebp, eip, arg[0], arg[1], arg[2], arg[3], arg[4]);
		struct Eipdebuginfo info;
		debuginfo_eip((uintptr_t)eip, &info);
		cprintf("         %s:%d: ", info.eip_file, info.eip_line);
		cprintf("%.*s+%d\n", info.eip_fn_namelen, info.eip_fn_name, (uintptr_t)eip - info.eip_fn_addr);
		ebp = (uint32_t*)(*ebp);
		eip = (uint32_t*)*(ebp + 1);
		for (int i = 0; i < 5; ++i)
		{
			arg[i] = *(ebp + i + 2);
		}
	}
	return 0;
}


int
mon_showmappings(int argc, char **argv, struct Trapframe *tf)
{
	uint32_t begin, end;
	char *endptrb, *endptre;
	if(argc == 2)
	{
		begin = ROUNDDOWN((uint32_t)strtol(argv[1], &endptrb, 0), PGSIZE);
		end = begin + PGSIZE;
		assert(*endptrb == '\0');
	}
	else if(argc == 3)
	{
		begin = ROUNDDOWN((uint32_t)strtol(argv[1], &endptrb, 0), PGSIZE);
		end = ROUNDUP((uint32_t)strtol(argv[2], &endptre, 0), PGSIZE);
		assert(*endptrb == '\0' && *endptre == '\0');
	}
	else 
	{
		cprintf("Usage: showmappings va_begin [va_end]\n");
		return 0;
	}
	for (; begin <= end; begin += PGSIZE)
	{
		struct PageInfo *pp;
		pte_t *pte;
		pp = page_lookup(kern_pgdir, (void *)begin, &pte);
		if(pp)
		{
			cprintf("%08x ---> %08x\t", begin, page2pa(pp));
			if(*pte & PTE_U)
				cprintf("User: ");
			else
				cprintf("Kernel: ");
			if(*pte & PTE_W)
				cprintf("Read & Write\n");
			else
				cprintf("Read only\n");
		}
		else
			cprintf("%08x ---> NULL\n", begin);
	}
	return 0;
}

int
mon_setperm(int argc, char **argv, struct Trapframe *tf)
{
	if(argc != 4)
	{
		cprintf("Usage: setperm +/-/= perm(P/W/U/T/C/A/D/S/G) va(0xXXXXXXXX)\n");
		return 0;
	}
	uint32_t va, perm;
	va = strtol(argv[3], NULL, 0);
	switch(argv[2][0])
	{
		case 'P': perm = 0x1; break;
		case 'W': perm = 0x2; break;
		case 'U': perm = 0x4; break;
		case 'T': perm = 0x8; break;
		case 'C': perm = 0x10; break;
		case 'A': perm = 0x20; break;
		case 'D': perm = 0x40; break;
		case 'S': perm = 0x80; break;
		case 'G': perm = 0x100; break;
		default: cprintf("Wrong permission code!\n"); return 0; 
	}
	pte_t *pte;
	pte = pgdir_walk(kern_pgdir, (void *)va, 0);
	if(!pte)
		cprintf("0x%08x is not mapped!\n", va);
	else
	{
		if(argv[1][0] == '+')
			*pte |= perm;
		else if(argv[1][0] == '-')
			*pte &= ~perm;
		else if(argv[1][0] == '=')
			*pte = PTE_ADDR(*pte) | perm;
		else
			cprintf("Wrong operation code!\n");
	}
	return 0;
}

int
mon_dumpmem(int argc, char **argv, struct Trapframe *tf)
{
	if(argc != 4)
	{
		cprintf("Usage: dumpmem p/v address_begin(0xXXXXXXXX) address_end(0xXXXXXXXX)\n");
		return 0;
	}
	uint32_t ab, ae;
	struct PageInfo *pp;
	ab = strtol(argv[2], NULL, 0);
	ae = strtol(argv[3], NULL, 0);
	if(argv[1][0] == 'p')
		ab = (uint32_t)KADDR(ab), ae = (uint32_t)KADDR(ae);
	ab = ROUNDDOWN(ab, PGSIZE);
	ae = ROUNDUP(ae, PGSIZE);
	for(; ab < ae && ab > KERNBASE; ab += 4)
	{
		cprintf("0x%08x:\t", ab);
		cprintf("%08x\n", *(int*)ab);
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

	cprintf("Welcome to the JOS kernel monitor!\n");
	cprintf("Type 'help' for a list of commands.\n");


	while (1) {
		buf = readline("K> ");
		if (buf != NULL)
			if (runcmd(buf, tf) < 0)
				break;
	}
}
