[Chip Hack](http://www.chiphack.org)
====================================

This repository (and its companion [wiki](https://github.com/embecosm/chiphack/wiki)) contains tutorial code and documentation for the [Chip Hack](http://www.chiphack.org) EDSAC Challenge, to be held in Hebden Bridge from the 6th to the 8th of September 2017. You can register you interest at: https://www.eventbrite.co.uk/e/chiphack-edsac-challenge-registration-35008847405

Repository guide
================
basic_verilog
-------------
The files are mostly empty, you shall be guided through filling these out.

pretty_colours
--------------
A full project, with a chip.bin, so that you can test your installation of the tools

cheat_sheet
-----------
Corresponds to the basic_verilog files, if you get stuck.

Prerequisites
=============
To install everything you need follow the guides on chiphack.org:
 - [Linux](http://chiphack.org/chiphack-2017-install-linux.html)
 - [macOS](http://chiphack.org/chiphack-2017-install-mac.html)
 - [Windows](http://chiphack.org/chiphack-2017-install-windows.html)

To compile programs
===================
Linux
-----
Simply run the `make` for the basic led example, for others run make followed by the project name, e.g. `make blink`

macOS
-----
You will need to change the makefile, by commenting out the linux lines and uncommenting the mac lines, then as above.

Windows
-------
You will need to copy the blackice.pcf into the folder you want to compile, then run `apio build --size 8k --type hx --pack tq144:4k`

To upload programs
==================
Connect to the middle USB port.

Linux
-----
Once having compiled and got your chip.bin, run `make upload`

macOS
-----
You will need to have changed your makefile, else same as linux

Windows
-------
You will need to connect to the board using tera term. Select the serial option, then go to setup>serial. Delete the Baud rate option, set data as 8 bit, no parity, 1 bit stop and no flow control.

Then file>send file navigate to hardware.bin , tick the Binary option box and open.
