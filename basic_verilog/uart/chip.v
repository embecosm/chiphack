/******************************************************************************
*                                                                             *
* Copyright 2016 myStorm Copyright and related                                *
* rights are licensed under the Solderpad Hardware License, Version 0.51      *
* (the “License”); you may not use this file except in compliance with        *
* the License. You may obtain a copy of the License at                        *
* http://solderpad.org/licenses/SHL-0.51. Unless required by applicable       *
* law or agreed to in writing, software, hardware and materials               *
* distributed under this License is distributed on an “AS IS” BASIS,          *
* WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or             *
* implied. See the License for the specific language governing                *
* permissions and limitations under the License.                              *
*                                                                             *
******************************************************************************/

module chip (
    // 100MHz clock input
    input  clk,
    // SRAM Memory lines
    output [18:0] ADR,
    output [15:0] DAT,
    output RAMOE,
    output RAMWE,
    output RAMCS,
    // All PMOD outputs
    output [55:0] PMOD,
    input [1:0] BUT
  );

  // SRAM signals are not use in this design, lets set them to default values
  assign ADR[18:0] = {19{1'b0}};
  assign DAT[15:0] = {16{1'b0}};
  assign RAMOE = 1'b1;
  assign RAMWE = 1'b1;
  assign RAMCS = 1'b1;

  assign PMOD[49:0] = {49{1'b0}};

  wire OUT;

  wire enter_ed;
  wire next_ed;

  //UART(/slow) clock
  // We need to create a slow clokc for the uart to communicate over
  // We will be creating and then using a 115200 baud clock

  reg [9:0] clock_divider_counter;
  reg uart_clock;

  // The current clock is 100MHz
  // to get the divider counter we need to take the current clock and divide by twice the clock rate desired
  // e.g. 50x10^6/115200 = 434
  always @(posedge clk) begin
    if (next_ed == 1) begin
      counter <= counter + 1;
    end
   	if (reset == 1'b1)
   	  clock_divider_counter <= 0;
   	else if (clock_divider_counter == 434)
   	  clock_divider_counter <= 0;
   	else
   	  // Otherwise increment the counter
   	  clock_divider_counter <= clock_divider_counter + 1;
  end

    // Generate a clock (toggle this register)
  always @(posedge clk) begin
 	  if (reset == 1'b1)
 	    uart_clock <= 0;
 	  else if (clock_divider_counter == 434)
 	    uart_clock <= ~uart_clock;
    end
// UART ports!
  // You can assign two PMODs to be the UART_GND and UART_TX as both are outputs

  uart my_uart (
      // Here you need to put the inputs and outputs
      // Including the clock
      // the UART wires
      // and the button inputs
  );

  // ensure both modules are running using the same clock
  edge_detect next_edge_detect (
    // Here go the usual inputs for the edge detect.s
  );

endmodule
