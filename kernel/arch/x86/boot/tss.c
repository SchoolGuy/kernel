// Task State Segement helper functions

#include <menix/log.h>

#include <tss.h>

void tss_init(TaskStateSegment* tss)
{
	kassert(tss != NULL, "No valid TSS was provided!\n");
	tss->rsp0 = 0;
	tss->rsp1 = 0;
	tss->rsp2 = 0;
	tss->iopb = sizeof(TaskStateSegment);
}

void tss_set_stack(TaskStateSegment* tss, void* rsp)
{
	kassert(tss != NULL, "No valid TSS was provided!\n");
	tss->rsp0 = (uint64_t)rsp;
	tss->rsp1 = (uint64_t)rsp;
	tss->rsp2 = (uint64_t)rsp;
}
