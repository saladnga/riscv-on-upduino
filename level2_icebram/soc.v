// This file builds a tiny computer by connecting a RISC-V CPU
// (PicoRV32) to an 8 KB RAM and an LED, and sorting each memory request
// to the right one by its address.

`default_nettype none

module soc #(
    parameter FIRMWARE = "firmware/firmware.hex"
) (
    input wire clk,
    input wire resetn,
    output reg [2:0] led
);
    // Memory map
    localparam RAM_SIZE = 32'h0000_2000;
    localparam LED_ADDR = 32'h0200_0000;
    localparam RAM_ADDR = 32'h0000_0000;

    // CPU bus signals
    wire mem_valid;
    wire [31:0] mem_addr;
    wire [3:0] mem_wstrb;
    reg [31:0] mem_rdata;
    wire [31:0] mem_wdata;
    reg mem_ready = 0;

    // Address decoder: which device the address belongs to
    wire is_ram = (mem_addr < RAM_SIZE);
    wire is_led = (mem_addr == LED_ADDR);

    // RAM: 2048 words, loaded with the firmware; LED starts off
    reg [31:0] ram [0:RAM_SIZE/4-1];
    initial begin
        $readmemh(FIRMWARE, ram);
        led = 0;
    end

    // CPU: starts executing at address 0
    picorv32 #(.PROGADDR_RESET(RAM_ADDR)) cpu (
        .clk(clk),
        .resetn(resetn),
        .mem_valid(mem_valid),
        .mem_ready(mem_ready),
        .mem_addr(mem_addr),
        .mem_wdata(mem_wdata),
        .mem_wstrb(mem_wstrb),
        .mem_rdata(mem_rdata),
        .mem_instr()
    );

    always @(posedge clk) begin
        // Ready: answer each request once, one tick later
        mem_ready <= mem_valid && !mem_ready;

        // RAM read
        if (is_ram) begin
            mem_rdata <= ram[mem_addr[12:2]];
        end

        // RAM write: only the bytes selected by mem_wstrb
        if (mem_valid && is_ram) begin
            if (mem_wstrb[0]) begin
                ram[mem_addr[12:2]][7:0] <= mem_wdata[7:0];
            end
            if (mem_wstrb[1]) begin
                ram[mem_addr[12:2]][15:8] <= mem_wdata[15:8];
            end
            if (mem_wstrb[2]) begin
                ram[mem_addr[12:2]][23:16] <= mem_wdata[23:16];
            end
            if (mem_wstrb[3]) begin
                ram[mem_addr[12:2]][31:24] <= mem_wdata[31:24];
            end
        end

        // LED write: store the low 3 bits
        if (mem_valid && is_led && mem_wstrb[0]) begin
            led <= mem_wdata[2:0];
        end
    end

endmodule
