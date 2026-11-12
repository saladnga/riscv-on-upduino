// This file tests pwm.v without a board by setting a fixed duty and checking the output is on for exactly 'duty' out of every 16 ticks.

`timescale 1ns/1ps
`default_nettype none

module pwm_tb;
    reg clk = 0;
    wire out;
    reg [3:0] duty = 4;

    pwm #(.WIDTH(4)) dut (
        .clk(clk),
        .out(out),
        .duty(duty)
    );

    always #1 clk = ~clk;

    initial begin
        $dumpfile("pwm.vcd");
        $dumpvars(0, pwm_tb);
        $monitor("t=%0t count=%2d out=%b", $time, dut.count, out);
        #80 $finish;
    end

    
endmodule