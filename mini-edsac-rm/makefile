# before running "make test", start "make input" in another window
# to receive input

all: chip.bin

chip.blif: top.v cpu.v mem.v uarttx.v uartrx.v led64.v
	yosys -q -p "synth_ice40 -blif chip.blif" $^ 

chip.bin: chip.blif blackice.pcf
	arachne-pnr -d 8k -P tq144:4k -p blackice.pcf chip.blif -o chip.txt
	icepack chip.txt chip.bin

dfu:	chip.bin
	dfu-util -d 0483:df11 -a 0 -s 1 -D chip.bin -t 1024

upload: chip.bin
	cat chip.bin >/dev/ttyACM0

clean:
	$(RM) -f chip.blif chip.txt chip.bin

test: upload
	cp squares.txt /dev/ttyUSB0

input:
	(stty 9600; cat) </dev/ttyUSB0
