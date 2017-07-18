Verilog button example
=======================

## Inputs and Outputs

This module is similar to the blink example, except we also require to the buttons input.

The ports in both `chip.v` and `button.v` are missing, you will need to add these.

For the buttons the ports are:

```verilog
[1:0] BUT
```

## Logic

On the click of a button we want to increment a counter and display this onto the LEDs. Therefore we shall require a count register and an always block which is triggered by the edge of a button press. Then for the LEDs to represent the count register.

## Extension

Can you then combine this with the blink we did previously to make an auto incrementing counter?
