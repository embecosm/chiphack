# [Chip Hack](http://www.chiphack.org)

This repository (and its companion
[wiki](https://github.com/embecosm/chiphack/wiki)) contains tutorial code and
documentation for the [Chip Hack](http://www.chiphack.org) events.  Most
recently the ChipHack/EDSAC Challenge, held in Hebden Bridge from the 6th to
the 8th of September 2017.

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

The tutorial code is in individual subdirectories within the `basic_verilog`
and `cheat_sheet` directories, with one sub-directory for each exercise.
directory.

### basic_verilog

The files are mostly empty, for you to complete.

### cheat_sheet

Full solutionns corresponding to the basic_verilog files, if you get stuck.

### pretty_colours

A full project, with a chip.bin, so that you can test your installation of the
tools

## Prerequisites

To install everything you need follow the guides on chiphack.org:
 - [Linux](http://chiphack.org/chiphack-2017-install-linux.html)
 - [macOS](http://chiphack.org/chiphack-2017-install-mac.html)
 - [Windows](http://chiphack.org/chiphack-2017-install-windows.html)

## To compile and upload programs

Full guidance is provided in the setup presentation
([HTML](http://chiphack.org/talks/mystorm-setup/html/index.html),
[slides](http://chiphack.org/talks/mystorm-setup/slides/index.html))
