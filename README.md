# [Chip Hack](http://www.chiphack.org)

This repository contains tutorial code and
documentation for the [Chip Hack](http://www.chiphack.org) events. 
This has all been updated in 2021 to accomodate Fomu, an FPGA in your USB port! 

### empty

This is a minimal Verilog project for your Fomu. It contains just enough to turn the LED on and a clock buffer.

### blink

Hello blinky! This uses a counter to flash each channel of the RGB LED!

### TBD

For future use! I can hope for a UART one day :)

## Prerequisites

To install everything I recommend following the Fomu Toolchain installation guide! 
 - [Required-Software](https://workshop.fomu.im/en/latest/requirements/software.html#required-software)


## To compile and upload programs

Full guidance is provided in the ChipHack Fomu application notes. 
(Link coming soon!)

The simple way is probably just to use ```make; make load``` in the folder with your project + makefile
