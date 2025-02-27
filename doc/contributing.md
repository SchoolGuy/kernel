# Contributing
This document explains how to format and submit contributions to
the `menix` project.

## General rules
- **NO** discriminatory behavior, everyone should be welcome to contribute.
- Every submission should solve exactly **ONE** problem.
- Your submission **MUST** be written by you.
- Your code **MUST** be licensed under the project's main license, or
  one that has less restrictions.
- Currently, the following licenses are supported:
	- LGPL-2.1-or-later
	- BSD-2-Clause
	- BSD-3-Clause
	- MIT

At the top of each file, include the following section. It should contain a
very brief summary of the file's purpose, followed by the SPDX identifier of
the code. If it is omitted, it's assumed to be the same as the project's
main license.

<!-- REUSE-IgnoreStart -->
  **Example:**
  ```c
  // Example Code
  // SPDX-License-Identifier: BSD-3-Clause
  ```
<!-- REUSE-IgnoreEnd -->

## Coding style
The following section explains how code is expected to be formatted in order
to make it easier to read for other people. Use the `.clang-format` file in the
project root to check if your code complies with these guidelines.

- Tabs have a width of 4 characters.
- Always use tabs for indentation.
- All code should be less than 120 characters in width.
- All code should end on an empty newline.
- Write comments and messages in present tense and easy to understand English.
- Split your code into paragraphs where it makes sense and comment what
  each one does.
- Always use single line (aka C++ style) comments.
- Headers should always use `#pragma once` instead of header guards.
- Headers should first include standard libary headers, then `menix` headers,
  then relative headers.
- **DO NOT** include out of tree headers like `#include "../../random.h"`,
  always use `#include <path/to/random.h>` instead.
- Scope braces `{ }` begin and end on a new line.
- For primitives, always use standard types like `i32` and `u8`
  over built-in types like `int` or `unsigned char` (exception here is `char`).
- Avoid `i64` and `u64`, as they're not available on all platforms.
  Consider using `isize` and `usize` instead.
- Function declarations are always in one line.
- Structs and unions are to be declared via `typedef`. They should be anonymous.
- Multi-line `typedef`s have the alias name and closing brace on the same line.
- Pointer stars are part of the type and should be written as `Type*`.
- Avoid raw and inline assembly at all costs to keep the codebase portable.
- Prefer clear and descriptive variable names over short ones.
- Local variables and fields use `snake_case`.
- Defines use `SCREAMING_CASE`.
- Functions use `snake_case`.
- Types use `PascalCase`.
- Function Types should have a `Fn` suffix.
- Use the `const` keyword often to communicate intent with function parameters.
