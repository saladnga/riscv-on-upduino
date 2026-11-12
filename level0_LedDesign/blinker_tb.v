// This file tests blinker.v without a board by giving it a fake clock and printing the counter and LED bits on every tick.

`timescale 1ns/1ps
`default_nettype none

module blinker_tb;
    reg clk = 0;
    wire [2:0] led;

    blinker #(.BITS(4)) dut (
        .clk(clk),
        .led(led)
    );

    always #1 clk = ~clk;

    initial begin
        $dumpfile("blinker.vcd");
        $dumpvars(0, blinker_tb);
        $monitor("t=%0t count=%2d led=%b", $time, dut.count, led);
        #80 $finish;
    end

    
endmodule