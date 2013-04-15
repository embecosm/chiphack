/*

A combination lock

4 bit combination digits are entered by setting the 4 bit 
switch and pressing KEY1. If four correct digits are entered
in sequence, the lock opens. 

But this design has a serious security flaw! Can you find 
what it is and fix it?

*/


module lock(

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

// states
parameter LOCKED=3'b000, OK1=3'b001, OK2=3'b010, 
          OK3=3'b011, OK4=3'b100, OPEN=3'b111;

// the lock's combination
parameter COMBO={4'b1000, 4'b0100, 4'b0010, 4'b0001};

reg  [02:00] state;
reg  [15:00] count;
reg  [03:00] last_input;

assign reset = !KEY[0];
assign pb = KEY[1];
assign slow_clock = count[15];
assign LED[03:00] = last_input;
assign LED[06:04] = state;
assign LED[07] = pb_ed;

// instantiate an edge detect module
edge_detect ed_0 (.CLK(slow_clock), .IN(pb), .OUT(pb_ed));

// divide the clock
always @(posedge CLOCK_50) begin
  count <= count + 1;
end 

// output the last digit entered
always @(posedge CLOCK_50) begin
  if (reset == 1'b1) begin
    last_input <= 0;
  if (pb_ed == 1'b1)
    last_input <= SW;
end

// state machine
always @(posedge slow_clock) begin
  if (reset == 1'b1) begin
    state <= LOCKED;
  end
  else begin 
    if (pb_ed == 1'b1) begin
      case (state)
        LOCKED: begin
		            if (SW == COMBO[OK1*4-1:OK1*4-4]) begin
 					     state <= OK1;
						end
                end

 		  OK1:  begin
		          if (SW == COMBO[OK2*4-1:OK2*4-4]) begin
					   state <= OK2;
					 end	
                else
				      state <= LOCKED;
   		     end

		  OK2:  begin
		          if (SW == COMBO[OK3*4-1:OK3*4-4]) begin
					   state <= OK3;
					 end
                else
				      state <= LOCKED;
  		        end

		  OK3:  begin
		          if (SW == COMBO[OK4*4-1:OK4*4-4]) begin
					   state <= OPEN;
					 end	
                else
				      state <= LOCKED;
		        end

		  OPEN: begin
	           end

		  default: begin
		             state <= LOCKED;
		           end  
      endcase
	 end	
  end
end

endmodule


// edge detect module
module edge_detect(
  input  CLK, 
  input  IN, 
  output OUT
);

  reg a, b;

  assign OUT = b & !a;

  always @(posedge CLK) begin
    a <= IN;
    b <= a;
  end
  
endmodule
