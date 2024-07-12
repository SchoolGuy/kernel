//? Interrupt handlers (called by ASM stubs)

#include <menix/arch.h>
#include <menix/log.h>
#include <menix/syscall.h>

#include "menix/common.h"

typedef struct
{
	bool		stop;	 // We cannot continue, we have to stop.
	const char* name;	 // Name of the exception.
} ExceptionTable;

static const ExceptionTable exception_names[] = {
	[0x00] = { .stop = false, .name = "Division Error" },
	[0x01] = { .stop = false, .name = "Non-maskable Interrupt" },
	[0x02] = { .stop = false, .name = "Debug" },
	[0x03] = { .stop = false, .name = "Breakpoint" },
	[0x04] = { .stop = false, .name = "Overflow" },
	[0x05] = { .stop = false, .name = "Bound Range Exceeded" },
	[0x06] = { .stop = false, .name = "Invalid Opcode" },
	[0x07] = { .stop = false, .name = "Device Not Available" },
	[0x08] = { .stop = true, .name = "Double Fault" },
	[0x09] = { .stop = false, .name = "Coprocessor Segment Overrun" },
	[0x0A] = { .stop = false, .name = "Invalid TSS" },
	[0x0B] = { .stop = false, .name = "Segment Not Present" },
	[0x0C] = { .stop = false, .name = "Stack-Segment Fault" },
	[0x0D] = { .stop = false, .name = "General protection Fault" },
	[0x0E] = { .stop = false, .name = "Page Fault" },
	[0x0F] = { .stop = true }, // Reserved
	[0x10] = { .stop = false, .name = "x87 Floating-Point Exception" },
	[0x11] = { .stop = false, .name = "Alignment Check" },
	[0x12] = { .stop = true, .name = "Machine Check" },
	[0x13] = { .stop = false, .name = "SIMD Floating-Point Exception" },
	[0x14] = { .stop = false, .name = "Virtualization Exception" },
	[0x15] = { .stop = false, .name = "Control Protection Exception" },
	[0x16 ... 0x1B] = { .stop = true }, // Reserved
	[0x1C] = { .stop = false, .name = "Hypervisor Injection Exception" },
	[0x1D] = { .stop = false, .name = "VMM Communication Exception" },
	[0x1E] = { .stop = false, .name = "Security Exception" },
	[0x1F] = { .stop = true }, // Reserved
};

void error_handler(uint8_t fault)
{
	bool should_stop = true;
	if (fault >= ARRAY_SIZE(exception_names))
		kmesg(LOG_ERR, "Unknown error %u!\n", (uint32_t)fault);
	else
	{
		kmesg(LOG_ERR, "%s!\n", exception_names[fault].name);
		should_stop = exception_names[fault].stop;
	}

	if (should_stop)
	{
		// Stop the kernel.
		asm volatile("cli");
		asm volatile("hlt");
		while (1)
			;
	}
}

void error_handler_with_code(uint32_t fault, uint32_t code)
{
	bool should_stop = true;
	if (fault >= ARRAY_SIZE(exception_names))
		kmesg(LOG_ERR, "Unknown error!\n");
	else
	{
		kmesg(LOG_ERR, "%s! (Code: %u)\n", exception_names[fault].name, code);
		should_stop = exception_names[fault].stop;
	}

	if (should_stop)
	{
		// Stop the kernel.
		asm volatile("cli");
		asm volatile("hlt");
		while (1)
			;
	}
}

void syscall_handler(SyscallArgs* regs)
{
	// RAX contains the syscall number.
	// Check if number is inside bounds.
	if (regs->rax <= SYSCALL_MAX)
	{
		SyscallFn fn = syscall_table[regs->rax];
		// Invoke the respective system call if it's set.
		if (fn != NULL)
			// Just use the x86_64 ABI here.
			fn(regs->rdi, regs->rsi, regs->rdx, regs->r10, regs->r8, regs->r9);
	}
}