`define M 100

module basics_tb();

// inputs to module are registers
reg         CLK;
reg         reset;
reg         button;

// outputs from module are wires
wire [07:00] leds;

initial begin
  // initialise inputs to module
  CLK = 0;
  reset = 1;
  button = 1;  
end

// create a clock
always
  #5 CLK = !CLK;

basics basics_0 (
//////////// CLOCK //////////
  .CLOCK_50(CLK), //input
//////////// LED //////////
  .LED(leds[07:00]), // 8 bit output
//////////// KEY //////////
  .KEY({button, reset}), // 2 bit input
//////////// SW //////////
  .SW(4'b0000),  // 4 bit input
//////////// SDRAM //////////
  .DRAM_ADDR(), // 13 bit 
  .DRAM_BA(),  // 2 bit
  .DRAM_CAS_N(),
  .DRAM_CKE(),
  .DRAM_CLK(),
  .DRAM_CS_N(),
  .DRAM_DQ(),  // 16 bit inout
  .DRAM_DQM(), // 2 bit
  .DRAM_RAS_N(),
  .DRAM_WE_N(),
//////////// EPCS //////////
  .EPCS_ASDO(),
  .EPCS_DATA0(1'b0), //input
  .EPCS_DCLK(),
  .EPCS_NCSO(),
//////////// Accelerometer and EEPROM //////////
  .G_SENSOR_CS_N(), 
  .G_SENSOR_INT(1'b0), //input
  .I2C_SCLK(),
  .I2C_SDAT(),  // inout
//////////// ADC //////////
  .ADC_CS_N(),
  .ADC_SADDR(),
  .ADC_SCLK(),
  .ADC_SDAT(1'b0), //input
//////////// 2x13 GPIO Header //////////
  .GPIO_2(),    // 13 bit inout
  .GPIO_2_IN(3'b000)  // 3 bit input
);

initial begin

  #100
  #(10*`M) reset = 0;
  #(20*`M) reset = 1;
  
  #(30*`M) button = 0;
  #(70*`M) button = 1;

end


endmodule
