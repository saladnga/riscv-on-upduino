// This file tests soc.v by running the firmware on the CPU and checking every
// value it writes to the result slot 0x0200_0004 against a golden model:
// fib(0) to fib(47). Prints PASS, or FAIL on a wrong value or a timeout.

`timescale 1ns/1ps
`default_nettype none

module soc_tb;
    reg clk = 0;
    reg resetn = 0;
    wire [2:0] led;

    // Device under test
    soc dut (
        .clk(clk),
        .resetn(resetn),
        .led(led)
    );

    // Clock: one tick every 2 ns
    always #1 clk = ~clk;

    // Record the waveform, hold reset for 20 ns, then release the CPU
    initial begin
        $dumpfile("soc.vcd");
        $dumpvars(0, soc_tb);
        #20 resetn = 1;
    end

    // Golden model: our own Fibonacci, independent of the CPU.
    // fib_a = value expected next from the firmware, fib_b = the one after it
    reg [31:0] fib_a = 0;
    reg [31:0] fib_b = 1;
    integer count = 0;

    // Checker: watch the CPU bus inside the SoC (dut.*). A write is complete
    // when valid and ready are both high, so each value is caught exactly once.
    always @(posedge clk) begin
        if (dut.mem_valid && dut.mem_ready && dut.mem_addr == 32'h02000004 && dut.mem_wstrb == 4'hf) begin
            // Compare the CPU's value with the golden model
            if (dut.mem_wdata != fib_a) begin
                $display("FAIL: n=%0d expected %0d, saw %0d", count, fib_a, dut.mem_wdata);
                $finish;
            end else begin
                // Step the model: <= reads the old values, so this is
                // (a, b) -> (b, a + b) with no temp variable
                fib_a <= fib_b;
                fib_b <= fib_a + fib_b;
                count <= count + 1;
            end
            // count updates after this edge, so it reads 47 while checking
            // the 48th value, fib(47)
            if (count == 47) begin
                $display("PASS: 48 Fibonacci numbers correct");
                $finish;
            end
        end
    end

    // Timeout: FAIL if PASS hasn't happened by 200,000 ns
    initial begin
        #200000 $display("FAIL: timeout, no Fibonacci output.");
        $finish;
    end

endmodule