# Makefile for compiling this design with Icarus Verilog
# Also for building FPGA image with Quartus

DESIGN_NAME=uart
run: uart.sim
	vvp uart.sim

uart.sim: uart_tb.v uart.v
	iverilog $^ -D VCD -o $@


pgm: output_files/$(DESIGN_NAME).sof
	quartus_pgm --mode=jtag -o p\;output_files/$(DESIGN_NAME).sof

sta: asm
	quartus_sta $(DESIGN_NAME)

build: output_files/$(DESIGN_NAME).sof

output_files/$(DESIGN_NAME).sof: output_files/$(DESIGN_NAME).fit.rpt
	quartus_asm $(DESIGN_NAME)

output_files/$(DESIGN_NAME).fit.rpt: output_files/$(DESIGN_NAME).map.rpt
	quartus_fit $(DESIGN_NAME)

output_files/$(DESIGN_NAME).map.rpt: uart.qpf
	quartus_map $(DESIGN_NAME)

uart.qpf: uart.tcl uart.v
	quartus_sh -t uart.tcl


clean:
	rm -rf uart.sim waves.vcd *~ db output_files



