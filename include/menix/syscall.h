//? System call interface + prototypes

#include <menix/common.h>
#include <menix/self.h>

#include <bits/syscall.h>

#define SYSCALL_MAX 256

// This macro should be used when implementing a syscall, so that the naming scheme stays portable.
#define SYSCALL_IMPL(name) size_t syscall_##name(size_t a0, size_t a1, size_t a2, size_t a3, size_t a4, size_t a5)

typedef size_t		   (*SyscallFn)(size_t a0, size_t a1, size_t a2, size_t a3, size_t a4, size_t a5);
extern const SyscallFn syscall_table[];