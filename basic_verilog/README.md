# The basic Verilog examples

# Overview

In each folder there is a `chip.v` file which you should not need to touch.

The other Verilog files (ending in `.v`) are provided as templates for you to
modify as an exercies. If you become truly stuck a cheat sheet is available in
the `cheat_sheet` directory.

# Synthesizing the design

To compile the Verilog to a bitstream:
```
make <project_name>
```
where `<project_name>` is the name of the project.

To upload the bitstream to the board:
```
make upload
```
**Caveat** You may need to change `SERIAL` inside the `Makefile` to the USB
port your system is using.

## Cleaning up

Declutter the folder with:
```
make clean
```
