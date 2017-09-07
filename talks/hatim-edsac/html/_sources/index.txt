
.. What's New in High-Performance Python? slides file, created by
   hieroglyph-quickstart on Sat Apr 30 21:13:03 2016.


A New Implementation of EDSAC
=============================

| Hatim Kanchwala

Module hierarchy
----------------

.. figure:: 1.png

Generic module structure
------------------------

.. figure:: 2.png

Delay line implementation (1)
-----------------------------

.. code-block:: verilog

   module delay_line
     #(parameter STORE_LEN  = 16,
       parameter WORD_WIDTH = 36)
      (output reg [STORE_LEN*WORD_WIDTH-1:0] monitor,
       output reg                            data_out,
       input wire                            clk,
       input wire                            data_in,
       input wire                            data_in_gate,
       input wire                            data_clr // Active low. );

      reg [STORE_LEN*WORD_WIDTH-1:0] store;
      integer                        i;

      initial begin
         // Assuming stores in delay lines were cleared.
         monitor = 0;
         store = 0;
         data_out = 1'b0;
      end

Delay line implementation (2)
-----------------------------

.. code-block:: verilog

      // Recirculation logic.
      always @(posedge clk) begin
         for (i = 0; i < STORE_LEN*WORD_WIDTH-1; i = i + 1)
           store[i] <= store[i+1];

         store[STORE_LEN*WORD_WIDTH-1] <= (data_in_gate) ? data_in : (store[0] & data_clr);
      end

      always @(negedge clk) begin
         monitor[STORE_LEN*WORD_WIDTH-1:0] <= store[STORE_LEN*WORD_WIDTH-1:0];
         data_out <= store[0];
      end

   endmodule

Use of delay lines in memory
----------------------------

.. code-block:: verilog

   module memory
      (output wire [575:0] monitor, // External long tank display for full 576 bits.
       output wire         mob_tn,
       input wire          clk,
       input wire          mib,
       input wire          tn_in,
       input wire          tn_clr,
       input wire          tn_out );

      delay_line #(.STORE_LEN(16), .WORD_WIDTH(36)) dl
        (.monitor      (monitor),
         .clk          (clk),
         .data_in      (mib),
         .data_in_gate (tn_in),
         .data_clr     (tn_clr) );

      assign mob_tn = tn_out ? monitor[0] : 1'bz;
    endmodule

Control section modules
-----------------------

.. figure:: 5.png

Computer modules
----------------

.. figure:: 6.png
