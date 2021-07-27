# [Chip Hack](http://www.chiphack.org)

This repository contains tutorial code and
documentation for [Issue 2 of Chiphack](http://www.chiphack.org). 
This has all been updated in 2021 to accomodate Fomu, an FPGA in your USB port! 

### empty

This is a minimal Verilog project for your Fomu. It contains just enough to turn the LED on and a clock buffer.

### blink

Hello blinky! This uses a counter to flash each channel of the RGB LED!

### button

This is a basic project that can use the two capacitive "touch" buttons. This is abstracted into a module.

### deadbeef

This is a string to LED lights project, you can display ABCDEF through different colours

### serialTalker

Similar to deadbeef but over UART from the front pads. A crocodile dile clip and a usb to UART is recommended.

### serialTalkerNumberEdition

This displays binary over the UART

### serialTalkerFibonacciEdition

Displays the fibonacci sequence over the UART

### serialTalkerPRSBEdition

Displays "random" numbers over UART by using linear shift feedback registers

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
