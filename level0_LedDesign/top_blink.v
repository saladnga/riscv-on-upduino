// Level 0.2 - Blink
// This file blinks the green LED by counting clock ticks and showing one slow bit of the counter (bit 23 flips about every 0.7 s).

`default_nettype none

module top_blink (
    output wire led_red,
    output wire led_green,
    output wire led_blue
);

    wire clk;

    SB_HFOSC #(
        .CLKHF_DIV("0b10")
    ) osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );

    wire [2:0] blink;

    blinker #(.BITS(24)) b (
        .clk(clk),
        .led(blink)
    );

    SB_RGBA_DRV #(
        .RGB0_CURRENT("0b000001"),
        .RGB1_CURRENT("0b000001"),
        .RGB2_CURRENT("0b000001")
    ) rgb (
        .CURREN (1'b1),
        .RGBLEDEN (1'b1),
        .RGB0PWM (blink[1]),    // green
        .RGB1PWM (1'b0),    // blue
        .RGB2PWM (1'b0),    // red
        .RGB0 (led_green),
        .RGB1 (led_blue),
        .RGB2 (led_red)
    );
    
endmodule