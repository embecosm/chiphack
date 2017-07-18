Verilog blink example
=======================

## Inputs and Outputs

```verilog
module blink(input clk, output led);
```

The modules only input is the 100Mhz clock and only outputs are the LEDs, these have been assigned from the appropriate PMOD ports in the `chip.v` file.

## Logic

To make a blink we shall create a counter, incrementing on the positive edge of the clock. We the need to choose an appropriate bit to look at so that it is slow enough for the human eye to see a change.

![Alt Text](http://i.imgur.com/15ShJml.gif)
