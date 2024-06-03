#include <menix/common.h>
#include <menix/module.h>
#include <menix/stdint.h>
#include <menix/stdio.h>

#include "mod.h"

void example_say_hello()
{
	printf("Hello, world!\n");
}

static int32_t load()
{
	printf("loaded the hello_world module!\n");
	example_say_hello();
	return 0;
}

static void exit()
{
	printf("bye!\n");
}

MENIX_MODULE_INFO {
	.load = load,
	.exit = exit,
};
