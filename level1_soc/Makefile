# make - build firmware/firmware.hex
# make dump - show the machine code
# make clean - remove build files
# make sim / make flash - pick DELAY automatically (10 / 300000); override with DELAY=...

# Tools and compiler flags
CROSS = riscv-none-elf-
CFLAGS = -march=rv32i -mabi=ilp32 -O2 -nostdlib -ffreestanding
DELAY ?= 300000
sim: DELAY = 10
flash: DELAY = 300000
FW = firmware

PCF = ../common/upduino.pcf
RTL = top.v soc.v picorv32.v

# .elf -> .bin -> .hex (padded to 8 KB, one 32-bit word per line, for $readmemh)
$(FW)/firmware.hex: $(FW)/firmware.elf
	$(CROSS)objcopy -O binary $< $(FW)/firmware.bin
	python3 -c "import sys;d=open(sys.argv[1],'rb').read();d+=b'\0'*(8192-len(d));[print('%08x'%int.from_bytes(d[i:i+4],'little')) for i in range(0,len(d),4)]" $(FW)/firmware.bin > $@

# Compile and link startup code + C into an .elf
$(FW)/firmware.elf: $(FW)/start.S $(FW)/main.c $(FW)/sections.lds $(FW)/delay.txt 
	$(CROSS)gcc $(CFLAGS) -DDELAY=$(DELAY) -T $(FW)/sections.lds $(FW)/start.S $(FW)/main.c -o $@

# Remember the last DELAY: the file changes only when DELAY changes,
# so the firmware is rebuilt exactly when needed
$(FW)/delay.txt: FORCE
	@echo $(DELAY) | cmp -s - $@ || echo $(DELAY) > $@

FORCE:

# Disassemble the firmware
dump: $(FW)/firmware.elf
	$(CROSS)objdump -d $<

# Build: Verilog -> .json -> .asc -> .bin 
# make flash: build + program the board (no make clean needed)
top.bin: top.asc
	icepack $< $@

top.asc: top.json $(PCF)
	nextpnr-ice40 --up5k --package sg48 --json $< --pcf $(PCF) --asc $@ --freq 12

top.json: $(RTL) $(FW)/firmware.hex
	yosys -q -p "synth_ice40 -top top -json $@" $(RTL)

flash: top.bin
	iceprog -d i:0x0403:0x6014 $<

# Remove build outputs
clean:
	rm -f $(FW)/*.elf $(FW)/*.bin $(FW)/*.hex $(FW)/*.o $(FW)/delay.txt top.json top.asc top.bin a.out soc.vcd

# make sim: Run the self-checking testbench
sim: $(FW)/firmware.hex soc_tb.v soc.v picorv32.v
	iverilog soc_tb.v soc.v picorv32.v
	vvp a.out

.PHONY: dump clean sim flash FORCE