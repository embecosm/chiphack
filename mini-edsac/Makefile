V = mini.v uartrx.v uarttx.v CPU.v
CFLAGS = -Wall

all:	mini.bin miniserve

mini.blif:  $(V)
#	yosys -p "synth_ice40 -blif mini.blif" $(V) >yosys.log 2>&1
	yosys -s script >yosys.log 2>&1

mini.txt:	mini.blif blackice.pcf
	arachne-pnr -d 8k -P tq144:4k -p blackice.pcf mini.blif -o mini.txt >arachne.log 2>&1

mini.bin:	mini.txt
	icepack mini.txt mini.bin

miniserve:	miniserve.o
	$(CC) $(CFLAGS) -o miniserve miniserve.o -lpthread

clean:	
	rm -f yosys.log arachne.log mini.blif mini.txt mini.bin miniserve.o miniserve
	rm -f *~

