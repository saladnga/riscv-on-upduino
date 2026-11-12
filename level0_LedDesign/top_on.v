// Level 0.1 - LED on
// This file turns the green LED on by wiring fixed values (1 = on, 0 = off) straight into the LED driver. No clock, no logic: it just checks the tools work.

`default_nettype none

module top_on (
    output wire led_red,
    output wire led_green,
    output wire led_blue
);

    SB_RGBA_DRV #(
        .RGB0_CURRENT("0b000001"),
        .RGB1_CURRENT("0b000001"),
        .RGB2_CURRENT("0b000001")
    ) rgb (
        .CURREN (1'b1),
        .RGBLEDEN (1'b1),
        .RGB0PWM (1'b1),    // green: ON
        .RGB1PWM (1'b0),    // blue: OFF
        .RGB2PWM (1'b0),    // red: OFF
        .RGB0 (led_green),
        .RGB1 (led_blue),
        .RGB2 (led_red)
    );
    
endmodule