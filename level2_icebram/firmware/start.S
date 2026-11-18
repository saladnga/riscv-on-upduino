# This file is the first code the CPU runs: it sets up the stack, calls main,
# and parks the CPU in a loop if main ever returns.

.section .text.start            # placed at address 0 by sections.lds
.global _start
_start:
    li sp, 0x2000               # stack starts at the top of the 8 KB RAM
    call main                   # run the C program
    1: j 1b                     # main returned: loop here forever
