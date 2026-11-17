// This file sets LED brightness by switching it on and off very fast while a fast counter is below 'duty'. Bigger duty = on longer = brighter.

`default_nettype none

module pwm #(
    parameter WIDTH = 8
) (
    input wire clk,
    input wire [WIDTH-1:0] duty,
    output wire out
);

    // Counter: sweeps 0 to 2^WIDTH - 1, over and over
    reg [WIDTH-1:0] count = 0;

    always @(posedge clk) begin
        count <= count + 1;
    end

    // Output: on while count is below duty
    assign out = (count < duty);
    
endmodule