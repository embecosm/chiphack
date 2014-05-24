#============================================================
# Build by Terasic System Builder
#============================================================
project_new uart -overwrite

set_global_assignment -name FAMILY "Cyclone IV E"
set_global_assignment -name DEVICE EP4CE22F17C6
set_global_assignment -name TOP_LEVEL_ENTITY "uart"
set_global_assignment -name ORIGINAL_QUARTUS_VERSION 12.0
set_global_assignment -name LAST_QUARTUS_VERSION "12.1 SP1"
set_global_assignment -name PROJECT_CREATION_TIME_DATE "00:59:20 APRIL 08,2013"
set_global_assignment -name SDC_FILE uart.SDC
set_global_assignment -name CYCLONEII_RESERVE_NCEO_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_FLASH_NCE_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DATA0_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DATA1_AFTER_CONFIGURATION "USE AS REGULAR IO"
set_global_assignment -name RESERVE_DCLK_AFTER_CONFIGURATION "USE AS REGULAR IO"

#============================================================
# CLOCK
#============================================================
set_location_assignment PIN_R8 -to CLOCK_50
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to CLOCK_50

#============================================================
# LED
#============================================================
set_location_assignment PIN_A15 -to LED[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[0]
set_location_assignment PIN_A13 -to LED[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[1]
set_location_assignment PIN_B13 -to LED[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[2]
set_location_assignment PIN_A11 -to LED[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[3]
set_location_assignment PIN_D1 -to LED[4]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[4]
set_location_assignment PIN_F3 -to LED[5]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[5]
set_location_assignment PIN_B1 -to LED[6]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[6]
set_location_assignment PIN_L3 -to LED[7]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to LED[7]

#============================================================
# KEY
#============================================================
set_location_assignment PIN_J15 -to KEY[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[0]
set_location_assignment PIN_E1 -to KEY[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to KEY[1]

#============================================================
# SW
#============================================================
set_location_assignment PIN_M1 -to SW[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[0]
set_location_assignment PIN_T8 -to SW[1]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[1]
set_location_assignment PIN_B9 -to SW[2]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[2]
set_location_assignment PIN_M15 -to SW[3]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[3]

set_location_assignment PIN_M1 -to SW[0]
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to SW[0]

#============================================================
# UART Tx (and VCC to drive a buffer)
#============================================================
set_location_assignment PIN_L14 -to UART_TX
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to UART_TX
set_location_assignment PIN_P15 -to UART_GND
set_instance_assignment -name IO_STANDARD "3.3-V LVTTL" -to UART_GND


#============================================================
# End of pin assignments by Terasic System Builder
#============================================================


set_global_assignment -name PARTITION_NETLIST_TYPE SOURCE -section_id Top
set_global_assignment -name PARTITION_FITTER_PRESERVATION_LEVEL PLACEMENT_AND_ROUTING -section_id Top
set_global_assignment -name PARTITION_COLOR 16764057 -section_id Top
set_global_assignment -name EDA_SIMULATION_TOOL "ModelSim-Altera (Verilog)"
set_global_assignment -name EDA_OUTPUT_DATA_FORMAT "VERILOG HDL" -section_id eda_simulation
set_global_assignment -name EDA_TIME_SCALE "1 ps" -section_id eda_simulation
set_global_assignment -name EDA_TEST_BENCH_ENABLE_STATUS TEST_BENCH_MODE -section_id eda_simulation
set_global_assignment -name EDA_NATIVELINK_SIMULATION_TEST_BENCH uart_tb -section_id eda_simulation
set_global_assignment -name EDA_DESIGN_INSTANCE_NAME NA -section_id uart_tb
set_global_assignment -name EDA_TEST_BENCH_MODULE_NAME uart_tb -section_id uart_tb
set_global_assignment -name EDA_TEST_BENCH_FILE uart_tb.v -section_id uart_tb
set_global_assignment -name VERILOG_FILE uart_tb.v
set_global_assignment -name VERILOG_FILE uart.v

set_global_assignment -name PROJECT_OUTPUT_DIRECTORY output_files
set_global_assignment -name MIN_CORE_JUNCTION_TEMP 0
set_global_assignment -name MAX_CORE_JUNCTION_TEMP 85
set_global_assignment -name EDA_TEST_BENCH_NAME uart_tb -section_id eda_simulation
set_global_assignment -name EDA_TEST_BENCH_RUN_SIM_FOR "2 s" -section_id uart_tb
set_instance_assignment -name PARTITION_HIERARCHY root_partition -to | -section_id Top


project_close
