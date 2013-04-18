# Makefile for compiling this design with Icarus Verilog

run: uart.sim
	vvp uart.sim

uart.sim: uart_tb.v uart.v
	iverilog $^ -D VCD -o $@

clean:
	rm -f uart.sim waves.vcd *~
