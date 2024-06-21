/*? x86 Bootstrap */

.intel_syntax noprefix

# Stack
.section .bootstrap_stack, "aw", @nobits
stack_bottom:
.skip 32768 # 32 KiB
stack_top:

.section .bss, "aw", @nobits
	.align 4096
boot_page_directory:
	.skip 4096
boot_page_table1:
	.skip 4096

.section .entry, "a"
.code32										# 32-bit bootstrap

.global _start
.type _start, @function
_start:
kernel_init:
	cli										# Disable interrupts.
	mov		esp, stack_top - stack_bottom	# Setup the stack.
	call	kernel_main						# Call the kernel entry point.
kernel_hang:
	cli
	hlt										# Hang once kernel exits.
1:
	jmp 1b
