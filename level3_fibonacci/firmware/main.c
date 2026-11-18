// This file is the firmware: it computes the first 48 Fibonacci numbers,
// fib(0) to fib(47), the last one that fits in 32 bits. Each one goes to OUT
// for the testbench and to the LED for the board. Then it starts over.

// LED register at address 0x0200_0000 (bits 0-2 = red, green, blue)
#define LED (*(volatile unsigned int *)0x02000000)

// Result slot at 0x0200_0004: no device here (the bus still answers), but the
// testbench watches the bus and checks every 32-bit value written to it
#define OUT (*(volatile unsigned int *)0x02000004)

// Wait length; set by the Makefile (DELAY=10 for simulation)
#ifndef DELAY
#define DELAY 300000
#endif

// Busy-wait for n loop turns
void delay(int n) {
    for (volatile int i = 0; i < n; i++);
}

// Output fib(0..47) forever, keeping a running pair: fib_a is the current
// number, fib_b the next one (same algorithm as the testbench's golden model)
int main(void) {
    while (1) {
        unsigned int fib_a = 0, fib_b = 1;
        for (int i = 0; i < 48; i++) {
            OUT = fib_a;            // full 32-bit value for the testbench
            LED = fib_a % 8;        // low 3 bits as a color for the board
            delay(DELAY);

            // Step the pair forward: (a, b) -> (b, a + b)
            unsigned int next = fib_a + fib_b;
            fib_a = fib_b;
            fib_b = next;
        }
    }
}
