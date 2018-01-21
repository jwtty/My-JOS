#ifndef JOS_INC_ARM_H
#define JOS_INC_ARM_H

static inline void load_pgdir(uint32_t value) {
	asm volatile ("mcr p15, 0, %0, c2, c0, 0" : : "r"(value));
}

static inline uint32_t read_r11(void)
{
	uint32_t r11;
	asm volatile("mov %0, r11" : "=r" (r11));
	return r11;
}

#endif
