//  mini.v
// driver for mini-Edsac simulation
//
// Loosely based on the Lattice code for the IrDA programs
//
module mini (
            input clk_in,
            input RX , 
            output TX,
            output [11:0] leds,
            input BUT0
         );

         // Divide the 100MHz clock by 8 to get a 12.5Mhz clock.
   reg [2:0] clock_div = 2'd0;
   always @ (posedge clk_in)
      clock_div <= clock_div + 2'd1;
   wire clock;
   assign clock = ~clock_div[2];

// parameters (constants)
   reg [15:0] reset_ct = 0;
   // Clock divisor based on a 12.5Mhz clock generated above.
   // Make sure to use a 230400 buad rate with miniserve.
   parameter CLKDIV = (12_500_000) / 230400;

   reg rst_n = 0;
   reg i_rst = 1;

   always @ (posedge clk_in)
   begin
      reset_ct <= reset_ct + 16'd1;
      if (reset_ct[7])
         i_rst <= 1'b0;
   end /* reset counting */

wire [7:0]  rx_data       ; 
wire        rx_strobe     ;

wire [7:0]  tx_data       ;
wire        tx_start      ;
wire        tx_busy       ;

// UART instantiation
uartrx #(.CLKDIV(CLKDIV)) urx (                   
      .clk    ( clock    ),
      .rst    ( i_rst     ),
      .rx     ( RX        ), // signal from PC
      .q      ( rx_data   ), // byte of data from PC
      .strobe ( rx_strobe ),   // true briefly when data has arrived
      .leds   ( leds[11:8])    // debug output
   );

uarttx #(.CLKDIV(CLKDIV)) utx (                   
      .clk    ( clock    ),
      .rst    ( i_rst     ),
      .tx     ( TX        ), // signal to PC
      .d      ( tx_data   ), // data to the PC
      .strobe ( tx_start  ), // trigger send
      .busy   ( tx_busy   ), // tx data in transit
      .leds   ( leds[7:6] )
    );

// CPU instatiation
CPU cpu1 (
	  .clock(clock),
	  .reset(i_rst),
	  .rx_data_in(rx_data),
	  .rx_strobe(rx_strobe),
	  .tx_data(tx_data),
	  .tx_start(tx_start),
	  .tx_busy(tx_busy),
	  .leds(leds[5:0]),
	  .but0(BUT0)
	  );

endmodule





