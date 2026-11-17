// Level 0.4 - Breathing LED
// This file makes the green LED fade in and out by feeding a slowly rising and falling number (breathe) into a fast on/off brightness controller (pwm).

`default_nettype none

module top_breathe (
    output wire led_red,
    output wire led_green,
    output wire led_blue
);

    // Clock: internal oscillator, 12 MHz
    wire clk;

    SB_HFOSC #(
        .CLKHF_DIV("0b10")
    ) osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );

    // Brightness ramp: 0 -> 255 -> 0
    wire [7:0] bright;
    breathe br (
        .clk(clk),
        .bright(bright)
    );

    // PWM: brightness number -> fast on/off
    wire glow;
    pwm p (
        .clk(clk),
        .duty(bright),
        .out(glow)
    );

    // LED driver: PWM output to green
    SB_RGBA_DRV #(
        .RGB0_CURRENT("0b000001"),
        .RGB1_CURRENT("0b000001"),
        .RGB2_CURRENT("0b000001")
    ) rgb (
        .CURREN (1'b1),
        .RGBLEDEN (1'b1),
        .RGB0PWM (glow),    // green: breathing effect
        .RGB1PWM (1'b0),    // blue
        .RGB2PWM (1'b0),    // red
        .RGB0 (led_green),
        .RGB1 (led_blue),
        .RGB2 (led_red)
    );
    
endmodule