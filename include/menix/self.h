//? Compile-time information about the kernel binary itself

#pragma once

#include <menix/common.h>

extern const uint8_t __ld_kernel_start;
extern const uint8_t __ld_kernel_end;

#define SECTION_DECLARE_SYMBOLS(section) \
	extern const uint8_t __ld_sect_##section##_start; \
	extern const uint8_t __ld_sect_##section##_end;

#define SECTION_START(section) (&__ld_sect_##section##_start)
#define SECTION_END(section)   (&__ld_sect_##section##_end)
#define SECTION_SIZE(section)  (SECTION_END(section) - SECTION_START(section))
