PreRequisites
...

The chip.v file does not need to be altered but you need to write a bit of logic in the other verilog folders, if you become truly stuck a cheat sheet is available.

To compile:
  - for the LED project run 'make'
  - else run 'make' followed by the name of the project, e.g. for blink run 'make blink'

To Program the board:
  - Inside the makefile you may need to the change SERIAL to the port on your system
  - Then simply run make upload

'make clean' will declutter the folder for you.
