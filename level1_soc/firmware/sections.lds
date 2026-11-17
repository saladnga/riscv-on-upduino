/* This file tells the linker where everything goes: all code and data
   inside the 8 KB RAM, with _start first at address 0. */

/* Memory: 8 KB RAM at address 0 */
MEMORY {
    RAM (rwx) : ORIGIN = 0x00000000, LENGTH = 8K
}

/* Layout: startup code first, then code, constants, data, zeroed data */
SECTIONS {
    .text : { *(.text.start) *(.text*) *(.rodata*) } > RAM
    .data : { *(.data*) *(.sdata*) } > RAM
    .bss : { *(.bss*) *(.sbss*) } > RAM
}

/* Program entry point */
ENTRY(_start)
