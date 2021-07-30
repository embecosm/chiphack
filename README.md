# [Chip Hack](http://www.chiphack.org)

This repository contains tutorial code and
documentation for [Issue 2 of Chiphack](http://www.chiphack.org). 
This has all been updated in 2021 to accomodate Fomu, an FPGA in your USB port! 

### empty

This is a minimal Verilog project for your Fomu. It contains just enough to turn the LEDs on and a clock buffer.

### blink

Hello blinky! This uses a counter to flash each colour of the RGB LED!

### button

This is a basic project that can use the two capacitive "touch" buttons. The button logic is inside a module.

### buttonHalfAdder

This is the button project but with a half adder using the two buttons as inputs, and the blue and red LEDs acting as sum and carry outputs.

### deadbeef

This is an ASCII string to LED lights project, you can display ABCDEF through different colours.

### serialTalker

Similar to deadbeef but over UART from the front pads. A crocodile clip and a usb to UART is needed.

### serialTalkerNumberEdition

This displays binary over the UART using ASCII characters. 

### serialTalkerFibonacciEdition

Displays the fibonacci sequence over the UART.

### serialTalkerPRBSEdition

Displays "random" numbers over UART by using a linear shift feedback register.

## Prerequisites

To install everything I recommend following the Fomu Toolchain installation guide! 
 - [Required-Software](https://workshop.fomu.im/en/latest/requirements/software.html#required-software)


## To compile and upload programs

Full guidance is provided in the ChipHack Fomu application notes. 
(Link coming soon!)

The simple way is probably just to use ```make load``` in the folder with your project + makefile. You'll also have to add your 
```export FOMU_REV=pvt``` to your bash profile.

## Files
The following files have been taken from various [im-tomu](https://github.com/im-tomu) repositories. 
These are licensed under Apache 2.0. I have lovingly included a short notice in each file. 

* board.mk
* container.mk
* fomu-pvt.pcf
* PnR_Prog.mk
* Makefile
* blink.v 

All other projects are derivatives of blink.v 
