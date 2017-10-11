VB = uartrx.v uarttx.v BRAM.v
VS = uartrx.v uarttx.v SRAM.v

CFLAGS = -Wall -g

all:	
	@echo "Please use 'make mini', 'make minib', 'make minis' or 'make minisb' to build a binary"
	@echo "other commands are:"
	@echo "    make clean    (removes all non-essential files)"
	@echo "    make upload   (upload mini to blackice)"
	@echo "    make uploadb  (upload minib to blackice)"
	@echo "    make uploads  (upload minis to blackice)"
	@echo "    make uploadsb (upload minisb to blackice)"
	@echo " "

mini:	mini.bin

minib:	minib.bin

minis:	minis.bin

minisb: minisb.bin

mini.blif:  $(VB) mini.v CPU.v
	yosys -q  -p "read_verilog mini.v CPU.v" -p "synth_ice40 -blif mini.blif" $(VB)

mini.txt:	mini.blif blackice.pcf
	arachne-pnr -d 8k -P tq144:4k -p blackice.pcf mini.blif -o mini.txt

mini.bin:	mini.txt
	icepack mini.txt mini.bin

minib.blif:  $(VB) mini.v CPU.v
	yosys -q -p "read_verilog -DBline mini.v CPU.v" -p "synth_ice40 -blif minib.blif" $(VB)

minib.txt:	minib.blif blackice.pcf
	arachne-pnr -d 8k -P tq144:4k -p blackice.pcf minib.blif -o minib.txt

minib.bin:	minib.txt
	icepack minib.txt minib.bin

minis.blif:  $(VS) mini.v CPU.v
	yosys -q  -p "read_verilog -DSRAM mini.v CPU.v" -p "synth_ice40 -blif minis.blif" $(VS)

minis.txt:	minis.blif blackice.pcf
	arachne-pnr -d 8k -P tq144:4k -p blackice.pcf minis.blif -o minis.txt

minis.bin:	minis.txt
	icepack minis.txt minis.bin

minisb.blif:  $(VS) mini.v CPU.v
	yosys -q -p "read_verilog -DBline -DSRAM mini.v CPU.v" -p "synth_ice40 -blif minisb.blif" $(VS)

minisb.txt:	minisb.blif blackice.pcf
	arachne-pnr -d 8k -P tq144:4k -p blackice.pcf minisb.blif -o minisb.txt

minisb.bin:	minisb.txt
	icepack minisb.txt minisb.bin

clean:
	rm -f yosys.log arachne.log mini.blif mini.txt mini.bin miniserve.o miniserve
	rm -f *~ minib.* minis.* minisb.*

upload: mini.bin
	cat /dev/ttyACM0 > boot.log 2>&1 &
	stty -F /dev/ttyACM0 raw
	cat mini.bin > /dev/ttyACM0
	ps x | grep ttyACM | head -1 | \
	       sed -e 's/\([[:digit:]]*\) .*$$/now run kill \1/'

uploadb:	minib.bin
	cat /dev/ttyACM0 > boot.log 2>&1 &
	stty -F /dev/ttyACM0 raw
	cat minib.bin > /dev/ttyACM0
	ps x | grep ttyACM | head -1 | \
	       sed -e 's/\([[:digit:]]*\) .*$$/now run "kill \1"/'

uploads: minis.bin
	cat /dev/ttyACM0 > boot.log 2>&1 &
	stty -F /dev/ttyACM0 raw
	cat minis.bin > /dev/ttyACM0
	ps x | grep ttyACM | head -1 | \
	       sed -e 's/\([[:digit:]]*\) .*$$/now run kill \1/'

uploadsb:	minisb.bin
	cat /dev/ttyACM0 > boot.log 2>&1 &
	stty -F /dev/ttyACM0 raw
	cat minisb.bin > /dev/ttyACM0
	ps x | grep ttyACM | head -1 | \
	       sed -e 's/\([[:digit:]]*\) .*$$/now run "kill \1"/'

