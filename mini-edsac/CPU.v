module CPU (                    // MiniEdsac
   input        clock,          // clock (25MHz)
   input        reset,          // initial reset signal
   input [7:0]  rx_data_in,     // character read from PC
   input        rx_strobe,       // comes true when data has arrived
   output reg [7:0] tx_data,    // data to be sent to the PC
   output reg   tx_start,       // trigger to start sending
   input tx_busy,               // send has completed
   output [5:0] leds,           // output to LEDs 
   input but0                   // dump/reset button
   );

`include "ascii.inc"

   reg [31:0] Acc;               // Accumulator, double length
   reg [31:0] Mcandx;            // multiplicand, also double length
   reg [9:0]  SCT;               // sequence control tank (instruction counter)
   reg [15:0] IR;                // Instruction Register
   reg [7:0]  boot_data;         // word being assembled for initial orders
   reg [7:0]  rx_data;           // byte of data received from RS232 link
   reg [15:0] Mem[0:1023];	 // main memory
   reg 	      debug;	         // add extra tracing messages
   reg        dump;              // output a memory dump before execution
   reg        postmortem;	 // send halt after dumping memory
   reg [3:0]  debugindex;        // counter for debug info
   reg [7:0]  debugCode;         // error code for debug packets
   reg [7:0]  debug0, debug1, debug2; // debug bytes
   reg [7:0]  debug3, debug4, debug5; // debug bytes cont'd
   reg [15:0] mshift;            // bit shifter for multiply
   reg [9:0]  Addr;              // address part of IR
   reg 	      stopped;           // simulation halted
   reg 	      rx_ready1;         // synchronise rx_ready
   reg 	      data_ready;        // data has come ready
   reg [5:0]  shift;             // shift operation counter
   reg [15:0] Mpier;             // operand for multiply
   reg 	      but1;              // latch for dump/reset button
   reg [5:0]  save_state;        // debug failing state
   reg [5:0]  tx_return;         // resume state after send

   wire Sign;                    // sign of Accumulator
   wire [15:0] Mcand;            // 16 bit version of multiplicand
   wire [4:0]  Opcode;           // opcode part of IR
   wire        SPARE;		 // undefined bit
   wire        rx_H, rx_S, rx_G; // received character tests
   //  
   assign Sign  = Acc[31];
   assign Mcand = Mcandx[31:16];
   assign SPARE = IR[10];
   assign Opcode = IR[15:11];
   assign rx_H = rx_data == KH;
   assign rx_S = rx_data == KS;
   assign rx_G = rx_data == KG;

   reg [5:0] state;              // overall state
   parameter S_IDLE     = 6'd0;
   parameter S_START    = 6'd1;
   parameter S_CLEAR1   = 6'd2; 
   parameter S_LOAD1    = 6'd3;
   parameter S_LOAD2    = 6'd4;
   parameter S_LOAD3    = 6'd5;
   parameter S_LOAD4    = 6'd6;
   parameter S_LOAD5    = 6'd7;
   parameter S_FETCH1   = 6'd8;
   parameter S_FETCH2   = 6'd9;
   parameter S_FETCH3   = 6'd10;
   parameter S_EXECUTE1 = 6'd11;
   parameter S_EXECUTE2 = 6'd12;
   parameter S_EXECUTE3 = 6'd13;
   parameter S_EXECUTE4 = 6'd14;
   parameter S_EXECUTE5 = 6'd15;
   parameter S_EXECUTE6 = 6'd16;
   parameter S_EXECUTE7 = 6'd17;
   parameter S_EXECUTE8 = 6'd18;
   parameter S_EXECUTE9 = 6'd19;
   parameter S_DUMP1    = 6'd20;
   parameter S_DUMP2    = 6'd21;
   parameter S_DUMP3    = 6'd22;
   parameter S_DUMP4    = 6'd23;
   parameter S_RESET    = 6'd24;
   parameter S_RESET1   = 6'd25;
   parameter S_SEND     = 6'd26;
   parameter S_SEND2    = 6'd27;
   
   // pass current state to display on LEDs
   assign leds = state;

   // define the opcodes
   wire OP_A;           // Add to Acc
   wire OP_C;           // Collate opcode
   wire OP_E;           // Jump if Acc >= 0
   wire OP_G;           // Jump if Acc < 0
   wire OP_I;           // Input from tape reader
   wire OP_L;           // Shift Acc left
   wire OP_O;           // Output to Printer
   wire OP_R;           // Shift Acc right
   wire OP_S;           // Subtract from Acc
   wire OP_T;           // Store Acc and clear
   wire OP_U;           // Store Acc, don't clear
   wire OP_V;           // Multiply and Add
   wire OP_Z;           // Halt machine
   wire OP_FETCH;
   wire OP_TEST;
   wire OP_STORE;
   wire OP_SHIFT;
   // opcodes changed to be bottom 5 bits of ASCII codes
   assign OP_A = (Opcode == 5'b00001);
   assign OP_C = (Opcode == 5'b00011);
   assign OP_E = (Opcode == 5'b00101);
   assign OP_G = (Opcode == 5'b00111);
   assign OP_I = (Opcode == 5'b01001);
   assign OP_L = (Opcode == 5'b01100);
   assign OP_O = (Opcode == 5'b01111);
   assign OP_R = (Opcode == 5'b10010);
   assign OP_S = (Opcode == 5'b10011);
   assign OP_T = (Opcode == 5'b10100);
   assign OP_U = (Opcode == 5'b10101);
   assign OP_V = (Opcode == 5'b10110);
   assign OP_Z = (Opcode == 5'b11010);
   assign OP_FETCH = OP_A || OP_C || OP_O || OP_S || OP_V;
   assign OP_STORE = OP_T || OP_U;
   assign OP_TEST  = OP_E || OP_G;
   assign OP_SHIFT = OP_L || OP_R;

   always @ (posedge clock)
      if (reset) begin
         state <= S_IDLE;
         stopped <= 1'b1;
         tx_start <= 1'b0;
         data_ready <= 1'b0;
         debug <= 1'b0;
         debugindex <= 4'd0;
         debug0 <= 8'd0;
         debug1 <= 8'd0;
         debug2 <= 8'd0;
         debug3 <= 8'd0;
         debug4 <= 8'd0;
	 debug5 <= 8'd0;
         but1 <= 1'b0;
	 Acc <= 0;
	 IR <= 0;
      end
      else begin
         if (rx_strobe) begin
            data_ready <= 1'b1;
            rx_data <= rx_data_in;
         end
         but1 <= but0;              // latch state of button
         if (!but0 && but1) begin
            // button pressed
            save_state <= state;
            tx_data <= KK;
            tx_start <= 1'b1;
            tx_return <= S_RESET;
            state <= S_SEND;
         end
         else
         case (state)

         // waiting for start command from server
         S_IDLE:
            begin
               if (data_ready && (rx_data == KS)) begin
                  tx_data <= KS;
                  tx_start <= 1'b1;
                  debugCode <= KQ;
                  tx_return <= S_START;
                  data_ready <= 1'b0;
                  state <= S_SEND;
               end
            end // case: S_IDLE

         // waiting for Go or Debug command, assumes send complete
         S_START:
            if (data_ready) begin
               data_ready <= 1'b0;
               // check received command
               if (rx_data == KG || rx_data == KH ||
                   rx_data == KI || rx_data == KJ ) begin
                  Addr <= 10'd0;
                  stopped <= 1'b0;     // should be 1'b0 for real operation
                  debug <= (rx_data == KH || rx_data == KJ); // set debug messages on or off
                  dump  <= (rx_data == KI || rx_data == KJ); // set dump option
                  state <= S_CLEAR1;   // start by clearing store
               end
               // not Go or Debug, may be a new start?
               else if (rx_data == KS) begin
                  tx_data <= KS;
                  tx_start <= 1'b1;
                  state <= S_SEND;
               end
            end // case: S_START

         // Go received, clear the store
         S_CLEAR1:
            begin
               // check if all store cleared
               if (Addr == 11'd1023) begin
		  Mem[1023] <= 16'd0;
		  Addr <= 11'd0; // reset SCT
		  state <= S_LOAD1;
               end
               // if store ready, clear next word
               else begin
                  Mem[Addr] <= 16'd0;
                  Addr <= Addr + 11'd1;
               end
            end
 
         // Store cleared, request 1st byte of next initial order
         S_LOAD1: 
            begin
               tx_data <= KB;
               tx_start <= 1'b1;
               tx_return <= S_LOAD2;
               state <= S_SEND;
            end

         // 1st byte requested, wait for response
         S_LOAD2:
            begin
               // if byte received, save it and request next byte
               if (data_ready) begin
                  boot_data <= rx_data; // save data until next byte
                  data_ready <= 1'b0;
                  tx_data <= KC;
                  tx_start <= 1'b1;
                  tx_return <= S_LOAD3;
                  state <= S_SEND;
               end
            end // case: S_LOAD2

         // wait for second byte to arrive
         S_LOAD3:
            if (data_ready) begin
               Mem[Addr] <= { boot_data, rx_data }; // combine the two bytes
               data_ready <= 1'b0;
	       Addr <= Addr + 10'd1;
               state <= S_LOAD4;
            end

         // write complete, request further word, or run command
         S_LOAD4:
            begin
               tx_data <= KD;
               tx_start <= 1'd1;
               tx_return <= S_LOAD5;
               state <= S_SEND;
            end

         // request triggered, wait for response
         S_LOAD5:
            begin
               if (data_ready)  begin
                  // response arrived, check for more boot or run
                  data_ready <= 1'b0;
                  if (rx_data == KB)	 // continue loading, data byte follows
                     state <= S_LOAD2; // data follows immediately
                  else begin
                     // Start command, reset SCT and move to run phase
                     SCT <= 10'd0; // reset SCT for loader to run
		     Addr <= 10'd0; // and Addr for dumps
                     if (dump)
                        state <= S_DUMP1;    // send a dump of store
                     else   
                        state <= S_FETCH1;   // start execution
                  end
               end
            end // case: S_LOAD5

         // Run phase 1: Instruction fetch
         // request next order from store,
         S_FETCH1:
	   begin
	      Addr <= SCT;
               state <= S_FETCH2;
            end

         // wait for fetch completion
         S_FETCH2:
	   begin
               IR <= Mem[Addr];
	      state <= S_FETCH3;
	   end

	   // Next order now in IR
	   S_FETCH3:
	     begin
		 // read completed
		debug0 <= { 6'd0, SCT[9:8] };
		debug1 <= SCT[7:0];
		debug2 <= IR[15:8];
		debug3 <= IR[7:0];
		debug4 <= 8'd0;
		debug5 <= 8'd0;
		Addr <= IR[9:0];
		// Opcode <= IR[15:11];  // already set via assign
		state <= S_EXECUTE1;  // enter execute phase
	      end

         // Run Phase 2: Execute instruction
         S_EXECUTE1:
            begin
               // interpret the opcode
               // See if Store access is required
               if (OP_FETCH) begin
		  Mcandx <= { Mem[Addr], 16'd0 };
                  state <= S_EXECUTE3;
 	       end
	       else if (OP_STORE) begin
                  // Store, initiate store write
                  // address already set in Addr above
                  Mem[Addr] <= Acc[31:16];
		  if (OP_T)
		    Acc <= 32'd0;         // clear Acc if T
		  state <= S_EXECUTE6;    // finished
               end
               else if (OP_SHIFT) begin
                  // Shifts don't need store access
                  shift <= Addr[5:0]; // set shift bit count
                  state <= S_EXECUTE2;
               end
               else if (OP_I) begin
                  // Input data, send request to PC for data
                  tx_data <= KR;
                  tx_start <= 1'b1;
                  tx_return <= S_EXECUTE2; // wait for response
                  state <= S_SEND;
               end
               else if (OP_TEST) begin
                  // tests can be executed immediately
                  if ((OP_G && Sign) || (OP_E && !Sign))
                     SCT <= Addr;    // set new address in SCT
                  else
                     SCT <= SCT + 11'd1;// increment SCT if no jump
                  if (debug)
                     state <= S_EXECUTE8; // direct to instruction completion
                  else
                     state <= S_FETCH1; // back for next order
               end
               else if (OP_Z) begin
                  // halt machine deliberately
                  stopped <= 1'b1;
                  debugCode <= KZ;
		  if (Addr == 10'd1) begin
		     postmortem <= 1'b1; // request memory dump after halt
		     Addr <= 10'd0;
		     state <= S_DUMP1;
		  end
		  else
                    state <= S_EXECUTE8; // complete send then idle
               end
               else begin           
                  // illegal opcode?, halt anyway
                  stopped <= 1'b1;
                  debugCode <= KH;
		  postmortem <= 1'b1;
		  Addr <= 10'd0;
                  state <= S_DUMP1; // dump store, complete send, then idle
               end
            end // case: S_EXECUTE1

         // Continue execution, depends on the order
         S_EXECUTE2:
            begin
               if (OP_SHIFT) begin
                  // now we can do the shift, one bit at a time
                  if (shift == 16'd0)
                     state <= S_EXECUTE6; // complete, finish off
                  else begin
                     if (OP_L)
                        Acc <= { Acc[30:0], 1'b0 }; // pad left shift with zero bit
                     else
                        Acc[30:0] <= Acc[31:1];     // propagate sign...
                     shift <= shift - 6'd1;	     // decrement bit count
                  end;
               end // if (OP_SHIFT)
               else if (OP_I) begin
                  // Input a byte. Wait for data to arrive
                  if (data_ready) begin
                     // data has arrived, store in Acc
                     data_ready <= 1'b0;
                     Acc <= { 8'd0, rx_data, 16'd0 };
                     state <= S_EXECUTE6;          // finish order
                  end
               end
            end // case: S_EXECUTE2

         // Process fetched data
         S_EXECUTE3:
            if (OP_A) begin
               Acc <= Acc + Mcandx;    // Add operation
               state <= S_EXECUTE6;
            end
            else if (OP_S) begin
               Acc <= Acc - Mcandx;    // Subtract operation
               state <= S_EXECUTE6;
            end
            else if (OP_C) begin
               Acc <= Acc & Mcandx;    // Collate operation
               state <= S_EXECUTE6;
            end
            else if (OP_V) begin       // Multiply operation
               // this sets up the multiply operands
               // first extend the Mcand to 32 bits
               if (Mcand[15])
                  Mcandx <= { 16'hFFFF, Mcand };
               else
                  Mcandx <= { 16'd0, Mcand };
               Mpier <= Acc[31:16];
               Acc <= 32'd0;	         // clear Acc for result
               mshift <= 16'd1;	 // initialise shift counter
               state <= S_EXECUTE4;	 // enter multiplication states
            end
            else if (OP_O) begin
               // output order, send a print request
               tx_data <= KT;
               tx_start <= 1'b1;       // trigger a request write
               state <= S_SEND;
               tx_return <= S_EXECUTE4;
            end

         // further processing for multiply and print
         S_EXECUTE4:
            if (OP_V) begin
               if (mshift == 16'd0) begin
                  if (Mpier[15])
		    Acc <= Acc - Mcandx;
		  state <= S_EXECUTE6; // opertion complete, finish off
	       end
               else begin
                  // test muliplier bit to see if we need to add in mcand
                  if ((mshift & Mpier) != 16'd0) begin
                     Acc <= Acc + Mcandx; // // add it in
                  end
                  Mcandx <= { Mcandx[30:0], 1'b0 }; // shift mcand left one bit
                  mshift <= { mshift[14:0], 1'b0 };   // shift shifter left one bit
               end
            end // if (OP_V)
            else if (OP_O) begin
               // wait for acknowledgement
               if (data_ready) begin
                  // Assume acknowledgement is OK?
                  // set data from Mcand and trigger write
                  data_ready <= 1'b0;
                  tx_data <= Mcand[7:0];
                  tx_start <= 1'b1;
                  state <= S_SEND;
                  tx_return <= S_EXECUTE5; // wait for completion
               end
            end // if (OP_O)

         // finalise print, wait for acknowledgement
         S_EXECUTE5:
            begin
               if (data_ready) begin // wait for acknowledge of receipt
                  data_ready <= 1'b0;
                  debug5 <= Mcand[7:0];
                  state <= S_EXECUTE7;
               end
            end
 
         // normal instruction termination
         // if debugging, send trace info
         S_EXECUTE6:
	         // operation ended normally, Acc involved
	         // Add Acc to trace
            begin
               debug4 <= Acc[31:24];
               debug5 <= Acc[23:16];
               state <= S_EXECUTE7;
            end

         // Bump SCT ready for next instruction
         S_EXECUTE7:
            begin
               SCT <= SCT+11'd1;
               if (debug)
                  state <= S_EXECUTE8;
               else
                  state <= S_FETCH1;
            end

         // start writing trace
         S_EXECUTE8:
            begin
               // pack up trace info
               debugindex <= 4'd0;
               tx_data <= debugCode;
               tx_start <= 1'b1;
               state <= S_SEND;
               tx_return <= S_EXECUTE9;
            end

         // tracing info, send next byte when previous one complete
         S_EXECUTE9:
            begin
               if (debugindex == 4'd6) begin
                  if (stopped)
                     state <= S_IDLE;
                  else
                     state <= S_FETCH1;
               end
               else begin
                  case (debugindex)
                    4'd0:    tx_data <= debug0;
                    4'd1:    tx_data <= debug1;
                    4'd2:    tx_data <= debug2;
                    4'd3:    tx_data <= debug3;
                    4'd4:    tx_data <= debug4;
                    4'd5:    tx_data <= debug5;
		    default: tx_data <= 8'd0;
                  endcase // case (debugindex)
                  tx_start <= 1'b1;
                  debugindex <= debugindex + 4'd1;
                  state <= S_SEND;        // tx_return already set
               end
            end

         // dump store before running
         S_DUMP1:
            if (Addr == 10'd1023) begin
	       if (postmortem) begin
		  state <= S_EXECUTE8;
	       end
	       else begin
		  SCT <= 10'd0;
		  if (stopped)
		    state <= S_IDLE;
		  else
		    state <= S_FETCH1;       // go to run program
	       end
            end
            else begin
               IR <= Mem[Addr];
               state <= S_DUMP2;
            end

         // dump: Check for nulls, send trigger byte
         S_DUMP2:
            begin
               if (IR == 16'd0) begin
                  state <= S_DUMP4;
               end
               else begin
                  tx_data <= KM;
                  tx_start <= 1'b1;    // send mem dump trigger code
                  debugindex <= 4'd0;
                  state <= S_SEND;
                  tx_return <= S_DUMP3;
               end
            end

         // dump: send next byte
         S_DUMP3:
            if (debugindex == 4'd6) begin
	       Addr <= Addr + 10'd1;
               state <= S_DUMP1;
            end
            else begin
               case (debugindex)
		 4'd0: tx_data <= { 6'd0, Addr[9:8] };
		 4'd1: tx_data <= Addr[7:0];
		 4'd2: tx_data <= IR[15:8];
		 4'd3: tx_data <= IR[7:0];
		 default: tx_data <= 8'd0;
               endcase
               tx_start <= 1'd1;
               debugindex <= debugindex + 4'd1;
               state <= S_SEND;
            end

         // dump: bump Addr and repeat until done
         S_DUMP4:
            begin
               Addr <= Addr + 10'd1;
               state <= S_DUMP1;
            end

         // dump/reset button pressed
         S_RESET:
            begin
               tx_data <= save_state;
               tx_start <= 1'b1;
               Addr <= 11'd0;
               tx_return <= S_RESET1;
               state <= S_SEND;
            end

         // Dump/reset continuation
         S_RESET1:
            begin
               stopped <= 1'b1;
               state <= S_DUMP1;
            end

         // TX send subroutine
         S_SEND:
            if (tx_busy) begin
               tx_start <= 1'b0;
               state <= S_SEND2;
            end

         // TX send continuation
         S_SEND2:
            if (!tx_busy)
               state <= tx_return;

         endcase // case (state)
      end // else: !if(reset)
endmodule


