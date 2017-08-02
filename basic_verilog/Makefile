###############################################################################
#                                                                             #
# Copyright 2016 myStorm Copyright and related                                #
# rights are licensed under the Solderpad Hardware License, Version 0.51      #
# (the “License”); you may not use this file except in compliance with        #
# the License. You may obtain a copy of the License at                        #
# http://solderpad.org/licenses/SHL-0.51. Unless required by applicable       #
# law or agreed to in writing, software, hardware and materials               #
# distributed under this License is distributed on an “AS IS” BASIS,          #
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or             #
# implied. See the License for the specific language governing                #
# permissions and limitations under the License.                              #
#                                                                             #
###############################################################################

# Default name of serial adaptor if none is provided by the user
#SERIAL := /dev/cu.usbmodem1421 # For macOS (maybe)
SERIAL := /dev/ttyACM0 # The default for linux (usually)

# Leave as the basic make, so that people can initially get something running
chip.bin: ./led/chip.v ./led/led.v blackice.pcf
	yosys -q -p "synth_ice40 -blif chip.blif" ./led/chip.v ./led/led.v
	arachne-pnr -d 8k -P tq144:4k -p blackice.pcf chip.blif -o chip.txt
	icepack chip.txt chip.bin

.PHONY: button
button: ./button/chip.v ./button/button.v blackice.pcf
		yosys -q -p "synth_ice40 -blif chip.blif" ./button/chip.v ./button/button.v
		arachne-pnr -d 8k -P tq144:4k -p blackice.pcf chip.blif -o chip.txt
		icepack chip.txt chip.bin

.PHONY: fibonacci
fibonacci: ./fibonacci/chip.v ./fibonacci/fibonacci.v blackice.pcf
		yosys -q -p "synth_ice40 -blif chip.blif" ./fibonacci/chip.v ./fibonacci/fibonacci.v
		arachne-pnr -d 8k -P tq144:4k -p blackice.pcf chip.blif -o chip.txt
		icepack chip.txt chip.bin

.PHONY: button_ed
button_ed: ./button_edge_detect/chip.v ./button_edge_detect/button_ed.v ./button_edge_detect/edge_detect.v blackice.pcf
		yosys -q -p "synth_ice40 -blif chip.blif" ./button_edge_detect/chip.v ./button_edge_detect/button_ed.v ./button_edge_detect/edge_detect.v
		arachne-pnr -d 8k -P tq144:4k -p blackice.pcf chip.blif -o chip.txt
		icepack chip.txt chip.bin

.PHONY: blink
blink: ./blink/chip.v ./blink/blink.v blackice.pcf
		yosys -q -p "synth_ice40 -blif chip.blif" ./blink/chip.v ./blink/blink.v
		arachne-pnr -d 8k -P tq144:4k -p blackice.pcf chip.blif -o chip.txt
		icepack chip.txt chip.bin

.PHONY: lock
lock: ./lock/chip.v ./lock/lock.v ./lock/edge_detect.v blackice.pcf
		yosys -q -p "synth_ice40 -blif chip.blif" ./lock/chip.v ./lock/lock.v ./lock/edge_detect.v
		arachne-pnr -d 8k -P tq144:4k -p blackice.pcf chip.blif -o chip.txt
		icepack chip.txt chip.bin

.PHONY: uart
uart: ./uart/chip.v ./uart/uart.v ./uart/edge_detect.v blackice.pcf
		yosys -q -p "synth_ice40 -blif chip.blif" ./uart/chip.v ./uart/uart.v ./uart/edge_detect.v
		arachne-pnr -d 8k -P tq144:4k -p blackice.pcf chip.blif -o chip.txt
		icepack chip.txt chip.bin

.PHONY: uart_reciever
uart_reciever: ./uart_reciever/chip.v ./uart_reciever/uart.v ./uart_reciever/edge_detect.v blackice_uart.pcf
		yosys -q -p "synth_ice40 -blif chip.blif" ./uart_reciever/chip.v ./uart_reciever/uart.v ./uart_reciever/edge_detect.v
		arachne-pnr -d 8k -P tq144:4k -p blackice_uart.pcf chip.blif -o chip.txt
		icepack chip.txt chip.bin


# Upload to a mac, may have to change name of the port accordingly
.PHONY: upload
upload:
#	stty -f $(SERIAL) raw & cat chip.bin >$(SERIAL) # for macOS
	stty -F $(SERIAL) raw & cat chip.bin >$(SERIAL) # for linux

.PHONY: clean
clean:
	$(RM) -f chip.blif chip.txt chip.ex chip.bin

#Based of the oringinal makefile from the blackice tutorial (gitlab.com/Folknology/mystorm/tree/BlackIce/tutorial/BlackIce), with additions by Dan Gorringe
