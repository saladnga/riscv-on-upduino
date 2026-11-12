// This file makes a brightness number that goes up 0 -> 255 and back down by reading slow counter bits (and flipping them with ~ on the way down).

`default_nettype none

module breathe #(
    parameter N = 27
) (
    input wire clk,
    output wire [7:0] bright
);

    reg [N-1:0] count = 0;
    wire [7:0] level = count[N-2:N-9];
    
    always @(posedge clk) begin
        count <= count + 1;
    end

    assign bright = count[N-1] ? ~level : level;
        
endmodule