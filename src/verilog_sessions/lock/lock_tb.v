module edge_detect_tb();

// inputs to module are registers
reg         CLK;
reg [01:00] keys;
reg [03:00] switches;

// outputs from module are wires
wire [07:00] leds;

initial begin
  // initialise inputs to module
  CLK = 0;
  switches = 0;
  keys = 0;  
end

// create a clock
always
  #1 CLK = !CLK;

edge_detect ed_0 (
//////////// CLOCK //////////
  .CLOCK_50(CLK), //input
//////////// LED //////////
  .LED(leds[07:00]), // 8 bit output
//////////// KEY //////////
  .KEY(keys[01:00]), // 2 bit input
//////////// SW //////////
  .SW(switches[03:00]),  // 4 bit input
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

  #100 keys[0] = 1;
  #200 keys[0] = 0;
  
  #300 keys[1] = 1;
  #300 keys[1] = 0;

end


endmodule
