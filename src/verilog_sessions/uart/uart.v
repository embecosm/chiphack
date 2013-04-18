/*

 UART transmitter for DE0 Nano
 
 */

module uart(
  //////////// CLOCK //////////
  input 		          		CLOCK_50,
  //////////// LED //////////
  output		     [7:0]		LED,
  //////////// KEY //////////
  input 		     [1:0]		KEY,
  //////////// SW //////////
  input 		     [3:0]		SW,

  output                                        UART_TX,
  output                                        UART_VCC
);

   // Reset
   wire 					reset;
   assign reset = ~KEY[0];

   // Tie UART_VCC high - it's used to drive the buffer on the UART board
   assign UART_VCC = 1;
   
   //UART transmit at 115200 baud from 50MHz clock
   reg [7:0] 					clock_divider_counter;
   reg 						uart_clock;


   // Clock counter
   always @(posedge CLOCK_50) 
     begin
	if (reset == 1'b1)
	  clock_divider_counter <= 0;
	else
	  ;
	/*
	 What must this counter to do allow us to generate
	 a 115.2kHz clock down below?
	 */
	
     end

   // Generate a clock (toggle this register)
   always @(posedge CLOCK_50) 
     begin
	if (reset == 1'b1)
	  uart_clock <= 0;
	else if (/*What condition here to make the clock toggle? */)
	  uart_clock <= ~uart_clock;
     end
   
   reg [3:0] transmit_state;
   reg [7:0] transmit_data;
   reg 	     UART_TX;
   reg 	     key1_reg;
   wire      key1_edge_detect;

   always @(posedge uart_clock or posedge reset)
     begin
	if (reset)
	  begin
	     // Reset to the "IDLE" state
	     transmit_state <= 0;

	     // The UART line is set to '1' when idle, or reset
	     UART_TX <= 1;

	     // Data we'll transmit - start at ASCII '0'
	     transmit_data <= 8'h30;
	     
	  end
	else
	  begin
	     case (transmit_state)
	       0:
		 begin
		    // Idle state - what do we do to first send:
		    // 1. the start bit
		    // 2. the 8 data bits (LSB first)
		    // 3. the stop bit
		    // 4. return to this state ready for the next transmit
		 end 
	       default:
		 // Shouldn't reach here, but just incase!
		 transmit_state <= 0;
	     endcase
	  end
     end

   // Sample the pushbutton
   always @(posedge uart_clock)
     key1_reg <= KEY[1];

   // Detect the change in level
   assign key1_edge_detect = ~KEY[1] & key1_reg;

   // Output the transmit data on the LEDs
   assign LED = transmit_data;

   
endmodule
