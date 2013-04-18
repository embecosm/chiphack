/*

A basic module / template for the DE0-Nano board

*/

`define COUNTER_SIZE 32 // 32 bits
`define SLOW_CLK_BIT 16 // 16th bit

//// for simulation
//`define COUNTER_SIZE 8 // 32 bits
//`define SLOW_CLK_BIT 2 // 16th bit


module basics(
  //////////// CLOCK //////////
  input 		          		CLOCK_50,
  //////////// LED //////////
  output		     [7:0]		LED,
  //////////// KEY //////////
  input 		     [1:0]		KEY,
  //////////// SW //////////
  input 		     [3:0]		SW,
  //////////// SDRAM //////////
  output		    [12:0]		DRAM_ADDR,
  output		     [1:0]		DRAM_BA,
  output		          		DRAM_CAS_N,
  output		          		DRAM_CKE,
  output		          		DRAM_CLK,
  output		          		DRAM_CS_N,
  inout 		    [15:0]		DRAM_DQ,
  output		     [1:0]		DRAM_DQM,
  output		          		DRAM_RAS_N,
  output		          		DRAM_WE_N,
  //////////// EPCS //////////
  output		          		EPCS_ASDO,
  input 		          		EPCS_DATA0,
  output		          		EPCS_DCLK,
  output		          		EPCS_NCSO,
  //////////// Accelerometer and EEPROM //////////
  output		          		G_SENSOR_CS_N,
  input 		          		G_SENSOR_INT,
  output		          		I2C_SCLK,
  inout 		          		I2C_SDAT,
  //////////// ADC //////////
  output		          		ADC_CS_N,
  output		          		ADC_SADDR,
  output		          		ADC_SCLK,
  input 		          		ADC_SDAT,
  //////////// 2x13 GPIO Header //////////
  inout 		    [12:0]		GPIO_2,
  input 		     [2:0]		GPIO_2_IN
);


  /*
  Register instantiation
  */
  reg  [`COUNTER_SIZE-1:00] count;

  /*
  Wire instantiation
  */
  wire [07:00] led_out;
  wire         button_ed;
  
  // assign the most significant bit of the counter to be
  // the LED clock; this will produce a much slower clock
  // ~400 ms high time
  assign slow_clock = count[`SLOW_CLK_BIT-1];
  //assign slow_clock = count[15];

  // assign meaningful names to pushbutton keys
  assign reset = ~KEY[0];
  assign button = ~KEY[1];

  // connect the edge detect signal to an LED
  assign led_out = {count[`COUNTER_SIZE-1:`COUNTER_SIZE-8]};
  assign LED[0] = button_ed;
  assign LED[1] = button;
  assign LED[07:02] = led_out[07:02];

  // instantiate an edge detect module
  edge_detect ed_0 (.CLK(slow_clock), 
                    .RST(reset), 
						  .IN(button), 
						  .OUT(button_ed));
  
  // simple counter to divide up the clock in order
  // to create a slower frequency clock
  always @(posedge CLOCK_50) begin
    if (reset == 1'b1) begin
      count <= 0;
    end
    else begin
      count <= count + 1;
      /* all the following statements are equivalent to the above:
      count[15:00] <= count[15:0] + 1;
      count <= count + 1'b1;
      count <= count + 16'b0000000000000001;
      count[15:0] <= count + 16'h0001
      */
    end
  end

endmodule


// edge detect module
module edge_detect(
  input  CLK,
  input  RST,
  input  IN, 
  output OUT
);

  reg a, b;

  // the edge detect signal is (b AND (NOT a))
  assign OUT = a & !b;

  always @(posedge CLK) begin
    // it's always good to have a reset condition, otherwise
    // the state of the register will show up as undertemined
    // in simulation ('x')
    if (RST == 1'b1) begin
      a <= 0;
      b <= 0;
	 end
	 else begin
      a <= IN;
      b <= a;	 
	 end
  end

endmodule
