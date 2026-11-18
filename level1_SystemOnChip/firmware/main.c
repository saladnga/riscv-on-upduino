// This file is the firmware: it counts up forever and writes each number to
// the LED register, waiting a little between writes.

// LED register at address 0x0200_0000 (bits 0-2 = red, green, blue)
#define LED (*(volatile unsigned int *)0x02000000)

// Wait length; set by the Makefile (DELAY=10 for simulation)
#ifndef DELAY
#define DELAY 300000
#endif

// Busy-wait for n loop turns
void delay(int n) {
    for (volatile int i = 0; i < n; i++);
}

// Write 0, 1, 2, ... to the LED, forever
int main(void) {
    unsigned int x = 0;
    while (1) {
        LED = x;
        x++;
        delay(DELAY);
    }
}
