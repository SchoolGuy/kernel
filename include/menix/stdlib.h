/*-------------------------
Kernel C library - stdlib.h
-------------------------*/

#pragma once

#include <menix/common.h>
#include <menix/stdint.h>

void  abort();
char* itoa(int32_t, char*, uint32_t);
char* utoa(uint32_t, char*, uint32_t);