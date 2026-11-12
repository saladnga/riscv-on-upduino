# riscv-on-upduino

Running a RISC-V CPU on a **UPduino v3.0** (iCE40UP5K FPGA), built step by step.

## Levels

| Level                  | Goal                                                                                       |
| ---------------------- | ------------------------------------------------------------------------------------------ |
| [0](level0_LedDesign/) | FPGA basics: LED designs from blink to PWM breathing ([report](level0_LedDesign/RECAP.md)) |
| 1                      | Run a RISC-V CPU (PicoRV32) with RAM and an LED                                            |
| 2                      | Update the CPU's program without rebuilding the hardware                                   |
| 3                      | Run a real algorithm (Fibonacci) and check the results                                     |
| 4                      | Send text from the CPU to the PC over UART                                                 |
| 5                      | Control the CPU from the PC and measure performance in clock cycles                        |

### Extensions

After the CPU runs on the board:

- **Build a RISC-V core** and verify it with the official RISC-V tests
- **Compare** with PicoRV32 (size, speed, cycles per program)
- **Hardware acceleration:** add a custom multiply-accumulate instruction and measure the speedup

## Tools

Yosys, nextpnr, icepack, iceprog ([OSS CAD Suite](https://github.com/YosysHQ/oss-cad-suite-build)) · Icarus Verilog · `riscv-none-elf-gcc`

Each level folder has a `Makefile`: `make flash` builds and programs the board, `make sim` runs the tests.
