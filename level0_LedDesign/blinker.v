// This file slows down the clock by counting ticks: each counter bit flips half as often as the bit before it. It outputs the 3 slowest bits.

`default_nettype none

module blinker #(
    parameter BITS = 26
) (
    input wire clk,
    output wire [2:0] led
);

    reg [BITS-1:0] count = 0;

    always @(posedge clk) begin
        count <= count + 1;
    end

    assign led = count[BITS-1:BITS-3];
    
endmodule