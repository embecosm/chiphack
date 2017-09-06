# [Chip Hack](http://www.chiphack.org)

This repository (and its companion
[wiki](https://github.com/embecosm/chiphack/wiki)) contains tutorial code and
documentation for the [Chip Hack](http://www.chiphack.org) EDSAC Challenge, to
be held in Hebden Bridge from the 6th to the 8th of September 2017. You can
register you interest at:
https://www.eventbrite.co.uk/e/chiphack-edsac-challenge-registration-35008847405

## Tutorial slides

All the tutorial slide decks can be found in the `tutorials` directory.  Many
of these are prepared using
[Hieroglyph](http://docs.hieroglyph.io/en/latest/#) a derivative of .  Being
based on [reStructuredText](http://docutils.sourceforge.net/rst.html) the
content is plain text, making it easy to transfer to other formats.

Each tutorial slide deck has its own directory.

All slide decks are provided under a
[Creative Commons Attribution-ShareAlike 4.0](https://creativecommons.org/licenses/by-sa/4.0/legalcode)
license, so you are free to share and modify the slides, so long as you
attribute the original authors and give the same rights to others.

### Using Hieroglyph

There are guidelines online for setting up hieroglyph.  I used version 0.7.1
on top of Sphinx 1.4.1 (there can be an issue with newer versions).  With this
installed, each set of slides can be built from the individual tutorial
directory by running
```
make slides
```
The slides will be found as HTML in the build/slides directory. Just open
`index.html` in your browser.

## Tutorial code

The tutorial code is in individual directories within the `basic_verilog`
directory.

### basic_verilog

The files are mostly empty, you shall be guided through filling these out.

### cheat_sheet

Corresponds to the basic_verilog files, if you get stuck.

### pretty_colours

A full project, with a chip.bin, so that you can test your installation of the
tools

## Prerequisites

To install everything you need follow the guides on chiphack.org:
 - [Linux](http://chiphack.org/chiphack-2017-install-linux.html)
 - [macOS](http://chiphack.org/chiphack-2017-install-mac.html)
 - [Windows](http://chiphack.org/chiphack-2017-install-windows.html)

## To compile programs

### Linux

Simply run `make` for the basic led example, for others run make followed by
the project name, e.g. `make blink`

### macOS

You will need to change the makefile, by commenting out the linux lines and
uncommenting the mac lines, then as above.

### Windows

You will need to copy the blackice.pcf into the folder you want to compile,
then run `apio build --size 8k --type hx --pack tq144:4k`

## To upload programs

Connect to the middle USB port.

### Linux

Once having compiled and got your chip.bin, run `cat /dev/ttyACM0` in one terminal, and in another terminal run `cat chip.bin >/dev/ttyACM0`

### macOS

Once having compiled and got your chip.bin, run `cat /dev/usbmodem1421` in one terminal, and in another terminal run `cat chip.bin >/dev/cu.usbmodem1421`.

note you may have to change `usbmodem1421` to the appropriate port.

### Windows

You will need to connect to the board using tera term. Select the serial
option, then go to setup>serial. Delete the Baud rate option, set data as 8
bit, no parity, 1 bit stop and no flow control.

Then file>send file navigate to hardware.bin , tick the Binary option box and
open.
