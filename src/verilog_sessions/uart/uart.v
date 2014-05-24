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

  output reg                                    UART_TX,
  output                                        UART_GND
);

   // Some register and wire declarations
   reg [3:0] transmit_state;
   reg [7:0] transmit_data;
   reg 	     key1_reg;
   wire      key1_edge_detect;
   
   // Reset
   wire 					reset;
   assign reset = ~KEY[0];

   // Tie UART_GND low
   assign UART_GND = 0;
   
   //UART transmit at 115200 baud from 50MHz clock
   reg [9:0] 					clock_divider_counter;
   reg 						uart_clock;


   // Clock counter
   /*
    What must this counter to do allow us to generate
    a 115.2kHz clock down below?
    */   
   always @(posedge CLOCK_50) 
     begin
	if (reset == 1'b1)
	  clock_divider_counter <= 0;
	else if (/* FILL ME IN - what conditiono will make us 
		                 reset this counter? */)
	  clock_divider_counter <= 0;
	else
	  // Otherwise increment the counter
	  clock_divider_counter <= clock_divider_counter + 1;
     end

   // Generate a clock (toggle this register)
   always @(posedge CLOCK_50) 
     begin
	if (reset == 1'b1)
	  uart_clock <= 0;
	else if (/* FILL ME IN - what conditiono will make us 
		                 toggle the clock?
		    (hint: the same as the above counter condition) */)
	  uart_clock <= ~uart_clock;
     end
   
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
	     
	     // What follows is the skeleton of the state machine to control
	     // the bits going onto the UART transmit line.
	     // You will want to, from the idle state:
	     // 1. detect the pushbutton press and go to the the start bit state
	     // 2. then the 8 data bits (LSB first)
	     // 3. finally the stop bit
	     // 4. return to this state ready for the next transmit
	     case (transmit_state)
	       0:
		 begin
		    // Idle state - We want to transition to the start bit state
		    //              when the pushbutton is pressed. (A signal
		    //              detecting this is provided - "key1_edge_detect".)
		 end
	       1:
		 begin
		    // Start bit state, and progress onto the next state
		    /* Fill me in - assign UART_TX here */
		 end
	       2,3,4,5,6,7,8,9:
		 begin
		    // Data bits
		    // when transmit_state is 2 we want transmit_data[0]
		    // when transmit_state is 3 we want transmit_data[1]
		    // ...
		    // when transmit_state is 9 we want transmit_data[7]
		    /* Fill me - assign appropriate data bit to UART_TX here
		               - don't forget to continue incrementing the
		                 state
		     */
		 end
	       10:
		 begin
		    // Stop bit, and transition back to idle (0)
		    /* Fill me in - drive the final bit onto UART_TX.
		                  - also make sure the transmit_data
		                    changes so we see something different 
		                    next time */
		 end
	       default:
		 // Shouldn't reach here, but just incase, go back to idle!
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
