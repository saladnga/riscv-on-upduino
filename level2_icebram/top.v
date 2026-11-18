// This file puts the SoC on the UPduino by giving it a 12 MHz clock from the
// internal oscillator, a power-on reset, and connecting its 3 LED bits to the
// RGB LED driver.

`default_nettype none

module top (
    output wire led_red,
    output wire led_green,
    output wire led_blue
);
    wire clk;

    // Clock 12 MHz
    SB_HFOSC #(
        .CLKHF_DIV("0b10")
    ) osc (
        .CLKHFPU(1'b1),
        .CLKHFEN(1'b1),
        .CLKHF(clk)
    );

    // Power-on reset
    reg [7:0] por = 0;
    wire resetn = (por == 8'hFF);
    always @(posedge clk) begin
        if (!resetn) begin
            por <= por + 1;
        end
    end

    wire [2:0] led;
    soc #(
        .FIRMWARE("firmware/random.hex")
    ) s (
        .clk(clk),
        .resetn(resetn),
        .led(led)
    );

    SB_RGBA_DRV #(
        .RGB0_CURRENT("0b000001"),
        .RGB1_CURRENT("0b000001"),
        .RGB2_CURRENT("0b000001")
    ) rgb (
        .CURREN (1'b1),
        .RGBLEDEN (1'b1),
        .RGB0PWM (led[1]),    // green
        .RGB1PWM (led[2]),    // blue
        .RGB2PWM (led[0]),    // red
        .RGB0 (led_green),
        .RGB1 (led_blue),
        .RGB2 (led_red)
    );
endmodule
