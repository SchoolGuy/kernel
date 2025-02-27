// Kernel memory allocation

#pragma once
#include <menix/common.h>

// Returns a memory region with at least `bytes` bytes of uninitialized memory.
void* kalloc(usize bytes);

// Returns a memory region with at least `bytes` bytes of uninitialized memory, aligned to `alignment`.
// `alignment` may not exceed `bytes`.
void* kaalloc(usize bytes, usize alignment);

// Returns a memory region with at least `bytes` bytes of zeroed memory.
// Not the same as `kalloc` + `memset`. This function may also zero past the requested size.
void* kzalloc(usize bytes);

// Frees a block of memory allocated by one of the `k*alloc` functions.
// Any reference to the memory region is invalid after calling this.
void kfree(void* memory);
