`define M 100

module uart_tb();

// inputs to module are registers
reg         CLK;
reg         reset;
reg         button;

// outputs from module are wires
wire [07:00] leds;
wire      uart_tx;

initial begin
  // initialise inputs to module
  CLK = 0;
  reset = 1;
  button = 1;  
end

// create a clock - 50MHz
always
  #10 CLK = !CLK;

uart uart_0 (
//////////// CLOCK //////////
  .CLOCK_50(CLK), //input
//////////// LED //////////
  .LED(leds[07:00]), // 8 bit output
//////////// KEY //////////
  .KEY({button, reset}), // 2 bit input
//////////// SW //////////
  .SW(4'b0000),  // 4 bit input
//////////// UART TX //////////
  .UART_TX(uart_tx)
);

   reg through_once = 0;
   
   
initial begin

`ifdef VCD
   $dumpfile("waves.vcd");
   $dumpvars(0);
`endif
   
  #100
  #(10*`M) reset = 0;
  #(20*`M) reset = 1;
   
   #(20*`M) ;

   // Simulate button-push   
   #(30*`M) button = 0;
   #(70*`M) button = 1;

   while(1)
     begin
	@(posedge uart_decoder0.waiting_for_start_bit)
	  begin
	     // Simulate button-push   
	     #(30*`M) button = 0;
	     #(70*`M) button = 1;

	     if (uart_decoder0.tx_byte==8'h30)
	       begin
		  if (!through_once)
		    through_once = 1;
		  else
		    $finish();
	       end

	  end
     end
end
   
   uart_decoder uart_decoder0(CLK, uart_tx);
   
endmodule


module uart_decoder(clk, uart_tx);

   input clk;   
   input uart_tx;

   // Default baud of 115200, period (ns)
   parameter uart_baudrate_period_ns = 8680; 

   reg 	 waiting_for_start_bit = 0;
   
   reg [7:0] tx_byte;
   
   // Something to trigger the task
   always @(posedge clk)
     uart_decoder;
   
   task uart_decoder;
      begin
	 while (uart_tx !== 1'b1)
	   @(uart_tx);
	 // Wait for start bit
	 waiting_for_start_bit = 1;
	 
	 while (uart_tx !== 1'b0)
           @(uart_tx);
	 waiting_for_start_bit = 0;
	 #(uart_baudrate_period_ns+(uart_baudrate_period_ns/2));
	 tx_byte[0] = uart_tx;
	 #uart_baudrate_period_ns;
	 tx_byte[1] = uart_tx;
	 #uart_baudrate_period_ns;
	 tx_byte[2] = uart_tx;
	 #uart_baudrate_period_ns;
	 tx_byte[3] = uart_tx;
	 #uart_baudrate_period_ns;
	 tx_byte[4] = uart_tx;
	 #uart_baudrate_period_ns;
	 tx_byte[5] = uart_tx;
	 #uart_baudrate_period_ns;
	 tx_byte[6] = uart_tx;
	 #uart_baudrate_period_ns;
	 tx_byte[7] = uart_tx;
	 #uart_baudrate_period_ns;
	 //Check for stop bit
	 if (uart_tx !== 1'b1)
	   begin
	      // Wait for return to idle
	      while (uart_tx !== 1'b1)
		@(uart_tx);
	   end
	 // display the char
	 $display("%t %c (0x%h)",$time,tx_byte, tx_byte);
      end
   endtask // user_uart_read_byte

endmodule // uart_decoder
