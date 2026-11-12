# Level 0 Report: LED Designs on the UPduino v3.0

**Board:** UPduino v3.0  
**Toolchain:** Yosys → nextpnr-ice40 → icepack → iceprog / Icarus Verilog for simulation

## Summary

Built four LED designs from scratch in Verilog, each adding one new idea: a constant output, a counter-based blinker, multi-bit color mixing, and PWM brightness control. Every logic module was verified in simulation with its own testbench before running on hardware. All four designs work on the board. The final design uses **48 of 5,280 logic cells (<1%)** and meets timing at **71.8 MHz** (running at 12 MHz).

This level was about learning the full FPGA workflow (write → simulate → synthesize → place & route → program).

## Architecture

Every design shares the same structure; only the logic in the middle changes:

```
[ SB_HFOSC ]  ──clk 12 MHz──►  [ my logic ]  ──►  [ SB_RGBA_DRV ]  ──►  RGB LED
 internal oscillator             per step            LED current driver
 (48 MHz ÷ 4)
```

## Results

| Step | Design | Idea | On the board |
|---|---|---|---|
| 0.1 | `top_on.v` | Constants into the LED driver (no clock); tests the toolchain | Solid green |
| 0.2 | `top_blink.v` + `blinker.v` | Counter as clock divider: bit 23 flips every 2²³ ticks ≈ 0.7 s | Green blinks, 0.7 s |
| 0.3 | `top_colors.v` + `blinker.v` | 3 counter bits drive R/G/B → 8 states (off + 7 colors) | Color cycle, 0.7 s each |
| 0.4 | `top_breathe.v` + `pwm.v` + `breathe.v` | PWM sets brightness; a slow ramp drives the PWM | Fades in/out, ~5.6 s each way |

## How It Works (Step 0.4: Breathing)

**Idea.** An LED pin can only be fully on or off. To make it *look* dimmer, switch it on and off faster than the eye can see: the eye sees the average. Then slowly change that average up and down, and the LED appears to breathe.

**Approach.** Split the job into two modules, each doing one thing, joined in `top_breathe.v`:

```
clk ──► breathe.v ──bright[7:0]──► pwm.v (duty) ──glow──► green LED
        "how bright should it be?"  "make it look that bright"
```

| File | Job |
|---|---|
| `pwm.v` | Turns a number (`duty`, 0–255) into a brightness |
| `breathe.v` | Produces that number, slowly rising and falling |
| `top_breathe.v` | Wires the oscillator → `breathe` → `pwm` → LED driver |

**How.**

1. **`pwm.v`: brightness from a number.** An 8-bit counter sweeps 0 → 255 about 47,000 times per second. The output is on while `count < duty`.

   ```
   duty = 64:   ████░░░░░░░░░░░░   on 64/256 of the time  → 25% bright
   duty = 192:  ████████████░░░░   on 192/256 of the time → 75% bright
   ```

2. **`breathe.v`: the slow ramp.** A 27-bit counter ticks at 12 MHz.
   - Bits 25–18 (`level`) count 0 → 255, one step every 2¹⁸ ticks ≈ 22 ms, so ~5.6 s for the full ramp.
   - Bit 26 is the direction. When it is 1, the output is `~level` (all bits flipped), which turns 0, 1, 2 … 255 into 255, 254 … 0, so the same count plays backwards.
   - At the turnaround, `level` wraps to 0 and `~0 = 255`, so the brightness holds at the top instead of jumping to dark.

   ```
   bright:  0 ↗ 255 → 255 ↘ 0 → 0 ↗ 255 …
            └ 5.6 s ┘   └ 5.6 s ┘
   ```

3. **`top_breathe.v`: connect them.** `bright` from `breathe` goes into `pwm`'s `duty`, and `pwm`'s output drives the green channel of the LED driver.

**Result:** the green LED fades in for ~5.6 s, holds briefly, fades out for ~5.6 s, and repeats (48 cells, 71.8 MHz max).

## Verification

Each logic module has a testbench. Counter widths are parameters, so the same code runs with a small counter in simulation (fast) and the full counter on hardware.

| Module | Test | Result |
|---|---|---|
| `blinker.v` | 4-bit counter, check which counts set each output bit | ✓ |
| `pwm.v` | duty = 4 → on 4/16 ticks; duty = 12 → on 12/16 | ✓ |
| `breathe.v` | 10-bit counter, check ramp 0 → 255 → 0 and the turnaround | ✓ |
| All designs | Synthesized, placed and routed, flashed to the board | ✓ |

## Reproduce

```bash
make TOP=top_on flash        # 0.1 solid green
make TOP=top_blink flash     # 0.2 blink
make TOP=top_colors flash    # 0.3 color cycle
make TOP=top_breathe flash   # 0.4 breathing

make sim                     # blinker testbench
make sim_pwm                 # pwm testbench
make sim_breathe             # breathe testbench
```

Pin constraints: `../common/upduino.pcf`
