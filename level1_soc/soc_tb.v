// This file tests soc.v by running the firmware on the CPU and checking that
// the LED counts 1, 2, 3 ... for 10 steps. Prints PASS, or FAIL on a wrong
// value or a timeout.

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

    // Checker: each LED change must equal the previous value + 1
    reg [2:0] expected = 1;
    integer changes = 0;
    always @(led) begin
        if (resetn) begin
            if (led != expected) begin
                $display("FAIL: expected %0d, saw %0d", expected, led);
                $finish;
            end else begin
                expected = expected + 1;
                changes = changes + 1;
            end

            // Verdict: PASS after 10 correct changes
            if (changes == 10) begin
                $display("PASS: LED counted 10 steps correctly");
                $finish;
            end
        end
    end

    // Timeout: FAIL if PASS hasn't happened by 200,000 ns
    initial begin
        #200000 $display("FAIL: timeout, LED stopped changing.");
        $finish;
    end

endmodule