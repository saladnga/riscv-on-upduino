# Pick ONE design below (0.1 on, 0.2 blink, 0.3 colors, 0.4 breathe),
# then: make clean && make flash (or: make TOP=top_blink flash)
# Tests (no board): make sim | sim_pwm | sim_breathe

TOP = top_on
# TOP = top_blink
# TOP = top_colors
# TOP = top_breathe

PCF = ../common/upduino.pcf

SRCS = $(TOP).v blinker.v pwm.v breathe.v

$(TOP).bin: $(TOP).asc
		icepack $< $@

$(TOP).asc: $(TOP).json $(PCF)
		nextpnr-ice40 --up5k --package sg48 --json $< --pcf $(PCF) --asc $@

$(TOP).json: $(SRCS)
		yosys -q -p "synth_ice40 -top $(TOP) -json $@" $(SRCS)

flash: $(TOP).bin
		iceprog -d i:0x0403:0x6014 $<

sim: blinker_tb.v blinker.v
		iverilog blinker_tb.v blinker.v
		vvp a.out

sim_pwm: pwm_tb.v pwm.v
		iverilog pwm_tb.v pwm.v
		vvp a.out

sim_breathe: breathe_tb.v breathe.v
		iverilog breathe_tb.v breathe.v
		vvp a.out

clean:
		rm -f *.json *.asc *.bin

.PHONY: flash clean sim sim_pwm sim_breathe