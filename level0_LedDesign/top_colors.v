// Level 0.3 - Color cycle
// This file cycles the LED through 8 colors by sending 3 slow counter bits to red, green and blue (off, red, green, yellow, blue, purple, cyan, white).

`default_nettype none

module top_colors (
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

    blinker #(.BITS(26)) b (
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
        .RGB1PWM (blink[2]),    // blue
        .RGB2PWM (blink[0]),    // red
        .RGB0 (led_green),
        .RGB1 (led_blue),
        .RGB2 (led_red)
    );
    
endmodule