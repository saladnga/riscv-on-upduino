// This file tests breathe.v without a board by running one short breath (1024 ticks) and printing bright as it goes 0 -> 255 -> 0.

`timescale 1ns/1ps
`default_nettype none

module breathe_tb;
    reg clk = 0;
    wire [7:0] bright;

    breathe #(.N(10)) dut (
        .clk(clk),
        .bright(bright)
    );

    always #1 clk = ~clk;

    initial begin
        $dumpfile("breathe.vcd");
        $dumpvars(0, breathe_tb);
        $monitor("t=%0t dir=%b bright=%3d", $time, dut.count[9], bright);
        #2100 $finish;
    end

endmodule