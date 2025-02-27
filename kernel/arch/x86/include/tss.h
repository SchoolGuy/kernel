// Task State Segment
//! menix uses software multitasking, the TSS is only really used as a placeholder.

#include <menix/common.h>

typedef struct ATTR(packed)
{
	u32 reserved0;
	u64 rsp0;
	u64 rsp1;
	u64 rsp2;
	u32 reserved1;
	u32 reserved2;
	u64 ist1;
	u64 ist2;
	u64 ist3;
	u64 ist4;
	u64 ist5;
	u64 ist6;
	u64 ist7;
	u32 reserved3;
	u32 reserved4;
	u32 iopb;
} TaskStateSegment;

// Initializes the TSS.
void tss_init(TaskStateSegment* tss);

// Sets the RSP fields in the TSS to the given stack pointer.
void tss_set_stack(TaskStateSegment* tss, void* rsp);
